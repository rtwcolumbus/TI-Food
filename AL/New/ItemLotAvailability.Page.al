page 37002033 "Item Lot Availability"
{
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   List of available lots with filtering on age and lot specifications
    // 
    // PR3.70.08
    // P8000161A, Myers Nissi, Jack Reynolds, 06 JAN 05
    //   Update lot age data after change to production date
    // 
    // P8000159A, Myers Nissi, Jack Reynolds, 06 JAN 05
    //   OnNextRecord - if zero steps taken restore original record
    // 
    // P8000165A, Myers Nissi, Jack Reynolds, 11 FEB 05
    //   Add controls for reserved quantity and quantity available
    // 
    // PR4.00
    // P8000251A, Myers Nissi, Jack Reynolds, 20 OCT 05
    //   Support for Expiration Date and Days to Expire
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 14 APR 09
    //   Transformed - additions in TIF Editor
    //   Page changes made after transformation
    // 
    // PRW16.00.04
    // P8000899, Columbus IT, Ron Davidson, 01 MAR 11
    //   Added Freshness Date logic.
    // 
    // PRW16.00.05
    // P8000969, Columbus IT, Jack Reynolds, 12 AUG 11
    //   Fix problem with Freshness Calc. Method
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // P8001070, Columbus IT, Jack Reynolds, 07 JAN 13
    //   Support for Lot Freshness
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 9 NOV 15
    //   NAV 2016 refactoring; Cleanup action names
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    //
    // PRW115.00.03
    // P800126472, To Increase, Gangabhushan, JUL 21
    //   CS00174747 | Item Lot Availability Page doesn't Render the Shortcuts Setup in Inventory Setup

    ApplicationArea = FOODBasic;
    Caption = 'Item Lot Availability';
    DeleteAllowed = false;
    PageType = Worksheet;
    SourceTable = "Lot No. Information";
    SourceTableView = SORTING("Item Category Code", "Item No.", "Creation Date", "Variant Code", "Lot No.")
                      WHERE(Posted = CONST(true),
                            Inventory = FILTER(> 0));
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(Filters)
            {
                Caption = 'Filters';
                field(ItemCategoryFilter; ItemCategoryFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Category Filter';
                    TableRelation = "Item Category";

                    trigger OnValidate()
                    begin
                        SetFilter("Item Category Code", ItemCategoryFilter);
                        ItemCategoryFilter := GetFilter("Item Category Code");
                        CurrPage.Update(false);
                    end;
                }
                field(LocationFilter; LocationFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Location Filter';
                    TableRelation = Location;

                    trigger OnValidate()
                    begin
                        // P8000664
                        SetFilter("Location Filter", LocationFilter);
                        LocationFilter := GetFilter("Location Filter");
                        CurrPage.Update(false);
                    end;
                }
                field(LotSpecFilterText; LotSpecFilterText)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Lot Specification Filter';
                    Editable = false;

                    trigger OnAssistEdit()
                    begin
                        if LotFilterFns.LotSpecAssist(LotSpecFilter) then begin
                            LotSpecFilterText := LotFilterFns.LotSpecText(LotSpecFilter);
                            CurrPage.Update;
                        end;
                    end;
                }
                field(AgeFilter; AgeFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Age Filter';

                    trigger OnValidate()
                    begin
                        LotAgeFilter.SetFilter(Age, AgeFilter);
                        AgeFilter := LotAgeFilter.GetFilter(Age);
                        CurrPage.Update(false);
                    end;
                }
                field(AgeCategoryFilter; AgeCategoryFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Age Category Filter';
                    TableRelation = "Lot Age Category";

                    trigger OnValidate()
                    begin
                        LotAgeFilter.SetFilter("Age Category", AgeCategoryFilter);
                        AgeCategoryFilter := LotAgeFilter.GetFilter("Age Category");
                        CurrPage.Update(false);
                    end;
                }
                field(DaysToExpireFilter; DaysToExpireFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Days to Expire Filter';

                    trigger OnValidate()
                    begin
                        // P8000251A
                        LotAgeFilter.SetFilter("Days to Expire", DaysToExpireFilter);
                        DaysToExpireFilter := LotAgeFilter.GetFilter("Days to Expire");
                        CurrPage.Update(false);
                    end;
                }
                field(OldestAcceptableDate; OldestAcceptableDate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Oldest Acceptable Freshness Date';

                    trigger OnValidate()
                    begin
                        // P8001070
                        CurrPage.Update(false);
                    end;
                }
            }
            repeater(Control37002003)
            {
                Editable = false;
                ShowCaption = false;
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot Status Code"; "Lot Status Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Release Date"; "Release Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Creation Date"; "Creation Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("LotFilterFns.Age(Rec)"; LotFilterFns.Age(Rec))
                {
                    ApplicationArea = FOODBasic;
                    BlankNumbers = BlankNeg;
                    Caption = 'Age';
                }
                field("LotFilterFns.AgeCategory(Rec)"; LotFilterFns.AgeCategory(Rec))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Age Category';
                }
                field("LotFilterFns.AgeDate(Rec)"; LotFilterFns.AgeDate(Rec))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Current Age Date';
                }
                field("FormatDays(LotFilterFns.RemainingDays(Rec))"; FormatDays(LotFilterFns.RemainingDays(Rec)))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Remaining Days';
                }
                field("Expiration Date"; "Expiration Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("FormatDays(LotFilterFns.DaysToExpire(Rec))"; FormatDays(LotFilterFns.DaysToExpire(Rec)))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Days to Expire';
                }
                field("Freshness Date"; "Freshness Date")
                {
                    ApplicationArea = FOODBasic;
                    Style = Unfavorable;
                    StyleExpr = SetFreshDateStyleExpr;
                }
                field("Item.""Freshness Calc. Method"""; Item."Freshness Calc. Method")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Freshness Calc. Method';
                }
                field("ShortcutLotSpec[1]"; ShortcutLotSpec[1])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '37002020,1';
                    Visible = false;
                }
                field("ShortcutLotSpec[2]"; ShortcutLotSpec[2])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '37002020,2';
                    Visible = false;
                }
                field("ShortcutLotSpec[3]"; ShortcutLotSpec[3])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '37002020,3';
                    Visible = false;
                }
                field("ShortcutLotSpec[4]"; ShortcutLotSpec[4])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '37002020,4';
                    Visible = false;
                }
                field("ShortcutLotSpec[5]"; ShortcutLotSpec[5])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '37002020,5';
                    Visible = false;
                }
                field(Inventory; Inventory)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Quantity';
                }
                field("Reserved Quantity"; "Reserved Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field(QtyAvailable; QtyAvailable)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Available';
                    DecimalPlaces = 0 : 5;
                }
                field("Quantity (Alt.)"; "Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
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
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;
                    RunObject = Page "Item Card";
                    RunPageLink = "No." = FIELD("Item No.");
                    ShortCutKey = 'Shift+F7';
                }
                action("Age Summary")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Age Summary';
                    Image = Aging;

                    trigger OnAction()
                    begin
                        LotFilterFns.ItemAgeSummary(Rec, LotAgeFilter, LotSpecFilter);
                    end;
                }
            }
            group("&Lot")
            {
                Caption = '&Lot';
                action(Action1102603048)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;

                    trigger OnAction()
                    var
                        LotInfo: Record "Lot No. Information";
                        LotInfoCard: Page "Lot No. Information Card";
                    begin
                        LotInfo := Rec;
                        LotInfo.SetRecFilter;
                        PAGE.RunModal(PAGE::"Lot No. Information Card", LotInfo);
                        LotInfo.Find;
                        if LotInfo."Creation Date" <> "Creation Date" then begin // P8000161A
                            Rec := LotInfo;                                            // P8000161A
                            LotFilterFns.ClearLotAge(Rec);
                        end;                                                         // P8000161A
                    end;
                }
                action("Item Tracking Entries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Tracking Entries';
                    Image = ItemTrackingLedger;
                    ShortCutKey = 'Ctrl+F7';

                    trigger OnAction()
                    var
                        ItemTrackingDocMgt: Codeunit "Item Tracking Doc. Management";
                    begin
                        ItemTrackingDocMgt.ShowItemTrackingForMasterData(0, '', "Item No.", "Variant Code", '', "Lot No.", ''); // P8004516
                    end;
                }
                action("Quality Control")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Quality Control';
                    Image = CheckRulesSyntax;
                    RunObject = Page "Quality Control";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code"),
                                  "Lot No." = FIELD("Lot No.");
                }
                action("Lot &Specifications")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Lot &Specifications';
                    Image = LotInfo;
                    RunObject = Page "Lot Specifications";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code"),
                                  "Lot No." = FIELD("Lot No.");
                }
            }
        }
        area(processing)
        {
            action("Item Lot Availability")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Item Lot Availability';
                Ellipsis = true;
                Image = ItemAvailability;
                Promoted = true;
                PromotedCategory = "Report";

                trigger OnAction()
                var
                    LotInfo: Record "Lot No. Information";
                    ItemLotAvail: Report "Item Lot Availability";
                begin
                    LotInfo.Copy(Rec);
                    ItemLotAvail.SetLotFilters(LotAgeFilter, LotSpecFilter, OldestAcceptableDate); // P8001070
                    ItemLotAvail.SetTableView(LotInfo);
                    ItemLotAvail.RunModal;
                end;
            }
            action("Reset Filters")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Reset Filters';
                Image = ClearFilter;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Reset;
                    FilterGroup(2);
                    SetRange(Posted, true);
                    SetFilter(Inventory, '>0');
                    FilterGroup(0);

                    LotAgeFilter.Reset;
                    LotSpecFilter.Reset;
                    LotSpecFilter.DeleteAll;

                    ItemCategoryFilter := '';
                    AgeFilter := '';
                    AgeCategoryFilter := '';
                    LotSpecFilterText := '';

                    CurrPage.Update;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ShowShortcutLotSpec(ShortcutLotSpec);
        // P8000899
        GetItem; // P8001070
        SetFreshDateStyleExpr := Item.UseFreshnessDate and ("Freshness Date" < Today); // P8000969
        // P8000899
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        Direction: Integer;
        EOF: Boolean;
        i: Integer;
    begin
        ItemCategoryFilter := GetFilter("Item Category Code");
        LocationFilter := GetFilter("Location Filter"); // P8000664
        Clear(ShortcutLotSpec);
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
            while (not EOF) and (not LotInFilter) do // P8001070
                EOF := Next(Direction) = 0;
            if not EOF then
                exit(true);
        end;
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        NextRec: Record "Lot No. Information";
        Direction: Integer;
        NoSteps: Integer;
        StepsTaken: Integer;
        EOF: Boolean;
    begin
        NextRec := Rec; // P8000159A
        Direction := 1;
        if Steps < 0 then
            Direction := -1;
        NoSteps := Direction * Steps;
        while (StepsTaken < NoSteps) and (not EOF) do begin
            EOF := Next(Direction) = 0;
            if (not EOF) and LotInFilter then begin // P8000159A, P8001070
                NextRec := Rec;                       // P8000159A
                StepsTaken += 1;
            end;                                    // P8000159A
        end;
        Rec := NextRec; // P8000159A
        exit(Direction * StepsTaken);
    end;

    var
        Text001: Label 'N/A';
        Item: Record Item;
        LotAgeFilter: Record "Lot Age";
        LotSpecFilter: Record "Lot Specification Filter" temporary;
        LotFilterFns: Codeunit "Lot Filtering";
        ShortcutLotSpec: array[5] of Code[50];
        ItemCategoryFilter: Text[250];
        AgeCategoryFilter: Text[250];
        AgeFilter: Text[250];
        DaysToExpireFilter: Text[250];
        LotSpecFilterText: Text[1024];
        LocationFilter: Code[50];
        [InDataSet]
        SetFreshDateStyleExpr: Boolean;
        OldestAcceptableDate: Date;

    procedure QtyAvailable() Qty: Decimal
    begin
        // P8000165A
        Qty := Inventory - "Reserved Quantity";
        if Qty < 0 then
            Qty := 0
    end;

    procedure FormatDays(Days: Integer): Text[10]
    begin
        // P8000664
        if Days = 0 then
            exit('')
        else
            if Days = 2147483647 then
                exit(Text001)
            else
                exit(Format(Days));
    end;

    procedure LotInFilter(): Boolean
    begin
        // P8001070
        GetItem;
        exit(LotFilterFns.LotInFilter(Rec, LotAgeFilter, LotSpecFilter, Item."Freshness Calc. Method", OldestAcceptableDate));
    end;

    procedure GetItem()
    begin
        // P8001070
        if Item."No." <> "Item No." then
            if "Item No." <> '' then
                Item.Get("Item No.")
            else
                Clear(Item);
    end;
}

