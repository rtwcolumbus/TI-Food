table 37002476 "Daily Prod. Planning-Change"
{
    // PR4.00
    // P8000197A, Myers Nissi, Jack Reynolds, 21 SEP 05
    //   This is used as a temp table to store change in the produciton orders for purpose of updating the sales
    //   and equipment boards
    // 
    // PRW17.10.01
    // P8001258, Columbus IT, Jack Reynolds, 10 JAN 14
    //   Increase size ot text fields/variables
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Daily Prod. Planning-Change';
    ReplicateData = false;

    fields
    {
        field(1; Status; Option)
        {
            Caption = 'Status';
            DataClassification = SystemMetadata;
            OptionCaption = ',,Firm Planned,Released';
            OptionMembers = ,,"Firm Planned",Released;
        }
        field(2; "Production Order No."; Code[20])
        {
            Caption = 'Production Order No.';
            DataClassification = SystemMetadata;
        }
        field(3; "Prod. Order Line No."; Integer)
        {
            Caption = 'Prod. Order Line No.';
            DataClassification = SystemMetadata;
        }
        field(4; Type; Option)
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'Output,Consumption,Prod. Time';
            OptionMembers = Output,Consumption,"Prod. Time";
        }
        field(5; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = SystemMetadata;
        }
        field(6; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = SystemMetadata;
        }
        field(7; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = SystemMetadata;
        }
        field(8; Date; Date)
        {
            Caption = 'Date';
            DataClassification = SystemMetadata;
        }
        field(9; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = SystemMetadata;
        }
        field(10; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DataClassification = SystemMetadata;
        }
        field(11; "Equipment Code"; Code[20])
        {
            Caption = 'Equipment Code';
            DataClassification = SystemMetadata;
        }
        field(12; "Starting Time"; Time)
        {
            Caption = 'Starting Time';
            DataClassification = SystemMetadata;
        }
        field(13; "Ending Time"; Time)
        {
            Caption = 'Ending Time';
            DataClassification = SystemMetadata;
        }
        field(14; Duration; Decimal)
        {
            Caption = 'Duration';
            DataClassification = SystemMetadata;
        }
        field(15; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; Status, "Production Order No.", "Prod. Order Line No.", Type, "Item No.", "Variant Code", "Location Code", "Equipment Code", Date)
        {
            SumIndexFields = Quantity, "Quantity (Base)";
        }
        key(Key2; "Item No.")
        {
        }
        key(Key3; "Equipment Code")
        {
        }
    }

    fieldgroups
    {
    }
}

