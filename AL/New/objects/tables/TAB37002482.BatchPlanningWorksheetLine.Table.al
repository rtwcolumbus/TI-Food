table 37002482 "Batch Planning Worksheet Line"
{
    // PRW16.00.04
    // P8000877, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Worksheet line table for batch planning
    // 
    // PRW16.00.05
    // P8000917, Columbus IT, Jack Reynolds, 18 MAR 11
    //   Fix field length problem with Intermediate Item No.
    // 
    // P8000918, Columbus IT, Jack Reynolds, 18 MAR 11
    //   Fix problem with missing key in NA database
    // 
    // P8000959, Columbus IT, Jack Reynolds, 21 JUN 11
    //   Support for Item Avalability data when planning batches
    // 
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // PRW17.10.02
    // P8001271, Columbus IT, Jack Reynolds, 24 JAN 14
    //   Fix missing TableRelation properties
    // 
    // PRW110.0
    // P8007750, To-Increase, Jack Reynolds, 07 NOV 16
    //   Convert Food Item Attributes to NAV Item Attributes
    // 
    // PRW110.0.02
    // P80046223, To-Increase, Jack Reynolds, 31 AUG 17
    //   Problem with Quantity Planned
    // 
    // P80046323, To-Increase, Dayakar Battini, 05 SEP 17
    //   Fix for suggested date
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW120-.2
    // P800150458, To-Increase, Jack Reynolds, 11 AUG 22
    //   Transfer Orders for Batch Plannng demand
    //   Minor cleanup to Batch Planning objcts

    Caption = 'Batch Planning Worksheet Line';

    fields
    {
        field(1; "Worksheet Name"; Code[10])
        {
            Caption = 'Worksheet Name';
            Editable = false;
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Editable = false;
        }
        field(3; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            Editable = false;
        }
        field(4; Type; Option)
        {
            Caption = 'Type';
            Editable = false;
            OptionCaption = 'Summary,Detail';
            OptionMembers = Summary,Detail;
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            Editable = false;
        }
        field(6; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            Editable = false;
        }
        field(7; "Begin Date"; Date)
        {
            Caption = 'Begin Date';
            Editable = false;
        }
        field(8; "End Date"; Date)
        {
            Caption = 'End Date';
            Editable = false;
        }
        field(21; "Parameter 1"; Text[250])
        {
            CaptionClass = StrSubstNo('37002011,1,%1', "Worksheet Name");
            Caption = 'Parameter 1';
            Editable = false;
        }
        field(22; "Parameter 2"; Text[250])
        {
            CaptionClass = StrSubstNo('37002011,2,%1', "Worksheet Name");
            Caption = 'Parameter 2';
            Editable = false;
        }
        field(23; "Parameter 3"; Text[250])
        {
            CaptionClass = StrSubstNo('37002011,3,%1', "Worksheet Name");
            Caption = 'Parameter 3';
            Editable = false;
        }
        field(25; "Package Highlight Parameter"; Text[250])
        {
            Caption = 'Package Highlight Parameter';
        }
        field(31; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(32; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            Editable = false;
        }
        field(33; "Quantity Required"; Decimal)
        {
            Caption = 'Quantity Required';
            DecimalPlaces = 0 : 5;
            Editable = false;

            trigger OnValidate()
            begin
                CalcRemainingQty;
            end;
        }
        field(34; "Date Required"; Date)
        {
            Caption = 'Date Required';
            Editable = false;
        }
        field(35; "Quantity Planned"; Decimal)
        {
            Caption = 'Quantity Planned';
            DecimalPlaces = 0 : 5;
            Editable = false;

            trigger OnValidate()
            begin
                CalcRemainingQty;
            end;
        }
        field(36; "Quantity Remaining"; Decimal)
        {
            Caption = 'Quantity Remaining';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(37; "Suggested Date"; Date)
        {
            Caption = 'Suggested Date';
            Editable = false;
        }
        field(41; "Intermediate Item No."; Code[20])
        {
            Caption = 'Intermediate Item No.';
            Editable = false;
        }
        field(42; "Intermediate Description"; Text[100])
        {
            Caption = 'Intermediate Description';
            Editable = false;
        }
        field(43; "Intermediate Unit of Measure"; Code[10])
        {
            Caption = 'Intermediate Unit of Measure';
            Editable = false;
        }
        field(44; "Intermediate Qty. Required"; Decimal)
        {
            Caption = 'Intermediate Qty. Required';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(45; "Intermediate Qty. Planned"; Decimal)
        {
            Caption = 'Intermediate Qty. Planned';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(46; "Intermediate Qty. Remaining"; Decimal)
        {
            Caption = 'Intermediate Qty. Remaining';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(47; "Intermediate Variant Code"; Code[10])
        {
            Caption = 'Intermediate Variant Code';
            Editable = false;
        }
        field(100; "Order Source"; Integer)
        {
            Caption = 'Order Source';
        }
        field(101; "Order Source Subtype"; Integer)
        {
            Caption = 'Order Source Subtype';
        }
        field(102; "Order Type"; Text[30])
        {
            Caption = 'Order Type';
            Editable = false;
        }
        field(103; "Order No."; Code[20])
        {
            Caption = 'Order No.';
            Editable = false;
        }
        field(104; "Order Line No."; Integer)
        {
            Caption = 'Order Line No.';
            Editable = false;
        }
        field(105; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteTag = 'FOOD-21';
            ObsoleteReason = 'Replaced by function OrderSourceName';
        }
        field(200; "Production BOM No."; Code[20])
        {
            Caption = 'Production BOM No.';
            Editable = false;
            TableRelation = "Production BOM Header";

            trigger OnValidate()
            begin
                "Version Code" := VersionMgmt.GetBOMVersion("Production BOM No.", "Begin Date", true);

                "Intermediate Quantity per" := 0;

                BOMLine.SetCurrentKey(Type, "No.");
                BOMLine.SetRange("Production BOM No.", "Production BOM No.");
                BOMLine.SetRange("Version Code", "Version Code");
                BOMLine.SetRange(Type, BOMLine.Type::Item);
                BOMLine.SetRange("No.", "Intermediate Item No.");
                BOMLine.SetRange("Variant Code", "Intermediate Variant Code"); // P8001030
                if BOMLine.FindSet then begin
                    repeat
                        if BOMLine."Scrap %" = 100 then
                            BOMLine.FieldError("Scrap %", Text003);
                        ItemUOM.Get(BOMLine."No.", BOMLine."Unit of Measure Code");
                        "Intermediate Quantity per" += BOMLine."Quantity per" * ItemUOM."Qty. per Unit of Measure" *
                            (1 + BOMLine."Scrap %" / 100);
                    until BOMLine.Next = 0;
                    ItemUOM.Get("Item No.", VersionMgmt.GetBOMUnitOfMeasure("Production BOM No.", "Version Code"));
                    "Base Qty. per Prod. UOM" := ItemUOM."Qty. per Unit of Measure";
                    "Intermediate Quantity per" := "Intermediate Quantity per" / "Base Qty. per Prod. UOM";
                end;
            end;
        }
        field(201; "Version Code"; Code[20])
        {
            Caption = 'Version Code';
            Editable = false;
            TableRelation = "Production BOM Version"."Version Code" WHERE("Production BOM No." = FIELD("Production BOM No."));
        }
        field(202; "Intermediate Quantity per"; Decimal)
        {
            Caption = 'Intermediate Quantity per';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(203; "Base Qty. per Prod. UOM"; Decimal)
        {
            Caption = 'Base Qty. per Prod. UOM';
        }
        field(301; Include; Boolean)
        {
            Caption = 'Include';

            trigger OnValidate()
            begin
                if Include then
                    "Quantity to Produce" := "Quantity Required"
                else
                    "Quantity to Produce" := 0;

                "Additional Quantity Possible" := 0;
                "Remaining Quantity to Pack" := 0;
            end;
        }
        field(302; "Quantity to Produce"; Decimal)
        {
            Caption = 'Quantity to Produce';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                CalcRemainingQtyToProduce;
            end;
        }
        field(303; "Additional Quantity Possible"; Decimal)
        {
            Caption = 'Additional Quantity Possible';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(304; "Rounding Precision"; Decimal)
        {
            Caption = 'Rounding Precision';
            DecimalPlaces = 0 : 5;
        }
        field(305; "Remaining Quantity to Pack"; Decimal)
        {
            Caption = 'Remaining Quantity to Pack';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(306; "Remaining Quantity to Produce"; Decimal)
        {
            Caption = 'Remaining Quantity to Produce';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(400; "Projected Availability"; Decimal)
        {
            Caption = 'Projected Availability';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Worksheet Name", "Item No.", "Variant Code", Type, "Line No.")
        {
        }
        key(Key2; "Worksheet Name", "Item No.", "Variant Code", Type, "Date Required")
        {
        }
    }

    fieldgroups
    {
    }

    var
        BOMLine: Record "Production BOM Line";
        ItemUOM: Record "Item Unit of Measure";
        VersionMgmt: Codeunit VersionManagement;
        Text001: Label '%1 Order';
        Text002: Label 'Sales %1';
        Text003: Label 'may not be 100';
        Text004: Label 'Transfer Order';

    procedure GetDemand(Item: Record Item; LeadTime: DateFormula; MfgPolicy: Integer; var BPWorksheetLine: Record "Batch Planning Worksheet Line" temporary)
    var
        ProdOrderLine: Record "Prod. Order Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TransferLine: Record "Transfer Line";
        EndDate: Date;
        LeadTimeDays: Integer;
    begin
        // P80001030 - add parameter for Manufacturing Policy
        BPWorksheetLine.Reset;
        BPWorksheetLine.DeleteAll;

        "Quantity Required" := 0;
        "Quantity Planned" := 0;
        "Quantity Remaining" := 0;
        "Date Required" := 0D;
        "Suggested Date" := 0D;

        BPWorksheetLine := Rec;
        BPWorksheetLine.Init;
        BPWorksheetLine.Type := BPWorksheetLine.Type::Detail;
        BPWorksheetLine."Location Code" := "Location Code";
        BPWorksheetLine.Description := Description;

        EndDate := CalcDate(LeadTime, "End Date");
        LeadTimeDays := EndDate - "End Date";

        ProdOrderLine.SetCurrentKey(Status, "Item No.", "Variant Code", "Location Code");
        ProdOrderLine.SetRange(Status, ProdOrderLine.Status::Planned);
        ProdOrderLine.SetRange("Item No.", "Item No.");
        ProdOrderLine.SetRange("Variant Code", "Variant Code");
        ProdOrderLine.SetRange("Location Code", "Location Code");
        ProdOrderLine.SetRange("Due Date", "Begin Date", EndDate);
        if ProdOrderLine.FindSet then
            repeat
                ProdOrderLine.CalcFields("Qty. in Batch (Base)");
                BPWorksheetLine."Line No." += 1;
                BPWorksheetLine."Order Source" := DATABASE::"Prod. Order Line";
                BPWorksheetLine."Order Source Subtype" := ProdOrderLine.Status;
                BPWorksheetLine."Order Type" := StrSubstNo(Text001, ProdOrderLine.Status);
                BPWorksheetLine."Order No." := ProdOrderLine."Prod. Order No.";
                BPWorksheetLine."Order Line No." := ProdOrderLine."Line No.";
                BPWorksheetLine.Validate("Quantity Required", ProdOrderLine."Quantity (Base)" + ProdOrderLine."Qty. in Batch (Base)");
                BPWorksheetLine.Validate("Quantity Planned", ProdOrderLine."Qty. in Batch (Base)");
                BPWorksheetLine."Date Required" := ProdOrderLine."Due Date";
                BPWorksheetLine.Insert;

                "Quantity Required" += BPWorksheetLine."Quantity Required";
                "Quantity Planned" += BPWorksheetLine."Quantity Planned"; // P80046223
                if BPWorksheetLine."Quantity Remaining" <> 0 then // P80046323
                    if ("Date Required" = 0D) or (BPWorksheetLine."Date Required" < "Date Required") then
                        "Date Required" := BPWorksheetLine."Date Required";
            until ProdOrderLine.Next = 0;

        if MfgPolicy = Item."Manufacturing Policy"::"Make-to-Order" then begin // P8001030
            SalesLine.SetCurrentKey("Document Type", Type, "No.", "Variant Code", "Drop Shipment"); // P8000918
            SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
            SalesLine.SetRange(Type, SalesLine.Type::Item);
            SalesLine.SetRange("No.", "Item No.");
            SalesLine.SetRange("Variant Code", "Variant Code");
            SalesLine.SetRange("Drop Shipment", false);
            SalesLine.SetRange("Location Code", "Location Code");
            SalesLine.SetRange("Shipment Date", "Begin Date", EndDate);
            if SalesLine.FindSet then
                repeat
                    SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
                    SalesLine.CalcFields("Qty. on Prod. Order (Base)");
                    BPWorksheetLine."Line No." += 1;
                    BPWorksheetLine."Order Source" := DATABASE::"Sales Line";
                    BPWorksheetLine."Order Source Subtype" := SalesLine."Document Type";
                    BPWorksheetLine."Order Type" := StrSubstNo(Text002, SalesLine."Document Type");
                    BPWorksheetLine."Order No." := SalesLine."Document No.";
                    BPWorksheetLine."Order Line No." := SalesLine."Line No.";
                    BPWorksheetLine.Validate("Quantity Required", SalesLine."Quantity (Base)");
                    BPWorksheetLine.Validate("Quantity Planned", SalesLine."Qty. on Prod. Order (Base)");
                    BPWorksheetLine."Date Required" := SalesLine."Shipment Date";
                    BPWorksheetLine.Insert;

                    "Quantity Required" += BPWorksheetLine."Quantity Required";
                    "Quantity Planned" += BPWorksheetLine."Quantity Planned"; // P80046223
                    if BPWorksheetLine."Quantity Remaining" <> 0 then // P80046323
                        if ("Date Required" = 0D) or (BPWorksheetLine."Date Required" < "Date Required") then
                            "Date Required" := BPWorksheetLine."Date Required";
                until SalesLine.Next = 0;

            // P800150458
            TransferLine.SetRange(Type, TransferLine.Type::Item);
            TransferLine.SetRange("Item No.", "Item No.");
            TransferLine.SetRange("Variant Code", "Variant Code");
            TransferLine.SetRange("Transfer-from Code", "Location Code");
            TransferLine.SetRange("Shipment Date", "Begin Date", EndDate);
            if TransferLine.FindSet then
                repeat
                    TransferLine.CalcFields("Qty. on Prod. Order (Base)");
                    BPWorksheetLine."Line No." += 1;
                    BPWorksheetLine."Order Source" := DATABASE::"Transfer Line";
                    BPWorksheetLine."Order Source Subtype" := 0;
                    BPWorksheetLine."Order Type" := Text004;
                    BPWorksheetLine."Order No." := TransferLine."Document No.";
                    BPWorksheetLine."Order Line No." := TransferLine."Line No.";                    // BPWorksheetLine."Customer Name" := SalesHeader."Sell-to Customer Name";
                    BPWorksheetLine.Validate("Quantity Required", TransferLine."Quantity (Base)");
                    BPWorksheetLine.Validate("Quantity Planned", TransferLine."Qty. on Prod. Order (Base)");
                    BPWorksheetLine."Date Required" := TransferLine."Shipment Date";
                    BPWorksheetLine.Insert;

                    "Quantity Required" += BPWorksheetLine."Quantity Required";
                    "Quantity Planned" += BPWorksheetLine."Quantity Planned"; // P80046223
                    if BPWorksheetLine."Quantity Remaining" <> 0 then // P80046323
                        if ("Date Required" = 0D) or (BPWorksheetLine."Date Required" < "Date Required") then
                            "Date Required" := BPWorksheetLine."Date Required";
                until TransferLine.Next = 0;
            // P800150458
        end;

        // P80046223
        BPWorksheetLine."Line No." += 1;
        BPWorksheetLine."Order Source" := 0;
        BPWorksheetLine."Order Source Subtype" := 0;
        BPWorksheetLine."Order Type" := '';
        BPWorksheetLine."Order No." := '';
        BPWorksheetLine."Order Line No." := 0;
        BPWorksheetLine."Quantity Required" := 0;
        BPWorksheetLine."Quantity Planned" := 0;
        BPWorksheetLine."Quantity Remaining" := 0;
        BPWorksheetLine."Date Required" := 0D;
        // P80046223
        ProdOrderLine.SetCurrentKey(Status, "Item No.", "Variant Code", "Location Code");
        ProdOrderLine.SetRange(Status, ProdOrderLine.Status::"Firm Planned", ProdOrderLine.Status::Released);
        ProdOrderLine.SetRange("Item No.", "Item No.");
        ProdOrderLine.SetRange("Variant Code", "Variant Code");
        ProdOrderLine.SetRange("Location Code", "Location Code");
        ProdOrderLine.SetRange("Starting Date", "Begin Date", EndDate);
        if ProdOrderLine.FindSet then begin
            // P80046223
            repeat
                ProdOrderLine."Quantity (Base)" -= ProdOrderLine.BatchQuantityBase;
                if ProdOrderLine."Quantity (Base)" <> 0 then
                    BPWorksheetLine."Quantity Planned" += ProdOrderLine."Quantity (Base)";
            until ProdOrderLine.Next = 0;
            if BPWorksheetLine."Quantity Planned" <> 0 then begin
                BPWorksheetLine."Quantity Remaining" := -BPWorksheetLine."Quantity Planned";
                BPWorksheetLine.Insert;

                "Quantity Planned" += BPWorksheetLine."Quantity Planned";
                //"Quantity Required" += BPWorksheetLine."Quantity Required";
            end;
        end;
        Validate("Quantity Planned");
        // P80046223

        if "Date Required" <> 0D then
            "Suggested Date" := "Date Required" - LeadTimeDays;

        CalcIntermediateQty;
    end;

    procedure CalcRemainingQty()
    begin
        if "Quantity Required" <= "Quantity Planned" then
            "Quantity Remaining" := 0
        else
            "Quantity Remaining" := "Quantity Required" - "Quantity Planned";
    end;

    procedure CalcRemainingQtyToProduce()
    begin
        if "Quantity Required" <= "Quantity to Produce" then
            "Remaining Quantity to Produce" := 0
        else
            "Remaining Quantity to Produce" := "Quantity Required" - "Quantity to Produce";
    end;

    procedure CalcIntermediateQty()
    begin
        "Intermediate Qty. Required" := Round("Intermediate Quantity per" * "Quantity Required", 0.00001);
        "Intermediate Qty. Planned" := Round("Intermediate Quantity per" * "Quantity Planned", 0.00001);
        "Intermediate Qty. Remaining" := Round("Intermediate Quantity per" * "Quantity Remaining", 0.00001);
    end;

    procedure UpdateQuantity()
    var
        WorksheetLineDetail: Record "Batch Planning Worksheet Line";
        SalesLine: Record "Sales Line";
        ProdOrderLine: Record "Prod. Order Line";
    begin
        "Quantity Required" := 0;
        "Quantity Planned" := 0;
        "Quantity Remaining" := 0;

        WorksheetLineDetail.SetRange("Worksheet Name", "Worksheet Name");
        WorksheetLineDetail.SetRange("Item No.", "Item No.");
        WorksheetLineDetail.SetRange("Variant Code", "Variant Code");
        WorksheetLineDetail.SetRange(Type, Type::Detail);
        if WorksheetLineDetail.FindSet(true, false) then
            repeat
                case WorksheetLineDetail."Order Source" of
                    DATABASE::"Sales Line":
                        begin
                            SalesLine.Get(WorksheetLineDetail."Order Source Subtype", WorksheetLineDetail."Order No.",
                                WorksheetLineDetail."Order Line No.");
                            SalesLine.CalcFields("Qty. on Prod. Order (Base)");
                            WorksheetLineDetail."Quantity Required" := SalesLine."Quantity (Base)";
                            WorksheetLineDetail."Quantity Planned" := SalesLine."Qty. on Prod. Order (Base)";
                        end;
                    DATABASE::"Prod. Order Line":
                        begin
                            ProdOrderLine.Get(WorksheetLineDetail."Order Source Subtype", WorksheetLineDetail."Order No.",
                                WorksheetLineDetail."Order Line No.");
                            ProdOrderLine.CalcFields("Qty. in Batch (Base)");
                            WorksheetLineDetail."Quantity Required" := ProdOrderLine."Quantity (Base)" + ProdOrderLine."Qty. in Batch (Base)";
                            WorksheetLineDetail."Quantity Planned" := ProdOrderLine."Qty. in Batch (Base)";
                            WorksheetLineDetail.CalcRemainingQty;
                        end;
                end;
                WorksheetLineDetail.CalcRemainingQty;
                WorksheetLineDetail.Modify;
                "Quantity Required" += WorksheetLineDetail."Quantity Required";
                "Quantity Planned" += WorksheetLineDetail."Quantity Planned";
            until WorksheetLineDetail.Next = 0;

        CalcRemainingQty;
        CalcIntermediateQty;
    end;

    // P800150458
    procedure OrderSourceName() : Text
    var
        SalesHeader: Record "Sales Header";
        TransferHeader: Record "Transfer Header";
        Location: Record Location;
    begin 
        case "Order Source" of 
            Database::"Sales Line" :
                begin
                    SalesHeader.Get("Order Source Subtype", "Order No.");
                    exit(SalesHeader."Sell-to Customer Name");
                end;
            Database::"Transfer Line" :
                begin
                    TransferHeader.Get("Order No."); 
                    Location.Get(TransferHeader."Transfer-to Code");
                    if Location.Name <> '' then
                        exit(Location.Name)
                    else
                        exit(Location.Code);  
                end;
        end;
    end;
}

