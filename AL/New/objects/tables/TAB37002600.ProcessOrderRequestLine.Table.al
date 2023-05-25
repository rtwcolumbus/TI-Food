table 37002600 "Process Order Request Line"
{
    // PRW16.00.06
    // P8001092, Columbus IT, Don Bresee, 11 SEP 12
    //   Add Location Code, Variant Code, Finished Variant Code, add fields to the primary key
    // 
    // PRW17.10.01
    // P8001258, Columbus IT, Jack Reynolds, 10 JAN 14
    //   Increase size ot text fields/variables
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Process Order Request Line';

    fields
    {
        field(1; "Form Type"; Option)
        {
            Caption = 'Form Type';
            Editable = false;
            OptionCaption = 'Supply,Demand';
            OptionMembers = Supply,Demand;
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Editable = false;
            TableRelation = Item;
        }
        field(3; "Process BOM No."; Code[20])
        {
            Caption = 'Process BOM No.';
            Editable = false;
            NotBlank = true;
            TableRelation = "Production BOM Header" WHERE("Mfg. BOM Type" = CONST(Process));
        }
        field(4; "Process BOM Line No."; Integer)
        {
            Caption = 'Process BOM Line No.';
            Editable = false;
            TableRelation = "Production BOM Line"."Line No." WHERE("Production BOM No." = FIELD("Process BOM No."));
        }
        field(5; "Output Family Line No."; Integer)
        {
            Caption = 'Output Family Line No.';
            Editable = false;
        }
        field(6; "Package BOM No."; Code[20])
        {
            Caption = 'Package BOM No.';
            Editable = false;
            TableRelation = "Production BOM Header" WHERE("Mfg. BOM Type" = CONST(BOM));
        }
        field(7; "Package BOM Line No."; Integer)
        {
            Caption = 'Package BOM Line No.';
            Editable = false;
            TableRelation = "Production BOM Line"."Line No." WHERE("Production BOM No." = FIELD("Package BOM No."));
        }
        field(8; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            NotBlank = true;

            trigger OnValidate()
            begin
                "Finished Quantity" := GetPackageQuantity(); // P8001092
            end;
        }
        field(9; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            Editable = false;
            TableRelation = IF ("Package BOM No." = FILTER('')) "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."))
            ELSE
            "Item Unit of Measure".Code WHERE("Item No." = FIELD("Package Item No."));
        }
        field(10; "Package Item No."; Code[20])
        {
            CalcFormula = Lookup ("Family Line"."Item No." WHERE("Family No." = FIELD("Process BOM No."),
                                                                 "Line No." = FIELD("Output Family Line No.")));
            Caption = 'Package Item No.';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = Item;
        }
        field(11; "Process BOM Description"; Text[100])
        {
            CalcFormula = Lookup ("Production BOM Header".Description WHERE("No." = FIELD("Process BOM No.")));
            Caption = 'Process BOM Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(12; "Finished Item Description"; Text[100])
        {
            CalcFormula = Lookup (Item.Description WHERE("No." = FIELD("Finished Item No.")));
            Caption = 'Finished Item Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(13; "Item Description"; Text[100])
        {
            CalcFormula = Lookup (Item.Description WHERE("No." = FIELD("Item No.")));
            Caption = 'Item Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; "Package Item Description"; Text[100])
        {
            CalcFormula = Lookup (Item.Description WHERE("No." = FIELD("Package Item No.")));
            Caption = 'Package Item Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "Finished Item No."; Code[20])
        {
            Caption = 'Finished Item No.';
            Editable = false;
            TableRelation = Item;
        }
        field(16; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            Editable = false;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(17; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            Editable = false;
            TableRelation = Location;
        }
        field(18; "Finished Variant Code"; Code[10])
        {
            Caption = 'Finished Variant Code';
            Editable = false;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Finished Item No."));
        }
        field(19; "Finished Quantity"; Decimal)
        {
            Caption = 'Finished Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(20; "Total Finished Quantity"; Decimal)
        {
            CalcFormula = Sum ("Process Order Request Line"."Finished Quantity" WHERE("Finished Item No." = FIELD("Finished Item No."),
                                                                                      "Finished Variant Code" = FIELD("Finished Variant Code")));
            Caption = 'Total Finished Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Form Type", "Item No.", "Variant Code", "Location Code", "Process BOM No.", "Process BOM Line No.", "Output Family Line No.", "Package BOM No.", "Package BOM Line No.", "Finished Item No.", "Finished Variant Code")
        {
            SumIndexFields = Quantity;
        }
        key(Key2; "Package BOM No.", "Finished Item No.", "Finished Variant Code")
        {
        }
        key(Key3; "Finished Item No.", "Finished Variant Code")
        {
            SumIndexFields = "Finished Quantity";
        }
    }

    fieldgroups
    {
    }

    var
        VersionMgmt: Codeunit VersionManagement;

    procedure GetPackageQuantity(): Decimal
    var
        ProdBOMLine: Record "Production BOM Line";
    begin
        if ("Package BOM No." <> '') then
            if ProdBOMLine.Get("Package BOM No.",
                               VersionMgmt.GetBOMVersion("Package BOM No.", WorkDate, true),
                               "Package BOM Line No.")
            then
                exit(ProdBOMLine.GetPackageOutputQty("Unit of Measure Code", Quantity));
        exit(0);
    end;

    procedure GetPackageUnits(): Code[10]
    var
        ProdBOMHeader: Record "Production BOM Header";
    begin
        if ("Package BOM No." <> '') then
            if ProdBOMHeader.Get("Package BOM No.") then
                exit(ProdBOMHeader."Unit of Measure Code");
        exit('');
    end;
}

