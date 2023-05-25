codeunit 99000769 "Production BOM-Check"
{
    // PR1.00
    //   CheckBOMStructure - error if any Unapproved items
    // 
    // PR1.20
    //   Output Item must be supplied for Process BOM's
    // 
    // PR2.00
    //   Text constants
    // 
    // PR3.70
    //   Relocate Status check for variables from Production BOM Header table
    // 
    // PRW17.00
    // P8001145, Columbus IT, Don Bresee, 27 MAR 13
    //   Rework Low-Level Code Calculation
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW121.0
    // P800155629, To-Increase, Jack Reynolds, 03 NOV 22
    //   Add support for Mandatory Variant

    Permissions = TableData Item = r,
                  TableData "Routing Line" = r,
                  TableData "Manufacturing Setup" = r;
    TableNo = "Production BOM Header";

    trigger OnRun()
    begin
        Code(Rec, '');
    end;

    var
        Text000: Label 'Checking Item           #1########## @2@@@@@@@@@@@@@';
        Text001: Label 'The maximum number of BOM levels, %1, was exceeded. The process stopped at item number %2, BOM header number %3, BOM level %4.';
        Text003: Label '%1 with %2 %3 cannot be found. Check %4 %5 %6 %7.';
        Item: Record Item;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        RtngLine: Record "Routing Line";
        MfgSetup: Record "Manufacturing Setup";
        VersionMgt: Codeunit VersionManagement;
        Window: Dialog;
        NoOfItems: Integer;
        ItemCounter: Integer;
        CircularRefInBOMErr: Label 'The production BOM %1 has a circular reference. Pay attention to the production BOM %2 that closes the loop.', Comment = '%1 = Production BOM No., %2 = Production BOM No.';
        ProcessOrderMgmt: Codeunit "Process Order Management";
        Text37002000: Label 'Unapproved items are not allowed.';
        Text37002001: Label 'You must specify at least one output.';
        Text37002002: Label 'You must specify at least one output that is not a %1.';
        Text37002003: Label '%1 is currently in use and may not be certified with variables.';

    procedure "Code"(var ProdBOMHeader: Record "Production BOM Header"; VersionCode: Code[20])
    var
        CalcLowLevel: Codeunit "Calculate Low-Level Code";
    begin
        ProdBOMHeader.TestField("Unit of Measure Code");
        if ProdBOMHeader."Mfg. BOM Type" = ProdBOMHeader."Mfg. BOM Type"::Process then // PR1.20
            if (ProdBOMHeader."Output Type" = ProdBOMHeader."Output Type"::Item) then // PR3.60
                ProdBOMHeader.TestField("Output Item No.");         // PR1.20
        CheckProcessOutputs(ProdBOMHeader, VersionCode); // PR3.60
        MfgSetup.Get();
        if MfgSetup."Dynamic Low-Level Code" then begin
            CalcLowLevel.SetActualProdBOM(ProdBOMHeader);
            ProdBOMHeader."Low-Level Code" := CalcLowLevel.CalcLevels(2, ProdBOMHeader."No.", ProdBOMHeader."Low-Level Code", 1);
            CalcLowLevel.RecalcLowerLevels(ProdBOMHeader."No.", ProdBOMHeader."Low-Level Code", false);
            ProdBOMHeader.Modify();
        end else
            CheckBOM(ProdBOMHeader."No.", VersionCode);

        ProcessItems(ProdBOMHeader, VersionCode, CalcLowLevel);

        OnAfterCode(ProdBOMHeader, VersionCode);
    end;

    local procedure ProcessItems(var ProdBOMHeader: Record "Production BOM Header"; VersionCode: Code[20]; var CalcLowLevel: Codeunit "Calculate Low-Level Code")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeProcessItems(ProdBOMHeader, VersionCode, IsHandled);
        if IsHandled then
            exit;

        Item.SetCurrentKey("Production BOM No.");
        Item.SetRange("Production BOM No.", ProdBOMHeader."No.");

        OnProcessItemsOnAfterItemSetFilters(Item, ProdBOMHeader);
        // if Item.Find('-') then begin   // P8001145
        if CalcLowLevel.GetFirstBOMItem(ProdBOMHeader."No.", Item) then begin // P8001145
            OpenDialogWindow();
            // NoOfItems := Item.Count();
            NoOfItems := CalcLowLevel.GetBOMItemCount(); // P8001145
            ItemCounter := 0;
            repeat
                ItemCounter := ItemCounter + 1;

                UpdateDialogWindow();
                if MfgSetup."Dynamic Low-Level Code" then
                    CalcLowLevel.Run(Item);
                if Item."Routing No." <> '' then
                    CheckBOMStructure(ProdBOMHeader."No.", VersionCode, 1);
                ItemUnitOfMeasure.Get(Item."No.", ProdBOMHeader."Unit of Measure Code");
                // until Item.Next() = 0;                // P8001145
            until not CalcLowLevel.GetNextBOMItem(Item); // P8001145
        end;

    end;

    local procedure OpenDialogWindow()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOpenDialogWindow(Window, IsHandled);
        if IsHandled then
            exit;

        if GuiAllowed() then
            Window.Open(Text000);
    end;

    local procedure UpdateDialogWindow()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateDialogWindow(Item, ItemCounter, NoOfItems, Window, IsHandled);
        if IsHandled then
            exit;

        if GuiAllowed() then begin
            Window.Update(1, Item."No.");
            Window.Update(2, Round(ItemCounter / NoOfItems * 10000, 1));
        end;
    end;

    procedure CheckBOMStructure(BOMHeaderNo: Code[20]; VersionCode: Code[20]; Level: Integer)
    var
        ProdBOMHeader: Record "Production BOM Header";
        ProdBOMComponent: Record "Production BOM Line";
    begin
        if Level > 99 then
            Error(
              Text001,
              99, BOMHeaderNo, Item."Production BOM No.", Level);

        ProdBOMHeader.Get(BOMHeaderNo);

        ProdBOMComponent.SetRange("Production BOM No.", BOMHeaderNo);
        ProdBOMComponent.SetRange("Version Code", VersionCode);
        ProdBOMComponent.SetFilter("No.", '<>%1', '');

        if ProdBOMComponent.Find('-') then
            repeat
                case ProdBOMComponent.Type of
                    ProdBOMComponent.Type::Item:
                        if ProdBOMComponent."Routing Link Code" <> '' then begin
                            Item.TestField("Routing No.");
                            RtngLine.SetRange("Routing No.", Item."Routing No.");
                            RtngLine.SetRange("Routing Link Code", ProdBOMComponent."Routing Link Code");
                            if not RtngLine.FindFirst() then
                                Error(
                                  Text003,
                                  RtngLine.TableCaption(),
                                  RtngLine.FieldCaption("Routing Link Code"),
                                  ProdBOMComponent."Routing Link Code",
                                  ProdBOMComponent.FieldCaption("Production BOM No."),
                                  ProdBOMComponent."Production BOM No.",
                                  ProdBOMComponent.FieldCaption("Line No."),
                                  ProdBOMComponent."Line No.");
                        end;
                    ProdBOMComponent.Type::"Production BOM":
                        CheckBOMStructure(
                          ProdBOMComponent."No.",
                          VersionMgt.GetBOMVersion(ProdBOMComponent."No.", WorkDate(), true), Level + 1);
                    // PR1.00 Begin
                    ProdBOMComponent.Type::FOODUnapprovedItem:
                        Error(Text37002000);
                        // PR1.00 End
                end;
            until ProdBOMComponent.Next() = 0;
    end;

    procedure ProdBOMLineCheck(ProdBOMNo: Code[20]; VersionCode: Code[20])
    var
        ProdBOMLine: Record "Production BOM Line";
        Item: Record Item;
    begin
        ProdBOMLine.SetRange("Production BOM No.", ProdBOMNo);
        ProdBOMLine.SetRange("Version Code", VersionCode);
        ProdBOMLine.SetFilter(Type, '<>%1', ProdBOMLine.Type::" ");
        ProdBOMLine.SetRange("No.", '');
        if ProdBOMLine.FindFirst() then
            ProdBOMLine.FieldError("No.");
            
        // PR3.70 Begin
        ProdBOMLine.SetRange(Type, ProdBOMLine.Type::FOODVariable);
        ProdBOMLine.SetRange("No.");
        if ProdBOMLine.Find('-') then begin
            Item.SetCurrentKey("Production BOM No.", "No.");
            Item.SetRange("Production BOM No.", ProdBOMNo);
            if Item.Find('-') then
                Error(Text37002003, ProdBOMNo);
        end;
        // PR3.70 End

        // P800155629
        ProdBOMLine.SetRange(Type, ProdBOMLine.Type::Item); 
        if ProdBOMLine.FindSet(false, false) then
            repeat
                if Item.IsVariantMandatory(true, ProdBOMLine."No.") then
                    ProdBOMLine.TestField("Variant Code");
            until ProdBOMLine.Next() = 0;
        // P800155629

        OnAfterProdBomLineCheck(ProdBOMLine, VersionCode);
    end;

    procedure CheckBOM(ProductionBOMNo: Code[20]; VersionCode: Code[20])
    var
        TempProductionBOMHeader: Record "Production BOM Header" temporary;
    begin
        TempProductionBOMHeader."No." := ProductionBOMNo;
        TempProductionBOMHeader.Insert();
        CheckCircularReferencesInProductionBOM(TempProductionBOMHeader, VersionCode);
    end;

    local procedure CheckCircularReferencesInProductionBOM(var TempProductionBOMHeader: Record "Production BOM Header" temporary; VersionCode: Code[20])
    var
        ProductionBOMHeader: Record "Production BOM Header";
        ProductionBOMLine: Record "Production BOM Line";
        NextVersionCode: Code[20];
        CheckNextLevel: Boolean;
    begin
        ProductionBOMLine.SetRange("Production BOM No.", TempProductionBOMHeader."No.");
        ProductionBOMLine.SetRange("Version Code", VersionCode);
        ProductionBOMLine.SetRange(Type, ProductionBOMLine.Type::"Production BOM");
        ProductionBOMLine.SetFilter("No.", '<>%1', '');
        if ProductionBOMLine.FindSet() then
            repeat
                TempProductionBOMHeader."No." := ProductionBOMLine."No.";
                if not TempProductionBOMHeader.Insert() then
                    Error(CircularRefInBOMErr, ProductionBOMLine."No.", ProductionBOMLine."Production BOM No.");

                NextVersionCode := VersionMgt.GetBOMVersion(ProductionBOMLine."No.", WorkDate(), true);
                if NextVersionCode <> '' then
                    CheckNextLevel := true
                else begin
                    ProductionBOMHeader.Get(ProductionBOMLine."No.");
                    CheckNextLevel := ProductionBOMHeader.Status = ProductionBOMHeader.Status::Certified;
                end;

                if CheckNextLevel then
                    CheckCircularReferencesInProductionBOM(TempProductionBOMHeader, NextVersionCode);

                TempProductionBOMHeader.Get(ProductionBOMLine."No.");
                TempProductionBOMHeader.Delete();
            until ProductionBOMLine.Next() = 0;
    end;

    local procedure CheckProcessOutputs(var ProdBOMHeader: Record "Production BOM Header"; VersionCode: Code[10])
    var
        FamilyLine: Record "Family Line";
    begin
        // PR3.60
        if (ProdBOMHeader."Mfg. BOM Type" = ProdBOMHeader."Mfg. BOM Type"::Process) and
           (ProdBOMHeader."Output Type" = ProdBOMHeader."Output Type"::Family)
        then
            with FamilyLine do begin
                SetRange("Family No.", ProdBOMHeader."No.");
                SetFilter("Item No.", '<>%1', '');
                if not Find('-') then
                    Error(Text37002001);
                SetRange("By-Product", false);
                if not Find('-') then
                    Error(Text37002002, FieldCaption("By-Product"));
                SetRange("By-Product");
                Find('-');
                repeat
                    TestField(Quantity);
                    TestField("Unit of Measure Code");
                    ProcessOrderMgmt.CheckFamilyLineUnitType(FamilyLine, VersionCode);
                until (Next = 0);
            end;
        // PR3.60
    end;
    
    [IntegrationEvent(false, false)]
    local procedure OnAfterCode(var ProductionBOMHeader: Record "Production BOM Header"; VersionCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterProdBomLineCheck(ProductionBOMLine: Record "Production BOM Line"; VersionCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOpenDialogWindow(var Window: Dialog; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessItems(var ProdBOMHeader: Record "Production BOM Header"; VersionCode: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateDialogWindow(var Item: Record Item; ItemCounter: Integer; NoOfItems: Integer; var Window: Dialog; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnProcessItemsOnAfterItemSetFilters(var Item: Record Item; var ProductionBOMHeader: Record "Production BOM Header")
    begin
    end;
}

