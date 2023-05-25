report 37002066 "Pickup Load Sheet"
{
    // PR3.70.06
    // P8000080A, Myers Nissi, Steve Post, 30 AUG 04
    //   For Pickup Load Planning
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 09 AUG 07
    //   Name and address to 50 characters
    // 
    // PRW15.00.01
    // P8000599A, VerticalSoft, Jack Reynolds, 19 MAY 08
    //   Key change for Purch. Comment Line table
    // 
    // PRW16.00.03
    // P8000813, VerticalSoft, MMAS, 19 APR 10
    //   Report design for RTC
    //     1. Fixed format (text const. DateFormat) added to the date fields: "Pickup Date", "Due Date", date fields in the report body
    // 
    // PRW16.00.04
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // P8000897, VerticalSoft, Jack Reynolds, 22 JAN 11
    //   Fix spelling mistake
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
    Caption = 'Pickup Load Sheet';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Pickup Load Header"; "Pickup Load Header")
        {
            DataItemTableView = WHERE(Status = CONST(Open));
            RequestFilterFields = "No.";
            column(PickupLoadHeaderNo; "No.")
            {
            }
            column(CarrierName; CarrierName)
            {
            }
            column(PickupLoadHdrPickupDate; "Pickup Date")
            {
            }
            column(PickupLoadHdrTemperature; Temperature)
            {
            }
            column(PickupLoadHdrDueDate; "Due Date")
            {
            }
            column(PickupLoadHdrFreightCharge; "Freight Charge")
            {
            }
            column(PickupLoadHdrDueTime; Format("Due Time"))
            {
            }
            column(CarrierLabel; CarrierLabel)
            {
            }
            column(CompanyAddress8; CompanyAddress[8])
            {
            }
            column(CompanyAddress7; CompanyAddress[7])
            {
            }
            column(CompanyAddress6; CompanyAddress[6])
            {
            }
            column(CompanyAddress5; CompanyAddress[5])
            {
            }
            column(CompanyAddress4; CompanyAddress[4])
            {
            }
            column(CompanyAddress3; CompanyAddress[3])
            {
            }
            column(CompanyAddress2; CompanyAddress[2])
            {
            }
            column(CompanyAddress1; CompanyAddress[1])
            {
            }
            dataitem("Pickup Load Line"; "Pickup Load Line")
            {
                DataItemLink = "Pickup Load No." = FIELD("No.");
                DataItemTableView = SORTING("Sequence No.");
                column(PickupLoadLineSequenceNo; "Sequence No.")
                {
                }
                column(POHdrVendorOrderNo; POHdr."Vendor Order No.")
                {
                }
                column(POHdrBuyfromVendorName; POHdr."Buy-from Vendor Name")
                {
                }
                column(PickupLocationPhoneNo; PickupLocation."Phone No.")
                {
                }
                column(PickupAddress1; PickupAddress[1])
                {
                }
                column(PickupAddress2; PickupAddress[2])
                {
                }
                column(PickupAddress3; PickupAddress[3])
                {
                }
                column(PickupAddress4; PickupAddress[4])
                {
                }
                column(PickupAddress5; PickupAddress[5])
                {
                }
                column(PickupLoadLinePickupLoadNo; "Pickup Load No.")
                {
                }
                column(PickupLoadLinePurchaseOrderNo; "Purchase Order No.")
                {
                }
                dataitem("Purchase Line"; "Purchase Line")
                {
                    DataItemLink = "Document No." = FIELD("Purchase Order No.");
                    DataItemTableView = SORTING("Document Type", "Document No.", "Line No.") WHERE(Type = CONST(Item), "Outstanding Quantity" = FILTER(> 0));
                    column(PurchLineOutstandingQuantity; "Outstanding Quantity")
                    {
                    }
                    column(PurchLineNo; "No.")
                    {
                        IncludeCaption = true;
                    }
                    column(PurchLineDesc; Description)
                    {
                        IncludeCaption = true;
                    }
                    column(PurchLineUOM; "Unit of Measure")
                    {
                    }
                    column(PurchLineLineNo; "Line No.")
                    {
                    }
                }
                dataitem("Purch. Comment Line"; "Purch. Comment Line")
                {
                    DataItemLink = "No." = FIELD("Purchase Order No.");
                    DataItemTableView = SORTING("Document Type", "No.", "Document Line No.", "Line No.") WHERE("Document Type" = CONST(Order), "Document Line No." = CONST(0));
                    column(PurchCommentLineDate; Date)
                    {
                    }
                    column(PurchCommentLineComment; Comment)
                    {
                    }
                    column(PurchCommentLineLineNo; "Line No.")
                    {
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    POHdr.Get(POHdr."Document Type"::Order, "Purchase Order No.");
                    PickupLocation.Get(POHdr."Buy-from Vendor No.", "Pickup Location Code");
                    FormatAddress.PickupLocation(PickupAddress, PickupLocation);
                    FirstComment := true;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                case "Truck Type" of
                    "Truck Type"::Company:
                        begin
                            DelRoute.Get(Carrier);
                            CarrierName := DelRoute.Description;
                            CarrierLabel := Text001;
                        end;
                    "Truck Type"::"Common Carrier":
                        begin
                            Vendor.Get(Carrier);
                            CarrierName := Vendor.Name;
                            CarrierLabel := Text002;
                        end;
                end;
            end;

            trigger OnPreDataItem()
            begin
                CompanyInformation.Get('');
                FormatAddress.Company(CompanyAddress, CompanyInformation);
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
            LayoutFile = './layout/PickupLoadSheet.rdlc';
        }
    }

    labels
    {
        DateFormat = 'MM/dd/yy';
        PickupLoadNoCaption = 'Load No.:';
        PickupDateCaption = 'Pickup Date:';
        TemperatureCaption = 'Set Temp At:';
        DueDateCaption = 'Due Date:';
        FreightChargeCaption = 'Carrier Rate:';
        ReportCaption = 'PICKUP LOAD SHEET';
        DueTimeCaption = 'Due Time:';
        VendorOrderNoCaption = 'Vendor Order No.';
        VendorCaption = 'Vendor:';
        PickupLocationCaption = 'Pickup';
        PhoneCaption = 'Phone:';
        QuantityCaption = 'Quantity';
        ItemCaption = 'Item';
        UOMCaption = 'UOM';
        LocationCaption = 'Location';
        CommentsCaption = 'Comments:';
    }

    var
        PickupLocation: Record "Pickup Location";
        POHdr: Record "Purchase Header";
        CompanyInformation: Record "Company Information";
        Vendor: Record Vendor;
        DelRoute: Record "Delivery Route";
        ItemUOM: Record "Item Unit of Measure";
        FormatAddress: Codeunit "Format Address";
        CompanyAddress: array[8] of Text[100];
        PickupAddress: array[8] of Text[100];
        CarrierName: Text[100];
        CarrierLabel: Text[30];
        Text001: Label 'Truck Route :';
        Text002: Label 'Carrier Name :';
        FirstComment: Boolean;
}

