page 37002468 "Production Order Xref"
{
    // PR1.00, Myers Nissi, Jack Reynolds, 26 MAY 00, PR003
    //   Tabular style form to display Sales/Production Order Xref
    // 
    // PR3.10
    //   Finished Production orders no longer in separate table
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 02 FEB 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Production Order Xref';
    PageType = List;
    SourceTable = "Production Order XRef";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                Editable = false;
                ShowCaption = false;
                field("Prod. Order Status"; "Prod. Order Status")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Prod. Order No."; "Prod. Order No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Prod. Order Line No."; "Prod. Order Line No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity (Base)"; "Quantity (Base)")
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
            group("Pro&d. Order")
            {
                Caption = 'Pro&d. Order';
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;
                    ShortCutKey = 'Shift+F7';

                    trigger OnAction()
                    var
                        ProdOrder: Record "Production Order";
                    begin
                        ProdOrder.Get("Prod. Order Status", "Prod. Order No.");
                        case "Prod. Order Status" of
                            "Prod. Order Status"::Simulated:
                                PAGE.Run(PAGE::"Simulated Production Order", ProdOrder);
                            "Prod. Order Status"::Planned:
                                PAGE.Run(PAGE::"Planned Production Order", ProdOrder);
                            "Prod. Order Status"::"Firm Planned":
                                PAGE.Run(PAGE::"Firm Planned Prod. Order", ProdOrder);
                            "Prod. Order Status"::Released:
                                PAGE.Run(PAGE::"Released Production Order", ProdOrder);
                            "Prod. Order Status"::Finished:                          // PR3.10
                                PAGE.Run(PAGE::"Finished Production Order", ProdOrder); // PR3.10
                        end;
                    end;
                }
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;

                    trigger OnAction()
                    var
                        ProdOrderComment: Record "Prod. Order Comment Line";
                    begin
                        ProdOrderComment.SetRange(Status, "Prod. Order Status");
                        ProdOrderComment.SetRange("Prod. Order No.", "Prod. Order No.");
                        PAGE.Run(PAGE::"Prod. Order Comment Sheet", ProdOrderComment);
                    end;
                }
                separator(Separator1102603015)
                {
                }
                action(Statistics)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'F7';

                    trigger OnAction()
                    var
                        ProdOrder: Record "Production Order";
                    begin
                        ProdOrder.SetRange(Status, "Prod. Order Status");
                        ProdOrder.SetRange("No.", "Prod. Order No.");
                        PAGE.Run(PAGE::"Production Order Statistics", ProdOrder);
                    end;
                }
            }
        }
    }
}

