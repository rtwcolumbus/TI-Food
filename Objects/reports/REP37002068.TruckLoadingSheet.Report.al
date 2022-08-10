report 37002068 "Truck Loading Sheet"
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
    RDLCLayout = './layout/TruckLoadingSheet.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Truck Loading Sheet';
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
                    DataItemTableView = SORTING("Delivery Stop No.") ORDER(Descending) WHERE(Type = CONST(Outbound));
                    dataitem(ContainerLine; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        column(StopNo; StopNo)
                        {
                        }
                        column(OrderNo; OrderNo)
                        {
                        }
                        column(DestName; DestName)
                        {
                        }
                        column(ContainerLicensePlate; ContainerHeader."License Plate")
                        {
                        }
                        column(ContainerDescription; ContainerHeader.Description)
                        {
                        }
                        column(ContainerWeight; ContainerWeight)
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(WeightCaption; WeightCaption)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then begin
                                StopNo := "Warehouse Request"."Delivery Stop No.";
                                OrderNo := "Warehouse Request"."Source No.";
                                DestName := DestinationName("Warehouse Request"."Destination Type", "Warehouse Request"."Destination No.");
                            end else begin
                                StopNo := '';
                                OrderNo := '';
                                DestName := '';
                            end;

                            if ContainerCount = 0 then begin
                                Clear(ContainerHeader);
                                ContainerHeader."License Plate" := Text001;
                            end else
                                if Number = 1 then
                                    ContainerHeader.FindSet
                                else
                                    ContainerHeader.Next;

                            ContainerHeader.CalcFields("Total Net Weight (Base)", "Line Tare Weight (Base)");
                            ContainerWeight := WeightFactor * (ContainerHeader."Container Tare Weight (Base)" + ContainerHeader."Line Tare Weight (Base)" +
                              ContainerHeader."Total Net Weight (Base)");
                        end;

                        trigger OnPreDataItem()
                        begin
                            if ContainerCount = 0 then
                                SetRange(Number, 1)
                            else
                                SetRange(Number, 1, ContainerCount);
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        ContainerHeader.SetRange("Document Type", "Warehouse Request"."Source Type");
                        ContainerHeader.SetRange("Document Subtype", "Warehouse Request"."Source Subtype");
                        ContainerHeader.SetRange("Document No.", "Warehouse Request"."Source No.");
                        ContainerHeader.SetRange("Location Code", "Warehouse Request"."Location Code");
                        ContainerCount := ContainerHeader.Count;
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
        DeliveryTripRouteSheetCaption = 'Truck Loading Sheet';
        DepartureDateCaption = 'Departure';
        StopNoCaption = 'Stop No.';
        OrderNoCaption = 'Order No.';
        DestinationCaption = 'Destination';
        LicensePlateCaption = 'License Plate';
        DescriptionCaption = 'Description';
        QuantityCaption = 'Quantity';
        UOMCodeCaption = 'Unit of Measure';
    }

    trigger OnPreReport()
    var
        WeightUOM: Code[10];
        VolumeUOM: Code[10];
    begin
        FoodDeliveryTripMgt.GetWeightVolumeUOM(WeightUOM, VolumeUOM);
        WeightFactor := P800UOMFns.ConvertUOM(1, 'METRIC BASE', WeightUOM);
        WeightCaption := StrSubstNo(Text000, WeightUOM);
    end;

    var
        ContainerHeader: Record "Container Header";
        FoodDeliveryTripMgt: Codeunit "Food Delivery Trip Management";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
        StopNo: Code[20];
        OrderNo: Code[20];
        DestName: Text[100];
        WeightCaption: Text[30];
        WeightFactor: Decimal;
        ContainerCount: Integer;
        Text000: Label 'Weight (%1)';
        Text001: Label '*** NO CONTAINERS ***';
        ContainerWeight: Decimal;

    local procedure DestinationName(Type: Integer; No: Code[20]): Text[100]
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Location: Record Location;
    begin
        case Type of
            "Warehouse Request"."Destination Type"::Customer:
                begin
                    Customer.Get("Warehouse Request"."Destination No.");
                    exit(Customer.Name);
                end;
            "Warehouse Request"."Destination Type"::Vendor:
                begin
                    Vendor.Get("Warehouse Request"."Destination No.");
                    exit(Vendor.Name);
                end;
            "Warehouse Request"."Destination Type"::Location:
                begin
                    Location.Get("Warehouse Request"."Destination No.");
                    exit(Location.Name);
                end;
        end;
    end;
}

