table 37002819 "Preventive Maintenance Order"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 31 AUG 06
    //   This is the main table to establish repetitive (typically PM) work orders for assets
    // 
    // P8000335A, VerticalSoft, Jack Reynolds, 20 SEP 06
    //   Add fields for material and contract account
    //   Move to work order fields when creating work order
    // 
    // PRW16.00.01
    // P8000725, VerticalSoft, Jack Reynolds, 27 AUG 09
    //   Move Asset Hierarchy to work order when creating work order
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 13 FEB 09
    //   Modified to initialize fields properly for new records
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW17.10
    // P8001215, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Remove Notepad functionality
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW117.3
    // P80096165, To Increase, Jack Reynolds, 02 FEB 21
    //   Rename Comment Lines
    // 
    // PRW119.0
    // P800133109, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 19.0 - Qty. Rounding Precision
    // 
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 26 APR 22
    //   Upgrade to 20.0 - Refactoring for default dimensions
    // 
    // PRW121.2
    // P800163700, To-Increase, Jack Reynolds, 07 FEB 23
    //   Support for Auto-Save as You Work

    Caption = 'Preventive Maintenance Order';
    DataCaptionFields = "Asset No.", "Frequency Code";
    LookupPageID = "Preventive Maintenance Orders";

    fields
    {
        field(1; "Entry No."; Code[20])
        {
            Caption = 'Entry No.';
        }
        field(2; "Asset No."; Code[20])
        {
            Caption = 'Asset No.';
            TableRelation = Asset;

            trigger OnValidate()
            var
                NewRecord: Boolean;
            begin
                if "Entry No." = '' then begin
                    MaintSetup.LockTable;
                    MaintSetup.Get;
                    MaintSetup."Last PM Order No." += 1;
                    MaintSetup.Modify;
                    "Entry No." := Format(MaintSetup."Last PM Order No.");
                    NewRecord := true; // P8000664
                end;

                if ("Asset No." <> xRec."Asset No.") or NewRecord then begin // P8000664
                    TestField("Last Work Order", '');
                    TestField("Current Work Order", '');
                    if "Asset No." <> '' then begin
                        GetAsset;
                        Init;
                        "Asset No." := Asset."No.";
                        MaintSetup.Get;
                        Status := MaintSetup."Default PM Order Status";
                        Priority := MaintSetup."Default PM Priority";
                        CopyAssetDim;
                    end;
                end;
            end;
        }
        field(3; "Group Code"; Code[10])
        {
            Caption = 'Group Code';

            trigger OnValidate()
            begin
                TestField("Asset No.");
            end;
        }
        field(4; "Frequency Code"; Code[10])
        {
            Caption = 'Frequency Code';
            TableRelation = "PM Frequency";

            trigger OnValidate()
            begin
                if "Frequency Code" <> xRec."Frequency Code" then begin
                    TestField("Last Work Order", '');
                    TestField("Current Work Order", '');
                end;

                if "Frequency Code" <> '' then begin
                    TestField("Asset No.");
                    GetFrequency;
                    if Frequency.Type in [Frequency.Type::Usage, Frequency.Type::Combined] then begin
                        Frequency.TestField("Usage Unit of Measure");
                        GetAsset;
                        Asset.TestField("Usage Unit of Measure", Frequency."Usage Unit of Measure");
                    end;
                end else begin
                    "Last PM Date" := 0D;
                    "Last PM Usage" := -1;
                    "Override Date" := 0D;
                end;
            end;
        }
        field(5; "Last PM Date"; Date)
        {
            Caption = 'Last PM Date';

            trigger OnValidate()
            begin
                TestField("Last Work Order", '');
                TestField("Frequency Code");
                if "Last PM Date" <> xRec."Last PM Date" then
                    if "Last PM Date" = 0D then
                        "Last PM Usage" := -1
                    else
                        if "Last PM Usage" <> -1 then
                            MaintMgt.TestUsage("Asset No.", "Last PM Date", "Last PM Usage", true);
            end;
        }
        field(6; "Last PM Usage"; Decimal)
        {
            Caption = 'Last PM Usage';
            DecimalPlaces = 0 : 5;
            InitValue = -1;
            MinValue = 0;

            trigger OnValidate()
            begin
                TestField("Last Work Order", '');
                TestField("Frequency Code");
                TestField("Last PM Date");
                GetFrequency;
                if Frequency.Type = Frequency.Type::Calendar then
                    Frequency.FieldError(Type, StrSubstNo(Text001, Frequency.Type));
                if ("Last PM Usage" <> xRec."Last PM Usage") then
                    MaintMgt.TestUsage("Asset No.", "Last PM Date", "Last PM Usage", true);
            end;
        }
        field(7; "Last Work Order"; Code[20])
        {
            Caption = 'Last Work Order';
            Editable = false;
            TableRelation = "Work Order";
        }
        field(8; "Current Work Order"; Code[20])
        {
            Caption = 'Current Work Order';
            Editable = false;
            TableRelation = "Work Order";
        }
        field(9; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
        field(10; Comment; Boolean)
        {
            CalcFormula = Exist ("Comment Line" WHERE("Table Name" = CONST(FOODPMOrder),
                                                      "No." = FIELD("Entry No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; "Override Date"; Date)
        {
            Caption = 'Override Date';

            trigger OnValidate()
            begin
                TestField("Frequency Code");
            end;
        }
        field(21; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Global Dimension 1 Code");
            end;
        }
        field(22; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Global Dimension 2 Code");
            end;
        }
        field(23; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Waiting Approval,Waiting Schedule,Waiting Parts,Do,In Work';
            OptionMembers = "Waiting Approval","Waiting Schedule","Waiting Parts","Do","In Work";
        }
        field(24; Priority; Integer)
        {
            Caption = 'Priority';
            MaxValue = 9;
            MinValue = 0;
        }
        field(25; "Work Requested"; Integer)
        {
            Caption = 'Work Requested';
            Editable = false;
        }
        field(26; "Work Requested (First Line)"; Text[80])
        {
            Caption = 'Work Requested (First Line)';
            Editable = false;
        }
        field(27; Originator; Text[30])
        {
            Caption = 'Originator';
        }
        field(28; "Material Account"; Code[20])
        {
            Caption = 'Material Account';
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true));
        }
        field(29; "Contract Account"; Code[20])
        {
            Caption = 'Contract Account';
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true));
        }
        field(31; "Labor Cost (Planned)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum ("PM Activity"."Planned Cost" WHERE("PM Entry No." = FIELD("Entry No."),
                                                                  Type = CONST(Labor)));
            Caption = 'Labor Cost (Planned)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(32; "Material Cost (Planned)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum ("PM Material"."Planned Cost" WHERE("PM Entry No." = FIELD("Entry No.")));
            Caption = 'Material Cost (Planned)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(33; "Contract Cost (Planned)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum ("PM Activity"."Planned Cost" WHERE("PM Entry No." = FIELD("Entry No."),
                                                                  Type = CONST(Contract)));
            Caption = 'Contract Cost (Planned)';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Asset No.", "Group Code", "Frequency Code")
        {
        }
        key(Key3; "Frequency Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        TestField("Current Work Order", '');

        CommentLine.SetRange("Table Name", CommentLine."Table Name"::FOODPMOrder);
        CommentLine.SetRange("No.", "Entry No.");
        CommentLine.DeleteAll;

        PMActivity.SetRange("PM Entry No.", "Entry No.");
        PMActivity.DeleteAll;

        PMMaterial.SetRange("PM Entry No.", "Entry No.");
        PMMaterial.DeleteAll;

        DimMgt.DeleteDefaultDim(DATABASE::"Preventive Maintenance Order", "Entry No.");
    end;

    trigger OnInsert()
    begin
        TestField("Asset No.");
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today;
    end;

    var
        MaintSetup: Record "Maintenance Setup";
        Asset: Record Asset;
        CommentLine: Record "Comment Line";
        Frequency: Record "PM Frequency";
        PMActivity: Record "PM Activity";
        PMMaterial: Record "PM Material";
        DimMgt: Codeunit DimensionManagement;
        TextFns: Codeunit "Text Functions";
        Text001: Label 'may not be %1';
        NoSeriesMgt: Codeunit NoSeriesManagement;
        MaintMgt: Codeunit "Maintenance Management";
        DatePassed: Boolean;
        Text002: Label '%1 %2 %3 is currently open for this %4.';

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        DimMgt.SaveDefaultDim(DATABASE::"Preventive Maintenance Order", "Entry No.", FieldNumber, ShortcutDimCode);
        Modify;
    end;

    procedure GetAsset()
    begin
        if Asset."No." <> "Asset No." then
            if "Asset No." = '' then
                Clear(Asset)
            else
                Asset.Get("Asset No.");
    end;

    procedure AssetDescription(): Text[100]
    begin
        GetAsset;
        exit(Asset.Description);
    end;

    procedure AssetLocation(): Code[10]
    begin
        GetAsset;
        exit(Asset."Location Code");
    end;

    procedure AssetPhysicalLocation(): Code[20]
    begin
        GetAsset;
        exit(Asset."Physical Location");
    end;

    procedure GetFrequency()
    begin
        if Frequency.Code <> "Frequency Code" then
            if "Frequency Code" = '' then
                Clear(Frequency)
            else
                Frequency.Get("Frequency Code");
    end;

    procedure NextPMDate(): Date
    var
        Frequency: Record "PM Frequency";
        Asset: Record Asset;
        AssetUsage: Record "Asset Usage";
        AssetUsage2: Record "Asset Usage";
        CalendarDate: Date;
        UsageDate: Date;
        Usage: Decimal;
    begin
        DatePassed := false;

        if "Last PM Date" = 0D then
            exit;
        if not Frequency.Get("Frequency Code") then
            exit;
        if not Asset.Get("Asset No.") then
            exit;

        CalendarDate := DMY2Date(31, 12, 9999); // P8007748
        UsageDate := DMY2Date(31, 12, 9999); // P8007748

        if Frequency.Type in [Frequency.Type::Calendar, Frequency.Type::Combined] then
            if Format(Frequency."Calendar Frequency") <> '' then
                CalendarDate := CalcDate(Frequency."Calendar Frequency", "Last PM Date");
        if Frequency.Type in [Frequency.Type::Usage, Frequency.Type::Combined] then
            if "Last PM Usage" = -1 then
                exit
            else begin
                AssetUsage.SetRange("Asset No.", "Asset No.");
                AssetUsage.SetRange(Type, AssetUsage.Type::"Meter Change");
                AssetUsage.SetRange(Date, "Last PM Date", DMY2Date(31, 12, 9999)); // P8007748
                AssetUsage2.SetRange("Asset No.", "Asset No.");
                AssetUsage2.Reading := "Last PM Usage";
                if AssetUsage.FindSet then
                    repeat
                        Usage += AssetUsage.Reading - AssetUsage2.Reading;
                        AssetUsage2 := AssetUsage;
                        AssetUsage2.Next;
                    until AssetUsage.Next = 0;
                AssetUsage.SetRange(Type, AssetUsage.Type::Reading);
                AssetUsage.FindLast;
                Usage += AssetUsage.Reading - AssetUsage2.Reading;
                Usage := Frequency."Usage Frequency" - Usage;        // Usage remaining
                if Usage <= 0 then
                    UsageDate := AssetUsage.Date
                else
                    UsageDate := AssetUsage.Date + (Usage div AssetUsage."Average Daily Usage");
            end;

        if UsageDate < CalendarDate then
            CalendarDate := UsageDate;
        DatePassed := CalendarDate <= WorkDate;
        exit(CalendarDate);
    end;

    procedure NextPMDateHasPassed(): Boolean
    begin
        exit(DatePassed);
    end;

    procedure CopyAssetDim()
    var
        AssetDim: Record "Default Dimension";
        PMDim: Record "Default Dimension";
    begin
        PMDim.SetRange("Table ID", DATABASE::"Preventive Maintenance Order");
        PMDim.SetRange("No.", "Entry No.");
        PMDim.DeleteAll;

        AssetDim.SetRange("Table ID", DATABASE::Asset);
        AssetDim.SetRange("No.", "Asset No.");
        if AssetDim.FindSet then
            repeat
                PMDim := AssetDim;
                PMDim."Table ID" := DATABASE::"Preventive Maintenance Order";
                PMDim."No." := "Entry No.";
                PMDim.Insert;
            until AssetDim.Next = 0;

        DimMgt.UpdateDefaultDim(
          DATABASE::"Preventive Maintenance Order", "Entry No.",
          "Global Dimension 1 Code", "Global Dimension 2 Code");
    end;

    procedure CreateWorkOrder(var WorkOrder: Record "Work Order"; OrigDate: Date; OrigTime: Time; DueDate: Date)
    var
        WOActivity: Record "Work Order Activity";
        WOMaterial: Record "Work Order Material";
        PMActivity: Record "PM Activity";
        PMMaterial: Record "PM Material";
        UOMMgt: Codeunit "Unit of Measure Management";
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
        ReqDate: Date;
    begin
        TestField("Asset No.");
        if "Current Work Order" <> '' then
            Error(Text002, WorkOrder.TableCaption, WorkOrder.FieldCaption("No."), "Current Work Order", TableCaption);
        MaintSetup.Get;

        if MaintSetup."PM Order Nos." <> '' then begin
            WorkOrder."No." := NoSeriesMgt.GetNextNo(MaintSetup."PM Order Nos.", OrigDate, true);
            WorkOrder."No. Series" := MaintSetup."PM Order Nos.";
        end else begin
            MaintSetup.TestField("Work Order Nos.");
            WorkOrder."No." := NoSeriesMgt.GetNextNo(MaintSetup."Work Order Nos.", OrigDate, true);
            WorkOrder."No. Series" := MaintSetup."Work Order Nos.";
        end;

        GetAsset;
        WorkOrder."Asset No." := "Asset No.";
        WorkOrder."Origination Date" := OrigDate;
        WorkOrder."Origination Time" := OrigTime;
        WorkOrder.Originator := Originator;
        WorkOrder."Asset Description" := Asset.Description;
        WorkOrder."Location Code" := Asset."Location Code";
        WorkOrder."Physical Location" := Asset."Physical Location";
        WorkOrder."Asset Hierarchy" := Asset."Asset Hierarchy"; // P8000725
        WorkOrder.Status := Status;
        WorkOrder.Priority := Priority;
        WorkOrder."Due Date" := DueDate;
        if WorkOrder."Origination Date" = WorkOrder."Due Date" then
            WorkOrder."Due Time" := WorkOrder."Origination Time";
        WorkOrder."Work Requested" := TextFns.CopyNote("Work Requested");
        WorkOrder."Work Requested (First Line)" := "Work Requested (First Line)";
        // P8000335A
        if "Material Account" <> '' then
            WorkOrder."Material Account" := "Material Account"
        else
            WorkOrder."Material Account" := MaintSetup."Default Material Account";
        if "Contract Account" <> '' then
            WorkOrder."Contract Account" := "Contract Account"
        else
            WorkOrder."Contract Account" := MaintSetup."Default Contract Account";
        // P8000335A
        WorkOrder."Preventive Maintenance" := true;
        WorkOrder."Frequency Code" := "Frequency Code";
        WorkOrder.Insert;

        DimMgt.AddDimSource(DefaultDimSource, DATABASE::"Preventive Maintenance Order", Rec."Entry No."); // P800144605
        WorkOrder."Shortcut Dimension 1 Code" := '';
        WorkOrder."Shortcut Dimension 2 Code" := '';
        WorkOrder."Dimension Set ID" := DimMgt.GetDefaultDimID( // P8001133
          DefaultDimSource, '', // P800144605
          WorkOrder."Shortcut Dimension 1 Code", WorkOrder."Shortcut Dimension 2 Code", 0, 0); // P8001133
        WorkOrder.Modify;

        if WorkOrder."Scheduled Date" = 0D then
            ReqDate := WorkOrder."Due Date"
        else
            ReqDate := WorkOrder."Scheduled Date";

        PMActivity.SetRange("PM Entry No.", "Entry No.");
        if PMActivity.FindFirst then
            repeat
                WOActivity.TransferFields(PMActivity);
                WOActivity."Work Order No." := WorkOrder."No.";
                WOActivity."Required Date" := ReqDate;
                WOActivity."Location Code" := WorkOrder."Location Code";
                WOActivity."Planned Hours Remaining" := WOActivity."Planned Hours";
                WOActivity.Insert;
            until PMActivity.Next = 0;

        PMMaterial.SetRange("PM Entry No.", "Entry No.");
        if PMMaterial.FindFirst then
            repeat
                WOMaterial.TransferFields(PMMaterial);
                WOMaterial."Work Order No." := WorkOrder."No.";
                WOMaterial."Required Date" := ReqDate;
                WOMaterial."Location Code" := WorkOrder."Location Code";
                // P800133109
                WOMaterial."Qty. per Unit of Measure" := PMMaterial.QtyPerUnitOfMeasure();
                if WOMaterial.Type = WOMaterial.Type::Stock then    
                    UOMMgt.GetQtyRoundingPrecision(WOMaterial."Item No.", WOMaterial."Unit of Measure Code", WOMaterial."Qty. Rounding Precision", WOMaterial."Qty. Rounding Precision (Base)");
                WOMaterial."Planned Quantity (Base)" := PMMaterial.PlannedQuantityBase();
                // P800133109
                WOMaterial."Planned Quantity Rem. (Base)" := WOMaterial."Planned Quantity (Base)";
                WOMaterial.Insert;
            until PMMaterial.Next = 0;

        "Current Work Order" := WorkOrder."No.";
    end;

    procedure UsageRequired(): Boolean
    var
        Frequency: Record "PM Frequency";
    begin
        if "Frequency Code" <> '' then begin
            Frequency.Get("Frequency Code");
            exit(Frequency.Type in [Frequency.Type::Usage, Frequency.Type::Combined]);
        end;
    end;
}

