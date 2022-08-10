table 37002133 "Accrual Setup"
{
    // PR3.61AC
    // 
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PRW18.00.02
    // P8002741, To-Increase, Jack Reynolds, 30 Sep 15
    //   Option to create accrual payment documents
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 16 NOV 15
    //   Page Management
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018

    Caption = 'Accrual Setup';
    LookupPageID = "Accrual Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Sales Promo/Rebate Plan Nos."; Code[20])
        {
            Caption = 'Sales Promo/Rebate Plan Nos.';
            TableRelation = "No. Series";
        }
        field(3; "Purchase Accrual Plan Nos."; Code[20])
        {
            Caption = 'Purchase Accrual Plan Nos.';
            TableRelation = "No. Series";
        }
        field(4; "Sales Commission Plan Nos."; Code[20])
        {
            Caption = 'Sales Commission Plan Nos.';
            TableRelation = "No. Series";
        }
        field(5; "Create Payment Documents"; Boolean)
        {
            Caption = 'Create Payment Documents';
            InitValue = true;
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

