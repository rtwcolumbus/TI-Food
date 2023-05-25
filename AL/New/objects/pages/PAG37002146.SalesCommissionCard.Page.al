page 37002146 "Sales Commission Card"
{
    // PR3.70.05
    // P8000066A, Myers Nissi, Jack Reynolds, 29 JUN 04
    //   Resized tab control
    // 
    // PR3.70.06
    // P8000117A, Myers Nissi, Jack Reynolds, 15 SEP 04
    //   Resize tab control and form to accomodate subform on accrual tab
    // 
    // PR3.70.07
    // P8000119A, Myers Nissi, Don Bresee, 20 SEP 04
    //   Accruals update/fixes
    // 
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PR4.00.04
    // P8000355A, VerticalSoft, Jack Reynolds, 19 JUL 06
    //   Add support for accrual groups
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 03 NOV 09
    //   Transformed - additions in TIF Editor
    //   Changes made after transformation
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.00.01
    // P8001173, Columbus IT, Jack Reynolds, 20 JUN 13
    //   Support for Apply Template
    // 
    // PRW17.10
    // P8001236, Columbus IT, Don Bresee, 31 OCT 13
    //   Add "Payment Posting Options" field
    // 
    // PRW18.00
    // P8001359, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add support for ShowMandatory
    // 
    // PRW18.00.02
    // P8002741, To-Increase, Jack Reynolds, 30 Sep 15
    //   Option to create accrual payment documents
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 16 NOV 15
    //   Rewrite view handling functions

    Caption = 'Sales Commission Card';
    PageType = Document;
    SourceTable = "Accrual Plan";
    SourceTableView = WHERE(Type = CONST(Sales),
                            "Plan Type" = CONST(Commission));

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update;
                    end;
                }
                field(Name; Name)
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = true;
                }
                field("Plan Type"; "Plan Type")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(Accrue; Accrue)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Computation Level"; "Computation Level")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Start Date"; "Start Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("End Date"; "End Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Date Type"; "Date Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Search Name"; "Search Name")
                {
                    ApplicationArea = FOODBasic;
                }
                field(TotalEstimatedAmount; GetEstimatedAccrualAmount())
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Total Estimated Amount';
                    DrillDown = false;
                }
                field("Accrual Amount"; "Accrual Amount")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Payment Amount"; "Payment Amount")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Balance; Balance)
                {
                    ApplicationArea = FOODBasic;
                }
                group("Source Selection")
                {
                    Caption = 'Source Selection';
                    field("Source Selection Type"; "Source Selection Type")
                    {
                        ApplicationArea = FOODBasic;
                        OptionCaption = 'Bill-to,Sell-to,Sell-to/Ship-to';

                        trigger OnValidate()
                        begin
                            CurrPage.Update;                         // P8000664
                            CurrPage.SourceLines.PAGE.UpdateForm;    // P8000664
                        end;
                    }
                    field(Control37002017; "Source Selection")
                    {
                        ApplicationArea = FOODBasic;
                        OptionCaption = 'All Customers,Specific Customer,Price Group,Customer Group';

                        trigger OnValidate()
                        begin
                            CurrPage.Update;                         // P8000664
                            CurrPage.SourceLines.PAGE.UpdateForm;    // P8000664
                        end;
                    }
                    field("ReadView(FIELDNO(""Source View""))"; ReadView(FieldNo("Source View")))
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Source View';
                    }
                }
                group("Item Selection")
                {
                    Caption = 'Item Selection';
                    field(Control37002002; "Item Selection")
                    {
                        ApplicationArea = FOODBasic;
                        trigger OnValidate()
                        begin
                            CurrPage.Update;                         // P8000664
                            CurrPage.SourceLines.PAGE.UpdateForm;    // P8000664
                        end;
                    }
                    field("Minimum Value Type"; "Minimum Value Type")
                    {
                        ApplicationArea = FOODBasic;

                        trigger OnValidate()
                        begin
                            CurrPage.Update;                         // P8000664
                            CurrPage.SourceLines.PAGE.UpdateForm;    // P8000664
                        end;
                    }
                    field("Computation UOM"; "Computation UOM")
                    {
                        ApplicationArea = FOODBasic;

                        trigger OnValidate()
                        begin
                            CurrPage.Update;                         // P8000664
                            CurrPage.SourceLines.PAGE.UpdateForm;    // P8000664
                        end;
                    }
                    field("ReadView(FIELDNO(""Item View""))"; ReadView(FieldNo("Item View")))
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Item View';
                    }
                }
            }
            part(SourceLines; "Accrual Plan Source Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Customers';
                SubPageLink = "Accrual Plan Type" = FIELD(Type),
                              "Accrual Plan No." = FIELD("No.");
                SubPageView = SORTING("Accrual Plan Type", "Accrual Plan No.", "Source Code", "Source Ship-to Code");
            }
            part(PlanLines; "Accrual Plan Line Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Items';
                SubPageLink = "Accrual Plan Type" = FIELD(Type),
                              "Accrual Plan No." = FIELD("No.");
                SubPageView = SORTING("Accrual Plan Type", "Accrual Plan No.", "Item Code", "Minimum Value");
            }
            group(Accruals)
            {
                Caption = 'Accruals';
                field("Estimated Accrual Amount"; "Estimated Accrual Amount")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                }
                field("Accrual Charge Amount"; "Accrual Charge Amount")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        ChargesDrillDown;
                        CurrPage.Update;
                    end;
                }
                field(TotalEstimatedAmount2; GetEstimatedAccrualAmount())
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Total Estimated Amount';
                    DrillDown = false;
                }
                field("Use Accrual Schedule"; "Use Accrual Schedule")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;                // P8000664
                    end;
                }
                field("Scheduled Accrual Amount"; "Scheduled Accrual Amount")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        ShowScheduleLines(0);
                        CurrPage.Update;
                    end;
                }
                field(AccrualAmount2; "Accrual Amount")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Accrual Posting Level"; "Accrual Posting Level")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Payments)
            {
                Caption = 'Payments';
                field(EstimatedAccrualAmount2; "Estimated Accrual Amount")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                }
                field(AccrualChargeAmount2; "Accrual Charge Amount")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        ChargesDrillDown;
                        CurrPage.Update;
                    end;
                }
                field(TotalEstimatedAmount3; GetEstimatedAccrualAmount())
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Total Estimated Amount';
                    DrillDown = false;
                }
                field("Use Payment Schedule"; "Use Payment Schedule")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;               // P8000664
                    end;
                }
                field("Scheduled Payment Amount"; "Scheduled Payment Amount")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        ShowScheduleLines(1);
                        CurrPage.Update;
                    end;
                }
                field(PaymentAmount2; "Payment Amount")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Payment Posting Level"; "Payment Posting Level")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Payment Type"; "Payment Type")
                {
                    ApplicationArea = FOODBasic;
                    OptionCaption = 'Source Bill-to,Customer,Vendor,G/L Account,Payment Group,Manual/None';
                }
                field("Payment Code"; "Payment Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Payment Posting Options"; "Payment Posting Options")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Purchase Document Lines"; "Purchase Document Lines")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Sales Document Lines"; "Sales Document Lines")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Posting)
            {
                Caption = 'Posting';
                field("Computation Group"; "Computation Group")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Price Impact"; "Price Impact")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Include Promo/Rebate"; "Include Promo/Rebate")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Accrual Posting Group"; "Accrual Posting Group")
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = true;
                }
                field("G/L Posting Level"; "G/L Posting Level")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Post Accrual w/ Document"; "Post Accrual w/ Document")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Create Payment Documents"; "Create Payment Documents")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Post Payment w/ Document"; "Post Payment w/ Document")
                {
                    ApplicationArea = FOODBasic;
                    Enabled = NOT "Create Payment Documents";
                }
                field("Edit Accrual on Document"; "Edit Accrual on Document")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(CustomerMenu)
            {
                Caption = '&Source View';
                action(Define)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Define';
                    Ellipsis = true;
                    Image = CreateForm;

                    trigger OnAction()
                    begin
                        DefineView(FieldNo("Source View")); // P8004516
                    end;
                }
                action(Clear)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Clear';
                    Ellipsis = true;
                    Image = Delete;

                    trigger OnAction()
                    begin
                        ClearView(FieldNo("Source View")); // P8004516
                    end;
                }
                separator(Separator1102603015)
                {
                }
                action("Show Customers")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Show Customers';
                    Ellipsis = true;
                    Image = Customer;

                    trigger OnAction()
                    begin
                        ShowView(FieldNo("Source View")); // P8004516
                    end;
                }
                action("Add Customers to Plan")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Add Customers to Plan';
                    Ellipsis = true;
                    Image = AddAction;

                    trigger OnAction()
                    begin
                        AddViewToPlan(FieldNo("Source View")); // P8004516
                    end;
                }
            }
            group(ItemMenu)
            {
                Caption = '&Item View';
                action(Action1102603012)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Define';
                    Ellipsis = true;
                    Image = CreateForm;

                    trigger OnAction()
                    begin
                        DefineView(FieldNo("Item View")); // P8004516
                    end;
                }
                action(Action1102603013)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Clear';
                    Ellipsis = true;
                    Image = Delete;

                    trigger OnAction()
                    begin
                        ClearView(FieldNo("Item View")); // P8004516
                    end;
                }
                separator(Separator1102603016)
                {
                }
                action("Show Items")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Show Items';
                    Ellipsis = true;
                    Image = Item;

                    trigger OnAction()
                    begin
                        ShowView(FieldNo("Item View")); // P8004516
                    end;
                }
                action("Add Items to Plan")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Add Items to Plan';
                    Ellipsis = true;
                    Image = AddAction;

                    trigger OnAction()
                    begin
                        AddViewToPlan(FieldNo("Item View")); // P8004516
                    end;
                }
            }
            group("&Commission")
            {
                Caption = '&Commission';
                action(Statistics)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Statistics';
                    Image = Statistics;
                    RunObject = Page "Accrual Plan Statistics";
                    RunPageLink = "No." = FIELD("No.");
                    RunPageView = SORTING(Type, "No.")
                                  WHERE(Type = CONST(Sales),
                                        "Plan Type" = CONST(Commission));
                    ShortCutKey = 'F7';
                }
                action(Dimensions)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID" = CONST(37002120),
                                  "No." = FIELD("No.");
                    ShortCutKey = 'Shift+Ctrl+D';
                }
                action("Ledger E&ntries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Ledger E&ntries';
                    Image = ItemLedger;
                    RunObject = Page "Accrual Ledger Entries";
                    RunPageLink = "Accrual Plan No." = FIELD("No.");
                    RunPageView = SORTING("Accrual Plan Type", "Accrual Plan No.", "Posting Date")
                                  WHERE("Accrual Plan Type" = CONST(Sales));
                    ShortCutKey = 'Ctrl+F7';
                }
                separator(Separator1102603026)
                {
                }
                action("Accrual Schedule")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Accrual Schedule';
                    Ellipsis = true;
                    Image = InsuranceLedger;

                    trigger OnAction()
                    begin
                        ShowScheduleLines(0);
                        CurrPage.Update;
                    end;
                }
                action("Payment Schedule")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Payment Schedule';
                    Ellipsis = true;
                    Image = PaymentPeriod;

                    trigger OnAction()
                    begin
                        ShowScheduleLines(1);
                        CurrPage.Update;
                    end;
                }
                separator(Separator1102603044)
                {
                }
                action(Charges)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Charges';
                    Image = ProjectExpense;
                    RunObject = Page "Accrual Charge Lines";
                    RunPageLink = "Accrual Plan Type" = FIELD(Type),
                                  "Accrual Plan No." = FIELD("No.");
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("Apply Template")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Apply Template';
                    Ellipsis = true;
                    Image = ApplyTemplate;

                    trigger OnAction()
                    var
                        ConfigTemplateMgt: Codeunit "Config. Template Management";
                        RecRef: RecordRef;
                    begin
                        // P8001173
                        RecRef.GetTable(Rec);
                        ConfigTemplateMgt.UpdateFromTemplateSelection(RecRef);
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(LedgerEntries_Promoted; "Ledger E&ntries")
                {
                }
                actionref(AccrualSchedule_Promoted; "Accrual Schedule")
                {
                }
                actionref(ApplyTemplate_Promoted; "Apply Template")
                {
                }
                actionref(Statistics_Promoted; Statistics)
                {
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Type := Type::Sales;

        Validate("Plan Type", "Plan Type"::Commission);
    end;

    local procedure ChargesDrillDown()
    var
        AccrualChargeLine: Record "Accrual Charge Line";
    begin
        AccrualChargeLine.SetRange("Accrual Plan Type", Type);
        AccrualChargeLine.SetRange("Accrual Plan No.", "No.");
        PAGE.RunModal(0, AccrualChargeLine);
    end;
}

