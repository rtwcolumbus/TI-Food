table 37002212 "Repack Order Comment Line"
{
    // PR4.00.06
    // P8000496A, VerticalSoft, Jack Reynolds, 23 JUL 07
    //   Adapted from Sales Order Comment Line

    Caption = 'Repack Order Comment Line';
    LookupPageID = "Repack Order Comment List";

    fields
    {
        field(1; "Repack Order No."; Code[20])
        {
            Caption = 'Repack Order No.';
            NotBlank = true;
            TableRelation = "Repack Order";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; Date; Date)
        {
            Caption = 'Date';
        }
        field(4; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(5; Comment; Text[80])
        {
            Caption = 'Comment';
        }
    }

    keys
    {
        key(Key1; "Repack Order No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure SetupNewLine()
    var
        RepackOrderCommentLine: Record "Repack Order Comment Line";
    begin
        RepackOrderCommentLine.SetRange("Repack Order No.", "Repack Order No.");
        if RepackOrderCommentLine.IsEmpty then
            Date := WorkDate;
    end;
}

