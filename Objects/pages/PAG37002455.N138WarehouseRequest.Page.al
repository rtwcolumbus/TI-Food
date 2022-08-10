page 37002455 "N138 Warehouse Request"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 03-02-2015, Initial Version
    // --------------------------------------------------------------------------------
    // TOM4371     08-10-2015  Add Shipment Date
    // --------------------------------------------------------------------------------
    // 
    // PRW19.00.01
    // P8006916, To-Increase, Dayakar Battini, 16 JUN 16
    //   FOOD-TOM Separation delete Transsmart objects
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // PRW113.00.01
    // P80072959, To-Increase, Jack Reynolds, 09 APR 19
    //   Fix problem with empty page

    Caption = 'Warehouse Request';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = "Warehouse Request";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Source Document"; "Source Document")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Shipment Date"; "Shipment Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Document Status"; "Document Status")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Warehouse Shipment No."; "Warehouse Shipment No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Delivery Trip"; "Delivery Trip")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        // P80072959
                        if Count = 1 then
                            CurrPage.Close
                        else
                            // P80072959
                            CurrPage.Update(true);
                    end;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = EditLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F7';

                    trigger OnAction()
                    var
                        PurchHeader: Record "Purchase Header";
                        SalesHeader: Record "Sales Header";
                        TransHeader: Record "Transfer Header";
                        ProdOrder: Record "Production Order";
                        ServiceHeader: Record "Service Header";
                    begin
                        case "Source Document" of
                            "Source Document"::"Purchase Order":
                                begin
                                    PurchHeader.Get("Source Subtype", "Source No.");
                                    PAGE.Run(PAGE::"Purchase Order", PurchHeader);
                                end;
                            "Source Document"::"Purchase Return Order":
                                begin
                                    PurchHeader.Get("Source Subtype", "Source No.");
                                    PAGE.Run(PAGE::"Purchase Return Order", PurchHeader);
                                end;
                            "Source Document"::"Sales Order":
                                begin
                                    SalesHeader.Get("Source Subtype", "Source No.");
                                    PAGE.Run(PAGE::"Sales Order", SalesHeader);
                                end;
                            "Source Document"::"Sales Return Order":
                                begin
                                    SalesHeader.Get("Source Subtype", "Source No.");
                                    PAGE.Run(PAGE::"Sales Return Order", SalesHeader);
                                end;
                            "Source Document"::"Inbound Transfer", "Source Document"::"Outbound Transfer":
                                begin
                                    TransHeader.Get("Source No.");
                                    PAGE.Run(PAGE::"Transfer Order", TransHeader);
                                end;
                            "Source Document"::"Prod. Consumption", "Source Document"::"Prod. Output":
                                begin
                                    ProdOrder.Get("Source Subtype", "Source No.");
                                    PAGE.Run(PAGE::"Released Production Order", ProdOrder);
                                end;
                            "Source Document"::"Service Order":
                                begin
                                    ServiceHeader.Get("Source Subtype", "Source No.");
                                    PAGE.Run(PAGE::"Service Order", ServiceHeader);
                                end;
                        end;
                    end;
                }
            }
        }
    }
}

