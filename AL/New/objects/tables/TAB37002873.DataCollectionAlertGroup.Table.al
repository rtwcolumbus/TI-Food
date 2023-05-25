table 37002873 "Data Collection Alert Group"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Data Collection Alert Group';
    DataCaptionFields = "Code", Description;
    LookupPageID = "Data Collection Alert Groups";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
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
        AlertGroupMember: Record "Data Coll. Alert Group Member";
        DataCollectionSetup: Record "Data Collection Setup";
        DataCollectionLine: Record "Data Collection Line";
        DataCollectionTemplateLine: Record "Data Collection Template Line";
    begin
        AlertGroupMember.SetRange("Group Code", Code);
        AlertGroupMember.DeleteAll(true);

        DataCollectionSetup.Get;
        if DataCollectionSetup."Critical Alert Group" = Code then begin
            DataCollectionSetup."Critical Alert Group" := '';
            DataCollectionSetup.Modify;
        end;

        DataCollectionLine.SetRange("Level 1 Alert Group", Code);
        DataCollectionLine.ModifyAll("Level 1 Alert Group", '');
        DataCollectionLine.SetRange("Level 1 Alert Group");

        DataCollectionLine.SetRange("Level 2 Alert Group", Code);
        DataCollectionLine.ModifyAll("Level 2 Alert Group", '');
        DataCollectionLine.SetRange("Level 2 Alert Group");

        DataCollectionLine.SetRange("Missed Collection Alert Group", Code);
        DataCollectionLine.ModifyAll("Missed Collection Alert Group", '');
        DataCollectionLine.SetRange("Missed Collection Alert Group");

        DataCollectionTemplateLine.SetRange("Level 1 Alert Group", Code);
        DataCollectionTemplateLine.ModifyAll("Level 1 Alert Group", '');
        DataCollectionTemplateLine.SetRange("Level 1 Alert Group");

        DataCollectionTemplateLine.SetRange("Level 2 Alert Group", Code);
        DataCollectionTemplateLine.ModifyAll("Level 2 Alert Group", '');
        DataCollectionTemplateLine.SetRange("Level 2 Alert Group");

        DataCollectionTemplateLine.SetRange("Missed Collection Alert Group", Code);
        DataCollectionTemplateLine.ModifyAll("Missed Collection Alert Group", '');
        DataCollectionTemplateLine.SetRange("Missed Collection Alert Group");
    end;
}

