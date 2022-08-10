table 37002551 "Incident Comment Line"
{
    // PRW111.00.01
    // P80036649, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Incident/Complaint Registration
    // 
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property

    Caption = 'Incident Comment Line';
    DrillDownPageID = "Incident Comment Lines";
    LookupPageID = "Incident Comment Lines";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Table ID"; Integer)
        {
            Caption = 'Table ID';
        }
        field(3; "Incident Entry No."; Integer)
        {
            Caption = 'Incident Entry No.';

            trigger OnValidate()
            var
                IncidentEntry: Record "Incident Entry";
                IncidentResEntry: Record "Incident Resolution Entry";
            begin
                case "Table ID" of
                    DATABASE::"Incident Entry":
                        begin
                            if IncidentEntry.Get("Incident Entry No.") then begin
                                "Table ID" := IncidentEntry."Table No.";
                                "Incident Entry Record ID" := IncidentEntry."Source Record ID";
                                IncidentRecID := CopyStr(Format("Incident Entry Record ID"), 1, 249);
                                IncidentRecID2 := CopyStr(Format("Incident Entry Record ID"), 250, 499);
                            end;
                        end;
                    DATABASE::"Incident Resolution Entry":
                        begin
                            if IncidentResEntry.Get("Incident Entry No.") then begin
                                "Table ID" := DATABASE::"Incident Resolution Entry";
                                "Incident Entry Record ID" := IncidentResEntry."Incident Entry Record ID";
                                IncidentRecID := CopyStr(Format("Incident Entry Record ID"), 1, 249);
                                IncidentRecID2 := CopyStr(Format("Incident Entry Record ID"), 250, 499);
                            end;
                        end;
                end;
            end;
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
        field(7; Comment; Text[250])
        {
            Caption = 'Comment';

            trigger OnValidate()
            begin
                ShowNAVRecord;
            end;
        }
        field(8; Date; Date)
        {
            Caption = 'Date';
        }
        field(50; "Incident Entry Record ID"; RecordID)
        {
            Caption = 'Incident Entry Record ID';
            DataClassification = SystemMetadata;
        }
        field(52; IncidentRecID; Text[250])
        {
            Caption = 'IncidentRecID';
            DataClassification = SystemMetadata;
        }
        field(53; "Source Field No."; Integer)
        {
            Caption = 'Source Field No.';
        }
        field(55; IncidentRecID2; Text[250])
        {
            Caption = 'IncidentRecID2';
            DataClassification = SystemMetadata;
        }
        field(56; "Source Field Name"; Text[250])
        {
            Caption = 'Source Field Name';
        }
        field(61; Hits; Integer)
        {
            Caption = 'Hits';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; Hits)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "User ID" := UserId;
        "Date and Time" := CurrentDateTime;
        Date := WorkDate;
    end;

    procedure SetUpNewLine()
    var
        IncidentCommentLine: Record "Incident Comment Line";
    begin
        IncidentCommentLine.SetRange("Table ID", "Table ID");
        IncidentCommentLine.SetRange("Incident Entry No.", "Incident Entry No.");
        IncidentCommentLine.SetRange(Date, WorkDate);
        if not IncidentCommentLine.FindFirst then
            Date := WorkDate;
    end;

    procedure ShowNAVRecord()
    var
        PageManagement: Codeunit "Page Management";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
        RelatedRecord: Variant;
    begin
        if GetNAVRecord(RelatedRecord) then begin
            DataTypeManagement.GetRecordRef(RelatedRecord, RecRef);
            PageManagement.PageRunModal(RecRef);
        end;
    end;

    procedure GetNAVRecord(var RelatedRecord: Variant): Boolean
    var
        RelatedRecordRef: RecordRef;
    begin
        if GetRelatedRecord(RelatedRecordRef) then begin
            RelatedRecord := RelatedRecordRef;
            exit(true);
        end;
    end;

    local procedure GetRelatedRecord(var RelatedRecordRef: RecordRef): Boolean
    var
        RelatedRecordID: RecordID;
    begin
        RelatedRecordID := Rec."Incident Entry Record ID";
        if RelatedRecordID.TableNo = 0 then
            exit(false);
        RelatedRecordRef := RelatedRecordID.GetRecord;
        exit(RelatedRecordRef.Get(RelatedRecordID));
    end;
}

