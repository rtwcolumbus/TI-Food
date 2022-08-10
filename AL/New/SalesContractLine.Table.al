table 37002054 "Sales Contract Line"
{
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    //   Correct misspellings
    // 
    // PRW110.0.01
    // P80042410, To-Increase, Dayakar Battini, 05 JUL 17
    //   Fix for contract line limit functionality.

    Caption = 'Sales Contract Line';

    fields
    {
        field(1; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "Sales Contract"."No.";
        }
        field(2; "Item Type"; Option)
        {
            Caption = 'Item Type';
            OptionCaption = 'Item,Item Category,,,All Items';
            OptionMembers = Item,"Item Category",,,"All Items";
        }
        field(3; "Item Code"; Code[20])
        {
            Caption = 'Item Code';
            TableRelation = IF ("Item Type" = CONST(Item)) Item
            ELSE
            IF ("Item Type" = CONST("Item Category")) "Item Category";

            trigger OnValidate()
            begin
                SalesCont.Get("Contract No.");
                CheckUOM(SalesCont."Contract Limit Unit of Measure");
                CheckUOM("Line Limit Unit of Measure");
            end;
        }
        field(5; "Line Limit"; Decimal)
        {
            Caption = 'Line Limit';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                if ("Line Limit" <> 0) and ("Line Limit Unit of Measure" = '') then
                    Error(Text002, FieldCaption("Line Limit Unit of Measure"));
                if ("Line Limit" <> xRec."Line Limit") and
                  ("Line Limit" <> 0) and
                  ("Line Limit" < CalcLimitUsed)
                then
                    Error(Text005);
            end;
        }
        field(6; "Line Limit Unit of Measure"; Code[10])
        {
            Caption = 'Line Limit Unit of Measure';
            TableRelation = IF ("Item Type" = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item Code"))
            ELSE
            "Unit of Measure";

            trigger OnValidate()
            begin
                if "Line Limit Unit of Measure" <> xRec."Line Limit Unit of Measure" then
                    if HistoryExists then
                        Error(Text000, FieldCaption("Line Limit Unit of Measure"));
                CheckUOM("Line Limit Unit of Measure");
                ;
            end;
        }
        field(7; "Line Limit Used"; Decimal)
        {
            CalcFormula = Sum ("Sales Contract History"."Quantity (Contract Line)" WHERE("Contract No." = FIELD("Contract No."),
                                                                                         "Item Type" = FIELD("Item Type"),
                                                                                         "Item Code" = FIELD("Item Code")));
            Caption = 'Line Limit Used';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(8; "Limit Type"; Option)
        {
            Caption = 'Limit Type';
            Description = 'P80042410';
            OptionCaption = ' ,per Order';
            OptionMembers = " ","per Order";
        }
        field(24; "Document Type Filter"; Option)
        {
            Caption = 'Document Type Filter';
            Description = 'P80042410';
            FieldClass = FlowFilter;
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order,Standing Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order","Standing Order";
        }
        field(25; "Document No. Filter"; Code[20])
        {
            Caption = 'Document No. Filter';
            Description = 'P80042410';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(Key1; "Contract No.", "Item Type", "Item Code")
        {
        }
        key(Key2; "Item Type", "Item Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        SalesPrice.SetCurrentKey("Contract No.");
        SalesPrice.SetRange("Contract No.", "Contract No.");
        SalesPrice.SetRange("Item Type", "Item Type");
        SalesPrice.SetRange("Item Code", "Item Code");
        //SalesPrice.SETRANGE("Item Code 2","Item Code 2"); // P8007749
        SalesPrice.DeleteAll(true);
    end;

    trigger OnRename()
    begin
        Error(Text001, TableCaption);
    end;

    var
        Text000: Label '%1 Cannot be changed when History exists! ';
        SalesCont: Record "Sales Contract";
        Text001: Label 'You cannot rename a %1.';
        Text002: Label 'You must first specify the %1';
        Text003: Label 'An Item Unit of Measure is not setup for Item No. %1 Unit of Measure %2!';
        Text004: Label 'The type of Unit of Measure Code %1 does not match the type for Unit of Measure Code %2';
        SalesPrice: Record "Sales Price";
        Text005: Label 'You cannot make this change because contract limits will be exceeded.';
        CurrentDocType: Integer;
        CurrentDocNo: Code[20];

    procedure HistoryExists(): Boolean
    var
        SalesContHist: Record "Sales Contract History";
    begin
        SalesContHist.SetCurrentKey("Contract No.", "Item Type", "Item Code"); // P8007749
        SalesContHist.SetRange("Contract No.", "Contract No.");
        SalesContHist.SetRange("Item Type", "Item Type");
        SalesContHist.SetRange("Item Code", "Item Code");
        //SalesContHist.SETRANGE("Item Code 2","Item Code 2"); // P8007749
        exit(not SalesContHist.IsEmpty);
    end;

    procedure CheckUOM(UOMCode: Code[10])
    var
        ItemUOM: Record "Item Unit of Measure";
        ContractUOM: Record "Unit of Measure";
        UOM: Record "Unit of Measure";
    begin
        if ("Item Type" <> "Item Type"::Item) or ("Item Code" = '') or (UOMCode = '') then
            exit;
        UOM.Get(UOMCode);
        if (UOM.Type = UOM.Type::" ") and not ItemUOM.Get("Item Code", UOMCode) then begin
            Error(Text003, "Item Code", UOMCode);
        end else begin
            if not ItemUOM.Get("Item Code", UOMCode) then begin
                SalesCont.Get("Contract No.");
                if ContractUOM.Get(SalesCont."Contract Limit Unit of Measure") then
                    if ContractUOM.Type <> UOM.Type then
                        Error(Text004, UOMCode, ContractUOM.Code);
            end;
        end;
    end;

    procedure LimitReached(): Boolean
    begin
        if "Line Limit" = 0 then
            exit(false);
        exit(CalcLimitUsed >= "Line Limit");
    end;

    procedure CalcLimitUsed(): Decimal
    begin
        CalcFields("Line Limit Used");
        // P80042410
        if (CurrentDocNo <> '') then
            exit(CalcSalesDocLimitUsedperOrder);
        // P80042410
        exit(CalcSalesDocLimitUsed + "Line Limit Used");
    end;

    procedure CalcSalesDocLimitUsed() LimitUsed: Decimal
    var
        SalesLine: Record "Sales Line";
        SalesPrice: Record "Sales Price";
    begin
        SalesPrice.SetCurrentKey("Contract No.");
        SalesPrice.SetRange("Contract No.", "Contract No.");
        SalesPrice.SetRange("Item Type", "Item Type");
        SalesPrice.SetRange("Item Code", "Item Code");
        //SalesPrice.SETRANGE("Item Code 2","Item Code 2"); // P8007749
        if SalesPrice.FindSet then
            repeat
                SalesLine.SetCurrentKey("Contract No.", "Price ID");
                SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
                SalesLine.SetRange("Price ID", SalesPrice."Price ID");
                SalesLine.CalcSums("Outstanding Qty. (Cont. Line)");
                LimitUsed += SalesLine."Outstanding Qty. (Cont. Line)";

                SalesLine.SetRange("Document Type", SalesLine."Document Type"::Invoice);
                SalesLine.SetRange("Price ID", SalesPrice."Price ID");
                SalesLine.CalcSums("Outstanding Qty. (Cont. Line)");
                LimitUsed += SalesLine."Outstanding Qty. (Cont. Line)";

                SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Return Order");
                SalesLine.SetRange("Price ID", SalesPrice."Price ID");
                SalesLine.CalcSums("Outstanding Qty. (Cont. Line)");
                LimitUsed -= SalesLine."Outstanding Qty. (Cont. Line)";

                SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Credit Memo");
                SalesLine.SetRange("Price ID", SalesPrice."Price ID");
                SalesLine.CalcSums("Outstanding Qty. (Cont. Line)");
                LimitUsed -= SalesLine."Outstanding Qty. (Cont. Line)";
            until SalesPrice.Next = 0;
    end;

    procedure ApplyDocfilters(DocType: Integer; DocNo: Code[20])
    begin
        // P80042410
        if ("Limit Type" <> "Limit Type"::"per Order") then
            exit;
        CurrentDocType := DocType;
        CurrentDocNo := DocNo;
        // P80042410
    end;

    procedure CalcSalesDocLimitUsedperOrder() LimitUsed: Decimal
    var
        SalesLine: Record "Sales Line";
        SalesPrice: Record "Sales Price";
    begin
        // P80042410
        SalesPrice.SetCurrentKey("Contract No.");
        SalesPrice.SetRange("Contract No.", "Contract No.");
        SalesPrice.SetRange("Item Type", "Item Type");
        SalesPrice.SetRange("Item Code", "Item Code");
        if SalesPrice.FindSet then
            repeat
                SalesLine.SetCurrentKey("Contract No.", "Price ID");
                SalesLine.SetRange("Document Type", CurrentDocType);
                SalesLine.SetRange("Document No.", CurrentDocNo);
                ;
                SalesLine.SetRange("Price ID", SalesPrice."Price ID");
                SalesLine.CalcSums("Outstanding Qty. (Cont. Line)");
                LimitUsed += SalesLine."Outstanding Qty. (Cont. Line)";
            until SalesPrice.Next = 0;
        // P80042410
    end;
}

