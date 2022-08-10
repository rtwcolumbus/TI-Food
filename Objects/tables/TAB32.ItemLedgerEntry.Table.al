table 32 "Item Ledger Entry"
{
    // PR3.60
    //   New Fields
    //     Quantity (Alt.)
    //     Remaining Quantity (Alt.)
    //     Invoiced Quantity (Alt.)
    //   Add SumIndex fields to existing keys for alternate quantities
    // 
    // PR3.61.01
    //   Add Field
    //     Writeoff Responsibility
    //   Add Key
    //     Item No.,Variant Code,Location Code,Lot No.,Serial No.
    // 
    // PR3.70.01
    //   Add Key
    //     Posting Date,Item No.,Location Code
    //     Item No.,Entry Type,Prod. Order No.,Location Code,Posting Date
    // 
    // PR3.70.06
    // P8000069A, Myers Nissi, Jack Reynolds, 19 JUL 04
    //   Add key - Item No.,Variant Code,Drop Shipment,Location Code,Lot No.,Serial No.
    // 
    // P8000078A, Myers Nissi, Steve Post, 26 JUL 04
    //   Added Field
    //       37002460 Exclude from Sales Forecast
    //     Added Keys
    //       Exclude from Sales Forecast,Item No.,Entry Type,Posting Date            Invoiced Quantity
    //       Exclude from Sales Forecast,Entry Type,Posting Date,Item No.,Variant Code,Location Code,
    //         Source Type,Source No.
    //       Entry Type,Posting Date,Item No.,Variant Code,Location Code,Source Type,Source No.
    // 
    // PR3.70.10
    // P8000232A, Myers Nissi, Phyllis McGovern, 20 JUL 05
    //   Added Key:Item Category Code, Item No., Entry Type
    // 
    // P8000233A, Myers Nissi, Phyllis McGovern, 21 JUL 05
    //   Added Field:
    //     Delivery Route No.(37002060, Code(20))
    //   Added Key:
    //     Delivery Route No.,Source Type,Source No.,Item No.,Variant Code,Posting Date
    // 
    // PR4.00
    // P8000248B, Myers Nissi, Jack Reynolds, 07 OCT 05
    //   SalesQuantity - returns quantity sold in selling units
    //   SalesUnitPrice - returns unit price of sales adjusted for alternate quantity and selling units
    // 
    // P8000257A, Myers Nissi, Jack Reynolds, 24 OCT 05
    //   Add and modify keys to support inventory valuation report by lot
    // 
    // PR4.00.01
    // P8000267B, VerticalSoft, Jack Reynolds, 12 DEC 05
    //   Key changes to keep in line with SP1
    // 
    // PR4.00.02
    // P8000297A, VerticalSoft, Jack Reynolds, 15 FEB 06
    //   Missing SumIndexField when running sales order guide
    // 
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 30 AUG 06
    //   Add field Maint. Ledger Entry No.
    // 
    // P8000322A, VerticalSoft, Don Bresee, 20 SEP 06
    //   Add keys for Lot Warehouse Picking Method
    // 
    // PR4.00.06
    // P8000480A, VerticalSoft, Jack Reynolds, 31 MAY 07
    //   Update SumIndex fields on key
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 31 JUL 07
    //   Shipped Qty. Not Ret. (Alt.)
    //   Added helper function - CostInAlternateUnits
    //   Added helper function - OpenItemTracing
    // 
    // PRW15.00.01
    // P8000581A, VerticalSoft, Jack Reynolds, 20 FEB 08
    //   Remove "Exclude From Sales Forecast"
    // 
    // P8000548A, VerticalSoft, Don Bresee, 05 MAR 08
    //   Add new field - Rounding Adjustment Type
    // 
    // P8000552A, VerticalSoft, Don Bresee, 12 DEC 07
    //   Add Reserved Quantity (Alt.)
    // 
    // PRW16.00.04
    // P8000856, VerticalSoft, Don Bresee, 24 AUG 10
    //   Add Commodity Class Costing granule
    // 
    // PRW16.00.05
    // P8000921, Columbus IT, Don Bresee, 07 APR 11
    //   Add "Sales Amount (FOB)" and "Sales Amount (Freight)" fields
    //   Add SalesUnitPriceFreight function (used by SalesHistory function in Sales Line)
    // 
    // P8000931, Columbus IT, Jack Reynolds, 20 APR 11
    //   Support for Supply Chain Groups
    // 
    // P8000981, Columbus IT, Don Bresee, 20 SEP 11
    //   Add "PriceInAlternateUnits" and "GetPricingQty" routines
    // 
    // P8000979, Columbus IT, Jack Reynolds, 06 OCT 11
    //   Function to run lot tracing
    // 
    // P8000984, Columbus IT, Don Bresee, 18 OCT 11
    //   Add Multiple Lot Trace
    // 
    // PRW16.00.06
    // P8001017, Columbus IT, Jack Reynolds, 10 JAN 12
    //   Record timestamp of item ledger entry record creation
    // 
    // P8001019, Columbus IT, Jack Reynolds, 16 JAN 12
    //   Account Schedule - Item Units
    // 
    // P8001041, Columbus IT, Jack Reynolds, 09 MAR 12
    //   Additional SumIndexField for calculating Remaining Quantity (Alt.)
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Add field for Repack
    // 
    // PRW17.00
    // P8001134, Columbus IT, Don Bresee, 16 FEB 13
    //   Add new options to "Order Type"
    // 
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.10
    // P8001213, Columbus IT, Jack Reynolds, 26 SEP 13
    //   NAV 2013 R2 changes
    // 
    // P8001231, Columbus IT, Jack Reynolds, 22 OCT 13
    //   Add support for Shift Code
    // 
    // PRW17.10.01
    // P8001258, Columbus IT, Jack Reynolds, 10 JAN 14
    //   Increase size ot text fields/variables
    // 
    // PRW17.10.02
    // P8001302, Columbus IT, Jack Reynolds, 05 MAR 14
    //   Combine CalculateRemQuantity and CalculateRemAltQuantity
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW110.0.01
    // P8008735, To-Increase, Jack Reynolds, 03 MAT 17
    //   Fix problem with CalculateRemQuantity
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    //
    // PRW119.03
    // P800122712, To Increase, Gangabhushan, 25 MAY 22
    //   Quality Control Samples, new fields added

    Caption = 'Item Ledger Entry';
    DrillDownPageID = "Item Ledger Entries";
    LookupPageID = "Item Ledger Entries";
    Permissions = TableData "Item Ledger Entry" = rimd;

    fields
    {
        field(37002000; "Writeoff Responsibility"; Option)
        {
            Caption = 'Writeoff Responsibility';
            Description = 'PR3.61.01';
            OptionCaption = ' ,Company,Vendor';
            OptionMembers = " ",Company,Vendor;
        }
        field(37002001; "Posting Date/Time"; DateTime)
        {
            Caption = 'Posting Date/Time';
        }
        field(37002002; "Rounding Adjustment Type"; Option)
        {
            Caption = 'Rounding Adjustment Type';
            Description = 'P8000548A';
            OptionCaption = ' ,Near-Zero,Fixed Alt. Qty.';
            OptionMembers = " ","Near-Zero","Fixed Alt. Qty.";
        }
        field(37002015; "Supply Chain Group Code"; Code[10])
        {
            Caption = 'Supply Chain Group Code';
            TableRelation = "Supply Chain Group";
        }
        field(37002021; "Release Date"; Date)
        {
            Caption = 'Release Date';
            Description = 'PR3.60';
            Editable = false;
        }
        field(37002049; "Sales Amount (FOB)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Value Entry"."Sales Amount (FOB)" WHERE("Item Ledger Entry No." = FIELD("Entry No.")));
            Caption = 'Sales Amount (FOB)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002050; "Sales Amount (Freight)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Value Entry"."Sales Amount (Freight)" WHERE("Item Ledger Entry No." = FIELD("Entry No.")));
            Caption = 'Sales Amount (Freight)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002060; "Delivery Route No."; Code[20])
        {
            Caption = 'Delivery Route No.';
            TableRelation = "Delivery Route";
        }
        field(37002081; "Quantity (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            CaptionClass = StrSubstNo('37002080,0,0,%1', "Item No.");
            Caption = 'Quantity (Alt.)';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.60';
        }
        field(37002082; "Remaining Quantity (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            CaptionClass = StrSubstNo('37002080,0,7,%1', "Item No.");
            Caption = 'Remaining Quantity (Alt.)';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.60';
        }
        field(37002083; "Invoiced Quantity (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            CaptionClass = StrSubstNo('37002080,0,6,%1', "Item No.");
            Caption = 'Invoiced Quantity (Alt.)';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.60';
        }
        field(37002084; "Shipped Qty. Not Ret. (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            CaptionClass = StrSubstNo('37002080,0,16,%1', "Item No.");
            Caption = 'Shipped Qty. Not Ret. (Alt.)';
            DecimalPlaces = 0 : 5;
        }
        field(37002085; "Reserved Quantity (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            CalcFormula = Sum("Reservation Entry"."Quantity (Alt.)" WHERE("Source ID" = CONST(''),
                                                                           "Source Ref. No." = FIELD("Entry No."),
                                                                           "Source Type" = CONST(32),
                                                                           "Source Subtype" = CONST("0"),
                                                                           "Source Batch Name" = CONST(''),
                                                                           "Source Prod. Order Line" = CONST(0),
                                                                           "Reservation Status" = CONST(Reservation)));
            Caption = 'Reserved Quantity (Alt.)';
            DecimalPlaces = 0 : 5;
            Description = 'P8000552A';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002460; "Work Shift Code"; Code[10])
        {
            Caption = 'Work Shift Code';
            TableRelation = "Work Shift";
        }
        field(37002680; "Commodity Class Code"; Code[10])
        {
            Caption = 'Commodity Class Code';
            TableRelation = "Commodity Class";
        }
        field(37002801; "Maint. Ledger Entry No."; Integer)
        {
            Caption = 'Maint. Ledger Entry No.';
            TableRelation = "Maintenance Ledger";
        }
        // P800122712
        field(37002543; "Sample Test Code"; Code[10])
        {
            Caption = 'Sample Test Code';
        }
        field(37002544; "Sample Test No."; Integer)
        {
            Caption = 'Sample Test No.';
        }
        // P800122712
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(3; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(4; "Entry Type"; Enum "Item Ledger Entry Type")
        {
            Caption = 'Entry Type';
        }
        field(5; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            TableRelation = IF ("Source Type" = CONST(Customer)) Customer
            ELSE
            IF ("Source Type" = CONST(Vendor)) Vendor
            ELSE
            IF ("Source Type" = CONST(Item)) Item;
        }
        field(6; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(7; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(8; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(12; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(13; "Remaining Quantity"; Decimal)
        {
            Caption = 'Remaining Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(14; "Invoiced Quantity"; Decimal)
        {
            Caption = 'Invoiced Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(28; "Applies-to Entry"; Integer)
        {
            Caption = 'Applies-to Entry';
        }
        field(29; Open; Boolean)
        {
            Caption = 'Open';
        }
        field(33; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(34; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(36; Positive; Boolean)
        {
            Caption = 'Positive';
        }
        field(40; "Shpt. Method Code"; Code[10])
        {
            Caption = 'Shpt. Method Code';
            TableRelation = "Shipment Method";
        }
        field(41; "Source Type"; Enum "Analysis Source Type")
        {
            Caption = 'Source Type';
        }
        field(47; "Drop Shipment"; Boolean)
        {
            AccessByPermission = TableData "Drop Shpt. Post. Buffer" = R;
            Caption = 'Drop Shipment';
        }
        field(50; "Transaction Type"; Code[10])
        {
            Caption = 'Transaction Type';
            TableRelation = "Transaction Type";
        }
        field(51; "Transport Method"; Code[10])
        {
            Caption = 'Transport Method';
            TableRelation = "Transport Method";
        }
        field(52; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(59; "Entry/Exit Point"; Code[10])
        {
            Caption = 'Entry/Exit Point';
            TableRelation = "Entry/Exit Point";
        }
        field(60; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(61; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(62; "Area"; Code[10])
        {
            Caption = 'Area';
            TableRelation = Area;
        }
        field(63; "Transaction Specification"; Code[10])
        {
            Caption = 'Transaction Specification';
            TableRelation = "Transaction Specification";
        }
        field(64; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(70; "Reserved Quantity"; Decimal)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            CalcFormula = Sum("Reservation Entry"."Quantity (Base)" WHERE("Source ID" = CONST(''),
                                                                           "Source Ref. No." = FIELD("Entry No."),
                                                                           "Source Type" = CONST(32),
                                                                           "Source Subtype" = CONST("0"),
                                                                           "Source Batch Name" = CONST(''),
                                                                           "Source Prod. Order Line" = CONST(0),
                                                                           "Reservation Status" = CONST(Reservation)));
            Caption = 'Reserved Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(79; "Document Type"; Enum "Item Ledger Document Type")
        {
            Caption = 'Document Type';
        }
        field(80; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
        }
        field(90; "Order Type"; Enum "Inventory Order Type")
        {
            Caption = 'Order Type';
            Editable = false;
        }
        field(91; "Order No."; Code[20])
        {
            Caption = 'Order No.';
            Editable = false;
        }
        field(92; "Order Line No."; Integer)
        {
            Caption = 'Order Line No.';
            Editable = false;
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
        }
        field(481; "Shortcut Dimension 3 Code"; Code[20])
        {
            CaptionClass = '1,2,3';
            Caption = 'Shortcut Dimension 3 Code';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"),
                                                                                    "Global Dimension No." = const(3)));
        }
        field(482; "Shortcut Dimension 4 Code"; Code[20])
        {
            CaptionClass = '1,2,4';
            Caption = 'Shortcut Dimension 4 Code';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"),
                                                                                    "Global Dimension No." = const(4)));
        }
        field(483; "Shortcut Dimension 5 Code"; Code[20])
        {
            CaptionClass = '1,2,5';
            Caption = 'Shortcut Dimension 5 Code';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"),
                                                                                    "Global Dimension No." = const(5)));
        }
        field(484; "Shortcut Dimension 6 Code"; Code[20])
        {
            CaptionClass = '1,2,6';
            Caption = 'Shortcut Dimension 6 Code';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"),
                                                                                    "Global Dimension No." = const(6)));
        }
        field(485; "Shortcut Dimension 7 Code"; Code[20])
        {
            CaptionClass = '1,2,7';
            Caption = 'Shortcut Dimension 7 Code';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"),
                                                                                    "Global Dimension No." = const(7)));
        }
        field(486; "Shortcut Dimension 8 Code"; Code[20])
        {
            CaptionClass = '1,2,8';
            Caption = 'Shortcut Dimension 8 Code';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"),
                                                                                    "Global Dimension No." = const(8)));
        }
        field(904; "Assemble to Order"; Boolean)
        {
            AccessByPermission = TableData "BOM Component" = R;
            Caption = 'Assemble to Order';
        }
        field(1000; "Job No."; Code[20])
        {
            Caption = 'Job No.';
            TableRelation = Job."No.";
        }
        field(1001; "Job Task No."; Code[20])
        {
            Caption = 'Job Task No.';
            TableRelation = "Job Task"."Job Task No." WHERE("Job No." = FIELD("Job No."));
        }
        field(1002; "Job Purchase"; Boolean)
        {
            Caption = 'Job Purchase';
        }
        field(5402; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(5404; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
        }
        field(5407; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(5408; "Derived from Blanket Order"; Boolean)
        {
            Caption = 'Derived from Blanket Order';
        }
        field(5700; "Cross-Reference No."; Code[20])
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
        field(5701; "Originally Ordered No."; Code[20])
        {
            AccessByPermission = TableData "Item Substitution" = R;
            Caption = 'Originally Ordered No.';
            TableRelation = Item;
        }
        field(5702; "Originally Ordered Var. Code"; Code[10])
        {
            AccessByPermission = TableData "Item Substitution" = R;
            Caption = 'Originally Ordered Var. Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Originally Ordered No."));
        }
        field(5703; "Out-of-Stock Substitution"; Boolean)
        {
            Caption = 'Out-of-Stock Substitution';
        }
        field(5704; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            TableRelation = "Item Category";
        }
        field(5705; Nonstock; Boolean)
        {
            Caption = 'Catalog';
        }
        field(5706; "Purchasing Code"; Code[10])
        {
            Caption = 'Purchasing Code';
            TableRelation = Purchasing;
        }
        field(5707; "Product Group Code"; Code[10])
        {
            Caption = 'Product Group Code';
            ObsoleteReason = 'Product Groups became first level children of Item Categories.';
            ObsoleteState = Removed;
            ObsoleteTag = '15.0';
        }
        field(5725; "Item Reference No."; Code[50])
        {
            Caption = 'Item Reference No.';
        }
        field(5800; "Completely Invoiced"; Boolean)
        {
            Caption = 'Completely Invoiced';
        }
        field(5801; "Last Invoice Date"; Date)
        {
            Caption = 'Last Invoice Date';
        }
        field(5802; "Applied Entry to Adjust"; Boolean)
        {
            Caption = 'Applied Entry to Adjust';
        }
        field(5803; "Cost Amount (Expected)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Value Entry"."Cost Amount (Expected)" WHERE("Item Ledger Entry No." = FIELD("Entry No.")));
            Caption = 'Cost Amount (Expected)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5804; "Cost Amount (Actual)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Value Entry"."Cost Amount (Actual)" WHERE("Item Ledger Entry No." = FIELD("Entry No.")));
            Caption = 'Cost Amount (Actual)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5805; "Cost Amount (Non-Invtbl.)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Value Entry"."Cost Amount (Non-Invtbl.)" WHERE("Item Ledger Entry No." = FIELD("Entry No.")));
            Caption = 'Cost Amount (Non-Invtbl.)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5806; "Cost Amount (Expected) (ACY)"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            CalcFormula = Sum("Value Entry"."Cost Amount (Expected) (ACY)" WHERE("Item Ledger Entry No." = FIELD("Entry No.")));
            Caption = 'Cost Amount (Expected) (ACY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5807; "Cost Amount (Actual) (ACY)"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            CalcFormula = Sum("Value Entry"."Cost Amount (Actual) (ACY)" WHERE("Item Ledger Entry No." = FIELD("Entry No.")));
            Caption = 'Cost Amount (Actual) (ACY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5808; "Cost Amount (Non-Invtbl.)(ACY)"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            CalcFormula = Sum("Value Entry"."Cost Amount (Non-Invtbl.)(ACY)" WHERE("Item Ledger Entry No." = FIELD("Entry No.")));
            Caption = 'Cost Amount (Non-Invtbl.)(ACY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5813; "Purchase Amount (Expected)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Value Entry"."Purchase Amount (Expected)" WHERE("Item Ledger Entry No." = FIELD("Entry No.")));
            Caption = 'Purchase Amount (Expected)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5814; "Purchase Amount (Actual)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Value Entry"."Purchase Amount (Actual)" WHERE("Item Ledger Entry No." = FIELD("Entry No.")));
            Caption = 'Purchase Amount (Actual)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5815; "Sales Amount (Expected)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Value Entry"."Sales Amount (Expected)" WHERE("Item Ledger Entry No." = FIELD("Entry No.")));
            Caption = 'Sales Amount (Expected)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5816; "Sales Amount (Actual)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Value Entry"."Sales Amount (Actual)" WHERE("Item Ledger Entry No." = FIELD("Entry No.")));
            Caption = 'Sales Amount (Actual)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5817; Correction; Boolean)
        {
            Caption = 'Correction';
        }
        field(5818; "Shipped Qty. Not Returned"; Decimal)
        {
            AccessByPermission = TableData "Sales Header" = R;
            Caption = 'Shipped Qty. Not Returned';
            DecimalPlaces = 0 : 5;
        }
        field(5833; "Prod. Order Comp. Line No."; Integer)
        {
            AccessByPermission = TableData "Production Order" = R;
            Caption = 'Prod. Order Comp. Line No.';
        }
        field(6500; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';

            trigger OnLookup()
            begin
                ItemTrackingMgt.LookupTrackingNoInfo("Item No.", "Variant Code", ItemTrackingType::"Serial No.", "Serial No.");
            end;
        }
        field(6501; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';

            trigger OnLookup()
            begin
                ItemTrackingMgt.LookupTrackingNoInfo("Item No.", "Variant Code", ItemTrackingType::"Lot No.", "Lot No.");
            end;
        }
        field(6502; "Warranty Date"; Date)
        {
            Caption = 'Warranty Date';
        }
        field(6503; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
        }
        field(6510; "Item Tracking"; Enum "Item Tracking Entry Type")
        {
            Caption = 'Item Tracking';
            Editable = false;
        }
        field(6515; "Package No."; Code[50])
        {
            Caption = 'Package No.';
            CaptionClass = '6,1';

            trigger OnLookup()
            begin
                ItemTrackingMgt.LookupTrackingNoInfo("Item No.", "Variant Code", "Item Tracking Type"::"Package No.", "Package No.");
            end;
        }
        field(6602; "Return Reason Code"; Code[10])
        {
            Caption = 'Return Reason Code';
            TableRelation = "Return Reason";
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Item No.")
        {
            SumIndexFields = "Invoiced Quantity", Quantity;
        }
        key(Key3; "Item No.", "Posting Date")
        {
        }
        key(Key4; "Item No.", "Entry Type", "Variant Code", "Drop Shipment", "Location Code", "Posting Date")
        {
            SumIndexFields = Quantity, "Invoiced Quantity", "Quantity (Alt.)", "Invoiced Quantity (Alt.)";
        }
        key(Key5; "Source Type", "Source No.", "Item No.", "Variant Code", "Posting Date")
        {
            SumIndexFields = Quantity;
        }
        key(Key6; "Item No.", Open, "Variant Code", Positive, "Location Code", "Posting Date")
        {
            SumIndexFields = Quantity, "Remaining Quantity";
        }
#pragma warning disable AS0009
        key(Key7; "Item No.", Open, "Variant Code", Positive, "Location Code", "Posting Date", "Expiration Date", "Lot No.", "Serial No.", "Package No.")
#pragma warning restore AS0009
        {
            Enabled = false;
            SumIndexFields = Quantity, "Remaining Quantity";
        }
        key(Key8; "Country/Region Code", "Entry Type", "Posting Date")
        {
        }
        key(Key9; "Document No.", "Document Type", "Document Line No.")
        {
        }
        key(Key10; "Item No.", "Entry Type", "Variant Code", "Drop Shipment", "Global Dimension 1 Code", "Global Dimension 2 Code", "Location Code", "Posting Date")
        {
            Enabled = false;
            SumIndexFields = Quantity, "Invoiced Quantity", "Quantity (Alt.)", "Invoiced Quantity (Alt.)";
        }
        key(Key11; "Source Type", "Source No.", "Global Dimension 1 Code", "Global Dimension 2 Code", "Item No.", "Variant Code", "Posting Date")
        {
            Enabled = false;
            SumIndexFields = Quantity;
        }
        key(Key12; "Order Type", "Order No.", "Order Line No.", "Entry Type", "Prod. Order Comp. Line No.")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = Quantity, "Quantity (Alt.)";
        }
        key(Key13; "Item No.", "Applied Entry to Adjust")
        {
        }
        key(Key14; "Item No.", Positive, "Location Code", "Variant Code")
        {
        }
        key(Key15; "Entry Type", Nonstock, "Item No.", "Posting Date")
        {
            Enabled = false;
        }
#pragma warning disable AS0009
        key(Key16; "Item No.", "Location Code", Open, "Variant Code", "Unit of Measure Code", "Lot No.", "Serial No.", "Package No.")
#pragma warning restore AS0009
        {
            Enabled = false;
            SumIndexFields = "Remaining Quantity";
        }
#pragma warning disable AS0009
        key(Key17; "Item No.", Open, "Variant Code", Positive, "Lot No.", "Serial No.", "Package No.")
#pragma warning restore AS0009
        {
        }
#pragma warning disable AS0009
        key(Key18; "Item No.", Open, "Variant Code", "Location Code", "Item Tracking", "Lot No.", "Serial No.", "Package No.")
#pragma warning restore AS0009
        {
            Enabled = false;
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Remaining Quantity";
        }
        key(Key19; "Lot No.")
        {
        }
        key(Key20; "Serial No.")
        {
        }
        key(Key23; SystemModifiedAt)
        {
        }
        key(Key37002000; "Entry Type", "Item No.", "Variant Code", "Source Type", "Source No.", "Posting Date")
        {
            SumIndexFields = Quantity, "Invoiced Quantity", "Invoiced Quantity (Alt.)";
        }
        key(Key37002001; "Item No.", "Variant Code", "Location Code", "Posting Date")
        {
        }
        key(Key37002002; "Item No.", "Variant Code", "Global Dimension 1 Code", "Global Dimension 2 Code", "Location Code", "Posting Date")
        {
            Enabled = false;
        }
        key(Key37002003; "Item No.", "Variant Code", "Lot No.", Positive, "Posting Date")
        {
        }
        key(Key37002004; "Item No.", "Variant Code", "Location Code", "Lot No.", "Serial No.", "Posting Date")
        {
            SumIndexFields = Quantity, "Quantity (Alt.)";
        }
        key(Key37002005; "Item No.", "Variant Code", "Drop Shipment", "Location Code", "Lot No.", "Serial No.")
        {
            SumIndexFields = Quantity, "Quantity (Alt.)";
        }
        key(Key37002006; "Posting Date", "Item No.", "Location Code")
        {
            Enabled = false;
            SumIndexFields = Quantity, "Quantity (Alt.)";
        }
        key(Key37002007; "Item No.", "Entry Type", "Order Type", "Order No.", "Location Code", "Posting Date")
        {
            Enabled = false;
            SumIndexFields = Quantity, "Quantity (Alt.)";
        }
        key(Key37002008; "Item Category Code", "Item No.", "Entry Type")
        {
        }
        key(Key37002009; "Delivery Route No.", "Source Type", "Source No.", "Item No.", "Variant Code", "Posting Date")
        {
        }
        key(Key37002010; "Item No.", "Location Code", "Lot No.", "Posting Date")
        {
        }
        key(Key37002011; "Item No.", "Lot No.", "Posting Date")
        {
        }
        key(Key37002012; "Location Code", "Item No.", "Variant Code", Open, Positive, "Expiration Date")
        {
        }
        key(Key37002013; "Location Code", "Item No.", "Variant Code", Open, Positive, "Posting Date")
        {
        }
        key(Key37002014; "Item Category Code", "Entry Type", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code")
        {
            Enabled = false;
            SumIndexFields = Quantity, "Quantity (Alt.)";
        }
        key(Key37002015; "Item No.", Open, "Variant Code", "Location Code", "Lot No.")
        {
            SumIndexFields = "Remaining Quantity", "Remaining Quantity (Alt.)";
        }
        key(Key37002016; "Item No.", "Variant Code", "Lot No.", "Sample Test Code", "Sample Test No.")
        {
            // P800122712
            SumIndexFields = Quantity;
        }
    }

    fieldgroups
    {
    }

    var
        GLSetup: Record "General Ledger Setup";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        ItemTrackingType: Enum "Item Tracking Type";
        GLSetupRead: Boolean;
        UseItemTrackingLinesPageErr: Label 'You must use form %1 to enter %2, if item tracking is used.', Comment = '%1 - page caption, %2 - field caption';
        IsNotOnInventoryErr: Label 'You have insufficient quantity of Item %1 on inventory.';
        Item: Record Item;

    local procedure GetCurrencyCode(): Code[10]
    begin
        if not GLSetupRead then begin
            GLSetup.Get();
            GLSetupRead := true;
        end;
        exit(GLSetup."Additional Reporting Currency");
    end;

    procedure GetLastEntryNo(): Integer;
    var
        FindRecordManagement: Codeunit "Find Record Management";
    begin
        exit(FindRecordManagement.GetLastEntryIntFieldValue(Rec, FieldNo("Entry No.")))
    end;

    procedure ShowReservationEntries(Modal: Boolean)
    var
        ReservEntry: Record "Reservation Entry";
    begin
        ReservEntry.InitSortingAndFilters(true);
        SetReservationFilters(ReservEntry);
        if Modal then
            PAGE.RunModal(PAGE::"Reservation Entries", ReservEntry)
        else
            PAGE.Run(PAGE::"Reservation Entries", ReservEntry);
    end;

    procedure SetAppliedEntryToAdjust(AppliedEntryToAdjust: Boolean)
    begin
        if "Applied Entry to Adjust" <> AppliedEntryToAdjust then begin
            "Applied Entry to Adjust" := AppliedEntryToAdjust;
            Modify;
        end;
    end;

    procedure SetAvgTransCompletelyInvoiced(): Boolean
    var
        ItemApplnEntry: Record "Item Application Entry";
        InbndItemLedgEntry: Record "Item Ledger Entry";
        CompletelyInvoiced: Boolean;
    begin
        if "Entry Type" <> "Entry Type"::Transfer then
            exit(false);

        ItemApplnEntry.SetCurrentKey("Item Ledger Entry No.");
        ItemApplnEntry.SetRange("Item Ledger Entry No.", "Entry No.");
        ItemApplnEntry.Find('-');
        if not "Completely Invoiced" then begin
            CompletelyInvoiced := true;
            repeat
                InbndItemLedgEntry.Get(ItemApplnEntry."Inbound Item Entry No.");
                if not InbndItemLedgEntry."Completely Invoiced" then
                    CompletelyInvoiced := false;
            until ItemApplnEntry.Next() = 0;

            if CompletelyInvoiced then begin
                SetCompletelyInvoiced;
                exit(true);
            end;
        end;
        exit(false);
    end;

    procedure SetCompletelyInvoiced()
    begin
        if not "Completely Invoiced" then begin
            "Completely Invoiced" := true;
            Modify;
        end;
    end;

    procedure AppliedEntryToAdjustExists(ItemNo: Code[20]): Boolean
    begin
        Reset;
        SetCurrentKey("Item No.", "Applied Entry to Adjust");
        SetRange("Item No.", ItemNo);
        SetRange("Applied Entry to Adjust", true);
        exit(Find('-'));
    end;

    procedure IsOutbndConsump(): Boolean
    begin
        exit(("Entry Type" = "Entry Type"::Consumption) and not Positive);
    end;

    procedure IsExactCostReversingPurchase(): Boolean
    begin
        exit(
          ("Applies-to Entry" <> 0) and
          ("Entry Type" = "Entry Type"::Purchase) and
          ("Invoiced Quantity" < 0));
    end;

    procedure IsExactCostReversingOutput(): Boolean
    begin
        exit(
          ("Applies-to Entry" <> 0) and
          ("Entry Type" in ["Entry Type"::Output, "Entry Type"::"Assembly Output"]) and
          ("Invoiced Quantity" < 0));
    end;

    procedure UpdateItemTracking()
    var
        ReservEntry: Record "Reservation Entry";
    begin
        ReservEntry.CopyTrackingFromItemLedgEntry(Rec);
        "Item Tracking" := ReservEntry.GetItemTrackingEntryType();
    end;

    procedure GetSourceCaption(): Text
    begin
        exit(StrSubstNo('%1 %2', TableCaption, "Entry No."));
    end;

    procedure GetUnitCostLCY(): Decimal
    begin
        if "Cost Amount (Actual)" = 0 then    // P8000466A
            CalcFields("Cost Amount (Actual)"); // P8000466A
        if GetCostingQty = 0 then // P8000466A
            exit("Cost Amount (Actual)");

        exit(Round("Cost Amount (Actual)" / GetCostingQty, 0.00001)); // P8000466A
    end;

    procedure FilterLinesWithItemToPlan(var Item: Record Item; NetChange: Boolean)
    begin
        Reset;
        SetCurrentKey("Item No.", Open, "Variant Code", Positive, "Location Code", "Posting Date");
        SetRange("Item No.", Item."No.");
        SetRange(Open, true);
        SetFilter("Variant Code", Item.GetFilter("Variant Filter"));
        SetFilter("Location Code", Item.GetFilter("Location Filter"));
        SetFilter("Global Dimension 1 Code", Item.GetFilter("Global Dimension 1 Filter"));
        SetFilter("Global Dimension 2 Code", Item.GetFilter("Global Dimension 2 Filter"));
        if NetChange then
            SetFilter("Posting Date", Item.GetFilter("Date Filter"));
        SetFilter("Unit of Measure Code", Item.GetFilter("Unit of Measure Filter"));

        OnAfterFilterLinesWithItemToPlan(Rec, Item, NetChange);
    end;

    procedure FindLinesWithItemToPlan(var Item: Record Item; NetChange: Boolean): Boolean
    begin
        FilterLinesWithItemToPlan(Item, NetChange);
        exit(Find('-'));
    end;

    procedure LinesWithItemToPlanExist(var Item: Record Item; NetChange: Boolean): Boolean
    begin
        FilterLinesWithItemToPlan(Item, NetChange);
        exit(not IsEmpty);
    end;

    procedure FilterLinesForReservation(ReservationEntry: Record "Reservation Entry"; NewPositive: Boolean)
    var
        IsHandled: Boolean;
    begin
        Reset;
        SetCurrentKey("Item No.", Open, "Variant Code", Positive, "Location Code");
        SetRange("Item No.", ReservationEntry."Item No.");
        SetRange(Open, true);
        IsHandled := false;
        OnFilterLinesForReservationOnBeforeSetFilterVariantCode(Rec, ReservationEntry, Positive, IsHandled);
        if not IsHandled then
            SetRange("Variant Code", ReservationEntry."Variant Code");
        SetRange(Positive, NewPositive);
        SetRange("Location Code", ReservationEntry."Location Code");
        SetRange("Drop Shipment", false);
    end;

    procedure FilterLinesForTracking(CalcReservEntry: Record "Reservation Entry"; Positive: Boolean)
    var
        FieldFilter: Text;
    begin
        if CalcReservEntry.FieldFilterNeeded(FieldFilter, Positive, "Item Tracking Type"::"Lot No.") then
            SetFilter("Lot No.", FieldFilter);
        if CalcReservEntry.FieldFilterNeeded(FieldFilter, Positive, "Item Tracking Type"::"Serial No.") then
            SetFilter("Serial No.", FieldFilter);

        OnAfterFilterLinesForTracking(Rec, CalcReservEntry, Positive);
    end;

    procedure IsOutbndSale(): Boolean
    begin
        exit(("Entry Type" = "Entry Type"::Sale) and not Positive);
    end;

    procedure ShowDimensions()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo('%1 %2', TableCaption, "Entry No."));
    end;

    procedure CalculateRemQuantity(ItemLedgEntryNo: Integer; PostingDate: Date): Decimal
    var
        RemQty: Decimal;
        RemQtyAlt: Decimal;
    begin
        // P80096141 - Original signature
        CalculateRemQuantity(ItemLedgEntryNo, PostingDate, RemQty, RemQtyAlt);
        exit(RemQty);
    end;

    procedure CalculateRemQuantity(ItemLedgEntryNo: Integer; PostingDate: Date; var RemQty: Decimal; var RemQtyAlt: Decimal)
    var
        ItemApplnEntry: Record "Item Application Entry";
    begin
        // P8001302 - get rid of return value and pass both quantity and alternate quantity back as parameters
        ItemApplnEntry.SetCurrentKey("Inbound Item Entry No.");
        ItemApplnEntry.SetRange("Inbound Item Entry No.", ItemLedgEntryNo);
        RemQty := 0;
        RemQtyAlt := 0; // P8001302
        if ItemApplnEntry.FindSet() then
            repeat
                if ItemApplnEntry."Posting Date" <= PostingDate then begin // P8008735
                    RemQty += ItemApplnEntry.Quantity;
                    RemQtyAlt += ItemApplnEntry."Quantity (Alt.)"; // P8001302
                end; // P8008735
            until ItemApplnEntry.Next() = 0;
        //exit(RemQty);
    end;

    procedure VerifyOnInventory()
    begin
        VerifyOnInventory(StrSubstNo(IsNotOnInventoryErr, "Item No."));
    end;

    procedure VerifyOnInventory(ErrorMessageText: Text)
    var
        Item: Record Item;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeVerifyOnInventory(Rec, IsHandled);
        if IsHandled then
            exit;

        if not Open then
            exit;
        if (Quantity >= 0) and ("Quantity (Alt.)" >= 0) then // P8001213
            exit;
        case "Entry Type" of
            "Entry Type"::Consumption, "Entry Type"::"Assembly Consumption", "Entry Type"::Transfer:
                Error(ErrorMessageText);
            else begin
                    Item.Get("Item No.");
                    if Item.PreventNegativeInventory then
                        Error(ErrorMessageText);
                end;
        end;
    end;

    procedure CalculateRemInventoryValue(ItemLedgEntryNo: Integer; ItemLedgEntryQty: Decimal; RemQty: Decimal; IncludeExpectedCost: Boolean; PostingDate: Date): Decimal
    begin
        exit(
          CalculateRemInventoryValue(ItemLedgEntryNo, ItemLedgEntryQty, RemQty, IncludeExpectedCost, PostingDate, 0D));
    end;

    procedure CalculateRemInventoryValue(ItemLedgEntryNo: Integer; ItemLedgEntryQty: Decimal; RemQty: Decimal; IncludeExpectedCost: Boolean; ValuationDate: Date; PostingDate: Date): Decimal
    var
        ValueEntry: Record "Value Entry";
        AdjustedCost: Decimal;
        TotalQty: Decimal;
    begin
        ValueEntry.SetCurrentKey("Item Ledger Entry No.");
        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgEntryNo);
        if ValuationDate <> 0D then
            ValueEntry.SetRange("Valuation Date", 0D, ValuationDate);
        if PostingDate <> 0D then
            ValueEntry.SetRange("Posting Date", 0D, PostingDate);
        ValueEntry.SetFilter("Entry Type", '<>%1', ValueEntry."Entry Type"::Rounding);
        if not IncludeExpectedCost then
            ValueEntry.SetRange("Expected Cost", false);
        if ValueEntry.FindSet() then
            repeat
                if ValueEntry."Entry Type" = ValueEntry."Entry Type"::Revaluation then
                    TotalQty := ValueEntry."Valued Quantity"
                else
                    TotalQty := ItemLedgEntryQty;
                if TotalQty <> 0 then // P8000106A, P8001132
                    if IncludeExpectedCost then
                        AdjustedCost += RemQty / TotalQty * (ValueEntry."Cost Amount (Actual)" + ValueEntry."Cost Amount (Expected)")
                    else
                        AdjustedCost += RemQty / TotalQty * ValueEntry."Cost Amount (Actual)";
            until ValueEntry.Next() = 0;
        exit(AdjustedCost);
    end;

    local procedure GetItem()
    begin
        // PR3.60
        if (Item."No." <> "Item No.") then
            Item.Get("Item No.");
        // PR3.60
    end;

    procedure CostInAlternateUnits(): Boolean
    begin
        // P8000466A
        GetItem;
        exit(Item.CostInAlternateUnits);
    end;

    procedure PriceInAlternateUnits(): Boolean
    begin
        // P8000981
        GetItem;
        exit(Item.PriceInAlternateUnits());
    end;

    procedure GetCostingQty(): Decimal
    begin
        // PR3.60
        GetItem;
        if Item.CostInAlternateUnits() then
            exit("Quantity (Alt.)");
        exit(Quantity);
        // PR3.60
    end;

    procedure GetCostingInvQty(): Decimal
    begin
        // PR3.60
        GetItem;
        if Item.CostInAlternateUnits() then
            exit("Invoiced Quantity (Alt.)");
        exit("Invoiced Quantity");
        // PR3.60
    end;

    procedure GetCostingRemQty(): Decimal
    begin
        // PR3.60
        GetItem;
        if Item.CostInAlternateUnits() then
            exit("Remaining Quantity (Alt.)");
        exit("Remaining Quantity");
        // PR3.60
    end;

    procedure GetPricingQty(): Decimal
    begin
        // P8000981
        if PriceInAlternateUnits() then
            exit("Quantity (Alt.)");
        exit(Quantity);
    end;

    procedure SourceName(): Text[100]
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Item: Record Item;
    begin
        // PR2.00 Begin
        // P8001258 - increase size or Return Value to Text50
        case "Source Type" of
            "Source Type"::Customer:
                if Customer.Get("Source No.") then
                    exit(Customer.Name);
            "Source Type"::Vendor:
                if Vendor.Get("Source No.") then
                    exit(Vendor.Name);
            "Source Type"::Item:
                if Item.Get("Source No.") then
                    exit(Item.Description);
        end;
        // PR2.00 End
    end;

    procedure ItemDesc(): Text[100]
    var
        Item: Record Item;
    begin
        // PR2.00 Begin
        // P8001258 - increase size or Return Value to Text50
        if Item.Get("Item No.") then
            exit(Item.Description);
        // PR2.00 End
    end;

    procedure AltQtyEntriesExist(): Boolean
    var
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // PR3.60
        AltQtyEntry.SetRange("Table No.", DATABASE::"Item Ledger Entry");
        AltQtyEntry.SetRange("Document No.", '');
        AltQtyEntry.SetRange("Source Line No.", "Entry No.");
        exit(AltQtyEntry.Find('-'));
        // PR3.60
    end;

    procedure SalesQuantity(): Decimal
    begin
        // P8000248B
        if "Entry Type" <> "Entry Type"::Sale then
            exit(0);

        exit(Round(-Quantity / "Qty. per Unit of Measure", 0.00001));
    end;

    procedure SalesUnitPrice(): Decimal
    var
        PricingQty: Decimal;
    begin
        // P8000248B
        GetItem;
        //IF Item.CostInAlternateUnits THEN  // P8000981
        if Item.PriceInAlternateUnits then   // P8000981
            PricingQty := -"Quantity (Alt.)"
        else
            PricingQty := SalesQuantity;

        if PricingQty <> 0 then begin
            if not GLSetupRead then begin
                GLSetup.Get;
                GLSetupRead := true;
            end;
            CalcFields("Sales Amount (Actual)", "Sales Amount (Expected)");
            exit(Round(("Sales Amount (Actual)" + "Sales Amount (Expected)") / PricingQty,
              GLSetup."Unit-Amount Rounding Precision"));
        end;
    end;

    procedure OpenItemTracing()
    var
        ItemTracingBuffer: Record "Item Tracing Buffer";
        ItemTracing: Page "Item Tracing";
    begin
        // P8000466A
        ItemTracingBuffer.SetRange("Item No.", "Item No.");
        ItemTracingBuffer.SetRange("Variant Code", "Variant Code");
        ItemTracingBuffer.SetRange("Lot No.", "Lot No.");
        ItemTracing.InitFilters(ItemTracingBuffer);
        ItemTracing.FindRecords;
        ItemTracing.Run;
    end;

    procedure SalesUnitPriceFreight(): Decimal
    var
        PricingQty: Decimal;
    begin
        // P8000921
        CalcFields("Sales Amount (Freight)");
        if ("Sales Amount (Freight)" <> 0) then begin
            //IF CostInAlternateUnits() THEN // P8000981
            if PriceInAlternateUnits() then  // P8000981
                PricingQty := -"Invoiced Quantity (Alt.)"
            else
                PricingQty := Round(-"Invoiced Quantity" / "Qty. per Unit of Measure", 0.00001);
            if PricingQty <> 0 then begin
                if not GLSetupRead then begin
                    GLSetup.Get;
                    GLSetupRead := true;
                end;
                exit(Round("Sales Amount (Freight)" / PricingQty, GLSetup."Unit-Amount Rounding Precision"));
            end;
        end;
    end;

    procedure OpenLotTracing(var SelectedEntry: Record "Item Ledger Entry")
    var
        LotTracingPage: Page "Lot Tracing";
        SelectedLot: Record "Lot No. Information";
        MultLotTracePage: Page "Multiple Lot Trace";
    begin
        // P8000979, P8000984
        SelectedEntry.SetFilter("Lot No.", '<>%1', '');
        if IsMultipleLots(SelectedEntry) then begin
            MultLotTracePage.SetTraceFromItemLedgEntries(SelectedEntry);
            MultLotTracePage.Run;
        end else begin
            if SelectedEntry."Lot No." = '' then
                exit;
            LotTracingPage.SetTraceLot(SelectedEntry."Item No.", SelectedEntry."Variant Code", SelectedEntry."Lot No.");
            LotTracingPage.Run;
        end;
    end;

    local procedure IsMultipleLots(var SelectedEntry: Record "Item Ledger Entry"): Boolean
    var
        FirstEntry: Record "Item Ledger Entry";
    begin
        // P8000984
        if SelectedEntry.FindSet then begin
            FirstEntry := SelectedEntry;
            while (SelectedEntry.Next <> 0) do begin
                if (SelectedEntry."Item No." <> FirstEntry."Item No.") or
                   (SelectedEntry."Variant Code" <> FirstEntry."Variant Code") or
                   (SelectedEntry."Lot No." <> FirstEntry."Lot No.")
                then
                    exit(true);
            end;
        end;
    end;

    procedure IsBOMOrderType(): Boolean
    begin
        exit("Order Type" in ["Order Type"::FOODLotCombination, "Order Type"::FOODRepack, "Order Type"::FOODSalesRepack]); // P8001134
    end;

    procedure TrackingExists() IsTrackingExist: Boolean
    begin
        IsTrackingExist := ("Serial No." <> '') or ("Lot No." <> '');

        OnAfterTrackingExists(Rec, IsTrackingExist);
    end;

    procedure CheckTrackingDoesNotExist(RecId: RecordId; FldCaption: Text)
    var
        ItemTrackingLines: Page "Item Tracking Lines";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckTrackingDoesNotExist(RecId, Rec, FldCaption, IsHandled);
        if IsHandled then
            exit;

        if TrackingExists() then
            Error(UseItemTrackingLinesPageErr, ItemTrackingLines.Caption, FldCaption);
    end;

    procedure CopyTrackingFromItemJnlLine(ItemJnlLine: Record "Item Journal Line")
    begin
        "Serial No." := ItemJnlLine."Serial No.";
        "Lot No." := ItemJnlLine."Lot No.";

        OnAfterCopyTrackingFromItemJnlLine(Rec, ItemJnlLine);
    end;

    procedure CopyTrackingFromNewItemJnlLine(ItemJnlLine: Record "Item Journal Line")
    begin
        "Serial No." := ItemJnlLine."New Serial No.";
        "Lot No." := ItemJnlLine."New Lot No.";

        OnAfterCopyTrackingFromNewItemJnlLine(Rec, ItemJnlLine);
    end;

    procedure GetReservationQty(var QtyReserved: Decimal; var QtyToReserve: Decimal)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetReservationQty(Rec, QtyReserved, QtyToReserve, IsHandled);
        if IsHandled then
            exit;

        CalcFields("Reserved Quantity");
        QtyReserved := "Reserved Quantity";
        QtyToReserve := "Remaining Quantity" - "Reserved Quantity";
    end;

    procedure SetItemVariantLocationFilters(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; PostingDate: Date)
    begin
        Reset;
        SetCurrentKey("Item No.", Open, "Variant Code", Positive, "Location Code", "Posting Date");
        SetRange("Item No.", ItemNo);
        SetRange("Variant Code", VariantCode);
        SetRange("Location Code", LocationCode);
        SetRange("Posting Date", 0D, PostingDate);
    end;

    procedure SetReservationEntry(var ReservEntry: Record "Reservation Entry")
    begin
        ReservEntry.SetSource(DATABASE::"Item Ledger Entry", 0, '', "Entry No.", '', 0);
        ReservEntry.SetItemData("Item No.", Description, "Location Code", "Variant Code", "Qty. per Unit of Measure");
        Positive := "Remaining Quantity" <= 0;
        if Positive then begin
            ReservEntry."Expected Receipt Date" := DMY2Date(31, 12, 9999);
            ReservEntry."Shipment Date" := DMY2Date(31, 12, 9999);
        end else begin
            ReservEntry."Expected Receipt Date" := 0D;
            ReservEntry."Shipment Date" := 0D;
        end;
    end;

    procedure SetReservationFilters(var ReservEntry: Record "Reservation Entry")
    begin
        ReservEntry.SetSourceFilter(DATABASE::"Item Ledger Entry", 0, '', "Entry No.", false);
        ReservEntry.SetSourceFilter('', 0);

        OnAfterSetReservationFilters(ReservEntry, Rec);
    end;

    procedure SetTrackingFilterFromItemLedgEntry(ItemLedgEntry: Record "Item Ledger Entry")
    begin
        SetRange("Serial No.", ItemLedgEntry."Serial No.");
        SetRange("Lot No.", ItemLedgEntry."Lot No.");

        OnAfterSetTrackingFilterFromItemLedgEntry(Rec, ItemLedgEntry);
    end;

    procedure SetTrackingFilterFromItemJournalLine(ItemJournalLine: Record "Item Journal Line")
    begin
        SetRange("Serial No.", ItemJournalLine."Serial No.");
        SetRange("Lot No.", ItemJournalLine."Lot No.");

        OnAfterSetTrackingFilterFromItemJournalLine(Rec, ItemJournalLine);
    end;

    procedure SetTrackingFilterFromItemTrackingSetup(ItemTrackingSetup: Record "Item Tracking Setup")
    begin
        SetRange("Serial No.", ItemTrackingSetup."Serial No.");
        SetRange("Lot No.", ItemTrackingSetup."Lot No.");

        OnAfterSetTrackingFilterFromItemTrackingSetup(Rec, ItemTrackingSetup);
    end;

    procedure SetTrackingFilterFromItemTrackingSetupIfNotBlank(ItemTrackingSetup: Record "Item Tracking Setup")
    begin
        if ItemTrackingSetup."Serial No." <> '' then
            SetRange("Serial No.", ItemTrackingSetup."Serial No.");
        if ItemTrackingSetup."Lot No." <> '' then
            SetRange("Lot No.", ItemTrackingSetup."Lot No.");

        OnAfterSetTrackingFilterFromItemTrackingSetupIfNotBlank(Rec, ItemTrackingSetup);
    end;

    procedure SetTrackingFilterFromItemTrackingSetupIfRequired(ItemTrackingSetup: Record "Item Tracking Setup")
    begin
        if ItemTrackingSetup."Serial No. Required" then
            SetRange("Serial No.", ItemTrackingSetup."Serial No.");
        if ItemTrackingSetup."Lot No. Required" then
            SetRange("Lot No.", ItemTrackingSetup."Lot No.");

        OnAfterSetTrackingFilterFromItemTrackingSetupIfRequired(Rec, ItemTrackingSetup);
    end;

    procedure SetTrackingFilterFromSpec(TrackingSpecification: Record "Tracking Specification")
    begin
        SetRange("Serial No.", TrackingSpecification."Serial No.");
        SetRange("Lot No.", TrackingSpecification."Lot No.");

        OnAfterSetTrackingFilterFromSpec(Rec, TrackingSpecification);
    end;

    procedure SetTrackingFilterBlank()
    begin
        SetRange("Serial No.", '');
        SetRange("Lot No.", '');

        OnAfterSetTrackingFilterBlank(Rec);
    end;

    procedure ClearTrackingFilter()
    begin
        SetRange("Serial No.");
        SetRange("Lot No.");

        OnAfterClearTrackingFilter(Rec);
    end;

    procedure TestTrackingEqualToTrackingSpec(TrackingSpecification: Record "Tracking Specification")
    begin
        TestField("Serial No.", TrackingSpecification."Serial No.");
        TestField("Lot No.", TrackingSpecification."Lot No.");

        OnAfterTestTrackingEqualToTrackingSpec(Rec, TrackingSpecification);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterClearTrackingFilter(var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetTrackingFilterBlank(var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyTrackingFromItemJnlLine(var ItemLedgerEntry: Record "Item Ledger Entry"; ItemJnlLine: Record "Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyTrackingFromNewItemJnlLine(var ItemLedgerEntry: Record "Item Ledger Entry"; ItemJnlLine: Record "Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFilterLinesWithItemToPlan(var ItemLedgerEntry: Record "Item Ledger Entry"; var Item: Record Item; NetChange: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFilterLinesForTracking(var ItemLedgerEntry: Record "Item Ledger Entry"; CalcReservEntry: Record "Reservation Entry"; Positive: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetReservationFilters(var ReservEntry: Record "Reservation Entry"; ItemLedgerEntry: Record "Item Ledger Entry");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetTrackingFilterFromItemLedgEntry(var ItemLedgerEntry: Record "Item Ledger Entry"; FromItemLedgerEntry: Record "Item Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetTrackingFilterFromItemJournalLine(var ItemLedgerEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetTrackingFilterFromItemTrackingSetup(var ItemLedgerEntry: Record "Item Ledger Entry"; ItemTrackingSetup: Record "Item Tracking Setup");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetTrackingFilterFromItemTrackingSetupIfNotBlank(var ItemLedgerEntry: Record "Item Ledger Entry"; ItemTrackingSetup: Record "Item Tracking Setup");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetTrackingFilterFromItemTrackingSetupIfRequired(var ItemLedgerEntry: Record "Item Ledger Entry"; ItemTrackingSetup: Record "Item Tracking Setup");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetTrackingFilterFromSpec(var ItemLedgerEntry: Record "Item Ledger Entry"; TrackingSpecification: Record "Tracking Specification")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTrackingExists(ItemLedgerEntry: Record "Item Ledger Entry"; var IsTrackingExist: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTestTrackingEqualToTrackingSpec(var ItemLedgerEntry: Record "Item Ledger Entry"; TrackingSpecification: Record "Tracking Specification")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckTrackingDoesNotExist(RecId: RecordId; ItemLedgEntry: Record "Item Ledger Entry"; FldCaption: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetReservationQty(var ItemLedgerEntry: Record "Item Ledger Entry"; var QtyReserved: Decimal; var QtyToReserve: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeVerifyOnInventory(var ItemLedgerEntry: Record "Item Ledger Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFilterLinesForReservationOnBeforeSetFilterVariantCode(var ItemLedgerEntry: Record "Item Ledger Entry"; var ReservationEntry: Record "Reservation Entry"; var Positive: Boolean; var IsHandled: Boolean)
    begin
    end;
}

