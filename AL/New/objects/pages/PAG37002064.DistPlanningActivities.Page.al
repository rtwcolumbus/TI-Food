page 37002064 "Dist. Planning Activities"
{
    // PRW16.00.03
    // P8000810, VerticalSoft, Don Bresee, 11 APR 10
    //   Create Distribution Planning Role Center
    // 
    // PRW18.00
    // P8001355, Columbus IT, Jack Reynolds, 30 OCT 14
    //   Add action for "Set Up Cues"
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW19.00.01
    // P8007830, To-Increase, Dayakar Battini, 11 OCT 16
    //   Remove Trip Management and Trip Settlement links
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Activities';
    PageType = CardPart;
    SourceTable = "Dist. Planning Cue";

    layout
    {
        area(content)
        {
            cuegroup("Sales Orders")
            {
                Caption = 'Sales Orders';
                field("My Sales Orders"; "My Sales Orders")
                {
                    ApplicationArea = FOODBasic;
                    DrillDownPageID = "Sales Order List";
                }
                field("To Ship - Today"; "To Ship - Today")
                {
                    ApplicationArea = FOODBasic;
                    DrillDownPageID = "Sales Order List";
                }
                field("Shipping Delayed"; "Shipping Delayed")
                {
                    ApplicationArea = FOODBasic;
                    DrillDownPageID = "Sales Order List";
                }
                field("Partially Shipped"; "Partially Shipped")
                {
                    ApplicationArea = FOODBasic;
                    DrillDownPageID = "Sales Order List";
                }

                actions
                {
                    action("Order Shipping")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Order Shipping';
                        RunObject = Page "Order Shipping";
                    }
                    action("Route Review")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Route Review';
                        RunObject = Page "Posted Delivery Route Review";
                    }
                }
            }
            cuegroup("Pickup Loads")
            {
                Caption = 'Pickup Loads';
                field("To Pickup - Today"; "To Pickup - Today")
                {
                    ApplicationArea = FOODBasic;
                    DrillDownPageID = "Pickup Load List";
                }
                field("Pickup Delayed"; "Pickup Delayed")
                {
                    ApplicationArea = FOODBasic;
                    DrillDownPageID = "Pickup Load List";
                }

                actions
                {
                    action("Order Receiving")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Order Receiving';
                        RunObject = Page "Order Receiving";
                    }
                    action("Truckload Receiving")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Truckload Receiving';
                        RunObject = Page "Truckload Receiving";
                    }
                    action("New Pickup Load")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'New Pickup Load';
                        RunObject = Page "Pickup Load";
                        RunPageMode = Create;
                    }
                }
            }
            cuegroup("My User Tasks")
            {
                Caption = 'My User Tasks';
                field("UserTaskManagement.GetMyPendingUserTasksCount"; UserTaskManagement.GetMyPendingUserTasksCount)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Pending User Tasks';
                    Image = Checklist;

                    trigger OnDrillDown()
                    var
                        UserTaskList: Page "User Task List";
                    begin
                        // P80073095
                        UserTaskList.SetPageToShowMyPendingUserTasks;
                        UserTaskList.Run;
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Set Up Cues")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Set Up Cues';

                trigger OnAction()
                var
                    CueRecordRef: RecordRef;
                begin
                    // P8001355
                    CueRecordRef.GetTable(Rec);
                    CueSetup.OpenCustomizePageForCurrentUser(CueRecordRef.Number);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;
        SetFlowFilters;
    end;

    var
        CueSetup: Codeunit "Cues And KPIs";
        UserTaskManagement: Codeunit "User Task Management";
}

