table 37002479 "Value Entry ABC Detail"
{
    // PR4.00.04
    // P8000375A, VerticalSoft, Jack Reynolds, 08 SEP 06
    //   ABC detail for indirect cost for output entries

    Caption = 'Value Entry ABC Detail';
    LookupPageID = "Value Entry ABC Details";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            Editable = false;
        }
        field(2; "Resource No."; Code[20])
        {
            Caption = 'Resource No.';
            Editable = false;
            TableRelation = Resource;
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            Editable = false;
            OptionCaption = 'Person,Machine,Other';
            OptionMembers = Person,Machine,Other;
        }
        field(4; Cost; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Cost';
            Editable = false;
        }
        field(5; "Cost Posted to G/L"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Cost Posted to G/L';
            Editable = false;
        }
        field(6; "Cost (ACY)"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode;
            AutoFormatType = 1;
            Caption = 'Cost (ACY)';
            Editable = false;
        }
        field(7; "Cost Posted to G/L (ACY)"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode;
            AutoFormatType = 1;
            Caption = 'Cost Posted to G/L (ACY)';
            Editable = false;
        }
        field(8; Overhead; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Overhead';
            Editable = false;
        }
        field(9; "Overhead Posted to G/L"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Overhead Posted to G/L';
            Editable = false;
        }
        field(10; "Overhead (ACY)"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode;
            AutoFormatType = 1;
            Caption = 'Overhead (ACY)';
            Editable = false;
        }
        field(11; "Overhead Posted to G/L (ACY)"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode;
            AutoFormatType = 1;
            Caption = 'Overhead Posted to G/L (ACY)';
            Editable = false;
        }
        field(12; "Item Ledger Entry No."; Integer)
        {
            Caption = 'Item Ledger Entry No.';
            Editable = false;
            TableRelation = "Item Ledger Entry";
        }
    }

    keys
    {
        key(Key1; "Entry No.", "Resource No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        GLSetup: Record "General Ledger Setup";
        GLSetupRead: Boolean;

    procedure GetCurrencyCode(): Code[10]
    begin
        if not GLSetupRead then begin
            GLSetup.Get;
            GLSetupRead := true;
        end;
        exit(GLSetup."Additional Reporting Currency");
    end;
}

