table 37002884 "My Alert"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.00.01
    // P8001154, Columbus IT, Jack Reynolds, 20 MAY 13
    //   Enlarge User ID field
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property

    Caption = 'My Alert';

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(2; "Alert Entry No."; Integer)
        {
            Caption = 'Alert Entry No.';
            TableRelation = "Data Collection Alert";
        }
    }

    keys
    {
        key(Key1; "User ID", "Alert Entry No.")
        {
        }
        key(Key2; "Alert Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

