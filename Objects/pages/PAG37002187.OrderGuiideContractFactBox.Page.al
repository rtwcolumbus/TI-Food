page 37002187 "Order Guiide Contract FactBox"
{
    // PRW114.00
    // P80072447, To-increase, Gangabhushan, 24 APR 19
    //   Dev. Pricing information on the Sales Order Guide

    Caption = 'Contract Details';
    PageType = CardPart;
    SourceTable = "Order Guide FactBox Data";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            field("Contract No."; "Contract No.")
            {
                ApplicationArea = FOODBasic;
            }
            field("Contract Limit"; "Contract Limit")
            {
                ApplicationArea = FOODBasic;
                BlankZero = true;
                Caption = 'Limit';
                DecimalPlaces = 0 : 5;
            }
            field("Contract Limit Unit of Measure"; "Contract Limit Unit of Measure")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Limit Unit of Measure';
            }
            field("Contract Limit Used"; "Contract Limit Used")
            {
                ApplicationArea = FOODBasic;
                BlankZero = true;
                Caption = 'Limit Used';
            }
            field("Contract Line Limit"; "Contract Line Limit")
            {
                ApplicationArea = FOODBasic;
                BlankZero = true;
                Caption = 'Line Limit';
                DecimalPlaces = 0 : 5;
            }
            field("Contract Line Limit UOM"; "Contract Line Limit UOM")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Line Limit UOM';
            }
            field("Contract  Line Limit Used"; "Contract  Line Limit Used")
            {
                ApplicationArea = FOODBasic;
                BlankZero = true;
                Caption = 'Line Limit Used';
            }
        }
    }

    actions
    {
    }

    var
        ContractNo: Code[20];
        ContractLimit: Decimal;
        ContractLimitUOM: Code[10];
        ContractLimitUsed: Decimal;
        ContractLineLimit: Decimal;
        ContractLineLimitUOM: Code[10];
        ContractLineLimitUsed: Decimal;
        OrderGuidefactBoxData: Record "Order Guide FactBox Data" temporary;

    procedure ClearContractFields(ItemNo: Code[20])
    begin
        // P80072447
        SetRange("Item No.", ItemNo);
        SetRange(Type, Type::Contract);
        if FindFirst then
            Delete;
    end;

    procedure ValidateSalesContractNo(pItemNo: Code[20]; pType: Option; pContractNo: Code[20])
    var
        SalesContract: Record "Sales Contract";
        SalesContractLine: Record "Sales Contract Line";
        EntryNo: Integer;
    begin
        // P80072447
        Reset;
        OrderGuidefactBoxData.Copy(Rec, true);
        if (pType <> 0) and (pContractNo = '') then begin
            SetRange("Item No.", pItemNo);
            SetRange(Type, Type::Contract);
            if FindFirst then begin
                Delete;
                exit;
            end else
                exit;
        end;
        SetRange("Item No.", pItemNo);
        SetRange(Type, Type::Contract);
        if not FindFirst then begin
            OrderGuidefactBoxData.Reset;
            if OrderGuidefactBoxData.FindLast then
                EntryNo := OrderGuidefactBoxData."Enry No." + 1
            else
                EntryNo := 1;
            Init;
            "Enry No." := EntryNo;
            "Item No." := pItemNo;
            Type := Type::Contract;
            Insert;
        end;

        SalesContract.Get(pContractNo);
        "Contract No." := pContractNo;
        "Contract Limit" := SalesContract."Contract Limit";
        "Contract Limit Unit of Measure" := SalesContract."Contract Limit Unit of Measure";
        "Contract Limit Used" := SalesContract.CalcLimitUsed;
        if SalesContractLine.Get(pContractNo, Type, pItemNo) then begin
            "Contract  Line Limit Used" := SalesContractLine.CalcLimitUsed;
            "Contract Line Limit" := SalesContractLine."Line Limit";
            "Contract Line Limit UOM" := SalesContractLine."Line Limit Unit of Measure";
        end;
        Modify;
    end;
}

