page 37002685 "Commodity Manifest"
{
    // PRW16.00.04
    // P8000891, VerticalSoft, Don Bresee, 04 JAN 11
    //   Add Commodity Receiving logic
    // 
    // PRW18.00
    // P8001359, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add support for ShowMandatory
    // 
    // PRW121.0
    // P800155629, To-Increase, Jack Reynolds, 03 NOV 22
    //   Add support for Mandatory Variant

    Caption = 'Commodity Manifest';
    PageType = Card;
    SourceTable = "Commodity Manifest Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEditNo(xRec) then
                            CurrPage.Update;
                    end;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = LocationCodeMandatory;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;
                    ShowMandatory = true;

                    // P800155629
                    trigger OnValidate()
                    begin
                        if Rec."Variant Code" = '' then
                            VariantCodeMandatory := Rec.IsVariantMandatory();
                    end;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = VariantCodeMandatory;

                    // P800155629
                    trigger OnValidate()
                    begin
                        if Rec."Variant Code" = '' then
                            VariantCodeMandatory := Rec.IsVariantMandatory();
                    end;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnAssistEdit()
                    begin
                        if (Rec."Lot No." = '') then
                            if Rec.AssistEditLotNo(xRec) then
                                CurrPage.Update;
                    end;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Loaded Scale Quantity"; Rec."Loaded Scale Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Empty Scale Quantity"; Rec."Empty Scale Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Received Quantity"; Rec."Received Quantity")
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = true;
                }
                field("Manifest Quantity"; Rec."Manifest Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("GetAdjmtQty()"; Rec.GetAdjmtQty())
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Adjustment Quantity';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                }
                field("Broker No."; Rec."Broker No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Hauler No."; Rec."Hauler No.")
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
                    field("Product Rejected"; Rec."Product Rejected")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Destination Bin Quantity"; Rec."Destination Bin Quantity")
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
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    var
                        CommManifestPost: Codeunit "Commodity Manifest-Post";
                    begin
                        Rec.TestField("No.");
                        if Confirm(Text000, false, Rec."No.") then begin
                            CommManifestPost.Run(Rec);
                            CurrPage.Update(false);
                        end;
                    end;
                }
            }
        }
        area(Promoted)
        {
            actionref(Post_Promoted; "P&ost")
            {
            }
        }
    }

    // P800155629
    trigger OnAfterGetRecord()
    var
        Item: Record "Item";
    begin
        if Rec."Variant Code" = '' then
            VariantCodeMandatory := Rec.IsVariantMandatory();
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        if Rec.Find(Which) then
            exit(true);
        Rec.SetRange("No.");
        exit(Rec.Find(Which));
    end;

    trigger OnOpenPage()
    begin
        SetLocationCodeMandatory; // P8001359
    end;

    var
        Text000: Label 'Do you want to post Commodity Manifest %1?';
        [InDataSet]
        LocationCodeMandatory: Boolean;
        VariantCodeMandatory: Boolean;

    local procedure SetLocationCodeMandatory()
    var
        InventorySetup: Record "Inventory Setup";
    begin
        // P8001359
        InventorySetup.Get;
        LocationCodeMandatory := InventorySetup."Location Mandatory";
    end;
}

