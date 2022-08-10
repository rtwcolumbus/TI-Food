table 37002483 "Batch Planning Equip. Summary"
{
    // PRW16.00.04
    // P8000877, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Source table for the batch planning equipment sumary
    // 
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // PRW110.0
    // P8007750, To-Increase, Jack Reynolds, 07 NOV 16
    //   Convert Food Item Attributes to NAV Item Attributes
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Batch Planning Equip. Summary';
    ReplicateData = false;

    fields
    {
        field(1; "Production Date"; Date)
        {
            Caption = 'Production Date';
            DataClassification = SystemMetadata;
        }
        field(2; "Equipment Code"; Code[20])
        {
            Caption = 'Equipment Code';
            DataClassification = SystemMetadata;
        }
        field(3; "Highlight Value"; Text[250])
        {
            Caption = 'Highlight Value';
            DataClassification = SystemMetadata;
        }
        field(4; "Equipment Type"; Option)
        {
            Caption = 'Equipment Type';
            DataClassification = SystemMetadata;
            OptionCaption = ' ,Batch,Package';
            OptionMembers = " ",Batch,Package;
        }
        field(5; "Prod. Order Status"; Integer)
        {
            Caption = 'Prod. Order Status';
            DataClassification = SystemMetadata;
        }
        field(6; "Prod. Order No."; Code[20])
        {
            Caption = 'Prod. Order No.';
            DataClassification = SystemMetadata;
        }
        field(11; Items; Integer)
        {
            Caption = 'Items';
            DataClassification = SystemMetadata;
        }
        field(12; "Total Time (Hours)"; Decimal)
        {
            Caption = 'Total Time (Hours)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 3;
        }
        field(101; "Item Filter"; Code[20])
        {
            Caption = 'Item Filter';
            FieldClass = FlowFilter;
        }
        field(102; "Intermediate Filter"; Code[20])
        {
            Caption = 'Intermediate Filter';
            FieldClass = FlowFilter;
        }
        field(103; "Variant Filter"; Code[10])
        {
            Caption = 'Variant Filter';
            FieldClass = FlowFilter;
        }
        field(201; "Hide Equipment"; Boolean)
        {
            Caption = 'Hide Equipment';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Production Date", "Equipment Code", "Highlight Value", "Prod. Order Status", "Prod. Order No.")
        {
        }
        key(Key2; "Equipment Type", "Equipment Code", "Production Date")
        {
        }
    }

    fieldgroups
    {
    }
}

