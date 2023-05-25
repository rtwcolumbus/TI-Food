page 37002941 "Incident Res. Entries-Confirm"
{
    // PRW111.00.01
    // P80036649, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Incident/Complaint Registration

    Caption = 'Incident Resolution Entries-Confirm';
    DataCaptionExpression = GetCaption;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Incident Resolution Entry";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Control37002001)
            {
                ShowCaption = false;
                field("Incident Entry No."; "Incident Entry No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Incident Entry Source"; Format("Incident Entry Record ID"))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Incident Entry Source';
                }
                group(Control37002008)
                {
                    ShowCaption = false;
                    field("Incident Comments"; IncidentCommentText)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Incident Comments';
                        Editable = false;
                        MultiLine = true;
                    }
                    field("Resolution Comments"; ResolutionCommentText)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Resolution Comments';
                        MultiLine = true;
                    }
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = true;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(OpenDocument)
            {
                ApplicationArea = FOODBasic;
                Caption = '&Open Record';
                Image = ViewDetails;
                ToolTip = 'Open the document, journal line, or entry that the incoming document is linked to.';

                trigger OnAction()
                var
                    SourceRecRef: RecordRef;
                    IncidentEntry: Record "Incident Entry";
                begin
                    SourceRecRef.Get("Incident Entry Record ID");
                    IncidentEntry.Get("Incident Entry No.");
                    IncidentEntry.ShowNAVRecord(SourceRecRef);
                end;
            }
        }
        area(Promoted)
        {
            actionref(OpenDocument_Promoted; OpenDocument)
            {
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        IncidentEntry: Record "Incident Entry";
    begin
        Clear(IncidentCommentText);
        if IncidentEntry.Get("Incident Entry No.") then
            IncidentEntry.GetCommentLinetoText(IncidentCommentText, IncidentCommentView);
    end;

    var
        IncidentCommentText: Text;
        IncidentCommentView: Text;
        ResolutionCommentText: Text;
        Field2Visible: Boolean;
        Field3Visible: Boolean;

    procedure SetCurrentRecord(var IncidentEntry: Record "Incident Resolution Entry" temporary)
    begin
        Rec.Copy(IncidentEntry, true);
    end;

    procedure GetCurrentRecord(var IncidentEntry: Record "Incident Resolution Entry" temporary; var NewComment: Text)
    begin
        IncidentEntry.Copy(Rec, true);
        NewComment := ResolutionCommentText;
    end;

    local procedure GetCaption(): Text
    begin
        exit(Format(Format("Incident Entry Record ID")));
    end;
}

