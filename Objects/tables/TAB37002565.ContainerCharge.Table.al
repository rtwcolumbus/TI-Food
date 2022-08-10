table 37002565 "Container Charge"
{
    // PRW16.00
    // P8000639, VerticalSoft, Jack Reynolds, 18 NOV 08
    //   Add DropDown field group
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Container Charge';
    LookupPageID = "Container Charges";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
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
            MinValue = 0;
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
        fieldgroup(DropDown; "Code", Description, "Unit Price")
        {
        }
    }

    trigger OnDelete()
    begin
        ContainerTypeCharge.SetCurrentKey("Container Charge Code"); // P8001305
        ContainerTypeCharge.SetRange("Container Charge Code", Code); // P8001305
        ContainerTypeCharge.DeleteAll;                              // P8001305
    end;

    var
        GLAcc: Record "G/L Account";
        ContainerTypeCharge: Record "Container Type Charge";
}

