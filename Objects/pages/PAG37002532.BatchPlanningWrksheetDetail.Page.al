page 37002532 "Batch Planning Wrksheet Detail"
{
    // PRW16.00.04
    // P8000877, Columbus IT, Jack Reynolds, 02 MAR 11
    //   List page to display batch planning demand detail

    Caption = 'Batch Planning Worksheet Detail';
    Editable = false;
    PageType = List;
    SourceTable = "Batch Planning Worksheet Line";
    SourceTableView = SORTING("Worksheet Name", "Item No.", "Variant Code", Type, "Date Required");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Order Type"; "Order Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Order No."; "Order No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Customer Name"; "Customer Name")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity Required"; "Quantity Required")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity Planned"; "Quantity Planned")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity Remaining"; "Quantity Remaining")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Date Required"; "Date Required")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Order")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Order';
                Image = "Order";

                trigger OnAction()
                var
                    SalesOrder: Record "Sales Header";
                    ProdOrder: Record "Production Order";
                begin
                    case "Order Source" of
                        DATABASE::"Sales Line":
                            begin
                                SalesOrder.Get("Order Source Subtype", "Order No.");
                                PAGE.Run(PAGE::"Sales Order", SalesOrder);
                            end;
                        DATABASE::"Prod. Order Line":
                            begin
                                ProdOrder.Get("Order Source Subtype", "Order No.");
                                PAGE.Run(PAGE::"Planned Production Order", ProdOrder);
                            end;
                    end;
                end;
            }
        }
    }
}

