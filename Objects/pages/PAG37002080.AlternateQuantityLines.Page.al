page 37002080 "Alternate Quantity Lines"
{
    // PR3.60
    //   Create form for alternate quantity entry
    // 
    // PR3.61.01
    //   Fix problems with transfer orders
    // 
    // PR3.70.04
    // P8000043A, Myers Nissi, Jack Reynolds, 25 MAY 04
    //   Support for default lot numbers, easy lot control
    // 
    // PR5.00
    // P8000504A, VerticalSoft, Jack Reynolds, 08 AUG 07
    //   Support for alternate quantities on repack orders
    // 
    // PRW15.00.01
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   Add support for delivery trip pick lines
    // 
    // P8000566A, VerticalSoft, Jack Reynolds, 28 MAY 08
    //   Fix problem with reclass, lot tracking, and alternate quantity
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 27 JUL 09
    //   Transformed - additions in TIF Editor
    //   Page changes made after transformation
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW19.00
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup old delivery trips
    // 
    // P8007924, To-Increase, Dayakar Battini, 03 NOV 16
    //   Alt Qty handling for Return Order/ Credit Memo
    // 
    // PRW110.0.02
    // P80046533, To-Increase, Jack Reynolds, 10 OCT 17
    //   Inbound containers and shipping containers
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // PRW118.01
    // P800127049, To Increase, Jack Reynolds, 23 AUG 21
    //   Support for Inventory documents
    //   Cleanup layout
    //
    // PRW118.01
    // P800128960, To Increase, Jack Reynolds, 24 AUG 21
    //   Decimal precision on alternate quantity data entry

    Caption = 'Alternate Quantity Lines';
    DataCaptionExpression = GetCaption;
    DelayedInsert = true;
    PageType = Worksheet;
    SourceTable = "Alternate Quantity Line";

    layout
    {
        area(content)
        {
            field(Control37002003; GetItemInformation1())
            {
                ApplicationArea = FOODBasic;
                Caption = 'Item';
            }
            field(Control37002001; GetItemInformation2())
            {
                ApplicationArea = FOODBasic;
                CaptionClass = SourceQtyFieldName;
            }
            repeater(Control37002004)
            {
                ShowCaption = false;
                field("Line No."; SeqNo)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Line No.';
                    Editable = false;
                    Style = Subordinate;
                    StyleExpr = "Container ID" <> '';
                }
                field(Control37002006; "Serial No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = SerialNoEditable;
                    Enabled = SerialNoEnable;
                    Style = Subordinate;
                    StyleExpr = "Container ID" <> '';
                    Visible = SerialNoVisible;

                    trigger OnAssistEdit()
                    var
                        AltQtyTracking: Codeunit "Alt. Qty. Tracking Management";
                    begin
                        if AltQtyTracking.AssistEditSerialNo(Rec) then
                            CurrPage.Update;
                    end;
                }
                field(Control37002007; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = LotNoEditable;
                    Enabled = LotNoEnable;
                    Style = Subordinate;
                    StyleExpr = "Container ID" <> '';
                    Visible = LotNoVisible;

                    trigger OnAssistEdit()
                    var
                        AltQtyTracking: Codeunit "Alt. Qty. Tracking Management";
                    begin
                        if AltQtyTracking.AssistEditLotNo(Rec) then
                            CurrPage.Update;
                    end;
                }
                field("New Lot No."; "New Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = NewLotNoEditable;
                    Enabled = NewLotNoEnable;
                    Style = Subordinate;
                    StyleExpr = "Container ID" <> '';
                    Visible = NewLotNoVisible;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                    Style = Subordinate;
                    StyleExpr = "Container ID" <> '';

                    trigger OnValidate()
                    begin
                        ValidateBaseQty;
                    end;
                }
                field("Quantity (Base)"; "Quantity (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Style = Subordinate;
                    StyleExpr = "Container ID" <> '';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateBaseQty;
                    end;
                }
                field("Quantity (Alt.)"; "Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    AutoFormatExpression = GetItemNo();
                    AutoFormatType = 37002080;
                    Style = Subordinate;
                    StyleExpr = "Container ID" <> '';

                    trigger OnValidate()
                    begin
                        ValidateAltQty;   // P8007924
                    end;
                }
                field("Invoiced Qty. (Base)"; "Invoiced Qty. (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Style = Subordinate;
                    StyleExpr = "Container ID" <> '';
                    Visible = false;
                }
                field("Invoiced Qty. (Alt.)"; "Invoiced Qty. (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    Style = Subordinate;
                    StyleExpr = "Container ID" <> '';
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
            group("Tracking Button")
            {
                Caption = 'T&racking';
                Enabled = Trackingbuttonenable;
                action("Assign &Serial No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Assign &Serial No.';
                    Image = CreateSerialNo;

                    trigger OnAction()
                    var
                        AltQtyTracking: Codeunit "Alt. Qty. Tracking Management";
                    begin
                        if "Serial No." = '' then begin
                            CurrPage.SaveRecord;
                            AltQtyTracking.AssignSerialNo(Rec);
                            CurrPage.Update;
                        end;
                    end;
                }
                action("Assign &Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Assign &Lot No.';
                    Image = LotInfo;

                    trigger OnAction()
                    var
                        AltQtyTracking: Codeunit "Alt. Qty. Tracking Management";
                    begin
                        if "Lot No." = '' then begin
                            CurrPage.SaveRecord;
                            AltQtyTracking.AssignLotNo(Rec);
                            CurrPage.Update;
                        end;
                    end;
                }
                group(Information)
                {
                    Caption = 'Information';
                    action("Serial No.")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Serial No.';
                        Image = SerialNo;

                        trigger OnAction()
                        var
                            AltQtyTracking: Codeunit "Alt. Qty. Tracking Management";
                        begin
                            TestField("Serial No.");
                            AltQtyTracking.ShowSerialInfo(Rec);
                        end;
                    }
                    action("Lot No.")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Lot No.';
                        Image = Lot;

                        trigger OnAction()
                        var
                            AltQtyTracking: Codeunit "Alt. Qty. Tracking Management";
                        begin
                            TestField("Lot No.");
                            AltQtyTracking.ShowLotInfo(Rec);
                        end;
                    }
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        DefaultLotNo := "Lot No."; // P8000043A
        DefaultNewLotNo := "New Lot No.";
    end;

    trigger OnAfterGetRecord()
    begin
        SeqNo := GetSeqNo("Line No.");
    end;

    trigger OnInit()
    begin
        //P8000664 begin
        TrackingButtonEnable := true;
        NewLotNoEnable := true;
        LotNoEnable := true;
        SerialNoEnable := true;
        NewLotNoEditable := true;
        LotNoEditable := true;
        SerialNoEditable := true;
        LotNoVisible := true;
        SerialNoVisible := true;
        //P8000664 end
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if BelowxRec then
            SeqNo := GetSeqNo(0)
        else
            SeqNo := GetSeqNo(xRec."Line No.");

        SetUpNewLine(xRec, SourceTableNo, SourceDocumentType, SourceDocumentNo,
                     SourceTemplateName, SourceBatchName, SourceLineNo, SourceQtyBase);
        xRec."Alt. Qty. Transaction No." := Rec."Alt. Qty. Transaction No.";
        AutoSplitLineNo(xRec, BelowxRec);
        "Serial No." := SerialNo;
        if LotNo <> '' then          // P8000043A
            "Lot No." := LotNo         // P8000043A
        else                         // P8000043A
            "Lot No." := DefaultLotNo; // P8000043A
        if NewLotNo <> '' then              // P8000043A
            "New Lot No." := NewLotNo         // P8000043A
        else                                // P8000043A
            "New Lot No." := DefaultNewLotNo; // P8000043A
    end;

    trigger OnOpenPage()
    begin
        //P8000664 begin
        TrackingButtonEnable := (SerialTracking or LotTracking);
        SerialNoEnable := SerialTracking;
        SerialNoVisible := SerialTracking;
        SerialNoEditable := SerialNo = '';
        LotNoEnable := LotTracking;
        LotNoVisible := LotTracking;
        LotNoEditable := LotNo = '';
        NewLotNoEnable := LotTracking and Reclass; // P8000566A
        NewLotNoVisible := (LotTracking and Reclass); // P8000566A
        NewLotNoEditable := NewLotNo = '';          // P8000566A
        //P8000664 end
    end;

    var
        SeqNo: Integer;
        SourceTableNo: Integer;
        SourceDocumentType: Integer;
        SourceDocumentNo: Code[20];
        PickNo: Integer;
        SourceTemplateName: Code[10];
        SourceBatchName: Code[10];
        SourceLineNo: Integer;
        SourceQtyBase: Decimal;
        SourceQtyFieldName: Text[30];
        SourceMaxQtyBase: Decimal;
        Text001: Label '%1 %2 cannot exceed %3.';
        SerialTracking: Boolean;
        LotTracking: Boolean;
        SerialNo: Code[50];
        LotNo: Code[50];
        Text002: Label 'Transfer Order';
        NewLotNo: Code[50];
        DefaultLotNo: Code[50];
        DefaultNewLotNo: Code[50];
        Reclass: Boolean;
        [InDataSet]
        SerialNoVisible: Boolean;
        [InDataSet]
        LotNoVisible: Boolean;
        [InDataSet]
        SerialNoEditable: Boolean;
        [InDataSet]
        LotNoEditable: Boolean;
        [InDataSet]
        NewLotNoEditable: Boolean;
        [InDataSet]
        SerialNoEnable: Boolean;
        [InDataSet]
        LotNoEnable: Boolean;
        [InDataSet]
        NewLotNoEnable: Boolean;
        [InDataSet]
        NewLotNoVisible: Boolean;
        [InDataSet]
        TrackingButtonEnable: Boolean;
        SourceMaxAltQtyBase: Decimal;

    local procedure GetCaption(): Text[250]
    var
        ItemJnlBatch: Record "Item Journal Batch";
        InvtDocumentHeader: Record "Invt. Document Header";
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        TransHeader: Record "Transfer Header";
        RepackOrder: Record "Repack Order";
    begin
        case SourceTableNo of
            DATABASE::"Item Journal Line":
                begin
                    ItemJnlBatch.Get(SourceTemplateName, SourceBatchName);
                    if (ItemJnlBatch.Description = '') then
                        exit(SourceBatchName);
                    exit(StrSubstNo('%1 %2', SourceBatchName, ItemJnlBatch.Description));
                end;
            // P800127049
            Database::"Invt. Document Line":
                begin
                    InvtDocumentHeader.Get(SourceDocumentType, SourceDocumentNo);
                    exit(StrSubstNo('%1 %2', InvtDocumentHeader."Document Type", InvtDocumentHeader."No."));
                end;
            // P800127049
            DATABASE::"Sales Line":
                begin
                    SalesHeader.Get(SourceDocumentType, SourceDocumentNo);
                    exit(StrSubstNo('%1 %2', SalesHeader."Document Type", SalesHeader."No."));
                end;
            DATABASE::"Purchase Line":
                begin
                    PurchHeader.Get(SourceDocumentType, SourceDocumentNo);
                    exit(StrSubstNo('%1 %2', PurchHeader."Document Type", PurchHeader."No."));
                end;
            // PR3.61.01 Begin
            DATABASE::"Transfer Line":
                begin
                    TransHeader.Get(SourceDocumentNo);
                    exit(StrSubstNo('%1 %2', Text002, TransHeader."No."));
                end;
            // PR3.61.01 End
            // P8000504A
            DATABASE::"Repack Order", DATABASE::"Repack Order Line":
                begin
                    RepackOrder.Get(SourceDocumentNo);
                    exit(StrSubstNo('%1 %2', RepackOrder.TableCaption, RepackOrder."No."));
                end;
        // P8000504A
        end;
    end;

    procedure SetSource(TableNo: Integer; DocumentType: Integer; DocumentNo: Code[20]; TemplateName: Code[10]; BatchName: Code[10]; LineNo: Integer)
    var
        ItemJnlLine: Record "Item Journal Line";
        InvtDocumentHeader: Record "Invt. Document Header";
    begin
        SourceTableNo := TableNo;
        SourceDocumentType := DocumentType;
        SourceDocumentNo := DocumentNo;
        if SourceTableNo = DATABASE::"Delivery Trip Pick Line" then // P8000549A
            Evaluate(PickNo, SourceDocumentNo);                        // P8000549A
        SourceTemplateName := TemplateName;
        SourceBatchName := BatchName;
        SourceLineNo := LineNo;

        // P8000566A
        if SourceTableNo = DATABASE::"Item Journal Line" then begin
            ItemJnlLine.Get(SourceTemplateName, SourceBatchName, SourceLineNo);
            Reclass := ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Transfer;
        end;
        // P8000566A

        // P800127049
        if SourceTableNo = Database::"Invt. Document Line" then begin
            InvtDocumentHeader.Get(SourceDocumentType, SourceDocumentNo);
            CurrPage.Editable(InvtDocumentHeader.Status = InvtDocumentHeader.Status::Open)
        end;
        // P800127049
    end;

    procedure SetQty(QtyBase: Decimal; QtyFieldName: Text[30])
    begin
        SourceQtyBase := QtyBase;
        SourceQtyFieldName := QtyFieldName;
    end;

    procedure SetMaxQty(MaxQtyBase: Decimal)
    begin
        SourceMaxQtyBase := MaxQtyBase;
    end;

    local procedure GetSeqNo(CurrLineNo: Integer): Integer
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        AltQtyLine.Copy(Rec);
        if (CurrLineNo <> 0) then
            AltQtyLine.SetFilter("Line No.", '<%1', CurrLineNo);
        exit(AltQtyLine.Count + 1);
    end;

    local procedure ValidateBaseQty()
    var
        AltQtyLine: Record "Alternate Quantity Line";
        ObjTransl: Record "Object Translation";
        Item: Record Item;
        EntryUOM: Code[10];
        BaseQtyPerEntryUOM: Decimal;
    begin
        if (SourceMaxQtyBase = 0) then
            exit;
        AltQtyLine.SetCurrentKey("Alt. Qty. Transaction No.", "Serial No.", "Lot No.");
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", "Alt. Qty. Transaction No.");
        AltQtyLine.SetFilter("Line No.", '<>%1', "Line No.");
        if SerialNo <> '' then
            AltQtyLine.SetRange("Serial No.", SerialNo);
        if LotNo <> '' then
            AltQtyLine.SetRange("Lot No.", LotNo);
        AltQtyLine.CalcSums("Quantity (Base)");
        if (("Quantity (Base)" + AltQtyLine."Quantity (Base)") > SourceMaxQtyBase) then begin
            GetItem(Item, EntryUOM, BaseQtyPerEntryUOM);
            Error(Text001,
              ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, SourceTableNo),
              SourceQtyFieldName, Round(SourceMaxQtyBase / BaseQtyPerEntryUOM, 0.00001));
        end;
    end;

    // P800128960
    local procedure GetItemNo(): Code[20]
    var
        Item: Record Item;
        EntryUOM: Code[10];
        BaseQtyPerEntryUOM: Decimal;
    begin
        GetItem(Item, EntryUOM, BaseQtyPerEntryUOM);
        exit(Item."No.");
    end;

    local procedure GetItem(var Item: Record Item; var EntryUOM: Code[10]; var BaseQtyPerEntryUOM: Decimal): Text[250]
    var
        ItemJnlLine: Record "Item Journal Line";
        InvtDocLine: Record "Invt. Document Line";
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
        RepackOrder: Record "Repack Order";
        RepackLine: Record "Repack Order Line";
        UOMMgmt: Codeunit "Unit of Measure Management";
    begin
        case SourceTableNo of
            DATABASE::"Item Journal Line":
                begin
                    ItemJnlLine.Get(SourceTemplateName, SourceBatchName, SourceLineNo);
                    Item.Get(ItemJnlLine."Item No.");
                    EntryUOM := ItemJnlLine."Unit of Measure Code";
                    BaseQtyPerEntryUOM := UOMMgmt.GetQtyPerUnitOfMeasure(Item, EntryUOM);
                end;
            // P800127049    
            DATABASE::"Invt. Document Line":
                begin
                    InvtDocLine.Get(SourceDocumentType, SourceDocumentNo, SourceLineNo);
                    Item.Get(InvtDocLine."Item No.");
                    EntryUOM := InvtDocLine."Unit of Measure Code";
                    BaseQtyPerEntryUOM := UOMMgmt.GetQtyPerUnitOfMeasure(Item, EntryUOM);
                end;
            // P800127049
            DATABASE::"Sales Line":
                begin
                    SalesLine.Get(SourceDocumentType, SourceDocumentNo, SourceLineNo);
                    Item.Get(SalesLine."No.");
                    EntryUOM := SalesLine."Unit of Measure Code";
                    BaseQtyPerEntryUOM := UOMMgmt.GetQtyPerUnitOfMeasure(Item, EntryUOM);
                end;
            DATABASE::"Purchase Line":
                begin
                    PurchLine.Get(SourceDocumentType, SourceDocumentNo, SourceLineNo);
                    Item.Get(PurchLine."No.");
                    EntryUOM := PurchLine."Unit of Measure Code";
                    BaseQtyPerEntryUOM := UOMMgmt.GetQtyPerUnitOfMeasure(Item, EntryUOM);
                end;
            // PR3.60.01 Begin
            DATABASE::"Transfer Line":
                begin
                    TransLine.Get(SourceDocumentNo, SourceLineNo);
                    Item.Get(TransLine."Item No.");
                    EntryUOM := TransLine."Unit of Measure Code";
                    BaseQtyPerEntryUOM := UOMMgmt.GetQtyPerUnitOfMeasure(Item, EntryUOM);
                end;
            // PR3.60.01 End
            // P8000504A
            DATABASE::"Repack Order":
                begin
                    RepackOrder.Get(SourceDocumentNo);
                    Item.Get(RepackOrder."Item No.");
                    EntryUOM := RepackOrder."Unit of Measure Code";
                    BaseQtyPerEntryUOM := UOMMgmt.GetQtyPerUnitOfMeasure(Item, EntryUOM);
                end;
            DATABASE::"Repack Order Line":
                begin
                    RepackLine.Get(SourceDocumentNo, SourceLineNo);
                    Item.Get(RepackLine."No.");
                    EntryUOM := RepackLine."Unit of Measure Code";
                    BaseQtyPerEntryUOM := UOMMgmt.GetQtyPerUnitOfMeasure(Item, EntryUOM);
                end;
        // P8000504A
        end;
    end;

    local procedure GetItemInformation1(): Text[250]
    var
        Item: Record Item;
        EntryUOM: Code[10];
        BaseQtyPerEntryUOM: Decimal;
    begin
        GetItem(Item, EntryUOM, BaseQtyPerEntryUOM);
        exit(StrSubstNo('%1 - %2', Item."No.", Item.Description));
    end;

    local procedure GetItemInformation2(): Text[250]
    var
        Item: Record Item;
        EntryUOM: Code[10];
        BaseQtyPerEntryUOM: Decimal;
    begin
        GetItem(Item, EntryUOM, BaseQtyPerEntryUOM);
        exit(StrSubstNo('%1 (%2)', Round(SourceQtyBase / BaseQtyPerEntryUOM, 0.00001), EntryUOM));
    end;

    procedure SetTracking(SerialTrackingFlag: Boolean; LotTrackingFlag: Boolean)
    begin
        SerialTracking := SerialTrackingFlag;
        LotTracking := LotTrackingFlag;
    end;

    procedure SetLotAndSerial(LN: Code[20]; SN: Code[20])
    begin
        LotNo := LN;
        SerialNo := SN;
    end;

    procedure SetNewLot(LN: Code[20])
    begin
        // P8000566A
        NewLotNo := LN;
    end;

    procedure AutoSplitLineNo(xRec: Record "Alternate Quantity Line"; BelowxRec: Boolean)
    var
        AltQtyLine: Record "Alternate Quantity Line";
        Steps: Integer;
    begin
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", xRec."Alt. Qty. Transaction No.");
        if not AltQtyLine.Get(xRec."Alt. Qty. Transaction No.", xRec."Line No.") then begin
            if AltQtyLine.Find('+') then
                "Line No." := AltQtyLine."Line No." + 10000
            else
                "Line No." := 10000;
        end else begin
            if BelowxRec then
                Steps := 1
            else
                Steps := -1;
            if AltQtyLine.Next(Steps) <> 0 then
                "Line No." := (xRec."Line No." + AltQtyLine."Line No.") div 2
            else
                if BelowxRec then
                    "Line No." := AltQtyLine."Line No." + 10000
                else
                    "Line No." := AltQtyLine."Line No." div 2;
        end;
    end;

    procedure SetDefaultLot(LN: Code[20])
    begin
        // P8000043A
        DefaultLotNo := LN;
    end;

    procedure SetDefaultNewLot(LN: Code[20])
    begin
        // P8000566A
        DefaultNewLotNo := LN;
    end;

    procedure SetMaxAltQty(MaxAltQtyBase: Decimal)
    begin
        SourceMaxAltQtyBase := MaxAltQtyBase;   // P8007924
    end;

    local procedure ValidateAltQty()
    var
        AltQtyLine: Record "Alternate Quantity Line";
        ObjTransl: Record "Object Translation";
        Item: Record Item;
        EntryUOM: Code[10];
        BaseQtyPerEntryUOM: Decimal;
    begin
        // P8007924
        if (SourceMaxAltQtyBase = 0) then
            exit;
        AltQtyLine.SetCurrentKey("Alt. Qty. Transaction No.", "Serial No.", "Lot No.");
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", "Alt. Qty. Transaction No.");
        AltQtyLine.SetFilter("Line No.", '<>%1', "Line No.");
        if SerialNo <> '' then
            AltQtyLine.SetRange("Serial No.", SerialNo);
        if LotNo <> '' then
            AltQtyLine.SetRange("Lot No.", LotNo);
        AltQtyLine.CalcSums("Quantity (Alt.)");
        if (("Quantity (Alt.)" + AltQtyLine."Quantity (Alt.)") > SourceMaxAltQtyBase) then begin
            GetItem(Item, EntryUOM, BaseQtyPerEntryUOM);
            Error(Text001,
              ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, SourceTableNo),
              SourceQtyFieldName, SourceMaxAltQtyBase);
        end;
        // P8007924
    end;
}

