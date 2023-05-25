table 37002548 "Incident Entry"
{
    // PRW111.00.01
    // P80036649, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Incident/Complaint Registration
    // 
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Incident Entry';
    DrillDownPageID = "Incident Entries Subpage";
    LookupPageID = "Incident Entries Subpage";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            Editable = false;
        }
        field(5; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(13; "Primary Key Field 1 No."; Integer)
        {
            Caption = 'Primary Key Field 1 No.';
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table No."));
        }
        field(15; "Primary Key Field 1 Value"; Text[50])
        {
            Caption = 'Primary Key Field 1 Value';
        }
        field(16; "Primary Key Field 2 No."; Integer)
        {
            Caption = 'Primary Key Field 2 No.';
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table No."));
        }
        field(18; "Primary Key Field 2 Value"; Text[50])
        {
            Caption = 'Primary Key Field 2 Value';
        }
        field(19; "Primary Key Field 3 No."; Integer)
        {
            Caption = 'Primary Key Field 3 No.';
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table No."));
        }
        field(21; "Primary Key Field 3 Value"; Text[50])
        {
            Caption = 'Primary Key Field 3 Value';
        }
        field(22; "Item No."; Code[20])
        {
            Caption = 'Item No.';
        }
        field(23; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
        }
        field(24; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
        }
        field(25; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
        }
        field(26; "Item Category"; Code[10])
        {
            Caption = 'Item Category';
        }
        field(30; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
        }
        field(31; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
        }
        field(36; "To-do No."; Code[20])
        {
            Caption = 'Task No.';
            Editable = false;
            TableRelation = "To-do";
        }
        field(37; "To-do Description"; Text[100])
        {
            CalcFormula = Lookup ("To-do".Description WHERE("No." = FIELD("To-do No.")));
            Caption = 'Task Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(38; "To-do Status"; Option)
        {
            CalcFormula = Lookup ("To-do".Status WHERE("No." = FIELD("To-do No.")));
            Caption = 'Task Status';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'Not Started,In Progress,Completed,Waiting,Postponed';
            OptionMembers = "Not Started","In Progress",Completed,Waiting,Postponed;
        }
        field(39; "To-do Priority"; Option)
        {
            CalcFormula = Lookup ("To-do".Priority WHERE("No." = FIELD("To-do No.")));
            Caption = 'Task Priority';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'Low,Normal,High';
            OptionMembers = Low,Normal,High;
        }
        field(53; "Salesperson Code"; Code[10])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";

            trigger OnValidate()
            begin
                TestField(Archived, false);
            end;
        }
        field(55; "Incident Reason Code"; Code[20])
        {
            Caption = 'Incident Reason Code';
            TableRelation = "Incident Reason Code".Code WHERE(Type = CONST(Incident));

            trigger OnValidate()
            begin
                TestField(Archived, false);
            end;
        }
        field(58; "Incident Quantity"; Decimal)
        {
            Caption = 'Incident Quantity';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                TestField(Archived, false);
            end;
        }
        field(59; "Incident Unit of Measure Code"; Code[10])
        {
            Caption = 'Incident Unit of Measure Code';

            trigger OnValidate()
            begin
                TestField(Archived, false);
            end;
        }
        field(60; Archived; Boolean)
        {
            Caption = 'Archived';
        }
        field(100; "Active Resolution No."; Integer)
        {
            BlankZero = true;
            CalcFormula = Lookup ("Incident Resolution Entry"."Entry No." WHERE("Incident Entry No." = FIELD("Entry No."),
                                                                                Active = FILTER(true)));
            Caption = 'Active Resolution No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(210; "Incident Classification"; Code[10])
        {
            Caption = 'Incident Classification';
            TableRelation = "Incident Classification".Code;

            trigger OnValidate()
            begin
                TestField(Archived, false);
            end;
        }
        field(221; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(222; "Created On"; DateTime)
        {
            Caption = 'Created On';
        }
        field(225; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Created,Assigned,In-Progress,To Be Approved,Denied,Finished';
            OptionMembers = Created,Assigned,"In-Progress","To Be Approved",Denied,Finished;

            trigger OnValidate()
            var
                IncidentResolutionEntry: Record "Incident Resolution Entry";
            begin
                TestField(Archived, false);
                if Status <> xRec.Status then
                    if Status = Status::Finished then begin
                        IncidentResolutionEntry.SetRange("Incident Entry No.", "Entry No.");
                        IncidentResolutionEntry.SetRange(Active, true);
                        IncidentResolutionEntry.SetRange(Accept, true);
                        IncidentResolutionEntry.FindFirst;
                        if Confirm(StrSubstNo(ConfirmMsgforFinishedTxt, Format("Entry No."), Format(Status)), false) then
                            Validate(Archived, true);
                    end;
            end;
        }
        field(355; Comment; Boolean)
        {
            CalcFormula = Exist ("Incident Comment Line" WHERE("Table ID" = FILTER(<> 37002549),
                                                               "Incident Entry No." = FIELD("Entry No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(400; "Source Record ID"; RecordID)
        {
            Caption = 'Source Record ID';
            DataClassification = SystemMetadata;
        }
        field(401; SourceRecordID; Text[250])
        {
            Caption = 'SourceRecordID';
            DataClassification = SystemMetadata;
        }
        field(408; "Source Unit of Measure Code"; Code[10])
        {
            Caption = 'Source Unit of Measure Code';
            TableRelation = "Unit of Measure".Code;
        }
        field(409; "Source Transaction Date"; Date)
        {
            Caption = 'Source Transaction Date';
        }
        field(410; "Source Quantity"; Decimal)
        {
            Caption = 'Source Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(411; SourceRecordID2; Text[250])
        {
            Caption = 'SourceRecordID2';
            DataClassification = SystemMetadata;
        }
        field(7311; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "To-do No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        TestField(Archived, false);
        if HasLinks then
            DeleteLinks;
    end;

    var
        LotIn: Record "Lot No. Information";
        ConfirmMsgforFinishedTxt: Label 'Do you want to move the incident entry %1 to %2.';

    procedure ShowNAVRecord(var RecRef: RecordRef)
    var
        PageManagement: Codeunit "Page Management";
        DataTypeManagement: Codeunit "Data Type Management";
    begin
        PageManagement.PageRunModal(RecRef);
    end;

    procedure GetFieldCaption(FieldNo: Integer): Text
    var
        SourceRecordRef: RecordRef;
        SourceFieldRef: FieldRef;
    begin
        if FieldNo = 0 then
            exit(' ');
        if Format("Source Record ID") = '' then
            exit(Format(FieldNo));
        if not SourceRecordRef.Get("Source Record ID") then
            exit(Format(FieldNo));
        SourceFieldRef := SourceRecordRef.Field(FieldNo);
        exit(SourceRecordRef.Caption + ':' + SourceFieldRef.Caption);
    end;

    procedure GetCommentLinetoText(var CommentText: Text; var CommentView: Text)
    var
        IncidentCommentLine: Record "Incident Comment Line";
    begin
        Clear(CommentText);
        IncidentCommentLine.SetRange("Incident Entry No.", "Entry No.");
        if IncidentCommentLine.FindFirst then
            repeat
                CommentText += IncidentCommentLine.Comment;
            until IncidentCommentLine.Next = 0;
        CommentView := IncidentCommentLine.GetView;
    end;

    procedure ReOpen()
    begin
        Archived := false;
        Status := Status::Created;
        Modify;
    end;
}

