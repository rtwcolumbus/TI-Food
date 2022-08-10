report 37002663 "Terminal Market Pick Ticket"
{
    // PRW16.00.05
    // P8000970, Columbus IT, Jack Reynolds, 07 NOV 11
    //   Pick ticket for Terminal Market Orders
    // 
    // PRW16.00.06
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    DefaultLayout = RDLC;
    RDLCLayout = './layout/TerminalMarketPickTicket.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Terminal Market Pick Ticket';
    UsageCategory = Documents;

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = SORTING("Document Type", "No.") WHERE("Document Type" = CONST(Order));
            RequestFilterFields = "No.", "Sell-to Customer No.", "Order Date";
            column(SalesHeaderDocType; "Document Type")
            {
            }
            column(SalesHeaderNo; "No.")
            {
            }
            dataitem("Sales Line"; "Sales Line")
            {
                DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                DataItemTableView = SORTING("Document Type", "Document No.", "Line No.") WHERE(Type = CONST(Item), Quantity = FILTER(> 0));
                column(SellToAddress8; SellToAddress[8])
                {
                }
                column(SellToAddress7; SellToAddress[7])
                {
                }
                column(SellToAddress6; SellToAddress[6])
                {
                }
                column(SellToAddress5; SellToAddress[5])
                {
                }
                column(SalesHeaderPickTicketCount; "Sales Header"."Pick Ticket Count")
                {
                }
                column(SellToAddress4; SellToAddress[4])
                {
                }
                column(SalesHeaderSalespersonCode; "Sales Header"."Salesperson Code")
                {
                }
                column(SellToAddress2; SellToAddress[2])
                {
                }
                column(SellToAddress3; SellToAddress[3])
                {
                }
                column(SalesHeaderSelltoCustNo; "Sales Header"."Sell-to Customer No.")
                {
                }
                column(SalesHeaderOrderDate; "Sales Header"."Order Date")
                {
                }
                column(SellToAddress1; SellToAddress[1])
                {
                }
                column(ItemSlotSlotNo; ItemSlot."Slot No.")
                {
                }
                column(SalesLineNo; "No.")
                {
                }
                column(SalesLineDesc; Description)
                {
                }
                column(SalesLineVariantCode; "Variant Code")
                {
                }
                column(SalesLineQuantity; Quantity)
                {
                }
                column(SalesLineUnitPrice; "Unit Price")
                {
                }
                column(SalesLineUOMCode; "Unit of Measure Code")
                {
                }
                column(SalesLineLineAmount; "Line Amount")
                {
                }
                column(LotData1; LotData[1])
                {
                }
                column(LotData2; LotData[2])
                {
                }
                column(LotData3; LotData[3])
                {
                }
                column(BinText; BinText)
                {
                }
                dataitem("Sales Line Repack"; "Sales Line Repack")
                {
                    DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("Document No."), "Line No." = FIELD("Line No.");
                    DataItemTableView = SORTING("Document Type", "Document No.", "Line No.");
                    column(SalesLineRepackRepackQuantity; "Sales Line Repack"."Repack Quantity")
                    {
                    }
                    column(RepackItemDesc; RepackItem.Description)
                    {
                    }
                    column(SalesLineRepackRepackItemNo; "Repack Item No.")
                    {
                    }
                    column(Repack; 1)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        RepackItem.Get("Repack Item No.");
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if not ItemSlot.Get("No.", "Location Code") then
                        Clear(ItemSlot);

                    Item.Get("No.");
                    if Item.CostInAlternateUnits then begin
                        Qty := "Quantity (Alt.)";
                        UOM := Item."Alternate Unit of Measure";
                    end else begin
                        Qty := Quantity;
                        UOM := "Unit of Measure Code";
                    end;

                    Clear(LotData);
                    case SalesSetup."Terminal Market Item Level" of
                        SalesSetup."Terminal Market Item Level"::Lot:
                            begin
                                TermMktFns.GetSalesLineLotInfo("Sales Line", LotInfo);
                                LotData[1] := StrSubstNo('%1: %2', "Sales Line".FieldCaption("Lot No."), LotInfo."Lot No.");
                                if LotInfo."Country/Region of Origin Code" <> '' then
                                    LotData[2] := StrSubstNo(Text001, LotInfo."Country/Region of Origin Code");
                                if LotInfo.Brand <> '' then
                                    LotData[3] := StrSubstNo('%1: %2', LotInfo.FieldCaption(Brand), LotInfo.Brand);
                            end;
                        SalesSetup."Terminal Market Item Level"::"Item/Variant/Country of Origin":
                            if "Country/Region of Origin Code" <> '' then
                                LotData[2] := StrSubstNo(Text001, "Country/Region of Origin Code");
                    end;
                    CompressArray(LotData);

                    BinText := '';
                    BinCount := 0;
                    if Location.Get("Location Code") then
                        if (Location.LocationType = 1) and Location."Bin Mandatory" then begin
                            SalesLine2 := "Sales Line";
                            if SalesLineRepack.Get("Document Type", "Document No.", "Line No.") then begin
                                SalesLine2."No." := SalesLineRepack."Repack Item No.";
                                SalesLine2."Variant Code" := SalesLineRepack."Variant Code";
                            end;
                            BinContent.Reset;
                            BinContent.SetCurrentKey("Location Code", "Item No.", "Variant Code", "Warehouse Class Code", Fixed, "Bin Ranking");
                            BinContent.SetRange("Location Code", SalesLine2."Location Code");
                            BinContent.SetRange("Item No.", SalesLine2."No.");
                            if SalesLine2."Variant Code" <> '' then
                                BinContent.SetRange("Variant Code", SalesLine2."Variant Code");
                            BinContent.SetRange("Unit of Measure Code", Item."Base Unit of Measure");
                            BinContent.SetFilter("Bin Type Code", BinTypeFilter);
                            if BinContent.Find('+') then
                                repeat
                                    case SalesSetup."Terminal Market Item Level" of
                                        SalesSetup."Terminal Market Item Level"::Lot:
                                            begin
                                                BinContent.SetRange("Lot No. Filter", LotInfo."Lot No.");
                                                BinContent.CalcFields("Remaining Quantity");
                                                BinOK := BinContent."Remaining Quantity" > 0;
                                            end;
                                        SalesSetup."Terminal Market Item Level"::"Item/Variant/Country of Origin":
                                            begin
                                                WarehouseEntry.SetCurrentKey("Location Code", "Bin Code", "Item No.", "Variant Code",
                                                  "Unit of Measure Code", Open, "Lot No.");
                                                WarehouseEntry.SetRange("Location Code", BinContent."Location Code");
                                                WarehouseEntry.SetRange("Bin Code", BinContent."Bin Code");
                                                WarehouseEntry.SetRange("Item No.", BinContent."Item No.");
                                                WarehouseEntry.SetRange("Variant Code", BinContent."Variant Code");
                                                WarehouseEntry.SetRange("Unit of Measure Code", BinContent."Unit of Measure Code");
                                                WarehouseEntry.SetRange(Open, true);
                                                BinOK := false;
                                                if WarehouseEntry.Find('-') then
                                                    repeat
                                                        if LotInfo.Get(WarehouseEntry."Item No.", WarehouseEntry."Variant Code", WarehouseEntry."Lot No.") then
                                                            if LotInfo."Country/Region of Origin Code" = SalesLine2."Country/Region of Origin Code" then // P8001083
                                                                BinOK := not LotStatusMgmt.ExcludeLotInfo(LotInfo, LotStatusExclusionFilter);               // P8001083
                                                        if not BinOK then begin
                                                            WarehouseEntry.SetRange("Lot No.", WarehouseEntry."Lot No.");
                                                            WarehouseEntry.Find('+');
                                                            WarehouseEntry.SetRange("Lot No.");
                                                        end;
                                                    until (WarehouseEntry.Next = 0) or BinOK;
                                            end;
                                        SalesSetup."Terminal Market Item Level"::"Item/Variant":
                                            begin
                                                BinContent.CalcFields("Remaining Quantity");
                                                LotStatusMgmt.QuantityAdjForBinContent(BinContent,           // P8001083
                                                  LotStatusExclusionFilter, BinContent."Remaining Quantity"); // P8001083
                                                BinOK := BinContent."Remaining Quantity" > 0;
                                            end;
                                    end;
                                    if BinOK then begin
                                        BinCount += 1;
                                        BinText := BinText + ', ' + BinContent."Bin Code";
                                    end;
                                until (BinContent.Next(-1) = 0) or (BinCount = 3);
                            if BinCount > 0 then
                                BinText := Text002 + CopyStr(BinText, 2);
                        end;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                FormatAddress.SalesHeaderSellTo(SellToAddress, "Sales Header");
            end;

            trigger OnPostDataItem()
            begin
                if not CurrReport.Preview then begin
                    "Pick Ticket Count" := "Pick Ticket Count" + 1;
                    Modify;
                end;
            end;

            trigger OnPreDataItem()
            begin
                BinTypeFilter := CreatePick.GetBinTypeFilter(3); // Pick bins
                if BinTypeFilter <> '' then
                    BinTypeFilter := '|' + BinTypeFilter;
                BinTypeFilter := '''''' + BinTypeFilter;
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
        CopyCaption = 'Copy';
        SalespersonCodeCaption = 'Salesperson';
        RepackInstructionsCaption = '*Repack Instructions';
        CustomerNoCaption = 'Customer No.';
        OrderDateCaption = 'Order Date';
        PickTicketCaption = 'Pick Ticket';
        OrderNoCaption = 'Order No.';
        SlotNoCaption = 'Slot';
        ItemNoCaption = 'Item No.';
        DescCaption = 'Description';
        VariantCodeCaption = 'Variant';
        QuantityCaption = 'Quantity';
        UnitPriceCaption = 'Unit Price';
        UOMCaption = 'UOM';
        AmountCaption = 'Amount';
    }

    trigger OnPreReport()
    begin
        SalesSetup.Get;
        LotStatusExclusionFilter := LotStatusMgmt.SetLotStatusExclusionFilter(LotStatus.FieldNo("Available for Sale")); // P8001083
    end;

    var
        SalesSetup: Record "Sales & Receivables Setup";
        ItemSlot: Record "Item Slot";
        Item: Record Item;
        RepackItem: Record Item;
        LotInfo: Record "Lot No. Information";
        Location: Record Location;
        BinContent: Record "Bin Content";
        WarehouseEntry: Record "Warehouse Entry";
        SalesLineRepack: Record "Sales Line Repack";
        SalesLine2: Record "Sales Line";
        FormatAddress: Codeunit "Format Address";
        TermMktFns: Codeunit "Terminal Market Selling";
        CreatePick: Codeunit "Create Pick";
        SellToAddress: array[8] of Text[100];
        Qty: Decimal;
        UOM: Code[10];
        LotData: array[3] of Text[50];
        Text001: Label 'Country of Origin: %1';
        RepackFlag: Text[1];
        BinText: Text[100];
        BinCount: Integer;
        BinOK: Boolean;
        Text002: Label 'Bins:';
        BinTypeFilter: Text[1024];
        LotStatus: Record "Lot Status Code";
        LotStatusMgmt: Codeunit "Lot Status Management";
        LotStatusExclusionFilter: Text[1024];
}

