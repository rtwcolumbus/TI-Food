table 37002477 "Eq. Board Production Drilldown"
{
    // PR4.00
    // P8000197A, Myers Nissi, Jack Reynolds, 21 SEP 05
    //   This is used as a temp table to provide the basis for drill down on production time
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

    Caption = 'Eq. Board Production Drilldown';
    LookupPageID = "Eq. Board Production Drilldown";
    ReplicateData = false;

    fields
    {
        field(1; "Prod. Order Status"; Option)
        {
            Caption = 'Prod. Order Status';
            DataClassification = SystemMetadata;
            OptionCaption = ',,Firm Planned,Released';
            OptionMembers = ,,"Firm Planned",Released;
        }
        field(2; "Prod Order No."; Code[20])
        {
            Caption = 'Prod Order No.';
            DataClassification = SystemMetadata;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }
        field(4; Location; Code[10])
        {
            Caption = 'Location';
            DataClassification = SystemMetadata;
        }
        field(5; "Equipment Code"; Code[20])
        {
            Caption = 'Equipment Code';
            DataClassification = SystemMetadata;
        }
        field(6; Date; Date)
        {
            Caption = 'Date';
            DataClassification = SystemMetadata;
        }
        field(7; "Starting Time"; Time)
        {
            Caption = 'Starting Time';
            DataClassification = SystemMetadata;
        }
        field(8; "Ending Time"; Time)
        {
            Caption = 'Ending Time';
            DataClassification = SystemMetadata;
        }
        field(9; Duration; Decimal)
        {
            Caption = 'Duration';
            DataClassification = SystemMetadata;
        }
        field(10; Change; Boolean)
        {
            Caption = 'Change';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Prod. Order Status", "Prod Order No.", Date, Change)
        {
        }
    }

    fieldgroups
    {
    }
}

