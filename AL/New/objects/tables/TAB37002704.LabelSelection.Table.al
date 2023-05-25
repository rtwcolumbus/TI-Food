table 37002704 "Label Selection"
{
    // PRW16.00.06
    // P8001123, Columbus IT, Jack Reynolds, 19 DEC 12
    //   Move Item table Label Code fields to Item Label table
    // 
    // PRW111.00.01
    // P80056709, To-Increase, Jack Reynolds, 25 JUL 18
    //   Production Containers - assign container to production order

    Caption = 'Label Selection';
    DataCaptionFields = "Source No.";

    fields
    {
        field(1; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            NotBlank = true;
            TableRelation = IF ("Source Type" = CONST(27)) Item
            ELSE
            IF ("Source Type" = CONST(37002578)) "Container Type";
        }
        field(2; "Label Type"; Enum "Label Type")
        {
            Caption = 'Label Type';

            trigger OnValidate()
            begin
                if "Label Type" <> xRec."Label Type" then
                    "Label Code" := '';
            end;
        }
        field(3; "Label Code"; Code[10])
        {
            Caption = 'Label Code';
            NotBlank = true;
            TableRelation = Label WHERE(Type = FIELD("Label Type"));
        }
        field(4; "Source Type"; Integer)
        {
            Caption = 'Source Type';
            NotBlank = true;
        }
    }

    keys
    {
        key(Key1; "Source Type", "Source No.", "Label Type")
        {
        }
    }

    fieldgroups
    {
    }
}

