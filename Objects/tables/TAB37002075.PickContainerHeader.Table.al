table 37002075 "Pick Container Header"
{
    // PRW15.00.01
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   New table - header for pick containers (created via ADC)
    // 
    // PRW16.00.05
    // P8000990, Columbus IT, Jack Reynolds, 02 NOV 11
    //   Support for ADC transaction setup
    // 
    // PRW19.00
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup old delivery trips
    // 
    // PRW110.0.02
    // P80038979, To-Increase, Dayakar Battini, 18 DEC 17
    //   Adding Pickup load management functionality

    Caption = 'Pick Container Header';

    fields
    {
        field(1; "No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'No.';
            Editable = false;
        }
        field(2; ID; Code[50])
        {
            Caption = 'ID';
            Editable = false;
        }
        field(3; "Pick No."; Integer)
        {
            Caption = 'Pick No.';
            Editable = false;
        }
        field(4; "Source Type"; Integer)
        {
            Caption = 'Source Type';
            Editable = false;
        }
        field(5; "Source Subtype"; Option)
        {
            Caption = 'Source Subtype';
            Editable = false;
            OptionCaption = '0,1,2,3,4,5,6,7,8,9';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9";
        }
        field(6; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            Editable = false;
        }
        field(7; "Pick Class Code"; Code[10])
        {
            Caption = 'Pick Class Code';
            Editable = false;
        }
        field(8; Complete; Boolean)
        {
            Caption = 'Complete';
            Editable = false;
        }
        field(9; "ID is Case Label"; Boolean)
        {
            Caption = 'ID is Case Label';
            Editable = false;
        }
        field(10; "Delivery Trip No."; Code[20])
        {
            Caption = 'Delivery Trip No.';
            Numeric = false;
            TableRelation = "N138 Delivery Trip";
        }
        field(11; Loaded; Boolean)
        {
            Caption = 'Loaded';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; ID)
        {
        }
        key(Key3; "Pick No.", Complete)
        {
        }
        key(Key4; "Delivery Trip No.", "Source Type", "Source Subtype", "Source No.", "Pick Class Code")
        {
        }
    }

    fieldgroups
    {
    }
}

