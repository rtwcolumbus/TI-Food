table 37002134 "Document Accrual Line"
{
    // PR3.61AC
    // 
    // PRW16.00.01
    // P8000694, VerticalSoft, Jack Reynolds, 04 MAY 09
    //   Change name of Accrual fields
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Document Accrual Line';
    DrillDownPageID = "Document Accrual Lines";
    LookupPageID = "Document Accrual Lines";

    fields
    {
        field(1; "Accrual Plan Type"; Option)
        {
            Caption = 'Accrual Plan Type';
            OptionCaption = 'Sales,Purchase';
            OptionMembers = Sales,Purchase;
        }
        field(2; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = IF ("Accrual Plan Type" = CONST(Sales)) "Sales Header"."No." WHERE("Document Type" = FIELD("Document Type"))
            ELSE
            IF ("Accrual Plan Type" = CONST(Purchase)) "Purchase Header"."No." WHERE("Document Type" = FIELD("Document Type"));
        }
        field(4; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            TableRelation = IF ("Accrual Plan Type" = CONST(Sales)) "Sales Line"."Line No." WHERE("Document Type" = FIELD("Document Type"),
                                                                                                 "Document No." = FIELD("Document No."))
            ELSE
            IF ("Accrual Plan Type" = CONST(Purchase)) "Purchase Line"."Line No." WHERE("Document Type" = FIELD("Document Type"),
                                                                                                                                                                                 "Document No." = FIELD("Document No."));
        }
        field(5; "Accrual Plan No."; Code[20])
        {
            Caption = 'Accrual Plan No.';
            TableRelation = "Accrual Plan"."No." WHERE(Type = FIELD("Accrual Plan Type"),
                                                        "Plan Type" = FIELD("Plan Type"),
                                                        "Computation Level" = FIELD("Computation Level"));

            trigger OnValidate()
            begin
                AccrualPlan.Get("Accrual Plan Type", "Accrual Plan No.");
                if (CurrFieldNo = FieldNo("Accrual Plan No.")) and IsNewRecord() then
                    AccrualPlan.TestField("Edit Accrual on Document", true);
                "Plan Type" := AccrualPlan."Plan Type";
                "Computation Level" := AccrualPlan."Computation Level";
                "Price Impact" := AccrualPlan."Price Impact";
            end;
        }
        field(6; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Customer,Vendor,G/L Account';
            OptionMembers = Customer,Vendor,"G/L Account";

            trigger OnValidate()
            begin
                if (Type <> xRec.Type) then
                    Validate("No.", '');
            end;
        }
        field(7; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type = CONST(Customer)) Customer
            ELSE
            IF (Type = CONST(Vendor)) Vendor
            ELSE
            IF (Type = CONST("G/L Account")) "G/L Account";

            trigger OnValidate()
            begin
                Description := GetDescription();
            end;
        }
        field(8; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(9; "Accrual Amount (LCY)"; Decimal)
        {
            Caption = 'Accrual Amount (LCY)';
            Editable = false;
            MinValue = 0;

            trigger OnValidate()
            begin
                Validate("Payment Amount (LCY)", Round("Accrual Amount (LCY)" * ("Payment %" / 100)));
            end;
        }
        field(10; "Payment %"; Decimal)
        {
            Caption = 'Payment %';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                if ("Payment %" <> 0) then
                    TestField("Accrual Amount (LCY)");
                Validate("Accrual Amount (LCY)");
            end;
        }
        field(11; "Payment Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Payment Amount (LCY)';
            MinValue = 0;

            trigger OnValidate()
            begin
                if ("Accrual Amount (LCY)" = 0) then
                    "Payment %" := 0
                else
                    "Payment %" := ("Payment Amount (LCY)" / "Accrual Amount (LCY)") * 100;
            end;
        }
        field(12; "Plan Type"; Option)
        {
            Caption = 'Plan Type';
            Editable = false;
            OptionCaption = 'Promo/Rebate,Commission';
            OptionMembers = "Promo/Rebate",Commission;
        }
        field(13; "Price Impact"; Option)
        {
            Caption = 'Price Impact';
            Editable = false;
            OptionCaption = 'None,Exclude from Price,Include in Price';
            OptionMembers = "None","Exclude from Price","Include in Price";
        }
        field(14; "Edit Accrual on Document"; Boolean)
        {
            CalcFormula = Lookup ("Accrual Plan"."Edit Accrual on Document" WHERE(Type = FIELD("Accrual Plan Type"),
                                                                                  "No." = FIELD("Accrual Plan No.")));
            Caption = 'Edit Accrual on Document';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "Orig. Payment Amount (LCY)"; Decimal)
        {
            Caption = 'Orig. Payment Amount (LCY)';
            Editable = false;
        }
        field(16; "Computation Level"; Option)
        {
            Caption = 'Computation Level';
            Editable = false;
            OptionCaption = 'Document Line,Document,Plan';
            OptionMembers = "Document Line",Document,Plan;
        }
    }

    keys
    {
        key(Key1; "Accrual Plan Type", "Plan Type", "Computation Level", "Document Type", "Document No.", "Document Line No.", "Accrual Plan No.", Type, "No.", "Price Impact")
        {
            SumIndexFields = "Payment %", "Payment Amount (LCY)";
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if AccrualPlan.Get("Accrual Plan Type", "Accrual Plan No.") then
            AccrualPlan.TestField("Edit Accrual on Document", true);
    end;

    trigger OnInsert()
    begin
        TestField("Document No.");
        TestField("Accrual Plan No.");
        TestField("No.");
    end;

    var
        Text000: Label '%1 cannot be greater than %2.';
        AccrualPlan: Record "Accrual Plan";
        Text001: Label '%1 %2 Plans';
        Text002: Label '%1 Plans';

    procedure GetCaption() CaptionText: Text[250]
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
    begin
        FilterGroup(3);
        if (GetFilter("Accrual Plan Type") = '') then
            FilterGroup(0);
        if (GetFilter("Accrual Plan Type") <> '') then
            if (GetFilter("Plan Type") <> '') then
                CaptionText := StrSubstNo(Text001, GetFilter("Accrual Plan Type"), GetFilter("Plan Type"))
            else
                CaptionText := StrSubstNo(Text002, GetFilter("Accrual Plan Type"));
        FilterGroup(0);

        if (CaptionText <> '') and (GetFilter("Document No.") <> '') then begin
            CaptionText :=
              StrSubstNo('%1 - %2 %3', CaptionText, GetFilter("Document Type"), GetFilter("Document No."));
            if (GetFilter("Document Line No.") <> '') then
                if (GetRangeMin("Document Line No.") = GetRangeMax("Document Line No.")) then
                    if (GetRangeMin("Accrual Plan Type") = "Accrual Plan Type"::Sales) then begin
                        if SalesLine.Get(GetRangeMin("Document Type"),
                                         GetRangeMin("Document No."),
                                         GetRangeMin("Document Line No."))
                        then
                            CaptionText :=
                              StrSubstNo('%1 - %2 %3', CaptionText, SalesLine.Type, SalesLine."No.");
                    end else begin
                        if PurchLine.Get(GetRangeMin("Document Type"),
                                         GetRangeMin("Document No."),
                                         GetRangeMin("Document Line No."))
                        then
                            CaptionText :=
                              StrSubstNo('%1 - %2 %3', CaptionText, PurchLine.Type, PurchLine."No.");
                    end;
        end;
    end;

    procedure GetDescription(): Text[100]
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        GLAccount: Record "G/L Account";
    begin
        case Type of
            Type::Customer:
                if Customer.Get("No.") then
                    exit(Customer.Name);
            Type::Vendor:
                if Vendor.Get("No.") then
                    exit(Vendor.Name);
            Type::"G/L Account":
                if GLAccount.Get("No.") then
                    exit(GLAccount.Name);
        end;
        exit('');
    end;

    procedure IsNewRecord(): Boolean
    var
        OldRec: Record "Document Accrual Line";
    begin
        OldRec := Rec;
        exit(not OldRec.Find);
    end;

    procedure AccrualPlanLookup(var Text: Text[1024]): Boolean
    begin
        AccrualPlan.Reset;
        AccrualPlan.SetRange(Type, "Accrual Plan Type");
        AccrualPlan.SetRange("Plan Type", "Plan Type");
        AccrualPlan.SetRange("Computation Level", "Computation Level");
        if IsNewRecord() then
            AccrualPlan.SetRange("Edit Accrual on Document", true);
        AccrualPlan.SetFilter("No.", Text);
        if AccrualPlan.Find('-') then;
        AccrualPlan.SetRange("No.");
        if (PAGE.RunModal(0, AccrualPlan) <> ACTION::LookupOK) then
            exit(false);
        Text := AccrualPlan."No.";
        exit(true);
    end;
}

