page 9038 "Production Planner Activities"
{
    // PRW16.00.03
    // P8000810, VerticalSoft, Don Bresee, 05 APR 10
    //   Add P800 Production BOM elements, remove NAV Production BOM
    // 
    // PRW16.00.04
    // P8000877, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Action to run Batch Planning Worksheet
    // 
    // P8000889, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Action to the planning group to run the production sequence page
    // 
    // PRW16.00.06
    // P8001082, Columbus IT, Jack Reynolds, 09 JAN 13
    //   Support for pre-process
    // 
    // PRW17.00.01
    // P8001153, Columbus IT, Jack Reynolds, 15 MAY 13
    //   Set DrillDownPageID for pre-process controls
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names

    Caption = 'Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "Manufacturing Cue";

    layout
    {
        area(content)
        {
#if not CLEAN18
            cuegroup("Intelligent Cloud")
            {
                Caption = 'Intelligent Cloud';
                Visible = false;
                ObsoleteTag = '18.0';
                ObsoleteReason = 'Intelligent Cloud Insights is discontinued.';
                ObsoleteState = Pending;

                actions
                {
                    action("Learn More")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Learn More';
                        Image = TileInfo;
                        RunPageMode = View;
                        ToolTip = ' Learn more about the Intelligent Cloud and how it can help your business.';
                        Visible = false;
                        ObsoleteTag = '18.0';
                        ObsoleteReason = 'Intelligent Cloud Insights is discontinued.';
                        ObsoleteState = Pending;

                        trigger OnAction()
                        var
                            IntelligentCloudManagement: Codeunit "Intelligent Cloud Management";
                        begin
                            HyperLink(IntelligentCloudManagement.GetIntelligentCloudLearnMoreUrl);
                        end;
                    }
                    action("Intelligent Cloud Insights")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Intelligent Cloud Insights';
                        Image = TileCloud;
                        RunPageMode = View;
                        ToolTip = 'View your Intelligent Cloud insights.';
                        Visible = false;
                        ObsoleteTag = '18.0';
                        ObsoleteReason = 'Intelligent Cloud Insights is discontinued.';
                        ObsoleteState = Pending;

                        trigger OnAction()
                        var
                            IntelligentCloudManagement: Codeunit "Intelligent Cloud Management";
                        begin
                            HyperLink(IntelligentCloudManagement.GetIntelligentCloudInsightsUrl);
                        end;
                    }
                }
            }
#endif
            cuegroup("Production Orders")
            {
                Caption = 'Production Orders';
                field("Simulated Prod. Orders"; "Simulated Prod. Orders")
                {
                    ApplicationArea = Manufacturing;
                    DrillDownPageID = "Simulated Production Orders";
                    ToolTip = 'Specifies the number of simulated production orders that are displayed in the Manufacturing Cue on the Role Center. The documents are filtered by today''s date.';
                }
                field("Planned Prod. Orders - All"; "Planned Prod. Orders - All")
                {
                    ApplicationArea = Manufacturing;
                    DrillDownPageID = "Planned Production Orders";
                    ToolTip = 'Specifies the number of planned production orders that are displayed in the Manufacturing Cue on the Role Center. The documents are filtered by today''s date.';
                }
                field("Firm Plan. Prod. Orders - All"; "Firm Plan. Prod. Orders - All")
                {
                    ApplicationArea = Manufacturing;
                    DrillDownPageID = "Firm Planned Prod. Orders";
                    ToolTip = 'Specifies the number of firm planned production orders that are displayed in the Manufacturing Cue on the Role Center. The documents are filtered by today''s date.';
                }
                field("Released Prod. Orders - All"; "Released Prod. Orders - All")
                {
                    ApplicationArea = Manufacturing;
                    DrillDownPageID = "Released Production Orders";
                    ToolTip = 'Specifies the number of released production orders that are displayed in the Manufacturing Cue on the Role Center. The documents are filtered by today''s date.';
                }
                field("Pre-Process Activities - All"; "Pre-Process Activities - All")
                {
                    ApplicationArea = FOODBasic;
                    DrillDownPageID = "Pre-Process Activity List";
                }

                actions
                {
                    action("Change Production Order Status")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Change Production Order Status';
                        RunObject = Page "Change Production Order Status";
                        ToolTip = 'Change the production order to another status, such as Released.';
                    }
                    action("New Production Order")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'New Production Order';
                        RunObject = Page "Planned Production Order";
                        RunPageMode = Create;
                        ToolTip = 'Prepare to produce an end item. ';
                    }
                    action(Navigate)
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Find entries...';
                        RunObject = Page Navigate;
                        ShortCutKey = 'Shift+Ctrl+I';
                        ToolTip = 'Find entries and documents that exist for the document number and posting date on the selected document. (Formerly this action was named Navigate.)';
                    }
                }
            }
            cuegroup("Planning - Operations")
            {
                Caption = 'Planning - Operations';
                field("Purchase Orders"; "Purchase Orders")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'My Purchase Orders';
                    DrillDown = true;
                    DrillDownPageID = "Purchase Order List";
                    ToolTip = 'Specifies the number of purchase orders that are displayed in the Manufacturing Cue on the Role Center. The documents are filtered by today''s date.';
                }

                actions
                {
                    action("New Purchase Order")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'New Purchase Order';
                        RunObject = Page "Purchase Order";
                        RunPageMode = Create;
                        ToolTip = 'Purchase goods or services from a vendor.';
                    }
                    action("Edit Planning Worksheet")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Edit Planning Worksheet';
                        RunObject = Page "Planning Worksheet";
                        ToolTip = 'Plan supply orders automatically to fulfill new demand.';
                    }
                    action("Edit Batch Planning Worksheet")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Edit Batch Planning Worksheet';
                        RunObject = Page "Batch Planning Worksheet";
                    }
                    action("Production Sequence")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Production Sequence';
                        RunObject = Page "Production Sequence";
                    }
                    action("Generate Pre-Process Activity")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Generate Pre-Process Activity';
                        RunObject = Report "Generate Pre-Process Activity";
                    }
                    action("Edit Subcontracting Worksheet")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Edit Subcontracting Worksheet';
                        RunObject = Page "Subcontracting Worksheet";
                        ToolTip = 'Plan outsourcing of operation on released production orders.';
                    }
                }
            }
            cuegroup(Design)
            {
                Caption = 'Design';
                field("Formulas under Development"; "Formulas under Development")
                {
                    ApplicationArea = FOODBasic;
                    DrillDownPageID = "Production Formula List";
                }
                field("Package BOMs under Development"; "Package BOMs under Development")
                {
                    ApplicationArea = FOODBasic;
                    DrillDownPageID = "Package BOM List";
                }
                field("Routings under Development"; "Routings under Development")
                {
                    ApplicationArea = Manufacturing;
                    DrillDownPageID = "Routing List";
                    ToolTip = 'Specifies the routings under development that are displayed in the Manufacturing Cue on the Role Center. The documents are filtered by today''s date.';
                }

                actions
                {
                    action("New Item")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'New Item';
                        RunObject = Page "Item Card";
                        RunPageMode = Create;
                        ToolTip = 'Create an item card based on the stockkeeping unit.';
                    }
                    action("New Formula BOM")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'New Formula BOM';
                        RunObject = Page "Production Formula";
                        RunPageMode = Create;
                    }
                    action("New Package BOM")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'New Package BOM';
                        RunObject = Page "Package BOM";
                        RunPageMode = Create;
                    }
                    action("New Routing")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'New Routing';
                        RunObject = Page Routing;
                        RunPageMode = Create;
                        ToolTip = 'Create a routing that defines the operations required to produce an end item.';
                    }
                }
            }
            cuegroup("My User Tasks")
            {
                Caption = 'My User Tasks';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteReason = 'Replaced with User Tasks Activities part';
                ObsoleteTag = '17.0';
                field("UserTaskManagement.GetMyPendingUserTasksCount"; UserTaskManagement.GetMyPendingUserTasksCount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pending User Tasks';
                    Image = Checklist;
                    ToolTip = 'Specifies the number of pending tasks that are assigned to you or to a group that you are a member of.';
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced with User Tasks Activities part';
                    ObsoleteTag = '17.0';

                    trigger OnDrillDown()
                    var
                        UserTaskList: Page "User Task List";
                    begin
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
                ApplicationArea = Basic, Suite;
                Caption = 'Set Up Cues';
                Image = Setup;
                ToolTip = 'Set up the cues (status tiles) related to the role.';

                trigger OnAction()
                var
                    CueRecordRef: RecordRef;
                begin
                    CueRecordRef.GetTable(Rec);
                    CuesAndKpis.OpenCustomizePageForCurrentUser(CueRecordRef.Number);
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

        ShowIntelligentCloud := not EnvironmentInfo.IsSaaS;
    end;

    var
        CuesAndKpis: Codeunit "Cues And KPIs";
        EnvironmentInfo: Codeunit "Environment Information";
        UserTaskManagement: Codeunit "User Task Management";
        ShowIntelligentCloud: Boolean;
}

