page 37002193 "Split Deduction Line"
{
    // PR3.70.08
    // P8000170A, Myers Nissi, Jack Reynolds, 31 JAN 05
    //   Deduction Management
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 30 JAN 09
    //   Transformed from Form
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Split Deduction Line';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            field(CurrentLineAmount; CurrentLineAmount)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Current Amount';
                Editable = false;
            }
            field("New Amounts"; '')
            {
                ApplicationArea = FOODBasic;
                Caption = 'New Amounts';
                Style = Strong;
                StyleExpr = TRUE;
            }
            field(CurrentLineNewAmount; CurrentLineNewAmount)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Current Line';
                MinValue = 0;

                trigger OnValidate()
                begin
                    if CurrentLineNewAmount > CurrentLineAmount then
                        Error(Text001, CurrentLineAmount);
                    NewLineAmount := CurrentLineAmount - CurrentLineNewAmount;
                end;
            }
            field(NewLineAmount; NewLineAmount)
            {
                ApplicationArea = FOODBasic;
                Caption = 'New Line';
                MinValue = 0;

                trigger OnValidate()
                begin
                    if NewLineAmount > CurrentLineAmount then
                        Error(Text001, CurrentLineAmount);
                    CurrentLineNewAmount := CurrentLineAmount - NewLineAmount;
                end;
            }
        }
    }

    actions
    {
    }

    var
        CurrentLineAmount: Decimal;
        CurrentLineNewAmount: Decimal;
        NewLineAmount: Decimal;
        Text001: Label 'The maximum permitted value is %1.';
        Text19013494: Label 'Current Amount';
        Text19050045: Label 'New Amount';

    procedure SetAmount(Amt: Decimal)
    begin
        CurrentLineAmount := Amt;
        CurrentLineNewAmount := Amt;
    end;

    procedure GetNewAmount(): Decimal
    begin
        exit(CurrentLineNewAmount);
    end;
}

