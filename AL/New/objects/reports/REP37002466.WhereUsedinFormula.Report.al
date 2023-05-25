report 37002466 "Where Used in Formula"
{
    // p800.1, Myers Nissi, Bob Rainville, 12/12/00, Process 800
    // Single level Formula where-used report.
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 06 APR 10
    //   RTC Reporting Upgrade
    // 
    // PRW16.00.04
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
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
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    DefaultRenderingLayout = StandardRDLCLayout;

    ApplicationArea = FOODBasic;
    Caption = 'Where Used in Formula';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = WHERE(Type = CONST(Inventory));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            column(ItemNo; "No.")
            {
            }
            column(ItemDesc; Description)
            {
                IncludeCaption = true;
            }
            dataitem("Production BOM Line"; "Production BOM Line")
            {
                DataItemLink = "No." = FIELD("No.");
                DataItemTableView = SORTING("Production BOM No.", "Version Code", "Line No.");
                column(ProdBOMLineProdBOMNo; "Production BOM No.")
                {
                }
                column(Desc; Desc)
                {
                }
                column(ProdBOMLineVersionCode; "Version Code")
                {
                    IncludeCaption = true;
                }
                column(ProdBOMLineUOMCode; "Unit of Measure Code")
                {
                }
                column(ProdBOMLineLineQuantity; Quantity)
                {
                    IncludeCaption = true;
                }
                column(ProdBOMLineStartingDate; "Starting Date")
                {
                    IncludeCaption = true;
                }
                column(ProdBOMLineEndingDate; "Ending Date")
                {
                    IncludeCaption = true;
                }

                trigger OnAfterGetRecord()
                begin
                    ProdBOM.Get("Production BOM Line"."Production BOM No.");
                    Desc := ProdBOM.Description;
                end;

                trigger OnPreDataItem()
                begin
                    SetFilter("Version Code", '<>%1', '');
                end;
            }
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
            LayoutFile = './layout/WhereUsedinFormula.rdlc';
        }
    }

    labels
    {
        ItemWhereUsedinFormulaCaption = 'Item - Where Used in Formula';
        PAGENOCaption = 'Page';
        ItemNoCaption = 'Item No.';
        UsedByCaption = 'Used By';
        DescCaption = 'Description';
        UOMCodeCaption = 'UOM Code';
    }

    var
        ProdBOM: Record "Production BOM Header";
        Desc: Text[100];
        Item___Where_Used_in_FormulaCaptionLbl: Label 'Item - Where Used in Formula';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Item__No__CaptionLbl: Label 'Item No.';
        Used_ByCaptionLbl: Label 'Used By';
        DescCaptionLbl: Label 'Description';
        UOM_CodeCaptionLbl: Label 'UOM Code';
}

