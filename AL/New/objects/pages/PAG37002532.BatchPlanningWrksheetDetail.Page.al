page 37002532 "Batch Planning Wrksheet Detail"
{
    // PRW16.00.04
    // P8000877, Columbus IT, Jack Reynolds, 02 MAR 11
    //   List page to display batch planning demand detail
    // 
    // PRW120-.2
    // P800150458, To-Increase, Jack Reynolds, 11 AUG 22
    //   Transfer Orders for Batch Plannng demand
    //   Minor cleanup to Batch Planning objcts

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
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Order Type"; Rec."Order Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(OrderSourceName; Rec.OrderSourceName()) // P800150458
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Order Source';
                }
                field("Quantity Required"; Rec."Quantity Required")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity Planned"; Rec."Quantity Planned")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity Remaining"; Rec."Quantity Remaining")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Date Required"; Rec."Date Required")
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
                    TransferHeader: Record "Transfer Header";
                    ProdOrder: Record "Production Order";
                begin
                    case Rec."Order Source" of
                        DATABASE::"Sales Line":
                            begin
                                SalesOrder.Get(Rec."Order Source Subtype", Rec."Order No.");
                                PAGE.Run(PAGE::"Sales Order", SalesOrder);
                            end;
                        // P800150458
                        DATABASE::"Transfer Line":
                            begin
                                TransferHeader.Get(Rec."Order No.");
                                PAGE.Run(PAGE::"Transfer Order", TransferHeader);
                            end;
                        // P800150458
                        DATABASE::"Prod. Order Line":
                            begin
                                ProdOrder.Get(Rec."Order Source Subtype", Rec."Order No.");
                                PAGE.Run(PAGE::"Planned Production Order", ProdOrder);
                            end;
                    end;
                end;
            }
        }
    }
}

