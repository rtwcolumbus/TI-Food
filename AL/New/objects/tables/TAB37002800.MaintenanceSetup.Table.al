table 37002800 "Maintenance Setup"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 30 AUG 06
    //   Maintenance Management setup options
    // 
    // P8000335A, VerticalSoft, Jack Reynolds, 20 SEP 06
    //   Add fields for default material and contract account
    // 
    // PRW15.00.01
    // P8000590A, VerticalSoft, Jack Reynolds, 07 MAR 08
    //   Add field for Asset Usage Tolerance (%)
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 16 NOV 15
    //   Page Management
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018

    Caption = 'Maintenance Setup';
    LookupPageID = "Maintenance Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Asset Nos."; Code[20])
        {
            Caption = 'Asset Nos.';
            TableRelation = "No. Series";
        }
        field(3; "Work Order Nos."; Code[20])
        {
            Caption = 'Work Order Nos.';
            TableRelation = "No. Series";
        }
        field(4; "PM Order Nos."; Code[20])
        {
            Caption = 'PM Order Nos.';
            TableRelation = "No. Series";
        }
        field(5; "Default Work Order Status"; Option)
        {
            Caption = 'Default Work Order Status';
            OptionCaption = 'Waiting Approval,Waiting Schedule,Waiting Parts,Do,In Work';
            OptionMembers = "Waiting Approval","Waiting Schedule","Waiting Parts","Do","In Work";
        }
        field(6; "Default Work Order Priority"; Integer)
        {
            Caption = 'Default Work Order Priority';
            MaxValue = 9;
            MinValue = 0;
        }
        field(7; "Employee Mandatory"; Boolean)
        {
            Caption = 'Employee Mandatory';
        }
        field(8; "Doc. No. is Work Order No."; Boolean)
        {
            Caption = 'Doc. No. is Work Order No.';
        }
        field(9; "Vendor Mandatory"; Boolean)
        {
            Caption = 'Vendor Mandatory';
        }
        field(10; "Posting Grace Period"; DateFormula)
        {
            Caption = 'Posting Grace Period';
            InitValue = '1M';
        }
        field(11; "Last PM Order No."; Integer)
        {
            Caption = 'Last PM Order No.';
        }
        field(12; "Default PM Order Status"; Option)
        {
            Caption = 'Default PM Order Status';
            OptionCaption = 'Waiting Approval,Waiting Schedule,Waiting Parts,Do,In Work';
            OptionMembers = "Waiting Approval","Waiting Schedule","Waiting Parts","Do","In Work";
        }
        field(13; "Default PM Priority"; Integer)
        {
            Caption = 'Default PM Priority';
            MaxValue = 9;
            MinValue = 0;
        }
        field(15; "Default Material Account"; Code[20])
        {
            Caption = 'Default Material Account';
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true));
        }
        field(16; "Default Contract Account"; Code[20])
        {
            Caption = 'Default Contract Account';
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true));
        }
        field(17; "Asset Usage Tolerance (%)"; Decimal)
        {
            Caption = 'Asset Usage Tolerance (%)';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
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

