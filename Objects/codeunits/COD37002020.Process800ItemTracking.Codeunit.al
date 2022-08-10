codeunit 37002020 "Process 800 Item Tracking"
{
    // PR3.61
    //   Add functions to support physical count
    //     ItemJnlValidateLot
    //     ItemJnlValidateSerial
    //     ItemJnlInsertPhysical
    //     ItemJnlModifyPhysical
    //     ItemJnlDeletePhysical
    //     ItemJnlLineSplitPhysical
    // 
    // PR3.61.01
    //   Don't allow multiple postings of the same lot unless it's the same document
    // 
    // P3.61.02
    //   Modify PostLotData to allow positive correcting entries
    //   Use Text Constant for error message
    // 
    // PR3.70
    //   Remove referneces to Bin Code in reservation entry
    // 
    // PR3.70.01
    //   Set receiving reason code, farm, and brand when updating lot info
    //   Allow positive adjustments to existing lots for repacking
    //   Allow Loose Lot Control when posting lot tracked items
    //   New Function - GetDocumentLineLotInfo
    // 
    // PR3.70.03
    //    To Function PostLotData
    //      added additional test for entry type = consumption and Negative Qty
    // 
    // PR3.70.04
    // P8000043A, Myers Nissi, Jack Reynolds, 30 MAY 04
    //   ItemJnlValidateLot - if not physical then check for multiple lots; call UpdateLotTacking
    // 
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Maintain item category code and production date on lots
    //   Support for checking lot preferences
    // 
    // PR3.70.09
    // P8000194A, Myers Nissi, Jack Reynolds, 24 FEB 05
    //   Fix easy lot tracking problem to save record before creating tracking lines
    // 
    // PR3.70.09
    // P8000194A, Myers Nissi, Jack Reynolds, 24 FEB 05
    //   Fix easy lot tracking problem to save record before creating tracking lines
    // 
    // PR3.70.10
    // P8000227A, Myers Nissi, Jack Reynolds, 07 JUL 05
    //   Fix problem specifying lot before line has been inserted
    // 
    // P8000229A, Myers Nissi, Jack Reynolds, 12 JUL 05
    //   Create lot information record on positive adjustment if loose lot control is allowed
    // 
    // PR4.00
    // P8000250B, Myers Nissi, Jack Reynolds, 16 OCT 05
    //   Support for alternate methods of lot number assignment and automatic lot number assignment
    // 
    // PR4.00.01
    // P8000267B, VerticalSoft, Jack Reynolds, 12 DEC 05
    //   Changes to Item Ledger keys
    // 
    // P8000270A, VerticalSoft, Jack Reynolds, 06 DEC 05
    //   Close loophole that allows posting of positive adjstment with loose lot control turned off
    // 
    // PR4.00.02
    // P8000299A, VerticalSoft, Jack Reynolds, 21 FEB 06
    //   AutoAssignLotNo - change DocNo and xDocNo parameters to Code20
    // 
    // P8000318A, VerticalSoft, Jack Reynolds, 03 APR 06
    //   Fix bug with auto lot number assignment
    // 
    // PR4.00.03
    // P8000343A, VerticalSoft, Jack Reynolds, 05 JUN 06
    //   Modify to support easy lot tracking and creation of lot info record for new lot
    // 
    // PR4.00.04
    // P8000349A, VerticalSoft, Jack Reynolds, 10 JUL 06
    //   Fix problem with updating reservation entries for alt. qty. items and for split adjustments (i.e.
    //     ase is one direction and alternate is the opposite)
    // 
    // PR4.00.05
    // P8000419A, VerticalSoft, Jack Reynolds, 21 NOV 06
    //   GetLotNoForProdOrderLine - fix problem incorrectly indicating MULTIPLE lots
    // 
    // PR4.00.06
    // P8000496A, VerticalSoft, Jack Reynolds, 23 JUL 07
    //   Update lot infor records for repack orders
    // 
    // P8000502A, VerticalSoft, Jack Reynolds, 06 AUG 07
    //   Fix problem with assigning lot numbers for item journal lines
    // 
    // PRW15.00.01
    // P8000566A, VerticalSoft, Jack Reynolds, 28 MAY 08
    //   Fix problem with reclass, lot tracking, and alternate quantity
    // 
    // P8000574A, VerticalSoft, Jack Reynolds, 14 FEB 08
    //   CreateLotNoInfo - fix incorrect assignemnt of Source Type for purchase lines
    // 
    // P8000585A, VerticalSoft, Jack Reynolds, 03 MAR 08
    //   Add function called during Undo postiong to undo the setting of lot info
    // 
    // PRW15.00.03
    // P8000624A, VerticalSoft, Jack Reynolds, 19 AUG 08
    //   Set Country/Region of Origin on Lot Info record
    // 
    // PRW16.00.04
    // P8000899, Columbus IT, Ron Davidson, 01 MAR 11
    //   Added Lot Freshness logic.
    // 
    // PRW16.00.05
    // P8000935, Columbus IT, Jack Reynolds, 22 APR 11
    //   Check Country of Origin at Release
    // 
    // P8000938, Columbus IT, Jack Reynolds, 02 MAY 11
    //   Set default Country of Origin
    // 
    // P8000969, Columbus IT, Jack Reynolds, 12 AUG 11
    //   Fix problem with Freshness Calc. Method
    // 
    // P8000992, Columbus IT, Jack Reynolds, 01 NOV 11
    //   Support for new ADC Receiving transaction that updates lot information prior to posting
    // 
    // PRW16.00.06
    // P8001027, Columbus IT, Jack Reynolds, 26 JAN 12
    //   Fix error with checking freshness if lot has not been posted
    // 
    // P8001060, Columbus IT, Jack Reynolds, 23 APR 12
    //   Allow freshness preference to be specified for All Items
    // 
    // P8001062, Columbus IT, Jack Reynolds, 26 APR 12
    //   Lot freshness preference override on sales line
    // 
    // P8001070, Columbus IT, Jack Reynolds, 16 MAY 12
    //   Bring Lot Freshness and Lot Preferences together
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // P8001106, Columbus IT, Don Bresee, 16 OCT 12
    //   Add "Supplier Lot No." to lot posting
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.10
    // P8001234, Columbus IT, Jack Reynolds, 01 NOV 13
    //    Support for custom lot number formats
    // 
    // PRW17.10.01
    // P8001251, Columbus IT, Jack Reynolds, 13 DEC 13
    //   Fix problem clearing lot number field on item journal line
    // 
    // PRW18.00.02
    // P8004239, To-Increase, Jack Reynolds, 26 OCT 15
    //   fix problem creating new lot from old lot with reclass
    // 
    // PRW19.00.01
    // P8007474, To-Increase, Jack Reynolds, 29 JUL 16
    //   Replace use of Item Journal Line Repack field with Order Type field
    // 
    // P8008351, To-Increase, Jack Reynolds, 26 JAN 17
    //   Support for Lot Creation Date and Country of Origin for multiple lots
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // PRW118.1
    // P800129613, To Increase, Jack Reynolds, 20 SEP 21
    //   Creatre Sub-Lot Wizard


    trigger OnRun()
    begin
    end;

    var
        Text001: Label 'MULTIPLE';
        ProcessFns: Codeunit "Process 800 Functions";
        Text002: Label 'may not be edited';
        SplitItemJnlLine: Record "Item Journal Line";
        SplitResEntry: Record "Reservation Entry";
        SplitAltQtyLine: Record "Alternate Quantity Line";
        P800Globals: Codeunit "Process 800 System Globals";
        AltQtySplit: Integer;
        Text004: Label 'Only a single alternate quantity line may be entered.';
        Text005: Label '%1 %2, %3 %4 has already been posted.';
        Text006: Label 'Lot %1 fails to meet established lot preferences.';
        Text007: Label 'No document number is available to use for lot number.';
        Text008: Label 'No date is available to use for lot number.';
        Text009: Label '%1 %2, %3 %4 has not been posted.';
        Text010: Label 'may not be changed from %1';
        Text011: Label 'may not be changed to %1';

    procedure LotStatus(TrackingSpec: Record "Tracking Specification"; Operation: Code[10]; AllowLooseLotControl: Boolean): Boolean
    var
        ItemJnlLine: Record "Item Journal Line";
        LotNoInfo: Record "Lot No. Information";
    begin
        // LotStatus
        // P8000229A - add parameter for AllowLooseLotControl
        with TrackingSpec do begin
            if (not Positive) and
              // P8000343A
              (("Source Type" <> DATABASE::"Item Journal Line") or ("Source Subtype" <> ItemJnlLine."Entry Type"::Transfer))
            then
                // P8000343A
                exit(false);

            case Operation of
                'DELETE': // Lot should be deleted if exists and not posted
                    begin
                        if LotNoInfo.Get("Item No.", "Variant Code", "Lot No.") then
                            exit(not LotNoInfo.Posted);
                        exit(true);
                    end;

                'CREATE': // Can't create lots by negative consumption or positive adjustments (except physical count)
                    begin
                        if "Source Type" = DATABASE::"Item Journal Line" then begin
                            case "Source Subtype" of
                                ItemJnlLine."Entry Type"::"Positive Adjmt.":
                                    begin
                                        if "Phys. Inventory" or AllowLooseLotControl then // P8000229A
                                            exit(not LotNoInfo.Get("Item No.", "Variant Code", "Lot No."))
                                        else
                                            exit(false);
                                    end;
                                ItemJnlLine."Entry Type"::Consumption:
                                    // P8000229A Begin
                                    if AllowLooseLotControl then
                                        exit(not LotNoInfo.Get("Item No.", "Variant Code", "Lot No."))
                                    else
                                        exit(false);
                                // P8000229A End
                                // P8000343A
                                ItemJnlLine."Entry Type"::Transfer:
                                    if AllowLooseLotControl then
                                        exit(not LotNoInfo.Get("Item No.", "Variant Code", "New Lot No."))
                                    else
                                        exit("Lot No." <> "New Lot No."); // P8004239
                                                                          // P8000343A
                                else
                                    exit(not LotNoInfo.Get("Item No.", "Variant Code", "Lot No."))
                            end;
                        end;
                        exit(not LotNoInfo.Get("Item No.", "Variant Code", "Lot No."));
                    end;
            end;
        end;
    end;

    procedure CreateLotNoInfo(var TrackingSpec: Record "Tracking Specification"; var LotNoInfo: Record "Lot No. Information")
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        ItemJnlLine: Record "Item Journal Line";
        LotNoInfo2: Record "Lot No. Information";
    begin
        // CreateLotNoInfo
        with TrackingSpec do begin
            if "Lot No." = '' then
                exit;

            Item.Get("Item No.");

            // P8000343A
            if TrackingSpec."Source Subtype" = ItemJnlLine."Entry Type"::Transfer then begin
                LotNoInfo.Get("Item No.", "Variant Code", "Lot No.");
                if LotNoInfo2.Get("Item No.", "Variant Code", "New Lot No.") then
                    exit;
                LotNoInfo2 := LotNoInfo;
                LotNoInfo2."Lot No." := "New Lot No.";
                LotNoInfo2."Lot Status Code" := "New Lot Status Code"; // P8001083
                LotNoInfo2.Insert;
                "New Expiration Date" := LotNoInfo."Expiration Date"; // P8001083
                CopyLotData(LotNoInfo, LotNoInfo2); // P8001083
            end else begin
                // P8000343A
                LotNoInfo.Init;
                LotNoInfo."Item No." := "Item No.";
                LotNoInfo."Variant Code" := "Variant Code";
                LotNoInfo."Lot No." := "Lot No.";
                LotNoInfo.Description := Item.Description;
                LotNoInfo."Item Category Code" := Item."Item Category Code"; // P8000153A
                if "Source Type" = DATABASE::"Sales Line" then begin
                    SalesHeader.Get("Source Subtype", "Source ID");
                    LotNoInfo."Source Type" := LotNoInfo."Source Type"::Customer;
                    LotNoInfo."Source No." := SalesHeader."Sell-to Customer No.";
                end else
                    if "Source Type" = DATABASE::"Purchase Line" then begin
                        PurchaseHeader.Get("Source Subtype", "Source ID");
                        LotNoInfo."Source Type" := LotNoInfo."Source Type"::Vendor; // P8000574A
                        LotNoInfo."Source No." := PurchaseHeader."Buy-from Vendor No.";
                    end;
                LotNoInfo.Insert;
            end; // P8000343A
        end;
    end;

    procedure PostLotData(ItemJnlLine: Record "Item Journal Line"; EntryType: Integer; var LotNoInfo: Record "Lot No. Information"; AllowLooseLotControl: Boolean; ExpDate: Date; RelDate: Date)
    var
        Item: Record Item;
        InvSetup: Record "Inventory Setup";
        P800QCFns: Codeunit "Process 800 Q/C Functions";
    begin
        if ItemJnlLine.Correction then // PR3.61.02
            exit;                        // PR3.61.02
        ItemJnlLine."Entry Type" := EntryType;
        if not ItemJnlIsPositive(ItemJnlLine) then
            exit;
        // PR3.61.01 Begin
        if LotNoInfo.Posted then begin
            if AllowLooseLotControl or // PR3.70.01
              ItemJnlLine."Phys. Inventory" or
              (ItemJnlLine."Order Type" in [ItemJnlLine."Order Type"::FOODRepack, ItemJnlLine."Order Type"::FOODSalesRepack]) or // PR3.70.01, P8001083, P8007474
              ((ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Consumption) and (ItemJnlLine.Quantity < 0)) or // PR3.70.03
              ((LotNoInfo."Document No." = ItemJnlLine."Document No.") and
               (LotNoInfo."Source Type" = ItemJnlLine."Source Type") and
               (LotNoInfo."Source No." = ItemJnlLine."Source No."))
            then
                exit;
            Error(Text005, // PR3.61.02
              LotNoInfo.FieldCaption("Item No."), LotNoInfo."Item No.",
              LotNoInfo.FieldCaption("Lot No."), LotNoInfo."Lot No.");
            // P8000270A
        end else
            if not AllowLooseLotControl then begin
                if ((ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::"Positive Adjmt.") and // P8000496A
                    (not ItemJnlLine."Phys. Inventory") and                                      // P8000496A
                    (not (ItemJnlLine."Order Type" in [ItemJnlLine."Order Type"::FOODRepack, ItemJnlLine."Order Type"::FOODSalesRepack]))) or // P8000496A, P8001083, P8007474
                  ((ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Consumption) and (ItemJnlLine.Quantity < 0))
                then
                    Error(Text009,
                      LotNoInfo.FieldCaption("Item No."), LotNoInfo."Item No.",
                      LotNoInfo.FieldCaption("Lot No."), LotNoInfo."Lot No.");
                // P8000270A
            end;
        // PR3.61.01 End

        Item.Get(ItemJnlLine."Item No.");
        LotNoInfo."Document No." := ItemJnlLine."Document No.";
        LotNoInfo."Document Date" := ItemJnlLine."Document Date";
        LotNoInfo."Source Type" := ItemJnlLine."Source Type";
        LotNoInfo."Source No." := ItemJnlLine."Source No.";
        // PR3.70.01 Begin
        LotNoInfo."Receiving Reason Code" := ItemJnlLine."Receiving Reason Code";
        if LotNoInfo.Farm = '' then // P800992
            LotNoInfo.Farm := ItemJnlLine.Farm;
        if LotNoInfo.Brand = '' then // P800992
            LotNoInfo.Brand := ItemJnlLine.Brand;
        if LotNoInfo."Country/Region of Origin Code" = '' then // P800992
            LotNoInfo."Country/Region of Origin Code" := ItemJnlLine."Country/Region of Origin Code"; // P8000624A
        // PR3.70.01 End
        LotNoInfo."Expiration Date" := ExpDate;
        LotNoInfo."Release Date" := RelDate;
        if Format(Item."Quarantine Calculation") <> '' then
            LotNoInfo."Expected Release Date" := CalcDate(Item."Quarantine Calculation", ItemJnlLine."Document Date");
        if ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Output then // P8000153A
            ItemJnlLine."Creation Date" := ItemJnlLine."Document Date";        // P8000153A
        LotNoInfo.Posted := true;
        // P8000899
        if (Item."Freshness Calc. Method" > 0) and // P8000969, P8001062
           (LotNoInfo."Creation Date" = 0D) and // P800992
           (ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Purchase)
        then
            ItemJnlLine.TestField("Creation Date");
        if LotNoInfo."Creation Date" = 0D then // P800992
            LotNoInfo.Validate("Creation Date", ItemJnlLine."Creation Date");
        // P8000899
        if Item."Country/Region of Origin Reqd." then           // P8000624A
            LotNoInfo.TestField("Country/Region of Origin Code"); // P8000624A
        LotNoInfo.Modify; // P8001083, P80037569

        if ProcessFns.QCInstalled then begin
            InvSetup.Get;
            if ItemJnlLine."Phys. Inventory" then begin
                if InvSetup."Add Q/C Tests for Phys. Count" then
                    P800QCFns.CreateQCData(LotNoInfo, 1);
            end else
                P800QCFns.CreateQCData(LotNoInfo, 1);
        end;

        // P8001083
        LotNoInfo.CalcFields("Quality Control");
        if (LotNoInfo."Release Date" = 0D) and (not LotNoInfo."Quality Control") then
            LotNoInfo."Release Date" := ItemJnlLine."Document Date";
        LotNoInfo.SetDefaultStatus(ItemJnlLine);
        LotNoInfo.Modify;
        // P8001083
    end;

    procedure UndoPostLotData(ItemJnlLine: Record "Item Journal Line")
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        LotInfo: Record "Lot No. Information";
        xLotInfo: Record "Lot No. Information";
        PurchReceiptLine: Record "Purch. Rcpt. Line";
        QualityControl: Record "Quality Control Header";
        Item: Record Item;
        EntryNo: Integer;
        DatesSet: Boolean;
    begin
        // P8000585A
        if (not ItemJnlLine.Correction) or (ItemJnlLine."Applies-to Entry" = 0) or (ItemJnlLine."Lot No." = '') then
            exit;

        if not LotInfo.Get(ItemJnlLine."Item No.", ItemJnlLine."Variant Code", ItemJnlLine."Lot No.") then
            exit;

        ItemLedgerEntry.Get(ItemJnlLine."Applies-to Entry");

        if (not LotInfo.Posted) or
          (LotInfo."Document No." <> ItemLedgerEntry."Document No.") or
          (LotInfo."Document Date" <> ItemLedgerEntry."Document Date") or
          (LotInfo."Source Type" <> ItemLedgerEntry."Source Type") or
          (LotInfo."Source No." <> ItemLedgerEntry."Source No.")
        then
            exit;

        xLotInfo := LotInfo;

        LotInfo."Document No." := '';
        LotInfo."Document Date" := 0D;
        LotInfo."Source Type" := 0;
        LotInfo."Source No." := '';
        LotInfo."Receiving Reason Code" := '';
        LotInfo.Farm := '';
        LotInfo.Brand := '';
        LotInfo."Country/Region of Origin Code" := ''; // P8000624A
        LotInfo."Expiration Date" := 0D;
        LotInfo."Release Date" := 0D;
        LotInfo."Expected Release Date" := 0D;
        LotInfo.Posted := false;

        // Now look if there is another positive entry for the lot that should have been used to populate the lot info
        ItemLedgerEntry.SetCurrentKey("Item No.", "Variant Code", "Lot No.", Positive);
        ItemLedgerEntry.SetRange("Item No.", LotInfo."Item No.");
        ItemLedgerEntry.SetRange("Variant Code", LotInfo."Variant Code");
        ItemLedgerEntry.SetRange("Lot No.", LotInfo."Lot No.");
        ItemLedgerEntry.SetRange(Positive, true);
        ItemLedgerEntry.SetFilter("Entry No.", '>%1', ItemJnlLine."Applies-to Entry");
        if ItemLedgerEntry.FindSet then
            repeat
                if (EntryNo = 0) or (ItemLedgerEntry."Entry No." < EntryNo) then
                    EntryNo := ItemLedgerEntry."Entry No.";
            until ItemLedgerEntry.Next = 0;

        if EntryNo <> 0 then begin
            ItemLedgerEntry.Get(EntryNo);

            LotInfo."Document No." := ItemLedgerEntry."Document No.";
            LotInfo."Document Date" := ItemLedgerEntry."Document Date";
            LotInfo."Source Type" := ItemLedgerEntry."Source Type";
            LotInfo."Source No." := ItemLedgerEntry."Source No.";
            if ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Purchase Receipt" then
                if PurchReceiptLine.Get(ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.") then begin
                    LotInfo."Receiving Reason Code" := PurchReceiptLine."Receiving Reason Code";
                    LotInfo.Farm := PurchReceiptLine.Farm;
                    LotInfo.Brand := PurchReceiptLine.Brand;
                    LotInfo."Country/Region of Origin Code" := PurchReceiptLine."Country/Region of Origin Code"; // P8000624A
                end;
            LotInfo.Posted := true;
        end;

        LotInfo.CalcFields("Quality Control");
        if LotInfo."Quality Control" then begin
            QualityControl.SetRange("Item No.", LotInfo."Item No.");
            QualityControl.SetRange("Variant Code", LotInfo."Variant Code");
            QualityControl.SetRange("Lot No.", LotInfo."Lot No.");
            QualityControl.SetFilter(Status, '<>%1', QualityControl.Status::Pending);
            if QualityControl.FindFirst then begin
                LotInfo."Expected Release Date" := xLotInfo."Expected Release Date";
                LotInfo."Release Date" := xLotInfo."Release Date";
                LotInfo."Expiration Date" := xLotInfo."Expiration Date";
                DatesSet := true;
            end else
                if EntryNo = 0 then begin
                    QualityControl.SetRange(Status);
                    QualityControl.DeleteAll(true);
                end;
        end;
        if (not DatesSet) and (LotInfo."Document Date" <> 0D) then begin
            Item.Get(LotInfo."Item No.");
            if Format(Item."Expiration Calculation") <> '' then
                LotInfo."Expiration Date" := CalcDate(Item."Expiration Calculation", LotInfo."Document Date");
            if Format(Item."Quarantine Calculation") <> '' then begin
                LotInfo."Release Date" := 0D;
                LotInfo."Expected Release Date" := CalcDate(Item."Quarantine Calculation", LotInfo."Document Date");
            end else
                LotInfo."Release Date" := LotInfo."Document Date";
            LotInfo."Expected Release Date" := 0D;
        end;

        LotInfo.Modify;
    end;

    local procedure ItemJnlIsPositive(ItemJnlLine: Record "Item Journal Line") positive: Boolean
    begin
        // ItemJnlIsPositive
        with ItemJnlLine do
            positive := (("Entry Type" in ["Entry Type"::Purchase, "Entry Type"::"Positive Adjmt.",
                                           "Entry Type"::Output]) and
                         (Quantity > 0)) or
                        (("Entry Type" in ["Entry Type"::Sale, "Entry Type"::"Negative Adjmt.",
                                           "Entry Type"::Transfer, "Entry Type"::Consumption]) and
                         (Quantity < 0));
    end;

    procedure GetLotDates(ItemNo: Code[20]; VariantCode: Code[10]; LotNo: Code[50]; DocDate: Date; ItemTrackingCode: Record "Item Tracking Code"; var ExpDate: Date; var RelDate: Date)
    var
        Item: Record Item;
        LotNoInfo: Record "Lot No. Information";
    begin
        // GetLotDates
        ExpDate := 0D;
        RelDate := 0D;

        if LotNoInfo.Get(ItemNo, VariantCode, LotNo) then begin
            ExpDate := LotNoInfo."Expiration Date";
            RelDate := LotNoInfo."Release Date";
        end;

        Item.Get(ItemNo);
        if (ExpDate = 0D) and (Format(Item."Expiration Calculation") <> '') then
            ExpDate := CalcDate(Item."Expiration Calculation", DocDate);
        if RelDate = 0D then
            if Format(Item."Quarantine Calculation") <> '' then
                RelDate := 0D
            else
                RelDate := DocDate;
    end;

    procedure CheckLotUsable(ItemTrackingCode: Record "Item Tracking Code"; ItemLedgerEntry: Record "Item Ledger Entry")
    var
        Text001: Label ' is before the posting date.';
        LotNoInfo: Record "Lot No. Information";
        LotStatusMgmt: Codeunit "Lot Status Management";
    begin
        // CheckLotUsable
        // P8001070 - check for lot freshness has been removed
        // P8001083
        //IF NOT (ItemLedgerEntry."Entry Type" IN [ItemLedgerEntry."Entry Type"::Sale, ItemLedgerEntry."Entry Type"::Consumption]) THEN
        //  EXIT;
        // P8001083

        if not LotNoInfo.Get(ItemLedgerEntry."Item No.", ItemLedgerEntry."Variant Code", ItemLedgerEntry."Lot No.") then
            exit;

        if ItemTrackingCode."Strict Expiration Posting" and (LotNoInfo."Expiration Date" <> 0D) and                         // P8001083
          (ItemLedgerEntry."Entry Type" in [ItemLedgerEntry."Entry Type"::Sale, ItemLedgerEntry."Entry Type"::Consumption,  // P8001083, P8001132
            ItemLedgerEntry."Entry Type"::"Assembly Consumption"])                                                          // P8001132
        then                                                                                                                // P8001083
            if ItemLedgerEntry."Posting Date" > LotNoInfo."Expiration Date" then
                LotNoInfo.FieldError("Expiration Date", Text001);

        // P8001083
        //IF ItemTrackingCode."Strict Quarantine Posting" THEN
        //  IF (LotNoInfo."Release Date" = 0D) OR (ItemLedgerEntry."Posting Date" < LotNoInfo."Release Date") THEN
        //    LotNoInfo.FIELDERROR("Release Date",Text002);
        LotStatusMgmt.TestItemLedgerBlocked(LotNoInfo, ItemLedgerEntry);
        // P8001083
    end;

    procedure LotControlled(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        // LotControlled
        if not Item.Get(ItemNo) then
            exit(false);
        if Item."Item Tracking Code" <> '' then begin
            ItemTrackingCode.Get(Item."Item Tracking Code");
            exit(ItemTrackingCode."Lot Specific Tracking");
        end;
    end;

    procedure UpdateItemJnlPhysQty(ResEntry: Record "Reservation Entry")
    var
        ItemJnlLine: Record "Item Journal Line";
        ResEntry2: Record "Reservation Entry";
    begin
        // UpdateItemJnlPhysQty
        with ResEntry do begin
            ResEntry2.SetCurrentKey("Source Type", "Source ID", "Source Batch Name", "Source Ref. No.", "Lot No.", "Serial No.");
            ResEntry2.SetRange("Source Type", "Source Type");
            ResEntry2.SetRange("Source ID", "Source ID");
            ResEntry2.SetRange("Source Batch Name", "Source Batch Name");
            ResEntry2.SetRange("Source Ref. No.", "Source Ref. No.");
            ResEntry2.SetFilter("Entry No.", '<>%1', "Entry No.");
            ResEntry2.CalcSums("Qty. (Phys. Inventory)", "Qty. (Alt.) (Phys. Inventory)");
            ItemJnlLine.Get("Source ID", "Source Batch Name", "Source Ref. No.");
            ItemJnlLine.Validate("Qty. (Phys. Inventory)", ResEntry2."Qty. (Phys. Inventory)" + "Qty. (Phys. Inventory)");
            if ResEntry2."Qty. (Alt.) (Phys. Inventory)" <> 0 then
                ItemJnlLine.Validate("Qty. (Alt.) (Phys. Inventory)",
                  ResEntry2."Qty. (Alt.) (Phys. Inventory)" + "Qty. (Alt.) (Phys. Inventory)");
            ItemJnlLine.Modify;
        end;
    end;

    procedure TransferResEntryToItemJnlLine(ResEntry: Record "Reservation Entry"; var ItemJnlLine: Record "Item Journal Line")
    begin
        // TransferResEntryToItemJnlLine
        with ItemJnlLine do begin
            Quantity := ResEntry.Quantity;
            "Qty. (Calculated)" := ResEntry."Qty. (Calculated)";
            "Qty. (Phys. Inventory)" := ResEntry."Qty. (Phys. Inventory)";
            "Quantity (Alt.)" := ResEntry."Quantity (Alt.)";
            "Qty. (Alt.) (Calculated)" := ResEntry."Qty. (Alt.) (Calculated)";
            "Qty. (Alt.) (Phys. Inventory)" := ResEntry."Qty. (Alt.) (Phys. Inventory)";
            "Lot No." := ResEntry."Lot No.";
            "Serial No." := ResEntry."Serial No.";
        end;
    end;

    procedure TrackLinesExistForItemJnlLine(ItemJnlLine: Record "Item Journal Line"): Boolean
    var
        ResEntry: Record "Reservation Entry";
    begin
        // TrackLinesExistForItemJnlLine
        with ItemJnlLine do begin
            ResEntry.SetCurrentKey("Source Type", "Source ID", "Source Batch Name", "Source Ref. No.");
            ResEntry.SetRange("Source Type", DATABASE::"Item Journal Line");
            ResEntry.SetRange("Source ID", "Journal Template Name");
            ResEntry.SetRange("Source Batch Name", "Journal Batch Name");
            ResEntry.SetRange("Source Ref. No.", "Line No.");
            exit(ResEntry.Find('-'));
        end;
    end;

    procedure GetLotNoForProdOrderLine(ProdOrderLine: Record "Prod. Order Line") LotNo: Code[50]
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ResEntry: Record "Reservation Entry";
    begin
        // GetLotNoForProdOrderLine
        ResEntry.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line");
        ResEntry.SetRange("Source Type", DATABASE::"Prod. Order Line");
        ResEntry.SetRange("Source Subtype", ProdOrderLine.Status);
        ResEntry.SetRange("Source ID", ProdOrderLine."Prod. Order No.");
        ResEntry.SetRange("Source Prod. Order Line", ProdOrderLine."Line No.");
        if ResEntry.Find('-') then begin              // P8000419A
            LotNo := ResEntry."Lot No.";
            ResEntry.SetFilter("Lot No.", '<>%1', LotNo); // P8000419A
        end;                                          // P8000419A
        if ResEntry.Next <> 0 then
            exit(Text001);

        ItemLedgerEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type"); // P8000267B, P8001132
        ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Production); // P8001132
        ItemLedgerEntry.SetRange("Order No.", ProdOrderLine."Prod. Order No.");           // P8001132
        ItemLedgerEntry.SetRange("Order Line No.", ProdOrderLine."Line No.");             // P8001132
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Output);
        if LotNo <> '' then
            ItemLedgerEntry.SetFilter("Lot No.", '<>%1&<>%2', LotNo, '');
        if ItemLedgerEntry.Find('-') then begin
            if LotNo <> '' then
                exit(Text001);
            LotNo := ItemLedgerEntry."Lot No.";
            ItemLedgerEntry.SetFilter("Lot No.", '<>%1&<>%2', LotNo, ''); // P8000419A
            if ItemLedgerEntry.Next <> 0 then
                exit(Text001);
        end;
    end;

    procedure GetLotNoForProdOrderComp(ProdOrderComp: Record "Prod. Order Component") LotNo: Code[50]
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ResEntry: Record "Reservation Entry";
    begin
        // GetLotNoForProdOrderComp
        ResEntry.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line");
        ResEntry.SetRange("Source Type", DATABASE::"Prod. Order Component");
        ResEntry.SetRange("Source Subtype", ProdOrderComp.Status);
        ResEntry.SetRange("Source ID", ProdOrderComp."Prod. Order No.");
        ResEntry.SetRange("Source Prod. Order Line", ProdOrderComp."Prod. Order Line No.");
        ResEntry.SetRange("Source Ref. No.", ProdOrderComp."Line No.");
        if ResEntry.Find('-') then
            LotNo := ResEntry."Lot No.";
        if ResEntry.Next <> 0 then
            exit(Text001);


        ItemLedgerEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type"); // P8000267B, P8001132
        ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Production); // P8001132
        ItemLedgerEntry.SetRange("Order No.", ProdOrderComp."Prod. Order No.");           // P8001132
        ItemLedgerEntry.SetRange("Order Line No.", ProdOrderComp."Prod. Order Line No."); // P8001132
        ItemLedgerEntry.SetRange("Prod. Order Comp. Line No.", ProdOrderComp."Line No.");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Output);
        if LotNo <> '' then
            ItemLedgerEntry.SetFilter("Lot No.", '<>%1&<>%2', LotNo, '');
        if ItemLedgerEntry.Find('-') then begin
            if LotNo <> '' then
                exit(Text001);
            LotNo := ItemLedgerEntry."Lot No.";
            if ItemLedgerEntry.Next <> 0 then
                exit(Text001);
        end;
    end;

    procedure ItemJnlValidateLot(xRec: Record "Item Journal Line"; var Rec: Record "Item Journal Line")
    var
        Item: Record Item;
        ItemTracking: Record "Item Tracking Code";
        LotInfo: Record "Lot No. Information";
    begin
        // ItemJnlValdateLot
        // PR3.61 Begin
        if Rec."Phys. Inventory" then begin // P8000043A
            if xRec."Lot No." <> '' then
                Rec.FieldError("Lot No.", Text002); // P8000043A

            if Rec."Lot No." = '' then
                exit;

            Rec.TestField("Phys. Inventory", true);

            Item.Get(Rec."Item No.");
            Item.TestField("Item Tracking Code");
            ItemTracking.Get(Item."Item Tracking Code");
            ItemTracking.TestField("Lot Specific Tracking", true);

            if Rec."Line No." <> 0 then
                ItemJnlInsertPhysical(Rec);
        end else begin
            if xRec."Lot No." = P800Globals.MultipleLotCode then
                Rec.FieldError("Lot No.", Text002);
            // P8000153A Begin
            if Rec."Lot No." <> '' then
                if not Rec.CheckLotPreferences(Rec."Lot No.", true) then
                    Error(Text006, Rec."Lot No."); // P8001070
                                                   // P8000153A End
            if Rec."Entry Type" = Rec."Entry Type"::Transfer then // P8000566A
            begin // P8001083
                Rec."New Lot No." := Rec."Lot No.";                 // P8000566A
                                                                    // P8001083
                if LotInfo.Get(Rec."Item No.", Rec."Variant Code", Rec."Lot No.") then // P8001251
                    Rec."New Lot Status Code" := LotInfo."Lot Status Code"             // P8001251
                else                                                                 // P8001251
                    Rec."New Lot Status Code" := '';                                   // P8001251
            end;
            // P8001083
            if Rec."Line No." <> 0 then begin // P8000227A
                Rec.Modify; // P8000194A
                Rec.UpdateLotTracking(false);
            end;                              // P8000227A
        end;
        // PR3.61 End
    end;

    procedure ItemJnlValidateNewLot(xRec: Record "Item Journal Line"; var Rec: Record "Item Journal Line")
    var
        Item: Record Item;
        ItemTracking: Record "Item Tracking Code";
        LotInfo: Record "Lot No. Information";
    begin
        // P8000343A
        if xRec."New Lot No." = P800Globals.MultipleLotCode then
            Rec.FieldError("New Lot No.", Text002);
        // P8001083
        if LotInfo.Get(Rec."Item No.", Rec."Variant Code", Rec."New Lot No.") then
            Rec."New Lot Status Code" := LotInfo."Lot Status Code"
        else begin
            LotInfo.Get(Rec."Item No.", Rec."Variant Code", Rec."Lot No.");
            Rec."New Lot Status Code" := LotInfo."Lot Status Code"
        end;
        // P8001083
        if Rec."Line No." <> 0 then begin
            Rec.Modify;
            Rec.UpdateLotTracking(false);
        end;
    end;

    procedure ItemJnlValidateNewLotStatus(xRec: Record "Item Journal Line"; var Rec: Record "Item Journal Line")
    var
        InvSetup: Record "Inventory Setup";
    begin
        // P8001083
        if xRec."New Lot No." = P800Globals.MultipleLotCode then
            Rec.FieldError("New Lot No.", Text002);
        InvSetup.Get;
        if InvSetup."Quarantine Lot Status" = '' then
            exit;
        if xRec."New Lot Status Code" = InvSetup."Quarantine Lot Status" then
            Rec.FieldError("New Lot Status Code", StrSubstNo(Text010, InvSetup."Quarantine Lot Status"));
        if Rec."New Lot Status Code" = InvSetup."Quarantine Lot Status" then
            Rec.FieldError("New Lot Status Code", StrSubstNo(Text011, InvSetup."Quarantine Lot Status"));
        if Rec."Line No." <> 0 then begin
            Rec.Modify;
            Rec.UpdateLotTracking(false);
        end;
    end;

    procedure ItemJnlValidateSerial(xRec: Record "Item Journal Line"; var Rec: Record "Item Journal Line")
    var
        Item: Record Item;
        ItemTracking: Record "Item Tracking Code";
    begin
        // ItemJnlValdateSerial
        // PR3.61 Begin
        if xRec."Serial No." <> '' then
            Rec.FieldError("Serial No.", Text002); // P8000043A

        if Rec."Serial No." = '' then
            exit;

        Rec.TestField("Phys. Inventory", true);

        Item.Get(Rec."Item No.");
        Item.TestField("Item Tracking Code");
        ItemTracking.Get(Item."Item Tracking Code");
        ItemTracking.TestField("SN Specific Tracking", true);

        if Rec."Line No." <> 0 then
            ItemJnlInsertPhysical(Rec);
        // PR3.61 End
    end;

    procedure ItemJnlInsertPhysical(var rec: Record "Item Journal Line")
    var
        ResEntry: Record "Reservation Entry";
    begin
        // PR3.61 Begin
        ItemJnlDeletePhysical(rec);
        with rec do
            if ("Line No." <> 0) and
              (("Lot No." <> '') or ("Serial No." <> '')) and
              ((Quantity <> 0) or ("Quantity (Alt.)" <> 0))
            then begin
                ResEntry.Init;
                ResEntry."Entry No." := 0;
                ResEntry."Item No." := "Item No.";
                ResEntry."Reservation Status" := ResEntry."Reservation Status"::Prospect;
                ResEntry."Variant Code" := "Variant Code";
                ResEntry."Location Code" := "Location Code";
                ResEntry."Created By" := UserId;
                ResEntry."Creation Date" := Today;
                ResEntry."Source Type" := DATABASE::"Item Journal Line";
                ResEntry."Source ID" := "Journal Template Name";
                ResEntry."Source Batch Name" := "Journal Batch Name";
                ResEntry."Source Subtype" := "Entry Type";
                ResEntry."Source Ref. No." := "Line No.";
                ResEntry."Lot No." := "Lot No.";
                ResEntry."Serial No." := "Serial No.";
                ResEntry."Phys. Inventory" := true;
                ResEntry."Qty. (Calculated)" := "Qty. (Calculated)";
                ResEntry.Validate("Qty. (Phys. Inventory)", rec."Qty. (Phys. Inventory)");
                if ResEntry.TrackAlternateUnits then begin
                    ResEntry.Validate("Qty. (Alt.) (Calculated)", "Qty. (Alt.) (Calculated)");
                    ResEntry.Validate("Qty. (Alt.) (Phys. Inventory)", "Qty. (Alt.) (Phys. Inventory)");
                end;
                if ResEntry.Positive then
                    ResEntry."Expected Receipt Date" := "Posting Date"
                else
                    ResEntry."Shipment Date" := "Posting Date";
                ResEntry.Insert(true);
            end;
        // PR3.61 End
    end;

    procedure ItemJnlModifyPhysical(var rec: Record "Item Journal Line")
    var
        ResEntry: Record "Reservation Entry";
        xResEntry: Record "Reservation Entry";
    begin
        // InteJnlModifyPhysical
        // PR3.61 Begin
        with rec do
            if (Quantity = 0) and ("Quantity (Alt.)" = 0) then
                ItemJnlDeletePhysical(rec)
            else
                if ("Line No." <> 0) and (("Lot No." <> '') or ("Serial No." <> '')) then begin
                    ResEntry.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name",
                      "Source Prod. Order Line", "Source Ref. No.");
                    ResEntry.SetRange("Source Type", DATABASE::"Item Journal Line");
                    ResEntry.SetRange("Source ID", "Journal Template Name");
                    ResEntry.SetRange("Source Batch Name", "Journal Batch Name");
                    ResEntry.SetRange("Source Ref. No.", "Line No.");
                    if ResEntry.Find('-') then begin
                        xResEntry := ResEntry;
                        ResEntry.Validate("Qty. (Phys. Inventory)", rec."Qty. (Phys. Inventory)");
                        if ResEntry.TrackAlternateUnits then begin // P8000349A
                            ResEntry.Validate("Qty. (Alt.) (Calculated)", "Qty. (Alt.) (Calculated)"); // P8000349A
                            ResEntry.Validate("Qty. (Alt.) (Phys. Inventory)", "Qty. (Alt.) (Phys. Inventory)");
                        end; // P8000349A
                        if ResEntry.Positive then begin
                            ResEntry."Expected Receipt Date" := "Posting Date";
                            ResEntry."Shipment Date" := 0D;
                        end else begin
                            ResEntry."Expected Receipt Date" := 0D;
                            ResEntry."Shipment Date" := "Posting Date";
                        end;
                        if xResEntry.Positive <> ResEntry.Positive then begin
                            xResEntry.Delete;
                            ResEntry.Insert;
                        end else
                            ResEntry.Modify;
                    end else
                        ItemJnlInsertPhysical(rec);
                end;
        // PR3.61 End
    end;

    procedure ItemJnlDeletePhysical(var rec: Record "Item Journal Line")
    var
        ResEntry: Record "Reservation Entry";
    begin
        // ItemJnlDeletePhysical
        // PR3.61 Begin
        with rec do
            if ("Line No." <> 0) and (("Lot No." <> '') or ("Serial No." <> '')) then begin
                ResEntry.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name",
                  "Source Prod. Order Line", "Source Ref. No.");
                ResEntry.SetRange("Source Type", DATABASE::"Item Journal Line");
                ResEntry.SetRange("Source ID", "Journal Template Name");
                ResEntry.SetRange("Source Batch Name", "Journal Batch Name");
                ResEntry.SetRange("Source Ref. No.", "Line No.");
                ResEntry.DeleteAll;
            end;
        // PR3.61 End
    end;

    procedure ItemJnlLineSplitPhysical(var ItemJnlLine: Record "Item Journal Line"): Boolean
    var
        ResEntry: Record "Reservation Entry";
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // ItemJnlLineSplitPhysical
        // PR3.61 Begin
        case AltQtySplit of
            0: // Test for splitting and make first split
                begin
                    SplitItemJnlLine := ItemJnlLine;
                    if ItemJnlLine."Quantity (Alt.)" < 0 then begin
                        AltQtyLine.SetRange("Alt. Qty. Transaction No.", ItemJnlLine."Alt. Qty. Transaction No.");
                        if AltQtyLine.Count <> 1 then
                            Error(Text004);
                        AltQtyLine.Find('-');
                        SplitAltQtyLine := AltQtyLine;
                        ItemJnlLine.Validate("Qty. (Phys. Inventory)", ItemJnlLine."Qty. (Calculated)");
                        ItemJnlLine.Validate("Qty. (Alt.) (Phys. Inventory)", SplitItemJnlLine."Qty. (Alt.) (Phys. Inventory)"); // xxx
                        ItemJnlModifyPhysical(ItemJnlLine);
                        AltQtyLine.Validate(Quantity, ItemJnlLine."Qty. (Calculated)");
                        AltQtyLine.Modify;
                        AltQtySplit := 1;
                    end else
                        AltQtySplit := 2;
                end;
            1: // Make second split
                begin
                    ItemJnlLine := SplitItemJnlLine;
                    AltQtyLine := SplitAltQtyLine;
                    ItemJnlLine.Validate("Qty. (Alt.) (Calculated)", ItemJnlLine."Qty. (Alt.) (Phys. Inventory)");
                    ItemJnlModifyPhysical(ItemJnlLine);
                    AltQtyLine.Insert;
                    AltQtySplit := 2;
                end;
            2: // Terminate splitting
                begin
                    ItemJnlLine := SplitItemJnlLine;
                    AltQtySplit := 0;
                end;
        end;
        exit(AltQtySplit <> 0);
        // PR3.61 End
    end;

    procedure GetDocumentLineLotInfo(SourceType: Integer; SourceSubType: Integer; SourceID: Code[20]; SourceRefNo: Integer; Handled: Boolean; var LotInfo: Record "Lot No. Information")
    var
        TrackingSpec: Record "Tracking Specification";
        ResEntry: Record "Reservation Entry";
    begin
        // PR3.70.01
        LotInfo.Init;
        if Handled then begin
            TrackingSpec.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Batch Name",
              "Source Prod. Order Line", "Source Ref. No.");
            TrackingSpec.SetRange("Source Type", SourceType);
            TrackingSpec.SetRange("Source Subtype", SourceSubType);
            TrackingSpec.SetRange("Source ID", SourceID);
            TrackingSpec.SetRange("Source Ref. No.", SourceRefNo);
            if TrackingSpec.Find('-') then begin
                LotInfo."Item No." := TrackingSpec."Item No.";
                LotInfo."Variant Code" := TrackingSpec."Variant Code";
                LotInfo."Lot No." := TrackingSpec."Lot No.";
            end;
        end else begin
            ResEntry.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name",
              "Source Prod. Order Line", "Source Ref. No.");
            ResEntry.SetRange("Source Type", SourceType);
            ResEntry.SetRange("Source Subtype", SourceSubType);
            ResEntry.SetRange("Source ID", SourceID);
            ResEntry.SetRange("Source Ref. No.", SourceRefNo);
            if ResEntry.Find('-') then begin
                LotInfo."Item No." := ResEntry."Item No.";
                LotInfo."Variant Code" := ResEntry."Variant Code";
                LotInfo."Lot No." := ResEntry."Lot No.";
            end;
        end;

        if LotInfo.Find('=') then;
    end;

    procedure OKToAssignLotNo(SourceRec: Variant): Boolean
    var
        LotNoData: Record "Lot No. Data";
    begin
        // P8001234
        LotNoData.InitializeFromSourceRecord(SourceRec, false);
        exit(LotNoData.OKToAssign);
    end;

    procedure AssignLotNo(SourceRec: Variant): Code[50]
    var
        LotNoData: Record "Lot No. Data";
    begin
        // P8001234
        LotNoData.InitializeFromSourceRecord(SourceRec, false);
        exit(LotNoData.AssignLotNo);
    end;

    procedure AutoAssignLotNo(SourceRec: Variant; xSourceRec: Variant; var LotNo: Code[50]): Boolean
    var
        LotNoData: Record "Lot No. Data";
        xLotNoData: Record "Lot No. Data";
    begin
        // P8001234
        LotNoData.InitializeFromSourceRecord(SourceRec, true);

        if not LotNoData."Inbound Assignment" then
            exit(false);

        if LotNo = '' then begin
            if LotNoData.OKToAssign then begin
                LotNo := LotNoData.AssignLotNo;
                exit(true);
            end else
                exit(false);
        end else begin
            xLotNoData.InitializeFromSourceRecord(xSourceRec, true);
            if LotNoData.LotDataChanged(xLotNoData) then begin
                if LotNoData.OKToAssign then begin
                    LotNo := LotNoData.AssignLotNo;
                end else
                    LotNo := '';
                exit(true);
            end else
                if not LotNoData.OKToAssign then begin
                    LotNo := '';
                    exit(true);
                end else
                    exit(false);
        end;
    end;

    procedure GetUniqueSegmentNo(Root: Code[20]): Integer
    var
        AutoLotNo: Record "Automatic Lot No.";
    begin
        // P8001234
        if not AutoLotNo.Get(Root) then begin
            AutoLotNo.Root := Root;
            AutoLotNo.Suffix := 1;
            AutoLotNo.Insert;
        end else begin
            AutoLotNo.Suffix += 1;
            AutoLotNo.Modify;
        end;

        exit(AutoLotNo.Suffix);
    end;

    procedure CalcFreshDate(var LotNoInfo: Record "Lot No. Information"): Date
    var
        Item: Record Item;
    begin
        // P8000899
        with LotNoInfo do begin
            if not Item.Get("Item No.") or
               not Item.UseFreshnessDate or // P800969
               ("Creation Date" = 0D) or
               (Format(Item."Shelf Life") = '')
            then
                exit(0D);
            exit(CalcDate(Item."Shelf Life", "Creation Date"));
        end;
    end;

    procedure GetLotFreshDate(ReservEntry: Record "Reservation Entry"): Date
    var
        LotNoInfo: Record "Lot No. Information";
    begin
        // P8000899
        with ReservEntry do begin
            if LotNoInfo.Get("Item No.", "Variant Code", "Lot No.") then
                exit(LotNoInfo."Freshness Date");
            exit(0D);
        end;
    end;

    procedure VerifyReservLotIsFresh(TrackingSpecification: Record "Tracking Specification"; ReservEntry: Record "Reservation Entry"): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        // P8000899
        with ReservEntry do begin
            if TrackingSpecification."Source Type" = DATABASE::"Sales Line" then begin
                SalesLine.Get(TrackingSpecification."Source Subtype", TrackingSpecification."Source ID", TrackingSpecification."Source Ref. No.");
                if (SalesLine.Type <> SalesLine.Type::Item) or
                   (SalesLine."No." = '')
                then
                    exit(true);
                if not VerifySalesLotIsFresh(SalesLine, "Lot No.", SalesLine."Shipment Date") then
                    exit(false);
            end;
            exit(true);
        end;
    end;

    procedure VerifySalesLotIsFresh(SalesLine: Record "Sales Line"; LotNo: Code[50]; PostingDate: Date): Boolean
    begin
        // P8000899
        exit(LotIsFresh(SalesLine."No.", SalesLine."Variant Code", LotNo, SalesLine."Lot Freshness Preference", // P8001062
          PostingDate, SalesLine."Shipment Date", SalesLine."Planned Delivery Date"));
    end;

    procedure LotIsFresh(ItemNo: Code[20]; VariantCode: Code[10]; LotNo: Code[50]; FreshnessPreference: Integer; PostingDate: Date; ShipmentDate: Date; DeliveryDate: Date): Boolean
    var
        Item: Record Item;
        LotNoInfo: Record "Lot No. Information";
    begin
        // P8000899
        // P8001062 - add parameter for FreshnessPreference and remove parameter fot CustNo, old code removed
        if FreshnessPreference = -1 then
            exit(true);

        if not Item.Get(ItemNo) or
           not LotNoInfo.Get(ItemNo, VariantCode, LotNo) or
           (Item."Freshness Calc. Method" = Item."Freshness Calc. Method"::" ") then
            exit(true);

        if not LotNoInfo.Posted then
            exit(false);

        if not Item.UseFreshnessDate then begin
            if (LotNoInfo."Creation Date" + FreshnessPreference) < PostingDate then
                exit(false);
        end else begin
            if LotNoInfo."Freshness Date" < PostingDate then
                exit(false);
            if (LotNoInfo."Freshness Date" - FreshnessPreference) < (DeliveryDate + (PostingDate - ShipmentDate)) then
                exit(false);
        end;

        exit(true);
    end;

    procedure GetLotFreshnessPreference(Item: Record Item; CustNo: Code[20]): Integer
    var
        LotFresh: Record "Lot Freshness";
    begin
        // P8001062
        if not (Item."Freshness Calc. Method" in [Item."Freshness Calc. Method"::"Days To Fresh",
          Item."Freshness Calc. Method"::"Best If Used By", Item."Freshness Calc. Method"::"Sell By"])
        then
            exit(-1);

        if not LotFresh.Get(CustNo, LotFresh."Item Type"::Item, Item."No.") then
            if not LotFresh.GetForItemCategory(CustNo, Item."Item Category Code") then // P8007749
                if not LotFresh.Get(CustNo, LotFresh."Item Type"::"All Items", '') then
                    exit(-1);

        case Item."Freshness Calc. Method" of
            Item."Freshness Calc. Method"::"Days To Fresh":
                exit(LotFresh."Days to Fresh");
            Item."Freshness Calc. Method"::"Best If Used By", Item."Freshness Calc. Method"::"Sell By":
                exit(LotFresh."Required Shelf Life");
        end;
    end;

    procedure CheckPurchLineCOO(PurchLine: Record "Purchase Line")
    var
        Item: Record Item;
    begin
        // P8000935
        with PurchLine do
            if ("Document Type" in ["Document Type"::Order, "Document Type"::Invoice]) and
              (Type = Type::Item)
            then
                if Item.Get("No.") and Item."Country/Region of Origin Reqd." then
                    TestField("Country/Region of Origin Code");
    end;

    procedure SetDefaultCOO(PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line"; TrackingCode: Code[10])
    var
        ItemTracking: Record "Item Tracking Code";
        OrderAddress: Record "Order Address";
    begin
        // P8000938
        if TrackingCode = '' then
            exit;
        ItemTracking.Get(TrackingCode);
        if not ItemTracking."Lot Specific Tracking" then
            exit;
        if PurchHeader."Order Address Code" <> '' then begin
            OrderAddress.Get(PurchHeader."Buy-from Vendor No.", PurchHeader."Order Address Code");
            PurchLine."Country/Region of Origin Code" := OrderAddress."Country/Region Code";
        end;
        if PurchLine."Country/Region of Origin Code" = '' then
            PurchLine."Country/Region of Origin Code" := PurchHeader."Buy-from Country/Region Code";
    end;

    procedure CopyLotData(LotInfo: Record "Lot No. Information"; NewLotInfo: Record "Lot No. Information")
    var
        QCHeader: Record "Quality Control Header";
        QCHeader2: Record "Quality Control Header";
        QCLine: Record "Quality Control Line";
        QCLine2: Record "Quality Control Line";
        LotSpec: Record "Lot Specification";
        LotSpec2: Record "Lot Specification";
        Handled: Boolean;
    begin
        // P8001083
        QCHeader.SetRange("Item No.", LotInfo."Item No.");
        QCHeader.SetRange("Variant Code", LotInfo."Variant Code");
        QCHeader.SetRange("Lot No.", LotInfo."Lot No.");
        if QCHeader.FindSet then
            repeat
                // P800129613
                Handled := false;
                OnBeforeCopyQC(QCHeader, Handled);
                if not Handled then begin
                // P800129613
                    QCHeader2 := QCHeader;
                    QCHeader2."Lot No." := NewLotInfo."Lot No.";
                    QCHeader2.Insert;

                    QCLine.SetRange("Item No.", LotInfo."Item No.");
                    QCLine.SetRange("Variant Code", LotInfo."Variant Code");
                    QCLine.SetRange("Lot No.", LotInfo."Lot No.");
                    QCLine.SetRange("Test No.", QCHeader."Test No.");
                    if QCLine.FindSet then
                        repeat
                            QCLine2 := QCLine;
                            QCLine2."Lot No." := NewLotInfo."Lot No.";
                            QCLine2.Insert;
                        until QCLine.Next = 0;
                end; // P800129613

            until QCHeader.Next = 0;

        LotSpec.SetRange("Item No.", LotInfo."Item No.");
        LotSpec.SetRange("Variant Code", LotInfo."Variant Code");
        LotSpec.SetRange("Lot No.", LotInfo."Lot No.");
        if LotSpec.FindSet then
            repeat
                LotSpec2 := LotSpec;
                LotSpec2."Lot No." := NewLotInfo."Lot No.";
                LotSpec2.Insert;
            until LotSpec.Next = 0;
    end;

    procedure SetLotFieldsFromTracking(var TrackingSpec: Record "Tracking Specification"; var LotNoInfo: Record "Lot No. Information")
    var
        ModifyRec: Boolean;
    begin
        // P8001106
        with LotNoInfo do begin // P8008351
            if ("Supplier Lot No." = '') and (TrackingSpec."Supplier Lot No." <> '') then begin
                "Supplier Lot No." := TrackingSpec."Supplier Lot No.";
                ModifyRec := true; // P8008351
            end;
            // P8008351
            if ("Creation Date" = 0D) and (TrackingSpec."Lot Creation Date" <> 0D) then begin
                "Creation Date" := TrackingSpec."Lot Creation Date";
                "Freshness Date" := CalcFreshDate(LotNoInfo);
                ModifyRec := true;
            end;
            if ("Country/Region of Origin Code" = '') and (TrackingSpec."Country/Region of Origin Code" <> '') then begin
                "Country/Region of Origin Code" := TrackingSpec."Country/Region of Origin Code";
                ModifyRec := true;
            end;
            if ModifyRec then
                Modify;
        end;
        // P8008351
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyQC(QualityControlHeader: Record "Quality Control Header"; var Handled: Boolean)
    begin 
    end;
}

