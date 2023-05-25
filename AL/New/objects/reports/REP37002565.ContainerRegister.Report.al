report 37002565 "Container Register"
{
    // PR3.70.07
    // P8000140A, Myers Nissi, Jack Reynolds, 21 NOV 04
    //   Posting report for container journal
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 19 JUN 08
    //   Add caption property
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
    // PRW17.10
    // P8001223, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Expand filter variables
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    DefaultRenderingLayout = StandardRDLCLayout;

    ApplicationArea = FOODBasic;
    Caption = 'Container Register';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Container Register"; "Container Register")
        {
            DataItemTableView = SORTING("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Creation Date", "Source Code", "Journal Batch Name";
            column(CompanyInfoName; CompanyInformation.Name)
            {
            }
            column(ContRegTabCapContRegFilter; "Container Register".TableCaption + ': ' + ContRegFilter)
            {
            }
            column(ContLedEntryTabCapContEntryFilter; "Container Ledger Entry".TableCaption + ': ' + ContEntryFilter)
            {
            }
            column(Text001No; Text001 + Format("No."))
            {
            }
            column(SourceCodeText; SourceCodeText)
            {
            }
            column(SourceCodeDesc; SourceCode.Description)
            {
            }
            column(ContRegRec; Format("No."))
            {
            }
            column(ContRegHeader; 'Container Register')
            {
            }
            column(ContEntryFilter; ContEntryFilter)
            {
            }
            column(ContRegFilter; ContRegFilter)
            {
            }
            column(PrintEntryData; PrintEntryData)
            {
            }
            dataitem("Container Ledger Entry"; "Container Ledger Entry")
            {
                DataItemTableView = SORTING("Entry No.");
                RequestFilterFields = "Container Item No.", "Container Serial No.", "Posting Date", "Document No.";
                column(ContLedgEntryPostingDate; "Posting Date")
                {
                    IncludeCaption = true;
                }
                column(ContLedgEntryDocNo; "Document No.")
                {
                    IncludeCaption = true;
                }
                column(ContLedgEntryEntryType; "Entry Type")
                {
                    IncludeCaption = true;
                }
                column(ContLedgEntryContainerNo; "Container Item No.")
                {
                    IncludeCaption = true;
                }
                column(ContLedgEntryContainerSerialNo; "Container Serial No.")
                {
                    IncludeCaption = true;
                }
                column(ContLedgEntryLocationCode; "Location Code")
                {
                    IncludeCaption = true;
                }
                column(ContLedgEntrySourceType; "Source Type")
                {
                    IncludeCaption = true;
                }
                column(ContLedgEntrySourceNo; "Source No.")
                {
                    IncludeCaption = true;
                }
                column(ContLedgEntryContainerID; "Container ID")
                {
                    IncludeCaption = true;
                }
                column(ContLedgEntryQuantity; Quantity)
                {
                    IncludeCaption = true;
                }
                column(ContLedgEntryUserID; "User ID")
                {
                    IncludeCaption = true;
                }
                column(ContLedgEntryRec; Format("Entry No."))
                {
                }
                column(ContLedgEntryHeader; 'Container Ledger Entry')
                {
                }
                column(ContLedgEntryTareWeight; "Tare Weight")
                {
                    IncludeCaption = true;
                }
                column(ContLedgEntryTareUOM; "Tare Unit of Measure")
                {
                }
                column(ContLedgEntryFillItemNo; "Fill Item No.")
                {
                }
                column(ContLedgEntryFillLotNo; "Fill Lot No.")
                {
                }
                column(STRFillQuantityFillUOMCode; StrSubstNo('%1 %2', "Fill Quantity", "Fill Unit of Measure Code"))
                {
                }
                column(FillQtyAlt; FillQtyAlt)
                {
                }
                column(ContRegNo; "Container Register"."No.")
                {
                }
                column(ContRegToEntryNoFromEntryNo_1; "Container Register"."To Entry No." - "Container Register"."From Entry No." + 1)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if PrintEntryData and ("Entry Type" = "Entry Type"::Use) then begin
                        Item.Get("Fill Item No.");
                        if Item.TrackAlternateUnits then
                            FillQtyAlt := StrSubstNo('%1 %2', "Fill Quantity (Alt.)", Item."Alternate Unit of Measure");
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Entry No.", "Container Register"."From Entry No.", "Container Register"."To Entry No.");
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if "Source Code" <> '' then begin
                    SourceCodeText := 'Source Code: ' + "Source Code";
                    if not SourceCode.Get("Source Code") then
                        SourceCode.Init;
                end else begin
                    Clear(SourceCodeText);
                    SourceCode.Init;
                end;
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
                    field(PrintEntryData; PrintEntryData)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Print Entry Type Data';
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
            LayoutFile = './layout/ContainerRegister.rdlc';
        }
    }

    labels
    {
        ContRegCaption = 'Container Register';
        PageNoCaption = 'Page';
        FillItemNoCaption = 'Fill Item';
        LotNoCaption = 'Lot No.';
        QuantityCaption = 'Quantity';
        NoofEntriesinRegNoCaption = 'Number of Entries in Register No.';
    }

    trigger OnPreReport()
    begin
        ContRegFilter := "Container Register".GetFilters;
        ContEntryFilter := "Container Ledger Entry".GetFilters;
        CompanyInformation.Get;
    end;

    var
        Item: Record Item;
        CompanyInformation: Record "Company Information";
        SourceCode: Record "Source Code";
        PrintEntryData: Boolean;
        ContRegFilter: Text;
        ContEntryFilter: Text;
        SourceCodeText: Text[100];
        FillQtyAlt: Text[50];
        Text001: Label 'Register No:';
}

