table 37002664 "Extra Charge Posting Setup"
{
    // PR3.70.05
    // P8000062B, Myers Nissi, Jack Reynolds, 18 JUN 04
    //   Field 14 - Direct Cost Applied Account (Renamed from Purchase Account)
    //   Field 15 - Invt. Accrual Acc. (Interim) - Code 20
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Extra Charge Posting Setup';

    fields
    {
        field(1; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
        }
        field(2; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            NotBlank = true;
            TableRelation = "Gen. Product Posting Group";
        }
        field(3; "Extra Charge Code"; Code[10])
        {
            Caption = 'Extra Charge Code';
            NotBlank = true;
            TableRelation = "Extra Charge";
        }
        field(14; "Direct Cost Applied Account"; Code[20])
        {
            Caption = 'Direct Cost Applied Account';
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAcc("Direct Cost Applied Account");
            end;
        }
        field(15; "Invt. Accrual Acc. (Interim)"; Code[20])
        {
            Caption = 'Invt. Accrual Acc. (Interim)';
            Description = 'PR3.70.05';
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAcc("Invt. Accrual Acc. (Interim)"); // P8000062B
            end;
        }
    }

    keys
    {
        key(Key1; "Gen. Bus. Posting Group", "Gen. Prod. Posting Group", "Extra Charge Code")
        {
        }
        key(Key2; "Extra Charge Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
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

    [Scope('Personalization')]
    procedure GetDirectCostAppliedAccount(): Code[20]
    begin
        // P80053245
        if "Direct Cost Applied Account" = '' then
            PostingSetupMgt.SendECPostingSetupNotification(Rec, FieldCaption("Direct Cost Applied Account"));
        TestField("Direct Cost Applied Account");
        exit("Direct Cost Applied Account");
    end;

    [Scope('Personalization')]
    procedure GetInventoryAccrualAccount(): Code[20]
    begin
        // P80053245
        if "Invt. Accrual Acc. (Interim)" = '' then
            PostingSetupMgt.SendECPostingSetupNotification(Rec, FieldCaption("Invt. Accrual Acc. (Interim)"));
        TestField("Invt. Accrual Acc. (Interim)");
        exit("Invt. Accrual Acc. (Interim)");
    end;
}

