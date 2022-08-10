table 37002132 "Accrual Posting Buffer"
{
    // PR3.61AC
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Don Bresee, 12 JUN 07
    //   Copied CopyJnlLineDimToDimBuf routine from Version 4.00 - Codeunit 408 (used by Payroll granule in 4.00)
    // 
    // PRW16.00.04
    // P8000852, VerticalSoft, Jack Reynolds, 05 AUG 10
    //   Fix problem wih records accumulating in Dimension Buffer table
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW110.0.01
    // P8008663, To-Increase, Jack Reynolds 21 APR 17
    //   Payments in foreign currencies
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Accrual Posting Buffer';
    ReplicateData = false;

    fields
    {
        field(1; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            ClosingDates = true;
            DataClassification = SystemMetadata;
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = SystemMetadata;
        }
        field(3; "Accrual Plan Type"; Option)
        {
            Caption = 'Accrual Plan Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'Sales,Purchase';
            OptionMembers = Sales,Purchase;
        }
        field(4; "Accrual Plan No."; Code[20])
        {
            Caption = 'Accrual Plan No.';
            DataClassification = SystemMetadata;
            TableRelation = "Accrual Plan"."No." WHERE(Type = FIELD("Accrual Plan Type"));
        }
        field(5; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'Accrual,Payment';
            OptionMembers = Accrual,Payment;
        }
        field(6; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            DataClassification = SystemMetadata;
            TableRelation = IF ("Accrual Plan Type" = CONST(Sales)) Customer
            ELSE
            IF ("Accrual Plan Type" = CONST(Purchase)) Vendor;
        }
        field(7; "Source Document Type"; Option)
        {
            Caption = 'Source Document Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'None,Shipment,Receipt,Invoice,Credit Memo';
            OptionMembers = "None",Shipment,Receipt,Invoice,"Credit Memo";
        }
        field(8; "Source Document No."; Code[20])
        {
            Caption = 'Source Document No.';
            DataClassification = SystemMetadata;
        }
        field(9; "Source Document Line No."; Integer)
        {
            Caption = 'Source Document Line No.';
            DataClassification = SystemMetadata;
        }
        field(10; Type; Option)
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'Customer,Vendor,G/L Account';
            OptionMembers = Customer,Vendor,"G/L Account";
        }
        field(11; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = SystemMetadata;
            TableRelation = IF (Type = CONST(Customer)) Customer
            ELSE
            IF (Type = CONST(Vendor)) Vendor
            ELSE
            IF (Type = CONST("G/L Account")) "G/L Account";
        }
        field(12; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = SystemMetadata;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(13; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = SystemMetadata;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(14; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
            DataClassification = SystemMetadata;
        }
        field(15; "Dimension Entry No."; Integer)
        {
            Caption = 'Dimension Entry No.';
            DataClassification = SystemMetadata;
        }
        field(16; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Source Code";
        }
        field(17; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            DataClassification = SystemMetadata;
            TableRelation = "Reason Code";
        }
        field(18; "External Document No."; Code[20])
        {
            Caption = 'External Document No.';
            DataClassification = SystemMetadata;
        }
        field(19; "Due Date"; Date)
        {
            Caption = 'Due Date';
            DataClassification = SystemMetadata;
        }
        field(20; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = Currency;
        }
        field(21; "Amount (FCY)"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount (FCY)';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Posting Date", "Document No.", "Accrual Plan Type", "Accrual Plan No.", "Source No.", "Source Document Type", "Source Document No.", "Source Document Line No.", "Entry Type", Type, "No.", "Currency Code", "External Document No.", "Dimension Entry No.", "Source Code", "Reason Code")
        {
            SumIndexFields = Amount;
        }
    }

    fieldgroups
    {
    }
}

