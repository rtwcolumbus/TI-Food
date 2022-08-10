table 5741 "Transfer Line"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 09-10-2014, Initial Version
    // --------------------------------------------------------------------------------
    // 
    // PR3.61
    //   Add Fields
    //     Alt. Qty. Trans. No. (Ship)
    //     Quantity (Alt.)
    //     Qty. to Ship (Alt.)
    //     Qty. Shipped (Alt.)
    //     Net Weight to Ship
    //     Alt. Qty. Trans. No. (Receive)
    //     Qty. to Receive (Alt.)
    //     Qty. Received (Alt.)
    //     Type
    //     Qty. to Ship (Cont.)
    //     Qty. to Receive (Cont.)
    //   Add logic for alternate quantities
    //   Add logic for container tracking
    // 
    // PR3.61.01
    //   Fix problems with alternate quantities
    // 
    // PR3.70.01
    //   Fix InitQtyToReceive to initialize alternate quantity
    // 
    // PR3.70.04
    // P8000045B, Myers Nissi, Jack Reynolds, 22 MAY 04
    //   Delete existing alternate quantity lines when validating Item No.
    // 
    // P8000043A, Myers Nissi, Jack Reynolds, 02 JUN 04
    //    Support for easy lot tracking
    // 
    // PR3.70.06
    // P8000083A, Myers Nissi, Steve Post, 09 AUG 04
    //   added code to updatelinetracking function to allow
    //   lotted and unlotted items on the same document
    // 
    // PR3.70.09
    // P8000194A, Myers Nissi, Jack Reynolds, 24 FEB 05
    //   Fix easy lot tracking problem to save record before creating tracking lines
    // 
    // PR3.70.10
    // P8000227A, Myers Nissi, Jack Reynolds, 07 JUL 05
    //   Fix problem specifying lot before line has been inserted
    // 
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Integrate alternate quantity with WMS
    // 
    // PR.00.04
    // P8000322A, VerticalSoft, Don Bresee, 05 SEP 06
    //   Add Staged Quantity
    // 
    // P8000383A, VerticalSoft, Jack Reynolds, 22 SEP 06
    //   Insure that unit of measure is different type from alternate unit of measure
    // 
    // P8000372A, VerticalSoft, Phyllis McGovern, 06 SEP 06
    //   WH Overship and OverReceive
    //   Added field: 'allow quantity change'
    // 
    // PW15.00.01
    // P8000550A, VerticalSoft, Don Bresee, 05 MAR 08
    //   Add logic for new calculation of base and alternate quantities
    // 
    // PRW15.00.03
    // P8000629A, VerticalSoft, Jack Reynolds, 21 SEP 08
    //   Update easy lot tracking for 3-document locations
    // 
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add 1-Doc Whse Logic
    // 
    // PRW16.00.02
    // P8000746, VerticalSoft, Jack Reynolds, 22 FEB 10
    //   Fix to allow over shipping from ADC
    // 
    // PRW16.00.05
    // P8000928, Columbus IT, Jack Reynolds, 06 APR 11
    //   Support for Extra Charges
    // 
    // P8000931, Columbus IT, Jack Reynolds, 20 APR 11
    //   Support for Supply Chain Groups
    // 
    // P8000954, Columbus IT, Jack Reynolds, 08 JUL 11
    //   Support for transfer orders on delivery routes and trips
    // 
    // PRW16.00.06
    // P8001032, Columbus IT, Jack Reynolds, 02 FEB 12
    //   Correct flaw in design of Document Extra Charge table
    // 
    // P8001047, Columbus IT, Jack Reynolds, 30 MAR 12
    //   Receiving Labels
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.10.03
    // P8001309, Columbus IT, Jack Reynolds, 02 APR 14
    //   Fix problem increasing quantity on transfer line
    // 
    // P8001328, Columbus IT, Jack Reynolds, 13 JUN 14
    //   Fix problem with label UOM and contaainer lines
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality
    // 
    // PRW19.00
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup old delivery trips
    // 
    // PRW19.00.01
    // P8007536, To-Increase, Dayakar Battini, 12 AUG 16
    //   Item Tracking quantity update when Over shipment.
    // 
    // P8006916, To-Increase, Jack Reynolds, 31 AUG 16
    //   FOOD-TOM Separation
    // 
    // PRW110.0.01
    // P80041198, To-Increase, Jack Reynolds, 08 MAY 17
    //   General changes and refactoring for NAV 2017 CU7
    // 
    // PRW110.0.02
    // P80050544, To-Increase, Dayakar Battini, 12 FEB 18
    //   Upgrade to 2017 CU13
    // P80039781, To-Increase, Jack Reynolds, 10 DEC 17
    //   Warehouse Shipping process
    // 
    // PRW110.0.02
    // P80046533, To-Increase, Jack Reynolds, 10 OCT 17
    //   Inbound containers and shipping containers
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.03
    // P80081811, To-Increase, Gangabhushan, 30 OCT 19
    //   Catchweight item while doing transfer system allowing for Qty to ship Qty.
    // 
    // P800108868, To-Increase, Gangabhushan, 20 OCT 20
    //   CS00129745 | Transfer Receiving Issue    
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00 
    //
    // PRW115.03
    // P800110503, To Increase, Jack Reynolds, 02 NOV 20
    //   Restore original SyuspendStatusCheck and add new SuspendStatusCheck2 with return value
    //
    // PRW118.01
    // P800128960, To Increase, Jack Reynolds, 24 AUG 21
    //   Decimal precision on alternate quantity data entry

    Caption = 'Transfer Line';
    DrillDownPageID = "Transfer Lines";
    LookupPageID = "Transfer Lines";

    fields
    {
        field(37002004; "Allow Quantity Change"; Boolean)
        {
            Caption = 'Allow Quantity Change';
        }
        field(37002015; "Supply Chain Group Code"; Code[10])
        {
            Caption = 'Supply Chain Group Code';
            TableRelation = "Supply Chain Group";
        }
        field(37002020; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            Description = 'PR3.70.04';

            trigger OnValidate()
            begin
                // P8000043A
                if "Line No." <> 0 then begin // P8000227A
                    Modify; // P8000194A
                    UpdateLotTracking(true, gDirection); // P8007536, P800108868
                end;                          // P8000227A
                // P8000043A
            end;
        }
        field(37002080; "Alt. Qty. Trans. No. (Ship)"; Integer)
        {
            Caption = 'Alt. Qty. Trans. No. (Ship)';
            Description = 'PR3.61';
            Editable = false;
        }
        field(37002081; "Quantity (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,1,0,%1,%2', Type, "Item No.");
            Caption = 'Quantity (Alt.)';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.61';
            Editable = false;
        }
        field(37002082; "Qty. to Ship (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            AutoFormatExpression = "Item No.";
            AutoFormatType = 37002080;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,1,1,%1,%2', Type, "Item No.");
            Caption = 'Qty. to Ship (Alt.)';
            Description = 'PR3.61';

            trigger OnValidate()
            begin
                // PR3.61
                P800CoreFns.CheckTransferLineFieldEditable(Rec, FieldNo("Qty. to Ship (Alt.)"), CurrFieldNo); // PR3.61
                AltQtyMgmt.TestTransAltQtyInfo(Rec, 0, false);

                GetItem;
                if (CurrFieldNo = FieldNo("Qty. to Ship (Alt.)")) then begin
                    Item.TestField("Catch Alternate Qtys.", true);
                    TestField("Qty. to Ship");
                    // TestStatusOpen; // P8000282A
                    AltQtyMgmt.CheckSummaryTolerance1("Alt. Qty. Trans. No. (Ship)", "Item No.",
                      FieldCaption("Qty. to Ship (Alt.)"), "Qty. to Ship (Base)", "Qty. to Ship (Alt.)");
                end;

                AltQtyMgmt.SetTransLineAltQty(Rec);
                // PR3.61
            end;
        }
        field(37002083; "Qty. Shipped (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,1,2,%1,%2', Type, "Item No.");
            Caption = 'Qty. Shipped (Alt.)';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.61';
            Editable = false;
        }
        field(37002084; "Net Weight to Ship"; Decimal)
        {
            Caption = 'Net Weight to Ship';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.61';
        }
        field(37002085; "Alt. Qty. Trans. No. (Receive)"; Integer)
        {
            Caption = 'Alt. Qty. Trans. No. (Receive)';
            Description = 'PR3.61';
            Editable = false;
        }
        field(37002086; "Qty. to Receive (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            AutoFormatExpression = "Item No.";
            AutoFormatType = 37002080;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,1,3,%1,%2', Type, "Item No.");
            Caption = 'Qty. to Receive (Alt.)';
            Description = 'PR3.61';

            trigger OnValidate()
            begin
                // PR3.61
                P800CoreFns.CheckTransferLineFieldEditable(Rec, FieldNo("Qty. to Receive (Alt.)"), CurrFieldNo); // PR3.61, P8000282A
                AltQtyMgmt.TestTransAltQtyInfo(Rec, 1, false);

                GetItem;
                if (CurrFieldNo = FieldNo("Qty. to Receive (Alt.)")) then begin
                    Item.TestField("Catch Alternate Qtys.", true);
                    TestField("Qty. to Receive");
                    // TestStatusOpen; // P8000282A
                    AltQtyMgmt.CheckSummaryTolerance1("Alt. Qty. Trans. No. (Receive)", "Item No.",
                      FieldCaption("Qty. to Receive (Alt.)"),
                      "Qty. to Receive (Base)", "Qty. to Receive (Alt.)");
                end;
                // PR3.61
            end;
        }
        field(37002087; "Qty. Received (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,1,4,%1,%2', Type, "Item No.");
            Caption = 'Qty. Received (Alt.)';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.61';
            Editable = false;
        }
        field(37002560; Type; Option)
        {
            Caption = 'Type';
            Description = 'PR3.61';
            OptionCaption = 'Item,Container';
            OptionMembers = Item,Container;

            trigger OnValidate()
            begin
                // P8001090
                if ProcessFns.ProcessDataCollectionInstalled then
                    DataCollectionMgmt.CheckTransLineModify(xRec, Rec);
                // P8001090
            end;
        }
        field(37002663; "Extra Charge"; Decimal)
        {
            AccessByPermission = TableData "Extra Charge" = R;
            AutoFormatType = 1;
            CalcFormula = Sum("Document Extra Charge".Charge WHERE("Table ID" = CONST(1),
                                                                    "Document No." = FIELD("Document No."),
                                                                    "Line No." = FIELD("Line No.")));
            Caption = 'Extra Charge';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002700; "Label Unit of Measure Code"; Code[10])
        {
            Caption = 'Label Unit of Measure Code';
            TableRelation = IF (Type = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            var
                ItemUOM: Record "Item Unit of Measure";
            begin
                // P8001047
                if Type <> Type::Item then
                    TestField("Label Unit of Measure Code", '');
            end;
        }
        field(37002760; "Staged Quantity"; Decimal)
        {
            CalcFormula = Sum("Whse. Staged Pick Source Line"."Qty. Outstanding" WHERE("Source Type" = CONST(5741),
                                                                                        "Source Subtype" = CONST("0"),
                                                                                        "Source No." = FIELD("Document No."),
                                                                                        "Source Line No." = FIELD("Line No.")));
            Caption = 'Staged Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = IF (Type = CONST(Item)) Item WHERE(Type = CONST(Inventory),
                                                              Blocked = CONST(false))
            ELSE
            IF (Type = CONST(Container)) Item WHERE(Type = CONST(FOODContainer));
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                TempTransferLine: Record "Transfer Line" temporary;
            begin
                TestField("Quantity Shipped", 0);
                if CurrFieldNo <> 0 then
                    TestStatusOpen;
                TestContainerQuantityIsZero(0); // P80046533
                "Item No." := GetItemNo();
                TransferLineReserve.VerifyChange(Rec, xRec);
                CalcFields("Reserved Qty. Inbnd. (Base)");
                TestField("Reserved Qty. Inbnd. (Base)", 0);
                WhseValidateSourceLine.TransLineVerifyChange(Rec, xRec);

                if "Alt. Qty. Trans. No. (Ship)" <> 0 then                        // P8000045B
                    AltQtyMgmt.DeleteAltQtyLines("Alt. Qty. Trans. No. (Ship)");    // P8000045B
                if "Alt. Qty. Trans. No. (Receive)" <> 0 then                     // P8000045B
                    AltQtyMgmt.DeleteAltQtyLines("Alt. Qty. Trans. No. (Receive)"); // P8000045B

                TempTransferLine := Rec;
                Init;
                Type := TempTransferLine.Type; // PR3.61
                //"Alt. Qty. Trans. No. (Ship)" := TempTransferLine."Alt. Qty. Trans. No. (Ship)"; // PR3.61, P8000045B
                //"Alt. Qty. Trans. No. (Receive)" := TempTransferLine."Alt. Qty. Trans. No. (Receive)"; // PR3.61.01, P8000045B
                "Item No." := TempTransferLine."Item No.";
                OnValidateItemNoOnCopyFromTempTransLine(Rec, TempTransferLine);
                if "Item No." = '' then
                    exit;

                OnValidateItemNoOnAfterInitLine(Rec, TempTransferLine);

                GetTransHeaderExternal();

                OnValidateItemNoOnAfterGetTransHeaderExternal(Rec, TransHeader, TempTransferLine);
                GetItem;
                GetDefaultBin("Transfer-from Code", "Transfer-to Code");

                Item.TestField(Blocked, false);
                if Type = Type::Item then // P80053245
                    Item.TestField(Type, Item.Type::Inventory);

                Description := Item.Description;
                "Description 2" := Item."Description 2";
                Validate("Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group");
                Validate("Inventory Posting Group", Item."Inventory Posting Group");
                Validate(Quantity, xRec.Quantity);
                Validate("Unit of Measure Code", Item."Base Unit of Measure");
                if Type <> Type::Container then // P8001328
                    Validate("Label Unit of Measure Code", Item."Label Unit of Measure"); // P8001047
                Validate("Gross Weight", Item."Gross Weight");
                Validate("Net Weight", Item."Net Weight");
                Validate("Unit Volume", Item."Unit Volume");
                Validate("Units per Parcel", Item."Units per Parcel");
                "Item Category Code" := Item."Item Category Code";
                "Supply Chain Group Code" := Item.GetSupplyChainGroupCode; // P8000931
                // PR3.61 Begin
                if Item.TrackAlternateUnits and Item."Catch Alternate Qtys." then begin // PR3.61.01
                    AltQtyMgmt.AssignNewTransactionNo("Alt. Qty. Trans. No. (Ship)");
                    AltQtyMgmt.AssignNewTransactionNo("Alt. Qty. Trans. No. (Receive)");  // PR3.61.01
                end else begin                                                          // PR3.61.01
                    "Alt. Qty. Trans. No. (Ship)" := 0;
                    "Alt. Qty. Trans. No. (Receive)" := 0;                                // PR3.61.01
                end;                                                                    // PR3.61.01
                // PR3.61 End

                OnAfterAssignItemValues(Rec, Item);

                OnAfterAssignItemValues(Rec, Item);

                OnAfterAssignItemValues(Rec, Item);

                CreateDim(DATABASE::Item, "Item No.");
                DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            end;
        }
        field(4; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                P800CoreFns.CheckTransferLineFieldEditable(Rec, FieldNo(Quantity), CurrFieldNo); // PR3.61
                if CurrFieldNo <> 0 then
                    TestStatusOpen;
                if Quantity <> 0 then
                    TestField("Item No.");

                Quantity := UOMMgt.RoundAndValidateQty(Quantity, "Qty. Rounding Precision", FieldCaption(Quantity));

                "Quantity (Base)" := CalcBaseQty(Quantity, FieldCaption(Quantity), FieldCaption("Quantity (Base)"));
                OnValidateQuantityOnAfterCalcQuantityBase(Rec, xRec);
                if ((Quantity * "Quantity Shipped") < 0) or
                   (Abs(Quantity) < Abs("Quantity Shipped"))
                then
                    FieldError(Quantity, StrSubstNo(Text002, FieldCaption("Quantity Shipped")));
                if (("Quantity (Base)" * "Qty. Shipped (Base)") < 0) or
                   (Abs("Quantity (Base)") < Abs("Qty. Received (Base)"))
                then
                    FieldError("Quantity (Base)", StrSubstNo(Text002, FieldCaption("Qty. Shipped (Base)")));
                InitQtyInTransit;
                InitOutstandingQty;
                InitQtyToShip;
                InitQtyToReceive;
                CheckItemAvailable(FieldNo(Quantity));

                if Modify then; // P8001309
                UpdateLotTracking(false, 0); // P8000043A
                UpdateLotTracking(false, 1); // P8000043A
                VerifyReserveTransferLineQuantity();

                UpdateWithWarehouseShipReceive;

                IsHandled := false;
                OnValidateQuantityOnBeforeTransLineVerifyChange(Rec, xRec, IsHandled);
                if not IsHandled then
                    if not "Allow Quantity Change" then // P8000746
                        WhseValidateSourceLine.TransLineVerifyChange(Rec, xRec);
            end;
        }
        field(5; "Unit of Measure"; Text[50])
        {
            Caption = 'Unit of Measure';

            trigger OnValidate()
            begin
                if CurrFieldNo <> 0 then
                    TestStatusOpen;
                TestContainerQuantityIsZero(0); // P80046533
            end;
        }
        field(6; "Qty. to Ship"; Decimal)
        {
            Caption = 'Qty. to Ship';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                P800CoreFns.CheckTransferLineFieldEditable(Rec, FieldNo("Qty. to Ship"), CurrFieldNo); // PR3.61
                GetLocation("Transfer-from Code");
                if CurrFieldNo <> 0 then begin
                    if Location."Require Shipment" and
                       ("Qty. to Ship" <> 0)
                    then
                        CheckWarehouse(Location, false);
                    WhseValidateSourceLine.TransLineVerifyChange(Rec, xRec);
                end;

                if CurrFieldNo <> 0 then // P80046533
                                         // PR3.61 Begin
                    if GetContainerQuantity(0, true) > 0 then                // P80046533
                        if "Qty. to Ship" < GetContainerQuantity(0, true) then // P80046533
                            FieldError("Qty. to Ship", Text37002000);
                // PR3.61 End


                CheckItemCanBeShipped();

                // P8000550A
                // "Qty. to Ship (Base)" := CalcBaseQty("Qty. to Ship", FieldCaption("Qty. to Ship"), FieldCaption("Qty. to Ship (Base)"));
                if ("Qty. to Ship" = "Outstanding Quantity") then
                    "Qty. to Ship (Base)" := "Outstanding Qty. (Base)"
                else
                    "Qty. to Ship (Base)" := CalcBaseQty("Quantity Shipped" + "Qty. to Ship", FieldCaption("Qty. to Ship"), FieldCaption("Qty. to Ship (Base)")) - "Qty. Shipped (Base)"; // P800-MegaApp 
                // P8000550A 
                UOMMgt.ValidateQtyIsBalanced(Quantity, "Quantity (Base)", "Qty. to Ship", "Qty. to Ship (Base)", "Quantity Shipped", "Qty. Shipped (Base)");

                if ("In-Transit Code" = '') and ("Quantity Shipped" = "Quantity Received") then
                    Validate("Qty. to Receive", "Qty. to Ship" - GetContainerQuantity(0, '')); // P80046533

                // PR3.61
                if (Type = Type::Item) and ("Item No." <> '') and TrackAlternateUnits then begin
                    // P8000550A
                    // AltQtyMgmt.InitAlternateQty("Item No.", "Alt. Qty. Trans. No. (Ship)",
                    //                             "Qty. to Ship (Base)", "Qty. to Ship (Alt.)");
                    AltQtyMgmt.InitAlternateQtyToHandle(
                      "Item No.", "Alt. Qty. Trans. No. (Ship)", "Quantity (Base)", "Qty. to Ship (Base)",
                      "Qty. Shipped (Base)", "Quantity (Alt.)", "Qty. Shipped (Alt.)", "Qty. to Ship (Alt.)");
                    // P8000550A
                    AltQtyMgmt.SetTransLineAltQty(Rec);
                end;
                // PR3.61

                UpdateLotTracking(false, 0); // P8000043A
            end;
        }
        field(7; "Qty. to Receive"; Decimal)
        {
            Caption = 'Qty. to Receive';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.61';
            MinValue = 0;

            trigger OnValidate()
            begin
                P800CoreFns.CheckTransferLineFieldEditable(Rec, FieldNo("Qty. to Receive"), CurrFieldNo); // PR3.61
                GetLocation("Transfer-to Code");
                if CurrFieldNo <> 0 then begin
                    if Location."Require Receive" and
                       ("Qty. to Receive" <> 0)
                    then
                        CheckWarehouse(Location, true);
                    WhseValidateSourceLine.TransLineVerifyChange(Rec, xRec);
                end;

                GetTransferHeaderNoVerification;

                if CurrFieldNo <> 0 then // P80046533
                                         // PR3.61 Begin
                    if GetContainerQuantity(1, true) > 0 then                   // P80046533
                        if "Qty. to Receive" < GetContainerQuantity(1, true) then // P80046533
                            FieldError("Qty. to Receive", Text37002000);
                // PR3.61 End

                if not TransHeader."Direct Transfer" and ("Direct Transfer" = xRec."Direct Transfer") then
                    if ("Qty. to Receive" + GetContainerQuantity(1, false)) > "Qty. in Transit" then // P80046533
                        if "Qty. in Transit" > 0 then
                            Error(
                              Text008,
                              "Qty. in Transit" - GetContainerQuantity(1, false)) // P80046533
                        else
                            Error(Text009);
                // P8000550A
                // "Qty. to Receive (Base)" := CalcBaseQty("Qty. to Receive", FieldCaption("Qty. to Receive"), FieldCaption("Qty. to Receive (Base)"));
                if ("Qty. to Receive" = "Qty. in Transit") then
                    "Qty. to Receive (Base)" := "Qty. in Transit (Base)"
                else
                    "Qty. to Receive (Base)" := CalcBaseQty("Quantity Received" + "Qty. to Receive", FieldCaption("Qty. to Receive"), FieldCaption("Qty. to Receive (Base)")) - "Qty. Received (Base)"; // P800-MegaApp
                UOMMgt.ValidateQtyIsBalanced(Quantity, "Quantity (Base)", "Qty. to Receive", "Qty. to Receive (Base)", "Quantity Received", "Qty. Received (Base)");

                if (Type = Type::Item) and ("Item No." <> '') and TrackAlternateUnits then
                    AltQtyMgmt.InitAlternateQtyToHandle(
                      "Item No.", "Alt. Qty. Trans. No. (Receive)", "Quantity (Base)", "Qty. to Receive (Base)",
                      "Qty. Received (Base)", "Quantity (Alt.)", "Qty. Received (Alt.)", "Qty. to Receive (Alt.)");
                // P8000550A

                UpdateLotTracking(false, 1); // P8000043A
            end;
        }
        field(8; "Quantity Shipped"; Decimal)
        {
            Caption = 'Quantity Shipped';
            DecimalPlaces = 0 : 5;
            Editable = false;

            trigger OnValidate()
            begin
                "Qty. Shipped (Base)" := CalcBaseQty("Quantity Shipped", FieldCaption("Quantity Shipped"), FieldCaption("Qty. Shipped (Base)"));
                InitQtyInTransit;
                InitOutstandingQty;
                InitQtyToShip;
                InitQtyToReceive;
            end;
        }
        field(9; "Quantity Received"; Decimal)
        {
            Caption = 'Quantity Received';
            DecimalPlaces = 0 : 5;
            Editable = false;

            trigger OnValidate()
            begin
                "Qty. Received (Base)" := CalcBaseQty("Quantity Received", FieldCaption("Quantity Received"), FieldCaption("Qty. Received (Base)"));
                InitQtyInTransit;
                InitOutstandingQty;
                InitQtyToReceive;
            end;
        }
        field(10; Status; Option)
        {
            Caption = 'Status';
            Editable = false;
            OptionCaption = 'Open,Released';
            OptionMembers = Open,Released;
        }
        field(11; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1),
                                                          Blocked = CONST(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(12; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2),
                                                          Blocked = CONST(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(13; Description; Text[100])
        {
            Caption = 'Description';
            TableRelation = Item WHERE(Type = CONST(Inventory),
                                        Blocked = CONST(false));
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                Item: Record Item;
                ReturnValue: Text[50];
                ItemDescriptionIsNo: Boolean;
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateDescription(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                if (StrLen(Description) <= MaxStrLen(Item."No.")) and ("Item No." <> '') then
                    ItemDescriptionIsNo := Item.Get(Description);

                if ("Item No." <> '') and (not ItemDescriptionIsNo) and (Description <> '') then begin
                    Item.SetFilter(Description, '''@' + ConvertStr(Description, '''', '?') + '''');
                    if not Item.FindFirst then
                        exit;
                    if Item."No." = "Item No." then
                        exit;
                    if ConfirmManagement.GetResponseOrDefault(
                        StrSubstNo(AnotherItemWithSameDescrQst, Item."No.", Item.Description), true)
                    then
                        Validate("Item No.", Item."No.");
                    exit;
                end;

                if Item.TryGetItemNoOpenCard(ReturnValue, Description, false, true, true) then
                    case ReturnValue of
                        '':
                            Description := xRec.Description;
                        "Item No.":
                            Description := xRec.Description;
                        else begin
                                CurrFieldNo := FieldNo("Item No.");
                                Validate("Item No.", CopyStr(ReturnValue, 1, MaxStrLen(Item."No.")));
                            end;
                    end;

                if "Item No." <> '' then
                    GetItem;
            end;
        }
        field(14; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";

            trigger OnValidate()
            begin
                if CurrFieldNo <> 0 then
                    TestStatusOpen;
            end;
        }
        field(15; "Inventory Posting Group"; Code[20])
        {
            Caption = 'Inventory Posting Group';
            TableRelation = "Inventory Posting Group";

            trigger OnValidate()
            begin
                if CurrFieldNo <> 0 then
                    TestStatusOpen;
            end;
        }
        field(16; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.61';
            MinValue = 0;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateQuantityBase(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;
		    
                P800CoreFns.CheckTransferLineFieldEditable(Rec, FieldNo("Quantity (Base)"), CurrFieldNo); // PR3.61
                if CurrFieldNo <> 0 then
                    TestStatusOpen;
                TestField("Qty. per Unit of Measure", 1);
                Validate(Quantity, "Quantity (Base)");
            end;
        }
        field(17; "Outstanding Qty. (Base)"; Decimal)
        {
            Caption = 'Outstanding Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(18; "Qty. to Ship (Base)"; Decimal)
        {
            Caption = 'Qty. to Ship (Base)';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.61';
            MinValue = 0;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateQtyToShipBase(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;
		    
                P800CoreFns.CheckTransferLineFieldEditable(Rec, FieldNo("Qty. to Ship (Base)"), CurrFieldNo); // PR3.61
                TestField("Qty. per Unit of Measure", 1);
                Validate("Qty. to Ship", "Qty. to Ship (Base)");
            end;
        }
        field(19; "Qty. Shipped (Base)"; Decimal)
        {
            Caption = 'Qty. Shipped (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(20; "Qty. to Receive (Base)"; Decimal)
        {
            Caption = 'Qty. to Receive (Base)';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.61';
            MinValue = 0;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateQtyToReceiveBase(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                P800CoreFns.CheckTransferLineFieldEditable(Rec, FieldNo("Qty. to Receive (Base)"), CurrFieldNo); // PR3.61
                TestField("Qty. per Unit of Measure", 1);
                Validate("Qty. to Receive", "Qty. to Receive (Base)");
            end;
        }
        field(21; "Qty. Received (Base)"; Decimal)
        {
            Caption = 'Qty. Received (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(22; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
        }
        field(23; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            Description = 'PR3.61';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            var
                UnitOfMeasure: Record "Unit of Measure";
            begin
                P800CoreFns.CheckTransferLineFieldEditable(Rec, FieldNo("Unit of Measure Code"), CurrFieldNo); // PR3.61
                if CurrFieldNo <> 0 then
                    TestStatusOpen;
                TestField("Quantity Shipped", 0);
                TestField("Qty. Shipped (Base)", 0);
                TestField("Quantity Received", 0);
                TestField("Qty. Received (Base)", 0);
                TransferLineReserve.VerifyChange(Rec, xRec);
                WhseValidateSourceLine.TransLineVerifyChange(Rec, xRec);
                if "Unit of Measure Code" = '' then
                    "Unit of Measure" := ''
                else begin
                    if not UnitOfMeasure.Get("Unit of Measure Code") then
                        UnitOfMeasure.Init();
                    "Unit of Measure" := UnitOfMeasure.Description;
                end;
                GetItem;
                // P8000383A
                if Item.TrackAlternateUnits then
                    AltQtyMgmt.CheckUOMDifferentFromAltUOM(Item, "Unit of Measure Code", FieldCaption("Unit of Measure Code"));
                // P8000383A
                Validate("Qty. per Unit of Measure", UOMMgt.GetQtyPerUnitOfMeasure(Item, "Unit of Measure Code"));
                "Gross Weight" := Item."Gross Weight" * "Qty. per Unit of Measure";
                "Net Weight" := Item."Net Weight" * "Qty. per Unit of Measure";
                "Unit Volume" := Item."Unit Volume" * "Qty. per Unit of Measure";
                "Units per Parcel" := Round(Item."Units per Parcel" / "Qty. per Unit of Measure", UOMMgt.QtyRndPrecision);
                "Qty. Rounding Precision" := UOMMgt.GetQtyRoundingPrecision(Item, "Unit of Measure Code");
                "Qty. Rounding Precision (Base)" := UOMMgt.GetQtyRoundingPrecision(Item, Item."Base Unit of Measure");

                Validate(Quantity);
            end;
        }
        field(24; "Outstanding Quantity"; Decimal)
        {
            Caption = 'Outstanding Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(25; "Gross Weight"; Decimal)
        {
            Caption = 'Gross Weight';
            DecimalPlaces = 0 : 5;
        }
        field(26; "Net Weight"; Decimal)
        {
            Caption = 'Net Weight';
            DecimalPlaces = 0 : 5;
        }
        field(27; "Unit Volume"; Decimal)
        {
            Caption = 'Unit Volume';
            DecimalPlaces = 0 : 5;
        }
        field(28; "Qty. Rounding Precision"; Decimal)
        {
            Caption = 'Qty. Rounding Precision';
            InitValue = 0;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 1;
            Editable = false;
        }
        field(29; "Qty. Rounding Precision (Base)"; Decimal)
        {
            Caption = 'Qty. Rounding Precision (Base)';
            InitValue = 0;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 1;
            Editable = false;
        }
        field(30; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            var
                ItemVariant: Record "Item Variant";
            begin
                if CurrFieldNo <> 0 then
                    TestStatusOpen;
                TestContainerQuantityIsZero(0); // P80046533
                TransferLineReserve.VerifyChange(Rec, xRec);
                WhseValidateSourceLine.TransLineVerifyChange(Rec, xRec);

                OnValidateVariantCodeOnBeforeCheckEmptyVariantCode(Rec, xRec, CurrFieldNo);
                if "Variant Code" = '' then
                    exit;

                GetDefaultBin("Transfer-from Code", "Transfer-to Code");
                ItemVariant.Get("Item No.", "Variant Code");
                Description := ItemVariant.Description;
                "Description 2" := ItemVariant."Description 2";

                CheckItemAvailable(FieldNo("Variant Code"));
            end;
        }
        field(31; "Units per Parcel"; Decimal)
        {
            Caption = 'Units per Parcel';
            DecimalPlaces = 0 : 5;
        }
        field(32; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
        }
        field(33; "In-Transit Code"; Code[10])
        {
            Caption = 'In-Transit Code';
            Editable = false;
            TableRelation = Location WHERE("Use As In-Transit" = CONST(true));

            trigger OnValidate()
            begin
                TestField("Quantity Shipped", 0);
            end;
        }
        field(34; "Qty. in Transit"; Decimal)
        {
            Caption = 'Qty. in Transit';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(35; "Qty. in Transit (Base)"; Decimal)
        {
            Caption = 'Qty. in Transit (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(36; "Transfer-from Code"; Code[10])
        {
            Caption = 'Transfer-from Code';
            Editable = false;
            TableRelation = Location;

            trigger OnValidate()
            begin
                TestField("Quantity Shipped", 0);
                if CurrFieldNo <> 0 then
                    TestStatusOpen;
                if "Transfer-from Code" <> xRec."Transfer-from Code" then begin
                    "Transfer-from Bin Code" := '';
                    GetDefaultBin("Transfer-from Code", '');
                end;

                OnValidateTransferFromCodeOnBeforeCheckItemAvailable(Rec);
                CheckItemAvailable(FieldNo("Transfer-from Code"));
                TransferLineReserve.VerifyChange(Rec, xRec);
                UpdateWithWarehouseShipReceive;
                WhseValidateSourceLine.TransLineVerifyChange(Rec, xRec);
            end;
        }
        field(37; "Transfer-to Code"; Code[10])
        {
            Caption = 'Transfer-to Code';
            Editable = false;
            TableRelation = Location;

            trigger OnValidate()
            begin
                TestField("Quantity Shipped", 0);
                if CurrFieldNo <> 0 then
                    TestStatusOpen;
                if "Transfer-to Code" <> xRec."Transfer-to Code" then begin
                    "Transfer-To Bin Code" := '';
                    GetDefaultBin('', "Transfer-to Code");
                end;

                OnValidateTransferToCodeOnBeforeVerifyChange(Rec);
                TransferLineReserve.VerifyChange(Rec, xRec);
                UpdateWithWarehouseShipReceive;
                WhseValidateSourceLine.TransLineVerifyChange(Rec, xRec);
            end;
        }
        field(38; "Shipment Date"; Date)
        {
            Caption = 'Shipment Date';

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                if CurrFieldNo <> 0 then
                    TestStatusOpen;

                IsHandled := false;
                OnValidateShipmentDateOnBeforeCalcReceiptDate(IsHandled, Rec);
                if not IsHandled then
                    CalcReceiptDate();

                CheckItemAvailable(FieldNo("Shipment Date"));
                DateConflictCheck;
            end;
        }
        field(39; "Receipt Date"; Date)
        {
            Caption = 'Receipt Date';

            trigger OnValidate()
            var
                TransferLine: Record "Transfer Line";
                IsHandled: Boolean;
            begin
                if CurrFieldNo <> 0 then
                    TestStatusOpen;

                IsHandled := false;
                OnValidateReceiptDateOnBeforeCalcShipmentDate(IsHandled, Rec);
                if not IsHandled then
                    CalcShipmentDate();

                CheckItemAvailable(FieldNo("Shipment Date"));
                DateConflictCheck;
                if "Derived From Line No." = 0 then
                    if DerivedLinesExist(TransferLine, "Document No.", "Line No.") then
                        TransferLine.ModifyAll("Receipt Date", "Receipt Date");
            end;
        }
        field(40; "Derived From Line No."; Integer)
        {
            Caption = 'Derived From Line No.';
            TableRelation = "Transfer Line"."Line No." WHERE("Document No." = FIELD("Document No."));
        }
        field(41; "Shipping Agent Code"; Code[10])
        {
            AccessByPermission = TableData "Shipping Agent Services" = R;
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";

            trigger OnValidate()
            begin
                if CurrFieldNo <> 0 then
                    TestStatusOpen;
                if "Shipping Agent Code" <> xRec."Shipping Agent Code" then
                    Validate("Shipping Agent Service Code", '');
            end;
        }
        field(42; "Shipping Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code WHERE("Shipping Agent Code" = FIELD("Shipping Agent Code"));

            trigger OnValidate()
            begin
                if CurrFieldNo <> 0 then
                    TestStatusOpen;
                TransferRoute.GetShippingTime(
                  "Transfer-from Code", "Transfer-to Code",
                  "Shipping Agent Code", "Shipping Agent Service Code",
                  "Shipping Time");
                CalcReceiptDate();
                CheckItemAvailable(FieldNo("Shipping Agent Service Code"));
                DateConflictCheck;
            end;
        }
        field(43; "Appl.-to Item Entry"; Integer)
        {
            AccessByPermission = TableData Item = R;
            Caption = 'Appl.-to Item Entry';

            trigger OnLookup()
            begin
                SelectItemEntry(FieldNo("Appl.-to Item Entry"));
            end;

            trigger OnValidate()
            var
                ItemLedgEntry: Record "Item Ledger Entry";
                ItemTrackingLines: Page "Item Tracking Lines";
            begin
                if "Appl.-to Item Entry" <> 0 then begin
                    TestField(Quantity);
                    ItemLedgEntry.Get("Appl.-to Item Entry");
                    ItemLedgEntry.TestField(Positive, true);
                    if (ItemLedgEntry."Lot No." <> '') or (ItemLedgEntry."Serial No." <> '') then
                        Error(MustUseTrackingErr, ItemTrackingLines.Caption, FieldCaption("Appl.-to Item Entry"));
                    if Abs("Qty. to Ship (Base)") > ItemLedgEntry.Quantity then
                        Error(ShippingMoreUnitsThanReceivedErr, ItemLedgEntry.Quantity, ItemLedgEntry."Document No.");

                    ItemLedgEntry.TestField("Location Code", "Transfer-from Code");
                    if not ItemLedgEntry.Open then
                        Message(LedgEntryWillBeOpenedMsg, "Appl.-to Item Entry");
                end;
            end;
        }
        field(50; "Reserved Quantity Inbnd."; Decimal)
        {
            CalcFormula = Sum("Reservation Entry".Quantity WHERE("Source ID" = FIELD("Document No."),
                                                                  "Source Ref. No." = FIELD("Line No."),
                                                                  "Source Type" = CONST(5741),
                                                                  "Source Subtype" = CONST("1"),
                                                                  "Source Prod. Order Line" = FIELD("Derived From Line No."),
                                                                  "Reservation Status" = CONST(Reservation)));
            Caption = 'Reserved Quantity Inbnd.';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(51; "Reserved Quantity Outbnd."; Decimal)
        {
            CalcFormula = - Sum("Reservation Entry".Quantity WHERE("Source ID" = FIELD("Document No."),
                                                                   "Source Ref. No." = FIELD("Line No."),
                                                                   "Source Type" = CONST(5741),
                                                                   "Source Subtype" = CONST("0"),
                                                                   "Source Prod. Order Line" = FIELD("Derived From Line No."),
                                                                   "Reservation Status" = CONST(Reservation)));
            Caption = 'Reserved Quantity Outbnd.';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(52; "Reserved Qty. Inbnd. (Base)"; Decimal)
        {
            CalcFormula = Sum("Reservation Entry"."Quantity (Base)" WHERE("Source ID" = FIELD("Document No."),
                                                                           "Source Ref. No." = FIELD("Line No."),
                                                                           "Source Type" = CONST(5741),
                                                                           "Source Subtype" = CONST("1"),
                                                                           "Source Prod. Order Line" = FIELD("Derived From Line No."),
                                                                           "Reservation Status" = CONST(Reservation)));
            Caption = 'Reserved Qty. Inbnd. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(53; "Reserved Qty. Outbnd. (Base)"; Decimal)
        {
            CalcFormula = - Sum("Reservation Entry"."Quantity (Base)" WHERE("Source ID" = FIELD("Document No."),
                                                                            "Source Ref. No." = FIELD("Line No."),
                                                                            "Source Type" = CONST(5741),
                                                                            "Source Subtype" = CONST("0"),
                                                                            "Source Prod. Order Line" = FIELD("Derived From Line No."),
                                                                            "Reservation Status" = CONST(Reservation)));
            Caption = 'Reserved Qty. Outbnd. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(54; "Shipping Time"; DateFormula)
        {
            AccessByPermission = TableData "Shipping Agent Services" = R;
            Caption = 'Shipping Time';

            trigger OnValidate()
            begin
                if CurrFieldNo <> 0 then
                    TestStatusOpen;
                CalcReceiptDate();
                DateConflictCheck;
            end;
        }
        field(55; "Reserved Quantity Shipped"; Decimal)
        {
            CalcFormula = Sum("Reservation Entry".Quantity WHERE("Source ID" = FIELD("Document No."),
                                                                  "Source Ref. No." = FILTER(<> 0),
                                                                  "Source Type" = CONST(5741),
                                                                  "Source Subtype" = CONST("1"),
                                                                  "Source Prod. Order Line" = FIELD("Line No."),
                                                                  "Reservation Status" = CONST(Reservation)));
            Caption = 'Reserved Quantity Shipped';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(56; "Reserved Qty. Shipped (Base)"; Decimal)
        {
            CalcFormula = Sum("Reservation Entry"."Quantity (Base)" WHERE("Source ID" = FIELD("Document No."),
                                                                           "Source Ref. No." = FILTER(<> 0),
                                                                           "Source Type" = CONST(5741),
                                                                           "Source Subtype" = CONST("1"),
                                                                           "Source Prod. Order Line" = FIELD("Line No."),
                                                                           "Reservation Status" = CONST(Reservation)));
            Caption = 'Reserved Qty. Shipped (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(70; "Direct Transfer"; Boolean)
        {
            Caption = 'Direct Transfer';
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions();
            end;

            trigger OnValidate()
            begin
                DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            end;
        }
        field(5704; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            TableRelation = "Item Category";
        }
        field(5707; "Product Group Code"; Code[10])
        {
            Caption = 'Product Group Code';
            ObsoleteReason = 'Product Groups became first level children of Item Categories.';
            ObsoleteState = Removed;
            ObsoleteTag = '15.0';
        }
        field(5750; "Whse. Inbnd. Otsdg. Qty (Base)"; Decimal)
        {
            BlankZero = true;
            CalcFormula = Sum("Warehouse Receipt Line"."Qty. Outstanding (Base)" WHERE("Source Type" = CONST(5741),
                                                                                        "Source Subtype" = CONST("1"),
                                                                                        "Source No." = FIELD("Document No."),
                                                                                        "Source Line No." = FIELD("Line No.")));
            Caption = 'Whse. Inbnd. Otsdg. Qty (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5751; "Whse Outbnd. Otsdg. Qty (Base)"; Decimal)
        {
            BlankZero = true;
            CalcFormula = Sum("Warehouse Shipment Line"."Qty. Outstanding (Base)" WHERE("Source Type" = CONST(5741),
                                                                                         "Source Subtype" = CONST("0"),
                                                                                         "Source No." = FIELD("Document No."),
                                                                                         "Source Line No." = FIELD("Line No.")));
            Caption = 'Whse Outbnd. Otsdg. Qty (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5752; "Completely Shipped"; Boolean)
        {
            Caption = 'Completely Shipped';
            Editable = false;
        }
        field(5753; "Completely Received"; Boolean)
        {
            Caption = 'Completely Received';
            Editable = false;
        }
        field(5793; "Outbound Whse. Handling Time"; DateFormula)
        {
            Caption = 'Outbound Whse. Handling Time';

            trigger OnValidate()
            begin
                if CurrFieldNo <> 0 then
                    TestStatusOpen;
                CalcReceiptDate();
                DateConflictCheck;
            end;
        }
        field(5794; "Inbound Whse. Handling Time"; DateFormula)
        {
            Caption = 'Inbound Whse. Handling Time';

            trigger OnValidate()
            begin
                if CurrFieldNo <> 0 then
                    TestStatusOpen;
                CalcReceiptDate();
                DateConflictCheck;
            end;
        }
        field(7300; "Transfer-from Bin Code"; Code[20])
        {
            Caption = 'Transfer-from Bin Code';
            TableRelation = "Bin Content"."Bin Code" WHERE("Location Code" = FIELD("Transfer-from Code"),
                                                            "Item No." = FIELD("Item No."),
                                                            "Variant Code" = FIELD("Variant Code"));

            trigger OnValidate()
            begin
                if "Transfer-from Bin Code" <> xRec."Transfer-from Bin Code" then begin
                    TestField("Transfer-from Code");
                    if "Transfer-from Bin Code" <> '' then begin
                        GetLocation("Transfer-from Code");
                        Location.TestField("Bin Mandatory");
                        Location.TestField("Directed Put-away and Pick", false);
                        GetBin("Transfer-from Code", "Transfer-from Bin Code");
                        TestField("Transfer-from Code", Bin."Location Code");
                        HandleDedicatedBin(true);
                    end;
                end;
            end;
        }
        field(7301; "Transfer-To Bin Code"; Code[20])
        {
            Caption = 'Transfer-To Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Transfer-to Code"));

            trigger OnValidate()
            begin
                if "Transfer-To Bin Code" <> xRec."Transfer-To Bin Code" then begin
                    TestField("Transfer-to Code");
                    if "Transfer-To Bin Code" <> '' then begin
                        GetLocation("Transfer-to Code");
                        Location.TestField("Bin Mandatory");
                        Location.TestField("Directed Put-away and Pick", false);
                        GetBin("Transfer-to Code", "Transfer-To Bin Code");
                        TestField("Transfer-to Code", Bin."Location Code");
                    end;
                end;
            end;
        }
        field(10003; "Custom Transit Number"; Text[30])
        {
            Caption = 'Custom Transit Number';
        }
        field(99000755; "Planning Flexibility"; Enum "Reservation Planning Flexibility")
        {
            Caption = 'Planning Flexibility';

            trigger OnValidate()
            begin
                if "Planning Flexibility" <> xRec."Planning Flexibility" then
                    TransferLineReserve.UpdatePlanningFlexibility(Rec);
            end;
        }
    }

    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Transfer-to Code", Status, "Derived From Line No.", "Item No.", "Variant Code", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Receipt Date", "In-Transit Code")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Qty. in Transit (Base)", "Outstanding Qty. (Base)";
        }
        key(Key3; "Transfer-from Code", Status, "Derived From Line No.", "Item No.", "Variant Code", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Shipment Date", "In-Transit Code")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Outstanding Qty. (Base)";
        }
        key(Key4; "Item No.", "Variant Code")
        {
        }
        key(Key5; "Transfer-to Code", "Receipt Date", "Item No.", "Variant Code")
        {
        }
        key(Key6; "Transfer-from Code", "Shipment Date", "Item No.", "Variant Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Item No.", Description, Quantity, "Unit of Measure", "Transfer-from Code", "Transfer-to Code")
        {
        }
    }

    trigger OnDelete()
    var
        ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)";
        TransLine: Record "Transfer Line";
    begin
        TestStatusOpen;

        TestField("Quantity Shipped", "Quantity Received");
        TestField("Qty. Shipped (Base)", "Qty. Received (Base)");
        CalcFields("Reserved Qty. Inbnd. (Base)", "Reserved Qty. Outbnd. (Base)");
        TestField("Reserved Qty. Inbnd. (Base)", 0);
        TestField("Reserved Qty. Outbnd. (Base)", 0);
        // P8001324
        TestContainerQuantityIsZero(0); // P80046533
        if Type = Type::Container then begin
            ContainerHeader.SetRange("Document Type", DATABASE::"Transfer Line");
            ContainerHeader.SetRange("Document No.", "Document No.");
            ContainerHeader.SetRange("Document Ref. No.", "Line No.");
            if not ContainerHeader.IsEmpty then
                Error(Text37002002);
        end;
        // P8001324

        OnDeleteOnBeforeDeleteRelatedData(Rec);

        OnDeleteOnBeforeDeleteRelatedData(Rec);

        TransferLineReserve.DeleteLine(Rec);
        WhseValidateSourceLine.TransLineDelete(Rec);

        ItemChargeAssgntPurch.SetCurrentKey(
          "Applies-to Doc. Type", "Applies-to Doc. No.", "Applies-to Doc. Line No.");
        ItemChargeAssgntPurch.SetRange("Applies-to Doc. Type", ItemChargeAssgntPurch."Applies-to Doc. Type"::"Transfer Receipt");
        ItemChargeAssgntPurch.SetRange("Applies-to Doc. No.", "Document No.");
        ItemChargeAssgntPurch.SetRange("Applies-to Doc. Line No.", "Line No.");
        ItemChargeAssgntPurch.DeleteAll(true);

        DeleteExtraCharges; // P8000928

        // PR3.61 Begin
        if "Alt. Qty. Trans. No. (Ship)" <> 0 then
            AltQtyMgmt.DeleteAltQtyLines("Alt. Qty. Trans. No. (Ship)");
        if "Alt. Qty. Trans. No. (Receive)" <> 0 then
            AltQtyMgmt.DeleteAltQtyLines("Alt. Qty. Trans. No. (Receive)");
        // PR3.61 Begin
    end;

    trigger OnInsert()
    var
        TransLine2: Record "Transfer Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOnInsert(Rec, xRec, TransHeader, IsHandled);
        If IsHandled then
            exit;

        TestStatusOpen();

        IsHandled := false;
        OnInsertOnBeforeAssignLineNo(Rec, IsHandled);
        if not IsHandled then begin
            TransLine2.Reset();
            TransLine2.SetFilter("Document No.", TransHeader."No.");
            if TransLine2.FindLast then
                "Line No." := TransLine2."Line No." + 10000;
        end;
        TransferLineReserve.VerifyQuantity(Rec, xRec);

        if ProcessFns.FreshProInstalled then                                  // P8000928
            ExtraChargeMgt.InsertDocExtraCharge(DATABASE::"Transfer Line", 0, "Document No.", "Line No."); // P8000928, P8001032

        UpdateLotTracking(true, 0); // P8000043A
    end;

    trigger OnModify()
    begin
        if ItemExists(xRec."Item No.") then
            TransferLineReserve.VerifyChange(Rec, xRec);
    end;

    trigger OnRename()
    begin
        Error(Text001, TableCaption);
    end;

    var
        Text001: Label 'You cannot rename a %1.';
        Text002: Label 'must not be less than %1';
        Text003: Label 'Warehouse %1 is required for %2 = %3.';
        Text004: Label '\The entered information may be disregarded by warehouse operations.';
        Text005: Label 'You cannot ship more than %1 units.';
        Text006: Label 'All items have been shipped.';
        Text008: Label 'You cannot receive more than %1 units.';
        Text009: Label 'No items are currently in transit.';
        Text011: Label 'Outbound,Inbound';
        Text012: Label 'You have changed one or more dimensions on the %1, which is already shipped. When you post the line with the changed dimension to General Ledger, amounts on the Inventory Interim account will be out of balance when reported per dimension.\\Do you want to keep the changed dimension?';
        Text013: Label 'Cancelled.';
        TransferRoute: Record "Transfer Route";
        Item: Record Item;
        TransHeader: Record "Transfer Header";
        Location: Record Location;
        Bin: Record Bin;
        DimMgt: Codeunit DimensionManagement;
        WhseValidateSourceLine: Codeunit "Whse. Validate Source Line";
        TransferLineReserve: Codeunit "Transfer Line-Reserve";
        CheckDateConflict: Codeunit "Reservation-Check Date Confl.";
        WMSManagement: Codeunit "WMS Management";
        ConfirmManagement: Codeunit "Confirm Management";
        UOMMgt: Codeunit "Unit of Measure Management";
        Reservation: Page Reservation;
        TrackingBlocked: Boolean;
        CannotAutoReserveErr: Label 'Quantity %1 in line %2 cannot be reserved automatically.', Comment = '%1 - quantity, %2 - line number';
        P800CoreFns: Codeunit "Process 800 Core Functions";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        ContainerHeader: Record "Container Header";
        P800Globals: Codeunit "Process 800 System Globals";
        ProcessFns: Codeunit "Process 800 Functions";
        Text37002000: Label 'cannot be less than quantity assigned through containers';
        Text37002001: Label 'may not be edited';
        DocExtraCharge: Record "Document Extra Charge";
        ExtraChargeMgt: Codeunit "Extra Charge Management";
        Text37002002: Label 'Line is associated with one or more containers.';
        MustUseTrackingErr: Label 'You must use the %1 page to specify the %2, if you use item tracking.', Comment = '%1 = Form Name, %2 = Value to Enter';
        LedgEntryWillBeOpenedMsg: Label 'When posting the Applied to Ledger Entry %1 will be opened first.', Comment = '%1 = Entry No.';
        ShippingMoreUnitsThanReceivedErr: Label 'You cannot ship more than the %1 units that you have received for document no. %2.', Comment = '%1 = Quantity Value, %2 = Document No.';
        DataCollectionMgmt: Codeunit "Data Collection Management";
        ContainerFns: Codeunit "Container Functions";
        AnotherItemWithSameDescrQst: Label 'We found an item with the description "%2" (No. %1).\Did you mean to change the current item to %1?', Comment = '%1=Item no., %2=item description';
        StatusCheckSuspended: Boolean;
        UseWhseLineQty: Boolean;
        WhseLineQtyBase: Decimal;
        WhseLineAltQtyBase: Decimal;
        gDirection: Integer;

    procedure InitOutstandingQty()
    begin
        "Outstanding Quantity" := Quantity - "Quantity Shipped";
        "Outstanding Qty. (Base)" := "Quantity (Base)" - "Qty. Shipped (Base)";
        "Completely Shipped" := (Quantity <> 0) and ("Outstanding Quantity" = 0);

        OnAfterInitOutstandingQty(Rec, CurrFieldNo);
    end;

    procedure InitQtyToShip()
    begin
        "Qty. to Ship" := "Outstanding Quantity" - GetContainerQuantity(0, ''); // P80046533
        "Qty. to Ship (Base)" := UOMMgt.CalcBaseQty("Qty. to Ship", "Qty. per Unit of Measure"); // P80046533

        // PR3.61
        if (Type = Type::Item) and ("Item No." <> '') and TrackAlternateUnits then begin
            // P8000550A
            // AltQtyMgmt.InitAlternateQty("Item No.", "Alt. Qty. Trans. No. (Ship)",
            //                             "Qty. to Ship (Base)", "Qty. to Ship (Alt.)");
            AltQtyMgmt.InitAlternateQtyToHandle(
              "Item No.", "Alt. Qty. Trans. No. (Ship)", "Quantity (Base)", "Qty. to Ship (Base)",
              "Qty. Shipped (Base)", "Quantity (Alt.)", "Qty. Shipped (Alt.)", "Qty. to Ship (Alt.)");
            // P8000550A
            AltQtyMgmt.SetTransLineAltQty(Rec);
        end;
        // PR3.61

        OnAfterInitQtyToShip(Rec, CurrFieldNo);
    end;

    procedure InitQtyToReceive()
    begin
        if "In-Transit Code" <> '' then begin
            "Qty. to Receive" := "Qty. in Transit" - GetContainerQuantity(1, ''); // P80046533
            "Qty. to Receive (Base)" := UOMMgt.CalcBaseQty("Qty. to Receive", "Qty. per Unit of Measure"); // P80046533
        end;
        if ("In-Transit Code" = '') and ("Quantity Shipped" = "Quantity Received") then begin
            "Qty. to Receive" := "Qty. to Ship" - GetContainerQuantity(1, ''); // P80053245
            "Qty. to Receive (Base)" := UOMMgt.CalcBaseQty("Qty. to Receive", "Qty. per Unit of Measure"); // P80053245
        end;
        if (Type = Type::Item) and ("Item No." <> '') and TrackAlternateUnits then
            // P8000550A
            // AltQtyMgmt.InitAlternateQty("Item No.", "Alt. Qty. Trans. No. (Receive)",
            //                             "Qty. to Receive (Base)", "Qty. to Receive (Alt.)");
            AltQtyMgmt.InitAlternateQtyToHandle(
            "Item No.", "Alt. Qty. Trans. No. (Receive)", "Quantity (Base)", "Qty. to Receive (Base)",
            "Qty. Received (Base)", "Quantity (Alt.)", "Qty. Received (Alt.)", "Qty. to Receive (Alt.)");
        // P8000550A
        // PR3.70.01

        OnAfterInitQtyToReceive(Rec, CurrFieldNo);
    end;

    procedure InitQtyInTransit()
    begin
        if "In-Transit Code" <> '' then begin
            "Qty. in Transit" := "Quantity Shipped" - "Quantity Received";
            "Qty. in Transit (Base)" := "Qty. Shipped (Base)" - "Qty. Received (Base)";
        end else begin
            "Qty. in Transit" := 0;
            "Qty. in Transit (Base)" := 0;
        end;
        "Completely Received" := (Quantity <> 0) and (Quantity = "Quantity Received");

        OnAfterInitQtyInTransit(Rec, CurrFieldNo);
    end;

    local procedure CalcReceiptDate()
    begin
        TransferRoute.CalcReceiptDate("Shipment Date", "Receipt Date",
            "Shipping Time", "Outbound Whse. Handling Time", "Inbound Whse. Handling Time",
            "Transfer-from Code", "Transfer-to Code", "Shipping Agent Code", "Shipping Agent Service Code");
    end;

    local procedure CalcShipmentDate()
    begin
        TransferRoute.CalcShipmentDate("Shipment Date", "Receipt Date",
            "Shipping Time", "Outbound Whse. Handling Time", "Inbound Whse. Handling Time",
            "Transfer-from Code", "Transfer-to Code", "Shipping Agent Code", "Shipping Agent Service Code");
    end;

    procedure ResetPostedQty()
    begin
        "Quantity Shipped" := 0;
        "Qty. Shipped (Base)" := 0;
        "Qty. Shipped (Alt.)" := 0; // PR3.61, P80041198
        "Quantity Received" := 0;
        "Qty. Received (Base)" := 0;
        "Qty. Received (Alt.)" := 0; // PR3.61, P80041198
        "Qty. in Transit" := 0;
        "Qty. in Transit (Base)" := 0;

        OnAfterResetPostedQty(Rec);
    end;

    procedure GetTransHeaderExternal()
    begin
        GetTransHeader();
    end;

    local procedure GetTransHeader()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetTransHeader(Rec, TransHeader, IsHandled);
        if IsHandled then
            exit;

        GetTransferHeaderNoVerification;

        CheckTransferHeader(TransHeader);

        "In-Transit Code" := TransHeader."In-Transit Code";
        "Transfer-from Code" := TransHeader."Transfer-from Code";
        "Transfer-to Code" := TransHeader."Transfer-to Code";
        "Shipment Date" := TransHeader."Shipment Date";
        "Receipt Date" := TransHeader."Receipt Date";
        "Shipping Agent Code" := TransHeader."Shipping Agent Code";
        "Shipping Agent Service Code" := TransHeader."Shipping Agent Service Code";
        "Shipping Time" := TransHeader."Shipping Time";
        "Outbound Whse. Handling Time" := TransHeader."Outbound Whse. Handling Time";
        "Inbound Whse. Handling Time" := TransHeader."Inbound Whse. Handling Time";
        Status := TransHeader.Status;
        "Direct Transfer" := TransHeader."Direct Transfer";

        OnAfterGetTransHeader(Rec, TransHeader);
    end;

    local procedure CheckTransferHeader(TransferHeader: Record "Transfer Header")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckTransferHeader(TransferHeader, IsHandled, Rec, xRec);
        if IsHandled then
            exit;

        TransHeader.TestField("Shipment Date");
        TransHeader.TestField("Receipt Date");
        TransHeader.TestField("Transfer-from Code");
        TransHeader.TestField("Transfer-to Code");
        if not TransHeader."Direct Transfer" and ("Direct Transfer" = xRec."Direct Transfer") then
            TransHeader.TestField("In-Transit Code");
    end;

    local procedure GetItem()
    begin
        TestField("Item No.");
        if "Item No." <> Item."No." then
            Item.Get("Item No.");
    end;

    local procedure GetItemNo(): Code[20]
    var
        ReturnValue: Text[50];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetItemNo(Rec, xRec, CurrFieldNo, IsHandled);
        if IsHandled then
            exit("Item No.");

        Item.TryGetItemNo(ReturnValue, "Item No.", true);
        exit(CopyStr(ReturnValue, 1, MaxStrLen("Item No.")));
    end;

    procedure BlockDynamicTracking(SetBlock: Boolean)
    begin
        TrackingBlocked := SetBlock;
        TransferLineReserve.Block(SetBlock);
    end;

    procedure ShowDimensions()
    begin
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet("Dimension Set ID", StrSubstNo('%1 %2 %3', TableCaption, "Document No.", "Line No."));
        VerifyItemLineDim;
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");

        OnAfterShowDimensions(Rec, xRec);
    end;

    procedure CreateDim(Type1: Integer; No1: Code[20])
    var
        SourceCodeSetup: Record "Source Code Setup";
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        SourceCodeSetup.Get();
        TableID[1] := Type1;
        No[1] := No1;
        OnAfterCreateDimTableIDs(Rec, CurrFieldNo, TableID, No);

        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        "Dimension Set ID" :=
          DimMgt.GetRecDefaultDimID(
            Rec, CurrFieldNo, TableID, No, SourceCodeSetup.Transfer,
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", TransHeader."Dimension Set ID", DATABASE::Item);
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        OnBeforeValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode);

        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
        VerifyItemLineDim;

        OnAfterValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode);
    end;

    procedure LookupShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.LookupDimValueCode(FieldNumber, ShortcutDimCode);
        ValidateShortcutDimCode(FieldNumber, ShortcutDimCode);
    end;

    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20])
    begin
        DimMgt.GetShortcutDimensions("Dimension Set ID", ShortcutDimCode);
    end;

    local procedure CheckItemAvailable(CalledByFieldNo: Integer)
    var
        ItemCheckAvail: Codeunit "Item-Check Avail.";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckItemAvailable(Rec, CalledByFieldNo, CurrFieldNo, IsHandled);
        if IsHandled then
            exit;

        if (CurrFieldNo <> 0) and
           (CurrFieldNo = CalledByFieldNo) and
           ("Item No." <> '') and
           ("Outstanding Quantity" > 0)
        then
            if ItemCheckAvail.TransferLineCheck(Rec) then
                ItemCheckAvail.RaiseUpdateInterruptedError;
    end;

    local procedure CheckItemCanBeShipped()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckItemCanBeShipped(Rec, IsHandled);
        if IsHandled then
            exit;

        if ("Qty. to Ship" + GetContainerQuantity(0, false)) > "Outstanding Quantity" then // P80046533
            if "Outstanding Quantity" > 0 then
                Error(
                  Text005,
                  "Outstanding Quantity" - GetContainerQuantity(0, false)) // P80046533
            else
                Error(Text006);
    end;

    procedure OpenItemTrackingLines(Direction: Enum "Transfer Direction")
    begin
        TestField("Item No.");
        TestField("Quantity (Base)");

        TransferLineReserve.CallItemTracking(Rec, Direction);
        // PR3.61.01 Begin
        if TrackAlternateUnits then begin
            Rec.Find('=');
            AltQtyMgmt.UpdateTransLine(Rec, Direction);
            AltQtyMgmt.SetTransLineAltQty(Rec);
        end;
        // PR3.61.01 End
        GetLotNo; // P8000043A
        Modify;   // P8000043A
    end;

    procedure OpenItemTrackingLinesWithReclass(Direction: Enum "Transfer Direction")
    begin
        TestField("Item No.");
        TestField("Quantity (Base)");

        TransferLineReserve.CallItemTracking(Rec, Direction, true);
    end;

    procedure TestStatusOpen()
    begin
        if StatusCheckSuspended then
            exit;

        TestField("Document No.");
        if TransHeader."No." <> "Document No." then
            TransHeader.Get("Document No.");

        OnBeforeTestStatusOpen(Rec, TransHeader);

        if (Type = Type::Item) then // P8000631A
            TransHeader.TestField(Status, TransHeader.Status::Open);

        OnAfterTestStatusOpen(Rec, TransHeader);
    end;

    procedure SuspendStatusCheck(Suspend: Boolean)
    begin
        StatusCheckSuspended := Suspend;
    end;

    procedure SuspendStatusCheck2(Suspend: Boolean) WasSuspended: Boolean
    begin
        // P800110503 - maintain original function
        // P8006787 - add return value
        WasSuspended := StatusCheckSuspended; // P8006787
        StatusCheckSuspended := Suspend;
    end;

    procedure ShowReservation()
    var
        OptionNumber: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeShowReservation(Rec, IsHandled);
        if IsHandled then
            exit;

        TestField("Item No.");
        Clear(Reservation);
        OptionNumber := StrMenu(Text011);
        if OptionNumber > 0 then begin
            Reservation.SetReservSource(Rec, "Transfer Direction".FromInteger(OptionNumber - 1));
            Reservation.RunModal();
        end;
    end;

    procedure UpdateWithWarehouseShipReceive()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateWithWarehouseShipReceive(Rec, IsHandled);
        if IsHandled then
            exit;

        if Location.RequireShipment("Transfer-from Code") then
            Validate("Qty. to Ship", GetContainerQuantity(0, true)) // P80046533
        else
            Validate("Qty. to Ship", "Outstanding Quantity" - GetContainerQuantity(0, false)); //P80046533

        if Location.RequireReceive("Transfer-to Code") then
            Validate("Qty. to Receive", GetContainerQuantity(1, true)) // P80046533
        else begin
            if "In-Transit Code" <> '' then
                Validate("Qty. to Receive", "Qty. in Transit" - GetContainerQuantity(1, false)); //P80046533
            if ("In-Transit Code" = '') and ("Quantity Shipped" = "Quantity Received") then
                Validate("Qty. to Receive", "Qty. to Ship");
        end;

        UpdateOnWhseChange(0); // P8000282A
        UpdateOnWhseChange(1); // P8000282A

        OnAfterUpdateWithWarehouseShipReceive(Rec, CurrFieldNo);
    end;

    procedure RenameNo(OldNo: Code[20]; NewNo: Code[20])
    begin
        Reset;
        SetRange("Item No.", OldNo);
        if not Rec.IsEmpty() then
            ModifyAll("Item No.", NewNo, true);
    end;

    procedure CheckWarehouse(Location: Record Location; Receive: Boolean)
    var
        ShowDialog: Option " ",Message,Error;
        DialogText: Text[50];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckWarehouse(Rec, Location, Receive, IsHandled);
        if IsHandled then
            exit;

        if Location."Directed Put-away and Pick" then begin
            ShowDialog := ShowDialog::Error;
            if Receive then
                DialogText := Location.GetRequirementText(Location.FieldNo("Require Receive"))
            else
                DialogText := Location.GetRequirementText(Location.FieldNo("Require Shipment"));
        end else begin
            if Receive and (Location."Require Receive" or Location."Require Put-away") then begin
                if WhseValidateSourceLine.WhseLinesExist(
                     DATABASE::"Transfer Line", 1, "Document No.", "Line No.", 0, Quantity)
                then
                    ShowDialog := ShowDialog::Error
                else
                    if Location."Require Receive" then
                        ShowDialog := ShowDialog::Message;
                if Location."Require Receive" then
                    DialogText := Location.GetRequirementText(Location.FieldNo("Require Receive"))
                else
                    DialogText := Location.GetRequirementText(Location.FieldNo("Require Put-away"));
            end;

            if not Receive and (Location."Require Shipment" or Location."Require Pick") then begin
                if WhseValidateSourceLine.WhseLinesExist(
                     DATABASE::"Transfer Line", 0, "Document No.", "Line No.", 0, Quantity)
                then
                    ShowDialog := ShowDialog::Error
                else
                    if Location."Require Shipment" then
                        ShowDialog := ShowDialog::Message;
                if Location."Require Shipment" then
                    DialogText := Location.GetRequirementText(Location.FieldNo("Require Shipment"))
                else
                    DialogText := Location.GetRequirementText(Location.FieldNo("Require Pick"));
            end;
        end;

        OnCheckWarehouseOnBeforeShowDialog(Rec, Location, ShowDialog, DialogText);
        case ShowDialog of
            ShowDialog::Message:
                Message(Text003 + Text004, DialogText, FieldCaption("Line No."), "Line No.");
            ShowDialog::Error:
                Error(Text003, DialogText, FieldCaption("Line No."), "Line No.");
        end;
    end;

    local procedure GetLocation(LocationCode: Code[10])
    begin
        if Location.Code <> LocationCode then
            Location.Get(LocationCode);
    end;

    local procedure GetBin(LocationCode: Code[10]; BinCode: Code[20])
    begin
        if BinCode = '' then
            Clear(Bin)
        else
            if Bin.Code <> BinCode then
                Bin.Get(LocationCode, BinCode);
    end;

    local procedure GetDefaultBin(FromLocationCode: Code[10]; ToLocationCode: Code[10])
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetDefaultBin(Rec, IsHandled);
        if IsHandled then
            exit;

        if (FromLocationCode <> '') and ("Item No." <> '') then begin
            GetLocation(FromLocationCode);
            if Location."Bin Mandatory" and not Location."Directed Put-away and Pick" then begin
                if (Location."Shipment Bin Code (1-Doc)" <> '') then               // P8000631A
                    "Transfer-from Bin Code" := Location."Shipment Bin Code (1-Doc)" // P8000631A
                else                                                               // P8000631A
                    WMSManagement.GetDefaultBin("Item No.", "Variant Code", FromLocationCode, "Transfer-from Bin Code");
                HandleDedicatedBin(false);
            end;
        end;

        if (ToLocationCode <> '') and ("Item No." <> '') then begin
            GetLocation(ToLocationCode);
            if Location."Bin Mandatory" and not Location."Directed Put-away and Pick" then
                if (Location."Receipt Bin Code (1-Doc)" <> '') then             // P8000631A
                    "Transfer-To Bin Code" := Location."Receipt Bin Code (1-Doc)" // P8000631A
                else                                                            // P8000631A
                    WMSManagement.GetDefaultBin("Item No.", "Variant Code", ToLocationCode, "Transfer-To Bin Code");
        end;

        OnAfterGetDefaultBin(Rec, FromLocationCode, ToLocationCode);
    end;

    local procedure CalcBaseQty(Qty: Decimal; FromFieldName: Text; ToFieldName: Text): Decimal
    begin
        exit(UOMMgt.CalcBaseQty(
            "Item No.", "Variant Code", "Unit of Measure Code", Qty, "Qty. per Unit of Measure", "Qty. Rounding Precision (Base)", FieldCaption("Qty. Rounding Precision"), FromFieldName, ToFieldName));
    end;

    procedure GetRemainingQty(var RemainingQty: Decimal; var RemainingQtyBase: Decimal; Direction: Integer)
    begin
        case Direction of
            0: // Outbound
                begin
                    CalcFields("Reserved Quantity Outbnd.", "Reserved Qty. Outbnd. (Base)");
                    RemainingQty := "Outstanding Quantity" - Abs("Reserved Quantity Outbnd.");
                    RemainingQtyBase := "Outstanding Qty. (Base)" - Abs("Reserved Qty. Outbnd. (Base)");
                end;
            1: // Inbound
                begin
                    CalcFields("Reserved Quantity Inbnd.", "Reserved Qty. Inbnd. (Base)");
                    RemainingQty := "Outstanding Quantity" - Abs("Reserved Quantity Inbnd.");
                    RemainingQtyBase := "Outstanding Qty. (Base)" - Abs("Reserved Qty. Inbnd. (Base)");
                end;
        end;
    end;

    procedure GetReservationQty(var QtyReserved: Decimal; var QtyReservedBase: Decimal; var QtyToReserve: Decimal; var QtyToReserveBase: Decimal; Direction: Integer): Decimal
    begin
        if Direction = 0 then begin // Outbound
            CalcFields("Reserved Quantity Outbnd.", "Reserved Qty. Outbnd. (Base)");
            QtyReserved := "Reserved Quantity Outbnd.";
            QtyReservedBase := "Reserved Qty. Outbnd. (Base)";
            QtyToReserve := "Outstanding Quantity";
            QtyToReserveBase := "Outstanding Qty. (Base)";
        end else begin // Inbound
            CalcFields("Reserved Quantity Inbnd.", "Reserved Qty. Inbnd. (Base)");
            QtyReserved := "Reserved Quantity Inbnd.";
            QtyReservedBase := "Reserved Qty. Inbnd. (Base)";
            QtyToReserve := "Outstanding Quantity";
            QtyToReserveBase := "Outstanding Qty. (Base)";
        end;
        exit("Qty. per Unit of Measure");
    end;

    procedure GetSourceCaption(): Text
    begin
        exit(StrSubstNo('%1 %2 %3', "Document No.", "Line No.", "Item No."));
    end;

    procedure SetReservationEntry(var ReservEntry: Record "Reservation Entry"; Direction: Enum "Transfer Direction")
    begin
        ReservEntry.SetSource(
            DATABASE::"Transfer Line", Direction.AsInteger(), "Document No.", "Line No.", '', "Derived From Line No.");
        case Direction of
            Direction::Outbound:
                begin
                    ReservEntry.SetItemData(
                        "Item No.", Description, "Transfer-from Code", "Variant Code", "Qty. per Unit of Measure");
                    ReservEntry."Shipment Date" := "Shipment Date";
                    ReservEntry."Expected Receipt Date" := "Shipment Date";
                end;
            Direction::Inbound:
                begin
                    ReservEntry.SetItemData(
                        "Item No.", Description, "Transfer-to Code", "Variant Code", "Qty. per Unit of Measure");
                    ReservEntry."Shipment Date" := "Receipt Date";
                    ReservEntry."Expected Receipt Date" := "Receipt Date";
                end;
        end;
    end;

    procedure SetReservationFilters(var ReservEntry: Record "Reservation Entry"; Direction: Enum "Transfer Direction")
    begin
        ReservEntry.SetSourceFilter(DATABASE::"Transfer Line", Direction.AsInteger(), "Document No.", "Line No.", false);
        ReservEntry.SetSourceFilter('', "Derived From Line No.");

        OnAfterSetReservationFilters(ReservEntry, Rec);
    end;

    procedure ReservEntryExist(): Boolean
    var
        ReservEntry: Record "Reservation Entry";
    begin
        ReservEntry.InitSortingAndFilters(false);
        SetReservationFilters(ReservEntry, "Transfer Direction"::Outbound);
        ReservEntry.SetRange("Source Subtype"); // Ignore direction
        exit(not ReservEntry.IsEmpty);
    end;

    procedure IsInbound(): Boolean
    begin
        exit("Quantity (Base)" < 0);
    end;

    local procedure HandleDedicatedBin(IssueWarning: Boolean)
    var
        WhseIntegrationMgt: Codeunit "Whse. Integration Management";
    begin
        if not IsInbound and ("Quantity (Base)" <> 0) then
            WhseIntegrationMgt.CheckIfBinDedicatedOnSrcDoc("Transfer-from Code", "Transfer-from Bin Code", IssueWarning);
    end;

    procedure FilterLinesWithItemToPlan(var Item: Record Item; IsReceipt: Boolean; IsSupplyForPlanning: Boolean)
    begin
        Reset;
        SetCurrentKey("Item No.");
        SetRange("Item No.", Item."No.");
        SetFilter("Variant Code", Item.GetFilter("Variant Filter"));
        if not IsSupplyForPlanning then
            SetRange("Derived From Line No.", 0);
        if IsReceipt then begin
            SetFilter("Transfer-to Code", Item.GetFilter("Location Filter"));
            SetFilter("Receipt Date", Item.GetFilter("Date Filter"))
        end else begin
            SetFilter("Transfer-from Code", Item.GetFilter("Location Filter"));
            SetFilter("Shipment Date", Item.GetFilter("Date Filter"));
            SetFilter("Outstanding Qty. (Base)", '<>0');
        end;
        SetFilter("Shortcut Dimension 1 Code", Item.GetFilter("Global Dimension 1 Filter"));
        SetFilter("Shortcut Dimension 2 Code", Item.GetFilter("Global Dimension 2 Filter"));
        SetFilter("Unit of Measure Code", Item.GetFilter("Unit of Measure Filter"));
        OnAfterFilterLinesWithItemToPlan(Item, IsReceipt, IsSupplyForPlanning, Rec);
    end;

    procedure FindLinesWithItemToPlan(var Item: Record Item; IsReceipt: Boolean; IsSupplyForPlanning: Boolean): Boolean
    begin
        FilterLinesWithItemToPlan(Item, IsReceipt, IsSupplyForPlanning);
        exit(Find('-'));
    end;

    procedure LinesWithItemToPlanExist(var Item: Record Item; IsReceipt: Boolean): Boolean
    begin
        FilterLinesWithItemToPlan(Item, IsReceipt, false);
        exit(not IsEmpty);
    end;

    procedure FilterInboundLinesForReservation(ReservationEntry: Record "Reservation Entry"; AvailabilityFilter: Text; Positive: Boolean)
    begin
        Reset;
        SetCurrentKey("Transfer-to Code", "Receipt Date", "Item No.", "Variant Code");
        SetRange("Item No.", ReservationEntry."Item No.");
        SetRange("Variant Code", ReservationEntry."Variant Code");
        SetRange("Transfer-to Code", ReservationEntry."Location Code");
        SetFilter("Receipt Date", AvailabilityFilter);
        if Positive then
            SetFilter("Outstanding Qty. (Base)", '>0')
        else
            SetFilter("Outstanding Qty. (Base)", '<0');
    end;

    procedure FilterOutboundLinesForReservation(ReservationEntry: Record "Reservation Entry"; AvailabilityFilter: Text; Positive: Boolean)
    begin
        Reset;
        SetCurrentKey("Transfer-from Code", "Shipment Date", "Item No.", "Variant Code");
        SetRange("Item No.", ReservationEntry."Item No.");
        SetRange("Variant Code", ReservationEntry."Variant Code");
        SetRange("Transfer-from Code", ReservationEntry."Location Code");
        SetFilter("Shipment Date", AvailabilityFilter);
        if Positive then
            SetFilter("Outstanding Qty. (Base)", '<0')
        else
            SetFilter("Outstanding Qty. (Base)", '>0');
    end;

    procedure VerifyItemLineDim()
    begin
        if IsShippedDimChanged then
            ConfirmShippedDimChange();
    end;

    procedure ReserveFromInventory(var TransLine: Record "Transfer Line")
    var
        ReservMgt: Codeunit "Reservation Management";
        SourceRecRef: RecordRef;
        AutoReserved: Boolean;
    begin
        if TransLine.FindSet() then
            repeat
                SourceRecRef.GetTable(TransLine);
                ReservMgt.SetReservSource(SourceRecRef);
                TransLine.TestField("Shipment Date");
                TransLine.CalcFields("Reserved Qty. Outbnd. (Base)");
                ReservMgt.AutoReserveToShip(
                  AutoReserved, '', TransLine."Shipment Date",
                  TransLine."Qty. to Ship" - TransLine."Reserved Quantity Outbnd.",
                  TransLine."Qty. to Ship (Base)" - TransLine."Reserved Qty. Outbnd. (Base)");
                if not AutoReserved then
                    Error(CannotAutoReserveErr, TransLine."Qty. to Ship (Base)", TransLine."Line No.");
            until TransLine.Next() = 0;
    end;

    procedure TrackAlternateUnits(): Boolean
    begin
        // PR3.61
        if (Type <> Type::Item) or ("Item No." = '') then
            exit(false);
        GetItem;
        exit(Item.TrackAlternateUnits);
        // PR3.61
    end;

    procedure CostInAlternateUnits(): Boolean
    begin
        // PR3.60
        if (Type <> Type::Item) or ("Item No." = '') then
            exit(false);
        GetItem;
        exit(Item.CostInAlternateUnits);
        // PR3.60
    end;

    procedure GetCostingQty(): Decimal
    begin
        // PR3.60
        if CostInAlternateUnits then
            exit("Quantity (Alt.)");
        exit(Quantity);
        // PR3.60
    end;

    local procedure GetContainerQuantities(var QtyToHandle: Decimal; var QtyToHandleBase: Decimal; var QtyToHandleAlt: Decimal; Direction: Integer; ShipReceive: Variant)
    begin
        // P80046533
        QtyToHandle := 0;
        QtyToHandleBase := 0;
        QtyToHandleAlt := 0;

        case Type of
            Type::Container:
                begin
                    QtyToHandle := ContainerFns.GetContainerCount(DATABASE::"Transfer Line", Direction, "Document No.", "Line No.", false, ShipReceive);
                    QtyToHandleBase := Round(QtyToHandle * "Qty. per Unit of Measure", 0.00001);
                end;
            Type::Item:
                if ProcessFns.ContainerTrackingInstalled then
                    ContainerFns.GetContainerQuantitiesByDocLine(Rec, Direction, QtyToHandle, QtyToHandleBase, QtyToHandleAlt, ShipReceive);
        end;
    end;

    procedure GetContainerQuantity(Direction: Integer; ShipReceive: Variant) QtyToHandle: Decimal
    var
        QtyToHandleBase: Decimal;
        QtyToHandleAlt: Decimal;
    begin
        // P80046533
        GetContainerQuantities(QtyToHandle, QtyToHandleBase, QtyToHandleAlt, Direction, ShipReceive);
    end;

    procedure GetContainerQuantityAlt(Direction: Integer; ShipReceive: Variant) QtyToHandleAlt: Decimal
    var
        QtyToHandle: Decimal;
        QtyToHandleBase: Decimal;
    begin
        // P80046533
        GetContainerQuantities(QtyToHandle, QtyToHandleBase, QtyToHandleAlt, Direction, ShipReceive);
    end;

    local procedure TestContainerQuantityIsZero(Direction: Integer)
    begin
        // P80046533
        if 0 <> GetContainerQuantity(Direction, '') then
            Error(Text37002002);
    end;

    procedure ContainerSpecification()
    var
        ContainerFns: Codeunit "Container Functions";
    begin
        ContainerFns.ContainersFromDocument(Rec); // PR3.61
    end;

    procedure GetLotNo()
    var
        EasyLotTracking: Codeunit "Easy Lot Tracking";
    begin
        // P8000043A
        if ProcessFns.TrackingInstalled then begin
            EasyLotTracking.SetTransferLine(Rec, 0);
            "Lot No." := EasyLotTracking.GetLotNo;
        end;
    end;

    procedure UpdateLotTracking(ForceUpdate: Boolean; Direction: Option Outbound,Inbound)
    var
        EasyLotTracking: Codeunit "Easy Lot Tracking";
        Qty: Decimal;
        QtyToHandle: Decimal;
        QtyToHandleAlt: Decimal;
        AltQtyTransNo: Integer;
    begin
        // P8000043A
        if ((CurrFieldNo = 0) and (not ForceUpdate)) or (Type <> Type::Item) then // P8000071A
            exit;
        if ("Lot No." = P800Globals.MultipleLotCode) or (not ProcessFns.TrackingInstalled) or
          (("Lot No." = '') and (("Line No." <> xRec."Line No.") or (xRec."Lot No." = '')))  // P8000083A
        then
            exit;

        EasyLotTracking.TestTransferLine(Rec);
        if "Line No." = 0 then
            exit;
        // P800108868
        IF UseWhseLineQty then begin
            IF gDirection = 0 then begin
                Qty := "Quantity (Base)";
                AltQtyTransNo := "Alt. Qty. Trans. No. (Ship)"
            end else begin
                Qty := "Qty. Shipped (Base)";
                AltQtyTransNo := "Alt. Qty. Trans. No. (Receive)";
            end;
            QtyToHandle := WhseLineQtyBase;
            QtyToHandleAlt := WhseLineAltQtyBase;
        end else begin
            // P800108868
            case Direction of
                Direction::Outbound:
                    begin
                        Qty := "Quantity (Base)";
                        // P8000629A
                        GetLocation("Transfer-from Code");
                        if Location.LocationType = 1 then begin
                            // P8000629A
                            QtyToHandle := "Qty. to Ship (Base)";
                            QtyToHandleAlt := "Qty. to Ship (Alt.)";
                            // P8000629A
                        end else
                            QtyToHandle := "Outstanding Qty. (Base)";
                        // P8000629A
                        AltQtyTransNo := "Alt. Qty. Trans. No. (Ship)";
                    end;
                Direction::Inbound:
                    begin
                        Qty := "Qty. Shipped (Base)";
                        // P8000629A
                        GetLocation("Transfer-to Code");
                        if Location.LocationType = 1 then begin
                            // P8000629A
                            QtyToHandle := "Qty. to Receive (Base)";
                            QtyToHandleAlt := "Qty. to Receive (Alt.)";
                            // P8000629A
                        end else
                            QtyToHandle := "Qty. Shipped (Base)" - "Qty. Received (Base)";
                        // P8000629A
                        AltQtyTransNo := "Alt. Qty. Trans. No. (Receive)";
                    end;
            end;
            // P8000629A
            if Location.LocationType <> 1 then begin
                GetItem;
                if Item.TrackAlternateUnits and not Item."Catch Alternate Qtys." then
                    QtyToHandleAlt := Round(QtyToHandle * Item.AlternateQtyPerBase, 0.00001);
            end;
            // P8000629A
        end; // P800108868
        EasyLotTracking.SetTransferLine(Rec, Direction);
        EasyLotTracking.ReplaceTracking(xRec."Lot No.", "Lot No.", AltQtyTransNo,
          Qty, QtyToHandle, QtyToHandleAlt, Qty);
    end;

    procedure TestAltQtyEntry(Direction: Option Outbound,Inbound)
    begin
        // P8000282A
        case Direction of
            Direction::Outbound:
                AltQtyMgmt.TestWhseDataEntry("Transfer-from Code", Direction);
            Direction::Inbound:
                AltQtyMgmt.TestWhseDataEntry("Transfer-to Code", Direction);
        end;
    end;

    procedure UpdateOnWhseChange(Direction: Option Outbound,Inbound)
    var
        Location: Record Location;
    begin
        // P8000282A
        if ("Item No." <> '') then
            case Direction of
                Direction::Outbound:
                    if Location.RequireShipment("Transfer-from Code") then begin
                        "Qty. to Ship" := 0;
                        "Qty. to Ship (Base)" := 0;
                        "Qty. to Ship (Alt.)" := 0;
                    end;
                Direction::Inbound:
                    if Location.RequireReceive("Transfer-to Code") then begin
                        "Qty. to Receive" := 0;
                        "Qty. to Receive (Base)" := 0;
                        "Qty. to Receive (Alt.)" := 0;
                    end;
            end;
    end;

    procedure DeleteExtraCharges()
    begin
        // P8000928
        if "Line No." = 0 then
            exit;
        DocExtraCharge.Reset;
        DocExtraCharge.SetRange("Table ID", DATABASE::"Transfer Line"); // P8001032
        DocExtraCharge.SetRange("Document No.", "Document No.");
        DocExtraCharge.SetRange("Line No.", "Line No.");
        DocExtraCharge.DeleteAll;
    end;

    procedure ShowExtraCharges()
    var
        DocExtraCharge: Record "Document Extra Charge";
        Extracharges: Page "Document Line Extra Charges";
    begin
        // P8000928
        TestField("Document No.");
        TestField("Line No.");
        TestField(Type, Type::Item);
        DocExtraCharge.Reset;
        DocExtraCharge.SetRange("Table ID", DATABASE::"Transfer Line"); // P8001032
        DocExtraCharge.SetRange("Document No.", "Document No.");
        DocExtraCharge.SetRange("Line No.", "Line No.");
        Extracharges.SetTableView(DocExtraCharge);
        Extracharges.RunModal;
    end;

    procedure ShowShortcutECCharge(var ShortcutECCharge: array[5] of Decimal)
    begin
        // P8000928
        if not ProcessFns.FreshProInstalled then
            exit;

        if "Line No." <> 0 then
            ExtraChargeMgt.ShowExtraCharge(DATABASE::"Transfer Line", 0, "Document No.", "Line No.", ShortcutECCharge) // P8001032
        else
            ExtraChargeMgt.ShowTempExtraCharge(ShortcutECCharge);
    end;

    procedure ValidateShortcutECCharge(FieldNumber: Integer; Charge: Decimal)
    begin
        // P8000928
        TestStatusOpen;
        TestField(Type, Type::Item);
        ExtraChargeMgt.ValidateExtraCharge(FieldNumber, Charge);
        if "Line No." <> 0 then begin
            ExtraChargeMgt.SaveExtraCharge(DATABASE::"Transfer Line", 0, "Document No.", "Line No.", FieldNumber, Charge); // P8001032
            CalcFields("Extra Charge");
        end else begin
            ExtraChargeMgt.SaveTempExtraCharge(FieldNumber, Charge);
            "Extra Charge" := ExtraChargeMgt.TotalTempExtraCharge;
        end;
    end;

    procedure ExtraChargeUnitCost(): Decimal
    begin
        // P8000928
        CalcFields("Extra Charge");
        if CostInAlternateUnits then begin
            if "Quantity (Alt.)" <> 0 then
                exit("Extra Charge" / "Quantity (Alt.)");
        end else begin
            if Quantity <> 0 then
                exit("Extra Charge" / Quantity);
        end;
    end;

    procedure LineCost(): Decimal
    begin
        // P8000928
        GetItem;
        if CostInAlternateUnits then
            exit(Item."Unit Cost" * "Quantity (Alt.)")
        else
            exit(Item."Unit Cost" * "Quantity (Base)");
    end;

    procedure IsNonWarehouseItem(): Boolean
    begin
        // P8001290
        if (Type in [Type::Item, Type::Container]) and ("Item No." <> '') then begin
            GetItem;
            exit(Item."Non-Warehouse Item");
        end;
    end;

    procedure SkipWhseQtyCheck()
    begin
        WhseValidateSourceLine.SkipWhseQtyCheck; //N138F0000.n
    end;

    procedure IsShippedDimChanged() Result: Boolean
    begin
        Result := ("Dimension Set ID" <> xRec."Dimension Set ID") and (("Quantity Shipped" <> 0) or ("Qty. Shipped (Base)" <> 0));

        OnAfterIsShippedDimChanged(Rec, Result);
    end;

    procedure ConfirmShippedDimChange(): Boolean
    begin
        if not Confirm(Text012, false, TableCaption) then
            Error(Text013);

        exit(true);
    end;

    local procedure SelectItemEntry(CurrentFieldNo: Integer)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        TransferLine2: Record "Transfer Line";
    begin
        SetItemLedgerEntryFilters(ItemLedgEntry);

        if PAGE.RunModal(PAGE::"Item Ledger Entries", ItemLedgEntry) = ACTION::LookupOK then begin
            TransferLine2 := Rec;
            TransferLine2.Validate("Appl.-to Item Entry", ItemLedgEntry."Entry No.");
            CheckItemAvailable(CurrentFieldNo);
            Rec := TransferLine2;
        end;
    end;

    local procedure GetTransferHeaderNoVerification()
    begin
        TestField("Document No.");
        if "Document No." <> TransHeader."No." then
            TransHeader.Get("Document No.");
    end;

    procedure DateConflictCheck()
    begin
        if not TrackingBlocked then
            CheckDateConflict.TransferLineCheck(Rec);
    end;

    procedure GetWarehouseDocumentBin(Direction: Integer; WarehouseDocumentNo: Code[20]) BinCode: Code[20]
    var
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
    begin
        // P80046533
        if WarehouseDocumentNo = '' then begin
            case Direction of
                0:
                    begin
                        if not Location.Get("Transfer-from Code") then
                            exit;
                        BinCode := "Transfer-from Bin Code";
                        if Location."Require Shipment" then
                            BinCode := Location."Shipment Bin Code"
                        else
                            if BinCode = '' then
                                BinCode := Location."Shipment Bin Code (1-Doc)";
                    end;
                1:
                    begin
                        if not Location.Get("Transfer-to Code") then
                            exit;
                        BinCode := "Transfer-To Bin Code";
                        if Location."Require Receive" then
                            BinCode := Location."Receipt Bin Code"
                        else
                            if BinCode = '' then
                                BinCode := Location."Receipt Bin Code (1-Doc)";
                    end;
            end;
        end else begin
            case Direction of
                0:
                    begin
                        if WarehouseDocumentNo <> '' then
                            WarehouseShipmentLine.SetRange("No.", WarehouseDocumentNo);
                        WarehouseShipmentLine.SetRange("Source Type", DATABASE::"Transfer Line");
                        WarehouseShipmentLine.SetRange("Source Subtype", Direction);
                        WarehouseShipmentLine.SetRange("Source No.", "Document No.");
                        WarehouseShipmentLine.SetRange("Source Line No.", "Line No.");
                        if WarehouseShipmentLine.FindFirst then
                            exit(WarehouseShipmentLine."Bin Code");
                    end;
                1:
                    begin
                        if WarehouseDocumentNo <> '' then
                            WarehouseReceiptLine.SetRange("No.", WarehouseDocumentNo);
                        WarehouseReceiptLine.SetRange("Source Type", DATABASE::"Transfer Line");
                        WarehouseReceiptLine.SetRange("Source Subtype", Direction);
                        WarehouseReceiptLine.SetRange("Source No.", "Document No.");
                        WarehouseReceiptLine.SetRange("Source Line No.", "Line No.");
                        if WarehouseReceiptLine.FindFirst then
                            exit(WarehouseReceiptLine."Bin Code");
                    end;
            end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDimTableIDs(var TransferLine: Record "Transfer Line"; FieldNo: Integer; var TableID: array[10] of Integer; var No: array[10] of Code[20])
    begin
    end;

    local procedure ItemExists(ItemNo: Code[20]): Boolean
    var
        IEItem: Record Item;
    begin
        exit(IEItem.Get(ItemNo));
    end;

    local procedure DerivedLinesExist(var TransferLine: Record "Transfer Line"; DocumentNo: Code[20]; DerivedFromLineNo: Integer): Boolean
    begin
        TransferLine.SetRange("Document No.", DocumentNo);
        TransferLine.SetRange("Derived From Line No.", DerivedFromLineNo);
        exit(not TransferLine.IsEmpty);
    end;

    procedure RowID1(Direction: Enum "Transfer Direction"): Text[250]
    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        exit(ItemTrackingMgt.ComposeRowID(DATABASE::"Transfer Line", Direction.AsInteger(), "Document No.", '', "Derived From Line No.", "Line No."));
    end;

    local procedure VerifyReserveTransferLineQuantity()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeVerifyReserveTransferLineQuantity(Rec, IsHandled);
        if IsHandled then
            exit;

        TransferLineReserve.VerifyQuantity(Rec, xRec);
    end;

    local procedure SetItemLedgerEntryFilters(var ItemLedgEntry: Record "Item Ledger Entry")
    begin
        ItemLedgEntry.SetRange("Item No.", "Item No.");
        if "Transfer-from Code" <> '' then
            ItemLedgEntry.SetRange("Location Code", "Transfer-from Code");
        ItemLedgEntry.SetRange("Variant Code", "Variant Code");
        ItemLedgEntry.SetRange(Positive, true);
        ItemLedgEntry.SetRange(Open, true);

        OnAfterSetItemLedgerEntryFilters(ItemLedgEntry, Rec);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignItemValues(var TransferLine: Record "Transfer Line"; Item: Record Item)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterFilterLinesWithItemToPlan(var Item: Record Item; IsReceipt: Boolean; IsSupplyForPlanning: Boolean; var TransferLine: Record "Transfer Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetDefaultBin(var TransferLine: Record "Transfer Line"; FromLocationCode: Code[10]; ToLocationCode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetTransHeader(var TransferLine: Record "Transfer Line"; TransferHeader: Record "Transfer Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitOutstandingQty(var TransferLine: Record "Transfer Line"; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitQtyInTransit(var TransferLine: Record "Transfer Line"; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitQtyToReceive(var TransferLine: Record "Transfer Line"; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitQtyToShip(var TransferLine: Record "Transfer Line"; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterResetPostedQty(var TransferLine: Record "Transfer Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterShowDimensions(var TransferLine: Record "Transfer Line"; xTransferLine: Record "Transfer Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetReservationFilters(var ReservEntry: Record "Reservation Entry"; TransferLine: Record "Transfer Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTestStatusOpen(var TransferLine: Record "Transfer Line"; TransferHeader: Record "Transfer Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateWithWarehouseShipReceive(var TransferLine: Record "Transfer Line"; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateShortcutDimCode(var TransferLine: Record "Transfer Line"; var xTransferLine: Record "Transfer Line"; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckItemAvailable(var TransferLine: Record "Transfer Line"; CalledByFieldNo: Integer; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckItemCanBeShipped(var TransferLine: Record "Transfer Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckTransferHeader(TransferHeader: Record "Transfer Header"; var IsHandled: Boolean; TransferLine: Record "Transfer Line"; xTransferLine: Record "Transfer Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckWarehouse(TransferLine: Record "Transfer Line"; Location: Record Location; Receive: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetItemNo(var TransLine: Record "Transfer Line"; xTransLine: Record "Transfer Line"; CurrentFieldNo: Integer; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetTransHeader(var TransferLine: Record "Transfer Line"; var TransferHeader: Record "Transfer Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnInsert(var TransferLine: Record "Transfer Line"; var xTransferLine: Record "Transfer Line"; TransferHeader: Record "Transfer Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestStatusOpen(var TransferLine: Record "Transfer Line"; TransferHeader: Record "Transfer Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateWithWarehouseShipReceive(var TransferLine: Record "Transfer Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateDescription(var TransferLine: Record "Transfer Line"; xTransferLine: Record "Transfer Line"; CurrFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateShortcutDimCode(var TransferLine: Record "Transfer Line"; var xTransferLine: Record "Transfer Line"; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateQuantityBase(var TransferLine: Record "Transfer Line"; var xTransferLine: Record "Transfer Line"; FieldNumber: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateQtyToShipBase(var TransferLine: Record "Transfer Line"; var xTransferLine: Record "Transfer Line"; FieldNumber: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateQtyToReceiveBase(var TransferLine: Record "Transfer Line"; var xTransferLine: Record "Transfer Line"; FieldNumber: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeVerifyReserveTransferLineQuantity(var TransferLine: Record "Transfer Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeleteOnBeforeDeleteRelatedData(var TransferLine: Record "Transfer Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateItemNoOnAfterInitLine(var TransferLine: Record "Transfer Line"; TempTransferLine: Record "Transfer Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateItemNoOnAfterGetTransHeaderExternal(var TransferLine: Record "Transfer Line"; var TransHeader: Record "Transfer Header"; TempTransferLine: Record "Transfer Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateItemNoOnCopyFromTempTransLine(var TransferLine: Record "Transfer Line"; TempTransferLine: Record "Transfer Line" temporary)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnValidateReceiptDateOnBeforeCalcShipmentDate(var IsHandled: Boolean; var TransferLine: Record "Transfer Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnValidateShipmentDateOnBeforeCalcReceiptDate(var IsHandled: Boolean; var TransferLine: Record "Transfer Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateQuantityOnBeforeTransLineVerifyChange(var TransferLine: Record "Transfer Line"; xTransferLine: Record "Transfer Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateQuantityOnAfterCalcQuantityBase(var TransferLine: Record "Transfer Line"; xTransferLine: Record "Transfer Line")
    begin
    end;

    procedure CheckWarehouseGlobal(LocationCode: Code[10]; Receive: Boolean)
    var
        Location: Record "Location";
    begin
        Location.Get(LocationCode); // P800-MegaApp
        CheckWarehouse(Location, Receive); // P80081811
    end;

    procedure WarehouseLineQuantity(pQtyToRecvShipBase: Decimal; pAltQtyToRecvShipBase: Decimal; pDirection: Integer);
    begin
        // P800108868
        UseWhseLineQty := TRUE;
        WhseLineQtyBase := pQtyToRecvShipBase;
        WhseLineAltQtyBase := pAltQtyToRecvShipBase;
        gDirection := pDirection;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetItemLedgerEntryFilters(var ItemLedgEntry: Record "Item Ledger Entry"; TransferLine: Record "Transfer Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetDefaultBin(var TransferLine: Record "Transfer Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckWarehouseOnBeforeShowDialog(TransferLine: Record "Transfer Line"; Location: Record Location; ShowDialog: Option " ",Message,Error; var DialogText: Text[50])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertOnBeforeAssignLineNo(var TransferLine: Record "Transfer Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIsShippedDimChanged(var TransferLine: Record "Transfer Line"; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowReservation(var TransferLine: Record "Transfer Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateTransferFromCodeOnBeforeCheckItemAvailable(var TransferLine: Record "Transfer Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateTransferToCodeOnBeforeVerifyChange(var TransferLine: Record "Transfer Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateVariantCodeOnBeforeCheckEmptyVariantCode(var TransferLine: Record "Transfer Line"; xTransferLine: Record "Transfer Line"; CurrentFieldNo: Integer)
    begin
    end;
}

