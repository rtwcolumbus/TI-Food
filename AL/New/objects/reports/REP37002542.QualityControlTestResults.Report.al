report 37002542 "Quality Control Test Results"
{
    // PR1.10, Navision US, John Nozzi, 29 MAR 01, New Object
    //   This report is used to print a one page report of the Q/C Test Results
    //   for a single Lot.
    // 
    // PR1.20.02
    //   Rename from QC Test Results
    // 
    // PR2.00
    //   Modify for Quality Control Header
    // 
    // PRW16.00.03
    // P8000813, VerticalSoft, MMAS, 11 MAY 10
    //   Report design for RTC
    // 
    // PRW16.00.04
    // P8000837, VerticalSoft, Jack Reynolds, 08 JUL 10
    //   RDLC layout issues
    // 
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    DefaultRenderingLayout = StandardRDLCLayout;

    ApplicationArea = FOODBasic;
    Caption = 'Quality Control Test Results';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Quality Control Header"; "Quality Control Header")
        {
            CalcFields = "Quantity on Hand", "Release Date", "Expiration Date", "Lot Strength Percent";
            DataItemTableView = SORTING("Item No.", "Variant Code", "Lot No.", "Test No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "Item No.", "Variant Code", "Lot No.", "Test No.", Status;
            column(QCHeaderStatus; Status)
            {
                IncludeCaption = true;
            }
            column(QCHeaderReleaseDate; Format("Release Date"))
            {
            }
            column(CompanyInfoName; CompanyInformation.Name)
            {
            }
            column(QCHeaderLotStrengthPer; "Lot Strength Percent")
            {
                IncludeCaption = true;
            }
            column(QCHeaderExpDate; Format("Expiration Date"))
            {
            }
            column(QuantityonHandItemBaseUOM; Format("Quantity on Hand") + ' ' + Item."Base Unit of Measure")
            {
            }
            column(ItemDesc; Item.Description)
            {
            }
            column(QCHeaderItemNo; "Item No.")
            {
            }
            column(QCHeaderLotNo; "Lot No.")
            {
                IncludeCaption = true;
            }
            column(QCHeaderVariantCode; "Variant Code")
            {
                IncludeCaption = true;
            }
            column(QCHeaderTestNo; "Test No.")
            {
                IncludeCaption = true;
            }
            dataitem("Quality Control Line"; "Quality Control Line")
            {
                DataItemLink = "Item No." = FIELD("Item No."), "Variant Code" = FIELD("Variant Code"), "Lot No." = FIELD("Lot No."), "Test No." = FIELD("Test No.");
                DataItemTableView = SORTING("Item No.", "Variant Code", "Lot No.", "Test No.", "Test Code");
                column(QCLineTestCode; "Test Code")
                {
                }
                column(QCLineDesc; Description)
                {
                    IncludeCaption = true;
                }
                column(QCLineType; Type)
                {
                    IncludeCaption = true;
                }
                column(QCLineTestDate; Format("Test Date"))
                {
                }
                column(QCLineTestTime; "Test Time")
                {
                    IncludeCaption = true;
                }
                column(QCLineTestedBy; "Tested By")
                {
                    IncludeCaption = true;
                }
                column(QCLineResult; Result)
                {
                }
                column(QCLineStatus; Status)
                {
                    IncludeCaption = true;
                }

                trigger OnAfterGetRecord()
                begin
                    case Type of
                        Type::Boolean:
                            begin
                                "Numeric Result" := 0;
                                "Boolean Result" := false;
                            end;
                        Type::Date:
                            begin
                                "Text Result" := '';
                                "Boolean Result" := false;
                            end;
                        Type::"Lookup":
                            begin
                                "Text Result" := '';
                                "Numeric Result" := 0;
                            end;
                    end;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                Item.Get("Item No.");
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
            LayoutFile = './layout/QualityControlTestResults.rdlc';
        }
    }

    labels
    {
        QCReleaseDateCaption = 'Release Date';
        TestCodeCaption = 'Test Code';
        TestDateCaption = 'Test Date';
        ResultsCaption = 'Results';
        PageNoCaption = 'Page';
        ExpirationDateCaption = 'Expiration Date';
        ItemNoCaption = 'Item';
        QuantityCaption = 'Quantity';
        QCTestResultsCaption = 'Quality Control Test Results';
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get;
    end;

    var
        CompanyInformation: Record "Company Information";
        Item: Record Item;
}

