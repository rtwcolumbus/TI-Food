report 37002470 "Process Version Details"
{
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
    // P4.00.04
    // P8000379A, VerticalSoft, Jack Reynolds, 21 SEP 06
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
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    DefaultLayout = RDLC;
    RDLCLayout = './layout/ProcessVersionDetails.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Process Version Details';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Production BOM Version"; "Production BOM Version")
        {
            DataItemTableView = WHERE(Type = CONST(Process));
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
            column(UOM; UOM)
            {
            }
            column(ProdBOMDesc; ProdBOM.Description)
            {
            }
            column(Output; Output)
            {
            }
            column(Input; Input)
            {
            }
            column(ProdBOMVersionBody2; 'Production BOM Version Body(2)')
            {
            }
            dataitem("Production BOM Line"; "Production BOM Line")
            {
                DataItemLink = "Production BOM No." = FIELD("Production BOM No."), "Version Code" = FIELD("Version Code");
                DataItemTableView = SORTING("Production BOM No.", "Version Code", "Line No.") ORDER(Ascending);
                column(ProdBOMLineDesc; Description)
                {
                }
                column(ProdBOMLineBody2; 'Production BOM Line Body(2)')
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
                column(MtlCost; MtlCost)
                {
                }
                column(ProdBOMLineSTRUOM; StrSubstNo(Text000, UOM))
                {
                }
                column(MtlPer; MtlPer)
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
                column(QuantityResourceMult; Quantity * "Resource Multiplier")
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
                column(ProdBOMActivityCostBody2; 'Prod. BOM Activity Cost Body(2)')
                {
                }
                column(RTCActCost; RTCActCost)
                {
                }
                column(RTCIncludedABCCosts; RTCIncludedABCCosts)
                {
                }
                column(ABCPer; ABCPer)
                {
                }
                column(ProdBOMActivityCostSTRUOM; StrSubstNo(Text000, UOM))
                {
                }

                trigger OnAfterGetRecord()
                begin
                    ActCost := ActCost + "Prod. BOM Activity Cost"."Extended Cost"; // P8000219A
                    if "Prod. BOM Activity Cost"."Include In Cost Rollup" then        //  P8000219A    // P8007742
                        IncludedABCCosts := IncludedABCCosts + "Prod. BOM Activity Cost"."Extended Cost";

                    RTCActCost := "Prod. BOM Activity Cost"."Extended Cost";              // P8000812
                    if "Prod. BOM Activity Cost"."Include In Cost Rollup" then           // P8000812   // P8007742
                        RTCIncludedABCCosts := "Prod. BOM Activity Cost"."Extended Cost";   // P8000812
                end;

                trigger OnPostDataItem()
                begin
                    TotalCost := MtlCost + IncludedABCCosts; // P8000219A
                    if Output <> 0 then
                        CostPer := TotalCost / Output
                    else
                        CostPer := 0;
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Equipment No.", BOMVars."Costing Equipment"); // P8000219A
                end;
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                column(ProdBOMVersionSTRUOM; StrSubstNo(Text000, UOM))
                {
                }
                column(CostPer; CostPer)
                {
                }
                column(TotalCost; TotalCost)
                {
                }
                column(IntegerBody1; 'Integer Body(1)')
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
                column(ProdBOMEqpmtEqpmtCpcty; "Equipment Capacity")
                {
                    IncludeCaption = true;
                }
                column(ProdBOMEqpmtCpctyLevel; "Capacity Level %")
                {
                    IncludeCaption = true;
                }
                column(ProdBOMEqpmtPreference; Preference)
                {
                    IncludeCaption = true;
                }
                column(ProdBOMEqpmtFixedProdTimeHrs; "Fixed Prod. Time (Hours)")
                {
                }
                column(ProdBOMEqpmtNetCpcty; "Net Capacity")
                {
                    IncludeCaption = true;
                }
                column(ProdBOMEqpmtVariableProdTimeHrs; "Variable Prod. Time (Hours)")
                {
                }
                column(ProdBOMEqpmtBody2; 'Prod. BOM Equipment Body(2)')
                {
                }
            }

            trigger OnAfterGetRecord()
            begin
                IncludedABCCosts := 0;
                TotalCost := 0;
                ActCost := 0; // P8000219A
                RTCActCost := 0; // P8000812
                RTCIncludedABCCosts := 0;  // P8000812
                ProdBOM.Get("Production BOM Version"."Production BOM No.");
                BOMVars.Type := BOMVars.Type::Process;   // get the calculated fields
                BOMVars."No." := "Production BOM Version"."Production BOM No.";
                BOMVars."Version Code" := "Production BOM Version"."Version Code";
                BOMVars.InitRecord;
                MtlCost := BOMVars."Material Cost"; // P8000219A
                if BOMVars."Primary UOM" = BOMVars."Primary UOM"::Weight then begin
                    UOM := BOMVars."Weight UOM";
                    Output := BOMVars."Output Weight";
                    Input := BOMVars."Input Weight";
                    MtlPer := BOMVars."Material Cost (per Weight UOM)";
                end else begin
                    UOM := BOMVars."Volume UOM";
                    Output := BOMVars."Output Volume";
                    Input := BOMVars."Input Volume";
                    MtlPer := BOMVars."Material Cost (per Volume UOM)";
                end;
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

    labels
    {
        ProcessVersionDetCaption = 'Process Version Details';
        PAGENOCaption = 'Page';
        ProcessNoCaption = 'Process No.';
        OutputCaption = 'Output';
        InputCaption = 'Input';
        UOMCaption = 'UOM';
        ExtendedCostCaption = 'Extended Cost';
        UnitCostCaption = 'Unit Cost';
        YieldWtCaption = 'Yield (Wt)';
        QuantityCaption = 'Quantity';
        DescCaption = 'Description';
        NoCaption = 'No.';
        TypeCaption = 'Type';
        ProcessLinesCaption = 'Process Lines';
        CostInfoCaption = 'Cost Information';
        MtlCostCaption = 'Material Cost';
        MATERIALCOSTSCaption = 'MATERIAL COSTS';
        QuantityResourceMultCaption = 'Quantity';
        ActivityCostsCaption = 'Activity Costs';
        ActCostCaption = 'Activity Cost';
        IncludedABCCostsCaption = 'Included Costs';
        ACTIVITYCOSTS2Caption = 'ACTIVITY COSTS';
        TOTALCOSTSCaption = 'TOTAL COSTS';
        ChronicCaption = 'Chronic';
        FlammabilityCaption = 'Flammability';
        ReactivityCaption = 'Reactivity';
        HealthCaption = 'Health';
        PersonalProtectionCaption = 'Personal Protection';
        SafetyCaption = 'Safety';
        TotalCostCaption = 'Total Cost';
        FixedProdTimeHrsCaption = 'Fixed Prod. Time (Hrs)';
        EqpmtCaption = 'Equipment';
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
        xBOMDescription: Text[100];
        BOMVars: Record "BOM Variables";
        Output: Decimal;
        Input: Decimal;
        UOM: Text[30];
        CostPer: Decimal;
        MtlPer: Decimal;
        ABCPer: Decimal;
        Text000: Label 'Cost / %1';
        RTCActCost: Decimal;
        RTCIncludedABCCosts: Decimal;
}

