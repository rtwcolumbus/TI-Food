report 37002764 "Prod. Replenishment/Move List"
{
    // PR5.00
    // P8000494A, VerticalSoft, Don Bresee, 18 JUL 07
    //   Add Production Bins/Replenishment
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add 1-Doc Whse Logic
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 27 APR 10
    //   RTC Reporting Upgrade
    // 
    // PRW16.00.04
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // PRW16.00.06
    // P8001034, Columbus IT, Jack Reynolds, 10 FEB 12
    //   Change codeunit for Warehouse Employee functions
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // P8001082, Columbus IT, Don Bresee, 23 JAN 13
    //   Add Pre-Process functionality
    // 
    // PRW17.10
    // P8001231, Columbus IT, Jack Reynolds, 22 OCT 13
    //   Add support for Shift Code
    // 
    // PRW17.10.02
    // P8001276, Columbus IT, Jack Reynolds, 03 FEB 14
    //   Allow filtering of Prod. Replenishment/Move List by replenishment area
    // 
    // PRW17.10.02
    // P8001278, Columbus IT, Jack Reynolds, 04 FEB 14
    //   Allow move list reports to suggest receiving and/or output bins
    // 
    // PRW17.10.03
    // P8001345, Columbus IT, Jack Reynolds, 26 AUG 14
    //   Fix problem with order quantities not displayed
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // P8007749, To-Increase, Jack Reynolds, 07 DEC 16
    //   Item Category/Product Group
    // 
    // PRW110.0.02
    // P80050507, To-Increase, Dayakar Battini, 19 DEC 17
    //   Add PageBreak based on Replenishment Type
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    DefaultRenderingLayout = StandardRDLCLayout;

    ApplicationArea = FOODBasic;
    Caption = 'Prod. Replenishment/Move List';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Item Category Code";

            trigger OnPreDataItem()
            begin
                // P8000631A
                ItemFilters.Copy(Item);

                CurrReport.Break;
            end;
        }
        dataitem("Replenishment Area"; "Replenishment Area")
        {
            RequestFilterFields = "Code";

            trigger OnPreDataItem()
            begin
                // P8001276
                ReplenishmentAreaFilter := GetFilters;
                if ReplenishmentAreaFilter <> '' then
                    ReplenishmentAreaFilter := TableCaption + ' - ' + ReplenishmentAreaFilter;
                ReplenishmentArea.Copy("Replenishment Area");
                ReplenishmentArea.SetRange("Location Code", LocationCode);
                ReplenishmentArea."Location Code" := LocationCode;

                CurrReport.Break;
            end;
        }
        dataitem(ItemTypeLoop; "Integer")
        {
            DataItemTableView = SORTING(Number);
            PrintOnlyIfDetail = true;
            column(ItemTypeLoopRec; Format(Number))
            {
            }
            column(SuggestPicks; SuggestPicks)
            {
            }
            dataitem(PageHeader; "Integer")
            {
                DataItemTableView = SORTING(Number);
                MaxIteration = 1;
                PrintOnlyIfDetail = true;
                column(GetReportTitle1; GetReportTitle1())
                {
                }
                column(GetReportTitle2; GetReportTitle2())
                {
                }
                column(STRLocationCodeName; StrSubstNo('%1 - %2', Location.Code, Location.Name))
                {
                }
                column(ReplenishmentAreaFilter; ReplenishmentAreaFilter)
                {
                }
                column(PageHeaderHeader; 'PageHeader')
                {
                }
                column(PageHeaderRec; Format(Number))
                {
                }
                dataitem(ItemLoop; "Integer")
                {
                    DataItemTableView = SORTING(Number);
                    PrintOnlyIfDetail = true;
                    column(ItemLoopRec; Format(Number))
                    {
                    }
                    dataitem(ItemBinLoop; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        column(CurrItemNo; CurrItem."No.")
                        {
                        }
                        column(CurrItemDesc; CurrItem.Description)
                        {
                        }
                        column(CurrUOMCode; CurrUOMCode)
                        {
                        }
                        column(CurrQty; CurrQty)
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(QtyAvailBase; QtyAvailBase)
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(CurrQtyBase; CurrQtyBase)
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(ReplQtyBase; ReplQtyBase)
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(ReplQty; ReplQty)
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(CurrItemBaseUOM; CurrItem."Base Unit of Measure")
                        {
                        }
                        column(CurrBinCode; CurrBin.Code)
                        {
                        }
                        column(ItemBinLoopHeader; 'ItemBinLoop')
                        {
                        }
                        column(ItemBinLoopRec; Format(Number))
                        {
                        }
                        column(NumItemsPrinted; NumItemsPrinted)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if not P800ReplMgmt.GetReplItemBin(
                                     Number = 1, CurrVariantCode, CurrTransType, CurrBin, CurrUOMCode, CurrQty) // P8001083
                            then
                                CurrReport.Break;

                            CurrQty := Round(CurrQty, 0.00001);
                            CurrItemUOM.Get(CurrItem."No.", CurrUOMCode);
                            CurrQtyBase := Round(CurrQty * CurrItemUOM."Qty. per Unit of Measure", 0.00001);

                            // P8001082
                            if P800ReplMgmt.IsPreProcessReplBin() then
                                QtyAvailBase :=
                                  P800ReplMgmt.GetPreProcessQtyAvailBase(LocationCode, CurrBin.Code, CurrItem."No.", CurrVariantCode)
                            else
                                // P8001082
                                QtyAvailBase :=
                                P800ReplMgmt.GetQtyAvailBase(
                                  LocationCode, CurrBin.Code, CurrItem."No.", CurrVariantCode, CurrTransType, CurrUOMCode); // P8001083
                            if (CurrQtyBase > QtyAvailBase) then
                                ReplQtyBase := CurrQtyBase - QtyAvailBase
                            else
                                ReplQtyBase := 0;
                            ReplQty := Round(ReplQtyBase / CurrItemUOM."Qty. per Unit of Measure", 0.00001);

                            if RoundUpToWholeQtys then
                                if not P800ReplMgmt.IsPreProcessReplBin() then // P8001082
                                    ReplQty := Round(ReplQty, 1, '>');

                            RTCReplQty += ReplQty;  // P8000812

                            // P8000631A
                            if GenerateJnlLines and (ReplQty <> 0) then
                                InsertItemJnlLine(
                                  PostingDate, DocumentNo, CurrItem."No.", CurrVariantCode,
                                  LocationCode, CurrBin.Code, CurrUOMCode, ReplQty);
                            // P8000631A

                            if (ReplQty = 0) then begin
                                if not ShowAllItems then
                                    CurrReport.Skip;
                                if CurrItem.IsFixedBinItem(LocationCode) then
                                    CurrReport.Skip;
                            end;

                            NumItemsPrinted := NumItemsPrinted + 1;
                        end;

                        trigger OnPreDataItem()
                        begin
                            RTCReplQty := 0;  // P8000812
                            NumItemsPrinted := 0;

                            SetFilter(Number, '1..');
                        end;
                    }
                    dataitem(OrderLoop; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        column(CurrOrderNo; CurrOrderNo)
                        {
                        }
                        column(CurrOrderUOMCode; CurrOrderUOMCode)
                        {
                        }
                        column(CurrOrderQty; CurrOrderQty)
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(CurrOrderQtyBase; CurrOrderQtyBase)
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(OrderLoopHeader; 'OrderLoop')
                        {
                        }
                        column(OrderLoopRec; Format(Number))
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if not P800ReplMgmt.GetReplProdOrderDetail(
                                     Number = 1, CurrOrderNo, CurrBin.Code, CurrOrderUOMCode, CurrOrderQty, CurrOrderQtyBase) // P8001345
                            then
                                CurrReport.Break;
                        end;

                        trigger OnPreDataItem()
                        begin
                            if IsServiceTier then ReplQty := RTCReplQty;  // P8000812
                            if (ReplQty = 0) then
                                CurrReport.Break;

                            SetFilter(Number, '1..');
                        end;
                    }
                    dataitem(SuggestBinLoop; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        column(BinListHeaderText; BinListHeaderText)
                        {
                        }
                        column(SuggBinUOMMsg; SuggBinUOMMsg)
                        {
                        }
                        column(TempBinSuggestionUOMCode; TempBinSuggestion."Unit of Measure Code")
                        {
                        }
                        column(TempBinSuggestionQuantity; TempBinSuggestion.Quantity)
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(TempBinSuggestion_LotNo; TempBinSuggestion."Lot No.")
                        {
                        }
                        column(TempBinSuggestionBinCode; TempBinSuggestion."Bin Code")
                        {
                        }
                        column(SuggestBinLoopHeader; 'SuggestBinLoop')
                        {
                        }
                        column(SuggestBinLoopRec; Format(Number))
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if not P800ReplMgmt.GetSuggBinLine(Number = 1, TempBinSuggestion) then
                                CurrReport.Break;

                            P800ReplMgmt.GetSuggBinUOMMsg(
                              ReplQty, CurrUOMCode, TempBinSuggestion, SuggBinUOMMsg);
                        end;

                        trigger OnPreDataItem()
                        begin
                            P800ReplMgmt.SetPickBinOverride(AllowRecvBin, AllowOutputBin); // P8001278
                            if not P800ReplMgmt.GetSuggestedPicks(
                                     SuggestPicks, PicksSuggested, LocationCode, CurrItem."No.",
                                     CurrVariantCode, CurrTransType, ReplQty, CurrUOMCode, TempBinSuggestion) // P8001083
                            then
                                CurrReport.Break;

                            SetFilter(Number, '1..');

                            BinListHeaderText := GetPickBinHeaderText(Text006, Text008); // P8001082
                        end;
                    }
                    dataitem(NoSuggestBinLoop; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        MaxIteration = 1;
                        column(NoSuggestBinLoopRec; Format(Number))
                        {
                        }
                        column(NoBinListHeaderText; NoBinListHeaderText)
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            if not P800ReplMgmt.ShowNoSuggBins(SuggestPicks, PicksSuggested, ReplQty) then
                                CurrReport.Break;

                            NoBinListHeaderText := GetPickBinHeaderText(Text007, Text009); // P8001082
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if not P800ReplMgmt.GetReplItem(Number = 1, CurrItemType, CurrItem) then
                            CurrReport.Break;

                        // P8000631A
                        ItemFilters := CurrItem;
                        if not ItemFilters.Find then
                            CurrReport.Skip;
                        // P8000631A
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetFilter(Number, '1..');
                    end;
                }
            }

            trigger OnAfterGetRecord()
            begin
                if not P800ReplMgmt.GetReplItemType(Number = 1, CurrItemType, CurrItemTypeStr) then
                    CurrReport.Break;

                CurrReport.PageNo(0);
                CurrReport.NewPage;
            end;

            trigger OnPreDataItem()
            begin
                P800ReplMgmt.BuildProdReplTotals(LocationCode, ReplenishmentArea, StartingDate, ProdShiftNo, ShowOrderDetail); // P8001276

                SetFilter(Number, '1..');
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field("Location Code"; LocationCode)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Location Code';
                        TableRelation = Location;

                        trigger OnValidate()
                        begin
                            SetLocation(LocationCode);
                        end;
                    }
                    field("Starting Date"; StartingDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Starting Date';
                    }
                    field(WorkShiftCode; ProdShiftNo)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Work Shift Code';
                        TableRelation = "Work Shift";
                    }
                    field(ShowAllItems; ShowAllItems)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Show All Items';
                    }
                    field(RoundUpToWholeQtys; RoundUpToWholeQtys)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Round Up To Whole Qtys.';
                    }
                    field(ShowOrderDetail; ShowOrderDetail)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Show Order Detail';
                    }
                    field(SuggestPicks; SuggestPicks)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Suggest Picks';

                        trigger OnValidate()
                        begin
                            SuggestionsEnable := SuggestPicks; // P8001278
                        end;
                    }
                    field("Max. Number of Suggestions"; MaxNumSuggestions)
                    {
                        ApplicationArea = FOODBasic;
                        BlankZero = true;
                        Caption = 'Max. Number of Suggestions';
                        Enabled = SuggestionsEnable;
                        MinValue = 0;
                    }
                    field(AllowRecvBin; AllowRecvBin)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Allow Picks from Receiving Bins';
                        Enabled = SuggestionsEnable;
                    }
                    field(AllowOutputBin; AllowOutputBin)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Allow Picks from Output Bins';
                        Enabled = SuggestionsEnable;
                    }
                    field("Generate Journal Lines"; GenerateJnlLines)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Generate Journal Lines';
                        Visible = "Generate Journal LinesVisible";

                        trigger OnValidate()
                        begin
                            "Posting DateEnable" := GenerateJnlLines;
                            "Document No.Enable" := GenerateJnlLines;
                        end;
                    }
                    field("Posting Date"; PostingDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Posting Date';
                        Enabled = "Posting DateEnable";
                        Visible = "Posting DateVisible";
                    }
                    field("Document No."; DocumentNo)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Document No.';
                        Enabled = "Document No.Enable";
                        Visible = "Document No.Visible";
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            "Document No.Visible" := true;
            "Posting DateVisible" := true;
            "Generate Journal LinesVisible" := true;
            "Document No.Enable" := true;
            "Posting DateEnable" := true;
            SuggestionsEnable := true; // P8001278
        end;

        trigger OnOpenPage()
        begin
            if (ExtLocationCode <> '') then begin
                SetLocation(ExtLocationCode);
                StartingDate := ExtStartingDate;
                ProdShiftNo := ExtProdShiftNo;
            end;
            SuggestionsEnable := SuggestPicks; // P8001278

            // P8000631A
            if not CalledFromJnl then begin
                "Generate Journal LinesVisible" := false;
                "Posting DateVisible" := false;
                "Document No.Visible" := false;
            end else begin
                if ItemJnlLine."Location Code" <> '' then
                    LocationCode := ItemJnlLine."Location Code";
                PostingDate := ItemJnlLine."Posting Date";
                DocumentNo := ItemJnlLine."Document No.";
                "Posting DateEnable" := GenerateJnlLines;
                "Document No.Enable" := GenerateJnlLines;
            end;

            if LocationCode = '' then
                LocationCode := P800CoreFns.GetDefaultEmpLocation; // P8001034

            if Location.Get(LocationCode) then
                if not Location."Bin Mandatory" then
                    LocationCode := '';
            // P8000631A
        end;
    }

    rendering
    {
        layout(StandardRDLCLayout)
        {
            Summary = 'Standard Layout';
            Type = RDLC;
            LayoutFile = './layout/ProdReplenishmentMoveList.rdlc';
        }
    }

    labels
    {
        ReplQtyCaption = 'Replenish Qty.';
        ReplQtyBaseCaption = 'Replenish Qty. (Base)';
        QtyAvailBaseCaption = 'Qty. Avail. (Base)';
        BaseUOMCaption = 'Base UOM';
        QtyBaseCaption = 'Quantity (Base)';
        UOMCodeCaption = 'UOM';
        QtyCaption = 'Quantity';
        DescCaption = 'Description';
        PageNoCaption = 'Page';
        ItemNoCaption = 'Item No.';
        BinCodeCaption = 'Prod. Bin';
        TotReplQtyCaption = 'Total Replenish Qty.:';
        ProdOrdersCaption = 'Production Orders';
    }

    trigger OnInitReport()
    begin
        RoundUpToWholeQtys := true;
        SuggestPicks := true;
        MaxNumSuggestions := 3;
        GenerateJnlLines := true; // P8000631A
    end;

    trigger OnPreReport()
    begin
        if (LocationCode = '') then
            Error(Text000);
        SetLocation(LocationCode);
        if (StartingDate = 0D) then
            Error(Text001);
        P800ReplMgmt.SetMaxNumSuggestions(MaxNumSuggestions);

        // P8000631A
        if not CalledFromJnl then
            GenerateJnlLines := false;
        if GenerateJnlLines then
            if (PostingDate = 0D) or (DocumentNo = '') then
                Error(Text005);
        // P8000631A
    end;

    var
        LocationCode: Code[10];
        StartingDate: Date;
        ProdShiftNo: Code[10];
        ShowAllItems: Boolean;
        RoundUpToWholeQtys: Boolean;
        ShowOrderDetail: Boolean;
        SuggestPicks: Boolean;
        MaxNumSuggestions: Integer;
        ExtLocationCode: Code[10];
        ExtStartingDate: Date;
        ExtProdShiftNo: Code[10];
        Location: Record Location;
        CurrBin: Record Bin;
        CurrItemType: Integer;
        CurrItemTypeStr: Text[80];
        CurrItem: Record Item;
        CurrVariantCode: Code[10];
        CurrTransType: Integer;
        CurrUOMCode: Code[10];
        CurrQty: Decimal;
        CurrQtyBase: Decimal;
        CurrItemUOM: Record "Item Unit of Measure";
        ReplQty: Decimal;
        ReplQtyBase: Decimal;
        CurrOrderNo: Code[20];
        CurrOrderUOMCode: Code[10];
        CurrOrderQty: Decimal;
        CurrOrderQtyBase: Decimal;
        NumItemsPrinted: Integer;
        QtyAvailBase: Decimal;
        TempBinSuggestion: Record "Warehouse Entry" temporary;
        PicksSuggested: Boolean;
        SuggBinUOMMsg: Text[250];
        P800ReplMgmt: Codeunit "Process 800 Replenish. Mgmt.";
        Text000: Label 'You must enter a Location Code.';
        Text001: Label 'You must enter a Starting Date.';
        Text002: Label '%1 Item Replenishment / Move List';
        Text003: Label 'Shift %1 for %2';
        Text004: Label 'All Shifts for %1';
        ItemFilters: Record Item;
        CalledFromJnl: Boolean;
        GenerateJnlLines: Boolean;
        PostingDate: Date;
        DocumentNo: Code[20];
        ItemJnlLine: Record "Item Journal Line";
        ItemJournalTempl: Record "Item Journal Template";
        WMSMgmt: Codeunit "WMS Management";
        Text005: Label 'You must specify the Posting Date and Document No. to Generate Journal Lines.';
        P800CoreFns: Codeunit "Process 800 Core Functions";
        [InDataSet]
        SuggestionsEnable: Boolean;
        [InDataSet]
        "Posting DateEnable": Boolean;
        [InDataSet]
        "Document No.Enable": Boolean;
        [InDataSet]
        "Generate Journal LinesVisible": Boolean;
        [InDataSet]
        "Posting DateVisible": Boolean;
        [InDataSet]
        "Document No.Visible": Boolean;
        RTCReplQty: Decimal;
        BinListHeaderText: Text[80];
        NoBinListHeaderText: Text[80];
        Text006: Label 'Pre-Process Pick Bins / Lots';
        Text007: Label 'Pre-Process Required';
        Text008: Label 'Pick Bins / Lots Available';
        Text009: Label 'No Available Pick Bins / Lots';
        ReplenishmentArea: Record "Replenishment Area";
        ReplenishmentAreaFilter: Text;
        AllowRecvBin: Boolean;
        AllowOutputBin: Boolean;

    procedure SetProdOrder(var ProdOrderLine: Record "Prod. Order Line")
    begin
        with ProdOrderLine do begin
            TestField("Location Code");
            TestField("Starting Date");
            ExtLocationCode := "Location Code";
            ExtStartingDate := "Starting Date";
            ExtProdShiftNo := "Work Shift Code";
        end;
    end;

    local procedure SetLocation(NewLocationCode: Code[10])
    begin
        LocationCode := NewLocationCode;
        with Location do begin
            Get(LocationCode);
            TestField("Bin Mandatory", true);
        end;
    end;

    local procedure GetReportTitle1(): Text[80]
    begin
        exit(StrSubstNo(Text002, CurrItemTypeStr));
    end;

    local procedure GetReportTitle2(): Text[80]
    begin
        if (ProdShiftNo <> '') then
            exit(StrSubstNo(Text003, ProdShiftNo, StartingDate));
        exit(StrSubstNo(Text004, StartingDate));
    end;

    procedure SetItemJnlLine(var ItemJnlLine2: Record "Item Journal Line")
    begin
        ItemJnlLine := ItemJnlLine2;
        with ItemJnlLine do begin
            SetRange("Journal Template Name", "Journal Template Name");
            SetRange("Journal Batch Name", "Journal Batch Name");
            if FindLast then;
            ItemJournalTempl.Get("Journal Template Name");
        end;
        CalledFromJnl := true;
    end;

    local procedure InsertItemJnlLine(PostingDate: Date; DocumentNo: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; BinCode: Code[20]; UOMCode: Code[10]; Qty: Decimal)
    begin
        // P8000631A
        with ItemJnlLine do begin
            Init;
            "Line No." := "Line No." + 10000;
            Validate("Posting Date", PostingDate);
            Validate("Document No.", DocumentNo);
            Validate("Entry Type", "Entry Type"::Transfer);
            Validate("Item No.", ItemNo);
            Validate("Variant Code", VariantCode);
            Validate("Location Code", LocationCode);
            Validate("New Location Code", LocationCode);
            // P8001082
            if P800ReplMgmt.IsPreProcessReplBin() then
                Validate("Bin Code", P800ReplMgmt.GetPreProcessReplBin())
            else
                // P8001082
                if WMSMgmt.GetDefaultBin("Item No.", "Variant Code", "Location Code", "Bin Code") then
                    Validate("Bin Code")
                else
                    Validate("Bin Code", '');
            Validate("New Bin Code", BinCode);
            Validate("Unit of Measure Code", UOMCode);
            Validate(Quantity, Qty);
            "Source Code" := ItemJournalTempl."Source Code";
            Insert;
            if P800ReplMgmt.IsPreProcessReplBin() then            // P8001082
                P800ReplMgmt.CreatePreProcessReplTrkg(ItemJnlLine); // P8001082
        end;
    end;

    procedure GetPickBinHeaderText(PreProcessText: Text[80]; NormalText: Text[80]): Text[80]
    begin
        // P8001082
        if P800ReplMgmt.IsPreProcessReplBin() then
            exit(PreProcessText);
        exit(NormalText);
    end;
}

