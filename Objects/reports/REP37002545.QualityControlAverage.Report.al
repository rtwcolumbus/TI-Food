report 37002545 "Quality Control Average"
{
    // PRW111.00.01
    // P80037659, To-Increase, Jack Reynolds, 25 JUL 18
    //   QC-Additions: Develop average measurement
    DefaultLayout = RDLC;
    RDLCLayout = './layout/QualityControlAverage.rdlc';

    Caption = 'Quality Control Test Results';

    dataset
    {
        dataitem(QCHeader; "Quality Control Header")
        {
            CalcFields = "Quantity on Hand", "Release Date", "Expiration Date", "Lot Strength Percent";
            DataItemTableView = SORTING("Item No.", "Variant Code", "Lot No.", "Test No.");
            UseTemporary = true;
            column(QCHeaderReleaseDate; Format("Release Date"))
            {
            }
            column(CompanyInfoName; CompanyInformation.Name)
            {
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
                IncludeCaption = true;
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
            }
            dataitem(QCLine; "Quality Control Line")
            {
                DataItemTableView = SORTING("Item No.", "Variant Code", "Lot No.", "Test No.", "Test Code");
                UseTemporary = true;
                column(QCLineTestCode; "Test Code")
                {
                    IncludeCaption = true;
                }
                column(QCLineDesc; Description)
                {
                    IncludeCaption = true;
                }
                column(QCLineType; Type)
                {
                    IncludeCaption = true;
                }
                column(QCLineResult; Result)
                {
                    IncludeCaption = true;
                }
                column(QCLineStatus; FormatStatus(QCLine))
                {
                }
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

    labels
    {
        AverageResultsTitle = 'Quality Control Average Results';
        PageNoCaption = 'Page';
        TestNoCaption = 'No. of Tests';
        QuantityCaption = 'Quantity';
        ExpirationDateCaption = 'Expiration Date';
        ReleaseDateCaption = 'Release Date';
        LineStatusCaption = 'Status';
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get;
    end;

    var
        CompanyInformation: Record "Company Information";
        Item: Record Item;
        AvergeCountText: Label 'Average by %1.';
        AverageTestText: Label ' - AVERAGE MEASUREMENT';

    local procedure FormatStatus(QCLine: Record "Quality Control Line"): Text
    begin
        if QCLine.Status = QCLine.Status::"Not Tested" then
            exit('');
        exit(Format(QCLine.Status));
    end;

    procedure SetData(var Header: Record "Quality Control Header" temporary; var Line: Record "Quality Control Line" temporary)
    begin
        QCHeader := Header;
        QCHeader.Insert;
        QCLine.Copy(Line, true);
    end;
}

