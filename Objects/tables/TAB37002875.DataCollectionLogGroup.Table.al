table 37002875 "Data Collection Log Group"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Data Collection Log Group';
    LookupPageID = "Data Collection Log Groups";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        DataSheetHeader: Record "Data Sheet Header";
        DataCollectionLine: Record "Data Collection Line";
        DataCollectionTemplateLine: Record "Data Collection Template Line";
    begin
        DataSheetHeader.SetRange("Source ID", 0);
        DataSheetHeader.SetRange("Source Subtype", 0);
        DataSheetHeader.SetRange("Source No.", Code);
        DataSheetHeader.SetFilter(Status, '%1|%2', DataSheetHeader.Status::Pending, DataSheetHeader.Status::"In Progress");
        if not DataSheetHeader.IsEmpty then
            Error(Text001);

        DataCollectionLine.SetRange("Log Group Code", Code);
        DataCollectionLine.ModifyAll("Log Group Code", '');

        DataCollectionTemplateLine.SetRange("Log Group Code", Code);
        DataCollectionTemplateLine.ModifyAll("Log Group Code", '');
    end;

    var
        Text001: Label 'Open data sheets exist.';
}

