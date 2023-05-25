codeunit 37002465 "Equipment Board Management"
{
    // PR4.00
    // P8000197A, Myers Nissi, Jack Reynolds, 22 SEP 05
    //   Functions to manages equipment availability for equipment board and daily produciton planning board
    // 
    // PR4.00.05
    // P8000454B, VerticalSoft, Jack Reynolds, 19 FEB 07
    //   Fix overflow error with FormatDuration
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017


    trigger OnRun()
    begin
    end;

    var
        EquipBoard: Record "Equipment Board" temporary;
        LocationCapacity: Record "Equipment Board" temporary;
        TempLocation: Record Location temporary;
        ProdOrder: Record "Production Order";
        Date: Record Date;
        ProdPlanChange: Record "Daily Prod. Planning-Change" temporary;
        DateFormat: Text[250];
        Text002: Label '<Mon>/<Day>/<Year,2>';
        Text003: Label 'week of <Mon>/<Day>/<Year,2>';
        Text004: Label 'month of <Mon>/<Year,2>';
        BufferLimit: array[4] of BigInteger;

    procedure Initialize(BaseDate: Date; PeriodType: Option Day,Week,Month; Periods: Integer)
    var
        Location: Record Location;
        MfgSetup: Record "Manufacturing Setup";
        Date1: Record Date;
    begin
        Clear(BufferLimit);
        // Maximum number of records in temp equipment board table
        BufferLimit[1] := 100000;
        // Number of records to delete when table is full - 20%, rounded to be entire sets of data
        BufferLimit[4] := Round(BufferLimit[1] * 0.2, 3 * Periods);

        EquipBoard.Reset;
        EquipBoard.DeleteAll;
        LocationCapacity.Reset;
        LocationCapacity.DeleteAll;
        TempLocation.Reset;
        TempLocation.DeleteAll;
        Clear(TempLocation);

        MfgSetup.Get;
        TempLocation."Normal Starting Time" := MfgSetup."Normal Starting Time";
        TempLocation."Normal Ending Time" := MfgSetup."Normal Ending Time";
        TempLocation.Insert;
        if Location.Find('-') then
            repeat
                TempLocation := Location;
                if TempLocation."Normal Starting Time" = 0T then
                    TempLocation."Normal Starting Time" := MfgSetup."Normal Starting Time";
                if TempLocation."Normal Ending Time" = 0T then
                    TempLocation."Normal Ending Time" := MfgSetup."Normal Ending Time";
                TempLocation.Insert;
            until Location.Next = 0;

        Date.Reset;
        Date.SetRange("Period Type", PeriodType);
        Date.SetFilter("Period Start", '<=%1', BaseDate);
        Date.Find('+');
        Date1 := Date;
        Date.SetRange("Period Start");
        Date.Next(Periods - 1);
        Date.SetRange("Period Start", Date1."Period Start", Date."Period Start");
        case PeriodType of
            PeriodType::Day:
                DateFormat := Text002;
            PeriodType::Week:
                DateFormat := Text003;
            PeriodType::Month:
                DateFormat := Text004;
        end;

        ProdOrder.Reset;
        ProdOrder.SetCurrentKey("Equipment Code", "Starting Date", "Ending Date");
        ProdOrder.SetRange("Starting Date", 0D, NormalDate(Date."Period End"));
        ProdOrder.SetRange("Ending Date", Date1."Period Start", DMY2Date(31, 12, 9999)); // P8007748
        ProdOrder.SetRange(Status, ProdOrder.Status::"Firm Planned", ProdOrder.Status::Released);
    end;

    procedure GetQuantity(EquipCode: Code[20]; DateOffset: Integer; DataElement: Integer): Decimal
    begin
        if not EquipBoard.Get(EquipCode, DateOffset, DataElement) then begin
            Calculate(EquipCode);
            EquipBoard.Get(EquipCode, DateOffset, DataElement);
        end;

        exit(EquipBoard.Quantity);
    end;

    procedure GetIncludesProdChanges(EquipCode: Code[20]; DateOffset: Integer; DataElement: Integer) IncludesProdChanges: Boolean
    begin
        if not EquipBoard.Get(EquipCode, DateOffset, DataElement) then begin
            Calculate(EquipCode);
            EquipBoard.Get(EquipCode, DateOffset, DataElement);
        end;

        exit(EquipBoard."Includes Production Changes");
    end;

    procedure GetData(EquipCode: Code[20]; DateOffset: Integer; DataElement: Integer; var Quantity: Decimal; var IncludesProdChanges: Boolean)
    begin
        IncludesProdChanges := false;
        if not EquipBoard.Get(EquipCode, DateOffset, DataElement) then begin
            Calculate(EquipCode);
            EquipBoard.Get(EquipCode, DateOffset, DataElement);
        end;

        Quantity := EquipBoard.Quantity;
        IncludesProdChanges := EquipBoard."Includes Production Changes";
    end;

    procedure Calculate(EquipCode: Code[20])
    var
        ProdDateTime: Record "Production Time by Date" temporary;
        Resource: Record Resource;
        P800CalMgt: Codeunit "Process 800 Calendar Mngt.";
        ProdTime: Decimal;
        DateOffset: Integer;
        IncludesProdChange: Boolean;
    begin
        CalculateEquipCapacity(EquipCode);

        ProdOrder.SetRange("Equipment Code", EquipCode);
        if ProdOrder.Find('-') then
            repeat
                P800CalMgt.GetProductionDateTime(ProdOrder."Location Code", ProdOrder."Starting Date", ProdOrder."Starting Time",
                  ProdOrder."Ending Date", ProdOrder."Ending Time", ProdDateTime);
                EquipBoard."Equipment Code" := EquipCode;
                EquipBoard."Data Element" := EquipBoard."Data Element"::Production;
                EquipBoard."Date Offset" := 0;
                Date.Find('-');
                repeat
                    ProdDateTime.SetRange(Date, Date."Period Start", NormalDate(Date."Period End"));
                    ProdDateTime.CalcSums("Time Required");
                    if ProdDateTime."Time Required" <> 0 then begin
                        if EquipBoard.Find then begin
                            EquipBoard.Quantity += ProdDateTime."Time Required";
                            EquipBoard.Modify;
                        end else begin
                            EquipBoard.Quantity := ProdDateTime."Time Required";
                            InsertEquipBoardData;
                        end;
                    end;
                    EquipBoard."Date Offset" += 1;
                until Date.Next = 0;
            until ProdOrder.Next = 0;

        ProdPlanChange.Reset;
        ProdPlanChange.SetRange("Equipment Code", EquipCode);
        EquipBoard."Data Element" := EquipBoard."Data Element"::Production;
        if ProdPlanChange.Find('-') then begin
            EquipBoard."Date Offset" := 0;
            Date.Find('-');
            repeat
                ProdPlanChange.SetRange(Date, Date."Period Start", NormalDate(Date."Period End"));
                if ProdPlanChange.Find('-') then begin
                    ProdPlanChange.CalcSums(Duration);
                    if not EquipBoard.Find then begin
                        EquipBoard.Quantity := 0;
                        InsertEquipBoardData;
                    end;
                    EquipBoard.Quantity += ProdPlanChange.Duration;
                    EquipBoard."Includes Production Changes" := true;
                    EquipBoard.Modify;
                end;
                EquipBoard."Date Offset" += 1;
            until Date.Next = 0;
        end;

        EquipBoard.Reset;
        Date.Find('-');
        repeat
            if not EquipBoard.Get(EquipCode, DateOffset, EquipBoard."Data Element"::Production) then begin
                EquipBoard."Equipment Code" := EquipCode;
                EquipBoard."Date Offset" := DateOffset;
                EquipBoard."Data Element" := EquipBoard."Data Element"::Production;
                EquipBoard.Quantity := 0;
                EquipBoard."Includes Production Changes" := false;
                InsertEquipBoardData;
            end;
            ProdTime := EquipBoard.Quantity;
            IncludesProdChange := EquipBoard."Includes Production Changes";
            EquipBoard.Get(EquipCode, DateOffset, EquipBoard."Data Element"::Capacity);
            EquipBoard."Data Element" := EquipBoard."Data Element"::Available;
            EquipBoard.Quantity := EquipBoard.Quantity - ProdTime;
            EquipBoard."Includes Production Changes" := IncludesProdChange;
            InsertEquipBoardData;
            DateOffset += 1;
        until Date.Next = 0;
    end;

    procedure CalculateEquipCapacity(EquipCode: Code[20])
    var
        Resource: Record Resource;
        ProdDateTime: Record "Production Time by Date" temporary;
    begin
        if not Resource.Get(EquipCode) then
            Clear(Resource);

        // Since the capacity of the equipment is dependent on the location, we will calculate it once per location and
        // copy it for the equipment when needed
        CalculateLocCapacity(Resource."Location Code");
        LocationCapacity.SetRange("Equipment Code", Resource."Location Code");
        if LocationCapacity.Find('-') then
            repeat
                EquipBoard := LocationCapacity;
                EquipBoard."Equipment Code" := EquipCode;
                InsertEquipBoardData;
            until LocationCapacity.Next = 0;
    end;

    procedure CalculateLocCapacity(LocCode: Code[10])
    var
        ProdDateTime: Record "Production Time by Date" temporary;
        P800CalendarMgt: Codeunit "Process 800 Calendar Mngt.";
        StartDate: Date;
    begin
        TempLocation.Get(LocCode);
        if TempLocation.Mark then
            exit;

        Date.Find('-');
        StartDate := Date."Period Start";
        Date.Find('+');
        P800CalendarMgt.GetProductionDateTime(LocCode, StartDate - 1, TempLocation."Normal Starting Time",
          NormalDate(Date."Period End") + 1, TempLocation."Normal Ending Time", ProdDateTime);

        LocationCapacity."Equipment Code" := LocCode;
        LocationCapacity."Date Offset" := 0;
        LocationCapacity."Data Element" := LocationCapacity."Data Element"::Capacity;
        Date.Find('-');
        repeat
            ProdDateTime.SetRange(Date, Date."Period Start", NormalDate(Date."Period End"));
            ProdDateTime.CalcSums("Time Required");
            LocationCapacity.Quantity := ProdDateTime."Time Required";
            LocationCapacity.Insert;
            LocationCapacity."Date Offset" += 1;
        until Date.Next = 0;

        TempLocation.Mark(true);
    end;

    procedure InsertEquipBoardData()
    var
        EquipBoard2: Record "Equipment Board";
        BufferOffset: Integer;
    begin
        BufferLimit[2] += 1;
        BufferLimit[3] += 1;
        if BufferLimit[1] < BufferLimit[2] then begin
            EquipBoard2.Copy(EquipBoard);
            EquipBoard.Reset;
            EquipBoard.SetCurrentKey("Record No.");
            BufferOffset := BufferLimit[3] - BufferLimit[2];
            EquipBoard.Find('-');
            EquipBoard.SetRange("Record No.", 1 + BufferOffset, BufferLimit[4] + BufferOffset);
            EquipBoard.DeleteAll;
            BufferLimit[2] -= BufferLimit[4];
            EquipBoard.Copy(EquipBoard2);
        end;
        EquipBoard."Record No." := BufferLimit[3];
        EquipBoard.Insert;
    end;

    procedure GetHeading(DateOffset: Integer; DataElement: Integer): Text[30]
    var
        DateAvail: Date;
    begin
        EquipBoard."Data Element" := DataElement;
        if EquipBoard."Data Element" <> EquipBoard."Data Element"::Available then
            exit(Format(EquipBoard."Data Element"));

        Date.Find('-');
        if DateOffset = Date.Next(DateOffset) then
            DateAvail := Date."Period Start"
        else
            DateAvail := NormalDate(Date."Period End") + 1;
        exit(Format(DateAvail, 0, '<Month,2>/<Day,2>') + ' ' + Format(EquipBoard."Data Element"));
    end;

    procedure DrillDown(EquipCode: Code[20]; DateOffset: Integer; DataElement: Integer)
    var
        EquipBoardDrillDown: Record "Equipment Board" temporary;
    begin
        EquipBoard.Reset;
        EquipBoard.Get(EquipCode, DateOffset, DataElement);
        EquipBoardDrillDown := EquipBoard;
        SetEquipBoardDate(EquipBoardDrillDown);
        EquipBoardDrillDown.Insert;

        if DataElement = EquipBoard."Data Element"::Available then begin
            EquipBoard.Get(EquipCode, DateOffset, EquipBoard."Data Element"::Capacity);
            EquipBoardDrillDown := EquipBoard;
            SetEquipBoardDate(EquipBoardDrillDown);
            EquipBoardDrillDown.Insert;

            EquipBoard.Get(EquipCode, DateOffset, EquipBoard."Data Element"::Production);
            EquipBoardDrillDown := EquipBoard;
            SetEquipBoardDate(EquipBoardDrillDown);
            EquipBoardDrillDown.Insert;
        end;

        EquipBoardDrillDown.Get(EquipCode, DateOffset, DataElement);

        ProdPlanChange.Reset;
        ProdPlanChange.SetCurrentKey("Equipment Code");
        ProdPlanChange.SetRange("Equipment Code", EquipCode);
        if ProdPlanChange.Find('-') then
            EquipBoardDrillDown.SetProdPlanChange(ProdPlanChange);

        EquipBoardDrillDown.DrillDown(Date);
        EquipBoard.Reset;
    end;

    procedure SetEquipBoardDate(var EquipBoard: Record "Equipment Board")
    var
        Dt: Date;
    begin
        Date.Find('-');
        if (EquipBoard."Date Offset" = -1) or (EquipBoard."Date Offset" = Date.Next(EquipBoard."Date Offset")) then
            Dt := Date."Period Start"
        else
            Dt := NormalDate(Date."Period End") + 1;
        EquipBoard."Date Text" := StrSubstNo('(%1)', Format(Dt, 0, DateFormat));
    end;

    procedure FormatDuration(Duration: BigInteger) Result: Text[30]
    var
        Hours: Integer;
        Minutes: Integer;
        Sign: Text[1];
    begin
        // P8000454B - change Duration to BigInteger
        if Duration < 0 then begin
            Sign := '-';
            Duration := -Duration;
        end;

        Duration := Round(Duration / 60000, 1);
        Hours := Duration div 60;
        Minutes := Duration mod 60;

        Result := Format(Minutes);
        if StrLen(Result) = 1 then
            Result := '0' + Result;

        Result := Sign + Format(Hours) + ':' + Result;
    end;

    procedure ShowRecord(EquipCode: Code[20]; OverCapacityOnly: Boolean): Boolean
    var
        DateOffset: Integer;
        Periods: Integer;
    begin
        if OverCapacityOnly then begin
            if not EquipBoard.Get(EquipCode, 0, 0) then
                Calculate(EquipCode);
            Periods := Date.Count - 1;
            for DateOffset := 0 to Periods do begin
                EquipBoard.Get(EquipCode, DateOffset, EquipBoard."Data Element"::Available);
                if EquipBoard.Quantity < 0 then
                    exit(true);
            end;
        end else
            exit(true);
    end;

    procedure AddProductionChanges(var ProdPlanChange2: Record "Daily Prod. Planning-Change" temporary)
    begin
        EquipBoard.Reset;
        ProdPlanChange.Reset;
        ProdPlanChange.SetRange(Status, ProdPlanChange2.Status);
        ProdPlanChange.SetRange("Production Order No.", ProdPlanChange2."Production Order No.");
        if ProdPlanChange.Find('-') then
            repeat
                EquipBoard.SetRange("Equipment Code", ProdPlanChange."Equipment Code");
                EquipBoard.DeleteAll;
                ProdPlanChange.SetRange("Equipment Code", ProdPlanChange."Equipment Code");
                ProdPlanChange.DeleteAll;
                ProdPlanChange.SetRange("Equipment Code");
            until ProdPlanChange.Next = 0;
        ProdPlanChange.Reset;

        ProdPlanChange2.SetCurrentKey("Equipment Code");
        ProdPlanChange2.SetFilter(Duration, '<>0');
        if ProdPlanChange2.Find('-') then
            repeat
                EquipBoard.SetRange("Equipment Code", ProdPlanChange2."Equipment Code");
                EquipBoard.DeleteAll;
                ProdPlanChange2.SetRange("Equipment Code", ProdPlanChange2."Equipment Code");
                repeat
                    ProdPlanChange := ProdPlanChange2;
                    ProdPlanChange.Insert;
                until ProdPlanChange2.Next = 0;
                ProdPlanChange2.SetRange("Equipment Code");
            until ProdPlanChange2.Next = 0;

        EquipBoard.Reset;
    end;
}

