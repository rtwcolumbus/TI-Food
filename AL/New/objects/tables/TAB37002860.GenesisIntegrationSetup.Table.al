table 37002860 "Genesis Integration Setup"
{
    // PRW16.00
    // P8000678, VerticalSoft, Don Bresee, 23 FEB 09
    //   Genesis Integration setup data
    // 
    // P8000707, VerticalSoft, Don Bresee, 11 JUL 09
    //   Add more specific errors for non-existent files and directories
    // 
    // PRW16.00.04
    // P8000868, VerticalSoft, Rick Tweedle, 13 SEP 10
    //   Added Genesis Enhancements
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 16 NOV 15
    //   Page Management

    ObsoleteState = Removed;
    ObsoleteReason = 'Functionality moved to FOODESHA Extension App';
    ObsoleteTag = 'FOOD-16';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
        }
        field(2; "Data File Directory"; Text[250])
        {
        }
        field(3; "ESHAPort Application Path"; Text[250])
        {
        }
        field(4; "Data File Field Separator"; Option)
        {
            OptionMembers = Comma,Tab,Pipe;
        }
        field(5; "Data File Text Delimiter"; Option)
        {
            OptionMembers = "Double Quote",Pipe;
        }
        field(6; "EPF Directory"; Text[250])
        {
        }
        field(7; "New Item Import"; Text[50])
        {
        }
        field(8; "Update Item Import"; Text[50])
        {
        }
        field(9; "New Recipe Import"; Text[50])
        {
        }
        field(10; "Create Recipe Import"; Text[50])
        {
        }
        field(11; "Update Nutrient Import"; Text[50])
        {
        }
        field(12; "Export Nutrient Data"; Boolean)
        {
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }
}

