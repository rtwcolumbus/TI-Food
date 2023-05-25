codeunit 37002464 "Process 800 Calendar Mngt."
{
    // PR4.00
    // P8000197A, Myers Nissi, Jack Reynolds, 22 SEP 05
    //   Collection of P800 calendar functions


    trigger OnRun()
    begin
    end;

    var
        Location: Record Location;
        BaseCalChange: Record "Base Calendar Change";
        CustCalChange: Record "Customized Calendar Change";
        LocationRead: Boolean;

    procedure CalculateProductionDateTime(LocationCode: Code[10]; BaseDate: Date; BaseTime: Time; Direction: Option Forward,Backward; ProductionHours: Decimal; var NewDate: Date; var NewTime: Time; var ProdDateTime: Record "Production Time by Date" temporary)
    var
        ProductionTime: Decimal;
    begin
        NewDate := BaseDate;
        NewTime := BaseTime;
        ProdDateTime.Reset;
        ProdDateTime.DeleteAll;

        if ProductionHours <= 0 then
            exit;

        ProductionTime := Round(ProductionHours * 3600000, 1); // hours to milliseconds

        GetLocation(LocationCode);

        case Direction of
            Direction::Forward:
                begin
                    GetDates(BaseDate, Location."Normal Ending Time" - BaseTime, ProductionTime, 1, ProdDateTime);
                    ProdDateTime.Find('-');
                    ProdDateTime."Starting Time" := BaseTime;
                    ProdDateTime.Modify;

                    ProdDateTime.Find('+');
                    NewDate := ProdDateTime.Date;
                    if NewDate = BaseDate then
                        NewTime := BaseTime + ProdDateTime."Time Required"
                    else
                        NewTime := Location."Normal Starting Time" + ProdDateTime."Time Required";
                end;
            Direction::Backward:
                begin
                    GetDates(BaseDate, BaseTime - Location."Normal Starting Time", ProductionTime, -1, ProdDateTime);
                    ProdDateTime.Find('-');
                    NewDate := ProdDateTime.Date;
                    if NewDate = BaseDate then
                        NewTime := BaseTime - ProdDateTime."Time Required"
                    else
                        NewTime := Location."Normal Ending Time" - ProdDateTime."Time Required";
                    ProdDateTime."Starting Time" := NewTime;
                    ProdDateTime.Modify;
                end;
        end;
    end;

    procedure GetProductionDateTime(LocationCode: Code[10]; StartDate: Date; StartTime: Time; EndDate: Date; EndTime: Time; var ProdDateTime: Record "Production Time by Date" temporary)
    var
        Description: Text[30];
    begin
        ProdDateTime.Reset;
        ProdDateTime.DeleteAll;

        GetLocation(LocationCode);
        if StartTime = 0T then
            StartTime := Location."Normal Starting Time";
        if EndTime = 0T then
            EndTime := Location."Normal Ending Time";

        if StartDate = EndDate then begin
            ProdDateTime.Date := StartDate;
            ProdDateTime."Starting Time" := StartTime;
            ProdDateTime."Time Required" := EndTime - StartTime;
            ProdDateTime.Insert;
        end else begin
            ProdDateTime.Date := StartDate;
            ProdDateTime."Starting Time" := StartTime;
            ProdDateTime."Time Required" := Location."Normal Ending Time" - StartTime;
            ProdDateTime.Insert;

            ProdDateTime.Date := EndDate;
            ProdDateTime."Starting Time" := Location."Normal Starting Time";
            ProdDateTime."Time Required" := EndTime - Location."Normal Starting Time";
            ProdDateTime.Insert;

            ProdDateTime."Time Required" := Location."Normal Ending Time" - Location."Normal Starting Time";
        end;

        while StartDate < EndDate - 1 do begin
            StartDate := StartDate + 1;
            if CheckCalendar(StartDate, Description) then begin
                ProdDateTime.Date := StartDate;
                ProdDateTime."Starting Time" := Location."Normal Starting Time";
                ProdDateTime.Insert;
            end;
        end;
    end;

    procedure GetLocation(LocationCode: Code[10])
    var
        CompanyInfo: Record "Company Information";
        MfgSetup: Record "Manufacturing Setup";
    begin
        if (LocationCode = Location.Code) and LocationRead then
            exit;

        Clear(Location);
        if Location.Get(LocationCode) then;

        if Location."Base Calendar Code" = '' then begin
            CompanyInfo.Get;
            Location."Base Calendar Code" := CompanyInfo."Base Calendar Code";
        end;

        if Location."Normal Starting Time" = 0T then begin
            MfgSetup.Get;
            Location."Normal Starting Time" := MfgSetup."Normal Starting Time";
        end;
        if Location."Normal Ending Time" = 0T then begin
            MfgSetup.Get;
            Location."Normal Ending Time" := MfgSetup."Normal Ending Time";
        end;

        BaseCalChange.Reset;
        BaseCalChange.SetRange("Base Calendar Code", Location."Base Calendar Code");

        CustCalChange.Reset;
        CustCalChange.SetRange("Source Type", CustCalChange."Source Type"::Location);
        CustCalChange.SetRange("Source Code", Location.Code);
        CustCalChange.SetRange("Base Calendar Code", Location."Base Calendar Code");

        LocationRead := true;
    end;

    procedure GetDates(CurrentDate: Date; FirstDayTime: Decimal; ProductionTime: Decimal; Direction: Integer; var ProdDateTime: Record "Production Time by Date" temporary)
    var
        TimeInDay: Decimal;
        Description: Text[30];
    begin
        if FirstDayTime > 0 then begin
            if FirstDayTime > ProductionTime then
                FirstDayTime := ProductionTime;
            ProdDateTime.Date := CurrentDate;
            ProdDateTime."Time Required" := FirstDayTime;
            ProdDateTime.Insert;
            ProductionTime -= ProdDateTime."Time Required";
        end;

        TimeInDay := Location."Normal Ending Time" - Location."Normal Starting Time";

        while ProductionTime > 0 do begin
            CurrentDate := CurrentDate + Direction;
            if CheckCalendar(CurrentDate, Description) then begin
                ProdDateTime.Date := CurrentDate;
                if ProductionTime > TimeInDay then
                    ProdDateTime."Time Required" := TimeInDay
                else
                    ProdDateTime."Time Required" := ProductionTime;
                ProdDateTime."Starting Time" := Location."Normal Starting Time";
                ProdDateTime.Insert;
                ProductionTime -= ProdDateTime."Time Required";
            end;
        end;
    end;

    procedure CheckCalendar(TargetDate: Date; var Description: Text[30]): Boolean
    begin
        Description := '';
        if CustCalChange.Find('-') then
            repeat
                if DateMatch(TargetDate, CustCalChange."Recurring System",
                  CustCalChange.Date, CustCalChange.Day)
                then begin
                    Description := CustCalChange.Description;
                    exit(not CustCalChange.Nonworking);
                end;
            until CustCalChange.Next = 0;

        if BaseCalChange.Find('-') then
            repeat
                if DateMatch(TargetDate, BaseCalChange."Recurring System",
                  BaseCalChange.Date, BaseCalChange.Day)
                then begin
                    Description := BaseCalChange.Description;
                    exit(not BaseCalChange.Nonworking);
                end;
            until BaseCalChange.Next = 0;

        exit(true);
    end;

    procedure DateMatch(TargetDate: Date; RecurringSystem: Option " ",Annual,Weekly; Date: Date; Day: Integer): Boolean
    begin
        case RecurringSystem of
            RecurringSystem::" ":
                exit(TargetDate = Date);

            RecurringSystem::Annual:
                exit((Date2DMY(TargetDate, 2) = Date2DMY(Date, 2)) and (Date2DMY(TargetDate, 1) = Date2DMY(Date, 1)));

            RecurringSystem::Weekly:
                exit(Date2DWY(TargetDate, 1) = Day);
        end;
    end;
}

