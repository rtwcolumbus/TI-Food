table 37002883 "Data Collection Alert"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW110.0
    // P8008058, To IncreaseT, Jack Reynolds, 07 DEC 16
    //   Expand Closed By field
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Data Collection Alert';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            Editable = false;
        }
        field(2; "Alert Type"; Option)
        {
            Caption = 'Alert Type';
            Editable = false;
            OptionCaption = 'Level 1,Level 2,Missed,Quality';
            OptionMembers = "Level 1","Level 2",Missed,Quality;
        }
        field(10; "Data Element Code"; Code[10])
        {
            Caption = 'Data Element Code';
            Editable = false;
            TableRelation = "Data Collection Data Element";
        }
        field(11; "Data Sheet No."; Code[20])
        {
            Caption = 'Data Sheet No.';
            Editable = false;
        }
        field(12; "Prod. Order Line No."; Integer)
        {
            Caption = 'Prod. Order Line No.';
            Editable = false;
        }
        field(14; "Line No."; Integer)
        {
            Caption = 'Line No.';
            Editable = false;
        }
        field(15; "Source ID"; Integer)
        {
            Caption = 'Source ID';
            Editable = false;
        }
        field(16; "Source Key 1"; Code[20])
        {
            Caption = 'Source Key 1';
            Editable = false;
        }
        field(17; "Source Key 2"; Code[20])
        {
            Caption = 'Source Key 2';
            Editable = false;
        }
        field(18; "Instance No."; Integer)
        {
            Caption = 'Instance No.';
            Editable = false;
        }
        field(21; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Editable = false;
            NotBlank = true;
            TableRelation = Item;
        }
        field(22; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            Editable = false;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(23; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            Editable = false;
            NotBlank = true;
            TableRelation = "Lot No. Information"."Lot No." WHERE("Item No." = FIELD("Item No."),
                                                                   "Variant Code" = FIELD("Variant Code"));
        }
        field(24; "Test No."; Integer)
        {
            Caption = 'Test No.';
            Editable = false;
            TableRelation = "Quality Control Header"."Test No." WHERE("Item No." = FIELD("Item No."),
                                                                       "Variant Code" = FIELD("Variant Code"),
                                                                       "Lot No." = FIELD("Lot No."));
        }
        field(41; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            Editable = false;
            TableRelation = Location;
        }
        field(42; "Alert Group"; Code[10])
        {
            Caption = 'Alert Group';
            Editable = false;
            TableRelation = "Data Collection Alert Group";
        }
        field(43; Critical; Boolean)
        {
            Caption = 'Critical';
            Editable = false;
        }
        field(44; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Open,Closed';
            OptionMembers = Open,Closed;

            trigger OnValidate()
            begin
                if Status <> xRec.Status then
                    case Status of
                        Status::Open:
                            begin
                                "Close Date" := 0D;
                                "Close Time" := 0T;
                                "Close DateTime" := 0DT;
                                "Closed By" := '';
                                Elevated := AlertIsElevated;
                                CreateMyAlerts;
                            end;
                        Status::Closed:
                            begin
                                if Critical and (Comments = '') then
                                    Error(Text001);
                                if ("Close Date" = 0D) or ("Close Time" = 0T) then begin
                                    GetLocation;
                                    "Close DateTime" := CreateDateTime(WorkDate, Time);
                                    TimeZoneMgmt.UTC2DateAndTime("Close DateTime", Location."Time Zone", "Close Date", "Close Time");
                                end;
                                "Closed By" := UserId;
                                Elevated := AlertIsElevated;
                                DeleteMyAlerts;
                            end;
                    end;
            end;
        }
        field(45; "Origination Date"; Date)
        {
            Caption = 'Origination Date';
            Editable = false;
        }
        field(46; "Origination Time"; Time)
        {
            Caption = 'Origination Time';
            Editable = false;
        }
        field(47; "Close Date"; Date)
        {
            Caption = 'Close Date';

            trigger OnValidate()
            begin
                "Close DateTime" := SetDateTime("Close Date", "Close Time");
            end;
        }
        field(48; "Close Time"; Time)
        {
            Caption = 'Close Time';

            trigger OnValidate()
            begin
                "Close DateTime" := SetDateTime("Close Date", "Close Time");
            end;
        }
        field(49; "Closed By"; Code[50])
        {
            Caption = 'Closed By';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(50; Comments; Text[250])
        {
            Caption = 'Comments';
        }
        field(51; Elevated; Boolean)
        {
            Caption = 'Elevated';
            Editable = false;
        }
        field(52; "Origination DateTime"; DateTime)
        {
            Caption = 'Origination DateTime';
        }
        field(53; "Close DateTime"; DateTime)
        {
            Caption = 'Close DateTime';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Data Sheet No.", "Prod. Order Line No.", "Data Element Code", "Line No.", "Source ID", "Source Key 1", "Source Key 2", "Instance No.")
        {
        }
        key(Key3; "Item No.", "Variant Code", "Lot No.", "Test No.", "Data Element Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        DeleteMyAlerts;
        DeleteLinks;
    end;

    trigger OnInsert()
    var
        DataCollectionAlert: Record "Data Collection Alert";
    begin
        DataCollectionAlert.LockTable;
        if DataCollectionAlert.FindLast then;
        "Entry No." := DataCollectionAlert."Entry No." + 1;
        Elevated := AlertIsElevated;

        CreateMyAlerts;
        GetLinks;
    end;

    trigger OnModify()
    var
        DataCollectionSetup: Record "Data Collection Setup";
        DataCollectionAlert: Record "Data Collection Alert";
        AlertGroupMember: Record "Data Coll. Alert Group Member";
        MyAlert: Record "My Alert";
    begin
        DataCollectionAlert.Get("Entry No.");

        if DataCollectionAlert."Alert Type" <> "Alert Type" then begin
            Status := Status::Open;
            "Close Date" := 0D;
            "Close Time" := 0T;
            "Close DateTime" := 0DT;
            "Closed By" := '';
            Comments := '';

            DeleteLinks;
            GetLinks;
        end;

        Elevated := AlertIsElevated;

        if Status = Status::Open then
            if (DataCollectionAlert."Alert Group" <> "Alert Group") or (DataCollectionAlert.Elevated <> Elevated) then begin
                if Elevated then
                    DataCollectionSetup.Get;
                MyAlert.SetCurrentKey("Alert Entry No.");
                MyAlert.SetRange("Alert Entry No.", "Entry No.");
                if MyAlert.FindSet then
                    repeat
                        if not AlertGroupMember.Get("Alert Group", "Location Code", MyAlert."User ID") then
                            if Elevated then begin
                                if not AlertGroupMember.Get(DataCollectionSetup."Critical Alert Group", "Location Code", MyAlert."User ID") then
                                    MyAlert.Delete(true);
                            end else
                                MyAlert.Delete(true);
                    until MyAlert.Next = 0;

                if Elevated then
                    AlertGroupMember.SetFilter("Group Code", '%1|%2', "Alert Group", DataCollectionSetup."Critical Alert Group")
                else
                    AlertGroupMember.SetRange("Group Code", "Alert Group");
                AlertGroupMember.SetRange("Location Code", "Location Code");
                MyAlert."Alert Entry No." := "Entry No.";
                if AlertGroupMember.FindSet then
                    repeat
                        if not MyAlert.Get(AlertGroupMember."User ID", "Entry No.") then begin
                            MyAlert."User ID" := AlertGroupMember."User ID";
                            if MyAlert.Insert(true) then;
                        end;
                    until AlertGroupMember.Next = 0;
            end;
    end;

    var
        Text001: Label 'Critical alerts must have comments.';
        Location: Record Location;
        TimeZoneMgmt: Codeunit "Time Zone Management";

    procedure GetLocation()
    begin
        if Location.Code <> "Location Code" then
            if "Location Code" = '' then
                Clear(Location)
            else
                Location.Get("Location Code");
    end;

    procedure SetDateTime(Date: Date; Time: Time): DateTime
    begin
        if (Date = 0D) or (Time = 0T) then
            exit;

        GetLocation;
        exit(TimeZoneMgmt.CreateUTC(Date, Time, Location."Time Zone"));
    end;

    procedure AlertIsElevated(): Boolean
    var
        DataCollectionSetup: Record "Data Collection Setup";
    begin
        if Critical and ("Alert Type" in ["Alert Type"::"Level 1", "Alert Type"::"Level 2", "Alert Type"::Missed]) then begin
            DataCollectionSetup.Get;
            case Status of
                Status::Open:
                    exit(CurrentDateTime > ("Origination DateTime" + DataCollectionSetup."Critical Alert Response Time"));
                Status::Closed:
                    exit("Close DateTime" > ("Origination DateTime" + DataCollectionSetup."Critical Alert Response Time"));
            end;
        end;
    end;

    procedure CreateMyAlerts()
    var
        DataCollectionSetup: Record "Data Collection Setup";
        AlertGroupMember: Record "Data Coll. Alert Group Member";
        MyAlert: Record "My Alert";
    begin
        if Elevated then begin
            DataCollectionSetup.Get;
            AlertGroupMember.SetFilter("Group Code", '%1|%2', "Alert Group", DataCollectionSetup."Critical Alert Group");
        end else
            AlertGroupMember.SetRange("Group Code", "Alert Group");

        AlertGroupMember.SetRange("Location Code", "Location Code");
        MyAlert."Alert Entry No." := "Entry No.";
        if AlertGroupMember.FindSet then
            repeat
                MyAlert."User ID" := AlertGroupMember."User ID";
                if MyAlert.Insert(true) then;
            until AlertGroupMember.Next = 0;
    end;

    procedure DeleteMyAlerts()
    var
        MyAlert: Record "My Alert";
    begin
        MyAlert.SetCurrentKey("Alert Entry No.");
        MyAlert.SetRange("Alert Entry No.", "Entry No.");
        MyAlert.DeleteAll(true);
    end;

    procedure GetLinks()
    var
        DataSheetHeader: Record "Data Sheet Header";
        DataCollectionLine: Record "Data Collection Line";
        SourceLink: Record "Record Link";
        TargetLink: Record "Record Link";
        RecordRef: RecordRef;
    begin
        if "Alert Type" in ["Alert Type"::"Level 1", "Alert Type"::"Level 2", "Alert Type"::Missed] then begin
            DataSheetHeader.Get("Data Sheet No.");
            DataCollectionLine.SetRange("Source ID", "Source ID");
            DataCollectionLine.SetRange("Source Key 1", "Source Key 1");
            DataCollectionLine.SetRange("Source Key 2", "Source Key 2");
            DataCollectionLine.SetRange(Type, DataSheetHeader.Type);
            DataCollectionLine.SetRange("Data Element Code", "Data Element Code");
            DataCollectionLine.SetRange(Active, true);
            if DataCollectionLine.FindFirst then begin
                RecordRef.GetTable(DataCollectionLine);
                SourceLink.SetCurrentKey("Record ID");
                SourceLink.SetRange("Record ID", RecordRef.RecordId);
                SourceLink.SetRange(Type, SourceLink.Type::Link);
                SourceLink.SetRange(Company, CompanyName);
                // PRW1
                //CASE "Alert Type" OF
                //  "Alert Type"::"Level 1" : SourceLink.SETRANGE("Alert Type",SourceLink."Alert Type"::"1");
                //  "Alert Type"::"Level 2" : SourceLink.SETRANGE("Alert Type",SourceLink."Alert Type"::"2");
                //  "Alert Type"::Missed : SourceLink.SETRANGE("Alert Type",SourceLink."Alert Type"::"3");
                //END;
                // PRW1
                if SourceLink.FindSet then begin
                    RecordRef.GetTable(Rec);
                    repeat
                        if RecordLinkAlertType(SourceLink) = "Alert Type" then begin // PRW1
                            TargetLink := SourceLink;
                            TargetLink."Link ID" := 0;
                            TargetLink."Record ID" := RecordRef.RecordId;
                            TargetLink.Created := CurrentDateTime;
                            TargetLink."User ID" := UserId;
                            TargetLink.Insert;
                        end; // PRW1
                    until SourceLink.Next = 0;
                end;
            end;
        end;
    end;

    local procedure RecordLinkAlertType(RecordLink: Record "Record Link"): Integer
    var
        RecLinkAlertType: Record "Record Link Alert Type";
    begin
        // PRW1
        if RecLinkAlertType.Get(RecordLink."Link ID") then
            exit(RecLinkAlertType."Alert Type");
    end;
}

