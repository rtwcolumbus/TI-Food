report 37002210 "Repack Order"
{
    // PR4.00.06
    // P8000496A, VerticalSoft, Jack Reynolds, 25 JUL 07
    //   Document style report for repack orders (header and lines)
    // 
    // PRW15.00.03
    // P8000624A, VerticalSoft, Jack Reynolds, 19 AUG 08
    //   Add country of origin to header
    // 
    // PRW16.00.03
    // P8000813, VerticalSoft, MMAS, 07 MAY 10
    //   Report design for RTC
    // 
    // PRW16.00.04
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
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
    Caption = 'Repack Order';
    UsageCategory = Documents;

    dataset
    {
        dataitem("Repack Order"; "Repack Order")
        {
            DataItemTableView = SORTING(Status);
            RequestFilterFields = "No.", "Item No.", "Date Required";
            column(RepackOrderNo; "No.")
            {
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);
                dataitem(PageLoop; "Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                    column(RepackOrderItemNo; "Repack Order"."Item No.")
                    {
                    }
                    column(RepackOrderDesc; "Repack Order".Description)
                    {
                    }
                    column(RepackOrderRepackLocation; "Repack Order"."Repack Location")
                    {
                        IncludeCaption = true;
                    }
                    column(RepackOrderDestinationLocation; "Repack Order"."Destination Location")
                    {
                        IncludeCaption = true;
                    }
                    column(RepackOrderDateRequired; Format("Repack Order"."Date Required"))
                    {
                    }
                    column(RepackOrderUOMCode; "Repack Order"."Unit of Measure Code")
                    {
                    }
                    column(RepackOrderQuantity; "Repack Order".Quantity)
                    {
                        IncludeCaption = true;
                    }
                    column(LotTextOut; LotTextOut)
                    {
                    }
                    column(FarmText; FarmText)
                    {
                    }
                    column(BrandText; BrandText)
                    {
                    }
                    column(CopyText; CopyText)
                    {
                    }
                    column(CountryText; CountryText)
                    {
                    }
                    column(EmptyStringCaption; EmptyString)
                    {
                    }
                    column(OutputNo; OutputNo)
                    {
                    }
                    dataitem("Repack Order Line"; "Repack Order Line")
                    {
                        DataItemLink = "Order No." = FIELD("No.");
                        DataItemLinkReference = "Repack Order";
                        DataItemTableView = SORTING("Order No.", "Line No.");
                        column(RepackOrderLineType; Type)
                        {
                            IncludeCaption = true;
                        }
                        column(RepackOrderLineNo; "No.")
                        {
                            IncludeCaption = true;
                        }
                        column(RepackOrderLineDesc; Description)
                        {
                            IncludeCaption = true;
                        }
                        column(LocationText; LocationText)
                        {
                        }
                        column(RepackOrderLineUOMCode; "Unit of Measure Code")
                        {
                        }
                        column(RepackOrderLineQuantity; Quantity)
                        {
                            IncludeCaption = true;
                        }
                        column(LotTextIn; LotTextIn)
                        {
                        }
                        column(TransferText; TransferText)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            case Type of
                                Type::Item:
                                    begin
                                        if "Lot No." <> '' then
                                            LotTextIn := "Lot No."
                                        else
                                            LotTextIn := PadStr('', 30, '_');

                                        if "Source Location" <> '' then
                                            LocationText := "Source Location"
                                        else
                                            LocationText := PadStr('', 30, '_');

                                        TransferText := PadStr('', 30, '_');
                                    end;

                                Type::Resource:
                                    begin
                                        LotTextIn := '';
                                        LocationText := '';
                                        TransferText := '';
                                    end;
                            end;
                        end;
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    CurrReport.PageNo := 1;

                    if Number = 1 then
                        CopyText := ''
                    else begin
                        CopyText := Text001;
                        //mmas
                        if IsServiceTier then
                            OutputNo += 1;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    SetRange(Number, 1, NoOfCopies + 1);

                    //mmas
                    if IsServiceTier then
                        OutputNo := 1;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if "Lot No." <> '' then
                    LotTextOut := "Lot No."
                else
                    LotTextOut := PadStr('', StrLen(LotTextOut), '_');

                if Farm <> '' then
                    FarmText := Farm
                else
                    FarmText := PadStr('', StrLen(FarmText), '_');

                if Brand <> '' then
                    BrandText := Brand
                else
                    BrandText := PadStr('', StrLen(BrandText), '_');

                // P8000624A Begin
                if "Country/Region of Origin Code" = '' then
                    //CountryText := PADSTR('',50,'_')    // P800813
                    CountryText := PadStr('', StrLen(CountryText), '_')      // P800813
                else begin
                    Country.Get("Country/Region of Origin Code");
                    CountryText := Country.Name;
                end;
                // P8000624A End
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
                    field(NoOfCopies; NoOfCopies)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'No. of Copies';
                    }
                }
            }
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
            LayoutFile = './layout/RepackOrder.rdlc';
        }
    }

    labels
    {
        RepackOrderCaption = 'Repack Order';
        OrderNoCaption = 'Order No.';
        ItemNoCaption = 'Item';
        DateRequiredCaption = 'Date Required';
        LocationCaption = 'Source Location';
        UOMCodeCaption = 'Unit of Measure';
        LotCaption = 'Lot No.';
        FarmCaption = 'Farm';
        BrandCaption = 'Brand';
        QuantityProducedCaption = 'Quantity Produced';
        PostingDateCaption = 'Posting Date';
        QuantityTransferredCaption = 'Quantity Transferred';
        QuantityConsumedCaption = 'Quantity Consumed';
        PAGENOCaption = 'Page';
        CountryCaption = 'Country of Origin';
    }

    var
        Country: Record "Country/Region";
        NoOfCopies: Integer;
        CopyText: Text[30];
        LotTextOut: Text[30];
        FarmText: Text[30];
        BrandText: Text[30];
        LotTextIn: Text[30];
        LocationText: Text[30];
        TransferText: Text[30];
        Text001: Label 'Copy';
        CountryText: Text[50];
        OutputNo: Integer;
        EmptyString: Label ' ';
}

