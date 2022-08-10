table 6661 "Return Receipt Line"
{
    // PR3.60
    //   Add fields for alternate quantities
    // 
    // PR3.70
    //   Add Key - Type,No. (Group - LOT CTRL)
    // 
    // PR3.70.03
    //   New Fields
    //     Accrual Amount (Price)
    // 
    // PR3.70.07
    // P8000143A, Myers Nissi, Jack Reynolds, 18 NOV 04
    //   Add Container as option for Type field
    // 
    // PRW16.00.04
    // P8000885, VerticalSoft, Ron Davidson, 20 DEC 10
    //   Added three new fields for Sales Contracts.
    // 
    // PRW16.00.05
    // P8000931, Columbus IT, Jack Reynolds, 20 APR 11
    //   Support for Supply Chain Groups
    // 
    // P8000953, Columbus IT, Don Bresee, 04 JUN 11
    //   Add Delivered Pricing fields to Combine Shipments logic
    // 
    // P8000971, Columbus IT, Jack Reynolds, 25 AUG 11
    //   Fix problem with item charges and alternate quantity
    // 
    // PRW16.00.06
    // P8001047, Columbus IT, Jack Reynolds, 30 MAR 12
    //   Receiving Labels
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

    Caption = 'Return Receipt Line';
    LookupPageID = "Posted Return Receipt Lines";
    Permissions = TableData "Item Ledger Entry" = r,
                  TableData "Value Entry" = r;

    fields
    {
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
        field(37002124; "Accrual Amount (Price)"; Decimal)
        {
            Caption = 'Accrual Amount (Price)';
            Description = 'PR3.70.03';
            Editable = false;
        }
        field(37002700; "Label Unit of Measure Code"; Code[10])
        {
            Caption = 'Label Unit of Measure Code';
            TableRelation = IF (Type = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));
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
            TableRelation = "Return Receipt Header";
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
        field(61; "Quantity Invoiced"; Decimal)
        {
            Caption = 'Quantity Invoiced';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(68; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            Editable = false;
            TableRelation = Customer;
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
            TableRelation = "Return Receipt Line"."Line No." WHERE("Document No." = FIELD("Document No."));
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
            CalcFormula = Lookup("Return Receipt Header"."Currency Code" WHERE("No." = FIELD("Document No.")));
            Caption = 'Currency Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(97; "Blanket Order No."; Code[20])
        {
            AccessByPermission = TableData "Return Receipt Header" = R;
            Caption = 'Blanket Order No.';
            TableRelation = "Sales Header"."No." WHERE("Document Type" = CONST("Blanket Order"));
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(98; "Blanket Order Line No."; Integer)
        {
            AccessByPermission = TableData "Return Receipt Header" = R;
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
            ValidateTableRelation = true;
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
        field(5805; "Return Qty. Rcd. Not Invd."; Decimal)
        {
            Caption = 'Return Qty. Rcd. Not Invd.';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(5811; "Appl.-from Item Entry"; Integer)
        {
            AccessByPermission = TableData Item = R;
            Caption = 'Appl.-from Item Entry';
            MinValue = 0;
        }
        field(5812; "Item Charge Base Amount"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            Caption = 'Item Charge Base Amount';
        }
        field(5817; Correction; Boolean)
        {
            Caption = 'Correction';
            Editable = false;
        }
        field(6602; "Return Order No."; Code[20])
        {
            Caption = 'Return Order No.';
            Editable = false;
        }
        field(6603; "Return Order Line No."; Integer)
        {
            Caption = 'Return Order Line No.';
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
        field(10000; "Package Tracking No."; Text[30])
        {
            Caption = 'Package Tracking No.';
        }
    }

    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Return Order No.", "Return Order Line No.")
        {
        }
        key(Key3; "Blanket Order No.", "Blanket Order Line No.")
        {
        }
        key(Key4; "Item Rcpt. Entry No.")
        {
        }
        key(Key5; "Bill-to Customer No.")
        {
        }
        key(Key6; "Sell-to Customer No.")
        {
        }
        key(Key7; Type, "No.")
        {
            Enabled = false;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        SalesDocLineComments: Record "Sales Comment Line";
    begin
        SalesDocLineComments.SetRange("Document Type", SalesDocLineComments."Document Type"::"Posted Return Receipt");
        SalesDocLineComments.SetRange("No.", "Document No.");
        SalesDocLineComments.SetRange("Document Line No.", "Line No.");
        if not SalesDocLineComments.IsEmpty() then
            SalesDocLineComments.DeleteAll();
    end;

    var
        Currency: Record Currency;
        ReturnRcptHeader: Record "Return Receipt Header";
        Text000: Label 'Return Receipt No. %1:';
        Text001: Label 'The program cannot find this purchase line.';
        TranslationHelper: Codeunit "Translation Helper";
        CurrencyRead: Boolean;
        Item: Record Item;

    procedure GetCurrencyCode(): Code[10]
    begin
        if "Document No." = ReturnRcptHeader."No." then
            exit(ReturnRcptHeader."Currency Code");
        if ReturnRcptHeader.Get("Document No.") then
            exit(ReturnRcptHeader."Currency Code");
        exit('');
    end;

    procedure ShowDimensions()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo('%1 %2 %3', TableCaption, "Document No.", "Line No."));
    end;

    procedure ShowItemTrackingLines()
    var
        ItemTrackingDocMgt: Codeunit "Item Tracking Doc. Management";
    begin
        ItemTrackingDocMgt.ShowItemTrackingForShptRcptLine(DATABASE::"Return Receipt Line", 0, "Document No.", '', 0, "Line No.");
    end;

    procedure InsertInvLineFromRetRcptLine(var SalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
        SalesHeader2: Record "Sales Header";
        SalesOrderHeader: Record "Sales Header";
        SalesOrderLine: Record "Sales Line";
        TempSalesLine: Record "Sales Line" temporary;
        SalesSetup: Record "Sales & Receivables Setup";
        TransferOldExtLines: Codeunit "Transfer Old Ext. Text Lines";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        ExtTextLine: Boolean;
        NextLineNo: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnInsertInvLineFromRetRcptLine(Rec, SalesLine, IsHandled);
        if IsHandled then
            exit;

        SetRange("Document No.", "Document No.");

        TempSalesLine := SalesLine;
        if SalesLine.Find('+') then
            NextLineNo := SalesLine."Line No." + 10000
        else
            NextLineNo := 10000;

        if SalesHeader."No." <> TempSalesLine."Document No." then
            SalesHeader.Get(TempSalesLine."Document Type", TempSalesLine."Document No.");

        if SalesLine."Return Receipt No." <> "Document No." then begin
            OnInsertInvLineFromRetRcptLineOnBeforeInitSalesLine(Rec, SalesLine);
            SalesLine.Init();
            SalesLine."Line No." := NextLineNo;
            SalesLine."Document Type" := TempSalesLine."Document Type";
            SalesLine."Document No." := TempSalesLine."Document No.";
            TranslationHelper.SetGlobalLanguageByCode(SalesHeader."Language Code");
            SalesLine.Description := StrSubstNo(Text000, "Document No.");
            TranslationHelper.RestoreGlobalLanguage;
            IsHandled := false;
            OnBeforeInsertInvLineFromRetRcptLineBeforeInsertTextLine(Rec, SalesLine, NextLineNo, IsHandled);
            if not IsHandled then begin
                SalesLine.Insert();
                OnAfterDescriptionSalesLineInsert(SalesLine, Rec, NextLineNo);
                NextLineNo := NextLineNo + 10000;
            end;
        end;

        TransferOldExtLines.ClearLineNumbers;
        SalesSetup.Get();
        repeat
            ExtTextLine := (TransferOldExtLines.GetNewLineNumber("Attached to Line No.") <> 0);

            if not SalesOrderLine.Get(
                 SalesOrderLine."Document Type"::"Return Order", "Return Order No.", "Return Order Line No.")
            then begin
                if ExtTextLine then begin
                    SalesOrderLine.Init();
                    SalesOrderLine."Line No." := "Return Order Line No.";
                    SalesOrderLine.Description := Description;
                    SalesOrderLine."Description 2" := "Description 2";
                end else
                    Error(Text001);
            end else begin
                if (SalesHeader2."Document Type" <> SalesOrderLine."Document Type"::"Return Order") or
                   (SalesHeader2."No." <> SalesOrderLine."Document No.")
                then
                    SalesHeader2.Get(SalesOrderLine."Document Type"::"Return Order", "Return Order No.");

                InitCurrency("Currency Code");

                if SalesHeader."Prices Including VAT" then begin
                    if not SalesHeader2."Prices Including VAT" then
                        SalesOrderLine."Unit Price" :=
                          Round(
                            SalesOrderLine."Unit Price" * (1 + SalesOrderLine."VAT %" / 100),
                            Currency."Unit-Amount Rounding Precision");
                end else begin
                    if SalesHeader2."Prices Including VAT" then
                        SalesOrderLine."Unit Price" :=
                          Round(
                            SalesOrderLine."Unit Price" / (1 + SalesOrderLine."VAT %" / 100),
                            Currency."Unit-Amount Rounding Precision");
                end;
            end;
            SalesLine := SalesOrderLine;
            SalesLine."Line No." := NextLineNo;
            SalesLine."Document Type" := TempSalesLine."Document Type";
            SalesLine."Document No." := TempSalesLine."Document No.";
            SalesLine."Variant Code" := "Variant Code";
            SalesLine."Location Code" := "Location Code";
            SalesLine."Return Reason Code" := "Return Reason Code";
            SalesLine."Quantity (Base)" := 0;
            SalesLine.Quantity := 0;
            SalesLine."Outstanding Qty. (Base)" := 0;
            SalesLine."Outstanding Quantity" := 0;
            SalesLine."Return Qty. Received" := 0;
            SalesLine."Return Qty. Received (Base)" := 0;
            SalesLine."Quantity Invoiced" := 0;
            SalesLine."Qty. Invoiced (Base)" := 0;
            SalesLine."Drop Shipment" := false;
            SalesLine."Return Receipt No." := "Document No.";
            SalesLine."Return Receipt Line No." := "Line No.";
            SalesLine."Appl.-to Item Entry" := 0;
            SalesLine."Appl.-from Item Entry" := 0;
            OnAfterCopyFieldsFromReturnReceiptLine(Rec, SalesLine);

            if not ExtTextLine then begin
                IsHandled := false;
                OnInsertInvLineFromRetRcptLineOnBeforeValidateSalesLineQuantity(Rec, SalesLine, IsHandled, SalesHeader);
                if not IsHandled then
                    SalesLine.Validate(Quantity, Quantity - "Quantity Invoiced");

                CopySalesLinePriceAndDiscountFromSalesOrderLine(SalesLine, SalesOrderLine);
                OnOnInsertInvLineFromRetRcptLineOnAfterCopySalesLinePriceAndDiscount(SalesLine, SalesOrderLine, Rec, SalesHeader);
            end;
            SalesLine."Attached to Line No." :=
              TransferOldExtLines.TransferExtendedText(
                SalesOrderLine."Line No.",
                NextLineNo,
                "Attached to Line No.");
            SalesLine."Shortcut Dimension 1 Code" := SalesOrderLine."Shortcut Dimension 1 Code";
            SalesLine."Shortcut Dimension 2 Code" := SalesOrderLine."Shortcut Dimension 2 Code";
            SalesLine."Dimension Set ID" := SalesOrderLine."Dimension Set ID";

            IsHandled := false;
            OnBeforeInsertInvLineFromRetRcptLine(SalesLine, SalesOrderLine, Rec, IsHandled);
            if not IsHandled then
                SalesLine.Insert();
            OnAftertInsertInvLineFromRetRcptLine(SalesLine, SalesOrderLine, Rec);

            ItemTrackingMgt.CopyHandledItemTrkgToInvLine(SalesOrderLine, SalesLine);

            NextLineNo := NextLineNo + 10000;
            if "Attached to Line No." = 0 then
                SetRange("Attached to Line No.", "Line No.");

        until (Next() = 0) or ("Attached to Line No." = 0);
        OnInsertInvLineFromRetRcptLineOnAfterInsertAllLines(Rec, SalesLine);

        if SalesOrderHeader.Get(SalesOrderHeader."Document Type"::Order, "Return Order No.") then begin
            SalesOrderHeader."Get Shipment Used" := true;
            SalesOrderHeader.Modify();
        end;
    end;

    local procedure CopySalesLinePriceAndDiscountFromSalesOrderLine(var SalesLine: Record "Sales Line"; SalesOrderLine: Record "Sales Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopySalesLinePriceAndDiscountFromSalesOrderLine(SalesLine, SalesOrderLine, IsHandled);
        if IsHandled then
            exit;

        // P8000953
        SalesLine.Validate("Unit Price (FOB)", SalesOrderLine."Unit Price (FOB)");
        SalesLine.Validate("Unit Price (Freight)", SalesOrderLine."Unit Price (Freight)");
        SalesLine."Freight Entered by User" := SalesOrderLine."Freight Entered by User";
        // P8000953
        SalesLine.Validate("Unit Price", SalesOrderLine."Unit Price");
        SalesLine."Allow Line Disc." := SalesOrderLine."Allow Line Disc.";
        SalesLine."Allow Invoice Disc." := SalesOrderLine."Allow Invoice Disc.";
        SalesLine.Validate("Line Discount %", SalesOrderLine."Line Discount %");
        if SalesOrderLine.Quantity = 0 then
            SalesLine.Validate("Inv. Discount Amount", 0)
        else
            SalesLine.Validate(
              "Inv. Discount Amount",
              Round(
                SalesOrderLine."Inv. Discount Amount" * SalesLine.Quantity / SalesOrderLine.Quantity,
                Currency."Amount Rounding Precision"));
    end;

    procedure GetSalesCrMemoLines(var TempSalesCrMemoLine: Record "Sales Cr.Memo Line" temporary)
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        ItemLedgEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
    begin
        TempSalesCrMemoLine.Reset();
        TempSalesCrMemoLine.DeleteAll();

        if Type <> Type::Item then
            exit;

        FilterPstdDocLnItemLedgEntries(ItemLedgEntry);
        ItemLedgEntry.SetFilter("Invoiced Quantity", '<>0');
        if ItemLedgEntry.FindSet() then begin
            ValueEntry.SetCurrentKey("Item Ledger Entry No.", "Entry Type");
            ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
            ValueEntry.SetFilter("Invoiced Quantity", '<>0');
            repeat
                ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgEntry."Entry No.");
                if ValueEntry.FindSet() then
                    repeat
                        if ValueEntry."Document Type" = ValueEntry."Document Type"::"Sales Credit Memo" then
                            if SalesCrMemoLine.Get(ValueEntry."Document No.", ValueEntry."Document Line No.") then begin
                                TempSalesCrMemoLine.Init();
                                TempSalesCrMemoLine := SalesCrMemoLine;
                                if TempSalesCrMemoLine.Insert() then;
                            end;
                    until ValueEntry.Next() = 0;
            until ItemLedgEntry.Next() = 0;
        end;
    end;

    procedure FilterPstdDocLnItemLedgEntries(var ItemLedgEntry: Record "Item Ledger Entry")
    begin
        ItemLedgEntry.Reset();
        ItemLedgEntry.SetCurrentKey("Document No.");
        ItemLedgEntry.SetRange("Document No.", "Document No.");
        ItemLedgEntry.SetRange("Document Type", ItemLedgEntry."Document Type"::"Sales Return Receipt");
        ItemLedgEntry.SetRange("Document Line No.", "Line No.");
    end;

    procedure ShowItemSalesCrMemoLines()
    var
        TempSalesCrMemoLine: Record "Sales Cr.Memo Line" temporary;
    begin
        if Type = Type::Item then begin
            GetSalesCrMemoLines(TempSalesCrMemoLine);
            PAGE.RunModal(0, TempSalesCrMemoLine);
        end;
    end;

    local procedure InitCurrency(CurrencyCode: Code[10])
    begin
        if (Currency.Code = CurrencyCode) and CurrencyRead then
            exit;

        if CurrencyCode <> '' then
            Currency.Get(CurrencyCode)
        else
            Currency.InitRoundingPrecision;
        CurrencyRead := true;
    end;

    procedure ShowLineComments()
    var
        SalesCommentLine: Record "Sales Comment Line";
    begin
        SalesCommentLine.ShowComments(
            SalesCommentLine."Document Type"::"Posted Return Receipt".AsInteger(), "Document No.", "Line No.");
    end;

    procedure AltQtyEntriesExist(): Boolean
    var
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // PR3.60
        AltQtyEntry.SetRange("Table No.", DATABASE::"Return Receipt Line");
        AltQtyEntry.SetRange("Document No.", "Document No.");
        AltQtyEntry.SetRange("Source Line No.", "Line No.");
        exit(AltQtyEntry.Find('-'));
        // PR3.60
    end;

    local procedure GetItem()
    begin
        // P8000971
        TestField("No.");
        if "No." <> Item."No." then
            Item.Get("No.");
    end;

    procedure CostInAlternateUnits(): Boolean
    begin
        // P8000971
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

    procedure InitFromSalesLine(ReturnRcptHeader: Record "Return Receipt Header"; SalesLine: Record "Sales Line")
    begin
        Init;
        TransferFields(SalesLine);
        if ("No." = '') and HasTypeToFillMandatoryFields() then
            Type := Type::" ";
        "Posting Date" := ReturnRcptHeader."Posting Date";
        "Document No." := ReturnRcptHeader."No.";
        Quantity := SalesLine."Return Qty. to Receive";
        "Quantity (Base)" := SalesLine."Return Qty. to Receive (Base)";
        if Abs(SalesLine."Qty. to Invoice") > Abs(SalesLine."Return Qty. to Receive") then begin
            "Quantity Invoiced" := SalesLine."Return Qty. to Receive";
            "Qty. Invoiced (Base)" := SalesLine."Return Qty. to Receive (Base)";
        end else begin
            "Quantity Invoiced" := SalesLine."Qty. to Invoice";
            "Qty. Invoiced (Base)" := SalesLine."Qty. to Invoice (Base)";
        end;

        // P8004516
        "Quantity (Alt.)" := SalesLine."Return Qty. to Receive (Alt.)";
        if Abs(SalesLine."Qty. to Invoice") > Abs(SalesLine."Return Qty. to Receive") then
            "Qty. Invoiced (Alt.)" := SalesLine."Return Qty. to Receive (Alt.)"
        else
            "Qty. Invoiced (Alt.)" := SalesLine."Qty. to Invoice (Alt.)";
        // P8004516

        "Return Qty. Rcd. Not Invd." :=
          Quantity - "Quantity Invoiced";
        if SalesLine."Document Type" = SalesLine."Document Type"::"Return Order" then begin
            "Return Order No." := SalesLine."Document No.";
            "Return Order Line No." := SalesLine."Line No.";
        end;

        OnAfterInitFromSalesLine(ReturnRcptHeader, SalesLine, Rec);
    end;

    procedure HasTypeToFillMandatoryFields(): Boolean
    begin
        exit(Type <> Type::" ");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFieldsFromReturnReceiptLine(var ReturnReceiptLine: Record "Return Receipt Line"; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitFromSalesLine(ReturnRcptHeader: Record "Return Receipt Header"; SalesLine: Record "Sales Line"; var ReturnRcptLine: Record "Return Receipt Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAftertInsertInvLineFromRetRcptLine(var SalesLine: Record "Sales Line"; var SalesOrderLine: Record "Sales Line"; var ReturnReceiptLine: Record "Return Receipt Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopySalesLinePriceAndDiscountFromSalesOrderLine(var SalesLine: Record "Sales Line"; SalesOrderLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertInvLineFromRetRcptLine(var SalesLine: Record "Sales Line"; SalesOrderLine: Record "Sales Line"; var ReturnReceiptLine: Record "Return Receipt Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertInvLineFromRetRcptLineBeforeInsertTextLine(var ReturnReceiptLine: Record "Return Receipt Line"; var SalesLine: Record "Sales Line"; var NextLineNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertInvLineFromRetRcptLineOnBeforeInitSalesLine(var ReturnReceiptLine: Record "Return Receipt Line"; SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertInvLineFromRetRcptLineOnAfterInsertAllLines(ReturnReceiptLine: Record "Return Receipt Line"; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertInvLineFromRetRcptLineOnBeforeValidateSalesLineQuantity(var ReturnReceiptLine: Record "Return Receipt Line"; var SalesLine: Record "Sales Line"; var IsHandled: Boolean; var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDescriptionSalesLineInsert(var SalesLine: Record "Sales Line"; ReturnReceiptLine: Record "Return Receipt Line"; var NextLineNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertInvLineFromRetRcptLine(var ReturnReceiptLine: Record "Return Receipt Line"; var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnOnInsertInvLineFromRetRcptLineOnAfterCopySalesLinePriceAndDiscount(var SalesLine: Record "Sales Line"; SalesOrderLine: Record "Sales Line"; ReturnReceiptLine: Record "Return Receipt Line"; SalesHeader: Record "Sales Header")
    begin
    end;
}

