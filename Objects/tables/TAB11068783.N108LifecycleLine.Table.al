table 11068783 "N108 Lifecycle Line"
{
    ObsoleteState = Removed;
    ObsoleteReason = 'Functionality was part of BIS';
    ObsoleteTag = 'FOOD-16';

    fields
    {
        field(1; "Lifecycle No."; Code[20])
        {
        }
        field(2; "Line No."; Integer)
        {
        }
        field(3; "Code From"; Code[20])
        {
        }
        field(4; "Description From"; Text[50])
        {
        }
        field(5; "Code To"; Code[20])
        {
        }
        field(6; "Description To"; Text[50])
        {
        }
        field(7; "No. of Conditions"; Integer)
        {
        }
        field(8; "No. of Actions"; Integer)
        {
        }
        field(10; "State Code Failed"; Code[20])
        {
        }
        field(12; "Version Code"; Code[10])
        {
        }
        field(13; Confirm; Boolean)
        {
        }
        field(14; Allowed; Boolean)
        {
        }
        field(15; "Record ID"; RecordID)
        {
        }
        field(16; "Due Date Formula"; DateFormula)
        {
        }
        field(17; "Execute Trigger After Update"; Boolean)
        {
        }
        field(50; Status; Option)
        {
            OptionMembers = Enabled,Disabled;
        }
        field(51; "Product No."; Code[10])
        {
        }
        field(52; "User Message"; Text[250])
        {
        }
    }

    keys
    {
        key(Key1; "Lifecycle No.", "Version Code", "Line No.")
        {
        }
    }
}

