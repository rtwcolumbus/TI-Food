page 37002659 "N138 ChangeSource Line Wizard"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 09-10-2014, Initial Version
    // --------------------------------------------------------------------------------
    // TOM4219     05-10-2105  Cleanup change line wizard
    // --------------------------------------------------------------------------------
    // 
    // PRW19.00.01
    // P8007412, To-Increase, Dayakar Battini, 29 JUN 16
    //   Zero Qty Shipment line handling.
    // 
    // P8006916, To-Increase, Jack Reynolds, 31 AUG 16
    //   FOOD-TOM Separation
    // 
    // P8007827, To-Increase, Dayakar Battini, 11 OCT 16
    //   Change UOM for Substituted Item
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 16 JAN 17
    //   Correct misspellings
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects

    Caption = 'Change Sales Line Wizard';
    PageType = NavigatePage;

    layout
    {
        area(content)
        {
            group(Step)
            {
                InstructionalText = 'Choose the appropriate action for the selected line.';
                Visible = Step1Visible;
                field(WizardAction; WizardAction)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Action';
                    OptionCaption = 'Change Quantity,Substitute Item';
                }
            }
            group(Step2)
            {
                Visible = Step2Visible;
                field(SourceQty1; SourceQty)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Original Quantity';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                }
                field(NewQuantity; NewQuantity)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'New Quantity';
                    DecimalPlaces = 0 : 5;
                }
            }
            group(Step3)
            {
                Visible = Step3Visible;
                field(SourceItem; SourceItem)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Original Item';
                    Editable = false;
                }
                field(SourceQty2; SourceQty)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Original Quantity';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                }
                field(NewItem; NewItem)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Substitute Item';
                    TableRelation = Item."No.";

                    trigger OnValidate()
                    begin
                        // P8007827
                        NewUOM := '';
                        SubstituteQuantity := 0;
                        ValidateNewQty;
                    end;
                }
                field(NewUOM; NewUOM)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Substitute Unit of Measure';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ItemUnitOfMeasure: Record "Item Unit of Measure";
                        ItemUnitOfMeasureList: Page "Item Units of Measure";
                    begin
                        // P8007827
                        if NewItem = '' then
                            exit;

                        ItemUnitOfMeasure.Reset;
                        ItemUnitOfMeasure.SetRange("Item No.", NewItem);
                        ItemUnitOfMeasureList.SetTableView(ItemUnitOfMeasure);
                        if (Text <> '') then begin
                            ItemUnitOfMeasure.SetFilter(Code, Text);
                            if ItemUnitOfMeasure.Find('-') then
                                ItemUnitOfMeasureList.SetRecord(ItemUnitOfMeasure);
                        end;
                        ItemUnitOfMeasure.Reset;
                        ItemUnitOfMeasureList.LookupMode(true);
                        if (ItemUnitOfMeasureList.RunModal <> ACTION::LookupOK) then
                            exit(false);
                        ItemUnitOfMeasureList.GetRecord(ItemUnitOfMeasure);
                        Text := ItemUnitOfMeasure.Code;
                        NewUOM := Text;
                        ValidateNewUOM;
                        exit(true);
                        // P8007827
                    end;

                    trigger OnValidate()
                    begin
                        // P8007827
                        SubstituteQuantity := 0;
                        ValidateNewUOM;
                    end;
                }
                field(SubstituteQuantity; SubstituteQuantity)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Substitute Quantity';
                    DecimalPlaces = 0 : 5;
                }
            }
            group(Step4)
            {
                Visible = Step4Visible;
            }
            group(Step5)
            {
                Visible = Step5Visible;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Back)
            {
                ApplicationArea = FOODBasic;
                Caption = '&Back';
                Enabled = BackEnable;
                Image = PreviousRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    ShowStep(false);
                    PerformPrevStep();
                    ShowStep(true);
                    CurrPage.Update(true)
                end;
            }
            action(Next)
            {
                ApplicationArea = FOODBasic;
                Caption = '&Next';
                Enabled = NextEnable;
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    ShowStep(false);
                    PerformNextStep();
                    ShowStep(true);
                    CurrPage.Update(true);
                end;
            }
            action(Finish)
            {
                ApplicationArea = FOODBasic;
                Caption = '&Finish';
                Enabled = FinishEnable;
                Image = Approve;
                InFooterBar = true;

                trigger OnAction()
                begin
                    case WizardAction of
                        WizardAction::"Change Quantity":
                            ChangeSourceDocWizard.ChangeQuantity(Source, NewQuantity);
                        WizardAction::"Substitute Item":
                            ChangeSourceDocWizard.SubstituteItem(Source, NewItem, SubstituteQuantity, NewUOM);   // P8007518
                    end;

                    IsFinished := true;

                    CurrPage.Close;
                end;
            }
        }
    }

    trigger OnInit()
    begin
        Step1Visible := true;
        NextEnable := true;
    end;

    trigger OnOpenPage()
    begin
        ShowStep(true);
        CurrPage.Update(false);

        ChangeSourceDocWizard.GetSourceUOM(Source, NewItem, NewUOM);  // P8007827
    end;

    var
        [InDataSet]
        Step1Visible: Boolean;
        [InDataSet]
        Step2Visible: Boolean;
        [InDataSet]
        Step3Visible: Boolean;
        [InDataSet]
        Step4Visible: Boolean;
        [InDataSet]
        Step5Visible: Boolean;
        [InDataSet]
        BackEnable: Boolean;
        [InDataSet]
        FinishEnable: Boolean;
        [InDataSet]
        NextEnable: Boolean;
        WizardStep: Option "1","2","3","4","5";
        IsFinished: Boolean;
        WizardAction: Option "Change Quantity","Substitute Item";
        NewQuantity: Decimal;
        SubstituteQuantity: Decimal;
        NewItem: Code[20];
        ChangeSourceDocWizard: Codeunit "N138 Change Source Doc Wizard";
        Source: Variant;
        SourceItem: Code[20];
        SourceQty: Decimal;
        NewUOM: Code[10];
        ItemUnitofMeasure: Record "Item Unit of Measure";

    local procedure ShowStep(Visible: Boolean)
    begin
        case
        WizardStep of
            WizardStep::"1":
                begin
                    Step1Visible := Visible;
                    if Visible then begin
                        BackEnable := false;
                        NextEnable := true;
                        FinishEnable := false;
                    end;
                end;
            WizardStep::"2":
                begin
                    Step2Visible := Visible;
                    if Visible then begin
                        BackEnable := true;
                        NextEnable := false;
                        FinishEnable := true;
                    end;
                end;
            WizardStep::"3":
                begin
                    Step3Visible := Visible;
                    if Visible then begin
                        BackEnable := true;
                        NextEnable := false;
                        FinishEnable := true;
                    end;
                end;
            WizardStep::"4":
                begin
                    Step4Visible := Visible;
                    if Visible then begin
                        BackEnable := true;
                        NextEnable := false;
                        FinishEnable := false;
                    end;
                end;
            WizardStep::"5":
                begin
                    Step5Visible := Visible;
                    if Visible then begin
                        BackEnable := true;
                        NextEnable := false;
                        FinishEnable := true;
                    end;
                end;
        end;
    end;

    local procedure PerformNextStep()
    begin
        case WizardStep of
            WizardStep::"1":
                begin
                    case WizardAction of
                        WizardAction::"Change Quantity":
                            WizardStep := WizardStep::"2";
                        WizardAction::"Substitute Item":
                            WizardStep := WizardStep::"3";
                        else
                            WizardStep := WizardStep::"1";
                    end;
                end;
            WizardStep::"3":
                WizardStep := WizardStep::"5"
            else
                WizardStep := WizardStep + 1;
        end;
    end;

    local procedure PerformPrevStep()
    begin
        case WizardStep of
            WizardStep::"3":
                WizardStep := WizardStep::"1";
            WizardStep::"4":
                WizardStep := WizardStep::"1";
            WizardStep::"5":
                WizardStep := WizardStep::"3";
            else
                WizardStep := WizardStep - 1;
        end;
    end;

    procedure Finished(): Boolean
    begin
        exit(IsFinished);
    end;

    procedure Init(CurrentSourceItem: Code[20]; CurrentSourceQty: Decimal; CurrentNewQuantity: Decimal; SourceDoc: Variant; "Action": Option)
    begin
        SourceItem := CurrentSourceItem; // TOM4219
        SourceQty := CurrentSourceQty;
        NewQuantity := CurrentNewQuantity;
        SubstituteQuantity := SourceQty - NewQuantity; // TOM4219
        Source := SourceDoc;
        WizardAction := Action;
    end;

    local procedure ValidateNewQty()
    var
        SourceUOM: Code[10];
    begin
        // P8007827
        if NewItem = '' then
            NewUOM := ''
        else
            SubstituteQuantity := ChangeSourceDocWizard.GetNewUOMQty(Source, SourceUOM, NewItem, NewUOM);
    end;

    local procedure ValidateNewUOM()
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        // P8007827
        if (NewUOM <> '') then
            ItemUnitOfMeasure.Get(NewItem, NewUOM);
        ValidateNewQty;
    end;
}

