page 37002046 "Item Cost Basis List"
{
    // PR4.00
    // P8000245B, Myers Nissi, Jack Reynolds, 04 OCT 05
    //   Modify to show price for blank variants and add subform for variant market prices
    // 
    // PR5.00
    // P8000539A, VerticalSoft, Don Bresee, 17 NOV 07
    //   Add Cost Basis Code and Currency Code
    //   Change Variant form to only be visible if the item has variants
    //   Move Item Type filter logic from OnTimer to OnFindRecord
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.02
    // P8000791, VerticalSoft, MMAS, 16 MAR 10
    //   Page had been changed after transformation
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001078, Columbus IT, Jack Reynolds, 13 JUN 12
    //   Fix filtering of Item Cost Values
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 19 FEB 13
    //   Restoring the SaveValues Property.
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW111.00
    // P80059471, To Increase, Jack Reynolds, 25 JUN 18
    //   Cleanup TimerUpdate property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    ApplicationArea = FOODBasic;
    Caption = 'Item Cost Bases';
    DataCaptionExpression = GetCaption();
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = Item;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(Control37002001)
            {
                ShowCaption = false;
                field("Cost Basis Code"; CostBasisCode)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Cost Basis Code';
                    NotBlank = true;
                    TableRelation = "Cost Basis";

                    trigger OnValidate()
                    begin
                        CostBasis.Get(CostBasisCode); // P8000539A
                        CurrPage.ItemVariant.PAGE.SetCostDate(CostBasisCode, CostDate); // P8000539A
                        CurrPage.Update(false);
                        ItemVariantDisplay; // P8000539A
                    end;
                }
                field("Currency Code"; CostBasis."Currency Code")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Currency Code';
                    Editable = false;
                    NotBlank = true;
                    TableRelation = Currency;
                }
                field("Cost Date"; CostDate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Cost Date';
                    NotBlank = true;

                    trigger OnValidate()
                    begin
                        CurrPage.ItemVariant.PAGE.SetCostDate(CostBasisCode, CostDate); // P8000245B, P8000539A
                        CurrPage.Update(false);
                    end;
                }
                field("Item Type Filter"; ItemTypeFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Type Filter';

                    trigger OnValidate()
                    begin
                        SetItemTypeFilter;
                        CurrPage.Update(false);
                    end;
                }
                field(ShowItemsWithPrices; ShowItemsWithPrices)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Items w/ Values Only';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }
            }
            group(Control37002002)
            {
                ShowCaption = false;
                repeater(ItemList)
                {
                    field("No."; "No.")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = false;
                    }
                    field(Description; Description)
                    {
                        ApplicationArea = FOODBasic;
                        Editable = false;
                    }
                    field("Base Unit of Measure"; "Base Unit of Measure")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Unit of Measure Code';
                        Editable = false;
                    }
                    field("Costing Method"; "Costing Method")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = false;
                        Visible = false;
                    }
                    field("Unit Cost"; "Unit Cost")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = false;
                    }
                    field("Standard Cost"; "Standard Cost")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = false;
                        Visible = false;
                    }
                    field(LastMarketPrice; LastMarketPrice)
                    {
                        ApplicationArea = FOODBasic;
                        AutoFormatExpression = CostBasis."Currency Code";
                        AutoFormatType = 2;
                        BlankZero = true;
                        Caption = 'Last Cost Value';
                        DecimalPlaces = 2 : 5;
                        Editable = false;
                    }
                    field(LastMarketPriceDate; LastMarketPriceDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Last Cost Value Date';
                        Editable = false;
                    }
                    field("Cost Value"; MarketPrice)
                    {
                        ApplicationArea = FOODBasic;
                        AutoFormatExpression = CostBasis."Currency Code";
                        AutoFormatType = 2;
                        BlankZero = true;
                        Caption = 'Cost Value';
                        DecimalPlaces = 2 : 5;

                        trigger OnDrillDown()
                        begin
                            ItemMarketPrice.GetCostValueAsOf(CostBasisCode, "No.", '', CostDate); // P8000245B, P8000539A
                            ItemMarketPrice.Reset;
                            ItemMarketPrice.SetRange("Cost Basis Code", CostBasisCode); // P8000539A
                            ItemMarketPrice.SetRange("Item No.", "No.");
                            ItemMarketPrice.SetRange("Variant Code", ''); // P8000245B
                            PAGE.RunModal(0, ItemMarketPrice);
                        end;

                        trigger OnValidate()
                        begin
                            ItemMarketPrice.SetCostValue(CostBasisCode, "No.", '', CostDate, MarketPrice); // P8000245B, P8000539A
                            if ShowItemsWithPrices and (MarketPrice = 0) then
                                CurrPage.Update(false);
                        end;
                    }
                }
            }
            part(ItemVariant; "Item Variant Cost Basis")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Item Variant';
                SubPageLink = "Item No." = FIELD("No.");
                Visible = ItemVariantVisible;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Refresh)
            {
                ApplicationArea = FOODBasic;
                Image = Refresh;
                ShortCutKey = 'F5';

                trigger OnAction()
                begin
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
                group("&Item Availability by")
                {
                    Caption = '&Item Availability by';
                    action(Period)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Period';
                        Image = Period;
                        RunObject = Page "Item Availability by Periods";
                        RunPageLink = "No." = FIELD("No."),
                                      "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                      "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                                      "Location Filter" = FIELD("Location Filter"),
                                      "Drop Shipment Filter" = FIELD("Drop Shipment Filter"),
                                      "Variant Filter" = FIELD("Variant Filter"),
                                      "Bin Filter" = FIELD("Bin Filter");
                    }
                    action(Variant)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Variant';
                        Image = ItemVariant;
                        RunObject = Page "Item Availability by Variant";
                        RunPageLink = "No." = FIELD("No."),
                                      "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                      "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                                      "Location Filter" = FIELD("Location Filter"),
                                      "Drop Shipment Filter" = FIELD("Drop Shipment Filter"),
                                      "Variant Filter" = FIELD("Variant Filter"),
                                      "Bin Filter" = FIELD("Bin Filter");
                    }
                    action(Location)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Location';
                        Image = Warehouse;
                        RunObject = Page "Item Availability by Location";
                        RunPageLink = "No." = FIELD("No."),
                                      "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                      "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                                      "Location Filter" = FIELD("Location Filter"),
                                      "Drop Shipment Filter" = FIELD("Drop Shipment Filter"),
                                      "Variant Filter" = FIELD("Variant Filter"),
                                      "Bin Filter" = FIELD("Bin Filter");
                    }
                }
                separator(Separator1102603033)
                {
                }
                action("Item Cost &Values")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Cost &Values';
                    Image = ItemCosts;

                    trigger OnAction()
                    var
                        ItemCostBasis: Record "Item Cost Basis";
                    begin
                        // P8001078
                        ItemCostBasis.FilterGroup(4);
                        ItemCostBasis.SetRange("Cost Basis Code", CostBasisCode);
                        ItemCostBasis.SetRange("Item No.", "No.");
                        ItemCostBasis.FilterGroup(0);
                        PAGE.Run(0, ItemCostBasis);
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(Refresh_Promoted; Refresh)
                {
                }
                actionref(ItemCostValues_Promoted; "Item Cost &Values")
                {
                }
                actionref(Card_Promoted; Card)
                {
                }
                actionref(LedgerEntries_Promoted; "Ledger E&ntries")
                {
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        ItemVariantDisplay; // P8000539A
    end;

    trigger OnAfterGetRecord()
    begin
        if CostInAlternateUnits() then
            "Base Unit of Measure" := "Alternate Unit of Measure";

        MarketPrice := ItemMarketPrice.GetCostValue(CostBasisCode, "No.", '', CostDate); // P8000245B, P8000539A

        LastMarketPrice := ItemMarketPrice.GetCostValueBefore(CostBasisCode, "No.", '', CostDate); // P8000245B, P8000539A
        LastMarketPriceDate := ItemMarketPrice."Cost Date";
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        // P8000539A
        if (ItemTypeFilter <> GetItemTypeFilter()) then begin
            ItemTypeFilter := GetItemTypeFilter();
            SetItemTypeFilter;
        end;
        // P8000539A

        //mmas temp
        //MESSAGE('%1', ItemTypeFilter);

        if not ShowItemsWithPrices then
            exit(Find(Which));
        exit(ItemFind(Which));
    end;

    trigger OnInit()
    begin
        ItemVariantVisible := true;
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        if not ShowItemsWithPrices then
            exit(Next(Steps));
        exit(ItemNext(Steps));
    end;

    trigger OnOpenPage()
    begin
        // P8000539A
        if (ExtCostBasisCode <> '') then
            CostBasisCode := ExtCostBasisCode;
        if not CostBasis.Get(CostBasisCode) then begin
            CostBasis.FindFirst;
            CostBasisCode := CostBasis.Code;
        end;
        if (ExtCostDate <> 0D) then
            CostDate := ExtCostDate;
        // P8000539A

        if (CostDate = 0D) then
            CostDate := WorkDate;
        CurrPage.ItemVariant.PAGE.SetCostDate(CostBasisCode, CostDate); // P8000245B, P8000539A

        ItemTypeFilter := GetItemTypeFilter();

        // P8000539A
        ItemVariantHeight := ItemVariantHeight;
        TopMargin := ItemListYPos;
        BottomMargin := FrmHeight - (ItemVariantYPos + ItemVariantHeight);
        // P8000539A
        ItemVariantDisplay; // P8000539A
    end;

    var
        CostDate: Date;
        ItemTypeFilter: Option "None","Raw Materials",Packaging,Intermediates,"Finished Goods";
        ShowItemsWithPrices: Boolean;
        LastMarketPrice: Decimal;
        LastMarketPriceDate: Date;
        MarketPrice: Decimal;
        Text000: Label '<Weekday Text>, <Month Text> <Day>, <Year4>';
        ItemMarketPrice: Record "Item Cost Basis";
        CostBasisCode: Code[20];
        CostBasis: Record "Cost Basis";
        ExtCostDate: Date;
        ExtCostBasisCode: Code[20];
        ItemVariantHeight: Integer;
        TopMargin: Integer;
        BottomMargin: Integer;
        ItemListYPos: Integer;
        ItemVariantYPos: Integer;
        FrmHeight: Integer;
        [InDataSet]
        ItemVariantVisible: Boolean;
        ItemListHeight: Integer;

    local procedure ItemFind(Which: Text[30]): Boolean
    var
        Item: Record Item;
    begin
        with Item do begin
            Copy(Rec);
            SetCurrentKey("No.");
            if not Find(Which) then
                exit(false);
            if not ShowItem(Item) then
                case Which of
                    '-':
                        if not ItemSkip(Item, 1) then
                            exit(false);
                    '+':
                        if not ItemSkip(Item, -1) then
                            exit(false);
                    else
                        if not ItemSkip(Item, 1) then
                            if not ItemSkip(Item, -1) then
                                exit(false);
                end;
        end;
        Rec := Item;
        exit(true);
    end;

    local procedure ItemNext(NumSteps: Integer): Integer
    var
        Item: Record Item;
        StepNo: Integer;
        Direction: Integer;
    begin
        with Item do begin
            Copy(Rec);
            SetCurrentKey("No.");
            Direction := 1;
            if (NumSteps < 0) then begin
                Direction := -Direction;
                NumSteps := -NumSteps;
            end;
            for StepNo := 1 to NumSteps do begin
                if not ItemSkip(Item, Direction) then
                    exit((StepNo - 1) * Direction);
                Rec := Item;
            end;
        end;
        exit(NumSteps * Direction);
    end;

    local procedure ItemSkip(var Item: Record Item; Direction: Integer): Boolean
    var
        ItemMarketPrice2: Record "Item Cost Basis";
        EntryFound: Boolean;
    begin
        ItemMarketPrice2.SetRange("Cost Basis Code", CostBasisCode); // P8000539A
        ItemMarketPrice2.SetRange("Cost Date", 0D, CostDate);
        repeat
            if (Direction > 0) then begin
                ItemMarketPrice2.SetFilter("Item No.", '>%1', Item."No.");
                EntryFound := ItemMarketPrice2.Find('-');
            end else begin
                ItemMarketPrice2.SetFilter("Item No.", '<%1', Item."No.");
                EntryFound := ItemMarketPrice2.Find('+');
            end;
            if not EntryFound then
                exit(false);
            Item."No." := ItemMarketPrice2."Item No.";
        until Item.Find;
        exit(true);
    end;

    local procedure ShowItem(var Item: Record Item): Boolean
    var
        ItemMarketPrice2: Record "Item Cost Basis";
    begin
        // P8000245B
        ItemMarketPrice2.SetRange("Cost Basis Code", CostBasisCode); // P8000539A
        ItemMarketPrice2.SetRange("Item No.", Item."No.");
        ItemMarketPrice2.SetRange("Cost Date", 0D, CostDate);
        exit(ItemMarketPrice2.Find('+'));
        // P8000245B
    end;

    local procedure GetCaption(): Text[250]
    begin
        // P8000539A
        if CostBasis.Get(CostBasisCode) then
            exit(StrSubstNo('%1 %2 - %3', CostBasisCode, CostBasis.Description, Format(CostDate, 0, Text000)));
        // P8000539A
        exit(Format(CostDate, 0, Text000));
    end;

    local procedure GetItemTypeFilter(): Integer
    var
        ItemTypeFilter2: Option " ","Raw Material",Packaging,Intermediate,"Finished Good",Container,Spare;
    begin
        if (GetFilter("Item Type") = '') then
            exit(ItemTypeFilter::None);
        if not Evaluate(ItemTypeFilter2, GetFilter("Item Type")) then begin
            SetRange("Item Type");
            exit(ItemTypeFilter::None);
        end;
        exit(ItemTypeFilter2);
    end;

    local procedure SetItemTypeFilter()
    begin
        if ItemTypeFilter = ItemTypeFilter::None then
            SetRange("Item Type")
        else
            SetRange("Item Type", ItemTypeFilter);
    end;

    local procedure ItemVariantDisplay()
    var
        ItemVariantRec: Record "Item Variant";
        Display: Boolean;
    begin
        // P8000539A
        ItemVariantRec.SetRange("Item No.", "No.");
        Display := ItemVariantRec.FindFirst;

        if (Display <> ItemVariantVisible) then begin  // P8000791
            if Display then begin
                ItemVariantVisible := true;
            end else begin
                ItemVariantVisible := false;
            end;
            CurrPage.Update(false);
        end;
    end;

    procedure SetCostDate(NewCostBasisCode: Code[20]; NewDate: Date)
    begin
        // P8000539A
        ExtCostBasisCode := NewCostBasisCode;
        ExtCostDate := NewDate;
    end;
}

