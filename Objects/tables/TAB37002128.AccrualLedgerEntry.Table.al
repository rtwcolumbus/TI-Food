table 37002128 "Accrual Ledger Entry"
{
    // PR3.61AC
    // 
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PRW16.00
    // P8000639, VerticalSoft, Jack Reynolds, 18 NOV 08
    //   Add DropDown field group
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW17.00.01
    // P8001154, Columbus IT, Jack Reynolds, 28 MAY 13
    //   Enlarge User ID field
    // 
    // PRW110.0.02
    // P80048075, To-Increase, Dayakar Battini, 31 OCT 17
    //   "External Document No." field length from Code20 to Code35
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Accrual Ledger Entry';
    DrillDownPageID = "Accrual Ledger Entries";
    LookupPageID = "Accrual Ledger Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Accrual Plan Type"; Option)
        {
            Caption = 'Accrual Plan Type';
            OptionCaption = 'Sales,Purchase';
            OptionMembers = Sales,Purchase;
        }
        field(3; "Accrual Plan No."; Code[20])
        {
            Caption = 'Accrual Plan No.';
            TableRelation = "Accrual Plan"."No." WHERE(Type = FIELD("Accrual Plan Type"));
        }
        field(4; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'Accrual,Payment';
            OptionMembers = Accrual,Payment;
        }
        field(5; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            TableRelation = IF ("Accrual Plan Type" = CONST(Sales)) Customer
            ELSE
            IF ("Accrual Plan Type" = CONST(Purchase)) Vendor;
        }
        field(6; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Customer,Vendor,G/L Account';
            OptionMembers = Customer,Vendor,"G/L Account";
        }
        field(7; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type = CONST(Customer)) Customer
            ELSE
            IF (Type = CONST(Vendor)) Vendor
            ELSE
            IF (Type = CONST("G/L Account"),
                                     "Entry Type" = CONST(Payment)) "G/L Account";
        }
        field(8; "Source Document Type"; Option)
        {
            Caption = 'Source Document Type';
            OptionCaption = 'None,Shipment,Receipt,Invoice,Credit Memo';
            OptionMembers = "None",Shipment,Receipt,Invoice,"Credit Memo";
        }
        field(9; "Source Document No."; Code[20])
        {
            Caption = 'Source Document No.';

            trigger OnLookup()
            begin
                TestField("Source No.");
                if ("Source Document Type" = "Source Document Type"::None) then
                    FieldError("Source Document Type");
                TempText := "Source Document No.";
                AccrualFldMgmt.LookupSourceDoc(
                  "Accrual Plan Type", "Accrual Plan No.", "Source No.",
                  "Source Document Type", TempText);
            end;
        }
        field(10; "Source Document Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Source Document Line No.';

            trigger OnLookup()
            begin
                TestField("Source No.");
                if ("Source Document Type" = "Source Document Type"::None) then
                    FieldError("Source Document Type");
                TestField("Source Document No.");
                TempText := Format("Source Document Line No.");
                AccrualFldMgmt.LookupSourceDocLine(
                  "Accrual Plan Type", "Accrual Plan No.", "Source No.",
                  "Source Document Type", "Source Document No.", TempText);
            end;
        }
        field(11; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Editable = false;
            TableRelation = Item;
        }
        field(12; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
        }
        field(13; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(14; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(15; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(16; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            Editable = false;
            TableRelation = "Source Code";
        }
        field(17; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(18; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(19; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(20; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(21; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(22; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
        }
        field(23; "Accrual Posting Group"; Code[10])
        {
            Caption = 'Accrual Posting Group';
            TableRelation = "Accrual Posting Group";
        }
        field(24; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(25; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;

            trigger OnLookup()
            var
                UserSelection: Codeunit "User Selection";
                User: Record User;
            begin
                // P800-MegaApp
                if UserSelection.Open(User) then
                    "User ID" := User."User Name";
            end;
        }
        field(26; "Plan Type"; Option)
        {
            Caption = 'Plan Type';
            OptionCaption = 'Promo/Rebate,Commission,Reporting';
            OptionMembers = "Promo/Rebate",Commission,Reporting;
        }
        field(27; "Price Impact"; Option)
        {
            Caption = 'Price Impact';
            OptionCaption = 'None,Exclude from Price,Include in Price';
            OptionMembers = "None","Exclude from Price","Include in Price";
        }
        field(28; "Scheduled Accrual No."; Code[10])
        {
            Caption = 'Scheduled Accrual No.';

            trigger OnLookup()
            begin
                AccrualSchdLine.ShowSchedule(
                  "Accrual Plan Type", "Accrual Plan No.", "Entry Type",
                  "Scheduled Accrual No.", false);
            end;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                // P8001133
                ShowDimensions;
            end;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Accrual Plan Type", "Accrual Plan No.", "Posting Date")
        {
        }
        key(Key3; "Accrual Plan Type", "Accrual Plan No.", "Entry Type", "Source No.", Type, "No.", "Source Document Type", "Source Document No.", "Source Document Line No.", "Item No.", "Posting Date")
        {
            SumIndexFields = Amount;
        }
        key(Key4; "Accrual Plan Type", "Source Document Type", "Plan Type", "Entry Type", "Source Document No.", "Source Document Line No.", Type, "No.")
        {
            SumIndexFields = Amount;
        }
        key(Key5; "Accrual Plan Type", "Entry Type", "Price Impact", "Plan Type", "Source Document Type", "Source Document No.", "Source Document Line No.")
        {
            SumIndexFields = Amount;
        }
        key(Key6; "Document No.", "Posting Date")
        {
        }
        key(Key7; "Accrual Plan Type", "Accrual Plan No.", "Entry Type", "Source No.", Type, "No.", "Posting Date", "Source Document Type", "Source Document No.", "Source Document Line No.", "Item No.")
        {
        }
        key(Key8; "Accrual Plan Type", "Accrual Plan No.", "Source No.", "Entry Type", Type, "No.", "Item No.", "Posting Date")
        {
            SumIndexFields = Amount;
        }
        key(Key9; "Accrual Plan Type", "Accrual Plan No.", "Entry Type", "Scheduled Accrual No.", Type, "No.", "Posting Date")
        {
            SumIndexFields = Amount;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Entry No.", Description, "Accrual Plan Type", "Accrual Plan No.", "Posting Date", "Entry Type", "Document No.")
        {
        }
    }

    var
        TempText: Text[1024];
        AccrualSchdLine: Record "Accrual Plan Schedule Line";
        AccrualFldMgmt: Codeunit "Accrual Field Management";

    procedure ShowDimensions()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        // P8001133
        DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo('%1 %2', TableCaption, "Entry No."));
    end;
}

