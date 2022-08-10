report 5854 "Roll Up Standard Cost"
{
    // PR4.00.04
    // P8000390A, VerticalSoft, Jack Reynolds, 27 SEP 06
    //   Set New Overhead Rate on worksheet lines
    // 
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // PRW17.10.02
    // P8001298, Columbus IT, Jack Reynolds, 26 FEB 14
    //   Fix problems with SKUs

    Caption = 'Roll Up Standard Cost';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Costing Method";

            trigger OnPostDataItem()
            begin
                if not NoMessage then
                    if RolledUp then
                        Message(Text000)
                    else
                        Message(Text001);
            end;

            trigger OnPreDataItem()
            begin
                StdCostWksh.LockTable();
                Clear(CalcStdCost);
                CalcStdCost.SetProperties(CalculationDate, true, false, false, ToStdCostWkshName, true);
                CalcStdCost.CalcItems(Item, TempSKU); // P8001030

                TempSKU.SetFilter("Replenishment System", '%1|%2|%3', // P8001030, P8001298
                  TempSKU."Replenishment System"::Transfer,          // P8001030, P8001298
                  TempSKU."Replenishment System"::"Prod. Order",     // P8001030
                  TempSKU."Replenishment System"::Assembly);         // P8001030
                if TempSKU.Find('-') then                            // P8001030
                    repeat
                        UpdateStdCostWksh;
                        RolledUp := true;
                    until TempSKU.Next() = 0; // P8001030
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(CalculationDate; CalculationDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Calculation Date';
                        ToolTip = 'Specifies the date you want the cost shares to be calculated.';

                        trigger OnValidate()
                        begin
                            if CalculationDate = 0D then
                                Error(Text002);
                        end;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            if CalculationDate = 0D then
                CalculationDate := WorkDate;
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    var
        StdCostWkshName: Record "Standard Cost Worksheet Name";
    begin
        RolledUp := false;

        if ToStdCostWkshName = '' then
            Error(Text003);
        StdCostWkshName.Get(ToStdCostWkshName);
    end;

    var
        TempSKU: Record "Stockkeeping Unit" temporary;
        StdCostWksh: Record "Standard Cost Worksheet";
        CalcStdCost: Codeunit "Calculate Standard Cost";
        CalculationDate: Date;
        ToStdCostWkshName: Code[10];
        RolledUp: Boolean;
        Text000: Label 'The standard costs have been rolled up successfully.';
        Text001: Label 'There is nothing to roll up.';
        Text002: Label 'You must enter a calculation date.';
        Text003: Label 'You must specify a worksheet name to roll up to.';
        NoMessage: Boolean;

    local procedure UpdateStdCostWksh()
    var
        Found: Boolean;
    begin
        // P8001030 - TempItem replaced by TempSKU throughout, individual lines not commented
        with StdCostWksh do begin
            Found := Get(ToStdCostWkshName, Type::Item, TempSKU."Item No.", TempSKU."Location Code", TempSKU."Variant Code"); // P8001030
            Validate("Standard Cost Worksheet Name", ToStdCostWkshName);
            Validate(Type, Type::Item);
            // P8001030
            "No." := TempSKU."Item No.";
            "Location Code" := TempSKU."Location Code";
            "Variant Code" := TempSKU."Variant Code";
            if ("Location Code" <> '') or ("Variant Code" <> '') then
                ValidateSKU
            else
                // P8001030
                Validate("No."); // P8001030

            "New Standard Cost" := TempSKU."Standard Cost";

            "New Single-Lvl Material Cost" := TempSKU."Single-Level Material Cost";
            "New Single-Lvl Cap. Cost" := TempSKU."Single-Level Capacity Cost";
            "New Single-Lvl Subcontrd Cost" := TempSKU."Single-Level Subcontrd. Cost";
            "New Single-Lvl Cap. Ovhd Cost" := TempSKU."Single-Level Cap. Ovhd Cost";
            "New Single-Lvl Mfg. Ovhd Cost" := TempSKU."Single-Level Mfg. Ovhd Cost";

            "New Rolled-up Material Cost" := TempSKU."Rolled-up Material Cost";
            "New Rolled-up Cap. Cost" := TempSKU."Rolled-up Capacity Cost";
            "New Rolled-up Subcontrd Cost" := TempSKU."Rolled-up Subcontracted Cost";
            "New Rolled-up Cap. Ovhd Cost" := TempSKU."Rolled-up Cap. Overhead Cost";
            "New Rolled-up Mfg. Ovhd Cost" := TempSKU."Rolled-up Mfg. Ovhd Cost";

            "New Overhead Rate" := TempSKU."Overhead Rate"; // P8000390A

            if Found then
                Modify(true)
            else
                Insert(true);
        end;
    end;

    procedure SetStdCostWksh(NewStdCostWkshName: Code[10])
    begin
        ToStdCostWkshName := NewStdCostWkshName;
    end;

    procedure Initialize(StdCostWkshName2: Code[10]; NoMessage2: Boolean)
    begin
        ToStdCostWkshName := StdCostWkshName2;
        NoMessage := NoMessage2;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateStdCostWkshOnAfterFieldsPopulated(var StdCostWksh: Record "Standard Cost Worksheet"; TempItem: Record Item temporary)
    begin
    end;
}

