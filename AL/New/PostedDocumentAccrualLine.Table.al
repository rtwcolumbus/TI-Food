table 37002136 "Posted Document Accrual Line"
{
    // PR3.61AC
    // 
    // PRW16.00.01
    // P8000694, VerticalSoft, Jack Reynolds, 04 MAY 09
    //   Change name of Accrual fields
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Posted Document Accrual Line';

    fields
    {
        field(4; "Accrual Plan Type"; Option)
        {
            Caption = 'Accrual Plan Type';
            OptionCaption = 'Sales,Purchase';
            OptionMembers = Sales,Purchase;
        }
        field(5; "Accrual Plan No."; Code[20])
        {
            Caption = 'Accrual Plan No.';
            TableRelation = "Accrual Plan"."No." WHERE(Type = FIELD("Accrual Plan Type"));
        }
        field(6; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'Accrual,Payment';
            OptionMembers = Accrual,Payment;
        }
        field(7; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Editable = false;
            TableRelation = Item;
        }
        field(8; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            TableRelation = IF ("Accrual Plan Type" = CONST(Sales)) Customer
            ELSE
            IF ("Accrual Plan Type" = CONST(Purchase)) Vendor;
        }
        field(9; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Customer,Vendor,G/L Account';
            OptionMembers = Customer,Vendor,"G/L Account";
        }
        field(10; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type = CONST(Customer)) Customer
            ELSE
            IF (Type = CONST(Vendor)) Vendor
            ELSE
            IF (Type = CONST("G/L Account"),
                                     "Entry Type" = CONST(Payment)) "G/L Account";
        }
        field(11; "Source Document Type"; Option)
        {
            Caption = 'Source Document Type';
            OptionCaption = 'None,Shipment,Receipt,Invoice,Credit Memo';
            OptionMembers = "None",Shipment,Receipt,Invoice,"Credit Memo";
        }
        field(12; "Source Document No."; Code[20])
        {
            Caption = 'Source Document No.';
        }
        field(13; "Source Document Line No."; Integer)
        {
            Caption = 'Source Document Line No.';
        }
        field(14; "Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount (LCY)';
        }
        field(15; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(16; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(17; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(18; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            Editable = false;
            TableRelation = "Source Code";
        }
        field(19; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(20; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(21; "External Document No."; Code[20])
        {
            Caption = 'External Document No.';
        }
        field(22; "Posting No. Series"; Code[20])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";
        }
        field(23; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(24; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(25; "Recurring Method"; Option)
        {
            BlankZero = true;
            Caption = 'Recurring Method';
            OptionCaption = ',Fixed,Variable';
            OptionMembers = ,"Fixed",Variable;
        }
        field(26; "Recurring Frequency"; DateFormula)
        {
            Caption = 'Recurring Frequency';
        }
        field(27; "Accrual Posting Group"; Code[20])
        {
            Caption = 'Accrual Posting Group';
            TableRelation = "Accrual Posting Group";
        }
        field(28; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
        }
        field(29; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
        }
        field(30; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
    }

    keys
    {
        key(Key1; "Accrual Plan Type", "Source Document Type", "Source Document No.", "Source Document Line No.", "Accrual Plan No.", Type, "No.")
        {
        }
    }

    fieldgroups
    {
    }
}

