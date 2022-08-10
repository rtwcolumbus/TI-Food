table 37002820 "Asset Usage"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 31 AUG 06
    //   Stores asset usage readings for purpose of scheduling usage based PM
    // 
    // PRW15.00.01
    // P8000590A, VerticalSoft, Jack Reynolds, 07 MAR 08
    //   Correct bug with calculation of average daily usage
    //   Add function to check tolerance on average daily usage

    Caption = 'Asset Usage';

    fields
    {
        field(1; "Asset No."; Code[20])
        {
            Caption = 'Asset No.';
            TableRelation = Asset;
        }
        field(2; Date; Date)
        {
            Caption = 'Date';

            trigger OnValidate()
            begin
                if Date = 0D then
                    exit;
                if GetLastReading then
                    CheckDate;
                CalcAvgDailyUsage;
            end;
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            InitValue = Reading;
            OptionCaption = 'Meter Change,Reading';
            OptionMembers = "Meter Change",Reading;

            trigger OnValidate()
            begin
                Validate(Reading);
            end;
        }
        field(4; Reading; Decimal)
        {
            Caption = 'Reading';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                if GetLastReading then
                    CheckReading;
                CalcAvgDailyUsage;
            end;
        }
        field(5; "Average Daily Usage"; Decimal)
        {
            Caption = 'Average Daily Usage';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Asset No.", Date, Type)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        TestField(Date);
        if GetLastReading then begin
            CheckDate;
            CheckReading
        end;

        CalcAvgDailyUsage;
    end;

    var
        LastReading: Record "Asset Usage";
        Text001: Label '%1 must be after last %1 of %2.';
        Text002: Label '%1 must be greater than last %1 of %2.';

    procedure GetLastReading(): Boolean
    begin
        LastReading.SetRange("Asset No.", "Asset No.");
        exit(LastReading.FindLast);
    end;

    procedure CheckDate()
    begin
        if Date <= LastReading.Date then
            Error(Text001, FieldCaption(Date), LastReading.Date);
    end;

    procedure CheckReading()
    begin
        if Reading <= LastReading.Reading then
            Error(Text002, FieldCaption(Reading), LastReading.Reading);
    end;

    procedure CalcAvgDailyUsage()
    begin
        "Average Daily Usage" := 0;

        // P8000590A
        //IF NOT GetLastReading THEN
        //  EXIT;
        LastReading := Rec;
        LastReading.SetRange("Asset No.", "Asset No.");
        if LastReading.Next(-1) = 0 then
            exit;
        // P8000590A

        if LastReading.Type = LastReading.Type::"Meter Change" then
            "Average Daily Usage" := LastReading."Average Daily Usage"
        else
            "Average Daily Usage" := Round((Reading - LastReading.Reading) / (Date - LastReading.Date), 0.00001);
        if "Average Daily Usage" < 0 then
            "Average Daily Usage" := 0;
    end;

    procedure CheckTolerance(): Boolean
    var
        MaintSetup: Record "Maintenance Setup";
        PreviousUsage: Record "Asset Usage";
        PreviousUsage2: Record "Asset Usage";
        NextUsage: Record "Asset Usage";
    begin
        // P8000590A
        if (Date = 0D) or (Reading = 0) then
            exit(true);

        MaintSetup.Get;
        if MaintSetup."Asset Usage Tolerance (%)" = 0 then
            exit(true);

        PreviousUsage := Rec;
        PreviousUsage.SetRange("Asset No.", "Asset No.");
        if PreviousUsage.Next(-1) = 0 then
            exit(true);

        if PreviousUsage."Average Daily Usage" = 0 then begin
            PreviousUsage2.Copy(PreviousUsage);
            if PreviousUsage2.Next(-1) = 0 then
                exit(true);
        end;

        MaintSetup."Asset Usage Tolerance (%)" := MaintSetup."Asset Usage Tolerance (%)" / 100;

        if ("Average Daily Usage" < (PreviousUsage."Average Daily Usage" * (1 - MaintSetup."Asset Usage Tolerance (%)"))) or
           ("Average Daily Usage" > (PreviousUsage."Average Daily Usage" * (1 + MaintSetup."Asset Usage Tolerance (%)")))
        then
            exit(false);

        NextUsage := Rec;
        NextUsage.SetRange("Asset No.", "Asset No.");
        if NextUsage.Next = 0 then
            exit(true);

        if NextUsage.Date = Date then
            exit(true);
        NextUsage."Average Daily Usage" := Round((NextUsage.Reading - Reading) / (NextUsage.Date - Date), 0.00001);
        exit((NextUsage."Average Daily Usage" >= ("Average Daily Usage" * (1 - MaintSetup."Asset Usage Tolerance (%)"))) and
             (NextUsage."Average Daily Usage" <= ("Average Daily Usage" * (1 + MaintSetup."Asset Usage Tolerance (%)"))));
    end;
}

