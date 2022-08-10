codeunit 37002005 "Process 800 UOM Functions"
{
    // PR3.60.02
    //   Modify ItemUOMLookup to be called from forms rather than table
    // 
    // PR3.61
    //   Add functions
    //    ItemWeight
    //    ItemTareWeight
    //    DefaultUOM
    // 
    // PR3.70
    //   Add function
    //     ItemVolume
    // 
    // PR3.70.01
    //   Modify ItemWeight and ItemVolume to return zero if no base unit of measure
    // 
    // PRW16.00.01
    // P8000720, VerticalSoft, Jack Reynolds, 10 AUG 09
    //   Fix problem with ModifyItemUOM
    // 
    // PRW16.00.06
    // P8001093, Columbus IT, Jack Reynolds, 04 SEP 12
    //   Fix problem changing specific gravity with change to Item UOM
    // 
    // PRW17.10.02
    // P8001273, Columbus IT, Jack Reynolds, 29 JAN 14
    //   Fix problem with Item UOM lookup
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.01
    // P80060030, To Increase, Jack Reynolds, 11 JUN 18
    //   Fix problem with DefaultUOM


    trigger OnRun()
    begin
    end;

    var
        UnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        UnapprItemUnitOfMeasure: Record "Unappr. Item Unit of Measure";

    procedure AdjustItemUOM(var Rec: Record Item)
    var
        UOM: Record "Unit of Measure";
        ItemUOM: Record "Item Unit of Measure";
        ItemUOM2: Record "Item Unit of Measure";
        UOMMgt: Codeunit "Unit of Measure Management";
    begin
        // AdjustItemUOM
        with Rec do begin
            if "Specific Gravity" = 0 then exit;

            if "Base Unit of Measure" <> '' then begin
                UOM.Get("Base Unit of Measure");
                if not (UOM.Type in [2, 3]) then
                    UOM.Type := UOM.Type::Volume; // reference will be unit of volume
            end;

            ItemUOM.SetRange("Item No.", "No.");
            ItemUOM.SetRange(Type, UOM.Type);
            if not ItemUOM.Find('-') then exit; // Find reference unit

            ItemUOM2.SetRange("Item No.", "No.");
            if UOM.Type = UOM.Type::Volume then
                ItemUOM2.SetRange(Type, UOM.Type::Weight)
            else
                ItemUOM2.SetRange(Type, UOM.Type::Volume);
            if ItemUOM2.Find('-') then
                repeat
                    ItemUOM2.Validate("Qty. per Unit of Measure",
                      ConvertUOMWithSpecGravity(ItemUOM."Qty. per Unit of Measure",
                      ItemUOM.Code, ItemUOM2.Code, "Specific Gravity"));
                    ItemUOM2.Modify;
                until ItemUOM2.Next = 0;
        end;
    end;

    procedure GetConversionFromTo(ItemNo: Code[20]; FromUOM: Code[10]; ToUOM: Code[10]) factor: Decimal
    begin
        // GetConversionFromTo
        ItemUnitOfMeasure.Get(ItemNo, FromUOM);
        factor := ItemUnitOfMeasure."Qty. per Unit of Measure";
        ItemUnitOfMeasure.Get(ItemNo, ToUOM);
        factor := factor / ItemUnitOfMeasure."Qty. per Unit of Measure";
    end;

    procedure GetConversionToMetricBase(ItemNo: Code[20]; UOM: Code[10]; BaseType: Option ,Length,Weight,Volume) factor: Decimal
    var
        InvSetup: Record "Inventory Setup";
        MeasureSystem: Record "Measuring System";
        ItemUOM: Record "Item Unit of Measure";
    begin
        // GetConversionToMetricBase
        if not UnitOfMeasure.Get(UOM) then exit;
        // UOM is of same base type then all we need is in the measuring system table
        if UnitOfMeasure.Type = BaseType then begin
            InvSetup.Get;
            if InvSetup."Measuring System" = InvSetup."Measuring System"::Metric then
                factor := UnitOfMeasure."Base per Unit of Measure"
            else begin
                MeasureSystem.Get(MeasureSystem."Measuring System"::Conventional, UnitOfMeasure.Type);
                factor := UnitOfMeasure."Base per Unit of Measure" * MeasureSystem."Conversion to Other";
            end;
            exit;
        end;

        // Get conversion to item base unit, from item base unit to another unit of base type, and from
        // that to metric base
        if not ItemUOM.Get(ItemNo, UOM) then exit;
        factor := ItemUOM."Qty. per Unit of Measure";
        ItemUOM.SetRange("Item No.", ItemNo);
        ItemUOM.SetRange(Type, BaseType);
        if not ItemUOM.Find('-') then
            factor := 0
        else begin
            factor := factor * GetConversionToMetricBase('', ItemUOM.Code, BaseType) / ItemUOM."Qty. per Unit of Measure";
        end;
    end;

    procedure GetQtyPerUnitOfMeasureUnapp(UnapprItem: Record "Unapproved Item"; UnitOfMeasureCode: Code[10]): Decimal
    begin
        // GetQtyPerUnitOfMeasureUnapp
        UnapprItem.TestField("No.");
        if UnitOfMeasureCode in [UnapprItem."Base Unit of Measure", ''] then
            exit(1);
        if (UnapprItem."No." <> UnapprItemUnitOfMeasure."Unapproved Item No.") or
           (UnitOfMeasureCode <> UnapprItemUnitOfMeasure.Code)
        then
            UnapprItemUnitOfMeasure.Get(UnapprItem."No.", UnitOfMeasureCode);
        UnapprItemUnitOfMeasure.TestField("Qty. per Unit of Measure");
        exit(UnapprItemUnitOfMeasure."Qty. per Unit of Measure");
    end;

    procedure GetConversionFromToUnapp(UnapprItemNo: Code[20]; FromUOM: Code[10]; ToUOM: Code[10]) factor: Decimal
    begin
        // GetConversionFromToUnapp
        if not UnapprItemUnitOfMeasure.Get(UnapprItemNo, FromUOM) then;
        factor := UnapprItemUnitOfMeasure."Qty. per Unit of Measure";
        UnapprItemUnitOfMeasure.Get(UnapprItemNo, ToUOM);
        factor := factor / UnapprItemUnitOfMeasure."Qty. per Unit of Measure";
    end;

    procedure GetConversionToMetrciBaseUnapp(UnapprItemNo: Code[20]; UOM: Code[10]; BaseType: Option ,Length,Weight,Volume) factor: Decimal
    var
        InvSetup: Record "Inventory Setup";
        MeasureSystem: Record "Measuring System";
        UnapprItemUOM: Record "Unappr. Item Unit of Measure";
    begin
        // GetConversionToMetrciBaseUnapp
        if not UnitOfMeasure.Get(UOM) then exit;
        // UOM is of same base type then all we need is in the measuring system table
        if UnitOfMeasure.Type = BaseType then begin
            InvSetup.Get;
            if InvSetup."Measuring System" = InvSetup."Measuring System"::Metric then
                factor := UnitOfMeasure."Base per Unit of Measure"
            else begin
                MeasureSystem.Get(MeasureSystem."Measuring System"::Conventional, UnitOfMeasure.Type);
                factor := UnitOfMeasure."Base per Unit of Measure" * MeasureSystem."Conversion to Other";
            end;
            exit;
        end;

        // Get conversion to item base unit, from item base unit to another unit of base type, and from
        // that to metric base
        if not UnapprItemUOM.Get(UnapprItemNo, UOM) then exit;
        factor := UnapprItemUOM."Qty. per Unit of Measure";
        UnapprItemUOM.SetRange("Unapproved Item No.", UnapprItemNo);
        UnapprItemUOM.SetRange(Type, BaseType);
        if not UnapprItemUOM.Find('-') then
            factor := 0
        else begin
            factor := factor * GetConversionToMetricBase('', UnapprItemUOM.Code, BaseType) / UnapprItemUOM."Qty. per Unit of Measure";
        end;
    end;

    procedure UOMtoMetricBase(UOMCode: Code[10]): Decimal
    var
        InvSetup: Record "Inventory Setup";
        MeasureSystem: Record "Measuring System";
    begin
        // UOMtoMetricBase
        UnitOfMeasure.Get(UOMCode);
        InvSetup.Get;
        if InvSetup."Measuring System" = InvSetup."Measuring System"::Metric then
            exit(UnitOfMeasure."Base per Unit of Measure")
        else begin
            MeasureSystem.Get(MeasureSystem."Measuring System"::Conventional, UnitOfMeasure.Type);
            exit(UnitOfMeasure."Base per Unit of Measure" * MeasureSystem."Conversion to Other");
        end;
    end;

    procedure ConvertUOM(Quantity: Decimal; FromUOM: Code[20]; ToUOM: Code[20]): Decimal
    var
        InvSetup: Record "Inventory Setup";
        MeasureSystem: Record "Measuring System";
        type: Integer;
        factor: Decimal;
    begin
        // ConvertUOM
        InvSetup.Get;

        case FromUOM of
            'METRIC BASE':
                begin
                    type := 0;
                    if InvSetup."Measuring System" = InvSetup."Measuring System"::Metric then
                        factor := 1
                end;

            'CONVENTIONAL BASE':
                begin
                    type := 0;
                    if InvSetup."Measuring System" = InvSetup."Measuring System"::Conventional then
                        factor := 1
                end;

            else begin
                    UnitOfMeasure.Get(FromUOM);
                    if UnitOfMeasure.Type = 0 then
                        exit(0);
                    type := UnitOfMeasure.Type;
                    factor := UnitOfMeasure."Base per Unit of Measure";
                end;
        end;

        case ToUOM of
            'METRIC BASE':
                begin
                    if type = 0 then
                        exit(0);
                    if InvSetup."Measuring System" = InvSetup."Measuring System"::Conventional then begin
                        MeasureSystem.Get(InvSetup."Measuring System", type);
                        factor := factor * MeasureSystem."Conversion to Other";
                    end
                end;

            'CONVENTIONAL BASE':
                begin
                    if type = 0 then
                        exit(0);
                    if InvSetup."Measuring System" = InvSetup."Measuring System"::Metric then begin
                        MeasureSystem.Get(InvSetup."Measuring System", type);
                        factor := factor * MeasureSystem."Conversion to Other";
                    end
                end;

            else begin
                    UnitOfMeasure.Get(ToUOM);
                    if ((UnitOfMeasure.Type = 0) and (type = 0)) or
                      ((UnitOfMeasure.Type <> type) and (type <> 0))
                    then
                        exit(0);
                    if type = 0 then begin
                        if factor = 1 then
                            factor := 1 / UnitOfMeasure."Base per Unit of Measure"
                        else begin
                            MeasureSystem.Get(InvSetup."Measuring System", UnitOfMeasure.Type);
                            factor := 1 / (MeasureSystem."Conversion to Other" * UnitOfMeasure."Base per Unit of Measure");
                        end;
                    end else
                        factor := factor / UnitOfMeasure."Base per Unit of Measure";
                end;
        end;

        exit(Quantity * factor);
    end;

    procedure ConvertUOMWithSpecGravity(Quantity: Decimal; FromUOM: Code[10]; ToUOM: Code[10]; SpecGravity: Decimal): Decimal
    var
        UOM: array[2] of Record "Unit of Measure";
        Factor: Decimal;
    begin
        // ConvertUOMWithSpecGravity
        UOM[1].Get(ToUOM);
        UOM[2].Get(FromUOM);
        if UOM[1].Type = UOM[1].Type::Volume then
            Factor := 1000 * SpecGravity
        else
            Factor := 0.001 / SpecGravity;

        exit(Quantity * Factor * UOMtoMetricBase(UOM[1].Code) / UOMtoMetricBase(UOM[2].Code))
    end;

    procedure CalcSpecGravity(no: Code[20]; var SpecGravity: Decimal): Boolean
    begin
        // CalcSpecGravity
        ItemUnitOfMeasure.Reset;
        ItemUnitOfMeasure.SetRange("Item No.", no);
        ItemUnitOfMeasure.SetRange(Type, ItemUnitOfMeasure.Type::Weight);
        if ItemUnitOfMeasure.Find('-') then begin
            SpecGravity := 0.001 * UOMtoMetricBase(ItemUnitOfMeasure.Code) / ItemUnitOfMeasure."Qty. per Unit of Measure";
            ItemUnitOfMeasure.SetRange(Type, ItemUnitOfMeasure.Type::Volume);
            if ItemUnitOfMeasure.Find('-') then begin
                SpecGravity := SpecGravity * ItemUnitOfMeasure."Qty. per Unit of Measure" / UOMtoMetricBase(ItemUnitOfMeasure.Code);
                exit(true);
            end else
                exit(false);
        end else
            exit(false);
    end;

    procedure ChangeMeasuringSystem(OldSys: Integer)
    var
        UOM: Record "Unit of Measure";
        MeasuringSystem: Record "Measuring System";
        Factor: array[3] of Decimal;
        i: Integer;
    begin
        // ChangeMeasuringSystem
        for i := 1 to 3 do begin
            MeasuringSystem.Get(OldSys, i);
            Factor[i] := MeasuringSystem."Conversion to Other";
        end;
        UOM.SetRange(Type, 1, 3);
        if UOM.Find('-') then begin
            repeat
                UOM."Base per Unit of Measure" := UOM."Base per Unit of Measure" * Factor[UOM.Type];
                UOM.Modify;
            until UOM.Next = 0;
        end;
    end;

    procedure ItemUOMLookup(var Text: Text[1024]; var rec: Record Item; FldNo: Integer) res: Boolean
    var
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";
        ItemUOMForm: Page "Item Units of Measure";
    begin
        // ItemUOLookup
        // PR3.60.02 Begin
        ItemUOM.SetRange("Item No.", rec."No.");
        ItemUOM.FilterGroup(4); // P8001273
        case FldNo of
            rec.FieldNo("Weight UOM"):
                ItemUOM.SetRange(Type, ItemUOM.Type::Weight);
            rec.FieldNo("Volume UOM"):
                ItemUOM.SetRange(Type, ItemUOM.Type::Volume);
            rec.FieldNo("Alternate Unit of Measure"):
                if ItemUOM.Get(rec."No.", rec."Base Unit of Measure") then begin
                    ItemUOM.CalcFields(Type);
                    ItemUOM.SetFilter(Type, '<>%1', ItemUOM.Type);
                end;
        end;
        ItemUOM.FilterGroup(0);

        ItemUOMForm.SetTableView(ItemUOM);
        ItemUOMForm.LookupMode(true);
        if (Text = '') or (not ItemUOM.Get(rec."No.", Text)) then // P8001273
            ItemUOM."Item No." := rec."No.";                       // P8001273
        ItemUOMForm.SetRecord(ItemUOM);
        res := ItemUOMForm.RunModal = ACTION::LookupOK;
        if res then begin
            ItemUOMForm.GetRecord(ItemUOM);
            Text := ItemUOM.Code;
        end;

        Item.Copy(rec);
        Item.Get(rec."No.");
        rec.Copy(Item);
        // PR3.60.02 End
    end;

    procedure ModifyItemUOM(xRec: Record "Item Unit of Measure"; var Rec: Record "Item Unit of Measure")
    var
        Item: Record Item;
        factor: Decimal;
        SpecGravity: Decimal;
    begin
        // ModifyItemUOM
        // P8000720 - add parameter for xRec
        with Rec do begin
            CalcFields(Type);
            if (Type <> 0) then begin
                //ItemUnitOfMeasure.GET("Item No.",Code);                                     // P8000720
                if (xRec."Qty. per Unit of Measure" <> "Qty. per Unit of Measure") then begin // P8000720
                    ItemUnitOfMeasure.Reset;
                    ItemUnitOfMeasure.SetRange("Item No.", "Item No.");
                    ItemUnitOfMeasure.SetRange(Type, Type);
                    ItemUnitOfMeasure.SetFilter(Code, '<>%1', Code);
                    if ItemUnitOfMeasure.Find('-') then begin
                        UnitOfMeasure.Get(Code);
                        factor := UnitOfMeasure."Base per Unit of Measure";
                        repeat
                            UnitOfMeasure.Get(ItemUnitOfMeasure.Code);
                            ItemUnitOfMeasure.Validate("Qty. per Unit of Measure", "Qty. per Unit of Measure" *
                              UnitOfMeasure."Base per Unit of Measure" / factor);
                            ItemUnitOfMeasure.Modify;
                        until ItemUnitOfMeasure.Next = 0;
                    end;
                end;
            end;

            if Type in [Type::Weight, Type::Volume] then begin // P8001093
                Item.Get("Item No.");
                ItemUnitOfMeasure.SetRange("Item No.", "Item No.");
                SpecGravity := 1;
                case Type of
                    Type::Weight:
                        begin
                            ItemUnitOfMeasure.SetRange(Type, Type::Volume);
                            if ItemUnitOfMeasure.Find('-') then begin
                                SpecGravity := 0.001 * UOMtoMetricBase(Code) / "Qty. per Unit of Measure";
                                SpecGravity := SpecGravity * ItemUnitOfMeasure."Qty. per Unit of Measure" / UOMtoMetricBase(ItemUnitOfMeasure.Code);
                            end;
                        end;
                    Type::Volume:
                        begin
                            ItemUnitOfMeasure.SetRange(Type, Type::Weight);
                            if ItemUnitOfMeasure.Find('-') then begin
                                SpecGravity := 0.001 * UOMtoMetricBase(ItemUnitOfMeasure.Code) / ItemUnitOfMeasure."Qty. per Unit of Measure";
                                SpecGravity := SpecGravity * "Qty. per Unit of Measure" / UOMtoMetricBase(Code);
                            end;
                        end;
                end;
                Item.Validate("Specific Gravity", SpecGravity); // PR3.70
                Item.Modify;
            end; // P8001093
        end;
    end;

    procedure VaidateItemUOMCode(var Rec: Record "Item Unit of Measure")
    var
        Item: Record Item;
    begin
        // VaidateItemUOMCode
        with Rec do begin
            CalcFields(Type);
            if Type <> 0 then begin
                ItemUnitOfMeasure.Reset;
                ItemUnitOfMeasure.SetRange("Item No.", "Item No.");
                ItemUnitOfMeasure.SetFilter(Code, '<>%1', Code);
                ItemUnitOfMeasure.SetRange(Type, Type);
                if ItemUnitOfMeasure.Find('-') then
                    Validate("Qty. per Unit of Measure", ConvertUOM(ItemUnitOfMeasure."Qty. per Unit of Measure",
                      Code, ItemUnitOfMeasure.Code))
                else begin
                    // If we know the specific gravity, the type is weight or volume, and we have
                    // a unit of measure of the other type then we can still figure out the
                    // Qty. per Unit of Measure
                    Item.Get("Item No.");
                    if (Item."Specific Gravity" <> 0) and (Type in [Type::Weight, Type::Volume]) then begin
                        ItemUnitOfMeasure.SetRange("Item No.", "Item No.");
                        if Type = Type::Volume then
                            ItemUnitOfMeasure.SetRange(Type, Type::Weight)
                        else
                            ItemUnitOfMeasure.SetRange(Type, Type::Volume);
                        if ItemUnitOfMeasure.Find('-') then
                            Validate("Qty. per Unit of Measure", ConvertUOMWithSpecGravity(
                              ItemUnitOfMeasure."Qty. per Unit of Measure",
                              ItemUnitOfMeasure.Code, Code, Item."Specific Gravity"));
                    end;
                end;
            end;
        end;
    end;

    procedure ItemWeight(ItemNo: Code[20]; BaseQty: Decimal; AltQty: Decimal): Decimal
    var
        Item: Record Item;
        UOM: Record "Unit of Measure";
        ItemUOM: Record "Item Unit of Measure";
    begin
        // ItemWeight
        Item.Get(ItemNo);
        if Item."Alternate Unit of Measure" <> '' then begin
            UOM.Get(Item."Alternate Unit of Measure");
            if UOM.Type = UOM.Type::Weight then
                exit(AltQty * UOMtoMetricBase(Item."Alternate Unit of Measure"));
        end;

        if not UOM.Get(Item."Base Unit of Measure") then // PR3.70.01
            exit(0);                                       // PR3.70.01
        if UOM.Type = UOM.Type::Weight then
            exit(BaseQty * UOMtoMetricBase(Item."Base Unit of Measure"))
        else begin
            ItemUOM.SetRange("Item No.", ItemNo);
            ItemUOM.SetRange(Type, ItemUOM.Type::Weight);
            if ItemUOM.Find('-') then
                exit((BaseQty / ItemUOM."Qty. per Unit of Measure") * UOMtoMetricBase(ItemUOM.Code));
        end;
    end;

    procedure ItemVolume(ItemNo: Code[20]; BaseQty: Decimal; AltQty: Decimal): Decimal
    var
        Item: Record Item;
        UOM: Record "Unit of Measure";
        ItemUOM: Record "Item Unit of Measure";
    begin
        // PR3.70
        Item.Get(ItemNo);
        if Item."Alternate Unit of Measure" <> '' then begin
            UOM.Get(Item."Alternate Unit of Measure");
            if UOM.Type = UOM.Type::Volume then
                exit(AltQty * UOMtoMetricBase(Item."Alternate Unit of Measure"));
        end;

        if not UOM.Get(Item."Base Unit of Measure") then // PR3.70.01
            exit(0);                                       // PR3.70.01
        if UOM.Type = UOM.Type::Volume then
            exit(BaseQty * UOMtoMetricBase(Item."Base Unit of Measure"))
        else begin
            ItemUOM.SetRange("Item No.", ItemNo);
            ItemUOM.SetRange(Type, ItemUOM.Type::Volume);
            if ItemUOM.Find('-') then
                exit((BaseQty / ItemUOM."Qty. per Unit of Measure") * UOMtoMetricBase(ItemUOM.Code));
        end;
    end;

    procedure ItemTareWeight(ItemNo: Code[20]; UOMCode: Code[10]; Qty: Decimal): Decimal
    var
        ItemUOM: Record "Item Unit of Measure";
    begin
        // ItemTareWeight
        if ItemUOM.Get(ItemNo, UOMCode) then
            if ItemUOM."Tare Weight" <> 0 then
                exit(Qty * ItemUOM."Tare Weight" * UOMtoMetricBase(ItemUOM."Tare Unit of Measure"));
    end;

    procedure ItemUnitGrossWeightAndVolume(var DecimalArray: array[3] of Decimal; ItemNo: Code[20]; BaseQty: Decimal; Qty: Decimal; UOMCode: Code[10]; AltQty: Decimal)
    begin
        // P80053245
        if DecimalArray[1] = 0 then begin
            DecimalArray[2] := 0;
            DecimalArray[3] := 0;
        end else begin
            DecimalArray[2] := (ItemWeight(ItemNo, BaseQty, AltQty) + ItemTareWeight(ItemNo, UOMCode, Qty)) / DecimalArray[1];
            DecimalArray[3] := ItemVolume(ItemNo, BaseQty, AltQty) / DecimalArray[1];
        end;
    end;

    procedure DefaultUOM(type: Option ,Length,Weight,Volume): Code[10]
    var
        InvSetup: Record "Inventory Setup";
        MeasSystem: Record "Measuring System";
        UOM: Record "Unit of Measure";
    begin
        InvSetup.Get; // P80060030
        if MeasSystem.Get(InvSetup."Measuring System", type) then
            if UOM.Get(MeasSystem.UOM) then
                exit(MeasSystem.UOM);
    end;
}

