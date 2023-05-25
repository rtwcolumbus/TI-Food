table 37002025 "Lot Age Profile"
{
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Contains lot aging profiles which group together several lot aging caategories
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Lot Age Profile';
    LookupPageID = "Lot Aging Profiles";

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
        LotAgeProfileCat.SetRange("Profile Code", Code);
        LotAgeProfileCat.DeleteAll;

        ItemCat.SetRange("Lot Age Profile Code", Code);
        ItemCat.ModifyAll("Lot Age Profile Code", '');
    end;

    var
        LotAgeProfileCat: Record "Lot Age Profile Category";
        ItemCat: Record "Item Category";
}

