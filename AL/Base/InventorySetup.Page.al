page 461 "Inventory Setup"
{
    // PR3.10
    //   Add fields for alternate unit of measure
    // 
    // PR3.10.P
    //   Sales Pricing - Add Def. Price Rounding Method, Price Selection Priority
    // 
    // PR3.61
    //   Add fields
    //     Offsite Cont. Location
    //     Container IDs
    //     Blank Captoins (Non Alt. Qty.)
    // 
    // PR3.70.07
    // P8000140A, Myers Nissi, Jack Reynolds, 19 NOV 04
    //   Add controls for Container Usage Doc. Nos.
    // 
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Add controls for lot specification shortcuts
    // 
    // PR4.00
    // P8000260A, Myers Nissi, Jack Reynolds, 27 OCT 05
    //   Add controls for Production Costing Method
    // 
    // PR4.00.01
    // P8000267B, VerticalSoft, Jack Reynolds, 12 DEC 05
    //   Remove control for "Produciton Costing Method"
    // 
    // PR4.00.04
    // P8000375A, VerticalSoft, Jack Reynolds, 07 SEP 06
    //   Controls for ABC Detail Posting
    // 
    // PR4.00.06
    // P8000496A, VerticalSoft, Jack Reynolds, 23 JUL 07
    //   Add controls for Repack Order Nos. (Numbering tab) and Default Repack Location (Location tab)
    // 
    // PRW15.00.01
    // P8000548A, VerticalSoft, Don Bresee, 05 MAR 08
    //   Add new field - Near-Zero Qty. Value
    // 
    // PRW16.00.04
    // P8000856, VerticalSoft, Don Bresee, 24 AUG 10
    //   Add Commodity Class Costing granule
    // 
    // P8000891, VerticalSoft, Don Bresee, 04 JAN 11
    //   Add Commodity Receiving logic
    // 
    // PRW16.00.05
    // P8000979, Columbus IT, Don Bresee, 08 NOV 11
    //   Add Lot Trace Summary Level
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001070, Columbus IT, Jack Reynolds, 16 MAY 12
    //   Lot Preference Enforcement Level
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // PRW17.00.10
    // P8001227, Columbus IT, Don Bresee, 03 OCT 13
    //   Add new fields for Adjust Cost Job options
    // 
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW111.00.01
    // P80037569, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Assign new activity no. to Q/C activities
    // 
    // P80062661, To-Increase, Jack Reynolds, 25 JUL 18
    //   SSCC
    //
    // PRW119.03
    // P800122712, To Increase, Gangabhushan, 25 MAY 22
    //   Quality Control Samples, Fields added

    ApplicationArea = Basic, Suite;
    Caption = 'Inventory Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,General,Posting,Journal Templates';
    SourceTable = "Inventory Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Automatic Cost Posting"; "Automatic Cost Posting")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if value entries are automatically posted to the inventory account, adjustment account, and COGS account in the general ledger when an item transaction is posted. Alternatively, you can manually post the values at regular intervals with the Post Inventory Cost to G/L batch job. Note that costs must be adjusted before posting to the general ledger.';
                }
                field("Expected Cost Posting to G/L"; "Expected Cost Posting to G/L")
                {
                    ApplicationArea = Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies if value entries originating from receipt or shipment posting, but not from invoice posting are recoded in the general ledger. Expected costs represent the estimation of, for example, a purchased item''s cost that you record before you receive the invoice for the item. To post expected costs, interim accounts must exist in the general ledger for the relevant posting groups. Expected costs are only managed for item transactions, not for immaterial transaction types, such as capacity and item charges.';
                }
                field("ABC Detail Posting"; "ABC Detail Posting")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Automatic Cost Adjustment"; "Automatic Cost Adjustment")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if item value entries are automatically adjusted when an item transaction is posted. This ensures correct inventory valuation in the general ledger, so that sales and profit statistics are up to date. The cost adjustment forwards any cost changes from inbound entries, such as those for purchases or production output, to the related outbound entries, such as sales or transfers. To minimize reduced performance during posting, select a time option to define how far back in time from the work date an inbound transaction can occur to potentially trigger adjustment of related outbound value entries. Alternatively, you can manually adjust costs at regular intervals with the Adjust Cost - Item Entries batch job.';
                }
                field("Default Costing Method"; "Default Costing Method")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how your items'' cost flow is recorded and whether an actual or budgeted value is capitalized and used in the cost calculation. Your choice of costing method determines how the unit cost is calculated by making assumptions about the flow of physical items through your company. A different costing method on item cards will override this default. For more information, see "Design Details: Costing Methods" in Help.';
                }
                field("Average Cost Calc. Type"; "Average Cost Calc. Type")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies how costs are calculated for items using the Average costing method. Item: One average cost per item in the company is calculated. Item & Location & Variant: An average cost per item for each location and for each variant of the item in the company is calculated. This means that the average cost of this item depends on where it is stored and which variant, such as color, of the item you have selected.';
                }
                field("Average Cost Period"; "Average Cost Period")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    OptionCaption = ',Day,Week,Month,,,Accounting Period';
                    ToolTip = 'Specifies the period of time used to calculate the weighted average cost of items that apply the average costing method. All inventory decreases that were posted within an average cost period will receive the average cost calculated for that period. If you change the average cost period, only open fiscal years will be affected.';
                }
                field("Copy Comments Order to Shpt."; "Copy Comments Order to Shpt.")
                {
                    ApplicationArea = Comments;
                    Importance = Additional;
                    ToolTip = 'Specifies that you want the program to copy the comments entered on the transfer order to the transfer shipment.';
                }
                field("Copy Comments Order to Rcpt."; "Copy Comments Order to Rcpt.")
                {
                    ApplicationArea = Comments;
                    Importance = Additional;
                    ToolTip = 'Specifies that you want the program to copy the comments entered on the transfer order to the transfer receipt.';
                }
                field("Outbound Whse. Handling Time"; "Outbound Whse. Handling Time")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTip = 'Specifies a date formula that calculates the time it takes to get items ready to ship. The time element is used to calculate the delivery date as follows: Shipment Date + Outbound Warehouse Handling Time = Planned Shipment Date + Shipping Time = Planned Delivery Date.';
                }
                field("Inbound Whse. Handling Time"; "Inbound Whse. Handling Time")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTip = 'Specifies a date formula that calculates the time it takes to make items available in inventory after they have been received. The time element is used to calculate the expected receipt date as follows: Order Date + Lead Time Calculation = Planned Receipt Date + Inbound Warehouse Handling Time + Safety Lead Time = Expected Receipt Date.';
                }
                field("Prevent Negative Inventory"; "Prevent Negative Inventory")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if you can post transactions that will bring inventory levels below zero.';
                }
                field("Skip Prompt to Create Item"; "Skip Prompt to Create Item")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if a message about creating a new item card appears when you enter an item number that does not exist.';
                }
                field("Copy Item Descr. to Entries"; "Copy Item Descr. to Entries")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if you want the description on item cards to be copied to item ledger entries during posting.';
                }
                field("Allow Invt. Doc. Reservation"; "Allow Invt. Doc. Reservation")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if you want to allow reservation for inventory receipts and shipments.';
                    Visible = false;
                }
#if not CLEAN19
                field("Use Item References"; Rec."Use Item References")
                {
                    ApplicationArea = Suite, ItemReferences;
                    ObsoleteReason = 'Replaced by default visibility for Item Reference''s fields and actions.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '19.0';
                    ToolTip = 'Specifies if you want to use item references in purchase and sales documents.';
                    Visible = false;
                }
#endif
                field("Measuring System"; "Measuring System")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Def. Price Rounding Method"; "Def. Price Rounding Method")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Price Selection Priority"; "Price Selection Priority")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Allergen Cons. Enforcement Lvl"; "Allergen Cons. Enforcement Lvl")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Near-Zero Qty. Value"; "Near-Zero Qty. Value")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Adjust Cost - Post to G/L"; "Adjust Cost - Post to G/L")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Additional;
                }
                field("Adjust Cost - Lock Time (s)"; "Adjust Cost - Lock Time (s)")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Additional;
                }
                field("Adjust Cost - Unlock Time (ms)"; "Adjust Cost - Unlock Time (ms)")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Additional;
                }
                field("Commodity Cost by Location"; "Commodity Cost by Location")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Additional;
                }
                field("Commodity UOM Type"; "Commodity UOM Type")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Additional;
                }
                field("Comm. Cost Rounding Precision"; "Comm. Cost Rounding Precision")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Additional;
                }
                field("Cost Adjust on Comm. Post"; "Cost Adjust on Comm. Post")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Additional;
                }
            }
            group(Location)
            {
                Caption = 'Location';
                field("Location Mandatory"; "Location Mandatory")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies if a location code is required when posting item transactions. This field, together with the Components at Location field in the Manufacturing Setup window, is very important in governing how the planning system handles demand lines with/without location codes. For more information, see "Planning with or without Locations" in Help.';
                }
                field("Default Repack Location"; "Default Repack Location")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Dimensions)
            {
                Caption = 'Dimensions';
                field("Item Group Dimension Code"; "Item Group Dimension Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the dimension code that you want to use for product groups in analysis reports.';
                }
                field("Package Caption"; "Package Caption")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the alternative caption of Package tracking dimension that you want to use for captions for this dimension. For example, Size.';
                    Visible = PackageVisible;
                }
            }
            group(Numbering)
            {
                Caption = 'Numbering';
                field("Item Nos."; "Item Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to items.';
                }
                field("Nonstock Item Nos."; "Nonstock Item Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Catalog Item Nos.';
                    Importance = Additional;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to catalog items.';
                }
                field("Unapproved Item Nos."; "Unapproved Item Nos.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Container IDs"; "Container IDs")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Transfer Order Nos."; "Transfer Order Nos.")
                {
                    ApplicationArea = Location;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to transfer orders.';
                }
                field("Posted Transfer Shpt. Nos."; "Posted Transfer Shpt. Nos.")
                {
                    ApplicationArea = Location;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to posted transfer shipments.';
                }
                field("Posted Transfer Rcpt. Nos."; "Posted Transfer Rcpt. Nos.")
                {
                    ApplicationArea = Location;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to posted transfer receipts.';
                }
                field("Posted Direct Trans. Nos."; "Posted Direct Trans. Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number series from which numbers are assigned to new records.';
                }
                field("Direct Transfer Posting"; "Direct Transfer Posting")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if Direct Transfer should be posted separately as Shipment and Receipt or as single Direct Transfer document.';
                }
                field("Container Usage Doc. Nos."; "Container Usage Doc. Nos.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Inventory Put-away Nos."; "Inventory Put-away Nos.")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to inventory put-always.';
                }
                field("Posted Invt. Put-away Nos."; "Posted Invt. Put-away Nos.")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to posted inventory put-always.';
                }
                field("Inventory Pick Nos."; "Inventory Pick Nos.")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to inventory picks.';
                }
                field("Posted Invt. Pick Nos."; "Posted Invt. Pick Nos.")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to posted inventory picks.';
                }
                field("Inventory Movement Nos."; "Inventory Movement Nos.")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to inventory movements.';
                }
                field("Registered Invt. Movement Nos."; "Registered Invt. Movement Nos.")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to registered inventory movements.';
                }
                field("Internal Movement Nos."; "Internal Movement Nos.")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to internal movements.';
                }
                field("Phys. Invt. Order Nos."; "Phys. Invt. Order Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to physical inventory orders.';
                }
                field("Posted Phys. Invt. Order Nos."; "Posted Phys. Invt. Order Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to physical inventory orders when they are posted.';
                }
                field("Invt. Receipt Nos."; Rec."Invt. Receipt Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series from which numbers are assigned to new records.';
                }
                field("Posted Invt. Receipt Nos."; Rec."Posted Invt. Receipt Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series from which numbers are assigned to new records.';
                }
                field("Invt. Shipment Nos."; Rec."Invt. Shipment Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series from which numbers are assigned to new records.';
                }
                field("Posted Invt. Shipment Nos."; Rec."Posted Invt. Shipment Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series from which numbers are assigned to new records.';
                }
                field("Package Nos."; Rec."Package Nos.")
                {
                    ApplicationArea = ItemTracking;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to item tracking packages.';
                    Visible = PackageVisible;
                }
                field("Repack Order Nos."; "Repack Order Nos.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Commodity Manifest Nos."; "Commodity Manifest Nos.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Posted Comm. Manifest Nos."; "Posted Comm. Manifest Nos.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Comm. Rcpt. Lot Nos."; "Comm. Rcpt. Lot Nos.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Chg. Lot Status Document Nos."; "Chg. Lot Status Document Nos.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Q/C Activity Nos."; "Q/C Activity Nos.")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group("Alternate Units")
            {
                Caption = 'Alternate Units';
                field("Sale Alt. Qty. Default"; "Sale Alt. Qty. Default")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Purch. Alt. Qty. Default"; "Purch. Alt. Qty. Default")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Pos. Adj. Alt. Qty. Default"; "Pos. Adj. Alt. Qty. Default")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Neg. Adj. Alt. Qty. Default"; "Neg. Adj. Alt. Qty. Default")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Phys. Count Alt. Qty. Default"; "Phys. Count Alt. Qty. Default")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Transfer Alt. Qty. Default"; "Transfer Alt. Qty. Default")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Consumption Alt. Qty. Default"; "Consumption Alt. Qty. Default")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Output Alt. Qty. Default"; "Output Alt. Qty. Default")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Default Alt. Qty. Tolerance %"; "Default Alt. Qty. Tolerance %")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Blank Captions (Non Alt. Qty.)"; "Blank Captions (Non Alt. Qty.)")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Lots)
            {
                Caption = 'Lots';
                field("Lot Trace Summary Level"; "Lot Trace Summary Level")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot Pref. Enforcement Level"; "Lot Pref. Enforcement Level")
                {
                    ApplicationArea = FOODBasic;
                }
                group(Specifications)
                {
                    Caption = 'Specifications';
                    field("Shortcut Lot Spec. 1 Code"; "Shortcut Lot Spec. 1 Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Shortcut 1';
                    }
                    field("Shortcut Lot Spec. 2 Code"; "Shortcut Lot Spec. 2 Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Shortcut 2';
                    }
                    field("Shortcut Lot Spec. 3 Code"; "Shortcut Lot Spec. 3 Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Shortcut 3';
                    }
                    field("Shortcut Lot Spec. 4 Code"; "Shortcut Lot Spec. 4 Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Shortcut 4';
                    }
                    field("Shortcut Lot Spec. 5 Code"; "Shortcut Lot Spec. 5 Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Shortcut 5';
                    }
                }
                group("Quality Control")
                {
                    Caption = 'Quality Control';
                    field("All Q/C Tests Must Be Done"; "All Q/C Tests Must Be Done")
                    {
                        ApplicationArea = FOODBasic;
                        MultiLine = true;
                    }
                    field("Add Q/C Tests for Phys. Count"; "Add Q/C Tests for Phys. Count")
                    {
                        ApplicationArea = FOODBasic;
                        MultiLine = true;
                    }
                }
                // P800122712
                group(QCSample)
                {
                    Caption = 'Quality Control Samples';
                    field("Samples Enabled"; Rec."Samples Enabled")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("No Sample Warning"; Rec."Suppress Sample Warning")
                    {
                        ApplicationArea = FOODBasic;
                        Enabled = Rec."Samples Enabled";
                    }
                    field("Sample Default Reason Code"; Rec."Default Sample Reason Code")
                    {
                        ApplicationArea = FOODBasic;
                        Enabled = Rec."Samples Enabled";
                    }
                    field("Sample Document No. Series"; Rec."Sample Document No. Series")
                    {
                        ApplicationArea = FOODBasic;
                        Enabled = Rec."Samples Enabled";
                    }
                }
                // P800122712                
                group("Default Lot Status")
                {
                    Caption = 'Default Lot Status';
                    field("Quarantine Lot Status"; "Quarantine Lot Status")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Quarantine';
                    }
                    field("Quality Control Lot Status"; "Quality Control Lot Status")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Quality Control';
                    }
                    field("Quality Ctrl. Fail Lot Status"; "Quality Ctrl. Fail Lot Status")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Quality Control Failure';
                    }
                    field("Sales Lot Status"; "Sales Lot Status")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Sales';
                    }
                    field("Purchase Lot Status"; "Purchase Lot Status")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Purchase';
                    }
                    field("Output Lot Status"; "Output Lot Status")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Output';
                    }
                }
            }
            group(Containers)
            {
                Caption = 'Containers';
                field("SSCC Extension Digit"; "SSCC Extension Digit")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Offsite Cont. Location Code"; "Offsite Cont. Location Code")
                {
                    ApplicationArea = FOODBasic;
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
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Schedule Cost Adjustment and Posting")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Schedule Cost Adjustment and Posting';
                Image = AdjustItemCost;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                Visible = AdjustCostWizardVisible;
                ToolTip = 'Get help with creating job queue entries for item entry cost adjustments and posting costs to G/L tasks.';
                trigger OnAction()
                begin
                    Page.RunModal(Page::"Cost Adj. Scheduling Wizard");
                end;
            }
            action("Inventory Periods")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Inventory Periods';
                Image = Period;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "Inventory Periods";
                ToolTip = 'Set up periods in combinations with your accounting periods that define when you can post transactions that affect the value of your item inventory. When you close an inventory period, you cannot post any changes to the inventory value, either expected or actual value, before the ending date of the inventory period.';
            }
            action("Units of Measure")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Units of Measure';
                Image = UnitOfMeasure;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "Units of Measure";
                ToolTip = 'Set up the units of measure, such as PSC or HOUR, that you can select from in the Item Units of Measure window that you access from the item card.';
            }
            action("Item Discount Groups")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Item Discount Groups';
                Image = Discount;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "Item Disc. Groups";
                ToolTip = 'Set up discount group codes that you can use as criteria when you define special discounts on a customer, vendor, or item card.';
            }
            action("Import Item Pictures")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Import Item Pictures';
                Image = Import;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "Import Item Pictures";
                ToolTip = 'Import item pictures from a ZIP file.';
            }
            group(Posting)
            {
                Caption = 'Posting';
                action("Inventory Posting Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Inventory Posting Setup';
                    Image = PostedInventoryPick;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Page "Inventory Posting Setup";
                    ToolTip = 'Set up links between inventory posting groups, inventory locations, and general ledger accounts to define where transactions for inventory items are recorded in the general ledger.';
                }
                action("Inventory Posting Groups")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Inventory Posting Groups';
                    Image = ItemGroup;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Page "Inventory Posting Groups";
                    ToolTip = 'Set up the posting groups that you assign to item cards to link business transactions made for the item with an inventory account in the general ledger to group amounts for that item type.';
                }
            }
            group("Journal Templates")
            {
                Caption = 'Journal Templates';
                action("Item Journal Templates")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Item Journal Templates';
                    Image = JournalSetup;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedIsBig = true;
                    RunObject = Page "Item Journal Templates";
                    ToolTip = 'Set up number series and reason codes in the journals that you use for inventory adjustment. By using different templates you can design windows with different layouts and you can assign trace codes, number series, and reports to each template.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        SetPackageVisibility();
        SetAdjustCostWizardActionVisibility();

    end;

    var
        PackageMgt: Codeunit "Package Management";
        SchedulingManager: Codeunit "Cost Adj. Scheduling Manager";
        [InDataSet]
        PackageVisible: Boolean;
        AdjustCostWizardVisible: Boolean;

    local procedure SetPackageVisibility()
    begin
        PackageVisible := PackageMgt.IsEnabled();
    end;

    local procedure SetAdjustCostWizardActionVisibility()
    begin
        if (Rec."Automatic Cost Posting" = False) and (not SchedulingManager.PostInvCostToGLJobQueueExists()) or
           (Rec."Automatic Cost Adjustment" = Rec."Automatic Cost Adjustment"::Never) and (not SchedulingManager.AdjCostJobQueueExists()) then
            AdjustCostWizardVisible := true;
    end;
}

