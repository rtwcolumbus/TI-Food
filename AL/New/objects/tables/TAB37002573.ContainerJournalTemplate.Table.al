table 37002573 "Container Journal Template"
{
    // PR3.70.07
    // P8000140A, Myers Nissi, Jack Reynolds, 19 NOV 04
    //   Support for container journal and ledger
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.10
    // P8001219, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Object name fields changed to captions
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 16 NOV 15
    //   Change TableRelation references to Object table
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Container Journal Template';
    LookupPageID = "Container Jnl. Template List";
    ReplicateData = false;

    fields
    {
        field(1; Name; Code[10])
        {
            Caption = 'Name';
            NotBlank = true;

            trigger OnValidate()
            begin
                "Page ID" := PAGE::"Container Journal";

                "Test Report ID" := 0;
                "Posting Report ID" := 0;

                SourceCodeSetup.Get;
                "Source Code" := SourceCodeSetup."Container Journal";
            end;
        }
        field(2; Description; Text[80])
        {
            Caption = 'Description';
        }
        field(5; "Test Report ID"; Integer)
        {
            Caption = 'Test Report ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(6; "Page ID"; Integer)
        {
            Caption = 'Page ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Page));
        }
        field(7; "Posting Report ID"; Integer)
        {
            Caption = 'Posting Report ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(10; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";

            trigger OnValidate()
            begin
                ContJnlLine.SetRange("Journal Template Name", Name);
                ContJnlLine.ModifyAll("Shortcut Dimension 1 Code", "Source Code");
                Modify;
            end;
        }
        field(11; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(13; "Test Report Caption"; Text[250])
        {
            CalcFormula = Lookup (AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Report),
                                                                           "Object ID" = FIELD("Test Report ID")));
            Caption = 'Test Report Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; "Page Caption"; Text[250])
        {
            CalcFormula = Lookup (AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Page),
                                                                           "Object ID" = FIELD("Page ID")));
            Caption = 'Page Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "Posting Report Caption"; Text[250])
        {
            CalcFormula = Lookup (AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Report),
                                                                           "Object ID" = FIELD("Posting Report ID")));
            Caption = 'Posting Report Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(16; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(Key1; Name)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        ContJnlLine.SetRange("Journal Template Name", Name);
        ContJnlLine.DeleteAll(true);
        ContJnlBatch.SetRange("Journal Template Name", Name);
        ContJnlBatch.DeleteAll;
    end;

    var
        ContJnlBatch: Record "Container Journal Batch";
        ContJnlLine: Record "Container Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
}

