table 37002924 "Allergen Rollup"
{
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Allergen Rollup';
    ReplicateData = false;

    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'Item,BOM,Variable,Unapproved';
            OptionMembers = Item,BOM,Variable,Unapproved;
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = SystemMetadata;
        }
        field(3; "Version Code"; Code[20])
        {
            Caption = 'Version Code';
            DataClassification = SystemMetadata;
        }
        field(4; Status; Option)
        {
            Caption = 'Status';
            DataClassification = SystemMetadata;
            OptionMembers = Direct,Indirect,Processing;
        }
        field(5; "Allergen Set ID"; Integer)
        {
            Caption = 'Allergen Set ID';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; Type, "No.", "Version Code")
        {
        }
    }

    fieldgroups
    {
    }
}

