report 37002477 "Generate Pre-Process Activity"
{
    // P8001082, Columbus IT, Rick Tweedle, 22 JUN 12
    //   Used to generate the Pre-Process activites based on the released Prod. Order Components
    // 
    // PRW10.0
    // P8008034, To-Increase, Jack Reynolds, 07 DEC 16
    //   Update missing captions
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Generate Pre-Process Activity';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem(ProdOrder; "Production Order")
        {
            DataItemTableView = WHERE(Status = CONST(Released));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Location Code";
            dataitem(ProdOrderLine; "Prod. Order Line")
            {
                DataItemLink = Status = FIELD(Status), "Prod. Order No." = FIELD("No.");
                DataItemTableView = SORTING(Status, "Prod. Order No.", "Line No.");
                PrintOnlyIfDetail = true;
                RequestFilterFields = "Item No.";
                dataitem(NormalProdOrderComp; "Prod. Order Component")
                {
                    DataItemLink = Status = FIELD(Status), "Prod. Order No." = FIELD("Prod. Order No."), "Prod. Order Line No." = FIELD("Line No.");
                    DataItemTableView = SORTING(Status, "Prod. Order No.", "Prod. Order Line No.", "Line No.") WHERE("Pre-Process Type Code" = FILTER(<> ''));
                    RequestFilterFields = "Pre-Process Type Code", "Item No.";

                    trigger OnAfterGetRecord()
                    begin
                        ProcessComponent(NormalProdOrderComp);
                    end;
                }
            }
            dataitem(SharedProdOrderComp; "Prod. Order Component")
            {
                DataItemLink = Status = FIELD(Status), "Prod. Order No." = FIELD("No.");
                DataItemTableView = SORTING(Status, "Prod. Order No.", "Prod. Order Line No.", "Line No.") WHERE("Pre-Process Type Code" = FILTER(<> ''), "Prod. Order Line No." = CONST(0));

                trigger OnAfterGetRecord()
                begin
                    ProcessComponent(SharedProdOrderComp);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                Cnt += 1;
                if GuiAllowed then
                    Window.Update(1, Round((Cnt / TotalCnt) * 10000, 1));
            end;

            trigger OnPostDataItem()
            begin
                if GuiAllowed then
                    Window.Close;
            end;

            trigger OnPreDataItem()
            begin
                if GuiAllowed then begin
                    Window.Open(Text001);
                    TotalCnt := Count;
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
                    field(ProcessDate; ProcessDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Process Date';
                        NotBlank = true;
                    }
                    field(CreateOrdersAs; CreateOrdersAs)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Blending Order Status';
                        OptionCaption = 'Simulated,Planned,Firm Planned,Released,Finished';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        ProcessDate := WorkDate;
        CreateOrdersAs := CreateOrdersAs::Released;
    end;

    trigger OnPostReport()
    begin
        TempBlendOrder.Reset;
        Cnt := 0;
        TotalCnt := TempBlendOrder.Count;
        if TotalCnt = 0 then begin
            if (CreatedActCount = 0) then
                Message(Text003)
            else
                Message(Text004, CreatedActCount);
            exit;
        end;

        if GuiAllowed then
            Window.Open(Text002);

        // Create blending orders
        TempBlendOrder.SetCurrentKey(
          "Item No.", "Variant Code", "Unit of Measure Code", "Replenishment Area Code", "Location Code", "Starting Date");
        if TempBlendOrder.Find('-') then
            repeat
                Cnt += 1;
                if GuiAllowed then
                    Window.Update(1, Round((Cnt / TotalCnt) * 10000, 1));

                PreProcessMgmt.CreateBlendingOrder(TempBlendOrder, CreateOrdersAs, PreProcOrder);

                case TempBlendOrder.Blending of
                    TempBlendOrder.Blending::"Per Order":
                        begin
                            Activity.Get(TempBlendOrder."No.");
                            Activity."Blending Order Status" := PreProcOrder.Status;
                            Activity."Blending Order No." := PreProcOrder."No.";
                            Activity.Modify;
                        end;
                    TempBlendOrder.Blending::"Per Item":
                        begin
                            Activity.MarkedOnly(true);
                            Activity.SetRange("Item No.", TempBlendOrder."Item No.");
                            Activity.SetRange("Variant Code", TempBlendOrder."Variant Code");
                            Activity.SetRange("Unit of Measure Code", TempBlendOrder."Unit of Measure Code");
                            Activity.SetRange("Replenishment Area Code", TempBlendOrder."Replenishment Area Code");
                            Activity.SetRange("Location Code", TempBlendOrder."Location Code");
                            Activity.SetRange("Starting Date", TempBlendOrder."Starting Date");
                            Activity.ModifyAll("Blending Order Status", PreProcOrder.Status, false);
                            Activity.ModifyAll("Blending Order No.", PreProcOrder."No.", false);
                        end;
                end;
                CreatedOrdCount += 1;
            until TempBlendOrder.Next = 0;

        if GuiAllowed then begin
            Window.Close;
            Message(Text005, CreatedActCount, CreatedOrdCount);
        end;
    end;

    trigger OnPreReport()
    begin
        Activity.SetCurrentKey(
          "Item No.", "Variant Code", "Unit of Measure Code", "Replenishment Area Code", "Location Code", "Starting Date");
        TempBlendOrder.SetCurrentKey(
          "Item No.", "Variant Code", "Unit of Measure Code", "Replenishment Area Code", "Location Code", "Starting Date");
    end;

    var
        Activity: Record "Pre-Process Activity";
        ActivityLine: Record "Pre-Process Activity Line";
        Item: Record Item;
        PreProcType: Record "Pre-Process Type";
        PreProcOrder: Record "Production Order";
        PreProcLine: Record "Prod. Order Line";
        ReplenArea: Record "Replenishment Area";
        PreProcArea: Record "Replenishment Area";
        TempBlendOrder: Record "Pre-Process Activity" temporary;
        ProcessDate: Date;
        CreateOrdersAs: Option Simulated,Planned,"Firm Planned",Released,Finished;
        Window: Dialog;
        Cnt: Integer;
        TotalCnt: Integer;
        CreatedActCount: Integer;
        CreatedOrdCount: Integer;
        Text001: Label 'Generating Pre-Process Activities @1@@@@@@@@';
        Text002: Label 'Generating Blending Orders @1@@@@@@@@';
        Text003: Label 'No Pre-Process Activities were created.';
        Text004: Label '%1 Pre-Process Activities were created.';
        Text005: Label '%1 Pre-Process Activities and %2 Blending Orders were created.';
        PreProcessMgmt: Codeunit "Pre-Process Management";

    local procedure ProcessComponent(var ProdOrderComp: Record "Prod. Order Component")
    var
        VersionMgmt: Codeunit VersionManagement;
        QtyToProcess: Decimal;
        AdjustedStartDate: Date;
        BOMNo: Code[20];
    begin
        with ProdOrderComp do begin
            // No replinishment area - thus no staging area > Look at the component, then line, then header
            if not ReplenArea.Get("Location Code", "Replenishment Area Code") then
                if not ReplenArea.Get(ProdOrderLine."Location Code", ProdOrderLine."Replenishment Area Code") then
                    if not ReplenArea.Get(ProdOrder."Location Code", ProdOrder."Replenishment Area Code") then
                        CurrReport.Skip;

            // Staging Area is required and setup must be complete
            ReplenArea.TestField("Pre-Process Repl. Area Code");
            PreProcArea.Get(ReplenArea."Location Code", ReplenArea."Pre-Process Repl. Area Code");
            PreProcArea.TestField("To Bin Code");
            PreProcArea.TestField("From Bin Code");

            // Quantity has already been processed or in processing
            QtyToProcess := GetQtyToPreProcess();
            if QtyToProcess <= 0 then
                CurrReport.Skip;

            // Use pre-processing leadtime to see if we need to start this activity - based on the Prod. Comp. Due Date
            AdjustedStartDate := "Due Date" - "Pre-Process Lead Time (Days)";
            if AdjustedStartDate > ProcessDate then
                CurrReport.Skip;

            // Create the pre-process activity
            LockTable;
            ActivityLine.LockTable;

            PreProcType.Get("Pre-Process Type Code");
            Activity.Init;
            Activity."No." := '';
            Activity.InitFromComponent(ProdOrderComp);
            Activity."Starting Date" := AdjustedStartDate;
            Activity."Due Date" := "Due Date";

            // If component item does not has a BOM then convert the pre-process act. into a non-blend activity
            if Activity.Blending <> Activity.Blending::" " then begin
                Item.Get("Item No.");
                BOMNo := Item.ProductionBOMNo("Variant Code", "Location Code");
                if (BOMNo = '') or (VersionMgmt.GetBOMVersion(BOMNo, AdjustedStartDate, true) = '') then begin
                    Activity.Blending := Activity.Blending::" ";
                    Activity."Auto Complete" := false;
                end;
            end;
            Activity.Insert(true);
            if not Activity.IsLotTracked() then
                ActivityLine.InsertRecord(Activity."No.", '');
            CreatedActCount += 1;

            case Activity.Blending of
                Activity.Blending::"Per Order":
                    begin
                        TempBlendOrder := Activity;
                        TempBlendOrder.Insert;
                    end;
                Activity.Blending::"Per Item":
                    begin
                        Activity.Mark(true);
                        TempBlendOrder.SetRange(Blending, Activity.Blending);
                        TempBlendOrder.SetRange("Item No.", Activity."Item No.");
                        TempBlendOrder.SetRange("Variant Code", Activity."Variant Code");
                        TempBlendOrder.SetRange("Unit of Measure Code", Activity."Unit of Measure Code");
                        TempBlendOrder.SetRange("Replenishment Area Code", Activity."Replenishment Area Code");
                        TempBlendOrder.SetRange("Location Code", Activity."Location Code");
                        TempBlendOrder.SetRange("Starting Date", Activity."Starting Date");
                        if not TempBlendOrder.FindFirst then begin
                            TempBlendOrder := Activity;
                            TempBlendOrder.Insert;
                        end else begin
                            TempBlendOrder.Quantity += Activity.Quantity;
                            TempBlendOrder."Quantity (Base)" += Activity."Quantity (Base)";
                            TempBlendOrder.Modify;
                        end;
                    end;
            end;
        end;
    end;
}

