page 37002459 "N138 Settlement Wizard"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 09-10-2014, Initial Version
    // --------------------------------------------------------------------------------
    // TOM4237   , 02-10-2015, Correct decimal place property on Quantity to Settle
    // --------------------------------------------------------------------------------
    // TOM4340     07-10-2015  Correct page caption
    // --------------------------------------------------------------------------------
    // 
    // PRW19.00.01
    // P8006787, To-Increase, Jack Reynolds, 21 APR 16
    //   Fix issues with settlement and catch weight items
    // 
    // P8007168, To-Increase, Dayakar Battini, 08 JUN 16
    //  Trip Settlement Posting Issue
    // 
    // P8006916, To-Increase, Jack Reynolds, 31 AUG 16
    //   FOOD-TOM Separation
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects

    Caption = 'Settlement Wizard';
    PageType = NavigatePage;
    SourceTable = "Sales Shipment Line";

    layout
    {
        area(content)
        {
            group(Step)
            {
                Caption = 'General';
                InstructionalText = 'Use this wizard to settle the correct qty.';
                Visible = Step1Visible;
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item No.';
                    Editable = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(Qty2Settle; Qty2Settle)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Quantity to Settle';
                    DecimalPlaces = 0 : 5;

                    trigger OnValidate()
                    begin
                        if (Qty2Settle <= 0) or (Qty2Settle >= Quantity) then
                            Error(Text000);
                    end;
                }
                field(BackOrder; BackOrder)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Backorder';
                }
            }
            group(Step2)
            {
                InstructionalText = 'Press finish to post the settlement sales order';
                Visible = Step2Visible;
                field("''"; '')
                {
                    ApplicationArea = FOODBasic;
                    ShowCaption = false;
                }
            }
            group(Step3)
            {
                InstructionalText = 'Change Tracking information and finish the wizard to post the sales order';
                Visible = Step3Visible;
                field(Text001; Text001)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    ShowCaption = false;

                    trigger OnDrillDown()
                    begin
                        SalesLine.OpenItemTrackingLines;
                        FinishEnable := true; // P8006787
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        SalesLine.OpenItemTrackingLines;
                        FinishEnable := true; // P8006787
                    end;
                }
            }
            group(Step4)
            {
                InstructionalText = 'Enter alternate quantity and press finish to post the settlement sales order';
                Visible = Step4Visible;
                field(Quantity2; Quantity)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(Qty2Settle2; Qty2Settle)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Quantity to Settle';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                }
                field("+""Quantity (Alt.)"""; +"Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Alt. Quantity';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                }
                field(AltQty2Settle; AltQty2Settle)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Alt. Quantity to Settle';
                    DecimalPlaces = 0 : 5;

                    trigger OnValidate()
                    var
                        AltQtyManagement: Codeunit "Alt. Qty. Management";
                    begin
                        // P8006787
                        if (AltQty2Settle <= 0) or (AltQty2Settle >= "Quantity (Alt.)") then
                            Error(Text000);
                        AltQtyManagement.CheckTolerance(Item."No.", Text002, Round(Qty2Settle * "Qty. per Unit of Measure", 0.00001), AltQty2Settle);
                        FinishEnable := true; // P8006787
                    end;
                }
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
                    if (WizardStep = WizardStep::"1") then begin // P8006787
                        N138TripSettlementMgt.UndoShipment(Rec, Qty2Settle, PostingPossible);
                        Item.Get("No."); // P8006787
                    end;               // P8006787

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
                    SalesLine.Get(SalesLine."Document Type"::Order, "Order No.", "Order Line No.");
                    N138TripSettlementMgt.SetSettlementPosting(FromDeliveryTripNo);   // P8007168
                    N138TripSettlementMgt.PostSalesSettlementSlsLine(SalesLine, BackOrder, Qty2Settle, AltQty2Settle, "Bin Code"); // P8006787

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
    end;

    var
        Item: Record Item;
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
        Text000: Label 'Quantity not allowed';
        Qty2Settle: Decimal;
        N138TripSettlementMgt: Codeunit "N138 Trip Settlement Mgt.";
        SalesLine: Record "Sales Line";
        PostingPossible: Boolean;
        Text001: Label 'Change Tracking Information';
        BackOrder: Boolean;
        AltQty2Settle: Decimal;
        Text002: Label 'Alt. Quantity to Settle';
        FromDeliveryTripNo: Code[20];

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
                        FinishEnable := false; // P8006787
                    end;
                end;
            WizardStep::"2":
                begin
                    Step2Visible := Visible;
                    if Visible then begin

                        PostingPossible := false;
                        BackEnable := false;
                        NextEnable := false;
                        FinishEnable := true;
                    end;
                end;
            WizardStep::"3":
                begin
                    Step3Visible := Visible;
                    if Visible then begin
                        SalesLine.Get(SalesLine."Document Type"::Order, "Order No.", "Order Line No.");
                        BackEnable := false;
                        NextEnable := false;
                        FinishEnable := false; // P8006787
                    end;
                end;
            WizardStep::"4":
                begin
                    Step4Visible := Visible;
                    if Visible then begin
                        BackEnable := false;
                        NextEnable := false;
                        FinishEnable := false; // P8006787
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
                    Rec.Find;
                    if PostingPossible then
                        if Item."Catch Alternate Qtys." then // P8006787
                            WizardStep := WizardStep::"4"      // P8006787
                        else                                 // P8006787
                            WizardStep := WizardStep::"2"
                    else
                        WizardStep := WizardStep::"3";
                end;
            WizardStep::"3", WizardStep::"4": // P8006787
                WizardStep := WizardStep::"5";
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

    procedure SetSettlementPosting(DeliveryTripNo: Code[20])
    begin
        // P8007168
        FromDeliveryTripNo := DeliveryTripNo;
    end;
}

