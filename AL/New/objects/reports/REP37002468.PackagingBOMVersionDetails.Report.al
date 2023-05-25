report 37002468 "Packaging BOM Version Details"
{
    // PR1.00
    //   Print the Formula/version details.
    // 
    // PR1.20
    //   Minor formatting changes
    // 
    // PR4.00
    // P8000219A, Myers Nissi, Jack Reynolds, 24 JUN 05
    //   Filter costs by costing equipment
    //   Activity line quantity is extended by resource multiplier
    // 
    // PR4.00.04
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
    // PRW19.00.01
    // P8007742, To-Increase, Dayakar Battini, 11 OCT 16
    //   ? character removed from "Include In Cost Rollup?" field
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
    DefaultRenderingLayout = StandardRDLCLayout;

    ApplicationArea = FOODBasic;
    Caption = 'Packaging BOM Version Details';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Production BOM Version"; "Production BOM Version")
        {
            DataItemTableView = WHERE(Type = CONST(BOM));
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
            column(ProdBOMVersionUOMCode; "Unit of Measure Code")
            {
            }
            column(ProdBOMDesc; ProdBOM.Description)
            {
            }
            dataitem("Production BOM Line"; "Production BOM Line")
            {
                DataItemLink = "Production BOM No." = FIELD("Production BOM No."), "Version Code" = FIELD("Version Code");
                DataItemTableView = SORTING("Production BOM No.", "Version Code", "Line No.") ORDER(Ascending);
                column(ProdBOMLineType; Type)
                {
                }
                column(ProdBOMLineNo; "No.")
                {
                }
                column(ProdBOMLineDesc; Description)
                {
                }
                column(ProdBOMLineUOMCode; "Unit of Measure Code")
                {
                }
                column(ProdBOMLineUnitCost; "Unit Cost")
                {
                    DecimalPlaces = 3 : 3;
                }
                column(ProdBOMLineExtendedCost; "Extended Cost")
                {
                    DecimalPlaces = 2 : 2;
                }
                column(ProdBOMLineQuantityper; "Quantity per")
                {
                    IncludeCaption = true;
                }
                column(ProdBOMLineBody; 'Production BOM Line Body')
                {
                }
                column(MtlCost; MtlCost)
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
                column(ProdBOMActCostResourceType; "Resource Type")
                {
                    IncludeCaption = true;
                }
                column(ProdBOMActCostDesc; Description)
                {
                    IncludeCaption = true;
                }
                column(QuantityResourceMult; Quantity * "Resource Multiplier")
                {
                    DecimalPlaces = 0 : 5;
                }
                column(ProdBOMActCostUOM; "Unit of Measure")
                {
                    IncludeCaption = true;
                }
                column(ProdBOMActCostUnitCost; "Unit Cost")
                {
                    IncludeCaption = true;
                }
                column(ProdBOMActCostExtendedCost; "Extended Cost")
                {
                    IncludeCaption = true;
                }
                column(ProdBOMActCostIncludeInCostRollup; "Include In Cost Rollup")
                {
                    IncludeCaption = true;
                }
                column(ProdBOMActCostResourceNo; "Resource No.")
                {
                    IncludeCaption = true;
                }
                column(ProdBOMActCostBody; 'Prod. BOM Activity Cost Body')
                {
                }
                column(incABCCosts; incABCCosts)
                {
                }
                column(ActCost; ActCost)
                {
                }
                column(IncludedABCCosts; IncludedABCCosts)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    ActCost := ActCost + "Prod. BOM Activity Cost"."Extended Cost"; // P8000219A
                    if "Prod. BOM Activity Cost"."Include In Cost Rollup" then   // P8007742
                        IncludedABCCosts := IncludedABCCosts + "Prod. BOM Activity Cost"."Extended Cost";
                    // P8000812 S
                    if "Prod. BOM Activity Cost"."Include In Cost Rollup" then   // P8007742
                        incABCCosts := "Prod. BOM Activity Cost"."Extended Cost";
                    // P8000812 E
                end;

                trigger OnPostDataItem()
                begin
                    TotalCost := MtlCost + IncludedABCCosts; // P8000219A
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Equipment No.", BOMVars."Costing Equipment"); // P8000219A
                end;
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                column(TotalCost; TotalCost)
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
                column(ProdBOMEqpmtEquipmentCpcty; "Equipment Capacity")
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
                column(ProdBOMEqpmtBody; 'Prod. BOM Equipment Body')
                {
                }
            }

            trigger OnAfterGetRecord()
            begin
                IncludedABCCosts := 0;
                TotalCost := 0;
                ActCost := 0; // P8000219A
                ProdBOM.Get("Production BOM Version"."Production BOM No.");
                BOMVars.Type := BOMVars.Type::BOM;   // get the calculated fields
                BOMVars."No." := "Production BOM Version"."Production BOM No.";
                BOMVars."Version Code" := "Production BOM Version"."Version Code";
                BOMVars.InitRecord;
                MtlCost := BOMVars."Material Cost"; // P8000219A
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
            LayoutFile = './layout/PackagingBOMVersionDetails.rdlc';
        }
    }

    labels
    {
        PackagingBOMVersionDetailsCaption = 'Packaging BOM Version Details';
        PAGENOCaption = 'Page';
        PackagingBOMNoCaption = 'Packaging BOM No.';
        UOMCaption = 'UOM';
        DescCaption = 'Description';
        ExtendedCostCaption = 'Extended Cost';
        UnitCostCaption = 'Unit Cost';
        NoCaption = 'No.';
        TypeCaption = 'Type';
        BOMLinesCaption = 'BOM Lines';
        CostInfoCaption = 'Cost Information';
        MaterialCostCaption = 'Material Cost';
        MATERIALCOSTSCaption = 'MATERIAL COSTS';
        QuantityResourceMultCaption = 'Quantity';
        ActivityCostsCaption = 'Activity Costs';
        ActCostCaption = 'Activity Cost';
        IncludedABCCostsCaption = 'Included Costs';
        ACTIVITYCOSTS2Caption = 'ACTIVITY COSTS';
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
        VarProdTimeHrsCaption = 'Var. Prod. Time (Hrs)';
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
        incABCCosts: Decimal;
}

