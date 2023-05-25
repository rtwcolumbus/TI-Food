page 37002847 "Maint. Supervisor Role Center"
{
    // PRW16.00.20
    // P8000671, VerticalSoft, Jack Reynolds, 30 JAN 09
    //   Role center page for Maintenance Supervisor
    // 
    // P8000719, VerticalSoft, Jack Reynolds, 10 AUG 09
    //   Support for combined maintenance journal
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
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
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 07 DEC 16
    //   Item Category/Product Group
    // 
    // PRW111.00.01
    // P80060684, To-Increase, Jack Reynolds, 2 AUG 18
    //   Update Caption
    //
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 01 JUN 22
    //   Cleanup Role Centers and Navigate (Find Entries)

    Caption = 'Maintenance Supervisor';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            part(Headline; "Headline Maint. Supervisor")
            {
                ApplicationArea = Basic, Suite;
            }
            group(Control37002007)
            {
                ShowCaption = false;
                part(Control37002008; "Maintenance Activities")
                {
                    ApplicationArea = FOODBasic;
                }
                part(Control37002012; "My Assets")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Control37002011)
            {
                ShowCaption = false;
                part(Control37002010; "My Items")
                {
                    ApplicationArea = FOODBasic;
                }
                part(Control37002009; "Report Inbox Part")
                {
                    ApplicationArea = FOODBasic;
                }
                systempart(Control37002013; MyNotes)
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
            action(Assets)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Assets';
                Image = ListPage;
                RunObject = Page "Asset List";
            }
            action(PM)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Preventive Maintenance Orders';
                Image = MaintenanceLedger;
                RunObject = Page "Preventive Maintenance Orders";
            }
            action(Spares)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Spares';
                Image = Components;
                RunObject = Page "Item List";
                RunPageView = SORTING("Item Type", "Item Category Code")
                              WHERE("Item Type" = CONST(Spare));
            }
            action(WorkOrders)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Work Orders';
                Image = Document;
                RunObject = Page "Open Work Order List";
            }
            action(PurchaseOrders)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Purchase Orders';
                Image = List;
                RunObject = Page "Purchase Order List";
            }
        }
        area(sections)
        {
            group(Assets2)
            {
                Caption = 'Assets';
                action(Assets3)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Assets';
                    Image = ListPage;
                    RunObject = Page "Asset List";
                }
                action(PM3)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Preventive Maintenance Orders';
                    Image = MaintenanceLedger;
                    RunObject = Page "Preventive Maintenance Orders";
                }
            }
            group(Planning)
            {
                Caption = 'Planning';
                action("Work Order Schedule")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Work Order Schedule';
                    Image = CalculatePlan;
                    RunObject = Page "Work Order Schedule";
                }
                action("PM Worksheet")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'PM Worksheet';
                    Image = OpenWorksheet;
                    RunObject = Page "PM Worksheet Names";
                }
            }
            group(Operations)
            {
                Caption = 'Operations';
                action(WorkOrders2)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Work Orders';
                    Image = Document;
                    RunObject = Page "Open Work Order List";
                }
                action(PurchaseOrders2)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Purchase Orders';
                    Image = List;
                    RunObject = Page "Purchase Order List";
                }
                action("Labor Journal")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Labor Journal';
                    Image = Journals;
                    RunObject = Page "Maintenance Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(Labor));
                }
                action("Material Journal")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Material Journal';
                    Image = Journals;
                    RunObject = Page "Maintenance Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(Material));
                }
                action("Contract Journal")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Contract Journal';
                    Image = Journals;
                    RunObject = Page "Maintenance Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(Contract));
                }
                action("Maintenance Journal")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Maintenance Journal';
                    Image = Journals;
                    RunObject = Page "Maintenance Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(Maintenance));
                }
            }
        }
        area(Creation)
        {
            action("Work Order")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Work Order';
                Image = Document;
                RunObject = Page "Work Order";
                RunPageMode = Create;
            }
            action("Purchase Order")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Purchase Order';
                Image = Document;
                RunObject = Page "Purchase Order";
                RunPageMode = Create;
            }
        }
        area(processing)
        {
            action(Assets4)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Assets';
                Image = ListPage;
                RunObject = Page "Asset List";
            }
            action(PM4)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Preventive Maintenance Orders';
                Image = MaintenanceLedger;
                RunObject = Page "Preventive Maintenance Orders";
            }
            action(Spares2)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Spares';
                Image = Components;
                RunObject = Page "Item List";
                RunPageView = SORTING("Item Type", "Item Category Code")
                              WHERE("Item Type" = CONST(Spare));
            }
            group(Tasks)
            {
                Caption = 'Tasks';
                action(WorkOrderSchedule)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Work Order Schedule';
                    Image = CalculatePlan;
                    RunObject = Page "Work Order Schedule";
                }
                action(PMWorksheet)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'PM Worksheet';
                    Image = OpenWorksheet;
                    RunObject = Page "PM Worksheet Names";
                }
            }
            group(Journals)
            {
                Caption = 'Journals';
                action(LaborJournal)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Labor Journal';
                    Image = Journals;
                    RunObject = Page "Maintenance Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(Labor));
                }
                action(MaterialJournal)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Material Journal';
                    Image = Journals;
                    RunObject = Page "Maintenance Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(Material));
                }
                action(ContractJournal)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Contract Journal';
                    Image = Journals;
                    RunObject = Page "Maintenance Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(Contract));
                }
                action(MaintenanceJournal)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Maintenance Journal';
                    Image = Journals;
                    RunObject = Page "Maintenance Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(Maintenance));
                }
            }
            group(Administration)
            {
                Caption = 'Administration';
                action("Maintenance Setup")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Maintenance Setup';
                    Image = Setup;
                    RunObject = Page "Maintenance Setup";
                }
                action("AssetCategories")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Asset Categories';
                    Image = Category;
                    RunObject = page "Asset Categories";
                }
                action("MaintenanceTrades")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Maintenance Trades';
                    Image = Employee;
                    RunObject = page "Maintenance Trades";
                }
                action("WorkOrderFaultCodes")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Work Order Fault Codes';
                    Image = CodesList;
                    RunObject = page "Work Order Fault Codes";
                }
                action("WorkOrderCauseCodes")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Work Order Cause Codes';
                    Image = CodesList;
                    RunObject = page "Work Order Cause Codes";
                }
                action("WorkOrderActionCodes")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Work Order Action Codes';
                    Image = CodesList;
                    RunObject = page "Work Order Action Codes";
                }
                action("PMFrequencies")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'PM Frequencies';
                    Image = Refresh;
                    RunObject = page "PM Frequencies";
                }
                action("ReportSelectionMaintenance")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Report Selection';
                    Image = SelectReport;
                    RunObject = page "Report Selection - Maintenance";
                }
            }
            group(History)
            {
                Caption = 'History';
                Image = History;
                action("Completed Work Orders")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Completed Work Orders';
                    Image = Completed;
                    RunObject = Page "Completed Work Order List";
                }
                action("Maintenance Registers")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Maintenance Registers';
                    Image = Register;
                    RunObject = Page "Maintenance Registers";
                }
                action(Navigate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Navigate';
                    Image = Navigate;
                    RunObject = Page Navigate;
                    ShortCutKey = 'Ctrl+Alt+Q';
                }
            }
        }
        area(reporting)
        {
            group(AssetReports)
            {
                Caption = 'Assets';
                action("Asset List")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Asset List';
                    Image = List;
                    RunObject = Report "Asset List";
                }
                action("Asset Cost Summary")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Asset Cost Summary';
                    Image = Costs;
                    RunObject = Report "Asset Cost Summary";
                }
                action("Asset History")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Asset History';
                    Image = History;
                    RunObject = Report "Asset History";
                }
            }
            group(PMReports)
            {
                Caption = 'Preventive Maintenance';
                action("PM Master Schedule")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'PM Master Schedule';
                    Image = Timesheet;
                    RunObject = Report "PM Master Schedule";
                }
                action("PM Past Due")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'PM Past Due';
                    Image = DueDate;
                    RunObject = Report "PM Past Due";
                }
            }
            group(WorkOrderReports)
            {
                Caption = 'Work Orders';
                action("Work Order Summary")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Work Order Summary';
                    Image = FiledOverview;
                    RunObject = Report "Work Order Summary";
                }
                action("Work Order History")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Work Order History';
                    Image = History;
                    RunObject = Report "Work Order History";
                }
            }
        }
    }
}

