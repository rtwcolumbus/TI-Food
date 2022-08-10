page 37002088 "Multiple Lot Trace"
{
    // PRW16.00.05
    // P8000984, Columbus IT, Don Bresee, 18 OCT 11
    //   Add Multiple Lot Trace
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    ApplicationArea = FOODBasic;
    AutoSplitKey = true;
    Caption = 'Multiple Lot Trace';
    DelayedInsert = true;
    PageType = Worksheet;
    SourceTable = "Lot Tracing Buffer";
    SourceTableTemporary = true;
    SourceTableView = SORTING("Line No.");
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group("Trace Lots")
            {
                Caption = 'Trace Lots';
                repeater(Control37002005)
                {
                    ShowCaption = false;
                    field("Item No."; "Item No.")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = true;
                        TableRelation = Item WHERE("Item Tracking Code" = FILTER(<> ''));

                        trigger OnValidate()
                        begin
                            ValidateField(FieldNo("Item No."));
                        end;
                    }
                    field("Variant Code"; "Variant Code")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = true;
                        Visible = false;

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            exit(LotTracingMgmt.LookupVariantCode("Item No.", Text));
                        end;

                        trigger OnValidate()
                        begin
                            ValidateField(FieldNo("Variant Code"));
                        end;
                    }
                    field("GetDescription()"; GetDescription())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Description';
                        Editable = false;
                    }
                    field("Lot No."; "Lot No.")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = true;

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            exit(LotTracingMgmt.LookupLotNo("Item No.", "Variant Code", Text));
                        end;

                        trigger OnValidate()
                        begin
                            ValidateField(FieldNo("Lot No."));
                        end;
                    }
                    field("GetUOMDescription()"; GetUOMDescription())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Unit of Measure';
                        Editable = false;
                    }
                    field(Quantity; Quantity)
                    {
                        ApplicationArea = FOODBasic;
                        BlankZero = true;
                        Caption = 'Lot Quantity';
                        DecimalPlaces = 0 : 5;
                        Editable = false;
                        Importance = Promoted;
                    }
                    field("-(Quantity - ""Remaining Quantity"")"; -(Quantity - "Remaining Quantity"))
                    {
                        ApplicationArea = FOODBasic;
                        BlankZero = true;
                        Caption = 'Used Quantity';
                        DecimalPlaces = 0 : 5;
                        Editable = false;
                        Importance = Promoted;
                    }
                    field("Remaining Quantity"; "Remaining Quantity")
                    {
                        ApplicationArea = FOODBasic;
                        BlankZero = true;
                        Caption = 'Remaining Quantity';
                        DecimalPlaces = 0 : 5;
                        Editable = false;
                        Importance = Promoted;
                    }
                }
            }
            part(SourceSubpage; "Lot Tracing Source Subpage")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Source';
            }
            part(DestSubpage; "Lot Tracing Dest. Subpage")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Destination';
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("&Trace")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Trace';
                Image = Trace;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Ctrl+T';

                trigger OnAction()
                begin
                    ExecuteLotTrace;
                    CurrPage.Update(false);
                end;
            }
            action("&Clear")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Clear';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Reset;
                    DeleteAll;
                    ClearLotTrace;
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    begin
        ClearLotTrace;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        CheckLot;
        ClearLotTrace;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        CheckLot;
        ClearLotTrace;
    end;

    trigger OnOpenPage()
    begin
        ExecuteLotTrace;
    end;

    var
        Item: Record Item;
        TraceUOM: Record "Unit of Measure";
        LotInfo: Record "Lot No. Information";
        PosQty: Decimal;
        NegQty: Decimal;
        Text000: Label '%1 - %2';
        Text001: Label 'Trace Lot %1 for Item %2 already exists.';
        LotTracingMgmt: Codeunit "Lot Tracing Management";

    local procedure GetDescription(): Text[100]
    begin
        if Item.Get("Item No.") then begin
            if ("Lot No." <> '') then begin
                LotInfo.Get("Item No.", "Variant Code", "Lot No.");
                exit(LotInfo.Description);
            end;
            exit(Item.Description);
        end;
    end;

    local procedure GetUOMDescription(): Text[100]
    begin
        if Item.Get("Item No.") then begin
            if Item.TraceAltQty() then
                TraceUOM.Get(Item."Alternate Unit of Measure")
            else
                TraceUOM.Get(Item."Base Unit of Measure");
            if (TraceUOM.Description <> '') then
                exit(StrSubstNo(Text000, TraceUOM.Code, TraceUOM.Description));
            exit(TraceUOM.Code);
        end;
    end;

    local procedure ExecuteLotTrace()
    var
        TempLotBuf: Record "Lot Tracing Buffer" temporary;
        TempSourceBuf: Record "Lot Tracing Buffer" temporary;
        TempDestBuf: Record "Lot Tracing Buffer" temporary;
        LotTracingMgmt2: Codeunit "Lot Tracing Management";
        OldRec: Record "Lot Tracing Buffer";
    begin
        LotTracingMgmt2.StartLotTrace(TempLotBuf, TempSourceBuf, TempDestBuf);
        CopyRec(OldRec);
        SetCurrentKey("Item No.", "Variant Code", "Lot No.");
        if FindSet then
            repeat
                LotInfo.Get("Item No.", "Variant Code", "Lot No.");
                LotTracingMgmt2.AddLotToTrace(LotInfo, TempLotBuf, TempSourceBuf, TempDestBuf, PosQty, NegQty);
                Quantity := PosQty;
                "Remaining Quantity" := PosQty + NegQty;
                Modify;
            until (Next = 0);
        Copy(OldRec);
        CurrPage.SourceSubpage.PAGE.SetData(TempSourceBuf);
        CurrPage.DestSubpage.PAGE.SetData(TempDestBuf);
    end;

    local procedure ClearLotTrace()
    var
        TempLotBuf: Record "Lot Tracing Buffer" temporary;
        TempSourceBuf: Record "Lot Tracing Buffer" temporary;
        TempDestBuf: Record "Lot Tracing Buffer" temporary;
        LotTracingMgmt2: Codeunit "Lot Tracing Management";
        OldRec: Record "Lot Tracing Buffer";
    begin
        LotTracingMgmt2.StartLotTrace(TempLotBuf, TempSourceBuf, TempDestBuf);
        CurrPage.SourceSubpage.PAGE.SetData(TempSourceBuf);
        CurrPage.DestSubpage.PAGE.SetData(TempDestBuf);
    end;

    local procedure CheckLot()
    begin
        if FindLot() then
            Error(Text001, "Lot No.", "Item No.");
    end;

    local procedure FindLot() LotFound: Boolean
    var
        OldRec: Record "Lot Tracing Buffer";
    begin
        if ("Item No." <> '') and ("Lot No." <> '') then begin
            CopyRec(OldRec);
            SetCurrentKey("Item No.", "Variant Code", "Lot No.");
            SetRange("Item No.", OldRec."Item No.");
            SetRange("Variant Code", OldRec."Variant Code");
            SetRange("Lot No.", OldRec."Lot No.");
            LotFound := not IsEmpty;
            Copy(OldRec);
        end;
    end;

    local procedure ValidateField(FldNo: Integer)
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        case FldNo of
            FieldNo("Item No."):
                begin
                    Item.Get("Item No.");
                    Item.TestField("Item Tracking Code");
                    ItemTrackingCode.Get(Item."Item Tracking Code");
                    ItemTrackingCode.TestField("Lot Specific Tracking", true);
                    "Variant Code" := '';
                    "Lot No." := '';
                end;
            FieldNo("Variant Code"):
                "Lot No." := '';
            FieldNo("Lot No."):
                CheckLot;
        end;
        Quantity := 0;
        "Remaining Quantity" := 0;
        ClearLotTrace;
    end;

    procedure SetTraceFromLots(var LotInfo: Record "Lot No. Information")
    var
        OldRec: Record "Lot Tracing Buffer";
    begin
        if LotInfo.FindSet then begin
            CopyRecForInsert(OldRec);
            repeat
                AddLotToTrace(LotInfo."Item No.", LotInfo."Variant Code", LotInfo."Lot No.");
            until (LotInfo.Next = 0);
            Copy(OldRec);
        end;
    end;

    procedure SetTraceFromItemLedgEntries(var ItemLedgEntry: Record "Item Ledger Entry")
    var
        OldRec: Record "Lot Tracing Buffer";
    begin
        if ItemLedgEntry.FindSet then begin
            CopyRecForInsert(OldRec);
            repeat
                AddLotToTrace(ItemLedgEntry."Item No.", ItemLedgEntry."Variant Code", ItemLedgEntry."Lot No.");
            until (ItemLedgEntry.Next = 0);
            Copy(OldRec);
        end;
    end;

    procedure SetTraceFromItemTracingBuf(var ItemTracingBuf: Record "Lot Tracing Buffer")
    var
        OldRec: Record "Lot Tracing Buffer";
    begin
        if ItemTracingBuf.FindSet then begin
            CopyRecForInsert(OldRec);
            repeat
                AddLotToTrace(ItemTracingBuf."Item No.", ItemTracingBuf."Variant Code", ItemTracingBuf."Lot No.");
            until (ItemTracingBuf.Next = 0);
            Copy(OldRec);
        end;
    end;

    procedure AddTraceLot(NewItemNo: Code[20]; NewVariantCode: Code[10]; NewLotNo: Code[50])
    var
        OldRec: Record "Lot Tracing Buffer";
    begin
        if (NewItemNo <> '') and (NewLotNo <> '') then begin
            CopyRecForInsert(OldRec);
            AddLotToTrace(NewItemNo, NewVariantCode, NewLotNo);
            Copy(OldRec);
        end;
    end;

    local procedure AddLotToTrace(NewItemNo: Code[20]; NewVariantCode: Code[10]; NewLotNo: Code[50])
    begin
        "Item No." := NewItemNo;
        "Variant Code" := NewVariantCode;
        "Lot No." := NewLotNo;
        if not FindLot() then begin
            "Line No." := "Line No." + 10000;
            Insert;
        end;
    end;

    local procedure CopyRec(var OldRec: Record "Lot Tracing Buffer")
    begin
        OldRec.Copy(Rec);
        Reset;
    end;

    local procedure CopyRecForInsert(var OldRec: Record "Lot Tracing Buffer")
    begin
        CopyRec(OldRec);
        if not FindLast then
            "Line No." := 0;
    end;
}

