table 27 Item
{
    // PR2.00
    //   Change Quarantine Period to Quarantine Calculation (DateFormula)
    //   Remove Shelf Life - map to Expiration Calculation
    //   Remove Lot Controlled - replace with Item Tacking Code
    //   Remove Lot No. Series - map to Lot Nos.
    //   Item Tracking Code - OnValidate - check for existing quality tests
    // 
    // PR2.00.05
    //   Production BOM No. - check for variables
    //   Variant Filter - change table relation
    //   Forecast Quantity - change CalcFormula to use variants
    // 
    // PR3.60
    //   Add fields/logic for alternate unit of measure
    // 
    // PR3.60.02
    //   Remove OnLookup code for UOM fields - moved to forms
    // 
    // PR3.61
    //   Add Container to Item Type option string
    //   Add fields
    //     Container Sales Processing
    //     Tare Weight
    //     Tare Unit of Measure
    //     Capacity
    //     Capacity Unit of Measure
    // 
    // PR3.70
    //   Remove Bin Filter from flowfield calculations
    //   Cross checking of Flushing Method and Catch Alternate Qtys.
    // 
    // PR3.70.01
    //   Fix problem deleting items with sales price table and sales line discount
    // 
    // PR3.70.02
    //   Add Field
    //     Case Label Code
    // 
    // PR3.70.03
    //   Add field
    //     Proper Shipping Name
    //   Add function
    //     GetItemUOMRndgPrecision
    //   Change validation on Production BOM No. to allow Process to be associated with co-products
    //   Update BOM cost when unit cost is changed
    // 
    // PR3.70.06
    // P8000078A, Myers Nissi, Steve Post, 26 JUL 04
    //   Added fields
    //     37002469 Exclude from Sales Forecast
    //     37002470 Sales (Qty.) for Forecast
    // 
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Maintain lot preferences and item category code on lot info
    // 
    // PR3.70.08
    // P8000171B, Myers Nissi, Jack Reynolds, 20 JAN 05
    //   Modify flow field definitions for Quantity on Hand (Alt.) and Net Invoiced Qty. (Alt.) to include lot and serial
    //     number flow filters
    // 
    // P8000186B, Myers Nissi, Jack Reynolds, 16 FEB 05
    //   Check for existing entries when changing Catch Alternate Qtys.
    // 
    // PR3.70.10
    // P8000220A, Myers Nissi, Jack Reynolds, 14 JUN 05
    //   Update BOM cost when changing unit cost only if properly licensed
    // 
    // PR4.00
    // P8000219A, Myers Nissi, Jack Reynolds, 24 JUN 05
    //   Set routing based on preferred equipment
    // 
    // P8000239A, Myers Nissi, Jack Reynolds, 11 AUG 05
    //   Flowfield added - Net Change (Alt.)
    // 
    // P8000250B, Myers Nissi, Jack Reynolds, 18 OCT 05
    //   Add field for Lot No. Assignment Method
    // 
    // PR4.00.02
    // P8000293A, VerticalSoft, Jack Reynolds, 10 FEB 06
    //   ConsumptionQty - function duplicates flowfield (for world wide version)
    // 
    // P8000312A, VerticalSoft, Jack Reynolds, 17 MAR 06
    //   Add fields for Purchasing Group Code and Usage Formula
    // 
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 30 AUG 06
    //   Maintenance management - Item Type (Spare), Part No.
    // 
    // P8000383A, VerticalSoft, Jack Reynolds, 22 SEP 06
    //   Insure that alternate unit of measure is different type of sales and purch. unit of measure
    // 
    // PR5.00
    // P8000494A, VerticalSoft, Don Bresee, 18 JUL 07
    //   Add Production Bins/Replenishment
    //   Add Fixed Production Bin / Alt. Qty. restriction
    // 
    // P8000495A, VerticalSoft, Don Bresee, 18 JUL 07
    //   Add Combining of Lots
    // 
    // P8000503A, VerticalSoft, Don Bresee, 18 JUL 07
    //   Add Whse. Picking Not Required
    // 
    // PRW15.00.01
    // P8000581A, VerticalSoft, Jack Reynolds, 20 FEB 08
    //   Remove "Exclude From Sales Forecast"
    // 
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   Add field for pick class
    // 
    // P8000599A, VerticalSoft, Don Bresee, 28 MAY 08
    //   Change ID for BOMComp variable
    // 
    // PRW15.00.03
    // P8000624A, VerticalSoft, Jack Reynolds, 19 AUG 08
    //   Add field to indicate if a country of origin is required when creating new lots for the item
    // 
    // PRW16.00
    // P8000639, VerticalSoft, Jack Reynolds, 17 NOV 08
    //   Add Item Type to DropDown field group
    // 
    // PRW16.00.01
    // P8000678, VerticalSoft, Don Bresee, 23 FEB 09
    //   Add "ESHA Code" field, key
    // 
    // PRW16.00.02
    // P8000764, VerticalSoft, Jack Reynolds, 01 FEB 10
    //    Add key for Item Category Code for Production Yield & Cost Report
    // 
    // PRW16.00.03
    // P8000835, VerticalSoft, Jack Reynolds, 14 JUN 10
    //  Fix problem with ConsumptionQty function
    // 
    // PRW16.00.04
    // P8000856, VerticalSoft, Don Bresee, 24 AUG 10
    //   Add Commodity Class Costing granule
    // 
    // P8000868, VerticalSoft, Rick Tweedle, 13 SEP 10
    //   Added Genesis Enhancements
    // 
    // P8000869, VerticalSoft, Jack Reynolds, 28 SEP 10
    //   Add Variant to calculation of Prod. Forecast Qquantity flowfield
    // 
    // P8000876, VerticalSoft, Jack Reynolds, 18 OCT 10
    //   Support for item attributes
    // 
    // P8000891, VerticalSoft, Don Bresee, 04 JAN 11
    //   Add Commodity Receiving logic
    // 
    // P8000899, Columbus IT, Ron Davidson, 16 FEB 11
    //   Added Freshness Calc. Method and Shelf Life fields.
    // 
    // P8000902, Columbus IT, Don Bresee, 14 MAR 11
    //   Add Commodity Payment logic
    // 
    // PRW16.00.05
    // P8000931, Columbus IT, Jack Reynolds, 20 APR 11
    //   Support for Supply Chain Groups
    // 
    // P8000936, Columbus IT, Jack Reynolds, 25 APR 11
    //   Support for Repack Orders on Sales Board
    // 
    // P8000969, Columbus IT, Jack Reynolds, 12 AUG 11
    //   Fix problem with Freshness Calc. Method
    // 
    // P8000968, Columbus IT, Jack Reynolds, 16 AUG 11
    //   Support for Item Slots
    // 
    // P8000979, Columbus IT, Don Bresee, 14 SEP 11
    //   Add "TraceAltQty" function
    // 
    // P8000981, Columbus IT, Don Bresee, 20 SEP 11
    //   Change "Costing/Pricing Unit" field to "Costing Unit", add "Pricing Unit" field
    // 
    // PRW16.00.06
    // P8001039, Columbus IT, Don Bresee, 27 FEB 12
    //   Add "Near-Zero Qty. Value" field
    // 
    // P8001047, Columbus IT, Jack Reynolds, 30 MAR 12
    //   Receiving Labels
    // 
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // P8001092, Columbus IT, Don Bresee, 17 AUG 12
    //   Add Costing Method validation for By-Products (must be Standard)
    //   Add Variant Code for Item and Co-Product processes
    // 
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // P8001123, Columbus IT, Jack Reynolds, 19 DEC 12
    //   Move Item table Label Code fields to Item Label table
    // 
    // PRW17.00
    // P8001144, Columbus IT, Don Bresee, 26 MAR 13
    //   Integrate P800 features into new NAV item availability logic
    // 
    // PRW17.10
    // P8001213, Columbus IT, Jack Reynolds, 26 SEP 13
    //   NAV 2013 R2 changes
    // 
    // P8001221, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Type added to Item table
    // 
    // P8001230, Columbus IT, Jack Reynolds, 18 OCT 13
    //   Support for approved vendors
    // 
    // P8001234, Columbus IT, Jack Reynolds, 01 NOV 13
    //    Support for custom lot number formats
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality
    // 
    // PRW19.00
    // P8006676, To-Increase, Jack Reynolds, 31 MAR 16
    //   Fix problem with Item Type and Non-Warehouse Item
    // 
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // P8007750, To-Increase, Jack Reynolds, 07 NOV 16
    //   Convert Food Item Attributes to NAV Item Attributes
    // 
    // P8008171, To-Increase, Dayakar Battini, 09 DEC 16
    //   Lifecycle Management
    // 
    // PRW110.0.01
    // P80041198, To-Increase, Jack Reynolds, 08 MAY 17
    //   General changes and refactoring for NAV 2017 CU7
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.02
    // P80064675, To Increase, Jack Reynolds, 13 SEP 18
    //   Fix pro blem with Item Type and Non-Warehouse Item
    // 
    // PRW111.00.03
    // P80079197, To-Increase, Gangabhushan, 24 JUL 19
    //   TI-13290-Request for New Events
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW119.0
    // P800133109, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 19.0 - Qty. Rounding Precision
    //
    // PRW119.03
    // P800144674, To-Increase, Gangabhushan, 01 JUN 22
    //   Q/C templates can be added to Items without Item Tracking Code

    Caption = 'Item';
    DataCaptionFields = "No.", Description;
    DrillDownPageID = "Item List";
    LookupPageID = "Item Lookup";
    Permissions = TableData "Service Item" = rm,
                  TableData "Service Item Component" = rm,
                  TableData "Bin Content" = d;

    fields
    {
        field(11068780; "Status Code"; Code[20])
        {
            ObsoleteState = Pending;
        }
        field(37002000; "Item Type"; Option)
        {
            Caption = 'Item Type';
            Description = 'PR1.00';
            OptionCaption = ' ,Raw Material,Packaging,Intermediate,Finished Good,Container,Spare';
            OptionMembers = " ","Raw Material",Packaging,Intermediate,"Finished Good",Container,Spare;

            trigger OnValidate()
            begin
                // P8001221
                if "Item Type" <> 0 then
                    // TESTFIELD(Type,Type::Inventory);                     // P8001290
                    if not (Type in [Type::Inventory, Type::FOODContainer]) then // P8001290
                        FieldError(Type);                                     // P8001290
                // P8001221

                if ("Item Type" = "Item Type"::Container) and (not "Non-Warehouse Item") then // P8006676
                    Validate("Non-Warehouse Item", true);                                        // P8006676

                if ("Item Type" <> "Item Type"::Container) and "Non-Warehouse Item" then // P80064675
                    Validate("Non-Warehouse Item", false);                                  // P80064675

                CheckContainerTypes(FieldCaption("Item Type")); // P8001305
            end;
        }
        field(37002001; "Proper Shipping Name"; Code[10])
        {
            Caption = 'Proper Shipping Name';
            Description = 'PR3.70.03';
            TableRelation = "Proper Shipping Name";
        }
        field(37002002; "Near-Zero Qty. Value"; Decimal)
        {
            BlankZero = true;
            Caption = 'Near-Zero Qty. Value';
            DecimalPlaces = 0 : 5;
            Description = 'P8001039';
            MinValue = 0;
        }
        field(37002003; "Vendor Approval Required"; Option)
        {
            Caption = 'Vendor Approval Required';
            OptionCaption = ' ,No,Yes';
            OptionMembers = " ",No,Yes;

            trigger OnValidate()
            begin
                // P8001230
                if "Vendor Approval Required" <> xRec."Vendor Approval Required" then
                    if VendorApprovalRequired then begin
                        if "Vendor No." <> '' then
                            CheckApprovedVendor;
                        CheckSKUApprovedVendor;
                        CheckDocumentApprovedVendor;
                    end;
            end;
        }
        field(37002004; "Item Category Order"; Integer)
        {
            CalcFormula = Lookup("Item Category"."Presentation Order" WHERE(Code = FIELD("Item Category Code")));
            Caption = 'Item Category Order';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002005; "Old Unit Cost"; Decimal)
        {
            Caption = 'Old Unit Cost';
        }
        field(37002015; "Supply Chain Group Code"; Code[10])
        {
            Caption = 'Supply Chain Group Code';
            TableRelation = "Supply Chain Group";
        }
        field(37002020; "Quarantine Calculation"; DateFormula)
        {
            Caption = 'Quarantine Calculation';
            Description = 'PR2.00';
        }
        field(37002021; "Lot Strength"; Boolean)
        {
            Caption = 'Lot Strength';
            Description = 'PR1.10';
        }
        field(37002022; "Lot No. Assignment Method"; Option)
        {
            Caption = 'Lot No. Assignment Method';
            OptionCaption = 'No. Series,Doc. No.,Doc. No.+Suffix,Date,Date+Suffix,,,,,Custom';
            OptionMembers = "No. Series","Doc. No.","Doc. No.+Suffix",Date,"Date+Suffix",,,,,Custom;

            trigger OnValidate()
            begin
                // P8001234
                if "Lot No. Assignment Method" <> xRec."Lot No. Assignment Method" then
                    "Lot Nos." := '';
                // P8001234
            end;
        }
        field(37002023; "Freshness Calc. Method"; Option)
        {
            Caption = 'Freshness Calc. Method';
            OptionCaption = ' ,Days To Fresh,Best If Used By,Sell By';
            OptionMembers = " ","Days To Fresh","Best If Used By","Sell By";

            trigger OnValidate()
            begin
                if not UseFreshnessDate then // P8000969
                    Clear("Shelf Life");
            end;
        }
        field(37002024; "Shelf Life"; DateFormula)
        {
            Caption = 'Shelf Life';
        }
        field(37002040; "Price List Sequence No."; Code[10])
        {
            Caption = 'Price List Sequence No.';
            Description = 'PR3.60';
        }
        field(37002041; "Purchasing Group Code"; Code[10])
        {
            Caption = 'Purchasing Group Code';
            TableRelation = "Purchasing Group";
        }
        field(37002042; "Usage Formula"; Code[10])
        {
            Caption = 'Usage Formula';
            TableRelation = "Usage Formula";
        }
        field(37002060; "Pick Class Code"; Code[10])
        {
            Caption = 'Pick Class Code';
            TableRelation = "Pick Class";
        }
        field(37002080; "Alternate Unit of Measure"; Code[10])
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            Caption = 'Alternate Unit of Measure';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));

            trigger OnValidate()
            var
                ItemAltUnitOfMeasure: Record "Item Unit of Measure";
                BaseUnitOfMeasure: Record "Unit of Measure";
            begin
                // PR3.60
                TestNoEntriesExist(FieldCaption("Alternate Unit of Measure"));
                CheckJournalsAndWorksheets(FieldNo("Alternate Unit of Measure")); // P8001267, P80096141
                CheckDocuments(FieldNo("Alternate Unit of Measure"));             // P8001267, P80096141

                // P8000856
                if ProcessFns.CommCostInstalled() then
                    CommItemMgmt.ItemValidate(Rec, FieldNo("Alternate Unit of Measure"));
                // P8000856

                if ("Alternate Unit of Measure" = '') then begin
                    Validate("Costing Unit", "Costing Unit"::Base);
                    Validate("Catch Alternate Qtys.", false);
                end else begin
                    TestField(Type, Type::Inventory); // P8001290
                    ItemAltUnitOfMeasure.Get("No.", "Alternate Unit of Measure");
                    ItemAltUnitOfMeasure.CalcFields(Type);
                    TestField("Base Unit of Measure");
                    BaseUnitOfMeasure.Get("Base Unit of Measure");
                    if (BaseUnitOfMeasure.Type = ItemAltUnitOfMeasure.Type) then
                        Error(
                          Text37002003,
                          FieldCaption("Base Unit of Measure"),
                          FieldCaption("Alternate Unit of Measure"),
                          BaseUnitOfMeasure.TableName,
                          BaseUnitOfMeasure.FieldCaption(Type));
                    // P8000383A
                    AltQtyMgt.CheckUOMDifferentFromAltUOM(Rec, "Sales Unit of Measure", FieldCaption("Sales Unit of Measure"));
                    AltQtyMgt.CheckUOMDifferentFromAltUOM(Rec, "Purch. Unit of Measure", FieldCaption("Purch. Unit of Measure"));
                    // P8000383A
                    Validate("Costing Unit", "Costing Unit"::Alternate);
                    Validate("Catch Alternate Qtys.", true);
                    AltQtyMgt.CheckFixedBinAndAltQty(Rec); // P8000494A
                end;
                // PR3.60
            end;
        }
        field(37002081; "Costing Unit"; Option)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            Caption = 'Costing Unit';
            Description = 'PR3.60';
            OptionCaption = 'Base,Alternate';
            OptionMembers = Base,Alternate;

            trigger OnValidate()
            begin
                // PR3.60
                TestNoEntriesExist(FieldCaption("Costing Unit"));
                CheckJournalsAndWorksheets(FieldNo("Costing Unit")); // P8001267, P80096141
                CheckDocuments(FieldNo("Costing Unit"));             // P8001267, P80096141

                // P8000856
                if ProcessFns.CommCostInstalled() then
                    CommItemMgmt.ItemValidate(Rec, FieldNo("Costing Unit"));
                // P8000856

                if ("Costing Unit" = "Costing Unit"::Alternate) then
                    TestField("Alternate Unit of Measure");
                // PR3.60

                Validate("Pricing Unit", "Costing Unit"); // P8000981
            end;
        }
        field(37002082; "Catch Alternate Qtys."; Boolean)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            Caption = 'Catch Alternate Qtys.';
            Description = 'PR3.60';

            trigger OnValidate()
            begin
                // PR3.60
                TestNoEntriesExist(FieldCaption("Catch Alternate Qtys.")); // P8000186B
                CheckJournalsAndWorksheets(FieldNo("Catch Alternate Qtys.")); // P8001267, P80096141
                CheckDocuments(FieldNo("Catch Alternate Qtys."));             // P8001267, P80096141

                if not "Catch Alternate Qtys." then
                    Validate("Alternate Qty. Tolerance %", 0)
                else begin
                    TestField("Alternate Unit of Measure");
                    GetInvtSetup;
                    Validate("Alternate Qty. Tolerance %", InvtSetup."Default Alt. Qty. Tolerance %");
                    // PR3.70 Begin
                    if "Flushing Method" <> "Flushing Method"::Manual then begin
                        "Flushing Method" := "Flushing Method"::Manual;
                        Message(Text37002006, FieldCaption("Flushing Method"), "Flushing Method");
                    end;
                    // PR3.70 End
                end;
                // PR3.60
            end;
        }
        field(37002083; "Alternate Qty. Tolerance %"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            Caption = 'Alternate Qty. Tolerance %';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.60';
            MaxValue = 100;
            MinValue = 0;

            trigger OnValidate()
            begin
                // PR3.60
                if ("Alternate Qty. Tolerance %" <> 0) then
                    TestField("Catch Alternate Qtys.", true);
                // PR3.60
            end;
        }
        field(37002084; "Quantity on Hand (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            CalcFormula = Sum("Item Ledger Entry"."Quantity (Alt.)" WHERE("Item No." = FIELD("No."),
                                                                           "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                           "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                           "Location Code" = FIELD("Location Filter"),
                                                                           "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                           "Variant Code" = FIELD("Variant Filter")));
            CaptionClass = StrSubstNo('37002080,0,12,%1', "No.");
            Caption = 'Quantity on Hand (Alt.)';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.60';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002085; "Net Invoiced Qty. (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            CalcFormula = Sum("Item Ledger Entry"."Invoiced Quantity (Alt.)" WHERE("Item No." = FIELD("No."),
                                                                                    "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                                    "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                                    "Location Code" = FIELD("Location Filter"),
                                                                                    "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                                    "Variant Code" = FIELD("Variant Filter")));
            CaptionClass = StrSubstNo('37002080,0,13,%1', "No.");
            Caption = 'Net Invoiced Qty. (Alt.)';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.60';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002086; "Net Change (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            CalcFormula = Sum("Item Ledger Entry"."Quantity (Alt.)" WHERE("Item No." = FIELD("No."),
                                                                           "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                           "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                           "Location Code" = FIELD("Location Filter"),
                                                                           "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                           "Posting Date" = FIELD("Date Filter"),
                                                                           "Variant Code" = FIELD("Variant Filter"),
                                                                           "Lot No." = FIELD("Lot No. Filter"),
                                                                           "Serial No." = FIELD("Serial No. Filter")));
            Caption = 'Net Change (Alt.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002087; "Pricing Unit"; Option)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            Caption = 'Pricing Unit';
            OptionCaption = 'Base,Alternate';
            OptionMembers = Base,Alternate;

            trigger OnValidate()
            begin
                // P8000981
                if ("Pricing Unit" = "Pricing Unit"::Alternate) then
                    TestField("Alternate Unit of Measure");
            end;
        }
        field(37002210; "Qty. on Repack"; Decimal)
        {
            CalcFormula = Sum("Repack Order"."Quantity (Base)" WHERE(Status = CONST(Open),
                                                                      "Item No." = FIELD("No."),
                                                                      "Destination Location" = FIELD("Location Filter"),
                                                                      "Variant Code" = FIELD("Variant Filter"),
                                                                      "Due Date" = FIELD("Date Filter")));
            Caption = 'Qty. on Repack';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002211; "Qty. on Repack Line"; Decimal)
        {
            CalcFormula = Sum("Repack Order Line"."Quantity (Base)" WHERE(Status = CONST(Open),
                                                                           Type = CONST(Item),
                                                                           "No." = FIELD("No."),
                                                                           "Source Location" = FIELD("Location Filter"),
                                                                           "Variant Code" = FIELD("Variant Filter"),
                                                                           "Due Date" = FIELD("Date Filter")));
            Caption = 'Qty. on Repack Line';
            DecimalPlaces = 0 : 5;
            FieldClass = FlowField;
        }
        field(37002212; "Qty. on Repack Line-Trans. Out"; Decimal)
        {
            CalcFormula = Sum("Repack Order Line"."Quantity Transferred (Base)" WHERE(Status = CONST(Open),
                                                                                       Type = CONST(Item),
                                                                                       "No." = FIELD("No."),
                                                                                       "Source Location" = FIELD("Location Filter"),
                                                                                       "Variant Code" = FIELD("Variant Filter"),
                                                                                       "Due Date" = FIELD("Date Filter")));
            Caption = 'Qty. on Repack Line-Trans. Out';
            DecimalPlaces = 0 : 5;
            FieldClass = FlowField;
        }
        field(37002213; "Qty. on Repack Line-Trans. In"; Decimal)
        {
            CalcFormula = Sum("Repack Order Line"."Quantity Transferred (Base)" WHERE(Status = CONST(Open),
                                                                                       Type = CONST(Item),
                                                                                       "No." = FIELD("No."),
                                                                                       "Repack Location" = FIELD("Location Filter"),
                                                                                       "Variant Code" = FIELD("Variant Filter"),
                                                                                       "Due Date" = FIELD("Date Filter")));
            Caption = 'Qty. on Repack Line-Trans. In';
            DecimalPlaces = 0 : 5;
            FieldClass = FlowField;
        }
        field(37002460; "Weight UOM"; Code[10])
        {
            Caption = 'Weight UOM';
            Description = 'PR1.00';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."),
                                                               Type = CONST(Weight));
        }
        field(37002461; "Volume UOM"; Code[10])
        {
            Caption = 'Volume UOM';
            Description = 'PR1.00';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."),
                                                               Type = CONST(Volume));
        }
        field(37002462; Formula; Boolean)
        {
            CalcFormula = Exist("Production BOM Header" WHERE("No." = FIELD("Production BOM No."),
                                                               "Mfg. BOM Type" = CONST(Formula)));
            Caption = 'Formula';
            Description = 'PR1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002463; "Production Grouping Item"; Code[20])
        {
            Caption = 'Production Grouping Item';
            Description = 'PR1.20';
            TableRelation = Item WHERE("BOM Type" = FILTER(Formula | Process));

            trigger OnValidate()
            begin
                // P8001030
                if "Production Grouping Item" <> xRec."Production Grouping Item" then
                    "Production Grouping Variant" := '';
                // P8001030
            end;
        }
        field(37002464; "Forecast Quantity"; Decimal)
        {
            CalcFormula = Sum("Production Forecast".Quantity WHERE("Item No." = FIELD("No."),
                                                                    Date = FIELD("Date Filter"),
                                                                    "Location Code" = FIELD("Location Filter"),
                                                                    "Variant Code" = FIELD("Variant Filter")));
            Caption = 'Forecast Quantity';
            DecimalPlaces = 0 : 5;
            Description = 'PR1.00';
            FieldClass = FlowField;
        }
        field(37002465; "Specific Gravity"; Decimal)
        {
            Caption = 'Specific Gravity';
            DecimalPlaces = 0 : 5;
            Description = 'PR1.00';
            MinValue = 0;

            trigger OnValidate()
            begin
                // PR1.00 Begin
                if "Specific Gravity" <> 0 then
                    P800UOMFns.AdjustItemUOM(Rec)
                else
                    FieldError("Specific Gravity", Text37002000);
                // PR1.00 End
            end;
        }
        field(37002466; "Production Grouping Variant"; Code[20])
        {
            Caption = 'Production Grouping Variant';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Production Grouping Item"));
        }
        field(37002467; "Auto Plan if Component"; Boolean)
        {
            Caption = 'Auto Plan if Component';
            Description = 'PR1.00';
        }
        field(37002468; "BOM Type"; Option)
        {
            CalcFormula = Lookup("Production BOM Header"."Mfg. BOM Type" WHERE("No." = FIELD("Production BOM No.")));
            Caption = 'BOM Type';
            Description = 'PR1.20';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'BOM,Formula,Process';
            OptionMembers = BOM,Formula,Process;
        }
        field(37002565; "Non-Warehouse Item"; Boolean)
        {
            Caption = 'Non-Warehouse Item';

            trigger OnValidate()
            var
                ItemLedgEntry: Record "Item Ledger Entry";
            begin
                // P8001290
                if (Type = Type::FOODContainer) and (not "Non-Warehouse Item") then
                    FieldError(Type);

                ItemLedgEntry.Reset;
                ItemLedgEntry.SetCurrentKey("Item No.");
                ItemLedgEntry.SetRange("Item No.", "No.");
                if not ItemLedgEntry.IsEmpty then
                    Error(CannotChangeFieldErr, FieldCaption("Non-Warehouse Item"), TableCaption, "No.", ItemLedgEntry.TableCaption);

                CheckJournalsAndWorksheets(FieldNo("Non-Warehouse Item")); // P80096141
                CheckDocuments(FieldNo("Non-Warehouse Item"));             // P80096141

                CheckContainerTypes(FieldCaption("Non-Warehouse Item")); // P8001305
            end;
        }
        field(37002660; "Country/Region of Origin Reqd."; Boolean)
        {
            Caption = 'Country/Region of Origin Reqd.';
        }
        field(37002680; "Commodity Cost Item"; Boolean)
        {
            Caption = 'Commodity Cost Item';

            trigger OnValidate()
            begin
                CommItemMgmt.ItemValidate(Rec, FieldNo("Commodity Cost Item")); // P8000856
            end;
        }
        field(37002685; "Comm. Manifest Lot Nos."; Code[20])
        {
            Caption = 'Comm. Manifest Lot Nos.';
            TableRelation = "No. Series";
        }
        field(37002686; "Comm. Manifest UOM Code"; Code[10])
        {
            Caption = 'Comm. Manifest UOM Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));
        }
        field(37002687; "Comm. Payment Class Code"; Code[10])
        {
            Caption = 'Comm. Payment Class Code';
            TableRelation = "Commodity Class";
        }
        field(37002701; "Label Unit of Measure"; Code[10])
        {
            Caption = 'Label Unit of Measure';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));
        }
        field(37002760; "Replenishment Not Required"; Boolean)
        {
            Caption = 'Replenishment Not Required';
            Description = 'P8000494A';
        }
        field(37002761; "Replenishment UOM Code"; Code[10])
        {
            Caption = 'Replenishment UOM Code';
            Description = 'P8000494A';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));
        }
        field(37002762; "Replenishment Type"; Option)
        {
            Caption = 'Replenishment Type';
            Description = 'P8000494A';
            OptionCaption = 'Warehouse,Cooler';
            OptionMembers = Warehouse,Cooler;
        }
        field(37002763; "Replenishment Areas Exist"; Boolean)
        {
            CalcFormula = Exist("Item Replenishment Area" WHERE("Item No." = FIELD("No."),
                                                                 "Location Code" = FIELD("Location Filter")));
            Caption = 'Replenishment Areas Exist';
            Description = 'P8000494A';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002764; "Fixed Prod. Bins Exist"; Boolean)
        {
            CalcFormula = Exist("Item Fixed Prod. Bin" WHERE("Item No." = FIELD("No."),
                                                              "Location Code" = FIELD("Location Filter")));
            Caption = 'Fixed Prod. Bins Exist';
            Description = 'P8000494A';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002800; "Part No."; Code[20])
        {
            Caption = 'Part No.';
        }
        field(37002860; "ESHA Code"; Integer)
        {
            ObsoleteState = Pending;
        }
        field(37002862; "Ingredient Weight"; Decimal)
        {
            ObsoleteState = Pending;
        }
        field(37002863; "Ingredient Measure"; Option)
        {
            ObsoleteState = Pending;
            OptionMembers = " ","Ounce-weight",Pound,Microgram,Milligram,Gram,Kilogram;
        }
        field(37002920; "Direct Allergen Set ID"; Integer)
        {
            Caption = 'Direct Allergen Set ID';
        }
        field(37002921; "Indirect Allergen Set ID"; Integer)
        {
            Caption = 'Indirect Allergen Set ID';
        }
        field(37002922; "Old Direct Allergen Set ID"; Integer)
        {
            Caption = 'Old Direct Allergen Set ID';
        }
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    GetInvtSetup;
                    NoSeriesMgt.TestManual(InvtSetup."Item Nos.");
                    "No. Series" := '';
                    if xRec."No." = '' then
                        "Costing Method" := InvtSetup."Default Costing Method";
                end;
            end;
        }
        field(2; "No. 2"; Code[20])
        {
            Caption = 'No. 2';
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';

            trigger OnValidate()
            begin
                if ("Search Description" = UpperCase(xRec.Description)) or ("Search Description" = '') then
                    "Search Description" := CopyStr(Description, 1, MaxStrLen("Search Description"));

                if "Created From Nonstock Item" then begin
                    NonstockItem.SetCurrentKey("Item No.");
                    NonstockItem.SetRange("Item No.", "No.");
                    if NonstockItem.FindFirst then
                        if NonstockItem.Description = '' then begin
                            NonstockItem.Description := Description;
                            NonstockItem.Modify();
                        end;
                end;
            end;
        }
        field(4; "Search Description"; Code[100])
        {
            Caption = 'Search Description';
        }
        field(5; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
        }
        field(6; "Assembly BOM"; Boolean)
        {
            CalcFormula = Exist("BOM Component" WHERE("Parent Item No." = FIELD("No.")));
            Caption = 'Assembly BOM';
            Editable = false;
            FieldClass = FlowField;
        }
        field(8; "Base Unit of Measure"; Code[10])
        {
            Caption = 'Base Unit of Measure';
            TableRelation = "Unit of Measure";
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                TempItem: Record Item temporary;
                UnitOfMeasure: Record "Unit of Measure";
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateBaseUnitOfMeasure(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                if CurrentClientType() in [ClientType::ODataV4, ClientType::API] then
                    if not TempItem.Get(Rec."No.") and IsNullGuid(Rec.SystemId) then
                        Rec.Insert(true);

                UpdateUnitOfMeasureId;

                if "Base Unit of Measure" <> xRec."Base Unit of Measure" then begin
                    TestNoOpenEntriesExist(FieldCaption("Base Unit of Measure"));

                    // P8000856
                    if ProcessFns.CommCostInstalled() then
                        if "Base Unit of Measure" <> xRec."Base Unit of Measure" then
                            CommItemMgmt.ItemValidate(Rec, FieldNo("Base Unit of Measure"));
                    // P8000856
                    if "Base Unit of Measure" <> '' then begin
                        // If we can't find a Unit of Measure with a GET,
                        // then try with International Standard Code, as some times it's used as Code
                        if not UnitOfMeasure.Get("Base Unit of Measure") then begin
                            UnitOfMeasure.SetRange("International Standard Code", "Base Unit of Measure");
                            if not UnitOfMeasure.FindFirst then
                                Error(UnitOfMeasureNotExistErr, "Base Unit of Measure");
                            "Base Unit of Measure" := UnitOfMeasure.Code;
                        end;

                        if not ItemUnitOfMeasure.Get("No.", "Base Unit of Measure") then
                            CreateItemUnitOfMeasure()
                        else begin
                            if ItemUnitOfMeasure."Qty. per Unit of Measure" <> 1 then
                                Error(BaseUnitOfMeasureQtyMustBeOneErr, "Base Unit of Measure", ItemUnitOfMeasure."Qty. per Unit of Measure");
                        end;
                        UpdateQtyRoundingPrecisionForBaseUoM();
                    end;
                    "Sales Unit of Measure" := "Base Unit of Measure";
                    "Purch. Unit of Measure" := "Base Unit of Measure";
                    "Label Unit of Measure" := "Base Unit of Measure"; // P8001047
                end;
            end;
        }
        field(9; "Price Unit Conversion"; Integer)
        {
            Caption = 'Price Unit Conversion';
        }
        field(10; Type; Enum "Item Type")
        {
            Caption = 'Type';

            trigger OnValidate()
            begin
                if ExistsItemLedgerEntry then
                    Error(CannotChangeFieldErr, FieldCaption(Type), TableCaption, "No.", ItemLedgEntryTableCaptionTxt);
                CheckJournalsAndWorksheets(FieldNo(Type));
                CheckDocuments(FieldNo(Type));
                if (CurrFieldNo <> 0) then                 // P8001305
                    CheckContainerTypes(FieldCaption(Type)); // P8001305
                if IsNonInventoriableType then
                    CheckUpdateFieldsForNonInventoriableItem();

            end;
        }
        field(11; "Inventory Posting Group"; Code[20])
        {
            Caption = 'Inventory Posting Group';
            TableRelation = "Inventory Posting Group";

            trigger OnValidate()
            var
                InventoryPostGroupExists: Boolean;
            begin
                InventoryPostGroupExists := false;
                if "Inventory Posting Group" <> '' then begin
                    TestField(Type, Type::Inventory);
                    InventoryPostGroupExists := InventoryPostingGroup.Get("Inventory Posting Group");
                end;
                if InventoryPostGroupExists then
                    "Inventory Posting Group Id" := InventoryPostingGroup.SystemId
                else
                    Clear("Inventory Posting Group Id");
            end;
        }
        field(12; "Shelf No."; Code[10])
        {
            Caption = 'Shelf No.';
        }
        field(14; "Item Disc. Group"; Code[20])
        {
            Caption = 'Item Disc. Group';
            TableRelation = "Item Discount Group";
        }
        field(15; "Allow Invoice Disc."; Boolean)
        {
            Caption = 'Allow Invoice Disc.';
            InitValue = true;
        }
        field(16; "Statistics Group"; Integer)
        {
            Caption = 'Statistics Group';
        }
        field(17; "Commission Group"; Integer)
        {
            Caption = 'Commission Group';
        }
        field(18; "Unit Price"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price';
            MinValue = 0;

            trigger OnValidate()
            begin
                Validate("Price/Profit Calculation");
            end;
        }
        field(19; "Price/Profit Calculation"; Enum "Item Price Profit Calculation")
        {
            Caption = 'Price/Profit Calculation';

            trigger OnValidate()
            begin
                case "Price/Profit Calculation" of
                    "Price/Profit Calculation"::"Profit=Price-Cost":
                        if "Unit Price" <> 0 then
                            if "Unit Cost" = 0 then
                                "Profit %" := 0
                            else
                                "Profit %" :=
                                  Round(
                                    //100 * (1 - "Unit Cost" /                         // P8000981
                                    100 * (1 - ConvertUnitCostToPricing("Unit Cost") / // P8000981
                                           ("Unit Price" / (1 + CalcVAT))), 0.00001)
                        else
                            "Profit %" := 0;
                    "Price/Profit Calculation"::"Price=Cost+Profit":
                        if "Profit %" < 100 then begin
                            GetGLSetup;
                            "Unit Price" :=
                              Round(
                                //("Unit Cost" / (1 - "Profit %" / 100)) *                         // P8000981
                                //("Unit Cost" / (1 - "Profit %" / 100)) *                         // P8000981
                                (1 + CalcVAT),
                                GLSetup."Unit-Amount Rounding Precision");
                        end;
                end;
            end;
        }
        field(20; "Profit %"; Decimal)
        {
            Caption = 'Profit %';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                Validate("Price/Profit Calculation");
            end;
        }
        field(21; "Costing Method"; Enum "Costing Method")
        {
            Caption = 'Costing Method';

            trigger OnValidate()
            begin
                if "Costing Method" = xRec."Costing Method" then
                    exit;

                if "Costing Method" <> "Costing Method"::FIFO then
                    TestField(Type, Type::Inventory);

                if "Costing Method" = "Costing Method"::Specific then begin
                    TestField("Item Tracking Code");

                    ItemTrackingCode.Get("Item Tracking Code");
                    if not ItemTrackingCode."SN Specific Tracking" then
                        Error(
                          Text018,
                          ItemTrackingCode.FieldCaption("SN Specific Tracking"),
                          Format(true), ItemTrackingCode.TableCaption, ItemTrackingCode.Code,
                          FieldCaption("Costing Method"), "Costing Method");
                end;

                TestNoEntriesExist(FieldCaption("Costing Method"));

                // P8000856
                if ProcessFns.CommCostInstalled() then
                    CommItemMgmt.ItemValidate(Rec, FieldNo("Costing Method"));
                // P8000856

                if ProcessFns.CoProductsInstalled() then        // P8001092
                    P800Mgmt.ValidateItemCostingMethod(xRec, Rec); // P8001092

                ItemCostMgt.UpdateUnitCost(Rec, '', '', 0, 0, false, false, true, FieldNo("Costing Method"));
            end;
        }
        field(22; "Unit Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost';
            MinValue = 0;

            trigger OnValidate()
            begin
                if IsNonInventoriableType() then
                    exit;

                if "Costing Method" = "Costing Method"::Standard then
                    Validate("Standard Cost", "Unit Cost")
                else
                    TestNoEntriesExist(FieldCaption("Unit Cost"));
                Validate("Price/Profit Calculation");

                if CurrFieldNo <> 0 then        // PR3.70.03
                    if ProcessFns.ProcessInstalled then // P8000220A
                        P800BOMFns.UpdateBOMCost(Rec);    // PR3.70.03
            end;
        }
        field(24; "Standard Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Standard Cost';
            MinValue = 0;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateStandardCost(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                if ("Costing Method" = "Costing Method"::Standard) and (CurrFieldNo <> 0) then
                    if not GuiAllowed then begin
                        "Standard Cost" := xRec."Standard Cost";
                        exit;
                    end else
                        if not
                           Confirm(
                             Text020 +
                             Text021 +
                             Text022, false,
                             FieldCaption("Standard Cost"))
                        then begin
                            "Standard Cost" := xRec."Standard Cost";
                            exit;
                        end;

                ItemCostMgt.UpdateUnitCost(Rec, '', '', 0, 0, false, false, true, FieldNo("Standard Cost"));
            end;
        }
        field(25; "Last Direct Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Last Direct Cost';
            MinValue = 0;
        }
        field(28; "Indirect Cost %"; Decimal)
        {
            Caption = 'Indirect Cost %';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                if "Indirect Cost %" > 0 then
                    TestField(Type, Type::Inventory);
                ItemCostMgt.UpdateUnitCost(Rec, '', '', 0, 0, false, false, true, FieldNo("Indirect Cost %"));
            end;
        }
        field(29; "Cost is Adjusted"; Boolean)
        {
            Caption = 'Cost is Adjusted';
            Editable = false;
            InitValue = true;
        }
        field(30; "Allow Online Adjustment"; Boolean)
        {
            Caption = 'Allow Online Adjustment';
            Editable = false;
            InitValue = true;
        }
        field(31; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;
            //This property is currently not supported
            //TestTableRelation = true;
            ValidateTableRelation = true;

            trigger OnValidate()
            var
                ItemVend: Record "Item Vendor";
            begin
                if (xRec."Vendor No." <> "Vendor No.") and
                   ("Vendor No." <> '')
                then
                // P8001230
                begin
                    if VendorApprovalRequired then
                        CheckApprovedVendor;
                    // P8001230
                    if Vend.Get("Vendor No.") then
                        "Lead Time Calculation" := Vend."Lead Time Calculation";
                end; // P8001230
            end;
        }
        field(32; "Vendor Item No."; Text[50])
        {
            Caption = 'Vendor Item No.';
        }
        field(33; "Lead Time Calculation"; DateFormula)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            Caption = 'Lead Time Calculation';

            trigger OnValidate()
            begin
                LeadTimeMgt.CheckLeadTimeIsNotNegative("Lead Time Calculation");
            end;
        }
        field(34; "Reorder Point"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Reorder Point';
            DecimalPlaces = 0 : 5;
        }
        field(35; "Maximum Inventory"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Maximum Inventory';
            DecimalPlaces = 0 : 5;
        }
        field(36; "Reorder Quantity"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Reorder Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(37; "Alternative Item No."; Code[20])
        {
            Caption = 'Alternative Item No.';
            TableRelation = Item;
        }
        field(38; "Unit List Price"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit List Price';
            MinValue = 0;
        }
        field(39; "Duty Due %"; Decimal)
        {
            Caption = 'Duty Due %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(40; "Duty Code"; Code[10])
        {
            Caption = 'Duty Code';
        }
        field(41; "Gross Weight"; Decimal)
        {
            Caption = 'Gross Weight';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(42; "Net Weight"; Decimal)
        {
            Caption = 'Net Weight';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(43; "Units per Parcel"; Decimal)
        {
            Caption = 'Units per Parcel';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(44; "Unit Volume"; Decimal)
        {
            Caption = 'Unit Volume';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(45; Durability; Code[10])
        {
            Caption = 'Durability';
        }
        field(46; "Freight Type"; Code[10])
        {
            Caption = 'Freight Type';
        }
        field(47; "Tariff No."; Code[20])
        {
            Caption = 'Tariff No.';
            TableRelation = "Tariff Number";
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                TariffNumber: Record "Tariff Number";
            begin
                if "Tariff No." = '' then
                    exit;

                if (not TariffNumber.WritePermission) or
                   (not TariffNumber.ReadPermission)
                then
                    exit;

                if TariffNumber.Get("Tariff No.") then
                    exit;

                TariffNumber.Init();
                TariffNumber."No." := "Tariff No.";
                TariffNumber.Insert();
            end;
        }
        field(48; "Duty Unit Conversion"; Decimal)
        {
            Caption = 'Duty Unit Conversion';
            DecimalPlaces = 0 : 5;
        }
        field(49; "Country/Region Purchased Code"; Code[10])
        {
            Caption = 'Country/Region Purchased Code';
            TableRelation = "Country/Region";
        }
        field(50; "Budget Quantity"; Decimal)
        {
            Caption = 'Budget Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(51; "Budgeted Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Budgeted Amount';
        }
        field(52; "Budget Profit"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Budget Profit';
        }
        field(53; Comment; Boolean)
        {
            CalcFormula = Exist("Comment Line" WHERE("Table Name" = CONST(Item),
                                                      "No." = FIELD("No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(54; Blocked; Boolean)
        {
            Caption = 'Blocked';

            trigger OnValidate()
            begin
                if not Blocked then
                    "Block Reason" := '';
            end;
        }
        field(55; "Cost is Posted to G/L"; Boolean)
        {
            CalcFormula = - Exist("Post Value Entry to G/L" WHERE("Item No." = FIELD("No.")));
            Caption = 'Cost is Posted to G/L';
            Editable = false;
            FieldClass = FlowField;
        }
        field(56; "Block Reason"; Text[250])
        {
            Caption = 'Block Reason';

            trigger OnValidate()
            begin
                TestField(Blocked, true);
            end;
        }
        field(61; "Last DateTime Modified"; DateTime)
        {
            Caption = 'Last DateTime Modified';
            Editable = false;
        }
        field(62; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
        field(63; "Last Time Modified"; Time)
        {
            Caption = 'Last Time Modified';
            Editable = false;
        }
        field(64; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(65; "Global Dimension 1 Filter"; Code[20])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension 1 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(66; "Global Dimension 2 Filter"; Code[20])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension 2 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(67; "Location Filter"; Code[10])
        {
            Caption = 'Location Filter';
            FieldClass = FlowFilter;
            TableRelation = Location;
        }
        field(68; Inventory; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("No."),
                                                                  "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                  "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                  "Location Code" = FIELD("Location Filter"),
                                                                  "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                  "Variant Code" = FIELD("Variant Filter"),
                                                                  "Lot No." = FIELD("Lot No. Filter"),
                                                                  "Serial No." = FIELD("Serial No. Filter"),
                                                                  "Unit of Measure Code" = FIELD("Unit of Measure Filter"),
                                                                  "Package No." = FIELD("Package No. Filter")));
            Caption = 'Inventory';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(69; "Net Invoiced Qty."; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry"."Invoiced Quantity" WHERE("Item No." = FIELD("No."),
                                                                             "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                             "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                             "Location Code" = FIELD("Location Filter"),
                                                                             "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                             "Variant Code" = FIELD("Variant Filter"),
                                                                             "Lot No." = FIELD("Lot No. Filter"),
                                                                             "Serial No." = FIELD("Serial No. Filter"),
                                                                             "Package No." = FIELD("Package No. Filter")));
            Caption = 'Net Invoiced Qty.';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(70; "Net Change"; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("No."),
                                                                  "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                  "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                  "Location Code" = FIELD("Location Filter"),
                                                                  "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                  "Posting Date" = FIELD("Date Filter"),
                                                                  "Variant Code" = FIELD("Variant Filter"),
                                                                  "Lot No." = FIELD("Lot No. Filter"),
                                                                  "Serial No." = FIELD("Serial No. Filter"),
                                                                  "Unit of Measure Code" = FIELD("Unit of Measure Filter"),
                                                                  "Package No." = FIELD("Package No. Filter")));
            Caption = 'Net Change';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(71; "Purchases (Qty.)"; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry"."Invoiced Quantity" WHERE("Entry Type" = CONST(Purchase),
                                                                             "Item No." = FIELD("No."),
                                                                             "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                             "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                             "Location Code" = FIELD("Location Filter"),
                                                                             "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                             "Variant Code" = FIELD("Variant Filter"),
                                                                             "Posting Date" = FIELD("Date Filter"),
                                                                             "Lot No." = FIELD("Lot No. Filter"),
                                                                             "Serial No." = FIELD("Serial No. Filter"),
                                                                             "Package No." = FIELD("Package No. Filter")));
            Caption = 'Purchases (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(72; "Sales (Qty.)"; Decimal)
        {
            CalcFormula = - Sum("Value Entry"."Invoiced Quantity" WHERE("Item Ledger Entry Type" = CONST(Sale),
                                                                        "Item No." = FIELD("No."),
                                                                        "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                        "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                        "Location Code" = FIELD("Location Filter"),
                                                                        "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                        "Variant Code" = FIELD("Variant Filter"),
                                                                        "Posting Date" = FIELD("Date Filter")));
            Caption = 'Sales (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(73; "Positive Adjmt. (Qty.)"; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry"."Invoiced Quantity" WHERE("Entry Type" = CONST("Positive Adjmt."),
                                                                             "Item No." = FIELD("No."),
                                                                             "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                             "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                             "Location Code" = FIELD("Location Filter"),
                                                                             "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                             "Variant Code" = FIELD("Variant Filter"),
                                                                             "Posting Date" = FIELD("Date Filter"),
                                                                             "Lot No." = FIELD("Lot No. Filter"),
                                                                             "Serial No." = FIELD("Serial No. Filter"),
                                                                             "Package No." = FIELD("Package No. Filter")));
            Caption = 'Positive Adjmt. (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(74; "Negative Adjmt. (Qty.)"; Decimal)
        {
            CalcFormula = - Sum("Item Ledger Entry"."Invoiced Quantity" WHERE("Entry Type" = CONST("Negative Adjmt."),
                                                                              "Item No." = FIELD("No."),
                                                                              "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                              "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                              "Location Code" = FIELD("Location Filter"),
                                                                              "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                              "Variant Code" = FIELD("Variant Filter"),
                                                                              "Posting Date" = FIELD("Date Filter"),
                                                                              "Lot No." = FIELD("Lot No. Filter"),
                                                                              "Serial No." = FIELD("Serial No. Filter"),
                                                                              "Package No." = FIELD("Package No. Filter")));
            Caption = 'Negative Adjmt. (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(77; "Purchases (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Value Entry"."Purchase Amount (Actual)" WHERE("Item Ledger Entry Type" = CONST(Purchase),
                                                                              "Item No." = FIELD("No."),
                                                                              "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                              "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                              "Location Code" = FIELD("Location Filter"),
                                                                              "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                              "Variant Code" = FIELD("Variant Filter"),
                                                                              "Posting Date" = FIELD("Date Filter")));
            Caption = 'Purchases (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(78; "Sales (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Value Entry"."Sales Amount (Actual)" WHERE("Item Ledger Entry Type" = CONST(Sale),
                                                                           "Item No." = FIELD("No."),
                                                                           "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                           "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                           "Location Code" = FIELD("Location Filter"),
                                                                           "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                           "Variant Code" = FIELD("Variant Filter"),
                                                                           "Posting Date" = FIELD("Date Filter")));
            Caption = 'Sales (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(79; "Positive Adjmt. (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Value Entry"."Cost Amount (Actual)" WHERE("Item Ledger Entry Type" = CONST("Positive Adjmt."),
                                                                          "Item No." = FIELD("No."),
                                                                          "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                          "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                          "Location Code" = FIELD("Location Filter"),
                                                                          "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                          "Variant Code" = FIELD("Variant Filter"),
                                                                          "Posting Date" = FIELD("Date Filter")));
            Caption = 'Positive Adjmt. (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(80; "Negative Adjmt. (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Value Entry"."Cost Amount (Actual)" WHERE("Item Ledger Entry Type" = CONST("Negative Adjmt."),
                                                                          "Item No." = FIELD("No."),
                                                                          "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                          "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                          "Location Code" = FIELD("Location Filter"),
                                                                          "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                          "Variant Code" = FIELD("Variant Filter"),
                                                                          "Posting Date" = FIELD("Date Filter")));
            Caption = 'Negative Adjmt. (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(83; "COGS (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = - Sum("Value Entry"."Cost Amount (Actual)" WHERE("Item Ledger Entry Type" = CONST(Sale),
                                                                           "Item No." = FIELD("No."),
                                                                           "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                           "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                           "Location Code" = FIELD("Location Filter"),
                                                                           "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                           "Variant Code" = FIELD("Variant Filter"),
                                                                           "Posting Date" = FIELD("Date Filter")));
            Caption = 'COGS (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(84; "Qty. on Purch. Order"; Decimal)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            CalcFormula = Sum("Purchase Line"."Outstanding Qty. (Base)" WHERE("Document Type" = CONST(Order),
                                                                               Type = CONST(Item),
                                                                               "No." = FIELD("No."),
                                                                               "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                               "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                               "Location Code" = FIELD("Location Filter"),
                                                                               "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                               "Variant Code" = FIELD("Variant Filter"),
                                                                               "Expected Receipt Date" = FIELD("Date Filter"),
                                                                               "Unit of Measure Code" = FIELD("Unit of Measure Filter")));
            Caption = 'Qty. on Purch. Order';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(85; "Qty. on Sales Order"; Decimal)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            CalcFormula = Sum("Sales Line"."Outstanding Qty. (Base)" WHERE("Document Type" = CONST(Order),
                                                                            Type = CONST(Item),
                                                                            "No." = FIELD("No."),
                                                                            "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                            "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                            "Location Code" = FIELD("Location Filter"),
                                                                            "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                            "Variant Code" = FIELD("Variant Filter"),
                                                                            "Shipment Date" = FIELD("Date Filter"),
                                                                            "Unit of Measure Code" = FIELD("Unit of Measure Filter")));
            Caption = 'Qty. on Sales Order';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(87; "Price Includes VAT"; Boolean)
        {
            Caption = 'Price Includes VAT';

            trigger OnValidate()
            var
                VATPostingSetup: Record "VAT Posting Setup";
                SalesSetup: Record "Sales & Receivables Setup";
            begin
                if "Price Includes VAT" then begin
                    SalesSetup.Get();
                    SalesSetup.TestField("VAT Bus. Posting Gr. (Price)");
                    "VAT Bus. Posting Gr. (Price)" := SalesSetup."VAT Bus. Posting Gr. (Price)";
                    VATPostingSetup.Get("VAT Bus. Posting Gr. (Price)", "VAT Prod. Posting Group");
                end;
                Validate("Price/Profit Calculation");
            end;
        }
        field(89; "Drop Shipment Filter"; Boolean)
        {
            AccessByPermission = TableData "Drop Shpt. Post. Buffer" = R;
            Caption = 'Drop Shipment Filter';
            FieldClass = FlowFilter;
        }
        field(90; "VAT Bus. Posting Gr. (Price)"; Code[20])
        {
            Caption = 'VAT Bus. Posting Gr. (Price)';
            TableRelation = "VAT Business Posting Group";

            trigger OnValidate()
            begin
                Validate("Price/Profit Calculation");
            end;
        }
        field(91; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";

            trigger OnValidate()
            var
                ConfirmMgt: Codeunit "Confirm Management";
                Question: Text;
                GenProdPostGroupExists: Boolean;
            begin
                if xRec."Gen. Prod. Posting Group" <> "Gen. Prod. Posting Group" then begin
                    if CurrFieldNo <> 0 then
                        if ProdOrderExist then begin
                            Question := StrSubstNo(Text024 + Text022, FieldCaption("Gen. Prod. Posting Group"));
                            if not ConfirmMgt.GetResponseOrDefault(Question, true)
                            then begin
                                "Gen. Prod. Posting Group" := xRec."Gen. Prod. Posting Group";
                                exit;
                            end;
                        end;

                    if GenProdPostingGrp.ValidateVatProdPostingGroup(GenProdPostingGrp, "Gen. Prod. Posting Group") then
                        Validate("VAT Prod. Posting Group", GenProdPostingGrp."Def. VAT Prod. Posting Group");
                end;

                GenProdPostGroupExists := false;
                if "Gen. Prod. Posting Group" <> '' then
                    GenProdPostGroupExists := GenProdPostingGrp.Get("Gen. Prod. Posting Group");
                if GenProdPostGroupExists then
                    "Gen. Prod. Posting Group Id" := GenProdPostingGrp.SystemId
                else
                    Clear("Gen. Prod. Posting Group Id");

                Validate("Price/Profit Calculation");
            end;
        }
        field(92; Picture; MediaSet)
        {
            Caption = 'Picture';
        }
        field(93; "Transferred (Qty.)"; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry"."Invoiced Quantity" WHERE("Entry Type" = CONST(Transfer),
                                                                             "Item No." = FIELD("No."),
                                                                             "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                             "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                             "Location Code" = FIELD("Location Filter"),
                                                                             "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                             "Variant Code" = FIELD("Variant Filter"),
                                                                             "Posting Date" = FIELD("Date Filter"),
                                                                             "Lot No." = FIELD("Lot No. Filter"),
                                                                             "Serial No." = FIELD("Serial No. Filter"),
                                                                             "Package No." = FIELD("Package No. Filter")));
            Caption = 'Transferred (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(94; "Transferred (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Value Entry"."Sales Amount (Actual)" WHERE("Item Ledger Entry Type" = CONST(Transfer),
                                                                           "Item No." = FIELD("No."),
                                                                           "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                           "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                           "Location Code" = FIELD("Location Filter"),
                                                                           "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                           "Variant Code" = FIELD("Variant Filter"),
                                                                           "Posting Date" = FIELD("Date Filter")));
            Caption = 'Transferred (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(95; "Country/Region of Origin Code"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';
            TableRelation = "Country/Region";
        }
        field(96; "Automatic Ext. Texts"; Boolean)
        {
            Caption = 'Automatic Ext. Texts';
        }
        field(97; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(98; "Tax Group Code"; Code[20])
        {
            Caption = 'Tax Group Code';
            TableRelation = "Tax Group";

            trigger OnValidate()
            begin
                UpdateTaxGroupId;
            end;
        }
        field(99; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";

            trigger OnValidate()
            begin
                Validate("Price/Profit Calculation");
            end;
        }
        field(100; Reserve; Enum "Reserve Method")
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            Caption = 'Reserve';
            InitValue = Optional;

            trigger OnValidate()
            begin
                if Reserve in [Reserve::Optional, Reserve::Always] then
                    TestField(Type, Type::Inventory);
            end;
        }
        field(101; "Reserved Qty. on Inventory"; Decimal)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            CalcFormula = Sum("Reservation Entry"."Quantity (Base)" WHERE("Item No." = FIELD("No."),
                                                                           "Source Type" = CONST(32),
                                                                           "Source Subtype" = CONST("0"),
                                                                           "Reservation Status" = CONST(Reservation),
                                                                           "Serial No." = FIELD("Serial No. Filter"),
                                                                           "Lot No." = FIELD("Lot No. Filter"),
                                                                           "Location Code" = FIELD("Location Filter"),
                                                                           "Variant Code" = FIELD("Variant Filter"),
                                                                           "Package No." = FIELD("Package No. Filter")));
            Caption = 'Reserved Qty. on Inventory';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(102; "Reserved Qty. on Purch. Orders"; Decimal)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            CalcFormula = Sum("Reservation Entry"."Quantity (Base)" WHERE("Item No." = FIELD("No."),
                                                                           "Source Type" = CONST(39),
                                                                           "Source Subtype" = CONST("1"),
                                                                           "Reservation Status" = CONST(Reservation),
                                                                           "Location Code" = FIELD("Location Filter"),
                                                                           "Variant Code" = FIELD("Variant Filter"),
                                                                           "Expected Receipt Date" = FIELD("Date Filter")));
            Caption = 'Reserved Qty. on Purch. Orders';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(103; "Reserved Qty. on Sales Orders"; Decimal)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            CalcFormula = - Sum("Reservation Entry"."Quantity (Base)" WHERE("Item No." = FIELD("No."),
                                                                            "Source Type" = CONST(37),
                                                                            "Source Subtype" = CONST("1"),
                                                                            "Reservation Status" = CONST(Reservation),
                                                                            "Location Code" = FIELD("Location Filter"),
                                                                            "Variant Code" = FIELD("Variant Filter"),
                                                                            "Shipment Date" = FIELD("Date Filter")));
            Caption = 'Reserved Qty. on Sales Orders';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(105; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1),
                                                          Blocked = CONST(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Global Dimension 1 Code");
            end;
        }
        field(106; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2),
                                                          Blocked = CONST(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Global Dimension 2 Code");
            end;
        }
        field(107; "Res. Qty. on Outbound Transfer"; Decimal)
        {
            AccessByPermission = TableData "Transfer Header" = R;
            CalcFormula = - Sum("Reservation Entry"."Quantity (Base)" WHERE("Item No." = FIELD("No."),
                                                                            "Source Type" = CONST(5741),
                                                                            "Source Subtype" = CONST("0"),
                                                                            "Reservation Status" = CONST(Reservation),
                                                                            "Location Code" = FIELD("Location Filter"),
                                                                            "Variant Code" = FIELD("Variant Filter"),
                                                                            "Shipment Date" = FIELD("Date Filter")));
            Caption = 'Res. Qty. on Outbound Transfer';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(108; "Res. Qty. on Inbound Transfer"; Decimal)
        {
            AccessByPermission = TableData "Transfer Header" = R;
            CalcFormula = Sum("Reservation Entry"."Quantity (Base)" WHERE("Item No." = FIELD("No."),
                                                                           "Source Type" = CONST(5741),
                                                                           "Source Subtype" = CONST("1"),
                                                                           "Reservation Status" = CONST(Reservation),
                                                                           "Location Code" = FIELD("Location Filter"),
                                                                           "Variant Code" = FIELD("Variant Filter"),
                                                                           "Expected Receipt Date" = FIELD("Date Filter")));
            Caption = 'Res. Qty. on Inbound Transfer';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(109; "Res. Qty. on Sales Returns"; Decimal)
        {
            AccessByPermission = TableData "Return Receipt Header" = R;
            CalcFormula = Sum("Reservation Entry"."Quantity (Base)" WHERE("Item No." = FIELD("No."),
                                                                           "Source Type" = CONST(37),
                                                                           "Source Subtype" = CONST("5"),
                                                                           "Reservation Status" = CONST(Reservation),
                                                                           "Location Code" = FIELD("Location Filter"),
                                                                           "Variant Code" = FIELD("Variant Filter"),
                                                                           "Shipment Date" = FIELD("Date Filter")));
            Caption = 'Res. Qty. on Sales Returns';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(110; "Res. Qty. on Purch. Returns"; Decimal)
        {
            AccessByPermission = TableData "Return Shipment Header" = R;
            CalcFormula = - Sum("Reservation Entry"."Quantity (Base)" WHERE("Item No." = FIELD("No."),
                                                                            "Source Type" = CONST(39),
                                                                            "Source Subtype" = CONST("5"),
                                                                            "Reservation Status" = CONST(Reservation),
                                                                            "Location Code" = FIELD("Location Filter"),
                                                                            "Variant Code" = FIELD("Variant Filter"),
                                                                            "Expected Receipt Date" = FIELD("Date Filter")));
            Caption = 'Res. Qty. on Purch. Returns';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(120; "Stockout Warning"; Option)
        {
            Caption = 'Stockout Warning';
            OptionCaption = 'Default,No,Yes';
            OptionMembers = Default,No,Yes;
        }
        field(121; "Prevent Negative Inventory"; Option)
        {
            Caption = 'Prevent Negative Inventory';
            OptionCaption = 'Default,No,Yes';
            OptionMembers = Default,No,Yes;
        }
        field(200; "Cost of Open Production Orders"; Decimal)
        {
            CalcFormula = Sum("Prod. Order Line"."Cost Amount" WHERE(Status = FILTER(Planned | "Firm Planned" | Released),
                                                                      "Item No." = FIELD("No.")));
            Caption = 'Cost of Open Production Orders';
            FieldClass = FlowField;
        }
        field(521; "Application Wksh. User ID"; Code[128])
        {
            Caption = 'Application Wksh. User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(720; "Coupled to CRM"; Boolean)
        {
            Caption = 'Coupled to Dynamics 365 Sales';
            Editable = false;
        }
        field(910; "Assembly Policy"; Enum "Assembly Policy")
        {
            AccessByPermission = TableData "BOM Component" = R;
            Caption = 'Assembly Policy';

            trigger OnValidate()
            begin
                if "Assembly Policy" = "Assembly Policy"::"Assemble-to-Order" then
                    TestField("Replenishment System", "Replenishment System"::Assembly);
                if IsNonInventoriableType or IsContainerType then // P80066030
                    TestField("Assembly Policy", "Assembly Policy"::"Assemble-to-Stock");
            end;
        }
        field(929; "Res. Qty. on Assembly Order"; Decimal)
        {
            AccessByPermission = TableData "BOM Component" = R;
            CalcFormula = Sum("Reservation Entry"."Quantity (Base)" WHERE("Item No." = FIELD("No."),
                                                                           "Source Type" = CONST(900),
                                                                           "Source Subtype" = CONST("1"),
                                                                           "Reservation Status" = CONST(Reservation),
                                                                           "Location Code" = FIELD("Location Filter"),
                                                                           "Variant Code" = FIELD("Variant Filter"),
                                                                           "Expected Receipt Date" = FIELD("Date Filter")));
            Caption = 'Res. Qty. on Assembly Order';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(930; "Res. Qty. on  Asm. Comp."; Decimal)
        {
            AccessByPermission = TableData "BOM Component" = R;
            CalcFormula = - Sum("Reservation Entry"."Quantity (Base)" WHERE("Item No." = FIELD("No."),
                                                                            "Source Type" = CONST(901),
                                                                            "Source Subtype" = CONST("1"),
                                                                            "Reservation Status" = CONST(Reservation),
                                                                            "Location Code" = FIELD("Location Filter"),
                                                                            "Variant Code" = FIELD("Variant Filter"),
                                                                            "Shipment Date" = FIELD("Date Filter")));
            Caption = 'Res. Qty. on  Asm. Comp.';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(977; "Qty. on Assembly Order"; Decimal)
        {
            CalcFormula = Sum("Assembly Header"."Remaining Quantity (Base)" WHERE("Document Type" = CONST(Order),
                                                                                   "Item No." = FIELD("No."),
                                                                                   "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                                   "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                                   "Location Code" = FIELD("Location Filter"),
                                                                                   "Variant Code" = FIELD("Variant Filter"),
                                                                                   "Due Date" = FIELD("Date Filter"),
                                                                                   "Unit of Measure Code" = FIELD("Unit of Measure Filter")));
            Caption = 'Qty. on Assembly Order';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(978; "Qty. on Asm. Component"; Decimal)
        {
            CalcFormula = Sum("Assembly Line"."Remaining Quantity (Base)" WHERE("Document Type" = CONST(Order),
                                                                                 Type = CONST(Item),
                                                                                 "No." = FIELD("No."),
                                                                                 "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                                 "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                                 "Location Code" = FIELD("Location Filter"),
                                                                                 "Variant Code" = FIELD("Variant Filter"),
                                                                                 "Due Date" = FIELD("Date Filter"),
                                                                                 "Unit of Measure Code" = FIELD("Unit of Measure Filter")));
            Caption = 'Qty. on Asm. Component';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(1001; "Qty. on Job Order"; Decimal)
        {
            CalcFormula = Sum("Job Planning Line"."Remaining Qty. (Base)" WHERE(Status = CONST(Order),
                                                                                 Type = CONST(Item),
                                                                                 "No." = FIELD("No."),
                                                                                 "Location Code" = FIELD("Location Filter"),
                                                                                 "Variant Code" = FIELD("Variant Filter"),
                                                                                 "Planning Date" = FIELD("Date Filter"),
                                                                                 "Unit of Measure Code" = FIELD("Unit of Measure Filter")));
            Caption = 'Qty. on Job Order';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(1002; "Res. Qty. on Job Order"; Decimal)
        {
            AccessByPermission = TableData Job = R;
            CalcFormula = - Sum("Reservation Entry"."Quantity (Base)" WHERE("Item No." = FIELD("No."),
                                                                            "Source Type" = CONST(1003),
                                                                            "Source Subtype" = CONST("2"),
                                                                            "Reservation Status" = CONST(Reservation),
                                                                            "Location Code" = FIELD("Location Filter"),
                                                                            "Variant Code" = FIELD("Variant Filter"),
                                                                            "Shipment Date" = FIELD("Date Filter")));
            Caption = 'Res. Qty. on Job Order';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(1217; GTIN; Code[14])
        {
            Caption = 'GTIN';
            Numeric = true;
        }
        field(1700; "Default Deferral Template Code"; Code[10])
        {
            Caption = 'Default Deferral Template Code';
            TableRelation = "Deferral Template"."Deferral Code";
        }
        field(5400; "Low-Level Code"; Integer)
        {
            Caption = 'Low-Level Code';
            Editable = false;
        }
        field(5401; "Lot Size"; Decimal)
        {
            AccessByPermission = TableData "Production Order" = R;
            Caption = 'Lot Size';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(5402; "Serial Nos."; Code[20])
        {
            Caption = 'Serial Nos.';
            TableRelation = "No. Series";

            trigger OnValidate()
            begin
                if "Serial Nos." <> '' then
                    TestField("Item Tracking Code");
            end;
        }
        field(5403; "Last Unit Cost Calc. Date"; Date)
        {
            Caption = 'Last Unit Cost Calc. Date';
            Editable = false;
        }
        field(5404; "Rolled-up Material Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Rolled-up Material Cost';
            DecimalPlaces = 2 : 5;
            Editable = false;
        }
        field(5405; "Rolled-up Capacity Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Rolled-up Capacity Cost';
            DecimalPlaces = 2 : 5;
            Editable = false;
        }
        field(5407; "Scrap %"; Decimal)
        {
            AccessByPermission = TableData "Production Order" = R;
            Caption = 'Scrap %';
            DecimalPlaces = 0 : 2;
            MaxValue = 100;
            MinValue = 0;
        }
        field(5409; "Inventory Value Zero"; Boolean)
        {
            Caption = 'Inventory Value Zero';

            trigger OnValidate()
            begin
                CheckForProductionOutput("No.");
            end;
        }
        field(5410; "Discrete Order Quantity"; Integer)
        {
            Caption = 'Discrete Order Quantity';
            MinValue = 0;
        }
        field(5411; "Minimum Order Quantity"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Minimum Order Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(5412; "Maximum Order Quantity"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Maximum Order Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(5413; "Safety Stock Quantity"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Safety Stock Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(5414; "Order Multiple"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Order Multiple';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(5415; "Safety Lead Time"; DateFormula)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Safety Lead Time';
        }
        field(5417; "Flushing Method"; Enum "Flushing Method")
        {
            AccessByPermission = TableData "Production Order" = R;
            Caption = 'Flushing Method';

            trigger OnValidate()
            begin
                if "Flushing Method" <> "Flushing Method"::Manual then // PR3.70
                    TestField("Catch Alternate Qtys.", false);            // PR3.70
            end;
        }
        field(5419; "Replenishment System"; Enum "Replenishment System")
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Replenishment System';

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                case "Replenishment System" of
                    "Replenishment System"::Purchase:
                        TestField("Assembly Policy", "Assembly Policy"::"Assemble-to-Stock");
                    "Replenishment System"::"Prod. Order":
                        begin
                            TestField("Assembly Policy", "Assembly Policy"::"Assemble-to-Stock");
                            TestField(Type, Type::Inventory);
                        end;
                    "Replenishment System"::Transfer:
                        begin
                            IsHandled := false;
                            OnValidateReplenishmentSystemCaseTransfer(Rec, IsHandled);
                            if not IsHandled then
                                error(ReplenishmentSystemTransferErr);
                        end;
                    "Replenishment System"::Assembly:
                        TestField(Type, Type::Inventory);
                    else
                        OnValidateReplenishmentSystemCaseElse(Rec);
                end;
            end;
        }
        field(5420; "Scheduled Receipt (Qty.)"; Decimal)
        {
            CalcFormula = Sum("Prod. Order Line"."Remaining Qty. (Base)" WHERE(Status = FILTER("Firm Planned" | Released),
                                                                                "Item No." = FIELD("No."),
                                                                                "Variant Code" = FIELD("Variant Filter"),
                                                                                "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                                "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                                "Location Code" = FIELD("Location Filter"),
                                                                                "Due Date" = FIELD("Date Filter"),
                                                                                "Unit of Measure Code" = FIELD("Unit of Measure Filter")));
            Caption = 'Scheduled Receipt (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5421; "Scheduled Need (Qty.)"; Decimal)
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'Use the field ''Qty. on Component Lines'' instead';
            ObsoleteTag = '18.0';
            CalcFormula = Sum("Prod. Order Component"."Remaining Qty. (Base)" WHERE(Status = FILTER(Planned .. Released),
                                                                                     "Item No." = FIELD("No."),
                                                                                     "Variant Code" = FIELD("Variant Filter"),
                                                                                     "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                                     "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                                     "Location Code" = FIELD("Location Filter"),
                                                                                     "Due Date" = FIELD("Date Filter"),
                                                                                     "Unit of Measure Code" = FIELD("Unit of Measure Filter")));
            Caption = 'Scheduled Need (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5422; "Rounding Precision"; Decimal)
        {
            AccessByPermission = TableData "Production Order" = R;
            Caption = 'Rounding Precision';
            DecimalPlaces = 0 : 5;
            InitValue = 1;

            trigger OnValidate()
            begin
                if "Rounding Precision" <= 0 then
                    FieldError("Rounding Precision", Text027);
            end;
        }
        field(5423; "Bin Filter"; Code[20])
        {
            Caption = 'Bin Filter';
            FieldClass = FlowFilter;
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Filter"));
        }
        field(5424; "Variant Filter"; Code[10])
        {
            Caption = 'Variant Filter';
            FieldClass = FlowFilter;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("No."));
        }
        field(5425; "Sales Unit of Measure"; Code[10])
        {
            Caption = 'Sales Unit of Measure';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));

            trigger OnValidate()
            begin
                // P8000383A
                if TrackAlternateUnits then
                    AltQtyMgt.CheckUOMDifferentFromAltUOM(Rec, "Sales Unit of Measure", FieldCaption("Sales Unit of Measure"));
                // P8000383A
            end;
        }
        field(5426; "Purch. Unit of Measure"; Code[10])
        {
            Caption = 'Purch. Unit of Measure';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));

            trigger OnValidate()
            begin
                // P8000383A
                if TrackAlternateUnits then
                    AltQtyMgt.CheckUOMDifferentFromAltUOM(Rec, "Purch. Unit of Measure", FieldCaption("Purch. Unit of Measure"));
                // P8000383A

                "Label Unit of Measure" := "Purch. Unit of Measure"; // P8001047
            end;
        }
        field(5427; "Unit of Measure Filter"; Code[10])
        {
            Caption = 'Unit of Measure Filter';
            FieldClass = FlowFilter;
            TableRelation = "Unit of Measure";
        }
        field(5428; "Time Bucket"; DateFormula)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Time Bucket';

            trigger OnValidate()
            begin
                CalendarMgt.CheckDateFormulaPositive("Time Bucket");
            end;
        }
        field(5429; "Reserved Qty. on Prod. Order"; Decimal)
        {
            AccessByPermission = TableData "Production Order" = R;
            CalcFormula = Sum("Reservation Entry"."Quantity (Base)" WHERE("Item No." = FIELD("No."),
                                                                           "Source Type" = CONST(5406),
                                                                           "Source Subtype" = FILTER("1" .. "3"),
                                                                           "Reservation Status" = CONST(Reservation),
                                                                           "Location Code" = FIELD("Location Filter"),
                                                                           "Variant Code" = FIELD("Variant Filter"),
                                                                           "Expected Receipt Date" = FIELD("Date Filter")));
            Caption = 'Reserved Qty. on Prod. Order';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5430; "Res. Qty. on Prod. Order Comp."; Decimal)
        {
            AccessByPermission = TableData "Production Order" = R;
            CalcFormula = - Sum("Reservation Entry"."Quantity (Base)" WHERE("Item No." = FIELD("No."),
                                                                            "Source Type" = CONST(5407),
                                                                            "Source Subtype" = FILTER("1" .. "3"),
                                                                            "Reservation Status" = CONST(Reservation),
                                                                            "Location Code" = FIELD("Location Filter"),
                                                                            "Variant Code" = FIELD("Variant Filter"),
                                                                            "Shipment Date" = FIELD("Date Filter")));
            Caption = 'Res. Qty. on Prod. Order Comp.';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5431; "Res. Qty. on Req. Line"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            CalcFormula = Sum("Reservation Entry"."Quantity (Base)" WHERE("Item No." = FIELD("No."),
                                                                           "Source Type" = CONST(246),
                                                                           "Source Subtype" = FILTER("0"),
                                                                           "Reservation Status" = CONST(Reservation),
                                                                           "Location Code" = FIELD("Location Filter"),
                                                                           "Variant Code" = FIELD("Variant Filter"),
                                                                           "Expected Receipt Date" = FIELD("Date Filter")));
            Caption = 'Res. Qty. on Req. Line';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5440; "Reordering Policy"; Enum "Reordering Policy")
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Reordering Policy';

            trigger OnValidate()
            begin
                "Include Inventory" :=
                  "Reordering Policy" in ["Reordering Policy"::"Lot-for-Lot",
                                          "Reordering Policy"::"Maximum Qty.",
                                          "Reordering Policy"::"Fixed Reorder Qty."];

                if "Reordering Policy" <> "Reordering Policy"::" " then
                    TestField(Type, Type::Inventory);
            end;
        }
        field(5441; "Include Inventory"; Boolean)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Include Inventory';
        }
        field(5442; "Manufacturing Policy"; Enum "Manufacturing Policy")
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Manufacturing Policy';
        }
        field(5443; "Rescheduling Period"; DateFormula)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Rescheduling Period';

            trigger OnValidate()
            begin
                CalendarMgt.CheckDateFormulaPositive("Rescheduling Period");
            end;
        }
        field(5444; "Lot Accumulation Period"; DateFormula)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Lot Accumulation Period';

            trigger OnValidate()
            begin
                CalendarMgt.CheckDateFormulaPositive("Lot Accumulation Period");
            end;
        }
        field(5445; "Dampener Period"; DateFormula)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Dampener Period';

            trigger OnValidate()
            begin
                CalendarMgt.CheckDateFormulaPositive("Dampener Period");
            end;
        }
        field(5446; "Dampener Quantity"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Dampener Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(5447; "Overflow Level"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Overflow Level';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(5449; "Planning Transfer Ship. (Qty)."; Decimal)
        {
            CalcFormula = Sum("Requisition Line"."Quantity (Base)" WHERE("Worksheet Template Name" = FILTER(<> ''),
                                                                          "Journal Batch Name" = FILTER(<> ''),
                                                                          "Replenishment System" = CONST(Transfer),
                                                                          Type = CONST(Item),
                                                                          "No." = FIELD("No."),
                                                                          "Variant Code" = FIELD("Variant Filter"),
                                                                          "Transfer-from Code" = FIELD("Location Filter"),
                                                                          "Transfer Shipment Date" = FIELD("Date Filter")));
            Caption = 'Planning Transfer Ship. (Qty).';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5450; "Planning Worksheet (Qty.)"; Decimal)
        {
            CalcFormula = Sum("Requisition Line"."Quantity (Base)" WHERE("Planning Line Origin" = CONST(Planning),
                                                                          Type = CONST(Item),
                                                                          "No." = FIELD("No."),
                                                                          "Location Code" = FIELD("Location Filter"),
                                                                          "Variant Code" = FIELD("Variant Filter"),
                                                                          "Due Date" = FIELD("Date Filter"),
                                                                          "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                          "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter")));
            Caption = 'Planning Worksheet (Qty.)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5700; "Stockkeeping Unit Exists"; Boolean)
        {
            CalcFormula = Exist("Stockkeeping Unit" WHERE("Item No." = FIELD("No.")));
            Caption = 'Stockkeeping Unit Exists';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5701; "Manufacturer Code"; Code[10])
        {
            Caption = 'Manufacturer Code';
            TableRelation = Manufacturer;
        }
        field(5702; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            TableRelation = "Item Category";

            trigger OnValidate()
            var
                ItemCategory: Record "Item Category";
                ItemAttributeManagement: Codeunit "Item Attribute Management";
            begin
                if not IsTemporary then
                    ItemAttributeManagement.InheritAttributesFromItemCategory(Rec, "Item Category Code", xRec."Item Category Code");
                // P8007748
                if "Item Category Code" <> xRec."Item Category Code" then begin
                    if not xRec.VendorApprovalRequired then // P8007749
                        if VendorApprovalRequired then begin
                            if "Vendor No." <> '' then
                                CheckApprovedVendor;
                            CheckSKUApprovedVendor;
                            CheckDocumentApprovedVendor;
                        end;

                    if ItemCategory.Get("Item Category Code") then begin
                        LotInfo.SetRange("Item No.", "No.");
                        LotInfo.ModifyAll("Item Category Code", "Item Category Code");
                    end;
                end;
                UpdateItemCategoryId;
            end;
        }
        field(5703; "Created From Nonstock Item"; Boolean)
        {
            AccessByPermission = TableData "Nonstock Item" = R;
            Caption = 'Created From Catalog Item';
            Editable = false;
        }
        field(5704; "Product Group Code"; Code[10])
        {
            Caption = 'Product Group Code';
            ObsoleteReason = 'Product Groups became first level children of Item Categories.';
            ObsoleteState = Removed;
            ObsoleteTag = '15.0';
        }
        field(5706; "Substitutes Exist"; Boolean)
        {
            CalcFormula = Exist("Item Substitution" WHERE(Type = CONST(Item),
                                                           "No." = FIELD("No.")));
            Caption = 'Substitutes Exist';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5707; "Qty. in Transit"; Decimal)
        {
            CalcFormula = Sum("Transfer Line"."Qty. in Transit (Base)" WHERE("Derived From Line No." = CONST(0),
                                                                              "Item No." = FIELD("No."),
                                                                              "Transfer-to Code" = FIELD("Location Filter"),
                                                                              "Variant Code" = FIELD("Variant Filter"),
                                                                              "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                              "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                              "Receipt Date" = FIELD("Date Filter"),
                                                                              "Unit of Measure Code" = FIELD("Unit of Measure Filter")));
            Caption = 'Qty. in Transit';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5708; "Trans. Ord. Receipt (Qty.)"; Decimal)
        {
            CalcFormula = Sum("Transfer Line"."Outstanding Qty. (Base)" WHERE("Derived From Line No." = CONST(0),
                                                                               "Item No." = FIELD("No."),
                                                                               "Transfer-to Code" = FIELD("Location Filter"),
                                                                               "Variant Code" = FIELD("Variant Filter"),
                                                                               "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                               "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                               "Receipt Date" = FIELD("Date Filter"),
                                                                               "Unit of Measure Code" = FIELD("Unit of Measure Filter")));
            Caption = 'Trans. Ord. Receipt (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5709; "Trans. Ord. Shipment (Qty.)"; Decimal)
        {
            CalcFormula = Sum("Transfer Line"."Outstanding Qty. (Base)" WHERE("Derived From Line No." = CONST(0),
                                                                               "Item No." = FIELD("No."),
                                                                               "Transfer-from Code" = FIELD("Location Filter"),
                                                                               "Variant Code" = FIELD("Variant Filter"),
                                                                               "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                               "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                               "Shipment Date" = FIELD("Date Filter"),
                                                                               "Unit of Measure Code" = FIELD("Unit of Measure Filter")));
            Caption = 'Trans. Ord. Shipment (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5711; "Purchasing Code"; Code[10])
        {
            Caption = 'Purchasing Code';
            TableRelation = Purchasing;
        }
        field(5776; "Qty. Assigned to ship"; Decimal)
        {
            CalcFormula = Sum("Warehouse Shipment Line"."Qty. Outstanding (Base)" WHERE("Item No." = FIELD("No."),
                                                                                         "Location Code" = FIELD("Location Filter"),
                                                                                         "Variant Code" = FIELD("Variant Filter"),
                                                                                         "Due Date" = FIELD("Date Filter")));
            Caption = 'Qty. Assigned to ship';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5777; "Qty. Picked"; Decimal)
        {
            CalcFormula = Sum("Warehouse Shipment Line"."Qty. Picked (Base)" WHERE("Item No." = FIELD("No."),
                                                                                    "Location Code" = FIELD("Location Filter"),
                                                                                    "Variant Code" = FIELD("Variant Filter"),
                                                                                    "Due Date" = FIELD("Date Filter")));
            Caption = 'Qty. Picked';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5900; "Service Item Group"; Code[10])
        {
            Caption = 'Service Item Group';
            TableRelation = "Service Item Group".Code;

            trigger OnValidate()
            var
                ResSkill: Record "Resource Skill";
            begin
                if xRec."Service Item Group" <> "Service Item Group" then begin
                    if not ResSkillMgt.ChangeResSkillRelationWithGroup(
                         ResSkill.Type::Item,
                         "No.",
                         ResSkill.Type::"Service Item Group",
                         "Service Item Group",
                         xRec."Service Item Group")
                    then
                        "Service Item Group" := xRec."Service Item Group";
                end else
                    ResSkillMgt.RevalidateResSkillRelation(
                      ResSkill.Type::Item,
                      "No.",
                      ResSkill.Type::"Service Item Group",
                      "Service Item Group")
            end;
        }
        field(5901; "Qty. on Service Order"; Decimal)
        {
            CalcFormula = Sum("Service Line"."Outstanding Qty. (Base)" WHERE("Document Type" = CONST(Order),
                                                                              Type = CONST(Item),
                                                                              "No." = FIELD("No."),
                                                                              "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                              "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                              "Location Code" = FIELD("Location Filter"),
                                                                              "Variant Code" = FIELD("Variant Filter"),
                                                                              "Needed by Date" = FIELD("Date Filter"),
                                                                              "Unit of Measure Code" = FIELD("Unit of Measure Filter")));
            Caption = 'Qty. on Service Order';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5902; "Res. Qty. on Service Orders"; Decimal)
        {
            AccessByPermission = TableData "Service Header" = R;
            CalcFormula = - Sum("Reservation Entry"."Quantity (Base)" WHERE("Item No." = FIELD("No."),
                                                                            "Source Type" = CONST(5902),
                                                                            "Source Subtype" = CONST("1"),
                                                                            "Reservation Status" = CONST(Reservation),
                                                                            "Location Code" = FIELD("Location Filter"),
                                                                            "Variant Code" = FIELD("Variant Filter"),
                                                                            "Shipment Date" = FIELD("Date Filter")));
            Caption = 'Res. Qty. on Service Orders';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(6500; "Item Tracking Code"; Code[10])
        {
            Caption = 'Item Tracking Code';
            TableRelation = "Item Tracking Code";

            trigger OnValidate()
            var
                EmptyDateFormula: DateFormula;
            begin
                if "Item Tracking Code" <> '' then
                    TestField(Type, Type::Inventory);
                if "Item Tracking Code" = xRec."Item Tracking Code" then
                    exit;

                if not ItemTrackingCode.Get("Item Tracking Code") then
                    Clear(ItemTrackingCode);

                if not ItemTrackingCode2.Get(xRec."Item Tracking Code") then
                    Clear(ItemTrackingCode2);

                if ItemTrackingCode.IsSpecificTrackingChanged(ItemTrackingCode2) then
                    TestNoEntriesExist(FieldCaption("Item Tracking Code"));

                if ItemTrackingCode."Lot Specific Tracking" <> ItemTrackingCode2."Lot Specific Tracking" then // PR2.00
                    TestNoQCTestsExist(FieldCaption("Item Tracking Code"));                                     // PR2.00

                if ItemTrackingCode.IsWarehouseTrackingChanged(ItemTrackingCode2) then
                    TestNoWhseEntriesExist(FieldCaption("Item Tracking Code"));

                if "Costing Method" = "Costing Method"::Specific then begin
                    TestNoEntriesExist(FieldCaption("Item Tracking Code"));

                    TestField("Item Tracking Code");

                    ItemTrackingCode.Get("Item Tracking Code");
                    if not ItemTrackingCode."SN Specific Tracking" then
                        Error(
                          Text018,
                          ItemTrackingCode.FieldCaption("SN Specific Tracking"),
                          Format(true), ItemTrackingCode.TableCaption, ItemTrackingCode.Code,
                          FieldCaption("Costing Method"), "Costing Method");
                end;

                // P8000494A
                if ("Item Tracking Code" = '') then begin
                    FixedBinItem.Reset;
                    FixedBinItem.SetRange("Item No.", "No.");
                    FixedBinItem.SetFilter("Lot Handling", '<>%1', FixedBinItem."Lot Handling"::Manual);
                    if FixedBinItem.FindFirst then
                        FixedBinItem.FieldError("Lot Handling");
                end;
                // P8000494A

                // P8000856
                if ProcessFns.CommCostInstalled() then
                    CommItemMgmt.ItemValidate(Rec, FieldNo("Item Tracking Code"));
                // P8000856

                TestNoOpenDocumentsWithTrackingExist();

                if "Expiration Calculation" <> EmptyDateFormula then
                    if not ItemTrackingCodeUseExpirationDates() then
                        Error(ItemTrackingCodeIgnoresExpirationDateErr, "No.");
            end;
        }
        field(6501; "Lot Nos."; Code[20])
        {
            Caption = 'Lot Nos.';
            TableRelation = IF ("Lot No. Assignment Method" = CONST("No. Series")) "No. Series"
            ELSE
            IF ("Lot No. Assignment Method" = CONST(Custom)) "Lot No. Custom Format";

            trigger OnValidate()
            begin
                if "Lot Nos." <> '' then
                    TestField("Item Tracking Code");
            end;
        }
        field(6502; "Expiration Calculation"; DateFormula)
        {
            Caption = 'Expiration Calculation';

            trigger OnValidate()
            begin
                if Format("Expiration Calculation") <> '' then
                    if not ItemTrackingCodeUseExpirationDates() then
                        Error(ItemTrackingCodeIgnoresExpirationDateErr, "No.");
            end;
        }
        field(6503; "Lot No. Filter"; Code[50])
        {
            Caption = 'Lot No. Filter';
            FieldClass = FlowFilter;
        }
        field(6504; "Serial No. Filter"; Code[50])
        {
            Caption = 'Serial No. Filter';
            FieldClass = FlowFilter;
        }
#pragma warning disable
        field(6515; "Package No. Filter"; Code[50])
        {
            Caption = 'Package No. Filter';
            CaptionClass = '6,3';
            FieldClass = FlowFilter;
        }
#pragma warning enable
        field(6650; "Qty. on Purch. Return"; Decimal)
        {
            AccessByPermission = TableData "Return Receipt Header" = R;
            CalcFormula = Sum("Purchase Line"."Outstanding Qty. (Base)" WHERE("Document Type" = CONST("Return Order"),
                                                                               Type = CONST(Item),
                                                                               "No." = FIELD("No."),
                                                                               "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                               "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                               "Location Code" = FIELD("Location Filter"),
                                                                               "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                               "Variant Code" = FIELD("Variant Filter"),
                                                                               "Expected Receipt Date" = FIELD("Date Filter"),
                                                                               "Unit of Measure Code" = FIELD("Unit of Measure Filter")));
            Caption = 'Qty. on Purch. Return';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(6660; "Qty. on Sales Return"; Decimal)
        {
            AccessByPermission = TableData "Return Shipment Header" = R;
            CalcFormula = Sum("Sales Line"."Outstanding Qty. (Base)" WHERE("Document Type" = CONST("Return Order"),
                                                                            Type = CONST(Item),
                                                                            "No." = FIELD("No."),
                                                                            "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                            "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                            "Location Code" = FIELD("Location Filter"),
                                                                            "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                            "Variant Code" = FIELD("Variant Filter"),
                                                                            "Shipment Date" = FIELD("Date Filter"),
                                                                            "Unit of Measure Code" = FIELD("Unit of Measure Filter")));
            Caption = 'Qty. on Sales Return';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(7171; "No. of Substitutes"; Integer)
        {
            CalcFormula = Count("Item Substitution" WHERE(Type = CONST(Item),
                                                           "No." = FIELD("No.")));
            Caption = 'No. of Substitutes';
            Editable = false;
            FieldClass = FlowField;
        }
        field(7300; "Warehouse Class Code"; Code[10])
        {
            Caption = 'Warehouse Class Code';
            TableRelation = "Warehouse Class";
        }
        field(7301; "Special Equipment Code"; Code[10])
        {
            Caption = 'Special Equipment Code';
            TableRelation = "Special Equipment";
        }
        field(7302; "Put-away Template Code"; Code[10])
        {
            Caption = 'Put-away Template Code';
            TableRelation = "Put-away Template Header";
        }
        field(7307; "Put-away Unit of Measure Code"; Code[10])
        {
            AccessByPermission = TableData "Posted Invt. Put-away Header" = R;
            Caption = 'Put-away Unit of Measure Code';
            TableRelation = IF ("No." = FILTER(<> '')) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."))
            ELSE
            "Unit of Measure";
        }
        field(7380; "Phys Invt Counting Period Code"; Code[10])
        {
            Caption = 'Phys Invt Counting Period Code';
            TableRelation = "Phys. Invt. Counting Period";

            trigger OnValidate()
            var
                PhysInvtCountPeriod: Record "Phys. Invt. Counting Period";
                PhysInvtCountPeriodMgt: Codeunit "Phys. Invt. Count.-Management";
                IsHandled: Boolean;
            begin
                if ("Phys Invt Counting Period Code" <> '') and
                   ("Phys Invt Counting Period Code" <> xRec."Phys Invt Counting Period Code")
                then begin
                    PhysInvtCountPeriod.Get("Phys Invt Counting Period Code");
                    PhysInvtCountPeriod.TestField("Count Frequency per Year");
                    IsHandled := false;
                    OnValidatePhysInvtCountingPeriodCodeOnBeforeConfirmUpdate(Rec, xRec, PhysInvtCountPeriod, IsHandled);
                    if not IsHandled then
                        if xRec."Phys Invt Counting Period Code" <> '' then
                            if CurrFieldNo <> 0 then
                                if not Confirm(
                                     Text7380,
                                     false,
                                     FieldCaption("Phys Invt Counting Period Code"),
                                     FieldCaption("Next Counting Start Date"),
                                     FieldCaption("Next Counting End Date"))
                                then
                                    Error(Text7381);

                    if "Last Counting Period Update" = 0D then
                        PhysInvtCountPeriodMgt.CalcPeriod(
                          "Last Counting Period Update", "Next Counting Start Date", "Next Counting End Date",
                          PhysInvtCountPeriod."Count Frequency per Year");
                end else begin
                    if CurrFieldNo <> 0 then
                        if not Confirm(Text003, false, FieldCaption("Phys Invt Counting Period Code")) then
                            Error(Text7381);
                    "Next Counting Start Date" := 0D;
                    "Next Counting End Date" := 0D;
                    "Last Counting Period Update" := 0D;
                end;
            end;
        }
        field(7381; "Last Counting Period Update"; Date)
        {
            AccessByPermission = TableData "Phys. Invt. Item Selection" = R;
            Caption = 'Last Counting Period Update';
            Editable = false;
        }
        field(7383; "Last Phys. Invt. Date"; Date)
        {
            CalcFormula = Max("Phys. Inventory Ledger Entry"."Posting Date" WHERE("Item No." = FIELD("No."),
                                                                                   "Phys Invt Counting Period Type" = FILTER(" " | Item)));
            Caption = 'Last Phys. Invt. Date';
            Editable = false;
            FieldClass = FlowField;
        }
        field(7384; "Use Cross-Docking"; Boolean)
        {
            AccessByPermission = TableData "Bin Content" = R;
            Caption = 'Use Cross-Docking';
            InitValue = true;
        }
        field(7385; "Next Counting Start Date"; Date)
        {
            Caption = 'Next Counting Start Date';
            Editable = false;
        }
        field(7386; "Next Counting End Date"; Date)
        {
            Caption = 'Next Counting End Date';
            Editable = false;
        }
        field(7700; "Identifier Code"; Code[20])
        {
            CalcFormula = Lookup("Item Identifier".Code WHERE("Item No." = FIELD("No.")));
            Caption = 'Identifier Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(8000; Id; Guid)
        {
            Caption = 'Id';
            ObsoleteState = Pending;
            ObsoleteReason = 'This functionality will be replaced by the systemID field';
            ObsoleteTag = '15.0';
        }
        field(8001; "Unit of Measure Id"; Guid)
        {
            Caption = 'Unit of Measure Id';
            TableRelation = "Unit of Measure".SystemId;

            trigger OnValidate()
            begin
                UpdateUnitOfMeasureCode;
            end;
        }
        field(8002; "Tax Group Id"; Guid)
        {
            Caption = 'Tax Group Id';
            TableRelation = "Tax Group".SystemId;

            trigger OnValidate()
            begin
                UpdateTaxGroupCode;
            end;
        }
        field(8003; "Sales Blocked"; Boolean)
        {
            Caption = 'Sales Blocked';
            DataClassification = CustomerContent;
        }
        field(8004; "Purchasing Blocked"; Boolean)
        {
            Caption = 'Purchasing Blocked';
            DataClassification = CustomerContent;
        }
        field(8005; "Item Category Id"; Guid)
        {
            Caption = 'Item Category Id';
            DataClassification = SystemMetadata;
            TableRelation = "Item Category".SystemId;

            trigger OnValidate()
            begin
                UpdateItemCategoryCode;
            end;
        }
        field(8006; "Inventory Posting Group Id"; Guid)
        {
            Caption = 'Inventory Posting Group Id';
            TableRelation = "Inventory Posting Group".SystemId;

            trigger OnValidate()
            var
                InventoryPostGroupExists: Boolean;
            begin
                InventoryPostGroupExists := false;
                if not IsNullGuid("Inventory Posting Group Id") then
                    InventoryPostGroupExists := InventoryPostingGroup.GetBySystemId("Inventory Posting Group Id");
                if InventoryPostGroupExists then
                    Validate("Inventory Posting Group", InventoryPostingGroup."Code")
                else
                    Validate("Inventory Posting Group", '')
            end;
        }
        field(8007; "Gen. Prod. Posting Group Id"; Guid)
        {
            Caption = 'Gen. Prod. Posting Group Id';
            TableRelation = "Gen. Product Posting Group".SystemId;
            trigger OnValidate()
            var
                GenProdPostGroup: Record "Gen. Product Posting Group";
                GenProdPostGroupExists: Boolean;
            begin
                GenProdPostGroupExists := false;
                if not IsNullGuid("Gen. Prod. Posting Group Id") then
                    GenProdPostGroupExists := GenProdPostGroup.GetBySystemId("Gen. Prod. Posting Group Id");

                if GenProdPostGroupExists then
                    Validate("Gen. Prod. Posting Group", GenProdPostGroup."Code")
                else
                    Validate("Gen. Prod. Posting Group", '')
            end;
        }
        field(8510; "Over-Receipt Code"; Code[20])
        {
            Caption = 'Over-Receipt Code';
            TableRelation = "Over-Receipt Code";
        }
        field(10004; "Duty Class"; Code[10])
        {
            Caption = 'Duty Class';
        }
        field(10011; "Consumptions (Qty.)"; Decimal)
        {
            CalcFormula = - Sum("Item Ledger Entry"."Invoiced Quantity" WHERE("Entry Type" = CONST(Consumption),
                                                                              "Item No." = FIELD("No."),
                                                                              "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                              "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                              "Location Code" = FIELD("Location Filter"),
                                                                              "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                              "Variant Code" = FIELD("Variant Filter"),
                                                                              "Posting Date" = FIELD("Date Filter")));
            Caption = 'Consumptions (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(10012; "Outputs (Qty.)"; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry"."Invoiced Quantity" WHERE("Entry Type" = CONST(Output),
                                                                             "Item No." = FIELD("No."),
                                                                             "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                             "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                             "Location Code" = FIELD("Location Filter"),
                                                                             "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                             "Variant Code" = FIELD("Variant Filter"),
                                                                             "Posting Date" = FIELD("Date Filter")));
            Caption = 'Outputs (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(10013; "Rel. Scheduled Receipt (Qty.)"; Decimal)
        {
            CalcFormula = Sum("Prod. Order Line"."Remaining Qty. (Base)" WHERE(Status = CONST(Released),
                                                                                "Item No." = FIELD("No."),
                                                                                "Variant Code" = FIELD("Variant Filter"),
                                                                                "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                                "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                                "Location Code" = FIELD("Location Filter"),
                                                                                "Bin Code" = FIELD("Bin Filter"),
                                                                                "Due Date" = FIELD("Date Filter")));
            Caption = 'Rel. Scheduled Receipt (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(10014; "Rel. Scheduled Need (Qty.)"; Decimal)
        {
            CalcFormula = Sum("Prod. Order Component"."Remaining Qty. (Base)" WHERE(Status = FILTER(Released),
                                                                                     "Item No." = FIELD("No."),
                                                                                     "Variant Code" = FIELD("Variant Filter"),
                                                                                     "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                                     "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                                     "Location Code" = FIELD("Location Filter"),
                                                                                     "Bin Code" = FIELD("Bin Filter"),
                                                                                     "Due Date" = FIELD("Date Filter")));
            Caption = 'Rel. Scheduled Need (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(27000; "SAT Item Classification"; Code[10])
        {
            Caption = 'SAT Item Classification';
            TableRelation = "SAT Classification";
        }
        field(27024; "SAT Hazardous Material"; Code[10])
        {
            Caption = 'SAT Hazardous Material';
            TableRelation = "SAT Hazardous Material";
        }
        field(27025; "SAT Packaging Type"; Code[10])
        {
            Caption = 'SAT Packaging Type';
            TableRelation = "SAT Packaging Type";
        }
        field(99000750; "Routing No."; Code[20])
        {
            Caption = 'Routing No.';
            TableRelation = "Routing Header";

            trigger OnValidate()
            var
                SKU2: Record "Stockkeeping Unit";
            begin
                if "Routing No." <> '' then
                    TestField(Type, Type::Inventory);

                PlanningAssignment.RoutingReplace(Rec, xRec."Routing No.");

                if "Routing No." <> xRec."Routing No." then
                // P8001030
                begin
                    if "Routing No." = '' then begin
                        SKU2.SetCurrentKey("Item No.");
                        SKU2.SetRange("Item No.", "No.");
                        if SKU2.FindSet then
                            repeat
                                if SKU2."Routing No." <> '' then
                                    SKU2.FieldError("Routing No.", Text37002010);
                            until SKU2.Next = 0;
                    end;
                    // P8001030

                    ItemCostMgt.UpdateUnitCost(Rec, '', '', 0, 0, false, false, true, FieldNo("Routing No."));
                end; // P8001030
            end;
        }
        field(99000751; "Production BOM No."; Code[20])
        {
            Caption = 'Production BOM No.';
            TableRelation = "Production BOM Header";

            trigger OnValidate()
            var
                MfgSetup: Record "Manufacturing Setup";
                ProdBOMHeader: Record "Production BOM Header";
                ItemUnitOfMeasure: Record "Item Unit of Measure";
                SKU2: Record "Stockkeeping Unit";
                ProdBOMHeader2: Record "Production BOM Header";
                ProdBOMLine: Record "Production BOM Line";
                FamilyLine: Record "Family Line";
                ProdBOMEquipment: Record "Prod. BOM Equipment";
                VersionMgt: Codeunit VersionManagement;
                AllergenManagement: Codeunit "Allergen Management";
            begin
                if "Production BOM No." <> '' then
                    TestField(Type, Type::Inventory);

                PlanningAssignment.BomReplace(Rec, xRec."Production BOM No.");

                if "Production BOM No." <> xRec."Production BOM No." then
                // P8001030
                begin
                    if "Production BOM No." = '' then begin
                        SKU2.SetCurrentKey("Item No.");
                        SKU2.SetRange("Item No.", "No.");
                        if SKU2.FindSet then
                            repeat
                                if SKU2."Production BOM No." <> '' then
                                    SKU2.FieldError("Production BOM No.", Text37002010);
                            until SKU2.Next = 0;
                    end;
                    // P8001030

                    ItemCostMgt.UpdateUnitCost(Rec, '', '', 0, 0, false, false, true, FieldNo("Production BOM No."));

                    if "Production BOM No." <> '' then begin // P8001030
                                                             // PR2.00.05 Begin
                        ProdBOMLine.SetRange("Production BOM No.", "Production BOM No.");
                        ProdBOMLine.SetRange(Type, ProdBOMLine.Type::FOODVariable);
                        if ProdBOMLine.Find('-') then
                            Error(Text37002004, FieldCaption("Production BOM No."), "Production BOM No.");
                        // PR2.00.05 End

                        //IF ("Production BOM No." <> '') AND ("Production BOM No." <> xRec."Production BOM No.") THEN BEGIN // P8001213
                        ProdBOMHeader.Get("Production BOM No.");
                        ItemUnitOfMeasure.Get("No.", ProdBOMHeader."Unit of Measure Code");
                        if ProdBOMHeader.Status = ProdBOMHeader.Status::Certified then begin
                            MfgSetup.Get();
                            if MfgSetup."Dynamic Low-Level Code" then
                                CODEUNIT.Run(CODEUNIT::"Calculate Low-Level Code", Rec);
                        end;
                        //END;                                                                                               // P8001213

                        // PR3.70.03 Begin
                        if ProdBOMHeader."Mfg. BOM Type" = ProdBOMHeader."Mfg. BOM Type"::Process then
                            case ProdBOMHeader."Output Type" of
                                ProdBOMHeader."Output Type"::Item:
                                    begin // P8001092
                                        if ProdBOMHeader."Output Item No." <> "No." then
                                            Error(Text37002001, "No.", ProdBOMHeader.FieldCaption("Output Item No."));
                                        ProdBOMHeader.TestField("Output Variant Code", ''); // P8001092
                                    end; // P8001092
                                ProdBOMHeader."Output Type"::Family:
                                    begin
                                        FamilyLine.SetRange("Family No.", ProdBOMHeader."No.");
                                        FamilyLine.SetRange("Item No.", "No.");
                                        FamilyLine.SetFilter("Variant Code", '%1', ''); // P8001092
                                        FamilyLine.SetRange("By-Product", false);
                                        if not FamilyLine.Find('-') then
                                            Error(Text37002008, "No.");
                                    end;
                            end;
                        // PR3.70.03 End

                        // P8001030
                        SKU2.SetCurrentKey("Item No.");
                        SKU2.SetRange("Item No.", "No.");
                        SKU2.SetFilter("Production BOM No.", '<>%1', '');
                        if SKU2.FindSet then
                            repeat
                                ProdBOMHeader2.Get(SKU2."Production BOM No.");
                                ProdBOMHeader2.TestField("Mfg. BOM Type", ProdBOMHeader."Mfg. BOM Type");
                            until SKU2.Next = 0;
                        // P8001030

                        // P8000219A Begin
                        if "Routing No." = '' then
                            if ProcessFns.ProcessInstalled then begin
                                P800BOMFns.GetPreferredEquipment("Production BOM No.",
                                  VersionMgt.GetBOMVersion("Production BOM No.", Today, true), '', ProdBOMEquipment); // P8001030
                                if ProdBOMEquipment."Routing No." <> '' then
                                    Validate("Routing No.", ProdBOMEquipment."Routing No.");
                            end;
                        // P8000219A End
                    end;

                end; // P8001030

                CalcFields("BOM Type"); // PR3.70.03
            end;
        }
        field(99000752; "Single-Level Material Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Single-Level Material Cost';
            Editable = false;
        }
        field(99000753; "Single-Level Capacity Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Single-Level Capacity Cost';
            Editable = false;
        }
        field(99000754; "Single-Level Subcontrd. Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Single-Level Subcontrd. Cost';
            Editable = false;
        }
        field(99000755; "Single-Level Cap. Ovhd Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Single-Level Cap. Ovhd Cost';
            Editable = false;
        }
        field(99000756; "Single-Level Mfg. Ovhd Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Single-Level Mfg. Ovhd Cost';
            Editable = false;
        }
        field(99000757; "Overhead Rate"; Decimal)
        {
            AccessByPermission = TableData "Production Order" = R;
            AutoFormatType = 2;
            Caption = 'Overhead Rate';

            trigger OnValidate()
            begin
                if "Overhead Rate" <> 0 then
                    TestField(Type, Type::Inventory);
            end;
        }
        field(99000758; "Rolled-up Subcontracted Cost"; Decimal)
        {
            AccessByPermission = TableData "Production Order" = R;
            AutoFormatType = 2;
            Caption = 'Rolled-up Subcontracted Cost';
            Editable = false;
        }
        field(99000759; "Rolled-up Mfg. Ovhd Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Rolled-up Mfg. Ovhd Cost';
            Editable = false;
        }
        field(99000760; "Rolled-up Cap. Overhead Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Rolled-up Cap. Overhead Cost';
            Editable = false;
        }
        field(99000761; "Planning Issues (Qty.)"; Decimal)
        {
            CalcFormula = Sum("Planning Component"."Expected Quantity (Base)" WHERE("Item No." = FIELD("No."),
                                                                                     "Due Date" = FIELD("Date Filter"),
                                                                                     "Location Code" = FIELD("Location Filter"),
                                                                                     "Variant Code" = FIELD("Variant Filter"),
                                                                                     "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                                     "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                                     "Planning Line Origin" = CONST(" "),
                                                                                     "Unit of Measure Code" = FIELD("Unit of Measure Filter")));
            Caption = 'Planning Issues (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(99000762; "Planning Receipt (Qty.)"; Decimal)
        {
            CalcFormula = Sum("Requisition Line"."Quantity (Base)" WHERE(Type = CONST(Item),
                                                                          "No." = FIELD("No."),
                                                                          "Due Date" = FIELD("Date Filter"),
                                                                          "Location Code" = FIELD("Location Filter"),
                                                                          "Variant Code" = FIELD("Variant Filter"),
                                                                          "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                          "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                          "Unit of Measure Code" = FIELD("Unit of Measure Filter")));
            Caption = 'Planning Receipt (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(99000765; "Planned Order Receipt (Qty.)"; Decimal)
        {
            CalcFormula = Sum("Prod. Order Line"."Remaining Qty. (Base)" WHERE(Status = CONST(Planned),
                                                                                "Item No." = FIELD("No."),
                                                                                "Variant Code" = FIELD("Variant Filter"),
                                                                                "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                                "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                                "Location Code" = FIELD("Location Filter"),
                                                                                "Due Date" = FIELD("Date Filter"),
                                                                                "Unit of Measure Code" = FIELD("Unit of Measure Filter")));
            Caption = 'Planned Order Receipt (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(99000766; "FP Order Receipt (Qty.)"; Decimal)
        {
            CalcFormula = Sum("Prod. Order Line"."Remaining Qty. (Base)" WHERE(Status = CONST("Firm Planned"),
                                                                                "Item No." = FIELD("No."),
                                                                                "Variant Code" = FIELD("Variant Filter"),
                                                                                "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                                "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                                "Location Code" = FIELD("Location Filter"),
                                                                                "Due Date" = FIELD("Date Filter"),
                                                                                "Unit of Measure Code" = FIELD("Unit of Measure Filter")));
            Caption = 'FP Order Receipt (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(99000767; "Rel. Order Receipt (Qty.)"; Decimal)
        {
            CalcFormula = Sum("Prod. Order Line"."Remaining Qty. (Base)" WHERE(Status = CONST(Released),
                                                                                "Item No." = FIELD("No."),
                                                                                "Variant Code" = FIELD("Variant Filter"),
                                                                                "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                                "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                                "Location Code" = FIELD("Location Filter"),
                                                                                "Due Date" = FIELD("Date Filter"),
                                                                                "Unit of Measure Code" = FIELD("Unit of Measure Filter")));
            Caption = 'Rel. Order Receipt (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(99000768; "Planning Release (Qty.)"; Decimal)
        {
            CalcFormula = Sum("Requisition Line"."Quantity (Base)" WHERE(Type = CONST(Item),
                                                                          "No." = FIELD("No."),
                                                                          "Starting Date" = FIELD("Date Filter"),
                                                                          "Location Code" = FIELD("Location Filter"),
                                                                          "Variant Code" = FIELD("Variant Filter"),
                                                                          "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                          "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                          "Unit of Measure Code" = FIELD("Unit of Measure Filter")));
            Caption = 'Planning Release (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(99000769; "Planned Order Release (Qty.)"; Decimal)
        {
            CalcFormula = Sum("Prod. Order Line"."Remaining Qty. (Base)" WHERE(Status = CONST(Planned),
                                                                                "Item No." = FIELD("No."),
                                                                                "Variant Code" = FIELD("Variant Filter"),
                                                                                "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                                "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                                "Location Code" = FIELD("Location Filter"),
                                                                                "Starting Date" = FIELD("Date Filter"),
                                                                                "Unit of Measure Code" = FIELD("Unit of Measure Filter")));
            Caption = 'Planned Order Release (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(99000770; "Purch. Req. Receipt (Qty.)"; Decimal)
        {
            CalcFormula = Sum("Requisition Line"."Quantity (Base)" WHERE(Type = CONST(Item),
                                                                          "No." = FIELD("No."),
                                                                          "Variant Code" = FIELD("Variant Filter"),
                                                                          "Location Code" = FIELD("Location Filter"),
                                                                          "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                          "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                          "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                          "Due Date" = FIELD("Date Filter"),
                                                                          "Planning Line Origin" = CONST(" "),
                                                                          "Unit of Measure Code" = FIELD("Unit of Measure Filter")));
            Caption = 'Purch. Req. Receipt (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(99000771; "Purch. Req. Release (Qty.)"; Decimal)
        {
            CalcFormula = Sum("Requisition Line"."Quantity (Base)" WHERE(Type = CONST(Item),
                                                                          "No." = FIELD("No."),
                                                                          "Location Code" = FIELD("Location Filter"),
                                                                          "Variant Code" = FIELD("Variant Filter"),
                                                                          "Drop Shipment" = FIELD("Drop Shipment Filter"),
                                                                          "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                          "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                          "Order Date" = FIELD("Date Filter"),
                                                                          "Unit of Measure Code" = FIELD("Unit of Measure Filter")));
            Caption = 'Purch. Req. Release (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(99000773; "Order Tracking Policy"; Enum "Order Tracking Policy")
        {
            Caption = 'Order Tracking Policy';

            trigger OnValidate()
            var
                ReservEntry: Record "Reservation Entry";
                ActionMessageEntry: Record "Action Message Entry";
                TempReservationEntry: Record "Reservation Entry" temporary;
            begin
                if "Order Tracking Policy" <> "Order Tracking Policy"::None then
                    TestField(Type, Type::Inventory);
                if xRec."Order Tracking Policy" = "Order Tracking Policy" then
                    exit;
                if "Order Tracking Policy".AsInteger() > xRec."Order Tracking Policy".AsInteger() then begin
                    Message(Text99000000 + Text99000001, "Order Tracking Policy");
                end else begin
                    ActionMessageEntry.SetCurrentKey("Reservation Entry");
                    ReservEntry.SetCurrentKey("Item No.", "Variant Code", "Location Code", "Reservation Status");
                    ReservEntry.SetRange("Item No.", "No.");
                    ReservEntry.SetRange("Reservation Status", ReservEntry."Reservation Status"::Tracking, ReservEntry."Reservation Status"::Surplus);
                    if ReservEntry.Find('-') then
                        repeat
                            ActionMessageEntry.SetRange("Reservation Entry", ReservEntry."Entry No.");
                            ActionMessageEntry.DeleteAll();
                            if "Order Tracking Policy" = "Order Tracking Policy"::None then
                                if ReservEntry.TrackingExists then begin
                                    TempReservationEntry := ReservEntry;
                                    TempReservationEntry."Reservation Status" := TempReservationEntry."Reservation Status"::Surplus;
                                    TempReservationEntry.Insert();
                                end else
                                    ReservEntry.Delete();
                        until ReservEntry.Next() = 0;

                    if TempReservationEntry.Find('-') then
                        repeat
                            ReservEntry := TempReservationEntry;
                            ReservEntry.Modify();
                        until TempReservationEntry.Next() = 0;
                end;
            end;
        }
        field(99000774; "Prod. Forecast Quantity (Base)"; Decimal)
        {
            CalcFormula = Sum("Production Forecast Entry"."Forecast Quantity (Base)" WHERE("Item No." = FIELD("No."),
                                                                                            "Production Forecast Name" = FIELD("Production Forecast Name"),
                                                                                            "Forecast Date" = FIELD("Date Filter"),
                                                                                            "Location Code" = FIELD("Location Filter"),
                                                                                            "Component Forecast" = FIELD("Component Forecast"),
                                                                                            "Variant Code" = FIELD("Variant Filter")));
            Caption = 'Prod. Forecast Quantity (Base)';
            DecimalPlaces = 0 : 5;
            FieldClass = FlowField;
        }
        field(99000775; "Production Forecast Name"; Code[10])
        {
            Caption = 'Production Forecast Name';
            FieldClass = FlowFilter;
            TableRelation = "Production Forecast Name";
        }
        field(99000776; "Component Forecast"; Boolean)
        {
            Caption = 'Component Forecast';
            FieldClass = FlowFilter;
        }
        field(99000777; "Qty. on Prod. Order"; Decimal)
        {
            CalcFormula = Sum("Prod. Order Line"."Remaining Qty. (Base)" WHERE(Status = FILTER(Planned .. Released),
                                                                                "Item No." = FIELD("No."),
                                                                                "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                                "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                                "Location Code" = FIELD("Location Filter"),
                                                                                "Variant Code" = FIELD("Variant Filter"),
                                                                                "Due Date" = FIELD("Date Filter"),
                                                                                "Unit of Measure Code" = FIELD("Unit of Measure Filter")));
            Caption = 'Qty. on Prod. Order';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(99000778; "Qty. on Component Lines"; Decimal)
        {
            CalcFormula = Sum("Prod. Order Component"."Remaining Qty. (Base)" WHERE(Status = FILTER(Planned .. Released),
                                                                                     "Item No." = FIELD("No."),
                                                                                     "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                                     "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                                     "Location Code" = FIELD("Location Filter"),
                                                                                     "Variant Code" = FIELD("Variant Filter"),
                                                                                     "Due Date" = FIELD("Date Filter"),
                                                                                     "Unit of Measure Code" = FIELD("Unit of Measure Filter")));
            Caption = 'Qty. on Component Lines';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(99000875; Critical; Boolean)
        {
            Caption = 'Critical';
        }
        field(99008500; "Common Item No."; Code[20])
        {
            Caption = 'Common Item No.';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Search Description")
        {
        }
        key(Key3; "Inventory Posting Group")
        {
        }
        key(Key4; "Shelf No.")
        {
        }
        key(Key5; "Vendor No.")
        {
        }
        key(Key6; "Gen. Prod. Posting Group")
        {
        }
        key(Key7; "Low-Level Code")
        {
        }
        key(Key8; "Production BOM No.")
        {
        }
        key(Key9; "Routing No.")
        {
        }
        key(Key10; "Vendor Item No.", "Vendor No.")
        {
        }
        key(Key11; "Common Item No.")
        {
        }
        key(Key12; "Service Item Group")
        {
        }
        key(Key13; "Cost is Adjusted", "Allow Online Adjustment")
        {
        }
        key(Key14; Description)
        {
        }
        key(Key15; "Base Unit of Measure")
        {
        }
        key(Key16; Type)
        {
        }
        key(Key17; SystemModifiedAt)
        {
        }
        key(Key18; GTIN)
        {
        }
        key(Key19; "Coupled to CRM")
        {
        }
        key(Key37002000; "Item Type", "Item Category Code")
        {
        }
        key(Key37002001; "Item Type", "Item Category Code", "Price List Sequence No.")
        {
        }
        key(Key37002002; "Item Category Code")
        {
        }
        key(Key37002003; "Commodity Cost Item")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", Description, "Base Unit of Measure", "Item Type", "Unit Price")
        {
        }
        fieldgroup(Brick; "No.", Description, Inventory, "Unit Price", "Base Unit of Measure", "Description 2", Picture)
        {
        }
    }

    trigger OnDelete()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOnDelete(Rec, IsHandled);
        if IsHandled then
            exit;

        ApprovalsMgmt.OnCancelItemApprovalRequest(Rec);

        CheckJournalsAndWorksheets(0);
        CheckDocuments(0);

        CheckContainerTypes(''); // P8001305

        MoveEntries.MoveItemEntries(Rec);

        if ProcessFns.TrackingInstalled then // P8000153A
            LotSpecFns.DeleteItemLotPrefs(Rec); // P8000153A

        DeleteRelatedData;

        DeleteItemUnitGroup();
    end;

    trigger OnInsert()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOnInsert(Rec, IsHandled);
        if IsHandled then
            exit;

        if "No." = '' then begin
            GetInvtSetup;
            InvtSetup.TestField("Item Nos.");
            NoSeriesMgt.InitSeries(InvtSetup."Item Nos.", xRec."No. Series", 0D, "No.", "No. Series");
            "Costing Method" := InvtSetup."Default Costing Method";
        end;

        DimMgt.UpdateDefaultDim(
          DATABASE::Item, "No.",
          "Global Dimension 1 Code", "Global Dimension 2 Code");

        UpdateReferencedIds;
        SetLastDateTimeModified;

        UpdateItemUnitGroup();
    end;

    trigger OnModify()
    begin
        UpdateReferencedIds;
        SetLastDateTimeModified;
        PlanningAssignment.ItemChange(Rec, xRec);

        UpdateItemUnitGroup();
    end;

    trigger OnRename()
    var
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        TransferLine: Record "Transfer Line";
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
    begin
        SalesLine.RenameNo(SalesLine.Type::Item, xRec."No.", "No.");
        PurchaseLine.RenameNo(PurchaseLine.Type::Item, xRec."No.", "No.");
        TransferLine.RenameNo(xRec."No.", "No.");
        DimMgt.RenameDefaultDim(DATABASE::Item, xRec."No.", "No.");
        CommentLine.RenameCommentLine(CommentLine."Table Name"::Item, xRec."No.", "No.");

        ApprovalsMgmt.OnRenameRecordInApprovalRequest(xRec.RecordId, RecordId);
        ItemAttributeValueMapping.RenameItemAttributeValueMapping(xRec."No.", "No.");
        SetLastDateTimeModified;

        UpdateItemUnitGroup();
    end;

    var
        Text000: Label 'You cannot delete %1 %2 because there is at least one outstanding Purchase %3 that includes this item.';
        CannotDeleteItemIfSalesDocExistErr: Label 'You cannot delete %1 %2 because there is at least one outstanding Sales %3 that includes this item.', Comment = '1: Type, 2 Item No. and 3 : Type of document Order,Invoice';
        Text002: Label 'You cannot delete %1 %2 because there are one or more outstanding production orders that include this item.';
        Text003: Label 'Do you want to change %1?';
        Text004: Label 'You cannot delete %1 %2 because there are one or more certified Production BOM that include this item.';
        CannotDeleteItemIfProdBOMVersionExistsErr: Label 'You cannot delete %1 %2 because there are one or more certified production BOM version that include this item.', Comment = '%1 - Tablecaption, %2 - No.';
        Text006: Label 'Prices including VAT cannot be calculated when %1 is %2.';
        Text007: Label 'You cannot change %1 because there are one or more ledger entries for this item.';
        Text008: Label 'You cannot change %1 because there is at least one outstanding Purchase %2 that include this item.';
        Text014: Label 'You cannot delete %1 %2 because there are one or more production order component lines that include this item with a remaining quantity that is not 0.';
        Text016: Label 'You cannot delete %1 %2 because there are one or more outstanding transfer orders that include this item.';
        Text017: Label 'You cannot delete %1 %2 because there is at least one outstanding Service %3 that includes this item.';
        Text018: Label '%1 must be %2 in %3 %4 when %5 is %6.';
        Text019: Label 'You cannot change %1 because there are one or more open ledger entries for this item.';
        Text020: Label 'There may be orders and open ledger entries for the item. ';
        Text021: Label 'If you change %1 it may affect new orders and entries.\\';
        Text022: Label 'Do you want to change %1?';
        GLSetup: Record "General Ledger Setup";
        InvtSetup: Record "Inventory Setup";
        Text023: Label 'You cannot delete %1 %2 because there is at least one %3 that includes this item.';
        Text024: Label 'If you change %1 it may affect existing production orders.\';
        Text025: Label '%1 must be an integer because %2 %3 is set up to use %4.';
        Text026: Label '%1 cannot be changed because the %2 has work in process (WIP). Changing the value may offset the WIP account.';
        Text7380: Label 'If you change the %1, the %2 and %3 are calculated.\Do you still want to change the %1?', Comment = 'If you change the Phys Invt Counting Period Code, the Next Counting Start Date and Next Counting End Date are calculated.\Do you still want to change the Phys Invt Counting Period Code?';
        Text7381: Label 'Cancelled.';
        Text99000000: Label 'The change will not affect existing entries.\';
        CommentLine: Record "Comment Line";
        Text99000001: Label 'If you want to generate %1 for existing entries, you must run a regenerative planning.';
        ItemVend: Record "Item Vendor";
        ItemReference: Record "Item Reference";
        SalesPrepmtPct: Record "Sales Prepayment %";
        PurchPrepmtPct: Record "Purchase Prepayment %";
        ItemTranslation: Record "Item Translation";
        VATPostingSetup: Record "VAT Posting Setup";
        ExtTextHeader: Record "Extended Text Header";
        GenProdPostingGrp: Record "Gen. Product Posting Group";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        ItemVariant: Record "Item Variant";
        ItemJnlLine: Record "Item Journal Line";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComp: Record "Prod. Order Component";
        PlanningAssignment: Record "Planning Assignment";
        SKU: Record "Stockkeeping Unit";
        ItemTrackingCode: Record "Item Tracking Code";
        ItemTrackingCode2: Record "Item Tracking Code";
        ServInvLine: Record "Service Line";
        ItemSub: Record "Item Substitution";
        TransLine: Record "Transfer Line";
        Vend: Record Vendor;
        NonstockItem: Record "Nonstock Item";
        ProdBOMHeader: Record "Production BOM Header";
        ProdBOMLine: Record "Production BOM Line";
        ItemIdent: Record "Item Identifier";
        RequisitionLine: Record "Requisition Line";
        ItemBudgetEntry: Record "Item Budget Entry";
        ItemAnalysisViewEntry: Record "Item Analysis View Entry";
        ItemAnalysisBudgViewEntry: Record "Item Analysis View Budg. Entry";
        TroubleshSetup: Record "Troubleshooting Setup";
        ServiceItem: Record "Service Item";
        ServiceContractLine: Record "Service Contract Line";
        ServiceItemComponent: Record "Service Item Component";
        InventoryPostingGroup: Record "Inventory Posting Group";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        MoveEntries: Codeunit MoveEntries;
        DimMgt: Codeunit DimensionManagement;
        ItemCostMgt: Codeunit ItemCostManagement;
        ResSkillMgt: Codeunit "Resource Skill Mgt.";
        CalendarMgt: Codeunit "Calendar Management";
        LeadTimeMgt: Codeunit "Lead-Time Management";
        HasInvtSetup: Boolean;
        GLSetupRead: Boolean;
        Text027: Label 'must be greater than 0.', Comment = 'starts with "Rounding Precision"';
        Text028: Label 'You cannot perform this action because entries for item %1 are unapplied in %2 by user %3.';
        CannotChangeFieldErr: Label 'You cannot change the %1 field on %2 %3 because at least one %4 exists for this item.', Comment = '%1 = Field Caption, %2 = Item Table Name, %3 = Item No., %4 = Table Name';
        BaseUnitOfMeasureQtyMustBeOneErr: Label 'The quantity per base unit of measure must be 1. %1 is set up with %2 per unit of measure.\\You can change this setup in the Item Units of Measure window.', Comment = '%1 Name of Unit of measure (e.g. BOX, PCS, KG...), %2 Qty. of %1 per base unit of measure ';
        OpenDocumentTrackingErr: Label 'You cannot change "Item Tracking Code" because there is at least one open document that includes this item with specified tracking: Source Type = %1, Document No. = %2.';
        Text37002000: Label 'must be greater than zero';
        Text37002001: Label '%1 must be the %2 for item process.';
        Text37002002: Label 'You cannot change %1 because there are one or more quality tests for this item.';
        Text37002003: Label '%1 and %2 cannot have the same %3 %4.';
        Text37002004: Label '%1 %2 contains variables.';
        Text37002005: Label '%1 cannot be changed with open %2 records.';
        Text37002006: Label '%1 changed to %2.';
        Text37002007: Label '%1 must be defined for Item %2';
        Text37002008: Label '%1 must be an Output Item for item process.';
        Text37002009: Label 'may not be the same as %1';
        BOMComp: Record "BOM Component";
        ProcessFns: Codeunit "Process 800 Functions";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
        P800BOMFns: Codeunit "Process 800 BOM Functions";
        LotInfo: Record "Lot No. Information";
        LotSpecFns: Codeunit "Lot Specification Functions";
        AltQtyMgt: Codeunit "Alt. Qty. Management";
        ItemReplArea: Record "Item Replenishment Area";
        FixedBinItem: Record "Item Fixed Prod. Bin";
        CommItemMgmt: Codeunit "Commodity Item Management";
        Text37002010: Label 'must be blank';
        Text37002011: Label '%1 %2 must be the %3 on %4 %5 to have a %6 of %7.';
        Text37002012: Label '%1 %2 is not approved for %3 %4.';
        Text37002013: Label 'Unapproved item %1 is on %2 %3.';
        Text37002014: Label 'You cannot delete %1 %2 because there are one or more open repack orders that include this item.';
        Text37002015: Label 'You cannot delete %1 %2 because there are one or more open repack order lines that include this item.';
        Text37002016: Label 'You cannot delete %1 %2 because there is an open container type that uses this item.';
        Text37002860: Label 'Nutrient Breakdown (per %1 %2)';
        ItemSlot: Record "Item Slot";
        DataCollectionMgmt: Codeunit "Data Collection Management";
        P800Mgmt: Codeunit "Process 800 Prod. Order Mgt.";
        ItemLabel: Record "Label Selection";
        AllergenManagement: Codeunit "Allergen Management";
        CatalogItemMgt: Codeunit "Catalog Item Management";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        SelectItemErr: Label 'You must select an existing item.';
        CreateNewItemTxt: Label 'Create a new item card for %1.', Comment = '%1 is the name to be used to create the customer. ';
        ItemNotRegisteredTxt: Label 'This item is not registered. To continue, choose one of the following options:';
        SelectItemTxt: Label 'Select an existing item.';
        UnitOfMeasureNotExistErr: Label 'The Unit of Measure with Code %1 does not exist.', Comment = '%1 = Code of Unit of measure';
        ItemLedgEntryTableCaptionTxt: Label 'Item Ledger Entry';
        ItemTrackingCodeIgnoresExpirationDateErr: Label 'The settings for expiration dates do not match on the item tracking code and the item. Both must either use, or not use, expiration dates.', Comment = '%1 is the Item number';
        ReplenishmentSystemTransferErr: Label 'The Replenishment System Transfer cannot be used for item.';
        WhseEntriesExistErr: Label 'You cannot change %1 because there are one or more warehouse entries for this item.', Comment = '%1: Changed field name';
        ItemUnitGroupPrefixLbl: Label 'ITEM', Locked = true;

    local procedure DeleteRelatedData()
    var
        BinContent: Record "Bin Content";
        SocialListeningSearchTopic: Record "Social Listening Search Topic";
        MyItem: Record "My Item";
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
    begin
        ItemBudgetEntry.SetCurrentKey("Analysis Area", "Budget Name", "Item No.");
        ItemBudgetEntry.SetRange("Item No.", "No.");
        ItemBudgetEntry.DeleteAll(true);

        ItemSub.Reset();
        ItemSub.SetRange(Type, ItemSub.Type::Item);
        ItemSub.SetRange("No.", "No.");
        ItemSub.DeleteAll();

        ItemSub.Reset();
        ItemSub.SetRange("Substitute Type", ItemSub."Substitute Type"::Item);
        ItemSub.SetRange("Substitute No.", "No.");
        ItemSub.DeleteAll();

        SKU.Reset();
        SKU.SetCurrentKey("Item No.");
        SKU.SetRange("Item No.", "No.");
        SKU.DeleteAll();

        CatalogItemMgt.NonstockItemDel(Rec);
        CommentLine.SetRange("Table Name", CommentLine."Table Name"::Item);
        CommentLine.SetRange("No.", "No.");
        CommentLine.DeleteAll();

        ItemVend.SetCurrentKey("Item No.");
        ItemVend.SetRange("Item No.", "No.");
        ItemVend.DeleteAll();

        ItemReference.SetRange("Item No.", "No.");
        ItemReference.DeleteAll();

        SalesPrepmtPct.SetRange("Item No.", "No.");
        SalesPrepmtPct.DeleteAll();

        PurchPrepmtPct.SetRange("Item No.", "No.");
        PurchPrepmtPct.DeleteAll();

        ItemTranslation.SetRange("Item No.", "No.");
        ItemTranslation.DeleteAll();

        ItemUnitOfMeasure.SetRange("Item No.", "No.");
        ItemUnitOfMeasure.DeleteAll();

        ItemVariant.SetRange("Item No.", "No.");
        ItemVariant.DeleteAll();

        ExtTextHeader.SetRange("Table Name", ExtTextHeader."Table Name"::Item);
        ExtTextHeader.SetRange("No.", "No.");
        ExtTextHeader.DeleteAll(true);

        ItemAnalysisViewEntry.SetRange("Item No.", "No.");
        ItemAnalysisViewEntry.DeleteAll();

        ItemAnalysisBudgViewEntry.SetRange("Item No.", "No.");
        ItemAnalysisBudgViewEntry.DeleteAll();

        PlanningAssignment.SetRange("Item No.", "No.");
        PlanningAssignment.DeleteAll();

        BOMComp.Reset();
        BOMComp.SetRange("Parent Item No.", "No.");
        BOMComp.DeleteAll();

        TroubleshSetup.Reset();
        TroubleshSetup.SetRange(Type, TroubleshSetup.Type::Item);
        TroubleshSetup.SetRange("No.", "No.");
        TroubleshSetup.DeleteAll();

        ResSkillMgt.DeleteItemResSkills("No.");
        DimMgt.DeleteDefaultDim(DATABASE::Item, "No.");

        ItemIdent.Reset();
        ItemIdent.SetCurrentKey("Item No.");
        ItemIdent.SetRange("Item No.", "No.");
        ItemIdent.DeleteAll();

        BinContent.SetCurrentKey("Item No.");
        BinContent.SetRange("Item No.", "No.");
        BinContent.DeleteAll();

        MyItem.SetRange("Item No.", "No.");
        MyItem.DeleteAll();

        if not SocialListeningSearchTopic.IsEmpty() then begin
            SocialListeningSearchTopic.FindSearchTopic(SocialListeningSearchTopic."Source Type"::Item, "No.");
            SocialListeningSearchTopic.DeleteAll();
        end;

        // P8000494A
        ItemReplArea.Reset;
        ItemReplArea.SetRange("Item No.", "No.");
        ItemReplArea.DeleteAll(true);

        FixedBinItem.Reset;
        FixedBinItem.SetRange("Item No.", "No.");
        FixedBinItem.DeleteAll(true);
        // P8000494A

        // P8000968
        ItemSlot.SetRange("Item No.", "No.");
        ItemSlot.DeleteAll;
        // P8000968

        // P8001123
        ItemLabel.SetRange("Source Type", DATABASE::Item); // P8001322
        ItemLabel.SetRange("Source No.", "No.");
        ItemLabel.DeleteAll;

        // P8001123

        ItemAttributeValueMapping.Reset();
        ItemAttributeValueMapping.SetRange("Table ID", DATABASE::Item);
        ItemAttributeValueMapping.SetRange("No.", "No.");
        ItemAttributeValueMapping.DeleteAll();

        OnAfterDeleteRelatedData(Rec);
    end;

    procedure AssistEdit() Result: Boolean
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeAssistEdit(Rec, xRec, Result, IsHandled);
        if IsHandled then
            exit(Result);

        GetInvtSetup;
        InvtSetup.TestField("Item Nos.");
        if NoSeriesMgt.SelectSeries(InvtSetup."Item Nos.", xRec."No. Series", "No. Series") then begin
            NoSeriesMgt.SetSeries("No.");
            Validate("No.");
            exit(true);
        end;
    end;

    procedure FindItemVend(var ItemVend: Record "Item Vendor"; LocationCode: Code[10])
    var
        GetPlanningParameters: Codeunit "Planning-Get Parameters";
    begin
        TestField("No.");
        ItemVend.Reset();
        ItemVend.SetRange("Item No.", "No.");
        ItemVend.SetRange("Vendor No.", ItemVend."Vendor No.");
        ItemVend.SetRange("Variant Code", ItemVend."Variant Code");
        OnFindItemVendOnAfterSetFilters(ItemVend, Rec);

        if not ItemVend.Find('+') then begin
            ItemVend."Item No." := "No.";
            ItemVend."Vendor Item No." := '';
            GetPlanningParameters.AtSKU(SKU, "No.", ItemVend."Variant Code", LocationCode);
            if ItemVend."Vendor No." = '' then
                ItemVend."Vendor No." := SKU."Vendor No.";
            if ItemVend."Vendor Item No." = '' then
                ItemVend."Vendor Item No." := SKU."Vendor Item No.";
            ItemVend."Lead Time Calculation" := SKU."Lead Time Calculation";
        end;
        ItemVend.FindLeadTimeCalculation(Rec, SKU, LocationCode);
        ItemVend.Reset();
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        OnBeforeValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode);

        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        if not IsTemporary then begin
            DimMgt.SaveDefaultDim(DATABASE::Item, "No.", FieldNumber, ShortcutDimCode);
            Modify;
        end;

        OnAfterValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode);
    end;

    procedure TestNoEntriesExist(CurrentFieldName: Text[100])
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        PurchaseLine: Record "Purchase Line";
        IsHandled: Boolean;
    begin
        if "No." = '' then
            exit;

        IsHandled := false;
        OnBeforeTestNoItemLedgEntiesExist(Rec, CurrentFieldName, IsHandled);
        if not IsHandled then begin
            ItemLedgEntry.SetCurrentKey("Item No.");
            ItemLedgEntry.SetRange("Item No.", "No.");
            if not ItemLedgEntry.IsEmpty() then
                Error(Text007, CurrentFieldName);
        end;

        IsHandled := false;
        OnBeforeTestNoPurchLinesExist(Rec, CurrentFieldName, IsHandled);
        if not IsHandled then begin
            PurchaseLine.SetCurrentKey("Document Type", Type, "No.");
            PurchaseLine.SetFilter(
              "Document Type", '%1|%2',
              PurchaseLine."Document Type"::Order,
              PurchaseLine."Document Type"::"Return Order");
            PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
            PurchaseLine.SetRange("No.", "No.");
            if PurchaseLine.FindFirst then
                Error(Text008, CurrentFieldName, PurchaseLine."Document Type");
        end;
    end;

    local procedure TestNoWhseEntriesExist(CurrentFieldName: Text)
    var
        WarehouseEntry: Record "Warehouse Entry";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTestNoWhseEntriesExist(Rec, CurrentFieldName, IsHandled);
        if IsHandled then
            exit;

        WarehouseEntry.SetRange("Item No.", "No.");
        if not WarehouseEntry.IsEmpty() then
            Error(WhseEntriesExistErr, CurrentFieldName);
    end;

    procedure TestNoOpenEntriesExist(CurrentFieldName: Text[100])
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        ItemLedgEntry.SetCurrentKey("Item No.", Open);
        ItemLedgEntry.SetRange("Item No.", "No.");
        ItemLedgEntry.SetRange(Open, true);
        if not ItemLedgEntry.IsEmpty() then
            Error(
              Text019,
              CurrentFieldName);
    end;

    local procedure TestNoOpenDocumentsWithTrackingExist()
    var
        TrackingSpecification: Record "Tracking Specification";
        ReservationEntry: Record "Reservation Entry";
        RecRef: RecordRef;
        SourceType: Integer;
        SourceID: Code[20];
    begin
        if ItemTrackingCode2.Code = '' then
            exit;

        TrackingSpecification.SetRange("Item No.", "No.");
        if TrackingSpecification.FindFirst then begin
            SourceType := TrackingSpecification."Source Type";
            SourceID := TrackingSpecification."Source ID";
        end else begin
            ReservationEntry.SetRange("Item No.", "No.");
            ReservationEntry.SetFilter("Item Tracking", '<>%1', ReservationEntry."Item Tracking"::None);
            if ReservationEntry.FindFirst then begin
                SourceType := ReservationEntry."Source Type";
                SourceID := ReservationEntry."Source ID";
            end;
        end;

        if SourceType = 0 then
            exit;

        RecRef.Open(SourceType);
        Error(OpenDocumentTrackingErr, RecRef.Caption, SourceID);
    end;

    procedure ItemSKUGet(var Item: Record Item; LocationCode: Code[10]; VariantCode: Code[10])
    var
        SKU: Record "Stockkeeping Unit";
    begin
        if Item.Get("No.") then
            if SKU.Get(LocationCode, Item."No.", VariantCode) then
                Item."Shelf No." := SKU."Shelf No.";
    end;

    procedure GetSKU(LocationCode: Code[10]; VariantCode: Code[10]) SKU: Record "Stockkeeping Unit" temporary
    var
        PlanningGetParameters: Codeunit "Planning-Get Parameters";
    begin
        PlanningGetParameters.AtSKU(SKU, "No.", VariantCode, LocationCode);
    end;

    local procedure GetInvtSetup()
    begin
        if not HasInvtSetup then begin
            InvtSetup.Get();
            HasInvtSetup := true;
        end;
    end;

    procedure IsMfgItem() Result: Boolean
    begin
        Result := "Replenishment System" = "Replenishment System"::"Prod. Order";
        OnAfterIsMfgItem(Rec, Result);
    end;

    procedure IsAssemblyItem(): Boolean
    begin
        exit("Replenishment System" = "Replenishment System"::Assembly);
    end;

    procedure HasBOM(): Boolean
    begin
        CalcFields("Assembly BOM");
        exit("Assembly BOM" or ("Production BOM No." <> ''));
    end;

    local procedure GetGLSetup()
    begin
        if not GLSetupRead then
            GLSetup.Get();
        GLSetupRead := true;
    end;

    local procedure ProdOrderExist(): Boolean
    begin
        ProdOrderLine.SetCurrentKey(Status, "Item No.");
        ProdOrderLine.SetFilter(Status, '..%1', ProdOrderLine.Status::Released);
        ProdOrderLine.SetRange("Item No.", "No.");
        if not ProdOrderLine.IsEmpty() then
            exit(true);

        exit(false);
    end;

    procedure CheckSerialNoQty(ItemNo: Code[20]; FieldName: Text[30]; Quantity: Decimal)
    var
        ItemRec: Record Item;
        ItemTrackingCode3: Record "Item Tracking Code";
    begin
        if Quantity = Round(Quantity, 1) then
            exit;
        if not ItemRec.Get(ItemNo) then
            exit;
        if ItemRec."Item Tracking Code" = '' then
            exit;
        if not ItemTrackingCode3.Get(ItemRec."Item Tracking Code") then
            exit;
        CheckSNSpecificTrackingInteger(ItemTrackingCode3, ItemRec, FieldName);
    end;

    local procedure CheckSNSpecificTrackingInteger(ItemTrackingCode3: Record "Item Tracking Code"; ItemRec: Record Item; FieldName: Text[30])
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckSNSpecificTrackingInteger(ItemRec, IsHandled);
        if IsHandled then
            exit;

        if ItemTrackingCode3."SN Specific Tracking" then
            Error(Text025,
              FieldName,
              TableCaption,
              ItemRec."No.",
              ItemTrackingCode3.FieldCaption("SN Specific Tracking"));
    end;

    local procedure CheckForProductionOutput(ItemNo: Code[20])
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        Clear(ItemLedgEntry);
        ItemLedgEntry.SetCurrentKey("Item No.", "Entry Type", "Variant Code", "Drop Shipment", "Location Code", "Posting Date");
        ItemLedgEntry.SetRange("Item No.", ItemNo);
        ItemLedgEntry.SetRange("Entry Type", ItemLedgEntry."Entry Type"::Output);
        if not ItemLedgEntry.IsEmpty() then
            Error(Text026, FieldCaption("Inventory Value Zero"), TableCaption);
    end;

    procedure CheckBlockedByApplWorksheet()
    var
        ApplicationWorksheet: Page "Application Worksheet";
    begin
        if "Application Wksh. User ID" <> '' then
            Error(Text028, "No.", ApplicationWorksheet.Caption, "Application Wksh. User ID");
    end;

    procedure ShowTimelineFromItem(var Item: Record Item)
    var
        ItemAvailByTimeline: Page "Item Availability by Timeline";
    begin
        ItemAvailByTimeline.SetItem(Item);
        ItemAvailByTimeline.Run;
    end;

    procedure ShowTimelineFromSKU(ItemNo: Code[20]; LocationCode: Code[10]; VariantCode: Code[10])
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        Item.SetRange("No.", Item."No.");
        Item.SetRange("Variant Filter", VariantCode);
        Item.SetRange("Location Filter", LocationCode);
        ShowTimelineFromItem(Item);
    end;

    local procedure GetFieldCaption(FldNo: Integer): Text
    var
        ItemRecordRef: RecordRef;
        FieldRef: FieldRef;
    begin
        // P80096141
        ItemRecordRef.GetTable(Rec);
        FieldRef := ItemRecordRef.Field(FldNo);
        exit(FieldRef.Caption);
    end;

    local procedure FieldCaption2Number(CurrFieldCaption: Text): Integer
    var
        ItemRecordRef: RecordRef;
        FieldRef: FieldRef;
        Cnt: Integer;
    begin
        // P80096141
        if CurrFieldCaption = '' then
            exit(0);

        ItemRecordRef.GetTable(Rec);
        for Cnt := 1 to ItemRecordRef.FieldCount do begin
            FieldRef := ItemRecordRef.FieldIndex(Cnt);
            if FieldRef.Caption = CurrFieldCaption then
                exit(FieldRef.Number);
        end;
    end;

    procedure CheckJournalsAndWorksheets(CurrFieldCaption: Text)
    begin
        // P80096141
        CheckJournalsAndWorksheets(FieldCaption2Number(CurrFieldCaption));
    end;

    procedure CheckJournalsAndWorksheets(CurrFieldNo: Integer)
    begin
        CheckItemJnlLine(CurrFieldNo);
        CheckStdCostWksh(CurrFieldNo);
        CheckReqLine(CurrFieldNo);
        CheckContJnlLine(CurrFieldNo);  // P8001267, P80096141
        CheckMaintJnlLine(CurrFieldNo); // P8001267, P80096141
    end;

    local procedure CheckItemJnlLine(CurrFieldNo: Integer)
    begin
        ItemJnlLine.SetRange("Item No.", "No.");
        if not ItemJnlLine.IsEmpty() then begin
            if CurrFieldNo = 0 then
                Error(Text023, TableCaption, "No.", ItemJnlLine.TableCaption);
            // if CurrFieldNo = FieldNo(Type) then // P80096141
            Error(CannotChangeFieldErr, GetFieldCaption(CurrFieldNo), TableCaption, "No.", ItemJnlLine.TableCaption); // P80096141
        end;
    end;

    local procedure CheckStdCostWksh(CurrFieldNo: Integer)
    var
        StdCostWksh: Record "Standard Cost Worksheet";
    begin
        StdCostWksh.Reset();
        StdCostWksh.SetRange(Type, StdCostWksh.Type::Item);
        StdCostWksh.SetRange("No.", "No.");
        if not StdCostWksh.IsEmpty() then
            if CurrFieldNo = 0 then
                Error(Text023, TableCaption, "No.", StdCostWksh.TableCaption);
    end;

    local procedure CheckReqLine(CurrFieldNo: Integer)
    begin
        RequisitionLine.SetCurrentKey(Type, "No.");
        RequisitionLine.SetRange(Type, RequisitionLine.Type::Item);
        RequisitionLine.SetRange("No.", "No.");
        if not RequisitionLine.IsEmpty() then begin
            if CurrFieldNo = 0 then
                Error(Text023, TableCaption, "No.", RequisitionLine.TableCaption);
            // if CurrFieldNo = FieldNo(Type) then // P80096141
            Error(CannotChangeFieldErr, GetFieldCaption(CurrFieldNo), TableCaption, "No.", RequisitionLine.TableCaption); // P80096141
        end;
    end;

    local procedure CheckContJnlLine(CurrFieldNo: Integer)
    var
        ContJournalLine: Record "Container Journal Line";
    begin
        // P8001267
        ContJournalLine.SetRange("Container Item No.", "No.");
        if not ContJournalLine.IsEmpty then begin
            if CurrFieldNo = 0 then
                Error(Text023, TableCaption, "No.", ContJournalLine.TableCaption);
            Error(CannotChangeFieldErr, GetFieldCaption(CurrFieldNo), TableCaption, "No.", ContJournalLine.TableCaption);
        end;
    end;

    local procedure CheckMaintJnlLine(CurrFieldNo: Integer)
    var
        MaintJournalLine: Record "Maintenance Journal Line";
    begin
        // P8001267
        MaintJournalLine.SetRange("Entry Type", MaintJournalLine."Entry Type"::"Material-Stock");
        MaintJournalLine.SetRange("Item No.", "No.");
        if not MaintJournalLine.IsEmpty then begin
            if CurrFieldNo = 0 then
                Error(Text023, TableCaption, "No.", MaintJournalLine.TableCaption);
            Error(CannotChangeFieldErr, GetFieldCaption(CurrFieldNo), TableCaption, "No.", MaintJournalLine.TableCaption);
        end;
    end;

    procedure CheckDocuments(CurrFieldCaption: Text)
    begin
        // P80096141
        CheckDocuments(FieldCaption2Number(CurrFieldCaption));
    end;

    procedure CheckDocuments(CurrFieldNo: Integer)
    begin
        if "No." = '' then
            exit;

        CheckBOM(CurrFieldNo);
        CheckPurchLine(CurrFieldNo);
        CheckSalesLine(CurrFieldNo);
        CheckProdOrderLine(CurrFieldNo);
        CheckProdOrderCompLine(CurrFieldNo);
        CheckPlanningCompLine(CurrFieldNo);
        CheckTransLine(CurrFieldNo);
        CheckServLine(CurrFieldNo);
        CheckProdBOMLine(CurrFieldNo);
        CheckServContractLine(CurrFieldNo);
        CheckAsmHeader(CurrFieldNo);
        CheckAsmLine(CurrFieldNo);
        CheckJobPlanningLine(CurrFieldNo);
        CheckRepackOrder(CurrFieldNo);       // P8001267, P80096141
        CheckRepackOrderLine(CurrFieldNo);   // P8001267, P80096141

        OnAfterCheckDocuments(Rec, xRec, CurrFieldNo);
    end;

    local procedure CheckBOM(CurrFieldNo: Integer)
    begin
        BOMComp.Reset();
        BOMComp.SetCurrentKey(Type, "No.");
        BOMComp.SetRange(Type, BOMComp.Type::Item);
        BOMComp.SetRange("No.", "No.");
        if not BOMComp.IsEmpty() then begin
            if CurrFieldNo = 0 then
                Error(Text023, TableCaption, "No.", BOMComp.TableCaption);
            // if CurrFieldNo = FieldNo(Type) then // P80096141
            Error(CannotChangeFieldErr, GetFieldCaption(CurrFieldNo), TableCaption, "No.", BOMComp.TableCaption); // P80096141
        end;
    end;

    local procedure CheckPurchLine(CurrFieldNo: Integer)
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetCurrentKey(Type, "No.");
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        PurchaseLine.SetRange("No.", "No.");
        if PurchaseLine.FindFirst then begin
            if CurrFieldNo = 0 then
                Error(Text000, TableCaption, "No.", PurchaseLine."Document Type");
            // if CurrFieldNo = FieldNo(Type) then // P80096141
            Error(CannotChangeFieldErr, GetFieldCaption(CurrFieldNo), TableCaption, "No.", PurchaseLine.TableCaption); // P80096141
        end;
    end;

    local procedure CheckSalesLine(CurrFieldNo: Integer)
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetCurrentKey(Type, "No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetRange("No.", "No.");
        if SalesLine.FindFirst() then begin
            if CurrFieldNo = 0 then
                Error(CannotDeleteItemIfSalesDocExistErr, TableCaption, "No.", SalesLine."Document Type");
            // if CurrFieldNo = FieldNo(Type) then // P80096141
            Error(CannotChangeFieldErr, GetFieldCaption(CurrFieldNo), TableCaption, "No.", SalesLine.TableCaption); // P80096141
        end;
    end;

    local procedure CheckProdOrderLine(CurrFieldNo: Integer)
    begin
        if ProdOrderExist then begin
            if CurrFieldNo = 0 then
                Error(Text002, TableCaption, "No.");
            // if CurrFieldNo = FieldNo(Type) then // P80096141
            Error(CannotChangeFieldErr, GetFieldCaption(CurrFieldNo), TableCaption, "No.", ProdOrderLine.TableCaption); // P80096141
        end;
    end;

    local procedure CheckProdOrderCompLine(CurrFieldNo: Integer)
    begin
        ProdOrderComp.SetCurrentKey(Status, "Item No.");
        ProdOrderComp.SetFilter(Status, '..%1', ProdOrderComp.Status::Released);
        ProdOrderComp.SetRange("Item No.", "No.");
        if not ProdOrderComp.IsEmpty() then begin
            if CurrFieldNo = 0 then
                Error(Text014, TableCaption, "No.");
            // if CurrFieldNo = FieldNo(Type) then // P80096141
            Error(CannotChangeFieldErr, GetFieldCaption(CurrFieldNo), TableCaption, "No.", ProdOrderComp.TableCaption); // P80096141
        end;
    end;

    local procedure CheckPlanningCompLine(CurrFieldNo: Integer)
    var
        PlanningComponent: Record "Planning Component";
    begin
        PlanningComponent.SetCurrentKey("Item No.", "Variant Code", "Location Code", "Due Date", "Planning Line Origin");
        PlanningComponent.SetRange("Item No.", "No.");
        if not PlanningComponent.IsEmpty() then begin
            if CurrFieldNo = 0 then
                Error(Text023, TableCaption, "No.", PlanningComponent.TableCaption);
            // if CurrFieldNo = FieldNo(Type) then // P80096141
            Error(CannotChangeFieldErr, GetFieldCaption(CurrFieldNo), TableCaption, "No.", PlanningComponent.TableCaption); // P80096141
        end;
    end;

    local procedure CheckTransLine(CurrFieldNo: Integer)
    begin
        TransLine.SetCurrentKey("Item No.");
        TransLine.SetRange("Item No.", "No.");
        if not TransLine.IsEmpty() then begin
            if CurrFieldNo = 0 then
                Error(Text016, TableCaption, "No.");
            // if CurrFieldNo = FieldNo(Type) then // P80096141
            Error(CannotChangeFieldErr, GetFieldCaption(CurrFieldNo), TableCaption, "No.", TransLine.TableCaption); // P80096141
        end;
    end;

    local procedure CheckServLine(CurrFieldNo: Integer)
    begin
        ServInvLine.Reset();
        ServInvLine.SetCurrentKey(Type, "No.");
        ServInvLine.SetRange(Type, ServInvLine.Type::Item);
        ServInvLine.SetRange("No.", "No.");
        if not ServInvLine.IsEmpty() then begin
            if CurrFieldNo = 0 then
                Error(Text017, TableCaption, "No.", ServInvLine."Document Type");
            // if CurrFieldNo = FieldNo(Type) then // P80096141
            Error(CannotChangeFieldErr, GetFieldCaption(CurrFieldNo), TableCaption, "No.", ServInvLine.TableCaption); // P80096141
        end;
    end;

    local procedure CheckProdBOMLine(CurrFieldNo: Integer)
    var
        ProductionBOMVersion: Record "Production BOM Version";
    begin
        ProdBOMLine.Reset();
        ProdBOMLine.SetCurrentKey(Type, "No.");
        ProdBOMLine.SetRange(Type, ProdBOMLine.Type::Item);
        ProdBOMLine.SetRange("No.", "No.");
        if ProdBOMLine.Find('-') then begin
            if CurrFieldNo = 0 then
                repeat
                    if ProdBOMHeader.Get(ProdBOMLine."Production BOM No.") and
                       (ProdBOMHeader.Status = ProdBOMHeader.Status::Certified)
                    then
                        Error(Text004, TableCaption, "No.");
                    if ProductionBOMVersion.Get(ProdBOMLine."Production BOM No.", ProdBOMLine."Version Code") and
                       (ProductionBOMVersion.Status = ProductionBOMVersion.Status::Certified)
                    then
                        Error(CannotDeleteItemIfProdBOMVersionExistsErr, TableCaption, "No.");
                until ProdBOMLine.Next() = 0;
            // if CurrFieldNo = FieldNo(Type) then // P80096141
            Error(CannotChangeFieldErr, GetFieldCaption(CurrFieldNo), TableCaption, "No.", ProdBOMLine.TableCaption); // P80096141
        end;
    end;

    local procedure CheckServContractLine(CurrFieldNo: Integer)
    begin
        ServiceContractLine.Reset();
        ServiceContractLine.SetRange("Item No.", "No.");
        if not ServiceContractLine.IsEmpty() then begin
            if CurrFieldNo = 0 then
                Error(Text023, TableCaption, "No.", ServiceContractLine.TableCaption);
            // if CurrFieldNo = FieldNo(Type) then // P80096141
            Error(CannotChangeFieldErr, GetFieldCaption(CurrFieldNo), TableCaption, "No.", ServiceContractLine.TableCaption); // P80096141
        end;
    end;

    local procedure CheckAsmHeader(CurrFieldNo: Integer)
    var
        AsmHeader: Record "Assembly Header";
    begin
        AsmHeader.SetCurrentKey("Document Type", "Item No.");
        AsmHeader.SetRange("Item No.", "No.");
        if not AsmHeader.IsEmpty() then begin
            if CurrFieldNo = 0 then
                Error(Text023, TableCaption, "No.", AsmHeader.TableCaption);
            // if CurrFieldNo = FieldNo(Type) then // P80096141
            Error(CannotChangeFieldErr, GetFieldCaption(CurrFieldNo), TableCaption, "No.", AsmHeader.TableCaption); // P80096141
        end;
    end;

    local procedure CheckAsmLine(CurrFieldNo: Integer)
    var
        AsmLine: Record "Assembly Line";
    begin
        AsmLine.SetCurrentKey(Type, "No.");
        AsmLine.SetRange(Type, AsmLine.Type::Item);
        AsmLine.SetRange("No.", "No.");
        if not AsmLine.IsEmpty() then begin
            if CurrFieldNo = 0 then
                Error(Text023, TableCaption, "No.", AsmLine.TableCaption);
            // if CurrFieldNo = FieldNo(Type) then // P80096141
            Error(CannotChangeFieldErr, GetFieldCaption(CurrFieldNo), TableCaption, "No.", AsmLine.TableCaption); // P80096141
        end;
    end;

    local procedure CheckRepackOrder(CurrFieldNo: Integer)
    var
        RepackOrder: Record "Repack Order";
    begin
        // P8001267
        RepackOrder.SetCurrentKey(Status, "Item No.");
        RepackOrder.SetRange(Status, RepackOrder.Status::Open);
        RepackOrder.SetRange("Item No.", "No.");
        if not RepackOrder.IsEmpty then begin
            if CurrFieldNo = 0 then
                Error(Text37002014, TableCaption, "No.");
            Error(CannotChangeFieldErr, GetFieldCaption(CurrFieldNo), TableCaption, "No.", RepackOrder.TableCaption);
        end;
    end;

    local procedure CheckRepackOrderLine(CurrFieldNo: Integer)
    var
        RepackOrderLine: Record "Repack Order Line";
    begin
        // P8001267
        RepackOrderLine.SetCurrentKey(Status, Type, "No.");
        RepackOrderLine.SetRange(Status, RepackOrderLine.Status::Open);
        RepackOrderLine.SetRange(Type, RepackOrderLine.Type::Item);
        RepackOrderLine.SetRange("No.", "No.");
        if not RepackOrderLine.IsEmpty then begin
            if CurrFieldNo = 0 then
                Error(Text37002015, TableCaption, "No.");
            Error(CannotChangeFieldErr, GetFieldCaption(CurrFieldNo), TableCaption, "No.", RepackOrderLine.TableCaption);
        end;
    end;

    local procedure CheckUpdateFieldsForNonInventoriableItem()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckUpdateFieldsForNonInventoriableItem(Rec, xRec, CurrFieldNo, IsHandled);
        if IsHandled then
            exit;

        CalcFields("Assembly BOM");
        TestField("Assembly BOM", false);

        CalcFields("Stockkeeping Unit Exists");
        TestField("Stockkeeping Unit Exists", false);

        Validate("Assembly Policy", "Assembly Policy"::"Assemble-to-Stock");
        Validate("Replenishment System", "Replenishment System"::Purchase);
        Validate(Reserve, Reserve::Never);
        Validate("Inventory Posting Group", '');
        Validate("Item Tracking Code", '');
        Validate("Costing Method", "Costing Method"::FIFO);
        Validate("Production BOM No.", '');
        Validate("Routing No.", '');
        Validate("Reordering Policy", "Reordering Policy"::" ");
        Validate("Order Tracking Policy", "Order Tracking Policy"::None);
        Validate("Overhead Rate", 0);
        Validate("Indirect Cost %", 0);
        // P8001290
        if (Type = Type::FOODContainer) then begin
            if ("Item Type" <> "Item Type"::Container) then
                Validate("Item Type", "Item Type"::Container);
            if not "Non-Warehouse Item" then
                Validate("Non-Warehouse Item", true);
        end else                                  // P80064675
            Validate("Item Type", "Item Type"::" "); // P80064675
                                                     // P8001290
    end;

    procedure PreventNegativeInventory(): Boolean
    var
        InventorySetup: Record "Inventory Setup";
    begin
        case "Prevent Negative Inventory" of
            "Prevent Negative Inventory"::Yes:
                exit(true);
            "Prevent Negative Inventory"::No:
                exit(false);
            "Prevent Negative Inventory"::Default:
                begin
                    InventorySetup.Get();
                    exit(InventorySetup."Prevent Negative Inventory");
                end;
        end;
    end;

    local procedure CheckJobPlanningLine(CurrFieldNo: Integer)
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        JobPlanningLine.SetCurrentKey(Type, "No.");
        JobPlanningLine.SetRange(Type, JobPlanningLine.Type::Item);
        JobPlanningLine.SetRange("No.", "No.");
        if not JobPlanningLine.IsEmpty() then begin
            if CurrFieldNo = 0 then
                Error(Text023, TableCaption, "No.", JobPlanningLine.TableCaption);
            // if CurrFieldNo = FieldNo(Type) then // P80096141
            Error(CannotChangeFieldErr, GetFieldCaption(CurrFieldNo), TableCaption, "No.", JobPlanningLine.TableCaption); // P80096141
        end;
    end;

    local procedure CalcVAT(): Decimal
    begin
        if "Price Includes VAT" then begin
            VATPostingSetup.Get("VAT Bus. Posting Gr. (Price)", "VAT Prod. Posting Group");
            case VATPostingSetup."VAT Calculation Type" of
                VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT":
                    VATPostingSetup."VAT %" := 0;
                VATPostingSetup."VAT Calculation Type"::"Sales Tax":
                    Error(
                      Text006,
                      VATPostingSetup.FieldCaption("VAT Calculation Type"),
                      VATPostingSetup."VAT Calculation Type");
            end;
        end else
            Clear(VATPostingSetup);

        exit(VATPostingSetup."VAT %" / 100);
    end;

    procedure CalcUnitPriceExclVAT(): Decimal
    begin
        GetGLSetup;
        if 1 + CalcVAT = 0 then
            exit(0);
        exit(Round("Unit Price" / (1 + CalcVAT), GLSetup."Unit-Amount Rounding Precision"));
    end;

    procedure TestNoQCTestsExist(CurrentFieldName: Text[30])
    var
        DataCollectionLine: Record "Data Collection Line";
    begin
        // PR2.00 Begin
        // P8001090
        DataCollectionLine.SetRange("Source ID", DATABASE::Item);
        DataCollectionLine.SetRange("Source Key 1", "No.");
        DataCollectionLine.SetRange(Type, DataCollectionLine.Type::"Q/C");
        //ItemTest.SETRANGE("Item No.","No.");
        //IF ItemTest.FIND('-') THEN
        if not DataCollectionLine.IsEmpty then
            // P8001090
            Error(
            Text37002002,
            CurrentFieldName);
        // PR2.00 End
    end;

    procedure TrackAlternateUnits(): Boolean
    begin
        exit("Alternate Unit of Measure" <> ''); // PR3.60
    end;

    procedure CostInAlternateUnits(): Boolean
    begin
        exit("Costing Unit" = "Costing Unit"::Alternate); // PR3.60
    end;

    procedure PriceInAlternateUnits(): Boolean
    begin
        exit("Pricing Unit" = "Pricing Unit"::Alternate); // P8000981
    end;

    procedure CostingQtyPerBase(): Decimal
    begin
        // PR3.60
        if not CostInAlternateUnits() then
            exit(1);
        exit(AlternateQtyPerBase());
        // PR3.60
    end;

    procedure AlternateQtyPerBase(): Decimal
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        // PR3.60
        if not TrackAlternateUnits() then
            exit(1);
        ItemUnitOfMeasure.Get("No.", "Alternate Unit of Measure");
        ItemUnitOfMeasure.TestField("Qty. per Unit of Measure");
        exit(1 / ItemUnitOfMeasure."Qty. per Unit of Measure");
        // PR3.60
    end;

    procedure PricingQtyPerBase(): Decimal
    begin
        // P8000981
        if not PriceInAlternateUnits() then
            exit(1);
        exit(AlternateQtyPerBase());
    end;

    procedure ConvertUnitCostToPricing(UnitCost: Decimal): Decimal
    begin
        exit(UnitCost * (CostingQtyPerBase() / PricingQtyPerBase())); // P8000981
    end;

    procedure ConvertFieldsToBase()
    var
        QtyPerBase: Decimal;
    begin
        // PR3.60
        if CostInAlternateUnits() then begin
            QtyPerBase := CostingQtyPerBase();
            //"Unit Price" := "Unit Price" * QtyPerBase;        // P8000981
            "Unit Price" := "Unit Price" * PricingQtyPerBase(); // P8000981
            "Unit Cost" := "Unit Cost" * QtyPerBase;
            "Standard Cost" := "Standard Cost" * QtyPerBase;
            "Last Direct Cost" := "Last Direct Cost" * QtyPerBase;
            "Overhead Rate" := "Overhead Rate" * QtyPerBase;
            "Single-Level Material Cost" := "Single-Level Material Cost" * QtyPerBase;
            "Single-Level Capacity Cost" := "Single-Level Capacity Cost" * QtyPerBase;
            "Single-Level Subcontrd. Cost" := "Single-Level Subcontrd. Cost" * QtyPerBase;
            "Single-Level Cap. Ovhd Cost" := "Single-Level Cap. Ovhd Cost" * QtyPerBase;
            "Single-Level Mfg. Ovhd Cost" := "Single-Level Mfg. Ovhd Cost" * QtyPerBase;
            "Rolled-up Material Cost" := "Rolled-up Material Cost" * QtyPerBase;
            "Rolled-up Capacity Cost" := "Rolled-up Capacity Cost" * QtyPerBase;
            "Rolled-up Subcontracted Cost" := "Rolled-up Subcontracted Cost" * QtyPerBase;
            "Rolled-up Mfg. Ovhd Cost" := "Rolled-up Mfg. Ovhd Cost" * QtyPerBase;
            "Rolled-up Cap. Overhead Cost" := "Rolled-up Cap. Overhead Cost" * QtyPerBase;
        end;
        // PR3.60
    end;

    procedure ConvertFieldsToCosting()
    var
        QtyPerBase: Decimal;
    begin
        // PR3.60
        if CostInAlternateUnits() then begin
            QtyPerBase := CostingQtyPerBase();
            //Convert1FieldToCosting("Unit Price", QtyPerBase);        // P8000981
            Convert1FieldToCosting("Unit Price", PricingQtyPerBase()); // P8000981
            Convert1FieldToCosting("Unit Cost", QtyPerBase);
            Convert1FieldToCosting("Standard Cost", QtyPerBase);
            Convert1FieldToCosting("Last Direct Cost", QtyPerBase);
            Convert1FieldToCosting("Overhead Rate", QtyPerBase);
            Convert1FieldToCosting("Single-Level Material Cost", QtyPerBase);
            Convert1FieldToCosting("Single-Level Capacity Cost", QtyPerBase);
            Convert1FieldToCosting("Single-Level Subcontrd. Cost", QtyPerBase);
            Convert1FieldToCosting("Single-Level Cap. Ovhd Cost", QtyPerBase);
            Convert1FieldToCosting("Single-Level Mfg. Ovhd Cost", QtyPerBase);
            Convert1FieldToCosting("Rolled-up Material Cost", QtyPerBase);
            Convert1FieldToCosting("Rolled-up Capacity Cost", QtyPerBase);
            Convert1FieldToCosting("Rolled-up Subcontracted Cost", QtyPerBase);
            Convert1FieldToCosting("Rolled-up Mfg. Ovhd Cost", QtyPerBase);
            Convert1FieldToCosting("Rolled-up Cap. Overhead Cost", QtyPerBase);
        end;
        // PR3.60
    end;

    local procedure Convert1FieldToCosting(var ValueToConvert: Decimal; QtyPerBase: Decimal)
    begin
        // PR3.60
        ValueToConvert :=
          Round(ValueToConvert / QtyPerBase, GLSetup."Unit-Amount Rounding Precision");
        // PR3.60
    end;

    procedure GetItemUOMRndgPrecision(UOM: Code[10]; UseDefaultPrecision: Boolean) RndgPrecisionSet: Boolean
    var
        ItemUOM: Record "Item Unit of Measure";
        Handled: Boolean;
    begin
        // PR3.70.03
        /* Sets precision specific to UOM or gets item precision or sets 0.00001 default precision and returns true
        if UseDefaultPrecision is false, if both specific UOM and item precision are 0
         precision is 0 and returns false
        */
        // P80079197
        OnBeforeGetItemUOMRndgPrecision(Rec, UOM, UseDefaultPrecision, RndgPrecisionSet, Handled);
        if Handled then
            exit;
        // P80079197

        if ItemUOM.Get("No.", UOM) then
            if ItemUOM."Rounding Precision" <> 0 then begin
                "Rounding Precision" := ItemUOM."Rounding Precision";
                exit(true);
            end;

        if "Rounding Precision" <> 0 then
            exit(true)
        else
            if UseDefaultPrecision then begin
                "Rounding Precision" := 0.00001;
                exit(true);
            end else
                exit(false);

    end;

    procedure GetItemUOMRndgPrecisionError(UOM: Code[10])
    begin
        // PR3.70.03
        // replaces item.testfield("rounding precision")
        if GetItemUOMRndgPrecision(UOM, false) then
            exit
        else
            Error(Text37002007, FieldCaption("Rounding Precision"), "No.");
    end;

    procedure ConsumptionQty(): Decimal
    var
        ItemLedger: Record "Item Ledger Entry";
    begin
        // P800293A
        ItemLedger.SetCurrentKey("Item No.", "Entry Type", "Variant Code", "Drop Shipment", "Location Code", "Posting Date");
        ItemLedger.SetRange("Entry Type", ItemLedger."Entry Type"::Consumption);
        ItemLedger.SetRange("Item No.", "No.");
        CopyFilter("Location Filter", ItemLedger."Location Code");      // P8000835
        CopyFilter("Drop Shipment Filter", ItemLedger."Drop Shipment"); // P8000835
        CopyFilter("Variant Filter", ItemLedger."Variant Code");        // P8000835
        CopyFilter("Date Filter", ItemLedger."Posting Date");           // P8000835
        ItemLedger.CalcSums("Invoiced Quantity");
        exit(-ItemLedger."Invoiced Quantity");
    end;

    procedure IsFixedBinItem(LocationCode: Code[10]): Boolean
    begin
        exit(FixedBinItem.Get("No.", LocationCode)); // P8000494A
    end;

    procedure GetFixedBinItem(LocationCode: Code[10]; var FixedBinCode: Code[20]): Boolean
    begin
        // P8000494A
        if not FixedBinItem.Get("No.", LocationCode) then
            exit(false);
        FixedBinCode := FixedBinItem."Bin Code";
        exit(true);
    end;

    procedure GetFixedBinLotHandling(LocationCode: Code[10]; BinCode: Code[20]; var LotHandling: Integer): Boolean
    begin
        // P8000495A
        if not FixedBinItem.Get("No.", LocationCode) then
            exit(false);
        if (BinCode <> FixedBinItem."Bin Code") then
            exit(false);
        LotHandling := FixedBinItem."Lot Handling";
        exit(LotHandling <> FixedBinItem."Lot Handling"::Manual);
    end;

    procedure IsFixedBinSingleLotItem(LocationCode: Code[10]; BinCode: Code[20]): Boolean
    var
        LotHandling: Integer;
    begin
        // P8000495A
        if not GetFixedBinLotHandling(LocationCode, BinCode, LotHandling) then
            exit(false);
        exit(LotHandling = FixedBinItem."Lot Handling"::"Single Lot");
    end;

    procedure HasReplenishmentArea(LocationCode: Code[10]; var ReplAreaCode: Code[20]): Boolean
    begin
        // P8000494A
        if not ItemReplArea.Get("No.", LocationCode) then
            exit(false);
        ReplAreaCode := ItemReplArea."Replenishment Area Code";
        exit(true);
    end;

    procedure GetSupplyChainGroupCode(): Code[10]
    var
        ItemCategory: Record "Item Category";
    begin
        // P8000931
        if "Supply Chain Group Code" <> '' then
            exit("Supply Chain Group Code")
        else
            if "Item Category Code" <> '' then
                if ItemCategory.Get("Item Category Code") then // P8007749
                    exit(ItemCategory.GetSupplyChainGroupCode);  // P8007749
    end;

    procedure UseFreshnessDate(): Boolean
    begin
        // P8000969
        exit("Freshness Calc. Method" in ["Freshness Calc. Method"::"Best If Used By", "Freshness Calc. Method"::"Sell By"]);
    end;

    procedure TraceAltQty(): Boolean
    begin
        exit("Catch Alternate Qtys."); // P8000979
    end;

    procedure ProductionBOMNo(VariantCode: Code[10]; LocationCode: Code[10]) BOMNo: Code[20]
    var
        P80BOMFns: Codeunit "Process 800 BOM Functions";
    begin
        // P8001030
        BOMNo := "Production BOM No.";
        if ProcessFns.ProcessInstalled then
            BOMNo := P80BOMFns.GetProdBOMAtSKU(Rec, VariantCode, LocationCode);
    end;

    procedure RoutingNo(VariantCode: Code[10]; LocationCode: Code[10]) RtgNo: Code[20]
    var
        P80BOMFns: Codeunit "Process 800 BOM Functions";
    begin
        // P8001030
        RtgNo := "Routing No.";
        if ProcessFns.ProcessInstalled then
            RtgNo := P80BOMFns.GetRoutingAtSKU(Rec, VariantCode, LocationCode);
    end;

    procedure IndirectCostPct(VariantCode: Code[10]; LocationCode: Code[10]): Decimal
    begin
        // P8001030
        if ("No." = SKU."Item No.") and (VariantCode = SKU."Variant Code") and (LocationCode = SKU."Location Code") then
            exit(SKU."Indirect Cost %")
        else
            if SKU.Get(LocationCode, "No.", VariantCode) then
                exit(SKU."Indirect Cost %")
            else
                exit("Indirect Cost %");
    end;

    procedure OverheadRate(VariantCode: Code[10]; LocationCode: Code[10]): Decimal
    begin
        // P8001030
        if ("No." = SKU."Item No.") and (VariantCode = SKU."Variant Code") and (LocationCode = SKU."Location Code") then
            exit(SKU."Overhead Rate")
        else
            if SKU.Get(LocationCode, "No.", VariantCode) then
                exit(SKU."Overhead Rate")
            else
                exit("Overhead Rate");
    end;

    procedure GetLabelCode(LabelType: Integer): Code[10]
    var
        ItemLabel: Record "Label Selection";
    begin
        // P8001123
        // LabelType: 1 - Case
        //            3 - Pre-Process
        if ItemLabel.Get(DATABASE::Item, "No.", LabelType) then // P8001322
            exit(ItemLabel."Label Code");
    end;

    procedure InitFromSKU(VariantCode: Code[10]; LocationCode: Code[10])
    var
        SKU: Record "Stockkeeping Unit";
    begin
        // P8001144
        if (VariantCode <> '') or (LocationCode <> '') then
            if SKU.Get(LocationCode, "No.", VariantCode) then begin
                "Shelf No." := SKU."Shelf No.";
                "Unit Cost" := SKU."Unit Cost";
                "Standard Cost" := SKU."Standard Cost";
                "Last Direct Cost" := SKU."Last Direct Cost";
                "Vendor No." := SKU."Vendor No.";
                "Vendor Item No." := SKU."Vendor Item No.";
                "Lead Time Calculation" := SKU."Lead Time Calculation";
                "Reorder Point" := SKU."Reorder Point";
                "Maximum Inventory" := SKU."Maximum Inventory";
                "Reorder Quantity" := SKU."Reorder Quantity";
                "Lot Size" := SKU."Lot Size";
                "Discrete Order Quantity" := SKU."Discrete Order Quantity";
                "Minimum Order Quantity" := SKU."Minimum Order Quantity";
                "Maximum Order Quantity" := SKU."Maximum Order Quantity";
                "Safety Stock Quantity" := SKU."Safety Stock Quantity";
                "Order Multiple" := SKU."Order Multiple";
                "Safety Lead Time" := SKU."Safety Lead Time";
                "Flushing Method" := SKU."Flushing Method";
                "Replenishment System" := SKU."Replenishment System";
                "Time Bucket" := SKU."Time Bucket";
                "Reordering Policy" := SKU."Reordering Policy";
                "Include Inventory" := SKU."Include Inventory";
                "Manufacturing Policy" := SKU."Manufacturing Policy";
                "Rescheduling Period" := SKU."Rescheduling Period";
                "Lot Accumulation Period" := SKU."Lot Accumulation Period";
                "Dampener Period" := SKU."Dampener Period";
                "Dampener Quantity" := SKU."Dampener Quantity";
                "Overflow Level" := SKU."Overflow Level";
                "Special Equipment Code" := SKU."Special Equipment Code";
                "Put-away Template Code" := SKU."Put-away Template Code";
                "Put-away Unit of Measure Code" := SKU."Put-away Unit of Measure Code";
                "Phys Invt Counting Period Code" := SKU."Phys Invt Counting Period Code";
                "Last Counting Period Update" := SKU."Last Counting Period Update";
                "Use Cross-Docking" := SKU."Use Cross-Docking";
                "Usage Formula" := SKU."Usage Formula";
                if (SKU."Routing No." <> '') then
                    "Routing No." := SKU."Routing No.";
                if (SKU."Production BOM No." <> '') then
                    "Production BOM No." := SKU."Production BOM No.";
                "Indirect Cost %" := SKU."Indirect Cost %";
                "Overhead Rate" := SKU."Overhead Rate";
            end;
    end;

    procedure VendorApprovalRequired(): Boolean
    var
        ItemCategory: Record "Item Category";
    begin
        // P8001230
        if "Vendor Approval Required" <> "Vendor Approval Required"::" " then // P8007749
            exit("Vendor Approval Required" = "Vendor Approval Required"::Yes);

        if "Item Category Code" <> '' then
            if ItemCategory.Get("Item Category Code") then
                exit(ItemCategory.VendorApprovalRequired); // P8007749
    end;

    procedure VendorApproved(VendorNo: Code[20]): Boolean
    var
        ItemVendor: Record "Item Vendor";
    begin
        // P8001230
        if "Vendor No." = '' then
            exit(true);

        ItemVendor.SetRange("Vendor No.", VendorNo);
        ItemVendor.SetRange("Item No.", "No.");
        ItemVendor.SetRange("Variant Code", '');
        ItemVendor.SetRange(Approved, true);
        exit(not ItemVendor.IsEmpty);
    end;

    procedure CheckApprovedVendor()
    begin
        // P8001230
        if not VendorApproved("Vendor No.") then
            Error(Text37002012, TableCaption, "No.", Vend.TableCaption, "Vendor No.");
    end;

    procedure CheckSKUApprovedVendor()
    var
        SKU: Record "Stockkeeping Unit";
    begin
        // P8001230
        SKU.SetRange("Item No.", "No.");
        SKU.SetFilter("Vendor No.", '<>%1', '');
        if SKU.FindSet then
            repeat
                SKU.CheckApprovedVendor;
            until SKU.Next = 0;
    end;

    procedure CheckDocumentApprovedVendor()
    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
    begin
        // P8001230
        PurchLine.SetFilter("Document Type", '%1|%2|%3', PurchLine."Document Type"::Order,
          PurchLine."Document Type"::Invoice, PurchLine."Document Type"::"Blanket Order");
        PurchLine.SetRange(Type, PurchLine.Type::Item);
        PurchLine.SetRange("No.", "No.");
        if PurchLine.FindSet then
            repeat
                PurchHeader.Get(PurchLine."Document Type", PurchLine."Document No.");
                if (PurchHeader.Status <> PurchHeader.Status::Released) and (not PurchHeader."Allow Unapproved Items") then begin
                    if not VendorApproved(PurchLine."Buy-from Vendor No.") then
                        Error(Text37002013, "No.", PurchLine."Document Type", PurchLine."Document No.");
                end;
            until PurchLine.Next = 0;
    end;

    local procedure CheckContainerTypes(CurrFieldCaption: Text)
    var
        ContainerType: Record "Container Type";
    begin
        // P8001305
        ContainerType.SetRange("Container Item No.", "No.");
        if not ContainerType.IsEmpty then begin
            if CurrFieldCaption = '' then
                Error(Text37002016, TableCaption, "No.");
            Error(CannotChangeFieldErr, CurrFieldCaption, TableCaption, "No.", ContainerType.TableCaption);
        end;
    end;

    procedure ShowAllergens()
    var
        AllergenManagement: Codeunit "Allergen Management";
    begin
        // P8006959
        if AllergenManagement.IsProducedItem(Rec) then
            AllergenManagement.ShowAllergenSet(Rec)
        else
            "Direct Allergen Set ID" := AllergenManagement.ShowAllergenSet(Rec);
    end;

    procedure GetItemNo(ItemText: Text): Code[20]
    var
        ItemNo: Text[50];
    begin
        TryGetItemNo(ItemNo, ItemText, true);
        exit(CopyStr(ItemNo, 1, MaxStrLen("No.")));
    end;

    local procedure AsPriceAsset(var PriceAsset: Record "Price Asset")
    begin
        PriceAsset.Init();
        PriceAsset."Asset Type" := PriceAsset."Asset Type"::Item;
        PriceAsset."Asset No." := "No.";
    end;

    procedure ShowPriceListLines(PriceType: Enum "Price Type"; AmountType: Enum "Price Amount Type")
    var
        PriceAsset: Record "Price Asset";
        PriceUXManagement: Codeunit "Price UX Management";
    begin
        AsPriceAsset(PriceAsset);
        PriceUXManagement.ShowPriceListLines(PriceAsset, PriceType, AmountType);
    end;

    procedure TryGetItemNo(var ReturnValue: Text[50]; ItemText: Text; DefaultCreate: Boolean): Boolean
    begin
        InvtSetup.Get();
        exit(TryGetItemNoOpenCard(ReturnValue, ItemText, DefaultCreate, true, not InvtSetup."Skip Prompt to Create Item"));
    end;

    procedure TryGetItemNoOpenCard(var ReturnValue: Text; ItemText: Text; DefaultCreate: Boolean; ShowItemCard: Boolean; ShowCreateItemOption: Boolean): Boolean
    var
        ItemView: Record Item;
    begin
        ItemView.SetRange(Blocked, false);
        exit(TryGetItemNoOpenCardWithView(ReturnValue, ItemText, DefaultCreate, ShowItemCard, ShowCreateItemOption, ItemView.GetView));
    end;

    internal procedure TryGetItemNoOpenCardWithView(var ReturnValue: Text; ItemText: Text; DefaultCreate: Boolean; ShowItemCard: Boolean; ShowCreateItemOption: Boolean; View: Text): Boolean
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
        FindRecordMgt: Codeunit "Find Record Management";
        ItemNo: Code[20];
        ItemWithoutQuote: Text;
        ItemFilterContains: Text;
        FoundRecordCount: Integer;
    begin
        ReturnValue := CopyStr(ItemText, 1, MaxStrLen(ReturnValue));
        if ItemText = '' then
            exit(DefaultCreate);

        FoundRecordCount :=
            FindRecordMgt.FindRecordByDescriptionAndView(ReturnValue, SalesLine.Type::Item.AsInteger(), ItemText, View);

        if FoundRecordCount = 1 then
            exit(true);

        ReturnValue := CopyStr(ItemText, 1, MaxStrLen(ReturnValue));
        if FoundRecordCount = 0 then begin
            if not DefaultCreate then
                exit(false);

            if not GuiAllowed then
                Error(SelectItemErr);

            if Item.WritePermission then
                if ShowCreateItemOption then
                    case StrMenu(
                           StrSubstNo('%1,%2', StrSubstNo(CreateNewItemTxt, ConvertStr(ItemText, ',', '.')), SelectItemTxt), 1, ItemNotRegisteredTxt)
                    of
                        0:
                            Error('');
                        1:
                            begin
                                ReturnValue := CreateNewItem(CopyStr(ItemText, 1, MaxStrLen(Item.Description)), ShowItemCard);
                                exit(true);
                            end;
                    end
                else
                    exit(false);
        end;

        if not GuiAllowed then
            Error(SelectItemErr);

        if FoundRecordCount > 0 then begin
            ItemWithoutQuote := ConvertStr(ItemText, '''', '?');
            ItemFilterContains := '''@*' + ItemWithoutQuote + '*''';
            Item.FilterGroup(-1);
            Item.SetFilter("No.", ItemFilterContains);
            Item.SetFilter(Description, ItemFilterContains);
            Item.SetFilter("Base Unit of Measure", ItemFilterContains);
            OnTryGetItemNoOpenCardOnAfterSetItemFilters(Item, ItemFilterContains);
        end;

        if ShowItemCard then
            ItemNo := PickItem(Item)
        else begin
            ReturnValue := '';
            exit(true);
        end;

        if ItemNo <> '' then begin
            ReturnValue := ItemNo;
            exit(true);
        end;

        if not DefaultCreate then
            exit(false);
        Error('');
    end;

    local procedure CreateNewItem(ItemName: Text[100]; ShowItemCard: Boolean): Code[20]
    var
        Item: Record Item;
        ItemTemplMgt: Codeunit "Item Templ. Mgt.";
        ItemCard: Page "Item Card";
    begin
        OnBeforeCreateNewItem(Item, ItemName);
        if not ItemTemplMgt.InsertItemFromTemplate(Item) then
            Error(SelectItemErr);

        Item.Description := ItemName;
        Item.Modify(true);
        Commit();
        if not ShowItemCard then
            exit(Item."No.");
        Item.SetRange("No.", Item."No.");
        ItemCard.SetTableView(Item);
        if not (ItemCard.RunModal = ACTION::OK) then
            Error(SelectItemErr);

        exit(Item."No.");
    end;

    local procedure CreateItemUnitOfMeasure()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateItemUnitOfMeasure(Rec, ItemUnitOfMeasure, IsHandled);
        if IsHandled then
            exit;

        ItemUnitOfMeasure.Init();
        if IsTemporary then
            ItemUnitOfMeasure."Item No." := "No."
        else
            ItemUnitOfMeasure.Validate("Item No.", "No.");
        ItemUnitOfMeasure.Validate(Code, "Base Unit of Measure");
        ItemUnitOfMeasure."Qty. per Unit of Measure" := 1;
        ItemUnitOfMeasure.Insert();
    end;

    procedure PickItem(var Item: Record Item): Code[20]
    var
        ItemList: Page "Item List";
    begin
        if Item.FilterGroup = -1 then
            ItemList.SetTempFilteredItemRec(Item);

        if Item.FindFirst then;
        ItemList.SetTableView(Item);
        ItemList.SetRecord(Item);
        ItemList.LookupMode := true;
        if ItemList.RunModal = ACTION::LookupOK then
            ItemList.GetRecord(Item)
        else
            Clear(Item);

        exit(Item."No.");
    end;

    procedure SetLastDateTimeModified()
    begin
        "Last DateTime Modified" := CurrentDateTime;
        "Last Date Modified" := DT2Date("Last DateTime Modified");
        "Last Time Modified" := DT2Time("Last DateTime Modified");
    end;

    procedure SetLastDateTimeFilter(DateFilter: DateTime)
    var
        DotNet_DateTimeOffset: Codeunit DotNet_DateTimeOffset;
        SyncDateTimeUtc: DateTime;
        CurrentFilterGroup: Integer;
    begin
        SyncDateTimeUtc := DotNet_DateTimeOffset.ConvertToUtcDateTime(DateFilter);
        CurrentFilterGroup := FilterGroup;
        SetFilter("Last Date Modified", '>=%1', DT2Date(SyncDateTimeUtc));
        FilterGroup(-1);
        SetFilter("Last Date Modified", '>%1', DT2Date(SyncDateTimeUtc));
        SetFilter("Last Time Modified", '>%1', DT2Time(SyncDateTimeUtc));
        FilterGroup(CurrentFilterGroup);
    end;

    procedure ConvertItemCatFilterToItemCatOrderFilter()
    var
        ItemCategory: Record "Item Category";
        Process800CoreFunctions: Codeunit "Process 800 Core Functions";
    begin
        // P8007749
        CopyFilter("Item Category Code", ItemCategory.Code);
        SetRange("Item Category Code");
        SetFilter("Item Category Order", Process800CoreFunctions.GetItemCategoryPresentationRangeFilter(ItemCategory)); // P80066030
    end;

    procedure UpdateReplenishmentSystem(): Boolean
    begin
        CalcFields("Assembly BOM");

        if "Assembly BOM" then begin
            if not ("Replenishment System" in ["Replenishment System"::Assembly, "Replenishment System"::"Prod. Order"])
            then begin
                Validate("Replenishment System", "Replenishment System"::Assembly);
                exit(true);
            end
        end else
            if "Replenishment System" = "Replenishment System"::Assembly then begin
                if "Assembly Policy" <> "Assembly Policy"::"Assemble-to-Order" then begin
                    Validate("Replenishment System", "Replenishment System"::Purchase);
                    exit(true);
                end
            end
    end;

    procedure UpdateUnitOfMeasureId()
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        if "Base Unit of Measure" = '' then begin
            Clear("Unit of Measure Id");
            exit;
        end;

        if not UnitOfMeasure.Get("Base Unit of Measure") then
            exit;

        "Unit of Measure Id" := UnitOfMeasure.SystemId;
    end;

    local procedure UpdateQtyRoundingPrecisionForBaseUoM()
    var
        BaseItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        // P800133109
        if BaseItemUnitOfMeasure.Get("No.", Rec."Base Unit of Measure") then begin
            BaseItemUnitOfMeasure.Validate("Qty. Rounding Precision", BaseItemUnitOfMeasure."Rounding Precision");
            BaseItemUnitOfMeasure.Modify(true);
        end;
        // P800133109
        // Reset Rounding Percision in old Base UOM
        if BaseItemUnitOfMeasure.Get("No.", xRec."Base Unit of Measure") then begin
            BaseItemUnitOfMeasure.Validate("Qty. Rounding Precision", 0);
            BaseItemUnitOfMeasure.Modify(true);
        end;
    end;

    procedure UpdateItemCategoryId()
    var
        ItemCategory: Record "Item Category";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        if IsTemporary then
            exit;

        if not GraphMgtGeneralTools.IsApiEnabled then
            exit;

        if "Item Category Code" = '' then begin
            Clear("Item Category Id");
            exit;
        end;

        if not ItemCategory.Get("Item Category Code") then
            exit;

        "Item Category Id" := ItemCategory.SystemId;
    end;

    procedure UpdateTaxGroupId()
    var
        TaxGroup: Record "Tax Group";
    begin
        if "Tax Group Code" = '' then begin
            Clear("Tax Group Id");
            exit;
        end;

        if not TaxGroup.Get("Tax Group Code") then
            exit;

        "Tax Group Id" := TaxGroup.SystemId;
    end;

    local procedure UpdateUnitOfMeasureCode()
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        if not IsNullGuid("Unit of Measure Id") then
            UnitOfMeasure.GetBySystemId("Unit of Measure Id");

        "Base Unit of Measure" := UnitOfMeasure.Code;
    end;

    local procedure UpdateTaxGroupCode()
    var
        TaxGroup: Record "Tax Group";
    begin
        if not IsNullGuid("Tax Group Id") then
            TaxGroup.GetBySystemId("Tax Group Id");

        Validate("Tax Group Code", TaxGroup.Code);
    end;

    local procedure UpdateItemCategoryCode()
    var
        ItemCategory: Record "Item Category";
    begin
        if IsNullGuid("Item Category Id") then
            ItemCategory.GetBySystemId("Item Category Id");

        "Item Category Code" := ItemCategory.Code;
    end;

    procedure UpdateReferencedIds()
    var
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        if IsTemporary then
            exit;

        if not GraphMgtGeneralTools.IsApiEnabled() then
            exit;

        UpdateUnitOfMeasureId();
        UpdateTaxGroupId();
        UpdateItemCategoryId();
    end;

    procedure GetReferencedIds(var TempField: Record "Field" temporary)
    var
        DataTypeManagement: Codeunit "Data Type Management";
    begin
        DataTypeManagement.InsertFieldToBuffer(TempField, DATABASE::Item, FieldNo("Unit of Measure Id"));
        DataTypeManagement.InsertFieldToBuffer(TempField, DATABASE::Item, FieldNo("Tax Group Id"));
        DataTypeManagement.InsertFieldToBuffer(TempField, DATABASE::Item, FieldNo("Item Category Id"));
    end;

    procedure IsServiceType(): Boolean
    begin
        exit(Type = Type::Service);
    end;

    procedure IsNonInventoriableType(): Boolean
    begin
        exit(Type in [Type::"Non-Inventory", Type::Service]);
    end;

    procedure IsInventoriableType(): Boolean
    begin
        exit(not IsNonInventoriableType);
    end;

    local procedure UpdateItemUnitGroup()
    var
        UnitGroup: Record "Unit Group";
        Modified: Boolean;
    begin
        if UnitGroup.Get(UnitGroup."Source Type"::Item, Rec.SystemId) then begin
            if UnitGroup."Code" <> ItemUnitGroupPrefixLbl + ' ' + Rec."No." + ' ' + 'UOM GR' then begin
                UnitGroup."Code" := ItemUnitGroupPrefixLbl + ' ' + Rec."No." + ' ' + 'UOM GR';
                Modified := true;
            end;
            if UnitGroup."Source Name" <> Rec.Description then begin
                UnitGroup."Source Name" := Rec.Description;
                Modified := true;
            end;
            if Modified then
                UnitGroup.Modify();
            exit;
        end else begin
            UnitGroup.Init();
            UnitGroup."Source Id" := Rec.SystemId;
            UnitGroup."Source No." := Rec."No.";
            UnitGroup."Code" := ItemUnitGroupPrefixLbl + ' ' + Rec."No." + ' ' + 'UOM GR';
            UnitGroup."Source Name" := Rec.Description;
            UnitGroup."Source Type" := UnitGroup."Source Type"::Item;
            UnitGroup.Insert();
        end;
    end;

    local procedure DeleteItemUnitGroup()
    var
        UnitGroup: Record "Unit Group";
    begin
        if UnitGroup.Get(UnitGroup."Source Type"::Item, Rec.SystemId) then
            UnitGroup.Delete();
    end;

    procedure IsContainerType(): Boolean
    begin
        // P80066030
        exit(Type = Type::Service);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckDocuments(var Item: Record Item; var xItem: Record Item; var CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDeleteRelatedData(Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIsMfgItem(Item: Record Item; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateShortcutDimCode(var Item: Record Item; xItem: Record Item; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAssistEdit(var Item: Record Item; var xItem: Record Item; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckSNSpecificTrackingInteger(var Item: Record Item; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckUpdateFieldsForNonInventoriableItem(var Item: Record Item; xItem: Record Item; CallingFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateItemUnitOfMeasure(var Item: Record Item; var ItemUnitOfMeasure: Record "Item Unit of Measure"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateNewItem(var Item: Record Item; var ItemName: Text[100])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnDelete(var Item: Record Item; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnInsert(var Item: Record Item; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestNoItemLedgEntiesExist(Item: Record Item; CurrentFieldName: Text[100]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestNoPurchLinesExist(Item: Record Item; CurrentFieldName: Text[100]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestNoWhseEntriesExist(Item: Record Item; CurrentFieldName: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateShortcutDimCode(var Item: Record Item; xItem: Record Item; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateStandardCost(var Item: Record Item; xItem: Record Item; CallingFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateBaseUnitOfMeasure(var Item: Record Item; xItem: Record Item; CallingFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateReplenishmentSystemCaseElse(var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateReplenishmentSystemCaseTransfer(var Item: Record Item; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindItemVendOnAfterSetFilters(var ItemVend: Record "Item Vendor"; Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnTryGetItemNoOpenCardOnAfterSetItemFilters(var Item: Record Item; var ItemFilterContains: Text)
    begin
    end;

    procedure ExistsItemLedgerEntry(): Boolean
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        ItemLedgEntry.Reset();
        ItemLedgEntry.SetCurrentKey("Item No.");
        ItemLedgEntry.SetRange("Item No.", "No.");
        exit(not ItemLedgEntry.IsEmpty);
    end;

    procedure ItemTrackingCodeUseExpirationDates(): Boolean
    begin
        if "Item Tracking Code" = '' then
            exit(false);

        ItemTrackingCode.Get("Item Tracking Code");
        exit(ItemTrackingCode."Use Expiration Dates");
    end;

    [Obsolete('Replaced by ItemTrackingCodeUseExpirationDates()', '17.0')]
    [Scope('OnPrem')]
    procedure ItemTrackingCodeUsesExpirationDate(): Boolean
    begin
        exit(ItemTrackingCodeUseExpirationDates());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidatePhysInvtCountingPeriodCodeOnBeforeConfirmUpdate(var Item: Record Item; xItem: Record Item; PhysInvtCountPeriod: Record "Phys. Invt. Counting Period"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetItemUOMRndgPrecision(var Sender: Record Item; UOM: Code[10]; UseDefaultPrecision: Boolean; var RndgPrecisionSet: Boolean; var Handled: Boolean)
    begin
        // P80079197
    end;

    procedure CheckQualityAllowed(ItemNo: Code[20]): Boolean
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        // P800144674
        Rec.Get(ItemNo);
        if Rec."Item Tracking Code" <> '' then begin
            if ItemTrackingCode.Get(Rec."Item Tracking Code") then
                if ItemTrackingCode."Lot Specific Tracking" then
                    exit(true)
                else
                    exit(false)
        end else
            exit(false);
    end;    
}

