table 37002669 "Lot Settlement Report"
{
    // PR4.00.06
    // P8000496A, VerticalSoft, Jack Reynolds, 24 JUL 07
    //   Add Repack as option to Entry Type field
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 09 AUG 07
    //   Expand result of CustomerName function to 50 characters
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Lot Settlement Report';
    ReplicateData = false;

    fields
    {
        field(1; "Report No."; Integer)
        {
            Caption = 'Report No.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'Sales,Writeoff Company,Writeoff Vendor,Repack';
            OptionMembers = Sales,"Writeoff Company","Writeoff Vendor",Repack;
        }
        field(4; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(6; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
        }
        field(7; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
        field(8; "Unit Price"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Unit Price';
        }
        field(9; "Extended Price"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Extended Price';
        }
        field(10; "Includes Expected Cost"; Boolean)
        {
            Caption = 'Includes Expected Cost';
        }
    }

    keys
    {
        key(Key1; "Report No.", "Line No.")
        {
        }
        key(Key2; "Entry Type", "Unit Price", "Posting Date", "Document No.")
        {
        }
        key(Key3; "Entry Type", "Posting Date", "Document No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure CustomerName(): Text[100]
    var
        Customer: Record Customer;
    begin
        // P8000466A - expand result to TEXT50
        if Customer.Get("Customer No.") then
            exit(Customer.Name);
    end;
}

