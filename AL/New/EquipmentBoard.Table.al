table 37002474 "Equipment Board"
{
    // PR4.00
    // P8000197A, Myers Nissi, Jack Reynolds, 21 SEP 05
    //   Used as a temporary table to hold data for equipment board
    // 
    // PRW16.00.05
    // P8000925, Columbus IT, Jack Reynolds, 29 MAR 11
    //   Use Prod Order Line instead of Prod Order for Drilldown
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Equipment Board';
    ReplicateData = false;

    fields
    {
        field(1; "Equipment Code"; Code[20])
        {
            Caption = 'Equipment Code';
            DataClassification = SystemMetadata;
        }
        field(4; "Date Offset"; Integer)
        {
            Caption = 'Date Offset';
            DataClassification = SystemMetadata;
        }
        field(5; "Data Element"; Option)
        {
            Caption = 'Data Element';
            DataClassification = SystemMetadata;
            OptionCaption = 'Capacity,Production,Available';
            OptionMembers = Capacity,Production,Available;
        }
        field(6; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
        }
        field(7; "Date Text"; Text[30])
        {
            Caption = 'Date Text';
            DataClassification = SystemMetadata;
        }
        field(8; "Includes Production Changes"; Boolean)
        {
            Caption = 'Includes Production Changes';
            DataClassification = SystemMetadata;
        }
        field(9; "Record No."; BigInteger)
        {
            Caption = 'Record No.';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Equipment Code", "Date Offset", "Data Element")
        {
            SumIndexFields = Quantity;
        }
        key(Key2; "Record No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        ProdPlanChange: Record "Daily Prod. Planning-Change" temporary;

    procedure DrillDown(var Date: Record Date)
    var
        Resource: Record Resource;
        EquipCapacity: Record "Production Time by Date" temporary;
        ProdDateTime: Record "Production Time by Date" temporary;
        ProdOrderLine: Record "Prod. Order Line";
        ProdDrillDown: Record "Eq. Board Production Drilldown" temporary;
        Date2: Record Date;
        DrillDown: Page "Equipment Board Drilldown";
        CapDrillDown: Page "Eq. Board Capacity Drilldown";
        ProductionDrillDown: Page "Eq. Board Production Drilldown";
        P800CalMgt: Codeunit "Process 800 Calendar Mngt.";
        BegDate: Date;
        EndDate: Date;
    begin
        Date.Find('-');
        Date.Next("Date Offset");
        BegDate := Date."Period Start";
        EndDate := NormalDate(Date."Period End");

        case "Data Element" of
            "Data Element"::Available:
                begin
                    DrillDown.SetParameters(Date, Rec);
                    DrillDown.SetProdPlanChange(ProdPlanChange);
                    DrillDown.RunModal;
                end;
            "Data Element"::Capacity:
                begin
                    if Resource.Get("Equipment Code") then;
                    P800CalMgt.GetProductionDateTime(Resource."Location Code", BegDate - 1, 0T, EndDate + 1, 0T, EquipCapacity);
                    EquipCapacity.Find('-');
                    EquipCapacity.Delete;
                    EquipCapacity.Find('+');
                    EquipCapacity.Delete;
                    Date2.SetRange("Period Type", Date2."Period Type"::Date);
                    Date2.SetRange("Period Start", BegDate, EndDate);
                    if Date2.Find('-') then
                        repeat
                            if not EquipCapacity.Get(Date2."Period Start") then begin
                                EquipCapacity.Date := Date2."Period Start";
                                EquipCapacity."Time Required" := 0;
                                EquipCapacity.Insert;
                            end;
                        until Date2.Next = 0;
                    CapDrillDown.SetVariables("Equipment Code", "Date Text", EquipCapacity);
                    CapDrillDown.RunModal;
                end;
            "Data Element"::Production:
                begin
                    // P8000925 - Following lines changed to use ProdOrderLine instead of ProdOrder
                    ProdOrderLine.SetCurrentKey("Equipment Code", "Starting Date");
                    ProdOrderLine.SetRange(Status, ProdOrderLine.Status::"Firm Planned", ProdOrderLine.Status::Released);
                    ProdOrderLine.SetRange("Equipment Code", "Equipment Code");
                    ProdOrderLine.SetRange("Starting Date", 0D, EndDate);
                    ProdOrderLine.SetRange("Ending Date", BegDate, DMY2Date(31, 12, 9999)); // P8007748
                    if ProdOrderLine.Find('-') then
                        repeat
                            P800CalMgt.GetProductionDateTime(ProdOrderLine."Location Code", ProdOrderLine."Starting Date",
                              ProdOrderLine."Starting Time", ProdOrderLine."Ending Date", ProdOrderLine."Ending Time", ProdDateTime);
                            ProdDateTime.SetRange(Date, BegDate, EndDate);
                            if ProdDateTime.Find('-') then begin
                                ProdDrillDown."Prod. Order Status" := ProdOrderLine.Status;
                                ProdDrillDown."Prod Order No." := ProdOrderLine."Prod. Order No.";
                                ProdDrillDown.Description := ProdOrderLine.Description;
                                ProdDrillDown.Location := ProdOrderLine."Location Code";
                                ProdDrillDown."Equipment Code" := ProdOrderLine."Equipment Code";
                                repeat
                                    ProdDrillDown.Date := ProdDateTime.Date;
                                    ProdDrillDown."Starting Time" := ProdDateTime."Starting Time";
                                    ProdDrillDown.Duration := ProdDateTime."Time Required";
                                    ProdDrillDown."Ending Time" := ProdDrillDown."Starting Time" + ProdDrillDown.Duration;
                                    ProdDrillDown.Insert;
                                until ProdDateTime.Next = 0;
                            end;
                        until ProdOrderLine.Next = 0;
                    ProdPlanChange.SetRange(Date, BegDate, EndDate);
                    if ProdPlanChange.Find('-') then
                        repeat
                            ProdDrillDown."Prod. Order Status" := ProdPlanChange.Status;
                            ProdDrillDown."Prod Order No." := ProdPlanChange."Production Order No.";
                            ProdDrillDown.Date := ProdPlanChange.Date;
                            ProdDrillDown.Change := true;
                            ProdDrillDown.Description := ProdPlanChange.Description;
                            ProdDrillDown.Location := ProdPlanChange."Location Code";
                            ProdDrillDown."Equipment Code" := ProdPlanChange."Equipment Code";
                            ProdDrillDown."Starting Time" := ProdPlanChange."Starting Time";
                            ProdDrillDown."Ending Time" := ProdPlanChange."Ending Time";
                            ProdDrillDown.Duration := ProdPlanChange.Duration;
                            ProdDrillDown.Insert;
                        until ProdPlanChange.Next = 0;

                    ProductionDrillDown.SetVariables("Equipment Code", "Date Text", ProdDrillDown);
                    ProductionDrillDown.RunModal;
                end;
        end;
    end;

    procedure SetProdPlanChange(var PPchange: Record "Daily Prod. Planning-Change" temporary)
    begin
        ProdPlanChange.Reset;
        ProdPlanChange.DeleteAll;
        if PPchange.Find('-') then
            repeat
                ProdPlanChange := PPchange;
                ProdPlanChange.Insert;
            until PPchange.Next = 0;
    end;
}

