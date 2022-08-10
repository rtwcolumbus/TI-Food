table 37002081 "Alternate Quantity Entry"
{
    // PR3.10
    //   Add Table for posted alternate quantities
    // 
    // PR5.00
    // P8000504A, VerticalSoft, Jack Reynolds, 08 AUG 07
    //   Support for alternate quantities on repack orders
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Alternate Quantity Entry';
    DrillDownPageID = "Alternate Quantity Entries";
    LookupPageID = "Alternate Quantity Entries";

    fields
    {
        field(2; "Table No."; Integer)
        {
            BlankZero = true;
            Caption = 'Table No.';
            Editable = false;
        }
        field(4; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
        }
        field(7; "Source Line No."; Integer)
        {
            Caption = 'Source Line No.';
            Editable = false;
        }
        field(8; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(9; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
        }
        field(10; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
        }
        field(12; "Quantity (Base)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(13; "Quantity (Alt.)"; Decimal)
        {
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,3,0,%1,%2,%3', "Table No.", "Document No.", "Source Line No.");
            Caption = 'Quantity (Alt.)';
            DecimalPlaces = 0 : 5;
        }
        field(14; "Invoiced Qty. (Base)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Invoiced Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(15; "Invoiced Qty. (Alt.)"; Decimal)
        {
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,3,6,%1,%2,%3', "Table No.", "Document No.", "Source Line No.");
            Caption = 'Invoiced Qty. (Alt.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(16; "Field No."; Integer)
        {
            Caption = 'Field No.';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Table No.", "Document No.", "Source Line No.", "Line No.")
        {
            SumIndexFields = "Quantity (Base)", "Quantity (Alt.)";
        }
        key(Key2; "Table No.", "Source Line No.")
        {
            SumIndexFields = "Quantity (Base)", "Quantity (Alt.)";
        }
        key(Key3; "Table No.", "Source Line No.", "Lot No.", "Serial No.", "Line No.")
        {
            SumIndexFields = "Quantity (Base)", "Quantity (Alt.)", "Invoiced Qty. (Alt.)";
        }
    }

    fieldgroups
    {
    }
}

