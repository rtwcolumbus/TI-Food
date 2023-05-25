table 37002870 "Data Collection Line"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW111.00.01
    // P80037645, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Develop Test UOM/Measuring Method
    // 
    // P80038815, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Certificate of Analysis changes
    // 
    // P80037639, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Develop threshhold results
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    //
    // PRW119.00.03
    // P800139946, To-Increase, Gangabhushan, 24 FEB 22
    //   Copy QC test-templates to Item Quality Tests    
    //
    // PRW119.03
    // P800122712, To Increase, Gangabhushan, 25 MAY 22
    //   Quality Control Samples

    Caption = 'Data Collection Line';

    fields
    {
        field(1; "Source ID"; Integer)
        {
            Caption = 'Source ID';
        }
        field(2; "Source Key 1"; Code[20])
        {
            Caption = 'Source Key 1';
        }
        field(3; "Source Key 2"; Code[20])
        {
            Caption = 'Source Key 2';
        }
        field(4; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,Q/C,Shipping,Receiving,Production,Log';
            OptionMembers = " ","Q/C",Shipping,Receiving,Production,Log;
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
                "Unit of Measure Code" := DataElement."Unit of Measure Code";    // P80037645
                "Measuring Method" := DataElement."Measuring Method";            // P80037645
                SetLineNo;
            end;
        }
        field(6; "Line No."; Integer)
        {
            Caption = 'Line No.';
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
            CalcFormula = Exist("Data Collection Comment" WHERE("Source ID" = FIELD("Source ID"),
                                                                 "Source Key 1" = FIELD("Source Key 1"),
                                                                 "Source Key 2" = FIELD("Source Key 2"),
                                                                 Type = FIELD(Type),
                                                                 "Variant Type" = FIELD("Variant Type"),
                                                                 "Data Element Code" = FIELD("Data Element Code"),
                                                                 "Data Collection Line No." = FIELD("Line No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; Active; Boolean)
        {
            Caption = 'Active';

            trigger OnValidate()
            var
                DataCollectionLine: Record "Data Collection Line";
            begin
                if Active then begin
                    DataCollectionLine.SetRange("Source ID", "Source ID");
                    DataCollectionLine.SetRange("Source Key 1", "Source Key 1");
                    DataCollectionLine.SetRange("Source Key 2", "Source Key 2");
                    DataCollectionLine.SetRange(Type, Type);
                    DataCollectionLine.SetRange("Variant Type", "Variant Type");
                    DataCollectionLine.SetRange("Data Element Code", "Data Element Code");
                    DataCollectionLine.SetFilter("Line No.", '<>%1', "Line No.");
                    DataCollectionLine.SetRange(Active, true);
                    if not DataCollectionLine.IsEmpty then
                        Error(Text004);
                end;
            end;
        }
        field(12; "Source Template Code"; Code[10])
        {
            Caption = 'Source Template Code';
            Editable = false;
            TableRelation = "Data Collection Template";
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
                TestField(Type, Type::Production);
            end;
        }
        field(32; Recurrence; Option)
        {
            Caption = 'Recurrence';
            OptionCaption = 'None,Scheduled,Unscheduled';
            OptionMembers = "None",Scheduled,Unscheduled;

            trigger OnValidate()
            var
                DataCollectionLine1: Record "Data Collection Line";
                DataCollectionLine2: Record "Data Collection Line";
            begin
                if Recurrence <> Recurrence::None then
                    if not (Type in [Type::Production, Type::Log]) then begin
                        DataCollectionLine1.Type := Type::Production;
                        DataCollectionLine2.Type := Type::Log;
                        Error(Text003, FieldCaption(Type), DataCollectionLine1.Type, DataCollectionLine2.Type);
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
        field(119; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            Editable = false;
            TableRelation = "Unit of Measure";
        }
        field(122; "Measuring Method"; Text[50])
        {
            Caption = 'Measuring Method';
            Editable = false;
        }
        field(123; "Threshold on COA"; Boolean)
        {
            Caption = 'Threshold on COA';
        }
        // P800122712
        field(124; "Sample Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Sample Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if Rec."Sample Quantity" > 0 then begin
                    if "Sample Unit of Measure Code" = '' then begin
                        Item.Get("Source Key 1");
                        Validate("Sample Unit of Measure Code", Item."Base Unit of Measure");
                    end;
                    Validate("Combine Samples", true);
                end else begin
                    Validate("Sample Unit of Measure Code", '');
                    Validate("Combine Samples", false);
                end;
            end;
        }
        field(125; "Sample Unit of Measure Code"; Code[10])
        {
            Caption = 'Sample Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Source Key 1"));
            trigger OnValidate()
            var
                Item: Record "Item";
                UnitofMeasure: Record "Unit of Measure";
                UnitofMeasure2: Record "Unit of Measure";
            begin
                if "Sample Unit of Measure Code" <> '' then begin
                    Item.Get("Source Key 1");
                    if Item."Alternate Unit of Measure" = "Sample Unit of Measure Code" then
                        error(AltUOMError, Item.FieldCaption("Alternate Unit of Measure"), Rec.FieldCaption("Sample Unit of Measure Code"));
                    if Item."Alternate Unit of Measure" <> '' then begin
                        UnitofMeasure.Get("Sample Unit of Measure Code");
                        if UnitofMeasure2.Get(Item."Alternate Unit of Measure") then
                            if UnitofMeasure.Type = UnitofMeasure2.Type then
                                Error(AltUOMTypeError, Rec.FieldCaption("Sample Unit of Measure Code"), Item.FieldCaption("Alternate Unit of Measure"));
                    end;
                end;
            end;
        }
        field(126; "Combine Samples"; Boolean)
        {
            Caption = 'Combine Samples';
        }
        // P800122712
    }

    keys
    {
        key(Key1; "Source ID", "Source Key 1", "Source Key 2", Type, "Variant Type", "Data Element Code", "Line No.")
        {
        }
        key(Key2; "Data Element Code")
        {
        }
        key(Key3; "Log Group Code")
        {
        }
        key(Key4; "Source Template Code")
        {

        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        CommentLine.Reset;
        CommentLine.SetRange("Source ID", "Source ID");
        CommentLine.SetRange("Source Key 1", "Source Key 1");
        CommentLine.SetRange("Source Key 2", "Source Key 2");
        CommentLine.SetRange(Type, Type);
        CommentLine.SetRange("Data Element Code", "Data Element Code");
        CommentLine.SetRange("Data Collection Line No.", "Line No.");
        CommentLine.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        if ("Source ID" = DATABASE::Item) and (Type = Type::"Q/C") then begin
            Item.Get("Source Key 1");
            Item.TestField("Item Tracking Code");
            ItemTrackingCode.Get(Item."Item Tracking Code");
            ItemTrackingCode.TestField(ItemTrackingCode."Lot Specific Tracking");
        end;
    end;

    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        DataElement: Record "Data Collection Data Element";
        TempDataCollectionLine: Record "Data Collection Line";
        HideTemplate: Boolean;
        Text000: Label '%1 must not be greater than %2.';
        Text001: Label '%1 must not be less than %2.';
        CommentLine: Record "Data Collection Comment";
        Text003: Label '%1 must be equal to ''%2'' or ''%3''.';
        Text004: Label 'Only one line may be Active.';
        AltUOMError: Label 'Item %1 should not be same as %2'; // P800122712
        AltUOMTypeError: Label '%1 Type should not be same as Item %2 Type'; // P800122712

    procedure SetLineNo()
    var
        DataCollectionLine: Record "Data Collection Line";
    begin
        DataCollectionLine.SetRange("Source ID", "Source ID");
        DataCollectionLine.SetRange("Source Key 1", "Source Key 1");
        DataCollectionLine.SetRange("Source Key 2", "Source Key 2");
        DataCollectionLine.SetRange(Type, Type);
        DataCollectionLine.SetRange("Data Element Code", "Data Element Code");
        if DataCollectionLine.FindLast then begin
            "Line No." := DataCollectionLine."Line No." + 1;
            Active := false;
        end else begin
            "Line No." := 1;
            Active := true;
        end;
    end;

    procedure CopyTemplateLineComments(TemplateLine: Record "Data Collection Template Line")
    var
        DataCollectionComment: Record "Data Collection Comment";
        DataCollectionComment2: Record "Data Collection Comment";
    begin
        DataCollectionComment.SetRange("Source ID", 0);
        DataCollectionComment.SetRange("Source Key 1", TemplateLine."Template Code");
        DataCollectionComment.SetRange("Variant Type", TemplateLine."Variant Type");
        DataCollectionComment.SetRange("Data Element Code", TemplateLine."Data Element Code");
        if DataCollectionComment.FindSet then
            repeat
                DataCollectionComment2.TransferFields(DataCollectionComment);
                DataCollectionComment2."Source ID" := "Source ID";
                DataCollectionComment2."Source Key 1" := "Source Key 1";
                DataCollectionComment2."Source Key 2" := "Source Key 2";
                DataCollectionComment2.Type := Type;
                DataCollectionComment2."Data Collection Line No." := "Line No.";
                DataCollectionComment2.Insert;
            until DataCollectionComment.Next = 0;
    end;

    procedure CopyLineComments(DataCollectionLine: Record "Data Collection Line")
    var
        DataCollectionComment: Record "Data Collection Comment";
        DataCollectionComment2: Record "Data Collection Comment";
    begin
        DataCollectionComment.SetRange("Source ID", DataCollectionLine."Source ID");
        DataCollectionComment.SetRange("Source Key 1", DataCollectionLine."Source Key 1");
        DataCollectionComment.SetRange("Source Key 2", DataCollectionLine."Source Key 2");
        DataCollectionComment.SetRange("Variant Type", DataCollectionLine."Variant Type");
        DataCollectionComment.SetRange("Data Element Code", DataCollectionLine."Data Element Code");
        DataCollectionComment.SetRange("Data Collection Line No.", DataCollectionLine."Line No.");
        if DataCollectionComment.FindSet then
            repeat
                DataCollectionComment2 := DataCollectionComment;
                DataCollectionComment2."Source ID" := "Source ID";
                DataCollectionComment2."Source Key 1" := "Source Key 1";
                DataCollectionComment2."Source Key 2" := "Source Key 2";
                DataCollectionComment2.Type := Type;
                DataCollectionComment2."Variant Type" := "Variant Type";
                DataCollectionComment2."Data Collection Line No." := "Line No.";
                DataCollectionComment2.Insert;
            until DataCollectionComment.Next = 0;
    end;

    procedure CopyTemplateLineLinks(TemplateLine: Record "Data Collection Template Line")
    var
        Source: RecordRef;
    begin
        if not TemplateLine.HasLinks then
            exit;

        Source.GetTable(TemplateLine);
        CopyRecordLinks(Source);
    end;

    procedure CopyLineLinks(DataCollectionLine: Record "Data Collection Line")
    var
        Source: RecordRef;
    begin
        if not DataCollectionLine.HasLinks then
            exit;

        Source.GetTable(DataCollectionLine);
        CopyRecordLinks(Source);
    end;

    local procedure CopyRecordLinks(var Source: RecordRef)
    var
        Target: RecordRef;
        SourceRecordID: RecordID;
        TargetRecordID: RecordID;
        RecordLink: Record "Record Link";
        RecordLink2: Record "Record Link";
    begin
        SourceRecordID := Source.RecordId;
        Target.GetTable(Rec);
        TargetRecordID := Target.RecordId;

        RecordLink.SetRange("Record ID", SourceRecordID);
        RecordLink.SetRange(Type, RecordLink.Type::Link);
        RecordLink.SetRange(Company, CompanyName);
        if RecordLink.FindSet then
            repeat
                RecordLink2 := RecordLink;
                RecordLink2."Link ID" := 0;
                RecordLink2."Record ID" := TargetRecordID;
                RecordLink2.Created := CurrentDateTime;
                RecordLink2."User ID" := UserId;
                RecordLink2.Insert;
            until RecordLink.Next = 0;
    end;

    procedure IsFirstTemplate(): Boolean
    var
        DataCollectionLine: Record "Data Collection Line";
    begin
        // P800139946
        TempDataCollectionLine.Reset();
        TempDataCollectionLine.CopyFilters(Rec);
        TempDataCollectionLine.SetRange("Source Template Code", "Source Template Code");
        if not TempDataCollectionLine.FindFirst() then begin
            DataCollectionLine.CopyFilters(Rec);
            DataCollectionLine.SetRange("Source Template Code", "Source Template Code");
            IF DataCollectionLine.FindFirst then begin
                TempDataCollectionLine := DataCollectionLine;
                TempDataCollectionLine.Insert();
            end;
        end;
        IF "Data Element Code" = TempDataCollectionLine."Data Element Code" then
            exit(true);
    end;

    procedure GetTemplateDesc(): Text[50]
    var
        DataCollectionTemplate: Record "Data Collection Template";
    begin
        // P800139946
        if DataCollectionTemplate.Get("Source Template Code") then
            exit(DataCollectionTemplate.Description);
    end;

    procedure GetTemplateCodeForDisplay(): Text[20]
    var
        BlankText: Label '(Blank)';
    begin
        // P800139946
        if "Source Template Code" = '' then
            exit(BlankText)
        else
            exit("Source Template Code");
    end;

    procedure SamplesEnabled(): Boolean
    var
        Process800QCFunctions: Codeunit "Process 800 Q/C Functions";
    begin
        // P800122712
        exit(Process800QCFunctions.SamplesEnabled());
    end;
}

