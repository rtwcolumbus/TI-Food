codeunit 99000853 "Calc. Low-level code"
{
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // P8001092, Columbus IT, Don Bresee, 30 AUG 12
    //   Add logic for Item & Co-Product Process BOMs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.10
    // P8001226, Columbus IT, Jack Reynolds, 01 OCT 13
    //   Calculate low-level code with background processing from job queue

    ObsoleteState = Pending;
    ObsoleteReason = 'Use Codeunit Low-Level Code Calculator instead.';
    ObsoleteTag = '17.0';

    trigger OnRun()
    begin
        if not GuiAllowed then // P8001228
            HideDialogs := true; // P8001228
        FindTopLevel();
    end;

    var
        Text000: Label 'Calculate low-level code';
        Text001: Label 'No. #2################## @3@@@@@@@@@@@@@';
        Text002: Label 'Top-Level Items';
        Text003: Label 'BOMs';
        TimeTakenForRunTxt: Label 'Time taken to run low level calculation through Calc. Low-level code is %1.', Comment = '%1 is the time taken', Locked = true;
        HideDialogs: Boolean;

    local procedure FindTopLevel()
    var
        ProdBOMLine: Record "Production BOM Line";
        BOMComp: Record "BOM Component";
        Item: Record Item;
        ProdBOMHeader: Record "Production BOM Header";
        ProdBOMHeader2: Record "Production BOM Header";
        CalcLowLevelCode: Codeunit "Calculate Low-Level Code";
        ConfirmManagement: Codeunit "Confirm Management";
        Window: Dialog;
        WindowUpdateDateTime: DateTime;
        NoofItems: Integer;
        CountOfRecords: Integer;
        HasProductionBOM: Boolean;
        FamilyLine: Record "Family Line";
        Start: DateTime;
    begin
        NoofItems := 0;
        if not HideDialogs then
            if not ConfirmManagement.GetResponseOrDefault(Text000, true) then
                exit;
        Start := CurrentDateTime();
        if not HideDialogs then begin // P8001228
            Window.Open(
              '#1################## \\' +
              Text001);
            WindowUpdateDateTime := CurrentDateTime;
            // P8001228
        end else
            WindowUpdateDateTime := CreateDateTime(99991231D, 0T);
        if not HideDialogs then
            // P8001228
            Window.Update(1, Text002);

        Item.LockTable();
        Item.ModifyAll("Low-Level Code", 0);
        ProdBOMHeader.LockTable();
        ProdBOMHeader.ModifyAll("Low-Level Code", 0);

        ProdBOMLine.SetCurrentKey(Type, "No.");
        CountOfRecords := Item.Count();
        if Item.Find('-') then
            repeat
                if CurrentDateTime - WindowUpdateDateTime > 2000 then begin
                    Window.Update(2, Item."No.");
                    Window.Update(3, Round(NoofItems / CountOfRecords * 10000, 1));
                    WindowUpdateDateTime := CurrentDateTime;
                end;

                HasProductionBOM := ProdBOMHeader.Get(Item."Production BOM No.");
                if (ProdBOMHeader."Low-Level Code" = 0) or not HasProductionBOM
                then begin
                    ProdBOMLine.SetRange("No.", Item."No.");
                    ProdBOMLine.SetRange(Type, ProdBOMLine.Type::Item);

                    BOMComp.SetRange(Type, BOMComp.Type::Item);
                    BOMComp.SetRange("No.", Item."No.");

                    if ProdBOMLine.IsEmpty() and BOMComp.IsEmpty() then begin
                        // handle items which are not part of any BOMs
                        Item.CalcFields("Assembly BOM");
                        if Item."Assembly BOM" then
                            CalcLowLevelCode.RecalcAsmLowerLevels(Item."No.", CalcLowLevelCode.CalcLevels(3, Item."No.", 0, 0), true);
                        if HasProductionBOM then
                            CalcLevelsForBOM(ProdBOMHeader);
                        CalcLevelsForSKUBOMs(Item); // P8001030
                        CalcLevelsForProcessBOMs(Item); // P8001092
                    end else
                        if HasProductionBOM then
                            if ProdBOMLine.Find('-') then
                                repeat
                                    // handle items which are part of un-certified, active BOMs
                                    if ProdBOMHeader2.Get(ProdBOMLine."Production BOM No.") then
                                        if ProdBOMHeader2.Status in [ProdBOMHeader2.Status::New, ProdBOMHeader2.Status::"Under Development"] then begin // P8001132
                                            CalcLevelsForBOM(ProdBOMHeader);
                                            CalcLevelsForSKUBOMs(Item); // P8001030
                                            CalcLevelsForProcessBOMs(Item); // P8001092
                                            Item.Mark(true);
                                        end; // P8001132
                                until (ProdBOMLine.Next() = 0) or Item.Mark; // P8001030
                end;

                NoofItems := NoofItems + 1;
            until Item.Next() = 0;

        NoofItems := 0;
        if not HideDialogs then // P8001228
            Window.Update(1, Text003);
        ProdBOMHeader.Reset();
        ProdBOMHeader.SetCurrentKey(Status);
        ProdBOMHeader.SetRange(Status, ProdBOMHeader.Status::Certified);
        ProdBOMHeader.SetRange("Low-Level Code", 0);
        CountOfRecords := ProdBOMHeader.Count();
        if ProdBOMHeader.Find('-') then
            repeat
                if CurrentDateTime - WindowUpdateDateTime > 2000 then begin
                    Window.Update(2, ProdBOMHeader."No.");
                    Window.Update(3, Round(NoofItems / CountOfRecords * 10000, 1));
                    WindowUpdateDateTime := CurrentDateTime;
                end;
                ProdBOMHeader2 := ProdBOMHeader;
                CalcLevelsForBOM(ProdBOMHeader2);
                NoofItems := NoofItems + 1;
            until ProdBOMHeader.Next() = 0;

        OnAfterFindTopLevel();
        Session.LogMessage('0000CIN', StrSubstNo(TimeTakenForRunTxt, CurrentDateTime() - Start), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', 'Planning');
    end;

    local procedure CalcLevelsForBOM(var ProdBOM: Record "Production BOM Header")
    var
        ProdBOMLine: Record "Production BOM Line";
        CalcLowLevelCode: Codeunit "Calculate Low-Level Code";
    begin
        if ProdBOM.Status = ProdBOM.Status::Certified then begin
            ProdBOM."Low-Level Code" := CalcLowLevelCode.CalcLevels(ProdBOMLine.Type::"Production BOM".AsInteger(), ProdBOM."No.", 0, 0);
            CalcLowLevelCode.RecalcLowerLevels(ProdBOM."No.", ProdBOM."Low-Level Code", true);
            ProdBOM.Modify();
        end;
    end;

    procedure SetHideDialogs(NewHideDialogs: Boolean)
    begin
        HideDialogs := NewHideDialogs;
    end;

    local procedure CalcLevelsForSKUBOMs(Item: Record Item)
    var
        SKU: Record "Stockkeeping Unit";
        ProdBOMHeader: Record "Production BOM Header";
    begin
        // P8000130
        SKU.SetCurrentKey("Item No.");
        SKU.SetRange("Item No.", Item."No.");
        SKU.SetFilter("Production BOM No.", '<>%1', '');
        if SKU.FindSet then
            repeat
                if ProdBOMHeader.Get(SKU."Production BOM No.") then
                    if ProdBOMHeader."Low-Level Code" = 0 then
                        CalcLevelsForBOM(ProdBOMHeader);
            until SKU.Next = 0;
    end;

    local procedure CalcLevelsForProcessBOMs(var Item: Record Item)
    var
        ProdBOMHeader: Record "Production BOM Header";
        ItemProcessBOM: Record "Production BOM Header";
        FamilyLine: Record "Family Line";
    begin
        // P8001092
        with ItemProcessBOM do begin
            SetCurrentKey("Output Item No.");
            SetRange("Output Item No.", Item."No.");
            if FindSet then
                repeat
                    if "Low-Level Code" = 0 then
                        CalcLevelsForBOM(ItemProcessBOM);
                until (Next = 0);
        end;
        with FamilyLine do begin
            SetCurrentKey("Item No.");
            SetRange("Item No.", Item."No.");
            SetRange("Process Family", true);
            if FindSet then
                repeat
                    if ProdBOMHeader.Get("Family No.") then
                        if ProdBOMHeader."Low-Level Code" = 0 then
                            CalcLevelsForBOM(ProdBOMHeader);
                until (Next = 0);
        end;
    end;

    local procedure UpdateCoProdOutputs()
    var
        FamilyLine: Record "Family Line";
        Item: Record Item;
    begin
        // P8001092
        with FamilyLine do begin
            SetCurrentKey("Item No.");
            if FindSet then
                repeat
                    SetRange("Item No.", "Item No.");
                    if not Item.Get("Item No.") then
                        Clear(Item);
                    repeat
                        "Low-Level Code" := Item."Low-Level Code";
                        Modify;
                    until (Next = 0);
                    SetRange("Item No.");
                until (Next = 0);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindTopLevel()
    begin
    end;
}
