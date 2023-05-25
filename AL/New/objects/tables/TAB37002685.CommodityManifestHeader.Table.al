table 37002685 "Commodity Manifest Header"
{
    // PRW16.00.04
    // P8000891, VerticalSoft, Don Bresee, 04 JAN 11
    //   Add Commodity Receiving logic
    // 
    // PRW16.00.06
    // P8001034, Columbus IT, Jack Reynolds, 10 FEB 12
    //   Change codeunit for Warehouse Employee functions
    // 
    // PRW17.10
    // P8001234, Columbus IT, Jack Reynolds, 01 NOV 13
    //    Support for custom lot number formats
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW121.0
    // P800155629, To-Increase, Jack Reynolds, 03 NOV 22
    //   Add support for Mandatory Variant

    Caption = 'Commodity Manifest Header';
    DataCaptionFields = "No.", "Item No.";
    LookupPageID = "Commodity Manifest List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                InvtSetup.Get;
                if ("No." <> xRec."No.") then begin
                    NoSeriesMgt.TestManual(InvtSetup."Commodity Manifest Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location WHERE("Bin Mandatory" = CONST(true),
                                            "Require Put-away" = CONST(false),
                                            "Require Receive" = CONST(false));

            trigger OnValidate()
            begin
                if ("Location Code" <> xRec."Location Code") then begin
                    CheckAllLinesOpen(FieldCaption("Location Code"));
                    CheckAndDeleteDestBins(FieldCaption("Location Code"));
                    Validate("Bin Code", '');
                end;

                if ("Location Code" <> '') then begin
                    Location.Get("Location Code");
                    Validate("Bin Code", Location."Comm. Manifest Bin Code");
                    if (Location."Comm. Manifest Item No." <> '') then
                        Validate("Item No.", Location."Comm. Manifest Item No.");
                end;
            end;
        }
        field(3; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"),
                                            "Lot Combination Method" = CONST(Manual));
        }
        field(4; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item WHERE("Catch Alternate Qtys." = CONST(false),
                                        "Comm. Manifest UOM Code" = FILTER(<> ''));

            trigger OnValidate()
            begin
                if ("Item No." <> xRec."Item No.") then begin
                    CheckAllLinesOpen(FieldCaption("Item No."));
                    Validate("Variant Code", '');
                    Validate("Unit of Measure Code", '');
                end;

                if ("Item No." <> '') then begin
                    Item.Get("Item No.");
                    Item.TestField("Comm. Manifest UOM Code");
                    Validate("Unit of Measure Code", Item."Comm. Manifest UOM Code");
                end;
            end;
        }
        field(5; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(6; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
        }
        field(7; "Received Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Received Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                if ("Empty Scale Quantity" = 0) then
                    "Loaded Scale Quantity" := 0
                else
                    if ("Loaded Scale Quantity" = 0) then
                        "Empty Scale Quantity" := 0
                    else
                        "Loaded Scale Quantity" := "Empty Scale Quantity" + "Received Quantity";
            end;
        }
        field(8; "Loaded Scale Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Loaded Scale Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                if ("Empty Scale Quantity" > "Loaded Scale Quantity") then
                    "Empty Scale Quantity" := "Loaded Scale Quantity";
                if ("Loaded Scale Quantity" <> 0) and ("Empty Scale Quantity" <> 0) then
                    "Received Quantity" := "Loaded Scale Quantity" - "Empty Scale Quantity";
            end;
        }
        field(9; "Empty Scale Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Empty Scale Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                if ("Loaded Scale Quantity" < "Empty Scale Quantity") then
                    "Loaded Scale Quantity" := "Empty Scale Quantity";
                if ("Loaded Scale Quantity" <> 0) and ("Empty Scale Quantity" <> 0) then
                    "Received Quantity" := "Loaded Scale Quantity" - "Empty Scale Quantity";
            end;
        }
        field(10; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(11; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(12; "Receiving No."; Code[20])
        {
            Caption = 'Receiving No.';
        }
        field(13; "Receiving No. Series"; Code[20])
        {
            Caption = 'Receiving No. Series';
            TableRelation = "No. Series";

            trigger OnLookup()
            begin
                with CommManifestHeader do begin
                    CommManifestHeader := Rec;
                    InvtSetup.Get;
                    InvtSetup.TestField("Posted Comm. Manifest Nos.");
                    if NoSeriesMgt.LookupSeries(InvtSetup."Posted Comm. Manifest Nos.", "Receiving No. Series") then
                        Validate("Receiving No. Series");
                    Rec := CommManifestHeader;
                end;
            end;

            trigger OnValidate()
            begin
                if ("Receiving No. Series" <> '') then begin
                    InvtSetup.Get;
                    InvtSetup.TestField("Posted Comm. Manifest Nos.");
                    NoSeriesMgt.TestSeries(InvtSetup."Posted Comm. Manifest Nos.", "Receiving No. Series");
                end;
                TestField("Receiving No.", '');
            end;
        }
        field(15; "Manifest Quantity"; Decimal)
        {
            BlankZero = true;
            CalcFormula = Sum ("Commodity Manifest Line"."Manifest Quantity" WHERE("Commodity Manifest No." = FIELD("No.")));
            Caption = 'Manifest Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(16; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(17; "Hauler No."; Code[20])
        {
            Caption = 'Hauler No.';
            TableRelation = Vendor WHERE("Commodity Vendor Type" = CONST(Hauler));
        }
        field(18; "Product Rejected"; Boolean)
        {
            Caption = 'Product Rejected';

            trigger OnValidate()
            begin
                if "Product Rejected" then
                    CheckAndDeleteDestBins(FieldCaption("Product Rejected"))
                else begin
                    CommManifestLine.Reset;
                    CommManifestLine.SetRange("Commodity Manifest No.", "No.");
                    CommManifestLine.SetFilter("Rejection Action", '>0');
                    if CommManifestLine.FindFirst then
                        CommManifestLine.FieldError("Rejection Action");
                end;
            end;
        }
        field(19; "Broker No."; Code[20])
        {
            Caption = 'Broker No.';
            TableRelation = Vendor WHERE("Commodity Vendor Type" = CONST(Broker));

            trigger OnValidate()
            begin
                if ("Broker No." <> xRec."Broker No.") then
                    CheckAllLinesOpen(FieldCaption("Broker No."));
            end;
        }
        field(20; "Destination Bin Quantity"; Decimal)
        {
            BlankZero = true;
            CalcFormula = Sum ("Commodity Manifest Dest. Bin".Quantity WHERE("Commodity Manifest No." = FIELD("No.")));
            Caption = 'Destination Bin Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; "Location Code", "Bin Code", "Posting Date")
        {
        }
        key(Key3; "Item No.", "Posting Date")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        CommManifestLine.Reset;
        CommManifestLine.SetRange("Commodity Manifest No.", "No.");
        CommManifestLine.DeleteAll(true);

        CommManifestDestBin.Reset;
        CommManifestDestBin.SetRange("Commodity Manifest No.", "No.");
        CommManifestDestBin.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        InvtSetup.Get;
        if ("No." = '') then begin
            InvtSetup.TestField("Commodity Manifest Nos.");
            NoSeriesMgt.InitSeries(InvtSetup."Commodity Manifest Nos.", xRec."No. Series", "Posting Date", "No.", "No. Series");
        end;
        NoSeriesMgt.SetDefaultSeries("Receiving No. Series", InvtSetup."Posted Comm. Manifest Nos.");

        "Posting Date" := WorkDate;
        if ("Location Code" = '') then
            if Location.Get(P800CoreFns.GetDefaultEmpLocation()) then // P8001034
                if Location."Bin Mandatory" and
                   not (Location."Require Put-away" or Location."Require Receive")
                then
                    Validate("Location Code", Location.Code);
    end;

    trigger OnRename()
    begin
        Error(Text000, TableCaption);
    end;

    var
        InvtSetup: Record "Inventory Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        CommManifestHeader: Record "Commodity Manifest Header";
        CommManifestLine: Record "Commodity Manifest Line";
        CommManifestDestBin: Record "Commodity Manifest Dest. Bin";
        P800ItemTracking: Codeunit "Process 800 Item Tracking";
        P800CoreFns: Codeunit "Process 800 Core Functions";
        Item: Record Item;
        Location: Record Location;
        Text000: Label 'You cannot rename a %1.';
        Text001: Label 'You cannot change %1 with Destination Bins specified.';
        Text002: Label 'Do you want to assign a %1?';
        Text003: Label 'You cannot change %1 because linked Purchase Order Lines exist.';

    procedure AssistEditNo(OldCommManifestHeader: Record "Commodity Manifest Header"): Boolean
    begin
        InvtSetup.Get;
        with CommManifestHeader do begin
            CommManifestHeader := Rec;
            InvtSetup.TestField(InvtSetup."Commodity Manifest Nos.");
            if NoSeriesMgt.SelectSeries(
              InvtSetup."Commodity Manifest Nos.", OldCommManifestHeader."No. Series", "No. Series")
            then begin
                NoSeriesMgt.SetSeries("No.");
                Rec := CommManifestHeader;
                exit(true);
            end;
        end;
    end;

    procedure AssistEditLotNo(OldCommManifestHeader: Record "Commodity Manifest Header"): Boolean
    begin
        TestField("Item No.");
        if Confirm(Text002, false, FieldCaption("Lot No.")) then begin
            AssignLotNo;
            exit(true);
        end;
    end;

    procedure AssignLotNo()
    begin
        Item.Get("Item No.");
        if (Item."Comm. Manifest Lot Nos." <> '') then
            "Lot No." := NoSeriesMgt.GetNextNo(Item."Comm. Manifest Lot Nos.", "Posting Date", true)
        else
            "Lot No." := P800ItemTracking.AssignLotNo(Rec); // P8001234
    end;

    procedure GetBaseQty(Qty: Decimal): Decimal
    var
        ItemUOM: Record "Item Unit of Measure";
    begin
        ItemUOM.Get("Item No.", "Unit of Measure Code");
        exit(Round(Qty * ItemUOM."Qty. per Unit of Measure", 0.00001));
    end;

    local procedure CheckAndDeleteDestBins(FldCaption: Text[250])
    begin
        CommManifestDestBin.Reset;
        CommManifestDestBin.SetRange("Commodity Manifest No.", "No.");
        if not CommManifestDestBin.IsEmpty then
            Error(Text001, FldCaption);
    end;

    procedure GetAdjmtQty(): Decimal
    begin
        if ("Received Quantity" <> 0) then begin
            CalcFields("Manifest Quantity");
            if ("Manifest Quantity" <> 0) then
                exit("Received Quantity" - "Manifest Quantity");
        end;
    end;

    procedure CheckAllLinesOpen(FldCaption: Text[250])
    begin
        CommManifestLine.Reset;
        CommManifestLine.SetRange("Commodity Manifest No.", "No.");
        CommManifestLine.SetFilter("Purch. Order Status", '>%1', CommManifestLine."Purch. Order Status"::Open);
        if not CommManifestLine.IsEmpty then
            Error(Text003, FldCaption);
    end;

    // P800155629
    procedure IsVariantMandatory(): Boolean
    var
        Item: Record Item;
    begin
        exit(Item.IsVariantMandatory(true, "Item No."));
    end;
}
