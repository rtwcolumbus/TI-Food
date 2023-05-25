page 37002503 "Daily Production Planning"
{
    // PRW16.00.03
    // P8000789, VerticalSoft, Rick Tweedle, 10 MAR 10
    //   Created page - based upon form version
    // 
    // PRW16.00.06
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
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
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // P8008034, To-Increase, Jack Reynolds, 07 DEC 16
    //   Update missing captions
    // 
    // P8007748, To-Increase, Jack Reynolds, 16 JAN 17
    //   Correct misspellings
    // 
    // PRW111.00
    // P80059471, To Increase, Jack Reynolds, 25 JUN 18
    //   Upgrade signal control for JavaScript
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 28 APR 22
    //   Removing support for Signal Functions codeunit

    ApplicationArea = FOODBasic;
    Caption = 'Daily Production Planning';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;
    SaveValues = true;
    SourceTable = Item;
    UsageCategory = Tasks;

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
                    Caption = 'Base Date';
                    Editable = false;
                }
                field("Days View"; DaysView)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Days View';

                    trigger OnValidate()
                    begin
                        SetDateRange; // P8007749
                    end;
                }
                field("Location Filter"; LocationFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Location Filter';
                    TableRelation = Location;

                    trigger OnValidate()
                    begin
                        SetLocationFilter; // P8007749
                        CurrPage.Update;   // P8007749
                    end;
                }
                field("Shortages Only"; ShortagesOnly)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Shortages Only';

                    trigger OnValidate()
                    begin
                        CurrPage.Update; // P8007749
                    end;
                }
            }
            group("Additional Filters")
            {
                field("Item Type Filter"; ItemTypeFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Type Filter';
                    OptionCaption = ' ,(blank),Raw Material,Packaging,Intermediate,Finished Good,Container,Spare';

                    trigger OnValidate()
                    begin
                        SetItemTypeFilter; // P8007749
                        CurrPage.Update;   // P8007749
                    end;
                }
                field("Item Category Filter"; ItemCategoryFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Category Filter';
                    TableRelation = "Item Category";

                    trigger OnValidate()
                    begin
                        SetItemCategoryFilter; // P8007749
                        CurrPage.Update;       // P8007749
                    end;
                }
                field("Variant Filter"; VariantFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Variant Filter';
                    TableRelation = Variant;

                    trigger OnValidate()
                    begin
                        SetVariantFilter; // P8007749
                        CurrPage.Update;  // P8007749
                    end;
                }
            }
            group(Items)
            {
                Caption = 'Items';
                repeater(Control37002013)
                {
                    FreezeColumn = "Unit of Measure";
                    ShowCaption = false;
                    field("No."; "No.")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field(Description; Description)
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Unit of Measure"; "Base Unit of Measure")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field(Allergens; AllergenManagement.AllergenCodeForRecord(0, 0, "No."))
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Allergens';
                        Style = StrongAccent;
                        StyleExpr = TRUE;
                        Visible = false;

                        trigger OnDrillDown()
                        begin
                            // P8006959
                            AllergenManagement.AllergenDrilldownForRecord(0, 0, "No.");
                        end;
                    }
                    field(AvailDate1; Qty[1])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = AvailCaption[1];
                        DecimalPlaces = 0 : 0;
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
                        DecimalPlaces = 0 : 0;
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
                        DecimalPlaces = 0 : 0;
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
                        DecimalPlaces = 0 : 0;
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
                        DecimalPlaces = 0 : 0;
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
                        DecimalPlaces = 0 : 0;
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
                        DecimalPlaces = 0 : 0;
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
                        DecimalPlaces = 0 : 0;
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
                        DecimalPlaces = 0 : 0;
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
                        DecimalPlaces = 0 : 0;
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
                        DecimalPlaces = 0 : 0;
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
                        DecimalPlaces = 0 : 0;
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
                        DecimalPlaces = 0 : 0;
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
                        DecimalPlaces = 0 : 0;
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
                        DecimalPlaces = 0 : 0;
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
                        DecimalPlaces = 0 : 0;
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
                        DecimalPlaces = 0 : 0;
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
                        DecimalPlaces = 0 : 0;
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
                SubPageLink = "Item No." = FIELD("No.");
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

                trigger OnAction()
                begin
                    dateMultiplier += 1;
                    PrevEnabled := dateMultiplier > 0;
                    SetDateRange;
                end;
            }
            action(AddOrder)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Add Order';
                Image = AddAction;

                trigger OnAction()
                var
                    ProdPlan3: Record "Daily Production Planning" temporary;
                begin
                    CurrPage.ProdLines.PAGE.AddOrder(Rec, ProdPlan3);
                end;
            }
            action(Update)
            {
                ApplicationArea = FOODBasic;
                Image = Change;

                trigger OnAction()
                begin
                    InitializeBoard;
                end;
            }
            action(CommitChanges)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Commit Changes';
                Image = Save;

                trigger OnAction()
                begin
                    CurrPage.ProdLines.PAGE.CommitChanges;
                end;
            }
        }
        area(navigation)
        {
            group(Item)
            {
                Caption = 'Item';
                action(MarkRequired)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Show Required Items';
                    Image = ItemLines;

                    trigger OnAction()
                    begin
                        MarkRequired(Rec, ShortagesOnly);
                    end;
                }
                action(ClearMarked)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Clear Required Items Filter';
                    Image = ClearFilter;

                    trigger OnAction()
                    begin
                        Rec.Reset;
                        Rec.Copy(preRequiredItem);
                        Clear(preRequiredItem);
                    end;
                }
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;
                    RunObject = Page "Item Card";
                    RunPageLink = "No." = FIELD("No.");
                }
                separator(Separator37002048)
                {
                }
                action(Equipment)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Show Equipment';
                    Image = Tools;

                    trigger OnAction()
                    var
                        ProdPlan: Record "Daily Production Planning" temporary;
                        equipPg: Page "Daily Prod. Planning-Equipment";
                    begin
                        equipPg.SetDateParameters(dateMultiplier, DaysView, BaseDate);
                        equipPg.SetDateRange;
                        equipPg.MarkForBOM("No.", overCapactity);
                        //equipPg.EDITABLE := FALSE;
                        CurrPage.ProdLines.PAGE.GetRecords(ProdPlan);                   // P8001086
                        equipPg.SetSharedObjects(SalesBoardMgt, EquipBoardMgt, ProdPlan); // P8001086
                        equipPg.RunModal; // P8001086
                        CurrPage.Update(false); // P8001086
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_New)
            {
                Caption = 'New';

                actionref(AddOrder_Promoted; AddOrder)
                {
                }
                actionref(CommitChanges_Promoted; CommitChanges)
                {
                }
            }
            group(Category_Navigate)
            {
                Caption = 'Navigate';

                actionref(PreviousDate_Promoted; "Previous Date")
                {
                }
                actionref(NextDate_Promoted; "Next Date")
                {
                }
            }
            group(Category_Related)
            {
                Caption = 'Related';

                actionref(MarkRequired_Promoted; MarkRequired)
                {
                }
                actionref(ClearMarked_Promoted; ClearMarked)
                {
                }
                actionref(Equipment_Promoted; Equipment)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        // P8007749
        Qty[1] := ItemAvailability("No.", AvailDate[1], itemAvailColourFlag01);
        Qty[2] := ItemAvailability("No.", AvailDate[2], itemAvailColourFlag02);
        Qty[3] := ItemAvailability("No.", AvailDate[3], itemAvailColourFlag03);
        Qty[4] := ItemAvailability("No.", AvailDate[4], itemAvailColourFlag04);
        Qty[5] := ItemAvailability("No.", AvailDate[5], itemAvailColourFlag05);
        Qty[6] := ItemAvailability("No.", AvailDate[6], itemAvailColourFlag06);
        Qty[7] := ItemAvailability("No.", AvailDate[7], itemAvailColourFlag07);
        Qty[8] := ItemAvailability("No.", AvailDate[8], itemAvailColourFlag08);
        Qty[9] := ItemAvailability("No.", AvailDate[9], itemAvailColourFlag09);
        Qty[10] := ItemAvailability("No.", AvailDate[10], itemAvailColourFlag10);
        Qty[11] := ItemAvailability("No.", AvailDate[11], itemAvailColourFlag11);
        Qty[12] := ItemAvailability("No.", AvailDate[12], itemAvailColourFlag12);
        Qty[13] := ItemAvailability("No.", AvailDate[13], itemAvailColourFlag13);
        Qty[14] := ItemAvailability("No.", AvailDate[14], itemAvailColourFlag14);
        Qty[15] := ItemAvailability("No.", AvailDate[15], itemAvailColourFlag15);
        Qty[16] := ItemAvailability("No.", AvailDate[16], itemAvailColourFlag16);
        Qty[17] := ItemAvailability("No.", AvailDate[17], itemAvailColourFlag17);
        Qty[18] := ItemAvailability("No.", AvailDate[18], itemAvailColourFlag18);
        // P8007749
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        Direction: Integer;
        EOF: Boolean;
        i: Integer;
    begin
        if not ShortagesOnly then
            exit(Find(Which));

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
            EOF := not Find(CopyStr(Which, i, 1));
            while (not EOF) and (not SalesBoardMgt.ShowRecord("No.", GetFilter("Variant Filter"),
              GetFilter("Location Filter"), ShortagesOnly, false))
            do
                EOF := Next(Direction) = 0;
            if not EOF then
                exit(true);
        end;
    end;

    trigger OnInit()
    begin
        ItemTypeFilterText := '*';
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        NextRec: Record Item;
        Direction: Integer;
        NoSteps: Integer;
        StepsTaken: Integer;
        EOF: Boolean;
    begin
        if not ShortagesOnly then
            exit(Next(Steps));

        NextRec := Rec;
        Direction := 1;
        if Steps < 0 then
            Direction := -1;
        NoSteps := Direction * Steps;
        while (StepsTaken < NoSteps) and (not EOF) do begin
            EOF := Next(Direction) = 0;
            if (not EOF) and SalesBoardMgt.ShowRecord("No.", GetFilter("Variant Filter"),
              GetFilter("Location Filter"), ShortagesOnly, false) then begin
                NextRec := Rec;
                StepsTaken += 1;
            end;
        end;
        Rec := NextRec;
        exit(Direction * StepsTaken);
    end;

    trigger OnOpenPage()
    begin
        // P8000789 S
        SetItemTypeFilter; // P8007749
        SetItemCategoryFilter; // P8007749
        SetLocationFilter; // P8007749
        SetVariantFilter; // P8007749
        // P8000789 E
        BaseDate := WorkDate;
        if DaysView = 0 then
            DaysView := 15;
        ShortagesOnly := false;

        SetDateRange;
        CurrPage.ProdLines.PAGE.SetSharedCodeunits(SalesBoardMgt, EquipBoardMgt, // P8000789, P8001086
          PAGE::"Daily Production Planning");                                   //           P8001086
    end;

    var
        preRequiredItem: Record Item;
        SalesBoard: Record "Item Availability";
        SalesBoardMgt: Codeunit "Sales Board Management";
        EquipBoardMgt: Codeunit "Equipment Board Management";
        AllergenManagement: Codeunit "Allergen Management";
        BaseDate: Date;
        BegEndDate: array[2] of Date;
        AvailDate: array[18] of Date;
        VariantFilter: Code[250];
        LocationFilter: Code[250];
        ItemCategoryFilter: Code[250];
        ResourceGroupFilter: Code[250];
        Text001: Label '<Weekday Text,3> <Month>/<Day>';
        AvailCaption: array[18] of Text[80];
        ItemTypeFilterText: Text[250];
        Text003: Label 'This will commit all pending changes.\Continue?';
        ItemTypeFilter: Option " ","(blank)","Raw Material",Packaging,Intermediate,"Finished Good",Container,Spare;
        dateMultiplier: Integer;
        DaysView: Integer;
        [InDataSet]
        IncludesProdChanges: Boolean;
        ShortagesOnly: Boolean;
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
        Qty: array[18] of Decimal;

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

    procedure SetVariantFilter()
    begin
        SetFilter("Variant Filter", VariantFilter); // P8007749
        CurrPage.Update(false);
    end;

    procedure SetItemTypeFilter()
    begin
        if ItemTypeFilter = 0 then
            SetRange("Item Type")
        else
            SetRange("Item Type", ItemTypeFilter - 1);
        ItemTypeFilterText := GetFilter("Item Type");
    end;

    procedure SetItemCategoryFilter()
    begin
        SetFilter("Item Category Code", ItemCategoryFilter); // P8007749
        ConvertItemCatFilterToItemCatOrderFilter; // P8007749
    end;

    procedure SetLocationFilter()
    begin
        SetFilter("Location Filter", LocationFilter); // P8007749
    end;

    procedure DrillDown(iDate: Date)
    begin
        if "No." = '' then
            exit;
        SalesBoardMgt.DrillDown("No.",
                                GetFilter("Variant Filter"),
                                GetFilter("Location Filter"),
                                1 + (iDate - CalcDate(('+' + Format(dateMultiplier * DaysView) + 'D'), BaseDate)),
                                SalesBoard."Data Element"::Available);
    end;

    procedure ItemAvailability(ItemNo: Code[20]; iDate: Date; var iColourFlag: Boolean) Quantity: Decimal
    var
        DateOffset: Integer;
    begin
        if iDate = 0D then
            exit(0);

        iColourFlag := false;   // P8000789
        IncludesProdChanges := false;
        DateOffset := 1 + (iDate - CalcDate(('+' + Format(dateMultiplier * DaysView) + 'D'), BaseDate));
        SalesBoardMgt.GetData("No.", GetFilter("Variant Filter"), GetFilter("Location Filter"),
          DateOffset, SalesBoard."Data Element"::Available, Quantity, IncludesProdChanges);

        iColourFlag := IncludesProdChanges;  // P8000789
        if DateOffset > 1 then
            exit;
        IncludesProdChanges := IncludesProdChanges or
          SalesBoardMgt.GetIncludesProdChanges("No.", GetFilter("Variant Filter"), GetFilter("Location Filter"),
          0, SalesBoard."Data Element"::Available);

        iColourFlag := IncludesProdChanges;  // P8000789
    end;

    procedure InitializeBoard()
    var
        LotStatus: Record "Lot Status Code";
    begin
        SalesBoardMgt.Initialize(BegEndDate[1], 0, 1 + (BegEndDate[2] - BegEndDate[1]), // P8001083
          LotStatus.FieldNo("Available for Planning"));                               // P8001083
        EquipBoardMgt.Initialize(BegEndDate[1], 0, 1 + (BegEndDate[2] - BegEndDate[1])); // P8001086
        CurrPage.Update(false); // P8000263A
    end;

    procedure MarkRequired(var Item: Record Item; var Shortages: Boolean)
    var
        Item2: Record Item;
        RequiredItem: Record "Where-Used Line" temporary;
        ProdBoardMgt: Codeunit "Production Board Management";
    begin
        TestField("Production BOM No.");

        preRequiredItem.Copy(Rec);
        Item2.Copy(Rec); // To preserve location and variant flowfilters
        Reset;
        ShortagesOnly := false;
        Item2.CopyFilter("Location Filter", "Location Filter");
        Item2.CopyFilter("Variant Filter", "Variant Filter");

        ProdBoardMgt.GetRequiredItems("No.", 0, Today, RequiredItem);

        // Now mark the records
        RequiredItem.Reset;
        RequiredItem.Find('-');
        repeat
            Get(RequiredItem."Item No.");
            Mark(true);
        until RequiredItem.Next = 0;
        RequiredItem.Find('-');
        Get(RequiredItem."Item No.");
        MarkedOnly(true);

        CurrPage.Update(false);

        Item.Copy(Rec);
        Shortages := ShortagesOnly;
    end;

    procedure OnAfterGetRec()
    begin
    end;
}

