table 37002122 "Accrual Posting Group"
{
    // PR3.61AC
    // 
    // PR4.00
    // P8000246A, Myers Nissi, Jack Reynolds, 05 OCT 05
    //   Add fields for Sales Account (Accrual) and Purch. Account (Accrual)
    // 
    // PRW17.10.03
    // P8001308, Columbus IT, Jack Reynolds, 01 APR 14
    //   Fix problem posting purcahse lines with type of Accrual Plan
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Accrual Posting Group';
    LookupPageID = "Accrual Posting Groups";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Sales Plan Account"; Code[20])
        {
            Caption = 'Sales Plan Account';
            TableRelation = "G/L Account";

            trigger OnLookup()
            begin
                // P80053245
                GLAccountCategoryMgt.LookupGLAccount("Sales Plan Account", GLAccountCategory."Account Category"::Expense, '');
            end;

            trigger OnValidate()
            begin
                // P80053245
                CheckGLAcc("Sales Plan Account");
            end;
        }
        field(4; "Purchase Plan Account"; Code[20])
        {
            Caption = 'Purchase Plan Account';
            TableRelation = "G/L Account";

            trigger OnLookup()
            begin
                // P80053245
                GLAccountCategoryMgt.LookupGLAccount("Purchase Plan Account", GLAccountCategory."Account Category"::Income, '');
            end;

            trigger OnValidate()
            begin
                // P80053245
                CheckGLAcc("Purchase Plan Account");
            end;
        }
        field(5; "Accrual Account"; Code[20])
        {
            Caption = 'Accrual Account';
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                // P80053245
                CheckGLAcc("Accrual Account");
            end;
        }
        field(6; "Sales Account (Accrual)"; Code[20])
        {
            Caption = 'Sales Account (Accrual)';
            TableRelation = "G/L Account";

            trigger OnLookup()
            begin
                // P80053245
                GLAccountCategoryMgt.LookupGLAccount("Sales Account (Accrual)", GLAccountCategory."Account Category"::Income, '');
            end;

            trigger OnValidate()
            begin
                // P80053245
                CheckGLAcc("Sales Account (Accrual)");
            end;
        }
        field(7; "Purch. Account (Accrual)"; Code[20])
        {
            Caption = 'Purch. Account (Accrual)';
            TableRelation = "G/L Account";

            trigger OnLookup()
            begin
                // P80053245
                GLAccountCategoryMgt.LookupGLAccount("Purch. Account (Accrual)", GLAccountCategory."Account Category"::Expense, '');
            end;

            trigger OnValidate()
            begin
                // P80053245
                CheckGLAcc("Purch. Account (Accrual)");
            end;
        }
        field(8; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        CheckAccrualEntries; // P80053245
    end;

    var
        YouCannotDeleteErr: Label 'You cannot delete %1.', Comment = '%1 = Code';
        GLAccountCategory: Record "G/L Account Category";
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        PostingSetupMgt: Codeunit PostingSetupManagement;

    local procedure CheckGLAcc(AccNo: Code[20])
    var
        GLAcc: Record "G/L Account";
    begin
        if AccNo <> '' then begin
            GLAcc.Get(AccNo);
            GLAcc.CheckGLAcc;
        end;
    end;

    local procedure CheckAccrualEntries()
    var
        AccrualPlan: Record "Accrual Plan";
        AccrualLedgerEntry: Record "Accrual Ledger Entry";
    begin
        // P80073095
        AccrualPlan.SetRange("Accrual Posting Group", Code);
        if not AccrualPlan.IsEmpty then
            Error(YouCannotDeleteErr, Code);

        AccrualLedgerEntry.SetRange("Accrual Posting Group", Code);
        if not AccrualLedgerEntry.IsEmpty then
            Error(YouCannotDeleteErr, Code);
        // P80073095
    end;

    [Scope('Personalization')]
    procedure GetSalesPlanAccount(): Code[20]
    begin
        // P80053245
        if "Sales Plan Account" = '' then
            PostingSetupMgt.SendAccrualPostingGroupNotification(Rec, FieldCaption("Sales Plan Account"));
        TestField("Sales Plan Account");
        exit("Sales Plan Account");
    end;

    [Scope('Personalization')]
    procedure GetPurchasePlanAccount(): Code[20]
    begin
        // P80053245
        if "Purchase Plan Account" = '' then
            PostingSetupMgt.SendAccrualPostingGroupNotification(Rec, FieldCaption("Purchase Plan Account"));
        TestField("Purchase Plan Account");
        exit("Purchase Plan Account");
    end;

    [Scope('Personalization')]
    procedure GetAccrualAccount(): Code[20]
    begin
        // P80053245
        if "Accrual Account" = '' then
            PostingSetupMgt.SendAccrualPostingGroupNotification(Rec, FieldCaption("Accrual Account"));
        TestField("Accrual Account");
        exit("Accrual Account");
    end;

    [Scope('Personalization')]
    procedure GetSalesAccountAccrual(): Code[20]
    begin
        // P80053245
        if "Sales Account (Accrual)" = '' then
            PostingSetupMgt.SendAccrualPostingGroupNotification(Rec, FieldCaption("Sales Account (Accrual)"));
        TestField("Sales Account (Accrual)");
        exit("Sales Account (Accrual)");
    end;

    [Scope('Personalization')]
    procedure GetPurchaseAccountAccrual(): Code[20]
    begin
        // P80053245
        if "Purch. Account (Accrual)" = '' then
            PostingSetupMgt.SendAccrualPostingGroupNotification(Rec, FieldCaption("Purch. Account (Accrual)"));
        TestField("Purch. Account (Accrual)");
        exit("Purch. Account (Accrual)");
    end;
}

