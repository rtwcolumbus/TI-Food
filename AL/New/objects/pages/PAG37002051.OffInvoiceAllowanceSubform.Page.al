page 37002051 "Off-Invoice Allowance Subform"
{
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Off-Invoice Allowance Subform';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Off-Invoice Allowance Line";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Sales Type"; "Sales Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Sales Code"; "Sales Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Basis; Basis)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Method; Method)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Ending Date"; "Ending Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Minimum Quantity"; "Minimum Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Tax Excludes Allowance"; "Tax Excludes Allowance")
                {
                    ApplicationArea = FOODBasic;
                }
                field("G/L Account"; "G/L Account")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetupNewLine(xRec);
    end;
}

