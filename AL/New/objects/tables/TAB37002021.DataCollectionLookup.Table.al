table 37002021 "Data Collection Lookup"
{
    // PR1.10
    //   New table for subcategories to Lookup lot specification categories
    // 
    // PR3.70.07
    // P8000152A, Myers Nissi, Jack Reynolds, 26 NOV 04
    //   Renamed table and fields
    // 
    // PRW16.00
    // P8000639, VerticalSoft, Jack Reynolds, 18 NOV 08
    //   Add DropDown field group
    // 
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Data Collection Lookup';
    LookupPageID = "Data Collection Lookups";

    fields
    {
        field(1; "Data Element Code"; Code[10])
        {
            Caption = 'Data Element Code';
            TableRelation = "Data Collection Data Element" WHERE(Type = CONST("Lookup"));
        }
        field(2; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Data Element Code", "Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description)
        {
        }
    }
}

