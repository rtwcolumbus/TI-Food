table 37002805 "Work Order Comment Line"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 30 AUG 06
    //   Standard table for document comments

    Caption = 'Work Order Comment Line';

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
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
        key(Key1; "No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure SetUpNewLine()
    var
        WorkOrderCommentLine: Record "Work Order Comment Line";
    begin
        WorkOrderCommentLine.SetRange("No.", "No.");
        WorkOrderCommentLine.SetRange(Date, WorkDate);
        if not WorkOrderCommentLine.FindFirst then
            Date := WorkDate;
    end;
}

