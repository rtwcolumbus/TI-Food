table 37002126 "Accrual Journal Batch"
{
    // PR3.61AC
    // 
    // PRW16.00
    // P8000643, VerticalSoft, Jack Reynolds, 20 NOV 08
    //   Add flow fields Template Type and Recurring
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Accrual Journal Batch';
    DataCaptionFields = Name, Description;
    LookupPageID = "Accrual Journal Batches";

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Accrual Journal Template";
        }
        field(2; Name; Code[10])
        {
            Caption = 'Name';
            NotBlank = true;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(4; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";

            trigger OnValidate()
            begin
                if "Reason Code" <> xRec."Reason Code" then begin
                    AccrualJnlLine.SetRange("Journal Template Name", "Journal Template Name");
                    AccrualJnlLine.SetRange("Journal Batch Name", Name);
                    AccrualJnlLine.ModifyAll("Reason Code", "Reason Code");
                    Modify;
                end;
            end;
        }
        field(5; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";

            trigger OnValidate()
            begin
                if "No. Series" <> '' then begin
                    AccrualJnlTemplate.Get("Journal Template Name");
                    if AccrualJnlTemplate.Recurring then
                        Error(
                          Text000,
                          FieldCaption("Posting No. Series"));
                    if "No. Series" = "Posting No. Series" then
                        Validate("Posting No. Series", '');
                end;
            end;
        }
        field(6; "Posting No. Series"; Code[20])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";

            trigger OnValidate()
            begin
                if ("Posting No. Series" = "No. Series") and ("Posting No. Series" <> '') then
                    FieldError("Posting No. Series", StrSubstNo(Text001, "Posting No. Series"));
                AccrualJnlLine.SetRange("Journal Template Name", "Journal Template Name");
                AccrualJnlLine.SetRange("Journal Batch Name", Name);
                AccrualJnlLine.ModifyAll("Posting No. Series", "Posting No. Series");
                Modify;
            end;
        }
        field(21; "Template Type"; Option)
        {
            CalcFormula = Lookup ("Accrual Journal Template".Type WHERE(Name = FIELD("Journal Template Name")));
            Caption = 'Template Type';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'Accrual,Scheduled Accrual';
            OptionMembers = Accrual,"Scheduled Accrual";
        }
        field(22; Recurring; Boolean)
        {
            CalcFormula = Lookup ("Accrual Journal Template".Recurring WHERE(Name = FIELD("Journal Template Name")));
            Caption = 'Recurring';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Journal Template Name", Name)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        AccrualJnlLine.SetRange("Journal Template Name", "Journal Template Name");
        AccrualJnlLine.SetRange("Journal Batch Name", Name);
        AccrualJnlLine.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        LockTable;
        AccrualJnlTemplate.Get("Journal Template Name");
    end;

    trigger OnRename()
    begin
        AccrualJnlLine.SetRange("Journal Template Name", xRec."Journal Template Name");
        AccrualJnlLine.SetRange("Journal Batch Name", xRec.Name);
        if AccrualJnlLine.Find('-') then
            repeat
                AccrualJnlLine.Rename("Journal Template Name", Name, AccrualJnlLine."Line No.");
            until AccrualJnlLine.Next = 0;
    end;

    var
        Text000: Label 'Only the %1 field can be filled in on recurring journals.';
        Text001: Label 'must not be %1';
        AccrualJnlTemplate: Record "Accrual Journal Template";
        AccrualJnlLine: Record "Accrual Journal Line";

    procedure SetupNewBatch()
    begin
        AccrualJnlTemplate.Get("Journal Template Name");
        "No. Series" := AccrualJnlTemplate."No. Series";
        "Posting No. Series" := AccrualJnlTemplate."Posting No. Series";
        "Reason Code" := AccrualJnlTemplate."Reason Code";
    end;
}

