page 37002147 "Accrual Plan Source Subform"
{
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 03 NOV 09
    //   Page changes made after transformation
    // 
    // PRW16.00.04
    // P8000882, VerticalSoft, Ron Davidson, 22 NOV 10
    //   Added new field called Manual Entry for the users to check if they don't want the Batch Update process to touch this line.
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Source Lines';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Accrual Plan Source Line";

    layout
    {
        area(content)
        {
            repeater(Control37002001)
            {
                ShowCaption = false;
                field("Source Code"; "Source Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source Ship-to Code"; "Source Ship-to Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Source Description"; GetLineDescription())
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Source Description';
                    Editable = false;
                }
                field("Start Date"; "Start Date")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("End Date"; "End Date")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Manual Entry"; "Manual Entry")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnDeleteRecord(): Boolean
    begin
        if "Source Selection" = "Source Selection"::All then
            FieldError("Source Selection");
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetUpNewLine(xRec);
    end;

    var
        AccrualPlan: Record "Accrual Plan";
        SourceSelectionType: Option "Bill-to/Pay-to","Sell-to/Buy-from","Sell-to/Ship-to";
        SourceSelection: Option All,Specific,"Price Group","Accrual Group";

    procedure UpdateForm()
    begin
        CurrPage.Update(false);
    end;
}

