codeunit 37002101 "Process 800 1-Doc Whse. Mgmt."
{
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add 1-Doc Whse Logic
    // 
    // PRW16.00.01
    // P8000689, VerticalSoft, Don Bresee, 21 APR 09
    //   Default Expiration Date and New Expiration Date fields
    // 
    // PRW16.00.02
    // P8000747, VerticalSoft, Don Bresee, 24 NOV 09
    //   Change handling of expiration dates
    // 
    // P8000748, VerticalSoft, Don Bresee, 03 DEC 09
    //   Fix issue with Fixed Weight Items
    // 
    // PRW16.00.04
    // P8000888, VerticalSoft, Don Bresee, 14 DEC 10
    //   Add logic to handle registers
    // 
    // PRW16.00.06
    // P8001039, Columbus IT, Don Bresee, 06 MAR 12
    //   Add Rounding Adjustment logic for Warehouse
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW17.00.01
    // P8001165, Columbus IT, Jack Reynolds, 29 MAY 13
    //   Fix problem with Line No. in BuildItemJnlLine
    // 
    // PRW17.10.03
    // P8001312, Columbus IT, Jack Reynolds, 17 APR 14
    //   Fix problem updating quantity to ship on source document lines when posting bin reclass
    // 
    // P8001339, Columbus IT, Jack Reynolds, 12 AUG 14
    //   Fix permissoin error when moving inventory and container tracking is not installed
    // 
    // PRW19.00
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup old delivery trips
    // 
    // PRW110.0.02
    // P80045166, To-Increase, Dayakar Battini, 28 JUL 17
    //   Fix issue with multiple lots by passing the correct CU variable
    // 
    // P80050544, To-Increase, Dayakar Battini, 12 FEB 18
    //   Upgrade to 2017 CU13
    // 
    // P80046533, To-Increase, Jack Reynolds, 10 OCT 17
    //   Inbound containers and shipping containers
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // PRW118.01
    // P80094516, To Increase, Jack Reynolds, 24 SEP 21
    //   Use AutoIncrement property


    trigger OnRun()
    begin
    end;

    var
        ErrorText: Text[250];
        Location: Record Location;
        FromBin: Record Bin;
        ToBin: Record Bin;
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        LotNoInfo: Record "Lot No. Information";
        SerialNoInfo: Record "Serial No. Information";
        SourceCode: Code[10];
        RegisterDate: Date;
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        WMSMgmt: Codeunit "WMS Management";
        WhseJnlPostLine: Codeunit "Whse. Jnl.-Register Line";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        ContainerFns: Codeunit "Container Functions";
        DelTripPickNo: Integer;
        DelTripPickLineNo: Integer;
        SourceTableNo: Integer;
        SourceDocumentType: Integer;
        SourceDocumentNo: Code[20];
        SourceDocumentLineNo: Integer;
        WhseMgmt: Codeunit "Whse. Management";
        DimMgt: Codeunit DimensionManagement;
        Text000: Label '%1 %2 does not exist.';
        Text001: Label '%1 %2 does not exist for %3 %4.';
        Text002: Label '%1 must be %2 for %3 %4.';
        Text003: Label 'Container ID %1 is already assigned.';
        Text004: Label 'Container ID %1 is not assigned.';
        Text005: Label '%1 %2 does not have sufficient quantity of %3 %4.';
        Text006: Label '%1 %2 does not have sufficient alternate quantity of %3 %4.';
        Text007: Label '%1 must be %2 in %3 %4.';
        Text008: Label 'Container ID %1 is already in %2 %3.';
        Text009: Label 'You must specify %1 for %2 %3.';
        Text010: Label '%1 must be blank for %2 %3.';
        Text011: Label 'Item %1 is not allowed in container %2.';
        Text012: Label 'Different items cannot be combined for container %1.';
        Text013: Label 'Different lots for item %1 cannot be combined for container %2.';
        Text014: Label 'Container %1 has a maximum quantity of %2 for Item %3.';
        Text015: Label '%1 %2, Line %3 does not exist.';
        Text016: Label '%1 must be %2 on %3 %4, Line %5.';
        Text017: Label 'Quantity is not sufficient on %1 %2, Line %3.';
        Text018: Label '%1 %2, %3 %4 was not found on %5 %6.';
        Text019: Label 'Containers cannot be assigned to a %1.';
        Text020: Label 'The source and destination bins cannot be the same.';
        Text021: Label 'You must specify a quantity.';
        RoundingAdjmtMgmt: Codeunit "Rounding Adjustment Mgmt.";
        Process800Fns: Codeunit "Process 800 Functions";

    procedure MoveItem(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; FromBinCode: Code[20]; ToBinCode: Code[20]; Qty: Decimal; UOMCode: Code[10]; QtyAlt: Decimal; LotNo: Code[50]; SerialNo: Code[50]; PickDocumentType: Integer; PickDocumentNo: Code[20]; PickDocumentLineNo: Integer): Boolean
    var
        ItemJnlLine: Record "Item Journal Line";
    begin
        Clear(ErrorText);
        if (FromBinCode = ToBinCode) then
            exit(SetError(Text020));
        if not BuildItemJnlLine(
                 ItemJnlLine, ItemNo, VariantCode, LocationCode, FromBinCode,
                 ToBinCode, Qty, UOMCode, QtyAlt, LotNo, SerialNo) // P8001323
        then
            exit(false);
        if (PickDocumentType <> 0) then
            if not AddItemJnlLinePickData(ItemJnlLine, PickDocumentType, PickDocumentNo, PickDocumentLineNo) then
                exit(false);
        RegisterItemJnlLine(ItemJnlLine);
        exit(true);
    end;

    procedure GetErrorText(): Text[250]
    begin
        // P8001323
        exit(ErrorText);
    end;

    local procedure SetError(ErrorText2: Text[250]): Boolean
    begin
        // P8001323
        ErrorText := ErrorText2;
        exit(false);
    end;

    procedure SetSourceCode(NewSourceCode: Code[10])
    begin
        SourceCode := NewSourceCode;
    end;

    local procedure GetSourceCode(): Code[10]
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        if (SourceCode = '') then begin
            SourceCodeSetup.Get;
            SourceCode := SourceCodeSetup."Whse. Item Journal";
        end;
        exit(SourceCode);
    end;

    procedure SetRegisterDate(NewRegisterDate: Date)
    begin
        RegisterDate := NewRegisterDate;
    end;

    local procedure AddItemJnlLinePickData(var ItemJnlLine: Record "Item Journal Line"; PickDocumentType: Integer; PickDocumentNo: Code[20]; PickDocumentLineNo: Integer): Boolean
    begin
        with ItemJnlLine do begin
            if not CheckPickSource(Quantity, "Quantity (Alt.)", PickDocumentType, PickDocumentNo, PickDocumentLineNo) then
                exit(false);
            "Pick Source Type" := PickDocumentType;
            "Pick Source No." := PickDocumentNo;
            "Pick Source Line No." := PickDocumentLineNo;
        end;
        exit(true);
    end;

    local procedure BuildItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; FromBinCode: Code[20]; ToBinCode: Code[20]; Qty: Decimal; UOMCode: Code[10]; QtyAlt: Decimal; LotNo: Code[50]; SerialNo: Code[50]): Boolean
    var
        OldLineNo: Integer;
    begin
        // P8001323 - remove parameter for PostFromContainer
        if not CheckLocationBin(LocationCode, FromBinCode) then
            exit(false);
        if not CheckToBin(ToBinCode) then
            exit(false);
        if not CheckItem(ItemNo, VariantCode, UOMCode, LotNo, SerialNo) then
            exit(false);
        if (Qty = 0) and (QtyAlt = 0) then
            exit(SetError(Text021));
        if not CheckTotalQtyAvail(Qty, QtyAlt) then
            exit(false);
        with ItemJnlLine do begin
            Init;
            "Line No." := 0; // P8001165
            Validate("Document No.", CopyStr(UserId, 1, 20)); // P8001165
            if (RegisterDate <> 0D) then
                Validate("Posting Date", RegisterDate)
            else
                Validate("Posting Date", WorkDate);
            Validate("Entry Type", "Entry Type"::Transfer);
            Validate("Item No.", ItemNo);
            Validate("Variant Code", VariantCode);
            Validate("Location Code", LocationCode);
            Validate("Bin Code", FromBinCode);
            Validate("New Bin Code", ToBinCode);
            Validate("Source Code", GetSourceCode());
            Validate("Unit of Measure Code", UOMCode);
            Validate(Quantity, Qty);
            "Invoiced Qty. (Base)" := "Quantity (Base)";
            "Quantity (Alt.)" := QtyAlt;
            "Invoiced Qty. (Alt.)" := "Quantity (Alt.)";
            "Lot No." := LotNo;
            "Serial No." := SerialNo;
        end;
        exit(true);
    end;

    local procedure CheckLocationBin(LocationCode: Code[10]; FromBinCode: Code[20]): Boolean
    begin
        if not Location.Get(LocationCode) then
            exit(SetError(StrSubstNo(Text000, Location.TableCaption, LocationCode)));
        if not Location."Bin Mandatory" then
            exit(SetError(StrSubstNo(
              Text002, Location.FieldCaption("Bin Mandatory"), true, Location.TableCaption, LocationCode)));
        if Location."Directed Put-away and Pick" then
            exit(SetError(StrSubstNo(
              Text002, Location.FieldCaption("Directed Put-away and Pick"), false, Location.TableCaption, LocationCode)));
        if not FromBin.Get(LocationCode, FromBinCode) then
            exit(SetError(StrSubstNo(
              Text001, FromBin.TableCaption, FromBinCode, Location.TableCaption, LocationCode)));
        exit(true);
    end;

    local procedure CheckToBin(ToBinCode: Code[20]): Boolean
    begin
        if not ToBin.Get(Location.Code, ToBinCode) then
            exit(SetError(StrSubstNo(
              Text001, ToBin.TableCaption, ToBinCode, Location.TableCaption, Location.Code)));
        exit(true);
    end;

    local procedure CheckItem(ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; LotNo: Code[50]; SerialNo: Code[50]): Boolean
    var
        LNRequired: Boolean;
        SNRequired: Boolean;
    begin
        if not Item.Get(ItemNo) then
            exit(SetError(StrSubstNo(Text000, Item.TableCaption, ItemNo)));
        Clear(ItemVariant);
        if (VariantCode <> '') then
            if not ItemVariant.Get(ItemNo, VariantCode) then
                exit(SetError(StrSubstNo(
                  Text001, ItemVariant.TableCaption, VariantCode, Item.TableCaption, ItemNo)));
        if (UnitOfMeasureCode = '') then
            UnitOfMeasureCode := Item."Base Unit of Measure";
        if not ItemUnitOfMeasure.Get(ItemNo, UnitOfMeasureCode) then
            exit(SetError(StrSubstNo(
              Text001, ItemUnitOfMeasure.TableCaption, UnitOfMeasureCode, Item.TableCaption, ItemNo)));
        ItemTrackingMgt.CheckWhseItemTrkgSetup(ItemNo, SNRequired, LNRequired, false);
        Clear(LotNoInfo);
        if (LotNo = '') then begin
            if LNRequired then
                exit(SetError(StrSubstNo(
                  Text009, LotNoInfo.FieldCaption("Lot No."), Item.TableCaption, ItemNo)));
        end else begin
            if not LNRequired then
                exit(SetError(StrSubstNo(
                  Text010, LotNoInfo.FieldCaption("Lot No."), Item.TableCaption, ItemNo)));
            if not LotNoInfo.Get(ItemNo, VariantCode, LotNo) then begin
                LotNoInfo."Item No." := ItemNo;
                LotNoInfo."Variant Code" := VariantCode;
                LotNoInfo."Lot No." := LotNo;
            end;
        end;
        Clear(SerialNoInfo);
        if (SerialNo = '') then begin
            if SNRequired then
                exit(SetError(StrSubstNo(
                  Text009, SerialNoInfo.FieldCaption("Serial No."), Item.TableCaption, ItemNo)));
        end else begin
            if not SNRequired then
                exit(SetError(StrSubstNo(
                  Text010, SerialNoInfo.FieldCaption("Serial No."), Item.TableCaption, ItemNo)));
            if not SerialNoInfo.Get(ItemNo, VariantCode, SerialNo) then begin
                SerialNoInfo."Item No." := ItemNo;
                SerialNoInfo."Variant Code" := VariantCode;
                SerialNoInfo."Serial No." := SerialNo;
            end;
            ItemUnitOfMeasure.TestField("Qty. per Unit of Measure", 1);
        end;
        exit(true);
    end;

    local procedure CheckTotalQtyAvail(Qty: Decimal; QtyAlt: Decimal): Boolean
    begin
        // IF (Qty > TotalBinQuantity()) THEN                                                      // P8001039
        if (Qty > (TotalBinQuantity() + RoundingAdjmtMgmt.GetNearZeroQtyForItem(Item."No."))) then // P8001039
            exit(SetError(StrSubstNo(Text005, FromBin.TableCaption, FromBin.Code, Item.TableCaption, Item."No.")));
        if Item.TrackAlternateUnits() then
            if (QtyAlt > TotalAltQuantity()) then
                exit(SetError(StrSubstNo(Text006, Location.TableCaption, Location.Code, Item.TableCaption, Item."No.")));
        exit(true);
    end;

    local procedure TotalBinQuantity(): Decimal
    var
        WhseEntry: Record "Warehouse Entry";
    begin
        with WhseEntry do begin
            SetCurrentKey(
              "Location Code", "Bin Code", "Item No.", "Variant Code",
              "Unit of Measure Code", Open, "Lot No.", "Serial No.");
            SetRange("Location Code", Location.Code);
            SetRange("Bin Code", FromBin.Code);
            SetRange("Item No.", Item."No.");
            if ItemVariant.Code <> '' then
                SetRange("Variant Code", ItemVariant.Code);
            if ItemUnitOfMeasure.Code <> '' then
                SetRange("Unit of Measure Code", ItemUnitOfMeasure.Code);
            SetRange(Open, true);
            if LotNoInfo."Lot No." <> '' then
                SetRange("Lot No.", LotNoInfo."Lot No.");
            if SerialNoInfo."Serial No." <> '' then
                SetRange("Serial No.", SerialNoInfo."Serial No.");
            CalcSums("Remaining Quantity");
            exit("Remaining Quantity");
        end;
    end;

    local procedure TotalAltQuantity(): Decimal
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        with ItemLedgEntry do begin
            SetCurrentKey("Item No.", "Variant Code", "Location Code", "Lot No.", "Serial No.");
            SetRange("Item No.", Item."No.");
            if ItemVariant.Code <> '' then
                SetRange("Variant Code", ItemVariant.Code);
            SetRange("Location Code", Location.Code);
            if LotNoInfo."Lot No." <> '' then
                SetRange("Lot No.", LotNoInfo."Lot No.");
            if SerialNoInfo."Serial No." <> '' then
                SetRange("Serial No.", SerialNoInfo."Serial No.");
            CalcSums("Quantity (Alt.)");
            exit("Quantity (Alt.)");
        end;
    end;

    local procedure CheckPickSource(Qty: Decimal; QtyAlt: Decimal; PickDocumentType: Integer; PickDocumentNo: Code[20]; PickDocumentLineNo: Integer): Boolean
    var
        ItemJnlLine: Record "Item Journal Line";
    begin
        case PickDocumentType of
            ItemJnlLine."Pick Source Type"::"Sales Order":
                exit(CheckPickSale(Qty, QtyAlt, PickDocumentNo, PickDocumentLineNo));
            ItemJnlLine."Pick Source Type"::"Purchase Return Order":
                exit(CheckPickPurchase(Qty, QtyAlt, PickDocumentNo, PickDocumentLineNo));
            ItemJnlLine."Pick Source Type"::"Outbound Transfer":
                exit(CheckPickTransfer(Qty, QtyAlt, PickDocumentNo, PickDocumentLineNo));
        end;
        exit(true);
    end;

    local procedure CheckPickSale(Qty: Decimal; QtyAlt: Decimal; PickDocumentNo: Code[20]; PickDocumentLineNo: Integer): Boolean
    var
        ItemJnlLine: Record "Item Journal Line";
        SalesLine: Record "Sales Line";
    begin
        // P8001323
        ItemJnlLine."Pick Source Type" := ItemJnlLine."Pick Source Type"::"Sales Order";
        with SalesLine do begin
            if not Get("Document Type"::Order, PickDocumentNo, PickDocumentLineNo) then
                exit(SetError(StrSubstNo(Text015, ItemJnlLine."Pick Source Type", PickDocumentNo, PickDocumentLineNo)));
            if (Type <> Type::Item) then begin
                Type := Type::Item;
                exit(SetError(StrSubstNo(
                  Text016, FieldCaption(Type), Type, ItemJnlLine."Pick Source Type", PickDocumentNo, PickDocumentLineNo)));
            end;
            if ("No." <> Item."No.") then
                exit(SetError(StrSubstNo(
                  Text016, FieldCaption("No."), Item."No.", ItemJnlLine."Pick Source Type", PickDocumentNo, PickDocumentLineNo)));
            if ("Unit of Measure Code" <> ItemUnitOfMeasure.Code) then
                exit(SetError(StrSubstNo(
                  Text016, FieldCaption("Unit of Measure Code"), ItemUnitOfMeasure.Code,
                  ItemJnlLine."Pick Source Type", PickDocumentNo, PickDocumentLineNo)));
            if (("Outstanding Quantity" - GetContainerQuantity('')) < Qty) then // P80046533
                exit(SetError(StrSubstNo(Text017, ItemJnlLine."Pick Source Type", PickDocumentNo, PickDocumentLineNo)));
        end;
        exit(true);
    end;

    local procedure CheckPickPurchase(Qty: Decimal; QtyAlt: Decimal; PickDocumentNo: Code[20]; PickDocumentLineNo: Integer): Boolean
    var
        ItemJnlLine: Record "Item Journal Line";
        PurchLine: Record "Purchase Line";
    begin
        ItemJnlLine."Pick Source Type" := ItemJnlLine."Pick Source Type"::"Purchase Return Order";
        with PurchLine do begin
            if not Get("Document Type"::"Return Order", PickDocumentNo, PickDocumentLineNo) then
                exit(SetError(StrSubstNo(Text015, ItemJnlLine."Pick Source Type", PickDocumentNo, PickDocumentLineNo)));
            if (Type <> Type::Item) then begin
                Type := Type::Item;
                exit(SetError(StrSubstNo(
                  Text016, FieldCaption(Type), Type, ItemJnlLine."Pick Source Type", PickDocumentNo, PickDocumentLineNo)));
            end;
            if ("No." <> Item."No.") then
                exit(SetError(StrSubstNo(
                  Text016, FieldCaption("No."), Item."No.", ItemJnlLine."Pick Source Type", PickDocumentNo, PickDocumentLineNo)));
            if ("Unit of Measure Code" <> ItemUnitOfMeasure.Code) then
                exit(SetError(StrSubstNo(
                  Text016, FieldCaption("Unit of Measure Code"), ItemUnitOfMeasure.Code,
                  ItemJnlLine."Pick Source Type", PickDocumentNo, PickDocumentLineNo)));
            if ("Outstanding Quantity" < Qty) then
                exit(SetError(StrSubstNo(Text017, ItemJnlLine."Pick Source Type", PickDocumentNo, PickDocumentLineNo)));
        end;
        exit(true);
    end;

    local procedure CheckPickTransfer(Qty: Decimal; QtyAlt: Decimal; PickDocumentNo: Code[20]; PickDocumentLineNo: Integer): Boolean
    var
        ItemJnlLine: Record "Item Journal Line";
        TransLine: Record "Transfer Line";
    begin
        ItemJnlLine."Pick Source Type" := ItemJnlLine."Pick Source Type"::"Outbound Transfer";
        with TransLine do begin
            if not Get(PickDocumentNo, PickDocumentLineNo) then
                exit(SetError(StrSubstNo(Text015, ItemJnlLine."Pick Source Type", PickDocumentNo, PickDocumentLineNo)));
            if ("Item No." <> Item."No.") then
                exit(SetError(StrSubstNo(
                  Text016, FieldCaption("Item No."), Item."No.", ItemJnlLine."Pick Source Type", PickDocumentNo, PickDocumentLineNo)));
            if ("Unit of Measure Code" <> ItemUnitOfMeasure.Code) then
                exit(SetError(StrSubstNo(
                  Text016, FieldCaption("Unit of Measure Code"), ItemUnitOfMeasure.Code,
                  ItemJnlLine."Pick Source Type", PickDocumentNo, PickDocumentLineNo)));
            if (("Outstanding Quantity" - GetContainerQuantity(0, '')) < Qty) then // P80046533
                exit(SetError(StrSubstNo(Text017, ItemJnlLine."Pick Source Type", PickDocumentNo, PickDocumentLineNo)));
        end;
        exit(true);
    end;

    local procedure RegisterItemJnlLine(var ItemJnlLine: Record "Item Journal Line")
    var
        AltQtyLine: Record "Alternate Quantity Line";
        ResEntry: Record "Reservation Entry";
        TempHandlingSpecification: Record "Tracking Specification" temporary;
        WhseJnlLine: Record "Warehouse Journal Line";
        TempWhseJnlLine2: Record "Warehouse Journal Line" temporary;
        ItemJnlTemplate: Record "Item Journal Template";
        EntriesExist: Boolean;
    begin
        with ItemJnlLine do begin
            if ("Quantity (Alt.)" <> 0) then begin
                AltQtyMgmt.AssignNewTransactionNo("Alt. Qty. Transaction No.");
                AltQtyLine."Alt. Qty. Transaction No." := "Alt. Qty. Transaction No.";
                AltQtyLine."Line No." := 10000;
                AltQtyLine."Table No." := DATABASE::"Item Journal Line";
                AltQtyLine."Journal Template Name" := "Journal Template Name";
                AltQtyLine."Journal Batch Name" := "Journal Batch Name";
                AltQtyLine."Source Line No." := "Line No.";
                AltQtyLine."Lot No." := "Lot No.";
                AltQtyLine."New Lot No." := "Lot No.";
                AltQtyLine."Serial No." := "Serial No.";
                AltQtyLine.Quantity := "Quantity (Base)";
                AltQtyLine."Quantity (Base)" := "Quantity (Base)";
                AltQtyLine."Invoiced Qty. (Base)" := "Quantity (Base)";
                AltQtyLine."Quantity (Alt.)" := "Quantity (Alt.)";
                AltQtyLine."Invoiced Qty. (Alt.)" := "Quantity (Alt.)";
                AltQtyLine.Insert;
            end;
            if ("Lot No." <> '') or ("Serial No." <> '') then begin
                // P80094516
                // if not ResEntry.Find('+') then
                //     ResEntry."Entry No." := 0;
                // P80094516
                ResEntry.Init;
                ResEntry."Entry No." := 0; // P80094516
                ResEntry.Positive := (Signed(Quantity) > 0);
                ResEntry."Item No." := "Item No.";
                ResEntry."Variant Code" := "Variant Code";
                ResEntry."Location Code" := "Location Code";
                ResEntry."Source Type" := DATABASE::"Item Journal Line";
                ResEntry."Source Subtype" := "Entry Type";
                ResEntry."Source ID" := "Journal Template Name";
                ResEntry."Source Batch Name" := "Journal Batch Name";
                ResEntry."Source Ref. No." := "Line No.";
                ResEntry."Lot No." := "Lot No.";
                ResEntry."New Lot No." := "Lot No.";
                ResEntry."Serial No." := "Serial No.";
                ResEntry."New Serial No." := "Serial No.";
                // P8000689
                // ResEntry."Expiration Date" :=                                 // P8000747
                ResEntry."New Expiration Date" :=
                  ItemTrackingMgt.ExistingExpirationDate("Item No.", "Variant Code", "Lot No.", "Serial No.", false, EntriesExist);
                // ResEntry."New Expiration Date" := ResEntry."Expiration Date"; // P8000747
                // P8000689
                ResEntry."Reservation Status" := ResEntry."Reservation Status"::Prospect;
                ResEntry.Quantity := Signed(Quantity);
                ResEntry."Quantity (Base)" := Signed("Quantity (Base)");
                ResEntry."Qty. to Handle (Base)" := ResEntry."Quantity (Base)";
                ResEntry."Qty. to Invoice (Base)" := ResEntry."Quantity (Base)";
                if ("Quantity (Alt.)" <> 0) then begin
                    ResEntry."Quantity (Alt.)" := Signed("Quantity (Alt.)");
                    ResEntry."Qty. to Handle (Alt.)" := ResEntry."Quantity (Alt.)";
                    ResEntry."Qty. to Invoice (Alt.)" := ResEntry."Quantity (Alt.)";
                end;
                ResEntry."Qty. per Unit of Measure" := "Qty. per Unit of Measure";
                ResEntry.Insert;
            end;
        end;
        if (ItemJnlLine."Pick Source Line No." <> 0) then
            Transfer1DocLooseQty(ItemJnlLine);
        ItemJnlPostLine.RunWithCheck(ItemJnlLine); // P8001133
        ItemJnlPostLine.CheckItemTracking;
        ItemJnlPostLine.CollectTrackingSpecification(TempHandlingSpecification);
        XferRegsToWhse; // P8000888
        if WMSMgmt.CreateWhseJnlLine(ItemJnlLine, ItemJnlTemplate.Type::Transfer, WhseJnlLine, false) then begin // P8001132
            XferWhseRoundingAdjmts; // P8001039
            ItemTrackingMgt.SplitWhseJnlLine(WhseJnlLine, TempWhseJnlLine2, TempHandlingSpecification, false);
            if TempWhseJnlLine2.FindSet then
                repeat
                    WMSMgmt.CheckWhseJnlLine(TempWhseJnlLine2, 1, 0, false);
                    AddSourceDocumentInfo(TempWhseJnlLine2);
                    WhseJnlPostLine.Run(TempWhseJnlLine2);
                until TempWhseJnlLine2.Next = 0;
            PostWhseRoundingAdjmts; // P8001039
        end;
        if WMSMgmt.CreateWhseJnlLine(ItemJnlLine, ItemJnlTemplate.Type::Transfer, WhseJnlLine, true) then begin // P8001132
            ItemTrackingMgt.SplitWhseJnlLine(WhseJnlLine, TempWhseJnlLine2, TempHandlingSpecification, true);
            if TempWhseJnlLine2.FindSet then
                repeat
                    WMSMgmt.CheckWhseJnlLine(TempWhseJnlLine2, 1, 0, true);
                    AddSourceDocumentInfo(TempWhseJnlLine2);
                    WhseJnlPostLine.Run(TempWhseJnlLine2);
                until TempWhseJnlLine2.Next = 0;
        end;
        XferRegsFromWhse; // P8000888
        if (ItemJnlLine."Alt. Qty. Transaction No." <> 0) then
            AltQtyMgmt.DeleteItemJnlAltQtyLines(ItemJnlLine);
    end;

    procedure SetSourceDocumentLine(NewSourceTableNo: Integer; NewSourceDocumentType: Integer; NewSourceDocumentNo: Code[20]; NewSourceDocumentLineNo: Integer)
    begin
        SourceTableNo := NewSourceTableNo;
        SourceDocumentType := NewSourceDocumentType;
        SourceDocumentNo := NewSourceDocumentNo;
        SourceDocumentLineNo := NewSourceDocumentLineNo;
    end;

    local procedure AddSourceDocumentInfo(var WhseJnlLine: Record "Warehouse Journal Line")
    begin
        if (SourceTableNo <> 0) then
            with WhseJnlLine do begin
                "Source Type" := SourceTableNo;
                "Source Subtype" := SourceDocumentType;
                "Source No." := SourceDocumentNo;
                "Source Line No." := SourceDocumentLineNo;
                "Source Document" := WhseMgmt.GetSourceDocumentType("Source Type", "Source Subtype"); // P8001132
            end;
    end;

    procedure Transfer1DocPickInfo(var ItemJnlLine: Record "Item Journal Line")
    begin
        with ItemJnlLine do
            if ("Pick Source Type" <> 0) then begin
                TestField("Entry Type", "Entry Type"::Transfer);
                TestField("Pick Source No.");
                TestField("Pick Source Line No.");
                Transfer1DocLooseQty(ItemJnlLine);
            end;
    end;

    local procedure Transfer1DocLooseQty(var ItemJnlLine: Record "Item Journal Line")
    begin
        with ItemJnlLine do begin
            case "Pick Source Type" of
                "Pick Source Type"::"Sales Order":
                    Transfer1DocSale(ItemJnlLine);
                "Pick Source Type"::"Purchase Return Order":
                    Transfer1DocPurchase(ItemJnlLine);
                "Pick Source Type"::"Outbound Transfer":
                    Transfer1DocTransfer(ItemJnlLine);
            end;
        end;
    end;

    local procedure Transfer1DocSale(var ItemJnlLine: Record "Item Journal Line")
    var
        SalesLine: Record "Sales Line";
        ResEntry: Record "Reservation Entry";
        QtyToShipUpdated: Boolean;
    begin
        Set1DocResFilters(ItemJnlLine, ResEntry);
        with ItemJnlLine do begin
            SalesLine.Get(SalesLine."Document Type"::Order, "Pick Source No.", "Pick Source Line No.");
            SalesLine.TestField(Type, SalesLine.Type::Item);
            SalesLine.TestField("No.", "Item No.");
            if Add1DocAltQtyLines(
                 ItemJnlLine, SalesLine."Alt. Qty. Transaction No.", DATABASE::"Sales Line",
                 SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.")
            then begin
                AltQtyMgmt.UpdateSalesLine(SalesLine);
                // SalesLine.MODIFY;      // P8001312
                QtyToShipUpdated := true; // P8001312
            end;
            if ResEntry.FindSet then begin
                repeat
                    CreateReservEntry.CreateReservEntryFor(
                      DATABASE::"Sales Line", SalesLine."Document Type", SalesLine."Document No.", '', 0,
                      SalesLine."Line No.", SalesLine."Qty. per Unit of Measure",
                      -ResEntry.Quantity, -ResEntry."Quantity (Base)", ResEntry."Serial No.", ResEntry."Lot No."); // P8001132
                    CreateReservEntry.AddAltQtyData(ResEntry."Quantity (Alt.)");
                    CreateReservEntry.CreateEntry(
                      SalesLine."No.", SalesLine."Variant Code", SalesLine."Location Code",
                      SalesLine.Description, 0D, SalesLine."Shipment Date", 0, 2);
                until (ResEntry.Next = 0);
                SalesLine.GetLotNo;
                // P8001312
                if not QtyToShipUpdated then begin
                    SalesLine.Validate("Qty. to Ship", Round(TrackingQtyToHandle(SalesLine) / SalesLine."Qty. per Unit of Measure", 0.00001));
                    QtyToShipUpdated := true;
                end;
                //SalesLine.MODIFY;
                // P8001312
            end;
            // P8001312
            if not QtyToShipUpdated then begin
                SalesLine."Qty. to Ship" += ItemJnlLine.Quantity;
                if SalesLine."Outstanding Quantity" < SalesLine."Qty. to Ship" then
                    SalesLine."Qty. to Ship" := SalesLine."Outstanding Quantity";
                SalesLine.Validate("Qty. to Ship");
            end;
            SalesLine.Modify;
            // P8001312
        end;
    end;

    local procedure Transfer1DocPurchase(var ItemJnlLine: Record "Item Journal Line")
    var
        PurchLine: Record "Purchase Line";
        ResEntry: Record "Reservation Entry";
        QtyToShipUpdated: Boolean;
    begin
        Set1DocResFilters(ItemJnlLine, ResEntry);
        with ItemJnlLine do begin
            PurchLine.Get(PurchLine."Document Type"::"Return Order", "Pick Source No.", "Pick Source Line No.");
            PurchLine.TestField(Type, PurchLine.Type::Item);
            PurchLine.TestField("No.", "Item No.");
            if Add1DocAltQtyLines(
                 ItemJnlLine, PurchLine."Alt. Qty. Transaction No.", DATABASE::"Purchase Line",
                 PurchLine."Document Type", PurchLine."Document No.", PurchLine."Line No.")
            then begin
                AltQtyMgmt.UpdatePurchLine(PurchLine);
                //PurchLine.MODIFY;       // P8001312
                QtyToShipUpdated := true; // P8001312
            end;
            if ResEntry.FindSet then begin
                repeat
                    CreateReservEntry.CreateReservEntryFor(
                      DATABASE::"Purchase Line", PurchLine."Document Type", PurchLine."Document No.", '', 0,
                      PurchLine."Line No.", PurchLine."Qty. per Unit of Measure",
                      -ResEntry.Quantity, -ResEntry."Quantity (Base)", ResEntry."Serial No.", ResEntry."Lot No."); // P8001132
                    CreateReservEntry.AddAltQtyData(ResEntry."Quantity (Alt.)");
                    CreateReservEntry.CreateEntry(
                      PurchLine."No.", PurchLine."Variant Code", PurchLine."Location Code",
                      PurchLine.Description, 0D, PurchLine."Expected Receipt Date", 0, 2);
                until (ResEntry.Next = 0);
                PurchLine.GetLotNo;
                // P8001312
                if not QtyToShipUpdated then begin
                    PurchLine.Validate("Return Qty. to Ship", Round(TrackingQtyToHandle(PurchLine) / PurchLine."Qty. per Unit of Measure", 0.00001));
                    QtyToShipUpdated := true;
                end;
                //PurchLine.MODIFY;
                // P8001312
            end;
            // P8001312
            if not QtyToShipUpdated then begin
                PurchLine."Return Qty. to Ship" += ItemJnlLine.Quantity;
                if PurchLine."Outstanding Quantity" < PurchLine."Return Qty. to Ship" then
                    PurchLine."Return Qty. to Ship" := PurchLine."Outstanding Quantity";
                PurchLine.Validate("Return Qty. to Ship");
            end;
            PurchLine.Modify;
            // P8001312
        end;
    end;

    local procedure Transfer1DocTransfer(var ItemJnlLine: Record "Item Journal Line")
    var
        TransLine: Record "Transfer Line";
        ResEntry: Record "Reservation Entry";
        QtyToShipUpdated: Boolean;
    begin
        Set1DocResFilters(ItemJnlLine, ResEntry);
        with ItemJnlLine do begin
            TransLine.Get("Pick Source No.", "Pick Source Line No.");
            TransLine.TestField("Item No.", "Item No.");
            if Add1DocAltQtyLines(
                 ItemJnlLine, TransLine."Alt. Qty. Trans. No. (Ship)", DATABASE::"Transfer Line",
                 0, TransLine."Document No.", TransLine."Line No.")
            then begin
                AltQtyMgmt.UpdateTransLine(TransLine, 0);
                //TransLine.MODIFY;       // P8001312
                QtyToShipUpdated := true; // P8001312
            end;
            if ResEntry.FindSet then begin
                repeat
                    CreateReservEntry.CreateReservEntryFor(
                      DATABASE::"Transfer Line", 0, TransLine."Document No.", '', 0,
                      TransLine."Line No.", TransLine."Qty. per Unit of Measure",
                      -ResEntry.Quantity, -ResEntry."Quantity (Base)", ResEntry."Serial No.", ResEntry."Lot No."); // P8001132
                    CreateReservEntry.AddAltQtyData(ResEntry."Quantity (Alt.)");
                    CreateReservEntry.CreateEntry(
                      TransLine."Item No.", TransLine."Variant Code", TransLine."Transfer-from Code",
                      TransLine.Description, 0D, TransLine."Shipment Date", 0, 2);
                    CreateReservEntry.CreateReservEntryFor(
                      DATABASE::"Transfer Line", 1, TransLine."Document No.", '', 0,
                      TransLine."Line No.", TransLine."Qty. per Unit of Measure",
                      -ResEntry.Quantity, -ResEntry."Quantity (Base)", ResEntry."Serial No.", ResEntry."Lot No."); // P8001132
                    CreateReservEntry.AddAltQtyData(-ResEntry."Quantity (Alt.)");
                    CreateReservEntry.CreateEntry(
                      TransLine."Item No.", TransLine."Variant Code", TransLine."Transfer-to Code",
                      TransLine.Description, TransLine."Receipt Date", 0D, 0, 2);
                until (ResEntry.Next = 0);
                TransLine.GetLotNo;
                // P8001312
                if not QtyToShipUpdated then begin
                    TransLine.Validate("Qty. to Ship", Round(TrackingQtyToHandle(TransLine) / TransLine."Qty. per Unit of Measure", 0.00001));
                    QtyToShipUpdated := true;
                end;
                //TransLine.MODIFY;
                // P8001312
            end;
            // P8001312
            if not QtyToShipUpdated then begin
                TransLine."Qty. to Ship" += ItemJnlLine.Quantity;
                if TransLine."Outstanding Quantity" < TransLine."Qty. to Ship" then
                    TransLine."Qty. to Ship" := TransLine."Outstanding Quantity";
                TransLine.Validate("Qty. to Ship");
            end;
            TransLine.Modify;
            // P8001312
        end;
    end;

    local procedure Set1DocResFilters(var ItemJnlLine: Record "Item Journal Line"; var ResEntry: Record "Reservation Entry")
    begin
        with ItemJnlLine do begin
            ResEntry.SetCurrentKey(
              "Source Type", "Source Subtype", "Source ID", "Source Batch Name",
              "Source Prod. Order Line", "Source Ref. No.");
            ResEntry.SetRange("Source Type", DATABASE::"Item Journal Line");
            ResEntry.SetRange("Source Subtype", "Entry Type");
            ResEntry.SetRange("Source ID", "Journal Template Name");
            ResEntry.SetRange("Source Batch Name", "Journal Batch Name");
            ResEntry.SetRange("Source Prod. Order Line", 0);
            ResEntry.SetRange("Source Ref. No.", "Line No.");
        end;
    end;

    procedure TrackingQtyToHandle(SourceRec: Variant): Decimal
    var
        SourceRecRef: RecordRef;
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
        ReservEntry: Record "Reservation Entry";
        SalesLineReserve: Codeunit "Sales Line-Reserve";
        PurchLineReserve: Codeunit "Purch. Line-Reserve";
        TransLineReserve: Codeunit "Transfer Line-Reserve";
    begin
        // P8001312
        SourceRecRef.GetTable(SourceRec);
        case SourceRecRef.Number of
            DATABASE::"Sales Line":
                begin
                    SalesLine := SourceRec;
                    SalesLine.SetReservationFilters(ReservEntry); // P800131478
                end;
            DATABASE::"Purchase Line":
                begin
                    PurchLine := SourceRec;
                    PurchLine.SetReservationFilters(ReservEntry); // P800131478
                end;
            DATABASE::"Transfer Line":
                begin
                    TransLine := SourceRec;
                    TransLine.SetReservationFilters(ReservEntry, "Transfer Direction"::Outbound); // P800131478
                end;
        end;

        ReservEntry.SetCurrentKey("Source Type", "Source ID", "Source Batch Name", "Source Ref. No.", "Lot No.");
        ReservEntry.SetFilter("Lot No.", '<>%1', '');
        ReservEntry.CalcSums("Qty. to Handle (Base)");
        exit(-ReservEntry."Qty. to Handle (Base)");
    end;

    local procedure Add1DocAltQtyLines(var ItemJnlLine: Record "Item Journal Line"; var AltQtyTransNo: Integer; TableNo: Integer; DocType: Option; DocNo: Code[20]; DocLineNo: Integer): Boolean
    var
        AltQtyLine: Record "Alternate Quantity Line";
        AltQtyLine2: Record "Alternate Quantity Line";
        AltQtyLineNo: Integer;
    begin
        if (ItemJnlLine."Alt. Qty. Transaction No." = 0) then
            exit(false);
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", ItemJnlLine."Alt. Qty. Transaction No.");
        if AltQtyLine.IsEmpty then
            exit(false);
        if (AltQtyTransNo = 0) then
            AltQtyMgmt.AssignNewTransactionNo(AltQtyTransNo)
        else begin
            AltQtyLine2.SetRange("Alt. Qty. Transaction No.", AltQtyTransNo);
            if AltQtyLine2.FindLast then
                AltQtyLineNo := AltQtyLine2."Line No.";
        end;
        AltQtyLine.FindSet;
        repeat
            AltQtyLine2 := AltQtyLine;
            with AltQtyLine2 do begin
                "Alt. Qty. Transaction No." := AltQtyTransNo;
                AltQtyLineNo := AltQtyLineNo + 10000;
                "Line No." := AltQtyLineNo;
                "Table No." := TableNo;
                "Document Type" := DocType;
                "Document No." := DocNo;
                "Journal Template Name" := '';
                "Journal Batch Name" := '';
                "Source Line No." := DocLineNo;
                Insert;
            end;
        until (AltQtyLine.Next = 0);
        exit(true);
    end;

    local procedure XferRegsToWhse()
    var
        ItemReg2: Record "Item Register";
        ItemApplnEntryNo2: Integer;
        WhseReg2: Record "Warehouse Register";
        GLReg2: Record "G/L Register";
        NextVATEntryNo2: Integer;
        NextTransactionNo2: Integer;
    begin
        // P8000888
        ItemJnlPostLine.GetRegisters(ItemReg2, ItemApplnEntryNo2, WhseReg2, GLReg2, NextVATEntryNo2, NextTransactionNo2, WhseJnlPostLine);  //P80045166
        WhseJnlPostLine.SetRegisters(ItemReg2, ItemApplnEntryNo2, WhseReg2, GLReg2, NextVATEntryNo2, NextTransactionNo2);
    end;

    local procedure XferRegsFromWhse()
    var
        ItemReg2: Record "Item Register";
        ItemApplnEntryNo2: Integer;
        WhseReg2: Record "Warehouse Register";
        GLReg2: Record "G/L Register";
        NextVATEntryNo2: Integer;
        NextTransactionNo2: Integer;
    begin
        // P8000888
        WhseJnlPostLine.GetRegisters(ItemReg2, ItemApplnEntryNo2, WhseReg2, GLReg2, NextVATEntryNo2, NextTransactionNo2);
        ItemJnlPostLine.SetRegisters(ItemReg2, ItemApplnEntryNo2, WhseReg2, GLReg2, NextVATEntryNo2, NextTransactionNo2);
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

