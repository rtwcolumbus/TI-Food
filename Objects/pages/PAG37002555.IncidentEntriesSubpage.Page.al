page 37002555 "Incident Entries Subpage"
{
    // PRW111.00.01
    // P80036649, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Incident/Complaint Registration

    Caption = 'Incident Entries';
    CardPageID = "Incident Entry Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    PromotedActionCategories = 'New,Process,Report,Item';
    RefreshOnActivate = true;
    SourceTable = "Incident Entry";

    layout
    {
        area(content)
        {
            repeater(Control37002001)
            {
                ShowCaption = false;
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Source; Format("Source Record ID"))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Source';
                }
                field("Primary Key Field 1"; GetFieldCaption("Primary Key Field 1 No."))
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Primary Key Field 1 Value"; "Primary Key Field 1 Value")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Primary Key Field 2"; GetFieldCaption("Primary Key Field 2 No."))
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Primary Key Field 2 Value"; "Primary Key Field 2 Value")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Primary Key Field 3"; GetFieldCaption("Primary Key Field 3 No."))
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Primary Key Field 3 Value"; "Primary Key Field 3 Value")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Archived; Archived)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Created By"; "Created By")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Created On"; "Created On")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Incident Classification"; "Incident Classification")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Incident Reason Code"; "Incident Reason Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Comment; Comment)
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
    }

    var
        CaptionAllText: Label '- All';

    local procedure GetFieldCaption(FieldNo: Integer): Text
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
}

