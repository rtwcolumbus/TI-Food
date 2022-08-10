table 7317 "Warehouse Receipt Line"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 22-10-2014, Initial Version
    // --------------------------------------------------------------------------------
    // 
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   P800 WMS project - alternate quantities; easy lot tracking
    // 
    // PR4.00.04
    // P8000372A, VerticalSoft, Phyllis McGovern, 25 SEP 06
    //   WH Overship and OverReceive
    //   Modified 'Qty. to Receive - OnValidate()' to allow over-receipt for Purchase Lines
    //   Added function 'ProcessOverReceipt', called from 'Qty. to Receive - OnValidate()'
    // 
    // P8000358A, VerticalSoft, Phyllis McGovern, 06 SEP 06
    //   Added field 'ADC Activity'
    //   Bypassed OverReceipt confirmation if ADC Activity
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 31 JUL 07
    //   Change call to UpdateLotTracking on sales line to pass ApplyFromEntryNo
    // 
    // PRW15.00.03
    // P8000629A, VerticalSoft, Jack Reynolds, 21 SEP 08
    //   Set lot number on source document line when calling item tracking for the line
    // 
    // PRW16.00.06
    // P8001106, Columbus IT, Don Bresee, 22 OCT 12
    //   Add logic for "Supplier Lot No." field for easy lot tracking on pages
    // 
    // PRW18.00.02
    // P8004505, To-Increase, Jack Reynolds, 23 OCT 15
    //   Problem with catch weight and lot controlled items when updating from warehouse shipment
    // 
    // PRW19.00.01
    // P8007108, To-Increase, Jack Reynolds, 31 MAY 16
    //   Allow entry of Creation Date and Coutry of Origin for lots
    // 
    // P8007477, To-Increase, Dayakar Battini, 25 JUL 16
    //   Qty. to Handle fields updation when assigning lot.
    // 
    // P8006916, To-Increase, Jack Reynolds, 31 AUG 16
    //   FOOD-TOM Separation
    // 
    // P8008014, To-Increase, Jack Reynolds, 17 NOV 16
    //   Problem with containers assigned to inbound transfers
    // 
    // PRW110.0.02
    // P80039780, To-Increase, Jack Reynolds, 01 DEC 17
    //   Warehouse Receiving process
    // 
    // P80046533, To-Increase, Jack Reynolds, 10 OCT 17
    //   Inbound containers and shipping containers
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 26 JUL 18
    //   Upgrade for NAV 2018 CU4 due to Microsoft changes
    // 
    // P80061239, To Increase, Jack Reynolds, 31 JUL 18
    //   Run Bin Status from warehouse document pages
    // 
    // PRW111.00.03
    // P80075420, To-Increase, Jack Reynolds, 08 JUL 19
    //   Problem losing tracking when using containers and specifying alt quantity to handle
    // 
    // P80077569, To-Increase, Gangabhushan, 17 JUL 19
    //   CS00069439 - Item tracking that is pre-defined in S.O. will now allow pick registration with qty. - Error
    // 
    // P80079197, To-Increase, Gangabhushan, 18 JUL 19
    //   TI-13290-Request for New Events
    // 
    // P800108868,P800108979, To-Increase, Gangabhushan, 20 OCT 20
    //   CS00129745 | Transfer Receiving Issue
    //   CS00130169 | Purchase Order Receiving - lot no must be specified  
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Warehouse Receipt Line';
    DrillDownPageID = "Whse. Receipt Lines";
    LookupPageID = "Whse. Receipt Lines";

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
        field(3; "Source Type"; Integer)
        {
            Caption = 'Source Type';
            Editable = false;
        }
        field(4; "Source Subtype"; Option)
        {
            Caption = 'Source Subtype';
            Editable = false;
            OptionCaption = '0,1,2,3,4,5,6,7,8,9,10';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9","10";
        }
        field(6; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            Editable = false;
        }
        field(7; "Source Line No."; Integer)
        {
            Caption = 'Source Line No.';
            Editable = false;
        }
        field(9; "Source Document"; Enum "Warehouse Activity Source Document")
        {
            Caption = 'Source Document';
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
            TableRelation = IF ("Zone Code" = FILTER('')) Bin.Code WHERE("Location Code" = FIELD("Location Code"))
            ELSE
            IF ("Zone Code" = FILTER(<> '')) Bin.Code WHERE("Location Code" = FIELD("Location Code"),
                                                                               "Zone Code" = FIELD("Zone Code"));

            trigger OnValidate()
            var
                Bin: Record Bin;
                WhseIntegrationMgt: Codeunit "Whse. Integration Management";
            begin
                if xRec."Bin Code" <> "Bin Code" then
                    if "Bin Code" <> '' then begin
                        GetItem;                                    // P8001290
                        Item.TestField("Non-Warehouse Item", false); // P8001290
                        GetLocation("Location Code");
                        WhseIntegrationMgt.CheckBinTypeCode(DATABASE::"Warehouse Receipt Line",
                          FieldCaption("Bin Code"),
                          "Location Code",
                          "Bin Code", 0);
                        if Location."Directed Put-away and Pick" then begin
                            Bin.Get("Location Code", "Bin Code");
                            "Zone Code" := Bin."Zone Code";
                            CheckBin(false);
                        end;
                    end;

                // P80046533
                if CurrFieldNo = FieldNo("Bin Code") then
                    CheckContainersExist;
                // P80046533
            end;
        }
        field(13; "Zone Code"; Code[10])
        {
            Caption = 'Zone Code';
            TableRelation = Zone.Code WHERE("Location Code" = FIELD("Location Code"));

            trigger OnValidate()
            begin
                if xRec."Zone Code" <> "Zone Code" then begin
                    if "Zone Code" <> '' then begin
                        GetItem;                                    // P8001290
                        Item.TestField("Non-Warehouse Item", false); // P8001290
                        GetLocation("Location Code");
                        Location.TestField("Directed Put-away and Pick");
                    end;
                    "Bin Code" := '';
                end;
            end;
        }
        field(14; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Editable = false;
            TableRelation = Item;
        }
        field(15; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;

            trigger OnValidate()
            begin
                Quantity := UOMMgt.RoundAndValidateQty(Quantity, "Qty. Rounding Precision", FieldCaption(Quantity));
                "Qty. (Base)" := CalcBaseQty(Quantity, FieldCaption(Quantity), FieldCaption("Qty. (Base)"));
                InitOutstandingQtys;
            end;
        }
        field(16; "Qty. (Base)"; Decimal)
        {
            Caption = 'Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(19; "Qty. Outstanding"; Decimal)
        {
            Caption = 'Qty. Outstanding';
            DecimalPlaces = 0 : 5;
            Editable = false;

            trigger OnValidate()
            begin
                "Qty. Outstanding" := UOMMgt.RoundAndValidateQty("Qty. Outstanding", "Qty. Rounding Precision", FieldCaption("Qty. Outstanding"));
                "Qty. Outstanding (Base)" := MaxQtyOutstandingBase(CalcBaseQty("Qty. Outstanding", FieldCaption("Qty. Outstanding"), FieldCaption("Qty. Outstanding (Base)")));
                InitQtyToReceive();
            end;
        }
        field(20; "Qty. Outstanding (Base)"; Decimal)
        {
            Caption = 'Qty. Outstanding (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(21; "Qty. to Receive"; Decimal)
        {
            Caption = 'Qty. to Receive';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            var
                WMSMgt: Codeunit "WMS Management";
                AdditionalQuantity: Decimal;
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateQtyToReceive(Rec, IsHandled, CurrFieldNo);
                if not OverReceiptProcessing() then
                    if not IsHandled then
                        if "Qty. to Receive" > "Qty. Outstanding" - GetContainerQuantity(false) then // P80046533
                            Error(Text002, "Qty. Outstanding" - GetContainerQuantity(false)); // P80046533

                if CurrFieldNo <> 0 then
                    TestContainerQuantity; // P8001323

                GetLocation("Location Code");
                if Location."Directed Put-away and Pick" then begin
                    WMSMgt.CalcCubageAndWeight(
                      "Item No.", "Unit of Measure Code", "Qty. to Receive", Cubage, Weight);

                    if (CurrFieldNo <> 0) and ("Qty. to Receive" > 0) then
                        CheckBin(true);
                end;

                "Qty. to Cross-Dock" := 0;
                "Qty. to Cross-Dock (Base)" := 0;
                "Qty. to Receive" := UOMMgt.RoundAndValidateQty("Qty. to Receive", "Qty. Rounding Precision", FieldCaption("Qty. to Receive"));
                "Qty. to Receive (Base)" := MaxQtyToReceiveBase(CalcBaseQty("Qty. to Receive", FieldCaption("Qty. to Receive"), FieldCaption("Qty. to Receive (Base)")));

                ValidateQuantityIsBalanced();

                Item.CheckSerialNoQty("Item No.", FieldCaption("Qty. to Receive (Base)"), "Qty. to Receive (Base)");
            end;
        }
        field(22; "Qty. to Receive (Base)"; Decimal)
        {
            Caption = 'Qty. to Receive (Base)';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateQtyToReceiveBase(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                TestField("Qty. per Unit of Measure", 1);
                Validate("Qty. to Receive", "Qty. to Receive (Base)");
            end;
        }
        field(23; "Qty. Received"; Decimal)
        {
            Caption = 'Qty. Received';
            DecimalPlaces = 0 : 5;
            Editable = false;

            trigger OnValidate()
            begin
                "Qty. Received" := UOMMgt.RoundAndValidateQty("Qty. Received", "Qty. Rounding Precision", FieldCaption("Qty. Received"));
                "Qty. Received (Base)" := CalcBaseQty("Qty. Received", FieldCaption("Qty. Received"), FieldCaption("Qty. Received (Base)"));
            end;
        }
        field(24; "Qty. Received (Base)"; Decimal)
        {
            Caption = 'Qty. Received (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(29; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            Editable = false;
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
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
            Editable = false;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(32; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(33; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            Editable = false;
        }
        field(34; Status; Option)
        {
            Caption = 'Status';
            Editable = false;
            OptionCaption = ' ,Partially Received,Completely Received';
            OptionMembers = " ","Partially Received","Completely Received";
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
        field(37; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
        }
        field(38; Cubage; Decimal)
        {
            Caption = 'Cubage';
            DecimalPlaces = 0 : 5;
        }
        field(39; Weight; Decimal)
        {
            Caption = 'Weight';
            DecimalPlaces = 0 : 5;
        }
        field(48; "Not upd. by Src. Doc. Post."; Boolean)
        {
            Caption = 'Not upd. by Src. Doc. Post.';
            Editable = false;
        }
        field(49; "Posting from Whse. Ref."; Integer)
        {
            Caption = 'Posting from Whse. Ref.';
            Editable = false;
        }
        field(50; "Qty. to Cross-Dock"; Decimal)
        {
            Caption = 'Qty. to Cross-Dock';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                CrossDockMgt.GetUseCrossDock(UseCrossDock, "Location Code", "Item No.");
                if not UseCrossDock then
                    Error(Text006, Item.TableCaption, Location.TableCaption);
                if "Qty. to Cross-Dock" > "Qty. to Receive" then
                    Error(
                      Text005,
                      "Qty. to Receive");

                "Qty. to Cross-Dock" := UOMMgt.RoundAndValidateQty("Qty. to Cross-Dock", "Qty. Rounding Precision", FieldCaption("Qty. to Cross-Dock"));
                "Qty. to Cross-Dock (Base)" := CalcBaseQty("Qty. to Cross-Dock", FieldCaption("Qty. to Cross-Dock"), FieldCaption("Qty. to Cross-Dock (Base)"));
            end;
        }
        field(51; "Qty. to Cross-Dock (Base)"; Decimal)
        {
            Caption = 'Qty. to Cross-Dock (Base)';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                TestField("Qty. per Unit of Measure", 1);
                Validate("Qty. to Cross-Dock", "Qty. to Cross-Dock (Base)");
            end;
        }
        field(52; "Cross-Dock Zone Code"; Code[10])
        {
            Caption = 'Cross-Dock Zone Code';
            TableRelation = Zone.Code WHERE("Location Code" = FIELD("Location Code"),
                                             "Cross-Dock Bin Zone" = CONST(true));
        }
        field(53; "Cross-Dock Bin Code"; Code[20])
        {
            Caption = 'Cross-Dock Bin Code';
            TableRelation = IF ("Cross-Dock Zone Code" = FILTER('')) Bin.Code WHERE("Location Code" = FIELD("Location Code"),
                                                                                   "Cross-Dock Bin" = CONST(true))
            ELSE
            IF ("Cross-Dock Zone Code" = FILTER(<> '')) Bin.Code WHERE("Location Code" = FIELD("Location Code"),
                                                                                                                                                 "Zone Code" = FIELD("Cross-Dock Zone Code"),
                                                                                                                                                 "Cross-Dock Bin" = CONST(true));
        }
        field(55; "Qty. Rounding Precision"; Decimal)
        {
            Caption = 'Qty. Rounding Precision';
            InitValue = 0;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 1;
            Editable = false;
        }
        field(56; "Qty. Rounding Precision (Base)"; Decimal)
        {
            Caption = 'Qty. Rounding Precision (Base)';
            InitValue = 0;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 1;
            Editable = false;
        }
        field(8509; "Over-Receipt Quantity"; Decimal)
        {
            Caption = 'Over-Receipt Quantity';
            DecimalPlaces = 0 : 5;
            BlankZero = false;
            MinValue = 0;

            trigger OnValidate()
            var
                PurchaseLine: Record "Purchase Line";
                OverReceiptMgt: Codeunit "Over-Receipt Mgt.";
                Handled: Boolean;
            begin
                OnValidateOverReceiptQuantity(Rec, xRec, CurrFieldNo, Handled);
                if Handled then
                    exit;
                if not OverReceiptMgt.IsOverReceiptAllowed() then begin
                    "Over-Receipt Quantity" := 0;
                    exit;
                end;
                TestField("Source Document", "Source Document"::"Purchase Order");
                if xRec."Over-Receipt Quantity" = "Over-Receipt Quantity" then
                    exit;
                if "Over-Receipt Quantity" <> 0 then begin
                    if "Over-Receipt Code" = '' then begin
                        PurchaseLine.Get("Source Subtype", "Source No.", "Source Line No.");
                        "Over-Receipt Code" := OverReceiptMgt.GetDefaultOverReceiptCode(PurchaseLine);
                    end;
                    TestField("Over-Receipt Code");
                end;
                Validate(Quantity, Quantity - xRec."Over-Receipt Quantity" + "Over-Receipt Quantity");
                Modify();
                OverReceiptMgt.UpdatePurchaseLineOverReceiptQuantityFromWarehouseReceiptLine(Rec);
            end;
        }
        field(8510; "Over-Receipt Code"; Code[20])
        {
            Caption = 'Over-Receipt Code';
            TableRelation = "Over-Receipt Code";

            trigger OnValidate()
            begin
                if ((Rec."Over-Receipt Code" = '') and (xRec."Over-Receipt Code" <> '')) then
                    Validate("Over-Receipt Quantity", 0);
            end;
        }
    }

    keys
    {
        key(Key1; "No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Source Type", "Source Subtype", "Source No.", "Source Line No.")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Qty. Outstanding (Base)";
        }
        key(Key3; "No.", "Source Type", "Source Subtype", "Source No.", "Source Line No.")
        {
            MaintainSQLIndex = false;
        }
        key(Key4; "No.", "Sorting Sequence No.")
        {
            MaintainSQLIndex = false;
        }
        key(Key5; "No.", "Shelf No.")
        {
            MaintainSQLIndex = false;
        }
        key(Key6; "No.", "Item No.")
        {
            MaintainSQLIndex = false;
        }
        key(Key7; "No.", "Source Document", "Source No.")
        {
            MaintainSQLIndex = false;
        }
        key(Key8; "No.", "Due Date")
        {
            MaintainSQLIndex = false;
        }
        key(Key9; "No.", "Bin Code")
        {
            MaintainSQLIndex = false;
        }
        key(Key10; "Item No.", "Location Code", "Variant Code")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Qty. Outstanding (Base)";
        }
        key(Key11; "Bin Code", "Location Code")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = Cubage, Weight;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        WhseRcptHeader: Record "Warehouse Receipt Header";
        OrderStatus: Option;
        SkipConfirm: Boolean;
    begin
        OnBeforeConfirmDelete(Rec, SkipConfirm);

        CheckContainersExist; // P8001323, P8008014
        if (Quantity <> "Qty. Outstanding") and ("Qty. Outstanding" <> 0) and not SkipConfirm then
            if not Confirm(Text004, false, TableCaption, "Line No.") then
                Error(Text003);

        WhseRcptHeader.Get("No.");
        OrderStatus := WhseRcptHeader.GetHeaderStatus("Line No.");
        if OrderStatus <> WhseRcptHeader."Document Status" then begin
            WhseRcptHeader.Validate("Document Status", OrderStatus);
            WhseRcptHeader.Modify();
        end;
    end;

    trigger OnRename()
    begin
        Error(Text001, TableCaption);
    end;

    var
        Location: Record Location;
        Item: Record Item;
        Bin: Record Bin;
        CrossDockMgt: Codeunit "Whse. Cross-Dock Management";
        UOMMgt: Codeunit "Unit of Measure Management";
        UseCrossDock: Boolean;
        Text001: Label 'You cannot rename a %1.';
        Text002: Label 'You cannot handle more than the outstanding %1 units.';
        Text003: Label 'Cancelled.';
        Text004: Label '%1 %2 is not completely received.\Do you really want to delete the %1?';
        Text005: Label 'You cannot Cross-Dock  more than the %1 units to be received.';
        Text006: Label 'Cross-Docking is disabled for this %1 and/or %2';
        IgnoreErrors: Boolean;
        ErrorOccured: Boolean;
        [Obsolete('Replaced by MS Over Receiving functionality', 'FOOD-21')]
        Text37000000: Label 'Confirm Over-receipt';
        Text37002700: Label 'One or more containers are associated with this receipt line.';
        Text37002701: Label 'cannot be less than quantity assigned through containers';
        ProcessFns: Codeunit "Process 800 Functions";
        ContainerFns: Codeunit "Container Functions";

    procedure InitNewLine(DocNo: Code[20])
    begin
        // P80096141 - Original signature
        InitNewLine(DocNo, false);
    end;

    procedure InitNewLine(DocNo: Code[20]; UserInteraction: Boolean)
    begin
        // P0053245 - add parameter UserInteraction
        Reset;
        "No." := DocNo;
        SetRange("No.", "No.");
        if not UserInteraction then //N138F0000.n, P80053245
            LockTable();
        if FindLast() then;

        Init;
        SetIgnoreErrors;
        "Line No." := "Line No." + 10000;
    end;

    local procedure CalcBaseQty(Qty: Decimal; FromFieldName: Text; ToFieldName: Text): Decimal
    begin
        TestField("Qty. per Unit of Measure");
        exit(UOMMgt.CalcBaseQty(
            "Item No.", "Variant Code", "Unit of Measure Code", Qty, "Qty. per Unit of Measure", "Qty. Rounding Precision (Base)", FieldCaption("Qty. Rounding Precision"), FromFieldName, ToFieldName));
    end;

    procedure AutofillQtyToReceive(var WhseReceiptLine: Record "Warehouse Receipt Line")
    var
        LotNo: Code[50];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeAutofillQtyToReceive(WhseReceiptLine, IsHandled);
        if IsHandled then
            exit;

        with WhseReceiptLine do begin
            if Find('-') then
                repeat
                    Validate("Qty. to Receive", "Qty. Outstanding" - GetContainerQuantity(false)); // P80046533
                    OnAutoFillQtyToReceiveOnBeforeModify(WhseReceiptLine);
                    Modify;
                    // P800108979
                    LotNo := GetLotNo;
                    ValidateLotNo(LotNo);
                // P800108979   
                until Next() = 0;
        end;
    end;

    procedure DeleteQtyToReceive(var WhseReceiptLine: Record "Warehouse Receipt Line")
    var
        IsHandled: Boolean;
        UpdateDocLine: Codeunit "Update Document Line";
        MinimumQuantity: Decimal;
    begin
        IsHandled := false;
        OnBeforeDeleteQtyToReceive(WhseReceiptLine, IsHandled);
        if IsHandled then
            exit;

        if WhseReceiptLine.FindSet() then
            repeat
                MinimumQuantity := WhseReceiptLine.GetContainerQuantity(true); // P80039780
                WhseReceiptLine.Validate("Qty. to Receive", MinimumQuantity); // P8001323, P80039780
                OnDeleteQtyToReceiveOnBeforeModify(WhseReceiptLine);
                WhseReceiptLine.Modify();
                UpdateDocLine.ClearQtyToHandle(WhseReceiptLine, 1); // P80039780
            until WhseReceiptLine.Next() = 0;
    end;

    local procedure GetItem()
    begin
        if Item."No." <> "Item No." then
            Item.Get("Item No.");
    end;

    procedure GetLineStatus(): Integer
    begin
        if "Qty. Outstanding" = 0 then
            Status := Status::"Completely Received"
        else
            if Quantity = "Qty. Outstanding" then
                Status := Status::" "
            else
                Status := Status::"Partially Received";

        exit(Status);
    end;

    local procedure GetLocation(LocationCode: Code[10])
    begin
        if LocationCode = '' then
            Location.GetLocationSetup(LocationCode, Location)
        else
            if Location.Code <> LocationCode then
                Location.Get(LocationCode);
    end;

    local procedure GetBin(LocationCode: Code[10]; BinCode: Code[20])
    begin
        GetLocation(LocationCode);
        if not Location."Bin Mandatory" then
            Clear(Bin)
        else
            if (Bin."Location Code" <> LocationCode) or
               (Bin.Code <> BinCode)
            then
                Bin.Get(LocationCode, BinCode);
    end;

    local procedure CheckBin(CalledFromQtytoReceive: Boolean)
    var
        BinContent: Record "Bin Content";
        DeductCubage: Decimal;
        DeductWeight: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckBin(Rec, IsHandled);
        if IsHandled then
            exit;

        if CalledFromQtytoReceive then begin
            DeductCubage := xRec.Cubage;
            DeductWeight := xRec.Weight;
        end;

        if BinContent.Get(
             "Location Code", "Bin Code",
             "Item No.", "Variant Code", "Unit of Measure Code")
        then begin
            if not BinContent.CheckIncreaseBinContent(
                 "Qty. to Receive", xRec."Qty. to Receive",
                 DeductCubage, DeductWeight, Cubage, Weight, false, IgnoreErrors)
            then
                ErrorOccured := true;
        end else begin
            GetBin("Location Code", "Bin Code");
            if not Bin.CheckIncreaseBin(
                 "Bin Code", "Item No.", "Qty. to Receive",
                 DeductCubage, DeductWeight, Cubage, Weight, false, IgnoreErrors)
            then
                ErrorOccured := true;
        end;
        OnCheckBinOnAfterCheckIncreaseBin(Rec, Bin, DeductCubage, DeductWeight, IgnoreErrors, ErrorOccured);
        if ErrorOccured then
            "Bin Code" := '';
    end;

    procedure OpenItemTrackingLines()
    var
        PurchaseLine: Record "Purchase Line";
        SalesLine: Record "Sales Line";
        TransferLine: Record "Transfer Line";
        PurchLineReserve: Codeunit "Purch. Line-Reserve";
        SalesLineReserve: Codeunit "Sales Line-Reserve";
        TransferLineReserve: Codeunit "Transfer Line-Reserve";
        SecondSourceQtyArray: array[3] of Decimal;
        Direction: Enum "Transfer Direction";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOpenItemTrackingLines(Rec, IsHandled, CurrFieldNo);
        if IsHandled then
            exit;

        TestField("No.");
        TestField("Qty. (Base)");

        GetItem;
        Item.TestField("Item Tracking Code");

        SecondSourceQtyArray[1] := DATABASE::"Warehouse Receipt Line";
        SecondSourceQtyArray[2] := "Qty. to Receive (Base)";
        SecondSourceQtyArray[3] := 0;

        case "Source Type" of
            DATABASE::"Purchase Line":
                begin
                    if PurchaseLine.Get("Source Subtype", "Source No.", "Source Line No.") then begin // P8000629A
                        PurchLineReserve.CallItemTracking(PurchaseLine, SecondSourceQtyArray);
                        // P8000629A
                        PurchaseLine.GetLotNo;
                        PurchaseLine.Modify;
                    end;
                    // P8000629A
                end;
            DATABASE::"Sales Line":
                begin
                    if SalesLine.Get("Source Subtype", "Source No.", "Source Line No.") then begin // P8000629A
                        SalesLineReserve.CallItemTracking(SalesLine, SecondSourceQtyArray);
                        // P8000629A
                        SalesLine.GetLotNo;
                        SalesLine.Modify;
                    end;
                    // P8000629A
                end;
            DATABASE::"Transfer Line":
                begin
                    Direction := Direction::Inbound;
                    if TransferLine.Get("Source No.", "Source Line No.") then
                        TransferLineReserve.CallItemTracking(TransferLine, Direction, SecondSourceQtyArray);
                end
        end;

        OnAfterOpenItemTrackingLines(Rec, SecondSourceQtyArray);
    end;

    procedure SetIgnoreErrors()
    begin
        IgnoreErrors := true;
    end;

    procedure HasErrorOccured(): Boolean
    begin
        exit(ErrorOccured);
    end;

    procedure InitOutstandingQtys()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitOutstandingQtys(Rec, CurrFieldNo, IsHandled);
        if IsHandled then
            exit;

        Validate("Qty. Outstanding", Quantity - "Qty. Received");
    end;

    procedure WhseActLineWrapper(var WshActivityLine: Record "Warehouse Activity Line")
    begin
        //N138F0000.sn
        WshActivityLine."Location Code" := "Location Code";
        WshActivityLine."Source Type" := "Source Type";
        WshActivityLine."Source Subtype" := "Source Subtype";
        WshActivityLine."Source No." := "Source No.";
        WshActivityLine."Source Line No." := "Source Line No.";
        WshActivityLine."Qty. to Handle" := "Qty. to Receive";
        WshActivityLine."Item No." := "Item No.";
        //N138F0000.en
    end;

    procedure TrackAlternateUnits(): Boolean
    begin
        // P8000282A
        GetItem;
        exit(Item.TrackAlternateUnits());
    end;

    procedure GetLotNo(): Code[50]
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
    begin
        // P8000282A
        case "Source Type" of
            DATABASE::"Sales Line":
                begin
                    SalesLine.Get("Source Subtype", "Source No.", "Source Line No.");
                    SalesLine.GetLotNo;
                    exit(SalesLine."Lot No.");
                end;
            DATABASE::"Purchase Line":
                begin
                    PurchLine.Get("Source Subtype", "Source No.", "Source Line No.");
                    PurchLine.GetLotNo;
                    exit(PurchLine."Lot No.");
                end;
            DATABASE::"Transfer Line":
                begin
                    TransLine.Get("Source No.", "Source Line No.");
                    TransLine.GetLotNo;
                    exit(TransLine."Lot No.");
                end;
        end;
    end;

    procedure ValidateLotNo(var LotNo: Code[50])
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        QtyToReceiveAlt: Decimal;
    begin
        // P8000282A
        if ProcessFns.AltQtyInstalled then                      // P8004505
            AltQtyMgmt.WhseRcptLineGetData(Rec, QtyToReceiveAlt); // P8004505

        case "Source Type" of
            DATABASE::"Sales Line":
                begin
                    SalesLine.Get("Source Subtype", "Source No.", "Source Line No.");
                    SalesLine.Validate("Lot No.", LotNo);
                    SalesLine.Modify(true);
                    SalesLine.WarehouseLineQuantity("Qty. to Receive (Base)", QtyToReceiveAlt, SalesLine."Qty. to Invoice (Base)"); // P8004505, P80077569
                    SalesLine.UpdateLotTracking(true, 0); // P8001106
                end;
            DATABASE::"Purchase Line":
                begin
                    PurchLine.Get("Source Subtype", "Source No.", "Source Line No.");
                    PurchLine.Validate("Lot No.", LotNo);
                    PurchLine.Modify(true);
                    PurchLine.WarehouseLineQuantity("Qty. to Receive (Base)", QtyToReceiveAlt, PurchLine."Qty. to Invoice (Base)"); // P8004505, P80077569
                    PurchLine.UpdateLotTracking(true); // P8001106
                end;
            DATABASE::"Transfer Line":
                begin
                    TransLine.Get("Source No.", "Source Line No.");
                    TransLine.Validate("Lot No.", LotNo);
                    TransLine.Modify(true);
                    TransLine.WarehouseLineQuantity("Qty. to Receive (Base)", QtyToReceiveAlt, 1); // P800108868
                    TransLine.UpdateLotTracking(true, 1); // P8001106, P800108868
                end;
        end;
    end;

    procedure AssistLotNoEdit(var LotNo: Code[50]): Boolean
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
        EasyLotTracking: Codeunit "Easy Lot Tracking";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        QtyToReceiveAlt: Decimal;
    begin
        // P8000282A
        // P8007477
        if ProcessFns.AltQtyInstalled then
            AltQtyMgmt.WhseRcptLineGetData(Rec, QtyToReceiveAlt);
        // P8007477
        case "Source Type" of
            DATABASE::"Sales Line":
                begin
                    SalesLine.Get("Source Subtype", "Source No.", "Source Line No.");
                    SalesLine."Lot No." := LotNo;
                    EasyLotTracking.SetSalesLine(SalesLine);
                    if not EasyLotTracking.AssistEdit(SalesLine."Lot No.") then
                        exit(false);
                    SalesLine.Modify(true);
                    SalesLine.WarehouseLineQuantity("Qty. to Receive (Base)", QtyToReceiveAlt, SalesLine."Qty. to Invoice (Base)"); // P8007477, P80077569
                    SalesLine.UpdateLotTracking(true, 0); // P8000466A
                end;
            DATABASE::"Purchase Line":
                begin
                    PurchLine.Get("Source Subtype", "Source No.", "Source Line No.");
                    PurchLine."Lot No." := LotNo;
                    EasyLotTracking.SetPurchaseLine(PurchLine);
                    if not EasyLotTracking.AssistEdit(PurchLine."Lot No.") then
                        exit(false);
                    PurchLine.Modify(true);
                    PurchLine.WarehouseLineQuantity("Qty. to Receive (Base)", QtyToReceiveAlt, PurchLine."Qty. to Invoice (Base)"); // P8007477, P80077569
                    PurchLine.UpdateLotTracking(true);
                end;
            DATABASE::"Transfer Line":
                begin
                    TransLine.Get("Source No.", "Source Line No.");
                    TransLine."Lot No." := LotNo;
                    EasyLotTracking.SetTransferLine(TransLine, 0);
                    if not EasyLotTracking.AssistEdit(TransLine."Lot No.") then
                        exit(false);
                    TransLine.Modify(true);
                    TransLine.UpdateLotTracking(true, 0);
                end;
        end;
        exit(true);
    end;

    [Obsolete('Replaced by MS Over Receiving functionality','FOOD-21')]
    procedure ProcessOverReceipt(AdditionalQuantity: Variant)
    var
        PurchLine: Record "Purchase Line";
        OriginalQty: Decimal;
        QuantityToAdd: Decimal;
        Handled: Boolean;
    begin
        // P8000372A
        // P80079197
        OnBeforeProcessOverReceipt(Rec, xRec, AdditionalQuantity, Handled);
        if Handled then
            exit;
        // P80079197
        // P80039780 - add parameter AdditionalQuantity
        if PurchLine.Get("Source Subtype", "Source No.", "Source Line No.") then begin
            PurchLine.SuspendStatusCheck(true); // P80039780
            OriginalQty := PurchLine."Original Quantity";
            // P80039780
            if AdditionalQuantity.IsDecimal or AdditionalQuantity.IsInteger then
                QuantityToAdd := AdditionalQuantity
            else
                QuantityToAdd := "Qty. to Receive" + GetContainerQuantity(false) - PurchLine."Outstanding Quantity";
            // P80039780
            PurchLine."Allow Quantity Change" := true;
            PurchLine.Validate(Quantity, Quantity + QuantityToAdd); // P80039780
            PurchLine.Validate("Original Quantity", OriginalQty);
            PurchLine."Allow Quantity Change" := false;
            PurchLine.UpdateLotTracking(true);   // P8007477
            PurchLine.Modify;
            Validate(Quantity, Quantity + QuantityToAdd); // P80039780
            Modify;
        end;
        OnAfterProcessOverReceipt(Rec, xRec, AdditionalQuantity); // P80079197
    end;

    procedure GetLotInfo(var SupplierLotNo: Code[50]; var CreationDate: Date; var CountryOfOrigin: Code[10])
    var
        PurchLine: Record "Purchase Line";
    begin
        // P8007108
        if ("Source Type" = DATABASE::"Purchase Line") then begin
            PurchLine.Get("Source Subtype", "Source No.", "Source Line No.");
            SupplierLotNo := PurchLine."Supplier Lot No.";
            CreationDate := PurchLine."Creation Date";
            CountryOfOrigin := PurchLine."Country/Region of Origin Code";
        end else begin
            SupplierLotNo := '';
            CreationDate := 0D;
            CountryOfOrigin := '';
        end;
    end;

    procedure ValidateSupplierLotNo(var SupplierLotNo: Code[50])
    var
        PurchLine: Record "Purchase Line";
    begin
        // P8001106
        if ("Source Type" = DATABASE::"Purchase Line") then begin
            PurchLine.Get("Source Subtype", "Source No.", "Source Line No.");
            PurchLine.Validate("Supplier Lot No.", SupplierLotNo);
            PurchLine.Modify(true);
            PurchLine.UpdateLotTracking(true);
        end;
    end;

    procedure ValidateCreationDate(var CreationDate: Date)
    var
        PurchLine: Record "Purchase Line";
    begin
        // P8007108
        if ("Source Type" = DATABASE::"Purchase Line") then begin
            PurchLine.Get("Source Subtype", "Source No.", "Source Line No.");
            PurchLine.Validate("Creation Date", CreationDate);
            PurchLine.Modify(true);
            PurchLine.UpdateLotTracking(true);
        end;
    end;

    procedure ValidateCountryOfOrigin(var CountryOfOrigin: Code[10])
    var
        PurchLine: Record "Purchase Line";
    begin
        // P8007108
        if ("Source Type" = DATABASE::"Purchase Line") then begin
            PurchLine.Get("Source Subtype", "Source No.", "Source Line No.");
            PurchLine.Validate("Country/Region of Origin Code", CountryOfOrigin);
            PurchLine.Modify(true);
            PurchLine.UpdateLotTracking(true);
        end;
    end;

    procedure IsNonWarehouseItem(): Boolean
    begin
        // P8001290
        if ("Item No." <> '') then begin
            GetItem;
            exit(Item."Non-Warehouse Item");
        end;
    end;

    local procedure TestContainerQuantity()
    begin
        // P80046533
        if GetContainerQuantity('') > 0 then
            if "Qty. to Receive" < GetContainerQuantity(true) then // P80046533
                FieldError("Qty. to Receive", Text37002701);
    end;

    procedure GetContainerQuantity(ShipReceive: Variant) QtyToHandle: Decimal
    var
        QtyToHandleBase: Decimal;
        QtyToHandleAlt: Decimal;
    begin
        // P80046533
        GetContainerQuantitiesByDocLine(QtyToHandle, QtyToHandleBase, QtyToHandleAlt, ShipReceive);
    end;

    local procedure GetContainerQuantitiesByDocLine(var QtyToHandle: Decimal; var QtyToHandleBase: Decimal; var QtyToHandleAlt: Decimal; ShipReceive: Variant)
    begin
        // P80046533
        if ProcessFns.ContainerTrackingInstalled then
            ContainerFns.GetContainerQuantitiesByDocLine(Rec, 0, QtyToHandle, QtyToHandleBase, QtyToHandleAlt, ShipReceive);
    end;

    local procedure CheckContainersExist()
    var
        ContainerLineAppl: Record "Container Line Application";
        P800Functions: Codeunit "Process 800 Functions";
    begin
        // P8001323
        // P80046533 - renamed from CheckContainersOnDelete
        if P800Functions.ContainerTrackingInstalled then begin
            ContainerLineAppl.SetRange("Application Table No.", "Source Type");
            ContainerLineAppl.SetRange("Application Subtype", "Source Subtype");
            ContainerLineAppl.SetRange("Application No.", "Source No.");
            ContainerLineAppl.SetRange("Application Line No.", "Source Line No.");
            if not ContainerLineAppl.IsEmpty then
                Error(Text37002700);
        end;
    end;

    procedure ShowBinStatus()
    var
        BinContent: Record "Bin Content";
        BinStatus: Page "Bin Status";
    begin
        // P80061239
        BinStatus.SetInitialLocation("Location Code");
        BinStatus.SetMode(2);
        BinContent.SetFilter("Item No.", "Item No.");
        if "Bin Code" <> '' then
            BinContent.SetRange("Bin Code", "Bin Code");
        BinStatus.SetTableView(BinContent);
        BinStatus.Run;
    end;

    local procedure InitQtyToReceive()
    begin
        Validate("Qty. to Receive", "Qty. Outstanding" - GetContainerQuantity(false)); // P80046533

        OnAfterInitQtyToReceive(Rec, CurrFieldNo);
    end;

    procedure GetWhseRcptLine(ReceiptNo: Code[20]; SourceType: Integer; SourceSubType: Option; SourceNo: Code[20]; SourceLineNo: Integer): Boolean
    begin
        SetRange("No.", ReceiptNo);
        SetSourceFilter(SourceType, SourceSubType, SourceNo, SourceLineNo, false);
        OnGetWhseRcptLineOnAfterSetFilters(Rec, ReceiptNo, SourceType, SourceSubType, SourceNo, SourceLineNo);
        if FindFirst() then
            exit(true);
    end;

    procedure SetItemData(ItemNo: Code[20]; ItemDescription: Text[100]; ItemDescription2: Text[50]; LocationCode: Code[10]; VariantCode: Code[10]; UoMCode: Code[10]; QtyPerUoM: Decimal)
    begin
        "Item No." := ItemNo;
        Description := ItemDescription;
        "Description 2" := ItemDescription2;
        "Location Code" := LocationCode;
        "Variant Code" := VariantCode;
        "Unit of Measure Code" := UoMCode;
        "Qty. per Unit of Measure" := QtyPerUoM;

        OnAfterSetItemData(Rec);
    end;

    procedure SetItemData(ItemNo: Code[20]; ItemDescription: Text[100]; ItemDescription2: Text[50]; LocationCode: Code[10]; VariantCode: Code[10]; UoMCode: Code[10]; QtyPerUoM: Decimal; QtyRndPrec: Decimal; QtyRndPrecBase: Decimal)
    begin
        SetItemData(ItemNo, ItemDescription, ItemDescription2, LocationCode, VariantCode, UoMCode, QtyPerUoM);
        "Qty. Rounding Precision" := QtyRndPrec;
        "Qty. Rounding Precision (Base)" := QtyRndPrecBase;
    end;

    procedure SetSource(SourceType: Integer; SourceSubType: Option; SourceNo: Code[20]; SourceLineNo: Integer)
    var
        WhseMgt: Codeunit "Whse. Management";
    begin
        "Source Type" := SourceType;
        "Source Subtype" := SourceSubType;
        "Source No." := SourceNo;
        "Source Line No." := SourceLineNo;
        "Source Document" := WhseMgt.GetWhseActivSourceDocument("Source Type", "Source Subtype");
    end;

    procedure SetSourceFilter(SourceType: Integer; SourceSubType: Option; SourceNo: Code[20]; SourceLineNo: Integer; SetKey: Boolean)
    var
        WhseManagement: Codeunit "Whse. Management";
    begin
        WhseManagement.SetSourceFilterForWhseRcptLine(Rec, SourceType, SourceSubType, SourceNo, SourceLineNo, SetKey);
    end;

    local procedure OverReceiptProcessing() Result: Boolean
    var
        OverReceiptMgt: Codeunit "Over-Receipt Mgt.";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOverReceiptProcessing(Rec, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if not OverReceiptMgt.IsOverReceiptAllowed() or (CurrFieldNo <> FieldNo("Qty. to Receive")) or ("Qty. to Receive" <= "Qty. Outstanding") then
            exit(false);

        // Validate("Over-Receipt Quantity", "Qty. to Receive" - Quantity + "Qty. Received" + "Over-Receipt Quantity");
        Validate("Over-Receipt Quantity", "Qty. to Receive" - "Qty. Outstanding" + GetContainerQuantity(false) + "Over-Receipt Quantity");
        exit(true);
    end;

    local procedure ValidateQuantityIsBalanced()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnValidateQtyToReceiveOnBeforeUOMMgtValidateQtyIsBalanced(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        UOMMgt.ValidateQtyIsBalanced(Quantity, "Qty. (Base)", "Qty. to Receive", "Qty. to Receive (Base)", "Qty. Received", "Qty. Received (Base)");
    end;

    local procedure MaxQtyToReceiveBase(QtyToReceiveBase: Decimal): Decimal
    begin
        if Abs(QtyToReceiveBase) > Abs("Qty. Outstanding (Base)") then
            exit("Qty. Outstanding (Base)");
        exit(QtyToReceiveBase);
    end;

    local procedure MaxQtyOutstandingBase(QtyOutstandingBase: Decimal): Decimal
    begin
        if Abs(QtyOutstandingBase + "Qty. Received (Base)") > Abs("Qty. (Base)") then
            exit("Qty. (Base)" - "Qty. Received (Base)");
        exit(QtyOutstandingBase);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterOpenItemTrackingLines(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; SecondSourceQtyArray: array[3] of Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitQtyToReceive(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetItemData(var WarehouseReceiptLine: Record "Warehouse Receipt Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAutoFillQtyToReceiveOnBeforeModify(var WarehouseReceiptLine: Record "Warehouse Receipt Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckBin(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmDelete(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; var SkipConfirm: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitOutstandingQtys(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOpenItemTrackingLines(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; var IsHandled: Boolean; CallingFieldNo: Integer)
    begin
    end;

    [Obsolete('Replaced by MS Over Receiving functionality', 'FOOD-21')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessOverReceipt(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; var xWarehouseReceiptLine: Record "Warehouse Receipt Line"; AdditionalQty: Variant; var Handled: Boolean)
    begin
        // P80079197
    end;

    [Obsolete('Replaced by MS Over Receiving functionality', 'FOOD-21')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterProcessOverReceipt(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; var xWarehouseReceiptLine: Record "Warehouse Receipt Line"; AdditionalQty: Variant)
    begin
        // P80079197
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateQtyToReceive(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; var IsHandled: Boolean; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateQtyToReceiveBase(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; xWarehouseReceiptLine: Record "Warehouse Receipt Line"; CallingFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateOverReceiptQuantity(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; xWarehouseReceiptLine: Record "Warehouse Receipt Line"; CalledByFieldNo: Integer; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeleteQtyToReceiveOnBeforeModify(var WhseReceiptLine: Record "Warehouse Receipt Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAutofillQtyToReceive(var WhseReceiptLine: Record "Warehouse Receipt Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteQtyToReceive(var WhseReceiptLine: Record "Warehouse Receipt Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckBinOnAfterCheckIncreaseBin(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; var Bin: Record Bin; DeductCubage: Decimal; DeductWeight: Decimal; IgnoreErrors: Boolean; var ErrorOccured: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOverReceiptProcessing(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetWhseRcptLineOnAfterSetFilters(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; ReceiptNo: Code[20]; SourceType: Integer; SourceSubType: Option; SourceNo: Code[20]; SourceLineNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateQtyToReceiveOnBeforeUOMMgtValidateQtyIsBalanced(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; xWarehouseReceiptLine: Record "Warehouse Receipt Line"; var IsHandled: Boolean)
    begin
    end;
}

