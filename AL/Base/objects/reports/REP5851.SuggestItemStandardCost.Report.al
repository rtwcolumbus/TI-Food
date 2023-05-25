report 5851 "Suggest Item Standard Cost"
{
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // PRW17.10.02
    // P8001298, Columbus IT, Jack Reynolds, 26 FEB 14
    //   Fix problems with SKUs

    Caption = 'Suggest Item Standard Cost';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Vendor No.", "Costing Method", "Location Filter", "Variant Filter";
            dataitem("Stockkeeping Unit"; "Stockkeeping Unit")
            {
                DataItemLink = "Item No." = FIELD("No.");
                DataItemTableView = SORTING("Item No.", "Location Code", "Variant Code") WHERE("Replenishment System" = CONST(Purchase));

                trigger OnAfterGetRecord()
                begin
                    // P8001030
                    InsertStdCostWksh("Item No.", "Location Code", "Variant Code");
                end;

                trigger OnPreDataItem()
                begin
                    // P8001298
                    Item.CopyFilter("Location Filter", "Stockkeeping Unit"."Location Code");
                    Item.CopyFilter("Variant Filter", "Stockkeeping Unit"."Variant Code");
                    // P8001298
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if "Replenishment System" = "Replenishment System"::Purchase then // P8001298
                    InsertStdCostWksh("No.", '', ''); // P8001030
                if CurrentDateTime - WindowUpdateDateTime >= 750 then begin
                    Window.Update(1, "No.");
                    WindowUpdateDateTime := CurrentDateTime;
                end;
            end;

            trigger OnPostDataItem()
            begin
                Window.Close();
            end;

            trigger OnPreDataItem()
            begin
                WindowUpdateDateTime := CurrentDateTime;
                Window.Open(Text007 + Text008);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    group("Standard Cost")
                    {
                        Caption = 'Standard Cost';
                        field("AmtAdjustFactor[1]"; AmtAdjustFactor[1])
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Adjustment Factor';
                            DecimalPlaces = 0 : 5;
                            MinValue = 0;
                            NotBlank = true;
                            ToolTip = 'Specifies an adjustment factor to multiply the standard cost that you want suggested. By entering an adjustment factor, you can increase or decrease the amounts that are suggested.';
                        }
                        field("RoundingMethod[1]"; RoundingMethod[1])
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Rounding Method';
                            TableRelation = "Rounding Method";
                            ToolTip = 'Specifies a code for the rounding method that you want to apply to costs that you adjust.';
                        }
                    }
                    group("Indirect Cost %")
                    {
                        Caption = 'Indirect Cost %';
                        field("AmtAdjustFactor[2]"; AmtAdjustFactor[2])
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Adjustment Factor';
                            DecimalPlaces = 0 : 5;
                            MinValue = 0;
                            NotBlank = true;
                            ToolTip = 'Specifies an adjustment factor to multiply the standard cost that you want suggested. By entering an adjustment factor, you can increase or decrease the amounts that are suggested.';
                        }
                        field("RoundingMethod[2]"; RoundingMethod[2])
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Rounding Method';
                            TableRelation = "Rounding Method";
                            ToolTip = 'Specifies a code for the rounding method that you want to apply to costs that you adjust.';
                        }
                    }
                    group("Overhead Rate")
                    {
                        Caption = 'Overhead Rate';
                        field("AmtAdjustFactor[3]"; AmtAdjustFactor[3])
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Adjustment Factor';
                            DecimalPlaces = 0 : 5;
                            MinValue = 0;
                            NotBlank = true;
                            ToolTip = 'Specifies an adjustment factor to multiply the standard cost that you want suggested. By entering an adjustment factor, you can increase or decrease the amounts that are suggested.';
                        }
                        field("RoundingMethod[3]"; RoundingMethod[3])
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Rounding Method';
                            TableRelation = "Rounding Method";
                            ToolTip = 'Specifies a code for the rounding method that you want to apply to costs that you adjust.';
                        }
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        var
            i: Integer;
        begin
            for i := 1 to ArrayLen(AmtAdjustFactor) do
                if AmtAdjustFactor[i] = 0 then
                    AmtAdjustFactor[i] := 1;
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    var
        i: Integer;
    begin
        for i := 1 to ArrayLen(AmtAdjustFactor) do
            if AmtAdjustFactor[i] = 0 then
                AmtAdjustFactor[i] := 1;
    end;

    trigger OnPreReport()
    var
        StdCostWkshName: Record "Standard Cost Worksheet Name";
    begin
        if ToStdCostWkshName = '' then
            Error(Text004);
        StdCostWkshName.Get(ToStdCostWkshName);

        ToStdCostWksh.LockTable();
    end;

    var
        ToStdCostWksh: Record "Standard Cost Worksheet";
        Window: Dialog;
        ToStdCostWkshName: Code[10];
        RoundingMethod: array[3] of Code[10];
        AmtAdjustFactor: array[3] of Decimal;
        WindowUpdateDateTime: DateTime;

        Text004: Label 'You must specify a worksheet name to copy to.';
        Text007: Label 'Copying worksheet...\\';
        Text008: Label 'Item No. #1####################\';

    local procedure InsertStdCostWksh(No2: Code[20]; Location2: Code[10]; Variant2: Code[10])
    begin
        // P801030 - addeded parameters for Locatoin and Variant
        with ToStdCostWksh do begin
            Init();
            Validate("Standard Cost Worksheet Name", ToStdCostWkshName);
            Validate(Type, Type::Item);
            // P8001030
            "No." := No2;
            "Location Code" := Location2;
            "Variant Code" := Variant2;
            if (Location2 <> '') or (Variant2 <> '') then
                ValidateSKU
            else
                // P8001030
                Validate("No.", No2);

            Validate(
              "New Standard Cost",
              RoundAndAdjustAmt("Standard Cost", RoundingMethod[1], AmtAdjustFactor[1]));
            Validate(
              "New Indirect Cost %",
              RoundAndAdjustAmt("Indirect Cost %", RoundingMethod[2], AmtAdjustFactor[2]));
            Validate(
              "New Overhead Rate",
              RoundAndAdjustAmt("Overhead Rate", RoundingMethod[3], AmtAdjustFactor[3]));

            OnInsertStdCostWkshOnBeforeUpdate(ToStdCostWksh, RoundingMethod, AmtAdjustFactor);

            if not Insert(true) then
                Modify(true);
        end;
    end;

    procedure RoundAndAdjustAmt(Amt: Decimal; RoundingMethodCode: Code[10]; AmtAdjustFactor: Decimal): Decimal
    var
        RoundingMethod: Record "Rounding Method";
        Sign: Decimal;
    begin
        if Amt = 0 then
            exit(Amt);

        Amt := Round(Amt * AmtAdjustFactor, 0.00001);

        if RoundingMethodCode <> '' then
            with RoundingMethod do begin
                if Amt >= 0 then
                    Sign := 1
                else
                    Sign := -1;

                SetRange(Code, RoundingMethodCode);
                Code := RoundingMethodCode;
                "Minimum Amount" := Abs(Amt);
                if Find('=<') then begin
                    Amt := Amt + Sign * "Amount Added Before";
                    if Precision > 0 then
                        Amt := Sign * Round(Abs(Amt), Precision, CopyStr('=><', Type + 1, 1));
                    Amt := Amt + Sign * "Amount Added After";
                end;
            end;

        exit(Amt);
    end;

    procedure SetCopyToWksh(ToStdCostWkshName2: Code[10])
    begin
        ToStdCostWkshName := ToStdCostWkshName2;
    end;

    procedure Initialize(ToStdCostWkshName2: Code[10]; AmtAdjustFactor1: Decimal; AmtAdjustFactor2: Decimal; AmtAdjustFactor3: Decimal; RoundingMethod1: Code[10]; RoundingMethod2: Code[10]; RoundingMethod3: Code[10])
    begin
        ToStdCostWkshName := ToStdCostWkshName2;
        AmtAdjustFactor[1] := AmtAdjustFactor1;
        AmtAdjustFactor[2] := AmtAdjustFactor2;
        AmtAdjustFactor[3] := AmtAdjustFactor3;
        RoundingMethod[1] := RoundingMethod1;
        RoundingMethod[2] := RoundingMethod2;
        RoundingMethod[3] := RoundingMethod3;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertStdCostWkshOnBeforeUpdate(var ToStandardCostWorksheet: Record "Standard Cost Worksheet"; RoundingMethod: array[3] of Code[10]; AmtAdjustFactor: array[3] of Decimal)
    begin
    end;
}

