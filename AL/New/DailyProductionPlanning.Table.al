table 37002475 "Daily Production Planning"
{
    // PR4.00
    // P8000197A, Myers Nissi, Jack Reynolds, 21 SEP 05
    //   This is a temporary table to contain data for production orders and production order lines for the daily production
    //   planning board.  The original display will just show production orders but each order can be expanded to show the
    //   lines as well.  As values are changed they are compared with the original values and if different will display in
    //   red.
    // 
    // P8000259A, VerticalSoft, Jack Reynolds, 28 OCT 05
    //   Add fields for production sequencing
    // 
    // P8000263A, VerticalSoft, Jack Reynolds, 02 NOV 05
    //   Add field Changed to allow checking for changed records on closing the form
    // 
    // PRW16.00.03
    // P8000789, VerticalSoft, Rick Tweedle, 11 MAR 10
    //   Added field for RTC tree view
    // 
    // PRW16.00.06
    // P8001099, Columbus IT, Jack Reynolds, 27 SEP 12
    //   Expand Equipment Description and Orig. Equipment Description
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.10.01
    // P8001258, Columbus IT, Jack Reynolds, 10 JAN 14
    //   Increase size ot text fields/variables
    // 
    // PRW17.10.02
    // P8001279, Columbus IT, Jack Reynolds, 05 FEB 14
    //   Default replenishment area for equipment
    // 
    // P8001301, Columbus IT, Jack Reynolds, 03 MAR 14
    //   Update Rollup 4
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 08 MAR 16
    //   Expand BOM Version code to Code20
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Daily Production Planning';
    LookupPageID = "Daily Prod. Planning-Order";
    ReplicateData = false;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(2; Expanded; Boolean)
        {
            Caption = 'Expanded';
            DataClassification = SystemMetadata;
        }
        field(3; Display; Boolean)
        {
            Caption = 'Display';
            DataClassification = SystemMetadata;
        }
        field(4; Changed; Boolean)
        {
            Caption = 'Changed';
            DataClassification = SystemMetadata;
        }
        field(11; Status; Option)
        {
            Caption = 'Status';
            DataClassification = SystemMetadata;
            OptionCaption = ',,Firm Planned,Released';
            OptionMembers = ,,"Firm Planned",Released;
        }
        field(12; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(13; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(14; "Source Type"; Option)
        {
            Caption = 'Source Type';
            DataClassification = SystemMetadata;
            OptionCaption = ' ,Item,Family,Sales Header';
            OptionMembers = " ",Item,Family,"Sales Header";
        }
        field(15; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            DataClassification = SystemMetadata;
            TableRelation = IF ("Source Type" = CONST(Item)) Item
            ELSE
            IF ("Source Type" = CONST(Family)) Family
            ELSE
            IF ("Source Type" = CONST("Sales Header")) "Sales Header"."No." WHERE("Document Type" = CONST(Order));
        }
        field(16; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = SystemMetadata;
            TableRelation = Location;

            trigger OnValidate()
            begin
                if "Location Code" <> xRec."Location Code" then begin
                    "Equipment Code" := '';
                    "Equipment Description" := '';
                end;

                GetProdTime;
                CalculateDates(FieldNo("Starting Date"), true);

                if (0D < "Starting Date") and ("Starting Date" < WorkDate) then
                    FieldError("Starting Date", StrSubstNo(Text002, WorkDate));
            end;
        }
        field(17; "Orig. Location Code"; Code[10])
        {
            Caption = 'Orig. Location Code';
            DataClassification = SystemMetadata;
            Editable = false;

            trigger OnValidate()
            begin
                "Location Code" := "Orig. Location Code";
            end;
        }
        field(18; "Equipment Code"; Code[20])
        {
            Caption = 'Equipment Code';
            DataClassification = SystemMetadata;
            TableRelation = Resource."No." WHERE(Type = CONST(Machine),
                                                  "Location Code" = FIELD("Location Code"));

            trigger OnValidate()
            begin
                if Resource.Get("Equipment Code") then begin
                    "Equipment Description" := Resource.Name;
                    "Location Code" := Resource."Location Code";
                end else begin
                    "Equipment Description" := '';
                    "Location Code" := '';
                end;

                GetProdTime;
                CalculateDates(FieldNo("Starting Date"), true);

                if (0D < "Starting Date") and ("Starting Date" < WorkDate) then
                    FieldError("Starting Date", StrSubstNo(Text002, WorkDate));
            end;
        }
        field(19; "Equipment Description"; Text[100])
        {
            Caption = 'Equipment Description';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(20; "Orig. Equipment Code"; Code[20])
        {
            Caption = 'Orig. Equipment Code';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = Resource."No." WHERE(Type = CONST(Machine),
                                                  "Location Code" = FIELD("Orig. Location Code"));

            trigger OnValidate()
            begin
                if Resource.Get("Orig. Equipment Code") then
                    "Orig. Equipment Description" := Resource.Name;

                "Equipment Code" := "Orig. Equipment Code";
                "Equipment Description" := "Orig. Equipment Description";
            end;
        }
        field(21; "Orig. Equipment Description"; Text[100])
        {
            Caption = 'Orig. Equipment Description';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(22; Release; Boolean)
        {
            Caption = 'Release';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                ProdOrder: Record "Production Order";
            begin
                if (Status <> Status::"Firm Planned") or ("Line No." <> 0) then
                    Release := false;
                ProdOrder.Get(Status, "No.");
                if (ProdOrder."Batch Prod. Order No." <> '') and (not ProdOrder."Batch Order") then
                    Release := false;
            end;
        }
        field(23; "Sequence Code"; Code[10])
        {
            Caption = 'Sequence Code';
            DataClassification = SystemMetadata;
            TableRelation = "Production Sequence";

            trigger OnValidate()
            begin
                // P8000259A
                if "Sequence Code" = '' then begin
                    "Sequence Value" := 2147483647;
                    Bold := false;
                end else begin
                    ProdSequence.Get("Sequence Code");
                    "Sequence Value" := ProdSequence."Sequence Value";
                    Bold := ProdSequence."Display Bold";
                end;
            end;
        }
        field(24; "Orig. Sequence Code"; Code[10])
        {
            Caption = 'Orig. Sequence Code';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Production Sequence";

            trigger OnValidate()
            begin
                // P8000259A
                Validate("Sequence Code", "Orig. Sequence Code");
            end;
        }
        field(25; "Sequence Value"; Integer)
        {
            Caption = 'Sequence Value';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(26; Bold; Boolean)
        {
            Caption = 'Bold';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(27; "Sort Value"; Decimal)
        {
            Caption = 'Sort Value';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(41; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = Item;

            trigger OnValidate()
            begin
                Item.Get("Item No.");

                "Item Description" := Item.Description;
                Validate("Unit of Measure Code", Item."Base Unit of Measure");
            end;
        }
        field(42; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(43; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = SystemMetadata;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(44; "Production BOM No."; Code[20])
        {
            Caption = 'Production BOM No.';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if "Due Date" <> 0D then begin
                    "Version Code" := VersionMgt.GetBOMVersion("Production BOM No.", "Due Date", true);
                    if "Version Code" = '' then
                        Error(Text001, FieldCaption("Production BOM No."), "Production BOM No.");
                end;
            end;
        }
        field(45; "Version Code"; Code[20])
        {
            Caption = 'Version Code';
            DataClassification = SystemMetadata;
        }
        field(61; "Due Date"; Date)
        {
            Caption = 'Due Date';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if "Due Date" = xRec."Due Date" then
                    exit;

                CalculateDates(FieldNo("Due Date"), true);

                if (0D < "Starting Date") and ("Starting Date" < WorkDate) then
                    FieldError("Starting Date", StrSubstNo(Text002, WorkDate));
            end;
        }
        field(62; "Orig. Due Date"; Date)
        {
            Caption = 'Orig. Due Date';
            DataClassification = SystemMetadata;
            Editable = false;

            trigger OnValidate()
            begin
                "Due Date" := "Orig. Due Date";
            end;
        }
        field(63; "Starting Time"; Time)
        {
            Caption = 'Starting Time';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if "Starting Time" = xRec."Starting Time" then
                    exit;

                CalculateDates(FieldNo("Starting Time"), true);
            end;
        }
        field(64; "Orig. Starting Time"; Time)
        {
            Caption = 'Orig. Starting Time';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                "Starting Time" := "Orig. Starting Time";
            end;
        }
        field(65; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if "Starting Date" = xRec."Starting Date" then
                    exit;

                if (0D < "Starting Date") and ("Starting Date" < WorkDate) then
                    FieldError("Starting Date", StrSubstNo(Text002, WorkDate));

                CalculateDates(FieldNo("Starting Date"), true);
            end;
        }
        field(66; "Orig. Starting Date"; Date)
        {
            Caption = 'Orig. Starting Date';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                "Starting Date" := "Orig. Starting Date";
            end;
        }
        field(67; "Ending Time"; Time)
        {
            Caption = 'Ending Time';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if "Ending Time" = xRec."Ending Time" then
                    exit;

                CalculateDates(FieldNo("Ending Time"), true);

                if (0D < "Starting Date") and ("Starting Date" < WorkDate) then
                    FieldError("Starting Date", StrSubstNo(Text002, WorkDate));
            end;
        }
        field(68; "Orig. Ending Time"; Time)
        {
            Caption = 'Orig. Ending Time';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                "Ending Time" := "Orig. Ending Time";
            end;
        }
        field(69; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if "Ending Date" = xRec."Ending Date" then
                    exit;

                CalculateDates(FieldNo("Ending Date"), true);

                if (0D < "Starting Date") and ("Starting Date" < WorkDate) then
                    FieldError("Starting Date", StrSubstNo(Text002, WorkDate));
            end;
        }
        field(70; "Orig. Ending Date"; Date)
        {
            Caption = 'Orig. Ending Date';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                "Ending Date" := "Orig. Ending Date";
            end;
        }
        field(71; Quantity; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                "Quantity (Base)" := Round(Quantity * "Qty. per Unit of Measure", 0.00001);

                CalculateDates(FieldNo("Starting Date"), true);

                if (0D < "Starting Date") and ("Starting Date" < WorkDate) then
                    FieldError("Starting Date", StrSubstNo(Text002, WorkDate));
            end;
        }
        field(72; "Orig. Quantity"; Decimal)
        {
            Caption = 'Orig. Quantity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;

            trigger OnValidate()
            begin
                Quantity := "Orig. Quantity";

                "Orig. Quantity (Base)" := Round("Orig. Quantity" * "Qty. per Unit of Measure", 0.00001);
                "Quantity (Base)" := "Orig. Quantity (Base)";
            end;
        }
        field(73; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DataClassification = SystemMetadata;
        }
        field(74; "Orig. Quantity (Base)"; Decimal)
        {
            Caption = 'Orig. Quantity (Base)';
            DataClassification = SystemMetadata;
        }
        field(75; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = SystemMetadata;
            Editable = false;

            trigger OnValidate()
            begin
                if ItemUOM.Get("Item No.", "Unit of Measure Code") then
                    "Qty. per Unit of Measure" := ItemUOM."Qty. per Unit of Measure";
            end;
        }
        field(76; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DataClassification = SystemMetadata;
        }
        field(77; "Orig. Fixed Time (Hours)"; Decimal)
        {
            Caption = 'Orig. Fixed Time (Hours)';
            DataClassification = SystemMetadata;
        }
        field(78; "Orig. Variable Time (Hours)"; Decimal)
        {
            Caption = 'Orig. Variable Time (Hours)';
            DataClassification = SystemMetadata;
        }
        field(79; "Fixed Time (Hours)"; Decimal)
        {
            Caption = 'Fixed Time (Hours)';
            DataClassification = SystemMetadata;
        }
        field(80; "Variable Time (Hours)"; Decimal)
        {
            Caption = 'Variable Time (Hours)';
            DataClassification = SystemMetadata;
        }
        field(81; "Quantity Factor"; Decimal)
        {
            Caption = 'Quantity Factor';
            DataClassification = SystemMetadata;
        }
        field(82; Indentation; Integer)
        {
            Caption = 'Indentation';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Item No.", "Due Date", "Equipment Code", Status, "No.")
        {
        }
        key(Key3; "Equipment Code", "Due Date", "Item No.", Status, "No.")
        {
        }
        key(Key4; "Location Code", "Equipment Code", "Starting Date", "Sequence Value")
        {
        }
        key(Key5; "Sort Value")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Item: Record Item;
        Resource: Record Resource;
        ItemUOM: Record "Item Unit of Measure";
        ProdSequence: Record "Production Sequence";
        VersionMgt: Codeunit VersionManagement;
        Text001: Label 'No active version for %1 %2.';
        Text002: Label 'must be on or after %1';

    procedure ExpansionStatus(): Integer
    begin
        case true of
            "Line No." <> 0:
                exit(2);
            Expanded:
                exit(0);
            else
                exit(1);
        end;
    end;

    procedure IncludesItem(ItemNo: Code[20]): Boolean
    var
        ProdPlan2: Record "Daily Production Planning";
        ItemFound: Boolean;
    begin
        if "Line No." <> 0 then
            exit("Item No." = ItemNo);

        ProdPlan2.Copy(Rec); // So we can put it back later

        Reset;
        SetRange(Status, Status);
        SetRange("No.", "No.");
        SetFilter("Line No.", '<>0');
        SetRange("Item No.", ItemNo);
        ItemFound := Find('-');

        Rec.Copy(ProdPlan2);

        exit(ItemFound);
    end;

    procedure GetProdTime()
    var
        ProdBOMEquip: Record "Prod. BOM Equipment";
        ProdPlan2: Record "Daily Production Planning";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
        ProdOrderHours: array[2] of Decimal;
        VariableHours: Decimal;
    begin
        "Fixed Time (Hours)" := 0;
        "Variable Time (Hours)" := 0;

        if "Equipment Code" = '' then
            exit;

        if ("Production BOM No." = '') or ("Version Code" = '') then begin
            ProdPlan2.Copy(Rec);
            Reset;
            SetRange(Status, Status);
            SetRange("No.", "No.");
            SetFilter("Line No.", '<>0');
            if Find('-') then
                repeat
                    "Equipment Code" := ProdPlan2."Equipment Code";
                    GetProdTime;
                    if ProdOrderHours[1] < "Fixed Time (Hours)" then
                        ProdOrderHours[1] := "Fixed Time (Hours)";
                    if Quantity <> 0 then begin
                        VariableHours := "Variable Time (Hours)" / "Quantity Factor";
                        if ProdOrderHours[2] < VariableHours then
                            ProdOrderHours[2] := VariableHours;
                    end;
                until Next = 0;
            Copy(ProdPlan2);
            "Fixed Time (Hours)" := ProdOrderHours[1];
            "Variable Time (Hours)" := ProdOrderHours[2];
        end else begin
            if ProdBOMEquip.Get("Production BOM No.", "Version Code", "Equipment Code") then begin
                "Fixed Time (Hours)" := ProdBOMEquip."Fixed Prod. Time (Hours)";
                "Variable Time (Hours)" := ProdBOMEquip."Variable Prod. Time (Hours)";
                "Variable Time (Hours)" := "Variable Time (Hours)" *
                  P800UOMFns.GetConversionFromTo("Item No.",
                    "Unit of Measure Code", VersionMgt.GetBOMUnitOfMeasure("Production BOM No.", "Version Code"));
            end;
        end;
    end;

    procedure GetProdOrderLine(var ProdOrderLine: Record "Prod. Order Line"): Code[20]
    begin
        if ("Line No." <> 0) and (CopyStr("No.", 1, 3) <> '***') then
            ProdOrderLine.Get(Status, "No.", "Line No.");

        ProdOrderLine.SetRange(Status, Status);
        ProdOrderLine.SetRange("Prod. Order No.", "No.");
        ProdOrderLine.SetFilter("Line No.", '<>0');
        if not ProdOrderLine.Find('-') then
            if "Source Type" = "Source Type"::Item then begin
                ProdOrderLine."Item No." := "Source No.";
                ProdOrderLine."Variant Code" := "Variant Code";
                ProdOrderLine."Location Code" := "Location Code";
            end;
    end;

    procedure CalculateDates(FldNo: Integer; ResetTime: Boolean)
    var
        ProdDateTime: Record "Production Time by Date" temporary;
        ProdOrderLine: Record "Prod. Order Line";
        LeadTimeMgt: Codeunit "Lead-Time Management";
        P800CalMgt: Codeunit "Process 800 Calendar Mngt.";
        ProdHours: Decimal;
    begin
        if Quantity <> 0 then
            ProdHours := "Fixed Time (Hours)" + (Quantity * "Variable Time (Hours)");
        GetProdOrderLine(ProdOrderLine);

        case FldNo of
            FieldNo("Due Date"):
                begin
                    if "Due Date" = 0D then
                        exit;
                    "Ending Date" :=
                      LeadTimeMgt.PlannedEndingDate(ProdOrderLine."Item No.", ProdOrderLine."Location Code",
                        ProdOrderLine."Variant Code", "Due Date", '', 2);
                    if "Ending Time" = 0T then
                        SetNormalStartEndTime;
                    if ProdHours = 0 then begin
                        "Starting Date" := "Ending Date";
                        if ResetTime then
                            "Starting Time" := "Ending Time";
                    end else
                        P800CalMgt.CalculateProductionDateTime("Location Code", "Ending Date", "Ending Time", 1, ProdHours,
                          "Starting Date", "Starting Time", ProdDateTime);
                end;

            FieldNo("Ending Time"):
                begin
                    if "Ending Date" = 0D then
                        exit;
                    if "Ending Time" = 0T then
                        SetNormalStartEndTime;
                    if ProdHours = 0 then begin
                        if ResetTime then
                            "Starting Time" := "Ending Time";
                    end else
                        P800CalMgt.CalculateProductionDateTime("Location Code", "Ending Date", "Ending Time", 1, ProdHours,
                          "Starting Date", "Starting Time", ProdDateTime);
                end;

            FieldNo("Ending Date"):
                begin
                    if "Ending Date" = 0D then
                        exit;
                    if "Ending Time" = 0T then
                        SetNormalStartEndTime;
                    if ProdHours = 0 then begin
                        "Starting Date" := "Ending Date";
                        if ResetTime then
                            "Starting Time" := "Ending Time";
                    end else
                        P800CalMgt.CalculateProductionDateTime("Location Code", "Ending Date", "Ending Time", 1, ProdHours,
                          "Starting Date", "Starting Time", ProdDateTime);
                end;

            FieldNo("Starting Time"), FieldNo("Starting Date"):
                begin
                    if "Starting Date" = 0D then
                        exit;
                    if "Starting Time" = 0T then
                        SetNormalStartEndTime;
                    if ProdHours = 0 then begin
                        "Ending Date" := "Starting Date";
                        if ResetTime then
                            "Ending Time" := "Starting Time";
                    end else
                        P800CalMgt.CalculateProductionDateTime("Location Code", "Starting Date", "Starting Time", 0, ProdHours,
                          "Ending Date", "Ending Time", ProdDateTime);
                    "Due Date" :=
                      LeadTimeMgt.PlannedDueDate(ProdOrderLine."Item No.", ProdOrderLine."Location Code",
                        ProdOrderLine."Variant Code", "Ending Date", '', 2);
                end;
        end;
    end;

    procedure SetNormalStartEndTime()
    var
        Location: Record Location;
        MfgSetup: Record "Manufacturing Setup";
    begin
        if Location.Get("Location Code") then;
        MfgSetup.Get;

        if Location."Normal Starting Time" = 0T then
            "Starting Time" := MfgSetup."Normal Starting Time"
        else
            "Starting Time" := Location."Normal Starting Time";
        if Location."Normal Ending Time" = 0T then
            "Ending Time" := MfgSetup."Normal Ending Time"
        else
            "Ending Time" := Location."Normal Ending Time";
    end;

    procedure SetChanged()
    begin
        // P8000263A
        if CopyStr("No.", 1, 3) = '***' then begin
            Changed := true;
            exit;
        end;

        Changed :=
          Release or
          (Quantity = 0) or
          ("Location Code" <> "Orig. Location Code") or
          ("Equipment Code" <> "Orig. Equipment Code") or
          ("Sequence Code" <> "Orig. Sequence Code") or
          (Quantity <> "Orig. Quantity") or
          ("Due Date" <> "Orig. Due Date") or
          ("Starting Time" <> "Orig. Starting Time") or
          ("Starting Date" <> "Orig. Starting Date") or
          ("Ending Time" <> "Orig. Ending Time") or
          ("Ending Date" <> "Orig. Ending Date");
    end;

    procedure CommitChanges()
    var
        ProdOrder: Record "Production Order";
        ProdOrderStatusChange: Codeunit "Prod. Order Status Management";
        CreateProdOrderLines: Codeunit "Create Prod. Order Lines";
        CalculateProdOrder: Codeunit "Calculate Prod. Order";
        Reschedule: Boolean;
        Replan: Boolean;
    begin
        if CopyStr("No.", 1, 3) = '***' then begin
            if Quantity <> 0 then begin
                ProdOrder.Status := ProdOrder.Status::Released;
                ProdOrder.Insert(true);
                ProdOrder.Validate("Source Type", ProdOrder."Source Type"::Item);
                ProdOrder.Validate("Source No.", "Source No.");
                ProdOrder.Validate("Variant Code", "Variant Code");
                ProdOrder.Validate(Quantity, Quantity);
                ProdOrder.Validate("Location Code", "Location Code");
                ProdOrder.Validate("Equipment Code", "Equipment Code");
                ProdOrder.Validate("Production Sequence Code", "Sequence Code"); // P8000259A
                ProdOrder.Validate("Starting Date", "Starting Date");
                ProdOrder.Validate("Starting Time", "Starting Time");
                ProdOrder.Validate("Due Date", "Due Date");
                ProdOrder.Modify(true);
                CreateProdOrderLines.Copy(ProdOrder, 0, ProdOrder."Variant Code", true); // P8001301
            end;
        end else begin
            if Quantity = 0 then begin
                ProdOrder.Get(Status, "No.");
                ProdOrder.Delete(true);
            end else begin
                if Release then begin
                    ProdOrder.Get(Status, "No.");
                    ProdOrderStatusChange.ChangeStatusOnProdOrder(ProdOrder, ProdOrder.Status::Released, WorkDate, false);
                    ProdOrderStatusChange.GetNewProdOrder(ProdOrder);
                end;

                if "Location Code" <> "Orig. Location Code" then begin
                    if ProdOrder."No." = '' then
                        ProdOrder.Get(Status, "No.");
                    Reschedule := true;
                    ProdOrder."Location Code" := "Location Code";
                end;

                if "Equipment Code" <> "Orig. Equipment Code" then begin
                    if ProdOrder."No." = '' then
                        ProdOrder.Get(Status, "No.");
                    Replan := true;
                    Reschedule := true;
                    ProdOrder."Equipment Code" := "Equipment Code";
                    ProdOrder.Validate("Replenishment Area Code", ProdOrder.GetDefaultReplArea); // P8001279
                end;

                // P8000259A Begin
                if "Sequence Code" <> "Orig. Sequence Code" then begin
                    if ProdOrder."No." = '' then
                        ProdOrder.Get(Status, "No.");
                    ProdOrder.Validate("Production Sequence Code", "Sequence Code");
                    Reschedule := true;
                end;
                // P8000259A End

                if Quantity <> "Orig. Quantity" then begin
                    if ProdOrder."No." = '' then
                        ProdOrder.Get(Status, "No.");
                    Replan := true;
                    Reschedule := true;
                    ProdOrder.Validate(Quantity, Quantity);
                end;

                if ("Due Date" <> "Orig. Due Date") or
                  ("Starting Time" <> "Orig. Starting Time") or
                  ("Starting Date" <> "Orig. Starting Date") or
                  ("Ending Time" <> "Orig. Ending Time") or
                  ("Ending Date" <> "Orig. Ending Date")
                then begin
                    if ProdOrder."No." = '' then
                        ProdOrder.Get(Status, "No.");
                    Reschedule := true;
                    ProdOrder."Starting Time" := "Starting Time";
                    ProdOrder."Starting Date" := "Starting Date";
                end;

                if Replan then begin
                    ProdOrder.Modify;
                    CreateProdOrderLines.Copy(ProdOrder, 0, ProdOrder."Variant Code", true); // P8001301
                end;
                if Reschedule then begin
                    ProdOrder.Modify;
                    ProdOrder.Validate("Starting Date");
                    ProdOrder.Modify;
                end;
            end;
        end;
    end;

    procedure QtyChangeAllowed(): Boolean
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        CapLedgEntry: Record "Capacity Ledger Entry";
    begin
        if (Status = Status::"Firm Planned") or ("No." = '') or (CopyStr("No.", 1, 3) = '***') then
            exit(true);

        ItemLedgEntry.SetCurrentKey("Order Type", "Order No.");                       // P8001132
        ItemLedgEntry.SetRange("Order Type", ItemLedgEntry."Order Type"::Production); // P8001132
        ItemLedgEntry.SetRange("Order No.", "No.");                                   // P8001132
        if not ItemLedgEntry.IsEmpty then // P8001132
            exit(false);

        CapLedgEntry.SetCurrentKey("Order Type", "Order No.");                      // P8001132
        CapLedgEntry.SetRange("Order Type", CapLedgEntry."Order Type"::Production); // P8001132
        CapLedgEntry.SetRange("Order No.", "No.");                                  // P8001132
        if not CapLedgEntry.IsEmpty then // P8001132
            exit(false);

        exit(true);
    end;
}

