table 37002050 "Cost Calculation Method"
{
    // PR5.00
    // P8000539A, VerticalSoft, Don Bresee, 17 NOV 07
    //   New table for extended cost based sales pricing mechanism
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Cost Calculation Method';
    DataCaptionFields = "Code", Description;
    DrillDownPageID = "Cost Calculation Method List";
    LookupPageID = "Cost Calculation Method List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Cost Basis Code"; Code[20])
        {
            Caption = 'Cost Basis Code';
            TableRelation = "Cost Basis";
        }
        field(4; "Cost Date Formula"; Code[20])
        {
            Caption = 'Cost Date Formula';
            DateFormula = true;
        }
        field(5; "Day of Week Restriction"; Option)
        {
            Caption = 'Day of Week Restriction';
            OptionCaption = ' ,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday';
            OptionMembers = " ",Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday;
        }
        field(6; Calculate; Option)
        {
            Caption = 'Calculate';
            OptionCaption = 'Most Recent,Average';
            OptionMembers = "Most Recent","Average";
        }
        field(7; "Calculation Period"; Code[20])
        {
            Caption = 'Calculation Period';
            DateFormula = true;
        }
        field(8; "Cost Calc. Item No."; Code[20])
        {
            Caption = 'Cost Calc. Item No.';
            TableRelation = Item;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
        key(Key2; "Cost Basis Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnModify()
    begin
        if ("Cost Basis Code" <> '') and (Calculate = Calculate::Average) then
            TestField("Calculation Period");
    end;

    procedure GetReferenceDates(PriceDate: Date; var StartDate: Date; var EndDate: Date)
    var
        Day: Integer;
    begin
        EndDate := PriceDate;
        if ("Cost Date Formula" <> '') then
            EndDate := CalcDate("Cost Date Formula", EndDate);
        if ("Calculation Period" = '') then
            StartDate := 0D
        else
            StartDate := CalcDate('-(' + "Calculation Period" + ')', EndDate) + 1;
        if ("Day of Week Restriction" <> 0) then begin
            Day := Date2DWY(EndDate, 1);
            if (Day < "Day of Week Restriction") then
                EndDate := EndDate - (Day + 7 - "Day of Week Restriction")
            else
                EndDate := EndDate - (Day - "Day of Week Restriction");
        end;
    end;

    procedure CalculateCostValue(CostBasisCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; StartDate: Date; EndDate: Date): Decimal
    var
        ItemCostBasis: Record "Item Cost Basis";
        TotalCost: Decimal;
        NumCosts: Integer;
        LastCostDate: Date;
        LastCost: Decimal;
        ItemCostBasis2: Record "Item Cost Basis";
        NumSkippedDays: Integer;
    begin
        ItemCostBasis.SetRange("Cost Basis Code", CostBasisCode);
        if ("Cost Calc. Item No." <> '') then begin
            ItemCostBasis.SetRange("Item No.", "Cost Calc. Item No.");
            ItemCostBasis.SetRange("Variant Code", '');
        end else begin
            ItemCostBasis.SetRange("Item No.", ItemNo);
            ItemCostBasis.SetRange("Variant Code", VariantCode);
        end;
        case Calculate of
            Calculate::"Most Recent":
                begin
                    ItemCostBasis.SetRange("Cost Date", StartDate, EndDate);
                    if ItemCostBasis.FindLast then
                        exit(ItemCostBasis."Cost Value" * GetCostQtyPerPriceQty(ItemNo));
                end;
            Calculate::Average:
                if (StartDate <> 0D) then begin
                    ItemCostBasis.SetRange("Cost Date", 0D, EndDate);
                    if ItemCostBasis.Find('+') then begin
                        TotalCost := 0;
                        NumCosts := 0;
                        repeat
                            while (EndDate < ItemCostBasis."Cost Date") do
                                if (ItemCostBasis.Next(-1) = 0) then
                                    exit((TotalCost / NumCosts) * GetCostQtyPerPriceQty(ItemNo));
                            TotalCost := TotalCost + ItemCostBasis."Cost Value";
                            NumCosts := NumCosts + 1;
                            if ("Day of Week Restriction" = 0) then
                                EndDate := EndDate - 1
                            else
                                EndDate := EndDate - 7;
                        until (EndDate < StartDate);
                        exit((TotalCost / NumCosts) * GetCostQtyPerPriceQty(ItemNo));
                    end;
                end;
        end;
        exit(0);
    end;

    local procedure GetCostQtyPerPriceQty(ItemNo: Code[20]): Decimal
    var
        ItemCostCalcFactor: Record "Item Cost Conversion Factor";
    begin
        if ("Cost Calc. Item No." <> '') then
            if ItemCostCalcFactor.Get("Cost Calc. Item No.", ItemNo) then
                exit(ItemCostCalcFactor."Costing Qty." / ItemCostCalcFactor."Equivalent Pricing Qty.");
        exit(1);
    end;
}

