table 11068788 "N108 Lifecycle Instance"
{
    ObsoleteState = Removed;
    ObsoleteReason = 'Functionality was part of BIS';
    ObsoleteTag = 'FOOD-16';

    fields
    {
        field(1; "Record ID"; RecordID)
        {
        }
        field(3; "Lifecycle No."; Code[20])
        {
        }
        field(4; "State Code"; Code[20])
        {
        }
        field(5; Pending; Boolean)
        {
        }
        field(12; "Version Code"; Code[10])
        {
        }
        field(20; "Codeunit No."; Integer)
        {
        }
        field(21; "No. of Entries"; Integer)
        {
        }
        field(22; "Due Date"; Date)
        {
        }
    }

    keys
    {
        key(Key1; "Record ID")
        {
        }
    }
}

