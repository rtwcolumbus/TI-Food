table 37002005 "Sales Statistic Line"
{
    // PRW17.10.01
    // P8001258, Columbus IT, Jack Reynolds, 10 JAN 14
    //   Increase size ot text fields/variables
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Sales Statistic Line';

    fields
    {
        field(1; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = SystemMetadata;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }
        field(4; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = SystemMetadata;
        }
        field(5; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = SystemMetadata;
        }
        field(6; "Unit Price"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Price';
            DataClassification = SystemMetadata;
        }
        field(7; "Unit Price (LCY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price (LCY)';
            DataClassification = SystemMetadata;
        }
        field(8; "Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount (LCY)';
            DataClassification = SystemMetadata;
        }
        field(9; "Line Discount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Line Discount';
            DataClassification = SystemMetadata;
        }
        field(10; "Line Discount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Line Discount (LCY)';
            DataClassification = SystemMetadata;
        }
        field(11; "Line Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Line Amount';
            DataClassification = SystemMetadata;
        }
        field(12; "Line Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Line Amount (LCY)';
            DataClassification = SystemMetadata;
        }
        field(13; "Unit Cost (LCY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost (LCY)';
            DataClassification = SystemMetadata;
        }
        field(14; "Cost (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Cost (LCY)';
            DataClassification = SystemMetadata;
        }
        field(15; "Profit (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Profit (LCY)';
            DataClassification = SystemMetadata;
        }
        field(16; "Profit (%)"; Decimal)
        {
            Caption = 'Profit (%)';
            DataClassification = SystemMetadata;
        }
        field(17; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure ConvertToLCY(UseDate: Date; CurrencyFactor: Decimal)
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        if "Currency Code" <> '' then begin
            "Unit Price (LCY)" := Round(
              CurrExchRate.ExchangeAmtFCYToLCY(UseDate, "Currency Code", "Unit Price", CurrencyFactor));
            "Line Discount (LCY)" := Round(
              CurrExchRate.ExchangeAmtFCYToLCY(UseDate, "Currency Code", "Line Discount", CurrencyFactor));
            "Line Amount (LCY)" := Round(
              CurrExchRate.ExchangeAmtFCYToLCY(UseDate, "Currency Code", "Line Amount", CurrencyFactor));
        end else begin
            "Unit Price (LCY)" := "Unit Price";
            "Line Discount (LCY)" := "Line Discount";
            "Line Amount (LCY)" := "Line Amount";
        end;
    end;

    procedure Calculate()
    begin
        "Amount (LCY)" := "Line Discount (LCY)" + "Line Amount (LCY)";
        "Cost (LCY)" := Round(Quantity * "Unit Cost (LCY)");
        "Profit (LCY)" := "Line Amount (LCY)" - "Cost (LCY)";
        if "Line Amount (LCY)" <> 0 then
            "Profit (%)" := 100 * "Profit (LCY)" / "Line Amount (LCY)"
        else
            "Profit (%)" := 100;
    end;
}

