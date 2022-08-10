table 37002138 "Accrual Plan Search Line"
{
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PR4.00.03
    // P8000324A, VerticalSoft, Jack Reynolds, 06 APR 06
    //   Add field for plan type
    // 
    // PR4.00.04
    // P8000355A, VerticalSoft, Jack Reynolds, 19 JUL 06
    //   Add support for accrual groups
    // 
    // PRW15.00.01
    // P8000601A, VerticalSoft, Don Bresee, 30 OCT 07
    //   Change search key for SQL
    // 
    // PRW16.00.01
    // P8000767, VerticalSoft, Don Bresee, 04 FEB 10
    //   Modify existing key - move Plan Type

    Caption = 'Accrual Plan Search Line';

    fields
    {
        field(1; "Accrual Plan Type"; Option)
        {
            Caption = 'Accrual Plan Type';
            OptionCaption = 'Sales,Purchase';
            OptionMembers = Sales,Purchase;
        }
        field(2; "Computation Level"; Option)
        {
            Caption = 'Computation Level';
            OptionCaption = 'Document Line,Document,Plan';
            OptionMembers = "Document Line",Document,Plan;
        }
        field(3; "Date Type"; Option)
        {
            Caption = 'Date Type';
            OptionCaption = 'Posting Date,Order Date';
            OptionMembers = "Posting Date","Order Date";
        }
        field(4; "Start Date"; Date)
        {
            Caption = 'Start Date';
        }
        field(5; "End Date"; Date)
        {
            Caption = 'End Date';
        }
        field(6; "Source Selection Type"; Option)
        {
            Caption = 'Source Selection Type';
            OptionCaption = 'Bill-to/Pay-to,Sell-to/Buy-from,Sell-to/Ship-to';
            OptionMembers = "Bill-to/Pay-to","Sell-to/Buy-from","Sell-to/Ship-to";
        }
        field(7; "Source Selection"; Option)
        {
            Caption = 'Source Selection';
            OptionCaption = 'All,Specific,Price Group,Accrual Group';
            OptionMembers = All,Specific,"Price Group","Accrual Group";
        }
        field(8; "Source Code"; Code[20])
        {
            Caption = 'Source Code';
            TableRelation = IF ("Accrual Plan Type" = CONST(Sales),
                                "Source Selection" = CONST(Specific)) Customer
            ELSE
            IF ("Accrual Plan Type" = CONST(Sales),
                                         "Source Selection" = CONST("Price Group")) "Customer Price Group"
            ELSE
            IF ("Accrual Plan Type" = CONST(Purchase),
                                                  "Source Selection" = CONST(Specific)) Vendor;
        }
        field(9; "Source Ship-to Code"; Code[10])
        {
            Caption = 'Source Ship-to Code';
            TableRelation = IF ("Accrual Plan Type" = CONST(Sales),
                                "Source Selection Type" = CONST("Sell-to/Ship-to"),
                                "Source Selection" = CONST(Specific)) "Ship-to Address".Code WHERE("Customer No." = FIELD("Source Code"));
        }
        field(10; "Item Selection"; Option)
        {
            Caption = 'Item Selection';
            OptionCaption = 'All Items,Specific Item,Item Category,Manufacturer,Vendor No.,Plan Group';
            OptionMembers = "All Items","Specific Item","Item Category",Manufacturer,"Vendor No.","Accrual Group";
        }
        field(11; "Item Code"; Code[20])
        {
            Caption = 'Item Code';
            TableRelation = IF ("Item Selection" = CONST("Specific Item")) Item
            ELSE
            IF ("Item Selection" = CONST("Item Category")) "Item Category"
            ELSE
            IF ("Item Selection" = CONST(Manufacturer)) Manufacturer
            ELSE
            IF ("Item Selection" = CONST("Vendor No.")) Vendor;
        }
        field(12; "Accrual Plan No."; Code[20])
        {
            Caption = 'Accrual Plan No.';
            TableRelation = "Accrual Plan"."No." WHERE(Type = FIELD("Accrual Plan Type"));
        }
        field(13; "Plan Type"; Option)
        {
            Caption = 'Plan Type';
            OptionCaption = 'Promo/Rebate,Commission,Reporting';
            OptionMembers = "Promo/Rebate",Commission,Reporting;
        }
        field(14; "Item Accrual Group Code"; Code[10])
        {
            Caption = 'Item Accrual Group Code';
            TableRelation = "Accrual Group".Code WHERE(Type = CONST(Item));
        }
        field(15; "Source Accrual Group Code"; Code[10])
        {
            Caption = 'Source Accrual Group Code';
            TableRelation = IF ("Accrual Plan Type" = CONST(Sales)) "Accrual Group".Code WHERE(Type = CONST(Customer))
            ELSE
            IF ("Accrual Plan Type" = CONST(Purchase)) "Accrual Group".Code WHERE(Type = CONST(Vendor));
        }
    }

    keys
    {
        key(Key1; "Accrual Plan Type", "Accrual Plan No.", "Source Code", "Source Ship-to Code", "Item Code")
        {
        }
        key(Key2; "Accrual Plan Type", "Accrual Plan No.", "Item Code", "Source Code", "Source Ship-to Code")
        {
        }
        key(Key3; "Accrual Plan Type", "Computation Level", "Plan Type", "Item Selection", "Item Code", "Source Selection Type", "Source Selection", "Source Code", "Source Ship-to Code", "Date Type", "Start Date", "End Date")
        {
            SQLIndex = "Item Code", "Item Selection", "Source Code", "Source Selection Type", "Source Selection", "Source Ship-to Code", "Plan Type", "Start Date", "End Date";
        }
    }

    fieldgroups
    {
    }
}

