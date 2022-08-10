report 37002123 "Suggest Purchase Payments"
{
    // PR3.61AC
    // 
    // PR4.00.01
    // P8000274A, VerticalSoft, Jack Reynolds, 22 DEC 05
    //   Fix problems with resolving start and end dates for plan and ship-to codes
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 09 AUG 07
    //   Remove unused section
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.03
    // P8000792, VerticalSoft, Rick Tweedle, 17 MAR 10
    //   Converted using TIF Editor
    // 
    // PRW17.10
    // P8001237, Columbus IT, Don Bresee, 31 OCT 13
    //   Move logic to reduce the payment amount with the posted amount
    // 
    // PRW18.00.02
    // P8002745, To-Increase, Jack Reynolds, 30 Sep 15
    //   Support for accrual payment documents
    // 
    // P8004919, To-Increase, Jack Reynolds, 03 NOV 15
    //   Remove filtering of accrual entries by starting date
    // 
    // PRW19.00.01
    // P8006985, To-Increase, Jack Reynolds, 12 MAY 16
    //   Fix adjustment for posted payments
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // PRW118.00.05
    // P80014660, To-Increase, Gangabhushan, 21 JUN 22
    //   CS00221661 | Suggest Accrual Payments Document No. Incorrect

    ApplicationArea = FOODBasic;
    Caption = 'Suggest Purchase Accrual Payments';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem(AccrualPlan; "Accrual Plan")
        {
            DataItemTableView = SORTING(Type, "No.") WHERE(Type = CONST(Purchase), "Plan Type" = FILTER(<> Reporting));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Computation Group";
            RequestFilterHeading = 'Purchase Accrual Plan';
            dataitem(VendorLoop; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                PrintOnlyIfDetail = true;
                dataitem(AccrualLedgEntry; "Accrual Ledger Entry")
                {
                    DataItemTableView = SORTING("Accrual Plan Type", "Accrual Plan No.", "Entry Type", "Source No.", Type, "No.", "Source Document Type", "Source Document No.", "Source Document Line No.", "Item No.", "Posting Date") WHERE("Accrual Plan Type" = CONST(Purchase), "Entry Type" = CONST(Accrual), Type = CONST(Vendor));

                    trigger OnAfterGetRecord()
                    begin
                        if (AccrualPlan."Accrual Posting Level" < AccrualPlan."Accrual Posting Level"::Document) then // P8002746
                            StatusWindow.Update(3, Text004)                                                             // P8002746
                        else begin                                                                                    // P8002746
                            StatusWindow.Update(3, "Source Document No.");
                            SetRange("Source Document Type", "Source Document Type");
                            SetRange("Source Document No.", "Source Document No.");
                            if (AccrualPlan."Accrual Posting Level" = AccrualPlan."Accrual Posting Level"::"Document Line") then // P8002746
                                SetRange("Source Document Line No.", "Source Document Line No.");
                        end;                                                                                          // P8002746
                        Find('+');
                        CalcSums(Amount);
                        //AccrualCalcMgmt.AdjustForPreviousPayments(AccrualPlan,AccrualLedgEntry); // P8001237, P8002746

                        if (Amount <> 0) then begin // P8001237
                            if not AccrualPlan."Post Accrual w/ Document" then
                                AccrualCalcMgmt.GetPaymentDistribution(
                                  "Accrual Plan Type", "Accrual Plan No.", "Source No.", -Amount, TempJnlLine)
                            else begin
                                AccrualCalcMgmt.GetPostedPaymentDistribution(AccrualLedgEntry, TempJnlLine);
                                if not TempJnlLine.Find('-') then
                                    AccrualCalcMgmt.GetPaymentDistribution(
                                      "Accrual Plan Type", "Accrual Plan No.", "Source No.", -Amount, TempJnlLine);
                            end;

                            if TempJnlLine.Find('-') then
                                repeat
                                        // P8002746
                                        case AccrualPlan."Payment Posting Level" of
                                            AccrualPlan."Payment Posting Level"::Plan:
                                                AddPlanLine('', 0, '', 0);
                                            AccrualPlan."Payment Posting Level"::Source:
                                                AddPlanLine("Source No.", 0, '', 0);
                                            AccrualPlan."Payment Posting Level"::Document:
                                                AddPlanLine("Source No.", "Source Document Type", "Source Document No.", 0);
                                            AccrualPlan."Payment Posting Level"::"Document Line":
                                                AddPlanLine("Source No.", "Source Document Type", "Source Document No.", "Source Document Line No.");
                                        end;
                                    TempJnlLine.Delete;
                                // P8002746
                                until (TempJnlLine.Next = 0);
                        end; // P8001237

                        SetRange("Source Document Type");
                        SetRange("Source Document No.");
                        SetRange("Source Document Line No.");
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange("Accrual Plan No.", AccrualPlan."No.");
                        SetRange("Source No.", Vendor."No.");
                        if EndDate <> 0D then                  // P8004919
                            SetRange("Posting Date", 0D, EndDate); // P8004919
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if not AccrualCalcMgmt.GetVendor(Vendor, AccrualSourceLine, AccrualPlan, Number = 1) then // P8000274A
                        CurrReport.Break;

                    // P8002746
                    if Vendor.Mark then
                        CurrReport.Skip
                    else
                        Vendor.Mark(true);
                    // P8002746

                    StatusWindow.Update(2, Vendor."No.");
                end;

                trigger OnPostDataItem()
                begin
                    CreatePlanLines; // P8002746
                end;

                trigger OnPreDataItem()
                begin
                    AccrualCalcMgmt.PrepareVendor(Vendor, VendorFilters, AccrualPlan);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                StatusWindow.Update(1, "No.");
            end;

            trigger OnPreDataItem()
            begin
                // P8002746
                if not RunFromJournal then
                    SetRange("Create Payment Documents", true);
                // P8002746
                // P80014660
                if NewDocumentNo = '' then
                    Error(DocumentNoErr2);
                // P80014660
            end;
        }
        dataitem(SearchVendor; Vendor)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.";

            trigger OnPreDataItem()
            begin
                CurrReport.Break;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field("Accrual End Date"; EndDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Accrual End Date';
                    }
                    field("Posting Date"; NewPostingDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Posting Date';
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
            NewDocumentNo := AccrualJnlLine."Document No.";

            if (NewPostingDate = 0D) then
                NewPostingDate := WorkDate;
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        VendorFilters.CopyFilters(SearchVendor);

        StatusWindow.Open(Text003);

        AccrualCalcMgmt.SetEntryInfo(NewPostingDate, NewDocumentNo);
    end;

    var
        EndDate: Date;
        NewPostingDate: Date;
        NewDocumentNo: Code[20];
        VendorFilters: Record Vendor;
        Vendor: Record Vendor;
        AccrualSourceLine: Record "Accrual Plan Source Line";
        AccrualJnlLine: Record "Accrual Journal Line";
        StatusWindow: Dialog;
        AccrualCalcMgmt: Codeunit "Accrual Calculation Management";
        Text003: Label 'Generating Entries...\\Accrual Plan No.  #1##################\Vendor No.        #2##################\Document No.      #3##################';
        TempJnlLine: Record "Accrual Journal Line" temporary;
        TempPlanJnlLine: Record "Accrual Journal Line" temporary;
        TempPlanJnlLineNo: Integer;
        [InDataSet]
        RunFromJournal: Boolean;
        Text004: Label 'All Documents';
        DocumentNoErr: Label 'The value in the Document No. field must have a number so that we can assign the next number in the series.'; // P80014660
        DocumentNoErr2: Label 'In the Document No. field, specify the document number to be used.'; // P80014660

    procedure SetJnlLine(var AccrualJnlLine2: Record "Accrual Journal Line")
    begin
        AccrualJnlLine := AccrualJnlLine2;
        AccrualCalcMgmt.SetJnlLine(AccrualJnlLine);
        RunFromJournal := true; // P8002746
    end;

    procedure AddPlanLine(SourceNo: Code[20]; SourceDocType: Integer; SourceDocNo: Code[20]; SourceDocLineNo: Integer)
    begin
        // P8002746
        if TempJnlLine.Type in [TempJnlLine.Type::Customer, TempJnlLine.Type::Vendor] then begin
            if RunFromJournal = AccrualPlan."Create Payment Documents" then
                exit;
        end else
            if not RunFromJournal then
                exit;
        TempPlanJnlLine.SetRange(Type, TempJnlLine.Type);
        TempPlanJnlLine.SetRange("No.", TempJnlLine."No.");
        TempPlanJnlLine.SetRange("Source No.", SourceNo);
        TempPlanJnlLine.SetRange("Source Document Type", SourceDocType);
        TempPlanJnlLine.SetRange("Source Document No.", SourceDocNo);
        TempPlanJnlLine.SetRange("Source Document Line No.", SourceDocLineNo);
        if TempPlanJnlLine.Find('-') then begin
            TempPlanJnlLine.Amount := TempPlanJnlLine.Amount + TempJnlLine.Amount;
            TempPlanJnlLine.Modify;
        end else begin
            TempPlanJnlLine := TempJnlLine;
            TempPlanJnlLineNo := TempPlanJnlLineNo + 1;
            TempPlanJnlLine."Line No." := TempPlanJnlLineNo;
            TempPlanJnlLine."Source No." := SourceNo;
            TempPlanJnlLine."Source Document Type" := SourceDocType;
            TempPlanJnlLine."Source Document No." := SourceDocNo;
            TempPlanJnlLine."Source Document Line No." := SourceDocLineNo;
            TempPlanJnlLine.Insert;
        end;
    end;

    procedure CreatePlanLines()
    begin
        // P8002746
        TempPlanJnlLine.Reset;
        TempPlanJnlLine.SetRange(Amount, 0);
        TempPlanJnlLine.DeleteAll;
        TempPlanJnlLine.Reset;
        if TempPlanJnlLine.Find('-') then
                repeat
                    AccrualCalcMgmt.AdjustForPreviousPayments(AccrualPlan, TempPlanJnlLine); // P8001237, P8006985
                    if TempPlanJnlLine.Amount <> 0 then
                        if RunFromJournal then
                            AccrualCalcMgmt.CreatePaymentJnlLine(
                              AccrualPlan, TempPlanJnlLine.Amount, TempPlanJnlLine."Source No.",
                              TempPlanJnlLine.Type, TempPlanJnlLine."No.", TempPlanJnlLine."Source Document Type",
                              TempPlanJnlLine."Source Document No.", TempPlanJnlLine."Source Document Line No.")
                        else
                            AccrualCalcMgmt.CreatePaymentDocLine(
                              AccrualPlan, TempPlanJnlLine.Amount, TempPlanJnlLine."Source No.",
                              TempPlanJnlLine.Type, TempPlanJnlLine."No.", TempPlanJnlLine."Source Document Type",
                              TempPlanJnlLine."Source Document No.", TempPlanJnlLine."Source Document Line No.");
                    TempPlanJnlLine.Delete;
                until (TempPlanJnlLine.Next = 0);
        Clear(TempPlanJnlLineNo);
    end;
}

