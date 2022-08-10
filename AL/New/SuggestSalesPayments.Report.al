report 37002121 "Suggest Sales Payments"
{
    // PR3.61AC
    // 
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PR4.00.01
    // P8000274A, VerticalSoft, Jack Reynolds, 22 DEC 05
    //   Fix problems with resolving start and end dates for plan and ship-to codes
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.01
    // P8000732, VerticalSoft, Jack Reynolds, 05 NOV 09
    //   Fix problem with incorrect payment suggestion
    // 
    // PRW16.00.03
    // P8000792, VerticalSoft, Rick Tweedle, 17 MAR 10
    //   Converted using TIF Editor
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 20 FEB 13
    //   Restoring the SaveValues property in the Request Page.
    // 
    // PRW17.10
    // P8001236, Columbus IT, Don Bresee, 31 OCT 13
    //   Add logic for "Payment Posting Options" field
    // 
    // P8001237, Columbus IT, Don Bresee, 31 OCT 13
    //   Move logic to reduce the payment amount with the posted amount
    // 
    // PRW18.00.02
    // P8003887, To-Increase, Jack Reynolds, 23 Sep 15
    //   Fix problem with suggest payemnts with payment posting level
    // 
    // P8002745, To-Increase, Jack Reynolds, 30 Sep 15
    //   Support for accrual payment documents
    // 
    // P8004919, To-Increase, Jack Reynolds, 03 NOV 15
    //   Remove filtering of accrual entries by starting date
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // PRW118.00.05
    // P80014660, To-Increase, Gangabhushan, 21 JUN 22
    //   CS00221661 | Suggest Accrual Payments Document No. Incorrect

    AdditionalSearchTerms = 'create accrual payment documents';
    ApplicationArea = FOODBasic;
    Caption = 'Suggest Sales Accrual Payments';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem(AccrualPlan; "Accrual Plan")
        {
            DataItemTableView = SORTING(Type, "No.") WHERE(Type = CONST(Sales), "Plan Type" = FILTER(<> Reporting), "Use Payment Schedule" = CONST(false));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Computation Group";
            RequestFilterHeading = 'Sales Accrual Plan';
            dataitem(CustomerLoop; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                PrintOnlyIfDetail = true;
                dataitem(AccrualLedgEntry; "Accrual Ledger Entry")
                {
                    DataItemTableView = SORTING("Accrual Plan Type", "Accrual Plan No.", "Entry Type", "Source No.", Type, "No.", "Source Document Type", "Source Document No.", "Source Document Line No.", "Item No.", "Posting Date") WHERE("Accrual Plan Type" = CONST(Sales), "Entry Type" = CONST(Accrual), Type = CONST(Customer));

                    trigger OnAfterGetRecord()
                    begin
                        //IF (AccrualPlan."Payment Posting Level" < AccrualPlan."Payment Posting Level"::Document) THEN // P8000732
                        if (AccrualPlan."Accrual Posting Level" < AccrualPlan."Accrual Posting Level"::Document) then   // P8000732
                            StatusWindow.Update(3, Text004)
                        else begin
                            StatusWindow.Update(3, "Source Document No.");
                            SetRange("Source Document Type", "Source Document Type");
                            SetRange("Source Document No.", "Source Document No.");
                            //IF (AccrualPlan."Payment Posting Level" = AccrualPlan."Payment Posting Level"::"Document Line") THEN // P8000732
                            if (AccrualPlan."Accrual Posting Level" = AccrualPlan."Accrual Posting Level"::"Document Line") then   // P8000732
                                SetRange("Source Document Line No.", "Source Document Line No.");
                        end;
                        Find('+');
                        CalcSums(Amount);
                        AccrualCalcMgmt.AdjustForPaymentOptions(AccrualPlan, AccrualLedgEntry); // P8001236
                        //AccrualCalcMgmt.AdjustForPreviousPayments(AccrualPlan,AccrualLedgEntry); // P8001237, P8003887

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
                                        case AccrualPlan."Payment Posting Level" of
                                            AccrualPlan."Payment Posting Level"::Plan:
                                                AddPlanLine('', 0, '', 0); // P8000732
                                            AccrualPlan."Payment Posting Level"::Source:
                                                //AccrualCalcMgmt.CreatePaymentJnlLine(                                                 // P8000732
                                                //  AccrualPlan, TempJnlLine.Amount, "Source No.", TempJnlLine.Type, TempJnlLine."No.", // P8000732
                                                //  "Source Document Type"::None, '', 0);                                               // P8000732
                                                AddPlanLine("Source No.", 0, '', 0); // P8000732
                                            AccrualPlan."Payment Posting Level"::Document:
                                                //AccrualCalcMgmt.CreatePaymentJnlLine(                                                 // P8000732
                                                //  AccrualPlan, TempJnlLine.Amount, "Source No.", TempJnlLine.Type, TempJnlLine."No.", // P8000732
                                                //  "Source Document Type", "Source Document No.", 0);                                  // P8000732
                                                AddPlanLine("Source No.", "Source Document Type", "Source Document No.", 0); // P8000732
                                            AccrualPlan."Payment Posting Level"::"Document Line":
                                                // P8002746
                                                AddPlanLine("Source No.", "Source Document Type", "Source Document No.", "Source Document Line No.");
                                        //AccrualCalcMgmt.CreatePaymentJnlLine(
                                        //  AccrualPlan, TempJnlLine.Amount, "Source No.", TempJnlLine.Type, TempJnlLine."No.",
                                        //  "Source Document Type", "Source Document No.", "Source Document Line No.");
                                        // P8002746
                                        end;
                                        TempJnlLine.Delete;
                                    until (TempJnlLine.Next = 0);
                        end; // P8001237

                        SetRange("Source Document Type");
                        SetRange("Source Document No.");
                        SetRange("Source Document Line No.");
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange("Accrual Plan No.", AccrualPlan."No.");
                        SetRange("Source No.", Customer."No.");
                        if EndDate <> 0D then                  // P8004919
                            SetRange("Posting Date", 0D, EndDate); // P8004919
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if not AccrualCalcMgmt.GetCustomer(Customer, AccrualSourceLine, AccrualPlan, Number = 1) then
                        CurrReport.Break;

                    // P8000732
                    if Customer.Mark then
                        CurrReport.Skip
                    else
                        Customer.Mark(true);
                    // P8000732

                    StatusWindow.Update(2, Customer."No.");
                end;

                trigger OnPostDataItem()
                begin
                    CreatePlanLines; // P8002746
                end;

                trigger OnPreDataItem()
                begin
                    AccrualCalcMgmt.PrepareCustomer(Customer, CustomerFilters, AccrualPlan); // P8000274A
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
        dataitem(SearchCustomer; Customer)
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
        CustomerFilters.CopyFilters(SearchCustomer);

        StatusWindow.Open(Text003);

        AccrualCalcMgmt.SetEntryInfo(NewPostingDate, NewDocumentNo);
    end;

    var
        EndDate: Date;
        NewPostingDate: Date;
        NewDocumentNo: Code[20];
        CustomerFilters: Record Customer;
        Customer: Record Customer;
        AccrualSourceLine: Record "Accrual Plan Source Line";
        AccrualJnlLine: Record "Accrual Journal Line";
        StatusWindow: Dialog;
        AccrualCalcMgmt: Codeunit "Accrual Calculation Management";
        TempJnlLine: Record "Accrual Journal Line" temporary;
        TempPlanJnlLine: Record "Accrual Journal Line" temporary;
        TempPlanJnlLineNo: Integer;
        Text003: Label 'Generating Entries...\\Accrual Plan No.  #1##################\Customer No.      #2##################\Document No.      #3##################';
        Text004: Label 'All Documents';
        [InDataSet]
        RunFromJournal: Boolean;
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
        // P8000732 - Add parameters for SourceNo, SourceDocType, SourceDocNo, SourceDocLineNo
        // P8002746
        if TempJnlLine.Type in [TempJnlLine.Type::Customer, TempJnlLine.Type::Vendor] then begin
            if RunFromJournal = AccrualPlan."Create Payment Documents" then
                exit;
        end else
            if not RunFromJournal then
                exit;
        // P8002746
        TempPlanJnlLine.SetRange(Type, TempJnlLine.Type);
        TempPlanJnlLine.SetRange("No.", TempJnlLine."No.");
        // P8000732
        TempPlanJnlLine.SetRange("Source No.", SourceNo);
        TempPlanJnlLine.SetRange("Source Document Type", SourceDocType);
        TempPlanJnlLine.SetRange("Source Document No.", SourceDocNo);
        TempPlanJnlLine.SetRange("Source Document Line No.", SourceDocLineNo);
        // P8000732
        if TempPlanJnlLine.Find('-') then begin
            TempPlanJnlLine.Amount := TempPlanJnlLine.Amount + TempJnlLine.Amount;
            TempPlanJnlLine.Modify;
        end else begin
            TempPlanJnlLine := TempJnlLine;
            TempPlanJnlLineNo := TempPlanJnlLineNo + 1;
            TempPlanJnlLine."Line No." := TempPlanJnlLineNo;
            // P8000732
            TempPlanJnlLine."Source No." := SourceNo;
            TempPlanJnlLine."Source Document Type" := SourceDocType;
            TempPlanJnlLine."Source Document No." := SourceDocNo;
            TempPlanJnlLine."Source Document Line No." := SourceDocLineNo;
            // P8000732
            TempPlanJnlLine.Insert;
        end;
    end;

    procedure CreatePlanLines()
    begin
        TempPlanJnlLine.Reset;
        // P8001237
        TempPlanJnlLine.SetRange(Amount, 0);
        TempPlanJnlLine.DeleteAll;
        TempPlanJnlLine.Reset;
        // P8001237
        if TempPlanJnlLine.Find('-') then
            repeat
                    AccrualCalcMgmt.AdjustForPreviousPayments(AccrualPlan, TempPlanJnlLine); // P8001237, P8003887
                if TempPlanJnlLine.Amount <> 0 then                                     // P8003887
                    if RunFromJournal then // P8002746
                        AccrualCalcMgmt.CreatePaymentJnlLine(
                          AccrualPlan, TempPlanJnlLine.Amount, TempPlanJnlLine."Source No.",                   // P8000732
                          TempPlanJnlLine.Type, TempPlanJnlLine."No.", TempPlanJnlLine."Source Document Type", // P8000732
                          TempPlanJnlLine."Source Document No.", TempPlanJnlLine."Source Document Line No.")   // P8000732
                                                                                                               // P8002746
                    else
                        AccrualCalcMgmt.CreatePaymentDocLine(
                          AccrualPlan, TempPlanJnlLine.Amount, TempPlanJnlLine."Source No.",
                          TempPlanJnlLine.Type, TempPlanJnlLine."No.", TempPlanJnlLine."Source Document Type",
                          TempPlanJnlLine."Source Document No.", TempPlanJnlLine."Source Document Line No.");
                // P8002746
                TempPlanJnlLine.Delete;
            until (TempPlanJnlLine.Next = 0);
        Clear(TempPlanJnlLineNo);
    end;
}

