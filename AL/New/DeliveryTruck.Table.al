table 37002073 "Delivery Truck"
{
    // PRW110.0.02
    // P80038970, To-Increase, Dayakar Battini, 28 NOV 17
    //    Delivery Trip changes
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Delivery Truck';
    LookupPageID = "Delivery Truck List";

    fields
    {
        field(1; "Internal No."; Code[10])
        {
            Caption = 'Internal No.';
        }
        field(6; "License Plate"; Code[50])
        {
            Caption = 'License Plate';
        }
        field(7; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(11; "Link to Asset"; Code[20])
        {
            Caption = 'Link to Asset';
            TableRelation = Asset."No.";
        }
    }

    keys
    {
        key(Key1; "Internal No.")
        {
        }
    }

    fieldgroups
    {
    }
}

