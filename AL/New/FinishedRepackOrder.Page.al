page 37002215 "Finished Repack Order"
{
    // PR4.00.06
    // P8000496A, VerticalSoft, Jack Reynolds, 24 JUL 07
    //   Standard card style subform for finished repack orders
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
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013

    Caption = 'Finished Repack Order';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Document;
    SourceTable = "Repack Order";
    SourceTableView = WHERE(Status = CONST(Finished));

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
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;

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
                field("Quantity Produced"; "Quantity Produced")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity Produced (Alt.)"; "Quantity Produced (Alt.)")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        AltQtyMgmt.ShowRepackOrderAltQtyEntries(Rec); // P8000504A
                    end;
                }
                field("Destination Location"; "Destination Location")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            part(RepackLines; "Finished Repack Order Subform")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "Order No." = FIELD("No.");
            }
            group(Posting)
            {
                Caption = 'Posting';
                field("Repack Location"; "Repack Location")
                {
                    ApplicationArea = FOODBasic;
                }
                field(PostingDate2; "Posting Date")
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

    var
        AltQtyMgmt: Codeunit "Alt. Qty. Management";

    local procedure ItemNoOnAfterValidate()
    begin
        CurrPage.Update;
    end;

    local procedure QuantityOnAfterValidate()
    begin
        CurrPage.Update;
    end;
}

