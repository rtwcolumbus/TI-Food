page 37002505 "Daily Prod. Planning-Equipment"
{
    // PRW16.00.03
    // P8000789, VerticalSoft, Rick Tweedle, 10 MAR 10
    //   Created page - based upon form version
    // 
    // PRW16.00.06
    // P8001086, Columbus IT, Jack Reynolds, 08 AUG 12
    //   Fixes to page refresh issues
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW18.00
    // P8001352, Columbus IT, Jack Reynolds, 11 NOV 14
    //   Fix problem with ItemTypeFilter
    // 
    // PRW18.00.01
    // P8001386, Columbus IT, Jack Reynolds, 27 MAY 15
    //   Renamed NAV Food client addins
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW111.00
    // P80059471, To Increase, Jack Reynolds, 25 JUN 18
    //   Upgrade signal control for JavaScript
    //   Cleanup Timer references
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Daily Prod. Planning-Equipment';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;
    PromotedActionCategories = 'New,Process,Report,Related Info';
    SourceTable = Resource;

    layout
    {
        area(content)
        {
            group(Filters)
            {
                Caption = 'Filters';
                field("Base Date"; BaseDate)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Days View"; DaysView)
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        DaysViewOnAfterValidate;
                    end;
                }
                field("Over Capacity Only"; OverCapacityOnly)
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        OverCapacityOnAfterValidate;
                    end;
                }
                field("Resource Group Filter"; ResourceGroupFilter)
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ResRec: Record "Resource Group";
                        ResPg: Page "Resource Groups";
                    begin
                        ResPg.LookupMode := true;
                        ResPg.Editable := false;
                        if (ResPg.RunModal = ACTION::LookupOK) then begin
                            ResPg.GetRecord(ResRec);
                            Text := ResRec."No.";
                            exit(true);
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        if ResourceGroupFilter = '' then
                            SetRange("Resource Group No.")
                        else
                            SetFilter("Resource Group No.", ResourceGroupFilter);
                    end;
                }
                // usercontrol(Signal; "TI.NAVFood.Controls.SignalWeb")
                // {

                //     trigger AddInReady(guid: Text)
                //     begin
                //         // P80059471
                //         SignalFns.SetControl(2, guid, CurrPage.Signal);
                //         CurrPage.Signal.SetInterval(1);
                //     end;

                //     trigger OnSignal()
                //     begin
                //         // P80059471
                //         CurrPage.Update(false);
                //     end;
                // }
            }
            group(Control37002008)
            {
                Caption = 'Equipment';
                repeater(Control37002013)
                {
                    FreezeColumn = "Unit of Measure";
                    ShowCaption = false;
                    field("No."; "No.")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field(Name; Name)
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Unit of Measure"; "Base Unit of Measure")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field(AvailDate1; Qty[1])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = AvailCaption[1];
                        Style = Attention;
                        StyleExpr = itemAvailColourFlag01;

                        trigger OnDrillDown()
                        begin
                            DrillDown(AvailDate[1]);
                        end;
                    }
                    field(AvailDate2; Qty[2])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = AvailCaption[2];
                        Style = Attention;
                        StyleExpr = itemAvailColourFlag02;

                        trigger OnDrillDown()
                        begin
                            DrillDown(AvailDate[2]);
                        end;
                    }
                    field(AvailDate3; Qty[3])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = AvailCaption[3];
                        Style = Attention;
                        StyleExpr = itemAvailColourFlag03;

                        trigger OnDrillDown()
                        begin
                            DrillDown(AvailDate[3]);
                        end;
                    }
                    field(AvailDate4; Qty[4])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = AvailCaption[4];
                        Style = Attention;
                        StyleExpr = itemAvailColourFlag04;

                        trigger OnDrillDown()
                        begin
                            DrillDown(AvailDate[4]);
                        end;
                    }
                    field(AvailDate5; Qty[5])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = AvailCaption[5];
                        Style = Attention;
                        StyleExpr = itemAvailColourFlag05;

                        trigger OnDrillDown()
                        begin
                            DrillDown(AvailDate[5]);
                        end;
                    }
                    field(AvailDate6; Qty[6])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = AvailCaption[6];
                        Style = Attention;
                        StyleExpr = IncludesProdChanges;

                        trigger OnDrillDown()
                        begin
                            DrillDown(AvailDate[6]);
                        end;
                    }
                    field(AvailDate7; Qty[7])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = AvailCaption[7];
                        Style = Attention;
                        StyleExpr = IncludesProdChanges;

                        trigger OnDrillDown()
                        begin
                            DrillDown(AvailDate[7]);
                        end;
                    }
                    field(AvailDate8; Qty[8])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = AvailCaption[8];
                        Style = Attention;
                        StyleExpr = IncludesProdChanges;

                        trigger OnDrillDown()
                        begin
                            DrillDown(AvailDate[8]);
                        end;
                    }
                    field(AvailDate9; Qty[9])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = AvailCaption[9];
                        Style = Attention;
                        StyleExpr = IncludesProdChanges;

                        trigger OnDrillDown()
                        begin
                            DrillDown(AvailDate[9]);
                        end;
                    }
                    field(AvailDate10; Qty[10])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = AvailCaption[10];
                        Style = Attention;
                        StyleExpr = IncludesProdChanges;

                        trigger OnDrillDown()
                        begin
                            DrillDown(AvailDate[10]);
                        end;
                    }
                    field(AvailDate11; Qty[11])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = AvailCaption[11];
                        Style = Attention;
                        StyleExpr = IncludesProdChanges;

                        trigger OnDrillDown()
                        begin
                            DrillDown(AvailDate[11]);
                        end;
                    }
                    field(AvailDate12; Qty[12])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = AvailCaption[12];
                        Style = Attention;
                        StyleExpr = IncludesProdChanges;

                        trigger OnDrillDown()
                        begin
                            DrillDown(AvailDate[12]);
                        end;
                    }
                    field(AvailDate13; Qty[13])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = AvailCaption[13];
                        Style = Attention;
                        StyleExpr = IncludesProdChanges;

                        trigger OnDrillDown()
                        begin
                            DrillDown(AvailDate[13]);
                        end;
                    }
                    field(AvailDate14; Qty[14])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = AvailCaption[14];
                        Style = Attention;
                        StyleExpr = IncludesProdChanges;

                        trigger OnDrillDown()
                        begin
                            DrillDown(AvailDate[14]);
                        end;
                    }
                    field(AvailDate15; Qty[15])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = AvailCaption[15];
                        Style = Attention;
                        StyleExpr = IncludesProdChanges;

                        trigger OnDrillDown()
                        begin
                            DrillDown(AvailDate[15]);
                        end;
                    }
                    field(AvailDate16; Qty[16])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = AvailCaption[16];
                        Style = Attention;
                        StyleExpr = IncludesProdChanges;

                        trigger OnDrillDown()
                        begin
                            DrillDown(AvailDate[16]);
                        end;
                    }
                    field(AvailDate17; Qty[17])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = AvailCaption[17];
                        Style = Attention;
                        StyleExpr = IncludesProdChanges;

                        trigger OnDrillDown()
                        begin
                            DrillDown(AvailDate[17]);
                        end;
                    }
                    field(AvailDate18; Qty[18])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = AvailCaption[18];
                        Style = Attention;
                        StyleExpr = IncludesProdChanges;

                        trigger OnDrillDown()
                        begin
                            DrillDown(AvailDate[18]);
                        end;
                    }
                }
            }
            part(ProdLines; "Daily Prod. Planning")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "Equipment Code" = FIELD("No."),
                              "Line No." = FILTER(> 0);
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Previous Date")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Previous Date';
                Enabled = PrevEnabled;
                Image = PreviousSet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    dateMultiplier -= 1;
                    PrevEnabled := dateMultiplier > 0;
                    if dateMultiplier < 0 then
                        dateMultiplier := 0;

                    SetDateRange;
                end;
            }
            action("Next Date")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Next Date';
                Image = NextSet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    dateMultiplier += 1;
                    PrevEnabled := dateMultiplier > 0;
                    SetDateRange;
                end;
            }
            action(Recalculate)
            {
                ApplicationArea = FOODBasic;
                Image = Recalculate;

                trigger OnAction()
                begin
                    CurrPage.ProdLines.PAGE.Recalculate;
                end;
            }
            action(Update)
            {
                ApplicationArea = FOODBasic;
                Image = Change;

                trigger OnAction()
                begin
                    InitializeBoard;
                    //CurrPage.Equip.InitializeBoard
                end;
            }
            action(CommitChanges)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Commit Changes';
                Image = Save;
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    CurrPage.ProdLines.PAGE.CommitChanges;
                end;
            }
        }
        area(navigation)
        {
            group(Equipment)
            {
                Caption = 'Equipment';
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;
                    RunObject = Page "Resource Card";
                    RunPageLink = "No." = FIELD("No.");
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Qty[1] := EquipAvailability("No.", AvailDate[1], itemAvailColourFlag01);
        Qty[2] := EquipAvailability("No.", AvailDate[2], itemAvailColourFlag02);
        Qty[3] := EquipAvailability("No.", AvailDate[3], itemAvailColourFlag03);
        Qty[4] := EquipAvailability("No.", AvailDate[4], itemAvailColourFlag04);
        Qty[5] := EquipAvailability("No.", AvailDate[5], itemAvailColourFlag05);
        Qty[6] := EquipAvailability("No.", AvailDate[6], itemAvailColourFlag06);
        Qty[7] := EquipAvailability("No.", AvailDate[7], itemAvailColourFlag07);
        Qty[8] := EquipAvailability("No.", AvailDate[8], itemAvailColourFlag08);
        Qty[9] := EquipAvailability("No.", AvailDate[9], itemAvailColourFlag09);
        Qty[10] := EquipAvailability("No.", AvailDate[10], itemAvailColourFlag10);
        Qty[11] := EquipAvailability("No.", AvailDate[11], itemAvailColourFlag11);
        Qty[12] := EquipAvailability("No.", AvailDate[12], itemAvailColourFlag12);
        Qty[13] := EquipAvailability("No.", AvailDate[13], itemAvailColourFlag13);
        Qty[14] := EquipAvailability("No.", AvailDate[14], itemAvailColourFlag14);
        Qty[15] := EquipAvailability("No.", AvailDate[15], itemAvailColourFlag15);
        Qty[16] := EquipAvailability("No.", AvailDate[16], itemAvailColourFlag16);
        Qty[17] := EquipAvailability("No.", AvailDate[17], itemAvailColourFlag17);
        Qty[18] := EquipAvailability("No.", AvailDate[18], itemAvailColourFlag18);
    end;

    trigger OnClosePage()
    begin
        //parentCU."Dis/EnableTimer"(TRUE);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        Direction: Integer;
        EOF: Boolean;
        i: Integer;
    begin
        TempResource.Copy(Rec);

        if not OverCapacityOnly then begin
            if not TempResource.Find(Which) then
                exit(false);
            Rec.Copy(TempResource);
            exit(true);
        end else begin
            for i := 1 to StrLen(Which) do begin
                EOF := false;
                case Which[i] of
                    '-', '>':
                        Direction := 1;
                    '+', '<':
                        Direction := -1;
                    '=':
                        Direction := 0;
                end;
                EOF := not TempResource.Find(CopyStr(Which, i, 1));
                while (not EOF) and (not EquipBoardMgt.ShowRecord(TempResource."No.", OverCapacityOnly)) do
                    EOF := TempResource.Next(Direction) = 0;
                if not EOF then begin
                    Rec.Copy(TempResource);
                    exit(true);
                end;
            end;
        end;
    end;

    trigger OnInit()
    begin
        ItemTypeFilterText := '*';
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        NextRec: Record Resource;
        Direction: Integer;
        NoSteps: Integer;
        StepsTaken: Integer;
        EOF: Boolean;
    begin
        TempResource.Copy(Rec);

        if not OverCapacityOnly then begin
            StepsTaken := TempResource.Next(Steps);
            if StepsTaken <> 0 then
                Rec.Copy(TempResource);
            exit(StepsTaken);
        end else begin
            NextRec := Rec;
            Direction := 1;
            if Steps < 0 then
                Direction := -1;
            NoSteps := Direction * Steps;
            while (StepsTaken < NoSteps) and (not EOF) do begin
                EOF := TempResource.Next(Direction) = 0;
                if (not EOF) and EquipBoardMgt.ShowRecord(TempResource."No.", OverCapacityOnly) then begin
                    NextRec := TempResource;
                    StepsTaken += 1;
                end;
            end;
            Rec := NextRec;
            exit(Direction * StepsTaken);
        end;
    end;

    trigger OnOpenPage()
    begin
        if not parametersSetup then begin  // P8000789
            BaseDate := WorkDate;
            if DaysView = 0 then
                DaysView := 15;
        end;                               // P8000789
        OverCapacityOnly := false;

        SetDateRange;
        FillTempResource;                                                               // P8000789
        //CurrPage.ProdLines.FORM.SetCommonEquipCodeunits(EquipBoardMgt,dailyPlanFuncs);  // P8000789

        CurrPage.ProdLines.PAGE.SetSignalFns(SignalFns); // P8001086
    end;

    var
        preRequiredItem: Record Item;
        BaseDate: Date;
        BegEndDate: array[2] of Date;
        AvailDate: array[18] of Date;
        VariantFilter: Code[250];
        LocationFilter: Code[250];
        ItemCategoryFilter: Code[250];
        ProductGroupFilter: Code[250];
        ResourceGroupFilter: Code[250];
        Text001: Label '<Weekday Text,3> <Month>/<Day>';
        AvailCaption: array[18] of Text[80];
        ItemTypeFilterText: Text[250];
        Text003: Label 'This will commit all pending changes.\Continue?';
        ItemTypeFilter: Option "* MULTIPLE *"," ","(blank)","Raw Material",Packaging,Intermediate,"Finished Good",Container;
        dateMultiplier: Integer;
        DaysView: Integer;
        [InDataSet]
        IncludesProdChanges: Boolean;
        OverCapacityOnly: Boolean;
        [InDataSet]
        PrevEnabled: Boolean;
        overCapactity: Boolean;
        "-- Item Avail.Colour Flags --": Integer;
        [InDataSet]
        itemAvailColourFlag01: Boolean;
        [InDataSet]
        itemAvailColourFlag02: Boolean;
        [InDataSet]
        itemAvailColourFlag03: Boolean;
        [InDataSet]
        itemAvailColourFlag04: Boolean;
        [InDataSet]
        itemAvailColourFlag05: Boolean;
        [InDataSet]
        itemAvailColourFlag06: Boolean;
        [InDataSet]
        itemAvailColourFlag07: Boolean;
        [InDataSet]
        itemAvailColourFlag08: Boolean;
        [InDataSet]
        itemAvailColourFlag09: Boolean;
        [InDataSet]
        itemAvailColourFlag10: Boolean;
        [InDataSet]
        itemAvailColourFlag11: Boolean;
        [InDataSet]
        itemAvailColourFlag12: Boolean;
        [InDataSet]
        itemAvailColourFlag13: Boolean;
        [InDataSet]
        itemAvailColourFlag14: Boolean;
        [InDataSet]
        itemAvailColourFlag15: Boolean;
        [InDataSet]
        itemAvailColourFlag16: Boolean;
        [InDataSet]
        itemAvailColourFlag17: Boolean;
        [InDataSet]
        itemAvailColourFlag18: Boolean;
        "-": Integer;
        TempResource: Record Resource temporary;
        EquipBoard: Record "Equipment Board";
        VersionMgt: Codeunit VersionManagement;
        EquipBoardMgt: Codeunit "Equipment Board Management";
        ItemForMarking: Code[20];
        parametersSetup: Boolean;
        Qty: array[18] of Text[30];
        SignalFns: Codeunit "Process 800 Signal Functions";

    procedure SetDateRange()
    var
        dateFrm: Text[30];
        dateFrm2: Text[30];
        dateRec: Record Date;
        c: Integer;
    begin
        dateFrm := '+' + Format(dateMultiplier * DaysView) + 'D';
        dateFrm2 := '+' + Format(dateMultiplier * DaysView) + 'D +' + Format(DaysView - 1) + 'D';
        BegEndDate[1] := CalcDate(dateFrm, BaseDate);
        BegEndDate[2] := CalcDate(dateFrm2, BaseDate);
        dateRec.SetRange("Period Type", dateRec."Period Type"::Date);
        dateRec.SetRange("Period Start", BegEndDate[1], BegEndDate[2]);
        for c := 1 to ArrayLen(AvailCaption, 1) do begin
            AvailCaption[c] := 'n/a';
            AvailDate[c] := 0D;
        end;
        c := 0;
        if dateRec.FindFirst then
            repeat
                c += 1;
                AvailDate[c] := dateRec."Period Start";
                AvailCaption[c] := Format(dateRec."Period Start", 0, Text001);
            until (dateRec.Next = 0) or (c = ArrayLen(AvailDate, 1));
        //CurrPage.ItemMatrix.MatrixRec.SETRANGE("Period Start",BegDate,EndDate);
        InitializeBoard;
    end;

    procedure OverCapacityOnAfterValidate()
    begin
        CurrPage.Update(false);
    end;

    procedure DaysViewOnAfterValidate()
    begin
        SetDateRange;
    end;

    procedure FillTempResource()
    var
        Resource: Record Resource;
    begin
        TempResource.Reset;
        TempResource.DeleteAll;

        Clear(TempResource);
        TempResource.Insert;

        Resource.SetRange(Type, Resource.Type::Machine);
        if Resource.Find('-') then
            repeat
                TempResource := Resource;
                TempResource.Insert;
            until Resource.Next = 0;
    end;

    procedure InitializeBoard()
    begin
        //EquipBoardMgt.Initialize(BegEndDate[1],0,1 + (BegEndDate[2] - BegEndDate[1])); // P8001086
        CurrPage.Update(false); // P8000263A
    end;

    procedure EquipAvailability(EquipCode: Code[20]; iDate: Date; var iColourFlag: Boolean): Text[30]
    var
        DateOffset: Integer;
        Avail: Decimal;
    begin
        if iDate = 0D then
            exit('');
        DateOffset := iDate - BegEndDate[1];
        EquipBoardMgt.GetData(EquipCode, DateOffset, EquipBoard."Data Element"::Available, Avail, IncludesProdChanges);
        iColourFlag := IncludesProdChanges;  // P8000789
        exit(EquipBoardMgt.FormatDuration(Avail));
    end;

    procedure DrillDown(iDate: Date)
    begin
        if "No." = '' then
            exit;
        //EquipBoardMgt.DrillDown("No.",(iDate - BegEndDate[1]),EquipBoard."Data Element"::Available);  // P8000789
        // P8000789

        EquipBoardMgt.DrillDown("No.",
                                (iDate - CalcDate(('+' + Format(dateMultiplier * DaysView) + 'D'), BaseDate)),
                                EquipBoard."Data Element"::Available);
        // P8000789
    end;

    procedure MarkForBOM(ItemNo: Code[20]; var OverCapacity: Boolean)
    var
        Item: Record Item;
        Equipment2: Record Resource;
        BOMEquip: Record "Prod. BOM Equipment";
    begin
        if ItemNo = ItemForMarking then
            exit;

        Equipment2.Copy(Rec); // To preserve location filter
        Reset;
        OverCapacityOnly := false;
        Equipment2.CopyFilter("Location Code", "Location Code");

        if ItemNo <> '' then begin
            Item.Get(ItemNo);
            BOMEquip.Reset;
            BOMEquip.SetRange("Production Bom No.", Item."Production BOM No.");
            BOMEquip.SetRange("Version Code", VersionMgt.GetBOMVersion(Item."Production BOM No.", WorkDate, true));
            if BOMEquip.Find('-') then
                repeat
                    Get(BOMEquip."Resource No.");
                    Mark(true);
                until BOMEquip.Next = 0;
            MarkedOnly(true);
        end;

        CurrPage.Update(false);

        OverCapacity := OverCapacityOnly;
        ItemForMarking := ItemNo;
    end;

    procedure SetDateParameters(idateMultiplier: Integer; iDaysView: Integer; iBaseDate: Date)
    begin
        dateMultiplier := idateMultiplier;
        DaysView := iDaysView;
        BaseDate := iBaseDate;
        parametersSetup := true;
    end;

    procedure SetSharedObjects(var SalesBoard: Codeunit "Sales Board Management"; var EquipBoard: Codeunit "Equipment Board Management"; var ProdPlan: Record "Daily Production Planning" temporary)
    begin
        // P8001086
        EquipBoardMgt := EquipBoard;
        CurrPage.ProdLines.PAGE.SetSharedCodeunits(SalesBoard, EquipBoard, PAGE::"Daily Prod. Planning-Equipment");
        CurrPage.ProdLines.PAGE.SetRecords(ProdPlan);
    end;
}

