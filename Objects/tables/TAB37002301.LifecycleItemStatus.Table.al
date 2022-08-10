table 37002301 "Lifecycle Item Status"
{
    ObsoleteState = Removed;
    ObsoleteReason = 'Functionality moved to FOODILM Extension App';
    ObsoleteTag = 'FOOD-16';

    fields
    {
        field(1; "Lifecycle No."; Code[20])
        {
        }
        field(2; "Version Code"; Code[10])
        {
        }
        field(3; "Code"; Code[20])
        {
        }
        field(5; "Available for Job"; Boolean)
        {
        }
        field(6; "Available for Purchase"; Boolean)
        {
        }
        field(7; "Available for Sales"; Boolean)
        {
        }
        field(8; "Available for Production"; Boolean)
        {
        }
        field(9; "Available for Service"; Boolean)
        {
        }
        field(10; "Create SKU"; Boolean)
        {
        }
        field(13; "No. of Instances"; Integer)
        {
        }
        field(19; "Available for Planning"; Boolean)
        {
        }
        field(25; "Pending Approval-Allergens"; Boolean)
        {
        }
        field(26; "Manual Change Disabled-Allerg."; Boolean)
        {
        }
    }

    keys
    {
        key(Key1; "Lifecycle No.", "Version Code", "Code")
        {
        }
    }
}

