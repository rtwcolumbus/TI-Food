table 37002211 "Repack Order Line"
{
    // PR4.00.06
    // P8000496A, VerticalSoft, Jack Reynolds, 23 JUL 07
    //   This contains the lines for repack orders
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 31 JUL 07
    //   LotNoLookup - AssitEditLotSerialNo moved to Item Tracking Data Collection codeunit
    // 
    // P8000504A, VerticalSoft, Jack Reynolds, 08 AUG 07
    //   Support for alternate quantities
    // 
    // PRW15.00.01
    // P8000536A, VerticalSoft, Jack Reynolds, 16 OCT 07
    //   Fix problem setting default dimensions on lines
    // 
    // PRW16.00.05
    // P8000936, Columbus IT, Jack Reynolds, 25 APR 11
    //   Support for Repack Orders on Sales Board
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW17.10
    // P8001221, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Type added to Item table
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality
    // 
    // P8001359, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add support for ShowMandatory
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds 17 NOV 13
    //   Lookup of Shortcut Dimensions
    // 
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
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
    // 
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 26 APR 22
    //   Upgrade to 20.0 - Refactoring for default dimensions
    // 
    // PRW121.0
    // P800155629, To-Increase, Jack Reynolds, 03 NOV 22
    //   Add support for Mandatory Variant

    Caption = 'Repack Order Line';
    DrillDownPageID = "Repack Order Components";
    LookupPageID = "Repack Order Components";

    fields
    {
        field(1; "Order No."; Code[20])
        {
            Caption = 'Order No.';
            TableRelation = "Repack Order";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            InitValue = Item;
            OptionCaption = 'Item,Resource';
            OptionMembers = Item,Resource;

            trigger OnValidate()
            var
                TempRepackLine: Record "Repack Order Line";
            begin
                TestStatusOpen;

                TestField("Quantity Transferred", 0);

                if Type <> xRec.Type then begin
                    // P8000504A
                    if "Alt. Qty. Trans. No. (Trans)" <> 0 then
                        AltQtyMgmt.DeleteAltQtyLines("Alt. Qty. Trans. No. (Trans)");
                    if "Alt. Qty. Trans. No. (Consume)" <> 0 then
                        AltQtyMgmt.DeleteAltQtyLines("Alt. Qty. Trans. No. (Trans)");
                    // P8000504A
                    TempRepackLine := Rec;
                    Init;
                    Type := TempRepackLine.Type;
                end;
            end;
        }
        field(4; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type = CONST(Item)) Item WHERE(Type = CONST(Inventory))
            ELSE
            IF (Type = CONST(Resource)) Resource;

            trigger OnValidate()
            var
                TempRepackLine: Record "Repack Order Line";
            begin
                TestStatusOpen;

                TestField("Quantity Transferred", 0);

                // P8000504A
                if "Alt. Qty. Trans. No. (Trans)" <> 0 then
                    AltQtyMgmt.DeleteAltQtyLines("Alt. Qty. Trans. No. (Trans)");
                if "Alt. Qty. Trans. No. (Consume)" <> 0 then
                    AltQtyMgmt.DeleteAltQtyLines("Alt. Qty. Trans. No. (Trans)");
                // P8000504A
                TempRepackLine := Rec;
                Init;
                Type := TempRepackLine.Type;
                "No." := TempRepackLine."No.";

                if "No." = '' then
                    exit;

                case Type of
                    Type::Item: // PR3.61
                        begin
                            GetItem;
                            Item.TestField(Blocked, false);
                            // P8006959
                            if ProcessFns.AllergenInstalled then
                                AllergenManagement.CheckConsumption(Rec);
                            // P8006959
                            Description := Item.Description;
                            "Description 2" := Item."Description 2";
                            "Unit of Measure Code" := Item."Base Unit of Measure";
                            // P8000504A
                            if Item.TrackAlternateUnits and Item."Catch Alternate Qtys." then begin
                                AltQtyMgmt.AssignNewTransactionNo("Alt. Qty. Trans. No. (Trans)");
                                AltQtyMgmt.AssignNewTransactionNo("Alt. Qty. Trans. No. (Consume)");
                            end else begin
                                "Alt. Qty. Trans. No. (Trans)" := 0;
                                "Alt. Qty. Trans. No. (Consume)" := 0;
                            end;
                            // P8000504A
                        end;
                    Type::Resource:
                        begin
                            GetResource;
                            Resource.TestField(Blocked, false);
                            Description := Resource.Name;
                            "Description 2" := Resource."Name 2";
                            "Unit of Measure Code" := Resource."Base Unit of Measure";
                        end;
                end;

                Validate("Unit of Measure Code");

                CreateDimFromDefaultDim(); // P800144605

                GetDefaultBin;
            end;
        }
        field(5; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = IF (Type = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD("No."));

            trigger OnValidate()
            begin
                if "Variant Code" <> '' then
                    TestField(Type, Type::Item);
                TestStatusOpen;

                if xRec."Variant Code" <> "Variant Code" then begin
                    TestField("Quantity Transferred", 0);
                    GetDefaultBin;
                end;
            end;
        }
        field(6; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(7; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
        }
        field(8; "Source Location"; Code[10])
        {
            Caption = 'Source Location';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));

            trigger OnValidate()
            begin
                if "Source Location" <> '' then
                    TestField(Type, Type::Item);
                TestStatusOpen;

                if xRec."Source Location" <> "Source Location" then begin
                    TestField("Quantity Transferred", 0);

                    GetLocation;
                    Location.TestField("Directed Put-away and Pick", false);

                    "Bin Code" := '';
                    GetDefaultBin;

                    UpdateQtyToTransfer;
                    UpdateQtyToConsume;
                end;
            end;
        }
        field(9; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = IF (Type = CONST(Item)) "Bin Content"."Bin Code" WHERE("Location Code" = FIELD("Source Location"),
                                                                                  "Item No." = FIELD("No."),
                                                                                  "Variant Code" = FIELD("Variant Code"));

            trigger OnValidate()
            begin
                if "Bin Code" <> '' then
                    TestField(Type, Type::Item);
                TestStatusOpen;

                if "Bin Code" <> '' then
                    WMSManagement.FindBinContent("Source Location", "Bin Code", "No.", "Variant Code", '');

                if xRec."Bin Code" <> "Bin Code" then
                    TestField("Quantity Transferred", 0);

                TestField("Source Location");

                if (Type = Type::Item) and ("Bin Code" <> '') then begin
                    GetLocation;
                    Location.TestField("Bin Mandatory");
                end;
            end;
        }
        field(10; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = IF (Type = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."))
            ELSE
            IF (Type = CONST(Resource)) "Resource Unit of Measure".Code WHERE("Resource No." = FIELD("No."));

            trigger OnValidate()
            begin
                TestStatusOpen;
                TestField("Quantity Transferred", 0);

                case Type of
                    Type::Item:
                        begin
                            GetItem;
                            if Item.TrackAlternateUnits then
                                AltQtyMgmt.CheckUOMDifferentFromAltUOM(Item, "Unit of Measure Code", FieldCaption("Unit of Measure Code"));

                            ItemUOM.Get("No.", "Unit of Measure Code");
                            "Qty. per Unit of Measure" := ItemUOM."Qty. per Unit of Measure";
                            UOMMgt.GetQtyRoundingPrecision(Item, "Unit of Measure Code", "Qty. Rounding Precision", "Qty. Rounding Precision (Base)"); // P800133109
                        end;
                    Type::Resource:
                        begin
                            ResourceUOM.Get("No.", "Unit of Measure Code");
                            "Qty. per Unit of Measure" := ResourceUOM."Qty. per Unit of Measure";
                        end;
                end;
                Validate(Quantity);
            end;
        }
        field(11; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            Editable = false;
        }
        field(12; Quantity; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                // P800133109
                if Type = type::Item then
                    Quantity := UOMMgt.RoundAndValidateQty(Quantity, "Qty. Rounding Precision", FieldCaption(Quantity));
                // P800133109
                if Quantity < "Quantity Transferred" then
                    Error(Text003, FieldCaption("Quantity Transferred"), FieldCaption(Quantity));

                "Quantity (Base)" := CalcBaseQty(Quantity, FieldCaption(Quantity), FieldCaption("Quantity (Base)")); // P800133109

                // P8000504A
                GetItem;
                if (Type = Type::Item) and Item.TrackAlternateUnits then
                    "Quantity (Alt.)" := Round(Item.AlternateQtyPerBase * Quantity * "Qty. per Unit of Measure", 0.00001);
                // P8000504A

                UpdateQtyToTransfer;
                UpdateQtyToConsume;
            end;
        }
        field(13; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(14; "Quantity (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,1,0,%1,%2', Type, "No.");
            Caption = 'Quantity (Alt.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(15; "Quantity to Transfer"; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity to Transfer';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                // P800133109
                if Type = type::Item then
                    "Quantity to Transfer" := UOMMgt.RoundAndValidateQty("Quantity to Transfer", "Qty. Rounding Precision", FieldCaption("Quantity to Transfer"));
                // P800133109
                if "Quantity to Transfer" <> 0 then begin
                    TestField(Type, Type::Item);
                    GetHeader;
                    if "Source Location" = RepackOrder."Repack Location" then
                        Error(Text002, RepackOrder.FieldCaption("Repack Location"), FieldCaption("Source Location"));
                    if Quantity < "Quantity Transferred" + "Quantity to Transfer" then
                        Error(Text003, FieldCaption("Quantity Transferred"), FieldCaption(Quantity));
                end;

                "Quantity to Transfer (Base)" := CalcBaseQty("Quantity to Transfer", FieldCaption("Quantity to Transfer"), FieldCaption("Quantity to Transfer (Base)")); // P800133109

                // P8000504A
                GetItem;
                if (Type = Type::Item) and Item.TrackAlternateUnits then
                    AltQtyMgmt.InitAlternateQty("No.", "Alt. Qty. Trans. No. (Trans)",
                      "Quantity to Transfer" * "Qty. per Unit of Measure", "Quantity to Transfer (Alt.)");
                // P8000504A

                UpdateQtyToConsume;
            end;
        }
        field(16; "Quantity to Transfer (Base)"; Decimal)
        {
            Caption = 'Quantity to Transfer (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(17; "Quantity to Transfer (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            AutoFormatExpression = GetItemNo();
            AutoFormatType = 37002080;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,1,23,%1,%2', Type, "No.");
            Caption = 'Quantity to Transfer (Alt.)';
            MinValue = 0;

            trigger OnValidate()
            begin
                // P8000504A
                AltQtyMgmt.TestRepackLineAltQtyInfo(Rec, false, FieldNo("Quantity to Transfer"));

                GetItem;
                if (CurrFieldNo = FieldNo("Quantity to Transfer (Alt.)")) then begin
                    Item.TestField("Catch Alternate Qtys.", true);
                    TestField("Quantity to Transfer");
                    AltQtyMgmt.CheckSummaryTolerance1("Alt. Qty. Trans. No. (Trans)", "No.",
                      FieldCaption("Quantity to Transfer (Alt.)"), "Quantity to Transfer (Base)", "Quantity to Transfer (Alt.)");
                end;
                // P8000504A
            end;
        }
        field(18; "Quantity Transferred"; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity Transferred';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(19; "Quantity Transferred (Base)"; Decimal)
        {
            Caption = 'Quantity Transferred (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(20; "Quantity Transferred (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,1,24,%1,%2', Type, "No.");
            Caption = 'Quantity Transferred (Alt.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(21; "Quantity to Consume"; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity to Consume';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                // P800133109
                if Type = type::Item then
                    "Quantity to Consume" := UOMMgt.RoundAndValidateQty("Quantity to Consume", "Qty. Rounding Precision", FieldCaption("Quantity to Consume"));
                // P800133109
                if Quantity < "Quantity to Consume" then
                    Error(Text003, FieldCaption("Quantity to Consume"), FieldCaption(Quantity));

                "Quantity to Consume (Base)" := CalcBaseQty("Quantity to Consume", FieldCaption("Quantity to Consume"), FieldCaption("Quantity to Consume (Base)")); // P800133109

                // P8000504A
                GetItem;
                if (Type = Type::Item) and Item.TrackAlternateUnits then
                    AltQtyMgmt.InitAlternateQty("No.", "Alt. Qty. Trans. No. (Consume)",
                      "Quantity to Consume" * "Qty. per Unit of Measure", "Quantity to Consume (Alt.)");
                // P8000504A
            end;
        }
        field(22; "Quantity to Consume (Base)"; Decimal)
        {
            Caption = 'Quantity to Consume (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(23; "Quantity to Consume (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            AutoFormatExpression = GetItemNo();
            AutoFormatType = 37002080;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,1,25,%1,%2', Type, "No.");
            Caption = 'Quantity to Consume (Alt.)';
            MinValue = 0;

            trigger OnValidate()
            begin
                // P8000504A
                AltQtyMgmt.TestRepackLineAltQtyInfo(Rec, false, FieldNo("Quantity to Consume"));

                GetItem;
                if (CurrFieldNo = FieldNo("Quantity to Consume (Alt.)")) then begin
                    Item.TestField("Catch Alternate Qtys.", true);
                    TestField("Quantity to Consume");
                    AltQtyMgmt.CheckSummaryTolerance1("Alt. Qty. Trans. No. (Consume)", "No.",
                      FieldCaption("Quantity to Consume (Alt.)"), "Quantity to Consume (Base)", "Quantity to Consume (Alt.)");
                end;
                // P8000504A
            end;
        }
        field(24; "Quantity Consumed"; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity Consumed';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(25; "Quantity Consumed (Base)"; Decimal)
        {
            Caption = 'Quantity Consumed (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(26; "Quantity Consumed (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,1,26,%1,%2', Type, "No.");
            Caption = 'Quantity Consumed (Alt.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(27; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            TableRelation = IF (Type = CONST(Item)) "Lot No. Information"."Lot No." WHERE("Item No." = FIELD("No."),
                                                                                         "Variant Code" = FIELD("Variant Code"));

            trigger OnValidate()
            begin
                if "Lot No." <> '' then
                    TestField(Type, Type::Item);
                TestField("No.");
                GetItem;
                Item.TestField("Item Tracking Code");

                if "Lot No." <> xRec."Lot No." then
                    TestField("Quantity Transferred", 0);

                // P8000504A
                if ProcessFns.AltQtyInstalled then begin
                    AltQtyTrackingMgmt.UpdateAltQtyLineLotNo("Alt. Qty. Trans. No. (Trans)", "Lot No.");
                    AltQtyTrackingMgmt.UpdateAltQtyLineLotNo("Alt. Qty. Trans. No. (Consume)", "Lot No.");
                end;
                // P8000504A
            end;
        }
        field(30; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(31; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(41; "Alt. Qty. Trans. No. (Trans)"; Integer)
        {
            Caption = 'Alt. Qty. Trans. No. (Trans)';
            Editable = false;
        }
        field(42; "Alt. Qty. Trans. No. (Consume)"; Integer)
        {
            Caption = 'Alt. Qty. Trans. No. (Consume)';
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
        field(81; Status; Option)
        {
            Caption = 'Status';
            Editable = false;
            OptionCaption = 'Open,Finished';
            OptionMembers = Open,Finished;
        }
        field(82; "Due Date"; Date)
        {
            Caption = 'Due Date';
            Editable = false;
        }
        field(83; "Repack Location"; Code[10])
        {
            Caption = 'Repack Location';
            Editable = false;
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                // P8001133
                ShowDimensions;
            end;
        }
    }

    keys
    {
        key(Key1; "Order No.", "Line No.")
        {
        }
        key(Key2; Status, Type, "No.", "Variant Code", "Source Location", "Due Date")
        {
            SumIndexFields = "Quantity (Base)", "Quantity Transferred (Base)";
        }
        key(Key3; Status, Type, "No.", "Variant Code", "Repack Location", "Due Date")
        {
            SumIndexFields = "Quantity Transferred (Base)";
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        TestStatusOpen;

        TestField("Quantity Transferred", 0);

        // P8000504A
        if "Alt. Qty. Trans. No. (Trans)" <> 0 then
            AltQtyMgmt.DeleteAltQtyLines("Alt. Qty. Trans. No. (Trans)");
        if "Alt. Qty. Trans. No. (Consume)" <> 0 then
            AltQtyMgmt.DeleteAltQtyLines("Alt. Qty. Trans. No. (Trans)");
        // P8000504A
    end;

    trigger OnInsert()
    begin
        TestStatusOpen;

        GetHeader;
        RepackOrder.TestField("Item No."); // P8006959
        RepackOrder.TestField(Quantity);

        // P8000936
        "Due Date" := RepackOrder."Due Date";
        "Repack Location" := RepackOrder."Repack Location";
        // P8000936
    end;

    trigger OnModify()
    begin
        TestStatusOpen;
    end;

    var
        RepackOrder: Record "Repack Order";
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ItemUOM: Record "Item Unit of Measure";
        Resource: Record Resource;
        ResourceUOM: Record "Resource Unit of Measure";
        Location: Record Location;
        ProcessFns: Codeunit "Process 800 Functions";
        DimMgt: Codeunit DimensionManagement;
        Text001: Label '%1 %2 must be open.';
        WMSManagement: Codeunit "WMS Management";
        Text002: Label 'No transfer allowed when %1 is the same as %2.';
        Text003: Label '%1 cannot exceed %2.';
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        AltQtyTrackingMgmt: Codeunit "Alt. Qty. Tracking Management";
        AllergenManagement: Codeunit "Allergen Management";
        UOMMgt: Codeunit "Unit of Measure Management";

    procedure GetHeader()
    begin
        if "Order No." <> RepackOrder."No." then
            if "Order No." <> '' then
                RepackOrder.Get("Order No.")
            else
                Clear(RepackOrder);
    end;

    procedure GetItem()
    begin
        if Type <> Type::Item then
            Clear(Item)
        else
            if "No." <> Item."No." then
                Item.Get("No.")
            else
                if "No." = '' then
                    Clear(Item);
    end;

    // P800128960
    local procedure GetItemNo(): Code[20]
    var
        Item: Record Item;
    begin
        if (Type = Type::Item) and ("No." <> '') then begin
            Item.Get("No.");
            exit(Item."No.");
        end;
    end;

    procedure GetResource()
    begin
        if Type <> Type::Resource then
            Clear(Resource)
        else
            if "No." <> Resource."No." then
                Resource.Get("No.")
            else
                if "No." = '' then
                    Clear(Resource);
    end;

    procedure GetLocation()
    begin
        if "Source Location" <> Location.Code then
            Location.Get("Source Location")
        else
            Clear(Location);
    end;

    procedure TestStatusOpen()
    begin
        GetHeader;
        if RepackOrder.Status <> RepackOrder.Status::Open then
            Error(Text001, RepackOrder.TableCaption, RepackOrder."No.");
    end;

    // P800133109
    local procedure CalcBaseQty(Qty: Decimal; FromFieldName: Text; ToFieldName: Text): Decimal
    begin
        exit(UOMMgt.CalcBaseQty(
            "No.", "Variant Code", "Unit of Measure Code", Qty, "Qty. per Unit of Measure", "Qty. Rounding Precision (Base)", FieldCaption("Qty. Rounding Precision"), FromFieldName, ToFieldName));
    end;

    procedure TypeToTable(): Integer
    begin
        case Type of
            Type::Item:
                exit(DATABASE::Item);
            Type::Resource:
                exit(DATABASE::Resource);
        end;
    end;

    // P800144605
    procedure CreateDimFromDefaultDim()
    var
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        InitDefaultDimensionSources(DefaultDimSource);
        CreateDim(DefaultDimSource);
    end;

    // P800144605
    local procedure InitDefaultDimensionSources(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    begin
        DimMgt.AddDimSource(DefaultDimSource, Rec.TypeToTable(), Rec."No.");
    end;

    // P800144605
    procedure CreateDim(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    begin
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        "Dimension Set ID" :=
          DimMgt.GetRecDefaultDimID(
            Rec, CurrFieldNo, DefaultDimSource, '', "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID"); // P8001133
    end;

    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20])
    begin
        DimMgt.GetShortcutDimensions("Dimension Set ID", ShortcutDimCode); // P8001133
    end;

    procedure ShowDimensions()
    begin
        // P8001113
        if RepackOrder.Status = RepackOrder.Status::Open then
            DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo('%1 %2', "Order No.", "Line No."))
        else
            "Dimension Set ID" :=
              DimMgt.EditDimensionSet(
                "Dimension Set ID", StrSubstNo('%1 %2', "Order No.", "Line No."),
                "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    local procedure GetDefaultBin()
    var
        WMSManagement: Codeunit "WMS Management";
    begin
        if Type <> Type::Item then
            exit;

        if ("No." = xRec."No.") and
           ("Source Location" = xRec."Source Location") and
           ("Variant Code" = xRec."Variant Code")
        then
            exit;

        "Bin Code" := '';

        if ("Source Location" <> '') and ("No." <> '') then begin
            GetLocation;
            if Location."Bin Mandatory" and not Location."Directed Put-away and Pick" then
                WMSManagement.GetDefaultBin("No.", "Variant Code", "Source Location", "Bin Code");
        end;
    end;

    procedure UpdateQtyToTransfer()
    begin
        if Type <> Type::Item then
            exit;

        GetHeader;
        if (RepackOrder."Repack Location" = "Source Location") or (RepackOrder.Status = RepackOrder.Status::Finished) then
            Validate("Quantity to Transfer", 0)
        else
            if Quantity <= "Quantity Transferred" then
                Validate("Quantity to Transfer", 0)
            else
                Validate("Quantity to Transfer", Quantity - "Quantity Transferred");
    end;

    procedure UpdateQtyToConsume()
    begin
        GetHeader;
        if RepackOrder.Status = RepackOrder.Status::Finished then
            Validate("Quantity to Consume", 0)
        else
            case Type of
                Type::Item:
                    if RepackOrder."Repack Location" = "Source Location" then
                        Validate("Quantity to Consume", Quantity)
                    else
                        Validate("Quantity to Consume", "Quantity Transferred" + "Quantity to Transfer");
                Type::Resource:
                    Validate("Quantity to Consume", Quantity);
            end;
    end;

    procedure LotNoLookup(var LotNo: Text[1024]): Boolean
    var
        TrackingSpec: Record "Tracking Specification";
        ItemTrackingDCMgt: Codeunit "Item Tracking Data Collection";
    begin
        if Type <> Type::Item then
            exit(false);

        if "Quantity Transferred" <> 0 then
            exit(false);

        TestField("No.");
        GetItem;
        Item.TestField("Item Tracking Code");

        TrackingSpec."Item No." := "No.";
        TrackingSpec."Location Code" := "Source Location";
        TrackingSpec.Description := Description;
        TrackingSpec."Variant Code" := "Variant Code";
        TrackingSpec."Source Subtype" := 3;
        if "Quantity to Transfer" <> 0 then begin
            TrackingSpec."Quantity (Base)" := "Quantity to Transfer (Base)";
            TrackingSpec."Qty. to Handle" := "Quantity to Transfer";
            TrackingSpec."Qty. to Handle (Base)" := "Quantity to Transfer (Base)";
            TrackingSpec."Qty. to Invoice" := "Quantity to Transfer";
            TrackingSpec."Qty. to Invoice (Base)" := "Quantity to Transfer (Base)";
            TrackingSpec."Bin Code" := "Bin Code";
        end else begin
            TrackingSpec."Quantity (Base)" := "Quantity to Consume (Base)";
            TrackingSpec."Qty. to Handle" := "Quantity to Consume";
            TrackingSpec."Qty. to Handle (Base)" := "Quantity to Consume (Base)";
            TrackingSpec."Qty. to Invoice" := "Quantity to Consume";
            TrackingSpec."Qty. to Invoice (Base)" := "Quantity to Consume (Base)";
        end;
        TrackingSpec."Qty. per Unit of Measure" := "Qty. per Unit of Measure";

        ItemTrackingDCMgt.AssistEditTrackingNo(TrackingSpec, true, -1, 1, TrackingSpec."Quantity (Base)");
        LotNo := TrackingSpec."Lot No.";
        exit(LotNo <> '');
    end;

    // P800155629
    procedure IsVariantMandatory(): Boolean
    var
        Item: Record Item;
    begin
        exit(Item.IsVariantMandatory(Type = Type::Item, "No."));
    end;
}
