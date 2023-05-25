table 37002100 "Lot Tracing Buffer"
{
    //   PRW111.00.03
    //   P80074332, To-Increase, Gangabhushan, 18 JUL 19
    //     Lot tracing performance improvements
    //     Copied from 6520 "Item Tracing Buffer"
    // 
    // PRW121.0
    // P800155629, To-Increase, Jack Reynolds, 03 NOV 22
    //   Add support for Mandatory Variant

    Caption = 'Lot Tracing Buffer';
    ReplicateData = false;

    fields
    {
        field(1; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "Item Ledger Entry No."; Integer)
        {
            Caption = 'Item Ledger Entry No.';
            DataClassification = SystemMetadata;
            TableRelation = "Item Ledger Entry";
            Editable = false;
        }
        field(3; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(4; "Trace Quantity"; Decimal)
        {
            Caption = 'Trace Quantity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(5; "Remaining Quantity"; Decimal)
        {
            Caption = 'Remaining Quantity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(6; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            DataClassification = SystemMetadata;
            Editable = false;
            OptionCaption = 'Purchase,Sale,Positive Adjmt.,Negative Adjmt.,Transfer,Consumption,Output, ,Assembly Consumption,Assembly Output,,,,,,,Location';
            OptionMembers = Purchase,Sale,"Positive Adjmt.","Negative Adjmt.",Transfer,Consumption,Output," ","Assembly Consumption","Assembly Output",,,,,,,Location;
        }
        field(7; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(8; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = Location;
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = Item;
        }
        field(11; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(12; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(13; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(20; "Source Type"; Option)
        {
            Caption = 'Source Type';
            DataClassification = SystemMetadata;
            Editable = false;
            OptionCaption = ' ,Customer,Vendor,Item';
            OptionMembers = " ",Customer,Vendor,Item;
        }
        field(21; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = IF ("Source Type" = CONST(Customer)) Customer
            ELSE
            IF ("Source Type" = CONST(Vendor)) Vendor
            ELSE
            IF ("Source Type" = CONST(Item)) Item;
        }
        field(22; "Source Name"; Text[100])
        {
            Caption = 'Source Name';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Line No.", "Item Ledger Entry No.")
        {
            Clustered = true;
        }
    }

    // P800155629
    procedure IsVariantMandatory(): Boolean
    var
        Item: Record Item;
    begin
        exit(Item.IsVariantMandatory(true, "Item No."));
    end;
}
