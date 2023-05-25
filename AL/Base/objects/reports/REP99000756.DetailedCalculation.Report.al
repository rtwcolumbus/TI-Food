report 99000756 "Detailed Calculation"
{
    // PR4.00
    // P8000219A, Myers Nissi, Jack Reynolds, 24 JUN 05
    //   Call function to set cost from ABC
    // 
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    DefaultLayout = RDLC;
    RDLCLayout = './layout/DetailedCalculation.rdlc';
    ApplicationArea = Manufacturing;
    Caption = 'Detailed Calculation';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("Low-Level Code");
            RequestFilterFields = "No.";
            column(CompanyName; COMPANYPROPERTY.DisplayName())
            {
            }
            column(AsofCalcDate; StrSubstNo(Text000, CalculateDate, LocationCode))
            {
            }
            column(TodayFormatted; Format(Today, 0, 4))
            {
            }
            column(ItemTableCaptionFilter; TableCaption + ': ' + ItemFilter)
            {
            }
            column(ItemFilter; ItemFilter)
            {
            }
            column(No_Item; "No.")
            {
                IncludeCaption = true;
            }
            column(Description_Item; Description)
            {
                IncludeCaption = true;
            }
            column(ProductionBOMNo_Item; "Production BOM No.")
            {
                IncludeCaption = true;
            }
            column(RoutingNo_Item; "Routing No.")
            {
                IncludeCaption = true;
            }
            column(PBOMVersionCode1; PBOMVersionCode[1])
            {
            }
            column(RtngVersionCode; RtngVersionCode)
            {
            }
            column(LotSize_Item; "Lot Size")
            {
                IncludeCaption = true;
            }
            column(BaseUOM_Item; "Base Unit of Measure")
            {
            }
            column(CurrReportPageNoCapt; CurrReportPageNoCaptLbl)
            {
            }
            column(DetailedCalculationCapt; DetailedCalculationCaptLbl)
            {
            }
            dataitem("Routing Line"; "Routing Line")
            {
                DataItemLink = "Routing No." = FIELD("Routing No.");
                DataItemTableView = SORTING("Routing No.", "Version Code", "Operation No.");
                column(InRouting; InRouting)
                {
                }
                column(OperationNo_RtngLine; "Operation No.")
                {
                    IncludeCaption = true;
                }
                column(Type_RtngLine; Type)
                {
                    IncludeCaption = true;
                }
                column(No_RtngLine; "No.")
                {
                    IncludeCaption = true;
                }
                column(Desc_RtngLine; Description)
                {
                    IncludeCaption = true;
                }
                column(SetupTime_RtngLine; "Setup Time")
                {
                    IncludeCaption = true;
                }
                column(RunTime_RtngLine; "Run Time")
                {
                    IncludeCaption = true;
                }
                column(CostTime; CostTime)
                {
                    DecimalPlaces = 0 : 5;
                }
                column(ProdUnitCost; ProdUnitCost)
                {
                    AutoFormatType = 2;
                }
                column(ProdTotalCost; ProdTotalCost)
                {
                    AutoFormatType = 1;
                }
                column(CostTimeCaption; CostTimeCaptionLbl)
                {
                }
                column(ProdTotalCostCaption; ProdTotalCostCaptionLbl)
                {
                }

                trigger OnAfterGetRecord()
                var
                    UnitCostCalculation: Option Time,Unit;
                    RoutingRec: RecordRef;
                    ProdBOMNo: Code[20];
                    ProdBOMVersion: Code[10];
                begin
                    ProdUnitCost := "Unit Cost per";

                    // P8000219A Begin
                    RoutingRec.GetTable("Routing Line");
                    if not CostCalcMgt.CalcABCRtngCostPerUnit(
                      RoutingRec, Item, CalculateDate, '', ProdBOMNo, ProdBOMVersion, // P8001030
                      DirectUnitCost, IndirectCostPct, OverheadRate, ProdUnitCost, UnitCostCalculation)
                    then
                        // P8000219A End
                        CostCalcMgt.RoutingCostPerUnit(
                      Type,
                      "No.",
                      DirectUnitCost,
                      IndirectCostPct,
                      OverheadRate, ProdUnitCost, UnitCostCalculation);
                    CostTime :=
                      CostCalcMgt.CalcCostTime(
                        CostCalcMgt.CalcQtyAdjdForBOMScrap(Item."Lot Size", Item."Scrap %"),
                        "Setup Time", "Setup Time Unit of Meas. Code",
                        "Run Time", "Run Time Unit of Meas. Code", "Lot Size",
                        "Scrap Factor % (Accumulated)", "Fixed Scrap Qty. (Accum.)",
                        "Work Center No.", UnitCostCalculation, MfgSetup."Cost Incl. Setup",
                        "Concurrent Capacities") /
                      Item."Lot Size";

                    ProdTotalCost := CostTime * ProdUnitCost;

                    FooterProdTotalCost += ProdTotalCost;
                end;

                trigger OnPostDataItem()
                begin
                    InRouting := false;
                end;

                trigger OnPreDataItem()
                begin
                    Clear(ProdTotalCost);
                    SetRange("Version Code", RtngVersionCode);

                    InRouting := true;
                end;
            }
            dataitem(BOMLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);
                column(InBOM; InBOM)
                {
                }
                column(ProdBOMLineLevelNoCaption; ProdBOMLineLevelNoCaptionLbl)
                {
                }
                column(ProdBOMLineLevelDescCapt; ProdBOMLineLevelDescCaptLbl)
                {
                }
                column(ProdBOMLineLevelQtyCapt; ProdBOMLineLevelQtyCaptLbl)
                {
                }
                column(CostTotalCaption; CostTotalCaptionLbl)
                {
                }
                column(ProdBOMLineLevelTypeCapt; ProdBOMLineLevelTypeCaptLbl)
                {
                }
                column(CompItemBaseUOMCapt; CompItemBaseUOMCaptLbl)
                {
                }
                column(VariantCaption; VariantCaptionLbl)
                {
                }
                dataitem(BOMComponentLine; "Integer")
                {
                    DataItemTableView = SORTING(Number);
                    MaxIteration = 1;
                    column(ProdBOMLineLevelType; Format(ProdBOMLine[Level].Type))
                    {
                    }
                    column(ProdBOMLineLevelNo; ProdBOMLine[Level]."No.")
                    {
                    }
                    column(ProdBOMLineLevelDesc; ProdBOMLine[Level].Description)
                    {
                    }
                    column(ProdBOMLineLevelQty; ProdBOMLine[Level].Quantity)
                    {
                    }
                    column(UnitCost_CompItem; CompItem."Unit Cost")
                    {
                        AutoFormatType = 2;
                        DecimalPlaces = 2 : 5;
                    }
                    column(CostTotal; CostTotal)
                    {
                        AutoFormatType = 1;
                    }
                    column(BaseUOM_CompItem; CompItem."Base Unit of Measure")
                    {
                    }
                    column(ShowLine; ProdBOMLine[Level].Type = ProdBOMLine[Level].Type::Item)
                    {
                    }
                    column(Variant; ProdBOMLine[Level]."Variant Code")
                    {
                    }
                }

                trigger OnAfterGetRecord()
                var
                    UOMFactor: Decimal;
                begin
                    CostTotal := 0;

                    while ProdBOMLine[Level].Next() = 0 do begin
                        Level := Level - 1;
                        if Level < 1 then
                            CurrReport.Break();
                        ProdBOMLine[Level].SetRange("Production BOM No.", PBOMNoList[Level]);
                        ProdBOMLine[Level].SetRange("Version Code", PBOMVersionCode[Level]);
                    end;

                    NextLevel := Level;
                    Clear(CompItem);

                    if Level = 1 then
                        UOMFactor :=
                          UOMMgt.GetQtyPerUnitOfMeasure(Item, VersionMgt.GetBOMUnitOfMeasure(PBOMNoList[Level], PBOMVersionCode[Level]))
                    else
                        UOMFactor := 1;

                    CompItemQtyBase :=
                      CostCalcMgt.CalcCompItemQtyBase(ProdBOMLine[Level], CalculateDate, Quantity[Level], Item."Routing No.", Level = 1) /
                      UOMFactor;

                    case ProdBOMLine[Level].Type of
                        ProdBOMLine[Level].Type::Item:
                            begin
                                CompItem.Get(ProdBOMLine[Level]."No.");
                                // P8001030
                                if SKU.Get(LocationCode, CompItem."No.", ProdBOMLine[Level]."Variant Code") then
                                    ItemCostMgmt.TransferCostsFromSKUToItem(SKU, CompItem);
                                // P8001030
                                ProdBOMLine[Level].Quantity := CompItemQtyBase / Item."Lot Size";
                                CostTotal := ProdBOMLine[Level].Quantity * CompItem."Unit Cost";
                                FooterCostTotal += CostTotal;
                            end;
                        ProdBOMLine[Level].Type::"Production BOM":
                            begin
                                NextLevel := Level + 1;
                                Clear(ProdBOMLine[NextLevel]);
                                PBOMNoList[NextLevel] := ProdBOMLine[Level]."No.";
                                PBOMVersionCode[NextLevel] :=
                                  VersionMgt.GetBOMVersion(ProdBOMLine[Level]."No.", CalculateDate, false);
                                ProdBOMLine[NextLevel].SetRange("Production BOM No.", PBOMNoList[NextLevel]);
                                ProdBOMLine[NextLevel].SetRange("Version Code", PBOMVersionCode[NextLevel]);
                                ProdBOMLine[NextLevel].SetFilter("Starting Date", '%1|..%2', 0D, CalculateDate);
                                ProdBOMLine[NextLevel].SetFilter("Ending Date", '%1|%2..', 0D, CalculateDate);
                                Quantity[NextLevel] := CompItemQtyBase;
                                Level := NextLevel;
                            end;
                    end;
                end;

                trigger OnPostDataItem()
                begin
                    InBOM := false;
                end;

                trigger OnPreDataItem()
                begin
                    if Item."Production BOM No." = '' then
                        CurrReport.Break();

                    Level := 1;

                    ProdBOMHeader.Get(PBOMNoList[Level]);

                    Clear(ProdBOMLine);
                    ProdBOMLine[Level].SetRange("Production BOM No.", PBOMNoList[Level]);
                    ProdBOMLine[Level].SetRange("Version Code", PBOMVersionCode[Level]);
                    ProdBOMLine[Level].SetFilter("Starting Date", '%1|..%2', 0D, CalculateDate);
                    ProdBOMLine[Level].SetFilter("Ending Date", '%1|%2..', 0D, CalculateDate);

                    Quantity[Level] := CostCalcMgt.CalcQtyAdjdForBOMScrap(Item."Lot Size", Item."Scrap %");

                    InBOM := true;
                end;
            }
            dataitem(Footer; "Integer")
            {
                DataItemTableView = SORTING(Number);
                MaxIteration = 1;
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = SORTING(Number);
                MaxIteration = 1;
                column(UnitCost_Item; Item."Unit Cost")
                {
                    AutoFormatType = 1;
                }
                column(SingleLevelMfgOvhd; SingleLevelMfgOvhd)
                {
                    AutoFormatType = 1;
                }
                column(FooterCostTotal; FooterCostTotal)
                {
                }
                column(FooterProdTotalCost; FooterProdTotalCost)
                {
                }
                column(ProdTotalCostCapt; ProdTotalCostCaptLbl)
                {
                }
                column(CostTotalCapt; CostTotalCaptLbl)
                {
                }
                column(SingleLevelMfgOvhdCaption; SingleLevelMfgOvhdCaptionLbl)
                {
                }
            }

            trigger OnAfterGetRecord()
            begin
                // P8001030
                if SKU.Get(LocationCode, "No.", '') then begin
                    if SKU."Routing No." <> '' then
                        "Routing No." := SKU."Routing No.";
                    if SKU."Production BOM No." <> '' then
                        "Production BOM No." := SKU."Production BOM No.";
                    if SKU."Lot Size" > 0 then
                        "Lot Size" := SKU."Lot Size";
                    ItemCostMgmt.TransferCostsFromSKUToItem(SKU, Item);
                end;
                // P8001030

                if "Lot Size" = 0 then
                    "Lot Size" := 1;

                if ("Production BOM No." = '') and
                   ("Routing No." = '')
                then
                    CurrReport.Skip();

                CostTotal := 0;

                PBOMNoList[1] := "Production BOM No.";

                if "Production BOM No." <> '' then
                    PBOMVersionCode[1] :=
                      VersionMgt.GetBOMVersion("Production BOM No.", CalculateDate, false);

                if "Routing No." <> '' then
                    RtngVersionCode := VersionMgt.GetRtngVersion("Routing No.", CalculateDate, false);

                SingleLevelMfgOvhd := "Single-Level Mfg. Ovhd Cost";

                FooterProdTotalCost := 0;
                FooterCostTotal := 0;
            end;

            trigger OnPreDataItem()
            begin
                ItemFilter := GetFilters();
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
                    field(CalculationDate; CalculateDate)
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Calculation Date';
                        ToolTip = 'Specifies the specific date for which to get the cost list. The standard entry in this field is the working date.';
                    }
                    field(LocationCode; LocationCode)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Location Code';
                        TableRelation = Location;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            CalculateDate := WorkDate();
        end;
    }

    labels
    {
        ProdUnitCostCaption = 'Unit Cost';
    }

    trigger OnInitReport()
    begin
        MfgSetup.Get();
    end;

    var
        MfgSetup: Record "Manufacturing Setup";
        CompItem: Record Item;
        ProdBOMHeader: Record "Production BOM Header";
        ProdBOMLine: array[99] of Record "Production BOM Line";
        UOMMgt: Codeunit "Unit of Measure Management";
        CostCalcMgt: Codeunit "Cost Calculation Management";
        VersionMgt: Codeunit VersionManagement;
        RtngVersionCode: Code[20];
        ItemFilter: Text;
        PBOMNoList: array[99] of Code[20];
        PBOMVersionCode: array[99] of Code[20];
        CompItemQtyBase: Decimal;
        Quantity: array[99] of Decimal;
        CalculateDate: Date;
        CostTotal: Decimal;
        ProdUnitCost: Decimal;
        ProdTotalCost: Decimal;
        CostTime: Decimal;
        InBOM: Boolean;
        InRouting: Boolean;
        Level: Integer;
        NextLevel: Integer;
        SingleLevelMfgOvhd: Decimal;
        DirectUnitCost: Decimal;
        IndirectCostPct: Decimal;
        OverheadRate: Decimal;
        FooterProdTotalCost: Decimal;
        FooterCostTotal: Decimal;

        Text000: Label 'As of %1, Location: %2';
        CurrReportPageNoCaptLbl: Label 'Page';
        DetailedCalculationCaptLbl: Label 'Detailed Calculation';
        CostTimeCaptionLbl: Label 'Cost Time';
        ProdTotalCostCaptionLbl: Label 'Total Cost';
        ProdBOMLineLevelNoCaptionLbl: Label 'No.';
        ProdBOMLineLevelDescCaptLbl: Label 'Description';
        ProdBOMLineLevelQtyCaptLbl: Label 'Quantity (Base)';
        CostTotalCaptionLbl: Label 'Total Cost';
        ProdBOMLineLevelTypeCaptLbl: Label 'Type';
        CompItemBaseUOMCaptLbl: Label 'Base Unit of Measure Code';
        ProdTotalCostCaptLbl: Label 'Cost of Production';
        CostTotalCaptLbl: Label 'Cost of Components';
        SingleLevelMfgOvhdCaptionLbl: Label 'Single-Level Mfg. Overhead Cost';
        SKU: Record "Stockkeeping Unit";
        ItemCostMgmt: Codeunit ItemCostManagement;
        LocationCode: Code[10];
        VariantCaptionLbl: Label 'Variant';
}

