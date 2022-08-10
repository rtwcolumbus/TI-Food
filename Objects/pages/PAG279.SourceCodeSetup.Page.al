page 279 "Source Code Setup"
{
    // PR3.70.08
    // P8000140A, Myers Nissi, Jack Reynolds, 19 NOV 04
    //   Add controls for container journal source code
    // 
    // P8000170A, Myers Nissi, Jack Reynolds, 31 JAN 05
    //   Deduction Management
    // 
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 30 AUG 06
    //   Add tab page and controls for maintenace source code fields
    // 
    // PR4.00.06
    // P8000496A, VerticalSoft, Jack Reynolds, 23 JUL 07
    //   Add control for repack order (Inventory tab)
    // 
    // PRW16.00.01
    // P8000719, VerticalSoft, Jack Reynolds, 10 AUG 09
    //   Add controls for Maintenance Journal
    // 
    // PRW16.00.04
    // P8000856, VerticalSoft, Don Bresee, 24 AUG 10
    //   Add Commodity Class Costing granule
    // 
    // P8000891, VerticalSoft, Don Bresee, 04 JAN 11
    //   Add Commodity Receiving logic
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW110.0.02
    // P80039017, To-Increase, Jack Reynolds, 31 JUL 17
    //   Source Code for NAV Anywhere
    //
    // PRW119.03
    // P800122712, To Increase, Gangabhushan, 25 MAY 22
    //   Quality Control Samples

    ApplicationArea = Basic, Suite;
    Caption = 'Source Code Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Source Code Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("General Journal"; "General Journal")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted from a general journal of the general type.';
                }
                field("IC General Journal"; "IC General Journal")
                {
                    ApplicationArea = Intercompany;
                    ToolTip = 'Specifies the code linked to entries that are posted from an intercompany general journal.';
                }
                field("Accrual Journal"; "Accrual Journal")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Scheduled Accrual Journal"; "Scheduled Accrual Journal")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Close Income Statement"; "Close Income Statement")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted when you run the Close Income Statement batch job.';
                }
                field("VAT Settlement"; "VAT Settlement")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted using the Calc. and Post VAT Settlement batch job.';
                }
                field("Exchange Rate Adjmt."; "Exchange Rate Adjmt.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted when you run the Adjust Exchange Rates batch job.';
                }
                field("Deleted Document"; "Deleted Document")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted in connection with the deletion of a document.';
                }
                field("Adjust Add. Reporting Currency"; "Adjust Add. Reporting Currency")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted when you change the additional reporting currency in the General Ledger Setup table.';
                }
                field(Reversal; Reversal)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code assigned to entries that are posted from the Reverse Entries window.';
                }
                field("Compress G/L"; "Compress G/L")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted using the Date Compress General Ledger batch job.';
                }
                field("Compress VAT Entries"; "Compress VAT Entries")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted using the Date Compress VAT Entries batch job.';
                }
                field("Compress Bank Acc. Ledger"; "Compress Bank Acc. Ledger")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted using the Date Compress Bank Acc. Ledger batch job.';
                }
                field("Compress Check Ledger"; "Compress Check Ledger")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted using the Delete Check Ledger Entries batch job.';
                }
                field("Financially Voided Check"; "Financially Voided Check")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to check ledger entries with the entry status Financially Voided.';
                }
                field("Trans. Bank Rec. to Gen. Jnl."; "Trans. Bank Rec. to Gen. Jnl.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries posted after being transferred from a bank reconciliation by the Trans. Bank Rec. to Gen. Jnl. batch job.';
                }
                field("Bank Rec. Adjustment"; "Bank Rec. Adjustment")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source code that is assigned to entries that are posted from a bank record adjustment.';
                }
                field("Cash Flow Worksheet"; "Cash Flow Worksheet")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source code assigned to entries that are posted from the cash flow worksheet.';
                }
                field(Deposits; Deposits)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source code that is assigned to entries that are posted from a deposit.';
                    Visible = not BankDepositFeatureEnabled;
                }
                field("Payment Reconciliation Journal"; "Payment Reconciliation Journal")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted from a payment reconciliation journal.';
                }
                field(Consolidation; Consolidation)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted from Consolidation.';
                }
            }
            group(Sales)
            {
                Caption = 'Sales';
                field(Control14; Sales)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted in connection with sales, such as orders, invoices, and credit memos.';
                }
                field("Sales Journal"; "Sales Journal")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries posted from a general journal of the sales type.';
                }
                field("Cash Receipt Journal"; "Cash Receipt Journal")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted from a general journal of the cash receipts type.';
                }
                field("Sales Entry Application"; "Sales Entry Application")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted from the Apply Customer Entries window.';
                }
                field("Unapplied Sales Entry Appln."; "Unapplied Sales Entry Appln.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code assigned to entries that are posted from the Unapply Customer Entries window.';
                }
                field("Deduction Management"; "Deduction Management")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Reminder; Reminder)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted from a Reminder.';
                }
                field("Finance Charge Memo"; "Finance Charge Memo")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted from a Finance Charge Memo.';
                }
                field("Compress Cust. Ledger"; "Compress Cust. Ledger")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted using the Date Compress Customer Ledger batch job.';
                }
            }
            group(Purchases)
            {
                Caption = 'Purchases';
                field(Control26; Purchases)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted in connection with purchases, such as orders, invoices, and credit memos.';
                }
                field("Purchase Journal"; "Purchase Journal")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted from a general journal of the purchase type.';
                }
                field("Payment Journal"; "Payment Journal")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted from a general journal of the payments type.';
                }
                field("Purchase Entry Application"; "Purchase Entry Application")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted from the Apply Vendor Entries window.';
                }
                field("Unapplied Purch. Entry Appln."; "Unapplied Purch. Entry Appln.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code assigned to entries that are posted from the Unapply Vendor Entries window.';
                }
                field("Compress Vend. Ledger"; "Compress Vend. Ledger")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted using the Date Compress Vendor Ledger batch job.';
                }
            }
            group(Employees)
            {
                Caption = 'Employees';
                field("Employee Entry Application"; "Employee Entry Application")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted from the Apply Employee Entries window.';
                }
                field("Unapplied Empl. Entry Appln."; "Unapplied Empl. Entry Appln.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code assigned to entries that are posted from the Unapply Employee Entries window.';
                }
            }
            group(Inventory)
            {
                Caption = 'Inventory';
                field(Transfer; Transfer)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted in connection with transfer orders.';
                }
                field("Item Journal"; "Item Journal")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted from an item journal.';
                }
                field("Item Reclass. Journal"; "Item Reclass. Journal")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source code to use in item reclassification journals.';
                }
                field("Phys. Inventory Journal"; "Phys. Inventory Journal")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted from a Physical Inventory Journal.';
                }
                field("Phys. Invt. Orders"; "Phys. Invt. Orders")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the source code to use in physical inventory orders.';
                }
                field("Revaluation Journal"; "Revaluation Journal")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted from a Revaluation Journal.';
                }
                field("Inventory Post Cost"; "Inventory Post Cost")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted when you run the Post Inventory Cost to G/L batch job.';
                }
                field("Compress Item Ledger"; "Compress Item Ledger")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted using the Date Compress Item Ledger batch job.';
                }
                field("Compress Item Budget"; "Compress Item Budget")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the code that is linked to the compressed item budget entries.';
                }
                field("Adjust Cost"; "Adjust Cost")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are the result of a cost adjustment.';
                }
                field(Assembly; Assembly)
                {
                    ApplicationArea = Assembly;
                    ToolTip = 'Specifies the code that is linked to entries that are posted with assembly orders.';
                }
                field("Invt. Receipt"; "Invt. Receipt")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the inventory receipt.';
                }
                field("Invt. Shipment"; "Invt. Shipment")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the inventory shipment.';
                }
                field("Container Journal"; "Container Journal")
                {
                    ApplicationArea = FOODBasic;
                }
                // P800122712
                field("Quality Control Sample"; Rec."Quality Control Sample")
                {
                    ApplicationArea = FOODBasic;
                }
                // P800122712       
                field("Repack Order"; "Repack Order")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Commodity Cost Adjustment"; "Commodity Cost Adjustment")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Commodity Manifest"; "Commodity Manifest")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Resources)
            {
                Caption = 'Resources';
                field("Resource Journal"; "Resource Journal")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted from a Resource Journal.';
                }
                field("Compress Res. Ledger"; "Compress Res. Ledger")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted using the Date Compress Resource Ledger batch job.';
                }
            }
            group(Jobs)
            {
                Caption = 'Jobs';
                field("Job Journal"; "Job Journal")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted from a job journal.';
                }
                field("Job G/L Journal"; "Job G/L Journal")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code assigned to entries that are posted from a general journal of the Job G/L Journal type.';
                }
                field("Job G/L WIP"; "Job G/L WIP")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code assigned to entries that are posted from the Job Post WIP to G/L batch job in the Jobs module.';
                }
                field("Compress Job Ledger"; "Compress Job Ledger")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted using the Date Compress Job Ledger batch job.';
                }
            }
            group("Fixed Assets")
            {
                Caption = 'Fixed Assets';
                field("Fixed Asset G/L Journal"; "Fixed Asset G/L Journal")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted from a fixed asset G/L journal.';
                }
                field("Fixed Asset Journal"; "Fixed Asset Journal")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted from a fixed asset journal.';
                }
                field("Insurance Journal"; "Insurance Journal")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted from an insurance journal.';
                }
                field("Compress FA Ledger"; "Compress FA Ledger")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted using the Date Compress FA Ledger batch job.';
                }
                field("Compress Maintenance Ledger"; "Compress Maintenance Ledger")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted using the Date Compress Maint. Ledger batch job.';
                }
                field("Compress Insurance Ledger"; "Compress Insurance Ledger")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted using the Date Compress Insurance Ledger batch job.';
                }
            }
            group(Manufacturing)
            {
                Caption = 'Manufacturing';
                field("Consumption Journal"; "Consumption Journal")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted from a consumption journal.';
                }
                field("Output Journal"; "Output Journal")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted from an output journal.';
                }
                field(Flushing; Flushing)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to consumption entries that are posted when you change the status of a released production order to Finished.';
                }
                field("Capacity Journal"; "Capacity Journal")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted from a capacity journal.';
                }
                field("Production Journal"; "Production Journal")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the code that is linked to the entries that are posted from a production journal.';
                }
            }
            group(Service)
            {
                Caption = 'Service';
                field("Service Management"; "Service Management")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted from the Service Management application area.';
                }
            }
            group(Warehouse)
            {
                Caption = 'Warehouse';
                field("Whse. Item Journal"; "Whse. Item Journal")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the code for the Warehouse Item Journal.';
                }
                field("Whse. Reclassification Journal"; "Whse. Reclassification Journal")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the code for the Warehouse Reclassification Journal.';
                }
                field("Whse. Phys. Invt. Journal"; "Whse. Phys. Invt. Journal")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the code for the Warehouse Physical Inventory Journal.';
                }
                field("Whse. Put-away"; "Whse. Put-away")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the code for the Warehouse Put-away.';
                }
                field("Whse. Pick"; "Whse. Pick")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the code for the Warehouse Pick.';
                }
                field("Whse. Movement"; "Whse. Movement")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the code for the Warehouse movement.';
                }
                field("Compress Whse. Entries"; "Compress Whse. Entries")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the code linked to entries that are posted using the Date Compress Whse. Entries batch job.';
                }
            }
            group("Cost Accounting")
            {
                Caption = 'Cost Accounting';
                field("G/L Entry to CA"; "G/L Entry to CA")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code assigned to entries that are posted from transferring general ledger entries to cost entries.';
                }
                field("Cost Journal"; "Cost Journal")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code assigned to entries that are posted from a cost journal.';
                }
                field("Cost Allocation"; "Cost Allocation")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code assigned to entries that are posted from cost allocations.';
                }
                field("Transfer Budget to Actual"; "Transfer Budget to Actual")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the code linked to entries that are posted by running the Transfer Budget to Actual batch job.';
                }
            }
            group(Maintenance)
            {
                Caption = 'Maintenance';
                field("Work Order"; "Work Order")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Maintenance Labor Journal"; "Maintenance Labor Journal")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Maintenance Material Journal"; "Maintenance Material Journal")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Maintenance Contract Journal"; "Maintenance Contract Journal")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Maintenance Journal"; "Maintenance Journal")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
#if not CLEAN21
    var
        BankDepositFeatureMgt: Codeunit "Bank Deposit Feature Mgt.";
#endif
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;
        BankDepositFeatureEnabled := true;
#if not CLEAN21
        BankDepositFeatureEnabled := BankDepositFeatureMgt.IsEnabled();
#endif
    end;

    var
        BankDepositFeatureEnabled: Boolean;
}

