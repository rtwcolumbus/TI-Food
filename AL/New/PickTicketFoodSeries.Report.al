report 37002081 "Pick Ticket - Food Series" // Version: FOODNA
{
    // PR3.10
    //   Add logic for alternate quantities
    // 
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Modified to display available lots satisfying specified preferences
    // 
    // PR3.70.08
    // P8000165A, Myers Nissi, Jack Reynolds, 11 FEB 05
    //   Modify to show reserved lots
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.01
    // P8000699, VerticalSoft, Jack Reynolds, 18 MAY 09
    //   Exclude reservation entries without a lot number
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 06 APR 10
    //   RTC Reporting Upgrade
    // 
    // PRW16.00.04
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // PRW16.00.06
    // P8001070, Columbus IT, Jack Reynolds, 07 JAN 13
    //   Support for Lot Freshness
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 20 FEB 13
    //   Restoring the SaveValues property in the Request Page.
    // 
    // PRW19.00.01
    // P8007485, To-Increase, Dayakar Battini, 18 JUL 16
    //   Print Comments
    // 
    // PRW110.0.01
    // P8001070, To-Increase, Jack Reynolds, 27 APR 17
    //   Redesigned to solve paging issues with the RDLC (SetData, GetData)
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    DefaultLayout = RDLC;
    RDLCLayout = './layout/PickTicketFoodSeries.rdlc';

    Caption = 'Pick Ticket - Food Series';

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = SORTING("Document Type", "No.") WHERE("Document Type" = CONST(Order));
            RequestFilterFields = "No.", "Sell-to Customer No.", "Standing Order No.", "Shipment Date", "No. Printed";
            column(CompanyInfoName; CompanyInformation.Name)
            {
            }
            column(SalesHeaderDocumentType; "Document Type")
            {
            }
            column(SalesHeaderNo; "No.")
            {
            }
            column(SalesHeaderOrderDate; "Order Date")
            {
            }
            dataitem(CopyNo; "Integer")
            {
                DataItemTableView = SORTING(Number);
                dataitem(PageLoop; "Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                    column(BillToAddress1; BillToAddress[1])
                    {
                    }
                    column(BillToAddress2; BillToAddress[2])
                    {
                    }
                    column(BillToAddress3; BillToAddress[3])
                    {
                    }
                    column(BillToAddress4; BillToAddress[4])
                    {
                    }
                    column(BillToAddress5; BillToAddress[5])
                    {
                    }
                    column(BillToAddress6; BillToAddress[6])
                    {
                    }
                    column(BillToAddress7; BillToAddress[7])
                    {
                    }
                    column(BillToAddress8; BillToAddress[8])
                    {
                    }
                    column(ShipToAddress1; ShipToAddress[1])
                    {
                    }
                    column(ShipToAddress2; ShipToAddress[2])
                    {
                    }
                    column(ShipToAddress3; ShipToAddress[3])
                    {
                    }
                    column(ShipToAddress4; ShipToAddress[4])
                    {
                    }
                    column(ShipToAddress5; ShipToAddress[5])
                    {
                    }
                    column(ShipToAddress6; ShipToAddress[6])
                    {
                    }
                    column(ShipToAddress7; ShipToAddress[7])
                    {
                    }
                    column(ShipToAddress8; ShipToAddress[8])
                    {
                    }
                    column(ShipmentMethodDescription; ShipmentMethod.Description)
                    {
                    }
                    column(SalesHeaderShipmentDate; "Sales Header"."Shipment Date")
                    {
                    }
                    column(RouteDescription; RouteDescription)
                    {
                    }
                    column(PaymentTermsDescription; PaymentTerms.Description)
                    {
                    }
                    column(SalesHeaderBillToCustomerNo; "Sales Header"."Bill-to Customer No.")
                    {
                    }
                    column(SalesHeaderExternalDocumentNo; "Sales Header"."External Document No.")
                    {
                    }
                    column(SalesPurchPersonName; SalesPurchPerson.Name)
                    {
                    }
                    column(myCopyNo; CopyNo.Number)
                    {
                    }
                    column(PageLoop_Number; Number)
                    {
                    }
                    dataitem("Sales Line"; "Sales Line")
                    {
                        DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                        DataItemLinkReference = "Sales Header";
                        DataItemTableView = SORTING("Document Type", "Document No.", "Line No.") WHERE(Type = CONST(Item), "Outstanding Quantity" = FILTER(<> 0));
                        dataitem(SalesLineComment; "Sales Comment Line")
                        {
                            DataItemLink = "No." = FIELD("Document No."), "Document Line No." = FIELD("Line No.");
                            DataItemTableView = SORTING("Document Type", "No.", "Document Line No.", "Line No.") WHERE("Document Type" = CONST(Order));

                            trigger OnAfterGetRecord()
                            begin
                                LineNo := LineNo + 1;
                                TempSalesLine.Init;
                                TempSalesLine."Document Type" := "Sales Header"."Document Type";
                                TempSalesLine."Document No." := "Sales Header"."No.";
                                TempSalesLine."Line No." := LineNo;
                                // to handle the display by SortByCategoryAndGroup
                                TempSalesLine.Type := "Sales Line".Type;
                                TempSalesLine."Item Category Code" := "Sales Line"."Item Category Code";
                                SplitComment(Comment, TempSalesLine.Description, TempSalesLine."Description 2");
                                TempSalesLine.Insert;
                            end;

                            trigger OnPreDataItem()
                            begin
                                // Following line is for W1 only and should be commented out in the NA version
                                // CurrReport.Break;
                                // Following line is for NA only and should be commented out in the W1 version
                                SETRANGE("Print On Pick Ticket",TRUE);
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            LineNo += 1;
                            TempSalesLine := "Sales Line";
                            TempSalesLine."Attached to Line No." := "Line No.";
                            TempSalesLine."Line No." := LineNo;
                            TempSalesLine.Insert;
                        end;

                        trigger OnPreDataItem()
                        begin
                            TempSalesLine.Reset;
                            TempSalesLine.DeleteAll;
                            LineNo := 0;
                        end;
                    }
                    dataitem(SalesHeaderComment; "Sales Comment Line")
                    {
                        DataItemLink = "Document Type" = FIELD("Document Type"), "No." = FIELD("No.");
                        DataItemLinkReference = "Sales Header";
                        DataItemTableView = SORTING("Document Type", "No.", "Document Line No.", "Line No.") WHERE("Document Line No." = CONST(0));

                        trigger OnAfterGetRecord()
                        begin
                            LineNo := LineNo + 1;
                            TempSalesLine.Init;
                            TempSalesLine."Document Type" := "Sales Header"."Document Type";
                            TempSalesLine."Document No." := "Sales Header"."No.";
                            TempSalesLine."Line No." := LineNo;
                            TempSalesLine.Type := 9999;  // to handle the display by SortByCategoryAndGroup
                            SplitComment(Comment, TempSalesLine.Description, TempSalesLine."Description 2");
                            TempSalesLine.Insert;
                        end;

                        trigger OnPreDataItem()
                        begin
                            // Following line is for W1 only and should be commented out in the NA version
                            // CurrReport.Break;
                            // Following line is for NA only and should be commented out in the W1 version
                            SETRANGE("Print On Pick Ticket",TRUE);
                        end;
                    }
                    dataitem(TempSalesLine; "Sales Line")
                    {
                        DataItemTableView = SORTING("Document Type", "Document No.", "Line No.");
                        UseTemporary = true;
                        column(SalesLineNo; "No.")
                        {
                        }
                        column(SalesLineQuantity; Quantity)
                        {
                        }
                        column(SalesLineUOM; "Unit of Measure")
                        {
                        }
                        column(SalesLineDescription; Description + "Description 2")
                        {
                        }
                        column(SalesLineDocumentType; "Document Type")
                        {
                        }
                        column(SalesLineDocumentNo; "Document No.")
                        {
                        }
                        column(SalesLineLineNo; "Line No.")
                        {
                        }
                        dataitem("Reservation Entry"; "Reservation Entry")
                        {
                            DataItemTableView = SORTING("Source Type", "Source ID", "Source Batch Name", "Source Ref. No.", "Lot No.", "Serial No.") WHERE("Source Type" = CONST(37));

                            trigger OnAfterGetRecord()
                            begin
                                Lot.SetRange("Lot No.", "Lot No.");
                                if not Lot.Find('-') then begin
                                    Lot.Reset;
                                    if Lot.Find('+') then;
                                    Lot.Init;
                                    Lot."Entry No." += 1;
                                    Lot."Lot No." := "Lot No.";
                                    Lot.Insert;
                                end;
                                Lot.Quantity -= Quantity;
                                Lot.Modify;
                            end;

                            trigger OnPostDataItem()
                            begin
                                Lot.Reset;
                            end;

                            trigger OnPreDataItem()
                            begin
                                Lot.Reset;
                                Lot.DeleteAll;
                                Lot."Entry No." := 0;

                                SetRange("Source Subtype", TempSalesLine."Document Type");
                                SetRange("Source ID", TempSalesLine."Document No.");
                                SetRange("Source Ref. No.", TempSalesLine."Attached to Line No.");
                                SetFilter("Lot No.", '<>%1', '');
                            end;
                        }
                        dataitem(Lot; "Reservation Entry")
                        {
                            DataItemTableView = SORTING("Entry No.", Positive);
                            UseTemporary = true;
                            column(LotLotNo; "Lot No.")
                            {
                            }
                            column(LotQuantity; Quantity)
                            {
                            }
                            column(LotAltQtys1; AltQtys[1])
                            {
                            }
                            column(LotEntryNo; "Entry No.")
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                QtyReserved += Quantity;
                            end;

                            trigger OnPreDataItem()
                            begin
                                if Lot.IsEmpty then
                                    CurrReport.Break;

                                QtyReserved := 0;

                                if Item."Catch Alternate Qtys." then
                                    InitAltQtyStrs(1)
                                else
                                    Clear(AltQtys);
                            end;
                        }
                        dataitem(AltQtyLine; "Integer")
                        {
                            DataItemTableView = SORTING(Number);
                            column(AltQtyLineNumber; Number)
                            {
                            }
                            column(AltQtyLineAltQtys1; AltQtys[1])
                            {
                            }
                            column(AltQtyLineAltQtys2; AltQtys[2])
                            {
                            }
                            column(AltQtyLineAltQtys3; AltQtys[3])
                            {
                            }
                            column(AltQtyLineAltQtys4; AltQtys[4])
                            {
                            }
                            column(AltQtyLineAltQtys5; AltQtys[5])
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                if (Number = NumAltQtyLines) then begin
                                    NumAltQtys := Round(TempSalesLine.Quantity - QtyReserved, 1, '>') mod 5;
                                    if (NumAltQtys > 0) then
                                        InitAltQtyStrs(NumAltQtys);
                                end;
                            end;

                            trigger OnPreDataItem()
                            begin
                                if (LotPrefText <> '') or (Item."Alternate Unit of Measure" = '') or (not Item."Catch Alternate Qtys.") then
                                    CurrReport.Break;

                                NumAltQtyLines := Round((TempSalesLine.Quantity - QtyReserved) / 5, 1, '>');

                                InitAltQtyStrs(5);

                                SetRange(Number, 1, NumAltQtyLines);
                            end;
                        }
                        dataitem("Lot No. Information"; "Lot No. Information")
                        {
                            DataItemTableView = SORTING("Item No.", "Variant Code", "Lot No.");
                            column(LotInfoNumber; LotInfoNumber)
                            {
                            }
                            column(LotInfoPreference; LotPrefText)
                            {
                            }
                            column(LotInfoLotNo; "Lot No.")
                            {
                            }
                            column(LotInfoMaximumAvailable; StrSubstNo(MaximumAvailable, Inventory - "Reserved Quantity"))
                            {
                            }
                            column(LotInfoAltQtys1; AltQtys[1])
                            {
                            }
                            column(LotInfoAltQtys2; AltQtys[2])
                            {
                            }
                            column(LotInfoAltQtys3; AltQtys[3])
                            {
                            }
                            column(LotInfoAltQtys4; AltQtys[4])
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                CalcFields(Inventory, "Reserved Quantity");
                                if Inventory <= "Reserved Quantity" then
                                    CurrReport.Skip;

                                if not LotFiltering.LotInFilter("Lot No. Information", LotAge, LotSpecFilterTemp,
                                  "Sales Line"."Freshness Calc. Method", "Sales Line"."Oldest Accept. Freshness Date")
                                then
                                    CurrReport.Skip;

                                LotInfoNumber += 1;
                            end;

                            trigger OnPreDataItem()
                            begin
                                if (LotPrefText = '') or (TempSalesLine.Quantity <= QtyReserved) then
                                    CurrReport.Break;

                                SetRange("Item No.", TempSalesLine."No.");
                                SetRange("Variant Code", TempSalesLine."Variant Code");
                                SetRange("Location Filter", TempSalesLine."Location Code");
                                SetFilter(Inventory, '>0');

                                if Item."Catch Alternate Qtys." then begin
                                    NumAltQtys := Round(TempSalesLine.Quantity - QtyReserved, 1, '>');
                                    if NumAltQtys < 5 then
                                        InitAltQtyStrs(5)
                                    else
                                        InitAltQtyStrs(NumAltQtys);
                                end else
                                    InitAltQtyStrs(1);

                                LotInfoNumber := 0;
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if "No." <> '' then
                                Item.Get("No.");

                            if ShowLotPreferences then begin
                                LotPrefText := '';

                                LotAgeFilter.Reset;
                                LotAge.Reset;
                                LotAgeFilter.SetRange("Table ID", DATABASE::"Sales Line");
                                LotSpecFilter.SetRange(Type, TempSalesLine."Document Type");
                                LotAgeFilter.SetRange(ID, TempSalesLine."Document No.");
                                LotAgeFilter.SetRange("Line No.", TempSalesLine."Attached to Line No.");
                                if LotAgeFilter.Find('-') then begin
                                    if LotAgeFilter."Age Filter" <> '' then begin
                                        LotAge.SetFilter(Age, LotAgeFilter."Age Filter");
                                        LotPrefText := LotPrefText + StrSubstNo(', %1: %2', LotAge.FieldCaption(Age), LotAgeFilter."Age Filter");
                                    end;
                                    if LotAgeFilter."Category Filter" <> '' then begin
                                        LotAge.SetFilter("Age Category", LotAgeFilter."Category Filter");
                                        LotPrefText := LotPrefText + StrSubstNo(', %1: %2', LotAge.FieldCaption("Age Category"), LotAgeFilter."Category Filter");
                                    end;
                                end;

                                LotSpecFilter.Reset;
                                LotSpecFilterTemp.Reset;
                                LotSpecFilterTemp.DeleteAll;
                                LotSpecFilter.SetRange("Table ID", DATABASE::"Sales Line");
                                LotSpecFilter.SetRange(Type, TempSalesLine."Document Type");
                                LotSpecFilter.SetRange(ID, TempSalesLine."Document No.");
                                LotSpecFilter.SetRange("Line No.", TempSalesLine."Attached to Line No.");
                                if LotSpecFilter.Find('-') then begin
                                    repeat
                                        LotSpecFilterTemp := LotSpecFilter;
                                        LotSpecFilterTemp.Insert;
                                    until LotSpecFilter.Next = 0;
                                    LotPrefText := LotPrefText + ', ' + LotFiltering.LotSpecText(LotSpecFilterTemp);
                                end;

                                LotPrefText := CopyStr(LotPrefText, 3);
                                if LotPrefText <> '' then begin
                                    Item.Get(TempSalesLine."No.");
                                    if (Item."Alternate Unit of Measure" <> '') and Item."Catch Alternate Qtys." then begin
                                        if TempSalesLine.Quantity > 5 then
                                            NumAltQtyLines := 5
                                        else
                                            NumAltQtyLines := Round(TempSalesLine.Quantity, 1, '>');
                                        InitAltQtyStrs(NumAltQtyLines);
                                    end;
                                end else
                                    Clear(AltQtys);
                            end;
                        end;

                        trigger OnPreDataItem()
                        begin
                            if SortByCategory then
                                SetCurrentKey("Document Type", "Document No.", Type, "Item Category Code");
                        end;
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    CurrReport.PageNo := 1;
                end;

                trigger OnPreDataItem()
                begin
                    SetRange(Number, 1, 1 + Abs(NoCopies));
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if RespCenter.Get("Responsibility Center") then
                    CompanyInformation.Name := RespCenter.Name
                else
                    CompanyInformation.Get;

                if "Salesperson Code" = '' then
                    Clear(SalesPurchPerson)
                else
                    SalesPurchPerson.Get("Salesperson Code");

                if "Payment Terms Code" = '' then
                    Clear(PaymentTerms)
                else
                    PaymentTerms.Get("Payment Terms Code");

                if "Shipment Method Code" = '' then
                    Clear(ShipmentMethod)
                else
                    ShipmentMethod.Get("Shipment Method Code");

                FormatAddress.SalesHeaderBillTo(BillToAddress, "Sales Header");
                FormatAddress.SalesHeaderShipTo(ShipToAddress, ShipToAddress, "Sales Header");

                if "Posting Date" <> 0D then
                    UseDate := "Posting Date"
                else
                    UseDate := WorkDate;

                if Customer.Get("Bill-to Customer No.") then
                    AddToAddress(BillToAddress, Customer."Phone No.");

                Clear(RouteDescription);
                if ("Delivery Route No." <> '') then
                    if Route.Get("Delivery Route No.") then
                        if ("Delivery Stop No." = '') then
                            RouteDescription := Route.Description
                        else
                            RouteDescription := StrSubstNo('%1 / %2', Route.Description, "Delivery Stop No.");
            end;

            trigger OnPreDataItem()
            begin
                if UseRouteOrder then begin
                    SetCurrentKey("Document Type", "Shipment Date", "Delivery Route No.", "Delivery Stop No.");
                    Ascending(false);
                    SetRange("Shipment Date", DeliveryDate);
                    SetFilter("Delivery Route No.", RouteFilter);
                end;
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
                    field(NoCopies; NoCopies)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Number of Copies';
                        MaxValue = 9;
                        MinValue = 0;
                    }
                    field("Sort By Category/Group"; SortByCategory)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Sort By Category';
                    }
                    field(ShowLotPreferences; ShowLotPreferences)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Show Lot Preferences';
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
        PICKTICKETCaption = 'PICK TICKET';
        OrderNumberCaption = 'Order Number:';
        OrderDateCaption = 'Order Date:';
        CopyText = 'COPY';
        PageCaption = 'Page:';
        SoldCaption = 'Sold';
        ShipCaption = 'Ship';
        ToCaption = 'To:';
        ShipViaCaption = 'Ship Via';
        ShipDateCaption = 'Ship Date';
        RouteCaption = 'Route';
        TermsCaption = 'Terms';
        CustomerNoCaption = 'Customer No.';
        PONumberCaption = 'P.O. Number';
        PODateCaption = 'P.O. Date';
        SalesPersonCaption = 'Sales Person';
        ItemNoCaption = 'Item No.';
        QuantityCaption = 'Quantity';
        XCaption = 'X';
        UnitCaption = 'Unit';
        DescriptionCaption = 'Description';
        LotsCaption = 'Lots:';
        LotPreferencesCaption = 'Lot Preferences:';
    }

    var
        ShipmentMethod: Record "Shipment Method";
        PaymentTerms: Record "Payment Terms";
        Item: Record Item;
        SalesPurchPerson: Record "Salesperson/Purchaser";
        TempLocation: Record Location temporary;
        CompanyInformation: Record "Company Information";
        Route: Record "Delivery Route";
        RespCenter: Record "Responsibility Center";
        Customer: Record Customer;
        LotAgeFilter: Record "Lot Age Filter";
        LotSpecFilter: Record "Lot Specification Filter";
        LotAge: Record "Lot Age";
        LotSpecFilterTemp: Record "Lot Specification Filter" temporary;
        FormatAddress: Codeunit "Format Address";
        LotFiltering: Codeunit "Lot Filtering";
        BillToAddress: array[8] of Text[100];
        ShipToAddress: array[8] of Text[100];
        AnySerialNos: Boolean;
        NoCopies: Integer;
        RouteDescription: Text[100];
        UseRouteOrder: Boolean;
        DeliveryDate: Date;
        RouteFilter: Code[250];
        UseDate: Date;
        LineNo: Integer;
        SortByCategory: Boolean;
        ShowLotPreferences: Boolean;
        QtyReserved: Decimal;
        AltQtys: array[99] of Text[30];
        LotPrefText: Text;
        LotInfoNumber: Integer;
        NumAltQtys: Integer;
        NumAltQtyLines: Integer;
        MaximumAvailable: Label '(max - %1)';

    local procedure AddToAddress(var Addr: array[8] of Text[100]; StrToAdd: Text[250])
    var
        AddrIndex: Integer;
    begin
        if (StrToAdd <> '') then begin
            AddrIndex := 0;
            repeat
                AddrIndex := AddrIndex + 1;
            until (AddrIndex = ArrayLen(Addr)) or (Addr[AddrIndex] = '');
            if (Addr[AddrIndex] = '') then
                Addr[AddrIndex] := StrToAdd;
        end;
    end;

    local procedure InitAltQtyStrs(NumQtys: Integer)
    var
        QtyIndex: Integer;
    begin
        Clear(AltQtys);
        for QtyIndex := 1 to NumQtys do
            AltQtys[QtyIndex] := PadStr('', MaxStrLen(AltQtys[QtyIndex]), '_');
    end;

    procedure SetRouteInfo(DeliveryDate2: Date; RouteFilter2: Code[250])
    begin
        UseRouteOrder := true;
        DeliveryDate := DeliveryDate2;
        RouteFilter := RouteFilter2;
    end;

    local procedure SplitComment(Comment: Text[80]; var Description: Text[100]; var Description2: Text[50])
    var
        Index: Integer;
    begin
        if StrLen(Comment) <= MaxStrLen(Description) then begin
            Description := Comment;
            Description2 := '';
        end else begin
            Index := MaxStrLen(Description) + 1;
            while (Index > 1) and (Comment[Index] <> ' ') do
                Index := Index - 1;
            if Index = 1 then
                Index := MaxStrLen(Description) + 1;
            Description := CopyStr(Comment, 1, Index - 1);
            Description2 := CopyStr(CopyStr(Comment, Index + 1), 1, MaxStrLen(Description2));
        end;
    end;
}

