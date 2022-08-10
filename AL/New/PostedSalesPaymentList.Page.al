page 37002715 "Posted Sales Payment List"
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
    Caption = 'Posted Sales Payments';
    CardPageID = "Posted Sales Payment Card";
    Editable = false;
    PageType = List;
    SourceTable = "Posted Sales Payment Header";
    UsageCategory = History;

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
                field("Amount - ""Amount Tendered"""; Amount - "Amount Tendered")
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
            action("Show &Invoice")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Show &Invoice';
                Image = Invoice;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    ShowInvoice;
                end;
            }
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
            action("&Print")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Print';
                Ellipsis = true;
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Print;
                end;
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
}

