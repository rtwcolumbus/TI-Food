codeunit 37002160 "Account Schedule Units"
{
    // PRW16.00.06
    // P8001019, Columbus IT, Jack Reynolds, 16 JAN 12
    //   Account Schedule - Item Units
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group


    trigger OnRun()
    begin
    end;

    var
        AccSchedName: Record "Acc. Schedule Name";
        ColLayoutName: Record "Column Layout Name";
        TempItemCategory: Record "Item Category" temporary;
        AccSchedUnitData: Record "Acc. Schedule Unit Data" temporary;
        TempDimBuf: Record "Dimension ID Buffer" temporary;
        AccSchedMgmt: Codeunit AccSchedManagement;
        DimCode: array[6] of Code[20];
        DimMap: array[4] of Integer;

    procedure CalcUnits(var GLAcc: Record "G/L Account"; var AccSchedLine: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout"): Decimal
    var
        GLSetup: Record "General Ledger Setup";
        AnalysisView: Record "Analysis View";
        AccSchedUnit: Record "Acc. Schedule Unit";
        ItemCategory: Record "Item Category";
        DimValue: array[6] of Record "Dimension Value";
        DimValueTemp: Record "Dimension Value" temporary;
        UseDimFilter: array[6] of Boolean;
        DimEntryNo: Integer;
        BegDate: Date;
        EndDate: Date;
        Result: Decimal;
        Index: Integer;
    begin
        if AccSchedLine."Acc. Schedule Unit Code" = '' then
            exit(0);
        AccSchedUnit.Get(AccSchedLine."Acc. Schedule Unit Code");

        if (AccSchedLine."Schedule Name" <> AccSchedName.Name) or
          (ColumnLayout."Column Layout Name" <> ColLayoutName.Name)
        then begin
            GLSetup.Get;
            AccSchedName.Get(AccSchedLine."Schedule Name");
            ColLayoutName.Get(ColumnLayout."Column Layout Name");
            AccSchedMgmt.CheckAnalysisView(AccSchedName.Name, ColLayoutName.Name, false);
            if AccSchedName."Analysis View Name" = '' then begin
                DimMap[1] := 1;
                DimCode[1] := GLSetup."Global Dimension 1 Code";
                DimMap[2] := 2;
                DimCode[2] := GLSetup."Global Dimension 2 Code";
            end else begin
                AnalysisView.Get(AccSchedName."Analysis View Name");
                Index := 3;

                if AnalysisView."Dimension 1 Code" = GLSetup."Global Dimension 1 Code" then begin
                    DimMap[1] := 1;
                    DimCode[1] := AnalysisView."Dimension 1 Code";
                end else
                    if AnalysisView."Dimension 1 Code" = GLSetup."Global Dimension 2 Code" then begin
                        DimMap[1] := 2;
                        DimCode[2] := AnalysisView."Dimension 1 Code";
                    end else begin
                        DimMap[1] := Index;
                        DimCode[Index] := AnalysisView."Dimension 1 Code";
                        Index += 1;
                    end;

                if AnalysisView."Dimension 2 Code" = GLSetup."Global Dimension 1 Code" then begin
                    DimMap[2] := 1;
                    DimCode[1] := AnalysisView."Dimension 2 Code";
                end else
                    if AnalysisView."Dimension 2 Code" = GLSetup."Global Dimension 2 Code" then begin
                        DimMap[2] := 2;
                        DimCode[2] := AnalysisView."Dimension 2 Code";
                    end else begin
                        DimMap[2] := Index;
                        DimCode[Index] := AnalysisView."Dimension 2 Code";
                        Index += 1;
                    end;

                if AnalysisView."Dimension 3 Code" = GLSetup."Global Dimension 1 Code" then begin
                    DimMap[3] := 1;
                    DimCode[1] := AnalysisView."Dimension 3 Code";
                end else
                    if AnalysisView."Dimension 3 Code" = GLSetup."Global Dimension 2 Code" then begin
                        DimMap[3] := 2;
                        DimCode[2] := AnalysisView."Dimension 3 Code";
                    end else begin
                        DimMap[3] := Index;
                        DimCode[Index] := AnalysisView."Dimension 3 Code";
                        Index += 1;
                    end;

                if AnalysisView."Dimension 4 Code" = GLSetup."Global Dimension 1 Code" then begin
                    DimMap[4] := 1;
                    DimCode[1] := AnalysisView."Dimension 4 Code";
                end else
                    if AnalysisView."Dimension 4 Code" = GLSetup."Global Dimension 2 Code" then begin
                        DimMap[4] := 2;
                        DimCode[2] := AnalysisView."Dimension 4 Code";
                    end else begin
                        DimMap[4] := Index;
                        DimCode[Index] := AnalysisView."Dimension 4 Code";
                    end;
            end;

            AccSchedUnitData.Reset;
            AccSchedUnitData.DeleteAll;

            TempItemCategory.Reset;
            if TempItemCategory.IsEmpty then begin
                TempItemCategory.Code := '';
                TempItemCategory.Insert;
                if ItemCategory.FindSet then
                    repeat
                        TempItemCategory := ItemCategory;
                        TempItemCategory.Insert;
                    until ItemCategory.Next = 0;
            end;
        end;

        SetDimensions(AccSchedLine, ColumnLayout, UseDimFilter, DimValue, DimValueTemp, DimEntryNo);
        if DimEntryNo = -1 then
            exit(0);

        SetDates(GLAcc.GetFilter("Date Filter"), BegDate, EndDate);
        TempItemCategory.SetFilter(Code, AccSchedUnit."Item Category Code Filter");
        if TempItemCategory.FindSet then
            repeat
                Result += CalcUnits2(AccSchedUnit, TempItemCategory.Code, BegDate, EndDate, DimEntryNo, UseDimFilter, DimValue, DimValueTemp);
            until TempItemCategory.Next = 0;

        exit(Round(Result * AccSchedUnit.Factor, 0.00001));
    end;

    local procedure CalcUnits2(AccSchedUnit: Record "Acc. Schedule Unit"; ItemCategoryCode: Code[20]; BegDate: Date; EndDate: Date; DimEntryNo: Integer; UseDimFilter: array[6] of Boolean; var DimValue: array[6] of Record "Dimension Value"; var DimValueTemp: Record "Dimension Value" temporary): Decimal
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        DimensionSetEntry: Record "Dimension Set Entry";
        EntryMatch: Boolean;
        Index: Integer;
        DimCode: Code[20];
        UseSIFT: Boolean;
    begin
        if not AccSchedUnitData.Get(ItemCategoryCode, BegDate, EndDate, AccSchedUnit."Entry Type", DimEntryNo) then begin
            UseSIFT := ItemLedgEntry.SetCurrentKey("Item Category Code", "Entry Type", "Posting Date",
              "Global Dimension 1 Code", "Global Dimension 2 Code");
            if not UseSIFT then
                ItemLedgEntry.SetCurrentKey("Item Category Code", "Item No.", "Entry Type");
            UseSIFT := UseSIFT and (not (UseDimFilter[3] or UseDimFilter[4] or UseDimFilter[5] or UseDimFilter[6]));

            ItemLedgEntry.SetRange("Item Category Code", ItemCategoryCode);
            ItemLedgEntry.SetRange("Entry Type", AccSchedUnit."Entry Type");
            ItemLedgEntry.SetRange("Posting Date", BegDate, EndDate);
            if UseDimFilter[1] then begin
                DimValue[1].CopyFilter(Code, ItemLedgEntry."Global Dimension 1 Code");
                ItemLedgEntry.FilterGroup(2);
                DimValue[1].FilterGroup(2);
                DimValue[1].CopyFilter(Code, ItemLedgEntry."Global Dimension 1 Code");
                ItemLedgEntry.FilterGroup(6);
                DimValue[1].FilterGroup(6);
                DimValue[1].CopyFilter(Code, ItemLedgEntry."Global Dimension 1 Code");
                ItemLedgEntry.FilterGroup(0);
                DimValue[1].FilterGroup(0);
            end;
            if UseDimFilter[2] then begin
                DimValue[2].CopyFilter(Code, ItemLedgEntry."Global Dimension 2 Code");
                ItemLedgEntry.FilterGroup(2);
                DimValue[2].FilterGroup(2);
                DimValue[2].CopyFilter(Code, ItemLedgEntry."Global Dimension 2 Code");
                ItemLedgEntry.FilterGroup(6);
                DimValue[2].FilterGroup(6);
                DimValue[2].CopyFilter(Code, ItemLedgEntry."Global Dimension 2 Code");
                ItemLedgEntry.FilterGroup(0);
                DimValue[2].FilterGroup(0);
            end;

            AccSchedUnitData.Init;
            if UseSIFT then begin
                ItemLedgEntry.CalcSums(Quantity, "Quantity (Alt.)");
                AccSchedUnitData.Quantity := ItemLedgEntry.Quantity;
                AccSchedUnitData."Quantity (Alt.)" := ItemLedgEntry."Quantity (Alt.)";
            end else
                if ItemLedgEntry.Find('-') then
                    repeat
                        EntryMatch := true;
                        if DimEntryNo <> 0 then begin
                            Index := 3;
                            while EntryMatch and (Index <= 6) do begin
                                if UseDimFilter[Index] then begin
                                    DimCode := DimValue[Index].GetFilter("Dimension Code");
                                    if DimensionSetEntry.Get(ItemLedgEntry."Dimension Set ID", DimCode) then            // P8001133
                                        EntryMatch := DimValueTemp.Get(DimCode, DimensionSetEntry."Dimension Value Code") // P8001133
                                    else
                                        EntryMatch := false;
                                end;
                                Index += 1;
                            end;
                        end;

                        if EntryMatch then begin
                            AccSchedUnitData.Quantity += ItemLedgEntry.Quantity;
                            AccSchedUnitData."Quantity (Alt.)" += ItemLedgEntry."Quantity (Alt.)";
                        end;
                    until ItemLedgEntry.Next = 0;

            AccSchedUnitData."Item Category Code" := ItemCategoryCode;
            AccSchedUnitData."Beginning Date" := BegDate;
            AccSchedUnitData."Ending Date" := EndDate;
            AccSchedUnitData."Entry Type" := AccSchedUnit."Entry Type";
            AccSchedUnitData."Dimension Entry No." := DimEntryNo;
            if AccSchedUnitData."Entry Type" in [AccSchedUnitData."Entry Type"::Sale, AccSchedUnitData."Entry Type"::Consumption] then begin
                AccSchedUnitData.Quantity := -AccSchedUnitData.Quantity;
                AccSchedUnitData."Quantity (Alt.)" := -AccSchedUnitData."Quantity (Alt.)";
            end;
            AccSchedUnitData.Insert;
        end;

        case AccSchedUnit."Quantity Field" of
            AccSchedUnit."Quantity Field"::Base:
                exit(AccSchedUnitData.Quantity);
            AccSchedUnit."Quantity Field"::Alternate:
                exit(AccSchedUnitData."Quantity (Alt.)");
        end;
    end;

    procedure DrillDownUnits(var GLAcc: Record "G/L Account"; var AccSchedLine: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout"): Decimal
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        AccSchedUnit: Record "Acc. Schedule Unit";
        DimValue: array[6] of Record "Dimension Value";
        DimValueTemp: Record "Dimension Value" temporary;
        ItemLedgEntries: Page "Item Ledger Entries";
        UseDimFilter: array[6] of Boolean;
        DimEntryNo: Integer;
        BegDate: Date;
        EndDate: Date;
    begin
        if AccSchedLine."Acc. Schedule Unit Code" = '' then
            exit;
        AccSchedUnit.Get(AccSchedLine."Acc. Schedule Unit Code");

        SetDimensions(AccSchedLine, ColumnLayout, UseDimFilter, DimValue, DimValueTemp, DimEntryNo);
        if DimEntryNo = -1 then
            exit(0);

        SetDates(GLAcc.GetFilter("Date Filter"), BegDate, EndDate);

        ItemLedgEntry.SetCurrentKey("Item Category Code", "Item No.", "Entry Type");
        ItemLedgEntry.SetFilter("Item Category Code", AccSchedUnit."Item Category Code Filter");
        ItemLedgEntry.SetRange("Entry Type", AccSchedUnit."Entry Type");
        ItemLedgEntry.SetRange("Posting Date", BegDate, EndDate);

        if UseDimFilter[1] then begin
            DimValue[1].CopyFilter(Code, ItemLedgEntry."Global Dimension 1 Code");
            ItemLedgEntry.FilterGroup(2);
            DimValue[1].FilterGroup(2);
            DimValue[1].CopyFilter(Code, ItemLedgEntry."Global Dimension 1 Code");
            ItemLedgEntry.FilterGroup(6);
            DimValue[1].FilterGroup(6);
            DimValue[1].CopyFilter(Code, ItemLedgEntry."Global Dimension 1 Code");
            ItemLedgEntry.FilterGroup(0);
            DimValue[1].FilterGroup(0);
        end;
        if UseDimFilter[2] then begin
            DimValue[2].CopyFilter(Code, ItemLedgEntry."Global Dimension 2 Code");
            ItemLedgEntry.FilterGroup(2);
            DimValue[2].FilterGroup(2);
            DimValue[2].CopyFilter(Code, ItemLedgEntry."Global Dimension 2 Code");
            ItemLedgEntry.FilterGroup(6);
            DimValue[2].FilterGroup(6);
            DimValue[2].CopyFilter(Code, ItemLedgEntry."Global Dimension 2 Code");
            ItemLedgEntry.FilterGroup(0);
            DimValue[2].FilterGroup(0);
        end;

        ItemLedgEntries.SetTableView(ItemLedgEntry);
        if DimEntryNo <> 0 then
            ItemLedgEntries.SetDimFilter(UseDimFilter, DimValue, DimValueTemp);
        ItemLedgEntries.Run;
    end;

    local procedure SetDimensions(var AccSchedLine: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout"; var UseDimFilter: array[6] of Boolean; var DimValue: array[6] of Record "Dimension Value"; var DimValueTemp: Record "Dimension Value"; var DimEntryNo: Integer)
    var
        Index: Integer;
    begin
        if DimMap[1] <> 0 then
            UseDimFilter[DimMap[1]] :=
              (AccSchedLine."Dimension 1 Totaling" <> '') or
              (AccSchedLine.GetFilter("Dimension 1 Filter") <> '') or
              (ColumnLayout."Dimension 1 Totaling" <> '');
        if DimMap[2] <> 0 then
            UseDimFilter[DimMap[2]] :=
              (AccSchedLine."Dimension 2 Totaling" <> '') or
              (AccSchedLine.GetFilter("Dimension 2 Filter") <> '') or
              (ColumnLayout."Dimension 2 Totaling" <> '');
        if DimMap[3] <> 0 then
            UseDimFilter[DimMap[3]] :=
              (AccSchedLine."Dimension 3 Totaling" <> '') or
              (AccSchedLine.GetFilter("Dimension 3 Filter") <> '') or
              (ColumnLayout."Dimension 3 Totaling" <> '');
        if DimMap[4] <> 0 then
            UseDimFilter[DimMap[4]] :=
              (AccSchedLine."Dimension 4 Totaling" <> '') or
              (AccSchedLine.GetFilter("Dimension 4 Filter") <> '') or
              (ColumnLayout."Dimension 4 Totaling" <> '');

        if UseDimFilter[1] or UseDimFilter[2] or UseDimFilter[3] or UseDimFilter[4] or UseDimFilter[5] or UseDimFilter[6] then begin
            if DimMap[1] <> 0 then
                AccSchedLine.CopyFilter("Dimension 1 Filter", DimValue[DimMap[1]].Code);
            if DimMap[2] <> 0 then
                AccSchedLine.CopyFilter("Dimension 2 Filter", DimValue[DimMap[2]].Code);
            if DimMap[3] <> 0 then
                AccSchedLine.CopyFilter("Dimension 3 Filter", DimValue[DimMap[3]].Code);
            if DimMap[4] <> 0 then
                AccSchedLine.CopyFilter("Dimension 4 Filter", DimValue[DimMap[4]].Code);

            if DimMap[1] <> 0 then begin
                DimValue[DimMap[1]].FilterGroup(2);
                DimValue[DimMap[1]].SetFilter(Code, AccSchedMgmt.GetDimTotalingFilter(1, AccSchedLine."Dimension 1 Totaling"));
            end;
            if DimMap[2] <> 0 then begin
                DimValue[DimMap[2]].FilterGroup(2);
                DimValue[DimMap[2]].SetFilter(Code, AccSchedMgmt.GetDimTotalingFilter(2, AccSchedLine."Dimension 2 Totaling"));
            end;
            if DimMap[3] <> 0 then begin
                DimValue[DimMap[3]].FilterGroup(2);
                DimValue[DimMap[3]].SetFilter(Code, AccSchedMgmt.GetDimTotalingFilter(3, AccSchedLine."Dimension 3 Totaling"));
            end;
            if DimMap[4] <> 0 then begin
                DimValue[DimMap[4]].FilterGroup(2);
                DimValue[DimMap[4]].SetFilter(Code, AccSchedMgmt.GetDimTotalingFilter(4, AccSchedLine."Dimension 4 Totaling"));
            end;

            if DimMap[1] <> 0 then begin
                DimValue[DimMap[1]].FilterGroup(6);
                DimValue[DimMap[1]].SetFilter(Code, AccSchedMgmt.GetDimTotalingFilter(1, ColumnLayout."Dimension 1 Totaling"));
            end;
            if DimMap[2] <> 0 then begin
                DimValue[DimMap[2]].FilterGroup(6);
                DimValue[DimMap[2]].SetFilter(Code, AccSchedMgmt.GetDimTotalingFilter(2, ColumnLayout."Dimension 2 Totaling"));
            end;
            if DimMap[3] <> 0 then begin
                DimValue[DimMap[3]].FilterGroup(6);
                DimValue[DimMap[3]].SetFilter(Code, AccSchedMgmt.GetDimTotalingFilter(3, ColumnLayout."Dimension 3 Totaling"));
            end;
            if DimMap[4] <> 0 then begin
                DimValue[DimMap[4]].FilterGroup(6);
                DimValue[DimMap[4]].SetFilter(Code, AccSchedMgmt.GetDimTotalingFilter(4, ColumnLayout."Dimension 4 Totaling"));
            end;

            if DimMap[1] <> 0 then
                DimValue[DimMap[1]].FilterGroup(0);
            if DimMap[2] <> 0 then
                DimValue[DimMap[2]].FilterGroup(0);
            if DimMap[3] <> 0 then
                DimValue[DimMap[3]].FilterGroup(0);
            if DimMap[4] <> 0 then
                DimValue[DimMap[4]].FilterGroup(0);

            for Index := 1 to 4 do
                if DimMap[Index] <> 0 then
                    if UseDimFilter[DimMap[Index]] and (DimCode[DimMap[Index]] <> '') then begin
                        DimValue[DimMap[Index]].SetRange("Dimension Code", DimCode[DimMap[Index]]);
                        if DimValue[DimMap[Index]].FindSet then
                            repeat
                                DimValueTemp := DimValue[DimMap[Index]];
                                DimValueTemp.Insert;
                            until DimValue[DimMap[Index]].Next = 0;
                    end;

            DimEntryNo := FindDimensions(DimValueTemp);
        end;
    end;

    local procedure FindDimensions(var DimValueTemp: Record "Dimension Value" temporary): Integer
    var
        TempDimBuf2: Record "Dimension ID Buffer";
        Mismatch: Boolean;
    begin
        // We use the Dimension ID Buffer table to keep track of the dimension sets
        //    Parent ID   will be used for Set number (-1 is used for the empty set)
        //    ID          will be used for the count of records in the set
        DimValueTemp.Reset;
        if not DimValueTemp.Find('-') then
            exit(-1);

        TempDimBuf.Reset;
        TempDimBuf.SetCurrentKey(ID);
        TempDimBuf.SetRange(ID, DimValueTemp.Count);
        TempDimBuf.SetRange("Dimension Code", DimValueTemp."Dimension Code");
        TempDimBuf.SetRange("Dimension Value", DimValueTemp.Code);
        if not TempDimBuf.Find('-') then
            exit(InsertDimensions(DimValueTemp));
        if TempDimBuf.ID = 1 then
            exit(TempDimBuf."Parent ID");

        repeat
            TempDimBuf2.Copy(TempDimBuf);
            TempDimBuf.Reset;
            TempDimBuf.SetRange("Parent ID", TempDimBuf."Parent ID");
            DimValueTemp.Find('-');

            Mismatch := false;
            while (not Mismatch) and (TempDimBuf.Next <> 0) do begin
                DimValueTemp.Next;
                Mismatch := (TempDimBuf."Dimension Code" <> DimValueTemp."Dimension Code") or
                  (TempDimBuf."Dimension Value" <> DimValueTemp.Code);
            end;
            if not Mismatch then
                exit(TempDimBuf."Parent ID");
            TempDimBuf.Copy(TempDimBuf2);
        until TempDimBuf.Next = 0;

        exit(InsertDimensions(DimValueTemp));
    end;

    local procedure InsertDimensions(var DimValueTemp: Record "Dimension Value" temporary): Integer
    begin
        TempDimBuf.Reset;
        if TempDimBuf.Find('+') then
            TempDimBuf."Parent ID" += 1
        else
            TempDimBuf."Parent ID" := 1;

        DimValueTemp.Reset;
        TempDimBuf.ID := DimValueTemp.Count;
        DimValueTemp.Find('-');
        repeat
            TempDimBuf."Dimension Code" := DimValueTemp."Dimension Code";
            TempDimBuf."Dimension Value" := DimValueTemp.Code;
            TempDimBuf.Insert;
        until DimValueTemp.Next = 0;

        exit(TempDimBuf."Parent ID");
    end;

    local procedure SetDates(FilterString: Text[30]; var BegDate: Date; var EndDate: Date)
    var
        Position: Integer;
    begin
        // Should be of the form '', BegDate..EndDate, ''..EndDate, <EndDate
        Position := StrPos(FilterString, '..');
        if Position = 0 then begin
            Position := StrPos(FilterString, '<');
            if Position = 0 then
                exit;
            Evaluate(EndDate, CopyStr(FilterString, Position + 1));
        end else begin
            if Evaluate(BegDate, CopyStr(FilterString, 1, Position - 1)) then;
            Evaluate(EndDate, CopyStr(FilterString, Position + 2));
        end;
    end;
}

