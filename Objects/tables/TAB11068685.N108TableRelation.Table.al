table 11068685 "N108 Table Relation"
{
    DataPerCompany = false;
    ObsoleteState = Removed;
    ObsoleteReason = 'Functionality was part of BIS';
    ObsoleteTag = 'FOOD-16';

    fields
    {
        field(1; "Table No."; Integer)
        {
        }
        field(2; "Child Table No."; Integer)
        {
        }
        field(3; "No."; Integer)
        {
        }
        field(5; Description; Text[50])
        {
        }
        field(6; Type; Option)
        {
            OptionMembers = " ",Reference,Composition;
        }
        field(7; "Generic Export"; Option)
        {
            OptionMembers = " ",Include,"Last Level";
        }
        field(8; "Found Action"; Option)
        {
            OptionMembers = " ",UseExisting,Update,,Delete;
        }
        field(9; "Not Found Action"; Option)
        {
            OptionMembers = " ",Insert,Skip;
        }
        field(10; "Relation Mapping ID."; Guid)
        {
        }
        field(11; "System-Created Entry"; Boolean)
        {
        }
        field(511; "Component ID"; Code[20])
        {
        }
    }

    keys
    {
        key(Key1; "Table No.", "Child Table No.", "No.")
        {
        }
    }

}

