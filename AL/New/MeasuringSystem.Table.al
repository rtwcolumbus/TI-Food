table 37002000 "Measuring System"
{
    // PR1.00, Myers Nissi, Jack Reynolds, 26 MAY 00, PR001
    //   This new table contains the list of base unit of measure for each
    //   type (length, width, volume) and measuring system (conventional,
    //   metric) and conversion factors between the measuring systems
    // 
    // PRW17.10.03
    // P8001318, Columbus IT, Jack Reynolds, 29 APR 14
    //   Fix decimal place issue with conversion factor
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Measuring System';
    DataPerCompany = false;

    fields
    {
        field(1; "Measuring System"; Option)
        {
            Caption = 'Measuring System';
            OptionCaption = 'Conventional,Metric';
            OptionMembers = Conventional,Metric;
        }
        field(2; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,Length,Weight,Volume';
            OptionMembers = " ",Length,Weight,Volume;
        }
        field(3; UOM; Code[10])
        {
            Caption = 'UOM';
        }
        field(4; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(5; "Conversion to Other"; Decimal)
        {
            Caption = 'Conversion to Other';
            DecimalPlaces = 0 : 17;
        }
    }

    keys
    {
        key(Key1; "Measuring System", Type)
        {
        }
    }

    fieldgroups
    {
    }
}

