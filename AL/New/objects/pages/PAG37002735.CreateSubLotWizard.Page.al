page 37002735 "Create Sub-Lot Wizard"
{
    // PRW118.1
    // P800129613, To Increase, Jack Reynolds, 20 SEP 21
    //   Creatre Sub-Lot Wizard
    // 
    // PRW121.0
    // P800155629, To-Increase, Jack Reynolds, 03 NOV 22
    //   Add support for Mandatory Variant

    ApplicationArea = FOODBasic;
    Caption = 'Create Sub-Lot Wizard';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = NavigatePage;
    SourceTable = "Sub-Lot Buffer";
    SourceTableTemporary = true;
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            group(StepLOT)
            {
                InstructionalText = 'Specify the lot that should be sub-lotted.';
                ShowCaption = false;
                Visible = CurrentStep = 'LOT';

                field(ItemNo; Rec."Item No.")
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        if Rec."Item No." <> xRec."Item No." then
                            SetEnabledActions();
                    end;
                }
                field(ItemDescription; Rec."Item Description")
                {
                    ApplicationArea = FOODBasic;
                }
                field(VariantCode; Rec."Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Enabled = Rec.ItemHasVariants;
                    ShowMandatory = Rec.VariantIsMandatory; // P800155629
                }
                field(LotNo; Rec."Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        SetEnabledActions();
                    end;
                }
            }
            group(StepLOCATION)
            {
                InstructionalText = 'Specify the location (and optionally a bin and container) where the sub-lotting occurs.';
                ShowCaption = false;
                Visible = CurrentStep = 'LOCATION';

                field(StepCaptionLOCATION; Rec.LotSummary())
                {
                    ApplicationArea = FOODBasic;
                    ShowCaption = false;
                    Style = Strong;
                }
                field(LocationLocation; Rec."Location Code")
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = true;
                }
                field(LocationBin; Rec."Bin Code")
                {
                    ApplicationArea = FOODBasic;
                    Enabled = Rec.BinMandatory;
                }
                field(LocationContainer; Rec."Container License Plate")
                {
                    ApplicationArea = FOODBasic;
                    Visible = ContainerFilterEnabled;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(Rec.LookupContainerLicensePlate(Text));
                    end;
                }
            }
            group(StepQUANTITY)
            {
                InstructionalText = 'Specify the quantities to reclass to create the sub-lot.';
                ShowCaption = false;
                Visible = CurrentStep = 'QUANTITY';

                field(StepCaptionQUANTITY; Rec.Join(Rec.LotSummary(), Rec.LocationSummary()))
                {
                    ApplicationArea = FOODBasic;
                    ShowCaption = false;
                    Style = Strong;
                }
                part(ReclassQuantity; "Create Sub-Lot Quantity")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Quantity to Reclass';
                }
            }
            group(StepQUALITY)
            {
                InstructionalText = 'Specify what to do with the open quality control activities for the lot.';
                ShowCaption = false;
                Visible = CurrentStep = 'QUALITY';

                field(StepCaptionQUALITY; Rec.LotSummary())
                {
                    ApplicationArea = FOODBasic;
                    ShowCaption = false;
                    Style = Strong;
                }
                part(QualityControl; "Create Sub-Lot Quality")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Open Quality Control Activities';
                }
            }
            group(StepSUBLOTNO)
            {
                InstructionalText = 'Specify the sub-lot number (and optionally change the lot status code for the sub-lot).  Also specify the necessary fields for the journal lines that will be created and posted for the reclassification.';
                ShowCaption = false;
                Visible = CurrentStep = 'SUBLOTNO';

                field(StepCaptionSUBLOTNO; Rec.LotSummary())
                {
                    ApplicationArea = FOODBasic;
                    ShowCaption = false;
                    Style = Strong;
                }

                group(GroupSubLot)
                {
                    Caption = 'Sub-Lot';

                    field(SubLotNo; Rec."Sub-Lot No.")
                    {
                        ApplicationArea = FOODBasic;
                        ShowMandatory = true;

                        trigger OnAssistEdit()
                        begin
                            Rec.AssignLotNo();
                        end;
                    }
                    field(LotStatusCode; Rec."Lot Status Code")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = LotStatusEditable;
                    }
                }
                group(GroupPosting)
                {
                    Caption = 'Posting';
                    field(DocumentNo; Rec."Document No.")
                    {
                        ApplicationArea = FOODBasic;
                        ShowMandatory = true;

                        trigger OnValidate()
                        begin
                            SetEnabledActions();
                        end;
                    }
                    field(PostingDate; Rec."Posting Date")
                    {
                        ApplicationArea = FOODBasic;
                        ShowMandatory = true;
                    }
                    field(ReasonCode; Rec."Reason Code")
                    {
                        ApplicationArea = FOODBasic;
                    }
                }
            }
            group(StepLABEL)
            {
                InstructionalText = 'Specify the number of labels to be printed for the sub-lot.';
                ShowCaption = false;
                Visible = CurrentStep = 'LABEL';

                field(StepCaptionLABEL; Rec.Join(Rec.LotSummary(), Rec.LocationSummary()))
                {
                    ApplicationArea = FOODBasic;
                    ShowCaption = false;
                    Style = Strong;
                }
                part(Labels; "Create Sub-Lot Labels")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Labels';
                }
            }
            group(StepFINISH)
            {
                InstructionalText = 'Finish creation of the sub-lot.';
                ShowCaption = false;
                Visible = CurrentStep = 'FINISH';

                group(Finish0)
                {
                    ShowCaption = false;
                    Visible = (not QualityVisible) and (not LabelsVisible);

                    field(Finish0Lot; Rec.LotSummary())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Lot';
                        Editable = false;
                    }
                    field(Finish0Location; Rec.LocationSummary())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Location';
                        Editable = false;
                    }
                    field(Finish0Quantity; ReclassQuantity.QuantitySummary())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Quantity to Reclass';
                        Editable = false;
                    }
                    field(Finish0SubLot; Rec.SubLotSummary())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Sub-Lot';
                        Editable = false;
                    }
                    field(Finish0Posting; Rec.PostingSummary())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Posting';
                        Editable = false;
                    }
                }
                group(Finish1)
                {
                    ShowCaption = false;
                    Visible = QualityVisible and (not LabelsVisible);

                    field(Finish1Lot; Rec.LotSummary())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Lot';
                        Editable = false;
                    }
                    field(Finish1Location; Rec.LocationSummary())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Location';
                        Editable = false;
                    }
                    field(Finish1Quantity; ReclassQuantity.QuantitySummary())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Quantity to Reclass';
                        Editable = false;
                    }
                    field(Finish1Quality; QualityControl.QualitySummary())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Quality Control Activities';
                        Editable = false;
                    }
                    field(Finish1SubLot; Rec.SubLotSummary())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Sub-Lot';
                        Editable = false;
                    }
                    field(Finish1Posting; Rec.PostingSummary())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Posting';
                        Editable = false;
                    }
                }
                group(Finish2)
                {
                    ShowCaption = false;
                    Visible = (not QualityVisible) and LabelsVisible;

                    field(Finish2Lot; Rec.LotSummary())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Lot';
                        Editable = false;
                    }
                    field(Finish2Location; Rec.LocationSummary())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Location';
                        Editable = false;
                    }
                    field(Finish2Quantity; ReclassQuantity.QuantitySummary())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Quantity to Reclass';
                        Editable = false;
                    }
                    field(Finish2SubLot; Rec.SubLotSummary())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Sub-Lot';
                        Editable = false;
                    }
                    field(Finish2Posting; Rec.PostingSummary())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Posting';
                        Editable = false;
                    }
                    field(Finish2Label; ReclassQuantity.LabelSummary())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'No. of Labels';
                        Editable = false;
                    }
                }
                group(Finish3)
                {
                    ShowCaption = false;
                    Visible = QualityVisible and LabelsVisible;

                    field(Finish3Lot; Rec.LotSummary())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Lot';
                        Editable = false;
                    }
                    field(Finish3Location; Rec.LocationSummary())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Location';
                        Editable = false;
                    }
                    field(Finish3Quantity; ReclassQuantity.QuantitySummary())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Quantity to Reclass';
                        Editable = false;
                    }
                    field(Finish3Quality; QualityControl.QualitySummary())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Quality Control Activities';
                        Editable = false;
                    }
                    field(Finish3SubLot; Rec.SubLotSummary())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Sub-Lot';
                        Editable = false;
                    }
                    field(Finish3Posting; Rec.PostingSummary())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Posting';
                        Editable = false;
                    }
                    field(Finish3Label; ReclassQuantity.LabelSummary())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'No. of Labels';
                        Editable = false;
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Back)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Back';
                Enabled = BackEnabled;
                InFooterBar = true;

                trigger OnAction()
                begin
                    SetStep(-1);
                end;
            }
            action(Next)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Next';
                Enabled = NextEnabled;
                InFooterBar = true;

                trigger OnAction()
                begin
                    SetStep(1);
                end;
            }
            action(Finish)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Finish';
                Enabled = FinishEnabled;
                InFooterBar = true;

                trigger OnAction()
                var
                    SubLotManagement: Codeunit "Sub-Lot Management";
                begin
                    SubLotManagement.CreateSubLot(Rec, ReclassQuantity, QualityControl);
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        ReclassQuantity, QualityControl : Record "Sub-Lot Buffer" temporary;
        BackEnabled, NextEnabled, FinishEnabled : Boolean;
        QualityVisible, LabelsVisible : Boolean;
        ContainerFilterEnabled, LotStatusEditable : Boolean;
        Steps: List of [Code[20]];
        CurrentStep: Code[20];
        ErrNotAvailable: Label 'Lot "%1" is not avalable at the specified location.';
        ErrNoReclassQuantity: Label 'No "%1" has been specified.';
        ErrMustCopyQC: Label 'At least one quality control activity must be copied to the sub-lot.';

    trigger OnInit()
    begin
        InitializeSteps();
        CurrentStep := 'LOT';
        Rec.Insert(true);
        ContainerFilterEnabled := Rec.ContainersEnabled;
    end;

    trigger OnOpenPage()
    begin
        if not Rec.Get() then
            Rec.Insert(true);

        SetEnabledActions();
    end;

    local procedure InitializeSteps()
    begin
        Steps.Add('LOT');
        Steps.Add('LOCATION');
        Steps.Add('QUANTITY');
        Steps.Add('SUBLOTNO');
        Steps.Add('FINISH');
    end;

    procedure SetSource(SourceRec: Variant)
    var
        SourceRecRef: RecordRef;
        Item: Record Item;
        LotNoInfo: Record "Lot No. Information";
    begin
        SourceRecRef.GetTable(SourceRec);
        begin
            case SourceRecRef.Number of
                Database::"Lot No. Information":
                    begin
                        LotNoInfo := SourceRec;
                        Rec.Validate("Item No.", LotNoInfo."Item No.");
                        Rec.Validate("Variant Code", LotNoInfo."Variant Code");
                        Rec.Validate("Lot No.", LotNoInfo."Lot No.");
                        Rec.Modify();

                        ValidateLot();

                        Steps.Remove('LOT');
                        CurrentStep := 'LOCATION';
                    end;
                Database::Item:
                    begin
                        Item := SourceRec;
                        Rec.Validate("Item No.", Item."No.");
                        Rec.Modify();
                    end;
            end;
        end;
    end;

    local procedure SetEnabledActions()
    var
        StepIndex: Integer;
    begin
        StepIndex := Steps.IndexOf(CurrentStep);
        BackEnabled := StepIndex > 1;
        case CurrentStep of
            'LOT':
                NextEnabled := Rec."Lot No." <> '';
            'SUBLOTNO':
                NextEnabled := Rec."Document No." <> '';
            else
                NextEnabled := StepIndex < Steps.Count;
        end;
        FinishEnabled := StepIndex = Steps.Count;
    end;

    local procedure SetStep(Increment: Integer)
    var
        StepIndex: Integer;
    begin
        if Increment > 0 then begin
            ValidateLot();
            ValidateLocation();
            ValidateReclassQuantity();
            ValidateQualityControl();
        end;

        StepIndex := Steps.IndexOf(CurrentStep);
        CurrentStep := Steps.Get(StepIndex + Increment);
        if Increment > 0 then begin
            SetReclassQuantity();
            SetQualityControl();
            SetSubLotNo();
            SetLabel();
        end;

        SetEnabledActions();
    end;

    local procedure ValidateLot()
    var
        InventorySetup: Record "Inventory Setup";
        SubLotManagement: Codeunit "Sub-Lot Management";
    begin
        if CurrentStep <> 'LOT' then
            exit;

        SubLotManagement.GetOpenQualityControl(Rec, QualityControl);
        QualityControl.Reset();
        if not QualityControl.FindFirst() then begin
            Steps.Remove('QUALITY');
            QualityVisible := false;
        end else begin
            if not Steps.Contains('QUALITY') then
                Steps.Insert(Steps.IndexOf('SUBLOTNO'), 'QUALITY');
            QualityVisible := true;
        end;

        LotStatusEditable := true;
        if Rec."Lot Status Code" <> '' then begin
            InventorySetup.Get();
            LotStatusEditable := Rec."Lot Status Code" <> InventorySetup."Quarantine Lot Status";
        end;
    end;

    local procedure ValidateLocation()
    var
        SubLotManagement: Codeunit "Sub-Lot Management";
    begin
        if CurrentStep <> 'LOCATION' then
            exit;

        SubLotManagement.GetReclassQuantity(Rec, ReclassQuantity);
        ReclassQuantity.Reset();
        if not ReclassQuantity.FindFirst() then
            Error(ErrNotAvailable, Rec."Lot No.");
    end;

    local procedure SetReclassQuantity()
    begin
        if CurrentStep <> 'QUANTITY' then
            exit;

        CurrPage.ReclassQuantity.Page.SetSource(Rec, ReclassQuantity);
    end;

    local procedure ValidateReclassQuantity()
    begin
        if CurrentStep <> 'QUANTITY' then
            exit;

        CurrPage.ReclassQuantity.Page.GetSource(ReclassQuantity);
        ReclassQuantity.Reset();
        ReclassQuantity.SetFilter("Quantity to Reclass", '>0');
        if ReclassQuantity.IsEmpty() then
            Error(ErrNoReclassQuantity, Rec.FieldCaption("Quantity to Reclass"));

        ReclassQuantity.SetFilter("Label Code", '<>%1', '');
        if ReclassQuantity.IsEmpty() then begin
            Steps.Remove('LABEL');
            LabelsVisible := false;
        end else begin
            ReclassQuantity.Reset();
            if not Steps.Contains('LABEL') then
                Steps.Insert(Steps.IndexOf('FINISH'), 'LABEL');
            LabelsVisible := true;
        end;
    end;

    local procedure SetQualityControl()
    begin
        if CurrentStep <> 'QUALITY' then
            exit;

        CurrPage.QualityControl.Page.SetSource(QualityControl);
    end;

    local procedure ValidateQualityControl()
    var
        InventorySetup: Record "Inventory Setup";
        QualityControlHeader: Record "Quality Control Header";
        MustCopy: Boolean;
    begin
        if CurrentStep <> 'QUALITY' then
            exit;

        CurrPage.QualityControl.Page.GetSource(QualityControl);
        QualityControl.Reset();
        QualityControl.SetRange("Copy to Sub-lot", true);
        if QualityControl.IsEmpty() then begin
            InventorySetup.Get();
            if Rec."Lot Status Code" = InventorySetup."Quarantine Lot Status" then
                MustCopy := true
            else begin
                QualityControlHeader.SetRange("Item No.", Rec."Item No.");
                QualityControlHeader.SetRange("Variant Code", Rec."Variant Code");
                QualityControlHeader.SetRange("Lot No.", Rec."Lot No.");
                QualityControlHeader.SetFilter(Status, '%1|%2', QualityControlHeader.Status::Pass, QualityControlHeader.Status::Fail);
                MustCopy := QualityControlHeader.IsEmpty();
            end;
        end;
        QualityControl.Reset();
        if MustCopy then
            Error(ErrMustCopyQC);
    end;

    local procedure SetSubLotNo()
    var
        NoSeriesMgmt: Codeunit NoSeriesManagement;
    begin
        if CurrentStep <> 'SUBLOTNO' then
            exit;

        Rec.Validate("Sub-Lot No.");
        if Rec."Posting Date" = 0D then
            Rec."Posting Date" := WorkDate();

        if (Rec.DocumentNoSeries <> '') and (Rec."Document No." = '') then
            Rec."Document No." := NoSeriesMgmt.GetNextNo(Rec.DocumentNoSeries, Rec."Posting Date", true);
    end;

    local procedure SetLabel()
    begin
        if CurrentStep <> 'LABEL' then
            exit;

        CurrPage.Labels.Page.SetSource(Rec, ReclassQuantity);
    end;
}
