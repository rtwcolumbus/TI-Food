page 99000867 "Finished Production Order"
{
    // PR2.00.05
    //   Variant Code
    // 
    // PR3.60
    //   Co/By-Products
    // 
    // PR3.61
    //   Add functions menu button with item to create containers
    // 
    // PR3.70.06
    // P8000081A, Myers Nissi, Jack Reynolds, 04 AUG 04
    //   Add Print menu button with item to print summary report
    // 
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add "Bin Code" to containers
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001098, Columbus IT, Jack Reynolds, 27 SEP 12
    //   Fix problem with Create Containers
    // 
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.00
    // P8001233, Columbus IT, Jack Reynolds, 24 OCT 13
    //   Support for label worksheet
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds 10 JAN 17
    //   Move Data Sheets action

    Caption = 'Finished Production Order';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,Order';
    RefreshOnActivate = true;
    SourceTable = "Production Order";
    SourceTableView = WHERE(Status = CONST(Finished));

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    Importance = Promoted;
                    Lookup = false;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the description of the production order.';
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies an additional part of the production order description.';
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the source type of the production order.';
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the item number or number of the source document that the entry originates from.';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the variant code for production order item.';
                    Visible = false;
                }
                field("Search Description"; "Search Description")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the search description.';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies how many units of the item or the family to produce (production quantity).';
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the due date of the production order.';
                }
                field("Last Date Modified"; "Last Date Modified")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies when the production order card was last modified.';
                }
            }
            part(ProdOrderLines; "Finished Prod. Order Lines")
            {
                ApplicationArea = Manufacturing;
                SubPageLink = "Prod. Order No." = FIELD("No.");
                UpdatePropagation = Both;
            }
            group(Schedule)
            {
                Caption = 'Schedule';
#if not CLEAN17
                field("Starting Time"; StartingTime)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Starting Time';
                    Editable = false;
                    Importance = Promoted;
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
                    Editable = false;
                    Importance = Promoted;
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
                    Editable = false;
                    Importance = Promoted;
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
                    Editable = false;
                    Importance = Promoted;
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
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the starting date and starting time of the production order.';
                }
                field("Ending Date-Time"; "Ending Date-Time")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the ending date and ending time of the production order.';
                }
            }
            group(Posting)
            {
                Caption = 'Posting';
                field("Inventory Posting Group"; "Inventory Posting Group")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies links between business transactions made for the item and an inventory account in the general ledger, to group amounts for that item type.';
                }
                field("Gen. Prod. Posting Group"; "Gen. Prod. Posting Group")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the item''s product type to link transactions made for this item with the appropriate general ledger account according to the general posting setup.';
                }
                field("Gen. Bus. Posting Group"; "Gen. Bus. Posting Group")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the vendor''s or customer''s trade type to link transactions made for this business partner with the appropriate general ledger account according to the general posting setup.';
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    Editable = false;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    Editable = false;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = Location;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the location code to which you want to post the finished product from this production order.';
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
            group("O&rder")
            {
                Caption = 'O&rder';
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
                    Promoted = true;
                    PromotedCategory = Category4;
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
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        ShowDocDim;
                    end;
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
                action(Statistics)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "Production Order Statistics";
                    RunPageLink = Status = FIELD(Status),
                                  "No." = FIELD("No."),
                                  "Date Filter" = FIELD("Date Filter");
                    ShortCutKey = 'F7';
                    ToolTip = 'View statistical information, such as the value of posted entries, for the record.';
                }
                action("Registered P&ick Lines")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Registered P&ick Lines';
                    Image = RegisteredDocs;
                    RunObject = Page "Registered Whse. Act.-Lines";
                    RunPageLink = "Source Type" = CONST(5407),
                                  "Source Subtype" = CONST("3"),
                                  "Source No." = FIELD("No.");
                    RunPageView = SORTING("Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.");
                    ToolTip = 'View the list of warehouse picks that have been made for the order.';
                }
                action("<Action2>")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Registered Invt. M&ovement Lines';
                    Image = RegisteredDocs;
                    RunObject = Page "Reg. Invt. Movement Lines";
                    RunPageLink = "Source Type" = CONST(5407),
                                  "Source Subtype" = CONST("3"),
                                  "Source No." = FIELD("No.");
                    RunPageView = SORTING("Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.");
                    ToolTip = 'View the list of inventory movements that have been made for the order.';
                }
                separator(Separator37002002)
                {
                }
            }
        }
        area(processing)
        {
            group("&Print")
            {
                Caption = '&Print';
                action(Summary)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Summary';
                    Ellipsis = true;
                    Image = FiledOverview;

                    trigger OnAction()
                    var
                        ProdOrder: Record "Production Order";
                    begin
                        // P8000081A
                        ProdOrder := Rec;
                        ProdOrder.SetRecFilter;
                        REPORT.Run(REPORT::"Production Order Summary", true, false, ProdOrder);
                    end;
                }
                action("Print Labels")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Print Labels';
                    Ellipsis = true;
                    Image = Price;

                    trigger OnAction()
                    begin
                        // P8001047
                        PrintLabels;
                    end;
                }
                action("Shared &Components")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Shared &Components';
                    Image = Components;
                    RunObject = Page "Prod. Order Components";
                    RunPageLink = Status = FIELD(Status),
                                  "Prod. Order No." = FIELD("No.");
                    RunPageView = SORTING(Status, "Prod. Order No.", "Prod. Order Line No.", "Line No.")
                                  WHERE("Prod. Order Line No." = CONST(0));
                }
                separator(Separator1102603003)
                {
                }
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

    var
        StartingTime: Time;
        EndingTime: Time;
        StartingDate: Date;
        EndingDate: Date;
        DateAndTimeFieldVisible: Boolean;
#endif
}

