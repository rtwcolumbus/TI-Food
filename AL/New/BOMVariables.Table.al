table 37002469 "BOM Variables"
{
    // PR1.00.02
    //   Yields must be positive
    // 
    // PR1.00.03
    //   IncludeInRollup
    //   InitRecord - use IncludeInRollup when calculating cost fields
    // 
    // PR1.20
    //   Add Process to Type OptionString
    // 
    // PR1.20.01
    //   Rename fields
    // 
    // PR4.00
    // P8000219A, Myers Nissi, Jack Reynolds, 24 JUN 05
    //   Add support for calculating cost based on the costing equipment
    // 
    // PR4.00.05
    // P8000414B, VerticalSoft, Jack Reynolds, 15 NOV 06
    //   Correct spelling error in text constant
    // 
    // PRW15.00.01
    // P8000556A, VerticalSoft, Jack Reynolds, 07 FEB 08
    //   Fix problem calculating other ABC costs
    // 
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'BOM Variables';
    ReplicateData = false;

    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
            Description = 'PR1.20';
            OptionCaption = 'BOM,Formula,Process';
            OptionMembers = BOM,Formula,Process;
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = SystemMetadata;
        }
        field(3; "Version Code"; Code[20])
        {
            Caption = 'Version Code';
            DataClassification = SystemMetadata;
        }
        field(4; "Active Version Code"; Code[20])
        {
            Caption = 'Active Version Code';
            DataClassification = SystemMetadata;
        }
        field(5; Status; Option)
        {
            Caption = 'Status';
            DataClassification = SystemMetadata;
            OptionCaption = 'New,Certified,Under Development,Closed';
            OptionMembers = New,Certified,"Under Development",Closed;
        }
        field(6; Recalc; Boolean)
        {
            Caption = 'Resized';
            DataClassification = SystemMetadata;
        }
        field(7; Hold; Option)
        {
            Caption = 'Hold';
            DataClassification = SystemMetadata;
            OptionCaption = ' ,Weight,Volume,Density';
            OptionMembers = " ",Weight,Volume,Density;
        }
        field(8; "Include In Rollup"; Boolean)
        {
            Caption = 'Include In Rollup';
            DataClassification = SystemMetadata;
            Description = 'PR1.00.03';
        }
        field(9; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = SystemMetadata;
            Description = 'PR1.00.03';
        }
        field(10; "Costing Equipment"; Code[20])
        {
            Caption = 'Costing Equipment';
            DataClassification = SystemMetadata;
        }
        field(101; "Primary UOM"; Option)
        {
            Caption = 'Primary UOM';
            DataClassification = SystemMetadata;
            OptionCaption = 'Weight,Volume';
            OptionMembers = Weight,Volume;
        }
        field(102; "Weight UOM"; Code[10])
        {
            Caption = 'Weight UOM';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if "Weight UOM" <> xRec."Weight UOM" then begin
                    if not UOM.Get("Weight UOM") then begin
                        Clear(UOM);
                        Validate("Weight Factor (From Base)", 0);
                    end else
                        Validate("Weight Factor (From Base)", 1 / P800UOMFns.UOMtoMetricBase("Weight UOM"));
                    Validate("Weight Text", UOM.Description);
                end;
            end;
        }
        field(103; "Volume UOM"; Code[10])
        {
            Caption = 'Volume UOM';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if "Volume UOM" <> xRec."Volume UOM" then begin
                    if not UOM.Get("Volume UOM") then begin
                        Clear(UOM);
                        Validate("Volume Factor (From Base)", 0);
                    end else
                        Validate("Volume Factor (From Base)", 1 / P800UOMFns.UOMtoMetricBase("Volume UOM"));
                    Validate("Volume Text", UOM.Description);
                end;
            end;
        }
        field(104; "Weight Yield"; Decimal)
        {
            Caption = 'Weight Yield';
            DataClassification = SystemMetadata;
            Description = 'PR1.00.02';

            trigger OnValidate()
            begin
                if "Weight Yield" <= 0 then // PR1.00.02
                    Error(Text000); // PR1.00.02

                case Hold of
                    Hold::Volume:
                        begin
                            "Output Weight" := "Output Weight (Before Yield)" * "Weight Yield" / 100;
                            if "Output Volume" <> 0 then
                                Density := "Output Weight" / "Output Volume"
                            else
                                Density := 0;
                        end;

                    Hold::Density:
                        begin
                            "Output Weight" := "Output Weight (Before Yield)" * "Weight Yield" / 100;
                            if Density <> 0 then
                                "Output Volume" := "Output Weight" / Density;
                            "Volume Yield" := 100 * "Output Volume" / "Output Volume (Before Yield)";
                        end;
                end;
            end;
        }
        field(105; "Volume Yield"; Decimal)
        {
            Caption = 'Volume Yield';
            DataClassification = SystemMetadata;
            Description = 'PR1.00.02';

            trigger OnValidate()
            begin
                if "Volume Yield" <= 0 then // PR1.00.02
                    Error(Text000); // PR1.00.02

                case Hold of
                    Hold::Weight:
                        begin
                            "Output Volume" := "Output Volume (Before Yield)" * "Volume Yield" / 100;
                            if "Output Volume" <> 0 then
                                Density := "Output Weight" / "Output Volume"
                            else
                                Density := 0;
                        end;

                    Hold::Density:
                        begin
                            "Output Volume" := "Output Volume (Before Yield)" * "Volume Yield" / 100;
                            "Output Weight" := "Output Volume" * Density;
                            "Weight Yield" := 100 * "Output Weight" / "Output Weight (Before Yield)";
                        end;
                end;
            end;
        }
        field(106; "Weight Factor (From Base)"; Decimal)
        {
            Caption = 'Weight Factor (From Base)';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                Validate("Output Weight", "Output Weight (Base)" * "Weight Factor (From Base)");
                Validate("Input Weight", "Input Weight (Base)" * "Weight Factor (From Base)");
                if ("Active Version Weight (Base)" <> 0) and ("Weight Factor (From Base)" <> 0) then
                    "Act Ver Cost (per Weight UOM)" := "Active Version Cost" / ("Active Version Weight (Base)" * "Weight Factor (From Base)");
            end;
        }
        field(107; "Volume Factor (From Base)"; Decimal)
        {
            Caption = 'Volume Factor (From Base)';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                Validate("Output Volume", "Output Volume (Base)" * "Volume Factor (From Base)");
                Validate("Input Volume", "Input Volume (Base)" * "Volume Factor (From Base)");
                if ("Active Version Volume (Base)" <> 0) and ("Volume Factor (From Base)" <> 0) then
                    "Act Ver Cost (per Volume UOM)" := "Active Version Cost" / ("Active Version Volume (Base)" * "Volume Factor (From Base)");
            end;
        }
        field(201; "Output Weight (Base)"; Decimal)
        {
            Caption = 'Output Weight (Base)';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                Validate("Output Weight", "Output Weight (Base)" * "Weight Factor (From Base)");
            end;
        }
        field(202; "Output Volume (Base)"; Decimal)
        {
            Caption = 'Output Volume (Base)';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                Validate("Output Volume", "Output Volume (Base)" * "Volume Factor (From Base)");
            end;
        }
        field(203; "Output Weight"; Decimal)
        {
            Caption = 'Output Weight';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                case Hold of
                    Hold::" ":
                        begin
                            if "Output Volume" <> 0 then
                                Density := "Output Weight" / "Output Volume"
                            else
                                Density := 0;
                        end;

                    Hold::Volume:
                        begin
                            "Weight Yield" := 100 * "Output Weight" / "Output Weight (Before Yield)";
                            if "Output Volume" <> 0 then
                                Density := "Output Weight" / "Output Volume"
                            else
                                Density := 0;
                        end;

                    Hold::Density:
                        begin
                            "Weight Yield" := 100 * "Output Weight" / "Output Weight (Before Yield)";
                            if Density <> 0 then
                                "Output Volume" := "Output Weight" / Density;
                            "Volume Yield" := 100 * "Output Volume" / "Output Volume (Before Yield)";
                        end;
                end;

                if "Output Weight" <> 0 then begin
                    "Material Cost (per Weight UOM)" := "Material Cost" / "Output Weight";
                    "Labor Cost (per Weight UOM)" := "Labor Cost" / "Output Weight";
                    "Machine Cost (per Weight UOM)" := "Machine Cost" / "Output Weight";
                    "Other Cost (per Weight UOM)" := "Other Cost" / "Output Weight";
                    "Overhead Cost (per Weight UOM)" := "Overhead Cost" / "Output Weight";
                    Validate("Total Cost (per Weight UOM)");
                end else begin
                    "Material Cost (per Weight UOM)" := 0;
                    "Labor Cost (per Weight UOM)" := 0;
                    "Machine Cost (per Weight UOM)" := 0;
                    "Other Cost (per Weight UOM)" := 0;
                    "Overhead Cost (per Weight UOM)" := 0;
                    Validate("Total Cost (per Weight UOM)");
                end;
            end;
        }
        field(204; "Output Volume"; Decimal)
        {
            Caption = 'Output Volume';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                case Hold of
                    Hold::" ":
                        begin
                            if "Output Volume" <> 0 then
                                Density := "Output Weight" / "Output Volume"
                            else
                                Density := 0;
                        end;

                    Hold::Weight:
                        begin
                            "Volume Yield" := 100 * "Output Volume" / "Output Volume (Before Yield)";
                            if "Output Volume" <> 0 then
                                Density := "Output Weight" / "Output Volume"
                            else
                                Density := 0;
                        end;

                    Hold::Density:
                        begin
                            "Volume Yield" := 100 * "Output Volume" / "Output Volume (Before Yield)";
                            "Output Weight" := "Output Volume" * Density;
                            "Weight Yield" := 100 * "Output Weight" / "Output Weight (Before Yield)";
                        end;
                end;

                if "Output Volume" <> 0 then begin
                    "Material Cost (per Volume UOM)" := "Material Cost" / "Output Volume";
                    "Labor Cost (per Volume UOM)" := "Labor Cost" / "Output Volume";
                    "Machine Cost (per Volume UOM)" := "Machine Cost" / "Output Volume";
                    "Other Cost (per Volume UOM)" := "Other Cost" / "Output Volume";
                    "Overhead Cost (per Volume UOM)" := "Overhead Cost" / "Output Volume";
                    Validate("Total Cost (per volume UOM)");
                end else begin
                    "Material Cost (per Volume UOM)" := 0;
                    "Labor Cost (per Volume UOM)" := 0;
                    "Machine Cost (per Volume UOM)" := 0;
                    "Other Cost (per Volume UOM)" := 0;
                    "Overhead Cost (per Volume UOM)" := 0;
                    Validate("Total Cost (per volume UOM)");
                end;
            end;
        }
        field(205; Density; Decimal)
        {
            Caption = 'Density';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                case Hold of
                    Hold::Weight:
                        begin
                            "Output Volume" := "Output Weight" / Density;
                            "Volume Yield" := 100 * "Output Volume" / "Output Volume (Before Yield)";
                        end;

                    Hold::Volume:
                        begin
                            "Output Weight" := "Output Volume" * Density;
                            "Weight Yield" := 100 * "Output Weight" / "Output Weight (Before Yield)";
                        end;
                end;
            end;
        }
        field(206; "Weight Text"; Text[10])
        {
            Caption = 'Weight Text';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                "Density Text" := "Weight Text" + '/' + "Volume Text";
            end;
        }
        field(207; "Volume Text"; Text[10])
        {
            Caption = 'Volume Text';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                "Density Text" := "Weight Text" + '/' + "Volume Text";
            end;
        }
        field(208; "Density Text"; Text[21])
        {
            Caption = 'Density Text';
            DataClassification = SystemMetadata;
        }
        field(209; "Active Version Weight (Base)"; Decimal)
        {
            Caption = 'Active Version Weight (Base)';
            DataClassification = SystemMetadata;
        }
        field(210; "Active Version Volume (Base)"; Decimal)
        {
            Caption = 'Active Version Volume (Base)';
            DataClassification = SystemMetadata;
        }
        field(211; "Output Weight (Before Yield)"; Decimal)
        {
            Caption = 'Output Weight (Before Yield)';
            DataClassification = SystemMetadata;
        }
        field(212; "Output Volume (Before Yield)"; Decimal)
        {
            Caption = 'Output Volume (Before Yield)';
            DataClassification = SystemMetadata;
        }
        field(213; "Input Weight (Base)"; Decimal)
        {
            Caption = 'Input Weight (Base)';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                Validate("Input Weight", "Input Weight (Base)" * "Weight Factor (From Base)");
            end;
        }
        field(214; "Input Volume (Base)"; Decimal)
        {
            Caption = 'Input Volume (Base)';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                Validate("Input Volume", "Input Volume (Base)" * "Volume Factor (From Base)");
            end;
        }
        field(215; "Input Weight"; Decimal)
        {
            Caption = 'Input Weight';
            DataClassification = SystemMetadata;
        }
        field(216; "Input Volume"; Decimal)
        {
            Caption = 'Input Volume';
            DataClassification = SystemMetadata;
        }
        field(301; "Material Cost"; Decimal)
        {
            Caption = 'Material Cost';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if "Output Weight" <> 0 then
                    "Material Cost (per Weight UOM)" := "Material Cost" / "Output Weight";
                if "Output Volume" <> 0 then
                    "Material Cost (per Volume UOM)" := "Material Cost" / "Output Volume";
                Validate("Total Cost");
            end;
        }
        field(302; "Labor Cost"; Decimal)
        {
            Caption = 'Labor Cost';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if "Output Weight" <> 0 then
                    "Labor Cost (per Weight UOM)" := "Labor Cost" / "Output Weight";
                if "Output Volume" <> 0 then
                    "Labor Cost (per Volume UOM)" := "Labor Cost" / "Output Volume";
                Validate("Total Cost");
            end;
        }
        field(303; "Machine Cost"; Decimal)
        {
            Caption = 'Machine Cost';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if "Output Weight" <> 0 then
                    "Machine Cost (per Weight UOM)" := "Machine Cost" / "Output Weight";
                if "Output Volume" <> 0 then
                    "Machine Cost (per Volume UOM)" := "Machine Cost" / "Output Volume";
                Validate("Total Cost");
            end;
        }
        field(304; "Other Cost"; Decimal)
        {
            Caption = 'Other Cost';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if "Output Weight" <> 0 then
                    "Other Cost (per Weight UOM)" := "Other Cost" / "Output Weight";
                if "Output Volume" <> 0 then
                    "Other Cost (per Volume UOM)" := "Other Cost" / "Output Volume";
                Validate("Total Cost");
            end;
        }
        field(305; "Overhead Cost"; Decimal)
        {
            Caption = 'Overhead Cost';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if "Output Weight" <> 0 then
                    "Overhead Cost (per Weight UOM)" := "Overhead Cost" / "Output Weight";
                if "Output Volume" <> 0 then
                    "Overhead Cost (per Volume UOM)" := "Overhead Cost" / "Output Volume";
                Validate("Total Cost");
            end;
        }
        field(306; "Total Cost"; Decimal)
        {
            Caption = 'Total Cost';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                "Total Cost" := "Material Cost" + "Labor Cost" + "Machine Cost" + "Other Cost" + "Overhead Cost";
                if "Output Weight" <> 0 then
                    "Total Cost (per Weight UOM)" := "Total Cost" / "Output Weight";
                if "Output Volume" <> 0 then
                    "Total Cost (per volume UOM)" := "Total Cost" / "Output Volume";
            end;
        }
        field(307; "Active Version Cost"; Decimal)
        {
            Caption = 'Active Version Cost';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if "Active Version Cost" >= 0 then begin
                    if ("Active Version Weight (Base)" <> 0) and ("Weight Factor (From Base)" <> 0) then
                        "Act Ver Cost (per Weight UOM)" := "Active Version Cost" / ("Active Version Weight (Base)" * "Weight Factor (From Base)");
                    if ("Active Version Volume (Base)" <> 0) and ("Volume Factor (From Base)" <> 0) then
                        "Act Ver Cost (per Volume UOM)" := "Active Version Cost" / ("Active Version Volume (Base)" * "Volume Factor (From Base)");
                end else begin
                    "Act Ver Cost (per Weight UOM)" := -1;
                    "Act Ver Cost (per Volume UOM)" := -1;
                end;
            end;
        }
        field(311; "Material Cost (per Weight UOM)"; Decimal)
        {
            Caption = 'Material Cost (per Weight UOM)';
            DataClassification = SystemMetadata;
        }
        field(312; "Labor Cost (per Weight UOM)"; Decimal)
        {
            Caption = 'Labor Cost (per Weight UOM)';
            DataClassification = SystemMetadata;
        }
        field(313; "Machine Cost (per Weight UOM)"; Decimal)
        {
            Caption = 'Machine Cost (per Weight UOM)';
            DataClassification = SystemMetadata;
        }
        field(314; "Other Cost (per Weight UOM)"; Decimal)
        {
            Caption = 'Other Cost (per Weight UOM)';
            DataClassification = SystemMetadata;
        }
        field(315; "Overhead Cost (per Weight UOM)"; Decimal)
        {
            Caption = 'Overhead Cost (per Weight UOM)';
            DataClassification = SystemMetadata;
        }
        field(316; "Total Cost (per Weight UOM)"; Decimal)
        {
            Caption = 'Total Cost (per Weight UOM)';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                "Total Cost (per Weight UOM)" := "Material Cost (per Weight UOM)" + "Labor Cost (per Weight UOM)" +
                "Machine Cost (per Weight UOM)"
                 +
                  "Other Cost (per Weight UOM)" + "Overhead Cost (per Weight UOM)";
            end;
        }
        field(317; "Act Ver Cost (per Weight UOM)"; Decimal)
        {
            Caption = 'Act Ver Cost (per Weight UOM)';
            DataClassification = SystemMetadata;
        }
        field(321; "Material Cost (per Volume UOM)"; Decimal)
        {
            Caption = 'Material Cost (per Volume UOM)';
            DataClassification = SystemMetadata;
        }
        field(322; "Labor Cost (per Volume UOM)"; Decimal)
        {
            Caption = 'Labor Cost (per Volume UOM)';
            DataClassification = SystemMetadata;
        }
        field(323; "Machine Cost (per Volume UOM)"; Decimal)
        {
            Caption = 'Machine Cost (per Volume UOM)';
            DataClassification = SystemMetadata;
        }
        field(324; "Other Cost (per Volume UOM)"; Decimal)
        {
            Caption = 'Other Cost (per Volume UOM)';
            DataClassification = SystemMetadata;
        }
        field(325; "Overhead Cost (per Volume UOM)"; Decimal)
        {
            Caption = 'Overhead Cost (per Volume UOM)';
            DataClassification = SystemMetadata;
        }
        field(326; "Total Cost (per volume UOM)"; Decimal)
        {
            Caption = 'Total Cost (per volume UOM)';
            DataClassification = SystemMetadata;

            trigger OnLookup()
            begin
                "Total Cost (per volume UOM)" := "Material Cost (per Volume UOM)" + "Labor Cost (per Volume UOM)" +
                "Machine Cost (per Volume UOM)"
                 +
                  "Other Cost (per Volume UOM)" + "Overhead Cost (per Volume UOM)";
            end;
        }
        field(327; "Act Ver Cost (per Volume UOM)"; Decimal)
        {
            Caption = 'Act Ver Cost (per Volume UOM)';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; Type, "No.", "Version Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        UOM: Record "Unit of Measure";
        Version: Record "Production BOM Version";
        Line: Record "Production BOM Line";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
        Text000: Label 'Yield must be positive.';
        P800BOMFns: Codeunit "Process 800 BOM Functions";

    procedure ClearVersion()
    var
        BOMVars: Record "BOM Variables";
    begin
        Clear(BOMVars);
        BOMVars.Type := Type;
        BOMVars."No." := "No.";
        BOMVars."Active Version Code" := "Active Version Code";
        Rec := BOMVars;
    end;

    procedure InitRecord()
    begin
        Hold := 0;
        if Version.Get("No.", "Version Code") then begin
            Status := Version.Status;
            "Unit of Measure Code" := Version."Unit of Measure Code"; // PR1.00.03
            Validate("Primary UOM", Version."Primary UOM");
            Validate("Weight UOM", Version."Weight UOM");
            Validate("Volume UOM", Version."Volume UOM");
            Validate("Weight Yield", Version."Yield % (Weight)");
            Validate("Volume Yield", Version."Yield % (Volume)");
            "Costing Equipment" := P800BOMFns.GetCostingEquipment("No.", "Version Code", ''); // P8000219A, P8001030

            Version.CalcFields("Output Weight (Base)", "Output Volume (Base)",
              "Input Weight (Base)", "Input Volume (Base)");
            Validate("Output Weight (Base)", Version."Output Weight (Base)");
            Validate("Output Volume (Base)", Version."Output Volume (Base)");
            Validate("Input Weight (Base)", Version."Input Weight (Base)");
            Validate("Input Volume (Base)", Version."Input Volume (Base)");

            CalcCosts; // P8000219A
            CalcActiveVersion;
        end;
    end;

    procedure Resize(factor: Decimal)
    var
        BOMLines: Record "Production BOM Line";
    begin
        if factor <> 1 then begin
            BOMLines.SetRange("Production BOM No.", "No.");
            BOMLines.SetRange("Version Code", "Version Code");
            if BOMLines.Find('-') then
                repeat
                    BOMLines.Validate("Batch Quantity", BOMLines."Batch Quantity" * factor);
                    BOMLines.Modify;
                until BOMLines.Next = 0;

            InitRecord;
            Recalc := true;
        end;
    end;

    procedure UpdateCostingEquipment(Operation: Code[10]; RecordRef: RecordRef)
    var
        BOMEquip: Record "Prod. BOM Equipment";
        BOMCost: Record "Prod. BOM Activity Cost";
        BOMCost2: Record "Prod. BOM Activity Cost";
    begin
        case RecordRef.Number of
            DATABASE::"Prod. BOM Equipment":
                if "Costing Equipment" = '' then
                    // IF costing equipment is blank then it's because there are no cost records that are equipment
                    // specific and nothing we do to change the equipment records will change that
                    exit
                else begin
                    RecordRef.SetTable(BOMEquip);
                    case Operation of
                        'INSERT':
                            Recalc := true; // costing equipment may change depending on preference
                        'MODIFY':
                            Recalc := true; // costing equipment may change depending on preference
                        'DELETE':
                            Recalc := "Costing Equipment" = BOMEquip."Resource No.";
                    end;
                end;

            DATABASE::"Prod. BOM Activity Cost":
                begin
                    RecordRef.SetTable(BOMCost);
                    if "Costing Equipment" = '' then begin
                        if (Operation in ['INSERT', 'MODIFY']) and
                          (BOMCost."Equipment No." <> '')
                        then begin
                            P800BOMFns.GetPreferredEquipment("No.", "Version Code", '', BOMEquip); // P8001030
                            "Costing Equipment" := BOMEquip."Resource No.";
                            CalcCosts;
                            Recalc := true;
                        end;
                    end else begin
                        if Operation = 'INSERT' then
                            exit;
                        BOMCost2 := BOMCost;
                        BOMCost2.Find;
                        if BOMCost2."Equipment No." <> '' then begin
                            if (Operation = 'DELETE') or
                              ((Operation = 'MODIFY') and (BOMCost."Equipment No." = ''))
                            then begin
                                BOMCost2.Reset;
                                BOMCost2.SetRange("Production Bom No.", BOMCost."Production Bom No.");
                                BOMCost2.SetRange("Version Code", BOMCost."Version Code");
                                BOMCost2.SetFilter("Line No.", '<>%1', BOMCost."Line No.");
                                BOMCost2.SetFilter("Equipment No.", '<>%1', '');
                                if not BOMCost2.Find('-') then begin
                                    "Costing Equipment" := '';
                                    CalcCosts;
                                    Recalc := true;
                                end;
                            end;
                        end;
                    end;
                end;
        end;
    end;

    procedure SetPercents(LineToSkip: Integer)
    var
        BOMLines: Record "Production BOM Line";
        factor: Decimal;
    begin
        case "Primary UOM" of
            "Primary UOM"::Weight:
                factor := "Output Weight (Base)";
            "Primary UOM"::Volume:
                factor := "Output Volume (Base)";
        end;
        if factor <> 0 then
            factor := 100 / factor;

        BOMLines.SetRange("Production BOM No.", "No.");
        BOMLines.SetRange("Version Code", "Version Code");
        BOMLines.SetFilter("Line No.", '<>%1', LineToSkip);
        if BOMLines.Find('-') then
            repeat
                case "Primary UOM" of
                    "Primary UOM"::Weight:
                        BOMLines."% of Total" := BOMLines."Output Weight (Base)" * factor;
                    "Primary UOM"::Volume:
                        BOMLines."% of Total" := BOMLines."Output Volume (Base)" * factor;
                end;
                BOMLines.Modify;
            until BOMLines.Next = 0;
    end;

    procedure CalcCosts()
    var
        TotalCost: Decimal;
        OverheadCost: Decimal;
    begin
        // P8000219A Begin
        if Version."Production BOM No." = '' then
            if not Version.Get("No.", "Version Code") then
                exit;

        Validate("Material Cost", Version.MaterialCost);
        Version.ABCCost("Costing Equipment", 0, "Include In Rollup", TotalCost, OverheadCost);
        Validate("Labor Cost", TotalCost - OverheadCost);
        "Overhead Cost" := OverheadCost;
        Version.ABCCost("Costing Equipment", 1, "Include In Rollup", TotalCost, OverheadCost);
        Validate("Machine Cost", TotalCost - OverheadCost);
        "Overhead Cost" += OverheadCost;
        Version.ABCCost("Costing Equipment", 6, "Include In Rollup", TotalCost, OverheadCost); // P8000556
        Validate("Other Cost", TotalCost - OverheadCost);
        "Overhead Cost" += OverheadCost;
        Validate("Overhead Cost");
        // P8000219A End
    end;

    procedure CalcActiveVersion()
    var
        TotalCost: Decimal;
        OverheadCost: Decimal;
    begin
        if "Active Version Code" <> '' then begin
            Version.Reset;
            Version.Get("No.", "Active Version Code");
            Version.CalcFields("Output Weight (Base)", "Output Volume (Base)");           // P8000219A
                                                                                          //  "Total Cost (Material)","Total Cost (ABC)");                             // P8000219A
            "Active Version Weight (Base)" := Version."Output Weight (Base)";
            "Active Version Volume (Base)" := Version."Output Volume (Base)";
            Version.ABCCost(P800BOMFns.GetCostingEquipment("No.", "Active Version Code", ''), // P8000219A, P8001030
              -1, "Include In Rollup", TotalCost, OverheadCost);                            // P8000219A
            Validate("Active Version Cost", Version.MaterialCost + TotalCost);            // P8000219A
        end else
            Validate("Active Version Cost", -1); // Will display as blank if no active version
    end;
}

