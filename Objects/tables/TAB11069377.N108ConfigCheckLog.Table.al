table 11069377 "N108 Config Check Log"
{
    DataPerCompany = false;
    ObsoleteState = Removed;
    ObsoleteReason = 'Functionality was part of BIS';
    ObsoleteTag = 'FOOD-16';

    fields
    {
        field(1; "Session ID"; Integer)
        {
        }
        field(2; "Source Type"; Integer)
        {
        }
        field(3; "Source No."; Code[20])
        {
        }
        field(4; "Entry No."; Integer)
        {
        }
        field(5; "Record ID"; RecordID)
        {
        }
        field(6; "Parent Entry No."; Integer)
        {
        }
        field(10; "Test Name"; Text[100])
        {
        }
        field(11; Severity; Option)
        {
            OptionMembers = Information,Warning,Failed,Success;
        }
        field(12; Description; Text[100])
        {
        }
        field(13; Level; Integer)
        {
        }
        field(14; "Codeunit No."; Integer)
        {
        }
        field(15; "Page No."; Integer)
        {
        }
        field(17; "Company Name"; Text[30])
        {
        }
        field(20; "Log Message"; Text[250])
        {
        }
        field(21; "Log Message 2"; Text[250])
        {
        }
        field(22; "Log Message 3"; Text[250])
        {
        }
        field(23; "Log Message 4"; Text[250])
        {
        }
    }

    keys
    {
        key(Key1; "Session ID", "Source Type", "Source No.", "Entry No.")
        {
        }
    }
}

