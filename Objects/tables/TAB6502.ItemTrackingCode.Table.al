table 6502 "Item Tracking Code"
{
    // PR2.00
    //   Add field - Strict Quarantine Posting
    //   Lot Specific also sets Lot Info Must Exist fields
    //   TestRemoveSpecific checks for Item Tests
    // 
    // PR3.70.01
    //   Add field
    //     Allow Loose Lot Control
    // 
    // PR4.00
    // P8000250B, Myers Nissi, Jack Reynolds, 16 OCT 05
    //   Add field to allow specification of prefernece for automatic lot number assignement
    // 
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   P800 WMS Project
    // 
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 15 SEP 06
    //   Add Lot Warehouse Picking Method
    // 
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection

    Caption = 'Item Tracking Code';
    DataCaptionFields = "Code", Description;
    DrillDownPageID = "Item Tracking Codes";
    LookupPageID = "Item Tracking Codes";

    fields
    {
        field(37002020; "Strict Quarantine Posting"; Boolean)
        {
            Caption = 'Strict Quarantine Posting';
            Description = 'PR2.00';
        }
        field(37002021; "Allow Loose Lot Control"; Boolean)
        {
            Caption = 'Allow Loose Lot Control';
            Description = 'PR3.70.01';
        }
        field(37002022; "Lot Sales Inbound Assignment"; Boolean)
        {
            Caption = 'Lot Sales Inbound Assignment';
        }
        field(37002023; "Lot Purch. Inbound Assignment"; Boolean)
        {
            Caption = 'Lot Purch. Inbound Assignment';
        }
        field(37002024; "Lot Manuf. Inbound Assignment"; Boolean)
        {
            Caption = 'Lot Manuf. Inbound Assignment';
        }
        field(37002760; "Lot Warehouse Picking Method"; Option)
        {
            Caption = 'Lot Warehouse Picking Method';
            OptionCaption = 'None,FEFO,FIFO,LIFO';
            OptionMembers = "None",FEFO,FIFO,LIFO;

            trigger OnValidate()
            begin
                // P8000322A
                if ("Lot Warehouse Picking Method" > "Lot Warehouse Picking Method"::None) then
                    TestField("Lot Warehouse Tracking", true);
                // P8000322A
            end;
        }
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Warranty Date Formula"; DateFormula)
        {
            Caption = 'Warranty Date Formula';
        }
        field(5; "Man. Warranty Date Entry Reqd."; Boolean)
        {
            Caption = 'Man. Warranty Date Entry Reqd.';
        }
        field(6; "Man. Expir. Date Entry Reqd."; Boolean)
        {
            Caption = 'Man. Expir. Date Entry Reqd.';

            trigger OnValidate()
            begin
                if (not "Use Expiration Dates") and "Man. Expir. Date Entry Reqd." then
                    Validate("Use Expiration Dates", true);
            end;
        }
        field(8; "Strict Expiration Posting"; Boolean)
        {
            Caption = 'Strict Expiration Posting';

            trigger OnValidate()
            begin
                if (not "Use Expiration Dates") and "Strict Expiration Posting" then
                    Validate("Use Expiration Dates", true);
            end;
        }
        field(9; "Use Expiration Dates"; Boolean)
        {
            Caption = 'Use Expiration Dates';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Use Expiration Dates" then
                    exit;

                ValidateUseExpirationDates;
            end;
        }
        field(11; "SN Specific Tracking"; Boolean)
        {
            Caption = 'SN Specific Tracking';

            trigger OnValidate()
            begin
                if "SN Specific Tracking" = xRec."SN Specific Tracking" then
                    exit;

                if "SN Specific Tracking" then begin
                    TestSetSpecific(FieldCaption("SN Specific Tracking"));

                    "SN Purchase Inbound Tracking" := true;
                    "SN Purchase Outbound Tracking" := true;
                    "SN Sales Inbound Tracking" := true;
                    "SN Sales Outbound Tracking" := true;
                    "SN Pos. Adjmt. Inb. Tracking" := true;
                    "SN Pos. Adjmt. Outb. Tracking" := true;
                    "SN Neg. Adjmt. Inb. Tracking" := true;
                    "SN Neg. Adjmt. Outb. Tracking" := true;
                    "SN Transfer Tracking" := true;
                    "SN Manuf. Inbound Tracking" := true;
                    "SN Manuf. Outbound Tracking" := true;
                    "SN Assembly Inbound Tracking" := true;
                    "SN Assembly Outbound Tracking" := true;
                    "SN Warehouse Tracking" := true; // P8000282A
                end else begin
                    TestRemoveSpecificSN(FieldCaption("SN Specific Tracking"));
                    "SN Warehouse Tracking" := false;
                end;
            end;
        }
        field(13; "SN Info. Inbound Must Exist"; Boolean)
        {
            Caption = 'SN Info. Inbound Must Exist';
        }
        field(14; "SN Info. Outbound Must Exist"; Boolean)
        {
            Caption = 'SN Info. Outbound Must Exist';
        }
        field(15; "SN Warehouse Tracking"; Boolean)
        {
            AccessByPermission = TableData Location = R;
            Caption = 'SN Warehouse Tracking';

            trigger OnValidate()
            begin
                if "SN Warehouse Tracking" then begin
                    TestField("SN Specific Tracking", true);
                    TestSetSpecific(FieldCaption("SN Warehouse Tracking"));
                end else
                    TestRemoveSpecificSN(FieldCaption("SN Warehouse Tracking"));

                TestNoWhseEntriesExist(FieldCaption("SN Warehouse Tracking"));
            end;
        }
        field(21; "SN Purchase Inbound Tracking"; Boolean)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            Caption = 'SN Purchase Inbound Tracking';

            trigger OnValidate()
            begin
                TestField("SN Specific Tracking", false);
            end;
        }
        field(22; "SN Purchase Outbound Tracking"; Boolean)
        {
            AccessByPermission = TableData "Return Shipment Header" = R;
            Caption = 'SN Purchase Outbound Tracking';

            trigger OnValidate()
            begin
                TestField("SN Specific Tracking", false);
            end;
        }
        field(23; "SN Sales Inbound Tracking"; Boolean)
        {
            AccessByPermission = TableData "Return Receipt Header" = R;
            Caption = 'SN Sales Inbound Tracking';

            trigger OnValidate()
            begin
                TestField("SN Specific Tracking", false);
            end;
        }
        field(24; "SN Sales Outbound Tracking"; Boolean)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            Caption = 'SN Sales Outbound Tracking';

            trigger OnValidate()
            begin
                TestField("SN Specific Tracking", false);
            end;
        }
        field(25; "SN Pos. Adjmt. Inb. Tracking"; Boolean)
        {
            Caption = 'SN Pos. Adjmt. Inb. Tracking';

            trigger OnValidate()
            begin
                TestField("SN Specific Tracking", false);
            end;
        }
        field(26; "SN Pos. Adjmt. Outb. Tracking"; Boolean)
        {
            Caption = 'SN Pos. Adjmt. Outb. Tracking';

            trigger OnValidate()
            begin
                TestField("SN Specific Tracking", false);
            end;
        }
        field(27; "SN Neg. Adjmt. Inb. Tracking"; Boolean)
        {
            Caption = 'SN Neg. Adjmt. Inb. Tracking';

            trigger OnValidate()
            begin
                TestField("SN Specific Tracking", false);
            end;
        }
        field(28; "SN Neg. Adjmt. Outb. Tracking"; Boolean)
        {
            Caption = 'SN Neg. Adjmt. Outb. Tracking';

            trigger OnValidate()
            begin
                TestField("SN Specific Tracking", false);
            end;
        }
        field(29; "SN Transfer Tracking"; Boolean)
        {
            AccessByPermission = TableData Location = R;
            Caption = 'SN Transfer Tracking';

            trigger OnValidate()
            begin
                TestField("SN Specific Tracking", false);
            end;
        }
        field(30; "SN Manuf. Inbound Tracking"; Boolean)
        {
            AccessByPermission = TableData "Production Order" = R;
            Caption = 'SN Manuf. Inbound Tracking';

            trigger OnValidate()
            begin
                TestField("SN Specific Tracking", false);
            end;
        }
        field(31; "SN Manuf. Outbound Tracking"; Boolean)
        {
            AccessByPermission = TableData "Production Order" = R;
            Caption = 'SN Manuf. Outbound Tracking';

            trigger OnValidate()
            begin
                TestField("SN Specific Tracking", false);
            end;
        }
        field(32; "SN Assembly Inbound Tracking"; Boolean)
        {
            AccessByPermission = TableData "BOM Component" = R;
            Caption = 'SN Assembly Inbound Tracking';

            trigger OnValidate()
            begin
                TestField("SN Specific Tracking", false);
            end;
        }
        field(33; "SN Assembly Outbound Tracking"; Boolean)
        {
            AccessByPermission = TableData "BOM Component" = R;
            Caption = 'SN Assembly Outbound Tracking';

            trigger OnValidate()
            begin
                TestField("SN Specific Tracking", false);
            end;
        }
        field(34; "Create SN Info on Posting"; Boolean)
        {
            Caption = 'Create SN Info. on posting';
        }
        field(41; "Lot Specific Tracking"; Boolean)
        {
            Caption = 'Lot Specific Tracking';
            Description = 'PR2.00';

            trigger OnValidate()
            begin
                if "Lot Specific Tracking" = xRec."Lot Specific Tracking" then
                    exit;

                if "Lot Specific Tracking" then begin
                    TestSetSpecific(FieldCaption("Lot Specific Tracking"));

                    "Lot Purchase Inbound Tracking" := true;
                    "Lot Purchase Outbound Tracking" := true;
                    "Lot Sales Inbound Tracking" := true;
                    "Lot Sales Outbound Tracking" := true;
                    "Lot Pos. Adjmt. Inb. Tracking" := true;
                    "Lot Pos. Adjmt. Outb. Tracking" := true;
                    "Lot Neg. Adjmt. Inb. Tracking" := true;
                    "Lot Neg. Adjmt. Outb. Tracking" := true;
                    "Lot Transfer Tracking" := true;
                    "Lot Manuf. Inbound Tracking" := true;
                    "Lot Manuf. Outbound Tracking" := true;
                    "Lot Assembly Inbound Tracking" := true;
                    "Lot Assembly Outbound Tracking" := true;
                    "Lot Info. Inbound Must Exist" := true; // PR2.00
                    "Lot Info. Outbound Must Exist" := true; // PR2.00
                    "Lot Warehouse Tracking" := true; // P8000282A
                    "Lot Warehouse Picking Method" := "Lot Warehouse Picking Method"::None; // P8000322A
                    "Create Lot No. Info on posting" := true; // Upgrade18.0

                end else begin
                    TestRemoveSpecific(FieldCaption("Lot Specific Tracking"));
                    "Lot Warehouse Tracking" := false;
                end;
            end;
        }
        field(43; "Lot Info. Inbound Must Exist"; Boolean)
        {
            Caption = 'Lot Info. Inbound Must Exist';
        }
        field(44; "Lot Info. Outbound Must Exist"; Boolean)
        {
            Caption = 'Lot Info. Outbound Must Exist';
        }
        field(45; "Lot Warehouse Tracking"; Boolean)
        {
            Caption = 'Lot Warehouse Tracking';

            trigger OnValidate()
            begin
                if "Lot Warehouse Tracking" then begin
                    TestField("Lot Specific Tracking", true);
                    TestSetSpecific(FieldCaption("Lot Warehouse Tracking"));
                end else
                    TestRemoveSpecific(FieldCaption("Lot Warehouse Tracking"));

                TestNoWhseEntriesExist(FieldCaption("Lot Warehouse Tracking"));
            end;
        }
        field(51; "Lot Purchase Inbound Tracking"; Boolean)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            Caption = 'Lot Purchase Inbound Tracking';

            trigger OnValidate()
            begin
                TestField("Lot Specific Tracking", false);
            end;
        }
        field(52; "Lot Purchase Outbound Tracking"; Boolean)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            Caption = 'Lot Purchase Outbound Tracking';

            trigger OnValidate()
            begin
                TestField("Lot Specific Tracking", false);
            end;
        }
        field(53; "Lot Sales Inbound Tracking"; Boolean)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            Caption = 'Lot Sales Inbound Tracking';

            trigger OnValidate()
            begin
                TestField("Lot Specific Tracking", false);
            end;
        }
        field(54; "Lot Sales Outbound Tracking"; Boolean)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            Caption = 'Lot Sales Outbound Tracking';

            trigger OnValidate()
            begin
                TestField("Lot Specific Tracking", false);
            end;
        }
        field(55; "Lot Pos. Adjmt. Inb. Tracking"; Boolean)
        {
            Caption = 'Lot Pos. Adjmt. Inb. Tracking';

            trigger OnValidate()
            begin
                TestField("Lot Specific Tracking", false);
            end;
        }
        field(56; "Lot Pos. Adjmt. Outb. Tracking"; Boolean)
        {
            Caption = 'Lot Pos. Adjmt. Outb. Tracking';

            trigger OnValidate()
            begin
                TestField("Lot Specific Tracking", false);
            end;
        }
        field(57; "Lot Neg. Adjmt. Inb. Tracking"; Boolean)
        {
            Caption = 'Lot Neg. Adjmt. Inb. Tracking';

            trigger OnValidate()
            begin
                TestField("Lot Specific Tracking", false);
            end;
        }
        field(58; "Lot Neg. Adjmt. Outb. Tracking"; Boolean)
        {
            Caption = 'Lot Neg. Adjmt. Outb. Tracking';

            trigger OnValidate()
            begin
                TestField("Lot Specific Tracking", false);
            end;
        }
        field(59; "Lot Transfer Tracking"; Boolean)
        {
            Caption = 'Lot Transfer Tracking';

            trigger OnValidate()
            begin
                TestField("Lot Specific Tracking", false);
            end;
        }
        field(60; "Lot Manuf. Inbound Tracking"; Boolean)
        {
            AccessByPermission = TableData "Production Order" = R;
            Caption = 'Lot Manuf. Inbound Tracking';

            trigger OnValidate()
            begin
                TestField("Lot Specific Tracking", false);
            end;
        }
        field(61; "Lot Manuf. Outbound Tracking"; Boolean)
        {
            AccessByPermission = TableData "Production Order" = R;
            Caption = 'Lot Manuf. Outbound Tracking';

            trigger OnValidate()
            begin
                TestField("Lot Specific Tracking", false);
            end;
        }
        field(62; "Lot Assembly Inbound Tracking"; Boolean)
        {
            AccessByPermission = TableData "BOM Component" = R;
            Caption = 'Lot Assembly Inbound Tracking';

            trigger OnValidate()
            begin
                TestField("Lot Specific Tracking", false);
            end;
        }
        field(63; "Lot Assembly Outbound Tracking"; Boolean)
        {
            AccessByPermission = TableData "BOM Component" = R;
            Caption = 'Lot Assembly Outbound Tracking';

            trigger OnValidate()
            begin
                TestField("Lot Specific Tracking", false);
            end;
        }
        field(64; "Create Lot No. Info on posting"; Boolean)
        {
            Caption = 'Create Lot No. Info. on posting';

            // Upgrade18.0
            trigger OnValidate()
            begin
                TestField("Lot Specific Tracking", false);
            end;
        }
        field(70; "Package Specific Tracking"; Boolean)
        {
            Caption = 'Package Specific Tracking';
            CaptionClass = '6,70';

            trigger OnValidate()
            begin
                if "Package Specific Tracking" = xRec."Package Specific Tracking" then
                    exit;

                if "Package Specific Tracking" then begin
                    TestSetSpecific(FieldCaption("Package Specific Tracking"));

                    "Package Purchase Inb. Tracking" := true;
                    "Package Purch. Outb. Tracking" := true;
                    "Package Sales Inbound Tracking" := true;
                    "Package Sales Outb. Tracking" := true;
                    "Package Pos. Inb. Tracking" := true;
                    "Package Pos. Outb. Tracking" := true;
                    "Package Neg. Inb. Tracking" := true;
                    "Package Neg. Outb. Tracking" := true;
                    "Package Transfer Tracking" := true;
                    "Package Manuf. Inb. Tracking" := true;
                    "Package Manuf. Outb. Tracking" := true;
                    "Package Assembly Inb. Tracking" := true;
                    "Package Assembly Out. Tracking" := true;
                end else begin
                    TestRemoveSpecific(FieldCaption("Package Specific Tracking"));
                    "Package Warehouse Tracking" := false;
                end;
            end;
        }
        field(71; "Package Warehouse Tracking"; Boolean)
        {
            Caption = 'Package Warehouse Tracking';
            CaptionClass = '6,71';

            trigger OnValidate()
            begin
                if "Package Warehouse Tracking" then begin
                    TestField("Package Specific Tracking", true);
                    TestSetSpecific(FieldCaption("Package Warehouse Tracking"));
                end else
                    TestRemoveSpecific(FieldCaption("Package Warehouse Tracking"));

                TestNoWhseEntriesExist(FieldCaption("Package Warehouse Tracking"));
            end;
        }
        field(73; "Package Info. Inb. Must Exist"; Boolean)
        {
            Caption = 'Package Info. Inb. Must Exist';
            CaptionClass = '6,73';
        }
        field(74; "Package Info. Outb. Must Exist"; Boolean)
        {
            Caption = 'Lot Info. Outb. Must Exist';
            CaptionClass = '6,74';
        }
        field(75; "Package Purchase Inb. Tracking"; Boolean)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            Caption = 'Package Purchase Inb. Tracking';
            CaptionClass = '6,75';

            trigger OnValidate()
            begin
                TestField("Package Specific Tracking", false);
            end;
        }
        field(76; "Package Purch. Outb. Tracking"; Boolean)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            Caption = 'Package Purch. Outb. Tracking';
            CaptionClass = '6,76';

            trigger OnValidate()
            begin
                TestField("Package Specific Tracking", false);
            end;
        }
        field(77; "Package Sales Inbound Tracking"; Boolean)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            Caption = 'Package Sales Inbound Tracking';
            CaptionClass = '6,77';

            trigger OnValidate()
            begin
                TestField("Package Specific Tracking", false);
            end;
        }
        field(78; "Package Sales Outb. Tracking"; Boolean)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            Caption = 'Package Sales Outb. Tracking';
            CaptionClass = '6,78';

            trigger OnValidate()
            begin
                TestField("Package Specific Tracking", false);
            end;
        }
        field(79; "Package Pos. Inb. Tracking"; Boolean)
        {
            Caption = 'Package Pos. Inb. Tracking';
            CaptionClass = '6,79';

            trigger OnValidate()
            begin
                TestField("Package Specific Tracking", false);
            end;
        }
        field(80; "Package Pos. Outb. Tracking"; Boolean)
        {
            Caption = 'Package Pos. Outb. Tracking';
            CaptionClass = '6,80';

            trigger OnValidate()
            begin
                TestField("Package Specific Tracking", false);
            end;
        }
        field(81; "Package Neg. Inb. Tracking"; Boolean)
        {
            Caption = 'Package Neg. Inb. Tracking';
            CaptionClass = '6,81';

            trigger OnValidate()
            begin
                TestField("Package Specific Tracking", false);
            end;
        }
        field(82; "Package Neg. Outb. Tracking"; Boolean)
        {
            Caption = 'Package Neg. Outb. Tracking';
            CaptionClass = '6,82';

            trigger OnValidate()
            begin
                TestField("Package Specific Tracking", false);
            end;
        }
        field(83; "Package Transfer Tracking"; Boolean)
        {
            Caption = 'Package Transfer Tracking';
            CaptionClass = '6,83';

            trigger OnValidate()
            begin
                TestField("Package Specific Tracking", false);
            end;
        }
        field(84; "Package Manuf. Inb. Tracking"; Boolean)
        {
            AccessByPermission = TableData "Production Order" = R;
            Caption = 'Package Manuf. Inbound Tracking';
            CaptionClass = '6,84';

            trigger OnValidate()
            begin
                TestField("Package Specific Tracking", false);
            end;
        }
        field(85; "Package Manuf. Outb. Tracking"; Boolean)
        {
            AccessByPermission = TableData "Production Order" = R;
            Caption = 'Package Manuf. Outbound Tracking';
            CaptionClass = '6,85';

            trigger OnValidate()
            begin
                TestField("Package Specific Tracking", false);
            end;
        }
        field(86; "Package Assembly Inb. Tracking"; Boolean)
        {
            AccessByPermission = TableData "BOM Component" = R;
            Caption = 'Package Assembly Inbound Tracking';
            CaptionClass = '6,86';

            trigger OnValidate()
            begin
                TestField("Package Specific Tracking", false);
            end;
        }
        field(87; "Package Assembly Out. Tracking"; Boolean)
        {
            AccessByPermission = TableData "BOM Component" = R;
            Caption = 'Package Assembly Outbound Tracking';
            CaptionClass = '6,87';

            trigger OnValidate()
            begin
                TestField("Package Specific Tracking", false);
            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        TestDelete;
    end;

    var
        DataCollectionLine: Record "Data Collection Line";
        Item: Record Item;
        EntriesExistErr: Label 'Entries exist for item %1. The field %2 cannot be changed.';
        CostingMethodErr: Label 'Costing Method is %1 for item %2. The field %3 cannot be changed.', Comment = '%1 = Costing Method, %2 = Item No., %3 - field caption.';
        Text002: Label 'You cannot delete %1 %2 because it is used on one or more items.';
        IgnoreExpirationDateErr: Label 'You cannot stop using expiration dates because item ledger entries with expiration dates exist for item %1.', Comment = '%1 is the item number';
        ExpDateCalcSetOnItemsQst: Label 'You cannot stop using expiration dates because they are set up for %1 item(s). Do you want to see a list of these items, and decide whether to remove the expiration dates?', Comment = '%1 is the number of items';
        ExpDateCalcSetOnItemsErr: Label 'You cannot stop using expiration dates because they are set up for %1 item(s).', Comment = '%1 is the number of items';
        IgnoreButManExpirDateReqdErr: Label 'You cannot stop using expiration dates if you require manual expiration date entry on the item tracking code.';
        IgnoreButStrictExpirationPostingErr: Label 'You cannot stop using expiration dates if you require strict expiration posting on the item tracking code.';
        Text37002000: Label 'Quality Tests Exist for Item %1, The field %2 cannot be changed';
        WhseEntriesExistErr: Label 'You cannot change %1 because there are one or more warehouse entries for item %2.', Comment = '%1: Changed field name; %2: Item No.';

    local procedure EnsureNoExpirationDatesExistInRelatedItemLedgerEntries()
    var
        ItemsWithExpirationDate: Query "Items With Expiration Date";
    begin
        // find items using this tracking code
        ItemsWithExpirationDate.SetRange(Item_Tracking_Code, Code);

        // join with item ledger entries for these items that have an expiration date
        ItemsWithExpirationDate.SetFilter(Expiration_Date, '<>%1', 0D);
        if ItemsWithExpirationDate.Open then
            if ItemsWithExpirationDate.Read then // found some problematic data
                Error(IgnoreExpirationDateErr, ItemsWithExpirationDate.Item_No);
    end;

    local procedure EnsureRelatedItemsHaveNoExpirationDate()
    var
        EmptyDateFormula: DateFormula;
    begin
        Item.SetRange("Item Tracking Code", Code);
        Item.SetFilter("Expiration Calculation", '<>%1', EmptyDateFormula);
        if Item.FindSet() then begin
            if GuiAllowed then
                if Confirm(StrSubstNo(ExpDateCalcSetOnItemsQst, Item.Count)) then begin
                    PAGE.RunModal(PAGE::"Item List", Item);
                    Validate("Use Expiration Dates");
                    exit;
                end;

            Error(ExpDateCalcSetOnItemsErr, Item.Count);
        end;
    end;

    procedure TestSetSpecific(CurrentFieldName: Text[100])
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        Item.Reset();
        Item.SetRange("Item Tracking Code", Code);
        if Item.Find('-') then
            repeat
                ItemLedgEntry.SetRange("Item No.", Item."No.");
                if not ItemLedgEntry.IsEmpty() then
                    Error(EntriesExistErr, Item."No.", CurrentFieldName);
            until Item.Next() = 0;
    end;

    procedure TestRemoveSpecific(CurrentFieldName: Text)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        Item.Reset();
        Item.SetRange("Item Tracking Code", Code);
        if Item.Find('-') then
            repeat
                ItemLedgEntry.SetRange("Item No.", Item."No.");
                if not ItemLedgEntry.IsEmpty() then
                    Error(EntriesExistErr, Item."No.", CurrentFieldName);
            until Item.Next() = 0;
    end;

    local procedure TestRemoveSpecificSN(CurrentFieldName: Text)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        Item.Reset();
        Item.SetRange("Item Tracking Code", Code);
        if Item.Find('-') then
            repeat
                if Item."Costing Method" = Item."Costing Method"::Specific then
                    Error(CostingMethodErr, Item."Costing Method", Item."No.", CurrentFieldName);
                ItemLedgEntry.SetRange("Item No.", Item."No.");
                if not ItemLedgEntry.IsEmpty() then
                    Error(EntriesExistErr, Item."No.", CurrentFieldname);
                // PR2.00 begin
                if CurrentFieldname = FieldCaption("Lot Specific Tracking") then begin
                    // P8001090
                    //ItemTest.RESET;
                    //ItemTest.SETRANGE("Item No.",Item."No.");
                    DataCollectionLine.SetRange("Source ID", DATABASE::Item);
                    DataCollectionLine.SetRange("Source Key 1", Item."No.");
                    DataCollectionLine.SetRange(Type, DataCollectionLine.Type::"Q/C");
                    //IF ItemTest.FIND('-') THEN
                    if not DataCollectionLine.IsEmpty then
                        // P8001090
                        Error(
                  Text37002000,
                  Item."No.", CurrentFieldname);
                end;
                // PR2.00 End
            until Item.Next() = 0;
    end;

    local procedure TestDelete()
    begin
        Item.Reset();
        Item.SetRange("Item Tracking Code", Code);
        if not Item.IsEmpty() then
            Error(Text002, TableCaption, Code);
    end;

    local procedure ValidateUseExpirationDates()
    begin
        // 1. check if it is possible to ignore expiration dates
        EnsureNoExpirationDatesExistInRelatedItemLedgerEntries;

        // 2. Check for inconsistencies that may be fixed
        // a. Items with expiration calculation not empty, suggesting these items expire
        EnsureRelatedItemsHaveNoExpirationDate;

        // b. Manual expiration date entry is required, which implies items using this tracking code should expire
        if "Man. Expir. Date Entry Reqd." then
            Error(IgnoreButManExpirDateReqdErr);

        // c. Strict expiration posting, which implies expiration dates matter
        if "Strict Expiration Posting" then
            Error(IgnoreButStrictExpirationPostingErr);
    end;

    procedure IsSpecific() Specific: Boolean
    begin
        Specific := "SN Specific Tracking" or "Lot Specific Tracking";

        OnAfterIsSpecific(Rec, Specific);
    end;

    procedure IsSpecificTrackingChanged(ItemTrackingCode2: Record "Item Tracking Code") TrackingChanged: Boolean
    begin
        TrackingChanged :=
            ("SN Specific Tracking" <> ItemTrackingCode2."SN Specific Tracking") or
            ("Lot Specific Tracking" <> ItemTrackingCode2."Lot Specific Tracking");

        OnAfterIsSpecificTrackingChanged(Rec, ItemTrackingCode2, TrackingChanged);
    end;

    procedure IsWarehouseTracking() WarehouseTracking: Boolean
    begin
        WarehouseTracking := "SN Warehouse Tracking" or "Lot Warehouse Tracking";

        OnAfterIsWarehouseTracking(Rec, WarehouseTracking);
    end;

    procedure IsWarehouseTrackingChanged(ItemTrackingCode2: Record "Item Tracking Code") TrackingChanged: Boolean
    begin
        TrackingChanged :=
            ("SN Warehouse Tracking" <> ItemTrackingCode2."SN Warehouse Tracking") or
            ("Lot Warehouse Tracking" <> ItemTrackingCode2."Lot Warehouse Tracking");

        OnAfterIsWarehouseTrackingChanged(Rec, ItemTrackingCode2, TrackingChanged);
    end;

    local procedure TestNoWhseEntriesExist(CurrentFieldName: Text)
    var
        TrackedItem: Record Item;
        WarehouseEntry: Record "Warehouse Entry";
    begin
        TrackedItem.SetRange("Item Tracking Code", Code);
        if TrackedItem.FindSet() then
            repeat
                WarehouseEntry.SetRange("Item No.", TrackedItem."No.");
                if not WarehouseEntry.IsEmpty() then
                    Error(WhseEntriesExistErr, CurrentFieldName, TrackedItem."No.");
            until TrackedItem.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIsSpecific(ItemTrackingCode: Record "Item Tracking Code"; var Specific: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIsSpecificTrackingChanged(ItemTrackingCode: Record "Item Tracking Code"; ItemTrackingCode2: Record "Item Tracking Code"; var TrackingChanged: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIsWarehouseTracking(ItemTrackingCode: Record "Item Tracking Code"; var WarehouseTracking: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIsWarehouseTrackingChanged(ItemTrackingCode: Record "Item Tracking Code"; ItemTrackingCode2: Record "Item Tracking Code"; var TrackingChanged: Boolean)
    begin
    end;
}

