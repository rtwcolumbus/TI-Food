table 14014900 "Process 800 Control-8.00"
{
    // PR3.70.03
    //   Add field
    //     ADC License File
    // 
    // PR4.00
    // P8000265A, VerticalSoft, Jack Reynolds, 08 NOV 05
    //   Support for different product logo and menus
    // 
    // PR5.00
    // P8000509A, VerticalSoft, Jack Reynolds, 31 AUG 07
    //   Change the use of the Product Name for the active product
    //   Support for MenuSuite 60
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013

    Caption = 'Process 800 Control';
    DataPerCompany = false;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            Editable = false;
        }
        field(4; "ADC License File"; BLOB)
        {
            Caption = 'ADC License File';
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
}

