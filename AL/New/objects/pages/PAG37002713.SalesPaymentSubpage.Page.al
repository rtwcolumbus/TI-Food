page 37002713 "Sales Payment Subpage"
{
    // PRW16.00.05
    // P8000941, Columbus IT, Don Bresee, 25 JUL 11
    //   Sales Payments granule
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names

    AutoSplitKey = true;
    Caption = 'Sales Payment Subpage';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Sales Payment Line";

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
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookupNo(Text));
                    end;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Allow Order Changes"; "Allow Order Changes")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Order Shipment Status"; "Order Shipment Status")
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
            action("&View Order")
            {
                ApplicationArea = FOODBasic;
                Caption = '&View Order';
                Ellipsis = true;
                Enabled = IsOrder;
                Image = View;
                ShortCutKey = 'Shift+Ctrl+V';

                trigger OnAction()
                begin
                    ShowOrder(false);
                end;
            }
            action("&Edit Order")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Edit Order';
                Ellipsis = true;
                Enabled = IsOrder;
                Image = DocumentEdit;
                ShortCutKey = 'Shift+Ctrl+E';

                trigger OnAction()
                begin
                    ShowOrder(true);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IsOrder := (Type = Type::Order) and ("No." <> '');
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if (xRec.Type in [Type::Order, Type::"Open Entry"]) then
            Validate(Type, xRec.Type)
        else
            Validate(Type, Type::Order);
    end;

    var
        [InDataSet]
        IsOrder: Boolean;
}

