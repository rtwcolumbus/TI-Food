table 37002461 "Quick Planner Worksheet"
{
    // PR1.20.01
    //   Remove field - Production Forecast Name
    // 
    // PR2.00.05
    //   Variant Code
    //   Add variant code to CalcFormula for flow fields
    //   Expand primary key to include variant code
    // 
    // PR4.00.06
    // P8000492A, VerticalSoft, Jack Reynolds, 03 JUL 07
    //   Add new fields to support supply/demand calculation for transfer orders
    // 
    // PRW16.00.04
    // P8000869, VerticalSoft, Jack Reynolds, 28 SEP 10
    //   support for NAV Forecast
    // 
    // P8000875, VerticalSoft, Jack Reynolds, 14 OCT 10
    //   Enhancements for Suggested Date
    // 
    // PRW16.00.05
    // P8000937, Columbus IT, Jack Reynolds, 26 APR 11
    //   Fix problem calculating Qty. on Forecast
    // 
    // PRW16.00.06
    // P8000996, Columbus IT, Jack Reynolds, 15 NOV 11
    //   Fix problem with multiple locations
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // PRW17.00.01
    // P8001154, Columbus IT, Jack Reynolds, 28 MAY 13
    //   Enlarge User ID field
    // 
    // PRW17.10.01
    // P8001258, Columbus IT, Jack Reynolds, 10 JAN 14
    //   Increase size ot text fields/variables
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Quick Planner Worksheet';

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            Editable = false;
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Editable = false;
            TableRelation = Item;
        }
        field(3; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
            Editable = false;
        }
        field(4; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            Editable = false;
        }
        field(5; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            Description = 'PR2.00.05';
            Editable = false;
        }
        field(100; "On Hand"; Decimal)
        {
            CalcFormula = Sum ("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("Item No."),
                                                                  "Variant Code" = FIELD("Variant Code"),
                                                                  "Location Code" = FIELD("Location Filter")));
            Caption = 'On Hand';
            DecimalPlaces = 0 : 5;
            Description = 'PR2.00.05';
            Editable = false;
            FieldClass = FlowField;
        }
        field(198; "Qty. on Forecast"; Decimal)
        {
            Caption = 'Qty. on Forecast';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(199; "Qty. on Forecast (NAV)"; Decimal)
        {
            CalcFormula = Sum ("Production Forecast Entry"."Forecast Quantity (Base)" WHERE("Item No." = FIELD("Item No."),
                                                                                            "Production Forecast Name" = FIELD("Production Forecast Name"),
                                                                                            "Variant Code" = FIELD("Variant Code"),
                                                                                            "Location Code" = FIELD("Location Filter"),
                                                                                            "Forecast Date" = FIELD("Date Filter")));
            Caption = 'Qty. on Forecast (NAV)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(200; "Qty. on Forecast (VPS)"; Decimal)
        {
            CalcFormula = Sum ("Production Forecast".Quantity WHERE("Item No." = FIELD("Item No."),
                                                                    "Variant Code" = FIELD("Variant Code"),
                                                                    Date = FIELD("Date Filter"),
                                                                    "Location Code" = FIELD("Location Filter")));
            Caption = 'Qty. on Forecast (VPS)';
            DecimalPlaces = 0 : 5;
            Description = 'PR2.00.05';
            Editable = false;
            FieldClass = FlowField;
        }
        field(201; "Qty. on Sales Order"; Decimal)
        {
            CalcFormula = Sum ("Sales Line"."Outstanding Qty. (Base)" WHERE("Document Type" = CONST(Order),
                                                                            Type = CONST(Item),
                                                                            "No." = FIELD("Item No."),
                                                                            "Variant Code" = FIELD("Variant Code"),
                                                                            "Shipment Date" = FIELD(UPPERLIMIT("Date Filter")),
                                                                            "Location Code" = FIELD("Location Filter")));
            Caption = 'Qty. on Sales Order';
            DecimalPlaces = 0 : 5;
            Description = 'PR2.00.05';
            Editable = false;
            FieldClass = FlowField;
        }
        field(202; "Qty. Required For Production"; Decimal)
        {
            CalcFormula = Sum ("Prod. Order Component"."Remaining Qty. (Base)" WHERE(Status = FILTER(Planned .. Released),
                                                                                     "Item No." = FIELD("Item No."),
                                                                                     "Variant Code" = FIELD("Variant Code"),
                                                                                     "Due Date" = FIELD(UPPERLIMIT("Date Filter")),
                                                                                     "Location Code" = FIELD("Location Filter"),
                                                                                     "Production Grouping Item" = CONST(false)));
            Caption = 'Qty. Required For Production';
            DecimalPlaces = 0 : 5;
            Description = 'PR2.00,PR2.00.05';
            Editable = false;
            FieldClass = FlowField;
        }
        field(203; "Qty. on Transfer (Outbound)"; Decimal)
        {
            CalcFormula = Sum ("Transfer Line"."Outstanding Qty. (Base)" WHERE("Derived From Line No." = CONST(0),
                                                                               "Item No." = FIELD("Item No."),
                                                                               "Variant Code" = FIELD("Variant Code"),
                                                                               "Shipment Date" = FIELD(UPPERLIMIT("Date Filter")),
                                                                               "Transfer-from Code" = FIELD("Location Filter")));
            Caption = 'Qty. on Transfer (Outbound)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(299; Demand; Decimal)
        {
            Caption = 'Demand';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(300; "Qty. on Purchase Order"; Decimal)
        {
            CalcFormula = Sum ("Purchase Line"."Outstanding Qty. (Base)" WHERE("Document Type" = CONST(Order),
                                                                               Type = CONST(Item),
                                                                               "No." = FIELD("Item No."),
                                                                               "Variant Code" = FIELD("Variant Code"),
                                                                               "Expected Receipt Date" = FIELD(UPPERLIMIT("Date Filter")),
                                                                               "Location Code" = FIELD("Location Filter")));
            Caption = 'Qty. on Purchase Order';
            DecimalPlaces = 0 : 5;
            Description = 'PR2.00.05';
            Editable = false;
            FieldClass = FlowField;
        }
        field(301; "Qty. on Production Order"; Decimal)
        {
            CalcFormula = Sum ("Prod. Order Line"."Remaining Qty. (Base)" WHERE(Status = FILTER(Planned .. Released),
                                                                                "Item No." = FIELD("Item No."),
                                                                                "Variant Code" = FIELD("Variant Code"),
                                                                                "Due Date" = FIELD(UPPERLIMIT("Date Filter")),
                                                                                "Location Code" = FIELD("Location Filter")));
            Caption = 'Qty. on Production Order';
            DecimalPlaces = 0 : 5;
            Description = 'PR2.00.05';
            Editable = false;
            FieldClass = FlowField;
        }
        field(302; "Qty. on Transfer (Outstanding)"; Decimal)
        {
            CalcFormula = Sum ("Transfer Line"."Outstanding Qty. (Base)" WHERE("Derived From Line No." = CONST(0),
                                                                               "Item No." = FIELD("Item No."),
                                                                               "Variant Code" = FIELD("Variant Code"),
                                                                               "Receipt Date" = FIELD(UPPERLIMIT("Date Filter")),
                                                                               "Transfer-to Code" = FIELD("Location Filter")));
            Caption = 'Qty. on Transfer (Outstanding)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(303; "Qty. on Transfer (In-Transit)"; Decimal)
        {
            CalcFormula = Sum ("Transfer Line"."Qty. in Transit (Base)" WHERE("Derived From Line No." = CONST(0),
                                                                              "Item No." = FIELD("Item No."),
                                                                              "Variant Code" = FIELD("Variant Code"),
                                                                              "Receipt Date" = FIELD(UPPERLIMIT("Date Filter")),
                                                                              "Transfer-to Code" = FIELD("Location Filter")));
            Caption = 'Qty. on Transfer (In-Transit)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(304; "Qty. on Transfer (Inbound)"; Decimal)
        {
            Caption = 'Qty. on Transfer (Inbound)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(399; Orders; Decimal)
        {
            Caption = 'Orders';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(400; "Sales Order in Forecast"; Boolean)
        {
            Caption = 'Sales Order in Forecast';
        }
        field(401; "Qty. Available"; Decimal)
        {
            Caption = 'Qty. Available';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(402; "Safety Stock"; Decimal)
        {
            Caption = 'Safety Stock';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(404; "Suggested Quantity"; Decimal)
        {
            Caption = 'Suggested Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(405; "Actual Quantity"; Decimal)
        {
            Caption = 'Actual Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(406; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(407; "Required Date"; Date)
        {
            Caption = 'Required Date';
            Editable = false;
        }
        field(500; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(501; "Location Filter"; Code[10])
        {
            Caption = 'Location Filter';
            FieldClass = FlowFilter;
            TableRelation = Location;
        }
        field(502; "Production Forecast Name"; Code[10])
        {
            Caption = 'Production Forecast Name';
            FieldClass = FlowFilter;
            TableRelation = "Production Forecast Name";
        }
    }

    keys
    {
        key(Key1; "User ID", "Item No.", "Variant Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Item: Record Item;
        LotStatus: Record "Lot Status Code";
        LotStatusMgmt: Codeunit "Lot Status Management";
        ExcludePurch: Boolean;
        ExcludeSalesRet: Boolean;
        ExcludeOutput: Boolean;

    procedure Calculate(UseNAVForecast: Boolean; EarliestForecastDate: Date; LotStatusExclusionfilter: Text[1024])
    var
        Location: Record Location;
        SKU: Record "Stockkeeping Unit";
        WorkSheet2: Record "Quick Planner Worksheet";
        CurrentDate: Date;
        EndDate: Date;
        TotalOrdersWithinForecast: Decimal;
        ForecastOrOrders: array[2] of Decimal;
        SalesOrdersBeforeForecast: Decimal;
        SKUNotFound: Boolean;
    begin
        // P8000875
        // P8000996
        // P8001083 - add parameter for LotStatusExclusionFilter
        //GetPlanningParameters.AtSKU(SKU,"Item No.","Variant Code",GETFILTER("Location Filter"));
        //"Safety Stock" := SKU."Safety Stock Quantity";
        SetItem; // P8001083
        if GetFilter("Location Filter") = '' then begin
            //Item.GET("Item No."); // P8001083
            "Safety Stock" := Item."Safety Stock Quantity";
        end else begin
            "Safety Stock" := 0;
            CopyFilter("Location Filter", Location.Code);
            if Location.FindSet then
                repeat
                    if SKU.Get(Location.Code, "Item No.", "Variant Code") then
                        "Safety Stock" += SKU."Safety Stock Quantity"
                    else
                        SKUNotFound := true;
                until (Location.Next = 0) or SKUNotFound;
            if SKUNotFound then begin
                //Item.GET("Item No."); // P8001083
                "Safety Stock" := Item."Safety Stock Quantity";
            end;
        end;
        // P8000996

        "Qty. on Forecast" := 0;
        "Required Date" := 0D;

        CalcFields("On Hand");
        LotStatusMgmt.AdjustQuickPlannerFlowFields(Rec, LotStatusExclusionfilter, true, false, false, false, false); // P8001083
        WorkSheet2.Copy(Rec);
        CurrentDate := GetRangeMin("Date Filter");
        EndDate := GetRangeMax("Date Filter");
        WorkSheet2.SetRange("Date Filter", 0D, CurrentDate - 1); // Past due supply and demand
        CalcPeriod(WorkSheet2, UseNAVForecast, EarliestForecastDate, SalesOrdersBeforeForecast, LotStatusExclusionfilter); // P8001083
        while (0 <= "Qty. Available") and (CurrentDate <= EndDate) do begin
            WorkSheet2.SetRange("Date Filter", CurrentDate);
            CalcPeriod(WorkSheet2, UseNAVForecast, EarliestForecastDate, SalesOrdersBeforeForecast, LotStatusExclusionfilter); // P8001083
            CurrentDate := CurrentDate + 1;
        end;

        if "Qty. Available" < 0 then
            "Required Date" := CurrentDate - 1;

        if CurrentDate <= EndDate then begin
            if CurrentDate < EarliestForecastDate then begin
                if EndDate < EarliestForecastDate then
                    WorkSheet2.SetRange("Date Filter", CurrentDate, EndDate)
                else
                    WorkSheet2.SetRange("Date Filter", CurrentDate, EarliestForecastDate - 1);
                CalcPeriod(WorkSheet2, UseNAVForecast, EarliestForecastDate, SalesOrdersBeforeForecast, LotStatusExclusionfilter); // P8001083
                CurrentDate := EarliestForecastDate;
            end;
            if CurrentDate <= EndDate then begin
                WorkSheet2.SetRange("Date Filter", CurrentDate, EndDate);
                CalcPeriod(WorkSheet2, UseNAVForecast, EarliestForecastDate, SalesOrdersBeforeForecast, LotStatusExclusionfilter); // P8001083
            end;
        end;

        if "Qty. Available" < 0 then
            "Suggested Quantity" := -"Qty. Available"
        else
            "Suggested Quantity" := 0;
        "Qty. Available" += "Safety Stock";

        "Actual Quantity" := 0;
        "Due Date" := 0D;
    end;

    local procedure CalcPeriod(var WorkSheet2: Record "Quick Planner Worksheet"; UseNAVForecast: Boolean; EarliestForecastDate: Date; var SalesOrdersBeforeForecast: Decimal; LotStatusExclusionfilter: Text[1024])
    var
        SalesOrdersInForecast: Decimal;
        ForecastOrOrders: Decimal;
    begin
        // P8001083 - add parameter for LotStatusExclusionFilter
        WorkSheet2.CalcFields("Qty. on Sales Order",
          "Qty. on Transfer (Outbound)", "Qty. on Transfer (Outstanding)", "Qty. on Transfer (In-Transit)",
          "Qty. Required For Production", "Qty. on Purchase Order", "Qty. on Production Order");
        LotStatusMgmt.AdjustQuickPlannerFlowFields(WorkSheet2, LotStatusExclusionfilter, false, true, // P8001083
          ExcludePurch, ExcludeSalesRet, ExcludeOutput);                                             // P8001083
        "Qty. on Transfer (Inbound)" := WorkSheet2."Qty. on Transfer (Outstanding)" + WorkSheet2."Qty. on Transfer (In-Transit)";
        if WorkSheet2.GetRangeMax("Date Filter") >= EarliestForecastDate then begin
            if UseNAVForecast then begin
                WorkSheet2.CalcFields("Qty. on Forecast (NAV)");
                "Qty. on Forecast" += WorkSheet2."Qty. on Forecast (NAV)";
            end else begin
                WorkSheet2.CalcFields("Qty. on Forecast (VPS)");
                "Qty. on Forecast" += WorkSheet2."Qty. on Forecast (VPS)"; // P8000937
            end;
            SalesOrdersInForecast := WorkSheet2."Qty. on Sales Order" - SalesOrdersBeforeForecast;
            if SalesOrdersInForecast < "Qty. on Forecast" then
                ForecastOrOrders := "Qty. on Forecast"
            else
                ForecastOrOrders := SalesOrdersInForecast;
        end else
            SalesOrdersBeforeForecast := WorkSheet2."Qty. on Sales Order";

        Demand := SalesOrdersBeforeForecast + ForecastOrOrders +
          WorkSheet2."Qty. Required For Production" + WorkSheet2."Qty. on Transfer (Outbound)";
        Orders := WorkSheet2."Qty. on Purchase Order" + WorkSheet2."Qty. on Production Order" + "Qty. on Transfer (Inbound)";
        "Qty. Available" := "On Hand" - "Safety Stock" - Demand + Orders;
    end;

    procedure SetItem()
    begin
        // P8001083
        if Item."No." <> "Item No." then begin
            Item.Get("Item No.");
            LotStatusMgmt.SetInboundExclusions(Item, LotStatus.FieldNo("Available for Planning"),
              ExcludePurch, ExcludeSalesRet, ExcludeOutput);
        end;
    end;

    procedure OnHandDrillDown(LotStatusExclusionFilter: Text[1024])
    var
        ItemLedger: Record "Item Ledger Entry";
        ItemLedgerEntries: Page "Item Ledger Entries";
    begin
        // P8001083
        ItemLedger.SetCurrentKey("Item No.", "Variant Code", "Location Code");
        ItemLedger.SetRange("Drop Shipment", false);
        ItemLedger.SetRange("Item No.", "Item No.");
        ItemLedger.SetFilter("Variant Code", "Variant Code");
        ItemLedger.SetFilter("Location Code", GetFilter("Location Filter"));
        ItemLedgerEntries.SetTableView(ItemLedger);
        ItemLedgerEntries.SetLotStatus(LotStatusExclusionFilter);
        ItemLedgerEntries.RunModal;
    end;

    procedure TransInDrilldown(DaysView: Integer; LotStatusExclusionFilter: Text[1024])
    var
        TransferLine: Record "Transfer Line";
        TransferLines: Page "Transfer Lines";
    begin
        // P8001083
        TransferLine.SetCurrentKey("Transfer-to Code", Status, "Derived From Line No.", "Item No.", "Variant Code",
          "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Receipt Date", "In-Transit Code");
        TransferLine.SetFilter("Transfer-to Code", GetFilter("Location Filter"));
        TransferLine.SetRange("Derived From Line No.", 0);
        TransferLine.SetRange("Item No.", "Item No.");
        TransferLine.SetRange("Variant Code", "Variant Code");
        TransferLine.SetRange("Receipt Date", 0D, WorkDate + DaysView);
        TransferLines.SetTableView(TransferLine);
        TransferLines.SetLotStatus(LotStatusExclusionFilter);
        TransferLines.RunModal;
    end;
}

