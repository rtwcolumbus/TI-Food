codeunit 37002549 "Item Q/C Skip Logic Management"
{
    // PRW111.00.01
    // P80037569, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Develop QC skip logic
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00


    trigger OnRun()
    begin
    end;

    var
        SkipLogicSetupLine: Record "Skip Logic Setup";
        Item: Record Item;
        ValueClass: Integer;
        ActivityClass: Integer;
        SourceType: Integer;
        SourceNo: Code[20];
        LastTransLineNo: Integer;

    procedure ApplySkipLogic(QualityControlHeader: Record "Quality Control Header"; var TempTransaction: Record "Item Quality Skip Logic Trans." temporary)
    var
        TempTransactionBuffer: Record "Item Quality Skip Logic Trans." temporary;
        LastSkipLogicTrans: Record "Item Quality Skip Logic Trans.";
        CurrentLevel: Integer;
        ExitLoop: Boolean;
    begin
        with QualityControlHeader do begin
            GetSourceType("Item No.", "Variant Code", "Lot No.", SourceType, SourceNo);
            GetItemClassCodes("Item No.", "Variant Code", SourceType, SourceNo, ValueClass, ActivityClass);
            SkipLogicSetupLine.SetRange("Value Class", ValueClass);
            SkipLogicSetupLine.SetRange("Activity Class", ActivityClass);
            LastTransLineNo := GetLastTransaction(LastSkipLogicTrans, "Item No.", "Variant Code", SourceType, SourceNo, ValueClass, ActivityClass);
            if LastTransLineNo <> 0 then
                SkipLogicSetupLine.SetFilter(Level, '>=%1', LastSkipLogicTrans."Current Level");
            if SkipLogicSetupLine.FindFirst then begin
                //Insert new temp transaction
                InsertTempTransaction(TempTransaction, "Item No.", "Variant Code", SourceType, SourceNo, ValueClass, ActivityClass, SkipLogicSetupLine.Level, SkipLogicSetupLine."Rejected Level", LastTransLineNo);

                if (LastTransLineNo = 0) or (HasExpired(LastSkipLogicTrans."Transaction Date", SkipLogicSetupLine."Max Interval")) then begin
                    SkipLogicSetupLine.SetRange(Level);
                    if SkipLogicSetupLine.FindFirst then begin
                        ResetTransaction(TempTransaction, SkipLogicSetupLine.Level, 1, 0, 0, SkipLogicSetupLine."Rejected Level", TempTransaction."Test Status"::Pending);
                        exit;
                    end;
                end;

                TempTransaction.Delete;
                TempTransaction := LastSkipLogicTrans;
                TempTransaction.Insert;

                if TempTransaction."Test Status" = TempTransaction."Test Status"::Fail then begin
                    // Last transaction rejected
                    SkipLogicSetupLine.SetRange(Level, LastSkipLogicTrans."Rejected Level");
                    if SkipLogicSetupLine.IsEmpty then
                        SkipLogicSetupLine.SetRange(Level);
                    if SkipLogicSetupLine.FindFirst then begin
                        ResetTransaction(TempTransaction, SkipLogicSetupLine.Level, 1, 0, 0, SkipLogicSetupLine."Rejected Level", TempTransaction."Test Status"::Pending);
                    end;
                end;

                CurrentLevel := SkipLogicSetupLine.Level;
                TempTransaction."Test Status" := TempTransaction."Test Status"::Pending;

                repeat
                    if CurrentLevel <> SkipLogicSetupLine.Level then begin
                        TempTransaction."Current Level" := SkipLogicSetupLine.Level;
                        TempTransaction."Current Frequency" := 1;
                        TempTransaction."Current Accepted Events" := 0;
                        TempTransaction."Current Skipped Events" := 0;
                        TempTransaction."Rejected Level" := SkipLogicSetupLine."Rejected Level";
                    end;
                    TempTransactionBuffer := TempTransaction;
                    TempTransactionBuffer."Current Accepted Events" -= SkipLogicSetupLine.Accept * TempTransactionBuffer."Current Frequency";
                    TempTransactionBuffer."Current Skipped Events" -= SkipLogicSetupLine.Skip * TempTransactionBuffer."Current Frequency";
                    ExitLoop := (TempTransactionBuffer."Current Accepted Events" = 0) and (TempTransactionBuffer."Current Skipped Events" = 0); // reached total events in the level
                    if ExitLoop then
                        TempTransaction."Current Frequency" += 1
                    else begin
                        ExitLoop := TempTransactionBuffer."Current Accepted Events" < 0;  // needs to pass in the level
                        if not ExitLoop then begin
                            ExitLoop := TempTransactionBuffer."Current Skipped Events" < 0; // needs to skip in the level
                            if ExitLoop then
                                TempTransaction."Test Status" := TempTransaction."Test Status"::Skip;
                        end;
                    end;
                    if TempTransaction."Current Frequency" > SkipLogicSetupLine.Frequency then // frequency reached the level, needs to move to the next level
                        ExitLoop := false;
                    if ExitLoop then
                        TempTransaction.Modify;
                until (SkipLogicSetupLine.Next = 0) or (ExitLoop);
            end;
        end;
    end;

    procedure GetItemClassCodes(ItemNo: Code[20]; VariantCode: Code[20]; var SourceType: Integer; var SourceNo: Code[20]; var ValueClass: Integer; var ActivityClass: Integer)
    var
        ItemQualityClassCode: Record "Item Quality Skip Logic Line";
    begin
        if not ItemQualityClassCode.Get(ItemNo, VariantCode, SourceType, SourceNo) then
            if not ItemQualityClassCode.Get(ItemNo, '', SourceType, SourceNo) then
                if not ItemQualityClassCode.Get(ItemNo, VariantCode, SourceType, '') then
                    if not ItemQualityClassCode.Get(ItemNo, '', SourceType, '') then
                        if not ItemQualityClassCode.Get(ItemNo, '', 0, '') then
                            ItemQualityClassCode.Init;
        ValueClass := ItemQualityClassCode."Value Class";
        ActivityClass := ItemQualityClassCode."Activity Class";
        SourceType := ItemQualityClassCode."Source Type";
        SourceNo := ItemQualityClassCode."Source No.";
    end;

    local procedure GetSourceType(ItemNo: Code[20]; VariantCode: Code[20]; LotNo: Code[50]; var SourceType: Integer; var SourceNo: Code[20])
    var
        LotInfo: Record "Lot No. Information";
    begin
        if LotInfo.Get(ItemNo, VariantCode, LotNo) then begin
            SourceType := LotInfo."Source Type";
            if LotInfo."Source Type" = LotInfo."Source Type"::Vendor then
                SourceNo := LotInfo."Source No."
            else
                SourceNo := '';
        end;
    end;

    local procedure GetLastTransaction(var LastSkipLogicTrans: Record "Item Quality Skip Logic Trans."; ItemNo: Code[20]; VariantCode: Code[20]; SourceType: Integer; SourceNo: Code[20]; ValueClass: Integer; ActivityClass: Integer): Integer
    begin
        LastSkipLogicTrans.Reset;
        LastSkipLogicTrans.SetRange("Item No.", ItemNo);
        LastSkipLogicTrans.SetRange("Variant Code", VariantCode);
        LastSkipLogicTrans.SetRange("Source Type", SourceType);
        LastSkipLogicTrans.SetRange("Source No.", SourceNo);
        LastSkipLogicTrans.SetRange("Value Class", ValueClass);
        LastSkipLogicTrans.SetRange("Activity Class", ActivityClass);
        if LastSkipLogicTrans.FindLast then
            exit(LastSkipLogicTrans."Line No.");
    end;

    local procedure HasExpired(TransactionDate: Date; MaxInterval: DateFormula): Boolean
    var
        IntervalDays: Integer;
    begin
        IntervalDays := CalcDate(MaxInterval, WorkDate) - WorkDate;
        if TransactionDate <> 0D then
            exit(WorkDate - TransactionDate > IntervalDays);
    end;

    local procedure InsertTempTransaction(var TempTransaction: Record "Item Quality Skip Logic Trans." temporary; ItemNo: Code[20]; VariantCode: Code[20]; SourceType: Integer; SourceNo: Code[20]; ValueClass: Integer; ActivityClass: Integer; CurrentLevel: Integer; RejectedLevel: Integer; LineNo: Integer)
    begin
        TempTransaction.Init;
        TempTransaction."Item No." := ItemNo;
        TempTransaction."Variant Code" := VariantCode;
        TempTransaction."Source Type" := SourceType;
        TempTransaction."Source No." := SourceNo;
        TempTransaction."Value Class" := ValueClass;
        TempTransaction."Activity Class" := ActivityClass;
        TempTransaction."Line No." := LineNo;
        TempTransaction."Current Level" := CurrentLevel;
        if (LineNo = 0) then
            TempTransaction."Current Frequency" := 1;
        TempTransaction."Current Accepted Events" := 0;
        TempTransaction."Current Skipped Events" := 0;
        TempTransaction."Rejected Level" := RejectedLevel;
        TempTransaction.Insert;
    end;

    local procedure ResetTransaction(var TempTransaction: Record "Item Quality Skip Logic Trans." temporary; CurrentLevel: Integer; CurrentFrequency: Integer; Accepted: Integer; Skipped: Integer; RejectLevel: Integer; Status: Integer)
    begin
        TempTransaction."Current Level" := CurrentLevel;
        TempTransaction."Current Frequency" := CurrentFrequency;
        TempTransaction."Current Accepted Events" := Accepted;
        TempTransaction."Current Skipped Events" := Skipped;
        TempTransaction."Rejected Level" := RejectLevel;
        TempTransaction."Test Status" := Status;
        TempTransaction.Modify;
    end;

    procedure UseQCActivity(QCHeader: Record "Quality Control Header"): Boolean
    var
        QCHeader2: Record "Quality Control Header";
    begin
        if QCHeader."Re-Test" then
            exit(false);

        QCHeader2.SetRange("Item No.", QCHeader."Item No.");
        QCHeader2.SetRange("Variant Code", QCHeader."Variant Code");
        QCHeader2.SetRange("Lot No.", QCHeader."Lot No.");
        QCHeader2.SetFilter("Test No.", '<>%1', QCHeader."Test No.");
        QCHeader2.SetRange("Re-Test", false);

        case QCHeader.Status of
            QCHeader.Status::Pending, QCHeader.Status::Suspended:
                exit(false);
            QCHeader.Status::Skip:
                exit(true);
            QCHeader.Status::Fail:
                begin
                    QCHeader2.SetRange(Status, QCHeader.Status::Fail);
                    exit(QCHeader2.IsEmpty());
                end;
            QCHeader.Status::Pass:
                begin
                    QCHeader2.SetRange(Status, QCHeader.Status::Fail);
                    if not QCHeader2.IsEmpty() then
                        exit(false);
                    QCHeader2.SetFilter(Status, '%1|%2|%3', QCHeader.Status::Pending, QCHeader.Status::Skip, QCHeader.Status::Suspended);
                    exit(QCHeader2.IsEmpty());
                end;
        end;
    end;
}

