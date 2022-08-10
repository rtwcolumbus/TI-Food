table 37 "Sales Line"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 06-07-2015, Initial Version
    // --------------------------------------------------------------------------------
    // 
    // PR1.00
    //   Maintain Production Order Xref when deleting lines
    //   Default Item No. Lookup restricted to finished items
    //   Modify validation on Qty. to Ship
    //   New Process 800 fields
    //     Original Quantity
    //     Qty. on Prod. Order (Base)
    // 
    // PR1.00.02
    //   No. - only set quantity if line number is unchanged
    //   Set permissions
    // 
    // PR1.20.01
    //   When backordering line with lot number then split into two lines
    // 
    // PR2.00
    //   Text constants
    //   Remove lot splitting
    //   New types for No. lookup
    // 
    // PR2.00.01
    //   Validate No. after lookup
    // 
    // PR2.00.05
    //   Variant Code - set unit of measure code from item variant
    // 
    // PR3.60
    //   New Fields
    //     Invoice at Shipped Price
    //     Delivery Route No.
    //     Delivery Stop No.
    //     Net Weight to Ship
    //     Amount to Ship (LCY)
    //     Price ID
    //     Quantity (Alt.)
    //     Qty. to Ship (Alt.)
    //     Alt. Qty. Transaction No.
    //     Qty. Shipped (Alt.)
    //     Qty. to Invoice (Alt.)
    //     Qty. Invoiced (Alt.)
    //     Return Qty. to Receive (Alt.)
    //     Return Qty. Received (Alt.)
    //   New Keys for delivery routes and to SumIndex alternate quantities
    //   Move No. OnLookup to function to be called on forms
    // 
    // PR3.60.02
    //   Suppress backorder prompt when Qty. to Ship set though UpdateWithWarehouseShip
    // 
    // PR3.60.03
    //   Fix problems with Qty. to Ship on fixed weight items
    // 
    // PR3.61
    //   Add Fields
    //     Container Line No.
    //     Qty. to Ship (Cont.)
    //   Add logic for containers
    // 
    // PR3.61.01
    //   Add Fields
    //     Writeoff
    //     Writeoff Responsibility
    // 
    // PR3.61.02
    //   Fix problem with "Qty. to Ship (Cont.)" and negative quantities
    //   Fix problem with wrong sum index field on delivery route key
    // 
    // PR3.70
    //   Integration of P800 into 3.70
    //   Add function GetQuantity to return qty or alt qty for specified fields
    //   Add function GetTransactionQty to return qty and alt qty or specified transactions
    //   Off-Invoice Allowances
    //   Contract Items Only
    // 
    // PR3.70.01
    //   Add Fields
    //     Comment
    //   OnDelete - delete repack lines
    //   Add "Quantity (Alt.)", "Qty. Shipped (Alt.)" as sum index fields to key
    //     Document Type,Type,No.,Variant Code,Drop Shipment,Location Code,Shipment Date
    // 
    // PR3.70.02
    //   Add "Amount to Ship (LCY)" as sum index fields to key
    //     Document Type,Type,Shipment Date,Delivery Route No.,Delivery Stop No.,Document No.
    // 
    // PR3.70.03
    //   Accruals
    // 
    // PR3.70.04
    // P8000044A, Myers Nissi, Jack Reynolds, 21 MAY 04
    //   Accrual Fixes
    // 
    // P8000045B, Myers Nissi, Jack Reynolds, 22 MAY 04
    //   Delete existing alternate quantity lines when validating Type and No.
    // 
    // P8000043A, Myers Nissi, Jack Reynolds, 28 MAY 04
    //    Support for easy lot tracking
    // 
    // PR3.70.06
    // P8000078A, Myers Nissi, Steve Post, 26 JUL 04
    //   added field  37002461 Exclude From Sales Forecast
    // 
    // P8000079A, Myers Nissi, Steve Post, 05 AUG 04
    //   Add sum index fields to key for delivery routes to calculate outstanding quantity and amount
    //   Added code to UpdateAmounts function to calculate Amount to Ship (LCY)
    // 
    // P8000083A, Myers Nissi, Steve Post, 09 AUG 04
    //   added code to updatelinetracking function to allow
    //   lotted and unlotted items on the same document
    // 
    // PR3.70.07
    // P8000119A, Myers Nissi, Don Bresee, 20 SEP 04
    //   Accruals update/fixes
    // 
    // P8000151A, Myers Nissi, Jack Reynolds, 23 NOV 04
    //   Fix problem with item availibility checking on change to UOM
    // 
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Maintain and check lot preferences
    // 
    // PR3.70.08
    // P8000172A, Myers Nissi, Jack Reynolds, 20 JAN 05
    //   CheckLotPreference - exit with TRUE if lot tracking not installed
    // 
    // P8000181A, Myers Nissi, Jack Reynolds, 14 FEB 05
    //   UpdateLotTracking - if xRec is blank then use exising lot number in place of xRec's lot number
    // 
    // PR3.70.09
    // P8000194A, Myers Nissi, Jack Reynolds, 24 FEB 05
    //   Fix easy lot tracking problem to save record before creating tracking lines
    // 
    // PR3.70.10
    // P8000210A, Myers Nissi, Jack Reynolds, 10 MAY 05
    //   Allow lot preferences for blanket order and standing orders
    // 
    // P8000227A, Myers Nissi, Jack Reynolds, 07 JUL 05
    //   Fix problem specifying lot before line has been inserted
    // 
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PR4.00
    // P8000248B, Myers Nissi, Jack Reynolds, 07 OCT 05
    //   Create function SalesHistory to show customer/item sales history and use selection to fill current record
    // 
    // P8000250B, Myers Nissi, Jack Reynolds, 16 OCT 05
    //   Support for automatic lot number assignment on inbound entries
    // 
    // P8000253A, Myers Nissi, Jack Reynolds, 21 OCT 05
    //   Add field "Bypass Credit Check"
    // 
    // P8000264A, VerticalSoft, Jack Reynolds, 07 NOV 05
    //   Fix problem with credit check when changing quantity as part of Qty. to Ship
    // 
    // PR4.00.02
    // P8000295A, VerticalSoft, Jack Reynolds, 13 FEB 06
    //   fix problem with line discount when over/under shipping
    // 
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Integrate alternate quantity with WMS
    // 
    // PR4.00.03
    // P8000342A, VerticalSoft, Jack Reynolds, 18 MAY 06
    //   Fix problem with alternate quantity to invoice for lot tracked items
    // 
    // P8000346A, VerticalSoft, Jack Reynolds, 09 JUN 06
    //   Fix problem calculating line discount when line amount is entered
    // 
    // PR4.00.04
    // P8000351A, VerticalSoft, Jack Reynolds, 17 JUL 06
    //   Fix problem with qty to ship/receive on invoices and credit memos
    // 
    // P8000352A, VerticalSoft, Jack Reynolds, 17 JUL 06
    //   Fix problem when order has been released and changing the quantity in response to backorder
    //     or over receipt prompt
    // 
    // P8000353A, VerticalSoft, Jack Reynolds, 17 JUL 06
    //   Fix problem with lot information not existing when checking lot preferences
    // 
    // P8000322A, VerticalSoft, Don Bresee, 05 SEP 06
    //   Add Staged Quantity
    //   Add Samples
    // 
    // P8000383A, VerticalSoft, Jack Reynolds, 22 SEP 06
    //   Insure that unit of measure is different type from alternate unit of measure
    // 
    // P8000372A, VerticalSoft, Phyllis McGovern, 06 SEP 06
    //   WH Overship and OverReceive
    //   Added field: 'allow quantity change'
    // 
    // P8000398A, VerticalSoft, Jack Reynolds, 03 OCT 06
    //   Fix problem with setting qty. to ship to zero and no backorder
    // 
    // P8000399A, VerticalSoft, Jack Reynolds, 04 OCT 06
    //   Fix error with credit check and marketing plans with price impact
    // 
    // PR4.00.05
    // P8000426A, VerticalSoft, Jack Reynolds, 27 DEC 06
    //   Restore SuspendStatusCheck and give SuspendCreditCheck a new ID
    // 
    // P8000440A, VerticalSoft, Jack Reynolds, 24 JAN 07
    //   Handling for Line Discount Type
    // 
    // P8000413A, VerticalSoft, Jack Reynolds, 02 APR 07
    //   SP3 removed code that was needed for P800
    // 
    // PR4.00.06
    // P8000408A, VerticalSoft, Jack Reynolds, 08 AUG 07
    //   Cover functions to preserve CurrFieldNo
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Don Bresee, 12 JUN 07
    //   Support for Qty. not Returned
    //   Changes for Appl.-from tem Entry
    //   Add LineAmtExclAltQtys - use for prepayment calculations instead of "Line Amount"
    //   Use "Bypass Credit Check" to bypass prepayment calculations for backorder/increase check
    //   Allow deleting of salesl ines w/o prompt to delete tracking lines
    // 
    // PRW15.00.01
    // P8000545A, VerticalSoft, Don Bresee, 13 NOV 07
    //   Override assignment of price and discount group with item specific groups
    // 
    // P8000581A, VerticalSoft, Jack Reynolds, 20 FEB 08
    //   Remove "Exclude From Sales Forecast"
    // 
    // P8000550A, VerticalSoft, Don Bresee, 05 MAR 08
    //   Add logic for new calculation of base and alternate quantities
    // 
    // P8000589A, VerticalSoft, Don Bresee, 05 MAR 08
    //   Add logic for alternate sales items
    // 
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   Support for trip management
    // 
    // PRW15.00.02
    // P8000611A, VerticalSoft, Jack Reynolds, 15 JUL 08
    //   Add missing alternate quantity code to InitQtyToShip2
    // 
    // PRW15.00.03
    // P8000629A, VerticalSoft, Jack Reynolds, 21 SEP 08
    //   Update easy lot tracking for 3-document locations
    // 
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add 1-Doc Whse Logic
    // 
    // PRW16.00.01
    // P8000688, VerticalSoft, Jack Reynolds, 10 APR 09
    //   Fix problem setting quantity to ship
    // 
    // P8000694, VerticalSoft, Jack Reynolds, 04 MAY 09
    //   Change name of Accrual fields
    // 
    // P8000715, VerticalSoft, Jack Reynolds, 06 AUG 09
    //   Fix problem with over shipments from Warehouse shipment
    // 
    // P8000726, VerticalSoft, Jack Reynolds, 01 SEP 09
    //   Clear permission property for Production Order XRef
    // 
    // PRW16.00.02
    // P8000756, VerticalSoft, Jack Reynolds, 04 JAN 10
    //   UpdateAmounts - prepayments and alternate quantities
    // 
    // P8000760, VerticalSoft, Jack Reynolds, 19 JAN 10
    //   Fix to synchronize tracking between sales and purchase lines for drop shipments
    // 
    // PRW16.00.03
    // P8000808, VerticalSoft, Jack Reynolds, 01 APR 10
    //   fix problem setting default alternate quantities
    // 
    // P8000818, VerticalSoft, Jack Reynolds, 29 APR 10
    //   Fix problem with alternate quantities for invoices and credit memos
    // 
    // PRW16.00.04
    // P8000875, VerticalSoft, Jack Reynolds, 14 OCT 10
    //   Modify "Qty. on Prod. Order (Base)" DecimalPlaces
    // 
    // P8000885, VerticalSoft, Ron Davidson, 20 DEC 10
    //   Added three new fields: "Contract No." "Outstanding Qty. (Contract)" & "Outstanding Qty. (Cont. Line)".
    //   Added new function called from InitOutstanding named InitOutstandingQtyCont.
    //   Added logic to not UpdateUnitPrice.
    //   Moved the call to AltQtyMgmt.AssignNewTransactionNo("Alt. Qty. Transaction No.") to after UpdateUnitPrice.
    // 
    // PRW16.00.05
    // P8000921, Columbus IT, Don Bresee, 07 APR 11
    //   Add fields and logic for Delivered Pricing
    // 
    // P8000931, Columbus IT, Jack Reynolds, 20 APR 11
    //   Support for Supply Chain Groups
    // 
    // P8000941, Columbus IT, Don Bresee, 25 JUL 11
    //   Sales Payments granule
    // 
    // P8000943, Columbus IT, Jack Reynolds, 09 MAY 11
    //   Add Receipt Date
    // 
    // P8000944, Columbus IT, Jack Reynolds, 31 MAY 11
    //   Maintain Lot No. on Sales Line repack
    // 
    // P8000946, Columbus IT, Jack Reynolds, 24 MAY 11
    //   Required Country of Origin
    // 
    // P8000981, Columbus IT, Don Bresee, 21 SEP 11
    //   Change "CostInAlternateUnits" to "PriceInAlternateUnits"
    //   Change "GetCostingQty" to "GetPricingQty"
    // 
    // PRW16.00.06
    // P8001014, Columbus IT, Jack Reynolds, 06 JAN 12
    //   Fix problem checking lot preferences
    // 
    // P8001026, Columbus IT, Jack Reynolds, 26 JAN 12
    //   Option to use Sell-to Customer Price Group
    // 
    // P8001038, Columbus IT, Jack Reynolds, 23 FEB 12
    //   Fix problem with Qty. to Ship less than Qty. on Container
    // 
    // P8001047, Columbus IT, Jack Reynolds, 30 MAR 12
    //   Receiving Labels
    // 
    // P8001062, Columbus IT, Jack Reynolds, 26 APR 12
    //   Lot freshness preference override on sales line
    // 
    // P8001070, Columbus IT, Jack Reynolds, 16 MAY 12
    //   Bring Lot Freshness and Lot Preferences together
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.00.01
    // P8001178, Columbus IT, Jack Reynolds, 05 JUL 13
    //   Fix problem with Allow Line Disc.
    // 
    // PRW17.10
    // P8001213, Columbus IT, Jack Reynolds, 26 SEP 13
    //   NAV 2013 R2 changes
    // 
    // P8001234, Columbus IT, Jack Reynolds, 01 NOV 13
    //    Support for custom lot number formats
    // 
    // PRW17.10.02
    // P8001296, Columbus IT, Jack Reynolds, 21 FEB 14
    //   Fix problem with backorder confirmation on Qty. to Ship
    // 
    // PRW17.10.03
    // P8001314, Columbus IT, Jack Reynolds, 23 APR 14
    //   Fix problem reassigniong lot number when posting
    // 
    // P8001363, Columbus IT, Jack Reynolds, 18 NOV 14
    //    Change DecimalPlaces property for Original Quantity
    // 
    // PRW17.10.04
    // P8001366, Columbus IT, Jack Reynolds, 15 DEC 14
    //   Fix VAT and Sales tax calculations for alternate quantity
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality
    // 
    // PRW18.00.01
    // P8001371, Columbus IT, Jack Reynolds, 22 JAN 15
    //   Use GetSalesSetup introduced in CU1
    // 
    // P8001382, Columbus IT, Jack Reynolds, 08 MAY 15
    //   fix problem with over shipments from warehouse shipment
    // 
    // P8001386, Columbus IT, Jack Reynolds, 26 MAY 15
    //   Refactoring changess for cumulative updates
    // 
    // PRW18.00.02
    // P8002744, To-Increase, Jack Reynolds, 30 Sep 15
    //   Support for accrual payment documents
    // 
    // P8002745, To-Increase, Jack Reynolds, 30 Sep 15
    //   Support for accrual payment documents
    // 
    // P8004338, To-Increase, Jack Reynolds, 07 OCT 15
    //   Multiple containers on warehouse receipt
    // 
    // P8004505, To-Increase, Jack Reynolds, 23 OCT 15
    //   Problem with catch weight and lot controlled items when updating from warehouse shipment
    // 
    // PRW18.00.03
    // P8006632, To-Increase, Jack Reynolds, 14 MAR 16
    //   Fix problem with multiple application of accrual price impact
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 9 NOV 15
    //   NAV 2016 refactoring
    // 
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup old delivery trips
    // 
    // PRW19.00.01
    // P8006835, To-Increase, Jack Reynolds, 12 APR 16
    //   Fix division by zero problem when displaying order statistics
    // 
    // P8006787, To-Increase, Jack Reynolds, 21 APR 16
    //   Fix issues with settlement and catch weight items
    // 
    // P8007152, To-Increase, Dayakar Battini, 06 JUN 16
    //   Fix issue Resolve Shorts for Containers.
    // 
    // P8007536, To-Increase, Dayakar Battini, 12 AUG 16
    //   Item Tracking quantity update when Over shipment.
    // 
    // P8006916, To-Increase, Jack Reynolds, 31 AUG 16
    //   FOOD-TOM Separation
    // 
    // P8007924, To-Increase, Dayakar Battini, 03 NOV 16
    //   Alt Qty handling for Return Order/ Credit Memo
    // 
    // P8008268, To-Increase, Jack Reynolds, 04 JAN 17
    //   Problem with accrual price impact and freight calculation
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    //   Fix problem with freight calculation
    // 
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW110.0.01
    // P80038948, To-Increase, Dayakar Battini, 22 MAY 17
    //   Resepect the existing line discount details
    // 
    // P80041480, To-Increase, Dayakar Battini, 09 JUN 17
    //   Manual updation of Unit Price vs Accrual amounts
    // 
    // P80042706, To-Increase, Dayakar Battini, 07 JUL 17
    //  Fix issue with Delivery Route behaviour
    // 
    // PRW110.0.02
    // P80046512, To-Increase, Jack Reynolds, 11 SEP 17
    //   Follow up to 7924 - Permission Error
    // 
    // P80046781, To-Increase, Dayakar Battini, 20 SEP 17
    //   Issue with Delivery Route No. validation
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // P80050544, To-Increase, Dayakar Battini, 12 FEB 18
    //   Upgrade to 2017 CU13
    // 
    // P80052585, To-Increase, Dayakar Battini, 03 FEB 18
    //   Fix issue for Alt UOM error
    // 
    // P80046533, To-Increase, Jack Reynolds, 10 OCT 17
    //   Inbound containers and shipping containers
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.01
    // P80058334, To Increase, Jack Reynolds, 04 MAY 18
    //   Fix issue with surplus item tracking when changing fields
    // 
    // P80060942, To Increase, Jack Reynolds, 25 JUN 18
    //   Fix problem removing order from delivery trip
    // 
    // PRW111.00.02
    // P80068336, P800122261 To Increase, Jack Reynolds, 20 DEC 18
    //   CS00156346 | Rebate/Promo Line Discount Issue
    //   Rollback changes from P80041480
    //        
    // P80070336, To Increase, Jack Reynolds, 12 FEB 19
    //   Fix issue with Alternate Quantity to Handle
    // 
    // P80071625, To Increase, Jack Reynolds, 19 MAR 19
    //   Fix problem initiializing Qty to Ship/Receive
    // 
    // P80073378, To Increase, Jack Reynolds, 24 MAR 19
    //   Support for easy lot tracking on warehouse shipments
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW111.00.03
    // P80077569, To-Increase, Gangabhushan, 17 JUL 19
    //   CS00069439 - Item tracking that is pre-defined in S.O. will now allow pick registration with qty. - Error
    // 
    // P80083775, To-Increase, Gangabhushan, 04 OCT 19
    //   CS00076359 - Purchase Order losing price during receipt for different currency
    // 
    // P80081811, To-Increase, Gangabhushan, 30 OCT 19
    //   Catchweight item while doing transfer system allowing for Qty to ship Qty.
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    //
    // PRW114.00.03
    // P80098163, To-Increase, Gangabhushan, 20 APR 20
    //   CS00103794 - Over Receiving Qty. in Order Receiving page with using Purchase workflows  
    //
    // PRW115.03
    // P800110503, To Increase, Jack Reynolds, 02 NOV 20
    //   Restore original SyuspendStatusCheck and add new SuspendStatusCheck2 with return value
    //
    // PRW117.3
    // P80096165 To Increase, Jack Reynolds, 10 FEB 21
    //   Upgrade to 17.3 - Item Reference replaces Item Cross Reference
    //
    // PRW118.01
    // P800128960, To Increase, Jack Reynolds, 24 AUG 21
    //   Decimal precision on alternate quantity data entry
    //
    // PRW119.3
    // P800145564, To Increase, Jack Reynolds, 2 JUN 22
    //   Error selecting Sales Contract

    Caption = 'Sales Line';
    DrillDownPageID = "Sales Lines";
    LookupPageID = "Sales Lines";
    Permissions = TableData "Sales Line" = m;

    fields
    {
        field(11028580; Settlement; Boolean)
        {
            Caption = 'Settlement';
            Editable = false;
        }
        field(37002000; "Original Quantity"; Decimal)
        {
            Caption = 'Original Quantity';
            DecimalPlaces = 0 : 5;
            Description = 'PR1.00';
        }
        field(37002001; Writeoff; Boolean)
        {
            Caption = 'Writeoff';
            Description = 'PR3.61.01';

            trigger OnValidate()
            begin
                // PR3.61.01
                if Writeoff then begin
                    TestField(Type, Type::Item);
                    "Writeoff Responsibility" := "Writeoff Responsibility"::Company
                end else
                    "Writeoff Responsibility" := 0;
                // PR3.61.01
            end;
        }
        field(37002002; "Writeoff Responsibility"; Option)
        {
            Caption = 'Writeoff Responsibility';
            Description = 'PR3.61.01';
            OptionCaption = ' ,Company,Vendor';
            OptionMembers = " ",Company,Vendor;

            trigger OnValidate()
            begin
                // PR3.61.01
                if "Writeoff Responsibility" <> 0 then begin
                    TestField(Type, Type::Item);
                    Writeoff := true;
                end else
                    Writeoff := false;
                // PR3.61.01
            end;
        }
        field(37002003; "Bypass Credit Check"; Boolean)
        {
            Caption = 'Bypass Credit Check';
        }
        field(37002004; "Allow Quantity Change"; Boolean)
        {
            Caption = 'Allow Quantity Change';
        }
        field(37002015; "Supply Chain Group Code"; Code[10])
        {
            Caption = 'Supply Chain Group Code';
            TableRelation = "Supply Chain Group";
        }
        field(37002020; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            Description = 'PR3.70.04';

            trigger OnValidate()
            var
                ItemLedgEntry: Record "Item Ledger Entry";
                RepackLine: Record "Sales Line Repack";
                ApplyFromEntryNo: Integer;
            begin
                // P8000043A
                ApplyFromEntryNo := GlobalApplyFromEntryNo; // P8000466A
                GlobalApplyFromEntryNo := 0;                // P8000466A
                if xRec."Lot No." = P800Globals.MultipleLotCode then
                    FieldError("Lot No.", Text37002006);
                // P8000153A Begin
                if "Lot No." <> '' then
                    if not CheckLotPreferences("Lot No.", true) then
                        Error(Text37002007, "Lot No."); // P8001070
                // P8000153A End
                // P8000466A
                if ApplyFromEntryNo <> 0 then begin
                    ItemLedgEntry.Get(ApplyFromEntryNo);
                    if ItemLedgEntry."Shipped Qty. Not Returned" + Abs("Quantity (Base)") > 0 then
                        ItemLedgEntry.FieldError("Shipped Qty. Not Returned");
                    if ItemLedgEntry."Shipped Qty. Not Ret. (Alt.)" + Abs("Quantity (Alt.)") > 0 then
                        ItemLedgEntry.FieldError("Shipped Qty. Not Ret. (Alt.)");
                end;
                // P8000466A
                if "Line No." <> 0 then begin // P8000227A
                    Modify; // P8000194A
                    UpdateLotTracking(true, ApplyFromEntryNo); // P8000466A   // P8007536
                end;                          // P8000227A
                // P8000043A

                // P8000944
                if RepackLine.Get("Document Type", "Document No.", "Line No.") then begin
                    RepackLine."Lot No." := "Lot No.";
                    RepackLine.Modify;
                end;
                // P8000944
            end;
        }
        field(37002021; "Lot Freshness Preference"; Integer)
        {
            Caption = 'Lot Freshness Preference';
            InitValue = -1;
        }
        field(37002022; "Freshness Calc. Method"; Option)
        {
            Caption = 'Freshness Calc. Method';
            OptionCaption = ' ,Days To Fresh,Best If Used By,Sell By';
            OptionMembers = " ","Days To Fresh","Best If Used By","Sell By";
        }
        field(37002023; "Oldest Accept. Freshness Date"; Date)
        {
            Caption = 'Oldest Acceptable Freshness Date';

            trigger OnValidate()
            begin
                // P8001062
                case "Freshness Calc. Method" of
                    "Freshness Calc. Method"::"Days To Fresh":
                        if "Shipment Date" < "Oldest Accept. Freshness Date" then
                            Error(Text37002009, FieldCaption("Oldest Accept. Freshness Date"), FieldCaption("Shipment Date"), "Shipment Date")
                        else
                            "Lot Freshness Preference" := "Shipment Date" - "Oldest Accept. Freshness Date";
                    "Freshness Calc. Method"::"Best If Used By", "Freshness Calc. Method"::"Sell By":
                        if "Planned Delivery Date" > "Oldest Accept. Freshness Date" then
                            Error(Text37002010, FieldCaption("Oldest Accept. Freshness Date"),
                              FieldCaption("Planned Delivery Date"), "Planned Delivery Date")
                        else
                            "Lot Freshness Preference" := "Oldest Accept. Freshness Date" - "Planned Delivery Date";
                end;
            end;
        }
        field(37002040; "Invoice at Shipped Price"; Boolean)
        {
            Caption = 'Invoice at Shipped Price';
            Description = 'PR3.60';
        }
        field(37002041; "Price ID"; Integer)
        {
            Caption = 'Price ID';
            Description = 'PR3.60';
        }
        field(37002042; "Off-Invoice Allowance Code"; Code[10])
        {
            Caption = 'Off-Invoice Allowance Code';
            Description = 'PR3.70';
        }
        field(37002045; "Line Discount Type"; Option)
        {
            Caption = 'Line Discount Type';
            Editable = false;
            OptionCaption = 'Percent,Amount,Unit Amount';
            OptionMembers = Percent,Amount,"Unit Amount";
        }
        field(37002046; "Line Discount Unit Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Line Discount Unit Amount';

            trigger OnValidate()
            begin
                // P8000440A
                TestStatusOpen;
                if CurrFieldNo = FieldNo("Line Discount Unit Amount") then
                    "Line Discount Type" := "Line Discount Type"::"Unit Amount";
                CalcLineDiscount(true); // P80073095

                if ProcessFns.AccrualsInstalled() then
                    AccrualMgmt.SalesRecalcLines(Rec);
            end;
        }
        field(37002049; "FOB Pricing"; Boolean)
        {
            CalcFormula = Lookup("Sales Header"."FOB Pricing" WHERE("Document Type" = FIELD("Document Type"),
                                                                     "No." = FIELD("Document No.")));
            Caption = 'FOB Pricing';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002050; "Unit Price (FOB)"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            BlankZero = true;
            CaptionClass = GetCaptionClass(FieldNo("Unit Price (FOB)"));
            Caption = 'Unit Price (FOB)';

            trigger OnValidate()
            begin
                // P8000921
                if (CurrFieldNo = FieldNo("Unit Price (FOB)")) then
                    UsingDeliveredPricing(true);
                ValidateUnitPriceFOB("Unit Price (FOB)");
            end;
        }
        field(37002051; "Unit Price (Freight)"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            BlankZero = true;
            CaptionClass = GetCaptionClass(FieldNo("Unit Price (Freight)"));
            Caption = 'Unit Price (Freight)';

            trigger OnValidate()
            var
                xRecLineDiscPerc: Decimal;
            begin
                // P8000921
                // P80038948
                if "Line Discount %" <> 0 then
                    xRecLineDiscPerc := "Line Discount %";
                // P80038948

                GetSalesHeader;
                "Freight Entered by User" := (CurrFieldNo in [FieldNo("Unit Price (Freight)"), FieldNo("Line Amount (Freight)")]);
                if "Freight Entered by User" then begin
                    UsingDeliveredPricing(true);
                    if SalesHeader."FOB Pricing" and ("Unit Price (Freight)" <> 0) then
                        SalesHeader.FieldError("FOB Pricing");
                end;
                "Line Amount (Freight)" := Round(GetPricingQty() * "Unit Price (Freight)", Currency."Amount Rounding Precision");
                Validate("Unit Price", "Unit Price (FOB)" - "Accrual Amount (Price)" + "Unit Price (Freight)"); // P8008268

                // P80038948
                if xRecLineDiscPerc <> 0 then
                    Validate("Line Discount %", xRecLineDiscPerc);
                // P80038948
            end;
        }
        field(37002052; "Line Amount (Freight)"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            BlankZero = true;
            CaptionClass = GetCaptionClass(FieldNo("Line Amount (Freight)"));
            Caption = 'Line Amount (Freight)';

            trigger OnValidate()
            var
                xRecLineDiscPerc: Decimal;
            begin
                // P8000921
                // P80038948
                if "Line Discount %" <> 0 then
                    xRecLineDiscPerc := "Line Discount %";
                // P80038948

                if (GetPricingQty() = 0) then
                    Validate("Unit Price (Freight)", 0)
                else begin
                    GetSalesHeader;
                    Validate("Unit Price (Freight)",
                      Round("Line Amount (Freight)" / GetPricingQty(), Currency."Unit-Amount Rounding Precision"));
                end;

                // P80038948
                if xRecLineDiscPerc <> 0 then
                    Validate("Line Discount %", xRecLineDiscPerc);
                // P80038948
            end;
        }
        field(37002053; "Freight Entered by User"; Boolean)
        {
            Caption = 'Freight Entered by User';
            Editable = false;
        }
        field(37002060; "Delivery Route No."; Code[20])
        {
            Caption = 'Delivery Route No.';
            Description = 'PR3.60';
            Editable = false;
            TableRelation = "Delivery Route";

            trigger OnValidate()
            begin
                // P80042706
                if xRec."Delivery Route No." <> '' then   // P80046781
                    if xRec."Delivery Route No." <> "Delivery Route No." then
                        RemoveDeliveryTrip;
                // P80042706
            end;
        }
        field(37002061; "Delivery Stop No."; Code[20])
        {
            Caption = 'Delivery Stop No.';
            Description = 'PR3.60';
            Editable = false;
        }
        field(37002080; "Alt. Qty. Transaction No."; Integer)
        {
            Caption = 'Alt. Qty. Transaction No.';
            Description = 'PR3.60';
            Editable = false;
        }
        field(37002081; "Quantity (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,1,0,%1,%2', Type, "No.");
            Caption = 'Quantity (Alt.)';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.60';
            Editable = false;

            trigger OnValidate()
            var
                ItemLedgEntry: Record "Item Ledger Entry";
            begin
                CheckApplFromItemLedgEntry(ItemLedgEntry); // P8000466A

                // P8000044A
                if ProcessFns.AccrualsInstalled() then
                    AccrualMgmt.SalesRecalcLines(Rec);
                // P8000044A
            end;
        }
        field(37002082; "Qty. to Ship (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            AutoFormatExpression = GetItemNo();
            AutoFormatType = 37002080;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,1,1,%1,%2', Type, "No.");
            Caption = 'Qty. to Ship (Alt.)';
            Description = 'PR3.61';

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                // PR3.60
                P800CoreFns.CheckSalesLineFieldEditable(Rec, FieldNo("Qty. to Ship (Alt.)"), CurrFieldNo); // PR3.61
                TestSalesAltQtyInfo(false); // P8000408A

                GetItem(Item); // P80066030
                if (CurrFieldNo = FieldNo("Qty. to Ship (Alt.)")) then begin
                    TestStatusOpen; // P80070336
                    Item.TestField("Catch Alternate Qtys.", true);
                    if "Qty. to Ship (Alt.)" <> 0 then // P80073378
                        TestField("Qty. to Ship");
                    // TestStatusOpen; // P8000282A
                    AltQtyMgmt.CheckSummaryTolerance1("Alt. Qty. Transaction No.", "No.",
                                                     FieldCaption("Qty. to Ship (Alt.)"),
                                                     "Qty. to Ship (Base)", "Qty. to Ship (Alt.)");
                end;

                SetSalesLineAltQty; // P8000408A
                                    // PR3.60

                /*P8000044A
                // PR3.70.03
                IF ProcessFns.AccrualsInstalled() THEN
                  AccrualMgmt.SalesRecalcLines(Rec);
                // PR3.70.03
                P8000044A*/

            end;
        }
        field(37002083; "Qty. Shipped (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,1,2,%1,%2', Type, "No.");
            Caption = 'Qty. Shipped (Alt.)';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.60';
            Editable = false;
        }
        field(37002084; "Qty. to Invoice (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,1,5,%1,%2', Type, "No.");
            Caption = 'Qty. to Invoice (Alt.)';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.60';
            Editable = false;
        }
        field(37002085; "Qty. Invoiced (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,1,6,%1,%2', Type, "No.");
            Caption = 'Qty. Invoiced (Alt.)';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.60';
            Editable = false;
        }
        field(37002086; "Return Qty. to Receive (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            AutoFormatExpression = GetItemNo();
            AutoFormatType = 37002080;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,1,3,%1,%2', Type, "No.");
            Caption = 'Return Qty. to Receive (Alt.)';
            Description = 'PR3.60';

            trigger OnValidate()
            var
                Item: Record Item;
                ItemLedgerEntry: Record "Item Ledger Entry";
            begin
                // PR3.60
                TestSalesAltQtyInfo(false); // P8000408A

                GetItem(Item); // P80066030
                // P8007924
                // "Return Qty. to Receive (Alt.)" alt should be always less than ILE shipped not returned alt.
                if ("Appl.-from Item Entry" <> 0) then begin
                    ItemLedgerEntry.Get("Appl.-from Item Entry");
                    if (Abs("Return Qty. to Receive (Alt.)") > -ItemLedgerEntry."Shipped Qty. Not Ret. (Alt.)") then
                        Error(Text020, -ItemLedgerEntry."Shipped Qty. Not Ret. (Alt.)");
                end;
                // P8007924
                if (CurrFieldNo = FieldNo("Return Qty. to Receive (Alt.)")) then begin
                    TestStatusOpen; // P80070336
                    Item.TestField("Catch Alternate Qtys.", true);
                    if "Return Qty. to Receive (Alt.)" <> 0 then // P80073378
                        TestField("Return Qty. to Receive");
                    // TestStatusOpen; // P8000282A
                    AltQtyMgmt.CheckSummaryTolerance1("Alt. Qty. Transaction No.", "No.",
                                                     FieldCaption("Return Qty. to Receive (Alt.)"),
                                                     "Return Qty. to Receive (Base)", "Return Qty. to Receive (Alt.)");
                end;

                SetSalesLineAltQty; // P8000408A
                                    // PR3.60

                /*P8000044A
                // PR3.70.03
                IF ProcessFns.AccrualsInstalled() THEN
                  AccrualMgmt.SalesRecalcLines(Rec);
                // PR3.70.03
                P8000044A*/

            end;
        }
        field(37002087; "Return Qty. Received (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,1,4,%1,%2', Type, "No.");
            Caption = 'Return Qty. Received (Alt.)';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.60';
            Editable = false;
        }
        field(37002088; "Alt. Qty. Update Required"; Boolean)
        {
            Caption = 'Alt. Qty. Update Required';
            Description = 'PR4.00.02';
        }
        field(37002093; "Net Weight to Ship"; Decimal)
        {
            Caption = 'Net Weight to Ship';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.60';
        }
        field(37002094; "Amount to Ship (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount to Ship (LCY)';
            Description = 'PR3.60';
            Editable = false;
        }
        field(37002120; "Promo/Rebate Amount (LCY)"; Decimal)
        {
            CalcFormula = Sum("Document Accrual Line"."Payment Amount (LCY)" WHERE("Accrual Plan Type" = CONST(Sales),
                                                                                    "Plan Type" = CONST("Promo/Rebate"),
                                                                                    "Computation Level" = CONST("Document Line"),
                                                                                    "Document Type" = FIELD("Document Type"),
                                                                                    "Document No." = FIELD("Document No."),
                                                                                    "Document Line No." = FIELD("Line No.")));
            Caption = 'Promo/Rebate Amount (LCY)';
            Description = 'PR3.70.03';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002121; "Commission Amount (LCY)"; Decimal)
        {
            CalcFormula = Sum("Document Accrual Line"."Payment Amount (LCY)" WHERE("Accrual Plan Type" = CONST(Sales),
                                                                                    "Plan Type" = CONST(Commission),
                                                                                    "Computation Level" = CONST("Document Line"),
                                                                                    "Document Type" = FIELD("Document Type"),
                                                                                    "Document No." = FIELD("Document No."),
                                                                                    "Document Line No." = FIELD("Line No.")));
            Caption = 'Commission Amount (LCY)';
            Description = 'PR3.70.03';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002122; "Acc. Incl. in Price (LCY)"; Decimal)
        {
            CalcFormula = Sum("Document Accrual Line"."Payment Amount (LCY)" WHERE("Accrual Plan Type" = CONST(Sales),
                                                                                    "Computation Level" = CONST("Document Line"),
                                                                                    "Document Type" = FIELD("Document Type"),
                                                                                    "Document No." = FIELD("Document No."),
                                                                                    "Document Line No." = FIELD("Line No."),
                                                                                    "Price Impact" = FILTER("Include in Price")));
            Caption = 'Acc. Incl. in Price (LCY)';
            Description = 'PR3.70.03';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002123; "Acc. Excl. from Price (LCY)"; Decimal)
        {
            CalcFormula = Sum("Document Accrual Line"."Payment Amount (LCY)" WHERE("Accrual Plan Type" = CONST(Sales),
                                                                                    "Computation Level" = CONST("Document Line"),
                                                                                    "Document Type" = FIELD("Document Type"),
                                                                                    "Document No." = FIELD("Document No."),
                                                                                    "Document Line No." = FIELD("Line No."),
                                                                                    "Price Impact" = CONST("Exclude from Price")));
            Caption = 'Acc. Excl. from Price (LCY)';
            Description = 'PR3.70.03';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002124; "Accrual Amount (Price)"; Decimal)
        {
            Caption = 'Accrual Amount (Price)';
            Description = 'PR3.70.03';
            Editable = false;
        }
        field(37002127; "Accrual Plan Type"; Option)
        {
            Caption = 'Accrual Plan Type';
            Editable = false;
            OptionCaption = 'Sales,Purchase';
            OptionMembers = Sales,Purchase;
        }
        field(37002128; "Accrual Source No."; Code[20])
        {
            Caption = 'Accrual Source No.';
            TableRelation = IF ("Accrual Plan Type" = CONST(Sales)) Customer
            ELSE
            IF ("Accrual Plan Type" = CONST(Purchase)) Vendor;

            trigger OnValidate()
            begin
                AccrualFldMgmt.SalesLineValidate(FieldNo("Accrual Source No."), xRec, Rec); // P8002744
            end;
        }
        field(37002129; "Accrual Source Doc. Type"; Option)
        {
            Caption = 'Accrual Source Doc. Type';
            OptionCaption = 'None,Shipment,Receipt,Invoice,Credit Memo';
            OptionMembers = "None",Shipment,Receipt,Invoice,"Credit Memo";

            trigger OnValidate()
            begin
                AccrualFldMgmt.SalesLineValidate(FieldNo("Accrual Source Doc. Type"), xRec, Rec); // P8002744
            end;
        }
        field(37002130; "Accrual Source Doc. No."; Code[20])
        {
            Caption = 'Accrual Source Doc. No.';

            trigger OnValidate()
            begin
                AccrualFldMgmt.SalesLineValidate(FieldNo("Accrual Source Doc. No."), xRec, Rec); // P8002744
            end;
        }
        field(37002131; "Accrual Source Doc. Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Accrual Source Doc. Line No.';

            trigger OnValidate()
            begin
                AccrualFldMgmt.SalesLineValidate(FieldNo("Accrual Source Doc. Line No."), xRec, Rec); // P8002744
            end;
        }
        field(37002132; "Scheduled Accrual No."; Code[10])
        {
            Caption = 'Scheduled Accrual No.';

            trigger OnValidate()
            begin
                AccrualFldMgmt.SalesLineValidate(FieldNo("Scheduled Accrual No."), xRec, Rec); // P8002744
            end;
        }
        field(37002460; "Qty. on Prod. Order (Base)"; Decimal)
        {
            CalcFormula = Sum("Production Order XRef"."Quantity (Base)" WHERE("Source Table ID" = CONST(37),
                                                                               "Source Type" = FIELD("Document Type"),
                                                                               "Source No." = FIELD("Document No."),
                                                                               "Source Line No." = FIELD("Line No.")));
            Caption = 'Qty. on Prod. Order (Base)';
            DecimalPlaces = 0 : 5;
            Description = 'PR1.00, PR2.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002560; "Container Line No."; Integer)
        {
            Caption = 'Container Line No.';
            Description = 'PR3.61';
            Editable = false;
        }
        field(37002660; Comment; Text[30])
        {
            Caption = 'Comment';
            Description = 'PR3.70.01';
        }
        field(37002661; "Receipt Date"; Date)
        {
            Caption = 'Receipt Date';

            trigger OnValidate()
            begin
                // P8000943
                TestStatusOpen;
            end;
        }
        field(37002662; "Country/Region of Origin Code"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';
            TableRelation = "Country/Region";

            trigger OnValidate()
            var
                Item: Record Item;
                ItemTracking: Record "Item Tracking Code";
                ResEntry: Record "Reservation Entry";
                LotInfo: Record "Lot No. Information";
            begin
                // P8000946
                TestField(Type, Type::Item);
                TestField("No.");
                Item.Get("No.");
                ItemTracking.Get(Item."Item Tracking Code");
                ItemTracking.TestField("Lot Specific Tracking", true);
                ResEntry.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.");
                ResEntry.SetRange("Source Type", DATABASE::"Sales Line");
                ResEntry.SetRange("Source Subtype", "Document Type");
                ResEntry.SetRange("Source ID", "Document No.");
                ResEntry.SetRange("Source Ref. No.", "Line No.");
                if ResEntry.FindSet then
                    repeat
                        LotInfo.Get(ResEntry."Item No.", ResEntry."Variant Code", ResEntry."Lot No.");
                        LotInfo.TestField("Country/Region of Origin Code", "Country/Region of Origin Code");
                    until ResEntry.Next = 0;
            end;
        }
        field(37002700; "Label Unit of Measure Code"; Code[10])
        {
            Caption = 'Label Unit of Measure Code';
            TableRelation = IF (Type = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));

            trigger OnValidate()
            var
                ItemUOM: Record "Item Unit of Measure";
            begin
                // P8001047
                TestField("Document Type", "Document Type"::"Return Order");
                if Type <> Type::Item then
                    TestField("Label Unit of Measure Code", '');
            end;
        }
        field(37002760; "Staged Quantity"; Decimal)
        {
            CalcFormula = Sum("Whse. Staged Pick Source Line"."Qty. Outstanding" WHERE("Source Type" = CONST(37),
                                                                                        "Source Subtype" = CONST("1"),
                                                                                        "Source No." = FIELD("Document No."),
                                                                                        "Source Line No." = FIELD("Line No.")));
            Caption = 'Staged Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002761; "Sales Sample"; Boolean)
        {
            Caption = 'Sales Sample';

            trigger OnValidate()
            begin
                // P8000322A
                if "Sales Sample" then
                    // VALIDATE("Unit Price", 0) // P8000921
                    ValidateUnitPriceFOB(0)      // P8000921
                else
                    if ("Unit Price" = 0) then
                        UpdateUnitPrice(FieldNo("Sales Sample"));
                // P8000322A
            end;
        }
        field(37002762; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            Description = 'PRW16.00.04';
            Editable = false;
            TableRelation = "Sales Contract";
        }
        field(37002763; "Outstanding Qty. (Contract)"; Decimal)
        {
            Caption = 'Outstanding Qty. (Contract)';
            DecimalPlaces = 0 : 5;
            Description = 'PRW16.00.04';
        }
        field(37002764; "Outstanding Qty. (Cont. Line)"; Decimal)
        {
            Caption = 'Outstanding Qty. (Cont. Line)';
            DecimalPlaces = 0 : 5;
            Description = 'PRW16.00.04';
        }
        field(1; "Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Document Type';
        }
        field(2; "Sell-to Customer No."; Code[20])
        {
            Caption = 'Sell-to Customer No.';
            Editable = false;
            TableRelation = Customer;
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "Sales Header"."No." WHERE("Document Type" = FIELD("Document Type"));
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(5; Type; Enum "Sales Line Type")
        {
            Caption = 'Type';

            trigger OnValidate()
            var
                TempSalesLine: Record "Sales Line" temporary;
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateType(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                TestJobPlanningLine();
                TestStatusOpen();
                GetSalesHeader();

                TestField("Qty. Shipped Not Invoiced", 0);
                TestField("Quantity Shipped", 0);
                TestField("Shipment No.", '');

                TestField("Return Qty. Rcd. Not Invd.", 0);
                TestField("Return Qty. Received", 0);
                TestField("Return Receipt No.", '');

                TestField("Prepmt. Amt. Inv.", 0);

                CheckAssocPurchOrder(FieldCaption(Type));


                if Type <> xRec.Type then begin
                    case xRec.Type of
                        Type::Item:
                            begin
                                ATOLink.DeleteAsmFromSalesLine(Rec);
                                if Quantity <> 0 then begin
                                    SalesHeader.TestField(Status, SalesHeader.Status::Open);
                                    CalcFields("Reserved Qty. (Base)");
                                    TestField("Reserved Qty. (Base)", 0);
                                    VerifyChangeForSalesLineReserve(FieldNo(Type));
                                    WhseValidateSourceLine.SalesLineVerifyChange(Rec, xRec);
                                    OnValidateTypeOnAfterCheckItem(Rec, xRec);
                                end;
                            end;
                        Type::"Fixed Asset":
                            if Quantity <> 0 then
                                SalesHeader.TestField(Status, SalesHeader.Status::Open);
                        Type::"Charge (Item)":
                            DeleteChargeChargeAssgnt("Document Type", "Document No.", "Line No.");
                    end;
                    if xRec."Deferral Code" <> '' then
                        DeferralUtilities.RemoveOrSetDeferralSchedule('',
                          "Deferral Document Type"::Sales.AsInteger(), '', '',
                          xRec."Document Type".AsInteger(), xRec."Document No.", xRec."Line No.",
                          xRec.GetDeferralAmount(), xRec."Posting Date", '', xRec."Currency Code", true);
                end;
                AddOnIntegrMgt.CheckReceiptOrderStatus(Rec);

                if "Alt. Qty. Transaction No." <> 0 then                     // P8000045B
                    AltQtyMgmt.DeleteAltQtyLines("Alt. Qty. Transaction No."); // P8000045B
                "Alt. Qty. Transaction No." := 0;                            // P8000045B

                // P8000044A
                if ProcessFns.AccrualsInstalled() then
                    AccrualMgmt.SalesDeleteLines(Rec);
                // P8000044A

                TempSalesLine := Rec;
                Init();
                SystemId := TempSalesLine.SystemId;
                if xRec."Line Amount" <> 0 then
                    "Recalculate Invoice Disc." := true;

                Type := TempSalesLine.Type;
                "System-Created Entry" := TempSalesLine."System-Created Entry";
                "Currency Code" := SalesHeader."Currency Code";

                OnValidateTypeOnCopyFromTempSalesLine(Rec, TempSalesLine);

                if Type = Type::Item then
                    "Allow Item Charge Assignment" := true
                else
                    "Allow Item Charge Assignment" := false;
                if Type = Type::Item then begin
                    if SalesHeader.InventoryPickConflict("Document Type", "Document No.", SalesHeader."Shipping Advice") then
                        Error(Text056, SalesHeader."Shipping Advice");
                    if SalesHeader.WhseShipmentConflict("Document Type", "Document No.", SalesHeader."Shipping Advice") then
                        Error(Text052, SalesHeader."Shipping Advice");
                end;
            end;
        }
        field(6; "No."; Code[20])
        {
            CaptionClass = GetCaptionClass(FieldNo("No."));
            Caption = 'No.';
            Description = 'PR3.61';
            TableRelation = IF (Type = CONST(" ")) "Standard Text"
            ELSE
            IF (Type = CONST("G/L Account"),
                                     "System-Created Entry" = CONST(false)) "G/L Account" WHERE("Direct Posting" = CONST(true),
                                                                                               "Account Type" = CONST(Posting),
                                                                                               Blocked = CONST(false))
            ELSE
            IF (Type = CONST("G/L Account"),
                                                                                                        "System-Created Entry" = CONST(true)) "G/L Account"
            ELSE
            IF (Type = CONST(Resource)) Resource
            ELSE
            IF (Type = CONST("Fixed Asset")) "Fixed Asset"
            ELSE
            IF (Type = CONST("Charge (Item)")) "Item Charge"
            ELSE
            IF (Type = CONST(Item),
                                                                                                                 "Document Type" = FILTER(<> "Credit Memo" & <> "Return Order")) Item WHERE(Blocked = CONST(false),
                                                                                                                                                                                       "Sales Blocked" = CONST(false))
            ELSE
            IF (Type = CONST(Item),
                                                                                                                                                                                                "Document Type" = FILTER("Credit Memo" | "Return Order")) Item WHERE(Blocked = CONST(false)) ELSE
            IF (Type = CONST(FOODAccrualPlan)) "Accrual Plan"."No.";
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                Item: Record Item;
                TempSalesLine: Record "Sales Line" temporary;
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateNo(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                CustItemAltMgmt.SalesLineValidate(Rec); // P8000589A

                GetSalesSetup();

                "No." := FindOrCreateRecordByNo("No.");

                TestJobPlanningLine();
                TestStatusOpen();
                CheckItemAvailable(FieldNo("No."));

                if (xRec."No." <> "No.") and (Quantity <> 0) then begin
                    TestField("Qty. to Asm. to Order (Base)", 0);
                    CalcFields("Reserved Qty. (Base)");
                    TestField("Reserved Qty. (Base)", 0);
                    if Type = Type::Item then
                        WhseValidateSourceLine.SalesLineVerifyChange(Rec, xRec);
                    OnValidateNoOnAfterVerifyChange(Rec, xRec);
                end;

                TestField("Qty. Shipped Not Invoiced", 0);
                TestField("Quantity Shipped", 0);
                TestField("Shipment No.", '');

                TestField("Prepmt. Amt. Inv.", 0);

                TestField("Return Qty. Rcd. Not Invd.", 0);
                TestField("Return Qty. Received", 0);
                TestField("Return Receipt No.", '');

                TestContainerQuantityIsZero; // P80046533

                if "No." = '' then
                    ATOLink.DeleteAsmFromSalesLine(Rec);
                CheckAssocPurchOrder(FieldCaption("No."));
                AddOnIntegrMgt.CheckReceiptOrderStatus(Rec);

                OnValidateNoOnBeforeInitRec(Rec, xRec, CurrFieldNo);

                // P8000885 - Moved next 3 lines to after UpdateUnitPrice
                //IF "Alt. Qty. Transaction No." <> 0 THEN                     // P8000045B
                //  AltQtyMgmt.DeleteAltQtyLines("Alt. Qty. Transaction No."); // P8000045B
                //"Alt. Qty. Transaction No." := 0;                            // P8000045B

                // PR3.70.03
                if ProcessFns.AccrualsInstalled() then
                    AccrualMgmt.SalesDeleteLines(Rec);
                // PR3.70.03

                TempSalesLine := Rec;
                Init();
                SystemId := TempSalesLine.SystemId;
                if xRec."Line Amount" <> 0 then
                    "Recalculate Invoice Disc." := true;
                Type := TempSalesLine.Type;
                "No." := TempSalesLine."No.";
                OnValidateNoOnCopyFromTempSalesLine(Rec, TempSalesLine, xRec);
                if "No." = '' then
                    exit;

                if HasTypeToFillMandatoryFields() then
                    Quantity := TempSalesLine.Quantity;

                "System-Created Entry" := TempSalesLine."System-Created Entry";
                GetSalesHeader();
                OnValidateNoOnBeforeInitHeaderDefaults(SalesHeader, Rec);
                InitHeaderDefaults(SalesHeader);
                OnValidateNoOnAfterInitHeaderDefaults(SalesHeader, TempSalesLine);

                CalcFields("Substitution Available");

                "Promised Delivery Date" := SalesHeader."Promised Delivery Date";
                "Requested Delivery Date" := SalesHeader."Requested Delivery Date";

                IsHandled := false;
                OnValidateNoOnBeforeCalcShipmentDateForLocation(IsHandled, Rec);
                if not IsHandled then
                    CalcShipmentDateForLocation();

                IsHandled := false;
                OnValidateNoOnBeforeUpdateDates(Rec, xRec, SalesHeader, CurrFieldNo, IsHandled, TempSalesLine);
                if not IsHandled then
                    UpdateDates();

                OnAfterAssignHeaderValues(Rec, SalesHeader);

                // P8000044A, P8000119A
                if ProcessFns.AccrualsInstalled() then
                    AccrualMgmt.SalesBeginRecalcLines(Rec);
                // P8000044A

                case Type of
                    Type::" ":
                        CopyFromStandardText();
                    Type::"G/L Account":
                        CopyFromGLAccount();
                    Type::Item, Type::FOODContainer: // PR3.61
                        CopyFromItem();
                    Type::Resource:
                        CopyFromResource();
                    Type::"Fixed Asset":
                        CopyFromFixedAsset();
                    Type::"Charge (Item)":
                        CopyFromItemCharge();
                end;
                // P8002744
                if ProcessFns.AccrualsInstalled() then
                    AccrualFldMgmt.SalesLineValidate(FieldNo("No."), xRec, Rec);
                // P8002744

                OnAfterAssignFieldsForNo(Rec, xRec, SalesHeader);

                if Type <> Type::" " then begin
                    PostingSetupMgt.CheckGenPostingSetupSalesAccount("Gen. Bus. Posting Group", "Gen. Prod. Posting Group");
                    PostingSetupMgt.CheckGenPostingSetupCOGSAccount("Gen. Bus. Posting Group", "Gen. Prod. Posting Group");
                    PostingSetupMgt.CheckVATPostingSetupSalesAccount("VAT Bus. Posting Group", "VAT Prod. Posting Group");
                end;

                if HasTypeToFillMandatoryFields() and (Type <> Type::"Fixed Asset") then
                    ValidateVATProdPostingGroup();

                UpdatePrepmtSetupFields();

                if HasTypeToFillMandatoryFields() then begin
                    PlanPriceCalcByField(FieldNo("No."));
                    if not (Type in [Type::"Charge (Item)", Type::"Fixed Asset"]) then
                        ValidateUnitOfMeasureCodeFromNo();
                    if Quantity <> 0 then begin
                        InitOutstanding();
                        if IsCreditDocType() then
                            InitQtyToReceive()
                        else
                            InitQtyToShip();
                        InitQtyToAsm();
                        UpdateWithWarehouseShip();
                    end;
                    // P8000885 - Moved next 3 lines from above
                    if "Alt. Qty. Transaction No." <> 0 then                     // P8000045B
                        AltQtyMgmt.DeleteAltQtyLines("Alt. Qty. Transaction No."); // P8000045B
                    "Alt. Qty. Transaction No." := 0;                            // P8000045B

                    // P8000885
                    if Type = Type::Item then begin
                        GetItem(Item); // P80066030
                        if Item.TrackAlternateUnits and Item."Catch Alternate Qtys." then
                            AltQtyMgmt.AssignNewTransactionNo("Alt. Qty. Transaction No.")
                        else
                            "Alt. Qty. Transaction No." := 0;
                    end;
                    // P8000885
                end;

                CreateDimFromDefaultDim(Rec.FieldNo("No."));

                if "No." <> xRec."No." then begin
                    if Type = Type::Item then
                        if (Quantity <> 0) and ItemExists(xRec."No.") then begin
                            VerifyChangeForSalesLineReserve(FieldNo("No."));
                            WhseValidateSourceLine.SalesLineVerifyChange(Rec, xRec);
                        end;
                    GetDefaultBin();
                    AutoAsmToOrder();
                    DeleteItemChargeAssignment("Document Type", "Document No.", "Line No.");
                    if Type = Type::"Charge (Item)" then
                        DeleteChargeChargeAssgnt("Document Type", "Document No.", "Line No.");
                end;

                // P8000044A, P8000119A
                if ProcessFns.AccrualsInstalled() then
                    AccrualMgmt.SalesEndRecalcLines(Rec);
                // P8000044A

                UpdateItemReference();

                UpdateUnitPriceByField(FieldNo("No."));

                OnValidateNoOnAfterUpdateUnitPrice(Rec, xRec, TempSalesLine);
            end;
        }
        field(7; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                P800CoreFns.CheckSalesLineFieldEditable(Rec, FieldNo("Location Code"), CurrFieldNo); // PR3.61
                TestJobPlanningLine();
                TestStatusOpen();
                CheckAssocPurchOrder(FieldCaption("Location Code"));
                OnValidateLocationCodeOnAfterCheckAssocPurchOrder(Rec);
#if not CLEAN20                
                IsHandled := false;
                OnBeforeUpdateLocationCode(Rec, IsHandled);
#endif                
                if xRec."Location Code" <> "Location Code" then begin
                    if not FullQtyIsForAsmToOrder then begin
                        CalcFields("Reserved Qty. (Base)");
                        TestField("Reserved Qty. (Base)", "Qty. to Asm. to Order (Base)");
                    end;
                    TestField("Qty. Shipped Not Invoiced", 0);
                    TestField("Shipment No.", '');
                    TestField("Return Qty. Rcd. Not Invd.", 0);
                    TestField("Return Receipt No.", '');
                    AutoLotNo(false); // P8001234
                end;

                TestContainerQuantityIsZero; // P80046533

                GetSalesHeader();
                IsHandled := false;
                OnValidateLocationCodeOnBeforeSetShipmentDate(Rec, IsHandled);
                if not IsHandled then
                    CalcShipmentDateForLocation();
                SetOldestAcceptableDate; // P8001062

                CheckItemAvailable(FieldNo("Location Code"));

                if not "Drop Shipment" then begin
                    if "Location Code" = '' then begin
                        if InvtSetup.Get then
                            "Outbound Whse. Handling Time" := InvtSetup."Outbound Whse. Handling Time";
                    end else
                        if Location.Get("Location Code") then
                            "Outbound Whse. Handling Time" := Location."Outbound Whse. Handling Time";
                end else
                    Evaluate("Outbound Whse. Handling Time", '<0D>');

                OnValidateLocationCodeOnAfterSetOutboundWhseHandlingTime(Rec);

                if "Location Code" <> xRec."Location Code" then begin
                    InitItemAppl(true);
                    GetDefaultBin();
                    InitQtyToAsm();
                    AutoAsmToOrder();
                    if Quantity <> 0 then begin
                        if not "Drop Shipment" then
                            UpdateWithWarehouseShip();
                        if not FullReservedQtyIsForAsmToOrder then
                            VerifyChangeForSalesLineReserve(FieldNo("Location Code"));
                        WhseValidateSourceLine.SalesLineVerifyChange(Rec, xRec);
                    end;
                    if IsInventoriableItem() then
                        PostingSetupMgt.CheckInvtPostingSetupInventoryAccount("Location Code", "Posting Group");
                end;

                UpdateDates();

                if Type = Type::FOODContainer then             // PR3.61, P8000631A
                    ContainerFns.EditSalesLineLocation(Rec); // PR3.61, P8000631A

                if (Type in [Type::Item, Type::FOODContainer]) and ("No." <> '') then // PR3.61
                    GetUnitCost();

                CheckWMS();

                if "Document Type" = "Document Type"::"Return Order" then
                    ValidateReturnReasonCode(FieldNo("Location Code"));

                CreateDimFromDefaultDim(Rec.FieldNo("Location Code"));
            end;
        }
        field(8; "Posting Group"; Code[20])
        {
            Caption = 'Posting Group';
            Editable = false;
            TableRelation = IF (Type = CONST(Item)) "Inventory Posting Group"
            ELSE
            IF (Type = CONST("Fixed Asset")) "FA Posting Group";
        }
        field(10; "Shipment Date"; Date)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            Caption = 'Shipment Date';

            trigger OnValidate()
            var
                CheckDateConflict: Codeunit "Reservation-Check Date Confl.";
                IsHandled: boolean;
            begin
                IsHandled := false;
                OnBeforeValidateShipmentDate(IsHandled, Rec);
                if IsHandled then
                    exit;

                TestStatusOpen();
                WhseValidateSourceLine.SalesLineVerifyChange(Rec, xRec);
                OnValidateShipmentDateOnAfterSalesLineVerifyChange(Rec, CurrFieldNo);
                if CurrFieldNo <> 0 then
                    AddOnIntegrMgt.CheckReceiptOrderStatus(Rec);

                if "Shipment Date" <> 0D then begin
                    if CurrFieldNo in [
                                       FieldNo("Planned Shipment Date"),
                                       FieldNo("Planned Delivery Date"),
                                       FieldNo("Shipment Date"),
                                       FieldNo("Shipping Time"),
                                       FieldNo("Outbound Whse. Handling Time"),
                                       FieldNo("Requested Delivery Date")]
                    then
                        CheckItemAvailable(FieldNo("Shipment Date"));

                    CheckShipmentDateBeforeWorkDate();
                end;

                AutoAsmToOrder();
                if (xRec."Shipment Date" <> "Shipment Date") and
                   (Quantity <> 0) and
                   not StatusCheckSuspended
                then
                    CheckDateConflict.SalesLineCheck(Rec, CurrFieldNo <> 0);

                if not PlannedShipmentDateCalculated then
                    "Planned Shipment Date" := CalcPlannedShptDate(FieldNo("Shipment Date"));
                if not PlannedDeliveryDateCalculated then
                    "Planned Delivery Date" := CalcPlannedDeliveryDate(FieldNo("Shipment Date"));
                // P8000943
                if ("Document Type" = "Document Type"::"Return Order") and (xRec."Shipment Date" = "Receipt Date") then
                    "Receipt Date" := "Shipment Date";
                // P8000943
                SetOldestAcceptableDate; // P8001062
            end;
        }
        field(11; Description; Text[100])
        {
            Caption = 'Description';
            TableRelation = IF (Type = CONST("G/L Account"),
                                "System-Created Entry" = CONST(false)) "G/L Account".Name WHERE("Direct Posting" = CONST(true),
                                "Account Type" = CONST(Posting),
                                Blocked = CONST(false))
            ELSE
            IF (Type = CONST("G/L Account"), "System-Created Entry" = CONST(true)) "G/L Account".Name
            ELSE
            IF (Type = CONST(Item), "Document Type" = FILTER(<> "Credit Memo" & <> "Return Order")) Item.Description WHERE(Blocked = CONST(false),
                                                    "Sales Blocked" = CONST(false))
            ELSE
            IF (Type = CONST(Item), "Document Type" = FILTER("Credit Memo" | "Return Order")) Item.Description WHERE(Blocked = CONST(false))
            ELSE
            IF (Type = CONST(Resource)) Resource.Name
            ELSE
            IF (Type = CONST("Fixed Asset")) "Fixed Asset".Description
            ELSE
            IF (Type = CONST("Charge (Item)")) "Item Charge".Description;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                Item: Record Item;
                ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
                FindRecordMgt: Codeunit "Find Record Management";
                ReturnValue: Text[100];
                DescriptionIsNo: Boolean;
                DefaultCreate: Boolean;
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateDescription(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                if not HasTypeToFillMandatoryFields() then
                    exit;

                if "No." <> '' then
                    exit;

                case Type of
                    Type::Item:
                        begin
                            if StrLen(Description) <= MaxStrLen(Item."No.") then
                                DescriptionIsNo := Item.Get(Description)
                            else
                                DescriptionIsNo := false;

                            if not DescriptionIsNo then begin
                                Item.SetRange(Blocked, false);
                                if not IsCreditDocType() then
                                    Item.SetRange("Sales Blocked", false);

                                // looking for an item with exact description
                                Item.SetRange(Description, Description);
                                if Item.FindFirst() then begin
                                    Validate("No.", Item."No.");
                                    exit;
                                end;

                                // looking for an item with similar description
                                Item.SetFilter(Description, '''@' + ConvertStr(Description, '''', '?') + '''');
                                if Item.FindFirst() then begin
                                    Validate("No.", Item."No.");
                                    exit;
                                end;
                            end;

                            GetSalesSetup();
                            DefaultCreate := ("No." = '') and SalesSetup."Create Item from Description";
                            if Item.TryGetItemNoOpenCard(
                                 ReturnValue, Description, DefaultCreate, not GetHideValidationDialog, true)
                            then
                                case ReturnValue of
                                    '':
                                        begin
                                            LookupRequested := true;
                                            Description := xRec.Description;
                                        end;
                                    "No.":
                                        Description := xRec.Description;
                                    else begin
                                            CurrFieldNo := FieldNo("No.");
                                            Validate("No.", CopyStr(ReturnValue, 1, MaxStrLen(Item."No.")));
                                        end;
                                end;
                        end;
                    else begin
                            IsHandled := false;
                            OnBeforeFindNoByDescription(Rec, xRec, CurrFieldNo, IsHandled);
                            if not IsHandled then begin
                                ReturnValue := FindRecordMgt.FindNoByDescription(Type.AsInteger(), Description, true);
                                if ReturnValue <> '' then begin
                                    CurrFieldNo := FieldNo("No.");
                                    Validate("No.", CopyStr(ReturnValue, 1, MaxStrLen("No.")));
                                end;
                            end;
                        end;
                end;

                IsHandled := false;
                OnValidateDescriptionOnBeforeCannotFindDescrError(Rec, xRec, IsHandled);
                if not IsHandled then
                    if ("No." = '') and GuiAllowed then
                        if ApplicationAreaMgmtFacade.IsFoundationEnabled then
                            if "Document Type" in
                            ["Document Type"::Order, "Document Type"::Invoice, "Document Type"::Quote, "Document Type"::"Credit Memo"]
                            then
                                Error(CannotFindDescErr, Type, Description);
            end;
        }
        field(12; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
        }
        field(13; "Unit of Measure"; Text[50])
        {
            Caption = 'Unit of Measure';
            TableRelation = IF (Type = FILTER(<> " ")) "Unit of Measure".Description;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(15; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            var
                Item: Record Item;
                ItemLedgEntry: Record "Item Ledger Entry";
                IsHandled: Boolean;
            begin
                // P8000044A, P8000119A
                if ProcessFns.AccrualsInstalled() then
                    AccrualMgmt.SalesBeginRecalcLines(Rec);
                // P8000044A
                P800CoreFns.CheckSalesLineFieldEditable(Rec, FieldNo(Quantity), CurrFieldNo); // PR3.61
                Quantity := UOMMgt.RoundAndValidateQty(Quantity, "Qty. Rounding Precision", FieldCaption(Quantity));
                TestJobPlanningLine();
                TestStatusOpen();

                OnValidateQuantityOnBeforeCheckAssocPurchOrder(Rec);
                CheckAssocPurchOrder(FieldCaption(Quantity));

                if "Shipment No." <> '' then
                    CheckShipmentRelation()
                else
                    if "Return Receipt No." <> '' then
                        CheckRetRcptRelation();

                "Quantity (Base)" := CalcBaseQty(Quantity, FieldCaption(Quantity), FieldCaption("Quantity (Base)"));
                OnValidateQuantityOnAfterCalcBaseQty(Rec, xRec);

                if IsCreditDocType() then begin
                    if (Quantity * "Return Qty. Received" < 0) or
                       ((Abs(Quantity) < Abs("Return Qty. Received")) and ("Return Receipt No." = ''))
                    then
                        FieldError(Quantity, StrSubstNo(Text003, FieldCaption("Return Qty. Received")));
                    if ("Quantity (Base)" * "Return Qty. Received (Base)" < 0) or
                       ((Abs("Quantity (Base)") < Abs("Return Qty. Received (Base)")) and ("Return Receipt No." = ''))
                    then
                        FieldError("Quantity (Base)", StrSubstNo(Text003, FieldCaption("Return Qty. Received (Base)")));
                end else begin
                    if (Quantity * "Quantity Shipped" < 0) or
                       ((Abs(Quantity) < Abs("Quantity Shipped")) and ("Shipment No." = ''))
                    then
                        FieldError(Quantity, StrSubstNo(Text003, FieldCaption("Quantity Shipped")));
                    if ("Quantity (Base)" * "Qty. Shipped (Base)" < 0) or
                       ((Abs("Quantity (Base)") < Abs("Qty. Shipped (Base)")) and ("Shipment No." = ''))
                    then
                        FieldError("Quantity (Base)", StrSubstNo(Text003, FieldCaption("Qty. Shipped (Base)")));
                end;

                if (Type = Type::"Charge (Item)") and (CurrFieldNo <> 0) then begin
                    if (Quantity = 0) and ("Qty. to Assign" <> 0) then
                        FieldError("Qty. to Assign", StrSubstNo(Text009, FieldCaption(Quantity), Quantity));
                    if (Quantity * "Qty. Assigned" < 0) or (Abs(Quantity) < Abs("Qty. Assigned")) then
                        FieldError(Quantity, StrSubstNo(Text003, FieldCaption("Qty. Assigned")));
                end;

                CheckRetentionAttachedToLineNo();

                IsHandled := false;
                OnValidateQuantityOnBeforeCheckReceiptOrderStatus(Rec, StatusCheckSuspended, IsHandled);
                if not IsHandled then
                    AddOnIntegrMgt.CheckReceiptOrderStatus(Rec);

                InitQty();

                CheckItemAvailable(FieldNo(Quantity));

                if (Quantity * xRec.Quantity < 0) or (Quantity = 0) then
                    InitItemAppl(false);

                if (xRec.Quantity <> Quantity) or (xRec."Quantity (Base)" <> "Quantity (Base)") then
                    PlanPriceCalcByField(FieldNo(Quantity));
                UpdateUnitPriceByField(FieldNo(Quantity)); // P800145564 - moved from below

                if Type = Type::Item then begin
                    if (xRec.Quantity <> Quantity) or (xRec."Quantity (Base)" <> "Quantity (Base)") then begin
                        UpdateLotTracking(false, 0); // P8000043A, P8000466A
                        OnBeforeVerifyReservedQty(Rec, xRec, FieldNo(Quantity));
                        SalesLineReserve.VerifyQuantity(Rec, xRec);
                        if not "Drop Shipment" then
                            UpdateWithWarehouseShip();
                        SetAltQtyWithNoHandling; // P8000818

                        IsHandled := false;
                        OnValidateQuantityOnBeforeSalesLineVerifyChange(Rec, StatusCheckSuspended, IsHandled);
                        if (not IsHandled) and not ("Allow Quantity Change") then // P8000715
                            WhseValidateSourceLine.SalesLineVerifyChange(Rec, xRec);
                        if ("Quantity (Base)" * xRec."Quantity (Base)" <= 0) and ("No." <> '') then begin
                            GetItem(Item);
                            OnValidateQuantityOnBeforeGetUnitCost(Rec, Item);
                            if (Item."Costing Method" = Item."Costing Method"::Standard) and not IsShipment then
                                GetUnitCost();
                        end;
                    end;
                    IsHandled := FALSE;
                    OnValidateQuantityOnBeforeValidateQtyToAssembleToOrder(Rec, StatusCheckSuspended, IsHandled);
                    if not IsHandled then
                        Validate("Qty. to Assemble to Order");
                    if (Quantity = "Quantity Invoiced") and (CurrFieldNo <> 0) then
                        CheckItemChargeAssgnt();
                    CheckApplFromItemLedgEntry(ItemLedgEntry);
                    // P8001324
                end else
                    if (CurrFieldNo = FieldNo(Quantity)) and (Type = Type::FOODContainer) and ("Document Type" = "Document Type"::"Return Order") then begin
                        if "Outstanding Quantity" < GetContainerQuantity('') then   // P80046533
                            Error(Text37002013, FieldCaption("Outstanding Quantity")); // P80046533
                                                                                       // P8001324
                    end else
                        Validate("Line Discount %");

                IsHandled := false;
                OnValidateQuantityOnBeforeResetAmounts(Rec, xRec, IsHandled);
                if not IsHandled then
                    if (xRec.Quantity <> Quantity) and (Quantity = 0) and
                       ((Amount <> 0) or ("Amount Including VAT" <> 0) or ("VAT Base Amount" <> 0))
                    then begin
                        Amount := 0;
                        "Amount Including VAT" := 0;
                        "VAT Base Amount" := 0;
                    end;

                // UpdateUnitPriceByField(FieldNo(Quantity)); // P800145564 - moved up
                UpdatePrePaymentAmounts();

                CheckWMS();

                UpdatePlanned();

                Validate("Original Quantity", Quantity); // PR1.00

                if "Document Type" = "Document Type"::"Return Order" then
                    ValidateReturnReasonCode(FieldNo(Quantity));

                // P8000044A, P8000119A
                if ProcessFns.AccrualsInstalled() then
                    AccrualMgmt.SalesEndRecalcLines(Rec);
                // P8000044A
            end;
        }
        field(16; "Outstanding Quantity"; Decimal)
        {
            Caption = 'Outstanding Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(17; "Qty. to Invoice"; Decimal)
        {
            Caption = 'Qty. to Invoice';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                "Qty. to Invoice" := UOMMgt.RoundAndValidateQty("Qty. to Invoice", "Qty. Rounding Precision", FieldCaption("Qty. to Invoice"));
                if "Qty. to Invoice" = MaxQtyToInvoice then
                    InitQtyToInvoice()
                else begin
                    "Qty. to Invoice (Base)" := CalcBaseQty("Quantity Invoiced" + "Qty. to Invoice", FieldCaption("Qty. to Invoice"), FieldCaption("Qty. to Invoice (Base)")) - "Qty. Invoiced (Base)"; // P8000550A
                    if ("Quantity (Base)" = ("Qty. Invoiced (Base)" + "Qty. to Invoice (Base)")) and ("Qty. to Invoice" > 0) then
                        Error(QuantityImbalanceErr, ItemUOMForCaption.FieldCaption("Qty. Rounding Precision"), Type::Item, "No.", FieldCaption("Qty. to Invoice"), FieldCaption("Qty. to Invoice (Base)"));
                end;

                // P8000342A - move up from end of trigger
                UpdateLotTracking(false, 0); // P8000043A, P8000466A

                if TrackAlternateUnits then // PR3.60
                    SetSalesLineAltQty;       // P8000408A

                if ("Qty. to Invoice" * Quantity < 0) or
                   (Abs("Qty. to Invoice") > Abs(MaxQtyToInvoice))
                then
                    Error(Text005, MaxQtyToInvoice);

                if ("Qty. to Invoice (Base)" * "Quantity (Base)" < 0) or
                   (Abs("Qty. to Invoice (Base)") > Abs(MaxQtyToInvoiceBase))
                then
                    Error(Text006, MaxQtyToInvoiceBase);

                "VAT Difference" := 0;
                CalcInvDiscToInvoice();
                CalcPrepaymentToDeduct();
            end;
        }
        field(18; "Qty. to Ship"; Decimal)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            Caption = 'Qty. to Ship';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            var
                ItemLedgEntry: Record "Item Ledger Entry";
                IsHandled: Boolean;
                ReleaseSalesDoc: Codeunit "Release Sales Document";
                OriginalStatus: Integer;
                ContainerQuantity: Decimal;
            begin
                P800CoreFns.CheckSalesLineFieldEditable(Rec, FieldNo("Qty. to Ship"), CurrFieldNo); // PR3.61
                // P80070336
                if ((CurrFieldNo = FieldNo("Qty. to Ship")) and PriceInAlternateUnits) then
                    TestStatusOpen;
                // P80070336
                "Qty. to Ship" := UOMMgt.RoundAndValidateQty("Qty. to Ship", "Qty. Rounding Precision", FieldCaption("Qty. to Ship"));

                WarehouseUpdate[2] := WarehouseUpdate[1]; // PR3.60.02
                WarehouseUpdate[1] := false;              // PR3.60.02
                GetLocation("Location Code");
                CheckWarehouseForQtyToShip();

                if CurrFieldNo <> 0 then // P80046533
                                         // PR3.61 Begin
                    if GetContainerQuantity(true) > 0 then // P80046533
                        if "Qty. to Ship" < GetContainerQuantity(true) then // P80046533
                            FieldError("Qty. to Ship", Text37002003);
                // PR3.61 End

                OnValidateQtyToShipOnAfterCheck(Rec, CurrFieldNo);

                ContainerQuantity := GetContainerQuantity(''); // P800131478
                if "Qty. to Ship" = "Outstanding Quantity" - ContainerQuantity then // P80046533, P800131478
                    InitQtyToShip()
                else begin
                    "Qty. to Ship (Base)" := CalcBaseQty("Quantity Shipped" + "Qty. to Ship", FieldCaption("Qty. to Ship"), FieldCaption("Qty. to Ship (Base)")) - "Qty. Shipped (Base)"; // P8000550A
                    if ("Quantity (Base)" = ("Qty. Shipped (Base)" + "Qty. to Ship (Base)")) and ("Qty. to Ship" > 0) and (ContainerQuantity = 0) then // P800131478
                        Error(QuantityImbalanceErr, ItemUOMForCaption.FieldCaption("Qty. Rounding Precision"), Type::Item, "No.", FieldCaption("Qty. to Ship"), FieldCaption("Qty. to Ship (Base)"));

                    // PR3.60.03
                    if (Type = Type::Item) and ("No." <> '') and TrackAlternateUnits then
                        // P8000550A
                        // AltQtyMgmt.InitAlternateQty("No.", "Alt. Qty. Transaction No.",
                        //                             "Qty. to Ship" * "Qty. per Unit of Measure", "Qty. to Ship (Alt.)");
                        AltQtyMgmt.InitAlternateQtyToHandle(
                      "No.", "Alt. Qty. Transaction No.", "Quantity (Base)", "Qty. to Ship (Base)",
                      "Qty. Shipped (Base)", "Quantity (Alt.)", "Qty. Shipped (Alt.)", "Qty. to Ship (Alt.)");
                    // P8000550A
                    // PR3.60.03

                    CheckServItemCreation();
                    InitQtyToInvoice();
                end;

                IsHandled := false;
                OnValidateQtyToShipAfterInitQty(Rec, xRec, CurrFieldNo, IsHandled);
                if not IsHandled then begin
                    if ("Document Type" = "Document Type"::Order) then // PR3.60
                        if CurrFieldNo <> 0 then begin // PR1.00
                            if ((("Qty. to Ship" < 0) xor (Quantity < 0)) and (Quantity <> 0) and ("Qty. to Ship" <> 0)) or
                               ((Abs("Qty. to Ship") + GetContainerQuantity(false)) > Abs("Outstanding Quantity")) or // P80046533
                               (((Quantity < 0) xor ("Outstanding Quantity" < 0)) and (Quantity <> 0) and ("Outstanding Quantity" <> 0))
                            then begin // PR1.00
                                //    ERROR(
                                //      Text007, "Outstanding Quantity");
                                // PR1.00 Begin
                                if Confirm(Text37002000, false) then begin
                                    // P8000352A
                                    GetSalesHeader;
                                    OriginalStatus := SalesHeader.Status;
                                    // IF OriginalStatus = SalesHeader.Status::Released THEN BEGIN // P8000466A
                                    if OriginalStatus <> SalesHeader.Status::Open then begin       // P8000466A
                                        Modify;
                                        ReleaseSalesDoc.Reopen(SalesHeader);
                                        Find;
                                    end;
                                    // P8000352A
                                    "Bypass Credit Check" := true;  // P8000264
                                    Validate(Quantity, Quantity + "Qty. to Ship" + GetContainerQuantity(false) - "Outstanding Quantity"); // P80046533
                                    Validate("Line Discount %"); // P8000295A
                                    "Bypass Credit Check" := false; // P8000264
                                    Validate("Original Quantity", xRec."Original Quantity");
                                    // P8000352A
                                    // IF OriginalStatus = SalesHeader.Status::Released THEN BEGIN // P8000466A
                                    if OriginalStatus <> SalesHeader.Status::Open then begin       // P8000466A
                                        Modify;
                                        ReleaseSalesDoc.SetSkipCheckReleaseRestrictions; // P80098163
                                        ReleaseSalesDoc.Run(SalesHeader);
                                        Find;
                                    end;
                                    // P8000352A
                                end else
                                    Error(Text37002002);
                            end;
                            if (((("Qty. to Ship" < 0) xor (Quantity < 0)) and ("Qty. to Ship" <> 0) and (Quantity <> 0)) or // P8001213, P8001296
                                ((Abs("Qty. to Ship") + GetContainerQuantity(false)) < Abs("Outstanding Quantity")) or // P80046533
                                (((Quantity < 0) xor ("Outstanding Quantity" < 0)) and (Quantity <> 0) and ("Outstanding Quantity" <> 0))) and // P8001213, P8001296
                               (not WarehouseUpdate[2]) // PR3.60.02
                            then begin
                                if not Confirm(Text37002001, true) then begin
                                    // P8000352A
                                    GetSalesHeader;
                                    OriginalStatus := SalesHeader.Status;
                                    // IF OriginalStatus = SalesHeader.Status::Released THEN BEGIN // P8000466A
                                    if OriginalStatus <> SalesHeader.Status::Open then begin       // P8000466A
                                        Modify;
                                        ReleaseSalesDoc.Reopen(SalesHeader);
                                        Find;
                                    end;
                                    // P8000352A
                                    "Bypass Credit Check" := true;  // P8000264
                                    Validate(Quantity, Quantity + "Qty. to Ship" + GetContainerQuantity(false) - "Outstanding Quantity"); // P80046533
                                    Validate("Line Discount %"); // P8000295A
                                    "Bypass Credit Check" := false; // P8000264
                                    Validate("Original Quantity", xRec."Original Quantity");
                                    // P8000352A
                                    // IF OriginalStatus = SalesHeader.Status::Released THEN BEGIN // P8000466A
                                    if OriginalStatus <> SalesHeader.Status::Open then begin       // P8000466A
                                        Modify;
                                        ReleaseSalesDoc.ExitIfNothingToRelease; // P8000398A
                                        ReleaseSalesDoc.Run(SalesHeader);       // P8000398A
                                        if Find then;                           // P8000398A
                                    end;
                                    // P8000352A
                                end;
                            end;
                        end;
                    // PR1.00 End
                    if ("Document Type" <> "Document Type"::FOODStandingOrder) then // PR3.60
                        if ((("Qty. to Ship (Base)" < 0) xor ("Quantity (Base)" < 0)) and ("Qty. to Ship (Base)" <> 0) and ("Quantity (Base)" <> 0)) or
                           (Abs("Qty. to Ship (Base)") > Abs("Outstanding Qty. (Base)")) or
                           ((("Quantity (Base)" < 0) xor ("Outstanding Qty. (Base)" < 0)) and ("Quantity (Base)" <> 0) and ("Outstanding Qty. (Base)" <> 0))
                        then
                            Error(Text008, "Outstanding Qty. (Base)");
                end;

                if (CurrFieldNo <> 0) and (Type = Type::Item) and ("Qty. to Ship" < 0) then
                    CheckApplFromItemLedgEntry(ItemLedgEntry);

                UpdateQtyToAsmFromSalesLineQtyToShip();

                UpdateLotTracking(false, 0); // P8000043A, P8000466A
            end;
        }
        field(22; "Unit Price"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            CaptionClass = GetCaptionClass(FieldNo("Unit Price"));
            Caption = 'Unit Price';

            trigger OnValidate()
            var
                PriceCalculation: Interface "Price Calculation";
            begin
                if ("Prepmt. Amt. Inv." <> 0) and
                   ("Unit Price" <> xRec."Unit Price") and not IsServiceChargeLine()
                then
                    FieldError("Unit Price", StrSubstNo(Text1020001, xRec."Unit Price"));

                CorrectUnitPriceFOB; // P8000921

                // P8000044A, P8000119A
                if ProcessFns.AccrualsInstalled() then
                    AccrualMgmt.SalesBeginNewPriceLines(Rec);
                // P8000044A

                P800CoreFns.CheckSalesLineFieldEditable(Rec, FieldNo("Unit Price"), CurrFieldNo); // PR3.61

                // PR3.60
                // IF (CurrFieldNo = FIELDNO("Unit Price")) AND                              // P8000921
                if (CurrFieldNo in [FieldNo("Unit Price"), FieldNo("Unit Price (FOB)")]) and // P8000921
                   ("Unit Price" <> xRec."Unit Price")
                then begin // P8000885 - added BEGIN and END below
                    TestField("Contract No.", ''); // P8000885
                    "Price ID" := 0;
                    GetSalesHeader;                                       // P8001178
                    "Allow Line Disc." := SalesHeader."Allow Line Disc."; // P8001178
                end;
                // PR3.60

                if (Type = Type::Item) and "Allow Line Disc." then begin    // P8000440A, P8001178
                    GetPriceCalculationHandler(PriceType::Sale, SalesHeader, PriceCalculation);
                    ApplyDiscount(PriceCalculation); // P8000440A
                end;
                Validate("Line Discount %");

                // P8000044A, P8000119A
                if ProcessFns.AccrualsInstalled() then
                    AccrualMgmt.SalesEndNewPriceLines(Rec, (CurrFieldNo = FieldNo("Unit Price")) or SettingUnitPrice); // P8006632
                // P8000044A
            end;
        }
        field(23; "Unit Cost (LCY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost (LCY)';

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if (CurrFieldNo = FieldNo("Unit Cost (LCY)")) and
                   ("Unit Cost (LCY)" <> xRec."Unit Cost (LCY)")
                then
                    CheckAssocPurchOrder(FieldCaption("Unit Cost (LCY)"));

                if (CurrFieldNo = FieldNo("Unit Cost (LCY)")) and
                   (Type = Type::Item) and ("No." <> '') and ("Quantity (Base)" <> 0)
                then begin
                    TestJobPlanningLine();
                    GetItem(Item);
                    if (Item."Costing Method" = Item."Costing Method"::Standard) and not IsShipment then begin
                        if IsCreditDocType() then
                            Error(
                              Text037,
                              FieldCaption("Unit Cost (LCY)"), Item.FieldCaption("Costing Method"),
                              Item."Costing Method", FieldCaption(Quantity));
                        Error(
                          Text038,
                          FieldCaption("Unit Cost (LCY)"), Item.FieldCaption("Costing Method"),
                          Item."Costing Method", FieldCaption(Quantity));
                    end;
                end;

                GetSalesHeader();
                if SalesHeader."Currency Code" <> '' then begin
                    Currency.TestField("Unit-Amount Rounding Precision");
                    "Unit Cost" :=
                      Round(
                        CurrExchRate.ExchangeAmtLCYToFCY(
                          GetDate, SalesHeader."Currency Code",
                          "Unit Cost (LCY)", SalesHeader."Currency Factor"),
                        Currency."Unit-Amount Rounding Precision")
                end else
                    "Unit Cost" := "Unit Cost (LCY)";
            end;
        }
        field(25; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(27; "Line Discount %"; Decimal)
        {
            Caption = 'Line Discount %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;

            trigger OnValidate()
            begin
                ValidateLineDiscountPercent(true);
                NotifyOnMissingSetup(FieldNo("Line Discount Amount"));
            end;
        }
        field(28; "Line Discount Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Line Discount Amount';

            trigger OnValidate()
            begin
                GetSalesHeader();
                "Line Discount Amount" := Round("Line Discount Amount", Currency."Amount Rounding Precision");
                TestJobPlanningLine();
                TestStatusOpen();
                TestQtyFromLindDiscountAmount();
                if xRec."Line Discount Amount" <> "Line Discount Amount" then
                    UpdateLineDiscPct();
                "Inv. Discount Amount" := 0;
                "Inv. Disc. Amount to Invoice" := 0;
                UpdateAmounts();
                NotifyOnMissingSetup(FieldNo("Line Discount Amount"));
            end;
        }
        field(29; Amount; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount';
            Editable = false;

            trigger OnValidate()
            begin
                Amount := Round(Amount, Currency."Amount Rounding Precision");
                case "VAT Calculation Type" of
                    "VAT Calculation Type"::"Normal VAT",
                    "VAT Calculation Type"::"Reverse Charge VAT":
                        begin
                            "VAT Base Amount" :=
                              Round(Amount * (1 - SalesHeader."VAT Base Discount %" / 100), Currency."Amount Rounding Precision");
                            "Amount Including VAT" :=
                              Round(Amount + "VAT Base Amount" * "VAT %" / 100, Currency."Amount Rounding Precision");
                        end;
                    "VAT Calculation Type"::"Full VAT":
                        if Amount <> 0 then
                            FieldError(Amount,
                              StrSubstNo(
                                Text009, FieldCaption("VAT Calculation Type"),
                                "VAT Calculation Type"));
                    "VAT Calculation Type"::"Sales Tax":
                        begin
                            SalesHeader.TestField("VAT Base Discount %", 0);
                            "VAT Base Amount" := Round(Amount, Currency."Amount Rounding Precision");
                            "Amount Including VAT" :=
                              Amount +
                              SalesTaxCalculate.CalculateTax(
                                "Tax Area Code", "Tax Group Code", "Tax Liable", SalesHeader."Posting Date",
                                "VAT Base Amount", GetPricingQuantity(FieldNo(Quantity), 'BASE'), SalesHeader."Currency Factor"); // P8001366
                            OnAfterSalesTaxCalculate(Rec, SalesHeader, Currency);
                            UpdateVATPercent("VAT Base Amount", "Amount Including VAT" - "VAT Base Amount");
                            "Amount Including VAT" := Round("Amount Including VAT", Currency."Amount Rounding Precision");
                        end;
                end;

                InitOutstandingAmount();
            end;
        }
        field(30; "Amount Including VAT"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount Including VAT';
            Editable = false;

            trigger OnValidate()
            begin
                "Amount Including VAT" := Round("Amount Including VAT", Currency."Amount Rounding Precision");
                case "VAT Calculation Type" of
                    "VAT Calculation Type"::"Normal VAT",
                    "VAT Calculation Type"::"Reverse Charge VAT":
                        begin
                            Amount :=
                              Round(
                                "Amount Including VAT" /
                                (1 + (1 - SalesHeader."VAT Base Discount %" / 100) * "VAT %" / 100),
                                Currency."Amount Rounding Precision");
                            "VAT Base Amount" :=
                              Round(Amount * (1 - SalesHeader."VAT Base Discount %" / 100), Currency."Amount Rounding Precision");
                        end;
                    "VAT Calculation Type"::"Full VAT":
                        begin
                            Amount := 0;
                            "VAT Base Amount" := 0;
                        end;
                    "VAT Calculation Type"::"Sales Tax":
                        begin
                            SalesHeader.TestField("VAT Base Discount %", 0);
                            Amount :=
                              SalesTaxCalculate.ReverseCalculateTax(
                                "Tax Area Code", "Tax Group Code", "Tax Liable", SalesHeader."Posting Date",
                                "Amount Including VAT", GetPricingQuantity(FieldNo(Quantity), 'BASE'), SalesHeader."Currency Factor"); // P8001366
                            OnAfterSalesTaxCalculateReverse(Rec, SalesHeader, Currency);
                            UpdateVATPercent(Amount, "Amount Including VAT" - Amount);
                            Amount := Round(Amount, Currency."Amount Rounding Precision");
                            "VAT Base Amount" := Amount;
                        end;
                end;
                OnValidateAmountIncludingVATOnAfterAssignAmounts(Rec, Currency);

                InitOutstandingAmount();
            end;
        }
        field(32; "Allow Invoice Disc."; Boolean)
        {
            Caption = 'Allow Invoice Disc.';
            InitValue = true;

            trigger OnValidate()
            begin
                TestStatusOpen();
                if ("VAT Calculation Type" = "VAT Calculation Type"::"Full VAT") and "Allow Invoice Disc." then
                    Error(CannotAllowInvDiscountErr, FieldCaption("Allow Invoice Disc."));

                if "Allow Invoice Disc." <> xRec."Allow Invoice Disc." then begin
                    if not "Allow Invoice Disc." then begin
                        "Inv. Discount Amount" := 0;
                        "Inv. Disc. Amount to Invoice" := 0;
                    end;
                    UpdateAmounts();

                    // PR3.70.03
                    if ProcessFns.AccrualsInstalled() then
                        AccrualMgmt.SalesRecalcLines(Rec);
                    // PR3.70.03
                end;
            end;
        }
        field(34; "Gross Weight"; Decimal)
        {
            Caption = 'Gross Weight';
            DecimalPlaces = 0 : 5;
        }
        field(35; "Net Weight"; Decimal)
        {
            Caption = 'Net Weight';
            DecimalPlaces = 0 : 5;
        }
        field(36; "Units per Parcel"; Decimal)
        {
            Caption = 'Units per Parcel';
            DecimalPlaces = 0 : 5;
        }
        field(37; "Unit Volume"; Decimal)
        {
            Caption = 'Unit Volume';
            DecimalPlaces = 0 : 5;
        }
        field(38; "Appl.-to Item Entry"; Integer)
        {
            AccessByPermission = TableData Item = R;
            Caption = 'Appl.-to Item Entry';

            trigger OnLookup()
            begin
                SelectItemEntry(FieldNo("Appl.-to Item Entry"));
            end;

            trigger OnValidate()
            var
                ItemLedgEntry: Record "Item Ledger Entry";
            begin
                if "Appl.-to Item Entry" <> 0 then begin
                    AddOnIntegrMgt.CheckReceiptOrderStatus(Rec);

                    TestField(Type, Type::Item);
                    TestField(Quantity);
                    CheckQuantitySign();
                    ItemLedgEntry.Get("Appl.-to Item Entry");
                    ItemLedgEntry.TestField(Positive, true);
                    ItemLedgEntry.CheckTrackingDoesNotExist(RecordId, FieldCaption("Appl.-to Item Entry"));
                    if Abs("Qty. to Ship (Base)") > ItemLedgEntry.Quantity then
                        Error(ShippingMoreUnitsThanReceivedErr, ItemLedgEntry.Quantity, ItemLedgEntry."Document No.");

                    Validate("Unit Cost (LCY)", CalcUnitCost(ItemLedgEntry));

                    "Location Code" := ItemLedgEntry."Location Code";
                    if not ItemLedgEntry.Open then
                        Message(Text042, "Appl.-to Item Entry");
                end;
            end;
        }
        field(40; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1),
                                                          Blocked = CONST(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
                ATOLink.UpdateAsmDimFromSalesLine(Rec);
            end;
        }
        field(41; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2),
                                                          Blocked = CONST(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
                ATOLink.UpdateAsmDimFromSalesLine(Rec);
            end;
        }
        field(42; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            Editable = false;
            TableRelation = "Customer Price Group";

            trigger OnValidate()
            begin
                if Type = Type::Item then begin
                    if "Customer Price Group" <> xRec."Customer Price Group" then
                        PlanPriceCalcByField(FieldNo("Customer Price Group"));
                    UpdateUnitPriceByField(FieldNo("Customer Price Group"));
                end;
            end;
        }
        field(45; "Job No."; Code[20])
        {
            Caption = 'Job No.';
            Editable = false;
            TableRelation = Job;
        }
        field(52; "Work Type Code"; Code[10])
        {
            Caption = 'Work Type Code';
            TableRelation = "Work Type";

            trigger OnValidate()
            var
                WorkType: Record "Work Type";
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateWorkTypeCode(xRec, IsHandled);
                if IsHandled then
                    exit;

                if Type = Type::Resource then begin
                    TestStatusOpen();
                    if WorkType.Get("Work Type Code") then
                        Validate("Unit of Measure Code", WorkType."Unit of Measure Code");
                    if "Work Type Code" <> xRec."Work Type Code" then
                        PlanPriceCalcByField(FieldNo("Work Type Code"));
                    UpdateUnitPriceByField(FieldNo("Work Type Code"));
                    ApplyResUnitCost(FieldNo("Work Type Code"));
                end;
            end;
        }
        field(56; "Recalculate Invoice Disc."; Boolean)
        {
            Caption = 'Recalculate Invoice Disc.';
            Editable = false;
        }
        field(57; "Outstanding Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Outstanding Amount';
            Editable = false;

            trigger OnValidate()
            var
                Currency2: Record Currency;
            begin
                GetSalesHeader();
                Currency2.InitRoundingPrecision;
                if SalesHeader."Currency Code" <> '' then
                    "Outstanding Amount (LCY)" :=
                      Round(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                          GetDate, "Currency Code",
                          "Outstanding Amount", SalesHeader."Currency Factor"),
                        Currency2."Amount Rounding Precision")
                else
                    "Outstanding Amount (LCY)" :=
                      Round("Outstanding Amount", Currency2."Amount Rounding Precision");
            end;
        }
        field(58; "Qty. Shipped Not Invoiced"; Decimal)
        {
            Caption = 'Qty. Shipped Not Invoiced';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(59; "Shipped Not Invoiced"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Shipped Not Invoiced';
            Editable = false;

            trigger OnValidate()
            var
                Currency2: Record Currency;
            begin
                GetSalesHeader();
                Currency2.InitRoundingPrecision;
                if SalesHeader."Currency Code" <> '' then
                    "Shipped Not Invoiced (LCY)" :=
                      Round(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                          GetDate, "Currency Code",
                          "Shipped Not Invoiced", SalesHeader."Currency Factor"),
                        Currency2."Amount Rounding Precision")
                else
                    "Shipped Not Invoiced (LCY)" :=
                      Round("Shipped Not Invoiced", Currency2."Amount Rounding Precision");

                CalculateNotShippedInvExlcVatLCY();
            end;
        }
        field(60; "Quantity Shipped"; Decimal)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            Caption = 'Quantity Shipped';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(61; "Quantity Invoiced"; Decimal)
        {
            Caption = 'Quantity Invoiced';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(63; "Shipment No."; Code[20])
        {
            Caption = 'Shipment No.';
            Editable = false;
        }
        field(64; "Shipment Line No."; Integer)
        {
            Caption = 'Shipment Line No.';
            Editable = false;
        }
        field(67; "Profit %"; Decimal)
        {
            Caption = 'Profit %';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(68; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            Editable = false;
            TableRelation = Customer;
        }
        field(69; "Inv. Discount Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CaptionClass = GetCaptionClass(FieldNo("Inv. Discount Amount"));
            Caption = 'Inv. Discount Amount';
            Editable = false;

            trigger OnValidate()
            begin
                CalcInvDiscToInvoice();
                UpdateAmounts();

                // PR3.70.03
                if ProcessFns.AccrualsInstalled() then
                    AccrualMgmt.SalesRecalcLines(Rec);
                // PR3.70.03
            end;
        }
        field(71; "Purchase Order No."; Code[20])
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            Caption = 'Purchase Order No.';
            Editable = false;
            TableRelation = IF ("Drop Shipment" = CONST(true)) "Purchase Header"."No." WHERE("Document Type" = CONST(Order));

            trigger OnValidate()
            begin
                if (xRec."Purchase Order No." <> "Purchase Order No.") and (Quantity <> 0) then begin
                    VerifyChangeForSalesLineReserve(FieldNo("Purchase Order No."));
                    WhseValidateSourceLine.SalesLineVerifyChange(Rec, xRec);
                end;
            end;
        }
        field(72; "Purch. Order Line No."; Integer)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            Caption = 'Purch. Order Line No.';
            Editable = false;
            TableRelation = IF ("Drop Shipment" = CONST(true)) "Purchase Line"."Line No." WHERE("Document Type" = CONST(Order),
                                                                                               "Document No." = FIELD("Purchase Order No."));

            trigger OnValidate()
            begin
                if (xRec."Purch. Order Line No." <> "Purch. Order Line No.") and (Quantity <> 0) then begin
                    VerifyChangeForSalesLineReserve(FieldNo("Purch. Order Line No."));
                    WhseValidateSourceLine.SalesLineVerifyChange(Rec, xRec);
                end;
            end;
        }
        field(73; "Drop Shipment"; Boolean)
        {
            AccessByPermission = TableData "Drop Shpt. Post. Buffer" = R;
            Caption = 'Drop Shipment';
            Editable = true;

            trigger OnValidate()
            begin
                TestField("Document Type", "Document Type"::Order);
                TestField(Type, Type::Item);
                TestField("Quantity Shipped", 0);
                TestField("Job No.", '');
                TestField("Qty. to Asm. to Order (Base)", 0);

                if "Drop Shipment" then
                    TestField("Special Order", false);

                CheckAssocPurchOrder(FieldCaption("Drop Shipment"));

                if "Special Order" then
                    Reserve := Reserve::Never
                else
                    if "Drop Shipment" then begin
                        Reserve := Reserve::Never;
                        Evaluate("Outbound Whse. Handling Time", '<0D>');
                        Evaluate("Shipping Time", '<0D>');
                        UpdateDates();
                        "Bin Code" := '';
                    end else
                        SetReserveWithoutPurchasingCode();

                CheckItemAvailable(FieldNo("Drop Shipment"));

                AddOnIntegrMgt.CheckReceiptOrderStatus(Rec);
                if (xRec."Drop Shipment" <> "Drop Shipment") and (Quantity <> 0) then begin
                    if not "Drop Shipment" then begin
                        InitQtyToAsm();
                        AutoAsmToOrder();
                        UpdateWithWarehouseShip();
                    end else
                        InitQtyToShip();
                    WhseValidateSourceLine.SalesLineVerifyChange(Rec, xRec);
                    if not FullReservedQtyIsForAsmToOrder() then
                        VerifyChangeForSalesLineReserve(FieldNo("Drop Shipment"));
                end;
            end;
        }
        field(74; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";

            trigger OnValidate()
            begin
                if xRec."Gen. Bus. Posting Group" <> "Gen. Bus. Posting Group" then
                    if GenBusPostingGrp.ValidateVatBusPostingGroup(GenBusPostingGrp, "Gen. Bus. Posting Group") then
                        Validate("VAT Bus. Posting Group", GenBusPostingGrp."Def. VAT Bus. Posting Group");
            end;
        }
        field(75; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";

            trigger OnValidate()
            begin
                TestJobPlanningLine();
                TestStatusOpen();
                if xRec."Gen. Prod. Posting Group" <> "Gen. Prod. Posting Group" then
                    if GenProdPostingGrp.ValidateVatProdPostingGroup(GenProdPostingGrp, "Gen. Prod. Posting Group") then
                        Validate("VAT Prod. Posting Group", GenProdPostingGrp."Def. VAT Prod. Posting Group");
            end;
        }
        field(77; "VAT Calculation Type"; Enum "Tax Calculation Type")
        {
            Caption = 'VAT Calculation Type';
            Editable = false;
        }
        field(78; "Transaction Type"; Code[10])
        {
            Caption = 'Transaction Type';
            TableRelation = "Transaction Type";
        }
        field(79; "Transport Method"; Code[10])
        {
            Caption = 'Transport Method';
            TableRelation = "Transport Method";
        }
        field(80; "Attached to Line No."; Integer)
        {
            Caption = 'Attached to Line No.';
            Editable = false;
            TableRelation = "Sales Line"."Line No." WHERE("Document Type" = FIELD("Document Type"),
                                                           "Document No." = FIELD("Document No."));
        }
        field(81; "Exit Point"; Code[10])
        {
            Caption = 'Exit Point';
            TableRelation = "Entry/Exit Point";
        }
        field(82; "Area"; Code[10])
        {
            Caption = 'Area';
            TableRelation = Area;
        }
        field(83; "Transaction Specification"; Code[10])
        {
            Caption = 'Transaction Specification';
            TableRelation = "Transaction Specification";
        }
        field(84; "Tax Category"; Code[10])
        {
            Caption = 'Tax Category';
        }
        field(85; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            TableRelation = "Tax Area";

            trigger OnValidate()
            var
                TaxArea: Record "Tax Area";
                HeaderTaxArea: Record "Tax Area";
            begin
                GetSalesHeader;
                SalesHeader.TestField(Status, SalesHeader.Status::Open);
                if "Tax Area Code" <> '' then begin
                    TaxArea.Get("Tax Area Code");
                    SalesHeader.TestField("Tax Area Code");
                    HeaderTaxArea.Get(SalesHeader."Tax Area Code");
                    if TaxArea."Country/Region" <> HeaderTaxArea."Country/Region" then
                        Error(
                          Text1020003,
                          TaxArea.FieldCaption("Country/Region"),
                          TaxArea.TableCaption,
                          TableCaption,
                          SalesHeader.TableCaption);
                    if TaxArea."Use External Tax Engine" <> HeaderTaxArea."Use External Tax Engine" then
                        Error(
                          Text1020003,
                          TaxArea.FieldCaption("Use External Tax Engine"),
                          TaxArea.TableCaption,
                          TableCaption,
                          SalesHeader.TableCaption);
                end;
                UpdateAmounts();
            end;
        }
        field(86; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
            Editable = false;

            trigger OnValidate()
            begin
                UpdateAmounts();
            end;
        }
        field(87; "Tax Group Code"; Code[20])
        {
            Caption = 'Tax Group Code';
            TableRelation = "Tax Group";

            trigger OnValidate()
            begin
                TestStatusOpen();
                ValidateTaxGroupCode;
                UpdateAmounts();
            end;
        }
        field(88; "VAT Clause Code"; Code[20])
        {
            Caption = 'VAT Clause Code';
            TableRelation = "VAT Clause";
        }
        field(89; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";

            trigger OnValidate()
            begin
                ValidateVATProdPostingGroup();
            end;
        }
        field(90; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateVATProdPostingGroupTrigger(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                TestStatusOpen();
                CheckPrepmtAmtInvEmpty();

                VATPostingSetup.Get("VAT Bus. Posting Group", "VAT Prod. Posting Group");
                "VAT Difference" := 0;

                GetSalesHeader();
                "VAT %" := VATPostingSetup."VAT %";
                "VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
                if "VAT Calculation Type" = "VAT Calculation Type"::"Full VAT" then
                    Validate("Allow Invoice Disc.", false);
                "VAT Identifier" := VATPostingSetup."VAT Identifier";
                "VAT Clause Code" := VATPostingSetup."VAT Clause Code";

                IsHandled := false;
                OnValidateVATProdPostingGroupOnBeforeCheckVATCalcType(Rec, VATPostingSetup, IsHandled);
                if not IsHandled then
                    case "VAT Calculation Type" of
                        "VAT Calculation Type"::"Reverse Charge VAT",
                        "VAT Calculation Type"::"Sales Tax":
                            "VAT %" := 0;
                        "VAT Calculation Type"::"Full VAT":
                            begin
                                TestField(Type, Type::"G/L Account");
                                TestField("No.", VATPostingSetup.GetSalesAccount(false));
                            end;
                    end;

                IsHandled := FALSE;
                OnValidateVATProdPostingGroupOnBeforeUpdateUnitPrice(Rec, VATPostingSetup, IsHandled);
                if not IsHandled then
                    if SalesHeader."Prices Including VAT" and (Type in [Type::Item, Type::Resource]) then
                        Validate("Unit Price",
                            Round(
                                "Unit Price" * (100 + "VAT %") / (100 + xRec."VAT %"),
                        Currency."Unit-Amount Rounding Precision"));

                OnValidateVATProdPostingGroupOnBeforeUpdateAmounts(Rec, xRec, SalesHeader, Currency);
                UpdateAmounts();
            end;
        }
        field(91; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
        }
        field(92; "Outstanding Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Outstanding Amount (LCY)';
            Editable = false;
        }
        field(93; "Shipped Not Invoiced (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Shipped Not Invoiced (LCY) Incl. VAT';
            Editable = false;
        }
        field(94; "Shipped Not Inv. (LCY) No VAT"; Decimal)
        {
            Caption = 'Shipped Not Invoiced (LCY)';
            Editable = false;
            FieldClass = Normal;
        }
        field(95; "Reserved Quantity"; Decimal)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            CalcFormula = - Sum("Reservation Entry".Quantity WHERE("Source ID" = FIELD("Document No."),
                                                                   "Source Ref. No." = FIELD("Line No."),
                                                                   "Source Type" = CONST(37),
#pragma warning disable
                                                                   "Source Subtype" = FIELD("Document Type"),
#pragma warning restore
                                                                   "Reservation Status" = CONST(Reservation)));
            Caption = 'Reserved Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(96; Reserve; Enum "Reserve Method")
        {
            AccessByPermission = TableData Item = R;
            Caption = 'Reserve';

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if Reserve <> Reserve::Never then begin
                    TestField(Type, Type::Item);
                    TestField("No.");
                    GetItem(Item);
                    if Item.Type = Item.Type::"Non-Inventory" then
                        Error(NonInvReserveTypeErr, Item."No.", Reserve);
                end;

                CalcFields("Reserved Qty. (Base)");
                if (Reserve = Reserve::Never) and ("Reserved Qty. (Base)" > 0) then
                    TestField("Reserved Qty. (Base)", 0);

                if "Drop Shipment" or "Special Order" then
                    TestField(Reserve, Reserve::Never);
                if xRec.Reserve = Reserve::Always then begin
                    GetItem(Item);
                    if Item.Reserve = Item.Reserve::Always then
                        TestField(Reserve, Reserve::Always);
                end;
            end;
        }
        field(97; "Blanket Order No."; Code[20])
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            Caption = 'Blanket Order No.';
            TableRelation = "Sales Header"."No." WHERE("Document Type" = CONST("Blanket Order"));
            //This property is currently not supported
            //TestTableRelation = false;

            trigger OnLookup()
            begin
                BlanketOrderLookup();
            end;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateBlanketOrderNo(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                TestField("Quantity Shipped", 0);
                if "Blanket Order No." = '' then
                    "Blanket Order Line No." := 0
                else
                    Validate("Blanket Order Line No.");
            end;
        }
        field(98; "Blanket Order Line No."; Integer)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            Caption = 'Blanket Order Line No.';
            TableRelation = "Sales Line"."Line No." WHERE("Document Type" = CONST("Blanket Order"),
                                                           "Document No." = FIELD("Blanket Order No."));
            //This property is currently not supported
            //TestTableRelation = false;

            trigger OnLookup()
            begin
                BlanketOrderLookup();
            end;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateBlanketOrderLineNo(IsHandled, Rec);
                if IsHandled then
                    exit;

                TestField("Quantity Shipped", 0);
                if "Blanket Order Line No." <> 0 then begin
                    SalesLine2.Get("Document Type"::"Blanket Order", "Blanket Order No.", "Blanket Order Line No.");
                    SalesLine2.TestField(Type, Type);
                    SalesLine2.TestField("No.", "No.");
                    SalesLine2.TestField("Bill-to Customer No.", "Bill-to Customer No.");
                    SalesLine2.TestField("Sell-to Customer No.", "Sell-to Customer No.");
                    if "Drop Shipment" or "Special Order" then begin
                        SalesLine2.TestField("Variant Code", "Variant Code");
                        SalesLine2.TestField("Location Code", "Location Code");
                        SalesLine2.TestField("Unit of Measure Code", "Unit of Measure Code");
                    end else begin
                        Validate("Variant Code", SalesLine2."Variant Code");
                        Validate("Location Code", SalesLine2."Location Code");
                        Validate("Unit of Measure Code", SalesLine2."Unit of Measure Code");
                    end;
                    Validate("Unit Price", SalesLine2."Unit Price");
                    Validate("Line Discount %", SalesLine2."Line Discount %");
                end;
            end;
        }
        field(99; "VAT Base Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'VAT Base Amount';
            Editable = false;
        }
        field(100; "Unit Cost"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Cost';
            Editable = false;
        }
        field(101; "System-Created Entry"; Boolean)
        {
            Caption = 'System-Created Entry';
            Editable = false;
        }
        field(103; "Line Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CaptionClass = GetCaptionClass(FieldNo("Line Amount"));
            Caption = 'Line Amount';
            Description = 'PR3.60';

            trigger OnValidate()
            var
                MaxLineAmount: Decimal;
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateLineAmount(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                TestField(Type);
                TestField(Quantity);
                IsHandled := false;
                OnValidateLineAmountOnbeforeTestUnitPrice(Rec, IsHandled);
                if not IsHandled then
                    TestField("Unit Price");

                GetSalesHeader();

                "Line Amount" := Round("Line Amount", Currency."Amount Rounding Precision");
                MaxLineAmount := Round(GetPricingQty * "Unit Price", Currency."Amount Rounding Precision"); // P80066030

                if "Line Amount" < 0 then
                    if "Line Amount" < MaxLineAmount then
                        Error(LineAmountInvalidErr);

                if "Line Amount" > 0 then
                    if "Line Amount" > MaxLineAmount then
                        Error(LineAmountInvalidErr);

                Validate("Line Discount Amount", MaxLineAmount - "Line Amount");
            end;
        }
        field(104; "VAT Difference"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'VAT Difference';
            Editable = false;
        }
        field(105; "Inv. Disc. Amount to Invoice"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Inv. Disc. Amount to Invoice';
            Editable = false;
        }
        field(106; "VAT Identifier"; Code[20])
        {
            Caption = 'VAT Identifier';
            Editable = false;
        }
        field(107; "IC Partner Ref. Type"; Enum "IC Partner Reference Type")
        {
            AccessByPermission = TableData "IC G/L Account" = R;
            Caption = 'IC Partner Ref. Type';

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if "IC Partner Code" <> '' then
                    "IC Partner Ref. Type" := "IC Partner Ref. Type"::"G/L Account";
                if "IC Partner Ref. Type" <> xRec."IC Partner Ref. Type" then
                    "IC Partner Reference" := '';
                if "IC Partner Ref. Type" = "IC Partner Ref. Type"::"Common Item No." then begin
                    GetItem(Item);
                    Item.TestField("Common Item No.");
                    "IC Partner Reference" := Item."Common Item No.";
                end;
            end;
        }
        field(108; "IC Partner Reference"; Code[20])
        {
            AccessByPermission = TableData "IC G/L Account" = R;
            Caption = 'IC Partner Reference';

            trigger OnLookup()
            var
                ICGLAccount: Record "IC G/L Account";
                Item: Record Item;
            begin
                if "No." <> '' then
                    case "IC Partner Ref. Type" of
                        "IC Partner Ref. Type"::"G/L Account":
                            begin
                                if ICGLAccount.Get("IC Partner Reference") then;
                                if PAGE.RunModal(PAGE::"IC G/L Account List", ICGLAccount) = ACTION::LookupOK then
                                    Validate("IC Partner Reference", ICGLAccount."No.");
                            end;
                        "IC Partner Ref. Type"::Item:
                            begin
                                if Item.Get("IC Partner Reference") then;
                                if PAGE.RunModal(PAGE::"Item List", Item) = ACTION::LookupOK then
                                    Validate("IC Partner Reference", Item."No.");
                            end;
                        else
                            OnLookUpICPartnerReferenceTypeCaseElse();
                    end;
            end;
        }
        field(109; "Prepayment %"; Decimal)
        {
            Caption = 'Prepayment %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                TestStatusOpen();

                IsHandled := false;
                OnValidatePrepaymentPercentageOnBeforeUpdatePrepmtSetupFields(Rec, IsHandled);
                if IsHandled then
                    exit;

                UpdatePrepmtSetupFields();

                if HasTypeToFillMandatoryFields() then
                    UpdateAmounts();

                UpdateBaseAmounts(Amount, "Amount Including VAT", "VAT Base Amount");
            end;
        }
        field(110; "Prepmt. Line Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CaptionClass = GetCaptionClass(FieldNo("Prepmt. Line Amount"));
            Caption = 'Prepmt. Line Amount';
            MinValue = 0;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidatePrepmtLineAmount(Rec, PrePaymentLineAmountEntered, IsHandled);
                if IsHandled then
                    exit;

                TestStatusOpen();
                PrePaymentLineAmountEntered := true;
                TestField("Line Amount");
                if "Prepmt. Line Amount" < "Prepmt. Amt. Inv." then
                    FieldError("Prepmt. Line Amount", StrSubstNo(Text044, "Prepmt. Amt. Inv."));
                if "Prepmt. Line Amount" > LineAmtExclAltQtys() then                                        // P8000466A
                    FieldError("Prepmt. Line Amount", StrSubstNo(Text045, LineAmtExclAltQtys()));               // P8000466A
                if "System-Created Entry" and not IsServiceChargeLine() then
                    FieldError("Prepmt. Line Amount", StrSubstNo(Text045, 0));
                Validate("Prepayment %", "Prepmt. Line Amount" * 100 / LineAmtExclAltQtys());
            end;
        }
        field(111; "Prepmt. Amt. Inv."; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CaptionClass = GetCaptionClass(FieldNo("Prepmt. Amt. Inv."));
            Caption = 'Prepmt. Amt. Inv.';
            Editable = false;
        }
        field(112; "Prepmt. Amt. Incl. VAT"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Prepmt. Amt. Incl. VAT';
            Editable = false;
        }
        field(113; "Prepayment Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Prepayment Amount';
            Editable = false;
        }
        field(114; "Prepmt. VAT Base Amt."; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Prepmt. VAT Base Amt.';
            Editable = false;
        }
        field(115; "Prepayment VAT %"; Decimal)
        {
            Caption = 'Prepayment VAT %';
            DecimalPlaces = 0 : 5;
            Editable = false;
            MinValue = 0;
        }
        field(116; "Prepmt. VAT Calc. Type"; Enum "Tax Calculation Type")
        {
            Caption = 'Prepmt. VAT Calc. Type';
            Editable = false;
        }
        field(117; "Prepayment VAT Identifier"; Code[20])
        {
            Caption = 'Prepayment VAT Identifier';
            Editable = false;
        }
        field(118; "Prepayment Tax Area Code"; Code[20])
        {
            Caption = 'Prepayment Tax Area Code';
            TableRelation = "Tax Area";

            trigger OnValidate()
            begin
                UpdateAmounts();
            end;
        }
        field(119; "Prepayment Tax Liable"; Boolean)
        {
            Caption = 'Prepayment Tax Liable';

            trigger OnValidate()
            begin
                UpdateAmounts();
            end;
        }
        field(120; "Prepayment Tax Group Code"; Code[20])
        {
            Caption = 'Prepayment Tax Group Code';
            TableRelation = "Tax Group";

            trigger OnValidate()
            begin
                TestStatusOpen();
                UpdateAmounts();
            end;
        }
        field(121; "Prepmt Amt to Deduct"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CaptionClass = GetCaptionClass(FieldNo("Prepmt Amt to Deduct"));
            Caption = 'Prepmt Amt to Deduct';
            MinValue = 0;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidatePrepmtAmttoDeduct(Rec, xRec, IsHandled);
                if IsHandled then
                    exit;

                if "Prepmt Amt to Deduct" > "Prepmt. Amt. Inv." - "Prepmt Amt Deducted" then
                    FieldError(
                      "Prepmt Amt to Deduct",
                      StrSubstNo(Text045, "Prepmt. Amt. Inv." - "Prepmt Amt Deducted"));

                if "Prepmt Amt to Deduct" > "Qty. to Invoice" * "Unit Price" then
                    FieldError(
                      "Prepmt Amt to Deduct",
                      StrSubstNo(Text045, "Qty. to Invoice" * "Unit Price"));

                if ("Prepmt. Amt. Inv." - "Prepmt Amt to Deduct" - "Prepmt Amt Deducted") >
                   (Quantity - "Qty. to Invoice" - "Quantity Invoiced") * "Unit Price"
                then
                    FieldError(
                      "Prepmt Amt to Deduct",
                      StrSubstNo(Text044,
                        "Prepmt. Amt. Inv." - "Prepmt Amt Deducted" - (Quantity - "Qty. to Invoice" - "Quantity Invoiced") * "Unit Price"));
            end;
        }
        field(122; "Prepmt Amt Deducted"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CaptionClass = GetCaptionClass(FieldNo("Prepmt Amt Deducted"));
            Caption = 'Prepmt Amt Deducted';
            Editable = false;
        }
        field(123; "Prepayment Line"; Boolean)
        {
            Caption = 'Prepayment Line';
            Editable = false;
        }
        field(124; "Prepmt. Amount Inv. Incl. VAT"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Prepmt. Amount Inv. Incl. VAT';
            Editable = false;
        }
        field(129; "Prepmt. Amount Inv. (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Prepmt. Amount Inv. (LCY)';
            Editable = false;
        }
        field(130; "IC Partner Code"; Code[20])
        {
            Caption = 'IC Partner Code';
            TableRelation = "IC Partner";

            trigger OnValidate()
            begin
                if "IC Partner Code" <> '' then begin
                    TestField(Type, Type::"G/L Account");
                    GetSalesHeader();
                    SalesHeader.TestField("Sell-to IC Partner Code", '');
                    SalesHeader.TestField("Bill-to IC Partner Code", '');
                    Validate("IC Partner Ref. Type", "IC Partner Ref. Type"::"G/L Account");
                end;
            end;
        }
        field(132; "Prepmt. VAT Amount Inv. (LCY)"; Decimal)
        {
            Caption = 'Prepmt. VAT Amount Inv. (LCY)';
            Editable = false;
        }
        field(135; "Prepayment VAT Difference"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Prepayment VAT Difference';
            Editable = false;
        }
        field(136; "Prepmt VAT Diff. to Deduct"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Prepmt VAT Diff. to Deduct';
            Editable = false;
        }
        field(137; "Prepmt VAT Diff. Deducted"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Prepmt VAT Diff. Deducted';
            Editable = false;
        }
        field(138; "IC Item Reference No."; Code[50])
        {
            AccessByPermission = TableData "Item Reference" = R;
            Caption = 'IC Item Reference No.';

            trigger OnLookup()
            var
                ItemReference: Record "Item Reference";
            begin
                if "No." <> '' then
                    case "IC Partner Ref. Type" of
                        "IC Partner Ref. Type"::"Cross Reference":
                            begin
                                ItemReference.Reset();
                                ItemReference.SetCurrentKey("Reference Type", "Reference Type No.");
                                ItemReference.SetFilter("Reference Type", '%1|%2', "Item Reference Type"::Customer, "Item Reference Type"::" ");
                                ItemReference.SetFilter("Reference Type No.", '%1|%2', "Sell-to Customer No.", '');
                                if PAGE.RunModal(PAGE::"Item Reference List", ItemReference) = ACTION::LookupOK then
                                    Validate("IC Item Reference No.", ItemReference."Reference No.");
                            end;
                    end;
            end;
        }
        field(145; "Pmt. Discount Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Pmt. Discount Amount';

            trigger OnValidate()
            begin
                TestField(Quantity);
                UpdateAmounts();
            end;
        }
        field(146; "Prepmt. Pmt. Discount Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Prepmt. Pmt. Discount Amount';
            Editable = false;
        }
        field(180; "Line Discount Calculation"; Option)
        {
            Caption = 'Line Discount Calculation';
            OptionCaption = 'None,%,Amount';
            OptionMembers = "None","%",Amount;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions();
            end;

            trigger OnValidate()
            begin
                DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            end;
        }
        field(900; "Qty. to Assemble to Order"; Decimal)
        {
            AccessByPermission = TableData "BOM Component" = R;
            Caption = 'Qty. to Assemble to Order';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            var
                SalesLineReserve: Codeunit "Sales Line-Reserve";
                IsHandled: Boolean;
            begin
                if not "Allow Quantity Change" then begin// P8001382
                    "Qty. to Assemble to Order" := UOMMgt.RoundAndValidateQty("Qty. to Assemble to Order", "Qty. Rounding Precision", FieldCaption("Qty. to Assemble to Order"));
                    IsHandled := false;
                    OnValidateQuantityOnBeforeSalesLineVerifyChange(Rec, StatusCheckSuspended, IsHandled);
                    if not IsHandled then
                        WhseValidateSourceLine.SalesLineVerifyChange(Rec, xRec);
                end;

                "Qty. to Asm. to Order (Base)" := CalcBaseQty("Qty. to Assemble to Order", FieldCaption("Qty. to Assemble to Order"), FieldCaption("Qty. to Asm. to Order (Base)"));
                if "Qty. to Asm. to Order (Base)" <> 0 then begin
                    TestField("Drop Shipment", false);
                    TestField("Special Order", false);
                    if "Qty. to Asm. to Order (Base)" < 0 then
                        FieldError("Qty. to Assemble to Order", StrSubstNo(Text009, FieldCaption("Quantity (Base)"), "Quantity (Base)"));
                    TestField("Appl.-to Item Entry", 0);

                    case "Document Type" of
                        "Document Type"::"Blanket Order",
                      "Document Type"::Quote:
                            if ("Quantity (Base)" = 0) or ("Qty. to Asm. to Order (Base)" <= 0) or SalesLineReserve.ReservEntryExist(Rec) then
                                TestField("Qty. to Asm. to Order (Base)", 0)
                            else
                                if "Quantity (Base)" <> "Qty. to Asm. to Order (Base)" then
                                    FieldError("Qty. to Assemble to Order", StrSubstNo(Text031, 0, "Quantity (Base)"));
                        "Document Type"::Order:
                            ;
                        else
                            TestField("Qty. to Asm. to Order (Base)", 0);
                    end;
                end;

                CheckItemAvailable(FieldNo("Qty. to Assemble to Order"));
                if not (CurrFieldNo in [FieldNo(Quantity), FieldNo("Qty. to Assemble to Order")]) then
                    GetDefaultBin();
                AutoAsmToOrder();
            end;
        }
        field(901; "Qty. to Asm. to Order (Base)"; Decimal)
        {
            Caption = 'Qty. to Asm. to Order (Base)';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateQtytoAsmtoOrderBase(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                TestField("Qty. per Unit of Measure", 1);
                Validate("Qty. to Assemble to Order", "Qty. to Asm. to Order (Base)");
            end;
        }
        field(902; "ATO Whse. Outstanding Qty."; Decimal)
        {
            AccessByPermission = TableData "BOM Component" = R;
            BlankZero = true;
            CalcFormula = Sum("Warehouse Shipment Line"."Qty. Outstanding" WHERE("Source Type" = CONST(37),
#pragma warning disable
                                                                                  "Source Subtype" = FIELD("Document Type"),
#pragma warning restore
                                                                                  "Source No." = FIELD("Document No."),
                                                                                  "Source Line No." = FIELD("Line No."),
                                                                                  "Assemble to Order" = FILTER(true)));
            Caption = 'ATO Whse. Outstanding Qty.';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(903; "ATO Whse. Outstd. Qty. (Base)"; Decimal)
        {
            AccessByPermission = TableData "BOM Component" = R;
            BlankZero = true;
            CalcFormula = Sum("Warehouse Shipment Line"."Qty. Outstanding (Base)" WHERE("Source Type" = CONST(37),
#pragma warning disable
                                                                                         "Source Subtype" = FIELD("Document Type"),
#pragma warning restore
                                                                                         "Source No." = FIELD("Document No."),
                                                                                         "Source Line No." = FIELD("Line No."),
                                                                                         "Assemble to Order" = FILTER(true)));
            Caption = 'ATO Whse. Outstd. Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(1001; "Job Task No."; Code[20])
        {
            Caption = 'Job Task No.';
            Editable = false;
            TableRelation = "Job Task"."Job Task No." WHERE("Job No." = FIELD("Job No."));
        }
        field(1002; "Job Contract Entry No."; Integer)
        {
            AccessByPermission = TableData Job = R;
            Caption = 'Job Contract Entry No.';
            Editable = false;

            trigger OnValidate()
            var
                JobPlanningLine: Record "Job Planning Line";
                IsHandled: Boolean;
                DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
            begin
                IsHandled := false;
                OnBeforeValidateJobContractEntryNo(xRec, IsHandled);
                if IsHandled then
                    exit;

                JobPlanningLine.SetCurrentKey("Job Contract Entry No.");
                JobPlanningLine.SetRange("Job Contract Entry No.", "Job Contract Entry No.");
                JobPlanningLine.FindFirst();
                InitDefaultDimensionSources(DefaultDimSource, JobPlanningLine."Job No.", Rec.FieldNo("Job Contract Entry No."));
                CreateDim(DefaultDimSource);
            end;
        }
        field(1300; "Posting Date"; Date)
        {
            CalcFormula = Lookup("Sales Header"."Posting Date" WHERE("Document Type" = FIELD("Document Type"),
                                                                      "No." = FIELD("Document No.")));
            Caption = 'Posting Date';
            FieldClass = FlowField;
        }
        field(1700; "Deferral Code"; Code[10])
        {
            Caption = 'Deferral Code';
            TableRelation = "Deferral Template"."Deferral Code";

            trigger OnValidate()
            var
                DeferralPostDate: Date;
            begin
                GetSalesHeader();
                OnGetDeferralPostDate(SalesHeader, DeferralPostDate, Rec);
                if DeferralPostDate = 0D then
                    DeferralPostDate := SalesHeader."Posting Date";

                DeferralUtilities.DeferralCodeOnValidate(
                    "Deferral Code", "Deferral Document Type"::Sales.AsInteger(), '', '',
                    "Document Type".AsInteger(), "Document No.", "Line No.",
                    GetDeferralAmount(), DeferralPostDate,
                    Description, SalesHeader."Currency Code");

                if "Document Type" = "Document Type"::"Return Order" then
                    "Returns Deferral Start Date" :=
                        DeferralUtilities.GetDeferralStartDate(
                            "Deferral Document Type"::Sales.AsInteger(), "Document Type".AsInteger(),
                            "Document No.", "Line No.", "Deferral Code", SalesHeader."Posting Date");
            end;
        }
        field(1702; "Returns Deferral Start Date"; Date)
        {
            Caption = 'Returns Deferral Start Date';

            trigger OnValidate()
            var
                DeferralHeader: Record "Deferral Header";
            begin
                GetSalesHeader();
                if DeferralHeader.Get("Deferral Document Type"::Sales, '', '', "Document Type", "Document No.", "Line No.") then
                    DeferralUtilities.CreateDeferralSchedule(
                        "Deferral Code", "Deferral Document Type"::Sales.AsInteger(), '', '',
                        "Document Type".AsInteger(), "Document No.", "Line No.", GetDeferralAmount(),
                        DeferralHeader."Calc. Method", "Returns Deferral Start Date",
                        DeferralHeader."No. of Periods", true,
                        DeferralHeader."Schedule Description", false,
                        SalesHeader."Currency Code");
            end;
        }
        field(5402; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = IF (Type = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD("No."));

            trigger OnValidate()
            begin
                TestJobPlanningLine();
                if "Variant Code" <> '' then
                    TestField(Type, Type::Item);
                TestContainerQuantityIsZero; // P80046533
                TestStatusOpen();
                CheckAssocPurchOrder(FieldCaption("Variant Code"));

                if xRec."Variant Code" <> "Variant Code" then begin
                    TestField("Qty. Shipped Not Invoiced", 0);
                    TestField("Shipment No.", '');

                    TestField("Return Qty. Rcd. Not Invd.", 0);
                    TestField("Return Receipt No.", '');
                    InitItemAppl(false);
                end;

                OnValidateVariantCodeOnAfterChecks(Rec, xRec, CurrFieldNo);

                CheckItemAvailable(FieldNo("Variant Code"));

                if Type in [Type::Item, Type::FOODContainer] then begin // PR3.61
                    GetUnitCost();
                    if "Variant Code" <> xRec."Variant Code" then
                        PlanPriceCalcByField(FieldNo("Variant Code"));
                end;

                GetDefaultBin();
                InitQtyToAsm();
                AutoAsmToOrder();
                if (xRec."Variant Code" <> "Variant Code") and (Quantity <> 0) then begin
                    if not FullReservedQtyIsForAsmToOrder then
                        VerifyChangeForSalesLineReserve(FieldNo("Variant Code"));
                    WhseValidateSourceLine.SalesLineVerifyChange(Rec, xRec);
                end;

                UpdateItemReference();
                // PR2.00.05 Begin
                if "Variant Code" <> '' then begin       // P8000413A
                    ItemVariant.Get("No.", "Variant Code"); // P8000413A
                    if ItemVariant."Unit of Measure Code" <> '' then
                        Validate("Unit of Measure Code", ItemVariant."Unit of Measure Code");
                end;                                     // P8000413A
                                                         // PR2.00.05 End

                UpdateUnitPriceByField(FieldNo("Variant Code"));
            end;
        }
        field(5403; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = IF ("Document Type" = FILTER(Order | Invoice),
                                Quantity = FILTER(>= 0),
                                "Qty. to Asm. to Order (Base)" = CONST(0)) "Bin Content"."Bin Code" WHERE("Location Code" = FIELD("Location Code"),
                                                                                                         "Item No." = FIELD("No."),
                                                                                                         "Variant Code" = FIELD("Variant Code"))
            ELSE
            IF ("Document Type" = FILTER("Return Order" | "Credit Memo"),
                                                                                                                  Quantity = FILTER(< 0)) "Bin Content"."Bin Code" WHERE("Location Code" = FIELD("Location Code"),
                                                                                                                                                                       "Item No." = FIELD("No."),
                                                                                                                                                                       "Variant Code" = FIELD("Variant Code"))
            ELSE
            Bin.Code WHERE("Location Code" = FIELD("Location Code"));

            trigger OnLookup()
            var
                WMSManagement: Codeunit "WMS Management";
                BinCode: Code[20];
            begin
                if not IsInbound and ("Quantity (Base)" <> 0) then
                    BinCode := WMSManagement.BinContentLookUp("Location Code", "No.", "Variant Code", '', "Bin Code")
                else
                    BinCode := WMSManagement.BinLookUp("Location Code", "No.", "Variant Code", '');

                if BinCode <> '' then
                    Validate("Bin Code", BinCode);
            end;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if "Bin Code" <> '' then
                    GetItem(Item);                              // P8001290, P80066030
                Item.TestField("Non-Warehouse Item", false); // P8001290
                CheckBinCodeRelation();

                TestContainerQuantityIsZero; // P80046533

                if "Drop Shipment" then
                    CheckAssocPurchOrder(FieldCaption("Bin Code"));

                TestField(Type, Type::Item);
                TestField("Location Code");

                GetItem(Item);
                Item.TestField(Type, Item.Type::Inventory);

                if (Type = Type::Item) and ("Bin Code" <> '') then begin
                    TestField("Drop Shipment", false);
                    GetLocation("Location Code");
                    Location.TestField("Bin Mandatory");
                    CheckWarehouse();
                end;
                ATOLink.UpdateAsmBinCodeFromSalesLine(Rec);

                if Type = Type::FOODContainer then             // P8000631A
                    ContainerFns.EditSalesLineLocation(Rec); // P8000631A
            end;
        }
        field(5404; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
        }
        field(5405; Planned; Boolean)
        {
            Caption = 'Planned';
            Editable = false;
        }
        field(5406; "Qty. Rounding Precision"; Decimal)
        {
            Caption = 'Qty. Rounding Precision';
            InitValue = 0;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 1;
            Editable = false;
        }
        field(5408; "Qty. Rounding Precision (Base)"; Decimal)
        {
            Caption = 'Qty. Rounding Precision (Base)';
            InitValue = 0;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 1;
            Editable = false;
        }
        field(5407; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = IF (Type = CONST(Item),
                                "No." = FILTER(<> '')) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."))
            ELSE
            IF (Type = CONST(Resource),
                                         "No." = FILTER(<> '')) "Resource Unit of Measure".Code WHERE("Resource No." = FIELD("No."))
            ELSE
            "Unit of Measure";

            trigger OnValidate()
            var
                Item: Record Item;
                UnitOfMeasureTranslation: Record "Unit of Measure Translation";
            begin
                P800CoreFns.CheckSalesLineFieldEditable(Rec, FieldNo("Unit of Measure Code"), CurrFieldNo); // PR3.61
                TestJobPlanningLine();
                TestStatusOpen();
                TestField("Quantity Shipped", 0);
                TestField("Qty. Shipped (Base)", 0);
                CalcFields("Qty. on Prod. Order (Base)"); // PR1.00
                TestField("Qty. on Prod. Order (Base)", 0); // PR1.00
                TestContainerQuantityIsZero; // P80046533
                TestField("Return Qty. Received", 0);
                TestField("Return Qty. Received (Base)", 0);
                if "Unit of Measure Code" <> xRec."Unit of Measure Code" then begin
                    TestField("Shipment No.", '');
                    TestField("Return Receipt No.", '');
                end;

                CheckAssocPurchOrder(FieldCaption("Unit of Measure Code"));

                if "Unit of Measure Code" = '' then
                    "Unit of Measure" := ''
                else begin
                    if not UnitOfMeasure.Get("Unit of Measure Code") then
                        UnitOfMeasure.Init();
                    "Unit of Measure" := UnitOfMeasure.Description;
                    GetSalesHeader();
                    if SalesHeader."Language Code" <> '' then begin
                        UnitOfMeasureTranslation.SetRange(Code, "Unit of Measure Code");
                        UnitOfMeasureTranslation.SetRange("Language Code", SalesHeader."Language Code");
                        if UnitOfMeasureTranslation.FindFirst() then
                            "Unit of Measure" := UnitOfMeasureTranslation.Description;
                    end;
                end;

                ItemReferenceMgt.EnterSalesItemReference(Rec);

                case Type of
                    Type::Item, Type::FOODContainer: // PR3.70
                        begin
                            GetItem(Item);
                            // P8000383A
                            if Item.TrackAlternateUnits then
                                AltQtyMgmt.CheckUOMDifferentFromAltUOM(Item, "Unit of Measure Code", FieldCaption("Unit of Measure"));
                            // P8000383A
                            GetUnitCost();
                            if "Unit of Measure Code" <> xRec."Unit of Measure Code" then
                                PlanPriceCalcByField(FieldNo("Unit of Measure Code"));
                            CheckItemAvailable(FieldNo("Unit of Measure Code"));
                            "Gross Weight" := Item."Gross Weight" * "Qty. per Unit of Measure";
                            "Net Weight" := Item."Net Weight" * "Qty. per Unit of Measure";
                            "Unit Volume" := Item."Unit Volume" * "Qty. per Unit of Measure";
                            "Units per Parcel" :=
                              Round(Item."Units per Parcel" / "Qty. per Unit of Measure", UOMMgt.QtyRndPrecision);
                            "Qty. Rounding Precision" := UOMMgt.GetQtyRoundingPrecision(Item, "Unit of Measure Code");
                            "Qty. Rounding Precision (Base)" := UOMMgt.GetQtyRoundingPrecision(Item, Item."Base Unit of Measure");

                            OnAfterAssignItemUOM(Rec, Item, CurrFieldNo);
                            if (xRec."Unit of Measure Code" <> "Unit of Measure Code") and (Quantity <> 0) then
                                WhseValidateSourceLine.SalesLineVerifyChange(Rec, xRec);
                            if "Qty. per Unit of Measure" > xRec."Qty. per Unit of Measure" then
                                InitItemAppl(false);
                        end;
                    Type::Resource:
                        begin
                            if "Unit of Measure Code" = '' then begin
                                GetResource();
                                "Unit of Measure Code" := Resource."Base Unit of Measure";
                            end;
                            AssignResourceUoM();
                            if "Unit of Measure Code" <> xRec."Unit of Measure Code" then
                                PlanPriceCalcByField(FieldNo("Unit of Measure Code"));
                            ApplyResUnitCost(FieldNo("Unit of Measure Code"));
                        end;
                    Type::"G/L Account", Type::"Fixed Asset",
                    Type::"Charge (Item)", Type::" ":
                        "Qty. per Unit of Measure" := 1;
                end;
                UpdateQuantityFromUOMCode();
                UpdateUnitPriceByField(FieldNo("Unit of Measure Code"));
            end;
        }
        field(5415; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.61';

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                P800CoreFns.CheckSalesLineFieldEditable(Rec, FieldNo("Quantity (Base)"), CurrFieldNo); // PR3.61

                IsHandled := false;
                OnBeforeValidateQuantityBase(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                TestJobPlanningLine();
                TestField("Qty. per Unit of Measure", 1);
                if "Quantity (Base)" <> xRec."Quantity (Base)" then
                    PlanPriceCalcByField(FieldNo("Quantity (Base)"));
                Validate(Quantity, "Quantity (Base)");
                UpdateUnitPriceByField(FieldNo("Quantity (Base)"));
            end;
        }
        field(5416; "Outstanding Qty. (Base)"; Decimal)
        {
            Caption = 'Outstanding Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(5417; "Qty. to Invoice (Base)"; Decimal)
        {
            Caption = 'Qty. to Invoice (Base)';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateQtytoInvoiceBase(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                TestField("Qty. per Unit of Measure", 1);
                Validate("Qty. to Invoice", "Qty. to Invoice (Base)");
            end;
        }
        field(5418; "Qty. to Ship (Base)"; Decimal)
        {
            Caption = 'Qty. to Ship (Base)';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.61';

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateQtytoShipBase(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                P800CoreFns.CheckSalesLineFieldEditable(Rec, FieldNo("Qty. to Ship (Base)"), CurrFieldNo); // PR3.6
                TestField("Qty. per Unit of Measure", 1);
                Validate("Qty. to Ship", "Qty. to Ship (Base)");
            end;
        }
        field(5458; "Qty. Shipped Not Invd. (Base)"; Decimal)
        {
            Caption = 'Qty. Shipped Not Invd. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(5460; "Qty. Shipped (Base)"; Decimal)
        {
            Caption = 'Qty. Shipped (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(5461; "Qty. Invoiced (Base)"; Decimal)
        {
            Caption = 'Qty. Invoiced (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(5495; "Reserved Qty. (Base)"; Decimal)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            CalcFormula = - Sum("Reservation Entry"."Quantity (Base)" WHERE("Source ID" = FIELD("Document No."),
                                                                            "Source Ref. No." = FIELD("Line No."),
                                                                            "Source Type" = CONST(37),
#pragma warning disable
                                                                            "Source Subtype" = FIELD("Document Type"),
#pragma warning restore
                                                                            "Reservation Status" = CONST(Reservation)));
            Caption = 'Reserved Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5600; "FA Posting Date"; Date)
        {
            AccessByPermission = TableData "Fixed Asset" = R;
            Caption = 'FA Posting Date';
        }
        field(5602; "Depreciation Book Code"; Code[10])
        {
            Caption = 'Depreciation Book Code';
            TableRelation = "Depreciation Book";

            trigger OnValidate()
            begin
                GetFAPostingGroup();
            end;
        }
        field(5605; "Depr. until FA Posting Date"; Boolean)
        {
            AccessByPermission = TableData "Fixed Asset" = R;
            Caption = 'Depr. until FA Posting Date';
        }
        field(5612; "Duplicate in Depreciation Book"; Code[10])
        {
            Caption = 'Duplicate in Depreciation Book';
            TableRelation = "Depreciation Book";

            trigger OnValidate()
            begin
                "Use Duplication List" := false;
            end;
        }
        field(5613; "Use Duplication List"; Boolean)
        {
            AccessByPermission = TableData "Fixed Asset" = R;
            Caption = 'Use Duplication List';

            trigger OnValidate()
            begin
                "Duplicate in Depreciation Book" := '';
            end;
        }
        field(5700; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            Editable = false;
            TableRelation = "Responsibility Center";

            trigger OnValidate()
            begin
                CreateDimFromDefaultDim(Rec.FieldNo("Responsibility Center"));
            end;
        }
        field(5701; "Out-of-Stock Substitution"; Boolean)
        {
            Caption = 'Out-of-Stock Substitution';
            Editable = false;
        }
        field(5702; "Substitution Available"; Boolean)
        {
            CalcFormula = Exist("Item Substitution" WHERE(Type = CONST(Item),
                                                           "No." = FIELD("No."),
                                                           "Substitute Type" = CONST(Item)));
            Caption = 'Substitution Available';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5703; "Originally Ordered No."; Code[20])
        {
            AccessByPermission = TableData "Item Substitution" = R;
            Caption = 'Originally Ordered No.';
            TableRelation = IF (Type = CONST(Item)) Item;
        }
        field(5704; "Originally Ordered Var. Code"; Code[10])
        {
            AccessByPermission = TableData "Item Substitution" = R;
            Caption = 'Originally Ordered Var. Code';
            TableRelation = IF (Type = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD("Originally Ordered No."));
        }
        field(5705; "Cross-Reference No."; Code[20])
        {
            Caption = 'Cross-Reference No.';
            ObsoleteReason = 'Cross-Reference replaced by Item Reference feature.';
#if not CLEAN19
            ObsoleteState = Pending;
            ObsoleteTag = '17.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '20.0';
#endif
        }
        field(5706; "Unit of Measure (Cross Ref.)"; Code[10])
        {
            Caption = 'Unit of Measure (Cross Ref.)';
            TableRelation = IF (Type = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));
            ObsoleteReason = 'Cross-Reference replaced by Item Reference feature.';
#if not CLEAN19
            ObsoleteState = Pending;
            ObsoleteTag = '17.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '20.0';
#endif
        }
        field(5707; "Cross-Reference Type"; Option)
        {
            Caption = 'Cross-Reference Type';
            OptionCaption = ' ,Customer,Vendor,Bar Code';
            OptionMembers = " ",Customer,Vendor,"Bar Code";
            ObsoleteReason = 'Cross-Reference replaced by Item Reference feature.';
#if not CLEAN19
            ObsoleteState = Pending;
            ObsoleteTag = '17.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '20.0';
#endif
        }
        field(5708; "Cross-Reference Type No."; Code[30])
        {
            Caption = 'Cross-Reference Type No.';
            ObsoleteReason = 'Cross-Reference replaced by Item Reference feature.';
#if not CLEAN19
            ObsoleteState = Pending;
            ObsoleteTag = '17.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '20.0';
#endif
        }
        field(5709; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            TableRelation = "Item Category";
        }
        field(5710; Nonstock; Boolean)
        {
            AccessByPermission = TableData "Nonstock Item" = R;
            Caption = 'Catalog';
            Editable = false;
        }
        field(5711; "Purchasing Code"; Code[10])
        {
            AccessByPermission = TableData "Drop Shpt. Post. Buffer" = R;
            Caption = 'Purchasing Code';
            TableRelation = Purchasing;

            trigger OnValidate()
            var
                PurchasingCode: Record Purchasing;
                ShippingAgentServices: Record "Shipping Agent Services";
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidatePurchasingCode(Rec, IsHandled);
                if IsHandled then
                    exit;

                TestStatusOpen();
                TestField(Type, Type::Item);
                CheckAssocPurchOrder(FieldCaption("Purchasing Code"));

                if PurchasingCode.Get("Purchasing Code") then begin
                    "Drop Shipment" := PurchasingCode."Drop Shipment";
                    "Special Order" := PurchasingCode."Special Order";
                    IsHandled := false;
                    OnValidatePurchasingCodeOnAfterAssignPurchasingFields(Rec, PurchasingCode, IsHandled);
                    if not IsHandled then
                        if "Drop Shipment" or "Special Order" then begin
                            TestField("Qty. to Asm. to Order (Base)", 0);
                            CalcFields("Reserved Qty. (Base)");
                            TestField("Reserved Qty. (Base)", 0);
                            VerifyChangeForSalesLineReserve(FieldNo("Purchasing Code"));

                            if (Quantity <> 0) and (Quantity = "Quantity Shipped") then
                                Error(SalesLineCompletelyShippedErr);
                            Reserve := Reserve::Never;
                            if "Drop Shipment" then begin
                                Evaluate("Outbound Whse. Handling Time", '<0D>');
                                Evaluate("Shipping Time", '<0D>');
                                UpdateDates();
                                "Bin Code" := '';
                            end;
                        end else
                            SetReserveWithoutPurchasingCode;
                end else begin
                    "Drop Shipment" := false;
                    "Special Order" := false;
                    OnValidatePurchasingCodeOnAfterResetPurchasingFields(Rec, xRec);
                    SetReserveWithoutPurchasingCode;
                end;

                OnValidatePurchasingCodeOnAfterSetReserveWithoutPurchasingCode(Rec);

                if ("Purchasing Code" <> xRec."Purchasing Code") and
                   (not "Drop Shipment") and
                   ("Drop Shipment" <> xRec."Drop Shipment")
                then begin
                    if "Location Code" = '' then begin
                        if InvtSetup.Get then
                            "Outbound Whse. Handling Time" := InvtSetup."Outbound Whse. Handling Time";
                    end else
                        if Location.Get("Location Code") then
                            "Outbound Whse. Handling Time" := Location."Outbound Whse. Handling Time";
                    if ShippingAgentServices.Get("Shipping Agent Code", "Shipping Agent Service Code") then
                        "Shipping Time" := ShippingAgentServices."Shipping Time"
                    else begin
                        GetSalesHeader();
                        "Shipping Time" := SalesHeader."Shipping Time";
                    end;
                    UpdateDates();
                end;
            end;
        }
        field(5712; "Product Group Code"; Code[10])
        {
            Caption = 'Product Group Code';
            ObsoleteReason = 'Product Groups became first level children of Item Categories.';
            ObsoleteState = Removed;
            ObsoleteTag = '15.0';
        }
        field(5713; "Special Order"; Boolean)
        {
            AccessByPermission = TableData "Drop Shpt. Post. Buffer" = R;
            Caption = 'Special Order';
            Editable = false;
        }
        field(5714; "Special Order Purchase No."; Code[20])
        {
            AccessByPermission = TableData "Drop Shpt. Post. Buffer" = R;
            Caption = 'Special Order Purchase No.';
            TableRelation = IF ("Special Order" = CONST(true)) "Purchase Header"."No." WHERE("Document Type" = CONST(Order));
        }
        field(5715; "Special Order Purch. Line No."; Integer)
        {
            AccessByPermission = TableData "Drop Shpt. Post. Buffer" = R;
            Caption = 'Special Order Purch. Line No.';
            TableRelation = IF ("Special Order" = CONST(true)) "Purchase Line"."Line No." WHERE("Document Type" = CONST(Order),
                                                                                               "Document No." = FIELD("Special Order Purchase No."));
        }
        field(5725; "Item Reference No."; Code[50])
        {
            AccessByPermission = TableData "Item Reference" = R;
            Caption = 'Item Reference No.';

            trigger OnLookup()
            begin
                GetSalesHeader();
                ItemReferenceMgt.SalesReferenceNoLookUp(Rec, SalesHeader);
            end;

            trigger OnValidate()
            var
                ItemReference: Record "Item Reference";
            begin
                GetSalesHeader();
                "Sell-to Customer No." := SalesHeader."Sell-to Customer No.";
                ItemReferenceMgt.ValidateSalesReferenceNo(Rec, SalesHeader, ItemReference, true, CurrFieldNo);
            end;
        }
        field(5726; "Item Reference Unit of Measure"; Code[10])
        {
            AccessByPermission = TableData "Item Reference" = R;
            Caption = 'Reference Unit of Measure';
            TableRelation = IF (Type = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));
        }
        field(5727; "Item Reference Type"; Enum "Item Reference Type")
        {
            Caption = 'Item Reference Type';
        }
        field(5728; "Item Reference Type No."; Code[30])
        {
            Caption = 'Item Reference Type No.';
        }
        field(5749; "Whse. Outstanding Qty."; Decimal)
        {
            AccessByPermission = TableData Location = R;
            BlankZero = true;
            CalcFormula = Sum("Warehouse Shipment Line"."Qty. Outstanding" WHERE("Source Type" = CONST(37),
#pragma warning disable
                                                                                  "Source Subtype" = FIELD("Document Type"),
#pragma warning restore
                                                                                  "Source No." = FIELD("Document No."),
                                                                                  "Source Line No." = FIELD("Line No.")));
            Caption = 'Whse. Outstanding Qty.';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5750; "Whse. Outstanding Qty. (Base)"; Decimal)
        {
            AccessByPermission = TableData Location = R;
            BlankZero = true;
            CalcFormula = Sum("Warehouse Shipment Line"."Qty. Outstanding (Base)" WHERE("Source Type" = CONST(37),
#pragma warning disable
                                                                                         "Source Subtype" = FIELD("Document Type"),
#pragma warning restore
                                                                                         "Source No." = FIELD("Document No."),
                                                                                         "Source Line No." = FIELD("Line No.")));
            Caption = 'Whse. Outstanding Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5752; "Completely Shipped"; Boolean)
        {
            Caption = 'Completely Shipped';
            Editable = false;
        }
        field(5790; "Requested Delivery Date"; Date)
        {
            Caption = 'Requested Delivery Date';

            trigger OnValidate()
            begin
                TestStatusOpen();
                CheckPromisedDeliveryDate();

                if "Requested Delivery Date" <> 0D then
                    Validate("Planned Delivery Date", CalcPlannedDeliveryDate(FieldNo("Requested Delivery Date")))
                else begin
                    GetSalesHeader();
                    Validate("Shipment Date", SalesHeader."Shipment Date");
                end;
            end;
        }
        field(5791; "Promised Delivery Date"; Date)
        {
            AccessByPermission = TableData "Order Promising Line" = R;
            Caption = 'Promised Delivery Date';

            trigger OnValidate()
            begin
                TestStatusOpen();
                if "Promised Delivery Date" <> 0D then
                    Validate("Planned Delivery Date", "Promised Delivery Date")
                else
                    Validate("Requested Delivery Date");
            end;
        }
        field(5792; "Shipping Time"; DateFormula)
        {
            AccessByPermission = TableData "Order Promising Line" = R;
            Caption = 'Shipping Time';

            trigger OnValidate()
            begin
                TestStatusOpen();
                if "Drop Shipment" then
                    DateFormularZero("Shipping Time", FieldNo("Shipping Time"), FieldCaption("Shipping Time"));
                UpdateDates();
            end;
        }
        field(5793; "Outbound Whse. Handling Time"; DateFormula)
        {
            AccessByPermission = TableData Location = R;
            Caption = 'Outbound Whse. Handling Time';

            trigger OnValidate()
            begin
                TestStatusOpen();
                if "Drop Shipment" then
                    DateFormularZero("Outbound Whse. Handling Time",
                      FieldNo("Outbound Whse. Handling Time"), FieldCaption("Outbound Whse. Handling Time"));
                UpdateDates();
            end;
        }
        field(5794; "Planned Delivery Date"; Date)
        {
            AccessByPermission = TableData "Order Promising Line" = R;
            Caption = 'Planned Delivery Date';

            trigger OnValidate()
            var
                IsHandled: boolean;
            begin
                IsHandled := false;
                OnBeforeValidatePlannedDeliveryDate(IsHandled, Rec);
                if IsHandled then
                    exit;

                TestStatusOpen();
                if "Planned Delivery Date" <> 0D then begin
                    PlannedDeliveryDateCalculated := true;

                    Validate("Planned Shipment Date", CalcPlannedDate);

                    if "Planned Shipment Date" > "Planned Delivery Date" then
                        "Planned Delivery Date" := "Planned Shipment Date";
                end;
                SetOldestAcceptableDate; // P8001062
            end;
        }
        field(5795; "Planned Shipment Date"; Date)
        {
            AccessByPermission = TableData "Order Promising Line" = R;
            Caption = 'Planned Shipment Date';

            trigger OnValidate()
            var
                IsHandled: boolean;
            begin
                IsHandled := false;
                OnBeforeValidatePlannedShipmentDate(IsHandled, Rec);
                if IsHandled then
                    exit;

                TestStatusOpen();
                if "Planned Shipment Date" <> 0D then begin
                    PlannedShipmentDateCalculated := true;

                    Validate("Shipment Date", CalcShipmentDate);
                end;
            end;
        }
        field(5796; "Shipping Agent Code"; Code[10])
        {
            AccessByPermission = TableData "Shipping Agent Services" = R;
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";

            trigger OnValidate()
            begin
                TestStatusOpen();
                if "Shipping Agent Code" <> xRec."Shipping Agent Code" then
                    Validate("Shipping Agent Service Code", '');
            end;
        }
        field(5797; "Shipping Agent Service Code"; Code[10])
        {
            AccessByPermission = TableData "Shipping Agent Services" = R;
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code WHERE("Shipping Agent Code" = FIELD("Shipping Agent Code"));

            trigger OnValidate()
            var
                ShippingAgentServices: Record "Shipping Agent Services";
            begin
                TestStatusOpen();
                if "Shipping Agent Service Code" <> xRec."Shipping Agent Service Code" then
                    Evaluate("Shipping Time", '<>');

                if "Drop Shipment" then begin
                    Evaluate("Shipping Time", '<0D>');
                    UpdateDates();
                end else
                    if ShippingAgentServices.Get("Shipping Agent Code", "Shipping Agent Service Code") then
                        "Shipping Time" := ShippingAgentServices."Shipping Time"
                    else begin
                        GetSalesHeader();
                        "Shipping Time" := SalesHeader."Shipping Time";
                    end;

                if ShippingAgentServices."Shipping Time" <> xRec."Shipping Time" then
                    Validate("Shipping Time", "Shipping Time");
            end;
        }
        field(5800; "Allow Item Charge Assignment"; Boolean)
        {
            AccessByPermission = TableData "Item Charge" = R;
            Caption = 'Allow Item Charge Assignment';
            InitValue = true;

            trigger OnValidate()
            begin
                CheckItemChargeAssgnt();
            end;
        }
        field(5801; "Qty. to Assign"; Decimal)
        {
            CalcFormula = Sum("Item Charge Assignment (Sales)"."Qty. to Assign" WHERE("Document Type" = FIELD("Document Type"),
                                                                                       "Document No." = FIELD("Document No."),
                                                                                       "Document Line No." = FIELD("Line No.")));
            Caption = 'Qty. to Assign';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5802; "Qty. Assigned"; Decimal)
        {
            CalcFormula = Sum("Item Charge Assignment (Sales)"."Qty. Assigned" WHERE("Document Type" = FIELD("Document Type"),
                                                                                      "Document No." = FIELD("Document No."),
                                                                                      "Document Line No." = FIELD("Line No.")));
            Caption = 'Qty. Assigned';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5803; "Return Qty. to Receive"; Decimal)
        {
            AccessByPermission = TableData "Return Receipt Header" = R;
            Caption = 'Return Qty. to Receive';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            var
                ItemLedgEntry: Record "Item Ledger Entry";
                IsHandled: Boolean;
                ContainerQuantity: Decimal;
            begin
                // P80070336
                if ((CurrFieldNo = FieldNo("Return Qty. to Receive")) and PriceInAlternateUnits) then
                    TestStatusOpen;
                // P80070336
                if (CurrFieldNo <> 0) and
                   (Type = Type::Item) and
                   ("Return Qty. to Receive" <> 0) and
                   (not "Drop Shipment")
                then
                    CheckWarehouse();

                "Return Qty. to Receive" := UOMMgt.RoundAndValidateQty("Return Qty. to Receive", "Qty. Rounding Precision", FieldCaption("Return Qty. to Receive"));

                // P8001323
                if Type = Type::FOODContainer then begin
                    if "Return Qty. to Receive" < GetContainerQuantity(true) then // P80046533
                        Error(Text37002013, FieldCaption("Return Qty. to Receive"));
                end else
                    if GetContainerQuantity(true) > 0 then // P80046533
                        if "Return Qty. to Receive" < GetContainerQuantity(true) then // P80046533
                            FieldError("Return Qty. to Receive", Text37002003);
                // P8001323

                OnValidateReturnQtyToReceiveOnAfterCheck(Rec, CurrFieldNo);

                ContainerQuantity := GetContainerQuantity(''); // P800131478
                if "Return Qty. to Receive" = Quantity - "Return Qty. Received" - ContainerQuantity then // P80046533, P800131478
                    InitQtyToReceive()
                else begin
                    "Return Qty. to Receive (Base)" := CalcBaseQty("Return Qty. Received" + "Return Qty. to Receive", FieldCaption("Return Qty. to Receive"), FieldCaption("Return Qty. to Receive (Base)")) - "Return Qty. Received (Base)"; // P8000550A
                    if ("Quantity (Base)" = ("Return Qty. Received (Base)" + "Return Qty. to Receive (Base)")) and ("Return Qty. to Receive" > 0) and (ContainerQuantity = 0) then // P800131478
                        Error(QuantityImbalanceErr, ItemUOMForCaption.FieldCaption("Qty. Rounding Precision"), Type::Item, "No.", FieldCaption("Return Qty. to Receive"), FieldCaption("Return Qty. to Receive (Base)"));

                    // PR3.60.03
                    if (Type = Type::Item) and ("No." <> '') and TrackAlternateUnits then
                        // P8000550A
                        // AltQtyMgmt.InitAlternateQty("No.", "Alt. Qty. Transaction No.",
                        //                             "Return Qty. to Receive" * "Qty. per Unit of Measure", "Return Qty. to Receive (Alt.)");
                        AltQtyMgmt.InitAlternateQtyToHandle(
                      "No.", "Alt. Qty. Transaction No.", "Quantity (Base)",
                      "Return Qty. to Receive (Base)", "Return Qty. Received (Base)",
                      "Quantity (Alt.)", "Return Qty. Received (Alt.)", "Return Qty. to Receive (Alt.)");
                    // P8000550A
                    // PR3.60.03

                    InitQtyToInvoice();
                end;

                IsHandled := false;
                OnValidateQtyToReturnAfterInitQty(Rec, xRec, CurrFieldNo, IsHandled);
                if not IsHandled then begin
                    if ("Return Qty. to Receive" * Quantity < 0) or
                        (Abs("Return Qty. to Receive") > Abs("Outstanding Quantity")) or
                        (Quantity * "Outstanding Quantity" < 0)
                     then
                        Error(Text020, "Outstanding Quantity");
                    if ("Return Qty. to Receive (Base)" * "Quantity (Base)" < 0) or
                       (Abs("Return Qty. to Receive (Base)") > Abs("Outstanding Qty. (Base)")) or
                       ("Quantity (Base)" * "Outstanding Qty. (Base)" < 0)
                    then
                        Error(Text021, "Outstanding Qty. (Base)");
                end;

                if (CurrFieldNo <> 0) and (Type = Type::Item) and ("Return Qty. to Receive" > 0) then
                    CheckApplFromItemLedgEntry(ItemLedgEntry);

                UpdateLotTracking(false, 0); // P8000043A, P8000466A
            end;
        }
        field(5804; "Return Qty. to Receive (Base)"; Decimal)
        {
            Caption = 'Return Qty. to Receive (Base)';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateReturnQtytoReceiveBase(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                TestField("Qty. per Unit of Measure", 1);
                Validate("Return Qty. to Receive", "Return Qty. to Receive (Base)");
            end;
        }
        field(5805; "Return Qty. Rcd. Not Invd."; Decimal)
        {
            Caption = 'Return Qty. Rcd. Not Invd.';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(5806; "Ret. Qty. Rcd. Not Invd.(Base)"; Decimal)
        {
            Caption = 'Ret. Qty. Rcd. Not Invd.(Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(5807; "Return Rcd. Not Invd."; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Return Rcd. Not Invd.';
            Editable = false;

            trigger OnValidate()
            var
                Currency2: Record Currency;
            begin
                GetSalesHeader();
                Currency2.InitRoundingPrecision;
                if SalesHeader."Currency Code" <> '' then
                    "Return Rcd. Not Invd. (LCY)" :=
                      Round(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                          GetDate, "Currency Code",
                          "Return Rcd. Not Invd.", SalesHeader."Currency Factor"),
                        Currency2."Amount Rounding Precision")
                else
                    "Return Rcd. Not Invd. (LCY)" :=
                      Round("Return Rcd. Not Invd.", Currency2."Amount Rounding Precision");
            end;
        }
        field(5808; "Return Rcd. Not Invd. (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Return Rcd. Not Invd. (LCY)';
            Editable = false;
        }
        field(5809; "Return Qty. Received"; Decimal)
        {
            AccessByPermission = TableData "Return Receipt Header" = R;
            Caption = 'Return Qty. Received';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(5810; "Return Qty. Received (Base)"; Decimal)
        {
            Caption = 'Return Qty. Received (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(5811; "Appl.-from Item Entry"; Integer)
        {
            AccessByPermission = TableData Item = R;
            Caption = 'Appl.-from Item Entry';
            MinValue = 0;

            trigger OnLookup()
            begin
                SelectItemEntry(FieldNo("Appl.-from Item Entry"));
            end;

            trigger OnValidate()
            var
                ItemLedgEntry: Record "Item Ledger Entry";
                QtyAlt: Decimal;
            begin
                if "Appl.-from Item Entry" <> 0 then begin
                    if ProcessFns.AltQtyInstalled then begin // P80046512
                                                             // P8007924
                                                             // When no AltQtyLinesExist then Quantity alt must be from ILE shipped not returned alt.
                        if ("Appl.-from Item Entry" <> 0) then begin
                            ItemLedgEntry.Get("Appl.-from Item Entry");
                            CurrFieldNo := 0;
                            if AltQtyMgmt.AltQtyLinesExist("Alt. Qty. Transaction No.") then
                                Error(Text37002014);
                            // P80052585
                            QtyAlt := AltQtyMgmt.GetActualAppliedAltQty("Appl.-from Item Entry", "Quantity (Alt.)");
                            if QtyAlt <> 0 then begin
                                "Quantity (Alt.)" := QtyAlt;
                                Validate("Return Qty. to Receive (Alt.)", "Quantity (Alt.)");
                            end;
                            // P80052585
                        end;

                        // "Return Qty. to Receive (Alt.)" alt should be always less than ILE shipped not returned alt.
                        if (Abs("Return Qty. to Receive (Alt.)") > -ItemLedgEntry."Shipped Qty. Not Ret. (Alt.)") then
                            Error(Text020, -ItemLedgEntry."Shipped Qty. Not Ret. (Alt.)");
                        // P8007924
                    end; // P80046512
                    CheckApplFromItemLedgEntry(ItemLedgEntry);
                    Validate("Unit Cost (LCY)", CalcUnitCost(ItemLedgEntry));
                end;
            end;
        }
        field(5909; "BOM Item No."; Code[20])
        {
            Caption = 'BOM Item No.';
            TableRelation = Item;
        }
        field(6600; "Return Receipt No."; Code[20])
        {
            Caption = 'Return Receipt No.';
            Editable = false;
        }
        field(6601; "Return Receipt Line No."; Integer)
        {
            Caption = 'Return Receipt Line No.';
            Editable = false;
        }
        field(6608; "Return Reason Code"; Code[10])
        {
            Caption = 'Return Reason Code';
            TableRelation = "Return Reason";

            trigger OnValidate()
            begin
                ValidateReturnReasonCode(FieldNo("Return Reason Code"));
            end;
        }
        field(6610; "Copied From Posted Doc."; Boolean)
        {
            Caption = 'Copied From Posted Doc.';
            DataClassification = SystemMetadata;
        }
        field(7000; "Price Calculation Method"; Enum "Price Calculation Method")
        {
            Caption = 'Price Calculation Method';
        }
        field(7001; "Allow Line Disc."; Boolean)
        {
            Caption = 'Allow Line Disc.';
            InitValue = true;
        }
        field(7002; "Customer Disc. Group"; Code[20])
        {
            Caption = 'Customer Disc. Group';
            TableRelation = "Customer Discount Group";

            trigger OnValidate()
            begin
                if Type = Type::Item then begin
                    if "Customer Disc. Group" <> xRec."Customer Disc. Group" then
                        PlanPriceCalcByField(FieldNo("Customer Disc. Group"));
                    UpdateUnitPriceByField(FieldNo("Customer Disc. Group"));
                end;
            end;
        }
        field(7003; Subtype; Option)
        {
            Caption = 'Subtype';
            OptionCaption = ' ,Item - Inventory,Item - Service,Comment';
            OptionMembers = " ","Item - Inventory","Item - Service",Comment;
        }
        field(7004; "Price description"; Text[80])
        {
            Caption = 'Price description';
        }
        field(7010; "Attached Doc Count"; Integer)
        {
            BlankNumbers = DontBlank;
            CalcFormula = Count("Document Attachment" WHERE("Table ID" = CONST(37),
                                                             "No." = FIELD("Document No."),
                                                             "Document Type" = FIELD("Document Type"),
                                                             "Line No." = FIELD("Line No.")));
            Caption = 'Attached Doc Count';
            FieldClass = FlowField;
            InitValue = 0;
        }
        field(10000; "Package Tracking No."; Text[30])
        {
            Caption = 'Package Tracking No.';
        }
        field(10001; "Retention Attached to Line No."; Integer)
        {
            Caption = 'Retention Attached to Line No.';
            TableRelation = IF (Quantity = FILTER(< 0)) "Sales Line"."Line No." WHERE("Document Type" = FIELD("Document Type"),
                                                                                    "Document No." = FIELD("Document No."),
                                                                                    Quantity = FILTER(> 0));

            trigger OnValidate()
            begin
                CheckRetentionAttachedToLineNo();
            end;
        }
        field(10002; "Retention VAT %"; Decimal)
        {
            Caption = 'Retention VAT %';
            AutoFormatType = 2;
            MaxValue = 100;
            MinValue = 0;
        }
        field(10003; "Custom Transit Number"; Text[30])
        {
            Caption = 'Custom Transit Number';
        }
    }

    keys
    {
        key(Key1; "Document Type", "Document No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Document No.", "Line No.", "Document Type")
        {
            Enabled = false;
        }
        key(Key3; "Document Type", Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Shipment Date")
        {
            SumIndexFields = "Outstanding Qty. (Base)", "Quantity (Alt.)", "Qty. Shipped (Alt.)";
        }
        key(Key4; "Document Type", "Bill-to Customer No.", "Currency Code", "Document No.")
        {
            SumIndexFields = "Outstanding Amount", "Shipped Not Invoiced", "Outstanding Amount (LCY)", "Shipped Not Invoiced (LCY)", "Return Rcd. Not Invd. (LCY)";
        }
        key(Key5; "Document Type", Type, "No.", "Variant Code", "Drop Shipment", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Location Code", "Shipment Date")
        {
            Enabled = false;
            SumIndexFields = "Outstanding Qty. (Base)";
        }
        key(Key6; "Document Type", "Bill-to Customer No.", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Currency Code", "Document No.")
        {
            Enabled = false;
            SumIndexFields = "Outstanding Amount", "Shipped Not Invoiced", "Outstanding Amount (LCY)", "Shipped Not Invoiced (LCY)";
        }
        key(Key7; "Document Type", "Blanket Order No.", "Blanket Order Line No.")
        {
        }
        key(Key8; "Document Type", "Document No.", "Location Code")
        {
            MaintainSQLIndex = false;
            SumIndexFields = Amount, "Amount Including VAT", "Outstanding Amount", "Shipped Not Invoiced", "Outstanding Amount (LCY)", "Shipped Not Invoiced (LCY)";
        }
        key(Key9; "Document Type", "Shipment No.", "Shipment Line No.")
        {
        }
        key(Key10; Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Document Type", "Shipment Date")
        {
            MaintainSQLIndex = false;
        }
        key(Key11; "Document Type", "Sell-to Customer No.", "Shipment No.", "Document No.")
        {
            SumIndexFields = "Outstanding Amount (LCY)";
        }
        key(Key12; "Job Contract Entry No.")
        {
        }
        key(Key13; "Document Type", "Document No.", "Qty. Shipped Not Invoiced")
        {
            Enabled = false;
        }
        key(Key14; "Document Type", "Document No.", Type, "No.")
        {
            Enabled = false;
        }
        key(Key15; "Recalculate Invoice Disc.")
        {
        }
        key(Key16; "Qty. Shipped Not Invoiced")
        {
        }
        key(Key17; "Qty. Shipped (Base)")
        {
        }
        key(Key18; "Shipment Date", "Outstanding Quantity")
        {
        }
        key(Key19; SystemModifiedAt)
        {
        }
        key(Key20; "Completely Shipped")
        {
        }
        key(Key378002001; "Price ID", "Document Type", "Bill-to Customer No.", Type, "No.", "Shipment Date")
        {
            SumIndexFields = "Quantity (Alt.)", "Qty. Invoiced (Alt.)", "Quantity (Base)", "Qty. Invoiced (Base)";
        }
        key(Key378002002; "Document Type", Type, "Shipment Date", "Delivery Route No.", "Delivery Stop No.", "Document No.")
        {
            SumIndexFields = Amount, "Qty. to Ship", "Net Weight to Ship", "Amount to Ship (LCY)", Quantity, "Outstanding Quantity", "Outstanding Amount (LCY)", "Qty. to Ship (Alt.)", "Line Amount";
        }
        key(Key378002003; "Document Type", "Document No.", Type, "Item Category Code")
        {
        }
        key(Key378002004; "Contract No.", "Price ID")
        {
            SumIndexFields = "Outstanding Qty. (Contract)", "Outstanding Qty. (Cont. Line)";
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", Description, "Line Amount", Quantity, "Unit of Measure Code", "Price description")
        {
        }
        fieldgroup(Brick; "No.", Description, "Line Amount", Quantity, "Unit of Measure Code", "Price description")
        {
        }
    }

    trigger OnDelete()
    var
        SalesCommentLine: Record "Sales Comment Line";
        CapableToPromise: Codeunit "Capable to Promise";
        JobCreateInvoice: Codeunit "Job Create-Invoice";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnDeleteOnBeforeTestStatusOpen(Rec, IsHandled);
        if not IsHandled then
            TestStatusOpen();
        TestContainerQuantityIsZero; // P80046533

        // PR3.70.03, P8000119A
        if ProcessFns.AccrualsInstalled() then
            AccrualMgmt.SalesDeleteLines(Rec);
        // PR3.70.03

        if (Quantity <> 0) and ItemExists("No.") then begin
            SalesLineReserve.DeleteLine(Rec);
            CheckReservedQtyBase();
            CheckNotInvoicedQty();
            WhseValidateSourceLine.SalesLineDelete(Rec);
        end;

        if ("Document Type" = "Document Type"::Order) and (Quantity <> "Quantity Invoiced") then
            TestField("Prepmt. Amt. Inv.", "Prepmt Amt Deducted");

        CleanDropShipmentFields();
        CleanSpecialOrderFieldsAndCheckAssocPurchOrder();
        CatalogItemMgt.DelNonStockSales(Rec);

        CheckLinkedBlanketOrderLineOnDelete();

        if Type = Type::Item then begin
            ATOLink.DeleteAsmFromSalesLine(Rec);
            DeleteItemChargeAssignment("Document Type", "Document No.", "Line No.");
        end;

        if Type = Type::"Charge (Item)" then
            DeleteChargeChargeAssgnt("Document Type", "Document No.", "Line No.");

        CapableToPromise.RemoveReqLines("Document No.", "Line No.", 0, false);

        if "Line No." <> 0 then begin
            SalesLine2.Reset();
            SalesLine2.SetRange("Document Type", "Document Type");
            SalesLine2.SetRange("Document No.", "Document No.");
            SalesLine2.SetRange("Attached to Line No.", "Line No.");
            SalesLine2.SetFilter("Line No.", '<>%1', "Line No.");
            OnDeleteOnAfterSetSalesLineFilters(SalesLine2);
            SalesLine2.DeleteAll(true);
        end;

        // PR3.61 Begin
        if Type = Type::FOODContainer then begin // P8001324
            SalesLine2.SetRange("Attached to Line No.");
            SalesLine2.SetRange("Container Line No.", "Line No.");
            SalesLine2.DeleteAll(true);
        end;
        // P8001324
        // PR3.61 End

        if "Job Contract Entry No." <> 0 then
            JobCreateInvoice.DeleteSalesLine(Rec);

        SalesCommentLine.SetRange("Document Type", "Document Type");
        SalesCommentLine.SetRange("No.", "Document No.");
        SalesCommentLine.SetRange("Document Line No.", "Line No.");
        if not SalesCommentLine.IsEmpty() then
            SalesCommentLine.DeleteAll();

        // PR1.00 Begin
        ProdXref.SetRange("Source Table ID", DATABASE::"Sales Line"); // PR2.00
        ProdXref.SetRange("Source Type", "Document Type");
        ProdXref.SetRange("Source No.", "Document No.");
        ProdXref.SetRange("Source Line No.", "Line No.");
        ProdXref.DeleteAll(true);
        // PR1.00 End

        if "Alt. Qty. Transaction No." <> 0 then                     // PR3.60
            AltQtyMgmt.DeleteAltQtyLines("Alt. Qty. Transaction No."); // PR3.60

        // PR3.70.01 Begin
        RepackLine.SetRange("Document Type", "Document Type");
        RepackLine.SetRange("Document No.", "Document No.");
        RepackLine.SetRange("Line No.", "Line No.");
        RepackLine.DeleteAll;
        // PR3.70.01 End

        if ProcessFns.TrackingInstalled then       // P8000153A
            LotSpecFns.DeleteSalesLineLotPrefs(Rec); // P8000153A

        // In case we have roundings on VAT or Sales Tax, we should update some other line
        if (Type <> Type::" ") and ("Line No." <> 0) and ("Attached to Line No." = 0) and ("Job Contract Entry No." = 0) and
           (Quantity <> 0) and (Amount <> 0) and (Amount <> "Amount Including VAT") and not StatusCheckSuspended
        then begin
            Quantity := 0;
            "Quantity (Base)" := 0;
            "Qty. to Invoice" := 0;
            "Qty. to Invoice (Base)" := 0;
            "Line Discount Amount" := 0;
            "Inv. Discount Amount" := 0;
            "Inv. Disc. Amount to Invoice" := 0;
            UpdateAmounts();
        end;

        if "Deferral Code" <> '' then
            DeferralUtilities.DeferralCodeOnDelete(
                "Deferral Document Type"::Sales.AsInteger(), '', '',
                "Document Type".AsInteger(), "Document No.", "Line No.");
    end;

    trigger OnInsert()
    begin
        TestStatusOpen();
        if Quantity <> 0 then begin
            OnBeforeVerifyReservedQty(Rec, xRec, 0);
            SalesLineReserve.VerifyQuantity(Rec, xRec);
        end;

        // PR3.70.03, P8000119A
        if ProcessFns.AccrualsInstalled() then
            AccrualMgmt.SalesInsertLines(Rec);
        // PR3.70.03

        LockTable();
        SalesHeader."No." := '';
        if Type = Type::Item then
            CheckInventoryPickConflict();
        OnInsertOnAfterCheckInventoryConflict(Rec, xRec, SalesLine2);
        if ProcessFns.TrackingInstalled then              // P8000153A
            LotSpecFns.CopyLotPrefCustomerToSalesLine(Rec); // P8000153A, P8000210A

        UpdateLotTracking(true, 0); // P8000043A, P8000466A

        CorrectUnitPriceFOB; // P8000921
        if ("Deferral Code" <> '') and (GetDeferralAmount <> 0) then
            UpdateDeferralAmounts();
    end;

    trigger OnModify()
    begin
        if ("Document Type" = "Document Type"::"Blanket Order") and
           ((Type <> xRec.Type) or ("No." <> xRec."No."))
        then begin
            SalesLine2.Reset();
            SalesLine2.SetCurrentKey("Document Type", "Blanket Order No.", "Blanket Order Line No.");
            SalesLine2.SetRange("Blanket Order No.", "Document No.");
            SalesLine2.SetRange("Blanket Order Line No.", "Line No.");
            if SalesLine2.FindSet() then
                repeat
                    SalesLine2.TestField(Type, Type);
                    SalesLine2.TestField("No.", "No.");
                until SalesLine2.Next() = 0;
        end;

        if (xRec.Type <> Type) or (xRec."No." <> "No.") then // P8000210A
            if ProcessFns.TrackingInstalled then              // P8000153A
                LotSpecFns.CopyLotPrefCustomerToSalesLine(Rec); // P8000153A, P8000210A

        if ((Quantity <> 0) or (xRec.Quantity <> 0)) and ItemExists(xRec."No.") and not FullReservedQtyIsForAsmToOrder then
            VerifyChangeForSalesLineReserve(0);

        if ((Type = Type::Item) and ("No." <> xRec."No.")) or "Drop Shipment" then // P80058334
            UpdateLotTracking(true, 0); // P8000760

        CorrectUnitPriceFOB; // P8000921
    end;

    trigger OnRename()
    begin
        Error(Text001, TableCaption);
    end;

    var
        Text000: Label 'You cannot delete the order line because it is associated with purchase order %1 line %2.';
        Text001: Label 'You cannot rename a %1.';
        Text002: Label 'You cannot change %1 because the order line is associated with purchase order %2 line %3.';
        Text003: Label 'must not be less than %1';
        Text005: Label 'You cannot invoice more than %1 units.';
        Text006: Label 'You cannot invoice more than %1 base units.';
        Text007: Label 'You cannot ship more than %1 units.';
        Text008: Label 'You cannot ship more than %1 base units.';
        Text009: Label ' must be 0 when %1 is %2';
        ManualReserveQst: Label 'Automatic reservation is not possible.\Do you want to reserve items manually?';
        Text014: Label '%1 %2 is before work date %3';
        Text016: Label '%1 is required for %2 = %3.';
        WhseRequirementMsg: Label '%1 is required for this line. The entered information may be disregarded by warehouse activities.', Comment = '%1=Document';
        Text020: Label 'You cannot return more than %1 units.';
        Text021: Label 'You cannot return more than %1 base units.';
        Text026: Label 'You cannot change %1 if the item charge has already been posted.';
        QuantityImbalanceErr: Label '%1 on %2-%3 causes the %4 and %5 to be out of balance.', Comment = '%1 - field name, %2 - table name, %3 - primary key value, %4 - field name, %5 - field name';
        ItemUOMForCaption: Record "Item Unit of Measure";
        CurrExchRate: Record "Currency Exchange Rate";
        SalesHeader: Record "Sales Header";
        SalesLine2: Record "Sales Line";
        GLAcc: Record "G/L Account";
        Resource: Record Resource;
        Currency: Record Currency;
        Res: Record Resource;
        VATPostingSetup: Record "VAT Posting Setup";
        GenBusPostingGrp: Record "Gen. Business Posting Group";
        GenProdPostingGrp: Record "Gen. Product Posting Group";
        UnitOfMeasure: Record "Unit of Measure";
        NonstockItem: Record "Nonstock Item";
        SKU: Record "Stockkeeping Unit";
        ItemCharge: Record "Item Charge";
        InvtSetup: Record "Inventory Setup";
        Location: Record Location;
        ATOLink: Record "Assemble-to-Order Link";
        GLSetup: Record "General Ledger Setup";
        SalesSetup: Record "Sales & Receivables Setup";
        CalChange: Record "Customized Calendar Change";
        TempErrorMessage: Record "Error Message" temporary;
        CustCheckCreditLimit: Codeunit "Cust-Check Cr. Limit";
        ItemCheckAvail: Codeunit "Item-Check Avail.";
        SalesTaxCalculate: Codeunit "Sales Tax Calculate";
        SalesLineReserve: Codeunit "Sales Line-Reserve";
        UOMMgt: Codeunit "Unit of Measure Management";
        AddOnIntegrMgt: Codeunit AddOnIntegrManagement;
        DimMgt: Codeunit DimensionManagement;
        ItemSubstitutionMgt: Codeunit "Item Subst.";
        ItemReferenceMgt: Codeunit "Item Reference Management";
        CatalogItemMgt: Codeunit "Catalog Item Management";
        WhseValidateSourceLine: Codeunit "Whse. Validate Source Line";
        TransferExtendedText: Codeunit "Transfer Extended Text";
        DeferralUtilities: Codeunit "Deferral Utilities";
        CalendarMgmt: Codeunit "Calendar Management";
        PostingSetupMgt: Codeunit PostingSetupManagement;
        PriceType: Enum "Price Type";
        FieldCausedPriceCalculation: Integer;
        FullAutoReservation: Boolean;
        HasBeenShown: Boolean;
        PlannedShipmentDateCalculated: Boolean;
        PlannedDeliveryDateCalculated: Boolean;
        Text028: Label 'You cannot change the %1 when the %2 has been filled in.';
        Text029: Label 'must be positive';
        Text030: Label 'must be negative';
        Text031: Label 'You must either specify %1 or %2.';
        Text034: Label 'The value of %1 field must be a whole number for the item included in the service item group if the %2 field in the Service Item Groups window contains a check mark.';
        Text035: Label 'Warehouse ';
        Text036: Label 'Inventory ';
        Text037: Label 'You cannot change %1 when %2 is %3 and %4 is positive.';
        Text038: Label 'You cannot change %1 when %2 is %3 and %4 is negative.';
        Text039: Label '%1 units for %2 %3 have already been returned. Therefore, only %4 units can be returned.';
        Text042: Label 'When posting the Applied to Ledger Entry %1 will be opened first';
        ShippingMoreUnitsThanReceivedErr: Label 'You cannot ship more than the %1 units that you have received for document no. %2.';
        Text044: Label 'cannot be less than %1';
        Text045: Label 'cannot be more than %1';
        Text046: Label 'You cannot return more than the %1 units that you have shipped for %2 %3.';
        Text047: Label 'must be positive when %1 is not 0.';
        Text048: Label 'You cannot use item tracking on a %1 created from a %2.';
        Text049: Label 'cannot be %1.';
        Text1020001: Label 'must be %1 when the Prepayment Invoice has already been posted', Comment = 'starts with a field name; %1 - numeric value';
        Text051: Label 'You cannot use %1 in a %2.';
        Text052: Label 'You cannot add an item line because an open warehouse shipment exists for the sales header and Shipping Advice is %1.\\You must add items as new lines to the existing warehouse shipment or change Shipping Advice to Partial.';
        Text053: Label 'You have changed one or more dimensions on the %1, which is already shipped. When you post the line with the changed dimension to General Ledger, amounts on the Inventory Interim account will be out of balance when reported per dimension.\\Do you want to keep the changed dimension?';
        Text054: Label 'Cancelled.';
        Text055: Label '%1 must not be greater than the sum of %2 and %3.', Comment = 'Quantity Invoiced must not be greater than the sum of Qty. Assigned and Qty. to Assign.';
        Text056: Label 'You cannot add an item line because an open inventory pick exists for the Sales Header and because Shipping Advice is %1.\\You must first post or delete the inventory pick or change Shipping Advice to Partial.';
        Text057: Label 'must have the same sign as the shipment';
        Text058: Label 'The quantity that you are trying to invoice is greater than the quantity in shipment %1.';
        Text059: Label 'must have the same sign as the return receipt';
        Text060: Label 'The quantity that you are trying to invoice is greater than the quantity in return receipt %1.';
        Text1020000: Label 'You must reopen the document since this will affect Sales Tax.';
        Text1020003: Label 'The %1 field in the %2 used on the %3 must match the %1 field in the %2 used on the %4.';
        ItemChargeAssignmentErr: Label 'You can only assign Item Charges for Line Types of Charge (Item).';
        SalesLineCompletelyShippedErr: Label 'You cannot change the purchasing code for a sales line that has been completely shipped.';
        SalesSetupRead: Boolean;
        LookupRequested: Boolean;
        ProdXref: Record "Production Order XRef";
        ContainerHeader: Record "Container Header";
        RepackLine: Record "Sales Line Repack";
        P800Globals: Codeunit "Process 800 System Globals";
        P800CoreFns: Codeunit "Process 800 Core Functions";
        ContainerFns: Codeunit "Container Functions";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        WarehouseUpdate: array[2] of Boolean;
        ProcessFns: Codeunit "Process 800 Functions";
        AccrualMgmt: Codeunit "Sales Accrual Management";
        AccrualFldMgmt: Codeunit "Accrual Field Management";
        LotSpecFns: Codeunit "Lot Specification Functions";
        Text37002000: Label 'Quantity to ship exceeds outstanding quantity.\\OK to proceed?';
        Text37002001: Label 'Outstanding quantity exceeds quantity to ship.\\Backorder remainder?';
        Text37002002: Label 'The update has been interrupted to respect the warning.';
        Text37002003: Label 'cannot be less than quantity assigned through containers';
        Text37002005: Label 'Only contract items are allowed.';
        Text37002006: Label 'may not be edited';
        Text37002007: Label 'Lot %1 fails to meet established lot preferences.';
        CreditCheckSuspended: Boolean;
        Text37002008: Label '%1 %5 for %2 %3 have already been returned. Therefore, only %4 %5 can be returned.';
        GlobalApplyFromEntryNo: Integer;
        ItemSalesPriceMgmt: Codeunit "Item Sales Price Management";
        CustItemAltMgmt: Codeunit "Cust./Item Alt. Mgmt.";
        DoNotUpdatePrice: Boolean;
        SalesContMgt: Codeunit "Sales Contract Management";
        Text37002009: Label '%1 must be on or before %2 (%3)';
        Text37002010: Label '%1 must be on or after %2 (%3)';
        Text37002011: Label '%1 Date';
        ItemVariant: Record "Item Variant";
        Text37002012: Label 'Line is associated with one or more containers.';
        ContainerType: Record "Container Type";
        Text37002013: Label '%1 cannot be less than number of containers assigned.';
        UseWhseLineQty: Boolean;
        WhseLineQtyBase: Decimal;
        WhseLineQtyAlt: Decimal;
        FreightLineDescriptionTxt: Label 'Freight Amount';
        Text37002014: Label 'Alternate Quantity detail has already been specified.';
        CannotFindDescErr: Label 'Cannot find %1 with Description %2.\\Make sure to use the correct type.', Comment = '%1 = Type caption %2 = Description';
        PriceDescriptionTxt: Label 'x%1 (%2%3/%4)', Locked = true;
        PriceDescriptionWithLineDiscountTxt: Label 'x%1 (%2%3/%4) - %5%', Locked = true;
        SelectNonstockItemErr: Label 'You can only select a catalog item for an empty line.';
        CommentLbl: Label 'Comment';
        LineDiscountPctErr: Label 'The value in the Line Discount % field must be between 0 and 100.';
        SalesBlockedErr: Label 'You cannot sell this item because the Sales Blocked check box is selected on the item card.';
        CannotChangePrepaidServiceChargeErr: Label 'You cannot change the line because it will affect service charges that are already invoiced as part of a prepayment.';
        LineAmountInvalidErr: Label 'You have set the line amount to a value that results in a discount that is not valid. Consider increasing the unit price instead.';
        WhseLineQtyToInvBase: Decimal;
        SettingUnitPrice: Boolean;
        IsShortSubstituteItem: Boolean;
        LineInvoiceDiscountAmountResetTok: Label 'The value in the Inv. Discount Amount field in %1 has been cleared.', Comment = '%1 - Record ID';
        UnitPriceChangedMsg: Label 'The unit price for %1 %2 that was copied from the posted document has been changed.', Comment = '%1 = Type caption %2 = No.';
        BlockedItemNotificationMsg: Label 'Item %1 is blocked, but it is allowed on this type of document.', Comment = '%1 is Item No.';
        InvDiscForPrepmtExceededErr: Label 'You cannot enter an invoice discount for sales document %1.\\You must cancel the prepayment invoice first and then you will be able to update the invoice discount.', Comment = '%1 - document number';
        CannotAllowInvDiscountErr: Label 'The value of the %1 field is not valid when the VAT Calculation Type field is set to "Full VAT".', Comment = '%1 is the name of not valid field';
        CannotChangeVATGroupWithPrepmInvErr: Label 'You cannot change the VAT product posting group because prepayment invoices have been posted.\\You need to post the prepayment credit memo to be able to change the VAT product posting group.';
        CannotChangePrepmtAmtDiffVAtPctErr: Label 'You cannot change the prepayment amount because the prepayment invoice has been posted with a different VAT percentage. Please check the settings on the prepayment G/L account.';
        NonInvReserveTypeErr: Label 'Non-inventory items must have the reserve type Never. The current reserve type for item %1 is %2.', Comment = '%1 is Item No., %2 is Reserve';

    protected var
        HideValidationDialog: Boolean;
        StatusCheckSuspended: Boolean;
        PrePaymentLineAmountEntered: Boolean;

    procedure InitOutstanding()
    begin
        if IsCreditDocType() then begin
            "Outstanding Quantity" := Quantity - "Return Qty. Received";
            "Outstanding Qty. (Base)" := "Quantity (Base)" - "Return Qty. Received (Base)";
            "Return Qty. Rcd. Not Invd." := "Return Qty. Received" - "Quantity Invoiced";
            "Ret. Qty. Rcd. Not Invd.(Base)" := "Return Qty. Received (Base)" - "Qty. Invoiced (Base)";
        end else begin
            "Outstanding Quantity" := Quantity - "Quantity Shipped";
            "Outstanding Qty. (Base)" := "Quantity (Base)" - "Qty. Shipped (Base)";
            "Qty. Shipped Not Invoiced" := "Quantity Shipped" - "Quantity Invoiced";
            "Qty. Shipped Not Invd. (Base)" := "Qty. Shipped (Base)" - "Qty. Invoiced (Base)";
        end;
        OnAfterInitOutstandingQty(Rec);
        UpdatePlanned();
        "Completely Shipped" := (Quantity <> 0) and ("Outstanding Quantity" = 0);
        InitOutstandingAmount();
        InitOutstandingQtyCont; // P8000885

        OnAfterInitOutstanding(Rec);
    end;

    procedure InitOutstandingAmount()
    var
        AmountInclVAT: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitOutstandingAmount(Rec, xRec, CurrFieldNo, IsHandled);
        if IsHandled then
            exit;

        if Quantity = 0 then begin
            "Outstanding Amount" := 0;
            "Outstanding Amount (LCY)" := 0;
            "Shipped Not Invoiced" := 0;
            "Shipped Not Invoiced (LCY)" := 0;
            "Return Rcd. Not Invd." := 0;
            "Return Rcd. Not Invd. (LCY)" := 0;
        end else begin
            GetSalesHeader();
            if SalesHeader."Prices Including VAT" then
                AmountInclVAT := "Line Amount" - "Inv. Discount Amount"
            else
                if "VAT Calculation Type" = "VAT Calculation Type"::"Sales Tax" then begin
                    AmountInclVAT :=
                      CalcLineAmount +
                      Round(
                        SalesTaxCalculate.CalculateTax(
                          "Tax Area Code", "Tax Group Code", "Tax Liable", SalesHeader."Posting Date",
                          CalcLineAmount, "Quantity (Base)", SalesHeader."Currency Factor"),
                        Currency."Amount Rounding Precision");
                    AmountInclVAT += SalesTaxCalculate.CalculateExpenseTax(
                        "Tax Area Code", "Tax Group Code", "Tax Liable", SalesHeader."Posting Date",
                        CalcLineAmount, "Quantity (Base)", SalesHeader."Currency Factor");
                end else
                    AmountInclVAT :=
                      Round(
                        CalcLineAmount * (1 + "VAT %" / 100 * (1 - SalesHeader."VAT Base Discount %" / 100)),
                        Currency."Amount Rounding Precision");
            Validate(
              "Outstanding Amount",
              Round(
                AmountInclVAT * "Outstanding Quantity" / Quantity,
                Currency."Amount Rounding Precision"));
            if IsCreditDocType() then
                Validate(
                  "Return Rcd. Not Invd.",
                  Round(
                    AmountInclVAT * "Return Qty. Rcd. Not Invd." / Quantity,
                    Currency."Amount Rounding Precision"))
            else
                Validate(
                  "Shipped Not Invoiced",
                  Round(
                    AmountInclVAT * "Qty. Shipped Not Invoiced" / Quantity,
                    Currency."Amount Rounding Precision"));
        end;

        OnAfterInitOutstandingAmount(Rec, SalesHeader, Currency);
    end;

    procedure InitQtyToShip()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitQtyToShip(Rec, CurrFieldNo, IsHandled);
        if IsHandled then
            exit;

        GetSalesSetup();
        if (SalesSetup."Default Quantity to Ship" = SalesSetup."Default Quantity to Ship"::Remainder) or
           ("Document Type" = "Document Type"::Invoice)
        then begin
            "Qty. to Ship" := "Outstanding Quantity" - GetContainerQuantity(''); // P80046533
            "Qty. to Ship (Base)" := UOMMgt.CalcBaseQty("Qty. to Ship", "Qty. per Unit of Measure"); // P80046533
        end else
            if "Qty. to Ship" <> 0 then
                "Qty. to Ship (Base)" :=
                  MaxQtyToShipBase(CalcBaseQty("Qty. to Ship", FieldCaption("Qty. to Ship"), FieldCaption("Qty. to Ship (Base)")));
        OnInitQtyToShipOnBeforeCheckServItemCreation(Rec);
        CheckServItemCreation();

        OnAfterInitQtyToShip(Rec, CurrFieldNo);

        InitQtyToInvoice();
    end;

    procedure InitQtyToReceive()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitQtyToReceive(Rec, CurrFieldNo, IsHandled);
        if IsHandled then
            exit;

        GetSalesSetup();
        if (SalesSetup."Default Quantity to Ship" = SalesSetup."Default Quantity to Ship"::Remainder) or
           ("Document Type" = "Document Type"::"Credit Memo")
        then begin
            "Return Qty. to Receive" := "Outstanding Quantity" - GetContainerQuantity(''); // P80046533
            "Return Qty. to Receive (Base)" := UOMMgt.CalcBaseQty("Return Qty. to Receive", "Qty. per Unit of Measure"); // P80046533
        end else
            if "Return Qty. to Receive" <> 0 then
                "Return Qty. to Receive (Base)" := CalcBaseQty("Return Qty. to Receive", FieldCaption("Return Qty. to Receive"), FieldCaption("Return Qty. to Receive (Base)"));
        OnAfterInitQtyToReceive(Rec, CurrFieldNo);

        if ProcessFns.AltQtyInstalled then // P80046512
            AltQtyMgmt.SetActualAppliedAltQty(("Appl.-from Item Entry" <> 0) and ("Return Qty. to Receive (Alt.)" = 0));  // P8007924

        InitQtyToInvoice();
    end;

    procedure InitQtyToInvoice()
    begin
        "Qty. to Invoice" := MaxQtyToInvoice;
        "Qty. to Invoice (Base)" := MaxQtyToInvoiceBase;
        "VAT Difference" := 0;

        if TrackAlternateUnits then // PR3.60
            SetSalesLineAltQty;       // P8000408A

        OnBeforeCalcInvDiscToInvoice(Rec, CurrFieldNo);
        CalcInvDiscToInvoice;
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Invoice then
            CalcPrepaymentToDeduct();

        OnAfterInitQtyToInvoice(Rec, CurrFieldNo);
    end;

    local procedure InitItemAppl(OnlyApplTo: Boolean)
    begin
        "Appl.-to Item Entry" := 0;
        if not OnlyApplTo then
            "Appl.-from Item Entry" := 0;
    end;

    procedure MaxQtyToInvoice(): Decimal
    var
        MaxQty: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeMaxQtyToInvoice(Rec, MaxQty, IsHandled);
        if IsHandled then
            exit(MaxQty);

        if "Prepayment Line" then
            exit(1);

        if IsCreditDocType() then
            exit("Return Qty. Received" + "Return Qty. to Receive" - "Quantity Invoiced");

        exit("Quantity Shipped" + "Qty. to Ship" - "Quantity Invoiced");
    end;

    procedure MaxQtyToInvoiceBase(): Decimal
    var
        MaxQtyBase: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeMaxQtyToInvoiceBase(Rec, MaxQtyBase, IsHandled);
        if IsHandled then
            exit(MaxQtyBase);

        if IsCreditDocType() then
            exit("Return Qty. Received (Base)" + "Return Qty. to Receive (Base)" - "Qty. Invoiced (Base)");

        exit("Qty. Shipped (Base)" + "Qty. to Ship (Base)" - "Qty. Invoiced (Base)");
    end;

    procedure MaxQtyToShipBase(QtyToShipBase: Decimal): Decimal
    begin
        if Abs(QtyToShipBase) > Abs("Outstanding Qty. (Base)") then
            exit("Outstanding Qty. (Base)");

        exit(QtyToShipBase);
    end;

    procedure CalcLineAmount() LineAmount: Decimal
    begin
        LineAmount := "Line Amount" - "Inv. Discount Amount";

        OnAfterCalcLineAmount(Rec, LineAmount);
    end;

    local procedure CopyFromStandardText()
    var
        StandardText: Record "Standard Text";
    begin
        "Tax Area Code" := '';
        "Tax Liable" := false;
        StandardText.Get("No.");
        Description := StandardText.Description;
        "Allow Item Charge Assignment" := false;
        OnAfterAssignStdTxtValues(Rec, StandardText, SalesHeader);
    end;

    procedure CalcShipmentDateForLocation()
    var
        CustomCalendarChange: Array[2] of Record "Customized Calendar Change";
    begin
        CustomCalendarChange[1].SetSource(CalChange."Source Type"::Location, "Location Code", '', '');
        "Shipment Date" := CalendarMgmt.CalcDateBOC('', SalesHeader."Shipment Date", CustomCalendarChange, false);
    end;

    local procedure CopyFromGLAccount()
    begin
        GLAcc.Get("No.");
        GLAcc.CheckGLAcc;
        if not "System-Created Entry" then
            GLAcc.TestField("Direct Posting", true);
        Description := GLAcc.Name;
        "Gen. Prod. Posting Group" := GLAcc."Gen. Prod. Posting Group";
        "VAT Prod. Posting Group" := GLAcc."VAT Prod. Posting Group";
        "Tax Group Code" := GLAcc."Tax Group Code";
        "Allow Invoice Disc." := false;
        "Allow Item Charge Assignment" := false;
        InitDeferralCode();
        OnAfterAssignGLAccountValues(Rec, GLAcc, SalesHeader);
    end;

    local procedure CopyFromItem()
    var
        Item: Record Item;
        PrepaymentMgt: Codeunit "Prepayment Mgt.";
        IsHandled: Boolean;
    begin
        GetItem(Item);
        IsHandled := false;
        OnBeforeCopyFromItem(Rec, Item, IsHandled);
        if not IsHandled then begin
            Item.TestField(Blocked, false);
            Item.TestField("Gen. Prod. Posting Group");
            if Item."Sales Blocked" then
                if IsCreditDocType() then
                    SendBlockedItemNotification()
                else
                    Error(SalesBlockedErr);
            if Item.Type = Item.Type::Inventory then begin
                Item.TestField("Inventory Posting Group");
                "Posting Group" := Item."Inventory Posting Group";
            end;
        end;

        OnCopyFromItemOnAfterCheck(Rec, Item);

        Description := Item.Description;
        "Description 2" := Item."Description 2";
        GetUnitCost();
        "Allow Invoice Disc." := Item."Allow Invoice Disc.";
        "Units per Parcel" := Item."Units per Parcel";
        "Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
        "VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
        "Tax Group Code" := Item."Tax Group Code";
        "Package Tracking No." := SalesHeader."Package Tracking No.";
        "Item Category Code" := Item."Item Category Code";
        "Supply Chain Group Code" := Item.GetSupplyChainGroupCode; // P8000931
        // P8000545A
        ItemSalesPriceMgmt.SetCustItemPriceGroup(
          "Customer Price Group", SalesHeader.PriceGroupCustomerNo, "Item Category Code"); // P8001026, P8007749
        ItemSalesPriceMgmt.SetCustItemDiscGroup(
          "Customer Disc. Group", SalesHeader.PriceGroupCustomerNo, "Item Category Code"); // P8001026, P8007749
        // P8000545A
        Nonstock := Item."Created From Nonstock Item";
        "Profit %" := Item."Profit %";
        "Allow Item Charge Assignment" := true;
        PrepaymentMgt.SetSalesPrepaymentPct(Rec, SalesHeader."Posting Date");
        if IsInventoriableItem() then
            PostingSetupMgt.CheckInvtPostingSetupInventoryAccount("Location Code", "Posting Group");

        if SalesHeader."Language Code" <> '' then
            GetItemTranslation();

        if Item.Reserve = Item.Reserve::Optional then
            Reserve := SalesHeader.Reserve
        else
            Reserve := Item.Reserve;

        if Item."Sales Unit of Measure" <> '' then
            "Unit of Measure Code" := Item."Sales Unit of Measure"
        else
            "Unit of Measure Code" := Item."Base Unit of Measure";
        if Type = Type::Item then begin // P8001375
            if "Document Type" in ["Document Type"::Quote, "Document Type"::Order] then
                Validate("Purchasing Code", Item."Purchasing Code");
            if "Document Type" = "Document Type"::"Return Order" then              // P8001047
                Validate("Label Unit of Measure Code", Item."Label Unit of Measure"); // P8001047
        end;

        GetLotFreshness;         // P8001062
        SetOldestAcceptableDate; // P8001062
        AutoLotNo(false); // P8000250B
        OnAfterCopyFromItem(Rec, Item, CurrFieldNo);
        InitDeferralCode();
        SetDefaultItemQuantity();
        OnAfterAssignItemValues(Rec, Item);
    end;

    local procedure CopyFromResource()
    var
        IsHandled: Boolean;
    begin
        Res.Get("No.");
        Res.CheckResourcePrivacyBlocked(false);
        IsHandled := false;
        OnCopyFromResourceOnBeforeTestBlocked(Res, IsHandled);
        if not IsHandled then
            Res.TestField(Blocked, false);
        Res.TestField("Gen. Prod. Posting Group");
        Description := Res.Name;
        "Description 2" := Res."Name 2";
        "Unit of Measure Code" := Res."Base Unit of Measure";
        "Unit Cost (LCY)" := Res."Unit Cost";
        "Gen. Prod. Posting Group" := Res."Gen. Prod. Posting Group";
        "VAT Prod. Posting Group" := Res."VAT Prod. Posting Group";
        "Tax Group Code" := Res."Tax Group Code";
        "Allow Item Charge Assignment" := false;
        ApplyResUnitCost(FieldNo("No."));
        InitDeferralCode();
        OnAfterAssignResourceValues(Rec, Res, SalesHeader);
    end;

    local procedure CopyFromFixedAsset()
    var
        FixedAsset: Record "Fixed Asset";
    begin
        FixedAsset.Get("No.");
        FixedAsset.TestField(Inactive, false);
        FixedAsset.TestField(Blocked, false);
        GetFAPostingGroup();
        Description := FixedAsset.Description;
        "Description 2" := FixedAsset."Description 2";
        "Allow Invoice Disc." := false;
        "Allow Item Charge Assignment" := false;
        OnAfterAssignFixedAssetValues(Rec, FixedAsset, SalesHeader);
    end;

    local procedure CopyFromItemCharge()
    begin
        ItemCharge.Get("No.");
        Description := ItemCharge.Description;
        "Gen. Prod. Posting Group" := ItemCharge."Gen. Prod. Posting Group";
        "VAT Prod. Posting Group" := ItemCharge."VAT Prod. Posting Group";
        "Tax Group Code" := ItemCharge."Tax Group Code";
        "Allow Invoice Disc." := false;
        "Allow Item Charge Assignment" := false;
        OnAfterAssignItemChargeValues(Rec, ItemCharge, SalesHeader);
    end;

    [Scope('OnPrem')]
    procedure CopyFromSalesLine(FromSalesLine: Record "Sales Line")
    begin
        "No." := FromSalesLine."No.";
        "Variant Code" := FromSalesLine."Variant Code";
        "Location Code" := FromSalesLine."Location Code";
        "Bin Code" := FromSalesLine."Bin Code";
        "Unit of Measure Code" := FromSalesLine."Unit of Measure Code";
        "Qty. per Unit of Measure" := FromSalesLine."Qty. per Unit of Measure";
        "Outstanding Quantity" := FromSalesLine.Quantity;
        "Qty. to Assemble to Order" := 0;
        "Drop Shipment" := FromSalesLine."Drop Shipment";
        OnAfterCopyFromSalesLine(Rec, FromSalesLine);
    end;

    [Scope('OnPrem')]
    procedure CopyFromSalesShptLine(FromSalesShptLine: Record "Sales Shipment Line")
    begin
        "No." := FromSalesShptLine."No.";
        "Variant Code" := FromSalesShptLine."Variant Code";
        "Location Code" := FromSalesShptLine."Location Code";
        "Bin Code" := FromSalesShptLine."Bin Code";
        "Unit of Measure Code" := FromSalesShptLine."Unit of Measure Code";
        "Qty. per Unit of Measure" := FromSalesShptLine."Qty. per Unit of Measure";
        "Outstanding Quantity" := FromSalesShptLine.Quantity;
        "Qty. to Assemble to Order" := 0;
        "Drop Shipment" := FromSalesShptLine."Drop Shipment";

        OnAfterCopyFromSalesShptLine(Rec, FromSalesShptLine);
    end;

    [Scope('OnPrem')]
    procedure CopyFromSalesInvLine(FromSalesInvLine: Record "Sales Invoice Line")
    begin
        "No." := FromSalesInvLine."No.";
        "Variant Code" := FromSalesInvLine."Variant Code";
        "Location Code" := FromSalesInvLine."Location Code";
        "Bin Code" := FromSalesInvLine."Bin Code";
        "Unit of Measure Code" := FromSalesInvLine."Unit of Measure Code";
        "Qty. per Unit of Measure" := FromSalesInvLine."Qty. per Unit of Measure";
        "Outstanding Quantity" := FromSalesInvLine.Quantity;
        "Drop Shipment" := FromSalesInvLine."Drop Shipment";
    end;

    [Scope('OnPrem')]
    procedure CopyFromReturnRcptLine(FromReturnRcptLine: Record "Return Receipt Line")
    begin
        "No." := FromReturnRcptLine."No.";
        "Variant Code" := FromReturnRcptLine."Variant Code";
        "Location Code" := FromReturnRcptLine."Location Code";
        "Bin Code" := FromReturnRcptLine."Bin Code";
        "Unit of Measure Code" := FromReturnRcptLine."Unit of Measure Code";
        "Qty. per Unit of Measure" := FromReturnRcptLine."Qty. per Unit of Measure";
        "Outstanding Quantity" := FromReturnRcptLine.Quantity;
        "Drop Shipment" := false;
    end;

    [Scope('OnPrem')]
    procedure CopyFromSalesCrMemoLine(FromSalesCrMemoLine: Record "Sales Cr.Memo Line")
    begin
        "No." := FromSalesCrMemoLine."No.";
        "Variant Code" := FromSalesCrMemoLine."Variant Code";
        "Location Code" := FromSalesCrMemoLine."Location Code";
        "Bin Code" := FromSalesCrMemoLine."Bin Code";
        "Unit of Measure Code" := FromSalesCrMemoLine."Unit of Measure Code";
        "Qty. per Unit of Measure" := FromSalesCrMemoLine."Qty. per Unit of Measure";
        "Outstanding Quantity" := FromSalesCrMemoLine.Quantity;
        "Drop Shipment" := false;
    end;

    local procedure SelectItemEntry(CurrentFieldNo: Integer)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        SalesLine3: Record "Sales Line";
    begin
        ItemLedgEntry.SetRange("Item No.", "No.");
        if "Location Code" <> '' then
            ItemLedgEntry.SetRange("Location Code", "Location Code");
        ItemLedgEntry.SetRange("Variant Code", "Variant Code");

        if CurrentFieldNo = FieldNo("Appl.-to Item Entry") then begin
            ItemLedgEntry.SetCurrentKey("Item No.", Open);
            ItemLedgEntry.SetRange(Positive, true);
            ItemLedgEntry.SetRange(Open, true);
        end else begin
            ItemLedgEntry.SetCurrentKey("Item No.", Positive);
            ItemLedgEntry.SetRange(Positive, false);
            ItemLedgEntry.SetFilter("Shipped Qty. Not Returned", '<0');
        end;
        OnSelectItemEntryOnAfterSetFilters(ItemLedgEntry, Rec, CurrFieldNo);
        if PAGE.RunModal(PAGE::"Item Ledger Entries", ItemLedgEntry) = ACTION::LookupOK then begin
            SalesLine3 := Rec;
            if CurrentFieldNo = FieldNo("Appl.-to Item Entry") then
                SalesLine3.Validate("Appl.-to Item Entry", ItemLedgEntry."Entry No.")
            else
                SalesLine3.Validate("Appl.-from Item Entry", ItemLedgEntry."Entry No.");
            CheckItemAvailable(CurrentFieldNo);
            Rec := SalesLine3;
        end;
    end;

    procedure SetSalesHeader(NewSalesHeader: Record "Sales Header")
    begin
        SalesHeader := NewSalesHeader;
        OnBeforeSetSalesHeader(SalesHeader);

        if SalesHeader."Currency Code" = '' then
            Currency.InitRoundingPrecision
        else begin
            SalesHeader.TestField("Currency Factor");
            Currency.Get(SalesHeader."Currency Code");
            Currency.TestField("Amount Rounding Precision");
        end;

        OnAfterSetSalesHeader(Rec, SalesHeader, Currency);
    end;

    procedure GetSalesHeader(): Record "Sales Header"
    begin
        GetSalesHeader(SalesHeader, Currency);
        exit(SalesHeader);
    end;

    procedure GetSalesHeader(var OutSalesHeader: Record "Sales Header"; var OutCurrency: Record Currency)
    var
        IsHandled: Boolean;
    begin
        OnBeforeGetSalesHeader(Rec, SalesHeader, IsHandled, Currency);
        if IsHandled then
            exit;

        TestField("Document No.");
        if ("Document Type" <> SalesHeader."Document Type") or ("Document No." <> SalesHeader."No.") then begin
            SalesHeader.Get("Document Type", "Document No.");
            if SalesHeader."Currency Code" = '' then
                Currency.InitRoundingPrecision
            else begin
                SalesHeader.TestField("Currency Factor");
                Currency.Get(SalesHeader."Currency Code");
                Currency.TestField("Amount Rounding Precision");
            end;
        end;

        OnAfterGetSalesHeader(Rec, SalesHeader, Currency);
        OutSalesHeader := SalesHeader;
        OutCurrency := Currency;
    end;

    procedure GetItem(): Record Item
    var
        Item: Record Item;
    begin
        TestField("No.");
        Item.Get("No.");
        exit(Item);
    end;

    procedure GetItem(var Item: Record Item)
    begin
        TestField("No.");
        Item.Get("No.");
    end;

    // P800128960
    local procedure GetItemNo(): Code[20]
    var
        Item: Record Item;
    begin
        if (Type = Type::Item) and ("No." <> '') then begin
            Item.Get("No.");
            exit(Item."No.");
        end;
    end;

    procedure GetResource(): Record Resource
    begin
        TestField("No.");
        if "No." <> Resource."No." then
            Resource.Get("No.");
        exit(Resource);
    end;

    procedure GetRemainingQty(var RemainingQty: Decimal; var RemainingQtyBase: Decimal)
    begin
        CalcFields("Reserved Quantity", "Reserved Qty. (Base)");
        RemainingQty := "Outstanding Quantity" - Abs("Reserved Quantity");
        RemainingQtyBase := "Outstanding Qty. (Base)" - Abs("Reserved Qty. (Base)");
    end;

    procedure GetReservationQty(var QtyReserved: Decimal; var QtyReservedBase: Decimal; var QtyToReserve: Decimal; var QtyToReserveBase: Decimal) Result: Decimal
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetReservationQty(Rec, QtyReserved, QtyReservedBase, QtyToReserve, QtyToReserveBase, Result, IsHandled);
        if IsHandled then
            exit(Result);

        CalcFields("Reserved Quantity", "Reserved Qty. (Base)");
        if "Document Type" = "Document Type"::"Return Order" then begin
            "Reserved Quantity" := -"Reserved Quantity";
            "Reserved Qty. (Base)" := -"Reserved Qty. (Base)";
        end;
        QtyReserved := "Reserved Quantity";
        QtyReservedBase := "Reserved Qty. (Base)";
        QtyToReserve := "Outstanding Quantity";
        QtyToReserveBase := "Outstanding Qty. (Base)";
        exit("Qty. per Unit of Measure");
    end;

    procedure GetSourceCaption(): Text
    begin
        exit(StrSubstNo('%1 %2 %3', "Document Type", "Document No.", "No."));
    end;

    procedure SetReservationEntry(var ReservEntry: Record "Reservation Entry")
    begin
        ReservEntry.SetSource(DATABASE::"Sales Line", "Document Type".AsInteger(), "Document No.", "Line No.", '', 0);
        ReservEntry.SetItemData("No.", Description, "Location Code", "Variant Code", "Qty. per Unit of Measure");
        if Type <> Type::Item then
            ReservEntry."Item No." := '';
        ReservEntry."Expected Receipt Date" := "Shipment Date";
        ReservEntry."Shipment Date" := "Shipment Date";
    end;

    procedure SetReservationFilters(var ReservEntry: Record "Reservation Entry")
    begin
        ReservEntry.SetSourceFilter(DATABASE::"Sales Line", "Document Type".AsInteger(), "Document No.", "Line No.", false);
        ReservEntry.SetSourceFilter('', 0);

        OnAfterSetReservationFilters(ReservEntry, Rec);
    end;

    procedure ReservEntryExist(): Boolean
    var
        ReservEntry: Record "Reservation Entry";
    begin
        ReservEntry.InitSortingAndFilters(false);
        SetReservationFilters(ReservEntry);
        exit(not ReservEntry.IsEmpty);
    end;

    procedure IsPriceCalcCalledByField(CurrPriceFieldNo: Integer): Boolean;
    begin
        exit(FieldCausedPriceCalculation = CurrPriceFieldNo);
    end;

    procedure PlanPriceCalcByField(CurrPriceFieldNo: Integer)
    begin
        if FieldCausedPriceCalculation = 0 then
            FieldCausedPriceCalculation := CurrPriceFieldNo;
    end;

    procedure ClearFieldCausedPriceCalculation()
    begin
        FieldCausedPriceCalculation := 0;
    end;

    local procedure UpdateQuantityFromUOMCode()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateQuantityFromUOMCode(Rec, IsHandled);
        if IsHandled then
            exit;

        Validate(Quantity);
    end;

    procedure UpdateUnitPrice(CalledByFieldNo: Integer)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateUnitPriceProcedure(Rec, CalledByFieldNo, IsHandled);
        if IsHandled then
            exit;

        ClearFieldCausedPriceCalculation();
        PlanPriceCalcByField(CalledByFieldNo);
        UpdateUnitPriceByField(CalledByFieldNo);
    end;

    local procedure UpdateUnitPriceByField(CalledByFieldNo: Integer)
    var
        IsHandled: Boolean;
        PriceCalculation: Interface "Price Calculation";
        FoodManualSubscriptions: Codeunit "Food Manual Subscriptions";
    begin
        if (CalledByFieldNo <> CurrFieldNo) and (CurrFieldNo <> 0) then
            exit;
        // P8000885 
        if DoNotUpdatePrice then begin
            ClearFieldCausedPriceCalculation();
            exit;
        end;
        // P8000885 

        IsHandled := false;
        OnBeforeUpdateUnitPrice(Rec, xRec, CalledByFieldNo, CurrFieldNo, IsHandled);
        if IsHandled then
            exit;

        GetSalesHeader();
        TestField("Qty. per Unit of Measure");

        "Unit Price" := "Unit Price" - "Unit Price (Freight)"; // P8000921
        BindSubscription(FoodManualSubscriptions);

        case Type of
            Type::"G/L Account",
            Type::Item,
            Type::Resource:
                begin
                    IsHandled := false;
                    OnUpdateUnitPriceOnBeforeFindPrice(SalesHeader, Rec, CalledByFieldNo, CurrFieldNo, IsHandled);
                    if not IsHandled then begin
                        FoodManualSubscriptions.SetShortSubstituteItem(IsShortSubstituteItem);
                        GetPriceCalculationHandler(PriceType::Sale, SalesHeader, PriceCalculation);
                        if not ("Copied From Posted Doc." and IsCreditDocType) then begin
                            ApplyPrice(CalledByFieldNo, PriceCalculation);
                            // PR3.70
                            if (Type = Type::Item) and SalesHeader."Contract Items Only" and (not FoodManualSubscriptions.GetContractItem()) then
                                Error(Text37002005);
                            // PR3.70
                            // P8001178
                            if not "Allow Line Disc." then begin
                                "Line Discount Type" := "Line Discount Type"::Percent;
                                Validate("Line Discount %", 0);
                            end else
                                // P8001178
                                ApplyDiscount(PriceCalculation);
                        end;
                    end;
                    OnUpdateUnitPriceByFieldOnAfterFindPrice(SalesHeader, Rec, CalledByFieldNo, CurrFieldNo);
                end;
            // PR3.61 Begin
            Type::FOODContainer:
                begin
                    GetContainerType; // P8001290
                    if ContainerType."Container Sales Processing" = ContainerType."Container Sales Processing"::Sale then begin // P8001290
                        GetPriceCalculationHandler(PriceType::Sale, SalesHeader, PriceCalculation);
                        if CalledByFieldNo <> 0 then // P80083775
                            ApplyPrice(CalledByFieldNo, PriceCalculation);
                        // P8001178
                        if not "Allow Line Disc." then begin
                            "Line Discount Type" := "Line Discount Type"::Percent;
                            Validate("Line Discount %", 0);
                        end else
                            // P8001178
                            if CalledByFieldNo <> 0 then // P80083775
                                ApplyDiscount(PriceCalculation);
                    end else
                        "Unit Price" := 0;
                end;
        // PR3.61 End
        end;

        ShowUnitPriceChangedMsg();

        Validate("Unit Price");

        ClearFieldCausedPriceCalculation();
        OnAfterUpdateUnitPrice(Rec, xRec, CalledByFieldNo, CurrFieldNo);
    end;

    local procedure ShowUnitPriceChangedMsg()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeShowUnitPriceChangedMsg(Rec, xRec, IsHandled);
        if IsHandled then
            exit;
        if "Copied From Posted Doc." and IsCreditDocType() and ("Appl.-from Item Entry" <> 0) then
            if xRec."Unit Price" <> "Unit Price" then
                if GuiAllowed then
                    ShowMessageOnce(StrSubstNo(UnitPriceChangedMsg, Type, "No."));
    end;

    local procedure GetLineWithCalculatedPrice(var PriceCalculation: Interface "Price Calculation")
    var
        Line: Variant;
    begin
        PriceCalculation.GetLine(Line);
        Rec := Line;
    end;

    procedure GetPriceCalculationHandler(PriceType: Enum "Price Type"; SalesHeader: Record "Sales Header"; var PriceCalculation: Interface "Price Calculation")
    var
        PriceCalculationMgt: codeunit "Price Calculation Mgt.";
        LineWithPrice: Interface "Line With Price";
    begin
        if (SalesHeader."No." = '') and ("Document No." <> '') then
            SalesHeader.Get("Document Type", "Document No.");
        GetLineWithPrice(LineWithPrice);
        LineWithPrice.SetLine(PriceType, SalesHeader, Rec);
        PriceCalculationMgt.GetHandler(LineWithPrice, PriceCalculation);
    end;

    procedure GetLineWithPrice(var LineWithPrice: Interface "Line With Price")
    var
        SalesLinePrice: Codeunit "Sales Line - Price";
    begin
        LineWithPrice := SalesLinePrice;
        OnAfterGetLineWithPrice(LineWithPrice);
    end;

    procedure ApplyDiscount(var PriceCalculation: Interface "Price Calculation")
    begin
        PriceCalculation.ApplyDiscount();
        GetLineWithCalculatedPrice(PriceCalculation);
    end;

    procedure ApplyPrice(CalledByFieldNo: Integer; var PriceCalculation: Interface "Price Calculation")
    begin
        PriceCalculation.ApplyPrice(CalledByFieldNo);
        GetLineWithCalculatedPrice(PriceCalculation);
        OnAfterApplyPrice(Rec, xRec, CalledByFieldNo, CurrFieldNo);
    end;

    local procedure ApplyResUnitCost(CalledByFieldNo: Integer)
    var
        PriceCalculation: Interface "Price Calculation";
    begin
        GetPriceCalculationHandler(PriceType::Purchase, SalesHeader, PriceCalculation);
        PriceCalculation.ApplyPrice(CalledByFieldNo);
        GetLineWithCalculatedPrice(PriceCalculation);
        Validate("Unit Cost (LCY)");
    end;

    procedure CountDiscount(ShowAll: Boolean): Integer;
    var
        PriceCalculation: Interface "Price Calculation";
    begin
        GetPriceCalculationHandler(PriceType::Sale, SalesHeader, PriceCalculation);
        exit(PriceCalculation.CountDiscount(ShowAll));
    end;

    procedure CountPrice(ShowAll: Boolean): Integer;
    var
        PriceCalculation: Interface "Price Calculation";
    begin
        GetPriceCalculationHandler(PriceType::Sale, SalesHeader, PriceCalculation);
        exit(PriceCalculation.CountPrice(ShowAll));
    end;

    procedure DiscountExists(ShowAll: Boolean): Boolean;
    var
        PriceCalculation: Interface "Price Calculation";
    begin
        GetPriceCalculationHandler(PriceType::Sale, SalesHeader, PriceCalculation);
        exit(PriceCalculation.IsDiscountExists(ShowAll));
    end;

    procedure PriceExists(ShowAll: Boolean): Boolean;
    var
        PriceCalculation: Interface "Price Calculation";
    begin
        GetPriceCalculationHandler(PriceType::Sale, SalesHeader, PriceCalculation);
        exit(PriceCalculation.IsPriceExists(ShowAll));
    end;

    procedure PickDiscount()
    var
        PriceCalculation: Interface "Price Calculation";
    begin
        GetPriceCalculationHandler(PriceType::Sale, SalesHeader, PriceCalculation);
        PriceCalculation.PickDiscount();
        GetLineWithCalculatedPrice(PriceCalculation);
    end;

    procedure PickPrice()
    var
        PriceCalculation: Interface "Price Calculation";
    begin
        GetPriceCalculationHandler(PriceType::Sale, SalesHeader, PriceCalculation);
        PriceCalculation.PickPrice();
        GetLineWithCalculatedPrice(PriceCalculation);

        OnAfterPickPrice(Rec, PriceCalculation);
    end;

    procedure UpdateReferencePriceAndDiscount();
    var
        PriceCalculation: Interface "Price Calculation";
    begin
        GetPriceCalculationHandler(PriceType::Sale, SalesHeader, PriceCalculation);
        PriceCalculation.ApplyDiscount();
        ApplyPrice(FieldNo("Item Reference No."), PriceCalculation);
    end;

    local procedure ShowMessageOnce(MessageText: Text)
    begin
        TempErrorMessage.SetContext(Rec);
        if TempErrorMessage.FindRecord(RecordId, 0, TempErrorMessage."Message Type"::Warning, MessageText) = 0 then begin
            TempErrorMessage.LogMessage(Rec, 0, TempErrorMessage."Message Type"::Warning, MessageText);
            Message(MessageText);
        end;
    end;

#if not CLEAN19
    [Obsolete('Replaced by the new implementation (V16) of price calculation.', '16.0')]
    procedure FindResUnitCost()
    var
        ResCost: Record "Resource Cost";
    begin
        ResCost.Init();
        OnFindResUnitCostOnAfterInitResCost(Rec, ResCost);
        ResCost.Code := "No.";
        ResCost."Work Type Code" := "Work Type Code";
        CODEUNIT.Run(CODEUNIT::"Resource-Find Cost", ResCost);
        OnAfterFindResUnitCost(Rec, ResCost);
        Validate("Unit Cost (LCY)", ResCost."Unit Cost" * "Qty. per Unit of Measure");
    end;

    [Obsolete('Replaced by the new implementation (V16) of price calculation.', '17.0')]
    procedure FindResUnitCostOnAfterInitResCost(var ResourceCost: Record "Resource Cost")
    begin
        OnFindResUnitCostOnAfterInitResCost(Rec, ResourceCost);
    end;

    [Obsolete('Replaced by the new implementation (V16) of price calculation.', '17.0')]
    procedure AfterFindResUnitCost(var ResourceCost: Record "Resource Cost")
    begin
        OnAfterFindResUnitCost(Rec, ResourceCost);
    end;
#endif
    procedure UpdatePrepmtSetupFields()
    var
        GenPostingSetup: Record "General Posting Setup";
        GLAcc: Record "G/L Account";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdatePrepmtSetupFields(Rec, IsHandled, CurrFieldNo);
        if IsHandled then
            exit;

        if ("Prepmt. Amt. Inv." <> 0) and ("Prepayment %" <> xRec."Prepayment %") then
            FieldError("Prepayment %", StrSubstNo(Text1020001, xRec."Prepayment %"));

        if ("Prepayment %" <> 0) and (Type <> Type::" ") then begin
            TestField("Document Type", "Document Type"::Order);
            TestField("No.");
            if CurrFieldNo = FieldNo("Prepayment %") then
                if "System-Created Entry" and not IsServiceChargeLine() then
                    FieldError("Prepmt. Line Amount", StrSubstNo(Text045, 0));
            if "System-Created Entry" and not IsServiceChargeLine() then
                "Prepayment %" := 0;
            GenPostingSetup.Get("Gen. Bus. Posting Group", "Gen. Prod. Posting Group");
            if GenPostingSetup."Sales Prepayments Account" <> '' then begin
                GLAcc.Get(GenPostingSetup."Sales Prepayments Account");
                VATPostingSetup.Get("VAT Bus. Posting Group", GLAcc."VAT Prod. Posting Group");
                VATPostingSetup.TestField("VAT Calculation Type", "VAT Calculation Type");
            end else
                Clear(VATPostingSetup);
            if ("Prepayment VAT %" <> 0) and ("Prepayment VAT %" <> VATPostingSetup."VAT %") and ("Prepmt. Amt. Inv." <> 0) then
                Error(CannotChangePrepmtAmtDiffVAtPctErr);
            "Prepayment VAT %" := VATPostingSetup."VAT %";
            "Prepmt. VAT Calc. Type" := VATPostingSetup."VAT Calculation Type";
            "Prepayment VAT Identifier" := VATPostingSetup."VAT Identifier";
            if "Prepmt. VAT Calc. Type" in
               ["Prepmt. VAT Calc. Type"::"Reverse Charge VAT", "Prepmt. VAT Calc. Type"::"Sales Tax"]
            then
                "Prepayment VAT %" := 0;
            "Prepayment Tax Group Code" := GLAcc."Tax Group Code";
        end;
    end;

    protected procedure UpdatePrepmtAmounts()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdatePrepmtAmounts(Rec, SalesHeader, IsHandled, xRec, CurrFieldNo);
        if IsHandled then
            exit;

        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Invoice then begin
            "Prepayment VAT Difference" := 0;
            if not PrePaymentLineAmountEntered then begin
                "Prepmt. Line Amount" := Round("Line Amount" * "Prepayment %" / 100, Currency."Amount Rounding Precision");
                if abs("Inv. Discount Amount" + "Prepmt. Line Amount") > abs(LineAmtExclAltQtys()) then
                    "Prepmt. Line Amount" := LineAmtExclAltQtys() - "Inv. Discount Amount";
            end;
            PrePaymentLineAmountEntered := false;
        end;

        if not IsTemporary() then
            CheckPrepmtAmounts();
    end;

    local procedure CheckPrepmtAmounts()
    var
        RemLineAmountToInvoice: Decimal;
    begin
        if "Prepayment %" <> 0 then begin
            if Quantity < 0 then
                FieldError(Quantity, StrSubstNo(Text047, FieldCaption("Prepayment %")));
            if "Unit Price" < 0 then
                FieldError("Unit Price", StrSubstNo(Text047, FieldCaption("Prepayment %")));
        end;
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Invoice then begin
            if ("Prepmt. Line Amount" < "Prepmt. Amt. Inv.") and (SalesHeader.Status <> SalesHeader.Status::Released) then begin
                if IsServiceChargeLine() then
                    Error(CannotChangePrepaidServiceChargeErr);
                if "Inv. Discount Amount" <> 0 then
                    Error(InvDiscForPrepmtExceededErr, "Document No.");
                FieldError("Prepmt. Line Amount", StrSubstNo(Text049, "Prepmt. Amt. Inv."));
            end;
            if "Prepmt. Line Amount" <> 0 then begin
	    	// LineAmtExclAltQtys()
                RemLineAmountToInvoice := GetLineAmountToHandleInclPrepmt(Quantity - "Quantity Invoiced");
                if RemLineAmountToInvoice < ("Prepmt. Line Amount" - "Prepmt Amt Deducted") then
                    FieldError("Prepmt. Line Amount", StrSubstNo(Text045, RemLineAmountToInvoice + "Prepmt Amt Deducted"));
            end;
        end else
            if (CurrFieldNo <> 0) and ("Line Amount" <> xRec."Line Amount") and
               ("Prepmt. Amt. Inv." <> 0) and ("Prepayment %" = 100)
            then begin
                if "Line Amount" < xRec."Line Amount" then
                    FieldError("Line Amount", StrSubstNo(Text044, xRec."Line Amount"));
                FieldError("Line Amount", StrSubstNo(Text045, xRec."Line Amount"));
            end;
    end;

    local procedure CheckPrepmtAmtInvEmpty()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckPrepmtAmtInvEmpty(Rec, IsHandled);
        if IsHandled then
            exit;

        if "Prepmt. Amt. Inv." <> 0 then
            Error(CannotChangeVATGroupWithPrepmInvErr);
    end;

    local procedure CheckLinkedBlanketOrderLineOnDelete()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckLinkedBlanketOrderLineOnDelete(Rec, IsHandled);
        if IsHandled then
            exit;

        if "Document Type" = "Document Type"::"Blanket Order" then begin
            SalesLine2.Reset();
            SalesLine2.SetCurrentKey("Document Type", "Blanket Order No.", "Blanket Order Line No.");
            SalesLine2.SetRange("Blanket Order No.", "Document No.");
            SalesLine2.SetRange("Blanket Order Line No.", "Line No.");
            if SalesLine2.FindFirst() then
                SalesLine2.TestField("Blanket Order Line No.", 0);
        end;
    end;

    procedure UpdateAmounts()
    var
        SalesCrMemoHdr: Record "Sales Cr.Memo Header";
        VATBaseAmount: Decimal;
        LineAmount: Decimal;
        LineAmountChanged: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateAmounts(Rec, xRec, CurrFieldNo, IsHandled);
        if IsHandled then
            exit;

        if Type = Type::" " then
            exit;

        GetSalesHeader();
        VATBaseAmount := "Amount Including VAT";
        "Recalculate Invoice Disc." := true;

        IsHandled := false;
        OnUpdateAmountsOnBeforeCheckLineAmount(IsHandled, Rec);
        if not IsHandled then
            if "Line Amount" <> xRec."Line Amount" then begin
                "VAT Difference" := 0;
                LineAmountChanged := true;
            end;

        LineAmount := Round(GetPricingQty * "Unit Price", Currency."Amount Rounding Precision") - "Line Discount Amount"; // PR3.70
        OnUpdateAmountsOnAfterCalcLineAmount(Rec, LineAmount);
        if "Line Amount" <> LineAmount then begin
            "Line Amount" := LineAmount;
            "VAT Difference" := 0;
            LineAmountChanged := true;
        end;
        if (CurrFieldNo <> 0) and (SalesHeader.Status = SalesHeader.Status::Released) then
            Error(Text1020000);
        if (("Tax Group Code" = '') and (xRec."Tax Group Code" <> ''))
           or (("Tax Area Code" = '') and (xRec."Tax Area Code" <> '')) then begin
            Amount := 0;
            "Amount Including VAT" := 0;
        end;

        if not "Prepayment Line" then
            UpdatePrepmtAmounts();

        OnAfterUpdateAmounts(Rec, xRec, CurrFieldNo);

        UpdateVATAmounts();
        InitOutstandingAmount();
        CheckCreditLimit();

        if Type = Type::"Charge (Item)" then
            UpdateItemChargeAssgnt();

        if Quantity < xRec.Quantity then begin
            SalesCrMemoHdr.SetCurrentKey("Prepayment Order No.");
            SalesCrMemoHdr.SetRange("Prepayment Order No.", "Document No.");
            if SalesCrMemoHdr.FindFirst() then begin
                SalesCrMemoHdr.CalcFields(Amount);
                if ("Prepmt. Amt. Inv." <> 0) and ("Prepayment %" <> 0) then
                    if "Line Amount" <> xRec."Line Amount" - SalesCrMemoHdr.Amount * 100 / "Prepayment %" then
                        FieldError("Line Amount", StrSubstNo(Text1020001, xRec."Line Amount"));
            end;
        end;
        CalcPrepaymentToDeduct();

        /*P8000079A Begin
        IF TrackAlternateUnits THEN               // PR3.60
          AltQtyMgmt.SetSalesLineShipAmount(Rec); // PR3.60
        P8000079AEnd*/
        // P8000079A Begin
        if (Type = Type::Item) and ("No." <> '') and ("Qty. to Ship" <> 0) then
            if "Outstanding Quantity" <> 0 then
                "Amount to Ship (LCY)" := Round("Outstanding Amount (LCY)" * ("Qty. to Ship" / "Outstanding Quantity"))
            else
                "Amount to Ship (LCY)" := 0
        else
            "Amount to Ship (LCY)" := 0;
        // P8000079A End
        if VATBaseAmount <> "Amount Including VAT" then
            LineAmountChanged := true;

        if LineAmountChanged then begin
            UpdateDeferralAmounts;
            LineAmountChanged := false;
        end;

        OnAfterUpdateAmountsDone(Rec, xRec, CurrFieldNo);

    end;

    procedure UpdateVATAmounts()
    var
        SalesLine2: Record "Sales Line";
        TotalLineAmount: Decimal;
        TotalInvDiscAmount: Decimal;
        TotalAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        TotalVATDifference: Decimal;
        TotalQuantityBase: Decimal;
        TotalVATBaseAmount: Decimal;
        IsHandled: Boolean;
    begin
        OnBeforeUpdateVATAmounts(Rec);

        GetSalesHeader();
        SalesLine2.SetRange("Document Type", "Document Type");
        SalesLine2.SetRange("Document No.", "Document No.");
        SalesLine2.SetFilter("Line No.", '<>%1', "Line No.");
        SalesLine2.SetRange("VAT Identifier", "VAT Identifier");
        SalesLine2.SetRange("Tax Group Code", "Tax Group Code");
        SalesLine2.SetRange("Tax Area Code", "Tax Area Code");

        IsHandled := false;
        OnUpdateVATAmountsOnAfterSetSalesLineFilters(Rec, SalesLine2, IsHandled);
        if IsHandled then
            exit;

        if ("Line Amount" = "Inv. Discount Amount") and not
            SalesTaxCalculate.HasExciseTax("Tax Area Code", "Tax Group Code", "Tax Liable", Quantity, SalesHeader."Document Date") then begin
            Amount := 0;
            "VAT Base Amount" := 0;
            "Amount Including VAT" := 0;
            if (Quantity = 0) and (xRec.Quantity <> 0) and (xRec.Amount <> 0) then begin
                if "Line No." <> 0 then
                    Modify;
                SalesLine2.SetFilter(Amount, '<>0');
                if SalesLine2.Find('<>') then begin
                    OnUpdateVATAmountsOnBeforeValidateLineDiscountPercent(SalesLine2, StatusCheckSuspended);
                    SalesLine2.ValidateLineDiscountPercent(false);
                    SalesLine2.Modify();
                end;
            end;
        end else begin
            TotalLineAmount := 0;
            TotalInvDiscAmount := 0;
            TotalAmount := 0;
            TotalAmountInclVAT := 0;
            TotalQuantityBase := 0;
            TotalVATBaseAmount := 0;
            if ("VAT Calculation Type" = "VAT Calculation Type"::"Sales Tax") or
               (("VAT Calculation Type" in
                 ["VAT Calculation Type"::"Normal VAT", "VAT Calculation Type"::"Reverse Charge VAT"]) and ("VAT %" <> 0))
            then begin
                SalesLine2.SetFilter("VAT %", '<>0');
                if not SalesLine2.IsEmpty() then begin
                    SalesLine2.CalcSums("Line Amount", "Inv. Discount Amount", Amount, "Amount Including VAT", "Quantity (Base)", "Quantity (Alt.)", "VAT Base Amount"); // P8001386
                    TotalLineAmount := SalesLine2."Line Amount";
                    TotalInvDiscAmount := SalesLine2."Inv. Discount Amount";
                    TotalAmount := SalesLine2.Amount;
                    TotalAmountInclVAT := SalesLine2."Amount Including VAT";
                    TotalVATDifference := SalesLine2."VAT Difference";
                    TotalQuantityBase := SalesLine2.GetPricingQuantity(FieldNo(Quantity), 'BASE'); // P8001366, P8001386
                    TotalVATBaseAmount := SalesLine2."VAT Base Amount";
                    OnAfterUpdateTotalAmounts(Rec, SalesLine2, TotalAmount, TotalAmountInclVAT, TotalLineAmount, TotalInvDiscAmount);
                end;
            end;

            OnUpdateVATAmountsOnBeforeCalcAmounts(
                Rec, SalesLine2, TotalAmount, TotalAmountInclVAT, TotalLineAmount, TotalInvDiscAmount, TotalVATBaseAmount, TotalQuantityBase, IsHandled);
            if IsHandled then
                exit;

            if SalesHeader."Prices Including VAT" then
                case "VAT Calculation Type" of
                    "VAT Calculation Type"::"Normal VAT",
                    "VAT Calculation Type"::"Reverse Charge VAT":
                        begin
                            Amount :=
                              Round(
                                (TotalLineAmount - TotalInvDiscAmount + CalcLineAmount) / (1 + "VAT %" / 100),
                                Currency."Amount Rounding Precision") -
                              TotalAmount;
                            "VAT Base Amount" :=
                              Round(
                                Amount * (1 - SalesHeader."VAT Base Discount %" / 100),
                                Currency."Amount Rounding Precision");
                            "Amount Including VAT" :=
                              TotalLineAmount + "Line Amount" -
                              Round(
                                (TotalAmount + Amount) * (SalesHeader."VAT Base Discount %" / 100) * "VAT %" / 100,
                                Currency."Amount Rounding Precision", Currency.VATRoundingDirection) -
                              TotalAmountInclVAT - TotalInvDiscAmount - "Inv. Discount Amount";
                        end;
                    "VAT Calculation Type"::"Full VAT":
                        begin
                            Amount := 0;
                            "VAT Base Amount" := 0;
                            "Amount Including VAT" := ROUND(CalcLineAmount(), Currency."Amount Rounding Precision");
                        end;
                    "VAT Calculation Type"::"Sales Tax":
                        begin
                            SalesHeader.TestField("VAT Base Discount %", 0);
                            Amount :=
                              SalesTaxCalculate.ReverseCalculateTax(
                                "Tax Area Code", "Tax Group Code", "Tax Liable", SalesHeader."Posting Date",
                                TotalAmountInclVAT + "Amount Including VAT", TotalQuantityBase + GetPricingQuantity(FieldNo(Quantity), 'BASE'), // P8001366
                                SalesHeader."Currency Factor") -
                              TotalAmount;
                            OnAfterSalesTaxCalculateReverse(Rec, SalesHeader, Currency);
                            UpdateVATPercent(Amount, "Amount Including VAT" - Amount);
                            Amount := Round(Amount, Currency."Amount Rounding Precision");
                            "VAT Base Amount" := Amount;
                        end;
                end
            else
                case "VAT Calculation Type" of
                    "VAT Calculation Type"::"Normal VAT",
                    "VAT Calculation Type"::"Reverse Charge VAT":
                        begin
                            Amount := Round(CalcLineAmount, Currency."Amount Rounding Precision");
                            "VAT Base Amount" :=
                              Round(Amount * (1 - SalesHeader."VAT Base Discount %" / 100), Currency."Amount Rounding Precision");
                            "Amount Including VAT" :=
                              TotalAmount + Amount +
                              Round(
                                (TotalAmount + Amount) * (1 - SalesHeader."VAT Base Discount %" / 100) * "VAT %" / 100,
                                Currency."Amount Rounding Precision", Currency.VATRoundingDirection) -
                              TotalAmountInclVAT + TotalVATDifference;
                        end;
                    "VAT Calculation Type"::"Full VAT":
                        begin
                            Amount := 0;
                            "VAT Base Amount" := 0;
                            "Amount Including VAT" := CalcLineAmount;
                        end;
                    "VAT Calculation Type"::"Sales Tax":
                        begin
                            Amount := Round(CalcLineAmount, Currency."Amount Rounding Precision");
                            "VAT Base Amount" := Amount;
                            "Amount Including VAT" :=
                              TotalAmount + Amount +
                              Round(
                                SalesTaxCalculate.CalculateTax(
                                  "Tax Area Code", "Tax Group Code", "Tax Liable", SalesHeader."Posting Date",
                                  TotalAmount + Amount, TotalQuantityBase + GetPricingQuantity(FieldNo(Quantity), 'BASE'), // P8001366
                                  SalesHeader."Currency Factor"), Currency."Amount Rounding Precision") -
                              TotalAmountInclVAT;
                            "Amount Including VAT" += SalesTaxCalculate.CalculateExpenseTax(
                                "Tax Area Code", "Tax Group Code", "Tax Liable", SalesHeader."Posting Date",
                                TotalAmount + Amount, "Quantity (Base)", SalesHeader."Currency Factor");
                            OnAfterSalesTaxCalculate(Rec, SalesHeader, Currency);
                            UpdateVATPercent("VAT Base Amount", "Amount Including VAT" - "VAT Base Amount");
                        end;
                end;
        end;

        OnAfterUpdateVATAmounts(Rec);
    end;

    local procedure InitQty()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitQty(Rec, xRec, IsAsmToOrderAllowed(), IsAsmToOrderRequired(), IsHandled);
        if IsHandled then
            exit;

        if (xRec.Quantity <> Quantity) or (xRec."Quantity (Base)" <> "Quantity (Base)") then begin
            InitOutstanding();
            if IsCreditDocType() then
                InitQtyToReceive()
            else
                InitQtyToShip();
            InitQtyToAsm();
            SetDefaultQuantity();
        end;
    end;

    procedure CheckItemAvailable(CalledByFieldNo: Integer)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckItemAvailable(Rec, CalledByFieldNo, IsHandled, CurrFieldNo, xRec);
        if IsHandled then
            exit;

        if "Shipment Date" = 0D then begin
            GetSalesHeader();
            if SalesHeader."Shipment Date" <> 0D then
                Validate("Shipment Date", SalesHeader."Shipment Date")
            else
                Validate("Shipment Date", WorkDate);
        end;

        if ((CalledByFieldNo = CurrFieldNo) or (CalledByFieldNo = FieldNo("Shipment Date"))) and GuiAllowed and
           ("Document Type" in ["Document Type"::Order, "Document Type"::Invoice]) and
           (Type = Type::Item) and ("No." <> '') and
           ("Outstanding Quantity" > 0) and
           ("Job Contract Entry No." = 0) and
           not "Special Order"
        then begin
            if ItemCheckAvail.SalesLineCheck(Rec) then
                ItemCheckAvail.RaiseUpdateInterruptedError;
        end;

        OnAfterCheckItemAvailable(Rec, CalledByFieldNo, HideValidationDialog);
    end;

    local procedure CheckCreditLimit()
    var
        IsHandled: Boolean;
    begin
        if (CurrFieldNo <> 0) and
           (not CreditCheckSuspended) and // P8000399A
           not ((Type = Type::Item) and (CurrFieldNo = FieldNo("No.")) and (Quantity <> 0) and
                ("Qty. per Unit of Measure" <> xRec."Qty. per Unit of Measure")) and
           CheckCreditLimitCondition and
           (("Outstanding Amount" + "Shipped Not Invoiced") > 0) and
           (CurrFieldNo <> FieldNo("Blanket Order No.")) and
           (CurrFieldNo <> FieldNo("Blanket Order Line No."))
        then begin
            IsHandled := false;
            OnUpdateAmountOnBeforeCheckCreditLimit(Rec, IsHandled, CurrFieldNo);
            if not IsHandled then
                CustCheckCreditLimit.SalesLineCheck(Rec);
        end;
    end;

    local procedure CheckBinCodeRelation()
    var
        WMSManagement: Codeunit "WMS Management";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckBinCodeRelation(Rec, IsHandled);
        if IsHandled then
            exit;

        if not IsInbound() and ("Quantity (Base)" <> 0) and ("Qty. to Asm. to Order (Base)" = 0) then
            WMSManagement.FindBinContent("Location Code", "Bin Code", "No.", "Variant Code", '')
        else
            WMSManagement.FindBin("Location Code", "Bin Code", '');
    end;

    local procedure CheckCreditLimitCondition(): Boolean
    var
        RunCheck: Boolean;
    begin
        RunCheck := "Document Type".AsInteger() <= "Document Type"::Invoice.AsInteger();
        OnAfterCheckCreditLimitCondition(Rec, RunCheck);
        exit(RunCheck);
    end;

    procedure ShowReservation()
    var
        Reservation: Page Reservation;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeShowReservation(Rec, IsHandled);
        if IsHandled then
            exit;

        TestField(Type, Type::Item);
        TestField("No.");
        TestField(Reserve);
        Clear(Reservation);
        Reservation.SetReservSource(Rec);
        Reservation.RunModal();
        UpdatePlanned();
    end;

    procedure ShowReservationEntries(Modal: Boolean)
    var
        ReservEntry: Record "Reservation Entry";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeShowReservationEntries(Rec, IsHandled);
        if IsHandled then
            exit;

        TestField(Type, Type::Item);
        TestField("No.");
        ReservEntry.InitSortingAndFilters(true);
        SetReservationFilters(ReservEntry);
        if Modal then
            PAGE.RunModal(PAGE::"Reservation Entries", ReservEntry)
        else
            PAGE.Run(PAGE::"Reservation Entries", ReservEntry);
    end;

    procedure AutoReserve()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        Item: Record Item;
        ReservMgt: Codeunit "Reservation Management";
        ConfirmManagement: Codeunit "Confirm Management";
        QtyToReserve: Decimal;
        QtyToReserveBase: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeAutoReserve(Rec, IsHandled, xRec, FullAutoReservation, SalesLineReserve);
        if IsHandled then
            exit;

        TestField(Type, Type::Item);
        TestField("No.");
        GetItem(Item);
        if (Item.Type = Item.Type::"Non-Inventory") and (Reserve = Reserve::Never) then
            Error(NonInvReserveTypeErr, Item."No.", Reserve);

        SalesLineReserve.ReservQuantity(Rec, QtyToReserve, QtyToReserveBase);
        if QtyToReserveBase <> 0 then begin
            TestField("Shipment Date");
            ReservMgt.SetReservSource(Rec);
            ReservMgt.AutoReserve(FullAutoReservation, '', "Shipment Date", QtyToReserve, QtyToReserveBase);
            CalcFields("Reserved Quantity");
            Find();
            SalesSetup.Get();
            if (not FullAutoReservation) and (not SalesSetup."Skip Manual Reservation") then begin
                Commit();
                if ConfirmManagement.GetResponse(ManualReserveQst, true) then begin
                    ShowReservation();
                    Find();
                end;
            end;
        end;

        OnAfterAutoReserve(Rec);
    end;

    procedure AutoAsmToOrder()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeAutoAsmToOrder(Rec, IsHandled);
        if IsHandled then
            exit;

        ATOLink.UpdateAsmFromSalesLine(Rec);

        OnAfterAutoAsmToOrder(Rec);
    end;

    procedure GetDate(): Date
    begin
        GetSalesHeader();
        if SalesHeader."Posting Date" <> 0D then
            exit(SalesHeader."Posting Date");
        exit(WorkDate);
    end;

    procedure CalcPlannedDeliveryDate(CurrFieldNo: Integer) PlannedDeliveryDate: Date
    var
        CustomCalendarChange: Array[2] of Record "Customized Calendar Change";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        PlannedDeliveryDate := "Planned Delivery Date";
        OnBeforeCalcPlannedDeliveryDate(Rec, PlannedDeliveryDate, CurrFieldNo, IsHandled);
        if IsHandled then
            exit(PlannedDeliveryDate);

        if CurrFieldNo = FieldNo("Requested Delivery Date") then
            exit("Requested Delivery Date");

        if "Shipment Date" = 0D then
            exit("Planned Delivery Date");

        CustomCalendarChange[1].SetSource(CalChange."Source Type"::"Shipping Agent", "Shipping Agent Code", "Shipping Agent Service Code", '');
        case CurrFieldNo of
            FieldNo("Shipment Date"):
                begin
                    CustomCalendarChange[2].SetSource(CalChange."Source Type"::Customer, "Sell-to Customer No.", '', '');
                    exit(CalendarMgmt.CalcDateBOC(Format("Shipping Time"), "Planned Shipment Date", CustomCalendarChange, true));
                end;
            FieldNo("Planned Delivery Date"):
                begin
                    CustomCalendarChange[2].SetSource(CalChange."Source Type"::Location, "Location Code", '', '');
                    exit(CalendarMgmt.CalcDateBOC2(Format("Shipping Time"), "Planned Delivery Date", CustomCalendarChange, true));
                end;
        end;
    end;

    procedure CalcPlannedShptDate(CurrFieldNo: Integer) PlannedShipmentDate: Date
    var
        CustomCalendarChange: Array[2] of Record "Customized Calendar Change";
        IsHandled: Boolean;
    begin
        OnBeforeCalcPlannedShptDate(Rec, PlannedShipmentDate, CurrFieldNo, IsHandled);
        if IsHandled then
            exit(PlannedShipmentDate);

        if "Shipment Date" = 0D then
            exit("Planned Shipment Date");

        CustomCalendarChange[2].SetSource(CalChange."Source Type"::"Shipping Agent", "Shipping Agent Code", "Shipping Agent Service Code", '');
        case CurrFieldNo of
            FieldNo("Shipment Date"):
                begin
                    CustomCalendarChange[1].SetSource(CalChange."Source Type"::Location, "Location Code", '', '');
                    exit(CalendarMgmt.CalcDateBOC(Format("Outbound Whse. Handling Time"), "Shipment Date", CustomCalendarChange, true));
                end;
            FieldNo("Planned Delivery Date"):
                begin
                    CustomCalendarChange[1].SetSource(CalChange."Source Type"::Customer, "Sell-to Customer No.", '', '');
                    exit(CalendarMgmt.CalcDateBOC(Format(''), "Planned Delivery Date", CustomCalendarChange, true));
                end;
        end;
    end;

    procedure CalcShipmentDate(): Date
    var
        CustomCalendarChange: Array[2] of Record "Customized Calendar Change";
        ShipmentDate: Date;
        IsHandled: Boolean;
    begin
        if "Planned Shipment Date" = 0D then
            exit("Shipment Date");

        IsHandled := false;
        OnCalcShipmentDateOnPlannedShipmentDate(Rec, ShipmentDate, IsHandled);
        if IsHandled then
            exit(ShipmentDate);

        if Format("Outbound Whse. Handling Time") <> '' then begin
            CustomCalendarChange[1].SetSource(CalChange."Source Type"::Location, "Location Code", '', '');
            CustomCalendarChange[2].SetSource(CalChange."Source Type"::"Shipping Agent", "Shipping Agent Code", "Shipping Agent Service Code", '');
            exit(CalendarMgmt.CalcDateBOC2(Format("Outbound Whse. Handling Time"), "Planned Shipment Date", CustomCalendarChange, false));
        end;

        CustomCalendarChange[1].SetSource(CalChange."Source Type"::"Shipping Agent", "Shipping Agent Code", "Shipping Agent Service Code", '');
        CustomCalendarChange[2].SetSource(CalChange."Source Type"::Location, "Location Code", '', '');
        exit(CalendarMgmt.CalcDateBOC(Format(Format('')), "Planned Shipment Date", CustomCalendarChange, false));
    end;

    procedure SignedXX(Value: Decimal): Decimal
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSignedXX(Rec, Value, IsHandled);
        if IsHandled then
            exit(Value);

        case "Document Type" of
            "Document Type"::Quote,
          "Document Type"::Order,
          "Document Type"::Invoice,
          "Document Type"::"Blanket Order":
                exit(-Value);
            "Document Type"::"Return Order",
          "Document Type"::"Credit Memo":
                exit(Value);

            // PR3.60
            "Document Type"::FOODStandingOrder:
                exit(-Value);
        // PR3.60
        end;
    end;

    local procedure BlanketOrderLookup()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeBlanketOrderLookup(Rec, IsHandled);
        if IsHandled then
            exit;

        SalesLine2.Reset();
        SalesLine2.SetCurrentKey("Document Type", Type, "No.");
        SalesLine2.SetRange("Document Type", "Document Type"::"Blanket Order");
        SalesLine2.SetRange(Type, Type);
        SalesLine2.SetRange("No.", "No.");
        SalesLine2.SetRange("Bill-to Customer No.", "Bill-to Customer No.");
        SalesLine2.SetRange("Sell-to Customer No.", "Sell-to Customer No.");
        if PAGE.RunModal(PAGE::"Sales Lines", SalesLine2) = ACTION::LookupOK then begin
            SalesLine2.TestField("Document Type", "Document Type"::"Blanket Order");
            "Blanket Order No." := SalesLine2."Document No.";
            Validate("Blanket Order Line No.", SalesLine2."Line No.");
        end;

        OnAfterBlanketOrderLookup(Rec);
    end;

    procedure ShowDimensions() IsChanged: Boolean
    var
        OldDimSetID: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeShowDimensions(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet("Dimension Set ID", StrSubstNo('%1 %2 %3', "Document Type", "Document No.", "Line No."));
        VerifyItemLineDim();
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
        ATOLink.UpdateAsmDimFromSalesLine(Rec);
        IsChanged := OldDimSetID <> "Dimension Set ID";

        OnAfterShowDimensions(Rec, xRec);
    end;

    procedure OpenItemTrackingLines()
    var
        Job: Record Job;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOpenItemTrackingLines(Rec, IsHandled);
        if IsHandled then
            exit;

        TestField(Type, Type::Item);
        TestField("No.");
        TestField("Quantity (Base)");
        if "Job Contract Entry No." <> 0 then
            Error(Text048, TableCaption, Job.TableCaption);

        IsHandled := false;
        OnBeforeCallItemTracking(Rec, IsHandled);
        if not IsHandled then
            SalesLineReserve.CallItemTracking(Rec);
        // PR3.60 Begin
        if TrackAlternateUnits then begin
            Rec.Find('=');
            UpdateSalesLine;    // P8000408A
            SetSalesLineAltQty; // P8000408A
        end;
        // PR3.60 End
        GetLotNo; // P8000043A
        Modify;   // P8000043A

        OnAfterOpenItemTrackingLines(Rec);
    end;

#if not CLEAN20
    [Obsolete('Replaced by CreateDim(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])', '20.0')]
    procedure CreateDim(Type1: Integer; No1: Code[20]; Type2: Integer; No2: Code[20]; Type3: Integer; No3: Code[20])
    var
        SourceCodeSetup: Record "Source Code Setup";
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
        IsHandled: Boolean;
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        IsHandled := false;
        OnBeforeCreateDim(IsHandled, Rec);
        if IsHandled then
            exit;

        SourceCodeSetup.Get();
        TableID[1] := Type1;
        No[1] := No1;
        TableID[2] := Type2;
        No[2] := No2;
        TableID[3] := Type3;
        No[3] := No3;
        OnAfterCreateDimTableIDs(Rec, CurrFieldNo, TableID, No);
        CreateDefaultDimSourcesFromDimArray(DefaultDimSource, TableID, No);


        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        GetSalesHeader();
        "Dimension Set ID" :=
          DimMgt.GetRecDefaultDimID(
            Rec, CurrFieldNo, DefaultDimSource, SourceCodeSetup.Sales,
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", SalesHeader."Dimension Set ID", DATABASE::Customer);
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
        ATOLink.UpdateAsmDimFromSalesLine(Rec);

        OnAfterCreateDim(Rec, CurrFieldNo);
    end;
#endif

    procedure CreateDim(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    var
        SourceCodeSetup: Record "Source Code Setup";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateDim(IsHandled, Rec);
        if IsHandled then
            exit;

        SourceCodeSetup.Get();
#if not CLEAN20
        RunEventOnAfterCreateDimTableIDs(DefaultDimSource);
#endif

        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        GetSalesHeader();
        "Dimension Set ID" :=
          DimMgt.GetRecDefaultDimID(
            Rec, CurrFieldNo, DefaultDimSource, SourceCodeSetup.Sales,
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", SalesHeader."Dimension Set ID", DATABASE::Customer);

        OnCreateDimOnBeforeUpdateGlobalDimFromDimSetID(Rec);
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
        ATOLink.UpdateAsmDimFromSalesLine(Rec);

        OnAfterCreateDim(Rec, CurrFieldNo);
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode, IsHandled);
        if IsHandled then
            exit;

        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
        VerifyItemLineDim();

        OnAfterValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode);
    end;

    procedure LookupShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeLookupShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode, IsHandled);
        if IsHandled then
            exit;

        DimMgt.LookupDimValueCode(FieldNumber, ShortcutDimCode);
        ValidateShortcutDimCode(FieldNumber, ShortcutDimCode);
    end;

    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20])
    begin
        DimMgt.GetShortcutDimensions("Dimension Set ID", ShortcutDimCode);
    end;

    procedure SelectMultipleItems()
    var
        ItemListPage: Page "Item List";
        SelectionFilter: Text;
    begin
        OnBeforeSelectMultipleItems(Rec);

        if IsCreditDocType() then
            SelectionFilter := ItemListPage.SelectActiveItems
        else
            SelectionFilter := ItemListPage.SelectActiveItemsForSale;
        if SelectionFilter <> '' then
            AddItems(SelectionFilter);

        OnAfterSelectMultipleItems(Rec);
    end;

    local procedure AddItems(SelectionFilter: Text)
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeAddItems(Rec, SelectionFilter, IsHandled);
        if IsHandled then
            exit;

        InitNewLine(SalesLine);
        Item.SetFilter("No.", SelectionFilter);
        if Item.FindSet() then
            repeat
                AddItem(SalesLine, Item."No.");
            until Item.Next() = 0;
    end;

    procedure AddItem(var SalesLine: Record "Sales Line"; ItemNo: Code[20])
    var
        LastSalesLine: Record "Sales Line";
    begin
        SalesLine.Init();
        SalesLine."Line No." += 10000;
        SalesLine.Validate(Type, Type::Item);
        SalesLine.Validate("No.", ItemNo);
        SalesLine.Insert(true);

        if SalesLine.IsAsmToOrderRequired() then
            SalesLine.AutoAsmToOrder();

        if TransferExtendedText.SalesCheckIfAnyExtText(SalesLine, false) then begin
            TransferExtendedText.InsertSalesExtTextRetLast(SalesLine, LastSalesLine);
            SalesLine."Line No." := LastSalesLine."Line No."
        end;
        OnAfterAddItem(SalesLine, LastSalesLine);
    end;

    procedure InitNewLine(var NewSalesLine: Record "Sales Line")
    var
        SalesLine: Record "Sales Line";
    begin
        NewSalesLine.Copy(Rec);
        SalesLine.SetRange("Document Type", NewSalesLine."Document Type");
        SalesLine.SetRange("Document No.", NewSalesLine."Document No.");
        if SalesLine.FindLast() then
            NewSalesLine."Line No." := SalesLine."Line No."
        else
            NewSalesLine."Line No." := 0;
    end;

    procedure ShowItemSub()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeShowItemSub(Rec, IsHandled);
        if IsHandled then
            exit;

        Clear(SalesHeader);
        TestStatusOpen();
        ItemSubstitutionMgt.ItemSubstGet(Rec);
        if TransferExtendedText.SalesCheckIfAnyExtText(Rec, false) then
            TransferExtendedText.InsertSalesExtText(Rec);

        OnAfterShowItemSub(Rec);
    end;

    procedure ShowNonstock()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeShowNonStock(Rec, NonstockItem, IsHandled);
        if IsHandled then
            exit;

        TestField(Type, Type::Item);
        if "No." <> '' then
            Error(SelectNonstockItemErr);

        OnShowNonstockOnBeforeOpenCatalogItemList(Rec, NonstockItem);
        if PAGE.RunModal(PAGE::"Catalog Item List", NonstockItem) = ACTION::LookupOK then begin
            CheckNonstockItemTemplate(NonstockItem);

            "No." := NonstockItem."Entry No.";
            CatalogItemMgt.NonStockSales(Rec);
            Validate("No.", "No.");
            UpdateUnitPriceFromNonstockItem();

            OnAfterShowNonStock(Rec, NonstockItem);
        end;
    end;

    local procedure UpdateUnitPriceFromNonstockItem()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateUnitPriceFromNonstockItem(Rec, NonstockItem, IsHandled);
        if IsHandled then
            exit;

        // Validate("Unit Price", NonstockItem."Unit Price"); // P8000921
        ValidateUnitPriceFOB(NonstockItem."Unit Price");      // P8000921
    end;

    local procedure GetSalesSetup()
    begin
        if not SalesSetupRead then
            SalesSetup.Get();
        SalesSetupRead := true;

        OnAfterGetSalesSetup(Rec, SalesSetup);
    end;

    local procedure GetFAPostingGroup()
    var
        LocalGLAcc: Record "G/L Account";
        FASetup: Record "FA Setup";
        FAPostingGr: Record "FA Posting Group";
        FADeprBook: Record "FA Depreciation Book";
        ShouldExit: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetFAPostingGroup(Rec, IsHandled);
        if IsHandled then
            exit;

        if (Type <> Type::"Fixed Asset") or ("No." = '') then
            exit;

        if "Depreciation Book Code" = '' then begin
            FASetup.Get();
            "Depreciation Book Code" := FASetup."Default Depr. Book";
            if not FADeprBook.Get("No.", "Depreciation Book Code") then
                "Depreciation Book Code" := '';

            ShouldExit := "Depreciation Book Code" = '';
            OnGetGetFAPostingGroupOnBeforeExit(Rec, ShouldExit);
            if ShouldExit then
                exit;
        end;

        FADeprBook.Get("No.", "Depreciation Book Code");
        FADeprBook.TestField("FA Posting Group");
        FAPostingGr.GetPostingGroup(FADeprBook."FA Posting Group", FADeprBook."Depreciation Book Code");
        LocalGLAcc.Get(FAPostingGr.GetAcquisitionCostAccountOnDisposal);
        LocalGLAcc.CheckGLAcc();
        GLSetup.Get();
        if GLSetup."VAT in Use" then
            LocalGLAcc.TestField("Gen. Prod. Posting Group");
        "Posting Group" := FADeprBook."FA Posting Group";
        "Gen. Prod. Posting Group" := LocalGLAcc."Gen. Prod. Posting Group";
        "Tax Group Code" := LocalGLAcc."Tax Group Code";
        Validate("VAT Prod. Posting Group", LocalGLAcc."VAT Prod. Posting Group");

        OnAfterGetFAPostingGroup(Rec, LocalGLAcc);
    end;

    procedure GetCaptionClass(FieldNumber: Integer): Text[80]
    var
        SalesLineCaptionClassMgmt: Codeunit "Sales Line CaptionClass Mgmt";
    begin
        exit(SalesLineCaptionClassMgmt.GetSalesLineCaptionClass(Rec, FieldNumber));
    end;

    procedure GetSKU() Result: Boolean
    begin
        exit(GetSKU(SKU));
    end;

    procedure GetSKU(var StockkeepingUnit: Record "Stockkeeping Unit") Result: Boolean
    begin
        if (StockkeepingUnit."Location Code" = "Location Code") and
           (StockkeepingUnit."Item No." = "No.") and
           (StockkeepingUnit."Variant Code" = "Variant Code")
        then
            exit(true);

        if StockkeepingUnit.Get("Location Code", "No.", "Variant Code") then
            exit(true);

        Result := false;
        OnAfterGetSKU(Rec, Result, StockkeepingUnit);
    end;

    procedure GetUnitCost()
    var
        Item: Record Item;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetUnitCost(Rec, IsHandled);
        if IsHandled then
            exit;

        if not (Type in [Type::Item, Type::FOODContainer]) then // PR3.61
            exit;                                             // PR3.61
        //TESTFIELD(Type,Type::Item);  

        TestField("No.");
        GetItem(Item);
        "Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item, "Unit of Measure Code");

        if TrackAlternateUnits then                                          // PR3.60
            AltQtyMgmt.AdjustPerBaseAmount("No.", "Qty. per Unit of Measure"); // PR3.60

        ValidateUnitCostLCYOnGetUnitCost(Item);

        if TrackAlternateUnits then                                    // PR3.60
            AltQtyMgmt.RestorePerBaseAmount("Qty. per Unit of Measure"); // PR3.60

        OnAfterGetUnitCost(Rec, Item);
    end;

    local procedure CalcUnitCost(ItemLedgEntry: Record "Item Ledger Entry"): Decimal
    var
        ValueEntry: Record "Value Entry";
        UnitCost: Decimal;
    begin
        with ValueEntry do begin
            SetCurrentKey("Item Ledger Entry No.");
            SetRange("Item Ledger Entry No.", ItemLedgEntry."Entry No.");
            if IsNonInventoriableItem then begin
                CalcSums("Cost Amount (Non-Invtbl.)");
                UnitCost := "Cost Amount (Non-Invtbl.)" / ItemLedgEntry.Quantity;
            end else begin
                CalcSums("Cost Amount (Actual)", "Cost Amount (Expected)");
                UnitCost :=
                  ("Cost Amount (Expected)" + "Cost Amount (Actual)") / ItemLedgEntry.GetCostingQty; // PR4.00
            end;
        end;

        exit(Abs(UnitCost * "Qty. per Unit of Measure"));
    end;

    procedure ShowItemChargeAssgnt()
    var
        ItemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
        AssignItemChargeSales: Codeunit "Item Charge Assgnt. (Sales)";
        ItemChargeAssgnts: Page "Item Charge Assignment (Sales)";
        ItemChargeAssgntLineAmt: Decimal;
        IsHandled: Boolean;
    begin
        Get("Document Type", "Document No.", "Line No.");
        TestField("No.");
        TestField(Quantity);

        if Type <> Type::"Charge (Item)" then begin
            Message(ItemChargeAssignmentErr);
            exit;
        end;

        GetSalesHeader();
        Currency.Initialize(SalesHeader."Currency Code");
        OnShowItemChargeAssgntOnAfterCurrencyInitialize(Rec, SalesHeader, Currency);
        if ("Inv. Discount Amount" = 0) and ("Line Discount Amount" = 0) and
           (not SalesHeader."Prices Including VAT")
        then
            ItemChargeAssgntLineAmt := "Line Amount"
        else
            if SalesHeader."Prices Including VAT" then
                ItemChargeAssgntLineAmt :=
                  Round(CalcLineAmount / (1 + "VAT %" / 100), Currency."Amount Rounding Precision")
            else
                ItemChargeAssgntLineAmt := CalcLineAmount;

        ItemChargeAssgntSales.Reset();
        ItemChargeAssgntSales.SetRange("Document Type", "Document Type");
        ItemChargeAssgntSales.SetRange("Document No.", "Document No.");
        ItemChargeAssgntSales.SetRange("Document Line No.", "Line No.");
        ItemChargeAssgntSales.SetRange("Item Charge No.", "No.");
        if not ItemChargeAssgntSales.FindLast() then begin
            ItemChargeAssgntSales."Document Type" := "Document Type";
            ItemChargeAssgntSales."Document No." := "Document No.";
            ItemChargeAssgntSales."Document Line No." := "Line No.";
            ItemChargeAssgntSales."Item Charge No." := "No.";
            ItemChargeAssgntSales."Unit Cost" :=
              Round(ItemChargeAssgntLineAmt / Quantity, Currency."Unit-Amount Rounding Precision");
        end;

        IsHandled := false;
        OnShowItemChargeAssgntOnBeforeCalcItemCharge(Rec, ItemChargeAssgntLineAmt, Currency, IsHandled, ItemChargeAssgntSales);
        if not IsHandled then
            ItemChargeAssgntLineAmt :=
              Round(ItemChargeAssgntLineAmt * ("Qty. to Invoice" / Quantity), Currency."Amount Rounding Precision");

        if IsCreditDocType() then
            AssignItemChargeSales.CreateDocChargeAssgn(ItemChargeAssgntSales, "Return Receipt No.")
        else
            AssignItemChargeSales.CreateDocChargeAssgn(ItemChargeAssgntSales, "Shipment No.");
        Clear(AssignItemChargeSales);
        Commit();

        ItemChargeAssgnts.Initialize(Rec, ItemChargeAssgntLineAmt);
        ItemChargeAssgnts.RunModal();
        CalcFields("Qty. to Assign");
    end;

    procedure UpdateItemChargeAssgnt()
    var
        ItemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
        ShareOfVAT: Decimal;
        TotalQtyToAssign: Decimal;
        TotalAmtToAssign: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateItemChargeAssgnt(Rec, IsHandled);
        if IsHandled then
            exit;

        if "Document Type" = "Document Type"::"Blanket Order" then
            exit;

        CalcFields("Qty. Assigned", "Qty. to Assign");
        if Abs("Quantity Invoiced") > Abs(("Qty. Assigned" + "Qty. to Assign")) then
            Error(Text055, FieldCaption("Quantity Invoiced"), FieldCaption("Qty. Assigned"), FieldCaption("Qty. to Assign"));

        ItemChargeAssgntSales.Reset();
        ItemChargeAssgntSales.SetRange("Document Type", "Document Type");
        ItemChargeAssgntSales.SetRange("Document No.", "Document No.");
        ItemChargeAssgntSales.SetRange("Document Line No.", "Line No.");
        ItemChargeAssgntSales.CalcSums("Qty. to Assign");
        TotalQtyToAssign := ItemChargeAssgntSales."Qty. to Assign";
        if (CurrFieldNo <> 0) and (Amount <> xRec.Amount) and
           not ((Quantity <> xRec.Quantity) and (TotalQtyToAssign = 0))
        then begin
            ItemChargeAssgntSales.SetFilter("Qty. Assigned", '<>0');
            if not ItemChargeAssgntSales.IsEmpty() then
                Error(Text026,
                  FieldCaption(Amount));
            ItemChargeAssgntSales.SetRange("Qty. Assigned");
        end;

        if ItemChargeAssgntSales.FindSet(true) and (Quantity <> 0) then begin
            GetSalesHeader();
            TotalAmtToAssign := CalcTotalAmtToAssign(TotalQtyToAssign);
            repeat
                ShareOfVAT := 1;
                if SalesHeader."Prices Including VAT" then
                    ShareOfVAT := 1 + "VAT %" / 100;
                if Quantity <> 0 then
                    if ItemChargeAssgntSales."Unit Cost" <>
                       Round(CalcLineAmount / Quantity / ShareOfVAT, Currency."Unit-Amount Rounding Precision")
                    then
                        ItemChargeAssgntSales."Unit Cost" :=
                          Round(CalcLineAmount / Quantity / ShareOfVAT, Currency."Unit-Amount Rounding Precision");
                if TotalQtyToAssign <> 0 then begin
                    ItemChargeAssgntSales."Amount to Assign" :=
                      Round(ItemChargeAssgntSales."Qty. to Assign" / TotalQtyToAssign * TotalAmtToAssign,
                        Currency."Amount Rounding Precision");
                    TotalQtyToAssign -= ItemChargeAssgntSales."Qty. to Assign";
                    TotalAmtToAssign -= ItemChargeAssgntSales."Amount to Assign";
                end;
                ItemChargeAssgntSales.Modify();
            until ItemChargeAssgntSales.Next() = 0;
            CalcFields("Qty. to Assign");
        end;
    end;

    procedure DeleteItemChargeAssignment(DocType: Enum "Sales Document Type"; DocNo: Code[20]; DocLineNo: Integer)
    var
        ItemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
    begin
        ItemChargeAssgntSales.SetRange("Applies-to Doc. Type", DocType);
        ItemChargeAssgntSales.SetRange("Applies-to Doc. No.", DocNo);
        ItemChargeAssgntSales.SetRange("Applies-to Doc. Line No.", DocLineNo);
        if not ItemChargeAssgntSales.IsEmpty() then
            ItemChargeAssgntSales.DeleteAll(true);
    end;

    local procedure DeleteChargeChargeAssgnt(DocType: Enum "Sales Document Type"; DocNo: Code[20]; DocLineNo: Integer)
    var
        ItemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
    begin
        if DocType <> "Document Type"::"Blanket Order" then
            if "Quantity Invoiced" <> 0 then begin
                CalcFields("Qty. Assigned");
                TestField("Qty. Assigned", "Quantity Invoiced");
            end;

        ItemChargeAssgntSales.Reset();
        ItemChargeAssgntSales.SetRange("Document Type", DocType);
        ItemChargeAssgntSales.SetRange("Document No.", DocNo);
        ItemChargeAssgntSales.SetRange("Document Line No.", DocLineNo);
        if not ItemChargeAssgntSales.IsEmpty() then
            ItemChargeAssgntSales.DeleteAll();

        OnAfterDeleteChargeChargeAssgnt(Rec, xRec, CurrFieldNo);
    end;

    local procedure CheckItemChargeAssgnt()
    var
        ItemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
    begin
        ItemChargeAssgntSales.SetRange("Applies-to Doc. Type", "Document Type");
        ItemChargeAssgntSales.SetRange("Applies-to Doc. No.", "Document No.");
        ItemChargeAssgntSales.SetRange("Applies-to Doc. Line No.", "Line No.");
        ItemChargeAssgntSales.SetRange("Document Type", "Document Type");
        ItemChargeAssgntSales.SetRange("Document No.", "Document No.");
        if ItemChargeAssgntSales.FindSet() then begin
            TestField("Allow Item Charge Assignment");
            repeat
                ItemChargeAssgntSales.TestField("Qty. to Assign", 0);
            until ItemChargeAssgntSales.Next() = 0;
        end;
    end;

    procedure TestStatusOpen()
    var
        StatusCheckSuspended2: Boolean;
        IsHandled: Boolean;
    begin
        GetSalesHeader();
        IsHandled := false;
        OnBeforeTestStatusOpen(Rec, SalesHeader, IsHandled, xRec, CurrFieldNo, StatusCheckSuspended);
        if IsHandled then
            exit;

        if StatusCheckSuspended then
            exit;

        // P8007748
        OnBeforeTestStatusOpen_Food(SalesHeader, StatusCheckSuspended2);
        if StatusCheckSuspended2 then
            exit;
        // P8007748

        if not "System-Created Entry" then
            if (xRec.Type <> Type) or HasTypeToFillMandatoryFields() then
                SalesHeader.TestField(Status, SalesHeader.Status::Open);

        OnAfterTestStatusOpen(Rec, SalesHeader);
    end;

    local procedure TestQtyFromLindDiscountAmount()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTestQtyFromLindDiscountAmount(Rec, CurrFieldNo, IsHandled);
        if IsHandled then
            exit;

        TestField(Quantity);
    end;

    procedure GetSuspendedStatusCheck(): Boolean
    begin
        exit(StatusCheckSuspended);
    end;

    procedure SuspendStatusCheck(Suspend: Boolean)
    begin
        StatusCheckSuspended := Suspend;
    end;

    procedure SuspendStatusCheck2(Suspend: Boolean) WasSuspended: Boolean
    begin
        // P800110503 - maintain original function
        // P8006787 - add return value
        WasSuspended := StatusCheckSuspended; // P8006787
        StatusCheckSuspended := Suspend;
    end;

    procedure SwitchLinesWithErrorsFilter(var ShowAllLinesEnabled: Boolean)
    var
        TempLineErrorMessage: Record "Error Message" temporary;
        DocumentErrorsMgt: Codeunit "Document Errors Mgt.";
    begin
        if ShowAllLinesEnabled then begin
            MarkedOnly(false);
            ShowAllLinesEnabled := false;
        end else begin
            DocumentErrorsMgt.GetErrorMessages(TempLineErrorMessage);
            if TempLineErrorMessage.FindSet() then
                repeat
                    if Rec.Get(TempLineErrorMessage."Context Record ID") then
                        Rec.Mark(true)
                until TempLineErrorMessage.Next() = 0;
            MarkedOnly(true);
            ShowAllLinesEnabled := true;
        end;
    end;

    procedure UpdateVATOnLines(QtyType: Option General,Invoicing,Shipping; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var VATAmountLine: Record "VAT Amount Line") LineWasModified: Boolean
    var
        TempVATAmountLineRemainder: Record "VAT Amount Line" temporary;
        Currency: Record Currency;
        NewAmount: Decimal;
        NewAmountIncludingVAT: Decimal;
        NewVATBaseAmount: Decimal;
        VATAmount: Decimal;
        VATDifference: Decimal;
        InvDiscAmount: Decimal;
        LineAmountToInvoice: Decimal;
        LineAmountToInvoiceDiscounted: Decimal;
        DeferralAmount: Decimal;
    begin
        if IsUpdateVATOnLinesHandled(SalesHeader, SalesLine, VATAmountLine, QtyType) then
            exit;

        LineWasModified := false;
        if QtyType = QtyType::Shipping then
            exit;

        Currency.Initialize(SalesHeader."Currency Code");
        OnUpdateVATOnLinesOnAfterCurrencyInitialize(Rec, SalesHeader, Currency);

        TempVATAmountLineRemainder.DeleteAll();

        with SalesLine do begin
            SetRange("Document Type", SalesHeader."Document Type");
            SetRange("Document No.", SalesHeader."No.");
            OnUpdateVATOnLinesOnAfterSalesLineSetFilter(SalesLine);
            LockTable();
            if FindSet() then
                repeat
                    if not ZeroAmountLine(QtyType) and
                       ((SalesHeader."Document Type" <> SalesHeader."Document Type"::Invoice) or ("Prepmt. Amt. Inv." = 0))
                    then begin
                        DeferralAmount := GetDeferralAmount();
                        VATAmountLine.Get("VAT Identifier", "VAT Calculation Type", "Tax Group Code", "Tax Area Code", false, "Line Amount" >= 0);
                        if VATAmountLine.Modified then begin
                            if not TempVATAmountLineRemainder.Get(
                                 "VAT Identifier", "VAT Calculation Type", "Tax Group Code", "Tax Area Code", false, "Line Amount" >= 0)
                            then begin
                                TempVATAmountLineRemainder := VATAmountLine;
                                TempVATAmountLineRemainder.Init();
                                TempVATAmountLineRemainder.Insert();
                            end;

                            if QtyType = QtyType::General then
                                LineAmountToInvoice := "Line Amount"
                            else
                                LineAmountToInvoice :=
                                  Round("Line Amount" * GetPricingQuantity(FieldNo("Qty. to Invoice"), '') / GetPricingQuantity(FieldNo(Quantity), ''), Currency."Amount Rounding Precision");  // P8001366

                            if "Allow Invoice Disc." then begin
                                if (VATAmountLine."Inv. Disc. Base Amount" = 0) or (LineAmountToInvoice = 0) then
                                    InvDiscAmount := 0
                                else begin
                                    LineAmountToInvoiceDiscounted :=
                                      VATAmountLine."Invoice Discount Amount" * LineAmountToInvoice /
                                      VATAmountLine."Inv. Disc. Base Amount";
                                    TempVATAmountLineRemainder."Invoice Discount Amount" :=
                                      TempVATAmountLineRemainder."Invoice Discount Amount" + LineAmountToInvoiceDiscounted;
                                    InvDiscAmount :=
                                      Round(
                                        TempVATAmountLineRemainder."Invoice Discount Amount", Currency."Amount Rounding Precision");
                                    TempVATAmountLineRemainder."Invoice Discount Amount" :=
                                      TempVATAmountLineRemainder."Invoice Discount Amount" - InvDiscAmount;
                                end;
                                if QtyType = QtyType::General then begin
                                    "Inv. Discount Amount" := InvDiscAmount;
                                    CalcInvDiscToInvoice();
                                end else
                                    "Inv. Disc. Amount to Invoice" := InvDiscAmount;
                            end else
                                InvDiscAmount := 0;

                            OnUpdateVATOnLinesOnBeforeCalculateAmounts(SalesLine, SalesHeader);
                            if QtyType = QtyType::General then begin
                                if SalesHeader."Prices Including VAT" then begin
                                    if (VATAmountLine.CalcLineAmount = 0) or ("Line Amount" = 0) then begin
                                        VATAmount := 0;
                                        NewAmountIncludingVAT := 0;
                                    end else begin
                                        VATAmount :=
                                          TempVATAmountLineRemainder."VAT Amount" +
                                          VATAmountLine."VAT Amount" * CalcLineAmount / VATAmountLine.CalcLineAmount;
                                        NewAmountIncludingVAT :=
                                          TempVATAmountLineRemainder."Amount Including VAT" +
                                          VATAmountLine."Amount Including VAT" * CalcLineAmount / VATAmountLine.CalcLineAmount;
                                    end;
                                    OnUpdateVATOnLinesOnBeforeCalculateNewAmount(
                                      Rec, SalesHeader, VATAmountLine, TempVATAmountLineRemainder, NewAmountIncludingVAT, VATAmount);
                                    NewAmount :=
                                      Round(NewAmountIncludingVAT, Currency."Amount Rounding Precision") -
                                      Round(VATAmount, Currency."Amount Rounding Precision");
                                    NewVATBaseAmount :=
                                      Round(
                                        NewAmount * (1 - SalesHeader."VAT Base Discount %" / 100), Currency."Amount Rounding Precision");
                                end else begin
                                    if "VAT Calculation Type" = "VAT Calculation Type"::"Full VAT" then begin
                                        VATAmount := CalcLineAmount();
                                        NewAmount := 0;
                                        NewVATBaseAmount := 0;
                                    end else begin
                                        NewAmount := CalcLineAmount();
                                        NewVATBaseAmount :=
                                          Round(
                                            NewAmount * (1 - SalesHeader."VAT Base Discount %" / 100), Currency."Amount Rounding Precision");
                                        if VATAmountLine."VAT Base" = 0 then
                                            VATAmount := 0
                                        else
                                            VATAmount :=
                                              TempVATAmountLineRemainder."VAT Amount" +
                                              VATAmountLine."VAT Amount" * NewAmount / VATAmountLine."VAT Base";
                                    end;
                                    OnUpdateVATOnLinesOnBeforeCalculateNewAmount(
                                      Rec, SalesHeader, VATAmountLine, TempVATAmountLineRemainder, NewAmount, VATAmount);
                                    NewAmountIncludingVAT := NewAmount + Round(VATAmount, Currency."Amount Rounding Precision");
                                end;
                                OnUpdateVATOnLinesOnAfterCalculateNewAmount(
                                  Rec, SalesHeader, VATAmountLine, TempVATAmountLineRemainder, NewAmountIncludingVAT, VATAmount,
                                  NewAmount, NewVATBaseAmount);
                            end else begin
                                if VATAmountLine.CalcLineAmount = 0 then
                                    VATDifference := 0
                                else
                                    VATDifference :=
                                      TempVATAmountLineRemainder."VAT Difference" +
                                      VATAmountLine."VAT Difference" * (LineAmountToInvoice - InvDiscAmount) / VATAmountLine.CalcLineAmount;
                                if LineAmountToInvoice = 0 then
                                    "VAT Difference" := 0
                                else
                                    "VAT Difference" := Round(VATDifference, Currency."Amount Rounding Precision");
                            end;
                            OnUpdateVATOnLinesOnAfterCalculateAmounts(SalesLine, SalesHeader);

                            if QtyType = QtyType::General then begin
                                if not "Prepayment Line" then
                                    UpdatePrepmtAmounts();
                                UpdateBaseAmounts(NewAmount, Round(NewAmountIncludingVAT, Currency."Amount Rounding Precision"), NewVATBaseAmount);
                            end;
                            InitOutstanding();
                            if Type = Type::"Charge (Item)" then
                                UpdateItemChargeAssgnt();
                            OnUpdateVATOnLinesOnBeforeModifySalesLine(SalesLine, VATAmount);
                            Modify;
                            LineWasModified := true;

                            if ("Deferral Code" <> '') and (DeferralAmount <> GetDeferralAmount()) then
                                UpdateDeferralAmounts();

                            TempVATAmountLineRemainder."Amount Including VAT" :=
                              NewAmountIncludingVAT - Round(NewAmountIncludingVAT, Currency."Amount Rounding Precision");
                            TempVATAmountLineRemainder."VAT Amount" := VATAmount - NewAmountIncludingVAT + NewAmount;
                            TempVATAmountLineRemainder."VAT Difference" := VATDifference - "VAT Difference";
                            OnUpdateVATOnLinesOnBeforeTempVATAmountLineRemainderModify(Rec, TempVATAmountLineRemainder, VATAmount, NewVATBaseAmount);
                            TempVATAmountLineRemainder.Modify();
                        end;
                    end;
                until Next() = 0;
        end;

        OnAfterUpdateVATOnLines(SalesHeader, SalesLine, VATAmountLine, QtyType);
    end;

    local procedure IsUpdateVATOnLinesHandled(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var VATAmountLine: Record "VAT Amount Line"; QtyType: Integer) IsHandled: Boolean
    begin
        IsHandled := FALSE;
        OnBeforeUpdateVATOnLines(SalesHeader, SalesLine, VATAmountLine, IsHandled, QtyType);
        exit(IsHandled);
    end;

    procedure CalcVATAmountLines(QtyType: Option General,Invoicing,Shipping; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var VATAmountLine: Record "VAT Amount Line")
    begin
        CalcVATAmountLines(QtyType, SalesHeader, SalesLine, VATAmountLine, true);
    end;

    procedure CalcVATAmountLines(QtyType: Option General,Invoicing,Shipping; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var VATAmountLine: Record "VAT Amount Line"; IncludePrepayments: Boolean)
    var
        TotalVATAmount: Decimal;
        QtyToHandle: Decimal;
        AmtToHandle: Decimal;
        RoundingLineInserted: Boolean;
        ShouldProcessRounding: Boolean;
        IsHandled: Boolean;
    begin
        if IsCalcVATAmountLinesHandled(SalesHeader, SalesLine, VATAmountLine, QtyType) then
            exit;

        Currency.Initialize(SalesHeader."Currency Code");
        OnCalcVATAmountLinesOnAfterCurrencyInitialize(Rec, SalesHeader, Currency);

        VATAmountLine.DeleteAll();

        with SalesLine do begin
            SetRange("Document Type", SalesHeader."Document Type");
            SetRange("Document No.", SalesHeader."No.");
            OnCalcVATAmountLinesOnAfterSetFilters(SalesLine, SalesHeader);
            if FindSet() then
                repeat
                    if not ZeroAmountLine(QtyType) then begin
                        if (Type = Type::"G/L Account") and not "Prepayment Line" then
                            RoundingLineInserted := (("No." = GetCPGInvRoundAcc(SalesHeader)) and "System-Created Entry") or RoundingLineInserted;
                        if "VAT Calculation Type" in
                           ["VAT Calculation Type"::"Reverse Charge VAT", "VAT Calculation Type"::"Sales Tax"]
                        then
                            "VAT %" := 0;
                        if not VATAmountLine.Get(
                             "VAT Identifier", "VAT Calculation Type", "Tax Group Code", "Tax Area Code", false, "Line Amount" >= 0)
                        then
                            VATAmountLine.InsertNewLine(
                              "VAT Identifier", "VAT Calculation Type", "Tax Group Code", "Tax Area Code", false, "VAT %", "Line Amount" >= 0, false);

                        OnCalcVATAmountLinesOnBeforeQtyTypeCase(VATAmountLine, SalesLine, SalesHeader);
                        case QtyType of
                            QtyType::General:
                                begin
                                    OnCalcVATAmountLinesOnBeforeQtyTypeGeneralCase(SalesHeader, SalesLine, VATAmountLine, IncludePrepayments, QtyType, QtyToHandle, AmtToHandle);
                                    VATAmountLine.Quantity += GetPricingQuantity(FieldNo(Quantity), 'BASE'); // P8001366
                                    VATAmountLine.SumLine(
                                      "Line Amount", "Inv. Discount Amount", "VAT Difference", "Allow Invoice Disc.", "Prepayment Line");
                                end;
                            QtyType::Invoicing:
                                begin
                                    IsHandled := false;
                                    OnCalcVATAmountLinesOnBeforeAssignQuantities(SalesHeader, SalesLine, VATAmountLine, QtyToHandle, IsHandled);
                                    if not IsHandled then
                                        case true of
                                            ("Document Type" in ["Document Type"::Order, "Document Type"::Invoice]) and
                                        (not SalesHeader.Ship) and SalesHeader.Invoice and (not "Prepayment Line"):
                                                if "Shipment No." = '' then begin
                                                    QtyToHandle := GetAbsMin(GetPricingQuantity(FieldNo("Qty. to Invoice"), ''), GetPricingQuantity(FieldNo("Qty. Shipped Not Invoiced"), '')); // P8001366
                                                    VATAmountLine.Quantity += GetAbsMin(GetPricingQuantity(FieldNo("Qty. to Invoice"), 'BASE'), GetPricingQuantity(FieldNo("Qty. Shipped Not Invoiced"), 'BASE')); // P8001366
                                                end else begin
                                                    QtyToHandle := GetPricingQuantity(FieldNo("Qty. to Invoice"), ''); // P8001366
                                                    VATAmountLine.Quantity += GetPricingQuantity(FieldNo("Qty. to Invoice"), 'BASE'); // P8001366
                                                end;
                                            IsCreditDocType() and (not SalesHeader.Receive) and SalesHeader.Invoice:
                                                if "Return Receipt No." = '' then begin
                                                    QtyToHandle := GetAbsMin(GetPricingQuantity(FieldNo("Qty. to Invoice"), ''), GetPricingQuantity(FieldNo("Return Qty. Rcd. Not Invd."), '')); // P8001366
                                                    VATAmountLine.Quantity += GetAbsMin(GetPricingQuantity(FieldNo("Qty. to Invoice"), 'BASE'), GetPricingQuantity(FieldNo("Return Qty. Rcd. Not Invd."), 'BASE')); // P8001366
                                                end else begin
                                                    QtyToHandle := GetPricingQuantity(FieldNo("Qty. to Invoice"), ''); // P8001366
                                                    VATAmountLine.Quantity += GetPricingQuantity(FieldNo("Qty. to Invoice"), 'BASE'); // P8001366
                                                end;
                                            else begin
                                                    QtyToHandle := GetPricingQuantity(FieldNo("Qty. to Invoice"), ''); // P8001366
                                                    VATAmountLine.Quantity += GetPricingQuantity(FieldNo("Qty. to Invoice"), 'BASE'); // P8001366
                                                end;
                                        end;

                                    OnCalcVATAmountLinesOnBeforeAssignAmtToHandle(SalesHeader, SalesLine, VATAmountLine, IncludePrepayments, QtyType, QtyToHandle, AmtToHandle);
                                    if IncludePrepayments then
                                        AmtToHandle := GetLineAmountToHandleInclPrepmt(QtyToHandle)
                                    else
                                        AmtToHandle := GetLineAmountToHandle(QtyToHandle);
                                    if SalesHeader."Invoice Discount Calculation" <> SalesHeader."Invoice Discount Calculation"::Amount then
                                        VATAmountLine.SumLine(
                                          AmtToHandle, Round("Inv. Discount Amount" * QtyToHandle / GetPricingQuantity(FieldNo(Quantity), ''), Currency."Amount Rounding Precision"), // P8001366
                                          "VAT Difference", "Allow Invoice Disc.", "Prepayment Line")
                                    else
                                        VATAmountLine.SumLine(
                                          AmtToHandle, "Inv. Disc. Amount to Invoice", "VAT Difference", "Allow Invoice Disc.", "Prepayment Line");
                                end;
                            QtyType::Shipping:
                                begin
                                    if "Document Type" in
                                       ["Document Type"::"Return Order", "Document Type"::"Credit Memo"]
                                    then begin
                                        QtyToHandle := GetPricingQuantity(FieldNo("Return Qty. to Receive"), ''); // P8001366
                                        VATAmountLine.Quantity += GetPricingQuantity(FieldNo("Return Qty. to Receive"), 'BASE'); // P8001366
                                    end else begin
                                        QtyToHandle := GetPricingQuantity(FieldNo("Qty. to Ship"), ''); // P8001366
                                        VATAmountLine.Quantity += GetPricingQuantity(FieldNo("Qty. to Ship"), 'BASE'); // P8001366
                                    end;
                                    if IncludePrepayments then
                                        AmtToHandle := GetLineAmountToHandleInclPrepmt(QtyToHandle)
                                    else
                                        AmtToHandle := GetLineAmountToHandle(QtyToHandle);
                                    VATAmountLine.SumLine(
                                      AmtToHandle, Round("Inv. Discount Amount" * QtyToHandle / GetPricingQuantity(FieldNo(Quantity), ''), Currency."Amount Rounding Precision"), // P8001366
                                      "VAT Difference", "Allow Invoice Disc.", "Prepayment Line");
                                end;
                        end;
                        TotalVATAmount += "Amount Including VAT" - Amount;
                        OnCalcVATAmountLinesOnAfterCalcLineTotals(VATAmountLine, SalesHeader, SalesLine, Currency, QtyType, TotalVATAmount);
                    end;
                until Next() = 0;
        end;

        OnCalcVATAmountLinesOnBeforeVATAmountLineUpdateLines(SalesLine);
        VATAmountLine.UpdateLines(
          TotalVATAmount, Currency, SalesHeader."Currency Factor", SalesHeader."Prices Including VAT",
          SalesHeader."VAT Base Discount %", SalesHeader."Tax Area Code", SalesHeader."Tax Liable", SalesHeader."Posting Date");

        ShouldProcessRounding := RoundingLineInserted and (TotalVATAmount <> 0);
        OnCalcVATAmountLinesOnAfterCalcShouldProcessRounding(VATAmountLine, Currency, ShouldProcessRounding);
        if ShouldProcessRounding then
            if GetVATAmountLineOfMaxAmt(VATAmountLine, SalesLine) then begin
                VATAmountLine."VAT Amount" += TotalVATAmount;
                VATAmountLine."Amount Including VAT" += TotalVATAmount;
                VATAmountLine."Calculated VAT Amount" += TotalVATAmount;
                VATAmountLine.Modify();
            end;

        OnAfterCalcVATAmountLines(SalesHeader, SalesLine, VATAmountLine, QtyType);
    end;

    procedure GetCPGInvRoundAcc(var SalesHeader: Record "Sales Header") AccountNo: Code[20]
    var
        Cust: Record Customer;
        CustPostingGroup: Record "Customer Posting Group";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetCPGInvRoundAcc(SalesHeader, Cust, AccountNo, IsHandled);
        if IsHandled then
            exit(AccountNo);

        GetSalesSetup();
        if SalesSetup."Invoice Rounding" then
            if Cust.Get(SalesHeader."Bill-to Customer No.") then
                CustPostingGroup.Get(Cust."Customer Posting Group")
            else
                GetCustomerPostingGroupFromTemplate(CustPostingGroup, SalesHeader);

        exit(CustPostingGroup."Invoice Rounding Account");
    end;

    local procedure GetCustomerPostingGroupFromTemplate(var CustPostingGroup: Record "Customer Posting Group"; SalesHeader: Record "Sales Header")
    var
        CustomerTempl: Record "Customer Templ.";
    begin
        if CustomerTempl.Get(SalesHeader."Sell-to Customer Templ. Code") then
            CustPostingGroup.Get(CustomerTempl."Customer Posting Group");
    end;

    local procedure GetVATAmountLineOfMaxAmt(var VATAmountLine: Record "VAT Amount Line"; SalesLine: Record "Sales Line"): Boolean
    var
        VATAmount1: Decimal;
        VATAmount2: Decimal;
        IsPositive1: Boolean;
        IsPositive2: Boolean;
    begin
        if VATAmountLine.Get(SalesLine."VAT Identifier", SalesLine."VAT Calculation Type", SalesLine."Tax Group Code", false, false) then begin
            VATAmount1 := VATAmountLine."VAT Amount";
            IsPositive1 := VATAmountLine.Positive;
        end;
        if VATAmountLine.Get(SalesLine."VAT Identifier", SalesLine."VAT Calculation Type", SalesLine."Tax Group Code", false, true) then begin
            VATAmount2 := VATAmountLine."VAT Amount";
            IsPositive2 := VATAmountLine.Positive;
        end;
        if Abs(VATAmount1) >= Abs(VATAmount2) then
            exit(
              VATAmountLine.Get(SalesLine."VAT Identifier", SalesLine."VAT Calculation Type", SalesLine."Tax Group Code", false, IsPositive1));
        exit(
          VATAmountLine.Get(SalesLine."VAT Identifier", SalesLine."VAT Calculation Type", SalesLine."Tax Group Code", false, IsPositive2));
    end;

    procedure CalcInvDiscToInvoice()
    var
        OldInvDiscAmtToInv: Decimal;
    begin
        GetSalesHeader();
        OldInvDiscAmtToInv := "Inv. Disc. Amount to Invoice";
        if Quantity = 0 then
            Validate("Inv. Disc. Amount to Invoice", 0)
        else
            Validate(
              "Inv. Disc. Amount to Invoice",
              Round(
                "Inv. Discount Amount" * "Qty. to Invoice" / Quantity,
                Currency."Amount Rounding Precision"));

        if OldInvDiscAmtToInv <> "Inv. Disc. Amount to Invoice" then begin
            "Amount Including VAT" := "Amount Including VAT" - "VAT Difference";
            "VAT Difference" := 0;
        end;
        NotifyOnMissingSetup(FieldNo("Inv. Discount Amount"));

        OnAfterCalcInvDiscToInvoice(Rec, OldInvDiscAmtToInv);
    end;

    procedure UpdateWithWarehouseShip()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateWithWarehouseShip(Rec, IsHandled);
        if IsHandled then
            exit;

        if IsInventoriableItem() then
            case true of
                ("Document Type" in ["Document Type"::Quote, "Document Type"::Order]) and (Quantity >= 0):
                    begin                         // PR3.60.02
                        WarehouseUpdate[1] := true; // PR3.60.02
                        if Location.RequireShipment("Location Code") then
                            Validate("Qty. to Ship", GetContainerQuantity(true))   // P8007152, P80046533
                        else
                            Validate("Qty. to Ship", "Outstanding Quantity" - GetContainerQuantity(false)); // P80046533
                    end;                          // PR3.60.02
                ("Document Type" in ["Document Type"::Quote, "Document Type"::Order]) and (Quantity < 0):
                    if Location.RequireReceive("Location Code") then
                        Validate("Qty. to Ship", 0)
                    else
                        Validate("Qty. to Ship", "Outstanding Quantity");
                ("Document Type" = "Document Type"::"Return Order") and (Quantity >= 0):
                    if Location.RequireReceive("Location Code") then
                        Validate("Return Qty. to Receive", GetContainerQuantity(true))   // P80046533
                    else
                        Validate("Return Qty. to Receive", "Outstanding Quantity" - GetContainerQuantity(false)); // P80046533
                ("Document Type" = "Document Type"::"Return Order") and (Quantity < 0):
                    if Location.RequireShipment("Location Code") then
                        Validate("Return Qty. to Receive", 0)
                    else
                        Validate("Return Qty. to Receive", "Outstanding Quantity");
            end;

        if not (CurrFieldNo in [FieldNo("Qty. to Ship"), FieldNo("Return Qty. to Receive")]) then // P8001132
            SetDefaultQuantity();

        UpdateOnWhseChange; // P8000282A

        OnAfterUpdateWithWarehouseShip(SalesHeader, Rec);
    end;

    local procedure CheckWarehouse()
    var
        Location2: Record Location;
        WhseSetup: Record "Warehouse Setup";
        ShowDialog: Option " ",Message,Error;
        DialogText: Text[50];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckWarehouse(Rec, IsHandled);
        if IsHandled then
            exit;

        GetLocation("Location Code");
        if "Location Code" = '' then begin
            WhseSetup.Get();
            Location2."Require Shipment" := WhseSetup."Require Shipment";
            Location2."Require Pick" := WhseSetup."Require Pick";
            Location2."Require Receive" := WhseSetup."Require Receive";
            Location2."Require Put-away" := WhseSetup."Require Put-away";
        end else
            Location2 := Location;
        OnCheckWarehouseOnAfterSetLocation2(Rec, Location2);

        DialogText := Text035;
        if ("Document Type" in ["Document Type"::Order, "Document Type"::"Return Order"]) and
           Location2."Directed Put-away and Pick"
        then begin
            ShowDialog := ShowDialog::Error;
            if (("Document Type" = "Document Type"::Order) and (Quantity >= 0)) or
               (("Document Type" = "Document Type"::"Return Order") and (Quantity < 0))
            then
                DialogText :=
                  DialogText + Location2.GetRequirementText(Location2.FieldNo("Require Shipment"))
            else
                DialogText :=
                  DialogText + Location2.GetRequirementText(Location2.FieldNo("Require Receive"));
        end else begin
            if (("Document Type" = "Document Type"::Order) and (Quantity >= 0) and
                (Location2."Require Shipment" or Location2."Require Pick")) or
               (("Document Type" = "Document Type"::"Return Order") and (Quantity < 0) and
                (Location2."Require Shipment" or Location2."Require Pick"))
            then begin
                if WhseValidateSourceLine.WhseLinesExist(
                     DATABASE::"Sales Line", "Document Type".AsInteger(), "Document No.", "Line No.", 0, Quantity)
                then
                    ShowDialog := ShowDialog::Error
                else
                    if Location2."Require Shipment" then
                        ShowDialog := ShowDialog::Message;
                if Location2."Require Shipment" then
                    DialogText :=
                      DialogText + Location2.GetRequirementText(Location2.FieldNo("Require Shipment"))
                else begin
                    DialogText := Text036;
                    DialogText :=
                      DialogText + Location2.GetRequirementText(Location2.FieldNo("Require Pick"));
                end;
            end;

            if (("Document Type" = "Document Type"::Order) and (Quantity < 0) and
                (Location2."Require Receive" or Location2."Require Put-away")) or
               (("Document Type" = "Document Type"::"Return Order") and (Quantity >= 0) and
                (Location2."Require Receive" or Location2."Require Put-away"))
            then begin
                if WhseValidateSourceLine.WhseLinesExist(
                     DATABASE::"Sales Line", "Document Type".AsInteger(), "Document No.", "Line No.", 0, Quantity)
                then
                    ShowDialog := ShowDialog::Error
                else
                    if Location2."Require Receive" then
                        ShowDialog := ShowDialog::Message;
                if Location2."Require Receive" then
                    DialogText :=
                      DialogText + Location2.GetRequirementText(Location2.FieldNo("Require Receive"))
                else begin
                    DialogText := Text036;
                    DialogText :=
                      DialogText + Location2.GetRequirementText(Location2.FieldNo("Require Put-away"));
                end;
            end;
        end;

        OnCheckWarehouseOnBeforeShowDialog(Rec, Location2, ShowDialog, DialogText);

        case ShowDialog of
            ShowDialog::Message:
                Message(WhseRequirementMsg, DialogText);
            ShowDialog::Error:
                Error(Text016, DialogText, FieldCaption("Line No."), "Line No.");
        end;

        HandleDedicatedBin(true);
    end;

    local procedure CheckWarehouseForQtyToShip()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckWarehouseForQtyToShip(Rec, CurrFieldNo, IsHandled, xRec);
        if IsHandled then
            exit;

        if (CurrFieldNo <> 0) and IsInventoriableItem() and (not "Drop Shipment") then begin
            if Location."Require Shipment" and ("Qty. to Ship" <> 0) then
                CheckWarehouse();
            WhseValidateSourceLine.SalesLineVerifyChange(Rec, xRec);
        end;
    end;

    procedure UpdateDates()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateDates(Rec, IsHandled);
        if IsHandled then
            exit;

        if CurrFieldNo = 0 then begin
            PlannedShipmentDateCalculated := false;
            PlannedDeliveryDateCalculated := false;
        end;
        if "Promised Delivery Date" <> 0D then
            Validate("Promised Delivery Date")
        else
            if "Requested Delivery Date" <> 0D then
                Validate("Requested Delivery Date")
            else
                Validate("Shipment Date");

        OnAfterUpdateDates(Rec);
    end;

    procedure GetItemTranslation()
    var
        ItemTranslation: Record "Item Translation";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetItemTranslation(Rec, IsHandled);
        if IsHandled then
            exit;

        GetSalesHeader();
        if ItemTranslation.Get("No.", "Variant Code", SalesHeader."Language Code") then begin
            Description := ItemTranslation.Description;
            "Description 2" := ItemTranslation."Description 2";
            OnAfterGetItemTranslation(Rec, SalesHeader, ItemTranslation);
        end;
    end;

    local procedure GetLocation(LocationCode: Code[10])
    begin
        if LocationCode = '' then
            Clear(Location)
        else
            if Location.Code <> LocationCode then
                Location.Get(LocationCode);
    end;

    procedure PriceExists(): Boolean
    begin
        if "Document No." <> '' then
            exit(PriceExists(true));
        exit(false);
    end;

    procedure LineDiscExists(): Boolean
    begin
        if "Document No." <> '' then
            exit(DiscountExists(true));
        exit(false);
    end;

    procedure RowID1(): Text[250]
    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        exit(ItemTrackingMgt.ComposeRowID(DATABASE::"Sales Line", "Document Type".AsInteger(),
            "Document No.", '', 0, "Line No."));
    end;

    local procedure UpdateItemReference()
    begin
        ItemReferenceMgt.EnterSalesItemReference(Rec);
        UpdateICPartner();

        OnAfterUpdateItemReference(Rec);
    end;

    procedure GetDefaultBin()
    var
        WMSManagement: Codeunit "WMS Management";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetDefaultBin(Rec, IsHandled);
        if IsHandled then
            exit;

        if (not (Type in [Type::Item, Type::FOODContainer])) or IsNonInventoriableItem() then
            exit;

        "Bin Code" := '';
        if "Drop Shipment" then
            exit;

        if ("Location Code" <> '') and ("No." <> '') then begin
            GetLocation("Location Code");
            if IsNonWarehouseItem() then // P8001290
                exit;                      // P8001290
            if Location."Bin Mandatory" and not Location."Directed Put-away and Pick" then begin
                if ("Qty. to Assemble to Order" > 0) or IsAsmToOrderRequired then
                    if GetATOBin(Location, "Bin Code") then
                        exit;

                if not IsShipmentBinOverridesDefaultBin(Location) then begin
                    // P8000631A
                    if ("Document Type" in ["Document Type"::"Return Order", "Document Type"::"Credit Memo"]) then
                        if (Location."Receipt Bin Code (1-Doc)" <> '') then
                            "Bin Code" := Location."Receipt Bin Code (1-Doc)"
                        else
                            WMSManagement.GetDefaultBin("No.", "Variant Code", "Location Code", "Bin Code")
                    else
                        if (Location."Shipment Bin Code (1-Doc)" <> '') then
                            "Bin Code" := Location."Shipment Bin Code (1-Doc)"
                        else
                            WMSManagement.GetDefaultBin("No.", "Variant Code", "Location Code", "Bin Code");
                    // P8000631A
                    HandleDedicatedBin(false);
                end;
            end;
        end;

        OnAfterGetDefaultBin(Rec);
    end;

    procedure GetATOBin(Location: Record Location; var BinCode: Code[20]): Boolean
    var
        AsmHeader: Record "Assembly Header";
    begin
        if not Location."Require Shipment" then
            BinCode := Location."Asm.-to-Order Shpt. Bin Code";
        if BinCode <> '' then
            exit(true);

        if AsmHeader.GetFromAssemblyBin(Location, BinCode) then
            exit(true);

        exit(false);
    end;

    procedure IsInbound(): Boolean
    begin
        case "Document Type" of
            "Document Type"::Order, "Document Type"::Invoice, "Document Type"::Quote, "Document Type"::"Blanket Order":
                exit("Quantity (Base)" < 0);
            "Document Type"::"Return Order", "Document Type"::"Credit Memo":
                exit("Quantity (Base)" > 0);
        end;

        exit(false);
    end;

    local procedure HandleDedicatedBin(IssueWarning: Boolean)
    var
        WhseIntegrationMgt: Codeunit "Whse. Integration Management";
    begin
        if IsInbound() or ("Quantity (Base)" = 0) or ("Document Type" = "Document Type"::"Blanket Order") then
            exit;

        WhseIntegrationMgt.CheckIfBinDedicatedOnSrcDoc("Location Code", "Bin Code", IssueWarning);
    end;

    procedure CheckAssocPurchOrder(TheFieldCaption: Text[250])
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckAssocPurchOrder(Rec, TheFieldCaption, IsHandled, xRec);
        if IsHandled then
            exit;

        if TheFieldCaption = '' then begin // If sales line is being deleted
            if "Purch. Order Line No." <> 0 then
                Error(Text000, "Purchase Order No.", "Purch. Order Line No.");
            if "Special Order Purch. Line No." <> 0 then
                CheckPurchOrderLineDeleted("Special Order Purchase No.", "Special Order Purch. Line No.");
        end else begin
            if "Purch. Order Line No." <> 0 then
                Error(Text002, TheFieldCaption, "Purchase Order No.", "Purch. Order Line No.");

            if "Special Order Purch. Line No." <> 0 then
                Error(Text002, TheFieldCaption, "Special Order Purchase No.", "Special Order Purch. Line No.");
        end;
    end;

    local procedure CheckPurchOrderLineDeleted(PurchaseOrderNo: Code[20]; PurchaseLineNo: Integer)
    var
        PurchaseLine: Record "Purchase Line";
    begin
        if PurchaseLine.Get(PurchaseLine."Document Type"::Order, PurchaseOrderNo, PurchaseLineNo) then
            Error(Text000, PurchaseOrderNo, PurchaseLineNo);
    end;

    procedure CheckServItemCreation()
    var
        Item: Record Item;
        ServItemGroup: Record "Service Item Group";
    begin
        if CurrFieldNo = 0 then
            exit;
        if Type <> Type::Item then
            exit;
        GetItem(Item);
        if Item."Service Item Group" = '' then
            exit;
        if ServItemGroup.Get(Item."Service Item Group") then
            if ServItemGroup."Create Service Item" then
                if "Qty. to Ship (Base)" <> Round("Qty. to Ship (Base)", 1) then
                    Error(
                      Text034,
                      FieldCaption("Qty. to Ship (Base)"),
                      ServItemGroup.FieldCaption("Create Service Item"));
    end;

    procedure ItemExists(ItemNo: Code[20]): Boolean
    var
        Item2: Record Item;
    begin
        if Type = Type::Item then
            if not Item2.Get(ItemNo) then
                exit(false);
        exit(true);
    end;

    procedure FindOrCreateRecordByNo(SourceNo: Code[20]): Code[20]
    var
        Item: Record Item;
        FindRecordManagement: Codeunit "Find Record Management";
        FoundNo: Text;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeFindOrCreateRecordByNo(Rec, xRec, CurrFieldNo, IsHandled);
        if IsHandled then
            exit("No.");

        GetSalesSetup();

        if Type = Type::Item then begin
            if Item.TryGetItemNoOpenCardWithView(
                 FoundNo, SourceNo, SalesSetup."Create Item from Item No.", true, SalesSetup."Create Item from Item No.", '')
            then
                exit(CopyStr(FoundNo, 1, MaxStrLen("No.")))
        end else
            exit(FindRecordManagement.FindNoFromTypedValue(Type.AsInteger(), "No.", not "System-Created Entry"));

        exit(SourceNo);
    end;

    procedure IsShipment(): Boolean
    begin
        exit(SignedXX("Quantity (Base)") < 0);
    end;

    local procedure GetAbsMin(QtyToHandle: Decimal; QtyHandled: Decimal) Result: Decimal
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetAbsMin(Rec, QtyToHandle, QtyHandled, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if Abs(QtyHandled) < Abs(QtyToHandle) then
            exit(QtyHandled);

        exit(QtyToHandle);
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    procedure GetHideValidationDialog(): Boolean
    begin
        exit(HideValidationDialog);
    end;

    local procedure CheckApplFromItemLedgEntry(var ItemLedgEntry: Record "Item Ledger Entry")
    var
        Item: Record Item;
        QtyNotReturned: Decimal;
        QtyReturned: Decimal;
        UnitOfMeasure: Record "Unit of Measure";
        QtyAlt: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckApplFromItemLedgEntry(Rec, xRec, ItemLedgEntry, IsHandled);
        if IsHandled then
            exit;

        if "Appl.-from Item Entry" = 0 then
            exit;

        if "Shipment No." <> '' then
            exit;

        OnCheckApplFromItemLedgEntryOnBeforeTestFieldType(Rec);
        TestField(Type, Type::Item);
        TestField(Quantity);
        if IsCreditDocType() then begin
            if Quantity < 0 then
                FieldError(Quantity, Text029);
        end else begin
            if Quantity > 0 then
                FieldError(Quantity, Text030);
        end;

        ItemLedgEntry.Get("Appl.-from Item Entry");
        ItemLedgEntry.TestField(Positive, false);
        ItemLedgEntry.TestField("Item No.", "No.");
        ItemLedgEntry.TestField("Variant Code", "Variant Code");
        ItemLedgEntry.CheckTrackingDoesNotExist(RecordId, FieldCaption("Appl.-from Item Entry"));

        if Abs("Quantity (Base)") > -ItemLedgEntry.Quantity then
            Error(
              Text046,
              -ItemLedgEntry.Quantity, ItemLedgEntry.FieldCaption("Document No."),
              ItemLedgEntry."Document No.");

        if IsCreditDocType() then begin // P8001213
            if Abs("Outstanding Qty. (Base)") > -ItemLedgEntry."Shipped Qty. Not Returned" then begin
                QtyNotReturned := ItemLedgEntry."Shipped Qty. Not Returned";
                QtyReturned := ItemLedgEntry.Quantity - ItemLedgEntry."Shipped Qty. Not Returned";
                if "Qty. per Unit of Measure" <> 0 then begin
                    QtyNotReturned :=
                      Round(ItemLedgEntry."Shipped Qty. Not Returned" / "Qty. per Unit of Measure", UOMMgt.QtyRndPrecision);
                    QtyReturned :=
                      Round(
                        (ItemLedgEntry.Quantity - ItemLedgEntry."Shipped Qty. Not Returned") /
                        "Qty. per Unit of Measure", UOMMgt.QtyRndPrecision);
                end;
                ShowReturnedUnitsError(ItemLedgEntry, QtyReturned, QtyNotReturned);
            end;
            // P8001213
            if Abs("Quantity (Alt.)" - "Qty. Shipped (Alt.)") > -ItemLedgEntry."Shipped Qty. Not Ret. (Alt.)" then begin
                QtyNotReturned := ItemLedgEntry."Shipped Qty. Not Ret. (Alt.)";
                QtyReturned := ItemLedgEntry."Quantity (Alt.)" - ItemLedgEntry."Shipped Qty. Not Ret. (Alt.)";
                GetItem(Item); // P80066030
                UnitOfMeasure.Get(Item."Alternate Unit of Measure");
                Error(
                  Text37002008,
                  -QtyReturned, ItemLedgEntry.FieldCaption("Document No."),
                  ItemLedgEntry."Document No.", -QtyNotReturned, UnitOfMeasure.Description);
            end;
        end;
        // P8001213
    end;

    procedure CalcPrepaymentToDeduct()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalcPrepmtToDeduct(Rec, IsHandled);
        if IsHandled then
            exit;

        if ("Qty. to Invoice" <> 0) and ("Prepmt. Amt. Inv." <> 0) then begin
            GetSalesHeader();
            if ("Prepayment %" = 100) and not IsFinalInvoice then
                "Prepmt Amt to Deduct" := GetLineAmountToHandle(GetPricingQuantity(FieldNo("Qty. to Invoice"), '')) - "Inv. Disc. Amount to Invoice" // P8001366
            else
                "Prepmt Amt to Deduct" :=
                  Round(
                    ("Prepmt. Amt. Inv." - "Prepmt Amt Deducted") *
                    GetPricingQuantity(FieldNo("Qty. to Invoice"), '') /                                                                                     // P8001366
                     (GetPricingQuantity(FieldNo(Quantity), '') - GetPricingQuantity(FieldNo("Quantity Invoiced"), '')), Currency."Amount Rounding Precision") // P8001366
        end else
            "Prepmt Amt to Deduct" := 0
    end;

    procedure IsFinalInvoice(): Boolean
    begin
        exit("Qty. to Invoice" = Quantity - "Quantity Invoiced");
    end;

    procedure GetLineAmountToHandle(QtyToHandle: Decimal): Decimal
    var
        LineAmount: Decimal;
        LineDiscAmount: Decimal;
    begin
        if "Line Discount %" = 100 then
            exit(0);

        GetSalesHeader();

        if "Prepmt Amt to Deduct" = 0 then
            LineAmount := Round(QtyToHandle * "Unit Price", Currency."Amount Rounding Precision")
        else
            if Quantity <> 0 then begin
                LineAmount := Round(Quantity * "Unit Price", Currency."Amount Rounding Precision");
                LineAmount := Round(QtyToHandle * LineAmount / Quantity, Currency."Amount Rounding Precision");
            end else
                LineAmount := 0;

        if QtyToHandle <> Quantity then
            LineDiscAmount := Round(LineAmount * "Line Discount %" / 100, Currency."Amount Rounding Precision")
        else
            LineDiscAmount := "Line Discount Amount";

        OnAfterGetLineAmountToHandle(Rec, QtyToHandle, LineAmount, LineDiscAmount);
        exit(LineAmount - LineDiscAmount);
    end;

    procedure GetLineAmountToHandleInclPrepmt(QtyToHandle: Decimal): Decimal
    var
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
        DocType: Option Invoice,"Credit Memo",Statistic;
    begin
        if "Line Discount %" = 100 then
            exit(0);

        if IsCreditDocType() then
            DocType := DocType::"Credit Memo"
        else
            DocType := DocType::Invoice;

        if ("Prepayment %" = 100) and not "Prepayment Line" and ("Prepmt Amt to Deduct" <> 0) then begin
            GetSalesHeader();
            if SalesPostPrepayments.PrepmtAmount(Rec, DocType, SalesHeader."Prepmt. Include Tax") <= 0 then
                exit("Prepmt Amt to Deduct" + "Inv. Disc. Amount to Invoice");
        end;
        exit(GetLineAmountToHandle(QtyToHandle));
    end;

    procedure GetLineAmountExclVAT(): Decimal
    begin
        if "Document No." = '' then
            exit(0);
        GetSalesHeader();
        if not SalesHeader."Prices Including VAT" then
            exit("Line Amount");

        exit(Round("Line Amount" / (1 + "VAT %" / 100), Currency."Amount Rounding Precision"));
    end;

    procedure GetLineAmountInclVAT(): Decimal
    begin
        if "Document No." = '' then
            exit(0);
        GetSalesHeader();
        if SalesHeader."Prices Including VAT" then
            exit("Line Amount");

        exit(Round("Line Amount" * (1 + "VAT %" / 100), Currency."Amount Rounding Precision"));
    end;

    procedure SetHasBeenShown()
    begin
        HasBeenShown := true;
    end;

    local procedure TestJobPlanningLine()
    var
        JobPostLine: Codeunit "Job Post-Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTestJobPlanningLine(Rec, IsHandled, CurrFieldNo);
        if IsHandled then
            exit;

        if "Job Contract Entry No." = 0 then
            exit;

        JobPostLine.TestSalesLine(Rec);
    end;

    procedure BlockDynamicTracking(SetBlock: Boolean)
    begin
        SalesLineReserve.Block(SetBlock);
    end;

    procedure InitQtyToShip2()
    begin
        "Qty. to Ship" := "Outstanding Quantity" - GetContainerQuantity(''); // P80046533
        "Qty. to Ship (Base)" := UOMMgt.CalcBaseQty("Qty. to Ship", "Qty. per Unit of Measure"); // P80046533
        // P8000611A
        if (Type = Type::Item) and ("No." <> '') and TrackAlternateUnits then
            AltQtyMgmt.InitAlternateQtyToHandle(
              "No.", "Alt. Qty. Transaction No.", "Quantity (Base)", "Qty. to Ship (Base)",
              "Qty. Shipped (Base)", "Quantity (Alt.)", "Qty. Shipped (Alt.)", "Qty. to Ship (Alt.)");
        // P8000611A

        OnAfterInitQtyToShip2(Rec, CurrFieldNo);

        ATOLink.UpdateQtyToAsmFromSalesLine(Rec);

        CheckServItemCreation();

        "Qty. to Invoice" := MaxQtyToInvoice;
        "Qty. to Invoice (Base)" := MaxQtyToInvoiceBase;
        "VAT Difference" := 0;

        // P8000611A
        if TrackAlternateUnits then
            SetSalesLineAltQty;
        // P8000611A

        OnInitQtyToShip2OnBeforeCalcInvDiscToInvoice(Rec, xRec);

        CalcInvDiscToInvoice();

        CalcPrepaymentToDeduct();
    end;

    local procedure UpdateQtyToAsmFromSalesLineQtyToShip()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateQtyToAsmFromSalesLineQtyToShip(Rec, IsHandled);
        if IsHandled then
            exit;

        ATOLink.UpdateQtyToAsmFromSalesLine(Rec);
    end;

    procedure ShowLineComments()
    var
        SalesCommentLine: Record "Sales Comment Line";
        SalesCommentSheet: Page "Sales Comment Sheet";
    begin
        TestField("Document No.");
        TestField("Line No.");
        SalesCommentLine.SetRange("Document Type", "Document Type");
        SalesCommentLine.SetRange("No.", "Document No.");
        SalesCommentLine.SetRange("Document Line No.", "Line No.");
        OnShowLineCommentsOnAfterSetFilters(SalesCommentLine);
        SalesCommentSheet.SetTableView(SalesCommentLine);
        SalesCommentSheet.RunModal();
    end;

    procedure SetDefaultQuantity()
    var
        IsHandled: Boolean;
    Begin
        IsHandled := false;
        OnBeforeSetDefaultQuantity(Rec, IsHandled);
        if IsHandled then
            exit;

        GetSalesSetup();
        if SalesSetup."Default Quantity to Ship" = SalesSetup."Default Quantity to Ship"::Blank then begin
            if ("Document Type" = "Document Type"::Order) or ("Document Type" = "Document Type"::Quote) then begin
                // P8001038
                //"Qty. to Ship" := 0;
                //"Qty. to Ship (Base)" := 0;
                //"Qty. to Ship (Alt.)" := 0; // P8000808
                GetContainerQuantities("Qty. to Ship", "Qty. to Ship (Base)", "Qty. to Ship (Alt.)", false, true); // P80046533
                "Qty. to Invoice" := "Qty. to Ship";
                "Qty. to Invoice (Base)" := "Qty. to Ship (Base)";
                "Qty. to Invoice (Alt.)" := "Qty. to Ship (Alt.)"; // P8000808
                                                                   // P8001038
            end;
            if "Document Type" = "Document Type"::"Return Order" then begin
                // P8001323
                GetContainerQuantities("Return Qty. to Receive", "Return Qty. to Receive (Base)", "Return Qty. to Receive (Alt.)", false, true); // P8004338, P80046533
                "Qty. to Invoice" := "Return Qty. to Receive";
                "Qty. to Invoice (Base)" := "Return Qty. to Receive (Base)";
                "Qty. to Invoice (Alt.)" := "Return Qty. to Receive (Alt.)";
                // P8001323
            end;
        end;

        OnAfterSetDefaultQuantity(Rec, xRec);
    end;

    protected procedure SetReserveWithoutPurchasingCode()
    var
        Item: Record Item;
    begin
        GetItem(Item);
        if Item.Reserve = Item.Reserve::Optional then begin
            GetSalesHeader();
            Reserve := SalesHeader.Reserve;
        end else
            Reserve := Item.Reserve;

        OnAfterSetReserveWithoutPurchasingCode(Rec, SalesHeader, Item);
    end;

    local procedure SetDefaultItemQuantity()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSetDefaultItemQuantity(Rec, IsHandled);
        if IsHandled then
            exit;

        GetSalesSetup();
        if SalesSetup."Default Item Quantity" then begin
            Validate(Quantity, 1);
            CheckItemAvailable(CurrFieldNo);
        end;
    end;

    procedure UpdatePrePaymentAmounts()
    var
        ShipmentLine: Record "Sales Shipment Line";
        SalesOrderLine: Record "Sales Line";
        SalesOrderHeader: Record "Sales Header";
    begin
        if ("Document Type" <> "Document Type"::Invoice) or ("Prepayment %" = 0) then
            exit;

        if not ShipmentLine.Get("Shipment No.", "Shipment Line No.") then begin
            "Prepmt Amt to Deduct" := 0;
            "Prepmt VAT Diff. to Deduct" := 0;
        end else
            if SalesOrderLine.Get(SalesOrderLine."Document Type"::Order, ShipmentLine."Order No.", ShipmentLine."Order Line No.") then begin
                if ("Prepayment %" = 100) and (Quantity <> SalesOrderLine.Quantity - SalesOrderLine."Quantity Invoiced") then
                    "Prepmt Amt to Deduct" := "Line Amount"
                else
                    "Prepmt Amt to Deduct" :=
                      Round((SalesOrderLine."Prepmt. Amt. Inv." - SalesOrderLine."Prepmt Amt Deducted") *
                        Quantity / (SalesOrderLine.Quantity - SalesOrderLine."Quantity Invoiced"), Currency."Amount Rounding Precision");
                "Prepmt VAT Diff. to Deduct" := "Prepayment VAT Difference" - "Prepmt VAT Diff. Deducted";
                SalesOrderHeader.Get(SalesOrderHeader."Document Type"::Order, SalesOrderLine."Document No.");
            end else begin
                "Prepmt Amt to Deduct" := 0;
                "Prepmt VAT Diff. to Deduct" := 0;
            end;

        GetSalesHeader();
        SalesHeader.TestField("Prices Including VAT", SalesOrderHeader."Prices Including VAT");
        if SalesHeader."Prices Including VAT" then begin
            "Prepmt. Amt. Incl. VAT" := "Prepmt Amt to Deduct";
            "Prepayment Amount" :=
              Round(
                "Prepmt Amt to Deduct" / (1 + ("Prepayment VAT %" / 100)),
                Currency."Amount Rounding Precision");
        end else begin
            "Prepmt. Amt. Incl. VAT" :=
              Round(
                "Prepmt Amt to Deduct" * (1 + ("Prepayment VAT %" / 100)),
                Currency."Amount Rounding Precision");
            "Prepayment Amount" := "Prepmt Amt to Deduct";
        end;
        "Prepmt. Line Amount" := "Prepmt Amt to Deduct";
        "Prepmt. Amt. Inv." := "Prepmt. Line Amount";
        "Prepmt. VAT Base Amt." := "Prepayment Amount";
        "Prepmt. Amount Inv. Incl. VAT" := "Prepmt. Amt. Incl. VAT";
        "Prepmt Amt Deducted" := 0;

        OnAfterUpdatePrePaymentAmounts(Rec);
    end;

    procedure ZeroAmountLine(QtyType: Option General,Invoicing,Shipping) Result: Boolean
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeZeroAmountLine(Rec, QtyType, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if not HasTypeToFillMandatoryFields() then
            exit(true);
        if GetPricingQuantity(FieldNo(Quantity), '') = 0 then            // P8006835
            exit(true);
        if "Unit Price" = 0 then
            exit(true);
        if QtyType = QtyType::Invoicing then
            if GetPricingQuantity(FieldNo("Qty. to Invoice"), '') = 0 then // P8006835
                exit(true);
        exit(false);
    end;

    procedure FilterLinesWithItemToPlan(var Item: Record Item; DocumentType: Enum "Sales Document Type")
    begin
        Reset;
        SetCurrentKey("Document Type", Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Shipment Date");
        SetRange("Document Type", DocumentType);
        SetRange(Type, Type::Item);
        SetRange("No.", Item."No.");
        SetFilter("Variant Code", Item.GetFilter("Variant Filter"));
        SetFilter("Location Code", Item.GetFilter("Location Filter"));
        SetFilter("Drop Shipment", Item.GetFilter("Drop Shipment Filter"));
        SetFilter("Shortcut Dimension 1 Code", Item.GetFilter("Global Dimension 1 Filter"));
        SetFilter("Shortcut Dimension 2 Code", Item.GetFilter("Global Dimension 2 Filter"));
        SetFilter("Shipment Date", Item.GetFilter("Date Filter"));
        SetFilter("Outstanding Qty. (Base)", '<>0');
        SetFilter("Unit of Measure Code", Item.GetFilter("Unit of Measure Filter"));

        OnAfterFilterLinesWithItemToPlan(Rec, Item, DocumentType.AsInteger());
    end;

    procedure FindLinesWithItemToPlan(var Item: Record Item; DocumentType: Enum "Sales Document Type"): Boolean
    begin
        FilterLinesWithItemToPlan(Item, DocumentType);
        exit(Find('-'));
    end;

    procedure LinesWithItemToPlanExist(var Item: Record Item; DocumentType: Enum "Sales Document Type"): Boolean
    begin
        FilterLinesWithItemToPlan(Item, DocumentType);
        exit(not IsEmpty);
    end;

    procedure FilterLinesForReservation(ReservationEntry: Record "Reservation Entry"; DocumentType: Enum "Sales Document Type"; AvailabilityFilter: Text; Positive: Boolean)
    begin
        Reset;
        SetCurrentKey(
          "Document Type", Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Shipment Date");
        SetRange("Document Type", DocumentType);
        SetRange(Type, Type::Item);
        SetRange("No.", ReservationEntry."Item No.");
        SetRange("Variant Code", ReservationEntry."Variant Code");
        SetRange("Drop Shipment", false);
        SetRange("Location Code", ReservationEntry."Location Code");
        SetFilter("Shipment Date", AvailabilityFilter);
        if DocumentType = "Document Type"::"Return Order" then
            if Positive then
            SetFilter("Quantity (Base)", '>0')
        else
            SetFilter("Quantity (Base)", '<0')
        else
        if Positive then
            SetFilter("Quantity (Base)", '<0')
        else
            SetFilter("Quantity (Base)", '>0');
        SetRange("Job No.", ' ');

        OnAfterFilterLinesForReservation(Rec, ReservationEntry, DocumentType, AvailabilityFilter, Positive);
    end;

    local procedure DateFormularZero(var DateFormularValue: DateFormula; CalledByFieldNo: Integer; CalledByFieldCaption: Text[250])
    var
        DateFormularZero: DateFormula;
    begin
        Evaluate(DateFormularZero, '<0D>');
        if (DateFormularValue <> DateFormularZero) and (CalledByFieldNo = CurrFieldNo) then
            Error(Text051, CalledByFieldCaption, FieldCaption("Drop Shipment"));
        Evaluate(DateFormularValue, '<0D>');
    end;

    protected procedure InitQtyToAsm()
    var
        ShouldUpdateQtyToAsm: Boolean;
    begin
        OnBeforeInitQtyToAsm(Rec, CurrFieldNo);

        if not IsAsmToOrderAllowed then begin
            "Qty. to Assemble to Order" := 0;
            "Qty. to Asm. to Order (Base)" := 0;
            exit;
        end;

        ShouldUpdateQtyToAsm := ((xRec."Qty. to Asm. to Order (Base)" = 0) and IsAsmToOrderRequired and ("Qty. Shipped (Base)" = 0)) or
           ((xRec."Qty. to Asm. to Order (Base)" <> 0) and
            (xRec."Qty. to Asm. to Order (Base)" = xRec."Quantity (Base)")) or
           ("Qty. to Asm. to Order (Base)" > "Quantity (Base)");
        OnInitQtyToAsmOnAfterCalcShouldUpdateQtyToAsm(Rec, CurrFieldNo, xRec, ShouldUpdateQtyToAsm);
        if ShouldUpdateQtyToAsm then begin
            "Qty. to Assemble to Order" := Quantity;
            "Qty. to Asm. to Order (Base)" := "Quantity (Base)";
        end;

        OnAfterInitQtyToAsm(Rec, CurrFieldNo, xRec);
    end;

    procedure AsmToOrderExists(var AsmHeader: Record "Assembly Header"): Boolean
    var
        ATOLink: Record "Assemble-to-Order Link";
    begin
        if not ATOLink.AsmExistsForSalesLine(Rec) then
            exit(false);
        exit(AsmHeader.Get(ATOLink."Assembly Document Type", ATOLink."Assembly Document No."));
    end;

    procedure FullQtyIsForAsmToOrder(): Boolean
    begin
        if "Qty. to Asm. to Order (Base)" = 0 then
            exit(false);
        exit("Quantity (Base)" = "Qty. to Asm. to Order (Base)");
    end;

    local procedure FullReservedQtyIsForAsmToOrder(): Boolean
    begin
        if "Qty. to Asm. to Order (Base)" = 0 then
            exit(false);
        CalcFields("Reserved Qty. (Base)");
        exit("Reserved Qty. (Base)" = "Qty. to Asm. to Order (Base)");
    end;

    procedure QtyBaseOnATO(): Decimal
    var
        AsmHeader: Record "Assembly Header";
    begin
        if AsmToOrderExists(AsmHeader) then
            exit(AsmHeader."Quantity (Base)");
        exit(0);
    end;

    procedure QtyAsmRemainingBaseOnATO(): Decimal
    var
        AsmHeader: Record "Assembly Header";
    begin
        if AsmToOrderExists(AsmHeader) then
            exit(AsmHeader."Remaining Quantity (Base)");
        exit(0);
    end;

    procedure QtyToAsmBaseOnATO(): Decimal
    var
        AsmHeader: Record "Assembly Header";
    begin
        if AsmToOrderExists(AsmHeader) then
            exit(AsmHeader."Quantity to Assemble (Base)");
        exit(0);
    end;

    procedure IsAsmToOrderAllowed(): Boolean
    begin
        if not ("Document Type" in ["Document Type"::Quote, "Document Type"::"Blanket Order", "Document Type"::Order]) then
            exit(false);
        if Quantity < 0 then
            exit(false);
        if Type <> Type::Item then
            exit(false);
        if "No." = '' then
            exit(false);
        if "Drop Shipment" or "Special Order" then
            exit(false);
        exit(true)
    end;

    procedure IsAsmToOrderRequired(): Boolean
    var
        Item: Record Item;
        Result: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        Result := false;
        OnBeforeIsAsmToOrderRequired(Rec, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if (Type <> Type::Item) or ("No." = '') then
            exit(false);
        GetItem(Item);
        if GetSKU then
            exit(SKU."Assembly Policy" = SKU."Assembly Policy"::"Assemble-to-Order");
        exit(Item."Assembly Policy" = Item."Assembly Policy"::"Assemble-to-Order");
    end;

    procedure CheckAsmToOrder(AsmHeader: Record "Assembly Header")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckAsmToOrder(Rec, AsmHeader, IsHandled);
        if IsHandled then
            exit;

        TestField("Qty. to Assemble to Order", AsmHeader.Quantity);
        TestField("Document Type", AsmHeader."Document Type");
        TestField(Type, Type::Item);
        TestField("No.", AsmHeader."Item No.");
        TestField("Location Code", AsmHeader."Location Code");
        TestField("Unit of Measure Code", AsmHeader."Unit of Measure Code");
        TestField("Variant Code", AsmHeader."Variant Code");
        TestField("Shipment Date", AsmHeader."Due Date");
        if "Document Type" = "Document Type"::Order then begin
            AsmHeader.CalcFields("Reserved Qty. (Base)");
            AsmHeader.TestField("Reserved Qty. (Base)", AsmHeader."Remaining Quantity (Base)");
        end;
        TestField("Qty. to Asm. to Order (Base)", AsmHeader."Quantity (Base)");
        if "Outstanding Qty. (Base)" < AsmHeader."Remaining Quantity (Base)" then
            AsmHeader.FieldError("Remaining Quantity (Base)", StrSubstNo(Text045, AsmHeader."Remaining Quantity (Base)"));
    end;

    procedure ShowAsmToOrderLines()
    var
        ATOLink: Record "Assemble-to-Order Link";
    begin
        ATOLink.ShowAsmToOrderLines(Rec);
    end;

    [Obsolete('Replaced by FindOpenATOEntry() with parameter ItemTrackingSetup.', '17.0')]
    procedure FindOpenATOEntry(LotNo: Code[50]; SerialNo: Code[50]): Integer
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
    begin
        ItemTrackingSetup."Serial No." := SerialNo;
        ItemTrackingSetup."Lot No." := LotNo;
        exit(FindOpenATOEntry(ItemTrackingSetup));
    end;

    procedure FindOpenATOEntry(ItemTrackingSetup: Record "Item Tracking Setup"): Integer
    var
        PostedATOLink: Record "Posted Assemble-to-Order Link";
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        TestField("Document Type", "Document Type"::Order);
        if PostedATOLink.FindLinksFromSalesLine(Rec) then
            repeat
                ItemLedgEntry.SetRange("Document Type", ItemLedgEntry."Document Type"::"Posted Assembly");
                ItemLedgEntry.SetRange("Document No.", PostedATOLink."Assembly Document No.");
                ItemLedgEntry.SetRange("Document Line No.", 0);
                ItemLedgEntry.SetTrackingFilterFromItemTrackingSetupIfNotBlank(ItemTrackingSetup);
                ItemLedgEntry.SetRange(Open, true);
                if ItemLedgEntry.FindFirst() then
                    exit(ItemLedgEntry."Entry No.");
            until PostedATOLink.Next() = 0;
    end;

    procedure RollUpAsmCost()
    begin
        ATOLink.RollUpCost(Rec);
    end;

    procedure RollupAsmPrice()
    begin
        GetSalesHeader();
        ATOLink.RollUpPrice(SalesHeader, Rec);
    end;

    procedure UpdateICPartner()
    var
        ICPartner: Record "IC Partner";
    begin
        if SalesHeader."Send IC Document" and
           (SalesHeader."IC Direction" = SalesHeader."IC Direction"::Outgoing) and
           (SalesHeader."Bill-to IC Partner Code" <> '')
        then
            case Type of
                Type::" ", Type::"Charge (Item)":
                    begin
                        "IC Partner Ref. Type" := Type;
                        "IC Partner Reference" := "No.";
                    end;
                Type::"G/L Account":
                    begin
                        "IC Partner Ref. Type" := Type;
                        "IC Partner Reference" := GLAcc."Default IC Partner G/L Acc. No";
                    end;
                Type::Item:
                    begin
                        if SalesHeader."Sell-to IC Partner Code" <> '' then
                            ICPartner.Get(SalesHeader."Sell-to IC Partner Code")
                        else
                            ICPartner.Get(SalesHeader."Bill-to IC Partner Code");
                        case ICPartner."Outbound Sales Item No. Type" of
                            ICPartner."Outbound Sales Item No. Type"::"Common Item No.":
                                Validate("IC Partner Ref. Type", "IC Partner Ref. Type"::"Common Item No.");
                            ICPartner."Outbound Sales Item No. Type"::"Internal No.":
                                begin
                                    Validate("IC Partner Ref. Type", "IC Partner Ref. Type"::Item);
                                    "IC Partner Reference" := "No.";
                                end;
                            ICPartner."Outbound Sales Item No. Type"::"Cross Reference":
                                begin
                                    Validate("IC Partner Ref. Type", "IC Partner Ref. Type"::"Cross Reference");
                                    UpdateICPartnerItemReference();
                                end;
                        end;
                    end;
                Type::"Fixed Asset":
                    begin
                        "IC Partner Ref. Type" := "IC Partner Ref. Type"::" ";
                        "IC Partner Reference" := '';
                    end;
                Type::Resource:
                    begin
                        Resource.Get("No.");
                        "IC Partner Ref. Type" := "IC Partner Ref. Type"::"G/L Account";
                        "IC Partner Reference" := Resource."IC Partner Purch. G/L Acc. No.";
                    end;
            end;
        OnAfterUpdateICPartner(Rec, SalesHeader);
    end;

    local procedure UpdateICPartnerItemReference()
    var
        ItemReference: Record "Item Reference";
    begin
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::Customer);
        ItemReference.SetRange("Reference Type No.", "Sell-to Customer No.");
        ItemReference.SetRange("Item No.", "No.");
        ItemReference.SetRange("Variant Code", "Variant Code");
        ItemReference.SetRange("Unit of Measure", "Unit of Measure Code");
        if ItemReference.FindFirst() then
            "IC Item Reference No." := ItemReference."Reference No."
        else
            "IC Partner Reference" := "No.";
    end;

    procedure OutstandingInvoiceAmountFromShipment(SellToCustomerNo: Code[20]): Decimal
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetCurrentKey("Document Type", "Sell-to Customer No.", "Shipment No.");
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Invoice);
        SalesLine.SetRange("Sell-to Customer No.", SellToCustomerNo);
        SalesLine.SetFilter("Shipment No.", '<>%1', '');
        SalesLine.CalcSums("Outstanding Amount (LCY)");
        exit(SalesLine."Outstanding Amount (LCY)");
    end;

    local procedure CheckShipmentRelation()
    var
        SalesShptLine: Record "Sales Shipment Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckShipmentRelation(IsHandled, Rec);
        if IsHandled then
            exit;

        SalesShptLine.Get("Shipment No.", "Shipment Line No.");
        if (Quantity * SalesShptLine."Qty. Shipped Not Invoiced") < 0 then
            FieldError("Qty. to Invoice", Text057);
        if Abs(Quantity) > Abs(SalesShptLine."Qty. Shipped Not Invoiced") then
            Error(Text058, SalesShptLine."Document No.");

        OnAfterCheckShipmentRelation(Rec, SalesShptLine);
    end;

    local procedure CheckShipmentDateBeforeWorkDate()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckShipmentDateBeforeWorkDate(Rec, xRec, HasBeenShown, IsHandled);
        if IsHandled then
            exit;

        if ("Shipment Date" < WorkDate) and HasTypeToFillMandatoryFields() then
            if not (GetHideValidationDialog or HasBeenShown) and GuiAllowed and (CurrFieldNo <> 0) then begin // PR3.70
                Message(
                  Text014,
                  FieldCaption("Shipment Date"), "Shipment Date", WorkDate);
                HasBeenShown := true;
            end;
    end;

    local procedure CheckRetRcptRelation()
    var
        ReturnRcptLine: Record "Return Receipt Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckRetRcptRelation(IsHandled, Rec);
        if IsHandled then
            exit;

        ReturnRcptLine.Get("Return Receipt No.", "Return Receipt Line No.");
        if (Quantity * (ReturnRcptLine.Quantity - ReturnRcptLine."Quantity Invoiced")) < 0 then
            FieldError("Qty. to Invoice", Text059);
        if Abs(Quantity) > Abs(ReturnRcptLine.Quantity - ReturnRcptLine."Quantity Invoiced") then
            Error(Text060, ReturnRcptLine."Document No.");

        OnAfterCheckRetRcptRelation(Rec, ReturnRcptLine);
    end;

    local procedure VerifyItemLineDim()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeVerifyItemLineDim(Rec, IsHandled);
        if IsHandled then
            exit;

        if IsShippedReceivedItemDimChanged then
            ConfirmShippedReceivedItemDimChange;
    end;

    procedure IsShippedReceivedItemDimChanged(): Boolean
    begin
        exit(("Dimension Set ID" <> xRec."Dimension Set ID") and (Type = Type::Item) and
          (("Qty. Shipped Not Invoiced" <> 0) or ("Return Rcd. Not Invd." <> 0)));
    end;

    procedure IsServiceChargeLine(): Boolean
    var
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        if Type <> Type::"G/L Account" then
            exit(false);

        GetSalesHeader();
        CustomerPostingGroup.Get(SalesHeader."Customer Posting Group");
        exit(CustomerPostingGroup."Service Charge Acc." = "No.");
    end;

    procedure ConfirmShippedReceivedItemDimChange(): Boolean
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(Text053, TableCaption), true) then
            Error(Text054);

        exit(true);
    end;

    procedure InitType()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitType(Rec, xRec, IsHandled, SalesHeader);
        if IsHandled then
            exit;

        if "Document No." <> '' then begin
            if not SalesHeader.Get("Document Type", "Document No.") then
                exit;
            if (SalesHeader.Status = SalesHeader.Status::Released) and
               (xRec.Type in [xRec.Type::Item, xRec.Type::"Fixed Asset"])
            then
                Type := Type::" "
            else
                Type := xRec.Type;
        end;

        OnAfterInitType(Rec, xRec, SalesHeader);
    end;

    procedure GetDefaultLineType(): Enum "Sales Line Type"
    begin
        GetSalesSetup();
        if SalesSetup."Document Default Line Type" <> SalesSetup."Document Default Line Type"::" " then
            exit(SalesSetup."Document Default Line Type");
    end;

    procedure CalcSalesTaxLines(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        TaxArea: Record "Tax Area";
    begin
        if SalesHeader."Tax Area Code" = '' then
            exit;
        TaxArea.Get(SalesHeader."Tax Area Code");
        SalesTaxCalculate.StartSalesTaxCalculation; // clear temp table

        if TaxArea."Use External Tax Engine" then
            SalesTaxCalculate.CallExternalTaxEngineForSales(SalesHeader, true)
        else begin
            with SalesLine do begin
                SetRange("Document Type", SalesHeader."Document Type");
                SetRange("Document No.", SalesHeader."No.");
                SetFilter(Type, '<>0');
                SetFilter("Tax Group Code", '<>%1', '');
                SalesTaxCalculate.SetTmpSalesHeader(SalesHeader);
                if FindSet() then
                    repeat
                        SalesTaxCalculate.AddSalesLine(SalesLine);
                    until Next() = 0;
            end;
            SalesTaxCalculate.EndSalesTaxCalculation(SalesHeader."Posting Date");
        end;
        SalesLine2.CopyFilters(SalesLine);
        SalesLine.SetSalesHeader(SalesHeader);
        SalesTaxCalculate.DistTaxOverSalesLines(SalesLine);
        SalesLine.CopyFilters(SalesLine2);
    end;

    local procedure CheckWMS()
    begin
        if CurrFieldNo <> 0 then
            CheckLocationOnWMS;
    end;

    procedure CheckLocationOnWMS()
    var
        DialogText: Text;
    begin
        if (Type = Type::Item) and IsInventoriableItem() then begin
            DialogText := Text035;
            if "Quantity (Base)" <> 0 then
                case "Document Type" of
                    "Document Type"::Invoice:
                        if "Shipment No." = '' then
                            if Location.Get("Location Code") and Location."Directed Put-away and Pick" then begin
                                DialogText += Location.GetRequirementText(Location.FieldNo("Require Shipment"));
                                Error(Text016, DialogText, FieldCaption("Line No."), "Line No.");
                            end;
                    "Document Type"::"Credit Memo":
                        if "Return Receipt No." = '' then
                            if Location.Get("Location Code") and Location."Directed Put-away and Pick" then begin
                                DialogText += Location.GetRequirementText(Location.FieldNo("Require Receive"));
                                Error(Text016, DialogText, FieldCaption("Line No."), "Line No.");
                            end;
                end;
        end;
    end;

    local procedure CheckRetentionAttachedToLineNo()
    begin
        if Quantity >= 0 then
            TestField("Retention Attached to Line No.", 0);
    end;

    procedure IsNonInventoriableItem(): Boolean
    var
        Item: Record Item;
    begin
        if Type <> Type::Item then
            exit(false);
        if "No." = '' then
            exit(false);
        GetItem(Item);
        exit(Item.IsNonInventoriableType());
    end;

    procedure IsInventoriableItem(): Boolean
    var
        Item: Record Item;
    begin
        if Type <> Type::Item then
            exit(false);
        if "No." = '' then
            exit(false);
        GetItem(Item);
        exit(Item.IsInventoriableType());
    end;

    procedure CalcAmountIncludingTax(BaseAmount: Decimal): Decimal
    begin
        GetSalesHeader;
        exit(Round(BaseAmount * (1 + "VAT %" / 100), Currency."Amount Rounding Precision"));
    end;

    procedure GetJnlTemplateName(): Code[10]
    begin
        GLSetup.Get();
        if not GLSetup."Journal Templ. Name Mandatory" then
            exit('');

        if "IC Partner Code" = '' then begin
            GetSalesHeader();
            exit(SalesHeader."Journal Templ. Name");
        end;

        GetSalesSetup();
        if IsCreditDocType() then begin
            SalesSetup.TestField("IC Sales Cr. Memo Templ. Name");
            exit(SalesSetup."IC Sales Cr. Memo Templ. Name");
        end;
        SalesSetup.TestField("IC Sales Invoice Template Name");
        exit(SalesSetup."IC Sales Invoice Template Name");
    end;

    procedure ValidateReturnReasonCode(CallingFieldNo: Integer)
    var
        ReturnReason: Record "Return Reason";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeValidateReturnReasonCode(Rec, CallingFieldNo, IsHandled);
        if IsHandled then
            exit;

        if CallingFieldNo = 0 then
            exit;
        if "Return Reason Code" = '' then begin
            if (Type = Type::Item) and ("No." <> '') then
                GetUnitCost();
            PlanPriceCalcByField(CallingFieldNo);
        end;

        if ReturnReason.Get("Return Reason Code") then begin
            if (CallingFieldNo <> FieldNo("Location Code")) and (ReturnReason."Default Location Code" <> '') then
                Validate("Location Code", ReturnReason."Default Location Code");
            if ReturnReason."Inventory Value Zero" then
                Validate("Unit Cost (LCY)", 0)
            else
                if "Unit Price" = 0 then
                    PlanPriceCalcByField(CallingFieldNo);
        end;
        UpdateUnitPriceByField(CallingFieldNo);

        OnAfterValidateReturnReasonCode(Rec, CallingFieldNo);
    end;

    [Scope('OnPrem')]
    procedure ValidateLineDiscountPercent(DropInvoiceDiscountAmount: Boolean)
    begin
        TestJobPlanningLine();
        TestStatusOpen();
        OnValidateLineDiscountPercentOnAfterTestStatusOpen(Rec, xRec, CurrFieldNo);
        /*P8000440A
        "Line Discount Amount" :=
          Round(
            Round(Quantity * "Unit Price", Currency."Amount Rounding Precision") *
            "Line Discount %" / 100, Currency."Amount Rounding Precision");
        if DropInvoiceDiscountAmount then begin
            "Inv. Discount Amount" := 0;
            "Inv. Disc. Amount to Invoice" := 0;
        end;
        OnValidateLineDiscountPercentOnBeforeUpdateAmounts(Rec, CurrFieldNo);
        UpdateAmounts();
        P8000440A*/
        // P8000440A
        if CurrFieldNo = FieldNo("Line Discount %") then
            "Line Discount Type" := "Line Discount Type"::Percent;
        CalcLineDiscount(DropInvoiceDiscountAmount);  // P80073095
                                                      // P8000440A

        // PR3.70.03
        if ProcessFns.AccrualsInstalled() then
            AccrualMgmt.SalesRecalcLines(Rec); // P8000044A
        // PR3.70.03

        OnAfterValidateLineDiscountPercent(Rec, CurrFieldNo);
    end;

    local procedure ValidateVATProdPostingGroup()
    var
        IsHandled: boolean;
    begin
        IsHandled := false;
        OnBeforeValidateVATProdPostingGroup(IsHandled, Rec);
        if IsHandled then
            exit;

        Validate("VAT Prod. Posting Group");
    end;

    local procedure ValidateUnitOfMeasureCodeFromNo()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeValidateUnitOfMeasureCodeFromNo(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        Validate("Unit of Measure Code");
    end;

    local procedure NotifyOnMissingSetup(FieldNumber: Integer)
    var
        DiscountNotificationMgt: Codeunit "Discount Notification Mgt.";
    begin
        if CurrFieldNo = 0 then
            exit;
        GetSalesSetup();
        DiscountNotificationMgt.RecallNotification(SalesSetup.RecordId);
        if (FieldNumber = FieldNo("Line Discount Amount")) and ("Line Discount Amount" = 0) then
            exit;
        DiscountNotificationMgt.NotifyAboutMissingSetup(
          SalesSetup.RecordId, "Gen. Bus. Posting Group", "Gen. Prod. Posting Group",
          SalesSetup."Discount Posting", SalesSetup."Discount Posting"::"Invoice Discounts");
    end;

    procedure HasTypeToFillMandatoryFields() ReturnValue: Boolean
    begin
        ReturnValue := Type <> Type::" ";

        OnAfterHasTypeToFillMandatoryFields(Rec, ReturnValue);
    end;

    procedure GetDeferralAmount() DeferralAmount: Decimal
    var
        TempSalesLine: Record "Sales Line" temporary;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetDeferralAmount(Rec, IsHandled, DeferralAmount);
        if IsHandled then
            exit;

        if "Tax Liable" and ("Tax Area Code" <> '') and ("VAT Calculation Type" = "VAT Calculation Type"::"Sales Tax") then begin
            TempSalesLine := Rec;
            TempSalesLine.Insert();
            CalcSalesTaxLines(SalesHeader, TempSalesLine);
            exit(Amount + (TempSalesLine."Amount Including VAT" - "Amount Including VAT"));
        end;

        exit(CalcLineAmount);
    end;

    procedure UpdateDeferralAmounts()
    var
        AdjustStartDate: Boolean;
        DeferralPostDate: Date;
    begin
        GetSalesHeader();
        OnGetDeferralPostDate(SalesHeader, DeferralPostDate, Rec);
        if DeferralPostDate = 0D then
            DeferralPostDate := SalesHeader."Posting Date";
        AdjustStartDate := true;
        if "Document Type" = "Document Type"::"Return Order" then begin
            if "Returns Deferral Start Date" = 0D then
                "Returns Deferral Start Date" := SalesHeader."Posting Date";
            DeferralPostDate := "Returns Deferral Start Date";
            AdjustStartDate := false;
        end;

        DeferralUtilities.RemoveOrSetDeferralSchedule(
            "Deferral Code", "Deferral Document Type"::Sales.AsInteger(), '', '',
            "Document Type".AsInteger(), "Document No.", "Line No.",
            GetDeferralAmount(), DeferralPostDate, Description, SalesHeader."Currency Code", AdjustStartDate);
    end;

    procedure UpdatePriceDescription()
    var
        Currency: Record Currency;
    begin
        "Price description" := '';
        if Type in [Type::"Charge (Item)", Type::"Fixed Asset", Type::Item, Type::Resource] then begin
            if "Line Discount %" = 0 then
                "Price description" := StrSubstNo(
                    PriceDescriptionTxt, Quantity, Currency.ResolveGLCurrencySymbol("Currency Code"),
                    "Unit Price", "Unit of Measure")
            else
                "Price description" := StrSubstNo(
                    PriceDescriptionWithLineDiscountTxt, Quantity, Currency.ResolveGLCurrencySymbol("Currency Code"),
                    "Unit Price", "Unit of Measure", "Line Discount %")
        end;
    end;

    local procedure UpdateVATPercent(BaseAmount: Decimal; VATAmount: Decimal)
    begin
        if BaseAmount <> 0 then
            "VAT %" := Round(100 * VATAmount / BaseAmount, 0.00001)
        else
            "VAT %" := 0;
    end;

    procedure ShowDeferrals(PostingDate: Date; CurrencyCode: Code[10]) ReturnValue: Boolean
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeShowDeferrals(Rec, ReturnValue, IsHandled);
        if IsHandled then
            exit(ReturnValue);

        exit(
            DeferralUtilities.OpenLineScheduleEdit(
                "Deferral Code", "Deferral Document Type"::Sales.AsInteger(), '', '',
                "Document Type".AsInteger(), "Document No.", "Line No.",
                GetDeferralAmount(), PostingDate, Description, CurrencyCode));
    end;

    local procedure InitHeaderDefaults(SalesHeader: Record "Sales Header")
    begin

        if SalesHeader."Document Type" = SalesHeader."Document Type"::Quote then
            CheckQuoteCustomerTemplateCode(SalesHeader)
        else
            SalesHeader.TestField("Sell-to Customer No.");

        "Sell-to Customer No." := SalesHeader."Sell-to Customer No.";
        "Currency Code" := SalesHeader."Currency Code";
        InitHeaderLocactionCode(SalesHeader);
        "Customer Price Group" := SalesHeader."Customer Price Group";
        "Customer Disc. Group" := SalesHeader."Customer Disc. Group";
        "Allow Line Disc." := SalesHeader."Allow Line Disc.";
        "Transaction Type" := SalesHeader."Transaction Type";
        "Transport Method" := SalesHeader."Transport Method";
        "Bill-to Customer No." := SalesHeader."Bill-to Customer No.";
        "Price Calculation Method" := SalesHeader."Price Calculation Method";
        "Gen. Bus. Posting Group" := SalesHeader."Gen. Bus. Posting Group";
        "VAT Bus. Posting Group" := SalesHeader."VAT Bus. Posting Group";
        "Exit Point" := SalesHeader."Exit Point";
        Area := SalesHeader.Area;
        "Transaction Specification" := SalesHeader."Transaction Specification";
        "Tax Area Code" := SalesHeader."Tax Area Code";
        "Tax Liable" := SalesHeader."Tax Liable";
        if not "System-Created Entry" and ("Document Type" = "Document Type"::Order) and HasTypeToFillMandatoryFields() or
           IsServiceChargeLine()
        then
            "Prepayment %" := SalesHeader."Prepayment %";
        "Prepayment Tax Area Code" := SalesHeader."Tax Area Code";
        "Prepayment Tax Liable" := SalesHeader."Tax Liable";
        "Responsibility Center" := SalesHeader."Responsibility Center";

        "Shipping Agent Code" := SalesHeader."Shipping Agent Code";
        "Shipping Agent Service Code" := SalesHeader."Shipping Agent Service Code";
        "Outbound Whse. Handling Time" := SalesHeader."Outbound Whse. Handling Time";
        "Shipping Time" := SalesHeader."Shipping Time";

        OnAfterInitHeaderDefaults(Rec, SalesHeader, xRec);
    end;

    local procedure InitHeaderLocactionCode(SalesHeader: Record "Sales Header")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitHeaderLocactionCode(Rec, IsHandled);
        if IsHandled then
            exit;
#if not CLEAN20
        IsHandled := false;
        OnBeforeUpdateLocationCode(Rec, IsHandled);
        if not IsHandled then
#endif
        "Location Code" := SalesHeader."Location Code";
    end;

    local procedure InitDeferralCode()
    var
        Item: Record Item;
    begin
        if "Document Type" in
           ["Document Type"::Order, "Document Type"::Invoice, "Document Type"::"Credit Memo", "Document Type"::"Return Order"]
        then
            case Type of
                Type::"G/L Account":
                    Validate("Deferral Code", GLAcc."Default Deferral Template Code");
                Type::Item:
                    begin
                        GetItem(Item);
                        Validate("Deferral Code", Item."Default Deferral Template Code");
                    end;
                Type::Resource:
                    Validate("Deferral Code", Res."Default Deferral Template Code");
            end;
    end;

    procedure DefaultDeferralCode()
    var
        Item: Record Item;
    begin
        case Type of
            Type::"G/L Account":
                begin
                    GLAcc.Get("No.");
                    InitDeferralCode();
                end;
            Type::Item:
                begin
                    GetItem(Item);
                    InitDeferralCode();
                end;
            Type::Resource:
                begin
                    Res.Get("No.");
                    InitDeferralCode();
                end;
        end;
    end;

    procedure IsCreditDocType() CreditDocType: Boolean
    begin
        CreditDocType := "Document Type" in ["Document Type"::"Return Order", "Document Type"::"Credit Memo"];
        OnAfterIsCreditDocType(Rec, CreditDocType);
    end;

    local procedure IsFullyInvoiced(): Boolean
    begin
        exit(("Qty. Shipped Not Invd. (Base)" = 0) and ("Qty. Shipped (Base)" = "Quantity (Base)"))
    end;

    local procedure CleanDropShipmentFields()
    begin
        if ("Purch. Order Line No." <> 0) and IsFullyInvoiced then
            if CleanPurchaseLineDropShipmentFields then begin
                "Purchase Order No." := '';
                "Purch. Order Line No." := 0;
            end;
    end;

    local procedure CleanSpecialOrderFieldsAndCheckAssocPurchOrder()
    begin
        OnBeforeCleanSpecialOrderFieldsAndCheckAssocPurchOrder(Rec);

        if ("Special Order Purch. Line No." <> 0) and IsFullyInvoiced then
            if CleanPurchaseLineSpecialOrderFields then begin
                "Special Order Purchase No." := '';
                "Special Order Purch. Line No." := 0;
            end;

        CheckAssocPurchOrder('');
    end;

    local procedure CleanPurchaseLineDropShipmentFields(): Boolean
    var
        PurchaseLine: Record "Purchase Line";
    begin
        if PurchaseLine.Get(PurchaseLine."Document Type"::Order, "Purchase Order No.", "Purch. Order Line No.") then begin
            if PurchaseLine."Qty. Received (Base)" < "Qty. Shipped (Base)" then
                exit(false);

            PurchaseLine."Sales Order No." := '';
            PurchaseLine."Sales Order Line No." := 0;
            PurchaseLine.Modify();
        end;

        exit(true);
    end;

    local procedure CleanPurchaseLineSpecialOrderFields() Result: Boolean
    var
        PurchaseLine: Record "Purchase Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCleanPurchaseLineSpecialOrderFields(Rec, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if PurchaseLine.Get(PurchaseLine."Document Type"::Order, "Special Order Purchase No.", "Special Order Purch. Line No.") then begin
            if PurchaseLine."Qty. Received (Base)" < "Qty. Shipped (Base)" then
                exit(false);

            PurchaseLine."Special Order" := false;
            PurchaseLine."Special Order Sales No." := '';
            PurchaseLine."Special Order Sales Line No." := 0;
            PurchaseLine.Modify();
        end;

        exit(true);
    end;

    procedure CanEditUnitOfMeasureCode(): Boolean
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        if (Type = Type::Item) and ("No." <> '') then begin
            ItemUnitOfMeasure.SetRange("Item No.", "No.");
            exit(ItemUnitOfMeasure.Count > 1);
        end;
        exit(true);
    end;

    local procedure ValidateTaxGroupCode()
    var
        TaxDetail: Record "Tax Detail";
    begin
        if ("Tax Area Code" <> '') and ("Tax Group Code" <> '') then
            TaxDetail.ValidateTaxSetup("Tax Area Code", "Tax Group Code", "Posting Date");
    end;

    procedure InsertFreightLine(var FreightAmount: Decimal)
    var
        SalesLine: Record "Sales Line";
        FreightAmountQuantity: Integer;
    begin
        if FreightAmount <= 0 then begin
            FreightAmount := 0;
            exit;
        end;

        FreightAmountQuantity := 1;

        SalesSetup.Get();
        SalesSetup.TestField("Freight G/L Acc. No.");

        TestField("Document No.");
        OnInsertFreightLineOnAfterCheckDocumentNo(SalesLine, Rec);

        SalesLine.SetRange("Document Type", "Document Type");
        SalesLine.SetRange("Document No.", "Document No.");
        SalesLine.SetRange(Type, SalesLine.Type::"G/L Account");
        SalesLine.SetRange("No.", SalesSetup."Freight G/L Acc. No.");
        // "Quantity Shipped" will be equal to 0 until FreightAmount line successfully shipped
        SalesLine.SetRange("Quantity Shipped", 0);
        if SalesLine.FindFirst() then begin
            SalesLine.Validate(Quantity, FreightAmountQuantity);
            SalesLine.Validate("Unit Price", FreightAmount);
            SalesLine.Modify();
        end else begin
            SalesLine.SetRange(Type);
            SalesLine.SetRange("No.");
            SalesLine.SetRange("Quantity Shipped");
            SalesLine.FindLast();
            SalesLine."Line No." += 10000;
            SalesLine.Init();
            SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
            SalesLine.Validate("No.", SalesSetup."Freight G/L Acc. No.");
            SalesLine.Validate(Description, FreightLineDescriptionTxt);
            SalesLine.Validate(Quantity, FreightAmountQuantity);
            SalesLine.Validate("Unit Price", FreightAmount);
            SalesLine.Insert();
        end;
    end;

    local procedure CalcTotalAmtToAssign(TotalQtyToAssign: Decimal) TotalAmtToAssign: Decimal
    begin
        TotalAmtToAssign := CalcLineAmount * TotalQtyToAssign / Quantity;
        if SalesHeader."Prices Including VAT" then
            TotalAmtToAssign := TotalAmtToAssign / (1 + "VAT %" / 100) - "VAT Difference";

        TotalAmtToAssign := Round(TotalAmtToAssign, Currency."Amount Rounding Precision");
    end;

    procedure IsLookupRequested() Result: Boolean
    begin
        Result := LookupRequested;
        LookupRequested := false;
    end;

    procedure TestItemFields(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10])
    begin
        TestField(Type, Type::Item);
        TestField("No.", ItemNo);
        TestField("Variant Code", VariantCode);
        TestField("Location Code", LocationCode);
    end;

    procedure CalculateNotShippedInvExlcVatLCY()
    var
        Currency2: Record Currency;
    begin
        Currency2.InitRoundingPrecision();
        "Shipped Not Inv. (LCY) No VAT" :=
          Round("Shipped Not Invoiced (LCY)" / (1 + "VAT %" / 100), Currency2."Amount Rounding Precision");
    end;

    procedure ClearSalesHeader()
    begin
        Clear(SalesHeader);
    end;

    local procedure GetBlockedItemNotificationID(): Guid
    begin
        exit('963A9FD3-11E8-4CAA-BE3A-7F8CEC9EF8EC');
    end;

    local procedure SendBlockedItemNotification()
    var
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        NotificationToSend: Notification;
    begin
        NotificationToSend.Id := GetBlockedItemNotificationID();
        NotificationToSend.Recall();
        NotificationToSend.Message := StrSubstNo(BlockedItemNotificationMsg, "No.");
        NotificationLifecycleMgt.SendNotification(NotificationToSend, RecordId);
    end;

    procedure SendLineInvoiceDiscountResetNotification()
    var
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        NotificationToSend: Notification;
    begin
        if ("Inv. Discount Amount" = 0) and (xRec."Inv. Discount Amount" <> 0) and ("Line Amount" <> 0) then begin
            NotificationToSend.Id := SalesHeader.GetLineInvoiceDiscountResetNotificationId();
            NotificationToSend.Message := StrSubstNo(LineInvoiceDiscountAmountResetTok, RecordId);

            NotificationLifecycleMgt.SendNotification(NotificationToSend, RecordId);
        end;
    end;

    procedure GetDocumentTypeDescription(): Text
    begin
        exit(Format("Document Type"));
    end;

    [Scope('OnPrem')]
    procedure GetPrepaidSalesAmountInclVAT(): Decimal
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        SalesInvoiceLine.SetRange("Order No.", "Document No.");
        SalesInvoiceLine.SetRange("Order Line No.", "Line No.");
        SalesInvoiceLine.CalcSums("Amount Including VAT");
        exit(SalesInvoiceLine."Amount Including VAT");
    end;

    procedure FormatType() FormattedType: Text[20]
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeFormatType(Rec, FormattedType, IsHandled);
        if IsHandled then
            EXIT(FormattedType);

        if Type = Type::" " then
            exit(CommentLbl);

        exit(Format(Type));
    end;

    procedure RenameNo(LineType: Enum "Sales Line Type"; OldNo: Code[20]; NewNo: Code[20])
    begin
        Reset;
        SetRange(Type, LineType);
        SetRange("No.", OldNo);
        if not Rec.IsEmpty() then
            ModifyAll("No.", NewNo, true);
    end;

    procedure UpdatePlanned(): Boolean
    begin
        TestField("Qty. per Unit of Measure");
        CalcFields("Reserved Quantity");
        if Planned = ("Reserved Quantity" = "Outstanding Quantity") then
            exit(false);
        Planned := not Planned;
        exit(true);
    end;

    procedure AssignedItemCharge(): Boolean
    begin
        exit((Type = Type::"Charge (Item)") and ("No." <> '') and ("Qty. to Assign" < Quantity));
    end;

    local procedure UpdateLineDiscPct()
    var
        LineDiscountPct: Decimal;
        IsHandled: Boolean;
        IsOutOfStandardDiscPctRange: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateLineDiscPct(Rec, IsHandled, Currency);
        if IsHandled then
            exit;

        if Round(Quantity * "Unit Price", Currency."Amount Rounding Precision") <> 0 then begin
            LineDiscountPct := Round(
                "Line Discount Amount" / Round(GetPricingQty * "Unit Price", Currency."Amount Rounding Precision") * 100, // P80066030
                0.00001);
            IsOutOfStandardDiscPctRange := not (LineDiscountPct in [0 .. 100]);
            OnUpdateLineDiscPctOnAfterCalcIsOutOfStandardDiscPctRange(Rec, IsOutOfStandardDiscPctRange);
            if IsOutOfStandardDiscPctRange then
                Error(LineDiscountPctErr);
            "Line Discount %" := LineDiscountPct;
        end else
            "Line Discount %" := 0;

        OnAfterUpdateLineDiscPct(Rec);
    end;

    local procedure UpdateBaseAmounts(NewAmount: Decimal; NewAmountIncludingVAT: Decimal; NewVATBaseAmount: Decimal)
    begin
        Amount := NewAmount;
        "Amount Including VAT" := NewAmountIncludingVAT;
        "VAT Base Amount" := NewVATBaseAmount;

        OnAfterUpdateBaseAmounts(Rec, xRec, CurrFieldNo);
    end;

    procedure CalcPlannedDate(): Date
    begin
        if Format("Shipping Time") <> '' then
            exit(CalcPlannedDeliveryDate(FieldNo("Planned Delivery Date")));

        exit(CalcPlannedShptDate(FieldNo("Planned Delivery Date")));
    end;

    local procedure IsCalcVATAmountLinesHandled(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var VATAmountLine: Record "VAT Amount Line"; QtyType: Option General,Invoicing,Shipping) IsHandled: Boolean
    begin
        IsHandled := false;
        OnBeforeCalcVATAmountLines(SalesHeader, SalesLine, VATAmountLine, IsHandled, QtyType);
        exit(IsHandled);
    end;

    procedure ValidateUnitCostLCYOnGetUnitCost(Item: Record Item)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeValidateUnitCostLCYOnGetUnitCost(IsHandled, Rec);
        if IsHandled then
            exit;

        if GetSKU then
            Validate("Unit Cost (LCY)", SKU."Unit Cost" * "Qty. per Unit of Measure")
        else
            Validate("Unit Cost (LCY)", Item."Unit Cost" * "Qty. per Unit of Measure");
    end;

    local procedure AssignResourceUoM()
    var
        ResUnitofMeasure: Record "Resource Unit of Measure";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeAssignResourceUoM(ResUnitofMeasure, IsHandled);
        if IsHandled then
            exit;

        ResUnitofMeasure.Get("No.", "Unit of Measure Code");
        "Qty. per Unit of Measure" := ResUnitofMeasure."Qty. per Unit of Measure";

        OnAfterAssignResourceUOM(Rec, Resource, ResUnitofMeasure);
    end;

    local procedure CheckPromisedDeliveryDate()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckPromisedDeliveryDate(SalesHeader, IsHandled);
        if IsHandled then
            exit;

        if ("Requested Delivery Date" <> xRec."Requested Delivery Date") and ("Promised Delivery Date" <> 0D) then
            Error(Text028, FieldCaption("Requested Delivery Date"), FieldCaption("Promised Delivery Date"));
    end;

    procedure LookupNoField(var Text: Text[1024]): Boolean
    var
        StdText: Record "Standard Text";
        Acct: Record "G/L Account";
        Item: Record Item;
        Res: Record Resource;
        FA: Record "Fixed Asset";
        ItemCharge: Record "Item Charge";
        StdTextList: Page "Standard Text Codes";
        AcctList: Page "G/L Account List";
        ItemList: Page "Item List";
        ResList: Page "Resource List";
        FAList: Page "Fixed Asset List";
        ItemChargeList: Page "Item Charges";
    begin
        // PR1.00 Begin
        case Type of
            Type::" ":
                begin
                    StdTextList.SetTableView(StdText);
                    if StdText.Get("No.") then
                        StdTextList.SetRecord(StdText);
                    StdTextList.LookupMode := true;
                    if StdTextList.RunModal <> ACTION::LookupOK then
                        exit(false);
                    StdTextList.GetRecord(StdText);
                    Text := StdText.Code;
                end;

            Type::"G/L Account":
                begin
                    AcctList.SetTableView(Acct);
                    if Acct.Get("No.") then
                        AcctList.SetRecord(Acct);
                    AcctList.LookupMode := true;
                    if AcctList.RunModal <> ACTION::LookupOK then
                        exit(false);
                    AcctList.GetRecord(Acct);
                    Text := Acct."No.";
                end;

            Type::Item:
                begin
                    Item.SetRange("Item Type", Item."Item Type"::"Finished Good");
                    ItemList.SetTableView(Item);
                    if Item.Get("No.") then
                        ItemList.SetRecord(Item);
                    ItemList.LookupMode := true;
                    if ItemList.RunModal <> ACTION::LookupOK then
                        exit(false);
                    ItemList.GetRecord(Item);
                    Text := Item."No.";
                end;

            Type::Resource:
                begin
                    ResList.SetTableView(Res);
                    if Res.Get("No.") then
                        ResList.SetRecord(Res);
                    ResList.LookupMode := true;
                    if ResList.RunModal <> ACTION::LookupOK then
                        exit(false);
                    ResList.GetRecord(Res);
                    Text := Res."No.";
                end;

            Type::"Fixed Asset":
                begin
                    FAList.SetTableView(FA);
                    if FA.Get("No.") then
                        FAList.SetRecord(FA);
                    FAList.LookupMode := true;
                    if FAList.RunModal <> ACTION::LookupOK then
                        exit(false);
                    FAList.GetRecord(FA);
                    Text := FA."No.";
                end;

            Type::"Charge (Item)":
                begin
                    ItemChargeList.SetTableView(ItemCharge);
                    if ItemCharge.Get("No.") then
                        ItemChargeList.SetRecord(ItemCharge);
                    ItemChargeList.LookupMode := true;
                    if ItemChargeList.RunModal <> ACTION::LookupOK then
                        exit(false);
                    ItemChargeList.GetRecord(ItemCharge);
                    Text := ItemCharge."No.";
                end;

            Type::FOODAccrualPlan:
                exit(AccrualFldMgmt.DocumentLineLookupNo(Text)); // P8002744

            // PR3.61 Begin
            Type::FOODContainer:
                begin
                    Item.SetRange("Item Type", Item."Item Type"::Container);
                    ItemList.SetTableView(Item);
                    if Item.Get("No.") then
                        ItemList.SetRecord(Item);
                    ItemList.LookupMode := true;
                    if ItemList.RunModal <> ACTION::LookupOK then
                        exit(false);
                    ItemList.GetRecord(Item);
                    Text := Item."No.";
                end;
        // PR3.61 End
        end;
        exit(true);
        // PR1.00 End
    end;

    procedure TrackAlternateUnits(): Boolean
    var
        Item: Record Item;
    begin
        // PR3.60
        if (Type <> Type::Item) or ("No." = '') then
            exit(false);
        GetItem(Item); // P80066030
        exit(Item.TrackAlternateUnits);
        // PR3.60
    end;

    procedure PriceInAlternateUnits(): Boolean
    var
        Item: Record Item;
    begin
        // PR3.60
        if (Type <> Type::Item) or ("No." = '') then
            exit(false);
        GetItem(Item); // P80066030
        //EXIT(Item.CostInAlternateUnits); // P8000981
        exit(Item.PriceInAlternateUnits);  // P8000981
        // PR3.60
    end;

    procedure CostInAlternateUnits(): Boolean
    var
        Item: Record Item;
    begin
        // P8000981
        if (Type <> Type::Item) or ("No." = '') then
            exit(false);
        GetItem(Item); // P80066030
        exit(Item.CostInAlternateUnits());
    end;

    procedure GetQuantity(FldNo: Integer): Decimal
    begin
        // PR3.70
        if TrackAlternateUnits then begin
            case FldNo of
                FieldNo(Quantity):
                    exit("Quantity (Alt.)");
                FieldNo("Qty. to Ship"):
                    exit("Qty. to Ship (Alt.)");
            end;
        end else begin
            case FldNo of
                FieldNo(Quantity):
                    exit(Quantity);
                FieldNo("Qty. to Ship"):
                    exit("Qty. to Ship");
            end;
        end;
        // PR3.70
    end;

    procedure GetPricingQty(): Decimal
    begin
        // PR3.60
        if PriceInAlternateUnits then
            exit("Quantity (Alt.)");
        exit(Quantity);
        // PR3.60
    end;

    procedure GetPricingQuantity(FldNo: Integer; Base: Code[4]): Decimal
    begin
        // P8001366
        if PriceInAlternateUnits then begin
            case FldNo of
                FieldNo(Quantity):
                    exit("Quantity (Alt.)");
                FieldNo("Qty. to Ship"):
                    exit("Qty. to Ship (Alt.)");
                FieldNo("Quantity Shipped"):
                    exit("Qty. Shipped (Alt.)");
                FieldNo("Return Qty. to Receive"):
                    exit("Return Qty. to Receive (Alt.)");
                FieldNo("Return Qty. Received"):
                    exit("Return Qty. Received (Alt.)");
                FieldNo("Qty. to Invoice"):
                    exit("Qty. to Invoice (Alt.)");
                FieldNo("Quantity Invoiced"):
                    exit("Qty. Invoiced (Alt.)");
                FieldNo("Qty. Shipped Not Invoiced"):
                    exit("Qty. Shipped (Alt.)" - "Qty. Invoiced (Alt.)");
                FieldNo("Return Qty. Rcd. Not Invd."):
                    exit("Return Qty. Received (Alt.)" - "Qty. Invoiced (Alt.)");
            end;
        end else
            if Base = 'BASE' then begin
                case FldNo of
                    FieldNo(Quantity):
                        exit("Quantity (Base)");
                    FieldNo("Qty. to Ship"):
                        exit("Qty. to Ship (Base)");
                    FieldNo("Quantity Shipped"):
                        exit("Qty. Shipped (Base)");
                    FieldNo("Return Qty. to Receive"):
                        exit("Return Qty. to Receive (Base)");
                    FieldNo("Return Qty. Received"):
                        exit("Return Qty. Received (Base)");
                    FieldNo("Qty. to Invoice"):
                        exit("Qty. to Invoice (Base)");
                    FieldNo("Quantity Invoiced"):
                        exit("Qty. Invoiced (Base)");
                    FieldNo("Qty. Shipped Not Invoiced"):
                        exit("Qty. Shipped Not Invd. (Base)");
                    FieldNo("Return Qty. Rcd. Not Invd."):
                        exit("Ret. Qty. Rcd. Not Invd.(Base)");
                end;
            end else begin
                case FldNo of
                    FieldNo(Quantity):
                        exit(Quantity);
                    FieldNo("Qty. to Ship"):
                        exit("Qty. to Ship");
                    FieldNo("Quantity Shipped"):
                        exit("Quantity Shipped");
                    FieldNo("Return Qty. to Receive"):
                        exit("Return Qty. to Receive");
                    FieldNo("Return Qty. Received"):
                        exit("Return Qty. Received");
                    FieldNo("Qty. to Invoice"):
                        exit("Qty. to Invoice");
                    FieldNo("Quantity Invoiced"):
                        exit("Quantity Invoiced");
                    FieldNo("Qty. Shipped Not Invoiced"):
                        exit("Qty. Shipped Not Invoiced");
                    FieldNo("Return Qty. Rcd. Not Invd."):
                        exit("Return Qty. Rcd. Not Invd.");
                end;
            end;
    end;

    procedure GetCostingQty(): Decimal
    begin
        // P8000981
        if CostInAlternateUnits then
            exit("Quantity (Alt.)");
        exit(Quantity);
    end;

    procedure GetTransactionQty(FldNo: Integer; TransType: Code[10]): Decimal
    begin
        // PR3.70
        case FldNo of
            FieldNo(Quantity):
                case TransType of
                    'ORDER':
                        exit(Quantity);
                    'SHIP':
                        exit("Qty. to Ship");
                    'SHIPPED':
                        exit("Quantity Shipped");
                    'RETURN':
                        exit("Return Qty. to Receive");
                    'INVOICE':
                        exit("Qty. to Invoice");
                    'OUT':
                        exit("Outstanding Quantity");
                end;
            FieldNo("Quantity (Base)"):
                case TransType of
                    'ORDER':
                        exit("Quantity (Base)");
                    'SHIP':
                        exit("Qty. to Ship (Base)");
                    'SHIPPED':
                        exit("Qty. Shipped (Base)");
                    'RETURN':
                        exit("Return Qty. to Receive (Base)");
                    'INVOICE':
                        exit("Qty. to Invoice (Base)");
                    'OUT':
                        exit("Outstanding Qty. (Base)");
                end;
            FieldNo("Quantity (Alt.)"):
                case TransType of
                    'ORDER':
                        exit("Quantity (Alt.)");
                    'SHIP':
                        exit("Qty. to Ship (Alt.)");
                    'SHIPPED':
                        exit("Qty. Shipped (Alt.)");
                    'RETURN':
                        exit("Return Qty. to Receive (Alt.)");
                    'INVOICE':
                        exit("Qty. to Invoice (Alt.)");
                    'OUT':
                        exit("Quantity (Alt.)" - "Qty. Shipped (Alt.)");
                end;
        end;
        // PR3.70
    end;

    procedure ContainerSpecification()
    var
        ContainerFns: Codeunit "Container Functions";
    begin
        ContainerFns.ContainersFromDocument(Rec); // PR3.61
    end;

    procedure GetLotNo()
    var
        EasyLotTracking: Codeunit "Easy Lot Tracking";
    begin
        // P8000043A
        if ProcessFns.TrackingInstalled then begin
            EasyLotTracking.SetSalesLine(Rec);
            "Lot No." := EasyLotTracking.GetLotNo;
        end;
    end;

    procedure UpdateLotTracking(ForceUpdate: Boolean; ApplyFromEntryNo: Integer)
    var
        Item: Record Item;
        EasyLotTracking: Codeunit "Easy Lot Tracking";
        QtyBase: Decimal;
        QtyToHandle: Decimal;
        QtyToHandleAlt: Decimal;
        QtyToInvoice: Decimal;
    begin
        // P8000043A
        // P8000466A - add parameter for ApplyFromEntryNo
        if ((CurrFieldNo = 0) and (not ForceUpdate)) or (Type <> Type::Item) then // P8000071A
            exit;
        if ("Lot No." = P800Globals.MultipleLotCode) or (not ProcessFns.TrackingInstalled) or
          (("Lot No." = '') and (("Line No." <> xRec."Line No.") or (xRec."Lot No." = ''))) // P8000083A
        then
            exit;

        EasyLotTracking.TestSalesLine(Rec);
        if "Line No." = 0 then
            exit;

        // P8004505
        if UseWhseLineQty then begin
            QtyBase := "Quantity (Base)"; // P80073378
            QtyToHandle := WhseLineQtyBase;
            QtyToHandleAlt := WhseLineQtyAlt;
            QtyToInvoice := WhseLineQtyToInvBase; // P80077569
        end else begin
            // P8004505
            GetLocation("Location Code"); // P8000629A
            case "Document Type" of
                "Document Type"::Order, "Document Type"::Invoice:
                    if Location.LocationType = 1 then begin // P8000629A
                        QtyToHandle := "Qty. to Ship (Base)";
                        QtyToHandleAlt := "Qty. to Ship (Alt.)";
                        QtyToInvoice := "Qty. to Invoice (Base)"; // P8000629A
                                                                  // P8000629A
                    end else begin
                        // P80077569
                        QtyToHandle := "Qty. to Ship (Base)";
                        QtyToHandleAlt := "Qty. to Ship (Alt.)";
                        QtyToInvoice := "Qty. to Invoice (Base)"; // P8000629A
                                                                  // P80077569
                                                                  // P8000629A
                    end;
                "Document Type"::"Credit Memo", "Document Type"::"Return Order":
                    if Location.LocationType = 1 then begin // P8000629A
                        QtyToHandle := "Return Qty. to Receive (Base)";
                        QtyToHandleAlt := "Return Qty. to Receive (Alt.)";
                        QtyToInvoice := "Qty. to Invoice (Base)"; // P8000629A
                                                                  // P8000629A
                    end else begin
                        // P80077569
                        QtyToHandle := "Return Qty. to Receive (Base)";
                        QtyToHandleAlt := "Return Qty. to Receive (Alt.)";
                        QtyToInvoice := "Qty. to Invoice (Base)"; // P8000629A
                                                                  // P80077569
                                                                  // P8000629A
                    end;
            end;
            // P8000629A
            if Location.LocationType <> 1 then begin
                GetItem(Item); // P80066030
                               // P8004505
                if Item.TrackAlternateUnits then
                    if Item."Catch Alternate Qtys." then
                        QtyToHandleAlt := AltQtyMgmt.CalcAltQtyLinesQtyAlt1("Alt. Qty. Transaction No.")
                    else
                        QtyToHandleAlt := Round(QtyToHandle * Item.AlternateQtyPerBase, 0.00001);
                //IF Item.TrackAlternateUnits AND NOT Item."Catch Alternate Qtys." THEN
                //  QtyToHandleAlt := ROUND(QtyToHandle * Item.AlternateQtyPerBase,0.00001);
                // P8004505
            end;
            // P8000629A
            QtyBase := "Quantity (Base)"; // P8004505
        end;                            // P8004505

        EasyLotTracking.SetSalesLine(Rec);
        EasyLotTracking.SetApplyFromEntryNo(ApplyFromEntryNo); // P8000466A
        if (xRec."Document Type" = 0) and (xRec."Document No." = '') and (xRec."Line No." = 0) then // P8000181A
            xRec."Lot No." := "Lot No.";                                                              // P8000181A
        EasyLotTracking.ReplaceTracking(xRec."Lot No.", "Lot No.", "Alt. Qty. Transaction No.",
          QtyBase, QtyToHandle, QtyToHandleAlt, QtyToInvoice); // P8000629A, P8004505
    end;

    procedure CheckLotPreferences(LotNo: Code[50]; ShowWarning: Boolean): Boolean
    var
        LotInfo: Record "Lot No. Information";
        LotAgeFilter: Record "Lot Age Filter";
        LotSpecFilter: Record "Lot Specification Filter";
        LotFiltering: Codeunit "Lot Filtering";
        Customer: Record Customer;
        InvSetup: Record "Inventory Setup";
        LotExists: Boolean;
    begin
        // P8000153A
        if not ProcessFns.TrackingInstalled then
            exit(true); // P8000172A

        if "Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"] then // P8000248B
            exit(true);                                                                                // P8000248B

        // P8000946
        LotExists := LotInfo.Get("No.", "Variant Code", LotNo);
        if "Country/Region of Origin Code" <> '' then begin
            if not LotExists then
                if ShowWarning then
                    LotInfo.Get("No.", "Variant Code", LotNo)
                else
                    exit(false);
            if LotInfo."Country/Region of Origin Code" <> "Country/Region of Origin Code" then
                if ShowWarning then
                    LotInfo.TestField("Country/Region of Origin Code", "Country/Region of Origin Code")
                else
                    exit(false);
        end;
        // P8000946

        LotAgeFilter.SetRange("Table ID", DATABASE::"Sales Line");
        LotAgeFilter.SetRange(Type, "Document Type");
        LotAgeFilter.SetRange(ID, "Document No.");
        LotAgeFilter.SetRange("Line No.", "Line No.");

        LotSpecFilter.SetRange("Table ID", DATABASE::"Sales Line");
        LotSpecFilter.SetRange(Type, "Document Type");
        LotSpecFilter.SetRange(ID, "Document No.");
        LotSpecFilter.SetRange("Line No.", "Line No.");

        if (not LotAgeFilter.Find('-')) and (not LotSpecFilter.Find('-')) and  // P8000353A
          ("Freshness Calc. Method" = 0) // P8001070
        then                             // P8001070
            exit(true);                                                          // P8000353A

        // P8000946
        if not LotExists then // P8001014
            if ShowWarning then // P8001014
                LotInfo.Get("No.", "Variant Code", LotNo)
            else
                exit(false);
        // P8000946

        // P8001070
        Customer.Get("Sell-to Customer No.");
        if Customer."Lot Pref. Enforcement Level" > 0 then
            Customer."Lot Pref. Enforcement Level" -= 1
        else begin
            InvSetup.Get;
            Customer."Lot Pref. Enforcement Level" := InvSetup."Lot Pref. Enforcement Level";
        end;
        // P8001070

        exit(LotFiltering.CheckLotPreferences(LotInfo, LotAgeFilter, LotSpecFilter, // P8001070
          "Freshness Calc. Method", "Oldest Accept. Freshness Date", ShowWarning,   // P8001070
          Customer."Lot Pref. Enforcement Level"));                               // P8001070
    end;

    procedure ReCheckLotPreferences()
    var
        ResEntry: Record "Reservation Entry";
        P800Globals: Codeunit "Process 800 System Globals";
    begin
        // P8001070
        if not ProcessFns.TrackingInstalled then
            exit;

        if "Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"] then
            exit;

        if ("Lot No." <> '') and ("Lot No." <> P800Globals.MultipleLotCode) then begin
            if not CheckLotPreferences("Lot No.", true) then
                Error(Text37002007, ResEntry."Lot No.");
        end else begin
            ResEntry.SetCurrentKey("Source Type", "Source ID", "Source Batch Name", "Source Ref. No.", "Lot No.", "Serial No.");
            ResEntry.SetRange("Source Type", DATABASE::"Sales Line");
            ResEntry.SetRange("Source Subtype", "Document Type");
            ResEntry.SetRange("Source ID", "Document No.");
            ResEntry.SetRange("Source Ref. No.", "Line No.");
            ResEntry.SetFilter("Lot No.", '<>%1', '');

            if ResEntry.Find('-') then
                repeat
                    if not CheckLotPreferences(ResEntry."Lot No.", true) then
                        Error(Text37002007, ResEntry."Lot No.");

                    ResEntry.SetRange("Lot No.", ResEntry."Lot No.");
                    ResEntry.Find('+');
                    ResEntry.SetRange("Lot No.");
                until ResEntry.Next = 0;
        end;
    end;

    procedure SalesHistory()
    var
        SalesHeader: Record "Sales Header";
        ItemLedgerEntry: Record "Item Ledger Entry";
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        SalesHistory: Page "Customer/Item Sales";
    begin
        // P8000248B
        if Type <> Type::Item then
            exit;
        SalesHeader.Get("Document Type", "Document No.");
        if SalesHeader."Sell-to Customer No." = '' then
            exit;

        if "Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"] then begin
            SalesHistory.LookupMode(true);
            SalesHistory.SetVariables(SalesHeader."Sell-to Customer No.", "No.");
            if SalesHistory.RunModal = ACTION::LookupOK then begin
                SalesHistory.GetRecord(ItemLedgerEntry);
                if "No." = '' then
                    Validate("No.", ItemLedgerEntry."Item No.");
                if "Variant Code" = '' then
                    Validate("Variant Code", ItemLedgerEntry."Variant Code");
                Validate("Unit of Measure Code", ItemLedgerEntry."Unit of Measure Code");
                if Quantity = 0 then
                    Validate(Quantity, ItemLedgerEntry.SalesQuantity);
                "Unit Price (Freight)" := ItemLedgerEntry.SalesUnitPriceFreight(); // P8000921
                Validate("Unit Price", ItemLedgerEntry.SalesUnitPrice);
                Validate("Line Discount %", 0);
                if ItemLedgerEntry."Lot No." <> '' then begin
                    Item.Get("No.");
                    ItemTrackingCode.Get(Item."Item Tracking Code");
                    if ItemTrackingCode."Allow Loose Lot Control" then begin       // P8000466A
                        GlobalApplyFromEntryNo := ItemLedgerEntry."Entry No.";       // P8000466A
                        Validate("Lot No.", ItemLedgerEntry."Lot No.");
                    end;                                                           // P8000466A
                end else                                                         // P8000466A
                    Validate("Appl.-from Item Entry", ItemLedgerEntry."Entry No."); // P8000466A
            end;
        end else begin
            SalesHistory.SetVariables(SalesHeader."Sell-to Customer No.", "No.");
            SalesHistory.RunModal;
        end;
    end;

    procedure AutoLotNo(Posting: Boolean)
    var
        SalesLine: Record "Sales Line";
        xSalesLine: Record "Sales Line";
        P800Tracking: Codeunit "Process 800 Item Tracking";
    begin
        // P8000250B
        if not ("Document Type" in ["Document Type"::"Return Order", "Document Type"::"Credit Memo"]) then
            exit;
        if (Type <> Type::Item) or ("No." = '') then
            exit;
        if not ProcessFns.TrackingInstalled then
            exit;
        if Posting and ("Return Qty. to Receive" = 0) then
            exit;

        GetSalesHeader;
        // P8001234
        SalesLine := Rec;
        xSalesLine := xRec;
        if Posting then begin
            SalesLine."Shipment Date" := SalesHeader."Posting Date";
            //xSalesLine."Shipment Date" := SalesHeader."Posting Date"; // P8001314
            xSalesLine := SalesLine;                                    // P8001314
        end else begin
            SalesLine."Shipment Date" := 0D;
            xSalesLine."Shipment Date" := 0D;
        end;
        if P800Tracking.AutoAssignLotNo(SalesLine, xSalesLine, "Lot No.") then begin
            // P8001234
            UpdateLotTracking(true, 0); // P8000466A
            if Posting then
                Modify;
        end;
    end;

    procedure TestAltQtyEntry()
    var
        Direction: Option Outbound,Inbound;
    begin
        // P8000282A
        if ("Document Type" in ["Document Type"::"Return Order", "Document Type"::"Credit Memo"]) then
            AltQtyMgmt.TestWhseDataEntry("Location Code", Direction::Inbound)
        else
            AltQtyMgmt.TestWhseDataEntry("Location Code", Direction::Outbound);
    end;

    procedure UpdateOnWhseChange()
    var
        Location: Record Location;
    begin
        // P8000282A
        if (Type = Type::Item) and ("No." <> '') then
            //IF ("Document Type" IN ["Document Type"::"Return Order", "Document Type"::"Credit Memo"]) THEN BEGIN // P8000351A
            if "Document Type" = "Document Type"::"Return Order" then begin                                        // P8000351A
                if Location.RequireReceive("Location Code") then begin
                    "Return Qty. to Receive" := 0;
                    "Return Qty. to Receive (Base)" := 0;
                    "Return Qty. to Receive (Alt.)" := 0;
                    InitQtyToInvoice;
                end;
                //END ELSE BEGIN                                                                                       // P8000351A
            end else
                if "Document Type" = "Document Type"::Order then begin                                        // P8000351A
                    if Location.RequireShipment("Location Code") then begin
                        "Qty. to Ship" := 0;
                        "Qty. to Ship (Base)" := 0;
                        "Qty. to Ship (Alt.)" := 0;
                        InitQtyToInvoice;
                    end;
                end;
    end;

    procedure SuspendCreditCheck(Suspend: Boolean) WasSuspended: Boolean
    begin
        // P8000399A
        // P8000428A - ID changed
        // P8006787 - add return value
        WasSuspended := CreditCheckSuspended; // P8006787
        CreditCheckSuspended := Suspend;
    end;

    procedure SetSalesLineAltQty()
    var
        CurrFldNo: Integer;
    begin
        // P8000408A
        CurrFldNo := CurrFieldNo;
        AltQtyMgmt.SetSalesLineAltQty(Rec);
        CurrFieldNo := CurrFldNo;
    end;

    procedure TestSalesAltQtyInfo(CatchAltQtysCheck: Boolean)
    var
        CurrFldNo: Integer;
    begin
        // P8000408A
        CurrFldNo := CurrFieldNo;
        AltQtyMgmt.TestSalesAltQtyInfo(Rec, CatchAltQtysCheck);
        CurrFieldNo := CurrFldNo;
    end;

    procedure UpdateSalesLine()
    var
        CurrFldNo: Integer;
    begin
        // P8000408A
        CurrFldNo := CurrFieldNo;
        AltQtyMgmt.UpdateSalesLine(Rec);
        CurrFieldNo := CurrFldNo;
    end;

    procedure CalcLineDiscount(DropInvoiceDiscountAmount: Boolean)
    begin
        // P8000440A
        case "Line Discount Type" of
            "Line Discount Type"::Percent:
                begin
                    "Line Discount Amount" :=
                      Round(
                        Round(GetPricingQty * "Unit Price", Currency."Amount Rounding Precision") *
                        "Line Discount %" / 100, Currency."Amount Rounding Precision");
                    if GetPricingQty <> 0 then
                        "Line Discount Unit Amount" :=
                          Round("Line Discount Amount" / GetPricingQty, Currency."Unit-Amount Rounding Precision")
                    else
                        "Line Discount Unit Amount" := 0;
                end;
            "Line Discount Type"::Amount:
                begin
                    if Round(GetPricingQty * "Unit Price", Currency."Amount Rounding Precision") <> 0 then
                        "Line Discount %" :=
                          Round(
                           "Line Discount Amount" / Round(GetPricingQty * "Unit Price", Currency."Amount Rounding Precision") * 100,
                            0.00001)
                    else
                        "Line Discount %" := 0;
                    if GetPricingQty <> 0 then
                        "Line Discount Unit Amount" :=
                          Round("Line Discount Amount" / GetPricingQty, Currency."Unit-Amount Rounding Precision")
                    else
                        "Line Discount Unit Amount" := 0;
                end;
            "Line Discount Type"::"Unit Amount":
                begin
                    "Line Discount Amount" :=
                      Round(GetPricingQty * "Line Discount Unit Amount", Currency."Amount Rounding Precision");
                    if Round(GetPricingQty * "Unit Price", Currency."Amount Rounding Precision") <> 0 then
                        "Line Discount %" :=
                          Round(
                           "Line Discount Amount" / Round(GetPricingQty * "Unit Price", Currency."Amount Rounding Precision") * 100,
                            0.00001)
                    else
                        "Line Discount %" := 0;
                end;
        end;

        if DropInvoiceDiscountAmount then begin // P80073095
            "Inv. Discount Amount" := 0;
            "Inv. Disc. Amount to Invoice" := 0;
        end;                                    // P80073095

        UpdateAmounts;
    end;

    procedure LineAmtExclAltQtys(): Decimal
    var
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";
    begin
        // P8000466A
        if (Type = Type::Item) and ("No." <> '') then
            if PriceInAlternateUnits() then begin
                GetItem(Item); // P80066030
                ItemUOM.Get("No.", Item."Alternate Unit of Measure");
                exit(Round(Quantity * ("Qty. per Unit of Measure" / ItemUOM."Qty. per Unit of Measure") *
                           "Unit Price" * (1 - "Line Discount %" / 100), Currency."Amount Rounding Precision"));
            end;
        exit("Line Amount");
    end;

    procedure SetDeleteItemTracking()
    begin
        // P8000466A
        SalesLineReserve.SetDeleteItemTracking(true); // P80066030
    end;

    procedure SetAltQtyWithNoHandling()
    begin
        // P8000818
        if TrackAlternateUnits then begin
            case "Document Type" of
                "Document Type"::Invoice:
                    AltQtyMgmt.InitAlternateQtyToHandle(
                      "No.", "Alt. Qty. Transaction No.", "Quantity (Base)", "Qty. to Ship (Base)",
                      "Qty. Shipped (Base)", "Quantity (Alt.)", "Qty. Shipped (Alt.)", "Qty. to Ship (Alt.)");
                "Document Type"::"Credit Memo":
                    AltQtyMgmt.InitAlternateQtyToHandle(
                      "No.", "Alt. Qty. Transaction No.", "Quantity (Base)", "Return Qty. to Receive (Base)",
                      "Return Qty. Received (Base)", "Quantity (Alt.)", "Return Qty. Received (Alt.)", "Return Qty. to Receive (Alt.)");
            end;
            SetSalesLineAltQty;
        end;
    end;

    procedure InitOutstandingQtyCont()
    var
        SalesCont: Record "Sales Contract";
        SalesContLine: Record "Sales Contract Line";
        SalesPrice: Record "Sales Price";
    begin
        // P8000885
        if "Contract No." <> '' then begin
            SalesCont.Get("Contract No.");
            SalesPrice.SetCurrentKey("Price ID");
            SalesPrice.SetRange("Price ID", "Price ID");
            SalesPrice.FindFirst;
            SalesContLine.Get("Contract No.", SalesPrice."Item Type", SalesPrice."Item Code"); // P8007749
            if SalesCont."Contract Limit Unit of Measure" <> '' then
                "Outstanding Qty. (Contract)" :=
                      SalesContMgt.ConvertLimitUOMFromBase("Outstanding Qty. (Base)", "No.", SalesCont."Contract Limit Unit of Measure");
            if SalesContLine."Line Limit Unit of Measure" <> '' then
                "Outstanding Qty. (Cont. Line)" :=
                      SalesContMgt.ConvertLimitUOMFromBase("Outstanding Qty. (Base)", "No.", SalesContLine."Line Limit Unit of Measure");
        end else begin
            "Outstanding Qty. (Contract)" := 0;
            "Outstanding Qty. (Cont. Line)" := 0;
        end;
    end;

    procedure SetDoNotUpdatePrice(NewDoNotUpdatePrice: Boolean)
    begin
        // P8000885
        DoNotUpdatePrice := NewDoNotUpdatePrice;
    end;

    local procedure UsingDeliveredPricing(Required: Boolean): Boolean
    begin
        // P8000921
        GetSalesSetup; // P8001371
        if Required then
            SalesSetup.TestField("Delivered Pricing Calc. Method")
        else
            if (SalesSetup."Delivered Pricing Calc. Method" = SalesSetup."Delivered Pricing Calc. Method"::None) then
                exit(false);
        SalesSetup.TestField("Del. Pricing Calc. Codeunit ID");
        exit(true);
    end;

    procedure ValidateUnitPriceFOB(NewUnitPriceFOB: Decimal)
    begin
        // P8000921
        if (Type <> Type::" ") then
            if not UsingDeliveredPricing(false) then
                Validate("Unit Price", NewUnitPriceFOB)
            else begin
                "Unit Price (FOB)" := NewUnitPriceFOB;
                "Unit Price (Freight)" := 0;
                "Line Amount (Freight)" := 0;
                if (SalesSetup."Delivered Pricing Calc. Method" = SalesSetup."Delivered Pricing Calc. Method"::Line) then begin
                    CalcFields("FOB Pricing");
                    if not "FOB Pricing" then
                        CODEUNIT.Run(SalesSetup."Del. Pricing Calc. Codeunit ID", Rec);
                end;
                ValidateFreightAmounts;
            end;
    end;

    procedure ValidateFreightAmounts()
    var
        xRecLineDiscPerc: Decimal;
    begin
        // P8000921
        GetSalesHeader;
        // P80038948
        if ("Line Discount Amount" <> 0) then
            xRecLineDiscPerc := "Line Discount %";
        // P80038948
        "Unit Price (Freight)" := Round("Unit Price (Freight)", Currency."Unit-Amount Rounding Precision");
        "Line Amount (Freight)" := Round("Line Amount (Freight)", Currency."Amount Rounding Precision");
        if ("Unit Price (Freight)" = 0) and ("Line Amount (Freight)" <> 0) then
            Validate("Line Amount (Freight)")
        else
            Validate("Unit Price (Freight)");

        // P80038948
        if xRecLineDiscPerc <> 0 then
            Validate("Line Discount %", xRecLineDiscPerc);
        // P80038948
    end;

    procedure CorrectUnitPriceFOB()
    begin
        // P8000921
        "Unit Price (FOB)" := "Unit Price" - "Unit Price (Freight)"; // P8000921
    end;

    local procedure GetContainerQuantities(var QtyToHandle: Decimal; var QtyToHandleBase: Decimal; var QtyToHandleAlt: Decimal; ExcludeWhseDoc: Boolean; ShipReceive: Variant)
    begin
        // P80046533 - rename from GetContainerQty; add parameter ShipReceiveOnly
        QtyToHandle := 0;
        QtyToHandleBase := 0;
        QtyToHandleAlt := 0;

        case Type of
            Type::"G/L Account":
                if "Container Line No." <> 0 then begin
                    QtyToHandle := ContainerFns.GetContainerCount(DATABASE::"Sales Line", "Document Type", "Document No.", "Container Line No.", ExcludeWhseDoc, ShipReceive);
                    QtyToHandleBase := Round(QtyToHandle * "Qty. per Unit of Measure", 0.00001);
                end;
            Type::FOODContainer:
                begin
                    QtyToHandle := ContainerFns.GetContainerCount(DATABASE::"Sales Line", "Document Type", "Document No.", "Line No.", ExcludeWhseDoc, ShipReceive);
                    QtyToHandleBase := Round(QtyToHandle * "Qty. per Unit of Measure", 0.00001);
                end;
            Type::Item:
                if ProcessFns.ContainerTrackingInstalled then
                    ContainerFns.GetContainerQuantitiesByDocLine(Rec, 0, QtyToHandle, QtyToHandleBase, QtyToHandleAlt, ShipReceive);
        end;
    end;

    procedure GetContainerQuantity(ShipReceive: Variant) QtyToHandle: Decimal
    var
        QtyToHandleBase: Decimal;
        QtyToHandleAlt: Decimal;
    begin
        // P80046533
        GetContainerQuantities(QtyToHandle, QtyToHandleBase, QtyToHandleAlt, true, ShipReceive);
    end;

    local procedure TestContainerQuantityIsZero()
    begin
        // P80046533
        if 0 <> GetContainerQuantity('') then
            Error(Text37002012);
    end;

    procedure GetLotFreshness()
    var
        Item: Record Item;
        P800Tracking: Codeunit "Process 800 Item Tracking";
    begin
        // P8001062
        if ("Document Type" <> "Document Type"::Order) or (Type <> Type::Item) or ("No." = '') then
            "Lot Freshness Preference" := -1
        else
            if ProcessFns.TrackingInstalled then begin
                GetItem(Item); // P80066030
                "Lot Freshness Preference" := P800Tracking.GetLotFreshnessPreference(Item, "Sell-to Customer No.");
            end;
    end;

    procedure SetOldestAcceptableDate()
    var
        Item: Record Item;
    begin
        // P8001062
        "Oldest Accept. Freshness Date" := 0D;

        if ("Document Type" <> "Document Type"::Order) or (Type <> Type::Item) or ("No." = '') then
            exit;

        if ProcessFns.TrackingInstalled then begin
            GetItem(Item); // P80066030
            "Freshness Calc. Method" := Item."Freshness Calc. Method";
            case "Freshness Calc. Method" of
                "Freshness Calc. Method"::"Days To Fresh":
                    if ("Shipment Date" <> 0D) and ("Lot Freshness Preference" >= 0) then
                        "Oldest Accept. Freshness Date" := "Shipment Date" - "Lot Freshness Preference"
                    else
                        "Oldest Accept. Freshness Date" := 0D;
                "Freshness Calc. Method"::"Best If Used By", "Freshness Calc. Method"::"Sell By":
                    if ("Planned Delivery Date" <> 0D) and ("Lot Freshness Preference" >= 0) then
                        "Oldest Accept. Freshness Date" := "Planned Delivery Date" + "Lot Freshness Preference"
                    else
                        "Oldest Accept. Freshness Date" := 0D;
            end;
        end;

        // P8001070
        if (CurrFieldNo <> 0) and
          ("Oldest Accept. Freshness Date" <> xRec."Oldest Accept. Freshness Date")
        then
            ReCheckLotPreferences;
        // P8001070
    end;

    procedure FreshnessDateText(): Text[50]
    var
        LotInfo: Record "Lot No. Information";
    begin
        // P8001062
        case "Freshness Calc. Method" of
            "Freshness Calc. Method"::"Days To Fresh":
                exit(LotInfo.FieldCaption("Creation Date"));
            "Freshness Calc. Method"::"Best If Used By", "Freshness Calc. Method"::"Sell By":
                exit(StrSubstNo(Text37002011, "Freshness Calc. Method"));
        end;
    end;

    procedure IsNonWarehouseItem(): Boolean
    var
        Item: Record Item;
    begin
        // P8001290
        if (Type in [Type::Item, Type::FOODContainer]) and ("No." <> '') then begin
            GetItem(Item); // P80066030
            exit(Item."Non-Warehouse Item");
        end;
    end;

    local procedure GetContainerType()
    begin
        // P8001290
        if ContainerType."Container Item No." <> "No." then begin
            ContainerType.SetRange("Container Item No.", "No.");
            ContainerType.FindFirst;
        end;
    end;

    procedure SkipWhseQtyCheck()
    begin
        WhseValidateSourceLine.SkipWhseQtyCheck; //N138F0000.n
    end;

    procedure WarehouseLineQuantity(QtyBase: Decimal; QtyAlt: Decimal; QtyToInvBase: Decimal)
    begin
        // P8004505
        UseWhseLineQty := true;
        WhseLineQtyBase := QtyBase;
        WhseLineQtyAlt := QtyAlt;
        WhseLineQtyToInvBase := QtyToInvBase; // P80077569
    end;

    procedure SetUnitPrice()
    begin
        // P8006632
        SettingUnitPrice := true;
    end;

    procedure SetShortSubstituteItem()
    begin
        // P8007152
        IsShortSubstituteItem := true;
    end;

    local procedure RemoveDeliveryTrip(): Code[20]
    var
        WarehouseRequest: Record "Warehouse Request";
        ProcessFns: Codeunit "Process 800 Functions";
        DeliveryTripMgt: Codeunit "N138 Delivery Trip Mgt.";
        DeliveryTrip: Record "N138 Delivery Trip";
    begin
        // P80042706
        if ProcessFns.DistPlanningInstalled then
            if DeliveryTripMgt.GetWhseReqSLS(Rec, WarehouseRequest) then begin
                WarehouseRequest.SetRecFilter; // P80060942
                if DeliveryTrip.Get(WarehouseRequest."Delivery Trip") then
                    DeliveryTrip.RemoveSourceDocFromTrip(WarehouseRequest);
            end;
        // P80042706
    end;

    procedure GetWarehouseDocumentBin(WarehouseDocumentNo: Code[20]) BinCode: Code[20]
    var
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
    begin
        // P80046533
        BinCode := "Bin Code";

        if WarehouseDocumentNo = '' then begin
            if not Location.Get("Location Code") then
                exit;
            case "Document Type" of
                "Document Type"::Order:
                    if Location."Require Shipment" then
                        BinCode := Location."Shipment Bin Code"
                    else
                        if BinCode = '' then
                            BinCode := Location."Shipment Bin Code (1-Doc)";
                "Document Type"::"Return Order":
                    if Location."Require Receive" then
                        BinCode := Location."Receipt Bin Code"
                    else
                        if BinCode = '' then
                            BinCode := Location."Receipt Bin Code (1-Doc)";
            end;
        end else begin
            case "Document Type" of
                "Document Type"::Order:
                    begin
                        if WarehouseDocumentNo <> '' then
                            WarehouseShipmentLine.SetRange("No.", WarehouseDocumentNo);
                        WarehouseShipmentLine.SetRange("Source Type", DATABASE::"Sales Line");
                        WarehouseShipmentLine.SetRange("Source Subtype", "Document Type");
                        WarehouseShipmentLine.SetRange("Source No.", "Document No.");
                        WarehouseShipmentLine.SetRange("Source Line No.", "Line No.");
                        if WarehouseShipmentLine.FindFirst then
                            exit(WarehouseShipmentLine."Bin Code");
                    end;
                "Document Type"::"Return Order":
                    begin
                        if WarehouseDocumentNo <> '' then
                            WarehouseReceiptLine.SetRange("No.", WarehouseDocumentNo);
                        WarehouseReceiptLine.SetRange("Source Type", DATABASE::"Sales Line");
                        WarehouseReceiptLine.SetRange("Source Subtype", "Document Type");
                        WarehouseReceiptLine.SetRange("Source No.", "Document No.");
                        WarehouseReceiptLine.SetRange("Source Line No.", "Line No.");
                        if WarehouseReceiptLine.FindFirst then
                            exit(WarehouseReceiptLine."Bin Code");
                    end;
            end;
        end;
    end;

    procedure SetCurrFieldNo(CurrFldNo: Integer)
    begin
        // P80070336
        CurrFieldNo := CurrFldNo;
    end;

    procedure CheckWarehouseGlobal()
    begin
        CheckWarehouse; // P80081811
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestStatusOpen_Food(SalesHeader: Record "Sales Header"; var StatusCheckSuspended: Boolean)
    begin
    end;

    protected procedure VerifyChangeForSalesLineReserve(CallingFieldNo: Integer)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeVerifyChangeForSalesLineReserve(Rec, xRec, CallingFieldNo, IsHandled);
        if IsHandled then
            exit;

        SalesLineReserve.VerifyChange(Rec, xRec);
    end;

    local procedure CheckReservedQtyBase()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckReservedQtyBase(Rec, IsHandled);
        if IsHandled then
            exit;

        CalcFields("Reserved Qty. (Base)");
        TestField("Reserved Qty. (Base)", 0);
    end;

    local procedure CheckNotInvoicedQty()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckNotInvoicedQty(Rec, IsHandled);
        if IsHandled then
            exit;

        if "Shipment No." = '' then
            TestField("Qty. Shipped Not Invoiced", 0);
        if "Return Receipt No." = '' then
            TestField("Return Qty. Rcd. Not Invd.", 0);
    end;

    local procedure CheckInventoryPickConflict()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckInventoryPickConflict(Rec, IsHandled);
        if IsHandled then
            exit;

        if SalesHeader.InventoryPickConflict("Document Type", "Document No.", SalesHeader."Shipping Advice") then
            Error(Text056, SalesHeader."Shipping Advice");
    end;

    local procedure CheckQuantitySign()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckQuantitySign(Rec, IsHandled);
        if IsHandled then
            exit;

        if IsCreditDocType() then begin
            if Quantity > 0 then
                FieldError(Quantity, Text030);
        end else begin
            if Quantity < 0 then
                FieldError(Quantity, Text029);
        end;
    end;

    local procedure ShowReturnedUnitsError(var ItemLedgEntry: Record "Item Ledger Entry"; QtyReturned: Decimal; QtyNotReturned: Decimal)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeShowReturnedUnitsError(Rec, ItemLedgEntry, IsHandled);
        if IsHandled then
            exit;

        Error(Text039, -QtyReturned, ItemLedgEntry.FieldCaption("Document No."), ItemLedgEntry."Document No.", -QtyNotReturned);
    end;

    procedure ShowBlanketOrderSalesLines(DocumentType: Enum "Sales Document Type")
    var
        RelatedSalesLine: Record "Sales Line";
    begin
        RelatedSalesLine.Reset();
        RelatedSalesLine.SetCurrentKey("Document Type", "Blanket Order No.", "Blanket Order Line No.");
        RelatedSalesLine.SetRange("Document Type", DocumentType);
        RelatedSalesLine.SetRange("Blanket Order No.", Rec."Document No.");
        RelatedSalesLine.SetRange("Blanket Order Line No.", Rec."Line No.");
        PAGE.RunModal(PAGE::"Sales Lines", RelatedSalesLine);
    end;

    procedure ShowBlanketOrderPostedShipmentLines()
    var
        SaleShptLine: Record "Sales Shipment Line";
    begin
        SaleShptLine.Reset();
        SaleShptLine.SetCurrentKey("Blanket Order No.", "Blanket Order Line No.");
        SaleShptLine.SetRange("Blanket Order No.", Rec."Document No.");
        SaleShptLine.SetRange("Blanket Order Line No.", Rec."Line No.");
        PAGE.RunModal(PAGE::"Posted Sales Shipment Lines", SaleShptLine);
    end;

    procedure ShowBlanketOrderPostedInvoiceLines()
    var
        SalesInvLine: Record "Sales Invoice Line";
    begin
        SalesInvLine.Reset();
        SalesInvLine.SetCurrentKey("Blanket Order No.", "Blanket Order Line No.");
        SalesInvLine.SetRange("Blanket Order No.", Rec."Document No.");
        SalesInvLine.SetRange("Blanket Order Line No.", Rec."Line No.");
        PAGE.RunModal(PAGE::"Posted Sales Invoice Lines", SalesInvLine);
    end;

    procedure ShowBlanketOrderPostedReturnReceiptLines()
    var
        ReturnRcptLine: Record "Return Receipt Line";
    begin
        ReturnRcptLine.Reset();
        ReturnRcptLine.SetCurrentKey("Blanket Order No.", "Blanket Order Line No.");
        ReturnRcptLine.SetRange("Blanket Order No.", Rec."Document No.");
        ReturnRcptLine.SetRange("Blanket Order Line No.", Rec."Line No.");
        PAGE.RunModal(PAGE::"Posted Return Receipt Lines", ReturnRcptLine);
    end;

    procedure ShowBlanketOrderPostedCreditMemoLines()
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        SalesCrMemoLine.Reset();
        SalesCrMemoLine.SetCurrentKey("Blanket Order No.", "Blanket Order Line No.");
        SalesCrMemoLine.SetRange("Blanket Order No.", Rec."Document No.");
        SalesCrMemoLine.SetRange("Blanket Order Line No.", Rec."Line No.");
        PAGE.RunModal(PAGE::"Posted Sales Credit Memo Lines", SalesCrMemoLine);
    end;

    procedure ShowDeferralSchedule()
    begin
        GetSalesHeader();
        ShowDeferrals(SalesHeader."Posting Date", SalesHeader."Currency Code");
    end;

    local procedure CheckNonstockItemTemplate(NonstockItem: Record "Nonstock Item")
    var
        ItemTempl: Record "Item Templ.";
    begin
        ItemTempl.Get(NonstockItem."Item Templ. Code");
        ItemTempl.TestField("Gen. Prod. Posting Group");
        ItemTempl.TestField("Inventory Posting Group");
    end;

    local procedure CheckQuoteCustomerTemplateCode(SalesHeader: Record "Sales Header")
    begin
        if (SalesHeader."Sell-to Customer No." = '') and
           (SalesHeader."Sell-to Customer Templ. Code" = '')
        then
            Error(
              Text031,
              SalesHeader.FieldCaption("Sell-to Customer No."),
              SalesHeader.FieldCaption("Sell-to Customer Templ. Code"));
        if (SalesHeader."Bill-to Customer No." = '') and
           (SalesHeader."Bill-to Customer Templ. Code" = '')
        then
            Error(
              Text031,
              SalesHeader.FieldCaption("Bill-to Customer No."),
              SalesHeader.FieldCaption("Bill-to Customer Templ. Code"));
    end;

    local procedure CalcBaseQty(Qty: Decimal; FromFieldName: Text; ToFieldName: Text): Decimal
    begin
        OnBeforeCalcBaseQty(Rec, Qty, FromFieldName, ToFieldName);
        exit(UOMMgt.CalcBaseQty(
            "No.", "Variant Code", "Unit of Measure Code", Qty, "Qty. per Unit of Measure", "Qty. Rounding Precision (Base)", FieldCaption("Qty. Rounding Precision"), FromFieldName, ToFieldName));
    end;

    local procedure IsShipmentBinOverridesDefaultBin(Location: Record Location): Boolean
    var
        Bin: Record Bin;
        ShipmentBinAvailable: Boolean;
    begin
        ShipmentBinAvailable := Bin.Get(Location.Code, Location."Shipment Bin Code");
        exit(Location."Require Shipment" and ShipmentBinAvailable);
    end;

    procedure CreateDimFromDefaultDim(FieldNo: Integer)
    var
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        InitDefaultDimensionSources(DefaultDimSource, FieldNo);
        CreateDim(DefaultDimSource);
    end;

    local procedure InitDefaultDimensionSources(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; FieldNo: Integer)
    begin
        DimMgt.AddDimSource(DefaultDimSource, DimMgt.SalesLineTypeToTableID(Type), Rec."No.", FieldNo = Rec.FieldNo("No."));
        DimMgt.AddDimSource(DefaultDimSource, Database::"Responsibility Center", Rec."Responsibility Center", FieldNo = Rec.FieldNo("Responsibility Center"));
        DimMgt.AddDimSource(DefaultDimSource, Database::Job, Rec."Job No.", FieldNo = Rec.FieldNo("Job No."));
        DimMgt.AddDimSource(DefaultDimSource, Database::Location, Rec."Location Code", FieldNo = Rec.FieldNo("Location Code"));

        OnAfterInitDefaultDimensionSources(Rec, DefaultDimSource, FieldNo);
    end;

    local procedure InitDefaultDimensionSources(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; JobNo: Code[20]; FieldNo: Integer)
    begin
        DimMgt.AddDimSource(DefaultDimSource, DimMgt.SalesLineTypeToTableID(Type), Rec."No.");
        DimMgt.AddDimSource(DefaultDimSource, Database::"Responsibility Center", Rec."Responsibility Center");
        DimMgt.AddDimSource(DefaultDimSource, Database::Job, JobNo);
        DimMgt.AddDimSource(DefaultDimSource, Database::Location, Rec."Location Code");

        OnAfterInitDefaultDimensionSources(Rec, DefaultDimSource, FieldNo);
    end;

#if not CLEAN20
    local procedure CreateDefaultDimSourcesFromDimArray(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; TableID: array[10] of Integer; No: array[10] of Code[20])
    var
        DimArrayConversionHelper: Codeunit "Dim. Array Conversion Helper";
    begin
        DimArrayConversionHelper.CreateDefaultDimSourcesFromDimArray(Database::"Sales Line", DefaultDimSource, TableID, No);
    end;

    local procedure CreateDimTableIDs(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; var TableID: array[10] of Integer; var No: array[10] of Code[20])
    var
        DimArrayConversionHelper: Codeunit "Dim. Array Conversion Helper";
    begin
        DimArrayConversionHelper.CreateDimTableIDs(Database::"Sales Line", DefaultDimSource, TableID, No);
    end;

    local procedure RunEventOnAfterCreateDimTableIDs(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    var
        DimArrayConversionHelper: Codeunit "Dim. Array Conversion Helper";
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeRunEventOnAfterCreateDimTableIDs(Rec, DefaultDimSource, IsHandled);
        if IsHandled then
            exit;

        if not DimArrayConversionHelper.IsSubscriberExist(Database::"Sales Line") then
            exit;

        CreateDimTableIDs(DefaultDimSource, TableID, No);
        OnAfterCreateDimTableIDs(Rec, CurrFieldNo, TableID, No);
        CreateDefaultDimSourcesFromDimArray(DefaultDimSource, TableID, No);
    end;

    [Obsolete('Temporary event for compatibility', '20.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunEventOnAfterCreateDimTableIDs(var SalesLine: Record "Sales Line"; var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; var IsHandled: Boolean)
    begin
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitDefaultDimensionSources(var SalesLine: Record "Sales Line"; var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; FieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignFieldsForNo(var SalesLine: Record "Sales Line"; var xSalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterApplyPrice(var SalesLine: Record "Sales Line"; var xSalesLine: Record "Sales Line"; CallFieldNo: Integer; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignHeaderValues(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignStdTxtValues(var SalesLine: Record "Sales Line"; StandardText: Record "Standard Text"; SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignGLAccountValues(var SalesLine: Record "Sales Line"; GLAccount: Record "G/L Account"; SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignItemValues(var SalesLine: Record "Sales Line"; Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignItemChargeValues(var SalesLine: Record "Sales Line"; ItemCharge: Record "Item Charge"; SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignResourceValues(var SalesLine: Record "Sales Line"; Resource: Record Resource; SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignFixedAssetValues(var SalesLine: Record "Sales Line"; FixedAsset: Record "Fixed Asset"; SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignItemUOM(var SalesLine: Record "Sales Line"; Item: Record Item; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignResourceUOM(var SalesLine: Record "Sales Line"; Resource: Record Resource; ResourceUOM: Record "Resource Unit of Measure")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAutoReserve(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckItemAvailable(var SalesLine: Record "Sales Line"; CalledByFieldNo: Integer; HideValidationDialog: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckShipmentRelation(SalesLine: Record "Sales Line"; SalesShipmentLine: Record "Sales Shipment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckRetRcptRelation(SalesLine: Record "Sales Line"; ReturnReceiptLine: Record "Return Receipt Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromItem(var SalesLine: Record "Sales Line"; Item: Record Item; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromSalesLine(var SalesLine: Record "Sales Line"; FromSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromSalesShptLine(var SalesLine: Record "Sales Line"; FromSalesShipmentLine: Record "Sales Shipment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDeleteChargeChargeAssgnt(var SalesLine: Record "Sales Line"; var xSalesLine: Record "Sales Line"; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFilterLinesWithItemToPlan(var SalesLine: Record "Sales Line"; var Item: Record Item; DocumentType: Option)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFilterLinesForReservation(var SalesLine: Record "Sales Line"; ReservationEntry: Record "Reservation Entry"; DocumentType: Enum "Sales Document Type"; AvailabilityFilter: Text; Positive: Boolean)
    begin
    end;

#if not CLEAN19
    [Obsolete('Replaced by the new implementation (V16) of price calculation.', '16.0')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterFindResUnitCost(var SalesLine: Record "Sales Line"; var ResourceCost: Record "Resource Cost")
    begin
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetFAPostingGroup(var SalesLine: Record "Sales Line"; GLAccount: Record "G/L Account")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetItemTranslation(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; ItemTranslation: Record "Item Translation")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetSalesHeader(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"; var Currency: Record Currency)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetUnitCost(var SalesLine: Record "Sales Line"; Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetDefaultBin(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterHasTypeToFillMandatoryFields(var SalesLine: Record "Sales Line"; var ReturnValue: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitQtyToAsm(var SalesLine: Record "Sales Line"; CallingFieldNo: Integer; xSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetSalesSetup(var SalesLine: Record "Sales Line"; var SalesSetup: Record "Sales & Receivables Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIsCreditDocType(SalesLine: Record "Sales Line"; var CreditDocType: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterOpenItemTrackingLines(SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPickPrice(var SalesLine: Record "Sales Line"; var PriceCalculation: Interface "Price Calculation")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetSalesHeader(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"; var Currency: Record Currency)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterShowNonStock(var SalesLine: Record "Sales Line"; NonstockItem: Record "Nonstock Item")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateLineDiscPct(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdatePrePaymentAmounts(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateUnitPrice(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CalledByFieldNo: Integer; CurrFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAddItem(var SalesLine: Record "Sales Line"; LastSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddItems(var SalesLine: Record "Sales Line"; SelectionFilter: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAutoReserve(var SalesLine: Record "Sales Line"; var IsHandled: Boolean; xSalesLine: Record "Sales Line"; FullAutoReservation: Boolean; var ReserveSalesLine: Codeunit "Sales Line-Reserve")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcBaseQty(var SalesLine: Record "Sales Line"; Qty: Decimal; FromFieldName: Text; ToFieldName: Text);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcInvDiscToInvoice(var SalesLine: Record "Sales Line"; CallingFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcPlannedShptDate(var SalesLine: Record "Sales Line"; var PlannedShipmentDate: Date; CallingFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcPrepmtToDeduct(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcVATAmountLines(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var VATAmountLine: Record "VAT Amount Line"; var IsHandled: Boolean; QtyType: Option General,Invoicing,Shipping)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCallItemTracking(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckAssocPurchOrder(var SalesLine: Record "Sales Line"; TheFieldCaption: Text[250]; var IsHandled: Boolean; xSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckAsmToOrder(var SalesLine: Record "Sales Line"; AsmHeader: Record "Assembly Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckApplFromItemLedgEntry(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; var ItemLedgerEntry: Record "Item Ledger Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckBinCodeRelation(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckItemAvailable(var SalesLine: Record "Sales Line"; CalledByFieldNo: Integer; var IsHandled: Boolean; CurrentFieldNo: Integer; xSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckLinkedBlanketOrderLineOnDelete(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCleanSpecialOrderFieldsAndCheckAssocPurchOrder(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCleanPurchaseLineSpecialOrderFields(SalesLine: Record "Sales Line"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyFromItem(var SalesLine: Record "Sales Line"; Item: Record Item; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindNoByDescription(SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; var CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindOrCreateRecordByNo(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFormatType(SalesLine: Record "Sales Line"; var FormattedType: Text[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetCPGInvRoundAcc(SalesHeader: Record "Sales Header"; Customer: Record Customer; var AccountNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetAbsMin(SalesLine: Record "Sales Line"; QtyToHandle: Decimal; QtyHandled: Decimal; var Result: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetFAPostingGroup(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetDefaultBin(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetItemTranslation(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetSalesHeader(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"; var IsHanded: Boolean; var Currency: Record Currency)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetUnitCost(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetDeferralAmount(var SalesLine: Record "Sales Line"; var IsHandled: Boolean; var DeferralAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetReservationQty(var SalesLine: Record "Sales Line"; var QtyReserved: Decimal; var QtyReservedBase: Decimal; var QtyToReserve: Decimal; var QtyToReserveBase: Decimal; var Result: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitHeaderLocactionCode(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitOutstandingAmount(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitQty(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; IsAsmToOrderAlwd: Boolean; IsAsmToOrderRqd: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitQtyToAsm(var SalesLine: Record "Sales Line"; CallingFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitQtyToReceive(var SalesLine: Record "Sales Line"; FieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitQtyToShip(var SalesLine: Record "Sales Line"; FieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitType(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; var IsHandled: Boolean; var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsAsmToOrderRequired(SalesLine: Record "Sales Line"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLookupShortcutDimCode(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; FieldNumber: Integer; var ShortcutDimCode: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeMaxQtyToInvoice(SalesLine: Record "Sales Line"; var MaxQty: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeMaxQtyToInvoiceBase(SalesLine: Record "Sales Line"; var MaxQty: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSelectMultipleItems(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetDefaultItemQuantity(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetDefaultQuantity(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetSalesHeader(SalesHeader: record "Sales Header");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowDimensions(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSignedXX(var SalesLine: Record "Sales Line"; var Value: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowItemSub(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowReservation(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowReservationEntries(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestJobPlanningLine(var SalesLine: Record "Sales Line"; var IsHandled: Boolean; CallingFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestStatusOpen(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"; var IsHandled: Boolean; xSalesLine: Record "Sales Line"; CallingFieldNo: Integer; var StatusCheckSuspended: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestQtyFromLindDiscountAmount(var SalesLine: Record "Sales Line"; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateDates(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdatePrepmtAmounts(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; var IsHandled: Boolean; xSalesLine: Record "Sales Line"; FieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdatePrepmtSetupFields(var SalesLine: Record "Sales Line"; var IsHandled: Boolean; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateLineDiscPct(var SalesLine: Record "Sales Line"; var IsHandled: Boolean; Currency: Record Currency)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateUnitPrice(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CalledByFieldNo: Integer; CurrFieldNo: Integer; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateUnitPriceProcedure(var SalesLine: Record "Sales Line"; CalledByFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateAmounts(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateVATAmounts(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateVATOnLines(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var VATAmountLine: Record "VAT Amount Line"; var IsHandled: Boolean; QtyType: Integer);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateWithWarehouseShip(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateQuantityFromUOMCode(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateQtyToAsmFromSalesLineQtyToShip(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateReturnReasonCode(var SalesLine: Record "Sales Line"; CallingFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidatePurchasingCode(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateUnitOfMeasureCodeFromNo(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateLineAmount(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidatePrepmtAmttoDeduct(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidatePrepmtLineAmount(var SalesLine: Record "Sales Line"; PrePaymentLineAmountEntered: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateBlanketOrderNo(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateType(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateQtytoAsmtoOrderBase(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateQtyToInvoiceBase(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateQtyToShipBase(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateReturnQtyToReceiveBase(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeVerifyReservedQty(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CalledByFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeZeroAmountLine(var SalesLine: Record "Sales Line"; QtyType: Option General,Invoicing,Shipping; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcVATAmountLinesOnBeforeAssignAmtToHandle(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var VATAmountLine: Record "VAT Amount Line"; IncludePrepayments: Boolean; QtyType: Option; var QtyToHandle: Decimal; var AmtToHandle: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcVATAmountLinesOnBeforeQtyTypeGeneralCase(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var VATAmountLine: Record "VAT Amount Line"; IncludePrepayments: Boolean; QtyType: Option; var QtyToHandle: Decimal; var AmtToHandle: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcVATAmountLinesOnBeforeAssignQuantities(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var VATAmountLine: record "VAT Amount Line"; var QtyToHandle: Decimal; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcVATAmountLinesOnBeforeQtyTypeCase(var VATAmountLine: Record "VAT Amount Line"; var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitHeaderDefaults(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; xSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitOutstanding(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitOutstandingQty(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitOutstandingAmount(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; Currency: Record Currency)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitQtyToInvoice(var SalesLine: Record "Sales Line"; CurrFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitQtyToShip(var SalesLine: Record "Sales Line"; CurrFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitQtyToShip2(var SalesLine: Record "Sales Line"; CurrFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitQtyToReceive(var SalesLine: Record "Sales Line"; CurrFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitType(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcLineAmount(var SalesLine: Record "Sales Line"; var LineAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcInvDiscToInvoice(var SalesLine: Record "Sales Line"; OldInvDiscAmtToInv: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcVATAmountLines(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var VATAmountLine: Record "VAT Amount Line"; QtyType: Option General,Invoicing,Shipping)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetLineAmountToHandle(SalesLine: Record "Sales Line"; QtyToHandle: Decimal; var LineAmount: Decimal; var LineDiscAmount: Decimal)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterGetLineWithPrice(var LineWithPrice: Interface "Line With Price")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetSKU(SalesLine: Record "Sales Line"; var Result: Boolean; var StockkeepingUnit: Record "Stockkeeping Unit")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSalesTaxCalculate(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; Currency: Record Currency)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSalesTaxCalculateReverse(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; Currency: Record Currency)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetReserveWithoutPurchasingCode(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterShowDimensions(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateAmounts(var SalesLine: Record "Sales Line"; var xSalesLine: Record "Sales Line"; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateAmountsDone(var SalesLine: Record "Sales Line"; var xSalesLine: Record "Sales Line"; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateBaseAmounts(var SalesLine: Record "Sales Line"; var xSalesLine: Record "Sales Line"; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateDates(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateItemReference(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateVATAmounts(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateVATOnLines(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var VATAmountLine: Record "VAT Amount Line"; QtyType: Option General,Invoicing,Shipping)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateWithWarehouseShip(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDim(var SalesLine: Record "Sales Line"; CallingFieldNo: Integer);
    begin
    end;

#if not CLEAN20
    [Obsolete('Temporary event for compatibility', '20.0')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDimTableIDs(var SalesLine: Record "Sales Line"; CallingFieldNo: Integer; var TableID: array[10] of Integer; var No: array[10] of Code[20])
    begin
    end;
#endif
    [IntegrationEvent(false, false)]
    local procedure OnAfterSetReservationFilters(var ReservEntry: Record "Reservation Entry"; SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterShowItemSub(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateICPartner(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateReturnReasonCode(var SalesLine: Record "Sales Line"; CallingFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertOnAfterCheckInventoryConflict(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; var SalesLine2: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertFreightLineOnAfterCheckDocumentNo(var SalesLine: Record "Sales Line"; var SalesLineRec: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitQtyToShip2OnBeforeCalcInvDiscToInvoice(var SalesLine: Record "Sales Line"; var xSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitQtyToAsmOnAfterCalcShouldUpdateQtyToAsm(var SalesLine: Record "Sales Line"; CallingFieldNo: Integer; xSalesLine: Record "Sales Line"; var ShouldUpdateQtyToAsm: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnShowLineCommentsOnAfterSetFilters(var SalesCommentLine: Record "Sales Comment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnShowItemChargeAssgntOnBeforeCalcItemCharge(var SalesLine: Record "Sales Line"; var ItemChargeAssgntLineAmt: Decimal; Currency: Record Currency; var IsHandled: Boolean; var ItemChargeAssgntSales: Record "Item Charge Assignment (Sales)")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnShowItemChargeAssgntOnAfterCurrencyInitialize(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"; var Currency: Record Currency)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateLineDiscPctOnAfterCalcIsOutOfStandardDiscPctRange(var SalesLine: Record "Sales Line"; var IsOutOfStandardDiscPctRange: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateUnitPriceByFieldOnAfterFindPrice(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; CalledByFieldNo: Integer; CallingFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateUnitPriceOnBeforeFindPrice(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; CalledByFieldNo: Integer; CallingFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateLocationCodeOnBeforeSetShipmentDate(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateTypeOnAfterCheckItem(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateTypeOnCopyFromTempSalesLine(var SalesLine: Record "Sales Line"; var TempSalesLine: Record "Sales Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateNoOnAfterInitHeaderDefaults(var SalesHeader: Record "Sales Header"; var TempSalesLine: Record "Sales Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateNoOnAfterUpdateUnitPrice(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; var TempSalesLine: Record "Sales Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateNoOnAfterVerifyChange(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateNoOnCopyFromTempSalesLine(var SalesLine: Record "Sales Line"; var TempSalesLine: Record "Sales Line" temporary; xSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateNoOnBeforeInitHeaderDefaults(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateNoOnBeforeInitRec(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CallingFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnValidateNoOnBeforeCalcShipmentDateForLocation(var IsHandled: Boolean; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateNoOnBeforeUpdateDates(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; CallingFieldNo: Integer; var IsHandled: Boolean; var TempSalesLine: Record "Sales Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateQuantityOnAfterCalcBaseQty(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateQuantityOnBeforeGetUnitCost(var SalesLine: Record "Sales Line"; Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateQuantityOnBeforeResetAmounts(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateQtyToShipAfterInitQty(var SalesLine: Record "Sales Line"; var xSalesLine: Record "Sales Line"; CallingFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateQtyToShipOnAfterCheck(var SalesLine: Record "Sales Line"; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateQtyToReturnAfterInitQty(var SalesLine: Record "Sales Line"; var xSalesLine: Record "Sales Line"; CallingFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateReturnQtyToReceiveOnAfterCheck(var SalesLine: Record "Sales Line"; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateShipmentDateOnAfterSalesLineVerifyChange(var SalesLine: Record "Sales Line"; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateVariantCodeOnAfterChecks(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CallingFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateVATProdPostingGroupOnBeforeCheckVATCalcType(var SalesLine: Record "Sales Line"; VATPostingSetup: Record "VAT Posting Setup"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateVATProdPostingGroupOnBeforeUpdateUnitPrice(var SalesLine: Record "Sales Line"; VATPostingSetup: Record "VAT Posting Setup"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTestStatusOpen(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSelectMultipleItems(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetDefaultQuantity(var SalesLine: Record "Sales Line"; var xSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateTotalAmounts(var SalesLine: Record "Sales Line"; SalesLine2: Record "Sales Line"; var TotalAmount: Decimal; var TotalAmountInclVAT: Decimal; var TotalLineAmount: Decimal; var TotalInvDiscAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckWarehouseOnAfterSetLocation2(var SalesLine: Record "Sales Line"; var Location2: Record Location)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckWarehouseOnBeforeShowDialog(var SalesLine: Record "Sales Line"; Location: Record Location; var ShowDialog: Option " ",Message,Error; var DialogText: Text[50])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcShipmentDateOnPlannedShipmentDate(SalesLine: Record "Sales Line"; var ShipmentDate: Date; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyFromItemOnAfterCheck(var SalesLine: Record "Sales Line"; Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyFromResourceOnBeforeTestBlocked(var Resoiurce: Record Resource; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateDimOnBeforeUpdateGlobalDimFromDimSetID(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetDeferralPostDate(SalesHeader: Record "Sales Header"; var DeferralPostingDate: Date; SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAutoAsmToOrder(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAutoAsmToOrder(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBlanketOrderLookup(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeBlanketOrderLookup(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcPlannedDeliveryDate(var SalesLine: Record "Sales Line"; var PlannedDeliveryDate: Date; CallingFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetGetFAPostingGroupOnBeforeExit(var SalesLine: Record "Sales Line"; var ShouldExit: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOpenItemTrackingLines(SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckCreditLimitCondition(SalesLine: Record "Sales Line"; var RunCheck: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateShortcutDimCode(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateItemChargeAssgnt(var SalesLine: Record "Sales Line"; var InHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateUnitPriceFromNonstockItem(var SalesLine: Record "Sales Line"; NonstockItem: Record "Nonstock Item"; var InHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateDescription(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CurrentFieldNo: Integer; var InHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeValidatePlannedDeliveryDate(var IsHandled: Boolean; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeValidatePlannedShipmentDate(var IsHandled: Boolean; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateQuantityBase(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CallingFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateShortcutDimCode(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; FieldNumber: Integer; var ShortcutDimCode: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeVerifyItemLineDim(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnUpdateAmountsOnAfterCalcLineAmount(var SalesLine: Record "Sales Line"; var LineAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateAmountOnBeforeCheckCreditLimit(var SalesLine: Record "Sales Line"; var IsHandled: Boolean; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnUpdateAmountsOnBeforeCheckLineAmount(var IsHandled: Boolean; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateVATOnLinesOnBeforeCalculateNewAmount(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; VATAmountLine: Record "VAT Amount Line"; VATAmountLineReminder: Record "VAT Amount Line"; var NewAmount: Decimal; var VATAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateVATOnLinesOnAfterCalculateAmounts(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateVATOnLinesOnAfterCalculateNewAmount(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; VATAmountLine: Record "VAT Amount Line"; VATAmountLineReminder: Record "VAT Amount Line"; var NewAmountIncludingVAT: Decimal; VATAmount: Decimal; var NewAmount: Decimal; var NewVATBaseAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateVATOnLinesOnAfterSalesLineSetFilter(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateVATOnLinesOnBeforeModifySalesLine(var SalesLine: Record "Sales Line"; VATAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateVATOnLinesOnBeforeCalculateAmounts(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateVATOnLinesOnBeforeTempVATAmountLineRemainderModify(SalesLine: Record "Sales Line"; var TempVATAmountLineRemainder: Record "VAT Amount Line"; VATAmount: Decimal; NewVATBaseAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateVATOnLinesOnAfterCurrencyInitialize(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"; var Currency: Record Currency)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateDescriptionOnBeforeCannotFindDescrError(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateLocationCodeOnAfterSetOutboundWhseHandlingTime(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcVATAmountLinesOnAfterCalcLineTotals(var VATAmountLine: Record "VAT Amount Line"; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; Currency: Record Currency; QtyType: Option General,Invoicing,Shipping; var TotalVATAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcVATAmountLinesOnAfterSetFilters(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcVATAmountLinesOnAfterCalcShouldProcessRounding(var VATAmountLine: Record "VAT Amount Line"; Currency: Record Currency; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcVATAmountLinesOnBeforeVATAmountLineUpdateLines(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcVATAmountLinesOnAfterCurrencyInitialize(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"; var Currency: Record Currency)
    begin
    end;

#if not CLEAN18
    [Obsolete('Replaced by same event in Item Reference Management codeunit.', '18.0')]
    [IntegrationEvent(false, false)]
    local procedure OnCrossReferenceNoLookUpOnAfterSetFilters(var ItemCrossReference: Record "Item Cross Reference"; SalesLine: Record "Sales Line")
    begin
    end;
#endif

#if not CLEAN18
    [Obsolete('Replaced by same event in Item Reference Management codeunit.', '18.0')]
    [IntegrationEvent(false, false)]
    local procedure OnCrossReferenceNoLookupOnBeforeValidateUnitPrice(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnDeleteOnAfterSetSalesLineFilters(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeleteOnBeforeTestStatusOpen(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

#if not CLEAN19
    [Obsolete('Replaced by the new implementation (V16) of price calculation.', '19.0')]
    [IntegrationEvent(false, false)]
    local procedure OnFindResUnitCostOnAfterInitResCost(var SalesLine: Record "Sales Line"; var ResourceCost: Record "Resource Cost")
    begin
    end;
#endif
    [IntegrationEvent(true, false)]
    local procedure OnLookUpICPartnerReferenceTypeCaseElse()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateVATAmountsOnAfterSetSalesLineFilters(var SalesLine: Record "Sales Line"; var SalesLine2: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateVATAmountsOnBeforeValidateLineDiscountPercent(var SalesLine: Record "Sales Line"; var StatusCheckSuspended: boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateVATAmountsOnBeforeCalcAmounts(var SalesLine: Record "Sales Line"; var SalesLine2: Record "Sales Line"; var TotalAmount: Decimal; TotalAmountInclVAT: Decimal; var TotalLineAmount: Decimal; var TotalInvDiscAmount: Decimal; var TotalVATBaseAmount: Decimal; var TotalQuantityBase: Decimal; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSelectItemEntryOnAfterSetFilters(var ItemLedgEntry: Record "Item Ledger Entry"; SalesLine: Record "Sales Line"; CurrFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateAmountIncludingVATOnAfterAssignAmounts(var SalesLine: Record "Sales Line"; Currency: Record Currency);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateLineAmountOnbeforeTestUnitPrice(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidatePrepaymentPercentageOnBeforeUpdatePrepmtSetupFields(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateQuantityOnBeforeCheckAssocPurchOrder(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateQuantityOnBeforeCheckReceiptOrderStatus(var SalesLine: Record "Sales Line"; StatusCheckSuspended: Boolean; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateQuantityOnBeforeSalesLineVerifyChange(var SalesLine: Record "Sales Line"; StatusCheckSuspended: Boolean; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateQuantityOnBeforeValidateQtyToAssembleToOrder(var SalesLine: Record "Sales Line"; StatusCheckSuspended: Boolean; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidatePurchasingCodeOnAfterAssignPurchasingFields(var SalesLine: Record "Sales Line"; PurchasingCode: Record Purchasing; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidatePurchasingCodeOnAfterSetReserveWithoutPurchasingCode(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidatePurchasingCodeOnAfterResetPurchasingFields(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateVATProdPostingGroupOnBeforeUpdateAmounts(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; Currency: Record Currency)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowDeferrals(SalesLine: Record "Sales Line"; var ReturnValue: Boolean; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckWarehouse(SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckWarehouseForQtyToShip(SalesLine: Record "Sales Line"; CurrentFieldNo: Integer; var IsHandled: Boolean; xSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCreateDim(var IsHandled: Boolean; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowUnitPriceChangedMsg(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeValidateUnitCostLCYOnGetUnitCost(var IsHandled: Boolean; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeValidateWorkTypeCode(xSalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeValidateJobContractEntryNo(xSalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateNo(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeValidateShipmentDate(var IsHandled: Boolean; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeValidateVATProdPostingGroup(var IsHandled: Boolean; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeValidateVATProdPostingGroupTrigger(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeAssignResourceUoM(var ResUnitofMeasure: Record "Resource Unit of Measure"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckPromisedDeliveryDate(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckPrepmtAmtInvEmpty(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeValidateBlanketOrderLineNo(var IsHandled: Boolean; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCheckShipmentRelation(var IsHandled: Boolean; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCheckShipmentDateBeforeWorkDate(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; var HasBeenShown: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCheckRetRcptRelation(var IsHandled: Boolean; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitQtyToShipOnBeforeCheckServItemCreation(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeVerifyChangeForSalesLineReserve(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CallingFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckInventoryPickConflict(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckApplFromItemLedgEntryOnBeforeTestFieldType(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckQuantitySign(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckReservedQtyBase(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckNotInvoicedQty(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowReturnedUnitsError(var SalesLine: Record "Sales Line"; var ItemLedgEntry: Record "Item Ledger Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateLineDiscountPercent(var SalesLine: Record "Sales Line"; CurrFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateLineDiscountPercentOnBeforeUpdateAmounts(var SalesLine: Record "Sales Line"; CurrFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateLineDiscountPercentOnAfterTestStatusOpen(var SalesLine: Record "Sales Line"; var xSalesLine: Record "Sales Line"; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowNonStock(var SalesLine: Record "Sales Line"; var NonstockItem: Record "Nonstock Item"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnShowNonstockOnBeforeOpenCatalogItemList(var SalesLine: Record "Sales Line"; var NonstockItem: Record "Nonstock Item")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateLocationCodeOnAfterCheckAssocPurchOrder(var SalesLine: Record "Sales Line")
    begin
    end;

#if not CLEAN20
    [Obsolete('Replaced with OnValidateLocationCodeOnAfterCheckAssocPurchOrder and OnBeforeInitHeaderLocactionCode', '20.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateLocationCode(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;
#endif
}

