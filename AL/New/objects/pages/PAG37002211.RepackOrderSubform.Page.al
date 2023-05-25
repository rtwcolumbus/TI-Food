page 37002211 "Repack Order Subform"
{
    // PR4.00.06
    // P8000496A, VerticalSoft, Jack Reynolds, 24 JUL 07
    //   Standard subform for repack order lines
    // 
    // PR5.00
    // P8000504A, VerticalSoft, Jack Reynolds, 08 AUG 07
    //   Support for alternate quantities
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 15 JAN 10
    //   Change Form Caption
    // 
    // P8000664, VerticalSoft, Jimmy Abidi, 15 JAN 10
    //   Transformed from Form
    // 
    // PRW16.00.03
    // P8000817, VerticalSoft, Jack Reynolds, 26 APR 10
    //   Change visible property of fields
    // 
    // PRW18.00
    // P8001359, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add support for ShowMandatory
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds 17 NOV 13
    //   Lookup of Shortcut Dimensions
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW121.0
    // P800155629, To-Increase, Jack Reynolds, 03 NOV 22
    //   Add support for Mandatory Variant

    AutoSplitKey = true;
    Caption = 'Repack Order Subform';
    DelayedInsert = true;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Repack Order Line";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field(Type; Rec.Type)
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        SetLocationCodeMandatory; // P8001359
                    end;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = true;

                    // P800155629
                    trigger OnValidate()
                    begin
                        if Rec."Variant Code" = '' then
                            VariantCodeMandatory := Rec.IsVariantMandatory();
                    end;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = VariantCodeMandatory;
                    Visible = false;

                    // P800155629
                    trigger OnValidate()
                    begin
                        if Rec."Variant Code" = '' then
                            VariantCodeMandatory := Rec.IsVariantMandatory();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Source Location"; Rec."Source Location")
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = LocationCodeMandatory;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = true;
                }
                field("Quantity (Alt.)"; Rec."Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(Rec.LotNoLookup(Text));
                    end;
                }
                field("Quantity to Transfer"; Rec."Quantity to Transfer")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity to Transfer (Alt.)"; Rec."Quantity to Transfer (Alt.)")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        // P8000504A
                        CurrPage.SaveRecord;
                        AltQtyMgmt.ShowRepackLineAltQtyLines(Rec, Rec.FieldNo("Quantity to Transfer"));
                        CurrPage.Update;
                        // P8000504A
                    end;

                    trigger OnValidate()
                    begin
                        QuantitytoTransferAltOnAfterVa;
                    end;
                }
                field("Quantity Transferred"; Rec."Quantity Transferred")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity Transferred (Alt.)"; Rec."Quantity Transferred (Alt.)")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        AltQtyMgmt.ShowRepackLineAltQtyEntries(Rec, Rec.FieldNo("Quantity Transferred (Alt.)")); // P8000504A
                    end;
                }
                field("Quantity to Consume"; Rec."Quantity to Consume")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity to Consume (Alt.)"; Rec."Quantity to Consume (Alt.)")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        // P8000504A
                        CurrPage.SaveRecord;
                        AltQtyMgmt.ShowRepackLineAltQtyLines(Rec, Rec.FieldNo("Quantity to Consume"));
                        CurrPage.Update;
                        // P8000504A
                    end;

                    trigger OnValidate()
                    begin
                        QuantitytoConsumeAltOnAfterVal;
                    end;
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
            group("&Line")
            {
                Caption = '&Line';
                action(Dimensions)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        //This functionality was copied from page #37002210. Unsupported part was commented. Please check it.
                        /*CurrPage.RepackLines.PAGE.*/
                        _ShowDimensions;

                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetLocationCodeMandatory; // P8001359
    end;

    trigger OnAfterGetRecord()
    begin
        Rec.ShowShortcutDimCode(ShortcutDimCode);
        // P800155629
        if Rec."Variant Code" = '' then
            VariantCodeMandatory := Rec.IsVariantMandatory();
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
    end;

    var
        ProcessFns: Codeunit "Process 800 Functions";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        IsOpenForm: Boolean;
        [InDataSet]
        LocationCodeMandatory: Boolean;
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

    procedure _ShowDimensions()
    begin
        Rec.ShowDimensions;
    end;

    procedure ShowDimensions()
    begin
        Rec.ShowDimensions;
    end;

    local procedure QuantitytoTransferAltOnAfterVa()
    begin
        // P8000504A
        CurrPage.SaveRecord;
        AltQtyMgmt.ValidateRepackLineAltQtyLine(Rec, Rec.FieldNo("Quantity to Transfer"));
        CurrPage.Update;
        // P8000504A
    end;

    local procedure QuantitytoConsumeAltOnAfterVal()
    begin
        // P8000504A
        CurrPage.SaveRecord;
        AltQtyMgmt.ValidateRepackLineAltQtyLine(Rec, Rec.FieldNo("Quantity to Consume"));
        CurrPage.Update;
        // P8000504A
    end;

    local procedure SetLocationCodeMandatory()
    var
        InventorySetup: Record "Inventory Setup";
    begin
        // P8001359
        InventorySetup.Get;
        LocationCodeMandatory := InventorySetup."Location Mandatory" and (Rec.Type = Rec.Type::Item);
    end;

    local procedure SetDimensionVisibility()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        // P80073095
        DimMgt.UseShortcutDims(
          DimVisible1, DimVisible2, DimVisible3, DimVisible4, DimVisible5, DimVisible6, DimVisible7, DimVisible8);
    end;
}

