page 395 "General Posting Setup Card"
{
    // PR4.00.04
    // P8000375A, VerticalSoft, Jack Reynolds, 07 SEP 06
    //   Add controls for ABC Direct and ABC Overhead accounts
    // 
    // PRW16.00.05
    // P8000921, Columbus IT, Jack Reynolds, 20 SEP 11
    //   Added "Sales Account (Freight)" field
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'General Posting Setup Card';
    DataCaptionFields = "Gen. Bus. Posting Group", "Gen. Prod. Posting Group";
    PageType = Card;
    SourceTable = "General Posting Setup";

    layout
    {
        area(content)
        {
            group(Control11)
            {
                ShowCaption = false;
                field(ShowAllAccounts; ShowAllAccounts)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Show All Accounts';
                    ToolTip = 'Specifies that all possible setup fields related to G/L accounts are shown.';

                    trigger OnValidate()
                    begin
                        if ShowAllAccounts then begin
                            PmtDiscountVisible := true;
                            PmtToleranceVisible := true;
                            SalesLineDiscVisible := true;
                            SalesInvDiscVisible := true;
                            PurchLineDiscVisible := true;
                            PurchInvDiscVisible := true;
                        end else
                            SetAccountsVisibility(
                              PmtToleranceVisible, PmtDiscountVisible, SalesInvDiscVisible, SalesLineDiscVisible, PurchInvDiscVisible, PurchLineDiscVisible);

                        CurrPage.Update();
                    end;
                }
            }
            group(General)
            {
                Caption = 'General';
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor''s or customer''s trade type to link transactions made for this business partner with the appropriate general ledger account according to the general posting setup.';
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the item''s product type to link transactions made for this item with the appropriate general ledger account according to the general posting setup.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the general posting setup.';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if this particular combination of general business posting group and general product posting group is blocked.';
                }
                field("View All Accounts on Lookup"; Rec."View All Accounts on Lookup")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that all possible accounts are shown when you look up from a field. If the check box is not selected, then only accounts related to the involved account category are shown.';
                }
            }
            group(Sales)
            {
                Caption = 'Sales';
                field("Sales Account"; Rec."Sales Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the general ledger sales account to which the program will post sales transactions with this particular combination of business group and product group.';
                }
                field("Sales Account (Freight)"; Rec."Sales Account (Freight)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Sales Credit Memo Account"; Rec."Sales Credit Memo Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general ledger account number to which the program will post transactions involving sales credit memos for this particular combination of business posting group and product posting group.';
                }
                field("Sales Line Disc. Account"; Rec."Sales Line Disc. Account")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the general ledger account number to post customer/item and quantity discounts when you post sales transactions with this particular combination of business group and product group.';
                    Visible = SalesLineDiscVisible;
                }
                field("Sales Inv. Disc. Account"; Rec."Sales Inv. Disc. Account")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the general ledger account number to which to post sales invoice discount amounts when you post sales transactions for this particular combination of business group and product group.';
                    Visible = SalesInvDiscVisible;
                }
                field("Sales Pmt. Disc. Debit Acc."; Rec."Sales Pmt. Disc. Debit Acc.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the general ledger account number to post granted sales payment discount amounts when you post payments for sales with this particular combination of business group and product group.';
                    Visible = PmtDiscountVisible;
                }
                field("Sales Pmt. Disc. Credit Acc."; Rec."Sales Pmt. Disc. Credit Acc.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the general ledger account number to which to post reductions in sales payment discount amounts when you post payments for sales with this particular combination of business group and product group.';
                    Visible = PmtDiscountVisible;
                }
                field("Sales Pmt. Tol. Debit Acc."; Rec."Sales Pmt. Tol. Debit Acc.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the number of the G/L account to which you want the program to post payment tolerance for purchases with this combination.';
                    Visible = PmtToleranceVisible;
                }
                field("Sales Pmt. Tol. Credit Acc."; Rec."Sales Pmt. Tol. Credit Acc.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the number of the G/L account to which you want the program to post payment tolerance for purchases with this combination.';
                    Visible = PmtToleranceVisible;
                }
                field("Sales Prepayments Account"; Rec."Sales Prepayments Account")
                {
                    ApplicationArea = Prepayments;
                    ToolTip = 'Specifies the general ledger account number to which to post sales prepayment amounts when you post prepayment invoices from a sales order for this particular combination of business group and product group.';
                }
                field("Sales Account (Accrual)"; Rec."Sales Account (Accrual)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Sales Plan Account (Accrual)"; Rec."Sales Plan Account (Accrual)")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Purchases)
            {
                Caption = 'Purchases';
                field("Purch. Account"; Rec."Purch. Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general ledger account number to which the program will post purchase transactions with this particular combination of business posting group and product posting group.';
                }
                field("Purch. Credit Memo Account"; Rec."Purch. Credit Memo Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general ledger account number to which the program will post transactions involving purchase credit memos for this particular combination of business posting group and product posting group.';
                }
                field("Purch. Line Disc. Account"; Rec."Purch. Line Disc. Account")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the general ledger account number to which to post purchase line discount amounts with this particular combination of business group and product group.';
                    Visible = PurchLineDiscVisible;
                }
                field("Purch. Inv. Disc. Account"; Rec."Purch. Inv. Disc. Account")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the general ledger account number to which to post purchase invoice discount amounts with this particular combination of business group and product group.';
                    Visible = PurchInvDiscVisible;
                }
                field("Purch. Pmt. Disc. Debit Acc."; Rec."Purch. Pmt. Disc. Debit Acc.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the general ledger account number to which to post reductions in purchase payment discount amounts when you post payments for purchases with this particular combination of business posting group and product posting group.';
                    Visible = PmtDiscountVisible;
                }
                field("Purch. Pmt. Disc. Credit Acc."; Rec."Purch. Pmt. Disc. Credit Acc.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the general ledger account number to which to post received purchase payment discount amounts when you post payments for purchases with this particular combination of business posting group and product posting group.';
                    Visible = PmtDiscountVisible;
                }
                field("Purch. FA Disc. Account"; Rec."Purch. FA Disc. Account")
                {
                    ApplicationArea = FixedAssets;
                    Importance = Additional;
                    ToolTip = 'Specifies the account that the line and invoice discount will be posted to when the Subtract Disc. in Purch. Inv. field is check marked.';
                }
                field("Purch. Pmt. Tol. Debit Acc."; Rec."Purch. Pmt. Tol. Debit Acc.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the number of the G/L account to which you want the program to post payment tolerance for purchases with this combination.';
                    Visible = PmtToleranceVisible;
                }
                field("Purch. Pmt. Tol. Credit Acc."; Rec."Purch. Pmt. Tol. Credit Acc.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the number of the G/L account to which you want the program to post payment tolerance for purchases with this combination.';
                    Visible = PmtToleranceVisible;
                }
                field("Purch. Prepayments Account"; Rec."Purch. Prepayments Account")
                {
                    ApplicationArea = Prepayments;
                    ToolTip = 'Specifies the general ledger account number to which to post purchase prepayment amounts when you post prepayment invoices from a purchase order for this particular combination of business group and product group.';
                }
                field("Purch. Account (Accrual)"; Rec."Purch. Account (Accrual)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Purch. Plan Account (Accrual)"; "Purch. Plan Account (Accrual)")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Inventory)
            {
                Caption = 'Inventory';
                field("COGS Account"; Rec."COGS Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general ledger account number to which to post the cost of goods sold with this particular combination of business group and product group.';
                }
                field("COGS Account (Interim)"; Rec."COGS Account (Interim)")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the interim G/L account number to which you want the program to post the expected cost of goods sold.';
                }
                field("Inventory Adjmt. Account"; Rec."Inventory Adjmt. Account")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the general ledger account number to which to post inventory adjustments (positive and negative) with this particular combination of business posting group and product posting group.';
                }
                field("Invt. Accrual Acc. (Interim)"; Rec."Invt. Accrual Acc. (Interim)")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the number of the G/L account to which you want the program to post expected inventory adjustments (positive and negative).';
                }
                field("Direct Cost Applied Account"; Rec."Direct Cost Applied Account")
                {
                    ApplicationArea = Assembly, Manufacturing;
                    Importance = Additional;
                    ToolTip = 'Specifies the general ledger account number to post the direct cost applied with this particular combination of business posting group and product posting group.';
                }
                field("Overhead Applied Account"; Rec."Overhead Applied Account")
                {
                    ApplicationArea = Assembly, Manufacturing;
                    Importance = Additional;
                    ToolTip = 'Specifies the general ledger account number to post the direct cost applied with this particular combination of business posting group and product posting group.';
                }
                field("ABC Direct Account"; Rec."ABC Direct Account")
                {
                    ApplicationArea = FOODBasic;
                }
                field("ABC Overhead Account"; Rec."ABC Overhead Account")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Purchase Variance Account"; Rec."Purchase Variance Account")
                {
                    ApplicationArea = Assembly, Manufacturing;
                    Importance = Additional;
                    ToolTip = 'Specifies the general ledger account number to post the direct cost applied with this particular combination of business posting group and product posting group.';
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
        area(navigation)
        {
            group("&Setup")
            {
                Caption = '&Setup';
                action("E&xtra Charges")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'E&xtra Charges';
                    Image = Costs;
                    RunObject = Page "Extra Charge Posting Setup";
                    RunPageLink = "Gen. Bus. Posting Group" = FIELD("Gen. Bus. Posting Group"),
                                  "Gen. Prod. Posting Group" = FIELD("Gen. Prod. Posting Group");
                }
            }
        }
        area(processing)
        {
            action(SuggestAccounts)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Suggest Accounts';
                Image = Default;
                ToolTip = 'Suggest G/L Accounts for selected setup.';

                trigger OnAction()
                begin
                    SuggestSetupAccounts();
                end;
            }
            action(Copy)
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Copy';
                Ellipsis = true;
                Image = Copy;
                ToolTip = 'Copy a record with selected fields or all fields from the general posting setup to a new record. Before you start to copy you have to create the new record.';

                trigger OnAction()
                begin
                    CurrPage.SaveRecord();
                    CopyGenPostingSetup.SetGenPostingSetup(Rec);
                    CopyGenPostingSetup.RunModal();
                    Clear(CopyGenPostingSetup);
                    CurrPage.Update();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Setup)
            {
                Caption = 'Setup';

                actionref(ExtraCharges_Promoted; "E&xtra Charges")
                {
                }
            }
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(SuggestAccounts_Promoted; SuggestAccounts)
                {
                }
                actionref(Copy_Promoted; Copy)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        SetAccountsVisibility(
          PmtToleranceVisible, PmtDiscountVisible, SalesInvDiscVisible, SalesLineDiscVisible, PurchInvDiscVisible, PurchLineDiscVisible);
    end;

    var
        CopyGenPostingSetup: Report "Copy - General Posting Setup";

    protected var
        PmtDiscountVisible: Boolean;
        PmtToleranceVisible: Boolean;
        SalesLineDiscVisible: Boolean;
        SalesInvDiscVisible: Boolean;
        PurchLineDiscVisible: Boolean;
        PurchInvDiscVisible: Boolean;
        ShowAllAccounts: Boolean;
}

