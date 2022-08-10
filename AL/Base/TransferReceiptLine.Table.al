table 5747 "Transfer Receipt Line"
{
    // PR3.61
    //   Add Fields
    //     Quantity (Alt.)
    //     Type
    // 
    // PR3.70
    //   Add Key - Type,Item No. (Group - LOT CTRL)
    // 
    // PRW16.00.05
    // P8000928, Columbus IT, Jack Reynolds, 06 APR 11
    //   Support for Extra Charges
    // 
    // P8000931, Columbus IT, Jack Reynolds, 20 APR 11
    //   Support for Supply Chain Groups
    // 
    // P8000971, Columbus IT, Jack Reynolds, 25 AUG 11
    //   Fix problem with item charges and alternate quantity
    // 
    // PRW16.00.06
    // P8001047, Columbus IT, Jack Reynolds, 30 MAR 12
    //   Receiving Labels
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018

    Caption = 'Transfer Receipt Line';
    LookupPageID = "Posted Transfer Receipt Lines";

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(4; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(5; "Unit of Measure"; Text[50])
        {
            Caption = 'Unit of Measure';
        }
        field(7; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(8; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(9; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(10; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
        field(11; "Inventory Posting Group"; Code[20])
        {
            Caption = 'Inventory Posting Group';
            TableRelation = "Inventory Posting Group";
        }
        field(12; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(14; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            InitValue = 1;
        }
        field(15; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(16; "Gross Weight"; Decimal)
        {
            Caption = 'Gross Weight';
            DecimalPlaces = 0 : 5;
        }
        field(17; "Net Weight"; Decimal)
        {
            Caption = 'Net Weight';
            DecimalPlaces = 0 : 5;
        }
        field(18; "Unit Volume"; Decimal)
        {
            Caption = 'Unit Volume';
            DecimalPlaces = 0 : 5;
        }
        field(21; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(22; "Units per Parcel"; Decimal)
        {
            Caption = 'Units per Parcel';
            DecimalPlaces = 0 : 5;
        }
        field(23; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
        }
        field(24; "Transfer Order No."; Code[20])
        {
            Caption = 'Transfer Order No.';
            TableRelation = "Transfer Header";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(25; "Receipt Date"; Date)
        {
            Caption = 'Receipt Date';
        }
        field(26; "Shipping Agent Code"; Code[10])
        {
            AccessByPermission = TableData "Shipping Agent Services" = R;
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";
        }
        field(27; "Shipping Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code WHERE("Shipping Agent Code" = FIELD("Shipping Agent Code"));
        }
        field(28; "In-Transit Code"; Code[10])
        {
            Caption = 'In-Transit Code';
            Editable = false;
            TableRelation = Location WHERE("Use As In-Transit" = CONST(true));
        }
        field(29; "Transfer-from Code"; Code[10])
        {
            Caption = 'Transfer-from Code';
            Editable = false;
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
        }
        field(30; "Transfer-to Code"; Code[10])
        {
            Caption = 'Transfer-to Code';
            Editable = false;
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
        }
        field(31; "Item Rcpt. Entry No."; Integer)
        {
            Caption = 'Item Rcpt. Entry No.';
        }
        field(32; "Shipping Time"; DateFormula)
        {
            AccessByPermission = TableData "Shipping Agent Services" = R;
            Caption = 'Shipping Time';
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions();
            end;
        }
        field(5704; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            TableRelation = "Item Category";
        }
        field(5707; "Product Group Code"; Code[10])
        {
            Caption = 'Product Group Code';
            ObsoleteReason = 'Product Groups became first level children of Item Categories.';
            ObsoleteState = Removed;
            ObsoleteTag = '15.0';
        }
        field(7301; "Transfer-To Bin Code"; Code[20])
        {
            Caption = 'Transfer-To Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Transfer-to Code"),
                                            "Item Filter" = FIELD("Item No."),
                                            "Variant Filter" = FIELD("Variant Code"));
        }
        field(37002015; "Supply Chain Group Code"; Code[10])
        {
            Caption = 'Supply Chain Group Code';
            TableRelation = "Supply Chain Group";
        }
        field(37002081; "Quantity (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,1,0,%1,%2', Type, "Item No.");
            Caption = 'Quantity (Alt.)';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.61';
        }
        field(37002560; Type; Option)
        {
            Caption = 'Type';
            Description = 'PR3.61';
            OptionCaption = 'Item,Container';
            OptionMembers = Item,Container;
        }
        field(37002700; "Label Unit of Measure Code"; Code[10])
        {
            Caption = 'Label Unit of Measure Code';
            TableRelation = IF (Type = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
    }

    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Transfer Order No.", "Item No.", "Receipt Date")
        {
        }
        key(Key3; Type, "Item No.")
        {
            Enabled = false;
        }
    }

    fieldgroups
    {
    }

    var
        Item: Record Item;
        DimMgt: Codeunit DimensionManagement;

    procedure ShowDimensions()
    begin
        DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo('%1 %2 %3', TableCaption, "Document No.", "Line No."));
    end;

    procedure ShowItemTrackingLines()
    var
        ItemTrackingDocMgt: Codeunit "Item Tracking Doc. Management";
    begin
        ItemTrackingDocMgt.ShowItemTrackingForShptRcptLine(DATABASE::"Transfer Receipt Line", 0, "Document No.", '', 0, "Line No.");
    end;

    procedure ShowExtraCharges()
    var
        PostedExtraCharge: Record "Posted Document Extra Charge";
        PostedExtraCharges: Page "Pstd. Doc. Line Extra Charges";
    begin
        // P8000928
        TestField("Item No.");
        TestField("Line No.");
        TestField(Type, Type::Item);
        PostedExtraCharge.SetRange("Table ID", DATABASE::"Transfer Receipt Line");
        PostedExtraCharge.SetRange("Document No.", "Document No.");
        PostedExtraCharge.SetRange("Line No.", "Line No.");
        PostedExtraCharges.SetTableView(PostedExtraCharge);
        PostedExtraCharges.RunModal;
    end;

    local procedure GetItem()
    begin
        // P8000971
        if (Item."No." <> "Item No.") then
            Item.Get("Item No.");
    end;

    procedure CostInAlternateUnits(): Boolean
    begin
        // P8000971
        GetItem;
        exit(Item.CostInAlternateUnits);
    end;

    procedure GetCostingQtyBase(): Decimal
    begin
        // P8000971
        if CostInAlternateUnits then
            exit("Quantity (Alt.)");
        exit("Quantity (Base)");
    end;

    procedure CopyFromTransferLine(TransLine: Record "Transfer Line")
    begin
        "Line No." := TransLine."Line No.";
        Type := TransLine.Type; // P8007748
        "Item No." := TransLine."Item No.";
        Description := TransLine.Description;
        Quantity := TransLine."Qty. to Receive";
        "Unit of Measure" := TransLine."Unit of Measure";
        "Shortcut Dimension 1 Code" := TransLine."Shortcut Dimension 1 Code";
        "Shortcut Dimension 2 Code" := TransLine."Shortcut Dimension 2 Code";
        "Dimension Set ID" := TransLine."Dimension Set ID";
        "Gen. Prod. Posting Group" := TransLine."Gen. Prod. Posting Group";
        "Inventory Posting Group" := TransLine."Inventory Posting Group";
        "Quantity (Base)" := TransLine."Qty. to Receive (Base)";
        "Quantity (Alt.)" := TransLine."Qty. to Receive (Alt.)"; // P8007748
        "Qty. per Unit of Measure" := TransLine."Qty. per Unit of Measure";
        "Unit of Measure Code" := TransLine."Unit of Measure Code";
        "Gross Weight" := TransLine."Gross Weight";
        "Net Weight" := TransLine."Net Weight";
        "Unit Volume" := TransLine."Unit Volume";
        "Variant Code" := TransLine."Variant Code";
        "Units per Parcel" := TransLine."Units per Parcel";
        "Description 2" := TransLine."Description 2";
        "Transfer Order No." := TransLine."Document No.";
        "Receipt Date" := TransLine."Receipt Date";
        "Shipping Agent Code" := TransLine."Shipping Agent Code";
        "Shipping Agent Service Code" := TransLine."Shipping Agent Service Code";
        "In-Transit Code" := TransLine."In-Transit Code";
        "Transfer-from Code" := TransLine."Transfer-from Code";
        "Transfer-to Code" := TransLine."Transfer-to Code";
        "Transfer-To Bin Code" := TransLine."Transfer-To Bin Code";
        "Shipping Time" := TransLine."Shipping Time";
        "Item Category Code" := TransLine."Item Category Code";

        OnAfterCopyFromTransferLine(Rec, TransLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromTransferLine(var TransferReceiptLine: Record "Transfer Receipt Line"; TransferLine: Record "Transfer Line")
    begin
    end;
}

