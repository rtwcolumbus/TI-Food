page 37002159 "Accrual Plan Details FactBox"
{
    // PR3.70.05
    // P8000066A, Myers Nissi, Jack Reynolds, 29 JUN 04
    //   Resized tab control
    // 
    // PR3.70.06
    // P8000117A, Myers Nissi, Jack Reynolds, 15 SEP 04
    //   Resize tab control and form to accomodate subform on accrual tab
    // 
    // PR3.70.07
    // P8000119A, Myers Nissi, Don Bresee, 20 SEP 04
    //   Accruals update/fixes
    // 
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PR4.00.04
    // P8000355A, VerticalSoft, Jack Reynolds, 19 JUL 06
    //   Add support for accrual groups
    // 
    // PRW16.00.02
    // P8000664, VerticalSoft, Jimmy Abidi, 02 NOV 09
    //   New FactBox Page for Accrual Plan Details
    // 
    // PRW16.00.03
    // P8000810, VerticalSoft, Don Bresee, 11 APR 10
    //   Rework FactBox, group fields
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Accrual Plan Details';
    PageType = CardPart;
    SourceTable = "Accrual Plan";

    layout
    {
        area(content)
        {
            field("No."; "No.")
            {
                ApplicationArea = FOODBasic;
            }
            field("Accrual Amount"; "Accrual Amount")
            {
                ApplicationArea = FOODBasic;
            }
            field("Payment Amount"; "Payment Amount")
            {
                ApplicationArea = FOODBasic;
            }
            field(Balance; Balance)
            {
                ApplicationArea = FOODBasic;
            }
            group(Estimates)
            {
                Caption = 'Estimates';
                field("Estimated Accrual Amount"; "Estimated Accrual Amount")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Accruals';
                    DrillDown = false;
                }
                field("Accrual Charge Amount"; "Accrual Charge Amount")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Charges';

                    trigger OnDrillDown()
                    begin
                        ChargesDrillDown;
                        CurrPage.Update;
                    end;
                }
                field("GetEstimatedAccrualAmount()"; GetEstimatedAccrualAmount())
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Total';
                    DrillDown = false;
                }
            }
            group("Accrual Schedule")
            {
                Caption = 'Accrual Schedule';
                field("Use Accrual Schedule"; "Use Accrual Schedule")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Use Schedule';

                    trigger OnValidate()
                    begin
                        CurrPage.Update;                // P8000664
                    end;
                }
                field("Scheduled Accrual Amount"; "Scheduled Accrual Amount")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Scheduled Amount';

                    trigger OnDrillDown()
                    begin
                        ShowScheduleLines(0);
                        CurrPage.Update;
                    end;
                }
            }
            group("Payment Schedule")
            {
                Caption = 'Payment Schedule';
                field("Use Payment Schedule"; "Use Payment Schedule")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Use Schedule';
                }
                field("Scheduled Payment Amount"; "Scheduled Payment Amount")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Scheduled Amount';

                    trigger OnDrillDown()
                    begin
                        ShowScheduleLines(1);
                        CurrPage.Update;
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Type := Type::Sales;
    end;

    local procedure ChargesDrillDown()
    var
        AccrualChargeLine: Record "Accrual Charge Line";
    begin
        AccrualChargeLine.SetRange("Accrual Plan Type", Type);
        AccrualChargeLine.SetRange("Accrual Plan No.", "No.");
        PAGE.RunModal(0, AccrualChargeLine);
    end;
}

