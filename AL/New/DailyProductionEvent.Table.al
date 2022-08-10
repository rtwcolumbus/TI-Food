table 37002485 "Daily Production Event"
{
    // PRW16.00.04
    // P8000877, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Non-production events by equipment and date
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property

    Caption = 'Daily Production Event';

    fields
    {
        field(1; "Production Date"; Date)
        {
            Caption = 'Production Date';
        }
        field(2; "Equipment Code"; Code[20])
        {
            Caption = 'Equipment Code';
            TableRelation = Resource WHERE(Type = CONST(Machine));
        }
        field(3; "Event Code"; Code[10])
        {
            Caption = 'Event Code';
            NotBlank = true;
            TableRelation = "Production Planning Event";
        }
        field(4; "Line No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Line No.';
        }
        field(5; "Duration (Hours)"; Decimal)
        {
            Caption = 'Duration (Hours)';
            DecimalPlaces = 0 : 3;
            MinValue = 0;
        }
        field(11; "Start Time"; Time)
        {
            Caption = 'Start Time';
        }
        field(12; "End Date"; Date)
        {
            Caption = 'End Date';
        }
        field(13; "End Time"; Time)
        {
            Caption = 'End Time';
        }
    }

    keys
    {
        key(Key1; "Production Date", "Equipment Code", "Event Code", "Line No.")
        {
            SumIndexFields = "Duration (Hours)";
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Line No." := 0;
        if "Start Time" = 0T then    // P800-MegaApp
            "Start Time" := 000000T; // P800-MegaApp
        CalculateEndDateTime; // P80037404
    end;

    trigger OnModify()
    begin
        CalculateEndDateTime; // P80037404
    end;

    local procedure CalculateEndDateTime()
    var
        EndDateTime: DateTime;
    begin
        // P80037404
        EndDateTime := CreateDateTime("Production Date", "Start Time" + Round(3600000 * "Duration (Hours)", 1));
        "End Date" := DT2Date(EndDateTime);
        "End Time" := DT2Time(EndDateTime);
        // P80037404
    end;
}

