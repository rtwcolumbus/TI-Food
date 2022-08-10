page 37002065 "Posted Delivery Route Review"
{
    // PR3.70.06
    // P8000079A, Myers Nissi, Jack Reynolds, 16 SEP 04
    //   Renamed Functions menu button to Print
    // 
    // PRW15.00.01
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   Modified due to table changes in delivery routes
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.02
    // P8000781, VerticalSoft, MMAS, 05 MAR 10 Page changes
    //   changed methods: OnOpenPage()
    //   Refresh action is promoted
    // 
    // PRW16.00.03
    // P8000810, VerticalSoft, Don Bresee, 06 APR 10
    //   Remove subpage, add new fields
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 19 FEB 13
    //   Restoring the SaveValues Property.
    // 
    // PRW111.00
    // P80059471, To Increase, Jack Reynolds, 25 JUN 18
    //   Cleanup TimerUpdate property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Posted Delivery Route Review';
    DataCaptionFields = "Delivery Route No.";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Sales Invoice Header";
    SourceTableView = SORTING("Shipment Date", "Delivery Route No.", "Delivery Stop No.");
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            field("Delivery Date"; DeliveryDate)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Delivery Date';

                trigger OnValidate()
                begin
                    SetDeliveryDate;
                    CurrPage.Update(false);
                    DeliveryRouteMgmt.GetPostedDeliveryDriverNo(DeliveryDate, "Delivery Route No.", DeliveryDriverNo);
                end;
            }
            field("Route Filter"; RouteFilter)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Route Filter';
                TableRelation = "Delivery Route";

                trigger OnLookup(var Text: Text): Boolean
                begin
                    exit(DeliveryRouteMgmt.LookupRoute(Text));
                end;

                trigger OnValidate()
                begin
                    SetFilter("Delivery Route No.", RouteFilter);
                    CurrPage.Update(false);
                    DeliveryRouteMgmt.GetPostedDeliveryDriverNo(DeliveryDate, "Delivery Route No.", DeliveryDriverNo);
                end;
            }
            group("Delivery Route Information")
            {
                Caption = 'Delivery Route Information';
                Editable = false;
                field("DeliveryRoute.""No."""; DeliveryRoute."No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'No.';
                }
                field("DeliveryRoute.Description"; DeliveryRoute.Description)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Description';
                }
                field(DeliveryDriverNo; DeliveryDriverNo)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Driver No.';
                    Editable = false;
                    TableRelation = "Delivery Driver";

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        TempDeliveryDriverNo: Text[20];
                    begin
                        TempDeliveryDriverNo := DeliveryDriverNo;
                        exit(DeliveryRouteMgmt.LookupDriver(TempDeliveryDriverNo));
                    end;
                }
                field("DeliveryRouteMgmt.GetDeliveryDriverName(DeliveryDriverNo)"; DeliveryRouteMgmt.GetDeliveryDriverName(DeliveryDriverNo))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Driver Name';
                    Editable = false;
                }
            }
            repeater(Control37002004)
            {
                Editable = false;
                ShowCaption = false;
                field("Delivery Route No."; "Delivery Route No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Delivery Stop No."; "Delivery Stop No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        SalesInvHeader.Reset;
                        SalesInvHeader := Rec;
                        PAGE.RunModal(PAGE::"Posted Sales Invoice", SalesInvHeader);
                        exit(false);
                    end;
                }
                field("Sell-to Customer No."; "Sell-to Customer No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Bill-to Name"; "Bill-to Name")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Print")
            {
                Caption = '&Print';
                action(Invoices)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Invoices';
                    Image = Invoice;
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        NumOrders: Integer;
                    begin
                        SalesInvHeader.Copy(Rec);
                        SalesInvHeader.PrintRecords(true);
                    end;
                }
            }
            action(Refresh)
            {
                ApplicationArea = FOODBasic;
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'F5';

                trigger OnAction()
                begin
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        if not DeliveryRoute.Get("Delivery Route No.") then // P8000810
            Clear(DeliveryRoute);                             // P8000810
        DeliveryRouteMgmt.GetPostedDeliveryDriverNo(DeliveryDate, "Delivery Route No.", DeliveryDriverNo);
    end;

    trigger OnOpenPage()
    var
        lcoRouteFilter: Code[250];
    begin
        if (DeliveryDate = 0D) then
            DeliveryDate := WorkDate;
        SetDeliveryDate;

        // P8000781
        lcoRouteFilter := GetFilter("Delivery Route No.");
        if (RouteFilter <> lcoRouteFilter) then begin
            RouteFilter := lcoRouteFilter;
            DeliveryRouteMgmt.GetPostedDeliveryDriverNo(DeliveryDate, "Delivery Route No.", DeliveryDriverNo);
        end;
        // P8000781
    end;

    var
        DeliveryDate: Date;
        RouteFilter: Code[250];
        SalesInvHeader: Record "Sales Invoice Header";
        Text001: Label 'Nothing to print.';
        Text002: Label 'Do you want to print %1 orders?';
        DeliveryDriverNo: Code[20];
        DeliveryRouteMgmt: Codeunit "Delivery Route Management";
        DeliveryRoute: Record "Delivery Route";

    local procedure SetDeliveryDate()
    begin
        FilterGroup(4);
        SetRange("Shipment Date", DeliveryDate);
        FilterGroup(0);
    end;
}

