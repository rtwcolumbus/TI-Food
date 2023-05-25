codeunit 37002021 "Easy Lot Tracking"
{
    // PR3.70.04
    // P8000043A, Myers Nissi, Jack Reynolds, 02 JUN 04
    //    Support for easy lot tracking
    // 
    // PR3.70.07
    // P8000150A, Myers Nissi, Jack Reynolds, 22 NOV 04
    //   Modify to update linked sales or purchase line for drop shipments
    // 
    // PR3.70.10
    // P8000230A, Myers Nissi, Jack Reynolds, 14 JUL 05
    //   Modify AssistEdit to give the user a choice between lookup and assignment if the situation calls for it
    // 
    // PR4.00
    // P8000250B, Myers Nissi, Jack Reynolds, 18 OCT 05
    //   Support for alternate lot number assignemnt methods
    // 
    // PR4.00.01
    // P8000267B, VerticalSoft, Jack Reynolds, 12 DEC 05
    //   UpdateTracking - no longer required to call ItemTrackingForm.SetOnTransfer
    // 
    // P8000272A, VerticalSoft, Jack Reynolds, 15 DEC 05
    //   Clear GlobalTrackingSpec prior to initializing it
    // 
    // P8000276A, VerticalSoft, Jack Reynolds, 03 JAN 06
    //   Fix problem with zero quantity and non-zero alternate quantity
    // 
    // PR4.00.03
    // P8000343A, VerticalSoft, Jack Reynolds, 05 JUN 06
    //   Modify to support easy lot with reclass journal
    // 
    // PR4.00.04
    // P8000322A, Don Bresee, 03 AUG 06
    //   Bypass lot tracking update for 3-document location
    // 
    // PR4.00.05
    // P8000448B, VerticalSoft, Jack Reynolds, 19 FEB 07
    //   Use keys in GetLotNo and GetNewLotNo
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Don Bresee, 12 JUN 07
    //   AssistEditLotSerialNo moved to codeunit 6501
    //   AssistEdit - use Lot Info. Card
    // 
    // PRW15.00.01
    // P8000596A, VerticalSoft, Jack Reynolds, 27 MAR 08
    //   Fix problem updating tracking when registering picks
    // 
    // PRW16.00.02
    // P8000754, VerticalSoft, Jack Reynolds, 10 DEC 09
    //   fix problem with invoiced drop shipments
    // 
    // PRW16.00.05
    // P8000923, Columbus IT, Jack Reynolds, 29 MAR 11
    //   Fix problem creating synchronized entry for transfers
    // 
    // PRW16.00.06
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // P8001106, Columbus IT, Don Bresee, 16 OCT 12
    //   Add "Supplier Lot No." field
    // 
    // PRW17.00.01
    // P8001167, Columbus IT, Jack Reynolds, 02 AUG 13
    //   Modify to allow updating of existing reservations
    // 
    // PRW17.10
    // P8001234, Columbus IT, Jack Reynolds, 01 NOV 13
    //    Support for custom lot number formats
    // 
    // PRW19.00.01
    // P8007477, To-Increase, Dayakar Battini, 25 JUL 16
    //   Qty. to Handle fields updation when assigning lot.
    // 
    // P8008351, To-Increase, Jack Reynolds, 26 JAN 17
    //   Support for Lot Creation Date and Country of Origin for multiple lots
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW110.0.02
    // P80050544, To-Increase, Dayakar Battini, 12 FEB 18
    //   Upgrade to 2017 CU13
    // 
    // PRW111.00.02
    // P80073378, To Increase, Jack Reynolds, 24 MAR 19
    //   Support for easy lot tracking on warehouse shipments
    // 
    // PRW111.00.03
    // P800108979, To Increase, Gangabhuhan, 19 OCT 20
    //   CS00130169 | Purchase Order Receiving - lot no must be specified 
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // PRW118.01
    // P800127049, To Increase, Jack Reynolds, 23 AUG 21
    //   Support for Inventory documents
    //
    // PRW119.03
    // P800142405, To Increase, Gangabhushan, 14 MAR 22
    //   CS00212965 | Error when Lot number exceeds 20 characters    

    trigger OnRun()
    begin
    end;

    var
        Item: Record Item;
        GlobalTrackingSpec: Record "Tracking Specification";
        P800Globals: Codeunit "Process 800 System Globals";
        HandledField: Text[80];
        QtyHandled: Decimal;
        SourceOutstandingQtyBase: Decimal;
        TrackingDate: Date;
        TrackingFormRunMode: Integer;
        Text001: Label '%1 must be zero.';
        LookupAllowed: Code[10];
        Text002: Label 'Do you want to assign a %1?';
        AssignmentAllowed: Code[10];
        SecondSourceRowID: Text[100];
        Text003: Label '&Lookup %1,&Assign %1';
        LotNoData: Record "Lot No. Data";
        NewLotNo: Code[50];
        xNewLotNo: Code[50];
        NewLotStatusCode: Code[10];
        xNewLotStatusCode: Code[10];
        GlobalApplyFromEntryNo: Integer;
        SupplierLotNo: Code[50];
        xSupplierLotNo: Code[50];
        LotCreationDate: Date;
        xLotCreationDate: Date;
        CountryOfOrigin: Code[10];
        xCountryOfOrigin: Code[10];

    procedure TestSalesLine(SalesLine: Record "Sales Line")
    begin
        with SalesLine do begin
            TestField(Type, Type::Item);
            TestField("No.");
            Item.Get("No.");
            Item.TestField("Item Tracking Code");
        end;
    end;

    procedure SetSalesLine(SalesLine: Record "Sales Line")
    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        with SalesLine do begin
            Clear(GlobalTrackingSpec); // P8000272A
            GlobalTrackingSpec.InitFromSalesLine(SalesLine); // P8007748
            TrackingDate := SalesLine."Shipment Date";
            // P8001234
            //LotNoDocNo := "Document No."; // P8000250B
            //LotNoDate := "Shipment Date"; // P8000250B
            LotNoData.InitializeFromSourceRecord(SalesLine, false);
            // P8001234
            TrackingFormRunMode := 2;
            // P8000150A Begin
            if "Drop Shipment" and ("Purchase Order No." <> '') then begin // P8000754
                TrackingFormRunMode := 3;
                //IF "Purchase Order No." <> '' THEN                         // P8000754
                SecondSourceRowID := ItemTrackingMgt.ComposeRowID(DATABASE::"Purchase Line", 1,
                  "Purchase Order No.", '', 0, "Purch. Order Line No.");
            end;
            // P8000150A
            case "Document Type" of
                "Document Type"::Order, "Document Type"::Invoice:
                    begin
                        HandledField := FieldCaption("Quantity Shipped");
                        QtyHandled := "Qty. Shipped (Base)";
                        LookupAllowed := 'ALWAYS';    // P8000230A
                        AssignmentAllowed := 'NEVER'; // P8000230A
                    end;
                "Document Type"::"Return Order", "Document Type"::"Credit Memo":
                    begin
                        HandledField := FieldCaption("Return Qty. Received");
                        QtyHandled := "Return Qty. Received (Base)";
                        LookupAllowed := '';           // P8000230A
                        AssignmentAllowed := 'ALWAYS'; // P8000230A
                    end;
            end;
            SourceOutstandingQtyBase := "Outstanding Qty. (Base)";
        end;
    end;

    procedure TestPurchaseLine(PurchaseLine: Record "Purchase Line")
    begin
        with PurchaseLine do begin
            TestField(Type, Type::Item);
            TestField("No.");
            Item.Get("No.");
            Item.TestField("Item Tracking Code");
        end;
    end;

    procedure SetPurchaseLine(PurchaseLine: Record "Purchase Line")
    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        with PurchaseLine do begin
            Clear(GlobalTrackingSpec); // P8000272A
            GlobalTrackingSpec.InitFromPurchLine(PurchaseLine); // P8007748
            TrackingDate := PurchaseLine."Expected Receipt Date";
            // P8001234
            //LotNoDocNo := "Document No.";         // P8000250B
            //LotNoDate := "Expected Receipt Date"; // P8000250B
            LotNoData.InitializeFromSourceRecord(PurchaseLine, false);
            // P8001234
            TrackingFormRunMode := 2;
            // P8000150A Begin
            if "Drop Shipment" and ("Sales Order No." <> '') then begin  // P8000754
                TrackingFormRunMode := 3;
                //IF "Sales Order No." <> '' THEN                          // P8000754
                SecondSourceRowID := ItemTrackingMgt.ComposeRowID(DATABASE::"Sales Line", 1,
                  "Sales Order No.", '', 0, "Sales Order Line No.");
            end;
            // P8000150A
            case "Document Type" of
                "Document Type"::Order, "Document Type"::Invoice:
                    begin
                        HandledField := FieldCaption("Quantity Received");
                        QtyHandled := "Qty. Received (Base)";
                        LookupAllowed := '';           // P8000230A
                        AssignmentAllowed := 'ALWAYS'; // P8000230A
                    end;
                "Document Type"::"Return Order", "Document Type"::"Credit Memo":
                    begin
                        HandledField := FieldCaption("Return Qty. Shipped");
                        QtyHandled := "Return Qty. Shipped (Base)";
                        LookupAllowed := 'ALWAYS';    // P8000230A
                        AssignmentAllowed := 'NEVER'; // P8000230A
                    end;
            end;
            SourceOutstandingQtyBase := "Outstanding Qty. (Base)";
        end;
    end;

    procedure TestItemJnlLine(ItemJnlLine: Record "Item Journal Line")
    begin
        with ItemJnlLine do begin
            TestField("Item No.");
            Item.Get("Item No.");
            Item.TestField("Item Tracking Code");
        end;
    end;

    procedure SetItemJnlLine(ItemJnlLine: Record "Item Journal Line"; FldNo: Integer)
    begin
        // P8000343A - add parameter for field number
        with ItemJnlLine do begin
            Clear(GlobalTrackingSpec); // P8000272A
            GlobalTrackingSpec.InitFromItemJnlLine(ItemJnlLine); // P8007748
            TrackingDate := "Posting Date";
            // P8001234
            //LotNoDocNo := "Document No."; // P8000250B
            //LotNoDate := "Posting Date";  // P8000250B
            LotNoData.InitializeFromSourceRecord(ItemJnlLine, false);
            // P8001234
            if "Entry Type" = "Entry Type"::Transfer then // P8000343A
                TrackingFormRunMode := 1;                   // P8000343A
                                                            // P8000230A Begin
            case "Entry Type" of
                "Entry Type"::Sale, "Entry Type"::"Negative Adjmt.", "Entry Type"::Consumption:
                    if Quantity >= 0 then begin
                        LookupAllowed := 'ALWAYS';
                        AssignmentAllowed := 'NEVER';
                    end else begin
                        LookupAllowed := '';
                        AssignmentAllowed := 'ALWAYS';
                    end;
                "Entry Type"::"Positive Adjmt.":
                    if Quantity >= 0 then begin
                        LookupAllowed := 'ALWAYS';
                        AssignmentAllowed := '';
                    end else begin
                        LookupAllowed := 'ALWAYS';
                        AssignmentAllowed := 'NEVER';
                    end;
                // P8000343A
                "Entry Type"::Transfer:
                    case FldNo of
                        FieldNo("Lot No."):
                            begin
                                LookupAllowed := 'ALWAYS';
                                AssignmentAllowed := 'NEVER';
                            end;
                        FieldNo("New Lot No."):
                            begin
                                LookupAllowed := '';
                                AssignmentAllowed := 'ALWAYS';
                            end;
                    end;
                // P8000343A
                else
                    if Quantity >= 0 then begin
                        LookupAllowed := '';
                        AssignmentAllowed := 'ALWAYS';
                    end else begin
                        LookupAllowed := 'ALWAYS';
                        AssignmentAllowed := 'NEVER';
                    end;
            end;
            // P8000230A End
            SourceOutstandingQtyBase := "Quantity (Base)";
        end;
    end;

    procedure SetNewLotNo(xLotNo: Code[50]; LotNo: Code[50])
    begin
        // P8000343A
        xNewLotNo := xLotNo;
        NewLotNo := LotNo;
    end;

    procedure SetNewLotStatus(xLotStatus: Code[10]; LotStatus: Code[10])
    begin
        // P8001083
        xNewLotStatusCode := xLotStatus;
        NewLotStatusCode := LotStatus;
    end;

    // P800127049
    procedure TestInvtDocLine(IvtDocLine: Record "Invt. Document Line")
    begin
        IvtDocLine.TestField("Item No.");
        Item.Get(IvtDocLine."Item No.");
        Item.TestField("Item Tracking Code");
    end;

    // P800127049
    procedure SetInvtDocLine(InvtDocLine: Record "Invt. Document Line")
    begin
        Clear(GlobalTrackingSpec);
        GlobalTrackingSpec.InitFromInvtDocLine(InvtDocLine);
        TrackingDate := InvtDocLine."Posting Date";
        LotNoData.InitializeFromSourceRecord(InvtDocLine, false);
        TrackingFormRunMode := 2;
        case InvtDocLine."Document Type" of
            InvtDocLine."Document Type"::Shipment:
                begin
                    LookupAllowed := 'ALWAYS';
                    AssignmentAllowed := 'NEVER';
                end;
            InvtDocLine."Document Type"::Receipt:
                begin
                    LookupAllowed := '';
                    AssignmentAllowed := 'ALWAYS';
                end;
        end;
        SourceOutstandingQtyBase := InvtDocLine."Quantity (Base)";
    end;

    procedure TestTransferLine(TransLine: Record "Transfer Line")
    begin
        with TransLine do begin
            TestField("Item No.");
            Item.Get("Item No.");
            Item.TestField("Item Tracking Code");
        end;
    end;

    procedure SetTransferLine(TransLine: Record "Transfer Line"; Direction: Option Outbound,Inbound)
    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        with TransLine do begin
            TrackingDate := "Shipment Date";
            Clear(GlobalTrackingSpec); // P8000272A
            GlobalTrackingSpec.InitFromTransLine(TransLine, TrackingDate, Direction); // P8007748
                                                                                      // P8000923
            TrackingFormRunMode := 3;
            SecondSourceRowID := ItemTrackingMgt.ComposeRowID(DATABASE::"Transfer Line", 1,
              "Document No.", '', 0, "Line No.");
            // P8000923
            HandledField := FieldCaption("Quantity Shipped");
            QtyHandled := "Qty. Shipped (Base)";
            LookupAllowed := 'ALWAYS';    // P8000230A
            AssignmentAllowed := 'NEVER'; // P8000230A
            SourceOutstandingQtyBase := "Quantity (Base)";
        end;
    end;

    procedure TestProdOrderLine(ProdOrderLine: Record "Prod. Order Line")
    begin
        with ProdOrderLine do begin
            TestField("Item No.");
            Item.Get("Item No.");
            Item.TestField("Item Tracking Code");
        end;
    end;

    procedure SetProdOrderLine(ProdOrderLine: Record "Prod. Order Line")
    begin
        with ProdOrderLine do begin
            Clear(GlobalTrackingSpec); // P8000272A
            GlobalTrackingSpec.InitFromProdOrderLine(ProdOrderLine); // P8007748
            TrackingDate := "Due Date";
            // P8001234
            //LotNoDocNo := "Prod. Order No."; // P8000250B
            //LotNoDate := "Due Date";         // P8000250B
            LotNoData.InitializeFromSourceRecord(ProdOrderLine, false);
            // P8001234
            LookupAllowed := '';           // P8000230A
            AssignmentAllowed := 'ALWAYS'; // P8000230A
            SourceOutstandingQtyBase := "Remaining Qty. (Base)";
        end;
    end;

    procedure TestProdOrderComp(ProdOrderComp: Record "Prod. Order Component")
    begin
        with ProdOrderComp do begin
            TestField("Item No.");
            Item.Get("Item No.");
            Item.TestField("Item Tracking Code");
        end;
    end;

    procedure SetProdOrderComp(ProdOrderComp: Record "Prod. Order Component")
    begin
        with ProdOrderComp do begin
            Clear(GlobalTrackingSpec); // P8000272A
            GlobalTrackingSpec.InitFromProdOrderComp(ProdOrderComp); // P8007748
            TrackingDate := "Due Date";
            LookupAllowed := 'ALWAYS';    // P8000230A
            AssignmentAllowed := 'NEVER'; // P8000230A
            SourceOutstandingQtyBase := "Remaining Qty. (Base)";
        end;
    end;

    procedure GetLotNo() LotNo: Code[50]
    var
        ResEntry: Record "Reservation Entry";
        TrackingSpec: Record "Tracking Specification";
        ItemEntryRelation: Record "Item Entry Relation";
        ItemLedgerEntry: Record "Item Ledger Entry";
        NewLotNo: Code[50];
    begin
        ResEntry.SetCurrentKey(                                                                    // P8000448B
          "Source Type", "Source ID", "Source Batch Name", "Source Ref. No.", "Lot No.", "Serial No."); // P8000448B
        ResEntry.SetRange("Source Type", GlobalTrackingSpec."Source Type");
        ResEntry.SetRange("Source Subtype", GlobalTrackingSpec."Source Subtype");
        ResEntry.SetRange("Source ID", GlobalTrackingSpec."Source ID");
        ResEntry.SetRange("Source Batch Name", GlobalTrackingSpec."Source Batch Name");
        ResEntry.SetRange("Source Prod. Order Line", GlobalTrackingSpec."Source Prod. Order Line");
        ResEntry.SetRange("Source Ref. No.", GlobalTrackingSpec."Source Ref. No.");
        ResEntry.SetFilter("Lot No.", '<>%1&<>%2', '', LotNo);
        if ResEntry.Find('-') then begin
            LotNo := ResEntry."Lot No.";
            SupplierLotNo := ResEntry."Supplier Lot No."; // P8001106
            LotCreationDate := ResEntry."Lot Creation Date";             // P8008351
            CountryOfOrigin := ResEntry."Country/Region of Origin Code"; // P8008351
            ResEntry.SetFilter("Lot No.", '<>%1&<>%2', '', LotNo);
            if ResEntry.Find('-') then
                exit(P800Globals.MultipleLotCode);
            // P8000343A
            if (GlobalTrackingSpec."Source Type" = DATABASE::"Item Journal Line") and
              (GlobalTrackingSpec."Source Subtype" = 4)
            then begin
                ResEntry.SetRange("Lot No.");
                ResEntry.SetFilter("New Lot No.", '<>%1&<>%2', '', NewLotNo);
                if ResEntry.Find('-') then begin
                    NewLotNo := ResEntry."New Lot No.";
                    ResEntry.SetFilter("New Lot No.", '<>%1&<>%2', '', NewLotNo);
                    if ResEntry.Find('-') then
                        exit(P800Globals.MultipleLotCode);
                end;
            end;
            // P8000343A
        end;

        if GlobalTrackingSpec."Source Type" in [DATABASE::"Sales Line", DATABASE::"Purchase Line"] then begin
            TrackingSpec.SetCurrentKey("Source ID", "Source Type", "Source Subtype", // P8000448B
              "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.");    // P8000448B

            TrackingSpec.SetRange("Source Type", GlobalTrackingSpec."Source Type");
            TrackingSpec.SetRange("Source Subtype", GlobalTrackingSpec."Source Subtype");
            TrackingSpec.SetRange("Source ID", GlobalTrackingSpec."Source ID");
            TrackingSpec.SetRange("Source Batch Name", GlobalTrackingSpec."Source Batch Name");
            TrackingSpec.SetRange("Source Prod. Order Line", GlobalTrackingSpec."Source Prod. Order Line");
            TrackingSpec.SetRange("Source Ref. No.", GlobalTrackingSpec."Source Ref. No.");
            TrackingSpec.SetFilter("Lot No.", '<>%1&<>%2', '', LotNo);
            if TrackingSpec.Find('-') then
                if LotNo = '' then begin
                    LotNo := TrackingSpec."Lot No.";
                    SupplierLotNo := TrackingSpec."Supplier Lot No."; // P8001106
                    LotCreationDate := TrackingSpec."Lot Creation Date";             // P8008351
                    CountryOfOrigin := TrackingSpec."Country/Region of Origin Code"; // P8008351
                    TrackingSpec.SetFilter("Lot No.", '<>%1&<>%2', '', LotNo);
                    if TrackingSpec.Find('-') then
                        exit(P800Globals.MultipleLotCode);
                end else
                    exit(P800Globals.MultipleLotCode);
        end;

        if GlobalTrackingSpec."Source Type" = DATABASE::"Transfer Line" then begin
            ItemEntryRelation.SetCurrentKey("Order No.", "Order Line No.");
            ItemEntryRelation.SetRange("Source Type", DATABASE::"Transfer Shipment Line");
            ItemEntryRelation.SetRange("Order No.", GlobalTrackingSpec."Source ID");
            ItemEntryRelation.SetRange("Order Line No.", GlobalTrackingSpec."Source Ref. No.");
            if ItemEntryRelation.Find('-') then
                repeat
                    ItemLedgerEntry.Get(ItemEntryRelation."Item Entry No.");
                    if LotNo = '' then
                        LotNo := ItemLedgerEntry."Lot No."
                    else
                        if LotNo <> ItemLedgerEntry."Lot No." then
                            exit(P800Globals.MultipleLotCode);
                until ItemEntryRelation.Next = 0;
        end;
    end;

    procedure GetNewLotNo(var NewLotStatus: Code[10]) NewLotNo: Code[50]
    var
        ResEntry: Record "Reservation Entry";
        LotNo: Code[50];
    begin
        // P8000343A
        ResEntry.SetCurrentKey(                                                                    // P8000448B
          "Source Type", "Source ID", "Source Batch Name", "Source Ref. No.", "Lot No.", "Serial No."); // P8000448B
        ResEntry.SetRange("Source Type", GlobalTrackingSpec."Source Type");
        ResEntry.SetRange("Source Subtype", GlobalTrackingSpec."Source Subtype");
        ResEntry.SetRange("Source ID", GlobalTrackingSpec."Source ID");
        ResEntry.SetRange("Source Batch Name", GlobalTrackingSpec."Source Batch Name");
        ResEntry.SetRange("Source Prod. Order Line", GlobalTrackingSpec."Source Prod. Order Line");
        ResEntry.SetRange("Source Ref. No.", GlobalTrackingSpec."Source Ref. No.");
        ResEntry.SetFilter("New Lot No.", '<>%1&<>%2', '', NewLotNo);
        if ResEntry.Find('-') then begin
            NewLotNo := ResEntry."New Lot No.";
            NewLotStatus := ResEntry."New Lot Status Code"; // P8001083
            ResEntry.SetFilter("New Lot No.", '<>%1&<>%2', '', NewLotNo);
            if ResEntry.Find('-') then begin               // P8001083
                NewLotStatus := P800Globals.MultipleLotCode; // P8001083
                exit(P800Globals.MultipleLotCode);
            end;                                           // P8001083
            if (GlobalTrackingSpec."Source Type" = DATABASE::"Item Journal Line") and
              (GlobalTrackingSpec."Source Subtype" = 4)
            then begin
                ResEntry.SetRange("New Lot No.");
                ResEntry.SetFilter("Lot No.", '<>%1&<>%2', '', LotNo);
                if ResEntry.Find('-') then begin
                    LotNo := ResEntry."Lot No.";
                    ResEntry.SetFilter("Lot No.", '<>%1&<>%2', '', LotNo);
                    if ResEntry.Find('-') then begin               // P8001083
                        NewLotStatus := P800Globals.MultipleLotCode; // P8001083
                        exit(P800Globals.MultipleLotCode);
                    end;                                           // P8001083
                end;
            end;
        end;
    end;

    procedure ReplaceTracking(xLotNo: Code[50]; LotNo: Code[50]; AltQtyTransNo: Integer; Qty: Decimal; QtyToHandle: Decimal; QtyToHandleAlt: Decimal; QtyToInvoice: Decimal)
    begin
        // P8001167
        ProcessTracking(xLotNo, LotNo, AltQtyTransNo, Qty, QtyToHandle, QtyToHandleAlt, QtyToInvoice, 'REPLACE');
    end;

    procedure UpdateTracking(xLotNo: Code[50]; LotNo: Code[50]; AltQtyTransNo: Integer; Qty: Decimal; QtyToHandle: Decimal; QtyToHandleAlt: Decimal; QtyToInvoice: Decimal)
    begin
        // P8001167
        ProcessTracking(xLotNo, LotNo, AltQtyTransNo, Qty, QtyToHandle, QtyToHandleAlt, QtyToInvoice, 'UPDATE');
    end;

    procedure ProcessTracking(xLotNo: Code[50]; LotNo: Code[50]; AltQtyTransNo: Integer; Qty: Decimal; QtyToHandle: Decimal; QtyToHandleAlt: Decimal; QtyToInvoice: Decimal; Mode: Code[10])
    var
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        AltQtyLine: Record "Alternate Quantity Line";
        ItemTrackingForm: Page "Item Tracking Lines";
        ApplyFromEntryNo: Integer;
    begin
        // P8001167
        ApplyFromEntryNo := GlobalApplyFromEntryNo; // P8000466A
        GlobalApplyFromEntryNo := 0;                // P8000466A

        if (LotNo = '') and (xLotNo = '') and (NewLotNo = '') and (xNewLotNo = '') and // P8001083
          (SupplierLotNo = '') and (xSupplierLotNo = '') and // P8001106
          (LotCreationDate = 0D) and (xLotCreationDate = 0D) and // P8008351
          (CountryOfOrigin = '') and (xCountryOfOrigin = '') and // P8008351
          (NewLotStatusCode = '') and (xNewLotStatusCode = '')                         // P8001083
        then // P8000343A
            exit;

        /*P8000596A
        // P8000322A
        IF SkipWhseTrackingUpdate() THEN
          EXIT;
        // P8000322A
        P8000596A*/

        if (xLotNo <> '') and (LotNo <> xLotNo) and (QtyHandled <> 0) then // P8001189
            Error(Text001, HandledField);

        TempTrackingSpecification.Init;
        TempTrackingSpecification."Lot No." := LotNo;
        TempTrackingSpecification."New Lot No." := NewLotNo; // P8000343A
        TempTrackingSpecification."New Lot Status Code" := NewLotStatusCode; //P8001083
        TempTrackingSpecification."Supplier Lot No." := SupplierLotNo; // P8001106
        TempTrackingSpecification."Lot Creation Date" := LotCreationDate;             // P8008351
        TempTrackingSpecification."Country/Region of Origin Code" := CountryOfOrigin; // P8008351
        TempTrackingSpecification.Validate("Quantity (Base)", Qty);  //P8007477
        TempTrackingSpecification."Qty. to Handle (Base)" := QtyToHandle;
        TempTrackingSpecification."Qty. to Invoice (Base)" := QtyToInvoice;
        if GlobalTrackingSpec."Source Type" = DATABASE::"Item Journal Line" then // P8000276A
            TempTrackingSpecification."Quantity (Alt.)" := QtyToHandleAlt;         // P8000276A
        TempTrackingSpecification."Qty. to Handle (Alt.)" := QtyToHandleAlt;
        TempTrackingSpecification."Appl.-from Item Entry" := ApplyFromEntryNo; // P8000466A
        TempTrackingSpecification.InitExpirationDate; // P8001083
        TempTrackingSpecification.Insert;

        ItemTrackingForm.SetFormRunMode(TrackingFormRunMode);
        // P8000150A Begin
        if TrackingFormRunMode = 3 then
            ItemTrackingForm.SetSecondSourceRowID(SecondSourceRowID);
        // P8000150A End
        ItemTrackingForm.SetBlockCommit(true);
        ItemTrackingForm.SetSourceSpec(GlobalTrackingSpec, TrackingDate);
        ItemTrackingForm.RegisterP800Tracking(TempTrackingSpecification, Mode);
        // P8000105A Begin
        if TrackingFormRunMode = 3 then
            UpdateLinkedLine(SecondSourceRowID);
        // P8000150A End

        if AltQtyTransNo <> 0 then begin
            AltQtyLine.SetRange("Alt. Qty. Transaction No.", AltQtyTransNo);
            if AltQtyLine.Find('-') then
                repeat
                    AltQtyLine."Lot No." := LotNo;
                    AltQtyLine.Modify;
                until AltQtyLine.Next = 0;
        end;

    end;

    procedure UpdateLinkedLine(RowID: Text[100])
    var
        ResEntry: Record "Reservation Entry";
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
    begin
        // P8000150A
        ResEntry.SetPointer(RowID);
        case ResEntry."Source Type" of
            DATABASE::"Sales Line":
                begin
                    SalesLine.Get(ResEntry."Source Subtype", ResEntry."Source ID", ResEntry."Source Ref. No.");
                    SalesLine.GetLotNo;
                    SalesLine.Modify;
                end;
            DATABASE::"Purchase Line":
                begin
                    PurchLine.Get(ResEntry."Source Subtype", ResEntry."Source ID", ResEntry."Source Ref. No.");
                    PurchLine.GetLotNo;
                    PurchLine.Modify;
                end;
        end;
    end;

    procedure AssistEdit(var LotNo: Code[50]): Boolean
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        LotNoInfo: Record "Lot No. Information";
        ResEntry: Record "Reservation Entry";
        P800Functions: Codeunit "Process 800 Functions";
        P800ItemTracking: Codeunit "Process 800 Item Tracking";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ItemTrackingDCMgt: Codeunit "Item Tracking Data Collection";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        CurrentSignFactor: Integer;
        MaxQty: Decimal;
        Lookup: Boolean;
        Assign: Boolean;
        DefaultAction: Integer;
    begin
        if not P800Functions.TrackingInstalled then
            exit;
        if LotNo = P800Globals.MultipleLotCode then
            exit(false);

        if LotNo <> '' then begin
            LotNoInfo.SetRange("Item No.", GlobalTrackingSpec."Item No.");
            LotNoInfo.SetRange("Variant Code", GlobalTrackingSpec."Variant Code");
            LotNoInfo.SetRange("Lot No.", LotNo);
            PAGE.RunModal(PAGE::"Lot No. Information Card", LotNoInfo); // P8000466A
            exit(false);
        end;

        Item.Get(GlobalTrackingSpec."Item No.");
        ItemTrackingCode.Get(Item."Item Tracking Code"); // P8000230A

        // P8000230A Begin
        if LookupAllowed = 'ALWAYS' then begin
            Lookup := true;
            DefaultAction := 1;
        end;
        if (LookupAllowed = '') and ItemTrackingCode."Allow Loose Lot Control" then
            Lookup := true;
        if AssignmentAllowed = 'ALWAYS' then begin
            Assign := true;
            DefaultAction := 2;
        end;
        if (AssignmentAllowed = '') and ItemTrackingCode."Allow Loose Lot Control" then
            Assign := true;
        if Assign and Lookup then begin
            case StrMenu(StrSubstNo(Text003, GlobalTrackingSpec.FieldCaption("Lot No.")), DefaultAction) of
                0:
                    exit(false);
                1:
                    Assign := false;
                2:
                    Lookup := false;
            end;
        end else
            if Assign then
                if not Confirm(Text002, false, GlobalTrackingSpec.FieldCaption("Lot No.")) then
                    exit(false);
        // P8000230A End

        if Lookup then begin // P8000230A
            ResEntry."Source Type" := GlobalTrackingSpec."Source Type";
            ResEntry."Source Subtype" := GlobalTrackingSpec."Source Subtype";
            CurrentSignFactor := CreateReservEntry.SignFactor(ResEntry);
            MaxQty := SourceOutstandingQtyBase;
            ItemTrackingDCMgt.AssistEditTrackingNo(GlobalTrackingSpec, true, CurrentSignFactor, 1, MaxQty); // P8000466A
            LotNo := GlobalTrackingSpec."Lot No.";
            exit(LotNo <> '');
        end; // P8000230A
        if Assign then begin // P8000230A
                             //IF NOT CONFIRM(Text002,FALSE,GlobalTrackingSpec.FIELDCAPTION("Lot No.")) THEN // P8000230A
                             //  EXIT(FALSE);
                             // P8001234                                                                // P8000230A
                             //Item.GET(GlobalTrackingSpec."Item No.");
            LotNo := LotNoData.AssignLotNo;                                   // P8000250B
                                                                              // P8001234
                                                                              //Item.TESTFIELD("Lot Nos.");                                     // P8000250B
                                                                              //LotNo := NoSeriesMgt.GetNextNo(Item."Lot Nos.",WORKDATE,TRUE);  // P8000250B
            exit(true);
        end;
    end;

    local procedure SkipWhseTrackingUpdate(): Boolean
    var
        Location: Record Location;
    begin
        // P8000322A
        if IsWhseShptSource(GlobalTrackingSpec) then
            with Location do begin
                if Get(GlobalTrackingSpec."Location Code") then
                    exit("Require Shipment" and "Require Pick");
            end;
        exit(false);
        // P8000322A
    end;

    local procedure IsWhseShptSource(var SourceSpecification2: Record "Tracking Specification"): Boolean
    begin
        // P8000322A
        with SourceSpecification2 do
            case "Source Type" of
                DATABASE::"Sales Line":
                    exit("Source Subtype" = 1);   // Sales Order
                DATABASE::"Purchase Line":
                    exit("Source Subtype" = 5);   // Purchase Return Order
                DATABASE::"Transfer Line":
                    exit("Source Subtype" = 0);   // Outbound Transfer Order
            end;
        exit(false);
        // P8000322A
    end;

    procedure SetApplyFromEntryNo(EntryNo: Integer)
    begin
        // P8000466A
        GlobalApplyFromEntryNo := EntryNo;
    end;

    procedure SetSupplierLotNo(xNewSupplierLotNo: Code[50]; NewSupplierLotNo: Code[50])
    begin
        // P8001106
        xSupplierLotNo := xNewSupplierLotNo;
        SupplierLotNo := NewSupplierLotNo;
    end;

    procedure GetSupplierLotNo(LotNo: Code[50]): Code[50]
    begin
        // P8001106
        if (LotNo <> '') then
            if (LotNo = P800Globals.MultipleLotCode) then
                exit(''); // P8008351
        exit(SupplierLotNo);
    end;

    procedure SetLotCreationDate(xNewLotCreationDate: Date; NewLotCreationDate: Date)
    begin
        // P8008351
        xLotCreationDate := xNewLotCreationDate;
        LotCreationDate := NewLotCreationDate;
    end;

    procedure GetLotCreationDate(LotNo: Code[50]): Date
    begin
        // P8008351
        if (LotNo <> '') then
            if (LotNo = P800Globals.MultipleLotCode) then
                exit(0D);
        exit(LotCreationDate);
    end;

    procedure SetCountryOfOrigin(xNewCountryOfOrigin: Code[10]; NewCountryOfOrigin: Code[10])
    begin
        // P8008351
        xCountryOfOrigin := xNewCountryOfOrigin;
        CountryOfOrigin := NewCountryOfOrigin;
    end;

    procedure GetCountryOfOrigin(LotNo: Code[50]): Code[10]
    begin
        // P8008351
        if (LotNo <> '') then
            if (LotNo = P800Globals.MultipleLotCode) then
                exit('');
        exit(CountryOfOrigin);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Create Source Document", 'OnAfterCreateShptLineFromSalesLine', '', true, false)]
    local procedure WhseCreateSourceDocument_OnAfterCreateShptLineFromSalesLine(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; WarehouseShipmentHeader: Record "Warehouse Shipment Header"; SalesLine: Record "Sales Line")
    begin
        // P80073378
        WarehouseShipmentLine.SetLotQuantity(WarehouseShipmentLine.GetLotNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment", 'OnAfterPostUpdateWhseShptLine', '', true, false)]
    local procedure WhsePostShipment_OnAfterPostUpdateWhseShptLine(var WarehouseShipmentLine: Record "Warehouse Shipment Line")
    begin
        // P80073378
        WarehouseShipmentLine.SetLotQuantity(WarehouseShipmentLine.GetLotNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Receipt", 'OnAfterPostUpdateWhseRcptLine', '', true, false)]
    local procedure OnAfterPostUpdateWhseRcptLine(var WarehouseReceiptLine: Record "Warehouse Receipt Line");
    var
        LotNo: Code[50];
    begin
        // P800108979
        LotNo := WarehouseReceiptLine.GetLotNo;
        WarehouseReceiptLine.ValidateLotNo(LotNo);
    end;
}

