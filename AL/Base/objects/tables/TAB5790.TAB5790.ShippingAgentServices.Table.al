table 5790 "Shipping Agent Services"
{
    // PRW19.00.01
    // P8006916, To-Increase, Dayakar Battini, 16 SEP 16
    //   FOOD-TOM Separation

    Caption = 'Shipping Agent Services';
    DrillDownPageID = "Shipping Agent Services";
    LookupPageID = "Shipping Agent Services";

    fields
    {
        field(1; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            NotBlank = true;
            TableRelation = "Shipping Agent";
        }
        field(2; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(4; "Shipping Time"; DateFormula)
        {
            Caption = 'Shipping Time';

            trigger OnValidate()
            var
                DateTest: Date;
            begin
                DateTest := CalcDate("Shipping Time", WorkDate());
                if DateTest < WorkDate() then
                    Error(Text000, FieldCaption("Shipping Time"));
            end;
        }
        field(7600; "Base Calendar Code"; Code[10])
        {
            Caption = 'Base Calendar Code';
            TableRelation = "Base Calendar";
        }
        field(11028620; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            Description = 'N138F0000';
            TableRelation = Vendor;
        }
        field(11028626; "Delivery Trip Route"; Boolean)
        {
            Caption = 'Delivery Trip Route';
            Description = 'N138F0000';
        }
    }

    keys
    {
        key(Key1; "Shipping Agent Code", "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description, "Shipping Time")
        {
        }
    }

    var
        Text000: Label 'The %1 cannot be negative.';
}

