table 37002923 "Allergen Set History"
{
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property

    Caption = 'Allergen Set History';

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2; "Table No."; Integer)
        {
            Caption = 'Table No.';
        }
        field(3; "Code 1"; Code[20])
        {
            Caption = 'Code 1';
        }
        field(4; "Code 2"; Code[20])
        {
            Caption = 'Code 2';
        }
        field(10; "Date and Time"; DateTime)
        {
            Caption = 'Date and Time';
        }
        field(11; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;

            trigger OnLookup()
            var
                UserSelection: Codeunit "User Selection";
                User: Record User;
            begin
                // P800-MegaApp
                if UserSelection.Open(User) then
                    "User ID" := User."User Name";
            end;
        }
        field(12; "Old Allergen Set ID"; Integer)
        {
            Caption = 'Old Allergen Set ID';
        }
        field(13; "New Allergen Set ID"; Integer)
        {
            Caption = 'New Allergen Set ID';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Table No.", "Code 1", "Code 2")
        {
        }
    }

    fieldgroups
    {
    }
}

