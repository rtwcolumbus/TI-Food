page 37002846 "Work Order Sched. Activity"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   Standard subform to show planned work order activities with hours remaining
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 16 FEB 09
    //   Transformed - additions in TIF Editor
    //   Page changes made after transformation
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Work Order Sched. Activity';
    Editable = false;
    DeleteAllowed = false; // P800-MegaApp
    InsertAllowed = false; // P800-MegaApp
    PageType = ListPart;
    SourceTable = "Work Order Activity";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Trade Code"; "Trade Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Trade Description"; "Trade Description")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Required Date"; "Required Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Planned Hours Remaining"; "Planned Hours Remaining")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Hours Remaining';
                }
            }
        }
    }

    actions
    {
    }

    procedure Update()
    begin
        CurrPage.Update(false);
    end;
}

