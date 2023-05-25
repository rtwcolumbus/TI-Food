table 11068731 "N108 Temp Text"
{
    ObsoleteState = Removed;
    ObsoleteReason = 'Functionality was part of BIS';
    ObsoleteTag = 'FOOD-16';

    fields
    {
        field(1; ID; Guid)
        {
        }
        field(2; "Key"; Integer)
        {
        }
        field(10; "Text 1"; Text[250])
        {
        }
        field(11; "Text 2"; Text[250])
        {
        }
        field(15; Severity; Option)
        {
            OptionMembers = Info,Warning,Error;
        }
        field(16; "Integer Value 1"; Integer)
        {
        }
        field(17; "Boolean Value"; Boolean)
        {
        }
        field(18; "Text 3"; Text[250])
        {
        }
        field(19; "Date Time Value"; DateTime)
        {
        }
        field(22; "Integer Value 2"; Integer)
        {
        }
        field(30; "Decimal Value 1"; Decimal)
        {
        }
        field(31; "Decimal Value 2"; Decimal)
        {
        }
        field(32; "Decimal Value 3"; Decimal)
        {
        }
        field(33; "Decimal Value 4"; Decimal)
        {
        }
        field(34; "Decimal Value 5"; Decimal)
        {
        }
        field(35; "Decimal Value 6"; Decimal)
        {
        }
        field(36; "Decimal Value 7"; Decimal)
        {
        }
        field(40; "Time Value 1"; Time)
        {
        }
        field(41; "Time Value 2"; Time)
        {
        }
        field(45; "Date Value 1"; Date)
        {
        }
        field(100; "Table No."; Integer)
        {
        }
        field(101; "Parent Table No."; Integer)
        {
        }
        field(102; Level; Integer)
        {
        }
        field(103; "Block Name"; Text[50])
        {
        }
        field(104; "Relation Mapping ID."; Guid)
        {
        }
    }

    keys
    {
        key(Key1; ID, "Key")
        {
        }
    }
}

