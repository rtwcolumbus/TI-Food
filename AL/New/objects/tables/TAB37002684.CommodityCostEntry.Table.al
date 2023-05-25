table 37002684 "Commodity Cost Entry"
{
    // PRW16.00.04
    // P8000856, VerticalSoft, Don Bresee, 24 AUG 10
    //   Add Commodity Class Costing granule
    // 
    // PRW16.00.05
    // P8000939, Columbus IT, Don Bresee, 03 MAY 11
    //   Fix User ID field length
    // 
    // PRW17.00.01
    // P8001154, Columbus IT, Jack Reynolds, 28 MAY 13
    //   Enlarge User ID field
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property

    Caption = 'Commodity Cost Entry';
    DrillDownPageID = "Commodity Cost Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Comm. Class Period Entry No."; Integer)
        {
            Caption = 'Comm. Class Period Entry No.';
            TableRelation = "Commodity Cost Period";
        }
        field(3; "Commodity Class Code"; Code[10])
        {
            Caption = 'Commodity Class Code';
            TableRelation = "Commodity Class";
        }
        field(4; "Comm. Cost Component Code"; Code[10])
        {
            Caption = 'Comm. Cost Component Code';
            TableRelation = "Comm. Cost Component";
        }
        field(5; "Component Value"; Decimal)
        {
            Caption = 'Component Value';
            DecimalPlaces = 2 : 12;
        }
        field(6; "Entry Date"; DateTime)
        {
            Caption = 'Entry Date';
        }
        field(7; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Comm. Class Period Entry No.", "Commodity Class Code", "Comm. Cost Component Code")
        {
            SumIndexFields = "Component Value";
        }
        key(Key3; "Commodity Class Code", "Comm. Cost Component Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Entry Date" := CurrentDateTime;
        "User ID" := UserId;
    end;

    procedure GetDescription(): Text[250]
    var
        CommCostSetup: Record "Comm. Cost Setup Line";
    begin
        if CommCostSetup.Get("Commodity Class Code", "Comm. Cost Component Code") then
            exit(CommCostSetup.GetDescription());
    end;
}

