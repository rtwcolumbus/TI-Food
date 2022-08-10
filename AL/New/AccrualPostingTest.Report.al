report 37002126 "Accrual Posting - Test" // Version: FOODNA
{
    // PR4.00.06
    // P8000473A, VerticalSoft, Jack Reynolds, 23 MAY 07
    //   Standard test report for accrual journal
    // 
    // PRW16.00.02
    // P8000744, VerticalSoft, Jack Reynolds, 20 NOV 09
    //   Fix false errors for Source Document Type
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 20 APR 10
    //   RTC Reporting Upgrade
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW17.10
    // P8001223, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Expand filter variables
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    DefaultLayout = RDLC;
    RDLCLayout = './layout/AccrualPostingTest.rdlc';

    Caption = 'Accrual Posting - Test';

    dataset
    {
        dataitem("Accrual Journal Batch"; "Accrual Journal Batch")
        {
            DataItemTableView = SORTING("Journal Template Name", Name);
            RequestFilterFields = "Journal Template Name", Name;
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            column(AccrualJnlBatchJnlTemplateName; "Journal Template Name")
            {
            }
            column(AccrualJnlBatchName; Name)
            {
            }
            column(AccrualJnlLineFilter; AccrualJnlLineFilter)
            {
            }
            dataitem("Accrual Journal Line"; "Accrual Journal Line")
            {
                DataItemLink = "Journal Template Name" = FIELD("Journal Template Name"), "Journal Batch Name" = FIELD(Name);
                DataItemTableView = SORTING("Journal Template Name", "Journal Batch Name", "Line No.");
                RequestFilterFields = "Posting Date";
                column(AccrualJnlLineJnlTemplateName; "Journal Template Name")
                {
                    IncludeCaption = true;
                }
                column(AccrualJnlLineJnlBatchName; "Journal Batch Name")
                {
                    IncludeCaption = true;
                }
                column(AccrualJnlLinePostingDate; "Posting Date")
                {
                    IncludeCaption = true;
                }
                column(AccrualJnlLineDocNo; "Document No.")
                {
                    IncludeCaption = true;
                }
                column(AccrualJnlLineAccrualPlanType; "Accrual Plan Type")
                {
                    IncludeCaption = true;
                }
                column(AccrualJnlLineAccrualPlanNo; "Accrual Plan No.")
                {
                    IncludeCaption = true;
                }
                column(AccrualJnlLineEntryType; "Entry Type")
                {
                    IncludeCaption = true;
                }
                column(AccrualJnlLineSourceNo; "Source No.")
                {
                    IncludeCaption = true;
                }
                column(AccrualJnlLineType; Type)
                {
                    IncludeCaption = true;
                }
                column(AccrualJnlLineNo; "No.")
                {
                    IncludeCaption = true;
                }
                column(AccrualJnlLineSourceDocType; "Source Document Type")
                {
                    IncludeCaption = true;
                }
                column(AccrualJnlLineSourceDocNo; "Source Document No.")
                {
                    IncludeCaption = true;
                }
                column(AccrualJnlLineItemNo; "Item No.")
                {
                    IncludeCaption = true;
                }
                column(AccrualJnlLineDesc; Description)
                {
                    IncludeCaption = true;
                }
                column(AccrualJnlLineAmount; Amount)
                {
                    IncludeCaption = true;
                }
                column(AccrualJnlLineBody; 'AccrualJournalLine Body')
                {
                }
                column(AccrualJnlLineLineNo; "Line No.")
                {
                }
                column(AccrualJnlTemplateType; AccrualJnlTemplate.Type)
                {
                }
                column(NoOfEntries1; NoOfEntries[1])
                {
                }
                column(NoOfEntries2; NoOfEntries[2])
                {
                }
                column(TotalAmounts1; TotalAmounts[1])
                {
                }
                column(TotalAmounts2; TotalAmounts[2])
                {
                }
                column(AccrualJnlLineScheduledAccrualNo; "Scheduled Accrual No.")
                {
                    IncludeCaption = true;
                }
                column(EntryTypeDesc1; EntryTypeDescription[1])
                {
                }
                column(EntryTypeDesc2; EntryTypeDescription[2])
                {
                }
                dataitem(DimensionLoop; "Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                    column(DimText; DimText)
                    {
                    }
                    column(DimensionLoopNumber; Number)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if Number = 1 then begin
                            if not DimSetEntry.FindSet then // P8001133
                                CurrReport.Break;
                        end else
                            if not Continue then
                                CurrReport.Break;

                        Clear(DimText);
                        Continue := false;
                        repeat
                            OldDimText := DimText;
                            if DimText = '' then
                                DimText := StrSubstNo('%1 - %2', DimSetEntry."Dimension Code", DimSetEntry."Dimension Value Code") // P8001133
                            else
                                DimText :=
                                  StrSubstNo(
                                    '%1; %2 - %3', DimText, DimSetEntry."Dimension Code", DimSetEntry."Dimension Value Code"); // P8001133
                            if StrLen(DimText) > MaxStrLen(OldDimText) then begin
                                DimText := OldDimText;
                                Continue := true;
                                exit;
                            end;
                        until (DimSetEntry.Next = 0); // P8001133
                    end;

                    trigger OnPreDataItem()
                    begin
                        if not ShowDim then
                            CurrReport.Break;
                        DimSetEntry.SetRange("Dimension Set ID", "Accrual Journal Line"."Dimension Set ID"); // P8001133
                    end;
                }
                dataitem(ErrorLoop; "Integer")
                {
                    DataItemTableView = SORTING(Number);
                    column(ErrorTextNumber; ErrorText[Number])
                    {
                    }
                    column(ErrorLoopNumber; Number)
                    {
                    }

                    trigger OnPostDataItem()
                    begin
                        ErrorCounter := 0;
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange(Number, 1, ErrorCounter);
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    NoOfEntries["Entry Type" + 1] := 1;
                    TotalAmounts["Entry Type" + 1] := Amount;

                    MakeRecurringTexts("Accrual Journal Line");

                    if EmptyLine then begin
                        AddError(StrSubstNo(Text001, FieldCaption("Accrual Plan No.")))
                    end else
                        if not AccrualPlan.Get("Accrual Plan Type", "Accrual Plan No.") then
                            AddError(
                              StrSubstNo(
                                Text002,
                                AccrualPlan.TableCaption, "Accrual Plan No."));

                    CheckRecurringLine("Accrual Journal Line");

                    if "Posting Date" = 0D then
                        AddError(StrSubstNo(Text001, FieldCaption("Posting Date")))
                    else begin
                        if "Posting Date" <> NormalDate("Posting Date") then
                            AddError(StrSubstNo(Text004, FieldCaption("Posting Date")));

                        if "Accrual Journal Batch"."No. Series" <> '' then
                            if NoSeries."Date Order" and ("Posting Date" < LastPostingDate) then
                                AddError(Text005);
                        LastPostingDate := "Posting Date";

                        // P80066030
                        if not Process800UtilityFunctions.CheckAllowedPostingDate("Posting Date") then
                            AddError(GetLastErrorText);
                        // P80066030
                    end;

                    if ("Document Date" <> 0D) then
                        if ("Document Date" <> NormalDate("Document Date")) then
                            AddError(StrSubstNo(Text004, FieldCaption("Document Date")));

                    if "Accrual Journal Batch"."No. Series" <> '' then begin
                        if (LastDocNo <> '') then
                            if ("Document No." <> LastDocNo) and ("Document No." <> IncStr(LastDocNo)) then
                                AddError(Text009);
                        LastDocNo := "Document No.";
                    end;

                    if Amount = 0 then
                        AddError(StrSubstNo(Text001, FieldCaption(Amount)));

                    case "Entry Type" of
                        "Entry Type"::Accrual:
                            if AccrualPlan."Use Accrual Schedule" then
                                if "Scheduled Accrual No." = '' then
                                    AddError(StrSubstNo(Text001, FieldCaption("Scheduled Accrual No.")))
                                else begin
                                    if Type <> "Accrual Plan Type" then
                                        AddError(StrSubstNo(Text007, FieldCaption(Type), FieldCaption("Accrual Plan Type"),
                                          FieldCaption("Entry Type"), "Entry Type"));
                                    if "No." = '' then
                                        AddError(StrSubstNo(Text001, FieldCaption("No.")))
                                end;
                        "Entry Type"::Payment:
                            begin
                                if AccrualPlan."Use Payment Schedule" then
                                    if "Scheduled Accrual No." = '' then
                                        AddError(StrSubstNo(Text001, FieldCaption("Scheduled Accrual No.")))
                                    else
                                        if "No." = '' then
                                            AddError(StrSubstNo(Text001, FieldCaption("No.")));
                                if (AccrualPlan."Plan Type" = AccrualPlan."Plan Type"::Reporting) then
                                    AddError(StrSubstNo(Text010, AccrualPlan.FieldCaption("Plan Type"), AccrualPlan."Plan Type",
                                      FieldCaption("Entry Type"), "Entry Type"));
                            end;
                    end;

                    case "Source Document Type" of
                        "Source Document Type"::Shipment,
                      "Source Document Type"::Receipt:
                            if (AccrualPlan.Accrue <> AccrualPlan.Accrue::"Shipments/Receipts") then
                                AddError(StrSubstNo(Text013, FieldCaption("Source Document Type"),
                                  SourceDocTypeDescription[1 + "Source Document Type"::Shipment], SourceDocTypeDescription[1 + "Source Document Type"::Receipt],
                                  AccrualPlan.TableCaption, AccrualPlan.FieldCaption(Accrue), AccrualPlan.Accrue));
                        "Source Document Type"::Invoice,
                      "Source Document Type"::"Credit Memo":
                            if (AccrualPlan.Accrue = AccrualPlan.Accrue::"Shipments/Receipts") then
                                AddError(StrSubstNo(Text013, FieldCaption("Source Document Type"),
                                  SourceDocTypeDescription[1 + "Source Document Type"::Invoice],
                                  SourceDocTypeDescription[1 + "Source Document Type"::"Credit Memo"],
                                  AccrualPlan.TableCaption, AccrualPlan.FieldCaption(Accrue), AccrualPlan.Accrue));
                    end;

                    if not AccrualPlan."Use Accrual Schedule" then
                        case AccrualPlan.GetPostingLevel("Entry Type") of
                            AccrualPlan."Accrual Posting Level"::Plan:
                                begin
                                    if "Source No." <> '' then
                                        AddError(StrSubstNo(Text012, FieldCaption("Source No."), Text015,
                                          AccrualPlan.TableCaption, AccrualPlan.FieldCaption("Accrual Posting Level"),
                                          PostingLevelDescription[1 + AccrualPlan."Accrual Posting Level"::Plan]));
                                    if "Source Document Type" <> "Source Document Type"::None then      // P8000744
                                        AddError(StrSubstNo(Text011, FieldCaption("Source Document Type"), // P8000744
                                          SourceDocTypeDescription[1 + "Source Document Type"::None],       // P8000744
                                          AccrualPlan.TableCaption, AccrualPlan.FieldCaption("Accrual Posting Level"),
                                          PostingLevelDescription[1 + AccrualPlan."Accrual Posting Level"::Plan]));
                                end;
                            AccrualPlan."Accrual Posting Level"::Source:
                                begin
                                    if "Source No." = '' then
                                        AddError(StrSubstNo(Text011, FieldCaption("Source No."), Text015,
                                          AccrualPlan.TableCaption, AccrualPlan.FieldCaption("Accrual Posting Level"),
                                          PostingLevelDescription[1 + AccrualPlan."Accrual Posting Level"::Source]));
                                    if "Source Document Type" <> "Source Document Type"::None then      // P8000744
                                        AddError(StrSubstNo(Text011, FieldCaption("Source Document Type"), // P8000744
                                          SourceDocTypeDescription[1 + "Source Document Type"::None],       // P8000744
                                          AccrualPlan.TableCaption, AccrualPlan.FieldCaption("Accrual Posting Level"),
                                          PostingLevelDescription[1 + AccrualPlan."Accrual Posting Level"::Source]));
                                end;
                            AccrualPlan."Accrual Posting Level"::Document:
                                begin
                                    if "Source No." = '' then
                                        AddError(StrSubstNo(Text011, FieldCaption("Source No."), Text015,
                                          AccrualPlan.TableCaption, AccrualPlan.FieldCaption("Accrual Posting Level"),
                                          PostingLevelDescription[1 + AccrualPlan."Accrual Posting Level"::Document]));
                                    if "Source Document Type" = 0 then
                                        AddError(StrSubstNo(Text011, FieldCaption("Source Document Type"), Text015,
                                          AccrualPlan.TableCaption, AccrualPlan.FieldCaption("Accrual Posting Level"),
                                          PostingLevelDescription[1 + AccrualPlan."Accrual Posting Level"::Document]));
                                    if "Source Document No." = '' then
                                        AddError(StrSubstNo(Text011, FieldCaption("Source Document No."), Text015,
                                          AccrualPlan.TableCaption, AccrualPlan.FieldCaption("Accrual Posting Level"),
                                          PostingLevelDescription[1 + AccrualPlan."Accrual Posting Level"::Document]));
                                    if "Source Document Line No." <> 0 then
                                        AddError(StrSubstNo(Text011, FieldCaption("Source Document Type"), 0,
                                          AccrualPlan.TableCaption, AccrualPlan.FieldCaption("Accrual Posting Level"),
                                          PostingLevelDescription[1 + AccrualPlan."Accrual Posting Level"::Document]));
                                    TestField("Source Document Line No.", 0);
                                end;
                            AccrualPlan."Accrual Posting Level"::"Document Line":
                                begin
                                    if "Source No." = '' then
                                        AddError(StrSubstNo(Text011, FieldCaption("Source No."), Text015,
                                          AccrualPlan.TableCaption, AccrualPlan.FieldCaption("Accrual Posting Level"),
                                          PostingLevelDescription[1 + AccrualPlan."Accrual Posting Level"::"Document Line"]));
                                    if "Source Document Type" = 0 then
                                        AddError(StrSubstNo(Text011, FieldCaption("Source Document Type"), Text015,
                                          AccrualPlan.TableCaption, AccrualPlan.FieldCaption("Accrual Posting Level"),
                                          PostingLevelDescription[1 + AccrualPlan."Accrual Posting Level"::"Document Line"]));
                                    if "Source Document No." = '' then
                                        AddError(StrSubstNo(Text011, FieldCaption("Source Document No."), Text015,
                                          AccrualPlan.TableCaption, AccrualPlan.FieldCaption("Accrual Posting Level"),
                                          PostingLevelDescription[1 + AccrualPlan."Accrual Posting Level"::"Document Line"]));
                                    if "Source Document Line No." = 0 then
                                        AddError(StrSubstNo(Text011, FieldCaption("Source Document Line No."), 0,
                                          AccrualPlan.TableCaption, AccrualPlan.FieldCaption("Accrual Posting Level"),
                                          PostingLevelDescription[1 + AccrualPlan."Accrual Posting Level"::"Document Line"]));
                                    if "Item No." = '' then
                                        AddError(StrSubstNo(Text011, FieldCaption("Item No."), Text015,
                                          AccrualPlan.TableCaption, AccrualPlan.FieldCaption("Accrual Posting Level"),
                                          PostingLevelDescription[1 + AccrualPlan."Accrual Posting Level"::"Document Line"]));
                                end;
                        end;

                    if not DimMgt.CheckDimIDComb("Dimension Set ID") then // P8001133
                        AddError(DimMgt.GetDimCombErr);

                    TableID[1] := DATABASE::"Accrual Plan";
                    No[1] := "Accrual Plan No.";
                    TableID[2] := TypeToTableID(Type);
                    No[2] := "No.";
                    TableID[3] := DATABASE::Item;
                    No[3] := "Item No.";
                    if not not DimMgt.CheckDimValuePosting(TableID, No, "Dimension Set ID") then // P8001133
                        AddError(DimMgt.GetDimValuePostingErr);
                end;

                trigger OnPreDataItem()
                begin
                    AccrualJnlTemplate.Get("Accrual Journal Batch"."Journal Template Name");
                    if AccrualJnlTemplate.Recurring then begin
                        if GetFilter("Posting Date") <> '' then
                            AddError(StrSubstNo(Text000, FieldCaption("Posting Date")));
                        SetRange("Posting Date", 0D, WorkDate);
                    end;
                    if "Accrual Journal Batch"."No. Series" <> '' then
                        NoSeries.Get("Accrual Journal Batch"."No. Series");
                    LastPostingDate := 0D;
                    LastDocNo := '';
                end;
            }

            trigger OnAfterGetRecord()
            begin
                CurrReport.PageNo := 1;
            end;

            trigger OnPreDataItem()
            var
                i: Integer;
            begin
                for i := 1 to ArrayLen(EntryTypeDescription) do begin
                    "Accrual Journal Line"."Entry Type" := i - 1;
                    EntryTypeDescription[i] := Format("Accrual Journal Line"."Entry Type");
                end;

                for i := 1 to ArrayLen(SourceDocTypeDescription) do begin
                    "Accrual Journal Line"."Source Document Type" := i - 1;
                    SourceDocTypeDescription[i] := Format("Accrual Journal Line"."Source Document Type");
                end;

                for i := 1 to ArrayLen(PostingLevelDescription) do begin
                    AccrualPlan."Accrual Posting Level" := i - 1;
                    PostingLevelDescription[i] := Format(AccrualPlan."Accrual Posting Level");
                end;
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
                    field(ShowDim; ShowDim)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Show Dimensions';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
        PAGENOCaption = 'Page';
        AccrualPostingTestCaption = 'Accrual Posting - Test';
        TotalCaption = 'Total';
        DimensionsCaption = 'Dimensions';
        ErrorTextNumberCaption = 'Warning!';
    }

    trigger OnPreReport()
    begin
        AccrualJnlLineFilter := "Accrual Journal Line".GetFilters;
        AccrualSetup.Get;
    end;

    var
        AccrualSetup: Record "Accrual Setup";
        AccrualJnlTemplate: Record "Accrual Journal Template";
        AccrualPlan: Record "Accrual Plan";
        NoSeries: Record "No. Series";
        DimSetEntry: Record "Dimension Set Entry";
        DimMgt: Codeunit DimensionManagement;
        Process800UtilityFunctions: Codeunit "Process 800 Utility Functions";
        AccrualJnlLineFilter: Text;
        EntryTypeDescription: array[2] of Text[30];
        SourceDocTypeDescription: array[5] of Text[30];
        PostingLevelDescription: array[4] of Text[30];
        ErrorCounter: Integer;
        ErrorText: array[30] of Text[250];
        NoOfEntries: array[2] of Decimal;
        TotalAmounts: array[2] of Decimal;
        LastPostingDate: Date;
        LastDocNo: Code[20];
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
        ShowDim: Boolean;
        DimText: Text[120];
        OldDimText: Text[75];
        Continue: Boolean;
        Text000: Label '%1 cannot be filtered when you post recurring journals.';
        Text001: Label '%1 must be specified.';
        Text002: Label '%1 %2 does not exist.';
        Text003: Label '%1 must be %2.';
        Text004: Label '%1 must not be a closing date.';
        Text005: Label 'The lines are not listed according to Posting Date because they were not entered in that order.';
        Text007: Label '%1 must have the same value as %2 when %3 is %4.';
        Text008: Label '%1 cannot be specified.';
        Text009: Label 'There is a gap in the number series.';
        Text010: Label '%1 must not be %2 when %3 is %4.';
        Text011: Label '%1 must be %2 for %3 %4 of %5.';
        Text012: Label '%1 must not be %2 for %3 %4 of %5.';
        Text013: Label '%1 must not be %2 or %3 for %4 %5 of %6.';
        Text014: Label '<Month Text>';
        Text015: Label 'entered';

    local procedure AddError(Text: Text[250])
    begin
        ErrorCounter := ErrorCounter + 1;
        ErrorText[ErrorCounter] := Text;
    end;

    local procedure MakeRecurringTexts(var AccrualJnlLine2: Record "Accrual Journal Line")
    var
        AccountingPeriod: Record "Accounting Period";
        Day: Integer;
        Week: Integer;
        Month: Integer;
        MonthText: Text[30];
    begin
        with AccrualJnlLine2 do begin
            if ("Posting Date" <> 0D) and ("Item No." <> '') and ("Recurring Method" <> 0) then begin
                Day := Date2DMY("Posting Date", 1);
                Week := Date2DWY("Posting Date", 2);
                Month := Date2DMY("Posting Date", 2);
                MonthText := Format("Posting Date", 0, Text014);
                AccountingPeriod.SetRange("Starting Date", 0D, "Posting Date");
                if not AccountingPeriod.Find('+') then
                    AccountingPeriod.Name := '';
                "Document No." :=
                  DelChr(
                    PadStr(
                      StrSubstNo("Document No.", Day, Week, Month, MonthText, AccountingPeriod.Name),
                      MaxStrLen("Document No.")),
                    '>');
                Description :=
                  DelChr(
                    PadStr(
                      StrSubstNo(Description, Day, Week, Month, MonthText, AccountingPeriod.Name),
                      MaxStrLen(Description)),
                    '>');
            end;
        end;
    end;

    local procedure CheckRecurringLine(AccrualJnlLine2: Record "Accrual Journal Line")
    begin
        with AccrualJnlLine2 do begin
            if AccrualJnlTemplate.Recurring then begin
                if "Recurring Method" = 0 then
                    AddError(StrSubstNo(Text001, FieldCaption("Recurring Method")));
                if Format("Recurring Frequency") = '' then
                    AddError(StrSubstNo(Text001, FieldCaption("Recurring Frequency")));
                if "Recurring Method" = "Recurring Method"::Variable then
                    if Amount = 0 then
                        AddError(StrSubstNo(Text001, FieldCaption(Amount)));
            end else begin
                if "Recurring Method" <> 0 then
                    AddError(StrSubstNo(Text008, FieldCaption("Recurring Method")));
                if Format("Recurring Frequency") <> '' then
                    AddError(StrSubstNo(Text008, FieldCaption("Recurring Frequency")));
            end;
        end;
    end;
}

