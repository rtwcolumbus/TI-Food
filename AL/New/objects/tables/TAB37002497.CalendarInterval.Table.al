table 37002497 "Calendar Interval"
{
    ObsoleteState = Removed;
    ObsoleteReason = 'Part of Visual Production Sequencer not migrated from C/AL to AL';
    ObsoleteTag = 'FOOD-16';

    fields
    {
        field(1; "Calendar Code"; Code[10])
        {
        }
        field(2; "Line No."; Integer)
        {
        }
        field(3; "Work Shift Code"; Code[10])
        {
        }
        field(11; "Starting Date"; Date)
        {
        }
        field(12; "Starting Time"; Time)
        {
        }
        field(13; "Starting Date-Time"; DateTime)
        {
        }
        field(14; "Ending Date"; Date)
        {
        }
        field(15; "Ending Time"; Time)
        {
        }
        field(16; "Ending Date-Time"; DateTime)
        {
        }
        field(17; Duration; Decimal)
        {
        }
    }

    keys
    {
        key(Key1; "Calendar Code", "Line No.")
        {
        }
    }
}

