page 37002144 "Accrual Plan Stats. Subform"
{
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PR4.00.01
    // P8000274A, VerticalSoft, Jack Reynolds, 22 DEC 05
    //   Fix problems with resolving start and end dates for plan
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // P8000613A, VerticalSoft, Jack Reynolds, 18 JUL 08
    //   Resize to fit subform control on parent form
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 15 JAN 10
    //   Change Form Caption
    // 
    // P8000664, VerticalSoft, Jimmy Abidi, 15 JAN 10
    //   Transformed from Form
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Lines';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Accrual Ledger Entry";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Source No."; "Source No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source Name"; SourceName())
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Source Name';
                }
                field("Not In Plan"; NotInPlan())
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Not In Plan';
                }
                field("Accrual Amount"; AccrualAmount)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Accrual Amount';

                    trigger OnDrillDown()
                    begin
                        DetailDrillDown("Entry Type"::Accrual);
                    end;
                }
                field("Payment Amount"; PaymentAmount)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Payment Amount';

                    trigger OnDrillDown()
                    begin
                        DetailDrillDown("Entry Type"::Payment);
                    end;
                }
                field(Balance; AccrualAmount + PaymentAmount)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Balance';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        GetAmounts;
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        exit(DoNext(Steps));
    end;

    var
        AccrualPlan: Record "Accrual Plan";
        AccrualAmount: Decimal;
        PaymentAmount: Decimal;
        Text000: Label 'Scheduled Accruals';

    local procedure DoNext(NumSteps: Integer): Integer
    var
        SearchRec: Record "Accrual Ledger Entry";
        StepNo: Integer;
        Direction: Integer;
    begin
        SearchRec.Copy(Rec);
        SearchRec.SetCurrentKey("Accrual Plan Type", "Accrual Plan No.", "Source No.");
        Direction := 1;
        if (NumSteps < 0) then begin
            NumSteps := -NumSteps;
            Direction := -Direction;
        end;
        for StepNo := 1 to NumSteps do begin
            SearchRec.SetRange("Source No.", "Source No.");
            if (Direction > 0) then
                SearchRec.Find('+')
            else
                SearchRec.Find('-');
            SearchRec.SetRange("Source No.");
            if (SearchRec.Next(Direction) = 0) then
                exit((StepNo - 1) * Direction);
            Rec := SearchRec;
        end;
        exit(NumSteps * Direction);
    end;

    local procedure SourceName(): Text[250]
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        if ("Source No." = '') then
            exit(Text000);
        if "Accrual Plan Type" = "Accrual Plan Type"::Sales then begin
            Customer.Get("Source No.");
            exit(Customer.Name);
        end;
        Vendor.Get("Source No.");
        exit(Vendor.Name);
    end;

    local procedure SetLedgFilters(var AccrualLedgEntry: Record "Accrual Ledger Entry")
    begin
        AccrualLedgEntry.SetCurrentKey(
          "Accrual Plan Type", "Accrual Plan No.", "Source No.", "Entry Type",
          Type, "No.", "Item No.", "Posting Date");
        AccrualLedgEntry.SetRange("Accrual Plan Type", "Accrual Plan Type");
        AccrualLedgEntry.SetRange("Accrual Plan No.", "Accrual Plan No.");
        AccrualLedgEntry.SetRange("Source No.", "Source No.");
        FilterGroup(4);
        CopyFilter("Item No.", AccrualLedgEntry."Item No.");
        CopyFilter("Posting Date", AccrualLedgEntry."Posting Date");
        FilterGroup(0);
    end;

    local procedure GetAmounts()
    var
        AccrualLedgEntry: Record "Accrual Ledger Entry";
    begin
        SetLedgFilters(AccrualLedgEntry);
        AccrualLedgEntry.SetRange("Entry Type", AccrualLedgEntry."Entry Type"::Accrual);
        AccrualLedgEntry.CalcSums(Amount);
        AccrualAmount := AccrualLedgEntry.Amount;
        AccrualLedgEntry.SetRange("Entry Type", AccrualLedgEntry."Entry Type"::Payment);
        AccrualLedgEntry.CalcSums(Amount);
        PaymentAmount := AccrualLedgEntry.Amount;
    end;

    local procedure NotInPlan(): Boolean
    begin
        if ("Source No." = '') then
            exit(false);

        if ("Accrual Plan Type" <> AccrualPlan.Type) or
           ("Accrual Plan No." <> AccrualPlan."No.")
        then
            AccrualPlan.Get("Accrual Plan Type", "Accrual Plan No.");

        exit(not AccrualPlan.IsSourceInPlan("Source No.", "Source No.", 0D)); // P8000274A
    end;

    local procedure DetailDrillDown(EntryType: Integer)
    var
        AccrualLedgEntry: Record "Accrual Ledger Entry";
    begin
        SetLedgFilters(AccrualLedgEntry);
        AccrualLedgEntry.SetRange("Entry Type", EntryType);
        PAGE.RunModal(0, AccrualLedgEntry);
    end;
}

