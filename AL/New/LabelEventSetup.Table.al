table 37002706 "Label Event Setup"
{
    ObsoleteState = Removed;

    fields
    {
        field(1; "Source Type"; Integer)
        {
        }
        field(2; "Source No."; Code[20])
        {
        }
        field(3; "Activity Code"; Code[20])
        {
        }
        field(10; "Source Document No."; Code[20])
        {
        }
        field(37002700; "Label Type"; Option)
        {
            OptionMembers = " ","Case",Container,"Pre-Process",,,,,,"Shipping Container","Production Container";
        }
    }

    keys
    {
        key(Key1; "Source Type", "Source No.", "Activity Code")
        {
        }
    }
}

