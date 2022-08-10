table 37002683 "Commodity Cost Period"
{
    // PRW16.00.04
    // P8000856, VerticalSoft, Don Bresee, 24 AUG 10
    //   Add Commodity Class Costing granule

    Caption = 'Commodity Cost Period';
    DataCaptionFields = "Location Code", "Starting Market Date";
    LookupPageID = "Commodity Cost Periods";

    fields
    {
        field(1; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(2; "Starting Market Date"; Date)
        {
            Caption = 'Starting Market Date';
        }
        field(3; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(4; "Component Value"; Decimal)
        {
            BlankZero = true;
            CalcFormula = Sum ("Commodity Cost Entry"."Component Value" WHERE("Comm. Class Period Entry No." = FIELD("Entry No."),
                                                                              "Commodity Class Code" = FIELD("Commodity Class Filter"),
                                                                              "Comm. Cost Component Code" = FIELD("Comm. Cost Comp. Filter")));
            Caption = 'Component Value';
            DecimalPlaces = 2 : 12;
            FieldClass = FlowField;
        }
        field(5; "Calculate Cost"; Boolean)
        {
            Caption = 'Calculate Cost';
            InitValue = true;
        }
        field(100; "Commodity Class Filter"; Code[10])
        {
            Caption = 'Commodity Class Filter';
            FieldClass = FlowFilter;
            TableRelation = "Commodity Class";
        }
        field(101; "Comm. Cost Comp. Filter"; Code[10])
        {
            Caption = 'Comm. Cost Comp. Filter';
            FieldClass = FlowFilter;
            TableRelation = "Comm. Cost Component";
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Location Code", "Starting Market Date")
        {
        }
        key(Key3; "Starting Market Date", "Calculate Cost")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        SetCalcPreviousLine;

        CommClassEntry.SetRange("Comm. Class Period Entry No.", "Entry No.");
        CommClassEntry.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        TestField("Starting Market Date");
    end;

    trigger OnModify()
    begin
        TestField("Starting Market Date");
    end;

    var
        CommClassEntry: Record "Commodity Cost Entry";
        Text000: Label '%1 already exists for %2 %3.';
        Text001: Label '%1 already exists for %2 %3 and %4 %5.';

    procedure EndingMarketDate(): Date
    var
        NextCommPeriod: Record "Commodity Cost Period";
    begin
        if ("Starting Market Date" <> 0D) then begin
            NextCommPeriod := Rec;
            NextCommPeriod.SetCurrentKey("Location Code", "Starting Market Date");
            NextCommPeriod.SetRange("Location Code", "Location Code");
            if (NextCommPeriod.Next <> 0) then
                exit(NextCommPeriod."Starting Market Date" - 1);
        end;
    end;

    procedure TestLocationAndDate()
    var
        OrigCommPeriod: Record "Commodity Cost Period";
        CommClassPeriod: Record "Commodity Cost Period";
    begin
        if OrigCommPeriod.Get("Entry No.") then
            if ("Location Code" <> OrigCommPeriod."Location Code") or
               ("Starting Market Date" <> OrigCommPeriod."Starting Market Date")
            then begin
                CommClassPeriod.SetCurrentKey("Location Code", "Starting Market Date");
                CommClassPeriod.SetRange("Location Code", "Location Code");
                CommClassPeriod.SetRange("Starting Market Date", "Starting Market Date");
                if CommClassPeriod.FindFirst then
                    if ("Location Code" = '') then
                        Error(Text000,
                          TableCaption, FieldCaption("Starting Market Date"), "Starting Market Date")
                    else
                        Error(Text001,
                          TableCaption, FieldCaption("Location Code"), "Location Code",
                          FieldCaption("Starting Market Date"), "Starting Market Date");
                if ("Location Code" <> OrigCommPeriod."Location Code") then begin
                    SetCalcPreviousLine;
                    "Calculate Cost" := true;
                end else
                    if ("Starting Market Date" < OrigCommPeriod."Starting Market Date") then begin
                        if JumpedLinesBefore then
                            SetCalcPreviousLine;
                        "Calculate Cost" := true;
                    end else begin
                        SetCalcPreviousLine;
                        if JumpedLinesAfter then
                            "Calculate Cost" := true;
                    end;
            end;
    end;

    local procedure SetCalcPreviousLine()
    var
        OrigCommPeriod: Record "Commodity Cost Period";
        PrevCommPeriod: Record "Commodity Cost Period";
    begin
        if OrigCommPeriod.Get("Entry No.") then
            if (OrigCommPeriod."Starting Market Date" <> 0D) then begin
                PrevCommPeriod.SetCurrentKey("Location Code", "Starting Market Date");
                PrevCommPeriod.SetRange("Location Code", OrigCommPeriod."Location Code");
                PrevCommPeriod.SetRange(
                  "Starting Market Date", 0D, OrigCommPeriod."Starting Market Date" - 1);
                if PrevCommPeriod.FindLast then begin
                    PrevCommPeriod."Calculate Cost" := true;
                    PrevCommPeriod.Modify;
                end;
            end;
    end;

    local procedure JumpedLinesBefore(): Boolean
    var
        OrigCommPeriod: Record "Commodity Cost Period";
        JumpedCommPeriod: Record "Commodity Cost Period";
    begin
        if OrigCommPeriod.Get("Entry No.") then begin
            JumpedCommPeriod.SetCurrentKey("Location Code", "Starting Market Date");
            JumpedCommPeriod.SetRange("Location Code", "Location Code");
            JumpedCommPeriod.SetRange(
              "Starting Market Date", "Starting Market Date" + 1, OrigCommPeriod."Starting Market Date" - 1);
            exit(not JumpedCommPeriod.IsEmpty());
        end;
    end;

    local procedure JumpedLinesAfter(): Boolean
    var
        OrigCommPeriod: Record "Commodity Cost Period";
        JumpedCommPeriod: Record "Commodity Cost Period";
    begin
        if OrigCommPeriod.Get("Entry No.") then begin
            JumpedCommPeriod.SetCurrentKey("Location Code", "Starting Market Date");
            JumpedCommPeriod.SetRange("Location Code", "Location Code");
            JumpedCommPeriod.SetRange(
              "Starting Market Date", OrigCommPeriod."Starting Market Date" + 1, "Starting Market Date" - 1);
            exit(not JumpedCommPeriod.IsEmpty());
        end;
    end;
}

