page 37002689 "Posted Commodity Manifest"
{
    // PRW16.00.04
    // P8000891, VerticalSoft, Don Bresee, 04 JAN 11
    //   Add Commodity Receiving logic

    Caption = 'Posted Commodity Manifest';
    Editable = false;
    PageType = Card;
    SourceTable = "Posted Comm. Manifest Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        ShowManifestLotEntries;
                    end;
                }
                field("Commodity Manifest No."; "Commodity Manifest No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;
                }
                field("Loaded Scale Quantity"; "Loaded Scale Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Empty Scale Quantity"; "Empty Scale Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Received Quantity"; "Received Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Manifest Quantity"; "Manifest Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("""Received Quantity"" - ""Manifest Quantity"""; "Received Quantity" - "Manifest Quantity")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Adjustment Quantity';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                }
                field("Broker No."; "Broker No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Hauler No."; "Hauler No.")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(DestinationBins)
            {
                Caption = 'Destination Bins';
                part(Bins; "Pstd. Comm. Manifest Dest.Bins")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Bins';
                    SubPageLink = "Posted Comm. Manifest No." = FIELD("No.");
                    SubPageView = SORTING("Posted Comm. Manifest No.", "Bin Code");
                }
                field("Product Rejected"; "Product Rejected")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            part(Lines; "Posted Comm. Manifest Lines")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lines';
                SubPageLink = "Posted Comm. Manifest No." = FIELD("No.");
                SubPageView = SORTING("Posted Comm. Manifest No.", "Line No.");
            }
        }
        area(factboxes)
        {
            systempart(Control37002023; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control37002022; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = true;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("&Navigate")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Navigate;
                end;
            }
        }
    }
}

