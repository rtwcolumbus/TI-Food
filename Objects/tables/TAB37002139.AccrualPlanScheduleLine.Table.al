table 37002139 "Accrual Plan Schedule Line"
{
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PRW17.00.01
    // P8001185, Columbus IT, Jack Reynolds, 19 JUL 13
    //   Fix problem with FILTERGROUP 1

    Caption = 'Accrual Plan Schedule Line';
    DrillDownPageID = "Accrual Plan Schedule Lines";
    LookupPageID = "Accrual Plan Schedule Lines";

    fields
    {
        field(1; "Accrual Plan Type"; Option)
        {
            Caption = 'Accrual Plan Type';
            OptionCaption = 'Sales,Purchase';
            OptionMembers = Sales,Purchase;
        }
        field(2; "Accrual Plan No."; Code[20])
        {
            Caption = 'Accrual Plan No.';
            TableRelation = "Accrual Plan"."No." WHERE(Type = FIELD("Accrual Plan Type"));
        }
        field(3; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'Accrual,Payment';
            OptionMembers = Accrual,Payment;
        }
        field(4; "Scheduled Date"; Date)
        {
            Caption = 'Scheduled Date';
            NotBlank = true;
        }
        field(5; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
        }
        field(6; "No."; Code[10])
        {
            Caption = 'No.';
        }
        field(7; "Posted Amount"; Decimal)
        {
            CalcFormula = Sum ("Accrual Ledger Entry".Amount WHERE("Accrual Plan Type" = FIELD("Accrual Plan Type"),
                                                                   "Accrual Plan No." = FIELD("Accrual Plan No."),
                                                                   "Entry Type" = FIELD("Entry Type"),
                                                                   "Scheduled Accrual No." = FIELD("No.")));
            Caption = 'Posted Amount';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Accrual Plan Type", "Accrual Plan No.", "Entry Type", "Scheduled Date")
        {
            SumIndexFields = Amount;
        }
        key(Key2; "Accrual Plan Type", "Accrual Plan No.", "Entry Type", "No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        RenumberAccruals(false, true);
    end;

    trigger OnInsert()
    begin
        TestField("Accrual Plan No.");

        RenumberAccruals(true, false);
    end;

    trigger OnRename()
    begin
        TestField("Accrual Plan No.");

        RenumberAccruals(true, true);
    end;

    local procedure RenumberAccruals(Inserting: Boolean; Deleting: Boolean)
    var
        AccrualSchdLine: Record "Accrual Plan Schedule Line";
        AccrualNo: Integer;
    begin
        AccrualSchdLine.SetRange("Accrual Plan Type", "Accrual Plan Type");
        AccrualSchdLine.SetRange("Accrual Plan No.", "Accrual Plan No.");
        AccrualSchdLine.SetRange("Entry Type", "Entry Type");
        if Deleting then begin
            AccrualSchdLine.FilterGroup(9); // xxx
            AccrualSchdLine.SetFilter("Scheduled Date", '<>%1', xRec."Scheduled Date");
            AccrualSchdLine.FilterGroup(0);
        end;
        if Inserting then begin
            AccrualSchdLine.SetFilter("Scheduled Date", '<%1', "Scheduled Date");
            "No." := Format(AccrualSchdLine.Count + 1);
            AccrualSchdLine.SetFilter("Scheduled Date", '<>%1', "Scheduled Date");
        end;

        if AccrualSchdLine.Find('-') then
            repeat
                AccrualNo := AccrualNo + 1;
                if Inserting and (AccrualSchdLine."Scheduled Date" > "Scheduled Date") then
                    AccrualSchdLine."No." := Format(AccrualNo + 1)
                else
                    AccrualSchdLine."No." := Format(AccrualNo);
                AccrualSchdLine.Modify;
            until (AccrualSchdLine.Next = 0);
    end;

    procedure SignedAmount(Amount: Decimal): Decimal
    begin
        if ("Accrual Plan Type" = "Accrual Plan Type"::Sales) then begin
            if ("Entry Type" = "Entry Type"::Accrual) then
                exit(-Amount);
            exit(Amount);
        end else begin
            if ("Entry Type" = "Entry Type"::Accrual) then
                exit(Amount);
            exit(-Amount);
        end;
    end;

    procedure LookupNo(AccrualPlanType: Integer; AccrualPlanNo: Code[20]; EntryType: Integer; var Text: Text[1024]): Boolean
    var
        AccrualSchdLines: Page "Accrual Plan Schedule Lines";
    begin
        Reset;
        SetCurrentKey("Accrual Plan Type", "Accrual Plan No.", "Entry Type", "No.");
        FilterGroup(2);
        SetRange("Accrual Plan Type", AccrualPlanType);
        SetRange("Accrual Plan No.", AccrualPlanNo);
        SetRange("Entry Type", EntryType);
        FilterGroup(0);
        AccrualSchdLines.LookupMode(true);
        AccrualSchdLines.SetTableView(Rec);
        if (Text <> '') then begin
            SetFilter("No.", Text);
            if Find('-') then
                AccrualSchdLines.SetRecord(Rec);
            SetRange("No.");
        end;
        if (AccrualSchdLines.RunModal <> ACTION::LookupOK) then
            exit(false);
        AccrualSchdLines.GetRecord(Rec);
        Text := Format("No.");
        exit(true);
    end;

    procedure ShowSchedule(AccrualPlanType: Integer; AccrualPlanNo: Code[20]; EntryType: Integer; No: Code[10]; AllowEdit: Boolean)
    var
        AccrualSchdLines: Page "Accrual Plan Schedule Lines";
    begin
        Reset;
        SetCurrentKey("Accrual Plan Type", "Accrual Plan No.", "Entry Type", "No.");
        FilterGroup(2);
        SetRange("Accrual Plan Type", AccrualPlanType);
        SetRange("Accrual Plan No.", AccrualPlanNo);
        SetRange("Entry Type", EntryType);
        FilterGroup(0);
        AccrualSchdLines.LookupMode(not AllowEdit);
        AccrualSchdLines.Editable(AllowEdit);
        AccrualSchdLines.SetTableView(Rec);
        if (No <> '') then begin
            SetFilter("No.", '%1', No);
            if Find('-') then
                AccrualSchdLines.SetRecord(Rec);
            SetRange("No.");
        end;
        AccrualSchdLines.RunModal;
    end;
}

