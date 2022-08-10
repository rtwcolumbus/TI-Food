table 37002017 "Process 800 Signal"
{
    // PRW16.00.05
    // P8000940, Columbus IT, Jack Reynolds, 05 MAY 11
    //   Temporary table used for signalling controls
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Process 800 Signal';
    ReplicateData = false;

    fields
    {
        field(1; Index; Integer)
        {
            Caption = 'Index';
            DataClassification = SystemMetadata;
        }
        field(2; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(3; Message; Text[250])
        {
            Caption = 'Message';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; Index, "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

