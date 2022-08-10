page 37002650 "N138 Delivery Trip History"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // TOM4554     27-10-2015  Additional history fields
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
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Delivery Trip History';
    Editable = false;
    PageType = List;
    SourceTable = "N138 Delivery Trip History";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Delivery Route No."; "Delivery Route No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Shipment Date"; "Shipment Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Driver No."; "Driver No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Driver Name"; "Driver Name")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Truck ID"; "Truck ID")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Loading Dock"; "Loading Dock")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Additional;
                }
                field("Shipping Agent Service Code"; "Shipping Agent Service Code")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Additional;
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
            }
            part("Posted Documents"; "Del. Trip History-Posted Docs.")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Posted Documents';
                SubPageLink = "Delivery Trip No." = FIELD("No.");
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Functions)
            {
                Caption = 'Functions';
                action("Transport Costs")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Transport Costs';
                    Image = SalesPrices;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        OpenTransportCost;
                    end;
                }
            }
        }
    }
}

