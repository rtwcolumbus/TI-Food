table 37002009 "Ledger Entry Comment Line"
{
    // PR4.00.01
    // P8000268B, VerticalSoft, Jack Reynolds, 04 DEC 05
    //   New table to store comments attached to ledger entries

    Caption = 'Ledger Entry Comment Line';

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
        }
        field(2; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
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
    }

    keys
    {
        key(Key1; "Table ID", "Entry No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure SetUpNewLine()
    var
        CommentLine: Record "Ledger Entry Comment Line";
    begin
        CommentLine.SetRange("Table ID", "Table ID");
        CommentLine.SetRange("Entry No.", "Entry No.");
        CommentLine.SetRange(Date, WorkDate);
        if not CommentLine.Find('-') then
            Date := WorkDate;
    end;
}

