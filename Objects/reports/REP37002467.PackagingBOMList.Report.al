report 37002467 "Packaging BOM List"
{
    // PR1.00
    //   Listing on package BOM's
    // 
    // PR1.20
    //   Change title from "Packaging BOM List"
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 06 APR 10
    //   RTC Reporting Upgrade
    // 
    // PRW16.00.04
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // PRW17.10.01
    // P8001258, Columbus IT, Jack Reynolds, 10 JAN 14
    //   Increase size ot text fields/variables
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
    RDLCLayout = './layout/PackagingBOMList.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Packaging BOM List';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Production BOM Version"; "Production BOM Version")
        {
            DataItemTableView = SORTING("Production BOM No.", "Version Code") ORDER(Ascending) WHERE(Type = CONST(BOM));
            RequestFilterFields = "Production BOM No.", "Version Code", Description, Status;
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            column(ProdBOMVersionProdBOMNo; "Production BOM No.")
            {
            }
            column(ProdBOMVersionDesc; Description)
            {
            }
            column(ProdBOMVersionVersionCode; "Version Code")
            {
                IncludeCaption = true;
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
            column(ProdBOMDesc; ProdBOMDesc)
            {
            }

            trigger OnAfterGetRecord()
            begin
                // get the description of the BOM
                ProductionBOM.Get("Production BOM Version"."Production BOM No.");
                ProdBOMDesc := ProductionBOM.Description;
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
        PackagingBOMVersionListCaption = 'Packaging BOM Version List';
        PAGENOCaption = 'Page';
        PackagingBOMNoCaption = 'Packaging BOM No.';
        ProdBOMVersionDescCaption = 'Version Description';
        ProdBOMDescCaption = 'Description';
    }

    var
        ProductionBOM: Record "Production BOM Header";
        ProdBOMDesc: Text[100];
        Packaging_BOM_Version_ListCaptionLbl: Label 'Packaging BOM Version List';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Packaging_BOM_No_CaptionLbl: Label 'Packaging BOM No.';
        Production_BOM_Version_DescriptionCaptionLbl: Label 'Version Description';
        ProdBOMDescCaptionLbl: Label 'Description';
}

