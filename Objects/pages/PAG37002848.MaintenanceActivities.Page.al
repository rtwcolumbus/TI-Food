page 37002848 "Maintenance Activities"
{
    // PRW16.00.20
    // P8000671, VerticalSoft, Jack Reynolds, 30 JAN 09
    //   Standard "Activities" page with cue groups for work orders by status and purchase orders
    // 
    // P8000719, VerticalSoft, Jack Reynolds, 10 AUG 09
    //   Support for combined maintenance journal
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW18.00
    // P8001355, Columbus IT, Jack Reynolds, 30 OCT 14
    //   Add action for "Set Up Cues"
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Activities';
    PageType = CardPart;
    SourceTable = "Maintenance Cue";

    layout
    {
        area(content)
        {
            cuegroup("Work Orders")
            {
                Caption = 'Work Orders';
                field("Orders Waiting Approval"; "Orders Waiting Approval")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Waiting Approval';
                    DrillDownPageID = "Open Work Order List";
                }
                field("Orders Waiting Scheduling"; "Orders Waiting Scheduling")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Waiting Scheduling';
                    DrillDownPageID = "Open Work Order List";
                }
                field("Orders Waiting Parts"; "Orders Waiting Parts")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Waiting Parts';
                    DrillDownPageID = "Open Work Order List";
                }
                field("Orders Scheduled"; "Orders Scheduled")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Scheduled';
                    DrillDownPageID = "Open Work Order List";
                }
                field("Orders In Work"; "Orders In Work")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'In Work';
                    DrillDownPageID = "Open Work Order List";
                }

                actions
                {
                    action("New Work Order")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'New Work Order';
                        RunObject = Page "Work Order";
                        RunPageMode = Create;
                    }
                    action("Edit Labor Journal")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Edit Labor Journal';
                        RunObject = Page "Maintenance Labor Journal";
                    }
                    action("Edit Material Journal")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Edit Material Journal';
                        RunObject = Page "Maintenance Material Journal";
                    }
                    action("Edit Contract Journal")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Edit Contract Journal';
                        RunObject = Page "Maintenance Contract Journal";
                    }
                    action("Edit Maintenance Journal")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Edit Maintenance Journal';
                        RunObject = Page "Maintenance Journal";
                    }
                }
            }
            cuegroup(Purchasing)
            {
                Caption = 'Purchasing';
                field("Purchase Orders"; "Purchase Orders")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'My Purchase Orders';
                    DrillDownPageID = "Purchase Order List";
                }

                actions
                {
                    action("New Purchase Order")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'New Purchase Order';
                        RunObject = Page "Purchase Order";
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

        SetRange("User ID Filter", UserId);
    end;

    var
        CueSetup: Codeunit "Cues And KPIs";
        UserTaskManagement: Codeunit "User Task Management";
}

