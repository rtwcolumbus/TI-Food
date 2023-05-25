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
    // 
    // PRW121.0
    // P800155629, To-Increase, Jack Reynolds, 03 NOV 22
    //   Add support for Mandatory Variant

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
                    field("Item No."; Rec."Item No.")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = true;
                        TableRelation = Item WHERE("Item Tracking Code" = FILTER(<> ''));

                        trigger OnValidate()
                        begin
                            ValidateField(Rec.FieldNo("Item No."));
                            // P800155629
                            if Rec."Variant Code" = '' then
                                VariantCodeMandatory := Rec.IsVariantMandatory();
                            // P800155629
                        end;
                    }
                    field("Variant Code"; Rec."Variant Code")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = true;
                        ShowMandatory = VariantCodeMandatory;
                        Visible = false;

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            exit(LotTracingMgmt.LookupVariantCode(Rec."Item No.", Text));
                        end;

                        trigger OnValidate()
                        begin
                            ValidateField(Rec.FieldNo("Variant Code"));
                            // P800155629
                            if Rec."Variant Code" = '' then
                                VariantCodeMandatory := Rec.IsVariantMandatory();
                            // P800155629
                        end;
                    }
                    field("GetDescription()"; GetDescription())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Description';
                        Editable = false;
                    }
                    field("Lot No."; Rec."Lot No.")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = true;

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            exit(LotTracingMgmt.LookupLotNo(Rec."Item No.", Rec."Variant Code", Text));
                        end;

                        trigger OnValidate()
                        begin
                            ValidateField(Rec.FieldNo("Lot No."));
                        end;
                    }
                    field("GetUOMDescription()"; GetUOMDescription())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Unit of Measure';
                        Editable = false;
                    }
                    field(Quantity; Rec.Quantity)
                    {
                        ApplicationArea = FOODBasic;
                        BlankZero = true;
                        Caption = 'Lot Quantity';
                        DecimalPlaces = 0 : 5;
                        Editable = false;
                        Importance = Promoted;
                    }
                    field("-(Quantity - ""Remaining Quantity"")"; -(Rec.Quantity - Rec."Remaining Quantity"))
                    {
                        ApplicationArea = FOODBasic;
                        BlankZero = true;
                        Caption = 'Used Quantity';
                        DecimalPlaces = 0 : 5;
                        Editable = false;
                        Importance = Promoted;
                    }
                    field("Remaining Quantity"; Rec."Remaining Quantity")
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

                trigger OnAction()
                begin
                    Reset;
                    DeleteAll;
                    ClearLotTrace;
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            actionref(Trace_Promoted; "&Trace")
            {
            }
            actionref(Clear_Promoted; "&Clear")
            {
            }
        }
    }

    // P800155629
    trigger OnAfterGetRecord()
    begin
        if Rec."Variant Code" = '' then
            VariantCodeMandatory := Rec.IsVariantMandatory();
    end;

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

    // P800155629
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        VariantCodeMandatory := false;
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
        VariantCodeMandatory: Boolean;

    local procedure GetDescription(): Text[100]
    begin
        if Item.Get(Rec."Item No.") then begin
            if (Rec."Lot No." <> '') then begin
                LotInfo.Get(Rec."Item No.", Rec."Variant Code", Rec."Lot No.");
                exit(LotInfo.Description);
            end;
            exit(Item.Description);
        end;
    end;

    local procedure GetUOMDescription(): Text[100]
    begin
        if Item.Get(Rec."Item No.") then begin
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
        Rec.SetCurrentKey("Item No.", "Variant Code", "Lot No.");
        if FindSet then
            repeat
                LotInfo.Get(Rec."Item No.", Rec."Variant Code", Rec."Lot No.");
                LotTracingMgmt2.AddLotToTrace(LotInfo, TempLotBuf, TempSourceBuf, TempDestBuf, PosQty, NegQty);
                Rec.Quantity := PosQty;
                Rec."Remaining Quantity" := PosQty + NegQty;
                Rec.Modify;
            until (Rec.Next = 0);
        Rec.Copy(OldRec);
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
            Error(Text001, Rec."Lot No.", Rec."Item No.");
    end;

    local procedure FindLot() LotFound: Boolean
    var
        OldRec: Record "Lot Tracing Buffer";
    begin
        if (Rec."Item No." <> '') and (Rec."Lot No." <> '') then begin
            CopyRec(OldRec);
            Rec.SetCurrentKey("Item No.", "Variant Code", "Lot No.");
            Rec.SetRange("Item No.", OldRec."Item No.");
            Rec.SetRange("Variant Code", OldRec."Variant Code");
            Rec.SetRange("Lot No.", OldRec."Lot No.");
            LotFound := not Rec.IsEmpty;
            Rec.Copy(OldRec);
        end;
    end;

    local procedure ValidateField(FldNo: Integer)
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        case FldNo of
            Rec.FieldNo("Item No."):
                begin
                    Item.Get(Rec."Item No.");
                    Item.TestField("Item Tracking Code");
                    ItemTrackingCode.Get(Item."Item Tracking Code");
                    ItemTrackingCode.TestField("Lot Specific Tracking", true);
                    Rec."Variant Code" := '';
                    Rec."Lot No." := '';
                end;
            Rec.FieldNo("Variant Code"):
                Rec."Lot No." := '';
            Rec.FieldNo("Lot No."):
                CheckLot;
        end;
        Rec.Quantity := 0;
        Rec."Remaining Quantity" := 0;
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
            Rec.Copy(OldRec);
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
            Rec.Copy(OldRec);
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
            Rec.Copy(OldRec);
        end;
    end;

    procedure AddTraceLot(NewItemNo: Code[20]; NewVariantCode: Code[10]; NewLotNo: Code[50])
    var
        OldRec: Record "Lot Tracing Buffer";
    begin
        if (NewItemNo <> '') and (NewLotNo <> '') then begin
            CopyRecForInsert(OldRec);
            AddLotToTrace(NewItemNo, NewVariantCode, NewLotNo);
            Rec.Copy(OldRec);
        end;
    end;

    local procedure AddLotToTrace(NewItemNo: Code[20]; NewVariantCode: Code[10]; NewLotNo: Code[50])
    begin
        Rec."Item No." := NewItemNo;
        Rec."Variant Code" := NewVariantCode;
        Rec."Lot No." := NewLotNo;
        if not FindLot() then begin
            Rec."Line No." := Rec."Line No." + 10000;
            Rec.Insert;
        end;
    end;

    local procedure CopyRec(var OldRec: Record "Lot Tracing Buffer")
    begin
        OldRec.Copy(Rec);
        Rec.Reset;
    end;

    local procedure CopyRecForInsert(var OldRec: Record "Lot Tracing Buffer")
    begin
        CopyRec(OldRec);
        if not Rec.FindLast then
            Rec."Line No." := 0;
    end;
}

