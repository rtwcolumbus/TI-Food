table 37002038 "Lot No. Segment Value"
{
    // PRW17.10
    // P8001234, Columbus IT, Jack Reynolds, 01 NOV 13
    //    Support for custom lot number formats
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Lot No. Segment Value';

    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Location,Equipment,Shift';
            OptionMembers = Location,Equipment,Shift;

            trigger OnValidate()
            begin
                if Type <> xRec.Type then begin
                    "Code/No." := '';
                    "Segment Value" := '';
                end;
            end;
        }
        field(2; "Code/No."; Code[20])
        {
            Caption = 'Code/No.';
            NotBlank = true;
            TableRelation = IF (Type = CONST(Location)) Location
            ELSE
            IF (Type = CONST(Equipment)) Resource WHERE(Type = CONST(Machine))
            ELSE
            IF (Type = CONST(Shift)) "Work Shift";

            trigger OnValidate()
            begin
                if "Code/No." <> xRec."Code/No." then
                    "Segment Value" := '';
            end;
        }
        field(3; "Segment Value"; Code[5])
        {
            Caption = 'Segment Value';
        }
    }

    keys
    {
        key(Key1; Type, "Code/No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure Description(): Text[100]
    var
        Location: Record Location;
        Resource: Record Resource;
        WorkShift: Record "Work Shift";
    begin
        if "Code/No." = '' then
            exit('');

        case Type of
            Type::Location:
                begin
                    Location.Get("Code/No.");
                    exit(Location.Name);
                end;
            Type::Equipment:
                begin
                    Resource.Get("Code/No.");
                    exit(Resource.Name);
                end;
            Type::Shift:
                begin
                    WorkShift.Get("Code/No.");
                    exit(WorkShift.Description);
                end;
        end;
    end;

    procedure SetupNewLine(LastLine: Record "Lot No. Segment Value")
    begin
        Type := LastLine.Type;
    end;
}

