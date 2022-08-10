page 37002929 "Allergen Consumption Warning"
{
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Allergen Consumption Warning';
    InstructionalText = 'The following allergens are present in the consumption item that are not present in the output.  Continue?';
    PageType = ConfirmationDialog;
    SourceTable = Allergen;

    layout
    {
        area(content)
        {
            field(ItemNo; ItemNo)
            {
                ApplicationArea = FOODBasic;
                Caption = 'No.';
                Editable = false;
            }
            field(ItemDescription; ItemDescription)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Description';
                Editable = false;
            }
            repeater(Control37002002)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
    }

    var
        ItemNo: Code[20];
        ItemDescription: Text[100];

    procedure SetItem(No: Code[20]; Desc: Text[100])
    begin
        ItemNo := No;
        ItemDescription := Desc;
    end;
}

