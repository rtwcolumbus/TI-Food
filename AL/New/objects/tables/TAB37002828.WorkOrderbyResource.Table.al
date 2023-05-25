table 37002828 "Work Order by Resource"
{
    // PRW16.00.04
    // P8000880, VerticalSoft, Jack Reynolds, 16 NOV 10
    //   Source table for Maintenance Work FactBox
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Work Order by Resource';
    ReplicateData = false;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Resource No."; Code[20])
        {
            Caption = 'Resource No.';
            DataClassification = SystemMetadata;
        }
        field(3; "Asset No."; Code[20])
        {
            Caption = 'Asset No.';
            DataClassification = SystemMetadata;
        }
        field(4; Date; Date)
        {
            Caption = 'Date';
            DataClassification = SystemMetadata;
        }
        field(5; "Work Order No."; Code[20])
        {
            Caption = 'Work Order No.';
            DataClassification = SystemMetadata;
        }
        field(6; "PM Entry No."; Code[20])
        {
            Caption = 'PM Entry No.';
            DataClassification = SystemMetadata;
        }
        field(7; "Work Requested"; Text[80])
        {
            Caption = 'Work Requested';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Resource No.", Date, "Asset No.")
        {
        }
        key(Key3; "Asset No.")
        {
        }
    }

    fieldgroups
    {
    }
}

