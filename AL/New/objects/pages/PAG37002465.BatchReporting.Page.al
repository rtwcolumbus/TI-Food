page 37002465 "Batch Reporting"
{
    // PRW115.00.03
    // P800125286, To-Increase, Gangabhushan, 28 JUN 21
    //   CS00172322 | SSM - Batch Reporting - Records are disappearing in Consumption / Output sub pages 

    ApplicationArea = FOODBasic;
    Caption = 'Batch Reporting';
    DataCaptionExpression = '';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Listplus;
    SaveValues = true;
    SourceTable = "Prod. Order Line";
    SourceTableTemporary = true;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(Orders)
            {
                ShowCaption = false;
                group(Input)
                {
                    ShowCaption = false;
                    field(BatchOrder; BatchOrder)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Order No.';
                        Editable = BatchOrderEditable;
                        TableRelation = "Production Order"."No." WHERE(Status = CONST(Released), Suborder = CONST(false));

                        trigger OnValidate()
                        begin
                            if BatchOrder <> '' then begin
                                ProdOrder.Get(ProdOrder.Status::Released, BatchOrder);
                                ProdOrder.TestField(Suborder, false);
                                ShiftCode := ProdOrder."Work Shift Code";
                            end else
                                ShiftCode := '';

                            if xBatchOrder <> BatchOrder then
                                CheckAndDeleteLines(xBatchOrder);
                            xBatchOrder := BatchOrder;

                            InitializeOrder;
                        end;
                    }
                    field(BatchDate; BatchDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Production Date';
                        NotBlank = true;

                        trigger OnValidate()
                        begin
                            P800ProdOrderMgt.UpdatePostingDate(BatchOrder, BatchDate, CalcOutput, CalcConsumption,
                              ProcessSetup."Batch Output Template", ProcessSetup."Batch Output Batch",
                              ProcessSetup."Batch Consumption Template", ProcessSetup."Batch Consumption Batch");
                        end;
                    }
                    field(ShiftCode; ShiftCode)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Shift Code';
                        TableRelation = "Work Shift";

                        trigger OnValidate()
                        begin
                            P800ProdOrderMgt.UpdateShiftCode(BatchOrder, ShiftCode,
                              CalcOutput, CalcConsumption,
                              ProcessSetup."Batch Output Template", ProcessSetup."Batch Output Batch",
                              ProcessSetup."Batch Consumption Template", ProcessSetup."Batch Consumption Batch");
                        end;
                    }
                    field(CalcOutput; CalcOutput)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Output';
                        // P800125286
                        trigger Onvalidate()
                        begin
                            if CalcOutput then
                                RecalculateOrder(true, false);
                        end;
                        // P800125286
                    }
                    field(CalcConsumption; CalcConsumption)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Consumption';
                        // P800125286
                        trigger Onvalidate()
                        begin
                            if CalcConsumption then
                                RecalculateOrder(false, true);
                        end;
                        // P800125286
                    }
                }
                repeater(OrderLines)
                {
                    Editable = false;
                    ShowCaption = false;
                    field("Prod. Order No."; "Prod. Order No.")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field(Description; Description)
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Equipment Code"; "Equipment Code")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Batch No."; Priority)
                    {
                        ApplicationArea = FOODBasic;
                        BlankZero = true;
                        Caption = 'Batch No.';
                    }
                }

            }
            part(Output; "Batch Reporting Output")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Output';
                SubPageLink = "Order No." = FIELD("Prod. Order No."), "Order Line No." = FIELD("Line No.");
                SubPageView = WHERE("Order Type" = CONST(Production));
                Visible = CalcOutput;
            }
            part(Consumption; "Batch Reporting Consumption")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Consumption';
                SubPageLink = "Order No." = FIELD("Prod. Order No."), "Order Line No." = FIELD("Line No.");
                SubPageView = WHERE("Order Type" = CONST(Production));
                Visible = CalcConsumption;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Balance)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Balance Intermediate';
                Image = Balance;

                trigger OnAction()
                begin
                    BalanceIntermediate;
                end;
            }
            action(RefreshLines)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Refresh Lines';
                Image = RefreshLines;

                trigger OnAction()
                begin
                    if BatchOrder <> '' then begin
                        P800ProdOrderMgt.DeleteOutputAndConsumpJnl(BatchOrder,
                          ProcessSetup."Batch Output Template", ProcessSetup."Batch Output Batch",
                          ProcessSetup."Batch Consumption Template", ProcessSetup."Batch Consumption Batch");

                        P800ProdOrderMgt.FillOutputAndConsumpJnl(BatchOrder, BatchDate, ShiftCode, CalcOutput, CalcConsumption,
                          ProcessSetup."Batch Output Template", ProcessSetup."Batch Output Batch",
                          ProcessSetup."Batch Consumption Template", ProcessSetup."Batch Consumption Batch");
                    end;
                end;
            }
            action(Post)
            {
                ApplicationArea = FOODBasic;
                Caption = '&Post';
                Ellipsis = true;
                Enabled = ((BatchOrder <> '') and (CalcOutput or CalcConsumption));
                Image = Post;

                trigger OnAction()
                var
                    P800ProdOrderMgt: Codeunit "Process 800 Prod. Order Mgt.";
                begin
                    if not P800ProdOrderMgt.PostOrder(BatchOrder, BatchDate, CalcOutput, CalcConsumption,
                      ProcessSetup."Batch Output Template", ProcessSetup."Batch Output Batch",
                      ProcessSetup."Batch Consumption Template", ProcessSetup."Batch Consumption Batch")
                    then
                        exit;

                    if OrderNo <> '' then begin
                        Posted := true;
                        CurrPage.Close;
                    end else begin
                        BatchOrder := '';
                        xBatchOrder := '';
                        PopulateTempTable;
                        SetFormProperties;
                    end;
                end;
            }
        }
        area(Promoted)
        {
            actionref(Balance_Promoted; Balance)
            {
            }
            actionref(RefreshLines_Promoted; RefreshLines)
            {
            }
            actionref(Post_Promoted; Post)
            {
            }
        }
    }

    trigger OnInit()
    begin
        BatchOrderEditable := true;
        ProcessSetup.Get;
        ProcessSetup.TestField("Batch Output Template");
        ProcessSetup.TestField("Batch Output Batch");
        ProcessSetup.TestField("Batch Consumption Template");
        ProcessSetup.TestField("Batch Consumption Batch");
    end;

    trigger OnOpenPage()
    begin
        if BatchDate = 0D then begin
            CalcOutput := true;
            CalcConsumption := true;
        end;
        BatchDate := WorkDate;
        BatchOrder := '';
        ShiftCode := '';

        CurrPage.Output.PAGE.UpdateForm;
        CurrPage.Consumption.PAGE.UpdateForm;

        if OrderNo <> '' then begin
            BatchOrder := OrderNo;
            xBatchOrder := OrderNo;
            ProdOrder.Get(ProdOrder.Status::Released, BatchOrder);
            InitializeOrder;
        end;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        CheckAndDeleteLines(xBatchOrder);
        exit(true);
    end;

    var
        ProcessSetup: Record "Process Setup";
        ProdOrder: Record "Production Order";
        P800ProdOrderMgt: Codeunit "Process 800 Prod. Order Mgt.";
        BatchOrder: Code[20];
        xBatchOrder: Code[20];
        BatchDate: Date;

        ShiftCode: Code[10];
        BalancingMethod: Option ,"Output Matches Consumption","Consumption Matches Output";

        Text003: Label 'Delete journal lines?';
        CalcConsumption: Boolean;
        CalcOutput: Boolean;
        OrderNo: Code[20];
        BatchNo: Integer;
        [InDataSet]
        BatchOrderEditable: Boolean;
        [InDataSet]
        Posted: Boolean;

    procedure SetFormProperties()
    begin
        CurrPage.Update(false);
    end;

    procedure BalanceIntermediate()
    var
        BalanceIntermediate: Codeunit "Balance Intermediate";
    begin
        BalanceIntermediate.BalanceIntermediate(BatchOrder, BalancingMethod, BatchDate);
    end;

    procedure CheckAndDeleteLines(ProdOrderNo: Code[20])
    var
        DeleteLines: Boolean;
    begin
        if (ProdOrderNo = '') or ((OrderNo <> '') and Posted) then
            exit;

        case ProcessSetup."Batch Reporting Line Retention" of
            ProcessSetup."Batch Reporting Line Retention"::Save:
                ;
            ProcessSetup."Batch Reporting Line Retention"::Prompt:
                if Confirm(Text003, false) then
                    DeleteLines := true;
            ProcessSetup."Batch Reporting Line Retention"::Delete:
                DeleteLines := true;
        end;

        if DeleteLines then
            P800ProdOrderMgt.DeleteOutputAndConsumpJnl(ProdOrderNo,
              ProcessSetup."Batch Output Template", ProcessSetup."Batch Output Batch",
              ProcessSetup."Batch Consumption Template", ProcessSetup."Batch Consumption Batch");
    end;

    procedure PopulateTempTable()
    var
        ProdOrder2: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
    begin
        Reset;
        DeleteAll;
        if BatchOrder <> '' then begin
            ProdOrder2.Reset;
            if ProdOrder."Order Type" = ProdOrder."Order Type"::Batch then begin
                ProdOrder2.SetCurrentKey(Status, "Batch Prod. Order No.", "No.");
                ProdOrder2.SetRange(Status, Status::Released);
                ProdOrder2.SetRange("Batch Prod. Order No.", BatchOrder);
            end else begin
                ProdOrder2.SetRange(Status, Status::Released);
                ProdOrder2.SetRange("No.", BatchOrder);
            end;
            ProdOrder2.FindSet;
            repeat
                if ProdOrder2."Family Process Order" then begin
                    Init;
                    Status := ProdOrder2.Status;
                    "Prod. Order No." := ProdOrder2."No.";
                    "Line No." := 0;
                    Description := ProdOrder2.Description;
                    "Equipment Code" := ProdOrder2."Equipment Code";
                    Insert;
                end else begin
                    ProdOrderLine.SetRange(Status, ProdOrder2.Status);
                    ProdOrderLine.SetRange("Prod. Order No.", ProdOrder2."No.");
                    BatchNo := 0;
                    if ProdOrderLine.FindSet then
                        repeat
                            Rec := ProdOrderLine;
                            if ProdOrder2."Batch Order" then begin
                                BatchNo += 1;
                                Priority := BatchNo; // Using Priority for Batch No.
                            end else
                                Priority := 0;
                            Insert;
                        until ProdOrderLine.Next = 0;
                end;
            until ProdOrder2.Next = 0;
            FindFirst;
        end;
    end;

    procedure InitializeOrder()
    begin
        RecalculateOrder(CalcOutput, CalcConsumption); // P800125286
        PopulateTempTable;
        SetFormProperties;
        BalancingMethod := ProcessSetup."Batch Reporting Balancing";
    end;

    // P800125286
    local procedure RecalculateOrder(pCalcOutPut: boolean; pCalcConsumption: Boolean)
    begin
        if BatchOrder <> '' then
            P800ProdOrderMgt.FillOutputAndConsumpJnl(BatchOrder, BatchDate, ShiftCode, pCalcOutput, pCalcConsumption,
              ProcessSetup."Batch Output Template", ProcessSetup."Batch Output Batch",
              ProcessSetup."Batch Consumption Template", ProcessSetup."Batch Consumption Batch");

    end;
    // P800125286
    procedure SetOrder(ProdOrderNo: Code[20])
    begin
        OrderNo := ProdOrderNo;
        BatchOrderEditable := false;
    end;
}
