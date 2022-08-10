page 37002473 "Quick Planner"
{
    // PR1.20
    //   Correct handling of Cancel from Create Quick Planner
    // 
    // PR2.00
    //   Dimensions
    //   Order Status
    //   Create components for production orders
    // 
    // PR2.00.05
    //   Variant Code
    // 
    // PR3.10
    //   New Production Order table
    //   Exclude order from production schedule if item has production grouping no.
    // 
    // PR3.60.02
    //   Modify OnAfterValidate for Days View and Location Filter for SQL
    // 
    // PR3.70.06
    // P8000110A, Myers Nissi, Jack Reynolds, 08 SEP 04
    //   Standardize command and menu buttons
    // 
    // PR3.70.10
    // P8000209A, Myers Nissi, Jack Reynolds, 10 MAY 05
    //   Forward flush components for released orders
    // 
    // PR4.00
    // P8000197A, Myers Nissi, Jack Reynolds, 21 SEP 05
    //   ConfirmOrders - re-read produciton order line record after calculating the order
    // 
    // P8000259A, VerticalSoft, Jack Reynolds, 04 NOV 05
    //   Set default production sequence
    // 
    // PR4.00.03
    // P8000328A, VerticalSoft, Jack Reynolds, 01 MAY 06
    //   Modify to use workdate
    // 
    // PR4.00.06
    // P8000492A, VerticalSoft, Jack Reynolds, 03 JUL 07
    //   Support for transfer orders
    // 
    // PRW15.00.01
    // P8000518A, VerticalSoft, Jack Reynolds, 14 SEP 07
    //   When creating orders check for non-blank location if Location Mandatory is set
    // 
    // PRW15.00.03
    // P8000625A, VerticalSoft, Jack Reynolds, 20 AUG 08
    //   Fix problem with missing global dimensions on production order
    // 
    // PRW16.00.01
    // P8000661, VerticalSoft, Jack Reynolds, 22 JAN 09
    //   Fix problem with replenishment area not being set
    // 
    // PRW16.00.03
    // P8000796, VerticalSoft, Don Bresee, 01 APR 10
    //   Rework interface for NAV 2009
    // 
    // PRW16.00.04
    // P8000869, VerticalSoft, Jack Reynolds, 28 SEP 10
    //   Support for NAV forecast
    // 
    // P8000875, VerticalSoft, Jack Reynolds, 14 OCT 10
    //   Refactored, Suggested Date, Forecast Time Fence, Select Lines
    // 
    // PRW16.00.05
    // P8000948, Columbus IT, Jack Reynolds, 25 MAY 11
    //   Fix problem opening page with long location filter
    // 
    // P8000959, Columbus IT, Jack Reynolds, 21 JUN 11
    //   Default Forecast Name
    //   Fix problem calculating NAV forecast
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // P8001105, Columbus IT, Jack Reynolds, 15 OCT 12
    //   Fix problem with blank forecast name
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW17.10.02
    // P8001299, Columbus IT, Jack Reynolds, 26 FEB 14
    //   Add limited support for SKUS
    // 
    // P8001301, Columbus IT, Jack Reynolds, 03 MAR 14
    //   Update Rollup 4
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Quick Planner';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    Permissions = TableData "Prod. Order Line" = im,
                  TableData "Production Order" = im;
    SaveValues = true;
    SourceTable = "Quick Planner Worksheet";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(Control37002001)
            {
                ShowCaption = false;
                field(DaysView; DaysView)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Days View';

                    trigger OnValidate()
                    begin
                        if DaysView < 0 then
                            Error(Text000);
                        EndDate := WorkDate + DaysView; // P8000875
                        SetDates;                       // P8000875
                    end;
                }
                field(EndDate; EndDate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'End Date';

                    trigger OnValidate()
                    begin
                        // P8000875
                        if EndDate < WorkDate then
                            Error(Text002, WorkDate);
                        DaysView := EndDate - WorkDate;
                        SetDates;
                        // P8000875
                    end;
                }
                field(Shortages; Shortages)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Shortages Only';

                    trigger OnValidate()
                    begin
                        // P8000875
                        if Shortages then
                            SetFilter("Suggested Quantity", '>0')
                        else
                            SetRange("Suggested Quantity");
                        CurrPage.Update;
                    end;
                }
                field(LocationFilter; LocationFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Location Filter';
                    TableRelation = Location;

                    trigger OnValidate()
                    begin
                        // P8000875
                        SetFilter("Location Filter", LocationFilter);
                        CalcSheet;
                        CurrPage.Update(false);
                    end;
                }
                field(ForecastName; ForecastName)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Forecast Name';
                    TableRelation = "Production Forecast Name";
                    Visible = UseNAVForecast;

                    trigger OnValidate()
                    begin
                        // P80008
                        SetRange("Production Forecast Name", ForecastName); // P8001105
                        CalcSheet;
                        CurrPage.Update(false);
                        // P8000869
                    end;
                }
            }
            repeater(Control37002008)
            {
                ShowCaption = false;
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item Description"; "Item Description")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Suggested Quantity"; "Suggested Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Required Date"; "Required Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Actual Quantity"; "Actual Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Safety Stock"; "Safety Stock")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Qty. Available"; "Qty. Available")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Available';
                }
                field("On Hand"; "On Hand")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        OnHandDrillDown(LotStatusExclusionFilter); // P8001083
                    end;
                }
                field(Demand; Demand)
                {
                    ApplicationArea = FOODBasic;
                    Caption = '(-) Demand';
                }
                field("<Qty. on Forecast>"; "Qty. on Forecast")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '(-) Forecast';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        NAVForecastEntry: Record "Production Forecast Entry";
                        VPSForecastEntry: Record "Production Forecast";
                    begin
                        // P8000869
                        if UseNAVForecast then begin
                            NAVForecastEntry.SetCurrentKey("Production Forecast Name", "Item No.", "Location Code", "Variant Code",
                              "Forecast Date", "Component Forecast");
                            NAVForecastEntry.SetFilter("Production Forecast Name", GetFilter("Production Forecast Name"));
                            NAVForecastEntry.SetRange("Item No.", "Item No.");
                            NAVForecastEntry.SetRange("Variant Code", "Variant Code");
                            NAVForecastEntry.SetRange("Forecast Date", EarliestForecastDate, WorkDate + DaysView); // P8000875
                            NAVForecastEntry.SetFilter("Location Code", GetFilter("Location Filter"));
                            PAGE.RunModal(0, NAVForecastEntry);
                        end else begin
                            VPSForecastEntry.SetCurrentKey("Item No.", "Variant Code", Date, "Location Code");
                            VPSForecastEntry.SetRange("Item No.", "Item No.");
                            VPSForecastEntry.SetRange("Variant Code", "Variant Code");
                            VPSForecastEntry.SetRange(Date, EarliestForecastDate, WorkDate + DaysView); // P8000875
                            VPSForecastEntry.SetFilter("Location Code", GetFilter("Location Filter"));
                            PAGE.RunModal(0, VPSForecastEntry);
                        end;
                        // P8000869
                    end;
                }
                field("Qty. on Sales Order"; "Qty. on Sales Order")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '(-) Sales Order';
                    Visible = false;
                }
                field("Qty. on Transfer (Outbound)"; "Qty. on Transfer (Outbound)")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '(-) Transfer Order';
                    Visible = false;
                }
                field("Qty. Required For Production"; "Qty. Required For Production")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '(-) Prod. Reqmnts.';
                    Visible = false;
                }
                field(Orders; Orders)
                {
                    ApplicationArea = FOODBasic;
                    Caption = '(+)  Orders';
                }
                field("Qty. on Purchase Order"; "Qty. on Purchase Order")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '(+) Purch. Orders';
                    Visible = false;
                }
                field("Qty. on Transfer (Inbound)"; "Qty. on Transfer (Inbound)")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '(+) Transfer Order';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        TransInDrilldown(DaysView, LotStatusExclusionFilter); // P8001083
                    end;
                }
                field("Qty. on Production Order"; "Qty. on Production Order")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '(+) Prod. Order';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Item")
            {
                Caption = '&Item';
                action("&Card")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Card';
                    Image = Card;
                    RunObject = Page "Item Card";
                    RunPageLink = "No." = FIELD("Item No.");
                    ShortCutKey = 'Shift+F7';
                }
                action("Ledger E&ntries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Ledger E&ntries';
                    Image = LedgerEntries;
                    RunObject = Page "Item Ledger Entries";
                    RunPageLink = "Item No." = FIELD("Item No.");
                    RunPageView = SORTING("Item No.");
                    ShortCutKey = 'Ctrl+F7';
                }
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = CONST(Item),
                                  "No." = FIELD("Item No.");
                }
                separator(Separator1102603046)
                {
                    Caption = '';
                }
                action("&Units of Measure")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Units of Measure';
                    Image = UnitOfMeasure;
                    RunObject = Page "Item Units of Measure";
                    RunPageLink = "Item No." = FIELD("Item No.");
                }
            }
        }
        area(processing)
        {
            action("&Regenerate")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Regenerate';
                Ellipsis = true;
                Image = CalculateRegenerativePlan;

                trigger OnAction()
                begin
                    BuildWorksheet; // P8000110A
                end;
            }
            separator(Separator37002006)
            {
            }
            action("&Select")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Select';
                Image = SelectField;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'F9';

                trigger OnAction()
                begin
                    SelectLines; // P8000875
                end;
            }
            action("Create &Orders")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Create &Orders';
                Ellipsis = true;
                Image = CreateDocuments;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'F7';

                trigger OnAction()
                begin
                    ConfirmOrders; // P8000110A
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        ExcludePurch: Boolean;
        ExcludeSalesRet: Boolean;
        ExcludeOutput: Boolean;
    begin
        // P8001083
        Item.Get("Item No.");
        LotStatusMgmt.SetInboundExclusions(Item, LotStatus.FieldNo("Available for Planning"), ExcludePurch, ExcludeSalesRet, ExcludeOutput);
        LotStatusMgmt.AdjustQuickPlannerFlowFields(Rec, LotStatusExclusionFilter, true, false, ExcludePurch, ExcludeSalesRet, ExcludeOutput);
        // P8001083
    end;

    trigger OnOpenPage()
    var
        DefaultLocation: Code[10];
    begin
        // P8000875
        EndDate := WorkDate + DaysView;
        LotStatusExclusionFilter := LotStatusMgmt.SetLotStatusExclusionFilter(LotStatus.FieldNo("Available for Planning")); // P8001083

        ProcessSetup.Get;
        if Format(ProcessSetup."Forecast Time Fence") <> '' then
            EarliestForecastDate := CalcDate(ProcessSetup."Forecast Time Fence", WorkDate)
        else
            EarliestForecastDate := WorkDate;
        // P8000875
        SetRange("User ID", UserId);
        SetRange("Date Filter", WorkDate, EndDate); // P8000328A, P8000875
        // P8001030
        DefaultLocation := P800CoreFns.GetDefaultEmpLocation;
        if DefaultLocation <> '' then
            LocationFilter := DefaultLocation;
        // P8001030
        SetFilter("Location Filter", LocationFilter); // P8000948
        UseNAVForecast := P800Functions.ForecastInstalled; // P8000869
        if Shortages then
            SetFilter("Suggested Quantity", '>0')
        else
            SetRange("Suggested Quantity");
        // P8000959
        MfgSetup.Get;
        ForecastName := MfgSetup."Current Production Forecast";
        SetRange("Production Forecast Name", ForecastName); // P8001105
        // P8000959
        if not BuildWorksheet then
            Error('');
    end;

    var
        ProcessSetup: Record "Process Setup";
        MfgSetup: Record "Manufacturing Setup";
        InvSetup: Record "Inventory Setup";
        P800Functions: Codeunit "Process 800 Functions";
        P800CoreFns: Codeunit "Process 800 Core Functions";
        DaysView: Integer;
        EndDate: Date;
        Shortages: Boolean;
        Text000: Label 'Must be a positive integer.';
        Text001: Label 'Location must be specified.';
        LocationFilter: Code[50];
        ForecastName: Code[10];
        [InDataSet]
        UseNAVForecast: Boolean;
        Text002: Label 'Must be after %1.';
        EarliestForecastDate: Date;
        Item: Record Item;
        LotStatus: Record "Lot Status Code";
        LotStatusMgmt: Codeunit "Lot Status Management";
        LotStatusExclusionFilter: Text[1024];
        Text003: Label 'Calculating Items: #1#############';

    procedure BuildWorksheet(): Boolean
    var
        Loc: Record Location;
        CreateWorksheet: Report "Create Quick Planner Worksheet";
        Location: Code[11];
    begin
        // P8001299
        Location := CopyStr(GetFilter("Location Filter"), 1, 11);
        if StrLen(Location) <= 10 then
            if Loc.Get(Location) then
                CreateWorksheet.SetLocation(Location);
        // P8001299
        CreateWorksheet.RunModal;
        if CreateWorksheet.ReportProcessed then begin // PR1.20
            CalcSheet;
            exit(true);                                 // PR1.20
        end;                                          // PR1.20
    end;

    local procedure SetDates()
    begin
        SetRange("Date Filter", WorkDate, EndDate); // P8000328A, P8000875
        CalcSheet;
        CurrPage.Update(false);
    end;

    procedure CalcSheet()
    var
        WorkSheet: Record "Quick Planner Worksheet";
        Window: Dialog;
    begin
        CopyFilter("User ID", WorkSheet."User ID");
        CopyFilter("Date Filter", WorkSheet."Date Filter");
        CopyFilter("Location Filter", WorkSheet."Location Filter");
        CopyFilter("Production Forecast Name", WorkSheet."Production Forecast Name"); // P8000959
        Window.Open(Text003); // P8001299
        if WorkSheet.Find('-') then
            repeat
                Window.Update(1, WorkSheet."Item No."); // P8001299
                WorkSheet.Calculate(UseNAVForecast, EarliestForecastDate, LotStatusExclusionFilter); // P8000875, P8001083
                WorkSheet.Modify;
            until WorkSheet.Next = 0;
        Window.Close; // P8001299
    end;

    procedure SelectLines()
    var
        Worksheet: Record "Quick Planner Worksheet";
    begin
        // P8000875
        CurrPage.SetSelectionFilter(Worksheet);
        if Worksheet.FindSet then begin
            repeat
                Worksheet."Actual Quantity" := Worksheet."Suggested Quantity";
                Worksheet."Due Date" := Worksheet."Required Date";
                Worksheet.Modify;
            until Worksheet.Next = 0;
            CurrPage.Update(false);
        end;
    end;

    procedure ConfirmOrders()
    var
        MfgSetup: Record "Manufacturing Setup";
        Loc: Record Location;
        WorkSheet: Record "Quick Planner Worksheet";
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        Item: Record Item;
        InvSetup: Record "Inventory Setup";
        CreateOrder: Page "Create Production Orders";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        CalcProdOrder: Codeunit "Calculate Prod. Order";
        ProdOrderStatusMgt: Codeunit "Prod. Order Status Management";
        DimMgt: Codeunit DimensionManagement;
        Location: Code[11];
        Status: Integer;
        Direction: Integer;
        DimensionSetIDArr: array[10] of Integer;
        NoSeries: Code[10];
    begin
        // P8001299
        Location := CopyStr(GetFilter("Location Filter"), 1, 11);
        if StrLen(Location) > 10 then
            Location := ''
        else
            if not Loc.Get(Location) then
                Location := '';
        // P8001299
        // P8000110A Begin
        WorkSheet.Copy(Rec);
        WorkSheet.SetFilter("Due Date", '<>%1', 0D);
        WorkSheet.SetFilter("Actual Quantity", '>0');
        // P8000110A End

        CreateOrder.SetVariables(Location, ProdOrder.Status::Planned, WorkSheet.Count); // P8000110A, P8000875, P8001299
        if CreateOrder.RunModal <> ACTION::Yes then
            exit;

        // PR2.00 Begin
        CreateOrder.ReturnVariables(Location, Direction, Status, DimensionSetIDArr[1]); // P8001133

        MfgSetup.Get;
        case Status of
            // P8000875
            ProdOrder.Status::Planned:
                begin
                    MfgSetup.TestField("Planned Order Nos.");
                    NoSeries := MfgSetup."Planned Order Nos.";
                end;
            // P8000875
            ProdOrder.Status::"Firm Planned":
                begin
                    MfgSetup.TestField("Firm Planned Order Nos.");
                    NoSeries := MfgSetup."Firm Planned Order Nos.";
                end;
            ProdOrder.Status::Released:
                begin
                    MfgSetup.TestField("Released Order Nos.");
                    NoSeries := MfgSetup."Released Order Nos.";
                end;
        end;
        // PR2.00 End

        // P8000518A
        InvSetup.Get;
        if InvSetup."Location Mandatory" and (Location = '') then
            Error(Text001);
        // P8000518A

        //WorkSheet.COPY(Rec);
        with WorkSheet do begin
            //  SETFILTER("Due Date",'<>%1',0D);
            //  SETFILTER("Actual Quantity",'>0');
            if Find('-') then begin
                repeat
                    Item.Get("Item No.");
                    Clear(ProdOrder);
                    Clear(ProdOrderLine);
                    ProdOrder.Init;
                    NoSeriesMgt.InitSeries(NoSeries, '', "Due Date", ProdOrder."No.", ProdOrder."No. Series");
                    ProdOrder.Validate(Status, Status);
                    ProdOrder.Insert(true);

                    ProdOrder."Starting Date" := WorkDate;
                    ProdOrder."Creation Date" := WorkDate;
                    ProdOrder."Due Date" := "Due Date";
                    ProdOrder."Ending Date" := "Due Date" - 1;
                    ProdOrder."Low-Level Code" := 1;
                    ProdOrder."Source Type" := ProdOrder."Source Type"::Item;
                    ProdOrder.Validate("Source No.", "Item No.");
                    ProdOrder.Validate("Variant Code", "Variant Code"); // PR2.00.05
                    ProdOrder.Validate("Location Code", Location); // P8000661
                    ProdOrder.Quantity := "Actual Quantity";
                    ProdOrder."Exclude From Prod. Sched." := Item."Production Grouping Item" <> ''; // PR3.10
                                                                                                    // P8001133
                    DimensionSetIDArr[2] := ProdOrder."Dimension Set ID";
                    ProdOrder."Dimension Set ID" :=
                      DimMgt.GetCombinedDimensionSetID(DimensionSetIDArr, ProdOrder."Shortcut Dimension 1 Code", ProdOrder."Shortcut Dimension 2 Code");
                    // P8001133
                    ProdOrder.Modify;
                    ProdOrder.Find; // P8000625A
                    ProdOrder.SetRange("No.", ProdOrder."No.");

                    ProdOrderLine.Init;
                    ProdOrderLine.Status := ProdOrder.Status;
                    ProdOrderLine."Prod. Order No." := ProdOrder."No.";
                    ProdOrderLine."Line No." := 10000;
                    ProdOrderLine."Routing Reference No." := ProdOrderLine."Line No.";
                    ProdOrderLine.Validate("Item No.", Item."No.");
                    ProdOrderLine.Validate("Variant Code", "Variant Code"); // PR2.00.05
                    ProdOrderLine."Location Code" := ProdOrder."Location Code";
                    ProdOrderLine."Scrap %" := Item."Scrap %";
                    ProdOrderLine."Due Date" := ProdOrder."Due Date";
                    ProdOrderLine."Starting Date" := ProdOrder."Starting Date";
                    ProdOrderLine."Starting Time" := ProdOrder."Starting Time";
                    ProdOrderLine."Ending Date" := ProdOrder."Ending Date";
                    ProdOrderLine."Ending Time" := ProdOrder."Ending Time";
                    ProdOrderLine."Planning Level Code" := 0;
                    ProdOrderLine."Inventory Posting Group" := Item."Inventory Posting Group";
                    ProdOrderLine.Validate("Unit Cost");
                    ProdOrderLine.Validate(Quantity, "Actual Quantity");
                    ProdOrderLine.Validate("Unit of Measure Code", "Unit of Measure Code");
                    ProdOrderLine.UpdateDatetime;
                    ProdOrderLine.Insert(true);

                    CalcProdOrder.Calculate(ProdOrderLine, Direction, true, true, true, true); // P8001301
                    ProdOrderLine.Find; // P8000197A

                    WorkSheet."Due Date" := 0D;
                    WorkSheet.Calculate(UseNAVForecast, EarliestForecastDate, LotStatusExclusionFilter); // P8000875, P8001083
                    Modify;

                    ProdOrder.SetDefaultProductionSequence; // P8000259A
                    ProdOrder.Modify;                       // P8000259A

                    if ProdOrder.Status = ProdOrder.Status::Released then                     // P8000209A
                        ProdOrderStatusMgt.FlushProdOrder(ProdOrder, ProdOrder.Status, WorkDate); // P8000209A
                until Next = 0;
            end;
        end;
    end;
}

