table 37002045 "Purchasing Group"
{
    // PR4.00.02
    // P8000312A, VerticalSoft, Jack Reynolds, 17 MAR 06
    //   New table of valid purchasing codes (used to categorize items)
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Purchasing Group';
    LookupPageID = "Purchasing Groups";

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
        Item.SetRange("Purchasing Group Code", Code);
        if Item.Find('-') then
            Error(Text37002000, TableCaption, Code, Item.TableCaption, FieldCaption(Code));
    end;

    var
        Text37002000: Label 'You cannot delete %1 %2 because there is at least one %3 that includes this %4.';
        Item: Record Item;
}

