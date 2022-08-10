table 37002566 "Container Type Charge"
{
    Caption = 'Container Type Charge';

    fields
    {
        field(1; "Container Type Code"; Code[10])
        {
            Caption = 'Container Type Code';
            TableRelation = "Container Type".Code WHERE("Container Item No." = FILTER(<> ''));
        }
        field(2; "Container Charge Code"; Code[10])
        {
            Caption = 'Container Charge Code';
            TableRelation = "Container Charge";

            trigger OnValidate()
            begin
                if "Container Charge Code" <> xRec."Container Charge Code" then
                    if ContCharge.Get("Container Charge Code") then begin
                        "Account No." := ContCharge."Account No.";
                        "Unit Price" := ContCharge."Unit Price";
                    end else begin
                        "Account No." := '';
                        "Unit Price" := 0;
                    end;
            end;
        }
        field(3; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                if "Account No." <> '' then begin
                    GLAcc.Get("Account No.");
                    GLAcc.CheckGLAcc;
                end;
            end;
        }
        field(4; "Unit Price"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price';
        }
    }

    keys
    {
        key(Key1; "Container Type Code", "Container Charge Code")
        {
        }
        key(Key2; "Container Charge Code", "Container Type Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        GLAcc: Record "G/L Account";
        ContainerType: Record "Container Type";
        ContCharge: Record "Container Charge";
}

