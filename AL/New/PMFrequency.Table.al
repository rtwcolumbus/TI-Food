table 37002818 "PM Frequency"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 30 AUG 06
    //   Table to define the PM frequencies
    // 
    // PRW16.00
    // P8000639, VerticalSoft, Jack Reynolds, 18 NOV 08
    //   Add DropDown field group
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'PM Frequency';
    LookupPageID = "PM Frequencies";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Calendar,Usage,Combined';
            OptionMembers = Calendar,Usage,Combined;

            trigger OnValidate()
            begin
                if Type <> xRec.Type then
                    if PMExists then
                        Error(Text002, Code);

                if Type = Type::Calendar then begin
                    "Usage Frequency" := 0;
                    "Usage Unit of Measure" := '';
                end else
                    if Type = Type::Usage then
                        Evaluate("Calendar Frequency", '');
            end;
        }
        field(4; "Calendar Frequency"; DateFormula)
        {
            Caption = 'Calendar Frequency';

            trigger OnValidate()
            begin
                if Type = Type::Usage then
                    FieldError(Type, StrSubstNo(Text001, Type));
            end;
        }
        field(5; "Usage Frequency"; Decimal)
        {
            Caption = 'Usage Frequency';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                if Type = Type::Calendar then
                    FieldError(Type, StrSubstNo(Text001, Type));
            end;
        }
        field(6; "Usage Unit of Measure"; Code[10])
        {
            Caption = 'Usage Unit of Measure';
            TableRelation = "Unit of Measure";

            trigger OnValidate()
            begin
                if Type = Type::Calendar then
                    FieldError(Type, StrSubstNo(Text001, Type));

                if "Usage Unit of Measure" <> xRec."Usage Unit of Measure" then
                    if PMExists then
                        Error(Text002, Code);
            end;
        }
        field(7; "Lead Time"; DateFormula)
        {
            Caption = 'Lead Time';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description, Type, "Calendar Frequency", "Usage Frequency", "Usage Unit of Measure")
        {
        }
    }

    trigger OnDelete()
    begin
        if PMExists then
            Error(Text002, Code);
    end;

    var
        Text001: Label 'must not be %1';
        Text002: Label 'Preventive maintenance orders exist for %1.';

    procedure PMExists(): Boolean
    var
        PMOrder: Record "Preventive Maintenance Order";
    begin
        PMOrder.SetCurrentKey("Frequency Code");
        PMOrder.SetRange("Frequency Code", Code);
        exit(PMOrder.FindFirst);
    end;
}

