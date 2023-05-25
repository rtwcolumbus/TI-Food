table 37002208 Color
{
    Caption = 'Color';
    ObsoleteState = Removed;
    ObsoleteReason = 'This was used to support color selection for the VPS which never made it to AL';
    ObsoleteTag = 'FOOD-21';
    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[30])
        {
            Caption = 'Description';
        }
        field(3; Red; Integer)
        {
            Caption = 'Red';
            MaxValue = 255;
            MinValue = 0;
        }
        field(4; Green; Integer)
        {
            Caption = 'Green';
            MaxValue = 255;
            MinValue = 0;
        }
        field(5; Blue; Integer)
        {
            Caption = 'Blue';
            MaxValue = 255;
            MinValue = 0;
        }
        field(11; Color; BLOB)
        {
            Caption = 'Color';
            SubType = Bitmap;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
        key(Key2; Red, Green, Blue)
        {
        }
    }

    fieldgroups
    {
    }
}

