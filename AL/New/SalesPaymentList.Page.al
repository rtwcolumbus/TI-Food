page 37002711 "Sales Payment List"
{
    // PRW16.00.05
    // P8000941, Columbus IT, Don Bresee, 25 JUL 11
    //   Sales Payments granule
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Sales Payments';
    CardPageID = "Sales Payment Card";
    PageType = List;
    SourceTable = "Sales Payment Header";
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
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Customer Name"; "Customer Name")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                }
                field("Amount Tendered"; "Amount Tendered")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                    Visible = false;
                }
                field("GetBalance(FALSE)"; GetBalance(false))
                {
                    ApplicationArea = FOODBasic;
                    AutoFormatType = 1;
                    Caption = 'Balance';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control37002007; Notes)
            {
                ApplicationArea = FOODBasic;
            }
            systempart(Control37002005; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            separator(Separator37002017)
            {
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
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    var
                        SalesPaymentPost: Codeunit "Sales Payment-Post";
                    begin
                        if Confirm(Text000, false, "No.") then begin
                            SalesPaymentPost.Run(Rec);
                            CurrPage.Update(false);
                        end;
                    end;
                }
                action("Post and &Print")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Post and &Print';
                    Ellipsis = true;
                    Image = PostPrint;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F9';

                    trigger OnAction()
                    var
                        SalesPaymentPost: Codeunit "Sales Payment-Post";
                    begin
                        if Confirm(Text000, false, "No.") then begin
                            SalesPaymentPost.Run(Rec);
                            SalesPaymentPost.PrintAfterPosting(Rec);
                            CurrPage.Update(false);
                        end;
                    end;
                }
            }
            group("&Print")
            {
                Caption = '&Print';
                action(Receipt)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Receipt';
                    Image = Receipt;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        Print;
                    end;
                }
                action("Pick Tickets")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Pick Tickets';
                    Image = InventoryPick;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        PrintPickTickets;
                    end;
                }
            }
        }
        area(reporting)
        {
            action("Daily Detail")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Daily Detail';
                Image = ViewDetails;
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Sales Payment - Daily Detail";
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CalcFields(Amount, "Amount Tendered");
    end;

    var
        Text000: Label 'Do you want to post Sales Payment %1?';
}

