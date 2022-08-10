table 37002490 "Production Sequencing"
{
    // PRW16.00.04
    // P8000889, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Source table (temporary) for the Production Sequencing page
    // 
    // P8000898, Columbus IT, Jack Reynolds, 14 FEB 11
    //   Add additional fields for Daily Propduciton Plan report
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Production Sequencing';
    ReplicateData = false;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Equipment Entry No."; Integer)
        {
            Caption = 'Equipment Entry No.';
            DataClassification = SystemMetadata;
        }
        field(3; Level; Integer)
        {
            Caption = 'Level';
            DataClassification = SystemMetadata;
        }
        field(4; "No. Of Entries"; Integer)
        {
            Caption = 'No. Of Entries';
            DataClassification = SystemMetadata;
        }
        field(5; "Sequence No."; Integer)
        {
            Caption = 'Sequence No.';
            DataClassification = SystemMetadata;
        }
        field(11; "Equipment Code"; Code[20])
        {
            Caption = 'Equipment Code';
            DataClassification = SystemMetadata;
        }
        field(12; Type; Option)
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
            OptionCaption = ' ,Event,Order';
            OptionMembers = " ","Event","Order";
        }
        field(13; "Event Code"; Code[10])
        {
            Caption = 'Event Code';
            DataClassification = SystemMetadata;
            TableRelation = "Production Planning Event";
        }
        field(14; "Order Status"; Option)
        {
            Caption = 'Order Status';
            DataClassification = SystemMetadata;
            OptionCaption = ' ,,Firm Planned,Released';
            OptionMembers = " ",,"Firm Planned",Released;
        }
        field(15; "Order No."; Code[20])
        {
            Caption = 'Order No.';
            DataClassification = SystemMetadata;
        }
        field(16; "Order Type"; Option)
        {
            Caption = 'Order Type';
            DataClassification = SystemMetadata;
            OptionCaption = ' ,Batch,Package';
            OptionMembers = " ",Batch,Package;
        }
        field(17; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
        }
        field(18; "Resource Group"; Code[20])
        {
            Caption = 'Resource Group';
            DataClassification = SystemMetadata;
        }
        field(21; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }
        field(22; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = SystemMetadata;
        }
        field(23; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
            DataClassification = SystemMetadata;
        }
        field(24; "First Line Duration"; Duration)
        {
            Caption = 'First Line Duration';
            DataClassification = SystemMetadata;
        }
        field(31; "Starting Date-Time"; DateTime)
        {
            Caption = 'Starting Date-Time';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                "Starting Time" := DT2Time("Starting Date-Time");
                if "Ending Date-Time" <> 0DT then
                    "Duration (Hours)" := Round(("Ending Date-Time" - "Starting Date-Time") / 3600000, 0.001);
            end;
        }
        field(32; "Starting Time"; Time)
        {
            Caption = 'Starting Time';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                Duration: Duration;
            begin
                Duration := "Ending Date-Time" - "Starting Date-Time";
                "Starting Date-Time" := CreateDateTime(DT2Date("Starting Date-Time"), "Starting Time");
                Validate("Ending Date-Time", "Starting Date-Time" + Duration);
            end;
        }
        field(33; "Ending Date-Time"; DateTime)
        {
            Caption = 'Ending Date-Time';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                "Ending Time" := DT2Time("Ending Date-Time");
                if "Starting Date-Time" <> 0DT then
                    "Duration (Hours)" := Round(("Ending Date-Time" - "Starting Date-Time") / 3600000, 0.001);
            end;
        }
        field(34; "Ending Time"; Time)
        {
            Caption = 'Ending Time';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                Duration: Duration;
            begin
                Duration := "Ending Date-Time" - "Starting Date-Time";
                "Ending Date-Time" := CreateDateTime(DT2Date("Ending Date-Time"), "Ending Time");
                Validate("Starting Date-Time", "Ending Date-Time" - Duration);
            end;
        }
        field(35; "Duration (Hours)"; Decimal)
        {
            Caption = 'Duration (Hours)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 3;
            MinValue = 0;

            trigger OnValidate()
            begin
                Validate("Ending Date-Time", "Starting Date-Time" + "Duration (Hours)" * 3600000);
            end;
        }
        field(36; "Total Time (Hours)"; Decimal)
        {
            Caption = 'Total Time (Hours)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 3;
        }
        field(37; "Earliest Starting Time"; Time)
        {
            Caption = 'Earliest Starting Time';
            DataClassification = SystemMetadata;
        }
        field(38; "Latest Starting Time"; Time)
        {
            Caption = 'Latest Starting Time';
            DataClassification = SystemMetadata;
        }
        field(39; "No. of Batches"; Integer)
        {
            Caption = 'No. of Batches';
            DataClassification = SystemMetadata;
        }
        field(40; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
        }
        field(41; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = SystemMetadata;
        }
        field(101; Timeline; BLOB)
        {
            Caption = 'Timeline';
            DataClassification = SystemMetadata;
            SubType = Bitmap;
        }
        field(102; Overlap; Boolean)
        {
            Caption = 'Overlap';
            DataClassification = SystemMetadata;
        }
        field(103; "Starting Time Issues"; Integer)
        {
            Caption = 'Starting Time Issues';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Equipment Code", Type, "Event Code", "Order Status", "Order No.", "Line No.")
        {
        }
        key(Key3; "Equipment Code", Level, "Starting Date-Time", "Ending Date-Time")
        {
        }
        key(Key4; "Resource Group", "Equipment Code", Level, "Sequence No.", "Starting Date-Time", "Ending Date-Time")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label '%1 Order %2';

    procedure SetDescription()
    var
        Resource: Record Resource;
        ProdEvent: Record "Production Planning Event";
    begin
        case Type of
            Type::" ":
                begin
                    Resource.Get("Equipment Code");
                    Description := Resource.Name;
                end;
            Type::"Event":
                begin
                    ProdEvent.Get("Event Code");
                    Description := ProdEvent.Description;
                end;
            Type::Order:
                Description := StrSubstNo(Text001, "Order Status", "Order No.");
        end;
    end;

    procedure EarliestLatestStart(): Text[30]
    begin
        if "Earliest Starting Time" <> 0T then
            exit('> ' + Format("Earliest Starting Time", 0, '<Hours24,2><Filler,0>:<Minutes,2>'));
        if "Latest Starting Time" <> 0T then
            exit('< ' + Format("Latest Starting Time", 0, '<Hours24,2><Filler,0>:<Minutes,2>'));
    end;

    procedure StartTimeIssue(): Boolean
    begin
        exit((("Earliest Starting Time" <> 0T) and ("Starting Time" < "Earliest Starting Time")) or
             (("Latest Starting Time" <> 0T) and ("Latest Starting Time" < "Starting Time")));
    end;

    procedure ShowOrder()
    var
        ProdOrder: Record "Production Order";
        FirmPlannedOrder: Page "Firm Planned Prod. Order";
        ReleasedOrder: Page "Released Production Order";
    begin
        if Type = Type::Order then begin
            FilterGroup(9);
            ProdOrder.SetRange(Status, "Order Status");
            ProdOrder.SetRange("No.", "Order No.");
            FilterGroup(0);
            case "Order Status" of
                "Order Status"::"Firm Planned":
                    begin
                        FirmPlannedOrder.Editable(false);
                        FirmPlannedOrder.SetTableView(ProdOrder);
                        FirmPlannedOrder.RunModal;
                    end;
                "Order Status"::Released:
                    begin
                        ReleasedOrder.Editable(false);
                        ReleasedOrder.SetTableView(ProdOrder);
                        ReleasedOrder.RunModal;
                    end;
            end;
        end;
    end;
}

