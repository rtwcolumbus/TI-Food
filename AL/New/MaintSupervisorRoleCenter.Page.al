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

    Caption = 'Maintenance Supervisor';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
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
            action("PM Worksheets")
            {
                ApplicationArea = FOODBasic;
                Caption = 'PM Worksheets';
                Image = OpenWorksheet;
                RunObject = Page "PM Worksheet Names";
            }
        }
        area(sections)
        {
            group(Journals)
            {
                Caption = 'Journals';
                Image = Journals;
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
            }
            group(Administration)
            {
                Caption = 'Administration';
                Image = Administration;
                action(Trades)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Trades';
                    Image = Purchasing;
                    RunObject = Page "Maintenance Trades";
                }
                action("PM Frequencies")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'PM Frequencies';
                    Image = Timeline;
                    RunObject = Page "PM Frequencies";
                }
            }
        }
        area(processing)
        {
            separator(New)
            {
                Caption = 'New';
                IsHeader = true;
            }
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
            separator(Tasks)
            {
                Caption = 'Tasks';
                IsHeader = true;
            }
            action(Action1102603043)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Labor Journal';
                Image = Journals;
                RunObject = Page "Maintenance Journal Batches";
                RunPageView = WHERE("Template Type" = CONST(Labor));
            }
            action(Action1102603044)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Material Journal';
                Image = Journals;
                RunObject = Page "Maintenance Journal Batches";
                RunPageView = WHERE("Template Type" = CONST(Material));
            }
            action(Action1102603045)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Contract Journal';
                Image = Journals;
                RunObject = Page "Maintenance Journal Batches";
                RunPageView = WHERE("Template Type" = CONST(Contract));
            }
            action(Action37002005)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Maintenance Journal';
                Image = Journals;
                RunObject = Page "Maintenance Journal Batches";
                RunPageView = WHERE("Template Type" = CONST(Maintenance));
            }
            separator(Separator1102603046)
            {
            }
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
            separator(Separator37002001)
            {
                Caption = 'Administration';
                IsHeader = true;
            }
            action("Maintenance Setup")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Maintenance Setup';
                Image = Setup;
                RunObject = Page "Maintenance Setup";
            }
            separator(Separator1102603054)
            {
                Caption = 'History';
                IsHeader = true;
            }
            action(Navigate)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Navigate';
                Image = Navigate;
                RunObject = Page Navigate;
            }
        }
        area(reporting)
        {
            action("Asset List")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Asset List';
                Image = List;
                RunObject = Report "Asset List";
            }
            action("PM Master Schedule")
            {
                ApplicationArea = FOODBasic;
                Caption = 'PM Master Schedule';
                Image = Timesheet;
                RunObject = Report "PM Master Schedule";
            }
            separator(Separator1102603035)
            {
            }
            action("PM Past Due")
            {
                ApplicationArea = FOODBasic;
                Caption = 'PM Past Due';
                Image = DueDate;
                RunObject = Report "PM Past Due";
            }
            separator(Separator1102603033)
            {
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

