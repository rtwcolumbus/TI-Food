table 37002046 "Usage Formula"
{
    // PR4.00.02
    // P8000312A, VerticalSoft, Jack Reynolds, 17 MAR 06
    //   Formulas for projecting usage
    // 
    // PRW16.00
    // P8000639, VerticalSoft, Jack Reynolds, 18 NOV 08
    //   Add DropDown field group
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Usage Formula';
    LookupPageID = "Usage Formulas";

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
        field(3; Period; Option)
        {
            Caption = 'Period';
            OptionCaption = 'Day,Week,Month';
            OptionMembers = Day,Week,Month;
        }
        field(4; "No. of Periods"; Integer)
        {
            Caption = 'No. of Periods';
            InitValue = 1;
            MinValue = 1;
        }
        field(5; "Comparison Period Formula"; DateFormula)
        {
            Caption = 'Comparison Period Formula';
        }
        field(6; "Rounding Method"; Option)
        {
            Caption = 'Rounding Method';
            OptionCaption = '=,<,>';
            OptionMembers = "=","<",">";
        }
        field(7; "Rounding Precision"; Decimal)
        {
            Caption = 'Rounding Precision';
            DecimalPlaces = 0 : 5;
            InitValue = 1;
            MinValue = 0.00001;
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
        fieldgroup(DropDown; "Code", Description, "No. of Periods", Period)
        {
        }
    }

    trigger OnDelete()
    begin
        ItemCat.SetRange("Usage Formula", Code);
        if ItemCat.Find('-') then
            Error(Text37002000, TableCaption, Code, ItemCat.TableCaption, FieldCaption(Code));

        // P8007749
        // ProdGroup.SETRANGE("Usage Formula",Code);
        // IF ProdGroup.FIND('-') THEN
        //  ERROR(Text37002000,TABLECAPTION,Code,ProdGroup.TABLECAPTION,FIELDCAPTION(Code));
        // P8007749

        Item.SetRange("Usage Formula", Code);
        if Item.Find('-') then
            Error(Text37002000, TableCaption, Code, Item.TableCaption, FieldCaption(Code));

        SKU.SetRange("Usage Formula", Code);
        if SKU.Find('-') then
            Error(Text37002000, TableCaption, Code, SKU.TableCaption, FieldCaption(Code));
    end;

    var
        Text37002000: Label 'You cannot delete %1 %2 because there is at least one %3 that includes this %4.';
        ItemCat: Record "Item Category";
        Item: Record Item;
        SKU: Record "Stockkeeping Unit";
}

