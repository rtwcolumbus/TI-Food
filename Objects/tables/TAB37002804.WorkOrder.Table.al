table 37002804 "Work Order"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 30 AUG 06
    //   Maintenance management for work orders; this is the key document in this granule
    // 
    // P8000336A, VerticalSoft, Jack Reynolds, 14 SEP 06
    //   Add field for standing order
    // 
    // P8000335A, VerticalSoft, Jack Reynolds, 20 SEP 06
    //   Add fields for material and contract account
    //   Update InitRecord to initialze these from defaults on maintenance setup table
    // 
    // PRW15.00.01
    // P8000514A, VerticalSoft, Jack Reynolds, 12 SEP 07
    //   Fix problem setting schedule date to the same date as origination date
    // 
    // P8000515A, VerticalSoft, Jack Reynolds, 12 SEP 07
    //   Fix problem with work order completion even when OK button is not pressed on Complete Work Order form
    // 
    // P8000590A, VerticalSoft, Jack Reynolds, 07 MAR 08
    //   Modify CompleteWorkOrder to recalculate average daily usage for record after insertion
    // 
    // PRW16.00
    // P8000639, VerticalSoft, Jack Reynolds, 18 NOV 08
    //   Add DropDown field group
    // 
    // PRW16.00.01
    // P8000718, VerticalSoft, Jack Reynolds, 10 AUG 09
    //   Added field for downtime
    // 
    // P8000725, VerticalSoft, Jack Reynolds, 27 AUG 09
    //   Set Asset Hierarchy from asset record
    // 
    // PRW16.00.20
    // P8000671, VerticalSoft, Jack Reynolds, 04 FEB 09
    //   Support for adding work orders for a selected asset
    // 
    // PRW16.00.04
    // P8000897, VerticalSoft, Jack Reynolds, 22 JAN 11
    //   Fix spelling mistake
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW17.10
    // P8001215, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Remove Notepad functionality
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 26 APR 22
    //   Upgrade to 20.0 - Refactoring for default dimensions

    Caption = 'Work Order';
    DataCaptionFields = "No.", "Asset Description";
    LookupPageID = "Work Order List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; "Asset No."; Code[20])
        {
            Caption = 'Asset No.';
            TableRelation = Asset;

            trigger OnValidate()
            begin
                if "Asset No." <> xRec."Asset No." then begin
                    TestField("Preventive Maintenance", false);
                    if EntriesExist then
                        Error(Text003,
                          FieldCaption("Asset No."), MaintLedgEntry.TableCaption, TableCaption);
                end;

                GetAsset("Asset No.");
                "Asset Description" := Asset.Description;
                "Location Code" := Asset."Location Code";
                "Physical Location" := Asset."Physical Location";
                "Resource No." := Asset."Resource No.";
                "Asset Hierarchy" := Asset."Asset Hierarchy"; // P8000725

                CreateDimFromDefaultDim(); // P800144605
            end;
        }
        field(3; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(4; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(5; Comment; Boolean)
        {
            CalcFormula = Exist("Work Order Comment Line" WHERE("No." = FIELD("No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(7; "Preventive Maintenance"; Boolean)
        {
            Caption = 'Preventive Maintenance';
            Editable = false;
        }
        field(8; "Frequency Code"; Code[10])
        {
            Caption = 'Frequency Code';
            Editable = false;
            TableRelation = "PM Frequency";
        }
        field(9; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(10; "Trade Filter"; Code[10])
        {
            Caption = 'Trade Filter';
            FieldClass = FlowFilter;
            TableRelation = "Maintenance Trade";
        }
        field(11; "Origination Date"; Date)
        {
            Caption = 'Origination Date';

            trigger OnValidate()
            begin
                if "Origination Date" = 0D then
                    "Origination Time" := 0T;
                CheckDatesAndTimes;
            end;
        }
        field(12; "Origination Time"; Time)
        {
            Caption = 'Origination Time';

            trigger OnValidate()
            begin
                TestField("Origination Date");
                CheckDatesAndTimes;
            end;
        }
        field(13; Originator; Text[30])
        {
            Caption = 'Originator';
        }
        field(14; "Asset Description"; Text[100])
        {
            Caption = 'Asset Description';
            Editable = false;
        }
        field(15; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;

            trigger OnValidate()
            begin
                if "Location Code" <> xRec."Location Code" then begin
                    SetActAndMtlLocation;
                    CreateDimFromDefaultDim(); // P800144605
                end;
            end;
        }
        field(16; "Physical Location"; Code[20])
        {
            Caption = 'Physical Location';
        }
        field(17; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Waiting Approval,Waiting Schedule,Waiting Parts,Do,In Work,Closed,Cancelled';
            OptionMembers = "Waiting Approval","Waiting Schedule","Waiting Parts","Do","In Work",Closed,Cancelled;
        }
        field(18; Priority; Integer)
        {
            Caption = 'Priority';
            InitValue = 4;
            MaxValue = 9;
            MinValue = 0;
        }
        field(19; "Due Date"; Date)
        {
            Caption = 'Due Date';

            trigger OnValidate()
            begin
                if "Due Date" = 0D then
                    "Due Time" := 0T;
                SetActAndMtlDates;
            end;
        }
        field(20; "Due Time"; Time)
        {
            Caption = 'Due Time';

            trigger OnValidate()
            begin
                TestField("Due Date");
            end;
        }
        field(21; "Scheduled Date"; Date)
        {
            Caption = 'Scheduled Date';

            trigger OnValidate()
            begin
                if "Scheduled Date" = 0D then
                    "Scheduled Time" := 0T;
                if ("Scheduled Date" = "Origination Date") and ("Scheduled Time" = 0T) then // P8000514A
                    "Scheduled Time" := "Origination Time";                                   // P8000514A
                CheckDatesAndTimes;
                SetActAndMtlDates;
            end;
        }
        field(22; "Scheduled Time"; Time)
        {
            Caption = 'Scheduled Time';

            trigger OnValidate()
            begin
                TestField("Scheduled Date");
                CheckDatesAndTimes;
            end;
        }
        field(23; "Fault Code"; Code[10])
        {
            Caption = 'Fault Code';
            TableRelation = "Work Order Fault Code";
        }
        field(24; "Cause Code"; Code[10])
        {
            Caption = 'Cause Code';
            TableRelation = "Work Order Cause Code";
        }
        field(25; "Action Code"; Code[10])
        {
            Caption = 'Action Code';
            TableRelation = "Work Order Action Code";
        }
        field(26; "Completion Date"; Date)
        {
            Caption = 'Completion Date';
            Editable = false;

            trigger OnValidate()
            begin
                if "Completion Date" = 0D then
                    "Completion Time" := 0T;
                CheckDatesAndTimes;
            end;
        }
        field(27; "Completion Time"; Time)
        {
            Caption = 'Completion Time';
            Editable = false;

            trigger OnValidate()
            begin
                TestField("Completion Date");
                CheckDatesAndTimes;
            end;
        }
        field(28; Completed; Boolean)
        {
            Caption = 'Completed';
            Editable = false;
        }
        field(29; "Work Requested"; Integer)
        {
            Caption = 'Work Requested';
            Editable = false;
        }
        field(30; "Work Requested (First Line)"; Text[80])
        {
            Caption = 'Work Requested (First Line)';
            Editable = false;
        }
        field(31; "Corrective Action"; Integer)
        {
            Caption = 'Corrective Action';
            Editable = false;
        }
        field(32; "Corrective Action (First Line)"; Text[80])
        {
            Caption = 'Corrective Action (First Line)';
            Editable = false;
        }
        field(33; Usage; Decimal)
        {
            Caption = 'Usage';
            DecimalPlaces = 0 : 5;
            InitValue = -1;
        }
        field(34; "Resource No."; Code[20])
        {
            Caption = 'Resource No.';
            TableRelation = Resource;
        }
        field(35; "Material Account"; Code[20])
        {
            Caption = 'Material Account';
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true));
        }
        field(36; "Contract Account"; Code[20])
        {
            Caption = 'Contract Account';
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true));
        }
        field(37; "Standing Order"; Boolean)
        {
            Caption = 'Standing Order';
        }
        field(38; "Asset Hierarchy"; Code[85])
        {
            Caption = 'Asset Hierarchy';
            Editable = false;
            TableRelation = Asset;
            ValidateTableRelation = false;
        }
        field(41; "Total Cost (Actual)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Maintenance Ledger"."Cost Amount" WHERE("Work Order No." = FIELD("No."),
                                                                        "Posting Date" = FIELD("Date Filter")));
            Caption = 'Total Cost (Actual)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(42; "Labor Cost (Planned)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Work Order Activity"."Planned Cost" WHERE("Work Order No." = FIELD("No."),
                                                                          Type = CONST(Labor),
                                                                          "Trade Code" = FIELD("Trade Filter")));
            Caption = 'Labor Cost (Planned)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(43; "Labor Cost (Actual)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Maintenance Ledger"."Cost Amount" WHERE("Work Order No." = FIELD("No."),
                                                                        "Entry Type" = CONST(Labor),
                                                                        "Posting Date" = FIELD("Date Filter"),
                                                                        "Maintenance Trade Code" = FIELD("Trade Filter")));
            Caption = 'Labor Cost (Actual)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(44; "Labor Hours (Planned)"; Decimal)
        {
            CalcFormula = Sum("Work Order Activity"."Planned Hours" WHERE("Work Order No." = FIELD("No."),
                                                                           Type = CONST(Labor),
                                                                           "Trade Code" = FIELD("Trade Filter")));
            Caption = 'Labor Hours (Planned)';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(45; "Labor Hours (Actual)"; Decimal)
        {
            CalcFormula = Sum("Maintenance Ledger".Quantity WHERE("Work Order No." = FIELD("No."),
                                                                   "Entry Type" = CONST(Labor),
                                                                   "Posting Date" = FIELD("Date Filter"),
                                                                   "Maintenance Trade Code" = FIELD("Trade Filter")));
            Caption = 'Labor Hours (Actual)';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(46; "Material Cost (Planned)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Work Order Material"."Planned Cost" WHERE("Work Order No." = FIELD("No.")));
            Caption = 'Material Cost (Planned)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(47; "Material Cost (Actual)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Maintenance Ledger"."Cost Amount" WHERE("Work Order No." = FIELD("No."),
                                                                        "Entry Type" = FILTER("Material-Stock" | "Material-NonStock"),
                                                                        "Posting Date" = FIELD("Date Filter")));
            Caption = 'Material Cost (Actual)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50; "Contract Cost (Planned)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Work Order Activity"."Planned Cost" WHERE("Work Order No." = FIELD("No."),
                                                                          Type = CONST(Contract),
                                                                          "Trade Code" = FIELD("Trade Filter")));
            Caption = 'Contract Cost (Planned)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(51; "Contract Cost (Actual)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Maintenance Ledger"."Cost Amount" WHERE("Work Order No." = FIELD("No."),
                                                                        "Entry Type" = CONST(Contract),
                                                                        "Posting Date" = FIELD("Date Filter"),
                                                                        "Maintenance Trade Code" = FIELD("Trade Filter")));
            Caption = 'Contract Cost (Actual)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(52; "Contract Hours (Planned)"; Decimal)
        {
            CalcFormula = Sum("Work Order Activity"."Planned Hours" WHERE("Work Order No." = FIELD("No."),
                                                                           Type = CONST(Contract),
                                                                           "Trade Code" = FIELD("Trade Filter")));
            Caption = 'Contract Hours (Planned)';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(53; "Contract Hours (Actual)"; Decimal)
        {
            CalcFormula = Sum("Maintenance Ledger".Quantity WHERE("Work Order No." = FIELD("No."),
                                                                   "Entry Type" = CONST(Contract),
                                                                   "Posting Date" = FIELD("Date Filter"),
                                                                   "Maintenance Trade Code" = FIELD("Trade Filter")));
            Caption = 'Contract Hours (Actual)';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(54; "Labor Hours (Remaining)"; Decimal)
        {
            CalcFormula = Sum("Work Order Activity"."Planned Hours Remaining" WHERE("Work Order No." = FIELD("No."),
                                                                                     Type = CONST(Labor),
                                                                                     "Trade Code" = FIELD("Trade Filter")));
            Caption = 'Labor Hours (Remaining)';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(55; "Contract Hours (Remaining)"; Decimal)
        {
            CalcFormula = Sum("Work Order Activity"."Planned Hours Remaining" WHERE("Work Order No." = FIELD("No."),
                                                                                     Type = CONST(Contract),
                                                                                     "Trade Code" = FIELD("Trade Filter")));
            Caption = 'Contract Hours (Remaining)';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(61; "Downtime (Hours)"; Decimal)
        {
            Caption = 'Downtime (Hours)';
            DecimalPlaces = 0 : 2;
            MinValue = 0;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                // P8001133
                ShowDocDim;
            end;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; "Asset No.", "Completion Date", Completed)
        {
            SumIndexFields = "Downtime (Hours)";
        }
        key(Key3; Completed)
        {
        }
        key(Key4; Completed, "Resource No.", "Scheduled Date", "Scheduled Time", Priority)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", "Asset No.", Status, "Work Requested (First Line)")
        {
        }
    }

    trigger OnDelete()
    var
        PMOrder: Record "Preventive Maintenance Order";
    begin
        if EntriesExist then
            Error(
              Text002, TableCaption, "No.", MaintLedgEntry.TableCaption);

        if "Preventive Maintenance" then begin
            PMOrder.SetCurrentKey("Asset No.");
            PMOrder.SetRange("Asset No.", "Asset No.");
            PMOrder.SetRange("Current Work Order", "No.");
            if PMOrder.FindSet(true, false) then
                repeat
                    PMOrder."Current Work Order" := '';
                    PMOrder.Modify;
                until PMOrder.Next = 0;
        end;


        WorkOrderCommentLine.SetRange("No.", "No.");
        WorkOrderCommentLine.DeleteAll;

        WorkOrderActivity.SetRange("Work Order No.", "No.");
        WorkOrderActivity.DeleteAll;

        WorkOrderMtl.SetRange("Work Order No.", "No.");
        WorkOrderMtl.DeleteAll;
    end;

    trigger OnInsert()
    begin
        GetSetup;

        if "No." = '' then begin
            MaintSetup.TestField("Work Order Nos.");
            NoSeriesMgt.InitSeries(MaintSetup."Work Order Nos.", xRec."No. Series", "Origination Date", "No.", "No. Series");
        end;

        InitRecord;

        // P8000671
        if GetFilter("Asset No.") <> '' then
            if GetRangeMin("Asset No.") = GetRangeMax("Asset No.") then
                Validate("Asset No.", GetRangeMin("Asset No."));
        // P8000671
    end;

    trigger OnRename()
    begin
        Error(Text001, TableCaption);
    end;

    var
        MaintSetup: Record "Maintenance Setup";
        Text001: Label 'You cannot rename a %1.';
        WorkOrder: Record "Work Order";
        Asset: Record Asset;
        MaintLedgEntry: Record "Maintenance Ledger";
        WorkOrderCommentLine: Record "Work Order Comment Line";
        WorkOrderActivity: Record "Work Order Activity";
        WorkOrderMtl: Record "Work Order Material";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DimMgt: Codeunit DimensionManagement;
        TextFns: Codeunit "Text Functions";
        MaintMgt: Codeunit "Maintenance Management";
        SetupRead: Boolean;
        Text002: Label 'You cannot delete %1 %2 because there exists at least one %3 associated with it.';
        Text003: Label 'You cannot change %1 because there exists at least one %2 associated with this %3.';
        Text004: Label '%1 and %2 must be after %3 and %4.';

    procedure GetSetup()
    begin
        if SetupRead then
            exit;

        MaintSetup.Get;
        SetupRead := true;
    end;

    procedure InitRecord()
    begin
        "Origination Date" := WorkDate;
        "Origination Time" := Time;

        // P8000335A
        GetSetup;
        "Material Account" := MaintSetup."Default Material Account";
        "Contract Account" := MaintSetup."Default Contract Account";
        // P8000335A
    end;

    procedure SetupNewOrder()
    begin
        GetSetup;
        Status := MaintSetup."Default Work Order Status";
        Priority := MaintSetup."Default Work Order Priority";
    end;

    procedure AssistEdit(OldWorkOrder: Record "Work Order"): Boolean
    var
        Asset: Record Asset;
    begin
        with WorkOrder do begin
            WorkOrder := Rec;
            MaintSetup.Get;
            MaintSetup.TestField("Work Order Nos.");
            if NoSeriesMgt.SelectSeries(MaintSetup."Work Order Nos.", OldWorkOrder."No. Series", "No. Series") then begin
                NoSeriesMgt.SetSeries("No.");
                Rec := WorkOrder;
                exit(true);
            end;
        end;
    end;

    local procedure GetAsset(AssetNo: Code[20])
    begin
        if AssetNo <> '' then begin
            if AssetNo <> Asset."No." then
                Asset.Get(AssetNo);
        end else
            Clear(Asset);
    end;
    // P800144605
    procedure CreateDimFromDefaultDim()
    var
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        InitDefaultDimensionSources(DefaultDimSource);
        CreateDim(DefaultDimSource);
    end;

    // P800144605
    local procedure InitDefaultDimensionSources(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    begin
        DimMgt.AddDimSource(DefaultDimSource, Database::Asset, Rec."Asset No.");
        DimMgt.AddDimSource(DefaultDimSource, Database::Location, Rec."Location Code");
    end;

    // P800144605
    procedure CreateDim(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        "Dimension Set ID" :=
          DimMgt.GetRecDefaultDimID(
            Rec, CurrFieldNo, DefaultDimSource, SourceCodeSetup."Work Order", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);
    end;

    [Obsolete('Replaced by CreateDim(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])', 'FOOD-21')]
    procedure CreateDim(Type1: Integer; No1: Code[20])
    var
        SourceCodeSetup: Record "Source Code Setup";
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        SourceCodeSetup.Get;
        TableID[1] := Type1;
        No[1] := No1;
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        "Dimension Set ID" := DimMgt.GetDefaultDimID( // P8001113
          TableID, No, SourceCodeSetup."Work Order",
          "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0); // P8001133
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID"); // P8001133
    end;

    procedure ShowDocDim()
    begin
        // P8001133
        if not Completed then
            DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo('%1 %2', TableCaption, "No."))
        else begin
            TestField("No.");
            "Dimension Set ID" :=
              DimMgt.EditDimensionSet(
                "Dimension Set ID", StrSubstNo('%1 %2', TableCaption, "No."),
                "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
        end;
    end;

    procedure EntriesExist(): Boolean
    begin
        MaintLedgEntry.Reset;
        MaintLedgEntry.SetCurrentKey("Work Order No.");
        MaintLedgEntry.SetRange("Work Order No.", "No.");
        exit(MaintLedgEntry.FindFirst);
    end;

    procedure CheckDatesAndTimes()
    var
        OrigDT: DateTime;
        DueDT: DateTime;
        SchedDT: DateTime;
        CompDT: DateTime;
    begin
        OrigDT := CreateDateTime("Origination Date", "Origination Time");
        SchedDT := CreateDateTime("Scheduled Date", "Scheduled Time");
        CompDT := CreateDateTime("Completion Date", "Completion Time");

        if OrigDT <> 0DT then begin
            if (SchedDT <> 0DT) and (SchedDT < OrigDT) then
                Error(Text004, FieldCaption("Scheduled Date"), FieldCaption("Scheduled Time"),
                  FieldCaption("Origination Date"), FieldCaption("Origination Time"));
            if (CompDT <> 0DT) and (CompDT < OrigDT) then
                Error(Text004, FieldCaption("Completion Date"), FieldCaption("Completion Time"),
                  FieldCaption("Origination Date"), FieldCaption("Origination Time"));
        end;
    end;

    procedure SetActAndMtlDates()
    var
        WOActivity: Record "Work Order Activity";
        WOMaterial: Record "Work Order Material";
        ReqDate: Date;
    begin
        if "Scheduled Date" = 0D then
            ReqDate := "Due Date"
        else
            ReqDate := "Scheduled Date";

        WOActivity.SetRange("Work Order No.", "No.");
        WOActivity.ModifyAll("Required Date", ReqDate);

        WOMaterial.SetRange("Work Order No.", "No.");
        WOMaterial.ModifyAll("Required Date", ReqDate);
    end;

    procedure SetActAndMtlLocation()
    var
        WOActivity: Record "Work Order Activity";
        WOMaterial: Record "Work Order Material";
    begin
        WOActivity.SetRange("Work Order No.", "No.");
        WOActivity.ModifyAll("Location Code", "Location Code");

        WOMaterial.SetRange("Work Order No.", "No.");
        WOMaterial.ModifyAll("Location Code", "Location Code");
    end;

    procedure CheckUsage()
    begin
        if ("Completion Date" <> 0D) and (Usage <> -1) then
            MaintMgt.TestUsage("Asset No.", "Completion Date", Usage, false);
    end;

    procedure CompleteWorkOrder()
    var
        WorkOrder: Record "Work Order";
        WOActivity: Record "Work Order Activity";
        WOMaterial: Record "Work Order Material";
        AssetUsage: Record "Asset Usage";
        PMOrder: Record "Preventive Maintenance Order";
        Frequency: Record "PM Frequency";
        CompWorkOrder: Page "Complete Work Order";
    begin
        if Completed then
            exit;

        WorkOrder := Rec;
        WorkOrder."Completion Date" := WorkDate;
        WorkOrder."Completion Time" := Time;
        if WorkOrder."Corrective Action" <> 0 then
            WorkOrder.Status := WorkOrder.Status::Closed
        else
            WorkOrder.Status := WorkOrder.Status::Cancelled;

        CompWorkOrder.SetWorkOrder(WorkOrder);
        CompWorkOrder.RunModal;                // P8000515A
        CompWorkOrder.GetWorkOrder(WorkOrder); // P8000515A
        if WorkOrder.Completed then begin      // P8000515A
            WorkOrder.TestField("Completion Date");
            "Completion Date" := WorkOrder."Completion Date";
            "Completion Time" := WorkOrder."Completion Time";
            Usage := WorkOrder.Usage;
            Status := WorkOrder.Status;
            "Downtime (Hours)" := WorkOrder."Downtime (Hours)"; // P8000718
            Completed := true;
            Modify;

            WOActivity.SetRange("Work Order No.", "No.");
            WOActivity.ModifyAll(Completed, true);

            WOMaterial.SetRange("Work Order No.", "No.");
            WOMaterial.ModifyAll(Completed, true);

            if Usage <> -1 then
                if not AssetUsage.Get("Asset No.", "Completion Date", AssetUsage.Type::Reading) then begin
                    AssetUsage."Asset No." := "Asset No.";
                    AssetUsage.Date := "Completion Date";
                    AssetUsage.Type := AssetUsage.Type::Reading;
                    AssetUsage.Reading := Usage;
                    AssetUsage.CalcAvgDailyUsage;
                    AssetUsage.Insert;
                    // P8000590A
                    AssetUsage.SetRange("Asset No.", "Asset No.");
                    if AssetUsage.Next <> 0 then begin
                        AssetUsage.CalcAvgDailyUsage;
                        AssetUsage.Modify;
                    end;
                    // P8000590A
                end;

            if "Preventive Maintenance" then begin
                PMOrder.SetCurrentKey("Asset No.");
                PMOrder.SetRange("Asset No.", "Asset No.");
                PMOrder.SetRange("Current Work Order", "No.");
                if PMOrder.FindSet(true, false) then
                    repeat
                        PMOrder."Last Work Order" := "No.";
                        PMOrder."Current Work Order" := '';
                        PMOrder."Override Date" := 0D;
                        if PMOrder."Frequency Code" <> '' then begin
                            Frequency.Get(PMOrder."Frequency Code");
                            PMOrder."Last PM Date" := "Completion Date";
                            if Frequency.Type in [Frequency.Type::Usage, Frequency.Type::Combined] then
                                PMOrder."Last PM Usage" := Usage;
                        end;
                        PMOrder.Modify;
                    until PMOrder.Next = 0;
            end;
        end;
    end;

    procedure UsageRequired(): Boolean
    var
        Frequency: Record "PM Frequency";
        PMOrder: Record "Preventive Maintenance Order";
    begin
        if not "Preventive Maintenance" then
            exit(false);

        if "Frequency Code" <> '' then begin
            Frequency.Get("Frequency Code");
            if Frequency.Type in [Frequency.Type::Usage, Frequency.Type::Combined] then
                exit(true);
        end;

        PMOrder.SetCurrentKey("Asset No.");
        PMOrder.SetRange("Asset No.");
        PMOrder.SetRange("Current Work Order", "No.");
        PMOrder.SetFilter("Frequency Code", '<>%1', '');
        if PMOrder.FindSet then
            repeat
                if PMOrder.UsageRequired then
                    exit(true);
            until PMOrder.Next = 0;
    end;

    procedure Navigate()
    var
        NavigateForm: Page Navigate;
    begin
        if not Completed then
            exit;
        NavigateForm.SetDoc(0D, "No.");
        NavigateForm.Run;
    end;
}

