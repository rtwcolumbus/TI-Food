table 37002210 "Repack Order"
{
    // PR4.00.06
    // P8000496A, VerticalSoft, Jack Reynolds, 23 JUL 07
    //   Header record for repack orders
    // 
    // PR5.00
    // P8000498A, VerticalSoft, Jack Reynolds, 27 JUL 07
    //   Add key - Production Entry No.
    // 
    // P8000504A, VerticalSoft, Jack Reynolds, 08 AUG 07
    //   Support for alternate quantities
    // 
    // PRW15.00.01
    // P8000528A, VerticalSoft, Jack Reynolds, 09 OCT 07
    //   Fix problem validating Repack Location on new records
    // 
    // P8000529A, VerticalSoft, Jack Reynolds, 09 OCT 07
    //   Fix problem calculating lines with blank type
    // 
    // P8000530A, VerticalSoft, Jack Reynolds, 10 OCT 07
    //   Problems with LotNoAssistEdit
    // 
    // PRW15.00.03
    // P8000624A, VerticalSoft, Jack Reynolds, 19 AUG 08
    //   Add field for coutry/region of origin
    // 
    // PRW16.00.01
    // P8000703, VerticalSoft, Jack Reynolds, 15 JUN 09
    //   Modify PrintLabels to include variant code, unit of measure code, and UCC barcode
    // 
    // PRW16.00.05
    // P8000936, Columbus IT, Jack Reynolds, 25 APR 11
    //   Support for Repack Orders on Sales Board
    // 
    // P8000943, Columbus IT, Jack Reynolds, 09 MAY 11
    //   Add Due Date
    // 
    // PRW16.00.06
    // P8001123, Columbus IT, Jack Reynolds, 19 DEC 12
    //   Move Item table Label Code fields to Item Label table
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW17.10
    // P8001221, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Type added to Item table
    // 
    // P8001234, Columbus IT, Jack Reynolds, 01 NOV 13
    //    Support for custom lot number formats
    // 
    // PRW17.10.01
    // P8001258, Columbus IT, Jack Reynolds, 10 JAN 14
    //   Increase size ot text fields/variables
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality
    // 
    // P8001359, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add support for ShowMandatory
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 08 DEC 16
    //   Utility to specify number of labels to print
    // 
    // PRW110.0.01
    // P8008451, To-Increase, Jack Reynolds, 22 MAR 17
    //   Label Printing support for NAV Anywhere
    // 
    // PRW110.0.02
    // P80055869, To-Increase, Dayakar Battini, 20 MAR 18
    //   Fix Label Printing User selection Issue
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    //
    //   PRW111.00.03
    //   P80088888, To-Increase, Gangabhushan, 09 JAN 2020
    //     Repack order changes
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
    // P800128960, To Increase, Jack Reynolds, 24 AUG 21
    //   Decimal precision on alternate quantity data entry
    // 
    // PRW119.0
    // P800133109, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 19.0 - Qty. Rounding Precision

    Caption = 'Repack Order';
    DrillDownPageID = "Repack Orders";
    LookupPageID = "Repack Orders";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    InvSetup.Get;
                    NoSeriesMgt.TestManual(InvSetup."Repack Order Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; Status; Option)
        {
            Caption = 'Status';
            Editable = false;
            OptionCaption = 'Open,Finished';
            OptionMembers = Open,Finished;
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item WHERE(Type = CONST(Inventory));

            trigger OnValidate()
            begin
                if "Item No." = '' then
                    exit;

                if "Alt. Qty. Transaction No." <> 0 then                     // P8000504A
                    AltQtyMgmt.DeleteAltQtyLines("Alt. Qty. Transaction No."); // P8000504A

                GetItem;
                Item.TestField(Blocked, false);
                Validate(Description, Item.Description);
                "Description 2" := Item."Description 2";
                Validate("Unit of Measure Code", Item."Base Unit of Measure");
                CreateDim(DATABASE::Item, "Item No.");
                InitRecord;

                AutoLot; // P8001234

                // P8000504A
                if Item.TrackAlternateUnits and Item."Catch Alternate Qtys." then
                    AltQtyMgmt.AssignNewTransactionNo("Alt. Qty. Transaction No.")
                else
                    "Alt. Qty. Transaction No." := 0;
                // P8000504A
            end;
        }
        field(4; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            begin
                if "Variant Code" = '' then begin
                    Validate("Item No.");
                    exit;
                end;
                ItemVariant.Get("Item No.", "Variant Code");
                Description := ItemVariant.Description;
                "Description 2" := ItemVariant."Description 2";
            end;
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';

            trigger OnValidate()
            begin
                if ("Search Description" = UpperCase(xRec.Description)) or ("Search Description" = '') then
                    "Search Description" := Description;
            end;
        }
        field(6; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
        }
        field(7; "Search Description"; Code[100])
        {
            Caption = 'Search Description';
        }
        field(8; "Creation Date"; Date)
        {
            Caption = 'Creation Date';
            Editable = false;
        }
        field(9; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
        field(10; Comment; Boolean)
        {
            CalcFormula = Exist("Repack Order Comment Line" WHERE("Repack Order No." = FIELD("No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(12; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(13; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(14; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(21; "Repack Location"; Code[10])
        {
            Caption = 'Repack Location';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));

            trigger OnValidate()
            var
                RepackLine: Record "Repack Order Line";
            begin
                if "Repack Location" <> '' then begin
                    Location.Get("Repack Location");
                    Location.TestField("Bin Mandatory", false);
                end;

                if "Destination Location" = xRec."Repack Location" then
                    Validate("Destination Location", "Repack Location");

                if "Repack Location" <> xRec."Repack Location" then begin
                    AutoLot; // P8001234
                    if Modify then; // P8000528A
                    RepackLine.SetRange("Order No.", "No.");
                    if RepackLine.FindSet(true, false) then
                        repeat
                            RepackLine.TestField("Quantity Transferred", 0);
                            RepackLine.UpdateQtyToTransfer;
                            RepackLine.UpdateQtyToConsume;
                            RepackLine."Repack Location" := "Repack Location"; // P8000936
                            RepackLine.Modify;
                        until RepackLine.Next = 0;
                end;
            end;
        }
        field(22; "Destination Location"; Code[10])
        {
            Caption = 'Destination Location';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));

            trigger OnValidate()
            begin
                if "Destination Location" <> xRec."Destination Location" then begin
                    if "Destination Location" <> '' then
                        Location.Get("Destination Location")
                    else
                        Clear(Location);

                    Location.TestField("Directed Put-away and Pick", false);

                    "Bin Code" := '';
                    if ("Destination Location" <> '') and ("Item No." <> '') then
                        if Location."Bin Mandatory" then
                            WMSManagement.GetDefaultBin("Item No.", "Variant Code", "Destination Location", "Bin Code");
                end;
            end;
        }
        field(23; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Destination Location"),
                                            "Item Filter" = FIELD("Item No."),
                                            "Variant Filter" = FIELD("Variant Code"));
        }
        field(24; "Date Required"; Date)
        {
            Caption = 'Date Required';

            trigger OnValidate()
            var
                RepackLine: Record "Repack Order Line";
            begin
                // P8000943
                if "Date Required" <> xRec."Date Required" then begin
                    if ("Due Date" = 0D) or ("Due Date" = xRec."Date Required") then
                        "Due Date" := "Date Required";
                end;
                // P8000943
            end;
        }
        field(25; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            begin
                GetItem;
                if Item.TrackAlternateUnits then
                    AltQtyMgmt.CheckUOMDifferentFromAltUOM(Item, "Unit of Measure Code", FieldCaption("Unit of Measure Code"));

                ItemUOM.Get("Item No.", "Unit of Measure Code");
                "Qty. per Unit of Measure" := ItemUOM."Qty. per Unit of Measure";
                UOMMgt.GetQtyRoundingPrecision(Item, "Unit of Measure Code", "Qty. Rounding Precision", "Qty. Rounding Precision (Base)"); // P800133109
                Validate(Quantity);
            end;
        }
        field(26; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            Editable = false;
        }
        field(27; Quantity; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            var
                factor: Decimal;
            begin
                // P800133109
                Quantity := UOMMgt.RoundAndValidateQty(Quantity, "Qty. Rounding Precision", FieldCaption(Quantity));
                "Quantity (Base)" := CalcBaseQty(Quantity, FieldCaption(Quantity), FieldCaption("Quantity (Base)"));
                // P800133109
                // P8000504A
                GetItem;
                if Item.TrackAlternateUnits then
                    "Quantity (Alt.)" := Round(Item.AlternateQtyPerBase * Quantity * "Qty. per Unit of Measure", 0.00001) // P80088888
                                                                                                                          // P80088888
                else begin
                    "Quantity (Alt.)" := 0;
                    "Quantity to Produce (Alt.)" := 0;
                end;
                // P80088888
                // P8000504A

                //"Quantity to Produce" := Quantity;                 // P8000504A
                //"Quantity to Produce (Base)" := "Quantity (Base)"; // P8000504A
                Validate("Quantity to Produce", Quantity);            // P8000504A

                RepackLine.Reset;
                RepackLine.SetRange("Order No.", "No.");
                if RepackLine.FindSet(true, false) then begin
                    factor := Quantity / xRec.Quantity;
                    repeat
                        RepackLine.Validate(Quantity, Round(RepackLine.Quantity * factor, 0.00001));
                        RepackLine.Modify;
                    until RepackLine.Next = 0;
                end;
            end;
        }
        field(28; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(29; "Quantity (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,0,0,%1', "Item No.");
            Caption = 'Quantity (Alt.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(30; "Quantity to Produce"; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity to Produce';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                "Quantity to Produce" := UOMMgt.RoundAndValidateQty("Quantity to Produce", "Qty. Rounding Precision", FieldCaption("Quantity to Produce")); // P800133109
                if "Quantity to Produce" > Quantity then
                    Error(Text002, FieldCaption("Quantity to Produce"), FieldCaption(Quantity));

                "Quantity to Produce (Base)" := CalcBaseQty("Quantity to Produce", FieldCaption("Quantity to Produce"), FieldCaption("Quantity to Produce (Base)")); // P800133109

                // P8000504A
                GetItem;
                if Item.TrackAlternateUnits then
                    AltQtyMgmt.InitAlternateQty("Item No.", "Alt. Qty. Transaction No.",
                      "Quantity to Produce" * "Qty. per Unit of Measure", "Quantity to Produce (Alt.)");
                // P8000504A
            end;
        }
        field(31; "Quantity to Produce (Base)"; Decimal)
        {
            Caption = 'Quantity to Produce (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(32; "Quantity to Produce (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            AutoFormatExpression = "Item No.";
            AutoFormatType = 37002080;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,0,21,%1', "Item No.");
            Caption = 'Quantity to Produce (Alt.)';

            trigger OnValidate()
            begin
                // P8000504A
                AltQtyMgmt.TestRepackOrderAltQtyInfo(Rec, false);

                GetItem;
                if (CurrFieldNo = FieldNo("Quantity to Produce (Alt.)")) then begin
                    Item.TestField("Catch Alternate Qtys.", true);
                    TestField("Quantity to Produce");
                    AltQtyMgmt.CheckSummaryTolerance1("Alt. Qty. Transaction No.", "Item No.",
                      FieldCaption("Quantity to Produce (Alt.)"), "Quantity to Produce (Base)", "Quantity to Produce (Alt.)");
                end;
                // P8000504A
            end;
        }
        field(33; "Quantity Produced"; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity Produced';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(34; "Quantity Produced (Base)"; Decimal)
        {
            Caption = 'Quantity Produced (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(35; "Quantity Produced (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,0,22,%1', "Item No.");
            Caption = 'Quantity Produced (Alt.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(36; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';

            trigger OnValidate()
            begin
                // P8000504A
                if "Lot No." <> '' then begin
                    GetItem;
                    Item.TestField("Item Tracking Code");
                end;

                if ProcessFns.AltQtyInstalled then
                    AltQtyTrackingMgmt.UpdateAltQtyLineLotNo("Alt. Qty. Transaction No.", "Lot No.");
                // P8000504A
            end;
        }
        field(37; Farm; Text[30])
        {
            Caption = 'Farm';
        }
        field(38; Brand; Text[30])
        {
            Caption = 'Brand';
        }
        field(39; "Country/Region of Origin Code"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';
            TableRelation = "Country/Region";
        }
        field(40; "Due Date"; Date)
        {
            Caption = 'Due Date';

            trigger OnValidate()
            begin
                // P8000936
                if "Due Date" <> xRec."Due Date" then begin
                    RepackLine.SetRange("Order No.", "No.");
                    if RepackLine.FindSet(true, false) then
                        repeat
                            RepackLine."Due Date" := "Due Date";
                            RepackLine.Modify;
                        until RepackLine.Next = 0;
                end;
                // P8000936
            end;
        }
        field(50; Transfer; Boolean)
        {
            Caption = 'Transfer';
        }
        field(51; Produce; Boolean)
        {
            Caption = 'Produce';
        }
        field(53; "Alt. Qty. Transaction No."; Integer)
        {
            Caption = 'Alt. Qty. Transaction No.';
            Editable = false;
        }
        // P800133109
        field(54; "Qty. Rounding Precision"; Decimal)
        {
            Caption = 'Qty. Rounding Precision';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        // P800133109
        field(55; "Qty. Rounding Precision (Base)"; Decimal)
        {
            Caption = 'Qty. Rounding Precision (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                // P8001133
                ShowDocDim;
            end;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; Status)
        {
        }
        key(Key3; "Search Description")
        {
        }
        key(Key4; Status, "Item No.", "Variant Code", "Destination Location", "Due Date")
        {
            SumIndexFields = "Quantity (Base)";
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        RepackComment: Record "Repack Order Comment Line";
    begin
        TestField(Status, Status::Open);

        RepackComment.SetRange("Repack Order No.", "No.");
        RepackComment.DeleteAll(true);

        DeleteLines;

        if "Alt. Qty. Transaction No." <> 0 then                     // P8000504A
            AltQtyMgmt.DeleteAltQtyLines("Alt. Qty. Transaction No."); // P8000504A
    end;

    trigger OnInsert()
    begin
        InvSetup.Get;
        if "No." = '' then begin
            InvSetup.TestField("Repack Order Nos.");
            NoSeriesMgt.InitSeries(InvSetup."Repack Order Nos.", xRec."No. Series", "Date Required", "No.", "No. Series");
        end;
        InitRecord;

        "Creation Date" := Today;
    end;

    trigger OnModify()
    begin
        TestField(Status, Status::Open);
        "Last Date Modified" := Today;
    end;

    trigger OnRename()
    begin
        Error(Text001, TableCaption);
    end;

    var
        RepackLine: Record "Repack Order Line";
        InvSetup: Record "Inventory Setup";
        Text001: Label 'You cannot rename a %1.';
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ItemUOM: Record "Item Unit of Measure";
        Location: Record Location;
        ProcessFns: Codeunit "Process 800 Functions";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DimMgt: Codeunit DimensionManagement;
        WMSManagement: Codeunit "WMS Management";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        AltQtyTrackingMgmt: Codeunit "Alt. Qty. Tracking Management";
        P800Tracking: Codeunit "Process 800 Item Tracking";
        UOMMgt: Codeunit "Unit of Measure Management";
        Text002: Label '%1 cannot exceed %2.';
        Text003: Label 'Existing lines for %1 %2 will be deleted.  Continue?';
        Text005: Label 'Items have been transferred.  Continue?';

    procedure InitRecord()
    begin
        InvSetup.Get;

        Validate("Posting Date", WorkDate);
        Validate("Date Required", WorkDate);
        Validate("Repack Location", InvSetup."Default Repack Location");
        Validate("Destination Location", "Repack Location");
        "Variant Code" := '';
        Validate(Quantity, 0);
        "Lot No." := '';
        Farm := '';
        Brand := '';

        DeleteLines;
    end;

    procedure DeleteLines()
    begin
        RepackLine.SetRange("Order No.", "No.");
        RepackLine.DeleteAll(true);
    end;

    // P800133109
    local procedure CalcBaseQty(Qty: Decimal; FromFieldName: Text; ToFieldName: Text): Decimal
    begin
        exit(UOMMgt.CalcBaseQty(
            "No.", "Variant Code", "Unit of Measure Code", Qty, "Qty. per Unit of Measure", "Qty. Rounding Precision (Base)", FieldCaption("Qty. Rounding Precision"), FromFieldName, ToFieldName));
    end;

    procedure AssistEdit(OldRepackOrder: Record "Repack Order"): Boolean
    var
        RepackOrder: Record "Repack Order";
    begin
        with RepackOrder do begin
            RepackOrder := Rec;
            InvSetup.Get;
            InvSetup.TestField("Repack Order Nos.");
            if NoSeriesMgt.SelectSeries(InvSetup."Repack Order Nos.", OldRepackOrder."No. Series", "No. Series") then begin
                NoSeriesMgt.SetSeries("No.");
                Rec := RepackOrder;
                exit(true);
            end;
        end;
    end;

    procedure CreateDim(Type1: Integer; No1: Code[20])
    var
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        TableID[1] := Type1;
        No[1] := No1;
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        "Dimension Set ID" := DimMgt.GetDefaultDimID( // P8001133
          TableID, No, '',
          "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0); // P8001133
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID"); // P8001133
    end;

    procedure ShowDocDim()
    begin
        // P8001133
        if Status = Status::Open then
            DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo('%1 %2', TableCaption, "No."))
        else begin
            TestField("No.");
            "Dimension Set ID" :=
              DimMgt.EditDimensionSet(
                "Dimension Set ID", StrSubstNo('%1 %2', TableCaption, "No."),
                "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
        end;
    end;

    procedure GetItem()
    begin
        if "Item No." <> Item."No." then
            if "Item No." <> '' then
                Item.Get("Item No.")
            else
                Clear(Item);
    end;

    procedure LotNoAssistEdit()
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        if "Lot No." <> '' then // P8000530A
            exit;                 // P8000530A
        GetItem;
        Item.TestField("Item Tracking Code");
        if ProcessFns.TrackingInstalled then begin
            ItemTrackingCode.Get(Item."Item Tracking Code");
            //  IF ItemTrackingCode."Lot Manuf. Inbound Assignment" THEN                 // P8000530A
            Validate("Lot No.", P800Tracking.AssignLotNo(Rec)); // P8000530A, P8001234
        end else begin
            Item.TestField("Lot Nos.");
            Validate("Lot No.", NoSeriesMgt.GetNextNo(Item."Lot Nos.", WorkDate, true));
        end;
    end;

    procedure CalculateLines()
    var
        RepackLine: Record "Repack Order Line";
        BOMComponent: Record "BOM Component";
    begin
        TestField(Status, Status::Open);

        TestField("Item No.");
        TestField(Quantity);

        RepackLine.SetRange("Order No.", "No.");
        if not RepackLine.IsEmpty then begin
            if not Confirm(Text003, false, TableCaption, "No.") then
                exit;
            DeleteLines;
        end;

        Clear(RepackLine);
        RepackLine."Order No." := "No.";

        BOMComponent.SetRange("Parent Item No.", "Item No.");
        BOMComponent.SetFilter(Type, '<>0'); // P8000529A
        if BOMComponent.FindSet then
            repeat
                RepackLine.Init;
                RepackLine."Line No." += 10000;
                RepackLine.Validate(Type, BOMComponent.Type - 1);
                RepackLine.Validate("No.", BOMComponent."No.");
                RepackLine.Validate("Variant Code", BOMComponent."Variant Code");
                RepackLine.Validate("Unit of Measure Code", BOMComponent."Unit of Measure Code");
                RepackLine.Validate(Quantity, Round("Quantity (Base)" * BOMComponent."Quantity per", 0.00001));
                RepackLine.Insert(true);
            until BOMComponent.Next = 0;
    end;

    procedure Navigate()
    var
        NavigateForm: Page Navigate;
    begin
        NavigateForm.SetDoc(0D, "No.");
        NavigateForm.Run;
    end;

    procedure PrintLabels()
    var
        ItemLabel: Record "Item Case Label";
        LabData: RecordRef;
        LabelMgmt: Codeunit "Label Management";
        NoOfLabels: Integer;
        res: Integer;
    begin
        GetItem;
        //Item.TESTFIELD("Case Label Code"); // P9001123

        NoOfLabels := LabelMgmt.GetNoOfLables(Rec, Round("Quantity to Produce", 1, '>')); // P8007748

        if NoOfLabels <= 0 then
            exit;

        ItemLabel.Validate("Item No.", "Item No.");
        ItemLabel.Validate("Unit of Measure Code", "Unit of Measure Code"); // P8000703
        ItemLabel.Validate("Variant Code", "Variant Code");                 // P8000703
        ItemLabel.Validate("Lot No.", "Lot No.");                           // P8000703
        ItemLabel."No. Of Copies" := NoOfLabels;
        ItemLabel.CreateUCC(''); // P8000703
        LabData.GetTable(ItemLabel);
        // LabelMgmt.SetUser(UserId);  // P80055869
        LabelMgmt.PrintLabel(Item.GetLabelCode("Label Type"::"Case".AsInteger()), "Repack Location", LabData); // P8001123, P8008451
    end;

    procedure FinishOrder()
    var
        RepackLine: Record "Repack Order Line";
    begin
        TestField(Status, Status::Open);

        RepackLine.SetRange("Order No.", "No.");
        RepackLine.SetRange(Type, RepackLine.Type::Item);
        RepackLine.SetFilter("Source Location", '<>%1', "Repack Location");
        RepackLine.SetFilter("Quantity Transferred", '>0');
        if not RepackLine.IsEmpty then
            if not Confirm(Text005, false) then
                exit;

        Validate("Quantity to Produce", 0);
        Status := Status::Finished;
        Modify;

        RepackLine.Reset;
        RepackLine.SetRange("Order No.", "No.");
        if RepackLine.FindSet(true, false) then
            repeat
                RepackLine.UpdateQtyToTransfer;
                RepackLine.UpdateQtyToConsume;
                RepackLine.Status := Status; // P8000936
                RepackLine.Modify;
            until RepackLine.Next = 0;
    end;

    procedure AutoLot()
    begin
        // P8001234
        if not ProcessFns.TrackingInstalled then
            exit;

        if P800Tracking.AutoAssignLotNo(Rec, xRec, "Lot No.") then
            Validate("Lot No.");
    end;
}

