table 37002053 "Sales Contract"
{
    // PRW16.00.05
    // P8000986, Columbus IT, Jack Reynolds, 21 OCT 11
    //   Check for existence of sales lines before allowing changes
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Sales Contract';
    DataCaptionFields = "No.", Description; // P800-MegaApp

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                if ("No." <> xRec."No.") then begin
                    SalesSetup.Get;
                    NoSeriesMgt.TestManual(SalesSetup."Sales Contract Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Starting Date"; Date)
        {
            Caption = 'Starting Date';

            trigger OnValidate()
            begin
                if "Starting Date" <> xRec."Starting Date" then
                    UpdatePriceLines(CurrFieldNo);
            end;
        }
        field(4; "Ending Date"; Date)
        {
            Caption = 'Ending Date';

            trigger OnValidate()
            begin
                if "Ending Date" <> xRec."Ending Date" then
                    UpdatePriceLines(CurrFieldNo);
            end;
        }
        field(5; "Contract Limit"; Decimal)
        {
            Caption = 'Contract Limit';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                if ("Contract Limit" <> 0) and ("Contract Limit Unit of Measure" = '') then
                    Error(Text002, FieldCaption("Contract Limit Unit of Measure"));
                if ("Contract Limit" <> xRec."Contract Limit") and
                   ("Contract Limit" <> 0) and
                   ("Contract Limit" < CalcLimitUsed)
                then
                    Error(Text001);
            end;
        }
        field(6; "Contract Limit Unit of Measure"; Code[10])
        {
            Caption = 'Contract Limit Unit of Measure';
            TableRelation = "Unit of Measure";

            trigger OnValidate()
            begin
                if "Contract Limit Unit of Measure" <> xRec."Contract Limit Unit of Measure" then
                    if HistoryExists then
                        Error(Text000, FieldCaption("Contract Limit Unit of Measure"));
                CheckUOM("Contract Limit Unit of Measure");
            end;
        }
        field(7; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(8; "Sales Type"; Option)
        {
            Caption = 'Sales Type';
            OptionCaption = 'Customer,Customer Price Group,All Customers,Campaign';
            OptionMembers = Customer,"Customer Price Group","All Customers",Campaign;

            trigger OnValidate()
            begin
                if "Sales Type" <> xRec."Sales Type" then
                    UpdatePriceLines(CurrFieldNo);
            end;
        }
        field(9; "Sales Code"; Code[20])
        {
            Caption = 'Sales Code';
            TableRelation = IF ("Sales Type" = CONST("Customer Price Group")) "Customer Price Group"
            ELSE
            IF ("Sales Type" = CONST(Customer)) Customer
            ELSE
            IF ("Sales Type" = CONST(Campaign)) Campaign;

            trigger OnValidate()
            begin
                if "Sales Code" <> xRec."Sales Code" then
                    UpdatePriceLines(CurrFieldNo);
            end;
        }
        field(10; "Limit Used"; Decimal)
        {
            CalcFormula = Sum ("Sales Contract History"."Quantity (Contract)" WHERE("Contract No." = FIELD("No.")));
            Caption = 'Limit Used';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; "Sales Type", "Sales Code", "Starting Date", "Ending Date")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if SalesLinesExists then
            Error(Text005, TableCaption);
        SalesContLine.SetRange("Contract No.", "No.");
        SalesContLine.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        SalesCont.Reset;
        if SalesCont.IsEmpty then begin
            SalesPrice.SetCurrentKey("Contract No.");
            SalesPrice.SetFilter("Price Type", '>%1', SalesPrice."Price Type"::Normal);
            SalesPrice.SetRange("Contract No.", '');
            if not SalesPrice.IsEmpty then
                Error(Text004);
        end;

        if "No." = '' then begin
            SalesSetup.Get;
            SalesSetup.TestField("Sales Contract Nos.");
            NoSeriesMgt.InitSeries(SalesSetup."Sales Contract Nos.", '', 0D, "No.", "No. Series");
        end;
    end;

    var
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        SalesCont: Record "Sales Contract";
        Text000: Label '%1 Cannot be changed when History exists! ';
        Text001: Label 'You cannot make this change because contract limits will be exceeded.';
        Text002: Label 'You must first specify the %1';
        Text003: Label 'The Unit of Measure %1 will not convert for one or more Contract Lines.';
        SalesPrice: Record "Sales Price";
        Text004: Label 'You cannot create Sales Contracts while Sales Prices with Price Type of Contract or Soft Contract exists, that are not associated with a Sales Contract exists. Please contact your system administrator for assistance.';
        SalesContLine: Record "Sales Contract Line";
        Text005: Label 'You cannot delete this %1 because it is associated with one or more Sales Document.';
        Text006: Label 'You cannot modify this %1 because it is associated with one or more Sales Document.';

    procedure AssistEdit(OldSalesContract: Record "Sales Contract"): Boolean
    begin
        with SalesCont do begin
            SalesCont := Rec;
            SalesSetup.Get;
            SalesSetup.TestField("Sales Contract Nos.");
            if NoSeriesMgt.SelectSeries(SalesSetup."Sales Contract Nos.", OldSalesContract."No. Series", "No. Series") then begin
                NoSeriesMgt.SetSeries("No.");
                Rec := SalesCont;
                exit(true);
            end;
        end;
    end;

    procedure HistoryExists(): Boolean
    var
        SalesContHist: Record "Sales Contract History";
    begin
        SalesContHist.SetCurrentKey("Contract No.");
        SalesContHist.SetRange("Contract No.", "No.");
        exit(not SalesContHist.IsEmpty);
    end;

    procedure LimitReached(): Boolean
    begin
        if "Contract Limit" = 0 then
            exit(false);
        exit(CalcLimitUsed >= "Contract Limit");
    end;

    procedure CalcLimitUsed(): Decimal
    begin
        CalcFields("Limit Used");
        exit("Limit Used" + CalcSalesDocLimitUsed);
    end;

    procedure CalcSalesDocLimitUsed() LimitUsed: Decimal
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetCurrentKey("Contract No.", "Price ID");
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Contract No.", "No.");
        SalesLine.CalcSums("Outstanding Qty. (Contract)");
        LimitUsed += SalesLine."Outstanding Qty. (Contract)";

        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Invoice);
        SalesLine.CalcSums("Outstanding Qty. (Contract)");
        LimitUsed += SalesLine."Outstanding Qty. (Contract)";

        SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Return Order");
        SalesLine.CalcSums("Outstanding Qty. (Contract)");
        LimitUsed -= SalesLine."Outstanding Qty. (Contract)";

        SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Credit Memo");
        SalesLine.CalcSums("Outstanding Qty. (Contract)");
        LimitUsed -= SalesLine."Outstanding Qty. (Contract)";
    end;

    procedure CheckUOM(UOMCode: Code[10])
    var
        ItemUOM: Record "Item Unit of Measure";
        ContractLineUOM: Record "Unit of Measure";
        UOM: Record "Unit of Measure";
        ContractLine: Record "Sales Contract Line";
    begin
        if UOMCode = '' then
            exit;
        UOM.Get(UOMCode);
        ContractLine.SetRange("Contract No.", "No.");
        ContractLine.SetRange("Item Type", ContractLine."Item Type"::Item);
        if ContractLine.FindSet then
            repeat
                if not ItemUOM.Get(ContractLine."Item Code", UOMCode) then
                    if UOM.Type = UOM.Type::" " then
                        Error(Text003, UOMCode)
                    else
                        if ContractLineUOM.Get(ContractLine."Line Limit Unit of Measure") and
                           (ContractLineUOM.Type <> UOM.Type)
                   then
                            Error(Text003, UOMCode)
            until ContractLine.Next = 0;
    end;

    procedure UpdatePriceLines(ChangedFiledNo: Integer)
    var
        SalesPrice2: Record "Sales Price";
    begin
        if SalesLinesExists then       // P8000986
            Error(Text006, TableCaption); // P8000986

        SalesPrice.Reset;
        SalesPrice.SetCurrentKey("Contract No.");
        SalesPrice.SetRange("Contract No.", "No.");
        if SalesPrice.FindSet then
            repeat
                case ChangedFiledNo of
                    FieldNo("Ending Date"):
                        begin
                            SalesPrice."Ending Date" := "Ending Date";
                            SalesPrice.Modify;
                        end;
                    FieldNo("Starting Date"):
                        begin
                            SalesPrice2 := SalesPrice;
                            SalesPrice.Delete;
                            SalesPrice2."Starting Date" := "Starting Date";
                            SalesPrice2."Price ID" := 0; // P8000986
                            SalesPrice2.Insert;
                        end;
                    FieldNo("Sales Type"):
                        begin
                            SalesPrice2 := SalesPrice;
                            SalesPrice.Delete;
                            SalesPrice2."Sales Type" := "Sales Type";
                            SalesPrice2."Price ID" := 0; // P8000986
                            SalesPrice2.Insert;
                        end;
                    FieldNo("Sales Code"):
                        begin
                            SalesPrice2 := SalesPrice;
                            SalesPrice.Delete;
                            SalesPrice2.Validate("Sales Code", "Sales Code");
                            SalesPrice2."Price ID" := 0; // P8000986
                            SalesPrice2.Insert;
                        end;
                end;
            until SalesPrice.Next = 0;
    end;

    procedure SalesLinesExists(): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetCurrentKey("Contract No.");
        SalesLine.SetRange("Contract No.", "No.");
        exit(not SalesLine.IsEmpty);
    end;
}

