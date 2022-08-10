page 37002694 "Commodity Purch. Order Subpage"
{
    // PRW16.00.04
    // P8000902, Columbus IT, Don Bresee, 14 MAR 11
    //   Add Commodity Payment logic

    AutoSplitKey = true;
    Caption = 'Commodity Purch. Order Subpage';
    PageType = ListPart;
    SourceTable = "Purchase Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                }
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field("Producer Zone Code"; "Producer Zone Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Commodity Received Lot No."; "Commodity Received Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Commodity Received Date"; "Commodity Received Date")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Comm. Payment Class Code"; "Comm. Payment Class Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Commodity Cost Calculated"; "Commodity Cost Calculated")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Commodity Unit Cost"; "Commodity Unit Cost")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Commodity Amount"; "Commodity Amount")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Commodity Rejected"; "Commodity Rejected")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Rejection Action"; "Rejection Action")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Direct Unit Cost"; "Direct Unit Cost")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Line Amount"; "Line Amount")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Qty. to Invoice"; "Qty. to Invoice")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity Invoiced"; "Quantity Invoiced")
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

