table 37002473 "Production Time by Date"
{
    // PR4.00
    // P8000197A, Myers Nissi, Jack Reynolds, 21 SEP 05
    //   Used as a temporary table to break track production time by date
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Production Time by Date';
    ReplicateData = false;

    fields
    {
        field(1; Date; Date)
        {
            Caption = 'Date';
            DataClassification = SystemMetadata;
        }
        field(2; "Time Required"; Decimal)
        {
            Caption = 'Time Required';
            DataClassification = SystemMetadata;
        }
        field(3; "Starting Time"; Time)
        {
            Caption = 'Starting Time';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; Date)
        {
            SumIndexFields = "Time Required";
        }
    }

    fieldgroups
    {
    }
}

