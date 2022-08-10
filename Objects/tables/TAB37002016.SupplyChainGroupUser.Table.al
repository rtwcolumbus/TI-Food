table 37002016 "Supply Chain Group User"
{
    // PRW16.00.05
    // P8000931, Columbus IT, Jack Reynolds, 20 APR 11
    //   Support for Supply Chain Groups
    // 
    // PRW17.00.01
    // P8001154, Columbus IT, Jack Reynolds, 28 MAY 13
    //   Enlarge User ID field
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property

    Caption = 'Supply Chain Group User';

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            NotBlank = true;
            TableRelation = User."User Name";
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                UserSelection: Codeunit "User Selection";
                User: Record User;
            begin
                // P800-MegaApp
                if UserSelection.Open(User) then
                    "User ID" := User."User Name";
            end;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("User ID");
            end;
        }
        field(2; "Supply Chain Group Code"; Code[10])
        {
            Caption = 'Supply Chain Group Code';
            NotBlank = true;
            TableRelation = "Supply Chain Group";
        }
    }

    keys
    {
        key(Key1; "User ID", "Supply Chain Group Code")
        {
        }
        key(Key2; "Supply Chain Group Code")
        {
        }
    }

    fieldgroups
    {
    }
}

