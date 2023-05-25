page 37002200 "Sales Board"
{
    // PR3.70.08
    // P8000178A, Myers Nissi, Jack Reynolds, 08 FEB 05
    //   Sales Board showing item availability by period
    // 
    // PR3.70.09
    // P8000187A, Myers Nissi, Jack Reynolds, 18 FEB 05
    //   Fix problem with Location and Variant filter when calling ShowRecord to rsolve shortages and zero lines
    // 
    // PR4.00
    // P8000197A, Myers Nissi, Jack Reynolds, 21 SEP 05
    //   GetData - change call in sales board management from GetData to GetQuantity
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.03
    // P8000828, VerticalSoft, Don Bresee, 03 JUN 10
    //   Consolidate timer logic
    //   Change to ListPlus page type
    //   Add style application to SetColumns
    //   Rework Enabled expression for Next/Previous actions
    // 
    // PRW16.00.04
    // P8000897, VerticalSoft, Jack Reynolds, 22 JAN 11
    //   Fix spelling mistake
    // 
    // PRW16.00.05
    // P8000936, Columbus IT, Jack Reynolds, 25 APR 11
    //   Support for Repack Orders on Sales Board
    // 
    // P8000940, Columbus IT, Jack Reynolds, 04 MAY 11
    //   Rework timer control
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001024, Columbus IT, Jack Reynolds, 25 JAN 12
    //   Pass Location Filter to Item Lot Availability
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.00.01
    // P8001157, Columbus IT, Jack Reynolds, 23 MAY 13
    //   Fix problem with incorrect time add-in
    // 
    // PRW18.00.01
    // P8001386, Columbus IT, Jack Reynolds, 27 MAY 15
    //    Renamed NAV Food client addins
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 9 NOV 15
    //   NAV 2016 refactoring; Cleanup action names
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW111.00
    // P80059471, To Increase, Jack Reynolds, 25 JUN 18
    //   Cleanup TimerUpdate property
    //   Replace Timer control by PingPong control
    // 
    // PRW111.00.02
    // P80064337, To-Increase, Jack Reynolds, 06 SEP 18
    //   Missing or misspelled caption
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW118.1
    // P80095846, To Increase, Jack Reynolds, 24 SEP 21
    //   Layout change to combiine fast tabs
    // 
    // PRW120.00
    // P800144605, To Increase, Jack Reynolds, 20 APR 22
    //   Upgrade to 20.0

    ApplicationArea = FOODBasic;
    Caption = 'Sales Board';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SaveValues = true;
    SourceTable = Item;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(FiltersSettings)
            {
                Caption = 'Filters and Settings';
                group(General)
                {
                    Caption = 'Filters';
                    field(ItemCategoryFilter; ItemCategoryFilter)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Item Category Filter';
                        TableRelation = "Item Category";

                        trigger OnValidate()
                        begin
                            SetItemCategoryFilter;
                            CurrPage.Update(false);
                        end;
                    }
                    field(LocationFilter; LocationFilter)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Location Filter';
                        Importance = Promoted;
                        TableRelation = Location.Code WHERE("Use As In-Transit" = FILTER(false));

                        trigger OnValidate()
                        begin
                            SetLocationFilter;
                            CurrPage.Update(false);
                        end;
                    }
                    field(VariantFilter; VariantFilter)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Variant Filter';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            ItemVariant: Record "Item Variant";
                            ItemVariants: Page "Item Variants";
                        begin
                            ItemVariant.SetRange("Item No.", "No.");

                            ItemVariants.Editable(false);
                            ItemVariants.LookupMode(true);
                            ItemVariants.SetTableView(ItemVariant);

                            if (ItemVariants.RunModal = ACTION::LookupOK) then begin
                                ItemVariants.GetRecord(ItemVariant);
                                Text := ItemVariant.Code;
                                exit(true);
                            end;
                        end;

                        trigger OnValidate()
                        begin
                            SetVariantFilter;
                            CurrPage.Update(false);
                        end;
                    }
                }
                group("Display Options")
                {
                    Caption = 'Display Options';
                    field(BaseDate; BaseDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Base Date';
                        Importance = Promoted;

                        trigger OnValidate()
                        begin
                            BaseDateOnAfterValidate;
                        end;
                    }
                    field(Period; Period)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Period';
                        OptionCaption = 'Date,Week,Month';

                        trigger OnValidate()
                        begin
                            PeriodOnAfterValidate;
                        end;
                    }
                    field(Periods; Periods)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Periods';
                        MinValue = 1;

                        trigger OnValidate()
                        begin
                            PeriodsOnAfterValidate;
                        end;
                    }
                    field(AvailableFor; AvailableFor)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Available for';
                        Importance = Promoted;
                        OptionCaption = ', ,Sale,Purchase Return,Transfer,Consumption,Adjustment,Planning';

                        trigger OnValidate()
                        begin
                            // P8001083
                            RegenerateBoard;
                        end;
                    }
                    field(ShortagesOnly; ShortagesOnly)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Shortages Only';

                        trigger OnValidate()
                        begin
                            ShortagesOnlyOnPush;
                        end;
                    }
                    field(HideZero; HideZero)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Hide Zero Lines';

                        trigger OnValidate()
                        begin
                            HideZeroOnPush;
                        end;
                    }
                    // field(TimerInterval; TimerInterval)
                    // {
                    //     Caption = 'Auto Update Interval (seconds)';

                    //     trigger OnValidate()
                    //     var
                    //         intTimer: Integer;
                    //     begin
                    //         if (TimerInterval < 5) and (TimerInterval <> 0) then
                    //             Error(Text37000001);

                    //         // P80059471
                    //         CurrPage.PingPong.Stop;
                    //         if TimerInterval <> 0 then
                    //             CurrPage.PingPong.Ping(TimerInterval * 1000);
                    //         // P80059471
                    //     end;
                    // }
                }
                group("Display Columns")
                {
                    Caption = 'Display Columns';
                    field("DataElementDisplay[1]"; DataElementDisplay[1])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = Format(DataElementDesc[1]);
                        Caption = 'Available';
                        Editable = false;
                    }
                    field("DataElementDisplay[2]"; DataElementDisplay[2])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = Format(DataElementDesc[2]);
                        Caption = 'Purchases';

                        trigger OnValidate()
                        begin
                            DataElementDisplay2OnPush;
                        end;
                    }
                    field("DataElementDisplay[3]"; DataElementDisplay[3])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = Format(DataElementDesc[3]);
                        Caption = 'Sales';

                        trigger OnValidate()
                        begin
                            DataElementDisplay3OnPush;
                        end;
                    }
                    field("DataElementDisplay[4]"; DataElementDisplay[4])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = Format(DataElementDesc[4]);
                        Caption = 'Output';

                        trigger OnValidate()
                        begin
                            DataElementDisplay4OnPush;
                        end;
                    }
                    field("DataElementDisplay[5]"; DataElementDisplay[5])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = Format(DataElementDesc[5]);
                        Caption = 'Consumption';

                        trigger OnValidate()
                        begin
                            DataElementDisplay5OnPush;
                        end;
                    }
                    field("DataElementDisplay[6]"; DataElementDisplay[6])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = Format(DataElementDesc[6]);
                        Caption = 'Transfers';

                        trigger OnValidate()
                        begin
                            DataElementDisplay6OnPush;
                        end;
                    }
                }
            }
            // usercontrol(PingPong; "Microsoft.Dynamics.Nav.Client.PingPong")
            // {
            //     trigger AddInReady()
            //     begin
            //         // P80059471
            //         if TimerInterval <> 0 then
            //             CurrPage.PingPong.Ping(TimerInterval * 1000);
            //     end;

            //     trigger Pong()
            //     begin
            //         // P80059471
            //         RegenerateBoard;
            //         CurrPage.PingPong.Ping(TimerInterval * 1000);
            //     end;
            // }
            repeater(Control37002006)
            {
                FreezeColumn = "Base Unit of Measure";
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item Type"; "Item Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Base Unit of Measure"; "Base Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Column0; GetData(0))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(0);
                    DecimalPlaces = 0 : 5;
                    Style = Strong;
                    StyleExpr = TRUE;

                    trigger OnDrillDown()
                    begin
                        DrillDown(0);
                    end;
                }
                field(Column1; GetData(1))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(1);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 1;
                    Style = Strong;
                    StyleExpr = StyleColumn1;

                    trigger OnDrillDown()
                    begin
                        DrillDown(1);
                    end;
                }
                field(Column2; GetData(2))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(2);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 2;
                    Style = Strong;
                    StyleExpr = StyleColumn2;

                    trigger OnDrillDown()
                    begin
                        DrillDown(2);
                    end;
                }
                field(Column3; GetData(3))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(3);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 3;
                    Style = Strong;
                    StyleExpr = StyleColumn3;

                    trigger OnDrillDown()
                    begin
                        DrillDown(3);
                    end;
                }
                field(Column4; GetData(4))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(4);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 4;
                    Style = Strong;
                    StyleExpr = StyleColumn4;

                    trigger OnDrillDown()
                    begin
                        DrillDown(4);
                    end;
                }
                field(Column5; GetData(5))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(5);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 5;
                    Style = Strong;
                    StyleExpr = StyleColumn5;

                    trigger OnDrillDown()
                    begin
                        DrillDown(5);
                    end;
                }
                field(Column6; GetData(6))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(6);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 6;
                    Style = Strong;
                    StyleExpr = StyleColumn6;

                    trigger OnDrillDown()
                    begin
                        DrillDown(6);
                    end;
                }
                field(Column7; GetData(7))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(7);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 7;
                    Style = Strong;
                    StyleExpr = StyleColumn7;

                    trigger OnDrillDown()
                    begin
                        DrillDown(7);
                    end;
                }
                field(Column8; GetData(8))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(8);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 8;
                    Style = Strong;
                    StyleExpr = StyleColumn8;

                    trigger OnDrillDown()
                    begin
                        DrillDown(8);
                    end;
                }
                field(Column9; GetData(9))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(9);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 9;
                    Style = Strong;
                    StyleExpr = StyleColumn9;

                    trigger OnDrillDown()
                    begin
                        DrillDown(9);
                    end;
                }
                field(Column10; GetData(10))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(10);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 10;
                    Style = Strong;
                    StyleExpr = StyleColumn10;

                    trigger OnDrillDown()
                    begin
                        DrillDown(10);
                    end;
                }
                field(Column11; GetData(11))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(11);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 11;
                    Style = Strong;
                    StyleExpr = StyleColumn11;

                    trigger OnDrillDown()
                    begin
                        DrillDown(11);
                    end;
                }
                field(Column12; GetData(12))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(12);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 12;
                    Style = Strong;
                    StyleExpr = StyleColumn12;

                    trigger OnDrillDown()
                    begin
                        DrillDown(12);
                    end;
                }
                field(Column13; GetData(13))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(13);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 13;
                    Style = Strong;
                    StyleExpr = StyleColumn13;

                    trigger OnDrillDown()
                    begin
                        DrillDown(13);
                    end;
                }
                field(Column14; GetData(14))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(14);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 14;
                    Style = Strong;
                    StyleExpr = StyleColumn14;

                    trigger OnDrillDown()
                    begin
                        DrillDown(14);
                    end;
                }
                field(Column15; GetData(15))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(15);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 15;
                    Style = Strong;
                    StyleExpr = StyleColumn15;

                    trigger OnDrillDown()
                    begin
                        DrillDown(15);
                    end;
                }
                field(Column16; GetData(16))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(16);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 16;
                    Style = Strong;
                    StyleExpr = StyleColumn16;

                    trigger OnDrillDown()
                    begin
                        DrillDown(16);
                    end;
                }
                field(Column17; GetData(17))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(17);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 17;
                    Style = Strong;
                    StyleExpr = StyleColumn17;

                    trigger OnDrillDown()
                    begin
                        DrillDown(17);
                    end;
                }
                field(Column18; GetData(18))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(18);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 18;
                    Style = Strong;
                    StyleExpr = StyleColumn18;

                    trigger OnDrillDown()
                    begin
                        DrillDown(18);
                    end;
                }
                field(Column19; GetData(19))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(19);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 19;
                    Style = Strong;
                    StyleExpr = StyleColumn19;

                    trigger OnDrillDown()
                    begin
                        DrillDown(19);
                    end;
                }
                field(Column20; GetData(20))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(20);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 20;
                    Style = Strong;
                    StyleExpr = StyleColumn20;

                    trigger OnDrillDown()
                    begin
                        DrillDown(20);
                    end;
                }
                field(Column21; GetData(21))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(21);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 21;
                    Style = Strong;
                    StyleExpr = StyleColumn21;

                    trigger OnDrillDown()
                    begin
                        DrillDown(21);
                    end;
                }
                field(Column22; GetData(22))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(22);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 22;
                    Style = Strong;
                    StyleExpr = StyleColumn22;

                    trigger OnDrillDown()
                    begin
                        DrillDown(22);
                    end;
                }
                field(Column23; GetData(23))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(23);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 23;
                    Style = Strong;
                    StyleExpr = StyleColumn23;

                    trigger OnDrillDown()
                    begin
                        DrillDown(23);
                    end;
                }
                field(Column24; GetData(24))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(24);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 24;
                    Style = Strong;
                    StyleExpr = StyleColumn24;

                    trigger OnDrillDown()
                    begin
                        DrillDown(24);
                    end;
                }
                field(Column25; GetData(25))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(25);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 25;
                    Style = Strong;
                    StyleExpr = StyleColumn25;

                    trigger OnDrillDown()
                    begin
                        DrillDown(25);
                    end;
                }
                field(Column26; GetData(26))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(26);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 26;
                    Style = Strong;
                    StyleExpr = StyleColumn26;

                    trigger OnDrillDown()
                    begin
                        DrillDown(26);
                    end;
                }
                field(Column27; GetData(27))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(27);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 27;
                    Style = Strong;
                    StyleExpr = StyleColumn27;

                    trigger OnDrillDown()
                    begin
                        DrillDown(27);
                    end;
                }
                field(Column28; GetData(28))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(28);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 28;
                    Style = Strong;
                    StyleExpr = StyleColumn28;

                    trigger OnDrillDown()
                    begin
                        DrillDown(28);
                    end;
                }
                field(Column29; GetData(29))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(29);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 29;
                    Style = Strong;
                    StyleExpr = StyleColumn29;

                    trigger OnDrillDown()
                    begin
                        DrillDown(29);
                    end;
                }
                field(Column30; GetData(30))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = ColHeading(30);
                    DecimalPlaces = 0 : 5;
                    HideValue = MaxColumnIncOffset <= 30;
                    Style = Strong;
                    StyleExpr = StyleColumn30;

                    trigger OnDrillDown()
                    begin
                        DrillDown(30);
                    end;
                }
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
                Enabled = ColumnOffset > 0;
                Image = PreviousSet;

                trigger OnAction()
                begin
                    ColumnOffset -= 1;
                    MaxColumnIncOffset += NoCols;

                    CurrPage.Update(false);
                end;
            }
            action("Next Date")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Next Date';
                Enabled = MaxColumnIncOffset > 31;
                Image = NextSet;

                trigger OnAction()
                begin
                    ColumnOffset += 1;
                    MaxColumnIncOffset -= NoCols;

                    //BaseDate := CALCDATE('<+1D>', BaseDate);
                    //RegenerateBoard();

                    CurrPage.Update(false);
                end;
            }
        }
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
                    RunPageLink = "No." = FIELD("No."),
                                  "Date Filter" = FIELD("Date Filter"),
                                  "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                  "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                                  "Location Filter" = FIELD("Location Filter"),
                                  "Drop Shipment Filter" = FIELD("Drop Shipment Filter");
                    ShortCutKey = 'Shift+F7';
                }
                group("E&ntries")
                {
                    Caption = 'E&ntries';
                    action("Ledger E&ntries")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Ledger E&ntries';
                        Image = LedgerEntries;
                        RunObject = Page "Item Ledger Entries";
                        RunPageLink = "Item No." = FIELD("No.");
                        RunPageView = SORTING("Item No.");
                        ShortCutKey = 'Ctrl+F7';
                    }
                    action("&Reservation Entries")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = '&Reservation Entries';
                        Image = ReservationLedger;
                        RunObject = Page "Reservation Entries";
                        RunPageLink = "Reservation Status" = CONST(Reservation),
                                      "Item No." = FIELD("No.");
                        RunPageView = SORTING("Reservation Status", "Item No.", "Variant Code", "Location Code");
                    }
                    action("&Phys. Inventory Ledger Entries")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = '&Phys. Inventory Ledger Entries';
                        Image = PhysicalInventoryLedger;
                        RunObject = Page "Phys. Inventory Ledger Entries";
                        RunPageLink = "Item No." = FIELD("No.");
                        RunPageView = SORTING("Item No.");
                    }
                    action("&Value Entries")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = '&Value Entries';
                        Image = ValueLedger;
                        RunObject = Page "Value Entries";
                        RunPageLink = "Item No." = FIELD("No.");
                        RunPageView = SORTING("Item No.");
                    }
                    action("Item &Tracking Entries")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Item &Tracking Entries';
                        Image = ItemTrackingLedger;

                        trigger OnAction()
                        var
                            ItemTrackingSetup: Record "Item Tracking Setup";
                            ItemTrackingDocMgt: Codeunit "Item Tracking Doc. Management";
                        begin
                            ItemTrackingDocMgt.ShowItemTrackingForEntity(1, Rec."No.", '', '', '', ItemTrackingSetup); // P8004516, P800144605
                        end;
                    }
                    action(Lots)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Lots';
                        Image = Lot;
                        RunObject = Page Lots;
                        RunPageLink = "Item No." = FIELD("No.");
                    }
                    action("Serial Nos.")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Serial Nos.';
                        Image = SerialNo;
                        RunObject = Page "Serial Nos.";
                        RunPageLink = "Item No." = FIELD("No.");
                    }
                }
                action("Lot Availability")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Lot Availability';
                    Image = Lot;
                    RunObject = Page "Item Lot Availability";
                    RunPageLink = "Item No." = FIELD("No."),
                                  "Location Filter" = FIELD("Location Filter");
                }
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = CONST(Item),
                                  "No." = FIELD("No.");
                }
            }
        }
        area(Promoted)
        {
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
            group(Category_Item)
            {
                Caption = 'Item';

                actionref(Card_Promoted; Card)
                {
                }
                actionref(LotAvailability_Promoted; "Lot Availability")
                {
                }
                actionref(Comments_Promoted; "Co&mments")
                {
                }
            }
            group(Category_Entries)
            {
                Caption = 'Entries';

                actionref(LedgerEntries_Promoted; "Ledger E&ntries")
                {
                }
                actionref(ReservationEntries_Promoted; "&Reservation Entries")
                {
                }
                actionref(PhysInventoryLedgerEntries_Promoted; "&Phys. Inventory Ledger Entries")
                {
                }
                actionref(ValueEntries_Promoted; "&Value Entries")
                {
                }
                actionref(ItemTrackingEntries_Promoted; "Item &Tracking Entries")
                {
                }
                actionref(Lots_Promoted; Lots)
                {
                }
                actionref(SerialNos_Promoted; "Serial Nos.")
                {
                }
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    var
        Direction: Integer;
        EOF: Boolean;
        i: Integer;
    begin
        // P8007749
        // ItemCategoryFilter := GETFILTER("Item Category Code");
        // LocationFilter := GETFILTER("Location Filter");
        // VariantFilter := GETFILTER("Variant Filter");
        // P8007749

        if (not ShortagesOnly) and (not HideZero) then
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
            while (not EOF) and (not SalesBoardMgt.ShowRecord("No.", GetFilter("Variant Filter"), // P8000187A
              GetFilter("Location Filter"), ShortagesOnly, HideZero))                              // P8000187A
            do                                                                                   // P8000187A
                EOF := Next(Direction) = 0;
            if not EOF then
                exit(true);
        end;
    end;

    trigger OnInit()
    begin
        MaxPeriods := 0;
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        NextRec: Record Item;
        Direction: Integer;
        NoSteps: Integer;
        StepsTaken: Integer;
        EOF: Boolean;
    begin
        if (not ShortagesOnly) and (not HideZero) then
            exit(Next(Steps));

        NextRec := Rec;
        Direction := 1;
        if Steps < 0 then
            Direction := -1;
        NoSteps := Direction * Steps;
        while (StepsTaken < NoSteps) and (not EOF) do begin
            EOF := Next(Direction) = 0;
            if (not EOF) and SalesBoardMgt.ShowRecord("No.", GetFilter("Variant Filter"), // P8000187A
              GetFilter("Location Filter"), ShortagesOnly, HideZero) then begin            // P8000187A
                NextRec := Rec;
                StepsTaken += 1;
            end;
        end;
        Rec := NextRec;
        exit(Direction * StepsTaken);
    end;

    trigger OnOpenPage()
    var
        i: Integer;
    begin
        BaseDate := Today;
        if Periods = 0 then
            Periods := 1;

        // P8000828
        SetLocationFilter;
        SetVariantFilter;
        SetItemCategoryFilter;
        // P8000828

        DataElementDisplay[1] := true;
        DataElementType[1] := SalesBoard."Data Element"::Available;
        DataElementType[2] := SalesBoard."Data Element"::Purchases;
        DataElementType[3] := SalesBoard."Data Element"::Sales;
        DataElementType[4] := SalesBoard."Data Element"::Output; // P8000936
        DataElementType[5] := SalesBoard."Data Element"::Consumption; // P8000936
        DataElementType[6] := SalesBoard."Data Element"::Transfers;

        for i := 1 to ArrayLen(DataElementType) do begin
            SalesBoard."Data Element" := DataElementType[i];
            DataElementDesc[i] := Format(SalesBoard."Data Element");
        end;

        ColumnOffset := 0;
        SetColumns;

        // P8001083
        if AvailableFor = 0 then
            AvailableFor := AvailableFor::Sale;
        SalesBoardMgt.Initialize(BaseDate, Period, Periods, LotStatusMgmt.AvailableForToFieldNo(AvailableFor - 1));
        // P8001083
    end;

    var
        SalesBoard: Record "Item Availability";
        SalesBoardMgt: Codeunit "Sales Board Management";
        BaseDate: Date;
        Period: Option Date,Week,Month;
        Periods: Integer;
        DataElementDisplay: array[6] of Boolean;
        DataElementType: array[6] of Integer;
        DataElementDesc: array[6] of Text[30];
        [InDataSet]
        NoCols: Integer;
        ColumnType: array[6] of Integer;
        ItemCategoryFilter: Code[250];
        ShortagesOnly: Boolean;
        HideZero: Boolean;
        AutoUpdateInterval: Integer;
        [InDataSet]
        MaxColumnIncOffset: Integer;
        MaxPeriods: Integer;
        Text37000000: Label 'Maximum number of periods is %1.';
        [InDataSet]
        ColumnOffset: Integer;
        LocationFilter: Code[250];
        VariantFilter: Code[250];
        // TimerInterval: Integer;
        LotStatusMgmt: Codeunit "Lot Status Management";
        AvailableFor: Option ," ",Sale,"Purchase Return",Transfer,Consumption,Adjustment,Planning;
        [InDataSet]
        StyleColumn0: Boolean;
        [InDataSet]
        StyleColumn1: Boolean;
        [InDataSet]
        StyleColumn2: Boolean;
        [InDataSet]
        StyleColumn3: Boolean;
        [InDataSet]
        StyleColumn4: Boolean;
        [InDataSet]
        StyleColumn5: Boolean;
        [InDataSet]
        StyleColumn6: Boolean;
        [InDataSet]
        StyleColumn7: Boolean;
        [InDataSet]
        StyleColumn8: Boolean;
        [InDataSet]
        StyleColumn9: Boolean;
        [InDataSet]
        StyleColumn10: Boolean;
        [InDataSet]
        StyleColumn11: Boolean;
        [InDataSet]
        StyleColumn12: Boolean;
        [InDataSet]
        StyleColumn13: Boolean;
        [InDataSet]
        StyleColumn14: Boolean;
        [InDataSet]
        StyleColumn15: Boolean;
        [InDataSet]
        StyleColumn16: Boolean;
        [InDataSet]
        StyleColumn17: Boolean;
        [InDataSet]
        StyleColumn18: Boolean;
        [InDataSet]
        StyleColumn19: Boolean;
        [InDataSet]
        StyleColumn20: Boolean;
        [InDataSet]
        StyleColumn21: Boolean;
        [InDataSet]
        StyleColumn22: Boolean;
        [InDataSet]
        StyleColumn23: Boolean;
        [InDataSet]
        StyleColumn24: Boolean;
        [InDataSet]
        StyleColumn25: Boolean;
        [InDataSet]
        StyleColumn26: Boolean;
        [InDataSet]
        StyleColumn27: Boolean;
        [InDataSet]
        StyleColumn28: Boolean;
        [InDataSet]
        StyleColumn29: Boolean;
        [InDataSet]
        StyleColumn30: Boolean;
        Text37000001: Label 'Update interval cannot be less than 5 seconds.';

    procedure SetColumns()
    var
        i: Integer;
    begin
        NoCols := 0;
        Clear(ColumnType);

        for i := 1 to ArrayLen(DataElementDisplay) do
            if DataElementDisplay[i] then begin
                NoCols += 1;
                ColumnType[NoCols] := DataElementType[i];
            end;

        // P8000828
        ColumnOffset := 0;
        MaxColumnIncOffset := 1 + NoCols * Periods;

        for i := 1 to MaxColumnIncOffset do
            ApplyColumnStyle(i, 1 + i mod NoCols, i div NoCols);
        // P8000828
    end;

    procedure RegenerateBoard()
    begin
        SalesBoardMgt.Initialize(BaseDate, Period, Periods, LotStatusMgmt.AvailableForToFieldNo(AvailableFor - 1)); // P8001083
        CurrPage.Update(false);
    end;

    procedure ColHeading(ColInd: Integer): Text[30]
    var
        DateOffset: Integer;
        ColIndex: Integer;
    begin
        DateOffset := ColInd div NoCols + ColumnOffset;
        ColIndex := 1 + ColInd mod NoCols;

        ApplyColumnStyle(ColInd, ColIndex, DateOffset);

        if (DateOffset < Periods) or ((DateOffset = Periods) and (ColIndex = 1)) then
            exit(SalesBoardMgt.GetHeading(DateOffset, ColumnType[ColIndex]))
        else
            exit(' ');
    end;

    procedure GetData(ColInd: Integer): Decimal
    var
        DateOffset: Integer;
        ColIndex: Integer;
    begin
        if "No." = '' then
            exit;

        DateOffset := ColInd div NoCols + ColumnOffset;
        ColIndex := 1 + ColInd mod NoCols;

        if (DateOffset < Periods) or ((DateOffset = Periods) and (ColIndex = 1)) then
            exit(SalesBoardMgt.GetQuantity("No.", GetFilter("Variant Filter"), GetFilter("Location Filter"),
              DateOffset, ColumnType[ColIndex]));
    end;

    procedure DrillDown(ColInd: Integer)
    var
        DateOffset: Integer;
        ColIndex: Integer;
    begin
        if "No." = '' then
            exit;

        DateOffset := ColInd div NoCols + ColumnOffset;
        ColIndex := 1 + ColInd mod NoCols;

        if (DateOffset < Periods) or ((DateOffset = Periods) and (ColIndex = 1)) then
            SalesBoardMgt.DrillDown("No.", GetFilter("Variant Filter"), GetFilter("Location Filter"),
              DateOffset, ColumnType[ColIndex]);
    end;

    local procedure SetLocationFilter()
    begin
        // P8007749
        SetRange("Location Filter", LocationFilter)
    end;

    local procedure SetVariantFilter()
    begin
        // P8007749
        SetRange("Variant Filter", VariantFilter)
    end;

    local procedure SetItemCategoryFilter()
    begin
        // P8007749
        SetFilter("Item Category Code", ItemCategoryFilter);
        ConvertItemCatFilterToItemCatOrderFilter;
    end;

    local procedure BaseDateOnAfterValidate()
    begin
        RegenerateBoard;
    end;

    local procedure PeriodOnAfterValidate()
    begin
        RegenerateBoard;
    end;

    local procedure PeriodsOnAfterValidate()
    begin
        if (MaxPeriods > 0) and (Periods > MaxPeriods) then
            Error(Text37000000, MaxPeriods);
        SetColumns;
        RegenerateBoard;
    end;

    local procedure ShortagesOnlyOnPush()
    begin
        CurrPage.Update(false);
    end;

    local procedure HideZeroOnPush()
    begin
        CurrPage.Update(false);
    end;

    local procedure DataElementDisplay2OnPush()
    begin
        SetColumns;
        CurrPage.Update(false);
    end;

    local procedure DataElementDisplay3OnPush()
    begin
        SetColumns;
        CurrPage.Update(false);
    end;

    local procedure DataElementDisplay4OnPush()
    begin
        SetColumns;
        CurrPage.Update(false);
    end;

    local procedure DataElementDisplay5OnPush()
    begin
        SetColumns;
        CurrPage.Update(false);
    end;

    local procedure DataElementDisplay6OnPush()
    begin
        SetColumns;
        CurrPage.Update(false);
    end;

    procedure ApplyColumnStyle(_ColInd: Integer; _ColIndex: Integer; _DateOffset: Integer)
    var
        ApplyStyle: Boolean;
    begin
        if (_DateOffset < Periods) or ((_DateOffset = Periods) and (_ColIndex = 1)) then
            ApplyStyle := (ColumnType[_ColIndex] = 1);

        case _ColInd of
            0:
                StyleColumn0 := ApplyStyle;
            1:
                StyleColumn1 := ApplyStyle;
            2:
                StyleColumn2 := ApplyStyle;
            3:
                StyleColumn3 := ApplyStyle;
            4:
                StyleColumn4 := ApplyStyle;
            5:
                StyleColumn5 := ApplyStyle;
            6:
                StyleColumn6 := ApplyStyle;
            7:
                StyleColumn7 := ApplyStyle;
            8:
                StyleColumn8 := ApplyStyle;
            9:
                StyleColumn9 := ApplyStyle;
            10:
                StyleColumn10 := ApplyStyle;
            11:
                StyleColumn11 := ApplyStyle;
            12:
                StyleColumn12 := ApplyStyle;
            13:
                StyleColumn13 := ApplyStyle;
            14:
                StyleColumn14 := ApplyStyle;
            15:
                StyleColumn15 := ApplyStyle;
            16:
                StyleColumn16 := ApplyStyle;
            17:
                StyleColumn17 := ApplyStyle;
            18:
                StyleColumn18 := ApplyStyle;
            19:
                StyleColumn19 := ApplyStyle;
            20:
                StyleColumn20 := ApplyStyle;
            21:
                StyleColumn21 := ApplyStyle;
            22:
                StyleColumn22 := ApplyStyle;
            23:
                StyleColumn23 := ApplyStyle;
            24:
                StyleColumn24 := ApplyStyle;
            25:
                StyleColumn25 := ApplyStyle;
            26:
                StyleColumn26 := ApplyStyle;
            27:
                StyleColumn27 := ApplyStyle;
            28:
                StyleColumn28 := ApplyStyle;
            29:
                StyleColumn29 := ApplyStyle;
            30:
                StyleColumn30 := ApplyStyle;
        end;
    end;
}

