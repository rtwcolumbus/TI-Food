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
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update;
                    end;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        ItemNoOnAfterValidate;
                    end;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnAssistEdit()
                    begin
                        LotNoAssistEdit;
                    end;
                }
                field(Farm; Farm)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Brand; Brand)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Country/Region of Origin Code"; "Country/Region of Origin Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Search Description"; "Search Description")
                {
                    ApplicationArea = FOODBasic;
                }
                field(PostingDate; "Posting Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Date Required"; "Date Required")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        QuantityOnAfterValidate;
                    end;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity (Alt.)"; "Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity to Produce"; "Quantity to Produce")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity to Produce (Alt.)"; "Quantity to Produce (Alt.)")
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
                field("Destination Location"; "Destination Location")
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = LocationCodeMandatory;
                }
                field("Bin Code"; "Bin Code")
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
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
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
                    Promoted = true;
                    PromotedCategory = Process;

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
                    Promoted = true;
                    PromotedCategory = Process;

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
                    Promoted = true;
                    PromotedCategory = Process;
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
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
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
                    Promoted = true;
                    PromotedCategory = Process;

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
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        PrintLabels;
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        SetLocationCodeMandatory; // P8001359
    end;

    var
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        [InDataSet]
        LocationCodeMandatory: Boolean;

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

