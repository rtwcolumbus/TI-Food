page 9326 "Released Production Orders"
{
    // PRW16.00.06
    // P8001098, Columbus IT, Jack Reynolds, 27 SEP 12
    //   Add action to Create Containers
    // 
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names

    ApplicationArea = Manufacturing;
    Caption = 'Released Production Orders';
    CardPageID = "Released Production Order";
    Editable = false;
    PageType = List;
    SourceTable = "Production Order";
    SourceTableView = WHERE(Status = CONST(Released));
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = Manufacturing;
                    Lookup = false;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the description of the production order.';
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number of the source document that the entry originates from.';
                }
                field("Routing No."; "Routing No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the routing number used for this production order.';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies how many units of the item or the family to produce (production quantity).';
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the location code to which you want to post the finished product from this production order.';
                    Visible = false;
                }
#if not CLEAN17
                field("Starting Time"; StartingTime)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Starting Time';
                    ToolTip = 'Specifies the starting time of the production order.';
                    Visible = DateAndTimeFieldVisible;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Starting Date-Time field should be used instead.';
                    ObsoleteTag = '17.0';
                }
                field("Starting Date"; StartingDate)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Starting Date';
                    ToolTip = 'Specifies the starting date of the production order.';
                    Visible = DateAndTimeFieldVisible;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Starting Date-Time field should be used instead.';
                    ObsoleteTag = '17.0';
                }
                field("Ending Time"; EndingTime)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Ending Time';
                    ToolTip = 'Specifies the ending time of the production order.';
                    Visible = DateAndTimeFieldVisible;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Ending Date-Time field should be used instead.';
                    ObsoleteTag = '17.0';
                }
                field("Ending Date"; EndingDate)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Ending Date';
                    ToolTip = 'Specifies the ending date of the production order.';
                    Visible = DateAndTimeFieldVisible;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Ending Date-Time field should be used instead.';
                    ObsoleteTag = '17.0';
                }
#endif
                field("Starting Date-Time"; "Starting Date-Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the starting date and starting time of the production order.';
                }
                field("Ending Date-Time"; "Ending Date-Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the ending date and ending time of the production order.';
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the due date of the production order.';
                }
                field("Assigned User ID"; "Assigned User ID")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the ID of the user who is responsible for the document.';
                }
                field("Finished Date"; "Finished Date")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the actual finishing date of a finished production order.';
                    Visible = false;
                }
                field(Status; Status)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the status of the production order.';
                }
                field("Search Description"; "Search Description")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the search description.';
                }
                field("Last Date Modified"; "Last Date Modified")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies when the production order card was last modified.';
                    Visible = false;
                }
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies a bin to which you want to post the finished items.';
                    Visible = false;
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
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Pro&d. Order")
            {
                Caption = 'Pro&d. Order';
                Image = "Order";
                group("E&ntries")
                {
                    Caption = 'E&ntries';
                    Image = Entries;
                    action("Item Ledger E&ntries")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Item Ledger E&ntries';
                        Image = ItemLedger;
                        RunObject = Page "Item Ledger Entries";
                        RunPageLink = "Order Type" = CONST(Production),
                                      "Order No." = FIELD("No.");
                        RunPageView = SORTING("Order Type", "Order No.");
                        ShortCutKey = 'Ctrl+F7';
                        ToolTip = 'View the item ledger entries of the item on the document or journal line.';
                    }
                    action("Capacity Ledger Entries")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Capacity Ledger Entries';
                        Image = CapacityLedger;
                        RunObject = Page "Capacity Ledger Entries";
                        RunPageLink = "Order Type" = CONST(Production),
                                      "Order No." = FIELD("No.");
                        RunPageView = SORTING("Order Type", "Order No.");
                        ToolTip = 'View the capacity ledger entries of the involved production order. Capacity is recorded either as time (run time, stop time, or setup time) or as quantity (scrap quantity or output quantity).';
                    }
                    action("Value Entries")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Value Entries';
                        Image = ValueLedger;
                        RunObject = Page "Value Entries";
                        RunPageLink = "Order Type" = CONST(Production),
                                      "Order No." = FIELD("No.");
                        RunPageView = SORTING("Order Type", "Order No.");
                        ToolTip = 'View the value entries of the item on the document or journal line.';
                    }
                    action("&Warehouse Entries")
                    {
                        ApplicationArea = Warehouse;
                        Caption = '&Warehouse Entries';
                        Image = BinLedger;
                        RunObject = Page "Warehouse Entries";
                        RunPageLink = "Source Type" = FILTER(83 | 5407),
                                      "Source Subtype" = FILTER("3" | "4" | "5"),
                                      "Source No." = FIELD("No.");
                        RunPageView = SORTING("Source Type", "Source Subtype", "Source No.");
                        ToolTip = 'View the history of quantities that are registered for the item in warehouse activities. ';
                    }
                }
                action("Co&mments")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Prod. Order Comment Sheet";
                    RunPageLink = Status = FIELD(Status),
                                  "Prod. Order No." = FIELD("No.");
                    ToolTip = 'View or add comments for the record.';
                }
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        ShowDocDim;
                    end;
                }
                action(Statistics)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Production Order Statistics";
                    RunPageLink = Status = FIELD(Status),
                                  "No." = FIELD("No."),
                                  "Date Filter" = FIELD("Date Filter");
                    ShortCutKey = 'F7';
                    ToolTip = 'View statistical information, such as the value of posted entries, for the record.';
                }
                separator(Separator37002002)
                {
                }
                action("Data Sheets")
                {
                    AccessByPermission = TableData "Data Sheet Header" = R;
                    ApplicationArea = FOODBasic;
                    Caption = 'Data Sheets';
                    Ellipsis = true;
                    Image = EntriesList;

                    trigger OnAction()
                    var
                        DataCollectionMgmt: Codeunit "Data Collection Management";
                    begin
                        // P8001090
                        DataCollectionMgmt.DataSheetsForProdOrder(Rec);
                    end;
                }
            }
        }
        area(processing)
        {
            action("Print Labels")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Print Labels';
                Ellipsis = true;
                Image = Price;

                trigger OnAction()
                var
                    ProdOrder: Record "Production Order";
                    LabelWorksheetLine: Record "Label Worksheet Line" temporary;
                    ReceivingLabelMgmt: Codeunit "Label Worksheet Management";
                begin
                    // P8001047
                    CurrPage.SetSelectionFilter(ProdOrder);
                    ReceivingLabelMgmt.WorksheetLinesForProdOrder(ProdOrder, LabelWorksheetLine);
                    ReceivingLabelMgmt.RunWorksheet(LabelWorksheetLine);
                end;
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Change &Status")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Change &Status';
                    Ellipsis = true;
                    Image = ChangeStatus;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Codeunit "Prod. Order Status Management";
                    ToolTip = 'Change the production order to another status, such as Released.';
                }
                action("&Update Unit Cost")
                {
                    ApplicationArea = Manufacturing;
                    Caption = '&Update Unit Cost';
                    Ellipsis = true;
                    Image = UpdateUnitCost;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Update the cost of the parent item per changes to the production BOM or routing.';

                    trigger OnAction()
                    var
                        ProdOrder: Record "Production Order";
                    begin
                        ProdOrder.SetRange(Status, Status);
                        ProdOrder.SetRange("No.", "No.");

                        REPORT.RunModal(REPORT::"Update Unit Cost", true, true, ProdOrder);
                    end;
                }
                action("Create Inventor&y Put-away/Pick/Movement")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Create Inventor&y Put-away/Pick/Movement';
                    Ellipsis = true;
                    Image = CreatePutAway;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Prepare to create inventory put-aways, picks, or movements for the parent item or components on the production order.';

                    trigger OnAction()
                    begin
                        CreateInvtPutAwayPick;
                    end;
                }
            }
        }
        area(reporting)
        {
            action("Prod. Order - Detail Calc.")
            {
                ApplicationArea = Manufacturing;
                Caption = 'Prod. Order - Detail Calc.';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Prod. Order - Detailed Calc.";
                ToolTip = 'View a list of the production orders. This list contains the expected costs and the quantity per production order or per operation of a production order.';
            }
            action("Prod. Order - Precalc. Time")
            {
                ApplicationArea = Manufacturing;
                Caption = 'Prod. Order - Precalc. Time';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Prod. Order - Precalc. Time";
                ToolTip = 'View a list of information about capacity requirement, starting and ending time, etc. per operation, per production order, or per production order line.';
            }
            action("Production Order - Comp. and Routing")
            {
                ApplicationArea = Manufacturing;
                Caption = 'Production Order - Comp. and Routing';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Prod. Order Comp. and Routing";
                ToolTip = 'View information about components and operations in production orders. For released production orders, the report shows the remaining quantity if parts of the quantity have been posted as output.';
            }
            action(ProdOrderJobCard)
            {
                ApplicationArea = Manufacturing;
                Caption = 'Production Order Job Card';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                ToolTip = 'View a list of the work in progress of a production order. Output, Scrapped Quantity and Production Lead Time are shown or printed depending on the operation.';

                trigger OnAction()
                begin
                    ManuPrintReport.PrintProductionOrder(Rec, 0);
                end;
            }
            action("Production Order - Picking List")
            {
                ApplicationArea = Manufacturing;
                Caption = 'Production Order - Picking List';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Prod. Order - Picking List";
                ToolTip = 'View a detailed list of items that must be picked for a particular production order, from which location (and bin, if the location uses bins) they must be picked, and when the items are due for production.';
            }
            action(ProdOrderMaterialRequisition)
            {
                ApplicationArea = Manufacturing;
                Caption = 'Production Order - Material Requisition';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                ToolTip = 'View a list of material requirements per production order. The report shows you the status of the production order, the quantity of end items and components with the corresponding required quantity. You can view the due date and location code of each component.';

                trigger OnAction()
                begin
                    ManuPrintReport.PrintProductionOrder(Rec, 1);
                end;
            }
            action("Production Order List")
            {
                ApplicationArea = Manufacturing;
                Caption = 'Production Order List';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Prod. Order - List";
                ToolTip = 'View a list of the production orders contained in the system. Information such as order number, number of the item to be produced, starting/ending date and other data are shown or printed.';
            }
            action(ProdOrderShortageList)
            {
                ApplicationArea = Manufacturing;
                Caption = 'Production Order - Shortage List';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                ToolTip = 'View a list of the missing quantity per production order. You are shown how the inventory development is planned from today until the set day - for example whether orders are still open.';

                trigger OnAction()
                begin
                    ManuPrintReport.PrintProductionOrder(Rec, 2);
                end;
            }
            action("Production Order Statistics")
            {
                ApplicationArea = Manufacturing;
                Caption = 'Production Order Statistics';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Production Order Statistics";
                ToolTip = 'View statistical information about the production order''s direct material and capacity costs and overhead as well as its capacity need in the time unit of measure.';
            }
        }
    }
#if not CLEAN17
    trigger OnAfterGetRecord()
    begin
        GetStartingEndingDateAndTime(StartingTime, StartingDate, EndingTime, EndingDate);
    end;

    trigger OnInit()
    begin
        DateAndTimeFieldVisible := false;
    end;

    trigger OnOpenPage()
    begin
        DateAndTimeFieldVisible := false;
    end;
#endif

    var
        ManuPrintReport: Codeunit "Manu. Print Report";
#if not CLEAN17
        StartingTime: Time;
        EndingTime: Time;
        StartingDate: Date;
        EndingDate: Date;
        DateAndTimeFieldVisible: Boolean;
#endif
}

