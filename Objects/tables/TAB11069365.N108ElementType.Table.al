table 11069365 "N108 Element Type"
{
    DataPerCompany = false;
    ObsoleteState = Removed;
    ObsoleteReason = 'Functionality was part of BIS';
    ObsoleteTag = 'FOOD-16';

    fields
    {
        field(2; "Code"; Code[20])
        {
        }
        field(10; Description; Text[250])
        {
        }
        field(11; "Setup Table No."; Integer)
        {
        }
        field(12; "Setup Table Name"; Text[30])
        {
        }
        field(13; "Setup Page No."; Integer)
        {
        }
        field(14; "Setup Page Name"; Text[30])
        {
        }
        field(15; "Activity Class Name"; Text[100])
        {
        }
        field(16; "Codeunit No."; Integer)
        {
        }
        field(17; "Codeunit Name"; Text[30])
        {
        }
        field(19; Type; Option)
        {
            OptionMembers = "Event",Activity,Endpoint;
        }
        field(20; "Config. Test Codeunit No."; Integer)
        {
        }
        field(21; "Config. Test Codeunit Name"; Text[30])
        {
        }
        field(22; "Xml Port No."; Integer)
        {
        }
        field(23; "Xml Port Name"; Text[30])
        {
        }
        field(24; Subtype; Option)
        {
            OptionMembers = " ",Reader,Writer,Periodic;
        }
        field(25; "Transaction Point"; Boolean)
        {
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }
}

