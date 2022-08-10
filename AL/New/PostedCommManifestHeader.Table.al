table 37002688 "Posted Comm. Manifest Header"
{
    // PRW16.00.04
    // P8000891, VerticalSoft, Don Bresee, 04 JAN 11
    //   Add Commodity Receiving logic
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Posted Comm. Manifest Header';
    DataCaptionFields = "No.", "Item No.";
    LookupPageID = "Posted Comm. Manifest List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(3; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"),
                                            "Lot Combination Method" = CONST(Manual));
        }
        field(4; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item WHERE("Catch Alternate Qtys." = CONST(false));
        }
        field(5; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(6; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
        }
        field(7; "Received Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Received Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(8; "Loaded Scale Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Loaded Scale Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(9; "Empty Scale Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Empty Scale Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(10; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(13; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(15; "Manifest Quantity"; Decimal)
        {
            BlankZero = true;
            CalcFormula = Sum ("Posted Comm. Manifest Line"."Manifest Quantity" WHERE("Posted Comm. Manifest No." = FIELD("No.")));
            Caption = 'Manifest Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(16; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(17; "Hauler No."; Code[20])
        {
            Caption = 'Hauler No.';
            TableRelation = Vendor WHERE("Commodity Vendor Type" = CONST(Hauler));
        }
        field(18; "Product Rejected"; Boolean)
        {
            Caption = 'Product Rejected';
        }
        field(19; "Broker No."; Code[20])
        {
            Caption = 'Broker No.';
            TableRelation = Vendor WHERE("Commodity Vendor Type" = CONST(Broker));
        }
        field(1001; "Commodity Manifest No."; Code[20])
        {
            Caption = 'Commodity Manifest No.';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; "Location Code", "Bin Code", "Posting Date")
        {
        }
        key(Key3; "Item No.", "Posting Date")
        {
        }
    }

    fieldgroups
    {
    }

    procedure Navigate()
    var
        NavigateForm: Page Navigate;
    begin
        NavigateForm.SetDoc("Posting Date", "No.");
        NavigateForm.Run;
    end;

    procedure ShowManifestLotEntries()
    begin
        ShowLotEntries("Lot No.");
    end;

    procedure ShowLotEntries(LotNo: Code[50])
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        ItemLedgEntry.SetCurrentKey("Item No.", "Variant Code", "Location Code", "Lot No.");
        ItemLedgEntry.SetRange("Item No.", "Item No.");
        ItemLedgEntry.SetRange("Variant Code", "Variant Code");
        ItemLedgEntry.SetRange("Lot No.", LotNo);
        PAGE.RunModal(0, ItemLedgEntry);
    end;
}

