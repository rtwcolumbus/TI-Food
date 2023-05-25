table 97 "Comment Line" // Version: FOODNA
{
    // PR1.00
    //   Add Unapproved Item as option for table name
    // 
    // PR3.10
    //   Unapproved moves because Engineering Change is removed
    // 
    // PR3.70
    //   Unpapproved Item moves from position 12 to 16
    //   Table Relation for No. updated to include unapproved items
    // 
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 05 MAY 06
    //   Add Asset and PM as option for table name

    Caption = 'Comment Line';
    DrillDownPageID = "Comment List";
    LookupPageID = "Comment List";

    fields
    {
        field(1; "Table Name"; Enum "Comment Line Table Name")
        {
            Caption = 'Table Name';
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; Date; Date)
        {
            Caption = 'Date';
        }
        field(5; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(6; Comment; Text[80])
        {
            Caption = 'Comment';
        }
        field(37002000; "Order Comment Flags"; Code[30])
        {
            Caption = 'Order Comment Flags';
            Description = 'PR3.70';

            trigger OnValidate()
            begin
                // PR3.70
                if not OrderCommentFns.ValidateCommentFlags("Table Name", "Order Comment Flags") then
                    Error(Text37002000, FieldCaption("Order Comment Flags"), "Table Name");
                // PR3.70
            end;
        }
    }

    keys
    {
        key(Key1; "Table Name", "No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        OrderCommentFns: Codeunit "Order Comment Functions";
        Text37002000: Label '%1 are not supported for %2.';

    procedure SetUpNewLine()
    var
        CommentLine: Record "Comment Line";
    begin
        CommentLine.SetRange("Table Name", "Table Name");
        CommentLine.SetRange("No.", "No.");
        CommentLine.SetRange(Date, WorkDate());
        if not CommentLine.FindFirst() then
            Date := WorkDate();

        OnAfterSetUpNewLine(Rec, CommentLine);
    end;

    procedure RenameCommentLine(TableName: Enum "Comment Line Table Name"; OldNo: Code[20]; NewNo: Code[20])
    var
        OldCommentLine: Record "Comment Line";
        NewCommentLine: Record "Comment Line";
    begin
        OldCommentLine.SetRange("Table Name", TableName);
        OldCommentLine.SetRange("No.", OldNo);
        if OldCommentLine.FindSet() then begin
            repeat
                NewCommentLine := OldCommentLine;
                NewCommentLine."No." := NewNo;
                NewCommentLine.Insert();
            until OldCommentLine.Next() = 0;
            OldCommentLine.DeleteAll();
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetUpNewLine(var CommentLineRec: Record "Comment Line"; var CommentLineFilter: Record "Comment Line")
    begin
    end;
}

