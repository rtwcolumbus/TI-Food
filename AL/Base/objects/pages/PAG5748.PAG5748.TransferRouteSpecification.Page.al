page 5748 "Transfer Route Specification"
{
    // PRW16.00.05
    // P8000954, Columbus IT, Jack Reynolds, 08 JUL 11
    //   Support for transfer orders on delivery routes and trips
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names

    Caption = 'Trans. Route Spec.';
    PageType = Card;
    SourceTable = "Transfer Route";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("In-Transit Code"; Rec."In-Transit Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the in-transit code for the transfer order, such as a shipping agent.';
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the code for the shipping agent who is transporting the items.';
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the code for the service, such as a one-day delivery, that is offered by the shipping agent.';
                }
                field("Default Delivery Route No."; Rec."Default Delivery Route No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Default Delivery Stop No."; Rec."Default Delivery Stop No.")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Route)
            {
                Caption = 'Route';
                action("Delivery Routing Matrix")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Delivery Routing Matrix';
                    Image = ShowMatrix;
                    RunObject = Page "Delivery Routing Matrix";
                    RunPageLink = "Source Type" = CONST(Transfer),
                                  "Source No." = FIELD("Transfer-from Code"),
                                  "Source No. 2" = FIELD("Transfer-to Code");
                }
            }
        }
    }

    trigger OnClosePage()
    var
        CanBeDeleted: Boolean;
    begin
        CanBeDeleted := true;
        OnBeforeClosePage(Rec, CanBeDeleted);
        if CanBeDeleted then
            if Get("Transfer-from Code", "Transfer-to Code") then
                if ("Shipping Agent Code" = '') and
                   ("Shipping Agent Service Code" = '') and
                  // P8000954
                  ("Default Delivery Route No." = '') and
                  ("Default Delivery Stop No." = '') and
                   // P8000954
                   ("In-Transit Code" = '')
                then
                    Delete(true); // P8000954
    end;

    trigger OnInit()
    begin
        CurrPage.LookupMode := true;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeClosePage(TransferRoute: Record "Transfer Route"; var CanBeDeleted: Boolean)
    begin
    end;
}

