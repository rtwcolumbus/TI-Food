table 37002876 "Data Collection Comment"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection

    Caption = 'Data Collection Comment';

    fields
    {
        field(1; "Source ID"; Integer)
        {
            Caption = 'Source ID';
        }
        field(2; "Source Key 1"; Code[20])
        {
            Caption = 'Source Key 1';
        }
        field(3; "Source Key 2"; Code[20])
        {
            Caption = 'Source Key 2';
        }
        field(4; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,Q/C,Shipping,Receiving,Production,Log';
            OptionMembers = " ","Q/C",Shipping,Receiving,Production,Log;
        }
        field(5; "Data Element Code"; Code[10])
        {
            Caption = 'Data Element Code';
            NotBlank = true;
            TableRelation = "Data Collection Data Element";
        }
        field(6; "Data Collection Line No."; Integer)
        {
            Caption = 'Data Collection Line No.';
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
        field(21; "Variant Type"; Option)
        {
            Caption = 'Variant Type';
            OptionCaption = 'Item Only,Item and Variant,Variant Only';
            OptionMembers = "Item Only","Item and Variant","Variant Only";
        }
    }

    keys
    {
        key(Key1; "Source ID", "Source Key 1", "Source Key 2", Type, "Variant Type", "Data Element Code", "Data Collection Line No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure SetupNewLine()
    var
        CommentLine: Record "Data Collection Comment";
    begin
        CommentLine.SetRange("Source ID", "Source ID");
        CommentLine.SetRange("Source Key 1", "Source Key 1");
        CommentLine.SetRange("Source Key 2", "Source Key 2");
        CommentLine.SetRange(Type, Type);
        CommentLine.SetRange("Variant Type", "Variant Type");
        CommentLine.SetRange("Data Element Code", "Data Element Code");
        CommentLine.SetRange("Data Collection Line No.", "Data Collection Line No.");
        CommentLine.SetRange(Date, WorkDate);
        if not CommentLine.Find('-') then
            Date := WorkDate;
    end;
}

