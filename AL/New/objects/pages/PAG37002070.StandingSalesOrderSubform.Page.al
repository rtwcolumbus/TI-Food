page 37002070 "Standing Sales Order Subform" // Version: FOODNA
{
    // PR3.70.10
    // P8000210A, Myers Nissi, Jack Reynolds, 10 MAY 05
    //   Add support for lot preferences
    // 
    // PR4.00.05
    // P8000440A, VerticalSoft, Jack Reynolds, 29 JAN 07
    //   Addcontrols for Line Discount Type and Line Discount Unit Amount
    // 
    // P8000443A, VerticalSoft, Jack Reynolds, 12 FEB 07
    //   Change price and discount fields to non-visible
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 25 JAN 10
    //   Change Form Caption
    // 
    // PRW16.00.03
    // P8000817, VerticalSoft, Jack Reynolds, 26 APR 10
    //   Change visible property of fields
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRNA7.00
    // P8001146, Columbus IT, Jack Reynolds, 19 DEC 13
    //   AutoReserve has Boolean parameter in NA database
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds 17 NOV 13
    //   Lookup of Shortcut Dimensions
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    //
    // PRW117.3
    // P80096165 To Increase, Jack Reynolds, 10 FEB 21
    //   Upgrade to 17.3 - Item Reference replaces Item Cross Reference
    // 
    // PRW120.00
    // P800144605, To Increase, Jack Reynolds, 20 APR 22
    //   Upgrade to 20.0
    // 
    // PRW121.0
    // P800155629, To-Increase, Jack Reynolds, 03 NOV 22
    //   Add support for Mandatory Variant

    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Sales Line";
    SourceTableView = WHERE("Document Type" = FILTER(FOODStandingOrder));

    layout
    {
        area(content)
        {
            repeater(Control37002001)
            {
                ShowCaption = false;
                field(Type; Rec.Type)
                {
                    ApplicationArea = FOODBasic;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(Rec.LookupNoField(Text)); // PR3.60
                    end;

                    trigger OnValidate()
                    var
                        Item: Record "Item";
                    begin
                        Rec.ShowShortcutDimCode(ShortcutDimCode);
                        InsertExtendedText(false);
                        // P800155629
                        if Rec."Variant Code" = '' then
                            VariantCodeMandatory := Item.IsVariantMandatory(Rec.Type = Rec.Type::Item, "No.");
                        // P800155629
                    end;
                }
                // P80096165
                field("Item Reference No."; Rec."Item Reference No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = ItemReferenceVisible;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        SalesHeader: Record "Sales Header";
                        ItemReferenceMgt: Codeunit "Item Reference Management";
                    begin
                        SalesHeader.Get("Document Type", Rec."Document No.");
                        ItemReferenceMgt.SalesReferenceNoLookup(Rec, SalesHeader);
                        InsertExtendedText(false);
                    end;

                    trigger OnValidate()
                    begin
                        InsertExtendedText(false);
                    end;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = VariantCodeMandatory;
                    Visible = false;

                    // P800155629
                    trigger OnValidate()
                    var
                        Item: Record "Item";
                    begin
                        if Rec."Variant Code" = '' then
                            VariantCodeMandatory := Item.IsVariantMandatory(Rec.Type = Rec.Type::Item, "No.");
                    end;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;

                    trigger OnValidate()
                    begin
                        if Rec.Reserve = Rec.Reserve::Always then begin
                            CurrPage.SaveRecord;
                            Rec.AutoReserve();  //P8001146
                        end;
                    end;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        if Rec.Reserve = Rec.Reserve::Always then begin
                            CurrPage.SaveRecord;
                            Rec.AutoReserve();  //P8001146
                        end;
                    end;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Quantity (Alt.)"; Rec."Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Qty. to Ship"; Rec."Qty. to Ship")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Qty. to Order';
                    // Visible = false; // P800-MegaApp
                }
                field("Unit Cost (LCY)"; Rec."Unit Cost (LCY)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Visible = false;
                }
                field("Line Amount"; Rec."Line Amount")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Visible = false;
                }
                field("Tax Group Code"; Rec."Tax Group Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Line Discount Type"; Rec."Line Discount Type")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Line Discount %"; Rec."Line Discount %")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Visible = false;
                }
                field("Line Discount Amount"; Rec."Line Discount Amount")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Line Discount Unit Amount"; Rec."Line Discount Unit Amount")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Allow Invoice Disc."; Rec."Allow Invoice Disc.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = DimVisible1;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = DimVisible2;
                }
                field("ShortcutDimCode[3]"; ShortcutDimCode[3])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,3';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible3;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field("ShortcutDimCode[4]"; ShortcutDimCode[4])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,4';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(4),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible4;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field("ShortcutDimCode[5]"; ShortcutDimCode[5])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,5';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(5),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible5;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field("ShortcutDimCode[6]"; ShortcutDimCode[6])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,6';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(6),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible6;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field("ShortcutDimCode[7]"; ShortcutDimCode[7])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,7';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(7),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible7;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field("ShortcutDimCode[8]"; ShortcutDimCode[8])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,8';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(8),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible8;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("Calculate &Invoice Discount")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Calculate &Invoice Discount';
                    Image = CalculateInvoiceDiscount;

                    trigger OnAction()
                    begin
                        //This functionality was copied from page #37002069. Unsupported part was commented. Please check it.
                        /*CurrPage.SalesLines.PAGE.*/
                        ApproveCalcInvDisc;

                    end;
                }
                action("E&xplode BOM")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'E&xplode BOM';
                    Image = ExplodeBOM;

                    trigger OnAction()
                    begin
                        //This functionality was copied from page #37002069. Unsupported part was commented. Please check it.
                        /*CurrPage.SalesLines.PAGE.*/
                        ExplodeBOM;

                    end;
                }
                action("Insert &Ext. Text")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Insert &Ext. Text';

                    trigger OnAction()
                    begin
                        //This functionality was copied from page #37002069. Unsupported part was commented. Please check it.
                        /*CurrPage.SalesLines.PAGE.*/
                        _InsertExtendedText(true);

                    end;
                }
            }
            group("&Line")
            {
                Caption = '&Line';
                group("Item Availability by")
                {
                    Caption = 'Item Availability by';
                    action(Period)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Period';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromSalesLine(Rec, ItemAvailFormsMgt.ByPeriod); // P8001132
                        end;
                    }
                    action(Variant)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Variant';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromSalesLine(Rec, ItemAvailFormsMgt.ByVariant); // P8001132
                        end;
                    }
                    action(Location)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Location';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromSalesLine(Rec, ItemAvailFormsMgt.ByLocation); // P8001132
                        end;
                    }
                }
                action(Dimensions)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        //This functionality was copied from page #37002069. Unsupported part was commented. Please check it.
                        /*CurrPage.SalesLines.PAGE.*/
                        _ShowDimensions;

                    end;
                }
                action("Lot Preferences")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Lot Preferences';

                    trigger OnAction()
                    begin
                        // P8000153A
                        //This functionality was copied from page #37002069. Unsupported part was commented. Please check it.
                        /*CurrPage.SalesLines.PAGE.*/
                        ShowLotPreferences;

                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        Item: Record "Item";
    begin
        Rec.ShowShortcutDimCode(ShortcutDimCode);
        // P800155629
        if Rec."Variant Code" = '' then
            VariantCodeMandatory := Item.IsVariantMandatory(Type = Type::Item, "No.");
        // P800155629
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        if not IsOpenForm then begin
            IsOpenForm := true;
        end;
        exit(Rec.Find(Which));
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.Type := xRec.Type;
        Clear(ShortcutDimCode);
        VariantCodeMandatory := false; // P800155629
    end;

    trigger OnOpenPage()
    begin
        SetDimensionVisibility; // P80073095
        SetItemReferenceVisibility(); // P80096165
    end;

    var
        SalesHeader: Record "Sales Header";
        ItemCrossReference: Record "Item Cross Reference";
        TransferExtendedText: Codeunit "Transfer Extended Text";
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        IsOpenForm: Boolean;
        [InDataSet]
        ItemReferenceVisible: Boolean;
        VariantCodeMandatory: Boolean;

    protected var
        ShortcutDimCode: array[8] of Code[20];
        DimVisible1: Boolean;
        DimVisible2: Boolean;
        DimVisible3: Boolean;
        DimVisible4: Boolean;
        DimVisible5: Boolean;
        DimVisible6: Boolean;
        DimVisible7: Boolean;
        DimVisible8: Boolean;

    procedure ApproveCalcInvDisc()
    begin
        CODEUNIT.Run(CODEUNIT::"Sales-Disc. (Yes/No)", Rec);
    end;

    procedure CalcInvDisc()
    begin
        CODEUNIT.Run(CODEUNIT::"Sales-Calc. Discount", Rec);
    end;

    procedure ExplodeBOM()
    begin
        CODEUNIT.Run(CODEUNIT::"Sales-Explode BOM", Rec);
    end;

    procedure _InsertExtendedText(Unconditionally: Boolean)
    begin
        if TransferExtendedText.SalesCheckIfAnyExtText(Rec, Unconditionally) then begin
            CurrPage.SaveRecord;
            TransferExtendedText.InsertSalesExtText(Rec);
        end;
        if TransferExtendedText.MakeUpdate then
            UpdateForm(true);
    end;

    procedure InsertExtendedText(Unconditionally: Boolean)
    begin
        if TransferExtendedText.SalesCheckIfAnyExtText(Rec, Unconditionally) then begin
            CurrPage.SaveRecord;
            TransferExtendedText.InsertSalesExtText(Rec);
        end;
        if TransferExtendedText.MakeUpdate then
            UpdateForm(true);
    end;

    procedure _ShowDimensions()
    begin
        Rec.ShowDimensions;
    end;

    procedure ShowDimensions()
    begin
        Rec.ShowDimensions;
    end;

    procedure UpdateForm(SetSaveRecord: Boolean)
    begin
        CurrPage.Update(SetSaveRecord);
    end;

    procedure ShowLotPreferences()
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        SalesLine: Record "Sales Line";
        LotPreferences: Page "Sales Line Lot Preferences";
    begin
        // P8000153A
        Rec.TestField(Type, Rec.Type::Item);
        Item.Get(Rec."No.");
        Item.TestField("Item Tracking Code");
        ItemTrackingCode.Get(Item."Item Tracking Code");
        ItemTrackingCode.TestField("Lot Specific Tracking", true);

        SalesLine := Rec;
        SalesLine.SetRecFilter;
        LotPreferences.SetTableView(SalesLine);
        LotPreferences.RunModal;
    end;

    local procedure SetDimensionVisibility()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        // P80073095
        DimMgt.UseShortcutDims(
          DimVisible1, DimVisible2, DimVisible3, DimVisible4, DimVisible5, DimVisible6, DimVisible7, DimVisible8);
    end;

    // P80096165
    local procedure SetItemReferenceVisibility()
    var
        ItemReferenceMgt: Codeunit "Item Reference Management";
    begin
        ItemReferenceVisible := ItemReferenceMgt.IsEnabled();
    end;
}

