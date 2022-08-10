table 11068713 "N108 Comment Line"
{
    DataPerCompany = false;
    ObsoleteState = Removed;
    ObsoleteReason = 'Functionality was part of BIS';
    ObsoleteTag = 'FOOD-16';
    fields
    {
        field(1; "Source Type"; Integer)
        {
        }
        field(2; "Source No."; Code[20])
        {
        }
        field(3; "Line No."; Integer)
        {
        }
        field(4; Date; Date)
        {
        }
        field(5; "Code"; Code[10])
        {
        }
        field(6; Comment; Text[80])
        {
        }
        field(7; "Source Line No."; Integer)
        {
        }
        field(8; "Table No."; Integer)
        {
        }
        field(9; "Source No. 2"; Code[20])
        {
        }
    }

    keys
    {
        key(Key1; "Table No.", "Source Type", "Source No.", "Source No. 2", "Source Line No.", "Line No.")
        {
        }
    }
}

