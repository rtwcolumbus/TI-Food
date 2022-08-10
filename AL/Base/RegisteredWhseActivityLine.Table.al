table 5773 "Registered Whse. Activity Line"
{
    // PR4.00.04
    // P8000322A, Don Bresee, 29 JUL 06
    //   Add fields/key for Undo function, add Breakbulk No. field.
    //   Staged Picks
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Don Bresee, 12 JUN 07
    //   CalcBaseQty removed
    // 
    // PRW15.00.03
    // P8000630A, VerticalSoft, Don Bresee, 17 SEP 08
    //   Add Delivery Trip Pick to Whse. Document Type

    Caption = 'Registered Whse. Activity Line';
    DrillDownPageID = "Registered Whse. Act.-Lines";
    LookupPageID = "Registered Whse. Act.-Lines";

    fields
    {
        field(1; "Activity Type"; Enum "Warehouse Activity Type")
        {
            Caption = 'Activity Type';
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; "Source Type"; Integer)
        {
            Caption = 'Source Type';
        }
        field(5; "Source Subtype"; Option)
        {
            Caption = 'Source Subtype';
            OptionCaption = '0,1,2,3,4,5,6,7,8,9,10';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9","10";
        }
        field(6; "Source No."; Code[20])
        {
            Caption = 'Source No.';
        }
        field(7; "Source Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Source Line No.';
        }
        field(8; "Source Subline No."; Integer)
        {
            BlankZero = true;
            Caption = 'Source Subline No.';
        }
        field(9; "Source Document"; Enum "Warehouse Activity Source Document")
        {
            BlankZero = true;
            Caption = 'Source Document';
        }
        field(11; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(12; "Shelf No."; Code[10])
        {
            Caption = 'Shelf No.';
        }
        field(13; "Sorting Sequence No."; Integer)
        {
            Caption = 'Sorting Sequence No.';
        }
        field(14; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(15; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(16; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(17; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            InitValue = 1;
        }
        field(18; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(19; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
        }
        field(20; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                TestField("Qty. per Unit of Measure");                                 // P8000466A
                "Qty. (Base)" := Round(Quantity * "Qty. per Unit of Measure", 0.00001); // P8000466A
            end;
        }
        field(21; "Qty. (Base)"; Decimal)
        {
            Caption = 'Qty. (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(31; "Shipping Advice"; Enum "Sales Header Shipping Advice")
        {
            Caption = 'Shipping Advice';
        }
        field(34; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(39; "Destination Type"; enum "Warehouse Destination Type")
        {
            Caption = 'Destination Type';
        }
        field(40; "Destination No."; Code[20])
        {
            Caption = 'Destination No.';
            TableRelation = IF ("Destination Type" = CONST(Vendor)) Vendor
            ELSE
            IF ("Destination Type" = CONST(Customer)) Customer
            ELSE
            IF ("Destination Type" = CONST(Location)) Location
            ELSE
            IF ("Destination Type" = CONST(Item)) Item
            ELSE
            IF ("Destination Type" = CONST(Family)) Family
            ELSE
            IF ("Destination Type" = CONST("Sales Order")) "Sales Header"."No." WHERE("Document Type" = CONST(Order));
        }
        field(41; "Whse. Activity No."; Code[20])
        {
            Caption = 'Whse. Activity No.';
        }
        field(42; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";
        }
        field(43; "Shipping Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code WHERE("Shipping Agent Code" = FIELD("Shipping Agent Code"));
        }
        field(44; "Shipment Method Code"; Code[10])
        {
            Caption = 'Shipment Method Code';
            TableRelation = "Shipment Method";
        }
        field(47; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
        }
        field(6500; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';

            trigger OnLookup()
            begin
                ItemTrackingMgt.LookupTrackingNoInfo("Item No.", "Variant Code", ItemTrackingType::"Serial No.", "Serial No.");
            end;
        }
        field(6501; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';

            trigger OnLookup()
            begin
                ItemTrackingMgt.LookupTrackingNoInfo("Item No.", "Variant Code", ItemTrackingType::"Lot No.", "Lot No.");
            end;
        }
        field(6502; "Warranty Date"; Date)
        {
            Caption = 'Warranty Date';
        }
        field(6503; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
        }
        field(6515; "Package No."; Code[50])
        {
            Caption = 'Package No.';
            CaptionClass = '6,1';

            trigger OnLookup()
            begin
                ItemTrackingMgt.LookupTrackingNoInfo("Item No.", "Variant Code", "Item Tracking Type"::"Package No.", "Package No.");
            end;
        }
        field(7300; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = IF ("Action Type" = FILTER(<> Take)) Bin.Code WHERE("Location Code" = FIELD("Location Code"),
                                                                              "Zone Code" = FIELD("Zone Code"))
            ELSE
            IF ("Action Type" = FILTER(<> Take),
                                                                                       "Zone Code" = FILTER('')) Bin.Code WHERE("Location Code" = FIELD("Location Code"))
            ELSE
            IF ("Action Type" = CONST(Take)) "Bin Content"."Bin Code" WHERE("Location Code" = FIELD("Location Code"),
                                                                                                                                                           "Zone Code" = FIELD("Zone Code"))
            ELSE
            IF ("Action Type" = CONST(Take),
                                                                                                                                                                    "Zone Code" = FILTER('')) "Bin Content"."Bin Code" WHERE("Location Code" = FIELD("Location Code"));
        }
        field(7301; "Zone Code"; Code[10])
        {
            Caption = 'Zone Code';
            TableRelation = Zone.Code WHERE("Location Code" = FIELD("Location Code"));
        }
        field(7305; "Action Type"; Enum "Warehouse Action Type")
        {
            Caption = 'Action Type';
            Editable = false;
        }
        field(7306; "Whse. Document Type"; Enum "Warehouse Activity Document Type")
        {
            Caption = 'Whse. Document Type';
            Editable = false;
        }
        field(7307; "Whse. Document No."; Code[20])
        {
            Caption = 'Whse. Document No.';
            Editable = false;
            TableRelation = IF ("Whse. Document Type" = CONST(Receipt)) "Posted Whse. Receipt Header"."No." WHERE("No." = FIELD("Whse. Document No."))
            ELSE
            IF ("Whse. Document Type" = CONST(Shipment)) "Warehouse Shipment Header"."No." WHERE("No." = FIELD("Whse. Document No."))
            ELSE
            IF ("Whse. Document Type" = CONST("Internal Put-away")) "Whse. Internal Put-away Header"."No." WHERE("No." = FIELD("Whse. Document No."))
            ELSE
            IF ("Whse. Document Type" = CONST("Internal Pick")) "Whse. Internal Pick Header"."No." WHERE("No." = FIELD("Whse. Document No."))
            ELSE
            IF ("Whse. Document Type" = CONST(Production)) "Production Order"."No." WHERE("No." = FIELD("Whse. Document No."))
            ELSE
            IF ("Whse. Document Type" = CONST(Assembly)) "Assembly Header"."No." WHERE("Document Type" = CONST(Order),
                                                                                                           "No." = FIELD("Whse. Document No."))
            ELSE
            IF ("Whse. Document Type" = CONST(FOODStagedPick)) "Whse. Staged Pick Header"."No." WHERE("No." = FIELD("Whse. Document No."));
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(7308; "Whse. Document Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Whse. Document Line No.';
            Editable = false;
            TableRelation = IF ("Whse. Document Type" = CONST(Receipt)) "Posted Whse. Receipt Line"."Line No." WHERE("No." = FIELD("Whse. Document No."),
                                                                                                                    "Line No." = FIELD("Whse. Document Line No."))
            ELSE
            IF ("Whse. Document Type" = CONST(Shipment)) "Warehouse Shipment Line"."Line No." WHERE("No." = FIELD("Whse. Document No."),
                                                                                                                                                                                                                "Line No." = FIELD("Whse. Document Line No."))
            ELSE
            IF ("Whse. Document Type" = CONST("Internal Put-away")) "Whse. Internal Put-away Line"."Line No." WHERE("No." = FIELD("Whse. Document No."),
                                                                                                                                                                                                                                                                                                                            "Line No." = FIELD("Whse. Document Line No."))
            ELSE
            IF ("Whse. Document Type" = CONST("Internal Pick")) "Whse. Internal Pick Line"."Line No." WHERE("No." = FIELD("Whse. Document No."),
                                                                                                                                                                                                                                                                                                                                                                                                                                "Line No." = FIELD("Whse. Document Line No."))
            ELSE
            IF ("Whse. Document Type" = CONST(Production)) "Prod. Order Line"."Line No." WHERE("Prod. Order No." = FIELD("No."),
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       "Line No." = FIELD("Line No."))
            ELSE
            IF ("Whse. Document Type" = CONST(Assembly)) "Assembly Line"."Line No." WHERE("Document Type" = CONST(Order),
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         "Document No." = FIELD("Whse. Document No."),
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         "Line No." = FIELD("Whse. Document Line No."))
            ELSE
            IF ("Whse. Document Type" = CONST(FOODStagedPick)) "Whse. Staged Pick Line"."Line No." WHERE("No." = FIELD("Whse. Document No."),
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         "Line No." = FIELD("Whse. Document Line No."));
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(7310; Cubage; Decimal)
        {
            Caption = 'Cubage';
            DecimalPlaces = 0 : 5;
        }
        field(7311; Weight; Decimal)
        {
            Caption = 'Weight';
            DecimalPlaces = 0 : 5;
        }
        field(7312; "Special Equipment Code"; Code[10])
        {
            Caption = 'Special Equipment Code';
            TableRelation = "Special Equipment";
        }
        field(37002081; "Quantity (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,0,0,%1', "Item No.");
            Caption = 'Quantity (Alt.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(37002100; "Undo-to Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Undo-to Line No.';
            Editable = false;
            TableRelation = "Registered Whse. Activity Line"."Line No." WHERE("Activity Type" = FIELD("Activity Type"),
                                                                               "No." = FIELD("No."));
        }
        field(37002101; "Qty. Undone (Base)"; Decimal)
        {
            BlankZero = true;
            CalcFormula = Sum("Registered Whse. Activity Line"."Qty. (Base)" WHERE("Activity Type" = FIELD("Activity Type"),
                                                                                    "No." = FIELD("No."),
                                                                                    "Undo-to Line No." = FIELD("Line No.")));
            Caption = 'Qty. Undone (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002102; "Breakbulk No."; Integer)
        {
            BlankZero = true;
            Caption = 'Breakbulk No.';
        }
        field(37002561; "Container ID"; Code[20])
        {
            Caption = 'Container ID';
        }
        field(37002564; "Container License Plate"; Code[50])
        {
            Caption = 'Container License Plate';
        }
        field(37002760; "From Staged Pick No."; Code[20])
        {
            Caption = 'From Staged Pick No.';
            TableRelation = "Whse. Staged Pick Header";
        }
        field(37002761; "From Staged Pick Line No."; Integer)
        {
            Caption = 'From Staged Pick Line No.';
            TableRelation = "Whse. Staged Pick Line"."Line No." WHERE("No." = FIELD("From Staged Pick No."));
        }
    }

    keys
    {
        key(Key1; "Activity Type", "No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "No.", "Line No.", "Activity Type")
        {
        }
        key(Key3; "Activity Type", "No.", "Sorting Sequence No.")
        {
        }
        key(Key4; "Whse. Document Type", "Whse. Document No.", "Whse. Document Line No.")
        {
        }
        key(Key5; "Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.", "Whse. Document No.", "Serial No.", "Lot No.", "Action Type")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Qty. (Base)";
        }
        key(Key37002000; "Activity Type", "No.", "Undo-to Line No.")
        {
            SumIndexFields = "Qty. (Base)";
        }
        key(Key37002001; "From Staged Pick No.", "From Staged Pick Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        ItemTrackingType: Enum "Item Tracking Type";

    procedure ShowRegisteredActivityDoc()
    var
        RegisteredWhseActivHeader: Record "Registered Whse. Activity Hdr.";
        RegisteredPickCard: Page "Registered Pick";
        RegisteredPutAwayCard: Page "Registered Put-away";
        RegisteredMovCard: Page "Registered Movement";
    begin
        RegisteredWhseActivHeader.SetRange(Type, "Activity Type");
        RegisteredWhseActivHeader.SetRange("No.", "No.");
        RegisteredWhseActivHeader.FindFirst;
        case "Activity Type" of
            "Activity Type"::Pick:
                begin
                    RegisteredPickCard.SetRecord(RegisteredWhseActivHeader);
                    RegisteredPickCard.SetTableView(RegisteredWhseActivHeader);
                    RegisteredPickCard.RunModal;
                end;
            "Activity Type"::"Put-away":
                begin
                    RegisteredPutAwayCard.SetRecord(RegisteredWhseActivHeader);
                    RegisteredPutAwayCard.SetTableView(RegisteredWhseActivHeader);
                    RegisteredPutAwayCard.RunModal;
                end;
            "Activity Type"::Movement:
                begin
                    RegisteredMovCard.SetRecord(RegisteredWhseActivHeader);
                    RegisteredMovCard.SetTableView(RegisteredWhseActivHeader);
                    RegisteredMovCard.RunModal;
                end;
        end;
    end;

    procedure ShowWhseDoc()
    var
        WhseShptHeader: Record "Warehouse Shipment Header";
        PostedWhseRcptHeader: Record "Posted Whse. Receipt Header";
        WhseInternalPickHeader: Record "Whse. Internal Pick Header";
        WhseInternalPutawayHeader: Record "Whse. Internal Put-away Header";
        RelProdOrder: Record "Production Order";
        AssemblyHeader: Record "Assembly Header";
        WhseShptCard: Page "Warehouse Shipment";
        PostedWhseRcptCard: Page "Posted Whse. Receipt";
        WhseInternalPickCard: Page "Whse. Internal Pick";
        WhseInternalPutawayCard: Page "Whse. Internal Put-away";
        RelProdOrderCard: Page "Released Production Order";
        IsHandled: Boolean;
        WhseStagedPickHeader: Record "Whse. Staged Pick Header";
        WhseStagedPickCard: Page "Whse. Staged Pick";
    begin
        IsHandled := false;
        OnBeforeShowWhseDoc(Rec, IsHandled);
        if IsHandled then
            exit;

        case "Whse. Document Type" of
            "Whse. Document Type"::Shipment:
                begin
                    WhseShptHeader.SetRange("No.", "Whse. Document No.");
                    WhseShptCard.SetTableView(WhseShptHeader);
                    WhseShptCard.RunModal;
                end;
            "Whse. Document Type"::Receipt:
                begin
                    PostedWhseRcptHeader.SetRange("No.", "Whse. Document No.");
                    PostedWhseRcptCard.SetTableView(PostedWhseRcptHeader);
                    PostedWhseRcptCard.RunModal;
                end;
            "Whse. Document Type"::"Internal Pick":
                begin
                    WhseInternalPickHeader.SetRange("No.", "Whse. Document No.");
                    WhseInternalPickHeader.FindFirst;
                    WhseInternalPickCard.SetRecord(WhseInternalPickHeader);
                    WhseInternalPickCard.SetTableView(WhseInternalPickHeader);
                    WhseInternalPickCard.RunModal;
                end;
            "Whse. Document Type"::"Internal Put-away":
                begin
                    WhseInternalPutawayHeader.SetRange("No.", "Whse. Document No.");
                    WhseInternalPutawayHeader.FindFirst;
                    WhseInternalPutawayCard.SetRecord(WhseInternalPutawayHeader);
                    WhseInternalPutawayCard.SetTableView(WhseInternalPutawayHeader);
                    WhseInternalPutawayCard.RunModal;
                end;
            "Whse. Document Type"::Production:
                begin
                    RelProdOrder.SetRange(Status, "Source Subtype");
                    RelProdOrder.SetRange("No.", "Source No.");
                    RelProdOrderCard.SetTableView(RelProdOrder);
                    RelProdOrderCard.RunModal;
                end;
            "Whse. Document Type"::Assembly:
                begin
                    AssemblyHeader.SetRange("Document Type", "Source Subtype");
                    AssemblyHeader.SetRange("No.", "Source No.");
                    PAGE.Run(PAGE::"Assembly Order", AssemblyHeader);
                end;
            // P8000322A
            "Whse. Document Type"::FOODStagedPick:
                begin
                    WhseStagedPickHeader.SetRange("No.", "Whse. Document No.");
                    WhseStagedPickCard.SetTableView(WhseStagedPickHeader);
                    WhseStagedPickCard.RunModal;
                end;
        // P8000322A
        end;
    end;

    procedure ShowWhseEntries(RegisterDate: Date)
    var
        WhseEntry: Record "Warehouse Entry";
        WhseEntries: Page "Warehouse Entries";
    begin
        WhseEntry.SetCurrentKey("Reference No.", "Registering Date");
        WhseEntry.SetRange("Reference No.", "No.");
        WhseEntry.SetRange("Registering Date", RegisterDate);
        case "Activity Type" of
            "Activity Type"::"Put-away":
                WhseEntry.SetRange(
                  "Reference Document", WhseEntry."Reference Document"::"Put-away");
            "Activity Type"::Pick:
                WhseEntry.SetRange(
                  "Reference Document", WhseEntry."Reference Document"::Pick);
            "Activity Type"::Movement:
                WhseEntry.SetRange(
                  "Reference Document", WhseEntry."Reference Document"::Movement);
        end;
        WhseEntries.SetTableView(WhseEntry);
        WhseEntries.RunModal;
    end;

    procedure SetSourceFilter(SourceType: Integer; SourceSubType: Option; SourceNo: Code[20]; SourceLineNo: Integer; SourceSubLineNo: Integer; SetKey: Boolean)
    begin
        if SetKey then
            SetCurrentKey("Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.");
        SetRange("Source Type", SourceType);
        if SourceSubType >= 0 then
            SetRange("Source Subtype", SourceSubType);
        SetRange("Source No.", SourceNo);
        SetRange("Source Line No.", SourceLineNo);
        if SourceSubLineNo >= 0 then
            SetRange("Source Subline No.", SourceSubLineNo);
    end;

    procedure ClearSourceFilter()
    begin
        SetRange("Source Type");
        SetRange("Source Subtype");
        SetRange("Source No.");
        SetRange("Source Line No.");
        SetRange("Source Subline No.");
    end;

    procedure ClearTrackingFilter()
    begin
        SetRange("Serial No.");
        SetRange("Lot No.");

        OnAfterClearTrackingFilter(Rec);
    end;

#if not CLEAN17
    [Obsolete('Replaced by SetTrackingFilterFrom procedures.', '17.0')]
    procedure SetTrackingFilter(SerialNo: Code[50]; LotNo: Code[50])
    begin
        SetRange("Serial No.", SerialNo);
        SetRange("Lot No.", LotNo);
    end;
#endif

    procedure SetTrackingFilterFromRelation(WhseItemEntryRelation: Record "Whse. Item Entry Relation")
    begin
        SetRange("Serial No.", WhseItemEntryRelation."Serial No.");
        SetRange("Lot No.", WhseItemEntryRelation."Lot No.");

        OnAfterSetTrackingFilterFromRelation(Rec, WhseItemEntryRelation);
    end;

    procedure SetTrackingFilterFromSpec(TrackingSpecification: Record "Tracking Specification")
    begin
        SetRange("Serial No.", TrackingSpecification."Serial No.");
        SetRange("Lot No.", TrackingSpecification."Lot No.");

        OnAfterSetTrackingFilterFromSpec(Rec, TrackingSpecification);
    end;

    procedure SetTrackingFilterFromWhseActivityLine(WhseActivLine: Record "Warehouse Activity Line")
    begin
        SetRange("Serial No.", WhseActivLine."Serial No.");
        SetRange("Lot No.", WhseActivLine."Lot No.");

        OnAfterSetTrackingFilterFromWhseActivityLine(Rec, WhseActivLine);
    end;

    procedure SetTrackingFilterFromWhseSpec(WhseItemTrackingLine: Record "Whse. Item Tracking Line")
    begin
        SetRange("Serial No.", WhseItemTrackingLine."Serial No.");
        SetRange("Lot No.", WhseItemTrackingLine."Lot No.");

        OnAfterSetTrackingFilterFromWhseSpec(Rec, WhseItemTrackingLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterClearTrackingFilter(var RegisteredWhseActivityLine: Record "Registered Whse. Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetTrackingFilterFromSpec(var RegisteredWhseActivityLine: Record "Registered Whse. Activity Line"; TrackingSpecification: Record "Tracking Specification")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetTrackingFilterFromRelation(var RegisteredWhseActivityLine: Record "Registered Whse. Activity Line"; WhseItemEntryRelation: Record "Whse. Item Entry Relation")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetTrackingFilterFromWhseActivityLine(var RegisteredWhseActivityLine: Record "Registered Whse. Activity Line"; WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetTrackingFilterFromWhseSpec(var RegisteredWhseActivityLine: Record "Registered Whse. Activity Line"; WhseItemTrackingLine: Record "Whse. Item Tracking Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowWhseDoc(RegisteredWhseActivityLine: Record "Registered Whse. Activity Line"; var IsHandled: Boolean);
    begin
    end;
}

