page 37002551 "Quality Control Role Center"
{
    // PRW16.00.20
    // P8000685, VerticalSoft, Jack Reynolds, 29 APR 09
    //   Role center page for Quality Control Worker
    // 
    // PRW16.00.04
    // P8000897, VerticalSoft, Jack Reynolds, 22 JAN 11
    //   Fix spelling mistake
    // 
    // P8000916, Columbus IT, Jack Reynolds, 10 MAR 11
    //   Updated for commodities
    // 
    // PRW16.00.06
    // P8001117, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Support for process data collection
    // 
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.10
    // P8001218, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Remove Outlook part
    // 
    // PRW18.00
    // P8001355, Columbus IT, Jack Reynolds, 30 OCT 14
    //   Add Report Inbox
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW111.00.01
    // P80036649, To-Increase, Jack Reynolds, 28 AUG 18
    //   Incidents
    // 
    // P80060684, To-Increase, Jack Reynolds, 2 AUG 18
    //   Update Caption

    Caption = 'Quality Control';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            group(Control37002001)
            {
                ShowCaption = false;
                part(Control37002002; "Quality Control Activities")
                {
                    ApplicationArea = FOODBasic;
                }
                part(Control37002005; "My Items")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Control37002004)
            {
                ShowCaption = false;
                part(Control37002023; "My Alerts")
                {
                    ApplicationArea = FOODBasic;
                }
                part(Control37002003; "Report Inbox Part")
                {
                    ApplicationArea = FOODBasic;
                }
                systempart(Control37002006; MyNotes)
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
        area(embedding)
        {
            action("Quality Control Activities")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Quality Control Activities';
                Image = CheckRulesSyntax;
                RunObject = Page "Open Q/C Activity List";
            }
            action("Item Quality Tests")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Item Quality Tests';
                Image = TaskQualityMeasure;
                RunObject = Page "Item Quality Tests";
            }
            action("Data Sheets")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Data Sheets';
                Image = EntriesList;
                RunObject = Page "Open Data Sheets";
            }
            action("Log Groups")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Log Groups';
                Enabled = false;
                Image = Log;
                RunObject = Page "Data Collection Log Groups";
            }
            action("Incident Entries")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Incident Entries';
                RunObject = Page "Incident Entries";
            }
        }
        area(sections)
        {
            group(History)
            {
                Caption = 'History';
                Image = History;
                action("Completed Quality Control Activities")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Completed Quality Control Activities';
                    Image = Completed;
                    RunObject = Page "Completed Q/C Activity List";
                }
                action("Completed Data Sheets")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Completed Data Sheets';
                    Image = Completed;
                    RunObject = Page "Completed Data Sheets";
                }
                action("Closed Alerts")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Closed Alerts';
                    Image = Alerts;
                    RunObject = Page "Closed Data Collection Alerts";
                }
                action("Finished Incidents")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Finished Incidents';
                    RunObject = Page "Incident Entries";
                    RunPageView = WHERE(Status = CONST(Finished));
                }
                action("Denied Incidents")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Denied Incidents';
                    RunObject = Page "Incident Entries";
                    RunPageView = WHERE(Status = CONST(Denied));
                }
            }
        }
        area(processing)
        {
            separator(Separator37002011)
            {
                Caption = 'History';
                IsHeader = true;
            }
            action("Lot History")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lot History';
                Image = History;
                RunObject = Page Lots;
            }
            action("Item Tracing")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Item Tracing';
                Image = ItemTracing;
                RunObject = Page "Item Tracing";
            }
        }
        area(reporting)
        {
            action("Item Lots Pending")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Item Lots Pending';
                Image = View;
                RunObject = Report "Item Lots Pending";
            }
            action("Commodity Cost Q/C Errors")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Commodity Cost Q/C Errors';
                Image = Error;
                RunObject = Report "Commodity Cost Q/C Errors";
            }
            action("Commodity Payment Q/C Errors")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Commodity Payment Q/C Errors';
                Image = Error;
                RunObject = Report "Commodity Payment Q/C Errors";
            }
            action("Item Lots by Expiration Date")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Item Lots by Expiration Date';
                Image = ItemAvailabilitybyPeriod;
                RunObject = Report "Item Lots by Expiration Date";
            }
            action("Item Test Results")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Item Test Results';
                Image = TestReport;
                RunObject = Report "Item Test Results";
            }
            action("Quality Control Test Results")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Quality Control Test Results';
                Image = CheckRulesSyntax;
                RunObject = Report "Quality Control Test Results";
            }
        }
    }
}

