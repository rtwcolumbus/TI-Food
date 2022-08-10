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
    //
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 01 JUN 22
    //   Cleanup Role Centers and Navigate (Find Entries)

    Caption = 'Quality Control';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            part(Headline; "Headline Quality Control")
            {
                ApplicationArea = Basic, Suite;
            }
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
        area(sections)
        {
            group(QualityControl)
            {
                Caption = 'Quality Control';
                action("Item Quality Tests")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Quality Tests';
                    Image = TaskQualityMeasure;
                    RunObject = Page "Item Quality Tests";
                }
                action("Quality Control Activities")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Quality Control Activities';
                    Image = CheckRulesSyntax;
                    RunObject = Page "Open Q/C Activity List";
                }
            }
            group(Incidents)
            {
                Caption = 'Incidents';
                action("Incident Entries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Incident Entries';
                    Image = Entries;
                    RunObject = Page "Incident Entries";
                }
            }
            group(DataCollection)
            {
                Caption = 'Process Data Collection';
                action("Data Sheets")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Data Sheets';
                    Image = EntriesList;
                    RunObject = Page "Open Data Sheets";
                }
                action("Open Alerts")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Open Alerts';
                    Image = Alerts;
                    RunObject = Page "Open Data Collection Alerts";
                }
            }
        }
        area(processing)
        {
            group(QualityControlTasks)
            {
                Caption = 'Quality Control';
                action(QualityControlActivities)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Quality Control Activities';
                    Image = CheckRulesSyntax;
                    RunObject = Page "Open Q/C Activity List";
                }

            }
            group(IncidentsTasks)
            {
                Caption = 'Incidents';
                action("IncidentSearch")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Search';
                    Image = Find;
                    RunObject = page "Incident Search";
                }
            }group(DataCollectionTasks)
            {
                 Caption = 'Process Data Collection';
                action(DataSheets)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Data Sheets';
                    Image = EntriesList;
                    RunObject = Page "Open Data Sheets";
                }
                action(OpenAlerts)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Open Alerts';
                    Image = Alerts;
                    RunObject = Page "Open Data Collection Alerts";
                }
            }
            group(Administration)
            {
                Caption = 'Administration';
                group(QualityControlAdmin)
                {
                    Caption = 'Quality Control';
                    action(DataElementsQualityControl)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Data Elements';
                        Image = Properties;
                        RunObject = page "Data Collection Data Elements";
                    }
                    action("QualityControlTechnicians")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Quality Control Technicians';
                        Image = PersonInCharge;
                        RunObject = page "Quality Control Technicians";
                    }
                    action("SkipLogicSetupList ")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Skip Logic Setup List';
                        Image = List;
                        RunObject = page "Skip Logic Setup List";
                    }
                    action("ItemQualitySkipLogicTemplate")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Item Quality Skip Logic Template';
                        Image = Template;
                        RunObject = page "Item Q/C Skip Logic Lines";
                    }
                }
                group(IncidentAdmin)
                {
                    Caption = 'Incidents';
                    action("IncidentReasonCodes")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Incident Reason Codes';
                        Image = ServiceCode;
                        RunObject = page "Incident Reason Codes";
                    }
                    action("IncidentClassificationCodes")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Incident Classification Codes';
                        Image = ServiceCode;
                        RunObject = page "Incident Classification Codes";
                    }
                }
                group(DataCollectionAdmin)
                {
                    Caption = 'Process Data Collection';
                    action(DataElementsDataCollection)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Data Collection Data Elements';
                        Image = Properties;
                        RunObject = page "Data Collection Data Elements";
                    }
                    action("SetupDataCollectionLogGroups")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Data Collection Log Groups';
                        Image = Group;
                        RunObject = page "Data Collection Log Groups";
                    }
                    action("DataCollectionAlertGroups")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Data Collection Alert Groups';
                        Image = Alerts;
                        RunObject = page "Data Collection Alert Groups";
                    }
                    action("DataCollectionTemplates")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Data Collection Templates';
                        Image = Template;
                        RunObject = page "Data Collection Templates";
                    }
                }
            }
            Group(History)
            {
                Caption = 'History';
                Image = History;
                group(LotHistory)
                {
                    Caption = 'Lots';
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
                group(QualityControlHistory)
                {
                    Caption = 'Quality Control';
                action("Completed Quality Control Activities")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Completed Quality Control Activities';
                    Image = Completed;
                    RunObject = Page "Completed Q/C Activity List";
                }
                }
                group(IncidentHistory)
                {
                    Caption = 'Incidents';
                action("Finished Incidents")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Finished Incidents';
                    Image = Completed;
                    RunObject = Page "Incident Entries";
                    RunPageView = WHERE(Status = CONST(Finished));
                }
                action("Denied Incidents")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Denied Incidents';
                    Image = Cancel;
                    RunObject = Page "Incident Entries";
                    RunPageView = WHERE(Status = CONST(Denied));
                }
                }
                group(DatacollectionHistory)
                {
                    Caption = 'Data Collection';
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
                }
                action("Navi&gate")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Find entries...';
                    Image = Navigate;
                    RunObject = Page Navigate;
                    ShortCutKey = 'Ctrl+Alt+Q';
                }
            }
        }
        area(Reporting)
        {
            group(QualityControlReports)
            {
                Caption = 'Quality Control';
                group(QCReports)
                {
                    Caption = 'Reports';

                    action("Item Lots Pending")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Item Lots Pending';
                        Image = View;
                        RunObject = Report "Item Lots Pending";
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
                }
                group(QCDocuments)
                {
                    Caption = 'Documents';
                    action("QualityControlWorksheet")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Quality Control Worksheet';
                        Image = ViewWorksheet;
                        RunObject = report "Quality Control Worksheet";
                    }
                    action("CertificateofAnalysis")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Certificate of Analysis';
                        Image = Certificate;
                        RunObject = report "Certificate of Analysis";
                    }
                    action("CertificateofAnalysisbyShipment")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Certificate of Analysis by Shipment';
                        Image = Certificate;
                        RunObject = report "Cert. of Analysis by Shipment";
                    }
                }
            }
        }
    }
}

