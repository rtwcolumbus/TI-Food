table 11068791 "N108 Lifecycle Entry Detail"
{
    ObsoleteState = Removed;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
        }
        field(2; "Line No."; Integer)
        {
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
        field(19; "Action Line No."; Integer)
        {
        }
        field(10000; "Table No."; Integer)
        {
        }
        field(10001; "Action Handler Name"; Text[100])
        {
        }
        field(10002; "Codeunit No."; Integer)
        {
        }
        field(10003; "Processing Policy"; Option)
        {
            OptionMembers = "Stop and show the first processing error","Errors are not processed";
        }
        field(10004; "Batch Processing"; Boolean)
        {
        }
        field(10005; "Error Message 1"; Text[250])
        {
        }
        field(10006; "Error Message 2"; Text[250])
        {
        }
        field(10007; "Error Message 3"; Text[250])
        {
        }
        field(10008; "Error Message 4"; Text[250])
        {
        }
        field(10009; Type; Option)
        {
            OptionMembers = "On Status Change","After Status Change";
        }
    }

    keys
    {
        key(Key1; "Entry No.", "Line No.")
        {
        }
    }
}

