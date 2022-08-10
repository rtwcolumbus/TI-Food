table 37002466 "Unappr. Item Unit of Measure"
{
    // PR1.00, Myers Nissi, Jack Reynolds, 30 JUL 00, PR007
    //   Field 1 - Unapproved Item No. - Code 20 - relate to Unapproved
    //     Item
    //   Field 2 - Code - Code 10 - relate to Unit of Measure
    //   Field 3 - Qty. per Unit of Measure - Decimal
    //   Field 4 - Type - Option (,Length,Weight,Volume) - FlowField (lookup
    //     type in Unit of Measure table)
    //   Primary Key - Unapproved Item No., Code
    //   LookupFormID - Unappr Item Units of Measure
    // 
    // PR2.00
    //   Text constants
    // 
    // PR3.60
    //   Update Unapproved Item Specific Gravity on changes to unapproved item unit of measure
    // 
    // PRW16.00
    // P8000639, VerticalSoft, Jack Reynolds, 18 NOV 08
    //   Add DropDown field group

    Caption = 'Unappr. Item Unit of Measure';
    LookupPageID = "Unappr Item Units of Measure";

    fields
    {
        field(1; "Unapproved Item No."; Code[20])
        {
            Caption = 'Unapproved Item No.';
            NotBlank = true;
            TableRelation = "Unapproved Item";
        }
        field(2; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
            TableRelation = "Unit of Measure";

            trigger OnValidate()
            begin
                CalcFields(Type);
                if Type <> 0 then begin
                    UnapprItemUOM.Reset;
                    UnapprItemUOM.SetRange("Unapproved Item No.", "Unapproved Item No.");
                    UnapprItemUOM.SetFilter(Code, '<>%1', Code);
                    UnapprItemUOM.SetRange(Type, Type);
                    if UnapprItemUOM.Find('-') then
                        "Qty. per Unit of Measure" := P800UOMFns.ConvertUOM(UnapprItemUOM."Qty. per Unit of Measure",
                          Code, UnapprItemUOM.Code)
                    else begin
                        // If we know the specific gravity, the type is weight or valume, and we have
                        // a unit of measure of the other type then we can still figure out the
                        // Qty. per Unit of Measure
                        UnapprItem.Get("Unapproved Item No.");
                        if (UnapprItem."Specific Gravity" <> 0) and (Type in [Type::Weight, Type::Volume]) then begin
                            UnapprItemUOM.SetRange("Unapproved Item No.", "Unapproved Item No.");
                            if Type = Type::Volume then
                                UnapprItemUOM.SetRange(Type, Type::Weight)
                            else
                                UnapprItemUOM.SetRange(Type, Type::Volume);
                            if UnapprItemUOM.Find('-') then
                                "Qty. per Unit of Measure" := P800UOMFns.ConvertUOMWithSpecGravity(
                                  UnapprItemUOM."Qty. per Unit of Measure",
                                  UnapprItemUOM.Code, Code, UnapprItem."Specific Gravity");
                        end;
                    end;
                end;
            end;
        }
        field(3; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            InitValue = 1;

            trigger OnValidate()
            begin
                if "Qty. per Unit of Measure" <= 0 then
                    FieldError("Qty. per Unit of Measure", Text000);
                UnapprItem.Get("Unapproved Item No.");
                if UnapprItem."Base Unit of Measure" = Code then
                    TestField("Qty. per Unit of Measure", 1);
            end;
        }
        field(4; Type; Option)
        {
            CalcFormula = Lookup ("Unit of Measure".Type WHERE(Code = FIELD(Code)));
            Caption = 'Type';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = ' ,Length,Weight,Volume';
            OptionMembers = " ",Length,Weight,Volume;
        }
    }

    keys
    {
        key(Key1; "Unapproved Item No.", "Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Type, "Qty. per Unit of Measure")
        {
        }
    }

    trigger OnModify()
    var
        factor: Decimal;
        SpecGravity: Decimal;
    begin
        CalcFields(Type);
        if (Type <> 0) then begin
            UnapprItemUOM.Get("Unapproved Item No.", Code);
            if (UnapprItemUOM."Qty. per Unit of Measure" <> "Qty. per Unit of Measure") then begin
                UnapprItemUOM.Reset;
                UnapprItemUOM.SetRange("Unapproved Item No.", "Unapproved Item No.");
                UnapprItemUOM.SetRange(Type, Type);
                UnapprItemUOM.SetFilter(Code, '<>%1', Code);
                if UnapprItemUOM.Find('-') then begin
                    UOM.Get(Code);
                    factor := UOM."Base per Unit of Measure";
                    repeat
                        UOM.Get(UnapprItemUOM.Code);
                        UnapprItemUOM.Validate("Qty. per Unit of Measure", "Qty. per Unit of Measure" * UOM."Base per Unit of Measure" / factor);
                        UnapprItemUOM.Modify;
                    until UnapprItemUOM.Next = 0;
                end;
            end;
        end;

        // PR3.60 Begin
        UnapprItem.Get("Unapproved Item No.");
        UnapprItemUOM.SetRange("Unapproved Item No.", "Unapproved Item No.");
        case Type of
            Type::Weight:
                begin
                    UnapprItemUOM.SetRange(Type, Type::Volume);
                    if UnapprItemUOM.Find('-') then begin
                        SpecGravity := 0.001 * P800UOMFns.UOMtoMetricBase(Code) / "Qty. per Unit of Measure";
                        SpecGravity := SpecGravity * UnapprItemUOM."Qty. per Unit of Measure" / P800UOMFns.UOMtoMetricBase(UnapprItemUOM.Code);
                    end else
                        SpecGravity := 1;
                end;
            Type::Volume:
                begin
                    UnapprItemUOM.SetRange(Type, Type::Weight);
                    if UnapprItemUOM.Find('-') then begin
                        SpecGravity := 0.001 * P800UOMFns.UOMtoMetricBase(UnapprItemUOM.Code) / UnapprItemUOM."Qty. per Unit of Measure";
                        SpecGravity := SpecGravity * "Qty. per Unit of Measure" / P800UOMFns.UOMtoMetricBase(Code);
                    end else
                        SpecGravity := 1;
                end;
        end;
        UnapprItem."Specific Gravity" := SpecGravity;
        UnapprItem.Modify;
        // PR3.60 End
    end;

    var
        UnapprItem: Record "Unapproved Item";
        UOM: Record "Unit of Measure";
        UnapprItemUOM: Record "Unappr. Item Unit of Measure";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
        Text000: Label 'must be greater than 0';

    procedure CalcSpecGravity(no: Code[20]; var SpecGravity: Decimal): Boolean
    begin
        UnapprItemUOM.Reset;
        UnapprItemUOM.SetRange("Unapproved Item No.", no);
        UnapprItemUOM.SetRange(Type, Type::Weight);
        if UnapprItemUOM.Find('-') then begin
            SpecGravity := 0.001 * P800UOMFns.UOMtoMetricBase(UnapprItemUOM.Code) / UnapprItemUOM."Qty. per Unit of Measure";
            UnapprItemUOM.SetRange(Type, Type::Volume);
            if UnapprItemUOM.Find('-') then begin
                SpecGravity := SpecGravity * UnapprItemUOM."Qty. per Unit of Measure" / P800UOMFns.UOMtoMetricBase(UnapprItemUOM.Code);
                exit(true);
            end else
                exit(false);
        end else
            exit(false);
    end;
}

