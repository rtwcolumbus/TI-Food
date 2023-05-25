page 37002169 "SKU/Item Planning FactBox"
{
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013

    Caption = 'SKU/Item Details - Planning';
    PageType = CardPart;
    SourceTable = Item;

    layout
    {
        area(content)
        {
            field("SKU.""Item No."""; SKU."Item No.")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Item No.';

                trigger OnDrillDown()
                begin
                    ShowDetails;
                end;
            }
            field("SKU.""Variant Code"""; SKU."Variant Code")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Variant Code';
            }
            field("SKU.""Location Code"""; SKU."Location Code")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Location Code';
            }
            field("Reordering Policy"; "Reordering Policy")
            {
                ApplicationArea = FOODBasic;
            }
            field("Reorder Point"; "Reorder Point")
            {
                ApplicationArea = FOODBasic;
            }
            field("Reorder Quantity"; "Reorder Quantity")
            {
                ApplicationArea = FOODBasic;
            }
            field("Maximum Inventory"; "Maximum Inventory")
            {
                ApplicationArea = FOODBasic;
            }
            field("Overflow Level"; "Overflow Level")
            {
                ApplicationArea = FOODBasic;
            }
            field("Time Bucket"; "Time Bucket")
            {
                ApplicationArea = FOODBasic;
            }
            field("Lot Accumulation Period"; "Lot Accumulation Period")
            {
                ApplicationArea = FOODBasic;
            }
            field("Rescheduling Period"; "Rescheduling Period")
            {
                ApplicationArea = FOODBasic;
            }
            field("Safety Lead Time"; "Safety Lead Time")
            {
                ApplicationArea = FOODBasic;
            }
            field("Safety Stock Quantity"; "Safety Stock Quantity")
            {
                ApplicationArea = FOODBasic;
            }
            field("Minimum Order Quantity"; "Minimum Order Quantity")
            {
                ApplicationArea = FOODBasic;
            }
            field("Maximum Order Quantity"; "Maximum Order Quantity")
            {
                ApplicationArea = FOODBasic;
            }
            field("Order Multiple"; "Order Multiple")
            {
                ApplicationArea = FOODBasic;
            }
            field("Dampener Period"; "Dampener Period")
            {
                ApplicationArea = FOODBasic;
            }
            field("Dampener Quantity"; "Dampener Quantity")
            {
                ApplicationArea = FOODBasic;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        FilterGroup(4);
        SKU."Item No." := "No.";
        SKU."Variant Code" := GetRangeMax("Variant Filter");
        SKU."Location Code" := GetRangeMax("Location Filter");
        FilterGroup(0);
        GetPlanningParameter.AtSKU(SKU, SKU."Item No.", SKU."Variant Code", SKU."Location Code");

        "Reordering Policy" := SKU."Reordering Policy";
        //"Reorder Cycle" := SKU."Reorder Cycle"; // P8001132
        "Safety Lead Time" := SKU."Safety Lead Time";
        "Safety Stock Quantity" := SKU."Safety Stock Quantity";
        "Reorder Point" := SKU."Reorder Point";
        "Reorder Quantity" := SKU."Reorder Quantity";
        "Maximum Inventory" := SKU."Maximum Inventory";
        "Minimum Order Quantity" := SKU."Minimum Order Quantity";
        "Maximum Order Quantity" := SKU."Maximum Order Quantity";
        "Order Multiple" := SKU."Order Multiple";
        // P8001132
        "Overflow Level" := SKU."Overflow Level";
        "Time Bucket" := SKU."Time Bucket";
        "Lot Accumulation Period" := SKU."Lot Accumulation Period";
        "Rescheduling Period" := SKU."Rescheduling Period";
        "Dampener Period" := SKU."Dampener Period";
        "Dampener Quantity" := SKU."Dampener Quantity";
        // P8001132
    end;

    var
        SKU: Record "Stockkeeping Unit";
        GetPlanningParameter: Codeunit "Planning-Get Parameters";

    procedure ShowDetails()
    var
        Item: Record Item;
    begin
        if SKU.Find then
            PAGE.Run(PAGE::"Stockkeeping Unit Card", SKU)
        else begin
            Item.Get("No.");
            PAGE.Run(PAGE::"Item Card", Item);
        end;
    end;
}

