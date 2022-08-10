report 37002462 "Quantity Explosion of Formula"
{
    // PR1.00, Myers Nissi, Diane Fox, 2 Nov 00, PR008
    //   Multi-level explosion of formula.
    // 
    // PR3.10
    //   New Calculation Management codeunit
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.03
    // P8000813, VerticalSoft, MMAS, 11 MAY 10
    //   Report design for RTC
    // 
    // PRW16.00.04
    // P8000837, VerticalSoft, Jack Reynolds, 06 JUL 10
    //   RDLC layout issues
    // 
    // PRW16.00.04
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 08 MAR 16
    //   Expand BOM Version code to Code20
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    DefaultLayout = RDLC;
    RDLCLayout = './layout/QuantityExplosionofFormula.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Quantity Explosion of Formula';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Production BOM Header"; "Production BOM Header")
        {
            DataItemTableView = SORTING("No.") ORDER(Ascending) WHERE("Mfg. BOM Type" = CONST(Formula));
            RequestFilterFields = "No.";
            column(CompanyInfoName; CompanyInformation.Name)
            {
            }
            column(STRCalcDate; StrSubstNo(Text000, "Calc.Date", LocationCode))
            {
            }
            column(ItemFilter; ItemFilter)
            {
            }
            column(ProdBOMHeaderTabCap; "Production BOM Header".TableCaption)
            {
            }
            column(ProdBOMHeaderNo; "No.")
            {
            }
            column(ProdBOMHeaderDesc; Description)
            {
            }
            dataitem(BOMLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);
                dataitem("Integer"; "Integer")
                {
                    DataItemTableView = SORTING(Number);
                    MaxIteration = 1;
                    column(BomCompLevelNo; BomComponent[Level]."No.")
                    {
                    }
                    column(BomCompLevelDesc; BomComponent[Level].Description)
                    {
                    }
                    column(BOMQty; BOMQty)
                    {
                        DecimalPlaces = 0 : 5;
                    }
                    column(PADLevel; PadStr('', Level, ' ') + Format(Level))
                    {
                    }
                    column(BomCompLevelQuantity; BomComponent[Level].Quantity)
                    {
                        DecimalPlaces = 0 : 5;
                    }
                    column(BomCompLevelScrap; BomComponent[Level]."Scrap %")
                    {
                        DecimalPlaces = 0 : 5;
                    }
                    column(BomCompLevelUOMCode; BomComponent[Level]."Unit of Measure Code")
                    {
                    }
                    column(BOMVariant; BomComponent[Level]."Variant Code")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        BOMQty :=
                          CalcMgt.CalcQtyAdjdForBOMScrap(
                            Quantity[Level],
                            BomComponent[Level]."Scrap %") *
                          QtyPerUnitOfMeasure;
                    end;

                    trigger OnPostDataItem()
                    begin
                        Level := NextLevel;

                        if CompItem."Production BOM No." <> '' then
                            UpperLevelItem := CompItem;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    while BomComponent[Level].Next = 0 do begin
                        Level := Level - 1;
                        if Level < 1 then
                            CurrReport.Break;
                        if NoListType[Level] = NoListType[Level] ::Item then begin // P8001030
                            UpperLevelItem.Get(NoList[Level]);
                            UpperLevelItem."Production BOM No." := UpperLevelItem.ProductionBOMNo(VariantList[Level], LocationCode); // P8001030
                        end else                                                   // P8001030
                            UpperLevelItem."Production BOM No." := NoList[Level];
                        BomComponent[Level].SetRange(
                          "Production BOM No.",
                          UpperLevelItem."Production BOM No.");
                        BomComponent[Level].SetRange(
                          "Version Code", VersionCode[Level]);
                    end;

                    NextLevel := Level;
                    Clear(CompItem);
                    QtyPerUnitOfMeasure := 1;
                    case BomComponent[Level].Type of
                        BomComponent[Level].Type::Item:
                            begin
                                CompItem.Get(BomComponent[Level]."No.");
                                if CompItem."Production BOM No." <> '' then begin
                                    CompItem."Production BOM No." := CompItem.ProductionBOMNo(BomComponent[Level]."Variant Code", LocationCode); // P8001030
                                    NextLevel := Level + 1;
                                    Clear(BomComponent[NextLevel]);
                                    NoList[NextLevel] := CompItem."No.";
                                    VariantList[Level] := BomComponent[Level]."Variant Code"; // P8001030
                                    VersionCode[NextLevel] :=
                                      VersionMgt.GetBOMVersion(CompItem."Production BOM No.", "Calc.Date", false);
                                    BomComponent[NextLevel].SetRange("Production BOM No.", CompItem."Production BOM No.");
                                    BomComponent[NextLevel].SetRange(
                                      "Version Code",
                                      VersionCode[NextLevel]);
                                    QtyPerUnitOfMeasure :=
                                      /* UOMMgt.GetQtyPerUnitOfMeasure(
                                         Item,
                                         Item."Base Unit of Measure") /*/
                                      UOMMgt.GetQtyPerUnitOfMeasure(
                                        CompItem,
                                        VersionMgt.GetBOMUnitOfMeasure(
                                          CompItem."Production BOM No.", VersionCode[NextLevel]));
                                end;
                            end;
                        BomComponent[Level].Type::"Production BOM":
                            begin
                                ProdBOM.Get(BomComponent[Level]."No.");
                                NextLevel := Level + 1;
                                Clear(BomComponent[NextLevel]);
                                NoListType[NextLevel] := NoListType[NextLevel] ::"Production BOM";
                                NoList[NextLevel] := ProdBOM."No.";
                                VariantList[NextLevel] := ''; // P8001030
                                VersionCode[NextLevel] :=
                                  VersionMgt.GetBOMVersion(ProdBOM."No.", "Calc.Date", false);
                                BomComponent[NextLevel].SetRange("Production BOM No.", NoList[NextLevel]);
                                BomComponent[NextLevel].SetRange("Version Code", VersionCode[NextLevel]);
                            end;
                    end;

                    if NextLevel <> Level then
                        Quantity[NextLevel] :=
                          CalcMgt.CalcQtyAdjdForBOMScrap(
                            BomComponent[NextLevel - 1].Quantity,
                            BomComponent[NextLevel - 1]."Scrap %") *
                          QtyPerUnitOfMeasure;

                end;

                trigger OnPreDataItem()
                begin
                    Level := 1;

                    //ProdBOM.GET();

                    VersionCode[Level] := VersionMgt.GetBOMVersion("Production BOM Header"."No.", "Calc.Date", false);
                    Clear(BomComponent);
                    BomComponent[Level]."Production BOM No." := "Production BOM Header"."No.";
                    BomComponent[Level].SetRange("Production BOM No.", "Production BOM Header"."No.");
                    BomComponent[Level].SetRange("Version Code", VersionCode[Level]);
                    BomComponent[Level].SetFilter("Starting Date", '%1|..%2', 0D, "Calc.Date");
                    BomComponent[Level].SetFilter("Ending Date", '%1|%2..', 0D, "Calc.Date");
                    NoList[Level] := "Production BOM Header"."No.";
                    NoListType[Level] := NoListType[Level] ::"Production BOM";
                    VariantList[Level] := ''; // P8001030
                    /*Quantity[Level] :=
                      1 *
                      UOMMgt.GetQtyPerUnitOfMeasure(Item,Item."Base Unit of Measure") /
                      UOMMgt.GetQtyPerUnitOfMeasure(
                        Item,
                        VersionMgt.GetBOMUnitOfMeasure(
                          Item."Production BOM No.",VersionCode[Level]));
                    
                    //UpperLevelItem := Item;
                    */

                end;
            }

            trigger OnPreDataItem()
            begin
                //ItemFilter := Item.GETFILTERS;

                //SETFILTER("Production BOM No.",'<>%1','');
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
                    field("Calc.Date"; "Calc.Date")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Calculation Date';
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
            "Calc.Date" := WorkDate;
        end;
    }

    labels
    {
        QuantityExplosionofBOMCaption = 'Quantity Explosion of BOM';
        PAGENOCaption = 'Page';
        TotQtyCaption = 'Total Qty.';
        ScrapCaption = 'Scrap %';
        BOMQuantityCaption = 'BOM Qty.';
        DescriptionCaption = 'Description';
        NoCaption = 'No.';
        LevelCaption = 'Level';
        UOMCodeCaption = 'Unit of Measure Code';
        BOMVariantCaption = 'Variant';
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get;
    end;

    var
        CompanyInformation: Record "Company Information";
        ProdBOM: Record "Production BOM Header";
        BomComponent: array[99] of Record "Production BOM Line";
        UpperLevelItem: Record Item;
        CompItem: Record Item;
        UOMMgt: Codeunit "Unit of Measure Management";
        VersionMgt: Codeunit VersionManagement;
        CalcMgt: Codeunit "Cost Calculation Management";
        ItemFilter: Text[250];
        "Calc.Date": Date;
        NoListType: array[99] of Option Item,"Production BOM";
        NoList: array[99] of Code[20];
        VersionCode: array[99] of Code[20];
        Quantity: array[99] of Decimal;
        QtyPerUnitOfMeasure: Decimal;
        Level: Integer;
        NextLevel: Integer;
        BOMQty: Decimal;
        Text000: Label 'As of %1, Location: %2';
        LocationCode: Code[10];
        VariantList: array[99] of Code[10];
}

