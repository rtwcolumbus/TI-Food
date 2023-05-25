table 37002542 "Quality Control Line"
{
    // PR1.10, Navision US, John Nozzi, 26 MAR 01, New Object
    //   This table is used enter the results of Quality Control Tests. These are attached to an Item Lot.
    // 
    // PR1.10.01
    //   Add fields
    //     Relate Assigned to to Quality Control Technician
    //     Result - results entered here, validated, and moved to Result-Alpha, -Numeric, and -Boolean
    //     Certificate of Analysis
    //     Alpha Target Value
    //     Boolean Target Value
    // 
    // PR1.10.02
    //   New Field
    //     Must Pass
    // 
    // PR2.00
    //   QC Header
    //   Text Constants
    // 
    // PR3.70.07
    // P8000152A, Myers Nissi, Jack Reynolds, 26 NOV 04
    //   Added support for additional type and combining of Q/C tests with lot specifications
    // 
    // PR4.00.05
    // P8000434A, VerticalSoft, Jack Reynolds, 18 JAN 07
    //   Fix TableRelation for Test Code
    // 
    // PRW16.00.06
    // P8001079, Columbus IT, Jack Reynolds, 15 JUN 12
    //   Support for Reaon Code on re-test
    // 
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.10.02
    // P8001281, Columbus IT, Jack Reynolds, 06 FEB 14
    //   Fix problem adding new comments
    // 
    // PRW111.00.01
    // P80037569, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Develop QC skip logic
    // 
    // P80037637, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Develop threshold results
    // 
    // P80038815, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Certificate of Analysis changes
    // 
    // P80037659, To-Increase, Jack Reynolds, 25 JUL 18
    //   QC-Additions: Develop average measurement
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    //
    // PRW119.03
    // P800122712, To Increase, Gangabhushan, 25 MAY 22
    //   Quality Control Samples

    Caption = 'Quality Control Line';
    DataCaptionFields = "Item No.", "Lot No.";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Editable = false;
            NotBlank = true;
            TableRelation = Item;
        }
        field(2; "Test Code"; Code[10])
        {
            Caption = 'Test Code';
            Editable = false;
            NotBlank = true;
            TableRelation = "Data Collection Data Element";

            trigger OnValidate()
            var
                DataElement: Record "Data Collection Data Element";
            begin
                // P80037659
                if "Test Code" <> '' then begin
                    DataElement.Get("Test Code");
                    "Unit of Measure Code" := DataElement."Unit of Measure Code";
                    "Measuring Method" := DataElement."Measuring Method";
                end;
                // P80037659
            end;
        }
        field(3; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            Editable = false;
            NotBlank = true;
            TableRelation = "Lot No. Information"."Lot No." WHERE("Item No." = FIELD("Item No."),
                                                                   "Variant Code" = FIELD("Variant Code"));
        }
        field(9; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(10; Type; Option)
        {
            Caption = 'Type';
            Editable = false;
            OptionCaption = 'Boolean,Date,Lookup,Numeric,Text';
            OptionMembers = Boolean,Date,"Lookup",Numeric,Text;
        }
        field(11; "Numeric Low Value"; Decimal)
        {
            Caption = 'Numeric Low Value';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(12; "Numeric High Value"; Decimal)
        {
            Caption = 'Numeric High Value';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(13; "Numeric Target Value"; Decimal)
        {
            Caption = 'Numeric Target Value';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(14; "Text Result"; Code[50])
        {
            Caption = 'Text Result';
            Description = 'PR1.10.01';
            Editable = false;

            trigger OnValidate()
            begin
                // P8000152A
                if ("Text Target Value" <> '') and ("Text Result" = "Text Target Value") then
                    Validate(Status, Status::Pass)
                else
                    Validate(Status, Status::Fail);
                // P8000152A
            end;
        }
        field(15; "Numeric Result"; Decimal)
        {
            Caption = 'Numeric Result';
            DecimalPlaces = 0 : 5;
            Description = 'PR1.10.01';
            Editable = false;

            trigger OnValidate()
            begin
                // P80037637
                if (("Numeric Result" >= "Numeric Low Value") and ("Numeric Result" < "Numeric Higher-Low Value")) or
                  (("Numeric Result" > "Numeric Lower-High Value") and ("Numeric Result" <= "Numeric High Value"))
                then
                    Validate(Status, Status::Suspended)
                else
                    // P80037637
                    // PR1.10.01 Begin
                    if ("Numeric Low Value" <= "Numeric Result") and ("Numeric Result" <= "Numeric High Value") then
                        Validate(Status, Status::Pass)
                    else
                        Validate(Status, Status::Fail);
                // PR1.10.01 End
            end;
        }
        field(16; "Boolean Result"; Boolean)
        {
            Caption = 'Boolean Result';
            Description = 'PR1.10.01';
            Editable = false;

            trigger OnValidate()
            begin
                // P8000152A
                if (("Boolean Target Value" = "Boolean Target Value"::Yes) and "Boolean Result") or
                   (("Boolean Target Value" = "Boolean Target Value"::No) and (not "Boolean Result"))
                then
                    Validate(Status, Status::Pass)
                else
                    Validate(Status, Status::Fail);
                // P8000152A
            end;
        }
        field(17; "Test Date"; Date)
        {
            Caption = 'Test Date';
        }
        field(18; "Test Time"; Time)
        {
            Caption = 'Test Time';
        }
        field(19; "Tested By"; Code[10])
        {
            Caption = 'Tested By';
            TableRelation = "Quality Control Technician";
        }
        field(20; Status; Option)
        {
            Caption = 'Status';
            Description = 'PR1.10.01';
            OptionCaption = 'Not Tested,Pass,Fail,Skip,Suspended';
            OptionMembers = "Not Tested",Pass,Fail,Skip,Suspended;

            trigger OnValidate()
            begin
                // PR1.10.01 Begin
                if Status in [Status::Pass, Status::Fail] then
                    TestField(Result);
                // PR1.10.01 End
            end;
        }
        field(21; Complete; Boolean)
        {
            Caption = 'Complete';
            Editable = false;
        }
        field(22; Result; Code[50])
        {
            Caption = 'Result';
            Description = 'PR1.10.01';

            trigger OnValidate()
            begin
                // PR1.10.01 Begin
                if Result = '' then begin
                    Clear("Text Result");
                    Clear("Numeric Result");
                    Clear("Boolean Result");
                    Clear("Date Result"); // P8000152A
                    Clear("Lookup Result"); // P8000152A
                    Clear("Tested By");
                    Clear("Test Date");
                    Clear("Test Time");
                    Validate(Status, Status::"Not Tested");
                end else begin
                    if QCHeader.Get("Item No.", "Variant Code", "Lot No.", "Test No.") then begin // P80037659
                        "Tested By" := QCHeader."Assigned To";
                        "Test Date" := WorkDate;
                        "Test Time" := Time;
                    end;                                                                       // P80037659
                                                                                               // P8000152A Begin
                    case Type of
                        Type::Boolean:
                            begin
                                if Result = CopyStr(Text000, 1, StrLen(Result)) then begin
                                    Result := Text000;
                                    Validate("Boolean Result", true);
                                end else
                                    if Result = CopyStr(Text004, 1, StrLen(Result)) then begin
                                        Result := Text004;
                                        Validate("Boolean Result", false);
                                    end else
                                        if Result = CopyStr(Text002, 1, StrLen(Result)) then begin
                                            Result := Text000;
                                            Validate("Boolean Result", true);
                                        end else
                                            if Result = CopyStr(Text006, 1, StrLen(Result)) then begin
                                                Result := Text004;
                                                Validate("Boolean Result", false);
                                            end else
                                                Error(Text008);
                            end;

                        Type::Date:
                            if Evaluate("Date Result", Result) then begin
                                Validate("Date Result");
                                Result := Format("Date Result");
                            end else
                                Error(Text010);

                        Type::"Lookup":
                            Validate("Lookup Result", Result);

                        Type::Text:
                            Validate("Text Result", Result);

                        Type::Numeric:
                            if Evaluate("Numeric Result", Result) then
                                Validate("Numeric Result")
                            else
                                Error(Text009);
                    end;
                    // P8000152A End
                end;
                // PR1.10.01 End
            end;
        }
        field(23; "Certificate of Analysis"; Boolean)
        {
            Caption = 'Certificate of Analysis';
            Description = 'PR1.10.01';
        }
        field(24; Comment; Boolean)
        {
            CalcFormula = Exist("Data Collection Comment" WHERE("Source ID" = CONST(27),
                                                                 "Source Key 1" = FIELD("Item No."),
                                                                 Type = CONST("Q/C"),
                                                                 "Data Element Code" = FIELD("Test Code"),
                                                                 "Data Collection Line No." = FIELD("Line No.")));
            Caption = 'Comment';
            Description = 'PR1.10.01';
            Editable = false;
            FieldClass = FlowField;
        }
        field(25; "Text Target Value"; Code[50])
        {
            Caption = 'Text Target Value';
            Description = 'PR1.10.01';
            Editable = false;
        }
        field(27; "Must Pass"; Boolean)
        {
            Caption = 'Must Pass';
            Description = 'PR1.10.02';
            Editable = false;
        }
        field(28; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            Description = 'PR2.00';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(29; "Test No."; Integer)
        {
            Caption = 'Test No.';
            Description = 'PR2.00';
            TableRelation = "Quality Control Header"."Test No." WHERE("Item No." = FIELD("Item No."),
                                                                       "Variant Code" = FIELD("Variant Code"),
                                                                       "Lot No." = FIELD("Lot No."));
        }
        field(30; "Boolean Target Value"; Option)
        {
            Caption = 'Boolean Target Value';
            Editable = false;
            OptionCaption = ' ,No,Yes';
            OptionMembers = " ",No,Yes;
        }
        field(31; "Date Result"; Date)
        {
            Caption = 'Date Result';
            Editable = false;
        }
        field(32; "Lookup Result"; Code[10])
        {
            Caption = 'Lookup Result';
            Editable = false;
            TableRelation = IF (Type = CONST("Lookup")) "Data Collection Lookup".Code WHERE("Data Element Code" = FIELD("Test Code"));

            trigger OnValidate()
            var
                LotSpecLookup: Record "Data Collection Lookup";
            begin
                // P8000152A
                if "Lookup Result" <> '' then
                    LotSpecLookup.Get("Test Code", "Lookup Result");
                if ("Lookup Target Value" <> '') and ("Lookup Result" = "Lookup Target Value") then
                    Validate(Status, Status::Pass)
                else
                    Validate(Status, Status::Fail);
            end;
        }
        field(33; "Lookup Target Value"; Code[10])
        {
            Caption = 'Lookup Target Value';
            Editable = false;
            TableRelation = IF (Type = CONST("Lookup")) "Data Collection Lookup".Code WHERE("Data Element Code" = FIELD("Test Code"));
        }
        field(40; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(51; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(61; "Numeric Higher-Low Value"; Decimal)
        {
            Caption = 'Numeric Higher Low Value';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(62; "Numeric Lower-High Value"; Decimal)
        {
            Caption = 'Numeric Lower High Value';
            DecimalPlaces = 0 : 5;
            Editable = false;
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
        field(124; "Averaging Method"; Option)
        {
            Caption = 'Averaging Method';
            OptionCaption = ' ,First,Last,,,,,,Arithmetic,Geometric,Harmonic';
            OptionMembers = " ",First,Last,,,,,,Arithmetic,Geometric,Harmonic;
        }
        // P800122712
        field(125; "Sample Unit of Measure Code"; Code[10])
        {
            Caption = 'Sample Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code;
            Editable = false;
        }
        field(126; "Sample Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Sample Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(127; "Combine Samples"; Boolean)
        {
            Caption = 'Combine Samples';
            Editable = false;
        }
        // P800122712
    }

    keys
    {
        key(Key1; "Item No.", "Variant Code", "Lot No.", "Test No.", "Test Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        QCHeader: Record "Quality Control Header";
        Text000: Label 'YES';
        Text002: Label 'TRUE';
        Text004: Label 'NO';
        Text006: Label 'FALSE';
        Text008: Label 'Result must be YES or NO.';
        Text009: Label 'Result must be numeric.';
        Text010: Label 'Result must be a date.';

    procedure SamplesEnabled(): Boolean
    var
        Process800QCFunctions: Codeunit "Process 800 Q/C Functions";
    begin
        // P800122712
        exit(Process800QCFunctions.SamplesEnabled());
    end;
}

