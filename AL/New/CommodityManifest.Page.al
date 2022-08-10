page 37002685 "Commodity Manifest"
{
    // PRW16.00.04
    // P8000891, VerticalSoft, Don Bresee, 04 JAN 11
    //   Add Commodity Receiving logic
    // 
    // PRW18.00
    // P8001359, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add support for ShowMandatory

    Caption = 'Commodity Manifest';
    PageType = Card;
    SourceTable = "Commodity Manifest Header";

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

                    trigger OnAssistEdit()
                    begin
                        if AssistEditNo(xRec) then
                            CurrPage.Update;
                    end;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = LocationCodeMandatory;
                }
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;
                    ShowMandatory = true;
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

                    trigger OnAssistEdit()
                    begin
                        if ("Lot No." = '') then
                            if AssistEditLotNo(xRec) then
                                CurrPage.Update;
                    end;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
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
                    ShowMandatory = true;
                }
                field("Manifest Quantity"; "Manifest Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("GetAdjmtQty()"; GetAdjmtQty())
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
                part(Bins; "Comm. Manifest Dest. Bins")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Bins';
                    SubPageLink = "Commodity Manifest No." = FIELD("No.");
                    SubPageView = SORTING("Commodity Manifest No.", "Bin Code");
                }
                group(DestinationBinsGroup)
                {
                    ShowCaption = false;
                    field("Product Rejected"; "Product Rejected")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Destination Bin Quantity"; "Destination Bin Quantity")
                    {
                        ApplicationArea = FOODBasic;
                        Importance = Promoted;
                    }
                }
            }
            part(Lines; "Comm. Manifest Lines")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lines';
                SubPageLink = "Commodity Manifest No." = FIELD("No.");
                SubPageView = SORTING("Commodity Manifest No.", "Line No.");
            }
        }
        area(factboxes)
        {
            systempart(Control37002022; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control37002021; Notes)
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
            group("P&osting")
            {
                Caption = 'P&osting';
                action("P&ost")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'P&ost';
                    Ellipsis = true;
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    var
                        CommManifestPost: Codeunit "Commodity Manifest-Post";
                    begin
                        TestField("No.");
                        if Confirm(Text000, false, "No.") then begin
                            CommManifestPost.Run(Rec);
                            CurrPage.Update(false);
                        end;
                    end;
                }
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        if Find(Which) then
            exit(true);
        SetRange("No.");
        exit(Find(Which));
    end;

    trigger OnOpenPage()
    begin
        SetLocationCodeMandatory; // P8001359
    end;

    var
        Text000: Label 'Do you want to post Commodity Manifest %1?';
        [InDataSet]
        LocationCodeMandatory: Boolean;

    local procedure SetLocationCodeMandatory()
    var
        InventorySetup: Record "Inventory Setup";
    begin
        // P8001359
        InventorySetup.Get;
        LocationCodeMandatory := InventorySetup."Location Mandatory";
    end;
}

