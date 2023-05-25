page 37002781 "Convert Whse. Units"
{
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Convert Whse. Units';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    ShowFilter = false;
    SourceTable = "Warehouse Activity Line";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group("Bin/Units")
            {
                group(Control37002001)
                {
                    ShowCaption = false;
                    field(LocationCode; LocationCode)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Location Code';
                        Editable = false;
                    }
                    field(BinCode; BinCode)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Bin Code';
                        Editable = false;
                    }
                }
                group(Control37002012)
                {
                    ShowCaption = false;
                    field(ItemNo; ItemNo)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Item No.';
                        Editable = false;
                    }
                    field(VariantCode; VariantCode)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Variant Code';
                        Editable = false;
                    }
                    field(LotNo; LotNo)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Lot No.';
                        Editable = false;
                    }
                }
                group(Control37002008)
                {
                    ShowCaption = false;
                    field(UnitOfMeasureCode; UnitOfMeasureCode)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Unit of Measure Code';
                        Editable = false;
                    }
                    field(QtyToPick; QtyToPick)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Qty. to Pick';
                        DecimalPlaces = 0 : 5;
                        Editable = false;
                    }
                    field(QtyAvailable; QtyAvailable)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Qty. Available';
                        DecimalPlaces = 0 : 5;
                        Editable = false;
                    }
                    field(MissingQty; MissingQty)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Missing Qty.';
                        DecimalPlaces = 0 : 5;
                        Editable = false;
                    }
                    field(TotalQtyToCreate; TotalQtyToCreate)
                    {
                        ApplicationArea = FOODBasic;
                        BlankZero = true;
                        Caption = 'Qty. to Create';
                        DecimalPlaces = 0 : 5;

                        trigger OnValidate()
                        begin
                            CurrPage.SaveRecord;
                            SetTotalQtyToCreate(TotalQtyToCreate);
                            CurrPage.Update(false);
                        end;
                    }
                }
            }
            group("Units to Convert")
            {
                repeater(Control37002013)
                {
                    ShowCaption = false;
                    field("Unit of Measure Code"; "Unit of Measure Code")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = false;
                    }
                    field(ConvQtyAvailable; ConvQtyAvailable)
                    {
                        ApplicationArea = FOODBasic;
                        BlankZero = true;
                        Caption = 'Qty. Available';
                        DecimalPlaces = 0 : 5;
                        Editable = false;
                    }
                    field(QtyToConvert; QtyToConvert)
                    {
                        ApplicationArea = FOODBasic;
                        BlankZero = true;
                        Caption = 'Qty. to Convert';
                        DecimalPlaces = 0 : 5;
                        MinValue = 0;

                        trigger OnValidate()
                        begin
                            RoundQtyToConvert;
                            SetQtyToConvert(QtyToConvert);
                            UpdateQtysExist;
                            CurrPage.Update;
                        end;
                    }
                    field(QtyToCreate; QtyToCreate)
                    {
                        ApplicationArea = FOODBasic;
                        BlankZero = true;
                        Caption = 'Qty. to Create';
                        DecimalPlaces = 0 : 5;

                        trigger OnValidate()
                        begin
                            RoundQtyToCreate;
                            SetQtyToCreate(QtyToCreate);
                            UpdateQtysExist;
                            CurrPage.Update;
                        end;
                    }
                    field("GetUOMToCreate()"; GetUOMToCreate())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'UOM to Create';
                        Editable = false;
                    }
                    field(Description; Description)
                    {
                        ApplicationArea = FOODBasic;
                        Editable = false;
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Functions)
            {
                Caption = 'Functions';
                action("&Register")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Register';
                    Enabled = QtysExist;
                    Image = RegisterPick;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    begin
                        if not QtysExist then
                            Error(Text001);
                        if Confirm(Text002) then
                            RegisterLines;
                    end;
                }
                action("&Clear Quantities")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Clear Quantities';
                    Enabled = QtysExist;
                    Image = DeleteQtyToHandle;

                    trigger OnAction()
                    begin
                        ClearQtys;
                    end;
                }
                action("&Autofill Quantities")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Autofill Quantities';
                    Image = AutofillQtyToHandle;

                    trigger OnAction()
                    begin
                        SetTotalQtyToCreate(MissingQty);
                    end;
                }
            }
        }
        area(Promoted)
        {
            actionref(Register_Promoted; "&Register")
            {
            }
            actionref(ClearQuantities_Promoted; "&Clear Quantities")
            {
            }
            actionref(AutofillQuantities_Promoted; "&Autofill Quantities")
            {
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ConvQtyAvailable :=
          SetNonNegative(CalcQtyAvailable("Unit of Measure Code", false)) +
          GetTotalQtyToCreate("Unit of Measure Code");
        QtyToConvert := Quantity;
        QtyToCreate := GetQtyToCreate();
        TotalQtyToCreate := GetTotalQtyToCreate(UnitOfMeasureCode);
    end;

    var
        LocationCode: Code[10];
        BinCode: Code[20];
        ItemNo: Code[20];
        VariantCode: Code[10];
        LotNo: Code[50];
        UnitOfMeasureCode: Code[10];
        QtyPerUnitOfMeasure: Decimal;
        QtyToPick: Decimal;
        QtyAvailable: Decimal;
        MissingQty: Decimal;
        ConvQtyAvailable: Decimal;
        QtyToConvert: Decimal;
        TotalQtyToCreate: Decimal;
        QtyToCreate: Decimal;
        TempPlaceLine: Record "Warehouse Activity Line" temporary;
        QtysExist: Boolean;
        Text000: Label 'No other units are available.';
        Text001: Label 'Nothing to register.';
        Text002: Label 'Do you want to register the conversion of units?';
        Text003: Label '%1 %2(s) per %3';
        Text004: Label '%1 %2(s) is %3 %4(s)';
        Text005: Label 'Only %1 units are available.';
        Text006: Label 'No units are available.';

    procedure SetSource(LocationCode2: Code[10]; BinCode2: Code[20]; ItemNo2: Code[20]; VariantCode2: Code[10]; LotNo2: Code[50]; UnitOfMeasureCode2: Code[10]; QtyToPick2: Decimal)
    var
        ItemUOM: Record "Item Unit of Measure";
    begin
        LocationCode := LocationCode2;
        BinCode := BinCode2;
        ItemNo := ItemNo2;
        VariantCode := VariantCode2;
        LotNo := LotNo2;
        UnitOfMeasureCode := UnitOfMeasureCode2;
        QtyToPick := QtyToPick2;

        ItemUOM.Get(ItemNo, UnitOfMeasureCode);
        QtyPerUnitOfMeasure := ItemUOM."Qty. per Unit of Measure";

        LoadData;

        Reset;
        if IsEmpty then
            Error(Text000);
        FindSet;
        UpdateHeaderQtys;
    end;

    local procedure LoadData()
    var
        ItemUOM: Record "Item Unit of Measure";
        UOMToCreate: Code[10];
        LineNo: Integer;
        NumSmallerUnits: Integer;
    begin
        ItemUOM.Get(ItemNo, UnitOfMeasureCode);
        ItemUOM.CalcFields(Type);
        ItemUOM.SetRange(Type, ItemUOM.Type);
        ItemUOM.SetCurrentKey("Item No.", "Qty. per Unit of Measure");
        ItemUOM.SetRange("Item No.", ItemNo);
        ItemUOM.SetFilter("Qty. per Unit of Measure", '<%1', QtyPerUnitOfMeasure);
        NumSmallerUnits := ItemUOM.Count;
        LineNo := NumSmallerUnits;
        UOMToCreate := UnitOfMeasureCode;
        while (ItemUOM.Next(-1) <> 0) do begin
            CreateTempLines(LineNo, ItemUOM.Code, UOMToCreate);
            UOMToCreate := ItemUOM.Code;
            LineNo := LineNo - 1;
        end;
        LineNo := NumSmallerUnits;
        UOMToCreate := UnitOfMeasureCode;
        ItemUOM.Get(ItemNo, UnitOfMeasureCode);
        ItemUOM.SetRange("Qty. per Unit of Measure");
        while (ItemUOM.Next <> 0) do begin
            LineNo := LineNo + 1;
            CreateTempLines(LineNo, ItemUOM.Code, UOMToCreate);
            UOMToCreate := ItemUOM.Code;
        end;
    end;

    local procedure CreateTempLines(var LineNo: Integer; TakeUOMCode: Code[10]; PlaceUOMCode: Code[10])
    var
        ItemUOM: Record "Item Unit of Measure";
    begin
        Create1TempLine(Rec, LineNo, true, TakeUOMCode);
        Create1TempLine(TempPlaceLine, LineNo, false, PlaceUOMCode);

        ItemUOM.Get(ItemNo, TakeUOMCode);
        "Qty. Outstanding" := ItemUOM."Equivalent UOM Qty.";
        "Qty. Outstanding (Base)" := ItemUOM."Base Quantity";
        ItemUOM.Get(ItemNo, PlaceUOMCode);
        "Qty. Outstanding" := "Qty. Outstanding" * ItemUOM."Base Quantity";
        "Qty. Outstanding (Base)" := "Qty. Outstanding (Base)" * ItemUOM."Equivalent UOM Qty.";
        if IsAnInteger("Qty. Outstanding" / "Qty. Outstanding (Base)") then begin
            "Qty. Outstanding" := Round("Qty. Outstanding" / "Qty. Outstanding (Base)", 1);
            "Qty. Outstanding (Base)" := 1;
            Description :=
              StrSubstNo(Text003,
                "Qty. Outstanding", ItemUOM.GetUOMDescription(TakeUOMCode), ItemUOM.GetUOMDescription(PlaceUOMCode));
        end else
            if IsAnInteger("Qty. Outstanding (Base)" / "Qty. Outstanding") then begin
                "Qty. Outstanding (Base)" := Round("Qty. Outstanding (Base)" / "Qty. Outstanding", 1);
                "Qty. Outstanding" := 1;
                Description :=
                  StrSubstNo(Text003,
                    "Qty. Outstanding (Base)", ItemUOM.GetUOMDescription(PlaceUOMCode), ItemUOM.GetUOMDescription(TakeUOMCode));
            end else
                Description :=
                  StrSubstNo(Text004,
                    "Qty. Outstanding", ItemUOM.GetUOMDescription(TakeUOMCode),
                    "Qty. Outstanding (Base)", ItemUOM.GetUOMDescription(PlaceUOMCode));
        Modify;
    end;

    local procedure Create1TempLine(var TempWhseActivLine: Record "Warehouse Activity Line" temporary; LineNo: Integer; TakeAction: Boolean; UOMCode: Code[10])
    var
        ItemUOM: Record "Item Unit of Measure";
    begin
        TempWhseActivLine.Init;
        TempWhseActivLine."Line No." := LineNo;
        TempWhseActivLine."Item No." := ItemNo;
        TempWhseActivLine."Bin Code" := BinCode;
        TempWhseActivLine."Location Code" := LocationCode;
        if TakeAction then
            TempWhseActivLine."Action Type" := TempWhseActivLine."Action Type"::Take
        else
            TempWhseActivLine."Action Type" := TempWhseActivLine."Action Type"::Place;
        TempWhseActivLine."Variant Code" := VariantCode;
        TempWhseActivLine."Unit of Measure Code" := UOMCode;
        TempWhseActivLine."Activity Type" := TempWhseActivLine."Activity Type"::Pick;
        TempWhseActivLine."Lot No." := LotNo;
        ItemUOM.Get(ItemNo, UOMCode);
        TempWhseActivLine."Qty. per Unit of Measure" := ItemUOM."Qty. per Unit of Measure";
        TempWhseActivLine.Insert;
    end;

    local procedure CalcQtyAvailable(UOMCode: Code[10]; ContainersOnPickOnly: Boolean): Decimal
    var
        BinContent: Record "Bin Content";
    begin
        if BinContent.Get(LocationCode, BinCode, ItemNo, VariantCode, UOMCode) then begin
            BinContent.SetRange("Lot No. Filter", LotNo);
            if ContainersOnPickOnly then begin
                BinContent.CalcFields(Quantity, "Neg. Adjmt. Qty.", "Allocated Container Qty.");
                exit(BinContent.Quantity - (BinContent."Allocated Container Qty." + BinContent."Neg. Adjmt. Qty."));
            end;
            BinContent.CalcFields(Quantity, "Neg. Adjmt. Qty.", "Pick Qty.");
            exit(BinContent.Quantity - (BinContent."Pick Qty." + BinContent."Neg. Adjmt. Qty."));
        end;
    end;

    local procedure ConvertQty(Qty: Decimal; UOMCode: Code[10]; NewUOMCode: Code[10]) NewQty: Decimal
    var
        ItemUOM: Record "Item Unit of Measure";
    begin
        ItemUOM.Get(ItemNo, UOMCode);
        NewQty := Qty * ItemUOM."Qty. per Unit of Measure";
        ItemUOM.Get(ItemNo, NewUOMCode);
        ItemUOM.TestField("Qty. per Unit of Measure");
        NewQty := Round(NewQty / ItemUOM."Qty. per Unit of Measure", 0.00001);
    end;

    local procedure IsAnInteger(Num: Decimal): Boolean
    begin
        exit(Abs(Num - Round(Num, 1)) < 0.00001);
    end;

    local procedure RoundQtyToConvert()
    begin
        TempPlaceLine.Get("Activity Type", "No.", "Line No.");
        QtyToConvert := RoundUOMQty(QtyToConvert, "Unit of Measure Code", '>');
        QtyToCreate := QtyToConvert * "Qty. per Unit of Measure" / TempPlaceLine."Qty. per Unit of Measure";
        QtyToCreate := RoundUOMQty(QtyToCreate, TempPlaceLine."Unit of Measure Code", '>');
        QtyToConvert := ConvertQty(QtyToCreate, TempPlaceLine."Unit of Measure Code", "Unit of Measure Code");
        ValidateQtyToConvert;
    end;

    local procedure RoundQtyToCreate()
    begin
        TempPlaceLine.Get("Activity Type", "No.", "Line No.");
        QtyToCreate := RoundUOMQty(QtyToCreate, TempPlaceLine."Unit of Measure Code", '>');
        QtyToConvert := QtyToCreate * TempPlaceLine."Qty. per Unit of Measure" / "Qty. per Unit of Measure";
        QtyToConvert := RoundUOMQty(QtyToConvert, "Unit of Measure Code", '>');
        QtyToCreate := ConvertQty(QtyToConvert, "Unit of Measure Code", TempPlaceLine."Unit of Measure Code");
        ValidateQtyToConvert;
    end;

    local procedure ValidateQtyToConvert()
    begin
        if (QtyToConvert > ConvQtyAvailable) then begin
            if (ConvQtyAvailable > 0) then
                Error(Text005, ConvQtyAvailable);
            Error(Text006);
        end;
    end;

    local procedure SetQtyToConvert(Qty: Decimal)
    begin
        Quantity := Qty;
        TempPlaceLine.Get("Activity Type", "No.", "Line No.");
        TempPlaceLine.Quantity :=
          ConvertQty(Qty, "Unit of Measure Code", TempPlaceLine."Unit of Measure Code");
        TempPlaceLine.Modify;
    end;

    local procedure SetQtyToCreate(Qty: Decimal)
    begin
        TempPlaceLine.Get("Activity Type", "No.", "Line No.");
        TempPlaceLine.Quantity := Qty;
        TempPlaceLine.Modify;
        Quantity := ConvertQty(Qty, TempPlaceLine."Unit of Measure Code", "Unit of Measure Code");
    end;

    local procedure GetTotalQtyToCreate(UOMCode: Code[10]): Decimal
    begin
        TempPlaceLine.Reset;
        TempPlaceLine.SetCurrentKey(
          "Item No.", "Bin Code", "Location Code", "Action Type", "Variant Code",
          "Unit of Measure Code", "Breakbulk No.", "Activity Type", "Lot No.", "Serial No.");
        TempPlaceLine.SetRange("Item No.", ItemNo);
        TempPlaceLine.SetRange("Bin Code", BinCode);
        TempPlaceLine.SetRange("Location Code", LocationCode);
        TempPlaceLine.SetRange("Action Type", TempPlaceLine."Action Type"::Place);
        TempPlaceLine.SetRange("Variant Code", VariantCode);
        TempPlaceLine.SetRange("Unit of Measure Code", UOMCode);
        TempPlaceLine.SetRange("Activity Type", TempPlaceLine."Activity Type"::Pick);
        TempPlaceLine.SetRange("Lot No.", LotNo);
        TempPlaceLine.CalcSums(Quantity);
        exit(TempPlaceLine.Quantity);
    end;

    local procedure GetQtyToCreate(): Decimal
    begin
        TempPlaceLine.Get("Activity Type", "No.", "Line No.");
        exit(TempPlaceLine.Quantity);
    end;

    local procedure GetUOMToCreate(): Code[10]
    begin
        TempPlaceLine.Get("Activity Type", "No.", "Line No.");
        exit(TempPlaceLine."Unit of Measure Code");
    end;

    local procedure RegisterLines()
    var
        P800WhseActCreate: Codeunit "Process 800 Create Whse. Act.";
    begin
        Reset;
        FindSet;
        repeat
            "Qty. to Handle" := GetTotalQtyToCreate("Unit of Measure Code") - Quantity;
            Modify;
        until (Next = 0);
        SetFilter("Qty. to Handle", '<0');
        if FindSet then
            repeat
                P800WhseActCreate.AddToSpecification(
                  LocationCode, BinCode, '', ItemNo, VariantCode, "Unit of Measure Code", LotNo, '', -"Qty. to Handle");
            until (Next = 0);
        TotalQtyToCreate := GetTotalQtyToCreate(UnitOfMeasureCode);
        if (TotalQtyToCreate > 0) then
            P800WhseActCreate.AddToSpecification(
              LocationCode, '', BinCode, ItemNo, VariantCode, UnitOfMeasureCode, LotNo, '', TotalQtyToCreate);
        SetFilter("Qty. to Handle", '>0');
        if FindSet then
            repeat
                P800WhseActCreate.AddToSpecification(
                  LocationCode, '', BinCode, ItemNo, VariantCode, "Unit of Measure Code", LotNo, '', "Qty. to Handle");
            until (Next = 0);
        P800WhseActCreate.RegisterUOMConvFromSpec;
        Commit;
        ClearQtys;
    end;

    local procedure UpdateQtysExist()
    begin
        TempPlaceLine.Reset;
        TempPlaceLine.SetFilter(Quantity, '<>0');
        QtysExist := not TempPlaceLine.IsEmpty;
    end;

    local procedure UpdateHeaderQtys()
    begin
        QtyAvailable := SetNonNegative(CalcQtyAvailable(UnitOfMeasureCode, true));
        MissingQty := SetNonNegative(QtyToPick - QtyAvailable);
    end;

    local procedure ClearQtys()
    begin
        Reset;
        FindSet;
        repeat
            Quantity := 0;
            Modify;
        until (Next = 0);
        TempPlaceLine.Reset;
        TempPlaceLine.FindSet;
        repeat
            TempPlaceLine.Quantity := 0;
            TempPlaceLine.Modify;
        until (TempPlaceLine.Next = 0);
        UpdateHeaderQtys;
        UpdateQtysExist;
        FindSet;
    end;

    local procedure SetTotalQtyToCreate(TotalQty: Decimal)
    begin
        ClearQtys;
        TotalQty := RoundUOMQty(TotalQty, UnitOfMeasureCode, '>');
        AllocateUnits(TotalQty, 1);
        TotalQtyToCreate := GetTotalQtyToCreate(UnitOfMeasureCode);
        if (TotalQty > TotalQtyToCreate) then
            AllocateUnits(TotalQty - TotalQtyToCreate, -1);
        UpdateHeaderQtys;
        UpdateQtysExist;
        Reset;
        FindSet;
    end;

    local procedure AllocateUnits(TotalQty: Decimal; Direction: Integer)
    var
        UnitsFound: Boolean;
        NewQty: Decimal;
    begin
        if (TotalQty > 0) then begin
            Reset;
            if (Direction > 0) then begin
                SetFilter("Qty. per Unit of Measure", '>%1', QtyPerUnitOfMeasure);
                UnitsFound := FindSet;
            end else begin
                SetFilter("Qty. per Unit of Measure", '<%1', QtyPerUnitOfMeasure);
                UnitsFound := FindLast;
            end;
            if UnitsFound then begin
                repeat
                    SetQtyToCreate(TotalQty);
                    "Qty. Outstanding" := SetNonNegative(CalcQtyAvailable("Unit of Measure Code", false));
                    TotalQty := SetNonNegative(Quantity - "Qty. Outstanding");
                    SetQtyToConvert(RoundUOMQty(Quantity, "Unit of Measure Code", '>'));
                    Modify;
                until (Next(Direction) = 0);
                repeat
                    NewQty := "Qty. Outstanding" + GetTotalQtyToCreate("Unit of Measure Code");
                    if (Quantity > NewQty) then begin
                        SetQtyToConvert(RoundUOMQty(NewQty, "Unit of Measure Code", '<'));
                        Modify;
                    end;
                until (Next(-Direction) = 0);
                if (Direction < 0) then begin
                    NewQty := GetQtyToCreate();
                    repeat
                        SetQtyToCreate(RoundUOMQty(NewQty, GetUOMToCreate(), '<'));
                        NewQty := SetNonNegative(Quantity - "Qty. Outstanding");
                        Modify;
                    until (Next(Direction) = 0);
                end;
            end;
        end;
    end;

    local procedure SetNonNegative(Qty: Decimal): Decimal
    begin
        if (Qty > 0) then
            exit(Qty);
    end;

    local procedure RoundUOMQty(Qty: Decimal; UOMCode: Code[10]; Direction: Text): Decimal
    var
        ItemUOM: Record "Item Unit of Measure";
    begin
        ItemUOM.Get(ItemNo, UOMCode);
        if (ItemUOM."Rounding Precision" = 0) then
            ItemUOM."Rounding Precision" := 0.00001;
        exit(Round(Qty, ItemUOM."Rounding Precision", Direction));
    end;
}

