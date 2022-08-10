table 11068734 "N108 Expression Argument"
{
    ObsoleteState = Removed;
    ObsoleteReason = 'Functionality was part of BIS';
    ObsoleteTag = 'FOOD-16';

    fields
    {
        field(1; "Expression ID"; Guid)
        {
        }
        field(2; "Parent Line No."; Integer)
        {
        }
        field(3; "Code"; Text[30])
        {
        }
        field(4; Type; Option)
        {
            OptionMembers = Text,"Field",Member,Parameter,Value;
        }
        field(7; "Text Value"; Text[250])
        {
        }
        field(8; Description; Text[50])
        {
        }
        field(10; "Table No."; Integer)
        {
        }
        field(11; "Table Name"; Text[50])
        {
        }
        field(12; "Field No."; Integer)
        {
        }
        field(13; "Field Name"; Text[50])
        {
        }
        field(15; "Input Line"; Integer)
        {
        }
        field(20; "Seq No."; Integer)
        {
        }
    }

    keys
    {
        key(Key1; "Expression ID", "Parent Line No.", "Code")
        {
        }
    }
}

