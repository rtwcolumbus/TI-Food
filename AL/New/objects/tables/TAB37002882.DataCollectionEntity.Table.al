table 37002882 "Data Collection Entity"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.10.01
    // P8001258, Columbus IT, Jack Reynolds, 10 JAN 14
    //   Increase size ot text fields/variables
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Data Collection Entity';

    fields
    {
        field(1; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "Prod. Order Line No."; Integer)
        {
            Caption = 'Prod. Order Line No.';
            DataClassification = SystemMetadata;
        }
        field(3; "Source ID"; Integer)
        {
            Caption = 'Source ID';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(4; "Source Key 1"; Code[20])
        {
            Caption = 'Source Key 1';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(5; "Source Key 2"; Code[20])
        {
            Caption = 'Source Key 2';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(11; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(12; Include; Boolean)
        {
            Caption = 'Include';
            DataClassification = SystemMetadata;
        }
        field(13; "Data Sheet No."; Code[20])
        {
            Caption = 'Data Sheet No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Location Code", "Prod. Order Line No.", "Source ID", "Source Key 1", "Source Key 2")
        {
        }
    }

    fieldgroups
    {
    }

    procedure EntityName(): Text[50]
    var
        EntityRecordRef: RecordRef;
    begin
        // P8001258 - increase size or Return Value to Text50
        EntityRecordRef.Open("Source ID");
        exit(EntityRecordRef.Caption);
    end;
}

