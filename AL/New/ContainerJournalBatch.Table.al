table 37002574 "Container Journal Batch"
{
    // PR3.70.07
    // P8000140A, Myers Nissi, Jack Reynolds, 19 NOV 04
    //   Support for container journal and ledger
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Container Journal Batch';
    DataCaptionFields = Name, Description;
    LookupPageID = "Container Journal Batches";

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Container Journal Template";
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
                    ContJnlLine.SetRange("Journal Template Name", "Journal Template Name");
                    ContJnlLine.SetRange("Journal Batch Name", Name);
                    ContJnlLine.ModifyAll("Shortcut Dimension 2 Code", "Reason Code");
                    Modify;
                end;
            end;
        }
        field(5; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
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
        ContJnlLine.SetRange("Journal Template Name", "Journal Template Name");
        ContJnlLine.SetRange("Journal Batch Name", Name);
        ContJnlLine.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        LockTable;
        ContJnlTemplate.Get("Journal Template Name");
    end;

    trigger OnRename()
    begin
        ContJnlLine.SetRange("Journal Template Name", xRec."Journal Template Name");
        ContJnlLine.SetRange("Journal Batch Name", xRec.Name);
        if ContJnlLine.Find('-') then
            repeat
                ContJnlLine.Rename("Journal Template Name", Name, ContJnlLine."Line No.");
            until ContJnlLine.Next = 0;
    end;

    var
        Text000: Label 'Only the %1 field can be filled in on recurring journals.';
        Text001: Label 'must not be %1';
        ContJnlTemplate: Record "Container Journal Template";
        ContJnlLine: Record "Container Journal Line";

    procedure SetupNewBatch()
    begin
        ContJnlTemplate.Get("Journal Template Name");
        "No. Series" := ContJnlTemplate."No. Series";
        "Reason Code" := ContJnlTemplate."Reason Code";
    end;
}

