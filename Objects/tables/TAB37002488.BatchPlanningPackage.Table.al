table 37002488 "Batch Planning - Package"
{
    // PRW16.00.0
    // P8000877, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Basis for the Package sub-page of the batch planning pages
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Batch Planning - Package';
    ReplicateData = false;

    fields
    {
        field(1; "Batch No."; Integer)
        {
            Caption = 'Batch No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "Equipment Code"; Code[20])
        {
            Caption = 'Equipment Code';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(3; "Equipment Description"; Text[100])
        {
            Caption = 'Equipment Description';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(4; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(5; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(6; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(7; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(10; Include; Boolean)
        {
            Caption = 'Include';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(11; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                if ("Additional Quantity Possible" + xRec.Quantity) < Quantity then
                    Error(Text001, FieldCaption(Quantity), "Additional Quantity Possible" + xRec.Quantity);
            end;
        }
        field(12; "Additional Quantity Possible"; Decimal)
        {
            Caption = 'Additional Quantity Possible';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;

            trigger OnValidate()
            begin
                if "Additional Quantity Possible" < 0 then
                    "Additional Quantity Possible" := 0
                else
                    if "Additional Quantity Possible" > ("Maximum Quantity Possible" - Quantity) then
                        "Additional Quantity Possible" := ("Maximum Quantity Possible" - Quantity);
            end;
        }
        field(13; "Maximum Quantity Possible"; Decimal)
        {
            Caption = 'Maximum Quantity Possible';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(14; "Production Time (Hours)"; Decimal)
        {
            Caption = 'Production Time (Hours)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(21; "Package Time (Hours)"; Decimal)
        {
            Caption = 'Package Time (Hours)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(22; "Other Time (Hours)"; Decimal)
        {
            Caption = 'Other Time (Hours)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(31; "Fixed Time"; Decimal)
        {
            Caption = 'Fixed Time';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(32; "Variable Time"; Decimal)
        {
            Caption = 'Variable Time';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(33; "Intermediate Quantity per"; Decimal)
        {
            Caption = 'Intermediate Quantity per';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(34; "Rounding Precision"; Decimal)
        {
            Caption = 'Rounding Precision';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(101; Summary; Boolean)
        {
            Caption = 'Summary';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(102; Highlight; Boolean)
        {
            Caption = 'Highlight';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Batch No.", "Equipment Code", "Item No.", "Variant Code")
        {
        }
        key(Key2; "Item No.", "Equipment Code", "Batch No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label '%1 must not exceed %2.';

    procedure CalculateTime()
    begin
        if Quantity <> 0 then
            "Production Time (Hours)" := Round("Fixed Time" + Quantity * "Variable Time", 0.00001)
        else
            "Production Time (Hours)" := 0;
    end;
}

