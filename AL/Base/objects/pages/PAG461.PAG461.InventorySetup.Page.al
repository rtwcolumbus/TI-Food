﻿page 461 "Inventory Setup"
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
    SourceTable = "Inventory Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Automatic Cost Posting"; Rec."Automatic Cost Posting")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if value entries are automatically posted to the inventory account, adjustment account, and COGS account in the general ledger when an item transaction is posted. Alternatively, you can manually post the values at regular intervals with the Post Inventory Cost to G/L batch job. Note that costs must be adjusted before posting to the general ledger.';
                }
                field("Expected Cost Posting to G/L"; Rec."Expected Cost Posting to G/L")
                {
                    ApplicationArea = Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies if value entries originating from receipt or shipment posting, but not from invoice posting are recoded in the general ledger. Expected costs represent the estimation of, for example, a purchased item''s cost that you record before you receive the invoice for the item. To post expected costs, interim accounts must exist in the general ledger for the relevant posting groups. Expected costs are only managed for item transactions, not for immaterial transaction types, such as capacity and item charges.';
                }
                field("ABC Detail Posting"; Rec."ABC Detail Posting")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Automatic Cost Adjustment"; Rec."Automatic Cost Adjustment")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if item value entries are automatically adjusted when an item transaction is posted. This ensures correct inventory valuation in the general ledger, so that sales and profit statistics are up to date. The cost adjustment forwards any cost changes from inbound entries, such as those for purchases or production output, to the related outbound entries, such as sales or transfers. To minimize reduced performance during posting, select a time option to define how far back in time from the work date an inbound transaction can occur to potentially trigger adjustment of related outbound value entries. Alternatively, you can manually adjust costs at regular intervals with the Adjust Cost - Item Entries batch job.';
                }
                field("Default Costing Method"; Rec."Default Costing Method")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how your items'' cost flow is recorded and whether an actual or budgeted value is capitalized and used in the cost calculation. Your choice of costing method determines how the unit cost is calculated by making assumptions about the flow of physical items through your company. A different costing method on item cards will override this default. For more information, see "Design Details: Costing Methods" in Help.';
                }
                field("Average Cost Calc. Type"; Rec."Average Cost Calc. Type")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies how costs are calculated for items using the Average costing method. Item: One average cost per item in the company is calculated. Item & Location & Variant: An average cost per item for each location and for each variant of the item in the company is calculated. This means that the average cost of this item depends on where it is stored and which variant, such as color, of the item you have selected.';
                }
                field("Average Cost Period"; Rec."Average Cost Period")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    OptionCaption = ',Day,Week,Month,,,Accounting Period';
                    ToolTip = 'Specifies the period of time used to calculate the weighted average cost of items that apply the average costing method. All inventory decreases that were posted within an average cost period will receive the average cost calculated for that period. If you change the average cost period, only open fiscal years will be affected.';
                }
                field("Copy Comments Order to Shpt."; Rec."Copy Comments Order to Shpt.")
                {
                    ApplicationArea = Comments;
                    Importance = Additional;
                    ToolTip = 'Specifies that you want the program to copy the comments entered on the transfer order to the transfer shipment.';
                }
                field("Copy Comments Order to Rcpt."; Rec."Copy Comments Order to Rcpt.")
                {
                    ApplicationArea = Comments;
                    Importance = Additional;
                    ToolTip = 'Specifies that you want the program to copy the comments entered on the transfer order to the transfer receipt.';
                }
                field("Outbound Whse. Handling Time"; Rec."Outbound Whse. Handling Time")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTip = 'Specifies a date formula that calculates the time it takes to get items ready to ship. The time element is used to calculate the delivery date as follows: Shipment Date + Outbound Warehouse Handling Time = Planned Shipment Date + Shipping Time = Planned Delivery Date.';
                }
                field("Inbound Whse. Handling Time"; Rec."Inbound Whse. Handling Time")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTip = 'Specifies a date formula that calculates the time it takes to make items available in inventory after they have been received. The time element is used to calculate the expected receipt date as follows: Order Date + Lead Time Calculation = Planned Receipt Date + Inbound Warehouse Handling Time + Safety Lead Time = Expected Receipt Date.';
                }
                field("Prevent Negative Inventory"; Rec."Prevent Negative Inventory")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether you can post a transaction that will bring the item''s inventory below zero. Negative inventory is always prevented for Consumption and Transfer type transactions.';
                }
                field("Variant Mandatory if Exists"; Rec."Variant Mandatory if Exists")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether a variant must be selected if variants exist for an item. This is the default setting for all items. However, the same option is available on the Item Card page for items. That setting applies to the specific item. ';
                }
                field("Skip Prompt to Create Item"; Rec."Skip Prompt to Create Item")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if a message about creating a new item card appears when you enter an item number that does not exist.';
                }
                field("Copy Item Descr. to Entries"; Rec."Copy Item Descr. to Entries")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if you want the description on item cards to be copied to item ledger entries during posting.';
                }
                field("Allow Invt. Doc. Reservation"; Rec."Allow Invt. Doc. Reservation")
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
                field("Measuring System"; Rec."Measuring System")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Def. Price Rounding Method"; Rec."Def. Price Rounding Method")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Price Selection Priority"; Rec."Price Selection Priority")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Allergen Cons. Enforcement Lvl"; Rec."Allergen Cons. Enforcement Lvl")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Near-Zero Qty. Value"; Rec."Near-Zero Qty. Value")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Adjust Cost - Post to G/L"; Rec."Adjust Cost - Post to G/L")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Additional;
                }
                field("Adjust Cost - Lock Time (s)"; Rec."Adjust Cost - Lock Time (s)")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Additional;
                }
                field("Adjust Cost - Unlock Time (ms)"; Rec."Adjust Cost - Unlock Time (ms)")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Additional;
                }
                field("Commodity Cost by Location"; Rec."Commodity Cost by Location")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Additional;
                }
                field("Commodity UOM Type"; Rec."Commodity UOM Type")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Additional;
                }
                field("Comm. Cost Rounding Precision"; Rec."Comm. Cost Rounding Precision")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Additional;
                }
                field("Cost Adjust on Comm. Post"; Rec."Cost Adjust on Comm. Post")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Additional;
                }
            }
            group(Location)
            {
                Caption = 'Location';
                field("Location Mandatory"; Rec."Location Mandatory")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies if a location code is required when posting item transactions. This field, together with the Components at Location field in the Manufacturing Setup window, is very important in governing how the planning system handles demand lines with/without location codes. For more information, see "Planning with or without Locations" in Help.';
                }
                field("Default Repack Location"; Rec."Default Repack Location")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Dimensions)
            {
                Caption = 'Dimensions';
                field("Item Group Dimension Code"; Rec."Item Group Dimension Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the dimension code that you want to use for product groups in analysis reports.';
                }
                field("Package Caption"; Rec."Package Caption")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the alternative caption of Package tracking dimension that you want to use for captions for this dimension. For example, Size.';
                    Visible = PackageVisible;
                }
            }
            group(Numbering)
            {
                Caption = 'Numbering';
                field("Item Nos."; Rec."Item Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to items.';
                }
                field("Nonstock Item Nos."; Rec."Nonstock Item Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Catalog Item Nos.';
                    Importance = Additional;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to catalog items.';
                }
                field("Unapproved Item Nos."; Rec."Unapproved Item Nos.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Container IDs"; Rec."Container IDs")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Transfer Order Nos."; Rec."Transfer Order Nos.")
                {
                    ApplicationArea = Location;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to transfer orders.';
                }
                field("Posted Transfer Shpt. Nos."; Rec."Posted Transfer Shpt. Nos.")
                {
                    ApplicationArea = Location;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to posted transfer shipments.';
                }
                field("Posted Transfer Rcpt. Nos."; Rec."Posted Transfer Rcpt. Nos.")
                {
                    ApplicationArea = Location;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to posted transfer receipts.';
                }
                field("Posted Direct Trans. Nos."; Rec."Posted Direct Trans. Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number series from which numbers are assigned to new records.';
                }
                field("Direct Transfer Posting"; Rec."Direct Transfer Posting")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if Direct Transfer should be posted separately as Shipment and Receipt or as single Direct Transfer document.';
                }
                field("Container Usage Doc. Nos."; Rec."Container Usage Doc. Nos.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Inventory Put-away Nos."; Rec."Inventory Put-away Nos.")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to inventory put-always.';
                }
                field("Posted Invt. Put-away Nos."; Rec."Posted Invt. Put-away Nos.")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to posted inventory put-always.';
                }
                field("Inventory Pick Nos."; Rec."Inventory Pick Nos.")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to inventory picks.';
                }
                field("Posted Invt. Pick Nos."; Rec."Posted Invt. Pick Nos.")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to posted inventory picks.';
                }
                field("Inventory Movement Nos."; Rec."Inventory Movement Nos.")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to inventory movements.';
                }
                field("Registered Invt. Movement Nos."; Rec."Registered Invt. Movement Nos.")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to registered inventory movements.';
                }
                field("Internal Movement Nos."; Rec."Internal Movement Nos.")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to internal movements.';
                }
                field("Phys. Invt. Order Nos."; Rec."Phys. Invt. Order Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to physical inventory orders.';
                }
                field("Posted Phys. Invt. Order Nos."; Rec."Posted Phys. Invt. Order Nos.")
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
                field("Repack Order Nos."; Rec."Repack Order Nos.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Commodity Manifest Nos."; Rec."Commodity Manifest Nos.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Posted Comm. Manifest Nos."; Rec."Posted Comm. Manifest Nos.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Comm. Rcpt. Lot Nos."; Rec."Comm. Rcpt. Lot Nos.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Chg. Lot Status Document Nos."; Rec."Chg. Lot Status Document Nos.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Q/C Activity Nos."; Rec."Q/C Activity Nos.")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group("Gen. Journal Templates")
            {
                Caption = 'Journal Templates';
                Visible = IsJournalTemplatesVisible;

                field("Invt. Cost Jnl. Template Name";
                Rec."Invt. Cost Jnl. Template Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the journal template to use for automatic and expected cost posting.';
                }
                field("Invt. Cost Jnl. Batch Name"; Rec."Invt. Cost Jnl. Batch Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the journal batch to use for automatic and expected cost posting.';
                }
            }
            group("Alternate Units")
            {
                Caption = 'Alternate Units';
                field("Sale Alt. Qty. Default"; Rec."Sale Alt. Qty. Default")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Purch. Alt. Qty. Default"; Rec."Purch. Alt. Qty. Default")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Pos. Adj. Alt. Qty. Default"; Rec."Pos. Adj. Alt. Qty. Default")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Neg. Adj. Alt. Qty. Default"; Rec."Neg. Adj. Alt. Qty. Default")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Phys. Count Alt. Qty. Default"; Rec."Phys. Count Alt. Qty. Default")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Transfer Alt. Qty. Default"; Rec."Transfer Alt. Qty. Default")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Consumption Alt. Qty. Default"; Rec."Consumption Alt. Qty. Default")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Output Alt. Qty. Default"; Rec."Output Alt. Qty. Default")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Default Alt. Qty. Tolerance %"; Rec."Default Alt. Qty. Tolerance %")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Blank Captions (Non Alt. Qty.)"; Rec."Blank Captions (Non Alt. Qty.)")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Lots)
            {
                Caption = 'Lots';
                field("Lot Trace Summary Level"; Rec."Lot Trace Summary Level")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot Pref. Enforcement Level"; Rec."Lot Pref. Enforcement Level")
                {
                    ApplicationArea = FOODBasic;
                }
                group(Specifications)
                {
                    Caption = 'Specifications';
                    field("Shortcut Lot Spec. 1 Code"; Rec."Shortcut Lot Spec. 1 Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Shortcut 1';
                    }
                    field("Shortcut Lot Spec. 2 Code"; Rec."Shortcut Lot Spec. 2 Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Shortcut 2';
                    }
                    field("Shortcut Lot Spec. 3 Code"; Rec."Shortcut Lot Spec. 3 Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Shortcut 3';
                    }
                    field("Shortcut Lot Spec. 4 Code"; Rec."Shortcut Lot Spec. 4 Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Shortcut 4';
                    }
                    field("Shortcut Lot Spec. 5 Code"; Rec."Shortcut Lot Spec. 5 Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Shortcut 5';
                    }
                }
                group("Quality Control")
                {
                    Caption = 'Quality Control';
                    field("All Q/C Tests Must Be Done"; Rec."All Q/C Tests Must Be Done")
                    {
                        ApplicationArea = FOODBasic;
                        MultiLine = true;
                    }
                    field("Add Q/C Tests for Phys. Count"; Rec."Add Q/C Tests for Phys. Count")
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
                    field("Quarantine Lot Status"; Rec."Quarantine Lot Status")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Quarantine';
                    }
                    field("Quality Control Lot Status"; Rec."Quality Control Lot Status")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Quality Control';
                    }
                    field("Quality Ctrl. Fail Lot Status"; Rec."Quality Ctrl. Fail Lot Status")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Quality Control Failure';
                    }
                    field("Sales Lot Status"; Rec."Sales Lot Status")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Sales';
                    }
                    field("Purchase Lot Status"; Rec."Purchase Lot Status")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Purchase';
                    }
                    field("Output Lot Status"; Rec."Output Lot Status")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Output';
                    }
                }
            }
            group(Containers)
            {
                Caption = 'Containers';
                field("SSCC Extension Digit"; Rec."SSCC Extension Digit")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Offsite Cont. Location Code"; Rec."Offsite Cont. Location Code")
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
                RunObject = Page "Inventory Periods";
                ToolTip = 'Set up periods in combinations with your accounting periods that define when you can post transactions that affect the value of your item inventory. When you close an inventory period, you cannot post any changes to the inventory value, either expected or actual value, before the ending date of the inventory period.';
            }
            action("Units of Measure")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Units of Measure';
                Image = UnitOfMeasure;
                RunObject = Page "Units of Measure";
                ToolTip = 'Set up the units of measure, such as PSC or HOUR, that you can select from in the Item Units of Measure window that you access from the item card.';
            }
            action("Item Discount Groups")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Item Discount Groups';
                Image = Discount;
                RunObject = Page "Item Disc. Groups";
                ToolTip = 'Set up discount group codes that you can use as criteria when you define special discounts on a customer, vendor, or item card.';
            }
            action("Import Item Pictures")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Import Item Pictures';
                Image = Import;
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
                    RunObject = Page "Inventory Posting Setup";
                    ToolTip = 'Set up links between inventory posting groups, inventory locations, and general ledger accounts to define where transactions for inventory items are recorded in the general ledger.';
                }
                action("Inventory Posting Groups")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Inventory Posting Groups';
                    Image = ItemGroup;
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
                    RunObject = Page "Item Journal Templates";
                    ToolTip = 'Set up number series and reason codes in the journals that you use for inventory adjustment. By using different templates you can design windows with different layouts and you can assign trace codes, number series, and reports to each template.';
                }
            }
        }
        area(Promoted)
        {
            group(Category_Report)
            {
                Caption = 'Report', Comment = 'Generated from the PromotedActionCategories property index 2.';
            }
            group(Category_Category4)
            {
                Caption = 'General', Comment = 'Generated from the PromotedActionCategories property index 3.';

                actionref("Schedule Cost Adjustment and Posting_Promoted"; "Schedule Cost Adjustment and Posting")
                {
                }
                actionref("Inventory Periods_Promoted"; "Inventory Periods")
                {
                }
                actionref("Units of Measure_Promoted"; "Units of Measure")
                {
                }
                actionref("Item Discount Groups_Promoted"; "Item Discount Groups")
                {
                }
                actionref("Import Item Pictures_Promoted"; "Import Item Pictures")
                {
                }
            }
            group(Category_Category5)
            {
                Caption = 'Posting', Comment = 'Generated from the PromotedActionCategories property index 4.';

                actionref("Inventory Posting Setup_Promoted"; "Inventory Posting Setup")
                {
                }
                actionref("Inventory Posting Groups_Promoted"; "Inventory Posting Groups")
                {
                }
            }
            group(Category_Category6)
            {
                Caption = 'Journal Templates', Comment = 'Generated from the PromotedActionCategories property index 5.';

                actionref("Item Journal Templates_Promoted"; "Item Journal Templates")
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            OnOpenPageOnBeforeRecInsert(Rec);
            Rec.Insert();
        end;

        SetPackageVisibility();
        SetAdjustCostWizardActionVisibility();

        GLSetup.Get();
        IsJournalTemplatesVisible := GLSetup."Journal Templ. Name Mandatory";
    end;

    var
        GLSetup: Record "General Ledger Setup";
        PackageMgt: Codeunit "Package Management";
        SchedulingManager: Codeunit "Cost Adj. Scheduling Manager";
        [InDataSet]
        PackageVisible: Boolean;
        AdjustCostWizardVisible: Boolean;
        [InDataSet]
        IsJournalTemplatesVisible: Boolean;

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

    [IntegrationEvent(false, false)]
    local procedure OnOpenPageOnBeforeRecInsert(var InventorySetup: Record "Inventory Setup")
    begin
    end;
}

