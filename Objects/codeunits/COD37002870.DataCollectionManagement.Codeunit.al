codeunit 37002870 "Data Collection Management"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.00
    // P8001149, Columbus IT, Don Bresee, 26 APR 13
    //   Use lookup mode for Prod. Order Line Start/Stop page
    // 
    // PRW17.00.01
    // P8001160, Columbus IT, Jack Reynolds, 23 MAY 13
    //   Allow control over creating separate lines
    // 
    // PRW17.10
    // P8001238, Columbus IT, Jack Reynolds, 31 OCT 13
    //   Fix error attempting to create sheets for invoices and credit memos
    // 
    // PRW17.10.02
    // P8001285, Columbus IT, Jack Reynolds, 11 FEB 14
    //   Fix problem creating data sheets for documents with no item lines
    // 
    // PRW17.10.03
    // P8001331, Columbus IT, Jack Reynolds, 24 JUN 14
    //   Fix problem creating (updating) data sheets when posting
    // 
    // PRW111.00.01
    // P80037645, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Add UOM/Measuring Method
    // 
    // PRW111.00.02
    // P80076240, To-Increase, Gangabhushan, 13 JUN 19
    //   CS00062180 - Data Collection Lines Measuring Method is not populated
    // 
    // PRW111.00.03
    // P80079674, To-Increase, Gangabhushan, 05 AUG 19
    //   CS00071461 - When users rename an item, the item quality tests/data collection lines are orphaned
    // 
    // P80079674, To-Increase, Gangabhushan, 19 AUG 19
    //   CS00071461 - Event Subscriber(OnAfterRenameAsset) created for Asset
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    //
    // PRW115.00.03
    // P800127129, To-Increase, Gangabhushan, 15 JUL 21
    //   CS00176500 | Data Collection sheets duplicate  
    // 
    // PRW118.1
    // P800130766, To-Increase, Jack Reynolds, 28 SEP 21
    //   Don't allow status change if already Complete  

    Permissions = TableData "Data Collection Line" = r,
                  TableData "Data Collection Template" = r,
                  TableData "Data Collection Template Line" = r,
                  TableData "Data Collection Alert Group" = r,
                  TableData "Data Coll. Alert Group Member" = r,
                  TableData "Data Collection Log Group" = r,
                  TableData "Data Sheet Header" = rimd,
                  TableData "Data Sheet Line" = rimd,
                  TableData "Data Sheet Line Detail" = rimd,
                  TableData "Data Collection Alert" = rimd,
                  TableData "My Alert" = rimd;

    trigger OnRun()
    begin
    end;

    var
        Text001: Label 'You cannot copy the %1 to itself.';
        Text002: Label 'There is nothing to create.';
        Text003: Label 'Line %1 - %2';
        Text004: Label 'Result for ''%1'' not yet recorded.';
        Text005: Label 'Result for ''%1'' is after stop date and time.';
        Text006: Label 'Production order line %1 has not been completed.';
        Text007: Label 'Shipment has not been posted.';
        Text008: Label 'Receipt has not been posted.';
        Text009: Label 'Production order has not been finished.';
        Text010: Label 'Data sheets exist.';
        Text011: Label 'Open alerts exist for data sheet.';
        ErrStatusComplete: Label '%1 cannot be changed for data sheets that are already %2.';

    procedure DataElementLookup(DataElementCode: Code[20]; var Text: Text[1024]): Boolean
    var
        DataCollectionLookup: Record "Data Collection Lookup";
        DataCollectionLookups: Page "Data Collection Lookups";
    begin
        DataCollectionLookup.FilterGroup(2);
        DataCollectionLookup.SetRange("Data Element Code", DataElementCode);
        DataCollectionLookup.FilterGroup(0);
        DataCollectionLookups.SetTableView(DataCollectionLookup);
        if DataCollectionLookup.Get(DataElementCode, Text) then
            DataCollectionLookups.SetRecord(DataCollectionLookup);
        DataCollectionLookups.LookupMode(true);
        if DataCollectionLookups.RunModal = ACTION::LookupOK then begin
            DataCollectionLookups.GetRecord(DataCollectionLookup);
            Text := DataCollectionLookup.Code;
            exit(true);
        end else
            exit(false);
    end;

    procedure SourceDescription(SourceID: Integer; SourceKey1: Code[20]; SourceKey2: Code[20]; var SourceType: Text[50]; var SourceDesc1: Text[100]; var SourceDesc2: Text[100])
    var
        Location: Record Location;
        Zone: Record Zone;
        Bin: Record Bin;
        Customer: Record Customer;
        Vendor: Record Vendor;
        Item: Record Item;
        Resource: Record Resource;
        WorkCenter: Record "Work Center";
        MachineCenter: Record "Machine Center";
        Asset: Record Asset;
    begin
        SourceDesc2 := '';
        case SourceID of
            DATABASE::Location, DATABASE::Zone, DATABASE::Bin:
                begin
                    Location.Get(SourceKey1);
                    SourceDesc1 := Location.Name;
                    case SourceID of
                        DATABASE::Location:
                            SourceType := Location.TableName;
                        DATABASE::Zone:
                            begin
                                SourceType := Zone.TableName;
                                Zone.Get(SourceKey1, SourceKey2);
                                SourceDesc2 := Zone.Description;
                            end;
                        DATABASE::Bin:
                            begin
                                SourceType := Bin.TableName;
                                Bin.Get(SourceKey1, SourceKey2);
                                SourceDesc2 := Bin.Description;
                            end;
                    end;
                end;
            DATABASE::Customer:
                begin
                    SourceType := Customer.TableName;
                    Customer.Get(SourceKey1);
                    SourceDesc1 := Customer.Name;
                end;
            DATABASE::Vendor:
                begin
                    SourceType := Vendor.TableName;
                    Vendor.Get(SourceKey1);
                    SourceDesc1 := Vendor.Name;
                end;
            DATABASE::Item:
                begin
                    SourceType := Item.TableName;
                    Item.Get(SourceKey1);
                    SourceDesc1 := Item.Description;
                end;
            DATABASE::Resource:
                begin
                    SourceType := Resource.TableName;
                    Resource.Get(SourceKey1);
                    SourceDesc1 := Resource.Name;
                end;
            DATABASE::"Work Center":
                begin
                    SourceType := WorkCenter.TableName;
                    WorkCenter.Get(SourceKey1);
                    SourceDesc1 := WorkCenter.Name;
                end;
            DATABASE::"Machine Center":
                begin
                    SourceType := MachineCenter.TableName;
                    MachineCenter.Get(SourceKey1);
                    SourceDesc1 := MachineCenter.Name;
                end;
            DATABASE::Asset:
                begin
                    SourceType := Asset.TableName;
                    Asset.Get(SourceKey1);
                    SourceDesc1 := Asset.Description;
                end;
        end;
    end;

    procedure FormatTargetValue(DataElementType: Option Boolean,Date,Lookup,Numeric,Text; BooleanTarget: Option " ",No,Yes; LookupTarget: Code[10]; TextTarget: Code[50]; NumericTarget: Decimal): Text[50]
    begin
        case DataElementType of
            DataElementType::Boolean:
                exit(Format(BooleanTarget));
            DataElementType::Lookup:
                exit(LookupTarget);
            DataElementType::Text:
                exit(TextTarget);
            DataElementType::Numeric:
                exit(Format(NumericTarget));
        end;
    end;

    procedure DeleteDataCollectionLines(SourceID: Integer; SourceKey1: Code[20]; SourceKey2: Code[20])
    var
        DataCollectionLine: Record "Data Collection Line";
    begin
        DataCollectionLine.SetRange("Source ID", SourceID);
        DataCollectionLine.SetRange("Source Key 1", SourceKey1);
        DataCollectionLine.SetRange("Source Key 2", SourceKey2);
        DataCollectionLine.DeleteAll(true);
    end;

    procedure CopyTemplateToLines(DataCollectionTemplate: Record "Data Collection Template"; SourceID: Integer; SourceKey1: Code[20]; SourceKey2: Code[20])
    var
        DataCollectionTemplateLine: Record "Data Collection Template Line";
        DataCollectionLine: Record "Data Collection Line";
        DataElement: Record "Data Collection Data Element";
    begin
        DataCollectionLine.SetRange("Source ID", SourceID);
        DataCollectionLine.SetRange("Source Key 1", SourceKey1);
        DataCollectionLine.SetRange("Source Key 2", SourceKey2);
        DataCollectionLine.SetRange(Type, DataCollectionTemplate.Type);

        DataCollectionTemplateLine.SetRange("Template Code", DataCollectionTemplate.Code);
        if DataCollectionTemplateLine.FindSet then
            repeat
                DataCollectionLine.SetRange("Variant Type", DataCollectionTemplateLine."Variant Type");
                DataCollectionLine.SetRange("Data Element Code", DataCollectionTemplateLine."Data Element Code");
                DataCollectionLine.SetRange("Source Template Code", DataCollectionTemplate.Code);
                if DataCollectionLine.IsEmpty then begin
                    DataCollectionLine.TransferFields(DataCollectionTemplateLine, false);
                    DataCollectionLine."Source ID" := SourceID;
                    DataCollectionLine."Source Key 1" := SourceKey1;
                    DataCollectionLine."Source Key 2" := SourceKey2;
                    DataCollectionLine.Type := DataCollectionTemplate.Type;
                    DataCollectionLine."Variant Type" := DataCollectionTemplateLine."Variant Type";
                    DataCollectionLine."Data Element Code" := DataCollectionTemplateLine."Data Element Code";
                    DataCollectionLine."Source Template Code" := DataCollectionTemplate.Code;
                    // P80076240
                    DataElement.Get(DataCollectionTemplateLine."Data Element Code");
                    DataCollectionLine."Measuring Method" := DataElement."Measuring Method";
                    // P80076240
                    CopySampleFields(DataCollectionTemplateLine, DataCollectionLine); // P800122712
                    DataCollectionLine.SetLineNo;
                    DataCollectionLine.Insert;
                    DataCollectionLine.CopyTemplateLineComments(DataCollectionTemplateLine);
                    DataCollectionLine.CopyTemplateLineLinks(DataCollectionTemplateLine);
                end;
            until DataCollectionTemplateLine.Next = 0;
    end;

    procedure CopyLinesToLines(TargetID: Integer; TargetKey1: Code[20]; TargetKey2: Code[20]; SourceKey1: Code[20]; SourceKey2: Code[20]; Quality: Boolean; Shipping: Boolean; Receiving: Boolean; Production: Boolean; Log: Boolean)
    var
        DataCollectionLineSource: Record "Data Collection Line";
        DataCollectionLineTarget: Record "Data Collection Line";
        Type: array[5] of Boolean;
        Cnt: Integer;
    begin
        Type[1] := Quality;
        Type[2] := Shipping;
        Type[3] := Receiving;
        Type[4] := Production;
        Type[5] := Log;

        DataCollectionLineSource.SetRange("Source ID", TargetID);
        DataCollectionLineSource.SetRange("Source Key 1", SourceKey1);
        DataCollectionLineSource.SetRange("Source Key 2", SourceKey2);
        DataCollectionLineSource.SetRange(Active, true);

        for Cnt := 1 to 5 do
            if Type[Cnt] then begin
                DataCollectionLineSource.SetRange(Type, Cnt);
                DataCollectionLineTarget.Type := Cnt;
                if DataCollectionLineSource.FindSet then
                    repeat
                        DataCollectionLineTarget := DataCollectionLineSource;
                        DataCollectionLineTarget."Source ID" := TargetID;
                        DataCollectionLineTarget."Source Key 1" := TargetKey1;
                        DataCollectionLineTarget."Source Key 2" := TargetKey2;
                        DataCollectionLineTarget.SetLineNo;
                        DataCollectionLineTarget.Insert;
                        DataCollectionLineTarget.CopyLineComments(DataCollectionLineSource);
                        DataCollectionLineTarget.CopyLineLinks(DataCollectionLineSource);
                    until DataCollectionLineSource.Next = 0;
            end;
    end;

    procedure DeleteDataSheet(ID: Integer; Subtype: Integer; No: Code[20])
    var
        DataSheet: Record "Data Sheet Header";
    begin
        DataSheet.SetRange("Source ID", ID);
        DataSheet.SetRange("Source Subtype", Subtype);
        DataSheet.SetRange("Source No.", No);
        DataSheet.SetRange(Status, DataSheet.Status::Pending);
        DataSheet.SetRange("Document No.", '');
        DataSheet.DeleteAll(true);
    end;

    procedure DataSheetsForSalesHeader(SalesHeader: Record "Sales Header")
    var
        DataSheetHeader: Record "Data Sheet Header";
        DataSheets: Page "Data Sheets";
    begin
        DataSheetHeader.FilterGroup(9);
        DataSheetHeader.SetRange("Source ID", DATABASE::"Sales Header");
        DataSheetHeader.SetRange("Source Subtype", SalesHeader."Document Type");
        DataSheetHeader.SetRange("Source No.", SalesHeader."No.");
        DataSheetHeader.FilterGroup(0);
        DataSheets.SetTableView(DataSheetHeader);
        DataSheets.Run;
    end;

    procedure DataSheetsForSalesShipment(SalesShipment: Record "Sales Shipment Header")
    var
        DataSheetHeader: Record "Data Sheet Header";
        DataSheets: Page "Data Sheets";
    begin
        DataSheetHeader.FilterGroup(9);
        DataSheetHeader.SetCurrentKey("Document Type", "Document No.");
        DataSheetHeader.SetRange("Document Type", DATABASE::"Sales Shipment Header");
        DataSheetHeader.SetRange("Document No.", SalesShipment."No.");
        DataSheetHeader.FilterGroup(0);
        DataSheets.SetTableView(DataSheetHeader);
        DataSheets.Run;
    end;

    procedure DataSheetsForReturnReceipt(ReturnReceipt: Record "Return Receipt Header")
    var
        DataSheetHeader: Record "Data Sheet Header";
        DataSheets: Page "Data Sheets";
    begin
        DataSheetHeader.FilterGroup(9);
        DataSheetHeader.SetCurrentKey("Document Type", "Document No.");
        DataSheetHeader.SetRange("Document Type", DATABASE::"Return Receipt Header");
        DataSheetHeader.SetRange("Document No.", ReturnReceipt."No.");
        DataSheetHeader.FilterGroup(0);
        DataSheets.SetTableView(DataSheetHeader);
        DataSheets.Run;
    end;

    procedure DataSheetsForPurchHeader(PurchHeader: Record "Purchase Header")
    var
        DataSheetHeader: Record "Data Sheet Header";
        DataSheets: Page "Data Sheets";
    begin
        DataSheetHeader.FilterGroup(9);
        DataSheetHeader.SetRange("Source ID", DATABASE::"Purchase Header");
        DataSheetHeader.SetRange("Source Subtype", PurchHeader."Document Type");
        DataSheetHeader.SetRange("Source No.", PurchHeader."No.");
        DataSheetHeader.FilterGroup(0);
        DataSheets.SetTableView(DataSheetHeader);
        DataSheets.Run;
    end;

    procedure DataSheetsForPurchReceipt(PurchReceipt: Record "Purch. Rcpt. Header")
    var
        DataSheetHeader: Record "Data Sheet Header";
        DataSheets: Page "Data Sheets";
    begin
        DataSheetHeader.FilterGroup(9);
        DataSheetHeader.SetCurrentKey("Document Type", "Document No.");
        DataSheetHeader.SetRange("Document Type", DATABASE::"Purch. Rcpt. Header");
        DataSheetHeader.SetRange("Document No.", PurchReceipt."No.");
        DataSheetHeader.FilterGroup(0);
        DataSheets.SetTableView(DataSheetHeader);
        DataSheets.Run;
    end;

    procedure DataSheetsForReturnShipment(ReturnShipment: Record "Return Shipment Header")
    var
        DataSheetHeader: Record "Data Sheet Header";
        DataSheets: Page "Data Sheets";
    begin
        DataSheetHeader.FilterGroup(9);
        DataSheetHeader.SetCurrentKey("Document Type", "Document No.");
        DataSheetHeader.SetRange("Document Type", DATABASE::"Return Shipment Header");
        DataSheetHeader.SetRange("Document No.", ReturnShipment."No.");
        DataSheetHeader.FilterGroup(0);
        DataSheets.SetTableView(DataSheetHeader);
        DataSheets.Run;
    end;

    procedure DataSheetsForTransHeader(TransHeader: Record "Transfer Header")
    var
        DataSheetHeader: Record "Data Sheet Header";
        DataSheets: Page "Data Sheets";
    begin
        DataSheetHeader.FilterGroup(9);
        DataSheetHeader.SetRange("Source ID", DATABASE::"Transfer Header");
        DataSheetHeader.SetRange("Source No.", TransHeader."No.");
        DataSheetHeader.FilterGroup(0);
        DataSheets.SetTableView(DataSheetHeader);
        DataSheets.Run;
    end;

    procedure DataSheetsForTransShipment(TransShipment: Record "Transfer Shipment Header")
    var
        DataSheetHeader: Record "Data Sheet Header";
        DataSheets: Page "Data Sheets";
    begin
        DataSheetHeader.FilterGroup(9);
        DataSheetHeader.SetCurrentKey("Document Type", "Document No.");
        DataSheetHeader.SetRange("Document Type", DATABASE::"Transfer Shipment Header");
        DataSheetHeader.SetRange("Document No.", TransShipment."No.");
        DataSheetHeader.FilterGroup(0);
        DataSheets.SetTableView(DataSheetHeader);
        DataSheets.Run;
    end;

    procedure DataSheetsForTransReceipt(TransReceipt: Record "Transfer Receipt Header")
    var
        DataSheetHeader: Record "Data Sheet Header";
        DataSheets: Page "Data Sheets";
    begin
        DataSheetHeader.FilterGroup(9);
        DataSheetHeader.SetCurrentKey("Document Type", "Document No.");
        DataSheetHeader.SetRange("Document Type", DATABASE::"Transfer Receipt Header");
        DataSheetHeader.SetRange("Document No.", TransReceipt."No.");
        DataSheetHeader.FilterGroup(0);
        DataSheets.SetTableView(DataSheetHeader);
        DataSheets.Run;
    end;

    procedure DataSheetsForProdOrder(ProdOrder: Record "Production Order")
    var
        DataSheetHeader: Record "Data Sheet Header";
        DataSheets: Page "Data Sheets";
    begin
        DataSheetHeader.FilterGroup(9);
        case ProdOrder.Status of
            ProdOrder.Status::Released:
                begin
                    DataSheetHeader.SetRange("Source ID", DATABASE::"Production Order");
                    DataSheetHeader.SetRange("Source Subtype", ProdOrder.Status);
                    DataSheetHeader.SetRange("Source No.", ProdOrder."No.");
                end;
            ProdOrder.Status::Finished:
                begin
                    DataSheetHeader.SetCurrentKey("Document Type", "Document No.");
                    DataSheetHeader.SetRange("Document Type", DATABASE::"Production Order");
                    DataSheetHeader.SetRange("Document No.", ProdOrder."No.");
                end;
        end;
        DataSheetHeader.FilterGroup(0);
        DataSheets.SetTableView(DataSheetHeader);
        DataSheets.Run;
    end;

    procedure DataSheetsForLogGroup(LogGroup: Record "Data Collection Log Group")
    var
        DataSheetHeader: Record "Data Sheet Header";
        DataSheets: Page "Data Sheets";
    begin
        DataSheetHeader.FilterGroup(9);
        DataSheetHeader.SetRange("Source ID", 0);
        DataSheetHeader.SetRange("Source Subtype", 0);
        DataSheetHeader.SetRange("Source No.", LogGroup.Code);
        DataSheetHeader.FilterGroup(0);
        DataSheetHeader.SetFilter(Status, '%1|%2', DataSheetHeader.Status::Pending, DataSheetHeader.Status::"In Progress");
        DataSheets.SetTableView(DataSheetHeader);
        DataSheets.Run;
    end;

    procedure CreateSheetForSalesHeader(SalesHeader: Record "Sales Header"; Posting: Boolean)
    var
        Location: Record Location;
        Item: Record Item;
        Resource: Record Resource;
        SalesLine: Record "Sales Line";
        ShipmentHeader: Record "Sales Shipment Header";
        ShipmentLine: Record "Sales Shipment Line";
        ReceiptHeader: Record "Return Receipt Header";
        ReceiptLine: Record "Return Receipt Line";
        DataCollectionLine: Record "Data Collection Line";
        DataSheetHeader: Record "Data Sheet Header";
        DataSheetLineDetail: Record "Data Sheet Line Detail";
        TempLocation: Record "Data Collection Entity" temporary;
        TempOrderLine: Record "Data Collection Entity" temporary;
        TempEntity: Record "Data Collection Entity" temporary;
        CreateDataSheets: Page "Create Data Sheets";
        SourceDescription: Text[100];
        SourceID: Integer;
        SheetType: Integer;
        DataCollectionForCustomer: Boolean;
        CreateSheets: Boolean;
        DocumentType: Integer;
        DocumentNo: Code[20];
        DocumentDate: Date;
    begin
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order:
                SheetType := DataCollectionLine.Type::Shipping;
            SalesHeader."Document Type"::"Return Order":
                SheetType := DataCollectionLine.Type::Receiving;
            else    // P8001238
                exit; // P8001238
        end;

        DataCollectionForCustomer := DataCollectionLinesExist(DATABASE::Customer,
          SalesHeader."Sell-to Customer No.", '', SheetType);

        SalesLine.SetCurrentKey(Type, "No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter(Type, '%1|%2', SalesLine.Type::Item, SalesLine.Type::Resource);
        SalesLine.SetFilter("No.", '<>%1', '');
        // P800127129
        IF SalesHeader."Document Type" = SalesHeader."Document Type"::Order THEN
            SalesLine.SETFILTER("Qty. to Ship", '>%1', 0)
        else
            SalesLine.SETFILTER("Return Qty. to Receive", '>%1', 0);
        // P800127129
        if SalesLine.FindSet then
            repeat
                if not TempLocation.Get(SalesLine."Location Code") then begin
                    TempLocation.Init;
                    TempLocation."Location Code" := SalesLine."Location Code";
                    if Location.Get(TempLocation."Location Code") then
                        TempLocation.Description := Location.Name;
                    DataSheetHeader.SetCurrentKey("Location Code", "Source ID", "Source Subtype", "Source No.");
                    DataSheetHeader.SetRange("Location Code", TempLocation."Location Code");
                    DataSheetHeader.SetRange(Type, SheetType);
                    DataSheetHeader.SetRange("Source ID", DATABASE::"Sales Header");
                    DataSheetHeader.SetRange("Source Subtype", SalesHeader."Document Type");
                    DataSheetHeader.SetRange("Source No.", SalesHeader."No.");
                    DataSheetHeader.SetFilter(Status, '%1|%2', DataSheetHeader.Status::Pending, DataSheetHeader.Status::"In Progress");
                    DataSheetHeader.SetRange("Document No.", '');
                    if DataSheetHeader.FindFirst then begin
                        TempLocation.Include := true;
                        TempLocation."Data Sheet No." := DataSheetHeader."No.";
                    end;
                    if DataCollectionLinesExist(DATABASE::Location, TempLocation."Location Code", '', SheetType) then begin
                        TempLocation.Include := true;
                        TempEntity."Location Code" := TempLocation."Location Code";
                        TempEntity."Source ID" := DATABASE::Location;
                        TempEntity."Source Key 1" := TempLocation."Location Code";
                        TempEntity.Description := TempLocation.Description;
                        TempEntity.Include := true;
                        TempEntity.Insert;
                    end;
                    if DataCollectionForCustomer then begin
                        TempLocation.Include := true;
                        TempEntity."Location Code" := TempLocation."Location Code";
                        TempEntity."Source ID" := DATABASE::Customer;
                        TempEntity."Source Key 1" := SalesHeader."Sell-to Customer No.";
                        TempEntity.Description := SalesHeader."Sell-to Customer Name";
                        TempEntity.Include := true;
                        TempEntity.Insert;
                    end;
                    TempLocation.Insert;
                    TempOrderLine."Location Code" := TempLocation."Location Code";
                    TempOrderLine."Prod. Order Line No." := 0;
                    TempOrderLine.Include := true;
                    TempOrderLine.Insert;
                end;

                TempEntity."Location Code" := TempLocation."Location Code";
                case SalesLine.Type of
                    SalesLine.Type::Item:
                        begin
                            SourceID := DATABASE::Item;
                            Item.Get(SalesLine."No.");
                            SourceDescription := Item.Description;
                        end;
                    SalesLine.Type::Resource:
                        begin
                            SourceID := DATABASE::Resource;
                            Resource.Get(SalesLine."No.");
                            SourceDescription := Resource.Name;
                        end;
                end;
                if DataCollectionLinesExist(SourceID, SalesLine."No.", '', SheetType) then begin
                    if not TempEntity.Get(TempLocation."Location Code", 0, SourceID, SalesLine."No.") then begin
                        TempEntity.Init;
                        TempEntity."Source ID" := SourceID;
                        TempEntity."Source Key 1" := SalesLine."No.";
                        TempEntity.Description := SourceDescription;
                        TempEntity.Insert;
                    end;
                    if TempLocation."Data Sheet No." = '' then
                        TempEntity.Include := TempEntity.Include or (SalesLine."Outstanding Quantity" > 0)
                    else begin
                        DataSheetLineDetail.SetCurrentKey("Data Sheet No.", "Source ID", "Source Key 1", "Source Key 2");
                        DataSheetLineDetail.SetRange("Data Sheet No.", TempLocation."Data Sheet No.");
                        DataSheetLineDetail.SetRange("Source ID", SourceID);
                        DataSheetLineDetail.SetRange("Source Key 1", SalesLine."No.");
                        TempEntity.Include := not DataSheetLineDetail.IsEmpty;
                    end;
                    TempEntity.Modify;
                    if not TempLocation.Include then begin
                        TempLocation.Include := true;
                        TempLocation.Modify;
                    end;
                end;
            until SalesLine.Next = 0;

        TempLocation.Reset;
        TempOrderLine.Reset;
        TempEntity.Reset;

        if (not Posting) and TempLocation.IsEmpty then begin
            Message(Text002);
            exit;
        end;

        if Posting then begin
            case SalesHeader."Document Type" of
                SalesHeader."Document Type"::Order:
                    begin
                        DocumentType := DATABASE::"Sales Shipment Header";
                        DocumentNo := SalesHeader."Last Shipping No."; // P80066030
                        ShipmentHeader.Get(DocumentNo);
                        DocumentDate := ShipmentHeader."Document Date";
                        ShipmentLine.SetRange("Document No.", DocumentNo);
                        ShipmentLine.SetFilter(Quantity, '>0');
                        TempEntity.SetFilter("Source ID", '%1|%2', DATABASE::Item, DATABASE::Resource);
                        if TempEntity.Find('-') then
                            repeat
                                case TempEntity."Source ID" of
                                    DATABASE::Item:
                                        ShipmentLine.SetRange(Type, ShipmentLine.Type::Item);
                                    DATABASE::Resource:
                                        ShipmentLine.SetRange(Type, ShipmentLine.Type::Resource);
                                end;
                                ShipmentLine.SetRange("No.", TempEntity."Source Key 1");
                                ShipmentLine.SetRange("Location Code", TempEntity."Location Code");
                                TempEntity.Include := not ShipmentLine.IsEmpty;
                                TempEntity.Modify;
                            until TempEntity.Next = 0;
                    end;
                SalesHeader."Document Type"::"Return Order":
                    begin
                        DocumentType := DATABASE::"Return Receipt Header";
                        DocumentNo := SalesHeader."Last Return Receipt No."; // P80066030
                        ReceiptHeader.Get(DocumentNo);
                        DocumentDate := ReceiptHeader."Document Date";
                        ReceiptLine.SetRange("Document No.", DocumentNo);
                        ReceiptLine.SetFilter(Quantity, '>0');
                        TempEntity.SetFilter("Source ID", '%1|%2', DATABASE::Item, DATABASE::Resource);
                        if TempEntity.Find('-') then
                            repeat
                                case TempEntity."Source ID" of
                                    DATABASE::Item:
                                        ReceiptLine.SetRange(Type, ReceiptLine.Type::Item);
                                    DATABASE::Resource:
                                        ReceiptLine.SetRange(Type, ReceiptLine.Type::Resource);
                                end;
                                ReceiptLine.SetRange("No.", TempEntity."Source Key 1");
                                ReceiptLine.SetRange("Location Code", TempEntity."Location Code");
                                TempEntity.Include := not ReceiptLine.IsEmpty;
                                TempEntity.Modify;
                            until TempEntity.Next = 0;
                    end;
            end;

            TempEntity.Reset;
            TempEntity.SetRange(Include, true);
            if not TempLocation.Find('-') then // P8001285, P8001331
                exit;                            // P8001285
            repeat
                TempEntity.SetRange("Location Code", TempLocation."Location Code");
                TempLocation.Include := not TempEntity.IsEmpty;
                TempLocation.Modify;
            until TempLocation.Next = 0;

            CreateSheets := true;
        end else begin
            CreateDataSheets.SetData(SheetType, TempLocation, TempEntity);
            CreateSheets := CreateDataSheets.RunModal = ACTION::OK;
            if CreateSheets then
                CreateDataSheets.GetData(TempLocation, TempEntity);
        end;

        if CreateSheets then begin
            TempLocation.Reset;
            TempOrderLine.Reset;
            TempEntity.Reset;

            Clear(DataSheetHeader);
            DataSheetHeader.Init;
            DataSheetHeader."Source ID" := DATABASE::"Sales Header";
            DataSheetHeader."Source Subtype" := SalesHeader."Document Type";
            DataSheetHeader."Source No." := SalesHeader."No.";
            DataSheetHeader."Reference Type" := DataSheetHeader."Reference Type"::Customer;
            DataSheetHeader."Reference ID" := SalesHeader."Sell-to Customer No.";
            DataSheetHeader."Document Type" := DocumentType;
            DataSheetHeader."Document No." := DocumentNo;
            DataSheetHeader."Document Date" := DocumentDate;
            CreateSheetLines(DataSheetHeader, TempLocation, TempOrderLine, TempEntity);
        end;
    end;

    procedure CreateSheetForPurchHeader(PurchHeader: Record "Purchase Header"; Posting: Boolean)
    var
        Location: Record Location;
        Item: Record Item;
        PurchLine: Record "Purchase Line";
        ReceiptHeader: Record "Purch. Rcpt. Header";
        ReceiptLine: Record "Purch. Rcpt. Line";
        ShipmentHeader: Record "Return Shipment Header";
        ShipmentLine: Record "Return Shipment Line";
        DataCollectionLine: Record "Data Collection Line";
        DataSheetHeader: Record "Data Sheet Header";
        DataSheetLineDetail: Record "Data Sheet Line Detail";
        TempLocation: Record "Data Collection Entity" temporary;
        TempOrderLine: Record "Data Collection Entity" temporary;
        TempEntity: Record "Data Collection Entity" temporary;
        CreateDataSheets: Page "Create Data Sheets";
        SheetType: Integer;
        DataCollectionForVendor: Boolean;
        CreateSheets: Boolean;
        DocumentType: Integer;
        DocumentNo: Code[20];
        DocumentDate: Date;
    begin
        case PurchHeader."Document Type" of
            PurchHeader."Document Type"::Order:
                SheetType := DataCollectionLine.Type::Receiving;
            PurchHeader."Document Type"::"Return Order":
                SheetType := DataCollectionLine.Type::Shipping;
            else    // P8001238
                exit; // P8001238
        end;

        DataCollectionForVendor := DataCollectionLinesExist(DATABASE::Vendor,
          PurchHeader."Buy-from Vendor No.", '', SheetType);

        PurchLine.SetCurrentKey(Type, "No.");
        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchHeader."No.");
        PurchLine.SetRange(Type, PurchLine.Type::Item);
        PurchLine.SetFilter("No.", '<>%1', '');
        // P800127129
        IF PurchHeader."Document Type" = PurchHeader."Document Type"::Order THEN
            PurchLine.SETFILTER("Qty. to Receive", '>%1', 0)
        Else
            PurchLine.SETFILTER("Return Qty. to Ship", '>%1', 0);
        // P800127129
        if PurchLine.FindSet then
            repeat
                if not TempLocation.Get(PurchLine."Location Code") then begin
                    TempLocation.Init;
                    TempLocation."Location Code" := PurchLine."Location Code";
                    if Location.Get(TempLocation."Location Code") then
                        TempLocation.Description := Location.Name;
                    DataSheetHeader.SetCurrentKey("Location Code", "Source ID", "Source Subtype", "Source No.");
                    DataSheetHeader.SetRange("Location Code", TempLocation."Location Code");
                    DataSheetHeader.SetRange(Type, SheetType);
                    DataSheetHeader.SetRange("Source ID", DATABASE::"Purchase Header");
                    DataSheetHeader.SetRange("Source Subtype", PurchHeader."Document Type");
                    DataSheetHeader.SetRange("Source No.", PurchHeader."No.");
                    DataSheetHeader.SetFilter(Status, '%1|%2', DataSheetHeader.Status::Pending, DataSheetHeader.Status::"In Progress");
                    DataSheetHeader.SetRange("Document No.", '');
                    if DataSheetHeader.FindFirst then begin
                        TempLocation.Include := true;
                        TempLocation."Data Sheet No." := DataSheetHeader."No.";
                    end;
                    if DataCollectionLinesExist(DATABASE::Location, TempLocation."Location Code", '', SheetType) then begin
                        TempLocation.Include := true;
                        TempEntity."Location Code" := TempLocation."Location Code";
                        TempEntity."Source ID" := DATABASE::Location;
                        TempEntity."Source Key 1" := TempLocation."Location Code";
                        TempEntity.Description := TempLocation.Description;
                        TempEntity.Include := true;
                        TempEntity.Insert;
                    end;
                    if DataCollectionForVendor then begin
                        TempLocation.Include := true;
                        TempEntity."Location Code" := TempLocation."Location Code";
                        TempEntity."Source ID" := DATABASE::Vendor;
                        TempEntity."Source Key 1" := PurchHeader."Buy-from Vendor No.";
                        TempEntity.Description := PurchHeader."Buy-from Vendor Name";
                        TempEntity.Include := true;
                        TempEntity.Insert;
                    end;
                    TempLocation.Insert;
                    TempOrderLine."Location Code" := TempLocation."Location Code";
                    TempOrderLine."Prod. Order Line No." := 0;
                    TempOrderLine.Include := true;
                    TempOrderLine.Insert;
                end;

                TempEntity."Location Code" := TempLocation."Location Code";
                Item.Get(PurchLine."No.");
                if DataCollectionLinesExist(DATABASE::Item, PurchLine."No.", '', SheetType) then begin
                    if not TempEntity.Get(TempLocation."Location Code", 0, DATABASE::Item, PurchLine."No.") then begin
                        TempEntity.Init;
                        TempEntity."Source ID" := DATABASE::Item;
                        TempEntity."Source Key 1" := PurchLine."No.";
                        TempEntity.Description := Item.Description;
                        TempEntity.Insert;
                    end;
                    if TempLocation."Data Sheet No." = '' then
                        TempEntity.Include := TempEntity.Include or (PurchLine."Outstanding Quantity" > 0)
                    else begin
                        DataSheetLineDetail.SetCurrentKey("Data Sheet No.", "Source ID", "Source Key 1", "Source Key 2");
                        DataSheetLineDetail.SetRange("Data Sheet No.", TempLocation."Data Sheet No.");
                        DataSheetLineDetail.SetRange("Source ID", DATABASE::Item);
                        DataSheetLineDetail.SetRange("Source Key 1", PurchLine."No.");
                        TempEntity.Include := not DataSheetLineDetail.IsEmpty;
                    end;
                    TempEntity.Modify;
                    if not TempLocation.Include then begin
                        TempLocation.Include := true;
                        TempLocation.Modify;
                    end;
                end;
            until PurchLine.Next = 0;

        TempLocation.Reset;
        TempOrderLine.Reset;
        TempEntity.Reset;

        if (not Posting) and TempLocation.IsEmpty then begin
            Message(Text002);
            exit;
        end;

        if Posting then begin
            case PurchHeader."Document Type" of
                PurchHeader."Document Type"::Order:
                    begin
                        DocumentType := DATABASE::"Purch. Rcpt. Header";
                        DocumentNo := PurchHeader."Last Receiving No."; // P8866030
                        ReceiptHeader.Get(DocumentNo);
                        DocumentDate := ReceiptHeader."Document Date";
                        ReceiptLine.SetRange("Document No.", DocumentNo);
                        ReceiptLine.SetRange(Type, ReceiptLine.Type::Item);
                        ReceiptLine.SetFilter(Quantity, '>0');
                        TempEntity.SetRange("Source ID", DATABASE::Item);
                        if TempEntity.Find('-') then
                            repeat
                                ReceiptLine.SetRange("No.", TempEntity."Source Key 1");
                                ReceiptLine.SetRange("Location Code", TempEntity."Location Code");
                                TempEntity.Include := not ReceiptLine.IsEmpty;
                                TempEntity.Modify;
                            until TempEntity.Next = 0;
                    end;
                PurchHeader."Document Type"::"Return Order":
                    begin
                        DocumentType := DATABASE::"Return Shipment Header";
                        DocumentNo := PurchHeader."Last Return Shipment No."; // P80066030
                        ShipmentHeader.Get(DocumentNo);
                        DocumentDate := ShipmentHeader."Document Date";
                        ShipmentLine.SetRange("Document No.", DocumentNo);
                        ShipmentLine.SetRange(Type, ShipmentLine.Type::Item);
                        ShipmentLine.SetFilter(Quantity, '>0');
                        TempEntity.SetRange("Source ID", DATABASE::Item);
                        if TempEntity.Find('-') then
                            repeat
                                ShipmentLine.SetRange("No.", TempEntity."Source Key 1");
                                ShipmentLine.SetRange("Location Code", TempEntity."Location Code");
                                TempEntity.Include := not ShipmentLine.IsEmpty;
                                TempEntity.Modify;
                            until TempEntity.Next = 0;
                    end;
            end;
            TempEntity.Reset;
            TempEntity.SetRange(Include, true);
            if not TempLocation.Find('-') then // P8001285, P8001331
                exit;                            // P8001285
            repeat
                TempEntity.SetRange("Location Code", TempLocation."Location Code");
                TempLocation.Include := not TempEntity.IsEmpty;
                TempLocation.Modify;
            until TempLocation.Next = 0;

            CreateSheets := true;
        end else begin
            CreateDataSheets.SetData(SheetType, TempLocation, TempEntity);
            CreateSheets := CreateDataSheets.RunModal = ACTION::OK;
            if CreateSheets then
                CreateDataSheets.GetData(TempLocation, TempEntity);
        end;

        if CreateSheets then begin
            TempLocation.Reset;
            TempOrderLine.Reset;
            TempEntity.Reset;

            Clear(DataSheetHeader);
            DataSheetHeader.Init;
            DataSheetHeader."Source ID" := DATABASE::"Purchase Header";
            DataSheetHeader."Source Subtype" := PurchHeader."Document Type";
            DataSheetHeader."Source No." := PurchHeader."No.";
            DataSheetHeader."Reference Type" := DataSheetHeader."Reference Type"::Vendor;
            DataSheetHeader."Reference ID" := PurchHeader."Buy-from Vendor No.";
            DataSheetHeader."Document Type" := DocumentType;
            DataSheetHeader."Document No." := DocumentNo;
            DataSheetHeader."Document Date" := DocumentDate;
            CreateSheetLines(DataSheetHeader, TempLocation, TempOrderLine, TempEntity);
        end;
    end;

    procedure CreateSheetForTransHeader(TransHeader: Record "Transfer Header"; Direction: Option Ship,Receive; Posting: Boolean; PostedDocNo: Code[20])
    var
        Location: Record Location;
        Item: Record Item;
        TransLine: Record "Transfer Line";
        ShipmentHeader: Record "Transfer Shipment Header";
        ShipmentLine: Record "Transfer Shipment Line";
        ReceiptHeader: Record "Transfer Receipt Header";
        ReceiptLine: Record "Transfer Receipt Line";
        DataCollectionLine: Record "Data Collection Line";
        DataSheetHeader: Record "Data Sheet Header";
        DataSheetLineDetail: Record "Data Sheet Line Detail";
        TempLocation: Record "Data Collection Entity" temporary;
        TempOrderLine: Record "Data Collection Entity" temporary;
        TempEntity: Record "Data Collection Entity" temporary;
        LocationCode: Code[10];
        CreateDataSheets: Page "Create Data Sheets";
        SheetType: Integer;
        CreateSheets: Boolean;
        DocumentType: Integer;
        DocumentDate: Date;
    begin
        case Direction of
            Direction::Ship:
                begin
                    SheetType := DataCollectionLine.Type::Shipping;
                    LocationCode := TransHeader."Transfer-from Code";
                end;
            Direction::Receive:
                begin
                    SheetType := DataCollectionLine.Type::Receiving;
                    LocationCode := TransHeader."Transfer-to Code";
                end;
        end;

        TransLine.SetCurrentKey("Item No.");
        TransLine.SetRange("Document No.", TransHeader."No.");
        TransLine.SetRange(Type, TransLine.Type::Item);
        TransLine.SetRange("Derived From Line No.", 0);
        TransLine.SetFilter("Item No.", '<>%1', '');
        if TransLine.FindSet then
            repeat
                if not TempLocation.Get(LocationCode) then begin
                    TempLocation.Init;
                    TempLocation."Location Code" := LocationCode;
                    if Location.Get(TempLocation."Location Code") then
                        TempLocation.Description := Location.Name;
                    DataSheetHeader.SetCurrentKey("Location Code", "Source ID", "Source Subtype", "Source No.");
                    DataSheetHeader.SetRange("Location Code", TempLocation."Location Code");
                    DataSheetHeader.SetRange(Type, SheetType);
                    DataSheetHeader.SetRange("Source ID", DATABASE::"Transfer Header");
                    DataSheetHeader.SetRange("Source No.", TransHeader."No.");
                    DataSheetHeader.SetFilter(Status, '%1|%2', DataSheetHeader.Status::Pending, DataSheetHeader.Status::"In Progress");
                    DataSheetHeader.SetRange("Document No.", '');
                    if DataSheetHeader.FindFirst then begin
                        TempLocation.Include := true;
                        TempLocation."Data Sheet No." := DataSheetHeader."No.";
                    end;
                    if DataCollectionLinesExist(DATABASE::Location, TempLocation."Location Code", '', SheetType) then begin
                        TempLocation.Include := true;
                        TempEntity."Location Code" := TempLocation."Location Code";
                        TempEntity."Source ID" := DATABASE::Location;
                        TempEntity."Source Key 1" := TempLocation."Location Code";
                        TempEntity.Description := TempLocation.Description;
                        TempEntity.Include := true;
                        TempEntity.Insert;
                    end;
                    TempLocation.Insert;
                    TempOrderLine."Location Code" := TempLocation."Location Code";
                    TempOrderLine."Prod. Order Line No." := 0;
                    TempOrderLine.Include := true;
                    TempOrderLine.Insert;
                end;

                TempEntity."Location Code" := TempLocation."Location Code";
                Item.Get(TransLine."Item No.");
                if DataCollectionLinesExist(DATABASE::Item, TransLine."Item No.", '', SheetType) then begin
                    if not TempEntity.Get(TempLocation."Location Code", 0, DATABASE::Item, TransLine."Item No.") then begin
                        TempEntity.Init;
                        TempEntity."Source ID" := DATABASE::Item;
                        TempEntity."Source Key 1" := TransLine."Item No.";
                        TempEntity.Description := Item.Description;
                        TempEntity.Insert;
                    end;
                    if TempLocation."Data Sheet No." = '' then begin
                        case Direction of
                            Direction::Ship:
                                TempEntity.Include := TempEntity.Include or (TransLine."Outstanding Quantity" > 0);
                            Direction::Receive:
                                TempEntity.Include := TempEntity.Include or (TransLine."Qty. in Transit" > 0);
                        end;
                    end else begin
                        DataSheetLineDetail.SetCurrentKey("Data Sheet No.", "Source ID", "Source Key 1", "Source Key 2");
                        DataSheetLineDetail.SetRange("Data Sheet No.", TempLocation."Data Sheet No.");
                        DataSheetLineDetail.SetRange("Source ID", DATABASE::Item);
                        DataSheetLineDetail.SetRange("Source Key 1", TransLine."Item No.");
                        TempEntity.Include := not DataSheetLineDetail.IsEmpty;
                    end;
                    TempEntity.Modify;
                    if not TempLocation.Include then begin
                        TempLocation.Include := true;
                        TempLocation.Modify;
                    end;
                end;
            until TransLine.Next = 0;

        TempLocation.Reset;
        TempOrderLine.Reset;
        TempEntity.Reset;

        if (not Posting) and TempLocation.IsEmpty then begin
            Message(Text002);
            exit;
        end;

        if Posting then begin
            case Direction of
                Direction::Ship:
                    begin
                        DocumentType := DATABASE::"Transfer Shipment Header";
                        ShipmentHeader.Get(PostedDocNo);
                        DocumentDate := ShipmentHeader."Posting Date";
                        ShipmentLine.SetRange("Document No.", PostedDocNo);
                        ShipmentLine.SetFilter(Quantity, '>0');
                        TempEntity.SetRange("Source ID", DATABASE::Item);
                        if TempEntity.Find('-') then
                            repeat
                                ShipmentLine.SetRange("Item No.", TempEntity."Source Key 1");
                                TempEntity.Include := not ShipmentLine.IsEmpty;
                                TempEntity.Modify;
                            until TempEntity.Next = 0;
                    end;
                Direction::Receive:
                    begin
                        DocumentType := DATABASE::"Transfer Receipt Header";
                        ReceiptHeader.Get(PostedDocNo);
                        DocumentDate := ReceiptHeader."Posting Date";
                        ReceiptLine.SetRange("Document No.", PostedDocNo);
                        ReceiptLine.SetFilter(Quantity, '>0');
                        TempEntity.SetRange("Source ID", DATABASE::Item);
                        if TempEntity.Find('-') then
                            repeat
                                ReceiptLine.SetRange("Item No.", TempEntity."Source Key 1");
                                TempEntity.Include := not ReceiptLine.IsEmpty;
                                TempEntity.Modify;
                            until TempEntity.Next = 0;
                    end;
            end;

            TempEntity.Reset;
            TempEntity.SetRange(Include, true);
            if not TempLocation.Find('-') then // P8001285, P8001331
                exit;                            // P8001285
            repeat
                TempEntity.SetRange("Location Code", TempLocation."Location Code");
                TempLocation.Include := not TempEntity.IsEmpty;
                TempLocation.Modify;
            until TempLocation.Next = 0;

            CreateSheets := true;
        end else begin
            CreateDataSheets.SetData(SheetType, TempLocation, TempEntity);
            CreateSheets := CreateDataSheets.RunModal = ACTION::OK;
            if CreateSheets then
                CreateDataSheets.GetData(TempLocation, TempEntity);
        end;

        if CreateSheets then begin
            TempLocation.Reset;
            TempOrderLine.Reset;
            TempEntity.Reset;

            Clear(DataSheetHeader);
            DataSheetHeader.Init;
            DataSheetHeader."Source ID" := DATABASE::"Transfer Header";
            DataSheetHeader."Source No." := TransHeader."No.";
            case Direction of
                Direction::Ship:
                    DataSheetHeader.Type := DataSheetHeader.Type::Shipping;
                Direction::Receive:
                    DataSheetHeader.Type := DataSheetHeader.Type::Receiving;
            end;
            DataSheetHeader."Document Type" := DocumentType;
            DataSheetHeader."Document No." := PostedDocNo;
            DataSheetHeader."Document Date" := DocumentDate;
            CreateSheetLines(DataSheetHeader, TempLocation, TempOrderLine, TempEntity);
        end;
    end;

    procedure CreateSheetForProdOrder(ProdOrder: Record "Production Order"; Finishing: Boolean)
    var
        Location: Record Location;
        Item: Record Item;
        Resource: Record Resource;
        WorkCenter: Record "Work Center";
        MachineCenter: Record "Machine Center";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderRouting: Record "Prod. Order Routing Line";
        DataCollectionLine: Record "Data Collection Line";
        DataSheetHeader: Record "Data Sheet Header";
        DataSheetLine: Record "Data Sheet Line";
        TempLocation: Record "Data Collection Entity" temporary;
        TempOrderLine: Record "Data Collection Entity" temporary;
        TempEntity: Record "Data Collection Entity" temporary;
        CreateDataSheets: Page "Create Data Sheets";
        SheetType: Integer;
        CreateSheets: Boolean;
        EntityExists: Boolean;
        DocumentType: Integer;
        DocumentNo: Code[20];
        DocumentDate: Date;
    begin
        SheetType := DataCollectionLine.Type::Production;

        ProdOrderLine.SetRange(Status, ProdOrder.Status);
        ProdOrderLine.SetRange("Prod. Order No.", ProdOrder."No.");
        ProdOrderLine.SetFilter("Item No.", '<>%1', '');
        if ProdOrderLine.FindSet then
            repeat
                if not TempLocation.Get(ProdOrderLine."Location Code") then begin
                    TempLocation.Init;
                    TempLocation."Location Code" := ProdOrderLine."Location Code";
                    if Location.Get(TempLocation."Location Code") then
                        TempLocation.Description := Location.Name;
                    DataSheetHeader.SetCurrentKey("Location Code", "Source ID", "Source Subtype", "Source No.");
                    DataSheetHeader.SetRange("Location Code", TempLocation."Location Code");
                    DataSheetHeader.SetRange(Type, SheetType);
                    DataSheetHeader.SetRange("Source ID", DATABASE::"Production Order");
                    DataSheetHeader.SetRange("Source Subtype", ProdOrder.Status::Released);
                    DataSheetHeader.SetRange("Source No.", ProdOrder."No.");
                    DataSheetHeader.SetFilter(Status, '%1|%2', DataSheetHeader.Status::Pending, DataSheetHeader.Status::"In Progress");
                    if DataSheetHeader.FindFirst then begin
                        TempLocation.Include := true;
                        TempLocation."Data Sheet No." := DataSheetHeader."No.";
                    end;
                end;

                TempOrderLine."Location Code" := ProdOrderLine."Location Code";
                TempOrderLine."Prod. Order Line No." := ProdOrderLine."Line No.";
                TempOrderLine.Description := ProdOrderLine.Description;
                if Finishing then
                    TempOrderLine.Include := ProdOrderLine."Finished Quantity" > 0
                else begin
                    if TempLocation."Data Sheet No." = '' then
                        TempOrderLine.Include := ProdOrderLine.Quantity > 0
                    else begin
                        DataSheetLine.SetRange("Data Sheet No.", TempLocation."Data Sheet No.");
                        DataSheetLine.SetRange("Prod. Order Line No.", TempOrderLine."Prod. Order Line No.");
                        TempOrderLine.Include := not DataSheetLine.IsEmpty;
                    end;
                end;
                EntityExists := false;

                TempEntity."Location Code" := TempLocation."Location Code";
                TempEntity."Prod. Order Line No." := ProdOrderLine."Line No.";
                if DataCollectionLinesExist(DATABASE::Location, ProdOrderLine."Location Code", '', SheetType) then begin
                    TempEntity."Source ID" := DATABASE::Location;
                    TempEntity."Source Key 1" := ProdOrderLine."Location Code";
                    TempEntity.Description := TempLocation.Description;
                    TempEntity.Include := true;
                    TempEntity.Insert;
                    EntityExists := true;
                end;
                if DataCollectionLinesExist(DATABASE::Item, ProdOrderLine."Item No.", '', SheetType) then begin
                    TempEntity."Source ID" := DATABASE::Item;
                    TempEntity."Source Key 1" := ProdOrderLine."Item No.";
                    Item.Get(ProdOrderLine."Item No.");
                    TempEntity.Description := Item.Description;
                    TempEntity.Include := true;
                    TempEntity.Insert;
                    EntityExists := true;
                end;
                if DataCollectionLinesExist(DATABASE::Resource, ProdOrderLine."Equipment Code", '', SheetType) then begin
                    TempEntity."Source ID" := DATABASE::Resource;
                    TempEntity."Source Key 1" := ProdOrderLine."Equipment Code";
                    Resource.Get(ProdOrderLine."Equipment Code");
                    TempEntity.Description := Resource.Name;
                    TempEntity.Include := true;
                    TempEntity.Insert;
                    EntityExists := true;
                end;
                ProdOrderRouting.SetRange(Status, ProdOrderLine.Status);
                ProdOrderRouting.SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
                ProdOrderRouting.SetRange("Routing Reference No.", ProdOrderLine."Line No.");
                if ProdOrderRouting.FindSet then
                    repeat
                        if DataCollectionLinesExist(DATABASE::"Work Center", ProdOrderRouting."Work Center No.", '', SheetType) then begin
                            if not TempEntity.Get(TempOrderLine."Location Code", TempOrderLine."Prod. Order Line No.",
                              DATABASE::"Work Center", ProdOrderRouting."Work Center No.")
                            then begin
                                TempEntity.Init;
                                TempEntity."Source ID" := DATABASE::"Work Center";
                                TempEntity."Source Key 1" := ProdOrderRouting."Work Center No.";
                                WorkCenter.Get(ProdOrderRouting."Work Center No.");
                                TempEntity.Description := WorkCenter.Name;
                                TempEntity.Include := true;
                                if TempEntity.Insert then;
                                EntityExists := true;
                            end;
                        end;
                        if ProdOrderRouting.Type = ProdOrderRouting.Type::"Machine Center" then
                            if DataCollectionLinesExist(DATABASE::"Machine Center", ProdOrderRouting."No.", '', SheetType) then begin
                                if not TempEntity.Get(TempOrderLine."Location Code", TempOrderLine."Prod. Order Line No.",
                                  DATABASE::"Machine Center", ProdOrderRouting."No.")
                                then begin
                                    TempEntity.Init;
                                    TempEntity."Source ID" := DATABASE::"Machine Center";
                                    TempEntity."Source Key 1" := ProdOrderRouting."No.";
                                    MachineCenter.Get(ProdOrderRouting."No.");
                                    TempEntity.Description := MachineCenter.Name;
                                    TempEntity.Include := true;
                                    if TempEntity.Insert then;
                                    EntityExists := true;
                                end;
                            end;
                    until ProdOrderRouting.Next = 0;

                if EntityExists then begin
                    TempOrderLine.Insert;
                    TempLocation.Include := true;
                end;
                if TempLocation.Insert then;
            until ProdOrderLine.Next = 0;

        TempLocation.Reset;
        TempOrderLine.Reset;
        TempEntity.Reset;

        if (not Finishing) and TempLocation.IsEmpty then begin
            Message(Text002);
            exit;
        end;

        if Finishing then begin
            DocumentType := DATABASE::"Production Order";
            DocumentNo := ProdOrder."No.";
            DocumentDate := ProdOrder."Finished Date";
            CreateSheets := true
        end else begin
            CreateDataSheets.SetData(SheetType, TempLocation, TempOrderLine);
            CreateSheets := CreateDataSheets.RunModal = ACTION::OK;
            if CreateSheets then
                CreateDataSheets.SetData(SheetType, TempLocation, TempOrderLine);
        end;

        if CreateSheets then begin
            TempLocation.Reset;
            TempOrderLine.Reset;
            TempEntity.Reset;

            Clear(DataSheetHeader);
            DataSheetHeader.Init;
            DataSheetHeader."Source ID" := DATABASE::"Production Order";
            DataSheetHeader."Source Subtype" := ProdOrder.Status::Released;
            DataSheetHeader."Source No." := ProdOrder."No.";
            DataSheetHeader."Document Type" := DocumentType;
            DataSheetHeader."Document No." := DocumentNo;
            DataSheetHeader."Document Date" := DocumentDate;
            CreateSheetLines(DataSheetHeader, TempLocation, TempOrderLine, TempEntity);
        end;
    end;

    procedure CreateSheetForLogGroup(LogGroup: Record "Data Collection Log Group")
    var
        Location: Record Location;
        Zone: Record Zone;
        Bin: Record Bin;
        Resource: Record Resource;
        Asset: Record Asset;
        DataCollectionLine: Record "Data Collection Line";
        DataSheetHeader: Record "Data Sheet Header";
        DataSheetLineDetail: Record "Data Sheet Line Detail";
        TempLocation: Record "Data Collection Entity" temporary;
        TempOrderLine: Record "Data Collection Entity" temporary;
        TempEntity: Record "Data Collection Entity" temporary;
        CreateDataSheets: Page "Create Data Sheets";
        SheetType: Integer;
        LocationCode: Code[10];
        SourceDescription: Text[100];
        CreateSheets: Boolean;
    begin
        SheetType := DataCollectionLine.Type::Log;

        DataCollectionLine.SetRange("Log Group Code", LogGroup.Code);
        DataCollectionLine.SetRange(Type, DataCollectionLine.Type::Log);
        DataCollectionLine.SetRange(Active, true);
        if DataCollectionLine.Find('-') then
            repeat
                case DataCollectionLine."Source ID" of
                    DATABASE::Location:
                        begin
                            LocationCode := DataCollectionLine."Source Key 1";
                            Location.Get(DataCollectionLine."Source Key 1");
                            if Location.Name <> '' then
                                SourceDescription := Location.Name
                            else
                                SourceDescription := Location.Code;
                        end;
                    DATABASE::Zone:
                        begin
                            LocationCode := DataCollectionLine."Source Key 1";
                            Zone.Get(DataCollectionLine."Source Key 1", DataCollectionLine."Source Key 2");
                            if Zone.Description <> '' then
                                SourceDescription := Zone.Description
                            else
                                SourceDescription := Zone.Code;
                        end;
                    DATABASE::Bin:
                        begin
                            LocationCode := DataCollectionLine."Source Key 1";
                            Bin.Get(DataCollectionLine."Source Key 1", DataCollectionLine."Source Key 2");
                            if Bin.Description <> '' then
                                SourceDescription := Bin.Description
                            else
                                SourceDescription := Bin.Code;
                        end;
                    DATABASE::Resource:
                        begin
                            Resource.Get(DataCollectionLine."Source Key 1");
                            LocationCode := Resource."Location Code";
                            if Resource.Name <> '' then
                                SourceDescription := Resource.Name
                            else
                                SourceDescription := Resource."No.";
                        end;
                    DATABASE::Asset:
                        begin
                            Asset.Get(DataCollectionLine."Source Key 1");
                            LocationCode := Asset."Location Code";
                            if Asset.Description <> '' then
                                SourceDescription := Asset.Description
                            else
                                SourceDescription := Asset."No.";
                        end;
                end;

                if not TempLocation.Get(LocationCode) then begin
                    TempLocation.Init;
                    TempLocation."Location Code" := LocationCode;
                    if Location.Get(TempLocation."Location Code") then
                        TempLocation.Description := Location.Name;
                    DataSheetHeader.SetCurrentKey("Location Code", "Source ID", "Source Subtype", "Source No.");
                    DataSheetHeader.SetRange("Location Code", TempLocation."Location Code");
                    DataSheetHeader.SetRange(Type, SheetType);
                    DataSheetHeader.SetRange("Source No.", LogGroup.Code);
                    DataSheetHeader.SetFilter(Status, '%1|%2', DataSheetHeader.Status::Pending, DataSheetHeader.Status::"In Progress");
                    if DataSheetHeader.FindFirst then
                        TempLocation."Data Sheet No." := DataSheetHeader."No.";
                    TempLocation.Include := true;
                    TempLocation.Insert;
                    TempOrderLine."Location Code" := TempLocation."Location Code";
                    TempOrderLine."Prod. Order Line No." := 0;
                    TempOrderLine.Include := true;
                    TempOrderLine.Insert;
                end;

                TempEntity.Init;
                TempEntity."Location Code" := TempLocation."Location Code";
                TempEntity."Source ID" := DataCollectionLine."Source ID";
                TempEntity."Source Key 1" := DataCollectionLine."Source Key 1";
                TempEntity."Source Key 2" := DataCollectionLine."Source Key 2";
                TempEntity.Description := SourceDescription;
                if TempLocation."Data Sheet No." = '' then
                    TempEntity.Include := true
                else begin
                    DataSheetLineDetail.SetCurrentKey("Data Sheet No.", "Source ID", "Source Key 1", "Source Key 2");
                    DataSheetLineDetail.SetRange("Data Sheet No.", TempLocation."Data Sheet No.");
                    DataSheetLineDetail.SetRange("Source ID", TempEntity."Source ID");
                    DataSheetLineDetail.SetRange("Source Key 1", TempEntity."Source Key 1");
                    DataSheetLineDetail.SetRange("Source Key 2", TempEntity."Source Key 2");
                    TempEntity.Include := not DataSheetLineDetail.IsEmpty;
                end;
                TempEntity.Insert;

                DataCollectionLine.SetRange("Source ID", DataCollectionLine."Source ID");
                DataCollectionLine.SetRange("Source Key 1", DataCollectionLine."Source Key 1");
                DataCollectionLine.SetRange("Source Key 2", DataCollectionLine."Source Key 2");
                DataCollectionLine.Find('+');
                DataCollectionLine.SetRange("Source ID");
                DataCollectionLine.SetRange("Source Key 1");
                DataCollectionLine.SetRange("Source Key 2");
            until DataCollectionLine.Next = 0;

        TempLocation.Reset;
        TempOrderLine.Reset;
        TempEntity.Reset;

        if TempLocation.IsEmpty then begin
            Message(Text002);
            exit;
        end;

        CreateDataSheets.SetData(SheetType, TempLocation, TempEntity);
        CreateSheets := CreateDataSheets.RunModal = ACTION::OK;
        if CreateSheets then
            CreateDataSheets.SetData(SheetType, TempLocation, TempOrderLine);

        if CreateSheets then begin
            TempLocation.Reset;
            TempOrderLine.Reset;
            TempEntity.Reset;

            Clear(DataSheetHeader);
            DataSheetHeader.Init;
            DataSheetHeader."Source No." := LogGroup.Code;
            CreateSheetLines(DataSheetHeader, TempLocation, TempOrderLine, TempEntity);
        end;
    end;

    local procedure CreateSheetLines(DataSheetHeader: Record "Data Sheet Header"; var TempLocation: Record "Data Collection Entity" temporary; var TempOrderLine: Record "Data Collection Entity" temporary; var TempEntity: Record "Data Collection Entity" temporary)
    var
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        DataCollectionElement: Record "Data Collection Data Element";
        DataCollectionLine: Record "Data Collection Line";
        DataSheetHeader2: Record "Data Sheet Header";
        DataSheetLineTemp: Record "Data Sheet Line" temporary;
        DataSheetLine: Record "Data Sheet Line";
        DataSheetLine2: Record "Data Sheet Line";
        DataSheetLineDetailTemp: Record "Data Sheet Line Detail" temporary;
        DataSheetLineDetail: Record "Data Sheet Line Detail";
        DataCollectionTemplate: Record "Data Collection Template";
        LogGroup: Record "Data Collection Log Group";
        SourceLink: Record "Record Link";
        DataSheetLinkTemp: Record "Record Link" temporary;
        DataSheetLink: Record "Record Link";
        RecordRef: RecordRef;
        DataSheetRecordID: RecordID;
        LineNo: Integer;
        LinkID: Integer;
        ProdOrderLineNo: Integer;
        Cnt: Integer;
    begin
        case DataSheetHeader."Source ID" of
            0:
                DataSheetHeader.Type := DataSheetHeader.Type::Log;
            DATABASE::"Sales Header":
                case DataSheetHeader."Source Subtype" of
                    SalesHeader."Document Type"::Order:
                        DataSheetHeader.Type := DataSheetHeader.Type::Shipping;
                    SalesHeader."Document Type"::"Return Order":
                        DataSheetHeader.Type := DataSheetHeader.Type::Receiving;
                end;
            DATABASE::"Purchase Header":
                case DataSheetHeader."Source Subtype" of
                    PurchHeader."Document Type"::Order:
                        DataSheetHeader.Type := DataSheetHeader.Type::Receiving;
                    PurchHeader."Document Type"::"Return Order":
                        DataSheetHeader.Type := DataSheetHeader.Type::Shipping;
                end;
            DATABASE::"Sales Shipment Header", DATABASE::"Return Shipment Header", DATABASE::"Transfer Shipment Header":
                DataSheetHeader.Type := DataSheetHeader.Type::Shipping;
            DATABASE::"Purch. Rcpt. Header", DATABASE::"Return Receipt Header", DATABASE::"Transfer Receipt Header":
                DataSheetHeader.Type := DataSheetHeader.Type::Receiving;
            DATABASE::"Production Order":
                DataSheetHeader.Type := DataSheetHeader.Type::Production;
        end;

        TempLocation.Reset;
        TempOrderLine.Reset;
        TempEntity.Reset;

        if TempLocation.Find('-') then
            repeat
                if TempLocation."Data Sheet No." = '' then
                    DataSheetHeader2 := DataSheetHeader
                else begin
                    DataSheetHeader2.Get(TempLocation."Data Sheet No.");
                    DataSheetHeader2."Document Type" := DataSheetHeader."Document Type";
                    DataSheetHeader2."Document No." := DataSheetHeader."Document No.";
                    DataSheetHeader2."Document Date" := DataSheetHeader."Document Date";
                end;
                DataSheetHeader2."Location Code" := TempLocation."Location Code";
                DataSheetHeader2.SetDescription;

                if (TempLocation."Data Sheet No." <> '') and (not TempLocation.Include) then
                    DataSheetHeader2.Delete(true)
                else
                    if TempLocation.Include then begin
                        DataSheetLineTemp.Reset;
                        DataSheetLineTemp.DeleteAll;
                        DataSheetLineDetailTemp.Reset;
                        DataSheetLineDetailTemp.DeleteAll;
                        DataSheetLinkTemp.Reset;
                        DataSheetLinkTemp.DeleteAll;
                        DataCollectionTemplate.Reset;
                        LineNo := 0;
                        LinkID := 0;

                        TempOrderLine.SetRange("Location Code", TempLocation."Location Code");
                        TempOrderLine.SetRange(Include, true);
                        if TempOrderLine.Find('-') then
                            repeat
                                if DataSheetHeader.Type = DataSheetHeader.Type::Production then
                                    if not DataSheetLineTemp.Get('', TempOrderLine."Prod. Order Line No.", '', 0, 0) then begin
                                        DataSheetLineTemp.Init;
                                        DataSheetLineTemp."Prod. Order Line No." := TempOrderLine."Prod. Order Line No.";
                                        DataSheetLineTemp.Description := StrSubstNo(Text003, TempOrderLine."Prod. Order Line No.", TempOrderLine.Description);
                                        DataSheetLineTemp."Data Element Code" := '';
                                        DataSheetLineTemp."Line No." := 0;
                                        DataSheetLineTemp."Instance No." := 0;
                                        DataSheetLineTemp."Hide Line" := true;
                                        DataSheetLineTemp.Insert;
                                    end;

                                TempEntity.SetRange("Location Code", TempLocation."Location Code");
                                TempEntity.SetRange("Prod. Order Line No.", TempOrderLine."Prod. Order Line No.");
                                TempEntity.SetRange(Include, true);
                                if TempEntity.Find('-') then
                                    repeat
                                        DataCollectionLine.SetRange("Source ID", TempEntity."Source ID");
                                        DataCollectionLine.SetRange("Source Key 1", TempEntity."Source Key 1");
                                        DataCollectionLine.SetRange("Source Key 2", TempEntity."Source Key 2");
                                        DataCollectionLine.SetRange(Type, DataSheetHeader.Type);
                                        DataCollectionLine.SetRange(Active, true);

                                        if DataCollectionLine.FindSet then
                                            repeat
                                                if TempOrderLine."Prod. Order Line No." <> 0 then begin
                                                    case DataCollectionLine."Order or Line" of
                                                        DataCollectionLine."Order or Line"::Order:
                                                            ProdOrderLineNo := 0;
                                                        DataCollectionLine."Order or Line"::Line:
                                                            ProdOrderLineNo := TempOrderLine."Prod. Order Line No.";
                                                    end;
                                                    if ProdOrderLineNo = 0 then begin
                                                        if not DataSheetLineTemp.Get('', ProdOrderLineNo, '', 0, 0) then begin
                                                            DataSheetLineTemp.Init;
                                                            DataSheetLineTemp."Prod. Order Line No." := ProdOrderLineNo;
                                                            DataSheetLineTemp.Description := DataSheetHeader2.Description;
                                                            DataSheetLineTemp."Data Element Code" := '';
                                                            DataSheetLineTemp."Line No." := 0;
                                                            DataSheetLineTemp."Instance No." := 0;
                                                            DataSheetLineTemp.Insert;
                                                        end;
                                                    end else begin
                                                        DataSheetLineTemp.Get('', TempOrderLine."Prod. Order Line No.", '', 0, 0);
                                                        DataSheetLineTemp."Hide Line" := false;
                                                        DataSheetLineTemp.Modify;
                                                    end;
                                                end;

                                                if (DataCollectionLine.Recurrence = DataCollectionLine.Recurrence::Scheduled) and
                                                  (DataCollectionLine.Frequency = 0)
                                                then begin
                                                    DataCollectionLine.Recurrence := DataCollectionLine.Recurrence::Unscheduled;
                                                    DataCollectionLine."Scheduled Type" := DataCollectionLine."Scheduled Type"::"Begin";
                                                    DataCollectionLine."Schedule Base" := DataCollectionLine."Schedule Base"::Schedule;
                                                    DataCollectionLine."Missed Collection Alert Group" := '';
                                                    DataCollectionLine."Grace Period" := 0;
                                                end;

                                                DataSheetLineTemp.SetRange("Prod. Order Line No.", ProdOrderLineNo);
                                                DataSheetLineTemp.SetRange("Data Element Code", DataCollectionLine."Data Element Code");
                                                DataSheetLineTemp.SetRange(Recurrence, DataCollectionLine.Recurrence);
                                                DataSheetLineTemp.SetRange(Frequency, DataCollectionLine.Frequency);
                                                DataSheetLineTemp.SetRange("Scheduled Type", DataCollectionLine."Scheduled Type");
                                                DataSheetLineTemp.SetRange("Schedule Base", DataCollectionLine."Schedule Base");
                                                DataCollectionElement.Get(DataCollectionLine."Data Element Code"); // P8001160
                                                if DataCollectionElement."Create Separate Lines" or (not DataSheetLineTemp.FindFirst) then begin // P8001160
                                                    LineNo += 1;
                                                    DataSheetLineTemp.Init;
                                                    DataSheetLineTemp."Prod. Order Line No." := ProdOrderLineNo;
                                                    DataSheetLineTemp."Data Element Code" := DataCollectionLine."Data Element Code";
                                                    DataSheetLineTemp."Unit of Measure Code" := DataCollectionLine."Unit of Measure Code";  // P80037645
                                                    DataSheetLineTemp."Measuring Method" := DataCollectionLine."Measuring Method";          // P80037645
                                                    DataSheetLineTemp.Description := DataCollectionLine.Description;
                                                    DataSheetLineTemp."Description 2" := DataCollectionLine."Description 2";
                                                    DataSheetLineTemp."Data Element Type" := DataCollectionLine."Data Element Type";
                                                    DataSheetLineTemp."Line No." := LineNo;
                                                    DataSheetLineTemp."Instance No." := 1;
                                                    DataSheetLineTemp.Type := DataSheetHeader2.Type;
                                                    DataSheetLineTemp.Recurrence := DataCollectionLine.Recurrence;
                                                    DataSheetLineTemp.Frequency := DataCollectionLine.Frequency;
                                                    DataSheetLineTemp."Scheduled Type" := DataCollectionLine."Scheduled Type";
                                                    DataSheetLineTemp."Schedule Base" := DataCollectionLine."Schedule Base";
                                                    DataSheetLineTemp.Insert;
                                                end;
                                                if not DataSheetLineDetailTemp.Get('', ProdOrderLineNo, DataSheetLineTemp."Data Element Code",
                                                  DataSheetLineTemp."Line No.", DataCollectionLine."Source ID", DataCollectionLine."Source Key 1",
                                                  DataCollectionLine."Source Key 2", 1)
                                                then begin
                                                    DataSheetLineDetailTemp.Init;
                                                    DataSheetLineDetailTemp."Prod. Order Line No." := ProdOrderLineNo;
                                                    DataSheetLineDetailTemp."Data Element Code" := DataSheetLineTemp."Data Element Code";
                                                    DataSheetLineDetailTemp."Line No." := DataSheetLineTemp."Line No.";
                                                    DataSheetLineDetailTemp."Source ID" := DataCollectionLine."Source ID";
                                                    DataSheetLineDetailTemp."Source Key 1" := DataCollectionLine."Source Key 1";
                                                    DataSheetLineDetailTemp."Source Key 2" := DataCollectionLine."Source Key 2";
                                                    DataSheetLineDetailTemp."Instance No." := 1;
                                                    DataSheetLineDetailTemp.Type := DataSheetHeader2.Type;
                                                    DataSheetLineDetailTemp."Data Element Type" := DataCollectionLine."Data Element Type";
                                                    DataSheetLineDetailTemp."Boolean Target Value" := DataCollectionLine."Boolean Target Value";
                                                    DataSheetLineDetailTemp."Lookup Target Value" := DataCollectionLine."Lookup Target Value";
                                                    DataSheetLineDetailTemp."Numeric Target Value" := DataCollectionLine."Numeric Target Value";
                                                    DataSheetLineDetailTemp."Text Target Value" := DataCollectionLine."Text Target Value";
                                                    DataSheetLineDetailTemp."Numeric Low-Low Value" := DataCollectionLine."Numeric Low-Low Value";
                                                    DataSheetLineDetailTemp."Numeric Low Value" := DataCollectionLine."Numeric Low Value";
                                                    DataSheetLineDetailTemp."Numeric High Value" := DataCollectionLine."Numeric High Value";
                                                    DataSheetLineDetailTemp."Numeric High-High Value" := DataCollectionLine."Numeric High-High Value";
                                                    DataSheetLineDetailTemp."Level 1 Alert Group" := DataCollectionLine."Level 1 Alert Group";
                                                    DataSheetLineDetailTemp."Level 2 Alert Group" := DataCollectionLine."Level 2 Alert Group";
                                                    DataSheetLineDetailTemp."Missed Collection Alert Group" := DataCollectionLine."Missed Collection Alert Group";
                                                    DataSheetLineDetailTemp."Grace Period" := DataCollectionLine."Grace Period";
                                                    DataSheetLineDetailTemp.Critical := DataCollectionLine.Critical;
                                                    DataSheetLineDetailTemp.Insert;
                                                end;

                                                if DataCollectionLine."Source Template Code" <> '' then begin
                                                    DataCollectionTemplate.Get(DataCollectionLine."Source Template Code");
                                                    if not DataCollectionTemplate.Mark then begin
                                                        DataCollectionTemplate.Mark(true);
                                                        RecordRef.GetTable(DataCollectionTemplate);
                                                        SourceLink.SetCurrentKey("Record ID");
                                                        SourceLink.SetRange("Record ID", RecordRef.RecordId);
                                                        SourceLink.SetRange(Type, SourceLink.Type::Link);
                                                        SourceLink.SetRange(Company, CompanyName);
                                                        if SourceLink.FindSet then
                                                            repeat
                                                                DataSheetLinkTemp.SetRange(URL1, SourceLink.URL1);
                                                                if DataSheetLinkTemp.IsEmpty then begin
                                                                    LinkID += 1;
                                                                    DataSheetLinkTemp := SourceLink;
                                                                    DataSheetLinkTemp."Link ID" := LinkID;
                                                                    DataSheetLinkTemp."User ID" := UserId;
                                                                    DataSheetLinkTemp.Insert;
                                                                end;
                                                            until SourceLink.Next = 0;
                                                    end;
                                                end;

                                            until DataCollectionLine.Next = 0;
                                    until TempEntity.Next = 0;

                                // Links for log groups
                                if DataSheetHeader.Type = DataSheetHeader.Type::Log then begin
                                    LogGroup.Get(DataSheetHeader."Source No.");
                                    RecordRef.GetTable(LogGroup);
                                    SourceLink.SetCurrentKey("Record ID");
                                    SourceLink.SetRange("Record ID", RecordRef.RecordId);
                                    SourceLink.SetRange(Type, SourceLink.Type::Link);
                                    SourceLink.SetRange(Company, CompanyName);
                                    if SourceLink.FindSet then
                                        repeat
                                            DataSheetLinkTemp.SetRange(URL1, SourceLink.URL1);
                                            if DataSheetLinkTemp.IsEmpty then begin
                                                LinkID += 1;
                                                DataSheetLinkTemp := SourceLink;
                                                DataSheetLinkTemp."Link ID" := LinkID;
                                                DataSheetLinkTemp."User ID" := UserId;
                                                DataSheetLinkTemp.Insert;
                                            end;
                                        until SourceLink.Next = 0;
                                end;

                            until TempOrderLine.Next = 0;

                        DataSheetLineTemp.Reset;
                        DataSheetLineDetailTemp.Reset;
                        DataSheetLinkTemp.Reset;
                        if DataSheetLineDetailTemp.Find('-') then begin
                            if DataSheetHeader2."No." = '' then begin
                                DataSheetHeader2.GetNumber;

                                repeat
                                    DataSheetLineDetail := DataSheetLineDetailTemp;
                                    DataSheetLineDetail."Data Sheet No." := DataSheetHeader2."No.";
                                    DataSheetLineDetail.Insert;
                                until DataSheetLineDetailTemp.Next = 0;

                                DataSheetLineTemp.Find('-');
                                repeat
                                    DataSheetLine := DataSheetLineTemp;
                                    DataSheetLine."Data Sheet No." := DataSheetHeader2."No.";
                                    DataSheetLine.Insert;
                                until DataSheetLineTemp.Next = 0;

                                if DataSheetLinkTemp.Find('-') then begin
                                    DataSheetLink.LockTable;
                                    DataSheetLink.FindLast;
                                    DataSheetHeader2.Insert(true);
                                    RecordRef.GetTable(DataSheetHeader2);
                                    DataSheetRecordID := RecordRef.RecordId;
                                    repeat
                                        DataSheetLink := DataSheetLinkTemp;
                                        DataSheetLink."Link ID" := 0;
                                        DataSheetLink."Record ID" := DataSheetRecordID;
                                        DataSheetLink.Created := CurrentDateTime;
                                        DataSheetLink.Insert;
                                    until DataSheetLinkTemp.Next = 0;
                                end else
                                    DataSheetHeader2.Insert(true);
                            end else begin
                                DataSheetLine.Reset;
                                DataSheetLine.SetCurrentKey("Data Sheet No.", "Line No.");
                                DataSheetLine.SetRange("Data Sheet No.", DataSheetHeader2."No.");
                                DataSheetLine.FindLast;
                                LineNo := DataSheetLine."Line No.";

                                DataSheetLine.SetCurrentKey("Data Sheet No.", "Prod. Order Line No.", "Data Element Code", "Line No.", "Instance No.");
                                if DataSheetLine.Find('-') then
                                    repeat
                                        DataSheetLineTemp.SetRange("Prod. Order Line No.", DataSheetLine."Prod. Order Line No.");
                                        DataSheetLineTemp.SetRange("Data Element Code", DataSheetLine."Data Element Code");
                                        DataSheetLineTemp.SetRange(Recurrence, DataSheetLine.Recurrence);
                                        DataSheetLineTemp.SetRange(Frequency, DataSheetLine.Frequency);
                                        DataSheetLineTemp.SetRange("Scheduled Type", DataSheetLine."Scheduled Type");
                                        DataSheetLineTemp.SetRange("Schedule Base", DataSheetLine."Schedule Base");
                                        if DataSheetLineTemp.Find('-') then begin
                                            if DataSheetLine."Data Element Code" = '' then begin
                                                DataSheetLine."Hide Line" := DataSheetLineTemp."Hide Line";
                                                DataSheetLine.Modify;
                                            end;
                                            if DataSheetLine."Line No." <> 0 then begin
                                                DataSheetLine.SetRange("Line No.", DataSheetLine."Line No.");
                                                DataSheetLine.Find('+');
                                                DataSheetLine.SetRange("Line No.");
                                            end;

                                            DataSheetLineDetail.SetRange("Data Sheet No.", DataSheetLine."Data Sheet No.");
                                            DataSheetLineDetail.SetRange("Prod. Order Line No.", DataSheetLine."Prod. Order Line No.");
                                            DataSheetLineDetail.SetRange("Data Element Code", DataSheetLine."Data Element Code");
                                            DataSheetLineDetail.SetRange("Line No.", DataSheetLine."Line No.");
                                            if DataSheetLineDetail.Find('-') then
                                                repeat
                                                    DataSheetLineDetail.SetRange("Source ID", DataSheetLineDetail."Source ID");
                                                    DataSheetLineDetail.SetRange("Source Key 1", DataSheetLineDetail."Source Key 1");
                                                    DataSheetLineDetail.SetRange("Source Key 2", DataSheetLineDetail."Source Key 2");
                                                    if DataSheetLineDetailTemp.Get('', DataSheetLineDetail."Prod. Order Line No.",
                                                      DataSheetLineDetail."Data Element Code", DataSheetLineTemp."Line No.",
                                                      DataSheetLineDetail."Source ID", DataSheetLineDetail."Source Key 1", DataSheetLineDetail."Source Key 2", 1)
                                                    then begin
                                                        DataSheetLineDetailTemp.Delete;
                                                        DataSheetLineDetail.Find('+');
                                                    end else
                                                        DataSheetLineDetail.DeleteAll(true);
                                                    DataSheetLineDetail.SetRange("Source ID");
                                                    DataSheetLineDetail.SetRange("Source Key 1");
                                                    DataSheetLineDetail.SetRange("Source Key 2");
                                                until DataSheetLineDetail.Next = 0;
                                            DataSheetLineTemp.Delete;
                                        end else begin
                                            DataSheetLine.SetRange("Prod. Order Line No.", DataSheetLine."Prod. Order Line No.");
                                            DataSheetLine.SetRange("Line No.", DataSheetLine."Line No.");
                                            DataSheetLine.DeleteAll(true);
                                            DataSheetLine.SetRange("Line No.");
                                            DataSheetLine.SetRange("Prod. Order Line No.");
                                        end;
                                        DataSheetLineDetailTemp.Reset;
                                        DataSheetLineDetailTemp.SetRange("Prod. Order Line No.", DataSheetLine."Prod. Order Line No.");
                                        DataSheetLineDetailTemp.SetRange("Data Element Code", DataSheetLine."Data Element Code");
                                        DataSheetLineDetailTemp.SetRange("Line No.", DataSheetLineTemp."Line No.");
                                        if DataSheetLineDetailTemp.Find('-') then
                                            repeat
                                                DataSheetLineDetail := DataSheetLineDetailTemp;
                                                DataSheetLineDetail."Data Sheet No." := DataSheetLine."Data Sheet No.";
                                                DataSheetLineDetail."Line No." := DataSheetLine."Line No.";
                                                for Cnt := 1 to DataSheetLine."Instance No." do begin
                                                    DataSheetLineDetail."Instance No." := Cnt;
                                                    DataSheetLineDetail."Alert Entry No. (Target)" := 0;
                                                    DataSheetLineDetail."Alert Entry No. (Missed)" := 0;
                                                    // Need to see if any alerts need to be generated
                                                    if DataSheetHeader2.Status = DataSheetHeader2.Status::"In Progress" then begin
                                                        DataSheetLine2.Get(DataSheetLineDetail."Data Sheet No.", DataSheetLineDetail."Prod. Order Line No.",
                                                          DataSheetLineDetail."Data Element Code", DataSheetLineDetail."Line No.", Cnt);
                                                        DataSheetLineDetail.SetAlert(DataSheetLine2);
                                                    end;
                                                    DataSheetLineDetail.Insert;
                                                end;
                                            until DataSheetLineDetailTemp.Next = 0;
                                    until DataSheetLine.Next = 0;

                                DataSheetLineTemp.Reset;
                                if DataSheetLineTemp.Find('-') then
                                    repeat
                                        DataSheetLine := DataSheetLineTemp;
                                        DataSheetLine."Data Sheet No." := DataSheetHeader2."No.";
                                        if DataSheetLineTemp."Data Element Code" <> '' then begin
                                            LineNo += 1;
                                            DataSheetLine."Line No." := LineNo;
                                        end;
                                        DataSheetLineDetailTemp.SetRange("Prod. Order Line No.", DataSheetLine."Prod. Order Line No.");
                                        DataSheetLineDetailTemp.SetRange("Data Element Code", DataSheetLine."Data Element Code");
                                        DataSheetLineDetailTemp.SetRange("Line No.", DataSheetLineTemp."Line No.");
                                        if DataSheetLineDetailTemp.Find('-') then
                                            repeat
                                                DataSheetLineDetail := DataSheetLineDetailTemp;
                                                DataSheetLineDetail."Data Sheet No." := DataSheetLine."Data Sheet No.";
                                                DataSheetLineDetail."Line No." := DataSheetLine."Line No.";
                                                DataSheetLineDetail."Instance No." := 1;
                                                DataSheetLineDetail.Insert;
                                            until DataSheetLineDetailTemp.Next = 0;
                                        if DataSheetHeader2.Status = DataSheetHeader2.Status::"In Progress" then
                                            DataSheetLine.SetSchedule(0DT, DataSheetHeader2."Start DateTime");
                                        DataSheetLine.Insert;
                                    until DataSheetLineTemp.Next = 0;

                                RecordRef.GetTable(DataSheetHeader2);
                                DataSheetRecordID := RecordRef.RecordId;
                                DataSheetLink.SetCurrentKey("Record ID");
                                DataSheetLink.SetRange("Record ID", DataSheetRecordID);
                                DataSheetLink.SetRange(Type, SourceLink.Type::Link);
                                DataSheetLink.SetRange(Company, CompanyName);
                                if DataSheetLink.FindSet(true, true) then
                                    repeat
                                        DataSheetLinkTemp.SetRange(URL1, DataSheetLink.URL1);
                                        if DataSheetLinkTemp.FindFirst then
                                            DataSheetLinkTemp.Delete
                                        else
                                            DataSheetLink.Delete;
                                    until DataSheetLink.Next = 0;
                                DataSheetLinkTemp.Reset;
                                if DataSheetLinkTemp.Find('-') then
                                    repeat
                                        DataSheetLink := DataSheetLinkTemp;
                                        DataSheetLink."Link ID" := 0;
                                        DataSheetLink."Record ID" := DataSheetRecordID;
                                        DataSheetLink.Created := CurrentDateTime;
                                        DataSheetLink.Insert;
                                    until DataSheetLinkTemp.Next = 0;
                            end;

                            DataSheetHeader2.Modify;
                        end else
                            if DataSheetHeader2."No." <> '' then
                                DataSheetHeader2.Delete(true);
                    end;
            until TempLocation.Next = 0;
    end;

    local procedure DataCollectionLinesExist(SourceID: Integer; SourceKey1: Code[20]; SourceKey2: Code[20]; SheetType: Integer): Boolean
    var
        DataCollectionLine: Record "Data Collection Line";
    begin
        DataCollectionLine.SetRange("Source ID", SourceID);
        DataCollectionLine.SetRange("Source Key 1", SourceKey1);
        DataCollectionLine.SetRange("Source Key 2", SourceKey2);
        DataCollectionLine.SetRange(Type, SheetType);
        DataCollectionLine.SetRange(Active, true);
        exit(not DataCollectionLine.IsEmpty);
    end;

    procedure CheckSalesHeaderModify(xSalesHeader: Record "Sales Header"; SalesHeader: Record "Sales Header")
    var
        DataSheetHeader: Record "Data Sheet Header";
    begin
        if (xSalesHeader."Sell-to Customer No." <> '') and
          (xSalesHeader."Sell-to Customer No." <> SalesHeader."Sell-to Customer No.")
        then begin
            DataSheetHeader.SetCurrentKey("Location Code", "Source ID", "Source Subtype", "Source No.");
            DataSheetHeader.SetRange("Source ID", DATABASE::"Sales Header");
            DataSheetHeader.SetRange("Source Subtype", xSalesHeader."Document Type");
            DataSheetHeader.SetRange("Source No.", xSalesHeader."No.");
            DataSheetHeader.SetRange("Document No.", '');
            if not DataSheetHeader.IsEmpty then
                Error(Text010);
        end;
    end;

    procedure CheckSalesLineModify(xSalesLine: Record "Sales Line"; SalesLine: Record "Sales Line")
    var
        DataSheetHeader: Record "Data Sheet Header";
    begin
        if xSalesLine."Location Code" <> SalesLine."Location Code" then begin
            DataSheetHeader.SetCurrentKey("Location Code", "Source ID", "Source Subtype", "Source No.");
            DataSheetHeader.SetRange("Location Code", xSalesLine."Location Code");
            DataSheetHeader.SetRange("Source ID", DATABASE::"Sales Header");
            DataSheetHeader.SetRange("Source Subtype", xSalesLine."Document Type");
            DataSheetHeader.SetRange("Source No.", xSalesLine."Document No.");
            DataSheetHeader.SetRange("Document No.", '');
            if not DataSheetHeader.IsEmpty then
                Error(Text010);
        end else
            if (xSalesLine.Type in [xSalesLine.Type::Item, xSalesLine.Type::Resource]) and
     ((xSalesLine.Type <> SalesLine.Type) or (xSalesLine."No." <> SalesLine."No."))
   then begin
                DataSheetHeader.SetCurrentKey("Location Code", "Source ID", "Source Subtype", "Source No.");
                DataSheetHeader.SetRange("Location Code", SalesLine."Location Code");
                DataSheetHeader.SetRange("Source ID", DATABASE::"Sales Header");
                DataSheetHeader.SetRange("Source Subtype", xSalesLine."Document Type");
                DataSheetHeader.SetRange("Source No.", xSalesLine."Document No.");
                DataSheetHeader.SetRange("Document No.", '');
                if not DataSheetHeader.IsEmpty then
                    Error(Text010);
            end;
    end;

    procedure CheckPurchHeaderModify(xPurchHeader: Record "Purchase Header"; PurchHeader: Record "Purchase Header")
    var
        DataSheetHeader: Record "Data Sheet Header";
    begin
        if (xPurchHeader."Buy-from Vendor No." <> '') and
          (xPurchHeader."Buy-from Vendor No." <> PurchHeader."Buy-from Vendor No.")
        then begin
            DataSheetHeader.SetCurrentKey("Location Code", "Source ID", "Source Subtype", "Source No.");
            DataSheetHeader.SetRange("Source ID", DATABASE::"Purchase Header");
            DataSheetHeader.SetRange("Source Subtype", xPurchHeader."Document Type");
            DataSheetHeader.SetRange("Source No.", xPurchHeader."No.");
            DataSheetHeader.SetRange("Document No.", '');
            if not DataSheetHeader.IsEmpty then
                Error(Text010);
        end;
    end;

    procedure CheckPurchLineModify(xPurchLine: Record "Purchase Line"; PurchLine: Record "Purchase Line")
    var
        DataSheetHeader: Record "Data Sheet Header";
    begin
        if xPurchLine."Location Code" <> PurchLine."Location Code" then begin
            DataSheetHeader.SetCurrentKey("Location Code", "Source ID", "Source Subtype", "Source No.");
            DataSheetHeader.SetRange("Location Code", xPurchLine."Location Code");
            DataSheetHeader.SetRange("Source ID", DATABASE::"Purchase Header");
            DataSheetHeader.SetRange("Source Subtype", xPurchLine."Document Type");
            DataSheetHeader.SetRange("Source No.", xPurchLine."Document No.");
            DataSheetHeader.SetRange("Document No.", '');
            if not DataSheetHeader.IsEmpty then
                Error(Text010);
        end else
            if (xPurchLine.Type = xPurchLine.Type::Item) and
     ((xPurchLine.Type <> PurchLine.Type) or (xPurchLine."No." <> PurchLine."No."))
   then begin
                DataSheetHeader.SetCurrentKey("Location Code", "Source ID", "Source Subtype", "Source No.");
                DataSheetHeader.SetRange("Location Code", PurchLine."Location Code");
                DataSheetHeader.SetRange("Source ID", DATABASE::"Purchase Header");
                DataSheetHeader.SetRange("Source Subtype", xPurchLine."Document Type");
                DataSheetHeader.SetRange("Source No.", xPurchLine."Document No.");
                DataSheetHeader.SetRange("Document No.", '');
                if not DataSheetHeader.IsEmpty then
                    Error(Text010);
            end;
    end;

    procedure CheckTransHeaderModify(xTransHeader: Record "Transfer Header"; TransHeader: Record "Transfer Header")
    var
        DataSheetHeader: Record "Data Sheet Header";
    begin
        if (xTransHeader."Transfer-from Code" <> '') and
          (xTransHeader."Transfer-from Code" <> TransHeader."Transfer-from Code")
        then begin
            DataSheetHeader.SetCurrentKey("Location Code", "Source ID", "Source Subtype", "Source No.");
            DataSheetHeader.SetRange("Location Code", xTransHeader."Transfer-from Code");
            DataSheetHeader.SetRange("Source ID", DATABASE::"Transfer Header");
            DataSheetHeader.SetRange("Source No.", xTransHeader."No.");
            DataSheetHeader.SetRange("Document No.", '');
            if not DataSheetHeader.IsEmpty then
                Error(Text010);
        end;
        if (xTransHeader."Transfer-to Code" <> '') and
          (xTransHeader."Transfer-to Code" <> TransHeader."Transfer-to Code")
        then begin
            DataSheetHeader.SetCurrentKey("Location Code", "Source ID", "Source Subtype", "Source No.");
            DataSheetHeader.SetRange("Location Code", xTransHeader."Transfer-to Code");
            DataSheetHeader.SetRange("Source ID", DATABASE::"Transfer Header");
            DataSheetHeader.SetRange("Source No.", xTransHeader."No.");
            DataSheetHeader.SetRange("Document No.", '');
            if not DataSheetHeader.IsEmpty then
                Error(Text010);
        end;
    end;

    procedure CheckTransLineModify(xTransLine: Record "Transfer Line"; TransLine: Record "Transfer Line")
    var
        DataSheetHeader: Record "Data Sheet Header";
    begin
        if (xTransLine.Type = xTransLine.Type::Item) and
          ((xTransLine.Type <> TransLine.Type) or (xTransLine."Item No." <> TransLine."Item No."))
        then begin
            DataSheetHeader.SetCurrentKey("Location Code", "Source ID", "Source Subtype", "Source No.");
            DataSheetHeader.SetFilter("Location Code", '%1|%2', xTransLine."Transfer-from Code", xTransLine."Transfer-to Code");
            DataSheetHeader.SetRange("Source ID", DATABASE::"Transfer Header");
            DataSheetHeader.SetRange("Source No.", xTransLine."Document No.");
            DataSheetHeader.SetRange("Document No.", '');
            if not DataSheetHeader.IsEmpty then
                Error(Text010);
        end;
    end;

    procedure CheckProdOrderLineModify(xProdOrderLine: Record "Prod. Order Line"; ProdOrderLine: Record "Prod. Order Line")
    var
        DataSheetHeader: Record "Data Sheet Header";
    begin
        if ((xProdOrderLine."Item No." <> '') and (xProdOrderLine."Item No." <> ProdOrderLine."Item No.")) or
          (xProdOrderLine."Location Code" <> ProdOrderLine."Location Code") or
          ((xProdOrderLine."Routing No." <> '') and
            ((xProdOrderLine."Routing No." <> ProdOrderLine."Routing No.") or
            (xProdOrderLine."Routing Version Code" <> ProdOrderLine."Routing Version Code"))) or
          ((xProdOrderLine."Equipment Code" <> '') and (xProdOrderLine."Equipment Code" <> ProdOrderLine."Equipment Code"))
        then begin
            DataSheetHeader.SetCurrentKey("Location Code", "Source ID", "Source Subtype", "Source No.");
            DataSheetHeader.SetRange("Location Code", xProdOrderLine."Location Code");
            DataSheetHeader.SetRange("Source ID", DATABASE::"Production Order");
            DataSheetHeader.SetRange("Source Subtype", xProdOrderLine.Status);
            DataSheetHeader.SetRange("Source No.", xProdOrderLine."Prod. Order No.");
            DataSheetHeader.SetRange("Document No.", '');
            if not DataSheetHeader.IsEmpty then
                Error(Text010);
        end;
    end;

    procedure CheckRoutingLineModify(xRoutingLine: Record "Prod. Order Routing Line"; RoutingLine: Record "Prod. Order Routing Line")
    var
        ProdOrderLine: Record "Prod. Order Line";
        DataSheetHeader: Record "Data Sheet Header";
    begin
        if (xRoutingLine."No." <> '') and
          ((xRoutingLine.Type <> RoutingLine.Type) or (xRoutingLine."No." <> RoutingLine."No."))
        then begin
            ProdOrderLine.SetRange(Status, xRoutingLine.Status);
            ProdOrderLine.SetRange("Prod. Order No.", xRoutingLine."Prod. Order No.");
            ProdOrderLine.SetRange("Routing No.", xRoutingLine."Routing No.");
            ProdOrderLine.SetRange("Routing Reference No.", xRoutingLine."Routing Reference No.");
            ProdOrderLine.FindFirst;

            DataSheetHeader.SetCurrentKey("Location Code", "Source ID", "Source Subtype", "Source No.");
            DataSheetHeader.SetRange("Location Code", ProdOrderLine."Location Code");
            DataSheetHeader.SetRange("Source ID", DATABASE::"Production Order");
            DataSheetHeader.SetRange("Source Subtype", ProdOrderLine.Status);
            DataSheetHeader.SetRange("Source No.", ProdOrderLine."Prod. Order No.");
            DataSheetHeader.SetRange("Document No.", '');
            if not DataSheetHeader.IsEmpty then
                Error(Text010);
        end;
    end;

    procedure DataSheetStatusChange(var DataSheetHeader: Record "Data Sheet Header")
    var
        DataSheetLine: Record "Data Sheet Line";
        DataSheetStatusChange: Page "Data Sheet Status Change";
    begin
        // P800130766
        if DataSheetHeader.Status = DataSheetHeader.Status::Complete then
            error(ErrStatusComplete, DataSheetHeader.FieldCaption(Status), DataSheetHeader.Status);
        // P800130766
        if DataSheetHeader.Status = DataSheetHeader.Status::"In Progress" then begin
            if DataSheetHeader."Document No." = '' then
                case DataSheetHeader.Type of
                    DataSheetHeader.Type::Shipping:
                        Error(Text007);
                    DataSheetHeader.Type::Receiving:
                        Error(Text008);
                    DataSheetHeader.Type::Production:
                        Error(Text009);
                end;

            if DataSheetHeader.Type = DataSheetHeader.Type::Production then begin
                DataSheetLine.SetRange("Data Sheet No.", DataSheetHeader."No.");
                DataSheetLine.SetFilter("Prod. Order Line No.", '>0');
                DataSheetLine.SetRange("Data Element Code", '');
                DataSheetLine.SetRange("Hide Line", false);
                DataSheetLine.SetRange("Stop Date", 0D);
                if DataSheetLine.FindFirst then
                    Error(Text006, DataSheetLine."Prod. Order Line No.");
            end;

            CheckOKToComplete(DataSheetHeader."No.", 0, 0DT);
        end;

        DataSheetStatusChange.Set(DataSheetHeader);
        if DataSheetStatusChange.RunModal = ACTION::Yes then begin
            DataSheetHeader.Status += 1;
            if DataSheetHeader.Status = DataSheetHeader.Status::"In Progress" then begin
                DataSheetStatusChange.GetDateTime(DataSheetHeader."Start Date", DataSheetHeader."Start Time", DataSheetHeader."Start DateTime");

                DataSheetLine.SetRange("Data Sheet No.", DataSheetHeader."No.");
                DataSheetLine.SetRange("Prod. Order Line No.", 0);
                DataSheetLine.SetRange("Instance No.", 1);
                DataSheetLine.SetRange(Recurrence, DataSheetLine.Recurrence::Scheduled);
                if DataSheetLine.FindSet(true, false) then
                    repeat
                        DataSheetLine.SetSchedule(0DT, DataSheetHeader."Start DateTime");
                        DataSheetLine.Modify(true);
                    until DataSheetLine.Next = 0;
            end else begin
                DataSheetStatusChange.GetDateTime(DataSheetHeader."End Date", DataSheetHeader."End Time", DataSheetHeader."End DateTime");

                if DataSheetHeader.Type = DataSheetHeader.Type::Production then
                    UpdateProdOrderActualDateTime(DataSheetHeader);

                DataSheetLine.SetRange("Data Sheet No.", DataSheetHeader."No.");
                DataSheetLine.SetRange("Prod. Order Line No.", 0);
                DataSheetLine.SetFilter("Data Element Code", '<>%1', '');
                DataSheetLine.SetRange(Result, '');
                DataSheetLine.DeleteAll(true);
            end;
        end;
    end;

    procedure CheckOKToComplete(DataSheetNo: Code[20]; ProdOrderLineNo: Integer; StopDateTime: DateTime)
    var
        DataSheetLine: Record "Data Sheet Line";
    begin
        DataSheetLine.SetRange("Data Sheet No.", DataSheetNo);
        DataSheetLine.SetRange("Prod. Order Line No.", ProdOrderLineNo);
        DataSheetLine.SetRange("Instance No.", 1);
        DataSheetLine.SetRange(Result, '');
        if DataSheetLine.FindFirst then
            Error(Text004, DataSheetLine."Data Element Code");

        if StopDateTime <> 0DT then begin
            DataSheetLine.Reset;
            DataSheetLine.SetRange("Data Sheet No.", DataSheetNo);
            DataSheetLine.SetRange("Prod. Order Line No.", ProdOrderLineNo);
            DataSheetLine.SetFilter(Result, '=%1', '');
            DataSheetLine.SetRange(Recurrence, DataSheetLine.Recurrence::Scheduled);
            DataSheetLine.SetFilter("Schedule DateTime", '<=%1', StopDateTime);
            if DataSheetLine.FindFirst then
                Error(Text004, DataSheetLine."Data Element Code");

            DataSheetLine.Reset;
            DataSheetLine.SetRange("Data Sheet No.", DataSheetNo);
            DataSheetLine.SetRange("Prod. Order Line No.", ProdOrderLineNo);
            DataSheetLine.SetFilter(Result, '<>%1', '');
            DataSheetLine.SetFilter("Actual DateTime", '>%1', StopDateTime);
            if DataSheetLine.FindFirst then
                Error(Text005, DataSheetLine."Data Element Code");
        end;
    end;

    procedure UpdateProdOrderActualDateTime(DataSheetHeader: Record "Data Sheet Header")
    var
        ProdOrderLine: Record "Prod. Order Line";
        DataSheetLine: Record "Data Sheet Line";
    begin
        ProdOrderLine.SetRange(Status, ProdOrderLine.Status::Finished);
        ProdOrderLine.SetRange("Prod. Order No.", DataSheetHeader."Document No.");
        if ProdOrderLine.FindSet(true) then begin
            DataSheetLine.SetRange("Data Sheet No.", DataSheetHeader."No.");
            DataSheetLine.SetRange("Data Element Code", '');
            repeat
                DataSheetLine.SetRange("Prod. Order Line No.", ProdOrderLine."Line No.");
                if DataSheetLine.FindFirst then begin
                    ProdOrderLine."Actual Start Date" := DataSheetLine."Actual Date";
                    ProdOrderLine."Actual Start Time" := DataSheetLine."Actual Time";
                    ProdOrderLine."Actual Stop Date" := DataSheetLine."Stop Date";
                    ProdOrderLine."Actual Stop Time" := DataSheetLine."Stop Time";
                end else begin
                    ProdOrderLine."Actual Start Date" := DataSheetHeader."Start Date";
                    ProdOrderLine."Actual Start Time" := DataSheetHeader."Start Time";
                    ProdOrderLine."Actual Stop Date" := DataSheetHeader."End Date";
                    ProdOrderLine."Actual Stop Time" := DataSheetHeader."End Time";
                end;
                ProdOrderLine.Modify;
            until ProdOrderLine.Next = 0;
        end;
    end;

    procedure ProdOrderLineStartStop(var DataSheetLine: Record "Data Sheet Line"): Boolean
    var
        DataSheetLine2: Record "Data Sheet Line";
        ProdOrderLine: Page "Prod. Order Line Start/Stop";
    begin
        if DataSheetLine."Actual DateTime" <> 0DT then
            CheckOKToComplete(DataSheetLine."Data Sheet No.", DataSheetLine."Prod. Order Line No.", 0DT);

        ProdOrderLine.SetData(DataSheetLine);
        // P8001149
        // IF ProdOrderLine.RUNMODAL = ACTION::OK THEN BEGIN
        ProdOrderLine.LookupMode(true);
        if ProdOrderLine.RunModal = ACTION::LookupOK then begin
            // P8001149
            if DataSheetLine."Actual DateTime" = 0DT then begin
                ProdOrderLine.GetDateTime(DataSheetLine."Actual Date", DataSheetLine."Actual Time", DataSheetLine."Actual DateTime");

                DataSheetLine2.SetRange("Data Sheet No.", DataSheetLine."Data Sheet No.");
                DataSheetLine2.SetRange("Prod. Order Line No.", DataSheetLine."Prod. Order Line No.");
                DataSheetLine2.SetRange("Instance No.", 1);
                DataSheetLine2.SetRange(Recurrence, DataSheetLine.Recurrence::Scheduled);
                if DataSheetLine2.FindSet(true, false) then
                    repeat
                        DataSheetLine2.SetSchedule(0DT, DataSheetLine."Actual DateTime");
                        DataSheetLine2.Modify(true);
                    until DataSheetLine2.Next = 0;
                exit(true);
            end else begin
                ProdOrderLine.GetDateTime(DataSheetLine."Stop Date", DataSheetLine."Stop Time", DataSheetLine."Stop DateTime");

                DataSheetLine2.SetRange("Data Sheet No.", DataSheetLine."Data Sheet No.");
                DataSheetLine2.SetRange("Prod. Order Line No.", DataSheetLine."Prod. Order Line No.");
                DataSheetLine2.SetFilter("Data Element Code", '<>%1', '');
                DataSheetLine2.SetRange(Result, '');
                DataSheetLine2.DeleteAll(true);
                exit(true);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterRenameEvent', '', true, false)]
    local procedure Item_OnAfterRename(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    var
        DataCollectionLine: Record "Data Collection Line";
        DataCollectionLine2: Record "Data Collection Line";
    begin
        // P80079674
        RenameDataCollectionLine(DATABASE::Item, xRec."No.", Rec."No.", '', '');
    end;

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnAfterRenameEvent', '', true, false)]
    local procedure Location_OnAfterRename(var Rec: Record Location; var xRec: Record Location; RunTrigger: Boolean)
    begin
        // P80079674
        RenameDataCollectionLine(DATABASE::Location, xRec.Code, Rec.Code, '', '');
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterRenameEvent', '', true, false)]
    local procedure Customer_OnAfterRename(var Rec: Record Customer; var xRec: Record Customer; RunTrigger: Boolean)
    begin
        // P80079674
        RenameDataCollectionLine(DATABASE::Customer, xRec."No.", Rec."No.", '', '');
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterRenameEvent', '', true, false)]
    local procedure Vendor_OnAfterRename(var Rec: Record Vendor; var xRec: Record Vendor; RunTrigger: Boolean)
    begin
        // P80079674
        RenameDataCollectionLine(DATABASE::Vendor, xRec."No.", Rec."No.", '', '');
    end;

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnAfterRenameEvent', '', true, false)]
    local procedure Resource_OnAfterRename(var Rec: Record Resource; var xRec: Record Resource; RunTrigger: Boolean)
    begin
        // P80079674
        RenameDataCollectionLine(DATABASE::Resource, xRec."No.", Rec."No.", '', '');
    end;

    [EventSubscriber(ObjectType::Table, Database::Zone, 'OnAfterRenameEvent', '', true, false)]
    local procedure Zone_OnAfterRename(var Rec: Record Zone; var xRec: Record Zone; RunTrigger: Boolean)
    begin
        // P80079674
        RenameDataCollectionLine(DATABASE::Zone, xRec."Location Code", Rec."Location Code", xRec.Code, Rec.Code);
    end;

    [EventSubscriber(ObjectType::Table, Database::Bin, 'OnAfterRenameEvent', '', true, false)]
    local procedure Bin_OnAfterRename(var Rec: Record Bin; var xRec: Record Bin; RunTrigger: Boolean)
    begin
        // P80079674
        RenameDataCollectionLine(DATABASE::Bin, xRec."Location Code", Rec."Location Code", xRec.Code, Rec.Code);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Work Center", 'OnAfterRenameEvent', '', true, false)]
    local procedure WorkCenter_OnAfterRename(var Rec: Record "Work Center"; var xRec: Record "Work Center"; RunTrigger: Boolean)
    begin
        // P80079674
        RenameDataCollectionLine(DATABASE::"Work Center", xRec."No.", Rec."No.", '', '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Machine Center", 'OnAfterRenameEvent', '', true, false)]
    local procedure MachineCenter_OnAfterRename(var Rec: Record "Machine Center"; var xRec: Record "Machine Center"; RunTrigger: Boolean)
    begin
        // P80079674
        RenameDataCollectionLine(DATABASE::"Machine Center", xRec."No.", Rec."No.", '', '');
    end;

    [EventSubscriber(ObjectType::Table, Database::Asset, 'OnAfterRenameEvent', '', true, false)]
    local procedure Asset_OnAfterRename(var Rec: Record Asset; var xRec: Record Asset; RunTrigger: Boolean)
    begin
        // P80079674
        RenameDataCollectionLine(DATABASE::Asset, xRec."No.", Rec."No.", '', '');
    end;

    local procedure RenameDataCollectionLine(SourceID: Integer; xSourceKey1: Code[20]; SourceKey1: Code[20]; xSourceKey2: Code[20]; SourceKey2: Code[20])
    var
        DataCollectionLine: Record "Data Collection Line";
        DataCollectionLine2: Record "Data Collection Line";
        CommentLine: Record "Data Collection Comment";
        CommentLine2: Record "Data Collection Comment";
    begin
        // P80079674
        CommentLine.SetRange("Source ID", SourceID);
        CommentLine.SetRange("Source Key 1", xSourceKey1);
        CommentLine.SetRange("Source Key 2", xSourceKey2);
        if CommentLine.FindSet(true, true) then
            repeat
                CommentLine2 := CommentLine;
                CommentLine2."Source Key 1" := SourceKey1;
                CommentLine2."Source Key 2" := SourceKey2;
                CommentLine2.Insert;
                CommentLine.Delete;
            until CommentLine.Next = 0;

        DataCollectionLine.SetRange("Source ID", SourceID);
        DataCollectionLine.SetRange("Source Key 1", xSourceKey1);
        DataCollectionLine.SetRange("Source Key 2", xSourceKey2);
        if DataCollectionLine.FindSet(true, true) then
            repeat
                DataCollectionLine2 := DataCollectionLine;
                DataCollectionLine2."Source Key 1" := SourceKey1;
                DataCollectionLine2."Source Key 2" := SourceKey2;
                DataCollectionLine2.Insert;
                DataCollectionLine.Delete;
            until DataCollectionLine.Next = 0;
        // P80079674
    end;

    procedure CopySampleFields(DataCollectionTemplateLine: Record "Data Collection Template Line"; var DataCollectionLine: Record "Data Collection Line")
    var
        Item: Record "Item";
        UnitofMeasure: Record "Unit of Measure";
        UnitofMeasure2: Record "Unit of Measure";
        ItemUnitofMeasure: Record "Item Unit of Measure";
    begin
        // P800122712
        DataCollectionLine."Sample Quantity" := DataCollectionTemplateLine."Sample Quantity";
        DataCollectionLine."Sample Unit of Measure Code" := DataCollectionTemplateLine."Sample Unit of Measure Code";
        DataCollectionLine."Combine Samples" := DataCollectionTemplateLine."Combine Samples";
        if DataCollectionTemplateLine."Sample Unit of Measure Code" <> '' then begin
            if ItemUnitofMeasure.Get(DataCollectionLine."Source Key 1", DataCollectionTemplateLine."Sample Unit of Measure Code") then begin
                Item.Get(DataCollectionLine."Source Key 1");
                if Item."Alternate Unit of Measure" <> '' then begin
                    if Item."Alternate Unit of Measure" = DataCollectionTemplateLine."Sample Unit of Measure Code" then
                        DataCollectionLine."Sample Unit of Measure Code" := ''
                    else begin
                        UnitofMeasure.Get(DataCollectionTemplateLine."Sample Unit of Measure Code");
                        if UnitofMeasure2.Get(Item."Alternate Unit of Measure") then
                            if UnitofMeasure.Type = UnitofMeasure2.Type then
                                DataCollectionLine."Sample Unit of Measure Code" := '';
                    end;
                end;
            end else
                DataCollectionLine."Sample Unit of Measure Code" := '';

            DataCollectionLine.Validate("Sample Unit of Measure Code");
        end;
    end;
}

