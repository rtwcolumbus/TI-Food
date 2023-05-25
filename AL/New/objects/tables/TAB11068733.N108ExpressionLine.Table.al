table 11068733 "N108 Expression Line"
{
    ObsoleteState = Removed;
    ObsoleteReason = 'Functionality was part of BIS';
    ObsoleteTag = 'FOOD-16';

    fields
    {
        field(1; "Expression ID"; Guid)
        {
        }
        field(2; "Line No."; Integer)
        {
        }
        field(3; Type; Option)
        {
            OptionMembers = Text,"Field","Function",Member,Parameter,Reference;
        }
        field(4; "Text Value"; Text[250])
        {
        }
        field(5; Arguments; Boolean)
        {
        }
        field(6; Postpone; Boolean)
        {
        }
        field(8; Description; Text[50])
        {
        }
        field(10; "Table No."; Integer)
        {
        }
        field(12; "Field No."; Integer)
        {
        }
        field(20; "Codeunit No."; Integer)
        {
        }
    }

    keys
    {
        key(Key1; "Expression ID", "Line No.")
        {
        }
    }
}

