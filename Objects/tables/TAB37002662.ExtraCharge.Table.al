table 37002662 "Extra Charge"
{
    // PRW16.00.05
    // P8000928, Columbus IT, Jack Reynolds, 06 APR 11
    //   Support for extra charges on transfer orders
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Extra Charge';
    LookupPageID = "Extra Charge List";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Allocation Method"; Option)
        {
            Caption = 'Allocation Method';
            OptionCaption = ' ,Amount,Quantity,Weight,Volume';
            OptionMembers = " ",Amount,Quantity,Weight,Volume;
        }
        field(10; "Charge Caption"; Text[30])
        {
            Caption = 'Charge Caption';
        }
        field(11; "Vendor Caption"; Text[30])
        {
            Caption = 'Vendor Caption';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        DocExtraCharge.SetCurrentKey("Extra Charge Code");
        DocExtraCharge.SetRange("Extra Charge Code", Code);
        if DocExtraCharge.Find('-') then
            Error(Text001, TableCaption, Code);

        PostingSetup.SetCurrentKey("Extra Charge Code");
        PostingSetup.SetRange("Extra Charge Code", Code);
        PostingSetup.DeleteAll;
    end;

    var
        DocExtraCharge: Record "Document Extra Charge";
        Text001: Label '%1 ''%2'' is in use.';
        PostingSetup: Record "Extra Charge Posting Setup";
}

