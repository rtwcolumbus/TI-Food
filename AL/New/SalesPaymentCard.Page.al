page 37002712 "Sales Payment Card"
{
    // PRW16.00.05
    // P8000941, Columbus IT, Don Bresee, 25 JUL 11
    //   Sales Payments granule
    // 
    // PRW17.00
    // P8001149, Columbus IT, Don Bresee, 24 APR 13
    //   Fix PromotedActionCategoriesML property - Add New and Report options, blanks are ignored
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017

    Caption = 'Sales Payment Card';
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,Lines,Tenders';
    SourceTable = "Sales Payment Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnAssistEdit()
                    begin
                        if AssistEditNo(xRec) then
                            CurrPage.Update;
                    end;
                }
                group(Control37002011)
                {
                    ShowCaption = false;
                    field("Customer No."; "Customer No.")
                    {
                        ApplicationArea = FOODBasic;

                        trigger OnValidate()
                        begin
                            CurrPage.Update;
                        end;
                    }
                    field("Customer Name"; "Customer Name")
                    {
                        ApplicationArea = FOODBasic;
                    }
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = FOODBasic;
                }
                group(Control37002019)
                {
                    ShowCaption = false;
                    field(Amount; Amount)
                    {
                        ApplicationArea = FOODBasic;
                        DrillDown = false;
                    }
                    field("Amount Tendered"; "Amount Tendered")
                    {
                        ApplicationArea = FOODBasic;
                        DrillDown = false;
                    }
                    field("GetBalance(FALSE)"; GetBalance(false))
                    {
                        ApplicationArea = FOODBasic;
                        AutoFormatType = 1;
                        Caption = 'Balance';
                    }
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Allow Posting w/ Balance"; "Allow Posting w/ Balance")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            part(Lines; "Sales Payment Subpage")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lines';
                SubPageLink = "Document No." = FIELD("No.");
                SubPageView = SORTING("Document No.", "Line No.");
            }
            part(Tenders; "Sales Payment Tender Subpage")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Tenders';
                Editable = false;
                SubPageLink = "Document No." = FIELD("No.");
                SubPageView = SORTING("Document No.");
            }
        }
        area(factboxes)
        {
            systempart(Control37002006; Notes)
            {
                ApplicationArea = FOODBasic;
            }
            systempart(Control37002007; Links)
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
            separator(Separator37002013)
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
                        TestField("No.");
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
                        TestField("No.");
                        if Confirm(Text000, false, "No.") then begin
                            SalesPaymentPost.Run(Rec);
                            SalesPaymentPost.PrintAfterPosting(Rec);
                            CurrPage.Update(false);
                        end;
                    end;
                }
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("&Add Orders")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Add Orders';
                    Ellipsis = true;
                    Image = AddAction;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'Ctrl+A';

                    trigger OnAction()
                    begin
                        AddOrders;
                    end;
                }
                action("Add &Open Entries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Add &Open Entries';
                    Ellipsis = true;
                    Image = AddAction;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'Ctrl+O';

                    trigger OnAction()
                    begin
                        AddOpenEntries;
                    end;
                }
            }
            group("P&ayments")
            {
                Caption = 'P&ayments';
                action("&Cash")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Cash';
                    Ellipsis = true;
                    Image = Costs;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+Ctrl+C';

                    trigger OnAction()
                    begin
                        DoCashPayment;
                    end;
                }
                action("Check/&Other")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Check/&Other';
                    Ellipsis = true;
                    Image = Check;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        DoNonCashPayment;
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
    }

    trigger OnAfterGetRecord()
    begin
        CalcFields(Amount, "Amount Tendered");
    end;

    var
        Text000: Label 'Do you want to post Sales Payment %1?';
}

