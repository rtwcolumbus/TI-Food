table 99000774 "Family Line"
{
    // PRW16.00.06
    // P8001031, Columbus IT, Jack Reynolds, 31 JAN 12
    //   Fix problem with editable property of Output FastTab on Co/By-Product Card
    // 
    // P8001092, Columbus IT, Don Bresee, 17 AUG 12
    //   Add "Variant Code", "Primary Co-Product", and "Co-Product Cost Share" fields
    //   Add key for By-Product searching
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 08 MAR 16
    //   Expand BOM Version code to Code20
    // 
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    //
    // PRW118.01
    // P800128960, To Increase, Jack Reynolds, 24 AUG 21
    //   Decimal precision on alternate quantity data entry

    Caption = 'Family Line';
    DrillDownPageID = "Family Line List";
    LookupPageID = "Family Line List";

    fields
    {
        field(1; "Family No."; Code[20])
        {
            Caption = 'Family No.';
            NotBlank = true;
            TableRelation = Family;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(8; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            NotBlank = true;
            TableRelation = IF ("Process Family" = CONST(true)) Item WHERE("Item Type" = CONST(Intermediate))
            ELSE
            Item;

            trigger OnValidate()
            var
                AllergenManagement: Codeunit "Allergen Management";
            begin
                if "Item No." = '' then
                    Init
                else begin
                    if "Process Family" then                                // P8006959
                        AllergenManagement.CheckAllergenAssigned("Item No."); // P8006959
                    Item.Get("Item No.");
                    Description := Item.Description;
                    "Description 2" := Item."Description 2";
                    "Unit of Measure Code" := Item."Base Unit of Measure";
                    "Low-Level Code" := Item."Low-Level Code";
                end;

                P800ProdOrderMgmt.ValidateFamilyLine(Rec, FieldNo("Item No.")); // PR3.60
            end;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(11; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
        }
        field(12; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            begin
                P800ProdOrderMgmt.ValidateFamilyLine(Rec, FieldNo("Unit of Measure Code")); // PR3.60
            end;
        }
        field(20; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                P800ProdOrderMgmt.ValidateFamilyLine(Rec, FieldNo(Quantity)); // PR3.60
            end;
        }
        field(25; "Low-Level Code"; Integer)
        {
            Caption = 'Low-Level Code';
        }
        field(37002001; "Version Filter"; Code[20])
        {
            Caption = 'Version Filter';
            FieldClass = FlowFilter;
        }
        field(37002081; "Quantity (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            AutoFormatExpression = "Item No.";
            AutoFormatType = 37002080;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,0,0,%1', "Item No.");
            Caption = 'Quantity (Alt.)';
            Description = 'PR3.60';

            trigger OnValidate()
            begin
                P800ProdOrderMgmt.ValidateFamilyLine(Rec, FieldNo("Quantity (Alt.)")); // PR3.60
            end;
        }
        field(37002600; "By-Product"; Boolean)
        {
            Caption = 'By-Product';
            Description = 'PR3.60';

            trigger OnValidate()
            begin
                P800ProdOrderMgmt.ValidateFamilyLine(Rec, FieldNo("By-Product")); // P8001092
            end;
        }
        field(37002601; "Process Family"; Boolean)
        {
            CalcFormula = Lookup(Family."Process Family" WHERE("No." = FIELD("Family No.")));
            Caption = 'Process Family';
            Description = 'PR3.60';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002602; "Unit Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost';
            Description = 'PR3.60';

            trigger OnValidate()
            begin
                P800ProdOrderMgmt.ValidateFamilyLine(Rec, FieldNo("Unit Cost")); // PR3.60
            end;
        }
        field(37002603; "Cost Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Cost Amount';
            Description = 'PR3.60';
            Editable = false;
        }
        field(37002604; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            begin
                P800ProdOrderMgmt.ValidateFamilyLine(Rec, FieldNo("Variant Code")); // P8001092
            end;
        }
        field(37002605; "Primary Co-Product"; Boolean)
        {
            Caption = 'Primary Co-Product';

            trigger OnValidate()
            begin
                P800ProdOrderMgmt.ValidateFamilyLine(Rec, FieldNo("Primary Co-Product")); // P8001092
            end;
        }
        field(37002606; "Co-Product Cost Share"; Decimal)
        {
            BlankZero = true;
            Caption = 'Co-Product Cost Share';
            DecimalPlaces = 0 : 5;
            InitValue = 1;
            MinValue = 0;

            trigger OnValidate()
            begin
                P800ProdOrderMgmt.ValidateFamilyLine(Rec, FieldNo("Co-Product Cost Share")); // P8001092
            end;
        }
    }

    keys
    {
        key(Key1; "Family No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Low-Level Code")
        {
        }
        key(Key3; "Item No.", "By-Product", "Variant Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Item: Record Item;
        P800ProdOrderMgmt: Codeunit "Process 800 Prod. Order Mgt.";

    procedure FindOutputItem(ProdBOMNo: Code[20]; ItemNo: Code[20]): Boolean
    begin
        // P8001092
        Reset;
        SetRange("Family No.", ProdBOMNo);
        SetRange("Item No.", ItemNo);
        SetFilter(Quantity, '<>0');
        exit(FindFirst);
    end;

    procedure IsPrimaryCoProduct(): Boolean
    begin
        // P8001092
        if not "By-Product" then begin
            if "Primary Co-Product" then
                exit(true);
            exit(IsOnlyCoProduct());
        end;
    end;

    procedure IsOnlyCoProduct(): Boolean
    var
        FamilyLine2: Record "Family Line";
    begin
        // P8001092
        FamilyLine2.SetRange("Family No.", "Family No.");
        FamilyLine2.SetFilter("Item No.", '<>%1', "Item No.");
        FamilyLine2.SetFilter(Quantity, '<>0');
        FamilyLine2.SetRange("By-Product", false);
        exit(FamilyLine2.IsEmpty);
    end;
}

