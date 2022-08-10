table 37002874 "Data Coll. Alert Group Member"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.00.01
    // P8001154, Columbus IT, Jack Reynolds, 28 MAY 13
    //   Enlarge User ID field
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property

    Caption = 'Data Coll. Alert Group Member';

    fields
    {
        field(1; "Group Code"; Code[10])
        {
            Caption = 'Group Code';
            NotBlank = true;
            TableRelation = "Data Collection Alert Group";
        }
        field(2; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
        }
        field(3; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            NotBlank = true;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
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
            begin
                UserSelection.ValidateUserName("User ID");
            end;
        }
    }

    keys
    {
        key(Key1; "Group Code", "Location Code", "User ID")
        {
        }
    }

    fieldgroups
    {
    }

    var
        UserSelection: Codeunit "User Selection";
}

