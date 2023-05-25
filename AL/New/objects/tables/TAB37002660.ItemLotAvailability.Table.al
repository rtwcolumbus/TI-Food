table 37002660 "Item Lot Availability"
{
    // PR4.00
    // P8000253A, Myers Nissi, Jack Reynolds, 21 OCT 05
    //   Add fields for uit price and quantity to order to allow entry of quantity and price directly on
    //     terminal market form
    // 
    // PR4.00.04
    // P8000363A, VerticalSoft, Jack Reynolds, 03 AUG 06
    //   Increase Farm and Brand fields to Text30 to match Lot Information table
    // 
    // PRW15.00.01
    // P8000577A, VerticalSoft, Jack Reynolds, 19 FEB 08
    //   Modify GetUnitPrice to use the unit price from the item record
    // 
    // PRW15.00.03
    // P8000624A, VerticalSoft, Jack Reynolds, 19 AUG 08
    //   Add field for coutry/region of origin
    // 
    // PR6.00.01
    // P8000735, VerticalSoft, Jack Reynolds, 19 OCT 09
    //   Change the name of field 101 from "Quantity to Order" to "Quantity to Sell"
    // 
    // PRW16.00.05
    // P8000944, Columbus IT, Jack Reynolds, 31 MAY 11
    //   Re-done for modified terminal market
    // 
    // P8000981, Columbus IT, Don Bresee, 20 SEP 11
    //   Use Pricing Qty in Last Sales Price calculation
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
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

    Caption = 'Item Lot Availability';
    ReplicateData = false;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(3; "Lot No."; Code[100])
        {
            Caption = 'Lot No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(4; "Country/Region of Origin Code"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(6; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(8; "Base Unit of Measure"; Code[10])
        {
            Caption = 'Base Unit of Measure';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(9; "Costing Unit of Measure"; Code[10])
        {
            Caption = 'Costing Unit of Measure';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(10; "Alternate Qty. per Base"; Decimal)
        {
            Caption = 'Alternate Qty. per Base';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(11; "Receiving Reason Code"; Code[20])
        {
            Caption = 'Receiving Reason Code';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(12; Farm; Text[30])
        {
            Caption = 'Farm';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(13; Brand; Text[30])
        {
            Caption = 'Brand';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(14; "Release Date"; Date)
        {
            Caption = 'Release Date';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(15; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(16; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(21; "Quantity Available"; Decimal)
        {
            Caption = 'Quantity Available';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(22; "Quantity Available (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            Caption = 'Quantity Available (Alt.)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(23; "Qty. on Hand"; Decimal)
        {
            Caption = 'Qty. on Hand';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(24; "Qty. on Hand (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            Caption = 'Qty. on Hand (Alt.)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(31; "Qty. on Purch. Order"; Decimal)
        {
            Caption = 'Qty. on Purch. Order';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(32; "Qty. on Sales Ret. Order"; Decimal)
        {
            Caption = 'Qty. on Sales Ret. Order';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(33; "Qty. on Trans. Order (In)"; Decimal)
        {
            Caption = 'Qty. on Trans. Order (In)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(34; "Qty. on Prod. Order (In)"; Decimal)
        {
            Caption = 'Qty. on Prod. Order (In)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(35; "Qty. on Repack Order (In)"; Decimal)
        {
            Caption = 'Qty. on Repack Order (In)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(36; "Qty. on Line Repack (In)"; Decimal)
        {
            Caption = 'Qty. on Line Repack (In)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(41; "Qty. on Purch. Ret. Order"; Decimal)
        {
            Caption = 'Qty. on Purch. Ret. Order';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(42; "Qty. on Sales Order"; Decimal)
        {
            Caption = 'Qty. on Sales Order';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(43; "Qty. on Trans. Order (Out)"; Decimal)
        {
            Caption = 'Qty. on Trans. Order (Out)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(44; "Qty. on Prod. Order (Out)"; Decimal)
        {
            Caption = 'Qty. on Prod. Order (Out)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(45; "Qty. on Repack Order (Out)"; Decimal)
        {
            Caption = 'Qty. on Repack Order (Out)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(46; "Qty. on Line Repack (Out)"; Decimal)
        {
            Caption = 'Qty. on Line Repack (Out)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(51; "Total Cost"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Total Cost';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(52; "Cost Quantity"; Decimal)
        {
            Caption = 'Cost Quantity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(53; "Unit Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(61; "Source Type"; Option)
        {
            Caption = 'Source Type';
            DataClassification = SystemMetadata;
            Editable = false;
            OptionCaption = ' ,Purchase,Sales Return,Transfer,Production,Repack';
            OptionMembers = " ",Purchase,"Sales Return",Transfer,Production,Repack;
        }
        field(62; "Source Status"; Option)
        {
            Caption = 'Source Status';
            DataClassification = SystemMetadata;
            Editable = false;
            OptionCaption = ' ,Planned,Firm Planned,Released';
            OptionMembers = " ",Planned,"Firm Planned",Released;
        }
        field(63; "Source Document No."; Code[20])
        {
            Caption = 'Source Document No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(101; "Recent Sales Filter"; Boolean)
        {
            Caption = 'Recent Sales Filter';
            FieldClass = FlowFilter;
        }
        field(102; "Last Sale Date"; Date)
        {
            Caption = 'Last Sale Date';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(103; "Last Sale Price"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Last Sale Price';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(104; "Quantity to Sell"; Decimal)
        {
            Caption = 'Quantity to Sell';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            var
                UOMMgt: Codeunit "Unit of Measure Management";
            begin
                // P800133109
                "Quantity to Sell" := UOMMgt.RoundAndValidateQty("Item No.", "Base Unit of Measure", "Quantity to Sell", FieldCaption("Quantity to Sell"));
                UOMMgt.CalcBaseQty("Item No.", "Base Unit of Measure", "Quantity to Sell");
                // P800133109
                if "Quantity to Sell" > "Quantity Available" then
                    Error(Text001, FieldCaption("Quantity to Sell"), FieldCaption("Quantity Available"));
            end;
        }
        field(105; "Unit Price"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(106; "Unit Price to Sell"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price to Sell';
            DataClassification = SystemMetadata;
            MinValue = 0;
        }
        field(37002004; "Item Category Order"; Integer)
        {
            CalcFormula = Lookup ("Item Category"."Presentation Order" WHERE(Code = FIELD("Item Category Code")));
            Caption = 'Item Category Order';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Variant Code", "Lot No.", "Country/Region of Origin Code")
        {
        }
        key(Key2; "Item No.", "Variant Code", "Country Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if "Country/Region of Origin Code" <> '' then
            "Country Code" := "Country/Region of Origin Code"
        else
            "Country Code" := '';
    end;

    var
        Text001: Label '%1 may not exceed %2.';

    procedure GetLotInfo(ItemTracking: Record "Item Tracking Code"; Item: Record Item; CountryOfOrigin: Code[10]; ReceivingReason: Code[10]; FarmText: Text[30]; BrandText: Text[30]; ExpectedReceiptDate: Date)
    var
        LotInfo: Record "Lot No. Information";
    begin
        if LotInfo.Get("Item No.", "Variant Code", "Lot No.") then;

        if "Lot No." <> '' then begin
            if LotInfo."Country/Region of Origin Code" <> '' then
                "Country Code" := LotInfo."Country/Region of Origin Code"
            else
                "Country Code" := CountryOfOrigin;
            if LotInfo."Receiving Reason Code" <> '' then
                "Receiving Reason Code" := LotInfo."Receiving Reason Code"
            else
                "Receiving Reason Code" := ReceivingReason;
            if LotInfo.Farm <> '' then
                Farm := LotInfo.Farm
            else
                Farm := FarmText;
            if LotInfo.Brand <> '' then
                Brand := LotInfo.Brand
            else
                Brand := BrandText;
        end;

        if ItemTracking."Strict Quarantine Posting" then
            if LotInfo."Release Date" <> 0D then
                "Release Date" := LotInfo."Release Date"
            else
                if (Format(Item."Quarantine Calculation") <> '') and (ExpectedReceiptDate <> 0D) then
                    "Release Date" := CalcDate(Item."Quarantine Calculation", ExpectedReceiptDate);
        if ItemTracking."Strict Expiration Posting" then
            if LotInfo."Expiration Date" <> 0D then
                "Expiration Date" := LotInfo."Expiration Date"
            else
                if (Format(Item."Expiration Calculation") <> '') and (ExpectedReceiptDate <> 0D) then
                    "Expiration Date" := CalcDate(Item."Expiration Calculation", ExpectedReceiptDate);
    end;

    procedure Include(ReferenceDate: Date): Boolean
    begin
        exit((("Release Date" = 0D) or ("Release Date" <= ReferenceDate)) and
             (("Expiration Date" = 0D) or (ReferenceDate <= "Expiration Date")))
    end;

    procedure IncrementQty(ItemLotAvail: Record "Item Lot Availability")
    begin
        "Qty. on Hand" += ItemLotAvail."Qty. on Hand";
        "Qty. on Purch. Order" += ItemLotAvail."Qty. on Purch. Order";
        "Qty. on Sales Ret. Order" += ItemLotAvail."Qty. on Sales Ret. Order";
        "Qty. on Trans. Order (In)" += ItemLotAvail."Qty. on Trans. Order (In)";
        "Qty. on Prod. Order (In)" += ItemLotAvail."Qty. on Prod. Order (In)";
        "Qty. on Repack Order (In)" += ItemLotAvail."Qty. on Repack Order (In)";
        "Qty. on Line Repack (In)" += ItemLotAvail."Qty. on Line Repack (In)";
        "Qty. on Purch. Ret. Order" += ItemLotAvail."Qty. on Purch. Ret. Order";
        "Qty. on Sales Order" += ItemLotAvail."Qty. on Sales Order";
        "Qty. on Trans. Order (Out)" += ItemLotAvail."Qty. on Trans. Order (Out)";
        "Qty. on Prod. Order (Out)" += ItemLotAvail."Qty. on Prod. Order (Out)";
        "Qty. on Repack Order (Out)" += ItemLotAvail."Qty. on Repack Order (Out)";
        "Qty. on Line Repack (Out)" += ItemLotAvail."Qty. on Line Repack (Out)";
        "Total Cost" += ItemLotAvail."Total Cost";
        "Cost Quantity" += ItemLotAvail."Cost Quantity";
    end;

    procedure CalculateAvailable()
    var
        Quantity: Decimal;
    begin
        Quantity :=
          ("Qty. on Purch. Order" + "Qty. on Sales Ret. Order" + "Qty. on Trans. Order (In)" +
           "Qty. on Prod. Order (In)" + "Qty. on Repack Order (In)" + "Qty. on Line Repack (In)") -
          ("Qty. on Purch. Ret. Order" + "Qty. on Sales Order" + "Qty. on Trans. Order (Out)" +
           "Qty. on Prod. Order (Out)" + "Qty. on Repack Order (Out)" + "Qty. on Line Repack (Out)");
        "Quantity Available" := "Qty. on Hand" + Quantity;
        if "Alternate Qty. per Base" <> 0 then
            "Quantity Available (Alt.)" := "Qty. on Hand (Alt.)" + (Quantity * "Alternate Qty. per Base");
    end;

    procedure GetLastTransaction(CustNo: Code[20])
    var
        ItemLedger: Record "Item Ledger Entry";
    begin
        ItemLedger.SetCurrentKey("Source Type", "Source No.", "Item No.", "Variant Code", "Posting Date");
        ItemLedger.SetRange("Source Type", ItemLedger."Source Type"::Customer);
        ItemLedger.SetRange("Source No.", CustNo);
        ItemLedger.SetRange("Item No.", "Item No.");
        ItemLedger.SetRange("Variant Code", "Variant Code");
        if ItemLedger.FindLast then begin
            "Last Sale Date" := ItemLedger."Posting Date";
            ItemLedger.CalcFields("Sales Amount (Expected)", "Sales Amount (Actual)");
            //"Last Sale Price" :=                                                                                       // P8000981
            //  (ItemLedger."Sales Amount (Expected)" + ItemLedger."Sales Amount (Actual)") / -ItemLedger.GetCostingQty; // P8000981
            "Last Sale Price" :=                                                                                         // P8000981
              (ItemLedger."Sales Amount (Expected)" + ItemLedger."Sales Amount (Actual)") / -ItemLedger.GetPricingQty;   // P8000981
        end else begin
            "Last Sale Date" := 0D;
            "Last Sale Price" := 0;
        end;
    end;

    procedure SourceReference(): Text[40]
    begin
        if "Source Type" > 0 then
            exit(StrSubstNo('%1 (%2)', "Source Type", "Source Document No."));
    end;

    procedure GetUnitPrice(CustNo: Code[20]; Date: Date)
    var
        Customer: Record Customer;
        Item: Record Item;
        PriceCalcMgt: Codeunit "Sales Price Calc. Mgt.";
    begin
        Item.Get("Item No.");
        "Unit Price" := Item."Unit Price";
        if not Customer.Get(CustNo) then
            exit;

        PriceCalcMgt.FindCustomerPriceListPrice(Item, Customer, "Variant Code", Item."Base Unit of Measure", Date, false);
        if Item."Unit Price" <> 0 then
            "Unit Price" := Item."Unit Price";
    end;

    procedure CountryOfOrigin(): Code[10]
    begin
        if "Country/Region of Origin Code" <> '' then
            exit("Country/Region of Origin Code")
        else
            exit("Country Code");
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
}

