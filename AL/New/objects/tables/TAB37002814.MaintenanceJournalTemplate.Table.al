table 37002814 "Maintenance Journal Template"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 30 AUG 06
    //   Standard journal template table adapted for maintenance
    // 
    // PRW16.00
    // P8000639, VerticalSoft, Jack Reynolds, 18 NOV 08
    //   Add DropDown field group
    // 
    // PRW16.00.01
    // P8000719, VerticalSoft, Jack Reynolds, 10 AUG 09
    //   Expand Type to include Maintenance
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

    Caption = 'Maintenance Journal Template';
    LookupPageID = "Maint. Journal Template List";
    ReplicateData = false;

    fields
    {
        field(1; Name; Code[10])
        {
            Caption = 'Name';
            NotBlank = true;
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

            trigger OnValidate()
            begin
                if "Page ID" = 0 then
                    Validate(Type);
            end;
        }
        field(7; "Posting Report ID"; Integer)
        {
            Caption = 'Posting Report ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(8; "Force Posting Report"; Boolean)
        {
            Caption = 'Force Posting Report';
        }
        field(9; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Labor,Material,Contract,Maintenance';
            OptionMembers = Labor,Material,Contract,Maintenance;

            trigger OnValidate()
            begin
                "Test Report ID" := REPORT::"Maintenance Posting - Test";
                "Posting Report ID" := REPORT::"Maint. Register";
                SourceCodeSetup.Get;
                case Type of
                    Type::Labor:
                        begin
                            "Source Code" := SourceCodeSetup."Maintenance Labor Journal";
                            "Page ID" := PAGE::"Maintenance Labor Journal";
                        end;
                    Type::Material:
                        begin
                            "Source Code" := SourceCodeSetup."Maintenance Material Journal";
                            "Page ID" := PAGE::"Maintenance Material Journal";
                        end;
                    Type::Contract:
                        begin
                            "Source Code" := SourceCodeSetup."Maintenance Contract Journal";
                            "Page ID" := PAGE::"Maintenance Contract Journal";
                        end;
                        // P8000719
                    Type::Maintenance:
                        begin
                            "Source Code" := SourceCodeSetup."Maintenance Journal";
                            "Page ID" := PAGE::"Maintenance Journal";
                        end;
                        // P8000719
                end;
            end;
        }
        field(10; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";

            trigger OnValidate()
            begin
                MaintJnlLine.SetRange("Journal Template Name", Name);
                MaintJnlLine.ModifyAll("Source Code", "Source Code");
                Modify;
            end;
        }
        field(11; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Source Code";
        }
        field(15; "Test Report Caption"; Text[250])
        {
            CalcFormula = Lookup (AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Report),
                                                                           "Object ID" = FIELD("Test Report ID")));
            Caption = 'Test Report Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(16; "Page Caption"; Text[250])
        {
            CalcFormula = Lookup (AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Page),
                                                                           "Object ID" = FIELD("Page ID")));
            Caption = 'Page Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(17; "Posting Report Caption"; Text[250])
        {
            CalcFormula = Lookup (AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Report),
                                                                           "Object ID" = FIELD("Posting Report ID")));
            Caption = 'Posting Report Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(19; "No. Series"; Code[20])
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
        fieldgroup(DropDown; Name, Description, Type)
        {
        }
    }

    trigger OnDelete()
    begin
        MaintJnlLine.SetRange("Journal Template Name", Name);
        MaintJnlLine.DeleteAll(true);
        MaintJnlBatch.SetRange("Journal Template Name", Name);
        MaintJnlBatch.DeleteAll;
    end;

    trigger OnInsert()
    begin
        Validate("Page ID");
    end;

    var
        Text000: Label 'Only the %1 field can be filled in on recurring journals.';
        Text001: Label 'must not be %1';
        MaintJnlBatch: Record "Maintenance Journal Batch";
        MaintJnlLine: Record "Maintenance Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
}

