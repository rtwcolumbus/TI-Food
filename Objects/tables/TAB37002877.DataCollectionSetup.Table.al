table 37002877 "Data Collection Setup"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.00.01
    // P8001162, Columbus IT, Jack Reynolds, 24 MAY 13
    //   Remove "Alert Gen. Interval (Minutes)"
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 16 NOV 15
    //   Page Management
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Data Collection Setup';
    LookupPageID = "Data Collection Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Data Sheet Nos."; Code[20])
        {
            Caption = 'Data Sheet Nos.';
            TableRelation = "No. Series";
        }
        field(3; "Critical Alert Response Time"; Duration)
        {
            Caption = 'Critical Alert Response Time';
        }
        field(4; "Critical Alert Group"; Code[10])
        {
            Caption = 'Critical Alert Group';
            TableRelation = "Data Collection Alert Group";
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }

    procedure Initialize()
    begin
        // P80073095
        Init;
        "Critical Alert Response Time" := 30 * 60 * 1000;  // 30 minutes (in milliseconds)
    end;
}

