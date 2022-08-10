table 37002055 "Sales Contract History"
{
    // PRW16.00.06
    // P8001076, Columbus IT, Jack Reynolds, 13 JUN 12
    //   Item Ledger Entry No. field removed
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW110.0.01
    // P80042410, To-Increase, Dayakar Battini, 05 JUL 17
    //   Fix for contract line limit functionality.

    Caption = 'Sales Contract History';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "Sales Contract";
        }
        field(3; "Sales Price ID"; Integer)
        {
            Caption = 'Sales Price ID';
        }
        field(4; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Sales Shipment,Sales Invoice,Sales Return Receipt,Sales Credit Memo';
            OptionMembers = "Sales Shipment","Sales Invoice","Sales Return Receipt","Sales Credit Memo";
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(6; "Quantity (Contract)"; Decimal)
        {
            Caption = 'Quantity (Contract)';
            DecimalPlaces = 0 : 5;
        }
        field(7; "Unit Price"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price';
        }
        field(8; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(9; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(10; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(13; "Quantity (Contract Line)"; Decimal)
        {
            Caption = 'Quantity (Contract Line)';
            DecimalPlaces = 0 : 5;
        }
        field(14; "Item Type"; Option)
        {
            Caption = 'Item Type';
            OptionCaption = 'Item,Item Category,,,All Items';
            OptionMembers = Item,"Item Category",,,"All Items";
        }
        field(15; "Item Code"; Code[20])
        {
            Caption = 'Item Code';
            TableRelation = IF ("Item Type" = CONST(Item)) Item
            ELSE
            IF ("Item Type" = CONST("Item Category")) "Item Category";
        }
        field(17; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(18; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
        }
        field(19; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(20; "Contract Limit UOM"; Code[10])
        {
            Caption = 'Contract Limit UOM';
            TableRelation = "Unit of Measure";
        }
        field(21; "Contract Line Limit UOM"; Code[10])
        {
            Caption = 'Contract Line Limit UOM';
            TableRelation = "Unit of Measure";
        }
        field(22; "Sales UOM"; Code[10])
        {
            Caption = 'Sales UOM';
            TableRelation = "Unit of Measure";
        }
        field(23; "Sales Quantity"; Decimal)
        {
            Caption = 'Sales Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(24; "Price ID"; Integer)
        {
            Caption = 'Price ID';
        }
        field(28; "Limit Type"; Option)
        {
            Caption = 'Limit Type';
            Description = 'P80042410';
            OptionCaption = ' ,per Order';
            OptionMembers = " ","per Order";
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Contract No.", "Item Type", "Item Code")
        {
            SumIndexFields = "Quantity (Contract)", "Quantity (Contract Line)";
        }
        key(Key3; "Contract No.")
        {
            SumIndexFields = "Quantity (Contract)";
        }
    }

    fieldgroups
    {
    }
}

