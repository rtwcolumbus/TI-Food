table 37002141 "Accrual Charge Line"
{
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Accrual Charge Line';
    DrillDownPageID = "Accrual Charge Lines";
    LookupPageID = "Accrual Charge Lines";

    fields
    {
        field(1; "Accrual Plan Type"; Option)
        {
            Caption = 'Accrual Plan Type';
            OptionCaption = 'Sales,Purchase';
            OptionMembers = Sales,Purchase;
        }
        field(2; "Accrual Plan No."; Code[20])
        {
            Caption = 'Accrual Plan No.';
            NotBlank = true;
            TableRelation = "Accrual Plan"."No." WHERE(Type = FIELD("Accrual Plan Type"));
        }
        field(3; "Accrual Charge Code"; Code[20])
        {
            Caption = 'Accrual Charge Code';
            NotBlank = true;
            TableRelation = "Accrual Charge";

            trigger OnValidate()
            begin
                if ("Accrual Charge Code" <> '') then begin
                    AccrualCharge.Get("Accrual Charge Code");
                    Description := AccrualCharge.Description;
                end;
            end;
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(5; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';

            trigger OnValidate()
            begin
                if Quantity <> 0 then begin
                    GLSetup.Get;
                    "Unit Amount" := Round(Amount / Quantity, GLSetup."Unit-Amount Rounding Precision");
                end;
            end;
        }
        field(6; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            InitValue = 1;
            MinValue = 0;

            trigger OnValidate()
            begin
                GLSetup.Get;
                Amount := Round(Quantity * "Unit Amount", GLSetup."Amount Rounding Precision");
            end;
        }
        field(7; "Unit Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Unit Amount';

            trigger OnValidate()
            begin
                GLSetup.Get;
                Amount := Round(Quantity * "Unit Amount", GLSetup."Amount Rounding Precision");
            end;
        }
    }

    keys
    {
        key(Key1; "Accrual Plan Type", "Accrual Plan No.", "Accrual Charge Code")
        {
            SumIndexFields = Amount;
        }
    }

    fieldgroups
    {
    }

    var
        AccrualCharge: Record "Accrual Charge";
        GLSetup: Record "General Ledger Setup";
}

