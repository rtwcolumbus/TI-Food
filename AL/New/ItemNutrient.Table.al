table 37002862 "Item Nutrient"
{
    // PRW16.00.04
    // P8000868, VerticalSoft, Rick Tweedle, 13 SEP 10
    //   Created for Genesis Enhancements

    ObsoleteState = Removed;

    fields
    {
        field(1; "Item No."; Code[20])
        {
        }
        field(2; "Nutrient No."; Integer)
        {
        }
        field(3; Value; Decimal)
        {
        }
        field(4; "Unapproved Item"; Boolean)
        {
        }
    }

    keys
    {
        key(Key1; "Item No.", "Unapproved Item", "Nutrient No.")
        {
        }
    }
}

