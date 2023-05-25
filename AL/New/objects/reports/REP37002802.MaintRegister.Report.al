report 37002802 "Maint. Register"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   This is the standard posting report for maintenance registers
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 04 MAY 10
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

    Caption = 'Maintenance Register';

    dataset
    {
        dataitem("Maintenance Register"; "Maintenance Register")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Source Code";
            column(CompanyInfoName; CompanyInformation.Name)
            {
            }
            column(MaintRegisterTabCapMaintRegFilter; "Maintenance Register".TableCaption + ': ' + MaintRegFilter)
            {
            }
            column(MaintLedgTabCapMaintEntryFilter; "Maintenance Ledger".TableCaption + ': ' + MaintEntryFilter)
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
            column(MaintRegisterHeader; 'MaintenanceRegister')
            {
            }
            column(MaintRegisterRec; Format("No."))
            {
            }
            column(PrintDescriptions; PrintDescriptions)
            {
            }
            column(MaintEntryFilter; MaintEntryFilter)
            {
            }
            column(MaintRegFilter; MaintRegFilter)
            {
            }
            dataitem("Maintenance Ledger"; "Maintenance Ledger")
            {
                DataItemTableView = SORTING("Entry No.");
                RequestFilterFields = "Work Order No.", "Asset No.", "Entry Type", "Location Code", "Posting Date";
                column(MaintLedgEntryNo; "Entry No.")
                {
                    IncludeCaption = true;
                }
                column(MaintLedgWorkOrderNo; "Work Order No.")
                {
                    IncludeCaption = true;
                }
                column(MaintLedgAssetNo; "Asset No.")
                {
                    IncludeCaption = true;
                }
                column(MaintLedgEntryType; "Entry Type")
                {
                    IncludeCaption = true;
                    OptionCaption = 'Labor,Stock,NonStock,Contract';
                }
                column(MaintLedgPostingDate; "Posting Date")
                {
                    IncludeCaption = true;
                }
                column(MaintLedgCostAmount; "Cost Amount")
                {
                    IncludeCaption = true;
                }
                column(MaintLedgQuantity; Quantity)
                {
                    IncludeCaption = true;
                }
                column(MaintLedgDocNo; "Document No.")
                {
                    IncludeCaption = true;
                }
                column(MaintLedgUnitCost; "Unit Cost")
                {
                    IncludeCaption = true;
                }
                column(MaintLedgRec; Format("Entry No."))
                {
                }
                column(MaintLedgHeader; 'MaintenanceLedger')
                {
                }
                column(MaintTradeDesc; MaintTrade.Description)
                {
                }
                column(MaintLedgEmployeeNo; "Employee No.")
                {
                }
                column(EmployeeSearchName; Employee."Search Name")
                {
                }
                column(MaintLedgVendorNo; "Vendor No.")
                {
                }
                column(VendorName; Vendor.Name)
                {
                }
                column(ItemDesc; Item.Description)
                {
                }
                column(MaintLedgPartNo; "Part No.")
                {
                }
                column(MaintRegisterNo; "Maintenance Register"."No.")
                {
                }
                column(MaintRegisterToEntryNo_FromEntryNo_1; "Maintenance Register"."To Entry No." - "Maintenance Register"."From Entry No." + 1)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if PrintDescriptions then begin
                        Clear(MaintTrade);
                        Clear(Employee);
                        Clear(Item);
                        Clear(Vendor);
                        case "Entry Type" of
                            "Entry Type"::Labor:
                                begin
                                    if MaintTrade.Get("Maintenance Trade Code") then;
                                    if Employee.Get("Employee No.") then;
                                end;
                            "Entry Type"::"Material-Stock":
                                if Item.Get("Item No.") then
                                    ;
                            "Entry Type"::Contract:
                                begin
                                    if MaintTrade.Get("Maintenance Trade Code") then;
                                    if Vendor.Get("Vendor No.") then;
                                end;
                        end;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Entry No.", "Maintenance Register"."From Entry No.", "Maintenance Register"."To Entry No.");
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
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PrintDescriptions; PrintDescriptions)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Print Descriptions';
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
            LayoutFile = './layout/MaintRegister.rdlc';
        }
    }

    labels
    {
        MaintRegisterCaption = 'Maintenance Register';
        PageNoCaption = 'Page';
        NumberofEntriesinRegisterNoCaption = 'Number of Entries in Register No.';
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get;
        MaintRegFilter := "Maintenance Register".GetFilters;
        MaintEntryFilter := "Maintenance Ledger".GetFilters;
    end;

    var
        CompanyInformation: Record "Company Information";
        SourceCode: Record "Source Code";
        MaintTrade: Record "Maintenance Trade";
        Employee: Record Employee;
        Item: Record Item;
        Vendor: Record Vendor;
        MaintRegFilter: Text;
        MaintEntryFilter: Text;
        SourceCodeText: Text[30];
        Text000: Label 'Register No: %1';
        PrintDescriptions: Boolean;
}

