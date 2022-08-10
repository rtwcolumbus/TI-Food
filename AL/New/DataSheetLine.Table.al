table 37002879 "Data Sheet Line"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.00.01
    // P8001154, Columbus IT, Jack Reynolds, 28 MAY 13
    //   Enlarge User ID field
    // 
    // PRW111.00.01
    // P80037643, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Develop Test UOM/Measuring Method
    // 
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW111.00.02
    // P80069665,To-Increase, Gangabhushan, 25 JAN 19
    //   TI-12717 - Creating Datasheets in Release Production Order - Will Fail With an Length Issue
    //   Description & Description2 fields length changed to 80
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Data Sheet Line';

    fields
    {
        field(1; "Data Sheet No."; Code[20])
        {
            Caption = 'Data Sheet No.';
            Editable = false;
        }
        field(2; "Prod. Order Line No."; Integer)
        {
            Caption = 'Prod. Order Line No.';
            Editable = false;
        }
        field(3; "Data Element Code"; Code[10])
        {
            Caption = 'Data Element Code';
            Editable = false;
            TableRelation = "Data Collection Data Element";
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
            Editable = false;
        }
        field(5; "Instance No."; Integer)
        {
            Caption = 'Instance No.';
            Editable = false;
        }
        field(6; "Hide Line"; Boolean)
        {
            Caption = 'Hide Line';
        }
        field(10; Type; Option)
        {
            Caption = 'Type';
            Editable = false;
            OptionCaption = ',Q/C,Shipping,Receiving,Production,Log';
            OptionMembers = ,"Q/C",Shipping,Receiving,Production,Log;
        }
        field(11; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(12; "Description 2"; Text[80])
        {
            Caption = 'Description 2';
            Editable = false;
        }
        field(13; "Data Element Type"; Option)
        {
            Caption = 'Data Element Type';
            Editable = false;
            OptionCaption = 'Boolean,Date,Lookup,Numeric,Text';
            OptionMembers = Boolean,Date,"Lookup",Numeric,Text;
        }
        field(21; Recurrence; Option)
        {
            Caption = 'Recurrence';
            Editable = false;
            OptionCaption = 'None,Scheduled,Unscheduled';
            OptionMembers = "None",Scheduled,Unscheduled;
        }
        field(22; Frequency; Duration)
        {
            Caption = 'Frequency';
            Editable = false;
        }
        field(23; "Scheduled Type"; Option)
        {
            Caption = 'Scheduled Type';
            Editable = false;
            OptionCaption = 'Begin,End';
            OptionMembers = "Begin","End";
        }
        field(24; "Schedule Base"; Option)
        {
            Caption = 'Schedule Base';
            Editable = false;
            OptionCaption = 'Schedule,Actual';
            OptionMembers = Schedule,Actual;
        }
        field(31; "Schedule Date"; Date)
        {
            Caption = 'Schedule Date';
            Editable = false;
        }
        field(32; "Schedule Time"; Time)
        {
            Caption = 'Schedule Time';
            Editable = false;
        }
        field(33; "Actual Date"; Date)
        {
            Caption = 'Actual Date';

            trigger OnValidate()
            begin
                if (Result <> '') then
                    TestField("Actual Date");
                CheckLastInstance;
                "Actual Time" := 0T;
            end;
        }
        field(34; "Actual Time"; Time)
        {
            Caption = 'Actual Time';

            trigger OnValidate()
            begin
                if (Result <> '') then
                    TestField("Actual Time");
                CheckLastInstance;
                CheckDateTime;
            end;
        }
        field(35; Result; Code[50])
        {
            Caption = 'Result';

            trigger OnValidate()
            var
                DataSheetLine: Record "Data Sheet Line";
            begin
                if Result = '' then begin
                    Clear("Boolean Result");
                    Clear("Date Result");
                    Clear("Lookup Result");
                    Clear("Numeric Result");
                    Clear("Text Result");
                    Clear("Actual Date");
                    Clear("Actual Time");
                    Clear("Actual DateTime");
                    Clear("User ID");
                end else begin
                    CheckLastInstance;
                    if "Schedule Date" <> 0D then begin
                        "Actual Date" := "Schedule Date";
                        "Actual Time" := "Schedule Time";
                        "Actual DateTime" := SetDateTime("Actual Date", "Actual Time");
                    end else
                        if "Instance No." = 1 then begin
                            if "Prod. Order Line No." = 0 then begin
                                GetHeader;
                                "Actual Date" := DataSheetHeader."Start Date";
                            end else begin
                                DataSheetLine.Get("Data Sheet No.", "Prod. Order Line No.", '', 0, 0);
                                "Actual Date" := DataSheetLine."Actual Date";
                            end;
                            "Actual Time" := 0T;
                        end else begin
                            DataSheetLine.Get("Data Sheet No.", "Prod. Order Line No.", "Data Element Code", "Line No.", "Instance No." - 1);
                            "Actual Date" := DataSheetLine."Actual Date";
                            "Actual Time" := 0T;
                        end;
                    "User ID" := UserId;

                    case "Data Element Type" of
                        "Data Element Type"::Boolean:
                            begin
                                if Result = CopyStr(Text002, 1, StrLen(Result)) then begin
                                    Result := Text002;
                                    Validate("Boolean Result", true);
                                end else
                                    if Result = CopyStr(Text003, 1, StrLen(Result)) then begin
                                        Result := Text002;
                                        Validate("Boolean Result", true);
                                    end else
                                        if Result = CopyStr(Text004, 1, StrLen(Result)) then begin
                                            Result := Text004;
                                            Validate("Boolean Result", false);
                                        end else
                                            if Result = CopyStr(Text005, 1, StrLen(Result)) then begin
                                                Result := Text004;
                                                Validate("Boolean Result", false);
                                            end else
                                                Error(Text006);
                            end;

                        "Data Element Type"::Date:
                            if Evaluate("Date Result", Result) then begin
                                Validate("Date Result");
                                Result := Format("Date Result");
                            end else
                                Error(Text007);

                        "Data Element Type"::"Lookup":
                            Validate("Lookup Result", Result);

                        "Data Element Type"::Numeric:
                            if Evaluate("Numeric Result", Result) then begin
                                Validate("Numeric Result");
                                Result := Format("Numeric Result");
                            end else
                                Error(Text008);

                        "Data Element Type"::Text:
                            Validate("Text Result", Result);
                    end;
                end;
            end;
        }
        field(36; "Boolean Result"; Boolean)
        {
            Caption = 'Boolean Result';
        }
        field(37; "Date Result"; Date)
        {
            Caption = 'Date Result';
        }
        field(38; "Lookup Result"; Code[10])
        {
            Caption = 'Lookup Result';

            trigger OnValidate()
            var
                DataCollectionLookup: Record "Data Collection Lookup";
            begin
                if "Lookup Result" <> '' then
                    DataCollectionLookup.Get("Data Element Code", "Lookup Result");
            end;
        }
        field(39; "Numeric Result"; Decimal)
        {
            Caption = 'Numeric Result';
            DecimalPlaces = 0 : 5;
        }
        field(40; "Text Result"; Code[50])
        {
            Caption = 'Text Result';
        }
        field(41; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
        }
        field(42; "Stop Date"; Date)
        {
            Caption = 'Stop Date';
        }
        field(43; "Stop Time"; Time)
        {
            Caption = 'Stop Time';
        }
        field(44; "Schedule DateTime"; DateTime)
        {
            Caption = 'Schedule DateTime';
            Editable = false;

            trigger OnValidate()
            begin
                GetHeader;
                TimeZoneMgmt.UTC2DateAndTime("Schedule DateTime", Location."Time Zone", "Schedule Date", "Schedule Time");
            end;
        }
        field(45; "Actual DateTime"; DateTime)
        {
            Caption = 'Actual DateTime';
            Editable = false;

            trigger OnValidate()
            begin
                GetHeader;
                TimeZoneMgmt.UTC2DateAndTime("Actual DateTime", Location."Time Zone", "Actual Date", "Actual Time");
            end;
        }
        field(46; "Stop DateTime"; DateTime)
        {
            Caption = 'Stop DateTime';
            Editable = false;

            trigger OnValidate()
            begin
                GetHeader;
                TimeZoneMgmt.UTC2DateAndTime("Stop DateTime", Location."Time Zone", "Stop Date", "Stop Time");
            end;
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
    }

    keys
    {
        key(Key1; "Data Sheet No.", "Prod. Order Line No.", "Data Element Code", "Line No.", "Instance No.")
        {
        }
        key(Key2; "Data Sheet No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        DataSheetLineDetail: Record "Data Sheet Line Detail";
    begin
        DataSheetLineDetail.SetRange("Data Sheet No.", "Data Sheet No.");
        DataSheetLineDetail.SetRange("Prod. Order Line No.", "Prod. Order Line No.");
        DataSheetLineDetail.SetRange("Data Element Code", "Data Element Code");
        DataSheetLineDetail.SetRange("Line No.", "Line No.");
        DataSheetLineDetail.SetRange("Instance No.", "Instance No.");
        DataSheetLineDetail.DeleteAll(true);
    end;

    trigger OnModify()
    var
        DataSheetLine: Record "Data Sheet Line";
    begin
        if Result = '' then begin
            DataSheetLine.SetRange("Data Sheet No.", "Data Sheet No.");
            DataSheetLine.SetRange("Prod. Order Line No.", "Prod. Order Line No.");
            DataSheetLine.SetRange("Data Element Code", "Data Element Code");
            DataSheetLine.SetRange("Line No.", "Line No.");
            DataSheetLine.SetFilter("Instance No.", '>%1', "Instance No.");
            DataSheetLine.DeleteAll(true);
        end else begin
            TestField("Actual Date");
            TestField("Actual Time");
        end;

        CreateAlerts;
        CreateNextInstance;
    end;

    var
        DataSheetHeader: Record "Data Sheet Header";
        Text001: Label 'Actual date and time must not be before start date and time of the data sheet.';
        Text002: Label 'YES';
        Text003: Label 'TRUE';
        Text004: Label 'NO';
        Text005: Label 'FALSE';
        Text006: Label 'Result must be YES or NO.';
        Text007: Label 'Result must be a date.';
        Text008: Label 'Result must be numeric.';
        Text009: Label 'Actual date and time must not be before date and time of the previous result.';
        Text010: Label 'Only the last result may be changed.';
        Text011: Label 'Actual date and time must not be before start date and time of the production order line.';
        Location: Record Location;
        TimeZoneMgmt: Codeunit "Time Zone Management";

    procedure GetHeader()
    begin
        if DataSheetHeader."No." <> "Data Sheet No." then begin
            DataSheetHeader.Get("Data Sheet No.");
            if DataSheetHeader."Location Code" <> Location.Code then
                if DataSheetHeader."Location Code" = '' then
                    Clear(Location)
                else
                    Location.Get(DataSheetHeader."Location Code");
        end;
    end;

    procedure SetSchedule(PrevSchedDateTime: DateTime; ActualDateTime: DateTime)
    var
        ScheduleDateTime: DateTime;
    begin
        if Recurrence = Recurrence::Scheduled then begin
            if "Instance No." = 1 then begin
                case "Scheduled Type" of
                    "Scheduled Type"::"Begin":
                        Validate("Schedule DateTime", ActualDateTime);
                    "Scheduled Type"::"End":
                        Validate("Schedule DateTime", ActualDateTime + Frequency);
                end;
            end else begin
                case "Schedule Base" of
                    "Schedule Base"::Schedule:
                        Validate("Schedule DateTime", PrevSchedDateTime + Frequency);
                    "Schedule Base"::Actual:
                        Validate("Schedule DateTime", ActualDateTime + Frequency);
                end;
            end;
        end;
    end;

    procedure SetDateTime(Date: Date; Time: Time): DateTime
    begin
        GetHeader;
        exit(TimeZoneMgmt.CreateUTC(Date, Time, Location."Time Zone"));
    end;

    procedure CheckLastInstance()
    var
        DataSheetLine: Record "Data Sheet Line";
    begin
        if Recurrence <> Recurrence::None then
            if DataSheetLine.Get("Data Sheet No.", "Prod. Order Line No.", "Data Element Code", "Line No.", "Instance No." + 1) then
                Error(Text010);
    end;

    procedure CheckDateTime()
    var
        DataSheetLine: Record "Data Sheet Line";
    begin
        if ("Actual Date" = 0D) or ("Actual Time" = 0T) then
            exit;

        GetHeader;
        "Actual DateTime" := SetDateTime("Actual Date", "Actual Time");

        if "Instance No." = 1 then begin
            if "Prod. Order Line No." = 0 then begin
                if "Actual DateTime" < DataSheetHeader."Start DateTime" then
                    Error(Text001);
            end else begin
                DataSheetLine.Get("Data Sheet No.", "Prod. Order Line No.", '', 0, 0);
                if "Actual DateTime" < DataSheetLine."Actual DateTime" then
                    Error(Text011);
            end;
        end else begin
            DataSheetLine.Get("Data Sheet No.", "Prod. Order Line No.", "Data Element Code", "Line No.", "Instance No." - 1);
            if "Actual DateTime" < DataSheetLine."Actual DateTime" then
                Error(Text009);
        end;
    end;

    procedure CreateAlerts()
    var
        DataSheetLineDetail: Record "Data Sheet Line Detail";
        AlertEntryNoTarget: Integer;
        AlertEntryNoMissed: Integer;
    begin
        DataSheetLineDetail.SetRange("Data Sheet No.", "Data Sheet No.");
        DataSheetLineDetail.SetRange("Data Element Code", "Data Element Code");
        DataSheetLineDetail.SetRange("Prod. Order Line No.", "Prod. Order Line No.");
        DataSheetLineDetail.SetRange("Line No.", "Line No.");
        DataSheetLineDetail.SetRange("Instance No.", "Instance No.");
        if DataSheetLineDetail.FindSet(true, false) then
            repeat
                AlertEntryNoTarget := DataSheetLineDetail."Alert Entry No. (Target)";
                AlertEntryNoMissed := DataSheetLineDetail."Alert Entry No. (Missed)";
                DataSheetLineDetail.SetAlert(Rec);
                if (AlertEntryNoTarget <> DataSheetLineDetail."Alert Entry No. (Target)") or
                  (AlertEntryNoMissed <> DataSheetLineDetail."Alert Entry No. (Missed)")
                then
                    DataSheetLineDetail.Modify;
            until DataSheetLineDetail.Next = 0;
    end;

    procedure CreateNextInstance()
    var
        DataSheetLine: Record "Data Sheet Line";
        DataSheetLineDetail: Record "Data Sheet Line Detail";
        DataSheetLineDetail2: Record "Data Sheet Line Detail";
    begin
        if (Result <> '') and (Recurrence > Recurrence::None) then begin
            DataSheetLine := Rec;
            DataSheetLine."Instance No." += 1;
            DataSheetLine.Validate(Result, '');
            DataSheetLine.SetSchedule("Schedule DateTime", "Actual DateTime");

            DataSheetLineDetail.SetRange("Data Sheet No.", "Data Sheet No.");
            DataSheetLineDetail.SetRange("Data Element Code", "Data Element Code");
            DataSheetLineDetail.SetRange("Prod. Order Line No.", "Prod. Order Line No.");
            DataSheetLineDetail.SetRange("Line No.", "Line No.");
            DataSheetLineDetail.SetRange("Instance No.", "Instance No.");
            if DataSheetLineDetail.FindSet then
                repeat
                    DataSheetLineDetail2 := DataSheetLineDetail;
                    DataSheetLineDetail2."Instance No." += 1;
                    DataSheetLineDetail2."Alert Entry No. (Target)" := 0;
                    DataSheetLineDetail2."Alert Entry No. (Missed)" := 0;
                    DataSheetLineDetail2.Insert;
                until DataSheetLineDetail.Next = 0;

            DataSheetLine.CreateAlerts;
            DataSheetLine.Insert;
        end;
    end;
}

