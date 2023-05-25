page 37002442 "Unposted Acc. Pymt. Purch Docs"
{
    // PRW18.00.02
    // P8002741, To-Increase, Jack Reynolds, 30 Sep 15
    //   Option to create accrual payment documents

    Caption = 'Unposted Accrual Payment Purchase Documents';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Purchase Header";
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
                field("Buy-from Vendor No."; "Buy-from Vendor No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Buy-from Vendor Name"; "Buy-from Vendor Name")
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
                                PAGE.Run(PAGE::"Purchase Invoice", Rec);
                            "Document Type"::"Credit Memo":
                                PAGE.Run(PAGE::"Purchase Credit Memo", Rec);
                        end;
                end;
            }
        }
    }

    procedure GetCurrentRec(var PurchHeader: Record "Purchase Header")
    begin
        PurchHeader := Rec;
    end;
}

