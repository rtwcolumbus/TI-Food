table 37002131 "Accrual Group Line"
{
    // PR3.61AC
    // 
    // PR4.00.04
    // P8000355A, VerticalSoft, Jack Reynolds, 19 JUL 06
    //   Add code to maintain accrual plan search line table on insert, delete, rename
    // 
    // PRW16.00.03
    // P8000828, VerticalSoft, Don Bresee, 09 JUN 10
    //   Move insert/delete logic to form/page
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Accrual Group Line';

    fields
    {
        field(1; "Accrual Group Type"; Option)
        {
            Caption = 'Accrual Group Type';
            OptionCaption = 'Customer,Vendor,Item';
            OptionMembers = Customer,Vendor,Item;
        }
        field(2; "Accrual Group Code"; Code[10])
        {
            Caption = 'Accrual Group Code';
            NotBlank = true;
            TableRelation = "Accrual Group".Code WHERE(Type = FIELD("Accrual Group Type"));
        }
        field(3; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
            TableRelation = IF ("Accrual Group Type" = CONST(Customer)) Customer
            ELSE
            IF ("Accrual Group Type" = CONST(Vendor)) Vendor
            ELSE
            IF ("Accrual Group Type" = CONST(Item)) Item;
        }
        field(4; "Accrual Group Description"; Text[100])
        {
            CalcFormula = Lookup ("Accrual Group".Description WHERE(Type = FIELD("Accrual Group Type"),
                                                                    Code = FIELD("Accrual Group Code")));
            Caption = 'Accrual Group Description';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Accrual Group Type", "Accrual Group Code", "No.")
        {
        }
        key(Key2; "Accrual Group Type", "No.", "Accrual Group Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        // AccrualSearchMgt.DeleteGroupLine(Rec); // P8000355A, P8000828
    end;

    trigger OnInsert()
    begin
        // AccrualSearchMgt.InsertGroupLine(Rec); // P8000355A, P8000828
    end;

    trigger OnRename()
    begin
        AccrualSearchMgt.InsertGroupLine(Rec);  // P8000355A
        AccrualSearchMgt.DeleteGroupLine(xRec); // P8000355A
    end;

    var
        AccrualSearchMgt: Codeunit "Accrual Search Management";
}

