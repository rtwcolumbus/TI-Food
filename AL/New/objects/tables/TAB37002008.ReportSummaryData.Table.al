table 37002008 "Report Summary Data"
{
    // PR3.70.10
    // P8000231A, Myers Nissi, Phyllis McGovern, 21 JUL 05
    //   Table added: work done by Steve Post
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Report Summary Data';
    ReplicateData = false;

    fields
    {
        field(1; Key1; Code[20])
        {
            Caption = 'Key1';
            DataClassification = SystemMetadata;
        }
        field(10; "Data Element"; Integer)
        {
            Caption = 'Data Element';
            DataClassification = SystemMetadata;
        }
        field(11; Value; Decimal)
        {
            Caption = 'Value';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; Key1, "Data Element")
        {
        }
    }

    fieldgroups
    {
    }

    procedure AddValue(NewValue: Decimal)
    begin
        if not Find then begin
            Init;
            Insert;
        end;
        Value += NewValue;
        Modify;
    end;
}

