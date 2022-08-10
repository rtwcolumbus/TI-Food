report 37002069 "Delivery Trip Route Sheet"
{
    // PRW15.00.01
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   Order listing for a delivery trip
    // 
    // PRW16.00.03
    // P8000813, VerticalSoft, MMAS, 19 APR 10
    //   Report design for RTC
    // 
    // P8000834, VerticalSoft, Jack Reynolds, 14 JUN 10
    //   Fix problem with unit of measure on return shipments
    // 
    // PRW16.00.04
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // PRW16.00.05
    // P8000954, Columbus IT, Jack Reynolds, 08 JUL 11
    //   Support for transfer orders on delivery routes and trips
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.01
    // P80060328, To Increase, Jack Reynolds, 11 JUN 18
    //   Delivery Driver is no longer FlowField
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    DefaultLayout = RDLC;
    RDLCLayout = './layout/DeliveryTripRouteSheet.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Delivery Trip Route Sheet';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Delivery Trip"; "N138 Delivery Trip")
        {
            RequestFilterFields = "No.", "Location Code", "Departure Date", "Departure Time";
            column(DeliveryTripNo; "No.")
            {
                IncludeCaption = true;
            }
            dataitem(PageLoop; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                column(DeliveryTripDriverName; "Delivery Trip"."Driver Name")
                {
                }
                column(DeliveryTripDriverNo; "Delivery Trip"."Driver No.")
                {
                }
                column(DeliveryTripTruckID; "Delivery Trip"."Truck ID")
                {
                    IncludeCaption = true;
                }
                column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
                {
                }
                column(DeliveryTripDesc; "Delivery Trip".Description)
                {
                    IncludeCaption = true;
                }
                column(DeliveryTripDepartureTime; Format("Delivery Trip"."Departure Time", 0, '<Hours12,2>:<Minutes,2> <AM/PM>'))
                {
                }
                column(DeliveryTripDepartureDate; "Delivery Trip"."Departure Date")
                {
                }
                dataitem("Warehouse Request"; "Warehouse Request")
                {
                    DataItemLink = "Delivery Trip" = FIELD("No.");
                    DataItemLinkReference = "Delivery Trip";
                    DataItemTableView = SORTING("Delivery Stop No.") WHERE(Type = CONST(Outbound));
                    dataitem("Sales Line"; "Sales Line")
                    {
                        DataItemLink = "Document Type" = FIELD("Source Subtype"), "Document No." = FIELD("Source No."), "Location Code" = FIELD("Location Code");
                        DataItemTableView = WHERE(Type = CONST(Item), Quantity = FILTER(> 0));

                        trigger OnAfterGetRecord()
                        begin
                            TempSalesLine := "Sales Line";
                            TempSalesLine.Insert;

                            CurrReport.Skip;
                        end;

                        trigger OnPreDataItem()
                        begin
                            if "Warehouse Request"."Source Type" <> DATABASE::"Sales Line" then
                                CurrReport.Break;
                        end;
                    }
                    dataitem("Purchase Line"; "Purchase Line")
                    {
                        DataItemLink = "Document Type" = FIELD("Source Subtype"), "Document No." = FIELD("Source No."), "Location Code" = FIELD("Location Code");
                        DataItemTableView = WHERE(Type = CONST(Item), Quantity = FILTER(> 0));

                        trigger OnAfterGetRecord()
                        begin
                            TempSalesLine.Init;
                            TempSalesLine."Line No." := "Line No.";
                            TempSalesLine."No." := "No.";
                            TempSalesLine.Description := Description;
                            TempSalesLine."Unit of Measure Code" := "Unit of Measure Code"; // P8000834
                            TempSalesLine.Quantity := Quantity;
                            TempSalesLine.Insert;

                            CurrReport.Skip;
                        end;

                        trigger OnPreDataItem()
                        begin
                            if "Warehouse Request"."Source Type" <> DATABASE::"Purchase Line" then
                                CurrReport.Break;
                        end;
                    }
                    dataitem("Transfer Line"; "Transfer Line")
                    {
                        DataItemLink = "Document No." = FIELD("Source No."), "Transfer-from Code" = FIELD("Location Code");
                        DataItemTableView = WHERE(Type = CONST(Item), Quantity = FILTER(> 0));

                        trigger OnAfterGetRecord()
                        begin
                            // P800095
                            TempSalesLine.Init;
                            TempSalesLine."Line No." := "Line No.";
                            TempSalesLine."No." := "Item No.";
                            TempSalesLine.Description := Description;
                            TempSalesLine."Unit of Measure Code" := "Unit of Measure Code";
                            TempSalesLine.Quantity := Quantity;
                            TempSalesLine.Insert;

                            CurrReport.Skip;
                        end;

                        trigger OnPreDataItem()
                        begin
                            // P8000954
                            if "Warehouse Request"."Source Type" <> DATABASE::"Transfer Line" then
                                CurrReport.Break;
                        end;
                    }
                    dataitem(OrderLine; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        column(StopNo; StopNo)
                        {
                        }
                        column(OrderNo; OrderNo)
                        {
                        }
                        column(AddressDisplay; AddressDisplay)
                        {
                        }
                        column(TempShpmtLineNo; TempSalesLine."No.")
                        {
                        }
                        column(TempShpmtLineDesc; TempSalesLine.Description)
                        {
                        }
                        column(TempShpmtLineQuantity; TempSalesLine.Quantity)
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(TempShpmtLineUOMCode; TempSalesLine."Unit of Measure Code")
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then begin
                                StopNo := "Warehouse Request"."Delivery Stop No.";
                                OrderNo := "Warehouse Request"."Source No.";
                            end else begin
                                StopNo := '';
                                OrderNo := '';
                            end;

                            if Number <= AddressLines then
                                AddressDisplay := Address[Number]
                            else
                                AddressDisplay := '';

                            if Number = 1 then
                                TempSalesLine.FindSet
                            else
                                if Number <= OrderLines then
                                    TempSalesLine.Next
                                else
                                    Clear(TempSalesLine);
                        end;

                        trigger OnPreDataItem()
                        begin
                            OrderLines := TempSalesLine.Count;

                            if OrderLines < AddressLines then
                                SetRange(Number, 1, AddressLines)
                            else
                                SetRange(Number, 1, OrderLines);
                        end;
                    }

                    trigger OnAfterGetRecord()
                    var
                        DummyAddress: array[8] of Text[100];
                        AddressLine: Integer;
                    begin
                        case "Source Type" of
                            DATABASE::"Sales Line":
                                begin
                                    SalesHeader.Get("Source Subtype", "Source No.");
                                    FormatAddress.SalesHeaderShipTo(Address, DummyAddress, SalesHeader); // P8007748
                                end;
                            DATABASE::"Purchase Line":
                                begin
                                    PurchHeader.Get("Source Subtype", "Source No.");
                                    FormatAddress.PurchHeaderShipTo(Address, PurchHeader);
                                end;
                                // P8000954
                            DATABASE::"Transfer Line":
                                begin
                                    TransHeader.Get("Source No.");
                                    FormatAddress.TransferHeaderTransferTo(Address, TransHeader);
                                end;
                                // P8000954
                        end;

                        AddressLines := 8;
                        while Address[AddressLines] = '' do
                            AddressLines -= 1;

                        TempSalesLine.Reset;
                        TempSalesLine.DeleteAll;
                    end;
                }
            }

            trigger OnAfterGetRecord()
            begin
                CurrReport.PageNo := 1;
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
        DateFormat = 'MM/dd/yy';
        PageNoCaption = 'Page';
        DriverNoCaption = 'Driver';
        DeliveryTripRouteSheetCaption = 'Delivery Trip Route Sheet';
        DepartureDateCaption = 'Departure';
        StopNoCaption = 'Stop No.';
        OrderNoCaption = 'Order No.';
        AddressDisplayCaption = 'Address';
        ItemNoCaption = 'Item No.';
        DescriptionCaption = 'Description';
        QuantityCaption = 'Quantity';
        UOMCodeCaption = 'Unit of Measure';
    }

    var
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        TransHeader: Record "Transfer Header";
        TempSalesLine: Record "Sales Line" temporary;
        FormatAddress: Codeunit "Format Address";
        Address: array[8] of Text[100];
        AddressDisplay: Text[100];
        StopNo: Code[20];
        OrderNo: Code[20];
        AddressLines: Integer;
        OrderLines: Integer;
}

