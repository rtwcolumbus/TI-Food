page 37002714 "Sales Payment Tender Subpage"
{
    // PRW16.00.05
    // P8000941, Columbus IT, Don Bresee, 25 JUL 11
    //   Sales Payments granule

    Caption = 'Sales Payment Tender Subpage';
    PageType = ListPart;
    SourceTable = "Sales Payment Tender Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Payment Method Code"; "Payment Method Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Card/Check No."; "Card/Check No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Result; Result)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Cust. Ledger Entry No."; "Cust. Ledger Entry No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("&Void")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Void';
                Ellipsis = true;
                Enabled = VoidEnabled;
                Image = VoidCheck;
                Visible = VoidVisible;

                trigger OnAction()
                var
                    PostNonCashPage: Page "Sales Payments - Check";
                begin
                    PostNonCashPage.VoidNonCashEntry(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        VoidVisible := SalesPayment.Get("Document No.");
        VoidEnabled := VoidVisible and (Result = Result::Authorized);
    end;

    var
        [InDataSet]
        VoidVisible: Boolean;
        [InDataSet]
        VoidEnabled: Boolean;
        SalesPayment: Record "Sales Payment Header";
}

