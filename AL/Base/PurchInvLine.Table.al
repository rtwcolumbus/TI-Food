table 123 "Purch. Inv. Line"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 09-10-2014, Initial Version
    // --------------------------------------------------------------------------------
    // 
    // PR1.00
    //   New Process 800 fields
    //     Original Quantity
    // 
    // PR3.60
    //   Add field/logic for alternate quantities
    // 
    // PR3.70.01
    //   Extra Charges
    // 
    // PR3.70.03
    //   New Fields
    //     Promo/Rebate Amount
    //     Commission Amount
    //     Accruals Included in Price
    //     Accruals Excluded from Price
    //     Accrual Amount (Cost)
    // 
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 30 AUG 05
    //   Add Accrual Plan option to Type
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 31 JUL 07
    //   Support alternate quantity for received not returned
    // 
    // PRW16.00.01
    // P8000694, VerticalSoft, Jack Reynolds, 04 MAY 09
    //   Change name of Accrual fields
    // 
    // PRW16.00.04
    // P8000902, Columbus IT, Don Bresee, 14 MAR 11
    //   Add Commodity Payment logic
    // 
    // PRW16.00.05
    // P8000931, Columbus IT, Jack Reynolds, 20 APR 11
    //   Support for Supply Chain Groups
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality
    // 
    // PRW18.00.02
    // P8002742, To-Increase, Jack Reynolds, 30 Sep 15
    //   Support for accrual payment documents
    // 
    // PRW18.00.03
    // P8006537, To-Increase, Jack Reynolds, 26 FEB 16
    //   Accrual flow fields
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 9 NOV 15
    //   NAV 2016 refactoring
    // 
    // PRW19.00.01
    // P8006916, To-Increase, Jack Reynolds, 31 AUG 16
    //   FOOD-TOM Separation
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018

    Caption = 'Purch. Inv. Line';
    DrillDownPageID = "Posted Purchase Invoice Lines";
    LookupPageID = "Posted Purchase Invoice Lines";
    Permissions = TableData "Item Ledger Entry" = r,
                  TableData "Value Entry" = r;

    fields
    {
        field(11028620; "Transport Cost Entry No"; Integer)
        {
            Caption = 'Transport Cost Entry No';
            Description = 'N138F0000';
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
        field(37002081; "Quantity (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,1,0,%1,%2', Type, "No.");
            Caption = 'Quantity (Alt.)';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.60';
        }
        field(37002120; "Promo/Rebate Amount (LCY)"; Decimal)
        {
            CalcFormula = Sum("Accrual Ledger Entry".Amount WHERE("Accrual Plan Type" = CONST(Purchase),
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
        field(37002122; "Acc. Incl. in Cost (LCY)"; Decimal)
        {
            CalcFormula = Sum("Accrual Ledger Entry".Amount WHERE("Accrual Plan Type" = CONST(Purchase),
                                                                   "Entry Type" = CONST(Accrual),
                                                                   "Price Impact" = CONST("Include in Price"),
                                                                   "Source Document Type" = CONST(Invoice),
                                                                   "Source Document No." = FIELD("Document No."),
                                                                   "Source Document Line No." = FIELD("Line No.")));
            Caption = 'Acc. Incl. in Cost (LCY)';
            Description = 'PR3.70.03';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002123; "Acc. Excl. from Cost (LCY)"; Decimal)
        {
            CalcFormula = Sum("Accrual Ledger Entry".Amount WHERE("Accrual Plan Type" = CONST(Purchase),
                                                                   "Entry Type" = CONST(Accrual),
                                                                   "Price Impact" = CONST("Exclude from Price"),
                                                                   "Source Document Type" = CONST(Invoice),
                                                                   "Source Document No." = FIELD("Document No."),
                                                                   "Source Document Line No." = FIELD("Line No.")));
            Caption = 'Acc. Excl. from Cost (LCY)';
            Description = 'PR3.70.03';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002124; "Accrual Amount (Cost)"; Decimal)
        {
            Caption = 'Accrual Amount (Cost)';
            Description = 'PR3.70.03';
            Editable = false;
        }
        field(37002125; "Accrual Plan Type"; Option)
        {
            Caption = 'Accrual Plan Type';
            Editable = false;
            OptionCaption = 'Sales,Purchase';
            OptionMembers = Sales,Purchase;
        }
        field(37002126; "Accrual Source No."; Code[20])
        {
            Caption = 'Accrual Source No.';
            TableRelation = IF ("Accrual Plan Type" = CONST(Sales)) Customer
            ELSE
            IF ("Accrual Plan Type" = CONST(Purchase)) Vendor;
        }
        field(37002127; "Accrual Source Doc. Type"; Option)
        {
            Caption = 'Accrual Source Doc. Type';
            OptionCaption = 'None,Shipment,Receipt,Invoice,Credit Memo';
            OptionMembers = "None",Shipment,Receipt,Invoice,"Credit Memo";
        }
        field(37002128; "Accrual Source Doc. No."; Code[20])
        {
            Caption = 'Accrual Source Doc. No.';
        }
        field(37002129; "Accrual Source Doc. Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Accrual Source Doc. Line No.';
        }
        field(37002130; "Scheduled Accrual No."; Code[10])
        {
            Caption = 'Scheduled Accrual No.';
        }
        field(37002685; "Commodity Manifest No."; Code[20])
        {
            Caption = 'Commodity Manifest No.';
            Editable = false;
        }
        field(37002686; "Commodity Manifest Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Commodity Manifest Line No.';
            Editable = false;
        }
        field(37002687; "Commodity Received Date"; Date)
        {
            Caption = 'Commodity Received Date';
            Editable = false;
        }
        field(37002688; "Comm. Payment Class Code"; Code[10])
        {
            Caption = 'Comm. Payment Class Code';
            TableRelation = "Commodity Class";
        }
        field(37002690; "Commodity Unit Cost"; Decimal)
        {
            AutoFormatType = 2;
            BlankZero = true;
            Caption = 'Commodity Unit Cost';
            Editable = false;
        }
        field(37002693; "Commodity P.O. Type"; Option)
        {
            Caption = 'Commodity P.O. Type';
            Editable = false;
            OptionCaption = ' ,Producer,Hauler,Broker';
            OptionMembers = " ",Producer,Hauler,Broker;
        }
        field(37002694; "Producer Zone Code"; Code[20])
        {
            Caption = 'Producer Zone Code';
            TableRelation = IF ("Commodity P.O. Type" = CONST(Hauler)) "Producer Zone";
        }
        field(37002695; "Commodity Rejected"; Boolean)
        {
            CalcFormula = Lookup("Posted Comm. Manifest Header"."Product Rejected" WHERE("No." = FIELD("Commodity Manifest No.")));
            Caption = 'Commodity Rejected';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002696; "Commodity Item No."; Code[20])
        {
            CalcFormula = Lookup("Purch. Inv. Header"."Commodity Item No." WHERE("No." = FIELD("Document No.")));
            Caption = 'Commodity Item No.';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = Item WHERE("Catch Alternate Qtys." = CONST(false),
                                        "Comm. Manifest UOM Code" = FILTER(<> ''));
        }
        field(37002697; "Rejection Action"; Option)
        {
            Caption = 'Rejection Action';
            OptionCaption = ' ,Withhold Payment';
            OptionMembers = " ","Withhold Payment";
        }
        field(2; "Buy-from Vendor No."; Code[20])
        {
            Caption = 'Buy-from Vendor No.';
            Editable = false;
            TableRelation = Vendor;
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "Purch. Inv. Header";
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
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 2;
            CaptionClass = GetCaptionClass(FieldNo("Direct Unit Cost"));
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
        field(63; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
            Editable = false;
        }
        field(64; "Receipt Line No."; Integer)
        {
            Caption = 'Receipt Line No.';
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
        field(68; "Pay-to Vendor No."; Code[20])
        {
            Caption = 'Pay-to Vendor No.';
            Editable = false;
            TableRelation = Vendor;
        }
        field(69; "Inv. Discount Amount"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            Caption = 'Inv. Discount Amount';
        }
        field(70; "Vendor Item No."; Text[50])
        {
            Caption = 'Vendor Item No.';
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
            TableRelation = "Purch. Inv. Line"."Line No." WHERE("Document No." = FIELD("Document No."));
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
        field(138; "IC Cross-Reference No."; Code[50])
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
        field(1700; "Deferral Code"; Code[10])
        {
            Caption = 'Deferral Code';
            TableRelation = "Deferral Template"."Deferral Code";
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
        field(5600; "FA Posting Date"; Date)
        {
            Caption = 'FA Posting Date';
        }
        field(5601; "FA Posting Type"; Option)
        {
            Caption = 'FA Posting Type';
            OptionCaption = ' ,Acquisition Cost,Maintenance,,Appreciation';
            OptionMembers = " ","Acquisition Cost",Maintenance,,Appreciation;
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
        field(6608; "Return Reason Code"; Code[10])
        {
            Caption = 'Return Reason Code';
            TableRelation = "Return Reason";
        }
        field(7000; "Price Calculation Method"; Enum "Price Calculation Method")
        {
            Caption = 'Price Calculation Method';
        }
        field(10017; "Provincial Tax Area Code"; Code[20])
        {
            Caption = 'Provincial Tax Area Code';
            TableRelation = "Tax Area" WHERE("Country/Region" = CONST(CA));
        }
        field(10022; "IRS 1099 Liable"; Boolean)
        {
            Caption = 'IRS 1099 Liable';
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
            MaintainSIFTIndex = false;
        }
        key(Key2; "Blanket Order No.", "Blanket Order Line No.")
        {
        }
        key(Key3; Type, "No.", "Variant Code")
        {
        }
        key(Key4; "Buy-from Vendor No.")
        {
        }
        key(Key5; "Job No.", "Document No.")
        {
        }
        key(Key6; "Order No.", "Order Line No.", "Posting Date")
        {
        }
        key(Key7; "Document No.", "Location Code")
        {
            MaintainSQLIndex = false;
            SumIndexFields = Amount, "Amount Including VAT";
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        PurchDocLineComments: Record "Purch. Comment Line";
        PostedDeferralHeader: Record "Posted Deferral Header";
    begin
        PurchDocLineComments.SetRange("Document Type", PurchDocLineComments."Document Type"::"Posted Invoice");
        PurchDocLineComments.SetRange("No.", "Document No.");
        PurchDocLineComments.SetRange("Document Line No.", "Line No.");
        if not PurchDocLineComments.IsEmpty() then
            PurchDocLineComments.DeleteAll();

        PostedDeferralHeader.DeleteHeader(
            "Deferral Document Type"::Purchase.AsInteger(), '', '',
            PurchDocLineComments."Document Type"::"Posted Invoice".AsInteger(), "Document No.", "Line No.");
    end;

    var
        DimMgt: Codeunit DimensionManagement;
        UOMMgt: Codeunit "Unit of Measure Management";
        Item: Record Item;
        DeferralUtilities: Codeunit "Deferral Utilities";

    procedure GetCurrencyCode(): Code[10]
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        if "Document No." = PurchInvHeader."No." then
            exit(PurchInvHeader."Currency Code");
        if PurchInvHeader.Get("Document No.") then
            exit(PurchInvHeader."Currency Code");
        exit('');
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

    procedure CalcVATAmountLines(PurchInvHeader: Record "Purch. Inv. Header"; var TempVATAmountLine: Record "VAT Amount Line" temporary)
    begin
        TempVATAmountLine.DeleteAll();
        SetRange("Document No.", PurchInvHeader."No.");
        if Find('-') then
            repeat
                TempVATAmountLine.Init();
                TempVATAmountLine.CopyFromPurchInvLine(Rec);
                TempVATAmountLine.InsertLine;
            until Next() = 0;
    end;

    local procedure GetFieldCaption(FieldNumber: Integer): Text[100]
    var
        "Field": Record "Field";
    begin
        Field.Get(DATABASE::"Purch. Inv. Line", FieldNumber);
        exit(Field."Field Caption");
    end;

    procedure GetCaptionClass(FieldNumber: Integer): Text[80]
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        if not PurchInvHeader.Get("Document No.") then
            PurchInvHeader.Init();
        if PurchInvHeader."Prices Including VAT" then
            exit('2,1,' + GetFieldCaption(FieldNumber));

        exit('2,0,' + GetFieldCaption(FieldNumber));
    end;

    procedure RowID1(): Text[250]
    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        exit(ItemTrackingMgt.ComposeRowID(DATABASE::"Purch. Inv. Line",
            0, "Document No.", '', 0, "Line No."));
    end;

    procedure GetPurchRcptLines(var TempPurchRcptLine: Record "Purch. Rcpt. Line" temporary)
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
        ItemLedgEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
    begin
        TempPurchRcptLine.Reset();
        TempPurchRcptLine.DeleteAll();

        if Type <> Type::Item then
            exit;

        FilterPstdDocLineValueEntries(ValueEntry);
        ValueEntry.SetFilter("Invoiced Quantity", '<>0');
        if ValueEntry.FindSet then
            repeat
                ItemLedgEntry.Get(ValueEntry."Item Ledger Entry No.");
                if ItemLedgEntry."Document Type" = ItemLedgEntry."Document Type"::"Purchase Receipt" then
                    if PurchRcptLine.Get(ItemLedgEntry."Document No.", ItemLedgEntry."Document Line No.") then begin
                        TempPurchRcptLine.Init();
                        TempPurchRcptLine := PurchRcptLine;
                        if TempPurchRcptLine.Insert() then;
                    end;
            until ValueEntry.Next() = 0;
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
        TempItemLedgEntry: Record "Item Ledger Entry" temporary;
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
        GetItemLedgEntries(TempItemLedgEntry, false);

        if TempItemLedgEntry.FindSet then
            repeat
                RemainingQty := RemainingQty + TempItemLedgEntry."Remaining Quantity";
                RemainingQtyAlt := RemainingQtyAlt + TempItemLedgEntry."Remaining Quantity (Alt.)"; // P8000466A
                if ExactCostReverse then begin
                    TempItemLedgEntry.CalcFields("Cost Amount (Expected)", "Cost Amount (Actual)");
                    TotalCostLCY :=
                      TotalCostLCY + TempItemLedgEntry."Cost Amount (Expected)" + TempItemLedgEntry."Cost Amount (Actual)";
                    TotalQtyBase := TotalQtyBase + TempItemLedgEntry.GetCostingQty; // P8000466A
                end;
            until TempItemLedgEntry.Next() = 0;

        if ExactCostReverse and ((RemainingQty <> 0) or (RemainingQtyAlt <> 0)) and  // P8000466A
          (TotalQtyBase <> 0)                                                        // P8000466A
        then begin                                                                   // P8000466A
            RevUnitCostLCY := Abs(TotalCostLCY / TotalQtyBase);                        // P8000466A
            if not CostInAlternateUnits then                                           // P8000466A
                RevUnitCostLCY := RevUnitCostLCY * "Qty. per Unit of Measure"            // P8000466A
        end else                                                                     // P8000466A
            RevUnitCostLCY := "Unit Cost (LCY)";
        RemainingQty := CalcQty(RemainingQty);

        if RemainingQty > Quantity then
            RemainingQty := Quantity;
        if RemainingQtyAlt > "Quantity (Alt.)" then // P8000466A
            RemainingQtyAlt := "Quantity (Alt.)";     // P8000466A
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
    begin
        if SetQuantity then begin
            TempItemLedgEntry.Reset();
            TempItemLedgEntry.DeleteAll();

            if Type <> Type::Item then
                exit;
            if "Work Center No." <> '' then
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
                    if Abs(TempItemLedgEntry."Remaining Quantity") > Abs(TempItemLedgEntry.Quantity) then
                        TempItemLedgEntry."Remaining Quantity" := Abs(TempItemLedgEntry.Quantity);
                    // P8000466A
                    if Abs(TempItemLedgEntry."Remaining Quantity (Alt.)") > Abs(TempItemLedgEntry."Quantity (Alt.)") then
                        TempItemLedgEntry."Remaining Quantity (Alt.)" := TempItemLedgEntry."Quantity (Alt.)";
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
        ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Purchase Invoice");
        ValueEntry.SetRange("Document Line No.", "Line No.");
    end;

    procedure ShowItemReceiptLines()
    var
        TempPurchRcptLine: Record "Purch. Rcpt. Line" temporary;
    begin
        if Type = Type::Item then begin
            GetPurchRcptLines(TempPurchRcptLine);
            PAGE.RunModal(0, TempPurchRcptLine);
        end;
    end;

    procedure ShowLineComments()
    var
        PurchCommentLine: Record "Purch. Comment Line";
    begin
        PurchCommentLine.ShowComments(PurchCommentLine."Document Type"::"Posted Invoice".AsInteger(), "Document No.", "Line No.");
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
        PostedExtraCharge.SetRange("Table ID", DATABASE::"Purch. Inv. Line");
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

    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20])
    begin
        DimMgt.GetShortcutDimensions("Dimension Set ID", ShortcutDimCode);
    end;

    procedure InitFromPurchLine(PurchInvHeader: Record "Purch. Inv. Header"; PurchLine: Record "Purchase Line")
    begin
        Init;
        TransferFields(PurchLine);
        if ("No." = '') and HasTypeToFillMandatoryFields() then
            Type := Type::" ";
        "Posting Date" := PurchInvHeader."Posting Date";
        "Document No." := PurchInvHeader."No.";
        Quantity := PurchLine."Qty. to Invoice";
        "Quantity (Base)" := PurchLine."Qty. to Invoice (Base)";

        OnAfterInitFromPurchLine(PurchInvHeader, PurchLine, Rec);
    end;

    procedure ShowDeferrals()
    begin
        DeferralUtilities.OpenLineScheduleView(
            "Deferral Code", "Deferral Document Type"::Purchase.AsInteger(), '', '',
            GetDocumentType, "Document No.", "Line No.");
    end;

    procedure GetDocumentType(): Integer
    var
        PurchCommentLine: Record "Purch. Comment Line";
    begin
        exit(PurchCommentLine."Document Type"::"Posted Invoice".AsInteger())
    end;

    procedure HasTypeToFillMandatoryFields(): Boolean
    begin
        exit(Type <> Type::" ");
    end;

    procedure FormatType(): Text
    var
        PurchaseLine: Record "Purchase Line";
    begin
        if Type = Type::" " then
            exit(PurchaseLine.FormatType);

        exit(Format(Type));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitFromPurchLine(PurchInvHeader: Record "Purch. Inv. Header"; PurchLine: Record "Purchase Line"; var PurchInvLine: Record "Purch. Inv. Line")
    begin
    end;

    procedure IsCancellationSupported(): Boolean
    begin
        exit(Type in [Type::" ", Type::Item, Type::"G/L Account", Type::"Charge (Item)", Type::Resource]);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetItemLedgEntriesOnBeforeTempItemLedgEntryInsert(var TempItemLedgerEntry: Record "Item Ledger Entry" temporary; ValueEntry: Record "Value Entry"; SetQuantity: Boolean)
    begin
    end;
}

