codeunit 37002080 "Alt. Qty. Management"
{
    // PR3.60
    //   Management of alternate quantities
    // 
    // PR3.60.03
    //   Fix problem with fixed weight items
    // 
    // PR3.61
    //   Add logic for transfer orders
    //   Add logic for container tracking
    //   Modify logic for physical counts
    // 
    // PR3.61.01
    //   Add logic for credit memos
    //   Fix problems with transfers
    // 
    // PR3.61.02
    //   Fix alternate quantity problme with "undo" transactions
    //   Fix problem with RemoveExcessAltQtys for fixed weight items
    // 
    // PR3.70.03
    //   In CheckBaseQty function
    //     Add ABS function quantitys
    //   In ItemJnlLineToItemLedgEntry function
    //     changed conditions on Negate variable assignment
    // 
    // PR3.70.04
    // P8000043A, Myers Nissi, Jack Reynolds, 25 MAY 04
    //   Support for easy lot tracking
    // 
    // PR3.70.05
    // P8000064A, Myers Nissi, Jack Reynolds, 12 JUL 04
    //   ShowItemJnlAltQtyLines - set Editable property on alt quantity form based on EditBlocked property
    //   DisallowEdit - set EditBlocked variable
    // 
    // PR3.70.06
    // P8000079A, Myers Nissi, Steve Post, 05 AUG 04
    //   Removed Function SetSalesLineShipAmount
    //     the code was moved to the SalesLine table UpdateAmount function as inline code
    // 
    // P8000108A, Myers Nissi, Jack Reynolds, 03 SEP 04
    //   UpdateTrackingAltQtyLine - call ValidateQuantity on alternate quantity line
    // 
    // P8000112A, Myers Nissi, Jack Reynolds, 10 SEP 04
    //   Remove code to disallow edit of alternate quantities for item journal lines
    // 
    // PR3.70.09
    // P8000198A, Myers Nissi, Jack Reynolds, 02 MAR 05
    //   DeletePostedDocEntries - delete alternate quantity entries for specified posted document
    // 
    // P8000199A, Myers Nissi, Don Bresee, 01 MAR 05
    //   Fix related to recalculation of document accruals
    // 
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Support for warehouse documents
    // 
    // PR4.00.03
    // P8000340A, VerticalSoft, Jack Reynolds, 16 MAY 06
    //   Set modify permission to Inventory Setup table
    // 
    // P8000344A, VerticalSoft, Jack Reynolds, 08 JUN 06
    //   Instead of updating amounts on sales and purchase lines validate line discount percent
    // 
    // PR4.00.04
    // P8000361A, VerticalSoft, Jack Reynolds, 27 JUL 06
    //   Problem assigning alternate quantity transaction number for fixed weight items
    // 
    // P8000322A, VerticalSoft, Don Bresee, 05 SEP 06
    //   TestWhseActAltQtyInfo - error if not shipment or production
    // 
    // P8000383A, VerticalSoft, Jack Reynolds, 22 SEP 06
    //   Add function to check that a unit of measure has differetn type than an item's alternate unit of measure
    // 
    // P8000392A, VerticalSoft, Jack Reynolds, 28 SEP 06
    //   Cleanup of rounding issue with alternate quantity lines form
    // 
    // PR4.00.05
    // P8000426A, VerticalSoft, Jack Reynolds, 27 DEC 06
    //   SetSalesLineAltQty - suspend status checking before validating line discount %
    // 
    // PR5.00
    // P8000504A, VerticalSoft, Jack Reynolds, 08 AUG 07
    //   Support for alternate quantities on repack orders
    // 
    // P8000506A, VerticalSoft, Jack Reynolds, 10 AUG 07
    //   Fix problem copying alternate quantity entries for drop shipments
    // 
    // PRW15.00.01
    // P8000538A, VerticalSoft, Jack Reynolds, 22 OCT 07
    //   Utility functions to delete alternate quantity lines and to check for zero alternate quantity
    // 
    // P8000554A, VerticalSoft, Don Bresee, 12 DEC 07
    //   Added BEGIN / END - fix to P8000344A, P8000426A
    // 
    // P8000550A, VerticalSoft, Don Bresee, 05 MAR 08
    //   Add logic for new calculation of base and alternate quantities
    // 
    // P8000494A, VerticalSoft, Don Bresee, 18 APR 08
    //   Add Fixed Production Bin / Alt. Qty. restriction
    // 
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //  Support for Delivery Trip Pick Line
    // 
    // P8000566A, VerticalSoft, Jack Reynolds, 28 MAY 08
    //   Fix problem with reclass, lot tracking, and alternate quantity
    // 
    // PRW15.00.03
    // P8000630A, VerticalSoft, Don Bresee, 17 SEP 08
    //   Add Whse. logic to delivery trips
    // 
    // P8000629A, VerticalSoft, Jack Reynolds, 21 SEP 08
    //   Fixes for warehouse and alternate quanity for fixed weight items
    // 
    // P8000638, VerticalSoft, Jack Reynolds, 14 NOV 08
    //   Resume status and credit checking on sales/purchase line after temporary suspension
    // 
    // PRW16.00.01
    // P8000662, VerticalSoft, Jack Reynolds, 22 JAN 09
    //   Fix problems with warehouse activity lines and fixed weight items
    // 
    // P8000713, VerticalSoft, Jack Reynolds, 06 AUG 09
    //   Fix problem calculating alternate quantity to handle for warehouse shipments and receipts
    // 
    // PRW16.00.02
    // P8000783, VerticalSoft, Don Bresee, 02 MAR 10
    //   Add filter for Lot No. and Serial No. to special consumption logic
    // 
    // PRW16.00.05
    // P8000981, Columbus IT, Don Bresee, 20 SEP 11
    //   Use Pricing logic for Sales Line update
    // 
    // PRW17.10
    // P8001224, Columbus IT, Jack Reynolds, 27 SEP 13
    //   Move Last Alt. Qty. Transaction No. from Inventory Setup
    // 
    // PRW18.00.01
    // P8001373, To-Increase, Dayakar Battini, 11 Feb 15
    //   Support containers for purchase returns.
    // 
    // P8001393, Columbus IT, Jack Reynolds, 12 AUG 15
    //   Fix problem calculating fixed alternagte quantity to handle
    // 
    // PRW18.00.02
    // P8004505, To-Increase, Jack Reynolds, 23 OCT 15
    //   Problem with catch weight and lot controlled items when updating from warehouse shipment
    // 
    // PRW18.00.03
    // P8006444, To-Increase, Jack Reynolds, 11 FEB 16
    //   Problem updating tracking when alter quantity entered directly on warehouse shipment/receipt
    // 
    // PRW19.00
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup old delivery trips
    // 
    // P8004516, To-Increase, Jack Reynolds, 17 MAR 16
    //   Incorporate modifications for NAV Anywhere processes
    // 
    // PRW19.00.01
    // P8006787, To-Increase, Jack Reynolds, 21 APR 16
    //   Fix issues with settlement and catch weight items
    // 
    // P8007524, To-Increase, Dayakar Battini, 02 AUG 16
    //   CheckBaseQty error correction
    // 
    // P8007584, To-Increase, Dayakar Battini, 31 AUG 16
    //   Issue with wrong quantity updation on alternate quantity calculations
    // 
    // P8007924, To-Increase, Dayakar Battini, 03 NOV 16
    //   Alt Qty handling for Return Order/ Credit Memo
    // 
    // P8008508, To-Increase, Jack Reynolds, 01 MAR 17
    //   Problem with containers, alternate quantity, and warehouse movement
    // 
    // PRW110.0.01
    // P8008729, To-Increase, Dayakar Battini, 04 MAY 17
    //   Issue with blank Itme No. value
    // 
    // PRW110.0.02
    // P80047943, To-Increase, Dayakar Battini, 22 NOV 17
    //   Fix issue for qty to Invoice calculation
    // 
    // P80052890, To-Increase, Dayakar Battini, 08 FEB 18
    //   Fix issue with lot tracked partial pick registration.
    // 
    // P80050544, To-Increase, Dayakar Battini, 12 FEB 18
    //   Upgrade to 2017 CU13
    // 
    // P80046533, To-Increase, Jack Reynolds, 10 OCT 17
    //   Inbound containers and shipping containers
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.01
    // P80059706, To-Increase, Dayakar Battini, 12 JUN 18
    //   Fix issue with mismatch application entries
    // 
    // P80057995, To-Increase, Jack Reynolds, 12 JUN 18
    //   Fix issue registering picks into containers for fixed weight items
    // 
    // PRW111.00.02
    // P80066185, To-Increase, Jack Reynolds, 16 OCT 18
    //   Correct changes from P80052890
    // 
    // P80068361, To Increase, Gangabhushan, 17 DEC 18
    //   TI-12507 - Container loses catch weight qty. during registration of Put away/Pick
    // 
    // P80070336, To Increase, Jack Reynolds, 12 FEB 19
    //   Fix issue with Alternate Quantity to Handle
    // 
    // P80071648, To Increase, Jack Reynolds, 07 MAR 19
    //   Followup to P80070336 for warehouse picks
    // 
    // PRW111.00.03
    // P80075420, To-Increase, Jack Reynolds, 08 JUL 19
    //   Problem losing tracking when using containers and specifying alt quantity to handle
    // 
    // P80080784, To-Increase, Jack Reynolds, 15 AUG 19
    //   Rollback changes from 47943
    // 
    // P80079981, To Increase, Gangabhushan, 23 AUG 19
    //   Qty to Handle data not get refreshed in Pick lines for Multiple UOM functionality.
    //
    // P80095316, To-Increase, Jack Reynolds, 09 MAR 20
    //   Second version of DeleteAltQtyLines with status check suspended.
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 15 JAN 19
    //   Upgrade to 13.00
    // 
    // PRW11300.03
    // P80082969, To Increase, Jack Reynolds, 26 SEP 19
    //   New Events
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    //
    // PRW118.01
    // P800127049, To Increase, Jack Reynolds, 23 AUG 21
    //   Support for Inventory documents
    //
    // PRW118.01
    // P800128960, To Increase, Jack Reynolds, 24 AUG 21
    //   Decimal precision on alternate quantity data entry
    // 
    // PRW120.00
    // P800144605, To Increase, Jack Reynolds, 20 APR 22
    //   Upgrade to 20.0

    Permissions = TableData "Inventory Setup" = m,
                  TableData "Alternate Quantity Entry" = rim;

    trigger OnRun()
    begin
    end;

    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        TrackItem: Boolean;
        TempAltQtyInvoiceEntry: Record "Alternate Quantity Entry" temporary;
        TempAltQtyItemJnlLine: Record "Alternate Quantity Line" temporary;
        TempAltQtyInvLineNo: Integer;
        TempExcessAltQtyLine: Record "Alternate Quantity Line" temporary;
        TempExcessAltQtyLineNo: Integer;
        ReportAltQtyLine: Record "Alternate Quantity Line";
        ReportAltQtyEntry: Record "Alternate Quantity Entry";
        ReportingComplete: Boolean;
        SavedPerBaseAmount: array[100] of Decimal;
        SavedPerBaseAmountCount: Integer;
        Text001: Label 'Alternate Quantity detail has already been specified.';
        Text002: Label '%1 differs from the expected value of %2 by more than the %3 of %4 percent.\\%1 is expected to be between %5 and %6.\\Is %7 the correct quantity?';
        Text003: Label '%1 differs from the expected value of %2 by more than the %3 of %4 percent.\\Is %5 the correct quantity?';
        Text004: Label 'Please enter the correct %1.';
        Text005: Label 'You must specify %1 for %2 %3 %4.';
        Text006: Label '%1 must match the detail quantity of %2.';
        Text007: Label '<Precision,%1><Standard format,0>';
        Text008: Label '%1s exist for an associated %2 (Order %3).\\These lines must be deleted, the information is already specified on the %4.';
        SourceAltQtyTransNo: Integer;
        P800Globals: Codeunit "Process 800 System Globals";
        Text009: Label 'Alternate quantity must be entered on the associated warehouse documents.';
        Text010: Label 'Alternate quantity must be entered on the Invt. Put-Away.';
        Text011: Label 'Alternate quantity must be entered on the Invt. Pick.';
        Text012: Label '%1 and %2 cannot have the same %3 %4.';
        Text013: Label '%1 %2 is assigned a Fixed Production Bin for %3 %4. %5 must be blank.';
        Text014: Label 'Alternate quantity must be entered for %1 %2.';
        IsActualAppliedAltQty: Boolean;

    procedure ValidateTrackingAltQtyLine(var TrackingLine: Record "Tracking Specification")
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // ValidateTrackingAltQtyLine
        TrackingLine.TestAltQtyEntry; // P8000282A
        StartTrackingAltQtyLine(TrackingLine);
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", SourceAltQtyTransNo);
        AltQtyLine.SetRange("Serial No.", TrackingLine."Serial No.");
        AltQtyLine.SetRange("Lot No.", TrackingLine."Lot No.");
        case AltQtyLine.Count of
            0:
                CreateTrackingAltQtyLine(TrackingLine);
            1:
                begin
                    AltQtyLine.Find('-');
                    UpdateTrackingAltQtyLine(TrackingLine, AltQtyLine);
                end;
            else begin
                    Message(Text001);
                    ShowTrackingAltQtyLines(TrackingLine);
                end;
        end;
    end;

    procedure ShowTrackingAltQtyLines(var TrackingLine: Record "Tracking Specification")
    var
        AltQtyLine: Record "Alternate Quantity Line";
        ItemTrackingCode: Record "Item Tracking Code";
        AltQtyForm: Page "Alternate Quantity Lines";
    begin
        // ShowTrackingAltQtyLines
        Commit;
        TrackingLine.TestAltQtyEntry; // P8000282A
        StartTrackingAltQtyLine(TrackingLine);
        with TrackingLine do begin
            AltQtyForm.SetSource("Source Type", DocumentType,
                                 DocumentNo, TemplateName, BatchName, "Source Ref. No.");
            AltQtyForm.SetQty("Qty. to Handle (Base)", FieldCaption("Qty. to Handle (Base)"));
            AltQtyForm.SetMaxQty("Quantity (Base)" - "Quantity Handled (Base)");
            Item.Get("Item No.");
            if Item."Item Tracking Code" <> '' then begin
                ItemTrackingCode.Get(Item."Item Tracking Code");
                if ItemTrackingCode."SN Specific Tracking" then
                    TestField("Serial No.");
                if ItemTrackingCode."Lot Specific Tracking" then begin // P8000566A
                    TestField("Lot No.");
                    if IsReclass then                                    // P8000566A
                        TestField("New Lot No.");                          // P8000566A
                end;                                                   // P8000566A
                AltQtyForm.SetTracking(ItemTrackingCode."SN Specific Tracking", ItemTrackingCode."Lot Specific Tracking");
            end;
            AltQtyLine.FilterGroup(4);
            AltQtyLine.SetRange("Alt. Qty. Transaction No.", SourceAltQtyTransNo);
            AltQtyLine.SetRange("Serial No.", "Serial No.");
            AltQtyLine.SetRange("Lot No.", "Lot No.");
            AltQtyLine.FilterGroup(0);
            AltQtyForm.SetTableView(AltQtyLine);
            AltQtyForm.SetLotAndSerial("Lot No.", "Serial No.");
            AltQtyForm.SetNewLot("New Lot No."); // P8000566A
            AltQtyForm.RunModal;
        end;
        UpdateTrackingLine(TrackingLine);
    end;

    local procedure StartTrackingAltQtyLine(var TrackingLine: Record "Tracking Specification")
    begin
        // StartTrackingAltQtyLine
        TestTrackingAltQtyInfo(TrackingLine, true);
        with TrackingLine do begin
            GetItem("Item No.");
            SourceAltQtyTransNo := GetSourceAltQtyTransNo(
              "Source Type", DocumentType, DocumentNo, TemplateName, BatchName, "Source Ref. No.", true);
        end;
    end;

    procedure TestTrackingAltQtyInfo(var TrackingLine: Record "Tracking Specification"; CatchAltQtysCheck: Boolean)
    begin
        // TestTrackingAltQtyInfo
        with TrackingLine do begin
            TestField("Item No.");
            GetItem("Item No.");
            Item.TestField("Alternate Unit of Measure");
            //TESTFIELD("Quantity (Base)"); // PR3.61
            if CatchAltQtysCheck then
                Item.TestField("Catch Alternate Qtys.", true);
        end;
    end;

    local procedure CreateTrackingAltQtyLine(var TrackingLine: Record "Tracking Specification")
    var
        AltQtyLine: Record "Alternate Quantity Line";
        AltQtyLine2: Record "Alternate Quantity Line";
    begin
        // CreateTrackingAltQtyLine
        AltQtyLine2.SetRange("Alt. Qty. Transaction No.", SourceAltQtyTransNo);
        if AltQtyLine2.Find('+') then
            AltQtyLine2."Line No." += 10000
        else
            AltQtyLine2."Line No." := 10000;
        with TrackingLine do begin
            CreateAltQtyLine(
              AltQtyLine, SourceAltQtyTransNo, AltQtyLine2."Line No.", "Source Type",
              DocumentType, DocumentNo, TemplateName, BatchName, "Source Ref. No.");
            AltQtyLine."Serial No." := "Serial No.";
            AltQtyLine."Lot No." := "Lot No.";
            AltQtyLine."New Lot No." := "New Lot No."; // P8000566A
            AltQtyLine.Modify;
        end;
        UpdateTrackingAltQtyLine(TrackingLine, AltQtyLine);
    end;

    local procedure UpdateTrackingAltQtyLine(var TrackingLine: Record "Tracking Specification"; var AltQtyLine: Record "Alternate Quantity Line")
    begin
        // UpdateTrackingAltQtyLine
        with TrackingLine do begin
            AltQtyLine.Validate("Quantity (Alt.)", "Qty. to Handle (Alt.)");
            AltQtyLine.Validate("Quantity (Base)", "Qty. to Handle (Base)");
            AltQtyLine.ValidateQuantity; // P8000108A
            AltQtyLine.Modify(true);
        end;
        SetTrackingLineAltQty(TrackingLine);
    end;

    local procedure UpdateTrackingLine(var TrackingLine: Record "Tracking Specification")
    begin
        // UpdatetrackingLine
        with TrackingLine do begin
            Validate("Qty. to Handle (Alt.)", CalcAltQtyLinesQtyAlt2(SourceAltQtyTransNo, "Serial No.", "Lot No."));
            if AltQtyLinesExist(SourceAltQtyTransNo) then
                Validate("Qty. to Handle (Base)", CalcAltQtyLinesQtyBase2(SourceAltQtyTransNo, "Serial No.", "Lot No."));
            if "Source Type" = DATABASE::"Item Journal Line" then
                Validate("Quantity (Base)", "Qty. to Handle (Base)");
            Modify;
        end;
    end;

    procedure SetTrackingLineAltQty(var TrackingLine: Record "Tracking Specification")
    var
        AltQtyTransNo: Integer;
    begin
        // SetTrackingLineAltQty
        with TrackingLine do begin
            GetItem("Item No.");
            if not Item.TrackAlternateUnits then
                "Quantity (Alt.)" := 0
            else
                if Item."Catch Alternate Qtys." then begin // PR3.61
                    AltQtyTransNo := GetSourceAltQtyTransNo("Source Type", DocumentType, DocumentNo, TemplateName,
                      BatchName, "Source Ref. No.", false);
                    if AltQtyTransNo <> 0 then begin
                        if "Qty. to Handle (Base)" = CalcAltQtyLinesQtyBase2(AltQtyTransNo, "Serial No.", "Lot No.") then
                            "Quantity (Alt.)" := "Quantity Handled (Alt.)" + "Qty. to Handle (Alt.)" +
                              CalcAltQty("Item No.", "Quantity (Base)" - "Qty. to Handle (Base)" - "Quantity Handled (Base)")
                        else
                            "Quantity (Alt.)" := "Quantity Handled (Alt.)" +
                              CalcAltQty("Item No.", "Quantity (Base)" - "Quantity Handled (Base)");
                        SetTrackingLineAltQtyToInvoice(TrackingLine);
                    end;
                    // PR3.61 Begin
                end else begin
                    // P8000550A
                    // "Qty. to Handle (Alt.)" := CalcAltQty("Item No.","Qty. to Handle (Base)");
                    // "Quantity (Alt.)" := "Quantity Handled (Alt.)" +
                    //   CalcAltQty("Item No.","Quantity (Base)" - "Quantity Handled (Base)");
                    if ("Quantity Handled (Base)" = "Quantity (Base)") then
                        "Quantity (Alt.)" := "Quantity Handled (Alt.)"
                    else
                        "Quantity (Alt.)" := CalcAltQty("Item No.", "Quantity (Base)");
                    "Qty. to Handle (Alt.)" :=
                      CalcAltQtyToHandle("Item No.", "Quantity (Base)", "Qty. to Handle (Base)",
                                         "Quantity Handled (Base)", "Quantity (Alt.)", "Quantity Handled (Alt.)");
                    // P8000550A
                    SetTrackingLineAltQtyToInvoice(TrackingLine);
                    // PR3.61 End
                end;
        end;
    end;

    procedure SetTrackingLineAltQtyToInvoice(var TrackingLine: Record "Tracking Specification")
    var
        QtyNotInvoiced: Decimal;
    begin
        // SetTrackingLineAltQtyToInvoice
        with TrackingLine do begin
            if ("Qty. to Invoice (Base)" <= "Qty. to Handle (Base)") and ("Qty. to Handle (Base)" <> 0) then begin
                "Qty. to Invoice (Alt.)" := "Qty. to Handle (Alt.)" * "Qty. to Invoice (Base)" / "Qty. to Handle (Base)";
                "Qty. to Invoice (Alt.)" := Round("Qty. to Invoice (Alt.)", 0.00001);
            end else begin
                "Qty. to Invoice (Alt.)" := "Qty. to Handle (Alt.)";
                QtyNotInvoiced := "Quantity Handled (Base)" - "Quantity Invoiced (Base)";
                if QtyNotInvoiced <> 0 then begin
                    "Qty. to Invoice (Alt.)" += ("Quantity Handled (Alt.)" - "Quantity Invoiced (Alt.)") *
                      ("Qty. to Invoice (Base)" - "Qty. to Handle (Base)") / QtyNotInvoiced;
                    "Qty. to Invoice (Alt.)" := Round("Qty. to Invoice (Alt.)", 0.00001);
                end;
            end;
        end;
    end;

    procedure SetResLineAltQty(TotalResEntry: Record "Reservation Entry")
    var
        ResEntry: Record "Reservation Entry";
        SourceSubtype: Integer;
        AltQtyTransNo: Integer;
        QtyToHandleIsEqual: Boolean;
    begin
        // P8000267B
        with ResEntry do begin
            GetItem(TotalResEntry."Item No.");
            if Item."Catch Alternate Qtys." then begin
                SourceSubtype := TotalResEntry."Source Subtype";
                if (TotalResEntry."Source Type" = DATABASE::"Transfer Line") and
                  (SourceSubtype = 1) and
                  (TotalResEntry."Source Prod. Order Line" = 0)
                then
                    SourceSubtype := 0;
                AltQtyTransNo := GetSourceAltQtyTransNo(TotalResEntry."Source Type", SourceSubtype,
                  TotalResEntry."Source ID", TotalResEntry."Source ID", TotalResEntry."Source Batch Name",
                  TotalResEntry."Source Ref. No.", false);
                if AltQtyTransNo <> 0 then
                    QtyToHandleIsEqual := Abs(TotalResEntry."Qty. to Handle (Base)") =
                      Abs(CalcAltQtyLinesQtyBase2(AltQtyTransNo, TotalResEntry."Serial No.", TotalResEntry."Lot No."));
            end;

            SetCurrentKey("Source Type", "Source ID", "Source Batch Name", "Source Ref. No.", "Lot No.", "Serial No.");
            SetRange("Source Type", TotalResEntry."Source Type");
            SetRange("Source ID", TotalResEntry."Source ID");
            SetRange("Source Batch Name", TotalResEntry."Source Batch Name");
            SetRange("Source Ref. No.", TotalResEntry."Source Ref. No.");
            SetRange("Lot No.", TotalResEntry."Lot No.");
            SetRange("Serial No.", TotalResEntry."Serial No.");
            SetRange("Source Prod. Order Line", TotalResEntry."Source Prod. Order Line");
            SetRange("Source Subtype", TotalResEntry."Source Subtype");

            Find('-');
            repeat
                if QtyToHandleIsEqual then
                    "Quantity (Alt.)" := "Qty. to Handle (Alt.)" +
                      CalcAltQty("Item No.", "Quantity (Base)" - "Qty. to Handle (Base)")
                else
                    // P8007584
                    //"Quantity (Alt.)" := CalcAltQty("Item No.","Quantity (Base)");
                    CalcAltQty("Item No.", Quantity * "Qty. per Unit of Measure");
                // P8007584
                Modify;
            until ResEntry.Next = 0;
        end;

        /*
          GetItem("Item No.");
          IF NOT Item.TrackAlternateUnits THEN
            "Quantity (Alt.)" := 0
          ELSE IF Item."Catch Alternate Qtys." THEN BEGIN
            AltQtyTransNo := GetSourceAltQtyTransNo("Source Type","Source Subtype","Source ID","Source ID",
              "Source Batch Name","Source Ref. No.",FALSE);
            IF AltQtyTransNo <> 0 THEN BEGIN
              IF ABS("Qty. to Handle (Base)") = ABS(CalcAltQtyLinesQtyBase2(AltQtyTransNo,"Serial No.","Lot No.")) THEN
              ELSE
                "Quantity (Alt.)" := CalcAltQty("Item No.","Quantity (Base)");
            END;
          END ELSE
            "Quantity (Alt.)" := CalcAltQty("Item No.","Quantity (Base)");
        
          IF (ABS("Qty. to Invoice (Base)") <= ABS("Qty. to Handle (Base)")) AND ("Qty. to Handle (Base)" <> 0) THEN BEGIN
            "Qty. to Invoice (Alt.)" := "Qty. to Handle (Alt.)" * "Qty. to Invoice (Base)" / "Qty. to Handle (Base)";
            "Qty. to Invoice (Alt.)" := ROUND("Qty. to Invoice (Alt.)",0.00001);
          END ELSE
            "Qty. to Invoice (Alt.)" := "Qty. to Handle (Alt.)";
        END;
         */

    end;

    procedure ValidateSalesAltQtyLine(var SalesLine: Record "Sales Line")
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // ValidateSalesAltQtyLine
        SalesLine.TestAltQtyEntry; // P8000282A
        StartSalesAltQtyLine(SalesLine);
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", SalesLine."Alt. Qty. Transaction No.");
        case AltQtyLine.Count of
            0:
                CreateSalesAltQtyLine(SalesLine);
            1:
                begin
                    AltQtyLine.Find('-');
                    UpdateSalesAltQtyLine(SalesLine, AltQtyLine);
                end;
            else begin
                    Message(Text001);
                    ShowSalesAltQtyLines(SalesLine);
                end;
        end;
    end;

    procedure ShowSalesAltQtyLines(var SalesLine: Record "Sales Line")
    var
        AltQtyLine: Record "Alternate Quantity Line";
        ItemTrackingCode: Record "Item Tracking Code";
        AltQtyForm: Page "Alternate Quantity Lines";
        AltQtyTracking: Codeunit "Alt. Qty. Tracking Management";
        ItemLedgerEntry: Record "Item Ledger Entry";
        Handled: Boolean;
    begin
        // ShowSalesAltQtyLines
        // P80082969
        OnBeforeShowSalesAltQtyLines(SalesLine, Handled);
        if Handled then
            exit;
        // P80082969

        Commit;
        SalesLine.TestAltQtyEntry; // P8000282A
        StartSalesAltQtyLine(SalesLine);
        with SalesLine do begin
            AltQtyForm.SetSource(DATABASE::"Sales Line", "Document Type",
                                 "Document No.", '', '', "Line No.");
            if ("Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"]) then
                AltQtyForm.SetQty("Return Qty. to Receive" * "Qty. per Unit of Measure", FieldCaption("Return Qty. to Receive")) // P8000392A
            else
                AltQtyForm.SetQty("Qty. to Ship" * "Qty. per Unit of Measure", FieldCaption("Qty. to Ship")); // P8000392A
                                                                                                              // P8007924
            if (("Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"])) and (SalesLine."Appl.-from Item Entry" <> 0) then begin
                ItemLedgerEntry.Get(SalesLine."Appl.-from Item Entry");

                AltQtyForm.SetMaxAltQty(-ItemLedgerEntry."Shipped Qty. Not Ret. (Alt.)");
            end;
            // P8007924
            //AltQtyForm.SetMaxQty("Outstanding Quantity" * "Qty. per Unit of Measure"); // P8000392A // P80075420
            AltQtyForm.SetMaxQty(("Outstanding Quantity" - SalesLine.GetContainerQuantity(false)) * "Qty. per Unit of Measure"); // P8000392A // P80075420

            Item.Get("No.");
            if Item."Item Tracking Code" <> '' then begin
                ItemTrackingCode.Get(Item."Item Tracking Code");
                AltQtyForm.SetTracking(ItemTrackingCode."SN Specific Tracking", ItemTrackingCode."Lot Specific Tracking");
            end;
            AltQtyLine.FilterGroup(4);
            AltQtyLine.SetRange("Alt. Qty. Transaction No.", "Alt. Qty. Transaction No.");
            AltQtyLine.FilterGroup(0);
            AltQtyForm.SetTableView(AltQtyLine);
            if "Lot No." <> P800Globals.MultipleLotCode then // P8000043A
                AltQtyForm.SetDefaultLot("Lot No.");           // P8000043A
            AltQtyForm.RunModal;
        end;
        UpdateSalesLine(SalesLine);
        // AltQtyTracking.UpdateSalesTracking(SalesLine); // P8000282A
        UpdateSalesTracking(SalesLine);                   // P8000282A
        SalesLine.SetCurrFieldNo(SalesLine.FieldNo("Qty. to Ship (Alt.)")); // P80070336
        SetSalesLineAltQty(SalesLine);
        SalesLine.GetLotNo; // P8000043A
    end;

    procedure UpdateSalesAltQtyLines(var SalesLine: Record "Sales Line")
    begin
        // P8004516
        UpdateSalesLine(SalesLine);
        UpdateSalesTracking(SalesLine);
        SetSalesLineAltQty(SalesLine);
        SalesLine.GetLotNo;
    end;

    procedure StartSalesAltQtyLine(var SalesLine: Record "Sales Line")
    begin
        // StartSalesAltQtyLine
        TestSalesAltQtyInfo(SalesLine, true);
        with SalesLine do begin
            GetItem(Item); // P800-MegaApp
            if AssignNewTransactionNo("Alt. Qty. Transaction No.") then begin
                Modify;
                Commit;
            end;
        end;
    end;

    procedure TestSalesAltQtyInfo(var SalesLine: Record "Sales Line"; CatchAltQtysCheck: Boolean)
    begin
        // TestSalesAltQtyInfo
        with SalesLine do begin
            TestField(Type, Type::Item);
            TestField("No.");
            GetItem(Item); // P800-MegaApp
            Item.TestField("Alternate Unit of Measure");
            if GetSalesShipReceiveQty(SalesLine, FieldNo("Qty. to Ship (Alt.)")) <> 0 then // PR3.61.01
                TestField("Outstanding Quantity");
            if CatchAltQtysCheck then
                Item.TestField("Catch Alternate Qtys.", true);
        end;
    end;

    local procedure CreateSalesAltQtyLine(var SalesLine: Record "Sales Line")
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // CreateSalesAltQtyLine
        GetItem(SalesLine."No.");                // PR3.61
        if not Item."Catch Alternate Qtys." then // PR3.61
            exit;                                  // PR3.61
        with SalesLine do
            CreateAltQtyLine(
              AltQtyLine, "Alt. Qty. Transaction No.", 10000, DATABASE::"Sales Line",
              "Document Type", "Document No.", '', '', "Line No.");

        if SalesLine."Lot No." <> P800Globals.MultipleLotCode then // P8000043A
            AltQtyLine."Lot No." := SalesLine."Lot No.";             // P8000043A
        UpdateSalesAltQtyLine(SalesLine, AltQtyLine);
    end;

    procedure CreateSalesContainerAltQtyLine(var SalesLine: Record "Sales Line"; LotNo: Code[50]; SerialNo: Code[50]; Qty: Decimal; QtyAlt: Decimal; ContainerID: Code[20]; ContainerLineNo: Integer)
    var
        AltQtyLine: Record "Alternate Quantity Line";
        AltQtyLine2: Record "Alternate Quantity Line";
    begin
        // CreateSalesContainerAltQtyLine
        // PR3.61 Begin
        // P8001324, replace ContainerTransNo with ContainerID, ContainerLineNo
        StartSalesAltQtyLine(SalesLine);
        AltQtyLine2.SetRange("Alt. Qty. Transaction No.", SalesLine."Alt. Qty. Transaction No.");
        if AltQtyLine2.Find('+') then;
        CreateAltQtyLine(
          AltQtyLine, SalesLine."Alt. Qty. Transaction No.", AltQtyLine2."Line No." + 10000, DATABASE::"Sales Line",
          SalesLine."Document Type", SalesLine."Document No.", '', '', SalesLine."Line No.");

        AltQtyLine."Lot No." := LotNo;
        AltQtyLine."Serial No." := SerialNo;
        AltQtyLine.Validate(Quantity, Qty);
        AltQtyLine.Validate("Quantity (Alt.)", QtyAlt);
        AltQtyLine."Container ID" := ContainerID;           // P8001324
        AltQtyLine."Container Line No." := ContainerLineNo; // P8001324
        AltQtyLine.Modify;
        // PR3.61 End
    end;

    local procedure UpdateSalesAltQtyLine(var SalesLine: Record "Sales Line"; var AltQtyLine: Record "Alternate Quantity Line")
    var
        AltQtyTracking: Codeunit "Alt. Qty. Tracking Management";
    begin
        // UpdateSalesAltQtyLine
        with SalesLine do begin
            AltQtyLine.Validate("Quantity (Alt.)",
              GetSalesShipReceiveQty(SalesLine, FieldNo("Qty. to Ship (Alt.)")));
            AltQtyLine.Validate("Quantity (Base)",
              GetSalesShipReceiveQty(SalesLine, FieldNo("Qty. to Ship")) * "Qty. per Unit of Measure"); // P8000392A
            AltQtyLine.Modify(true);
        end;
        // AltQtyTracking.UpdateSalesTracking(SalesLine); // P8000282A
        UpdateSalesTracking(SalesLine);                   // P8000282A
        SetSalesLineAltQty(SalesLine);
    end;

    procedure UpdateSalesLine(var SalesLine: Record "Sales Line")
    begin
        // UpdateSalesLine
        with SalesLine do begin
            if (Type = Type::Item) and ("No." <> '') then begin                       // PR3.60.03
                GetItem(Item); // P800-MegaApp                                         // PR3.60.03
                if Item.TrackAlternateUnits and Item."Catch Alternate Qtys." then begin // PR3.60.03
                    ValidateSalesQtyToPost(
                      SalesLine, true, CalcAltQtyLinesQtyAlt1("Alt. Qty. Transaction No."));
                    if AltQtyLinesExist("Alt. Qty. Transaction No.") then begin
                        if ("Qty. per Unit of Measure" = 0) then
                            "Qty. per Unit of Measure" := 1;
                        ValidateSalesQtyToPost(
                          SalesLine, false,                                                                                    // P8000392A
                            Round(CalcAltQtyLinesQtyBase1("Alt. Qty. Transaction No.") / "Qty. per Unit of Measure", 0.00001)); // P8000392A
                    end;
                    Modify;
                end;                                                                    // PR3.60.03
            end;                                                                      // PR3.60.03
        end;
    end;

    local procedure ValidateSalesQtyToPost(var SalesLine: Record "Sales Line"; SetAltQty: Boolean; NewQty: Decimal)
    var
        SetReceivingQty: Boolean;
        WasSuspended: Boolean;
    begin
        // ValidateSalesQtyToPost
        with SalesLine do begin
            WasSuspended := SuspendStatusCheck2(true); // P80070336, P800110503
            SetReceivingQty :=
              ("Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"]);
            case true of
                SetReceivingQty and SetAltQty:
                    Validate("Return Qty. to Receive (Alt.)", NewQty);
                SetReceivingQty:
                    Validate("Return Qty. to Receive", NewQty);
                SetAltQty:
                    Validate("Qty. to Ship (Alt.)", NewQty);
                else
                    Validate("Qty. to Ship", NewQty);
            end;
            SuspendStatusCheck(WasSuspended); // P80070336
        end;
    end;

    procedure SetSalesLineAltQty(var SalesLine: Record "Sales Line")
    var
        OldQtyAlt: Decimal;
        CheckSuspended: array[2] of Boolean;
        IsNotOrderLine: Boolean;
    begin
        // SetSalesLineAltQty
        with SalesLine do
            if (Type <> Type::Item) or ("No." = '') then
                "Quantity (Alt.)" := 0
            else begin
                GetItem(Item); // P800-MegaApp
                IsNotOrderLine := (SalesLine."Shipment No." <> '') or (SalesLine."Return Receipt No." <> '');
                if not Item.TrackAlternateUnits() then
                    "Quantity (Alt.)" := 0
                else begin
                    OldQtyAlt := "Quantity (Alt.)";
                    // P8000550A
                    if not Item."Catch Alternate Qtys." then
                        // P8007584
                        //"Quantity (Alt.)" := CalcAltQty("No.", "Quantity (Base)")
                        "Quantity (Alt.)" := CalcAltQty("No.", Quantity * "Qty. per Unit of Measure")
                    // P8007584
                    else
                        // P8000550A
                        if ("Appl.-from Item Entry" = 0) then   // P8007924
                            if (GetSalesShipReceiveQty(SalesLine, FieldNo("Qty. to Ship (Base)")) =
                                Round(CalcAltQtyLinesQtyBase1("Alt. Qty. Transaction No."), 0.00001)) // P8000392A
                            then
                                "Quantity (Alt.)" :=
                                  GetSalesShipReceiveQty(SalesLine, FieldNo("Qty. Shipped (Alt.)")) +
                                  GetSalesShipReceiveQty(SalesLine, FieldNo("Qty. to Ship (Alt.)")) +
                                  CalcAltQty("No.",
                                    ("Outstanding Quantity" - GetSalesShipReceiveQty(SalesLine, FieldNo("Qty. to Ship"))) *  // PR3.60.03
                                    "Qty. per Unit of Measure")                                                              // PR3.60.03
                            else
                                // P80047943
                                if not IsNotOrderLine then
                                    "Quantity (Alt.)" :=
                                      GetSalesShipReceiveQty(SalesLine, FieldNo("Qty. Shipped (Alt.)")) +
                                      CalcAltQty("No.", "Outstanding Quantity" * "Qty. per Unit of Measure") // PR3.60.03
                                else
                                    "Quantity (Alt.)" :=
                                      GetSalesShipReceiveQty(SalesLine, FieldNo("Qty. Shipped (Alt.)"));
                    // P80047943
                    // P8007924
                    if IsActualAppliedAltQty then
                        "Quantity (Alt.)" := GetActualAppliedAltQty(SalesLine."Appl.-from Item Entry", "Quantity (Alt.)");
                    // P8007924
                    // P8000199A
                    if ("Quantity (Alt.)" <> OldQtyAlt) then begin
                        Validate("Quantity (Alt.)");
                        //IF Item.CostInAlternateUnits() THEN BEGIN // P8000554A, P8000981
                        if Item.PriceInAlternateUnits() then begin  // P8000981
                                                                    //UpdateAmounts;                    // P8000344A
                            CheckSuspended[1] := SalesLine.SuspendStatusCheck2(true); // P8000344A, P8006787, P800110503
                            CheckSuspended[2] := SalesLine.SuspendCreditCheck(true); // P8000426A, P8006787
                            Validate("Line Discount %");        // P8000344A
                            SalesLine.SuspendCreditCheck(CheckSuspended[2]); // P8000638, P8006787
                            SalesLine.SuspendStatusCheck(CheckSuspended[1]); // P8000638, P8006787
                        end;                                      // P8000554A
                        "Alt. Qty. Update Required" := true; // P8000282A
                    end;
                    // P8000199A

                    // P8007924
                    if IsActualAppliedAltQty then
                        SetSalesLineAltQtyToReceiveFromApplication(SalesLine);
                    // P8007924
                    SetSalesLineAltQtyToInvoice(SalesLine);
                end;
            end;

        SetSalesLineWeights(SalesLine);
    end;

    local procedure SetSalesLineAltQtyToInvoice(var SalesLine: Record "Sales Line")
    var
        PostedQtyToInvBase: Decimal;
        AltQtyTracking: Codeunit "Alt. Qty. Tracking Management";
    begin
        // SetSalesLineAltQtyToInvoice
        with SalesLine do
            // P8000282A
            if ("Qty. to Invoice" =
                  (GetSalesShipReceiveQty(SalesLine, FieldNo("Quantity Shipped")) +
                   GetSalesShipReceiveQty(SalesLine, FieldNo("Qty. to Ship"))))
            then
                "Qty. to Invoice (Alt.)" :=
                  GetSalesShipReceiveQty(SalesLine, FieldNo("Qty. Shipped (Alt.)")) +
                  GetSalesShipReceiveQty(SalesLine, FieldNo("Qty. to Ship (Alt.)"))
            // P8000282A
            else
                if not Item."Catch Alternate Qtys." then
                    // P8000550A
                    // "Qty. to Invoice (Alt.)" := CalcAltQty("No.", "Qty. to Invoice" * "Qty. per Unit of Measure") // PR3.60.03
                    if ("Qty. to Invoice" = GetSalesShipReceiveQty(SalesLine, FieldNo("Qty. to Ship"))) then
                        "Qty. to Invoice (Alt.)" := GetSalesShipReceiveQty(SalesLine, FieldNo("Qty. to Ship (Alt.)"))
                    else
                        if not TrackItem then
                            "Qty. to Invoice (Alt.)" :=
                              CalcAltQtyToHandle("No.", "Quantity (Base)", "Qty. to Invoice (Base)",
                                                 "Qty. Invoiced (Base)", "Quantity (Alt.)", "Qty. Invoiced (Alt.)")
                        else
                            "Qty. to Invoice (Alt.)" :=
                              Abs(AltQtyTracking.GetAltQtyToInvoice(
                                DATABASE::"Sales Line", "Document No.", "Document Type", '', 0, "Line No."))
                // P8000550A
                else
                    if not TrackItem then begin
                        CalcAltQtyToInvoice(
                          "No.", "Alt. Qty. Transaction No.", "Qty. to Invoice" * "Qty. per Unit of Measure",      // PR3.60.03
                          GetSalesShipReceiveQty(SalesLine, FieldNo("Qty. to Ship")) * "Qty. per Unit of Measure", // PR3.60.03
                          "Qty. to Invoice (Alt.)", PostedQtyToInvBase);
                        if (PostedQtyToInvBase <> 0) then
                            if ("Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"]) then
                                "Qty. to Invoice (Alt.)" := "Qty. to Invoice (Alt.)" +
                                  CalcReturnRcptQtyAlt(SalesLine, PostedQtyToInvBase)
                            else
                                "Qty. to Invoice (Alt.)" := "Qty. to Invoice (Alt.)" +
                                  CalcShipmentQtyAlt(SalesLine, PostedQtyToInvBase);
                    end else begin
                        "Qty. to Invoice (Alt.)" :=
                          Abs(AltQtyTracking.GetAltQtyToInvoice(DATABASE::"Sales Line", "Document No.", "Document Type", '', 0, "Line No."));
                    end;
    end;

    local procedure SetSalesLineWeights(var SalesLine: Record "Sales Line")
    begin
        // SetSalesLineWeights
        with SalesLine do
            if (Type = Type::Item) and ("No." <> '') then begin
                GetItem(Item); // P800-MegaApp
                CalcLineWeights(
                  "Alt. Qty. Transaction No.", "Qty. per Unit of Measure",
                  GetSalesShipReceiveQty(SalesLine, FieldNo("Qty. to Ship")),
                  GetSalesShipReceiveQty(SalesLine, FieldNo("Qty. to Ship (Base)")),
                  GetSalesShipReceiveQty(SalesLine, FieldNo("Qty. to Ship (Alt.)")),
                  "Net Weight", "Net Weight to Ship");
            end;
    end;

    local procedure CalcShipmentQtyAlt(var SalesLine: Record "Sales Line"; QtyBase: Decimal) QtyAlt: Decimal
    var
        ShipmentLine: Record "Sales Shipment Line";
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // CalcShipmentQtyAlt
        QtyAlt := 0;
        with ShipmentLine do begin
            SetCurrentKey("Order No.", "Order Line No.");
            SetRange("Order No.", SalesLine."Document No.");
            SetRange("Order Line No.", SalesLine."Line No.");
            SetRange(Correction, false); // PR3.61.02
            if Find('-') then
                repeat
                    if (Abs(QtyBase) >= Abs("Quantity (Base)" - "Qty. Invoiced (Base)")) then begin
                        QtyBase := QtyBase - ("Quantity (Base)" - "Qty. Invoiced (Base)");
                        QtyAlt := QtyAlt + ("Quantity (Alt.)" - "Qty. Invoiced (Alt.)");
                    end else begin
                        AltQtyEntry.SetRange("Table No.", DATABASE::"Sales Shipment Line");
                        AltQtyEntry.SetRange("Document No.", "Document No.");
                        AltQtyEntry.SetRange("Source Line No.", "Line No.");
                        CalcAltQtyToInvoicePosted(AltQtyEntry, QtyBase, QtyAlt);
                    end;
                until (QtyBase = 0) or (Next = 0);
        end;
    end;

    local procedure CalcReturnRcptQtyAlt(var SalesLine: Record "Sales Line"; QtyBase: Decimal) QtyAlt: Decimal
    var
        ReturnRcptLine: Record "Return Receipt Line";
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // CalcReturnRcptQtyAlt
        QtyAlt := 0;
        with ReturnRcptLine do begin
            SetCurrentKey("Return Order No.", "Return Order Line No.");
            SetRange("Return Order No.", SalesLine."Document No.");
            SetRange("Return Order Line No.", SalesLine."Line No.");
            SetRange(Correction, false); // PR3.61.02
            if Find('-') then
                repeat
                    if (Abs(QtyBase) >= Abs("Quantity (Base)" - "Qty. Invoiced (Base)")) then begin
                        QtyBase := QtyBase - ("Quantity (Base)" - "Qty. Invoiced (Base)");
                        QtyAlt := QtyAlt + ("Quantity (Alt.)" - "Qty. Invoiced (Alt.)");
                    end else begin
                        AltQtyEntry.SetRange("Table No.", DATABASE::"Return Receipt Line");
                        AltQtyEntry.SetRange("Document No.", "Document No.");
                        AltQtyEntry.SetRange("Source Line No.", "Line No.");
                        CalcAltQtyToInvoicePosted(AltQtyEntry, QtyBase, QtyAlt);
                    end;
                until (QtyBase = 0) or (Next = 0);
        end;
    end;

    local procedure GetSalesShipReceiveQty(var SalesLine: Record "Sales Line"; FldNo: Integer): Decimal
    begin
        // GetSalesShipReceiveQty
        with SalesLine do begin
            if ("Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"]) then
                case FldNo of
                    FieldNo("Qty. to Ship"):
                        exit("Return Qty. to Receive");
                    FieldNo("Qty. to Ship (Base)"):
                        exit("Return Qty. to Receive (Base)");
                    FieldNo("Qty. to Ship (Alt.)"):
                        exit("Return Qty. to Receive (Alt.)");
                    FieldNo("Quantity Shipped"):
                        exit("Return Qty. Received");
                    FieldNo("Qty. Shipped (Base)"):
                        exit("Return Qty. Received (Base)");
                    FieldNo("Qty. Shipped (Alt.)"):
                        exit("Return Qty. Received (Alt.)");
                end;
            case FldNo of
                FieldNo("Qty. to Ship"):
                    exit("Qty. to Ship");
                FieldNo("Qty. to Ship (Base)"):
                    exit("Qty. to Ship (Base)");
                FieldNo("Qty. to Ship (Alt.)"):
                    exit("Qty. to Ship (Alt.)");
                FieldNo("Quantity Shipped"):
                    exit("Quantity Shipped");
                FieldNo("Qty. Shipped (Base)"):
                    exit("Qty. Shipped (Base)");
                FieldNo("Qty. Shipped (Alt.)"):
                    exit("Qty. Shipped (Alt.)");
            end;
        end;
    end;

    procedure SalesLineToShipmentLine(var SalesLine: Record "Sales Line"; var ShipmentLine: Record "Sales Shipment Line")
    begin
        // SalesLineToShipmentLine
        with ShipmentLine do
            AltQtyLinesToAltQtyEntries1(
              SalesLine."Alt. Qty. Transaction No.",
              DATABASE::"Sales Shipment Line", "Document No.", "Line No.", 0, false, true); // P8000504A

        UpdateShipmentAltQtyEntries(ShipmentLine);
    end;

    procedure UpdateShipmentAltQtyEntries(var ShipmentLine: Record "Sales Shipment Line")
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ItemEntryRelation: Record "Item Entry Relation";
    begin
        // UpdateShipmentAltQtyEntries
        with ShipmentLine do begin
            if ("Qty. Invoiced (Base)" <> 0) then
                if "Item Shpt. Entry No." <> 0 then
                    UpdateAltQtyEntries(
                      DATABASE::"Sales Shipment Line", "Document No.", "Line No.",
                      "Order Line No.", "Item Shpt. Entry No.")
                else begin
                    ItemEntryRelation.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Ref. No.");
                    ItemEntryRelation.SetRange("Source Type", DATABASE::"Sales Shipment Line");
                    ItemEntryRelation.SetRange("Source ID", "Document No.");
                    ItemEntryRelation.SetRange("Source Ref. No.", "Line No.");
                    if ItemEntryRelation.Find('-') then begin
                        repeat
                            ItemLedgEntry.Get(ItemEntryRelation."Item Entry No.");
                            if ItemLedgEntry."Invoiced Quantity" <> 0 then
                                UpdateAltQtyEntries(
                                  DATABASE::"Sales Shipment Line", "Document No.", "Line No.",
                                  "Order Line No.", ItemEntryRelation."Item Entry No.")
                        until ItemEntryRelation.Next = 0;
                    end;
                end;
        end;
    end;

    procedure SalesLineToReturnRcptLine(var SalesLine: Record "Sales Line"; var ReturnRcptLine: Record "Return Receipt Line")
    begin
        // SalesLineToReturnRcptLine
        with ReturnRcptLine do
            AltQtyLinesToAltQtyEntries1(
              SalesLine."Alt. Qty. Transaction No.",
              DATABASE::"Return Receipt Line", "Document No.", "Line No.", 0, false, true); // P8000504A

        UpdateReturnRcptAltQtyEntries(ReturnRcptLine);
    end;

    procedure UpdateReturnRcptAltQtyEntries(var ReturnRcptLine: Record "Return Receipt Line")
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ItemEntryRelation: Record "Item Entry Relation";
        OrderLineNo: Integer;
    begin
        // UpdateReturnRcptAltQtyEntries
        with ReturnRcptLine do begin
            if "Return Order Line No." <> 0 then     // PR3.61.01
                OrderLineNo := "Return Order Line No." // PR3.61.01
            else                                     // PR3.61.01
                OrderLineNo := "Line No.";             // PR3.61.01
            if ("Qty. Invoiced (Base)" <> 0) then
                if "Item Rcpt. Entry No." <> 0 then
                    UpdateAltQtyEntries(
                      DATABASE::"Return Receipt Line", "Document No.", "Line No.",
                      OrderLineNo, "Item Rcpt. Entry No.") // PR3.61.01
                else begin
                    ItemEntryRelation.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Ref. No.");
                    ItemEntryRelation.SetRange("Source Type", DATABASE::"Return Receipt Line");
                    ItemEntryRelation.SetRange("Source ID", "Document No.");
                    ItemEntryRelation.SetRange("Source Ref. No.", "Line No.");
                    if ItemEntryRelation.Find('-') then begin
                        repeat
                            ItemLedgEntry.Get(ItemEntryRelation."Item Entry No.");
                            if ItemLedgEntry."Invoiced Quantity" <> 0 then
                                UpdateAltQtyEntries(
                                  DATABASE::"Return Receipt Line", "Document No.", "Line No.",
                                  OrderLineNo, ItemEntryRelation."Item Entry No.") // PR3.61.01
                        until ItemEntryRelation.Next = 0;
                    end;
                end;
        end;
    end;

    procedure SalesLineToCreditMemoLine(var SalesLine: Record "Sales Line"; var CreditMemoLine: Record "Sales Cr.Memo Line")
    var
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // SalesLineToCreditMemoLine
        // PR3.61.01 Begin
        with CreditMemoLine do begin
            AltQtyLinesToAltQtyEntries1(
              SalesLine."Alt. Qty. Transaction No.",
              DATABASE::"Sales Cr.Memo Line", "Document No.", "Line No.", 0, false, true); // P8000504A

            AltQtyEntry.SetRange("Table No.", DATABASE::"Sales Cr.Memo Line");
            AltQtyEntry.SetRange("Document No.", "Document No.");
            AltQtyEntry.SetRange("Source Line No.", "Line No.");
            if AltQtyEntry.Find('-') then
                repeat
                    AltQtyEntry."Invoiced Qty. (Base)" := AltQtyEntry."Quantity (Base)";
                    AltQtyEntry."Invoiced Qty. (Alt.)" := AltQtyEntry."Quantity (Alt.)";
                    AltQtyEntry.Modify;
                until AltQtyEntry.Next = 0;
        end;
        // PR3.61.01 End
    end;

    procedure CheckSalesRelease(var SalesHeader: Record "Sales Header")
    var
        OrigSalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // CheckSalesRelease
        // P8000282A
        OrigSalesHeader := SalesHeader;
        with SalesHeader do
            if (Status = Status::Released) and Invoice then begin
                SalesLine.SetRange("Document Type", "Document Type");
                SalesLine.SetRange("Document No.", "No.");
                SalesLine.SetRange("Alt. Qty. Update Required", true);
                if SalesLine.Find('-') then begin
                    Status := Status::Open;
                    CODEUNIT.Run(CODEUNIT::"Release Sales Document", SalesHeader);
                    Ship := OrigSalesHeader.Ship;
                    Invoice := OrigSalesHeader.Invoice;
                    Receive := OrigSalesHeader.Receive;
                    Modify;
                    Commit;
                end;
            end;
    end;

    local procedure UpdateSalesTracking(var SalesLine: Record "Sales Line")
    var
        Location: Record Location;
        AltQtyTracking: Codeunit "Alt. Qty. Tracking Management";
    begin
        // P8000282A
        with SalesLine do begin
            if not ("Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"]) then begin
                GetLocation("Location Code", Location);
                if Location."Require Shipment" and Location."Require Pick" then begin
                    UpdateTrackingAltQtys(
                      "Alt. Qty. Transaction No.", DATABASE::"Sales Line",
                      "Document Type", "Document No.", 0, "Line No.");
                    exit;
                end;
            end;
            AltQtyTracking.UpdateSalesTracking(SalesLine);
        end;
    end;

    procedure ValidatePurchAltQtyLine(var PurchLine: Record "Purchase Line")
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // ValidatePurchAltQtyLine
        PurchLine.TestAltQtyEntry; // P8000282A
        StartPurchAltQtyLine(PurchLine);
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", PurchLine."Alt. Qty. Transaction No.");
        case AltQtyLine.Count of
            0:
                CreatePurchAltQtyLine(PurchLine);
            1:
                begin
                    AltQtyLine.Find('-');
                    UpdatePurchAltQtyLine(PurchLine, AltQtyLine);
                end;
            else begin
                    Message(Text001);
                    ShowPurchAltQtyLines(PurchLine);
                end;
        end;
    end;

    procedure ShowPurchAltQtyLines(var PurchLine: Record "Purchase Line")
    var
        AltQtyLine: Record "Alternate Quantity Line";
        ItemTrackingCode: Record "Item Tracking Code";
        AltQtyForm: Page "Alternate Quantity Lines";
        AltQtyTracking: Codeunit "Alt. Qty. Tracking Management";
        Handled: Boolean;
    begin
        // ShowPurchAltQtyLines
        // P80082969
        OnBeforeShowPurchAltQtyLines(PurchLine, Handled);
        if Handled then
            exit;
        // P80082969

        Commit;
        PurchLine.TestAltQtyEntry; // P8000282A
        StartPurchAltQtyLine(PurchLine);
        with PurchLine do begin
            AltQtyForm.SetSource(DATABASE::"Purchase Line", "Document Type",
                                 "Document No.", '', '', "Line No.");
            if ("Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"]) then
                AltQtyForm.SetQty("Return Qty. to Ship" * "Qty. per Unit of Measure", FieldCaption("Return Qty. to Ship")) // P8000392A
            else
                AltQtyForm.SetQty("Qty. to Receive" * "Qty. per Unit of Measure", FieldCaption("Qty. to Receive")); // P8000392A
                                                                                                                    //AltQtyForm.SetMaxQty("Outstanding Quantity" * "Qty. per Unit of Measure"); // P8000392A // P80075420
            AltQtyForm.SetMaxQty(("Outstanding Quantity" - PurchLine.GetContainerQuantity(false)) * "Qty. per Unit of Measure"); // P8000392A // P80075420
            Item.Get("No.");
            if Item."Item Tracking Code" <> '' then begin
                ItemTrackingCode.Get(Item."Item Tracking Code");
                AltQtyForm.SetTracking(ItemTrackingCode."SN Specific Tracking", ItemTrackingCode."Lot Specific Tracking");
            end;
            AltQtyLine.FilterGroup(4);
            AltQtyLine.SetRange("Alt. Qty. Transaction No.", "Alt. Qty. Transaction No.");
            AltQtyLine.FilterGroup(0);
            AltQtyForm.SetTableView(AltQtyLine);
            if "Lot No." <> P800Globals.MultipleLotCode then // P8000043A
                AltQtyForm.SetDefaultLot("Lot No.");           // P8000043A
            AltQtyForm.RunModal;
        end;
        UpdatePurchLine(PurchLine);
        // AltQtyTracking.UpdatePurchTracking(PurchLine); // P8000282A
        UpdatePurchTracking(PurchLine);                   // P8000282A
        PurchLine.SetCurrFieldNo(PurchLine.FieldNo("Qty. to Receive (Alt.)")); // P80070336
        SetPurchLineAltQty(PurchLine);
        PurchLine.GetLotNo; // P8000043A
    end;

    procedure UpdatePurchAltQtyLines(var PurchaseLine: Record "Purchase Line")
    begin
        // P8004516
        UpdatePurchLine(PurchaseLine);
        UpdatePurchTracking(PurchaseLine);
        SetPurchLineAltQty(PurchaseLine);
        PurchaseLine.GetLotNo;
    end;

    procedure StartPurchAltQtyLine(var PurchLine: Record "Purchase Line")
    begin
        // StartPurchAltQtyLine
        TestPurchAltQtyInfo(PurchLine, true);
        with PurchLine do begin
            Item := GetItem(); // P800144605
            if AssignNewTransactionNo("Alt. Qty. Transaction No.") then begin
                Modify;
                Commit;
            end;
        end;
    end;

    procedure TestPurchAltQtyInfo(var PurchLine: Record "Purchase Line"; CatchAltQtysCheck: Boolean)
    begin
        // TestPurchAltQtyInfo
        with PurchLine do begin
            TestField(Type, Type::Item);
            TestField("No.");
            Item := GetItem(); // P800144605
            Item.TestField("Alternate Unit of Measure");
            if GetPurchShipReceiveQty(PurchLine, FieldNo("Qty. to Receive (Alt.)")) <> 0 then // PR3.61.01
                TestField("Outstanding Quantity");
            if CatchAltQtysCheck then
                Item.TestField("Catch Alternate Qtys.", true);
        end;
    end;

    local procedure CreatePurchAltQtyLine(var PurchLine: Record "Purchase Line")
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // CreatePurchAltQtyLine
        with PurchLine do
            CreateAltQtyLine(
              AltQtyLine, "Alt. Qty. Transaction No.", 10000, DATABASE::"Purchase Line",
              "Document Type", "Document No.", '', '', "Line No.");

        if PurchLine."Lot No." <> P800Globals.MultipleLotCode then // P8000043A
            AltQtyLine."Lot No." := PurchLine."Lot No.";             // P8000043A
        UpdatePurchAltQtyLine(PurchLine, AltQtyLine);
    end;

    local procedure UpdatePurchAltQtyLine(var PurchLine: Record "Purchase Line"; var AltQtyLine: Record "Alternate Quantity Line")
    var
        AltQtyTracking: Codeunit "Alt. Qty. Tracking Management";
    begin
        // UpdatePurchAltQtyLine
        with PurchLine do begin
            AltQtyLine.Validate("Quantity (Alt.)",
              GetPurchShipReceiveQty(PurchLine, FieldNo("Qty. to Receive (Alt.)")));
            AltQtyLine.Validate("Quantity (Base)",
              GetPurchShipReceiveQty(PurchLine, FieldNo("Qty. to Receive")) * "Qty. per Unit of Measure"); // P8000392A
            AltQtyLine.Modify(true);
        end;
        // AltQtyTracking.UpdatePurchTracking(PurchLine); // P8000282A
        UpdatePurchTracking(PurchLine);                   // P8000282A
        SetPurchLineAltQty(PurchLine);
    end;

    procedure UpdatePurchLine(var PurchLine: Record "Purchase Line")
    begin
        // UpdatePurchLine
        with PurchLine do begin
            if (Type = Type::Item) and ("No." <> '') then begin                         // PR3.60.03
                Item := GetItem();                                                      // PR3.60.03, P800144605
                if Item.TrackAlternateUnits and Item."Catch Alternate Qtys." then begin // PR3.60.03
                    ValidatePurchQtyToPost(
                      PurchLine, true, CalcAltQtyLinesQtyAlt1("Alt. Qty. Transaction No."));
                    if AltQtyLinesExist("Alt. Qty. Transaction No.") then begin
                        if ("Qty. per Unit of Measure" = 0) then
                            "Qty. per Unit of Measure" := 1;
                        ValidatePurchQtyToPost(
                          PurchLine, false,                                                                                    // P8000392A
                            Round(CalcAltQtyLinesQtyBase1("Alt. Qty. Transaction No.") / "Qty. per Unit of Measure", 0.00001)); // P8000392A
                    end;
                    Modify;
                end;                                                                    // PR3.60.03
            end;                                                                      // PR3.60.03
        end;
    end;

    local procedure ValidatePurchQtyToPost(var PurchLine: Record "Purchase Line"; SetAltQty: Boolean; NewQty: Decimal)
    var
        SetShippingQty: Boolean;
        WasSuspended: Boolean;
    begin
        // ValidatePurchQtyToPost
        with PurchLine do begin
            WasSuspended := SuspendStatusCheck2(true); // P80070336, P800110503
            SetShippingQty :=
              ("Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"]);
            case true of
                SetShippingQty and SetAltQty:
                    Validate("Return Qty. to Ship (Alt.)", NewQty);
                SetShippingQty:
                    Validate("Return Qty. to Ship", NewQty);
                SetAltQty:
                    Validate("Qty. to Receive (Alt.)", NewQty);
                else
                    Validate("Qty. to Receive", NewQty);
            end;
            SuspendStatusCheck(WasSuspended); // P80070336
        end;
    end;

    procedure SetPurchLineAltQty(var PurchLine: Record "Purchase Line")
    var
        OldQtyAlt: Decimal;
        CheckSuspended: Boolean;
        IsNotOrderLine: Boolean;
    begin
        // SetPurchLineAltQty
        with PurchLine do
            if (Type <> Type::Item) or ("No." = '') then
                "Quantity (Alt.)" := 0
            else begin
                Item := GetItem(); // P800144605
                IsNotOrderLine := (PurchLine."Receipt No." <> '') or (PurchLine."Return Shipment No." <> '');
                if not Item.TrackAlternateUnits() then
                    "Quantity (Alt.)" := 0
                else begin
                    OldQtyAlt := "Quantity (Alt.)";
                    // P8000550A
                    if not Item."Catch Alternate Qtys." then
                        // P8007584
                        //"Quantity (Alt.)" := CalcAltQty("No.", "Quantity (Base)")
                        "Quantity (Alt.)" := CalcAltQty("No.", Quantity * "Qty. per Unit of Measure")
                    // P8007584
                    else
                        // P8000550A
                        if (GetPurchShipReceiveQty(PurchLine, FieldNo("Qty. to Receive (Base)")) =
                            Round(CalcAltQtyLinesQtyBase1("Alt. Qty. Transaction No."), 0.00001)) // P8000392A
                        then
                            "Quantity (Alt.)" :=
                              GetPurchShipReceiveQty(PurchLine, FieldNo("Qty. Received (Alt.)")) +
                              GetPurchShipReceiveQty(PurchLine, FieldNo("Qty. to Receive (Alt.)")) +
                              CalcAltQty("No.",
                                ("Outstanding Quantity" - GetPurchShipReceiveQty(PurchLine, FieldNo("Qty. to Receive"))) *  // PR3.60.03
                                "Qty. per Unit of Measure")                                                                 // PR3.60.03
                        else
                            // P80047943
                            if not IsNotOrderLine then
                                "Quantity (Alt.)" :=
                                  GetPurchShipReceiveQty(PurchLine, FieldNo("Qty. Received (Alt.)")) +
                                  CalcAltQty("No.", "Outstanding Quantity" * "Qty. per Unit of Measure") // PR3.60.03
                            else
                                "Quantity (Alt.)" :=
                                  GetPurchShipReceiveQty(PurchLine, FieldNo("Qty. Received (Alt.)"));
                    // P8000199A
                    // P80047943
                    if ("Quantity (Alt.)" <> OldQtyAlt) then begin
                        Validate("Quantity (Alt.)");
                        if Item.CostInAlternateUnits() then begin // P8000554A
                                                                  //UpdateAmounts;                    // P8000344A
                            CheckSuspended := PurchLine.SuspendStatusCheck2(true); // P8000344A, P8006787, P800110503
                            Validate("Line Discount %");        // P8000344A
                            PurchLine.SuspendStatusCheck(CheckSuspended); // P8000638, P8006787
                        end;                                      // P8000554A
                        "Alt. Qty. Update Required" := true; // P8000282A
                    end;
                    // P8000199A

                    SetPurchLineAltQtyToInvoice(PurchLine);
                end;
            end;

        SetPurchLineWeights(PurchLine);
    end;

    local procedure SetPurchLineAltQtyToInvoice(var PurchLine: Record "Purchase Line")
    var
        AltQtyTracking: Codeunit "Alt. Qty. Tracking Management";
        PostedQtyToInvBase: Decimal;
    begin
        // SetPurchLineAltQtyToInvoice
        with PurchLine do
            // P8000282A
            if ("Qty. to Invoice" =
                  (GetPurchShipReceiveQty(PurchLine, FieldNo("Quantity Received")) +
                   GetPurchShipReceiveQty(PurchLine, FieldNo("Qty. to Receive"))))
            then
                "Qty. to Invoice (Alt.)" :=
                  GetPurchShipReceiveQty(PurchLine, FieldNo("Qty. Received (Alt.)")) +
                  GetPurchShipReceiveQty(PurchLine, FieldNo("Qty. to Receive (Alt.)"))
            // P8000282A
            else
                if not Item."Catch Alternate Qtys." then
                    // P8000550A
                    // "Qty. to Invoice (Alt.)" := CalcAltQty("No.", "Qty. to Invoice" * "Qty. per Unit of Measure") // PR3.60.03
                    if ("Qty. to Invoice" = GetPurchShipReceiveQty(PurchLine, FieldNo("Qty. to Receive"))) then
                        "Qty. to Invoice (Alt.)" := GetPurchShipReceiveQty(PurchLine, FieldNo("Qty. to Receive (Alt.)"))
                    else
                        if not TrackItem then
                            "Qty. to Invoice (Alt.)" :=
                              CalcAltQtyToHandle("No.", "Quantity (Base)", "Qty. to Invoice (Base)",
                                                 "Qty. Invoiced (Base)", "Quantity (Alt.)", "Qty. Invoiced (Alt.)")
                        else
                            "Qty. to Invoice (Alt.)" :=
                              Abs(AltQtyTracking.GetAltQtyToInvoice(
                                DATABASE::"Purchase Line", "Document No.", "Document Type", '', 0, "Line No."))
                // P8000550A
                else
                    if not TrackItem then begin
                        CalcAltQtyToInvoice(
                          "No.", "Alt. Qty. Transaction No.", "Qty. to Invoice" * "Qty. per Unit of Measure",         // PR3.60.03
                          GetPurchShipReceiveQty(PurchLine, FieldNo("Qty. to Receive")) * "Qty. per Unit of Measure", // PR3.60.03
                          "Qty. to Invoice (Alt.)", PostedQtyToInvBase);
                        if (PostedQtyToInvBase <> 0) then
                            if ("Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"]) then
                                "Qty. to Invoice (Alt.)" := "Qty. to Invoice (Alt.)" +
                                  CalcReturnShptQtyAlt(PurchLine, PostedQtyToInvBase)
                            else
                                "Qty. to Invoice (Alt.)" := "Qty. to Invoice (Alt.)" +
                                  CalcReceiptQtyAlt(PurchLine, PostedQtyToInvBase);
                    end else begin
                        "Qty. to Invoice (Alt.)" :=
                          Abs(AltQtyTracking.GetAltQtyToInvoice(DATABASE::"Purchase Line", "Document No.", "Document Type", '', 0, "Line No."));
                    end;
    end;

    local procedure SetPurchLineWeights(var PurchLine: Record "Purchase Line")
    var
        NetWeightToReceive: Decimal;
    begin
        // SetPurchLineWeights
        with PurchLine do
            if (Type = Type::Item) and ("No." <> '') then begin
                Item := GetItem(); // P800144605
                CalcLineWeights(
                  "Alt. Qty. Transaction No.", "Qty. per Unit of Measure",
                  GetPurchShipReceiveQty(PurchLine, FieldNo("Qty. to Receive")),
                  GetPurchShipReceiveQty(PurchLine, FieldNo("Qty. to Receive (Base)")),
                  GetPurchShipReceiveQty(PurchLine, FieldNo("Qty. to Receive (Alt.)")),
                  "Net Weight", NetWeightToReceive);
            end;
    end;

    local procedure CalcReceiptQtyAlt(var PurchLine: Record "Purchase Line"; QtyBase: Decimal) QtyAlt: Decimal
    var
        ReceiptLine: Record "Purch. Rcpt. Line";
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // CalcReceiptQtyAlt
        QtyAlt := 0;
        with ReceiptLine do begin
            SetCurrentKey("Order No.", "Order Line No.");
            SetRange("Order No.", PurchLine."Document No.");
            SetRange("Order Line No.", PurchLine."Line No.");
            SetRange(Correction, false); // PR3.61.02
            if Find('-') then
                repeat
                    if (Abs(QtyBase) >= Abs("Quantity (Base)" - "Qty. Invoiced (Base)")) then begin
                        QtyBase := QtyBase - ("Quantity (Base)" - "Qty. Invoiced (Base)");
                        QtyAlt := QtyAlt + ("Quantity (Alt.)" - "Qty. Invoiced (Alt.)");
                    end else begin
                        AltQtyEntry.SetRange("Table No.", DATABASE::"Purch. Rcpt. Line");
                        AltQtyEntry.SetRange("Document No.", "Document No.");
                        AltQtyEntry.SetRange("Source Line No.", "Line No.");
                        CalcAltQtyToInvoicePosted(AltQtyEntry, QtyBase, QtyAlt);
                    end;
                until (QtyBase = 0) or (Next = 0);
        end;
    end;

    local procedure CalcReturnShptQtyAlt(var PurchLine: Record "Purchase Line"; QtyBase: Decimal) QtyAlt: Decimal
    var
        ReturnShptLine: Record "Return Shipment Line";
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // CalcReturnShptQtyAlt
        QtyAlt := 0;
        with ReturnShptLine do begin
            SetCurrentKey("Return Order No.", "Return Order Line No.");
            SetRange("Return Order No.", PurchLine."Document No.");
            SetRange("Return Order Line No.", PurchLine."Line No.");
            SetRange(Correction, false); // PR3.61.02
            if Find('-') then
                repeat
                    if (Abs(QtyBase) >= Abs("Quantity (Base)" - "Qty. Invoiced (Base)")) then begin
                        QtyBase := QtyBase - ("Quantity (Base)" - "Qty. Invoiced (Base)");
                        QtyAlt := QtyAlt + ("Quantity (Alt.)" - "Qty. Invoiced (Alt.)");
                    end else begin
                        AltQtyEntry.SetRange("Table No.", DATABASE::"Return Shipment Line");
                        AltQtyEntry.SetRange("Document No.", "Document No.");
                        AltQtyEntry.SetRange("Source Line No.", "Line No.");
                        CalcAltQtyToInvoicePosted(AltQtyEntry, QtyBase, QtyAlt);
                    end;
                until (QtyBase = 0) or (Next = 0);
        end;
    end;

    local procedure GetPurchShipReceiveQty(var PurchLine: Record "Purchase Line"; FldNo: Integer): Decimal
    begin
        // GetPurchShipReceiveQty
        with PurchLine do begin
            if ("Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"]) then
                case FldNo of
                    FieldNo("Qty. to Receive"):
                        exit("Return Qty. to Ship");
                    FieldNo("Qty. to Receive (Base)"):
                        exit("Return Qty. to Ship (Base)");
                    FieldNo("Qty. to Receive (Alt.)"):
                        exit("Return Qty. to Ship (Alt.)");
                    FieldNo("Quantity Received"):
                        exit("Return Qty. Shipped");
                    FieldNo("Qty. Received (Base)"):
                        exit("Return Qty. Shipped (Base)");
                    FieldNo("Qty. Received (Alt.)"):
                        exit("Return Qty. Shipped (Alt.)");
                end;
            case FldNo of
                FieldNo("Qty. to Receive"):
                    exit("Qty. to Receive");
                FieldNo("Qty. to Receive (Base)"):
                    exit("Qty. to Receive (Base)");
                FieldNo("Qty. to Receive (Alt.)"):
                    exit("Qty. to Receive (Alt.)");
                FieldNo("Quantity Received"):
                    exit("Quantity Received");
                FieldNo("Qty. Received (Base)"):
                    exit("Qty. Received (Base)");
                FieldNo("Qty. Received (Alt.)"):
                    exit("Qty. Received (Alt.)");
            end;
        end;
    end;

    procedure PurchLineToReceiptLine(var PurchLine: Record "Purchase Line"; var ReceiptLine: Record "Purch. Rcpt. Line")
    begin
        // PurchLineToReceiptLine
        with ReceiptLine do
            AltQtyLinesToAltQtyEntries1(
              PurchLine."Alt. Qty. Transaction No.",
              DATABASE::"Purch. Rcpt. Line", "Document No.", "Line No.", 0, false, true); // P8000504A

        UpdateReceiptAltQtyEntries(ReceiptLine);
    end;

    procedure UpdateReceiptAltQtyEntries(var ReceiptLine: Record "Purch. Rcpt. Line")
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ItemEntryRelation: Record "Item Entry Relation";
    begin
        // UpdateReceiptAltQtyEntries
        with ReceiptLine do begin
            if ("Qty. Invoiced (Base)" <> 0) then
                if "Item Rcpt. Entry No." <> 0 then
                    UpdateAltQtyEntries(
                      DATABASE::"Purch. Rcpt. Line", "Document No.", "Line No.",
                      "Order Line No.", "Item Rcpt. Entry No.")
                else begin
                    ItemEntryRelation.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Ref. No.");
                    ItemEntryRelation.SetRange("Source Type", DATABASE::"Purch. Rcpt. Line");
                    ItemEntryRelation.SetRange("Source ID", "Document No.");
                    ItemEntryRelation.SetRange("Source Ref. No.", "Line No.");
                    if ItemEntryRelation.Find('-') then begin
                        repeat
                            ItemLedgEntry.Get(ItemEntryRelation."Item Entry No.");
                            if ItemLedgEntry."Invoiced Quantity" <> 0 then
                                UpdateAltQtyEntries(
                                  DATABASE::"Purch. Rcpt. Line", "Document No.", "Line No.",
                                  "Order Line No.", ItemEntryRelation."Item Entry No.")
                        until ItemEntryRelation.Next = 0;
                    end;
                end;
        end;
    end;

    procedure PurchLineToReturnShptLine(var PurchLine: Record "Purchase Line"; var ReturnShptLine: Record "Return Shipment Line")
    begin
        // PurchLineToReturnShptLine
        with ReturnShptLine do
            AltQtyLinesToAltQtyEntries1(
              PurchLine."Alt. Qty. Transaction No.",
              DATABASE::"Return Shipment Line", "Document No.", "Line No.", 0, false, true); // P8000504A

        UpdateReturnShptAltQtyEntries(ReturnShptLine);
    end;

    procedure UpdateReturnShptAltQtyEntries(var ReturnShptLine: Record "Return Shipment Line")
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ItemEntryRelation: Record "Item Entry Relation";
        OrderLineNo: Integer;
    begin
        // UpdateReturnShptAltQtyEntries
        with ReturnShptLine do begin
            if "Return Order Line No." <> 0 then     // PR3.61.01
                OrderLineNo := "Return Order Line No." // PR3.61.01
            else                                     // PR3.61.01
                OrderLineNo := "Line No.";             // PR3.61.01
            if ("Qty. Invoiced (Base)" <> 0) then
                if "Item Shpt. Entry No." <> 0 then
                    UpdateAltQtyEntries(
                      DATABASE::"Return Shipment Line", "Document No.", "Line No.",
                      OrderLineNo, "Item Shpt. Entry No.") // PR3.61.01
                else begin
                    ItemEntryRelation.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Ref. No.");
                    ItemEntryRelation.SetRange("Source Type", DATABASE::"Return Shipment Line");
                    ItemEntryRelation.SetRange("Source ID", "Document No.");
                    ItemEntryRelation.SetRange("Source Ref. No.", "Line No.");
                    if ItemEntryRelation.Find('-') then begin
                        repeat
                            ItemLedgEntry.Get(ItemEntryRelation."Item Entry No.");
                            if ItemLedgEntry."Invoiced Quantity" <> 0 then
                                UpdateAltQtyEntries(
                                  DATABASE::"Return Shipment Line", "Document No.", "Line No.",
                                  OrderLineNo, ItemEntryRelation."Item Entry No.") // PR3.61.01
                        until ItemEntryRelation.Next = 0;
                    end;
                end;
        end;
    end;

    procedure PurchLineToCreditMemoLine(var PurchLine: Record "Purchase Line"; var CreditMemoLine: Record "Purch. Cr. Memo Line")
    var
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // PurchLineToCreditMemoLine
        // PR3.61.01 Begin
        with CreditMemoLine do begin
            AltQtyLinesToAltQtyEntries1(
              PurchLine."Alt. Qty. Transaction No.",
              DATABASE::"Purch. Cr. Memo Line", "Document No.", "Line No.", 0, false, true); // P8000504A

            AltQtyEntry.SetRange("Table No.", DATABASE::"Purch. Cr. Memo Line");
            AltQtyEntry.SetRange("Document No.", "Document No.");
            AltQtyEntry.SetRange("Source Line No.", "Line No.");
            if AltQtyEntry.Find('-') then
                repeat
                    AltQtyEntry."Invoiced Qty. (Base)" := AltQtyEntry."Quantity (Base)";
                    AltQtyEntry."Invoiced Qty. (Alt.)" := AltQtyEntry."Quantity (Alt.)";
                    AltQtyEntry.Modify;
                until AltQtyEntry.Next = 0;
        end;
        // PR3.61.01 End
    end;

    procedure CheckPurchRelease(var PurchHeader: Record "Purchase Header")
    var
        OrigPurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
    begin
        // CheckPurchRelease
        // P8000282A
        OrigPurchHeader := PurchHeader;
        with PurchHeader do
            if (Status = Status::Released) and Invoice then begin
                PurchLine.SetRange("Document Type", "Document Type");
                PurchLine.SetRange("Document No.", "No.");
                PurchLine.SetRange("Alt. Qty. Update Required", true);
                if PurchLine.Find('-') then begin
                    Status := Status::Open;
                    CODEUNIT.Run(CODEUNIT::"Release Purchase Document", PurchHeader);
                    Ship := OrigPurchHeader.Ship;
                    Invoice := OrigPurchHeader.Invoice;
                    Receive := OrigPurchHeader.Receive;
                    Modify;
                    Commit;
                end;
            end;
    end;

    local procedure UpdatePurchTracking(var PurchLine: Record "Purchase Line")
    var
        Location: Record Location;
        AltQtyTracking: Codeunit "Alt. Qty. Tracking Management";
    begin
        // P8000282A
        with PurchLine do begin
            if ("Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"]) then begin
                GetLocation("Location Code", Location);
                if Location."Require Shipment" and Location."Require Pick" then begin
                    UpdateTrackingAltQtys(
                      "Alt. Qty. Transaction No.", DATABASE::"Purchase Line",
                      "Document Type", "Document No.", 0, "Line No.");
                    exit;
                end;
            end;
            AltQtyTracking.UpdatePurchTracking(PurchLine);
        end;
    end;

    procedure ValidateTransAltQtyLine(var TransLine: Record "Transfer Line"; Direction: Option Outbound,Inbound)
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // ValidateTransAltQtyLine
        // PR3.61 Begin
        TransLine.TestAltQtyEntry(Direction); // P8000282A
        StartTransAltQtyLine(TransLine, Direction);
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", GetTransLineTransNo(TransLine, Direction));
        case AltQtyLine.Count of
            0:
                CreateTransAltQtyLine(TransLine, Direction);
            1:
                begin
                    AltQtyLine.Find('-');
                    UpdateTransAltQtyLine(TransLine, AltQtyLine, Direction);
                end;
            else begin
                    Message(Text001);
                    ShowTransAltQtyLines(TransLine, Direction);
                end;
        end;
        // PR3.61 End
    end;

    procedure ShowTransAltQtyLines(var TransLine: Record "Transfer Line"; Direction: Option Outbound,Inbound)
    var
        AltQtyLine: Record "Alternate Quantity Line";
        ItemTrackingCode: Record "Item Tracking Code";
        AltQtyForm: Page "Alternate Quantity Lines";
        AltQtyTracking: Codeunit "Alt. Qty. Tracking Management";
        Handled: Boolean;
    begin
        // ShowTransAltQtyLines
        // PR3.61 Begin
        // P80082969
        OnBeforeShowTransAltQtyLines(TransLine, Direction, Handled);
        if Handled then
            exit;
        // P80082969

        Commit;
        TransLine.TestAltQtyEntry(Direction); // P8000282A
        StartTransAltQtyLine(TransLine, Direction);
        with TransLine do begin
            AltQtyForm.SetSource(DATABASE::"Transfer Line", Direction, "Document No.", '', '', "Line No.");
            if Direction = Direction::Outbound then begin
                AltQtyForm.SetQty("Qty. to Ship" * "Qty. per Unit of Measure", FieldCaption("Qty. to Ship")); // P8000392A
                                                                                                              //AltQtyForm.SetMaxQty("Outstanding Quantity" * "Qty. per Unit of Measure"); // P8000392A // P80075420
                AltQtyForm.SetMaxQty(("Outstanding Quantity" - TransLine.GetContainerQuantity(0, false)) * "Qty. per Unit of Measure"); // P8000392A // P80075420
            end else begin
                AltQtyForm.SetQty("Qty. to Receive (Base)" * "Qty. per Unit of Measure", FieldCaption("Qty. to Receive")); // P8000392A
                                                                                                                           //AltQtyForm.SetMaxQty("Outstanding Quantity" * "Qty. per Unit of Measure"); // P8000392A // P80075420
                AltQtyForm.SetMaxQty(("Outstanding Quantity" - TransLine.GetContainerQuantity(1, false)) * "Qty. per Unit of Measure"); // P8000392A // P80075420
            end;
            Item.Get("Item No.");
            if Item."Item Tracking Code" <> '' then begin
                ItemTrackingCode.Get(Item."Item Tracking Code");
                AltQtyForm.SetTracking(ItemTrackingCode."SN Specific Tracking", ItemTrackingCode."Lot Specific Tracking");
            end;
            AltQtyLine.FilterGroup(4);
            AltQtyLine.SetRange("Alt. Qty. Transaction No.", GetTransLineTransNo(TransLine, Direction));
            AltQtyLine.FilterGroup(0);
            AltQtyForm.SetTableView(AltQtyLine);
            if "Lot No." <> P800Globals.MultipleLotCode then // P8000043A
                AltQtyForm.SetDefaultLot("Lot No.");           // P8000043A
            AltQtyForm.RunModal;
        end;
        UpdateTransLine(TransLine, Direction);
        // AltQtyTracking.UpdateTransTracking(TransLine,Direction); // P8000282A
        UpdateTransTracking(TransLine, Direction);                  // P8000282A
        if Direction = Direction::Outbound then begin // P8000043A
            SetTransLineAltQty(TransLine);
            TransLine.GetLotNo;                         // P8000043A
        end;                                         // P8000043A
        // PR3.61 End
    end;

    procedure UpdateTransAltQtyLines(var TransLine: Record "Transfer Line"; Direction: Option Outbound,Inbound)
    begin
        // P8004516
        UpdateTransLine(TransLine, Direction);
        UpdateTransTracking(TransLine, Direction);
        if Direction = Direction::Outbound then begin
            SetTransLineAltQty(TransLine);
            TransLine.GetLotNo;
        end;
    end;

    procedure StartTransAltQtyLine(var TransLine: Record "Transfer Line"; Direction: Option Outbound,Inbound)
    var
        Assigned: Boolean;
    begin
        // StartTransAltQtyLine
        // PR3.61 Begin
        TestTransAltQtyInfo(TransLine, Direction, true);
        with TransLine do begin
            GetItem("Item No.");
            case Direction of
                Direction::Outbound:
                    Assigned := AssignNewTransactionNo("Alt. Qty. Trans. No. (Ship)");
                Direction::Inbound:
                    Assigned := AssignNewTransactionNo("Alt. Qty. Trans. No. (Receive)");
            end;
            if Assigned then begin
                Modify;
                Commit;
            end;
        end;
        // PR3.61 End
    end;

    procedure TestTransAltQtyInfo(var TransLine: Record "Transfer Line"; Direction: Option Outbound,Inbound; CatchAltQtysCheck: Boolean)
    begin
        // TestTransAltQtyInfo
        // PR3.61 Begin
        with TransLine do begin
            TestField(Type, Type::Item);
            TestField("Item No.");
            GetItem("Item No.");
            Item.TestField("Alternate Unit of Measure");
            case Direction of
                Direction::Outbound:
                    TestField("Outstanding Quantity");
                Direction::Inbound:
                    if not "Direct Transfer" then   // P80053245
                        TestField("Qty. in Transit"); // P80053245
            end;
            if CatchAltQtysCheck then
                Item.TestField("Catch Alternate Qtys.", true);
        end;
        // PR3.61 End
    end;

    local procedure CreateTransAltQtyLine(var TransLine: Record "Transfer Line"; Direction: Option Outbound,Inbound)
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // CreateTransAltQtyLine
        // PR3.61 Begin
        with TransLine do
            CreateAltQtyLine(
              AltQtyLine, GetTransLineTransNo(TransLine, Direction), 10000, DATABASE::"Transfer Line",
              Direction, "Document No.", '', '', "Line No.");

        if TransLine."Lot No." <> P800Globals.MultipleLotCode then // P8000043A
            AltQtyLine."Lot No." := TransLine."Lot No.";             // P8000043A
        UpdateTransAltQtyLine(TransLine, AltQtyLine, Direction);
        // PR3.61 End
    end;

    procedure CreateTransContainerAltQtyLine(var TransLine: Record "Transfer Line"; Direction: Integer; LotNo: Code[50]; SerialNo: Code[50]; Qty: Decimal; QtyAlt: Decimal; ContainerID: Code[20]; ContainerLineNo: Integer)
    var
        AltQtyLine: Record "Alternate Quantity Line";
        AltQtyLine2: Record "Alternate Quantity Line";
        AltQtyTransNo: Integer;
    begin
        // CreateTransContainerAltQtyLine
        // P8001324, replace ContainerTransNo with ContainerID, ContainerLineNo
        // P80046533 - add parameter Direction
        // PR3.61 Begin
        StartTransAltQtyLine(TransLine, Direction); // P80046533
        // P80046533
        if Direction = 0 then
            AltQtyTransNo := TransLine."Alt. Qty. Trans. No. (Ship)"
        else
            AltQtyTransNo := TransLine."Alt. Qty. Trans. No. (Receive)";
        //AltQtyLine2.SETRANGE("Alt. Qty. Transaction No.",TransLine."Alt. Qty. Trans. No. (Ship)");
        AltQtyLine2.SetRange("Alt. Qty. Transaction No.", AltQtyTransNo);
        // P80046533
        if AltQtyLine2.Find('+') then;
        CreateAltQtyLine(
          AltQtyLine, AltQtyTransNo, AltQtyLine2."Line No." + 10000, DATABASE::"Transfer Line", Direction, TransLine."Document No.", '', '', TransLine."Line No."); // P80046533

        AltQtyLine."Lot No." := LotNo;
        AltQtyLine."Serial No." := SerialNo;
        AltQtyLine.Validate(Quantity, Qty);
        AltQtyLine.Validate("Quantity (Alt.)", QtyAlt);
        AltQtyLine."Container ID" := ContainerID;           // P8001324
        AltQtyLine."Container Line No." := ContainerLineNo; // P8001324
        AltQtyLine.Modify;
        // PR3.61 End
    end;

    local procedure UpdateTransAltQtyLine(var TransLine: Record "Transfer Line"; var AltQtyLine: Record "Alternate Quantity Line"; Direction: Option Outbound,Inbound)
    var
        AltQtyTracking: Codeunit "Alt. Qty. Tracking Management";
    begin
        // UpdateTransAltQtyLine
        // PR3.61 Begin
        with TransLine do begin
            AltQtyLine.Validate("Quantity (Alt.)",
              GetTransLineQty(TransLine, Direction, FieldNo("Qty. to Ship (Alt.)")));
            AltQtyLine.Validate("Quantity (Base)",
              GetTransLineQty(TransLine, Direction, FieldNo("Qty. to Ship")) * "Qty. per Unit of Measure"); // A&L
            AltQtyLine.Modify(true);
        end;
        // AltQtyTracking.UpdateTransTracking(TransLine,Direction); // P8000282A
        UpdateTransTracking(TransLine, Direction);                  // P8000282A
        SetTransLineAltQty(TransLine);
        // PR3.61 End
    end;

    procedure UpdateTransLine(var TransLine: Record "Transfer Line"; Direction: Option Outbound,Inbound)
    begin
        // UpdateTransLine
        // PR3.61 Begin
        with TransLine do begin
            GetItem("Item No.");
            if Item."Catch Alternate Qtys." then
                ValidateTransQtyToPost(
                  TransLine, Direction, true, CalcAltQtyLinesQtyAlt1(GetTransLineTransNo(TransLine, Direction)) - GetContainerQuantityAlt(1, false)); // P80046533
            if AltQtyLinesExist(GetTransLineTransNo(TransLine, Direction)) then begin
                if ("Qty. per Unit of Measure" = 0) then
                    "Qty. per Unit of Measure" := 1;
                ValidateTransQtyToPost(
                  TransLine, Direction, false,
                  Round(CalcAltQtyLinesQtyBase1(GetTransLineTransNo(TransLine, Direction)) / "Qty. per Unit of Measure", 0.00001) - GetContainerQuantity(1, false)); // P8000392A, P80046533
            end;
            Modify;
        end;
        // PR3.61 End
    end;

    local procedure ValidateTransQtyToPost(var TransLine: Record "Transfer Line"; Direction: Option Outbound,Inbound; SetAltQty: Boolean; NewQty: Decimal)
    var
        SetReceivingQty: Boolean;
    begin
        // ValidateTransQtyToPost
        // PR3.61 Begin
        with TransLine do begin
            SetReceivingQty := Direction = Direction::Inbound;
            case true of
                SetReceivingQty and SetAltQty:
                    Validate("Qty. to Receive (Alt.)", NewQty);
                SetReceivingQty:
                    Validate("Qty. to Receive", NewQty);
                SetAltQty:
                    Validate("Qty. to Ship (Alt.)", NewQty);
                else
                    Validate("Qty. to Ship", NewQty);
            end;
        end;
        // PR3.61 End
    end;

    procedure SetTransLineAltQty(var TransLine: Record "Transfer Line")
    begin
        // SetTransLineAltQty
        // PR3.61 Begin
        with TransLine do
            if (Type <> Type::Item) or ("Item No." = '') then
                "Quantity (Alt.)" := 0
            else begin
                GetItem("Item No.");
                if not Item.TrackAlternateUnits() then
                    "Quantity (Alt.)" := 0
                else
                    if not Item."Catch Alternate Qtys." then                    // P8000550A
                                                                                // P8007584
                                                                                //"Quantity (Alt.)" := CalcAltQty("Item No.", "Quantity (Base)") // P8000550A
                        "Quantity (Alt.)" := CalcAltQty("Item No.", Quantity * "Qty. per Unit of Measure")
                    // P8007584
                    else begin
                        if "Qty. to Ship (Base)" = Round(CalcAltQtyLinesQtyBase1("Alt. Qty. Trans. No. (Ship)"), 0.00001) then // P8000392A
                            "Quantity (Alt.)" := "Qty. Shipped (Alt.)" + "Qty. to Ship (Alt.)" +
                              // P8007584
                              //CalcAltQty("Item No.","Outstanding Qty. (Base)" - "Qty. to Ship (Base)")
                              CalcAltQty("Item No.", ("Outstanding Quantity" - "Qty. to Ship") * "Qty. per Unit of Measure")
                        // P8007584
                        else
                            // P8007584
                            //"Quantity (Alt.)" := "Qty. Shipped (Alt.)" + CalcAltQty("Item No.", "Outstanding Qty. (Base)");
                            "Quantity (Alt.)" := "Qty. Shipped (Alt.)" + CalcAltQty("Item No.", "Outstanding Quantity" * "Qty. per Unit of Measure");
                        // P8007584
                    end;
            end;

        SetTransLineWeights(TransLine);
        // PR3.61 End
    end;

    local procedure SetTransLineWeights(var TransLine: Record "Transfer Line")
    begin
        // SetTransLineWeights
        // PR3.61 Begin
        with TransLine do
            if (Type = Type::Item) and ("Item No." <> '') then begin
                GetItem("Item No.");
                CalcLineWeights(
                  "Alt. Qty. Trans. No. (Ship)", "Qty. per Unit of Measure",
                  "Qty. to Ship", "Qty. to Ship (Base)", "Qty. to Ship (Alt.)",
                  "Net Weight", "Net Weight to Ship");
            end;
        // PR3.61 End
    end;

    procedure GetTransLineTransNo(TransLine: Record "Transfer Line"; Direction: Option Outbound,Inbound): Integer
    begin
        // GetTransLineTransNo
        // PR3.61 Begin
        case Direction of
            Direction::Outbound:
                exit(TransLine."Alt. Qty. Trans. No. (Ship)");
            Direction::Inbound:
                exit(TransLine."Alt. Qty. Trans. No. (Receive)");
        end;
        // PR3.61 End
    end;

    procedure GetTransLineQty(TransLine: Record "Transfer Line"; Direction: Option Outbound,Inbound; FldNo: Integer): Decimal
    begin
        // GetTransLineQty
        // PR3.61 Begin
        with TransLine do
            case Direction of
                Direction::Outbound:
                    case FldNo of
                        FieldNo("Qty. to Ship"):
                            exit("Qty. to Ship");
                        FieldNo("Qty. to Ship (Base)"):
                            exit("Qty. to Ship (Base)");
                        FieldNo("Qty. to Ship (Alt.)"):
                            exit("Qty. to Ship (Alt.)");
                        FieldNo("Quantity Shipped"):
                            exit("Quantity Shipped");
                        FieldNo("Qty. Shipped (Base)"):
                            exit("Qty. Shipped (Base)");
                        FieldNo("Qty. Shipped (Alt.)"):
                            exit("Qty. Shipped (Alt.)");
                    end;
                Direction::Inbound:
                    case FldNo of
                        FieldNo("Qty. to Ship"):
                            exit("Qty. to Receive");
                        FieldNo("Qty. to Ship (Base)"):
                            exit("Qty. to Receive (Base)");
                        FieldNo("Qty. to Ship (Alt.)"):
                            exit("Qty. to Receive (Alt.)");
                        FieldNo("Quantity Shipped"):
                            exit("Quantity Received");
                        FieldNo("Qty. Shipped (Base)"):
                            exit("Qty. Received (Base)");
                        FieldNo("Qty. Shipped (Alt.)"):
                            exit("Qty. Received (Alt.)");
                    end;
            end;
        // PR3.61 End
    end;

    procedure TransLineToShipmentLine(var TransLine: Record "Transfer Line"; var TransShptLine: Record "Transfer Shipment Line")
    var
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // TransLineToShipmentLine
        // PR3.61 Begin
        with TransShptLine do begin // PR3.61.01
            AltQtyLinesToAltQtyEntries1(
              TransLine."Alt. Qty. Trans. No. (Ship)",
              DATABASE::"Transfer Shipment Line", "Document No.", "Line No.", 0, false, false); // P8000504A

            // PR3.61.01 Begin
            AltQtyEntry.SetRange("Table No.", DATABASE::"Transfer Shipment Line");
            AltQtyEntry.SetRange("Document No.", "Document No.");
            AltQtyEntry.SetRange("Source Line No.", "Line No.");
            if AltQtyEntry.Find('-') then
                repeat
                    AltQtyEntry."Invoiced Qty. (Base)" := AltQtyEntry."Quantity (Base)";
                    AltQtyEntry."Invoiced Qty. (Alt.)" := AltQtyEntry."Quantity (Alt.)";
                    AltQtyEntry.Modify;
                until AltQtyEntry.Next = 0;
        end;
        // PR3.61.01 End
        // PR3.61 End
    end;

    procedure TransLineToReceiptLine(var TransLine: Record "Transfer Line"; var TransRcptLine: Record "Transfer Receipt Line")
    var
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // TransLineToReceiptLine
        // PR3.61 Begin
        with TransRcptLine do begin // PR3.61.01
            AltQtyLinesToAltQtyEntries1(
              TransLine."Alt. Qty. Trans. No. (Receive)",
              DATABASE::"Transfer Receipt Line", "Document No.", "Line No.", 0, false, false); // P8000504A

            // PR3.61.01 Begin
            AltQtyEntry.SetRange("Table No.", DATABASE::"Transfer Receipt Line");
            AltQtyEntry.SetRange("Document No.", "Document No.");
            AltQtyEntry.SetRange("Source Line No.", "Line No.");
            if AltQtyEntry.Find('-') then
                repeat
                    AltQtyEntry."Invoiced Qty. (Base)" := AltQtyEntry."Quantity (Base)";
                    AltQtyEntry."Invoiced Qty. (Alt.)" := AltQtyEntry."Quantity (Alt.)";
                    AltQtyEntry.Modify;
                until AltQtyEntry.Next = 0;
        end;
        // PR3.61 End
    end;

    procedure UpdateTransLineShipToRcv(var TransLine: Record "Transfer Line")
    var
        AltQtyLine: Record "Alternate Quantity Line";
        AltQtyLine2: Record "Alternate Quantity Line";
        LineNo: Integer;
    begin
        // UpdateTransLineShipToRcv
        // PR3.61 Begin
        with TransLine do begin
            if "Alt. Qty. Trans. No. (Ship)" = 0 then
                exit;

            AssignNewTransactionNo("Alt. Qty. Trans. No. (Receive)");
            AltQtyLine.SetRange("Alt. Qty. Transaction No.", "Alt. Qty. Trans. No. (Ship)");
            AltQtyLine.SetRange("Container ID", ''); // P80046533
            if AltQtyLine.Find('-') then begin
                AltQtyLine2.SetRange("Alt. Qty. Transaction No.", "Alt. Qty. Trans. No. (Receive)");
                if AltQtyLine2.Find('+') then
                    LineNo := AltQtyLine2."Line No."
                else
                    LineNo := 0;
                repeat
                    LineNo += 10000;
                    AltQtyLine2 := AltQtyLine;
                    AltQtyLine2."Alt. Qty. Transaction No." := "Alt. Qty. Trans. No. (Receive)";
                    AltQtyLine2."Line No." := LineNo;
                    AltQtyLine2."Document Type" := 1;
                    AltQtyLine2.Insert;
                until AltQtyLine.Next = 0;
                // P80046533
            end;
            AltQtyLine.SetRange("Container ID"); // P80046533
            AltQtyLine.DeleteAll;
            // P80046533

            //"Alt. Qty. Trans. No. (Ship)" := 0; // PR3.61.01
            UpdateTransLine(TransLine, 1);
        end;
        // PR3.61 End
    end;

    procedure UpdateTransTracking(var TransLine: Record "Transfer Line"; Direction: Option Outbound,Inbound)
    var
        Location: Record Location;
        AltQtyTracking: Codeunit "Alt. Qty. Tracking Management";
    begin
        // P8000282A
        with TransLine do
            case Direction of
                Direction::Outbound:
                    begin
                        GetLocation("Transfer-from Code", Location);
                        if Location."Require Shipment" and Location."Require Pick" then
                            UpdateTrackingAltQtys(
                              "Alt. Qty. Trans. No. (Ship)", DATABASE::"Transfer Line",
                              Direction::Outbound, "Document No.", 0, "Line No.")
                        else
                            AltQtyTracking.UpdateTransTracking(TransLine, Direction::Outbound);
                    end;
                Direction::Inbound:
                    UpdateTrackingAltQtys(
                      "Alt. Qty. Trans. No. (Receive)", DATABASE::"Transfer Line",
                      Direction::Inbound, "Document No.", "Line No.", 0);
            end;
    end;

    local procedure UpdateTrackingAltQtys(AltQtyTransNo: Integer; SourceType: Integer; SourceSubtype: Integer; SourceNo: Code[20]; SourceProdOrderLineNo: Integer; SourceLineNo: Integer)
    var
        AltQtyLinesFound: Boolean;
        ReservEntry: Record "Reservation Entry";
        RemQtyBase: Decimal;
        RemQtyAlt: Decimal;
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        ReservEntry2: Record "Reservation Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        // P8000282A
        AltQtyLinesFound := AltQtyLinesExist(AltQtyTransNo);
        with ReservEntry do begin
            SetCurrentKey(
              "Source Type", "Source Subtype", "Source ID", "Source Batch Name",
              "Source Prod. Order Line", "Source Ref. No.");
            SetRange("Source Type", SourceType);
            SetRange("Source Subtype", SourceSubtype);
            SetRange("Source ID", SourceNo);
            SetRange("Source Prod. Order Line", SourceProdOrderLineNo);
            if (SourceLineNo <> 0) then
                SetRange("Source Ref. No.", SourceLineNo);
            if Find('-') then
                repeat
                    if not Mark then begin
                        if not AltQtyLinesFound then begin
                            RemQtyBase := ReservEntry."Quantity (Base)";
                            RemQtyAlt := 0;
                        end else begin
                            RemQtyBase := CalcAltQtyLinesQtyBase2(AltQtyTransNo, "Serial No.", "Lot No.");
                            RemQtyAlt := CalcAltQtyLinesQtyAlt2(AltQtyTransNo, "Serial No.", "Lot No.");
                            if (CreateReservEntry.SignFactor(ReservEntry) < 0) then begin
                                RemQtyBase := -RemQtyBase;
                                RemQtyAlt := -RemQtyAlt;
                            end;
                        end;
                        SetRange("Lot No.", "Lot No.");
                        SetRange("Serial No.", "Serial No.");
                        repeat
                            if (Abs("Quantity (Base)") < Abs(RemQtyBase)) then
                                "Qty. to Handle (Base)" := "Quantity (Base)"
                            else
                                "Qty. to Handle (Base)" := RemQtyBase;
                            if (RemQtyBase = 0) then
                                "Qty. to Handle (Alt.)" := RemQtyAlt
                            else begin
                                "Qty. to Handle (Alt.)" :=
                                  Round(RemQtyAlt * ("Qty. to Handle (Base)" / RemQtyBase), 0.00001);
                            end;
                            "Qty. to Invoice (Base)" := "Qty. to Handle (Base)";
                            "Qty. to Invoice (Alt.)" := "Qty. to Handle (Alt.)";
                            "Quantity (Alt.)" := "Qty. to Handle (Alt.)";  // P80059706
                            Modify;
                            RemQtyBase := RemQtyBase - "Qty. to Handle (Base)";
                            RemQtyAlt := RemQtyAlt - "Qty. to Handle (Alt.)";
                            Mark(true);
                        until (Next = 0);
                        Find('-');
                        SetRange("Lot No.");
                        SetRange("Serial No.");
                    end;
                until (Next = 0);
        end;
    end;

    procedure TestRepackOrderAltQtyInfo(var RepackOrder: Record "Repack Order"; CatchAltQtysCheck: Boolean)
    begin
        // P8000504A
        RepackOrder.TestField("Item No.");
        GetItem(RepackOrder."Item No.");
        Item.TestField("Alternate Unit of Measure");
        RepackOrder.TestField("Quantity to Produce");
        if CatchAltQtysCheck then
            Item.TestField("Catch Alternate Qtys.", true);
    end;

    procedure ValidateRepackOrderAltQtyLine(var RepackOrder: Record "Repack Order")
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // P8000504A
        StartRepackOrderAltQtyLine(RepackOrder);
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", RepackOrder."Alt. Qty. Transaction No.");
        case AltQtyLine.Count of
            0:
                CreateRepackOrderAltQtyLine(RepackOrder);
            1:
                begin
                    AltQtyLine.Find('-');
                    UpdateRepackOrderAltQtyLine(RepackOrder, AltQtyLine);
                end;
            else begin
                    Message(Text001);
                    ShowRepackOrderAltQtyLines(RepackOrder);
                end;
        end;
    end;

    procedure ShowRepackOrderAltQtyLines(var RepackOrder: Record "Repack Order")
    var
        AltQtyLine: Record "Alternate Quantity Line";
        AltQtyForm: Page "Alternate Quantity Lines";
    begin
        // P8000504A
        Commit;
        StartRepackOrderAltQtyLine(RepackOrder);
        with RepackOrder do begin
            AltQtyForm.SetSource(DATABASE::"Repack Order", 0, "No.", '', '', 0);
            AltQtyForm.SetQty("Quantity to Produce" * "Qty. per Unit of Measure", FieldCaption("Quantity to Produce"));
            AltQtyForm.SetMaxQty(Quantity * "Qty. per Unit of Measure");
            AltQtyForm.SetDefaultLot("Lot No.");
            AltQtyLine.FilterGroup(4);
            AltQtyLine.SetRange("Alt. Qty. Transaction No.", "Alt. Qty. Transaction No.");
            AltQtyLine.FilterGroup(0);
            AltQtyForm.SetTableView(AltQtyLine);
            AltQtyForm.RunModal;
        end;
        RepackOrder.Validate("Quantity to Produce (Alt.)", CalcAltQtyLinesQtyAlt1(RepackOrder."Alt. Qty. Transaction No."));
    end;

    local procedure StartRepackOrderAltQtyLine(var RepackOrder: Record "Repack Order")
    begin
        // P8000504A
        TestRepackOrderAltQtyInfo(RepackOrder, true);
        GetItem(RepackOrder."Item No.");
        if AssignNewTransactionNo(RepackOrder."Alt. Qty. Transaction No.") then begin
            RepackOrder.Modify;
            Commit;
        end;
    end;

    local procedure CreateRepackOrderAltQtyLine(var RepackOrder: Record "Repack Order")
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // P8000504A
        GetItem(RepackOrder."Item No.");
        if not Item."Catch Alternate Qtys." then
            exit;
        CreateAltQtyLine(
          AltQtyLine, RepackOrder."Alt. Qty. Transaction No.", 10000, DATABASE::"Repack Order", 0, RepackOrder."No.", '', '', 0);

        UpdateRepackOrderAltQtyLine(RepackOrder, AltQtyLine);
    end;

    local procedure UpdateRepackOrderAltQtyLine(var RepackOrder: Record "Repack Order"; var AltQtyLine: Record "Alternate Quantity Line")
    begin
        // P8000504A
        with RepackOrder do begin
            AltQtyLine."Lot No." := "Lot No.";
            AltQtyLine.Validate("Quantity (Alt.)", "Quantity to Produce (Alt.)");
            AltQtyLine.Validate("Quantity (Base)", "Quantity to Produce" * "Qty. per Unit of Measure");
            AltQtyLine.Modify(true);
        end;
    end;

    procedure RepackOrderAltQtyLineToEntry(var RepackOrder: Record "Repack Order")
    begin
        // P8000504A
        AltQtyLinesToAltQtyEntries1(RepackOrder."Alt. Qty. Transaction No.",
          DATABASE::"Repack Order", RepackOrder."No.", 0, 0, false, true);
    end;

    procedure ShowRepackOrderAltQtyEntries(RepackOrder: Record "Repack Order")
    var
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // P8000504A
        AltQtyEntry.SetRange("Table No.", DATABASE::"Repack Order");
        AltQtyEntry.SetRange("Document No.", RepackOrder."No.");
        AltQtyEntry.SetRange("Source Line No.", 0);
        PAGE.RunModal(0, AltQtyEntry, AltQtyEntry."Quantity (Alt.)");
    end;

    procedure TestRepackLineAltQtyInfo(var RepackLine: Record "Repack Order Line"; CatchAltQtysCheck: Boolean; FldNo: Integer)
    begin
        // P8000504A
        RepackLine.TestField(Type, RepackLine.Type::Item);
        RepackLine.TestField("No.");
        GetItem(RepackLine."No.");
        Item.TestField("Alternate Unit of Measure");
        case FldNo of
            RepackLine.FieldNo("Quantity to Transfer"):
                RepackLine.TestField("Quantity to Transfer");
            RepackLine.FieldNo("Quantity to Consume"):
                RepackLine.TestField("Quantity to Consume");
        end;
        if CatchAltQtysCheck then
            Item.TestField("Catch Alternate Qtys.", true);
    end;

    procedure ValidateRepackLineAltQtyLine(var RepackLine: Record "Repack Order Line"; FldNo: Integer)
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // P8000504A
        StartRepackLineAltQtyLine(RepackLine, FldNo);
        case FldNo of
            RepackLine.FieldNo("Quantity to Transfer"):
                AltQtyLine.SetRange("Alt. Qty. Transaction No.", RepackLine."Alt. Qty. Trans. No. (Trans)");
            RepackLine.FieldNo("Quantity to Consume"):
                AltQtyLine.SetRange("Alt. Qty. Transaction No.", RepackLine."Alt. Qty. Trans. No. (Consume)");
        end;
        case AltQtyLine.Count of
            0:
                CreateRepackLineAltQtyLine(RepackLine, FldNo);
            1:
                begin
                    AltQtyLine.Find('-');
                    UpdateRepackLineAltQtyLine(RepackLine, AltQtyLine, FldNo);
                end;
            else begin
                    Message(Text001);
                    ShowRepackLineAltQtyLines(RepackLine, FldNo);
                end;
        end;
    end;

    procedure ShowRepackLineAltQtyLines(var RepackLine: Record "Repack Order Line"; FldNo: Integer)
    var
        AltQtyLine: Record "Alternate Quantity Line";
        AltQtyForm: Page "Alternate Quantity Lines";
        TransNo: Integer;
    begin
        // P8000504A
        Commit;
        StartRepackLineAltQtyLine(RepackLine, FldNo);
        with RepackLine do begin
            AltQtyForm.SetSource(DATABASE::"Repack Order Line", 0, "Order No.", '', '', "Line No.");
            case FldNo of
                FieldNo("Quantity to Transfer"):
                    begin
                        AltQtyForm.SetQty("Quantity to Transfer" * "Qty. per Unit of Measure", FieldCaption("Quantity to Transfer"));
                        AltQtyForm.SetMaxQty(Quantity * "Qty. per Unit of Measure");
                        TransNo := RepackLine."Alt. Qty. Trans. No. (Trans)";
                    end;
                FieldNo("Quantity to Consume"):
                    begin
                        AltQtyForm.SetQty("Quantity to Consume" * "Qty. per Unit of Measure", FieldCaption("Quantity to Consume"));
                        TransNo := RepackLine."Alt. Qty. Trans. No. (Consume)";
                    end;
            end;
            AltQtyForm.SetMaxQty(Quantity * "Qty. per Unit of Measure");
            AltQtyForm.SetDefaultLot("Lot No.");
            AltQtyLine.FilterGroup(4);
            AltQtyLine.SetRange("Alt. Qty. Transaction No.", TransNo);
            AltQtyLine.FilterGroup(0);
            AltQtyForm.SetTableView(AltQtyLine);
            AltQtyForm.RunModal;
        end;
        case FldNo of
            RepackLine.FieldNo("Quantity to Transfer"):
                RepackLine.Validate("Quantity to Transfer (Alt.)", CalcAltQtyLinesQtyAlt1(TransNo));
            RepackLine.FieldNo("Quantity to Consume"):
                RepackLine.Validate("Quantity to Consume (Alt.)", CalcAltQtyLinesQtyAlt1(TransNo));
        end;
    end;

    local procedure StartRepackLineAltQtyLine(var RepackLine: Record "Repack Order Line"; FldNo: Integer)
    begin
        // P8000504A
        TestRepackLineAltQtyInfo(RepackLine, true, FldNo);
        GetItem(RepackLine."No.");
        case FldNo of
            RepackLine.FieldNo("Quantity to Transfer"):
                if AssignNewTransactionNo(RepackLine."Alt. Qty. Trans. No. (Trans)") then begin
                    RepackLine.Modify;
                    Commit;
                end;
            RepackLine.FieldNo("Quantity to Consume"):
                if AssignNewTransactionNo(RepackLine."Alt. Qty. Trans. No. (Consume)") then begin
                    RepackLine.Modify;
                    Commit;
                end;
        end;
    end;

    local procedure CreateRepackLineAltQtyLine(var RepackLine: Record "Repack Order Line"; FldNo: Integer)
    var
        AltQtyLine: Record "Alternate Quantity Line";
        TransNo: Integer;
    begin
        // P8000504A
        GetItem(RepackLine."No.");
        if not Item."Catch Alternate Qtys." then
            exit;
        case FldNo of
            RepackLine.FieldNo("Quantity to Transfer"):
                TransNo := RepackLine."Alt. Qty. Trans. No. (Trans)";
            RepackLine.FieldNo("Quantity to Consume"):
                TransNo := RepackLine."Alt. Qty. Trans. No. (Consume)";
        end;
        CreateAltQtyLine(
          AltQtyLine, TransNo, 10000, DATABASE::"Repack Order Line", 0, RepackLine."Order No.", '', '', RepackLine."Line No.");

        UpdateRepackLineAltQtyLine(RepackLine, AltQtyLine, FldNo);
    end;

    local procedure UpdateRepackLineAltQtyLine(var RepackLine: Record "Repack Order Line"; var AltQtyLine: Record "Alternate Quantity Line"; FldNo: Integer)
    begin
        // P8000504A
        with RepackLine do begin
            AltQtyLine."Lot No." := "Lot No.";
            case FldNo of
                FieldNo("Quantity to Transfer"):
                    begin
                        AltQtyLine.Validate("Quantity (Alt.)", "Quantity to Transfer (Alt.)");
                        AltQtyLine.Validate("Quantity (Base)", "Quantity to Transfer" * "Qty. per Unit of Measure");
                    end;
                FieldNo("Quantity to Consume"):
                    begin
                        AltQtyLine.Validate("Quantity (Alt.)", "Quantity to Consume (Alt.)");
                        AltQtyLine.Validate("Quantity (Base)", "Quantity to Consume" * "Qty. per Unit of Measure");
                    end;
            end;
            AltQtyLine.Modify(true);
        end;
    end;

    procedure RepackLineAltQtyLineToEntry(var RepackLine: Record "Repack Order Line"; FldNo: Integer)
    begin
        // P8000500A
        case FldNo of
            RepackLine.FieldNo("Quantity Transferred (Alt.)"):
                AltQtyLinesToAltQtyEntries1(RepackLine."Alt. Qty. Trans. No. (Trans)",
                  DATABASE::"Repack Order Line", RepackLine."Order No.", RepackLine."Line No.", FldNo, false, true);
            RepackLine.FieldNo("Quantity Consumed (Alt.)"):
                AltQtyLinesToAltQtyEntries1(RepackLine."Alt. Qty. Trans. No. (Consume)",
                  DATABASE::"Repack Order Line", RepackLine."Order No.", RepackLine."Line No.", FldNo, false, true);
        end;
    end;

    procedure RepackLineAltQtyTransToConsum(var RepackLine: Record "Repack Order Line")
    var
        AltQtyLine: Record "Alternate Quantity Line";
        AltQtyLine2: Record "Alternate Quantity Line";
        LineNo: Integer;
    begin
        // P8000504A
        if (RepackLine."Alt. Qty. Trans. No. (Trans)" = 0) or (RepackLine."Alt. Qty. Trans. No. (Consume)" = 0) then
            exit;

        AltQtyLine.SetRange("Alt. Qty. Transaction No.", RepackLine."Alt. Qty. Trans. No. (Consume)");
        if AltQtyLine.FindLast then
            LineNo := AltQtyLine."Line No."
        else
            LineNo := 0;

        AltQtyLine.SetRange("Alt. Qty. Transaction No.", RepackLine."Alt. Qty. Trans. No. (Trans)");
        if AltQtyLine.FindSet then
            repeat
                LineNo += 10000;
                AltQtyLine2 := AltQtyLine;
                AltQtyLine2."Alt. Qty. Transaction No." := RepackLine."Alt. Qty. Trans. No. (Consume)";
                AltQtyLine2."Line No." := LineNo;
                AltQtyLine2.Insert;
            until AltQtyLine.Next = 0;

        RepackLine.Validate("Quantity to Consume (Alt.)", CalcAltQtyLinesQtyAlt1(RepackLine."Alt. Qty. Trans. No. (Consume)"));
    end;

    procedure ShowRepackLineAltQtyEntries(RepackLine: Record "Repack Order Line"; FldNo: Integer)
    var
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // P8000504A
        AltQtyEntry.SetRange("Table No.", DATABASE::"Repack Order Line");
        AltQtyEntry.SetRange("Document No.", RepackLine."Order No.");
        AltQtyEntry.SetRange("Source Line No.", RepackLine."Line No.");
        AltQtyEntry.SetRange("Field No.", FldNo);
        PAGE.RunModal(0, AltQtyEntry, AltQtyEntry."Quantity (Alt.)");
    end;

    procedure TestWhseDataEntry(LocationCode: Code[20]; Direction: Option Outbound,Inbound)
    var
        Location: Record Location;
    begin
        // P8000282A
        GetLocation(LocationCode, Location);
        with Location do
            case Direction of
                Direction::Inbound:
                    if (not "Require Receive") and "Require Put-away" then
                        Error(Text010);
                Direction::Outbound:
                    if (not "Require Shipment") and "Require Pick" then
                        Error(Text011);
            end;
    end;

    procedure ValidateWhseActAltQtyLine(var WhseActLine: Record "Warehouse Activity Line")
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // P8000282A
        StartWhseActAltQtyLine(WhseActLine);
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", WhseActLine."Alt. Qty. Transaction No.");
        case AltQtyLine.Count of
            0:
                CreateWhseActAltQtyLine(WhseActLine);
            1:
                begin
                    AltQtyLine.Find('-');
                    UpdateWhseActAltQtyLine(WhseActLine, AltQtyLine);
                end;
            else begin
                    Message(Text001);
                    ShowWhseActAltQtyLines(WhseActLine);
                end;
        end;
    end;

    procedure ShowWhseActAltQtyLines(var WhseActLine: Record "Warehouse Activity Line")
    var
        AltQtyLine: Record "Alternate Quantity Line";
        ItemTrackingCode: Record "Item Tracking Code";
        OrderShippingReceiving: Codeunit "Order Shipping-Receiving";
        AltQtyForm: Page "Alternate Quantity Lines";
        Handled: Boolean;
    begin
        // P8000282A
        // P80082969
        OnBeforeShowWhseAltQtyLines(WhseActLine, Handled);
        if Handled then
            exit;
        // P80082969

        Commit;
        StartWhseActAltQtyLine(WhseActLine);
        with WhseActLine do begin
            AltQtyForm.SetSource(
              "Source Type", "Source Subtype", "Source No.", '', '', "Source Line No.");
            AltQtyForm.SetQty("Qty. to Handle" * "Qty. per Unit of Measure", FieldCaption("Qty. to Handle (Base)")); // P8000392A
            AltQtyForm.SetMaxQty("Qty. Outstanding (Base)" * "Qty. per Unit of Measure"); // P8000392A
            Item.Get("Item No.");
            if (Item."Item Tracking Code" <> '') then begin
                ItemTrackingCode.Get(Item."Item Tracking Code");
                if ItemTrackingCode."SN Specific Tracking" then
                    TestField("Serial No.");
                if ItemTrackingCode."Lot Specific Tracking" then
                    TestField("Lot No.");
                AltQtyForm.SetTracking(
                  ItemTrackingCode."SN Specific Tracking", ItemTrackingCode."Lot Specific Tracking");
            end;
            AltQtyLine.FilterGroup(4);
            AltQtyLine.SetRange("Alt. Qty. Transaction No.", "Alt. Qty. Transaction No.");
            AltQtyLine.FilterGroup(0);
            AltQtyForm.SetTableView(AltQtyLine);
            AltQtyForm.SetLotAndSerial("Lot No.", "Serial No.");
            BindSubscription(OrderShippingReceiving); // P80071648
            AltQtyForm.RunModal;
            UnbindSubscription(OrderShippingReceiving); // P80071648
        end;
        UpdateWhseActLine(WhseActLine);
    end;

    local procedure StartWhseActAltQtyLine(var WhseActLine: Record "Warehouse Activity Line")
    begin
        // P8000282A
        TestWhseActAltQtyInfo(WhseActLine, true);
        with WhseActLine do begin
            GetItem("Item No.");
            if AssignNewTransactionNo("Alt. Qty. Transaction No.") then begin
                Modify;
                Commit;
            end;
        end;
    end;

    procedure TestWhseActAltQtyInfo(var WhseActLine: Record "Warehouse Activity Line"; CatchAltQtysCheck: Boolean)
    begin
        // P8000282A
        with WhseActLine do begin
            TestField("Item No.");
            GetItem("Item No.");
            Item.TestField("Alternate Unit of Measure");
            if CatchAltQtysCheck then
                Item.TestField("Catch Alternate Qtys.", true);
            // P8000322A Begin
            if ("Activity Type" <> "Activity Type"::"Invt. Put-away") and ("Activity Type" <> "Activity Type"::"Invt. Pick") and // P8000662, P8004516
              ("Activity Type" <> "Activity Type"::Movement) // P8004516
            then // P8000662                                 // P8004516
                if ("Whse. Document Type" <> "Whse. Document Type"::Shipment) and
                   ("Whse. Document Type" <> "Whse. Document Type"::Production) and // P80068361
                   (("Whse. Document Type" <> "Whse. Document Type"::Receipt) or ("Container ID" = '')) // P80068361
                then
                    FieldError("Whse. Document Type");
            // P8000322A End
        end;
    end;

    local procedure CreateWhseActAltQtyLine(var WhseActLine: Record "Warehouse Activity Line")
    var
        AltQtyLine: Record "Alternate Quantity Line";
        AltQtyLine2: Record "Alternate Quantity Line";
    begin
        // P8000282A
        with WhseActLine do begin
            // P8008508
            //IF WhseActLine."Source Type" = 0 THEN // P80066030
            CreateAltQtyLine(
              AltQtyLine, "Alt. Qty. Transaction No.", 10000, DATABASE::"Warehouse Activity Line", WhseActLine."Activity Type", WhseActLine."No.", '', '', WhseActLine."Line No."); // P80066030
                                                                                                                                                                                    //ELSE // P80066030
                                                                                                                                                                                    // P8008508
                                                                                                                                                                                    //  CreateAltQtyLine(AltQtyLine,"Alt. Qty. Transaction No.",10000,"Source Type","Source Subtype","Source No.",'','',"Source Line No."); // P80066030
            AltQtyLine."Serial No." := "Serial No.";
            AltQtyLine."Lot No." := "Lot No.";
            AltQtyLine.Modify;
        end;
        UpdateWhseActAltQtyLine(WhseActLine, AltQtyLine);
    end;

    local procedure UpdateWhseActAltQtyLine(var WhseActLine: Record "Warehouse Activity Line"; var AltQtyLine: Record "Alternate Quantity Line")
    begin
        // P8000282A
        with WhseActLine do begin
            AltQtyLine.Validate("Quantity (Alt.)", "Qty. to Handle (Alt.)");
            AltQtyLine.Validate("Quantity (Base)", "Qty. to Handle" * "Qty. per Unit of Measure"); // P8000392A
            AltQtyLine.ValidateQuantity;
            AltQtyLine.Modify(true);
        end;
        SetWhseActLineAltQty(WhseActLine);
    end;

    local procedure UpdateWhseActLine(var WhseActLine: Record "Warehouse Activity Line")
    var
        QtyToHandleBase: Decimal;
    begin
        // P8000282A
        with WhseActLine do begin
            Validate("Qty. to Handle (Alt.)", CalcAltQtyLinesQtyAlt1("Alt. Qty. Transaction No."));
            if AltQtyLinesExist("Alt. Qty. Transaction No.") then begin  //TODO
                QtyToHandleBase := CalcAltQtyLinesQtyBase1("Alt. Qty. Transaction No.");
                "Qty. to Handle (Base)" := Round(QtyToHandleBase, 0.00001); // P8000392A
                Validate("Qty. to Handle", Round(QtyToHandleBase / "Qty. per Unit of Measure", 0.00001));
            end;
            Modify;
        end;
    end;

    procedure SetWhseActLineAltQty(var WhseActLine: Record "Warehouse Activity Line")
    begin
        // P8000282A
        with WhseActLine do begin
            GetItem("Item No.");
            if not Item.TrackAlternateUnits then
                "Quantity (Alt.)" := 0
            else
                if Item."Catch Alternate Qtys." then begin
                    if ("Qty. to Handle (Base)" = Round(CalcAltQtyLinesQtyBase1("Alt. Qty. Transaction No."), 0.00001)) then // P8000392A
                        "Quantity (Alt.)" := "Quantity Handled (Alt.)" + "Qty. to Handle (Alt.)" +
                          // P8007584
                          //CalcAltQty("Item No.", "Qty. Outstanding (Base)" - "Qty. to Handle (Base)")
                          CalcAltQty("Item No.", ("Qty. Outstanding" - "Qty. to Handle") * "Qty. per Unit of Measure")
                    // P8007584
                    else
                        "Quantity (Alt.)" :=
                          // P8007584
                          //  "Quantity Handled (Alt.)" + CalcAltQty("Item No.", "Qty. Outstanding (Base)");
                          "Quantity Handled (Alt.)" + CalcAltQty("Item No.", "Qty. Outstanding" * "Qty. per Unit of Measure");
                    // P8007584
                end else begin
                    // P8000550A
                    // "Qty. to Handle (Alt.)" := CalcAltQty("Item No.", "Qty. to Handle (Base)");
                    // "Quantity (Alt.)" :=
                    //   "Quantity Handled (Alt.)" + CalcAltQty("Item No.", "Qty. Outstanding (Base)");
                    if ("Qty. Outstanding (Base)" = 0) then
                        "Quantity (Alt.)" := "Quantity Handled (Alt.)"
                    else
                        // P8007584
                        //"Quantity (Alt.)" := CalcAltQty("Item No.", "Qty. (Base)");
                        "Quantity (Alt.)" := CalcAltQty("Item No.", Quantity * "Qty. per Unit of Measure");
                    // P8007584
                    "Qty. to Handle (Alt.)" :=
                      CalcAltQtyToHandle("Item No.", "Qty. (Base)", "Qty. to Handle (Base)",
                                         "Qty. Handled (Base)", "Quantity (Alt.)", "Quantity Handled (Alt.)");
                    // P8000550A
                end;
        end;
    end;

    procedure UpdateAltQtyLotSerial(AltQtyTransactionNo: Integer; xSerialNo: Code[50]; xLotNo: Code[50]; SerialNo: Code[50]; LotNo: Code[50])
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // P8000282A
        if (xSerialNo = SerialNo) and (xLotNo = LotNo) then
            exit;

        with AltQtyLine do begin
            SetRange("Alt. Qty. Transaction No.", AltQtyTransactionNo);
            SetRange("Serial No.", xSerialNo);
            SetRange("Lot No.", xLotNo);
            if Find('-') then
                repeat
                    "Serial No." := SerialNo;
                    "Lot No." := LotNo;
                    Modify;
                until (Next = 0);
        end;
    end;

    procedure UpdateTrackingLotSerial(var TrackingLine: Record "Tracking Specification"; xTrackingLine: Record "Tracking Specification")
    begin
        // P8000282A
        with TrackingLine do
            UpdateAltQtyLotSerial(
              GetSourceAltQtyTransNo(
                "Source Type", DocumentType(), DocumentNo(),
                TemplateName(), BatchName(), "Source Ref. No.", false),
              xTrackingLine."Serial No.", xTrackingLine."Lot No.", "Serial No.", "Lot No.");
    end;

    procedure DeleteTrackingLotSerial(var TrackingLine: Record "Tracking Specification")
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // P8000538A
        with TrackingLine do begin
            AltQtyLine.SetRange("Alt. Qty. Transaction No.",
              GetSourceAltQtyTransNo("Source Type", DocumentType, DocumentNo, TemplateName, BatchName, "Source Ref. No.", false));
            AltQtyLine.SetRange("Serial No.", "Serial No.");
            AltQtyLine.SetRange("Lot No.", "Lot No.");
            AltQtyLine.DeleteAll(true); // P80070336
        end;
    end;

    procedure CopyWhseActToPurchase(var TempWhseActHeader: Record "Warehouse Activity Header" temporary; var PurchHeader: Record "Purchase Header")
    var
        WhseActLine: Record "Warehouse Activity Line";
        PurchLine: Record "Purchase Line";
        Item: Record Item;
    begin
        // P8000282A
        if not TempWhseActHeader.Find('-') then
            exit;
        WhseActLine.SetRange("Activity Type", TempWhseActHeader.Type);
        WhseActLine.SetRange("No.", TempWhseActHeader."No.");
        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchHeader."No.");
        PurchLine.SetRange(Type, PurchLine.Type::Item);
        PurchLine.SetFilter("No.", '<>%1', '');
        if PurchLine.Find('-') then begin
            repeat
                if PurchLine.TrackAlternateUnits() then begin
                    WhseActLine.SetRange("Source Line No.", PurchLine."Line No.");
                    if WhseActLine.Find('-') then
                        repeat
                            if AltQtyLinesExist(WhseActLine."Alt. Qty. Transaction No.") then
                                CopyWhseAltQtys(
                                  WhseActLine."Alt. Qty. Transaction No.", PurchLine."Alt. Qty. Transaction No.", ''); // P80079981
                        until (WhseActLine.Next = 0);
                    UpdatePurchLine(PurchLine);
                    Item.Get(PurchLine."No.");           // P8000662
                    if Item."Catch Alternate Qtys." then // P8000662
                        UpdatePurchTracking(PurchLine);
                    PurchLine.InitQtyToInvoice;
                    PurchLine.GetLotNo;
                    PurchLine.Modify(true);
                end;
            until (PurchLine.Next = 0);
        end;
    end;

    procedure CopyWhseActToSale(var TempWhseActHeader: Record "Warehouse Activity Header" temporary; var SalesHeader: Record "Sales Header")
    var
        WhseActLine: Record "Warehouse Activity Line";
        SalesLine: Record "Sales Line";
        Item: Record Item;
    begin
        // P8000282A
        if not TempWhseActHeader.Find('-') then
            exit;
        WhseActLine.SetRange("Activity Type", TempWhseActHeader.Type);
        WhseActLine.SetRange("No.", TempWhseActHeader."No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetFilter("No.", '<>%1', '');
        if SalesLine.Find('-') then begin
            repeat
                if SalesLine.TrackAlternateUnits() then begin
                    WhseActLine.SetRange("Source Line No.", SalesLine."Line No.");
                    if WhseActLine.Find('-') then
                        repeat
                            if AltQtyLinesExist(WhseActLine."Alt. Qty. Transaction No.") then
                                CopyWhseAltQtys(
                                  WhseActLine."Alt. Qty. Transaction No.", SalesLine."Alt. Qty. Transaction No.", ''); // P80079981
                        until (WhseActLine.Next = 0);
                    UpdateSalesLine(SalesLine);
                    Item.Get(SalesLine."No.");           // P8000662
                    if Item."Catch Alternate Qtys." then // P8000662
                        UpdateSalesTracking(SalesLine);
                    SalesLine.InitQtyToInvoice;
                    SalesLine.GetLotNo;
                    SalesLine.Modify(true);
                end;
            until (SalesLine.Next = 0);
        end;
    end;

    procedure CopyWhseActToTransfer(var TempWhseActHeader: Record "Warehouse Activity Header" temporary; var TransHeader: Record "Transfer Header")
    var
        WhseActLine: Record "Warehouse Activity Line";
        TransLine: Record "Transfer Line";
        Item: Record Item;
        Direction: Option Outbound,Inbound;
        AltQtyTransNo: Integer;
    begin
        // P8000282A
        if not TempWhseActHeader.Find('-') then
            exit;
        WhseActLine.SetRange("Activity Type", TempWhseActHeader.Type);
        WhseActLine.SetRange("No.", TempWhseActHeader."No.");
        TransLine.SetRange("Document No.", TransHeader."No.");
        TransLine.SetFilter("Item No.", '<>%1', '');
        TransLine.SetRange("Derived From Line No.", 0);
        if TransLine.Find('-') then begin
            if (TempWhseActHeader.Type = TempWhseActHeader.Type::"Invt. Put-away") then
                Direction := Direction::Inbound
            else
                Direction := Direction::Outbound;
            repeat
                if TransLine.TrackAlternateUnits() then begin
                    WhseActLine.SetRange("Source Line No.", TransLine."Line No.");
                    if WhseActLine.Find('-') then
                        repeat
                            if AltQtyLinesExist(WhseActLine."Alt. Qty. Transaction No.") then
                                case Direction of
                                    Direction::Outbound:
                                        CopyWhseAltQtys(
                                          WhseActLine."Alt. Qty. Transaction No.", TransLine."Alt. Qty. Trans. No. (Ship)", ''); // P80079981
                                    Direction::Inbound:
                                        CopyWhseAltQtys(
                                          WhseActLine."Alt. Qty. Transaction No.", TransLine."Alt. Qty. Trans. No. (Receive)", '') // P80079981
                                end;
                        until (WhseActLine.Next = 0);
                    UpdateTransLine(TransLine, Direction);
                    Item.Get(TransLine."Item No.");      // P8000662
                    if Item."Catch Alternate Qtys." then // P8000662
                        UpdateTransTracking(TransLine, Direction);
                    TransLine.GetLotNo;
                    TransLine.Modify(true);
                end;
            until (TransLine.Next = 0);
        end;
    end;

    local procedure CopyWhseAltQtys(FromTransNo: Integer; var ToTransNo: Integer; AddRefID: Variant)
    var
        FromAltQtyLine: Record "Alternate Quantity Line";
        ToAltQtyLine: Record "Alternate Quantity Line";
        LastLineNo: Integer;
        AddRefRecID: RecordID;
    begin
        // P8000282A
        // P80079981
        if AddRefID.IsRecordId then
            AddRefRecID := AddRefID;
        // P80079981
        AssignNewTransactionNo(ToTransNo);
        with ToAltQtyLine do begin
            SetRange("Alt. Qty. Transaction No.", ToTransNo);
            if Find('+') then
                LastLineNo := "Line No.";
            Reset;
        end;
        with FromAltQtyLine do begin
            SetRange("Alt. Qty. Transaction No.", FromTransNo);
            if Find('-') then
                repeat
                    ToAltQtyLine := FromAltQtyLine;
                    ToAltQtyLine."Alt. Qty. Transaction No." := ToTransNo;
                    LastLineNo := LastLineNo + 10000;
                    ToAltQtyLine."Line No." := LastLineNo;
                    ToAltQtyLine."Additional Ref. ID" := AddRefRecID; // P80079981
                    ToAltQtyLine.Insert;
                until (Next = 0);
        end;
    end;

    local procedure RemoveWhseAltQtys(FromTransNo: Integer; ToTransNo: Integer; QtyPer: Decimal)
    var
        FromAltQtyLine: Record "Alternate Quantity Line";
        ToAltQtyLine: Record "Alternate Quantity Line";
        QtyToRemove: Decimal;
    begin
        // P8001323
        if (FromTransNo = 0) or (ToTransNo = 0) then
            exit;

        FromAltQtyLine.SetRange("Alt. Qty. Transaction No.", FromTransNo);
        if FromAltQtyLine.FindSet then
            repeat
                ToAltQtyLine.SetRange("Alt. Qty. Transaction No.", ToTransNo);
                ToAltQtyLine.SetRange("Lot No.", FromAltQtyLine."Lot No.");
                ToAltQtyLine.SetRange("Serial No.", FromAltQtyLine."Serial No.");
                ToAltQtyLine.SetRange("Container ID", ''); // P80075420
                if ToAltQtyLine.FindSet(true) then
                    repeat
                        if FromAltQtyLine.Quantity <= ToAltQtyLine.Quantity then
                            QtyToRemove := FromAltQtyLine.Quantity
                        else
                            QtyToRemove := ToAltQtyLine.Quantity;
                        ToAltQtyLine.Quantity -= QtyToRemove;
                        FromAltQtyLine.Quantity -= QtyToRemove;
                        if FromAltQtyLine."Quantity (Alt.)" <= ToAltQtyLine."Quantity (Alt.)" then
                            QtyToRemove := FromAltQtyLine."Quantity (Alt.)"
                        else
                            QtyToRemove := ToAltQtyLine."Quantity (Alt.)";
                        ToAltQtyLine."Quantity (Alt.)" -= QtyToRemove;
                        FromAltQtyLine."Quantity (Alt.)" -= QtyToRemove;
                        if (ToAltQtyLine.Quantity > 0) or (ToAltQtyLine."Quantity (Alt.)" > 0) then begin
                            if ToAltQtyLine.Quantity = 0 then
                                ToAltQtyLine."Quantity (Base)" := 0
                            else
                                ToAltQtyLine."Quantity (Base)" := Round(ToAltQtyLine.Quantity * QtyPer, 0.00001);
                            ToAltQtyLine.Modify;
                        end else
                            ToAltQtyLine.Delete;
                    until (ToAltQtyLine.Next = 0) or ((FromAltQtyLine."Quantity (Base)" = 0) and (FromAltQtyLine."Quantity (Alt.)" = 0));
            until FromAltQtyLine.Next = 0;
    end;

    local procedure CopyWhsePickToSourceLine(var WhseActLine: Record "Warehouse Activity Line"; RegisteredWhseActivityLine: Record "Registered Whse. Activity Line")
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
    begin
        // P8000282A
        with WhseActLine do
            if AltQtyLinesExist("Alt. Qty. Transaction No.") and ("Activity Type" = "Activity Type"::Pick) then // P80073095
                case "Source Type" of
                    DATABASE::"Sales Line":
                        begin
                            SalesLine.Get("Source Subtype", "Source No.", "Source Line No.");
                            if WhseActLine."Action Type" = WhseActLine."Action Type"::Take then      // P8001323
                                CopyWhseAltQtys(
                                  "Alt. Qty. Transaction No.", SalesLine."Alt. Qty. Transaction No.", RegisteredWhseActivityLine.RecordId) // P80079981
                            else                                                                     // P8001323
                                RemoveWhseAltQtys(                                                     // P8001323
                                  "Alt. Qty. Transaction No.", SalesLine."Alt. Qty. Transaction No.", WhseActLine."Qty. per Unit of Measure"); // P8001323
                            SalesLine.Modify(true);
                        end;
                    DATABASE::"Purchase Line":
                        begin
                            PurchLine.Get("Source Subtype", "Source No.", "Source Line No.");
                            if WhseActLine."Action Type" = WhseActLine."Action Type"::Take then      // P8001323
                                CopyWhseAltQtys(
                                  "Alt. Qty. Transaction No.", PurchLine."Alt. Qty. Transaction No.", RegisteredWhseActivityLine.RecordId) // P80079981
                            else                                                                     // P8001323
                                RemoveWhseAltQtys(                                                     // P8001323
                                  "Alt. Qty. Transaction No.", PurchLine."Alt. Qty. Transaction No.", WhseActLine."Qty. per Unit of Measure"); // P8001323
                            PurchLine.Modify(true);
                        end;
                    DATABASE::"Transfer Line":
                        begin
                            TransLine.Get("Source No.", "Source Line No.");
                            if WhseActLine."Action Type" = WhseActLine."Action Type"::Take then        // P8001323
                                CopyWhseAltQtys(
                                  "Alt. Qty. Transaction No.", TransLine."Alt. Qty. Trans. No. (Ship)", RegisteredWhseActivityLine.RecordId) // P80079981
                            else                                                                       // P8001323
                                RemoveWhseAltQtys(                                                       // P8001323
                                  "Alt. Qty. Transaction No.", TransLine."Alt. Qty. Trans. No. (Ship)", WhseActLine."Qty. per Unit of Measure"); // P8001323
                            TransLine.Modify(true);
                        end;
                end;
    end;

    procedure UpdateWhseShptTracking(RegPickHeader: Record "Registered Whse. Activity Hdr.")
    var
        RegPickLine: Record "Registered Whse. Activity Line";
        TempRegPickLine: Record "Registered Whse. Activity Line" temporary;
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        ContainerHeader: Record "Container Header";
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
        Item: Record Item;
        Direction: Option Outbound,Inbound;
    begin
        // P8000282A
        if (RegPickHeader.Type <> RegPickHeader.Type::Pick) then
            exit;

        // P80066185
        RegPickLine.SetRange("Activity Type", RegPickHeader.Type);
        RegPickLine.SetRange("No.", RegPickHeader."No.");
        if RegPickLine.FindFirst then
            if RegPickLine."Whse. Document Type" <> RegPickLine."Whse. Document Type"::Shipment then
                exit;
        WarehouseShipmentLine.SetRange("No.", RegPickLine."Whse. Document No.");
        if WarehouseShipmentLine.FindSet then begin
            RegPickLine.Reset;
            RegPickLine.SetRange("Activity Type", RegPickHeader.Type);
            RegPickLine.SetRange("Action Type", RegPickLine."Action Type"::Place);
            RegPickLine.SetRange("Whse. Document Type", RegPickLine."Whse. Document Type"::Shipment);
            repeat
                RegPickLine.SetRange("Source Type", WarehouseShipmentLine."Source Type");
                RegPickLine.SetRange("Source Subtype", WarehouseShipmentLine."Source Subtype");
                RegPickLine.SetRange("Source No.", WarehouseShipmentLine."Source No.");
                RegPickLine.SetRange("Source Line No.", WarehouseShipmentLine."Source Line No.");
                RegPickLine.SetRange("Whse. Document No.", WarehouseShipmentLine."No.");
                if RegPickLine.FindSet then
                    repeat
                        Item.Get(RegPickLine."Item No.");
                        if Item.TrackAlternateUnits then begin
                            if RegPickLine."Container ID" <> '' then
                                if ContainerHeader.Get(RegPickLine."Container ID") then
                                    if not ContainerHeader."Ship/Receive" then
                                        RegPickLine."Qty. (Base)" := 0;
                            if RegPickLine."Qty. (Base)" <> 0 then begin
                                TempRegPickLine.SetRange("Source Type", RegPickLine."Source Type");
                                TempRegPickLine.SetRange("Source Subtype", RegPickLine."Source Subtype");
                                TempRegPickLine.SetRange("Source No.", RegPickLine."Source No.");
                                TempRegPickLine.SetRange("Source Line No.", RegPickLine."Source Line No.");
                                if not Item."Catch Alternate Qtys." then begin
                                    TempRegPickLine.SetRange("Lot No.", RegPickLine."Lot No.");
                                    TempRegPickLine.SetRange("Serial No.", RegPickLine."Serial No.");
                                end else begin
                                    TempRegPickLine.SetRange("Lot No.");
                                    TempRegPickLine.SetRange("Serial No.");
                                end;
                                if TempRegPickLine.FindFirst then begin
                                    TempRegPickLine."Qty. (Base)" += RegPickLine."Qty. (Base)";
                                    TempRegPickLine.Modify;
                                end else begin
                                    TempRegPickLine := RegPickLine;
                                    TempRegPickLine.Insert;
                                end;
                            end;
                        end;
                    until RegPickLine.Next = 0;
            until WarehouseShipmentLine.Next = 0;
        end;
        TempRegPickLine.Reset;
        TempRegPickLine.SetCurrentKey("Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.");
        // P80066185

        with TempRegPickLine do begin
            // P8000629A
            if Find('-') then
                repeat
                    case "Source Type" of
                        DATABASE::"Sales Line":
                            begin
                                SalesLine.Get("Source Subtype", "Source No.", "Source Line No.");
                                // P8000629A
                                if SalesLine."Alt. Qty. Transaction No." = 0 then begin
                                    TempRegPickLine.SetRange("Source Type", "Source Type");
                                    TempRegPickLine.SetRange("Source Subtype", "Source Subtype");
                                    TempRegPickLine.SetRange("Source No.", "Source No.");
                                    TempRegPickLine.SetRange("Source Line No.", "Source Line No.");
                                    UpdTrackingFixedAltQtyFromPick(TempRegPickLine);
                                    TempRegPickLine.FindLast;
                                    TempRegPickLine.SetRange("Source Type");
                                    TempRegPickLine.SetRange("Source Subtype");
                                    TempRegPickLine.SetRange("Source No.");
                                    TempRegPickLine.SetRange("Source Line No.");
                                end else
                                    // P8000629A
                                    if AltQtyLinesExist(SalesLine."Alt. Qty. Transaction No.") then begin
                                        UpdateSalesTracking(SalesLine);
                                        SalesLine.GetLotNo;
                                        SalesLine.Modify; // P8004505
                                    end;
                            end;
                        DATABASE::"Purchase Line":
                            begin
                                PurchLine.Get("Source Subtype", "Source No.", "Source Line No.");
                                // P8000629A
                                if PurchLine."Alt. Qty. Transaction No." = 0 then begin
                                    TempRegPickLine.SetRange("Source Type", "Source Type");
                                    TempRegPickLine.SetRange("Source Subtype", "Source Subtype");
                                    TempRegPickLine.SetRange("Source No.", "Source No.");
                                    TempRegPickLine.SetRange("Source Line No.", "Source Line No.");
                                    UpdTrackingFixedAltQtyFromPick(TempRegPickLine);
                                    TempRegPickLine.FindLast;
                                    TempRegPickLine.SetRange("Source Type");
                                    TempRegPickLine.SetRange("Source Subtype");
                                    TempRegPickLine.SetRange("Source No.");
                                    TempRegPickLine.SetRange("Source Line No.");
                                end else
                                    // P8000629A
                                    if AltQtyLinesExist(PurchLine."Alt. Qty. Transaction No.") then begin
                                        UpdatePurchTracking(PurchLine);
                                        PurchLine.GetLotNo;
                                        PurchLine.Modify; // P8004505
                                    end;
                            end;
                        DATABASE::"Transfer Line":
                            begin
                                TransLine.Get("Source No.", "Source Line No.");
                                // P8000629A
                                if TransLine."Alt. Qty. Trans. No. (Ship)" = 0 then begin
                                    TempRegPickLine.SetRange("Source Type", "Source Type");
                                    TempRegPickLine.SetRange("Source Subtype", "Source Subtype");
                                    TempRegPickLine.SetRange("Source No.", "Source No.");
                                    TempRegPickLine.SetRange("Source Line No.", "Source Line No.");
                                    UpdTrackingFixedAltQtyFromPick(TempRegPickLine);
                                    TempRegPickLine.FindLast;
                                    TempRegPickLine.SetRange("Source Type");
                                    TempRegPickLine.SetRange("Source Subtype");
                                    TempRegPickLine.SetRange("Source No.");
                                    TempRegPickLine.SetRange("Source Line No.");
                                end else
                                    // P8000629A
                                    if AltQtyLinesExist(TransLine."Alt. Qty. Trans. No. (Ship)") then begin
                                        UpdateTransTracking(TransLine, Direction::Outbound);
                                        TransLine.GetLotNo;
                                        TransLine.Modify; // P8004505
                                    end;
                            end;
                    end;
                until (Next = 0);
        end;
    end;

    local procedure UpdTrackingFixedAltQtyFromPick(var TempRegPickLine: Record "Registered Whse. Activity Line")
    var
        ReservEntry: Record "Reservation Entry";
        Item: Record Item;
        RemQtyBase: Decimal;
        RemQtyAlt: Decimal;
        CreateReservEntry: Codeunit "Create Reserv. Entry";
    begin
        with ReservEntry do begin
            SetCurrentKey(
              "Source Type", "Source Subtype", "Source ID", "Source Batch Name",
              "Source Prod. Order Line", "Source Ref. No.");
            SetRange("Source Type", TempRegPickLine."Source Type");
            SetRange("Source Subtype", TempRegPickLine."Source Subtype");
            SetRange("Source ID", TempRegPickLine."Source No.");
            SetRange("Source Ref. No.", TempRegPickLine."Source Line No.");
            if Find('-') then
                repeat
                    if not Mark then begin
                        TempRegPickLine.SetRange("Lot No.", "Lot No.");
                        TempRegPickLine.SetRange("Serial No.", "Serial No.");
                        if TempRegPickLine.FindFirst then
                            RemQtyBase := TempRegPickLine."Qty. (Base)"
                        else
                            RemQtyBase := 0;
                        RemQtyBase := RemQtyBase * CreateReservEntry.SignFactor(ReservEntry);
                        Item.Get("Item No.");
                        RemQtyAlt := Round(RemQtyBase * Item.AlternateQtyPerBase, 0.00001);
                        SetRange("Lot No.", "Lot No.");
                        SetRange("Serial No.", "Serial No.");
                        repeat
                            if (Abs("Quantity (Base)") < Abs(RemQtyBase)) then
                                "Qty. to Handle (Base)" := "Quantity (Base)"
                            else
                                "Qty. to Handle (Base)" := RemQtyBase;
                            if (RemQtyBase = 0) then
                                "Qty. to Handle (Alt.)" := RemQtyAlt
                            else
                                "Qty. to Handle (Alt.)" :=
                                  Round(RemQtyAlt * ("Qty. to Handle (Base)" / RemQtyBase), 0.00001);
                            "Qty. to Invoice (Base)" := "Qty. to Handle (Base)";
                            "Qty. to Invoice (Alt.)" := "Qty. to Handle (Alt.)";
                            Modify;
                            RemQtyBase := RemQtyBase - "Qty. to Handle (Base)";
                            RemQtyAlt := RemQtyAlt - "Qty. to Handle (Alt.)";
                            Mark(true);
                        until (Next = 0);
                        Find('-');
                        SetRange("Lot No.");
                        SetRange("Serial No.");
                    end;
                until (Next = 0);
            TempRegPickLine.SetRange("Lot No.");
            TempRegPickLine.SetRange("Serial No.");
        end;
    end;

    procedure CopyTransAltQtysToPutAway(var PutAwayHeader: Record "Warehouse Activity Header")
    var
        PutAwayLine: Record "Warehouse Activity Line";
        TransLine: Record "Transfer Line";
        AltQtyLine: Record "Alternate Quantity Line";
        AltQtyLine2: Record "Alternate Quantity Line";
    begin
        // P8000282A
        if (PutAwayHeader."Source Document" <> PutAwayHeader."Source Document"::"Inbound Transfer") then
            exit;

        with PutAwayLine do begin
            SetRange("Activity Type", PutAwayHeader.Type);
            SetRange("No.", PutAwayHeader."No.");
            if Find('-') then
                repeat
                    if TrackAlternateUnits() then begin
                        TransLine.Get("Source No.", "Source Line No.");
                        AltQtyLine.SetRange("Alt. Qty. Transaction No.", TransLine."Alt. Qty. Trans. No. (Receive)");
                        AltQtyLine.SetRange("Serial No.", "Serial No.");
                        AltQtyLine.SetRange("Lot No.", "Lot No.");
                        if AltQtyLine.Find('-') then begin
                            AssignNewTransactionNo("Alt. Qty. Transaction No.");
                            repeat
                                AltQtyLine2 := AltQtyLine;
                                AltQtyLine2."Alt. Qty. Transaction No." := "Alt. Qty. Transaction No.";
                                AltQtyLine2.Insert;
                            until (AltQtyLine.Next = 0);
                            UpdateWhseActLine(PutAwayLine);
                            SetWhseActLineAltQty(PutAwayLine);
                            Modify(true);
                        end;
                    end;
                until (Next = 0);
        end;
    end;

    procedure WhseShptLineGetData(var WhseShptLine: Record "Warehouse Shipment Line"; var QtyToHandleAlt: Decimal)
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
        Item: Record Item;
        AltQtyTransNo: Integer;
    begin
        // P8000282A
        // P8008729
        if WhseShptLine."Item No." = '' then
            exit;
        // P8008729

        QtyToHandleAlt := 0; // P8001323
        with WhseShptLine do begin // P8000629A
            case "Source Type" of
                DATABASE::"Sales Line":
                    begin
                        SalesLine.Get("Source Subtype", "Source No.", "Source Line No.");
                        //QtyToHandleAlt := CalcAltQtyLinesQtyAlt1(SalesLine."Alt. Qty. Transaction No."); // P8000629A
                        AltQtyTransNo := SalesLine."Alt. Qty. Transaction No.";                            // P8000629A
                    end;
                DATABASE::"Purchase Line":
                    begin
                        PurchLine.Get("Source Subtype", "Source No.", "Source Line No.");
                        //QtyToHandleAlt := CalcAltQtyLinesQtyAlt1(PurchLine."Alt. Qty. Transaction No."); // P8000629A
                        AltQtyTransNo := PurchLine."Alt. Qty. Transaction No.";                            // P8000629A
                    end;
                DATABASE::"Transfer Line":
                    begin
                        TransLine.Get("Source No.", "Source Line No.");
                        //QtyToHandleAlt := CalcAltQtyLinesQtyAlt1(TransLine."Alt. Qty. Trans. No. (Ship)"); // P8000629A
                        AltQtyTransNo := TransLine."Alt. Qty. Trans. No. (Ship)";                            // P8000629A
                    end;
            end;

            // P8000629A
            if AltQtyTransNo <> 0 then
                QtyToHandleAlt := CalcAltQtyLinesQtyAlt1(AltQtyTransNo)
            else begin
                Item.Get("Item No.");
                if Item.TrackAlternateUnits and (not Item."Catch Alternate Qtys.") then // P8000713
                    QtyToHandleAlt := Round("Qty. to Ship (Base)" * Item.AlternateQtyPerBase, 0.00001);
            end;
        end;
        // P8000629A
    end;

    procedure WhseRcptLineGetData(var WhseRcptLine: Record "Warehouse Receipt Line"; var QtyToHandleAlt: Decimal)
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
        Item: Record Item;
        AltQtyTransNo: Integer;
    begin
        // P8000282A
        // P8008729
        if WhseRcptLine."Item No." = '' then
            exit;
        // P8008729

        QtyToHandleAlt := 0; // P8001323
        with WhseRcptLine do begin // P8000629A
            case "Source Type" of
                DATABASE::"Sales Line":
                    begin
                        SalesLine.Get("Source Subtype", "Source No.", "Source Line No.");
                        //QtyToHandleAlt := CalcAltQtyLinesQtyAlt1(SalesLine."Alt. Qty. Transaction No."); // P8000629A
                        AltQtyTransNo := SalesLine."Alt. Qty. Transaction No.";                            // P8000629A
                    end;
                DATABASE::"Purchase Line":
                    begin
                        PurchLine.Get("Source Subtype", "Source No.", "Source Line No.");
                        //QtyToHandleAlt := CalcAltQtyLinesQtyAlt1(PurchLine."Alt. Qty. Transaction No."); // P8000629A
                        AltQtyTransNo := PurchLine."Alt. Qty. Transaction No.";                            // P8000629A
                    end;
                DATABASE::"Transfer Line":
                    begin
                        TransLine.Get("Source No.", "Source Line No.");
                        //QtyToHandleAlt := CalcAltQtyLinesQtyAlt1(TransLine."Alt. Qty. Trans. No. (Receive)"); // P8000629A
                        AltQtyTransNo := TransLine."Alt. Qty. Trans. No. (Receive)";                            // P8000629A
                    end;
            end;

            // P8000629A
            if AltQtyTransNo <> 0 then
                QtyToHandleAlt := CalcAltQtyLinesQtyAlt1(AltQtyTransNo)
            else begin
                Item.Get("Item No.");
                if Item.TrackAlternateUnits and (not Item."Catch Alternate Qtys.") then // P8000713
                    QtyToHandleAlt := Round("Qty. to Receive (Base)" * Item.AlternateQtyPerBase, 0.00001);
            end;
        end;
        // P8000629A
    end;

    procedure WhseShptLineValidateQty(var WhseShptLine: Record "Warehouse Shipment Line"; var QtyToHandleAlt: Decimal; CheckTolerance: Boolean)
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
    begin
        // P8000282A
        // P8006787 - add parameter CheckTolerance
        with WhseShptLine do
            case "Source Type" of
                DATABASE::"Sales Line":
                    begin
                        SalesLine.Get("Source Subtype", "Source No.", "Source Line No.");
                        SalesLine.Validate("Qty. to Ship", "Qty. to Ship");
                        SalesLine.Validate("Qty. to Ship (Alt.)", QtyToHandleAlt);
                        if CheckTolerance then // P8006787
                            CheckSummaryTolerance1(
                              SalesLine."Alt. Qty. Transaction No.", SalesLine."No.",
                              SalesLine.FieldCaption("Qty. to Ship (Alt.)"),
                              SalesLine."Qty. to Ship (Base)", SalesLine."Qty. to Ship (Alt.)");
                        ValidateSalesAltQtyLine(SalesLine);
                        SalesLine.GetLotNo;
                        SalesLine.UpdateOnWhseChange;
                        SalesLine.Modify; // P8006444
                    end;
                DATABASE::"Purchase Line":
                    begin
                        PurchLine.Get("Source Subtype", "Source No.", "Source Line No.");
                        PurchLine.Validate("Return Qty. to Ship", "Qty. to Ship");
                        PurchLine.Validate("Return Qty. to Ship (Alt.)", QtyToHandleAlt);
                        if CheckTolerance then // P8006787
                            CheckSummaryTolerance1(
                              PurchLine."Alt. Qty. Transaction No.", PurchLine."No.",
                              PurchLine.FieldCaption("Return Qty. to Ship (Alt.)"),
                              PurchLine."Return Qty. to Ship (Base)", PurchLine."Return Qty. to Ship (Alt.)");
                        ValidatePurchAltQtyLine(PurchLine);
                        PurchLine.GetLotNo;
                        PurchLine.UpdateOnWhseChange;
                        PurchLine.Modify; // P8006444
                    end;
                DATABASE::"Transfer Line":
                    begin
                        TransLine.Get("Source No.", "Source Line No.");
                        TransLine.Validate("Qty. to Ship", "Qty. to Ship");
                        TransLine.Validate("Qty. to Ship (Alt.)", QtyToHandleAlt);
                        if CheckTolerance then // P8006787
                            CheckSummaryTolerance1(
                              TransLine."Alt. Qty. Trans. No. (Ship)", TransLine."Item No.",
                              TransLine.FieldCaption("Qty. to Ship (Alt.)"),
                              TransLine."Qty. to Ship (Base)", TransLine."Qty. to Ship (Alt.)");
                        ValidateTransAltQtyLine(TransLine, "Source Subtype");
                        TransLine.GetLotNo;
                        TransLine.UpdateOnWhseChange("Source Subtype");
                        TransLine.Modify; // P8006444
                    end;
            end;
    end;

    procedure WhseRcptLineValidateQty(var WhseRcptLine: Record "Warehouse Receipt Line"; var QtyToHandleAlt: Decimal)
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
    begin
        // P8000282A
        with WhseRcptLine do
            case "Source Type" of
                DATABASE::"Sales Line":
                    begin
                        SalesLine.Get("Source Subtype", "Source No.", "Source Line No.");
                        SalesLine.Validate("Return Qty. to Receive", "Qty. to Receive");
                        SalesLine.Validate("Return Qty. to Receive (Alt.)", QtyToHandleAlt);
                        CheckSummaryTolerance1(
                          SalesLine."Alt. Qty. Transaction No.", SalesLine."No.",
                          SalesLine.FieldCaption("Return Qty. to Receive (Alt.)"),
                          SalesLine."Return Qty. to Receive (Base)", SalesLine."Return Qty. to Receive (Alt.)");
                        ValidateSalesAltQtyLine(SalesLine);
                        Validate("Qty. to Receive", SalesLine."Return Qty. to Receive");
                        SalesLine.GetLotNo;
                        SalesLine.UpdateOnWhseChange;
                        SalesLine.Modify; // P8006444
                    end;
                DATABASE::"Purchase Line":
                    begin
                        PurchLine.Get("Source Subtype", "Source No.", "Source Line No.");
                        PurchLine.Validate("Qty. to Receive", "Qty. to Receive");
                        PurchLine.Validate("Qty. to Receive (Alt.)", QtyToHandleAlt);
                        CheckSummaryTolerance1(
                          PurchLine."Alt. Qty. Transaction No.", PurchLine."No.",
                          PurchLine.FieldCaption("Qty. to Receive (Alt.)"),
                          PurchLine."Qty. to Receive (Base)", PurchLine."Qty. to Receive (Alt.)");
                        ValidatePurchAltQtyLine(PurchLine);
                        Validate("Qty. to Receive", PurchLine."Qty. to Receive");
                        PurchLine.GetLotNo;
                        PurchLine.UpdateOnWhseChange;
                        PurchLine.Modify; // P8006444
                    end;
                DATABASE::"Transfer Line":
                    begin
                        TransLine.Get("Source No.", "Source Line No.");
                        TransLine.Validate("Qty. to Receive", "Qty. to Receive");
                        TransLine.Validate("Qty. to Receive (Alt.)", QtyToHandleAlt);
                        CheckSummaryTolerance1(
                          TransLine."Alt. Qty. Trans. No. (Receive)", TransLine."Item No.",
                          TransLine.FieldCaption("Qty. to Receive (Alt.)"),
                          TransLine."Qty. to Receive (Base)", TransLine."Qty. to Receive (Alt.)");
                        ValidateTransAltQtyLine(TransLine, "Source Subtype");
                        Validate("Qty. to Receive", TransLine."Qty. to Receive");
                        TransLine.GetLotNo;
                        TransLine.UpdateOnWhseChange("Source Subtype");
                        TransLine.Modify; // P8006444
                    end;
            end;
    end;

    procedure WhseShptLineDrillQty(var WhseShptLine: Record "Warehouse Shipment Line")
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
        Handled: Boolean;
    begin
        // P8000282A
        // P80082969
        OnBeforeWhseShptLineDrillQty(WhseShptLine, Handled);
        if Handled then
            exit;
        // P80082969

        with WhseShptLine do
            case "Source Type" of
                DATABASE::"Sales Line":
                    begin
                        SalesLine.Get("Source Subtype", "Source No.", "Source Line No.");
                        SalesLine.SuspendStatusCheck(true); // P80070336
                        SalesLine.Validate("Qty. to Ship", "Qty. to Ship");
                        ShowSalesAltQtyLines(SalesLine);
                        SalesLine.GetLotNo;
                        SalesLine.UpdateOnWhseChange;
                        SalesLine.Modify; // P8006444
                    end;
                DATABASE::"Purchase Line":
                    begin
                        PurchLine.Get("Source Subtype", "Source No.", "Source Line No.");
                        PurchLine.SuspendStatusCheck(true); // P80070336
                        PurchLine.Validate("Return Qty. to Ship", "Qty. to Ship");
                        ShowPurchAltQtyLines(PurchLine);
                        PurchLine.GetLotNo;
                        PurchLine.UpdateOnWhseChange;
                        PurchLine.Modify; // P8006444
                    end;
                DATABASE::"Transfer Line":
                    begin
                        TransLine.Get("Source No.", "Source Line No.");
                        TransLine.Validate("Qty. to Ship", "Qty. to Ship");
                        ShowTransAltQtyLines(TransLine, "Source Subtype");
                        TransLine.GetLotNo;
                        TransLine.UpdateOnWhseChange("Source Subtype");
                        TransLine.Modify; // P8006444
                    end;
            end;
    end;

    procedure WhseRcptLineDrillQty(var WhseRcptLine: Record "Warehouse Receipt Line")
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
        Handled: Boolean;
    begin
        // P8000282A
        // P80082969
        OnBeforeWhseRcptLineDrillQty(WhseRcptLine, Handled);
        if Handled then
            exit;
        // P80082969

        with WhseRcptLine do
            case "Source Type" of
                DATABASE::"Sales Line":
                    begin
                        SalesLine.Get("Source Subtype", "Source No.", "Source Line No.");
                        SalesLine.SuspendStatusCheck(true); // P80070336
                        SalesLine.Validate("Return Qty. to Receive", "Qty. to Receive");
                        ShowSalesAltQtyLines(SalesLine);
                        Validate("Qty. to Receive", SalesLine."Return Qty. to Receive");
                        SalesLine.GetLotNo;
                        SalesLine.UpdateOnWhseChange;
                        SalesLine.Modify; // P8006444
                    end;
                DATABASE::"Purchase Line":
                    begin
                        PurchLine.Get("Source Subtype", "Source No.", "Source Line No.");
                        PurchLine.SuspendStatusCheck(true); // P80070336
                        PurchLine.Validate("Qty. to Receive", "Qty. to Receive");
                        ShowPurchAltQtyLines(PurchLine);
                        Validate("Qty. to Receive", PurchLine."Qty. to Receive");
                        PurchLine.GetLotNo;
                        PurchLine.UpdateOnWhseChange;
                        PurchLine.Modify; // P8006444
                    end;
                DATABASE::"Transfer Line":
                    begin
                        TransLine.Get("Source No.", "Source Line No.");
                        TransLine.Validate("Qty. to Receive", "Qty. to Receive");
                        ShowTransAltQtyLines(TransLine, "Source Subtype");
                        Validate("Qty. to Receive", TransLine."Qty. to Receive");
                        TransLine.GetLotNo;
                        TransLine.UpdateOnWhseChange("Source Subtype");
                        TransLine.Modify; // P8006444
                    end;
            end;
    end;

    procedure UpdateSalesOnWhsePost(var SalesLine: Record "Sales Line"; Invoice: Boolean)
    begin
        // P8000282A
        with SalesLine do
            if ("Document Type" in ["Document Type"::"Return Order", "Document Type"::"Credit Memo"]) then begin
                if ("Return Qty. to Receive" = 0) then begin
                    Validate("Return Qty. to Receive (Alt.)", 0);
                    if Invoice then
                        Validate("Qty. to Invoice (Alt.)", 0);
                end else begin
                    // P8000629A
                    InitAlternateQtyToHandle("No.", "Alt. Qty. Transaction No.",
                      "Quantity (Base)", "Return Qty. to Receive (Base)", "Return Qty. Received (Base)",
                      "Quantity (Alt.)", "Return Qty. Received (Alt.)", "Return Qty. to Receive (Alt.)");
                    Validate("Return Qty. to Receive (Alt.)");
                    //VALIDATE("Return Qty. to Receive (Alt.)", CalcAltQtyLinesQtyAlt1("Alt. Qty. Transaction No."));
                    // P8000629A
                    if Invoice then
                        SetSalesLineAltQtyToInvoice(SalesLine);
                end;
            end else begin
                if ("Qty. to Ship" = 0) then begin
                    Validate("Qty. to Ship (Alt.)", 0);
                    if Invoice then
                        Validate("Qty. to Invoice (Alt.)", 0);
                end else begin
                    // P8000629A
                    InitAlternateQtyToHandle("No.", "Alt. Qty. Transaction No.",
                      "Quantity (Base)", "Qty. to Ship (Base)", "Qty. Shipped (Base)",
                      "Quantity (Alt.)", "Qty. Shipped (Alt.)", "Qty. to Ship (Alt.)");
                    Validate("Qty. to Ship (Alt.)");
                    //VALIDATE("Qty. to Ship (Alt.)", CalcAltQtyLinesQtyAlt1("Alt. Qty. Transaction No."));
                    // P8000629A
                    if Invoice then
                        SetSalesLineAltQtyToInvoice(SalesLine);
                end;
            end;
    end;

    procedure UpdatePurchOnWhsePost(var PurchLine: Record "Purchase Line"; Invoice: Boolean)
    begin
        // P8000282A
        with PurchLine do
            if ("Document Type" in ["Document Type"::"Return Order", "Document Type"::"Credit Memo"]) then begin
                if ("Return Qty. to Ship" = 0) then begin
                    Validate("Return Qty. to Ship (Alt.)", 0);
                    if Invoice then
                        Validate("Qty. to Invoice (Alt.)", 0);
                end else begin
                    // P8000629A
                    InitAlternateQtyToHandle("No.", "Alt. Qty. Transaction No.",
                      "Quantity (Base)", "Return Qty. to Ship (Base)", "Return Qty. Shipped (Base)",
                      "Quantity (Alt.)", "Return Qty. Shipped (Alt.)", "Return Qty. to Ship (Alt.)");
                    Validate("Return Qty. to Ship (Alt.)");
                    //VALIDATE("Return Qty. to Ship (Alt.)", CalcAltQtyLinesQtyAlt1("Alt. Qty. Transaction No."));
                    // P8000629A
                    if Invoice then
                        SetPurchLineAltQtyToInvoice(PurchLine);
                end;
            end else begin
                if ("Qty. to Receive" = 0) then begin
                    Validate("Qty. to Receive (Alt.)", 0);
                    if Invoice then
                        Validate("Qty. to Invoice (Alt.)", 0);
                end else begin
                    // P8000629A
                    InitAlternateQtyToHandle("No.", "Alt. Qty. Transaction No.",
                      "Quantity (Base)", "Qty. to Receive (Base)", "Qty. Received (Base)",
                      "Quantity (Alt.)", "Qty. Received (Alt.)", "Qty. to Receive (Alt.)");
                    Validate("Qty. to Receive (Alt.)");
                    //VALIDATE("Qty. to Receive (Alt.)", CalcAltQtyLinesQtyAlt1("Alt. Qty. Transaction No."));
                    // P8000629A
                    if Invoice then
                        SetPurchLineAltQtyToInvoice(PurchLine);
                end;
            end;
    end;

    procedure UpdateTransOnWhsePost(var TransLine: Record "Transfer Line"; Direction: Option Outbound,Inbound)
    begin
        // P8000282A
        with TransLine do
            case Direction of
                Direction::Outbound:
                    if ("Qty. to Ship" = 0) then
                        Validate("Qty. to Ship (Alt.)", 0)
                    else
                    // P8000629A
                    begin
                        InitAlternateQtyToHandle("Item No.", "Alt. Qty. Trans. No. (Ship)",
                          "Quantity (Base)", "Qty. to Ship (Base)", "Qty. Shipped (Base)",
                          "Quantity (Alt.)", "Qty. Shipped (Alt.)", "Qty. to Ship (Alt.)");
                        Validate("Qty. to Ship (Alt.)");
                        //VALIDATE("Qty. to Ship (Alt.)", CalcAltQtyLinesQtyAlt1("Alt. Qty. Trans. No. (Ship)"));
                    end;
                // P8000629A
                Direction::Inbound:
                    if ("Qty. to Receive" = 0) then
                        Validate("Qty. to Receive (Alt.)", 0)
                    else
                    // P8000629A
                    begin
                        InitAlternateQtyToHandle("Item No.", "Alt. Qty. Trans. No. (Receive)",
                          "Quantity (Base)", "Qty. to Receive (Base)", "Qty. Received (Base)",
                          "Quantity (Alt.)", "Qty. Received (Alt.)", "Qty. to Receive (Alt.)");
                        Validate("Qty. to Receive (Alt.)");
                        //VALIDATE("Qty. to Receive (Alt.)", CalcAltQtyLinesQtyAlt1("Alt. Qty. Trans. No. (Receive)"));
                    end;
            // P8000629A
            end;
    end;

    procedure ValidateItemJnlAltQtyLine(var ItemJnlLine: Record "Item Journal Line")
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // ValidateItemJnlAltQtyLine
        StartItemJnlAltQtyLine(ItemJnlLine);
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", ItemJnlLine."Alt. Qty. Transaction No.");
        case AltQtyLine.Count of
            0:
                CreateItemJnlAltQtyLine(ItemJnlLine);
            1:
                begin
                    AltQtyLine.Find('-');
                    UpdateItemJnlAltQtyLine(ItemJnlLine, AltQtyLine);
                end;
            else begin
                    Message(Text001);
                    ShowItemJnlAltQtyLines(ItemJnlLine);
                end;
        end;
    end;

    procedure ShowItemJnlAltQtyLines(var ItemJnlLine: Record "Item Journal Line")
    var
        AltQtyLine: Record "Alternate Quantity Line";
        ItemTrackingCode: Record "Item Tracking Code";
        AltQtyTracking: Codeunit "Alt. Qty. Tracking Management";
        AltQtyForm: Page "Alternate Quantity Lines";
        Handled: Boolean;
    begin
        // ShowItemJnlAltQtyLines
        // P80082969
        OnBeforeShowItemJnlAltQtyLines(ItemJnlLine, Handled);
        if Handled then
            exit;
        // P80082969

        Commit;
        StartItemJnlAltQtyLine(ItemJnlLine);
        with ItemJnlLine do begin
            AltQtyForm.SetSource(DATABASE::"Item Journal Line", 0, '', "Journal Template Name",
                                 "Journal Batch Name", "Line No.");
            case true of
                "Phys. Inventory":
                    begin
                        AltQtyForm.SetQty(
                          "Qty. (Phys. Inventory)" * "Qty. per Unit of Measure", FieldCaption("Qty. (Phys. Inventory)"));
                        AltQtyForm.SetLotAndSerial("Lot No.", "Serial No."); // PR3.61
                    end;
                "Entry Type" = "Entry Type"::Output:
                    AltQtyForm.SetQty(
                      "Output Quantity" * "Qty. per Unit of Measure", FieldCaption("Output Quantity")); // P8000392A
                else
                    AltQtyForm.SetQty(
                      Quantity * "Qty. per Unit of Measure", FieldCaption(Quantity)); // P8000392A
            end;
            Item.Get("Item No.");
            if Item."Item Tracking Code" <> '' then begin
                ItemTrackingCode.Get(Item."Item Tracking Code");
                AltQtyForm.SetTracking(ItemTrackingCode."SN Specific Tracking", ItemTrackingCode."Lot Specific Tracking");
            end;
            AltQtyLine.FilterGroup(4);
            AltQtyLine.SetRange("Alt. Qty. Transaction No.", "Alt. Qty. Transaction No.");
            AltQtyLine.FilterGroup(0);
            AltQtyForm.SetTableView(AltQtyLine);
            if "Lot No." <> P800Globals.MultipleLotCode then // P8000043A
                AltQtyForm.SetDefaultLot("Lot No.");           // P8000043A
            if "New Lot No." <> P800Globals.MultipleLotCode then // P8000566A
                AltQtyForm.SetDefaultNewLot("New Lot No.");        // P8000566A
            AltQtyForm.RunModal;
            if "Phys. Inventory" then
                Find;
        end;
        UpdateItemJnlLine(ItemJnlLine);
        AltQtyTracking.UpdateItemJnlTracking(ItemJnlLine);
        //SetitemjnlLineAltQty(itemjnlLine);
        ItemJnlLine.GetLotNo; // P8000043A
        ItemJnlLine.GetNewLotNo; // P8000566A
        OnAfterShowItemJnlAltQtyLines(ItemJnlLine); // P80082969
    end;

    procedure StartItemJnlAltQtyLine(var ItemJnlLine: Record "Item Journal Line")
    begin
        // StartItemJnlAltQtyLine
        with ItemJnlLine do begin
            TestField("Item No.");
            TestField("Value Entry Type", "Value Entry Type"::"Direct Cost");
            GetItem("Item No.");
            Item.TestField("Alternate Unit of Measure");
            Item.TestField("Catch Alternate Qtys.", true);
            if AssignNewTransactionNo("Alt. Qty. Transaction No.") then begin
                if Modify then // PR3.61
                    Commit;      // PR3.61
            end;
        end;
    end;

    procedure CreateItemJnlContAltQtyLine(var ItemJnlLine: Record "Item Journal Line"; LotNo: Code[50]; SerialNo: Code[50]; Qty: Decimal; QtyAlt: Decimal; ContainerID: Code[20]; ContainerLineNo: Integer)
    var
        AltQtyLine: Record "Alternate Quantity Line";
        AltQtyLine2: Record "Alternate Quantity Line";
    begin
        // CreateItemJnlContAltQtyLine
        // PR3.61 Begin
        // P8001324, replace ContainerTransNo with ContainerID, ContainerLineNo
        StartItemJnlAltQtyLine(ItemJnlLine);
        AltQtyLine2.SetRange("Alt. Qty. Transaction No.", ItemJnlLine."Alt. Qty. Transaction No.");
        if AltQtyLine2.Find('+') then;
        CreateAltQtyLine(
          AltQtyLine, ItemJnlLine."Alt. Qty. Transaction No.", AltQtyLine2."Line No." + 10000, DATABASE::"Item Journal Line", 0, '',
          ItemJnlLine."Journal Template Name", ItemJnlLine."Journal Batch Name", ItemJnlLine."Line No.");

        AltQtyLine."Lot No." := LotNo;
        AltQtyLine."Serial No." := SerialNo;
        AltQtyLine.Validate(Quantity, Qty);
        AltQtyLine.Validate("Quantity (Alt.)", QtyAlt);
        AltQtyLine."Container ID" := ContainerID;           // P8001324
        AltQtyLine."Container Line No." := ContainerLineNo; // P8001324
        AltQtyLine.Modify;
        // PR3.61 End
    end;

    local procedure CreateItemJnlAltQtyLine(var ItemJnlLine: Record "Item Journal Line")
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // CreateItemJnlAltQtyLine
        with ItemJnlLine do
            CreateAltQtyLine(
              AltQtyLine, "Alt. Qty. Transaction No.", 10000, DATABASE::"Item Journal Line", 0, '',
              "Journal Template Name", "Journal Batch Name", "Line No.");

        if ItemJnlLine."Lot No." <> P800Globals.MultipleLotCode then // P8000043A
            AltQtyLine."Lot No." := ItemJnlLine."Lot No.";             // P8000043A
        if ItemJnlLine."New Lot No." <> P800Globals.MultipleLotCode then // P8000566A
            AltQtyLine."New Lot No." := ItemJnlLine."New Lot No.";         // P8000566A
        UpdateItemJnlAltQtyLine(ItemJnlLine, AltQtyLine);
    end;

    local procedure UpdateItemJnlAltQtyLine(var ItemJnlLine: Record "Item Journal Line"; var AltQtyLine: Record "Alternate Quantity Line")
    var
        AltQtyTracking: Codeunit "Alt. Qty. Tracking Management";
    begin
        // UpdateItemJnlAltQtyLine
        with ItemJnlLine do begin
            case true of
                "Phys. Inventory":
                    begin
                        AltQtyLine."Lot No." := "Lot No.";       // PR3.61
                        AltQtyLine."Serial No." := "Serial No."; // PR3,61
                        AltQtyLine.Validate("Quantity (Alt.)", "Qty. (Alt.) (Phys. Inventory)");
                        AltQtyLine.Validate("Quantity (Base)", "Qty. (Phys. Inventory)" * "Qty. per Unit of Measure");
                    end;
                "Entry Type" = "Entry Type"::Output:
                    begin
                        AltQtyLine.Validate("Quantity (Alt.)", "Quantity (Alt.)");
                        AltQtyLine.Validate("Quantity (Base)", "Output Quantity" * "Qty. per Unit of Measure"); // P8000392A
                    end;
                else begin
                        AltQtyLine.Validate("Quantity (Alt.)", "Quantity (Alt.)");
                        AltQtyLine.Validate("Quantity (Base)", Quantity * "Qty. per Unit of Measure"); // P8000392A
                    end;
            end;
            AltQtyLine.Modify(true);
        end;
        AltQtyTracking.UpdateItemJnlTracking(ItemJnlLine);
        //SetitemjnlLineAltQty(itejnlLine);
    end;

    procedure UpdateItemJnlLine(var ItemJnlLine: Record "Item Journal Line")
    begin
        // UpdateItemJnlLine
        GetItem(ItemJnlLine."Item No.");         // PR3.60.03
        if not Item."Catch Alternate Qtys." then // PR3.60.03
            exit;                                  // PR3.60.03

        with ItemJnlLine do begin
            if not "Phys. Inventory" then
                Validate("Quantity (Alt.)", CalcAltQtyLinesQtyAlt1("Alt. Qty. Transaction No."));
            if AltQtyLinesExist("Alt. Qty. Transaction No.") then begin
                if ("Qty. per Unit of Measure" = 0) then
                    "Qty. per Unit of Measure" := 1;
                case true of
                    "Phys. Inventory":
                        Validate("Qty. (Phys. Inventory)",
                          Round(CalcAltQtyLinesQtyBase1("Alt. Qty. Transaction No.") / "Qty. per Unit of Measure", 0.00001)); // P8000392A
                    "Entry Type" = "Entry Type"::Output:
                        Validate("Output Quantity",
                           Round(CalcAltQtyLinesQtyBase1("Alt. Qty. Transaction No.") / "Qty. per Unit of Measure", 0.00001)); // P8000392A
                    else
                        Validate(Quantity,
                           Round(CalcAltQtyLinesQtyBase1("Alt. Qty. Transaction No.") / "Qty. per Unit of Measure", 0.00001)); // P8000392A
                end;
            end;
            if "Phys. Inventory" then
                Validate("Qty. (Alt.) (Phys. Inventory)", CalcAltQtyLinesQtyAlt1("Alt. Qty. Transaction No."));
            Modify;
        end;
    end;

    procedure InitTempAltQtyItemJnlLine(ItemJnlLine: Record "Item Journal Line")
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // InitTempAltQtyItemJnlLine
        // PR3.61.01 Begin
        TempAltQtyItemJnlLine.Reset;
        TempAltQtyItemJnlLine.DeleteAll;
        AltQtyLine.SetCurrentKey("Alt. Qty. Transaction No.", "Serial No.", "Lot No.");
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", ItemJnlLine."Alt. Qty. Transaction No.");
        AltQtyLine.SetRange("Lot No.", ItemJnlLine."Lot No.");
        AltQtyLine.SetRange("Serial No.", ItemJnlLine."Serial No.");
        if AltQtyLine.Find('-') then
            repeat
                TempAltQtyItemJnlLine := AltQtyLine;
                TempAltQtyItemJnlLine.Insert;
            until AltQtyLine.Next = 0;
        // PR3.61.01 End
    end;

    procedure ItemJnlLineToItemLedgEntry(var ItemJnlLine: Record "Item Journal Line"; var ItemLedgEntry: Record "Item Ledger Entry")
    var
        RemQty: Decimal;
        RemQtyAlt: Decimal;
        AltQtyEntry: Record "Alternate Quantity Entry";
        Negate: Boolean;
    begin
        // ItemJnlLineToItemLedgEntry
        // PR3.70.03 Begin
        Negate := (ItemLedgEntry."Entry Type" in [ItemLedgEntry."Entry Type"::Consumption,
          ItemLedgEntry."Entry Type"::Sale, ItemLedgEntry."Entry Type"::"Negative Adjmt."]) or
          // P800127049
          ((ItemLedgEntry."Document Type" = ItemLedgEntry."Document Type"::"Inventory Receipt") and (ItemLedgEntry.Quantity < 0)) or
          ((ItemLedgEntry."Document Type" = ItemLedgEntry."Document Type"::"Inventory Shipment") and (ItemLedgEntry.Quantity > 0)) or
          // P800127049
          ((ItemLedgEntry."Entry Type" = ItemLedgEntry."Entry Type"::Transfer) and
           ((ItemLedgEntry.Quantity < 0) or (ItemLedgEntry."Quantity (Alt.)" < 0)));
        // PR3.70.03 End

        RemQty := Abs(ItemLedgEntry.Quantity);
        RemQtyAlt := Abs(ItemLedgEntry."Quantity (Alt.)");
        if TempAltQtyItemJnlLine.Find('-') then begin
            AltQtyEntry."Table No." := DATABASE::"Item Ledger Entry";
            AltQtyEntry."Source Line No." := ItemLedgEntry."Entry No.";
            AltQtyEntry."Lot No." := ItemLedgEntry."Lot No.";
            AltQtyEntry."Serial No." := ItemLedgEntry."Serial No.";
            repeat
                AltQtyEntry."Line No." += 10000;
                SetLesserAmount(TempAltQtyItemJnlLine."Quantity (Base)", RemQty, AltQtyEntry."Quantity (Base)");
                SetLesserAmount(TempAltQtyItemJnlLine."Quantity (Alt.)", RemQtyAlt, AltQtyEntry."Quantity (Alt.)");
                if Negate then begin
                    AltQtyEntry."Quantity (Base)" *= -1;
                    AltQtyEntry."Quantity (Alt.)" *= -1;
                end;
                if (not (TempAltQtyItemJnlLine."Table No." in [DATABASE::"Sales Line", DATABASE::"Purchase Line"])) and
                  ((TempAltQtyItemJnlLine."Table No." <> DATABASE::"Item Journal Line") or
                   (ItemJnlLine."Entry Type" <> ItemJnlLine."Entry Type"::Output))
                then begin
                    AltQtyEntry."Invoiced Qty. (Base)" := AltQtyEntry."Quantity (Base)";
                    AltQtyEntry."Invoiced Qty. (Alt.)" := AltQtyEntry."Quantity (Alt.)";
                end;
                AltQtyEntry.Insert;

                if (TempAltQtyItemJnlLine."Quantity (Base)" = 0) and (TempAltQtyItemJnlLine."Quantity (Alt.)" = 0) then
                    TempAltQtyItemJnlLine.Delete
                else
                    TempAltQtyItemJnlLine.Modify;
            until (TempAltQtyItemJnlLine.Next = 0) or ((RemQty = 0) and (RemQtyAlt = 0));
        end;
    end;

    // P800127049
    procedure ValidateInvtDocAltQtyLine(var InvtDocLine: Record "Invt. Document Line")
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        StartInvtDocAltQtyLine(InvtDocLine);
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", InvtDocLine."FOOD Alt. Qty. Transaction No.");
        case AltQtyLine.Count() of
            0:
                CreateInvtDocAltQtyLine(InvtDocLine);
            1:
                begin
                    AltQtyLine.FindFirst();
                    UpdateInvtDocAltQtyLine(InvtDocLine, AltQtyLine);
                end;
            else begin
                    Message(Text001);
                    ShowInvtDocAltQtyLines(InvtDocLine);
                end;
        end;
    end;

    // P800127049
    procedure ShowInvtDocAltQtyLines(var InvtDocLine: Record "Invt. Document Line")
    var
        AltQtyLine: Record "Alternate Quantity Line";
        ItemTrackingCode: Record "Item Tracking Code";
        AltQtyTracking: Codeunit "Alt. Qty. Tracking Management";
        AltQtyForm: Page "Alternate Quantity Lines";
    begin
        Commit();
        StartInvtDocAltQtyLine(InvtDocLine);
        AltQtyForm.SetSource(DATABASE::"Invt. Document Line", InvtDocLine."Document Type".AsInteger(), InvtDocLine."Document No.", '', '', InvtDocLine."Line No.");
        AltQtyForm.SetQty(
          InvtDocLine.Quantity * InvtDocLine."Qty. per Unit of Measure", InvtDocLine.FieldCaption(Quantity));
        Item.Get(InvtDocLine."Item No.");
        if Item."Item Tracking Code" <> '' then begin
            ItemTrackingCode.Get(Item."Item Tracking Code");
            AltQtyForm.SetTracking(ItemTrackingCode."SN Specific Tracking", ItemTrackingCode."Lot Specific Tracking");
        end;
        AltQtyLine.FilterGroup(4);
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", InvtDocLine."FOOD Alt. Qty. Transaction No.");
        AltQtyLine.FilterGroup(0);
        AltQtyForm.SetTableView(AltQtyLine);
        if InvtDocLine."FOOD Lot No." <> P800Globals.MultipleLotCode() then
            AltQtyForm.SetDefaultLot(InvtDocLine."FOOD Lot No.");
        AltQtyForm.RunModal();
        UpdateInvtDocLine(InvtDocLine);
        AltQtyTracking.UpdateInvtDocTracking(InvtDocLine);
        InvtDocLine.GetLotNo();
    end;

    // P800127049
    procedure StartInvtDocAltQtyLine(var InvtDocLine: Record "Invt. Document Line")
    begin
        InvtDocLine.TestField("Item No.");
        GetItem(InvtDocLine."Item No.");
        Item.TestField("Alternate Unit of Measure");
        Item.TestField("Catch Alternate Qtys.", true);
        if AssignNewTransactionNo(InvtDocLine."FOOD Alt. Qty. Transaction No.") then begin
            if InvtDocLine.Modify() then
                Commit();
        end;
    end;

    // P800127049
    local procedure CreateInvtDocAltQtyLine(var InvtDocLine: Record "Invt. Document Line")
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        CreateAltQtyLine(
          AltQtyLine, InvtDocLine."FOOD Alt. Qty. Transaction No.", 10000, DATABASE::"Invt. Document Line",
            InvtDocLine."Document Type", InvtDocLine."Document No.", '', '', InvtDocLine."Line No.");

        if InvtDocLine."FOOD Lot No." <> P800Globals.MultipleLotCode() then
            AltQtyLine."Lot No." := InvtDocLine."FOOD Lot No.";
        UpdateInvtDocAltQtyLine(InvtDocLine, AltQtyLine);
    end;

    // P800127049
    local procedure UpdateInvtDocAltQtyLine(var InvtDocLine: Record "Invt. Document Line"; var AltQtyLine: Record "Alternate Quantity Line")
    var
        AltQtyTracking: Codeunit "Alt. Qty. Tracking Management";
    begin
        AltQtyLine.Validate("Quantity (Alt.)", InvtDocLine."FOOD Quantity (Alt.)");
        AltQtyLine.Validate("Quantity (Base)", InvtDocLine.Quantity * InvtDocLine."Qty. per Unit of Measure");
        AltQtyLine.Modify(true);
        AltQtyTracking.UpdateInvtDocTracking(InvtDocLine);
    end;

    // P800127049
    procedure UpdateInvtDocLine(var InvtDocLine: Record "Invt. Document Line")
    begin
        GetItem(InvtDocLine."Item No.");
        if not Item."Catch Alternate Qtys." then
            exit;

        InvtDocLine.Validate("FOOD Quantity (Alt.)", CalcAltQtyLinesQtyAlt1(InvtDocLine."FOOD Alt. Qty. Transaction No."));
        if AltQtyLinesExist(InvtDocLine."FOOD Alt. Qty. Transaction No.") then begin
            if (InvtDocLine."Qty. per Unit of Measure" = 0) then
                InvtDocLine."Qty. per Unit of Measure" := 1;
            InvtDocLine.Validate(Quantity,
               Round(CalcAltQtyLinesQtyBase1(InvtDocLine."FOOD Alt. Qty. Transaction No.") / InvtDocLine."Qty. per Unit of Measure", 0.00001));
        end;
        InvtDocLine.Modify();
    end;

    // P800127049
    procedure InvtDocLineToPostedInvtDocLine(InvtDocLine: Record "Invt. Document Line"; PostedInvtDocLine: Variant)
    var
        InvtReceiptLine: Record "Invt. Receipt Line";
        InvtShipmentLine: Record "Invt. Shipment Line";
        AltQtyEntry: Record "Alternate Quantity Entry";
        TableNo: Integer;
        DocNo: Code[20];
        DocLineNo: Integer;
    begin
        if InvtDocLine."FOOD Alt. Qty. Transaction No." = 0 then
            exit;

        case InvtDocLine."Document Type" of
            InvtDocLine."Document Type"::Receipt:
                begin
                    InvtReceiptLine := PostedInvtDocLine;
                    TableNo := Database::"Invt. Receipt Line";
                    DocNo := InvtReceiptLine."Document No.";
                    DocLineNo := InvtReceiptLine."Line No.";
                end;
            InvtDocLine."Document Type"::Shipment:
                begin
                    InvtShipmentLine := PostedInvtDocLine;
                    TableNo := Database::"Invt. Shipment Line";
                    DocNo := InvtShipmentLine."Document No.";
                    DocLineNo := InvtShipmentLine."Line No.";
                end;
        end;

        AltQtyLinesToAltQtyEntries1(InvtDocLine."FOOD Alt. Qty. Transaction No.", TableNo, DocNo, DocLineNo, 0, false, false);

        AltQtyEntry.SetRange("Table No.", TableNo);
        AltQtyEntry.SetRange("Document No.", DocNo);
        AltQtyEntry.SetRange("Source Line No.", DocLineNo);
        if AltQtyEntry.FindFirst() then
            repeat
                AltQtyEntry."Invoiced Qty. (Base)" := AltQtyEntry."Quantity (Base)";
                AltQtyEntry."Invoiced Qty. (Alt.)" := AltQtyEntry."Quantity (Alt.)";
                AltQtyEntry.Modify();
            until AltQtyEntry.Next() = 0;
    end;

    // P800127049
    procedure ShowPostedInvtDocLineAltQtyEntries(PostedInvtDocLine: Variant)
    var
        PostedInvtDocLineRecordRef: RecordRef;
        InvtReceiptLine: Record "Invt. Receipt Line";
        InvtShipmentLine: Record "Invt. Shipment Line";
        AltQtyEntry: Record "Alternate Quantity Entry";
        TableNo: Integer;
        DocNo: Code[20];
        DocLineNo: Integer;
    begin
        PostedInvtDocLineRecordRef.GetTable(PostedInvtDocLine);
        case PostedInvtDocLineRecordRef.Number of
            Database::"Invt. Receipt Line":
                begin
                    InvtReceiptLine := PostedInvtDocLine;
                    TableNo := Database::"Invt. Receipt Line";
                    DocNo := InvtReceiptLine."Document No.";
                    DocLineNo := InvtReceiptLine."Line No.";
                end;
            Database::"Invt. Shipment Line":
                begin
                    InvtShipmentLine := PostedInvtDocLine;
                    TableNo := Database::"Invt. Shipment Line";
                    DocNo := InvtShipmentLine."Document No.";
                    DocLineNo := InvtShipmentLine."Line No.";
                end;
        end;

        AltQtyEntry.SetRange("Table No.", TableNo);
        AltQtyEntry.SetRange("Document No.", DocNo);
        AltQtyEntry.SetRange("Source Line No.", DocLineNo);
        PAGE.RunModal(0, AltQtyEntry);
    end;

    procedure SetLesserAmount(var Amt1: Decimal; var Amt2: Decimal; var TargetAmt: Decimal)
    begin
        // SetLesserAmount
        if Amt1 < Amt2 then
            TargetAmt := Amt1
        else
            TargetAmt := Amt2;
        Amt1 -= TargetAmt;
        Amt2 -= TargetAmt;
    end;

    procedure CreatePhysAltQtyEntries(var ItemJnlLine: Record "Item Journal Line"; var ItemLedgEntry: Record "Item Ledger Entry")
    begin
        // CreatePhysAltQtyEntries
        with ItemJnlLine do begin
            GetItem("Item No.");
            if Item.TrackAlternateUnits() and Item."Catch Alternate Qtys." then
                InsertPhysAltQtyEntry(ItemLedgEntry, 10000, ItemLedgEntry.Quantity, ItemLedgEntry."Quantity (Alt.)")
        end;
    end;

    local procedure InsertPhysAltQtyEntry(var ItemLedgEntry: Record "Item Ledger Entry"; LineNo: Integer; QtyBase: Decimal; QtyAlt: Decimal)
    var
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // InsertPhysAltQtyEntry
        with AltQtyEntry do begin
            "Table No." := DATABASE::"Item Ledger Entry";
            "Source Line No." := ItemLedgEntry."Entry No.";
            "Line No." := LineNo;
            "Lot No." := ItemLedgEntry."Lot No.";
            "Serial No." := ItemLedgEntry."Serial No.";
            "Quantity (Base)" := QtyBase;
            "Quantity (Alt.)" := QtyAlt;
            "Invoiced Qty. (Base)" := QtyBase;
            "Invoiced Qty. (Alt.)" := QtyAlt;
            Insert;
        end;
    end;

    procedure ItemJnlLineToPhysInvtLedgEntry(var ItemJnlLine: Record "Item Journal Line"; var PhysInvtLedgEntry: Record "Phys. Inventory Ledger Entry")
    begin
        // ItemJnlLineToPhysInvtLedgEntry
        with ItemJnlLine do
            AltQtyLinesToAltQtyEntries1(
              "Alt. Qty. Transaction No.", DATABASE::"Phys. Inventory Ledger Entry", '', PhysInvtLedgEntry."Entry No.", 0,  // P8000504A
              (PhysInvtLedgEntry."Qty. (Phys. Inventory)" < 0) or
              (PhysInvtLedgEntry."Qty. (Alt.) (Phys. Inventory)" < 0), false);
    end;

    procedure UpdateOutputAltQtyEntries(ItemLedgEntryNo: Integer)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ItemLedgAltQtyEntry: Record "Alternate Quantity Entry";
        RemQtyBase: Decimal;
        RemQtyAlt: Decimal;
    begin
        // UpdateOutputAltQtyEntries
        ItemLedgEntry.Get(ItemLedgEntryNo);
        if (ItemLedgEntry."Invoiced Quantity" <> 0) then
            with ItemLedgAltQtyEntry do begin
                SetRange("Table No.", DATABASE::"Item Ledger Entry");
                SetRange("Source Line No.", ItemLedgEntry."Entry No.");
                if Find('-') then begin
                    RemQtyBase := ItemLedgEntry."Invoiced Quantity";
                    RemQtyAlt := ItemLedgEntry."Invoiced Quantity (Alt.)";
                    while (RemQtyBase <> 0) do begin
                        if (Abs(RemQtyBase) < Abs("Quantity (Base)")) then begin
                            "Invoiced Qty. (Base)" := RemQtyBase;
                            "Invoiced Qty. (Alt.)" := RemQtyAlt;
                            RemQtyBase := 0;
                        end else begin
                            "Invoiced Qty. (Base)" := "Quantity (Base)";
                            "Invoiced Qty. (Alt.)" := "Quantity (Alt.)";
                            RemQtyBase := RemQtyBase - "Quantity (Base)";
                            RemQtyAlt := RemQtyAlt - "Quantity (Alt.)";
                        end;
                        Modify;
                        if (Next = 0) then
                            RemQtyBase := 0;
                    end;
                end;
            end;
    end;

    procedure DeleteItemJnlAltQtyLines(var ItemJnlLine: Record "Item Journal Line")
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // DeleteItemJnlAltQtyLines
        with ItemJnlLine do begin
            if ("Alt. Qty. Transaction No." = 0) then
                exit;
            AltQtyLine.SetCurrentKey("Alt. Qty. Transaction No.", "Serial No.", "Lot No.");
            AltQtyLine.SetRange("Alt. Qty. Transaction No.", "Alt. Qty. Transaction No.");
            AltQtyLine.SetRange("Serial No.", "Serial No.");
            AltQtyLine.SetRange("Lot No.", "Lot No.");
            if AltQtyLine.Find('-') then
                if (AltQtyLine."Table No." = DATABASE::"Item Journal Line") then
                    AltQtyLine.DeleteAll;
        end;
    end;

    procedure TestDropShipAltQtys(AltQtyTransactionNo: Integer; AssocTableCaption: Text[30]; AssocOrderNo: Code[20]; PostingTableCaption: Text[30])
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // TestDropShipAltQtys
        if (AltQtyTransactionNo = 0) then
            exit;
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", AltQtyTransactionNo);
        if AltQtyLine.Find('-') then
            Error(Text008, AltQtyLine.TableCaption,
                  AssocTableCaption, AssocOrderNo, PostingTableCaption);
    end;

    procedure DropShipRcptToReceiptLine(var ReceiptLine: Record "Purch. Rcpt. Line")
    var
        ItemEntryRelation: Record "Item Entry Relation";
        LineNo: Integer;
    begin
        // DropShipLineToReceiptLine
        if ReceiptLine."Item Rcpt. Entry No." <> 0 then // P8000505A
            CopyDropShipAltQtys(
              ReceiptLine."Item Rcpt. Entry No.", DATABASE::"Purch. Rcpt. Line",
              ReceiptLine."Document No.", ReceiptLine."Line No.", LineNo, false) // P8000505A
        // P8000505A
        else begin
            ItemEntryRelation.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Ref. No.");
            ItemEntryRelation.SetRange("Source Type", DATABASE::"Purch. Rcpt. Line");
            ItemEntryRelation.SetRange("Source ID", ReceiptLine."Document No.");
            ItemEntryRelation.SetRange("Source Ref. No.", ReceiptLine."Line No.");
            if ItemEntryRelation.FindSet then
                repeat
                    CopyDropShipAltQtys(
                      ItemEntryRelation."Item Entry No.", DATABASE::"Purch. Rcpt. Line",
                      ReceiptLine."Document No.", ReceiptLine."Line No.", LineNo, false);
                until ItemEntryRelation.Next = 0;
        end;
        // P8000505A
    end;

    procedure DropShipShptToShipmentLine(var ShipmentLine: Record "Sales Shipment Line")
    var
        ItemEntryRelation: Record "Item Entry Relation";
        LineNo: Integer;
    begin
        // DropShipShptToShipmentLine
        if ShipmentLine."Item Shpt. Entry No." <> 0 then // P8000505A
            CopyDropShipAltQtys(
              ShipmentLine."Item Shpt. Entry No.", DATABASE::"Sales Shipment Line",
              ShipmentLine."Document No.", ShipmentLine."Line No.", LineNo, true) // P8000505A
        // P8000505A
        else begin
            ItemEntryRelation.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Ref. No.");
            ItemEntryRelation.SetRange("Source Type", DATABASE::"Sales Shipment Line");
            ItemEntryRelation.SetRange("Source ID", ShipmentLine."Document No.");
            ItemEntryRelation.SetRange("Source Ref. No.", ShipmentLine."Line No.");
            if ItemEntryRelation.FindSet then
                repeat
                    CopyDropShipAltQtys(
                      ItemEntryRelation."Item Entry No.", DATABASE::"Sales Shipment Line",
                      ShipmentLine."Document No.", ShipmentLine."Line No.", LineNo, true) // P8000505A
                until ItemEntryRelation.Next = 0;
        end;
        // P8000505A
    end;

    local procedure CopyDropShipAltQtys(ItemLedgEntryNo: Integer; ToTableNo: Integer; ToDocumentNo: Code[20]; ToLineNo: Integer; var LineNo: Integer; NegateQtys: Boolean)
    var
        EntryAltQtyEntry: Record "Alternate Quantity Entry";
        LineAltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // CopyDropShipAltQtys
        // P8000505A - add parameter for LineNo
        with EntryAltQtyEntry do begin
            SetRange("Table No.", DATABASE::"Item Ledger Entry");
            SetRange("Source Line No.", ItemLedgEntryNo);
            if Find('-') then
                repeat
                    LineNo += 10000; // P8000505A
                    LineAltQtyEntry := EntryAltQtyEntry;
                    LineAltQtyEntry."Table No." := ToTableNo;
                    LineAltQtyEntry."Document No." := ToDocumentNo;
                    LineAltQtyEntry."Source Line No." := ToLineNo;
                    LineAltQtyEntry."Line No." := LineNo; // P8000505A
                    if NegateQtys then begin
                        LineAltQtyEntry."Quantity (Base)" := -LineAltQtyEntry."Quantity (Base)";
                        LineAltQtyEntry."Quantity (Alt.)" := -LineAltQtyEntry."Quantity (Alt.)";
                    end;
                    LineAltQtyEntry.Insert;
                until (Next = 0);
        end;
    end;

    local procedure CalcLineWeights(AltQtyTransactionNo: Integer; QtyPerUnitOfMeasure: Decimal; Qty: Decimal; QtyBase: Decimal; QtyAlt: Decimal; var NetWeight: Decimal; var TotalNetWeight: Decimal)
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        UnitOfMeasure: Record "Unit of Measure";
        WeightUOMFound: Boolean;
        UseAltQtys: Boolean;
    begin
        // CalcLineWeights
        with ItemUnitOfMeasure do begin
            if Item.TrackAlternateUnits() then begin
                Get(Item."No.", Item."Alternate Unit of Measure");
                CalcFields(Type);
                WeightUOMFound := (Type = Type::Weight);
            end;
            if WeightUOMFound then
                UseAltQtys := (QtyBase = CalcAltQtyLinesQtyBase1(AltQtyTransactionNo))
            else begin
                SetRange("Item No.", Item."No.");
                SetRange(Type, Type::Weight);
                WeightUOMFound := Find('-');
            end;
            if not WeightUOMFound then begin
                NetWeight := Item."Net Weight" * QtyPerUnitOfMeasure;
                TotalNetWeight := NetWeight * Qty;
            end else begin
                UnitOfMeasure.Get(Code);
                NetWeight :=
                  (UnitOfMeasure."Base per Unit of Measure" / "Qty. per Unit of Measure") * QtyPerUnitOfMeasure;
                if not UseAltQtys then
                    TotalNetWeight := NetWeight * Qty
                else begin
                    TotalNetWeight := UnitOfMeasure."Base per Unit of Measure" * QtyAlt;
                    if (QtyBase <> 0) then
                        NetWeight := (TotalNetWeight / QtyBase) * QtyPerUnitOfMeasure;
                end;
            end;
        end;
    end;

    procedure GetNewAltQtyTransactionNo(var AltQtyTransactionNo: Integer)
    var
        P800UtilityFns: Codeunit "Process 800 Utility Functions";
    begin
        // GetNewAltQtyTransactionNo
        // P8001224
        //InvtSetup.LOCKTABLE;
        //InvtSetup.GET;
        //InvtSetup."Last Alt. Qty. Transaction No." := InvtSetup."Last Alt. Qty. Transaction No." + 1;
        //InvtSetup.MODIFY;
        //AltQtyTransactionNo := InvtSetup."Last Alt. Qty. Transaction No.";
        AltQtyTransactionNo := P800UtilityFns.GetNextTransNo;
        // P8001224
    end;

    procedure AssignNewTransactionNo(var AltQtyTransactionNo: Integer): Boolean
    begin
        // AssignNewTransactionNo
        if (AltQtyTransactionNo <> 0) then
            exit(false);
        GetNewAltQtyTransactionNo(AltQtyTransactionNo);
        exit(true);
    end;

    procedure CreateAltQtyLine(var AltQtyLine: Record "Alternate Quantity Line"; AltQtyTransactionNo: Integer; LineNo: Integer; TableNo: Integer; DocType: Integer; DocNo: Code[20]; JnlTemplateName: Code[10]; JnlBatchName: Code[10]; SourceLineNo: Integer)
    begin
        // CreateAltQtyLine
        with AltQtyLine do begin
            "Alt. Qty. Transaction No." := AltQtyTransactionNo;
            "Line No." := LineNo;
            "Table No." := TableNo;
            "Document Type" := DocType;
            "Document No." := DocNo;
            "Journal Template Name" := JnlTemplateName;
            "Journal Batch Name" := JnlBatchName;
            "Source Line No." := SourceLineNo;
            Insert(true);
        end;
    end;

    local procedure AltQtyLinesToAltQtyEntries1(AltQtyTransactionNo: Integer; TableNo: Integer; DocNo: Code[20]; SourceLineNo: Integer; FldNo: Integer; NegateQtys: Boolean; RemoveLines: Boolean)
    var
        AltQtyLine: Record "Alternate Quantity Line";
        AltQtyEntry: Record "Alternate Quantity Entry";
        LineNo: Integer;
    begin
        // AltQtyLinesToAltQtyEntries1
        // P8000504A - add parameter for FldNo
        if (AltQtyTransactionNo = 0) then
            exit;
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", AltQtyTransactionNo);
        if AltQtyLine.Find('-') then begin
            // P8000504A
            if FldNo <> 0 then begin
                AltQtyEntry.SetRange("Table No.", TableNo);
                AltQtyEntry.SetRange("Document No.", DocNo);
                AltQtyEntry.SetRange("Source Line No.", SourceLineNo);
                if AltQtyEntry.FindLast then
                    LineNo := AltQtyEntry."Line No."
                else
                    LineNo := 0;
            end;
            // P8000504A
            repeat
                InitAltQtyEntry(AltQtyEntry, AltQtyLine);
                AltQtyEntry."Table No." := TableNo;
                AltQtyEntry."Document No." := DocNo;
                AltQtyEntry."Source Line No." := SourceLineNo;
                // P8000504A
                if FldNo <> 0 then begin
                    LineNo += 10000;
                    AltQtyEntry."Line No." := LineNo;
                    AltQtyEntry."Field No." := FldNo;
                end;
                // P8000504A
                if NegateQtys then begin
                    AltQtyEntry."Quantity (Base)" := -AltQtyEntry."Quantity (Base)";
                    AltQtyEntry."Quantity (Alt.)" := -AltQtyEntry."Quantity (Alt.)";
                    AltQtyEntry."Invoiced Qty. (Base)" := -AltQtyEntry."Invoiced Qty. (Base)";
                    AltQtyEntry."Invoiced Qty. (Alt.)" := -AltQtyEntry."Invoiced Qty. (Alt.)";
                end;
                AltQtyEntry.Insert;
            until (AltQtyLine.Next = 0);
            if RemoveLines then
                AltQtyLine.DeleteAll;
        end;
    end;

    local procedure AltQtyLinesToAltQtyEntries2(AltQtyTransactionNo: Integer; SerialNo: Code[50]; LotNo: Code[50]; TableNo: Integer; DocNo: Code[20]; SourceLineNo: Integer; NegateQtys: Boolean; RemoveLines: Boolean)
    var
        AltQtyLine: Record "Alternate Quantity Line";
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // AltQtyLinesToAltQtyEntries2
        if (AltQtyTransactionNo = 0) then
            exit;
        AltQtyLine.SetCurrentKey("Alt. Qty. Transaction No.", "Serial No.", "Lot No.");
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", AltQtyTransactionNo);
        AltQtyLine.SetRange("Serial No.", SerialNo);
        AltQtyLine.SetRange("Lot No.", LotNo);
        if AltQtyLine.Find('-') then begin
            repeat
                InitAltQtyEntry(AltQtyEntry, AltQtyLine);
                AltQtyEntry."Table No." := TableNo;
                AltQtyEntry."Document No." := DocNo;
                AltQtyEntry."Source Line No." := SourceLineNo;
                if NegateQtys then begin
                    AltQtyEntry."Quantity (Base)" := -AltQtyEntry."Quantity (Base)";
                    AltQtyEntry."Quantity (Alt.)" := -AltQtyEntry."Quantity (Alt.)";
                    AltQtyEntry."Invoiced Qty. (Base)" := -AltQtyEntry."Invoiced Qty. (Base)";
                    AltQtyEntry."Invoiced Qty. (Alt.)" := -AltQtyEntry."Invoiced Qty. (Alt.)";
                end;
                AltQtyEntry.Insert;
            until (AltQtyLine.Next = 0);
            if RemoveLines then
                AltQtyLine.DeleteAll;
        end;
    end;

    local procedure UpdateAltQtyEntries(TableNo: Integer; DocNo: Code[20]; SourceLineNo: Integer; OrderLineNo: Integer; PostedItemLedgEntryNo: Integer)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        AltQtyEntry: Record "Alternate Quantity Entry";
        ItemLedgAltQtyEntry: Record "Alternate Quantity Entry";
        MoreEntries: Boolean;
        RemQtyBase: Decimal;
        RemQtyAlt: Decimal;
        ItemLedgerAltQtyLineNo: Integer;
    begin
        // UpdateAltQtyEntries
        ItemLedgerEntry.Get(PostedItemLedgEntryNo);
        RemQtyBase := ItemLedgerEntry."Invoiced Quantity";
        RemQtyAlt := ItemLedgerEntry."Invoiced Quantity (Alt.)";
        with AltQtyEntry do begin
            SetRange("Table No.", TableNo);
            SetRange("Document No.", DocNo);
            SetRange("Source Line No.", SourceLineNo);
            SetRange("Serial No.", ItemLedgerEntry."Serial No.");
            SetRange("Lot No.", ItemLedgerEntry."Lot No.");
            MoreEntries := Find('-');
            while MoreEntries and (RemQtyBase <> 0) do begin
                InitTempInvoiceEntry(AltQtyEntry, OrderLineNo);
                if (Abs(RemQtyBase) < Abs("Quantity (Base)")) then begin
                    "Invoiced Qty. (Base)" := RemQtyBase;
                    "Invoiced Qty. (Alt.)" := RemQtyAlt;
                    RemQtyBase := 0;
                end else begin
                    "Invoiced Qty. (Base)" := "Quantity (Base)";
                    "Invoiced Qty. (Alt.)" := "Quantity (Alt.)";
                    RemQtyBase := RemQtyBase - "Quantity (Base)";
                    RemQtyAlt := RemQtyAlt - "Quantity (Alt.)";
                end;
                Modify;
                InsertTempInvoiceEntry(AltQtyEntry);
                ItemLedgerAltQtyLineNo += 10000; // PR3.61.01
                ItemLedgAltQtyEntry.Get(DATABASE::"Item Ledger Entry", '',
                                        PostedItemLedgEntryNo, ItemLedgerAltQtyLineNo); // PR3.61.01
                if (ItemLedgAltQtyEntry."Quantity (Base)" > 0) then begin
                    ItemLedgAltQtyEntry."Invoiced Qty. (Base)" := "Invoiced Qty. (Base)";
                    ItemLedgAltQtyEntry."Invoiced Qty. (Alt.)" := "Invoiced Qty. (Alt.)";
                end else begin
                    ItemLedgAltQtyEntry."Invoiced Qty. (Base)" := -"Invoiced Qty. (Base)";
                    ItemLedgAltQtyEntry."Invoiced Qty. (Alt.)" := -"Invoiced Qty. (Alt.)";
                end;
                ItemLedgAltQtyEntry.Modify;
                MoreEntries := (Next <> 0);
            end;
        end;
    end;

    procedure UpdateAltQtyEntriesInvQty(var TempValueEntryRelation: Record "Value Entry Relation"; RowID: Text[100]; ItemLedgerEntryNo: Integer)
    var
        AltQtyEntry: Record "Alternate Quantity Entry";
        ValueEntry: Record "Value Entry";
    begin
        // UpdateAltQtyEntriesInvQty
        // PR3.61.01 Begin
        AltQtyEntry.SetRange("Table No.", DATABASE::"Item Ledger Entry");
        TempValueEntryRelation.SetRange("Source RowId", RowID);
        if TempValueEntryRelation.Find('-') then begin
            repeat
                ValueEntry.Get(TempValueEntryRelation."Value Entry No.");
                AltQtyEntry.SetRange("Source Line No.", ValueEntry."Item Ledger Entry No.");
                if AltQtyEntry.Find('-') then
                    repeat
                        AltQtyEntry."Invoiced Qty. (Base)" := AltQtyEntry."Quantity (Base)";
                        AltQtyEntry."Invoiced Qty. (Alt.)" := AltQtyEntry."Quantity (Alt.)";
                        AltQtyEntry.Modify;
                    until AltQtyEntry.Next = 0;
            until TempValueEntryRelation.Next = 0
        end else begin
            AltQtyEntry.SetRange("Source Line No.", ItemLedgerEntryNo);
            if AltQtyEntry.Find('-') then
                repeat
                    AltQtyEntry."Invoiced Qty. (Base)" := AltQtyEntry."Quantity (Base)";
                    AltQtyEntry."Invoiced Qty. (Alt.)" := AltQtyEntry."Quantity (Alt.)";
                    AltQtyEntry.Modify;
                until AltQtyEntry.Next = 0;
        end;
        // PR3.61.01 End
    end;

    local procedure CalcAltQtyToInvoice(ItemNo: Code[20]; AltQtyTransactionNo: Integer; QtyToInvBase: Decimal; QtyToPostBase: Decimal; var QtyToInvAlt: Decimal; var PostedQtyToInvBase: Decimal) TotalQtyToInvAlt: Decimal
    var
        RemQtyToInvBase: Decimal;
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // CalcAltQtyToInvoice
        if (Abs(QtyToInvBase) <= Abs(QtyToPostBase)) then
            PostedQtyToInvBase := 0
        else begin
            PostedQtyToInvBase := QtyToInvBase - QtyToPostBase;
            QtyToInvBase := QtyToPostBase;
        end;

        if (QtyToInvBase = 0) then
            QtyToInvAlt := 0
        else
            if (QtyToPostBase <> CalcAltQtyLinesQtyBase1(AltQtyTransactionNo)) then
                QtyToInvAlt := CalcAltQty(ItemNo, QtyToInvBase)
            else
                if (QtyToInvBase = QtyToPostBase) then
                    QtyToInvAlt := CalcAltQtyLinesQtyAlt1(AltQtyTransactionNo)
                else
                    with AltQtyLine do begin
                        SetRange("Alt. Qty. Transaction No.", AltQtyTransactionNo);
                        QtyToInvAlt := 0;
                        if Find('-') then
                            repeat
                                if (Abs(QtyToInvBase) < Abs("Quantity (Base)")) then begin
                                    QtyToInvAlt := QtyToInvAlt + "Quantity (Alt.)" * (QtyToInvBase / "Quantity (Base)");
                                    QtyToInvBase := 0;
                                end else begin
                                    QtyToInvAlt := QtyToInvAlt + "Quantity (Alt.)";
                                    QtyToInvBase := QtyToInvBase - "Quantity (Base)";
                                end;
                            until (QtyToInvBase = 0) or (Next = 0);
                    end;
    end;

    local procedure CalcAltQtyToInvoicePosted(var AltQtyEntry: Record "Alternate Quantity Entry"; var QtyBase: Decimal; var QtyAlt: Decimal): Decimal
    var
        QtyNotInvoicedBase: Decimal;
    begin
        // CalcAltQtyToInvPosted
        with AltQtyEntry do
            if Find('-') then
                repeat
                    QtyNotInvoicedBase := "Quantity (Base)" - "Invoiced Qty. (Base)";
                    if (QtyNotInvoicedBase <> 0) then
                        if (Abs(QtyBase) < Abs(QtyNotInvoicedBase)) then begin
                            QtyAlt := QtyAlt +
                              ("Quantity (Alt.)" - "Invoiced Qty. (Alt.)") * (QtyBase / QtyNotInvoicedBase);
                            QtyBase := 0;
                        end else begin
                            QtyAlt := QtyAlt + ("Quantity (Alt.)" - "Invoiced Qty. (Alt.)");
                            QtyBase := QtyBase - QtyNotInvoicedBase;
                        end;
                until (QtyBase = 0) or (Next = 0);
    end;

    local procedure InitTempInvoiceEntry(var OldAltQtyEntry: Record "Alternate Quantity Entry"; OrderLineNo: Integer)
    begin
        // InitTempInvoiceEntry
        TempAltQtyInvoiceEntry := OldAltQtyEntry;
        TempAltQtyInvoiceEntry."Source Line No." := OrderLineNo;
    end;

    local procedure InsertTempInvoiceEntry(var NewAltQtyEntry: Record "Alternate Quantity Entry")
    begin
        // InsertTempInvoiceEntry
        with TempAltQtyInvoiceEntry do begin
            "Quantity (Base)" := NewAltQtyEntry."Invoiced Qty. (Base)" - "Invoiced Qty. (Base)";
            "Quantity (Alt.)" := NewAltQtyEntry."Invoiced Qty. (Alt.)" - "Invoiced Qty. (Alt.)";
            if ("Quantity (Base)" <> 0) or ("Quantity (Alt.)" <> 0) then begin
                "Invoiced Qty. (Base)" := "Quantity (Base)";
                "Invoiced Qty. (Alt.)" := "Quantity (Alt.)";
                TempAltQtyInvLineNo := TempAltQtyInvLineNo + 10000;
                "Line No." := TempAltQtyInvLineNo;
                Insert;
            end;
        end;
    end;

    procedure CreateInvoiceEntries(TableNo: Integer; DocNo: Code[20])
    var
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // CreateInvoiceEntries
        with TempAltQtyInvoiceEntry do begin
            if Find('-') then
                repeat
                    AltQtyEntry := TempAltQtyInvoiceEntry;
                    AltQtyEntry."Table No." := TableNo;
                    AltQtyEntry."Document No." := DocNo;
                    AltQtyEntry.Insert;
                until (Next = 0);
            DeleteAll;
        end;
    end;

    local procedure InitAltQtyEntry(var AltQtyEntry: Record "Alternate Quantity Entry"; var AltQtyLine: Record "Alternate Quantity Line")
    begin
        // InitAltQtyEntry
        with AltQtyLine do begin
            AltQtyEntry.Init;
            AltQtyEntry."Line No." := "Line No.";
            AltQtyEntry."Lot No." := "Lot No.";
            AltQtyEntry."Serial No." := "Serial No.";
            AltQtyEntry."Quantity (Base)" := "Quantity (Base)";
            AltQtyEntry."Quantity (Alt.)" := "Quantity (Alt.)";
            AltQtyEntry."Invoiced Qty. (Base)" := "Invoiced Qty. (Base)";
            AltQtyEntry."Invoiced Qty. (Alt.)" := "Invoiced Qty. (Alt.)";
        end;
    end;

    procedure RemoveExcessAltQtys(var ItemJnlLine: Record "Item Journal Line")
    var
        RemQtyBase: Decimal;
        QtyAlt: Decimal;
        AltQtyLine: Record "Alternate Quantity Line";
        Item2: Record Item;
    begin
        // RemoveExcessAltQtys
        TempExcessAltQtyLine.DeleteAll;
        TempExcessAltQtyLineNo := 0;

        // PR3.61.02 Begin
        Item2.Get(ItemJnlLine."Item No.");
        if not Item2."Catch Alternate Qtys." then begin
            ItemJnlLine."Quantity (Alt.)" := Round(ItemJnlLine."Quantity (Base)" * Item2.AlternateQtyPerBase, 0.00001);
            ItemJnlLine."Invoiced Qty. (Alt.)" := ItemJnlLine."Quantity (Alt.)";
            exit;
        end;
        // PR3.61.02 End

        RemQtyBase := ItemJnlLine."Quantity (Base)";
        with AltQtyLine do begin
            SetRange("Alt. Qty. Transaction No.", ItemJnlLine."Alt. Qty. Transaction No.");
            SetRange("Lot No.", ItemJnlLine."Lot No.");       // P8000783
            SetRange("Serial No.", ItemJnlLine."Serial No."); // P8000783
            if Find('-') then
                repeat
                    if (Abs(RemQtyBase) >= Abs("Quantity (Base)")) then begin
                        RemQtyBase := RemQtyBase - "Quantity (Base)";
                        QtyAlt := QtyAlt + "Quantity (Alt.)";
                    end else
                        if (RemQtyBase = 0) then
                            InsertExcessAltQty(AltQtyLine, "Quantity (Base)")
                        else begin
                            InsertExcessAltQty(AltQtyLine, RemQtyBase);
                            QtyAlt := QtyAlt + "Quantity (Alt.)";
                            RemQtyBase := 0;
                        end;
                until (Next = 0);
        end;
        ItemJnlLine."Quantity (Alt.)" := QtyAlt;
        ItemJnlLine."Invoiced Qty. (Alt.)" := QtyAlt;
    end;

    local procedure InsertExcessAltQty(var AltQtyLine: Record "Alternate Quantity Line"; QtyBase: Decimal)
    begin
        // InsertExcessAltQty
        TempExcessAltQtyLineNo := TempExcessAltQtyLineNo + 10000;
        TempExcessAltQtyLine := AltQtyLine;
        with TempExcessAltQtyLine do begin
            // "Line No." := TempExcessAltQtyLineNo; // P8000783
            if (QtyBase = "Quantity (Base)") then
                AltQtyLine.Delete
            else begin
                AltQtyLine."Quantity (Base)" := QtyBase;
                AltQtyLine."Quantity (Alt.)" := Round("Quantity (Alt.)" * (QtyBase / "Quantity (Base)"), 0.00001);
                AltQtyLine."Invoiced Qty. (Base)" := AltQtyLine."Quantity (Base)";
                AltQtyLine."Invoiced Qty. (Alt.)" := AltQtyLine."Quantity (Alt.)";
                AltQtyLine.Modify;
                "Quantity (Base)" := "Quantity (Base)" - AltQtyLine."Quantity (Base)";
                "Quantity (Alt.)" := "Quantity (Alt.)" - AltQtyLine."Quantity (Alt.)";
                "Invoiced Qty. (Base)" := "Quantity (Base)";
                "Invoiced Qty. (Alt.)" := "Quantity (Alt.)";
            end;
            Insert;
        end;
    end;

    procedure RestoreExcessAltQtys()
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // RestoreExcessAltQtys
        with TempExcessAltQtyLine do
            if Find('-') then
                repeat
                    AltQtyLine := TempExcessAltQtyLine;
                    AltQtyLine.Insert;
                    Delete;
                until (Next = 0);
    end;

    procedure ShowItemLedgAltQtyEntries(var ItemLedgEntry: Record "Item Ledger Entry"; FldNo: Integer)
    var
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // ShowItemLedgAltQtyEntries
        with ItemLedgEntry do begin
            AltQtyEntry.SetRange("Table No.", DATABASE::"Item Ledger Entry");
            AltQtyEntry.SetRange("Source Line No.", "Entry No.");
            case FldNo of
                FieldNo("Quantity (Alt.)"):
                    PAGE.RunModal(0, AltQtyEntry, AltQtyEntry."Quantity (Alt.)");
                FieldNo("Invoiced Quantity (Alt.)"):
                    PAGE.RunModal(0, AltQtyEntry, AltQtyEntry."Invoiced Qty. (Alt.)");
            end;
        end;
    end;

    procedure ShowPhysInvtLedgAltQtyEntries(var PhysInvtLedgEntry: Record "Phys. Inventory Ledger Entry")
    var
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // ShowPhysInvtLedgAltQtyEntries
        with PhysInvtLedgEntry do begin
            AltQtyEntry.SetRange("Table No.", DATABASE::"Phys. Inventory Ledger Entry");
            AltQtyEntry.SetRange("Source Line No.", "Entry No.");
            PAGE.RunModal(0, AltQtyEntry, AltQtyEntry."Quantity (Alt.)");
        end;
    end;

    procedure ShowShipmentLineAltQtyEntries(var ShipmentLine: Record "Sales Shipment Line"; FldNo: Integer)
    var
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // ShowShipmentLineAltQtyEntries
        with ShipmentLine do begin
            AltQtyEntry.SetRange("Table No.", DATABASE::"Sales Shipment Line");
            AltQtyEntry.SetRange("Document No.", "Document No.");
            AltQtyEntry.SetRange("Source Line No.", "Line No.");
            case FldNo of
                FieldNo("Quantity (Alt.)"):
                    PAGE.RunModal(0, AltQtyEntry, AltQtyEntry."Quantity (Alt.)");
                FieldNo("Qty. Invoiced (Alt.)"):
                    PAGE.RunModal(0, AltQtyEntry, AltQtyEntry."Invoiced Qty. (Alt.)");
            end;
        end;
    end;

    procedure ShowSalesInvLineAltQtyEntries(var SalesInvLine: Record "Sales Invoice Line")
    var
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // ShowSalesInvLineAltQtyEntries
        with SalesInvLine do begin
            AltQtyEntry.SetRange("Table No.", DATABASE::"Sales Invoice Line");
            AltQtyEntry.SetRange("Document No.", "Document No.");
            AltQtyEntry.SetRange("Source Line No.", "Line No.");
            PAGE.RunModal(0, AltQtyEntry, AltQtyEntry."Quantity (Alt.)");
        end;
    end;

    procedure ShowRetRcptLineAltQtyEntries(var ReturnRcptLine: Record "Return Receipt Line"; FldNo: Integer)
    var
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // ShowRetRcptLineAltQtyEntries
        with ReturnRcptLine do begin
            AltQtyEntry.SetRange("Table No.", DATABASE::"Return Receipt Line");
            AltQtyEntry.SetRange("Document No.", "Document No.");
            AltQtyEntry.SetRange("Source Line No.", "Line No.");
            case FldNo of
                FieldNo("Quantity (Alt.)"):
                    PAGE.RunModal(0, AltQtyEntry, AltQtyEntry."Quantity (Alt.)");
                FieldNo("Qty. Invoiced (Alt.)"):
                    PAGE.RunModal(0, AltQtyEntry, AltQtyEntry."Invoiced Qty. (Alt.)");
            end;
        end;
    end;

    procedure ShowSalesCMLineAltQtyEntries(var SalesCrMemoLine: Record "Sales Cr.Memo Line")
    var
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // ShowSalesCMLineAltQtyEntries
        with SalesCrMemoLine do begin
            AltQtyEntry.SetRange("Table No.", DATABASE::"Sales Cr.Memo Line");
            AltQtyEntry.SetRange("Document No.", "Document No.");
            AltQtyEntry.SetRange("Source Line No.", "Line No.");
            PAGE.RunModal(0, AltQtyEntry, AltQtyEntry."Quantity (Alt.)");
        end;
    end;

    procedure ShowReceiptLineAltQtyEntries(var ReceiptLine: Record "Purch. Rcpt. Line"; FldNo: Integer)
    var
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // ShowReceiptLineAltQtyEntries
        with ReceiptLine do begin
            AltQtyEntry.SetRange("Table No.", DATABASE::"Purch. Rcpt. Line");
            AltQtyEntry.SetRange("Document No.", "Document No.");
            AltQtyEntry.SetRange("Source Line No.", "Line No.");
            case FldNo of
                FieldNo("Quantity (Alt.)"):
                    PAGE.RunModal(0, AltQtyEntry, AltQtyEntry."Quantity (Alt.)");
                FieldNo("Qty. Invoiced (Alt.)"):
                    PAGE.RunModal(0, AltQtyEntry, AltQtyEntry."Invoiced Qty. (Alt.)");
            end;
        end;
    end;

    procedure ShowPurchInvLineAltQtyEntries(var PurchInvLine: Record "Purch. Inv. Line")
    var
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // ShowPurchInvLineAltQtyEntries
        with PurchInvLine do begin
            AltQtyEntry.SetRange("Table No.", DATABASE::"Purch. Inv. Line");
            AltQtyEntry.SetRange("Document No.", "Document No.");
            AltQtyEntry.SetRange("Source Line No.", "Line No.");
            PAGE.RunModal(0, AltQtyEntry, AltQtyEntry."Quantity (Alt.)");
        end;
    end;

    procedure ShowRetShptLineAltQtyEntries(var ReturnShptLine: Record "Return Shipment Line"; FldNo: Integer)
    var
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // ShowRetShptLineAltQtyEntries
        with ReturnShptLine do begin
            AltQtyEntry.SetRange("Table No.", DATABASE::"Return Shipment Line");
            AltQtyEntry.SetRange("Document No.", "Document No.");
            AltQtyEntry.SetRange("Source Line No.", "Line No.");
            case FldNo of
                FieldNo("Quantity (Alt.)"):
                    PAGE.RunModal(0, AltQtyEntry, AltQtyEntry."Quantity (Alt.)");
                FieldNo("Qty. Invoiced (Alt.)"):
                    PAGE.RunModal(0, AltQtyEntry, AltQtyEntry."Invoiced Qty. (Alt.)");
            end;
        end;
    end;

    procedure ShowPurchCMLineAltQtyEntries(var PurchCrMemoLine: Record "Purch. Cr. Memo Line")
    var
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // ShowPurchCMLineAltQtyEntries
        with PurchCrMemoLine do begin
            AltQtyEntry.SetRange("Table No.", DATABASE::"Purch. Cr. Memo Line");
            AltQtyEntry.SetRange("Document No.", "Document No.");
            AltQtyEntry.SetRange("Source Line No.", "Line No.");
            PAGE.RunModal(0, AltQtyEntry, AltQtyEntry."Quantity (Alt.)");
        end;
    end;

    procedure ShowTransShptLineAltQtyEntries(var TransShptLine: Record "Transfer Shipment Line"; FldNo: Integer)
    var
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // ShowTransShptLineAltQtyEntries
        with TransShptLine do begin
            AltQtyEntry.SetRange("Table No.", DATABASE::"Transfer Shipment Line");
            AltQtyEntry.SetRange("Document No.", "Document No.");
            AltQtyEntry.SetRange("Source Line No.", "Line No.");
            case FldNo of
                FieldNo("Quantity (Alt.)"):
                    PAGE.RunModal(0, AltQtyEntry, AltQtyEntry."Quantity (Alt.)");
            end;
        end;
    end;

    procedure ShowTransRcptLineAltQtyEntries(var TransRcptLine: Record "Transfer Receipt Line"; FldNo: Integer)
    var
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // ShowTransRcptLineAltQtyEntries
        with TransRcptLine do begin
            AltQtyEntry.SetRange("Table No.", DATABASE::"Transfer Receipt Line");
            AltQtyEntry.SetRange("Document No.", "Document No.");
            AltQtyEntry.SetRange("Source Line No.", "Line No.");
            case FldNo of
                FieldNo("Quantity (Alt.)"):
                    PAGE.RunModal(0, AltQtyEntry, AltQtyEntry."Quantity (Alt.)");
            end;
        end;
    end;

    procedure StartLineReport(AltQtyTransactionNo: Integer; NumQtys: Decimal): Boolean
    begin
        // StartLineReport
        with ReportAltQtyLine do begin
            Reset;
            SetRange("Alt. Qty. Transaction No.", AltQtyTransactionNo);
            SetFilter(Quantity, '<>1&<>-1');
            ReportingComplete := Find('-');
            if not ReportingComplete then begin
                SetRange(Quantity);
                ReportingComplete := not Find('-');
            end;
            if ReportingComplete then
                exit(false);
            exit(Count = NumQtys);
        end;
    end;

    procedure GetLineReportAltQtys(var AltQtys: array[99] of Decimal; NumQtys: Integer): Boolean
    var
        CurrQty: Integer;
    begin
        // GetLineReportAltQtys
        if ReportingComplete then
            exit(false);
        for CurrQty := 1 to NumQtys do
            if ReportingComplete then
                AltQtys[CurrQty] := 0
            else begin
                AltQtys[CurrQty] := ReportAltQtyLine."Quantity (Alt.)";
                ReportingComplete := (ReportAltQtyLine.Next = 0);
            end;
        exit(true);
    end;

    procedure StartEntryReport(TableNo: Integer; DocNo: Code[20]; SourceLineNo: Integer; BaseQty: Decimal): Boolean
    begin
        // StartEntryReport
        with ReportAltQtyEntry do begin
            Reset;
            SetRange("Table No.", TableNo);
            SetRange("Document No.", DocNo);
            SetRange("Source Line No.", SourceLineNo);
            SetFilter("Quantity (Base)", '<>1&<>-1');
            ReportingComplete := Find('-');
            if not ReportingComplete then begin
                SetRange("Quantity (Base)");
                ReportingComplete := not Find('-');
            end;
            if ReportingComplete then
                exit(false);
            exit(Count = BaseQty);
        end;
    end;

    procedure GetEntryReportAltQtys(var AltQtys: array[99] of Decimal; NumQtys: Integer): Boolean
    var
        CurrQty: Integer;
    begin
        // GetEntryReportAltQtys
        if ReportingComplete then
            exit(false);
        for CurrQty := 1 to NumQtys do
            if ReportingComplete then
                AltQtys[CurrQty] := 0
            else begin
                AltQtys[CurrQty] := ReportAltQtyEntry."Quantity (Alt.)";
                ReportingComplete := (ReportAltQtyEntry.Next = 0);
            end;
        exit(true);
    end;

    procedure FormatReportAltQty(ItemNo: Code[20]; AltQty: Decimal): Text[30]
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        // FormatReportAltQty
        if (AltQty = 0) then
            exit('');
        GetItem(ItemNo);
        if UnitOfMeasure.Get(Item."Alternate Unit of Measure") then
            if (UnitOfMeasure."Alt. Qty. Decimal Places" <> '') then
                exit(Format(AltQty, 0,
                            StrSubstNo(Text007, UnitOfMeasure."Alt. Qty. Decimal Places")));
        exit(Format(AltQty));
    end;

    // P800128960
    procedure GetMaxDecimalPlaces(UOMCode: code[10]; var NumDecimalPlaces: Integer): Boolean
    var
        UnitOfMeasure: Record "Unit of Measure";
        ColonPos: Integer;
    begin
        if not UnitOfMeasure.Get(UOMCode) then
            exit(false);
        if (UnitOfMeasure."Alt. Qty. Decimal Places" = '') then
            exit(false);
        ColonPos := StrPos(UnitOfMeasure."Alt. Qty. Decimal Places", ':');
        if (ColonPos = 0) then
            exit(Evaluate(NumDecimalPlaces, UnitOfMeasure."Alt. Qty. Decimal Places"));
        exit(Evaluate(NumDecimalPlaces, CopyStr(UnitOfMeasure."Alt. Qty. Decimal Places", ColonPos + 1)));
    end;

    procedure InitAlternateQty(ItemNo: Code[20]; AltQtyTransactionNo: Integer; QtyBase: Decimal; var QtyAlt: Decimal)
    begin
        // InitAlternateQty
        GetItem(ItemNo);
        if Item."Catch Alternate Qtys." then
            QtyAlt := CalcAltQtyLinesQtyAlt1(AltQtyTransactionNo)
        else
            QtyAlt := CalcAltQty(ItemNo, QtyBase);
    end;

    procedure InitAlternateQtyToHandle(ItemNo: Code[20]; AltQtyTransactionNo: Integer; BaseQty: Decimal; BaseQtyToHandle: Decimal; BaseQtyHandled: Decimal; AltQty: Decimal; AltQtyHandled: Decimal; var AltQtyToHandle: Decimal)
    begin
        // P8000550A
        GetItem(ItemNo);
        if Item."Catch Alternate Qtys." then
            AltQtyToHandle := CalcAltQtyLinesQtyAlt1(AltQtyTransactionNo)
        else
            AltQtyToHandle :=
              CalcAltQtyToHandle(ItemNo, BaseQty, BaseQtyToHandle, BaseQtyHandled, AltQty, AltQtyHandled);
    end;

    procedure DeleteAltQtyLines(AltQtyTransactionNo: Integer)
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // DeleteAltQtyLines
        if (AltQtyTransactionNo = 0) then
            exit;
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", AltQtyTransactionNo);
        AltQtyLine.DeleteAll(true);
    end;

    procedure DeleteAltQtyLines2(AltQtyTransactionNo: Integer; SuspendStatusCheck: Boolean)
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // P80095316
        if (AltQtyTransactionNo = 0) then
            exit;
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", AltQtyTransactionNo);
        if AltQtyLine.FindSet then
            repeat
                AltQtyLine.SuspendStatusCheck(SuspendStatusCheck);
                AltQtyLine.Delete(true);
            until AltQtyLine.Next = 0;
    end;

    procedure AdjustPerBaseAmount(ItemNo: Code[20]; var PerBaseAmount: Decimal)
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        // AdjustPerBaseAmount
        SavedPerBaseAmountCount := SavedPerBaseAmountCount + 1;
        if (SavedPerBaseAmountCount <= 100) then
            SavedPerBaseAmount[SavedPerBaseAmountCount] := PerBaseAmount;
        GetItem(ItemNo);
        if Item.CostInAlternateUnits() then
            PerBaseAmount := 1;
    end;

    procedure RestorePerBaseAmount(var PerBaseAmount: Decimal)
    begin
        // RestorePerBaseAmount
        if (SavedPerBaseAmountCount <= 100) then
            PerBaseAmount := SavedPerBaseAmount[SavedPerBaseAmountCount];
        SavedPerBaseAmountCount := SavedPerBaseAmountCount - 1;
    end;

    procedure CheckTolerance(ItemNo: Code[20]; AltFieldName: Text[250]; BaseQty: Decimal; AlternateQty: Decimal)
    var
        ExpectedAltQty: Decimal;
        ToleranceAltQty: Decimal;
        ErrorMsg: Text[250];
    begin
        // CheckTolerance
        // P8000310A
        if CheckTolerance1(ItemNo, BaseQty, AlternateQty, ExpectedAltQty, ToleranceAltQty) then
            exit;

        //GetItem(ItemNo);
        //IF (Item."Alternate Qty. Tolerance %" = 0) THEN
        //  EXIT;
        //ExpectedAltQty := CalcAltQty(ItemNo, BaseQty);
        //ToleranceAltQty := ABS(ExpectedAltQty) * Item."Alternate Qty. Tolerance %" / 100;
        //IF (ABS(AlternateQty - ExpectedAltQty) > ToleranceAltQty) THEN BEGIN
        // P8000310A
        ExpectedAltQty := Round(ExpectedAltQty, 0.00001);
        ToleranceAltQty := Round(ToleranceAltQty, 0.00001);
        if (ExpectedAltQty <> 0) then
            ErrorMsg :=
              StrSubstNo(
                Text002, AltFieldName, ExpectedAltQty,
                Item.FieldCaption("Alternate Qty. Tolerance %"), Item."Alternate Qty. Tolerance %",
                ExpectedAltQty - ToleranceAltQty, ExpectedAltQty + ToleranceAltQty, AlternateQty)
        else
            ErrorMsg :=
              StrSubstNo(
                Text003, AltFieldName, ExpectedAltQty,
                Item.FieldCaption("Alternate Qty. Tolerance %"),
                Item."Alternate Qty. Tolerance %", AlternateQty);
        if not Confirm(ErrorMsg, false) then
            Error(Text004, AltFieldName);
        //END;
    end;

    procedure CheckTolerance1(ItemNo: Code[20]; BaseQty: Decimal; AlternateQty: Decimal; var ExpectedAltQty: Decimal; var ToleranceAltQty: Decimal): Boolean
    begin
        // P8000310A
        GetItem(ItemNo);
        if (Item."Alternate Qty. Tolerance %" = 0) then
            exit(true);
        ExpectedAltQty := CalcAltQty(ItemNo, BaseQty);
        ToleranceAltQty := Abs(ExpectedAltQty) * Item."Alternate Qty. Tolerance %" / 100;
        exit(Abs(AlternateQty - ExpectedAltQty) <= ToleranceAltQty);
    end;

    procedure CheckSummaryTolerance1(AltQtyTransactionNo: Integer; ItemNo: Code[20]; SourceFieldName: Text[250]; BaseQty: Decimal; AlternateQty: Decimal)
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // CheckSummaryTolerance1
        if (AltQtyTransactionNo <> 0) then begin
            AltQtyLine.SetRange("Alt. Qty. Transaction No.", AltQtyTransactionNo);
            if (AltQtyLine.Count > 1) then
                exit;
        end;
        CheckTolerance(ItemNo, SourceFieldName, BaseQty, AlternateQty);
    end;

    procedure CheckSummaryTolerance2(AltQtyTransactionNo: Integer; ItemNo: Code[20]; SerialNo: Code[50]; LotNo: Code[50]; SourceFieldName: Text[250]; BaseQty: Decimal; AlternateQty: Decimal)
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // CheckSummaryTolerance2
        if (AltQtyTransactionNo <> 0) then begin
            AltQtyLine.SetCurrentKey("Alt. Qty. Transaction No.", "Serial No.", "Lot No.");
            AltQtyLine.SetRange("Alt. Qty. Transaction No.", AltQtyTransactionNo);
            AltQtyLine.SetRange("Serial No.", SerialNo);
            AltQtyLine.SetRange("Lot No.", LotNo);
            if (AltQtyLine.Count > 1) then
                exit;
        end;
        CheckTolerance(ItemNo, SourceFieldName, BaseQty, AlternateQty);
    end;

    local procedure CalcAltQty(ItemNo: Code[20]; BaseQty: Decimal): Decimal
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        // CalcAltQty
        GetItem(ItemNo);
        if not Item.TrackAlternateUnits() then
            exit(0);
        ItemUnitOfMeasure.Get(ItemNo, Item."Alternate Unit of Measure");
        ItemUnitOfMeasure.TestField("Qty. per Unit of Measure");
        exit(Round(BaseQty / ItemUnitOfMeasure."Qty. per Unit of Measure", 0.00001)); // PR3.61.01
    end;

    local procedure CalcAltQtyToHandle(ItemNo: Code[20]; BaseQty: Decimal; BaseQtyToHandle: Decimal; BaseQtyHandled: Decimal; AltQty: Decimal; AltQtyHandled: Decimal): Decimal
    begin
        // P8000550A
        GetItem(ItemNo);
        if not Item.TrackAlternateUnits() then
            exit(0);
        if (BaseQtyToHandle = 0) then
            exit(0);
        //IF ((BaseQtyToHandle + BaseQtyHandled) = BaseQty) THEN // P8001393
        //  EXIT(AltQty - AltQtyHandled);                        // P8001393
        exit(CalcAltQty(ItemNo, BaseQtyToHandle + BaseQtyHandled) - AltQtyHandled);
    end;

    procedure CheckBaseQty(ItemNo: Code[20]; SerialNo: Code[50]; LotNo: Code[50]; AltQtyTransactionNo: Integer; SourceFieldName: Text[250]; SourceBaseQty: Decimal)
    var
        AltQtyLineQtyBase: Decimal;
    begin
        // CheckBaseQty
        if (SourceBaseQty <> 0) then begin
            GetItem(ItemNo);
            if Item.TrackAlternateUnits() and Item."Catch Alternate Qtys." then begin
                if not AltQtyLinesExist(AltQtyTransactionNo) then
                    Error(Text014, Item.TableName, Item."No.");  // P8007524
                AltQtyLineQtyBase := Round(CalcAltQtyLinesQtyBase2(AltQtyTransactionNo, SerialNo, LotNo), 0.00001); // P8000392A
                if (Abs(AltQtyLineQtyBase) <> Abs(SourceBaseQty)) then   // PR3.70.03
                    Error(Text006, SourceFieldName, AltQtyLineQtyBase);
            end;
        end;
    end;

    procedure CheckZeroAltQty(ItemNo: Code[20]; SerialNo: Code[50]; LotNo: Code[50]; AltQtyTransactionNo: Integer)
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // P8000538A
        GetItem(ItemNo);
        if Item.TrackAlternateUnits() and Item."Catch Alternate Qtys." and (AltQtyTransactionNo <> 0) then begin
            AltQtyLine.SetCurrentKey("Alt. Qty. Transaction No.", "Serial No.", "Lot No.");
            AltQtyLine.SetRange("Alt. Qty. Transaction No.", AltQtyTransactionNo);
            AltQtyLine.SetRange("Lot No.", LotNo);
            AltQtyLine.SetRange("Serial No.", SerialNo);
            AltQtyLine.SetFilter("Quantity (Base)", '<>0');
            AltQtyLine.SetRange("Quantity (Alt.)", 0);
            if not AltQtyLine.IsEmpty then
                Error(Text005,
                      AltQtyLine.FieldCaption("Quantity (Alt.)"), Item.TableName,
                      Item.FieldCaption("No."), Item."No.");
        end;
    end;

    procedure AltQtyLinesExist(AltQtyTransactionNo: Integer): Boolean
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // AltQtyLinesExist
        if (AltQtyTransactionNo = 0) then
            exit(false);
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", AltQtyTransactionNo);
        exit(AltQtyLine.Find('-'));
    end;

    procedure CalcAltQtyLinesQtyBase1(AltQtyTransactionNo: Integer): Decimal
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // CalcAltQtyLinesQtyBase1
        if (AltQtyTransactionNo = 0) then
            exit(0);
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", AltQtyTransactionNo);
        AltQtyLine.CalcSums("Quantity (Base)");
        exit(AltQtyLine."Quantity (Base)");
    end;

    procedure CalcAltQtyLinesQtyBase2(AltQtyTransactionNo: Integer; SerialNo: Code[50]; LotNo: Code[50]): Decimal
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // CalcAltQtyLinesQtyBase2
        if (AltQtyTransactionNo = 0) then
            exit(0);
        AltQtyLine.SetCurrentKey("Alt. Qty. Transaction No.", "Serial No.", "Lot No.");
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", AltQtyTransactionNo);
        AltQtyLine.SetRange("Serial No.", SerialNo);
        AltQtyLine.SetRange("Lot No.", LotNo);
        AltQtyLine.CalcSums("Quantity (Base)");
        exit(AltQtyLine."Quantity (Base)");
    end;

    procedure CalcAltQtyLinesQtyAlt1(AltQtyTransactionNo: Integer): Decimal
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // CalcAltQtyLinesQtyAlt1
        if (AltQtyTransactionNo = 0) then
            exit(0);
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", AltQtyTransactionNo);
        AltQtyLine.CalcSums("Quantity (Alt.)");
        exit(AltQtyLine."Quantity (Alt.)");
    end;

    procedure CalcAltQtyLinesQtyAlt2(AltQtyTransactionNo: Integer; SerialNo: Code[50]; LotNo: Code[50]): Decimal
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // CalcAltQtyLinesQtyAlt2
        if (AltQtyTransactionNo = 0) then
            exit(0);
        AltQtyLine.SetCurrentKey("Alt. Qty. Transaction No.", "Serial No.", "Lot No.");
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", AltQtyTransactionNo);
        AltQtyLine.SetRange("Serial No.", SerialNo);
        AltQtyLine.SetRange("Lot No.", LotNo);
        AltQtyLine.CalcSums("Quantity (Alt.)");
        exit(AltQtyLine."Quantity (Alt.)");
    end;

    procedure GetLocation(LocationCode: Code[20]; var Location: Record Location)
    var
        WhseSetup: Record "Warehouse Setup";
    begin
        // P8000282A
        Clear(Location);
        with Location do
            if not Get(LocationCode) then
                if WhseSetup.Get then begin
                    "Require Receive" := WhseSetup."Require Receive";
                    "Require Put-away" := WhseSetup."Require Put-away";
                    "Require Shipment" := WhseSetup."Require Shipment";
                    "Require Pick" := WhseSetup."Require Pick";
                end;
    end;

    local procedure GetItem(ItemNo: Code[20])
    begin
        // GetItem
        if (Item."No." <> ItemNo) then
            Item.Get(ItemNo);
        TrackItem := ItemTrackingCode.Get(Item."Item Tracking Code");
    end;

    procedure GetSourceAltQtyTransNo(TableNo: Integer; DocType: Integer; DocNo: Code[20]; TempName: Code[10]; BatchName: Code[10]; SourceLineNo: Integer; Assign: Boolean) AltQtyTransNo: Integer
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        ItemJnlLine: Record "Item Journal Line";
        InvtDocLine: Record "Invt. Document Line";
        TransferLine: Record "Transfer Line";
    begin
        // GetSourceAltQtyTransNo
        case TableNo of
            DATABASE::"Sales Line":
                begin
                    if not SalesLine.Get(DocType, DocNo, SourceLineNo) then
                        exit(0);
                    // P8000361A
                    GetItem(SalesLine."No.");
                    if not Item."Catch Alternate Qtys." then
                        exit(0);
                    // P8000361A
                    if AssignNewTransactionNo(SalesLine."Alt. Qty. Transaction No.") then begin
                        SalesLine.Modify;
                        Commit;
                    end;
                    AltQtyTransNo := SalesLine."Alt. Qty. Transaction No.";
                end;

            DATABASE::"Purchase Line":
                begin
                    if not PurchLine.Get(DocType, DocNo, SourceLineNo) then
                        exit(0);
                    // P8000361A
                    GetItem(PurchLine."No.");
                    if not Item."Catch Alternate Qtys." then
                        exit(0);
                    // P8000361A
                    if AssignNewTransactionNo(PurchLine."Alt. Qty. Transaction No.") then begin
                        PurchLine.Modify;
                        Commit;
                    end;
                    AltQtyTransNo := PurchLine."Alt. Qty. Transaction No.";
                end;

            DATABASE::"Item Journal Line":
                begin
                    if not ItemJnlLine.Get(TempName, BatchName, SourceLineNo) then
                        exit(0);
                    // P8000361A
                    GetItem(ItemJnlLine."Item No.");
                    if not Item."Catch Alternate Qtys." then
                        exit(0);
                    // P8000361A
                    if AssignNewTransactionNo(ItemJnlLine."Alt. Qty. Transaction No.") then begin
                        ItemJnlLine.Modify;
                        Commit;
                    end;
                    AltQtyTransNo := ItemJnlLine."Alt. Qty. Transaction No.";
                end;

            // P800127049
            Database::"Invt. Document Line":
                begin
                    if not InvtDocLine.Get(DocType, DocNo, SourceLineNo) then
                        exit(0);
                    GetItem(InvtDocLine."Item No.");
                    if not Item."Catch Alternate Qtys." then
                        exit(0);
                    if AssignNewTransactionNo(InvtDocLine."FOOD Alt. Qty. Transaction No.") then begin
                        InvtDocLine.Modify();
                        Commit();
                    end;
                    AltQtyTransNo := InvtDocLine."FOOD Alt. Qty. Transaction No.";
                end;
            // P800127049

            // PR3.61.01 Begin
            DATABASE::"Transfer Line":
                begin
                    if not TransferLine.Get(DocNo, SourceLineNo) then
                        exit(0);
                    // P8000361A
                    GetItem(TransferLine."Item No.");
                    if not Item."Catch Alternate Qtys." then
                        exit(0);
                    // P8000361A
                    case DocType of
                        0:
                            begin
                                if AssignNewTransactionNo(TransferLine."Alt. Qty. Trans. No. (Ship)") then begin
                                    TransferLine.Modify;
                                    Commit;
                                end;
                                AltQtyTransNo := TransferLine."Alt. Qty. Trans. No. (Ship)";
                            end;
                        1:
                            begin
                                if AssignNewTransactionNo(TransferLine."Alt. Qty. Trans. No. (Receive)") then begin
                                    TransferLine.Modify;
                                    Commit;
                                end;
                                AltQtyTransNo := TransferLine."Alt. Qty. Trans. No. (Receive)";
                            end;
                    end;
                end;
        // PR3.61.01 End
        end;
    end;

    procedure UndoAltQtyEntries(OldTableNo: Integer; OldDocNo: Code[20]; OldLineNo: Integer; NewTableNo: Integer; NewDocNo: Code[20]; NewLineNo: Integer; UpdateInvoiced: Boolean)
    var
        AltQtyEntry: Record "Alternate Quantity Entry";
        AltQtyEntry2: Record "Alternate Quantity Entry";
    begin
        // UndoAltQtyEntries
        AltQtyEntry.SetRange("Table No.", OldTableNo);
        AltQtyEntry.SetRange("Document No.", OldDocNo);
        AltQtyEntry.SetRange("Source Line No.", OldLineNo);
        if AltQtyEntry.Find('-') then
            repeat
                if UpdateInvoiced then begin
                    AltQtyEntry."Invoiced Qty. (Base)" := AltQtyEntry."Quantity (Base)";
                    AltQtyEntry."Invoiced Qty. (Alt.)" := AltQtyEntry."Quantity (Alt.)";
                    AltQtyEntry.Modify;
                end;
                AltQtyEntry2 := AltQtyEntry;
                AltQtyEntry2."Table No." := NewTableNo;
                AltQtyEntry2."Document No." := NewDocNo;
                AltQtyEntry2."Source Line No." := NewLineNo;
                AltQtyEntry2."Quantity (Base)" := -AltQtyEntry2."Quantity (Base)";
                AltQtyEntry2."Quantity (Alt.)" := -AltQtyEntry2."Quantity (Alt.)";
                AltQtyEntry2."Invoiced Qty. (Base)" := -AltQtyEntry2."Invoiced Qty. (Base)";
                AltQtyEntry2."Invoiced Qty. (Alt.)" := -AltQtyEntry2."Invoiced Qty. (Alt.)";
                AltQtyEntry2.Insert;
            until AltQtyEntry.Next = 0;
    end;

    procedure AltQtyEntriesToSalesLine(TableNo: Integer; DocNo: Code[20]; DocLineNo: Integer; var SalesLine: Record "Sales Line")
    var
        Item: Record Item;
        AltQtyEntry: Record "Alternate Quantity Entry";
        AltQtyLine: Record "Alternate Quantity Line";
        UOMMgmt: Codeunit "Unit of Measure Management";
        AltQtyTracking: Codeunit "Alt. Qty. Tracking Management";
        LineNo: Integer;
    begin
        // AltQtyEntriesToSalesLine
        AltQtyEntry.SetRange("Table No.", TableNo);
        AltQtyEntry.SetRange("Document No.", DocNo);
        AltQtyEntry.SetRange("Source Line No.", DocLineNo);
        if AltQtyEntry.Find('-') then begin
            AssignNewTransactionNo(SalesLine."Alt. Qty. Transaction No.");
            AltQtyLine.SetRange("Alt. Qty. Transaction No.", SalesLine."Alt. Qty. Transaction No.");
            if AltQtyLine.Find('+') then
                LineNo := AltQtyLine."Line No."
            else
                LineNo := 0;
            repeat
                LineNo += 10000;
                CreateAltQtyLine(AltQtyLine, SalesLine."Alt. Qty. Transaction No.", LineNo,
                  DATABASE::"Sales Line", SalesLine."Document Type", SalesLine."Document No.", '', '', SalesLine."Line No.");
                AltQtyLine."Lot No." := AltQtyEntry."Lot No.";
                AltQtyLine."Serial No." := AltQtyEntry."Serial No.";
                AltQtyLine."Quantity (Base)" := AltQtyEntry."Quantity (Base)";
                AltQtyLine."Quantity (Alt.)" := AltQtyEntry."Quantity (Alt.)";
                Item.Get(SalesLine."No.");
                AltQtyLine.Quantity := AltQtyLine."Quantity (Base)" /
                  UOMMgmt.GetQtyPerUnitOfMeasure(Item, SalesLine."Unit of Measure Code");
                AltQtyLine.InitInvoicedQty;
                AltQtyLine.Modify;
            until AltQtyEntry.Next = 0;
            UpdateSalesLine(SalesLine);
            AltQtyTracking.UpdateSalesTracking(SalesLine);
            SetSalesLineAltQty(SalesLine);
        end;
    end;

    procedure AltQtyEntriesToPurchLine(TableNo: Integer; DocNo: Code[20]; DocLineNo: Integer; var PurchLine: Record "Purchase Line")
    var
        Item: Record Item;
        AltQtyEntry: Record "Alternate Quantity Entry";
        AltQtyLine: Record "Alternate Quantity Line";
        UOMMgmt: Codeunit "Unit of Measure Management";
        AltQtyTracking: Codeunit "Alt. Qty. Tracking Management";
        LineNo: Integer;
    begin
        // AltQtyEntriesToPurchLine
        AltQtyEntry.SetRange("Table No.", TableNo);
        AltQtyEntry.SetRange("Document No.", DocNo);
        AltQtyEntry.SetRange("Source Line No.", DocLineNo);
        if AltQtyEntry.Find('-') then begin
            AssignNewTransactionNo(PurchLine."Alt. Qty. Transaction No.");
            AltQtyLine.SetRange("Alt. Qty. Transaction No.", PurchLine."Alt. Qty. Transaction No.");
            if AltQtyLine.Find('+') then
                LineNo := AltQtyLine."Line No."
            else
                LineNo := 0;
            repeat
                LineNo += 10000;
                CreateAltQtyLine(AltQtyLine, PurchLine."Alt. Qty. Transaction No.", LineNo,
                  DATABASE::"Purchase Line", PurchLine."Document Type", PurchLine."Document No.", '', '', PurchLine."Line No.");
                AltQtyLine."Lot No." := AltQtyEntry."Lot No.";
                AltQtyLine."Serial No." := AltQtyEntry."Serial No.";
                AltQtyLine."Quantity (Base)" := AltQtyEntry."Quantity (Base)";
                AltQtyLine."Quantity (Alt.)" := AltQtyEntry."Quantity (Alt.)";
                Item.Get(PurchLine."No.");
                AltQtyLine.Quantity := AltQtyLine."Quantity (Base)" /
                  UOMMgmt.GetQtyPerUnitOfMeasure(Item, PurchLine."Unit of Measure Code");
                AltQtyLine.InitInvoicedQty;
                AltQtyLine.Modify;
            until AltQtyEntry.Next = 0;
            UpdatePurchLine(PurchLine);
            AltQtyTracking.UpdatePurchTracking(PurchLine);
            SetPurchLineAltQty(PurchLine);
        end;
    end;

    procedure DeletePostedDocEntries(TableNo: Integer; DocNo: Code[20])
    var
        AltQtyEntry: Record "Alternate Quantity Entry";
    begin
        // P8000198A
        AltQtyEntry.SetRange("Table No.", TableNo);
        AltQtyEntry.SetRange("Document No.", DocNo);
        AltQtyEntry.DeleteAll;
    end;

    procedure CheckUOMDifferentFromAltUOM(Item: Record Item; UOMCode: Code[10]; FldCaption: Text[30])
    var
        UOM: Record "Unit of Measure";
        AltUOM: Record "Unit of Measure";
    begin
        // P8000383A
        if UOMCode = '' then
            exit;
        AltUOM.Get(Item."Alternate Unit of Measure");
        UOM.Get(UOMCode);
        if AltUOM.Type = UOM.Type then
            Error(
              Text012,
              FldCaption,
              Item.FieldCaption("Alternate Unit of Measure"),
              UOM.TableName,
              UOM.FieldCaption(Type));
    end;

    procedure CheckFixedBinAndAltQty(var Item: Record Item)
    var
        ItemFixedBin: Record "Item Fixed Prod. Bin";
    begin
        // P8000494A
        with ItemFixedBin do begin
            SetRange("Item No.", Item."No.");
            SetRange("Lot Handling", "Lot Handling"::"Single Lot");
            if FindFirst then
                Error(
                  Text013,
                  Item.TableCaption, Item."No.",
                  FieldCaption("Location Code"), "Location Code",
                  Item.FieldCaption("Alternate Unit of Measure"));
        end;
    end;

    procedure CreatePurchaseContainerAltQtyLine(var PurchLine: Record "Purchase Line"; LotNo: Code[50]; SerialNo: Code[50]; Qty: Decimal; QtyAlt: Decimal; ContainerID: Code[20]; ContainerLineNo: Integer)
    var
        AltQtyLine: Record "Alternate Quantity Line";
        AltQtyLine2: Record "Alternate Quantity Line";
    begin
        //P8001373
        StartPurchAltQtyLine(PurchLine);
        AltQtyLine2.SetRange("Alt. Qty. Transaction No.", PurchLine."Alt. Qty. Transaction No.");
        if AltQtyLine2.Find('+') then;
        CreateAltQtyLine(
          AltQtyLine, PurchLine."Alt. Qty. Transaction No.", AltQtyLine2."Line No." + 10000, DATABASE::"Purchase Line",
          PurchLine."Document Type", PurchLine."Document No.", '', '', PurchLine."Line No.");

        AltQtyLine."Lot No." := LotNo;
        AltQtyLine."Serial No." := SerialNo;
        AltQtyLine.Validate(Quantity, Qty);
        AltQtyLine.Validate("Quantity (Alt.)", QtyAlt);
        AltQtyLine."Container ID" := ContainerID;
        AltQtyLine."Container Line No." := ContainerLineNo;
        AltQtyLine.Modify;
        //P8001373
    end;

    procedure GetActualAppliedAltQty(AppliedFromEntryNo: Integer; QtyAlt: Decimal): Decimal
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        // P8007924
        if AppliedFromEntryNo = 0 then
            exit(QtyAlt);

        with ItemLedgerEntry do begin
            Get(AppliedFromEntryNo);
            if (QtyAlt = 0) or (QtyAlt > -"Shipped Qty. Not Ret. (Alt.)") then
                exit(-"Shipped Qty. Not Ret. (Alt.)")
            else
                exit(QtyAlt);
        end;
        // P8007924
    end;

    local procedure SetSalesLineAltQtyToReceiveFromApplication(var SalesLine: Record "Sales Line")
    var
        PostedQtyToInvBase: Decimal;
        AltQtyTracking: Codeunit "Alt. Qty. Tracking Management";
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        // P8007924
        // SetSalesLineAltQtyToInvoice
        with SalesLine do begin
            if "Appl.-from Item Entry" = 0 then
                exit;
            if not ("Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"]) then
                exit;
            if (Type <> Type::Item) or ("No." = '') then
                exit;
            Item.Get("No.");
            if not Item."Catch Alternate Qtys." then
                exit;
            ItemLedgerEntry.Get("Appl.-from Item Entry");

            if ("Return Qty. to Receive" = -ItemLedgerEntry."Shipped Qty. Not Returned") then
                "Return Qty. to Receive (Alt.)" := -ItemLedgerEntry."Shipped Qty. Not Ret. (Alt.)";
        end;
        // P8007924
    end;

    procedure SetActualAppliedAltQty(ActualAppliedAltQty: Boolean)
    begin
        // P8007924
        IsActualAppliedAltQty := ActualAppliedAltQty;
        // P8007924
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Activity-Register", 'OnAfterCreateRegActivLine', '', true, false)]
    local procedure WhseActivityRegister_OnAfterCreateRegActivLine(var WarehouseActivityLine: Record "Warehouse Activity Line"; var RegisteredWhseActivLine: Record "Registered Whse. Activity Line"; var RegisteredInvtMovementLine: Record "Registered Invt. Movement Line")
    begin
        // P80079981
        if WarehouseActivityLine."Alt. Qty. Transaction No." <> 0 then // P8000282A, P8001323
            CopyWhsePickToSourceLine(WarehouseActivityLine, RegisteredWhseActivLine);  // P8000282A, P80079981
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowSalesAltQtyLines(var SalesLine: Record "Sales Line"; var Handled: Boolean)
    begin
        // P80082969
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowPurchAltQtyLines(var PurchaseLine: Record "Purchase Line"; var Handled: Boolean)
    begin
        // P80082969
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowTransAltQtyLines(var TransferLine: Record "Transfer Line"; Direction: Option Outbound,Inbound; var Handled: Boolean)
    begin
        // P80082969
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowWhseAltQtyLines(var WarehouseActivityLine: Record "Warehouse Activity Line"; var Handled: Boolean)
    begin
        // P80082969
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeWhseShptLineDrillQty(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; var Handled: Boolean)
    begin
        // P80082969
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeWhseRcptLineDrillQty(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; var Handled: Boolean)
    begin
        // P80082969
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowItemJnlAltQtyLines(var ItemJournalLine: Record "Item Journal Line"; var Handled: Boolean)
    begin
        // P80082969
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterShowItemJnlAltQtyLines(var ItemJournalLine: Record "Item Journal Line")
    begin
        // P80082969
    end;
}

