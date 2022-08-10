codeunit 37002210 "Repack-Post"
{
    // PR4.00.06
    // P8000496A, VerticalSoft, Jack Reynolds, 24 JUL 07
    //   Posting codeunit for repack orders
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 31 JUL 07
    //   Change to parameters for CreateReservEntry.CreateReservEntryFor
    // 
    // P8000504A, VerticalSoft, Jack Reynolds, 08 AUG 07
    //   Support for alternate quantities
    // 
    // PRW15.00.01
    // P8000525A, VerticalSoft, Jack Reynolds, 24 SEP 07
    //   Fix problem posting for non-alternate quantity items
    // 
    // PRW15.00.02
    // P8000609A, VerticalSoft, Jack Reynolds, 02 JUL 08
    //   Fix problem with repack orders and expiration dating
    // 
    // P8000617A, VerticalSoft, Jack Reynolds, 05 AUG 08
    //   Fix problem posting production with bins and warehouse entries
    // 
    // PRW15.00.03
    // P8000624A, VerticalSoft, Jack Reynolds, 19 AUG 08
    //   Move country/region of origin to item journal line so that it gets moved to the lot info record
    // 
    // PRW16.00.05
    // P8000936, Columbus IT, Jack Reynolds, 25 APR 11
    //   Support for Repack Orders on Sales Board
    // 
    // PRW16.00.06
    // P8001039, Columbus IT, Don Bresee, 06 MAR 12
    //   Add Rounding Adjustment logic for Warehouse
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Repack on Item Ledger
    // 
    // PRW17.00
    // P8001134, Columbus IT, Don Bresee, 16 FEB 13
    //   Add logic for handling of new "Order Type" option Repack
    // 
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW17.10
    // P8001234, Columbus IT, Jack Reynolds, 01 NOV 13
    //    Support for custom lot number formats
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Permissions =;
    TableNo = "Repack Order";

    trigger OnRun()
    begin
        RepackOrder := Rec;
        with RepackOrder do begin
            TestField("Item No.");
            TestField("Posting Date");
            if GenJnlCheckLine.DateNotAllowed("Posting Date") then
                FieldError("Posting Date", Text001);

            if not (Transfer or Produce) then
                Error(
                  Text002,
                  FieldCaption(Transfer), FieldCaption(Produce));

            CheckDim; // P8001133

            if Transfer then begin
                RepackLine.Reset;
                RepackLine.SetRange("Order No.", "No.");
                RepackLine.SetFilter("Quantity to Transfer", '<>0');
                Transfer := not RepackLine.IsEmpty;
            end;

            if Produce then begin
                RepackLine.Reset;
                RepackLine.SetRange("Order No.", "No.");
                RepackLine.SetFilter("Quantity to Consume", '<>0');
                Produce := ("Quantity to Produce" <> 0) and (not RepackLine.IsEmpty);
            end;

            if not (Transfer or Produce) then
                Error(Text007);

            if Produce then
                if not CheckConsumptionEqualsTransfer(RepackOrder) then
                    exit;

            if Transfer and Produce then
                Window.Open(
                  Text008 + '\\' +
                  Text009 + '\' +
                  Text010 + '\' +
                  Text011)
            else
                if Transfer then
                    Window.Open(
                      Text008 + '\\' +
                      Text009)
                else
                    Window.Open(
                      Text008 + '\\' +
                      Text010 + '\' +
                      Text011);
            Window.Update(1, StrSubstNo('%1 %2', TableCaption, "No."));

            // Need to lock tables here to insure correct locking sequence

            SourceCodeSetup.Get;
            SrcCode := SourceCodeSetup."Repack Order";

            if Transfer then begin
                LineCount := 0;
                RepackLine.Reset;
                RepackLine.SetRange("Order No.", "No.");
                RepackLine.SetRange(Type, RepackLine.Type::Item);
                RepackLine.SetFilter("Quantity to Transfer", '<>0');
                if RepackLine.FindSet(true, false) then
                    repeat
                        LineCount += 1;
                        Window.Update(2, LineCount);
                        PostTransfer(RepackLine);
                        RepackLine.Modify;
                    until RepackLine.Next = 0;
            end;

            if Produce then begin
                LineCount := 0;
                TotalCost := 0;

                RepackLine.Reset;
                RepackLine.SetRange("Order No.", "No.");
                RepackLine.SetFilter("Quantity to Consume", '<>0');
                if RepackLine.FindSet(true, false) then
                    repeat
                        CreateTempConsumptionLine(RepackLine, TotalCost);
                        RepackLine.Modify;
                    until RepackLine.Next = 0;

                Window.Update(3, "Item No.");
                PostOutput(RepackOrder, TotalCost);

                PostTempJnlLines;

                RepackOrder.Status := RepackOrder.Status::Finished;
                RepackOrder.Modify;
            end;

            if RepackOrder.Status = RepackOrder.Status::Finished then begin
                RepackOrder."Quantity to Produce" := 0;
                RepackOrder."Quantity to Produce (Base)" := 0;
                RepackOrder."Quantity to Produce (Alt.)" := 0; // P8000504A
                RepackOrder.Modify;
            end;

            RepackLine.Reset;
            RepackLine.SetRange("Order No.", "No.");
            if RepackLine.FindSet then
                repeat
                    RepackLine.UpdateQtyToTransfer;
                    RepackLine.UpdateQtyToConsume;
                    RepackLine.Status := RepackOrder.Status; // P8000936
                    RepackLine.Modify;
                until RepackLine.Next = 0;
        end;

        UpdateAnalysisView.UpdateAll(0, true);
        UpdateItemAnalysisView.UpdateAll(0, true);
        Rec := RepackOrder;
    end;

    var
        RepackOrder: Record "Repack Order";
        RepackLine: Record "Repack Order Line";
        Location: Record Location;
        SourceCodeSetup: Record "Source Code Setup";
        TempItemJnlLine: Record "Item Journal Line" temporary;
        TempResJnlLine: Record "Res. Journal Line" temporary;
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
        DimMgt: Codeunit DimensionManagement;
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        ResJnlPostLine: Codeunit "Res. Jnl.-Post Line";
        WhseJnlPostLine: Codeunit "Whse. Jnl.-Register Line";
        UpdateAnalysisView: Codeunit "Update Analysis View";
        UpdateItemAnalysisView: Codeunit "Update Item Analysis View";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        ProcessFns: Codeunit "Process 800 Functions";
        Window: Dialog;
        SrcCode: Code[10];
        PostingDate: Date;
        LineCount: Integer;
        TotalCost: Decimal;
        Text001: Label 'is not within your range of allowed posting dates';
        Text002: Label 'Please enter "Yes" in %1 and/or %2.';
        Text003: Label 'The combination of dimensions used in %1 %2 is blocked. %3.';
        Text004: Label 'The combination of dimensions used in %1 %2, line no. %3 is blocked. %4.';
        Text005: Label 'The dimensions used in %1 %2 are invalid. %3.';
        Text006: Label 'The dimensions used in %1 %2, line no. %3 are invalid. %4.';
        Text007: Label 'There is nothing to post.';
        Text008: Label '#1#################################';
        Text009: Label 'Posting Transfers          #2######';
        Text010: Label 'Posting Output             #3######';
        Text011: Label 'Posting Consumption        #4######';
        Text012: Label '%1 %2, %3 %4, Item %5 %6 will exceed %7.  Continue posting?';
        RoundingAdjmtMgmt: Codeunit "Rounding Adjustment Mgmt.";

    local procedure CheckDim()
    var
        RepackLine2: Record "Repack Order Line";
    begin
        // P8001133 - renamed from CopyAndCheckDocDimToTempDocDim
        if (RepackOrder.Produce and (RepackOrder."Quantity to Produce" <> 0)) then begin
            RepackLine2."Line No." := 0;
            CheckDimComb(RepackLine2); // P8001133
            CheckDimValuePosting(RepackLine2);
        end;

        RepackLine2.SetRange("Order No.", RepackOrder."No.");
        if RepackLine2.FindSet then
            repeat
                if (RepackOrder.Transfer and (RepackLine2."Quantity to Transfer" <> 0)) or
                   (RepackOrder.Produce and (RepackLine2."Quantity to Consume" <> 0))
                then begin
                    CheckDimComb(RepackLine2); // P8001133
                    CheckDimValuePosting(RepackLine2);
                end
            until RepackLine2.Next = 0;
    end;

    local procedure CheckDimComb(RepackLine: Record "Repack Order Line")
    begin
        // P8001133 - parameter changed from LineNo to RepackLine
        if RepackLine."Line No." = 0 then                                   // P8001133
            if not DimMgt.CheckDimIDComb(RepackOrder."Dimension Set ID") then // P8001133
                Error(
                  Text003,
                  RepackOrder.TableCaption, RepackOrder."No.", DimMgt.GetDimCombErr);

        if RepackLine."Line No." <> 0 then                                 // P8001133
            if not DimMgt.CheckDimIDComb(RepackLine."Dimension Set ID") then // P8001133
                Error(
                  Text004,
                  RepackOrder.TableCaption, RepackOrder."No.", RepackLine."Line No.", DimMgt.GetDimCombErr);
    end;

    local procedure CheckDimValuePosting(var RepackLine2: Record "Repack Order Line")
    var
        TableIDArr: array[10] of Integer;
        NumberArr: array[10] of Code[20];
    begin
        if RepackLine2."Line No." = 0 then begin
            TableIDArr[1] := DATABASE::Item;
            NumberArr[1] := RepackOrder."Item No.";
            if not DimMgt.CheckDimValuePosting(TableIDArr, NumberArr, RepackOrder."Dimension Set ID") then // P8001133
                Error(
                  Text005,
                  RepackOrder.TableCaption, RepackOrder."No.", DimMgt.GetDimValuePostingErr);
        end else begin
            TableIDArr[1] := RepackLine2.TypeToTable;
            NumberArr[1] := RepackLine2."No.";
            if not DimMgt.CheckDimValuePosting(TableIDArr, NumberArr, RepackLine2."Dimension Set ID") then // P8001133
                Error(
                  Text006,
                  RepackOrder.TableCaption, RepackOrder."No.", RepackLine2."Line No.", DimMgt.GetDimValuePostingErr);
        end;
    end;

    procedure CheckConsumptionEqualsTransfer(RepackOrder: Record "Repack Order"): Boolean
    var
        RepackLine: Record "Repack Order Line";
    begin
        RepackLine.SetRange("Order No.", RepackOrder."No.");
        RepackLine.SetRange(Type, RepackLine.Type::Item);
        RepackLine.SetFilter("Source Location", '<>%1', RepackOrder."Repack Location");
        if RepackLine.Find('-') then
            repeat
                if (RepackLine."Quantity Transferred" + RepackLine."Quantity to Transfer") > RepackLine."Quantity to Consume" then
                    if not Confirm(Text012, false,
                      RepackOrder.TableCaption, RepackOrder."No.",
                      RepackLine.FieldCaption("Line No."), RepackLine."Line No.", RepackLine."No.",
                      RepackLine.FieldCaption("Quantity Transferred"), RepackLine.FieldCaption("Quantity Consumed"))
                    then
                        exit(false);
            until RepackLine.Next = 0;

        exit(true);
    end;

    procedure PostTransfer(var RepackLine: Record "Repack Order Line")
    var
        Item: Record Item;
        ItemJnlLine: Record "Item Journal Line";
        TempHandlingSpecification: Record "Tracking Specification" temporary;
        CreateReservEntry: Codeunit "Create Reserv. Entry";
    begin
        with RepackLine do begin
            Item.Get("No.");
            if (Item."Item Tracking Code" <> '') and ("Lot No." = '') then
                FieldError("Lot No.");

            ItemJnlLine.Init;
            ItemJnlLine.Validate("Posting Date", RepackOrder."Posting Date");
            ItemJnlLine.Validate("Document No.", RepackOrder."No.");
            ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::Transfer);
            ItemJnlLine.Validate("Item No.", "No.");
            ItemJnlLine.Description := Description;
            ItemJnlLine.Validate("Variant Code", "Variant Code");
            ItemJnlLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
            ItemJnlLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
            ItemJnlLine."Dimension Set ID" := "Dimension Set ID"; // P8001133
            ItemJnlLine.Validate("Location Code", "Source Location");
            ItemJnlLine.Validate("Bin Code", "Bin Code");
            ItemJnlLine.Validate("New Location Code", RepackOrder."Repack Location");
            ItemJnlLine.Validate("Unit of Measure Code", "Unit of Measure Code");
            ItemJnlLine.Validate(Quantity, "Quantity to Transfer");
            // P8000504A
            if "Quantity to Transfer (Alt.)" <> 0 then // P8000525A
                ItemJnlLine.Validate("Quantity (Alt.)", "Quantity to Transfer (Alt.)");
            if ("Quantity to Transfer (Alt.)" <> 0) then
                ItemJnlLine."Alt. Qty. Transaction No." := "Alt. Qty. Trans. No. (Trans)";
            // P8000504A
            ItemJnlLine."Source Code" := SrcCode;
            // P8001134
            // ItemJnlLine.Repack := ItemJnlLine.Repack::Order; // P8001083
            ItemJnlLine."Order Type" := ItemJnlLine."Order Type"::FOODRepack;
            ItemJnlLine."Order No." := "Order No.";
            ItemJnlLine."Order Line No." := "Line No.";
            // P8001134

            if "Lot No." <> '' then begin
                CreateReservEntry.CreateReservEntryFor(
                  DATABASE::"Item Journal Line", ItemJnlLine."Entry Type", '', '', 0, 0,
                  ItemJnlLine."Qty. per Unit of Measure", ItemJnlLine.Quantity, ItemJnlLine."Quantity (Base)", '', "Lot No."); // P8000466A, P8001132
                CreateReservEntry.AddAltQtyData(-ItemJnlLine."Quantity (Alt.)"); // P8000504A
                CreateReservEntry.SetNewSerialLotNo('', "Lot No.");
                CreateReservEntry.CreateEntry(ItemJnlLine."Item No.", ItemJnlLine."Variant Code",
                  ItemJnlLine."Location Code", ItemJnlLine.Description, 0D, ItemJnlLine."Posting Date", 0, 3);
            end;

            ItemJnlPostLine.RunWithCheck(ItemJnlLine); // P8001133
                                                       // P8000617A
            ItemJnlPostLine.CollectTrackingSpecification(TempHandlingSpecification);
            PostWhseJnlLine(
              ItemJnlLine, "Quantity to Transfer", "Quantity to Transfer (Base)",
              "Quantity to Transfer (Alt.)", TempHandlingSpecification);
            // P8000617A

            "Quantity Transferred" += "Quantity to Transfer";
            "Quantity Transferred (Base)" += "Quantity to Transfer (Base)";
            "Quantity Transferred (Alt.)" += "Quantity to Transfer (Alt.)"; // P8000504A

            // P8000504A
            if ProcessFns.AltQtyInstalled then begin
                AltQtyMgmt.RepackLineAltQtyTransToConsum(RepackLine);
                AltQtyMgmt.RepackLineAltQtyLineToEntry(RepackLine, FieldNo("Quantity Transferred (Alt.)"));
            end;
            // P8000504A
        end;
    end;

    procedure CreateTempConsumptionLine(var RepackLine: Record "Repack Order Line"; var TotalCost: Decimal)
    begin
        case RepackLine.Type of
            RepackLine.Type::Item:
                begin
                    TempItemJnlLine.Init;
                    TempItemJnlLine."Line No." := RepackLine."Line No.";
                    TempItemJnlLine.Validate("Posting Date", RepackOrder."Posting Date");
                    TempItemJnlLine."Document No." := RepackOrder."No.";
                    TempItemJnlLine."Entry Type" := TempItemJnlLine."Entry Type"::"Negative Adjmt.";
                    TempItemJnlLine.Validate("Item No.", RepackLine."No.");
                    TempItemJnlLine.Validate("Variant Code", RepackLine."Variant Code");
                    TempItemJnlLine.Description := RepackLine.Description;
                    TempItemJnlLine."Shortcut Dimension 1 Code" := RepackLine."Shortcut Dimension 1 Code";
                    TempItemJnlLine."Shortcut Dimension 2 Code" := RepackLine."Shortcut Dimension 2 Code";
                    TempItemJnlLine."Dimension Set ID" := RepackLine."Dimension Set ID"; // P8001133
                    TempItemJnlLine."Source Code" := SrcCode;
                    // P8001134
                    // TempItemJnlLine.Repack := TempItemJnlLine.Repack::Order; // P8001083
                    TempItemJnlLine."Order Type" := TempItemJnlLine."Order Type"::FOODRepack;
                    TempItemJnlLine."Order No." := RepackLine."Order No.";
                    TempItemJnlLine."Order Line No." := RepackLine."Line No.";
                    // P8001134
                    TempItemJnlLine.Validate("Location Code", RepackOrder."Repack Location");
                    if RepackOrder."Repack Location" = RepackLine."Source Location" then // P8000617A
                        TempItemJnlLine.Validate("Bin Code", RepackLine."Bin Code");
                    TempItemJnlLine.Validate("Unit of Measure Code", RepackLine."Unit of Measure Code");
                    TempItemJnlLine.Validate(Quantity, RepackLine."Quantity to Consume");
                    // P8000504A
                    if RepackLine."Quantity to Consume (Alt.)" <> 0 then // P8000525A
                        TempItemJnlLine.Validate("Quantity (Alt.)", RepackLine."Quantity to Consume (Alt.)");
                    if (RepackLine."Quantity to Consume (Alt.)" <> 0) then
                        TempItemJnlLine."Alt. Qty. Transaction No." := RepackLine."Alt. Qty. Trans. No. (Consume)";
                    // P8000504A
                    TempItemJnlLine.Insert;

                    TotalCost += TempItemJnlLine."Unit Cost" * TempItemJnlLine.GetCostingQty(TempItemJnlLine.FieldNo(Quantity)); // P8000504A
                end;

            RepackLine.Type::Resource:
                begin
                    TempResJnlLine.Init;
                    TempResJnlLine."Line No." := RepackLine."Line No.";
                    TempResJnlLine.Validate("Posting Date", RepackOrder."Posting Date");
                    TempResJnlLine."Document No." := RepackOrder."No.";
                    TempResJnlLine."Entry Type" := TempResJnlLine."Entry Type"::Usage;
                    TempResJnlLine.Validate("Resource No.", RepackLine."No.");
                    TempResJnlLine.Description := RepackLine.Description;
                    TempResJnlLine."Shortcut Dimension 1 Code" := RepackLine."Shortcut Dimension 1 Code";
                    TempResJnlLine."Shortcut Dimension 2 Code" := RepackLine."Shortcut Dimension 2 Code";
                    TempResJnlLine."Dimension Set ID" := RepackLine."Dimension Set ID"; // P8001133
                    TempResJnlLine."Source Code" := SrcCode;
                    // P8001134
                    TempResJnlLine."Order Type" := TempResJnlLine."Order Type"::FOODRepack;
                    TempResJnlLine."Order No." := RepackLine."Order No.";
                    TempResJnlLine."Order Line No." := RepackLine."Line No.";
                    // P8001134
                    TempResJnlLine.Validate("Unit of Measure Code", RepackLine."Unit of Measure Code");
                    TempResJnlLine.Validate(Quantity, RepackLine."Quantity to Consume");
                    TempResJnlLine.Insert;

                    TotalCost += TempResJnlLine."Total Cost";
                end;
        end;

        RepackLine."Quantity Consumed" := RepackLine."Quantity to Consume";
        RepackLine."Quantity Consumed (Base)" := RepackLine."Quantity to Consume (Base)";
        RepackLine."Quantity Consumed (Alt.)" := RepackLine."Quantity to Consume (Alt.)"; // P8000504A
    end;

    procedure PostOutput(var RepackOrder: Record "Repack Order"; TotalCost: Decimal)
    var
        ItemJnlLine: Record "Item Journal Line";
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        LotInfo: Record "Lot No. Information";
        TempHandlingSpecification: Record "Tracking Specification" temporary;
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        P800Tracking: Codeunit "Process 800 Item Tracking";
    begin
        with RepackOrder do begin
            Item.Get("Item No.");

            if ("Lot No." = '') and ProcessFns.TrackingInstalled then
                if ItemTrackingCode.Get(Item."Item Tracking Code") then
                    if ItemTrackingCode."Lot Manuf. Inbound Assignment" then
                        Validate("Lot No.", P800Tracking.AssignLotNo(RepackOrder)); // P8000504A, P8001234

            ItemJnlLine.Init;
            ItemJnlLine.Validate("Posting Date", "Posting Date");
            ItemJnlLine.Validate("Document No.", "No.");
            ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Positive Adjmt.");
            ItemJnlLine.Validate("Item No.", "Item No.");
            ItemJnlLine.Description := Description;
            ItemJnlLine.Validate("Variant Code", "Variant Code");
            ItemJnlLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
            ItemJnlLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
            ItemJnlLine."Dimension Set ID" := "Dimension Set ID"; // P8001133
            ItemJnlLine.Validate("Location Code", "Destination Location");
            ItemJnlLine.Validate("Bin Code", "Bin Code");
            ItemJnlLine.Validate("Unit of Measure Code", "Unit of Measure Code");
            ItemJnlLine.Validate(Quantity, "Quantity to Produce");
            // P8000504A
            if "Quantity to Produce (Alt.)" <> 0 then // P8000525A
                ItemJnlLine.Validate("Quantity (Alt.)", "Quantity to Produce (Alt.)");
            if ("Quantity to Produce (Alt.)" <> 0) then
                ItemJnlLine."Alt. Qty. Transaction No." := "Alt. Qty. Transaction No.";
            // P8000504A
            ItemJnlLine.Validate(Amount, TotalCost);
            ItemJnlLine."Source Code" := SrcCode;
            // P8001134
            // ItemJnlLine.Repack := ItemJnlLine.Repack::Order; // P8001083
            ItemJnlLine."Order Type" := ItemJnlLine."Order Type"::FOODRepack;
            ItemJnlLine."Order No." := "No.";
            // P8001134

            if "Lot No." <> '' then begin
                ItemJnlLine.Farm := Farm;
                ItemJnlLine.Brand := Brand;
                ItemJnlLine."Country/Region of Origin Code" := "Country/Region of Origin Code"; // P8000624A
                                                                                                //ItemJnlLine.Repack := TRUE; // P8001083

                CreateReservEntry.CreateReservEntryFor(
                  DATABASE::"Item Journal Line", ItemJnlLine."Entry Type", '', '', 0, 0,
                  ItemJnlLine."Qty. per Unit of Measure", ItemJnlLine.Quantity, ItemJnlLine."Quantity (Base)", '', "Lot No."); // P8000466A, P8001132
                CreateReservEntry.AddAltQtyData(ItemJnlLine."Quantity (Alt.)"); // P8000504A
                CreateReservEntry.CreateEntry(ItemJnlLine."Item No.", ItemJnlLine."Variant Code",
                  ItemJnlLine."Location Code", ItemJnlLine.Description, ItemJnlLine."Posting Date", 0D, 0, 3);

                if not LotInfo.Get("Item No.", "Variant Code", "Lot No.") then begin
                    LotInfo."Item No." := "Item No.";
                    LotInfo."Variant Code" := "Variant Code";
                    LotInfo."Lot No." := "Lot No.";
                    LotInfo.Description := Item.Description;
                    LotInfo."Item Category Code" := Item."Item Category Code";
                    LotInfo."Created From Repack" := true;
                    LotInfo.Insert;
                end;
            end;

            ItemJnlPostLine.RunWithCheck(ItemJnlLine); // P8001133
                                                       // P8000617A
            ItemJnlPostLine.CollectTrackingSpecification(TempHandlingSpecification);
            PostWhseJnlLine(
              ItemJnlLine, "Quantity to Produce", "Quantity to Produce (Base)",
              "Quantity to Produce (Alt.)", TempHandlingSpecification);
            // P8000617A

            "Quantity Produced" += "Quantity to Produce";
            "Quantity Produced (Base)" += "Quantity to Produce (Base)";
            "Quantity Produced (Alt.)" += "Quantity to Produce (Alt.)"; // P8000504A

            if ProcessFns.AltQtyInstalled then                      // P8000504A
                AltQtyMgmt.RepackOrderAltQtyLineToEntry(RepackOrder); // P8000504A
        end;
    end;

    procedure PostTempJnlLines()
    var
        ItemJnlLine: Record "Item Journal Line";
        ResReg: Record "Resource Register";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
    begin
        if TempItemJnlLine.FindSet then
            repeat
                LineCount += 1;
                Window.Update(4, LineCount);

                RepackLine.Get(RepackOrder."No.", TempItemJnlLine."Line No.");
                if RepackLine."Lot No." <> '' then begin
                    CreateReservEntry.CreateReservEntryFor(
                      DATABASE::"Item Journal Line", TempItemJnlLine."Entry Type", '', '', 0, TempItemJnlLine."Line No.",
                      TempItemJnlLine."Qty. per Unit of Measure", TempItemJnlLine.Quantity, TempItemJnlLine."Quantity (Base)", '', RepackLine."Lot No."); // P8000466A, P8001132
                    CreateReservEntry.AddAltQtyData(-TempItemJnlLine."Quantity (Alt.)"); // P8000504A
                    CreateReservEntry.CreateEntry(TempItemJnlLine."Item No.", TempItemJnlLine."Variant Code",
                      TempItemJnlLine."Location Code", TempItemJnlLine.Description, 0D, TempItemJnlLine."Posting Date", 0, 3);
                end;

                ItemJnlPostLine.RunWithCheck(TempItemJnlLine); // P8001133
                if ProcessFns.AltQtyInstalled then                                                                   // P8000504A
                    AltQtyMgmt.RepackLineAltQtyLineToEntry(RepackLine, RepackLine.FieldNo("Quantity Consumed (Alt.)")); // P8000504A
            until TempItemJnlLine.Next = 0;

        if TempResJnlLine.FindSet then
            repeat
                LineCount += 1;
                Window.Update(4, LineCount);

                RepackLine.Get(RepackOrder."No.", TempResJnlLine."Line No.");

                ResJnlPostLine.RunWithCheck(TempResJnlLine); // P8001133
                ResJnlPostLine.GetResReg(ResReg);
            until TempResJnlLine.Next = 0;
    end;

    local procedure PostWhseJnlLine(ItemJnlLine: Record "Item Journal Line"; OriginalQuantity: Decimal; OriginalQuantityBase: Decimal; OriginalQuantityAlt: Decimal; var TempHandlingSpecification: Record "Tracking Specification" temporary)
    var
        WhseJnlLine: Record "Warehouse Journal Line";
        TempWhseJnlLine2: Record "Warehouse Journal Line" temporary;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        WMSMgmt: Codeunit "WMS Management";
        TemplateType: Integer;
    begin
        // P8000617A - This function was essentially lifted out of CU23
        with ItemJnlLine do begin
            Quantity := OriginalQuantity;
            "Quantity (Base)" := OriginalQuantityBase;
            "Quantity (Alt.)" := OriginalQuantityAlt;
            if "Entry Type" = "Entry Type"::Transfer then
                TemplateType := 1
            else
                TemplateType := 0;
            if Location.Get("Location Code") then
                if Location."Bin Mandatory" then
                    if WMSMgmt.CreateWhseJnlLine(ItemJnlLine, TemplateType, WhseJnlLine, false) then begin // P8001132
                        XferWhseRoundingAdjmts; // P8001039
                        ItemTrackingMgt.SplitWhseJnlLine(WhseJnlLine, TempWhseJnlLine2, TempHandlingSpecification, false);
                        if TempWhseJnlLine2.FindSet then
                            repeat
                                WMSMgmt.CheckWhseJnlLine(TempWhseJnlLine2, 1, 0, false);
                                WhseJnlPostLine.Run(TempWhseJnlLine2);
                                PostWhseAltQtyAdjmt(TempWhseJnlLine2);
                            until TempWhseJnlLine2.Next = 0;
                        PostWhseRoundingAdjmts; // P8001039
                    end;

            if "Entry Type" = "Entry Type"::Transfer then begin
                if Location.Get("New Location Code") then
                    if Location."Bin Mandatory" then
                        if WMSMgmt.CreateWhseJnlLine(ItemJnlLine, 0, WhseJnlLine, true) then begin // P8001132
                            ItemTrackingMgt.SplitWhseJnlLine(WhseJnlLine, TempWhseJnlLine2, TempHandlingSpecification, true);
                            if TempWhseJnlLine2.FindSet then
                                repeat
                                    WMSMgmt.CheckWhseJnlLine(TempWhseJnlLine2, 1, 0, true);
                                    WhseJnlPostLine.Run(TempWhseJnlLine2);
                                until TempWhseJnlLine2.Next = 0;
                        end;
            end;
        end;
    end;

    local procedure PostWhseAltQtyAdjmt(var TempWhseJnlLine2: Record "Warehouse Journal Line" temporary)
    var
        TempWhseJnlLine: Record "Warehouse Journal Line";
        Item: Record Item;
        ItemLedgEntry: Record "Item Ledger Entry";
        WhseEntry: Record "Warehouse Entry";
    begin
        // P8000617A - This function was essentially lifted out of CU23
        if not Location."Directed Put-away and Pick" then
            exit;

        TempWhseJnlLine := TempWhseJnlLine2;
        with TempWhseJnlLine do begin
            Item.Get("Item No.");
            if not Item.TrackAlternateUnits() then
                exit;

            ItemLedgEntry.SetCurrentKey(
              "Item No.", "Variant Code", "Location Code", "Lot No.", "Serial No.", "Posting Date");
            ItemLedgEntry.SetRange("Item No.", "Item No.");
            ItemLedgEntry.SetRange("Variant Code", "Variant Code");
            ItemLedgEntry.SetRange("Location Code", "Location Code");
            ItemLedgEntry.SetRange("Lot No.", "Lot No.");
            ItemLedgEntry.SetRange("Serial No.", "Serial No.");
            ItemLedgEntry.CalcSums(Quantity);
            if (ItemLedgEntry.Quantity <> 0) then
                exit;
            ItemLedgEntry.CalcSums("Quantity (Alt.)");
            if (ItemLedgEntry."Quantity (Alt.)" <> 0) then
                exit;

            WhseEntry.SetCurrentKey(
              "Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code",
              "Lot No.", "Serial No.", "Entry Type");
            WhseEntry.SetRange("Item No.", "Item No.");
            WhseEntry.SetRange("Bin Code", Location."Adjustment Bin Code");
            WhseEntry.SetRange("Location Code", "Location Code");
            WhseEntry.SetRange("Variant Code", "Variant Code");
            WhseEntry.SetRange("Lot No.", "Lot No.");
            WhseEntry.SetRange("Serial No.", "Serial No.");
            WhseEntry.CalcSums("Qty. (Base)");
            if (WhseEntry."Qty. (Base)" <> 0) then
                exit;
            WhseEntry.CalcSums("Quantity (Alt.)");
            if (WhseEntry."Quantity (Alt.)" = 0) then
                exit;

            Quantity := 0;
            "Qty. (Base)" := 0;
            "Qty. (Absolute)" := 0;
            "Qty. (Absolute, Base)" := 0;
            "Quantity (Alt.)" := -WhseEntry."Quantity (Alt.)";
            "Quantity (Absolute, Alt.)" := Abs("Quantity (Alt.)");
            if ("Quantity (Alt.)" < 0) then
                "Entry Type" := "Entry Type"::"Negative Adjmt."
            else
                "Entry Type" := "Entry Type"::"Positive Adjmt.";
            if ("Entry Type" <> TempWhseJnlLine2."Entry Type") then begin
                "To Zone Code" := TempWhseJnlLine2."From Zone Code";
                "To Bin Code" := TempWhseJnlLine2."From Bin Code";
                "From Zone Code" := TempWhseJnlLine2."To Zone Code";
                "From Bin Code" := TempWhseJnlLine2."To Bin Code";
            end;

            WhseJnlPostLine.Run(TempWhseJnlLine);
        end;
    end;

    local procedure XferWhseRoundingAdjmts()
    var
        TempWhseAdjmtLine: Record "Warehouse Journal Line" temporary;
    begin
        // P8001039
        if ItemJnlPostLine.GetWhseRoundingAdjmts(TempWhseAdjmtLine) then begin
            ItemJnlPostLine.ClearWhseRoundingAdjmts;
            RoundingAdjmtMgmt.SetWhseAdjmts(TempWhseAdjmtLine);
            WhseJnlPostLine.SetWhseRoundingAdjmts(TempWhseAdjmtLine);
        end;
    end;

    local procedure PostWhseRoundingAdjmts()
    var
        WhseJnlLine: Record "Warehouse Journal Line";
    begin
        // P8001039
        if RoundingAdjmtMgmt.WhseAdjmtsToPost() then begin
            WhseJnlPostLine.ClearWhseRoundingAdjmts;
            repeat
                RoundingAdjmtMgmt.BuildWhseAdjmtJnlLine(WhseJnlLine);
                WhseJnlPostLine.Run(WhseJnlLine);
            until (not RoundingAdjmtMgmt.WhseAdjmtsToPost());
        end;
    end;
}

