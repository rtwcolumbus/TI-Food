table 37002809 "Maintenance Trade"
{
    // PR4.00.40
    // P8000333A, VerticalSoft, Jack Reynolds, 30 AUG 06
    //   Table of trades for maintenance labor and contractor tracking
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Maintenance Trade';
    LookupPageID = "Maintenance Trades";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Internal Rate (Hourly)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Internal Rate (Hourly)';

            trigger OnValidate()
            begin
                if "Internal Rate (Hourly)" <> xRec."Internal Rate (Hourly)" then begin
                    PMActivity.SetCurrentKey(Type, "Trade Code");
                    PMActivity.SetRange(Type, PMActivity.Type::Labor);
                    PMActivity.SetRange("Trade Code", Code);
                    if PMActivity.FindSet(true, false) then
                        repeat
                            PMActivity.Validate("Rate (Hourly)", "Internal Rate (Hourly)");
                            PMActivity.Modify;
                        until PMActivity.Next = 0;
                end;
            end;
        }
        field(4; "External Rate (Hourly)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'External Rate (Hourly)';

            trigger OnValidate()
            begin
                if "External Rate (Hourly)" <> xRec."External Rate (Hourly)" then begin
                    PMActivity.SetCurrentKey(Type, "Trade Code");
                    PMActivity.SetRange(Type, PMActivity.Type::Contract);
                    PMActivity.SetRange("Trade Code", Code);
                    if PMActivity.FindSet(true, false) then
                        repeat
                            if not VendorTrade.Get(PMActivity."Vendor No.", Code) then begin
                                PMActivity.Validate("Rate (Hourly)", "External Rate (Hourly)");
                                PMActivity.Modify;
                            end;
                        until PMActivity.Next = 0;
                end;
            end;
        }
        field(5; "Planned Labor Hours"; Decimal)
        {
            CalcFormula = Sum ("Work Order Activity"."Planned Hours" WHERE("Trade Code" = FIELD(Code),
                                                                           Type = CONST(Labor),
                                                                           "Location Code" = FIELD("Location Filter"),
                                                                           Completed = CONST(false),
                                                                           "Required Date" = FIELD("Date Filter")));
            Caption = 'Planned Labor Hours';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(6; "Remaining Labor Hours"; Decimal)
        {
            CalcFormula = Sum ("Work Order Activity"."Planned Hours Remaining" WHERE("Trade Code" = FIELD(Code),
                                                                                     Type = CONST(Labor),
                                                                                     "Location Code" = FIELD("Location Filter"),
                                                                                     Completed = CONST(false),
                                                                                     "Required Date" = FIELD("Date Filter")));
            Caption = 'Remaining Labor Hours';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(7; "Planned Contract Hours"; Decimal)
        {
            CalcFormula = Sum ("Work Order Activity"."Planned Hours" WHERE("Trade Code" = FIELD(Code),
                                                                           Type = CONST(Contract),
                                                                           "Location Code" = FIELD("Location Filter"),
                                                                           Completed = CONST(false),
                                                                           "Required Date" = FIELD("Date Filter")));
            Caption = 'Planned Contract Hours';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(8; "Remaining Contract Hours"; Decimal)
        {
            CalcFormula = Sum ("Work Order Activity"."Planned Hours Remaining" WHERE("Trade Code" = FIELD(Code),
                                                                                     Type = CONST(Contract),
                                                                                     "Location Code" = FIELD("Location Filter"),
                                                                                     Completed = CONST(false),
                                                                                     "Required Date" = FIELD("Date Filter")));
            Caption = 'Remaining Contract Hours';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(12; "Location Filter"; Code[10])
        {
            Caption = 'Location Filter';
            FieldClass = FlowFilter;
            TableRelation = Location;
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
    }

    var
        PMActivity: Record "PM Activity";
        VendorTrade: Record "Vendor / Maintenance Trade";
}

