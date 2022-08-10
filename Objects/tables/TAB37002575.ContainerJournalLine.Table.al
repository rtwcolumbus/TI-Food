table 37002575 "Container Journal Line"
{
    // PR3.70.07
    // P8000140A, Myers Nissi, Jack Reynolds, 19 NOV 04
    //   Support for container journal and ledger
    // 
    // PR3.70.08
    // P8000163A, Myers Nissi, Jack Reynolds, 07 JAN 05
    //   Default customer dimensions when selecting container serial number on returns
    // 
    // PR3.70.09
    // P8000200A, Myers Nissi, Jack Reynolds, 02 MAR 05
    //   Allow posting serialized containers through the transfer orders
    // 
    // PR4.00.01
    // P8000267B, VerticalSoft, Jack Reynolds, 12 DEC 05
    //   Change dimension code processing to with respect to MODIFY to be in line with similar changes in the
    //     standard tables for SP1
    // 
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add "Bin Code" and related logic
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds 17 NOV 13
    //   Lookup of Shortcut Dimensions, Standardize OpenedFromBatch
    // 
    // PRW110.0.02
    // P80048075, To-Increase, Dayakar Battini, 31 OCT 17
    //   "External Document No." field length from Code20 to Code35
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
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 26 APR 22
    //   Upgrade to 20.0 - Refactoring for default dimensions

    Caption = 'Container Journal Line';

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Container Journal Template";
        }
        field(2; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Container Journal Batch".Name WHERE("Journal Template Name" = FIELD("Journal Template Name"));
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; "Container Item No."; Code[20])
        {
            Caption = 'Container Item No.';
            TableRelation = Item WHERE("Item Type" = CONST(Container));

            trigger OnValidate()
            begin
                GetContainerType; // P8001290
                Description := ContainerType.Description; // P8001290
                "Tare Weight" := ContainerType."Tare Weight"; // P8001290
                "Tare Unit of Measure" := ContainerType."Tare Unit of Measure"; // P8001290
                if "Entry Type" = "Entry Type"::Acquisition then
                    "Unit Amount" := ItemCont."Last Direct Cost";

                CreateDimFromDefaultDim(); // P800144605
            end;
        }
        field(5; "Container Serial No."; Code[50])
        {
            Caption = 'Container Serial No.';
            TableRelation = "Serial No. Information"."Serial No." WHERE("Item No." = FIELD("Container Item No."),
                                                                         "Variant Code" = FILTER(''));
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                if "Container Serial No." = '' then
                    exit;

                if "Entry Type" = "Entry Type"::Acquisition then begin
                    if SerialNo.Get("Container Item No.", '', "Container Serial No.") then
                        Error(Text000, FieldCaption("Container Serial No."), "Container Serial No.");
                end else begin
                    SerialNo.Get("Container Item No.", '', "Container Serial No.");
                    "Tare Weight" := SerialNo."Tare Weight";
                    "Tare Unit of Measure" := SerialNo."Tare Unit of Measure";
                    SerialNo.CalcFields("Container ID");
                    if ("Entry Type" in ["Entry Type"::Disposal, "Entry Type"::Transfer]) and (not "Transfer Order") then // P8000200A
                        SerialNo.TestField("Container ID", '');
                    "Container ID" := SerialNo."Container ID";
                    if (CurrFieldNo = FieldNo("Container Serial No.")) and ("Entry Type" = "Entry Type"::Return) then begin // P8001323
                        InvSetup.Get;
                        SerialNo.SetRange("Location Filter", InvSetup."Offsite Cont. Location Code");
                        SerialNo.CalcFields(Inventory);
                        if SerialNo.Inventory <> 1 then
                            FieldError("Container Serial No.", Text002);
                        Validate("Source Type", SerialNo.OffSiteSourceTypeInt); // P8001323
                        Validate("Source No.", SerialNo.OffSiteSourceNo); // P8000163A
                    end;
                end;
            end;
        }
        field(6; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'Acquisition,Use,Transfer,Ship,Return,Adjust Tare,Disposal';
            OptionMembers = Acquisition,Use,Transfer,Ship,Return,"Adjust Tare",Disposal;

            trigger OnValidate()
            begin
                case "Entry Type" of
                    "Entry Type"::Acquisition:
                        begin
                            "Container Serial No." := '';
                            "Container ID" := '';
                            "Source Type" := "Source Type"::Vendor;
                            "Source No." := '';
                            Quantity := 1;
                        end;
                    "Entry Type"::Transfer:
                        begin
                            "Container Serial No." := '';
                            "Container ID" := '';
                            "Location Code" := '';
                            "New Location Code" := '';
                            "Source Type" := "Source Type"::" ";
                            "Source No." := '';
                            Quantity := 1;
                        end;
                    "Entry Type"::Return:
                        begin
                            "Container Serial No." := '';
                            "Container ID" := '';
                            "Location Code" := '';
                            "Source Type" := "Source Type"::Customer;
                            "Source No." := '';
                            Quantity := 1;
                        end;
                    "Entry Type"::Disposal:
                        begin
                            "Container Serial No." := '';
                            "Container ID" := '';
                            "Location Code" := '';
                            "Source Type" := "Source Type"::" ";
                            "Source No." := '';
                            Quantity := 1;
                        end;
                end;
            end;
        }
        field(7; "Direct Posting"; Boolean)
        {
            Caption = 'Direct Posting';
            Editable = false;
        }
        field(8; "Register No."; Integer)
        {
            Caption = 'Register No.';
        }
        field(9; "Transfer Order"; Boolean)
        {
            Caption = 'Transfer Order';
        }
        field(11; "Posting Date"; Date)
        {
            Caption = 'Posting Date';

            trigger OnValidate()
            begin
                Validate("Document Date", "Posting Date");
            end;
        }
        field(12; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(13; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(14; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(15; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(16; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            Editable = false;
            TableRelation = "Source Code";
        }
        field(17; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(18; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code"); // P8001133
            end;
        }
        field(19; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code"); // P8001133
            end;
        }
        field(20; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;

            trigger OnValidate()
            begin
                InvSetup.Get;
                if "Location Code" = InvSetup."Offsite Cont. Location Code" then
                    FieldError("Location Code", StrSubstNo(Text003, InvSetup."Offsite Cont. Location Code"));
            end;
        }
        field(21; "New Location Code"; Code[10])
        {
            Caption = 'New Location Code';
            TableRelation = Location;

            trigger OnValidate()
            begin
                TestField("Entry Type", "Entry Type"::Transfer);
                InvSetup.Get;
                if "New Location Code" = InvSetup."Offsite Cont. Location Code" then
                    FieldError("New Location Code", StrSubstNo(Text003, InvSetup."Offsite Cont. Location Code"));
            end;
        }
        field(31; "Source Type"; Option)
        {
            Caption = 'Source Type';
            OptionCaption = ' ,Customer,Vendor';
            OptionMembers = " ",Customer,Vendor;
        }
        field(32; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            TableRelation = IF ("Source Type" = CONST(Customer)) Customer
            ELSE
            IF ("Source Type" = CONST(Vendor)) Vendor;

            trigger OnValidate()
            begin
                CreateDimFromDefaultDim(); // P800144605
            end;
        }
        field(33; "Container ID"; Code[20])
        {
            Caption = 'Container ID';
        }
        field(34; "Fill Item No."; Code[20])
        {
            Caption = 'Fill Item No.';
            TableRelation = Item;
        }
        field(35; "Fill Variant Code"; Code[10])
        {
            Caption = 'Fill Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Fill Item No."));
        }
        field(36; "Fill Lot No."; Code[50])
        {
            Caption = 'Fill Lot No.';
        }
        field(37; "Fill Serial No."; Code[50])
        {
            Caption = 'Fill Serial No.';
        }
        field(38; "Fill Quantity"; Decimal)
        {
            Caption = 'Fill Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(39; "Fill Quantity (Base)"; Decimal)
        {
            Caption = 'Fill Quantity (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(40; "Fill Quantity (Alt.)"; Decimal)
        {
            AutoFormatExpression = "Fill Item No.";
            AutoFormatType = 37002080;
            Caption = 'Fill Quantity (Alt.)';
        }
        field(41; "Fill Unit of Measure Code"; Code[10])
        {
            Caption = 'Fill Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Fill Item No."));
        }
        field(51; "Unit Amount"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Amount';

            trigger OnValidate()
            begin
                if not ("Entry Type" in ["Entry Type"::Acquisition, "Entry Type"::Disposal]) then
                    TestField("Unit Amount", 0);
            end;
        }
        field(52; Quantity; Integer)
        {
            Caption = 'Quantity';

            trigger OnValidate()
            begin
                if "Entry Type" = "Entry Type"::Use then
                    TestField(Quantity, 0)
                else
                    if ("Container Serial No." <> '') and (not (Quantity in [-1, 1])) then
                        FieldError(Quantity, Text001);
            end;
        }
        field(61; "Tare Weight"; Decimal)
        {
            Caption = 'Tare Weight';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                TestField("Entry Type", "Entry Type"::"Adjust Tare");
            end;
        }
        field(62; "Tare Unit of Measure"; Code[10])
        {
            Caption = 'Tare Unit of Measure';
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
                ShowDimensions;
            end;
        }
        field(37002100; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            Description = 'P8000631A';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));
        }
        field(37002101; "New Bin Code"; Code[20])
        {
            Caption = 'New Bin Code';
            Description = 'P8000631A';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("New Location Code"));

            trigger OnValidate()
            begin
                TestField("Entry Type", "Entry Type"::Transfer); // P8000631A
            end;
        }
    }

    keys
    {
        key(Key1; "Journal Template Name", "Journal Batch Name", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        LockTable;
        ContJnlTemplate.Get("Journal Template Name");
        ContJnlBatch.Get("Journal Template Name", "Journal Batch Name");
    end;

    var
        InvSetup: Record "Inventory Setup";
        ContJnlTemplate: Record "Container Journal Template";
        ContJnlBatch: Record "Container Journal Batch";
        ContJnlLine: Record "Container Journal Line";
        ItemCont: Record Item;
        ContainerType: Record "Container Type";
        SerialNo: Record "Serial No. Information";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DimMgt: Codeunit DimensionManagement;
        Text000: Label '%1 %2 already exists.';
        Text001: Label 'must be 1 or -1';
        Text002: Label 'is not off-site';
        Text003: Label 'may not be %1';

    procedure EmptyLine(): Boolean
    begin
        exit("Container Item No." = '');
    end;

    procedure SetUpNewLine(LastContJnlLine: Record "Container Journal Line")
    begin
        ContJnlTemplate.Get("Journal Template Name");
        ContJnlBatch.Get("Journal Template Name", "Journal Batch Name");
        ContJnlLine.SetRange("Journal Template Name", "Journal Template Name");
        ContJnlLine.SetRange("Journal Batch Name", "Journal Batch Name");
        if ContJnlLine.Find('-') then begin
            "Posting Date" := LastContJnlLine."Posting Date";
            "Document Date" := LastContJnlLine."Posting Date";
            "Document No." := LastContJnlLine."Document No.";
        end else begin
            "Posting Date" := WorkDate;
            "Document Date" := WorkDate;
            if ContJnlBatch."No. Series" <> '' then begin
                Clear(NoSeriesMgt);
                "Document No." := NoSeriesMgt.TryGetNextNo(ContJnlBatch."No. Series", "Posting Date");
            end;
        end;
        "Direct Posting" := true;
        Validate("Entry Type", LastContJnlLine."Entry Type");
        "Source Code" := ContJnlTemplate."Source Code";
        "Reason Code" := ContJnlBatch."Reason Code";
    end;

    procedure SourceTypeToTableID(Type: Integer): Integer
    begin
        case Type of
            "Source Type"::Customer:
                exit(DATABASE::Customer);
            "Source Type"::Vendor:
                exit(DATABASE::Vendor);
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
        DimMgt.AddDimSource(DefaultDimSource, Database::Item, Rec."Container Item No.");
        DimMgt.AddDimSource(DefaultDimSource, Rec.SourceTypeToTableID(Rec."Source Type"), Rec."Source No.");
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

    [Obsolete('Replaced by CreateDim(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])', 'FOOD-21')]
    procedure CreateDim(Type1: Integer; No1: Code[20]; Type2: Integer; No2: Code[20])
    var
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        TableID[1] := Type1;
        No[1] := No1;
        TableID[2] := Type2;
        No[2] := No2;
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        "Dimension Set ID" := DimMgt.GetDefaultDimID( // P8001133
          TableID, No, "Source Code",
          "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0); // P8001133
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

    procedure GetContainerType()
    begin
        // P8001290
        if ContainerType."Container Item No." <> "Container Item No." then begin
            ItemCont.Get("Container Item No.");
            ContainerType.SetRange("Container Item No.", "Container Item No.");
            ContainerType.FindFirst;
        end;
    end;

    procedure AssignSerialNo()
    var
        ItemTrackingCode: Record "Item Tracking Code";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        TestField("Entry Type", "Entry Type"::Acquisition);
        GetContainerType; // P8001290
        ItemTrackingCode.Get(ItemCont."Item Tracking Code");
        ItemTrackingCode.TestField("SN Specific Tracking");
        ItemCont.TestField("Serial Nos.");
        "Container Serial No." := NoSeriesMgt.GetNextNo(ItemCont."Serial Nos.", "Posting Date", true);
    end;

    procedure IsOpenedFromBatch(): Boolean
    var
        ContJournalBatch: Record "Container Journal Batch";
        TemplateFilter: Text;
        BatchFilter: Text;
    begin
        // P8004516
        BatchFilter := GetFilter("Journal Batch Name");
        if BatchFilter <> '' then begin
            TemplateFilter := GetFilter("Journal Template Name");
            if TemplateFilter <> '' then
                ContJournalBatch.SetFilter("Journal Template Name", TemplateFilter);
            ContJournalBatch.SetFilter(Name, BatchFilter);
            ContJournalBatch.FindFirst;
        end;

        exit((("Journal Batch Name" <> '') and ("Journal Template Name" = '')) or (BatchFilter <> ''));
    end;
}

