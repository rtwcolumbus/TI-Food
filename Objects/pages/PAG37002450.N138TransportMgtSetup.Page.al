page 37002450 "N138 Transport Mgt. Setup"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 09-10-2014, Initial Version
    // --------------------------------------------------------------------------------
    // TOM4220     05-10-2015  Auto creation of warehouse shipment with delivery trip
    // --------------------------------------------------------------------------------
    // 
    // PRW18.0.01
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
    Caption = 'Transport Management Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "N138 Transport Mgt. Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Cost Warning"; "Cost Warning")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Delivery Trip Unit of Weight"; "Delivery Trip Unit of Weight")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Delivery Trip Unit of Volume"; "Delivery Trip Unit of Volume")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Use Container Status Loaded"; "Use Container Status Loaded")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Auto Create Del. Trip Shipment"; "Auto Create Del. Trip Shipment")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Numbering)
            {
                Caption = 'Numbering';
                field("Delivery Trip Nos."; "Delivery Trip Nos.")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;
    end;
}

