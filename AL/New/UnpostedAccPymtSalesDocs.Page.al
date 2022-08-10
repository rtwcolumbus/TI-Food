page 37002441 "Unposted Acc. Pymt. Sales Docs"
{
    // PRW18.00.02
    // P8002741, To-Increase, Jack Reynolds, 30 Sep 15
    //   Option to create accrual payment documents

    Caption = 'Unposted Accrual Payment Sales Documents';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Sales Header";
    SourceTableView = WHERE("Accrual Payment" = CONST(true));

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
                field("Sell-to Customer No."; "Sell-to Customer No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Sell-to Customer Name"; "Sell-to Customer Name")
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
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ShowDocument)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Show Document';
                Image = View;
                ShortCutKey = 'Shift+F7';
                trigger OnAction()
                begin
                    if "No." <> '' then
                        case "Document Type" of
                            "Document Type"::Invoice:
                                PAGE.Run(PAGE::"Sales Invoice", Rec);
                            "Document Type"::"Credit Memo":
                                PAGE.Run(PAGE::"Sales Credit Memo", Rec);
                        end;
                end;
            }
        }
    }

    procedure GetCurrentRec(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader := Rec;
    end;
}

