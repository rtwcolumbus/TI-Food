page 37002663 "Term. Mkt. Line Input"
{
    // PR3.70.08
    // P8000169A, Myers Nissi, Jack Reynolds, 17 JAN 05
    //   GetUnitPrice - rewrite to avoid inserting a dummy sales line
    // 
    // PR4.00
    // P8000249A, Myers Nissi, Jack Reynolds, 20 OCT 05
    //   Modify call to pricing function to exclude accruals in unit price
    // 
    // P8000254A, Myers Nissi, Jack Reynolds, 21 OCT 05
    //   Use base unit of measure when calculating unit price
    // 
    // P8000253A, Myers Nissi, Jack Reynolds, 21 OCT 05
    //   Use quantity to order and unit price if set prior to running form
    // 
    // PRW16.00.01
    // P8000734, VerticalSoft, Jack Reynolds, 19 OCT 09
    //   Modify to distinguish between OK and CLOSE
    // 
    // PRW16.00.02
    // P8000797, VerticalSoft, MMAS, 25 MAR 10
    //   Page creation
    // 
    // PRW16.00.05
    // P8000944, Columbus IT, Jack Reynolds, 31 MAY 11
    //   Support for enahnced terminal market order entry
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001021, Columbus IT, Jack Reynolds, 17 JAN 12
    //   Fix problem with lenght of comment
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 07 DEC 16
    //   Item Category/Product Group
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // PRW118.01
    // P800128960, To Increase, Jack Reynolds, 24 AUG 21
    //   Decimal precision on alternate quantity data entry
    // 
    // PRW119.0
    // P800133109, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 19.0 - Qty. Rounding Precision

    Caption = 'Term. Mkt. Line Input';
    DataCaptionExpression = SetCaption;
    PageType = ConfirmationDialog;

    layout
    {
        area(content)
        {
            group(Item)
            {
                Caption = 'Item';
                field(ItemNo; Item."No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item';
                    Editable = false;
                }
                field("Item.Description"; Item.Description)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
            }
            group(Quantity)
            {
                group(Control37002003)
                {
                    ShowCaption = false;
                    field("ItemAvailability.""Quantity Available"""; ItemAvailability."Quantity Available")
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = ManualCaption[5];
                        Caption = 'Available';
                        DecimalPlaces = 0 : 5;
                        Editable = false;
                    }
                    field(Control37002006; '')
                    {
                        ApplicationArea = FOODBasic;
                        ShowCaption = false;
                    }
                    field(AvailableAlt; ItemAvailability."Quantity Available (Alt.)")
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = ManualCaption[8];
                        Caption = 'Available';
                        DecimalPlaces = 0 : 5;
                        Editable = false;
                        Visible = AvailableAltVisible;
                    }
                }
            }
            field(Qty; QtyToSell)
            {
                ApplicationArea = FOODBasic;
                CaptionClass = Format(QtyLabel) + ManualCaption[1];
                DecimalPlaces = 0 : 5;
                MinValue = 0;

                trigger OnValidate()
                var
                    UOMMgt: Codeunit "Unit of Measure Management";
                begin
                    // P800133109
                    QtyToSell := UOMMgt.RoundAndValidateQty(Item."No.", Item."Base Unit of Measure", QtyToSell, QtyLabel);
                    UOMMgt.CalcBaseQty(Item."No.", Item."Base Unit of Measure", QtyToSell);
                    // P800133109
                    if QtyToSell > ItemAvailability."Quantity Available" then
                        Error(Text005, QtyLabel);
                    CheckRepackQuantity(false);

                    QtyToSellAlt := Round(QtyToSell * ItemAvailability."Alternate Qty. per Base", 0.00001); // P8000253A
                end;
            }
            field(AltQty; QtyToSellAlt)
            {
                ApplicationArea = FOODBasic;
                AutoFormatExpression = Item."No.";
                AutoFormatType = 37002080;
                CaptionClass = Format(QtyLabel) + ' Alt. (' + Item."Alternate Unit of Measure" + ')';
                Editable = false;
                MinValue = 0;
                Visible = AltQtyVisible;

                trigger OnValidate()
                begin
                    if QtyToSellAlt > ItemAvailability."Quantity Available (Alt.)" then
                        Error(Text005, QtyLabel);
                    AltQtyMgmt.CheckTolerance(Item."No.", Text008, QtyToSell, QtyToSellAlt)
                end;
            }
            field(RepackItem; RepackItemNo)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Repack to';
                Editable = RepackItemEditable;
                TableRelation = Item;
                Visible = RepackItemVisible;

                trigger OnLookup(var Text: Text): Boolean
                var
                    Item2: Record Item;
                    ItemList: Page "Item List";
                begin
                    Item2.SetCurrentKey("Item Type", "Item Category Code"); // P8007749
                    Item2.SetRange("Item Category Code", Item."Item Category Code");
                    ItemList.SetTableView(Item2);
                    if Item2.Get(Text) then
                        ItemList.SetRecord(Item2);
                    ItemList.LookupMode(true);
                    if ItemList.RunModal = ACTION::LookupOK then begin
                        ItemList.GetRecord(Item2);
                        Text := Item2."No.";
                        exit(true);
                    end else
                        exit(false);
                end;

                trigger OnValidate()
                var
                    ItemTrackingCode: Record "Item Tracking Code";
                    TermMktMgt: Codeunit "Terminal Market Selling";
                begin
                    if RepackItemNo = xRepackItemNo then
                        exit;

                    RepackItem.Get(RepackItemNo);
                    if Item."No." = RepackItem."No." then
                        Error(Text004);
                    RepackItem.TestField("Item Category Code", Item."Item Category Code");
                    if ItemTrackingCode.Get(RepackItem."Item Tracking Code") then
                        if ItemTrackingCode."Lot Specific Tracking" then
                            if (not ItemTrackingCode.Get(Item."Item Tracking Code")) or (not ItemTrackingCode."Lot Specific Tracking") then
                                Error(Text009, Item.TableCaption, Item."No.");
                    if (RepackItem."Alternate Unit of Measure" <> '') and RepackItem."Catch Alternate Qtys." then
                        if 0 = TermMktMgt.GetAltQtyRepackFactor(Item."No.", Item."Base Unit of Measure",
                          RepackItem."Alternate Unit of Measure")
                        then
                            Error(Text006);
                    CheckRepackQuantity(true);
                    xRepackItemNo := RepackItemNo;

                    // assign costing unit of measure
                    ManualCaption[2] := TextUnitPrice;
                    if (ItemAvailability."Costing Unit of Measure" <> '') then
                        ManualCaption[2] += ' (' + ItemAvailability."Costing Unit of Measure" + ')';
                end;
            }
            field(UnitPrice; UnitPrice)
            {
                ApplicationArea = FOODBasic;
                AutoFormatType = 2;
                CaptionClass = ManualCaption[2];
                Caption = 'Unit Price';
            }
            field(Reason; Comment)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Comment';
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(OK)
            {
                ApplicationArea = FOODBasic;
                Caption = 'OK';

                trigger OnAction()
                begin
                    if RepackFlag and (RepackItemNo = '') and (QtyToSell <> 0) then
                        Error(Text007);
                    if not RepackOK then
                        Error(Text006);
                    OKToAdd := true; // P8000734
                    CurrPage.Close;
                end;
            }
        }
    }

    trigger OnInit()
    begin
        RepackItemEditable := true;
        AltQtyUOMVisible := true;
        AltQtyVisible := true;
        AltUOMVisible := true;
        AvailableAltVisible := true;
        OnOrderAltVisible := true;
        RemainingAltVisible := true;
        RepackLabelVisible := true;
        RepackItemVisible := true;
    end;

    trigger OnOpenPage()
    var
        XPosDiff: Integer;
    begin
        RepackItemVisible := RepackFlag;
        RepackLabelVisible := RepackFlag;
        RepackItemEditable := AddFlag;
        if not Item."Catch Alternate Qtys." then begin
            RemainingAltVisible := false;
            OnOrderAltVisible := false;
            AvailableAltVisible := false;
            AltUOMVisible := false;
            AltQtyVisible := false;
            AltQtyUOMVisible := false;
        end;

        // assign captions taking into account unit of measure
        ManualCaption[3] := TextRemaining;
        ManualCaption[4] := TextOnOrder;
        ManualCaption[5] := TextAvailable;
        if (Item."Base Unit of Measure" <> '') then begin
            ManualCaption[1] := ' (' + Item."Base Unit of Measure" + ')';
            ManualCaption[3] += ' (' + Item."Base Unit of Measure" + ')';
            ManualCaption[4] += ' (' + Item."Base Unit of Measure" + ')';
            ManualCaption[5] += ' (' + Item."Base Unit of Measure" + ')';
        end;

        ManualCaption[6] := TextRemaining;
        ManualCaption[7] := TextOnOrder;
        ManualCaption[8] := TextAvailable;
        if (Item."Alternate Unit of Measure" <> '') then begin
            ManualCaption[6] += ' (' + Item."Alternate Unit of Measure" + ')';
            ManualCaption[7] += ' (' + Item."Alternate Unit of Measure" + ')';
            ManualCaption[8] += ' (' + Item."Alternate Unit of Measure" + ')';
        end;

        ManualCaption[2] := TextUnitPrice;
        if (ItemAvailability."Costing Unit of Measure" <> '') then
            ManualCaption[2] += ' (' + ItemAvailability."Costing Unit of Measure" + ')';
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        case CloseAction of
            ACTION::Yes:
                begin
                    if RepackFlag and (RepackItemNo = '') and (QtyToSell <> 0) then
                        Error(Text007);
                    if not RepackOK then
                        Error(Text006);
                    OKToAdd := true; // P8000734
                    exit(true);
                end;
        end;
    end;

    var
        Item: Record Item;
        RepackItem: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ItemAvailability: Record "Item Lot Availability";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        AddFlag: Boolean;
        RepackFlag: Boolean;
        RepackOK: Boolean;
        OKToAdd: Boolean;
        QtyLabel: Text[30];
        QtyToSell: Decimal;
        QtyToSellAlt: Decimal;
        RepackItemNo: Code[20];
        xRepackItemNo: Code[20];
        RepackQty: Decimal;
        UnitPrice: Decimal;
        Comment: Text[30];
        Text000: Label 'Add %1';
        Text001: Label 'Change %1';
        Text002: Label 'Quantity to Repack';
        Text003: Label 'Quantity to Sell';
        Text004: Label 'An item cannot be repacked to itself.';
        Text005: Label '%1 may not exceed quantity available.';
        Text006: Label 'Repack cannot be performed.';
        Text007: Label 'Repack item must be entered.';
        Text008: Label 'Alternate Quantity';
        Text009: Label '%1 ''%2'' is not lot controlled.';
        [InDataSet]
        RepackItemVisible: Boolean;
        [InDataSet]
        RepackLabelVisible: Boolean;
        [InDataSet]
        RemainingAltVisible: Boolean;
        [InDataSet]
        OnOrderAltVisible: Boolean;
        [InDataSet]
        AvailableAltVisible: Boolean;
        [InDataSet]
        AltUOMVisible: Boolean;
        [InDataSet]
        AltQtyVisible: Boolean;
        [InDataSet]
        AltQtyUOMVisible: Boolean;
        [InDataSet]
        RepackItemEditable: Boolean;
        PriceUOMXPos: Integer;
        UnitPriceXPos: Integer;
        PriceLabelXPos: Integer;
        QtyLabelXPos: Integer;
        QtyXPos: Integer;
        Text19010637: Label 'Quantity';
        ManualCaption: array[10] of Text[30];
        TextUnitPrice: Label 'Unit Price';
        TextRemaining: Label 'Remaining';
        TextOnOrder: Label 'On Order';
        TextAvailable: Label 'Available';

    procedure SetCaption() Caption: Text[50]
    begin
        if AddFlag then
            Caption := Text000
        else
            Caption := Text001;
        exit(StrSubstNo(Caption, SalesLine.TableCaption));
    end;

    procedure SetVariables(Mode: Code[10]; Repack: Boolean; ItemAvail: Record "Item Lot Availability"; SalesHdr: Record "Sales Header"; Qty: Decimal; AltQty: Decimal; Price: Decimal; RPItem: Code[20]; Com: Text[25])
    begin
        AddFlag := (Mode = 'ADD');
        RepackFlag := Repack;
        ItemAvailability := ItemAvail;
        SalesHeader := SalesHdr;
        Item.Get(ItemAvailability."Item No.");

        if RepackFlag then
            QtyLabel := Text002
        else
            QtyLabel := Text003;

        // P8000253A Begin
        if AddFlag then begin
            QtyToSell := ItemAvail."Quantity to Sell";
            QtyToSellAlt := Round(QtyToSell * ItemAvailability."Alternate Qty. per Base", 0.00001);
            if not RepackFlag then
                UnitPrice := ItemAvail."Unit Price to Sell"; // P8000944
        end else begin
            // P8000253A
            QtyToSell := Qty;
            QtyToSellAlt := AltQty;
            RepackItemNo := RPItem;
            UnitPrice := Price;
        end;

        if RepackItemNo <> '' then
            RepackItem.Get(RepackItemNo);
        xRepackItemNo := RepackItemNo;

        RepackOK := (not RepackFlag) or (not AddFlag);
        if RepackFlag then begin
            ItemAvailability."Costing Unit of Measure" := '';
            CheckRepackQuantity(false);
        end;

        Comment := Com;
    end;

    procedure GetVariables(var Qty1: Decimal; var Price: Decimal; var ItemNo: Code[20]; var Qty2: Decimal; var Qty3: Decimal; var Com: Text[25]): Boolean
    begin
        // P8000734 - Added return value to indicate if OK button was pressed
        Qty1 := QtyToSell;
        Price := UnitPrice;
        ItemNo := RepackItemNo;
        Qty2 := RepackQty;
        Qty3 := QtyToSellAlt;
        Com := Comment;
        exit(OKToAdd); // P8000734
    end;

    procedure CheckRepackQuantity(ResetPrice: Boolean)
    var
        Item2: Record Item;
        UOMMgt: Codeunit "Unit of Measure Management";
    begin
        if not RepackFlag then
            exit;

        if RepackItemNo = '' then begin
            UnitPrice := 0;
            exit;
        end;

        Item.TestField("Units per Parcel");
        RepackItem.TestField("Units per Parcel");

        // P800133109
        RepackQty := QtyToSell * Item."Units per Parcel" / RepackItem."Units per Parcel";
        RepackQty := UOMMgt.RoundAndValidateQty(RepackItem."No.", RepackItem."Base Unit of Measure", RepackQty, QtyLabel);
        UOMMgt.CalcBaseQty(Item."No.", Item."Base Unit of Measure", QtyToSell);
        // P800133109
        RepackOK := 0 = RepackQty mod 1;
        if not RepackOK then
            Error(Text006);

        if ResetPrice then
            UnitPrice := GetUnitPrice(RepackItem);

        ItemAvailability."Costing Unit of Measure" := RepackItem."Alternate Unit of Measure";
    end;

    procedure GetUnitPrice(Item: Record Item): Decimal
    var
        Customer: Record Customer;
        SalesLine: Record "Sales Line";
        PriceCalcMgt: Codeunit "Sales Price Calc. Mgt.";
        UOMCode: Code[10];
    begin
        // P8000253A
        Customer.Get(SalesHeader."Bill-to Customer No.");
        PriceCalcMgt.FindCustomerPriceListPrice(Item, Customer, '', Item."Base Unit of Measure", SalesHeader."Order Date", false);
        exit(Item."Unit Price");
    end;
}

