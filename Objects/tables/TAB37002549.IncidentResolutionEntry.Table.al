table 37002549 "Incident Resolution Entry"
{
    // PRW111.00.01
    // P80036649, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Incident/Complaint Registration
    // 
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property

    Caption = 'Incident Resolution Entry';
    DrillDownPageID = "Incident Resolution Card";
    LookupPageID = "Incident Resolution Card";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(3; "Incident Entry No."; Integer)
        {
            Caption = 'Incident Entry No.';
            Editable = false;
            TableRelation = "Incident Entry"."Entry No.";
        }
        field(5; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(6; "Date and Time"; DateTime)
        {
            Caption = 'Date and Time';
        }
        field(7; Comment; Boolean)
        {
            CalcFormula = Exist ("Incident Comment Line" WHERE("Table ID" = CONST(37002549),
                                                               "Incident Entry No." = FIELD("Entry No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(8; Active; Boolean)
        {
            Caption = 'Active';

            trigger OnValidate()
            var
                IncidentResEntry: Record "Incident Resolution Entry";
                ShowMsg: Text;
            begin
                TestField(Accept, false);
                if Active then
                    ShowMsg := ActiveMsg
                else
                    ShowMsg := InactiveMsg;
                if not Confirm(StrSubstNo(ConfirmActiveUpdateMsg, ShowMsg), false) then
                    Error('');
                if Active then begin
                    IncidentResEntry.Reset;
                    IncidentResEntry.SetRange("Incident Entry No.", "Incident Entry No.");
                    IncidentResEntry.SetFilter("Entry No.", '<>%1', "Entry No.");
                    IncidentResEntry.ModifyAll(Active, not Active);
                end;
            end;
        }
        field(9; Accept; Boolean)
        {
            Caption = 'Accept';
            Editable = false;

            trigger OnValidate()
            var
                IncidentResEntry: Record "Incident Resolution Entry";
            begin
                TestField("Resolution Reason Code");

                if Accept then begin
                    IncidentResEntry.Reset;
                    IncidentResEntry.SetRange("Incident Entry No.", "Incident Entry No.");
                    IncidentResEntry.SetFilter("Entry No.", '<>%1', "Entry No.");
                    IncidentResEntry.ModifyAll(Accept, not Accept);
                end;
            end;
        }
        field(50; "Incident Entry Record ID"; RecordID)
        {
            Caption = 'Incident Entry Record ID';
            DataClassification = SystemMetadata;
        }
        field(55; "Resolution Reason Code"; Code[20])
        {
            Caption = 'Resolution Reason Code';
            TableRelation = "Incident Reason Code".Code WHERE(Type = CONST(Resolution));
        }
        field(60; Archived; Boolean)
        {
            CalcFormula = Lookup ("Incident Entry".Archived WHERE("Entry No." = FIELD("Incident Entry No.")));
            Caption = 'Archived';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        ConfirmActiveUpdateMsg: Label 'Do you want to make the resolution %1?';
        ActiveMsg: Label 'active';
        InactiveMsg: Label 'inactive';
}

