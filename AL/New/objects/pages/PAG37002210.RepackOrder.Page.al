page 37002210 "Repack Order"
{
    // PR4.00.06
    // P8000496A, VerticalSoft, Jack Reynolds, 24 JUL 07
    //   Standard card style form for open repack orders
    // 
    // PR5.00
    // P8000504A, VerticalSoft, Jack Reynolds, 08 AUG 07
    //   Support for alternate quantities
    // 
    // PRW15.00.03
    // P8000624A, VerticalSoft, Jack Reynolds, 19 AUG 08
    //   Add control for country/region of origin
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 08 NOV 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.05
    // P8000943, Columbus IT, Jack Reynolds, 06 MAY 11
    //   Add Due Date
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW18.00
    // P8001359, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add support for ShowMandatory
    // 
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    //
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 01 JUN 22
    //   Cleanup Role Centers and Navigate (Find Entries)
    // 
    // PRW121.0
    // P800155629, To-Increase, Jack Reynolds, 03 NOV 22
    //   Add support for Mandatory Variant

    Caption = 'Repack Order';
    PageType = Document;
    SourceTable = "Repack Order";
    SourceTableView = WHERE(Status = CONST(Open));

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update;
                    end;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        ItemNoOnAfterValidate;
                        // P800155629
                        if Rec."Variant Code" = '' then
                            VariantCodeMandatory := Rec.IsVariantMandatory();
                        // P800155629
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
                field(Description; Rec.Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnAssistEdit()
                    begin
                        Rec.LotNoAssistEdit;
                    end;
                }
                field(Farm; Rec.Farm)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Brand; Rec.Brand)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Country/Region of Origin Code"; Rec."Country/Region of Origin Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Search Description"; Rec."Search Description")
                {
                    ApplicationArea = FOODBasic;
                }
                field(PostingDate; Rec."Posting Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Date Required"; Rec."Date Required")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        QuantityOnAfterValidate;
                    end;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity (Alt.)"; Rec."Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity to Produce"; Rec."Quantity to Produce")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity to Produce (Alt.)"; Rec."Quantity to Produce (Alt.)")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        // P8000504A
                        CurrPage.SaveRecord;
                        AltQtyMgmt.ShowRepackOrderAltQtyLines(Rec);
                        CurrPage.Update;
                        // P8000504A
                    end;

                    trigger OnValidate()
                    begin
                        QuantitytoProduceAltOnAfterVal;
                    end;
                }
                field("Destination Location"; Rec."Destination Location")
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = LocationCodeMandatory;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            part(RepackLines; "Repack Order Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lines';
                SubPageLink = "Order No." = FIELD("No.");
            }
            group(Posting)
            {
                Caption = 'Posting';
                field(PostingDate2; "Posting Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Repack Location"; "Repack Location")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            part(AllergenFactbox; "Allergen Factbox")
            {
                ApplicationArea = FOODBasic;
                Provider = RepackLines;
                SubPageLink = "Table No. Filter" = CONST(37002211),
                              "Type Filter" = FIELD(Type),
                              "No. Filter" = FIELD("No.");
                Visible = false;
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("O&rder")
            {
                Caption = 'O&rder';
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Repack Order Comment Sheet";
                    RunPageLink = "Repack Order No." = FIELD("No.");
                }
                action(Dimensions)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Dimensions';
                    Image = Dimensions;

                    trigger OnAction()
                    begin
                        ShowDocDim;
                    end;
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("Calculate Lines")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Calculate Lines';
                    Image = CalculateLines;

                    trigger OnAction()
                    begin
                        CalculateLines;
                    end;
                }
                action("Finish Order")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Finish Order';
                    Image = Stop;

                    trigger OnAction()
                    begin
                        FinishOrder;
                        CurrPage.Update(false);
                    end;
                }
                separator(Separator37002058)
                {
                }
                action(Navigate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Find entries...'; // P800144605
                    Image = Navigate;
                    ShortCutKey = 'Ctrl+Alt+Q'; // P800144605

                    trigger OnAction()
                    begin
                        Navigate;
                    end;
                }
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                action("P&ost")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'P&ost';
                    Ellipsis = true;
                    Image = Post;
                    RunObject = Codeunit "Repack-Post (Yes/No)";
                    ShortCutKey = 'F9';
                }
            }
            group("&Print")
            {
                Caption = '&Print';
                action("Order")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Order';
                    Ellipsis = true;
                    Image = "Order";

                    trigger OnAction()
                    var
                        DocPrint: Codeunit "Document-Print";
                    begin
                        DocPrint.PrintRepackOrder(Rec);
                    end;
                }
                action(Labels)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Labels';
                    Ellipsis = true;
                    Image = Text;

                    trigger OnAction()
                    begin
                        PrintLabels;
                    end;
                }
            }
        }
        area(Promoted)
        {
            actionref(Post_Promoted; "P&ost")
            {
            }
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(CalculateLines_Promoted; "Calculate Lines")
                {
                }
                actionref(FinishOrder_Promoted; "Finish Order")
                {
                }
                actionref(Navigate_Promoted; Navigate)
                {
                }
                actionref(Order_Promoted; Order)
                {
                }
                actionref(Labels_Promoted; Labels)
                {
                }
            }
        }
    }

    // P800155629
    trigger OnAfterGetRecord()
    begin
        if Rec."Variant Code" = '' then
            VariantCodeMandatory := Rec.IsVariantMandatory();
    end;

    trigger OnOpenPage()
    begin
        SetLocationCodeMandatory; // P8001359
    end;

    var
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        [InDataSet]
        LocationCodeMandatory: Boolean;
        VariantCodeMandatory: Boolean;

    local procedure ItemNoOnAfterValidate()
    begin
        CurrPage.Update;
    end;

    local procedure QuantitytoProduceAltOnAfterVal()
    begin
        // P8000504A
        CurrPage.SaveRecord;
        AltQtyMgmt.ValidateRepackOrderAltQtyLine(Rec);
        CurrPage.Update;
        // P8000504A
    end;

    local procedure QuantityOnAfterValidate()
    begin
        CurrPage.Update;
    end;

    local procedure SetLocationCodeMandatory()
    var
        InventorySetup: Record "Inventory Setup";
    begin
        // P8001359
        InventorySetup.Get;
        LocationCodeMandatory := InventorySetup."Location Mandatory";
    end;
}

