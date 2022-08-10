table 37002557 "Item Quality Skip Logic Trans."
{
    // PRW111.00.01
    // P80037569, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Develop QC skip logic
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Item Quality Skip Logic Transaction';

    fields
    {
        field(1; "Value Class"; Option)
        {
            Caption = 'Value Class';
            Editable = false;
            OptionCaption = ' ,a,b,c';
            OptionMembers = " ",a,b,c;
        }
        field(3; "Activity Class"; Option)
        {
            Caption = 'Activity Class';
            Editable = false;
            OptionCaption = ' ,A,B,C';
            OptionMembers = " ",A,B,C;
        }
        field(8; "Rejected Level"; Integer)
        {
            Caption = 'Rejected Level';
        }
        field(11; "Item No."; Code[20])
        {
            Caption = 'Item No.';
        }
        field(12; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(13; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
        }
        field(18; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            Editable = false;
            TableRelation = IF ("Source Type" = CONST(Vendor)) Vendor."No.";
        }
        field(19; "Source Type"; Option)
        {
            Caption = 'Source Type';
            Editable = false;
            OptionCaption = ' ,,Vendor,Item';
            OptionMembers = " ",,Vendor,Item;
        }
        field(21; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(22; "Current Level"; Integer)
        {
            Caption = 'Current Level';
        }
        field(23; "Current Skipped Events"; Integer)
        {
            Caption = 'Current Skipped Events';
        }
        field(24; "Current Accepted Events"; Integer)
        {
            Caption = 'Current Accepted Events';
        }
        field(25; "Current Frequency"; Integer)
        {
            Caption = 'Current Frequency';
        }
        field(33; "No. of Test Activities"; Integer)
        {
            Caption = 'No. of Test Activities';
        }
        field(41; "Test Status"; Option)
        {
            Caption = 'Test Status';
            Editable = false;
            OptionCaption = 'Pending,Pass,Fail,Skip';
            OptionMembers = Pending,Pass,Fail,Skip;
        }
        field(51; "Transaction Date"; Date)
        {
            Caption = 'Transaction Date';
        }
    }

    keys
    {
        key(Key1; "Item No.", "Variant Code", "Source Type", "Source No.", "Value Class", "Activity Class", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

