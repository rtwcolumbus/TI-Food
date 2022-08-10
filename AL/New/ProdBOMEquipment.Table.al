table 37002468 "Prod. BOM Equipment"
{
    // PR1.00, Myers Nissi & Co., Bob Rainville, 9/26/00, Process 800
    //   New table
    // 
    // PR1.00, Myers Nissi, Diane Fox, 3 NOV 00, PR009
    //   Add Version Code
    //   Add Est. Batch Time
    //   Add Net Capacity
    // 
    // PR.102
    //   ConvertUnits - work with BOM type of Process
    //   Orders - change CalcFormula to include Package and Process orders, remove reference to Source
    // 
    // PR3.10
    //   Change reference to Production Order table
    // 
    // PR3.70.05
    // P8000067A, Myers Nissi, Jack Reynolds, 07 JUL 04
    //   ConvertCapacity - rewritten to use ItemNo to convert to
    // 
    // PR4.00
    // P8000219A, Myers Nissi, Jack Reynolds, 24 JUN 05
    //   Allow equipment to be related to a routing
    // 
    // P8000197A, Myers Nissi, Jack Reynolds, 21 SEP 05
    //   Add support for fixed and variable production times
    // 
    // PRW15.00.01
    // P8000564A, VerticalSoft, Jack Reynolds, 08 FEB 08
    //   Change Description field to TEXT50
    // 
    // PRW16.00
    // P8000639, VerticalSoft, Jack Reynolds, 18 NOV 08
    //   Add DropDown field group
    // 
    // PRW16.00.04
    // P8000877, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Add key for sorting by preference
    // 
    // PRW16.00.06
    // P8001107, Columbus IT, Don Bresee, 19 OCT 12
    //   Add Minimum Equipment Qty. field, add logic to validate capacity quantities
    // 
    // PRW17.10.02
    // P8001271, Columbus IT, Jack Reynolds, 24 JAN 14
    //   Fix missing TableRelation properties
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 08 MAR 16
    //   Expand BOM Version code to Code20
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Prod. BOM Equipment';
    LookupPageID = "Production BOM Equipment";

    fields
    {
        field(5; "Production Bom No."; Code[20])
        {
            Caption = 'Production Bom No.';
            TableRelation = "Production BOM Header";
        }
        field(7; "Version Code"; Code[20])
        {
            Caption = 'Version Code';
            TableRelation = "Production BOM Version"."Version Code" WHERE("Production BOM No." = FIELD("Production Bom No."));
        }
        field(10; "Resource No."; Code[20])
        {
            Caption = 'Resource No.';
            NotBlank = true;
            TableRelation = Resource WHERE(Type = CONST(Machine));

            trigger OnValidate()
            begin
                Resource.Get("Resource No.");
                Description := Resource.Name;
                "Unit of Measure" := Resource."Capacity UOM";
                "Equipment Capacity" := Resource."Equipment Capacity";
                "Minimum Equipment Qty." := Resource."Minimum Equipment Qty."; // P8001107
                "Capacity Level %" := Resource."Capacity Level %"; // P8001107, moved up from after ConvertUnits
                ConvertUnits(true, true, '');
                Validate("Net Capacity");
            end;
        }
        field(20; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(30; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            Editable = false;
            TableRelation = "Unit of Measure";
        }
        field(40; "Equipment Capacity"; Decimal)
        {
            Caption = 'Equipment Capacity';
            DecimalPlaces = 0 : 5;
            Editable = false;

            trigger OnValidate()
            begin
                Validate("Net Capacity"); // P8001107
            end;
        }
        field(50; "Capacity Level %"; Decimal)
        {
            Caption = 'Capacity Level %';
            DecimalPlaces = 0 : 2;
            MaxValue = 100;

            trigger OnValidate()
            begin
                Validate("Net Capacity");
            end;
        }
        field(60; Preference; Option)
        {
            Caption = 'Preference';
            OptionCaption = '1,2,3,4,5,6,7,8,9,10';
            OptionMembers = "1","2","3","4","5","6","7","8","9","10";
        }
        field(61; Orders; Integer)
        {
            CalcFormula = Count ("Production Order" WHERE(Status = CONST(Released),
                                                          "Order Type" = FILTER(Batch | Package | Process),
                                                          "Equipment Code" = FIELD("Resource No."),
                                                          "Starting Date" = FIELD("Date Filter")));
            Caption = 'Orders';
            Editable = false;
            FieldClass = FlowField;
        }
        field(62; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(63; "Item Filter"; Code[20])
        {
            Caption = 'Item Filter';
            FieldClass = FlowFilter;
            TableRelation = Item;
        }
        field(64; "Fixed Prod. Time (Hours)"; Decimal)
        {
            Caption = 'Fixed Prod. Time (Hours)';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(65; "Net Capacity"; Decimal)
        {
            Caption = 'Net Capacity';
            DecimalPlaces = 0 : 5;
            Editable = false;

            trigger OnValidate()
            begin
                "Net Capacity" := "Equipment Capacity" * "Capacity Level %" / 100;
                ValidateEquipmentQtys; // P8001107
            end;
        }
        field(66; "Routing No."; Code[20])
        {
            Caption = 'Routing No.';
            TableRelation = "Routing Header";
        }
        field(67; "Variable Prod. Time (Hours)"; Decimal)
        {
            Caption = 'Variable Prod. Time (Hours)';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(68; "Minimum Equipment Qty."; Decimal)
        {
            Caption = 'Minimum Equipment Qty.';
            DecimalPlaces = 0 : 5;
            Editable = false;

            trigger OnValidate()
            begin
                ValidateEquipmentQtys; // P8001107
            end;
        }
    }

    keys
    {
        key(Key1; "Production Bom No.", "Version Code", "Resource No.")
        {
        }
        key(Key2; "Routing No.")
        {
        }
        key(Key3; Preference)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Resource No.", Description)
        {
        }
    }

    trigger OnDelete()
    begin
        TestStatus;

        // P8000219A Begin
        BOMCost.SetRange("Production Bom No.", "Production Bom No.");
        BOMCost.SetRange("Version Code", "Version Code");
        BOMCost.SetRange("Equipment No.", "Resource No.");
        BOMCost.DeleteAll;
        // P8000219A End
    end;

    trigger OnInsert()
    begin
        TestStatus;
    end;

    trigger OnModify()
    begin
        TestStatus;
    end;

    var
        Resource: Record Resource;
        UOM: Record "Unit of Measure";
        BOMVersion: Record "Production BOM Version";
        BOMCost: Record "Prod. BOM Activity Cost";

    procedure ConvertUnits(wgt: Boolean; vol: Boolean; UOMCode: Code[10]) changed: Boolean
    begin
        UOM.Get("Unit of Measure");
        if (wgt and (UOM.Type = UOM.Type::Weight)) or (vol and (UOM.Type = UOM.Type::Volume)) then begin
            "Equipment Capacity" *= UOM."Base per Unit of Measure";
            "Minimum Equipment Qty." *= UOM."Base per Unit of Measure"; // P8001107
            if UOMCode = '' then begin
                BOMVersion.Get("Production Bom No.", "Version Code");
                if BOMVersion.Type in [BOMVersion.Type::Formula, BOMVersion.Type::Process] then begin // PR1.20
                    case UOM.Type of
                        UOM.Type::Weight:
                            UOM.Get(BOMVersion."Weight UOM");
                        UOM.Type::Volume:
                            UOM.Get(BOMVersion."Volume UOM");
                    end;
                end;
            end else
                UOM.Get(UOMCode);
            "Equipment Capacity" /= UOM."Base per Unit of Measure";
            "Minimum Equipment Qty." /= UOM."Base per Unit of Measure"; // P8001107
            "Unit of Measure" := UOM.Code;
            Validate("Net Capacity");
            changed := true;
        end;
    end;

    procedure TestStatus()
    var
        ProdBOMHeader: Record "Production BOM Header";
        ProdBOMVersion: Record "Production BOM Version";
    begin
        if "Version Code" = '' then begin
            ProdBOMHeader.Get("Production Bom No.");
            if ProdBOMHeader.Status = ProdBOMHeader.Status::Certified then
                ProdBOMHeader.FieldError(Status);
        end else begin
            ProdBOMVersion.Get("Production Bom No.", "Version Code");
            if ProdBOMVersion.Status = ProdBOMVersion.Status::Certified then
                ProdBOMVersion.FieldError(Status);
        end;
    end;

    procedure ConvertCapacity(ToUOM: Code[10]; ItemNo: Code[20])
    var
        UOM: Record "Unit of Measure";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
    begin
        // P8000067A - rewritten to use ItemNo to convert to
        case UOM.Type of
            UOM.Type::Weight, UOM.Type::Volume:
                begin
                    "Net Capacity" := P800UOMFns.ConvertUOM("Net Capacity", "Unit of Measure", 'METRIC BASE');
                    "Net Capacity" := "Net Capacity" / P800UOMFns.GetConversionToMetricBase(ItemNo, ToUOM, UOM.Type);
                    "Unit of Measure" := ToUOM;
                end;
        end;
    end;

    procedure CalcTimeFromRouting(QtyFactor: Decimal)
    var
        RoutingLine: Record "Routing Line";
        VersionMgt: Codeunit VersionManagement;
        CalendarMgt: Codeunit "Shop Calendar Management";
    begin
        // P8000197A
        if "Routing No." = '' then
            exit;

        "Fixed Prod. Time (Hours)" := 0;
        "Variable Prod. Time (Hours)" := 0;
        RoutingLine.SetRange("Routing No.", "Routing No.");
        RoutingLine.SetRange("Version Code", VersionMgt.GetRtngVersion("Routing No.", Today, true));
        if RoutingLine.Find('-') then
            repeat
                "Fixed Prod. Time (Hours)" += RoutingLine."Setup Time" *
                  CalendarMgt.TimeFactor(RoutingLine."Setup Time Unit of Meas. Code");
                "Variable Prod. Time (Hours)" += RoutingLineRunTimePer(RoutingLine) * // P8007748
                  CalendarMgt.TimeFactor(RoutingLine."Run Time Unit of Meas. Code");
            until RoutingLine.Next = 0;

        "Fixed Prod. Time (Hours)" := Round("Fixed Prod. Time (Hours)" / 3600000, 0.00001);
        "Variable Prod. Time (Hours)" := Round("Variable Prod. Time (Hours)" / (3600000 * QtyFactor), 0.00001);
    end;

    local procedure ValidateEquipmentQtys()
    begin
        Resource.ValidateEquipmentQtys("Equipment Capacity", "Capacity Level %", "Minimum Equipment Qty."); // P8001107
    end;

    local procedure RoutingLineRunTimePer(RoutingLine: Record "Routing Line"): Decimal
    begin
        // P8007748
        if RoutingLine."Lot Size" = 0 then
            RoutingLine."Lot Size" := 1;

        exit(Round(RoutingLine."Run Time" / RoutingLine."Lot Size", 0.00001));
    end;
}

