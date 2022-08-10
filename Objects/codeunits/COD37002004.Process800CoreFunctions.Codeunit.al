codeunit 37002004 "Process 800 Core Functions"
{
    // PR3.61
    //   Add Functions
    //     CheckSalesLineFieldEditable
    //     CheckTransferLineFieldEditable
    // 
    // PR3.61.01
    //   Add function CreateCMWriteoff
    // 
    // PR3.61.02
    //   Fix problem with UpdateSalesDocFlag
    // 
    // PR3.70
    //   Remove Bin Code from call to create reservation entry
    // 
    // PR3.70.02
    //   UpdateSalesDocFlag was comparing Value Entry posting date with Document posting date, should be
    //   comparing with the posting date on the value entry's associated item ledger entry
    // 
    // PR4.00.01
    // P8000269A, VerticalSoft, Jack Reynolds, 05 DEC 05
    //   Functions to add and copy ledger entry comment lines
    // 
    // PR4.00.02
    // P8000303A, VerticalSoft, Jack Reynolds, 24 FEB 06
    //   CreateCMWriteoff - remove code to set dimensions
    // 
    // PR4.00.03
    // P8000325A, VerticalSoft, Jack Reynolds, 01 MAY 06
    //   CreateCMWriteoff - modify call to CreateReservEntry for new parameter for expiration date
    // 
    // PR4.00.06
    // P8000481A, VerticalSoft, Jack Reynolds, 31 MAY 07
    //   Fix problem with combine shipments
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Don Bresee, 12 JUN 07
    //   Eliminate parameter for Expiration Date
    // 
    // PRW16.00.06
    // P8001034, Columbus IT, Jack Reynolds, 10 FEB 12
    //   Move Warehouse Employee functions
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.00.01
    // P8001206, Columbus IT, Jack Reynolds, 11 SEP 13
    //   Fix problem with Applies-to Entry for credit memo writeoffs
    // 
    // P8001373, To-Increase, Dayakar Battini, 11 Feb 15
    //   Support containers for purchase returns.
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.01
    // P80062661, To-Increase, Jack Reynolds, 25 JUL 18
    //   SSCC
    // 
    // P80063746, To-Increase, Jack Reynolds, 29 AUG 18
    //   Remove length restriction on return value for GetEmpLocationFilter
    // 
    // PRW111.00.03
    // P80075420, To-Increase, Jack Reynolds, 08 JUL 19
    //   Problem losing tracking when using containers and specifying alt quantity to handle
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    //
    // PRW118.01
    // P800127049, To Increase, Jack Reynolds, 23 AUG 21
    //   Support for Inventory documents

    Permissions = TableData "Sales Invoice Header" = m,
                  TableData "Sales Cr.Memo Header" = m;

    trigger OnRun()
    begin
    end;

    var
        Text001: Label 'Not authorized for %1 ''%2''.';

    procedure UpdateSalesDocFlag(var Rec: Record "Value Entry")
    var
        SalesInvoice: Record "Sales Invoice Header";
        SalesCrMemo: Record "Sales Cr.Memo Header";
        ItemLedger: Record "Item Ledger Entry";
        Invoice: Boolean;
        FoundFlag: Boolean;
        cnt: Integer;
    begin
        // UpdateSalesDocFlag
        with Rec do begin
            if ("Item Ledger Entry Type" <> "Item Ledger Entry Type"::Sale) or
               "Expected Cost" or // PR3.61.02
               ("Source Type" <> "Source Type"::Customer)
            then
                exit;
            ItemLedger.Get("Item Ledger Entry No."); // PR3.70.02
            Invoice := "Valued Quantity" < 0; // check invoice first // PR3.61.02
            repeat
                cnt += 1;
                if Invoice then
                    if SalesInvoice.Get("Document No.")                                          // P8000481A
                                                                                                 //(ItemLedger."Posting Date" = SalesInvoice."Posting Date") AND // PR3.70.02, P8000481A
                                                                                                 //("Source No." = SalesInvoice."Sell-to Customer No.")                     // P8000481A
                    then begin
                        SalesInvoice."Cost is Adjusted" := false;
                        SalesInvoice.Modify;
                        FoundFlag := true;
                    end;
                if not Invoice then
                    if SalesCrMemo.Get("Document No.")                                          // P8000481A
                                                                                                //(ItemLedger."Posting Date" = SalesCrMemo."Posting Date") AND // PR3.70.02, P8000481A
                                                                                                //("Source No." = SalesCrMemo."Sell-to Customer No.")                     // P8000481A
                    then begin
                        SalesCrMemo."Cost is Adjusted" := false;
                        SalesCrMemo.Modify;
                        FoundFlag := true;
                    end;
                Invoice := not Invoice;
            until FoundFlag or (cnt = 2); // PR3.61.02
        end;
    end;

    procedure CheckSalesLineFieldEditable(SalesLine: Record "Sales Line"; FldNo: Integer; CurrFieldNo: Integer)
    var
        Text001: Label 'may not be edited';
        ContainerType: Record "Container Type";
    begin
        // CheckSalesLineFieldEditable
        with SalesLine do begin
            if (FldNo <> CurrFieldNo) or
              ((Type <> Type::FOODContainer) and ("Container Line No." = 0))
            then
                exit;
            case FldNo of
                FieldNo("Location Code"):
                    if "Container Line No." <> 0 then
                        FieldError("Location Code", Text001);
                FieldNo(Quantity):
                    if "Document Type" = "Document Type"::Order then // P8001324
                        FieldError(Quantity, Text001);                  // P8001324
                FieldNo("Quantity (Base)"):
                    FieldError("Quantity (Base)", Text001);
                FieldNo("Qty. to Ship"):
                    FieldError("Qty. to Ship", Text001);
                FieldNo("Qty. to Ship (Base)"):
                    FieldError("Qty. to Ship (Base)", Text001);
                FieldNo("Qty. to Ship (Alt.)"):
                    FieldError("Qty. to Ship (Alt.)", Text001);
                FieldNo("Unit Price"):
                    if Type = Type::FOODContainer then begin
                        ContainerType.SetRange("Container Item No.", "No."); // P8001290
                        if ContainerType.FindFirst then // P8001290
                            if ContainerType."Container Sales Processing" <> ContainerType."Container Sales Processing"::Adjustment then // P8001290
                                FieldError("Unit Price", Text001);
                    end;
                FieldNo("Unit of Measure Code"):
                    FieldError("Unit of Measure Code", Text001);
            end;
        end;
    end;

    procedure CheckTransferLineFieldEditable(TransferLine: Record "Transfer Line"; FldNo: Integer; CurrFieldNo: Integer)
    var
        Text001: Label 'may not be edited';
        Item: Record Item;
    begin
        // CheckTransferLineFieldEditable
        with TransferLine do begin
            if (FldNo <> CurrFieldNo) or (Type <> Type::Container) then
                exit;
            case FldNo of
                FieldNo(Quantity):
                    FieldError(Quantity, Text001);
                FieldNo("Quantity (Base)"):
                    FieldError("Quantity (Base)", Text001);
                FieldNo("Qty. to Ship"):
                    FieldError("Qty. to Ship", Text001);
                FieldNo("Qty. to Ship (Base)"):
                    FieldError("Qty. to Ship (Base)", Text001);
                FieldNo("Qty. to Ship (Alt.)"):
                    FieldError("Qty. to Ship (Alt.)", Text001);
                FieldNo("Qty. to Receive"):
                    FieldError("Qty. to Receive", Text001);
                FieldNo("Qty. to Receive (Base)"):
                    FieldError("Qty. to Receive (Base)", Text001);
                FieldNo("Qty. to Receive (Alt.)"):
                    FieldError("Qty. to Receive (Alt.)", Text001);
                FieldNo("Unit of Measure Code"):
                    FieldError("Unit of Measure Code", Text001);
            end;
        end;
    end;

    procedure CreateCMWriteoff(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesCrMemoLine: Record "Sales Cr.Memo Line"; ItemLedgerEntryNo: Integer; SrcCode: Code[10]; WriteoffResponsibility: Integer; var ItemJnlLine: Record "Item Journal Line")
    var
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        AltQtyLine: Record "Alternate Quantity Line";
        AltQtyEntry: Record "Alternate Quantity Entry";
        AltQtyMgt: Codeunit "Alt. Qty. Management";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        LineNo: Integer;
    begin
        // CreateCMWriteoff
        // PR3.61.01 Begin
        // P8000303A - remove TempJnlLineDim as parameter
        Item.Get(SalesCrMemoLine."No.");
        ItemLedgerEntry.Get(ItemLedgerEntryNo);

        ItemJnlLine.Init;
        ItemJnlLine.Validate("Posting Date", SalesCrMemoHeader."Posting Date");
        ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Negative Adjmt.");
        ItemJnlLine.Validate("Document No.", SalesCrMemoHeader."No.");
        ItemJnlLine.Validate("Item No.", SalesCrMemoLine."No.");
        ItemJnlLine.Validate("Variant Code", SalesCrMemoLine."Variant Code");
        ItemJnlLine.Validate("Location Code", SalesCrMemoLine."Location Code");
        ItemJnlLine.Validate("Source Code", SrcCode);
        ItemJnlLine.Validate(Quantity, ItemLedgerEntry.Quantity);
        if (ItemLedgerEntry."Lot No." = '') and (ItemLedgerEntry."Serial No." = '') then // P8001206
            ItemJnlLine.Validate("Applies-to Entry", ItemLedgerEntryNo);
        ItemJnlLine."Writeoff Responsibility" := SalesCrMemoLine."Writeoff Responsibility";

        AltQtyEntry.SetRange("Table No.", DATABASE::"Item Ledger Entry");
        AltQtyEntry.SetRange("Source Line No.", ItemLedgerEntryNo);
        if AltQtyEntry.Find('-') then begin
            AltQtyMgt.StartItemJnlAltQtyLine(ItemJnlLine);
            ItemJnlLine."Quantity (Alt.)" := Abs(ItemLedgerEntry."Quantity (Alt.)");
            ItemJnlLine."Invoiced Qty. (Alt.)" := Abs(ItemLedgerEntry."Quantity (Alt.)");
            repeat
                LineNo += 10000;
                AltQtyMgt.CreateAltQtyLine(AltQtyLine, ItemJnlLine."Alt. Qty. Transaction No.", LineNo,
                  DATABASE::"Item Journal Line", 0, '', '', '', 0);
                AltQtyLine."Lot No." := AltQtyEntry."Lot No.";
                AltQtyLine."Serial No." := AltQtyEntry."Serial No.";
                AltQtyLine."Quantity (Base)" := Abs(AltQtyEntry."Quantity (Base)");
                AltQtyLine.Quantity := AltQtyLine."Quantity (Base)";
                AltQtyLine."Invoiced Qty. (Base)" := AltQtyLine."Quantity (Base)";
                AltQtyLine."Quantity (Alt.)" := Abs(AltQtyEntry."Quantity (Alt.)");
                AltQtyLine."Invoiced Qty. (Alt.)" := Abs(AltQtyEntry."Quantity (Alt.)");
                AltQtyLine.Modify;
            until AltQtyEntry.Next = 0;
        end;

        if (ItemLedgerEntry."Lot No." <> '') or (ItemLedgerEntry."Serial No." <> '') then begin
            CreateReservEntry.CreateReservEntryFor(
              DATABASE::"Item Journal Line", ItemJnlLine."Entry Type", '', '', 0, 0,
              ItemJnlLine."Qty. per Unit of Measure", ItemJnlLine.Quantity, ItemJnlLine."Quantity (Base)", // P8001132
              ItemLedgerEntry."Serial No.", ItemLedgerEntry."Lot No."); // P8000325A, P8000466A
            CreateReservEntry.SetApplyToEntryNo(ItemLedgerEntryNo); // P8001206
            CreateReservEntry.AddAltQtyData(-ItemJnlLine."Quantity (Alt.)");
            CreateReservEntry.CreateEntry(ItemJnlLine."Item No.", ItemJnlLine."Variant Code", ItemJnlLine."Location Code", // PR3.70
              ItemJnlLine.Description, 0D, ItemJnlLine."Posting Date", 0, 3);
        end;

        /*P8000303A
        TableID[1] := DATABASE::Item;
        No[1] := ItemJnlLine."Item No.";
        DimMgt.GetDefaultDim(
          TableID,No,ItemJnlLine."Source Code",ItemJnlLine."Shortcut Dimension 1 Code",ItemJnlLine."Shortcut Dimension 2 Code");
        DimMgt.UpdateTempJnlLineDefaultDim(
          DATABASE::"Item Journal Line",
          ItemJnlLine."Journal Template Name",ItemJnlLine."Journal Batch Name",ItemJnlLine."Line No.",0,
          ItemJnlLine."Shortcut Dimension 1 Code",ItemJnlLine."Shortcut Dimension 2 Code",TempJnlLineDim);
        P8000303A*/
        // PR3.61.01 End

    end;

    procedure AddLedgerComment(LedgerEntryComment: Record "Ledger Entry Comment Line")
    var
        LedgerEntryComment2: Record "Ledger Entry Comment Line";
    begin
        // P8000269A
        LedgerEntryComment2.LockTable;
        LedgerEntryComment2.SetRange("Table ID", LedgerEntryComment."Table ID");
        LedgerEntryComment2.SetRange("Entry No.", LedgerEntryComment."Entry No.");
        if LedgerEntryComment2.Find('+') then
            LedgerEntryComment."Line No." := LedgerEntryComment2."Line No." + 10000
        else
            LedgerEntryComment."Line No." := 10000;
        LedgerEntryComment.Insert;
    end;

    procedure CopyLedgerComments(FromTableID: Integer; FromEntryNo: Integer; ToTableID: Integer; ToEntryNo: Integer)
    var
        LedgerEntryComment: Record "Ledger Entry Comment Line";
        LedgerEntryComment2: Record "Ledger Entry Comment Line";
    begin
        // P8000269A
        LedgerEntryComment.SetRange("Table ID", FromTableID);
        LedgerEntryComment.SetRange("Entry No.", FromEntryNo);
        if LedgerEntryComment.Find('-') then begin
            LedgerEntryComment2.LockTable;
            LedgerEntryComment2.SetRange("Table ID", ToTableID);
            LedgerEntryComment2.SetRange("Entry No.", ToEntryNo);
            if LedgerEntryComment2.Find('+') then;
            LedgerEntryComment2."Table ID" := ToTableID;
            LedgerEntryComment2."Entry No." := ToEntryNo;
            repeat
                LedgerEntryComment2."Line No." += 10000;
                LedgerEntryComment2.Date := LedgerEntryComment.Date;
                LedgerEntryComment2.Code := LedgerEntryComment.Code;
                LedgerEntryComment2.Comment := LedgerEntryComment.Comment;
                LedgerEntryComment2.Insert;
            until LedgerEntryComment.Next = 0;
        end;
    end;

    procedure GetDefaultEmpLocation(): Code[10]
    var
        WhseEmp: Record "Warehouse Employee";
    begin
        // P8001034
        WhseEmp.SetRange("User ID", UserId);
        WhseEmp.SetRange(Default, true);
        if WhseEmp.Find('-') then
            exit(WhseEmp."Location Code");
    end;

    procedure ValidateEmpLocation(LocCode: Code[10])
    var
        Location: Record Location;
        WhseEmp: Record "Warehouse Employee";
    begin
        // P8001034
        if LocCode = '' then
            exit;

        WhseEmp.SetRange("User ID", UserId);
        if not WhseEmp.Find('-') then
            exit;

        if WhseEmp.Get(UserId, LocCode) then
            exit;

        Error(Text001, Location.TableCaption, LocCode);
    end;

    procedure LookupEmpLocation(var Text: Text[1024]): Boolean
    var
        Location: Record Location;
        LocationList: Page "Location List";
    begin
        // P8001034
        Location.FilterGroup(9);
        Location.SetFilter(Code, GetEmpLocationFilter);
        Location.SetRange("Use As In-Transit", false);
        Location.FilterGroup(0);

        LocationList.LookupMode(true);
        LocationList.SetTableView(Location);
        if LocationList.RunModal = ACTION::LookupOK then begin
            LocationList.GetRecord(Location);
            Text := Location.Code;
            exit(true);
        end else
            exit(false);
    end;

    procedure GetEmpLocationFilter() LocFilter: Text
    var
        WhseEmp: Record "Warehouse Employee";
    begin
        // P8001034
        // P80063746 - remove lenght restriction on return value
        WhseEmp.SetRange("User ID", UserId);
        if not WhseEmp.Find('-') then
            exit('')
        else begin
            repeat
                LocFilter := LocFilter + '|';
                if WhseEmp."Location Code" = '' then
                    LocFilter := LocFilter + ''''''
                else
                    LocFilter := LocFilter + WhseEmp."Location Code";
            until WhseEmp.Next = 0;
            LocFilter := CopyStr(LocFilter, 2);
        end;
    end;

    procedure CheckPurchaseLineFieldEditable(PurchLine: Record "Purchase Line"; FldNo: Integer; CurrFieldNo: Integer)
    var
        Text001: Label 'may not be edited';
        ContainerType: Record "Container Type";
    begin
        //P8001373
        with PurchLine do begin
            if (FldNo <> CurrFieldNo) or (Type <> Type::FOODContainer) then
                exit;
            case FldNo of
                FieldNo(Quantity):
                    if "Document Type" = "Document Type"::"Return Order" then // P8001324
                        FieldError(Quantity, Text001);                           // P8001324
                FieldNo("Quantity (Base)"):
                    FieldError("Quantity (Base)", Text001);
                FieldNo("Return Qty. to Ship"):
                    FieldError("Return Qty. to Ship", Text001);
                FieldNo("Return Qty. to Ship (Base)"):
                    FieldError("Return Qty. to Ship (Base)", Text001);
                FieldNo("Return Qty. to Ship (Alt.)"):
                    FieldError("Return Qty. to Ship (Alt.)", Text001);
                FieldNo("Direct Unit Cost"):
                    if Type = Type::FOODContainer then begin
                        ContainerType.SetRange("Container Item No.", "No.");
                        if ContainerType.FindFirst then
                            if ContainerType."Container Purchase Processing" <> ContainerType."Container Purchase Processing"::Adjustment then
                                FieldError("Direct Unit Cost", Text001);
                    end;
                FieldNo("Unit of Measure Code"):
                    FieldError("Unit of Measure Code", Text001);
            end;
        end;
        //P8001373
    end;

    procedure GetLineFilterValues(DocumentLine: Variant; Direction: Integer; var SourceType: Integer; var SourceSubType: Integer; var SourceID: Code[20]; var SourceBatchName: Code[10]; var SourceRefNo: Integer)
    var
        DocumentLineRecRef: RecordRef;
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        ItemJournalLine: Record "Item Journal Line";
        InvtDocLine: Record "Invt. Document Line";
        TransferLine: Record "Transfer Line";
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        ContainerQtybyDocLine: Query "Container Qty. by Doc. Line 2";
    begin
        // P80075420
        DocumentLineRecRef.GetTable(DocumentLine);
        SourceType := DocumentLineRecRef.Number;
        SourceBatchName := '';
        case DocumentLineRecRef.Number of
            DATABASE::"Sales Line":
                begin
                    SalesLine := DocumentLine;
                    SourceSubType := SalesLine."Document Type";
                    SourceID := SalesLine."Document No.";
                    SourceRefNo := SalesLine."Line No.";
                end;
            DATABASE::"Purchase Line":
                begin
                    PurchaseLine := DocumentLine;
                    SourceSubType := PurchaseLine."Document Type";
                    SourceID := PurchaseLine."Document No.";
                    SourceRefNo := PurchaseLine."Line No.";
                end;
            DATABASE::"Item Journal Line":
                begin
                    ItemJournalLine := DocumentLine;
                    SourceSubType := 0;
                    SourceID := ItemJournalLine."Journal Template Name";
                    SourceBatchName := ItemJournalLine."Journal Batch Name";
                    SourceRefNo := ItemJournalLine."Line No.";
                end;
            // P800127049
            DATABASE::"Invt. Document Line":
                begin
                    InvtDocLine := DocumentLine;
                    SourceSubType := InvtDocLine."Document Type".AsInteger();
                    SourceID := InvtDocLine."Document No.";
                    SourceBatchName := '';
                    SourceRefNo := InvtDocLine."Line No.";
                end;
            DATABASE::"Transfer Line":
                begin
                    TransferLine := DocumentLine;
                    SourceSubType := Direction;
                    SourceID := TransferLine."Document No.";
                    SourceRefNo := TransferLine."Line No.";
                end;
            DATABASE::"Warehouse Receipt Line":
                begin
                    WarehouseReceiptLine := DocumentLine;
                    SourceType := WarehouseReceiptLine."Source Type";
                    SourceSubType := WarehouseReceiptLine."Source Subtype";
                    SourceID := WarehouseReceiptLine."Source No.";
                    SourceRefNo := WarehouseReceiptLine."Source Line No.";
                end;
            DATABASE::"Warehouse Shipment Line":
                begin
                    WarehouseShipmentLine := DocumentLine;
                    SourceType := WarehouseShipmentLine."Source Type";
                    SourceSubType := WarehouseShipmentLine."Source Subtype";
                    SourceID := WarehouseShipmentLine."Source No.";
                    SourceRefNo := WarehouseShipmentLine."Source Line No.";
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', true, false)]
    local procedure CompanyInitialize_OnCompanyInitialize()
    begin
        // P80066030
        InitializeP800ForCompany(CompanyName);
    end;

    procedure InitializeP800ForExistingCompanies()
    var
        Company: Record Company;
    begin
        // P8001199, P80066030
        if Company.FindSet then
            repeat
                InitializeP800ForCompany(Company.Name);
            until Company.Next = 0;
    end;

    local procedure InitializeP800ForCompany(CompName: Text[30])
    var
        SourceCodeSetup: Record "Source Code Setup";
        SourceCode: Record "Source Code";
        ReportSelections: Record "Report Selections";
    begin
        // P80066030
        if CompName <> CompanyName then begin
            SourceCodeSetup.ChangeCompany(CompName);
            SourceCode.ChangeCompany(CompName);
            ReportSelections.ChangeCompany(CompName);
        end;

        SourceCodeSetup.Get;
        OnInitializeP800(CompName, SourceCodeSetup, SourceCode, ReportSelections);
        SourceCodeSetup.Modify;
    end;

    procedure InsertSourceCode(var SourceCode: Record "Source Code"; var SourceCodeDefCode: Code[10]; "Code": Code[10]; Description: Text[100])
    begin
        // P80066030
        SourceCodeDefCode := Code;

        SourceCode.Init;
        SourceCode.Code := Code;
        SourceCode.Description := Description;
        if SourceCode.Insert then;
    end;

    procedure InsertRepSelection(var ReportSelections: Record "Report Selections"; ReportUsage: Integer; Sequence: Code[10]; ReportID: Integer)
    begin
        // P80066030
        ReportSelections.Init;
        ReportSelections.Usage := ReportUsage;
        ReportSelections.Sequence := Sequence;
        ReportSelections."Report ID" := ReportID;
        if ReportSelections.Insert then;
    end;

    procedure PageName(PageID: Integer): Text[50]
    var
        ObjectTranslation: Record "Object Translation";
    begin
        // P80066030
        exit(CopyStr(ObjectTranslation.TranslateObject(ObjectTranslation."Object Type"::Page, PageID), 1, 50));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitializeP800(CompName: Text[30]; var SourceCodeSetup: Record "Source Code Setup"; var SourceCode: Record "Source Code"; var ReportSelections: Record "Report Selections")
    begin
        // P80066030
    end;

    procedure GetItemCategoryPresentationRangeFilter(var ItemCategory: Record "Item Category") FilterString: Text
    var
        ItemCategory2: Record "Item Category";
        "Min": Integer;
        Min1: Integer;
        "Max": Integer;
        Max1: Integer;
    begin
        // P8007749, P80066030
        ItemCategory2.Copy(ItemCategory);
        ItemCategory2.SetCurrentKey("Presentation Order");
        if ItemCategory2.FindSet then begin
            repeat
                ItemCategory2.PresentationRange(Min1, Max1);
                if Min = 0 then begin
                    Min := Min1;
                    Max := Max1;
                end else begin
                    if Max < Min1 then
                        if (Max + 1) = Min1 then
                            Max := Max1
                        else begin
                            if Min = Max then
                                FilterString := StrSubstNo('%1|%2', FilterString, Min)
                            else
                                FilterString := StrSubstNo('%1|%2..%3', FilterString, Min, Max);
                            Min := Min1;
                            Max := Max1;
                        end;
                end;
            until ItemCategory2.Next = 0;

            if Min = Max then
                FilterString := StrSubstNo('%1|%2', FilterString, Min)
            else
                FilterString := StrSubstNo('%1|%2..%3', FilterString, Min, Max);
        end;

        FilterString := CopyStr(FilterString, 2);
    end;
}

