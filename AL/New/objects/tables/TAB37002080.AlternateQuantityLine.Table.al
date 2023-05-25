table 37002080 "Alternate Quantity Line"
{
    // PR3.60
    //   Create table/logic for alternate quantity entry
    // 
    // PR3.61
    //   Add Fields
    //     Container Transaction No.
    //   Add logic for transfer orders
    //   Add logic for containers
    // 
    // PR3.70
    //   Remove references to Bin Code in reservation entry table
    // 
    // PR3.70.05
    // P8000052A, Myers Nissi, Jack Reynolds, 04 JUN 04
    //   OnInsert - call ValidateQuantity
    // 
    // PR3.70.06
    // P8000108A, Myers Nissi, Jack Reynolds, 03 SEP 04
    //   Remove changes from P8000052A
    // 
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Support for checking lot preferences
    // 
    // PR3.70.08
    // P8000172A, Myers Nissi, Jack Reynolds, 09 FEB 05
    //   CheckLotPreferences - exit with TRUE if source table is not sales line or item journal line
    // 
    // PR4.00.01
    // P8000267B, VerticalSoft, Jack Reynolds, 12 DEC 05
    //   Changes to Item Ledger keys
    // 
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   P800 WMS project
    // 
    // PR5.00
    // P8000504A, VerticalSoft, Jack Reynolds, 08 AUG 07
    //   Support for alternate quantities
    // 
    // PRW15.00.01
    // P8000538A, VerticalSoft, Jack Reynolds, 22 OCT 07
    //   Prohibit zero alternate quantity
    // 
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   Support for delivery trip pick lines
    // 
    // P8000566A, VerticalSoft, Jack Reynolds, 28 MAY 08
    //   Fix problem with reclass, lot tracking, and alternate quantity
    // 
    // P8000664, VerticalSoft, Jimmy Abidi, 15 JAN 10
    //   Use AutoFormatType and AutoFormatExpr field properties
    // 
    // PRW16.00.06
    // P8001070, Columbus IT, Jack Reynolds, 16 MAY 12
    //   Bring Lot Freshness and Lot Preferences together
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW19.00
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup old delivery trips
    // 
    // P8004516, To-Increase, Jack Reynolds, 17 MAR 16
    //   Incorporate modifications for NAV Anywhere processes
    // 
    // PRW19.00.01
    // P8008508, To-Increase, Jack Reynolds, 01 MAR 17
    //   Problem with containers, alternate quantity, and warehouse movement
    // 
    // PRW111.00.02
    // P80070336, To Increase, Jack Reynolds, 12 FEB 19
    //   Fix issue with Alternate Quantity to Handle
    // 
    // PRW111.00.03
    // P80079300, To-Increase, Gangabhushan, 24 JUL 19
    //   CS00071299 - Users are able to specify more qty and qty alt in the alt qty entery page
    // 
    // P80080576, To-Increase, Gangabhushan, 19 AUG 19
    //   Changes to Rounding function
    // 
    // P80079981, To-Increase, Gangabhushan, 23 AUG 19
    //   Qty to Handle data not get refreshed in Pick lines for Multiple UOM functionality.
    // 
    // P80083828, To-Increase, Gangabhushan, 04 OCT 19
    //   CS00076976 - Quantity in alternate quantity entry is incorrect
    // 
    // P80085559, To-Increase, Gangabhushan, 30 OCT 19
    //   CS00079256 - New scenario causing issue after implementing change for CS00076976
    // 
    // P80081811, To-Increase, Gangabhushan, 30 OCT 19
    //   Catchweight item while doing transfer system allowing for Qty to ship Qty.
    //
    //   PRW111.00.03
    //   P80088888, To-Increase, Gangabhushan, 09 JAN 2020
    //     Repack order changes
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // PRW118.01
    // P800127049, To Increase, Jack Reynolds, 23 AUG 21
    //   Support for Inventory documents
    //
    // PRW118.01
    // P800128960, To Increase, Jack Reynolds, 24 AUG 21
    //   Decimal precision on alternate quantity data entry
    // 
    // PRW119.0
    // P800133109, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 19.0 - Qty. Rounding Precision

    Caption = 'Alternate Quantity Line';
    DrillDownPageID = "Alternate Quantity Lines";
    LookupPageID = "Alternate Quantity Lines";

    fields
    {
        field(1; "Alt. Qty. Transaction No."; Integer)
        {
            Caption = 'Alt. Qty. Transaction No.';
            Editable = false;
        }
        field(2; "Table No."; Integer)
        {
            BlankZero = true;
            Caption = 'Table No.';
            Editable = false;
        }
        field(3; "Document Type"; Option)
        {
            Caption = 'Document Type';
            Editable = false;
            OptionMembers = " ","Order",Invoice,"Credit Memo",,"Return Order";
        }
        field(4; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
        }
        field(5; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            Editable = false;
        }
        field(6; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            Editable = false;
        }
        field(7; "Source Line No."; Integer)
        {
            Caption = 'Source Line No.';
            Editable = false;
        }
        field(8; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(9; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            Description = 'PR3.61';

            trigger OnValidate()
            begin
                if "Container ID" <> '' then // PR3.61, ***
                    Error(Text007);            // PR3.61

                if ("Lot No." = '') then
                    exit;

                TestTrackingOn;
                if not CheckLotPreferences("Lot No.", true) then // P8000153A
                    Error(Text008, "Lot No.");                     // P8000153A, P8001070

                if not SourceTrackingLine.Positive then begin
                    SetTrackingEntryFilters(ItemTrackingEntry);
                    SetLotSerialEntryFilters(ItemTrackingEntry, "Lot No.", '');
                    if not ItemTrackingEntry.Find('-') then
                        Error(Text001, FieldCaption("Lot No."), "Lot No.");
                end;

                // P8000566A
                if "Table No." = DATABASE::"Item Journal Line" then begin
                    GetSource;
                    if ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Transfer then
                        "New Lot No." := "Lot No.";
                end;
                // P8000566A
            end;
        }
        field(10; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
            Description = 'PR3.61';

            trigger OnValidate()
            begin
                if "Container ID" <> '' then // PR3.61, ***
                    Error(Text007);            // PR3.61

                if ("Serial No." = '') then
                    exit;

                TestTrackingOn;

                if not SourceTrackingLine.Positive then begin
                    SetTrackingEntryFilters(ItemTrackingEntry);
                    SetLotSerialEntryFilters(ItemTrackingEntry, "Lot No.", "Serial No.");
                    if not ItemTrackingEntry.Find('-') then
                        Error(Text001, FieldCaption("Serial No."), "Serial No.");
                end;

                Validate("Quantity (Base)", 1);
            end;
        }
        field(11; "New Lot No."; Code[50])
        {
            Caption = 'New Lot No.';

            trigger OnValidate()
            var
                AltQtyLine: Record "Alternate Quantity Line";
            begin
                // P8000566A
                if "New Lot No." <> '' then begin
                    TestTrackingOn;
                    if "Table No." <> DATABASE::"Item Journal Line" then
                        Error(Text010, FieldCaption("New Lot No."))
                    else begin
                        GetSource;
                        if ItemJnlLine."Entry Type" <> ItemJnlLine."Entry Type"::Transfer then
                            Error(Text010, FieldCaption("New Lot No."))
                    end;

                    AltQtyLine.SetCurrentKey("Alt. Qty. Transaction No.", "Serial No.", "Lot No.");
                    AltQtyLine.SetRange("Alt. Qty. Transaction No.", "Alt. Qty. Transaction No.");
                    AltQtyLine.SetRange("Serial No.", "Serial No.");
                    AltQtyLine.SetRange("Lot No.", "Lot No.");
                    AltQtyLine.SetFilter("New Lot No.", '<>%1', "New Lot No.");
                    if not AltQtyLine.IsEmpty then
                        Error(Text011, TableCaption, FieldCaption("Lot No."), "Lot No.");
                end;
            end;
        }
        field(12; "Quantity (Base)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.61';

            trigger OnValidate()
            begin
                if "Container ID" <> '' then // PR3.61, ***
                    Error(Text007);            // PR3.61

                GetSource;
                Quantity := Round(("Quantity (Base)" / BaseQtyPerEntryUOM), 0.00001); // P80083828
                if (CurrFieldNo = FieldNo("Quantity (Base)")) then
                    ValidateQuantity;

                InitInvoicedQty;
            end;
        }
        field(13; "Quantity (Alt.)"; Decimal)
        {
            AutoFormatExpression = GetitemNo();
            AutoFormatType = 37002080;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,2,0,%1,%2,%3,%4,%5,%6', "Table No.", "Document Type", "Document No.", "Journal Template Name", "Journal Batch Name", "Source Line No.");
            Caption = 'Quantity (Alt.)';
            Description = 'PR3.61';

            trigger OnValidate()
            begin
                if "Container ID" <> '' then // PR3.61, ***
                    Error(Text007);            // PR3.61

                if (CurrFieldNo = FieldNo("Quantity (Alt.)")) then begin
                    GetSource;
                    TestSourceStatus; // P80070336
                    if ("Table No." <> DATABASE::"Item Journal Line") then begin
                        TestField("Quantity (Alt.)");
                        TestField(Quantity);
                    end else
                        if
                 // P8000538A
                 (("Quantity (Alt.)" = 0) and (Abs(ItemJnlLine."Quantity (Alt.)") > 0)) or
                 (not (ItemJnlLine."Entry Type" in [ItemJnlLine."Entry Type"::"Positive Adjmt.", ItemJnlLine."Entry Type"::"Negative Adjmt."]))
               then
                            TestField("Quantity (Alt.)");
                    // P8000538A
                    AltQtyMgmt.CheckTolerance(Item."No.", FieldCaption("Quantity (Alt.)"),
                                              "Quantity (Base)", "Quantity (Alt.)");
                end;

                InitInvoicedQty;
            end;
        }
        field(14; "Invoiced Qty. (Base)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Invoiced Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(15; "Invoiced Qty. (Alt.)"; Decimal)
        {
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,2,6,%1,%2,%3,%4,%5,%6', "Table No.", "Document Type", "Document No.", "Journal Template Name", "Journal Batch Name", "Source Line No.");
            Caption = 'Invoiced Qty. (Alt.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(18; Quantity; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.61';

            trigger OnValidate()
            var
                UOMMgt: Codeunit "Unit of Measure Management";
            begin
                if "Container ID" <> '' then // PR3.61, ***
                    Error(Text007);            // PR3.61
                GetSource;
                // P800133109
                Quantity := UOMMgt.RoundAndValidateQty(Quantity, QtyRoundingPrecision, FieldCaption(Quantity));
                "Quantity (Base)" := UOMMgt.CalcBaseQty('', '', UnitOfMeasure, Quantity, BaseQtyPerEntryUOM, QtyRoundingPrecisionBase, '', '', '');
                // P800133109
                if (CurrFieldNo = FieldNo(Quantity)) then begin // P80070336
                    TestSourceStatus; // P80070336
                    TestSourceLineLocation; // P80081811
                    ValidateQuantity;
                end; // P80070336

                InitInvoicedQty;
            end;
        }
        field(37002000; "Additional Ref. ID"; RecordID)
        {
            Caption = 'Additional Ref. ID';
            DataClassification = SystemMetadata;
        }
        field(37002562; "Container ID"; Code[20])
        {
            Caption = 'Container ID';
            TableRelation = "Container Header";
        }
        field(37002563; "Container Line No."; Integer)
        {
            Caption = 'Container Line No.';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Alt. Qty. Transaction No.", "Line No.")
        {
            SumIndexFields = "Quantity (Base)", "Quantity (Alt.)";
        }
        key(Key2; "Table No.", "Document Type", "Document No.", "Journal Template Name", "Journal Batch Name", "Source Line No.", "Line No.")
        {
            SumIndexFields = "Quantity (Base)", "Quantity (Alt.)";
        }
        key(Key3; "Table No.", "Document Type", "Document No.", "Source Line No.", "Line No.")
        {
            SumIndexFields = "Quantity (Base)", "Quantity (Alt.)";
        }
        key(Key4; "Alt. Qty. Transaction No.", "Serial No.", "Lot No.")
        {
            SumIndexFields = "Quantity (Base)", "Quantity (Alt.)";
        }
        key(Key5; "Container ID")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if "Container ID" <> '' then // PR3.61, ***
            Error(Text007);            // PR3.61

        TestSourceStatus; // P80070336
    end;

    var
        ItemJnlLine: Record "Item Journal Line";
        InvtDocLine: Record "Invt. Document Line"; // P800127049
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PurchaseHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
        RepackOrder: Record "Repack Order";
        RepackOrderLine: Record "Repack Order Line";
        WarehouseActivityLine: Record "Warehouse Activity Line";
        PhysInvtRecordLine: Record "Phys. Invt. Record Line";
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ItemTrackingEntry: Record "Item Ledger Entry";
        SourceTrackingLine: Record "Reservation Entry";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        SourceRead: Boolean;
        TrackingSourceBuilt: Boolean;
        TrackingOn: Boolean;
        Text001: Label 'Unable to find %1 %2.';
        Text002: Label '%1 %2 is assigned to other entries.';
        Text003: Label 'Do you want to assign a new %1?';
        Text004: Label '%1 or %2 must be Yes in %3 %4.';
        Text005: Label 'Assign is not allowed for negative entries.';
        BaseQtyPerEntryUOM: Decimal;
        UnitOfMeasure: Code[10];
        QtyRoundingPrecision, QtyRoundingPrecisionBase : Decimal;
        Text006: Label 'All %1s have been entered for %2 %3.';
        Text007: Label 'This line is associated with a container.';
        Text008: Label 'Lot %1 fails to meet established lot preferences.';
        Text009: Label 'Tracking is specified on %1.';
        Text010: Label '%1 is allowed only for reclassification.';
        Text011: Label '%1 already exists with %2 %3.';
        StatusCheckSuspended: Boolean;
        FromShpt: Boolean;
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        Location: Record Location;
        Text012: Label 'must not be greater than %1 units';
        FromReceipt: Boolean;

    procedure ClearSource()
    begin
        // ClearSource
        Clear(SourceRead);
        Clear(TrackingSourceBuilt);
        Clear(SourceTrackingLine);
    end;

    local procedure TestSourceExists()
    begin
        // TestSourceExists
        if not ("Table No." in [DATABASE::"Repack Order", DATABASE::"Phys. Invt. Record Line"]) then // P8000504A, P80074989
            if ("Source Line No." = 0) then
                Error(Text006, TableCaption, "Document Type", "Document No.");
    end;

    procedure ValidateQuantity()
    begin
        // ValidateQuantity
        if ("Serial No." <> '') then
            TestField("Quantity (Base)", 1)
        else
            if ("Table No." <> DATABASE::"Item Journal Line") then
                TestField(Quantity)
            else
                if (Quantity = 0) then begin
                    ItemJnlLine.Get("Journal Template Name", "Journal Batch Name", "Source Line No.");
                    if (Abs(ItemJnlLine.Quantity) > 0) then
                        TestField(Quantity);
                end;
    end;

    procedure GetMaxDecimalPlaces(var NumDecimalPlaces: Integer): Boolean
    begin
        // GetMaxDecimalPlaces
        GetSource;
        exit(AltQtyMgmt.GetMaxDecimalPlaces(Item."Alternate Unit of Measure", NumDecimalPlaces)); // P800128960
    end;

    procedure SetUpNewLine(LastRec: Record "Alternate Quantity Line"; TableNo: Integer; DocumentType: Integer; DocumentNo: Code[20]; TemplateName: Code[10]; BatchName: Code[10]; LineNo: Integer; QtyBase: Decimal)
    var
        AltQtyLine: Record "Alternate Quantity Line";
        AvailQtyBase: Decimal;
    begin
        // SetUpNewLine
        "Table No." := TableNo;
        "Document Type" := DocumentType;
        "Document No." := DocumentNo;
        "Journal Template Name" := TemplateName;
        "Journal Batch Name" := BatchName;
        "Source Line No." := LineNo;

        GetSource; // P8000282A

        AltQtyLine.SetRange("Alt. Qty. Transaction No.", "Alt. Qty. Transaction No.");
        AltQtyLine.CalcSums("Quantity (Base)");
        if (Round(AltQtyLine."Quantity (Base)", 0.00001) < QtyBase) then begin // P80079300, P80080576
            if ("Serial No." <> '') then
                "Quantity (Base)" := 1
            // P80083828
            else begin
                "Quantity (Base)" := QtyBase - AltQtyLine."Quantity (Base)";
                if DefaultToDetail() and ("Quantity (Base)" > BaseQtyPerEntryUOM) then
                    "Quantity (Base)" := BaseQtyPerEntryUOM;
            end;
            // P80083828
            Validate("Quantity (Base)");
        end;
    end;

    local procedure DefaultToDetail(): Boolean
    var
        InvtSetup: Record "Inventory Setup";
    begin
        // DefaultToDetail
        InvtSetup.Get;
        case "Table No." of
            DATABASE::"Item Journal Line":
                begin
                    if ItemJnlLine."Phys. Inventory" then
                        exit(InvtSetup."Phys. Count Alt. Qty. Default" =
                             InvtSetup."Phys. Count Alt. Qty. Default"::Detail);
                    case ItemJnlLine."Entry Type" of
                        ItemJnlLine."Entry Type"::Sale:
                            exit(InvtSetup."Sale Alt. Qty. Default" =
                                 InvtSetup."Sale Alt. Qty. Default"::Detail);
                        ItemJnlLine."Entry Type"::Purchase:
                            exit(InvtSetup."Purch. Alt. Qty. Default" =
                                 InvtSetup."Purch. Alt. Qty. Default"::Detail);
                        ItemJnlLine."Entry Type"::"Positive Adjmt.":
                            exit(InvtSetup."Pos. Adj. Alt. Qty. Default" =
                                 InvtSetup."Pos. Adj. Alt. Qty. Default"::Detail);
                        ItemJnlLine."Entry Type"::"Negative Adjmt.":
                            exit(InvtSetup."Neg. Adj. Alt. Qty. Default" =
                                 InvtSetup."Neg. Adj. Alt. Qty. Default"::Detail);
                        ItemJnlLine."Entry Type"::Transfer:
                            exit(InvtSetup."Transfer Alt. Qty. Default" =
                                 InvtSetup."Transfer Alt. Qty. Default"::Detail);
                        ItemJnlLine."Entry Type"::Consumption:
                            exit(InvtSetup."Consumption Alt. Qty. Default" =
                                 InvtSetup."Consumption Alt. Qty. Default"::Detail);
                        ItemJnlLine."Entry Type"::Output:
                            exit(InvtSetup."Output Alt. Qty. Default" =
                                 InvtSetup."Output Alt. Qty. Default"::Detail);
                    end;
                end;
            // P800127049
            DATABASE::"Invt. Document Line":
                case InvtDocLine."Document Type" of
                    InvtDocLine."Document Type"::Receipt:
                        exit(InvtSetup."Neg. Adj. Alt. Qty. Default" =
                             InvtSetup."Neg. Adj. Alt. Qty. Default"::Detail);
                    InvtDocLine."Document Type"::Shipment:
                        exit(InvtSetup."Pos. Adj. Alt. Qty. Default" =
                             InvtSetup."Pos. Adj. Alt. Qty. Default"::Detail);
                end;
            // P800127049
            DATABASE::"Sales Line":
                exit(InvtSetup."Sale Alt. Qty. Default" =
                     InvtSetup."Sale Alt. Qty. Default"::Detail);
            DATABASE::"Purchase Line":
                exit(InvtSetup."Purch. Alt. Qty. Default" =
                     InvtSetup."Purch. Alt. Qty. Default"::Detail);
            // PR3.61
            DATABASE::"Transfer Line":
                exit(InvtSetup."Transfer Alt. Qty. Default" =
                     InvtSetup."Transfer Alt. Qty. Default"::Detail);
            // PR3.61
            // P80074989
            DATABASE::"Phys. Invt. Record Line":
                exit(InvtSetup."Phys. Count Alt. Qty. Default" =
                      InvtSetup."Phys. Count Alt. Qty. Default"::Detail);
            // P80074989
            // P80088888
            DATABASE::"Repack Order":
                exit(InvtSetup."Output Alt. Qty. Default" =
                     InvtSetup."Output Alt. Qty. Default"::Detail);
            DATABASE::"Repack Order Line":
                exit(InvtSetup."Consumption Alt. Qty. Default" =
                      InvtSetup."Consumption Alt. Qty. Default"::Detail);
        // P80088888    
        end;
    end;

    procedure InitInvoicedQty()
    begin
        // InitInvoicedQty
        if ("Table No." = DATABASE::"Item Journal Line") then begin
            ItemJnlLine.Get("Journal Template Name", "Journal Batch Name", "Source Line No.");
            if (ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Output) then begin
                "Invoiced Qty. (Base)" := 0;
                "Invoiced Qty. (Alt.)" := 0;
            end else begin
                "Invoiced Qty. (Base)" := "Quantity (Base)";
                "Invoiced Qty. (Alt.)" := "Quantity (Alt.)";
            end;
        end;

        // P8000504A
        if "Table No." in
          [DATABASE::"Repack Order", DATABASE::"Repack Order Line", DATABASE::"Delivery Trip Pick Line"]  // P8000549A
        then begin
            "Invoiced Qty. (Base)" := "Quantity (Base)";
            "Invoiced Qty. (Alt.)" := "Quantity (Alt.)";
        end;
        // P8000504A
    end;

    // P800128960
    local procedure GetItemNo(): Code[20]
    begin
        if "Table No." = 0 then
            exit('');
        GetSource();
        exit(Item."No.");
    end;

    local procedure GetSource()
    var
        UOMMgmt: Codeunit "Unit of Measure Management";
        PickNo: Integer;
        RecordingNo: Integer;
    begin
        // GetSource
        TestSourceExists;

        if SourceRead then
            exit;
        SourceRead := true;

        case "Table No." of
            DATABASE::"Item Journal Line":
                begin
                    ItemJnlLine.Get("Journal Template Name", "Journal Batch Name", "Source Line No.");
                    Item.Get(ItemJnlLine."Item No.");
                    BaseQtyPerEntryUOM :=
                      UOMMgmt.GetQtyPerUnitOfMeasure(Item, ItemJnlLine."Unit of Measure Code");
                    // P800133109
                    UnitOfMeasure := ItemJnlLine."Unit of Measure Code";
                    QtyRoundingPrecision := ItemJnlLine."Qty. Rounding Precision";
                    QtyRoundingPrecisionBase := ItemJnlLine."Qty. Rounding Precision (Base)";
                    // P800133109
                end;
            DATABASE::"Sales Line":
                begin
                    SalesHeader.Get("Document Type", "Document No."); // P80070336
                    SalesLine.Get("Document Type", "Document No.", "Source Line No.");
                    Item.Get(SalesLine."No.");
                    BaseQtyPerEntryUOM :=
                      UOMMgmt.GetQtyPerUnitOfMeasure(Item, SalesLine."Unit of Measure Code");
                    // P800133109
                    UnitOfMeasure := SalesLine."Unit of Measure Code";
                    QtyRoundingPrecision := SalesLine."Qty. Rounding Precision";
                    QtyRoundingPrecisionBase := SalesLine."Qty. Rounding Precision (Base)";
                    // P800133109
                end;
            DATABASE::"Purchase Line":
                begin
                    PurchaseHeader.Get("Document Type", "Document No."); // P80070336
                    PurchLine.Get("Document Type", "Document No.", "Source Line No.");
                    Item.Get(PurchLine."No.");
                    BaseQtyPerEntryUOM :=
                      UOMMgmt.GetQtyPerUnitOfMeasure(Item, PurchLine."Unit of Measure Code");
                    // P800133109
                    UnitOfMeasure := PurchLine."Unit of Measure Code";
                    QtyRoundingPrecision := PurchLine."Qty. Rounding Precision";
                    QtyRoundingPrecisionBase := PurchLine."Qty. Rounding Precision (Base)";
                    // P800133109
                end;
            // PR3.61
            DATABASE::"Transfer Line":
                begin
                    TransLine.Get("Document No.", "Source Line No.");
                    Item.Get(TransLine."Item No.");
                    BaseQtyPerEntryUOM :=
                      UOMMgmt.GetQtyPerUnitOfMeasure(Item, TransLine."Unit of Measure Code");
                    // P800133109
                    UnitOfMeasure := TransLine."Unit of Measure Code";
                    UnitOfMeasure := TransLine."Unit of Measure Code";
                    QtyRoundingPrecision := TransLine."Qty. Rounding Precision";
                    QtyRoundingPrecisionBase := TransLine."Qty. Rounding Precision (Base)";
                    // P800133109
                end;
            // PR3.61
            // P8000504A
            DATABASE::"Repack Order":
                begin
                    RepackOrder.Get("Document No.");
                    Item.Get(RepackOrder."Item No.");
                    BaseQtyPerEntryUOM :=
                      UOMMgmt.GetQtyPerUnitOfMeasure(Item, RepackOrder."Unit of Measure Code");
                    // P800133109
                    UnitOfMeasure := RepackOrder."Unit of Measure Code";
                    QtyRoundingPrecision := RepackOrder."Qty. Rounding Precision";
                    QtyRoundingPrecisionBase := RepackOrder."Qty. Rounding Precision (Base)";
                    // P800133109
                end;
            DATABASE::"Repack Order Line":
                begin
                    RepackOrderLine.Get("Document No.", "Source Line No.");
                    Item.Get(RepackOrderLine."No.");
                    BaseQtyPerEntryUOM :=
                      UOMMgmt.GetQtyPerUnitOfMeasure(Item, RepackOrderLine."Unit of Measure Code");
                    // P800133109
                    UnitOfMeasure := RepackOrderLine."Unit of Measure Code";
                    QtyRoundingPrecision := RepackOrderLine."Qty. Rounding Precision";
                    QtyRoundingPrecisionBase := RepackOrderLine."Qty. Rounding Precision (Base)";
                    // P800133109
                end;
            // P8000504A
            // P8008508
            DATABASE::"Warehouse Activity Line":
                begin
                    WarehouseActivityLine.Get("Document Type", "Document No.", "Source Line No.");
                    Item.Get(WarehouseActivityLine."Item No.");
                    BaseQtyPerEntryUOM :=
                      UOMMgmt.GetQtyPerUnitOfMeasure(Item, WarehouseActivityLine."Unit of Measure Code");
                    UnitOfMeasure := WarehouseActivityLine."Unit of Measure Code";
                    // P800133109
                    QtyRoundingPrecision := WarehouseActivityLine."Qty. Rounding Precision";
                    QtyRoundingPrecisionBase := WarehouseActivityLine."Qty. Rounding Precision (Base)";
                    // P800133109
                end;
            // P8000508
            // P80074989
            DATABASE::"Phys. Invt. Record Line":
                begin
                    Evaluate(RecordingNo, "Journal Template Name");
                    PhysInvtRecordLine.Get("Document No.", RecordingNo, "Source Line No.");
                    Item.Get(PhysInvtRecordLine."Item No.");
                    BaseQtyPerEntryUOM :=
                      UOMMgmt.GetQtyPerUnitOfMeasure(Item, PhysInvtRecordLine."Unit of Measure Code");
                    // P800133109
                    UnitOfMeasure := PhysInvtRecordLine."Unit of Measure Code";
                    QtyRoundingPrecision := PhysInvtRecordLine."Qty. Rounding Precision";
                    QtyRoundingPrecisionBase := PhysInvtRecordLine."Qty. Rounding Precision (Base)";
                    // P800133109
                end;
            // P80074989
            // P800127049
            DATABASE::"Invt. Document Line":
                begin
                    InvtDocLine.Get("Document Type", "Document No.", "Source Line No.");
                    Item.Get(InvtDocLine."Item No.");
                    BaseQtyPerEntryUOM :=
                      UOMMgmt.GetQtyPerUnitOfMeasure(Item, InvtDocLine."Unit of Measure Code");
                    // P800133109
                    UnitOfMeasure := InvtDocLine."Unit of Measure Code";
                    QtyRoundingPrecision := InvtDocLine."Qty. Rounding Precision";
                    QtyRoundingPrecisionBase := InvtDocLine."Qty. Rounding Precision (Base)";
                    // P800133109
                end;
        // P800127049
        end;

        TrackingOn := false;
        if (Item."Item Tracking Code" <> '') then
            if ItemTrackingCode.Get(Item."Item Tracking Code") then
                if ItemTrackingCode."Lot Specific Tracking" or ItemTrackingCode."SN Specific Tracking" then
                    TrackingOn := true;
    end;

    local procedure BuildTrackingSource()
    begin
        // BuildTrackingSource
        TestSourceExists;

        if TrackingSourceBuilt then
            exit;
        TrackingSourceBuilt := true;

        GetSource;

        if not TrackingOn then
            exit;

        SourceTrackingLine.Init;
        SourceTrackingLine."Entry No." := 0;
        SourceTrackingLine."Item No." := Item."No.";
        SourceTrackingLine."Source Type" := "Table No.";
        SourceTrackingLine."Creation Date" := Today;
        SourceTrackingLine."Created By" := UserId;

        case "Table No." of
            DATABASE::"Item Journal Line":
                begin
                    SourceTrackingLine."Source ID" := "Journal Template Name";
                    SourceTrackingLine."Source Batch Name" := "Journal Batch Name";
                    SourceTrackingLine."Source Subtype" := ItemJnlLine."Entry Type";
                    SourceTrackingLine."Source Prod. Order Line" := ItemJnlLine."Order Line No."; // P8001132
                    SourceTrackingLine."Source Ref. No." := "Source Line No.";

                    SourceTrackingLine."Location Code" := ItemJnlLine."Location Code";
                    SourceTrackingLine."Variant Code" := ItemJnlLine."Variant Code";
                    SourceTrackingLine."Qty. per Unit of Measure" := ItemJnlLine."Qty. per Unit of Measure";

                    SourceTrackingLine."Phys. Inventory" := ItemJnlLine."Phys. Inventory";

                    if (ItemJnlLine."Output Quantity" <> 0) then
                        SourceTrackingLine.Positive := (ItemJnlLine."Output Quantity (Base)" > 0)
                    else
                        if (ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Transfer) then
                            SourceTrackingLine.Positive := false
                        else
                            if (ItemJnlLine."Quantity (Base)" <> 0) then
                                SourceTrackingLine.Positive := (ItemJnlLine.Signed(ItemJnlLine."Quantity (Base)") > 0)
                            else
                                if ItemJnlLine."Phys. Inventory" then
                                    SourceTrackingLine.Positive := false
                                else
                                    SourceTrackingLine.Positive := (ItemJnlLine.Signed(1) > 0);
                    if SourceTrackingLine.Positive then
                        SourceTrackingLine."Expected Receipt Date" := ItemJnlLine."Posting Date"
                    else
                        SourceTrackingLine."Shipment Date" := ItemJnlLine."Posting Date";

                    SourceTrackingLine.Validate("Quantity (Base)", ItemJnlLine."Quantity (Base)");
                end;
            // P800127049
            DATABASE::"Invt. Document Line":
                begin
                    SourceTrackingLine."Source Subtype" := "Document Type";
                    SourceTrackingLine."Source ID" := "Document No.";
                    SourceTrackingLine."Source Ref. No." := "Source Line No.";

                    SourceTrackingLine."Location Code" := InvtDocLine."Location Code";
                    SourceTrackingLine."Variant Code" := InvtDocLine."Variant Code";
                    SourceTrackingLine."Qty. per Unit of Measure" := InvtDocLine."Qty. per Unit of Measure";

                    SourceTrackingLine.Positive := InvtDocLine."Document Type" = InvtDocLine."Document Type"::Receipt;
                    if SourceTrackingLine.Positive then
                        SourceTrackingLine."Expected Receipt Date" := InvtDocLine."Posting Date"
                    else
                        SourceTrackingLine."Shipment Date" := InvtDocLine."Posting Date";

                    SourceTrackingLine.Validate("Quantity (Base)", InvtDocLine."Quantity (Base)");
                end;
            // P800127049
            DATABASE::"Sales Line":
                begin
                    SourceTrackingLine."Source Subtype" := "Document Type";
                    SourceTrackingLine."Source ID" := "Document No.";
                    SourceTrackingLine."Source Ref. No." := "Source Line No.";

                    SourceTrackingLine."Location Code" := SalesLine."Location Code";
                    SourceTrackingLine."Variant Code" := SalesLine."Variant Code";
                    SourceTrackingLine."Qty. per Unit of Measure" := SalesLine."Qty. per Unit of Measure";

                    SourceTrackingLine.Positive := (SalesLine.SignedXX(SalesLine."Quantity (Base)") > 0);
                    if SourceTrackingLine.Positive then
                        SourceTrackingLine."Expected Receipt Date" := SalesLine."Planned Shipment Date"
                    else
                        SourceTrackingLine."Shipment Date" := SalesLine."Planned Shipment Date";

                    SourceTrackingLine.Validate("Quantity (Base)", SalesLine."Quantity (Base)");
                end;
            DATABASE::"Purchase Line":
                begin
                    SourceTrackingLine."Source Subtype" := "Document Type";
                    SourceTrackingLine."Source ID" := "Document No.";
                    SourceTrackingLine."Source Ref. No." := "Source Line No.";

                    SourceTrackingLine."Location Code" := PurchLine."Location Code";
                    SourceTrackingLine."Variant Code" := PurchLine."Variant Code";
                    SourceTrackingLine."Qty. per Unit of Measure" := PurchLine."Qty. per Unit of Measure";

                    SourceTrackingLine.Positive := (PurchLine.Signed(PurchLine."Quantity (Base)") > 0);
                    if SourceTrackingLine.Positive then
                        SourceTrackingLine."Expected Receipt Date" := PurchLine."Expected Receipt Date"
                    else
                        SourceTrackingLine."Shipment Date" := PurchLine."Expected Receipt Date";

                    SourceTrackingLine.Validate("Quantity (Base)", PurchLine."Quantity (Base)");
                end;
            // PR3.61
            DATABASE::"Transfer Line":
                begin
                    SourceTrackingLine."Source Subtype" := "Document Type";
                    SourceTrackingLine."Source ID" := "Document No.";
                    SourceTrackingLine."Source Ref. No." := "Source Line No.";

                    SourceTrackingLine."Variant Code" := TransLine."Variant Code";
                    SourceTrackingLine."Qty. per Unit of Measure" := TransLine."Qty. per Unit of Measure";

                    if "Document Type" = 0 then begin // Outbound
                        SourceTrackingLine."Location Code" := TransLine."Transfer-from Code";
                        SourceTrackingLine.Positive := false;
                        SourceTrackingLine."Shipment Date" := TransLine."Shipment Date";
                        SourceTrackingLine.Validate("Quantity (Base)", TransLine."Quantity (Base)");
                    end else begin // Inbound
                        SourceTrackingLine."Location Code" := TransLine."Transfer-to Code";
                        SourceTrackingLine.Positive := true;
                        SourceTrackingLine."Shipment Date" := TransLine."Receipt Date";
                        SourceTrackingLine.Validate("Quantity (Base)", TransLine."Quantity (Base)");
                    end;
                end;
        // PR3.61
        end;

        if ItemTrackingMgt.IsOrderNetworkEntity(
          SourceTrackingLine."Source Type",
          SourceTrackingLine."Source Subtype")
        then
            SourceTrackingLine."Reservation Status" := SourceTrackingLine."Reservation Status"::Surplus
        else
            SourceTrackingLine."Reservation Status" := SourceTrackingLine."Reservation Status"::Prospect;
    end;

    local procedure SetTrackingLineFilters(var ResEntry: Record "Reservation Entry")
    begin
        // SetTrackingLineFilters
        ResEntry.Reset;
        ResEntry.SetCurrentKey("Item No.", "Variant Code", "Location Code");

        ResEntry.SetRange("Item No.", SourceTrackingLine."Item No.");
        ResEntry.SetRange("Variant Code", SourceTrackingLine."Variant Code");
        ResEntry.SetRange("Location Code", SourceTrackingLine."Location Code");
        if ResEntry."Phys. Inventory" then
            ResEntry.SetRange(Positive, true)
        else
            ResEntry.SetRange(Positive, SourceTrackingLine.Positive);
    end;

    local procedure SetTrackingEntryFilters(var ItemLedgerEntry2: Record "Item Ledger Entry")
    begin
        // SetTrackingEntryFilters
        ItemLedgerEntry2.Reset;
        ItemLedgerEntry2.SetCurrentKey("Item No.", Open, "Variant Code", Positive, "Location Code", "Posting Date", // P8000267B
          "Expiration Date", "Lot No.", "Serial No.");
        ItemLedgerEntry2.SetRange("Item No.", SourceTrackingLine."Item No.");
        ItemLedgerEntry2.SetRange("Variant Code", SourceTrackingLine."Variant Code");
        ItemLedgerEntry2.SetRange(Positive, not SourceTrackingLine.Positive);
        ItemLedgerEntry2.SetRange("Location Code", SourceTrackingLine."Location Code");
        ItemLedgerEntry2.SetRange(Open, true);
    end;

    local procedure SetLotSerialLineFilters(var ResEntry: Record "Reservation Entry"; LotNo: Code[50]; SerialNo: Code[50])
    begin
        // SetLotSerialLineFilters
        if (LotNo <> '') then
            ResEntry.SetRange("Lot No.", LotNo);
        if (SerialNo <> '') then
            ResEntry.SetRange("Serial No.", SerialNo);
    end;

    local procedure SetLotSerialEntryFilters(var ItemLedgerEntry2: Record "Item Ledger Entry"; LotNo: Code[50]; SerialNo: Code[50])
    begin
        // SetLotSerialEntryFilters
        if (LotNo <> '') then
            ItemLedgerEntry2.SetRange("Lot No.", LotNo);
        if (SerialNo <> '') then
            ItemLedgerEntry2.SetRange("Serial No.", SerialNo);
    end;

    local procedure TestTrackingOn()
    begin
        // TestTrackingOn
        // P8000504A
        if "Table No." = DATABASE::"Repack Order" then
            Error(Text009, RepackOrder.TableCaption)
        else
            if "Table No." = DATABASE::"Repack Order Line" then
                Error(Text009, RepackOrderLine.TableCaption);
        // P8000504A

        BuildTrackingSource;
        if not TrackingOn then begin
            Item.TestField("Item Tracking Code");
            ItemTrackingCode.Get(Item."Item Tracking Code");
            Error(Text004,
              ItemTrackingCode.FieldCaption("Lot Specific Tracking"),
              ItemTrackingCode.FieldCaption("SN Specific Tracking"),
              ItemTrackingCode.TableCaption, Item."Item Tracking Code");
        end;
    end;

    procedure CheckLotPreferences(LotNo: Code[50]; ShowWarning: Boolean): Boolean
    var
        SalesLine: Record "Sales Line";
        ItemJnlLine: Record "Item Journal Line";
    begin
        // P8000153A
        BuildTrackingSource;
        case SourceTrackingLine."Source Type" of
            DATABASE::"Sales Line":
                begin
                    SalesLine.Get(SourceTrackingLine."Source Subtype", SourceTrackingLine."Source ID", SourceTrackingLine."Source Ref. No.");
                    exit(SalesLine.CheckLotPreferences(LotNo, ShowWarning));
                end;
            DATABASE::"Item Journal Line":
                begin
                    ItemJnlLine.Get(SourceTrackingLine."Source ID", SourceTrackingLine."Source Batch Name", SourceTrackingLine."Source Ref. No.");
                    exit(ItemJnlLine.CheckLotPreferences(LotNo, ShowWarning));
                end;
            else          // P8000172A
                exit(true); // P8000172A
        end;
    end;

    procedure AutoFormatQtyAlt(): Text[10]
    var
        NumDecPlaces: Integer;
    begin
        //P8000664
        if ("Table No." = DATABASE::"Repack Order") or ("Source Line No." <> 0) then begin
            if GetMaxDecimalPlaces(NumDecPlaces) then
                exit('0:' + StrSubstNo('%1', NumDecPlaces));
        end else
            exit('0:5');
    end;

    local procedure TestSourceStatus()
    begin
        // P80070336
        if not StatusCheckSuspended then begin
            GetSource;
            case "Table No." of
                DATABASE::"Sales Line":
                    SalesHeader.TestField(Status, SalesHeader.Status::Open);
                DATABASE::"Purchase Line":
                    PurchaseHeader.TestField(Status, PurchaseHeader.Status::Open);
            end;
        end;
    end;

    procedure SuspendStatusCheck(SuspendCheck: Boolean) WasSuspended: Boolean
    begin
        // P80070336
        WasSuspended := StatusCheckSuspended; // P8006787
        StatusCheckSuspended := SuspendCheck;
    end;

    local procedure TestSourceLineLocation()
    var
        WhseShipmentLine: Record "Warehouse Shipment Line";
    begin
        // P80081811
        case "Table No." of
            DATABASE::"Sales Line":
                begin
                    OnGetFromShpt(FromShpt);
                    if not FromShpt then
                        SalesLine.CheckWarehouseGlobal
                    else begin
                        GetShipment(DATABASE::"Sales Line");
                        Location.Get(SalesLine."Location Code");
                        with WarehouseShipmentLine do begin
                            if ("Qty. to Ship" + Rec.Quantity > "Qty. Picked" - "Qty. Shipped") and
                               Location."Require Pick" and
                               not "Assemble to Order"
                            then
                                FieldError("Qty. to Ship",
                                  StrSubstNo(Text012, "Qty. Picked" - "Qty. Shipped"));
                        end;
                    end;
                end;

            DATABASE::"Purchase Line":
                begin
                    OnGetFromReceipt(FromReceipt);
                    if not FromReceipt then
                        PurchLine.CheckWarehouseGlobal;
                end;

            DATABASE::"Transfer Line":
                begin
                    if "Alt. Qty. Transaction No." = TransLine."Alt. Qty. Trans. No. (Ship)" then begin
                        OnGetFromShpt(FromShpt);
                        if not FromShpt then
                            TransLine.CheckWarehouseGlobal(TransLine."Transfer-from Code", false)
                        else begin
                            GetShipment(0);
                            Location.Get(TransLine."Transfer-from Code");
                            with WarehouseShipmentLine do
                                if ("Qty. to Ship" + Rec.Quantity > "Qty. Picked" - "Qty. Shipped") and
                                    Location."Require Pick" and not "Assemble to Order"
                                then
                                    FieldError("Qty. to Ship",
                                      StrSubstNo(Text012, "Qty. Picked" - "Qty. Shipped"));
                        end;
                    end
                    else
                        if "Alt. Qty. Transaction No." = TransLine."Alt. Qty. Trans. No. (Receive)" then begin
                            OnGetFromReceipt(FromReceipt);
                            if not FromReceipt then
                                TransLine.CheckWarehouseGlobal(TransLine."Transfer-to Code", true)
                        end;
                end;
        end;
    end;

    local procedure GetShipment(SourceType: Integer)
    begin
        // P80081811
        WarehouseShipmentLine.Reset;
        if SourceType <> 0 then begin
            WarehouseShipmentLine.SetRange("Source Type", SourceType);
            WarehouseShipmentLine.SetRange("Source Subtype", SalesLine."Document Type");
            WarehouseShipmentLine.SetRange("Source No.", SalesLine."Document No.");
            WarehouseShipmentLine.SetRange("Source Line No.", SalesLine."Line No.");
        end else begin
            WarehouseShipmentLine.SetRange("Source Type", DATABASE::"Transfer Line");
            WarehouseShipmentLine.SetRange("Source No.", TransLine."Document No.");
            WarehouseShipmentLine.SetRange("Source Line No.", TransLine."Line No.");
        end;
        WarehouseShipmentLine.FindFirst;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetFromShpt(var pFromShpt: Boolean)
    begin
        // P80081811
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetFromReceipt(var pFromReceipt: Boolean)
    begin
        // P80081811
    end;
}

