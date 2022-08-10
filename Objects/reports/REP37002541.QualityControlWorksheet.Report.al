report 37002541 "Quality Control Worksheet"
{
    // PR1.10, Navision US, John Nozzi, 29 MAR 01, New Object
    //   This report is used to print a one page worksheet where the user can fill in Q/C Test Results
    //   for a single Lot.
    // 
    // PR1.10.01
    //   Display Item Test Comments
    // 
    // PR1.20.02
    //   Rename to from QC Worksheet
    // 
    // PR2.00
    //   Change from Item Lot to Quality Control Header
    //   Add Variant Code and Test No.
    // 
    // PRW16.00.03
    // P8000813, VerticalSoft, MMAS, 11 MAY 10
    //   Report design for RTC
    // 
    // PRW16.00.04
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 20 FEB 13
    //   Restoring the SaveValues property in the Request Page.
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    DefaultLayout = RDLC;
    RDLCLayout = './layout/QualityControlWorksheet.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Quality Control Worksheet';
    UsageCategory = Documents;

    dataset
    {
        dataitem("Quality Control Header"; "Quality Control Header")
        {
            CalcFields = "Quantity on Hand";
            DataItemTableView = SORTING("Item No.", "Variant Code", "Lot No.", "Test No.") WHERE(Status = FILTER(<> Pass));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "Item No.", "Variant Code", "Lot No.", "Test No.";
            column(QCHeaderItemNo; "Item No.")
            {
            }
            column(ItemDesc; Item.Description)
            {
            }
            column(QCHeaderLotNo; "Lot No.")
            {
                IncludeCaption = true;
            }
            column(QuantityonHandItemBaseUOM; Format("Quantity on Hand") + ' ' + Item."Base Unit of Measure")
            {
            }
            column(CompanyInfoName; CompanyInformation.Name)
            {
            }
            column(QCHeaderVariantCode; "Variant Code")
            {
                IncludeCaption = true;
            }
            column(QCHeaderTestNo; "Test No.")
            {
                IncludeCaption = true;
            }
            column(DisplayComments; DisplayComments)
            {
            }
            column(ItemQuarantineCalc; Item."Quarantine Calculation")
            {
            }
            column(ItemExpirationCalc; Item."Expiration Calculation")
            {
            }
            column(ItemLotStrength; Item."Lot Strength")
            {
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
                dataitem("Data Collection Comment"; "Data Collection Comment")
                {
                    DataItemLink = "Source Key 1" = FIELD("Item No."), "Data Element Code" = FIELD("Test Code"), "Data Collection Line No." = FIELD("Line No.");
                    DataItemTableView = SORTING("Source ID", "Source Key 1", "Source Key 2", Type, "Variant Type", "Data Element Code", "Data Collection Line No.", "Line No.") WHERE("Source ID" = CONST(27), Type = CONST("Q/C"));
                    column(ItemTestCommentLineComment; Comment)
                    {
                    }
                }
            }

            trigger OnAfterGetRecord()
            begin
                if "Quantity on Hand" < 0 then
                    CurrReport.Skip;
                Item.Get("Item No.");
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(DisplayComments; DisplayComments)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Display Comments';
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
        ItemNoCaption = 'Item';
        QuantityCaption = 'Quantity';
        PageNoCaption = 'Page';
        QCWorksheetCaption = 'Quality Control Worksheet';
        QuarantineCalculationCaption = 'Quarantine';
        ReleaseDateCaption = 'Release Date';
        ShelfLifeCaption = 'Shelf Life';
        ExpDateCaption = 'Expiration Date';
        LotStrengthPercentCaption = 'Lot Strength Percent';
        CommentsCaption = 'Comments';
        TestCodeCaption = 'Test Code';
        ResultsCaption = 'Results';
        TestDateCaption = 'Test Date';
        TestTimeCaption = 'Test Time';
        TestedByCaption = 'Tested By';
        StatusCaption = 'Status';
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get;
    end;

    var
        CompanyInformation: Record "Company Information";
        Item: Record Item;
        DisplayComments: Boolean;
}

