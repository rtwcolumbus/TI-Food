table 11068750 "N108 Product Registration"
{
    DataPerCompany = false;
    ObsoleteState = Removed;
    ObsoleteReason = 'Functionality was part of BIS';
    ObsoleteTag = 'FOOD-16';

    fields
    {
        field(1; "Code"; Code[10])
        {
        }
        field(2; "Codeunit No."; Integer)
        {
        }
        field(3; Type; Option)
        {
            OptionMembers = Solution,Product;
        }
        field(5; "Parent Code"; Code[10])
        {
        }
        field(10; Name; Text[80])
        {
        }
        field(11; Enabled; Boolean)
        {
        }
        field(12; Version; Text[80])
        {
        }
        field(13; Installed; Boolean)
        {
        }
        field(28; "Solution Code"; Code[10])
        {
        }
        field(29; "Solution Name"; Text[80])
        {
        }
        field(36; "Setup Page No."; Integer)
        {
        }
        field(37; "Installation Date"; Date)
        {
        }
        field(38; "Installation User ID"; Code[50])
        {
        }
        field(39; Date; Date)
        {
        }
        field(40; "Software Vendor Id"; Text[30])
        {
        }
        field(41; "Software Vendor Name"; Text[100])
        {
        }
        field(42; "Granule Id"; Integer)
        {
        }
    }

    keys
    {
        key(Key1; Type, "Code")
        {
        }
    }
}

