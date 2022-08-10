table 99000779 "Production BOM Version"
{
    // PR1.00
    //   Maintain related Equipment, Activity Based Costs, Q/C when deleting records
    //   Modify validation for Status when formulas are certified
    //   Modify validation for Status to certify/decertify header
    //   New Process 800 fields
    //     Type
    //     Weight UOM
    //     Volume UOM
    //     Yield % (Weight)
    //     Yield % (Volume)
    //     Primary UOM
    //     Outout Weight (Metric Base)
    //     Output Volume (Metric Base)
    //     Total Cost (Material)
    //     Total Cost (ABC)
    //     Overhead Cost (ABC)
    //     Cost Type Filter
    //     Include in Rollup Filter
    //     Input Weight (Metric Base)
    //     Input Volume (Metric Base)
    //   New Process 800 function
    //     InitRecord
    //     UpdateLineQty
    //     UpdateABCAmount
    //     UpdateEquipmentUOM
    // 
    // PR1.00.03
    //   Support for Phantom BOM's
    // 
    // PR1.10
    //   Remove OnDelete code to delete quality line
    //   Correct field name misspelling
    // 
    // PR1.20
    //   Add support for Item Process
    //   Add Process to Type OptionString
    // 
    // PR1.10.01
    //   Change field names (Metric Base) to (Base)
    // 
    // PR2.00.02
    //   Create function to return Production BOM description
    // 
    // PR2.00.05
    //   Status - don't allow certification if BOM has variables and BOM is attached to an item
    // 
    // PR3.70
    //   Relocate Status check for variables to Production BOM-Check codeunit
    // 
    // PR3.70.03
    //   Add field
    //     Proper Shipping Name
    // 
    // PR4.00
    // P8000219A, Myers Nissi, Jack Reynolds, 24 JUN 05
    //   Replace cost flowfields by functions
    // 
    // P8000197A, Myers Nissi, Jack Reynolds, 21 SEP 05
    //   When certifying calculate production time for equipment
    // 
    // P8000259A, VerticalSoft, Jack Reynolds, 28 OCT 05
    //   Add field for production sequencing
    // 
    // PRW16.00.06
    // P8001092, Columbus IT, Don Bresee, 04 OCT 12
    //   Add function to calculate input quantity
    // 
    // P8001103, Columbus IT, Don Bresee, 04 OCT 12
    //   Add logic to use Yield % for Co/By-Product Processes
    // 
    // PRW17.00.01
    // P8001180, Columbus IT, Jack Reynolds, 10 JUL 13
    //   Fix problem resetting the UOM
    // 
    // PRW17.10.01
    // P8001258, Columbus IT, Jack Reynolds, 10 JAN 14
    //   Increase size ot text fields/variables
    // 
    // PRW19.00.01
    // P8007742, To-Increase, Dayakar Battini, 11 OCT 16
    //   ? character removed from "Include In Cost Rollup?" field
    // 
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW113.00.03
    // P80085384, To Increase, Jack Reynolds, 22 OCT 19
    //   More flexibility in UOM for CoProduct BOMs
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Production BOM Version';
    DataCaptionFields = "Production BOM No.", "Version Code", Description;
    DrillDownPageID = "Prod. BOM Version List";
    LookupPageID = "Prod. BOM Version List";

    fields
    {
        field(1; "Production BOM No."; Code[20])
        {
            Caption = 'Production BOM No.';
            NotBlank = true;
            TableRelation = "Production BOM Header";
        }
        field(2; "Version Code"; Code[20])
        {
            Caption = 'Version Code';
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(10; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
        }
        field(21; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Unit of Measure";

            trigger OnValidate()
            var
                Item: Record Item;
                ItemUnitOfMeasure: Record "Item Unit of Measure";
                UOM: Record "Unit of Measure";
            begin
                if (Status = Status::Certified) and ("Unit of Measure Code" <> xRec."Unit of Measure Code") then
                    FieldError(Status);
                Item.SetRange("Production BOM No.", "Production BOM No.");
                if Item.FindSet() then
                    repeat
                        ItemUnitOfMeasure.Get(Item."No.", "Unit of Measure Code");
                    until Item.Next() = 0;

                // P8001180
                UOM.Get("Unit of Measure Code");
                if Type = Type::Process then
                    if Format(UOM.Type) = Format("Primary UOM") then begin
                        case UOM.Type of
                            UOM.Type::Weight:
                                Validate("Weight UOM", "Unit of Measure Code");
                            UOM.Type::Volume:
                                Validate("Volume UOM", "Unit of Measure Code");
                        end;
                    end else
                        Error(Text37002000, FieldCaption("Unit of Measure Code"), "Primary UOM");
                // P8001180
            end;
        }
        field(22; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
        field(45; Status; Enum "BOM Status")
        {
            Caption = 'Status';

            trigger OnValidate()
            var
                ProdBOMHeader: Record "Production BOM Header";
                PlanningAssignment: Record "Planning Assignment";
                ProdBOMCheck: Codeunit "Production BOM-Check";
                SkipCommit: Boolean;
                ProdBomLine2: Record "Production BOM Line";
                Item: Record Item;
            begin
                if (Status <> xRec.Status) and (Status = Status::Certified) then begin
                    // PR1.00 Begin
                    ProdBOMHeader.Get("Production BOM No.");
                    if Type in [Type::Formula, Type::Process] then begin // PR1.20
                        case "Primary UOM" of
                            "Primary UOM"::Weight:
                                "Unit of Measure Code" := "Weight UOM";
                            "Primary UOM"::Volume:
                                "Unit of Measure Code" := "Volume UOM";
                        end;
                    end;
                    ProdBOMHeader."Unit of Measure Code" := "Unit of Measure Code";
                    ProdBOMHeader.Modify;
                    // PR1.00 End
                    ProdBOMCheck.ProdBOMLineCheck("Production BOM No.", "Version Code");
                    TestField("Unit of Measure Code");
                    ProdBOMHeader.Get("Production BOM No.");
                    ProdBOMHeader."Low-Level Code" := 0;
                    ProdBOMCheck.Code(ProdBOMHeader, "Version Code");
                    PlanningAssignment.NewBOM("Production BOM No.");
                    if ProdBOMHeader.IsProdFamilyBOM() then // P8001103
                        UpdateCoProdYield;                    // P8001103
                    P800BOMFns.BOMVersionUpdateLineQty(Rec); // PR3.60
                    P800BOMFns.BOMVersionUpdateABCAmount(Rec); // PR3.60
                    P800BOMFns.BOMVersionUpdateEquipmentTime(Rec) // P8000197A
                end;
                OnValidateStatusBeforeModify(Rec, xRec, CurrFieldNo);
                Modify(true);
                SkipCommit := false;
                OnValidateStatusBeforeCommit(Rec, SkipCommit);
                if not SkipCommit then
                    Commit();

                // PR1.00 Begin - must also certify/de-certify header
                ProdBOMHeader.Get("Production BOM No.");
                if Status = Status::Certified then begin
                    ProdBOMHeader.Status := ProdBOMHeader.Status::Certified;
                    P800BOMFns.BOMVersionUpdateWhereUsed(Rec); // PR3.60
                end else begin
                    ProdBOMVersion.Reset;
                    ProdBOMVersion.SetRange("Production BOM No.", "Production BOM No.");
                    ProdBOMVersion.SetRange(Status, Status::Certified);
                    if ProdBOMVersion.Find('-') then
                        ProdBOMHeader.Status := ProdBOMHeader.Status::Certified
                    else
                        ProdBOMHeader.Status := ProdBOMHeader.Status::"Under Development";
                end;
                ProdBOMHeader.Modify();
                // PR1.00 End
            end;
        }
        field(50; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(37002000; "Proper Shipping Name"; Code[10])
        {
            Caption = 'Proper Shipping Name';
            Description = 'PR3.70.03';
            TableRelation = "Proper Shipping Name";
        }
        field(37002460; Type; Option)
        {
            Caption = 'Type';
            Description = 'PR1.00';
            OptionCaption = 'BOM,Formula,Process';
            OptionMembers = BOM,Formula,Process;
        }
        field(37002461; "Weight UOM"; Code[10])
        {
            Caption = 'Weight UOM';
            Description = 'PR1.00';
            TableRelation = "Unit of Measure".Code WHERE(Type = CONST(Weight));

            trigger OnValidate()
            begin
                // PR1.00 Begin
                if Status = Status::Certified then
                    FieldError(Status);
                P800BOMFns.BOMVersionUpdateEquipmentUOM(Rec, true, false, "Weight UOM"); // PR3.60
                // PR1.00 End
            end;
        }
        field(37002462; "Volume UOM"; Code[10])
        {
            Caption = 'Volume UOM';
            Description = 'PR1.00';
            TableRelation = "Unit of Measure".Code WHERE(Type = CONST(Volume));

            trigger OnValidate()
            begin
                // PR1.00 Begin
                if Status = Status::Certified then
                    FieldError(Status);
                P800BOMFns.BOMVersionUpdateEquipmentUOM(Rec, false, true, "Volume UOM"); // PR3.60
                // PR1.00 End
            end;
        }
        field(37002463; "Yield % (Weight)"; Decimal)
        {
            Caption = 'Yield % (Weight)';
            DecimalPlaces = 0 : 5;
            Description = 'PR1.00';
            InitValue = 100;

            trigger OnValidate()
            begin
                P800BOMFns.BOMVersionUpdateLineQty(Rec); // PR3.60
            end;
        }
        field(37002464; "Yield % (Volume)"; Decimal)
        {
            Caption = 'Yield % (Volume)';
            DecimalPlaces = 0 : 5;
            Description = 'PR1.00';
            InitValue = 100;

            trigger OnValidate()
            begin
                P800BOMFns.BOMVersionUpdateLineQty(Rec); // PR3.60
            end;
        }
        field(37002465; "Primary UOM"; Option)
        {
            Caption = 'Primary UOM';
            Description = 'PR1.00';
            OptionCaption = 'Weight,Volume';
            OptionMembers = Weight,Volume;

            trigger OnValidate()
            begin
                // PR1.00 Begin
                if Status = Status::Certified then
                    FieldError(Status);
                // PR1.00 End
            end;
        }
        field(37002471; "Output Weight (Base)"; Decimal)
        {
            CalcFormula = Sum ("Production BOM Line"."Output Weight (Base)" WHERE("Production BOM No." = FIELD("Production BOM No."),
                                                                                  "Version Code" = FIELD("Version Code")));
            Caption = 'Output Weight (Base)';
            Description = 'PR1.00,PR1.10';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002472; "Output Volume (Base)"; Decimal)
        {
            CalcFormula = Sum ("Production BOM Line"."Output Volume (Base)" WHERE("Production BOM No." = FIELD("Production BOM No."),
                                                                                  "Version Code" = FIELD("Version Code")));
            Caption = 'Output Volume (Base)';
            Description = 'PR1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002478; "Input Weight (Base)"; Decimal)
        {
            CalcFormula = Sum ("Production BOM Line"."Input Weight (Base)" WHERE("Production BOM No." = FIELD("Production BOM No."),
                                                                                 "Version Code" = FIELD("Version Code")));
            Caption = 'Input Weight (Base)';
            Description = 'PR1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002479; "Input Volume (Base)"; Decimal)
        {
            CalcFormula = Sum ("Production BOM Line"."Input Volume (Base)" WHERE("Production BOM No." = FIELD("Production BOM No."),
                                                                                 "Version Code" = FIELD("Version Code")));
            Caption = 'Input Volume (Base)';
            Description = 'PR1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002480; "Production Sequence Code"; Code[10])
        {
            Caption = 'Production Sequence Code';
            TableRelation = "Production Sequence";
        }
        field(37002920; "Direct Allergen Set ID"; Integer)
        {
            Caption = 'Direct Allergen Set ID';
        }
        field(37002921; "Indirect Allergen Set ID"; Integer)
        {
            Caption = 'Indirect Allergen Set ID';
        }
        field(37002922; "Old Direct Allergen Set ID"; Integer)
        {
            Caption = 'Old Direct Allergen Set ID';
        }
    }

    keys
    {
        key(Key1; "Production BOM No.", "Version Code")
        {
            Clustered = true;
        }
        key(Key2; "Production BOM No.", "Starting Date")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ProdBOMLine: Record "Production BOM Line";
    begin
        ProdBOMLine.SetRange("Production BOM No.", "Production BOM No.");
        ProdBOMLine.SetRange("Version Code", "Version Code");
        ProdBOMLine.DeleteAll(true);

        // PR1.00 Begin
        EquipLines.Reset;
        EquipLines.SetRange("Production Bom No.", "Production BOM No.");
        EquipLines.SetRange("Version Code", "Version Code");
        EquipLines.DeleteAll;

        ABCLines.Reset;
        ABCLines.SetRange("Production Bom No.", "Production BOM No.");
        ABCLines.SetRange("Version Code", "Version Code");
        ABCLines.DeleteAll;
        // PR1.00 End
    end;

    trigger OnInsert()
    begin
        ProcessSetup.Get; // PR1.00
        ProdBOMHeader.Get("Production BOM No.");
        if "Version Code" = '' then begin
            ProdBOMHeader.TestField("Version Nos.");
            NoSeriesMgt.InitSeries(ProdBOMHeader."Version Nos.", xRec."No. Series", 0D, "Version Code", "No. Series");
        end;

        P800BOMFns.BOMVersionInitRecord(Rec); // PR3.60
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today;
    end;

    trigger OnRename()
    begin
        if Status = Status::Certified then
            Error(Text001, TableCaption, FieldCaption(Status), Format(Status));
    end;

    var
        ProdBOMHeader: Record "Production BOM Header";
        ProdBOMVersion: Record "Production BOM Version";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Text001: Label 'You cannot rename the %1 when %2 is %3.';
        ProcessSetup: Record "Process Setup";
        EquipLines: Record "Prod. BOM Equipment";
        ABCLines: Record "Prod. BOM Activity Cost";
        P800BOMFns: Codeunit "Process 800 BOM Functions";
        Text37002000: Label '%1 must be a unit of %2.';
        ProcessFns: Codeunit "Process 800 Functions";
        AllergenManagement: Codeunit "Allergen Management";

    procedure AssistEdit(OldProdBOMVersion: Record "Production BOM Version"): Boolean
    begin
        with ProdBOMVersion do begin
            ProdBOMVersion := Rec;
            ProdBOMHeader.Get("Production BOM No.");
            ProdBOMHeader.TestField("Version Nos.");
            if NoSeriesMgt.SelectSeries(ProdBOMHeader."Version Nos.", OldProdBOMVersion."No. Series", "No. Series") then begin
                NoSeriesMgt.SetSeries("Version Code");
                Rec := ProdBOMVersion;
                exit(true);
            end;
        end;
    end;

    procedure Caption(): Text
    var
        ProdBOMHeader: Record "Production BOM Header";
    begin
        if GetFilters = '' then
            exit('');

        if not ProdBOMHeader.Get("Production BOM No.") then
            exit('');

        exit(
          CopyStr(StrSubstNo('%1 %2 %3',
            "Production BOM No.", ProdBOMHeader.Description, "Version Code"), 1, 100));
    end;

    procedure BOMDescription(): Text[100]
    begin
        // PR2.00.02 Begin
        // P8001258 - increase size or Return Value to Text50
        if ProdBOMHeader.Get("Production BOM No.") then
            exit(ProdBOMHeader.Description);
        // PR2.00.02 End
    end;

    procedure MaterialCost(): Decimal
    var
        BOMLine: Record "Production BOM Line";
    begin
        // P8000219A
        BOMLine.SetRange("Production BOM No.", "Production BOM No.");
        BOMLine.SetRange("Version Code", "Version Code");
        BOMLine.CalcSums(BOMLine."Extended Cost");
        exit(BOMLine."Extended Cost");
    end;

    procedure ABCCost(EquipmentNo: Code[20]; ResourceType: Integer; IncludeInRollup: Boolean; var TotalCost: Decimal; var OverheadCost: Decimal)
    var
        BOMCost: Record "Prod. BOM Activity Cost";
    begin
        // P8000219A
        BOMCost.SetCurrentKey("Resource Type", "Include In Cost Rollup");  // P8007742
        BOMCost.SetRange("Production Bom No.", "Production BOM No.");
        BOMCost.SetRange("Version Code", "Version Code");
        BOMCost.SetRange("Equipment No.", EquipmentNo);
        if ResourceType >= 0 then
            BOMCost.SetRange("Resource Type", ResourceType);
        if IncludeInRollup then
            BOMCost.SetRange("Include In Cost Rollup", IncludeInRollup);   // P8007742
        BOMCost.CalcSums("Extended Cost", "Overhead Cost Ext");
        TotalCost := BOMCost."Extended Cost";
        OverheadCost := BOMCost."Overhead Cost Ext";
    end;

    procedure GetInputQtyBase(): Decimal
    begin
        // P8001092
        case "Primary UOM" of
            "Primary UOM"::Weight:
                begin
                    CalcFields("Input Weight (Base)");
                    exit("Input Weight (Base)");
                end;
            "Primary UOM"::Volume:
                begin
                    CalcFields("Input Volume (Base)");
                    exit("Input Volume (Base)");
                end;
        end;
    end;

    local procedure GetCoProdOutputQtyBase() OutputQty: Decimal
    var
        FamilyLine: Record "Family Line";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
    begin
        // P8001103
        FamilyLine.SetRange("Family No.", "Production BOM No.");
        if FamilyLine.FindSet then
            repeat
                OutputQty := OutputQty +
                  (FamilyLine.Quantity *
                  P800UOMFns.GetConversionToMetricBase(FamilyLine."Item No.", FamilyLine."Unit of Measure Code", 2 + "Primary UOM")); // P80085384
            until (FamilyLine.Next = 0);
    end;

    local procedure UpdateCoProdYield()
    var
        ProdBOMLine: Record "Production BOM Line";
    begin
        // P8001103
        case "Primary UOM" of
            "Primary UOM"::Weight:
                "Yield % (Weight)" := 100 * (GetCoProdOutputQtyBase() / GetInputQtyBase());
            "Primary UOM"::Volume:
                "Yield % (Volume)" := 100 * (GetCoProdOutputQtyBase() / GetInputQtyBase());
        end;
        ProdBOMLine.SetRange("Production BOM No.", "Production BOM No.");
        ProdBOMLine.SetRange("Version Code", "Version Code");
        if ProdBOMLine.FindSet then
            repeat
                case "Primary UOM" of
                    "Primary UOM"::Weight:
                        begin
                            ProdBOMLine."Yield % (Weight)" := 100;
                            ProdBOMLine."Output Weight (Base)" := ProdBOMLine."Input Weight (Base)" * ("Yield % (Weight)" / 100);
                        end;
                    "Primary UOM"::Volume:
                        begin
                            ProdBOMLine."Yield % (Volume)" := 100;
                            ProdBOMLine."Output Volume (Base)" := ProdBOMLine."Input Volume (Base)" * ("Yield % (Volume)" / 100);
                        end;
                end;
                ProdBOMLine.Modify(true);
            until (ProdBOMLine.Next = 0);
    end;

    procedure ShowAllergens()
    var
        AllergenManagement: Codeunit "Allergen Management";
    begin
        // P8006959
        if Status in [Status::New, Status::"Under Development"] then
            "Direct Allergen Set ID" := AllergenManagement.ShowAllergenSet(Rec)
        else
            AllergenManagement.ShowAllergenSet(Rec);
    end;

    procedure ShowAllergenDetail()
    var
        AllergenManagement: Codeunit "Allergen Management";
    begin
        // P8006959
        AllergenManagement.ShowAllergenDetail(Rec);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateStatusBeforeModify(var ProductionBOMVersion: Record "Production BOM Version"; var xProductionBOMVersion: Record "Production BOM Version"; CallingFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateStatusBeforeCommit(var ProductionBOMVersion: Record "Production BOM Version"; var SkipCommit: Boolean)
    begin
    end;
}

