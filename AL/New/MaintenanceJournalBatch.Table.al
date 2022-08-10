table 37002815 "Maintenance Journal Batch"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 30 AUG 06
    //   Standard journal batch table adapted for maintenance
    // 
    // PRW16.00
    // P8000643, VerticalSoft, Jack Reynolds, 20 NOV 08
    //   Add flow field Template Type
    // 
    // PRW16.00.01
    // P8000719, VerticalSoft, Jack Reynolds, 10 AUG 09
    //   Expand Type to include Maintenance
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Maintenance Journal Batch';
    DataCaptionFields = Name, Description;
    LookupPageID = "Maintenance Journal Batches";

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            NotBlank = true;
            TableRelation = "Maintenance Journal Template";
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
                    MaintJnlLine.SetRange("Journal Template Name", "Journal Template Name");
                    MaintJnlLine.SetRange("Journal Batch Name", Name);
                    MaintJnlLine.ModifyAll("Reason Code", "Reason Code");
                    Modify;
                end;
            end;
        }
        field(5; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(21; "Template Type"; Option)
        {
            CalcFormula = Lookup ("Maintenance Journal Template".Type WHERE(Name = FIELD("Journal Template Name")));
            Caption = 'Template Type';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'Labor,Material,Contract,Maintenance';
            OptionMembers = Labor,Material,Contract,Maintenance;
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
        MaintJnlLine.SetRange("Journal Template Name", "Journal Template Name");
        MaintJnlLine.SetRange("Journal Batch Name", Name);
        MaintJnlLine.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        LockTable;
        MaintJnlTemplate.Get("Journal Template Name");
    end;

    trigger OnRename()
    begin
        MaintJnlLine.SetRange("Journal Template Name", xRec."Journal Template Name");
        MaintJnlLine.SetRange("Journal Batch Name", xRec.Name);
        while MaintJnlLine.FindSet(true, true) do
            MaintJnlLine.Rename("Journal Template Name", Name, MaintJnlLine."Line No.");
    end;

    var
        Text000: Label 'Only the %1 field can be filled in on recurring journals.';
        Text001: Label 'must not be %1';
        MaintJnlTemplate: Record "Maintenance Journal Template";
        MaintJnlLine: Record "Maintenance Journal Line";

    procedure SetupNewBatch()
    begin
        MaintJnlTemplate.Get("Journal Template Name");
        "No. Series" := MaintJnlTemplate."No. Series";
        "Reason Code" := MaintJnlTemplate."Reason Code";
    end;
}

