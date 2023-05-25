table 37002816 "Maintenance Journal Line"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 30 AUG 06
    //   Maintenance journal lines for labor, material, and contract
    // 
    // P8000335A, VerticalSoft, Jack Reynolds, 20 SEP 06
    //   Move functions to maintenance management codeunit
    // 
    // PR4.00.06
    // P8000469B, VerticalSoft, Jack Reynolds, 16 MAY 07
    //   Fix problems with correct rate for contractors
    // 
    // P8000471A, VerticalSoft, Jack Reynolds, 16 MAY 07
    //   Fix problems assigning document number
    // 
    // PRW15.00.01
    // P8000517A, VerticalSoft, Jack Reynolds, 13 SEP 07
    //   Get part number from spares list for non-stock items
    // 
    // PRW16.00.01
    // P8000712, VerticalSoft, Jack Reynolds, 06 AUG 09
    //   Fix problem with dimensions for stock material
    // 
    // P8000719, VerticalSoft, Jack Reynolds, 10 AUG 09
    //   Support for combined maintenance journal
    // 
    // PRW16.00.04
    // P8000897, VerticalSoft, Jack Reynolds, 22 JAN 11
    //   Fix spelling mistake
    // 
    // PRW16.00.06
    // P8001057, Columbus IT, Jack Reynolds, 12 APR 12
    //   Fix problem with missing source code
    // 
    // P8001115, Columbus IT, Jack Reynolds, 08 NOV 12
    //   Fix problem posting to work orders without asset assigned
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds 17 NOV 13
    //   Lookup of Shortcut Dimensions, Standardize OpenedFromBatch
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 26 APR 22
    //   Upgrade to 20.0 - Refactoring for default dimensions

    Caption = 'Maintenance Journal Line';
    DrillDownPageID = "Item Journal Lines";
    LookupPageID = "Item Journal Lines";

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Maintenance Journal Template";
        }
        field(2; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Maintenance Journal Batch".Name WHERE("Journal Template Name" = FIELD("Journal Template Name"));
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; "Work Order No."; Code[20])
        {
            Caption = 'Work Order No.';
            TableRelation = "Work Order";

            trigger OnValidate()
            begin
                MaintSetup.Get;

                if "Work Order No." = '' then begin
                    Description := '';
                    "Location Code" := '';
                    if MaintSetup."Doc. No. is Work Order No." then
                        "Document No." := '';
                end else
                    if "Work Order No." <> xRec."Work Order No." then begin
                        MaintMgt.CheckPostingGracePeriod("Work Order No."); // P8000355A
                        WorkOrder.Get("Work Order No.");
                        WorkOrder.TestField("Asset No."); // P8001115
                        Description := WorkOrder."Asset Description";
                        "Location Code" := WorkOrder."Location Code";
                        if MaintSetup."Doc. No. is Work Order No." then
                            "Document No." := "Work Order No.";
                    end;

                CreateDimFromDefaultDim(); // P800144605
            end;
        }
        field(5; "Posting Date"; Date)
        {
            Caption = 'Posting Date';

            trigger OnValidate()
            var
                CheckDateConflict: Codeunit "Reservation-Check Date Confl.";
            begin
                Validate("Document Date", "Posting Date");
            end;
        }
        field(6; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'Labor,Material-Stock,Material-Nonstock,Contract';
            OptionMembers = Labor,"Material-Stock","Material-Nonstock",Contract;

            trigger OnValidate()
            var
                TempJnlLine: Record "Maintenance Journal Line";
            begin
                // P8000719
                if "Entry Type" <> xRec."Entry Type" then begin
                    TempJnlLine := Rec;
                    Init;
                    Validate("Posting Date", TempJnlLine."Posting Date");
                    "Entry Type" := TempJnlLine."Entry Type";
                    Validate("Document No.", TempJnlLine."Document No.");
                    Validate("Work Order No.", TempJnlLine."Work Order No.");
                    Description := TempJnlLine.Description;
                    "Location Code" := TempJnlLine."Location Code";
                    "Document Date" := TempJnlLine."Document Date"; // P8001057
                    "Source Code" := TempJnlLine."Source Code";     // P8001057
                    "Reason Code" := TempJnlLine."Reason Code";     // P8001057
                end;
                // P8000719
            end;
        }
        field(7; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(8; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(9; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(10; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(11; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            Editable = false;
            TableRelation = "Source Code";
        }
        field(12; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(13; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(14; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(15; "Unit Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost';

            trigger OnValidate()
            begin
                GLSetup.Get;
                Amount := Round(Quantity * "Unit Cost", GLSetup."Amount Rounding Precision");
            end;
        }
        field(16; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            var
                SignIntFract: array[3] of Decimal;
            begin
                case "Entry Type" of
                    "Entry Type"::Labor, "Entry Type"::Contract:
                        begin
                            Fracture(Quantity, SignIntFract);
                            "Hours.Minutes" := SignIntFract[1] * (SignIntFract[2] + (Round(SignIntFract[3] * 60, 1) / 100));
                            if ("Entry Type" = "Entry Type"::Labor) and ("Starting Time" <> 0T) then
                                "Ending Time" := "Starting Time" + Quantity * 3600000;
                        end;
                end;

                GLSetup.Get;
                Amount := Round(Quantity * "Unit Cost", GLSetup."Amount Rounding Precision");

                if Quantity > 0 then
                    "Applies-to Entry" := 0;
            end;
        }
        field(17; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
            Editable = false;
        }
        field(18; "Applies-to Entry"; Integer)
        {
            Caption = 'Applies-to Entry';
            TableRelation = IF ("Entry Type" = FILTER(Labor | Contract)) "Maintenance Ledger"."Entry No." WHERE("Work Order No." = FIELD("Work Order No."),
                                                                                                             "Entry Type" = FIELD("Entry Type"),
                                                                                                             "Maintenance Trade Code" = FIELD("Maintenance Trade Code"),
                                                                                                             Quantity = FILTER(> 0))
            ELSE
            IF ("Entry Type" = FILTER("Material-Stock" | "Material-Nonstock")) "Maintenance Ledger"."Entry No." WHERE("Work Order No." = FIELD("Work Order No."),
                                                                                                                                                                                                                         "Entry Type" = FIELD("Entry Type"),
                                                                                                                                                                                                                         "Item No." = FIELD("Item No."),
                                                                                                                                                                                                                         Quantity = FILTER(> 0));
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                if ("Applies-to Entry" <> 0) and (Quantity > 0) then
                    FieldError(Quantity, Text003);

                MaintLedgerEntry.Get("Applies-to Entry");

                if MaintLedgerEntry.Quantity < 0 then
                    MaintLedgerEntry.FieldError(Quantity, Text004);
                Validate("Posting Date", MaintLedgerEntry."Posting Date");
                Validate("Entry Type", MaintLedgerEntry."Entry Type");
                Validate("Work Order No.", MaintLedgerEntry."Work Order No.");
                case "Entry Type" of
                    "Entry Type"::Labor:
                        begin
                            Validate("Maintenance Trade Code", MaintLedgerEntry."Maintenance Trade Code");
                            Validate("Employee No.", MaintLedgerEntry."Employee No.");
                        end;
                    "Entry Type"::"Material-Stock", "Entry Type"::"Material-Nonstock":
                        begin
                            Validate("Item No.", MaintLedgerEntry."Item No.");
                            Validate("Unit of Measure Code", MaintLedgerEntry."Unit of Measure Code");
                            Validate("Lot No.", MaintLedgerEntry."Lot No.");
                            Validate("Serial No.", MaintLedgerEntry."Serial No.");
                        end;
                    "Entry Type"::Contract:
                        begin
                            Validate("Vendor No.", MaintLedgerEntry."Vendor No.");
                        end;
                end;
                Validate("Unit Cost", MaintLedgerEntry."Unit Cost");
            end;
        }
        field(101; "Employee No."; Code[20])
        {
            Caption = 'Employee No.';
            TableRelation = Employee;

            trigger OnValidate()
            begin
                if ("Employee No." <> '') and ("Employee No." <> xRec."Employee No.") then begin
                    Employee.Get("Employee No.");
                    if Employee."Maintenance Trade Code" <> '' then
                        Validate("Maintenance Trade Code", Employee."Maintenance Trade Code");
                end;

                CreateDimFromDefaultDim(); // P800144605
            end;
        }
        field(102; "Maintenance Trade Code"; Code[10])
        {
            Caption = 'Maintenance Trade Code';
            TableRelation = "Maintenance Trade";

            trigger OnValidate()
            begin
                if ("Maintenance Trade Code" <> '') and ("Maintenance Trade Code" <> xRec."Maintenance Trade Code") then begin
                    MaintTrade.Get("Maintenance Trade Code");
                    case "Entry Type" of
                        "Entry Type"::Labor:
                            Validate("Unit Cost", MaintTrade."Internal Rate (Hourly)");
                        "Entry Type"::Contract:
                            if ("Vendor No." <> '') and VendorTrade.Get("Vendor No.", "Maintenance Trade Code") then
                                Validate("Unit Cost", VendorTrade."Rate (Hourly)")
                            else
                                Validate("Unit Cost", MaintTrade."External Rate (Hourly)"); // P8000469B
                    end;
                end;
            end;
        }
        field(103; "Hours.Minutes"; Decimal)
        {
            Caption = 'Hours.Minutes';
            DecimalPlaces = 2 : 2;

            trigger OnValidate()
            var
                SignIntFract: array[3] of Decimal;
            begin
                Fracture("Hours.Minutes", SignIntFract);
                SignIntFract[3] := Round(SignIntFract[3] * 100, 1, '<');
                if (SignIntFract[3] > 59) then
                    Error(Text001);
                Validate(Quantity, Round(SignIntFract[1] * (SignIntFract[2] + (SignIntFract[3] / 60)), 0.00001));
            end;
        }
        field(104; "Starting Time"; Time)
        {
            Caption = 'Starting Time';

            trigger OnValidate()
            begin
                if "Ending Time" < "Starting Time" then
                    "Ending Time" := "Starting Time";

                Validate(Quantity, CalcDurationInHrs("Starting Time", "Ending Time"));
            end;
        }
        field(105; "Ending Time"; Time)
        {
            Caption = 'Ending Time';

            trigger OnValidate()
            begin
                if "Ending Time" < "Starting Time" then
                    Error(Text002, FieldCaption("Ending Time"), FieldCaption("Starting Time"));

                Validate(Quantity, CalcDurationInHrs("Starting Time", "Ending Time"));
            end;
        }
        field(201; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;

            trigger OnValidate()
            begin
                if ("Vendor No." <> xRec."Vendor No.") and ("Maintenance Trade Code" <> '') then // P8000469B
                    if "Vendor No." <> '' then begin                                               // P8000469B
                        if VendorTrade.Get("Vendor No.", "Maintenance Trade Code") then
                            Validate("Unit Cost", VendorTrade."Rate (Hourly)");
                    end else begin                                                                 // P8000469B
                        MaintTrade.Get("Maintenance Trade Code");                                    // P8000469B
                        Validate("Unit Cost", MaintTrade."External Rate (Hourly)");                   // P8000469B
                    end;                                                                           // P8000469B

                CreateDimFromDefaultDim(); // P800144605
            end;
        }
        field(301; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = IF ("Entry Type" = CONST("Material-Stock")) Item;

            trigger OnValidate()
            var
                Asset: Record Asset;
                AssetSpare: Record "Asset Spare Part";
            begin
                case "Entry Type" of
                    "Entry Type"::"Material-Stock":
                        if "Item No." <> '' then begin
                            Item.Get("Item No.");
                            "Part No." := Item."Part No.";
                            Validate("Unit of Measure Code", Item."Base Unit of Measure");
                            Validate("Unit Cost", Item."Unit Cost");
                        end else begin
                            "Part No." := '';
                            "Unit of Measure Code" := '';
                            "Qty. per Unit of Measure" := 1;
                            "Unit Cost" := 0;
                            Validate(Quantity, 0);
                        end;

                    "Entry Type"::"Material-Nonstock":
                        begin
                            // P8000517A
                            if WorkOrder.Get("Work Order No.") then
                                Asset.Get(WorkOrder."Asset No.");
                            if Asset.GetSpare("Entry Type", "Item No.", AssetSpare) then
                                "Part No." := AssetSpare."Part No."
                            else
                                // P8000517A
                                "Part No." := "Item No.";
                            "Qty. per Unit of Measure" := 1;
                        end;
                end;

                CreateDimFromDefaultDim(); // P800144605
            end;
        }
        field(302; "Part No."; Code[20])
        {
            Caption = 'Part No.';

            trigger OnValidate()
            begin
                if ("Entry Type" = "Entry Type"::"Material-Nonstock") and ("Item No." = '') then
                    "Item No." := "Part No.";
            end;
        }
        field(303; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = IF ("Entry Type" = CONST("Material-Stock")) "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."))
            ELSE
            IF ("Entry Type" = CONST("Material-Nonstock")) "Unit of Measure";

            trigger OnValidate()
            begin
                case "Entry Type" of
                    "Entry Type"::"Material-Stock":
                        begin
                            GLSetup.Get;
                            ItemUOM.Get("Item No.", "Unit of Measure Code");
                            "Unit Cost" := "Unit Cost" / "Qty. per Unit of Measure";
                            "Qty. per Unit of Measure" := ItemUOM."Qty. per Unit of Measure";
                            Validate("Unit Cost", Round("Unit Cost" * "Qty. per Unit of Measure", GLSetup."Unit-Amount Rounding Precision"));
                        end;
                end;
            end;
        }
        field(304; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            InitValue = 1;
        }
        field(305; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
        }
        field(306; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
        }
        field(401; "Item Ledger Entry No."; Integer)
        {
            Caption = 'Item Ledger Entry No.';
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
        key(Key1; "Journal Template Name", "Journal Batch Name", "Line No.")
        {
            MaintainSIFTIndex = false;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        LockTable;
        MaintJnlTemplate.Get("Journal Template Name");
        MaintJnlBatch.Get("Journal Template Name", "Journal Batch Name");

        ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
        ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
    end;

    var
        GLSetup: Record "General Ledger Setup";
        MaintSetup: Record "Maintenance Setup";
        MaintJnlTemplate: Record "Maintenance Journal Template";
        MaintJnlBatch: Record "Maintenance Journal Batch";
        MaintJnlLine: Record "Maintenance Journal Line";
        WorkOrder: Record "Work Order";
        Employee: Record Employee;
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";
        MaintTrade: Record "Maintenance Trade";
        VendorTrade: Record "Vendor / Maintenance Trade";
        MaintLedgerEntry: Record "Maintenance Ledger";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DimMgt: Codeunit DimensionManagement;
        Text001: Label 'Entry must be in the form HH.MM, where HH is number of Hours and MM is number of Minutes.';
        Text002: Label '%1 cannot be before %2.';
        Text003: Label 'cannot be greater than zero';
        Text004: Label 'must be positive';
        Text005: Label '%1 has expired.';
        MaintMgt: Codeunit "Maintenance Management";

    procedure EmptyLine(): Boolean
    begin
        exit(("Work Order No." = '') and (Quantity = 0));
    end;

    procedure SetUpNewLine(LastMaintJnlLine: Record "Maintenance Journal Line")
    begin
        MaintSetup.Get; // P8000471A
        MaintJnlTemplate.Get("Journal Template Name");
        MaintJnlBatch.Get("Journal Template Name", "Journal Batch Name");
        MaintJnlLine.SetRange("Journal Template Name", "Journal Template Name");
        MaintJnlLine.SetRange("Journal Batch Name", "Journal Batch Name");
        if MaintJnlLine.FindFirst then begin
            "Posting Date" := LastMaintJnlLine."Posting Date";
            "Document Date" := LastMaintJnlLine."Posting Date";
            if not MaintSetup."Doc. No. is Work Order No." then // P8000471A
                "Document No." := LastMaintJnlLine."Document No.";
        end else begin
            "Posting Date" := WorkDate;
            "Document Date" := WorkDate;
            if not MaintSetup."Doc. No. is Work Order No." then // P8000471A
                if MaintJnlBatch."No. Series" <> '' then begin
                    Clear(NoSeriesMgt);
                    "Document No." := NoSeriesMgt.TryGetNextNo(MaintJnlBatch."No. Series", "Posting Date");
                end;
        end;
        "Entry Type" := LastMaintJnlLine."Entry Type";
        "Source Code" := MaintJnlTemplate."Source Code";
        "Reason Code" := MaintJnlBatch."Reason Code";
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
        case Rec."Entry Type" of
            Rec."Entry Type"::Labor:
                DimMgt.AddDimSource(DefaultDimSource, DATABASE::Employee, Rec."Employee No.");
            Rec."Entry Type"::"Material-Stock":
                DimMgt.AddDimSource(DefaultDimSource, DATABASE::Item, Rec."Item No.");
            Rec."Entry Type"::Contract:
                DimMgt.AddDimSource(DefaultDimSource, DATABASE::Vendor, Rec."Vendor No.");
        end;
    end;

    // P800144605
    procedure CreateDim(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    var
        SourceCodeSetup: Record "Source Code Setup";
        WorkOrder: Record "Work Order";
    begin
        SourceCodeSetup.Get;
        case "Entry Type" of
            Rec."Entry Type"::Labor:
                SourceCodeSetup."Work Order" := SourceCodeSetup."Maintenance Labor Journal";
            Rec."Entry Type"::"Material-Stock", Rec."Entry Type"::"Material-Nonstock":
                SourceCodeSetup."Work Order" := SourceCodeSetup."Maintenance Material Journal";
            Rec."Entry Type"::Contract:
                SourceCodeSetup."Work Order" := SourceCodeSetup."Maintenance Contract Journal";
        end;

        if WorkOrder.Get("Work Order No.") then;

        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        "Dimension Set ID" :=
          DimMgt.GetRecDefaultDimID(
            Rec, CurrFieldNo, DefaultDimSource, SourceCodeSetup."Work Order",
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", WorkOrder."Dimension Set ID", DATABASE::Asset);
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
        // P8001133
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet(
            "Dimension Set ID", StrSubstNo('%1 %2 %3', "Journal Template Name", "Journal Batch Name", "Line No."),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    procedure Fracture(NumbertoFracture: Decimal; var SignIntFract: array[3] of Decimal)
    begin
        // Converts number into Sign, IntegerPart, and FractionPart
        if NumbertoFracture >= 0 then
            SignIntFract[1] := 1.0
        else begin
            SignIntFract[1] := -1.0;
            NumbertoFracture := -NumbertoFracture;
        end;
        SignIntFract[2] := Round(NumbertoFracture, 1, '<');
        SignIntFract[3] := NumbertoFracture - SignIntFract[2];
    end;

    procedure CalcDurationInHrs(StartTime: Time; EndTime: Time): Decimal
    begin
        if (StartTime = 0T) or (EndTime = 0T) then
            exit;
        exit(Round((EndTime - StartTime) / 3600000, 0.00001));
    end;

    procedure LookupItem(var Text: Text[1024]): Boolean
    var
        WorkOrder: Record "Work Order";
        Asset: Record Asset;
    begin
        // P8000517A
        if WorkOrder.Get("Work Order No.") then
            Asset.Get(WorkOrder."Asset No.");
        exit(Asset.LookupItem("Entry Type", Text));
    end;

    procedure LotNoAssistEdit()
    var
        LotNoInfo: Record "Lot No. Information";
        LotInfo: Page "Lot No. Information Card";
    begin
        if "Lot No." <> '' then begin
            LotNoInfo.FilterGroup(9);
            LotNoInfo.SetRange("Item No.", "Item No.");
            LotNoInfo.SetRange("Variant Code", '');
            LotNoInfo.SetRange("Lot No.", "Lot No.");
            LotNoInfo.FilterGroup(0);
            LotInfo.SetTableView(LotNoInfo);
            LotInfo.RunModal;
        end;
    end;

    procedure LotNoLookup(var Text: Text[1024]): Boolean
    var
        LotNoInfo: Record "Lot No. Information";
        Lots: Page Lots;
    begin
        LotNoInfo.SetRange("Item No.", "Item No.");
        LotNoInfo.SetRange("Variant Code", '');
        LotNoInfo.SetRange("Location Filter", "Location Code");
        LotNoInfo.SetFilter(Inventory, '>0');

        Lots.LookupMode(true);
        Lots.SetTableView(LotNoInfo);
        if Lots.RunModal <> ACTION::LookupOK then
            exit(false);
        Lots.GetRecord(LotNoInfo);
        Text := LotNoInfo."Lot No.";
        exit(true);
    end;

    procedure SerialNoAssistEdit()
    var
        SerialNoInfo: Record "Serial No. Information";
        SerialInfo: Page "Serial No. Information Card";
    begin
        if "Serial No." <> '' then begin
            SerialNoInfo.FilterGroup(9);
            SerialNoInfo.SetRange("Item No.", "Item No.");
            SerialNoInfo.SetRange("Variant Code", '');
            SerialNoInfo.SetRange("Serial No.", "Serial No.");
            SerialNoInfo.FilterGroup(0);
            SerialInfo.SetTableView(SerialNoInfo);
            SerialInfo.RunModal;
        end;
    end;

    procedure SerialNoLookup(var Text: Text[1024]): Boolean
    var
        SerialNoInfo: Record "Serial No. Information";
        SerialNos: Page "Serial Nos.";
    begin
        SerialNoInfo.SetRange("Item No.", "Item No.");
        SerialNoInfo.SetRange("Variant Code", '');
        SerialNoInfo.SetRange("Location Filter", "Location Code");
        SerialNoInfo.SetFilter(Inventory, '>0');

        SerialNos.LookupMode(true);
        SerialNos.SetTableView(SerialNoInfo);
        if SerialNos.RunModal <> ACTION::LookupOK then
            exit(false);
        SerialNos.GetRecord(SerialNoInfo);
        Text := SerialNoInfo."Serial No.";
        exit(true);
    end;

    procedure IsOpenedFromBatch(): Boolean
    var
        MaintJournalBatch: Record "Maintenance Journal Batch";
        TemplateFilter: Text;
        BatchFilter: Text;
    begin
        // P8004516
        BatchFilter := GetFilter("Journal Batch Name");
        if BatchFilter <> '' then begin
            TemplateFilter := GetFilter("Journal Template Name");
            if TemplateFilter <> '' then
                MaintJournalBatch.SetFilter("Journal Template Name", TemplateFilter);
            MaintJournalBatch.SetFilter(Name, BatchFilter);
            MaintJournalBatch.FindFirst;
        end;

        exit((("Journal Batch Name" <> '') and ("Journal Template Name" = '')) or (BatchFilter <> ''));
    end;
}

