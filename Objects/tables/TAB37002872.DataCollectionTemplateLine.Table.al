table 37002872 "Data Collection Template Line"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    //
    // PRW119.03
    // P800122712, To Increase, Gangabhushan, 25 MAY 22
    //   Quality Control Samples

    Caption = 'Data Collection Template Line';

    fields
    {
        field(1; "Template Code"; Code[10])
        {
            Caption = 'Template Code';
            TableRelation = "Data Collection Template";
        }
        field(5; "Data Element Code"; Code[10])
        {
            Caption = 'Data Element Code';
            NotBlank = true;
            TableRelation = "Data Collection Data Element";

            trigger OnValidate()
            begin
                if "Data Element Code" <> xRec."Data Element Code" then
                    Init;

                DataElement.Get("Data Element Code");
                Description := DataElement.Description;
                "Description 2" := DataElement."Description 2";
                "Data Element Type" := DataElement.Type;
            end;
        }
        field(7; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(8; "Description 2"; Text[30])
        {
            Caption = 'Description 2';
        }
        field(9; "Data Element Type"; Option)
        {
            Caption = 'Data Element Type';
            Editable = false;
            OptionCaption = 'Boolean,Date,Lookup,Numeric,Text';
            OptionMembers = Boolean,Date,"Lookup",Numeric,Text;
        }
        field(10; Comment; Boolean)
        {
            CalcFormula = Exist("Data Collection Comment" WHERE("Source ID" = CONST(0),
                                                                 "Source Key 1" = FIELD("Template Code"),
                                                                 "Variant Type" = FIELD("Variant Type"),
                                                                 "Data Element Code" = FIELD("Data Element Code")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(21; "Boolean Target Value"; Option)
        {
            Caption = 'Boolean Target Value';
            OptionCaption = ' ,No,Yes';
            OptionMembers = " ",No,Yes;

            trigger OnValidate()
            begin
                TestField("Data Element Type", "Data Element Type"::Boolean);
            end;
        }
        field(22; "Lookup Target Value"; Code[10])
        {
            Caption = 'Lookup Target Value';
            TableRelation = IF ("Data Element Type" = CONST("Lookup")) "Data Collection Lookup".Code WHERE("Data Element Code" = FIELD("Data Element Code"));

            trigger OnValidate()
            begin
                TestField("Data Element Type", "Data Element Type"::"Lookup");
            end;
        }
        field(23; "Numeric Target Value"; Decimal)
        {
            Caption = 'Numeric Target Value';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                TestField("Data Element Type", "Data Element Type"::Numeric);
                if "Numeric Target Value" < "Numeric Low Value" then
                    Error(Text001, FieldCaption("Numeric Target Value"), FieldCaption("Numeric Low Value"));
                if "Numeric Target Value" > "Numeric High Value" then
                    Error(Text000, FieldCaption("Numeric Target Value"), FieldCaption("Numeric High Value"));
            end;
        }
        field(24; "Text Target Value"; Code[50])
        {
            Caption = 'Text Target Value';

            trigger OnValidate()
            begin
                TestField("Data Element Type", "Data Element Type"::Text);
            end;
        }
        field(25; "Numeric Low-Low Value"; Decimal)
        {
            Caption = 'Numeric Low-Low Value';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                TestField("Data Element Type", "Data Element Type"::Numeric);
                if "Numeric Low-Low Value" > "Numeric Low Value" then
                    Error(Text000, FieldCaption("Numeric Low-Low Value"), FieldCaption("Numeric Low Value"));
            end;
        }
        field(26; "Numeric Low Value"; Decimal)
        {
            Caption = 'Numeric Low Value';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                TestField("Data Element Type", "Data Element Type"::Numeric);
                if "Numeric Low Value" > "Numeric Target Value" then
                    Error(Text000, FieldCaption("Numeric Low Value"), FieldCaption("Numeric Target Value"));
                if "Numeric Low Value" > "Numeric High Value" then
                    Error(Text000, FieldCaption("Numeric Low Value"), FieldCaption("Numeric High Value"));

                if xRec."Numeric Low Value" = xRec."Numeric Low-Low Value" then
                    "Numeric Low-Low Value" := "Numeric Low Value";
            end;
        }
        field(27; "Numeric High Value"; Decimal)
        {
            Caption = 'Numeric High Value';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                TestField("Data Element Type", "Data Element Type"::Numeric);
                if "Numeric High Value" < "Numeric Target Value" then
                    Error(Text001, FieldCaption("Numeric High Value"), FieldCaption("Numeric Target Value"));
                if "Numeric High Value" < "Numeric Low Value" then
                    Error(Text001, FieldCaption("Numeric High Value"), FieldCaption("Numeric Low Value"));
            end;
        }
        field(28; "Numeric High-High Value"; Decimal)
        {
            Caption = 'Numeric High-High Value';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                TestField("Data Element Type", "Data Element Type"::Numeric);
                if "Numeric High-High Value" < "Numeric High Value" then
                    Error(Text001, FieldCaption("Numeric High-High Value"), FieldCaption("Numeric High Value"));

                if xRec."Numeric High Value" = xRec."Numeric High-High Value" then
                    "Numeric High Value" := "Numeric High-High Value";
            end;
        }
        field(31; "Order or Line"; Option)
        {
            Caption = 'Order or Line';
            OptionCaption = 'Order,Line';
            OptionMembers = "Order",Line;

            trigger OnValidate()
            begin
                DataCollectionTemplate.Get("Template Code");
                DataCollectionTemplate.TestField(DataCollectionTemplate.Type, DataCollectionTemplate.Type::Production);
            end;
        }
        field(32; Recurrence; Option)
        {
            Caption = 'Recurrence';
            OptionCaption = 'None,Scheduled,Unscheduled';
            OptionMembers = "None",Scheduled,Unscheduled;

            trigger OnValidate()
            var
                DataCollectionTemplate1: Record "Data Collection Template";
                DataCollectionTemplate2: Record "Data Collection Template";
            begin
                if Recurrence <> Recurrence::None then begin
                    DataCollectionTemplate.Get("Template Code");
                    if not (DataCollectionTemplate.Type in [DataCollectionTemplate.Type::Production, DataCollectionTemplate.Type::Log]) then begin
                        DataCollectionTemplate1.Type := DataCollectionTemplate1.Type::Production;
                        DataCollectionTemplate2.Type := DataCollectionTemplate2.Type::Log;
                        Error(Text002, DataCollectionTemplate.FieldCaption(Type), DataCollectionTemplate1.Type, DataCollectionTemplate2.Type);
                    end;
                end;

                if Recurrence <> Recurrence::Scheduled then begin
                    Frequency := 0;
                    "Scheduled Type" := "Scheduled Type"::"Begin";
                    "Schedule Base" := "Schedule Base"::Schedule;
                    "Missed Collection Alert Group" := '';
                    "Grace Period" := 0;
                end;
            end;
        }
        field(33; Frequency; Duration)
        {
            Caption = 'Frequency';

            trigger OnValidate()
            begin
                TestField(Recurrence, Recurrence::Scheduled);
            end;
        }
        field(34; "Scheduled Type"; Option)
        {
            Caption = 'Scheduled Type';
            OptionCaption = 'Begin,End';
            OptionMembers = "Begin","End";

            trigger OnValidate()
            begin
                TestField(Recurrence, Recurrence::Scheduled);
            end;
        }
        field(35; "Schedule Base"; Option)
        {
            Caption = 'Schedule Base';
            OptionCaption = 'Schedule,Actual';
            OptionMembers = Schedule,Actual;

            trigger OnValidate()
            begin
                TestField(Recurrence, Recurrence::Scheduled);
            end;
        }
        field(41; "Level 1 Alert Group"; Code[10])
        {
            Caption = 'Level 1 Alert Group';
            TableRelation = "Data Collection Alert Group";
        }
        field(42; "Level 2 Alert Group"; Code[10])
        {
            Caption = 'Level 2 Alert Group';
            TableRelation = "Data Collection Alert Group";
        }
        field(43; "Missed Collection Alert Group"; Code[10])
        {
            Caption = 'Missed Collection Alert Group';
            TableRelation = "Data Collection Alert Group";

            trigger OnValidate()
            begin
                TestField(Recurrence, Recurrence::Scheduled);
            end;
        }
        field(44; "Grace Period"; Duration)
        {
            Caption = 'Grace Period';

            trigger OnValidate()
            begin
                TestField(Recurrence, Recurrence::Scheduled);
            end;
        }
        field(45; Critical; Boolean)
        {
            Caption = 'Critical';
        }
        field(51; "Certificate of Analysis"; Boolean)
        {
            Caption = 'Certificate of Analysis';
        }
        field(52; "Must Pass"; Boolean)
        {
            Caption = 'Must Pass';
        }
        field(53; "Variant Type"; Option)
        {
            Caption = 'Variant Type';
            OptionCaption = 'Item Only,Item and Variant,Variant Only';
            OptionMembers = "Item Only","Item and Variant","Variant Only";
        }
        field(54; "Re-Test Requires Reason Code"; Boolean)
        {
            Caption = 'Re-Test Requires Reason Code';
        }
        field(61; "Log Group Code"; Code[10])
        {
            Caption = 'Log Group Code';
            TableRelation = "Data Collection Log Group";
        }
        // P800122712
        field(62; "Sample Unit of Measure Code"; Code[10])
        {
            Caption = 'Sample Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code;
        }
        field(63; "Sample Quantity"; Decimal)
        {
            Caption = 'Sample Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(64; "Combine Samples"; Boolean)
        {
            Caption = 'Combine Samples';
        }
        // P800122712
    }

    keys
    {
        key(Key1; "Template Code", "Variant Type", "Data Element Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        CommentLine.Reset;
        CommentLine.SetRange("Source ID", 0);
        CommentLine.SetRange("Source Key 1", "Template Code");
        CommentLine.SetRange("Data Element Code", "Data Element Code");
        CommentLine.DeleteAll(true);
    end;

    var
        DataCollectionTemplate: Record "Data Collection Template";
        DataElement: Record "Data Collection Data Element";
        Text000: Label '%1 must not be greater than %2.';
        Text001: Label '%1 must not be less than %2.';
        Text002: Label '%1 must be equal to ''%2'' or ''%3''.';
        CommentLine: Record "Data Collection Comment";

    procedure TargetValue(): Text[50]
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        exit(DataCollectionMgmt.FormatTargetValue("Data Element Type",
          "Boolean Target Value", "Lookup Target Value", "Text Target Value", "Numeric Target Value"));
    end;

    procedure SamplesEnabled(): Boolean
    var
        Process800QCFunctions: Codeunit "Process 800 Q/C Functions";
    begin
        // P800122712
        exit(Process800QCFunctions.SamplesEnabled());
    end;
}

