report 37002469 "Process List"
{
    // PR1.20
    //   Listing of Process BOM's, copied from Formula List
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
    DefaultRenderingLayout = StandardRDLCLayout;

    ApplicationArea = FOODBasic;
    Caption = 'Process List';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Production BOM Version"; "Production BOM Version")
        {
            DataItemTableView = SORTING("Production BOM No.", "Version Code") ORDER(Ascending) WHERE(Type = CONST(Process));
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

    rendering
    {
        layout(StandardRDLCLayout)
        {
            Summary = 'Standard Layout';
            Type = RDLC;
            LayoutFile = './layout/ProcessList.rdlc';
        }
    }

    labels
    {
        DateFormat = 'MM/dd/yy';
        ProcessListCaption = 'Process List';
        PAGENOCaption = 'Page';
        ProcessCaption = 'Process No.';
        VerrsionDescCaption = 'Version Description';
        ProdBOMDescCaption = 'Description';
    }

    var
        ProductionBOM: Record "Production BOM Header";
        ProdBOMDesc: Text[100];
}

