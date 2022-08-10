codeunit 37002682 "Commodity Manifest-Post"
{
    // PRW16.00.04
    // P8000891, VerticalSoft, Don Bresee, 04 JAN 11
    //   Add Commodity Receiving logic
    // 
    // P8000902, Columbus IT, Don Bresee, 14 MAR 11
    //   Add Commodity Payment logic
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018

    Permissions = TableData "Posted Comm. Manifest Header" = rim,
                  TableData "Posted Comm. Manifest Line" = rim,
                  TableData "Pstd. Comm. Manifest Dest. Bin" = rim;
    TableNo = "Commodity Manifest Header";

    trigger OnRun()
    var
        TempOrderToPost: Record "Item Ledger Entry" temporary;
    begin
        CommManifestHeader.Copy(Rec);
        TestManifest;
        UpdateManifest;
        CreatePurchOrders;
        PostPurchOrders(TempOrderToPost);
        PostManifest(TempOrderToPost);
    end;

    var
        CommManifestHeader: Record "Commodity Manifest Header";
        Item: Record Item;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        ReservePurchLine: Codeunit "Purch. Line-Reserve";
        PurchPost: Codeunit "Purch.-Post";
        ReleasePurchDoc: Codeunit "Release Purchase Document";
        CombineLots: Codeunit "Combine Whse. Lots";
        P800WhseActCreate: Codeunit "Process 800 Create Whse. Act.";
        HideGUI: Boolean;
        Text000: Label 'Posting Manifest %1...';
        Text001: Label 'Updating Orders       #2######';
        Text002: Label 'Posting Receipts      #2######';
        Text003: Label 'The total %1 from the %2 (%3) must match the Manifest %4 (%5).';
        Text004: Label 'Lines';
        Text005: Label 'Destination Bins';
        Text006: Label 'You must specify %1 for the Manifest.';
        Text007: Label 'Manifest No. %1';

    local procedure TestManifest()
    var
        CommManifestLine: Record "Commodity Manifest Line";
        CommManifestDestBin: Record "Commodity Manifest Dest. Bin";
    begin
        with CommManifestHeader do begin
            TestField("Location Code");
            TestField("Bin Code");
            TestField("Item No.");
            TestField("Posting Date");
            TestField("Received Quantity");
            Item.Get("Item No.");
        end;
        with CommManifestLine do begin
            SetRange("Commodity Manifest No.", CommManifestHeader."No.");
            if not FindSet then
                Error(Text006, Text004);
            repeat
                TestField("Vendor No.");
                TestField("Received Date");
                TestField("Manifest Quantity");
            until (Next = 0);
        end;
        if not CommManifestHeader."Product Rejected" then begin
            with CommManifestDestBin do begin
                SetRange("Commodity Manifest No.", CommManifestHeader."No.");
                if not FindSet then
                    Error(Text006, Text005);
                repeat
                    TestField("Bin Code");
                    TestField(Quantity);
                until (Next = 0);
            end;
            with CommManifestHeader do begin
                CalcFields("Destination Bin Quantity");
                if ("Received Quantity" <> "Destination Bin Quantity") then
                    Error(Text003,
                      CommManifestDestBin.FieldCaption(Quantity), Text005,
                      "Destination Bin Quantity", FieldCaption("Received Quantity"), "Received Quantity");
            end;
        end;
    end;

    local procedure UpdateManifest()
    var
        ModifyHeader: Boolean;
        InvtSetup: Record "Inventory Setup";
    begin
        with CommManifestHeader do begin
            if ("Lot No." = '') then begin
                AssignLotNo;
                ModifyHeader := true;
            end;
            if ("Receiving No." = '') then begin
                InvtSetup.Get;
                "Receiving No. Series" := InvtSetup."Posted Comm. Manifest Nos.";
                if ("Receiving No. Series" in ['', "No. Series"]) then
                    "Receiving No." := "No."
                else
                    "Receiving No." := NoSeriesMgt.GetNextNo("Receiving No. Series", "Posting Date", true);
                ModifyHeader := true;
            end;
            if ModifyHeader then begin
                Modify;
                Commit;
            end;
        end;
    end;

    local procedure CreatePurchOrders()
    var
        CommManifestLine: Record "Commodity Manifest Line";
        Vendor: Record Vendor;
        PurchOrder: Record "Purchase Header";
        StatusWindow: Dialog;
        RcptCount: Integer;
        PurchOrderType: Integer;
    begin
        if ShowStatusWindow() then begin
            StatusWindow.Open('#1############################\\' + Text001);
            StatusWindow.Update(1, StrSubstNo(Text000, CommManifestHeader."No."));
        end;
        with CommManifestLine do begin
            SetCurrentKey("Commodity Manifest No.", "Vendor No.", "Received Date");
            SetRange("Commodity Manifest No.", CommManifestHeader."No.");
            SetRange("Purch. Order Status", "Purch. Order Status"::Open, "Purch. Order Status"::Created);
            if FindSet then
                repeat
                    RcptCount := RcptCount + 1;
                    if ShowStatusWindow() then
                        StatusWindow.Update(2, RcptCount);
                    Create1PurchOrder(CommManifestLine);
                    if (CommManifestHeader."Hauler No." <> '') then
                        Create1HaulerPO(CommManifestLine);
                    "Purch. Order Status" := "Purch. Order Status"::Created;
                    Modify;
                    Commit;
                until (Next = 0);
        end;
        if ShowStatusWindow() then
            StatusWindow.Close;
    end;

    local procedure Create1PurchOrder(var CommManifestLine: Record "Commodity Manifest Line")
    var
        PayToVendor: Record Vendor;
        PurchOrder: Record "Purchase Header";
        PurchOrderType: Integer;
    begin
        with CommManifestLine do begin
            GetPayToVendorAndType("Vendor No.", PayToVendor, PurchOrderType);
            if not FindPurchOrder("Vendor No.", PayToVendor, "Received Date", PurchOrder, PurchOrderType) then
                CreatePurchOrderHeader("Vendor No.", PayToVendor, "Received Date", PurchOrder, PurchOrderType);
            ReleasePurchDoc.Reopen(PurchOrder);
            if ("Received Lot No." = '') then
                AssignRcptLotNo;
            CalcFields("Purch. Order No.");
            if ("Purch. Order No." = '') then
                CreatePurchOrderLine(CommManifestLine, PurchOrder)
            else
                if ("Purch. Order No." = PurchOrder."No.") then
                    RecreatePurchOrderLine(CommManifestLine, PurchOrder)
                else begin
                    DeletePurchOrderLine;
                    CreatePurchOrderLine(CommManifestLine, PurchOrder);
                end;
        end;
    end;

    local procedure GetPayToVendorAndType(BuyFromVendorNo: Code[20]; var PayToVendor: Record Vendor; var PurchOrderType: Integer)
    begin
        with PayToVendor do
            if (CommManifestHeader."Broker No." <> '') then begin
                Get(CommManifestHeader."Broker No.");
                PurchOrderType := "Commodity Vendor Type"::Broker;
            end else begin
                Get(BuyFromVendorNo);
                if ("Pay-to Vendor No." <> '') then
                    Get("Pay-to Vendor No.");
                PurchOrderType := "Commodity Vendor Type"::Producer;
            end;
    end;

    local procedure FindPurchOrder(BuyFromVendorNo: Code[20]; var PayToVendor: Record Vendor; ReceivedDate: Date; var PurchOrder: Record "Purchase Header"; PurchOrderType: Integer): Boolean
    var
        PurchOrder2: Record "Purchase Header";
    begin
        with PurchOrder2 do begin
            SetCurrentKey(
              "Buy-from Vendor No.", "Pay-to Vendor No.", "Commodity Item No.", "Commodity P.O. Type");
            SetRange("Document Type", "Document Type"::Order);
            SetRange("Buy-from Vendor No.", BuyFromVendorNo);
            SetRange("Pay-to Vendor No.", PayToVendor."No.");
            SetRange("Commodity Manifest Order", true);
            SetRange("Commodity P.O. Type", PurchOrderType);
            SetRange("Commodity Item No.", CommManifestHeader."Item No.");
            SetRange("Comm. Receiving Complete", false);
            case PayToVendor."Commodity Invoicing Frequency" of
                PayToVendor."Commodity Invoicing Frequency"::Manifest:
                    SetRange("Comm. P.O. Manifest No.", CommManifestHeader."No.");
                PayToVendor."Commodity Invoicing Frequency"::Monthly:
                    begin
                        SetFilter("Comm. P.O. Start Date", '..%1', ReceivedDate);
                        SetFilter("Comm. P.O. End Date", '%1..', ReceivedDate);
                    end;
            end;
            if not FindFirst then
                exit(false);
            PurchOrder.Get("Document Type", "No.");
            exit(true);
        end;
    end;

    local procedure CreatePurchOrderHeader(BuyFromVendorNo: Code[20]; var PayToVendor: Record Vendor; ReceivedDate: Date; var PurchOrder: Record "Purchase Header"; PurchOrderType: Integer)
    var
        PurchSetup: Record "Purchases & Payables Setup";
        PurchLine: Record "Purchase Line";
        PurchOrder2: Record "Purchase Header";
    begin
        PurchSetup.Get;
        PurchLine.LockTable;
        with PurchOrder2 do begin
            "Document Type" := "Document Type"::Order;
            SetRange("Buy-from Vendor No.", BuyFromVendorNo);
            "Commodity Manifest Order" := true;
            "Commodity P.O. Type" := PurchOrderType;
            "Commodity Item No." := CommManifestHeader."Item No.";
            "No. Series" := PurchSetup."Commodity Order Nos.";
            if ("No. Series" <> '') then
                "No." := NoSeriesMgt.GetNextNo("No. Series", CommManifestHeader."Posting Date", true);
            case PayToVendor."Commodity Invoicing Frequency" of
                PayToVendor."Commodity Invoicing Frequency"::Manifest:
                    "Comm. P.O. Manifest No." := CommManifestHeader."No.";
                PayToVendor."Commodity Invoicing Frequency"::Monthly:
                    begin
                        "Comm. P.O. Start Date" := CalcDate('-CM', ReceivedDate);
                        "Comm. P.O. End Date" := CalcDate('CM', ReceivedDate);
                    end;
            end;
            SetHideValidationDialog(true);
            Insert(true);
            if ("Pay-to Vendor No." <> PayToVendor."No.") then
                Validate("Pay-to Vendor No.", PayToVendor."No.");
            Validate("Location Code", CommManifestHeader."Location Code");
            Modify(true);
            PurchOrder.Get("Document Type", "No.");
        end;
    end;

    local procedure CreatePurchOrderLine(var CommManifestLine: Record "Commodity Manifest Line"; var PurchOrder: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
    begin
        with PurchLine do begin
            SetRange("Document Type", "Document Type"::Order);
            SetRange("Document No.", PurchOrder."No.");
            if not FindLast then
                "Line No." := 0;
            "Line No." := "Line No." + 10000;
            Init;
            Validate("Document Type", PurchOrder."Document Type");
            Validate("Document No.", PurchOrder."No.");
            Validate(Type, Type::Item);
            Validate("No.", CommManifestHeader."Item No.");
            Validate("Location Code", CommManifestHeader."Location Code");
            Validate("Commodity P.O. Type", PurchOrder."Commodity P.O. Type");
            Validate("Commodity Manifest No.", CommManifestLine."Commodity Manifest No.");
            Validate("Commodity Manifest Line No.", CommManifestLine."Line No.");
            SetPurchOrderLineFields(CommManifestLine, PurchLine);
            Insert(true);
            CreatePurchLineTracking(CommManifestLine, PurchLine);
        end;
    end;

    local procedure RecreatePurchOrderLine(var CommManifestLine: Record "Commodity Manifest Line"; var PurchOrder: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
    begin
        CommManifestLine.CalcFields("Purch. Order Line No.");
        with PurchLine do begin
            Get("Document Type"::Order, PurchOrder."No.", CommManifestLine."Purch. Order Line No.");
            ReservePurchLine.SetDeleteItemTracking;
            ReservePurchLine.DeleteLine(PurchLine);
            SetPurchOrderLineFields(CommManifestLine, PurchLine);
            Modify(true);
            CreatePurchLineTracking(CommManifestLine, PurchLine);
        end;
    end;

    local procedure SetPurchOrderLineFields(var CommManifestLine: Record "Commodity Manifest Line"; var PurchLine: Record "Purchase Line")
    begin
        with PurchLine do begin
            Validate("Variant Code", CommManifestHeader."Variant Code");
            Validate("Bin Code", CommManifestHeader."Bin Code");
            Validate("Unit of Measure Code", CommManifestHeader."Unit of Measure Code");
            Validate(Quantity, CommManifestLine."Manifest Quantity");
            Validate("Qty. to Receive", Quantity);
            Validate("Qty. to Invoice", Quantity);
            "Commodity Received Lot No." := CommManifestLine."Received Lot No.";
            "Commodity Received Date" := CommManifestLine."Received Date";
            "Commodity Cost Calculated" := false;
            "Rejection Action" := CommManifestLine."Rejection Action";
            Validate("Comm. Payment Class Code", Item."Comm. Payment Class Code");
        end;
    end;

    local procedure CreatePurchLineTracking(var CommManifestLine: Record "Commodity Manifest Line"; var PurchLine: Record "Purchase Line")
    begin
        with PurchLine do begin
            CreateReservEntry.CreateReservEntryFor(
              DATABASE::"Purchase Line", "Document Type", "Document No.", '', 0, "Line No.",
              "Qty. per Unit of Measure", Quantity, "Quantity (Base)", '', CommManifestLine."Received Lot No."); // P8001132
            CreateReservEntry.CreateEntry(
              "No.", "Variant Code", "Location Code", '', CommManifestLine."Received Date", 0D, 0, 2);
        end;
    end;

    local procedure Create1HaulerPO(var CommManifestLine: Record "Commodity Manifest Line")
    var
        PayToVendor: Record Vendor;
        PurchOrder: Record "Purchase Header";
    begin
        with CommManifestLine do begin
            PayToVendor.Get(CommManifestHeader."Hauler No.");
            if (PayToVendor."Pay-to Vendor No." <> '') then
                PayToVendor.Get(PayToVendor."Pay-to Vendor No.");
            if not FindPurchOrder(
                     CommManifestHeader."Hauler No.", PayToVendor, "Received Date",
                     PurchOrder, PurchOrder."Commodity P.O. Type"::Hauler)
            then
                CreatePurchOrderHeader(
                  CommManifestHeader."Hauler No.", PayToVendor, "Received Date",
                  PurchOrder, PurchOrder."Commodity P.O. Type"::Hauler);
            ReleasePurchDoc.Reopen(PurchOrder);
            CalcFields("Hauler P.O. No.");
            if ("Hauler P.O. No." = '') then
                CreateHaulerPOLine(CommManifestLine, PayToVendor, PurchOrder)
            else
                if ("Hauler P.O. No." = PurchOrder."No.") then
                    RecreateHaulerPOLine(CommManifestLine, PayToVendor, PurchOrder)
                else begin
                    DeletePurchOrderLine;
                    CreateHaulerPOLine(CommManifestLine, PayToVendor, PurchOrder);
                end;
            ReleasePurchDoc.Run(PurchOrder);
        end;
    end;

    local procedure CreateHaulerPOLine(var CommManifestLine: Record "Commodity Manifest Line"; var PayToVendor: Record Vendor; var PurchOrder: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
    begin
        with PurchLine do begin
            SetRange("Document Type", "Document Type"::Order);
            SetRange("Document No.", PurchOrder."No.");
            if not FindLast then
                "Line No." := 0;
            "Line No." := "Line No." + 10000;
            Init;
            SetHaulerPOLineFields(CommManifestLine, PayToVendor, PurchOrder, PurchLine);
            Insert(true);
        end;
    end;

    local procedure RecreateHaulerPOLine(var CommManifestLine: Record "Commodity Manifest Line"; var PayToVendor: Record Vendor; var PurchOrder: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
    begin
        CommManifestLine.CalcFields("Hauler P.O. Line No.");
        with PurchLine do begin
            Get("Document Type"::Order, PurchOrder."No.", CommManifestLine."Hauler P.O. Line No.");
            Init;
            SetHaulerPOLineFields(CommManifestLine, PayToVendor, PurchOrder, PurchLine);
            Modify(true);
        end;
    end;

    local procedure SetHaulerPOLineFields(var CommManifestLine: Record "Commodity Manifest Line"; var PayToVendor: Record Vendor; var PurchOrder: Record "Purchase Header"; var PurchLine: Record "Purchase Line")
    var
        VendorPostingGroup: Record "Vendor Posting Group";
        Producer: Record Vendor;
    begin
        with PurchLine do begin
            PayToVendor.TestField("Vendor Posting Group");
            VendorPostingGroup.Get(PayToVendor."Vendor Posting Group");
            //VendorPostingGroup.TESTFIELD("Hauler Charge Account"); // P80053245
            Producer.Get(CommManifestLine."Vendor No.");
            Producer.TestField("Producer Zone Code");
            Validate("Document Type", PurchOrder."Document Type");
            Validate("Document No.", PurchOrder."No.");
            Validate(Type, Type::"G/L Account");
            Validate("No.", VendorPostingGroup.GetHaulerChargeAccount); // P80053245
            if ("Gen. Prod. Posting Group" = '') then begin
                Item.TestField("Gen. Prod. Posting Group");
                Validate("Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group");
            end;
            Validate("Unit of Measure Code", CommManifestHeader."Unit of Measure Code");
            Validate(Quantity, CommManifestLine."Manifest Quantity");
            Validate("Qty. to Receive", Quantity);
            Validate("Qty. to Invoice", Quantity);
            Validate("Location Code", CommManifestHeader."Location Code");
            "Commodity Received Date" := CommManifestLine."Received Date";
            "Commodity P.O. Type" := PurchOrder."Commodity P.O. Type";
            "Commodity Manifest No." := CommManifestLine."Commodity Manifest No.";
            "Commodity Manifest Line No." := CommManifestLine."Line No.";
            Validate("Producer Zone Code", Producer."Producer Zone Code");
        end;
    end;

    local procedure PostPurchOrders(var TempOrderToPost: Record "Item Ledger Entry" temporary)
    var
        TempOrderToPostNo: Integer;
        CommManifestLine: Record "Commodity Manifest Line";
        PurchOrder: Record "Purchase Header";
        StatusWindow: Dialog;
        RcptCount: Integer;
        BatchConfirm: Option;
    begin
        if ShowStatusWindow() then begin
            StatusWindow.Open('#1############################\\' + Text002);
            StatusWindow.Update(1, StrSubstNo(Text000, CommManifestHeader."No."));
        end;
        with CommManifestLine do begin
            SetCurrentKey("Commodity Manifest No.", "Vendor No.", "Received Date");
            SetRange("Commodity Manifest No.", CommManifestHeader."No.");
            SetRange("Purch. Order Status", "Purch. Order Status"::Created);
            if FindSet then begin
                TempOrderToPost.SetCurrentKey("Document No.", "Document Type", "Document Line No.");
                repeat
                    CalcFields("Purch. Order No.");
                    AddTempOrderToPost("Purch. Order No.", "Received Date", TempOrderToPost, TempOrderToPostNo);
                until (Next = 0);
            end;
        end;
        with TempOrderToPost do begin
            Reset;
            SetCurrentKey("Document No.", "Document Type", "Document Line No.");
            if FindSet then
                repeat
                    RcptCount := RcptCount + 1;
                    if ShowStatusWindow() then
                        StatusWindow.Update(2, RcptCount);
                    PurchOrder.Get(PurchOrder."Document Type"::Order, "Document No.");
                    PurchOrder."Posting Comm. Manifest No." := CommManifestHeader."No.";
                    PurchOrder.Receive := true;
                    PurchOrder.Invoice := false;
                    PurchOrder.Ship := false;
                    Clear(PurchPost);
                    PurchOrder.BatchConfirmUpdateDeferralDate(BatchConfirm, true, "Posting Date"); // P80053245
                    PurchPost.Run(PurchOrder);
                    if (PurchOrder."Comm. P.O. Manifest No." <> '') then begin
                        PurchOrder."Comm. Receiving Complete" := true;
                        PurchOrder.Modify;
                    end;
                    Commit;
                until (Next = 0);
        end;
        if ShowStatusWindow() then
            StatusWindow.Close;
    end;

    local procedure AddTempOrderToPost(PurchOrderNo: Code[20]; ReceivedDate: Date; var TempOrderToPost: Record "Item Ledger Entry" temporary; var TempOrderToPostNo: Integer)
    begin
        TempOrderToPost.SetRange("Document No.", PurchOrderNo);
        TempOrderToPost.SetRange("Posting Date", ReceivedDate);
        if TempOrderToPost.IsEmpty then begin
            TempOrderToPostNo := TempOrderToPostNo + 1;
            TempOrderToPost."Entry No." := TempOrderToPostNo;
            TempOrderToPost."Document No." := PurchOrderNo;
            TempOrderToPost."Document Line No." := TempOrderToPostNo;
            TempOrderToPost."Posting Date" := ReceivedDate;
            TempOrderToPost.Insert;
        end;
    end;

    local procedure PostManifest(var TempOrderToPost: Record "Item Ledger Entry" temporary)
    var
        StatusWindow: Dialog;
    begin
        if ShowStatusWindow() then
            StatusWindow.Open(StrSubstNo(Text000, CommManifestHeader."No."));
        InitForPost;
        CombineLots.RegisterManifest(CommManifestHeader);
        TransferRegisters;
        PostLotAdjustment;
        if CommManifestHeader."Product Rejected" then
            PostLotRejection
        else
            PostLotMoveToDestBins;
        CreatePostedManifest(TempOrderToPost);
        Commit;
        if ShowStatusWindow() then
            StatusWindow.Close;
    end;

    local procedure InitForPost()
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        Clear(CombineLots);
        Clear(P800WhseActCreate);
        with SourceCodeSetup do begin
            Get;
            CombineLots.SetSourceCode("Commodity Manifest");
            P800WhseActCreate.SetSourceCode("Commodity Manifest");
        end;
        with CommManifestHeader do begin
            CombineLots.SetPostingDate("Posting Date");
            CombineLots.SetDocumentNo("Receiving No.");
            P800WhseActCreate.SetRegisterDate("Posting Date");
            P800WhseActCreate.SetItemPostingDocNo("Receiving No.");
            P800WhseActCreate.SetItemPosting(true);
        end;
    end;

    local procedure TransferRegisters()
    var
        ItemReg2: Record "Item Register";
        ItemApplnEntryNo2: Integer;
        WhseReg2: Record "Warehouse Register";
        GLReg2: Record "G/L Register";
        NextVATEntryNo2: Integer;
        NextTransactionNo2: Integer;
    begin
        CombineLots.GetRegisters(ItemReg2, ItemApplnEntryNo2, WhseReg2, GLReg2, NextVATEntryNo2, NextTransactionNo2);
        P800WhseActCreate.SetRegisters(ItemReg2, ItemApplnEntryNo2, WhseReg2, GLReg2, NextVATEntryNo2, NextTransactionNo2);
    end;

    local procedure PostLotAdjustment()
    var
        ExcessQty: Decimal;
    begin
        with CommManifestHeader do begin
            CalcFields("Manifest Quantity");
            ExcessQty := "Manifest Quantity" - "Received Quantity";
            if (ExcessQty <> 0) then
                P800WhseActCreate.RegisterAdjmt(
                  "Location Code", "Bin Code", "Item No.", "Variant Code", '', "Lot No.", '', -GetBaseQty(ExcessQty));
        end;
    end;

    local procedure PostLotRejection()
    begin
        with CommManifestHeader do
            P800WhseActCreate.RegisterAdjmt(
              "Location Code", "Bin Code", "Item No.", "Variant Code", '', "Lot No.", '', -GetBaseQty("Received Quantity"));
    end;

    local procedure PostLotMoveToDestBins()
    var
        CommManifestDestBin: Record "Commodity Manifest Dest. Bin";
    begin
        P800WhseActCreate.ClearSpecification;
        with CommManifestHeader do begin
            CommManifestDestBin.SetRange("Commodity Manifest No.", "No.");
            CommManifestDestBin.FindSet;
            repeat
                P800WhseActCreate.AddToSpecification(
                  "Location Code", "Bin Code", CommManifestDestBin."Bin Code", "Item No.", "Variant Code",
                  '', "Lot No.", '', GetBaseQty(CommManifestDestBin.Quantity));
            until (CommManifestDestBin.Next = 0);
        end;
        P800WhseActCreate.RegisterMoveFromSpecification;
    end;

    local procedure CreatePostedManifest(var TempOrderToPost: Record "Item Ledger Entry" temporary)
    var
        CommManifestLine: Record "Commodity Manifest Line";
        CommManifestDestBin: Record "Commodity Manifest Dest. Bin";
        PstdCommManifest: Record "Posted Comm. Manifest Header";
        PstdCommManifestLine: Record "Posted Comm. Manifest Line";
        PstdCommManifestDestBin: Record "Pstd. Comm. Manifest Dest. Bin";
        PurchLine: Record "Purchase Line";
        PurchLine2: Record "Purchase Line";
        PurchOrder: Record "Purchase Header";
    begin
        PstdCommManifest.TransferFields(CommManifestHeader);
        PstdCommManifest."No." := CommManifestHeader."Receiving No.";
        PstdCommManifest."Commodity Manifest No." := CommManifestHeader."No.";
        PstdCommManifest.Insert;
        PstdCommManifest.CopyLinks(CommManifestHeader);
        with CommManifestLine do begin
            SetRange("Commodity Manifest No.", CommManifestHeader."No.");
            FindSet;
            repeat
                PstdCommManifestLine.TransferFields(CommManifestLine);
                PstdCommManifestLine."Posted Comm. Manifest No." := PstdCommManifest."No.";
                PstdCommManifestLine.Insert;
            until (Next = 0);
        end;
        with CommManifestDestBin do begin
            SetRange("Commodity Manifest No.", CommManifestHeader."No.");
            if FindSet then
                repeat
                    PstdCommManifestDestBin.TransferFields(CommManifestDestBin);
                    PstdCommManifestDestBin."Posted Comm. Manifest No." := PstdCommManifest."No.";
                    PstdCommManifestDestBin.Insert;
                until (Next = 0);
        end;
        CommManifestLine.DeleteAll;
        CommManifestDestBin.DeleteAll;
        if (PstdCommManifest."No." <> CommManifestHeader."No.") then begin
            with PurchLine do begin
                SetCurrentKey("Commodity Manifest No.", "Commodity Manifest Line No.");
                SetRange("Commodity Manifest No.", CommManifestHeader."No.");
                if FindSet then
                    repeat
                        PurchLine2 := PurchLine;
                        PurchLine2."Commodity Manifest No." := PstdCommManifest."No.";
                        PurchLine2.Description := StrSubstNo(Text007, PstdCommManifest."No.");
                        PurchLine2.Modify;
                    until (Next = 0);
            end;
            TempOrderToPost.Reset;
            TempOrderToPost.SetCurrentKey("Document No.", "Document Type", "Document Line No.");
            if TempOrderToPost.FindSet then
                repeat
                    PurchOrder.Get(PurchOrder."Document Type"::Order, TempOrderToPost."Document No.");
                    if (PurchOrder."Comm. P.O. Manifest No." = CommManifestHeader."No.") then begin
                        PurchOrder."Comm. P.O. Manifest No." := PstdCommManifest."No.";
                        PurchOrder.Modify;
                    end;
                until (TempOrderToPost.Next = 0);
        end;
        if CommManifestHeader.HasLinks then
            CommManifestHeader.DeleteLinks;
        CommManifestHeader.Delete;
    end;

    procedure SetHideGUI(NewHideGUI: Boolean)
    begin
        HideGUI := NewHideGUI;
    end;

    local procedure ShowStatusWindow(): Boolean
    begin
        exit(GuiAllowed and (not HideGUI));
    end;
}

