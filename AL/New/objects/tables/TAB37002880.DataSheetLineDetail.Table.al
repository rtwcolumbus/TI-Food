table 37002880 "Data Sheet Line Detail"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection

    Caption = 'Data Sheet Line Detail';

    fields
    {
        field(1; "Data Sheet No."; Code[20])
        {
            Caption = 'Data Sheet No.';
        }
        field(2; "Prod. Order Line No."; Integer)
        {
            Caption = 'Prod. Order Line No.';
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
        }
        field(5; "Source ID"; Integer)
        {
            Caption = 'Source ID';
        }
        field(6; "Source Key 1"; Code[20])
        {
            Caption = 'Source Key 1';
        }
        field(7; "Source Key 2"; Code[20])
        {
            Caption = 'Source Key 2';
        }
        field(8; "Instance No."; Integer)
        {
            Caption = 'Instance No.';
        }
        field(10; Type; Option)
        {
            Caption = 'Type';
            Editable = false;
            OptionCaption = ',Q/C,Shipping,Receiving,Production,Log';
            OptionMembers = ,"Q/C",Shipping,Receiving,Production,Log;
        }
        field(20; "Data Element Type"; Option)
        {
            Caption = 'Data Element Type';
            OptionCaption = 'Boolean,Date,Lookup,Numeric,Text';
            OptionMembers = Boolean,Date,"Lookup",Numeric,Text;
        }
        field(21; "Boolean Target Value"; Option)
        {
            Caption = 'Boolean Target Value';
            OptionCaption = ' ,No,Yes';
            OptionMembers = " ",No,Yes;
        }
        field(22; "Lookup Target Value"; Code[10])
        {
            Caption = 'Lookup Target Value';
            TableRelation = "Data Collection Lookup".Code WHERE("Data Element Code" = FIELD("Data Element Code"));
        }
        field(23; "Numeric Target Value"; Decimal)
        {
            Caption = 'Numeric Target Value';
            DecimalPlaces = 0 : 5;
        }
        field(24; "Text Target Value"; Code[50])
        {
            Caption = 'Text Target Value';
        }
        field(25; "Numeric Low-Low Value"; Decimal)
        {
            Caption = 'Numeric Low-Low Value';
            DecimalPlaces = 0 : 5;
        }
        field(26; "Numeric Low Value"; Decimal)
        {
            Caption = 'Numeric Low Value';
            DecimalPlaces = 0 : 5;
        }
        field(27; "Numeric High Value"; Decimal)
        {
            Caption = 'Numeric High Value';
            DecimalPlaces = 0 : 5;
        }
        field(28; "Numeric High-High Value"; Decimal)
        {
            Caption = 'Numeric High-High Value';
            DecimalPlaces = 0 : 5;
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
        }
        field(44; "Grace Period"; Duration)
        {
            Caption = 'Grace Period';
        }
        field(45; Critical; Boolean)
        {
            Caption = 'Critical';
        }
        field(51; "Alert Entry No. (Target)"; Integer)
        {
            Caption = 'Alert Entry No. (Target)';
        }
        field(52; "Alert Entry No. (Missed)"; Integer)
        {
            Caption = 'Alert Entry No. (Missed)';
        }
    }

    keys
    {
        key(Key1; "Data Sheet No.", "Prod. Order Line No.", "Data Element Code", "Line No.", "Source ID", "Source Key 1", "Source Key 2", "Instance No.")
        {
        }
        key(Key2; "Data Sheet No.", "Source ID", "Source Key 1", "Source Key 2")
        {
        }
        key(Key3; "Data Element Code", "Source ID", "Source Key 1", "Source Key 2", Type)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        DataCollectionAlert: Record "Data Collection Alert";
    begin
        if "Alert Entry No. (Target)" <> 0 then begin
            DataCollectionAlert.Get("Alert Entry No. (Target)");
            DataCollectionAlert.Delete(true);
        end;
        if "Alert Entry No. (Missed)" <> 0 then begin
            DataCollectionAlert.Get("Alert Entry No. (Missed)");
            DataCollectionAlert.Delete(true);
        end;
    end;

    var
        DataSheetHeader: Record "Data Sheet Header";
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

    procedure DeleteLineIfNoDetail()
    var
        DataSheetLine: Record "Data Sheet Line";
        DataSheetLineDetail: Record "Data Sheet Line Detail";
    begin
        DataSheetLineDetail.SetRange("Data Sheet No.", "Data Sheet No.");
        DataSheetLineDetail.SetRange("Prod. Order Line No.", "Prod. Order Line No.");
        DataSheetLineDetail.SetRange("Data Element Code", "Data Element Code");
        DataSheetLineDetail.SetRange("Line No.", "Line No.");
        if DataSheetLineDetail.IsEmpty then begin
            DataSheetLine.SetRange("Data Sheet No.", "Data Sheet No.");
            DataSheetLine.SetRange("Prod. Order Line No.", "Prod. Order Line No.");
            DataSheetLine.SetRange("Data Element Code", "Data Element Code");
            DataSheetLine.SetRange("Line No.", "Line No.");
            DataSheetLine.DeleteAll;
        end;
    end;

    procedure TargetValue(): Text[50]
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        exit(DataCollectionMgmt.FormatTargetValue("Data Element Type",
          "Boolean Target Value", "Lookup Target Value", "Text Target Value", "Numeric Target Value"));
    end;

    procedure SetAlert(DataSheetLine: Record "Data Sheet Line")
    var
        DataCollectionAlert: Record "Data Collection Alert";
        SourceType: Integer;
        AlertGroup: Code[10];
        AlertDateTime: DateTime;
        ActualDateTime: DateTime;
    begin
        GetHeader;

        if ("Level 1 Alert Group" <> '') or ("Level 2 Alert Group" <> '') then begin
            if DataSheetLine.Result = '' then begin
                if "Alert Entry No. (Target)" <> 0 then begin
                    DataCollectionAlert.Get("Alert Entry No. (Target)");
                    DataCollectionAlert.Delete(true);
                    "Alert Entry No. (Target)" := 0;
                end;
            end else begin
                SourceType := -1;
                case "Data Element Type" of
                    "Data Element Type"::Boolean:
                        if (("Boolean Target Value" = "Boolean Target Value"::Yes) and (not DataSheetLine."Boolean Result")) or
                           (("Boolean Target Value" = "Boolean Target Value"::No) and DataSheetLine."Boolean Result")
                        then
                            SourceType := DataCollectionAlert."Alert Type"::"Level 2";
                    "Data Element Type"::"Lookup":
                        if DataSheetLine."Lookup Result" <> "Lookup Target Value" then
                            SourceType := DataCollectionAlert."Alert Type"::"Level 2";
                    "Data Element Type"::Numeric:
                        if ("Level 2 Alert Group" <> '') and
                          ((DataSheetLine."Numeric Result" < "Numeric Low-Low Value") or
                            ("Numeric High-High Value" < DataSheetLine."Numeric Result"))
                        then
                            SourceType := DataCollectionAlert."Alert Type"::"Level 2"
                        else
                            if ("Level 1 Alert Group" <> '') and
                         ((DataSheetLine."Numeric Result" < "Numeric Low Value") or
                           ("Numeric High Value" < DataSheetLine."Numeric Result"))
                       then
                                SourceType := DataCollectionAlert."Alert Type"::"Level 1";
                    "Data Element Type"::Text:
                        if DataSheetLine."Text Result" <> "Text Target Value" then
                            SourceType := DataCollectionAlert."Alert Type"::"Level 2";
                end;
                if SourceType <> -1 then begin
                    case SourceType of
                        DataCollectionAlert."Alert Type"::"Level 1":
                            AlertGroup := "Level 1 Alert Group";
                        DataCollectionAlert."Alert Type"::"Level 2":
                            AlertGroup := "Level 2 Alert Group";
                    end;
                    CreateAlert(SourceType, Location, AlertGroup,
                      DataSheetLine."Actual Date", DataSheetLine."Actual Time", DataSheetLine."Actual DateTime", "Alert Entry No. (Target)");
                end else
                    if "Alert Entry No. (Target)" <> 0 then begin
                        DataCollectionAlert.Get("Alert Entry No. (Target)");
                        DataCollectionAlert.Delete(true);
                        "Alert Entry No. (Target)" := 0;
                    end;
            end;
        end;

        if (DataSheetLine.Recurrence = DataSheetLine.Recurrence::Scheduled) and
          (DataSheetLine."Schedule Date" <> 0D) and (DataSheetLine."Schedule Time" <> 0T) and
          ("Missed Collection Alert Group" <> '')
        then begin
            AlertDateTime := DataSheetLine."Schedule DateTime" + "Grace Period";
            if DataSheetLine."Actual DateTime" <> 0DT then
                ActualDateTime := DataSheetLine."Actual DateTime"
            else
                ActualDateTime := CurrentDateTime;
            if AlertDateTime < ActualDateTime then begin
                CreateAlert(DataCollectionAlert."Alert Type"::Missed, Location, "Missed Collection Alert Group",
                  0D, 0T, AlertDateTime, "Alert Entry No. (Missed)");
            end else
                if "Alert Entry No. (Missed)" <> 0 then begin
                    DataCollectionAlert.Get("Alert Entry No. (Missed)");
                    DataCollectionAlert.Delete(true);
                    "Alert Entry No. (Missed)" := 0;
                end;
        end;
    end;

    procedure CreateAlert(SourceType: Integer; Location: Record Location; AlertGroup: Code[10]; OrigDate: Date; OrigTime: Time; OrigDateTime: DateTime; var EntryNo: Integer)
    var
        DataCollectionAlert: Record "Data Collection Alert";
    begin
        if (OrigDate = 0D) or (OrigTime = 0T) then
            TimeZoneMgmt.UTC2DateAndTime(OrigDateTime, Location."Time Zone", OrigDate, OrigTime);
        if EntryNo = 0 then begin
            DataCollectionAlert."Alert Type" := SourceType;
            DataCollectionAlert."Data Element Code" := "Data Element Code";
            DataCollectionAlert."Data Sheet No." := "Data Sheet No.";
            DataCollectionAlert."Prod. Order Line No." := "Prod. Order Line No.";
            DataCollectionAlert."Line No." := "Line No.";
            DataCollectionAlert."Source ID" := "Source ID";
            DataCollectionAlert."Source Key 1" := "Source Key 1";
            DataCollectionAlert."Source Key 2" := "Source Key 2";
            DataCollectionAlert."Instance No." := "Instance No.";
            DataCollectionAlert."Location Code" := Location.Code;
            DataCollectionAlert."Alert Group" := AlertGroup;
            DataCollectionAlert.Critical := Critical;
            DataCollectionAlert.Status := DataCollectionAlert.Status::Open;
            DataCollectionAlert."Origination Date" := OrigDate;
            DataCollectionAlert."Origination Time" := OrigTime;
            DataCollectionAlert."Origination DateTime" := OrigDateTime;
            DataCollectionAlert.Insert(true);
            EntryNo := DataCollectionAlert."Entry No.";
        end else begin
            DataCollectionAlert.Get(EntryNo);
            DataCollectionAlert."Alert Type" := SourceType;
            DataCollectionAlert."Alert Group" := AlertGroup;
            DataCollectionAlert."Origination Date" := OrigDate;
            DataCollectionAlert."Origination Time" := OrigTime;
            DataCollectionAlert."Origination DateTime" := OrigDateTime;
            DataCollectionAlert.Modify(true);
        end;
    end;
}

