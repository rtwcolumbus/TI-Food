report 87 "Copy - General Posting Setup"
{
    // PR3.70.01
    //   Extra Charges
    // 
    // PR3.70.03
    //   Accruals
    // 
    // PR4.00.04
    // P8000375A, VerticalSoft, Jack Reynolds, 07 SEP 06
    //   Copy ABC Direct and ABC Overhead accounts
    // 
    // PRW16.00
    // P8000646, VerticalSoft, Jack Reynolds, 01 DEC 08
    //   Add Extra Charges to request page
    // 
    // PRW16.00.02
    // P8000756, VerticalSoft, Jack Reynolds, 15 JAN 10
    //   Set ExtraCharge flag in AllfieldsSelectionOnPush
    // 
    // PRW110.0.02
    // P80046442, To-Increase, Dayakar Battini, 07 Sep 17
    //   Product registration check provided for Extra Charges
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018

    Caption = 'Copy - General Posting Setup';
    ProcessingOnly = true;

    dataset
    {
        dataitem("General Posting Setup"; "General Posting Setup")
        {
            DataItemTableView = SORTING("Gen. Bus. Posting Group", "Gen. Prod. Posting Group");

            trigger OnAfterGetRecord()
            var
                ConfirmManagement: Codeunit "Confirm Management";
            begin
                GenPostingSetup.Find();
                if CopySales then begin
                    "Sales Account" := GenPostingSetup."Sales Account";
                    "Sales Credit Memo Account" := GenPostingSetup."Sales Credit Memo Account";
                    "Sales Line Disc. Account" := GenPostingSetup."Sales Line Disc. Account";
                    "Sales Inv. Disc. Account" := GenPostingSetup."Sales Inv. Disc. Account";
                    "Sales Pmt. Disc. Debit Acc." := GenPostingSetup."Sales Pmt. Disc. Debit Acc.";
                    "Sales Pmt. Disc. Credit Acc." := GenPostingSetup."Sales Pmt. Disc. Credit Acc.";
                    "Sales Pmt. Tol. Debit Acc." := GenPostingSetup."Sales Pmt. Tol. Debit Acc.";
                    "Sales Pmt. Tol. Credit Acc." := GenPostingSetup."Sales Pmt. Tol. Credit Acc.";
                    "Sales Prepayments Account" := GenPostingSetup."Sales Prepayments Account";
                    "Sales Account (Freight)" := GenPostingSetup."Sales Account (Freight)"; // P80053245
                    "Sales Account (Accrual)" := GenPostingSetup."Sales Account (Accrual)";           // PR3.70.03
                    "Sales Plan Account (Accrual)" := GenPostingSetup."Sales Plan Account (Accrual)"; // PR3.70.03
                end;

                if CopyPurchases then begin
                    "Purch. Account" := GenPostingSetup."Purch. Account";
                    "Purch. Credit Memo Account" := GenPostingSetup."Purch. Credit Memo Account";
                    "Purch. Line Disc. Account" := GenPostingSetup."Purch. Line Disc. Account";
                    "Purch. Inv. Disc. Account" := GenPostingSetup."Purch. Inv. Disc. Account";
                    "Purch. Pmt. Disc. Debit Acc." := GenPostingSetup."Purch. Pmt. Disc. Debit Acc.";
                    "Purch. Pmt. Disc. Credit Acc." := GenPostingSetup."Purch. Pmt. Disc. Credit Acc.";
                    "Purch. FA Disc. Account" := GenPostingSetup."Purch. FA Disc. Account";
                    "Purch. Pmt. Tol. Debit Acc." := GenPostingSetup."Purch. Pmt. Tol. Debit Acc.";
                    "Purch. Pmt. Tol. Credit Acc." := GenPostingSetup."Purch. Pmt. Tol. Credit Acc.";
                    "Purch. Prepayments Account" := GenPostingSetup."Purch. Prepayments Account";
                    "Purch. Account (Accrual)" := GenPostingSetup."Purch. Account (Accrual)";           // PR3.70.03
                    "Purch. Plan Account (Accrual)" := GenPostingSetup."Purch. Plan Account (Accrual)"; // PR3.70.03
                end;

                if CopyInventory then begin
                    "COGS Account" := GenPostingSetup."COGS Account";
                    "COGS Account (Interim)" := GenPostingSetup."COGS Account (Interim)";
                    "Inventory Adjmt. Account" := GenPostingSetup."Inventory Adjmt. Account";
                    "Invt. Accrual Acc. (Interim)" := GenPostingSetup."Invt. Accrual Acc. (Interim)";
                end;

                if CopyManufacturing then begin
                    "Direct Cost Applied Account" := GenPostingSetup."Direct Cost Applied Account";
                    "Overhead Applied Account" := GenPostingSetup."Overhead Applied Account";
                    "Purchase Variance Account" := GenPostingSetup."Purchase Variance Account";
                    "ABC Direct Account" := GenPostingSetup."ABC Direct Account";     // P8000375A
                    "ABC Overhead Account" := GenPostingSetup."ABC Overhead Account"; // P8000375A
                end;

                OnAfterCopyGenPostingSetup("General Posting Setup", GenPostingSetup, CopySales, CopyPurchases, CopyInventory, CopyManufacturing);

                if ConfirmManagement.GetResponseOrDefault(Text000, true) then begin                 // PR3.70.01
                    Modify();

                    if ExtraCharge then  // P80046442
                        ExtraChargeMgmt.CopyPostingSetup(GenPostingSetup, "General Posting Setup"); // PR3.70.01
                end;                                                                         // PR3.70.01
            end;

            trigger OnPreDataItem()
            begin
                SetRange("Gen. Bus. Posting Group", UseGenPostingSetup."Gen. Bus. Posting Group");
                SetRange("Gen. Prod. Posting Group", UseGenPostingSetup."Gen. Prod. Posting Group");
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
                    field(GenBusPostingGroup; GenPostingSetup."Gen. Bus. Posting Group")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Gen. Bus. Posting Group';
                        TableRelation = "Gen. Business Posting Group";
                        ToolTip = 'Specifies the general business posting group to copy from.';
                    }
                    field(GenProdPostingGroup; GenPostingSetup."Gen. Prod. Posting Group")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Gen. Prod. Posting Group';
                        TableRelation = "Gen. Product Posting Group";
                        ToolTip = 'Specifies general product posting group to copy from.';
                    }
                    field(Copy; Selection)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Copy';
                        OptionCaption = 'All fields,Selected fields';
                        ToolTip = 'Specifies if all fields or only selected fields are copied.';

                        trigger OnValidate()
                        begin
                            if Selection = Selection::"All fields" then
                                AllFieldsSelectionOnValidate();
                        end;
                    }
                    field(SalesAccounts; CopySales)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Sales Accounts';
                        ToolTip = 'Specifies if you want to copy sales accounts.';

                        trigger OnValidate()
                        begin
                            Selection := Selection::"Selected fields";
                        end;
                    }
                    field(PurchaseAccounts; CopyPurchases)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Purchase Accounts';
                        ToolTip = 'Specifies if you want to copy purchase accounts.';

                        trigger OnValidate()
                        begin
                            Selection := Selection::"Selected fields";
                        end;
                    }
                    field(InventoryAccounts; CopyInventory)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Inventory Accounts';
                        ToolTip = 'Specifies if you want to copy inventory accounts.';

                        trigger OnValidate()
                        begin
                            Selection := Selection::"Selected fields";
                        end;
                    }
                    field(ManufacturingAccounts; CopyManufacturing)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Manufacturing Accounts';
                        ToolTip = 'Specifies if you want to copy manufacturing accounts.';

                        trigger OnValidate()
                        begin
                            Selection := Selection::"Selected fields";
                        end;
                    }
                    field(ExtraCharge; ExtraCharge)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Extra Charge Accounts';
                        Visible = ExtraChargeEnabled;

                        trigger OnValidate()
                        begin
                            Selection := Selection::"Selected fields"; // PR3.70.01
                        end;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            if Selection = Selection::"All fields" then begin
                CopySales := true;
                CopyPurchases := true;
                CopyInventory := true;
                CopyManufacturing := true;
            end;
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        ExtraChargeEnabled := ProcessFns.FreshProInstalled;  // P80046442
    end;

    var
        UseGenPostingSetup: Record "General Posting Setup";
        GenPostingSetup: Record "General Posting Setup";
        CopySales: Boolean;
        CopyPurchases: Boolean;
        CopyInventory: Boolean;
        CopyManufacturing: Boolean;
        ExtraCharge: Boolean;
        ExtraChargeMgmt: Codeunit "Extra Charge Management";
        ProcessFns: Codeunit "Process 800 Functions";
        [InDataSet]
        ExtraChargeEnabled: Boolean;

        Text000: Label 'Copy General Posting Setup?';

    protected var
        Selection: Option "All fields","Selected fields";

    procedure SetGenPostingSetup(GenPostingSetup2: Record "General Posting Setup")
    begin
        UseGenPostingSetup := GenPostingSetup2;
    end;

    local procedure AllFieldsSelectionOnPush()
    begin
        CopySales := true;
        CopyPurchases := true;
        CopyInventory := true;
        CopyManufacturing := true;
        ExtraCharge := ExtraChargeEnabled; // PR3.70.01  // P80046442
    end;

    local procedure AllFieldsSelectionOnValidate()
    begin
        AllFieldsSelectionOnPush();
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnAfterCopyGenPostingSetup(var ToGeneralPostingSetup: Record "General Posting Setup"; FromGeneralPostingSetup: Record "General Posting Setup"; var CopySales: Boolean; var CopyPurchases: Boolean; var CopyInventory: Boolean; var CopyManufacturing: Boolean)
    begin
    end;
}

