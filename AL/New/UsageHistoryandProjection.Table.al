table 37002047 "Usage History and Projection"
{
    // PR4.00.02
    // P8000312A, VerticalSoft, Jack Reynolds, 17 MAR 06
    //   Temp. table to collect usage history and projection of future usage
    // 
    // PRW16.00.06
    // P8001004, Columbus IT, Jack Reynolds, 15 DEC 11
    //   Allow fields to allow links on subpages to be established
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Usage History and Projection';
    ReplicateData = false;

    fields
    {
        field(1; "Period Offset"; Integer)
        {
            Caption = 'Period Offset';
            DataClassification = SystemMetadata;
        }
        field(2; "Start Date - Comp."; Date)
        {
            Caption = 'Start Date - Comp.';
            DataClassification = SystemMetadata;
        }
        field(3; "End Date - Comp."; Date)
        {
            Caption = 'End Date - Comp.';
            DataClassification = SystemMetadata;
        }
        field(4; "Start Date - Current"; Date)
        {
            Caption = 'Start Date - Current';
            DataClassification = SystemMetadata;
        }
        field(5; "End Date - Current"; Date)
        {
            Caption = 'End Date - Current';
            DataClassification = SystemMetadata;
        }
        field(6; "Comparison Period"; Decimal)
        {
            Caption = 'Comparison Period';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
        }
        field(7; "Current Period"; Decimal)
        {
            Caption = 'Current Period';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
        }
        field(8; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = SystemMetadata;
        }
        field(9; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = SystemMetadata;
        }
        field(10; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Period Offset")
        {
            SumIndexFields = "Comparison Period", "Current Period";
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label '<Month,2>/<Day,2>';

    procedure PeriodDescription() Description: Text[30]
    begin
        Description := Format("Start Date - Current", 5, Text001);
        if "End Date - Current" <> "Start Date - Current" then
            Description := Description + ' - ' + Format("End Date - Current", 5, Text001);
    end;
}

