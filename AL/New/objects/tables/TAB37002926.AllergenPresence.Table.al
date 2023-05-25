table 37002926 "Allergen Presence"
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
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Allergen Presence';
    ReplicateData = false;

    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'Items,Unapproved Items,BOMs';
            OptionMembers = Items,"Unapproved Items",BOMs;
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = SystemMetadata;
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }
        field(5; Presence; Option)
        {
            Caption = 'Presence';
            DataClassification = SystemMetadata;
            OptionCaption = ',,,May Contain,,,,Allergen';
            OptionMembers = ,,,"May Contain",,,,Allergen;
        }
        field(6; Direct; Boolean)
        {
            Caption = 'Direct';
            DataClassification = SystemMetadata;
        }
        field(11; "Record Count"; Integer)
        {
            Caption = 'Record Count';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; Type, "No.")
        {
        }
    }

    fieldgroups
    {
    }
}

