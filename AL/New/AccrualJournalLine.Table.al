table 37002127 "Accrual Journal Line"
{
    // PR3.70.03
    // 
    // PR3.70.07
    // P8000119A, Myers Nissi, Don Bresee, 20 SEP 04
    //   Accruals update/fixes
    // 
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PR4.00.01
    // P8000267B, VerticalSoft, Jack Reynolds, 12 DEC 05
    //   Change dimension code processing to with respect to MODIFY to be in line with similar changes in the
    //     standard tables for SP1
    // 
    // P8000274A, VerticalSoft, Jack Reynolds, 22 DEC 05
    //   Fix problems with resolving start and end dates for plan
    // 
    // PR4.00.06
    // P8000474A, VerticalSoft, Jack Reynolds, 23 MAY 07
    //   Validate shortcut dimension codes to populate journal line dimension table
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds 17 NOV 13
    //   Lookup of Shortcut Dimensions, Standardize OpenedFromBatch
    // 
    // PRW110.0.01
    // P8008663, To-Increase, Jack Reynolds 21 APR 17
    //   Payments in foreign currencies
    // 
    // PRW110.0.02
    // P80048075, To-Increase, Dayakar Battini, 31 OCT 17
    //   "External Document No." field length from Code20 to Code35
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.02
    // P80068489, To Increase, Gangabhushan, 31 DEC 18
    //   TI-12522 - VAT issues for accruals process
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    //
    // PRW114.00.03
    // P800131317, To Increase, Gangabhushan, 12 OCT 21
    //   CS00187520 | Promo/Rebates w "Post Payment w/Document" are causing inconsistency to GL error

    Caption = 'Accrual Journal Line';

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Accrual Journal Template";
        }
        field(2; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Accrual Journal Batch".Name WHERE("Journal Template Name" = FIELD("Journal Template Name"));
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; "Accrual Plan Type"; Option)
        {
            Caption = 'Accrual Plan Type';
            OptionCaption = 'Sales,Purchase';
            OptionMembers = Sales,Purchase;

            trigger OnValidate()
            begin
                if ("Accrual Plan Type" <> xRec."Accrual Plan Type") then
                    Validate("Accrual Plan No.", '');
            end;
        }
        field(5; "Accrual Plan No."; Code[20])
        {
            Caption = 'Accrual Plan No.';
            TableRelation = "Accrual Plan"."No." WHERE(Type = FIELD("Accrual Plan Type"));

            trigger OnValidate()
            begin
                DefaultFromPlan;

                CreateDim(
                  DATABASE::"Accrual Plan", "Accrual Plan No.",
                  TypeToTableID(Type), "No.",
                  DATABASE::Item, "Item No.");
            end;
        }
        field(6; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'Accrual,Payment';
            OptionMembers = Accrual,Payment;

            trigger OnValidate()
            begin
                GetAccrualPlan;
                if ("Entry Type" = "Entry Type"::Payment) and
                   (AccrualPlan."Plan Type" = AccrualPlan."Plan Type"::Reporting)
                then
                    AccrualPlan.FieldError("Plan Type");
                Validate("Accrual Plan No.");
            end;
        }
        field(7; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Editable = false;
            TableRelation = Item;

            trigger OnValidate()
            begin
                GetAccrualPlan;
                AccrualFldMgmt.CheckItem(
                  AccrualPlan, "Entry Type", "Source No.", "Source Document Type",
                  "Source Document No.", "Source Document Line No.", "Item No.");

                CreateDim(
                  DATABASE::"Accrual Plan", "Accrual Plan No.",
                  TypeToTableID(Type), "No.",
                  DATABASE::Item, "Item No.");
            end;
        }
        field(8; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            TableRelation = IF ("Accrual Plan Type" = CONST(Sales)) Customer
            ELSE
            IF ("Accrual Plan Type" = CONST(Purchase)) Vendor;

            trigger OnValidate()
            begin
                if ("Source No." <> xRec."Source No.") then
                    Validate("Source Document No.", '');

                if ("Source No." = '') then
                    Validate("Source Document Type", "Source Document Type"::None)
                else begin
                    GetAccrualPlan;
                    AccrualPlan.CheckPostingLevel("Entry Type", AccrualPlan."Accrual Posting Level"::Source);
                    AccrualFldMgmt.CheckSource(AccrualPlan, "Entry Type", "Source No.", "Source No.", 0D); // P8000274A

                    if ("Entry Type" = "Entry Type"::Accrual) then begin
                        Type := "Accrual Plan Type";
                        SetNoFromSource;
                    end else
                        case AccrualPlan."Payment Type" of
                            AccrualPlan."Payment Type"::"Source Bill-to/Pay-to":
                                begin
                                    Type := "Accrual Plan Type";
                                    SetNoFromSource;
                                end;
                            AccrualPlan."Payment Type"::Customer .. AccrualPlan."Payment Type"::"G/L Account":
                                begin
                                    Type := AccrualPlan."Payment Type" - AccrualPlan."Payment Type"::Customer;
                                    Validate("No.", AccrualPlan."Payment Code");
                                end;
                            else begin
                                    Type := "Accrual Plan Type";
                                    Validate("No.", '');
                                end;
                        end;
                end;
            end;
        }
        field(9; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Customer,Vendor,G/L Account';
            OptionMembers = Customer,Vendor,"G/L Account";

            trigger OnValidate()
            begin
                if ("Entry Type" = "Entry Type"::Accrual) then
                    TestField(Type, "Accrual Plan Type");

                if (Type <> xRec.Type) then
                    Validate("No.", '');
            end;
        }
        field(10; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type = CONST(Customer)) Customer
            ELSE
            IF (Type = CONST(Vendor)) Vendor
            ELSE
            IF (Type = CONST("G/L Account"),
                                     "Entry Type" = CONST(Payment)) "G/L Account";

            trigger OnValidate()
            begin
                if ("Entry Type" = "Entry Type"::Accrual) and ("Accrual Plan No." <> '') then begin
                    GetAccrualPlan;
                    if (AccrualPlan."Source Selection Type" =
                        AccrualPlan."Source Selection Type"::"Bill-to/Pay-to")
                    then
                        TestField("No.", "Source No.");
                end;

                "Currency Code" := ''; // P8008663
                if ("No." = '') then
                    Description := ''
                else begin
                    TestField("Accrual Plan No.");
                    GetAccrualPlan;
                    if (AccrualPlan.GetPostingLevel("Entry Type") <> AccrualPlan."Accrual Posting Level"::Plan) then
                        TestField("Source No.");
                    case Type of
                        Type::Customer:
                            begin
                                Customer.Get("No.");
                                Customer.CheckBlockedCustOnJnls(Customer, 0, false);  // PR3.70.03
                                Description := Customer.Name;
                                if "Entry Type" = "Entry Type"::Payment then   // P8008663
                                    "Currency Code" := Customer."Currency Code"; // P8008663
                            end;
                        Type::Vendor:
                            begin
                                Vendor.Get("No.");
                                Vendor.CheckBlockedVendOnJnls(Vendor, 0, false);  // PR3.70.03
                                Description := Vendor.Name;
                                if "Entry Type" = "Entry Type"::Payment then // P8008663
                                    "Currency Code" := Vendor."Currency Code";  // P8008663
                            end;
                        Type::"G/L Account":
                            begin
                                GLAccount.Get("No.");
                                GLAccount.CheckGLAcc;
                                GLAccount.TestField("Direct Posting", true);
                                Description := GLAccount.Name;
                            end;
                    end;
                end;

                Validate("Currency Code"); // P8008663
                SetDueDateFromSource;

                CreateDim(
                  DATABASE::"Accrual Plan", "Accrual Plan No.",
                  TypeToTableID(Type), "No.",
                  DATABASE::Item, "Item No.");
            end;
        }
        field(11; "Source Document Type"; Option)
        {
            Caption = 'Source Document Type';
            OptionCaption = 'None,Shipment,Receipt,Invoice,Credit Memo';
            OptionMembers = "None",Shipment,Receipt,Invoice,"Credit Memo";

            trigger OnValidate()
            begin
                if ("Source Document Type" <> xRec."Source Document Type") then
                    Validate("Source Document No.", '');

                if ("Source Document Type" <> "Source Document Type"::None) then begin
                    GetAccrualPlan;
                    AccrualPlan.CheckPostingLevel("Entry Type", AccrualPlan."Accrual Posting Level"::Document);
                    AccrualFldMgmt.CheckSourceDocType(AccrualPlan, "Entry Type", "Source Document Type");

                    SetDueDateFromSource;
                end;
            end;
        }
        field(12; "Source Document No."; Code[20])
        {
            Caption = 'Source Document No.';

            trigger OnValidate()
            begin
                if ("Source Document No." <> xRec."Source Document No.") then
                    Validate("Source Document Line No.", 0);

                if ("Source Document No." <> '') then
                    ValidateSourceDoc;
            end;
        }
        field(13; "Source Document Line No."; Integer)
        {
            Caption = 'Source Document Line No.';

            trigger OnValidate()
            begin
                if ("Source Document Line No." <> xRec."Source Document Line No.") then
                    Validate("Item No.", '');

                if ("Source Document Line No." <> 0) then
                    ValidateSourceDocLine;
            end;
        }
        field(14; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';

            trigger OnValidate()
            var
                CurrExchRate: Record "Currency Exchange Rate";
            begin
                // P8008663
                if "Currency Code" = '' then
                    "Amount (FCY)" := Amount
                else begin
                    GetCurrency;
                    "Amount (FCY)" := Round(
                        CurrExchRate.ExchangeAmtLCYToFCY(
                          "Posting Date", "Currency Code",
                          Amount, "Currency Factor"),
                          Currency."Amount Rounding Precision")
                end;
                // P8008663
            end;
        }
        field(15; "Posting Date"; Date)
        {
            Caption = 'Posting Date';

            trigger OnValidate()
            begin
                Validate("Document Date", "Posting Date");
                Validate("Currency Code"); // P8008663
            end;
        }
        field(16; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(17; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(18; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            Editable = false;
            TableRelation = "Source Code";
        }
        field(19; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(20; "Document Date"; Date)
        {
            Caption = 'Document Date';

            trigger OnValidate()
            begin
                SetDueDateFromSource;
            end;
        }
        field(21; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(22; "Posting No. Series"; Code[20])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";
        }
        field(23; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code"); // P8000474A
            end;
        }
        field(24; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code"); // P8000474A
            end;
        }
        field(25; "Recurring Method"; Option)
        {
            BlankZero = true;
            Caption = 'Recurring Method';
            OptionCaption = ',Fixed,Variable';
            OptionMembers = ,"Fixed",Variable;
        }
        field(26; "Recurring Frequency"; DateFormula)
        {
            Caption = 'Recurring Frequency';
        }
        field(27; "Accrual Posting Group"; Code[20])
        {
            Caption = 'Accrual Posting Group';
            TableRelation = "Accrual Posting Group";
        }
        field(28; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
        }
        field(29; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
        }
        field(30; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
        field(31; "Price Impact"; Option)
        {
            Caption = 'Price Impact';
            Editable = false;
            OptionCaption = 'None,Exclude from Price,Include in Price';
            OptionMembers = "None","Exclude from Price","Include in Price";
        }
        field(32; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(33; "Scheduled Accrual No."; Code[10])
        {
            Caption = 'Scheduled Accrual No.';

            trigger OnValidate()
            begin
                ValidateAccrualSchdLine;
            end;
        }
        field(41; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;

            trigger OnValidate()
            var
                CurrExchRate: Record "Currency Exchange Rate";
            begin
                // P8008663
                if "Currency Code" <> '' then begin
                    GetCurrency;
                    if ("Currency Code" <> xRec."Currency Code") or
                       ("Posting Date" <> xRec."Posting Date") or
                       (CurrFieldNo = FieldNo("Currency Code")) or
                       ("Currency Factor" = 0)
                    then
                        "Currency Factor" :=
                          CurrExchRate.ExchangeRate("Posting Date", "Currency Code");
                end else
                    "Currency Factor" := 0;
                Validate("Currency Factor");
                Validate(Amount);
            end;
        }
        field(42; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
            MinValue = 0;
        }
        field(43; "Amount (FCY)"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount (FCY)';
            Editable = false;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                // P8001133
                ShowDimensions;
            end;
        }
    }

    keys
    {
        key(Key1; "Journal Template Name", "Journal Batch Name", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        LockTable;
        AccrualJnlTemplate.Get("Journal Template Name");
        AccrualJnlBatch.Get("Journal Template Name", "Journal Batch Name");
    end;

    var
        AccrualJnlTemplate: Record "Accrual Journal Template";
        AccrualJnlBatch: Record "Accrual Journal Batch";
        AccrualJnlLine: Record "Accrual Journal Line";
        AccrualPlan: Record "Accrual Plan";
        Customer: Record Customer;
        Vendor: Record Vendor;
        GLAccount: Record "G/L Account";
        Item: Record Item;
        Currency: Record Currency;
        AccrualGroup: Record "Accrual Group";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DimMgt: Codeunit DimensionManagement;
        Text000: Label '%1 is not a valid %2 for %3 %4.';
        Text001: Label '%1 %2 %3 for %4';
        AccrualFldMgmt: Codeunit "Accrual Field Management";

    procedure EmptyLine(): Boolean
    begin
        exit(("Accrual Plan No." = '') and (Amount = 0));
    end;

    procedure SetUpNewLine(LastAccrualJnlLine: Record "Accrual Journal Line")
    begin
        AccrualJnlTemplate.Get("Journal Template Name");
        AccrualJnlBatch.Get("Journal Template Name", "Journal Batch Name");
        AccrualJnlLine.SetRange("Journal Template Name", "Journal Template Name");
        AccrualJnlLine.SetRange("Journal Batch Name", "Journal Batch Name");
        if AccrualJnlLine.Find('-') then begin
            "Posting Date" := LastAccrualJnlLine."Posting Date";
            "Document Date" := LastAccrualJnlLine."Posting Date";
            "Document No." := LastAccrualJnlLine."Document No.";
        end else begin
            "Posting Date" := WorkDate;
            "Document Date" := WorkDate;
            if AccrualJnlBatch."No. Series" <> '' then begin
                Clear(NoSeriesMgt);
                "Document No." := NoSeriesMgt.TryGetNextNo(AccrualJnlBatch."No. Series", "Posting Date");
            end;
        end;
        "Recurring Method" := LastAccrualJnlLine."Recurring Method";
        "Entry Type" := LastAccrualJnlLine."Entry Type";
        "Accrual Plan Type" := LastAccrualJnlLine."Accrual Plan Type";
        "Accrual Plan No." := LastAccrualJnlLine."Accrual Plan No.";
        Type := LastAccrualJnlLine.Type;
        "Source Code" := AccrualJnlTemplate."Source Code";
        "Reason Code" := AccrualJnlBatch."Reason Code";
        "Posting No. Series" := AccrualJnlBatch."Posting No. Series";

        Validate("Accrual Plan No.");
    end;

    procedure TypeToTableID(TypeValue: Integer): Integer
    begin
        case TypeValue of
            Type::Customer:
                exit(DATABASE::Customer);
            Type::Vendor:
                exit(DATABASE::Vendor);
            Type::"G/L Account":
                exit(DATABASE::"G/L Account");
        end;
    end;

    procedure CreateDim(Type1: Integer; No1: Code[20]; Type2: Integer; No2: Code[20]; Type3: Integer; No3: Code[20])
    var
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        TableID[1] := Type1;
        No[1] := No1;
        TableID[2] := Type2;
        No[2] := No2;
        TableID[3] := Type3;
        No[3] := No3;
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        "Dimension Set ID" := DimMgt.GetDefaultDimID( // P8001133
          TableID, No, "Source Code",
          "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0); // P8001133
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID"); // P8001133
    end;

    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20])
    begin
        DimMgt.GetShortcutDimensions("Dimension Set ID", ShortcutDimCode); // P8001133
    end;

    procedure ShowDimensions()
    begin
        // P8001133
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet(
            "Dimension Set ID", StrSubstNo('%1 %2 %3', "Journal Template Name", "Journal Batch Name", "Line No."),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    local procedure GetAccrualPlan()
    begin
        if ("Accrual Plan No." = '') then
            Clear(AccrualPlan)
        else
            if ("Accrual Plan Type" <> AccrualPlan.Type) or
               ("Accrual Plan No." <> AccrualPlan."No.")
       then
                AccrualPlan.Get("Accrual Plan Type", "Accrual Plan No.");
    end;

    local procedure SetNoFromSource()
    begin
        if (AccrualPlan."Source Selection Type" =
            AccrualPlan."Source Selection Type"::"Bill-to/Pay-to")
        then
            Validate("No.", "Source No.")
        else
            Validate("No.", '');
    end;

    local procedure SetNoFromSourceDoc(BillToPayToNo: Code[20])
    begin
        if (Type = AccrualPlan.Type) and ("No." <> BillToPayToNo) then
            if (("Entry Type" = "Entry Type"::Accrual) and
                (AccrualPlan."Source Selection Type" =
                 AccrualPlan."Source Selection Type"::"Bill-to/Pay-to")) or
               (("Entry Type" = "Entry Type"::Payment) and
                (AccrualPlan."Payment Type" =
                 AccrualPlan."Payment Type"::"Source Bill-to/Pay-to"))
            then
                Validate("No.", BillToPayToNo);
    end;

    procedure SetDueDateFromSource()
    var
        TermsCode: Code[10];
        PaymentTerms: Record "Payment Terms";
    begin
        if ("Entry Type" = "Entry Type"::Payment) and ("No." <> '') and
           (Type <> Type::"G/L Account") and (Type <> "Accrual Plan Type")
        then
            if ("Document Date" = 0D) then
                "Due Date" := 0D
            else begin
                case Type of
                    Type::Customer:
                        begin
                            Customer.Get("No.");
                            TermsCode := Customer."Payment Terms Code";
                        end;
                    Type::Vendor:
                        begin
                            Vendor.Get("No.");
                            TermsCode := Vendor."Payment Terms Code";
                        end;
                end;
                if (TermsCode <> '') then begin
                    PaymentTerms.Get(TermsCode);
                    if (("Source Document Type" = "Source Document Type"::"Credit Memo") or
                        (("Accrual Plan Type" = "Accrual Plan Type"::Sales) and
                         ("Source Document Type" = "Source Document Type"::Receipt)) or
                        (("Accrual Plan Type" = "Accrual Plan Type"::Purchase) and
                         ("Source Document Type" = "Source Document Type"::Shipment))) and
                       (not PaymentTerms."Calc. Pmt. Disc. on Cr. Memos")
                    then
                        "Due Date" := 0D
                    else
                        "Due Date" := CalcDate(PaymentTerms."Due Date Calculation", "Document Date");
                end;
            end;
    end;

    local procedure SetDueDateFromSourceDoc(NewDueDate: Date)
    begin
        if ("Entry Type" <> "Entry Type"::Payment) or (Type = "Accrual Plan Type") or ("Due Date" = 0D) then
            "Due Date" := NewDueDate;
    end;

    local procedure DefaultFromPlan()
    begin
        if ("Accrual Plan No." = '') then
            Validate("Source Document Type", "Source Document Type"::None)
        else begin
            GetAccrualPlan;
            if ("Entry Type" = "Entry Type"::Accrual) then
                Validate(Type, "Accrual Plan Type");
            if (AccrualPlan.GetPostingLevel("Entry Type") < AccrualPlan."Accrual Posting Level"::Document) then
                Validate("Source Document Type", "Source Document Type"::None)
            else begin
                if (AccrualPlan."Source Selection" = AccrualPlan."Source Selection"::Specific) then
                    Validate("Source No.", AccrualPlan."Source Code")
                else
                    Validate("Source No.", '');
                if (AccrualPlan.Accrue = AccrualPlan.Accrue::"Shipments/Receipts") then
                    Validate("Source Document Type", "Source Document Type"::Shipment + "Accrual Plan Type")
                else
                    Validate("Source Document Type", "Source Document Type"::Invoice);
            end;
            if (AccrualPlan."Plan Type" = AccrualPlan."Plan Type"::Reporting) then
                Validate("Accrual Posting Group", '')
            else begin
                AccrualPlan.TestField("Accrual Posting Group");
                Validate("Accrual Posting Group", AccrualPlan."Accrual Posting Group");
            end;
        end;
        Validate("Source Document No.", '');
    end;

    local procedure ValidateSourceDoc()
    var
        BillToPayToNo: Code[20];
        DueDate: Date;
    begin
        TestField("Source No.");
        if ("Source Document Type" = "Source Document Type"::None) then
            FieldError("Source Document Type");

        GetAccrualPlan;
        AccrualPlan.CheckPostingLevel("Entry Type", AccrualPlan."Accrual Posting Level"::Document);
        AccrualFldMgmt.CheckSourceDocNo(
          AccrualPlan, "Entry Type", "Source Document Type",
          "Source Document No.", BillToPayToNo, DueDate);
        SetNoFromSourceDoc(BillToPayToNo);
        SetDueDateFromSourceDoc(DueDate);
    end;

    local procedure ValidateSourceDocLine()
    var
        ItemNo: Code[20];
        DummyVATprodPosGrp: Code[20];
    begin
        TestField("Source Document No.");

        GetAccrualPlan;
        AccrualPlan.CheckPostingLevel("Entry Type", AccrualPlan."Accrual Posting Level"::"Document Line");
        AccrualFldMgmt.CheckSourceDocLineNo(
          AccrualPlan, "Entry Type", "Source Document Type", "Source Document No.",
          "Source Document Line No.", ItemNo, "Gen. Bus. Posting Group", "Gen. Prod. Posting Group", DummyVATprodPosGrp, "Entry Type" = "Entry Type"::Accrual); // P80068489
        Validate("Item No.", ItemNo);
    end;

    local procedure ValidateAccrualSchdLine()
    var
        AccrualSchdLine: Record "Accrual Plan Schedule Line";
    begin
        if ("Scheduled Accrual No." <> '') then begin
            TestField("Accrual Plan No.");
            GetAccrualPlan;
            if ("Entry Type" = "Entry Type"::Accrual) then
                AccrualPlan.TestField("Use Accrual Schedule", true)
            else
                AccrualPlan.TestField("Use Payment Schedule", true);

            AccrualSchdLine.SetCurrentKey(
              "Accrual Plan Type", "Accrual Plan No.", "Entry Type", "No.");
            AccrualSchdLine.SetRange("Accrual Plan Type", "Accrual Plan Type");
            AccrualSchdLine.SetRange("Accrual Plan No.", "Accrual Plan No.");
            AccrualSchdLine.SetRange("Entry Type", "Entry Type");
            AccrualSchdLine.SetRange("No.", "Scheduled Accrual No.");
            AccrualSchdLine.Find('-');
            Validate("Source No.", '');
            Validate(Description,
              StrSubstNo(Text001, "Entry Type", AccrualSchdLine.FieldCaption("No."),
                         "Scheduled Accrual No.", AccrualSchdLine."Scheduled Date"));
            Validate("Source Document Type", "Source Document Type"::None);
            AccrualSchdLine.CalcFields("Posted Amount");
            Validate(Amount,
              AccrualSchdLine.SignedAmount(AccrualSchdLine.Amount) -
              AccrualSchdLine."Posted Amount");
        end;
    end;

    procedure LookupAccrualSchdLine(var Text: Text[1024]): Boolean
    var
        AccrualSchdLine: Record "Accrual Plan Schedule Line";
        AccrualSchdLines: Page "Accrual Plan Schedule Lines";
    begin
        exit(AccrualSchdLine.LookupNo("Accrual Plan Type", "Accrual Plan No.", "Entry Type", Text));
    end;

    procedure IsOpenedFromBatch(): Boolean
    var
        AccrualJournalBatch: Record "Accrual Journal Batch";
        TemplateFilter: Text;
        BatchFilter: Text;
    begin
        // P8004516
        BatchFilter := GetFilter("Journal Batch Name");
        if BatchFilter <> '' then begin
            TemplateFilter := GetFilter("Journal Template Name");
            if TemplateFilter <> '' then
                AccrualJournalBatch.SetFilter("Journal Template Name", TemplateFilter);
            AccrualJournalBatch.SetFilter(Name, BatchFilter);
            AccrualJournalBatch.FindFirst;
        end;

        exit((("Journal Batch Name" <> '') and ("Journal Template Name" = '')) or (BatchFilter <> ''));
    end;

    local procedure GetCurrency()
    var
        CurrencyCode: Code[10];
    begin
        // P8008663
        CurrencyCode := "Currency Code";

        if CurrencyCode = '' then begin
            Clear(Currency);
            Currency.InitRoundingPrecision
        end else
            if CurrencyCode <> Currency.Code then begin
                Currency.Get(CurrencyCode);
                Currency.TestField("Amount Rounding Precision");
            end;
    end;

    procedure SetCurrencyCode()
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        // P8008663
        if "Entry Type" <> "Entry Type"::Payment then
            exit;

        case Type of
            Type::Customer:
                begin
                    Customer.Get("No.");
                    Validate("Currency Code", Customer."Currency Code");
                end;
            Type::Vendor:
                begin
                    Vendor.Get("No.");
                    Validate("Currency Code", Vendor."Currency Code");
                end;
            // P800131317
            Type::"G/L Account":
                Validate("Currency Code", '');
        // P800131317
        end;
    end;
}

