table 37002036 "Lot No. Custom Format"
{
    // PRW17.10
    // P8001234, Columbus IT, Jack Reynolds, 01 NOV 13
    //    Support for custom lot number formats
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Lot No. Custom Format';
    LookupPageID = "Lot No. Custom Formats";

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
        Item.SetRange("Lot No. Assignment Method", Item."Lot No. Assignment Method"::Custom);
        Item.SetRange("Lot Nos.", Code);
        if not Item.IsEmpty then
            Error(Text001, TableCaption, Code, FieldCaption(Code));

        CustomFormatLine.SetRange("Custom Format Code", Code);
        CustomFormatLine.DeleteAll;
    end;

    var
        Item: Record Item;
        CustomFormatLine: Record "Lot No. Custom Format Line";
        Text001: Label 'You cannot delete %1 %2 because there is at least one item with that %3.';
}

