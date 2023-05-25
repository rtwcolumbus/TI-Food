table 37002762 "Whse. Staged Pick Source Line"
{
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 15 SEP 06
    //   Staged Picks
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW119.0
    // P800133109, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 19.0 - Qty. Rounding Precision

    Caption = 'Whse. Staged Pick Source Line';
    DrillDownPageID = "Whse. Staged Pick Source Lines";
    LookupPageID = "Whse. Staged Pick Source Lines";
    PasteIsValid = false;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            Editable = false;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            Editable = false;
        }
        field(4; "Source Type"; Integer)
        {
            Caption = 'Source Type';
            Editable = false;
        }
        field(5; "Source Subtype"; Option)
        {
            Caption = 'Source Subtype';
            Editable = false;
            OptionCaption = '0,1,2,3,4,5,6,7,8,9,10';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9","10";
        }
        field(6; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            Editable = false;
            TableRelation = IF ("Source Document" = CONST("Sales Order")) "Sales Header"."No." WHERE("Document Type" = CONST(Order),
                                                                                                    "No." = FIELD("Source No."))
            ELSE
            IF ("Source Document" = CONST("Purchase Return Order")) "Purchase Header"."No." WHERE("Document Type" = CONST("Return Order"),
                                                                                                                                                                                              "No." = FIELD("Source No."))
            ELSE
            IF ("Source Document" = CONST("Outbound Transfer")) "Transfer Header"."No." WHERE("No." = FIELD("Source No."))
            ELSE
            IF ("Source Document" = CONST("Prod. Consumption")) "Production Order"."No." WHERE(Status = CONST(Released),
                                                                                                                                                                                                                                                                                     "No." = FIELD("Source No."));
        }
        field(7; "Source Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Source Line No.';
            Editable = false;
            TableRelation = IF ("Source Document" = CONST("Sales Order")) "Sales Line"."Line No." WHERE("Document Type" = CONST(Order),
                                                                                                       "Document No." = FIELD("Source No."),
                                                                                                       "Line No." = FIELD("Source Line No."))
            ELSE
            IF ("Source Document" = CONST("Purchase Return Order")) "Purchase Line"."Line No." WHERE("Document Type" = CONST("Return Order"),
                                                                                                                                                                                                    "Document No." = FIELD("Source No."),
                                                                                                                                                                                                    "Line No." = FIELD("Source Line No."))
            ELSE
            IF ("Source Document" = CONST("Outbound Transfer")) "Transfer Line"."Line No." WHERE("Document No." = FIELD("Source No."),
                                                                                                                                                                                                                                                                                             "Line No." = FIELD("Source Line No."))
            ELSE
            IF ("Source Document" = CONST("Prod. Consumption")) "Prod. Order Line"."Line No." WHERE(Status = CONST(Released),
                                                                                                                                                                                                                                                                                                                                                                                         "Prod. Order No." = FIELD("Source No."),
                                                                                                                                                                                                                                                                                                                                                                                         "Line No." = FIELD("Source Line No."));
        }
        field(8; "Source Subline No."; Integer)
        {
            BlankZero = true;
            Caption = 'Source Subline No.';
            Editable = false;
            TableRelation = IF ("Source Document" = CONST("Prod. Consumption")) "Prod. Order Component"."Line No." WHERE(Status = CONST(Released),
                                                                                                                        "Prod. Order No." = FIELD("Source No."),
                                                                                                                        "Prod. Order Line No." = FIELD("Source Line No."),
                                                                                                                        "Line No." = FIELD("Source Subline No."));
        }
        field(9; "Source Document"; Option)
        {
            BlankZero = true;
            Caption = 'Source Document';
            Editable = false;
            OptionCaption = ',Sales Order,,,,,,,Purchase Return Order,,Outbound Transfer,Prod. Consumption';
            OptionMembers = ,"Sales Order",,,,,,,"Purchase Return Order",,"Outbound Transfer","Prod. Consumption";
        }
        field(10; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            Editable = false;
            TableRelation = Location;
        }
        field(12; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            Editable = false;
            TableRelation = IF ("Zone Code" = FILTER('')) Bin.Code WHERE("Location Code" = FIELD("Location Code"))
            ELSE
            IF ("Zone Code" = FILTER(<> '')) Bin.Code WHERE("Location Code" = FIELD("Location Code"),
                                                                               "Zone Code" = FIELD("Zone Code"));
        }
        field(13; "Zone Code"; Code[10])
        {
            Caption = 'Zone Code';
            Editable = false;
            TableRelation = Zone.Code WHERE("Location Code" = FIELD("Location Code"));
        }
        field(14; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(15; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            var
                DocStatus: Option;
                MaxStageQty: Decimal;
            begin
                Quantity := UOMMgt.RoundAndValidateQty(Quantity, "Qty. Rounding Precision", FieldCaption(Quantity)); // P800133109
                TestField(Quantity);

                MaxStageQty := GetSourceAvailPickQty() + "Qty. Picked";
                if (Quantity > MaxStageQty) then
                    FieldError(Quantity, StrSubstNo(Text001, MaxStageQty));

                CalcFields("Pick Qty.");
                if (Quantity < ("Pick Qty." + "Qty. Picked")) then
                    FieldError(Quantity, StrSubstNo(Text002, "Pick Qty." + "Qty. Picked"));

                Validate("Qty. Outstanding", Quantity - "Qty. Picked");
                "Qty. (Base)" := CalcBaseQty(Quantity, FieldCaption(Quantity), FieldCaption("Qty. (Base)")); // P800133109
            end;
        }
        field(16; "Qty. (Base)"; Decimal)
        {
            Caption = 'Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(19; "Qty. Outstanding"; Decimal)
        {
            Caption = 'Qty. Outstanding';
            DecimalPlaces = 0 : 5;
            Editable = false;

            trigger OnValidate()
            var
                WMSMgt: Codeunit "WMS Management";
            begin
                "Qty. Outstanding (Base)" := CalcBaseQty("Qty. Outstanding", FieldCaption("Qty. Outstanding"), FieldCaption("Qty. Outstanding (Base)")); // P800133109
            end;
        }
        field(20; "Qty. Outstanding (Base)"; Decimal)
        {
            Caption = 'Qty. Outstanding (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(23; "Qty. Picked"; Decimal)
        {
            Caption = 'Qty. Picked';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = Normal;

            trigger OnValidate()
            begin
                "Qty. Picked (Base)" := CalcBaseQty("Qty. Picked", FieldCaption("Qty. Picked"), FieldCaption("Qty. Picked (Base)")); // P800133109
            end;
        }
        field(24; "Qty. Picked (Base)"; Decimal)
        {
            Caption = 'Qty. Picked (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(27; "Pick Qty."; Decimal)
        {
            CalcFormula = Sum ("Warehouse Activity Line"."Qty. Outstanding" WHERE("From Staged Pick No." = FIELD("No."),
                                                                                  "From Staged Pick Line No." = FIELD("Line No."),
                                                                                  "Source Type" = FIELD("Source Type"),
                                                                                  "Source Subtype" = FIELD("Source Subtype"),
                                                                                  "Source No." = FIELD("Source No."),
                                                                                  "Source Line No." = FIELD("Source Line No."),
                                                                                  "Source Subline No." = FIELD("Source Subline No."),
                                                                                  "Action Type" = FILTER(" " | Place),
                                                                                  "Unit of Measure Code" = FIELD("Unit of Measure Code"),
                                                                                  "Original Breakbulk" = CONST(false),
                                                                                  "Breakbulk No." = CONST(0)));
            Caption = 'Pick Qty.';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(28; "Pick Qty. (Base)"; Decimal)
        {
            CalcFormula = Sum ("Warehouse Activity Line"."Qty. Outstanding (Base)" WHERE("From Staged Pick No." = FIELD("No."),
                                                                                         "From Staged Pick Line No." = FIELD("Line No."),
                                                                                         "Source Type" = FIELD("Source Type"),
                                                                                         "Source Subtype" = FIELD("Source Subtype"),
                                                                                         "Source No." = FIELD("Source No."),
                                                                                         "Source Line No." = FIELD("Source Line No."),
                                                                                         "Source Subline No." = FIELD("Source Subline No."),
                                                                                         "Action Type" = FILTER(" " | Place),
                                                                                         "Original Breakbulk" = CONST(false),
                                                                                         "Breakbulk No." = CONST(0)));
            Caption = 'Pick Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(29; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            NotBlank = true;
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(30; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
        }
        field(31; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            var
                ItemVariant: Record "Item Variant";
            begin
            end;
        }
        field(32; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(33; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
        }
        field(34; Status; Option)
        {
            Caption = 'Status';
            Editable = false;
            OptionCaption = ' ,Partially Picked,Completely Picked';
            OptionMembers = " ","Partially Picked","Completely Picked";
        }
        // P800133109
        field(39; "Qty. Rounding Precision"; Decimal)
        {
            Caption = 'Qty. Rounding Precision';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        // P800133109
        field(40; "Qty. Rounding Precision (Base)"; Decimal)
        {
            Caption = 'Qty. Rounding Precision (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "No.", "Line No.", "Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.")
        {
            SumIndexFields = "Qty. (Base)", "Qty. Outstanding (Base)", "Qty. Picked (Base)";
        }
        key(Key2; "Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code")
        {
            SumIndexFields = "Qty. Outstanding (Base)";
        }
        key(Key3; "Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.")
        {
            SumIndexFields = "Qty. Outstanding";
        }
        key(Key4; "No.", "Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        UpdateDocStatus(true);
        UpdateItemPickLine(true);
    end;

    trigger OnInsert()
    begin
        UpdateDocStatus(false);
        UpdateItemPickLine(false);
    end;

    trigger OnModify()
    begin
        UpdateDocStatus(false);
        UpdateItemPickLine(false);
    end;

    trigger OnRename()
    begin
        Error(Text000, TableCaption);
    end;

    var
        WhseStagedPickHeader: Record "Whse. Staged Pick Header";
        UOMMgt: Codeunit "Unit of Measure Management";
        HideValidationDialog: Boolean;
        Text000: Label 'You cannot rename a %1.';
        Text001: Label 'must not be more than %1 units';
        Text002: Label 'must not be less than %1 units';
        Text003: Label 'Nothing to handle.';

    local procedure CalcBaseQty(Qty: Decimal; FromFieldName: Text; ToFieldName: Text): Decimal
    begin
        // P800133109
        exit(UOMMgt.CalcBaseQty(
            "No.", "Variant Code", "Unit of Measure Code", Qty, "Qty. per Unit of Measure", "Qty. Rounding Precision (Base)", FieldCaption("Qty. Rounding Precision"), FromFieldName, ToFieldName));
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    procedure CreatePickDoc(var WhseStagedSourcePickLine: Record "Whse. Staged Pick Source Line"; WhseStagedPickHeader2: Record "Whse. Staged Pick Header")
    var
        CreatePickFromStgdSources: Report "Staged Pick - Pick Orders";
    begin
        WhseStagedPickHeader2.CheckPickRequired(WhseStagedPickHeader2."Location Code");
        WhseStagedPickHeader2.TestField(Status, WhseStagedPickHeader2.Status::Released);
        WhseStagedSourcePickLine.SetFilter("Qty. Outstanding", '>0');
        if WhseStagedSourcePickLine.Find('-') then begin
            CreatePickFromStgdSources.SetWhseStgdPickSourceLine(
              WhseStagedSourcePickLine, WhseStagedPickHeader2);
            CreatePickFromStgdSources.SetHideValidationDialog(HideValidationDialog);
            CreatePickFromStgdSources.UseRequestPage(not HideValidationDialog);
            CreatePickFromStgdSources.RunModal;
            CreatePickFromStgdSources.GetResultMessage;
            Clear(CreatePickFromStgdSources);
        end else
            if not HideValidationDialog then
                Message(Text003);
    end;

    procedure UpdateDocStatus(Deleting: Boolean)
    var
        DocStatus: Option;
    begin
        WhseStagedPickHeader.Get("No.");
        if Deleting then
            DocStatus := WhseStagedPickHeader.GetOrderPickingStatus("Line No.")
        else begin
            Status := CalcStatusPickSourceLine;
            DocStatus := WhseStagedPickHeader.GetLineOrderPickingStatus(Rec);
        end;
        if DocStatus <> WhseStagedPickHeader."Order Picking Status" then begin
            WhseStagedPickHeader.Validate("Order Picking Status", DocStatus);
            WhseStagedPickHeader.Modify(true);
        end;
    end;

    local procedure CalcStatusPickSourceLine(): Integer
    begin
        if (Quantity = "Qty. Picked") then
            exit(Status::"Completely Picked");
        if "Qty. Picked" > 0 then
            exit(Status::"Partially Picked");
        exit(Status::" ");
    end;

    local procedure UpdateItemPickLine(Deleting: Boolean)
    var
        SourceQtyBaseChg: Decimal;
        WhseStagedPickLine: Record "Whse. Staged Pick Line";
        OldWhseStagedPickSourceLine: Record "Whse. Staged Pick Source Line";
    begin
        if not Deleting then
            SourceQtyBaseChg := "Qty. Outstanding (Base)";
        OldWhseStagedPickSourceLine := Rec;
        if OldWhseStagedPickSourceLine.Find then
            SourceQtyBaseChg := SourceQtyBaseChg - OldWhseStagedPickSourceLine."Qty. Outstanding (Base)";
        WhseStagedPickLine.Get("No.", "Line No.");
        WhseStagedPickLine.RecalcQtyToStage(SourceQtyBaseChg);
        WhseStagedPickLine.Modify(true);
    end;

    procedure ShowSourceDocument()
    var
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        TransHeader: Record "Transfer Header";
        ProdHeader: Record "Production Order";
        SalesOrder: Page "Sales Order";
        PurchRetOrder: Page "Purchase Return Order";
        TransOrder: Page "Transfer Order";
        ProdOrder: Page "Released Production Order";
    begin
        case "Source Document" of
            "Source Document"::"Sales Order":
                begin
                    SalesHeader.Get("Source Subtype", "Source No.");
                    SalesOrder.Editable(false);
                    SalesOrder.SetRecord(SalesHeader);
                    SalesOrder.RunModal;
                end;
            "Source Document"::"Purchase Return Order":
                begin
                    PurchHeader.Get("Source Subtype", "Source No.");
                    PurchRetOrder.Editable(false);
                    PurchRetOrder.SetRecord(PurchHeader);
                    PurchRetOrder.RunModal;
                end;
            "Source Document"::"Outbound Transfer":
                begin
                    TransHeader.Get("Source No.");
                    TransOrder.Editable(false);
                    TransOrder.SetRecord(TransHeader);
                    TransOrder.RunModal;
                end;
            "Source Document"::"Prod. Consumption":
                begin
                    ProdHeader.Get("Source Subtype", "Source No.");
                    ProdOrder.Editable(false);
                    ProdOrder.SetRecord(ProdHeader);
                    ProdOrder.RunModal;
                end;
        end;
    end;

    procedure GetSourceAvailPickQty(): Decimal
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
        ProdCompLine: Record "Prod. Order Component";
    begin
        case "Source Document" of
            "Source Document"::"Sales Order":
                if SalesLine.Get("Source Subtype", "Source No.", "Source Line No.") then
                    exit(GetSalesLineAvailPickQty(SalesLine));
            "Source Document"::"Purchase Return Order":
                if PurchLine.Get("Source Subtype", "Source No.", "Source Line No.") then
                    exit(GetPurchLineAvailPickQty(PurchLine));
            "Source Document"::"Outbound Transfer":
                if TransLine.Get("Source No.", "Source Line No.") then
                    exit(GetTransLineAvailPickQty(TransLine));
            "Source Document"::"Prod. Consumption":
                if ProdCompLine.Get("Source Subtype", "Source No.", "Source Line No.", "Source Subline No.") then
                    exit(GetProdCompLineAvailPickQty(ProdCompLine));
        end;
        exit(0);
    end;

    procedure GetSalesLineAvailPickQty(var SalesLine: Record "Sales Line"): Decimal
    var
        QtyAvail: Decimal;
    begin
        QtyAvail :=
          SalesLine."Outstanding Quantity" -
          GetWhseShptQtyPicked(
            DATABASE::"Sales Line", SalesLine."Document Type",
            SalesLine."Document No.", SalesLine."Line No.");
        if (QtyAvail <= 0) then
            exit(0);
        SalesLine.CalcFields("Staged Quantity");
        exit(GetAvailLessStagedQty(QtyAvail, SalesLine."Staged Quantity"));
    end;

    procedure GetPurchLineAvailPickQty(var PurchLine: Record "Purchase Line"): Decimal
    var
        QtyAvail: Decimal;
    begin
        QtyAvail :=
          PurchLine."Outstanding Quantity" -
          GetWhseShptQtyPicked(
            DATABASE::"Purchase Line", PurchLine."Document Type",
            PurchLine."Document No.", PurchLine."Line No.");
        if (QtyAvail <= 0) then
            exit(0);
        PurchLine.CalcFields("Staged Quantity");
        exit(GetAvailLessStagedQty(QtyAvail, PurchLine."Staged Quantity"));
    end;

    procedure GetTransLineAvailPickQty(var TransLine: Record "Transfer Line"): Decimal
    var
        QtyAvail: Decimal;
    begin
        QtyAvail :=
          TransLine."Outstanding Quantity" -
          GetWhseShptQtyPicked(
            DATABASE::"Transfer Line", 0, TransLine."Document No.", TransLine."Line No.");
        if (QtyAvail <= 0) then
            exit(0);
        TransLine.CalcFields("Staged Quantity");
        exit(GetAvailLessStagedQty(QtyAvail, TransLine."Staged Quantity"));
    end;

    local procedure GetWhseShptQtyPicked(SourceType: Integer; SourceSubtype: Integer; SourceNo: Code[20]; SourceLineNo: Integer): Decimal
    var
        WhseShptLine: Record "Warehouse Shipment Line";
    begin
        with WhseShptLine do begin
            SetCurrentKey("Source Type", "Source Subtype", "Source No.", "Source Line No.");
            SetRange("Source Type", SourceType);
            SetRange("Source Subtype", SourceSubtype);
            SetRange("Source No.", SourceNo);
            SetRange("Source Line No.", SourceLineNo);
            if not Find('-') then
                exit(0);
            exit("Qty. Picked");
        end;
    end;

    procedure GetWhseShptPickQty(SourceType: Integer; SourceSubtype: Integer; SourceNo: Code[20]; SourceLineNo: Integer): Decimal
    var
        WhseShptLine: Record "Warehouse Shipment Line";
    begin
        with WhseShptLine do begin
            SetCurrentKey("Source Type", "Source Subtype", "Source No.", "Source Line No.");
            SetRange("Source Type", SourceType);
            SetRange("Source Subtype", SourceSubtype);
            SetRange("Source No.", SourceNo);
            SetRange("Source Line No.", SourceLineNo);
            if not Find('-') then
                exit(0);
            CalcFields("Pick Qty.");
            exit("Pick Qty.");
        end;
    end;

    procedure GetProdCompLineAvailPickQty(var ProdCompLine: Record "Prod. Order Component"): Decimal
    var
        QtyAvail: Decimal;
    begin
        QtyAvail := ProdCompLine."Expected Quantity" - ProdCompLine."Qty. Picked";
        if (QtyAvail <= 0) then
            exit(0);
        ProdCompLine.CalcFields("Staged Quantity");
        exit(GetAvailLessStagedQty(QtyAvail, ProdCompLine."Staged Quantity"));
    end;

    local procedure GetAvailLessStagedQty(var QtyAvail: Decimal; QtyToStage: Decimal): Decimal
    var
        OldStgdPickSourceLine: Record "Whse. Staged Pick Source Line";
    begin
        OldStgdPickSourceLine := Rec;
        if OldStgdPickSourceLine.Find then
            QtyToStage := QtyToStage - OldStgdPickSourceLine."Qty. Outstanding";
        QtyAvail := QtyAvail - QtyToStage;
        if (QtyAvail < 0) then
            exit(0);
        exit(QtyAvail);
    end;
}

