page 37002089 "Lot Tracing"
{
    // PRW16.00.05
    // P8000979, Columbus IT, Don Bresee, 09 SEP 11
    //   Add Lot Tracing to Enhanced Lot Tracking granule
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
    Caption = 'Lot Tracing';
    PageType = Card;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group("Trace Lot Info.")
            {
                Caption = 'Trace Lot Info.';
                group(Control37002005)
                {
                    ShowCaption = false;
                    field(CurrItemNo; CurrItemNo)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Item No.';
                        TableRelation = Item WHERE("Item Tracking Code" = FILTER(<> ''));

                        trigger OnValidate()
                        var
                            Item: Record Item;
                        begin
                            SetNewItemNo(CurrItemNo);
                            // P800155629
                            if CurrVariantCode = '' then
                                VariantCodeMandatory := Item.IsVariantMandatory(true, CurrItemNo);
                            // P800155629
                            ExecuteLotTrace;
                        end;
                    }
                    field(CurrVariantCode; CurrVariantCode)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Variant Code';
                        ShowMandatory = VariantCodeMandatory;

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            exit(LotTracingMgmt.LookupVariantCode(CurrItemNo, Text));
                        end;

                        trigger OnValidate()
                        var
                            Item: Record Item;
                        begin
                            SetNewVariantCode(CurrVariantCode);
                            // P800155629
                            if CurrVariantCode = '' then
                                VariantCodeMandatory := Item.IsVariantMandatory(true, CurrItemNo);
                            // P800155629
                            ExecuteLotTrace;
                        end;
                    }
                    field(CurrLotNo; CurrLotNo)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Lot No.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            exit(LotTracingMgmt.LookupLotNo(CurrItemNo, CurrVariantCode, Text));
                        end;

                        trigger OnValidate()
                        begin
                            SetNewLotNo(CurrLotNo);
                            ExecuteLotTrace;
                        end;
                    }
                    field("GetUOMDescription()"; GetUOMDescription())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Trace UOM Code';
                        Editable = false;
                    }
                }
                group(Control37002007)
                {
                    ShowCaption = false;
                    field("GetDescription()"; GetDescription())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Description';
                        Editable = false;
                    }
                    field(PosQty; PosQty)
                    {
                        ApplicationArea = FOODBasic;
                        BlankZero = true;
                        Caption = 'Lot Quantity';
                        DecimalPlaces = 0 : 5;
                        Editable = false;
                        Importance = Promoted;
                    }
                    field(NegQty; NegQty)
                    {
                        ApplicationArea = FOODBasic;
                        BlankZero = true;
                        Caption = 'Used Quantity';
                        DecimalPlaces = 0 : 5;
                        Editable = false;
                        Importance = Promoted;
                    }
                    field("PosQty + NegQty"; PosQty + NegQty)
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
    }

    trigger OnOpenPage()
    begin
        ExecuteLotTrace;
    end;

    var
        CurrItemNo: Code[20];
        CurrVariantCode: Code[10];
        CurrLotNo: Code[50];
        Item: Record Item;
        UseAltQty: Boolean;
        TraceUOM: Record "Unit of Measure";
        ItemVariant: Record "Item Variant";
        LotInfo: Record "Lot No. Information";
        PosQty: Decimal;
        NegQty: Decimal;
        LotTracingMgmt: Codeunit "Lot Tracing Management";
        VariantCodeMandatory: Boolean;

    procedure SetTraceLot(NewItemNo: Code[20]; NewVariantCode: Code[10]; NewLotNo: Code[50])
    begin
        SetNewItemNo(NewItemNo);
        SetNewVariantCode(NewVariantCode);
        SetNewLotNo(NewLotNo);
    end;

    local procedure GetDescription(): Text[100]
    begin
        if (LotInfo."Lot No." <> '') then
            exit(LotInfo.Description);
        exit(Item.Description);
    end;

    local procedure GetUOMDescription(): Text[100]
    begin
        if (TraceUOM.Code <> '') then begin
            if (TraceUOM.Description <> '') then
                exit(StrSubstNo('%1 - %2', TraceUOM.Code, TraceUOM.Description));
            exit(TraceUOM.Code);
        end;
    end;

    local procedure SetNewItemNo(NewItemNo: Code[20])
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        CurrItemNo := NewItemNo;
        if (CurrItemNo = '') then begin
            Clear(Item);
            Clear(TraceUOM);
        end else begin
            Item.Get(CurrItemNo);
            Item.TestField("Item Tracking Code");
            ItemTrackingCode.Get(Item."Item Tracking Code");
            ItemTrackingCode.TestField("Lot Specific Tracking", true);
            if Item.TraceAltQty() then
                TraceUOM.Get(Item."Alternate Unit of Measure")
            else
                TraceUOM.Get(Item."Base Unit of Measure");
        end;
        SetNewVariantCode('');
    end;

    local procedure SetNewVariantCode(NewVariantCode: Code[10])
    begin
        CurrVariantCode := NewVariantCode;
        if (CurrVariantCode = '') then
            Clear(ItemVariant)
        else
            ItemVariant.Get(CurrItemNo, CurrVariantCode);
        SetNewLotNo('');
    end;

    local procedure SetNewLotNo(NewLotNo: Code[50])
    begin
        CurrLotNo := NewLotNo;
        if (CurrLotNo = '') then
            Clear(LotInfo)
        else
            LotInfo.Get(CurrItemNo, CurrVariantCode, CurrLotNo);
    end;

    local procedure ExecuteLotTrace()
    var
        TempSourceBuf: Record "Lot Tracing Buffer" temporary;
        TempDestBuf: Record "Lot Tracing Buffer" temporary;
        LotTracingMgmt2: Codeunit "Lot Tracing Management";
    begin
        PosQty := 0;
        NegQty := 0;
        if LotInfo.Get(CurrItemNo, CurrVariantCode, CurrLotNo) then
            LotTracingMgmt2.GetLotTrace(LotInfo, TempSourceBuf, TempDestBuf, PosQty, NegQty);
        CurrPage.SourceSubpage.PAGE.SetData(TempSourceBuf);
        CurrPage.DestSubpage.PAGE.SetData(TempDestBuf);
        CurrPage.Update(false);
    end;
}

