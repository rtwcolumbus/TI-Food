page 37002186 "Sales Contract History"
{
    // PRW16.00.06
    // P8001076, Columbus IT, Jack Reynolds, 14 JUN 12
    //   Remove Item Ledger Entry No. and Cost Amount (Actual) from the page

    Caption = 'Sales Contract History';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Sales Contract History";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Contract No."; "Contract No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Sales Price ID"; "Sales Price ID")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Document Line No."; "Document Line No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Quantity (Contract)"; "Quantity (Contract)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Contract Limit UOM"; "Contract Limit UOM")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Quantity (Contract Line)"; "Quantity (Contract Line)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Contract Line Limit UOM"; "Contract Line Limit UOM")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Sales Quantity"; "Sales Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Sales UOM"; "Sales UOM")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
    }
}

