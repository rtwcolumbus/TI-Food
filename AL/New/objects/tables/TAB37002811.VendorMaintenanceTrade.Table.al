table 37002811 "Vendor / Maintenance Trade"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 30 AUG 06
    //   Table of trades and rates for vendors
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 09 AUG 07
    //   Expand Vendor Name to TEXT50
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Vendor / Maintenance Trade';
    DataCaptionFields = "Vendor No.";

    fields
    {
        field(1; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            NotBlank = true;
            TableRelation = Vendor;
        }
        field(2; "Trade Code"; Code[10])
        {
            Caption = 'Trade Code';
            NotBlank = true;
            TableRelation = "Maintenance Trade";

            trigger OnValidate()
            begin
                if "Trade Code" <> '' then begin
                    Trade.Get("Trade Code");
                    "Rate (Hourly)" := Trade."External Rate (Hourly)";
                end;
            end;
        }
        field(3; "Rate (Hourly)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Rate (Hourly)';

            trigger OnValidate()
            begin
                if "Rate (Hourly)" <> xRec."Rate (Hourly)" then begin
                    PMActivity.SetCurrentKey(Type, "Trade Code");
                    PMActivity.SetRange(Type, PMActivity.Type::Contract);
                    PMActivity.SetRange("Trade Code", "Trade Code");
                    PMActivity.SetRange("Vendor No.", "Vendor No.");
                    if PMActivity.FindSet(true, false) then
                        repeat
                            PMActivity.Validate("Rate (Hourly)", "Rate (Hourly)");
                            PMActivity.Modify;
                        until PMActivity.Next = 0;
                end;
            end;
        }
        field(4; "Trade Description"; Text[100])
        {
            CalcFormula = Lookup ("Maintenance Trade".Description WHERE(Code = FIELD("Trade Code")));
            Caption = 'Trade Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "Vendor Name"; Text[100])
        {
            CalcFormula = Lookup (Vendor.Name WHERE("No." = FIELD("Vendor No.")));
            Caption = 'Vendor Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(12; "Total Cost"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum ("Maintenance Ledger"."Cost Amount" WHERE("Entry Type" = CONST(Contract),
                                                                        "Posting Date" = FIELD("Date Filter"),
                                                                        "Maintenance Trade Code" = FIELD("Trade Code"),
                                                                        "Vendor No." = FIELD("Vendor No.")));
            Caption = 'Total Cost';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Vendor No.", "Trade Code")
        {
        }
        key(Key2; "Trade Code", "Vendor No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Trade: Record "Maintenance Trade";
        PMActivity: Record "PM Activity";
}

