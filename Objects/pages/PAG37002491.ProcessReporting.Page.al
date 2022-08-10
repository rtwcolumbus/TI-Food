page 37002491 "Process Reporting"
{
    // PR1.20
    //   Record and post consumption and output for Process orders
    // 
    // PR2.00.02
    //   Fix glue property on Output and Consumption buttons
    // 
    // PR3.10
    //   New Production Order table
    // 
    // PR3.70
    //   Fix glue property for output label
    // 
    // PR4.00.02
    // P8000316A, VerticalSoft, Jack Reynolds, 31 MAR 06
    //   Add support for deleting and refreshing journal lines
    // 
    // PRW16.00.02
    // P8000785, VerticalSoft, Rick Tweedle, 05 MAR 10
    //   Changes to code to make it transformation tool work
    // P8000785, VerticalSoft, Rick Tweedle, 05 MAR 10
    //   Created page based on form version - with amendment to make it RTC compatible
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001149, Columbus IT, Don Bresee, 25 APR 13
    //   Use lookup mode for Create Order page
    // 
    // PRW17.00.01
    // P8001163, Columbus IT, Jack Reynolds, 30 MAY 13
    //   Fix problem with editing sub-pages
    // 
    // PRW18.00.01
    // P8001385, Columbus IT, Jack Reynolds, 08 MAY 15
    //   Fix problem deleting output and consumption journal lines
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Process Reporting';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;
    SourceTable = "Production Order";
    SourceTableTemporary = true;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(Control37002000)
            {
                //ShowCaption = false;
                Caption = 'Settings';

                group(Control37002016)
                {
                    ShowCaption = false;
                    field(OrderNo; ProcessOrder)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Process Order No.';
                        LookupPageID = "Process Orders";
                        TableRelation = "Production Order"."No." WHERE(Status = CONST(Released),
                                                                    "Order Type" = CONST(Process));

                        trigger OnValidate()
                        begin
                            if ProcessOrder <> '' then begin// P8000316A, P8001231
                                ProdOrder.Get(ProdOrder.Status::Released, ProcessOrder);
                                ShiftCode := ProdOrder."Work Shift Code"; // P8001231
                            end else begin             // P8000316A, P8001231
                                Clear(ProdOrder);        // P8000316A
                                ShiftCode := ''; // P8001231
                            end;               // P8001231
                            ProcessOrderOnAfterValidate;
                        end;
                    }
                    field(ProcessDate; ProcessDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Production Date';
                        NotBlank = true;

                        trigger OnValidate()
                        begin
                            ProcessDateOnAfterValidate;
                        end;
                    }
                    field(ShiftCode; ShiftCode)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Shift Code';
                        TableRelation = "Work Shift";

                        trigger OnValidate()
                        begin
                            // P8001231
                            P800ProdOrderMgt.UpdateShiftCode(ProcessOrder, ShiftCode,
                              true, true,
                              ProcessSetup."Process Output Template", ProcessSetup."Process Output Batch",
                              ProcessSetup."Process Consumption Template", ProcessSetup."Process Consumption Batch");
                        end;
                    }
                }
                group(Control37002003)
                {
                    ShowCaption = false;
                    field(InputItem; DisplayNoDesc(ProdOrder."Input Item No.", ProdOrder.InputItemDescription))
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Input Item';
                        Editable = false;
                    }
                    field(OutputItem; DisplayNoDesc(ProdOrder."Source No.", ProdOrder.OutputItemDescription))
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Output Item';
                        Editable = false;

                    }
                }
            }

            part(Consumption; "Process Reporting Consumption")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Consumption';
                Editable = ConsumptionEditable;
                SubPageLink = "Order No." = FIELD("No.");
                SubPageView = WHERE("Order Type" = CONST(Production));
            }
            part(Output; "Process Reporting Output")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Output';
                Editable = OutputEditable;
                SubPageLink = "Order No." = FIELD("No.");
                SubPageView = WHERE("Order Type" = CONST(Production));
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Functions)
            {
                Caption = 'Functions';
                action("Create Order")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Create Order';
                    Image = CreateDocument;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ShortCutKey = 'F7';

                    trigger OnAction()
                    begin
                        CreateOrder;
                    end;
                }
                action("Refresh Lines")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Refresh Lines';
                    Image = RefreshLines;
                    Promoted = true;
                    PromotedOnly = true;

                    trigger OnAction()
                    begin
                        // P8000316A
                        if ProcessOrder <> '' then begin
                            P800ProdOrderMgt.DeleteOutputAndConsumpJnl(ProcessOrder,
                              //TRUE,TRUE, // P800xxx
                              ProcessSetup."Process Output Template", ProcessSetup."Process Output Batch",
                              ProcessSetup."Process Consumption Template", ProcessSetup."Process Consumption Batch");

                            P800ProdOrderMgt.FillOutputAndConsumpJnl(ProcessOrder, ProcessDate, ShiftCode, // P8001231
                              true, true,
                              ProcessSetup."Process Output Template", ProcessSetup."Process Output Batch",
                              ProcessSetup."Process Consumption Template", ProcessSetup."Process Consumption Batch");

                            SetFormProperties(true);
                        end;
                    end;
                }
            }
            action(bnPost)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Post';
                Ellipsis = true;
                Enabled = bnPostEnable;
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    if not P800ProdOrderMgt.PostOrder(ProcessOrder, ProcessDate, // P8000316A
                      true, true, // P8000316A
                      ProcessSetup."Process Output Template", ProcessSetup."Process Output Batch",
                      ProcessSetup."Process Consumption Template", ProcessSetup."Process Consumption Batch")
                    then    // P8000316A
                        exit; // P8000316A

                    ProcessOrder := '';
                    xProcessOrder := ''; // P8000316A
                    SetFormProperties(false);
                end;
            }
        }
    }

    trigger OnInit()
    begin
        ProcessDate := WorkDate;
        ShiftCode := ''; // P8001231
        ProcessSetup.Get;
        ProcessSetup.TestField("Process Output Template");
        ProcessSetup.TestField("Process Output Batch");
        ProcessSetup.TestField("Process Consumption Template");
        ProcessSetup.TestField("Process Consumption Batch");
    end;

    trigger OnOpenPage()
    begin
        /*  // P8000785
        CurrPage.Output.PAGE.SetFilter('');
        CurrPage.Output.PAGE.UpdateForm;
        CurrPage.Consumption.PAGE.SetFilter('');
        CurrPage.Consumption.PAGE.UpdateForm;
        */  // P8000785

    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        CheckAndDeleteLines(xProcessOrder); // P8000316A
        exit(true);                         // P8000316A
    end;

    var
        ProcessSetup: Record "Process Setup";
        ProdOrder: Record "Production Order";
        P800ProdOrderMgt: Codeunit "Process 800 Prod. Order Mgt.";
        ProcessOrder: Code[20];
        xProcessOrder: Code[20];
        ProcessDate: Date;
        Text000: Label 'Consumption for Order %1';
        Text001: Label 'Output for Order %1';
        Text003: Label 'Delete journal lines?';
        ShiftCode: Code[10];
        [InDataSet]
        OutputLabelVisible: Boolean;
        [InDataSet]
        ConsumptionLabelVisible: Boolean;
        [InDataSet]
        OutputEditable: Boolean;
        [InDataSet]
        ConsumptionEditable: Boolean;
        [InDataSet]
        bnOutputEnable: Boolean;
        [InDataSet]
        bnConsumptionEnable: Boolean;
        [InDataSet]
        bnPostEnable: Boolean;
        Text004: Label 'Input Item';
        Text005: Label 'Output Item';

    procedure SetFormProperties(Enabled: Boolean)
    begin
        /*  // P8000785
        IF Enabled THEN BEGIN
          CurrPage.Output.PAGE.SetFilter(ProcessOrder);
          CurrPage.Consumption.PAGE.SetFilter(ProcessOrder);
        END ELSE BEGIN
          CurrPage.Output.PAGE.SetFilter('');
          CurrPage.Consumption.PAGE.SetFilter('');
        END;
        
        CurrForm.OutputLabel.VISIBLE(Enabled);
        CurrForm.Output.EDITABLE(Enabled);
        CurrForm.ConsumptionLabel.VISIBLE(Enabled);
        CurrForm.Consumption.EDITABLE(Enabled);
        CurrForm.bnOutput.ENABLED(Enabled); // PR2.00
        CurrForm.bnConsumption.ENABLED(Enabled); // PR2.00
        CurrForm.bnPost.ENABLED(Enabled);
        */  // P8000785
        // P8000785
        OutputLabelVisible := Enabled;
        OutputEditable := Enabled;
        ConsumptionLabelVisible := Enabled;
        ConsumptionEditable := Enabled;
        bnOutputEnable := Enabled; // PR2.00
        bnConsumptionEnable := Enabled; // PR2.00
        bnPostEnable := Enabled;
        // P8000785
        CurrPage.Output.PAGE.UpdateForm;
        CurrPage.Consumption.PAGE.UpdateForm;
        CurrPage.Update;

    end;

    procedure CheckAndDeleteLines(OrderNo: Code[20])
    var
        DeleteLines: Boolean;
    begin
        // P8000316A
        if OrderNo = '' then
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
            P800ProdOrderMgt.DeleteOutputAndConsumpJnl(OrderNo,
              //TRUE,TRUE, // P8001385
              ProcessSetup."Process Output Template", ProcessSetup."Process Output Batch",
              ProcessSetup."Process Consumption Template", ProcessSetup."Process Consumption Batch");

        exit;
    end;

    local procedure ProcessOrderOnAfterValidate()
    begin
        GetTmpRec;  // P8000785
        // P8000316A
        if xProcessOrder <> ProcessOrder then
            CheckAndDeleteLines(xProcessOrder);
        xProcessOrder := ProcessOrder;
        // P8000316A

        if (ProdOrder."No." = ProcessOrder) and (ProcessOrder <> '') then // P8000316A
            P800ProdOrderMgt.FillOutputAndConsumpJnl(ProcessOrder, ProcessDate, ShiftCode, // P8001231
              true, true, // P8000316A
              ProcessSetup."Process Output Template", ProcessSetup."Process Output Batch",
              ProcessSetup."Process Consumption Template", ProcessSetup."Process Consumption Batch");

        SetFormProperties(ProcessOrder <> ''); // P8000316A
    end;

    local procedure ProcessDateOnAfterValidate()
    begin
        P800ProdOrderMgt.UpdatePostingDate(ProcessOrder, ProcessDate,
          true, true, // P8000316A
          ProcessSetup."Process Output Template", ProcessSetup."Process Output Batch",
          ProcessSetup."Process Consumption Template", ProcessSetup."Process Consumption Batch");
    end;

    procedure CreateOrder()
    var
        rec: Record "Production Order";
        CreateOrder: Page "Process Production Order";
        PopulateJnl: Boolean;
    begin
        CreateOrder.LookupMode(true); // P8001149
        CreateOrder.RunModal;
        if CreateOrder.GetProdOrder(rec, PopulateJnl) then
            if PopulateJnl then begin
                ProdOrder := rec;
                GetTmpRec;                 // P8000785
                ProcessOrder := ProdOrder."No.";
                CheckAndDeleteLines(xProcessOrder); // P8000316A
                xProcessOrder := ProcessOrder;      // P8000316A
                P800ProdOrderMgt.FillOutputAndConsumpJnl(ProcessOrder, ProcessDate, ShiftCode, // P8001231
                  true, true, // P8000316A
                  ProcessSetup."Process Output Template", ProcessSetup."Process Output Batch",
                  ProcessSetup."Process Consumption Template", ProcessSetup."Process Consumption Batch");
                SetFormProperties(true);
                CurrPage.Update;
            end;
    end;

    procedure GetTmpRec()
    begin
        // P8000785
        if ProdOrder."No." <> '' then begin
            if not Get(Status::Released, ProcessOrder) then begin
                Init;
                "No." := ProdOrder."No.";
                Status := ProdOrder.Status;
                Insert;
            end;
        end else
            Clear(Rec);
        // P800785
    end;

    local procedure DisplayNoDesc(No: Text; Description: Text): Text
    begin
        if No = '' then
            exit
        else
            exit(No + ' - ' + Description);
    end;
}

