report 37002803 "Maintenance Posting - Test"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   This is the standard test report for maintenance journals
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 05 MAY 10
    //   RTC Reporting Upgrade
    // 
    // PRW16.00.04
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // PRW16.00.06
    // P8001115, Columbus IT, Jack Reynolds, 08 NOV 12
    //   Fix problem posting to work orders without asset assigned
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 20 FEB 13
    //   Restoring the SaveValues property in the Request Page.
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
    DefaultRenderingLayout = StandardRDLCLayout;

    Caption = 'Maintenance Posting - Test';

    dataset
    {
        dataitem("Maintenance Journal Batch"; "Maintenance Journal Batch")
        {
            DataItemTableView = SORTING("Journal Template Name", Name);
            RequestFilterFields = "Journal Template Name", Name;
            column(MaintJnlBatchRec; "Journal Template Name" + Name)
            {
            }
            column(MaintJnlBatchHeader; 'MaintenanceJournalBatch')
            {
            }
            column(MaintJnlBatchJnlTemplateName; "Journal Template Name")
            {
                IncludeCaption = true;
            }
            column(MaintJnlBatchName; Name)
            {
            }
            dataitem("Maintenance Journal Line"; "Maintenance Journal Line")
            {
                DataItemLink = "Journal Template Name" = FIELD("Journal Template Name"), "Journal Batch Name" = FIELD(Name);
                DataItemTableView = SORTING("Journal Template Name", "Journal Batch Name", "Line No.");
                RequestFilterFields = "Posting Date";
                column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
                {
                }
                column(MaintJnlLineJnlBatchName; "Journal Batch Name")
                {
                    IncludeCaption = true;
                }
                column(MaintJnlLineTabCapMaintJnlLineFilter; "Maintenance Journal Line".TableCaption + ': ' + MaintJnlLineFilter)
                {
                }
                column(MaintJnlLineAmount; Amount)
                {
                    IncludeCaption = true;
                }
                column(MaintJnlLineUnitCost; "Unit Cost")
                {
                    IncludeCaption = true;
                }
                column(MaintJnlLineQuantity; Quantity)
                {
                    IncludeCaption = true;
                }
                column(MaintJnlLineEmployeeNo; "Employee No.")
                {
                    IncludeCaption = true;
                }
                column(MaintJnlLineMaintTradeCode; "Maintenance Trade Code")
                {
                    IncludeCaption = true;
                }
                column(MaintJnlLineDocNo; "Document No.")
                {
                    IncludeCaption = true;
                }
                column(MaintJnlLineWorkOrderNo; "Work Order No.")
                {
                    IncludeCaption = true;
                }
                column(MaintJnlLinePostingDate; "Posting Date")
                {
                    IncludeCaption = true;
                }
                column(MaintJnlLineAppliestoEntry; "Applies-to Entry")
                {
                    IncludeCaption = true;
                }
                column(MaintJnlLineRec; "Journal Template Name" + "Journal Batch Name" + Format("Line No."))
                {
                }
                column(MaintJnlLineHeader; 'MaintenanceJournalLine')
                {
                }
                column(MaintJnlTemplateType; MaintJnlTemplate.Type)
                {
                }
                column(MaintJnlLineEntryType; "Entry Type")
                {
                    IncludeCaption = true;
                    OptionCaption = 'Labor,Stock,Nonstock,Contract';
                }
                column(MaintJnlLineItemNo; "Item No.")
                {
                    IncludeCaption = true;
                }
                column(MaintJnlLinePartNo; "Part No.")
                {
                    IncludeCaption = true;
                }
                column(MaintJnlLineVendorNo; "Vendor No.")
                {
                    IncludeCaption = true;
                }
                dataitem(DimensionLoop; "Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                    column(DimText; DimText)
                    {
                    }
                    column(DimensionLoopRec; Format(Number))
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
                        DimSetEntry.SetRange("Dimension Set ID", "Maintenance Journal Line"."Dimension Set ID"); // P8001133
                    end;
                }
                dataitem(ErrorLoop; "Integer")
                {
                    DataItemTableView = SORTING(Number);
                    column(ErrorTextNumber; ErrorText[Number])
                    {
                    }
                    column(ErrorLoopRec; Format(Number))
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
                    TotalAmount := Amount;
                    // P8000812 S
                    RTCLabourAmount := 0;
                    RTCContractAmount := 0;
                    RTCMaterialAmount := 0;
                    if "Maintenance Journal Batch"."Template Type" = "Maintenance Journal Batch"."Template Type"::Labor then
                        RTCLabourAmount := Amount;
                    if "Maintenance Journal Batch"."Template Type" = "Maintenance Journal Batch"."Template Type"::Material then
                        RTCMaterialAmount := Amount;
                    if "Maintenance Journal Batch"."Template Type" = "Maintenance Journal Batch"."Template Type"::Contract then
                        RTCContractAmount := Amount;
                    // P8000812 E
                    if "Work Order No." = '' then
                        AddError(StrSubstNo(Text001, FieldCaption("Work Order No.")));
                    if "Posting Date" = 0D then
                        AddError(StrSubstNo(Text001, FieldCaption("Posting Date")))
                    else begin
                        if "Posting Date" <> NormalDate("Posting Date") then
                            AddError(StrSubstNo(Text005, FieldCaption("Posting Date")));

                        if "Maintenance Journal Batch"."No. Series" <> '' then
                            if NoSeries."Date Order" and ("Posting Date" < LastPostingDate) then
                                AddError(Text006);
                        LastPostingDate := "Posting Date";

                        // P80066030
                        if not Process800UtilityFunctions.CheckAllowedPostingDate("Posting Date") then
                            AddError(GetLastErrorText);
                        // P80066030
                    end;

                    if "Document No." = '' then
                        AddError(StrSubstNo(Text001, FieldCaption("Document No.")));
                    if "Document Date" = 0D then
                        AddError(StrSubstNo(Text001, FieldCaption("Document Date")))
                    else
                        if "Document Date" <> NormalDate("Document Date") then
                            AddError(StrSubstNo(Text005, FieldCaption("Document Date")));

                    if not WorkOrder.Get("Work Order No.") then
                        AddError(StrSubstNo(Text002, FieldCaption("Work Order No."), "Work Order No."));
                    // P8001115
                    if ("Work Order No." <> '') and (WorkOrder."Asset No." = '') then
                        AddError(StrSubstNo(Text017, WorkOrder.FieldCaption("Asset No."), "Work Order No."));
                    // P8001115

                    case "Entry Type" of
                        "Entry Type"::Labor:
                            begin
                                if "Maintenance Trade Code" = '' then
                                    AddError(StrSubstNo(Text001, FieldCaption("Maintenance Trade Code")));
                                if MaintSetup."Employee Mandatory" and ("Employee No." = '') then
                                    AddError(StrSubstNo(Text001, FieldCaption("Employee No.")));
                            end;
                        "Entry Type"::"Material-Stock":
                            begin
                                if "Item No." = '' then
                                    AddError(StrSubstNo(Text001, FieldCaption("Item No.")));
                            end;
                        "Entry Type"::"Material-Nonstock":
                            begin
                                if "Part No." = '' then
                                    AddError(StrSubstNo(Text001, FieldCaption("Part No.")));
                                if "Unit of Measure Code" = '' then
                                    AddError(StrSubstNo(Text001, FieldCaption("Unit of Measure Code")));
                            end;
                        "Entry Type"::Contract:
                            begin
                                if "Maintenance Trade Code" = '' then
                                    AddError(StrSubstNo(Text001, FieldCaption("Maintenance Trade Code")));
                                if MaintSetup."Vendor Mandatory" and ("Vendor No." = '') then
                                    AddError(StrSubstNo(Text001, FieldCaption("Vendor No.")));
                            end;
                    end;

                    if Quantity = 0 then
                        AddError(StrSubstNo(Text001, FieldCaption(Quantity)))
                    else
                        if Quantity > 0 then begin
                            if "Applies-to Entry" <> 0 then
                                AddError(StrSubstNo(Text003, FieldCaption("Applies-to Entry")));
                        end else begin
                            if "Applies-to Entry" = 0 then
                                AddError(StrSubstNo(Text001, FieldCaption("Applies-to Entry")));
                            MaintLedger.Get("Applies-to Entry");
                            if "Posting Date" <> MaintLedger."Posting Date" then
                                AddError(StrSubstNo(Text004, FieldCaption("Posting Date"), MaintLedger."Posting Date"));
                            if "Entry Type" <> MaintLedger."Entry Type" then
                                AddError(StrSubstNo(Text004, FieldCaption("Entry Type"), MaintLedger."Entry Type"));
                            if "Work Order No." <> MaintLedger."Work Order No." then
                                AddError(StrSubstNo(Text004, FieldCaption("Work Order No."), MaintLedger."Work Order No."));
                            case "Entry Type" of
                                "Entry Type"::Labor:
                                    begin
                                        if "Maintenance Trade Code" <> MaintLedger."Maintenance Trade Code" then
                                            AddError(StrSubstNo(Text004, FieldCaption("Maintenance Trade Code"), MaintLedger."Maintenance Trade Code"));
                                        if MaintSetup."Employee Mandatory" and ("Employee No." <> MaintLedger."Employee No.") then
                                            AddError(StrSubstNo(Text004, FieldCaption("Employee No."), MaintLedger."Employee No."));
                                    end;
                                "Entry Type"::"Material-Stock":
                                    begin
                                        if "Item No." <> MaintLedger."Item No." then
                                            AddError(StrSubstNo(Text004, FieldCaption("Item No."), MaintLedger."Item No."));
                                        if "Unit of Measure Code" <> MaintLedger."Unit of Measure Code" then
                                            AddError(StrSubstNo(Text004, FieldCaption("Unit of Measure Code"), MaintLedger."Unit of Measure Code"));
                                        if "Lot No." <> MaintLedger."Lot No." then
                                            AddError(StrSubstNo(Text004, FieldCaption("Lot No."), MaintLedger."Lot No."));
                                        if "Serial No." <> MaintLedger."Serial No." then
                                            AddError(StrSubstNo(Text004, FieldCaption("Serial No."), MaintLedger."Serial No."));
                                    end;
                                "Entry Type"::"Material-Nonstock":
                                    begin
                                        if "Part No." <> MaintLedger."Part No." then
                                            AddError(StrSubstNo(Text004, FieldCaption("Part No."), MaintLedger."Part No."));
                                        if "Unit of Measure Code" <> MaintLedger."Unit of Measure Code" then
                                            AddError(StrSubstNo(Text004, FieldCaption("Unit of Measure Code"), MaintLedger."Unit of Measure Code"));
                                    end;
                                "Entry Type"::Contract:
                                    begin
                                        if "Maintenance Trade Code" <> MaintLedger."Maintenance Trade Code" then
                                            AddError(StrSubstNo(Text004, FieldCaption("Maintenance Trade Code"), MaintLedger."Maintenance Trade Code"));
                                        if MaintSetup."Vendor Mandatory" and ("Employee No." <> MaintLedger."Employee No.") then
                                            AddError(StrSubstNo(Text004, FieldCaption("Vendor No."), MaintLedger."Vendor No."));
                                    end;
                            end;
                        end;

                    if "Posting Date" < WorkOrder."Origination Date" then
                        AddError(
                          StrSubstNo(Text014, FieldCaption("Posting Date"), WorkOrder.FieldCaption("Origination Date"), WorkOrder."Origination Date"));

                    if (WorkOrder."Completion Date" <> 0D) and (WorkOrder."Completion Date" < "Posting Date") then
                        AddError(
                          StrSubstNo(Text015, FieldCaption("Posting Date"), WorkOrder.FieldCaption("Completion Date"), WorkOrder."Completion Date"));

                    if WorkOrder."Completion Date" <> 0D then
                        if CalcDate(MaintSetup."Posting Grace Period", WorkOrder."Completion Date") < Today then
                            AddError(Text016);

                    if not DimMgt.CheckDimIDComb("Dimension Set ID") then // P8001133
                        AddError(DimMgt.GetDimCombErr);

                    TableID[1] := DATABASE::Asset;
                    No[1] := WorkOrder."Asset No.";
                    if not DimMgt.CheckDimValuePosting(TableID, No, "Dimension Set ID") then // P8001133
                        AddError(DimMgt.GetDimValuePostingErr);
                end;

                trigger OnPreDataItem()
                begin
                    MaintJnlTemplate.Get("Maintenance Journal Batch"."Journal Template Name");
                    if "Maintenance Journal Batch"."No. Series" <> '' then
                        NoSeries.Get("Maintenance Journal Batch"."No. Series");
                    LastPostingDate := 0D;
                    LastDocNo := '';

                    if Format(MaintSetup."Posting Grace Period") = '' then
                        Evaluate(MaintSetup."Posting Grace Period", '0D');
                end;
            }

            trigger OnAfterGetRecord()
            begin
                CurrReport.PageNo := 1;
            end;

            trigger OnPreDataItem()
            begin
                if templateFilter <> '' then
                    SetFilter("Journal Template Name", templateFilter);
                if batchFilter <> '' then
                    SetFilter(Name, batchFilter);
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

    rendering
    {
        layout(StandardRDLCLayout)
        {
            Summary = 'Standard Layout';
            Type = RDLC;
            LayoutFile = './layout/MaintenancePostingTest.rdlc';
        }
    }

    labels
    {
        PageNoCaption = 'Page';
        MaintPostingTestCaption = 'Maintenance Posting - Test';
        TotalAmountCaption = 'Total Amount';
        DimensionsCaption = 'Dimensions';
        ErrorTextNumberCaption = 'Warning!';
    }

    trigger OnPreReport()
    begin
        MaintJnlLineFilter := "Maintenance Journal Line".GetFilters;
        templateFilter := "Maintenance Journal Line".GetFilter("Journal Template Name");
        batchFilter := "Maintenance Journal Line".GetFilter("Journal Batch Name");
        MaintSetup.Get;
    end;

    var
        MaintSetup: Record "Maintenance Setup";
        WorkOrder: Record "Work Order";
        MaintLedger: Record "Maintenance Ledger";
        xAccountingPeriod: Record "Accounting Period";
        MaintJnlTemplate: Record "Maintenance Journal Template";
        NoSeries: Record "No. Series";
        DimSetEntry: Record "Dimension Set Entry";
        Process800UtilityFunctions: Codeunit "Process 800 Utility Functions";
        DimMgt: Codeunit DimensionManagement;
        MaintJnlLineFilter: Text;
        ErrorCounter: Integer;
        ErrorText: array[30] of Text[250];
        Text001: Label '%1 must be specified.';
        Text002: Label '%1 %2 does not exist.';
        Text003: Label '%1 must be 0.';
        Text004: Label '%1 must be %2.';
        Text005: Label '%1 must not be a closing date.';
        Text006: Label 'The lines are not listed according to Posting Date because they were not entered in that order.';
        LastPostingDate: Date;
        LastDocNo: Code[20];
        TotalAmount: Decimal;
        Text014: Label '%1 cannot be before %2 (%3)';
        Text015: Label '%1 cannot be after %2 (%3)';
        Text016: Label 'The grace period for posting has expired.';
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
        DimText: Text[120];
        OldDimText: Text[75];
        ShowDim: Boolean;
        Continue: Boolean;
        templateFilter: Text[1024];
        batchFilter: Text[1024];
        RTCLabourAmount: Decimal;
        RTCMaterialAmount: Decimal;
        RTCContractAmount: Decimal;
        Text017: Label 'No %1 for work order %2.';

    local procedure AddError(Text: Text[250])
    begin
        ErrorCounter := ErrorCounter + 1;
        ErrorText[ErrorCounter] := Text;
    end;
}

