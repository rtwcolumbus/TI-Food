table 37002922 "Allergen Set Tree Node"
{
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens

    Caption = 'Allergen Set Tree Node';

    fields
    {
        field(1; "Parent Allergen Set ID"; Integer)
        {
            Caption = 'Parent Allergen Set ID';
        }
        field(2; "Allergen ID"; Integer)
        {
            Caption = 'Allergen ID';
        }
        field(3; Presence; Option)
        {
            Caption = 'Presence';
            OptionCaption = ',,,May Contain,,,,Allergen';
            OptionMembers = ,,,"May Contain",,,,Allergen;
        }
        field(4; "Allergen Set ID"; Integer)
        {
            AutoIncrement = true;
            Caption = 'Allergen Set ID';
        }
        field(5; "In Use"; Boolean)
        {
            Caption = 'In Use';
        }
    }

    keys
    {
        key(Key1; "Parent Allergen Set ID", "Allergen ID", Presence)
        {
        }
    }

    fieldgroups
    {
    }
}

