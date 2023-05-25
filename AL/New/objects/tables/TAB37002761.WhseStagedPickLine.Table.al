table 37002761 "Whse. Staged Pick Line"
{
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 15 SEP 06
    //   Staged Picks
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Don Bresee, 12 JUN 07
    //   Add Expiration Date
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW119.0
    // P800133109, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 19.0 - Qty. Rounding Precision

    Caption = 'Whse. Staged Pick Line';
    DrillDownPageID = "Whse. Staged Pick Lines";
    LookupPageID = "Whse. Staged Pick Lines";
    PasteIsValid = false;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            Editable = false;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            Editable = false;
        }
        field(10; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            Editable = false;
            TableRelation = Location;
        }
        field(11; "Shelf No."; Code[10])
        {
            Caption = 'Shelf No.';
        }
        field(12; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            Editable = false;
            TableRelation = IF ("Zone Code" = FILTER('')) Bin.Code WHERE("Location Code" = FIELD("Location Code"))
            ELSE
            IF ("Zone Code" = FILTER(<> '')) Bin.Code WHERE("Location Code" = FIELD("Location Code"),
                                                                               "Zone Code" = FIELD("Zone Code"));
        }
        field(13; "Zone Code"; Code[10])
        {
            Caption = 'Zone Code';
            Editable = false;
            TableRelation = Zone.Code WHERE("Location Code" = FIELD("Location Code"));
        }
        field(14; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;

            trigger OnValidate()
            begin
                if "Item No." <> xRec."Item No." then begin
                    TestField("Qty. Staged", 0);
                    ErrorIfPicksExist(FieldCaption("Item No."));
                    "Variant Code" := '';
                end;

                GetStagedPickHeader("No.");
                "Location Code" := WhseStagedPickHeader."Location Code";
                "Zone Code" := WhseStagedPickHeader."Zone Code";
                "Bin Code" := WhseStagedPickHeader."Bin Code";

                if "Item No." <> '' then begin
                    GetItemUnitOfMeasure;
                    Description := Item.Description;
                    "Description 2" := Item."Description 2";
                    "Shelf No." := Item."Shelf No.";
                    Validate("Unit of Measure Code", ItemUnitofMeasure.Code);
                end else begin
                    Description := '';
                    "Description 2" := '';
                    "Variant Code" := '';
                    "Shelf No." := '';
                    Validate("Unit of Measure Code", '');
                end;
            end;
        }
        field(15; "Qty. to Stage"; Decimal)
        {
            Caption = 'Qty. to Stage';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                "Qty. to Stage" := UOMMgt.RoundAndValidateQty("Qty. to Stage", "Qty. Rounding Precision", FieldCaption("Qty. to Stage")); // P800133109
                CalcFields("Pick to Stage Qty.");
                if ("Qty. to Stage" < ("Pick to Stage Qty." + "Qty. Staged")) then
                    FieldError("Qty. to Stage", StrSubstNo(Text001, "Pick to Stage Qty." + "Qty. Staged"));

                Validate("Qty. Outstanding", "Qty. to Stage" - "Qty. Staged");
                "Qty. to Stage (Base)" := CalcBaseQty("Qty. to Stage", FieldCaption("Qty. to Stage"), FieldCaption("Qty. to Stage (Base)")); // P800133109

                CheckBin(true);
            end;
        }
        field(16; "Qty. to Stage (Base)"; Decimal)
        {
            Caption = 'Qty. to Stage (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(19; "Qty. Outstanding"; Decimal)
        {
            Caption = 'Qty. Outstanding';
            DecimalPlaces = 0 : 5;
            Editable = false;

            trigger OnValidate()
            var
                WMSMgt: Codeunit "WMS Management";
            begin
                "Qty. Outstanding (Base)" := CalcBaseQty("Qty. Outstanding", FieldCaption("Qty. Outstanding"), FieldCaption("Qty. Outstanding (Base)")); // P800133109

                WMSMgt.CalcCubageAndWeight(
                  "Item No.", "Unit of Measure Code", "Qty. Outstanding", Cubage, Weight);
            end;
        }
        field(20; "Qty. Outstanding (Base)"; Decimal)
        {
            Caption = 'Qty. Outstanding (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(23; "Qty. Staged"; Decimal)
        {
            Caption = 'Qty. Staged';
            DecimalPlaces = 0 : 5;
            Editable = false;

            trigger OnValidate()
            begin
                "Qty. Staged (Base)" := CalcBaseQty("Qty. Staged", FieldCaption("Qty. Staged"), FieldCaption("Qty. Staged (Base)")); // P800133109
            end;
        }
        field(24; "Qty. Staged (Base)"; Decimal)
        {
            Caption = 'Qty. Staged (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(27; "Pick to Stage Qty."; Decimal)
        {
            CalcFormula = Sum("Warehouse Activity Line"."Qty. Outstanding" WHERE("Activity Type" = CONST(Pick),
                                                                                  "Whse. Document Type" = CONST(FOODStagedPick),
                                                                                  "Whse. Document No." = FIELD("No."),
                                                                                  "Whse. Document Line No." = FIELD("Line No."),
                                                                                  "Action Type" = FILTER(" " | Place),
                                                                                  "Unit of Measure Code" = FIELD("Unit of Measure Code"),
                                                                                  "Original Breakbulk" = CONST(false),
                                                                                  "Breakbulk No." = CONST(0)));
            Caption = 'Pick to Stage Qty.';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(28; "Pick to Stage Qty. (Base)"; Decimal)
        {
            CalcFormula = Sum("Warehouse Activity Line"."Qty. Outstanding (Base)" WHERE("Activity Type" = CONST(Pick),
                                                                                         "Whse. Document Type" = CONST(FOODStagedPick),
                                                                                         "Whse. Document No." = FIELD("No."),
                                                                                         "Whse. Document Line No." = FIELD("Line No."),
                                                                                         "Action Type" = FILTER(" " | Place),
                                                                                         "Original Breakbulk" = CONST(false),
                                                                                         "Breakbulk No." = CONST(0)));
            Caption = 'Pick to Stage Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(29; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            NotBlank = true;
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            begin
                if ("Item No." = '') then
                    "Qty. per Unit of Measure" := 1
                else begin
                    TestField("Qty. Staged", 0);
                    ErrorIfPicksExist(FieldCaption("Unit of Measure Code"));
                    if ("Unit of Measure Code" <> xRec."Unit of Measure Code") then begin // P800133109
                        GetItemUnitOfMeasure;
                        "Qty. per Unit of Measure" := ItemUnitofMeasure."Qty. per Unit of Measure";
                        UOMMgt.GetQtyRoundingPrecision(Item, "Unit of Measure Code", "Qty. Rounding Precision", "Qty. Rounding Precision (Base)"); // P800133109
                        RecalcQtyToStage(0);
                    end;
                end;
            end;
        }
        field(30; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
        }
        field(31; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            var
                ItemVariant: Record "Item Variant";
            begin
                if "Variant Code" = '' then
                    Validate("Item No.")
                else begin
                    ItemVariant.Get("Item No.", "Variant Code");
                    Description := ItemVariant.Description;
                end;
            end;
        }
        field(32; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(33; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
        }
        field(34; Status; Option)
        {
            Caption = 'Status';
            Editable = false;
            OptionCaption = ' ,Partially Staged,Completely Staged';
            OptionMembers = " ","Partially Staged","Completely Staged";
        }
        field(35; "Sorting Sequence No."; Integer)
        {
            Caption = 'Sorting Sequence No.';
            Editable = false;
        }
        field(36; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(37; Cubage; Decimal)
        {
            Caption = 'Cubage';
            DecimalPlaces = 0 : 5;
        }
        field(38; Weight; Decimal)
        {
            Caption = 'Weight';
            DecimalPlaces = 0 : 5;
        }
        // P800133109
        field(39; "Qty. Rounding Precision"; Decimal)
        {
            Caption = 'Qty. Rounding Precision';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        // P800133109
        field(40; "Qty. Rounding Precision (Base)"; Decimal)
        {
            Caption = 'Qty. Rounding Precision (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(100; "Order Qty. (Base)"; Decimal)
        {
            CalcFormula = Sum("Whse. Staged Pick Source Line"."Qty. (Base)" WHERE("No." = FIELD("No."),
                                                                                   "Line No." = FIELD("Line No.")));
            Caption = 'Order Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(101; "Pick from Stage Qty. (Base)"; Decimal)
        {
            CalcFormula = Sum("Warehouse Activity Line"."Qty. Outstanding (Base)" WHERE("From Staged Pick No." = FIELD("No."),
                                                                                         "From Staged Pick Line No." = FIELD("Line No."),
                                                                                         "Action Type" = FILTER(" " | Place),
                                                                                         "Original Breakbulk" = CONST(false),
                                                                                         "Breakbulk No." = CONST(0)));
            Caption = 'Pick from Stage Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(102; "Qty. Picked from Stage (Base)"; Decimal)
        {
            CalcFormula = Sum("Whse. Staged Pick Source Line"."Qty. Picked (Base)" WHERE("No." = FIELD("No."),
                                                                                          "Line No." = FIELD("Line No.")));
            Caption = 'Qty. Picked from Stage (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "No.", "Line No.")
        {
        }
        key(Key2; "No.", "Sorting Sequence No.")
        {
        }
        key(Key3; "No.", "Item No.")
        {
        }
        key(Key4; "No.", "Bin Code")
        {
        }
        key(Key5; "No.", "Due Date")
        {
        }
        key(Key6; "Bin Code", "Location Code")
        {
            SumIndexFields = "Qty. Outstanding", Cubage, Weight;
        }
        key(Key7; "Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code")
        {
            SumIndexFields = "Qty. Outstanding (Base)";
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        WhseStagedPickSourceLine: Record "Whse. Staged Pick Source Line";
    begin
        if ("Qty. Staged" > 0) and ("Qty. to Stage" > "Qty. Staged") then
            if not HideValidationDialog then
                if not Confirm(
                  StrSubstNo(
                    Text002,
                    FieldCaption("Qty. Staged"), "Qty. Staged",
                    FieldCaption("Qty. to Stage"), "Qty. to Stage", TableCaption), false)
                then
                    Error(Text003);

        WhseStagedPickSourceLine.SetRange("No.", "No.");
        WhseStagedPickSourceLine.SetRange("Line No.", "Line No.");
        WhseStagedPickSourceLine.DeleteAll;

        ItemTrackingMgt.DeleteWhseItemTrkgLines(
          DATABASE::"Whse. Staged Pick Line", 0, "No.", '', 0,
          "Line No.", "Location Code", true);

        UpdateDocStatus(true);
    end;

    trigger OnInsert()
    begin
        "Sorting Sequence No." := GetSortSeqNo;

        UpdateDocStatus(false);
    end;

    trigger OnModify()
    begin
        "Sorting Sequence No." := GetSortSeqNo;

        UpdateDocStatus(false);
    end;

    trigger OnRename()
    begin
        Error(Text000, TableCaption);
    end;

    var
        Location: Record Location;
        Item: Record Item;
        ItemUnitofMeasure: Record "Item Unit of Measure";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        WhseStagedPickHeader: Record "Whse. Staged Pick Header";
        UOMMgt: Codeunit "Unit of Measure Management";
        LastLineNo: Integer;
        HideValidationDialog: Boolean;
        Text000: Label 'You cannot rename a %1.';
        Text001: Label 'must not be less than %1 units';
        Text002: Label '%1 = %2 is less than the %3 = %4.\Do you really want to delete the %5?';
        Text003: Label 'Cancelled.';
        Text004: Label 'must not be the %1 of the %2';
        Text005: Label 'Nothing to handle.';
        Text006: Label 'You cannot change the %1 when %2s exists.';

    procedure SetUpNewLine(LastWhseStagedPickLine: Record "Whse. Staged Pick Line")
    var
        WhseStagedPickLine: Record "Whse. Staged Pick Line";
    begin
        if GetStagedPickHeader("No.") then begin
            WhseStagedPickLine.SetRange("No.", WhseStagedPickHeader."No.");
            if WhseStagedPickLine.Count > 0 then
                LastLineNo := LastWhseStagedPickLine."Line No."
            else
                LastLineNo := 0;
            "Line No." := GetNextLineNo;
            "Location Code" := WhseStagedPickHeader."Location Code";
            "Zone Code" := WhseStagedPickHeader."Zone Code";
            "Bin Code" := WhseStagedPickHeader."Bin Code";
            "Due Date" := WhseStagedPickHeader."Due Date";
        end;
    end;

    local procedure CalcBaseQty(Qty: Decimal; FromFieldName: Text; ToFieldName: Text): Decimal
    begin
        // P800133109
        exit(UOMMgt.CalcBaseQty(
            "No.", "Variant Code", "Unit of Measure Code", Qty, "Qty. per Unit of Measure", "Qty. Rounding Precision (Base)", FieldCaption("Qty. Rounding Precision"), FromFieldName, ToFieldName));
    end;

    procedure CalcQty(QtyBase: Decimal): Decimal
    begin
        TestField("Qty. per Unit of Measure");
        exit(Round(QtyBase / "Qty. per Unit of Measure", 0.00001));
    end;

    local procedure GetLocation(LocationCode: Code[10])
    begin
        if (LocationCode = '') then
            Clear(Location)
        else
            if Location.Code <> LocationCode then
                Location.Get(LocationCode);
    end;

    procedure UpdateDocStatus(Deleting: Boolean)
    var
        DocStatus: Option;
    begin
        GetStagedPickHeader("No.");
        if Deleting then
            DocStatus := WhseStagedPickHeader.GetStagingStatus("Line No.")
        else begin
            Status := CalcStatusPickLine;
            DocStatus := WhseStagedPickHeader.GetLineStagingStatus(Rec);
        end;
        if DocStatus <> WhseStagedPickHeader."Staging Status" then begin
            WhseStagedPickHeader.Validate("Staging Status", DocStatus);
            WhseStagedPickHeader.Modify(true);
        end;
    end;

    local procedure CalcStatusPickLine(): Integer
    begin
        if ("Qty. to Stage" = "Qty. Staged") then
            exit(Status::"Completely Staged");
        if "Qty. Staged" > 0 then
            exit(Status::"Partially Staged");
        exit(Status::" ");
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    local procedure GetItem()
    begin
        if Item."No." <> "Item No." then
            Item.Get("Item No.");
    end;

    procedure GetItemUnitOfMeasure()
    begin
        GetItem;
        Item.TestField("No.");
        if (Item."No." <> ItemUnitofMeasure."Item No.") or
           ("Unit of Measure Code" <> ItemUnitofMeasure.Code)
        then
            if not ItemUnitofMeasure.Get(Item."No.", "Unit of Measure Code") then
                ItemUnitofMeasure.Get(Item."No.", Item."Base Unit of Measure");
    end;

    procedure GetStagedPickHeader(StagedPickNo: Code[20]): Boolean
    begin
        exit(WhseStagedPickHeader.Get(StagedPickNo));
    end;

    procedure CreatePickDoc(var WhseStagedPickLine: Record "Whse. Staged Pick Line"; WhseStagedPickHeader2: Record "Whse. Staged Pick Header")
    var
        CreatePickFromWhseSource: Report "Whse.-Source - Create Document";
    begin
        WhseStagedPickHeader2.CheckPickRequired(WhseStagedPickHeader2."Location Code");
        WhseStagedPickHeader2.TestField(Status, WhseStagedPickHeader2.Status::Released);
        WhseStagedPickLine.SetFilter("Qty. to Stage", '>0');
        WhseStagedPickLine.SetFilter(
          Status, '<>%1', WhseStagedPickLine.Status::"Completely Staged");
        if WhseStagedPickLine.Find('-') then begin
            CreatePickFromWhseSource.SetWhseStagedPickLine(
              WhseStagedPickLine, WhseStagedPickHeader2."Assigned User ID");
            CreatePickFromWhseSource.SetHideValidationDialog(HideValidationDialog);
            CreatePickFromWhseSource.UseRequestPage(not HideValidationDialog);
            CreatePickFromWhseSource.RunModal;
            CreatePickFromWhseSource.GetResultMessage(2);
            Clear(CreatePickFromWhseSource);
        end else
            if not HideValidationDialog then
                Message(Text005);
    end;

    procedure OpenItemTrackingLines()
    var
        TempWhseWorksheetLine: Record "Whse. Worksheet Line" temporary;
        WhseItemTrackingForm: Page "Whse. Item Tracking Lines";
    begin
        TestField("Item No.");
        TestField("Qty. to Stage (Base)");
        TempWhseWorksheetLine.Init;
        TempWhseWorksheetLine."Whse. Document Type" :=
          TempWhseWorksheetLine."Whse. Document Type"::FOODStagedPick;
        TempWhseWorksheetLine."Whse. Document No." := "No.";
        TempWhseWorksheetLine."Whse. Document Line No." := "Line No.";
        TempWhseWorksheetLine."Location Code" := "Location Code";
        TempWhseWorksheetLine."Item No." := "Item No.";
        TempWhseWorksheetLine."Qty. (Base)" := "Qty. to Stage (Base)";
        CalcFields("Pick to Stage Qty. (Base)");
        TempWhseWorksheetLine."Qty. to Handle (Base)" :=
          "Qty. to Stage (Base)" - "Qty. Staged (Base)" - "Pick to Stage Qty. (Base)";
        WhseItemTrackingForm.SetSource(TempWhseWorksheetLine, DATABASE::"Whse. Staged Pick Line");
        WhseItemTrackingForm.RunModal;
    end;

    procedure CheckBin(CalcDeduction: Boolean)
    var
        Bin: Record Bin;
        BinContent: Record "Bin Content";
        WhseStagedPickLine: Record "Whse. Staged Pick Line";
    begin
        if "Bin Code" <> '' then begin
            GetLocation("Location Code");
            if not Location."Directed Put-away and Pick" then
                exit;

            if (Location."Bin Capacity Policy" in
                [Location."Bin Capacity Policy"::"Allow More Than Max. Capacity",
                Location."Bin Capacity Policy"::"Prohibit More Than Max. Cap."]) and
                CalcDeduction
            then begin
                WhseStagedPickLine.SetCurrentKey("Bin Code", "Location Code");
                WhseStagedPickLine.SetRange("Bin Code", "Bin Code");
                WhseStagedPickLine.SetRange("Location Code", "Location Code");
                WhseStagedPickLine.SetRange("No.", "No.");
                WhseStagedPickLine.SetRange("Line No.", "Line No.");
                WhseStagedPickLine.CalcSums("Qty. Outstanding", Cubage, Weight);
            end;
            if BinContent.Get(
              "Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code")
            then begin
                BinContent.TestField("Bin Type Code");
                BinContent.CheckIncreaseBinContent(
                  "Qty. Outstanding", WhseStagedPickLine."Qty. to Stage",
                  WhseStagedPickLine.Cubage, WhseStagedPickLine.Weight,
                  Cubage, Weight, false, false); // P8001132
                "Zone Code" := BinContent."Zone Code";
            end else begin
                Bin.Get("Location Code", "Bin Code");
                Bin.CheckIncreaseBin(
                  "Bin Code", "Item No.", "Qty. Outstanding",
                  WhseStagedPickLine.Cubage, WhseStagedPickLine.Weight,
                  Cubage, Weight, false, false); // P8001132
                Bin.TestField("Bin Type Code");
                "Zone Code" := Bin."Zone Code";
            end;
        end;
    end;

    procedure GetNextLineNo(): Integer
    var
        WhseStagedPickLine: Record "Whse. Staged Pick Line";
        HigherLineNo: Integer;
        LowerLineNo: Integer;
    begin
        WhseStagedPickLine.SetRange("No.", WhseStagedPickHeader."No.");
        if WhseStagedPickHeader."Sorting Method" <> WhseStagedPickHeader."Sorting Method"::" " then
            exit(GetLastLineNo + 10000)
        else begin
            WhseStagedPickLine."No." := WhseStagedPickHeader."No.";
            WhseStagedPickLine."Line No." := LastLineNo;
            if WhseStagedPickLine.Find('<') then
                LowerLineNo := WhseStagedPickLine."Line No."
            else
                if WhseStagedPickLine.Find('>') then
                    exit(LastLineNo div 2)
                else
                    exit(LastLineNo + 10000);

            WhseStagedPickLine."No." := WhseStagedPickHeader."No.";
            WhseStagedPickLine."Line No." := LastLineNo;
            if WhseStagedPickLine.Find('>') then
                HigherLineNo := LastLineNo
            else
                exit(LastLineNo + 10000);
            exit(LowerLineNo + (HigherLineNo - LowerLineNo) div 2);
        end;
    end;

    procedure GetLastLineNo(): Integer
    var
        WhseStagedPickLine: Record "Whse. Staged Pick Line";
    begin
        WhseStagedPickLine.SetRange("No.", WhseStagedPickHeader."No.");
        if WhseStagedPickLine.Find('+') then
            exit(WhseStagedPickLine."Line No.");
        exit(0);
    end;

    procedure GetSortSeqNo(): Integer
    var
        WhseStagedPickLine: Record "Whse. Staged Pick Line";
        HigherSeqNo: Integer;
        LowerSeqNo: Integer;
        LastSeqNo: Integer;
    begin
        GetStagedPickHeader("No.");

        WhseStagedPickLine.SetRange("No.", "No.");
        case WhseStagedPickHeader."Sorting Method" of
            WhseStagedPickHeader."Sorting Method"::" ":
                WhseStagedPickLine.SetCurrentKey("No.", "Line No.");
            WhseStagedPickHeader."Sorting Method"::Item:
                WhseStagedPickLine.SetCurrentKey("No.", "Item No.");
            WhseStagedPickHeader."Sorting Method"::"Due Date":
                WhseStagedPickLine.SetCurrentKey("No.", "Due Date");
            else
                exit("Line No.")
        end;

        WhseStagedPickLine := Rec;
        LastSeqNo := GetLastSeqNo(WhseStagedPickLine);
        if WhseStagedPickLine.Find('<') then
            LowerSeqNo := WhseStagedPickLine."Sorting Sequence No."
        else
            if WhseStagedPickLine.Find('>') then
                exit(WhseStagedPickLine."Sorting Sequence No." div 2)
            else
                LowerSeqNo := 10000;

        WhseStagedPickLine := Rec;
        if WhseStagedPickLine.Find('>') then
            HigherSeqNo := WhseStagedPickLine."Sorting Sequence No."
        else
            if WhseStagedPickLine.Find('<') then
                exit(LastSeqNo + 10000)
            else
                HigherSeqNo := LastSeqNo;
        exit(LowerSeqNo + (HigherSeqNo - LowerSeqNo) div 2);
    end;

    procedure GetLastSeqNo(WhseStagedPickLine: Record "Whse. Staged Pick Line"): Integer
    begin
        WhseStagedPickLine.SetRecFilter;
        WhseStagedPickLine.SetRange("Line No.");
        WhseStagedPickLine.SetCurrentKey("No.", "Sorting Sequence No.");
        if WhseStagedPickLine.Find('+') then
            exit(WhseStagedPickLine."Sorting Sequence No.");
        exit(0);
    end;

    procedure SetItemTrackingLines(SerialNo: Code[50]; LotNo: Code[50]; ExpirationDate: Date; QtyToEmpty: Decimal)
    var
        TempWhseWorksheetLine: Record "Whse. Worksheet Line" temporary;
        WhseItemTrackingForm: Page "Whse. Item Tracking Lines";
        WarehouseEntry: Record "Warehouse Entry";
    begin
        // P8000466A - Add Expiration Date parameter
        TestField("Item No.");
        TestField("Qty. to Stage (Base)");
        TempWhseWorksheetLine.Init;
        TempWhseWorksheetLine."Whse. Document Type" :=
          TempWhseWorksheetLine."Whse. Document Type"::FOODStagedPick;
        TempWhseWorksheetLine."Whse. Document No." := "No.";
        TempWhseWorksheetLine."Whse. Document Line No." := "Line No.";
        TempWhseWorksheetLine."Location Code" := "Location Code";
        TempWhseWorksheetLine."Item No." := "Item No.";
        TempWhseWorksheetLine."Qty. (Base)" := "Qty. to Stage (Base)";
        CalcFields("Pick to Stage Qty. (Base)");
        TempWhseWorksheetLine."Qty. to Handle (Base)" :=
          "Qty. to Stage (Base)" - "Qty. Staged (Base)" - "Pick to Stage Qty. (Base)";
        WhseItemTrackingForm.SetSource(TempWhseWorksheetLine, DATABASE::"Whse. Staged Pick Line");
        // P800-MegaApp
        WarehouseEntry."Lot No." := LotNo;
        WarehouseEntry."Serial No." := SerialNo;
        WarehouseEntry."Expiration Date" := ExpirationDate;
        WhseItemTrackingForm.InsertItemTrackingLine(TempWhseWorksheetLine, WarehouseEntry, QtyToEmpty); // P8000466A
        // P800-MegaApp
    end;

    local procedure ErrorIfPicksExist(FldCaption: Text[30])
    var
        WhseActLine: Record "Warehouse Activity Line";
    begin
        WhseActLine.SetCurrentKey("Whse. Document No.", "Whse. Document Type", "Activity Type");
        WhseActLine.SetRange("Whse. Document No.", "No.");
        WhseActLine.SetRange("Whse. Document Type", WhseActLine."Whse. Document Type"::FOODStagedPick);
        WhseActLine.SetRange("Activity Type", WhseActLine."Activity Type"::Pick);
        WhseActLine.SetRange("Whse. Document Line No.", "Line No.");
        if WhseActLine.Find('-') then
            Error(Text006, FldCaption, WhseActLine.TableCaption);
    end;

    procedure RecalcQtyToStage(SourceQtyBaseChg: Decimal)
    var
        WhseStagedPickLine: Record "Whse. Staged Pick Line";
        WhseStagedPickSourceLine: Record "Whse. Staged Pick Source Line";
        WhseEntry: Record "Warehouse Entry";
        QtyInStagingBin: Decimal;
        StageQtyFromOtherDocs: Decimal;
        TotalStageQtyRequired: Decimal;
        QtyToStage: Decimal;
        QtyToStageBase: Decimal;
    begin
        GetStagedPickHeader("No.");
        if WhseStagedPickHeader."Ignore Staging Bin Contents" then begin
            WhseStagedPickSourceLine.SetRange("No.", "No.");
            WhseStagedPickSourceLine.SetRange("Line No.", "Line No.");
            WhseStagedPickSourceLine.CalcSums("Qty. Outstanding (Base)");
            TotalStageQtyRequired :=
              WhseStagedPickSourceLine."Qty. Outstanding (Base)" + SourceQtyBaseChg;
        end else begin
            WhseStagedPickSourceLine.SetCurrentKey(
              "Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code");
            WhseStagedPickSourceLine.SetRange("Location Code", "Location Code");
            WhseStagedPickSourceLine.SetRange("Bin Code", "Bin Code");
            WhseStagedPickSourceLine.SetRange("Item No.", "Item No.");
            WhseStagedPickSourceLine.SetRange("Variant Code", "Variant Code");
            WhseStagedPickSourceLine.CalcSums("Qty. Outstanding (Base)");
            TotalStageQtyRequired :=
              WhseStagedPickSourceLine."Qty. Outstanding (Base)" + SourceQtyBaseChg;

            WhseStagedPickLine.SetCurrentKey(
              "Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code");
            WhseStagedPickLine.SetRange("Location Code", "Location Code");
            WhseStagedPickLine.SetRange("Bin Code", "Bin Code");
            WhseStagedPickLine.SetRange("Item No.", "Item No.");
            WhseStagedPickLine.SetRange("Variant Code", "Variant Code");
            WhseStagedPickLine.CalcSums("Qty. Outstanding (Base)");
            StageQtyFromOtherDocs :=
              WhseStagedPickLine."Qty. Outstanding (Base)" - "Qty. Outstanding (Base)";

            WhseEntry.SetCurrentKey("Item No.", "Bin Code", "Location Code", "Variant Code");
            WhseEntry.SetRange("Location Code", "Location Code");
            WhseEntry.SetRange("Bin Code", "Bin Code");
            WhseEntry.SetRange("Item No.", "Item No.");
            WhseEntry.SetRange("Variant Code", "Variant Code");
            WhseEntry.CalcSums("Qty. (Base)");
            QtyInStagingBin := WhseEntry."Qty. (Base)";
        end;

        QtyToStageBase :=
          TotalStageQtyRequired - StageQtyFromOtherDocs - QtyInStagingBin + "Qty. Staged (Base)";
        if (QtyToStageBase < 0) then
            QtyToStageBase := 0;

        if WhseStagedPickHeader."Stage Exact Qty. Needed" then
            QtyToStage := Round(QtyToStageBase / "Qty. per Unit of Measure", 0.00001)
        else
            QtyToStage := Round(QtyToStageBase / "Qty. per Unit of Measure", 1, '>');

        CalcFields("Pick to Stage Qty.");
        if (QtyToStage > ("Pick to Stage Qty." + "Qty. Staged")) then
            Validate("Qty. to Stage", QtyToStage)
        else
            Validate("Qty. to Stage", "Pick to Stage Qty." + "Qty. Staged");

        Status := CalcStatusPickLine;
    end;
}

