table 11068686 "N108 Table Relation Mapping"
{
    DataPerCompany = false;
    ObsoleteState = Removed;

    fields
    {
        field(1; "ID."; Guid)
        {
        }
        field(2; Line; Integer)
        {
        }
        field(5; "Table No."; Integer)
        {
        }
        field(6; "Child Table No."; Integer)
        {
        }
        field(7; Type; Option)
        {
            OptionMembers = "FIELD","CONST",,"FILTER";
        }
        field(10; "Foreign Key Field No."; Integer)
        {
        }
        field(11; "Primary Key Field No."; Integer)
        {
        }
        field(20; "Foreign Description"; Text[50])
        {
        }
        field(21; "Primary Description"; Text[50])
        {
        }
        field(22; Value; Text[50])
        {
        }
    }

    keys
    {
        key(Key1; "ID.", "Table No.", "Child Table No.", Line)
        {
        }
    }
}

