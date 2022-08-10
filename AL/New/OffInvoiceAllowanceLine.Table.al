table 37002043 "Off-Invoice Allowance Line"
{
    Caption = 'Off-Invoice Allowance Line';

    fields
    {
        field(1; "Allowance Code"; Code[10])
        {
            Caption = 'Allowance Code';
            NotBlank = true;
            TableRelation = "Off-Invoice Allowance Header";
        }
        field(2; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Both,Order,Invoice';
            OptionMembers = Both,"Order",Invoice;
        }
        field(3; "Sales Type"; Option)
        {
            Caption = 'Sales Type';
            OptionCaption = 'Customer,Customer Price Group,All Customers';
            OptionMembers = Customer,"Customer Price Group","All Customers";

            trigger OnValidate()
            begin
                if "Sales Type" <> xRec."Sales Type" then
                    "Sales Code" := '';
            end;
        }
        field(4; "Sales Code"; Code[20])
        {
            Caption = 'Sales Code';
            TableRelation = IF ("Sales Type" = CONST("Customer Price Group")) "Customer Price Group"
            ELSE
            IF ("Sales Type" = CONST(Customer)) Customer;
        }
        field(5; Basis; Option)
        {
            Caption = 'Basis';
            OptionCaption = 'Weight,Volume,Quantity,Amount';
            OptionMembers = Weight,Volume,Quantity,Amount;

            trigger OnValidate()
            begin
                if Basis <> xRec.Basis then begin
                    Validate(Method, Method::Amount);
                    SetDefaultUOM;
                end;
            end;
        }
        field(6; Method; Option)
        {
            Caption = 'Method';
            OptionCaption = 'Amount,Percent';
            OptionMembers = Amount,Percent;

            trigger OnValidate()
            begin
                if Method <> xRec.Method then
                    Amount := 0;

                if Method = Method::Percent then
                    TestField(Basis, Basis::Amount);
            end;
        }
        field(7; Amount; Decimal)
        {
            Caption = 'Amount';
            DecimalPlaces = 2 : 5;
        }
        field(8; "Starting Date"; Date)
        {
            Caption = 'Starting Date';

            trigger OnValidate()
            var
                TempOffInvoiceAllowanceHeader: Record "Off-Invoice Allowance Header";
            begin
            end;
        }
        field(9; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
            NotBlank = false;
        }
        field(10; "Minimum Quantity"; Decimal)
        {
            Caption = 'Minimum Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(11; "Tax Excludes Allowance"; Boolean)
        {
            Caption = 'Tax Excludes Allowance';
            InitValue = true;
        }
        field(12; "G/L Account"; Code[20])
        {
            Caption = 'G/L Account';
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                if "G/L Account" = '' then
                    SetDefaultGLAccount;
                GLAcc.Get("G/L Account");
                GLAcc.CheckGLAcc;
            end;
        }
        field(13; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = IF (Basis = CONST(Weight)) "Unit of Measure" WHERE(Type = CONST(Weight))
            ELSE
            IF (Basis = CONST(Volume)) "Unit of Measure" WHERE(Type = CONST(Volume));

            trigger OnValidate()
            begin
                if "Unit of Measure Code" <> '' then
                    if not (Basis in [Basis::Weight, Basis::Volume]) then
                        Error(Text001, FieldCaption("Unit of Measure Code"), FieldCaption(Basis));
            end;
        }
        field(100; Allowance; Decimal)
        {
            Caption = 'Allowance';
        }
    }

    keys
    {
        key(Key1; "Allowance Code", "Document Type", "Sales Type", "Sales Code", Basis, Method, "Starting Date", "Minimum Quantity")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if "G/L Account" = '' then
            SetDefaultGLAccount;
    end;

    var
        AllowanceHeader: Record "Off-Invoice Allowance Header";
        InvSetup: Record "Inventory Setup";
        MeasureSystem: Record "Measuring System";
        GLAcc: Record "G/L Account";
        Text001: Label '''%1 is valid only for %2 of Weight or Volume.';

    procedure SetupNewLine(LastLine: Record "Off-Invoice Allowance Line")
    var
        AllowanceLine: Record "Off-Invoice Allowance Line";
    begin
        if not AllowanceHeader.Get("Allowance Code") then
            exit;

        "Document Type" := LastLine."Document Type";
        "Sales Type" := LastLine."Sales Type";
        "Sales Code" := LastLine."Sales Code";
        Basis := LastLine.Basis;
        Method := LastLine.Method;
        "Starting Date" := LastLine."Starting Date";
        "Tax Excludes Allowance" := LastLine."Tax Excludes Allowance";
        "G/L Account" := LastLine."G/L Account";
        "Unit of Measure Code" := LastLine."Unit of Measure Code";

        if "Unit of Measure Code" = '' then
            SetDefaultUOM;

        if "G/L Account" = '' then
            SetDefaultGLAccount;
    end;

    procedure SetDefaultUOM()
    begin
        InvSetup.Get;
        MeasureSystem.SetRange("Measuring System", InvSetup."Measuring System");
        case Basis of
            Basis::Weight:
                begin
                    MeasureSystem.SetRange(Type, MeasureSystem.Type::Weight);
                    MeasureSystem.Find('-');
                    "Unit of Measure Code" := MeasureSystem.UOM;
                end;
            Basis::Volume:
                begin
                    MeasureSystem.SetRange(Type, MeasureSystem.Type::Volume);
                    MeasureSystem.Find('-');
                    "Unit of Measure Code" := MeasureSystem.UOM;
                end;
            else
                "Unit of Measure Code" := '';
        end;
    end;

    procedure SetDefaultGLAccount()
    begin
        AllowanceHeader.Get("Allowance Code");
        "G/L Account" := AllowanceHeader."G/L Account";
    end;
}

