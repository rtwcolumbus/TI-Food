report 37002128 "Compare Accrual Plan to View"
{
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 24 AUG 07
    //   Use text constants
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 19 JUN 08
    //   Add caption property
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 21 APR 10
    //   RTC Reporting Upgrade
    // 
    // P8000829, VerticalSoft, Jack Reynolds, 08 JUN 10
    //   Remove text from ItemInView footer
    // 
    // PRW16.00.04
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 16 NOV 15
    //   Rewrite view handling functions
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
    Caption = 'Compare Accrual Plan to View';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(AccrualPlan; "Accrual Plan")
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = Type, "No.";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            column(ShowViewText; ShowViewText)
            {
            }
            column(STRTypeNoName; StrSubstNo('%1 %2 %3 - %4', Type, TableCaption, "No.", Name))
            {
            }
            column(AccrualPlanHeader; 'AccrualPlan')
            {
            }
            column(AccrualPlanRec; Format(AccrualPlan.Type) + AccrualPlan."No.")
            {
            }
            dataitem(AccrualPlanLine; "Accrual Plan Line")
            {
                DataItemLink = "Accrual Plan Type" = FIELD(Type), "Accrual Plan No." = FIELD("No.");
                DataItemTableView = SORTING("Accrual Plan Type", "Accrual Plan No.", "Item Code", "Minimum Value");
                PrintOnlyIfDetail = true;
                column(AccrualPlanGetItemViewText; AccrualPlan.ReadView(AccrualPlan.FieldNo("Item View")))
                {
                }
                column(Text007; Text007)
                {
                }
                column(Text001; Text001)
                {
                }
                column(STRItemSelectionItemCode; StrSubstNo('%1 - %2', "Item Selection", "Item Code"))
                {
                }
                column(AccrualPlanLineHeader; 'AccrualPlanLine')
                {
                }
                column(AccrualPlanLineRec; Format(AccrualPlanLine."Accrual Plan Type") + AccrualPlanLine."Accrual Plan No." + AccrualPlanLine."Item Code" + Format(AccrualPlanLine."Minimum Value"))
                {
                }
                column(AccrualPlanLineItemSelection; "Item Selection")
                {
                }
                dataitem(PlanItem; Item)
                {
                    DataItemTableView = SORTING("No.");
                    column(PlanItemNo; "No.")
                    {
                    }
                    column(PlanItemDesc; Description)
                    {
                    }
                    column(PlanItemRec; PlanItem."No.")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        ItemView := PlanItem;
                        if ItemView.Find then begin
                            ItemView.Mark(true);
                            CurrReport.Skip;
                        end;
                    end;

                    trigger OnPreDataItem()
                    begin
                        case AccrualPlan."Item Selection" of
                            AccrualPlan."Item Selection"::"Specific Item":
                                SetRange("No.", AccrualPlanLine."Item Code");
                            AccrualPlan."Item Selection"::"Item Category":
                                begin
                                    SetCurrentKey("Item Type", "Item Category Code");
                                    SetRange("Item Category Code", AccrualPlanLine."Item Code");
                                end;
                            AccrualPlan."Item Selection"::Manufacturer:
                                SetRange("Manufacturer Code", AccrualPlanLine."Item Code");
                            AccrualPlan."Item Selection"::"Vendor No.":
                                begin
                                    SetCurrentKey("Vendor No.");
                                    SetRange("Vendor No.", AccrualPlanLine."Item Code");
                                end;
                        end;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    SetRange("Item Code", "Item Code");
                    Find('+');
                    SetRange("Item Code");
                end;

                trigger OnPreDataItem()
                begin
                    if not ShowItems then
                        CurrReport.Break;
                end;
            }
            dataitem(ItemInView; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                column(Text002; Text002)
                {
                }
                column(ItemViewNo; ItemView."No.")
                {
                }
                column(ItemViewDesc; ItemView.Description)
                {
                }
                column(ItemInViewRec; Format(Number))
                {
                }
                column(ItemInViewHeader; 'ItemInView')
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if (Number = 1) then begin
                        if not ItemView.Find('-') then
                            CurrReport.Break;
                    end else begin
                        if (ItemView.Next = 0) then
                            CurrReport.Break;
                    end;

                    if ItemView.Mark then
                        CurrReport.Skip;
                end;

                trigger OnPreDataItem()
                begin
                    if not ShowItems then
                        CurrReport.Break;
                end;
            }
            dataitem(SalesAccrualSourceLine; "Accrual Plan Source Line")
            {
                DataItemLink = "Accrual Plan Type" = FIELD(Type), "Accrual Plan No." = FIELD("No.");
                DataItemTableView = SORTING("Accrual Plan Type", "Accrual Plan No.", "Source Code", "Source Ship-to Code");
                PrintOnlyIfDetail = true;
                column(SalesAccrualPlanGetSourceViewText; AccrualPlan.ReadView(AccrualPlan.FieldNo("Source View")))
                {
                }
                column(Text008; Text008)
                {
                }
                column(Text003; Text003)
                {
                }
                column(SalesSTRSourceSelectionSourceCode; StrSubstNo('%1 - %2', "Source Selection", "Source Code"))
                {
                }
                column(SalesAccrualSourceLineRec; Format(SalesAccrualSourceLine."Accrual Plan Type") + SalesAccrualSourceLine."Accrual Plan No." + SalesAccrualSourceLine."Source Code" + SalesAccrualSourceLine."Source Ship-to Code")
                {
                }
                column(SalesAccrualSourceLineHeader; 'SalesAccrualSourceLine')
                {
                }
                column(SalesAccrualSourceLineSourceSelection; "Source Selection")
                {
                }
                dataitem(PlanCustomer; Customer)
                {
                    DataItemTableView = SORTING("No.");
                    column(PlanCustNo; "No.")
                    {
                    }
                    column(PlanCustName; Name)
                    {
                    }
                    column(PlanCustRec; PlanCustomer."No.")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        CustomerView := PlanCustomer;
                        if CustomerView.Find then begin
                            CustomerView.Mark(true);
                            CurrReport.Skip;
                        end;
                    end;

                    trigger OnPreDataItem()
                    begin
                        case AccrualPlan."Source Selection" of
                            AccrualPlan."Source Selection"::Specific:
                                SetRange("No.", SalesAccrualSourceLine."Source Code");
                            AccrualPlan."Source Selection"::"Price Group":
                                SetRange("Customer Price Group", SalesAccrualSourceLine."Source Code");
                        end;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    SetRange("Source Code", "Source Code");
                    Find('+');
                    SetRange("Source Code");
                end;

                trigger OnPreDataItem()
                begin
                    if (AccrualPlan.Type <> AccrualPlan.Type::Sales) then
                        CurrReport.Break;

                    if not ShowSources then
                        CurrReport.Break;
                end;
            }
            dataitem(CustomerInView; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                column(Text004; Text004)
                {
                }
                column(CustViewNo; CustomerView."No.")
                {
                }
                column(CustViewName; CustomerView.Name)
                {
                }
                column(CustInViewRec; Format(Number))
                {
                }
                column(CustInViewHeader; 'CustomerInView')
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if (Number = 1) then begin
                        if not CustomerView.Find('-') then
                            CurrReport.Break;
                    end else begin
                        if (CustomerView.Next = 0) then
                            CurrReport.Break;
                    end;

                    if CustomerView.Mark then
                        CurrReport.Skip;
                end;

                trigger OnPreDataItem()
                begin
                    if (AccrualPlan.Type <> AccrualPlan.Type::Sales) then
                        CurrReport.Break;

                    if not ShowSources then
                        CurrReport.Break;
                end;
            }
            dataitem(PurchAccrualSourceLine; "Accrual Plan Source Line")
            {
                DataItemLink = "Accrual Plan Type" = FIELD(Type), "Accrual Plan No." = FIELD("No.");
                DataItemTableView = SORTING("Accrual Plan Type", "Accrual Plan No.", "Source Code", "Source Ship-to Code");
                PrintOnlyIfDetail = true;
                column(PurchAccrualPlanGetSourceViewText; AccrualPlan.ReadView(AccrualPlan.FieldNo("Source View")))
                {
                }
                column(Text009; Text009)
                {
                }
                column(Text005; Text005)
                {
                }
                column(PurchSTRSourceSelectionSourceCode; StrSubstNo('%1 - %2', "Source Selection", "Source Code"))
                {
                }
                column(PurchAccrualSourceLineHeader; 'PurchAccrualSourceLine')
                {
                }
                column(PurchAccrualSourceLineRec; Format(PurchAccrualSourceLine."Accrual Plan Type") + PurchAccrualSourceLine."Accrual Plan No." + PurchAccrualSourceLine."Source Code" + PurchAccrualSourceLine."Source Ship-to Code")
                {
                }
                column(PurchAccrualSourceLineSourceSelection; "Source Selection")
                {
                }
                dataitem(PlanVendor; Vendor)
                {
                    DataItemTableView = SORTING("No.");
                    column(PlanVendorNo; "No.")
                    {
                    }
                    column(PlanVendorName; Name)
                    {
                    }
                    column(PlanVendorRec; PlanVendor."No.")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        VendorView := PlanVendor;
                        if VendorView.Find then begin
                            VendorView.Mark(true);
                            CurrReport.Skip;
                        end;
                    end;

                    trigger OnPreDataItem()
                    begin
                        if (AccrualPlan."Source Selection" = AccrualPlan."Source Selection"::Specific) then
                            SetRange("No.", PurchAccrualSourceLine."Source Code");
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    SetRange("Source Code", "Source Code");
                    Find('+');
                    SetRange("Source Code");
                end;

                trigger OnPreDataItem()
                begin
                    if (AccrualPlan.Type <> AccrualPlan.Type::Purchase) then
                        CurrReport.Break;

                    if not ShowSources then
                        CurrReport.Break;
                end;
            }
            dataitem(VendorInView; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                column(VendorViewNo; VendorView."No.")
                {
                }
                column(VendorViewName; VendorView.Name)
                {
                }
                column(VendorInViewHeader; 'VendorInView')
                {
                }
                column(VendorInViewRec; Format(Number))
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if (Number = 1) then begin
                        if not VendorView.Find('-') then
                            CurrReport.Break;
                    end else begin
                        if (VendorView.Next = 0) then
                            CurrReport.Break;
                    end;

                    if VendorView.Mark then
                        CurrReport.Skip;
                end;

                trigger OnPreDataItem()
                begin
                    if (AccrualPlan.Type <> AccrualPlan.Type::Purchase) then
                        CurrReport.Break;

                    if not ShowSources then
                        CurrReport.Break;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                ShowItems := false;
                if (Compare in [Compare::"Sources & Items", Compare::"Items Only"]) then
                    ShowItems := LoadItemView(ItemView);

                ShowSources := false;
                if (Compare in [Compare::"Sources & Items", Compare::"Sources Only"]) then
                    if (Type = Type::Sales) then
                        ShowSources := LoadCustomerView(CustomerView)
                    else
                        ShowSources := LoadVendorView(VendorView);

                if not (ShowItems or ShowSources) then
                    CurrReport.Skip;
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
                    field(Compare; Compare)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Compare';
                    }
                    field(ShowViewText; ShowViewText)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Show View Text';
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
            LayoutFile = './layout/CompareAccrualPlantoView.rdlc';
        }
    }

    labels
    {
        CompareAccrualPlantoViewCaption = 'Compare Accrual Plan to View';
        PAGENOCaption = 'Page';
    }

    var
        Compare: Option "Sources & Items","Sources Only","Items Only";
        ShowViewText: Boolean;
        ShowItems: Boolean;
        ItemView: Record Item;
        ShowSources: Boolean;
        CustomerView: Record Customer;
        VendorView: Record Vendor;
        Text001: Label 'Items in the plan but not in the view:';
        Text002: Label 'Items in the view but not in the plan:';
        Text003: Label 'Customers in the plan but not in the view:';
        Text004: Label 'Customers in the view but not in the plan:';
        Text005: Label 'Vendors in the plan but not in the view:';
        Text006: Label 'Vendors in the view but not in the plan:';
        Text007: Label 'Item View:';
        Text008: Label 'Customer View:';
        Text009: Label 'Vendor View:';
}

