page 37002550 "Quality Control Activities"
{
    // PRW16.00.20
    // P8000685, VerticalSoft, Jack Reynolds, 29 APR 09
    //   Standard "Activities" page with cue group for Q/C activities
    // 
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW18.00
    // P8001355, Columbus IT, Jack Reynolds, 30 OCT 14
    //   Add action for "Set Up Cues"
    // 
    // PRW111.00.01
    // P80036649, To-Increase, Jack Reynolds, 28 AUG 18
    //   Incidents
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Activities';
    PageType = CardPart;
    SourceTable = "Quality Control Cue";

    layout
    {
        area(content)
        {
            cuegroup("Quality Control")
            {
                Caption = 'Quality Control';
                field("Pending Q/C Activities"; "Pending Q/C Activities")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Pending';
                    DrillDownPageID = "Open Q/C Activity List";
                }
            }
            cuegroup("Data Collection")
            {
                Caption = 'Data Collection';
                field("Pending  Data Sheets"; "Pending  Data Sheets")
                {
                    ApplicationArea = FOODBasic;
                    DrillDownPageID = "Open Data Sheets";
                }
                field("In Progress Data Sheets"; "In Progress Data Sheets")
                {
                    ApplicationArea = FOODBasic;
                    DrillDownPageID = "Open Data Sheets";
                }
                field("Open Alerts"; "Open Alerts")
                {
                    ApplicationArea = FOODBasic;
                    DrillDownPageID = "Open Data Collection Alerts";
                }
            }
            cuegroup(Incidents)
            {
                Caption = 'Incidents';
                field("Created Incidents"; "Created Incidents")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Created';
                    DrillDownPageID = "Incident Entries";
                }
                field("In Progress Incidents"; "In Progress Incidents")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'In Progress';
                    DrillDownPageID = "Incident Entries";
                }
                field("Assigned Incidents"; "Assigned Incidents")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Assigned';
                    DrillDownPageID = "Incident Entries";
                }
                field("To Be Approved Incidents"; "To Be Approved Incidents")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'To Be Approved';
                    DrillDownPageID = "Incident Entries";
                }

                actions
                {
                    action("Incident Search")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Incident Search';
                        RunObject = Page "Incident Search";
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
    end;

    var
        CueSetup: Codeunit "Cues And KPIs";
        UserTaskManagement: Codeunit "User Task Management";
}

