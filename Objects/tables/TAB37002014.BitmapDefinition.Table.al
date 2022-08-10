table 37002014 "Bitmap Definition"
{
    // PRW16.00.04
    // P8000889, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Used to define the bitmaps used in the production sequencing page
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Bitmap Definition';
    ReplicateData = false;

    fields
    {
        field(1; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
        }
        field(2; Start; DateTime)
        {
            Caption = 'Start';
            DataClassification = SystemMetadata;
        }
        field(3; Stop; DateTime)
        {
            Caption = 'Stop';
            DataClassification = SystemMetadata;
        }
        field(4; Color; Option)
        {
            Caption = 'Color';
            DataClassification = SystemMetadata;
            OptionCaption = 'White,Black,Green,Red';
            OptionMembers = White,Black,Green,Red;
        }
        field(5; Depth; Integer)
        {
            Caption = 'Depth';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Line No.")
        {
        }
        key(Key2; Start, Stop)
        {
        }
        key(Key3; Start, Depth)
        {
        }
    }

    fieldgroups
    {
    }
}

