table 121 "Purch. Rcpt. Line"
{
    // PR1.00
    //   New Process 800 fields
    //     Original Quantity
    // 
    // PR1.10
    //   New field
    //     Vendor Lot No.
    // 
    // PR2.00
    //   Remove Vendor Lot No. - moveed to Lot No. Information
    // 
    // PR3.60
    //   Add fields for alternate quantities
    // 
    // PR3.70
    //   Add Key - Type,No. (Group - LOT CTRL)
    // 
    // PR3.70.01
    //   New Fields
    //     Receiving Reason Code
    //     Farm
    //     Brand
    //   Extra Charges
    // 
    // PR3.70.03
    //   Add Field
    //    Accrual Amount (Cost)
    // 
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 30 AUG 05
    //   Add Accrual Plan option to Type
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 31 JUL 07
    //   Support alternate quantity for received not returned
    // 
    // PRW15.00.03
    // P8000624A, VerticalSoft, Jack Reynolds, 19 AUG 08
    //   Add field for country/region of origin
    // 
    // PRW16.00.04
    // P8000899, Columbus IT, Ron Davidson, 17 FEB 11
    //   Added a new field called Production Date for Freshness Tracking.
    // 
    // PRW16.00.05
    // P8000931, Columbus IT, Jack Reynolds, 20 APR 11
    //   Support for Supply Chain Groups
    // 
    // P8000971, Columbus IT, Jack Reynolds, 25 AUG 11
    //   Fix problem with item charges and alternate quantity
    // 
    // PRW16.00.06
    // P8001036, Columbus IT, Jack Reynolds, 21 FEB 12
    //   Copy extra charges from receipt line to invoice line
    // 
    // P8001047, Columbus IT, Jack Reynolds, 30 MAR 12
    //   Receiving Labels
    // 
    // P8001062, Columbus IT, Jack Reynolds, 26 APR 12
    //   Rename Production Date to Creation Date
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality
    // 
    // PRW18.00.02
    // P8002742, To-Increase, Jack Reynolds, 30 Sep 15
    //   Support for accrual payment documents
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 9 NOV 15
    //   NAV 2016 refactoring
    // 
    // PRW111.00.02
    // P80070933, To Increase, Gangabhushan, 07 MAR 19
    //   TI-12888 - When using get receipt lines to invoice a catch weight item the qty to invoice alt is not properly set
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Purch. Rcpt. Line';
    DrillDownPageID = "Posted Purchase Receipt Lines";
    LookupPageID = "Posted Purchase Receipt Lines";
    Permissions = TableData "Item Ledger Entry" = r,
                  TableData "Value Entry" = r;

    fields
    {
        field(2; "Buy-from Vendor No."; Code[20])
        {
            Caption = 'Buy-from Vendor No.';
            Editable = false;
            TableRelation = Vendor;
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "Purch. Rcpt. Header";
            trigger OnValidate()
            begin
                UpdateDocumentId();
            end;
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(5; Type; Enum "Purchase Line Type")
        {
            Caption = 'Type';
        }
        field(6; "No."; Code[20])
        {
            CaptionClass = GetCaptionClass(FieldNo("No."));
            Caption = 'No.';
            TableRelation = IF (Type = CONST("G/L Account")) "G/L Account"
            ELSE
            IF (Type = CONST(Item)) Item
            ELSE
            IF (Type = CONST("Fixed Asset")) "Fixed Asset"
            ELSE
            IF (Type = CONST("Charge (Item)")) "Item Charge"
            else
            if (Type = const(Resource)) Resource
            else
            if (Type = CONST(FOODAccrualPlan)) "Accrual Plan"."No.";
        }
        field(7; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
        }
        field(8; "Posting Group"; Code[20])
        {
            Caption = 'Posting Group';
            Editable = false;
            TableRelation = IF (Type = CONST(Item)) "Inventory Posting Group"
            ELSE
            IF (Type = CONST("Fixed Asset")) "FA Posting Group";
        }
        field(10; "Expected Receipt Date"; Date)
        {
            Caption = 'Expected Receipt Date';
        }
        field(11; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(12; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
        }
        field(13; "Unit of Measure"; Text[50])
        {
            Caption = 'Unit of Measure';
        }
        field(15; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(22; "Direct Unit Cost"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCodeFromHeader();
            AutoFormatType = 2;
            Caption = 'Direct Unit Cost';
        }
        field(23; "Unit Cost (LCY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost (LCY)';
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
        }
        field(31; "Unit Price (LCY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price (LCY)';
        }
        field(32; "Allow Invoice Disc."; Boolean)
        {
            Caption = 'Allow Invoice Disc.';
            InitValue = true;
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
        }
        field(39; "Item Rcpt. Entry No."; Integer)
        {
            Caption = 'Item Rcpt. Entry No.';
        }
        field(40; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(41; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(45; "Job No."; Code[20])
        {
            Caption = 'Job No.';
            TableRelation = Job;
        }
        field(54; "Indirect Cost %"; Decimal)
        {
            Caption = 'Indirect Cost %';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(58; "Qty. Rcd. Not Invoiced"; Decimal)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            Caption = 'Qty. Rcd. Not Invoiced';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(61; "Quantity Invoiced"; Decimal)
        {
            Caption = 'Quantity Invoiced';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(65; "Order No."; Code[20])
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            Caption = 'Order No.';
        }
        field(66; "Order Line No."; Integer)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            Caption = 'Order Line No.';
        }
        field(68; "Pay-to Vendor No."; Code[20])
        {
            Caption = 'Pay-to Vendor No.';
            TableRelation = Vendor;
        }
        field(70; "Vendor Item No."; Text[50])
        {
            Caption = 'Vendor Item No.';
        }
        field(71; "Sales Order No."; Code[20])
        {
            Caption = 'Sales Order No.';
        }
        field(72; "Sales Order Line No."; Integer)
        {
            Caption = 'Sales Order Line No.';
        }
        field(74; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
        }
        field(75; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
        field(77; "VAT Calculation Type"; Enum "Tax Calculation Type")
        {
            Caption = 'VAT Calculation Type';
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
            TableRelation = "Purch. Rcpt. Line"."Line No." WHERE("Document No." = FIELD("Document No."));
        }
        field(81; "Entry Point"; Code[10])
        {
            Caption = 'Entry Point';
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
        field(85; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            TableRelation = "Tax Area";
        }
        field(86; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
        }
        field(87; "Tax Group Code"; Code[20])
        {
            Caption = 'Tax Group Code';
            TableRelation = "Tax Group";
        }
        field(88; "Use Tax"; Boolean)
        {
            Caption = 'Use Tax';
        }
        field(89; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
        field(90; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(91; "Currency Code"; Code[10])
        {
            CalcFormula = Lookup("Purch. Rcpt. Header"."Currency Code" WHERE("No." = FIELD("Document No.")));
            Caption = 'Currency Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(97; "Blanket Order No."; Code[20])
        {
            Caption = 'Blanket Order No.';
            TableRelation = "Purchase Header"."No." WHERE("Document Type" = CONST("Blanket Order"));
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(98; "Blanket Order Line No."; Integer)
        {
            Caption = 'Blanket Order Line No.';
            TableRelation = "Purchase Line"."Line No." WHERE("Document Type" = CONST("Blanket Order"),
                                                              "Document No." = FIELD("Blanket Order No."));
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(99; "VAT Base Amount"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCodeFromHeader();
            AutoFormatType = 1;
            Caption = 'VAT Base Amount';
            Editable = false;
        }
        field(100; "Unit Cost"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCodeFromHeader();
            AutoFormatType = 2;
            Caption = 'Unit Cost';
            Editable = false;
        }
        field(107; "IC Partner Ref. Type"; Enum "IC Partner Reference Type")
        {
            Caption = 'IC Partner Ref. Type';
            DataClassification = CustomerContent;
        }
        field(108; "IC Partner Reference"; Code[20])
        {
            Caption = 'IC Partner Reference';
            DataClassification = CustomerContent;
        }
        field(131; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(138; "IC Item Reference No."; Code[50])
        {
            AccessByPermission = TableData "Item Reference" = R;
            Caption = 'IC Item Reference No.';
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
        field(1001; "Job Task No."; Code[20])
        {
            Caption = 'Job Task No.';
            TableRelation = "Job Task"."Job Task No." WHERE("Job No." = FIELD("Job No."));
        }
        field(1002; "Job Line Type"; Enum "Job Line Type")
        {
            Caption = 'Job Line Type';
        }
        field(1003; "Job Unit Price"; Decimal)
        {
            BlankZero = true;
            Caption = 'Job Unit Price';
        }
        field(1004; "Job Total Price"; Decimal)
        {
            BlankZero = true;
            Caption = 'Job Total Price';
        }
        field(1005; "Job Line Amount"; Decimal)
        {
            AutoFormatExpression = "Job Currency Code";
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Job Line Amount';
        }
        field(1006; "Job Line Discount Amount"; Decimal)
        {
            AutoFormatExpression = "Job Currency Code";
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Job Line Discount Amount';
        }
        field(1007; "Job Line Discount %"; Decimal)
        {
            BlankZero = true;
            Caption = 'Job Line Discount %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(1008; "Job Unit Price (LCY)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Job Unit Price (LCY)';
        }
        field(1009; "Job Total Price (LCY)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Job Total Price (LCY)';
        }
        field(1010; "Job Line Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Job Line Amount (LCY)';
        }
        field(1011; "Job Line Disc. Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Job Line Disc. Amount (LCY)';
        }
        field(1012; "Job Currency Factor"; Decimal)
        {
            BlankZero = true;
            Caption = 'Job Currency Factor';
        }
        field(1013; "Job Currency Code"; Code[20])
        {
            Caption = 'Job Currency Code';
        }
        field(5401; "Prod. Order No."; Code[20])
        {
            Caption = 'Prod. Order No.';
            TableRelation = "Production Order"."No." WHERE(Status = FILTER(Released | Finished));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(5402; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = IF (Type = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD("No."));
        }
        field(5403; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"),
                                            "Item Filter" = FIELD("No."),
                                            "Variant Filter" = FIELD("Variant Code"));
        }
        field(5404; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(5407; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = IF (Type = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."))
            ELSE
            "Unit of Measure";
        }
        field(5415; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(5461; "Qty. Invoiced (Base)"; Decimal)
        {
            Caption = 'Qty. Invoiced (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(5600; "FA Posting Date"; Date)
        {
            Caption = 'FA Posting Date';
        }
        field(5601; "FA Posting Type"; Enum "Purchase FA Posting Type")
        {
            Caption = 'FA Posting Type';
        }
        field(5602; "Depreciation Book Code"; Code[10])
        {
            Caption = 'Depreciation Book Code';
            TableRelation = "Depreciation Book";
        }
        field(5603; "Salvage Value"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Salvage Value';
        }
        field(5605; "Depr. until FA Posting Date"; Boolean)
        {
            Caption = 'Depr. until FA Posting Date';
        }
        field(5606; "Depr. Acquisition Cost"; Boolean)
        {
            Caption = 'Depr. Acquisition Cost';
        }
        field(5609; "Maintenance Code"; Code[10])
        {
            Caption = 'Maintenance Code';
            TableRelation = Maintenance;
        }
        field(5610; "Insurance No."; Code[20])
        {
            Caption = 'Insurance No.';
            TableRelation = Insurance;
        }
        field(5611; "Budgeted FA No."; Code[20])
        {
            Caption = 'Budgeted FA No.';
            TableRelation = "Fixed Asset";
        }
        field(5612; "Duplicate in Depreciation Book"; Code[10])
        {
            Caption = 'Duplicate in Depreciation Book';
            TableRelation = "Depreciation Book";
        }
        field(5613; "Use Duplication List"; Boolean)
        {
            Caption = 'Use Duplication List';
        }
        field(5700; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            TableRelation = "Responsibility Center";
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
        field(5725; "Item Reference No."; Code[50])
        {
            AccessByPermission = TableData "Item Reference" = R;
            Caption = 'Item Reference No.';
        }
        field(5726; "Item Reference Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure (Item Ref.)';
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
        field(5709; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            TableRelation = IF (Type = CONST(Item)) "Item Category";
        }
        field(5710; Nonstock; Boolean)
        {
            Caption = 'Catalog';
        }
        field(5711; "Purchasing Code"; Code[10])
        {
            Caption = 'Purchasing Code';
            TableRelation = Purchasing;
        }
        field(5712; "Product Group Code"; Code[10])
        {
            Caption = 'Product Group Code';
            ObsoleteReason = 'Product Groups became first level children of Item Categories.';
            ObsoleteState = Removed;
            ObsoleteTag = '15.0';
        }
        field(5714; "Special Order Sales No."; Code[20])
        {
            Caption = 'Special Order Sales No.';
        }
        field(5715; "Special Order Sales Line No."; Integer)
        {
            Caption = 'Special Order Sales Line No.';
        }
        field(5790; "Requested Receipt Date"; Date)
        {
            Caption = 'Requested Receipt Date';
        }
        field(5791; "Promised Receipt Date"; Date)
        {
            Caption = 'Promised Receipt Date';
        }
        field(5792; "Lead Time Calculation"; DateFormula)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            Caption = 'Lead Time Calculation';
        }
        field(5793; "Inbound Whse. Handling Time"; DateFormula)
        {
            AccessByPermission = TableData Location = R;
            Caption = 'Inbound Whse. Handling Time';
        }
        field(5794; "Planned Receipt Date"; Date)
        {
            Caption = 'Planned Receipt Date';
        }
        field(5795; "Order Date"; Date)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            Caption = 'Order Date';
        }
        field(5811; "Item Charge Base Amount"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCodeFromHeader();
            AutoFormatType = 1;
            Caption = 'Item Charge Base Amount';
        }
        field(5817; Correction; Boolean)
        {
            Caption = 'Correction';
            Editable = false;
        }
        field(6608; "Return Reason Code"; Code[10])
        {
            Caption = 'Return Reason Code';
            TableRelation = "Return Reason";
        }
        field(7000; "Price Calculation Method"; Enum "Price Calculation Method")
        {
            Caption = 'Price Calculation Method';
        }
        field(8000; "Document Id"; Guid)
        {
            Caption = 'Document Id';
            trigger OnValidate()
            begin
                UpdateDocumentNo();
            end;
        }
        field(8509; "Over-Receipt Quantity"; Decimal)
        {
            Caption = 'Over-Receipt Quantity';
            Editable = false;
        }
        field(8510; "Over-Receipt Code"; Code[10])
        {
            Caption = 'Over-Receipt Code';
            TableRelation = "Over-Receipt Code";
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Replaced with field 8512 due to wrong field length';
            ObsoleteTag = '20.0';
        }
        field(8512; "Over-Receipt Code 2"; Code[20])
        {
            Caption = 'Over-Receipt Code';
            TableRelation = "Over-Receipt Code";
            Editable = false;
        }
        field(37002000; "Original Quantity"; Decimal)
        {
            Caption = 'Original Quantity';
            Description = 'PR1.00';
        }
        field(37002015; "Supply Chain Group Code"; Code[10])
        {
            Caption = 'Supply Chain Group Code';
            TableRelation = "Supply Chain Group";
        }
        field(37002021; "Creation Date"; Date)
        {
            Caption = 'Creation Date';
        }
        field(37002081; "Quantity (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,1,0,%1,%2', Type, "No.");
            Caption = 'Quantity (Alt.)';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.60';
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
        field(37002124; "Accrual Amount (Cost)"; Decimal)
        {
            Caption = 'Accrual Amount (Cost)';
            Description = 'PR3.70.03';
            Editable = false;
        }
        field(37002660; "Receiving Reason Code"; Code[10])
        {
            Caption = 'Receiving Reason Code';
            Description = 'PR3.70.01';
            TableRelation = "Reason Code";
        }
        field(37002661; Farm; Text[30])
        {
            Caption = 'Farm';
            Description = 'PR3.70.01';
        }
        field(37002662; Brand; Text[30])
        {
            Caption = 'Brand';
            Description = 'PR3.70.01';
        }
        field(37002664; "Country/Region of Origin Code"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';
            TableRelation = "Country/Region";
        }
        field(37002700; "Label Unit of Measure Code"; Code[10])
        {
            Caption = 'Label Unit of Measure Code';
            TableRelation = IF (Type = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));
        }
        field(99000750; "Routing No."; Code[20])
        {
            Caption = 'Routing No.';
            TableRelation = "Routing Header";
        }
        field(99000751; "Operation No."; Code[10])
        {
            Caption = 'Operation No.';
            TableRelation = "Prod. Order Routing Line"."Operation No." WHERE(Status = FILTER(Released ..),
                                                                              "Prod. Order No." = FIELD("Prod. Order No."),
                                                                              "Routing No." = FIELD("Routing No."));
        }
        field(99000752; "Work Center No."; Code[20])
        {
            Caption = 'Work Center No.';
            TableRelation = "Work Center";
        }
        field(99000754; "Prod. Order Line No."; Integer)
        {
            Caption = 'Prod. Order Line No.';
            TableRelation = "Prod. Order Line"."Line No." WHERE(Status = FILTER(Released ..),
                                                                 "Prod. Order No." = FIELD("Prod. Order No."));
        }
        field(99000755; "Overhead Rate"; Decimal)
        {
            Caption = 'Overhead Rate';
            DecimalPlaces = 0 : 5;
        }
        field(99000759; "Routing Reference No."; Integer)
        {
            Caption = 'Routing Reference No.';
        }
    }

    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Order No.", "Order Line No.", "Posting Date")
        {
        }
        key(Key3; "Blanket Order No.", "Blanket Order Line No.")
        {
        }
        key(Key4; "Item Rcpt. Entry No.")
        {
        }
        key(Key5; "Pay-to Vendor No.")
        {
        }
        key(Key6; "Buy-from Vendor No.")
        {
        }
        key(Key7; "Document Id")
        {
        }
        key(Key37002000; Type, "No.")
        {
            Enabled = false;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        PurchDocLineComments: Record "Purch. Comment Line";
    begin
        PurchDocLineComments.SetRange("Document Type", PurchDocLineComments."Document Type"::Receipt);
        PurchDocLineComments.SetRange("No.", "Document No.");
        PurchDocLineComments.SetRange("Document Line No.", "Line No.");
        if not PurchDocLineComments.IsEmpty() then
            PurchDocLineComments.DeleteAll();
    end;

    trigger OnInsert()
    begin
        UpdateDocumentId();
    end;

    var
        Text000: Label 'Receipt No. %1:';
        Text001: Label 'The program cannot find this purchase line.';
        Currency: Record Currency;
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        DimMgt: Codeunit DimensionManagement;
        UOMMgt: Codeunit "Unit of Measure Management";
        CurrencyRead: Boolean;
        Item: Record Item;
        P800Functions: Codeunit "Process 800 Functions";

    procedure GetCurrencyCodeFromHeader(): Code[10]
    begin
        if "Document No." = PurchRcptHeader."No." then
            exit(PurchRcptHeader."Currency Code");
        if PurchRcptHeader.Get("Document No.") then
            exit(PurchRcptHeader."Currency Code");
        exit('');
    end;

    procedure ShowDimensions()
    begin
        DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo('%1 %2 %3', TableCaption(), "Document No.", "Line No."));
    end;

    procedure ShowItemTrackingLines()
    var
        ItemTrackingDocMgt: Codeunit "Item Tracking Doc. Management";
    begin
        ItemTrackingDocMgt.ShowItemTrackingForShptRcptLine(DATABASE::"Purch. Rcpt. Line", 0, "Document No.", '', 0, "Line No.");
    end;

    procedure InsertInvLineFromRcptLine(var PurchLine: Record "Purchase Line")
    var
        PurchInvHeader: Record "Purchase Header";
        PurchOrderHeader: Record "Purchase Header";
        PurchOrderLine: Record "Purchase Line";
        TempPurchLine: Record "Purchase Line" temporary;
        TransferOldExtLines: Codeunit "Transfer Old Ext. Text Lines";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        TranslationHelper: Codeunit "Translation Helper";
        PrepaymentMgt: Codeunit "Prepayment Mgt.";
        NextLineNo: Integer;
        ExtTextLine: Boolean;
        IsHandled: Boolean;
        DirectUnitCost: Decimal;
        ShouldProcessAsRegularLine: Boolean;
        ExtraChargeMgmt: Codeunit "Extra Charge Management";	
    begin
        IsHandled := false;
        OnBeforeInsertInvLineFromRcptLineProcedure(Rec, PurchLine, IsHandled);
        if IsHandled then
            exit;

        SetRange("Document No.", "Document No.");

        TempPurchLine := PurchLine;
        if PurchLine.Find('+') then
            NextLineNo := PurchLine."Line No." + 10000
        else
            NextLineNo := 10000;

        if PurchInvHeader."No." <> TempPurchLine."Document No." then
            PurchInvHeader.Get(TempPurchLine."Document Type", TempPurchLine."Document No.");

        IsHandled := false;
        OnInsertInvLineFromRcptLineOnBeforeCheckPurchLineReceiptNo(Rec, PurchLine, TempPurchLine, NextLineNo, IsHandled);
        if not IsHandled then
            if PurchLine."Receipt No." <> "Document No." then begin
                PurchLine.Init();
                PurchLine."Line No." := NextLineNo;
                PurchLine."Document Type" := TempPurchLine."Document Type";
                PurchLine."Document No." := TempPurchLine."Document No.";
                TranslationHelper.SetGlobalLanguageByCode(PurchInvHeader."Language Code");
                PurchLine.Description := StrSubstNo(Text000, "Document No.");
                TranslationHelper.RestoreGlobalLanguage();
                IsHandled := false;
                OnBeforeInsertInvLineFromRcptLineBeforeInsertTextLine(Rec, PurchLine, NextLineNo, IsHandled);
                if not IsHandled then begin
                    PurchLine.Insert();
                    OnAfterDescriptionPurchaseLineInsert(PurchLine, Rec, NextLineNo, TempPurchLine);
                    NextLineNo := NextLineNo + 10000;
                end;
            end;

        TransferOldExtLines.ClearLineNumbers();
        OnInsertInvLineFromRcptLineOnAfterTransferOldExtLinesClearLineNumbers(Rec);

        repeat
            OnInsertInvLineFromRcptLineOnBeforeCopyFromPurchRcptLine(Rec, PurchLine, TempPurchLine, NextLineNo);

            ExtTextLine := (TransferOldExtLines.GetNewLineNumber("Attached to Line No.") <> 0);

            if PurchOrderLine.Get(
                 PurchOrderLine."Document Type"::Order, "Order No.", "Order Line No.") and
               not ExtTextLine
            then begin
                if (PurchOrderHeader."Document Type" <> PurchOrderLine."Document Type"::Order) or
                   (PurchOrderHeader."No." <> PurchOrderLine."Document No.")
                then
                    PurchOrderHeader.Get(PurchOrderLine."Document Type"::Order, "Order No.");

                PrepaymentMgt.TestPurchaseOrderLineForGetRcptLines(PurchOrderLine);
                InitCurrency("Currency Code");

                if PurchInvHeader."Prices Including VAT" then begin
                    if not PurchOrderHeader."Prices Including VAT" then
                        PurchOrderLine."Direct Unit Cost" :=
                          Round(
                            PurchOrderLine."Direct Unit Cost" * (1 + PurchOrderLine."VAT %" / 100),
                            Currency."Unit-Amount Rounding Precision");
                end else
                    if PurchOrderHeader."Prices Including VAT" then
                        PurchOrderLine."Direct Unit Cost" :=
                          Round(
                            PurchOrderLine."Direct Unit Cost" / (1 + PurchOrderLine."VAT %" / 100),
                            Currency."Unit-Amount Rounding Precision");
            end else
                if ExtTextLine then begin
                    PurchOrderLine.Init();
                    PurchOrderLine."Line No." := "Order Line No.";
                    PurchOrderLine.Description := Description;
                    PurchOrderLine."Description 2" := "Description 2";
                    OnInsertInvLineFromRcptLineOnAfterAssignDescription(Rec, PurchOrderLine);
                end else
                    Error(Text001);

            CopyFromPurchRcptLine(PurchLine, PurchOrderLine, TempPurchLine, NextLineNo);

            ShouldProcessAsRegularLine := not ExtTextLine;
            OnInsertInvLineFromRcptLineOnAfterCalcShouldProcessAsRegularLine(Rec, ShouldProcessAsRegularLine);
            if ShouldProcessAsRegularLine then begin
                IsHandled := false;
                OnInsertInvLineFromRcptLineOnBeforeValidateQuantity(Rec, PurchLine, IsHandled, PurchInvHeader);
                if PurchLine."Deferral Code" <> '' then
                    PurchLine.Validate("Deferral Code");
                if not IsHandled then
                    PurchLine.Validate(Quantity, Quantity - "Quantity Invoiced");
                CalcBaseQuantities(PurchLine, "Quantity (Base)" / Quantity);

                OnInsertInvLineFromRcptLineOnAfterCalcQuantities(PurchLine, PurchOrderLine);

                IsHandled := false;
                DirectUnitCost := PurchOrderLine."Direct Unit Cost";
                OnInsertInvLineFromRcptLineOnBeforeSetDirectUnitCost(PurchLine, PurchOrderLine, DirectUnitCost);
                PurchLine.Validate("Direct Unit Cost", DirectUnitCost);
                PurchOrderLine."Line Discount Amount" :=
                  Round(
                    PurchOrderLine."Line Discount Amount" * PurchLine.Quantity / PurchOrderLine.Quantity,
                    Currency."Amount Rounding Precision");

                OnInsertInvLineFromRcptLineOnAfterRoundLineDiscountAmount(Rec, PurchLine, PurchOrderLine, Currency);

                if PurchInvHeader."Prices Including VAT" then begin
                    if not PurchOrderHeader."Prices Including VAT" then
                        PurchOrderLine."Line Discount Amount" :=
                          Round(
                            PurchOrderLine."Line Discount Amount" *
                            (1 + PurchOrderLine."VAT %" / 100), Currency."Amount Rounding Precision");
                end else
                    if PurchOrderHeader."Prices Including VAT" then
                        PurchOrderLine."Line Discount Amount" :=
                          Round(
                            PurchOrderLine."Line Discount Amount" /
                            (1 + PurchOrderLine."VAT %" / 100), Currency."Amount Rounding Precision");
                PurchLine.Validate("Line Discount Amount", PurchOrderLine."Line Discount Amount");
                PurchLine."Line Discount %" := PurchOrderLine."Line Discount %";
                OnInsertInvLineFromRcptLineOnBeforePurchLineUpdatePrePaymentAmounts(PurchLine, PurchOrderLine);
                PurchLine.UpdatePrePaymentAmounts();
                if PurchOrderLine.Quantity = 0 then
                    PurchLine.Validate("Inv. Discount Amount", 0)
                else
                    PurchLine.Validate(
                      "Inv. Discount Amount",
                      Round(
                        PurchOrderLine."Inv. Discount Amount" * PurchLine.Quantity / PurchOrderLine.Quantity,
                        Currency."Amount Rounding Precision"));
            end;

            PurchLine."Attached to Line No." :=
              TransferOldExtLines.TransferExtendedText(
                "Line No.",
                NextLineNo,
                "Attached to Line No.");
            PurchLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
            PurchLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
            PurchLine."Dimension Set ID" := "Dimension Set ID";

            if "Sales Order No." = '' then
                PurchLine."Drop Shipment" := false
            else
                PurchLine."Drop Shipment" := true;

            IsHandled := false;
            OnBeforeInsertInvLineFromRcptLine(Rec, PurchLine, PurchOrderLine, IsHandled);
            if not IsHandled then
                PurchLine.Insert();
            OnAfterInsertInvLineFromRcptLine(PurchLine, PurchOrderLine, NextLineNo, Rec);

            // P8001036
            if P800Functions.FreshProInstalled then
                ExtraChargeMgmt.CopyFromPstdReceiptToPurchLine(Rec, PurchLine);
            // P8001036

            ItemTrackingMgt.CopyHandledItemTrkgToInvLine(PurchOrderLine, PurchLine);

            NextLineNo := NextLineNo + 10000;
            if "Attached to Line No." = 0 then
                SetRange("Attached to Line No.", "Line No.");
        until (Next() = 0) or ("Attached to Line No." = 0);
    end;

    local procedure CopyFromPurchRcptLine(var PurchLine: Record "Purchase Line"; PurchOrderLine: Record "Purchase Line"; TempPurchLine: Record "Purchase Line"; NextLineNo: Integer)
    begin
        PurchLine := PurchOrderLine;
        PurchLine."Line No." := NextLineNo;
        PurchLine."Document Type" := TempPurchLine."Document Type";
        PurchLine."Document No." := TempPurchLine."Document No.";
        PurchLine."Variant Code" := "Variant Code";
        PurchLine."Location Code" := "Location Code";
        PurchLine."Quantity (Base)" := 0;
        PurchLine.Quantity := 0;
        PurchLine."Outstanding Qty. (Base)" := 0;
        PurchLine."Outstanding Quantity" := 0;
        PurchLine."Quantity Received" := 0;
        PurchLine."Qty. Received (Base)" := 0;
        PurchLine."Quantity Invoiced" := 0;
        PurchLine."Qty. Invoiced (Base)" := 0;
        // P80070933
        PurchLine."Quantity (Alt.)" := 0;
        PurchLine."Qty. Received (Alt.)" := 0;
        PurchLine."Qty. Invoiced (Alt.)" := 0;
        // P80070933
        PurchLine.Amount := 0;
        PurchLine."Amount Including VAT" := 0;
        PurchLine."Sales Order No." := '';
        PurchLine."Sales Order Line No." := 0;
        PurchLine."Drop Shipment" := false;
        PurchLine."Special Order Sales No." := '';
        PurchLine."Special Order Sales Line No." := 0;
        PurchLine."Special Order" := false;
        PurchLine."Receipt No." := "Document No.";
        PurchLine."Receipt Line No." := "Line No.";
        PurchLine."Appl.-to Item Entry" := 0;

        OnAfterCopyFromPurchRcptLine(PurchLine, Rec, TempPurchLine);
    end;

    procedure GetPurchInvLines(var TempPurchInvLine: Record "Purch. Inv. Line" temporary)
    var
        PurchInvLine: Record "Purch. Inv. Line";
        ValueItemLedgerEntries: Query "Value Item Ledger Entries";
    begin
        TempPurchInvLine.Reset();
        TempPurchInvLine.DeleteAll();

        if Type <> Type::Item then
            exit;

        ValueItemLedgerEntries.SetRange(Item_Ledg_Document_No, "Document No.");
        ValueItemLedgerEntries.SetRange(Item_Ledg_Document_Type, "Item Ledger Document Type"::"Purchase Receipt");
        ValueItemLedgerEntries.SetRange(Item_Ledg_Document_Line_No, "Line No.");
        ValueItemLedgerEntries.SetFilter(Item_Ledg_Invoice_Quantity, '<>0');
        ValueItemLedgerEntries.SetRange(Value_Entry_Type, "Cost Entry Type"::"Direct Cost");
        ValueItemLedgerEntries.SetFilter(Value_Entry_Invoiced_Qty, '<>0');
        ValueItemLedgerEntries.SetRange(Value_Entry_Doc_Type, "Item Ledger Document Type"::"Purchase Invoice");
        ValueItemLedgerEntries.Open();
        while ValueItemLedgerEntries.Read() do
            if PurchInvLine.Get(ValueItemLedgerEntries.Value_Entry_Doc_No, ValueItemLedgerEntries.Value_Entry_Doc_Line_No) then begin
                TempPurchInvLine.Init();
                TempPurchInvLine := PurchInvLine;
                if TempPurchInvLine.Insert() then;
            end;
    end;

    procedure CalcReceivedPurchNotReturned(var RemainingQty: Decimal; var RevUnitCostLCY: Decimal; ExactCostReverse: Boolean)
    var
        RemainingQtyAlt: Decimal;
    begin
        // P80096141 - Original signature 
        CalcReceivedPurchNotReturned(RemainingQty, RemainingQtyAlt, RevUnitCostLCY, ExactCostReverse);
    end;

    procedure CalcReceivedPurchNotReturned(var RemainingQty: Decimal; var RemainingQtyAlt: Decimal; var RevUnitCostLCY: Decimal; ExactCostReverse: Boolean)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        TotalCostLCY: Decimal;
        TotalQtyBase: Decimal;
    begin
        // P8000466A - added parameter to return RemainingQtyAlt
        RemainingQty := 0;
        RemainingQtyAlt := 0; // P8000466A
        if (Type <> Type::Item) or (Quantity <= 0) then begin
            RevUnitCostLCY := "Unit Cost (LCY)";
            exit;
        end;

        RevUnitCostLCY := 0;
        FilterPstdDocLnItemLedgEntries(ItemLedgEntry);
        if ItemLedgEntry.FindSet() then
            repeat
                RemainingQty := RemainingQty + ItemLedgEntry."Remaining Quantity";
                RemainingQtyAlt := RemainingQtyAlt + ItemLedgEntry."Remaining Quantity (Alt.)"; // P8000466A
                if ExactCostReverse then begin
                    ItemLedgEntry.CalcFields("Cost Amount (Expected)", "Cost Amount (Actual)");
                    TotalCostLCY :=
                      TotalCostLCY + ItemLedgEntry."Cost Amount (Expected)" + ItemLedgEntry."Cost Amount (Actual)";
                    TotalQtyBase := TotalQtyBase + ItemLedgEntry.GetCostingQty; // P8000466A
                end;
            until ItemLedgEntry.Next() = 0;

        if ExactCostReverse and ((RemainingQty <> 0) or (RemainingQtyAlt <> 0)) and  // P8000466A
          (TotalQtyBase <> 0)                                                        // P8000466A
        then begin                                                                   // P8000466A
            RevUnitCostLCY := Abs(TotalCostLCY / TotalQtyBase);                        // P8000466A
            if not CostInAlternateUnits then                                           // P8000466A
                RevUnitCostLCY := RevUnitCostLCY * "Qty. per Unit of Measure"            // P8000466A
        end else                                                                     // P8000466A
            RevUnitCostLCY := "Unit Cost (LCY)";

        RemainingQty := CalcQty(RemainingQty);
    end;

    local procedure CalcQty(QtyBase: Decimal): Decimal
    begin
        if "Qty. per Unit of Measure" = 0 then
            exit(QtyBase);
        exit(Round(QtyBase / "Qty. per Unit of Measure", UOMMgt.QtyRndPrecision()));
    end;

    procedure FilterPstdDocLnItemLedgEntries(var ItemLedgEntry: Record "Item Ledger Entry")
    begin
        ItemLedgEntry.Reset();
        ItemLedgEntry.SetCurrentKey("Document No.");
        ItemLedgEntry.SetRange("Document No.", "Document No.");
        ItemLedgEntry.SetRange("Document Type", ItemLedgEntry."Document Type"::"Purchase Receipt");
        ItemLedgEntry.SetRange("Document Line No.", "Line No.");
    end;

    procedure ShowItemPurchInvLines()
    var
        TempPurchInvLine: Record "Purch. Inv. Line" temporary;
    begin
        if Type = Type::Item then begin
            GetPurchInvLines(TempPurchInvLine);
            PAGE.RunModal(PAGE::"Posted Purchase Invoice Lines", TempPurchInvLine);
        end;
    end;

    local procedure InitCurrency(CurrencyCode: Code[10])
    begin
        if (Currency.Code = CurrencyCode) and CurrencyRead then
            exit;

        if CurrencyCode <> '' then
            Currency.Get(CurrencyCode)
        else
            Currency.InitRoundingPrecision();
        CurrencyRead := true;
    end;

    procedure ShowLineComments()
    var
        PurchCommentLine: Record "Purch. Comment Line";
    begin
        PurchCommentLine.ShowComments(PurchCommentLine."Document Type"::Receipt.AsInteger(), "Document No.", "Line No.");
    end;

    procedure AltQtyEntriesExist(): Boolean
    var
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // PR3.60
        AltQtyEntry.SetRange("Table No.", DATABASE::"Purch. Rcpt. Line");
        AltQtyEntry.SetRange("Document No.", "Document No.");
        AltQtyEntry.SetRange("Source Line No.", "Line No.");
        exit(AltQtyEntry.Find('-'));
        // PR3.60
    end;

    procedure ShowExtraCharges()
    var
        PostedExtraCharge: Record "Posted Document Extra Charge";
        PostedExtraCharges: Page "Pstd. Doc. Line Extra Charges";
    begin
        // PR3.70.01
        TestField("No.");
        TestField("Line No.");
        TestField(Type, Type::Item);
        PostedExtraCharge.SetRange("Table ID", DATABASE::"Purch. Rcpt. Line");
        PostedExtraCharge.SetRange("Document No.", "Document No.");
        PostedExtraCharge.SetRange("Line No.", "Line No.");
        PostedExtraCharges.SetTableView(PostedExtraCharge);
        PostedExtraCharges.RunModal;
        // PR3.70.01
    end;

    local procedure GetItem()
    begin
        // P8000466A
        TestField("No.");
        if "No." <> Item."No." then
            Item.Get("No.");
    end;

    procedure CostInAlternateUnits(): Boolean
    begin
        // P8000466A
        if (Type <> Type::Item) or ("No." = '') then
            exit(false);
        GetItem;
        exit(Item.CostInAlternateUnits);
    end;

    procedure GetCostingQtyBase(): Decimal
    begin
        // P8000971
        if CostInAlternateUnits then
            exit("Quantity (Alt.)");
        exit("Quantity (Base)");
    end;

    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20])
    begin
        DimMgt.GetShortcutDimensions("Dimension Set ID", ShortcutDimCode);
    end;

    procedure InitFromPurchLine(PurchRcptHeader: Record "Purch. Rcpt. Header"; PurchLine: Record "Purchase Line")
    var
        Factor: Decimal;
    begin
        Init();
        TransferOverReceiptCode(PurchLine);
        TransferFields(PurchLine);
        if ("No." = '') and HasTypeToFillMandatoryFields() then
            Type := Type::" ";
        "Posting Date" := PurchRcptHeader."Posting Date";
        "Document No." := PurchRcptHeader."No.";
        Quantity := PurchLine."Qty. to Receive";
        "Quantity (Base)" := PurchLine."Qty. to Receive (Base)";
        if Abs(PurchLine."Qty. to Invoice") > Abs(PurchLine."Qty. to Receive") then begin
            "Quantity Invoiced" := PurchLine."Qty. to Receive";
            "Qty. Invoiced (Base)" := PurchLine."Qty. to Receive (Base)";
        end else begin
            "Quantity Invoiced" := PurchLine."Qty. to Invoice";
            "Qty. Invoiced (Base)" := PurchLine."Qty. to Invoice (Base)";
        end;
        // P8004516
        "Quantity (Alt.)" := PurchLine."Qty. to Receive (Alt.)";
        if Abs(PurchLine."Qty. to Invoice") > Abs(PurchLine."Qty. to Receive") then
            "Qty. Invoiced (Alt.)" := PurchLine."Qty. to Receive (Alt.)"
        else
            "Qty. Invoiced (Alt.)" := PurchLine."Qty. to Invoice (Alt.)";
        // P8004516
        "Qty. Rcd. Not Invoiced" := Quantity - "Quantity Invoiced";
        if PurchLine."Document Type" = PurchLine."Document Type"::Order then begin
            "Order No." := PurchLine."Document No.";
            "Order Line No." := PurchLine."Line No.";
        end;
        if (PurchLine.Quantity <> 0) and ("Job No." <> '') then begin
            Factor := PurchLine."Qty. to Receive" / PurchLine.Quantity;
            if Factor <> 1 then
                UpdateJobPrices(Factor);
        end;

        OnAfterInitFromPurchLine(PurchRcptHeader, PurchLine, Rec);
    end;

    procedure FormatType(): Text
    var
        PurchaseLine: Record "Purchase Line";
    begin
        if Type = Type::" " then
            exit(PurchaseLine.FormatType());

        exit(Format(Type));
    end;

    local procedure UpdateJobPrices(Factor: Decimal)
    begin
        "Job Total Price" :=
          Round("Job Total Price" * Factor, Currency."Amount Rounding Precision");
        "Job Total Price (LCY)" :=
          Round("Job Total Price (LCY)" * Factor, Currency."Amount Rounding Precision");
        "Job Line Amount" :=
          Round("Job Line Amount" * Factor, Currency."Amount Rounding Precision");
        "Job Line Amount (LCY)" :=
          Round("Job Line Amount (LCY)" * Factor, Currency."Amount Rounding Precision");
        "Job Line Discount Amount" :=
          Round("Job Line Discount Amount" * Factor, Currency."Amount Rounding Precision");
        "Job Line Disc. Amount (LCY)" :=
          Round("Job Line Disc. Amount (LCY)" * Factor, Currency."Amount Rounding Precision");
    end;

    local procedure CalcBaseQuantities(var PurchaseLine: Record "Purchase Line"; QtyFactor: Decimal)
    begin
        PurchaseLine."Quantity (Base)" :=
          Round(PurchaseLine.Quantity * QtyFactor, UOMMgt.QtyRndPrecision());
        PurchaseLine."Outstanding Qty. (Base)" :=
          Round(PurchaseLine."Outstanding Quantity" * QtyFactor, UOMMgt.QtyRndPrecision());
        PurchaseLine."Qty. to Receive (Base)" :=
          Round(PurchaseLine."Qty. to Receive" * QtyFactor, UOMMgt.QtyRndPrecision());
        PurchaseLine."Qty. Received (Base)" :=
          Round(PurchaseLine."Quantity Received" * QtyFactor, UOMMgt.QtyRndPrecision());
        PurchaseLine."Qty. Rcd. Not Invoiced (Base)" :=
          Round(PurchaseLine."Qty. Rcd. Not Invoiced" * QtyFactor, UOMMgt.QtyRndPrecision());
        PurchaseLine."Qty. to Invoice (Base)" :=
          Round(PurchaseLine."Qty. to Invoice" * QtyFactor, UOMMgt.QtyRndPrecision());
        PurchaseLine."Qty. Invoiced (Base)" :=
          Round(PurchaseLine."Quantity Invoiced" * QtyFactor, UOMMgt.QtyRndPrecision());
        PurchaseLine."Return Qty. to Ship (Base)" :=
          Round(PurchaseLine."Return Qty. to Ship" * QtyFactor, UOMMgt.QtyRndPrecision());
        PurchaseLine."Return Qty. Shipped (Base)" :=
          Round(PurchaseLine."Return Qty. Shipped" * QtyFactor, UOMMgt.QtyRndPrecision());
        PurchaseLine."Ret. Qty. Shpd Not Invd.(Base)" :=
          Round(PurchaseLine."Return Qty. Shipped Not Invd." * QtyFactor, UOMMgt.QtyRndPrecision());
    end;

    local procedure GetFieldCaption(FieldNumber: Integer): Text[100]
    var
        "Field": Record "Field";
    begin
        Field.Get(DATABASE::"Purch. Rcpt. Line", FieldNumber);
        exit(Field."Field Caption");
    end;

    procedure GetCaptionClass(FieldNumber: Integer): Text[80]
    begin
        case FieldNumber of
            FieldNo("No."):
                exit(StrSubstNo('3,%1', GetFieldCaption(FieldNumber)));
        end;
    end;

    procedure HasTypeToFillMandatoryFields(): Boolean
    begin
        exit(Type <> Type::" ");
    end;

    local procedure TransferOverReceiptCode(var PurchLine: Record "Purchase Line")
    begin
        "Over-Receipt Code 2" := PurchLine."Over-Receipt Code";
    end;

    local procedure UpdateDocumentId()
    var
        ParentPurchRcptHeader: Record "Purch. Rcpt. Header";
    begin
        if "Document No." = '' then begin
            Clear("Document Id");
            exit;
        end;

        if not ParentPurchRcptHeader.Get("Document No.") then
            exit;

        "Document Id" := ParentPurchRcptHeader.SystemId;
    end;

    local procedure UpdateDocumentNo()
    var
        ParentPurchRcptHeader: Record "Purch. Rcpt. Header";
    begin
        if IsNullGuid(Rec."Document Id") then begin
            Clear(Rec."Document No.");
            exit;
        end;

        if not ParentPurchRcptHeader.GetBySystemId(Rec."Document Id") then
            exit;

        "Document No." := ParentPurchRcptHeader."No.";
    end;

    procedure UpdateReferencedIds()
    begin
        UpdateDocumentId();
    end;

    procedure SetSecurityFilterOnRespCenter()
    var
        UserSetupMgt: Codeunit "User Setup Management";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSetSecurityFilterOnRespCenter(Rec, IsHandled);
        if IsHandled then
            exit;

        if UserSetupMgt.GetPurchasesFilter() <> '' then begin
            FilterGroup(2);
            SetRange("Responsibility Center", UserSetupMgt.GetPurchasesFilter());
            FilterGroup(0);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromPurchRcptLine(var PurchaseLine: Record "Purchase Line"; PurchRcptLine: Record "Purch. Rcpt. Line"; var TempPurchLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitFromPurchLine(PurchRcptHeader: Record "Purch. Rcpt. Header"; PurchLine: Record "Purchase Line"; var PurchRcptLine: Record "Purch. Rcpt. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDescriptionPurchaseLineInsert(var PurchLine: Record "Purchase Line"; PurchRcptLine: Record "Purch. Rcpt. Line"; var NextLineNo: Integer; var TempPurchaseLine: Record "Purchase Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertInvLineFromRcptLine(var PurchLine: Record "Purchase Line"; PurchOrderLine: Record "Purchase Line"; var NextLineNo: Integer; PurchRcptLine: Record "Purch. Rcpt. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertInvLineFromRcptLine(var PurchRcptLine: Record "Purch. Rcpt. Line"; var PurchLine: Record "Purchase Line"; PurchOrderLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertInvLineFromRcptLineProcedure(var PurchRcptLine: Record "Purch. Rcpt. Line"; var PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertInvLineFromRcptLineBeforeInsertTextLine(var PurchRcptLine: Record "Purch. Rcpt. Line"; var PurchLine: Record "Purchase Line"; var NextLineNo: Integer; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertInvLineFromRcptLineOnAfterAssignDescription(var PurchRcptLine: Record "Purch. Rcpt. Line"; var PurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertInvLineFromRcptLineOnAfterCalcShouldProcessAsRegularLine(var PurchRcptLine: Record "Purch. Rcpt. Line"; var ShouldProcessAsRegularLine: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertInvLineFromRcptLineOnAfterCalcQuantities(var PurchaseLine: Record "Purchase Line"; PurchaseOrderLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertInvLineFromRcptLineOnBeforeCheckPurchLineReceiptNo(var PurchRcptLine: Record "Purch. Rcpt. Line"; var PurchLine: Record "Purchase Line"; var TempPurchLine: Record "Purchase Line"; var NextLineNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertInvLineFromRcptLineOnBeforeCopyFromPurchRcptLine(var PurchRcptLine: Record "Purch. Rcpt. Line"; var PurchLine: Record "Purchase Line"; TempPurchLine: Record "Purchase Line"; var NextLineNo: Integer);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertInvLineFromRcptLineOnBeforeSetDirectUnitCost(var PurchaseLine: Record "Purchase Line"; PurchaseOrderLine: Record "Purchase Line"; var DirectUnitCost: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertInvLineFromRcptLineOnBeforeValidateQuantity(PurchRcptLine: Record "Purch. Rcpt. Line"; var PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean; var PurchInvHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertInvLineFromRcptLineOnBeforePurchLineUpdatePrePaymentAmounts(var PurchaseLine: Record "Purchase Line"; PurchOrderLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertInvLineFromRcptLineOnAfterTransferOldExtLinesClearLineNumbers(var PurchRcptLine: Record "Purch. Rcpt. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertInvLineFromRcptLineOnAfterRoundLineDiscountAmount(var PurchRcptLine: Record "Purch. Rcpt. Line"; var PurchaseLine: Record "Purchase Line"; var PurchaseOrderLine: Record "Purchase Line"; Currency: Record Currency)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetSecurityFilterOnRespCenter(var PurchRcptLine: Record "Purch. Rcpt. Line"; var IsHandled: Boolean)
    begin
    end;
}

