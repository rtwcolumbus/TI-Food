page 37002096 "Lot Reservations Subform"
{
    // See documentation notes in the "Lot Reservations" form for the importance of the UseLotPref variable.
    // 
    // PR3.70.08
    // P8000165A, Myers Nissi, Jack Reynolds, 13 FEB 05
    //   Subform for lot reservations to display available lots and allow entry of quantity to reserve
    // 
    // PR4.00
    // P8000251A, Myers Nissi, Jack Reynolds, 20 OCT 05
    //   Support for Expiration Date and Days to Expire
    // 
    // PR4.00.03
    // P8000325A, VerticalSoft, Jack Reynolds, 01 MAY 06
    //   CreateReservation - modify call to CreateReservEntry for new parameter for expiration date
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Don Bresee, 12 JUN 07
    //   Eliminate parameter for Expiration Date
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 16 APR 09
    //   Transformed - additions in TIF Editor
    //   Page changes made after transformation
    // 
    // PRW16.00.04
    // P8000899, Columbus IT, Ron Davidson, 02 MAR 11
    //   Added Freshness Date logic.
    // 
    // PRW16.00.05
    // P8000969, Columbus IT, Jack Reynolds, 12 AUG 11
    //   Fix problem with Freshness Calc. Method
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001070, Columbus IT, Jack Reynolds, 07 JAN 13
    //   Support for Lot Freshness
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.00.01
    // P8001166, Columbus IT, Jack Reynolds, 30 MAY 13
    //   Don't allow editing of freshness calculation method
    // 
    // PRW17.10
    // P8001213, Columbus IT, Jack Reynolds, 26 SEP 13
    //   NAV 2013 R2 changes
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 9 NOV 15
    //   NAV 2016 refactoring
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW120.00
    // P800144605, To Increase, Jack Reynolds, 20 APR 22
    //   Upgrade to 20.0

    Caption = 'Lot Reservations Subform';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Lot No. Information";
    SourceTableView = SORTING("Item Category Code", "Item No.", "Creation Date", "Variant Code", "Lot No.")
                      WHERE(Inventory = FILTER(<> 0));

    layout
    {
        area(content)
        {
            repeater(Control37002002)
            {
                ShowCaption = false;
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Release Date"; "Release Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Creation Date"; "Creation Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Expiration Date"; "Expiration Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Freshness Date"; "Freshness Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item.""Freshness Calc. Method"""; Item."Freshness Calc. Method")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Freshness Calc. Method';
                    Editable = false;
                }
                field(Inventory; Inventory)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'On Hand';
                }
                field(Reserved; Reserved)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Reserved';
                    DecimalPlaces = 0 : 5;
                    Editable = false;

                    trigger OnDrillDown()
                    var
                        ResEntry: Record "Reservation Entry";
                        ResEntry2: Record "Reservation Entry";
                        TempResEntry: Record "Reservation Entry" temporary;
                    begin
                        ResEntry.SetCurrentKey("Reservation Status", "Item No.", "Variant Code", "Location Code", "Source Type",
                          "Source Subtype", "Lot No.", "Serial No.");
                        ResEntry.SetRange("Reservation Status", ResEntry."Reservation Status"::Reservation);
                        ResEntry.SetRange("Item No.", "Item No.");
                        ResEntry.SetRange("Variant Code", "Variant Code");
                        ResEntry.SetRange("Location Code", LocationCode);
                        ResEntry.SetRange("Source Type", DATABASE::"Item Ledger Entry");
                        ResEntry.SetRange("Lot No.", "Lot No.");
                        ResEntry.SetRange(Positive, true);
                        if ResEntry.Find('-') then
                            repeat
                                if (not ResEntry2.Get(ResEntry."Entry No.", false)) or
                                  (ResEntry2."Source Type" <> ItemDemand."Source Table") or
                                  (ResEntry2."Source Subtype" <> ItemDemand."Source Subtype") or
                                  (ResEntry2."Source ID" <> ItemDemand."Document No.") or
                                  (ResEntry2."Source Prod. Order Line" <> ItemDemand."Prod. Order Line No.") or
                                  (ResEntry2."Source Ref. No." <> ItemDemand."Line No.")
                                then begin
                                    TempResEntry := ResEntry;
                                    TempResEntry.Insert;
                                end;
                            until ResEntry.Next = 0;

                        PAGE.RunModal(0, TempResEntry);
                    end;
                }
                field("Inventory - Reserved"; Inventory - Reserved)
                {
                    ApplicationArea = FOODBasic;
                    BlankNumbers = BlankNeg;
                    Caption = 'Available';
                    DecimalPlaces = 0 : 5;
                }
                field(QtyToReserve; QtyToReserve)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Qty. to Reserve';
                    DecimalPlaces = 0 : 5;
                    MinValue = 0;

                    trigger OnValidate()
                    var
                        ResEntry: Record "Reservation Entry";
                        MaxQtyAvail: Decimal;
                        MaxQtyRequired: Decimal;
                    begin
                        if QtyToReserve <> xQtyToReserve then begin
                            ResEntry.LockTable;
                            CalcFields(Inventory, "Reserved Quantity");
                            MaxQtyAvail := Inventory - "Reserved Quantity" + xQtyToReserve;
                            if MaxQtyAvail < QtyToReserve then
                                Error(Text002, MaxQtyAvail, "Lot No.");
                            ItemDemand.CalcFields("Reserved Quantity (Base)");
                            MaxQtyRequired := ItemDemand."Quantity (Base)" - ItemDemand."Reserved Quantity (Base)" + xQtyToReserve;
                            if MaxQtyRequired < QtyToReserve then
                                Error(Text003, MaxQtyRequired, ItemDemand.SourceDescription);
                            DeleteCurrentReservation;
                            CreateReservation(QtyToReserve);
                            UpdateSourceLotNo;
                        end;
                        xQtyToReserve := QtyToReserve; // P8000664
                    end;
                }
                field("LotFilterFns.Age(Rec)"; LotFilterFns.Age(Rec))
                {
                    ApplicationArea = FOODBasic;
                    BlankNumbers = BlankNeg;
                    Caption = 'Age';
                }
                field("LotFilterFns.AgeCategory(Rec)"; LotFilterFns.AgeCategory(Rec))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Age Category';
                }
                field("LotFilterFns.AgeDate(Rec)"; LotFilterFns.AgeDate(Rec))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Current Age Date';
                }
                field("FormatDays(LotFilterFns.RemainingDays(Rec))"; FormatDays(LotFilterFns.RemainingDays(Rec)))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Remaining Days';
                }
                field("FormatDays(LotFilterFns.DaysToExpire(Rec))"; FormatDays(LotFilterFns.DaysToExpire(Rec)))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Days to Expire';
                }
                field("ShortcutLotSpec[1]"; ShortcutLotSpec[1])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '37002020,1';
                    Editable = false;
                    Visible = false;
                }
                field("ShortcutLotSpec[2]"; ShortcutLotSpec[2])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '37002020,2';
                    Editable = false;
                    Visible = false;
                }
                field("ShortcutLotSpec[3]"; ShortcutLotSpec[3])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '37002020,3';
                    Editable = false;
                    Visible = false;
                }
                field("ShortcutLotSpec[4]"; ShortcutLotSpec[4])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '37002020,4';
                    Editable = false;
                    Visible = false;
                }
                field("ShortcutLotSpec[5]"; ShortcutLotSpec[5])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '37002020,5';
                    Editable = false;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Lot")
            {
                Caption = '&Lot';
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = EditLines;
                    ShortCutKey = 'Shift+Ctrl+F5';

                    trigger OnAction()
                    begin
                        //This functionality was copied from page #37002095. Unsupported part was commented. Please check it.
                        /*CurrPage.Lots.PAGE.*/
                        ShowLotInfo;

                    end;
                }
                action("Item Tracking Entries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Tracking Entries';
                    Image = ItemTrackingLedger;
                    ShortCutKey = 'Ctrl+F7';

                    trigger OnAction()
                    begin
                        //This functionality was copied from page #37002095. Unsupported part was commented. Please check it.
                        /*CurrPage.Lots.PAGE.*/
                        ShowLotEntries;

                    end;
                }
                action("Quality Control")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Quality Control';

                    trigger OnAction()
                    begin
                        //This functionality was copied from page #37002095. Unsupported part was commented. Please check it.
                        /*CurrPage.Lots.PAGE.*/
                        ShowLotQC;

                    end;
                }
                action("Lot &Specifications")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Lot &Specifications';

                    trigger OnAction()
                    begin
                        //This functionality was copied from page #37002095. Unsupported part was commented. Please check it.
                        /*CurrPage.Lots.PAGE.*/
                        ShowLotSpecifications;

                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ShowShortcutLotSpec(ShortcutLotSpec);
        QtyToReserve := GetCurrentReservation;
        CalcFields("Reserved Quantity");
        Reserved := "Reserved Quantity" - QtyToReserve;
        xQtyToReserve := QtyToReserve; // P8000664
        // P8000899
        Item.Get("Item No.");
        //SetFreshDateStyleExpr := Item.UseFreshnessDate AND ("Freshness Date" < TODAY); // P8000969, P8001070
        // P8000899
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        Direction: Integer;
        EOF: Boolean;
        i: Integer;
    begin
        Clear(ShortcutLotSpec);

        if not UseLotPref then
            exit(Find(Which));

        for i := 1 to StrLen(Which) do begin
            EOF := false;
            case Which[i] of
                '-', '>':
                    Direction := 1;
                '+', '<':
                    Direction := -1;
                '=':
                    Direction := 0;
            end;
            EOF := not Find(CopyStr(Which, i, 1));
            while (not EOF) and (not LotFilterFns.LotInFilter(Rec, LotAgeFilter, LotSpecFilter,  // P8001070
              ItemDemand."Freshness Calc. Method", ItemDemand."Oldest Accept. Freshness Date")) // P8001070
            do                                                                                 // P8001070
                EOF := Next(Direction) = 0;
            if not EOF then
                exit(true);
        end;
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        NextRec: Record "Lot No. Information";
        Direction: Integer;
        NoSteps: Integer;
        StepsTaken: Integer;
        EOF: Boolean;
    begin
        if not UseLotPref then
            exit(Next(Steps));

        NextRec := Rec;
        Direction := 1;
        if Steps < 0 then
            Direction := -1;
        NoSteps := Direction * Steps;
        while (StepsTaken < NoSteps) and (not EOF) do begin
            EOF := Next(Direction) = 0;
            if (not EOF) and LotFilterFns.LotInFilter(Rec, LotAgeFilter, LotSpecFilter,         // P8001070
              ItemDemand."Freshness Calc. Method", ItemDemand."Oldest Accept. Freshness Date") // P8001070
            then begin                                                                        // P8001070
                NextRec := Rec;
                StepsTaken += 1;
            end;
        end;
        Rec := NextRec;
        exit(Direction * StepsTaken);
    end;

    var
        UseLotPref: Boolean;
        ItemDemand: Record "Item Demand";
        LotAgeFilter: Record "Lot Age";
        LotSpecFilter: Record "Lot Specification Filter" temporary;
        LotFilterFns: Codeunit "Lot Filtering";
        ShortcutLotSpec: array[5] of Code[50];
        Text001: Label 'N/A';
        LocationCode: Code[10];
        Reserved: Decimal;
        QtyToReserve: Decimal;
        xQtyToReserve: Decimal;
        Text002: Label 'Only %1 is available for lot %2.';
        Text003: Label 'Only %1 is required for %2.';
        Item: Record Item;

    procedure SetFilters(ItemNo: Code[20]; VariantCode: Code[10]; LocCode: Code[10]; Demand: Record "Item Demand"; var LotAgePref: Record "Lot Age Filter"; var LotSpecPref: Record "Lot Specification Filter" temporary)
    begin
        ItemDemand := Demand;
        LocationCode := LocCode;

        FilterGroup(4);
        SetRange("Item No.", ItemNo);
        SetRange("Variant Code", VariantCode);
        SetRange("Location Filter", LocationCode);
        FilterGroup(0);

        Clear(LotAgeFilter);
        LotSpecFilter.Reset;
        LotSpecFilter.DeleteAll;
        if LotAgePref."Age Filter" <> '' then
            LotAgeFilter.SetFilter(Age, LotAgePref."Age Filter");
        if LotAgePref."Category Filter" <> '' then
            LotAgeFilter.SetFilter("Age Category", LotAgePref."Category Filter");
        if LotSpecPref.Find('-') then
            repeat
                LotSpecFilter := LotSpecPref;
                LotSpecFilter.Insert;
            until LotSpecPref.Next = 0;

        if Demand."Date Required" < Today then
            LotFilterFns.SetAgingDate(Today)
        else
            LotFilterFns.SetAgingDate(Demand."Date Required");

        CurrPage.Update;
    end;

    procedure SetReservationFilter(var ResEntry: Record "Reservation Entry")
    begin
        ResEntry.SetCurrentKey("Reservation Status", "Item No.", "Variant Code", "Location Code",
          "Source Type", "Source Subtype", "Lot No.", "Serial No.");
        ResEntry.SetRange("Reservation Status", ResEntry."Reservation Status"::Reservation);
        ResEntry.SetRange("Item No.", "Item No.");
        ResEntry.SetRange("Variant Code", "Variant Code");
        ResEntry.SetRange("Location Code", LocationCode);
        ResEntry.SetRange("Source Type", ItemDemand."Source Table");
        ResEntry.SetRange("Source Subtype", ItemDemand."Source Subtype");
        ResEntry.SetRange("Source ID", ItemDemand."Document No.");
        ResEntry.SetRange("Source Prod. Order Line", ItemDemand."Prod. Order Line No.");
        ResEntry.SetRange("Source Ref. No.", ItemDemand."Line No.");
        ResEntry.SetRange("Lot No.", "Lot No.");
    end;

    procedure GetCurrentReservation() Qty: Decimal
    var
        ResEntry: Record "Reservation Entry";
    begin
        SetReservationFilter(ResEntry);
        if ResEntry.Find('-') then
            repeat
                Qty -= ResEntry."Quantity (Base)";
            until ResEntry.Next = 0;
    end;

    procedure DeleteCurrentReservation()
    var
        ResEntry: Record "Reservation Entry";
        ResEntry2: Record "Reservation Entry";
    begin
        SetReservationFilter(ResEntry);
        if ResEntry.Find('-') then
            repeat
                ResEntry2.Get(ResEntry."Entry No.", not ResEntry.Positive);
                ResEntry.Delete(true);
                ResEntry2.Delete(true);
            until ResEntry.Next = 0;
    end;

    procedure CreateReservation(QtyToReserve: Decimal)
    var
        ItemLedger: Record "Item Ledger Entry";
        FromTrackingSpecification: Record "Tracking Specification";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        QtyAvail: Decimal;
        QtyToReserveThisEntry: Decimal;
        QtyToReserveThisEntryBase: Decimal;
    begin
        if QtyToReserve = 0 then
            exit;
        ItemLedger.SetCurrentKey("Item No.", "Variant Code", "Drop Shipment", "Location Code", "Lot No.", "Serial No.");
        ItemLedger.SetRange("Item No.", "Item No.");
        ItemLedger.SetRange("Variant Code", "Variant Code");
        ItemLedger.SetRange("Drop Shipment", false);
        ItemLedger.SetRange("Location Code", LocationCode);
        ItemLedger.SetRange("Lot No.", "Lot No.");
        ItemLedger.SetRange(Positive, true);
        ItemLedger.SetFilter("Remaining Quantity", '<>0');
        if ItemLedger.Find('-') then
            repeat
                ItemLedger.CalcFields("Reserved Quantity");
                QtyAvail := ItemLedger."Remaining Quantity" - ItemLedger."Reserved Quantity";
                if QtyAvail > QtyToReserve then
                    QtyToReserveThisEntryBase := QtyToReserve // P8001132
                else
                    QtyToReserveThisEntryBase := QtyAvail;    // P8001132
                QtyToReserveThisEntry := Round(QtyToReserveThisEntryBase / ItemDemand."Qty. per Unit of Measure", 0.00001); // P8001132
                QtyToReserve -= QtyToReserveThisEntry;
                CreateReservEntry.CreateReservEntryFor(
                  ItemDemand."Source Table", ItemDemand."Source Subtype", ItemDemand."Document No.",
                  '', ItemDemand."Prod. Order Line No.", ItemDemand."Line No.",
                  ItemDemand."Qty. per Unit of Measure", QtyToReserveThisEntry, QtyToReserveThisEntryBase, // P8001132
                  ItemLedger."Serial No.", ItemLedger."Lot No."); // P8000325A, P8000466A
                // P800131478
                FromTrackingSpecification.InitTrackingSpecification(DATABASE::"Item Ledger Entry", 0, '', '', 0,
                    ItemLedger."Entry No.", ItemLedger."Variant Code", ItemLedger."Location Code", 1);
                FromTrackingSpecification.CopyTrackingFromItemLedgEntry(ItemLedger);
                CreateReservEntry.CreateReservEntryFrom(FromTrackingSpecification);
                // P800131478
                CreateReservEntry.CreateReservEntry(
                  "Item No.", "Variant Code", LocationCode,
                  Description, 0D, ItemDemand."Date Required"); // P8001213
            until (ItemLedger.Next = 0) or (QtyToReserve = 0);
    end;

    procedure UpdateSourceLotNo()
    var
        SalesLine: Record "Sales Line";
        ProdOrderComp: Record "Prod. Order Component";
        TransferLine: Record "Transfer Line";
    begin
        case ItemDemand.Type of
            ItemDemand.Type::Sales:
                begin
                    SalesLine.Get(ItemDemand."Source Subtype", ItemDemand."Document No.", ItemDemand."Line No.");
                    SalesLine.GetLotNo;
                    SalesLine.Modify;
                end;
            ItemDemand.Type::Production:
                begin
                    ProdOrderComp.Get(ItemDemand."Source Subtype", ItemDemand."Document No.",
                      ItemDemand."Prod. Order Line No.", ItemDemand."Line No.");
                    ProdOrderComp.GetLotNo;
                    ProdOrderComp.Modify;
                end;
            ItemDemand.Type::Transfer:
                begin
                    TransferLine.Get(ItemDemand."Document No.", ItemDemand."Line No.");
                    TransferLine.GetLotNo;
                    TransferLine.Modify;
                end;
        end;
    end;

    procedure ShowLotInfo()
    var
        LotInfo: Record "Lot No. Information";
    begin
        LotInfo := Rec;
        LotInfo.SetRecFilter;
        PAGE.RunModal(PAGE::"Lot No. Information Card", LotInfo);
        LotInfo.Find;
        if LotInfo."Creation Date" <> "Creation Date" then begin
            Rec := LotInfo;
            LotFilterFns.ClearLotAge(Rec);
        end;
    end;

    procedure ShowLotEntries()
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
        ItemTrackingDocMgt: Codeunit "Item Tracking Doc. Management";
    begin
        ItemTrackingSetup."Lot No." := Rec."Lot No."; // P800144605
        ItemTrackingDocMgt.ShowItemTrackingForEntity(0, '', Rec."Item No.", Rec."Variant Code", '', ItemTrackingSetup); // P8004516, P800144605
    end;

    procedure ShowLotSpecifications()
    var
        LotSpecification: Record "Lot Specification";
    begin
        LotSpecification.SetRange("Item No.", "Item No.");
        LotSpecification.SetRange("Variant Code", "Variant Code");
        LotSpecification.SetRange("Lot No.", "Lot No.");
        PAGE.RunModal(PAGE::"Lot Specifications", LotSpecification);
    end;

    procedure ShowLotQC()
    var
        QCHeader: Record "Quality Control Header";
    begin
        QCHeader.SetRange("Item No.", "Item No.");
        QCHeader.SetRange("Variant Code", "Variant Code");
        QCHeader.SetRange("Lot No.", "Lot No.");
        PAGE.RunModal(PAGE::"Quality Control", QCHeader);
    end;

    procedure SetUseLotPref(flag: Boolean)
    begin
        UseLotPref := flag;
    end;

    local procedure xQtyToReserveOnBeforeInput()
    begin
        xQtyToReserve := QtyToReserve;
    end;

    procedure FormatDays(Days: Integer): Text[10]
    begin
        // P8000664
        if Days = 0 then
            exit('')
        else
            if Days = 2147483647 then
                exit(Text001)
            else
                exit(Format(Days));
    end;
}

