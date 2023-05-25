page 37002122 "Accrual Plan Line Subform"
{
    // PR3.61AC
    // 
    // PR3.70.06
    // P8000117A, Myers Nissi, Jack Reynolds, 15 SEP 04
    //   Set the size of the table box and form to be the same
    // 
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

    Caption = 'Item Lines ';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Accrual Plan Line";

    layout
    {
        area(content)
        {
            repeater(Control37002001)
            {
                ShowCaption = false;
                field("Item Code"; "Item Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item Description"; GetLineDescription())
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Description';
                    Editable = false;
                }
                field("Minimum Value"; "Minimum Value")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Estimated Quantity"; "Estimated Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Computation UOM"; "Computation UOM")
                {
                    ApplicationArea = FOODBasic;
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
                field("Accrual Amount"; "Accrual Amount")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Reference Value"; "Reference Value")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Over Reference Value"; "Over Reference Value")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Multiplier Type"; "Multiplier Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Multiplier Value"; "Multiplier Value")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Estimated Ref. Unit Amount"; "Estimated Ref. Unit Amount")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Estimated Accrual Amount"; "Estimated Accrual Amount")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
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

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetUpNewLine(xRec);
    end;

    var
        AccrualPlan: Record "Accrual Plan";
        ItemSelection: Option "All Items","Specific Item","Item Category",Manufacturer,"Vendor No.","Accrual Group";
        MinValueType: Option Amount,Quantity;
        ComputationUOM: Code[10];

    procedure UpdateForm()
    begin
        CurrPage.Update(false);
    end;
}

