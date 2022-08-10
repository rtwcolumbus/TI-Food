table 7321 "Warehouse Shipment Line"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 09-10-2014, Initial Version
    // --------------------------------------------------------------------------------
    // TOM4225     01-10-2015, Rename "Change Item" to "Item Substitution"
    // --------------------------------------------------------------------------------
    // 
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   P800 WMS project - alternate quantities; easy lot tracking
    // 
    // PR4.00.04
    // P8000372A, VerticalSoft, Phyllis McGovern, 25 SEP 06
    //   WH Overship and OverReceive
    //   Modified 'Qty. to Handle - OnValidate()' to allow over-ship
    //   Added local function 'ProcessOverShip', called from 'Qty. to Handle - OnValidate()'
    //   Added local function 'OverShipUpdateShipmentHeader'
    //   Added Global: Overship
    // 
    // PR5.00
    // P8000503A, VerticalSoft, Don Bresee, 13 FEB 07
    //   Rounding re-work
    // 
    // PRW16.00.02
    // P8000746, VerticalSoft, Jack Reynolds, 22 FEB 10
    //   Fix problem with "Another user has modified ..." when updating header for over shipments
    // 
    // PRW17.10
    // P8001245, Columbus IT, Jack Reynolds, 21 NOV 13
    //   Correct confusing behavior of Assist Edit for Lot No.
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 17 MAR 16
    //   Incorporate modifications for NAV Anywhere processes
    // 
    // PRW19.00.01
    // P8007477, To-Increase, Dayakar Battini, 25 JUL 16
    //   Qty. to Handle fields updation when assigning lot.
    // 
    // P8007536, To-Increase, Dayakar Battini, 12 AUG 16
    //   Item Tracking quantity update when Over shipment.
    // 
    // P8006916, To-Increase, Jack Reynolds, 31 AUG 16
    //   FOOD-TOM Separation
    // 
    // P8008172, To-Increase, Dayakar Battini, 09 DEC 16
    //   Lifecycle Management
    // 
    // P8008297, To-Increase, Dayakar Battini, 18 DEC 16
    //   Lifecycle settings fields cleanup
    // 
    // PRW110.0.02
    // P80039781, To-Increase, Jack Reynolds, 10 DEC 17
    //   Warehouse Shipping process
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
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW111.00.02
    // P80073378, To Increase, Jack Reynolds, 24 MAR 19
    //   Support for easy lot tracking on warehouse shipments
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    // PRW111.00.03
    // P80077569, To-Increase, Gangabhushan, 17 JUL 19
    //   CS00069439 - Item tracking that is pre-defined in S.O. will now allow pick registration with qty. - Error
    //
    // P800108868, To-Increase, Gangabhushan, 20 OCT 20
    //   CS00129745 | Transfer Receiving Issue

    Caption = 'Warehouse Shipment Line';
    DrillDownPageID = "Whse. Shipment Lines";
    LookupPageID = "Whse. Shipment Lines";

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
                TestReleased;
                if xRec."Bin Code" <> "Bin Code" then
                    if "Bin Code" <> '' then begin
                        GetItem;                                    // P8001290
                        Item.TestField("Non-Warehouse Item", false); // P8001290
                        GetLocation("Location Code");
                        WhseIntegrationMgt.CheckBinTypeCode(DATABASE::"Warehouse Shipment Line",
                          FieldCaption("Bin Code"),
                          "Location Code",
                          "Bin Code", 0);
                        if Location."Directed Put-away and Pick" then begin
                            Bin.Get("Location Code", "Bin Code");
                            "Zone Code" := Bin."Zone Code";
                            CheckBin(0, 0);
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
                TestReleased;
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
            MinValue = 0;

            trigger OnValidate()
            var
                OrderStatus: Integer;
                IsHandled: Boolean;
            begin
                if Quantity <= 0 then
                    FieldError(Quantity, Text003);
                TestReleased;
                CheckSourceDocLineQty;

                if Quantity < "Qty. Picked" then
                    FieldError(Quantity, StrSubstNo(Text001, "Qty. Picked"));
                if Quantity < "Qty. Shipped" then
                    FieldError(Quantity, StrSubstNo(Text001, "Qty. Shipped"));

                Quantity := UOMMgt.RoundAndValidateQty(Quantity, "Qty. Rounding Precision", FieldCaption(Quantity));
                "Qty. (Base)" := CalcBaseQty(Quantity, FieldCaption(Quantity), FieldCaption("Qty. (Base)"));
                InitOutstandingQtys;
                "Completely Picked" := (Quantity = "Qty. Picked") or ("Qty. (Base)" = "Qty. Picked (Base)");

                GetLocation("Location Code");
                if Location."Directed Put-away and Pick" then
                    CheckBin(xRec.Cubage, xRec.Weight);

                IsHandled := false;
                OnValidateQuantityStatusUpdate(Rec, xRec, IsHandled);
                if not IsHandled then begin
                    Status := CalcStatusShptLine;
                    if (Status <> xRec.Status) and (not IsTemporary) then begin
                        GetWhseShptHeader("No.");
                        OrderStatus := WhseShptHeader.GetDocumentStatus(0);
                        if OrderStatus <> WhseShptHeader."Document Status" then begin
                            WhseShptHeader.Validate("Document Status", OrderStatus);
                            WhseShptHeader.Modify();
                        end;
                    end;
                end;
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
            var
                WMSMgt: Codeunit "WMS Management";
            begin
                GetLocation("Location Code");
                "Qty. Outstanding" := UOMMgt.RoundAndValidateQty("Qty. Outstanding", "Qty. Rounding Precision", FieldCaption("Qty. Outstanding"));
                "Qty. Outstanding (Base)" := MaxQtyOutstandingBase(CalcBaseQty("Qty. Outstanding", FieldCaption("Qty. Outstanding"), FieldCaption("Qty. Outstanding (Base)")));
                if Location."Require Pick" then begin
                    if "Assemble to Order" then
                        Validate("Qty. to Ship", 0)
                    else
                        Validate("Qty. to Ship", "Qty. Picked" - (Quantity - "Qty. Outstanding") - GetContainerQuantity(false)); // P80046533
                end else
                    Validate("Qty. to Ship", "Qty. Outstanding" - GetContainerQuantity(false)); // P80046533

                if Location."Directed Put-away and Pick" then
                    WMSMgt.CalcCubageAndWeight(
                      "Item No.", "Unit of Measure Code", "Qty. Outstanding", Cubage, Weight);
            end;
        }
        field(20; "Qty. Outstanding (Base)"; Decimal)
        {
            Caption = 'Qty. Outstanding (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(21; "Qty. to Ship"; Decimal)
        {
            Caption = 'Qty. to Ship';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            var
                ATOLink: Record "Assemble-to-Order Link";
                Confirmed: Boolean;
                IsHandled: Boolean;
            begin
                GetLocation("Location Code");

                if CurrFieldNo <> 0 then
                    TestContainerQuantity; // P8001323

                if CurrFieldNo <> 0 then begin // P80046533
                                               // P8000372A Begin
                    if ("Source Type" = DATABASE::"Sales Line") or ("Source Type" = DATABASE::"Transfer Line") then
                        if ("Qty. to Ship" + GetContainerQuantity(false)) > "Qty. Outstanding" then // P80046533
                            if GuiAllowed then begin                 // P8004516
                                if Confirm(Text37000000) then begin
                                    OverShip := true;
                                    ProcessOverShip('') // P80039780
                                end else     // P80046533
                                    Error(''); // P80046533
                                               // P8004516
                            end else begin
                                OverShip := true;
                                ProcessOverShip('') // P80039780
                            end;
                    // P8004516
                    // P8000372A End

                    IsHandled := false;
                    OnBeforeCompareShipAndPickQty(Rec, IsHandled);
                    if not IsHandled then
                        if ("Qty. to Ship" > "Qty. Picked" - "Qty. Shipped") and Location."Require Pick" and not "Assemble to Order" and (not OverShip) then // P8000372A
                            FieldError("Qty. to Ship", StrSubstNo(Text002, "Qty. Picked" - "Qty. Shipped"));

                    IsHandled := false;
                    OnBeforeCompareQtyToShipAndOutstandingQty(Rec, IsHandled);
                    if not IsHandled then
                        if "Qty. to Ship" > "Qty. Outstanding" then
                            Error(Text000, "Qty. Outstanding");
                end; // P80046533

                Confirmed := true;
                if (CurrFieldNo = FieldNo("Qty. to Ship")) and
                   ("Shipping Advice" = "Shipping Advice"::Complete) and
                   ("Qty. to Ship" <> "Qty. Outstanding") and
                   ("Qty. to Ship" > 0)
                then
                    Confirmed :=
                      Confirm(
                        Text009 +
                        Text010,
                        false,
                        FieldCaption("Shipping Advice"),
                        "Shipping Advice",
                        FieldCaption("Qty. to Ship"),
                        "Qty. Outstanding");

                if not Confirmed then
                    Error('');

                if CurrFieldNo <> FieldNo("Qty. to Ship (Base)") then begin
                    "Qty. to Ship" := UOMMgt.RoundAndValidateQty("Qty. to Ship", "Qty. Rounding Precision", FieldCaption("Qty. to Ship"));
                    "Qty. to Ship (Base)" := MaxQtyToShipBase(CalcBaseQty("Qty. to Ship", FieldCaption("Qty. to Ship"), FieldCaption("Qty. to Ship (Base)")));

                    UOMMgt.ValidateQtyIsBalanced(Quantity, "Qty. (Base)", "Qty. to Ship", "Qty. to Ship (Base)", "Qty. Shipped", "Qty. Shipped (Base)");
                end;

                if ("Qty. to Ship (Base)" > "Qty. (Base)") then
                    "Qty. to Ship (Base)" := "Qty. (Base)";
                // P8000503A

                if "Assemble to Order" then
                    ATOLink.UpdateQtyToAsmFromWhseShptLine(Rec);
            end;
        }
        field(22; "Qty. to Ship (Base)"; Decimal)
        {
            Caption = 'Qty. to Ship (Base)';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateQtyToShipBase(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                Validate("Qty. to Ship", CalcQty("Qty. to Ship (Base)"));
            end;
        }
        field(23; "Qty. Picked"; Decimal)
        {
            Caption = 'Qty. Picked';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = Normal;

            trigger OnValidate()
            begin
                "Qty. Picked" := UOMMgt.RoundAndValidateQty("Qty. Picked", "Qty. Rounding Precision", FieldCaption("Qty. Picked"));
                "Qty. Picked (Base)" := CalcBaseQty("Qty. Picked", FieldCaption("Qty. Picked"), FieldCaption("Qty. Picked (Base)"));
            end;
        }
        field(24; "Qty. Picked (Base)"; Decimal)
        {
            Caption = 'Qty. Picked (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(25; "Qty. Shipped"; Decimal)
        {
            Caption = 'Qty. Shipped';
            DecimalPlaces = 0 : 5;
            Editable = false;

            trigger OnValidate()
            begin
                "Qty. Shipped" := UOMMgt.RoundAndValidateQty("Qty. Shipped", "Qty. Rounding Precision", FieldCaption("Qty. Shipped"));
                "Qty. Shipped (Base)" := CalcBaseQty("Qty. Shipped", FieldCaption("Qty. Shipped"), FieldCaption("Qty. Shipped (Base)"));
            end;
        }
        field(26; "Qty. Shipped (Base)"; Decimal)
        {
            Caption = 'Qty. Shipped (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(27; "Pick Qty."; Decimal)
        {
            CalcFormula = Sum("Warehouse Activity Line"."Qty. Outstanding" WHERE("Activity Type" = CONST(Pick),
                                                                                  "Whse. Document Type" = CONST(Shipment),
                                                                                  "Whse. Document No." = FIELD("No."),
                                                                                  "Whse. Document Line No." = FIELD("Line No."),
                                                                                  "Unit of Measure Code" = FIELD("Unit of Measure Code"),
                                                                                  "Action Type" = FILTER(" " | Place),
                                                                                  "Original Breakbulk" = CONST(false),
                                                                                  "Breakbulk No." = CONST(0),
                                                                                  "Assemble to Order" = CONST(false)));
            Caption = 'Pick Qty.';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(28; "Pick Qty. (Base)"; Decimal)
        {
            CalcFormula = Sum("Warehouse Activity Line"."Qty. Outstanding (Base)" WHERE("Activity Type" = CONST(Pick),
                                                                                         "Whse. Document Type" = CONST(Shipment),
                                                                                         "Whse. Document No." = FIELD("No."),
                                                                                         "Whse. Document Line No." = FIELD("Line No."),
                                                                                         "Action Type" = FILTER(" " | Place),
                                                                                         "Original Breakbulk" = CONST(false),
                                                                                         "Breakbulk No." = CONST(0),
                                                                                         "Assemble to Order" = CONST(false)));
            Caption = 'Pick Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
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
            OptionCaption = ' ,Partially Picked,Partially Shipped,Completely Picked,Completely Shipped';
            OptionMembers = " ","Partially Picked","Partially Shipped","Completely Picked","Completely Shipped";
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
        field(39; "Destination Type"; Enum "Warehouse Destination Type")
        {
            Caption = 'Destination Type';
            Editable = false;
        }
        field(40; "Destination No."; Code[20])
        {
            Caption = 'Destination No.';
            Editable = false;
            TableRelation = IF ("Destination Type" = CONST(Customer)) Customer."No."
            ELSE
            IF ("Destination Type" = CONST(Vendor)) Vendor."No."
            ELSE
            IF ("Destination Type" = CONST(Location)) Location.Code;
        }
        field(41; Cubage; Decimal)
        {
            Caption = 'Cubage';
            DecimalPlaces = 0 : 5;
        }
        field(42; Weight; Decimal)
        {
            Caption = 'Weight';
            DecimalPlaces = 0 : 5;
        }
        field(44; "Shipping Advice"; Enum "Sales Header Shipping Advice")
        {
            Caption = 'Shipping Advice';
            Editable = false;
        }
        field(45; "Shipment Date"; Date)
        {
            Caption = 'Shipment Date';
        }
        field(46; "Completely Picked"; Boolean)
        {
            Caption = 'Completely Picked';
            Editable = false;
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
        field(50; "Qty. Rounding Precision"; Decimal)
        {
            Caption = 'Qty. Rounding Precision';
            InitValue = 0;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 1;
            Editable = false;
        }
        field(51; "Qty. Rounding Precision (Base)"; Decimal)
        {
            Caption = 'Qty. Rounding Precision (Base)';
            InitValue = 0;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 1;
            Editable = false;
        }
        field(900; "Assemble to Order"; Boolean)
        {
            AccessByPermission = TableData "BOM Component" = R;
            Caption = 'Assemble to Order';
            Editable = false;
        }
        field(11028580; Short; Boolean)
        {
            Caption = 'Short';
        }
        field(11028581; "Short Action"; Option)
        {
            Caption = 'Short Action';
            OptionCaption = 'Change Quantity,Substitute Item';
            OptionMembers = "Change Quantity","Substitute Item";
        }
        field(11028582; "Delivery Trip"; Code[20])
        {
            CalcFormula = Lookup ("Warehouse Shipment Header"."Delivery Trip" WHERE("No." = FIELD("No.")));
            Caption = 'Delivery Trip';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002000; "Assigned User ID"; Code[50])
        {
            Caption = 'Assigned User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "Warehouse Employee" WHERE("Location Code" = FIELD("Location Code"));
        }
    }

    keys
    {
        key(Key1; "No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "No.", "Sorting Sequence No.")
        {
            MaintainSQLIndex = false;
        }
        key(Key3; "No.", "Item No.")
        {
            MaintainSQLIndex = false;
        }
        key(Key4; "No.", "Source Document", "Source No.")
        {
            MaintainSQLIndex = false;
        }
        key(Key5; "No.", "Shelf No.")
        {
            MaintainSQLIndex = false;
        }
        key(Key6; "No.", "Bin Code")
        {
            MaintainSQLIndex = false;
        }
        key(Key7; "No.", "Due Date")
        {
            MaintainSQLIndex = false;
        }
        key(Key8; "No.", "Destination Type", "Destination No.")
        {
            MaintainSQLIndex = false;
        }
        key(Key9; "Source Type", "Source Subtype", "Source No.", "Source Line No.", "Assemble to Order")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Qty. Outstanding", "Qty. Outstanding (Base)";
        }
        key(Key10; "No.", "Source Type", "Source Subtype", "Source No.", "Source Line No.")
        {
            MaintainSQLIndex = false;
        }
        key(Key11; "Item No.", "Location Code", "Variant Code", "Due Date")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Qty. Outstanding (Base)", "Qty. Picked (Base)", "Qty. Shipped (Base)";
        }
        key(Key12; "Bin Code", "Location Code")
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
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        TestReleased;
        CheckContainersExist; // P8001323

        if "Assemble to Order" then
            Validate("Qty. to Ship", 0);

        if "Qty. Shipped" < "Qty. Picked" then
            if not Confirm(
                 StrSubstNo(
                   Text007,
                   FieldCaption("Qty. Picked"), "Qty. Picked", FieldCaption("Qty. Shipped"),
                   "Qty. Shipped", TableCaption), false)
            then
                Error('');

        ItemTrackingMgt.SetDeleteReservationEntries(true);
        ItemTrackingMgt.DeleteWhseItemTrkgLines(
          DATABASE::"Warehouse Shipment Line", 0, "No.", '', 0, "Line No.", "Location Code", true);

        UpdateDocumentStatus();
    end;

    trigger OnModify()
    begin
        OverShip := false; // P8000372A
    end;

    trigger OnRename()
    begin
        Error(Text008, TableCaption);
    end;

    var
        Text000: Label 'You cannot handle more than the outstanding %1 units.';
        Location: Record Location;
        Item: Record Item;
        UOMMgt: Codeunit "Unit of Measure Management";
        Text001: Label 'must not be less than %1 units';
        Text002: Label 'must not be greater than %1 units';
        Text003: Label 'must be greater than zero';
        Text005: Label 'The picked quantity is not enough to ship all lines.';
        Text007: Label '%1 = %2 is greater than %3 = %4. If you delete the %5, the items will remain in the shipping area until you put them away.\Related Item Tracking information defined during pick will be deleted.\Do you still want to delete the %5?', Comment = 'Qty. Picked = 2 is greater than Qty. Shipped = 0. If you delete the Warehouse Shipment Line, the items will remain in the shipping area until you put them away.\Related Item Tracking information defined during pick will be deleted.\Do you still want to delete the Warehouse Shipment Line?';
        Text008: Label 'You cannot rename a %1.';
        Text009: Label '%1 is set to %2. %3 should be %4.\\';
        Text010: Label 'Accept the entered value?';
        Text011: Label 'Nothing to handle.';
        IgnoreErrors: Boolean;
        ErrorOccured: Boolean;
        OverShip: Boolean;
        Text37000000: Label 'Confirm Over-ship';
        Text37002700: Label 'One or more containers are associated with this shipment line.';
        Text37002701: Label 'cannot be less than quantity assigned through containers';
        ProcessFns: Codeunit "Process 800 Functions";
        ContainerFns: Codeunit "Container Functions";

    protected var
        WhseShptHeader: Record "Warehouse Shipment Header";
        HideValidationDialog: Boolean;
        StatusCheckSuspended: Boolean;

    procedure InitNewLine(DocNo: Code[20])
    begin
        // P80096141 - Original signature
        InitNewLine(DocNo, false);
    end;

    procedure InitNewLine(DocNo: Code[20]; UserInteraction: Boolean)
    begin
        // P80053245 - add UserInteraction parameter
        Reset;
        "No." := DocNo;
        SetRange("No.", "No.");
        if not UserInteraction then //N138F0000.n, P80053245
            LockTable();
        if FindLast then;

        Init;
        SetIgnoreErrors;
        "Line No." := "Line No." + 10000;
    end;

    procedure CalcQty(QtyBase: Decimal): Decimal
    begin
        TestField("Qty. per Unit of Measure");
        exit(UOMMgt.RoundQty(QtyBase / "Qty. per Unit of Measure", "Qty. Rounding Precision"));
    end;

    local procedure CalcBaseQty(Qty: Decimal; FromFieldName: Text; ToFieldName: Text): Decimal
    begin
        TestField("Qty. per Unit of Measure");
        exit(UOMMgt.CalcBaseQty(
            "Item No.", "Variant Code", "Unit of Measure Code", Qty, "Qty. per Unit of Measure", "Qty. Rounding Precision (Base)", FieldCaption("Qty. Rounding Precision"), FromFieldName, ToFieldName));
    end;

    local procedure GetLocation(LocationCode: Code[10])
    begin
        if LocationCode = '' then
            Location.GetLocationSetup(LocationCode, Location)
        else
            if Location.Code <> LocationCode then
                Location.Get(LocationCode);
    end;

    local procedure TestReleased()
    begin
        TestField("No.");
        GetWhseShptHeader("No.");
        OnBeforeTestReleased(WhseShptHeader, StatusCheckSuspended);
        if not StatusCheckSuspended then
            WhseShptHeader.TestField(Status, WhseShptHeader.Status::Open);
    end;

    local procedure UpdateDocumentStatus()
    var
        OrderStatus: Option;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateDocumentStatus(Rec, IsHandled);
        if IsHandled then
            exit;

        OrderStatus := WhseShptHeader.GetDocumentStatus("Line No.");
        if OrderStatus <> WhseShptHeader."Document Status" then begin
            WhseShptHeader.Validate("Document Status", OrderStatus);
            WhseShptHeader.Modify();
        end;
    end;

    procedure CheckBin(DeductCubage: Decimal; DeductWeight: Decimal)
    var
        Bin: Record Bin;
        BinContent: Record "Bin Content";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckBin(Rec, Bin, DeductCubage, DeductWeight, IgnoreErrors, ErrorOccured, IsHandled);
        if IsHandled then
            exit;

        if "Bin Code" <> '' then begin
            GetLocation("Location Code");
            if not Location."Directed Put-away and Pick" then
                exit;

            if BinContent.Get(
                 "Location Code", "Bin Code",
                 "Item No.", "Variant Code", "Unit of Measure Code")
            then begin
                if not BinContent.CheckIncreaseBinContent(
                     "Qty. Outstanding", "Qty. Outstanding",
                     DeductCubage, DeductWeight, Cubage, Weight, false, IgnoreErrors)
                then
                    ErrorOccured := true;
            end else begin
                Bin.Get("Location Code", "Bin Code");
                if not Bin.CheckIncreaseBin(
                     "Bin Code", "Item No.", "Qty. Outstanding",
                     DeductCubage, DeductWeight, Cubage, Weight, false, IgnoreErrors)
                then
                    ErrorOccured := true;
            end;
        end;
        if ErrorOccured then
            "Bin Code" := '';
    end;

    procedure CheckSourceDocLineQty()
    var
        WhseShptLine: Record "Warehouse Shipment Line";
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        TransferLine: Record "Transfer Line";
        ServiceLine: Record "Service Line";
        WhseQtyOutstandingBase: Decimal;
        QtyOutstandingBase: Decimal;
        QuantityBase: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckSourceDocLineQty(Rec, IsHandled);
        if IsHandled then
            exit;

        SetQuantityBase(QuantityBase);

        WhseShptLine.SetSourceFilter("Source Type", "Source Subtype", "Source No.", "Source Line No.", true);
        WhseShptLine.CalcSums("Qty. Outstanding (Base)");
        if WhseShptLine.Find('-') then
            repeat
                if (WhseShptLine."No." <> "No.") or
                   (WhseShptLine."Line No." <> "Line No.")
                then
                    WhseQtyOutstandingBase := WhseQtyOutstandingBase + WhseShptLine."Qty. Outstanding (Base)";
            until WhseShptLine.Next() = 0;

        case "Source Type" of
            DATABASE::"Sales Line":
                begin
                    SalesLine.Get("Source Subtype", "Source No.", "Source Line No.");
                    if Abs(SalesLine."Outstanding Qty. (Base)") < WhseQtyOutstandingBase + QuantityBase then
                        FieldError(Quantity, StrSubstNo(Text002, CalcQty(SalesLine."Outstanding Qty. (Base)" - WhseQtyOutstandingBase)));
                    QtyOutstandingBase := Abs(SalesLine."Outstanding Qty. (Base)");
                end;
            DATABASE::"Purchase Line":
                begin
                    PurchaseLine.Get("Source Subtype", "Source No.", "Source Line No.");
                    if Abs(PurchaseLine."Outstanding Qty. (Base)") < WhseQtyOutstandingBase + QuantityBase then
                        FieldError(Quantity, StrSubstNo(Text002, CalcQty(Abs(PurchaseLine."Outstanding Qty. (Base)") - WhseQtyOutstandingBase)));
                    QtyOutstandingBase := Abs(PurchaseLine."Outstanding Qty. (Base)");
                end;
            DATABASE::"Transfer Line":
                begin
                    TransferLine.Get("Source No.", "Source Line No.");
                    if TransferLine."Outstanding Qty. (Base)" < WhseQtyOutstandingBase + QuantityBase then
                        FieldError(Quantity, StrSubstNo(Text002, CalcQty(TransferLine."Outstanding Qty. (Base)" - WhseQtyOutstandingBase)));
                    QtyOutstandingBase := TransferLine."Outstanding Qty. (Base)";
                end;
            DATABASE::"Service Line":
                begin
                    ServiceLine.Get("Source Subtype", "Source No.", "Source Line No.");
                    if Abs(ServiceLine."Outstanding Qty. (Base)") < WhseQtyOutstandingBase + QuantityBase then
                        FieldError(Quantity, StrSubstNo(Text002, CalcQty(ServiceLine."Outstanding Qty. (Base)" - WhseQtyOutstandingBase)));
                    QtyOutstandingBase := Abs(ServiceLine."Outstanding Qty. (Base)");
                end;
            else
                OnCheckSourceDocLineQtyOnCaseSourceType(Rec, WhseQtyOutstandingBase, QtyOutstandingBase, QuantityBase);
        end;
        IsHandled := false;
        OnCheckSourceDocLineQtyOnBeforeFieldError(Rec, WhseQtyOutstandingBase, QtyOutstandingBase, QuantityBase, IsHandled);
        if not IsHandled then
            if QuantityBase > QtyOutstandingBase then
                FieldError(Quantity, StrSubstNo(Text002, FieldCaption("Qty. Outstanding")));
    end;

    procedure CalcStatusShptLine(): Integer
    var
        NewStatus: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalcStatusShptLine(Rec, NewStatus, IsHandled);
        if IsHandled then
            exit(NewStatus);

        if (Quantity = "Qty. Shipped") or ("Qty. (Base)" = "Qty. Shipped (Base)") then
            exit(Status::"Completely Shipped");
        if "Qty. Shipped" > 0 then
            exit(Status::"Partially Shipped");
        if (Quantity = "Qty. Picked") or ("Qty. (Base)" = "Qty. Picked (Base)") then
            exit(Status::"Completely Picked");
        if "Qty. Picked" > 0 then
            exit(Status::"Partially Picked");
        exit(Status::" ");
    end;

    procedure AutofillQtyToHandle(var WhseShptLine: Record "Warehouse Shipment Line")
    var
        NotEnough: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeAutofillQtyToHandle(WhseShptLine, HideValidationDialog, IsHandled);
        if IsHandled then
            exit;

        with WhseShptLine do begin
            NotEnough := false;
            SetHideValidationDialog(true);
            if Find('-') then
                repeat
                    GetLocation("Location Code");
                    if Location."Require Pick" then
                        Validate("Qty. to Ship (Base)", "Qty. Picked (Base)" - "Qty. Shipped (Base)" - GetContainerQuantityBase(false)) // P80046533
                    else
                        Validate("Qty. to Ship (Base)", "Qty. Outstanding (Base)" - GetContainerQuantityBase(false)); // P80046533
                    OnAutoFillQtyToHandleOnBeforeModify(WhseShptLine);
                    Modify;
                    WhseShptLine.SetLotQuantity(WhseShptLine.GetLotNo); // P80073378
                    if not NotEnough then
                        if ("Qty. to Ship (Base)" < ("Qty. Outstanding (Base)" - GetContainerQuantityBase(false))) and // P80046533
                           ("Shipping Advice" = "Shipping Advice"::Complete)
                        then
                            NotEnough := true;
                until Next() = 0;
            SetHideValidationDialog(false);
            if NotEnough then
                Message(Text005);
        end;
        OnAfterAutofillQtyToHandle(WhseShptLine, HideValidationDialog);
    end;

    procedure DeleteQtyToHandle(var WhseShptLine: Record "Warehouse Shipment Line")
    var
        UpdateDocLine: Codeunit "Update Document Line";
        MinimumQuantity: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeDeleteQtyToHandle(WhseShptLine, IsHandled);
        if IsHandled then
            exit;

        with WhseShptLine do begin
            if Find('-') then
                repeat
                    MinimumQuantity := GetContainerQuantity(true); // P80039780
                    Validate("Qty. to Ship", MinimumQuantity); // P8001323, P80039780
                    OnDeleteQtyToHandleOnBeforeModify(WhseShptLine);
                    Modify;
                    UpdateDocLine.ClearQtyToHandle(WhseShptLine, 0); // P80039780
                until Next() = 0;
        end;
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    protected procedure GetWhseShptHeader(WhseShptNo: Code[20])
    begin
        if WhseShptHeader."No." <> WhseShptNo then
            WhseShptHeader.Get(WhseShptNo);

        OnAfterGetWhseShptHeader(Rec, WhseShptHeader, WhseShptNo);
    end;

    procedure CreatePickDoc(var WhseShptLine: Record "Warehouse Shipment Line"; WhseShptHeader2: Record "Warehouse Shipment Header")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnCreatePickDocOnBeforeCreatePickDoc(Rec, WhseShptLine, WhseShptHeader2, HideValidationDialog, IsHandled);
        if IsHandled then
            exit;

        WhseShptHeader2.TestField(Status, WhseShptHeader.Status::Released);
        WhseShptLine.SetFilter(Quantity, '>0');
        WhseShptLine.SetRange("Completely Picked", false);
        if WhseShptLine.Find('-') then
            CreatePickDocFromWhseShpt(WhseShptLine, WhseShptHeader2, HideValidationDialog)
        else
            if not HideValidationDialog then
                Message(Text011);
    end;

    local procedure CreatePickDocFromWhseShpt(var WhseShptLine: Record "Warehouse Shipment Line"; WhseShptHeader: Record "Warehouse Shipment Header"; HideValidationDialog: Boolean)
    var
        WhseShipmentCreatePick: Report "Whse.-Shipment - Create Pick";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreatePickDoc(WhseShptLine, WhseShptHeader, HideValidationDialog, IsHandled);
        if not IsHandled then begin
            WhseShipmentCreatePick.SetWhseShipmentLine(WhseShptLine, WhseShptHeader);
            WhseShipmentCreatePick.SetHideValidationDialog(HideValidationDialog);
            WhseShipmentCreatePick.UseRequestPage(not HideValidationDialog);
            WhseShipmentCreatePick.RunModal;
            WhseShipmentCreatePick.GetResultMessage;
            Clear(WhseShipmentCreatePick);
        end;
        OnAfterCreatePickDoc(WhseShptHeader, WhseShptLine);
    end;

    local procedure GetItem()
    begin
        if Item."No." <> "Item No." then
            Item.Get("Item No.");
    end;

    procedure OpenItemTrackingLines()
    var
        PurchaseLine: Record "Purchase Line";
        SalesLine: Record "Sales Line";
        ServiceLine: Record "Service Line";
        TransferLine: Record "Transfer Line";
        PurchLineReserve: Codeunit "Purch. Line-Reserve";
        SalesLineReserve: Codeunit "Sales Line-Reserve";
        TransferLineReserve: Codeunit "Transfer Line-Reserve";
        ServiceLineReserve: Codeunit "Service Line-Reserve";
        SecondSourceQtyArray: array[3] of Decimal;
        Direction: Enum "Transfer Direction";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOpenItemTrackingLines(Rec, IsHandled);
        if IsHandled then
            exit;

        TestField("No.");
        TestField("Qty. (Base)");

        GetItem;
        Item.TestField("Item Tracking Code");

        SecondSourceQtyArray[1] := DATABASE::"Warehouse Shipment Line";
        SecondSourceQtyArray[2] := "Qty. to Ship (Base)";
        SecondSourceQtyArray[3] := 0;

        case "Source Type" of
            DATABASE::"Sales Line":
                begin
                    if SalesLine.Get("Source Subtype", "Source No.", "Source Line No.") then begin // P80007477
                        SalesLineReserve.CallItemTrackingSecondSource(SalesLine, SecondSourceQtyArray, "Assemble to Order");
                        // P80007477
                        SalesLine.GetLotNo;
                        SalesLine.Modify;
                    end;
                    // P80007477
                end;
            DATABASE::"Service Line":
                begin
                    if ServiceLine.Get("Source Subtype", "Source No.", "Source Line No.") then
                        ServiceLineReserve.CallItemTracking(ServiceLine);
                end;
            DATABASE::"Purchase Line":
                begin
                    if PurchaseLine.Get("Source Subtype", "Source No.", "Source Line No.") then begin // P80007477
                        PurchLineReserve.CallItemTracking(PurchaseLine, SecondSourceQtyArray);
                        // P80007477
                        PurchaseLine.GetLotNo;
                        PurchaseLine.Modify;
                    end;
                    // P80007477
                end;
            DATABASE::"Transfer Line":
                begin
                    Direction := Direction::Outbound;
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

    procedure GetATOAndNonATOLines(var ATOWhseShptLine: Record "Warehouse Shipment Line"; var NonATOWhseShptLine: Record "Warehouse Shipment Line"; var ATOLineFound: Boolean; var NonATOLineFound: Boolean)
    var
        WhseShptLine: Record "Warehouse Shipment Line";
    begin
        WhseShptLine.Copy(Rec);
        WhseShptLine.SetSourceFilter("Source Type", "Source Subtype", "Source No.", "Source Line No.", false);

        NonATOWhseShptLine.Copy(WhseShptLine);
        NonATOWhseShptLine.SetRange("Assemble to Order", false);
        NonATOLineFound := NonATOWhseShptLine.FindFirst;

        ATOWhseShptLine.Copy(WhseShptLine);
        ATOWhseShptLine.SetRange("Assemble to Order", true);
        ATOLineFound := ATOWhseShptLine.FindFirst;
    end;

    procedure FullATOPosted(): Boolean
    var
        SalesLine: Record "Sales Line";
        ATOWhseShptLine: Record "Warehouse Shipment Line";
    begin
        if "Source Document" <> "Source Document"::"Sales Order" then
            exit(true);
        SalesLine.SetRange("Document Type", "Source Subtype");
        SalesLine.SetRange("Document No.", "Source No.");
        SalesLine.SetRange("Line No.", "Source Line No.");
        if not SalesLine.FindFirst then
            exit(true);
        if SalesLine."Qty. Shipped (Base)" >= SalesLine."Qty. to Asm. to Order (Base)" then
            exit(true);
        ATOWhseShptLine.SetRange("No.", "No.");
        ATOWhseShptLine.SetSourceFilter("Source Type", "Source Subtype", "Source No.", "Source Line No.", false);
        ATOWhseShptLine.SetRange("Assemble to Order", true);
        ATOWhseShptLine.CalcSums("Qty. to Ship (Base)");
        exit((SalesLine."Qty. Shipped (Base)" + ATOWhseShptLine."Qty. to Ship (Base)") >= SalesLine."Qty. to Asm. to Order (Base)");
    end;

    procedure InitOutstandingQtys()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitOutstandingQtys(Rec, CurrFieldNo, IsHandled);
        if IsHandled then
            exit;

        Validate("Qty. Outstanding", Quantity - "Qty. Shipped");
        "Qty. Outstanding (Base)" := "Qty. (Base)" - "Qty. Shipped (Base)";
    end;

    procedure CatchAlternateUnits(): Boolean
    begin
        // P8000282A
        GetItem;
        exit(Item."Catch Alternate Qtys.");
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

    procedure ValidateLotNo(LotNo: Code[50])
    var
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        TransferLine: Record "Transfer Line";
        P800Functions: Codeunit "Process 800 Functions";
    begin
        // P80073378
        if not P800Functions.TrackingInstalled then
            exit;

        GetSourceDocumentLine(SalesLine, PurchaseLine, TransferLine);
        case "Source Type" of
            DATABASE::"Sales Line":
                SalesLine.Validate("Lot No.", LotNo);
            DATABASE::"Purchase Line":
                PurchaseLine.Validate("Lot No.", LotNo);
            DATABASE::"Transfer Line":
                TransferLine.Validate("Lot No.", LotNo);
        end;
        UpdateLotQuantity(SalesLine, PurchaseLine, TransferLine);
    end;

    procedure AssistEditLotNo(var LotNo: Code[50]): Boolean
    var
        P800Functions: Codeunit "Process 800 Functions";
        P800Globals: Codeunit "Process 800 System Globals";
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        TransferLine: Record "Transfer Line";
        EasyLotTracking: Codeunit "Easy Lot Tracking";
    begin
        // P80073378
        if not P800Functions.TrackingInstalled then
            exit;
        if LotNo = P800Globals.MultipleLotCode then
            exit;

        GetSourceDocumentLine(SalesLine, PurchaseLine, TransferLine);
        case "Source Type" of
            DATABASE::"Sales Line":
                begin
                    SalesLine."Lot No." := LotNo;
                    EasyLotTracking.SetSalesLine(SalesLine);
                    if not EasyLotTracking.AssistEdit(SalesLine."Lot No.") then
                        exit(false);
                end;
            DATABASE::"Purchase Line":
                begin
                    PurchaseLine."Lot No." := LotNo;
                    EasyLotTracking.SetPurchaseLine(PurchaseLine);
                    if not EasyLotTracking.AssistEdit(PurchaseLine."Lot No.") then
                        exit(false);
                end;
            DATABASE::"Transfer Line":
                begin
                    TransferLine."Lot No." := LotNo;
                    EasyLotTracking.SetTransferLine(TransferLine, 0);
                    if not EasyLotTracking.AssistEdit(TransferLine."Lot No.") then
                        exit(false);
                end;
        end;
        UpdateLotQuantity(SalesLine, PurchaseLine, TransferLine);
        exit(true);
    end;

    procedure SetLotQuantity(LotNo: Code[50])
    var
        P800Functions: Codeunit "Process 800 Functions";
        P800Globals: Codeunit "Process 800 System Globals";
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        TransferLine: Record "Transfer Line";
    begin
        // P80073378
        if not P800Functions.TrackingInstalled then
            exit;
        if LotNo = P800Globals.MultipleLotCode then
            exit;

        GetSourceDocumentLine(SalesLine, PurchaseLine, TransferLine);
        UpdateLotQuantity(SalesLine, PurchaseLine, TransferLine);
    end;

    local procedure GetSourceDocumentLine(var SalesLine: Record "Sales Line"; var PurchaseLine: Record "Purchase Line"; var TransferLine: Record "Transfer Line")
    begin
        // P80073378
        case "Source Type" of
            DATABASE::"Sales Line":
                SalesLine.Get("Source Subtype", "Source No.", "Source Line No.");
            DATABASE::"Purchase Line":
                PurchaseLine.Get("Source Subtype", "Source No.", "Source Line No.");
            DATABASE::"Transfer Line":
                TransferLine.Get("Source No.", "Source Line No.");
        end;
    end;

    local procedure UpdateLotQuantity(var SalesLine: Record "Sales Line"; var PurchaseLine: Record "Purchase Line"; var TransferLine: Record "Transfer Line")
    var
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        QtyToShipAlt: Decimal;
    begin
        // P80073378
        if ProcessFns.AltQtyInstalled then
            AltQtyMgmt.WhseShptLineGetData(Rec, QtyToShipAlt);

        case "Source Type" of
            DATABASE::"Sales Line":
                begin
                    SalesLine.Modify(true);
                    SalesLine.WarehouseLineQuantity("Qty. to Ship (Base)", QtyToShipAlt, SalesLine."Qty. to Invoice (Base)"); // P80077569
                    SalesLine.UpdateLotTracking(true, 0);
                end;
            DATABASE::"Purchase Line":
                begin
                    PurchaseLine.Modify(true);
                    PurchaseLine.WarehouseLineQuantity("Qty. to Ship (Base)", QtyToShipAlt, PurchaseLine."Qty. to Invoice (Base)"); // P80077569
                    PurchaseLine.UpdateLotTracking(true);
                end;
            DATABASE::"Transfer Line":
                begin
                    TransferLine.Modify(true);
                    TransferLine.WarehouseLineQuantity("Qty. to Ship (Base)", QtyToShipAlt, 0); // P800108868
                    TransferLine.UpdateLotTracking(true, 0);
                end;
        end;
    end;

    procedure ProcessOverShip(AdditionalQuantity: Variant)
    var
        SalesLine: Record "Sales Line";
        TransferLine: Record "Transfer Line";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        OriginalQty: Decimal;
        QuantityToAdd: Decimal;
    begin
        // P8000372A, P80039781
        // P80039781 - add parameter AdditionalQuantity
        case "Source Type" of
            DATABASE::"Sales Line":
                begin
                    if SalesLine.Get("Source Subtype", "Source No.", "Source Line No.") then begin
                        if AdditionalQuantity.IsDecimal or AdditionalQuantity.IsInteger then
                            QuantityToAdd := AdditionalQuantity
                        else
                            QuantityToAdd := "Qty. to Ship" + GetContainerQuantity(false) - SalesLine."Outstanding Quantity";
                        SalesLine.SuspendStatusCheck(true);
                        OriginalQty := SalesLine."Original Quantity";
                        SalesLine."Allow Quantity Change" := true;
                        SalesLine.Validate(Quantity, Quantity + QuantityToAdd);
                        SalesLine.Validate("Original Quantity", OriginalQty);
                        SalesLine."Allow Quantity Change" := false;
                        SalesLine.UpdateLotTracking(true, 0);
                        SalesLine.Modify;
                    end;
                end;

            DATABASE::"Transfer Line":
                begin
                    if TransferLine.Get("Source No.", "Source Line No.") then begin
                        if AdditionalQuantity.IsDecimal or AdditionalQuantity.IsInteger then
                            QuantityToAdd := AdditionalQuantity
                        else
                            QuantityToAdd := "Qty. to Ship" + GetContainerQuantity(false) - TransferLine."Outstanding Quantity";
                        TransferLine.SuspendStatusCheck(true);
                        TransferLine."Allow Quantity Change" := true;
                        TransferLine.Validate(Quantity, Quantity + QuantityToAdd);
                        TransferLine."Allow Quantity Change" := false;
                        TransferLine.UpdateLotTracking(true, 0);
                        TransferLine.Modify;
                    end;
                end;
        end;

        WarehouseShipmentLine := Rec;
        SuspendStatusCheck(true);
        Validate(Quantity, Quantity + QuantityToAdd);
        "Qty. to Ship" := WarehouseShipmentLine."Qty. to Ship";
        "Qty. to Ship (Base)" := WarehouseShipmentLine."Qty. to Ship (Base)";
        Modify;
    end;

    procedure IsNonWarehouseItem(): Boolean
    begin
        // P8001290
        if ("Item No." <> '') then begin
            GetItem;
            exit(Item."Non-Warehouse Item");
        end;
    end;

    procedure InitNonWarehouseQtys()
    begin
        // P8001290
        if IsNonWarehouseItem() then begin
            "Qty. Picked" := Quantity;
            "Qty. Picked (Base)" := "Qty. (Base)";
            "Qty. to Ship" := "Qty. Outstanding";
            "Qty. to Ship (Base)" := "Qty. Outstanding (Base)";
            "Completely Picked" := true;
            Status := CalcStatusShptLine();
        end;
    end;

    local procedure TestContainerQuantity()
    begin
        // P80046533
        if GetContainerQuantity('') > 0 then
            if "Qty. to Ship" < GetContainerQuantity(true) then // P80046533
                FieldError("Qty. to Ship", Text37002701);
    end;

    procedure GetContainerQuantity(ShipReceive: Variant) QtyToHandle: Decimal
    var
        QtyToHandleBase: Decimal;
        QtyToHandleAlt: Decimal;
    begin
        // P80046533
        GetContainerQuantitiesByDocLine(QtyToHandle, QtyToHandleBase, QtyToHandleAlt, ShipReceive);
    end;

    procedure GetContainerQuantityBase(ShipReceive: Variant) QtyToHandleBase: Decimal
    var
        QtyToHandle: Decimal;
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
        BinStatus.SetMode(1);
        BinContent.SetFilter("Item No.", "Item No.");
        if "Bin Code" <> '' then
            BinContent.SetRange("Bin Code", "Bin Code");
        BinStatus.SetTableView(BinContent);
        BinStatus.Run;
    end;

    procedure GetWhseShptLine(ShipmentNo: Code[20]; SourceType: Integer; SourceSubtype: Option; SourceNo: Code[20]; SourceLineNo: Integer): Boolean
    begin
        SetRange("No.", ShipmentNo);
        SetSourceFilter(SourceType, SourceSubtype, SourceNo, SourceLineNo, false);
        if FindFirst then
            exit(true);
    end;

    procedure CreateWhseItemTrackingLines()
    var
        ATOSalesLine: Record "Sales Line";
        AsmHeader: Record "Assembly Header";
        AsmLineMgt: Codeunit "Assembly Line Management";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        if "Assemble to Order" then begin
            TestField("Source Type", DATABASE::"Sales Line");
            ATOSalesLine.Get("Source Subtype", "Source No.", "Source Line No.");
            ATOSalesLine.AsmToOrderExists(AsmHeader);
            AsmLineMgt.CreateWhseItemTrkgForAsmLines(AsmHeader);
        end else begin
            if ItemTrackingMgt.GetWhseItemTrkgSetup("Item No.") then
                ItemTrackingMgt.InitItemTrackingForTempWhseWorksheetLine(
                  "Warehouse Worksheet Document Type"::Shipment, "No.", "Line No.",
                  "Source Type", "Source Subtype", "Source No.", "Source Line No.", 0);
        end;
    end;

    procedure DeleteWhseItemTrackingLines()
    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        ItemTrackingMgt.DeleteWhseItemTrkgLinesWithRunDeleteTrigger(
          DATABASE::"Warehouse Shipment Line", 0, "No.", '', 0, "Line No.", "Location Code", true, true);
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
    begin
        if SetKey then
            SetCurrentKey("Source Type", "Source Subtype", "Source No.", "Source Line No.");
        SetRange("Source Type", SourceType);
        if SourceSubType >= 0 then
            SetRange("Source Subtype", SourceSubType);
        SetRange("Source No.", SourceNo);
        if SourceLineNo >= 0 then
            SetRange("Source Line No.", SourceLineNo);
    end;

    procedure ClearSourceFilter()
    begin
        SetRange("Source Type");
        SetRange("Source Subtype");
        SetRange("Source No.");
        SetRange("Source Line No.");
    end;

    procedure SuspendStatusCheck(Suspend: Boolean)
    begin
        StatusCheckSuspended := Suspend;
    end;

    local procedure SetQuantityBase(var QuantityBase: Decimal)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSetQuantityBase(Rec, QuantityBase, IsHandled);
        if IsHandled then
            exit;

        // P80039781
        // if "Qty. (Base)" = 0 then
        //     QuantityBase :=
        //         UOMMgt.CalcBaseQty("Item No.", "Variant Code", "Unit of Measure Code", Quantity, "Qty. per Unit of Measure")

        //     QuantityBase := "Qty. Outstanding (Base)";
        if "Qty. Outstanding (Base)" = 0 then
            QuantityBase := 
                UOMMgt.CalcBaseQty("Item No.", "Variant Code", "Unit of Measure Code", "Qty. Outstanding", "Qty. per Unit of Measure");
        // P80039781
    end;

    local procedure MaxQtyToShipBase(QtyToShipBase: Decimal): Decimal
    begin
        if Abs(QtyToShipBase) > Abs("Qty. Outstanding (Base)") then
            exit("Qty. Outstanding (Base)");
        exit(QtyToShipBase);
    end;

    local procedure MaxQtyOutstandingBase(QtyOutstandingBase: Decimal): Decimal
    begin
        if Abs(QtyOutstandingBase + "Qty. Shipped (Base)") > Abs("Qty. (Base)") then
            exit("Qty. (Base)" - "Qty. Shipped (Base)");
        exit(QtyOutstandingBase);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAutofillQtyToHandle(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; var HideValidationDialog: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatePickDoc(var WarehouseShipmentHeader: Record "Warehouse Shipment Header"; var WhseShptLine: Record "Warehouse Shipment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetWhseShptHeader(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; var WarehouseShipmentHeader: Record "Warehouse Shipment Header"; WhseShptNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterOpenItemTrackingLines(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; var SecondSourceQtyArray: array[3] of Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAutoFillQtyToHandleOnBeforeModify(var WarehouseShipmentLine: Record "Warehouse Shipment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAutofillQtyToHandle(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; var HideValidationDialog: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcStatusShptLine(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; var NewStatus: Integer; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckBin(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; var Bin: Record Bin; DeductCubage: Decimal; DeductWeight: Decimal; IgnoreErrors: Boolean; var ErrorOccured: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckSourceDocLineQty(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreatePickDoc(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; WarehouseShipmentHeader: Record "Warehouse Shipment Header"; HideValidationDialog: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCompareQtyToShipAndOutstandingQty(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCompareShipAndPickQty(WarehouseShipmentLine: Record "Warehouse Shipment Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitOutstandingQtys(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOpenItemTrackingLines(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestReleased(var WhseShptHeader: Record "Warehouse Shipment Header"; var StatusCheckSuspended: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateDocumentStatus(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateQtyToShipBase(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; xWarehouseShipmentLine: Record "Warehouse Shipment Line"; CallingFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckSourceDocLineQtyOnBeforeFieldError(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; WhseQtyOutstandingBase: Decimal; var QtyOutstandingBase: Decimal; QuantityBase: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckSourceDocLineQtyOnCaseSourceType(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; WhseQtyOutstandingBase: Decimal; var QtyOutstandingBase: Decimal; QuantityBase: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateQuantityStatusUpdate(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; xWarehouseShipmentLine: Record "Warehouse Shipment Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeleteQtyToHandleOnBeforeModify(var WhseShptLine: Record "Warehouse Shipment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreatePickDocOnBeforeCreatePickDoc(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; var WhseShptLine: Record "Warehouse Shipment Line"; var WhseShptHeader2: Record "Warehouse Shipment Header"; HideValidationDialog: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteQtyToHandle(var WhseShptLine: Record "Warehouse Shipment Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetQuantityBase(var Rec: Record "Warehouse Shipment Line"; var QuantityBase: Decimal; var IsHandled: Boolean)
    begin
    end;
}

