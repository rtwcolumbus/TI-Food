page 37002945 "Incident Entries-Confirm"
{
    // PRW111.00.01
    // P80036649, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Incident/Complaint Registration
    // 
    // PRW121.2
    // P800163700, To-Increase, Jack Reynolds, 07 FEB 23
    //   Support for Auto-Save as You Work


    Caption = 'Incident Entries-Confirm';
    DataCaptionExpression = GetCaption;
    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Incident Entry";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Control37002001)
            {
                ShowCaption = false;
                field("Primary Key Field 1 Value"; "Primary Key Field 1 Value")
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = GetFieldCaption("Primary Key Field 1 No.");
                }
                field("Primary Key Field 2 Value"; "Primary Key Field 2 Value")
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = GetFieldCaption("Primary Key Field 2 No.");
                    Visible = Field2Visible;
                }
                field("Primary Key Field 3 Value"; "Primary Key Field 3 Value")
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = GetFieldCaption("Primary Key Field 3 No.");
                    Visible = Field3Visible;
                }
                field("Incident Classification"; "Incident Classification")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Incident Reason Code"; "Incident Reason Code")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group("Source Details")
            {
                Caption = 'Source Details';
                field("FORMAT(SourceFieldData[1])"; Format(SourceFieldData[1]))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = SourceFieldCaption[1];
                    Caption = '1';
                    Editable = false;
                }
                field("FORMAT(SourceFieldData[2])"; Format(SourceFieldData[2]))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = SourceFieldCaption[2];
                    Caption = '2';
                    Editable = false;
                }
                field("FORMAT(SourceFieldData[3])"; Format(SourceFieldData[3]))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = SourceFieldCaption[3];
                    Caption = '3';
                    Editable = false;
                }
                field("FORMAT(SourceFieldData[4])"; Format(SourceFieldData[4]))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = SourceFieldCaption[4];
                    Caption = '4';
                    Editable = false;
                }
                field("FORMAT(SourceFieldData[5])"; Format(SourceFieldData[5]))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = SourceFieldCaption[5];
                    Caption = '5';
                    Editable = false;
                }
                field("FORMAT(SourceFieldData[6])"; Format(SourceFieldData[6]))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = SourceFieldCaption[6];
                    Caption = '6';
                    Editable = false;
                }
                field("FORMAT(SourceFieldData[7])"; Format(SourceFieldData[7]))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = SourceFieldCaption[7];
                    Caption = '7';
                    Editable = false;
                }
                field("FORMAT(SourceFieldData[8])"; Format(SourceFieldData[8]))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = SourceFieldCaption[8];
                    Caption = '8';
                    Editable = false;
                }
                field("FORMAT(SourceFieldData[9])"; Format(SourceFieldData[9]))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = SourceFieldCaption[9];
                    Caption = '9';
                    Editable = false;
                }
                field("FORMAT(SourceFieldData[10])"; Format(SourceFieldData[10]))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = SourceFieldCaption[10];
                    Caption = '10';
                    Editable = false;
                }
                group(Control37002002)
                {
                    ShowCaption = false;
                    field("Incident Comments"; CommentText)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Incident Comments';
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
                begin
                    SourceRecRef.Get("Source Record ID");
                    ShowNAVRecord(SourceRecRef);
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
    begin
        Field2Visible := "Primary Key Field 2 Value" <> '';
        Field3Visible := "Primary Key Field 3 Value" <> '';
        GetClassificationCode("Incident Classification");
    end;

    var
        CommentText: Text;
        Field2Visible: Boolean;
        Field3Visible: Boolean;
        SourceQty: Decimal;
        SourceUOM: Code[10];
        SourceFieldCaption: array[10] of Text;
        SourceFieldData: array[10] of Variant;

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

    procedure SetCurrentRecord(var IncidentEntry: Record "Incident Entry" temporary; var FldCaption: array[10] of Text; var FldData: array[10] of Variant)
    begin
        Rec.Copy(IncidentEntry, true);
        CopyArray(SourceFieldCaption, FldCaption, 1, 10);
        CopyArray(SourceFieldData, FldData, 1, 10);
    end;

    procedure GetCurrentRecord(var IncidentEntry: Record "Incident Entry" temporary; var NewComment: Text)
    begin
        IncidentEntry.Copy(Rec, true);
        NewComment := CommentText;
    end;

    local procedure GetCaption(): Text
    begin
        exit(Format(Format("Source Record ID")));
    end;

    local procedure GetClassificationCode(var ClassificationCode: Code[20])
    var
        IncidentClassification: Record "Incident Classification";
        SourceRecordRef: RecordRef;
        SourceFieldRef: FieldRef;
    begin
        IncidentClassification.SetRange("Incident Area ID", "Table No.");
        if IncidentClassification.FindFirst then
            ClassificationCode := IncidentClassification.Code;
    end;
}

