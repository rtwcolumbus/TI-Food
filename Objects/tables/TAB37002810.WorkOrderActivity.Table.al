table 37002810 "Work Order Activity"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 30 AUG 06
    //   Planned labor and contractor for work orders
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 09 AUG 07
    //   Expand Vendor Name to TEXT50
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Work Order Activity';
    DrillDownPageID = "Work Order Activities";
    LookupPageID = "Work Order Activities";

    fields
    {
        field(1; "Work Order No."; Code[20])
        {
            Caption = 'Work Order No.';
            TableRelation = "Work Order";
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
                if CurrFieldNo <> 0 then
                    if EntriesExist(xRec) then
                        Error(Text001, FieldCaption("Trade Code"));

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
        field(5; Completed; Boolean)
        {
            Caption = 'Completed';
        }
        field(6; "Required Date"; Date)
        {
            Caption = 'Required Date';
        }
        field(7; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
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

                CalcHoursRemaining;
            end;
        }
        field(12; "Planned Hours Remaining"; Decimal)
        {
            Caption = 'Planned Hours Remaining';
            DecimalPlaces = 0 : 2;
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
        field(15; "Actual Hours"; Decimal)
        {
            CalcFormula = Sum ("Maintenance Ledger".Quantity WHERE("Work Order No." = FIELD("Work Order No."),
                                                                   "Entry Type" = FIELD(Type),
                                                                   "Maintenance Trade Code" = FIELD("Trade Code")));
            Caption = 'Actual Hours';
            Editable = false;
            FieldClass = FlowField;
        }
        field(16; "Actual Cost"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum ("Maintenance Ledger"."Cost Amount" WHERE("Work Order No." = FIELD("Work Order No."),
                                                                        "Entry Type" = FIELD(Type),
                                                                        "Maintenance Trade Code" = FIELD("Trade Code")));
            Caption = 'Actual Cost';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Work Order No.", Type, "Trade Code")
        {
            SumIndexFields = "Planned Cost", "Planned Hours", "Planned Hours Remaining";
        }
        key(Key2; Type, "Trade Code", "Location Code", Completed, "Required Date")
        {
            SumIndexFields = "Planned Hours", "Planned Hours Remaining";
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if EntriesExist(Rec) then
            Error(Text002);
    end;

    trigger OnInsert()
    begin
        GetWorkOrder;
        if WorkOrder."Scheduled Date" <> 0D then
            "Required Date" := WorkOrder."Scheduled Date"
        else
            "Required Date" := WorkOrder."Due Date";
        "Location Code" := WorkOrder."Location Code";
    end;

    var
        GLSetup: Record "General Ledger Setup";
        Trade: Record "Maintenance Trade";
        VendorTrade: Record "Vendor / Maintenance Trade";
        Text001: Label 'You cannot change %1 because there are one or more ledger entries for this activity.';
        Text002: Label 'You cannot delete this activity because there are one or more ledger entries for this activity.';
        WorkOrder: Record "Work Order";

    procedure EntriesExist(WOActivity: Record "Work Order Activity"): Boolean
    var
        MaintLedger: Record "Maintenance Ledger";
    begin
        with WOActivity do begin
            MaintLedger.SetCurrentKey("Work Order No.", "Entry Type", "Maintenance Trade Code");
            MaintLedger.SetRange("Work Order No.", "Work Order No.");
            case Type of
                Type::Labor:
                    MaintLedger.SetRange("Entry Type", MaintLedger."Entry Type"::Labor);
                Type::Contract:
                    MaintLedger.SetRange("Entry Type", MaintLedger."Entry Type"::Contract);
            end;
            MaintLedger.SetRange("Maintenance Trade Code", "Trade Code");
            exit(MaintLedger.FindFirst);
        end;
    end;

    procedure GetWorkOrder()
    begin
        if "Work Order No." <> WorkOrder."No." then
            WorkOrder.Get("Work Order No.");
    end;

    procedure CalcHoursRemaining()
    begin
        CalcFields("Actual Hours");
        if "Planned Hours" < "Actual Hours" then
            "Planned Hours Remaining" := 0
        else
            "Planned Hours Remaining" := "Planned Hours" - "Actual Hours";
    end;
}

