table 37002192 "Deduction Comment Line"
{
    // PR4.00.01
    // P8000269A, VerticalSoft, Jack Reynolds, 05 DEC 05
    //   New table to store comment lines associated with deductions prior to posting
    // 
    // PRW18.00.01
    // P8001383, Columbus IT, Jack Reynolds, 08 MAY 15
    //   Fix problem with comments for deduction lines

    Caption = 'Deduction Comment Line';

    fields
    {
        field(1; "Source Table No."; Integer)
        {
            Caption = 'Source Table No.';
        }
        field(2; "Source ID"; Code[20])
        {
            Caption = 'Source ID';
        }
        field(3; "Source Batch Name"; Code[10])
        {
            Caption = 'Source Batch Name';
        }
        field(4; "Source Ref. No."; Integer)
        {
            Caption = 'Source Ref. No.';
        }
        field(5; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,Deduction';
            OptionMembers = " ",Deduction;
        }
        field(6; "Deduction Line No."; Integer)
        {
            Caption = 'Deduction Line No.';
        }
        field(7; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(8; Date; Date)
        {
            Caption = 'Date';
        }
        field(9; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(10; Comment; Text[80])
        {
            Caption = 'Comment';
        }
    }

    keys
    {
        key(Key1; "Source Table No.", "Source ID", "Source Batch Name", "Source Ref. No.", Type, "Deduction Line No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure SetUpNewLine()
    var
        CommentLine: Record "Deduction Comment Line";
    begin
        CommentLine.SetRange("Source Table No.", "Source Table No.");
        CommentLine.SetRange("Source ID", "Source ID");
        CommentLine.SetRange("Source Batch Name", "Source Batch Name");
        CommentLine.SetRange("Source Ref. No.", "Source Ref. No.");
        CommentLine.SetRange(Type, Type);
        CommentLine.SetRange("Deduction Line No.", "Deduction Line No.");
        CommentLine.SetRange(Date, WorkDate);
        if not CommentLine.Find('-') then
            Date := WorkDate;
    end;
}

