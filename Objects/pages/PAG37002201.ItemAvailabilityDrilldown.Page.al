page 37002201 "Item Availability Drilldown"
{
    // PR3.70.08
    // P8000178A, Myers Nissi, Jack Reynolds, 08 FEB 05
    //   Form to display sales board detail for derived data elements and provide further drilldown
    // 
    // PR4.00
    // P8000197A, Myers Nissi, Jack Reynolds, 21 SEP 05
    //   Modified for production planning changes
    // 
    // PRW15.00.02
    // P8000618A, VerticalSoft, Jack Reynolds, 11 AUG 08
    //   RENAMED - was Sales Board Drilldown
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 30 JAN 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status

    Caption = 'Item Availability Drilldown';
    DataCaptionExpression = CaptionText;
    Editable = false;
    PageType = List;
    SourceTable = "Item Availability";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field(Description; StrSubstNo('%1 %2', "Data Element", "Date Text"))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Description';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Quantity Available';

                    trigger OnDrillDown()
                    begin
                        QuantityDrillDown; // P8001083
                    end;
                }
                field("Quantity Not Available"; "Quantity Not Available")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        // P8001083
                        QuantityDrillDown;
                    end;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        SalesBoard.Copy(Rec);
        if not SalesBoard.Find(Which) then
            exit(false);
        Rec := SalesBoard;
        exit(true);
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        CurrentSteps: Integer;
    begin
        SalesBoard.Copy(Rec);
        CurrentSteps := SalesBoard.Next(Steps);
        if CurrentSteps <> 0 then
            Rec := SalesBoard;
        exit(CurrentSteps);
    end;

    var
        VariantFilter: Text[1024];
        LocationFilter: Text[1024];
        Date: Record Date;
        SalesBoard: Record "Item Availability" temporary;
        ProdPlanChange: Record "Daily Prod. Planning-Change" temporary;
        CaptionText: Text[50];
        LotStatusExclusionFilter: Text[1024];

    procedure SetParameters(VarFilter: Text[1024]; LocFilter: Text[1024]; ExclusionFilter: Text[1024]; var Dt: Record Date; var SlsBoard: Record "Item Availability" temporary)
    begin
        // P8001083 - add parameter for ExclusionFilter
        CaptionText := StrSubstNo('%1 %2', SlsBoard."Data Element", SlsBoard."Date Text");
        LotStatusExclusionFilter := ExclusionFilter; // P8001083
        if SlsBoard."Data Element" = SlsBoard."Data Element"::Available then begin
            FilterGroup(9);
            SetRange("Date Offset", SlsBoard."Date Offset" - 1);
            FilterGroup(0);
        end;
        VariantFilter := VarFilter;
        LocationFilter := LocFilter;
        Date.Copy(Dt);
        SlsBoard.Mark(true);
        SlsBoard.Find('-');
        repeat
            if not SlsBoard.Mark then begin
                SalesBoard := SlsBoard;
                SalesBoard.Insert;
            end;
        until SlsBoard.Next = 0;
    end;

    procedure DisplayColor(): Integer
    begin
        // P8000197A
        if "Includes Production Changes" then
            exit(255);
    end;

    procedure SetProdPlanChange(var PPchange: Record "Daily Prod. Planning-Change" temporary)
    begin
        // P8000197A
        ProdPlanChange.Reset;
        ProdPlanChange.DeleteAll;
        if PPchange.Find('-') then
            repeat
                ProdPlanChange := PPchange;
                ProdPlanChange.Insert;
            until PPchange.Next = 0;
    end;

    procedure QuantityDrillDown()
    var
        SalesBoardDrillDown: Record "Item Availability" temporary;
    begin
        // P8001083
        if "Data Element" = "Data Element"::Available then begin
            SalesBoard.Reset;
            SalesBoard.SetRange("Date Offset", -1, "Date Offset" - 1);
            if SalesBoard.Find('-') then
                repeat
                    SalesBoardDrillDown := SalesBoard;
                    SalesBoardDrillDown.Insert;
                until SalesBoard.Next = 0;
            SalesBoardDrillDown := Rec;
            SalesBoardDrillDown.SetProdPlanChange(ProdPlanChange); // P8000197A
            SalesBoardDrillDown.DrillDown(VariantFilter, LocationFilter, LotStatusExclusionFilter, Date); // P8001083
        end else begin                       // P8000197A
            SetProdPlanChange(ProdPlanChange); // P8000197A
            Rec.DrillDown(VariantFilter, LocationFilter, LotStatusExclusionFilter, Date); // P8001083
        end;                                 // P8000197A
    end;
}

