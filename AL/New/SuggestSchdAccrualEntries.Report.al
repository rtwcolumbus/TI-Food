report 37002130 "Suggest Schd. Accrual Entries"
{
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.03
    // P8000792, VerticalSoft, Rick Tweedle, 17 MAR 10
    //   Converted using TIF Editor
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW18.00.02
    // P8002745, To-Increase, Jack Reynolds, 30 Sep 15
    //   Support for accrual payment documents
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // PRW118.00.05
    // P80014660, To-Increase, Gangabhushan, 21 JUN 22
    //   CS00221661 | Suggest Accrual Payments Document No. Incorrect

    AdditionalSearchTerms = 'create scheduled accrual payment documents';
    ApplicationArea = FOODBasic;
    Caption = 'Suggest Scheduled Accrual Entries';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem(AccrualPlan; "Accrual Plan")
        {
            DataItemTableView = SORTING(Type, "No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = Type, "No.", "Computation Group";
            dataitem(AccrualPlanSchdLine; "Accrual Plan Schedule Line")
            {
                DataItemLink = "Accrual Plan Type" = FIELD(Type), "Accrual Plan No." = FIELD("No.");
                DataItemTableView = SORTING("Accrual Plan Type", "Accrual Plan No.", "Entry Type", "Scheduled Date");

                trigger OnAfterGetRecord()
                var
                    CustVend: Boolean;
                begin
                    CalcFields("Posted Amount");
                    if (SignedAmount(Amount) = "Posted Amount") then
                        CurrReport.Skip;

                    // P8002746
                    CustVend := AccrualPlan."Payment Type" in [AccrualPlan."Payment Type"::Customer, AccrualPlan."Payment Type"::Vendor];
                    if not RunFromJournal then begin
                        if CustVend then begin
                            AccrualCalcMgmt.CreateSchedPaymentDocLine(AccrualPlan, AccrualPlanSchdLine);
                        end;
                    end else
                        if not (AccrualPlan."Create Payment Documents" and CustVend) then
                            // P8002746
                            if UseAccrualDate then
                                AccrualCalcMgmt.CreateSchdAccrualJnlLine(
                                  AccrualPlan, "Scheduled Date", "Entry Type", "No.")
                            else
                                AccrualCalcMgmt.CreateSchdAccrualJnlLine(
                                  AccrualPlan, 0D, "Entry Type", "No.");
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Entry Type", NewEntryType);
                    SetRange("Scheduled Date", StartDate, EndDate);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                StatusWindow.Update(1, "No.");
            end;

            trigger OnPreDataItem()
            begin
                case NewEntryType of
                    AccrualJnlLine."Entry Type"::Accrual:
                        SetRange("Use Accrual Schedule", true);
                    AccrualJnlLine."Entry Type"::Payment:
                        begin                                          // P8002746
                            SetRange("Use Payment Schedule", true);
                            if not RunFromJournal then                   // P8002746
                                SetRange("Create Payment Documents", true); // P8002746
                        end;                                           // P8002746
                end;
                // P80014660
                if NewDocumentNo = '' then
                    Error(DocumentNoErr2);
                // P80014660
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field("Scheduled Start Date"; StartDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Scheduled Start Date';
                    }
                    field("Scheduled End Date"; EndDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Scheduled End Date';
                    }
                    field("Use Post Date from Schd."; UseAccrualDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Use Post Date from Schd.';
                        Visible = RunFromJournal;

                        trigger OnValidate()
                        begin
                            UpdateUseAccrualDate;
                        end;
                    }
                    field("Posting Date"; NewPostingDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Posting Date';
                        Enabled = NOT UseAccrualDate;
                        NotBlank = true;
                    }
                    field("Document No."; NewDocumentNo)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Document No.';
                        Visible = RunFromJournal;

                        // P80014660
                        trigger OnValidate()
                        begin
                            if NewDocumentNo <> '' then
                                if IncStr(NewDocumentNo) = '' then
                                    Error(DocumentNoErr);
                        end;
                        // P80014660                        
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            UseAccrualDate := RunFromJournal; // P8002746
            NewDocumentNo := AccrualJnlLine."Document No.";

            UpdateUseAccrualDate;
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        NewEntryType := AccrualJnlLine."Entry Type"::Payment; // P8002746
    end;

    trigger OnPreReport()
    begin
        if (EndDate = 0D) then
            Error(Text001);

        StatusWindow.Open(Text002);

        AccrualCalcMgmt.SetEntryInfo(NewPostingDate, NewDocumentNo);
    end;

    var
        StartDate: Date;
        EndDate: Date;
        [InDataSet]
        UseAccrualDate: Boolean;
        NewPostingDate: Date;
        NewDocumentNo: Code[20];
        NewEntryType: Integer;
        AccrualJnlLine: Record "Accrual Journal Line";
        StatusWindow: Dialog;
        AccrualCalcMgmt: Codeunit "Accrual Calculation Management";
        Text001: Label 'You must specify an End Date.';
        Text002: Label 'Generating Entries...\\Accrual Plan No.  #1##################';
        [InDataSet]
        RunFromJournal: Boolean;
        DocumentNoErr: Label 'The value in the Document No. field must have a number so that we can assign the next number in the series.'; // P80014660
        DocumentNoErr2: Label 'In the Document No. field, specify the document number to be used.'; // P80014660

    local procedure UpdateUseAccrualDate()
    begin
        // P8001132
        if UseAccrualDate then
            NewPostingDate := 0D
        else
            NewPostingDate := WorkDate;
    end;

    procedure SetJnlLine(var AccrualJnlLine2: Record "Accrual Journal Line"; NewEntryType2: Integer)
    begin
        AccrualJnlLine := AccrualJnlLine2;
        AccrualCalcMgmt.SetJnlLine(AccrualJnlLine);
        NewEntryType := NewEntryType2;
        RunFromJournal := true; // P8002746
    end;
}

