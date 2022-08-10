codeunit 99000768 "Production BOM-Copy"
{
    // PR1.00
    //   Copy additional version fields
    //   Copy Equipment Lines
    //   Copy ABC Lines
    //   Copy Quality Control Lines
    // 
    // PR2.00
    //   Remove quality specs
    //   Copy Unit of Measure code
    // 
    // PR2.00.02
    //   Allow copoying from any BOM not just different versions of the same BOM
    // 
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Copy lot preferences
    // 
    // PR4.00.05
    // P8000417B, VerticalSoft, Jack Reynolds, 17 NOV 06
    //   Fix problem with SQL and AutoIncrement when copy ABC lines
    // 
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens

    TableNo = "Production BOM Header";

    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'The %1 cannot be copied to itself.';
        Text001: Label '%1 on %2 %3 must not be %4';
        Text002: Label '%1 on %2 %3 %4 must not be %5';

    procedure CopyBOM(BOMHeaderNo: Code[20]; FromVersionCode: Code[20]; CurrentBOMHeader: Record "Production BOM Header"; ToVersionCode: Code[20])
    var
        FromProdBOMLine: Record "Production BOM Line";
        ToProdBOMLine: Record "Production BOM Line";
        FromProdBOMCompComment: Record "Production BOM Comment Line";
        ToProdBOMCompComment: Record "Production BOM Comment Line";
        ProdBOMVersion: Record "Production BOM Version";
        SkipBOMDeletion: Boolean;
        LineNo: Integer;
        ProdBOMVersion2: Record "Production BOM Version";
        FromBOMEquipment: Record "Prod. BOM Equipment";
        ToBOMEquipment: Record "Prod. BOM Equipment";
        FromABCLines: Record "Prod. BOM Activity Cost";
        ToABCLines: Record "Prod. BOM Activity Cost";
        ProcessFns: Codeunit "Process 800 Functions";
        LotSpecFns: Codeunit "Lot Specification Functions";
    begin
        if (CurrentBOMHeader."No." = BOMHeaderNo) and
           (FromVersionCode = ToVersionCode)
        then
            Error(Text000, CurrentBOMHeader.TableCaption);

        if ToVersionCode = '' then begin
            if CurrentBOMHeader.Status = CurrentBOMHeader.Status::Certified then
                Error(
                  Text001,
                  CurrentBOMHeader.FieldCaption(Status),
                  CurrentBOMHeader.TableCaption,
                  CurrentBOMHeader."No.",
                  CurrentBOMHeader.Status);
        end else begin
            ProdBOMVersion.Get(
              CurrentBOMHeader."No.", ToVersionCode);
            if ProdBOMVersion.Status = ProdBOMVersion.Status::Certified then
                Error(
                  Text002,
                  ProdBOMVersion.FieldCaption(Status),
                  ProdBOMVersion.TableCaption,
                  ProdBOMVersion."Production BOM No.",
                  ProdBOMVersion."Version Code",
                  ProdBOMVersion.Status);
        end;

        // PR1.00 Begin
        ProdBOMVersion2.Get(CurrentBOMHeader."No.", FromVersionCode);
        ProdBOMVersion."Primary UOM" := ProdBOMVersion2."Primary UOM";
        ProdBOMVersion."Weight UOM" := ProdBOMVersion2."Weight UOM";
        ProdBOMVersion."Volume UOM" := ProdBOMVersion2."Volume UOM";
        ProdBOMVersion."Unit of Measure Code" := ProdBOMVersion2."Unit of Measure Code"; // PR2.00
        ProdBOMVersion."Yield % (Weight)" := ProdBOMVersion2."Yield % (Weight)";
        ProdBOMVersion."Yield % (Volume)" := ProdBOMVersion2."Yield % (Volume)";
        // P8006959
        if ProdBOMVersion."Production BOM No." = ProdBOMVersion2."Production BOM No." then
            ProdBOMVersion."Direct Allergen Set ID" := ProdBOMVersion2."Direct Allergen Set ID";
        // P8006959
        ProdBOMVersion.Modify;
        // PR1.00 End

        LineNo := 0;
        SkipBOMDeletion := false;
        OnBeforeCopyBOM(CurrentBOMHeader, BOMHeaderNo, FromVersionCode, ToVersionCode, SkipBOMDeletion, LineNo);
        if not SkipBOMDeletion then begin
            ToProdBOMLine.SetRange("Production BOM No.", CurrentBOMHeader."No.");
            ToProdBOMLine.SetRange("Version Code", ToVersionCode);
            ToProdBOMLine.DeleteAll();

            // P8000153A Begin
            if ProcessFns.TrackingInstalled then
                LotSpecFns.DeleteBOMLotPrefs(ProdBOMVersion);
            // P8000153A End

            ToProdBOMCompComment.SetRange("Production BOM No.", CurrentBOMHeader."No.");
            ToProdBOMCompComment.SetRange("Version Code", ToVersionCode);
            ToProdBOMCompComment.DeleteAll();
        end;

        FromProdBOMLine.SetRange("Production BOM No.", BOMHeaderNo);
        FromProdBOMLine.SetRange("Version Code", FromVersionCode);
        if FromProdBOMLine.Find('-') then
            repeat
                ToProdBOMLine := FromProdBOMLine;
                ToProdBOMLine."Production BOM No." := CurrentBOMHeader."No.";
                ToProdBOMLine."Version Code" := ToVersionCode;
                if SkipBOMDeletion then
                    ToProdBOMLine."Line No." := LineNo;
                OnBeforeInsertProdBOMComponent(ToProdBOMLine, FromProdBOMLine);
                ToProdBOMLine.Insert();
                // P8000153A Begin
                if ProcessFns.TrackingInstalled then
                    LotSpecFns.CopyLotPrefBOMToBOM(FromProdBOMLine, ToProdBOMLine);
                // P8000153A End
                OnAfterInsertProdBOMComponent(ToProdBOMLine, FromProdBOMLine, CurrentBOMHeader, SkipBOMDeletion, LineNo);
            until FromProdBOMLine.Next() = 0;

        if SkipBOMDeletion then
            exit;

        FromProdBOMCompComment.SetRange("Production BOM No.", BOMHeaderNo);
        FromProdBOMCompComment.SetRange("Version Code", FromVersionCode);
        if FromProdBOMCompComment.Find('-') then
            repeat
                ToProdBOMCompComment := FromProdBOMCompComment;
                ToProdBOMCompComment."Production BOM No." := CurrentBOMHeader."No.";
                ToProdBOMCompComment."Version Code" := ToVersionCode;
                ToProdBOMCompComment.Insert();
            until FromProdBOMCompComment.Next() = 0;

        // PR1.00 Begin
        ToBOMEquipment.SetRange("Production Bom No.", CurrentBOMHeader."No.");
        ToBOMEquipment.SetRange("Version Code", ToVersionCode);
        ToBOMEquipment.DeleteAll;

        FromBOMEquipment.SetRange("Production Bom No.", BOMHeaderNo);
        FromBOMEquipment.SetRange("Version Code", FromVersionCode);

        if FromBOMEquipment.Find('-') then
            repeat
                ToBOMEquipment := FromBOMEquipment;
                ToBOMEquipment."Production Bom No." := CurrentBOMHeader."No.";
                ToBOMEquipment."Version Code" := ToVersionCode;
                ToBOMEquipment.Insert;
            until FromBOMEquipment.Next = 0;

        ToABCLines.SetRange("Production Bom No.", CurrentBOMHeader."No.");
        ToABCLines.SetRange("Version Code", ToVersionCode);
        ToABCLines.DeleteAll;

        FromABCLines.SetRange("Production Bom No.", BOMHeaderNo);
        FromABCLines.SetRange("Version Code", FromVersionCode);

        if FromABCLines.Find('-') then
            repeat
                ToABCLines := FromABCLines;
                ToABCLines."Production Bom No." := CurrentBOMHeader."No.";
                ToABCLines."Version Code" := ToVersionCode;
                ToABCLines."Line No." := 0; // P8000417B
                ToABCLines.Insert;
            until FromABCLines.Next = 0;
        // PR1.00 End
	
        OnAfterCopyBOM(BOMHeaderNo, CurrentBOMHeader, FromVersionCode, ToVersionCode);
    end;

    procedure CopyFromVersion(var ProdBOMVersionList2: Record "Production BOM Version")
    var
        ProdBOMHeader: Record "Production BOM Header";
        OldProdBOMVersionList: Record "Production BOM Version";
    begin
        OldProdBOMVersionList := ProdBOMVersionList2;

        ProdBOMHeader.Init();
        ProdBOMHeader."No." := ProdBOMVersionList2."Production BOM No.";
        if PAGE.RunModal(0, ProdBOMVersionList2) = ACTION::LookupOK then begin
            if OldProdBOMVersionList.Status = OldProdBOMVersionList.Status::Certified then
                Error(
                  Text002,
                  OldProdBOMVersionList.FieldCaption(Status),
                  OldProdBOMVersionList.TableCaption,
                  OldProdBOMVersionList."Production BOM No.",
                  OldProdBOMVersionList."Version Code",
                  OldProdBOMVersionList.Status);
            CopyBOM(ProdBOMVersionList2."Production BOM No.", ProdBOMVersionList2."Version Code", ProdBOMHeader, OldProdBOMVersionList."Version Code"); // PR2.00.02
        end;

        ProdBOMVersionList2 := OldProdBOMVersionList;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyBOM(BOMHeaderNo: Code[20]; CurrentBOMHeader: Record "Production BOM Header"; FromVersionCode: Code[20]; ToVersionCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyBOM(var ProdBOMHeader: Record "Production BOM Header"; BOMHeaderNo: Code[20]; FromVersionCode: Code[20]; ToVersionCode: Code[20]; var SkipBOMDeletion: Boolean; var LineNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertProdBOMComponent(var ToProductionBOMLine: Record "Production BOM Line"; var FromProductionBOMLine: Record "Production BOM Line"; var ProductionBOMHeader: Record "Production BOM Header"; var SkipBOMDeletion: Boolean; var LineNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertProdBOMComponent(var ToProductionBOMLine: Record "Production BOM Line"; var FromProductionBOMLine: Record "Production BOM Line")
    begin
    end;
}

