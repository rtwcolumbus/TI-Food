report 37002100 "Put-Away Move List"
{
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add 1-Doc Whse Logic
    // 
    // PRW16.00.02
    // P8000756, VerticalSoft, Jack Reynolds, 20 JAN 10
    //   Add InitBinContentItemTracking function
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 06 APR 10
    //   RTC Reporting Upgrade
    // 
    // PRW16.00.04
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // P8000901, VerticalSoft, Don Bresee, 07 FEB 11
    //   Add call to item tracking form to indicate "Reclass" mode
    // 
    // PRW16.00.06
    // P8001034, Columbus IT, Jack Reynolds, 10 FEB 12
    //   Change codeunit for Warehouse Employee functions
    // 
    // P8001045, Columbus IT, Jack Reynolds, 22 MAR 12
    //   fix problem with New Lot No. on Item Journal Line
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 20 FEB 13
    //   Restoring the SaveValues property in the Request Page.
    // 
    // PRW19.00
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup obsolete container functionality
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // P8007749, To-Increase, Jack Reynolds, 07 DEC 16
    //   Item Category/Product Group
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    DefaultLayout = RDLC;
    RDLCLayout = './layout/PutAwayMoveList.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Put-Away Move List';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item; Item)
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Item Category Code";
            column(GetReportTitle; GetReportTitle())
            {
            }
            column(STRLocationCodeName; StrSubstNo('%1 - %2', Location.Code, Location.Name))
            {
            }
            column(ItemNo; "No.")
            {
            }
            dataitem(ItemVariantLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);
                PrintOnlyIfDetail = true;
                column(ItemVariantLoopBody; 'ItemVariantLoopBody')
                {
                }
                dataitem(SourceBinLoop; "Integer")
                {
                    DataItemTableView = SORTING(Number);
                    PrintOnlyIfDetail = true;
                    column(SourceBinLoopBody1; 'SourceBinLoopBody1')
                    {
                    }
                    dataitem(UOMEntry; "Warehouse Entry")
                    {
                        DataItemTableView = SORTING("Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code", Open, "Lot No.", "Serial No.");
                        PrintOnlyIfDetail = true;
                        dataitem(BinEntry; "Warehouse Entry")
                        {
                            DataItemTableView = SORTING("Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code", Open, "Lot No.", "Serial No.");
                            column(BinEntryBinCode; "Bin Code")
                            {
                                IncludeCaption = true;
                            }
                            column(BinEntryUOMCode; "Unit of Measure Code")
                            {
                                IncludeCaption = true;
                            }
                            column(BinEntryRemQuantity; "Remaining Quantity")
                            {
                            }
                            column(BinEntryItemDesc; Item.Description)
                            {
                            }
                            column(BinEntryItemNo; "Item No.")
                            {
                                IncludeCaption = true;
                            }
                            column(BinEntryBody1; 'BinEntry Body1')
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                SetRange("Lot No.", "Lot No.");
                                SetRange("Serial No.", "Serial No.");
                                Find('+');
                                CalcSums("Remaining Quantity", "Remaining Qty. (Base)");
                                SetRange("Lot No.");
                                SetRange("Serial No.");

                                if (Item."Item Type" = Item."Item Type"::Container) then begin
                                    ContainerLine.Quantity := ContainerFns.ContainersInUse("Item No.", "Serial No.", "Location Code", "Bin Code");
                                    // P8004518
                                    //  IF (Location."Container Bin Code" <> '') THEN
                                    //    ContainerLine.Quantity -= ContainerFns.ContainersInUse(
                                    //      "Item No.","Serial No.","Location Code",Location."Container Bin Code");
                                    // P8004518
                                    ContainerLine."Quantity (Base)" := ContainerLine.Quantity;
                                end else begin
                                    ContainerLine.SetRange("Lot No.", "Lot No.");
                                    ContainerLine.SetRange("Serial No.", "Serial No.");
                                    ContainerLine.CalcSums(Quantity, "Quantity (Base)");
                                    ContainerLine.SetRange("Lot No.");
                                    ContainerLine.SetRange("Serial No.");
                                end;
                                "Remaining Quantity" -= ContainerLine.Quantity;
                                "Remaining Qty. (Base)" -= ContainerLine."Quantity (Base)";
                                if ("Remaining Quantity" = 0) and ("Remaining Qty. (Base)" = 0) then
                                    CurrReport.Skip;

                                if GenerateJnlLines then
                                    InsertItemJnlLine(BinEntry);
                            end;

                            trigger OnPreDataItem()
                            begin
                                Copy(UOMEntry);
                                SetRange("Unit of Measure Code", UOMEntry."Unit of Measure Code");

                                ContainerLine.SetCurrentKey(
                                  "Item No.", "Variant Code", "Location Code", "Bin Code",
                                  "Unit of Measure Code", "Lot No.", "Serial No.");
                                ContainerLine.SetRange("Item No.", Item."No.");
                                ContainerLine.SetRange("Variant Code", ItemVariant.Code);
                                ContainerLine.SetRange("Location Code", LocationCode);
                                ContainerLine.SetRange("Bin Code", SourceBin.Code);
                                ContainerLine.SetRange("Unit of Measure Code", UOMEntry."Unit of Measure Code");
                            end;
                        }
                        dataitem(SIContainer; "Container Header")
                        {
                            DataItemTableView = SORTING("Location Code", "Bin Code");
                            PrintOnlyIfDetail = true;
                            column(SIContainerBody; 'SIContainerBody')
                            {
                            }
                            dataitem(BinContainerEntry; "Container Line")
                            {
                                DataItemLink = "Container ID" = FIELD(ID);
                                DataItemTableView = SORTING("Container ID", "Line No.");
                                column(BinContEntryContainerID; "Container ID")
                                {
                                    IncludeCaption = true;
                                }
                                column(BinContEntryBinCode; "Bin Code")
                                {
                                }
                                column(BinContEntryUOMCode; "Unit of Measure Code")
                                {
                                }
                                column(BinContEntryQuantity; Quantity)
                                {
                                }
                                column(BinContEntryItemDesc; Item.Description)
                                {
                                }
                                column(BinContEntryItemNo; "Item No.")
                                {
                                }
                                column(BinContEntryBody1; 'BinContainerEntry Body1')
                                {
                                }

                                trigger OnPreDataItem()
                                begin
                                    SetRange("Item No.", Item."No.");
                                    SetRange("Variant Code", ItemVariant.Code);
                                    SetRange("Unit of Measure Code", UOMEntry."Unit of Measure Code");
                                end;
                            }
                        }

                        trigger OnAfterGetRecord()
                        begin
                            SetRange("Unit of Measure Code", "Unit of Measure Code");
                            Find('+');
                            SetRange("Unit of Measure Code");

                            ItemUOM.Get(Item."No.", "Unit of Measure Code");
                            ItemUOM.Mark(true);
                        end;

                        trigger OnPreDataItem()
                        begin
                            SetRange("Location Code", LocationCode);
                            SetRange("Bin Code", SourceBin.Code);
                            SetRange("Item No.", Item."No.");
                            SetRange("Variant Code", ItemVariant.Code);
                            SetRange(Open, true);
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if (Number = 1) then
                            SourceBin.FindSet
                        else
                            if (SourceBin.Next = 0) then
                                CurrReport.Break;
                    end;

                    trigger OnPreDataItem()
                    begin
                        ItemUOM.Reset;

                        SetFilter(Number, '1..');
                    end;
                }
                dataitem(SuggestBinLoop; "Integer")
                {
                    DataItemTableView = SORTING(Number);
                    column(SuggBinUOMMsg; SuggBinUOMMsg)
                    {
                    }
                    column(TempBinSuggUOMCode; TempBinSuggestion."Unit of Measure Code")
                    {
                    }
                    column(TempBinSuggQuantity; TempBinSuggestion.Quantity)
                    {
                        DecimalPlaces = 0 : 5;
                    }
                    column(TempBinSuggBinCode; TempBinSuggestion."Bin Code")
                    {
                    }
                    column(SuggestBinLoopBody2; 'SuggestBinLoopBody2')
                    {
                    }
                    column(SuggestBinLoopNumber; Number)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if not P800ReplMgmt.GetSuggBinLine(Number = 1, TempBinSuggestion) then
                            CurrReport.Break;

                        P800ReplMgmt.GetSuggBinUOMMsg(
                          TempBinSuggestion.Quantity, TempBinSuggestion."Unit of Measure Code", TempBinSuggestion, SuggBinUOMMsg);
                    end;

                    trigger OnPreDataItem()
                    begin
                        if (BinEntry."Remaining Quantity" = 0) and (BinContainerEntry.Quantity = 0) then
                            CurrReport.Break;

                        if not P800ReplMgmt.GetSuggestedPutAways(
                                 SuggestBins, BinsSuggested, LocationCode, SourceBin,
                                 Item."No.", ItemVariant.Code, ItemUOM, TempBinSuggestion)
                        then
                            CurrReport.Break;

                        SetFilter(Number, '1..');
                    end;
                }
                dataitem(NoSuggestBinLoop; "Integer")
                {
                    DataItemTableView = SORTING(Number);
                    MaxIteration = 1;
                    column(NoSuggestBinLoopNumber; Number)
                    {
                    }

                    trigger OnPreDataItem()
                    begin
                        if not P800ReplMgmt.ShowNoSuggBins(
                                 SuggestBins, BinsSuggested, BinEntry."Remaining Quantity" + BinContainerEntry.Quantity)
                        then
                            CurrReport.Break;
                    end;
                }
                dataitem(SourceBinLoop2; "Integer")
                {
                    DataItemTableView = SORTING(Number);
                    PrintOnlyIfDetail = true;
                    column(STRItemDesc; StrSubstNo(Text003, Item.Description))
                    {
                    }
                    column(SourceBinLoop2ItemNo; Item."No.")
                    {
                    }
                    column(SourceBinLoop2Body2; 'SourceBinLoop2Body2')
                    {
                    }
                    dataitem(MIContainer; "Container Header")
                    {
                        DataItemTableView = SORTING("Container Item No.", "Container Serial No.", "Location Code", "Bin Code");
                        column(MIContainerID; ID)
                        {
                        }
                        column(MIContainerItemDesc; 'PLACEHOLDER')
                        {
                        }
                        column(MIContainerBinCode; "Bin Code")
                        {
                        }
                        column(MIContainerBody1; 'MIContainerBody1')
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            //CALCFIELDS(Assigned);
                            //IF Assigned THEN
                            //  CurrReport.SKIP;

                            //IF GenerateJnlLines THEN
                            //  InsertContItemJnlLines(MIContainer);
                        end;

                        trigger OnPreDataItem()
                        begin
                            //SETRANGE("Container Item No.",Item."No.");
                            //SETRANGE("Location Code",LocationCode);
                            //SETRANGE("Bin Code",SourceBin.Code);
                            //SETFILTER("Item No.",'%1','');
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if (Number = 1) then
                            SourceBin.FindSet
                        else
                            if (SourceBin.Next = 0) then
                                CurrReport.Break;
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetFilter(Number, '1..');
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    case Number of
                        1:
                            ItemVariant.Code := '';
                        2:
                            if not ItemVariant.Find('-') then
                                CurrReport.Break;
                        else
                            if (ItemVariant.Next = 0) then
                                CurrReport.Break;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    ItemVariant.SetRange("Item No.", Item."No.");

                    SetFilter(Number, '1..');
                end;
            }

            trigger OnPreDataItem()
            begin
                FindItems;
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
                        TableRelation = Location WHERE("Bin Mandatory" = CONST(true),
                                                        "Directed Put-away and Pick" = CONST(false));

                        trigger OnValidate()
                        begin
                            LocationCodeOnAfterValidate;
                        end;
                    }
                    field("Source Bins"; UserSourceBins)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Source Bins';
                        Editable = "Source BinsEditable";

                        trigger OnValidate()
                        begin
                            UserSourceBinsOnAfterValidate;
                        end;
                    }
                    field("Bin Filter"; OtherBinFilter)
                    {
                        ApplicationArea = FOODBasic;
                        Enabled = "Bin FilterEnable";

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            Bin: Record Bin;
                            BinList: Page "Bin List";
                        begin
                            if (LocationCode = '') then
                                Error(Text000);
                            Bin.SetRange("Location Code", LocationCode);
                            BinList.SetTableView(Bin);
                            if (Text <> '') then begin
                                Bin.SetFilter(Code, Text);
                                if Bin.FindFirst then
                                    BinList.SetRecord(Bin);
                            end;
                            BinList.LookupMode(true);
                            if (BinList.RunModal <> ACTION::LookupOK) then
                                exit(false);
                            BinList.GetRecord(Bin);
                            Text := Bin.Code;
                            exit(true);
                        end;
                    }
                    field(SuggestBins; SuggestBins)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Suggest Bins';

                        trigger OnValidate()
                        begin
                            MaxNumberofSuggestionsEnable := SuggestBins;
                        end;
                    }
                    field("Max. Number of Suggestions"; MaxNumSuggestions)
                    {
                        ApplicationArea = FOODBasic;
                        BlankZero = true;
                        Caption = 'Max. Number of Suggestions';
                        Enabled = MaxNumberofSuggestionsEnable;
                        MinValue = 0;
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
            "Source BinsEditable" := true;
            "Document No.Visible" := true;
            "Posting DateVisible" := true;
            "Generate Journal LinesVisible" := true;
            MaxNumberofSuggestionsEnable := true;
            "Document No.Enable" := true;
            "Posting DateEnable" := true;
            "Bin FilterEnable" := true;
        end;

        trigger OnOpenPage()
        begin
            if SourceBins = 0 then begin
                "Generate Journal LinesVisible" := false;
                "Posting DateVisible" := false;
                "Document No.Visible" := false;
            end else begin
                if ItemJnlLine."Location Code" <> '' then
                    LocationCode := ItemJnlLine."Location Code";
                UserSourceBins := SourceBins - 1;
                "Source BinsEditable" := false;
                PostingDate := ItemJnlLine."Posting Date";
                DocumentNo := ItemJnlLine."Document No.";
                "Posting DateEnable" := GenerateJnlLines;
                "Document No.Enable" := GenerateJnlLines;
            end;
            MaxNumberofSuggestionsEnable := SuggestBins;
            "Bin FilterEnable" := UserSourceBins = UserSourceBins::Other;

            if (LocationCode = '') then
                LocationCode := P800CoreFns.GetDefaultEmpLocation; // P8001034

            if Location.Get(LocationCode) then
                if (not Location."Bin Mandatory") or
                   Location."Directed Put-away and Pick" or
                   Location."Require Put-away"
                then
                    LocationCode := '';

            InitOtherBinFilter;
        end;
    }

    labels
    {
        PAGENOCaption = 'Page';
        ItemDescriptionCaption = 'Item Description';
        QuantityCaption = 'Quantity';
        PutAwayBinsAvailableCaption = 'Put-Away Bins Available';
        NoAvailablePutAwayBinsCaption = 'No Available Put-Away Bins';
    }

    trigger OnInitReport()
    begin
        GenerateJnlLines := true;
        SuggestBins := true;
        MaxNumSuggestions := 3;
    end;

    trigger OnPreReport()
    begin
        if LocationCode = '' then
            Error(Text000);
        Location.Get(LocationCode);
        Location.TestField("Bin Mandatory", true);
        Location.TestField("Directed Put-away and Pick", false);

        if SourceBins = 0 then
            GenerateJnlLines := false;
        if GenerateJnlLines then
            if (PostingDate = 0D) or (DocumentNo = '') then
                Error(Text002);

        if (UserSourceBins = UserSourceBins::Other) and (OtherBinFilter = '') then
            Error(Text004);

        P800ReplMgmt.SetMaxNumSuggestions(MaxNumSuggestions);

        FindSourceBins;
    end;

    var
        LocationCode: Code[10];
        Location: Record Location;
        SourceBins: Option ,"Receipt Bin","Shipment Bin","Output Bins","Consumption Bins",Other;
        UserSourceBins: Option "Receipt Bin","Shipment Bin","Output Bins","Consumption Bins",Other;
        OtherBinFilter: Code[250];
        ReplArea: Record "Replenishment Area";
        SourceBin: Record Bin;
        ItemJnlLine: Record "Item Journal Line";
        ItemJournalTempl: Record "Item Journal Template";
        GenerateJnlLines: Boolean;
        PostingDate: Date;
        DocumentNo: Code[20];
        P800CoreFns: Codeunit "Process 800 Core Functions";
        WMSMgmt: Codeunit "WMS Management";
        SuggestBins: Boolean;
        MaxNumSuggestions: Integer;
        TempBinSuggestion: Record "Warehouse Entry" temporary;
        BinsSuggested: Boolean;
        SuggBinUOMMsg: Text[250];
        P800ReplMgmt: Codeunit "Process 800 Replenish. Mgmt.";
        ItemVariant: Record "Item Variant";
        ItemUOM: Record "Item Unit of Measure";
        ContainerLine: Record "Container Line";
        ContainerFns: Codeunit "Container Functions";
        SkipProdBin: Boolean;
        Text000: Label 'You must specify Location Code.';
        Text001: Label 'Put-Away Move List - %1';
        Text002: Label 'You must specify the Posting Date and Document No. to Generate Journal Lines.';
        Text003: Label '%1 - Multiple Item Containers';
        Text004: Label 'You must specify the Other Bin Filter.';
        [InDataSet]
        "Bin FilterEnable": Boolean;
        [InDataSet]
        "Posting DateEnable": Boolean;
        [InDataSet]
        "Document No.Enable": Boolean;
        [InDataSet]
        MaxNumberofSuggestionsEnable: Boolean;
        [InDataSet]
        "Generate Journal LinesVisible": Boolean;
        [InDataSet]
        "Posting DateVisible": Boolean;
        [InDataSet]
        "Document No.Visible": Boolean;
        [InDataSet]
        "Source BinsEditable": Boolean;

    procedure GetReportTitle(): Text[50]
    begin
        if UserSourceBins = UserSourceBins::Other then
            exit(StrSubstNo(Text001, OtherBinFilter));
        exit(StrSubstNo(Text001, UserSourceBins));
    end;

    local procedure InitOtherBinFilter()
    begin
        if (LocationCode = '') then
            OtherBinFilter := ''
        else begin
            SourceBin.SetRange("Location Code", LocationCode);
            SourceBin.SetFilter(Code, OtherBinFilter);
            if not SourceBin.FindFirst then
                OtherBinFilter := '';
        end;
    end;

    local procedure FindSourceBins()
    begin
        SourceBin.Reset;
        case UserSourceBins of
            UserSourceBins::"Receipt Bin":
                begin
                    Location.TestField("Receipt Bin Code (1-Doc)");
                    SourceBin.Get(LocationCode, Location."Receipt Bin Code (1-Doc)");
                    SourceBin.SetRecFilter;
                end;
            UserSourceBins::"Shipment Bin":
                begin
                    Location.TestField("Shipment Bin Code (1-Doc)");
                    SourceBin.Get(LocationCode, Location."Shipment Bin Code (1-Doc)");
                    SourceBin.SetRecFilter;
                end;
            UserSourceBins::"Output Bins", UserSourceBins::"Consumption Bins":
                begin
                    ReplArea.SetRange("Location Code", LocationCode);
                    ReplArea.FindSet;
                    repeat
                        case UserSourceBins of
                            UserSourceBins::"Output Bins":
                                begin
                                    ReplArea.TestField("From Bin Code");
                                    SourceBin.Get(LocationCode, ReplArea."From Bin Code");
                                    SourceBin.Mark(true);
                                end;
                            UserSourceBins::"Consumption Bins":
                                begin
                                    ReplArea.TestField("To Bin Code");
                                    SourceBin.Get(LocationCode, ReplArea."To Bin Code");
                                    SourceBin.Mark(true);
                                end;
                        end;
                    until (ReplArea.Next = 0);
                    SourceBin.MarkedOnly(true);
                end;
            UserSourceBins::Other:
                begin
                    SourceBin.SetRange("Location Code", LocationCode);
                    SourceBin.SetFilter(Code, OtherBinFilter);
                    SourceBin.FindSet;
                end;
        end;
    end;

    local procedure FindItems()
    var
        WhseEntry: Record "Warehouse Entry";
    begin
        if SourceBin.FindSet then
            repeat
                with WhseEntry do begin
                    SetCurrentKey(
                      "Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code", Open, "Lot No.", "Serial No.");
                    SetRange("Location Code", LocationCode);
                    SetRange("Bin Code", SourceBin.Code);
                    SetRange(Open, true);
                    if FindFirst then
                        repeat
                            SetRange("Item No.", "Item No.");
                            FindLast;
                            SetRange("Item No.");
                            Item."No." := "Item No.";
                            Item.Mark(true);
                        until (Next = 0);
                end;
            until (SourceBin.Next = 0);
        Item.MarkedOnly(true);
    end;

    procedure SetItemJnlLine(var ItemJnlLine2: Record "Item Journal Line"; SourceBins2: Integer)
    begin
        ItemJnlLine := ItemJnlLine2;
        with ItemJnlLine do begin
            SetRange("Journal Template Name", "Journal Template Name");
            SetRange("Journal Batch Name", "Journal Batch Name");
            if FindLast then;
            ItemJournalTempl.Get("Journal Template Name");
        end;
        SourceBins := SourceBins2;
    end;

    local procedure InsertItemJnlLine(var WhseEntry: Record "Warehouse Entry")
    var
        ItemJnlLine2: Record "Item Journal Line";
    begin
        ItemJnlLine."Line No." := ItemJnlLine."Line No." + 10000;
        with WhseEntry do begin
            ItemJnlLine2 := ItemJnlLine;
            ItemJnlLine2.Init;
            ItemJnlLine2.Validate("Posting Date", PostingDate);
            ItemJnlLine2.Validate("Document No.", DocumentNo);
            ItemJnlLine2.Validate("Entry Type", ItemJnlLine2."Entry Type"::Transfer);
            ItemJnlLine2.Validate("Item No.", "Item No.");
            ItemJnlLine2.Validate("Variant Code", "Variant Code");
            ItemJnlLine2.Validate("Location Code", "Location Code");
            ItemJnlLine2.Validate("New Location Code", "Location Code");
            ItemJnlLine2.Validate("Bin Code", "Bin Code");
            if WMSMgmt.GetDefaultBin("Item No.", "Variant Code", "Location Code", ItemJnlLine2."New Bin Code") then
                ItemJnlLine2.Validate("New Bin Code")
            else
                ItemJnlLine2.Validate("New Bin Code", '');
            ItemJnlLine2.Validate("Unit of Measure Code", "Unit of Measure Code");
            ItemJnlLine2.Validate(Quantity, "Remaining Quantity");
            ItemJnlLine2."Source Code" := ItemJournalTempl."Source Code";
            if ("Lot No." <> '') or ("Serial No." <> '') then begin
                InitBinContentItemTracking(ItemJnlLine2, "Serial No.", "Lot No.", "Remaining Qty. (Base)"); // P8000756
                                                                                                            // P8001045
                                                                                                            //ItemJnlLine2.GetLotNo;
                ItemJnlLine2."Lot No." := "Lot No.";
                ItemJnlLine2."New Lot No." := "Lot No.";
                // P8001045
            end;
            ItemJnlLine2.Insert;
        end;
    end;

    local procedure InsertContItemJnlLines(var ContainerHeader: Record "Container Header")
    var
        ItemJnlLine2: Record "Item Journal Line";
    begin
        //ItemJnlLine."Line No." := ItemJnlLine."Line No." + 10000;
        //WITH ContainerHeader DO BEGIN
        //  ItemJnlLine2 := ItemJnlLine;
        //  ItemJnlLine2.INIT;
        //  ItemJnlLine2.VALIDATE("Posting Date",PostingDate);
        //  ItemJnlLine2.VALIDATE("Document No.",DocumentNo);
        //  ItemJnlLine2.VALIDATE("Entry Type",ItemJnlLine2."Entry Type"::Transfer);
        //  ItemJnlLine2.VALIDATE("Location Code","Location Code");
        //  ItemJnlLine2.VALIDATE("New Location Code","Location Code");
        //  ItemJnlLine2.VALIDATE("Bin Code","Bin Code");
        //  ItemJnlLine2."New Bin Code" := '';
        //  IF ("Item No." <> '') THEN
        //    WMSMgmt.GetDefaultBin("Item No.",'',"Location Code",ItemJnlLine2."New Bin Code");
        //  ItemJnlLine2.VALIDATE("New Bin Code");
        //  ItemJnlLine2."Source Code" := ItemJournalTempl."Source Code";
        //  IF ("Container Serial No." <> '') THEN
        //    InitBinContentItemTracking(ItemJnlLine2,"Container Serial No.",'',0); // P8000756
        //  ItemJnlLine2.INSERT;
        //END;

        //WITH ContainerTrans DO BEGIN
        //  "License Plate" := DATABASE::"Item Journal Line";
        //  "Container Type Code" := ItemJnlLine2."Entry Type";
        //  "Serial No." := ItemJnlLine2."Journal Template Name";
        //  "Transaction No." := ItemJnlLine2."Journal Batch Name";
        //  "Source Line No." := ItemJnlLine2."Line No.";
        //  "Location Code" := ItemJnlLine2."Location Code";
        //  "Bin Code" := ItemJnlLine2."Bin Code";
        //  "Container ID" := ContainerHeader.ID;
        //  "Container Serial No." := ContainerHeader."Container Serial No.";
        //  "Container No." := ContainerHeader."Container Item No.";
        //  INSERT(TRUE);
        //END;
        //TempNewContainerTrans := ContainerTrans;
        //TempNewContainerTrans.INSERT;
    end;

    procedure InitBinContentItemTracking(var ItemJournalLine: Record "Item Journal Line"; SerNo: Code[20]; LotNo: Code[50]; QtyOnBin: Decimal)
    var
        TrackingSpecification: Record "Tracking Specification" temporary;
        ReservEntry: Record "Reservation Entry";
        ReserveItemJnlLine: Codeunit "Item Jnl. Line-Reserve";
        ItemTrackingForm: Page "Item Tracking Lines";
    begin
        // P8000756
        TrackingSpecification.InitFromItemJnlLine(ItemJournalLine); // P8007748
        TrackingSpecification."Serial No." := SerNo;
        TrackingSpecification."New Serial No." := SerNo;
        TrackingSpecification."Lot No." := LotNo;
        TrackingSpecification."New Lot No." := LotNo;
        TrackingSpecification."Quantity Handled (Base)" := 0;
        TrackingSpecification.Validate("Quantity (Base)", QtyOnBin);
        ReservEntry.TransferFields(TrackingSpecification);
        ReservEntry."Reservation Status" := ReservEntry."Reservation Status"::Surplus;
        ReservEntry.Positive := ReservEntry."Quantity (Base)" > 0;
        Clear(ItemTrackingForm);
        ItemTrackingForm.SetFormRunMode(1); // P8000901
        ItemTrackingForm.SetSourceSpec(TrackingSpecification, ItemJournalLine."Posting Date");
        ItemTrackingForm.BinContentItemTrackingInsert(TrackingSpecification);
    end;

    local procedure LocationCodeOnAfterValidate()
    begin
        InitOtherBinFilter;
    end;

    local procedure UserSourceBinsOnAfterValidate()
    begin
        "Bin FilterEnable" := UserSourceBins = UserSourceBins::Other;
    end;
}

