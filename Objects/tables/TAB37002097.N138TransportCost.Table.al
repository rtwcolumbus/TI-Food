table 37002097 "N138 Transport Cost"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 09-10-2014, Initial Version
    // --------------------------------------------------------------------------------
    // TOM4524     29-10-2014  Cleanup field names/captions
    // --------------------------------------------------------------------------------
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Transport Cost';
    DataCaptionFields = "No.";
    DrillDownPageID = "N138 Transport Costs";
    LookupPageID = "N138 Transport Costs";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = IF ("Source Type" = CONST(11028582)) "N138 Delivery Trip" WHERE("No." = FIELD("No."));
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Cost Component,Cost Component Template';
            OptionMembers = "Cost Component","Cost Component Template";
        }
        field(4; "Code"; Code[20])
        {
            Caption = 'Code';
            TableRelation = IF (Type = CONST("Cost Component Template")) "N138 Trans. Cost Comp Template".Code WHERE(Status = CONST(Certified))
            ELSE
            IF (Type = CONST("Cost Component")) "N138 Transport Cost Component".Code WHERE(Blocked = CONST(false));

            trigger OnValidate()
            var
                lRecTransCostComp: Record "N138 Transport Cost Component";
                lRecTransCCTemp: Record "N138 Trans. Cost Comp Template";
            begin
                if Code <> '' then begin
                    if Type = Type::"Cost Component" then begin
                        if lRecTransCostComp.Get(Code) then begin
                            Description := lRecTransCostComp.Description;
                            "G/L Account No." := lRecTransCostComp."G/L Account No.";
                        end;
                    end else begin
                        if lRecTransCCTemp.Get(Code) then begin
                            Description := lRecTransCCTemp.Description;
                            "G/L Account No." := lRecTransCCTemp."G/L Account No.";
                            gFncUpdateAmount;
                        end;
                    end;
                end else
                    Description := '';
            end;
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(6; Amount; Decimal)
        {
            Caption = 'Amount';

            trigger OnValidate()
            begin
                if CurrFieldNo = FieldNo(Amount) then
                    TestField(Type, Type::"Cost Component");
                lFncCalcAmountLCY;
            end;
        }
        field(7; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
        }
        field(8; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;

            trigger OnValidate()
            begin
                lFncCalcAmountLCY;
            end;
        }
        field(9; Subtype; Option)
        {
            Caption = 'Subtype';
            OptionCaption = '0,1,2,3,4,5,6,7,8,9,10';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9","10";
        }
        field(10; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.';
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true));
        }
        field(16; "Source Type"; Integer)
        {
            Caption = 'Source Type';
        }
    }

    keys
    {
        key(Key1; "Source Type", Subtype, "No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure gFncUpdateAmount()
    var
        lRecTransCCTempLine: Record "N138 Trans. CC Template Line";
        lRecTransportCost: Record "N138 Transport Cost";
        lRecTransCCTemp: Record "N138 Trans. Cost Comp Template";
        lDecAmount: Decimal;
    begin
        lRecTransCCTemp.Get(Code);
        lRecTransCCTempLine.SetRange("Template Code", Code);
        lRecTransCCTempLine.SetFilter("Transport Cost Component", '<>%1', '');
        if lRecTransCCTempLine.FindSet then begin
            lRecTransportCost.SetRange("No.", "No.");
            lRecTransportCost.SetRange(Type, lRecTransportCost.Type::"Cost Component");
            repeat
                lRecTransportCost.SetRange(Code, lRecTransCCTempLine."Transport Cost Component");
                if lRecTransportCost.FindSet then
                    repeat
                        lDecAmount += lRecTransportCost.Amount;
                    until lRecTransportCost.Next = 0;
            until lRecTransCCTempLine.Next = 0;
            Validate(Amount, (lRecTransCCTemp.Percentage * lDecAmount) / 100);
        end;
    end;

    local procedure lFncCalcAmountLCY()
    var
        lRecCurrency: Record Currency;
        lRecCurrExchRate: Record "Currency Exchange Rate";
    begin
        if "Currency Code" <> '' then begin
            lRecCurrency.InitRoundingPrecision;
            "Amount (LCY)" :=
              Round(
                lRecCurrExchRate.ExchangeAmtFCYToLCY(
                  WorkDate, "Currency Code",
                  Amount, lRecCurrExchRate.ExchangeRate(WorkDate, "Currency Code")),
                lRecCurrency."Amount Rounding Precision")
        end else
            "Amount (LCY)" := Amount;
    end;
}

