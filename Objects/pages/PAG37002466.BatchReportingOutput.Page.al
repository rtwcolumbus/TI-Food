page 37002466 "Batch Reporting Output"
{
    AutoSplitKey = true;
    Caption = 'Batch Reporting Output';
    PageType = ListPart;
    SourceTable = "Item Journal Line";

    layout
    {
        area(content)
        {
            repeater(Control37002003)
            {
                ShowCaption = false;
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupItemNo;
                    end;
                }
                field(Allergens; AllergenManagement.AllergenCodeForRecord(0, 0, "Item No."))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Allergens';
                    Style = StrongAccent;
                    StyleExpr = TRUE;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        AllergenManagement.AllergenDrilldownForRecord(0, 0, "Item No.");
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Description';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(LotTrackingRequired; LotTrackingRequired)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Lot Tracked';
                }
                field(PostedQuantity; PostedQuantity)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Posted Quantity';
                    DecimalPlaces = 0 : 5;

                    trigger OnDrillDown()
                    begin
                        PostedQuantityDrillDown;
                    end;
                }
                field("Expected Quantity"; "Expected Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field(YieldPct; YieldPercent)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Yield %';
                    DecimalPlaces = 0 : 2;
                }
                field("Output Quantity"; "Output Quantity")
                {
                    ApplicationArea = FOODBasic;
                    trigger OnValidate()
                    var
                        ProdOrderLine: Record "Prod. Order Line";
                        ProdBOMHeader: Record "Production BOM Header";
                    begin
                        if "Output Quantity" = OutputQty then
                            exit;
                        OutputQty := "Output Quantity";

                        ProdOrderLine.Get(ProdOrderLine.Status::Released, "Order No.", "Order Line No.");
                        if ProdOrderLine."By-Product" then
                            exit;
                        if ProdBOMHeader.Get(ProdOrderLine."Production BOM No.") then
                            if ProdBOMHeader."Mfg. BOM Type" = ProdBOMHeader."Mfg. BOM Type"::BOM then
                                SetConsumptionQty(Rec);
                    end;
                }
                field("Output Quantity (Alt.)"; "Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord;
                        AltQtyMgmt.ShowItemJnlAltQtyLines(Rec);
                        CurrPage.Update;
                    end;

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord;
                        AltQtyMgmt.ValidateItemJnlAltQtyLine(Rec);
                        CurrPage.Update;
                    end;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                    trigger OnValidate()
                    begin
                        if "Unit of Measure Code" = xRec."Unit of Measure Code" then
                            exit;
                        ProdOrder.Get(ProdOrder.Status::Released, "Order No.");
                        if not ProdOrder."Batch Order" then
                            SetConsumptionQty(Rec);
                    end;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = LotNoEditable;

                    trigger OnAssistEdit()
                    begin
                        CurrPage.SaveRecord;
                        Commit;
                        EasyLotTracking.SetItemJnlLine(Rec, FieldNo("Lot No."));
                        if EasyLotTracking.AssistEdit("Lot No.") then
                            UpdateLotTracking(true);
                        CurrPage.SaveRecord;
                    end;

                    trigger OnValidate()
                    begin
                        if "Line No." = 0 then begin
                            CurrPage.SaveRecord;
                            UpdateLotTracking(false);
                        end;
                    end;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;

                    trigger OnValidate()
                    var
                        ConsumpJnlLine: Record "Item Journal Line";
                    begin
                        if "Location Code" = xRec."Location Code" then
                            exit;
                        ProdOrder.Get(ProdOrder.Status::Released, "Order No.");
                        if ProdOrder."Batch Order" then begin
                            ConsumpJnlLine.SetRange("Journal Template Name", ProcessSetup."Batch Consumption Template");
                            ConsumpJnlLine.SetRange("Journal Batch Name", ProcessSetup."Batch Consumption Batch");
                            ConsumpJnlLine.SetRange("Document No.", "Document No.");
                            ConsumpJnlLine.SetRange("No.", "Item No.");
                            ConsumpJnlLine.SetRange("Location Code", xRec."Location Code");
                            ConsumpJnlLine.ModifyAll("Bin Code", "Bin Code", true);
                            ConsumpJnlLine.ModifyAll("Location Code", "Location Code", true);
                        end;
                    end;
                }
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;

                    trigger OnValidate()
                    var
                        ConsumpJnlLine: Record "Item Journal Line";
                    begin
                        if "Bin Code" = xRec."Bin Code" then
                            exit;
                        ProdOrder.Get(ProdOrder.Status::Released, "Order No.");
                        if ProdOrder."Batch Order" then begin
                            ConsumpJnlLine.SetRange("Journal Template Name", ProcessSetup."Batch Consumption Template");
                            ConsumpJnlLine.SetRange("Journal Batch Name", ProcessSetup."Batch Consumption Batch");
                            ConsumpJnlLine.SetRange("Document No.", "Document No.");
                            ConsumpJnlLine.SetRange("No.", "Item No.");
                            ConsumpJnlLine.SetRange("Location Code", "Location Code");
                            ConsumpJnlLine.SetRange("Bin Code", xRec."Bin Code");
                            ConsumpJnlLine.ModifyAll("Bin Code", "Bin Code", true);
                        end;
                    end;
                }
                field("Container License Plate"; "Container License Plate")
                {
                    ApplicationArea = FOODBasic;
                    AccessByPermission = TableData "Container Header" = R;
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ContainerFns: Codeunit "Container Functions";
                    begin
                        exit(ContainerFns.LookupContainerOnItemJnlLine(Rec, FieldNo("Container License Plate"), Text));
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("&Dimensions")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Dimensions';
                Image = Dimensions;
                Promoted = true;
                PromotedOnly = true;
                ShortCutKey = 'Shift+Ctrl+D';

                trigger OnAction()
                begin
                    ShowDimensions;
                    CurrPage.SaveRecord;
                end;
            }
            action("Item &Tracking Lines")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Item &Tracking Lines';
                Image = ItemTrackingLines;
                Promoted = true;
                PromotedOnly = true;
                ShortCutKey = 'Shift+Ctrl+I';

                trigger OnAction()
                begin
                    ItemTracking;
                end;
            }
            action("New Container")
            {
                ApplicationArea = FOODBasic;
                AccessByPermission = TableData "Container Header" = R;
                Caption = 'New Container';
                Image = NewItem;
                Promoted = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    ContainerFns: Codeunit "Container Functions";
                begin
                    ContainerFns.NewContainerOnItemJournalLine(Rec);
                    CurrPage.Update;
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        OutputQty := "Output Quantity";
        SetLotFields('EDITABLE');
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        if "Output Quantity" <> 0 then
            Error(Text002, FieldName("Output Quantity"));
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        // P8000900
        FilterGroup(4);
        if GetFilter("Order Line No.") = '0' then
            SetRange("Order Line No.", 1, 2147483647);
        FilterGroup(0);
        exit(Find(Which));
    end;

    trigger OnInit()
    var
        grp: Integer;
    begin
        LotNoEditable := true;
        ProcessSetup.Get;
        ProcessSetup.TestField("Batch Output Template");
        ProcessSetup.TestField("Batch Output Batch");

        grp := FilterGroup(4);
        SetRange("Journal Template Name", ProcessSetup."Batch Output Template");
        SetRange("Journal Batch Name", ProcessSetup."Batch Output Batch");
        FilterGroup(grp);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if ProdOrder.Get(ProdOrder.Status::Released, xRec."Order No.") then begin
            SetUpNewLine(xRec);
            Validate("Order Type", "Order Type"::Production);
            Validate("Order No.", xRec."Order No.");
            Description := '';
            Validate("Document No.", xRec."Document No.");
            Validate("Order Line No.", xRec."Order Line No.");
            CreateProdDim;
        end;
    end;

    var
        ProcessSetup: Record "Process Setup";
        ProdOrder: Record "Production Order";
        OutputQty: Decimal;
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        EasyLotTracking: Codeunit "Easy Lot Tracking";
        Text002: Label '%1 must be zero.';
        AllergenManagement: Codeunit "Allergen Management";
        [InDataSet]
        LotNoEditable: Boolean;

    procedure UpdateForm()
    begin
        CurrPage.Update;
    end;

    procedure ItemTracking()
    begin
        CurrPage.SaveRecord;
        OpenItemTrackingLines(false);
    end;

    procedure SetLotFields(Property: Code[10])
    var
        ProcessFns: Codeunit "Process 800 Functions";
        P800Globals: Codeunit "Process 800 System Globals";
    begin
        case Property of
            'EDITABLE':
                LotNoEditable := ProcessFns.TrackingInstalled and ("Lot No." <> P800Globals.MultipleLotCode);
        end;
    end;

    procedure YieldPercent(): Decimal
    begin
        if "Expected Quantity" <> 0 then
            exit(100 * (PostedQuantity + "Output Quantity") / "Expected Quantity");
    end;
}
