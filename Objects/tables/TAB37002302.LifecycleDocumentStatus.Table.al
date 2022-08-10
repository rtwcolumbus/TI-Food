table 37002302 "Lifecycle Document Status"
{
    ObsoleteState = Removed;
    ObsoleteReason = 'Part of Document Lifecycle not migrated from C/AL to AL';
    ObsoleteTag = 'FOOD-16';

    fields
    {
        field(1; "Lifecycle No."; Code[20])
        {
        }
        field(2; "Version Code"; Code[10])
        {
        }
        field(3; "Code"; Code[20])
        {
        }
        field(11; "Change Status"; Option)
        {
            OptionMembers = "Do nothing",Open,Released,"Pending Approval","Pending Prepayment";
        }
        field(13; "Update Posting Date"; Boolean)
        {
        }
        field(14; "Update Document Date"; Boolean)
        {
        }
        field(15; Description; Text[100])
        {
        }
    }

    keys
    {
        key(Key1; "Lifecycle No.", "Version Code", "Code")
        {
        }
    }
}

