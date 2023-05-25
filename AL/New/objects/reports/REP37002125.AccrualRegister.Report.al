report 37002125 "Accrual Register"
{
    // PR4.00.06
    // P8000473A, VerticalSoft, Jack Reynolds, 22 MAY 07
    //   Posting report for accruals
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 20 APR 10
    //   RTC Reporting Upgrade
    // 
    // PRW16.00.04
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // PRW17.10
    // P8001223, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Expand filter variables
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    DefaultRenderingLayout = StandardRDLCLayout;

    Caption = 'Accrual Register';

    dataset
    {
        dataitem("Accrual Register"; "Accrual Register")
        {
            DataItemTableView = SORTING("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Source Code";
            column(CompanyInfoName; CompanyInformation.Name)
            {
            }
            column(AccrualRegTabCapFilter; "Accrual Register".TableCaption + ': ' + AccrualRegFilter)
            {
            }
            column(AccrualLedgEntryTabCapFilter; "Accrual Ledger Entry".TableCaption + ': ' + AccrualEntryFilter)
            {
            }
            column(SourceCodeDesc; SourceCode.Description)
            {
            }
            column(SourceCodeText; SourceCodeText)
            {
            }
            column(STRNo; StrSubstNo(Text000, "No."))
            {
            }
            column(AccrualRegisterBody; 'AccrualRegister Body')
            {
            }
            column(AccrualRegisterNo; "No.")
            {
            }
            dataitem("Accrual Ledger Entry"; "Accrual Ledger Entry")
            {
                DataItemTableView = SORTING("Entry No.");
                RequestFilterFields = "Accrual Plan Type", "Entry Type", "Posting Date";
                column(AccrualLedgEntryAccrualPlanType; "Accrual Plan Type")
                {
                    IncludeCaption = true;
                }
                column(AccrualLedgEntryAccrualPlanNo; "Accrual Plan No.")
                {
                    IncludeCaption = true;
                }
                column(AccrualLedgEntryEntryType; "Entry Type")
                {
                    IncludeCaption = true;
                }
                column(AccrualLedgEntrySourceDocType; "Source Document Type")
                {
                    IncludeCaption = true;
                }
                column(AccrualLedgEntrySourceDocNo; "Source Document No.")
                {
                    IncludeCaption = true;
                }
                column(AccrualLedgEntryAmount; Amount)
                {
                    IncludeCaption = true;
                }
                column(AccrualLedgEntryPostingDate; "Posting Date")
                {
                    IncludeCaption = true;
                }
                column(AccrualLedgEntrySourceNo; "Source No.")
                {
                    IncludeCaption = true;
                }
                column(AccrualLedgEntryDesc; Description)
                {
                    IncludeCaption = true;
                }
                column(AccrualLedgerEntryBody; 'AccrualLedgerEntry Body')
                {
                }
                column(AccrualLedgerEntryEntryNo; "Entry No.")
                {
                }
                column(AccrualRegisterToEntryNo_AccrualRegisterFromEntryNo_1; "Accrual Register"."To Entry No." - "Accrual Register"."From Entry No." + 1)
                {
                }

                trigger OnPreDataItem()
                begin
                    SetRange("Entry No.", "Accrual Register"."From Entry No.", "Accrual Register"."To Entry No.");
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if "Source Code" = '' then begin
                    SourceCodeText := '';
                    SourceCode.Init;
                end else begin
                    SourceCodeText := FieldCaption("Source Code") + ': ' + "Source Code";
                    if not SourceCode.Get("Source Code") then
                        SourceCode.Init;
                end;
            end;
        }
    }

    requestpage
    {

        layout
        {
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
            LayoutFile = './layout/AccrualRegister.rdlc';
        }
    }

    labels
    {
        AccrualRegisterCaption = 'Accrual Register';
        PAGENOCaption = 'Page';
        NoofEntriesinRegisterNoCaption = 'Number of Entries in Register No.';
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get;
        AccrualRegFilter := "Accrual Register".GetFilters;
        AccrualEntryFilter := "Accrual Ledger Entry".GetFilters;
    end;

    var
        CompanyInformation: Record "Company Information";
        SourceCode: Record "Source Code";
        AccrualRegFilter: Text;
        AccrualEntryFilter: Text;
        SourceCodeText: Text[30];
        Text000: Label 'Register No: %1';
}

