page 37002148 "Accrual Plan Schedule Lines"
{
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.00.01
    // P8001185, Columbus IT, Jack Reynolds, 18 JUL 13
    //   Fix problem with Editable property of page

    Caption = 'Accrual Plan Schedule Lines';
    DataCaptionFields = "Accrual Plan Type", "Accrual Plan No.";
    DelayedInsert = true;
    PageType = Worksheet;
    SourceTable = "Accrual Plan Schedule Line";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Accrual Plan Type"; "Accrual Plan Type")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Accrual Plan No."; "Accrual Plan No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Scheduled Date"; "Scheduled Date")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Posted Amount"; "Posted Amount")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
            }
            field("AccrualPlan.GetEstimatedAccrualAmount()"; AccrualPlan.GetEstimatedAccrualAmount())
            {
                ApplicationArea = FOODBasic;
                Caption = 'Estimated Accrual Amount';
                Editable = false;
            }
            field("Scheduled Accrual Amount"; AccrualPlan."Scheduled Accrual Amount")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Scheduled Accrual Amount';
                Editable = false;
                Visible = ScheduledAccrualAmountVisible;
            }
            field("Scheduled Payment Amount"; AccrualPlan."Scheduled Payment Amount")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Scheduled Payment Amount';
                Editable = false;
                Visible = ScheduledPaymentAmountVisible;
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(CreateButton)
            {
                ApplicationArea = FOODBasic;
                Caption = '&Create';
                Ellipsis = true;
                Enabled = CreateButtonEnable;
                Image = New;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    CreateAccruals: Report "Create Accrual Plan Schedule";
                begin
                    TestField("Accrual Plan No.");
                    CreateAccruals.SetPlan("Accrual Plan Type", "Accrual Plan No.", "Entry Type");
                    CreateAccruals.RunModal;
                    CurrPage.Update;
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        AccrualPlan.GetEstimatedTotals("Accrual Plan Type", "Accrual Plan No.");
    end;

    trigger OnInit()
    begin
        CreateButtonEnable := true;
        ScheduledAccrualAmountVisible := true;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if ("Accrual Plan Type" = xRec."Accrual Plan Type") and
           ("Accrual Plan No." = xRec."Accrual Plan No.")
        then begin
            AccrualSchdLine.Reset;
            AccrualSchdLine.SetRange("Accrual Plan Type", "Accrual Plan Type");
            AccrualSchdLine.SetRange("Accrual Plan No.", "Accrual Plan No.");
            AccrualSchdLine.SetRange("Entry Type", "Entry Type");
            if BelowxRec then
                AccrualSchdLine.SetFilter("Scheduled Date", '..%1', xRec."Scheduled Date")
            else
                AccrualSchdLine.SetFilter("Scheduled Date", '<%1', xRec."Scheduled Date");
            "No." := Format(AccrualSchdLine.Count + 1);
        end;
        AccrualPlan.GetEstimatedTotals("Accrual Plan Type", "Accrual Plan No.");
    end;

    trigger OnOpenPage()
    begin
        //CurrPage.EDITABLE := NOT CurrPage.LOOKUPMODE; // xxx
        if not CurrPage.Editable then
            CreateButtonEnable := false;

        FilterGroup(2);
        if (GetFilter("Entry Type") <> '') then
            if (GetRangeMin("Entry Type") = "Entry Type"::Payment) then begin
                ScheduledPaymentAmountVisible := true;
                ScheduledAccrualAmountVisible := false;
            end;
        FilterGroup(0);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CurrPage.LookupMode then // xxx
            exit;
        if AccrualPlan.EstimatedTotalsMatch(
             "Accrual Plan Type", "Accrual Plan No.", "Entry Type")
        then
            exit(true);
        if "Entry Type" = "Entry Type"::Payment then
            exit(
              Confirm(
                Text000, false,
                AccrualPlan.FieldCaption("Estimated Accrual Amount"),
                AccrualPlan.FieldCaption("Scheduled Payment Amount"),
                AccrualPlan.Type, AccrualPlan.TableCaption, AccrualPlan."No."));
        exit(
          Confirm(
            Text000, false,
            AccrualPlan.FieldCaption("Estimated Accrual Amount"),
            AccrualPlan.FieldCaption("Scheduled Accrual Amount"),
            AccrualPlan.Type, AccrualPlan.TableCaption, AccrualPlan."No."));
    end;

    var
        AccrualSchdLine: Record "Accrual Plan Schedule Line";
        AccrualPlan: Record "Accrual Plan";
        Text000: Label 'The %1 and %2 for %3 %4 %5 are not the same.\\Do you still want to close the form?';
        [InDataSet]
        ScheduledPaymentAmountVisible: Boolean;
        [InDataSet]
        ScheduledAccrualAmountVisible: Boolean;
        [InDataSet]
        CreateButtonEnable: Boolean;
        Text001: Label '%1 must be specified.';
}

