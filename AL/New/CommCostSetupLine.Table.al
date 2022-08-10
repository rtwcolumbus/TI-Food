table 37002682 "Comm. Cost Setup Line"
{
    // PRW16.00.04
    // P8000856, VerticalSoft, Don Bresee, 24 AUG 10
    //   Add Commodity Class Costing granule

    Caption = 'Comm. Cost Setup Line';
    LookupPageID = "Comm. Class Cost Components";

    fields
    {
        field(1; "Commodity Class Code"; Code[10])
        {
            Caption = 'Commodity Class Code';
            NotBlank = true;
            TableRelation = "Commodity Class";

            trigger OnValidate()
            begin
                CalcFields("Commodity Class Description");
            end;
        }
        field(2; "Comm. Cost Component Code"; Code[10])
        {
            Caption = 'Comm. Cost Component Code';
            NotBlank = true;
            TableRelation = "Comm. Cost Component";

            trigger OnValidate()
            begin
                CalcFields("Comm. Cost Comp. Description");
            end;
        }
        field(3; "Commodity Class Description"; Text[100])
        {
            CalcFormula = Lookup ("Commodity Class".Description WHERE(Code = FIELD("Commodity Class Code")));
            Caption = 'Commodity Class Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(4; "Comm. Cost Comp. Description"; Text[100])
        {
            CalcFormula = Lookup ("Comm. Cost Component".Description WHERE(Code = FIELD("Comm. Cost Component Code")));
            Caption = 'Comm. Cost Comp. Description';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Commodity Class Code", "Comm. Cost Component Code")
        {
        }
        key(Key2; "Comm. Cost Component Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        CommClassEntry.SetCurrentKey("Commodity Class Code", "Comm. Cost Component Code");
        CommClassEntry.SetRange("Commodity Class Code", "Commodity Class Code");
        CommClassEntry.SetRange("Comm. Cost Component Code", "Comm. Cost Component Code");
        CommClassEntry.DeleteAll(true);
    end;

    var
        CommClassEntry: Record "Commodity Cost Entry";

    procedure GetDescription(): Text[250]
    begin
        CalcFields("Commodity Class Description");
        CalcFields("Comm. Cost Comp. Description");
        if ("Commodity Class Description" <> '') or ("Comm. Cost Comp. Description" <> '') then begin
            if ("Commodity Class Description" = '') then
                exit("Comm. Cost Comp. Description");
            if ("Comm. Cost Comp. Description" = '') then
                exit("Commodity Class Description");
            exit(StrSubstNo('%1 - %2', "Commodity Class Description", "Comm. Cost Comp. Description"));
        end;
    end;
}

