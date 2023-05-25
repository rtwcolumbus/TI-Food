page 37002534 "Production Sequence"
{
    // PRW16.00.04
    // P8000889, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Main page for production sequencing
    // 
    // PRW16.00.05
    // P8000930, Columbus IT, Jack Reynolds, 15 APR 11
    //   Add CURRPAGE.UPDATE to update page after move up/down
    // 
    // P8000973, Columbus IT, Jack Reynolds, 26 AUG 11
    //   Fix screen refresh issues
    // 
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // P8001112, Columbus IT, Jack Reynolds, 06 NOV 12
    //   Fix problem with overlapping and missing bitmaps
    // 
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW113.00.02
    // P80078034, To Increase, Jack Reynolds, 25 JUL 19
    //   Fix "hang' in web client

    ApplicationArea = FOODBasic;
    Caption = 'Production Sequence';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = "Production Sequencing";
    SourceTableTemporary = true;
    SourceTableView = SORTING("Resource Group", "Equipment Code", Level, "Sequence No.", "Starting Date-Time", "Ending Date-Time");
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            field(LocCode; LocCode)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Location';
                TableRelation = Location WHERE("Use As In-Transit" = CONST(false));

                trigger OnValidate()
                begin
                    if (LocCode <> xLocCode) and (ProdDate <> 0D) then begin
                        xLocCode := LocCode;
                        LoadData;
                    end;
                end;
            }
            field(ProdDate; ProdDate)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Date';

                trigger OnValidate()
                begin
                    if (ProdDate <> xProdDate) and (LocCode <> '') then begin
                        xProdDate := ProdDate;
                        LoadData;
                    end;
                end;
            }
            repeater(Group)
            {
                IndentationColumn = Level;
                IndentationControls = "Equipment Code";
                ShowAsTree = true;
                field("Equipment Code"; "Equipment Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Enabled = false;
                    HideValue = HideSummary;
                    Style = Strong;
                    StyleExpr = NOT HideSummary;
                }
                field("No. Of Entries"; "No. Of Entries")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Entries';
                    Editable = false;
                    HideValue = HideSummary;
                    Style = Strong;
                    StyleExpr = NOT HideSummary;
                }
                field("Resource Group"; "Resource Group")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    HideValue = HideSummary;
                    Style = Strong;
                    StyleExpr = NOT HideSummary;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = NOT HideSummary;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = NOT HideSummary;
                }
                field(Allergens; AllergenManagement.AllergenCodeForRecord(DATABASE::"Production Sequencing", Level, "Item No."))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Allergens';
                    Style = StrongAccent;
                    StyleExpr = TRUE;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        // P8006959
                        AllergenManagement.AllergenDrilldownForRecord(DATABASE::"Production Sequencing", Level, "Item No.");
                    end;
                }
                field("Item Description"; "Item Description")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = NOT HideSummary;
                }
                field("No. of Batches"; "No. of Batches")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    HideValue = NOT BatchOrder;
                    Visible = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    HideValue = NOT OrderLine;
                    Visible = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Unit of Measure';
                    Editable = false;
                    HideValue = NOT OrderLine;
                    Visible = false;
                }
                field(EarliestLatestStart; EarliestLatestStart)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Earliest/Latest Starting Time';
                    Style = Attention;
                    StyleExpr = HighlightStart;

                    trigger OnDrillDown()
                    begin
                        if ("Earliest Starting Time" = 0T) and ("Latest Starting Time" = 0T) then
                            exit;

                        DrillOnEarliestLatestStart;
                    end;
                }
                field(StartTime; StartTime)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Starting Time';
                    Editable = HideSummary;
                    Style = Attention;
                    StyleExpr = HighlightTimes;

                    trigger OnValidate()
                    var
                        P800UtilityFns: Codeunit "Process 800 Utility Functions"; // P800-MegaApp
                        xStartTimeIssue: Boolean;
                    begin
                        P800UtilityFns.MakeTimeText(StartTime); // P80066030
                        xStartTimeIssue := StartTimeIssue;
                        if Evaluate("Starting Time", StartTime) then begin
                            Validate("Starting Time");
                            if xStartTimeIssue <> StartTimeIssue then
                                if xStartTimeIssue then
                                    UpdateStartTimeIssue(Rec, -1)
                                else
                                    UpdateStartTimeIssue(Rec, 1);

                            CurrPage.SaveRecord;

                            UpdateDateTime;
                            UpdateEarliestLatestStart;
                            UpdateBitmap;

                            CurrPage.Update(false);
                        end else
                            Error(Text004, StartTime, FieldCaption("Starting Time"));
                    end;
                }
                field(EndTime; EndTime)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Ending Time';
                    Editable = HideSummary;
                    Style = Attention;
                    StyleExpr = HighlightTimes;

                    trigger OnValidate()
                    var
                        P800UtilityFns: Codeunit "Process 800 Utility Functions"; // P800-MegaApp
                        xStartTimeIssue: Boolean;
                    begin
                        P800UtilityFns.MakeTimeText(EndTime); // P80066030
                        xStartTimeIssue := StartTimeIssue;
                        if Evaluate("Ending Time", EndTime) then begin
                            Validate("Ending Time");
                            if xStartTimeIssue <> StartTimeIssue then
                                if xStartTimeIssue then
                                    UpdateStartTimeIssue(Rec, -1)
                                else
                                    UpdateStartTimeIssue(Rec, 1);

                            CurrPage.SaveRecord;

                            UpdateDateTime;
                            UpdateEarliestLatestStart;
                            UpdateBitmap;

                            CurrPage.Update(false);
                        end else
                            Error(Text004, EndTime, FieldCaption("Ending Time"));
                    end;
                }
                field("Total Time (Hours)"; "Total Time (Hours)")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    HideValue = HideSummary;
                }
                field(Timeline; Timeline)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(MoveUp)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Move Up';
                Enabled = MoveUpEnabled;
                Image = MoveUp;
                ShortCutKey = 'Ctrl+Up';

                trigger OnAction()
                begin
                    CurrPage.SaveRecord;
                    Move(-1);
                end;
            }
            action(MoveDown)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Move Down';
                Enabled = MoveDownEnabled;
                Image = MoveDown;
                ShortCutKey = 'Ctrl+Down';

                trigger OnAction()
                begin
                    CurrPage.SaveRecord;
                    Move(1);
                end;
            }
            separator(Separator37002017)
            {
            }
            action(Reschedule)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Reschedule';
                Image = Replan;

                trigger OnAction()
                begin
                    Reschedule;
                end;
            }
            group("Event")
            {
                Caption = 'Non-production Events';
                action(EditEvent)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Edit';
                    Image = Edit;
                    ShortCutKey = 'Ctrl+E';

                    trigger OnAction()
                    begin
                        EditEvent;
                    end;
                }
                action(NewEvent)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'New';
                    Image = NewDocument;
                    ShortCutKey = 'Ctrl+Insert';

                    trigger OnAction()
                    begin
                        NewEvent;
                    end;
                }
                action(DeleteEvent)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Delete';
                    Image = Delete;
                    ShortCutKey = 'Ctrl+Delete';

                    trigger OnAction()
                    begin
                        DeleteEvent;
                    end;
                }
            }
        }
        area(navigation)
        {
            action("Show Order")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Show Order';
                Image = "Order";

                trigger OnAction()
                begin
                    ShowOrder;
                end;
            }
        }
        area(reporting)
        {
            action(DailyProdPlan)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Daily Production Plan';
                Image = Planning;

                trigger OnAction()
                var
                    DailyProdPlan: Report "Daily Production Plan";
                begin
                    DailyProdPlan.SetParameters(LocCode, ProdDate, ProdDate);
                    DailyProdPlan.Run;
                end;
            }
        }
        area(Promoted)
        {
            actionref(Reschedule_Promoted; Reschedule)
            {
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        HideSummary := Level <> 0;
        OrderLine := "Order No." <> '';
        BatchOrder := "Order Type" = "Order Type"::Batch;
        HighlightTimes := Overlap or ((Level = 0) and ("Starting Time Issues" > 0));
        HighlightStart := (Level <> 0) and
         ((("Earliest Starting Time" <> 0T) and ("Starting Time" < "Earliest Starting Time")) or
          (("Latest Starting Time" <> 0T) and ("Latest Starting Time" < "Starting Time")));
        MoveEnabled;

        StartTime := Format("Starting Time", 0, '<Hours24,2><Filler,0>:<Minutes,2>');
        EndTime := Format("Ending Time", 0, '<Hours24,2><Filler,0>:<Minutes,2>');
    end;

    trigger OnOpenPage()
    begin
        LocCode := P800CoreFns.GetDefaultEmpLocation; // P8001030
        //LoadData; // P80078034
    end;

    var
        MfgSetup: Record "Manufacturing Setup";
        Location: Record Location;
        BatchPkgXref: array[2] of Record "Extended Text" temporary;
        P800CoreFns: Codeunit "Process 800 Core Functions";
        BitmapFns: Codeunit "Bitmap Functions";
        AllergenManagement: Codeunit "Allergen Management";
        LocCode: Code[10];
        xLocCode: Code[10];
        ProdDate: Date;
        xProdDate: Date;
        [InDataSet]
        HideSummary: Boolean;
        Text001: Label 'Only events can be rescheduled.';
        Text002: Label 'Only one equipment can be rescheduled at a time.';
        [InDataSet]
        OrderLine: Boolean;
        [InDataSet]
        BatchOrder: Boolean;
        [InDataSet]
        HighlightStart: Boolean;
        [InDataSet]
        HighlightTimes: Boolean;
        [InDataSet]
        MoveUpEnabled: Boolean;
        [InDataSet]
        MoveDownEnabled: Boolean;
        Text003: Label 'Delete %1? ';
        EntryNo: Integer;
        Text004: Label 'Your entry of ''%1'' is not an acceptable value for ''%2''. ''%1'' is not a valid time.';
        StartTime: Text;
        EndTime: Text;

    procedure LoadData()
    var
        ProdSequence: Record "Production Sequencing" temporary;
        ProdSequence2: Record "Production Sequencing";
        ProdOrder: Record "Production Order";
        BatchPlanning: Codeunit "Batch Planning Functions";
        LatestStart: Time;
        EarliestStart: Time;
        xStartTimeIssue: array[2] of Boolean;
        BitmapStartEndTime: array[2] of DateTime;
    begin
        Reset;
        DeleteAll;
        BatchPkgXref[1].Reset;
        BatchPkgXref[1].DeleteAll;

        if ProdDate = 0D then
            exit;

        BatchPlanning.LoadProductionSequence(LocCode, ProdDate, ProdSequence);

        ProdSequence.Reset;
        ProdSequence.SetFilter("Order No.", '<>%1', '');
        if ProdSequence.FindSet(true) then
            repeat
                ProdOrder.Get(ProdSequence."Order Status", ProdSequence."Order No.");
                if ProdOrder.Suborder then begin
                    ProdSequence."Order Type" := ProdSequence."Order Type"::Package;
                    ProdSequence2.Copy(ProdSequence);
                    xStartTimeIssue[2] := ProdSequence2.StartTimeIssue;

                    ProdSequence.Reset;
                    ProdSequence.SetRange("Order Status", ProdOrder.Status);
                    ProdSequence.SetRange("Order No.", ProdOrder."Batch Prod. Order No.");
                    if ProdSequence.FindSet then // Find the batch orders
                        repeat
                            xStartTimeIssue[1] := ProdSequence.StartTimeIssue;
                            LatestStart := DT2Time(ProdSequence2."Starting Date-Time" - ProdSequence."First Line Duration");
                            if (ProdSequence."Latest Starting Time" = 0T) or (LatestStart < ProdSequence."Latest Starting Time") then begin
                                ProdSequence."Latest Starting Time" := LatestStart;
                                if xStartTimeIssue[1] <> ProdSequence.StartTimeIssue then
                                    if xStartTimeIssue[1] then
                                        UpdateStartTimeIssue(ProdSequence, -1)
                                    else
                                        UpdateStartTimeIssue(ProdSequence, 1);
                            end;
                            ProdSequence."Order Type" := ProdSequence."Order Type"::Batch;
                            ProdSequence.Modify;

                            EarliestStart := DT2Time(ProdSequence."Starting Date-Time" + ProdSequence."First Line Duration");
                            // Need to compare to previous value and only set if earlier (later?)
                            if (ProdSequence2."Earliest Starting Time" = 0T) or (EarliestStart < ProdSequence2."Earliest Starting Time") then
                                ProdSequence2."Earliest Starting Time" := EarliestStart;

                            BatchPkgXref[1].ID := ProdSequence."Entry No.";
                            BatchPkgXref[1].LineNo := ProdSequence2."Entry No.";
                            BatchPkgXref[1].Insert;
                        until ProdSequence.Next = 0;
                    ProdSequence.Copy(ProdSequence2);
                    ProdSequence.Modify;
                    if xStartTimeIssue[2] <> ProdSequence.StartTimeIssue then
                        if xStartTimeIssue[2] then
                            UpdateStartTimeIssue(ProdSequence, -1)
                        else
                            UpdateStartTimeIssue(ProdSequence, 1);
                end;
            until ProdSequence.Next = 0;

        ProdSequence.Reset;
        if ProdSequence.FindSet then begin
            repeat
                Rec := ProdSequence;
                Insert;
            until ProdSequence.Next = 0;
            EntryNo := ProdSequence."Entry No.";
        end else
            EntryNo := 0;

        MfgSetup.Get;
        if not Location.Get(LocCode) then
            Clear(Location);
        if Location."Normal Starting Time" = 0T then
            Location."Normal Starting Time" := MfgSetup."Normal Starting Time";
        if Location."Normal Ending Time" = 0T then
            Location."Normal Ending Time" := MfgSetup."Normal Ending Time";

        // P8001112
        BitmapStartEndTime[1] := CreateDateTime(ProdDate, Location."Normal Starting Time") - 7200000;
        if Location."Normal Ending Time" = 0T then
            BitmapStartEndTime[2] := CreateDateTime(ProdDate, Location."Normal Ending Time") + 93600000
        else
            BitmapStartEndTime[2] := CreateDateTime(ProdDate, Location."Normal Ending Time") + 7200000;
        //IF Location."Normal Starting Time" < 020000T THEN
        //  BitmapStartEndTime[1] := 000001T
        //ELSE
        //  BitmapStartEndTime[1] := Location."Normal Starting Time" - 7200000; // 2 Hours
        //IF (Location."Normal Ending Time" > 220000T) OR (Location."Normal Ending Time" = 0T) THEN
        //  BitmapStartEndTime[2] := 235959T
        //ELSE
        //  BitmapStartEndTime[2] := Location."Normal Ending Time" + 7200000; // 2 Hours
        // P8001112

        Reset;
        // SetRange(Level, 0); // P800-MegaApp
        if FindSet then begin
            BitmapFns.Initialize(BitmapStartEndTime[1], BitmapStartEndTime[2]); // P8001112

            repeat
                CreateBitmap;
                Modify;
            until Next = 0;
        end;

        Reset;
        SetCurrentKey("Resource Group", "Equipment Code", Level, "Sequence No.", "Starting Date-Time", "Ending Date-Time");
        if FindFirst then;
        CurrPage.Update(false);
    end;

    procedure CreateBitmap()
    var
        ProdSequence: Record "Production Sequencing";
        BitmapDef: Record "Bitmap Definition" temporary;
        BitmapDef2: Record "Bitmap Definition" temporary;
        LastTime: DateTime;
        Depth: Integer;
        OutStr: OutStream;
    begin
        // P800-MegaApp
        if level <> 0 then begin
            Timeline.CreateOutStream(OutStr);
            BitmapFns.CreateBitmap(OutStr, BitmapDef2);
            exit;
        end;
        // P800-MegaApp
        ProdSequence.Copy(Rec);
        ProdSequence."No. Of Entries" := 0;
        ProdSequence.Overlap := false;

        Reset;
        SetCurrentKey("Equipment Code", Level, "Starting Date-Time", "Ending Date-Time");
        SetRange("Equipment Code", "Equipment Code");
        SetRange(Level, 1);
        if FindSet then begin
            ProdSequence.Validate("Starting Date-Time", "Starting Date-Time");
            repeat
                ProdSequence."No. Of Entries" += 1;

                BitmapDef."Line No." += 1;
                BitmapDef.Start := "Starting Date-Time";
                BitmapDef.Depth := -1;
                BitmapDef.Insert;
                BitmapDef."Line No." += 1;
                BitmapDef.Start := "Ending Date-Time";
                BitmapDef.Depth := 1;
                BitmapDef.Insert;
            until Next = 0;
            ProdSequence.Validate("Ending Date-Time", "Ending Date-Time");

            LastTime := 0DT;
            BitmapDef.SetCurrentKey(Start, Depth);
            BitmapDef.FindSet;
            repeat
                if BitmapDef.Start > LastTime then begin
                    if BitmapDef2.Start <> 0DT then begin
                        BitmapDef2.Stop := BitmapDef.Start;
                        if Depth > 1 then
                            BitmapDef2.Color := BitmapDef2.Color::Red
                        else
                            BitmapDef2.Color := BitmapDef2.Color::Green;
                        if Depth > 0 then begin
                            BitmapDef2.Insert;
                            if BitmapDef2.Color = BitmapDef2.Color::Red then
                                ProdSequence.Overlap := true;
                        end;
                    end;
                    BitmapDef2."Line No." += 1;
                    BitmapDef2.Start := BitmapDef.Start;
                end;
                Depth -= BitmapDef.Depth;
                LastTime := BitmapDef.Start;
            until BitmapDef.Next = 0;

            ProdSequence.Timeline.CreateOutStream(OutStr); // P8001112
            BitmapFns.CreateBitmap(OutStr, BitmapDef2);     // P8001112
                                                            // P800-MegaApp
        end else begin
            ProdSequence.Timeline.CreateOutStream(OutStr);
            BitmapFns.CreateBitmap(OutStr, BitmapDef2);
            // P800-MegaApp
        end;


        //ProdSequence.Timeline.CREATEOUTSTREAM(OutStr); // P8001112
        //BitmapFns.CreateBitmap(OutStr,BitmapDef2);     // P8001112
        Rec.Copy(ProdSequence);
    end;

    procedure UpdateBitmap()
    var
        ProdSequence: Record "Production Sequencing";
    begin
        ProdSequence.Copy(Rec);
        Get(ProdSequence."Equipment Entry No.");
        CreateBitmap;
        Modify;
        Rec.Copy(ProdSequence);
    end;

    procedure Move(Direction: Integer)
    var
        ProdSequence: Record "Production Sequencing";
        SequenceNo: Integer;
    begin
        ProdSequence.Copy(Rec);
        Next(Direction);
        SequenceNo := "Sequence No.";
        "Sequence No." := ProdSequence."Sequence No.";
        Modify;
        Copy(ProdSequence);
        "Sequence No." := SequenceNo;
        Modify;
        CurrPage.Update(false); // P8000930
    end;

    procedure MoveEnabled()
    begin
        MoveUpEnabled := (Level <> 0) and ("Sequence No." <> 1);
        MoveDownEnabled := (Level <> 0) and ("Sequence No." <> "No. Of Entries");
    end;

    procedure Reschedule()
    var
        ProdSequence: Record "Production Sequencing";
        EqCode: Code[20];
        StartDateTime: DateTime;
        Duration: Duration;
        ChangesMade: Boolean;
        xStartTimeIssue: Boolean;
    begin
        CurrPage.SaveRecord;
        ProdSequence.Copy(Rec);
        CurrPage.SetSelectionFilter(Rec);

        if FindSet then begin
            EqCode := "Equipment Code";
            repeat
                if (Level = 0) and (Count > 1) then begin
                    Rec.Copy(ProdSequence);
                    Error(Text001);
                end;
                if EqCode <> "Equipment Code" then begin
                    Rec.Copy(ProdSequence);
                    Error(Text002);
                end;
            until Next = 0;

            if Level = 0 then begin
                Reset;
                SetCurrentKey("Resource Group", "Equipment Code", Level, "Sequence No.", "Starting Date-Time", "Ending Date-Time");
                SetRange("Equipment Code", "Equipment Code");
                SetRange(Level, 1);
            end;
        end;

        if FindSet then begin
            StartDateTime := "Starting Date-Time";
            repeat
                if StartDateTime <> "Starting Date-Time" then begin
                    xStartTimeIssue := StartTimeIssue; // P8000973
                    Duration := "Ending Date-Time" - "Starting Date-Time";
                    Validate("Starting Date-Time", StartDateTime);
                    Validate("Ending Date-Time", "Starting Date-Time" + Duration);
                    Modify;
                    UpdateDateTime;
                    // P8000973
                    if xStartTimeIssue <> StartTimeIssue then
                        if xStartTimeIssue then
                            UpdateStartTimeIssue(Rec, -1)
                        else
                            UpdateStartTimeIssue(Rec, 1);
                    // P8000973
                    UpdateEarliestLatestStart;
                    ChangesMade := true;
                end;
                StartDateTime := "Ending Date-Time";
            until Next = 0;

            if ChangesMade then
                UpdateBitmap;
        end;

        CurrPage.Update(false); // P8000973

        Rec.Copy(ProdSequence);
    end;

    procedure EditEvent()
    var
        ProdEvent: Page "Non-production Event";
        TimeDelta: Decimal;
    begin
        TestField(Type, Type::"Event");
        ProdEvent.SetData(Rec);
        if ProdEvent.RunModal = ACTION::OK then begin
            TimeDelta := -"Duration (Hours)";
            ProdEvent.GetData(Rec);
            TimeDelta += "Duration (Hours)";
            CurrPage.SaveRecord;

            UpdateDateTime;
            UpdateTotalTime(TimeDelta);
            UpdateBitmap;

            CurrPage.Update(false);
        end;
    end;

    procedure NewEvent()
    var
        ProdSequence: Record "Production Sequencing";
        ProdSequence2: Record "Production Sequencing";
        DailyProductionEvent: Record "Daily Production Event";
        ProdEvent: Page "Non-production Event";
    begin
        ProdSequence2 := Rec;

        ProdSequence."Equipment Code" := "Equipment Code";
        ProdSequence.Type := ProdSequence.Type::"Event";
        if Level = 0 then begin
            if "Starting Date-Time" = 0DT then
                ProdSequence.Validate("Starting Date-Time", CreateDateTime(ProdDate, Location."Normal Starting Time"))
            else
                ProdSequence.Validate("Starting Date-Time", "Starting Date-Time");
        end else
            ProdSequence.Validate("Starting Date-Time", "Ending Date-Time");
        ProdEvent.SetData(ProdSequence);
        if ProdEvent.RunModal = ACTION::OK then begin
            ProdEvent.GetData(ProdSequence);

            DailyProductionEvent."Production Date" := DT2Date(ProdSequence."Starting Date-Time");
            DailyProductionEvent."Equipment Code" := ProdSequence."Equipment Code";
            DailyProductionEvent."Event Code" := ProdSequence."Event Code";
            DailyProductionEvent."Duration (Hours)" := ProdSequence."Duration (Hours)";
            DailyProductionEvent."Start Time" := ProdSequence."Starting Time";
            DailyProductionEvent.Insert;

            EntryNo += 1;
            Init;
            "Entry No." := EntryNo;
            "Equipment Entry No." := ProdSequence2."Equipment Entry No.";
            "Equipment Code" := ProdSequence2."Equipment Code";
            Level := 1;
            Type := ProdSequence.Type::"Event";
            "Event Code" := ProdSequence."Event Code";
            "Order Status" := 0;
            "Order No." := '';
            "Line No." := DailyProductionEvent."Line No.";
            "Resource Group" := ProdSequence2."Resource Group";
            "Item No." := '';
            "Item Description" := '';
            Validate("Starting Date-Time", ProdSequence."Starting Date-Time");
            Validate("Ending Date-Time", ProdSequence."Ending Date-Time");
            "No. Of Entries" := ProdSequence2."No. Of Entries" + 1;
            SetDescription;
            "Sequence No." := ProdSequence2."Sequence No.";
            Resequence(1);

            "Sequence No." += 1;
            CreateBitmap; // P800-MegaApp
            Insert;

            UpdateTotalTime("Duration (Hours)");
            UpdateBitmap;
        end;
    end;

    procedure DeleteEvent()
    var
        DailyProductionEvent: Record "Daily Production Event";
    begin
        TestField(Type, Type::"Event");
        if Confirm(Text003, false, Description) then begin
            DailyProductionEvent.Get(DT2Date("Starting Date-Time"), "Equipment Code", "Event Code", "Line No.");
            DailyProductionEvent.Delete;

            Resequence(-1);
            Delete;

            UpdateTotalTime(-"Duration (Hours)");
            UpdateBitmap;

            FilterGroup(9);
            SetRange("Equipment Code", "Equipment Code");
            Find('><');
            SetRange("Equipment Code");
            FilterGroup(0);
        end;
    end;

    procedure Resequence(Delta: Integer)
    var
        ProdSequence: Record "Production Sequencing";
        Which: Text[1];
    begin
        ProdSequence.Copy(Rec);

        Reset;
        SetCurrentKey("Resource Group", "Equipment Code", Level, "Sequence No.");
        SetRange("Equipment Code", ProdSequence."Equipment Code");
        SetRange(Level, 1);
        if Delta < 0 then
            Which := '-'
        else
            Which := '+';
        if Find(Which) then
            repeat
                "No. Of Entries" += Delta;
                if "Sequence No." > ProdSequence."Sequence No." then
                    "Sequence No." += Delta;
                Modify;
            until Next(-Delta) = 0;

        Rec.Copy(ProdSequence);
    end;

    procedure UpdateDateTime()
    var
        DailyProductionEvent: Record "Daily Production Event";
        ProdOrder: Record "Production Order";
        ProdOrderMgmt: Codeunit "Process 800 Prod. Order Mgt.";
    begin
        if Type = Type::"Event" then begin
            DailyProductionEvent.Get(DT2Date("Starting Date-Time"), "Equipment Code", "Event Code", "Line No.");
            DailyProductionEvent."Duration (Hours)" := "Duration (Hours)";
            DailyProductionEvent."Start Time" := "Starting Time";
            DailyProductionEvent.Modify;
        end else begin
            ProdOrder.Get("Order Status", "Order No.");
            ProdOrderMgmt.AdjustProdOrderLineDates(ProdOrder, "Equipment Code", "Starting Date-Time", 0DT, 0);
        end;
    end;

    procedure UpdateTotalTime(Delta: Decimal)
    var
        ProdSequence: Record "Production Sequencing";
    begin
        if Delta = 0 then
            exit;

        ProdSequence.Copy(Rec);
        Get(ProdSequence."Equipment Entry No.");
        "Total Time (Hours)" += Delta;
        Modify;

        Rec.Copy(ProdSequence);
    end;

    procedure UpdateEarliestLatestStart()
    var
        ProdSequence: Record "Production Sequencing";
        ProdSequence2: Record "Production Sequencing";
        LatestStart: Time;
        EarliestStart: Time;
        xStartTimeIssue: Boolean;
    begin
        if Type = Type::"Event" then
            exit;

        ProdSequence.Copy(Rec);

        Reset;
        case ProdSequence."Order Type" of
            ProdSequence."Order Type"::Batch:
                begin
                    BatchPkgXref[1].Reset;
                    BatchPkgXref[1].SetRange(ID, "Entry No.");
                    if BatchPkgXref[1].FindSet then
                        repeat
                            Get(BatchPkgXref[1].LineNo);
                            xStartTimeIssue := StartTimeIssue;
                            ProdSequence2 := Rec;
                            ProdSequence2."Earliest Starting Time" := 0T;
                            BatchPkgXref[2].Reset;
                            BatchPkgXref[2].SetRange(LineNo, ProdSequence2."Entry No.");
                            if BatchPkgXref[2].FindSet then
                                repeat
                                    Get(BatchPkgXref[2].ID);
                                    EarliestStart := DT2Time("Starting Date-Time" + "First Line Duration");
                                    if (ProdSequence2."Earliest Starting Time" = 0T) or (EarliestStart < ProdSequence2."Earliest Starting Time") then
                                        ProdSequence2."Earliest Starting Time" := EarliestStart;
                                until BatchPkgXref[2].Next = 0;
                            Rec := ProdSequence2;
                            Modify;
                            if xStartTimeIssue <> StartTimeIssue then
                                if xStartTimeIssue then
                                    UpdateStartTimeIssue(Rec, -1)
                                else
                                    UpdateStartTimeIssue(Rec, 1);
                        until BatchPkgXref[1].Next = 0;
                end;
            ProdSequence."Order Type"::Package:
                begin
                    BatchPkgXref[1].Reset;
                    BatchPkgXref[1].SetRange(LineNo, "Entry No.");
                    if BatchPkgXref[1].FindSet then
                        repeat
                            Get(BatchPkgXref[1].ID);
                            xStartTimeIssue := StartTimeIssue;
                            ProdSequence2 := Rec;
                            ProdSequence2."Latest Starting Time" := 0T;
                            BatchPkgXref[2].Reset;
                            BatchPkgXref[2].SetRange(ID, ProdSequence2."Entry No.");
                            if BatchPkgXref[2].FindSet then
                                repeat
                                    Get(BatchPkgXref[2].LineNo);
                                    LatestStart := DT2Time("Starting Date-Time" - ProdSequence2."First Line Duration");
                                    if (ProdSequence2."Latest Starting Time" = 0T) or (LatestStart < ProdSequence2."Latest Starting Time") then
                                        ProdSequence2."Latest Starting Time" := LatestStart;
                                until BatchPkgXref[2].Next = 0;
                            Rec := ProdSequence2;
                            Modify;
                            if xStartTimeIssue <> StartTimeIssue then
                                if xStartTimeIssue then
                                    UpdateStartTimeIssue(Rec, -1)
                                else
                                    UpdateStartTimeIssue(Rec, 1);
                        until BatchPkgXref[1].Next = 0;
                end;
        end;

        Rec.Copy(ProdSequence);
    end;

    procedure UpdateStartTimeIssue(var ProdSequence: Record "Production Sequencing" temporary; Delta: Integer)
    var
        ProdSequence2: Record "Production Sequencing";
    begin
        ProdSequence2.Copy(ProdSequence);
        ProdSequence.Get(ProdSequence2."Equipment Entry No.");
        ProdSequence."Starting Time Issues" += Delta;
        ProdSequence.Modify;
        ProdSequence.Copy(ProdSequence2);
    end;

    procedure DrillOnEarliestLatestStart()
    var
        ProdSequence: Record "Production Sequencing";
        ProdSequence2: Record "Production Sequencing" temporary;
    begin
        ProdSequence.Copy(Rec);
        Reset;
        case ProdSequence."Order Type" of
            ProdSequence."Order Type"::Batch:
                begin
                    BatchPkgXref[1].Reset;
                    BatchPkgXref[1].SetRange(ID, ProdSequence."Entry No.");
                    if BatchPkgXref[1].FindSet then
                        repeat
                            Get(BatchPkgXref[1].LineNo);
                            ProdSequence2 := Rec;
                            ProdSequence2."First Line Duration" := ProdSequence."First Line Duration";
                            ProdSequence2.Insert;
                        until BatchPkgXref[1].Next = 0;
                end;
            ProdSequence."Order Type"::Package:
                begin
                    BatchPkgXref[1].Reset;
                    BatchPkgXref[1].SetRange(LineNo, ProdSequence."Entry No.");
                    if BatchPkgXref[1].FindSet then
                        repeat
                            Get(BatchPkgXref[1].ID);
                            ProdSequence2 := Rec;
                            ProdSequence2.Insert;
                        until BatchPkgXref[1].Next = 0;
                end;
        end;
        Rec.Copy(ProdSequence);

        if not ProdSequence2.IsEmpty then
            PAGE.RunModal(PAGE::"Production Sequence Drilldown", ProdSequence2);
    end;
}

