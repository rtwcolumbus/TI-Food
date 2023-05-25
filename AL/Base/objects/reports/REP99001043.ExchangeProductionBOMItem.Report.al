report 99001043 "Exchange Production BOM Item"
{
    // PR1.00
    //   Make CreateNewVersion non-editable
    //   Use Initial Version Code from Process Setup
    //   Update Batch Quantity
    // 
    // PR2.00
    //   Remove transfer of record in BOM Quality table
    // 
    // PR4.00.05
    // P8000413A, VerticalSoft, Jack Reynolds, 02 APR 07
    //   Process 800 changes adapted for new code
    // 
    // PR4.00.06
    // P8000477A, VerticalSoft, Jack Reynolds, 30 MAY 07
    //   Fix problems with editable propert for Create New Version and Delete Exchanged Component
    //   Copoy Step code to exchanged BOM line
    // 
    // PRW15.00.01
    // P8000544A, VerticalSoft, Jack Reynolds, 15 NOV 07
    //   Fxi permission problem when creating new version and copying Prod. BOM Activity Cost records
    // 
    // PRW16.00.06
    // P8001065, Columbus IT, Jack Reynolds, 27 APR 12
    //   Restore ability to delete exchanged components
    // 
    // PRW17.00.01
    // P8001211, Columbus IT, Jack Reynolds, 20 SEP 13
    //   Fix problem with not all CF fields being copied to new line
    // 
    // PRW19.00.01
    // P8007106, To Increase, Jack Reynolds, 27 MAY 16
    //   Wrong batch quantity when not creating new version
    //
    // PRW118.03
    // P800144768, ToIncrease, Gangabhushan, 25 APR 22
    //   CS00220093 | Exchange Production BOM item Error 

    ApplicationArea = Manufacturing;
    Caption = 'Exchange Production BOM Item';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number);
            MaxIteration = 1;

            trigger OnPostDataItem()
            var
                ProdBOMHeader2: Record "Production BOM Header";
                FirstVersion: Boolean;
            begin
                ProcessSetup.Get; // PR1.00

                Window.Open(
                  Text004 +
                  Text005);

                Window.Update(1, FromBOMType);
                Window.Update(2, FromBOMNo);

                ProdBOMLine.SetCurrentKey(Type, "No.");
                ProdBOMLine.SetRange(Type, FromBOMType);
                ProdBOMLine.SetRange("No.", FromBOMNo);

                if ProdBOMLine.Find('+') then
                    repeat
                        FirstVersion := true;
                        ProdBOMHeader.Get(ProdBOMLine."Production BOM No.");
                        if ProdBOMLine."Version Code" <> '' then begin
                            ProdBOMVersionList.Get(
                              ProdBOMLine."Production BOM No.", ProdBOMLine."Version Code");
                            ProdBOMHeader.Status := ProdBOMVersionList.Status;
                            ProdBOMHeader2 := ProdBOMHeader;
                            ProdBOMHeader2."Unit of Measure Code" := ProdBOMVersionList."Unit of Measure Code";
                        end else begin
                            ProdBOMVersionList.SetRange("Production BOM No.");
                            ProdBOMVersionList."Version Code" := '';
                            ProdBOMHeader2 := ProdBOMHeader;
                        end;

                        if IsActiveBOMVersion(ProdBOMHeader, ProdBOMLine) then begin
                            Window.Update(3, ProdBOMLine."Production BOM No.");
                            if not CreateNewVersion then begin
                                if ProdBOMLine."Version Code" <> '' then begin
                                    ProdBOMVersionList.Status := ProdBOMVersionList.Status::"Under Development";
                                    ProdBOMVersionList.Modify();
                                    ProdBOMVersionList.Mark(true);
                                end else begin
                                    ProdBOMHeader.Status := ProdBOMHeader.Status::"Under Development";
                                    ProdBOMHeader.Modify();
                                    ProdBOMHeader.Mark(true);
                                end;
                            end else
                                if ProdBOMLine."Production BOM No." <> ProdBOMLine2."Production BOM No." then begin
                                    ProdBOMVersionList.SetRange("Production BOM No.", ProdBOMLine."Production BOM No.");

                                    if ProdBOMVersionList.Find('+') then
                                        ProdBOMVersionList."Version Code" := IncrementVersionNo(ProdBOMVersionList."Production BOM No.")
                                    else begin
                                        ProdBOMVersionList."Production BOM No." := ProdBOMLine."Production BOM No.";
                                        ProdBOMVersionList."Version Code" := ProcessSetup."Initial Version Code"; // PR1.00
                                    end;
                                    ProdBOMVersionList.Description := ProdBOMHeader2.Description;
                                    ProdBOMVersionList.Validate("Starting Date", StartingDate);
                                    ProdBOMVersionList."Unit of Measure Code" := ProdBOMHeader2."Unit of Measure Code";
                                    ProdBOMVersionList."Last Date Modified" := Today;
                                    ProdBOMVersionList.Status := ProdBOMVersionList.Status::New;
                                    if ProdBOMHeader2."Version Nos." <> '' then begin
                                        ProdBOMVersionList."No. Series" := ProdBOMHeader2."Version Nos.";
                                        ProdBOMVersionList."Version Code" := '';
                                        ProdBOMVersionList.Insert(true);
                                    end else
                                        ProdBOMVersionList.Insert();

                                    OnAfterProdBOMVersionListInsert(ProdBOMVersionList, ProdBOMHeader2);

                                    ProdBOMVersionList.Mark(true);
                                    ProdBOMLine3.Reset();
                                    ProdBOMLine3.SetRange("Production BOM No.", ProdBOMLine."Production BOM No.");
                                    ProdBOMLine3.SetRange("Version Code", ProdBOMLine."Version Code");
                                    if ProdBOMLine3.Find('-') then
                                        repeat
                                            if (ProdBOMLine.Type <> ProdBOMLine3.Type) or
                                               (ProdBOMLine."No." <> ProdBOMLine3."No.")
                                            then begin
                                                ProdBOMLine2 := ProdBOMLine3;
                                                ProdBOMLine2."Version Code" := ProdBOMVersionList."Version Code";
                                                ProdBOMLine2.Insert();
                                            end;
                                        until ProdBOMLine3.Next() = 0;
                                    // PR1.00 Begin
                                    ProdBOMEquipment.SetRange("Production Bom No.", ProdBOMLine."Production BOM No.");
                                    ProdBOMEquipment.SetRange("Version Code", ProdBOMLine."Version Code");
                                    if ProdBOMEquipment.Find('-') then
                                        repeat
                                            ProdBOMEquipment2 := ProdBOMEquipment;
                                            ProdBOMEquipment2."Version Code" := ProdBOMVersionList."Version Code";
                                            ProdBOMEquipment2.Insert;
                                        until ProdBOMEquipment.Next = 0;
                                    ProdBOMCost.SetRange("Production Bom No.", ProdBOMLine."Production BOM No.");
                                    ProdBOMCost.SetRange("Version Code", ProdBOMLine."Version Code");
                                    if ProdBOMCost.Find('-') then
                                        repeat
                                            ProdBOMCost2 := ProdBOMCost;
                                            ProdBOMCost2."Version Code" := ProdBOMVersionList."Version Code";
                                            ProdBOMCost2."Line No." := 0; // P8000544A
                                            ProdBOMCost2.Insert;
                                        until ProdBOMCost.Next = 0
                                    // PR1.00 End
                                    else
                                        FirstVersion := false;
                                end;

                            if (ToBOMNo <> '') and FirstVersion then
                                if CreateNewVersion then begin
                                    ProdBOMLine3.SetCurrentKey("Production BOM No.", "Version Code");
                                    ProdBOMLine3.SetRange(Type, FromBOMType);
                                    ProdBOMLine3.SetRange("No.", FromBOMNo);
                                    ProdBOMLine3.SetRange("Production BOM No.", ProdBOMLine."Production BOM No.");
                                    ProdBOMLine3.SetRange("Version Code", ProdBOMLine."Version Code");
                                    if ProdBOMLine3.Find('-') then
                                        repeat
                                            ProdBOMLine2 := ProdBOMLine3;
                                            ProdBOMLine2."Version Code" := ProdBOMVersionList."Version Code";
                                            ProdBOMLine2.Validate(Type, ToBOMType);
                                            ProdBOMLine2.Validate("No.", ToBOMNo);
                                            ProdBOMLine2.Validate("Batch Quantity", ProdBOMLine3."Batch Quantity" * QtyMultiply); // PR1.00, P8000413A
                                            ProdBOMLine2.Validate("Quantity per", ProdBOMLine3."Quantity per" * QtyMultiply);
                                            CopyP800Data(ProdBOMLine3, ProdBOMLine2); // P8001211
                                            if CopyRoutingLink then
                                                ProdBOMLine2.Validate("Routing Link Code", ProdBOMLine3."Routing Link Code");
                                            CopyPositionFields(ProdBOMLine2, ProdBOMLine3);
                                            ProdBOMLine2."Ending Date" := 0D;
                                            OnBeforeInsertNewProdBOMLine(ProdBOMLine2, ProdBOMLine3, QtyMultiply);
                                            ProdBOMLine2.Insert();
                                        until ProdBOMLine3.Next() = 0;
                                end else begin
                                    ProdBOMLine3.SetRange("Production BOM No.", ProdBOMLine."Production BOM No.");
                                    ProdBOMLine3.SetRange("Version Code", ProdBOMVersionList."Version Code");
                                    if not ProdBOMLine3.Find('+') then
                                        Clear(ProdBOMLine3);
                                    ProdBOMLine3."Line No." := ProdBOMLine3."Line No." + 10000;
                                    ProdBOMLine2 := ProdBOMLine;
                                    ProdBOMLine2."Version Code" := ProdBOMVersionList."Version Code";
                                    ProdBOMLine2.Validate(Type, ToBOMType);
                                    ProdBOMLine2.Validate("No.", ToBOMNo);
                                    ProdBOMLine2.Validate("Batch Quantity", ProdBOMLine."Batch Quantity" * QtyMultiply); // PR1.00, P8000413A, P8007106
                                    ProdBOMLine2.Validate("Quantity per", ProdBOMLine."Quantity per" * QtyMultiply);
                                    CopyP800Data(ProdBOMLine, ProdBOMLine2); // P8001211
                                    if CopyRoutingLink then
                                        ProdBOMLine2.Validate("Routing Link Code", ProdBOMLine."Routing Link Code");
                                    if not CreateNewVersion then
                                        ProdBOMLine2."Starting Date" := StartingDate;
                                    ProdBOMLine2."Ending Date" := 0D;
                                    if DeleteExcComp then begin
                                        ProdBOMLine2."Line No." := ProdBOMLine."Line No.";
                                        CopyPositionFields(ProdBOMLine2, ProdBOMLine);
                                        ProdBOMLine.Delete(true);
                                    end else begin
                                        ProdBOMLine2."Line No." := ProdBOMLine3."Line No.";
                                        CopyPositionFields(ProdBOMLine2, ProdBOMLine3);
                                        ProdBOMLine."Ending Date" := StartingDate - 1;
                                        ProdBOMLine.Modify();
                                    end;
                                    OnBeforeInsertNewProdBOMLine(ProdBOMLine2, ProdBOMLine3, QtyMultiply);
                                    ProdBOMLine2.Insert();
                                end;
                        end;
                    until ProdBOMLine.Next(-1) = 0;
            end;
        }
        dataitem(RecertifyLoop; "Integer")
        {
            DataItemTableView = SORTING(Number);
            MaxIteration = 1;

            trigger OnPreDataItem()
            begin
                OnRecertifyLoopOnBeforeOnPreDataItem(FromBOMType, FromBOMNo, ToBOMType, ToBOMNo, QtyMultiply, CreateNewVersion, StartingDate, Recertify, CopyRoutingLink, DeleteExcComp);
            end;

            trigger OnAfterGetRecord()
            begin
                if Recertify then begin
                    ProdBOMHeader.MarkedOnly(true);
                    if ProdBOMHeader.Find('-') then
                        repeat
                            ProdBOMHeader.Validate(Status, ProdBOMHeader.Status::Certified);
                            ProdBOMHeader.Modify();
                        until ProdBOMHeader.Next() = 0;

                    ProdBOMVersionList.SetRange("Production BOM No.");
                    ProdBOMVersionList.MarkedOnly(true);
                    if ProdBOMVersionList.Find('-') then
                        repeat
                            ProdBOMVersionList.Validate(Status, ProdBOMVersionList.Status::Certified);
                            ProdBOMVersionList.Modify();
                        until ProdBOMVersionList.Next() = 0;
                end;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    group(Exchange)
                    {
                        Caption = 'Exchange';
                        field(ExchangeType; FromBOMType)
                        {
                            ApplicationArea = Manufacturing;
                            Caption = 'Type';
                            ToolTip = 'Specifies what is to be exchanged here - Item or Production BOM.';

                            trigger OnValidate()
                            begin
                                FromBOMNo := '';
                            end;
                        }
                        field(ExchangeNo; FromBOMNo)
                        {
                            ApplicationArea = Manufacturing;
                            Caption = 'No.';
                            ToolTip = 'Specifies the number of the item.';

                            trigger OnLookup(var Text: Text): Boolean
                            var
                                IsHandled: Boolean;
                            begin
                                case FromBOMType of
                                    FromBOMType::Item:
                                        if PAGE.RunModal(0, Item) = ACTION::LookupOK then begin
                                            Text := Item."No.";
                                            exit(true);
                                        end;
                                    FromBOMType::"Production BOM":
                                        if PAGE.RunModal(0, ProdBOMHeader) = ACTION::LookupOK then begin
                                            Text := ProdBOMHeader."No.";
                                            exit(true);
                                        end;
                                    else
                                        OnLookupExchangeNo(FromBOMType, Text, IsHandled);
                                end;
                            end;

                            trigger OnValidate()
                            begin
                                if FromBOMType = FromBOMType::" " then
                                    Error(Text006);

                                case FromBOMType of
                                    FromBOMType::Item:
                                        Item.Get(FromBOMNo);
                                    FromBOMType::"Production BOM":
                                        ProdBOMHeader.Get(FromBOMNo);
                                end;
                            end;
                        }
                    }
                    group("With")
                    {
                        Caption = 'With';
                        field(WithType; ToBOMType)
                        {
                            ApplicationArea = Manufacturing;
                            Caption = 'Type';
                            ToolTip = 'Specifies your new selection that will replace what you selected in the Exchange Type field - Item or Production BOM.';

                            trigger OnValidate()
                            begin
                                ToBOMNo := '';
                            end;
                        }
                        field(WithNo; ToBOMNo)
                        {
                            ApplicationArea = Manufacturing;
                            Caption = 'No.';
                            ToolTip = 'Specifies the number of the item.';

                            trigger OnLookup(var Text: Text): Boolean
                            begin
                                case ToBOMType of
                                    ToBOMType::Item:
                                        if PAGE.RunModal(0, Item) = ACTION::LookupOK then begin
                                            Text := Item."No.";
                                            exit(true);
                                        end;
                                    ToBOMType::"Production BOM":
                                        if PAGE.RunModal(0, ProdBOMHeader) = ACTION::LookupOK then begin
                                            Text := ProdBOMHeader."No.";
                                            exit(true);
                                        end;
                                end;
                                exit(false);
                            end;

                            trigger OnValidate()
                            begin
                                if ToBOMType = ToBOMType::" " then
                                    Error(Text006);

                                case ToBOMType of
                                    ToBOMType::Item:
                                        Item.Get(ToBOMNo);
                                    ToBOMType::"Production BOM":
                                        ProdBOMHeader.Get(ToBOMNo);
                                end;
                            end;
                        }
                    }
                    field("Create New Version"; CreateNewVersion)
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Create New Version';
                        Editable = CreateNewVersionEditable;
                        ToolTip = 'Specifies if you want to make the exchange in a new version.';

                        trigger OnValidate()
                        begin
                            CreateNewVersionOnAfterValidat();
                        end;
                    }
                    field(MultiplyQtyWith; QtyMultiply)
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Multiply Qty. with';
                        DecimalPlaces = 0 : 5;
                        ToolTip = 'Specifies the value of a quantity change here. If the quantity is to remain the same, enter 1 here. If you enter 2, the new quantities doubled in comparison with original quantity.';
                    }
                    field(StartingDate; StartingDate)
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Starting Date';
                        ToolTip = 'Specifies the date from which these changes are to become valid.';
                    }
                    field(Recertify; Recertify)
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Recertify';
                        ToolTip = 'Specifies if you want the production BOM to be certified after the change.';
                    }
                    field(CopyRoutingLink; CopyRoutingLink)
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Copy Routing Link';
                        ToolTip = 'Specifies whether or not you want the routing link copied.';
                    }
                    field(CopyLotPref; CopyLotPref)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Copy Lot Preferences';
                    }
                    field("Delete Exchanged Component"; DeleteExcComp)
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Delete Exchanged Component';
                        Editable = DeleteExchangedComponentEditab;
                        ToolTip = 'Specifies whether you want the exchanged component deleted.';

                        trigger OnValidate()
                        begin
                            DeleteExcCompOnAfterValidate();
                        end;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            DeleteExchangedComponentEditab := true;
            CreateNewVersionEditable := true;
            CreateNewVersion := true;
            QtyMultiply := 1;
            StartingDate := WorkDate();

            OnAfterOnInitReport(CreateNewVersion, StartingDate, DeleteExcComp);
        end;

        trigger OnOpenPage()
        begin
            CreateNewVersionEditable := not DeleteExcComp;
            DeleteExchangedComponentEditab := not CreateNewVersion;
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        Recertify := true;
        CopyRoutingLink := true;
        CopyLotPref := true; // P8001211
    end;

    trigger OnPreReport()
    var
        FromItemTrackingCode, ToItemTrackingCode : Record "Item Tracking Code"; // P800144768
    begin
        CheckParameters();

        // P8001211
        if CopyLotPref and (FromBOMType = ToBOMType) and (FromBOMType = ToBOMType::Item) then begin
            if Item.Get(FromBOMNo) then
                if FromItemTrackingCode.Get(Item."Item Tracking Code") then; // P800144768
            if Item.Get(ToBOMNo) then
                if ToItemTrackingCode.Get(Item."Item Tracking Code") then; // P800144768
            CopyLotPref := FromItemTrackingCode."Lot Specific Tracking" and ToItemTrackingCode."Lot Specific Tracking"; // P800144768

            CommodityCostItem := Item."Commodity Cost Item";
        end else
            CopyLotPref := false;
        // P8001211
    end;

    var
        Item: Record Item;
        ProdBOMHeader: Record "Production BOM Header";
        ProdBOMVersionList: Record "Production BOM Version";
        ProdBOMLine: Record "Production BOM Line";
        ProdBOMLine2: Record "Production BOM Line";
        ProdBOMLine3: Record "Production BOM Line";
        Window: Dialog;
        FromBOMType: Enum "Production BOM Line Type";
        FromBOMNo: Code[20];
        ToBOMType: Enum "Production BOM Line Type";
        ToBOMNo: Code[20];
        QtyMultiply: Decimal;
        CreateNewVersion: Boolean;
        StartingDate: Date;
        Recertify: Boolean;
        CopyRoutingLink: Boolean;
        DeleteExcComp: Boolean;
        [InDataSet]
        CreateNewVersionEditable: Boolean;
        [InDataSet]
        DeleteExchangedComponentEditab: Boolean;        ProcessSetup: Record "Process Setup";
        ProdBOMEquipment: Record "Prod. BOM Equipment";
        ProdBOMEquipment2: Record "Prod. BOM Equipment";
        ProdBOMCost: Record "Prod. BOM Activity Cost";
        ProdBOMCost2: Record "Prod. BOM Activity Cost";
        CopyLotPref: Boolean;
        CommodityCostItem: Boolean;

        Text000: Label 'You must enter a Starting Date.';
        Text001: Label 'You must enter the Type to exchange.';
        Text002: Label 'You must enter the No. to exchange.';
        ItemBOMExchangeErr: Label 'You cannot exchange %1 %2 with %3 %4.', Comment = '%1 and %3 are strings (''Item'' or ''Production BOM''), %2 and %4 are either an Item No. or a Production BOM Header No. (Code[20])';
        Text004: Label 'Exchanging #1########## #2############\';
        Text005: Label 'Production BOM No.      #3############';
        Text006: Label 'Type must be entered.';

    local procedure CheckParameters()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckParameters(StartingDate, FromBOMType, FromBOMNo, ToBOMType, ToBOMNo, IsHandled);
        If IsHandled then
            exit;

        if StartingDate = 0D then
            Error(Text000);

        if FromBOMType = FromBOMType::" " then
            Error(Text001);

        if FromBOMNo = '' then
            Error(Text002);

        if (FromBOMType = ToBOMType) and (FromBOMNo = ToBOMNo) then
            Error(ItemBOMExchangeErr, FromBOMType, FromBOMNo, ToBOMType, ToBOMNo);
    end;

    local procedure CreateNewVersionOnAfterValidat()
    begin
        CreateNewVersionEditable := not DeleteExcComp;
        DeleteExchangedComponentEditab := not CreateNewVersion;
    end;

    local procedure DeleteExcCompOnAfterValidate()
    begin
        CreateNewVersionEditable := not DeleteExcComp;
        DeleteExchangedComponentEditab := not CreateNewVersion;
    end;

    local procedure IsActiveBOMVersion(ProdBOMHeader: Record "Production BOM Header"; ProdBOMLine: Record "Production BOM Line"): Boolean
    var
        VersionManagement: Codeunit VersionManagement;
    begin
        if ProdBOMHeader.Status = ProdBOMHeader.Status::Closed then
            exit(false);

        exit(ProdBOMLine."Version Code" = VersionManagement.GetBOMVersion(ProdBOMLine."Production BOM No.", StartingDate, true));
    end;

    local procedure IncrementVersionNo(ProductionBOMNo: Code[20]) Result: Code[20]
    var
        ProductionBOMVersion: Record "Production BOM Version";
    begin
        ProductionBOMVersion.SetRange("Production BOM No.", ProductionBOMNo);
        if ProductionBOMVersion.FindLast() then begin
            Result := IncStr(ProductionBOMVersion."Version Code");
            ProductionBOMVersion.SetRange("Version Code", Result);
            while not ProductionBOMVersion.IsEmpty() do begin
                Result := IncStr(Result);
                if Result = '' then
                    exit(Result);
                ProductionBOMVersion.SetRange("Version Code", Result);
            end;
        end;
    end;

    local procedure CopyPositionFields(var ProdBOMLineCopyTo: Record "Production BOM Line"; ProdBOMLineCopyFrom: Record "Production BOM Line")
    begin
        if (ProdBOMLineCopyTo.Type <> ProdBOMLineCopyTo.Type::Item) or (ProdBOMLineCopyFrom.Type <> ProdBOMLineCopyFrom.Type::Item) then
            exit;
        ProdBOMLineCopyTo.Validate(Position, ProdBOMLineCopyFrom.Position);
        ProdBOMLineCopyTo.Validate("Position 2", ProdBOMLineCopyFrom."Position 2");
        ProdBOMLineCopyTo.Validate("Position 3", ProdBOMLineCopyFrom."Position 3");

        OnAfterCopyPositionFields(ProdBOMLineCopyTo, ProdBOMLineCopyFrom);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyPositionFields(var ProdBOMLineCopyTo: Record "Production BOM Line"; ProdBOMLineCopyFrom: Record "Production BOM Line")
    begin
    end;

    procedure CopyP800Data(FromBOMLine: Record "Production BOM Line"; var ToBOMLine: Record "Production BOM Line")
    var
        LotAgeFilter: Record "Lot Age Filter";
        LotAgeFilter2: Record "Lot Age Filter";
        LotSpecFilter: Record "Lot Specification Filter";
        LotSpecFilter2: Record "Lot Specification Filter";
    begin
        // P8001211
        ToBOMLine."Yield % (Weight)" := FromBOMLine."Yield % (Weight)";
        ToBOMLine."Yield % (Volume)" := FromBOMLine."Yield % (Volume)";
        ToBOMLine."Step Code" := FromBOMLine."Step Code";
        if CommodityCostItem then
            ToBOMLine."Commodity Class Code" := FromBOMLine."Commodity Class Code";
        ToBOMLine."Pre-Process Type Code" := FromBOMLine."Pre-Process Type Code";
        ToBOMLine."Pre-Process Lead Time (Days)" := FromBOMLine."Pre-Process Lead Time (Days)";

        if CopyLotPref then begin
            LotAgeFilter.SetRange("Table ID", DATABASE::"Production BOM Line");
            LotAgeFilter.SetRange(ID, FromBOMLine."Production BOM No.");
            LotAgeFilter.SetRange("ID 2", FromBOMLine."Version Code");
            LotAgeFilter.SetRange("Line No.", FromBOMLine."Line No.");
            if LotAgeFilter.FindSet then
                repeat
                    LotAgeFilter2 := LotAgeFilter;
                    LotAgeFilter2."ID 2" := ToBOMLine."Version Code";
                    LotAgeFilter2."Line No." := ToBOMLine."Line No.";
                    LotAgeFilter2.Insert;
                until LotAgeFilter.Next = 0;

            LotSpecFilter.SetRange("Table ID", DATABASE::"Production BOM Line");
            LotSpecFilter.SetRange(ID, FromBOMLine."Production BOM No.");
            LotSpecFilter.SetRange("ID 2", FromBOMLine."Version Code");
            LotSpecFilter.SetRange("Line No.", FromBOMLine."Line No.");
            if LotSpecFilter.FindSet then
                repeat
                    LotSpecFilter2 := LotSpecFilter;
                    LotSpecFilter2."ID 2" := ToBOMLine."Version Code";
                    LotSpecFilter2."Line No." := ToBOMLine."Line No.";
                    LotSpecFilter2.Insert;
                until LotSpecFilter.Next = 0;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterProdBOMVersionListInsert(var ProductionBOMVersion: Record "Production BOM Version"; ProductionBOMHeader: Record "Production BOM Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertNewProdBOMLine(var ProductionBOMLine: Record "Production BOM Line"; var FromProductionBOMLine: Record "Production BOM Line"; QtyMultiply: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLookupExchangeNo(LineType: Enum "Production BOM Line Type"; LookupText: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRecertifyLoopOnBeforeOnPreDataItem(FromBOMType: Enum "Production BOM Line Type"; FromBOMNo: Code[20]; ToBOMType: Enum "Production BOM Line Type"; ToBOMNo: Code[20]; QtyMultiply: Decimal; CreateNewVersion: Boolean; StartingDate: Date; Recertify: Boolean; CopyRoutingLink: Boolean; DeleteExcComp: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckParameters(StartingDate: Date; FromBOMType: Enum "Production BOM Line Type"; FromBOMNo: Code[20]; ToBOMType: Enum "Production BOM Line Type"; ToBOMNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterOnInitReport(var CreateNewVersion: Boolean; var StartingDate: Date; var DeleteExcComp: Boolean)
    begin
    end;
}

