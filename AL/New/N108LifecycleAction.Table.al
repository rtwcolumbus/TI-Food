table 11068786 "N108 Lifecycle Action"
{
    ObsoleteState = Removed;

    fields
    {
        field(1; "Lifecycle No."; Code[20])
        {
        }
        field(2; "Parent Line No."; Integer)
        {
        }
        field(3; "Line No."; Integer)
        {
        }
        field(4; "State Code"; Code[20])
        {
        }
        field(5; Description; Text[50])
        {
        }
        field(6; Type; Option)
        {
            OptionMembers = "On Status Change","After Status Change";
        }
        field(12; "Version Code"; Code[10])
        {
        }
        field(50; Status; Option)
        {
            OptionMembers = Enabled,Disabled;
        }
        field(51; "Table No."; Integer)
        {
        }
        field(52; "Action Handler Name"; Text[100])
        {
        }
        field(53; "Product No."; Code[10])
        {
        }
        field(54; "Codeunit No."; Integer)
        {
        }
        field(56; Arguments; Boolean)
        {
        }
        field(57; "Processing Policy"; Option)
        {
            OptionMembers = "Stop and show the first processing error","Errors are not processed";
        }
        field(58; "Batch Processing"; Boolean)
        {
        }
    }

    keys
    {
        key(Key1; "Lifecycle No.", "Version Code", "Parent Line No.", "State Code", "Line No.")
        {
        }
    }
}

