report 37002543 "Item Test Results"
{
    // PR2.00
    //   Modify for Lot No. Information and multiple test sets
    // 
    // PR3.70.07
    // P8000152A, Myers Nissi, Jack Reynolds, 26 NOV 04
    //   Add support for date and lookup types
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 06 MAY 10
    //   RTC Reporting Upgrade
    // 
    // PRW16.00.04
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
    DefaultRenderingLayout = StandardRDLCLayout;

    ApplicationArea = FOODBasic;
    Caption = 'Item Test Results';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Lot No. Information"; "Lot No. Information")
        {
            DataItemTableView = SORTING("Item No.", "Variant Code", "Lot No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "Item No.", "Variant Code", "Lot No.";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            column(LotInfoItemNo; "Item No.")
            {
                IncludeCaption = true;
            }
            column(ItemDesc; Item.Description)
            {
            }
            column(LotInfoRec; "Item No." + "Variant Code" + "Lot No.")
            {
            }
            column(LotInfoHeader; 'LotNoInfo')
            {
            }
            dataitem("Quality Control Line"; "Quality Control Line")
            {
                DataItemLink = "Item No." = FIELD("Item No."), "Variant Code" = FIELD("Variant Code"), "Lot No." = FIELD("Lot No.");
                DataItemTableView = SORTING("Item No.", "Variant Code", "Lot No.", "Test No.", "Test Code");
                RequestFilterFields = "Test Code", "Test Date", Status;
                column(QCLineTestCode; "Test Code")
                {
                }
                column(QCLineDesc; Description)
                {
                    IncludeCaption = true;
                }
                column(QCLineTestDate; "Test Date")
                {
                    IncludeCaption = true;
                }
                column(QCLineStatus; Status)
                {
                    IncludeCaption = true;
                }
                column(QCLineResult; Result)
                {
                    IncludeCaption = true;
                }
                column(QCLineLotNo; "Lot No.")
                {
                    IncludeCaption = true;
                }
                column(Specs; Specs)
                {
                }
                column(QCLineTestNo; "Test No.")
                {
                    IncludeCaption = true;
                }
                column(QCLineRec; "Item No." + "Variant Code" + "Lot No." + Format("Test No.") + "Test Code")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    // P8000152A Begin
                    case Type of
                        Type::Boolean:
                            Specs := UpperCase(Format("Boolean Target Value"));
                        Type::Date:
                            Specs := '';
                        Type::"Lookup":
                            Specs := "Lookup Target Value";
                        Type::Numeric:
                            Specs := StrSubstNo(Text000, Format("Numeric Low Value"), Format("Numeric High Value"));
                        Type::Text:
                            Specs := "Text Target Value";
                    end;
                    // P8000152A End
                end;
            }

            trigger OnAfterGetRecord()
            begin
                Item.Get("Item No.");  // P8000812
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
            LayoutFile = './layout/ItemTestResults.rdlc';
        }
    }

    labels
    {
        ItemLotCaption = 'Item Lot';
        PageNoCaption = 'Page';
        TestCodeCaption = 'Test Code';
        SpecsCaption = 'Specifications';
    }

    var
        Item: Record Item;
        Specs: Text[50];
        Text000: Label '%1 to %2';
}

