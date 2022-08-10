table 37002190 "Deduction Line" // Version: FOODNA
{
    // PR3.70.08
    // P8000170A, Myers Nissi, Jack Reynolds, 31 JAN 05
    //   New table to store deduction management lines (applications, deductions, remainders)
    // 
    // PR3.70.09
    // P8000189A, Myers Nissi, Jack Reynolds, 22 FEB 05
    //   Field 8 - Dimension Entry No. - Integer
    // 
    // P8000195A, Myers Nissi, Jack Reynolds, 25 FEB 05
    //   Establish table relation for Source ID so that renaming a deposit renames the deductions
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
    // P8000915, Columbus IT, Jack Reynolds, 09 MAR 11
    //   Fix problem with non-existent customer ledger entry
    // 
    // PRW16.00.06
    // P8001066, Columbus IT, Jack Reynolds, 02 MAY 12
    //   Fix problem with missing global dimensions
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW17.10.02
    // P8001274, Columbus IT, Jack Reynolds, 30 JAN 14
    //    Increase the Assigned To field to Code50
    // 
    // PRW18.00.02
    // P8002751, to-Increase, Jack Reynolds, 26 OCT 15
    //   Allow option to keep deductions with original customer
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds 17 NOV 13
    //   Lookup of Shortcut Dimensions
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Deduction Line';

    fields
    {
        field(1; "Source Table No."; Integer)
        {
            Caption = 'Source Table No.';
        }
        field(2; "Source ID"; Code[20])
        {
            Caption = 'Source ID';
            TableRelation = IF ("Source Table No." = CONST(10141)) "Deposit Header";
        }
        field(3; "Source Batch Name"; Code[10])
        {
            Caption = 'Source Batch Name';
        }
        field(4; "Source Ref. No."; Integer)
        {
            Caption = 'Source Ref. No.';
        }
        field(5; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Application,Deduction,Remainder';
            OptionMembers = Application,Deduction,Remainder;
        }
        field(6; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(7; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;

            trigger OnValidate()
            begin
                CreateDim(
                  DATABASE::Customer, "Customer No.",
                  DATABASE::"G/L Account", "Account No.",   // P8000240A
                  DATABASE::"Accrual Plan", "Account No."); // P8000240A
            end;
        }
        field(8; Date; Date)
        {
            Caption = 'Date';
        }
        field(11; "Applies-to Entry No."; Integer)
        {
            Caption = 'Applies-to Entry No.';
        }
        field(21; "Deduction Type"; Option)
        {
            Caption = 'Deduction Type';
            OptionCaption = 'Unresolved,Writeoff,Accrual Plan';
            OptionMembers = Unresolved,Writeoff,"Accrual Plan";

            trigger OnValidate()
            begin
                if Type <> Type::Deduction then
                    exit;

                // P8000204A Begin
                if "Deduction Type" <> xRec."Deduction Type" then begin
                    "Account No." := '';
                    CreateDim(
                      DATABASE::Customer, "Customer No.",
                      DATABASE::"G/L Account", "Account No.",
                      DATABASE::"Accrual Plan", "Account No.");
                end;
                // P8000204A End

                if "Deduction Type" = 0 then begin
                    Description := '';
                    Allowed := false;
                end else begin
                    Description := Format("Deduction Type");
                    if "Applies-to Entry No." <> 0 then
                        Description := Description + ' - ' + RelatedDocumentNo;
                end;
            end;
        }
        field(22; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
            MinValue = 0;

            trigger OnValidate()
            var
                CustLedger: Record "Cust. Ledger Entry";
            begin
                case Type of
                    Type::Application:
                        begin
                            CustLedger.Get("Applies-to Entry No.");
                            DeductionLine.Reset;
                            DeductionLine.SetRange("Source Table No.", "Source Table No.");
                            DeductionLine.SetRange("Source ID", "Source ID");
                            DeductionLine.SetRange("Source Batch Name", "Source Batch Name");
                            DeductionLine.SetRange("Source Ref. No.", "Source Ref. No.");
                            DeductionLine.SetRange(Type, Type::Deduction);
                            if Amount <= 0 then begin
                                DeductionLine.SetRange("Applies-to Entry No.", "Applies-to Entry No.");
                                DeductionLine.DeleteAll;
                            end else
                                if xRec.Amount <= 0 then begin
                                    if DeductionLine.Find('+') then;
                                    DeductionLine."Line No." += 10000;
                                    DeductionLine.Init;
                                    DeductionLine."Source Table No." := "Source Table No.";
                                    DeductionLine."Source ID" := "Source ID";
                                    DeductionLine."Source Batch Name" := "Source Batch Name";
                                    DeductionLine."Source Ref. No." := "Source Ref. No.";
                                    DeductionLine.Type := DeductionLine.Type::Deduction;
                                    DeductionLine."Applies-to Entry No." := "Applies-to Entry No.";
                                    DeductionLine.Amount := Amount;
                                    DeductionLine.Insert(true);
                                end else begin
                                    DeductionLine.SetRange("Applies-to Entry No.", "Applies-to Entry No.");
                                    DeductionLine.Find('-');
                                    DeductionLine.SetFilter("Line No.", '<>%1', DeductionLine."Line No.");
                                    DeductionLine.DeleteAll;
                                    DeductionLine.Amount := Amount;
                                    DeductionLine.Allowed := false;
                                    DeductionLine.Modify;
                                end;
                        end;
                end;
            end;
        }
        field(23; Allowed; Boolean)
        {
            Caption = 'Allowed';

            trigger OnValidate()
            begin
                if "Deduction Type" = "Deduction Type"::Unresolved then
                    Allowed := false;
            end;
        }
        field(24; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = IF ("Deduction Type" = CONST(Writeoff)) "G/L Account"
            ELSE
            IF ("Deduction Type" = CONST("Accrual Plan")) "Accrual Plan"."No." WHERE(Type = CONST(Sales),
                                                                                                         "Payment Posting Level" = FILTER(<= Source),
                                                                                                         "Use Payment Schedule" = CONST(false));

            trigger OnValidate()
            begin
                // P8000240A Begin
                case "Deduction Type" of
                    "Deduction Type"::"Accrual Plan":
                        DedMgt.CheckAccrualPlan("Customer No.", "Account No.");
                end;
                // P8000240A Begin

                Validate(Allowed, "Account No." <> ''); // P8000240A

                CreateDim(
                  DATABASE::Customer, "Customer No.",
                  DATABASE::"G/L Account", "Account No.",   // P8000240A
                  DATABASE::"Accrual Plan", "Account No."); // P8000240A
            end;
        }
        field(25; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(26; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(27; "Remainder Applied to"; Option)
        {
            Caption = 'Remainder Applied to';
            OptionCaption = 'Ded. Mgt.,Customer';
            OptionMembers = "Ded. Mgt.",Customer;
        }
        field(28; "Assigned To"; Code[50])
        {
            Caption = 'Assigned To';
            TableRelation = User;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                UserSelection: Codeunit "User Selection";
                User: Record User;
            begin
                // P800-MegaApp
                if UserSelection.Open(User) then
                    "Assigned To" := User."User Name";
            end;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("Assigned To");
            end;
        }
        field(31; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(32; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(33; Comment; Boolean)
        {
            CalcFormula = Exist ("Deduction Comment Line" WHERE("Source Table No." = FIELD("Source Table No."),
                                                                "Source ID" = FIELD("Source ID"),
                                                                "Source Batch Name" = FIELD("Source Batch Name"),
                                                                "Source Ref. No." = FIELD("Source Ref. No."),
                                                                Type = FIELD(Type),
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
        key(Key1; "Source Table No.", "Source ID", "Source Batch Name", "Source Ref. No.", Type, "Line No.")
        {
            SumIndexFields = Amount;
        }
        key(Key2; "Applies-to Entry No.")
        {
            SumIndexFields = Amount;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if (Type = Type::Application) and (Amount <> 0) then begin
            DeductionLine.Reset;
            DeductionLine.SetRange("Source Table No.", "Source Table No.");
            DeductionLine.SetRange("Source ID", "Source ID");
            DeductionLine.SetRange("Source Batch Name", "Source Batch Name");
            DeductionLine.SetRange("Source Ref. No.", "Source Ref. No.");
            DeductionLine.SetRange(Type, Type::Deduction);
            DeductionLine.SetRange("Applies-to Entry No.", "Applies-to Entry No.");
            DeductionLine.DeleteAll(true);
        end;

        // P8000269A
        DeductionCommentLine.SetRange("Source Table No.", "Source Table No.");
        DeductionCommentLine.SetRange("Source ID", "Source ID");
        DeductionCommentLine.SetRange("Source Batch Name", "Source Batch Name");
        DeductionCommentLine.SetRange("Source Ref. No.", "Source Ref. No.");
        DeductionCommentLine.SetRange(Type, Type);
        DeductionCommentLine.SetRange("Deduction Line No.", "Line No.");
        DeductionCommentLine.DeleteAll;
        // P8000269A
    end;

    trigger OnInsert()
    begin
        if "Customer No." = '' then
            SetCustomerNo;

        if Type in [Type::Deduction, Type::Remainder] then begin // P8001066
            ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
        end;

        // P8002751
        if Type = Type::Remainder then begin
            SalesSetup.Get;
            if SalesSetup."Deduction Management Cust. No." <> '' then
                "Remainder Applied to" := "Remainder Applied to"::"Ded. Mgt."
            else
                "Remainder Applied to" := "Remainder Applied to"::Customer;
        end;
        // P8002751
    end;

    var
        Text001: Label 'must be greater than or equal to %1';
        Text002: Label 'must be less than or equal to %1';
        SourceCodeSetup: Record "Source Code Setup";
        DeductionLine: Record "Deduction Line";
        DeductionCommentLine: Record "Deduction Comment Line";
        SalesSetup: Record "Sales & Receivables Setup";
        DimMgt: Codeunit DimensionManagement;
        DedMgt: Codeunit "Deduction Management";

    procedure RelatedDocumentNo(): Code[20]
    var
        CustLedger: Record "Cust. Ledger Entry";
    begin
        if "Applies-to Entry No." <> 0 then begin
            if CustLedger.Get("Applies-to Entry No.") then // P8000915
                exit(CustLedger."Document No.");
        end;
    end;

    procedure SetCustomerNo()
    var
        CustLedger: Record "Cust. Ledger Entry";
        GenJnlLine: Record "Gen. Journal Line";
    begin
        case "Source Table No." of
            DATABASE::"Cust. Ledger Entry":
                if CustLedger.Get("Source Ref. No.") then      // P8000915
                    "Customer No." := CustLedger."Customer No."; // P8000915
            DATABASE::"Gen. Journal Line":
                if GenJnlLine.Get("Source ID", "Source Batch Name", "Source Ref. No.") then // P8000915
                    "Customer No." := GenJnlLine."Account No.";                             // P8000915
        end;

        Validate("Customer No.");
    end;

    procedure ShowComments()
    var
        DeductionCommentLine: Record "Deduction Comment Line";
        DeductionComments: Page "Deduction Comments";
    begin
        // P8000269A
        TestField("Line No.");
        DeductionCommentLine.SetRange("Source Table No.", "Source Table No.");
        DeductionCommentLine.SetRange("Source ID", "Source ID");
        DeductionCommentLine.SetRange("Source Batch Name", "Source Batch Name");
        DeductionCommentLine.SetRange("Source Ref. No.", "Source Ref. No.");
        DeductionCommentLine.SetRange(Type, Type);
        DeductionCommentLine.SetRange("Deduction Line No.", "Line No.");
        DeductionComments.SetTableView(DeductionCommentLine);
        DeductionComments.RunModal;
    end;

    procedure ShowDimensions()
    begin
        // P8001133
        DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo('%1 %2 %3 %4', "Source ID", "Source Batch Name", "Source Ref. No.", "Line No."));
    end;

    procedure EditDimensions()
    begin
        // P8001133
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet(
            "Dimension Set ID", StrSubstNo('%1 %2 %3 %4', "Source ID", "Source Batch Name", "Source Ref. No.", "Line No."),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    procedure CreateDim(Type1: Integer; No1: Code[20]; Type2: Integer; No2: Code[20]; Type3: Integer; No3: Code[20])
    var
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        // P8000240A - add parameters for Type3, No3
        if Type <> Type::Deduction then
            exit;

        TableID[1] := Type1;
        No[1] := No1;
        // P8000240A Begin
        case "Deduction Type" of
            "Deduction Type"::Writeoff:
                begin
                    TableID[2] := Type2;
                    No[2] := No2;
                end;
            "Deduction Type"::"Accrual Plan":
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
        if Type <> Type::Deduction then
            exit;

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
        DeductionCommentLine.SetRange("Source Table No.", "Source Table No.");
        DeductionCommentLine.SetRange("Source ID", "Source ID");
        DeductionCommentLine.SetRange("Source Batch Name", "Source Batch Name");
        DeductionCommentLine.SetRange("Source Ref. No.", "Source Ref. No.");
        DeductionCommentLine.SetRange(Type, Type);
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

