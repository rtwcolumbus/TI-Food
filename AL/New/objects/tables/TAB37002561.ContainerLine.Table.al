table 37002561 "Container Line"
{
    // PR3.70.07
    // P8000140A, Myers Nissi, Jack Reynolds, 19 NOV 04
    //   Add function to post usage changes to container ledger
    // 
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add "Bin Code" and related logic
    // 
    // PRW16.00.06
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW17.10
    // P8001246, Columbus IT, Jack Reynolds, 21 NOV 13
    //   Enlarge description fields to 50 characters
    // 
    // PRW19.00
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup obsolete container functionality
    // 
    // P8004516, To-Increase, Jack Reynolds, 17 MAR 16
    //   Incorporate modifications for NAV Anywhere processes
    // 
    // PRW19.00.01
    // P8007399, To-Increase, Jack Reynolds, 28 JUN 16
    //   Fix problem checking for available quantity when inserting/modifying line
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // P8008287, To-Increase, Dayakar Battini, 16 DEC 16
    //       Fix Bin Code lenght errors
    // 
    // PRW110.0.01
    // P8007012, To-Increase, Jack Reynolds, 22 MAR 03
    //   Container Management Process
    // 
    // P80041265, To-Increase, Dayakar Battini, 08 JUN 17
    //   Fix issue with source Line bin code filtering
    // 
    // PRW110.0.02
    // P80039780, To-Increase, Jack Reynolds, 01 DEC 17
    //   Warehouse Receiving process
    // 
    // P80046533, To-Increase, Jack Reynolds, 10 OCT 17
    //   Inbound containers and shipping containers
    // 
    // PRW111.00.01
    // P80056709, To-Increase, Jack Reynolds, 25 JUL 18
    //   Production Containers - assign container to production order
    // 
    // PRW111.00.02
    // P80067617, To Increase, Jack Reynolds, 20 NOV 18
    //   Fix problem checking for loose inventory
    // 
    // P80067398, To-Increase, Gangabhushan, 26 NOV 18
    //   Quantity (Alt.) in container line is mandatory for catch weight items.
    //   Quantity (Alt.) should be zero while changing the Quantity
    // 
    // P80067899, To-Increase, Gangabhushan, 28 DEC 18
    //   Item Availability calculation check on received container
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
    // PRW121.0
    // P800155629, To-Increase, Jack Reynolds, 03 NOV 22
    //   Add support for Mandatory Variant

    Caption = 'Container Line';
    DataCaptionFields = "Container ID";
    DrillDownPageID = "Container Lines";
    LookupPageID = "Container Lines";

    fields
    {
        field(1; "Container ID"; Code[20])
        {
            Caption = 'Container ID';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;

            trigger OnValidate()
            var
                ContainerLine: Record "Container Line";
                ContainerUsage: Record "Container Type Usage";
                ItemNo: Code[20];
            begin
                // P8001323
                if "Item No." <> xRec."Item No." then begin
                    GetContainerHeader;
                    ContainerHeader.CheckHeaderComplete(true);

                    GetItem;
                    Item.TestField(Blocked, false);

                    CheckLineAppliedToOrder;

                    ItemNo := "Item No.";
                    Init;
                    "Item No." := ItemNo;
                    Description := Item.Description;
                    "Description 2" := Item."Description 2";
                    if ContainerHeader."Document Type" = 0 then
                        "Unit of Measure Code" := Item."Base Unit of Measure";
                    Inbound := ContainerHeader.Inbound; // P8001324
                    "Location Code" := ContainerHeader."Location Code";
                    "Bin Code" := ContainerHeader."Bin Code";

                    if "Unit of Measure Code" <> '' then begin
                        if ContainerFns.GetContainerUsage(ContainerHeader."Container Type Code", Item."No.", Item."Item Category Code", // P8007749
                          "Unit of Measure Code", true, ContainerUsage)
                        then begin
                            "Single Lot" := ContainerUsage."Single Lot";
                            "Default Quantity" := ContainerUsage."Default Quantity";
                        end else begin
                            "Unit of Measure Code" := '';
                            if not ContainerFns.GetContainerUsage(ContainerHeader."Container Type Code", Item."No.", Item."Item Category Code", // P8007749
                              "Unit of Measure Code", false, ContainerUsage)
                            then
                                Error(Text002, "Item No.", ContainerHeader."License Plate"); // P8004516
                        end;
                    end;

                    if not ContainerHeader.MultipleItemsAllowed then begin
                        ContainerLine.SetCurrentKey("Item No.", "Variant Code", "Lot No.");
                        ContainerLine.SetRange("Container ID", "Container ID");
                        ContainerLine.SetFilter("Item No.", '<>%1', "Item No.");
                        ContainerLine.SetFilter("Line No.", '<>%1', "Line No.");
                        if not ContainerLine.IsEmpty then
                            Error(Text006, ContainerHeader."License Plate"); // P8004516
                    end;

                    CheckItemOnOrder(false, false);

                    ClearQty(true); // P8001342
                end;
            end;
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(5; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
        }
        field(6; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            begin
                // P8001323
                if "Variant Code" <> xRec."Variant Code" then begin
                    CheckLineAppliedToOrder;
                    "Lot No." := '';
                    if CurrFieldNo = FieldNo("Variant Code") then
                        CheckItemOnOrder(true, false);
                    ClearQty(true); // P8001342;
                end;
            end;
        }
        field(7; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            TableRelation = "Lot No. Information"."Lot No." WHERE("Item No." = FIELD("Item No."),
                                                                   "Variant Code" = FIELD("Variant Code"));
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                // P8001323
                if "Lot No." <> xRec."Lot No." then begin
                    GetContainerHeader;
                    CheckLineAppliedToOrder;
                    if not ContainerHeader.Inbound then begin
                        if "Lot No." <> '' then
                            LotInfo.Get("Item No.", "Variant Code", "Lot No.");
                        if not ContainerHeader.MultipleItemsAllowed then
                            CheckSingleLot;
                    end;
                    ClearQty(true); // P8001342;
                end;
            end;
        }
        field(8; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';

            trigger OnValidate()
            begin
                if "Serial No." <> xRec."Serial No." then begin
                    CheckLineAppliedToOrder;
                    ClearQty(true); // P8001342
                end;
            end;
        }
        field(9; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            var
                ContainerUsage: Record "Container Type Usage";
            begin
                // P8001323
                if "Unit of Measure Code" <> xRec."Unit of Measure Code" then begin
                    CheckLineAppliedToOrder;

                    TestField("Unit of Measure Code");

                    GetContainerHeader;
                    GetItem;
                    if not ContainerFns.GetContainerUsage(ContainerHeader."Container Type Code", Item."No.", Item."Item Category Code", // P8007749
                      "Unit of Measure Code", true, ContainerUsage)
                    then
                        Error(Text002, "Item No.", ContainerHeader."License Plate"); // P8004516

                    "Single Lot" := ContainerUsage."Single Lot";
                    "Default Quantity" := ContainerUsage."Default Quantity";

                    CheckSingleLot;

                    ItemUOM.Get("Item No.", "Unit of Measure Code");
                    "Qty. per Unit of Measure" := ItemUOM."Qty. per Unit of Measure";
                    UOMMgt.GetQtyRoundingPrecision(Item, "Unit of Measure Code", "Qty. Rounding Precision", "Qty. Rounding Precision (Base)"); // P800133109

                    if CurrFieldNo = FieldNo("Unit of Measure Code") then
                        CheckItemOnOrder(false, true);

                    ClearQty(true); // P8001342;
                end;
            end;
        }
        field(10; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            var
                LooseQty: Decimal;
                LooseQtyAlt: Decimal;
            begin
                if CurrFieldNo = FieldNo(Quantity) then begin
                    TestField("Item No.");
                    TestField("Unit of Measure Code");
                    GetItem;
                    if ItemTrackingCode."Lot Specific Tracking" then
                        TestField("Lot No.");

                    CheckItemOnOrder(true, true);

                    if Quantity < 0 then
                        FieldError(Quantity, Text001);
                end;

                // P8001342
                if Quantity = 0 then
                    ClearQty(false)
                else begin
                    Quantity := UOMMgt.RoundAndValidateQty(Quantity, "Qty. Rounding Precision", FieldCaption(Quantity)); // P800133109
                    // P8001342
                    Validate("Quantity (Base)", CalcBaseQty(Quantity, FieldCaption(Quantity), FieldCaption("Quantity (Base)"))); // PR3.70.02, P800133109
                    "Weight (Base)" := Round(P800UOMFns.ItemWeight("Item No.", "Quantity (Base)", "Quantity (Alt.)"), 0.000000001);
                    "Tare Weight (Base)" := Round(P800UOMFns.ItemTareWeight("Item No.", "Unit of Measure Code", Quantity), 0.000000001);
                end; // P8001342
            end;
        }
        field(11; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                // PR3.70.02 Begin
                GetItem;

                if "Quantity (Base)" = 0 then // P8001342
                    "Quantity (Alt.)" := 0      // P8001342
                // P80067398
                else
                    if Item."Alternate Unit of Measure" <> '' then
                        if Item."Catch Alternate Qtys." then
                            "Quantity (Alt.)" := 0
                        else
                            "Quantity (Alt.)" := Round("Quantity (Base)" * Item.AlternateQtyPerBase, 0.00001);
                // P80067398
                // PR3.70.02 End
            end;
        }
        field(12; "Quantity (Alt.)"; Decimal)
        {
            AutoFormatExpression = "Item No.";
            AutoFormatType = 37002080;
            Caption = 'Quantity (Alt.)';
            MinValue = 0;

            trigger OnValidate()
            begin
                if CurrFieldNo = FieldNo("Quantity (Alt.)") then begin // P80039780
                    TestField("Item No.");
                    GetItem;
                    Item.TestField("Catch Alternate Qtys.");
                    if ItemTrackingCode."Lot Specific Tracking" then
                        TestField("Lot No.");

                    AltQtyMgmt.CheckTolerance("Item No.", FieldCaption("Quantity (Alt.)"), "Quantity (Base)", "Quantity (Alt.)");
                end; // P80039780

                // P8001342
                if Quantity = 0 then
                    ClearQty(false)
                else
                    // P8001342
                    "Weight (Base)" := Round(P800UOMFns.ItemWeight("Item No.", "Quantity (Base)", "Quantity (Alt.)"), 0.000000001);
            end;
        }
        field(13; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
        }
        field(14; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            Editable = false;
        }
        // P800133109
        field(15; "Qty. Rounding Precision"; Decimal)
        {
            Caption = 'Qty. Rounding Precision';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        // P800133109
        field(61; "Qty. Rounding Precision (Base)"; Decimal)
        {
            Caption = 'Qty. Rounding Precision (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(17; "Container No."; Code[20])
        {
            Caption = 'Container No.';
            Editable = false;
        }
        field(18; "Weight (Base)"; Decimal)
        {
            Caption = 'Weight (Base)';
            DecimalPlaces = 0 : 9;
            Editable = false;
        }
        field(19; "Tare Weight (Base)"; Decimal)
        {
            Caption = 'Tare Weight (Base)';
            DecimalPlaces = 0 : 9;
            Editable = false;
        }
        field(20; "Single Lot"; Boolean)
        {
            Caption = 'Single Lot';
            Editable = false;
            InitValue = true;
        }
        field(21; "Default Quantity"; Decimal)
        {
            Caption = 'Default Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(30; Inbound; Boolean)
        {
            Caption = 'Inbound';
            Editable = false;
        }
        field(40; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
        }
        field(110; "Quantity Posted"; Decimal)
        {
            Caption = 'Quantity Posted';
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(111; "Quantity Posted (Base)"; Decimal)
        {
            Caption = 'Quantity Posted (Base)';
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(112; "Quantity Posted (Alt.)"; Decimal)
        {
            Caption = 'Quantity Posted (Alt.)';
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(37002100; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            Description = 'P8000631A';
            Editable = false;
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));
        }
    }

    keys
    {
        key(Key1; "Container ID", "Line No.")
        {
            SumIndexFields = "Quantity (Base)", "Weight (Base)", "Tare Weight (Base)";
        }
        key(Key2; "Item No.", "Variant Code", "Location Code", "Lot No.", "Serial No.")
        {
            SumIndexFields = Quantity, "Quantity (Base)", "Quantity (Alt.)";
        }
        key(Key3; "Item No.", "Variant Code", "Unit of Measure Code", "Lot No.", "Serial No.")
        {
        }
        key(Key4; "Item No.", "Variant Code", "Lot No.")
        {
        }
        key(Key5; "Item No.", "Variant Code", "Location Code", "Bin Code", "Lot No.", "Serial No.")
        {
            SumIndexFields = "Quantity (Base)", "Quantity (Alt.)";
        }
        key(Key6; "Item No.", "Variant Code", "Location Code", "Bin Code", "Unit of Measure Code", "Lot No.", "Serial No.")
        {
            SumIndexFields = Quantity, "Quantity (Base)", "Quantity (Alt.)";
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ContainerLine: Record "Container Line";
        ContainerLinePost: Record "Container Line";
    begin
        GetContainerHeader;                                                   // P8001324
        CheckInTransit;

        ContainerFns.AssignContainerLine(ContainerHeader, xRec, ContainerLine); // P8001324

        ContainerLinePost := xRec;                                           // P8001324
        ContainerLinePost.PostContainerUse(xRec.Quantity, xRec."Quantity (Alt.)", 0, 0); // P8001324

        if ContainerHeader.Inbound and (ContainerHeader."Document Type" = 0) then begin
            ContainerHeader.Inbound := false;
            if ContainerFns.IsOKToRemoveAssignment(ContainerHeader, "Line No.") then begin
                ContainerHeader.Modify;
            end;
        end;
    end;

    trigger OnInsert()
    var
        ContainerLine: Record "Container Line";
        ContainerLinePost: Record "Container Line";
    begin
        GetContainerHeader;
        CheckInTransit;

        if not ContainerHeader.Inbound then // P8001323
            CheckQuantityAvailable; // P8001342

        ContainerFns.AssignContainerLine(ContainerHeader, ContainerLine, Rec); // P8001324

        ContainerLinePost := Rec;                                           // P8001324
        ContainerLinePost.PostContainerUse(0, 0, Quantity, "Quantity (Alt.)"); // P8001324
    end;

    trigger OnModify()
    var
        ContainerLinePost: Record "Container Line";
    begin
        GetContainerHeader;                                         // P8001324
        CheckInTransit;

        if (not ContainerHeader.Inbound) or (ContainerHeader.Inbound and (ContainerHeader."Document Type" = 0)) then // P8001323 // P80067899
            CheckQuantityAvailable; // P8001342

        xRec.Get("Container ID", "Line No."); // P80039780
        ContainerFns.AssignContainerLine(ContainerHeader, xRec, Rec); // P8001324

        // P8001324
        if ((xRec."Item No." <> "Item No.") or (xRec."Variant Code" <> "Variant Code") or (xRec."Lot No." <> "Lot No.") or
            (xRec."Serial No." <> "Serial No.") or (xRec."Unit of Measure Code" <> "Unit of Measure Code")) and
           ((xRec.Quantity <> 0) or (xRec."Quantity (Alt.)" <> 0))
        then begin
            ContainerLinePost := xRec;
            ContainerLinePost.PostContainerUse(xRec.Quantity, xRec."Quantity (Alt.)", 0, 0);
            ContainerLinePost := Rec;
            ContainerLinePost.PostContainerUse(0, 0, Quantity, "Quantity (Alt.)");
        end else begin
            ContainerLinePost := Rec;
            ContainerLinePost.PostContainerUse(xRec.Quantity, xRec."Quantity (Alt.)", Quantity, "Quantity (Alt.)");
        end;
        // P8001324

        CheckAltQtyFill;  // P80067398
    end;

    var
        Item: Record Item;
        Text001: Label 'must be greater than zero.';
        ItemTrackingCode: Record "Item Tracking Code";
        ItemUOM: Record "Item Unit of Measure";
        LotInfo: Record "Lot No. Information";
        ContainerHeader: Record "Container Header";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
        PostContLine: Codeunit "Container Jnl.-Post Line";
        ContainerFns: Codeunit "Container Functions";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        UOMMgt: Codeunit "Unit of Measure Management";
        DisplayWeightUOM: Code[10];
        DisplayWeightFactor: Decimal;
        Text002: Label 'Item %1 is not allowed for container %2.';
        Text003: Label 'Item %1 cannot be combined with other items.';
        Text004: Label 'Item %1 cannot be combined with item %2.';
        Text005: Label 'Different lots for item %1 cannot be combined.';
        UsageDate: Date;
        UsageDocNo: Code[20];
        UsageSourceCode: Code[10];
        UsageExtDocNo: Code[20];
        Text006: Label 'Container %1 cannot have multiple items.';
        Text007: Label 'Quantity exceeds loose quantity available.';
        Text008: Label '%1 is not on %2 %3.';
        Text009: Label 'Line has already been applied to %1 %2.';
        Text010: Label 'Container is in-transit.';

    local procedure CalcBaseQty(Qty: Decimal; FromFieldName: Text; ToFieldName: Text): Decimal
    begin
        // P800133109
        exit(UOMMgt.CalcBaseQty(
            "Item No.", "Variant Code", "Unit of Measure Code", Qty, "Qty. per Unit of Measure", "Qty. Rounding Precision (Base)", FieldCaption("Qty. Rounding Precision"), FromFieldName, ToFieldName));
    end;

    procedure GetContainerHeader()
    begin
        // P8001323
        if "Container ID" <> ContainerHeader.ID then
            ContainerHeader.Get("Container ID");
    end;

    local procedure GetItem()
    begin
        TestField("Item No.");
        if "Item No." <> Item."No." then
            Item.Get("Item No.");
        // P8001323
        if Item."Item Tracking Code" <> ItemTrackingCode.Code then
            if Item."Item Tracking Code" = '' then
                ItemTrackingCode.Init
            else
                ItemTrackingCode.Get(Item."Item Tracking Code");
        // P8001323
    end;

    procedure CheckSingleLot()
    var
        ContainerLine: Record "Container Line";
        SingleLot: Boolean;
    begin
        // P8001323
        GetItem;
        if (ItemTrackingCode."Lot Specific Tracking") and ("Lot No." <> '') then begin
            SingleLot := "Single Lot";
            if not SingleLot then begin
                ContainerLine.SetRange("Container ID", "Container ID");
                ContainerLine.SetFilter("Line No.", '<>%1', "Line No.");
                ContainerLine.SetRange("Single Lot", true);
                SingleLot := not ContainerLine.IsEmpty;
            end;

            if SingleLot then begin
                ContainerLine.Reset;
                ContainerLine.SetCurrentKey("Item No.", "Variant Code", "Location Code", "Lot No.", "Serial No.");
                ContainerLine.SetRange("Container ID", "Container ID");
                ContainerLine.SetFilter("Line No.", '<>%1', "Line No.");
                ContainerLine.SetFilter("Variant Code", '<>%1', "Variant Code");
                if not ContainerLine.IsEmpty then
                    Error(Text005, "Item No.");
                ContainerLine.SetRange("Variant Code", "Variant Code");
                ContainerLine.SetFilter("Lot No.", '<>%1&<>%2', "Lot No.", '');
                if not ContainerLine.IsEmpty then
                    Error(Text005, "Item No.");
            end;
        end;
    end;

    local procedure ClearQty(SetDefault: Boolean)
    begin
        // P8001323
        Quantity := 0;
        "Quantity (Base)" := 0;
        "Quantity (Alt.)" := 0;
        "Weight (Base)" := 0;
        "Tare Weight (Base)" := 0;

        if SetDefault then // P8001342
            SetDefaultQty;
    end;

    procedure SetDefaultQty()
    var
        ContainerLine: Record "Container Line";
    begin
        // P8001323
        if "Default Quantity" <> 0 then begin
            if "Unit of Measure Code" = '' then
                exit;

            GetItem;
            if ItemTrackingCode."Lot Specific Tracking" and ("Lot No." = '') then
                exit;

            GetContainerHeader;
            if ContainerHeader."Document Type" <> 0 then
                exit;

            ContainerLine.SetRange("Container ID", "Container ID");
            ContainerLine.SetFilter("Line No.", '<>%1', "Line No.");
            if not ContainerLine.IsEmpty then
                exit;

            Validate(Quantity, "Default Quantity");
        end;
    end;

    local procedure CheckInTransit()
    begin
        GetContainerHeader;
        if (ContainerHeader."Document Type" = DATABASE::"Transfer Line") and (ContainerHeader."Document Subtype" = 1) then
            Error(Text010);
    end;

    procedure CheckLineAppliedToOrder()
    begin
        // P8001324
        if Quantity = 0 then
            exit;

        GetContainerHeader;
        if ContainerHeader."Document Type" <> 0 then
            Error(Text009, ContainerHeader.DocumentType, ContainerHeader."Document No.");
    end;

    local procedure CheckItemOnOrder(CheckVariant: Boolean; CheckUOM: Boolean)
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
        ProdOrderComponent: Record "Prod. Order Component";
        TransferToBin: Code[20];
        LineFound: Boolean;
    begin
        // P8001324
        // P8008287 - change BinCode to Code20
        GetContainerHeader;
        case ContainerHeader."Document Type" of
            DATABASE::"Sales Line":
                begin
                    SalesLine.SetRange("Document Type", ContainerHeader."Document Subtype");
                    SalesLine.SetRange("Document No.", ContainerHeader."Document No.");
                    SalesLine.SetRange(Type, SalesLine.Type::Item);
                    SalesLine.SetRange("No.", "Item No.");
                    SalesLine.SetRange("Location Code", ContainerHeader."Location Code");
                    //SalesLine.SETFILTER("Bin Code",'%1|%2','',ContainerHeader."Bin Code"); // P80046533
                    if CheckVariant then
                        SalesLine.SetRange("Variant Code", "Variant Code");
                    if CheckUOM then
                        SalesLine.SetRange("Unit of Measure Code", "Unit of Measure Code");
                    SalesLine.SetFilter(Quantity, '>0');
                    // P80046533
                    if SalesLine.FindSet then
                        repeat
                            LineFound := ContainerHeader."Bin Code" = SalesLine.GetWarehouseDocumentBin(ContainerHeader."Whse. Document No.");
                        until (SalesLine.Next = 0) or LineFound;
                    //IF NOT SalesLine.FINDFIRST THEN
                    if not LineFound then
                        // P80046533
                        Error(Text008, Item.TableCaption, ContainerHeader.DocumentType, ContainerHeader."Document No.");
                    if not CheckVariant then begin
                        SalesLine.SetFilter("Variant Code", '<>%1', SalesLine."Variant Code");
                        if SalesLine.IsEmpty then begin // P80056709
                            Validate("Variant Code", SalesLine."Variant Code");
                            SalesLine.SetRange("Variant Code", "Variant Code"); // P80056709
                        end; // P80056709
                    end;
                    if not CheckUOM then begin
                        SalesLine.SetFilter("Unit of Measure Code", '<>%1', SalesLine."Unit of Measure Code");
                        if SalesLine.IsEmpty then
                            Validate("Unit of Measure Code", SalesLine."Unit of Measure Code")
                        else
                            Validate("Unit of Measure Code", '');
                    end;
                end;
            DATABASE::"Purchase Line":
                begin
                    PurchLine.SetRange("Document Type", ContainerHeader."Document Subtype");
                    PurchLine.SetRange("Document No.", ContainerHeader."Document No.");
                    PurchLine.SetRange(Type, PurchLine.Type::Item);
                    PurchLine.SetRange("No.", "Item No.");
                    PurchLine.SetRange("Location Code", ContainerHeader."Location Code");
                    //PurchLine.SETFILTER("Bin Code",'%1|%2','',ContainerHeader."Bin Code");
                    if CheckVariant then
                        PurchLine.SetRange("Variant Code", "Variant Code");
                    if CheckUOM then
                        PurchLine.SetRange("Unit of Measure Code", "Unit of Measure Code");
                    PurchLine.SetFilter(Quantity, '>0');
                    // P80046533
                    if PurchLine.FindSet then
                        repeat
                            LineFound := ContainerHeader."Bin Code" = PurchLine.GetWarehouseDocumentBin(ContainerHeader."Whse. Document No.");
                        until (PurchLine.Next = 0) or LineFound;
                    //IF NOT PurchLine.FINDFIRST THEN
                    if not LineFound then
                        // P80046533
                        Error(Text008, Item.TableCaption, ContainerHeader.DocumentType, ContainerHeader."Document No.");
                    if not CheckVariant then begin
                        PurchLine.SetFilter("Variant Code", '<>%1', PurchLine."Variant Code");
                        if PurchLine.IsEmpty then begin // P80056709
                            Validate("Variant Code", PurchLine."Variant Code");
                            PurchLine.SetRange("Variant Code", "Variant Code"); // P80056709
                        end; // P80056709
                    end;
                    if not CheckUOM then begin
                        PurchLine.SetFilter("Unit of Measure Code", '<>%1', PurchLine."Unit of Measure Code");
                        if PurchLine.IsEmpty then
                            Validate("Unit of Measure Code", PurchLine."Unit of Measure Code")
                        else
                            Validate("Unit of Measure Code", '');
                    end;
                end;
            DATABASE::"Transfer Line":
                begin
                    TransLine.SetRange("Document No.", ContainerHeader."Document No.");
                    TransLine.SetRange(Type, TransLine.Type::Item);
                    TransLine.SetRange("Item No.", "Item No.");
                    TransLine.SetRange("Transfer-from Code", ContainerHeader."Location Code");
                    // P80046533
                    //TransLine.SETFILTER("Transfer-from Bin Code",'%1|%2','',ContainerHeader."Bin Code");
                    //IF ContainerHeader.GetTransferToBin(TransferToBin) THEN
                    //  TransLine.SETRANGE("Transfer-To Bin Code",TransferToBin);
                    // P80046533
                    if CheckVariant then
                        TransLine.SetRange("Variant Code", "Variant Code");
                    if CheckUOM then
                        TransLine.SetRange("Unit of Measure Code", "Unit of Measure Code");
                    TransLine.SetFilter(Quantity, '>0');
                    // P80046533
                    if TransLine.FindSet then
                        repeat
                            LineFound := ContainerHeader."Bin Code" = TransLine.GetWarehouseDocumentBin(0, ContainerHeader."Whse. Document No.");
                        until (TransLine.Next = 0) or LineFound;
                    //IF NOT TransLine.FINDFIRST THEN
                    if not LineFound then
                        // P80046533
                        Error(Text008, Item.TableCaption, ContainerHeader.DocumentType, ContainerHeader."Document No.");
                    if not CheckVariant then begin
                        TransLine.SetFilter("Variant Code", '<>%1', TransLine."Variant Code");
                        if TransLine.IsEmpty then begin // P80056709
                            Validate("Variant Code", TransLine."Variant Code");
                            TransLine.SetRange("Variant Code", "Variant Code"); // P80056709
                        end; // P80056709
                    end;
                    if not CheckUOM then begin
                        TransLine.SetFilter("Unit of Measure Code", '<>%1', TransLine."Unit of Measure Code");
                        if TransLine.IsEmpty then
                            Validate("Unit of Measure Code", TransLine."Unit of Measure Code")
                        else
                            Validate("Unit of Measure Code", '');
                    end;
                end;
            // P80056709
            DATABASE::"Prod. Order Component":
                begin
                    ProdOrderComponent.SetRange(Status, ContainerHeader."Document Subtype");
                    ProdOrderComponent.SetRange("Prod. Order No.", ContainerHeader."Document No.");
                    if ContainerHeader."Document Line No." <> 0 then
                        ProdOrderComponent.SetRange("Prod. Order Line No.", ContainerHeader."Document Line No.");
                    ProdOrderComponent.SetRange("Item No.", "Item No.");
                    if CheckVariant then
                        ProdOrderComponent.SetRange("Variant Code", "Variant Code");
                    if CheckUOM then
                        ProdOrderComponent.SetRange("Unit of Measure Code", "Unit of Measure Code");
                    ProdOrderComponent.SetFilter("Expected Quantity", '>0');
                    if not ProdOrderComponent.FindFirst then
                        Error(Text008, Item.TableCaption, ContainerHeader.DocumentType, ContainerHeader."Document No.");
                    if not CheckVariant then begin
                        ProdOrderComponent.SetFilter("Variant Code", '<>%1', ProdOrderComponent."Variant Code");
                        if ProdOrderComponent.IsEmpty then begin
                            Validate("Variant Code", ProdOrderComponent."Variant Code");
                            ProdOrderComponent.SetRange("Variant Code", "Variant Code");
                        end;
                    end;
                    if not CheckUOM then begin
                        ProdOrderComponent.SetFilter("Unit of Measure Code", '<>%1', ProdOrderComponent."Unit of Measure Code");
                        if ProdOrderComponent.IsEmpty then
                            Validate("Unit of Measure Code", ProdOrderComponent."Unit of Measure Code")
                        else
                            Validate("Unit of Measure Code", '');
                    end;
                end;
        // P80056709
        end;
    end;

    procedure DisplayWeight(BaseWeight: Decimal): Decimal
    begin
        if DisplayWeightUOM = '' then begin
            DisplayWeightUOM := P800UOMFns.DefaultUOM(2);
            DisplayWeightFactor := P800UOMFns.UOMtoMetricBase(DisplayWeightUOM);
        end;
        exit(BaseWeight / DisplayWeightFactor);
    end;

    procedure SetUsageParms(Date: Date; DocNo: Code[20]; ExtDocNo: Code[20]; SourceCode: Code[10])
    begin
        // P8000140A
        UsageDate := Date;
        UsageDocNo := DocNo;
        UsageExtDocNo := ExtDocNo;
        UsageSourceCode := SourceCode;
    end;

    procedure PostContainerUse(OriginalQty: Decimal; OriginalQtyAlt: Decimal; NewQty: Decimal; NewQtyAlt: Decimal)
    var
        InvSetup: Record "Inventory Setup";
        ContJnlLine: Record "Container Journal Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        // P8000140A
        if (OriginalQty = NewQty) and (OriginalQtyAlt = NewQtyAlt) then
            exit;

        ContainerHeader.Get("Container ID");
        if ContainerHeader."Container Serial No." = '' then
            exit;

        if UsageDate = 0D then begin // P8007012
            UsageDate := WorkDate;
            GetUsageDate(UsageDate);   // P8007012
        end;                         // P8007012
        if UsageDocNo = '' then begin
            InvSetup.Get;
            InvSetup.TestField("Container Usage Doc. Nos.");
            UsageDocNo := NoSeriesMgt.GetNextNo(InvSetup."Container Usage Doc. Nos.", UsageDate, true);
        end;

        ContJnlLine.Init;
        ContJnlLine.Validate("Posting Date", UsageDate);
        ContJnlLine.Validate("Document Date", UsageDate);
        ContJnlLine.Validate("Document No.", UsageDocNo);
        ContJnlLine.Validate("Entry Type", ContJnlLine."Entry Type"::Use);
        ContJnlLine.Validate("Container Item No.", ContainerHeader."Container Item No.");
        ContJnlLine.Validate("Container Serial No.", ContainerHeader."Container Serial No.");
        ContJnlLine.Validate("External Document No.", UsageExtDocNo);
        ContJnlLine.Validate("Source Code", UsageSourceCode);
        ContJnlLine.Validate("Location Code", ContainerHeader."Location Code");
        ContJnlLine.Validate("Bin Code", ContainerHeader."Bin Code"); // P8000631A
        ContJnlLine.Validate(Quantity, 0);
        ContJnlLine."Fill Item No." := "Item No.";
        ContJnlLine."Fill Variant Code" := "Variant Code";
        ContJnlLine."Fill Lot No." := "Lot No.";
        ContJnlLine."Fill Serial No." := "Serial No.";
        ContJnlLine."Fill Quantity" := NewQty - OriginalQty;
        ContJnlLine."Fill Quantity (Base)" := Round(ContJnlLine."Fill Quantity" * "Qty. per Unit of Measure", 0.00001);
        ContJnlLine."Fill Quantity (Alt.)" := NewQtyAlt - OriginalQtyAlt;
        ContJnlLine."Fill Unit of Measure Code" := "Unit of Measure Code";
        PostContLine.RunWithCheck(ContJnlLine); // P8001133
    end;

    procedure LotStatus(): Code[10]
    var
        LotInfo: Record "Lot No. Information";
    begin
        // P8001083
        if "Lot No." <> '' then begin
            if LotInfo.Get("Item No.", "Variant Code", "Lot No.") then
                exit(LotInfo."Lot Status Code");
        end;
    end;

    local procedure CheckQuantityAvailable()
    var
        xRec: Record "Container Line";
        LooseQty: Decimal;
        LooseQtyAlt: Decimal;
    begin
        // P8001342
        if xRec.Get("Container ID", "Line No.") then; // P8007399
        if ("Line No." = xRec."Line No.") and ("Item No." = xRec."Item No.") and ("Variant Code" = xRec."Variant Code") and ("Lot No." = xRec."Lot No.") and
            ("Serial No." = xRec."Serial No.") and ("Unit of Measure Code" = xRec."Unit of Measure Code") and
            (Quantity <= xRec.Quantity) and ("Quantity (Alt.)" <= xRec."Quantity (Alt.)")
        then
            exit;

        if (0 < Quantity) or (0 < "Quantity (Alt.)") then begin
            GetItem;
            if Item.PreventNegativeInventory or ("Bin Code" <> '') or ("Lot No." <> '') or ("Serial No." <> '') then begin
                ContainerFns.GetLooseQtyForContainerLine(Rec, LooseQty, LooseQtyAlt);
                if (LooseQty < Quantity) or (LooseQtyAlt < "Quantity (Alt.)") then
                    Error(Text007);
            end;
        end;
    end;

    procedure AssignLotNo()
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        LotNoData: Record "Lot No. Data";
    begin
        // P8001324
        GetContainerHeader;
        if not ContainerHeader.Inbound then
            exit;

        case ContainerHeader."Document Type" of
            DATABASE::"Sales Line":
                begin
                    SalesLine.SetRange("Document Type", ContainerHeader."Document Subtype");
                    SalesLine.SetRange("Document No.", ContainerHeader."Document No.");
                    SalesLine.SetRange(Type, SalesLine.Type::Item);
                    SalesLine.SetRange("No.", "Item No.");
                    SalesLine.SetRange("Variant Code", "Variant Code");
                    SalesLine.SetRange("Location Code", ContainerHeader."Location Code");
                    SalesLine.SetFilter("Bin Code", '%1|%2', '', ContainerHeader."Bin Code");  // P80041265
                    SalesLine.SetRange("Unit of Measure Code", "Unit of Measure Code");
                    SalesLine.FindFirst;
                    LotNoData.InitializeFromSourceRecord(SalesLine, false);
                end;
            DATABASE::"Purchase Line":
                begin
                    PurchLine.SetRange("Document Type", ContainerHeader."Document Subtype");
                    PurchLine.SetRange("Document No.", ContainerHeader."Document No.");
                    PurchLine.SetRange(Type, PurchLine.Type::Item);
                    PurchLine.SetRange("No.", "Item No.");
                    PurchLine.SetRange("Variant Code", "Variant Code");
                    PurchLine.SetRange("Location Code", ContainerHeader."Location Code");
                    PurchLine.SetFilter("Bin Code", '%1|%2', '', ContainerHeader."Bin Code");  // P80041265
                    PurchLine.SetRange("Unit of Measure Code", "Unit of Measure Code");
                    PurchLine.FindFirst;
                    LotNoData.InitializeFromSourceRecord(PurchLine, false);
                end;
        end;

        Validate("Lot No.", LotNoData.AssignLotNo);
    end;

    procedure LotNoAssistEdit()
    var
        LotInfo: Record "Lot No. Information";
    begin
        // P80039780
        if "Lot No." = '' then
            exit;

        LotInfo.FilterGroup(9);
        LotInfo.SetRange("Item No.", "Item No.");
        LotInfo.SetRange("Variant Code", "Variant Code");
        LotInfo.SetRange("Lot No.", "Lot No.");
        LotInfo.FilterGroup(0);
        if not LotInfo.FindFirst then begin
            LotInfo.Validate("Item No.", "Item No.");
            LotInfo.Validate("Variant Code", "Variant Code");
            LotInfo.Validate("Lot No.", "Lot No.");
            LotInfo.Insert;
        end;

        PAGE.Run(PAGE::"Lot No. Information Card", LotInfo);
    end;

    [BusinessEvent(false)]
    local procedure GetUsageDate(var UsageDate: Date)
    begin
        // P8007012
    end;

    local procedure CheckAltQtyFill()
    var
        Item: Record Item;
    begin
        // P80067398
        if (Quantity = 0) or ("Item No." = '') then
            exit;
        Item.Get("Item No.");
        if (Item."Catch Alternate Qtys.") and (Item."Alternate Unit of Measure" <> '') then
            if "Quantity (Alt.)" = 0 then
                TestField("Quantity (Alt.)");
    end;

    // P800155629
    procedure IsVariantMandatory(): Boolean
    var
        Item: Record Item;
    begin
        exit(Item.IsVariantMandatory(true, "Item No."));
    end;
}
