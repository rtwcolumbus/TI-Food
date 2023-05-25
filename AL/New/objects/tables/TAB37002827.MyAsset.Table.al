table 37002827 "My Asset"
{
    // PRW16.00.20
    // P8000671, VerticalSoft, Jack Reynolds, 30 JAN 09
    //   Supports user lists of preferred assets for My Asset part on role centers
    // 
    // PRW17.00.01
    // P8001154, Columbus IT, Jack Reynolds, 21 MAY 13
    //    Enlarge User ID field
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'My Asset';

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
        field(2; "Asset No."; Code[20])
        {
            Caption = 'Asset No.';
            NotBlank = true;
            TableRelation = Asset;

            trigger OnValidate()
            var
                Asset: Record Asset;
            begin
                // P8007748
                Asset.Get("Asset No.");
                Description := Asset.Description;
                Type := Asset.Type;
                Status := Asset.Status;
                // P8007748
            end;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(4; Type; Option)
        {
            Caption = 'Type';
            Editable = false;
            OptionCaption = ' ,Equipment,Vehicle,Facility';
            OptionMembers = " ",Equipment,Vehicle,Facility;
        }
        field(5; Status; Option)
        {
            Caption = 'Status';
            Editable = false;
            OptionCaption = 'New,In Service,Out of Service,Deactivated';
            OptionMembers = New,"In Service","Out of Service",Deactivated;
        }
    }

    keys
    {
        key(Key1; "User ID", "Asset No.")
        {
        }
    }

    fieldgroups
    {
    }
}

