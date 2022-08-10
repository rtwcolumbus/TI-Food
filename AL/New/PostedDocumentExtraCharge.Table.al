table 37002665 "Posted Document Extra Charge"
{
    // PR4.00.06
    // P8000487A, VerticalSoft, Jack Reynolds, 12 JUN 07
    //   Multi-currency support for extra charges
    // 
    // PRW16.00.05
    // P8000928, Columbus IT, Jack Reynolds, 06 APR 11
    //   Support for extra charges on transfer orders

    Caption = 'Posted Document Extra Charge';
    DrillDownPageID = "Pstd. Doc. Line Extra Charges";
    LookupPageID = "Pstd. Doc. Line Extra Charges";

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; "Extra Charge Code"; Code[10])
        {
            Caption = 'Extra Charge Code';
        }
        field(5; "Charge (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Charge (LCY)';
        }
        field(6; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;
        }
        field(7; "Allocation Method"; Option)
        {
            Caption = 'Allocation Method';
            OptionCaption = ' ,Amount,Quantity,Weight,Volume';
            OptionMembers = " ",Amount,Quantity,Weight,Volume;
        }
        field(8; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(9; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
        }
        field(10; Charge; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Charge';
        }
    }

    keys
    {
        key(Key1; "Table ID", "Document No.", "Line No.", "Extra Charge Code")
        {
            SumIndexFields = "Charge (LCY)", Charge;
        }
    }

    fieldgroups
    {
    }

    var
        CurrExchRate: Record "Currency Exchange Rate";

    procedure UpdateCurrencyFactor(PostingDate: Date)
    begin
        // P8000487A
        if "Currency Code" <> '' then
            "Currency Factor" := CurrExchRate.ExchangeRate(PostingDate, "Currency Code")
        else
            "Currency Factor" := 0;
    end;

    procedure ChargeLCYToCharge(PostingDate: Date)
    var
        Currency2: Record Currency;
    begin
        // P8000487A
        if "Currency Code" <> '' then begin
            Currency2.Get("Currency Code");
            Charge :=
              Round(
                CurrExchRate.ExchangeAmtLCYToFCY(PostingDate, "Currency Code", "Charge (LCY)", "Currency Factor"),
                Currency2."Amount Rounding Precision")
        end else begin
            Currency2.InitRoundingPrecision;
            Charge :=
              Round("Charge (LCY)", Currency2."Amount Rounding Precision");
        end;
    end;
}

