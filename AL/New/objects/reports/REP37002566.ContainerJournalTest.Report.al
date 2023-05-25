report 37002566 "Container Journal - Test"
{
    // PR3.70.07
    // P8000140A, Myers Nissi, Jack Reynolds, 22 NOV 04
    //   Standard test report for container journal
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 26 APR 10
    //   RTC Reporting Upgrade
    // 
    // PRW16.00.04
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 20 FEB 13
    //   Restoring the SaveValues property in the Request Page.
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
    DefaultRenderingLayout = StandardRDLCLayout;

    ApplicationArea = FOODBasic;
    Caption = 'Container Journal - Test';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Container Journal Batch"; "Container Journal Batch")
        {
            DataItemTableView = SORTING("Journal Template Name", Name);
            RequestFilterFields = "Journal Template Name", Name;
            column(ContJnlBatchHeader; 'ContainerJournalBatch')
            {
            }
            column(ContJnlBatchRec; "Journal Template Name" + Name)
            {
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                PrintOnlyIfDetail = true;
                column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
                {
                }
                column(ContJnlBatchJnlTemplateName; "Container Journal Batch"."Journal Template Name")
                {
                }
                column(ContJnlBatchName; "Container Journal Batch".Name)
                {
                }
                column(ContJnlLineContJnlLineFilter; "Container Journal Line".TableCaption + ': ' + ContJnlLineFilter)
                {
                }
                column(ContJnlLineFilter; ContJnlLineFilter)
                {
                }
                column(IntegerHeader; 'Integer')
                {
                }
                column(IntegerRec; Format(Number))
                {
                }
                dataitem("Container Journal Line"; "Container Journal Line")
                {
                    DataItemLink = "Journal Template Name" = FIELD("Journal Template Name"), "Journal Batch Name" = FIELD(Name);
                    DataItemLinkReference = "Container Journal Batch";
                    DataItemTableView = SORTING("Journal Template Name", "Journal Batch Name", "Line No.");
                    RequestFilterFields = "Posting Date";
                    column(ContJnlLineDocNo; "Document No.")
                    {
                        IncludeCaption = true;
                    }
                    column(ContJnlLinePostingDate; "Posting Date")
                    {
                        IncludeCaption = true;
                    }
                    column(ContJnlLineContainerNo; "Container Item No.")
                    {
                        IncludeCaption = true;
                    }
                    column(ContJnlLineContainerSerialNo; "Container Serial No.")
                    {
                        IncludeCaption = true;
                    }
                    column(ContJnlLineEntryType; "Entry Type")
                    {
                        IncludeCaption = true;
                    }
                    column(ContJnlLineLocationCode; "Location Code")
                    {
                        IncludeCaption = true;
                    }
                    column(ContJnlLineSourceType; "Source Type")
                    {
                        IncludeCaption = true;
                    }
                    column(ContJnlLineSourceNo; "Source No.")
                    {
                        IncludeCaption = true;
                    }
                    column(ContJnlLineContainerID; "Container ID")
                    {
                        IncludeCaption = true;
                    }
                    column(ContJnlLineQuantity; Quantity)
                    {
                        IncludeCaption = true;
                    }
                    column(ContJnlLineUnitAmount; "Unit Amount")
                    {
                        IncludeCaption = true;
                    }
                    column(ContJnlLineHeader; 'ContainerJournalLine')
                    {
                    }
                    column(ContJnlLineRec; "Journal Template Name" + "Journal Batch Name" + Format("Line No."))
                    {
                    }
                    dataitem(DimensionLoop; "Integer")
                    {
                        DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                        column(DimText; DimText)
                        {
                        }
                        column(DimLoopRec; Format(Number))
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
                            DimSetEntry.SetRange("Dimension Set ID", "Container Journal Line"."Dimension Set ID"); // P8001133
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
                        if EmptyLine then
                            exit;

                        if "Container Item No." = '' then
                            AddError(StrSubstNo(Text001, FieldCaption("Container Item No.")))
                        else
                            if not Item.Get("Container Item No.") then
                                AddError(StrSubstNo(Text002, "Container Item No."))
                            else begin
                                if Item.Blocked then
                                    AddError(StrSubstNo(Text003, Item.FieldCaption(Blocked), false, "Container Item No."));
                                if ItemTracking.Get(Item."Item Tracking Code") and
                                  ItemTracking."SN Specific Tracking" and
                                  ("Container Serial No." = '')
                                then
                                    AddError(StrSubstNo(Text004, FieldCaption("Container Serial No."), FieldCaption("Container Item No."), "Container Item No."));
                            end;

                        if "Document No." = '' then
                            AddError(StrSubstNo(Text001, FieldCaption("Document No.")));

                        if "Location Code" = InvSetup."Offsite Cont. Location Code" then
                            AddError(StrSubstNo(Text005, FieldCaption("Location Code"), InvSetup."Offsite Cont. Location Code"));

                        case "Entry Type" of
                            "Entry Type"::Acquisition:
                                begin
                                    if "Container Serial No." <> '' then begin
                                        if Quantity <> 1 then
                                            AddError(StrSubstNo(Text003, FieldCaption(Quantity), 1, "Container Item No."));
                                        if SerialNo.Get("Container Item No.", '', "Container Serial No.") then
                                            AddError(StrSubstNo(Text006, FieldCaption("Container Serial No."), "Container Serial No.", "Container Item No."));
                                    end;
                                    if "New Location Code" <> '' then
                                        AddError(StrSubstNo(Text013, FieldCaption("New Location Code")));
                                    if "Source Type" = "Source Type"::" " then begin
                                        if "Source No." <> '' then
                                            AddError(StrSubstNo(Text013, FieldCaption("Source No.")));
                                    end else begin
                                        if "Source No." = '' then
                                            AddError(StrSubstNo(Text001, FieldCaption("Source No.")));
                                    end;
                                end;
                            "Entry Type"::Transfer:
                                begin
                                    if "New Location Code" = InvSetup."Offsite Cont. Location Code" then
                                        AddError(StrSubstNo(Text005, FieldCaption("New Location Code"), InvSetup."Offsite Cont. Location Code"));
                                    if "Location Code" = "New Location Code" then
                                        AddError(StrSubstNo(Text005, FieldCaption("New Location Code"), "Location Code"));
                                    if "Container Serial No." <> '' then begin
                                        SerialNo.Get("Container Item No.", '', "Container Serial No.");
                                        SerialNo.CalcFields("Container ID");
                                        if SerialNo."Container ID" <> '' then
                                            AddError(StrSubstNo(Text007, SerialNo.FieldCaption("Container ID")));
                                        SerialNo.SetRange("Location Filter", "Location Code");
                                        SerialNo.CalcFields(Inventory);
                                        if SerialNo.Inventory <> 1 then
                                            AddError(StrSubstNo(Text008, FieldCaption("Container Serial No."), FieldCaption("Location Code"), "Location Code"));
                                    end;
                                    if "Source Type" <> 0 then
                                        AddError(StrSubstNo(Text013, FieldCaption("Source Type")));
                                    if "Source No." <> '' then
                                        AddError(StrSubstNo(Text013, FieldCaption("Source No.")));
                                end;
                            "Entry Type"::Return:
                                begin
                                    if "Container Serial No." = '' then
                                        AddError(StrSubstNo(Text001, FieldCaption("Container Serial No.")));
                                    if "New Location Code" <> '' then
                                        AddError(StrSubstNo(Text013, FieldCaption("New Location Code")));
                                    SerialNo.Get("Container Item No.", '', "Container Serial No.");
                                    SerialNo.SetRange("Location Filter", InvSetup."Offsite Cont. Location Code");
                                    SerialNo.CalcFields(Inventory);
                                    if SerialNo.Inventory <> 1 then
                                        AddError(StrSubstNo(Text008, FieldCaption("Container Serial No."), FieldCaption("Location Code"), "Location Code"));
                                    if "Source Type" <> SerialNo.OffSiteSourceTypeInt then // P8001323
                                        AddError(StrSubstNo(Text014, FieldCaption("Source Type"), SerialNo.OffSiteSourceTypeText)); // P8001323
                                    if "Source No." <> SerialNo.OffSiteSourceNo then
                                        AddError(StrSubstNo(Text014, FieldCaption("Source No."), SerialNo.OffSiteSourceNo));
                                end;
                            "Entry Type"::Disposal:
                                begin
                                    if "New Location Code" <> '' then
                                        AddError(StrSubstNo(Text013, FieldCaption("New Location Code")));
                                    if "Container Serial No." <> '' then begin
                                        SerialNo.Get("Container Item No.", '', "Container Serial No.");
                                        SerialNo.CalcFields("Container ID");
                                        if SerialNo."Container ID" <> '' then
                                            AddError(StrSubstNo(Text007, SerialNo.FieldCaption("Container ID")));
                                        SerialNo.SetRange("Location Filter", "Location Code");
                                        SerialNo.CalcFields(Inventory);
                                        if SerialNo.Inventory <> 1 then
                                            AddError(StrSubstNo(Text008, FieldCaption("Container Serial No."), FieldCaption("Location Code"), "Location Code"));
                                    end;
                                    if "Source Type" = "Source Type"::" " then begin
                                        if "Source No." <> '' then
                                            AddError(StrSubstNo(Text013, FieldCaption("Source No.")));
                                    end else begin
                                        if "Source No." = '' then
                                            AddError(StrSubstNo(Text001, FieldCaption("Source No.")));
                                    end;
                                end;
                        end;

                        if "Posting Date" = 0D then
                            AddError(StrSubstNo(Text001, FieldCaption("Posting Date")))
                        else begin
                            if "Posting Date" <> NormalDate("Posting Date") then
                                AddError(StrSubstNo(Text009, FieldCaption("Posting Date")));

                            if "Container Journal Batch"."No. Series" <> '' then
                                if NoSeries."Date Order" and ("Posting Date" < LastPostingDate) then
                                    AddError(Text010);
                            LastPostingDate := "Posting Date";

                            // P80066030
                            if not Process800UtilityFunctions.CheckAllowedPostingDate("Posting Date") then
                                AddError(GetLastErrorText);
                            // P80066030
                        end;

                        if ("Document Date" <> 0D) then
                            if ("Document Date" <> NormalDate("Document Date")) then
                                AddError(StrSubstNo(Text009, FieldCaption("Document Date")));

                        if "Container Journal Batch"."No. Series" <> '' then begin
                            if LastDocNo <> '' then
                                if ("Document No." <> LastDocNo) and ("Document No." <> IncStr(LastDocNo)) then
                                    AddError(Text012);
                            LastDocNo := "Document No.";
                        end;

                        if not DimMgt.CheckDimIDComb("Dimension Set ID") then // P8001133
                            AddError(DimMgt.GetDimCombErr);

                        TableID[1] := DATABASE::Item;
                        No[1] := "Container Item No.";
                        if "Source Type" <> 0 then begin
                            TableID[2] := SourceTypeToTableID("Source Type");
                            No[2] := "Source No.";
                        end;
                        if not DimMgt.CheckDimValuePosting(TableID, No, "Dimension Set ID") then // P8001133
                            AddError(DimMgt.GetDimValuePostingErr);
                    end;

                    trigger OnPreDataItem()
                    begin
                        if "Container Journal Batch"."No. Series" <> '' then
                            NoSeries.Get("Container Journal Batch"."No. Series");
                        LastPostingDate := 0D;
                        LastDocNo := '';

                        InvSetup.Get;
                    end;
                }
            }

            trigger OnAfterGetRecord()
            begin
                CurrReport.PageNo := 1;
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
            LayoutFile = './layout/ContainerJournalTest.rdlc';
        }
    }

    labels
    {
        JnlTemplateCaption = 'Journal Template';
        JnlBatchCaption = 'Journal Batch';
        ContJnlTestCaption = 'Container Journal - Test';
        PageNoCaption = 'Page';
        DimensionsCaption = 'Dimensions';
        ErrorTextNumberCaption = 'Warning!';
    }

    trigger OnPreReport()
    begin
        ContJnlLineFilter := "Container Journal Line".GetFilters;
    end;

    var
        Text001: Label '%1 must be specified.';
        Text002: Label 'Container %1 does not exist.';
        Text003: Label '%1 must be %2 for container %3.';
        Text004: Label '%1 must be specified for %2 %3.';
        Text005: Label '%1 must not be %2.';
        Text006: Label '%1 %2 already exists for container %3.';
        Text007: Label '%1 must not be assigned.';
        Text008: Label '%1 is not at %2 ''%3''.';
        Text009: Label '%1 must not be a closing date.';
        Text010: Label 'The lines are not listed according to Posting Date because they were not entered in that order.';
        Text012: Label 'There is a gap in the number series.';
        Text013: Label '%1 cannot be specified.';
        Text014: Label '%1 must be %2.';
        InvSetup: Record "Inventory Setup";
        Item: Record Item;
        ItemTracking: Record "Item Tracking Code";
        SerialNo: Record "Serial No. Information";
        NoSeries: Record "No. Series";
        DimSetEntry: Record "Dimension Set Entry";
        Process800UtilityFunctions: Codeunit "Process 800 Utility Functions";
        DimMgt: Codeunit DimensionManagement;
        ErrorCounter: Integer;
        ErrorText: array[50] of Text[250];
        ContJnlLineFilter: Text;
        LastPostingDate: Date;
        LastDocNo: Code[20];
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
        DimText: Text[120];
        OldDimText: Text[75];
        ShowDim: Boolean;
        Continue: Boolean;

    local procedure AddError(Text: Text[250])
    begin
        ErrorCounter := ErrorCounter + 1;
        ErrorText[ErrorCounter] := Text;
    end;
}

