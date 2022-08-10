table 113 "Sales Invoice Line"
{
    // PR1.00
    //   New Process 800 fields
    //     Original Quantity
    // 
    // PR3.60
    //   Add field for alternate quantities
    //   Sales Pricing
    // 
    // PR3.70
    //   Off-Invoice Allowances
    //   Add Key - Type,No. (Group - LOT CTRL)
    // 
    // PR3.70.01
    //   Add Fields
    //     Comment
    // 
    // PR3.70.02
    //   Add Function
    //     GetCostingQtyBase
    // 
    // PR3.70.03
    //   Added Fields
    //     Promo/Rebate Amount
    //     Commission Amount
    //     Accruals Included in Price
    //     Accruals Excluded from Price
    //     Accrual Amount (Price)
    // 
    // PR3.70.07
    // P8000143A, Myers Nissi, Jack Reynolds, 18 NOV 04
    //   Add Container as option for Type field
    // 
    // PR4.00.05
    // P8000440A, VerticalSoft, Jack Reynolds, 29 JAN 07
    //   Add fields for Line Discount Type and Line Discount Unit Amount
    // 
    // PR4.00.06
    // P8000464A, VerticalSoft, Don Bresee, 9 APR 07
    //   Add fields/keys for accrual dates
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 31 JUL 07
    //   Support alternate quantity for shipped not returned
    // 
    // PRW16.00.01
    // P8000694, VerticalSoft, Jack Reynolds, 04 MAY 09
    //   Change name of Accrual fields
    // 
    // PRW16.00.04
    // P8000885, VerticalSoft, Ron Davidson, 20 DEC 10
    //   Added three new fields for Sales Contracts.
    // 
    // PRW16.00.05
    // P8000921, Columbus IT, Don Bresee, 07 APR 11
    //   Add Delivered Pricing fields
    // 
    // P8000931, Columbus IT, Jack Reynolds, 20 APR 11
    //   Support for Supply Chain Groups
    // 
    // P8000981, Columbus IT, Don Bresee, 20 SEP 11
    //   Add "GetPricingQty" routine
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality
    // 
    // PRW18.00.02
    // P8002744, To-Increase, Jack Reynolds, 30 Sep 15
    //   Support for accrual payment documents
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 9 NOV 15
    //   NAV 2016 refactoring
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018

    Caption = 'Sales Invoice Line';
    DrillDownPageID = "Posted Sales Invoice Lines";
    LookupPageID = "Posted Sales Invoice Lines";
    Permissions = TableData "Item Ledger Entry" = r,
                  TableData "Value Entry" = r;

    fields
    {
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
            AutoFormatExpression = GetCurrencyCode;
            AutoFormatType = 2;
            Caption = 'Line Discount Unit Amount';
        }
        field(37002050; "Unit Price (FOB)"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode;
            AutoFormatType = 2;
            CaptionClass = GetCaptionClass(FieldNo("Unit Price (FOB)"));
            Caption = 'Unit Price (FOB)';
        }
        field(37002051; "Unit Price (Freight)"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode;
            AutoFormatType = 2;
            CaptionClass = GetCaptionClass(FieldNo("Unit Price (Freight)"));
            Caption = 'Unit Price (Freight)';
        }
        field(37002052; "Line Amount (Freight)"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode;
            AutoFormatType = 1;
            BlankZero = true;
            CaptionClass = GetCaptionClass(FieldNo("Line Amount (Freight)"));
            Caption = 'Line Amount (Freight)';
            Editable = false;
        }
        field(37002060; "Delivery Route No."; Code[20])
        {
            Caption = 'Delivery Route No.';
            Description = 'PR3.60';
            TableRelation = "Delivery Route";
        }
        field(37002061; "Delivery Stop No."; Code[20])
        {
            Caption = 'Delivery Stop No.';
            Description = 'PR3.60';
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
        field(37002093; "Total Net Weight"; Decimal)
        {
            Caption = 'Total Net Weight';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.60';
        }
        field(37002120; "Promo/Rebate Amount (LCY)"; Decimal)
        {
            CalcFormula = - Sum("Accrual Ledger Entry".Amount WHERE("Accrual Plan Type" = CONST(Sales),
                                                                    "Entry Type" = CONST(Accrual),
                                                                    "Plan Type" = CONST("Promo/Rebate"),
                                                                    "Source Document Type" = CONST(Invoice),
                                                                    "Source Document No." = FIELD("Document No."),
                                                                    "Source Document Line No." = FIELD("Line No.")));
            Caption = 'Promo/Rebate Amount (LCY)';
            Description = 'PR3.70.03';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002121; "Commission Amount (LCY)"; Decimal)
        {
            CalcFormula = - Sum("Accrual Ledger Entry".Amount WHERE("Accrual Plan Type" = CONST(Sales),
                                                                    "Entry Type" = CONST(Accrual),
                                                                    "Plan Type" = CONST(Commission),
                                                                    "Source Document Type" = CONST(Invoice),
                                                                    "Source Document No." = FIELD("Document No."),
                                                                    "Source Document Line No." = FIELD("Line No.")));
            Caption = 'Commission Amount (LCY)';
            Description = 'PR3.70.03';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002122; "Acc. Incl. in Price (LCY)"; Decimal)
        {
            CalcFormula = - Sum("Accrual Ledger Entry".Amount WHERE("Accrual Plan Type" = CONST(Sales),
                                                                    "Entry Type" = CONST(Accrual),
                                                                    "Price Impact" = CONST("Include in Price"),
                                                                    "Source Document Type" = CONST(Invoice),
                                                                    "Source Document No." = FIELD("Document No."),
                                                                    "Source Document Line No." = FIELD("Line No.")));
            Caption = 'Acc. Incl. in Price (LCY)';
            Description = 'PR3.70.03';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002123; "Acc. Excl. from Price (LCY)"; Decimal)
        {
            CalcFormula = - Sum("Accrual Ledger Entry".Amount WHERE("Accrual Plan Type" = CONST(Sales),
                                                                    "Entry Type" = CONST(Accrual),
                                                                    "Price Impact" = CONST("Exclude from Price"),
                                                                    "Source Document Type" = CONST(Invoice),
                                                                    "Source Document No." = FIELD("Document No."),
                                                                    "Source Document Line No." = FIELD("Line No.")));
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
        field(37002125; "Accrual Posting Date"; Date)
        {
            Caption = 'Accrual Posting Date';
        }
        field(37002126; "Accrual Order Date"; Date)
        {
            Caption = 'Accrual Order Date';
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
        }
        field(37002129; "Accrual Source Doc. Type"; Option)
        {
            Caption = 'Accrual Source Doc. Type';
            OptionCaption = 'None,Shipment,Receipt,Invoice,Credit Memo';
            OptionMembers = "None",Shipment,Receipt,Invoice,"Credit Memo";
        }
        field(37002130; "Accrual Source Doc. No."; Code[20])
        {
            Caption = 'Accrual Source Doc. No.';
        }
        field(37002131; "Accrual Source Doc. Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Accrual Source Doc. Line No.';
        }
        field(37002132; "Scheduled Accrual No."; Code[10])
        {
            Caption = 'Scheduled Accrual No.';
        }
        field(37002660; Comment; Text[30])
        {
            Caption = 'Comment';
            Description = 'PR3.70.01';
        }
        field(37002762; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            Description = 'PRW16.00.04';
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
        field(2; "Sell-to Customer No."; Code[20])
        {
            Caption = 'Sell-to Customer No.';
            Editable = false;
            TableRelation = Customer;
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "Sales Invoice Header";
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(5; Type; Enum "Sales Line Type")
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
            IF (Type = CONST(Resource)) Resource
            ELSE
            IF (Type = CONST("Fixed Asset")) "Fixed Asset"
            ELSE
            IF (Type = CONST("Charge (Item)")) "Item Charge";
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
        field(10; "Shipment Date"; Date)
        {
            Caption = 'Shipment Date';
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
        field(22; "Unit Price"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 2;
            CaptionClass = GetCaptionClass(FieldNo("Unit Price"));
            Caption = 'Unit Price';
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
        field(28; "Line Discount Amount"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            Caption = 'Line Discount Amount';
        }
        field(29; Amount; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            Caption = 'Amount';
        }
        field(30; "Amount Including VAT"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            Caption = 'Amount Including VAT';
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
        field(42; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            TableRelation = "Customer Price Group";
        }
        field(45; "Job No."; Code[20])
        {
            Caption = 'Job No.';
            TableRelation = Job;
        }
        field(52; "Work Type Code"; Code[10])
        {
            Caption = 'Work Type Code';
            TableRelation = "Work Type";
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
        field(65; "Order No."; Code[20])
        {
            Caption = 'Order No.';
        }
        field(66; "Order Line No."; Integer)
        {
            Caption = 'Order Line No.';
        }
        field(68; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            Editable = false;
            TableRelation = Customer;
        }
        field(69; "Inv. Discount Amount"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            Caption = 'Inv. Discount Amount';
        }
        field(73; "Drop Shipment"; Boolean)
        {
            AccessByPermission = TableData "Drop Shpt. Post. Buffer" = R;
            Caption = 'Drop Shipment';
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
            TableRelation = "Sales Invoice Line"."Line No." WHERE("Document No." = FIELD("Document No."));
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
        field(88; "VAT Clause Code"; Code[20])
        {
            Caption = 'VAT Clause Code';
            TableRelation = "VAT Clause";
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
        field(97; "Blanket Order No."; Code[20])
        {
            Caption = 'Blanket Order No.';
            TableRelation = "Sales Header"."No." WHERE("Document Type" = CONST("Blanket Order"));
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(98; "Blanket Order Line No."; Integer)
        {
            Caption = 'Blanket Order Line No.';
            TableRelation = "Sales Line"."Line No." WHERE("Document Type" = CONST("Blanket Order"),
                                                           "Document No." = FIELD("Blanket Order No."));
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(99; "VAT Base Amount"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            Caption = 'VAT Base Amount';
            Editable = false;
        }
        field(100; "Unit Cost"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
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
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            CaptionClass = GetCaptionClass(FieldNo("Line Amount"));
            Caption = 'Line Amount';
        }
        field(104; "VAT Difference"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            Caption = 'VAT Difference';
        }
        field(106; "VAT Identifier"; Code[20])
        {
            Caption = 'VAT Identifier';
            Editable = false;
        }
        field(107; "IC Partner Ref. Type"; Enum "IC Partner Reference Type")
        {
            Caption = 'IC Partner Ref. Type';
        }
        field(108; "IC Partner Reference"; Code[20])
        {
            Caption = 'IC Partner Reference';
        }
        field(123; "Prepayment Line"; Boolean)
        {
            Caption = 'Prepayment Line';
            Editable = false;
        }
        field(130; "IC Partner Code"; Code[20])
        {
            Caption = 'IC Partner Code';
            TableRelation = "IC Partner";
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
        field(145; "Pmt. Discount Amount"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            Caption = 'Pmt. Discount Amount';
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
        }
        field(1001; "Job Task No."; Code[20])
        {
            Caption = 'Job Task No.';
            Editable = false;
            TableRelation = "Job Task"."Job Task No." WHERE("Job No." = FIELD("Job No."));
        }
        field(1002; "Job Contract Entry No."; Integer)
        {
            Caption = 'Job Contract Entry No.';
            Editable = false;
        }
        field(1700; "Deferral Code"; Code[10])
        {
            Caption = 'Deferral Code';
            TableRelation = "Deferral Template"."Deferral Code";
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
        field(5600; "FA Posting Date"; Date)
        {
            Caption = 'FA Posting Date';
        }
        field(5602; "Depreciation Book Code"; Code[10])
        {
            Caption = 'Depreciation Book Code';
            TableRelation = "Depreciation Book";
        }
        field(5605; "Depr. until FA Posting Date"; Boolean)
        {
            Caption = 'Depr. until FA Posting Date';
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
#if not CLEAN17
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
#if not CLEAN17
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
#if not CLEAN17
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
#if not CLEAN17
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
        field(5811; "Appl.-from Item Entry"; Integer)
        {
            AccessByPermission = TableData Item = R;
            Caption = 'Appl.-from Item Entry';
            MinValue = 0;
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
        field(7001; "Allow Line Disc."; Boolean)
        {
            Caption = 'Allow Line Disc.';
            InitValue = true;
        }
        field(7002; "Customer Disc. Group"; Code[20])
        {
            Caption = 'Customer Disc. Group';
            TableRelation = "Customer Discount Group";
        }
        field(7004; "Price description"; Text[80])
        {
            Caption = 'Price description';
        }
        field(10000; "Package Tracking No."; Text[30])
        {
            Caption = 'Package Tracking No.';
        }
        field(10001; "Retention Attached to Line No."; Integer)
        {
            Caption = 'Retention Attached to Line No.';
        }
        field(10002; "Retention VAT %"; Decimal)
        {
            Caption = 'Retention VAT %';
            AutoFormatType = 2;	    
        }
    }

    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Blanket Order No.", "Blanket Order Line No.")
        {
        }
        key(Key3; "Sell-to Customer No.")
        {
        }
        key(Key4; "Sell-to Customer No.", Type, "Document No.")
        {
            Enabled = false;
            MaintainSQLIndex = false;
        }
        key(Key5; "Shipment No.", "Shipment Line No.")
        {
        }
        key(Key6; "Job Contract Entry No.")
        {
        }
        key(Key7; "Bill-to Customer No.")
        {
        }
        key(Key8; "Price ID", "Bill-to Customer No.", Type, "No.", "Shipment Date")
        {
            SumIndexFields = "Quantity (Base)", "Quantity (Alt.)";
        }
        key(Key9; Type, "Shipment Date", "Delivery Route No.", "Delivery Stop No.")
        {
            SumIndexFields = "Amount Including VAT", Quantity, "Total Net Weight";
        }
        key(Key10; Type, "No.")
        {
            Enabled = false;
        }
        key(Key11; "Accrual Posting Date", "Bill-to Customer No.", "Sell-to Customer No.", Type, "Document No.")
        {
        }
        key(Key12; "Accrual Order Date", "Bill-to Customer No.", "Sell-to Customer No.", Type, "Document No.")
        {
            Enabled = false;
        }
        key(Key13; "Order No.", "Order Line No.", "Posting Date")
        {
        }
        key(Key14; "Document No.", "Location Code")
        {
            MaintainSQLIndex = false;
            SumIndexFields = Amount, "Amount Including VAT", "Inv. Discount Amount";
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; "No.", Description, "Line Amount", "Price description", Quantity, "Unit of Measure Code")
        {
        }
    }

    trigger OnDelete()
    var
        SalesDocLineComments: Record "Sales Comment Line";
        PostedDeferralHeader: Record "Posted Deferral Header";
    begin
        SalesDocLineComments.SetRange("Document Type", SalesDocLineComments."Document Type"::"Posted Invoice");
        SalesDocLineComments.SetRange("No.", "Document No.");
        SalesDocLineComments.SetRange("Document Line No.", "Line No.");
        if not SalesDocLineComments.IsEmpty() then
            SalesDocLineComments.DeleteAll();

        PostedDeferralHeader.DeleteHeader(
            "Deferral Document Type"::Sales.AsInteger(), '', '',
            SalesDocLineComments."Document Type"::"Posted Invoice".AsInteger(), "Document No.", "Line No.");
    end;

    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Currency: Record Currency;
        DimMgt: Codeunit DimensionManagement;
        UOMMgt: Codeunit "Unit of Measure Management";
        Item: Record Item;
        DeferralUtilities: Codeunit "Deferral Utilities";
        PriceDescriptionTxt: Label 'x%1 (%2%3/%4)', Locked = true;
        PriceDescriptionWithLineDiscountTxt: Label 'x%1 (%2%3/%4) - %5%', Locked = true;

    procedure GetCurrencyCode(): Code[10]
    begin
        GetHeader;
        exit(SalesInvoiceHeader."Currency Code");
    end;

    procedure ShowDimensions()
    begin
        DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo('%1 %2 %3', TableCaption, "Document No.", "Line No."));
    end;

    procedure ShowItemTrackingLines()
    var
        ItemTrackingDocMgt: Codeunit "Item Tracking Doc. Management";
    begin
        ItemTrackingDocMgt.ShowItemTrackingForInvoiceLine(RowID1);
    end;

    procedure CalcVATAmountLines(SalesInvHeader: Record "Sales Invoice Header"; var TempVATAmountLine: Record "VAT Amount Line" temporary)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalcVATAmountLines(Rec, SalesInvHeader, TempVATAmountLine, IsHandled);
        if IsHandled then
            exit;

        TempVATAmountLine.DeleteAll();
        SetRange("Document No.", SalesInvHeader."No.");
        if Find('-') then
            repeat
                TempVATAmountLine.Init();
                TempVATAmountLine.CopyFromSalesInvLine(Rec);
                TempVATAmountLine.InsertLine;
            until Next() = 0;
    end;

    procedure GetLineAmountExclVAT(): Decimal
    begin
        GetHeader;
        if not SalesInvoiceHeader."Prices Including VAT" then
            exit("Line Amount");

        exit(Round("Line Amount" / (1 + "VAT %" / 100), Currency."Amount Rounding Precision"));
    end;

    procedure GetLineAmountInclVAT(): Decimal
    begin
        GetHeader;
        if SalesInvoiceHeader."Prices Including VAT" then
            exit("Line Amount");

        exit(Round("Line Amount" * (1 + "VAT %" / 100), Currency."Amount Rounding Precision"));
    end;

    local procedure GetHeader()
    begin
        if SalesInvoiceHeader."No." = "Document No." then
            exit;
        if not SalesInvoiceHeader.Get("Document No.") then
            SalesInvoiceHeader.Init();

        if SalesInvoiceHeader."Currency Code" = '' then
            Currency.InitRoundingPrecision
        else
            if not Currency.Get(SalesInvoiceHeader."Currency Code") then
                Currency.InitRoundingPrecision;
    end;

    local procedure GetFieldCaption(FieldNumber: Integer): Text[100]
    var
        "Field": Record "Field";
    begin
        Field.Get(DATABASE::"Sales Invoice Line", FieldNumber);
        exit(Field."Field Caption");
    end;

    procedure GetCaptionClass(FieldNumber: Integer): Text[80]
    begin
        GetHeader;
        case FieldNumber of
            FieldNo("No."):
                exit(StrSubstNo('3,%1', GetFieldCaption(FieldNumber)));
            else begin
                    if SalesInvoiceHeader."Prices Including VAT" then
                        exit('2,1,' + GetFieldCaption(FieldNumber));
                    exit('2,0,' + GetFieldCaption(FieldNumber));
                end
        end;
    end;

    procedure RowID1(): Text[250]
    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        exit(ItemTrackingMgt.ComposeRowID(DATABASE::"Sales Invoice Line",
            0, "Document No.", '', 0, "Line No."));
    end;

    procedure GetSalesShptLines(var TempSalesShptLine: Record "Sales Shipment Line" temporary)
    var
        SalesShptLine: Record "Sales Shipment Line";
        ItemLedgEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
    begin
        TempSalesShptLine.Reset();
        TempSalesShptLine.DeleteAll();

        if Type <> Type::Item then
            exit;

        FilterPstdDocLineValueEntries(ValueEntry);
        if ValueEntry.FindSet then
            repeat
                ItemLedgEntry.Get(ValueEntry."Item Ledger Entry No.");
                if ItemLedgEntry."Document Type" = ItemLedgEntry."Document Type"::"Sales Shipment" then
                    if SalesShptLine.Get(ItemLedgEntry."Document No.", ItemLedgEntry."Document Line No.") then begin
                        TempSalesShptLine.Init();
                        TempSalesShptLine := SalesShptLine;
                        if TempSalesShptLine.Insert() then;
                    end;
            until ValueEntry.Next() = 0;
    end;

    procedure CalcShippedSaleNotReturned(var ShippedQtyNotReturned: Decimal; var RevUnitCostLCY: Decimal; ExactCostReverse: Boolean)
    var
        ShippedQtyNotReturnedAlt: Decimal;
    begin
        // P80096141 - Original signature
        CalcShippedSaleNotReturned(ShippedQtyNotReturned, ShippedQtyNotReturnedAlt, RevUnitCostLCY, ExactCostReverse);
    end;

    procedure CalcShippedSaleNotReturned(var ShippedQtyNotReturned: Decimal; var ShippedQtyNotReturnedAlt: Decimal; var RevUnitCostLCY: Decimal; ExactCostReverse: Boolean)
    var
        TempItemLedgEntry: Record "Item Ledger Entry" temporary;
        TotalCostLCY: Decimal;
        TotalQtyBase: Decimal;
    begin
        // P8000466A - added parameter to return ShippedQtyNotReturnedAlt
        ShippedQtyNotReturned := 0;
        ShippedQtyNotReturnedAlt := 0; // P8000466A
        if (Type <> Type::Item) or (Quantity <= 0) then begin
            RevUnitCostLCY := "Unit Cost (LCY)";
            exit;
        end;

        RevUnitCostLCY := 0;
        GetItemLedgEntries(TempItemLedgEntry, false);
        if TempItemLedgEntry.FindSet then
            repeat
                ShippedQtyNotReturned := ShippedQtyNotReturned - TempItemLedgEntry."Shipped Qty. Not Returned";
                ShippedQtyNotReturnedAlt := ShippedQtyNotReturnedAlt - TempItemLedgEntry."Shipped Qty. Not Ret. (Alt.)"; // P8000466A
                if ExactCostReverse then begin
                    TempItemLedgEntry.CalcFields("Cost Amount (Expected)", "Cost Amount (Actual)");
                    TotalCostLCY :=
                      TotalCostLCY + TempItemLedgEntry."Cost Amount (Expected)" + TempItemLedgEntry."Cost Amount (Actual)";
                    TotalQtyBase := TotalQtyBase + TempItemLedgEntry.GetCostingQty; // P8000466A
                end;
            until TempItemLedgEntry.Next() = 0;

        if ExactCostReverse and ((ShippedQtyNotReturned <> 0) or (ShippedQtyNotReturnedAlt <> 0)) and  // P8000466A
          (TotalQtyBase <> 0)                                                                          // P8000466A
        then begin                                                                                     // P8000466A
            RevUnitCostLCY := Abs(TotalCostLCY / TotalQtyBase);                                          // P8000466A
            if not CostInAlternateUnits then                                                             // P8000466A
                RevUnitCostLCY := RevUnitCostLCY * "Qty. per Unit of Measure"                              // P8000466A
        end else                                                                                       // P8000466A
            RevUnitCostLCY := "Unit Cost (LCY)";
        ShippedQtyNotReturned := CalcQty(ShippedQtyNotReturned);

        if ShippedQtyNotReturned > Quantity then
            ShippedQtyNotReturned := Quantity;
        if ShippedQtyNotReturnedAlt > "Quantity (Alt.)" then // P8000466A
            ShippedQtyNotReturnedAlt := "Quantity (Alt.)";     // P8000466A
    end;

    local procedure CalcQty(QtyBase: Decimal): Decimal
    begin
        if "Qty. per Unit of Measure" = 0 then
            exit(QtyBase);
        exit(Round(QtyBase / "Qty. per Unit of Measure", UOMMgt.QtyRndPrecision));
    end;

    procedure GetItemLedgEntries(var TempItemLedgEntry: Record "Item Ledger Entry" temporary; SetQuantity: Boolean)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetItemLedgEntries(Rec, TempItemLedgEntry, SetQuantity, IsHandled);
        if IsHandled then
            exit;

        if SetQuantity then begin
            TempItemLedgEntry.Reset();
            TempItemLedgEntry.DeleteAll();

            if Type <> Type::Item then
                exit;
        end;

        FilterPstdDocLineValueEntries(ValueEntry);
        ValueEntry.SetFilter("Invoiced Quantity", '<>0');
        if ValueEntry.FindSet then
            repeat
                ItemLedgEntry.Get(ValueEntry."Item Ledger Entry No.");
                TempItemLedgEntry := ItemLedgEntry;
                if SetQuantity then begin
                    // P8000466A
                    if CostInAlternateUnits then begin
                        TempItemLedgEntry.Quantity := Round(
                          TempItemLedgEntry.Quantity * ValueEntry."Invoiced Quantity" / TempItemLedgEntry."Quantity (Alt.)", 0.00001);
                        TempItemLedgEntry."Quantity (Alt.)" := ValueEntry."Invoiced Quantity";
                    end else begin
                        // P8000466A
                        TempItemLedgEntry.Quantity := ValueEntry."Invoiced Quantity";
                        TempItemLedgEntry."Quantity (Alt.)" := Round(                                                                 // P8000466A
                          TempItemLedgEntry."Quantity (Alt.)" * ValueEntry."Invoiced Quantity" / TempItemLedgEntry.Quantity, 0.00001); // P8000466A
                    end; // P8000466A
                    if Abs(TempItemLedgEntry."Shipped Qty. Not Returned") > Abs(TempItemLedgEntry.Quantity) then
                        TempItemLedgEntry."Shipped Qty. Not Returned" := TempItemLedgEntry.Quantity;
                    // P8000466A
                    if Abs(TempItemLedgEntry."Shipped Qty. Not Ret. (Alt.)") > Abs(TempItemLedgEntry."Quantity (Alt.)") then
                        TempItemLedgEntry."Shipped Qty. Not Ret. (Alt.)" := TempItemLedgEntry."Quantity (Alt.)";
                    // P8000466A
                end;
                OnGetItemLedgEntriesOnBeforeTempItemLedgEntryInsert(TempItemLedgEntry, ValueEntry, SetQuantity);
                if TempItemLedgEntry.Insert() then;
            until ValueEntry.Next() = 0;
    end;

    procedure FilterPstdDocLineValueEntries(var ValueEntry: Record "Value Entry")
    begin
        ValueEntry.Reset();
        ValueEntry.SetCurrentKey("Document No.");
        ValueEntry.SetRange("Document No.", "Document No.");
        ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
        ValueEntry.SetRange("Document Line No.", "Line No.");
    end;

    procedure ShowItemShipmentLines()
    var
        TempSalesShptLine: Record "Sales Shipment Line" temporary;
    begin
        if Type = Type::Item then begin
            GetSalesShptLines(TempSalesShptLine);
            PAGE.RunModal(0, TempSalesShptLine);
        end;
    end;

    procedure ShowLineComments()
    var
        SalesCommentLine: Record "Sales Comment Line";
    begin
        SalesCommentLine.ShowComments(SalesCommentLine."Document Type"::"Posted Invoice".AsInteger(), "Document No.", "Line No.");
    end;

    procedure GetCostingQty(): Decimal
    begin
        // PR3.60
        if (Type <> Type::Item) or ("No." = '') then
            exit(Quantity);
        // P8000466A
        //IF (Item."No." <> "No.") THEN
        //  Item.GET("No.");
        //IF Item.CostInAlternateUnits() THEN
        if CostInAlternateUnits then
            // P8000466A
            exit("Quantity (Alt.)");
        exit(Quantity);
        // PR3.60
    end;

    procedure GetCostingQtyBase(): Decimal
    begin
        // PR3.70.02
        if (Type <> Type::Item) or ("No." = '') then
            exit("Quantity (Base)");
        // P8000466A
        //IF (Item."No." <> "No.") THEN
        //  Item.GET("No.");
        //IF Item.CostInAlternateUnits() THEN
        if CostInAlternateUnits then
            // P8000466A
            exit("Quantity (Alt.)");
        exit("Quantity (Base)");
        // PR3.70.02
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

    procedure GetPricingQty(): Decimal
    begin
        // P8000981
        if (Type <> Type::Item) or ("No." = '') then
            exit(Quantity);
        if (Item."No." <> "No.") then
            Item.Get("No.");
        if Item.PriceInAlternateUnits() then
            exit("Quantity (Alt.)");
        exit(Quantity);
    end;

    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20])
    begin
        DimMgt.GetShortcutDimensions("Dimension Set ID", ShortcutDimCode);
    end;

    procedure InitFromSalesLine(SalesInvHeader: Record "Sales Invoice Header"; SalesLine: Record "Sales Line")
    begin
        Init;
        TransferFields(SalesLine);
        if ("No." = '') and HasTypeToFillMandatoryFields() then
            Type := Type::" ";
        "Posting Date" := SalesInvHeader."Posting Date";
        "Document No." := SalesInvHeader."No.";
        Quantity := SalesLine."Qty. to Invoice";
        "Quantity (Base)" := SalesLine."Qty. to Invoice (Base)";

        OnAfterInitFromSalesLine(Rec, SalesInvHeader, SalesLine);
    end;

    procedure ShowDeferrals()
    begin
        DeferralUtilities.OpenLineScheduleView(
            "Deferral Code", "Deferral Document Type"::Sales.AsInteger(), '', '',
            GetDocumentType, "Document No.", "Line No.");
    end;

    procedure UpdatePriceDescription()
    var
        Currency: Record Currency;
    begin
        "Price description" := '';
        if Type in [Type::"Charge (Item)", Type::"Fixed Asset", Type::Item, Type::Resource] then begin
            if "Line Discount %" = 0 then
                "Price description" := StrSubstNo(
                    PriceDescriptionTxt, Quantity, Currency.ResolveGLCurrencySymbol(GetCurrencyCode),
                    "Unit Price", "Unit of Measure")
            else
                "Price description" := StrSubstNo(
                    PriceDescriptionWithLineDiscountTxt, Quantity, Currency.ResolveGLCurrencySymbol(GetCurrencyCode),
                    "Unit Price", "Unit of Measure", "Line Discount %")
        end;
    end;

    procedure FormatType(): Text
    var
        SalesLine: Record "Sales Line";
    begin
        if Type = Type::" " then
            exit(SalesLine.FormatType);

        exit(Format(Type));
    end;

    procedure GetDocumentType(): Integer
    var
        SalesCommentLine: Record "Sales Comment Line";
    begin
        exit(SalesCommentLine."Document Type"::"Posted Invoice".AsInteger())
    end;

    procedure HasTypeToFillMandatoryFields(): Boolean
    begin
        exit(Type <> Type::" ");
    end;

    procedure IsCancellationSupported(): Boolean
    begin
        exit(Type in [Type::" ", Type::Item, Type::"G/L Account", Type::"Charge (Item)"]);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitFromSalesLine(var SalesInvLine: Record "Sales Invoice Line"; SalesInvHeader: Record "Sales Invoice Header"; SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetItemLedgEntries(var SalesInvLine: Record "Sales Invoice Line"; var TempItemLedgEntry: Record "Item Ledger Entry" temporary; SetQuantity: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcVATAmountLines(SalesInvLine: Record "Sales Invoice Line"; SalesInvHeader: Record "Sales Invoice Header"; var TempVATAmountLine: Record "VAT Amount Line" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetItemLedgEntriesOnBeforeTempItemLedgEntryInsert(var TempItemLedgerEntry: Record "Item Ledger Entry" temporary; ValueEntry: Record "Value Entry"; SetQuantity: Boolean)
    begin
    end;
}

