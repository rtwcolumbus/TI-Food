table 37002703 "Label Worksheet Line"
{
    // PRW16.00.06
    // P8001047, Columbus IT, Jack Reynolds, 30 MAR 12
    //   Receiving Labels
    // 
    // P8001123, Columbus IT, Jack Reynolds, 19 DEC 12
    //   Move Item table Label Code fields to Item Label table
    // 
    // PRW17.10
    // P8001233, Columbus IT, Jack Reynolds, 24 OCT 13
    //   Support for label worksheet
    // 
    // P8001239, Columbus IT, Jack Reynolds, 01 NOV 13
    //   Fix problem printing labels if Lot No. Information has not yet been posted
    // 
    // P8001246, Columbus IT, Jack Reynolds, 21 NOV 13
    //   Enlarge description fields to 50 characters
    // 
    // PRW17.10.03
    // P8001326, Columbus IT, Jack Reynolds, 27 MAY 14
    //   Fix problem with missing data for production orders
    // 
    // PRW110.0.01
    // P8008451, To-Increase, Jack Reynolds, 22 MAR 17
    //   Label Printing support for NAV Anywhere
    // 
    // PRW110.0.02
    // P80055869, To-Increase, Dayakar Battini, 20 MAR 18
    //   Fix Label Printing User selection Issue
    // 
    // P80056085, To-Increase, Dayakar Battini, 27 MAR 18
    //   Fix issue with tool many key fields
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW111.00.02
    // P80070068, To Increase, Gangabhushan, 01 FEB 19
    //   TI-12757 - Error in Printing Labels from Posted Transfer Receipts
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Label Worksheet Line';

    fields
    {
        field(1; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = Item;

            trigger OnValidate()
            var
                ItemTrackingCode: Record "Item Tracking Code";
            begin
                GetItem;
                "Item Description" := Item.Description;
                if Item."Item Tracking Code" <> '' then begin
                    ItemTrackingCode.Get(Item."Item Tracking Code");
                    "Lot Tracked" := ItemTrackingCode."Lot Specific Tracking";
                end;
            end;
        }
        field(3; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(4; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(5; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            DataClassification = SystemMetadata;
            Editable = false;

            trigger OnValidate()
            begin
                "Document Date" := 0D;
                "Document Date Editable" := true;

                if "Lot No." <> '' then
                    if LotInfo.Get("Item No.", "Variant Code", "Lot No.") then
                        if LotInfo.Posted then begin
                            "Document Date" := LotInfo."Document Date";
                            "Document Date Editable" := false;
                        end;
            end;
        }
        field(6; "Lot Tracked"; Boolean)
        {
            Caption = 'Lot Tracked';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(11; "Source Table"; Integer)
        {
            Caption = 'Source Table';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(12; "Source Type"; Integer)
        {
            Caption = 'Source Type';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(13; "Source Document No."; Code[20])
        {
            Caption = 'Source Document No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(14; "Source Line No."; Integer)
        {
            Caption = 'Source Line No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(21; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                "Quantity (Base)" := Round(Quantity * "Qty. per Unit of Measure", 0.00001);
                Validate("Quantity (Label Units)", Round("Quantity (Base)" / "Label Qty. per Unit of Measure", 0.00001));
            end;
        }
        field(22; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(23; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DataClassification = SystemMetadata;
            DecimalPlaces = 12 : 12;
            Editable = false;
        }
        field(24; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(25; "Label Unit of Measure Code"; Code[10])
        {
            Caption = 'Label Unit of Measure Code';
            DataClassification = SystemMetadata;
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            var
                ItemUOM: Record "Item Unit of Measure";
            begin
                if "Label Unit of Measure Code" = '' then begin
                    GetItem;
                    if Item."Label Unit of Measure" <> '' then
                        "Label Unit of Measure Code" := Item."Label Unit of Measure"
                    else
                        "Label Unit of Measure Code" := "Unit of Measure Code";
                end;

                ItemUOM.Get("Item No.", "Label Unit of Measure Code");
                "Label Qty. per Unit of Measure" := ItemUOM."Qty. per Unit of Measure";
                "Labels per Unit" := ItemUOM."Labels per Unit";
                Validate("Quantity (Label Units)", Round("Quantity (Base)" / "Label Qty. per Unit of Measure", 0.00001));

                if ItemUOM."Label Code" <> '' then
                    "Label Code" := ItemUOM."Label Code"
                else begin
                    GetItem;
                    "Label Code" := Item.GetLabelCode(1); // P8001123
                end;
            end;
        }
        field(26; "Label Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Label Qty. per Unit of Measure';
            DataClassification = SystemMetadata;
            DecimalPlaces = 12 : 12;
            Editable = false;
        }
        field(27; "Quantity (Label Units)"; Decimal)
        {
            Caption = 'Quantity (Label Units)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                if CurrFieldNo = FieldNo("Quantity (Label Units)") then begin
                    "Quantity (Base)" := Round("Quantity (Label Units)" * "Label Qty. per Unit of Measure", 0.00001);
                    Quantity := Round("Quantity (Base)" / "Qty. per Unit of Measure", 0.00001);
                end;
                "No. of Labels" := Round("Quantity (Label Units)" * "Labels per Unit", 1);
            end;
        }
        field(28; "Labels per Unit"; Decimal)
        {
            Caption = 'Labels per Unit';
            DataClassification = SystemMetadata;
            DecimalPlaces = 12 : 12;
            Editable = false;
        }
        field(29; "No. of Labels"; Integer)
        {
            Caption = 'No. of Labels';
            DataClassification = SystemMetadata;
        }
        field(30; "Label Code"; Code[10])
        {
            Caption = 'Label Code';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = Label WHERE(Type = CONST(Case));
        }
        field(31; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = SystemMetadata;
        }
        field(32; "Document Date Editable"; Boolean)
        {
            Caption = 'Document Date Editable';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        TransferLine: Record "Transfer Line";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        ReturnReceiptLine: Record "Return Receipt Line";
        TransferReceiptLine: Record "Transfer Receipt Line";
        ProdOrderLine: Record "Prod. Order Line";
        Item: Record Item;
        LotInfo: Record "Lot No. Information";
        Text001: Label 'Sales Return Order';
        Text002: Label 'Purchase Order';
        Text003: Label 'Transfer Order';
        Text004: Label 'Purchase Receipt';
        Text005: Label 'Return Receipt';
        Text006: Label 'Transfer Receipt';
        Text007: Label '%1 %2';

    procedure GetItem()
    begin
        if Item."No." <> "Item No." then
            Item.Get("Item No.");
    end;

    procedure SourceDocumentType(): Text[30]
    var
        ProdOrder: Record "Production Order";
    begin
        case "Source Table" of
            DATABASE::"Sales Line":
                exit(Text001);
            DATABASE::"Purchase Line":
                exit(Text002);
            DATABASE::"Transfer Line":
                exit(Text003);
            DATABASE::"Purch. Rcpt. Line":
                exit(Text004);
            DATABASE::"Return Receipt Line":
                exit(Text005);
            DATABASE::"Transfer Receipt Line":
                exit(Text006);
            // P8001233
            DATABASE::"Prod. Order Line":
                begin
                    ProdOrder.Status := "Source Type";
                    exit(StrSubstNo(Text007, ProdOrder.Status, ProdOrder.TableCaption));
                end;
        // P8001233
        end;
    end;

    procedure PrintLabel()
    var
        ItemCaseLabel: Record "Item Case Label";
        LotNoInfo: Record "Lot No. Information";
        PurchLine: Record "Purchase Line";
        LabData: RecordRef;
        LabelMgmt: Codeunit "Label Management";
        FldList: Text[30];
    begin
        if "Label Code" <> '' then begin
            FldList := '01';
            ItemCaseLabel.Validate("Item No.", "Item No.");
            ItemCaseLabel.Validate("Variant Code", "Variant Code");
            if "Lot No." <> '' then begin
                FldList := FldList + ',10';
                if LotNoInfo.Get("Item No.", "Variant Code", "Lot No.") and LotNoInfo.Posted then // P8001239
                    ItemCaseLabel.Validate("Lot No.", "Lot No.") // P8001239
                                                                 // P8001239
                else begin
                    ItemCaseLabel."Lot No." := "Lot No.";
                    if "Source Table" in [DATABASE::"Purch. Rcpt. Line", DATABASE::"Transfer Receipt Line", DATABASE::"Return Receipt Line", DATABASE::"Prod. Order Line"] then // P8001326
                        ItemCaseLabel."Document No." := "Source Document No.";
                    ItemCaseLabel."Document Date" := "Document Date";
                    ItemCaseLabel.SetExpirationDate;
                    if "Source Table" = DATABASE::"Purchase Line" then begin
                        PurchLine.Get("Source Type", "Source Document No.", "Source Line No.");
                        ItemCaseLabel.Validate("Country/Region of Origin Code", PurchLine."Country/Region of Origin Code");
                    end;
                end;
                // P8001239
            end else begin
                if "Source Table" in [DATABASE::"Purch. Rcpt. Line", DATABASE::"Transfer Receipt Line", DATABASE::"Return Receipt Line", DATABASE::"Prod. Order Line"] then // P8001233, P8001326
                    ItemCaseLabel."Document No." := "Source Document No.";
                ItemCaseLabel."Document Date" := "Document Date";
            end;
            // P8001326
            if "Source Table" = DATABASE::"Prod. Order Line" then begin
                ItemCaseLabel.Validate("Prod. Order Status", "Source Type");
                ItemCaseLabel.Validate("Prod. Order No.", "Source Document No.");
                ItemCaseLabel.Validate("Prod. Order Line No.", "Source Line No.");
            end;
            // P8001326
            ItemCaseLabel.Validate("Unit of Measure Code", "Label Unit of Measure Code");
            ItemCaseLabel.Validate(Quantity, "Quantity (Label Units)");

            ItemCaseLabel.CreateUCC(FldList);

            ItemCaseLabel."No. Of Copies" := "No. of Labels";
            LabData.GetTable(ItemCaseLabel);
            // LabelMgmt.SetUser(UserId);  // P80055869
            LabelMgmt.PrintLabel("Label Code", GetSourceLocation, LabData); // P8008451
        end;
    end;

    local procedure GetSourceLocation(): Code[10]
    begin
        // P8008451
        case "Source Table" of
            DATABASE::"Sales Line":
                begin
                    if (SalesLine."Document Type" <> "Source Type") or (SalesLine."Document No." <> "Source Document No.") or (SalesLine."Line No." <> "Source Line No.") then
                        SalesLine.Get("Source Type", "Source Document No.", "Source Line No.");
                    exit(SalesLine."Location Code");
                end;
            DATABASE::"Purchase Line":
                begin
                    if (PurchaseLine."Document Type" <> "Source Type") or (PurchaseLine."Document No." <> "Source Document No.") or (PurchaseLine."Line No." <> "Source Line No.") then
                        PurchaseLine.Get("Source Type", "Source Document No.", "Source Line No.");
                    exit(PurchaseLine."Location Code");
                end;
            DATABASE::"Transfer Line":
                begin
                    if (TransferLine."Document No." <> "Source Document No.") or (TransferLine."Line No." <> "Source Line No.") then
                        TransferLine.Get("Source Document No.", "Source Line No."); // P80070068
                    exit(TransferLine."Transfer-to Code");
                end;
            DATABASE::"Purch. Rcpt. Line":
                begin
                    if (PurchRcptLine."Document No." <> "Source Document No.") or (PurchRcptLine."Line No." <> "Source Line No.") then
                        PurchRcptLine.Get("Source Document No.", "Source Line No."); // P80070068
                    exit(PurchRcptLine."Location Code");
                end;
            DATABASE::"Return Receipt Line":
                begin
                    if (ReturnReceiptLine."Document No." <> "Source Document No.") or (ReturnReceiptLine."Line No." <> "Source Line No.") then
                        ReturnReceiptLine.Get("Source Document No.", "Source Line No.");
                    exit(ReturnReceiptLine."Location Code");
                end;
            DATABASE::"Transfer Receipt Line":
                begin
                    if (TransferReceiptLine."Document No." <> "Source Document No.") or (TransferReceiptLine."Line No." <> "Source Line No.") then
                        TransferReceiptLine.Get("Source Document No.", "Source Line No."); // P80070068
                    exit(TransferReceiptLine."Transfer-to Code");
                end;
            DATABASE::"Prod. Order Line":
                begin
                    if (ProdOrderLine.Status <> "Source Type") or (ProdOrderLine."Prod. Order No." <> "Source Document No.") or (ProdOrderLine."Line No." <> "Source Line No.") then
                        ProdOrderLine.Get("Source Type", "Source Document No.", "Source Line No."); // P80056085
                    exit(ProdOrderLine."Location Code");
                end;
        end;
    end;
}

