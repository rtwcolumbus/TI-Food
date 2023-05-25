page 37002656 "N138 Transport Costs"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 09-10-2014, Initial Version
    // --------------------------------------------------------------------------------
    // PRW110.0
    // P8008464, To-Increase, Dayakar Battini, 28 FEB 17
    //   Product N138 replaced with Distribution Planning
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects

    AutoSplitKey = true;
    Caption = 'Transport Costs';
    PageType = List;
    SourceTable = "N138 Transport Cost";

    layout
    {
        area(content)
        {
            repeater(Control1100499000)
            {
                ShowCaption = false;
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Amount (LCY)"; "Amount (LCY)")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field("G/L Account No."; "G/L Account No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Functions")
            {
                Caption = '&Functions';
                action("&Refresh Transport Costs")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Refresh Transport Costs';
                    Image = Refresh;

                    trigger OnAction()
                    var
                        lRecTransportCost: Record "N138 Transport Cost";
                    begin
                        lRecTransportCost.Reset;
                        lRecTransportCost.SetRange(Subtype, Subtype);
                        lRecTransportCost.SetRange("No.", "No.");
                        lRecTransportCost.SetRange(Type, Type::"Cost Component Template");
                        if lRecTransportCost.FindSet then
                            repeat
                                lRecTransportCost.gFncUpdateAmount;
                                lRecTransportCost.Modify(true);
                            until lRecTransportCost.Next = 0;
                    end;
                }
            }
        }
        area(Promoted)
        {
            actionref(RefreshTransportCosts_Promoted; "&Refresh Transport Costs")
            {
            }
        }
    }

    trigger OnOpenPage()
    begin
        // P8008464
        if not ProcessFns.DistPlanningInstalled then
            Error(Text000);
        // P8008464
    end;

    var
        Text000: Label 'Product Distribution Planning must be installed.';
        ProcessFns: Codeunit "Process 800 Functions";
}

