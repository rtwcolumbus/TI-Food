report 37002465 "Formula Version Details"
{
    // PR1.00.01
    //   Separate section for text lines
    // 
    // PR1.20
    //   Change Gain/Loss labels to Yield
    // 
    // PR2.00
    //   Text Constants
    // 
    // PR4.00
    // P8000219A, Myers Nissi, Jack Reynolds, 24 JUN 05
    //   Filter costs by costing equipment
    //   Activity line quantity is extended by resource multiplier
    // 
    // PR4.00.04
    // P8000379A, VerticalSoft, Jack Reynolds, 21 SEP 06
    //   Fix calculation of ABC per unit
    //   Add variable production time
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 06 APR 10
    //   RTC Reporting Upgrade
    // 
    // PRW16.00.04
    // P8000837, VerticalSoft, Jack Reynolds, 07 JUL 10
    //   RDLC layout issues
    // 
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // PRW19.00.01
    // P8007742, To-Increase, Dayakar Battini, 11 OCT 16
    //   ? character removed from "Include In Cost Rollup?" field
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // P8008027, To-Increase, Dayakar Battini, 15 NOV 16
    //   Fix cost calculations on RDLC layout
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    DefaultRenderingLayout = StandardRDLCLayout;

    ApplicationArea = FOODBasic;
    Caption = 'Formula Version Details';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Production BOM Version"; "Production BOM Version")
        {
            DataItemTableView = WHERE(Type = CONST(Formula));
            PrintOnlyIfDetail = false;
            RequestFilterFields = "Production BOM No.", "Version Code";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            column(ProdBOMVersionProdBOMNo; "Production BOM No.")
            {
            }
            column(ProdBOMVersionVersionCode; "Version Code")
            {
                IncludeCaption = true;
            }
            column(ProdBOMVersionDesc; Description)
            {
            }
            column(ProdBOMVersionStartingDate; "Starting Date")
            {
                IncludeCaption = true;
            }
            column(ProdBOMVersionLastDateModified; "Last Date Modified")
            {
                IncludeCaption = true;
            }
            column(ProdBOMVersionStatus; Status)
            {
                IncludeCaption = true;
            }
            column(ProdBOMVersionWeightUOM; "Weight UOM")
            {
            }
            column(ProdBOMVersionVolumeUOM; "Volume UOM")
            {
            }
            column(ProdBOMVersionYieldWeight; "Yield % (Weight)")
            {
            }
            column(ProdBOMVersionYieldVolume; "Yield % (Volume)")
            {
            }
            column(ProdBOMVersionPrimaryUOM; "Primary UOM")
            {
                IncludeCaption = true;
            }
            column(ProdBOMDesc; ProdBOM.Description)
            {
            }
            column(WeightOutput; WeightOutput)
            {
            }
            column(VolumeOutput; VolumeOutput)
            {
            }
            column(WeightInput; WeightInput)
            {
            }
            column(VolumeInput; VolumeInput)
            {
            }
            dataitem("Production BOM Line"; "Production BOM Line")
            {
                DataItemLink = "Production BOM No." = FIELD("Production BOM No."), "Version Code" = FIELD("Version Code");
                DataItemTableView = SORTING("Production BOM No.", "Version Code", "Line No.") ORDER(Ascending);
                column(ProdBOMLineDesc; Description)
                {
                }
                column(ProdBOMLineType; Type)
                {
                }
                column(ProdBOMLineNo; "No.")
                {
                }
                column(ProdBOMLineUOMCode; "Unit of Measure Code")
                {
                }
                column(ProdBOMLineYieldWeight; "Yield % (Weight)")
                {
                    DecimalPlaces = 2 : 2;
                }
                column(ProdBOMLineUnitCost; "Unit Cost")
                {
                    DecimalPlaces = 3 : 3;
                }
                column(ProdBOMLineExtendedCost; "Extended Cost")
                {
                    DecimalPlaces = 2 : 2;
                }
                column(ProdBOMLineBatchQuantity; "Batch Quantity")
                {
                }
                column(ProdBOMLineofTotal; "% of Total")
                {
                    IncludeCaption = true;
                }
                column(ProdBOMLineMtlVol; "Mtl/Vol")
                {
                }
                column(ProdBOMLineMtlWt; "Mtl/Wt")
                {
                }
                column(ProdBOMLineMtlCost; MtlCost)
                {
                }
                column(ProdBOMLineSTRWtUOM; StrSubstNo(Text000, WtUOM))
                {
                }
                column(ProdBOMLineSTRVolUOM; StrSubstNo(Text000, VolUOM))
                {
                }
                column(ProdBOMLineProdBOMNo; "Production BOM No.")
                {
                }
                column(ProdBOMLineVersionCode; "Version Code")
                {
                }
                column(ProdBOMLineLineNo; "Line No.")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    TotalCost := TotalCost + "Production BOM Line"."Extended Cost";
                end;
            }
            dataitem("Prod. BOM Activity Cost"; "Prod. BOM Activity Cost")
            {
                DataItemLink = "Production Bom No." = FIELD("Production BOM No."), "Version Code" = FIELD("Version Code");
                DataItemTableView = SORTING("Production Bom No.", "Version Code", "Resource No.") ORDER(Ascending);
                column(ProdBOMActivityCostResourceType; "Resource Type")
                {
                    IncludeCaption = true;
                }
                column(ProdBOMActivityCostDesc; Description)
                {
                    IncludeCaption = true;
                }
                column(Quantity_ResourceMultiplier; Quantity * "Resource Multiplier")
                {
                    DecimalPlaces = 0 : 5;
                }
                column(ProdBOMActivityCostUOM; "Unit of Measure")
                {
                    IncludeCaption = true;
                }
                column(ProdBOMActivityCostUnitCost; "Unit Cost")
                {
                    IncludeCaption = true;
                }
                column(ProdBOMActivityCostExtendedCost; "Extended Cost")
                {
                    IncludeCaption = true;
                }
                column(ProdBOMActivityCostIncludeInCostRollup; "Include In Cost Rollup")
                {
                    IncludeCaption = true;
                }
                column(ProdBOMActivityCostResourceNo; "Resource No.")
                {
                    IncludeCaption = true;
                }
                column(ProdBOMActivityCostActCost; ActCost)
                {
                }
                column(IncludedABCCosts; IncludedABCCosts)
                {
                }
                column(ProdBOMActivityCostABCWt; "ABC/Wt")
                {
                }
                column(ProdBOMActivityCostABCVol; "ABC/Vol")
                {
                }
                column(ProdBOMActivityCostSTRWtUOM; StrSubstNo(Text000, WtUOM))
                {
                }
                column(ProdBOMActivityCostSTRVolUOM; StrSubstNo(Text000, VolUOM))
                {
                }
                column(ProdBOMActivityCostProdBomNo; "Production Bom No.")
                {
                }
                column(ProdBOMActivityCostVersionCode; "Version Code")
                {
                }
                column(ProdBOMActivityCostLineNo; "Line No.")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    ActCost := ActCost + "Prod. BOM Activity Cost"."Extended Cost"; // P8000219A
                    if "Prod. BOM Activity Cost"."Include In Cost Rollup" then   // P8007742
                        IncludedABCCosts := IncludedABCCosts + "Prod. BOM Activity Cost"."Extended Cost";
                end;

                trigger OnPostDataItem()
                begin
                    TotalCost := MtlCost + IncludedABCCosts; // P8000219A
                    if WeightOutput <> 0 then
                        "Cost/Wt" := TotalCost / WeightOutput
                    else
                        "Cost/Wt" := 0;
                    if VolumeOutput <> 0 then
                        "Cost/Vol" := TotalCost / VolumeOutput
                    else
                        "Cost/Vol" := 0;
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Equipment No.", BOMVars."Costing Equipment"); // P8000219A
                end;
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                column(ProdBOMVersionSTRWtUOM; StrSubstNo(Text000, WtUOM))
                {
                }
                column(ProdBOMVersionCostWt; "Cost/Wt")
                {
                }
                column(ProdBOMVersionTotalCost; TotalCost)
                {
                }
                column(ProdBOMVersionCostVol; "Cost/Vol")
                {
                }
                column(ProdBOMVersionSTRVolUOM; StrSubstNo(Text000, VolUOM))
                {
                }
                column(IntegerBody; 'Integer Body')
                {
                }
            }
            dataitem("Prod. BOM Equipment"; "Prod. BOM Equipment")
            {
                DataItemLink = "Production Bom No." = FIELD("Production BOM No."), "Version Code" = FIELD("Version Code");
                DataItemTableView = SORTING("Production Bom No.", "Version Code", "Resource No.") ORDER(Ascending);
                column(ProdBOMEqpmtResourceNo; "Resource No.")
                {
                    IncludeCaption = true;
                }
                column(ProdBOMEqpmtDesc; Description)
                {
                    IncludeCaption = true;
                }
                column(ProdBOMEqpmtUOM; "Unit of Measure")
                {
                    IncludeCaption = true;
                }
                column(ProdBOMEqpmtEquipmentCapacity; "Equipment Capacity")
                {
                    IncludeCaption = true;
                }
                column(ProdBOMEqpmtCapacityLevel; "Capacity Level %")
                {
                    IncludeCaption = true;
                }
                column(ProdBOMEqpmtPref; Preference)
                {
                    IncludeCaption = true;
                }
                column(ProdBOMEqpmtFixedProdTimeHrs; "Fixed Prod. Time (Hours)")
                {
                }
                column(ProdBOMEqpmtNetCapacity; "Net Capacity")
                {
                    IncludeCaption = true;
                }
                column(ProdBOMEqpmtVariableProdTimeHrs; "Variable Prod. Time (Hours)")
                {
                }
                column(ProdBOMEqpmtBody; 'Prod BOM Equipment Body')
                {
                }
            }

            trigger OnAfterGetRecord()
            begin
                IncludedABCCosts := 0;
                TotalCost := 0;
                ActCost := 0; // P8000219A
                ProdBOM.Get("Production BOM Version"."Production BOM No.");
                BOMVars.Type := BOMVars.Type::Formula;   // get the calculated fields
                BOMVars."No." := "Production BOM Version"."Production BOM No.";
                BOMVars."Version Code" := "Production BOM Version"."Version Code";
                BOMVars.InitRecord;
                MtlCost := BOMVars."Material Cost"; // P8000219A
                WeightOutput := BOMVars."Output Weight";
                VolumeOutput := BOMVars."Output Volume";
                WeightInput := BOMVars."Input Weight";
                VolumeInput := BOMVars."Input Volume";
                WtUOM := BOMVars."Weight UOM";
                VolUOM := BOMVars."Volume UOM";
                "Mtl/Wt" := BOMVars."Material Cost (per Weight UOM)";
                "Mtl/Vol" := BOMVars."Material Cost (per Volume UOM)";
                // P8000379A
                "ABC/Wt" := BOMVars."Labor Cost (per Weight UOM)" + BOMVars."Machine Cost (per Weight UOM)" +
                  BOMVars."Other Cost (per Weight UOM)" + BOMVars."Overhead Cost (per Weight UOM)";
                "ABC/Vol" := BOMVars."Labor Cost (per Volume UOM)" + BOMVars."Machine Cost (per Volume UOM)" +
                  BOMVars."Other Cost (per Volume UOM)" + BOMVars."Overhead Cost (per Volume UOM)";
                // P8000379A
                if FirstPage then     // check if it's the first page and if so, don't print a new page
                    FirstPage := false
                else
                    CurrReport.NewPage;
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    rendering
    {
        layout(StandardRDLCLayout)
        {
            Summary = 'Standard Layout';
            Type = RDLC;
            LayoutFile = './layout/FormulaVersionDetails.rdlc';
        }
    }

    labels
    {
        FormulaVersionDetailsCaption = 'Formula Version Details';
        PAGENOCaption = 'Page';
        FormulaNoCaption = 'Formula No.';
        OutputCaption = 'Output';
        WeightCaption = 'Weight';
        VolumeCaption = 'Volume';
        InputCaption = 'Input';
        YieldCaption = 'Yield';
        DescriptionCaption = 'Description';
        UOMCaption = 'UOM';
        ExtendedCostCaption = 'Extended Cost';
        UnitCostCaption = 'Unit Cost';
        YieldWtCaption = 'Yield (Wt)';
        QuantityCaption = 'Quantity';
        NoCaption = 'No.';
        TypeCaption = 'Type';
        FormulaLinesCaption = 'Formula Lines';
        CostInfoCaption = 'Cost Information';
        MATERIALCOSTSCaption = 'MATERIAL COSTS';
        MaterialCostCaption = 'Material Cost';
        ActivityCostsCaption = 'Activity Costs';
        ActCostCaption = 'Activity Cost';
        IncludedABCCostsCaption = 'Included Costs';
        ACTIVITYCOSTSCaptiion = 'ACTIVITY COSTS';
        TOTALCOSTSCaption = 'TOTAL COSTS';
        PersonalProtectionCaption = 'Personal Protection';
        ChronicCaption = 'Chronic';
        HealthCaption = 'Health';
        FlammabilityCaption = 'Flammability';
        ReactivityCaption = 'Reactivity';
        SafetyCaption = 'Safety';
        TotalCostCaption = 'Total Cost';
        FixedProdTimeHrsCaption = 'Fixed Prod. Time (Hrs)';
        EquipmentCaption = 'Equipment';
        VariableProdTimeHrsCaption = 'Var. Prod. Time (Hrs)';
    }

    trigger OnPreReport()
    begin
        FirstPage := true;
    end;

    var
        FirstPage: Boolean;
        TotalCost: Decimal;
        MtlCost: Decimal;
        ActCost: Decimal;
        IncludedABCCosts: Decimal;
        ProdBOM: Record "Production BOM Header";
        BOMVars: Record "BOM Variables";
        WeightOutput: Decimal;
        VolumeOutput: Decimal;
        WeightInput: Decimal;
        VolumeInput: Decimal;
        WtUOM: Text[30];
        VolUOM: Text[30];
        "Cost/Wt": Decimal;
        "Cost/Vol": Decimal;
        "Mtl/Wt": Decimal;
        "Mtl/Vol": Decimal;
        "ABC/Wt": Decimal;
        "ABC/Vol": Decimal;
        Text000: Label 'Cost / %1';
}

