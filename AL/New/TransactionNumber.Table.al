table 37002004 "Transaction Number"
{
    // PRW17.10
    // P8001224, Columbus IT, Jack Reynolds, 27 SEP 13
    //   Move Last Alt. Qty. Transaction No. from Inventory Setup

    Caption = 'Transaction Number';
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by number sequence';
    ObsoleteTag = '18.0';

    fields
    {
        field(1; "Transaction No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Transaction No.';
        }
    }

    keys
    {
        key(Key1; "Transaction No.")
        {
        }
    }

    fieldgroups
    {
    }
}

