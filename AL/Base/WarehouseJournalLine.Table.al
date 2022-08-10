table 7311 "Warehouse Journal Line"
{
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 05 SEP 06
    //   Staged Picks
    // 
    // PRW15.00.01
    // P8000591A, VerticalSoft, Don Bresee, 13 MAR 08
    //   Add New fields - Quantity (Alt.), Quantity (Absolute, Alt.)
    // 
    // P8000592A, VerticalSoft, Don Bresee, 13 MAR 08
    //   Add Lot No. lookup logic
    // 
    // PRW15.00.03
    // P8000630A, VerticalSoft, Don Bresee, 17 SEP 08
    //   Add Delivery Trip & Delivery Trip Pick to Whse. Document Type
    // 
    // PRW16.00.05
    // P8000980, Columbus IT, Jack Reynolds, 15 SEP 11
    //   Fix problem with mo alternate quantity for fixed weight items
    // 
    // PRW16.00.06
    // P8001082, Columbus IT, Don Bresee, 23 JAN 13
    //   Added Pre-Process to Source Document options
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 17 MAR 16
    //   Incorporate modifications for NAV Anywhere processes
    // 
    // PRW19.00
    // P8007272, To-Increase, Jack Reynolds, 17 JUN 16
    //   Problem with catch weight for physical count
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW110.0.01
    // P80041722, To-Increase, Dayakar Battini, 13 JUN 17
    //   Fix issue with bin code validation for Zone code
    // 
    // P80041932, To-Increase, Dayakar Battini, 20 JUN 17
    //   Add logic for Expiration Date on Whse. Jnl line
    // 
    // P80043725, To-Increase, Dayakar Battini, 17 JUL 17
    //   Item information updation on item validation.
    // 
    // PRW110.0.02
    // P80048582, To-Increase, Dayakar Battini, 09 NOV 17
    //   Restructure the whse. Item tracking creation to avoid permission errors
    // 
    // P80051629, To-Increase, Dayakar Battini, 10 JAN 18
    //   Fix issue for Bin code and Zone code validation with respect to conainer license plate
    // 
    // P80056356, To-Increase, Dayakar Battini, 30 MAR 18
    //   Fix issue for "Qty. (Alt.) (Calculated)" updation
    // 
    // PRW111.00.01
    // P80058977, To-Increase, Dayakar Battini, 15 MAY 18
    //   Fix issue for calculate inventory for fixed weight containerized items
    // 
    // PRW111.00.02
    // P80069310, Gangabhushan, 25 JAN 19
    //   TI-12635 - Whse. Reclass Journal registration for containerized catchweight fails with New Lot No. reuired error
    //
    // PRW111.00.03
    //   P80092144,To-Increase, Gangabhushan, 27 JAN 20
    //     In warehouse Physical Inventory Journal system not allow to Register when container information added.
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // PRW118.01
    // P800128960, To Increase, Jack Reynolds, 24 AUG 21
    //   Decimal precision on alternate quantity data entry

    Caption = 'Warehouse Journal Line';
    DrillDownPageID = "Warehouse Journal Lines";
    LookupPageID = "Warehouse Journal Lines";

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Warehouse Journal Template";
        }
        field(2; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Warehouse Journal Batch".Name WHERE("Journal Template Name" = FIELD("Journal Template Name"));
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; "Registering Date"; Date)
        {
            Caption = 'Registering Date';

            trigger OnValidate()
            begin
                CheckMoveContainer(FieldCaption("Registering Date")); // P8001323
            end;
        }
        field(5; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(6; "From Zone Code"; Code[10])
        {
            Caption = 'From Zone Code';
            TableRelation = Zone.Code WHERE("Location Code" = FIELD("Location Code"));

            trigger OnValidate()
            begin
                CheckMoveContainer(FieldCaption("From Zone Code")); // P8001323
                // P8001323
                //IF NOT PhysInvtEntered THEN
                //  TESTFIELD("Phys. Inventory",FALSE);
                if "Phys. Inventory" and ("Qty. (Calculated)" <> 0) then
                    FieldError("Qty. (Calculated)", Text37002009);
                // P8001323

                if "From Zone Code" <> xRec."From Zone Code" then begin
                    "From Bin Code" := '';
                    "From Bin Type Code" := '';
                    "From Container License Plate" := ''; // P8001323
                    "From Container ID" := '';    // P8001323
                end;
            end;
        }
        field(7; "From Bin Code"; Code[20])
        {
            Caption = 'From Bin Code';
            TableRelation = IF ("Phys. Inventory" = CONST(false),
                                "Item No." = FILTER(''),
                                "From Zone Code" = FILTER('')) "Bin Content"."Bin Code" WHERE("Location Code" = FIELD("Location Code"))
            ELSE
            IF ("Phys. Inventory" = CONST(false),
                                         "Item No." = FILTER(<> ''),
                                         "From Zone Code" = FILTER('')) "Bin Content"."Bin Code" WHERE("Location Code" = FIELD("Location Code"),
                                                                                                      "Item No." = FIELD("Item No."))
            ELSE
            IF ("Phys. Inventory" = CONST(false),
                                                                                                               "Item No." = FILTER(''),
                                                                                                               "From Zone Code" = FILTER(<> '')) "Bin Content"."Bin Code" WHERE("Location Code" = FIELD("Location Code"),
                                                                                                                                                                              "Zone Code" = FIELD("From Zone Code"))
            ELSE
            IF ("Phys. Inventory" = CONST(false),
                                                                                                                                                                                       "Item No." = FILTER(<> ''),
                                                                                                                                                                                       "From Zone Code" = FILTER(<> '')) "Bin Content"."Bin Code" WHERE("Location Code" = FIELD("Location Code"),
                                                                                                                                                                                                                                                      "Item No." = FIELD("Item No."),
                                                                                                                                                                                                                                                      "Zone Code" = FIELD("From Zone Code"))
            ELSE
            IF ("Phys. Inventory" = CONST(true),
                                                                                                                                                                                                                                                               "From Zone Code" = FILTER('')) Bin.Code WHERE("Location Code" = FIELD("Location Code"))
            ELSE
            IF ("Phys. Inventory" = CONST(true),
                                                                                                                                                                                                                                                                        "From Zone Code" = FILTER(<> '')) Bin.Code WHERE("Location Code" = FIELD("Location Code"),
                                                                                                                                                                                                                                                                                                                       "Zone Code" = FIELD("From Zone Code"));

            trigger OnLookup()
            begin
                LookupFromBinCode;
            end;

            trigger OnValidate()
            begin
                CheckMoveContainer(FieldCaption("From Bin Code")); // P8001323

                // P8001323
                //IF NOT PhysInvtEntered THEN
                //  TESTFIELD("Phys. Inventory",FALSE);
                if "Phys. Inventory" and ("Qty. (Calculated)" <> 0) then
                    FieldError("Qty. (Calculated)", Text37002009);
                // P8001323

                if CurrFieldNo = FieldNo("From Bin Code") then
                    if "From Bin Code" <> xRec."From Bin Code" then
                        CheckBin("Location Code", "From Bin Code", false);

                "From Bin Type Code" :=
                  GetBinType("Location Code", "From Bin Code");

                Bin.CalcFields("Adjustment Bin");
                if Bin."Adjustment Bin" and ("Entry Type" <> "Entry Type"::"Positive Adjmt.") then
                    Bin.FieldError("Adjustment Bin");

                if "From Bin Code" <> '' then
                    "From Zone Code" := Bin."Zone Code";

                if "Entry Type" = "Entry Type"::"Negative Adjmt." then
                    SetUpAdjustmentBin;

                // P8001323
                if (CurrFieldNo = FieldNo("From Bin Code")) and ("From Bin Code" <> xRec."From Bin Code") then begin
                    "From Container License Plate" := '';
                    "From Container ID" := '';
                end;
            end;
        }
        field(8; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(9; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item WHERE(Type = FILTER(Inventory | FOODContainer));

            trigger OnValidate()
            begin
                CheckMoveContainer(FieldCaption("Item No.")); // P8001323

                // P8001323
                //IF NOT PhysInvtEntered THEN
                //  TESTFIELD("Phys. Inventory",FALSE);
                if "Phys. Inventory" and ("Qty. (Calculated)" <> 0) then
                    FieldError("Qty. (Calculated)", Text37002009);
                // P8001323

                SetItemFields();

                // P8001323
                if (CurrFieldNo = FieldNo("Item No.")) and ("Item No." <> xRec."Item No.") then begin
                    CheckFromContainer;
                    CheckToContainer;
                end;
                // P8001323

                InitAlternateQty; // P8000591A
            end;
        }
        field(10; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            var
                WhseItemTrackingSetup: Record "Item Tracking Setup";
            begin
                CheckMoveContainer(FieldCaption(Quantity)); // P8001323

                if (CurrFieldNo = FieldNo(Quantity)) and (not PhysInvtEntered) then // P8001323
                    TestField("Phys. Inventory", false);                               // P8001323

                WhseJnlTemplate.Get("Journal Template Name");
                if WhseJnlTemplate.Type = WhseJnlTemplate.Type::Reclassification then begin
                    if Quantity < 0 then
                        FieldError(Quantity, Text000);
                end else begin
                    GetLocation("Location Code");
                    Location.TestField("Adjustment Bin Code");
                end;

                Quantity := UOMMgt.RoundAndValidateQty(Quantity, "Qty. Rounding Precision", FieldCaption(Quantity));
                "Qty. (Base)" := CalcBaseQty(Quantity, FieldCaption(Quantity), FieldCaption("Qty. (Base)"));
                OnValidateQuantityOnAfterCalcBaseQty(Rec, xRec);

                "Qty. (Absolute)" := Abs(Quantity);
                "Qty. (Absolute, Base)" := Abs("Qty. (Base)");
                if (xRec.Quantity < 0) and (Quantity >= 0) or
                   (xRec.Quantity >= 0) and (Quantity < 0)
                then
                    ExchangeFromToBin;

                if Quantity > 0 then
                    WMSMgt.CalcCubageAndWeight(
                      "Item No.", "Unit of Measure Code", "Qty. (Absolute)", Cubage, Weight)
                else begin
                    Cubage := 0;
                    Weight := 0;
                end;

                if Quantity <> xRec.Quantity then begin
                    CheckBin("Location Code", "From Bin Code", false);
                    CheckBin("Location Code", "To Bin Code", true);
                end;

                ItemTrackingMgt.GetWhseItemTrkgSetup("Item No.", WhseItemTrackingSetup);
                if WhseItemTrackingSetup."Serial No. Required" and not "Phys. Inventory" and ("Serial No." <> '') then
                    CheckSerialNoTrackedQuantity();

                InitAlternateQty; // P8000591A
                                  // P80041932
                if (CurrFieldNo in [FIELDNO(Quantity), FIELDNO("Qty. (Base)"), FIELDNO("Qty. (Phys. Inventory)")]) and ("Lot No." <> xRec."Lot No.") then // P80092144
                    UpdateLotInfo;
                // P80041932
            end;
        }
        field(11; "Qty. (Base)"; Decimal)
        {
            Caption = 'Qty. (Base)';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateQtyBase(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                TestField("Qty. per Unit of Measure", 1);
                Validate(Quantity, "Qty. (Base)");
            end;
        }
        field(12; "Qty. (Absolute)"; Decimal)
        {
            Caption = 'Qty. (Absolute)';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                if not PhysInvtEntered then
                    TestField("Phys. Inventory", false);

                "Qty. (Absolute, Base)" :=
                    CalcBaseQty("Qty. (Absolute)", FieldCaption("Qty. (Absolute)"), FieldCaption("Qty. (Absolute, Base)"));

                if Quantity > 0 then
                    WMSMgt.CalcCubageAndWeight(
                      "Item No.", "Unit of Measure Code", "Qty. (Absolute)", Cubage, Weight)
                else begin
                    Cubage := 0;
                    Weight := 0;
                end;
            end;
        }
        field(13; "Qty. (Absolute, Base)"; Decimal)
        {
            Caption = 'Qty. (Absolute, Base)';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            var
                NewValue: Decimal;
            begin
                NewValue := Round("Qty. (Absolute, Base)", UOMMgt.QtyRndPrecision);
                Validate(Quantity, CalcQty("Qty. (Absolute, Base)") * Quantity / Abs(Quantity));
                // Take care of rounding issues
                "Qty. (Absolute, Base)" := NewValue;
                "Qty. (Base)" := NewValue * "Qty. (Base)" / Abs("Qty. (Base)");
            end;
        }
        field(14; "Zone Code"; Code[10])
        {
            Caption = 'Zone Code';
            TableRelation = Zone.Code WHERE("Location Code" = FIELD("Location Code"));

            trigger OnValidate()
            begin
                // P8001323
                //IF NOT PhysInvtEntered THEN
                //  TESTFIELD("Phys. Inventory",FALSE);
                if "Phys. Inventory" and ("Qty. (Calculated)" <> 0) then
                    FieldError("Qty. (Calculated)", Text37002009);
                // P8001323

                if "Zone Code" <> xRec."Zone Code" then begin // P8001323
                    "Bin Code" := '';
                    if CurrFieldNo = FieldNo("Zone Code") then  // P80051629
                        "Container License Plate" := '';            // P8001323
                end;                                        // P8001323

                if Quantity < 0 then
                    Validate("From Zone Code", "Zone Code")
                else
                    Validate("To Zone Code", "Zone Code");
            end;
        }
        field(15; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = IF ("Zone Code" = FILTER('')) Bin.Code WHERE("Location Code" = FIELD("Location Code"))
            ELSE
            IF ("Zone Code" = FILTER(<> '')) Bin.Code WHERE("Location Code" = FIELD("Location Code"),
                                                                               "Zone Code" = FIELD("Zone Code"));

            trigger OnLookup()
            begin
                LookupBinCode;
            end;

            trigger OnValidate()
            begin
                // P8001323
                //IF NOT PhysInvtEntered THEN
                //  TESTFIELD("Phys. Inventory",FALSE);
                if "Phys. Inventory" and ("Qty. (Calculated)" <> 0) then
                    FieldError("Qty. (Calculated)", Text37002009);
                // P8001323

                if Quantity < 0 then begin
                    Validate("From Bin Code", "Bin Code");
                    if "Bin Code" <> xRec."Bin Code" then
                        CheckBin("Location Code", "Bin Code", false);
                end else begin
                    Validate("To Bin Code", "Bin Code");
                    if "Bin Code" <> xRec."Bin Code" then
                        CheckBin("Location Code", "Bin Code", true);
                end;

                if "Bin Code" <> '' then begin  // P80041722
                    GetBin("Location Code", "Bin Code");
                    "Zone Code" := Bin."Zone Code";
                    if CurrFieldNo = FieldNo("Bin Code") then // P80051629
                        "Container License Plate" := ''; // P8001323
                end;

                // P8001323
                if "Phys. Inventory" and (CurrFieldNo in [FieldNo("Bin Code"), FieldNo("Zone Code")]) then begin
                    "Container License Plate" := '';
                    "To Container License Plate" := '';
                    "To Container ID" := '';
                end;
                // P8001323
            end;
        }
        field(20; "Source Type"; Integer)
        {
            Caption = 'Source Type';
            Editable = false;
        }
        field(21; "Source Subtype"; Option)
        {
            Caption = 'Source Subtype';
            Editable = false;
            OptionCaption = '0,1,2,3,4,5,6,7,8,9,10';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9","10";
        }
        field(22; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            Editable = false;
        }
        field(23; "Source Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Source Line No.';
            Editable = false;
        }
        field(24; "Source Subline No."; Integer)
        {
            BlankZero = true;
            Caption = 'Source Subline No.';
            Editable = false;
        }
        field(25; "Source Document"; Enum "Warehouse Journal Source Document")
        {
            BlankZero = true;
            Caption = 'Source Document';
            Editable = false;
        }
        field(26; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            Editable = false;
            TableRelation = "Source Code";
        }
        field(27; "To Zone Code"; Code[10])
        {
            Caption = 'To Zone Code';
            TableRelation = Zone.Code WHERE("Location Code" = FIELD("Location Code"));

            trigger OnValidate()
            begin
                // P8001323
                //IF NOT PhysInvtEntered THEN
                //  TESTFIELD("Phys. Inventory",FALSE);
                if "Phys. Inventory" and ("Qty. (Calculated)" <> 0) then
                    FieldError("Qty. (Calculated)", Text37002009);
                // P8001323

                if "To Zone Code" <> xRec."To Zone Code" then begin // P8001323
                    "To Bin Code" := '';
                    // P8001323
                    if "Container Master Line No." = 0 then begin
                        "To Container License Plate" := '';
                        "To Container ID" := '';
                    end else
                        UpdateWhseJnlLineForContainer(FieldNo("To Zone Code"));
                end;
                // P8001323
            end;
        }
        field(28; "To Bin Code"; Code[20])
        {
            Caption = 'To Bin Code';
            TableRelation = IF ("To Zone Code" = FILTER('')) Bin.Code WHERE("Location Code" = FIELD("Location Code"))
            ELSE
            IF ("To Zone Code" = FILTER(<> '')) Bin.Code WHERE("Location Code" = FIELD("Location Code"),
                                                                                  "Zone Code" = FIELD("To Zone Code"));

            trigger OnValidate()
            begin
                // P8001323
                //IF NOT PhysInvtEntered THEN
                //  TESTFIELD("Phys. Inventory",FALSE);
                if "Phys. Inventory" and ("Qty. (Calculated)" <> 0) then
                    FieldError("Qty. (Calculated)", Text37002009);
                // P8001323

                if CurrFieldNo = FieldNo("To Bin Code") then
                    if "To Bin Code" <> xRec."To Bin Code" then
                        CheckBin("Location Code", "To Bin Code", true);

                GetBin("Location Code", "To Bin Code");

                Bin.CalcFields("Adjustment Bin");
                if Bin."Adjustment Bin" and ("Entry Type" <> "Entry Type"::"Negative Adjmt.") then
                    Bin.FieldError("Adjustment Bin");

                OnValidateToBinCodeOnBeforeSetToZoneCode(Rec, Bin);

                if "To Bin Code" <> '' then
                    "To Zone Code" := Bin."Zone Code";

                if "Entry Type" = "Entry Type"::"Positive Adjmt." then
                    SetUpAdjustmentBin;

                // P8001323
                if (CurrFieldNo = FieldNo("To Bin Code")) and ("To Bin Code" <> xRec."To Bin Code") then begin
                    if "Container Master Line No." = 0 then begin
                        "To Container License Plate" := '';
                        "To Container ID" := '';
                    end else
                        UpdateWhseJnlLineForContainer(FieldNo("To Bin Code"));
                end;
                // P8001323
            end;
        }
        field(29; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";

            trigger OnValidate()
            begin
                UpdateWhseJnlLineForContainer(FieldNo("Reason Code")); // P8001323
            end;
        }
        field(33; "Registering No. Series"; Code[20])
        {
            Caption = 'Registering No. Series';
            TableRelation = "No. Series";
        }
        field(35; "From Bin Type Code"; Code[10])
        {
            Caption = 'From Bin Type Code';
            TableRelation = "Bin Type";
        }
        field(40; Cubage; Decimal)
        {
            Caption = 'Cubage';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(41; Weight; Decimal)
        {
            Caption = 'Weight';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(50; "Whse. Document No."; Code[20])
        {
            Caption = 'Whse. Document No.';

            trigger OnValidate()
            begin
                CheckMoveContainer(FieldCaption("Whse. Document No.")); // P8001323
            end;
        }
        field(51; "Whse. Document Type"; Enum "Warehouse Journal Document Type")
        {
            Caption = 'Whse. Document Type';
        }
        field(52; "Whse. Document Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Whse. Document Line No.';
        }
        field(53; "Qty. (Calculated)"; Decimal)
        {
            Caption = 'Qty. (Calculated)';
            DecimalPlaces = 0 : 5;
            Editable = false;

            trigger OnValidate()
            begin
                Validate("Qty. (Phys. Inventory)");
            end;
        }
        field(54; "Qty. (Phys. Inventory)"; Decimal)
        {
            Caption = 'Qty. (Phys. Inventory)';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                TestField("Phys. Inventory", true);
                TestField("Shipping Container", false); // P8001323

                CheckQtyPhysInventory();

                PhysInvtEntered := true;
                Quantity := 0;
                Validate(Quantity, "Qty. (Phys. Inventory)" - "Qty. (Calculated)");
                if "Qty. (Phys. Inventory)" = "Qty. (Calculated)" then
                    Validate("Qty. (Phys. Inventory) (Base)", "Qty. (Calculated) (Base)")
                else
                    Validate("Qty. (Phys. Inventory) (Base)", Round("Qty. (Phys. Inventory)" * "Qty. per Unit of Measure", UOMMgt.QtyRndPrecision));
                PhysInvtEntered := false;

                // P8004516
                Item.Get("Item No.");
                if Item.TrackAlternateUnits() then begin // P8007272
                    if "Qty. (Phys. Inventory)" = "Qty. (Calculated)" then
                        "Qty. (Alt.) (Phys. Inventory)" := "Qty. (Alt.) (Calculated)"
                    else
                        "Qty. (Alt.) (Phys. Inventory)" := Round("Qty. (Phys. Inventory) (Base)" * Item.AlternateQtyPerBase(), 0.00001);
                    "Quantity (Alt.)" := "Qty. (Alt.) (Phys. Inventory)" - "Qty. (Alt.) (Calculated)";
                    "Quantity (Absolute, Alt.)" := Abs("Quantity (Alt.)");
                end;
                // P8004516
            end;
        }
        field(55; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'Negative Adjmt.,Positive Adjmt.,Movement';
            OptionMembers = "Negative Adjmt.","Positive Adjmt.",Movement;
        }
        field(56; "Phys. Inventory"; Boolean)
        {
            Caption = 'Phys. Inventory';
            Editable = false;
        }
        field(60; "Reference Document"; Option)
        {
            Caption = 'Reference Document';
            OptionCaption = ' ,Posted Rcpt.,Posted P. Inv.,Posted Rtrn. Rcpt.,Posted P. Cr. Memo,Posted Shipment,Posted S. Inv.,Posted Rtrn. Shipment,Posted S. Cr. Memo,Posted T. Receipt,Posted T. Shipment,Item Journal,Prod.,Put-away,Pick,Movement,BOM Journal,Job Journal,Assembly';
            OptionMembers = " ","Posted Rcpt.","Posted P. Inv.","Posted Rtrn. Rcpt.","Posted P. Cr. Memo","Posted Shipment","Posted S. Inv.","Posted Rtrn. Shipment","Posted S. Cr. Memo","Posted T. Receipt","Posted T. Shipment","Item Journal","Prod.","Put-away",Pick,Movement,"BOM Journal","Job Journal",Assembly;
        }
        field(61; "Reference No."; Code[20])
        {
            Caption = 'Reference No.';
        }
        field(67; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(68; "Qty. (Calculated) (Base)"; Decimal)
        {
            Caption = 'Qty. (Calculated) (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(69; "Qty. (Phys. Inventory) (Base)"; Decimal)
        {
            Caption = 'Qty. (Phys. Inventory) (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;

            trigger OnValidate()
            begin
                "Qty. (Base)" := "Qty. (Phys. Inventory) (Base)" - "Qty. (Calculated) (Base)";
                "Qty. (Absolute, Base)" := Abs("Qty. (Base)");
            end;
        }
        field(5402; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            var
                ItemVariant: Record "Item Variant";
            begin
                CheckMoveContainer(FieldCaption("Variant Code")); // P8001323

                // P8001323
                //IF NOT PhysInvtEntered THEN
                //  TESTFIELD("Phys. Inventory",FALSE);
                if "Phys. Inventory" and ("Qty. (Calculated)" <> 0) then
                    FieldError("Qty. (Calculated)", Text37002009);
                // P8001323

                if "Variant Code" <> '' then begin
                    ItemVariant.Get("Item No.", "Variant Code");
                    Description := ItemVariant.Description;
                end else
                    GetItem("Item No.", Description);

                if "Variant Code" <> xRec."Variant Code" then begin
                    CheckBin("Location Code", "From Bin Code", false);
                    CheckBin("Location Code", "To Bin Code", true);
                    // P8001323
                    if CurrFieldNo = FieldNo("Variant Code") then
                        CheckFromContainer;
                    // P8001323
                end;
            end;
        }
        field(5404; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
        }
        field(5407; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                CheckMoveContainer(FieldCaption("Unit of Measure Code")); // P8001323

                // P8001323
                //IF NOT PhysInvtEntered THEN
                //  TESTFIELD("Phys. Inventory",FALSE);
                if "Phys. Inventory" and ("Qty. (Calculated)" <> 0) then
                    FieldError("Qty. (Calculated)", Text37002009);
                // P8001323

                if "Item No." <> '' then begin
                    TestField("Unit of Measure Code");
                    GetItemUnitOfMeasure;
                    "Qty. per Unit of Measure" := ItemUnitOfMeasure."Qty. per Unit of Measure";
                    "Qty. Rounding Precision" := UOMMgt.GetQtyRoundingPrecision(Item, "Unit of Measure Code");
                    "Qty. Rounding Precision (Base)" := UOMMgt.GetQtyRoundingPrecision(Item, Item."Base Unit of Measure");
                    CheckBin("Location Code", "From Bin Code", false);
                    CheckBin("Location Code", "To Bin Code", true);
                end else
                    "Qty. per Unit of Measure" := 1;

                IsHandled := false;
                OnValidateUnitOfMeasureCodeOnBeforeValidateQuantity(Rec, IsHandled);
                if not IsHandled then
                    Validate(Quantity);

                // P8001323
                if (CurrFieldNo = FieldNo("Unit of Measure Code")) and ("Unit of Measure Code" <> xRec."Unit of Measure Code") then begin
                    CheckFromContainer;
                    CheckToContainer;
                end;
                // P8001323
            end;
        }
        field(5408; "Qty. Rounding Precision"; Decimal)
        {
            Caption = 'Qty. Rounding Precision';
            InitValue = 0;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 1;
            Editable = false;
        }
        field(5409; "Qty. Rounding Precision (Base)"; Decimal)
        {
            Caption = 'Qty. Rounding Precision (Base)';
            InitValue = 0;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 1;
            Editable = false;
        }
        field(6500; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';

            trigger OnLookup()
            begin
                // ItemTrackingMgt.LookupTrackingNoInfo("Item No.", "Variant Code", ItemTrackingType::"Serial No.", "Serial No.");// P8000592A
                LookUpTrackingSummary(true, -1, 0);                                                 // P8000592A
            end;

            trigger OnValidate()
            begin
                CheckMoveContainer(FieldCaption("Serial No.")); // P8001323

                if "Serial No." <> '' then
                    ItemTrackingMgt.CheckWhseItemTrkgSetup("Item No.");

                CheckSerialNoTrackedQuantity();

                // P8001323
                if (CurrFieldNo = FieldNo("Serial No.")) and ("Serial No." <> xRec."Serial No.") then
                    CheckFromContainer;
                // P8001323
            end;
        }
        field(6501; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';

            trigger OnLookup()
            begin
                // ItemTrackingMgt.LookupTrackingNoInfo("Item No.", "Variant Code", ItemTrackingType::"Lot No.", "Lot No."); // P8000592A
                LookUpTrackingSummary(true, -1, 1);                                              // P8000592A
                Validate("Lot No.");    // P80041932
            end;

            trigger OnValidate()
            begin
                CheckMoveContainer(FieldCaption("Lot No.")); // P8001323

                if "Lot No." <> '' then
                    ItemTrackingMgt.CheckWhseItemTrkgSetup("Item No.");

                // P8001323
                if (CurrFieldNo = FieldNo("Lot No.")) and ("Lot No." <> xRec."Lot No.") then begin
                    CheckFromContainer;
                    CheckToContainer;
                end;
                // P8001323
                // P80041932
                // if (CurrFieldNo = FieldNo("Lot No.")) and ("Lot No." <> xRec."Lot No.") then // P800-MegaApp
                UpdateLotInfo;
                // P80041932
            end;
        }
        field(6502; "Warranty Date"; Date)
        {
            Caption = 'Warranty Date';
            Editable = false;
        }
        field(6503; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
            Editable = false;

            trigger OnValidate()
            var
                LotNoInformation: Record "Lot No. Information";
            begin
                // P80041932
                if LotNoInformation.Get("Item No.", "Variant Code", "Lot No.") then begin
                    LotNoInformation.CalcFields(Inventory);
                    if LotNoInformation.Inventory <> 0 then
                        TestField("Expiration Date", LotNoInformation."Expiration Date");
                end;
                // P80041932
            end;
        }
        field(6504; "New Serial No."; Code[50])
        {
            Caption = 'New Serial No.';
            Editable = false;
        }
        field(6505; "New Lot No."; Code[50])
        {
            Caption = 'New Lot No.';
            Editable = false;
        }
        field(6506; "New Expiration Date"; Date)
        {
            Caption = 'New Expiration Date';
            Editable = false;
        }
        field(6515; "Package No."; Code[50])
        {
            Caption = 'Package No.';
            CaptionClass = '6,1';

            trigger OnLookup()
            begin
                ItemTrackingMgt.LookupTrackingNoInfo("Item No.", "Variant Code", "Item Tracking Type"::"Package No.", "Package No.");
            end;

            trigger OnValidate()
            begin
                if "Package No." <> '' then
                    ItemTrackingMgt.CheckWhseItemTrkgSetup("Item No.");
            end;
        }
        field(6516; "New Package No."; Code[50])
        {
            Caption = 'New Package No.';
            CaptionClass = '6,2';
            Editable = false;
        }
        field(7380; "Phys Invt Counting Period Code"; Code[10])
        {
            Caption = 'Phys Invt Counting Period Code';
            Editable = false;
            TableRelation = "Phys. Invt. Counting Period";
        }
        field(7381; "Phys Invt Counting Period Type"; Option)
        {
            AccessByPermission = TableData "Phys. Invt. Item Selection" = R;
            Caption = 'Phys Invt Counting Period Type';
            Editable = false;
            OptionCaption = ' ,Item,SKU';
            OptionMembers = " ",Item,SKU;
        }
        field(37002080; "Quantity (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            AutoFormatExpression = "Item No.";
            AutoFormatType = 37002080;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,0,0,%1', "Item No.");
            Caption = 'Quantity (Alt.)';
            Description = 'P8000591A';

            trigger OnValidate()
            begin
                // P8000591A
                CheckMoveContainer(FieldCaption("Quantity (Alt.)")); // P8001323

                if (CurrFieldNo = FieldNo("Quantity (Alt.)")) and (not PhysInvtEntered) then // P8004516
                    TestField("Phys. Inventory", false);                                        // P8004516

                TestField("Item No.");
                Item.Get("Item No.");
                Item.TestField("Alternate Unit of Measure");

                "Quantity (Absolute, Alt.)" := Abs("Quantity (Alt.)");

                if (CurrFieldNo = FieldNo("Quantity (Alt.)")) then begin
                    Item.TestField("Catch Alternate Qtys.", true);
                    TestField("Quantity (Alt.)");
                    AltQtyMgmt.CheckSummaryTolerance1(
                      0, "Item No.", FieldCaption("Quantity (Alt.)"), "Qty. (Base)", "Quantity (Alt.)");
                end;
                // P8000591A
            end;
        }
        field(37002081; "Quantity (Absolute, Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            BlankZero = true;
            Caption = 'Quantity (Absolute, Alt.)';
            DecimalPlaces = 0 : 5;
            Description = 'P8000591A';
        }
        field(37002082; "Qty. (Alt.) (Calculated)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            Caption = 'Qty. (Alt.) (Calculated)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(37002083; "Qty. (Alt.) (Phys. Inventory)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            AutoFormatExpression = "Item No.";
            AutoFormatType = 37002080;
            Caption = 'Qty. (Alt.) (Phys. Inventory)';

            trigger OnValidate()
            begin
                // P8001323
                TestField("Phys. Inventory", true);
                if (CurrFieldNo = FieldNo("Qty. (Alt.) (Phys. Inventory)")) then // P8007272
                    TestField("Container License Plate"); // P8004516
                TestField("Shipping Container", false);

                TestField("Item No.");
                Item.Get("Item No.");
                //Item.TESTFIELD("Catch Alternate Qtys.");  // P80058977

                if (CurrFieldNo = FieldNo("Qty. (Alt.) (Phys. Inventory)")) then begin
                    Item.TestField("Catch Alternate Qtys.", true);
                    AltQtyMgmt.CheckSummaryTolerance1(
                      0, "Item No.", FieldCaption("Qty. (Alt.) (Phys. Inventory)"), "Qty. (Phys. Inventory)" * "Qty. per Unit of Measure", "Qty. (Alt.) (Phys. Inventory)");
                end;

                Validate("Quantity (Alt.)", "Qty. (Alt.) (Phys. Inventory)" - "Qty. (Alt.) (Calculated)");
            end;
        }
        field(37002560; "Container License Plate"; Code[50])
        {
            AccessByPermission = TableData "Container Header" = R;
            Caption = 'Container License Plate';

            trigger OnValidate()
            begin
                // P8001323
                if "Phys. Inventory" and ("Qty. (Calculated)" <> 0) then
                    FieldError("Qty. (Calculated)", Text37002009);

                if Quantity < 0 then
                    Validate("From Container License Plate", "Container License Plate")
                else
                    Validate("To Container License Plate", "Container License Plate");
            end;
        }
        field(37002561; "From Container License Plate"; Code[50])
        {
            AccessByPermission = TableData "Container Header" = R;
            Caption = 'From Container License Plate';

            trigger OnValidate()
            var
                ContainerHeader: Record "Container Header";
                ContainerLine: Record "Container Line";
                ItemNo: Code[20];
                VariantCode: Code[10];
                LotNo: Code[50];
                UOMCode: Code[10];
            begin
                // P8001323
                CheckMoveContainer(FieldCaption("From Container License Plate")); // P8001323

                if "From Container License Plate" <> xRec."From Container License Plate" then
                    if "From Container License Plate" = '' then
                        "From Container ID" := ''
                    else begin
                        ContainerHeader.SetRange("License Plate", "From Container License Plate");
                        ContainerHeader.SetRange("Location Code", "Location Code");
                        if "Bin Code" <> '' then
                            ContainerHeader.SetRange("Bin Code", "Bin Code");
                        ContainerHeader.SetRange(Inbound, false);
                        ContainerHeader.FindFirst;

                        if ContainerHeader."Document Type" <> 0 then
                            Error(Text37002007, ContainerHeader.DocumentType, ContainerHeader."Document No.");

                        "From Container ID" := ContainerHeader.ID;
                        CheckFromContainer;

                        ContainerLine.SetRange("Container ID", "From Container ID");
                        if ContainerLine.FindFirst then begin
                            if "Item No." = '' then begin
                                ContainerLine.SetFilter("Item No.", '<>%1', ContainerLine."Item No.");
                                if ContainerLine.IsEmpty then
                                    ItemNo := ContainerLine."Item No.";
                                ContainerLine.SetRange("Item No.", ItemNo);
                            end else
                                ContainerLine.SetRange("Item No.", "Item No.");

                            if ("Item No." <> '') or (ItemNo <> '') then begin
                                if "Variant Code" = '' then begin
                                    ContainerLine.SetFilter("Variant Code", '<>%1', ContainerLine."Variant Code");
                                    if ContainerLine.IsEmpty then
                                        VariantCode := ContainerLine."Variant Code";
                                    ContainerLine.SetRange("Variant Code");
                                end;

                                if "Lot No." = '' then begin
                                    ContainerLine.SetFilter("Lot No.", '<>%1', ContainerLine."Lot No.");
                                    if ContainerLine.IsEmpty then
                                        LotNo := ContainerLine."Lot No.";
                                    ContainerLine.SetRange("Lot No.");
                                end;

                                if "Unit of Measure Code" = '' then begin
                                    ContainerLine.SetFilter("Unit of Measure Code", '<>%1', ContainerLine."Unit of Measure Code");
                                    if ContainerLine.IsEmpty then
                                        UOMCode := ContainerLine."Unit of Measure Code";
                                    ContainerLine.SetRange("Unit of Measure Code");
                                end;
                            end;

                            if ItemNo <> '' then
                                Validate("Item No.", ItemNo);
                            if "Variant Code" <> VariantCode then
                                Validate("Variant Code", VariantCode);
                            if LotNo <> '' then
                                Validate("Lot No.", LotNo);
                            if ("Unit of Measure Code" <> UOMCode) and (UOMCode <> '') then
                                Validate("Unit of Measure Code", UOMCode);
                        end;

                        if "Entry Type" = "Entry Type"::Movement then begin
                            if "From Bin Code" <> ContainerHeader."Bin Code" then
                                Validate("From Bin Code", ContainerHeader."Bin Code");
                        end else begin
                            if "Bin Code" <> ContainerHeader."Bin Code" then
                                Validate("Bin Code", ContainerHeader."Bin Code");
                        end;
                    end;
            end;
        }
        field(37002562; "From Container ID"; Code[20])
        {
            AccessByPermission = TableData "Container Header" = R;
            Caption = 'From Container ID';
        }
        field(37002563; "To Container License Plate"; Code[50])
        {
            AccessByPermission = TableData "Container Header" = R;
            Caption = 'To Container License Plate';

            trigger OnValidate()
            var
                ContainerHeader: Record "Container Header";
            begin
                // P8001323
                CheckMoveContainer(FieldCaption("To Container License Plate"));

                if "To Container License Plate" <> xRec."To Container License Plate" then
                    if "To Container License Plate" = '' then
                        "To Container ID" := ''
                    else begin
                        ContainerHeader.SetRange("License Plate", "To Container License Plate");
                        ContainerHeader.SetRange("Location Code", "Location Code");
                        if ("Bin Code" <> '') and (not "Phys. Inventory") then
                            ContainerHeader.SetRange("Bin Code", "Bin Code");
                        ContainerHeader.SetRange(Inbound, false);
                        ContainerHeader.FindFirst;

                        CheckMoveContainerForPhysical(ContainerHeader);

                        if ContainerHeader."Document Type" <> 0 then
                            Error(Text37002007, ContainerHeader.DocumentType, ContainerHeader."Document No.");

                        "To Container ID" := ContainerHeader.ID;
                        CheckToContainer;

                        if "Entry Type" = "Entry Type"::Movement then begin
                            if "To Bin Code" <> ContainerHeader."Bin Code" then
                                Validate("To Bin Code", ContainerHeader."Bin Code");
                        end else begin
                            if ("Bin Code" <> ContainerHeader."Bin Code") and (not "Phys. Inventory") then
                                Validate("Bin Code", ContainerHeader."Bin Code");
                        end;
                    end;
            end;
        }
        field(37002564; "To Container ID"; Code[20])
        {
            AccessByPermission = TableData "Container Header" = R;
            Caption = 'To Container ID';
        }
        field(37002565; "Container Master Line No."; Integer)
        {
            AccessByPermission = TableData "Container Header" = R;
            Caption = 'Container Master Line No.';
        }
        field(37002566; "Loose Quantity"; Decimal)
        {
            Caption = 'Loose Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(37002567; "Shipping Container"; Boolean)
        {
            Caption = 'Shipping Container';
        }
    }

    keys
    {
        key(Key1; "Journal Template Name", "Journal Batch Name", "Location Code", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Item No.", "Location Code", "Entry Type", "From Bin Type Code", "Variant Code", "Unit of Measure Code")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Qty. (Absolute, Base)";
        }
#pragma warning disable AS0009
        key(Key3; "Item No.", "From Bin Code", "Location Code", "Entry Type", "Variant Code", "Unit of Measure Code", "Lot No.", "Serial No.", "Package No.")
#pragma warning restore AS0009
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Qty. (Absolute, Base)", "Qty. (Absolute)", Cubage, Weight;
        }
#pragma warning disable AS0009
        key(Key4; "Item No.", "To Bin Code", "Location Code", "Variant Code", "Unit of Measure Code", "Lot No.", "Serial No.", "Package No.")
#pragma warning restore AS0009
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Qty. (Absolute, Base)", "Qty. (Absolute)";
        }
        key(Key5; "To Bin Code", "Location Code")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = Cubage, Weight, "Qty. (Absolute)";
        }
        key(Key6; "Location Code", "Item No.", "Variant Code")
        {
        }
        key(Key7; "Location Code", "Bin Code", "Item No.", "Variant Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if not ConfirmDeleteContainer then // P8001323
            Error('');                       // P8001323

        ItemTrackingMgt.DeleteWhseItemTrkgLines(
          DATABASE::"Warehouse Journal Line", 0, "Journal Batch Name",
          "Journal Template Name", 0, "Line No.", "Location Code", true);
    end;

    trigger OnInsert()
    begin
        "User ID" := UserId;
    end;

    trigger OnModify()
    begin
        if "User ID" = '' then
            "User ID" := UserId;
    end;

    var
        Location: Record Location;
        Bin: Record Bin;
        WhseJnlTemplate: Record "Warehouse Journal Template";
        WhseJnlBatch: Record "Warehouse Journal Batch";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        WMSMgt: Codeunit "WMS Management";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        UOMMgt: Codeunit "Unit of Measure Management";
        ItemTrackingType: Enum "Item Tracking Type";
        OldItemNo: Code[20];
        Text000: Label 'must not be negative';
        Text001: Label '%1 Journal';
        Text002: Label 'DEFAULT';
        Text003: Label 'Default Journal';
        Text005: Label 'The location %1 of warehouse journal batch %2 is not enabled for user %3.';
        Text006: Label '%1 must be 0 or 1 for an Item tracked by Serial Number.';
        OpenFromBatch: Boolean;
        StockProposal: Boolean;
        ProcessFns: Codeunit "Process 800 Functions";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        ItemTrackingDataCollection: Codeunit "Item Tracking Data Collection";
        ContainerFns: Codeunit "Container Functions";
        Text37002000: Label '%1 cannot be changed when moving containers.';
        Text37002001: Label 'Container %1 is already being moved.';
        Text37002002: Label 'This will delete all lines for container %1.\Continue?''';
        Text37002003: Label 'To and From Bin Codes must be different when moving containers.';
        Text37002004: Label 'Item %1 is not allowed for container %2';
        Text37002005: Label 'Different lots for item %1 cannot be combined.';
        Text37002006: Label 'Container %1 cannot have multiple items.';
        Text37002007: Label 'Container has been assigned to %1 %2.';
        Text37002008: Label 'Tracking';
        Text37002009: Label 'must be zero.';

    protected var
        Item: Record Item;
        WhseJnlLine: Record "Warehouse Journal Line";
        PhysInvtEntered: Boolean;

    procedure GetItem(ItemNo: Code[20]; var ItemDescription: Text[100])
    begin
        if ItemNo <> OldItemNo then begin
            ItemDescription := '';
            if ItemNo <> '' then
                if Item.Get(ItemNo) then
                    ItemDescription := Item.Description;
            OldItemNo := ItemNo;
        end else
            ItemDescription := Item.Description;
    end;

    procedure SetUpNewLine(LastWhseJnlLine: Record "Warehouse Journal Line")
    var
        Location: Record Location;
        Bin: Record Bin;
    begin
        WhseJnlTemplate.Get("Journal Template Name");
        WhseJnlLine.SetRange("Journal Template Name", "Journal Template Name");
        WhseJnlLine.SetRange("Journal Batch Name", "Journal Batch Name");
        WhseJnlLine.SetRange("Location Code", "Location Code");
        OnSetUpNewLineOnAfterWhseJnlLineSetFilters(Rec, WhseJnlLine, LastWhseJnlLine);
        if WhseJnlLine.FindFirst then begin
            WhseJnlBatch.Get(
              "Journal Template Name", "Journal Batch Name", LastWhseJnlLine."Location Code");
            "Registering Date" := LastWhseJnlLine."Registering Date";
            "Whse. Document No." := LastWhseJnlLine."Whse. Document No.";
            "Entry Type" := LastWhseJnlLine."Entry Type";
            "Location Code" := LastWhseJnlLine."Location Code";
        end else begin
            "Registering Date" := WorkDate;
            GetWhseJnlBatch();
            if WhseJnlBatch."No. Series" <> '' then begin
                Clear(NoSeriesMgt);
                "Whse. Document No." :=
                  NoSeriesMgt.TryGetNextNo(WhseJnlBatch."No. Series", "Registering Date");
            end;
        end;
        if WhseJnlTemplate.Type = WhseJnlTemplate.Type::"Physical Inventory" then begin
            "Source Document" := "Source Document"::"Phys. Invt. Jnl.";
            "Whse. Document Type" := "Whse. Document Type"::"Whse. Phys. Inventory";
        end;
        "Source Code" := WhseJnlTemplate."Source Code";
        "Reason Code" := WhseJnlBatch."Reason Code";
        "Registering No. Series" := WhseJnlBatch."Registering No. Series";
        if WhseJnlTemplate.Type <> WhseJnlTemplate.Type::Reclassification then begin
            if Quantity >= 0 then
                "Entry Type" := "Entry Type"::"Positive Adjmt."
            else
                "Entry Type" := "Entry Type"::"Negative Adjmt.";
            SetUpAdjustmentBin;
        end else
            "Entry Type" := "Entry Type"::Movement;

        "Phys. Inventory" := WhseJnlTemplate.Type = WhseJnlTemplate.Type::"Physical Inventory"; // P8001323
        OnAfterSetupNewLine(Rec, LastWhseJnlLine, WhseJnlTemplate);
    end;

    local procedure GetWhseJnlBatch()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetWhseJnlBatch(Rec, WhseJnlBatch, IsHandled);
        if IsHandled then
            exit;

        WhseJnlBatch.Get("Journal Template Name", "Journal Batch Name", "Location Code");
    end;

    procedure SetUpAdjustmentBin()
    var
        Location: Record Location;
    begin
        WhseJnlTemplate.Get("Journal Template Name");
        if WhseJnlTemplate.Type = WhseJnlTemplate.Type::Reclassification then
            exit;

        Location.Get("Location Code");
        GetBin(Location.Code, Location."Adjustment Bin Code");
        case "Entry Type" of
            "Entry Type"::"Positive Adjmt.":
                begin
                    "From Zone Code" := Bin."Zone Code";
                    "From Bin Code" := Bin.Code;
                    "From Bin Type Code" := Bin."Bin Type Code";
                end;
            "Entry Type"::"Negative Adjmt.":
                begin
                    "To Zone Code" := Bin."Zone Code";
                    "To Bin Code" := Bin.Code;
                end;
        end;
    end;

    local procedure CalcQty(QtyBase: Decimal): Decimal
    begin
        TestField("Qty. per Unit of Measure");
        exit(Round(QtyBase / "Qty. per Unit of Measure", UOMMgt.QtyRndPrecision));
    end;

    local procedure CalcBaseQty(Qty: Decimal; FromFieldName: Text; ToFieldName: Text): Decimal
    begin
        exit(UOMMgt.CalcBaseQty(
            "Item No.", "Variant Code", "Unit of Measure Code", Qty, "Qty. per Unit of Measure", "Qty. Rounding Precision (Base)", FieldCaption("Qty. Rounding Precision"), FromFieldName, ToFieldName));
    end;

    procedure CalcReservEntryQuantity(): Decimal
    var
        ReservEntry: Record "Reservation Entry";
    begin
        if "Source Type" = DATABASE::"Prod. Order Component" then begin
            ReservEntry.SetSourceFilter("Source Type", "Source Subtype", "Journal Template Name", "Source Subline No.", true);
            ReservEntry.SetSourceFilter("Journal Batch Name", "Source Line No.");
        end else begin
            ReservEntry.SetSourceFilter("Source Type", "Source Subtype", "Journal Template Name", "Source Line No.", true);
            ReservEntry.SetSourceFilter("Journal Batch Name", 0);
        end;
        ReservEntry.SetTrackingFilterFromWhseJnlLine(WhseJnlLine);
        if ReservEntry.FindFirst() then
            exit(ReservEntry."Quantity (Base)");
        exit("Qty. (Base)");
    end;

    local procedure GetItemUnitOfMeasure()
    begin
        GetItem("Item No.", Description);
        if (Item."No." <> ItemUnitOfMeasure."Item No.") or
           ("Unit of Measure Code" <> ItemUnitOfMeasure.Code)
        then
            if not ItemUnitOfMeasure.Get(Item."No.", "Unit of Measure Code") then
                ItemUnitOfMeasure.Get(Item."No.", Item."Base Unit of Measure");
    end;

    local procedure SetItemFields()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSetItemFields(Rec, IsHandled, xRec, Item);
        if IsHandled then
            exit;

        if "Item No." <> '' then begin
            if "Item No." <> xRec."Item No." then
                "Variant Code" := '';
            GetItemUnitOfMeasure;
            Description := Item.Description;
            Validate("Unit of Measure Code", ItemUnitOfMeasure.Code);
        end else begin
            Description := '';
            "Variant Code" := '';
            Validate("Unit of Measure Code", '');
        end;
    end;

    procedure EmptyLine(): Boolean
    begin
        exit(
          ("Item No." = '') and (Quantity = 0));
    end;

    local procedure ExchangeFromToBin()
    var
        WhseJnlLine: Record "Warehouse Journal Line";
    begin
        GetLocation("Location Code");
        WhseJnlLine := Rec;
        "From Zone Code" := WhseJnlLine."To Zone Code";
        "From Bin Code" := WhseJnlLine."To Bin Code";
        "From Container License Plate" := WhseJnlLine."To Container License Plate"; // P8001323
        "From Container ID" := WhseJnlLine."To Container ID";                       // P8001323
        CheckFromContainer;                                                         // P8001323
        "From Bin Type Code" :=
          GetBinType("Location Code", "From Bin Code");
        if ("Location Code" = Location.Code) and
           ("From Bin Code" = Location."Adjustment Bin Code")
        then
            WMSMgt.CheckAdjmtBin(Location, "Qty. (Absolute)", Quantity > 0);

        "To Zone Code" := WhseJnlLine."From Zone Code";
        "To Bin Code" := WhseJnlLine."From Bin Code";
        "To Container License Plate" := WhseJnlLine."From Container License Plate"; // P8001323
        "To Container ID" := WhseJnlLine."From Container ID";                       // P8001323
        CheckToContainer;                                                           // P8001323
        if ("Location Code" = Location.Code) and
           ("To Bin Code" = Location."Adjustment Bin Code")
        then
            WMSMgt.CheckAdjmtBin(Location, "Qty. (Absolute)", Quantity > 0);

        if WhseJnlTemplate.Type <> WhseJnlTemplate.Type::Reclassification then begin
            if Quantity >= 0 then
                "Entry Type" := "Entry Type"::"Positive Adjmt."
            else
                "Entry Type" := "Entry Type"::"Negative Adjmt.";
            SetUpAdjustmentBin;
        end;
    end;

    local procedure GetLocation(LocationCode: Code[10])
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetLocation(Location, LocationCode, IsHandled);
        if IsHandled then
            exit;

        if Location.Code <> LocationCode then
            Location.Get(LocationCode);
        Location.TestField("Directed Put-away and Pick");
    end;

    local procedure GetBin(LocationCode: Code[10]; BinCode: Code[20])
    begin
        if (LocationCode = '') or (BinCode = '') then
            Clear(Bin)
        else
            if (Bin."Location Code" <> LocationCode) or
               (Bin.Code <> BinCode)
            then
                Bin.Get(LocationCode, BinCode);
    end;

    local procedure CheckBin(LocationCode: Code[10]; BinCode: Code[20]; Inbound: Boolean)
    var
        BinContent: Record "Bin Content";
        WhseJnlLine: Record "Warehouse Journal Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckBin(Rec, LocationCode, BinCode, Inbound, IsHandled, CurrFieldNo);
        if IsHandled then
            exit;

        if (BinCode <> '') and ("Item No." <> '') then begin
            GetLocation(LocationCode);
            if BinCode = Location."Adjustment Bin Code" then
                exit;
            BinContent.SetProposalMode(StockProposal);
            if Inbound then begin
                GetBinType(LocationCode, BinCode);
                if Location."Bin Capacity Policy" in
                   [Location."Bin Capacity Policy"::"Allow More Than Max. Capacity",
                    Location."Bin Capacity Policy"::"Prohibit More Than Max. Cap."]
                then begin
                    WhseJnlLine.SetCurrentKey("To Bin Code", "Location Code");
                    WhseJnlLine.SetRange("To Bin Code", BinCode);
                    WhseJnlLine.SetRange("Location Code", LocationCode);
                    WhseJnlLine.SetRange("Journal Template Name", "Journal Template Name");
                    WhseJnlLine.SetRange("Journal Batch Name", "Journal Batch Name");
                    WhseJnlLine.SetRange("Line No.", "Line No.");
                    WhseJnlLine.CalcSums("Qty. (Absolute)", Cubage, Weight);
                end;
                CheckIncreaseBin(BinContent, LocationCode, BinCode);
            end else begin
                IsHandled := false;
                OnCheckBinOnBeforeCheckOutboundBin(Rec, IsHandled);
                if not IsHandled then begin
                    BinContent.Get("Location Code", BinCode, "Item No.", "Variant Code", "Unit of Measure Code");
                    if BinContent."Block Movement" in [
                                                    BinContent."Block Movement"::Outbound, BinContent."Block Movement"::All]
                    then
                        if not StockProposal then
                            BinContent.FieldError("Block Movement");
                end;
            end;
            BinContent.SetProposalMode(false);
        end;
    end;

    local procedure CheckIncreaseBin(BinContent: Record "Bin Content"; LocationCode: Code[10]; BinCode: Code[20])
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckIncreaseBin(Rec, BinCode, StockProposal, IsHandled);
        if IsHandled then
            exit;

        if BinContent.Get(
             "Location Code", BinCode, "Item No.", "Variant Code", "Unit of Measure Code")
        then
            BinContent.CheckIncreaseBinContent(
              "Qty. (Absolute, Base)", WhseJnlLine."Qty. (Absolute, Base)",
              WhseJnlLine.Cubage, WhseJnlLine.Weight, Cubage, Weight, false, false)
        else begin
            GetBin(LocationCode, BinCode);
            Bin.CheckIncreaseBin(
              BinCode, "Item No.", "Qty. (Absolute)",
              WhseJnlLine.Cubage, WhseJnlLine.Weight, Cubage, Weight, false, false);
        end;
    end;

    procedure GetBinType(LocationCode: Code[10]; BinCode: Code[20]): Code[10]
    var
        BinType: Record "Bin Type";
    begin
        GetBin(LocationCode, BinCode);
        WhseJnlTemplate.Get("Journal Template Name");
        if WhseJnlTemplate.Type = WhseJnlTemplate.Type::Reclassification then
            if Bin."Bin Type Code" <> '' then
                if BinType.Get(Bin."Bin Type Code") then
                    BinType.TestField(Receive, false);

        exit(Bin."Bin Type Code");
    end;

#if not CLEAN19
    [Obsolete('Replaced by TemplateSelection() with return value JnlSelected.', '19.0')]
    procedure TemplateSelection(PageID: Integer; PageTemplate: Option Adjustment,"Phys. Inventory",Reclassification; var WhseJnlLine: Record "Warehouse Journal Line"; var JnlSelected: Boolean)
    begin
        JnlSelected := TemplateSelection(PageID, "Warehouse Journal Template Type".FromInteger(PageTemplate), WhseJnlLine);
    end;
#endif

    procedure TemplateSelection(PageID: Integer; PageTemplate: Enum "Warehouse Journal Template Type"; var WhseJnlLine: Record "Warehouse Journal Line") JnlSelected: Boolean
    var
        WhseJnlTemplate: Record "Warehouse Journal Template";
    begin
        JnlSelected := true;

        WhseJnlTemplate.Reset();
        if not OpenFromBatch then
            WhseJnlTemplate.SetRange("Page ID", PageID);
        WhseJnlTemplate.SetRange(Type, PageTemplate);
        OnTemplateSelectionOnAfterSetFilters(Rec, WhseJnlTemplate, OpenFromBatch);

        case WhseJnlTemplate.Count of
            0:
                begin
                    WhseJnlTemplate.Init();
                    WhseJnlTemplate.Validate(Type, PageTemplate);
                    WhseJnlTemplate.Validate("Page ID");
                    WhseJnlTemplate.Name := Format(WhseJnlTemplate.Type, MaxStrLen(WhseJnlTemplate.Name));
                    WhseJnlTemplate.Description := StrSubstNo(Text001, WhseJnlTemplate.Type);
                    WhseJnlTemplate.Insert();
                    Commit();
                end;
            1:
                WhseJnlTemplate.FindFirst;
            else
                JnlSelected := PAGE.RunModal(0, WhseJnlTemplate) = ACTION::LookupOK;
        end;
        if JnlSelected then begin
            WhseJnlLine.FilterGroup := 2;
            WhseJnlLine.SetRange("Journal Template Name", WhseJnlTemplate.Name);
            WhseJnlLine.FilterGroup := 0;
            if OpenFromBatch then begin
                WhseJnlLine."Journal Template Name" := '';
                PAGE.Run(WhseJnlTemplate."Page ID", WhseJnlLine);
            end;
        end;
    end;

    procedure TemplateSelectionFromBatch(var WhseJnlBatch: Record "Warehouse Journal Batch")
    var
        WhseJnlLine: Record "Warehouse Journal Line";
        JnlSelected: Boolean;
    begin
        OnBeforeTemplateSelectionFromBatch(WhseJnlLine, WhseJnlBatch);

        OpenFromBatch := true;
        WhseJnlBatch.CalcFields("Template Type");
        WhseJnlLine."Journal Batch Name" := WhseJnlBatch.Name;
        WhseJnlLine."Location Code" := WhseJnlBatch."Location Code";
        JnlSelected := TemplateSelection(0, WhseJnlBatch."Template Type", WhseJnlLine);
    end;

    procedure OpenJnl(var CurrentJnlBatchName: Code[10]; var CurrentLocationCode: Code[10]; var WhseJnlLine: Record "Warehouse Journal Line")
    begin
        OnBeforeOpenJnl(WhseJnlLine, CurrentJnlBatchName, CurrentLocationCode);

        WMSMgt.CheckUserIsWhseEmployee;
        CheckTemplateName(
          WhseJnlLine.GetRangeMax("Journal Template Name"), CurrentLocationCode, CurrentJnlBatchName);
        WhseJnlLine.FilterGroup := 2;
        WhseJnlLine.SetRange("Journal Batch Name", CurrentJnlBatchName);
        if CurrentLocationCode <> '' then
            WhseJnlLine.SetRange("Location Code", CurrentLocationCode);
        WhseJnlLine.FilterGroup := 0;

        OnAfterOpenJnl(WhseJnlLine, CurrentJnlBatchName, CurrentLocationCode);
    end;

    procedure CheckTemplateName(CurrentJnlTemplateName: Code[10]; var CurrentLocationCode: Code[10]; var CurrentJnlBatchName: Code[10])
    var
        WhseJnlBatch: Record "Warehouse Journal Batch";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckTemplateName(CurrentJnlTemplateName, CurrentJnlBatchName, CurrentLocationCode, IsHandled);
        if IsHandled then
            exit;

        if FindExistingBatch(CurrentJnlTemplateName, CurrentLocationCode, CurrentJnlBatchName) then
            exit;

        WhseJnlBatch.Init();
        WhseJnlBatch."Journal Template Name" := CurrentJnlTemplateName;
        WhseJnlBatch.SetupNewBatch;
        WhseJnlBatch."Location Code" := CurrentLocationCode;
        WhseJnlBatch.Name := Text002;
        WhseJnlBatch.Description := Text003;
        WhseJnlBatch.Insert(true);
        Commit();
        CurrentJnlBatchName := WhseJnlBatch.Name;
    end;

    procedure CheckName(CurrentJnlBatchName: Code[10]; CurrentLocationCode: Code[10]; var WhseJnlLine: Record "Warehouse Journal Line")
    var
        WhseJnlBatch: Record "Warehouse Journal Batch";
        WhseEmployee: Record "Warehouse Employee";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckName(CurrentJnlBatchName, CurrentLocationCode, IsHandled);
        if IsHandled then
            exit;

        WhseJnlBatch.Get(
          WhseJnlLine.GetRangeMax("Journal Template Name"), CurrentJnlBatchName, CurrentLocationCode);
        if (UserId <> '') and not WhseEmployee.Get(UserId, CurrentLocationCode) then
            Error(Text005, CurrentLocationCode, CurrentJnlBatchName, UserId);
    end;

    local procedure CheckQtyPhysInventory()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckQtyPhysInventory(Rec, IsHandled);
        if IsHandled then
            exit;

        if "Serial No." <> '' then
            if ("Qty. (Phys. Inventory)" < 0) or ("Qty. (Phys. Inventory)" > 1) then
                Error(Text006, FieldCaption("Qty. (Phys. Inventory)"));
    end;

    local procedure CheckSerialNoTrackedQuantity()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckSerialNoTrackedQuantity(Rec, CurrFieldNo, IsHandled);
        if IsHandled then
            exit;

        if (Quantity < 0) or (Quantity > 1) then
            Error(Text006, FieldCaption(Quantity));
    end;

    procedure SetName(CurrentJnlBatchName: Code[10]; CurrentLocationCode: Code[10]; var WhseJnlLine: Record "Warehouse Journal Line")
    begin
        WhseJnlLine.FilterGroup := 2;
        WhseJnlLine.SetRange("Journal Batch Name", CurrentJnlBatchName);
        WhseJnlLine.SetRange("Location Code", CurrentLocationCode);
        WhseJnlLine.FilterGroup := 0;
        if WhseJnlLine.Find('-') then;

        OnAfterSetName(Rec, WhseJnlLine);
    end;

    procedure LookupName(var CurrentJnlBatchName: Code[10]; var CurrentLocationCode: Code[10]; var WhseJnlLine: Record "Warehouse Journal Line")
    var
        WhseJnlBatch: Record "Warehouse Journal Batch";
    begin
        Commit();
        WhseJnlBatch."Journal Template Name" := WhseJnlLine.GetRangeMax("Journal Template Name");
        WhseJnlBatch.Name := WhseJnlLine.GetRangeMax("Journal Batch Name");
        WhseJnlBatch.SetRange("Journal Template Name", WhseJnlBatch."Journal Template Name");
        if PAGE.RunModal(PAGE::"Whse. Journal Batches List", WhseJnlBatch) = ACTION::LookupOK then begin
            CurrentJnlBatchName := WhseJnlBatch.Name;
            CurrentLocationCode := WhseJnlBatch."Location Code";
            OnLookupNameOnBeforeSetName(WhseJnlLine, WhseJnlBatch);
            SetName(CurrentJnlBatchName, CurrentLocationCode, WhseJnlLine);
        end;
    end;

    procedure OpenItemTrackingLines()
    var
        WhseWkshLine: Record "Whse. Worksheet Line";
        WhseItemTrackingLines: Page "Whse. Item Tracking Lines";
    begin
        OnBeforeOpenItemTrackingLines(Rec);
        CheckMoveContainer(Text37002008); // P8001323
        TestField("Item No.");
        TestField("Qty. (Base)");
        WhseWkshLine.Init();
        WhseWkshLine."Worksheet Template Name" := "Journal Template Name";
        WhseWkshLine.Name := "Journal Batch Name";
        WhseWkshLine."Location Code" := "Location Code";
        WhseWkshLine."Line No." := "Line No.";
        WhseWkshLine."Item No." := "Item No.";
        WhseWkshLine."Variant Code" := "Variant Code";
        WhseWkshLine."Qty. (Base)" := "Qty. (Base)";
        WhseWkshLine."Qty. to Handle (Base)" := "Qty. (Base)";
        WhseWkshLine."Qty. per Unit of Measure" := "Qty. per Unit of Measure";
        OnOpenItemTrackingLinesOnBeforeSetSource(WhseWkshLine, Rec);

        WhseItemTrackingLines.SetSource(WhseWkshLine, DATABASE::"Warehouse Journal Line");
        WhseItemTrackingLines.RunModal;
        Clear(WhseItemTrackingLines);

        OnAfterOpenItemTrackingLines(Rec, WhseItemTrackingLines);
    end;

    procedure ItemTrackingReclass(TemplateName: Code[10]; BatchName: Code[10]; LocationCode: Code[10]; LineNo: Integer): Boolean
    var
        WhseItemTrkgLine: Record "Whse. Item Tracking Line";
    begin
        if not IsReclass(TemplateName) then
            exit(false);

        with WhseItemTrkgLine do begin
            if ItemTrackingMgt.WhseItemTrackingLineExists(TemplateName, BatchName, LocationCode, LineNo, WhseItemTrkgLine) then begin
                FindSet();
                repeat
                    if not HasSameNewTracking() or ("Expiration Date" <> "New Expiration Date") then
                        exit(true);
                until Next() = 0;
            end;
        end;

        exit(false);
    end;

    local procedure LookupFromBinCode()
    var
        WhseItemTrackingSetup: Record "Item Tracking Setup";
        BinCode: Code[20];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeLookupFromBinCode(Rec, IsHandled);
        if IsHandled then
            exit;

        if ("Line No." <> 0) and IsReclass("Journal Template Name") then begin
            LookupItemTracking(WhseItemTrackingSetup);
            BinCode := WMSMgt.BinContentLookUp("Location Code", "Item No.", "Variant Code", "Zone Code", WhseItemTrackingSetup, "Bin Code");
        end else
            BinCode := WMSMgt.BinLookUp("Location Code", "Item No.", "Variant Code", "Zone Code");
        if BinCode <> '' then
            Validate("From Bin Code", BinCode);
    end;

    local procedure LookupBinCode()
    var
        WhseItemTrackingSetup: Record "Item Tracking Setup";
        BinCode: Code[20];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeLookupBinCode(Rec, IsHandled);
        if IsHandled then
            exit;

        if ("Line No." <> 0) and (Quantity < 0) then begin
            LookupItemTracking(WhseItemTrackingSetup);
            BinCode := WMSMgt.BinContentLookUp("Location Code", "Item No.", "Variant Code", "Zone Code", WhseItemTrackingSetup, "Bin Code");
        end else
            BinCode := WMSMgt.BinLookUp("Location Code", "Item No.", "Variant Code", "Zone Code");
        if BinCode <> '' then
            Validate("Bin Code", BinCode);
    end;

#if not CLEAN17
    [Obsolete('Replaced by LookupItemTracking()', '17.0')]
    procedure RetrieveItemTracking(var LotNo: Code[50]; var SerialNo: Code[50])
    var
        WhseItemTrackingSetup: Record "Item Tracking Setup";
    begin
        LookupItemTracking(WhseItemTrackingSetup);
        SerialNo := WhseItemTrackingSetup."Serial No.";
        LotNo := WhseItemTrackingSetup."Lot No.";
    end;
#endif

    procedure LookupItemTracking(var WhseItemTrackingSetup: Record "Item Tracking Setup")
    var
        WhseItemTrkgLine: Record "Whse. Item Tracking Line";
    begin
        if ItemTrackingMgt.WhseItemTrackingLineExists(
             "Journal Template Name", "Journal Batch Name", "Location Code", "Line No.", WhseItemTrkgLine)
        then
            // Don't step in if more than one Tracking Definition exists
            if WhseItemTrkgLine.Count = 1 then begin
                WhseItemTrkgLine.FindFirst();
                if WhseItemTrkgLine."Quantity (Base)" = "Qty. (Absolute, Base)" then
                    WhseItemTrackingSetup.CopyTrackingFromWhseItemTrackingLine(WhseItemTrkgLine);
            end;
    end;

    procedure IsReclass(CurrentJnlTemplateName: Code[10]): Boolean
    var
        WhseJnlTemplate: Record "Warehouse Journal Template";
    begin
        if WhseJnlTemplate.Get(CurrentJnlTemplateName) then
            exit(WhseJnlTemplate.Type = WhseJnlTemplate.Type::Reclassification);

        exit(false);
    end;

    procedure SetProposal(NewValue: Boolean)
    begin
        StockProposal := NewValue;
    end;

    local procedure InitAlternateQty()
    begin
        // P8000591A
        // P8004516
        // IF "Phys. Inventory" THEN BEGIN
        //  "Quantity (Alt.)" := 0;
        //  IF Item.GET("Item No.") THEN
        //    IF Item.TrackAlternateUnits() THEN
        //      "Quantity (Alt.)" := ROUND("Qty. (Base)" * Item.AlternateQtyPerBase(), 0.00001);
        //  "Quantity (Absolute, Alt.)" := ABS("Quantity (Alt.)");
        // END;
        // P8004516

        // P8000980
        if Item.Get("Item No.") then
            if Item.TrackAlternateUnits and (not Item."Catch Alternate Qtys.") then begin
                "Quantity (Alt.)" := Round("Qty. (Base)" * Item.AlternateQtyPerBase(), 0.00001);
                "Quantity (Absolute, Alt.)" := Abs("Quantity (Alt.)");
                "Qty. (Alt.) (Calculated)" := Round("Qty. (Calculated) (Base)" * Item.AlternateQtyPerBase(), 0.00001);  // P80056356
            end;
        // P8000980
    end;

    local procedure LookUpTrackingSummary(SearchForSupply: Boolean; SignFactor: Integer; TrackingType: Option SerialNo,LotNo)
    var
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        // P8000592A
        TestField("Item No.");
        Item.Get("Item No.");
        Item.TestField("Item Tracking Code");
        ItemTrackingCode.Get(Item."Item Tracking Code");

        TempTrackingSpecification.Init;
        TempTrackingSpecification."Item No." := "Item No.";
        TempTrackingSpecification."Location Code" := "Location Code";
        TempTrackingSpecification."Variant Code" := "Variant Code";
        TempTrackingSpecification."Quantity (Base)" := "Qty. (Base)";
        TempTrackingSpecification."Qty. to Handle" := Quantity;
        TempTrackingSpecification."Qty. to Handle (Base)" := "Qty. (Base)";
        TempTrackingSpecification."Qty. per Unit of Measure" := "Qty. per Unit of Measure";
        if ("Entry Type" = "Entry Type"::Movement) then
            TempTrackingSpecification."Bin Code" := "From Bin Code"
        else
            TempTrackingSpecification."Bin Code" := "Bin Code";

        if not ItemTrackingDataCollection.CurrentDataSetMatches("Item No.", "Variant Code", "Location Code") then
            Clear(ItemTrackingDataCollection);
        ItemTrackingDataCollection.SetCurrentBinAndItemTrkgCode(
          TempTrackingSpecification."Bin Code", ItemTrackingCode);
        ItemTrackingDataCollection.AssistEditTrackingNo(
          TempTrackingSpecification, SearchForSupply, SignFactor, TrackingType, Quantity);

        case TrackingType of
            TrackingType::SerialNo:
                if TempTrackingSpecification."Serial No." <> '' then
                    Validate("Serial No.", TempTrackingSpecification."Serial No.");
            TrackingType::LotNo:
                if TempTrackingSpecification."Lot No." <> '' then
                    Validate("Lot No.", TempTrackingSpecification."Lot No.");
        end;
    end;

    local procedure CheckFromContainer()
    var
        ContainerLine: Record "Container Line";
    begin
        // P8001323
        if "From Container ID" <> '' then begin
            ContainerLine.SetRange("Container ID", "From Container ID");
            if "Item No." <> '' then
                ContainerLine.SetRange("Item No.", "Item No.");
            if "Variant Code" <> '' then
                ContainerLine.SetRange("Variant Code", "Variant Code");
            if "Unit of Measure Code" <> '' then
                ContainerLine.SetRange("Unit of Measure Code", "Unit of Measure Code");
            if "Lot No." <> '' then
                ContainerLine.SetRange("Lot No.", "Lot No.");
            if "Serial No." <> '' then
                ContainerLine.SetRange("Serial No.", "Serial No.");
            ContainerLine.SetFilter(Quantity, '>0');
            ContainerLine.FindFirst;
        end;
    end;

    local procedure CheckToContainer()
    var
        Item: Record Item;
        ContainerHeader: Record "Container Header";
        ContainerLine: Record "Container Line";
        ContainerUsage: Record "Container Type Usage";
    begin
        // P8001323
        if "To Container ID" <> '' then begin
            TestField("Item No.");
            TestField("Unit of Measure Code");
            ContainerHeader.Get("To Container ID");

            Item.Get("Item No.");
            if not ContainerFns.GetContainerUsage(ContainerHeader."Container Type Code", Item."No.", Item."Item Category Code", // P8007749
              "Unit of Measure Code", true, ContainerUsage)
            then
                Error(Text37002004, Item."No.", "To Container License Plate");

            if ContainerHeader."Document Type" = 0 then begin
                ContainerLine.SetRange("Container ID", "To Container ID");
                ContainerLine.SetFilter("Item No.", '<>%1', "Item No.");
                if not ContainerLine.IsEmpty then
                    Error(Text37002006, "To Container License Plate");

                if ContainerUsage."Single Lot" and ("Lot No." <> '') then begin
                    ContainerLine.SetRange("Item No.");
                    ContainerLine.SetFilter("Lot No.", '<>%1', "Lot No.");
                    ContainerLine.SetFilter("Variant Code", '<>%1', "Variant Code");
                    if not ContainerLine.IsEmpty then
                        Error(Text37002005, "Item No.");
                end;
            end;
        end;
    end;

    procedure MoveContainer()
    var
        ContainerLine: Record "Container Line";
        TempContainerLine: Record "Container Line" temporary;
        WhseJournalLine: Record "Warehouse Journal Line";
        LineNoIncrement: Integer;
    begin
        // P8001323
        TestField("Entry Type", "Entry Type"::Movement);
        TestField("From Container License Plate");
        TestField("To Bin Code");
        if "Container Master Line No." <> 0 then
            Error(Text37002001, "From Container License Plate");
        if "From Bin Code" = "To Bin Code" then
            Error(Text37002003);

        ContainerLine.SetRange("Container ID", "From Container ID");
        if ContainerLine.FindSet then
            repeat
                TempContainerLine.SetRange("Item No.", ContainerLine."Item No.");
                TempContainerLine.SetRange("Variant Code", ContainerLine."Variant Code");
                TempContainerLine.SetRange("Unit of Measure Code", ContainerLine."Unit of Measure Code");
                TempContainerLine.SetRange("Lot No.", ContainerLine."Lot No.");
                TempContainerLine.SetRange("Serial No.", ContainerLine."Serial No.");
                if TempContainerLine.FindFirst then begin
                    TempContainerLine.Quantity += ContainerLine.Quantity;
                    TempContainerLine."Quantity (Alt.)" += ContainerLine."Quantity (Alt.)";
                    TempContainerLine.Modify
                end else begin
                    TempContainerLine := ContainerLine;
                    TempContainerLine.Insert;
                end;
            until ContainerLine.Next = 0;

        // First, we'll filll in the current warehouse journal line
        TempContainerLine.Reset;
        if "Item No." <> '' then
            TempContainerLine.SetRange("Item No.", "Item No.");
        if "Variant Code" <> '' then
            TempContainerLine.SetRange("Variant Code", "Variant Code");
        if "Unit of Measure Code" <> '' then
            TempContainerLine.SetRange("Unit of Measure Code", "Unit of Measure Code");
        if "Serial No." <> '' then
            TempContainerLine.SetRange("Serial No.", "Serial No.");
        if "Lot No." <> '' then
            TempContainerLine.SetRange("Lot No.", "Lot No.");
        TempContainerLine.FindFirst;
        if "Item No." = '' then
            Validate("Item No.", TempContainerLine."Item No.");
        if ("Variant Code" = '') and (TempContainerLine."Variant Code" <> '') then
            Validate("Variant Code", TempContainerLine."Variant Code");
        if "Unit of Measure Code" <> TempContainerLine."Unit of Measure Code" then
            Validate("Unit of Measure Code", TempContainerLine."Unit of Measure Code");
        if ("Serial No." = '') and (TempContainerLine."Serial No." <> '') then
            Validate("Serial No.", TempContainerLine."Serial No.");
        if ("Lot No." = '') and (TempContainerLine."Lot No." <> '') then
            Validate("Lot No.", TempContainerLine."Lot No.");
        Validate(Quantity, TempContainerLine.Quantity);
        if Item.Get("Item No.") then
            if Item.TrackAlternateUnits and (not Item."Catch Alternate Qtys.") then begin
                "Quantity (Alt.)" := Round("Qty. (Base)" * Item.AlternateQtyPerBase(), 0.00001);
                "Quantity (Absolute, Alt.)" := Abs("Quantity (Alt.)");
            end else
                if TempContainerLine."Quantity (Alt.)" <> 0 then
                    Validate("Quantity (Alt.)", TempContainerLine."Quantity (Alt.)");
        "To Container License Plate" := "From Container License Plate";
        "To Container ID" := "From Container ID";
        "Container Master Line No." := "Line No.";
        TempContainerLine.Delete;

        // Now we will add additional journal lines for any remaining container contents
        TempContainerLine.Reset;
        if TempContainerLine.FindSet then begin
            WhseJournalLine.Copy(Rec);
            if WhseJournalLine.Next = 0 then
                LineNoIncrement := 10000
            else
                LineNoIncrement := Round((WhseJournalLine."Line No." - "Line No.") / 1000, 1, '<');
            WhseJournalLine."Line No." := "Line No.";

            repeat
                WhseJournalLine.Init;
                WhseJournalLine."Line No." += LineNoIncrement;
                WhseJournalLine."Registering Date" := "Registering Date";
                WhseJournalLine."Whse. Document No." := "Whse. Document No.";
                WhseJournalLine."Entry Type" := "Entry Type"::Movement;
                WhseJournalLine."Source Code" := "Source Code";
                WhseJournalLine."Reason Code" := "Reason Code";
                WhseJournalLine."Registering No. Series" := "Registering No. Series";

                WhseJournalLine.Validate("From Bin Code", "From Bin Code");
                WhseJournalLine.Validate("Item No.", TempContainerLine."Item No.");
                WhseJournalLine.Validate("Variant Code", TempContainerLine."Variant Code");
                WhseJournalLine.Validate("Unit of Measure Code", TempContainerLine."Unit of Measure Code");
                WhseJournalLine.Validate("Serial No.", TempContainerLine."Serial No.");
                WhseJournalLine.Validate("Lot No.", TempContainerLine."Lot No.");
                WhseJournalLine."To Zone Code" := "To Zone Code";
                WhseJournalLine."To Bin Code" := "To Bin Code";
                WhseJournalLine.Validate(Quantity, TempContainerLine.Quantity);
                if Item.Get("Item No.") then
                    if Item.TrackAlternateUnits and (not Item."Catch Alternate Qtys.") then begin
                        WhseJournalLine."Quantity (Alt.)" := Round(WhseJournalLine."Qty. (Base)" * Item.AlternateQtyPerBase(), 0.00001);
                        WhseJournalLine."Quantity (Absolute, Alt.)" := Abs(WhseJournalLine."Quantity (Alt.)");
                    end else
                        if TempContainerLine."Quantity (Alt.)" <> 0 then
                            WhseJournalLine.Validate("Quantity (Alt.)", TempContainerLine."Quantity (Alt.)");
                WhseJournalLine."From Container License Plate" := "From Container License Plate";
                WhseJournalLine."From Container ID" := "From Container ID";
                WhseJournalLine."To Container License Plate" := "From Container License Plate";
                WhseJournalLine."To Container ID" := "From Container ID";
                WhseJournalLine."Container Master Line No." := "Line No.";
                WhseJournalLine.Insert;
            until TempContainerLine.Next = 0;
        end;
    end;

    local procedure CheckMoveContainer(FldCaption: Text)
    begin
        // P8001323
        if "Container Master Line No." <> 0 then
            Error(Text37002000, FldCaption);
    end;

    local procedure ConfirmDeleteContainer(): Boolean
    var
        WhseJournalLine: Record "Warehouse Journal Line";
    begin
        // P8001323
        if "Container Master Line No." = 0 then
            exit(true);

        WhseJournalLine.SetRange("Journal Template Name", "Journal Template Name");
        WhseJournalLine.SetRange("Journal Batch Name", "Journal Batch Name");
        WhseJournalLine.SetRange("Location Code", "Location Code");
        WhseJournalLine.SetFilter("Line No.", '<>%1', "Line No.");
        WhseJournalLine.SetRange("Container Master Line No.", "Container Master Line No.");
        if WhseJournalLine.IsEmpty then
            exit(true);

        if not Confirm(Text37002002, false, "From Container License Plate") then
            exit(false);

        WhseJournalLine.FindSet;
        repeat
            WhseJournalLine."Container Master Line No." := 0;
            WhseJournalLine.Delete(true);
        until WhseJournalLine.Next = 0;

        exit(true);
    end;

    local procedure UpdateWhseJnlLineForContainer(FldNo: Integer)
    var
        WhseJournalLine: Record "Warehouse Journal Line";
    begin
        // P8001323
        WhseJournalLine.SetRange("Journal Template Name", "Journal Template Name");
        WhseJournalLine.SetRange("Journal Batch Name", "Journal Batch Name");
        WhseJournalLine.SetRange("Location Code", "Location Code");
        WhseJournalLine.SetFilter("Line No.", '<>%1', "Line No.");
        WhseJournalLine.SetRange("Container Master Line No.", "Container Master Line No.");
        if WhseJournalLine.FindSet(true) then
            repeat
                case FldNo of
                    FieldNo("To Zone Code"):
                        begin
                            WhseJournalLine."To Zone Code" := "To Zone Code";
                            WhseJournalLine."To Bin Code" := '';
                        end;
                    FieldNo("To Bin Code"):
                        begin
                            WhseJournalLine."To Zone Code" := "To Zone Code";
                            WhseJournalLine."To Bin Code" := "To Bin Code";
                        end;
                    FieldNo("Reason Code"):
                        begin
                            WhseJournalLine."Reason Code" := "Reason Code";
                        end;
                end;
                WhseJournalLine.Modify;
            until WhseJournalLine.Next = 0;
    end;

    local procedure CheckMoveContainerForPhysical(ContainerHeader: Record "Container Header")
    var
        ContainerLine: Record "Container Line";
        TempContainerLine: Record "Container Line" temporary;
        WhseJournalLine: Record "Warehouse Journal Line";
        Qty: Decimal;
    begin
        // P8001323
        if (not "Phys. Inventory") or ("Bin Code" = ContainerHeader."Bin Code") then
            exit;

        ContainerLine.SetRange("Container ID", ContainerHeader.ID);
        ContainerLine.SetFilter(Quantity, '>0');
        if ContainerLine.FindSet then
            repeat
                TempContainerLine := ContainerLine;
                TempContainerLine.Insert;
            until ContainerLine.Next = 0;

        WhseJournalLine.SetRange("Journal Template Name", "Journal Template Name");
        WhseJournalLine.SetRange("Journal Batch Name", "Journal Batch Name");
        WhseJournalLine.SetRange("Location Code", "Location Code");
        WhseJournalLine.SetRange("Entry Type", WhseJournalLine."Entry Type"::"Negative Adjmt.");
        WhseJournalLine.SetRange("From Container ID", ContainerHeader.ID);
        if WhseJournalLine.FindSet then
            repeat
                TempContainerLine.SetRange("Item No.", WhseJournalLine."Item No.");
                TempContainerLine.SetRange("Variant Code", WhseJournalLine."Variant Code");
                TempContainerLine.SetRange("Lot No.", WhseJournalLine."Lot No.");
                TempContainerLine.SetRange("Serial No.", WhseJournalLine."Serial No.");
                TempContainerLine.SetRange("Unit of Measure Code", WhseJournalLine."Unit of Measure Code");
                if TempContainerLine.FindSet then
                    repeat
                        if Abs(WhseJournalLine.Quantity) < TempContainerLine.Quantity then
                            Qty := Abs(WhseJournalLine.Quantity)
                        else
                            Qty := TempContainerLine.Quantity;
                        WhseJournalLine.Quantity += Qty; // Negative quantity on warehouse journal line
                        TempContainerLine.Quantity -= Qty;
                        if TempContainerLine.Quantity = 0 then
                            TempContainerLine.Delete
                        else
                            TempContainerLine.Modify;
                    until (TempContainerLine.Next = 0) or (WhseJournalLine.Quantity = 0);
            until WhseJournalLine.Next = 0;

        TempContainerLine.Reset;
        if not TempContainerLine.IsEmpty then
            TestField("Bin Code", ContainerHeader."Bin Code");
    end;

    procedure IsOpenedFromBatch(): Boolean
    var
        WarehouseJournalBatch: Record "Warehouse Journal Batch";
        TemplateFilter: Text;
        BatchFilter: Text;
    begin
        BatchFilter := GetFilter("Journal Batch Name");
        if BatchFilter <> '' then begin
            TemplateFilter := GetFilter("Journal Template Name");
            if TemplateFilter <> '' then
                WarehouseJournalBatch.SetFilter("Journal Template Name", TemplateFilter);
            WarehouseJournalBatch.SetFilter(Name, BatchFilter);
            WarehouseJournalBatch.FindFirst;
        end;

        exit((("Journal Batch Name" <> '') and ("Journal Template Name" = '')) or (BatchFilter <> ''));
    end;

    local procedure FindExistingBatch(CurrentJnlTemplateName: Code[10]; var CurrentLocationCode: Code[10]; var CurrentJnlBatchName: Code[10]): Boolean
    var
        WhseJnlBatch: Record "Warehouse Journal Batch";
    begin
        WhseJnlBatch.SetRange("Journal Template Name", CurrentJnlTemplateName);
        WhseJnlBatch.SetRange(Name, CurrentJnlBatchName);

        if IsWarehouseEmployeeLocationDirectPutAwayAndPick(CurrentLocationCode) then begin
            WhseJnlBatch.SetRange("Location Code", CurrentLocationCode);
            if not WhseJnlBatch.IsEmpty() then
                exit(true);
        end;

        WhseJnlBatch.SetRange(Name);
        CurrentLocationCode := WMSMgt.GetDefaultDirectedPutawayAndPickLocation;
        WhseJnlBatch.SetRange("Location Code", CurrentLocationCode);

        if WhseJnlBatch.FindFirst then begin
            CurrentJnlBatchName := WhseJnlBatch.Name;
            exit(true);
        end;

        WhseJnlBatch.SetRange("Location Code");

        if WhseJnlBatch.FindSet then begin
            repeat
                if IsWarehouseEmployeeLocationDirectPutAwayAndPick(WhseJnlBatch."Location Code") then begin
                    CurrentLocationCode := WhseJnlBatch."Location Code";
                    CurrentJnlBatchName := WhseJnlBatch.Name;
                    exit(true);
                end;
            until WhseJnlBatch.Next() = 0;
        end;

        exit(false);
    end;

    local procedure IsWarehouseEmployeeLocationDirectPutAwayAndPick(LocationCode: Code[10]): Boolean
    var
        Location: Record Location;
        WarehouseEmployee: Record "Warehouse Employee";
    begin
        if Location.Get(LocationCode) and Location."Directed Put-away and Pick" then
            exit(WarehouseEmployee.Get(UserId, Location.Code));

        exit(false);
    end;

    local procedure UpdateLotInfo()
    var
        LotNoInformation: Record "Lot No. Information";
    begin
        // P80041932
        "Expiration Date" := 0D;
        if LotNoInformation.Get("Item No.", "Variant Code", "Lot No.") then
            "Expiration Date" := LotNoInformation."Expiration Date";
        "New Lot No." := "Lot No.";
        "New Expiration Date" := "Expiration Date";
        // P80041932
    end;

    procedure UpdateItemTrackingLine()
    begin
        // P80041932
        if ItemTrackingMgt.WhseItemTrkgLineExists("Journal Batch Name", DATABASE::"Warehouse Journal Line", 0, "Journal Template Name", 0, "Line No.", "Location Code", "Serial No.", "Lot No.") then
            ItemTrackingMgt.DeleteWhseItemTrkgLines(DATABASE::"Warehouse Journal Line", 0, "Journal Batch Name", "Journal Template Name", 0, "Line No.", "Location Code", true);
        InsertItemTrackingLine;
        // P80041932
    end;

    local procedure InsertItemTrackingLine()
    var
        LotNoInformation: Record "Lot No. Information";
        WhseItemTrackingForm: Page "Whse. Item Tracking Lines";
        TempWhseWkshLine: Record "Whse. Worksheet Line" temporary;
        WarehouseEntry: Record "Warehouse Entry";
    begin
        // P80041932
        if "Lot No." <> '' then begin
            if not LotNoInformation.Get("Item No.", "Variant Code", "Lot No.") then begin
                LotNoInformation.Validate("Item No.", "Item No.");  // P80043725
                LotNoInformation."Variant Code" := "Variant Code";
                LotNoInformation."Lot No." := "Lot No.";
                LotNoInformation.Insert;
            end;
            if "Expiration Date" <> 0D then begin
                LotNoInformation."Expiration Date" := "Expiration Date";
                LotNoInformation.Modify;
            end;
        end;
        // P80048582
        TempWhseWkshLine.Init;
        TempWhseWkshLine."Worksheet Template Name" := "Journal Template Name";
        TempWhseWkshLine."Whse. Document Type" := DATABASE::"Warehouse Journal Line";
        TempWhseWkshLine."Whse. Document No." := "Journal Batch Name";
        TempWhseWkshLine."Whse. Document Line No." := "Line No.";

        TempWhseWkshLine.Name := "Journal Batch Name";
        TempWhseWkshLine."Location Code" := "Location Code";
        TempWhseWkshLine."Line No." := "Line No.";
        TempWhseWkshLine."Item No." := "Item No.";
        TempWhseWkshLine."Variant Code" := "Variant Code";
        TempWhseWkshLine."Qty. (Base)" := Abs("Qty. (Base)");
        TempWhseWkshLine."Qty. to Handle (Base)" := Abs("Qty. (Base)");

        WhseItemTrackingForm.SetSource(TempWhseWkshLine, DATABASE::"Warehouse Journal Line");
        WhseItemTrackingForm.SetReclassData("New Serial No.", "New Lot No.", "New Expiration Date"); // P80069310
        // P800-MegaApp
        WarehouseEntry."Serial No." := "Serial No.";
        WarehouseEntry."Lot No." := "Lot No.";
        WarehouseEntry."Expiration Date" := "Expiration Date";
        // P800-MegaApp
        WhseItemTrackingForm.InsertItemTrackingLine(TempWhseWkshLine, WarehouseEntry, TempWhseWkshLine."Qty. (Base)"); // P800-MegaApp
        // P80041932
        // P80048582
    end;

    procedure CheckTrackingIfRequired(WhseItemTrackingSetup: Record "Item Tracking Setup")
    begin
        if WhseItemTrackingSetup."Serial No. Required" then
            TestField("Serial No.");
        if WhseItemTrackingSetup."Lot No. Required" then
            TestField("Lot No.");

        OnAfterCheckTrackingIfRequired(Rec, WhseItemTrackingSetup);
    end;

    procedure CopyTrackingFromItemLedgEntry(ItemLedgEntry: Record "Item Ledger Entry")
    begin
        "Serial No." := ItemLedgEntry."Serial No.";
        "Lot No." := ItemLedgEntry."Lot No.";

        OnAfterCopyTrackingFromItemLedgEntry(Rec, ItemLedgEntry);
    end;

    procedure CopyTrackingFromItemTrackingSetupIfRequired(WhseItemTrackingSetup: Record "Item Tracking Setup")
    begin
        if WhseItemTrackingSetup."Serial No. Required" then
            "Serial No." := WhseItemTrackingSetup."Serial No.";
        if WhseItemTrackingSetup."Lot No. Required" then
            "Lot No." := WhseItemTrackingSetup."Lot No.";

        OnAfterCopyTrackingFromItemTrackingSetupIfRequired(Rec, WhseItemTrackingSetup);
    end;

    procedure CopyNewTrackingFromItemTrackingSetupIfRequired(WhseItemTrackingSetup: Record "Item Tracking Setup")
    begin
        if WhseItemTrackingSetup."Serial No. Required" then
            "New Serial No." := WhseItemTrackingSetup."Serial No.";
        if WhseItemTrackingSetup."Lot No. Required" then
            "New Lot No." := WhseItemTrackingSetup."Lot No.";

        OnAfterCopyNewTrackingFromItemTrackingSetupIfRequired(Rec, WhseItemTrackingSetup);
    end;

    procedure CopyTrackingFromWhseActivityLine(WhseActivityLine: Record "Warehouse Activity Line")
    begin
        "Serial No." := WhseActivityLine."Serial No.";
        "Lot No." := WhseActivityLine."Lot No.";

        OnAfterCopyTrackingFromWhseActivityLine(Rec, WhseActivityLine);
    end;

    procedure CopyTrackingFromWhseEntry(WhseEntry: Record "Warehouse Entry")
    begin
        "Serial No." := WhseEntry."Serial No.";
        "Lot No." := WhseEntry."Lot No.";

        OnAfterCopyTrackingFromWhseEntry(Rec, WhseEntry);
    end;

    procedure SetSource(SourceType: Integer; SourceSubtype: Integer; SourceNo: Code[20]; SourceLineNo: Integer; SourceSublineNo: Integer)
    begin
        "Source Type" := SourceType;
        if SourceSubtype >= 0 then
            "Source Subtype" := SourceSubtype;
        "Source No." := SourceNo;
        "Source Line No." := SourceLineNo;
        if SourceSublineNo >= 0 then
            "Source Subline No." := SourceSublineNo;
    end;

#if not CLEAN17
    [Obsolete('Replaced by CopyTrackingFrom procedures.', '17.0')]
    procedure SetTracking(SerialNo: Code[50]; LotNo: Code[50]; WarrantyDate: Date; ExpirationDate: Date)
    begin
        "Serial No." := SerialNo;
        "Lot No." := LotNo;
        "Warranty Date" := WarrantyDate;
        "Expiration Date" := ExpirationDate;
    end;
#endif

    procedure SetTrackingFilterFromBinContent(var BinContent: Record "Bin Content")
    begin
        SetFilter("Serial No.", BinContent.GetFilter("Serial No. Filter"));
        SetFilter("Lot No.", BinContent.GetFilter("Lot No. Filter"));

        OnAfterSetTrackingFilterFromBinContent(Rec, BinContent);
    end;

#if not CLEAN19
    [Obsolete('Replaced by SetWhseDocument().', '19.0')]
    procedure SetWhseDoc(DocType: Option; DocNo: Code[20]; DocLineNo: Integer)
    begin
        SetWhseDocument("Warehouse Journal Document Type".FromInteger(DocType), DocNo, DocLineNo);
    end;
#endif

    procedure SetWhseDocument(DocType: Enum "Warehouse Journal Document Type"; DocNo: Code[20]; DocLineNo: Integer)
    begin
        "Whse. Document Type" := DocType;
        "Whse. Document No." := DocNo;
        "Whse. Document Line No." := DocLineNo;
    end;

    procedure SetExpirationDateEditable(var pExpirationDateEditable: Boolean)
    var
        LotNoInfo: Record "Lot No. Information";
    begin
        // P80092144
        pExpirationDateEditable := (("Qty. (Base)" > 0) or (not LotNoInfo.Get("Item No.", "Variant Code", "Lot No.")));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckTrackingIfRequired(var WhseJnlLine: Record "Warehouse Journal Line"; WhseItemTrackingSetup: Record "Item Tracking Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyTrackingFromItemLedgEntry(var WhseJnlLine: Record "Warehouse Journal Line"; ItemLedgEntry: Record "Item Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyTrackingFromItemTrackingSetupIfRequired(var WhseJnlLine: Record "Warehouse Journal Line"; WhseItemTrackingSetup: Record "Item Tracking Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyNewTrackingFromItemTrackingSetupIfRequired(var WhseJnlLine: Record "Warehouse Journal Line"; WhseItemTrackingSetup: Record "Item Tracking Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyTrackingFromWhseActivityLine(var WarehouseJournalLine: Record "Warehouse Journal Line"; WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyTrackingFromWhseEntry(var WarehouseJournalLine: Record "Warehouse Journal Line"; WarehouseEntry: Record "Warehouse Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterOpenItemTrackingLines(var WarehouseJournalLine: Record "Warehouse Journal Line"; var WhseItemTrackingLines: Page "Whse. Item Tracking Lines")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterOpenJnl(var WarehouseJournalLine: Record "Warehouse Journal Line"; CurrentJnlBatchName: Code[10]; CurrentLocationCode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetupNewLine(var WarehouseJournalLine: Record "Warehouse Journal Line"; var LastWhseJnlLine: Record "Warehouse Journal Line"; WarehouseJournalTemplate: Record "Warehouse Journal Template");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetName(var RecWarehouseJournalLine: Record "Warehouse Journal Line"; var WarehouseJournalLine: Record "Warehouse Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetTrackingFilterFromBinContent(var WarehouseJournalLine: Record "Warehouse Journal Line"; var BinContent: Record "Bin Content")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckBin(var WarehouseJournalLine: Record "Warehouse Journal Line"; LocationCode: Code[10]; BinCode: Code[20]; Inbound: Boolean; var IsHandled: Boolean; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckIncreaseBin(WarehouseJournalLine: Record "Warehouse Journal Line"; BinCode: Code[20]; StockProposal: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckName(var JnlBatchName: Code[10]; var LocationCode: Code[10]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckQtyPhysInventory(var WarehouseJournalLine: Record "Warehouse Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckSerialNoTrackedQuantity(var WarehouseJournalLine: Record "Warehouse Journal Line"; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckTemplateName(var JnlTemplateName: Code[10]; var JnlBatchName: Code[10]; var LocationCode: Code[10]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetLocation(var Location: Record Location; LocationCode: Code[10]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetWhseJnlBatch(var WarehouseJournalLine: Record "Warehouse Journal Line"; var WhseJnlBatch: Record "Warehouse Journal Batch"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLookupBinCode(var WarehouseJournalLine: Record "Warehouse Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLookupFromBinCode(var WarehouseJournalLine: Record "Warehouse Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOpenItemTrackingLines(var WarehouseJournalLine: Record "Warehouse Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOpenJnl(var WarehouseJournalLine: Record "Warehouse Journal Line"; var CurrentJnlBatchName: Code[10]; CurrentLocationCode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetItemFields(var WarehouseJournalLine: Record "Warehouse Journal Line"; var IsHandled: Boolean; xWarehouseJournalLine: Record "Warehouse Journal Line"; Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTemplateSelectionFromBatch(var WarehouseJournalLine: Record "Warehouse Journal Line"; WarehouseJournalBatch: Record "Warehouse Journal Batch")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateQtyBase(var WarehouseJournalLine: Record "Warehouse Journal Line"; xWarehouseJournalLine: Record "Warehouse Journal Line"; CallingFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckBinOnBeforeCheckOutboundBin(var WarehouseJournalLine: Record "Warehouse Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLookupNameOnBeforeSetName(var WarehouseJournalLine: Record "Warehouse Journal Line"; WhseJnlBatch: Record "Warehouse Journal Batch")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnOpenItemTrackingLinesOnBeforeSetSource(var WhseWorksheetLine: Record "Whse. Worksheet Line"; WarehouseJournalLine: Record "Warehouse Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetUpNewLineOnAfterWhseJnlLineSetFilters(var RecWarehouseJournalLine: Record "Warehouse Journal Line"; WarehouseJournalLine: Record "Warehouse Journal Line"; LastWarehouseJournalLine: Record "Warehouse Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnTemplateSelectionOnAfterSetFilters(var WarehouseJournalLine: Record "Warehouse Journal Line"; var WhseJnlTemplate: Record "Warehouse Journal Template"; OpenFromBatch: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateQuantityOnAfterCalcBaseQty(var WarehouseJournalLine: Record "Warehouse Journal Line"; xWarehouseJournalLine: Record "Warehouse Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateUnitOfMeasureCodeOnBeforeValidateQuantity(var WarehouseJournalLine: Record "Warehouse Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateToBinCodeOnBeforeSetToZoneCode(var WarehouseJournalLine: Record "Warehouse Journal Line"; var Bin: Record Bin)
    begin
    end;
}

