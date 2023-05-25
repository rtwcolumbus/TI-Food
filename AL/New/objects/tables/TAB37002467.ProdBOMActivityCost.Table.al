table 37002467 "Prod. BOM Activity Cost"
{
    // PR1.00, Myers Nissi, Diane Fox, 3 NOV 00, PR010
    //   Add Version control & cost rollup.
    //   Add Resource Type field for Sum Index fields.
    // 
    // PR1.00.03
    //   Quantity - change DecimalPlaces to 0:5
    //   Change key to contain Include in Cost Rollup?
    // 
    // PR1.00.04
    //   Add key for Resource No.
    // 
    // PR3.70
    //   Add fields
    //     Quantity per
    //     Quantity (Base)
    //   Add logic for non-base units of measure
    // 
    // PR4.00
    // P8000219A, Myers Nissi, Jack Reynolds, 24 JUN 05
    //   Add resource multiplier
    //   Add fields to support linking to BOM equipment
    //   Modify keys to allow multiple records for same resource (different equipment)
    // 
    // PRW15.00.01
    // P8000556A, VerticalSoft, Jack Reynolds, 02 JAN 08
    //   Add null option values to Resource Tpye so it aligns with the Type field on the Resource table
    // 
    // P8000564A, VerticalSoft, Jack Reynolds, 08 FEB 08
    //   Change Description field to TEXT50
    // 
    // PRW17.10.02
    // P8001271, Columbus IT, Jack Reynolds, 24 JAN 14
    //   Fix missing TableRelation properties
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 08 MAR 16
    //   Expand BOM Version code to Code20
    // 
    // PRW19.00.01
    // P8007742, To-Increase, Dayakar Battini, 11 OCT 16
    //   ? character removed from "Include In Cost Rollup?" field
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Prod. BOM Activity Cost';
    DrillDownPageID = "Production Costs Subpage";
    LookupPageID = "Production Costs Subpage";

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
            TableRelation = Resource WHERE(Type = FIELD("Resource Type"));

            trigger OnValidate()
            begin
                Resource.Get("Resource No.");
                Description := Resource.Name;
                Validate("Unit of Measure", Resource."Base Unit of Measure"); // PR3.70
                //"Direct Unit Cost" := Resource."Direct Unit Cost";
                //"Unit Cost" := Resource."Unit Cost";
                "Resource Type" := Resource.Type;
            end;
        }
        field(12; "Line No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Line No.';
        }
        field(15; "Resource Type"; Option)
        {
            Caption = 'Resource Type';
            OptionCaption = 'Person,Machine,,,,,Other';
            OptionMembers = Person,Machine,,,,,Other;
        }
        field(20; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(30; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            Description = 'PR3.70';
            TableRelation = "Resource Unit of Measure".Code WHERE("Resource No." = FIELD("Resource No."),
                                                                   "Related to Base Unit of Meas." = CONST(true));

            trigger OnValidate()
            begin
                // PR3.70 Begin
                Resource.Get("Resource No.");
                ResourceUOM.Get("Resource No.", "Unit of Measure");
                "Quantity per" := ResourceUOM."Qty. per Unit of Measure";
                "Direct Unit Cost" := Round(Resource."Direct Unit Cost" * "Quantity per", 0.00001);
                "Unit Cost" := Round(Resource."Unit Cost" * "Quantity per", 0.00001);
                Validate(Quantity, Round("Quantity (Base)" / "Quantity per", 0.00001));
                // PR3.70 End
            end;
        }
        field(40; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            Description = 'PR1.00.03';

            trigger OnValidate()
            begin
                Validate("Extended Cost");
                Validate("Overhead Cost Ext");
                "Quantity (Base)" := Round(Quantity * "Quantity per", 0.00001); // PR3.70
            end;
        }
        field(41; "Resource Multiplier"; Decimal)
        {
            Caption = 'Resource Multiplier';
            DecimalPlaces = 0 : 2;
            InitValue = 1;
            MinValue = 0;

            trigger OnValidate()
            begin
                // P8000219A
                Validate("Extended Cost");
                Validate("Overhead Cost Ext");
            end;
        }
        field(45; "Direct Unit Cost"; Decimal)
        {
            Caption = 'Direct Unit Cost';

            trigger OnValidate()
            begin
                Validate("Overhead Cost Ext");
            end;
        }
        field(50; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            DecimalPlaces = 0 : 5;
            Editable = false;

            trigger OnValidate()
            begin
                Validate("Extended Cost");
                Validate("Overhead Cost Ext");
            end;
        }
        field(60; "Extended Cost"; Decimal)
        {
            Caption = 'Extended Cost';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                "Extended Cost" := Quantity * "Resource Multiplier" * "Unit Cost"; // P8000219A
            end;
        }
        field(70; "Include In Cost Rollup"; Boolean)
        {
            Caption = 'Include In Cost Rollup?';
        }
        field(80; "Equipment No."; Code[20])
        {
            Caption = 'Equipment No.';
            TableRelation = "Prod. BOM Equipment"."Resource No." WHERE("Production Bom No." = FIELD("Production Bom No."),
                                                                        "Version Code" = FIELD("Version Code"));
        }
        field(85; "Routing Link Code"; Code[10])
        {
            Caption = 'Routing Link Code';
            TableRelation = "Routing Link";

            trigger OnValidate()
            begin
                TestField("Equipment No."); // P8000219A
            end;
        }
        field(110; "Overhead Cost Ext"; Decimal)
        {
            Caption = 'Overhead Cost Ext';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                "Overhead Cost Ext" := Quantity * "Resource Multiplier" * ("Unit Cost" - "Direct Unit Cost"); // P8000219A
            end;
        }
        field(111; "Cost per"; Decimal)
        {
            Caption = 'Cost per';
            DecimalPlaces = 0 : 5;
        }
        field(112; "Quantity per"; Decimal)
        {
            Caption = 'Quantity per';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.70';
            Editable = false;
        }
        field(113; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.70';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Production Bom No.", "Version Code", "Resource No.", "Line No.")
        {
        }
        key(Key2; "Production Bom No.", "Version Code", "Equipment No.", "Routing Link Code", "Resource No.")
        {
        }
        key(Key3; "Resource Type", "Include In Cost Rollup", "Equipment No.")
        {
            SumIndexFields = "Extended Cost", "Overhead Cost Ext";
        }
        key(Key4; "Resource No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        TestStatus;
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
        ResourceUOM: Record "Resource Unit of Measure";

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
}

