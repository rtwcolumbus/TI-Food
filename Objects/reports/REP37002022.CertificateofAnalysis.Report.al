report 37002022 "Certificate of Analysis"
{
    // PR1.10.01
    //   This report is used to print a one page report of the Q/C Test Results
    //   for a single Lot.
    // 
    // PR2.00
    //   Modify for Lot No. Information and multiple test sets
    // 
    // PR3.70.07
    // P8000152A, Myers Nissi, Jack Reynolds, 26 NOV 04
    //   Get lines from lot specification table rather than quality control line table
    // 
    // PRW16.00.03
    // P8000813, VerticalSoft, MMAS, 07 MAY 10
    //   Report design for RTC
    // 
    // PRW16.00.04
    // P8000863, VerticalSoft, Jack Reynolds, 25 AUG 10
    //   Fix RDLC header alignment
    // 
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // PRW17.00
    // P8001136, Columbus IT, Jack Reynolds, 20 FEB 13
    //   Cleanup for NAV 2013
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW111.00.01
    // P80038815, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Certificate of Analysis changes
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    DefaultLayout = RDLC;
    RDLCLayout = './layout/CertificateofAnalysis.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Certificate of Analysis';
    UsageCategory = Documents;

    dataset
    {
        dataitem("Lot No. Information"; "Lot No. Information")
        {
            CalcFields = Inventory;
            DataItemTableView = SORTING("Item No.", "Variant Code", "Lot No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "Item No.", "Lot No.";
            column(CompanyInfoName; CompanyInformation.Name)
            {
            }
            column(LotInfoItemNo; "Item No.")
            {
            }
            column(LotInfoItemDesc; Item.Description)
            {
            }
            column(LotInfoVariantCode; "Variant Code")
            {
                IncludeCaption = true;
            }
            column(LotInfoLotNo; "Lot No.")
            {
                IncludeCaption = true;
            }
            column(LotInfoDocumentDate; "Document Date")
            {
            }
            dataitem("Lot Specification"; "Lot Specification")
            {
                DataItemLink = "Item No." = FIELD("Item No."), "Variant Code" = FIELD("Variant Code"), "Lot No." = FIELD("Lot No.");
                DataItemTableView = SORTING("Item No.", "Variant Code", "Lot No.", "Data Element Code") WHERE("Certificate of Analysis" = CONST(true));
                column(LotSpecDesc; Description)
                {
                }
                column(LotSpecSpecs; Specs)
                {
                }
                column(LotSpecValue; Value)
                {
                }
                column(LotSpecUOM; "Unit of Measure Code")
                {
                }
                column(LotSpecValueBold; IsBoldValue)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    // P8000152A Begin
                    if "Quality Control Test No." <> 0 then begin
                        QCLine.Get("Item No.", "Variant Code", "Lot No.", "Quality Control Test No.", "Data Element Code");
                        case Type of
                            Type::Boolean:
                                Specs := UpperCase(Format(QCLine."Boolean Target Value"));
                            Type::Date:
                                Specs := '';
                            Type::"Lookup":
                                Specs := QCLine."Lookup Target Value";
                            Type::Numeric:
                                // P80038815
                                begin
                                    Specs := StrSubstNo(Text000, QCLine."Numeric Low Value", QCLine."Numeric High Value");
                                    IsLowValue := QCLine."Numeric Result" < QCLine."Numeric Low Value";
                                    IsHighValue := QCLine."Numeric Result" > QCLine."Numeric High Value";
                                    if QCLine."Threshold on COA" then begin
                                        if IsLowValue then
                                            Value := StrSubstNo(LessThanLowerText, QCLine."Numeric Low Value")
                                        else
                                            if IsHighValue then
                                                Value := StrSubstNo(GreaterThanHigherText, QCLine."Numeric High Value")
                                            else
                                                Value := Format(QCLine."Numeric Result");
                                    end;
                                end;
                            // P80038815
                            Type::Text:
                                Specs := QCLine."Text Target Value";
                        end;
                    end else
                        Specs := '';
                    // P8000152A End
                    IsBoldValue := IsLowValue or IsHighValue;  // P80038815
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

    labels
    {
        COACaption = 'Certificate of Analysis';
        PageCaption = 'Page';
        ItemNoCaption = 'Item';
        DateReceivedCaption = 'Date Received';
        AttributeCaption = 'Attribute';
        SpecificationCaption = 'Specification';
        ResultCaption = 'Result';
        DateFormat = 'MM/dd/yy';
        UOMCaption = 'Unit of Measure';
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get;
    end;

    var
        CompanyInformation: Record "Company Information";
        Item: Record Item;
        QCLine: Record "Quality Control Line";
        Specs: Text[50];
        Text000: Label '%1 to %2';
        LessThanLowerText: Label '<%1';
        GreaterThanHigherText: Label '>%1';
        [InDataSet]
        IsBoldValue: Boolean;
        IsLowValue: Boolean;
        IsHighValue: Boolean;
}

