report 37002580 "Production Item Costs"
{
    // PR4.00
    // P8000219A, Myers Nissi, Jack Reynolds, 24 JUN 05
    //   Filter costs by costing equipment
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 26 APR 10
    //   RTC Reporting Upgrade
    // 
    // PRW16.00.04
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // PRW17.10
    // P8001221, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Type added to Item table
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
    DefaultLayout = RDLC;
    RDLCLayout = './layout/ProductionItemCosts.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Production Item Costs';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.") WHERE(Type = CONST(Inventory));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            column(ItemRec; "No.")
            {
            }
            column(ItemHeader; 'Item')
            {
            }
            dataitem("Production BOM Header"; "Production BOM Header")
            {
                DataItemLink = "No." = FIELD("Production BOM No.");
                DataItemTableView = SORTING("No.");
                PrintOnlyIfDetail = true;
                column(ProdBOMHeaderNo; "No.")
                {
                }
                column(ProdBOMHeaderDesc; Description)
                {
                    IncludeCaption = true;
                }
                column(ItemDesc; Item.Description)
                {
                }
                column(ItemNo; Item."No.")
                {
                }
                column(ItemBaseUOM; Item."Base Unit of Measure")
                {
                }
                dataitem("Production BOM Version"; "Production BOM Version")
                {
                    CalcFields = "Output Weight (Base)", "Output Volume (Base)";
                    DataItemLink = "Production BOM No." = FIELD("No.");
                    DataItemTableView = SORTING("Production BOM No.", "Version Code");
                    column(ProdBOMVersionVersionCode; "Version Code")
                    {
                    }
                    column(ProdBOMVersionDesc; Description)
                    {
                        IncludeCaption = true;
                    }
                    column(ProdBOMVersionPrimaryUOM; "Primary UOM")
                    {
                        IncludeCaption = true;
                    }
                    column(ProdBOMVersionStatus; Status)
                    {
                        IncludeCaption = true;
                    }
                    column(ProdBOMVersionYieldWeight; "Yield % (Weight)")
                    {
                        IncludeCaption = true;
                    }
                    column(ProdBOMVersionYieldVolume; "Yield % (Volume)")
                    {
                        IncludeCaption = true;
                    }
                    column(ProdBOMVersionRec; "Production BOM No." + "Version Code")
                    {
                    }
                    column(ProdBOMVersionGrouping; "Production BOM No.")
                    {
                    }
                    column(Text002; Text002)
                    {
                    }
                    column(IntermTotalCost; IntermediateTotalCost)
                    {
                    }
                    column(ProdBOMVersionSTRText003UOM; StrSubstNo(Text003, UOM))
                    {
                    }
                    column(Divide_IntermTotalCost_UOMTotal; Divide(IntermediateTotalCost, UOMTotal))
                    {
                        DecimalPlaces = 2 : 2;
                    }
                    dataitem("Production BOM Line"; "Production BOM Line")
                    {
                        DataItemLink = "Production BOM No." = FIELD("Production BOM No."), "Version Code" = FIELD("Version Code");
                        DataItemTableView = SORTING("Production BOM No.", "Version Code", "Line No.") WHERE(Type = FILTER(<> " "));
                        column(ProdBOMLineNo; "No.")
                        {
                            IncludeCaption = true;
                        }
                        column(ProdBOMLineDesc; Description)
                        {
                            IncludeCaption = true;
                        }
                        column(ProdBOMLineUOMCode; "Unit of Measure Code")
                        {
                        }
                        column(ProdBOMLineBatchQuantity; "Batch Quantity")
                        {
                            IncludeCaption = true;
                        }
                        column(ProdBOMLineUnitCost; "Unit Cost")
                        {
                            IncludeCaption = true;
                        }
                        column(ProdBOMLineExtendedCost; "Extended Cost")
                        {
                            DecimalPlaces = 2 : 2;
                            IncludeCaption = true;
                        }
                        column(ProdBOMLineHeader; 'ProdBOMLine')
                        {
                        }
                        column(ProdBOMLineRec; "Production BOM No." + "Version Code" + Format("Line No."))
                        {
                        }
                        column(ProdBOMLineGrouping; "Production BOM No.")
                        {
                        }
                        column(ProdBOMVersionOutputVolumeBase_VMetricConv; "Production BOM Version"."Output Volume (Base)" / VMetricConv)
                        {
                        }
                        column(ProdBOMVersionOutputWeightBase_WMetricConv; "Production BOM Version"."Output Weight (Base)" / WMetricConv)
                        {
                        }
                        column(ProdBOMLineDivide_ExtendedCost_UOMTotal; Divide("Extended Cost", UOMTotal))
                        {
                            AutoCalcField = false;
                            DecimalPlaces = 2 : 2;
                        }
                        column(ProdBOMLineSTRText004UOM; StrSubstNo(Text004, UOM))
                        {
                        }
                        column(STRText005VolumeUOM; StrSubstNo(Text005, "Production BOM Version"."Volume UOM"))
                        {
                        }
                        column(STRProdBOMVersionWeightUOM; StrSubstNo("Production BOM Version"."Weight UOM"))
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            IntermediateTotalCost += "Extended Cost";
                        end;
                    }
                    dataitem("Prod. BOM Activity Cost"; "Prod. BOM Activity Cost")
                    {
                        DataItemLink = "Production Bom No." = FIELD("Production BOM No."), "Version Code" = FIELD("Version Code");
                        DataItemTableView = SORTING("Production Bom No.", "Version Code", "Resource No.");
                        column(ProdBOMActCostResourceNo; "Resource No.")
                        {
                        }
                        column(ProdBOMActCostDesc; Description)
                        {
                        }
                        column(ProdBOMActCostUOM; "Unit of Measure")
                        {
                        }
                        column(ProdBOMActCostQuantity; Quantity)
                        {
                        }
                        column(ProdBOMActCostUnitCost; "Unit Cost")
                        {
                        }
                        column(ProdBOMActCostExtendedCost; "Extended Cost")
                        {
                            DecimalPlaces = 2 : 2;
                        }
                        column(ProdBOMActCostHeader; 'ProdBOMActCost')
                        {
                        }
                        column(ProdBOMActCostRec; "Production Bom No." + "Version Code" + "Resource No." + Format("Line No."))
                        {
                        }
                        column(ProdBOMActCostGrouping; "Production Bom No.")
                        {
                        }
                        column(ProdBOMActCostSTRText004UOM; StrSubstNo(Text004, UOM))
                        {
                        }
                        column(ProdBOMActCostDivide_ExtendedCost_UOMTotal; Divide("Extended Cost", UOMTotal))
                        {
                            DecimalPlaces = 2 : 2;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            IntermediateTotalCost += "Extended Cost";
                        end;

                        trigger OnPreDataItem()
                        begin
                            SetRange("Equipment No.", P800BOMFns.GetCostingEquipment(                                   // P8000219A
                              "Production BOM Version"."Production BOM No.", "Production BOM Version"."Version Code", '')); // P8000219A, P8001030
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        WMetricConv := P800UOMFns.UOMtoMetricBase("Weight UOM");
                        VMetricConv := P800UOMFns.UOMtoMetricBase("Volume UOM");


                        case "Primary UOM" of
                            "Primary UOM"::Volume:
                                begin
                                    UOM := "Volume UOM";
                                    UOMTotal := "Production BOM Version"."Output Volume (Base)" / VMetricConv;
                                end;
                            "Primary UOM"::Weight:
                                begin
                                    UOM := "Weight UOM";
                                    UOMTotal := "Production BOM Version"."Output Weight (Base)" / WMetricConv;
                                end;
                        end;
                        IntermediateTotalCost := 0;
                    end;

                    trigger OnPreDataItem()
                    begin
                        if VersionCode <> '' then
                            VersionSelect := VersionSelect::Code;
                        case VersionSelect of
                            VersionSelect::Code:
                                SetRange("Version Code", VersionCode);
                            VersionSelect::Active:
                                SetRange("Version Code", GetVersion.GetBOMVersion("Production BOM Header"."No.", WorkDate, true));
                        end;
                    end;
                }
            }
            dataitem("Item Variant"; "Item Variant")
            {
                DataItemLink = "Item No." = FIELD("No.");
                DataItemTableView = SORTING("Item No.", Code) WHERE("Production BOM No." = FILTER(<> ''));
                PrintOnlyIfDetail = true;
                column(ItemVariantDesc; Description)
                {
                }
                column(ItemVariantRec; "Item No." + Code)
                {
                }
                dataitem("VProduction BOM Version"; "Production BOM Version")
                {
                    DataItemLink = "Production BOM No." = FIELD("Production BOM No.");
                    DataItemTableView = SORTING("Production BOM No.", "Version Code");
                    column(vProdBOMVersionRec; "Production BOM No." + "Version Code")
                    {
                    }
                    column(vProdBOMVersionGrouping; "Production BOM No.")
                    {
                    }
                    column(UOMConv; UOMConv)
                    {
                    }
                    column(rtwUOMTotal; UOMTotal)
                    {
                    }
                    column(rtwIntermTotalCost; IntermediateTotalCost)
                    {
                    }
                    column(Text006; Text006)
                    {
                    }
                    column(VPBOMVersionSTRText007UOM; StrSubstNo(Text007, UOM))
                    {
                    }
                    column(PkgTotalCost; PkgTotalCost)
                    {
                    }
                    column(PkgTotalCost_UOMConv; PkgTotalCost / UOMConv)
                    {
                        DecimalPlaces = 2 : 2;
                    }
                    column(Divide_IntermTotalCost_UOMTotal_PkgTotalCost_UOMConv; Divide(IntermediateTotalCost, UOMTotal) + (PkgTotalCost / UOMConv))
                    {
                        DecimalPlaces = 2 : 2;
                    }
                    column(Text008; Text008)
                    {
                    }
                    column(VPBOMVersionSTRText004UOM; StrSubstNo(Text004, UOM))
                    {
                    }
                    column(Divide_IntermTotalCost_UOMTotal_UOMConv_PkgTotalCost; (Divide(IntermediateTotalCost, UOMTotal) * UOMConv) + PkgTotalCost)
                    {
                    }
                    dataitem("VProduction BOM Line"; "Production BOM Line")
                    {
                        DataItemLink = "Production BOM No." = FIELD("Production BOM No."), "Version Code" = FIELD("Version Code");
                        DataItemTableView = SORTING("Production BOM No.", "Version Code", "Line No.") WHERE(Type = FILTER(<> " "));
                        column(VProdBOMLineExtendedCost; "Extended Cost")
                        {
                            DecimalPlaces = 2 : 2;
                        }
                        column(VProdBOMLineUnitCost; "Unit Cost")
                        {
                        }
                        column(VProdBOMLineQuantity; Quantity)
                        {
                        }
                        column(VProdBOMLineUOMCode; "Unit of Measure Code")
                        {
                        }
                        column(VProdBOMLineDesc; Description)
                        {
                        }
                        column(VProdBOMLineNo; "No.")
                        {
                        }
                        column(vProdBOMLineRec; "Production BOM No." + "Version Code" + Format("Line No."))
                        {
                        }
                        column(vProdBOMLineGrouping; "Production BOM No.")
                        {
                        }

                        trigger OnAfterGetRecord()
                        var
                            VariantVar: Record "Item Variant Variable";
                            VarItem: Record Item;
                        begin
                            if Type = "VProduction BOM Line".Type::FOODVariable then begin
                                if VariantVar.Get("Item Variant"."Item No.", "Item Variant".Code, "VProduction BOM Line"."No.") then begin
                                    if not VarItem.Get(VariantVar."Variable Item No.") then
                                        Clear(VarItem);
                                end;
                                "Unit Cost" := VarItem."Unit Cost";
                                Validate("Quantity per", (VariantVar.Quantity * Quantity));
                                Description := VarItem.Description;
                                "No." := VarItem."No.";
                            end;
                            PkgTotalCost += "Extended Cost";
                        end;
                    }
                    dataitem("VProd. BOM Activity Cost"; "Prod. BOM Activity Cost")
                    {
                        DataItemLink = "Production Bom No." = FIELD("Production BOM No."), "Version Code" = FIELD("Version Code");
                        DataItemTableView = SORTING("Production Bom No.", "Version Code", "Resource No.");
                        column(VProdBOMActivityCostExtendedCost; "Extended Cost")
                        {
                            DecimalPlaces = 2 : 2;
                        }
                        column(VProdBOMActivityCostUnitCost; "Unit Cost")
                        {
                        }
                        column(VProdBOMActivityCostQuantity; Quantity)
                        {
                        }
                        column(VProdBOMActivityCostUOM; "Unit of Measure")
                        {
                        }
                        column(VProdBOMActivityCostDesc; Description)
                        {
                        }
                        column(VProdBOMActivityCostResourceNo; "Resource No.")
                        {
                        }
                        column(vProdBOMActCostHeader; 'vProdBOMActCost')
                        {
                        }
                        column(vProdBOMActCostRec; "Production Bom No." + "Version Code" + "Resource No." + Format("Line No."))
                        {
                        }
                        column(vProdBOMActCostGrouping; "Production Bom No.")
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            PkgTotalCost += "Extended Cost";
                        end;

                        trigger OnPreDataItem()
                        begin
                            SetRange("Equipment No.", P800BOMFns.GetCostingEquipment(                                     // P8000219A
                              "VProduction BOM Version"."Production BOM No.", "VProduction BOM Version"."Version Code", '')); // P8000219A, P8001030
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        PkgTotalCost := 0;
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange("Version Code", GetVersion.GetBOMVersion("Item Variant"."Production BOM No.", WorkDate, true));
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    UOMConv := P800UOMFns.GetConversionFromTo("Item No.", "Unit of Measure Code", UOM);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if CurrReport.PageNo <> 1 then
                    CurrReport.NewPage;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(VersionSelect; VersionSelect)
                    {
                        ApplicationArea = FOODBasic;
                        OptionCaption = 'Active Version,Version Code';
                    }
                    field(VersionCode; VersionCode)
                    {
                        ApplicationArea = FOODBasic;
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
        ProductionItemCostsCaption = 'Production Item Costs';
        PageNoCaption = 'Page';
        FormulaNoCaption = 'Formula No.';
        DescCaption = 'Description';
        ItemNoCaption = 'Item No.';
        BaseUOMCaption = 'Base UOM';
        VersionNoCaption = 'Version No.';
        FormulaCompCaption = 'Formula Components';
        TotalCompCostCaption = 'Total Component Cost';
        FormulaActivityBasedCostsCaption = 'Formula Activity Based Costs';
        ExtendedCostCaption = 'Extended Cost';
        UnitCostCaption = 'Unit Cost';
        BatchQuantityCaption = 'Batch Quantity';
        UOMCaption = 'Unit of Measure';
        NoCaption = 'No.';
        TotalActivityBasedCostCaption = 'Total Activity Based Cost';
        PackagingComponentsCaption = 'Packaging Components';
        TotalPkgMaterialCostCaption = 'Total Pkg. Material Cost';
        PackagingActivityBasedCostsCaption = 'Packaging Activity Based Costs';
        TotalPkgActivityBasedCostCaption = 'Total Pkg. Activity Based Cost';
    }

    trigger OnPreReport()
    begin
        if (VersionSelect = VersionSelect::Code) and (VersionCode = '') then
            Error(Text001);
    end;

    var
        GetVersion: Codeunit VersionManagement;
        UOM: Text[10];
        UOMTotal: Decimal;
        UnitCost: Decimal;
        IntermediateTotalCost: Decimal;
        PkgTotalCost: Decimal;
        UOMConv: Decimal;
        VersionSelect: Option Active,"Code";
        VersionCode: Code[10];
        WMetricConv: Decimal;
        P800UOMFns: Codeunit "Process 800 UOM Functions";
        P800BOMFns: Codeunit "Process 800 BOM Functions";
        VMetricConv: Decimal;
        Text001: Label 'No Version Code selected...';
        Text002: Label 'Total Intermediate Cost';
        Text003: Label 'Intermediate Cost per %1';
        Text004: Label 'Cost per %1';
        Text005: Label 'Total %1';
        Text006: Label 'Total Packaging Cost''';
        Text007: Label 'Packaging Cost per %1';
        Text008: Label 'Total Product Unit Cost';

    procedure Divide(numerator: Decimal; denominator: Decimal): Decimal
    begin
        if denominator <> 0 then
            exit(numerator / denominator);
    end;
}

