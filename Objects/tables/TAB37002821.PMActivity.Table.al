table 37002821 "PM Activity"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 31 AUG 06
    //   Planned activities for PM orders
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 09 AUG 07
    //   Expand Vendor Name to TEXT50
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'PM Activity';
    DrillDownPageID = "PM Activities";
    LookupPageID = "PM Activities";

    fields
    {
        field(1; "PM Entry No."; Code[20])
        {
            Caption = 'PM Entry No.';
            TableRelation = "Preventive Maintenance Order";
        }
        field(2; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Labor,,,Contract';
            OptionMembers = Labor,,,Contract;
        }
        field(3; "Trade Code"; Code[10])
        {
            Caption = 'Trade Code';
            TableRelation = "Maintenance Trade";

            trigger OnValidate()
            begin
                if "Trade Code" <> '' then
                    case Type of
                        Type::Labor:
                            begin
                                Trade.Get("Trade Code");
                                Validate("Rate (Hourly)", Trade."Internal Rate (Hourly)");
                            end;
                        Type::Contract:
                            begin
                                if VendorTrade.Get("Vendor No.", "Trade Code") then
                                    Validate("Rate (Hourly)", VendorTrade."Rate (Hourly)")
                                else begin
                                    Trade.Get("Trade Code");
                                    Validate("Rate (Hourly)", Trade."External Rate (Hourly)");
                                end;
                            end;
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
        field(8; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;

            trigger OnValidate()
            begin
                if VendorTrade.Get("Vendor No.", "Trade Code") then
                    Validate("Rate (Hourly)", VendorTrade."Rate (Hourly)")
            end;
        }
        field(9; "Vendor Name"; Text[100])
        {
            CalcFormula = Lookup (Vendor.Name WHERE("No." = FIELD("Vendor No.")));
            Caption = 'Vendor Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; "Planned Hours"; Decimal)
        {
            Caption = 'Planned Hours';
            DecimalPlaces = 0 : 2;

            trigger OnValidate()
            begin
                Validate("Planned Cost", "Rate (Hourly)" * "Planned Hours");
            end;
        }
        field(13; "Rate (Hourly)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Rate (Hourly)';

            trigger OnValidate()
            begin
                Validate("Planned Cost", "Rate (Hourly)" * "Planned Hours");
            end;
        }
        field(14; "Planned Cost"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Planned Cost';
            Editable = false;

            trigger OnValidate()
            begin
                GLSetup.Get;
                "Planned Cost" := Round("Planned Cost", GLSetup."Amount Rounding Precision");
            end;
        }
    }

    keys
    {
        key(Key1; "PM Entry No.", Type, "Trade Code")
        {
            SumIndexFields = "Planned Cost";
        }
        key(Key2; Type, "Trade Code", "Vendor No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        GLSetup: Record "General Ledger Setup";
        Trade: Record "Maintenance Trade";
        VendorTrade: Record "Vendor / Maintenance Trade";
        PMOrder: Record "Preventive Maintenance Order";

    procedure GetPMOrder()
    begin
        if PMOrder."Entry No." <> "PM Entry No." then
            PMOrder.Get("PM Entry No.");
    end;

    procedure AssetNo(): Code[20]
    begin
        GetPMOrder;
        exit(PMOrder."Asset No.");
    end;

    procedure FrequencyCode(): Code[10]
    begin
        GetPMOrder;
        exit(PMOrder."Frequency Code");
    end;
}

