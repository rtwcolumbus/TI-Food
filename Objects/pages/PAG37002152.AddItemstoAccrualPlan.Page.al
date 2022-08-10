page 37002152 "Add Items to Accrual Plan"
{
    // PR4.00
    // P8000252A, Myers Nissi, Jack Reynolds, 20 OCT 05
    //   Simple form to enter minimum value for adding items to accrual plan lines
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 09 FEB 09
    //   Transformed from Form
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Add Items to Accrual Plan';
    PageType = Card;

    layout
    {
        area(content)
        {
            field(MinValue; MinValue)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Minimum Value';
                DecimalPlaces = 0 : 5;
                MinValue = 0;
            }
        }
    }

    actions
    {
    }

    var
        MinValue: Decimal;

    procedure GetMinValue(): Decimal
    begin
        exit(MinValue);
    end;
}

