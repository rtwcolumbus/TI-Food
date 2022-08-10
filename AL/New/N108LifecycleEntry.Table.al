table 11068789 "N108 Lifecycle Entry"
{
    ObsoleteState = Removed;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
        }
        field(10; "Record ID"; RecordID)
        {
        }
        field(11; "Lifecycle No."; Code[20])
        {
        }
        field(12; "Version Code"; Code[10])
        {
        }
        field(13; "State Code"; Code[20])
        {
        }
        field(14; Status; Option)
        {
            OptionMembers = ,Pending,Completed,Failed;
        }
        field(15; "Log Date"; Date)
        {
        }
        field(16; "Log Time"; Time)
        {
        }
        field(17; "User ID"; Code[50])
        {
        }
        field(18; "Parent Line No."; Integer)
        {
        }
        field(19; "No. of Actions"; Integer)
        {
        }
        field(20; "No. of Pending Actions"; Integer)
        {
        }
        field(21; "Due Date Formula"; DateFormula)
        {
        }
        field(22; "Due Date"; Date)
        {
        }
        field(23; "Execute Trigger After Update"; Boolean)
        {
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }
}

