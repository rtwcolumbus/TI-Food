page 37002716 "Posted Sales Payment Card"
{
    // PRW16.00.05
    // P8000941, Columbus IT, Don Bresee, 25 JUL 11
    //   Sales Payments granule

    Caption = 'Posted Sales Payment Card';
    Editable = false;
    PageType = Card;
    SourceTable = "Posted Sales Payment Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                group(Control37002011)
                {
                    ShowCaption = false;
                    field("Customer No."; "Customer No.")
                    {
                        ApplicationArea = FOODBasic;
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
                field("Sales Payment No."; "Sales Payment No.")
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
                    field("Amount - ""Amount Tendered"""; Amount - "Amount Tendered")
                    {
                        ApplicationArea = FOODBasic;
                        AutoFormatType = 1;
                        Caption = 'Balance';
                    }
                }
            }
            part(Lines; "Posted Sales Payment Subpage")
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
    }

    trigger OnAfterGetRecord()
    begin
        CalcFields(Amount, "Amount Tendered");
    end;
}

