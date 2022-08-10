page 37002451 "N138 Delivery Trip List"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 09-10-2014, Initial Version
    // --------------------------------------------------------------------------------
    // 
    // PRW18.00.01
    // P8001379, Columbus IT, Jack Reynolds, 31 MAR 15
    //   Add FOOD fields
    // 
    // PRW19.00.01
    // P8006916, To-Increase, Jack Reynolds, 31 AUG 16
    //   FOOD-TOM Separation
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Delivery Trips';
    CardPageID = "N138 Delivery Trip";
    PageType = List;
    SourceTable = "N138 Delivery Trip";
    UsageCategory = Lists;

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
                field("Delivery Route No."; "Delivery Route No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Shipping Agent Service Code"; "Shipping Agent Service Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Departure Date"; "Departure Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Departure Time"; "Departure Time")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Truck ID"; "Truck ID")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Driver No."; "Driver No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Driver Name"; "Driver Name")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            part(Control11; "N138 Delivery Trip Factbox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("No.");
            }
        }
    }

    actions
    {
    }
}

