page 37002467 "Batch Reporting Consumption"
{
    AutoSplitKey = true;
    Caption = 'Batch Reporting Consumption';
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

                    trigger OnValidate()
                    var
                        LineNo: Integer;
                    begin
                        if "No." <> xRec."No." then begin
                            POComp.Reset;
                            if "Prod. Order Comp. Line No." <> 0 then begin
                                if POComp.Get(POComp.Status::Released, "Order No.", "Order Line No.",
                                  "Prod. Order Comp. Line No.") then begin
                                    POComp.Validate("Item No.", "No.");
                                    POComp.Modify;
                                end;
                            end else
                                if "No." <> '' then begin
                                    POComp.SetRange(Status, POComp.Status::Released);
                                    POComp.SetRange("Prod. Order No.", "Order No.");
                                    POComp.SetRange("Prod. Order Line No.", "Order Line No.");
                                    POComp.SetRange("Item No.", "No.");
                                    if not POComp.Find('-') then begin
                                        POComp.LockTable;
                                        POComp.SetRange("Item No.");
                                        if POComp.Find('+') then
                                            LineNo := POComp."Line No." + 10000
                                        else
                                            LineNo := 10000;
                                        POComp.Init;
                                        POComp.Status := POComp.Status::Released;
                                        POComp."Prod. Order No." := "Order No.";
                                        POComp."Prod. Order Line No." := "Order Line No.";
                                        POComp."Line No." := LineNo;
                                        POComp.Validate("Item No.", "No.");
                                        POComp.Insert(true);
                                    end;
                                    "Prod. Order Comp. Line No." := POComp."Line No.";
                                    POLine.Get(POLine.Status::Released, "Order No.", "Order Line No.");
                                    Validate("Location Code", POLine."Location Code");
                                end;
                        end;
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
                field(VariancePct; VariancePercent)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Variance %';
                    DecimalPlaces = 0 : 2;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity (Alt.)"; "Quantity (Alt.)")
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
                }
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = FOODBasic;
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
        SetLotFields('EDITABLE');
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        if Quantity <> 0 then
            Error(Text002, FieldName(Quantity));
    end;

    trigger OnInit()
    var
        grp: Integer;
    begin
        LotNoEditable := true;
        ProcessSetup.Get;
        ProcessSetup.TestField("Batch Consumption Template");
        ProcessSetup.TestField("Batch Consumption Batch");

        grp := FilterGroup(4);
        SetRange("Journal Template Name", ProcessSetup."Batch Consumption Template");
        SetRange("Journal Batch Name", ProcessSetup."Batch Consumption Batch");
        FilterGroup(grp);

        AutoUpdate := true;
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
        POLine: Record "Prod. Order Line";
        POComp: Record "Prod. Order Component";
        ProdOrder: Record "Production Order";
        AutoUpdate: Boolean;
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

    procedure VariancePercent(): Decimal
    begin
        if "Expected Quantity" <> 0 then
            exit(100 * (PostedQuantity + Quantity - "Expected Quantity") / "Expected Quantity");
    end;
}
