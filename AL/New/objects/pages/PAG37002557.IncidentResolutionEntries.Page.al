page 37002557 "Incident Resolution Entries"
{
    // PRW111.00.01
    // P80036649, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Incident/Complaint Registration

    Caption = 'Incident Resolution Entries';
    CardPageID = "Incident Resolution Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    PromotedActionCategories = 'New,Process,Report,Item';
    RefreshOnActivate = true;
    SourceTable = "Incident Resolution Entry";

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
                field(Active; Active)
                {
                    ApplicationArea = FOODBasic;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Date and Time"; "Date and Time")
                {
                    ApplicationArea = FOODBasic;
                }
                field("FORMAT(""Incident Entry Record ID"")"; Format("Incident Entry Record ID"))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Source';
                }
                field("Resolution Reason Code"; "Resolution Reason Code")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Reason Code';
                }
                field(Accept; Accept)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Archived; Archived)
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
        if Format("Incident Entry Record ID") = '' then
            exit(Format(FieldNo));
        if not SourceRecordRef.Get("Incident Entry Record ID") then
            exit(Format(FieldNo));
        SourceFieldRef := SourceRecordRef.Field(FieldNo);
        exit(SourceRecordRef.Caption + ':' + SourceFieldRef.Caption);
    end;
}

