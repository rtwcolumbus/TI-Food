table 99000772 "Production BOM Line"
{
    // PR1.00
    //   Add 'Unapproved Item' as option for Type
    //   Default Item No. lookup is restricted to raw material, packaging, and intermediate
    //     items
    //   Support for standard text
    //   New Process 800 fields
    //     Yield % (Weight)
    //     Yield % (Volume)
    //     Unit Cost
    //     Extended Cost
    //     Batch Quantity
    //     Auto Plan if Component
    //     % of Total
    //     Output Weight (Base Metric)
    //     Output Volume (Base Metric)
    //     Input Weight (Base Metric)
    //     Input Volume (Base Metric)
    //   New Process 800 functions
    //     ReCalc
    //     ConvertToMetric
    //     AdjustYield
    // 
    // PR1.00.02
    //   Comment - not editable
    // 
    // PR1.00.03
    //   Add support for Phantom BOM's for costing and weight/volume conversion
    // 
    // PR1.00.04
    //   Min Value on yields was set to -100, changed to zero.
    // 
    // PR1.00.05
    //   When OnLookup trigger for No. was run the OnValidate and OnAfterValidate triggers
    //   on the forms were not run; this caused running totals on the forms to not be
    //   updated.  Removed this code and relocated it to a function NoLookup that can be
    //   called from the OnLookup trigger on the forms.
    // 
    // PR1.10.01
    //   Change field names (Base Metric) to (Metric Base) to match field names in Production BOM Version
    // 
    // PR1.20
    //   Add support for Item Process
    // 
    // PR1.10.01
    //   Change field names (Metric Base) to (Base)
    // 
    // PR2.00.03
    //   Add Field - Step Code
    // 
    // PR2.00.05
    //   Type - add Variable as on option
    //   No. - change table relation to include variables; get description for package variable table
    //   NoLookup - modify for variables
    // 
    // PR3.60
    //   Add logic for alternate unit of measure
    // 
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Maintain lot preferences
    // 
    // P8000157A, Myers Nissi, Jack Reynolds, 04 JAN 05
    //   Modify PasteIsValid to keep users from pasting into this table
    // 
    // PR4.00.01
    // P8000286A, VerticalSoft, Jack Reynolds, 06 FEB 06
    //   Fix table relation for No. (unapproved item)
    // 
    // PRW15.00.01
    // P8000513A, VerticalSoft, Jack Reynolds, 12 SEP 07
    //   Check that UOM is not same type as alternate UOM
    // 
    // P8000551A, VerticalSoft, Jack Reynolds, 04 DEC 07
    //   Rounding of unit cost and extended cost
    // 
    // PRW16.00.04
    // P8000856, VerticalSoft, Don Bresee, 24 AUG 10
    //   Add Commodity Class Costing granule
    // 
    // P8000868, VerticalSoft, Don Bresee, 10 NOV 10
    //   Added Genesis Enhancements
    // 
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // P8001082, Columbus IT, Rick Tweedle, 22 JUN 12
    //   Added Pre-Process capability
    // 
    // PRW17.00.01
    // P8001155, Columbus IT, Jack Reynolds, 20 MAY 13
    //   Take Scrap % into account when calculating extended cost
    // 
    // PRW17.10.01
    // P8001258, Columbus IT, Jack Reynolds, 10 JAN 14
    //   Increase size ot text fields/variables
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality
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

    Caption = 'Production BOM Line';
    PasteIsValid = false;

    fields
    {
        field(1; "Production BOM No."; Code[20])
        {
            Caption = 'Production BOM No.';
            NotBlank = true;
            TableRelation = "Production BOM Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Version Code"; Code[20])
        {
            Caption = 'Version Code';
            TableRelation = "Production BOM Version"."Version Code" WHERE("Production BOM No." = FIELD("Production BOM No."));
        }
        field(10; Type; Enum "Production BOM Line Type")
        {
            Caption = 'Type';

            trigger OnValidate()
            begin
                TestStatus;

                xRec.Type := Type;

                Init;
                Type := xRec.Type;
            end;
        }
        field(11; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type = CONST(Item)) Item WHERE(Type = FILTER(Inventory | "Non-Inventory"))
            ELSE
            IF (Type = CONST("Production BOM")) "Production BOM Header"
            ELSE
            IF (Type = CONST(FOODUnapprovedItem)) "Unapproved Item"
            ELSE
            IF (Type = CONST(FOODVariable)) "Package Variable";

            trigger OnValidate()
            begin
                //TESTFIELD(Type); // PR1.00 Allow blank type

                TestStatus;

                case Type of
                    Type::Item:
                        begin
                            Item.Get("No.");
                            Description := Item.Description;
                            Item.TestField("Base Unit of Measure");
                            "Unit of Measure Code" := Item."Base Unit of Measure";
                            "Scrap %" := Item."Scrap %";
                            if "No." <> xRec."No." then
                                "Variant Code" := '';
                            OnValidateNoOnAfterAssignItemFields(Rec, Item, xRec, CurrFieldNo);
                        end;
                    Type::"Production BOM":
                        begin
                            ProdBOMHeader.Get("No.");
                            ProdBOMHeader.TestField("Unit of Measure Code");
                            Description := ProdBOMHeader.Description;
                            "Unit of Measure Code" := ProdBOMHeader."Unit of Measure Code";
                            OnValidateNoOnAfterAssignProdBOMFields(Rec, ProdBOMHeader, xRec, CurrFieldNo);
                        end;
                    // PR1.00 Begin
                    Type::FOODUnapprovedItem:
                        begin
                            UnapprItem.Get("No.");
                            Description := UnapprItem.Description;
                            UnapprItem.TestField("Base Unit of Measure");
                            "Unit of Measure Code" := UnapprItem."Base Unit of Measure";
                            Validate("Unit Cost", UnapprItem."Unit Cost");
                        end;

                    Type::" ":
                        begin
                            if StdText.Get("No.") then
                                Description := StdText.Description;
                        end;
                    // PR1.00 End
                    // PR2.00.05 Begin
                    Type::FOODVariable:
                        begin
                            PackVars.Get("No.");
                            Description := PackVars.Description;
                        end;
                // PR2.00.05 End
                end;

                // P8000856
                if ProcessFns.CommCostInstalled() then
                    CommItemMgmt.ProdBOMLineValidate(Rec, FieldNo("No."));
                // P8000856

                SetLinePercent;  // P8007746
                OnAfterValidateNo(Rec);
            end;
        }
        field(12; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(13; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = IF (Type = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."))
            ELSE
            IF (Type = CONST("Production BOM")) "Unit of Measure";

            trigger OnValidate()
            var
                factor: Decimal;
            begin
                TestField("No.");
                if Type = Type::" " then // PR1.00
                    Error(Text37002000); // PR1.00

                // PR1.00.03 Begin
                if Type = Type::"Production BOM" then begin
                    CalcPhantom(BOMVars); // P80066030
                    if not ("Unit of Measure Code" in [BOMVars."Unit of Measure Code", BOMVars."Weight UOM", BOMVars."Volume UOM"]) then
                        Error(Text37002001);
                end;
                // PR1.00.03 End

                // PR1.00 Begin
                if ("Unit of Measure Code" <> xRec."Unit of Measure Code") and
                   (xRec."Unit of Measure Code" <> '') then begin
                    case Type of
                        Type::Item:
                            // P8000513A
                            begin
                                Item.Get("No.");
                                if Item.TrackAlternateUnits then
                                    AltQtyMgmt.CheckUOMDifferentFromAltUOM(Item, "Unit of Measure Code", FieldCaption("Unit of Measure Code"));
                                // P8000513A
                                factor := P800UOMFns.GetConversionFromTo("No.", xRec."Unit of Measure Code", "Unit of Measure Code");
                            end; // P8000513A
                        Type::FOODUnapprovedItem:
                            factor := P800UOMFns.GetConversionFromToUnapp("No.", xRec."Unit of Measure Code", "Unit of Measure Code");
                        // PR1.00.03 Begin
                        Type::"Production BOM":
                            begin
                                if BOMVars.Type = BOMVars.Type::BOM then
                                    factor := 1
                                else
                                    if xRec."Unit of Measure Code" = BOMVars."Weight UOM" then
                                        factor := 1 / BOMVars.Density
                                    else
                                        factor := BOMVars.Density;
                            end;
                    // PR1.00.03
                    end;

                    Validate("Batch Quantity", "Batch Quantity" * factor);
                    Validate("Unit Cost", Round("Unit Cost" / factor, 0.00001)); // P8000551A
                end;
                // PR1.00 End

                P800ProdOrderMgmt.SetProdBOMQuantity(Rec, FieldNo("Unit of Measure Code")); // PR3.60
            end;
        }
        field(14; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(15; Position; Code[10])
        {
            Caption = 'Position';
        }
        field(16; "Position 2"; Code[10])
        {
            Caption = 'Position 2';
        }
        field(17; "Position 3"; Code[10])
        {
            Caption = 'Position 3';
        }
        field(18; "Lead-Time Offset"; DateFormula)
        {
            Caption = 'Lead-Time Offset';

            trigger OnValidate()
            begin
                TestField("No.");
            end;
        }
        field(19; "Routing Link Code"; Code[10])
        {
            Caption = 'Routing Link Code';
            TableRelation = "Routing Link";

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateRoutingLinkCode(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                if "Routing Link Code" <> '' then begin
                    TestField(Type, Type::Item);
                    TestField("No.");
                end;
            end;
        }
        field(20; "Scrap %"; Decimal)
        {
            BlankNumbers = BlankNeg;
            Caption = 'Scrap %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;

            trigger OnValidate()
            begin
                TestField("No.");
                ReCalc(false, false, true); // P8001155
            end;
        }
        field(21; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = IF (Type = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD("No."));

            trigger OnValidate()
            begin
                if "Variant Code" = '' then
                    exit;
                TestField(Type, Type::Item);
                TestField("No.");
                ItemVariant.Get("No.", "Variant Code");
                Description := ItemVariant.Description;
            end;
        }
        field(22; Comment; Boolean)
        {
            CalcFormula = Exist("Production BOM Comment Line" WHERE("Production BOM No." = FIELD("Production BOM No."),
                                                                     "Version Code" = FIELD("Version Code"),
                                                                     "BOM Line No." = FIELD("Line No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(28; "Starting Date"; Date)
        {
            Caption = 'Starting Date';

            trigger OnValidate()
            begin
                TestField("No.");

                if "Starting Date" > 0D then
                    Validate("Ending Date");
            end;
        }
        field(29; "Ending Date"; Date)
        {
            Caption = 'Ending Date';

            trigger OnValidate()
            begin
                TestField("No.");

                if ("Ending Date" > 0D) and
                   ("Starting Date" > 0D) and
                   ("Starting Date" > "Ending Date")
                then
                    Error(
                      Text000,
                      FieldCaption("Ending Date"),
                      FieldCaption("Starting Date"));
            end;
        }
        field(40; Length; Decimal)
        {
            Caption = 'Length';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                Validate("Calculation Formula");
            end;
        }
        field(41; Width; Decimal)
        {
            Caption = 'Width';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                Validate("Calculation Formula");
            end;
        }
        field(42; Weight; Decimal)
        {
            Caption = 'Weight';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                Validate("Calculation Formula");
            end;
        }
        field(43; Depth; Decimal)
        {
            Caption = 'Depth';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                Validate("Calculation Formula");
            end;
        }
        field(44; "Calculation Formula"; Enum "Quantity Calculation Formula")
        {
            Caption = 'Calculation Formula';

            trigger OnValidate()
            begin
                TestField("No.");

                case "Calculation Formula" of
                    "Calculation Formula"::" ":
                        Quantity := "Quantity per";
                    "Calculation Formula"::Length:
                        Quantity := Round(Length * "Quantity per", UOMMgt.QtyRndPrecision);
                    "Calculation Formula"::"Length * Width":
                        Quantity := Round(Length * Width * "Quantity per", UOMMgt.QtyRndPrecision);
                    "Calculation Formula"::"Length * Width * Depth":
                        Quantity := Round(Length * Width * Depth * "Quantity per", UOMMgt.QtyRndPrecision);
                    "Calculation Formula"::Weight:
                        Quantity := Round(Weight * "Quantity per", UOMMgt.QtyRndPrecision);
                    "Calculation Formula"::"Fixed Quantity":
                        begin
                            TestField(Type, Type::Item);
                            Quantity := "Quantity per";
#if not CLEAN20
                            LogUsageFixedQuantity();
#endif
                        end;
                    else
                        OnValidateCalculationFormulaEnumExtension(Rec);
                end;
            end;
        }
        field(45; "Quantity per"; Decimal)
        {
            Caption = 'Quantity per';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                P800ProdOrderMgmt.SetProdBOMQuantity(Rec, FieldNo("Quantity per")); // PR3.60

                Validate("Calculation Formula");
                ReCalc(false, false, true); // PR1.00
            end;
        }
        field(37002081; "Quantity (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            AutoFormatExpression = GetItemNo();
            AutoFormatType = 37002080;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,1,0,%1,%2', Type, "No.");
            Caption = 'Quantity (Alt.)';
            Description = 'PR3.60';

            trigger OnValidate()
            begin
                P800ProdOrderMgmt.SetProdBOMQuantity(Rec, FieldNo("Quantity (Alt.)")); // PR3.60
            end;
        }
        field(37002093; "Unit Cost (Costing Units)"; Decimal)
        {
            Caption = 'Unit Cost (Costing Units)';
            DecimalPlaces = 2 : 5;
            Description = 'PR3.60';
            MinValue = 0;

            trigger OnValidate()
            begin
                P800ProdOrderMgmt.SetProdBOMUnitCost(Rec, FieldNo("Unit Cost (Costing Units)")); // PR3.60
            end;
        }
        field(37002460; "Batch Quantity"; Decimal)
        {
            Caption = 'Batch Quantity';
            Description = 'PR1.00';

            trigger OnValidate()
            begin
                P800ProdOrderMgmt.SetProdBOMQuantity(Rec, FieldNo("Batch Quantity")); // PR3.60

                ReCalc(true, true, true); // PR1.00
                SetLinePercent;   // P8007746
            end;
        }
        field(37002461; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            DecimalPlaces = 0 : 5;
            Description = 'PR1.00';
            MinValue = 0;

            trigger OnValidate()
            begin
                P800ProdOrderMgmt.SetProdBOMUnitCost(Rec, FieldNo("Unit Cost")); // PR3.60

                ReCalc(false, false, true); // PR1.00
            end;
        }
        field(37002462; "Extended Cost"; Decimal)
        {
            Caption = 'Extended Cost';
            DecimalPlaces = 0 : 5;
            Description = 'PR1.00';
            Editable = false;
        }
        field(37002463; "Yield % (Weight)"; Decimal)
        {
            Caption = 'Yield % (Weight)';
            DecimalPlaces = 0 : 5;
            Description = 'PR1.00,PR1.00.04';
            InitValue = 100;
            MaxValue = 100;
            MinValue = 0;

            trigger OnValidate()
            begin
                ReCalc(true, false, false); // PR1.00
                SetLinePercent;   // P8007746
            end;
        }
        field(37002464; "Yield % (Volume)"; Decimal)
        {
            Caption = 'Yield % (Volume)';
            DecimalPlaces = 0 : 5;
            Description = 'PR1.00,PR1.00.04';
            InitValue = 100;
            MaxValue = 100;
            MinValue = 0;

            trigger OnValidate()
            begin
                ReCalc(false, true, false); // PR1.00
                SetLinePercent;   // P8007746
            end;
        }
        field(37002465; "Output Weight (Base)"; Decimal)
        {
            Caption = 'Output Weight (Base)';
            Description = 'PR1.00';
        }
        field(37002466; "Output Volume (Base)"; Decimal)
        {
            Caption = 'Output Volume (Base)';
            Description = 'PR1.00';
        }
        field(37002467; "Input Weight (Base)"; Decimal)
        {
            Caption = 'Input Weight (Base)';
            Description = 'PR1.00';
        }
        field(37002468; "Input Volume (Base)"; Decimal)
        {
            Caption = 'Input Volume (Base)';
            Description = 'PR1.00';
        }
        field(37002469; "% of Total"; Decimal)
        {
            Caption = '% of Total';
            Description = 'PR1.00';
        }
        field(37002470; "Auto Plan if Component"; Boolean)
        {
            Caption = 'Auto Plan if Component';
            Description = 'PR1.00';
        }
        field(37002471; "Step Code"; Code[10])
        {
            Caption = 'Step Code';
            Description = 'PR2.00.03';
        }
        field(37002600; "Prod. BOM Type"; Option)
        {
            CalcFormula = Lookup("Production BOM Header"."Mfg. BOM Type" WHERE("No." = FIELD("Production BOM No.")));
            Caption = 'Prod. BOM Type';
            Description = 'PR3.60';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'BOM,Formula,Process';
            OptionMembers = BOM,Formula,Process;
        }
        field(37002601; "Prod. BOM Description"; Text[100])
        {
            CalcFormula = Lookup("Production BOM Header".Description WHERE("No." = FIELD("Production BOM No.")));
            Caption = 'Prod. BOM Description';
            Description = 'PR3.60';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002602; "Prod. BOM Output Type"; Option)
        {
            CalcFormula = Lookup("Production BOM Header"."Output Type" WHERE("No." = FIELD("Production BOM No.")));
            Caption = 'Prod. BOM Output Type';
            Description = 'PR3.60';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'Item,Family';
            OptionMembers = Item,Family;
        }
        field(37002680; "Commodity Class Code"; Code[10])
        {
            Caption = 'Commodity Class Code';
            TableRelation = "Commodity Class";

            trigger OnValidate()
            begin
                CommItemMgmt.ProdBOMLineValidate(Rec, FieldNo("Commodity Class Code")); // P8000856
            end;
        }
        field(37002681; "Pre-Process Type Code"; Code[10])
        {
            Caption = 'Pre-Process Type Code';
            Description = 'P8001082';
            TableRelation = "Pre-Process Type";

            trigger OnValidate()
            var
                PreProcessType: Record "Pre-Process Type";
            begin
                // P8001082
                if ("Pre-Process Type Code" = '') then
                    Validate("Pre-Process Lead Time (Days)", 0)
                else begin
                    PreProcessType.Get("Pre-Process Type Code");
                    Validate("Pre-Process Lead Time (Days)", PreProcessType."Default Lead Time (Days)");
                end;
            end;
        }
        field(37002682; "Pre-Process Lead Time (Days)"; Integer)
        {
            Caption = 'Pre-Process Lead Time (Days)';
            Description = 'P8001082';
            MinValue = 0;

            trigger OnValidate()
            begin
                // P8001082
                if ("Pre-Process Lead Time (Days)" <> 0) then
                    TestField("Pre-Process Type Code");
            end;
        }
    }

    keys
    {
        key(Key1; "Production BOM No.", "Version Code", "Line No.")
        {
            Clustered = true;
            SumIndexFields = "Output Weight (Base)", "Output Volume (Base)", "Input Weight (Base)", "Input Volume (Base)", "Extended Cost";
        }
        key(Key2; Type, "No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ProdBOMComment: Record "Production BOM Comment Line";
        PlanningAssignment: Record "Planning Assignment";
    begin
        if Type <> Type::" " then begin
            TestStatus;
            case Type of
                Type::Item:
                    PlanningAssignment.AssignForBOMLine(Rec); // P8001030
                Type::"Production BOM":
                    PlanningAssignment.AssignForBOMLine(Rec); // P8001030
                else
                    OnDeleteOnCaseTypeElse(Rec);
            end;
        end;

        ProdBOMComment.SetRange("Production BOM No.", "Production BOM No.");
        ProdBOMComment.SetRange("BOM Line No.", "Line No.");
        ProdBOMComment.SetRange("Version Code", "Version Code");
        ProdBOMComment.DeleteAll();

        "Output Volume (Base)" := 0;   // P8007746
        "Output Weight (Base)" := 0;   // P8007746
        SetLinePercent;   // P8007746
    end;

    trigger OnInsert()
    begin
        TestStatus;
    end;

    trigger OnModify()
    begin
        if Type <> Type::" " then
            TestStatus;
    end;

    var
        Text000: Label '%1 must be later than %2.';
        Item: Record Item;
        ProdBOMHeader: Record "Production BOM Header";
        ItemVariant: Record "Item Variant";
        BOMVersionUOMErr: Label 'The Unit of Measure Code %1 for Item %2 does not exist. Identification fields and values: Production BOM No. = %3, Version Code = %4.', Comment = '%1=UOM Code;%2=Item No.;%3=Production BOM No.;%4=Version Code';
        BOMHeaderUOMErr: Label 'The Unit of Measure Code %1 for Item %2 does not exist. Identification fields and values: Production BOM No. = %3.', Comment = '%1=UOM Code;%2=Item No.;%3=Production BOM No.';
        BOMLineUOMErr: Label 'The Unit of Measure Code %1 for Item %2 does not exist. Identification fields and values: Production BOM No. = %3, Version Code = %4, Line No. = %5.', Comment = '%1=UOM Code;%2=Item No.;%3=Production BOM No.;%4=Version Code;%5=Line No.';
        UOMMgt: Codeunit "Unit of Measure Management";
        ItemUOM: Record "Item Unit of Measure";
        UnapprItem: Record "Unapproved Item";
        StdText: Record "Standard Text";
        ProdBOMVersion: Record "Production BOM Version";
        TempLine: Record "Production BOM Line";
        BOMVars: Record "BOM Variables";
        VersionMgt: Codeunit VersionManagement;
        P800ProdOrderMgmt: Codeunit "Process 800 Prod. Order Mgt.";
        UOMMgmt: Codeunit "Unit of Measure Management";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
        PackVars: Record "Package Variable";
        ProcessFns: Codeunit "Process 800 Functions";
        Text37002000: Label 'Type must not be blank.';
        Text37002001: Label 'Invalid unit of measure.';
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        CommItemMgmt: Codeunit "Commodity Item Management";

    procedure TestStatus()
    var
        ProdBOMVersion: Record "Production BOM Version";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTestStatus(Rec, IsHandled);
        if IsHandled then
            exit;

        if IsTemporary then
            exit;

        if "Version Code" = '' then begin
            ProdBOMHeader.Get("Production BOM No.");
            if ProdBOMHeader.Status = ProdBOMHeader.Status::Certified then
                ProdBOMHeader.FieldError(Status);
        end else begin
            ProdBOMVersion.Get("Production BOM No.", "Version Code");
            if ProdBOMVersion.Status = ProdBOMVersion.Status::Certified then
                ProdBOMVersion.FieldError(Status);
        end;

        OnAfterTestStatus(Rec, ProdBOMHeader, ProdBOMVersion);
    end;

    procedure GetQtyPerUnitOfMeasure(): Decimal
    var
        Item: Record Item;
        UOMMgt: Codeunit "Unit of Measure Management";
    begin
        if Type = Type::Item then begin
            Item.Get("No.");
            exit(
              UOMMgt.GetQtyPerUnitOfMeasure(Item, "Unit of Measure Code"));
        end;
        exit(1);
    end;

    procedure GetBOMHeaderQtyPerUOM(Item: Record Item): Decimal
    var
        ProdBOMHeader: Record "Production BOM Header";
        ProdBOMVersion: Record "Production BOM Version";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        UOMMgt: Codeunit "Unit of Measure Management";
    begin
        if "Production BOM No." = '' then
            exit(1);

        if "Version Code" <> '' then begin
            ProdBOMVersion.Get("Production BOM No.", "Version Code");
            if not ItemUnitOfMeasure.Get(Item."No.", ProdBOMVersion."Unit of Measure Code") then
                Error(BOMVersionUOMErr, ProdBOMVersion."Unit of Measure Code", Item."No.", "Production BOM No.", "Version Code");
            exit(UOMMgt.GetQtyPerUnitOfMeasure(Item, ProdBOMVersion."Unit of Measure Code"));
        end;

        ProdBOMHeader.Get("Production BOM No.");
        if not ItemUnitOfMeasure.Get(Item."No.", ProdBOMHeader."Unit of Measure Code") then
            Error(BOMHeaderUOMErr, ProdBOMHeader."Unit of Measure Code", Item."No.", "Production BOM No.");
        exit(UOMMgt.GetQtyPerUnitOfMeasure(Item, ProdBOMHeader."Unit of Measure Code"));
    end;

    procedure GetBOMLineQtyPerUOM(Item: Record Item): Decimal
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        UOMMgt: Codeunit "Unit of Measure Management";
    begin
        if "No." = '' then
            exit(1);

        if not ItemUnitOfMeasure.Get(Item."No.", "Unit of Measure Code") then
            Error(BOMLineUOMErr, "Unit of Measure Code", Item."No.", "Production BOM No.", "Version Code", "Line No.");
        exit(UOMMgt.GetQtyPerUnitOfMeasure(Item, "Unit of Measure Code"));
    end;
#if not CLEAN20
    local procedure LogUsageFixedQuantity()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        if (Rec."Calculation Formula" = Rec."Calculation Formula"::"Fixed Quantity") and (xRec."Calculation Formula" <> Rec."Calculation Formula") then
            FeatureTelemetry.LogUsage('0000GFP', 'Fixed Quantity in BOM Items', 'Calculation formula updated');
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnAfterTestStatus(ProductionBOMLine: Record "Production BOM Line"; ProductionBOMHeader: Record "Production BOM Header"; ProductionBOMVersion: Record "Production BOM Version")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateNo(var ProductionBOMLine: Record "Production BOM Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateRoutingLinkCode(var ProductionBOMLine: Record "Production BOM Line"; xProductionBOMLine: Record "Production BOM Line"; CallingFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestStatus(var ProductionBOMLine: Record "Production BOM Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeleteOnCaseTypeElse(var ProductionBOMLine: Record "Production BOM Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateCalculationFormulaEnumExtension(var ProductionBOMLine: Record "Production BOM Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateNoOnAfterAssignItemFields(var ProductionBOMLine: Record "Production BOM Line"; Item: Record Item; var xProductionBOMLine: Record "Production BOM Line"; CallingFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateNoOnAfterAssignProdBOMFields(var ProductionBOMLine: Record "Production BOM Line"; ProductionBOMHeader: Record "Production BOM Header"; var xProductionBOMLine: Record "Production BOM Line"; CallingFieldNo: Integer)
    begin
    end;

    procedure ReCalc(wgt: Boolean; vol: Boolean; cst: Boolean)
    var
        factor: Decimal;
        BOMLine: Record "Production BOM Line";
        UOM: Record "Unit of Measure";
        InvSetup: Record "Inventory Setup";
    begin
        // PR1.00 Begin
        if Type = Type::" " then // PR1.00.03
            exit;

        ProdBOMVersion.Get("Production BOM No.", "Version Code");
        InvSetup.Get;
        CalcPhantom(BOMVars); // PR1.00.03, P80066030

        if wgt then begin
            "Input Weight (Base)" := ConvertToMetric(Type, "No.", "Unit of Measure Code", 2, "Batch Quantity");
            "Output Weight (Base)" := AdjustYield("Input Weight (Base)",
              "Yield % (Weight)", ProdBOMVersion."Yield % (Weight)");
        end;
        if vol then begin
            "Input Volume (Base)" := ConvertToMetric(Type, "No.", "Unit of Measure Code", 3, "Batch Quantity");
            "Output Volume (Base)" := AdjustYield("Input Volume (Base)",
              "Yield % (Volume)", ProdBOMVersion."Yield % (Volume)");
        end;
        if cst then begin
            if ProdBOMVersion.Type in [ProdBOMVersion.Type::Formula, ProdBOMVersion.Type::Process] then // PR1.20
                "Extended Cost" := "Batch Quantity" * "Unit Cost"
            else
                "Extended Cost" := "Quantity per" * "Unit Cost";
            "Extended Cost" := Round("Extended Cost" * (1 + "Scrap %" / 100), 0.00001); // P8000551A, P8001155
        end;
        // PR1.00 End
    end;

    procedure ConvertToMetric(typ: Integer; no: Code[20]; uom: Code[10]; lwv: Integer; qty: Decimal): Decimal
    var
        MeasureSystem: Record "Measuring System";
        factor: Decimal;
    begin
        // PR1.00.02 Begin
        case typ of
            Type::Item:
                factor := P800UOMFns.GetConversionToMetricBase(no, uom, lwv);
            Type::FOODUnapprovedItem:
                factor := P800UOMFns.GetConversionToMetrciBaseUnapp(no, uom, lwv);
            // PR1.00.03 Begin
            Type::"Production BOM":
                begin
                    case lwv of
                        2:
                            factor := BOMVars."Output Weight (Base)";
                        3:
                            factor := BOMVars."Output Volume (Base)";
                        else
                            factor := 0;
                    end;
                    if (uom = BOMVars."Weight UOM") and (BOMVars."Output Weight" <> 0) then
                        factor := factor / BOMVars."Output Weight"
                    else
                        if (uom = BOMVars."Volume UOM") and (BOMVars."Output Volume" <> 0) then
                            factor := factor / BOMVars."Output Volume"
                        else
                            factor := 0;
                end;
        // PR1.00.03 End
        end;
        exit(factor * qty);
        // PR1.00.02 End
    end;

    procedure AdjustYield(qty: Decimal; yld1: Decimal; yld2: Decimal): Decimal
    begin
        exit(qty * (yld1 / 100) * (yld2 / 100)); // PR1.00
    end;

    procedure CalcPhantom(var BOMVariables: Record "BOM Variables")
    var
        ProductionBOMHeader: Record "Production BOM Header";
    begin
        // PR1.00.03, P80066030
        if (Type = Type::"Production BOM") and (BOMVariables."No." <> "No.") then begin
            Clear(BOMVariables);
            ProductionBOMHeader.Get("No.");
            BOMVariables.Type := ProductionBOMHeader."Mfg. BOM Type";
            BOMVariables."No." := "No.";
            BOMVariables."Version Code" := VersionMgt.GetBOMVersion("No.", WorkDate, true);
            BOMVariables."Include In Rollup" := true;
            BOMVariables.InitRecord;
        end;
    end;

    procedure NoLookup() res: Boolean
    var
        StdText: Record "Standard Text";
        Item: Record Item;
        BOM: Record "Production BOM Header";
        Unapp: Record "Unapproved Item";
        PkgVar: Record "Package Variable";
        StdTextList: Page "Standard Text Codes";
        ItemList: Page "Item List";
        BOMList: Page "Production BOM List";
        UnappList: Page "Unapproved Item List";
        PkgVarList: Page "Package Variables";
    begin
        // PR1.00.05 Begin
        res := false;
        case Type of
            Type::" ":
                begin
                    StdTextList.SetTableView(StdText);
                    if StdText.Get("No.") then
                        StdTextList.SetRecord(StdText);
                    StdTextList.LookupMode := true;
                    if StdTextList.RunModal = ACTION::LookupOK then begin
                        StdTextList.GetRecord(StdText);
                        Validate("No.", StdText.Code);
                        res := true;
                    end;
                end;

            Type::Item:
                begin
                    Item.SetFilter("Item Type", '%1|%2|%3', Item."Item Type"::"Raw Material",
                      Item."Item Type"::Packaging, Item."Item Type"::Intermediate);
                    ItemList.SetTableView(Item);
                    if Item.Get("No.") then
                        ItemList.SetRecord(Item);
                    ItemList.LookupMode := true;
                    if ItemList.RunModal = ACTION::LookupOK then begin
                        ItemList.GetRecord(Item);
                        Validate("No.", Item."No.");
                        res := true;
                    end;
                end;

            Type::"Production BOM":
                begin
                    BOMList.SetTableView(BOM);
                    if BOM.Get("No.") then
                        BOMList.SetRecord(BOM);
                    BOMList.LookupMode := true;
                    if BOMList.RunModal = ACTION::LookupOK then begin
                        BOMList.GetRecord(BOM);
                        Validate("No.", BOM."No.");
                        res := true;
                    end;
                end;

            Type::FOODUnapprovedItem:
                begin
                    UnappList.SetTableView(Unapp);
                    if Unapp.Get("No.") then
                        UnappList.SetRecord(Unapp);
                    UnappList.LookupMode := true;
                    if UnappList.RunModal = ACTION::LookupOK then begin
                        UnappList.GetRecord(Unapp);
                        Validate("No.", Unapp."No.");
                        res := true;
                    end;
                end;

            // PR2.00.05 Begin
            Type::FOODVariable:
                begin
                    PkgVarList.SetTableView(PkgVar);
                    if PkgVar.Get("No.") then
                        PkgVarList.SetRecord(PkgVar);
                    PkgVarList.LookupMode := true;
                    if PkgVarList.RunModal = ACTION::LookupOK then begin
                        PkgVarList.GetRecord(PkgVar);
                        Validate("No.", PkgVar.Code);
                        res := true;
                    end;
                end;
        // PR2.00.05 End

        end;
        // PR1.00 End
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

    procedure GetPackageOutputQty(RMUnitOfMeasureCode: Code[10]; RMQty: Decimal): Decimal
    begin
        // PR3.10
        if ("No." = '') or (Quantity = 0) or (RMQty = 0) then
            exit(0);
        if ("No." <> Item."No.") then
            Item.Get("No.");
        exit(RMQty * UOMMgmt.GetQtyPerUnitOfMeasure(Item, RMUnitOfMeasureCode) /
            (Quantity * UOMMgmt.GetQtyPerUnitOfMeasure(Item, "Unit of Measure Code")));
        // PR3.10
    end;

    procedure GetProcessOutputQty(RMUnitOfMeasureCode: Code[10]; RMQty: Decimal): Decimal
    begin
        // PR3.10
        if ("No." = '') or ("Batch Quantity" = 0) or (RMQty = 0) then
            exit(0);
        if ("No." <> Item."No.") then
            Item.Get("No.");
        exit(RMQty * UOMMgmt.GetQtyPerUnitOfMeasure(Item, RMUnitOfMeasureCode) /
            ("Batch Quantity" * UOMMgmt.GetQtyPerUnitOfMeasure(Item, "Unit of Measure Code")));
        // PR3.10
    end;

    local procedure SetLinePercent()
    var
        ProdBOMVersion: Record "Production BOM Version";
        ProdBOMLine: Record "Production BOM Line";
    begin
        ProdBOMVersion.Get("Production BOM No.", "Version Code");
        case ProdBOMVersion."Primary UOM" of
            ProdBOMVersion."Primary UOM"::Weight:
                begin
                    ProdBOMVersion.CalcFields("Output Weight (Base)");
                    ProdBOMVersion."Output Weight (Base)" :=
                      ProdBOMVersion."Output Weight (Base)" - xRec."Output Weight (Base)" + "Output Weight (Base)";
                    if (ProdBOMVersion."Output Weight (Base)" = 0) then
                        "% of Total" := 0
                    else
                        "% of Total" := 100 * ("Output Weight (Base)" / ProdBOMVersion."Output Weight (Base)");
                end;
            ProdBOMVersion."Primary UOM"::Volume:
                begin
                    ProdBOMVersion.CalcFields("Output Volume (Base)");
                    ProdBOMVersion."Output Volume (Base)" :=
                      ProdBOMVersion."Output Volume (Base)" - xRec."Output Volume (Base)" + "Output Volume (Base)";
                    if (ProdBOMVersion."Output Volume (Base)" = 0) then
                        "% of Total" := 0
                    else
                        "% of Total" := 100 * ("Output Volume (Base)" / ProdBOMVersion."Output Volume (Base)");
                end;
        end;

        ProdBOMLine.SetRange("Production BOM No.", "Production BOM No.");
        ProdBOMLine.SetRange("Version Code", "Version Code");
        ProdBOMLine.SetFilter("Line No.", '<>%1', "Line No.");
        if ProdBOMLine.FindSet then
            repeat
                case ProdBOMVersion."Primary UOM" of
                    ProdBOMVersion."Primary UOM"::Weight:
                        if (ProdBOMVersion."Output Weight (Base)" = 0) then
                            ProdBOMLine."% of Total" := 0
                        else
                            ProdBOMLine."% of Total" :=
                              100 * (ProdBOMLine."Output Weight (Base)" / ProdBOMVersion."Output Weight (Base)");
                    ProdBOMVersion."Primary UOM"::Volume:
                        if (ProdBOMVersion."Output Volume (Base)" = 0) then
                            ProdBOMLine."% of Total" := 0
                        else
                            ProdBOMLine."% of Total" :=
                              100 * (ProdBOMLine."Output Volume (Base)" / ProdBOMVersion."Output Volume (Base)");
                end;
                ProdBOMLine.Modify(true);
            until (ProdBOMLine.Next = 0);

        /*
        CASE BOMVars."Primary UOM" OF
          BOMVars."Primary UOM"::Weight : factor := BOMVars."Output Weight (Base)";
          BOMVars."Primary UOM"::Volume : factor := BOMVars."Output Volume (Base)";
        END;
        IF factor <> 0 THEN
          factor := 100 / factor;
        CASE BOMVars."Primary UOM" OF
          BOMVars."Primary UOM"::Weight : "% of Total" := "Output Weight (Base)" * factor;
          BOMVars."Primary UOM"::Volume : "% of Total" := "Output Volume (Base)" * factor;
        END;
        */

    end;
}

