table 37002027 "Lot Age Category"
{
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Simple list of age categories
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Lot Age Category';
    LookupPageID = "Lot Aging Categories";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
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
        LotAgeProfileCat.Reset;
        LotAgeProfileCat.SetCurrentKey("Category Code");
        LotAgeProfileCat.SetRange("Category Code", Code);
        if LotAgeProfileCat.Find('-') then
            Error(Text001, TableCaption, Code, LotAgeProfile.TableCaption);
    end;

    var
        LotAgeProfile: Record "Lot Age Profile";
        LotAgeProfileCat: Record "Lot Age Profile Category";
        Text001: Label 'You cannot delete %1 %2 because there is at least one %3 that includes this category.';
}

