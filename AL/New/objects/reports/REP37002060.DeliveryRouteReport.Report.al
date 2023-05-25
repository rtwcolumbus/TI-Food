report 37002060 "Delivery Route Report"
{
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.03
    // P8000821, VerticalSoft, Jack Reynolds, 04 MAY 10
    //   Modified to support vendors as well as customers
    // 
    // PRW16.00.03
    // P8000813, VerticalSoft, MMAS, 04 MAY 10
    //   Report design for RTC
    // 
    // PRW16.00.04
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 20 FEB 13
    //   Restoring the SaveValues property in the Request Page.
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    DefaultRenderingLayout = StandardRDLCLayout;

    Caption = 'Delivery Route Report';

    dataset
    {
        dataitem("Delivery Route"; "Delivery Route")
        {
            RequestFilterFields = "No.";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            column(ShowMatrix; ShowMatrix)
            {
            }
            column(DeliveryRouteNo; "No.")
            {
                IncludeCaption = true;
            }
            column(DeliveryRouteDesc; Description)
            {
                IncludeCaption = true;
            }
            column(DeliveryRouteDefaultDriverNo; "Default Driver No.")
            {
                IncludeCaption = true;
            }
            column(DeliveryRouteDefaultDriverName; "Default Driver Name")
            {
                IncludeCaption = true;
            }
            column(DeliveryRouteDesc2; "Description 2")
            {
            }
            dataitem("Delivery Routing Matrix Line"; "Delivery Routing Matrix Line")
            {
                DataItemLink = "Delivery Route No." = FIELD("No.");
                DataItemTableView = SORTING("Delivery Route No.", "Day Of Week", "Delivery Stop No.");
                column(DelRoutMatrixLineDayOfWeek; "Day Of Week")
                {
                }
                column(DelRoutMatrixLineDeliveryStopNo; "Delivery Stop No.")
                {
                }
                column(DelRoutMatrixLineSourceNo; "Source No.")
                {
                    IncludeCaption = true;
                }
                column(SourceName; SourceName)
                {
                }
                column(DelRoutMatrixLineStandingOrderNo; "Standing Order No.")
                {
                    IncludeCaption = true;
                }
                column(DelRoutMatrixLineSourceType; "Source Type")
                {
                }
                column(DelRoutMatrixLineSourceNo2; "Source No. 2")
                {
                }
                column(DelRoutMatrixLineDeliveryRouteNo; "Delivery Route No.")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    // P8000821
                    SourceName := '';
                    case "Source Type" of
                        "Source Type"::Customer, "Source Type"::"Ship-to":
                            if Customer.Get("Source No.") then
                                SourceName := Customer.Name
                            else
                                CurrReport.Skip;
                        "Source Type"::Vendor, "Source Type"::"Order Address":
                            if Vendor.Get("Source No.") then
                                SourceName := Vendor.Name
                            else
                                CurrReport.Skip;
                    end;
                    // P8000821
                end;

                trigger OnPreDataItem()
                begin
                    if not ShowMatrix then
                        CurrReport.Break;
                end;
            }
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
                    field("Show Routing Matrix"; ShowMatrix)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Show Routing Matrix';
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
            LayoutFile = './layout/DeliveryRouteReport.rdlc';
        }
    }

    labels
    {
        PAGENOCaption = 'Page';
        ReportCaption = 'Delivery Route Report';
        StopNoCaption = 'Stop No.';
        SourceNameCaption = 'Customer/Vendor Name';
    }

    var
        ShowMatrix: Boolean;
        Customer: Record Customer;
        Vendor: Record Vendor;
        SourceName: Text[100];
}

