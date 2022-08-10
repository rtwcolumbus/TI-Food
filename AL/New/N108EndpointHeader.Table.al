table 11069366 "N108 Endpoint Header"
{
    DataPerCompany = false;
    ObsoleteState = Removed;

    fields
    {
        field(1; "Code"; Code[20])
        {
        }
        field(2; "Line No."; Integer)
        {
        }
        field(3; Name; Text[100])
        {
        }
    }

    keys
    {
        key(Key1; "Code", "Line No.")
        {
        }
    }
}

