table 37002191 "Deduction Resolution"
{
    // PR3.70.08
    // P8000170A, Myers Nissi, Jack Reynolds, 31 JAN 05
    //   New table to store deduction resolution lines
    // 
    // PR3.70.10
    // P8000240A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Modify to allow accrual plans as an account number
    // 
    // PR4.00.01
    // P8000267B, VerticalSoft, Jack Reynolds, 12 DEC 05
    //   Change dimension code processing to with respect to MODIFY to be in line with similar changes in the
    //     standard tables for SP1
    // 
    // P8000269A, VerticalSoft, Jack Reynolds, 05 DEC 05
    //   Support for comments
    // 
    // PRW16.00.04
    // P8000897, VerticalSoft, Jack Reynolds, 22 JAN 11
    //   Fix spelling mistake
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW18.00.02
    // P8002752, to-Increase, Jack Reynolds, 26 OCT 15
    //   Allow option to keep deductions with original customer
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds 17 NOV 13
    //   Lookup of Shortcut Dimensions
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 26 APR 22
    //   Upgrade to 20.0 - Refactoring for default dimensions

    Caption = 'Deduction Resolution';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;

            trigger OnValidate()
            begin
                CreateDimFromDefaultDim(); // P800144605
            end;
        }
        field(4; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,Writeoff,Accrual Plan,,,,,Return,Clear';
            OptionMembers = " ",Writeoff,"Accrual Plan",,,,,Return,Clear;

            trigger OnValidate()
            begin
                if Type <> xRec.Type then begin
                    // P8000204A Begin
                    "Account No." := '';
                    CreateDimFromDefaultDim(); // P800144605
                    // P8000204A End
                    GetCustLedger;
                    case Type of
                        Type::" ":
                            begin
                                Validate("Resolve With Original Customer", false);
                                "Use Original Date" := false;
                                Description := '';
                            end;
                        Type::Return, Type::Clear: // P8002752
                            begin
                                DeductionRes.Reset;
                                DeductionRes.SetRange("Entry No.", "Entry No.");
                                DeductionRes.SetFilter("Line No.", '<>%1', "Line No.");
                                DeductionRes.SetRange(Type, Type); // P8002752
                                if DeductionRes.Find('-') then
                                    Error(Text001, Type);
                                Validate("Resolve With Original Customer", true);
                                "Use Original Date" := true;
                                Description := CustLedger.Description;
                            end;
                        else begin
                                SalesSetup.Get;
                                Validate("Resolve With Original Customer", SalesSetup."Resolve Ded. With Orig. Cust.");
                                Description := Format(Type);
                                if CustLedger."Original Entry No." <> 0 then begin
                                    CustLedger.CalcFields("Original Document No.");
                                    Description := Description + ' - ' + CustLedger."Original Document No.";
                                end;
                            end;
                    end;
                end;
            end;
        }
        field(5; "Customer Ledger Entry No."; Integer)
        {
            Caption = 'Customer Ledger Entry No.';
        }
        field(11; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';

            trigger OnValidate()
            begin
                if Amount <> 0 then begin
                    GetCustLedger;
                    if (Amount * CustLedger."Remaining Amount") < 0 then
                        Error(Text002, FieldCaption(Amount));

                    DeductionRes.Reset;
                    DeductionRes.SetRange("Entry No.", "Entry No.");
                    DeductionRes.SetFilter("Line No.", '<>%1', "Line No.");
                    DeductionRes.CalcSums(Amount);
                    if Abs(CustLedger."Remaining Amount") < Abs(DeductionRes.Amount + Amount) then
                        Error(Text003);
                end;
            end;
        }
        field(12; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = IF (Type = CONST(Writeoff)) "G/L Account"
            ELSE
            IF (Type = CONST("Accrual Plan")) "Accrual Plan"."No." WHERE(Type = CONST(Sales),
                                                                                             "Payment Posting Level" = FILTER(<= Source),
                                                                                             "Use Payment Schedule" = CONST(false));

            trigger OnValidate()
            begin
                // P8000240A Begin
                case Type of
                    Type::"Accrual Plan":
                        DedMgt.CheckAccrualPlan("Customer No.", "Account No.");
                end;
                // P8000240A Begin

                CreateDimFromDefaultDim(); // P800144605
            end;
        }
        field(13; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(14; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(15; "Resolve With Original Customer"; Boolean)
        {
            Caption = 'Resolve With Original Customer';

            trigger OnValidate()
            begin
                if Type = Type::Return then
                    "Resolve With Original Customer" := true;

                "Use Original Date" := "Resolve With Original Customer";
            end;
        }
        field(16; "Use Original Date"; Boolean)
        {
            Caption = 'Use Original Date';

            trigger OnValidate()
            begin
                if not "Resolve With Original Customer" then
                    "Use Original Date" := false;
            end;
        }
        field(21; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(22; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(23; Comment; Boolean)
        {
            CalcFormula = Exist("Deduction Comment Line" WHERE("Source Table No." = CONST(37002191),
                                                                "Source Ref. No." = FIELD("Entry No."),
                                                                "Deduction Line No." = FIELD("Line No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                // P8001133
                EditDimensions;
            end;
        }
    }

    keys
    {
        key(Key1; "Entry No.", "Line No.")
        {
            SumIndexFields = Amount;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        // P8000269A
        DeductionCommentLine.SetRange("Source Table No.", DATABASE::"Deduction Comment Line");
        DeductionCommentLine.SetRange("Source Ref. No.", "Entry No.");
        DeductionCommentLine.SetRange("Deduction Line No.", "Line No.");
        DeductionCommentLine.DeleteAll;
        // P8000269A
    end;

    trigger OnInsert()
    begin
        if "Customer No." = '' then
            InitRecord;

        ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
        ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
    end;

    var
        SalesSetup: Record "Sales & Receivables Setup";
        CustLedger: Record "Cust. Ledger Entry";
        DeductionRes: Record "Deduction Resolution";
        DeductionCommentLine: Record "Deduction Comment Line";
        DimMgt: Codeunit DimensionManagement;
        Text001: Label 'Only one line may be designated "%1".';
        Text002: Label '%1 must be the same sign as the deduction entry.';
        Text003: Label 'Total resolution cannot exceed remaining amount of the deduction.';
        DedMgt: Codeunit "Deduction Management";

    procedure GetCustLedger()
    begin
        if CustLedger."Entry No." <> "Entry No." then begin
            CustLedger.Get("Entry No.");
            CustLedger.CalcFields("Remaining Amount");
        end;
    end;

    procedure InitRecord()
    begin
        CustLedger."Entry No." := 0; // P8002752
        GetCustLedger;

        Validate("Customer No.", CustLedger."Original Customer No.");

        DeductionRes.Reset;
        DeductionRes.SetRange("Entry No.", "Entry No.");
        DeductionRes.SetFilter("Line No.", '<>%1', "Line No.");
        DeductionRes.CalcSums(Amount);
        Amount := CustLedger."Remaining Amount" - DeductionRes.Amount;
    end;

    procedure ShowComments()
    var
        DeductionCommentLine: Record "Deduction Comment Line";
        DeductionComments: Page "Deduction Comments";
    begin
        // P8000269A
        TestField("Line No.");
        DeductionCommentLine.SetRange("Source Table No.", DATABASE::"Deduction Resolution");
        DeductionCommentLine.SetRange("Source Ref. No.", "Entry No.");
        DeductionCommentLine.SetRange("Deduction Line No.", "Line No.");
        DeductionComments.SetTableView(DeductionCommentLine);
        DeductionComments.RunModal;
    end;

    procedure ShowDimensions()
    begin
        // P8001133
        DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo('%1 %2', "Entry No.", "Line No."));
    end;

    procedure EditDimensions()
    begin
        // P8001133
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet(
            "Dimension Set ID", StrSubstNo('%1 %2', "Entry No.", "Line No."),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    // P800144605
    procedure CreateDimFromDefaultDim()
    var
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        InitDefaultDimensionSources(DefaultDimSource);
        CreateDim(DefaultDimSource);
    end;

    // P800144605
    local procedure InitDefaultDimensionSources(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    begin
        DimMgt.AddDimSource(DefaultDimSource, DATABASE::Customer, Rec."Customer No.");
        case Rec.Type of
            Rec.Type::"Accrual Plan":
                DimMgt.AddDimSource(DefaultDimSource, DATABASE::"Accrual Plan", Rec."Account No.");
            Rec.Type::Writeoff:
                DimMgt.AddDimSource(DefaultDimSource, DATABASE::"G/L Account", Rec."Account No.");
        end;
    end;

    // P800144605
    procedure CreateDim(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        "Dimension Set ID" :=
          DimMgt.GetRecDefaultDimID(
            Rec, CurrFieldNo, DefaultDimSource, SourceCodeSetup."Deduction Management", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);
    end;

    [Obsolete('Replaced by CreateDim(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])', 'FOOD-21')]
    procedure CreateDim(Type1: Integer; No1: Code[20]; Type2: Integer; No2: Code[20]; Type3: Integer; No3: Code[20])
    var
        SourceCodeSetup: Record "Source Code Setup";
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        // P8000240A - add parameters for Type3, No3
        TableID[1] := Type1;
        No[1] := No1;
        // P8000240A Begin
        case Type of
            Type::Writeoff:
                begin
                    TableID[2] := Type2;
                    No[2] := No2;
                end;
            Type::"Accrual Plan":
                begin
                    TableID[2] := Type3;
                    No[2] := No3;
                end;
        end;
        // P8000240A End
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        SourceCodeSetup.Get;
        "Dimension Set ID" := DimMgt.GetDefaultDimID( // P8001133
          TableID, No, SourceCodeSetup."Deduction Management", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0); // P8001133
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID"); // P8001133
    end;

    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20])
    begin
        DimMgt.GetShortcutDimensions("Dimension Set ID", ShortcutDimCode); // P8001133
    end;

    procedure CopyCommentsToLedger(TableID: Integer; EntryNo: Integer)
    var
        LedgerEntryComment: Record "Ledger Entry Comment Line";
    begin
        // P8000269A
        DeductionCommentLine.SetRange("Source Table No.", DATABASE::"Deduction Resolution");
        DeductionCommentLine.SetRange("Source Ref. No.", "Entry No.");
        DeductionCommentLine.SetRange("Deduction Line No.", "Line No.");
        if DeductionCommentLine.Find('-') then begin
            LedgerEntryComment.SetRange("Table ID", TableID);
            LedgerEntryComment.SetRange("Entry No.", EntryNo);
            LedgerEntryComment.LockTable;
            if LedgerEntryComment.Find('+') then;
            LedgerEntryComment."Table ID" := TableID;
            LedgerEntryComment."Entry No." := EntryNo;
            repeat
                LedgerEntryComment."Line No." += 10000;
                LedgerEntryComment.Date := DeductionCommentLine.Date;
                LedgerEntryComment.Code := DeductionCommentLine.Code;
                LedgerEntryComment.Comment := DeductionCommentLine.Comment;
                LedgerEntryComment.Insert;
            until DeductionCommentLine.Next = 0;
        end;
    end;
}

