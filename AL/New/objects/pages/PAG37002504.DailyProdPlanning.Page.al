page 37002504 "Daily Prod. Planning"
{
    // PRW16.00.03
    // P8000789, VerticalSoft, Rick Tweedle, 10 MAR 10
    //   Created page - based upon form version
    // 
    // PRW16.00.06
    // P8001086, Columbus IT, Jack Reynolds, 08 AUG 12
    //   Fixes to page refresh issues
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW18.00
    // P8001360, Columbus IT, Jack Reynolds, 06 NOV 14
    //   Update .NET variable references
    // 
    // P8001352, Columbus IT, Jack Reynolds, 11 NOV 14
    //   Fix problem with ItemTypeFilter
    // 
    // PRW18.00.01
    // P8001386, Columbus IT, Jack Reynolds, 27 MAY 15
    //    Renamed NAV Food client addins
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 08 MAR 16
    //   Expand BOM Version code to Code20
    //   Update add-in assembly version references
    // 
    // PRW10.0
    // P8007755, To-Increase, Jack Reynolds, 22 NOV 16
    //   Update add-in assembly version references
    // 
    // P8007749, To-Increase, Jack Reynolds, 07 DEC 16
    //   Item Category/Product Group
    // 
    // PRW110.0.01
    // P80043682, To-Increase, Dayakar Battini, 14 JUL 17
    //   Exclude blank prodorder lines, validations.
    // 
    // PRW110.0.02
    // P80053037, To-Increase, Dayakar Battini, 22 MAR 18
    //   Hide some control values to separate header and lines
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00
    // P80059471, To Increase, Jack Reynolds, 25 JUN 18
    //   Upgrade signal control for JavaScript
    //   Cleanup Timer references
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 28 APR 22
    //   Removing support for Signal Functions codeunit

    Caption = 'Daily Prod. Planning';
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Daily Production Planning";
    SourceTableView = SORTING("Sort Value");

    layout
    {
        area(content)
        {
            repeater(Control37002013)
            {
                ShowCaption = false;
                field(Release; Release)
                {
                    ApplicationArea = FOODBasic;
                    HideValue = Indentation <> 0;
                    Style = Attention;
                    StyleExpr = genericColourFlag;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                    Enabled = false;
                    HideValue = Indentation <> 0;
                    Style = Attention;
                    StyleExpr = genericColourFlag;
                }
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    HideValue = Indentation <> 0;
                    Style = Attention;
                    StyleExpr = genericColourFlag;
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Style = Attention;
                    StyleExpr = genericColourFlag;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Style = Attention;
                    StyleExpr = genericColourFlag;
                    Visible = false;
                }
                field("Item Description"; "Item Description")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Style = Attention;
                    StyleExpr = genericColourFlag;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Style = Attention;
                    StyleExpr = locationColourFlag;
                }
                field("Equipment Code"; "Equipment Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Style = Attention;
                    StyleExpr = equipColourFlag;
                }
                field("Equipment Description"; "Equipment Description")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Style = Attention;
                    StyleExpr = equipColourFlag;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Style = Attention;
                    StyleExpr = genericColourFlag;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Style = Attention;
                    StyleExpr = qtyColourFlag;
                }
                field("Orig. Quantity"; "Orig. Quantity")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Style = Attention;
                    StyleExpr = genericColourFlag;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Style = Attention;
                    StyleExpr = dueColourFlag;
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Style = Attention;
                    StyleExpr = startColourFlag;
                }
                field("Starting Time"; "Starting Time")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Style = Attention;
                    StyleExpr = startTimeColourFlag;
                }
                field("Ending Date"; "Ending Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Style = Attention;
                    StyleExpr = endColourFlag;
                }
                field("Ending Time"; "Ending Time")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Style = Attention;
                    StyleExpr = endTimeColourFlag;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Card)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Card';
                Image = Card;

                trigger OnAction()
                var
                    ProdOrder: Record "Production Order";
                begin
                    if ProdOrder.Get(Status, "No.") then
                        case Status of
                            Status::"Firm Planned":
                                PAGE.Run(PAGE::"Firm Planned Prod. Order", ProdOrder);
                            Status::Released:
                                PAGE.Run(PAGE::"Released Production Order", ProdOrder);
                        end;
                end;
            }
            action(Comments)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Comments';
                Image = Comment;

                trigger OnAction()
                var
                    ProdOrder: Record "Production Order";
                    ProdOrderComment: Record "Prod. Order Comment Line";
                begin
                    if ProdOrder.Get(Status, "No.") then begin
                        ProdOrderComment.SetRange(Status, Status);
                        ProdOrderComment.SetRange("Prod. Order No.", "No.");
                        PAGE.RunModal(99000839, ProdOrderComment);
                    end;
                end;
            }
            action(ChangeOrder)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Change Order';
                Image = ChangeLog;

                trigger OnAction()
                var
                    changeProdPlan: Record "Daily Production Planning";
                    UnFilterCopy: Record "Daily Production Planning" temporary;
                    ProdPlan2: Record "Daily Production Planning";
                    OrderForm: Page "Daily Prod. Planning-Order";
                    ProdPlan3: Record "Daily Production Planning" temporary;
                    SortValue: Decimal;
                    summaryEnt: Integer;
                begin
                    // P8000789
                    UnFilterCopy.Copy(ProdPlan, true); // P8001086
                    UnFilterCopy.Reset;               // P8001086
                    UnFilterCopy.Get("Entry No.");
                    summaryEnt := -1;
                    repeat
                        if UnFilterCopy."Line No." = 0 then
                            summaryEnt := UnFilterCopy."Entry No.";
                    until (UnFilterCopy.Next(-1) = 0) or (summaryEnt >= 0);
                    if summaryEnt >= 0 then
                        UnFilterCopy.Get(summaryEnt);
                    with UnFilterCopy do begin
                        // P8000789

                        if "Line No." <> 0 then
                            Error(Text002);

                        ProdPlan2.Copy(Rec);
                        ProdPlan.Reset;
                        ProdPlan.SetRange(Status, ProdPlan2.Status);
                        ProdPlan.SetRange("No.", ProdPlan2."No.");
                        if ProdPlan.Find('-') then
                            repeat
                                ProdPlan3 := ProdPlan;
                                ProdPlan3.Insert;
                            until ProdPlan.Next = 0;
                        ProdPlan3.FilterGroup(9);
                        ProdPlan3.SetRange("Line No.", 0);
                        ProdPlan3.FilterGroup(0);
                        ProdPlan.Copy(ProdPlan2);
                        //IF PAGE.RUNMODAL(37002506,ProdPlan3) = ACTION::OK THEN BEGIN    // P8000789
                        if PAGE.RunModal(37002506, ProdPlan3) = ACTION::LookupOK then begin      // P8000789
                            ProdPlan3.Find('-');
                            SortValue := FindSortValue(ProdPlan, ProdPlan3); // P8000259A
                            ProdPlan := ProdPlan3;
                            ProdPlan."Sort Value" := SortValue; // P8000259A
                            ProdPlan.SetChanged; // P8000263A
                            ProdPlan.Modify;
                            //CurrForm.Equipment.FORM.ProdOrderChange(ProdPlan,FALSE);  // P8000789
                            ProdOrderChangeEquip(ProdPlan, false); // P8001086

                            // Update lines
                            ProdPlan2.Copy(ProdPlan);
                            ProdPlan.Reset;
                            ProdPlan.SetRange(Status, ProdPlan2.Status);
                            ProdPlan.SetRange("No.", ProdPlan2."No.");
                            ProdPlan.SetFilter("Line No.", '<>0');
                            if ProdPlan.Find('-') then
                                repeat
                                    ProdPlan."Sort Value" := SortValue; // P8000259A
                                    ProdPlan."Location Code" := ProdPlan2."Location Code";
                                    ProdPlan."Equipment Code" := ProdPlan2."Equipment Code";
                                    ProdPlan."Equipment Description" := ProdPlan2."Equipment Description";
                                    ProdPlan."Due Date" := ProdPlan2."Due Date";
                                    ProdPlan."Starting Time" := ProdPlan2."Starting Time";
                                    ProdPlan."Starting Date" := ProdPlan2."Starting Date";
                                    ProdPlan."Ending Time" := ProdPlan2."Ending Time";
                                    ProdPlan."Ending Date" := ProdPlan2."Ending Date";
                                    ProdPlan.Quantity := Round(ProdPlan2.Quantity * ProdPlan."Quantity Factor", 0.00001);
                                    ProdPlan."Quantity (Base)" := Round(ProdPlan.Quantity * ProdPlan."Qty. per Unit of Measure", 0.00001);
                                    ProdPlan.GetProdTime;
                                    ProdPlan.CalculateDates(ProdPlan.FieldNo("Starting Date"), false);
                                    ProdPlan.Modify;
                                    //CurrForm.Items.FORM.ProdOrderChange(ProdPlan,FALSE);  // P8000789
                                    ProdOrderChangeItem(ProdPlan, false);  // P8000789, P8001086
                                                                           // P8000789
                                    ProdPlan.Expanded := false;
                                // P8000789
                                until ProdPlan.Next = 0;
                            ProdPlan.Copy(ProdPlan2);
                        end;

                    end;  // P8000789
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        boldBool := Bold;
        SetDisplayColor;  // P8000789
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        if "Line No." <> 0 then
            exit(false);

        if CopyStr("No.", 1, 3) <> '***' then
            exit(false);

        ProdPlan.FilterGroup(9);
        ProdPlan.SetRange("No.", "No.");
        ProdPlan.DeleteAll;
        ProdPlan.SetRange("No.");
        ProdPlan.FilterGroup(0);
        exit(false);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        Direction: Integer;
        EOF: Boolean;
        i: Integer;
    begin
        ProdPlan.Copy(Rec);
        if not FilterOnItem then begin
            if not ProdPlan.Find(Which) then
                exit(false);
            Rec.Copy(ProdPlan);
            exit(true);
        end else begin
            for i := 1 to StrLen(Which) do begin
                EOF := false;
                case Which[i] of
                    '-', '>':
                        Direction := 1;
                    '+', '<':
                        Direction := -1;
                    '=':
                        Direction := 0;
                end;
                EOF := not ProdPlan.Find(CopyStr(Which, i, 1));
                while (not EOF) and (not ProdPlan.IncludesItem(Item."No.")) do
                    EOF := ProdPlan.Next(Direction) = 0;
                if not EOF then begin
                    Rec.Copy(ProdPlan);
                    exit(true);
                end;
            end;
        end;
    end;

    trigger OnInit()
    begin
        ItemTypeFilterText := '*';
    end;

    trigger OnModifyRecord(): Boolean
    begin
        ProdPlan := Rec;
        ProdPlan.Modify;
        exit(false);
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        NextRec: Record "Daily Production Planning";
        Direction: Integer;
        NoSteps: Integer;
        StepsTaken: Integer;
        EOF: Boolean;
    begin
        ProdPlan.Copy(Rec);
        if not FilterOnItem then begin
            StepsTaken := ProdPlan.Next(Steps);
            if StepsTaken <> 0 then
                Rec.Copy(ProdPlan);
            exit(StepsTaken);
        end else begin
            NextRec := Rec;
            Direction := 1;
            if Steps < 0 then
                Direction := -1;
            NoSteps := Direction * Steps;
            while (StepsTaken < NoSteps) and (not EOF) do begin
                EOF := ProdPlan.Next(Direction) = 0;
                if (not EOF) and ProdPlan.IncludesItem(Item."No.") then begin
                    NextRec := ProdPlan;
                    StepsTaken += 1;
                end;
            end;
            Rec := NextRec;
            exit(Direction * StepsTaken);
        end;
    end;

    trigger OnOpenPage()
    begin
        FilterOnItem := false;
        FilterOnEquipment := false;
        BaseDate := WorkDate;
        if DaysView = 0 then
            DaysView := 15;
        ShortagesOnly := false;
        OverCapacityOnly := false;

        SetDateRange;
        if LocationFilter <> '' then
            SetFilter("Location Code", LocationFilter);

        UpdateItemFilters;
        UpdateEquipmentFilters; // P8000256A
        if ParentPage = PAGE::"Daily Production Planning" then // P8001086
            FillProdPlanningTable;
        ProvisionalOrderNo := '***000000***';
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        // P8000263A
        if ParentPage <> PAGE::"Daily Production Planning" then // P8001086
            exit;                                                 // P8001086

        ProdPlan.Reset;
        ProdPlan.SetRange(Changed, true);
        if not ProdPlan.Find('-') then
            exit(true);

        exit(Confirm(Text004, false));
    end;

    var
        ProdPlan: Record "Daily Production Planning" temporary;
        Item: Record Item;
        Equipment: Record Resource;
        BOMVersion: Record "Production BOM Version";
        SalesBoardMgt: Codeunit "Sales Board Management";
        EquipBoardMgt: Codeunit "Equipment Board Management";
        [InDataSet]
        boldBool: Boolean;
        BaseDate: Date;
        DaysView: Integer;
        LocationFilter: Code[250];
        VariantFilter: Code[250];
        ItemCategoryFilter: Code[250];
        ResourceGroupFilter: Code[250];
        ProdPlanEntryNo: Integer;
        ProvisionalOrderNo: Code[20];
        ItemTypeFilter: Option "* MULTIPLE *"," ","(blank)","Raw Material",Packaging,Intermediate,"Finished Good",Container;
        ItemTypeFilterText: Text[250];
        ShortagesOnly: Boolean;
        FilterOnItem: Boolean;
        FilterOnEquipment: Boolean;
        ItemsActive: Boolean;
        EquipmentActive: Boolean;
        OverCapacityOnly: Boolean;
        EquipmentForMarkedItems: Code[20];
        ItemForMarkedEquipment: Code[20];
        Text001: Label '* MULTIPLE *';
        Text002: Label 'Changes are not allowed at the detail level.';
        Text003: Label 'This will commit all pending changes.\Continue?';
        Text004: Label 'Closing the form will cause pending changes to be discarded.\Continue?';
        dateMultiplier: Integer;
        [InDataSet]
        PrevEnabled: Boolean;
        [InDataSet]
        qtyColourFlag: Boolean;
        [InDataSet]
        locationColourFlag: Boolean;
        [InDataSet]
        equipColourFlag: Boolean;
        [InDataSet]
        seqColourFlag: Boolean;
        [InDataSet]
        dueColourFlag: Boolean;
        [InDataSet]
        startColourFlag: Boolean;
        [InDataSet]
        startTimeColourFlag: Boolean;
        [InDataSet]
        endColourFlag: Boolean;
        [InDataSet]
        endTimeColourFlag: Boolean;
        [InDataSet]
        genericColourFlag: Boolean;
        ParentPage: Integer;

    procedure SetDateRange()
    var
        dateFrm: Text[30];
        dateFrm2: Text[30];
    begin
        dateFrm := '+' + Format(dateMultiplier * DaysView) + 'D';
        dateFrm2 := '+' + Format(dateMultiplier * DaysView) + 'D +' + Format(DaysView - 1) + 'D';
    end;

    procedure UpdateItemFilters()
    begin
        LocationFilter := Item.GetFilter("Location Filter");
        VariantFilter := Item.GetFilter("Variant Filter");
        ItemCategoryFilter := Item.GetFilter("Item Category Code");
        if ItemTypeFilterText <> Item.GetFilter("Item Type") then begin
            ItemTypeFilterText := Item.GetFilter("Item Type");
            if ItemTypeFilterText = '' then
                ItemTypeFilter := 1
            else begin
                ItemTypeFilter := 2;
                while (ItemTypeFilterText <> Format(ItemTypeFilter)) and (ItemTypeFilter < 8) do
                    ItemTypeFilter := ItemTypeFilter + 1;
            end;
            if ItemTypeFilter = 8 then
                ItemTypeFilter := 0;
        end;
    end;

    procedure UpdateEquipmentFilters()
    begin
        // P8000256A
        ResourceGroupFilter := Equipment.GetFilter("Resource Group No.");
    end;

    procedure FillProdPlanningTable()
    var
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        VersionMgt: Codeunit VersionManagement;
        ProdOrderEntryNo: Integer;
        ProdOrderQty: Decimal;
        ProdOrderHours: array[2] of Decimal;
        VariableHours: Decimal;
        LineCount: Integer;
        ProdBOMNo: Code[20];
        VersionCode: Code[20];
        UOMCode: Code[10];
        SortValue: Integer;
    begin
        ProdPlan.Reset;
        ProdPlan.DeleteAll;

        ProdOrder.SetRange(Status, ProdOrder.Status::"Firm Planned", ProdOrder.Status::Released);
        ProdOrder.SetRange("Starting Date", 0D, BaseDate + DaysView - 1);
        ProdOrder.SetRange("Ending Date", BaseDate, DMY2Date(31, 12, 9999)); // P8007748
        ProdOrder.SetFilter(Quantity, '>0');
        if GetFilter("Equipment Code") <> '' then
            ProdOrder.SetFilter("Equipment Code", GetFilter("Equipment Code"));
        if ProdOrder.Find('-') then
            repeat
                ProdPlan.Init;
                ProdPlanEntryNo += 1;
                ProdPlan."Entry No." := ProdPlanEntryNo;
                ProdOrderEntryNo := ProdPlanEntryNo;
                ProdPlan.Status := ProdOrder.Status;
                ProdPlan."No." := ProdOrder."No.";
                ProdPlan."Item Description" := ProdOrder.Description;
                ProdPlan."Source Type" := 1 + ProdOrder."Source Type";
                ProdPlan."Source No." := ProdOrder."Source No.";
                // P80043682
                if ProdPlan."Source Type" = ProdPlan."Source Type"::Item then
                    ProdPlan."Item No." := ProdOrder."Source No.";
                // P80043682
                ProdPlan.Validate("Variant Code", ProdOrder."Variant Code");
                ProdPlan.Validate("Orig. Quantity", ProdOrder.Quantity);
                ProdOrderQty := ProdPlan."Orig. Quantity";
                ProdPlan.Validate("Orig. Location Code", ProdOrder."Location Code");
                ProdPlan.Validate("Orig. Equipment Code", ProdOrder."Equipment Code");
                ProdPlan.Validate("Orig. Sequence Code", ProdOrder."Production Sequence Code"); // P8000259A
                ProdPlan.Validate("Orig. Due Date", ProdOrder."Due Date");
                ProdPlan.Validate("Orig. Starting Date", ProdOrder."Starting Date");
                ProdPlan.Validate("Orig. Starting Time", ProdOrder."Starting Time");
                ProdPlan.Validate("Orig. Ending Date", ProdOrder."Ending Date");
                ProdPlan.Validate("Orig. Ending Time", ProdOrder."Ending Time");
                if ProdOrder."Family Process Order" then begin
                    ProdPlan."Production BOM No." := ProdOrder."Source No.";
                    ProdPlan."Version Code" := VersionMgt.GetBOMVersion(ProdOrder."Source No.", ProdOrder."Due Date", true);
                    ProdOrderEntryNo := 0;
                end;
                if ProdPlan."Source Type" = ProdPlan."Source Type"::Item then     // P80043682
                    ProdPlan.GetProdTime;
                ProdPlan."Orig. Fixed Time (Hours)" := ProdPlan."Fixed Time (Hours)";
                ProdPlan."Orig. Variable Time (Hours)" := ProdPlan."Variable Time (Hours)";
                ProdPlan.Display := true;
                ProdPlan.Insert;

                LineCount := 0;
                Clear(ProdOrderHours);
                ProdOrderLine.SetRange(Status, ProdOrder.Status);
                ProdOrderLine.SetRange("Prod. Order No.", ProdOrder."No.");
                ProdOrderLine.SetFilter("Item No.", '<>%1', '');              // P80043682
                if GetFilter("Item No.") <> '' then
                    ProdOrderLine.SetRange("Item No.", GetFilter("Item No."));
                if ProdOrderLine.Find('-') then
                    repeat
                        ProdPlan.Init;
                        ProdPlanEntryNo += 1;
                        ProdPlan.Indentation := 1;  // P8000789
                        ProdPlan."Entry No." := ProdPlanEntryNo;
                        ProdPlan.Status := ProdOrderLine.Status;
                        ProdPlan."No." := ProdOrderLine."Prod. Order No.";
                        ProdPlan."Line No." := ProdOrderLine."Line No.";
                        ProdPlan."Source Type" := 1 + ProdOrder."Source Type";   // P8000789
                        ProdPlan."Source No." := ProdOrder."Source No.";         // P8000789
                        ProdPlan.Validate("Item No.", ProdOrderLine."Item No.");
                        ProdPlan.Validate("Variant Code", ProdOrderLine."Variant Code");
                        ProdPlan.Validate("Unit of Measure Code", ProdOrderLine."Unit of Measure Code");
                        ProdPlan.Validate("Orig. Quantity", ProdOrderLine.Quantity);
                        ProdPlan.Validate("Orig. Location Code", ProdOrder."Location Code");
                        ProdPlan.Validate("Orig. Equipment Code", ProdOrder."Equipment Code");
                        ProdPlan.Validate("Orig. Due Date", ProdOrderLine."Due Date");
                        ProdPlan.Validate("Orig. Starting Date", ProdOrderLine."Starting Date");
                        ProdPlan.Validate("Orig. Starting Time", ProdOrderLine."Starting Time");
                        ProdPlan.Validate("Orig. Ending Date", ProdOrderLine."Ending Date");
                        ProdPlan.Validate("Orig. Ending Time", ProdOrderLine."Ending Time");
                        ProdPlan."Production BOM No." := ProdOrderLine."Production BOM No.";
                        ProdPlan."Version Code" := ProdOrderLine."Production BOM Version Code";
                        ProdPlan."Quantity Factor" := ProdPlan.Quantity / ProdOrderQty;
                        ProdPlan.GetProdTime;
                        ProdPlan."Orig. Fixed Time (Hours)" := ProdPlan."Fixed Time (Hours)";
                        ProdPlan."Orig. Variable Time (Hours)" := ProdPlan."Variable Time (Hours)";
                        if ProdOrderHours[1] < ProdPlan."Fixed Time (Hours)" then
                            ProdOrderHours[1] := ProdPlan."Fixed Time (Hours)";
                        if ProdPlan.Quantity <> 0 then begin
                            VariableHours := ProdPlan."Variable Time (Hours)" / ProdPlan."Quantity Factor";
                            if ProdOrderHours[2] < VariableHours then
                                ProdOrderHours[2] := VariableHours;
                        end;
                        if LineCount = 0 then begin
                            ProdBOMNo := ProdOrderLine."Production BOM No.";
                            VersionCode := ProdOrderLine."Production BOM Version Code";
                            UOMCode := ProdOrderLine."Unit of Measure Code";
                        end else begin
                            ProdBOMNo := '';
                            VersionCode := '';
                            UOMCode := '';
                        end;
                        LineCount += 1;
                        ProdPlan.Insert;
                    until ProdOrderLine.Next = 0
                else begin
                    ProdPlan.Delete;
                    ProdOrderEntryNo := 0;
                end;
                if ProdOrderEntryNo <> 0 then begin
                    ProdPlan.Get(ProdOrderEntryNo);
                    //ProdPlan."Production BOM No." := ProdBOMNo;
                    //ProdPlan."Version Code" := VersionCode;
                    ProdPlan."Unit of Measure Code" := UOMCode;
                    ProdPlan."Orig. Fixed Time (Hours)" := ProdOrderHours[1];
                    ProdPlan."Orig. Variable Time (Hours)" := ProdOrderHours[2];
                    ProdPlan."Fixed Time (Hours)" := ProdOrderHours[1];
                    ProdPlan."Variable Time (Hours)" := ProdOrderHours[2];
                    ProdPlan.Modify;
                end;
            until ProdOrder.Next = 0;

        // P8000259A Begin
        ProdPlan.SetCurrentKey("Location Code", "Equipment Code", "Starting Date", "Sequence Value");
        ProdPlan.SetRange("Line No.", 0);
        if ProdPlan.Find('-') then
            repeat
                SortValue += 10000;
                ProdPlan.SetRange(Status, ProdPlan.Status);
                ProdPlan.SetRange("No.", ProdPlan."No.");
                ProdPlan.SetRange("Line No.");
                ProdPlan.ModifyAll("Sort Value", SortValue);
                ProdPlan.SetRange("Line No.", 0);
                ProdPlan.SetRange("No.");
                ProdPlan.SetRange(Status);
            until ProdPlan.Next = 0;
        ProdPlan.Reset;
        // P8000259A End
    end;

    procedure SetProdPlanFilter()
    begin
        FilterGroup(9);
        if FilterOnItem then
            SetRange("Equipment Code")
        else
            if FilterOnEquipment then
                SetRange("Equipment Code", Equipment."No.")
            else
                SetRange("Equipment Code");
        FilterGroup(0);

        CurrPage.Update;
    end;

    procedure FindSortValue(var ProdPlan: Record "Daily Production Planning" temporary; NewProdPlan: Record "Daily Production Planning") SortValue: Decimal
    begin
        // P8000259A Begin
        ProdPlan.Reset;
        ProdPlan.SetCurrentKey("Location Code", "Equipment Code", "Starting Date", "Sequence Value");
        if NewProdPlan."Entry No." <> 0 then begin
            ProdPlan.Get(NewProdPlan."Entry No.");
            if (ProdPlan."Location Code" = NewProdPlan."Location Code") and
              (ProdPlan."Equipment Code" = NewProdPlan."Equipment Code") and
              (ProdPlan."Starting Date" = NewProdPlan."Starting Date") and
              (ProdPlan."Sequence Value" = NewProdPlan."Sequence Value")
            then begin
                ProdPlan.Reset;
                exit(ProdPlan."Sort Value");
            end;
            ProdPlan.SetFilter("Entry No.", '<>%1', NewProdPlan."Entry No.");
        end;
        ProdPlan.SetRange("Line No.", 0);
        ProdPlan."Location Code" := NewProdPlan."Location Code";
        ProdPlan."Equipment Code" := NewProdPlan."Equipment Code";
        ProdPlan."Starting Date" := NewProdPlan."Starting Date";
        ProdPlan."Sequence Value" := NewProdPlan."Sequence Value";
        if ProdPlan.Find('>') then begin
            SortValue := ProdPlan."Sort Value";
            if ProdPlan.Next(-1) <> 0 then
                SortValue += ProdPlan."Sort Value";
            SortValue := SortValue / 2;
        end else begin
            if ProdPlan.Find('+') then
                SortValue := ProdPlan."Sort Value" + 10000
            else
                SortValue := 10000;
        end;
        ProdPlan.Reset;
    end;

    procedure Recalculate()
    var
        Location: Record Location;
        MfgSetup: Record "Manufacturing Setup";
        ProdPlan2: Record "Daily Production Planning";
        NextStartDate: Date;
        NextStartTime: Time;
        RecordsToAdvance: Integer;
    begin
        // P8000259A
        MfgSetup.Get;
        FilterOnItem := false;
        SetProdPlanFilter;
        SetView('');
        SetCurrentKey("Sort Value");
        //RESET;
        ProdPlan.Copy(Rec);
        //ProdPlan.SETRANGE("Line No.",0);
        if ProdPlan.Find('-') then
            repeat
                if not Location.Get(ProdPlan."Location Code") then
                    Clear(Location);
                if Location."Normal Starting Time" = 0T then
                    Location."Normal Starting Time" := MfgSetup."Normal Starting Time";
                ProdPlan.SetRange("Location Code", ProdPlan."Location Code");
                ProdPlan.SetRange("Equipment Code", ProdPlan."Equipment Code");
                ProdPlan.SetFilter("Starting Date", '<%1', WorkDate);
                if ProdPlan.Find('+') then begin
                    NextStartDate := ProdPlan."Ending Date";
                    NextStartTime := ProdPlan."Ending Time";
                    RecordsToAdvance := 1;
                end else begin
                    NextStartDate := WorkDate;
                    NextStartTime := Location."Normal Starting Time";
                    RecordsToAdvance := 0;
                end;
                ProdPlan.SetRange("Starting Date");
                if ProdPlan.Next(RecordsToAdvance) = RecordsToAdvance then
                    repeat
                        if NextStartDate > ProdPlan."Starting Date" then
                            ProdPlan."Starting Date" := NextStartDate;
                        if NextStartDate = ProdPlan."Starting Date" then
                            ProdPlan.Validate("Starting Time", NextStartTime)
                        else
                            ProdPlan.Validate("Starting Time", Location."Normal Starting Time");
                        ProdPlan.SetChanged;
                        ProdPlan.Modify;
                        NextStartDate := ProdPlan."Ending Date";
                        NextStartTime := ProdPlan."Ending Time";

                        // Update lines
                        ProdPlan2.Copy(ProdPlan);
                        ProdPlan.Reset;
                        ProdPlan.SetRange(Status, ProdPlan2.Status);
                        ProdPlan.SetRange("No.", ProdPlan2."No.");
                        ProdPlan.SetFilter("Line No.", '<>0');
                        if ProdPlan.Find('-') then
                            repeat
                                ProdPlan."Starting Time" := ProdPlan2."Starting Time";
                                ProdPlan."Starting Date" := ProdPlan2."Starting Date";
                                ProdPlan."Ending Time" := ProdPlan2."Ending Time";
                                ProdPlan."Ending Date" := ProdPlan2."Ending Date";
                                ProdPlan.GetProdTime;
                                ProdPlan.CalculateDates(ProdPlan.FieldNo("Starting Date"), false);
                                ProdPlan.Modify;
                            until ProdPlan.Next = 0;
                        ProdPlan.Copy(ProdPlan2);
                    until ProdPlan.Next = 0;
                ProdPlan.SetRange("Location Code");
                ProdPlan.SetRange("Equipment Code");
            until ProdPlan.Next = 0;
        ProdPlan.Reset;
    end;

    procedure AddOrder(iItem: Record Item; var ioProdPlan: Record "Daily Production Planning")
    var
        ProdPlan3: Record "Daily Production Planning" temporary;
        ProdBOMEquip: Record "Prod. BOM Equipment";
        Location: Record Location;
        PreferredEquipment: Record "Prod. BOM Equipment";
        Resource: Record Resource;
        VersionMgt: Codeunit VersionManagement;
        OrderForm: Page "Daily Prod. Planning-Order";
        SortValue: Decimal;
    begin
        Item := iItem;
        Item.TestField("Production BOM No.");

        ProdPlan3.Status := ProdPlan3.Status::Released;
        ProdPlan3."Source Type" := ProdPlan3."Source Type"::Item;
        ProdPlan3."Source No." := Item."No.";
        ProdPlan3.Validate("Item No.", Item."No.");
        ProdPlan3."Production BOM No." := Item."Production BOM No.";
        ProdPlan3."Version Code" := VersionMgt.GetBOMVersion(ProdPlan3."Production BOM No.", WorkDate, true);
        BOMVersion.Get(ProdPlan3."Production BOM No.", ProdPlan3."Version Code");   // P8000259A
        ProdPlan3.Validate("Sequence Code", BOMVersion."Production Sequence Code"); // P8000259A
        ProdBOMEquip.SetCurrentKey("Production Bom No.", "Version Code", "Resource No.");
        ProdBOMEquip.SetRange("Production Bom No.", ProdPlan3."Production BOM No.");
        ProdBOMEquip.SetRange("Version Code", ProdPlan3."Version Code");
        PreferredEquipment.Preference := 99;
        if ProdBOMEquip.Find('-') then begin
            repeat
                if ProdBOMEquip.Preference < PreferredEquipment.Preference then begin
                    PreferredEquipment."Resource No." := ProdBOMEquip."Resource No.";
                    PreferredEquipment.Preference := ProdBOMEquip.Preference;
                end;
            until ProdBOMEquip.Next = 0;
            Resource.Get(PreferredEquipment."Resource No.");
            ProdPlan3.Validate("Location Code", Resource."Location Code");
            ProdPlan3.Validate("Equipment Code", Resource."No.");
        end;
        if (LocationFilter <> '') and (ProdPlan3."Equipment Code" = '') then begin
            Location.SetFilter(Code, LocationFilter);
            if Location.Find('-') and (0 = Location.Next) then
                ProdPlan3.Validate("Location Code", Location.Code);
        end;
        ProdPlan3.Insert;

        if PAGE.RunModal(37002506, ProdPlan3) = ACTION::LookupOK then begin

            ProdPlan3.Find('-');
            SortValue := FindSortValue(ProdPlan, ProdPlan3); // P8000259A
            ProdPlan := ProdPlan3;
            ProdPlanEntryNo += 1;
            ProdPlan."Entry No." := ProdPlanEntryNo;
            ProdPlan."Sort Value" := SortValue; // P8000259A
            ProvisionalOrderNo := IncStr(ProvisionalOrderNo);
            ProdPlan."No." := ProvisionalOrderNo;
            ProdPlan.Display := true;
            ProdPlan."Item No." := '';
            ProdPlan.SetChanged; // P8000263A
            ProdPlan.Insert;

            ProdOrderChangeEquip(ProdPlan, false); // P8001086

            // Add line
            ProdPlanEntryNo += 1;
            ProdPlan."Entry No." := ProdPlanEntryNo;
            ProdPlan."Line No." := 10000;
            ProdPlan."Sort Value" := SortValue; // P8000259A
            ProdPlan."Source Type" := 0;
            ProdPlan."Source No." := '';
            ProdPlan."Item No." := Item."No.";
            ProdPlan.Validate("Unit of Measure Code", Item."Base Unit of Measure");
            ProdPlan."Quantity (Base)" := Round(ProdPlan.Quantity * ProdPlan."Qty. per Unit of Measure", 0.00001);
            ProdPlan."Quantity Factor" := 1;
            ProdPlan.Display := false;
            ProdPlan.Insert;
            ProdOrderChangeItem(ProdPlan, false); // P8001086
            ioProdPlan := ProdPlan;

            ProdPlan.Get(ProdPlanEntryNo - 1);
            Rec := ProdPlan;
        end;
        //CurrPage.UPDATE(TRUE);
    end;

    procedure CommitChanges()
    var
        Window: Dialog;
        RecCount: Integer;
        RecNo: Integer;
    begin
        if not Confirm(Text003, false) then
            exit;

        ProdPlan.Reset;
        ProdPlan.SetRange("Line No.", 0);
        ProdPlan.SetRange(Changed, true);
        if ProdPlan.Find('-') then begin
            Window.Open('@1@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
            RecCount := ProdPlan.Count;
            repeat
                ProdPlan.CommitChanges;
                ProdOrderChangeItem(ProdPlan, true);  // P8001086
                ProdOrderChangeEquip(ProdPlan, true); // P8001086
                RecNo += 1;
                Window.Update(1, (9999 * RecNo) div RecCount);
            until ProdPlan.Next = 0;
            Window.Close;
        end;

        ProdPlan.Reset;
        ProdPlan.DeleteAll;
        FillProdPlanningTable;
    end;

    procedure SetSharedCodeunits(var iSalesBoardMgt: Codeunit "Sales Board Management"; var iEquipBoardMgt: Codeunit "Equipment Board Management"; CalledFrom: Integer)
    begin
        // Add paremeters for iEquipBoardMgt and CalledFrom
        SalesBoardMgt := iSalesBoardMgt;
        EquipBoardMgt := iEquipBoardMgt; // P8001086
        ParentPage := CalledFrom;        // P8001086
    end;

    procedure ProdOrderChangeItem(ProdPlan: Record "Daily Production Planning"; DeleteFlag: Boolean)
    var
        ProdPlanChange: Record "Daily Prod. Planning-Change" temporary;
        ProdOrderComponent: Record "Prod. Order Component";
        Item: Record Item;
        RequiredItem: Record "Where-Used Line" temporary;
        ProdBoardMgt: Codeunit "Production Board Management";
        Qty: Decimal;
        QtyBase: Decimal;
        DaysDiff: Integer;
        SimpleChange: Boolean;
    begin
        with ProdPlan do begin
            if DeleteFlag then begin
                ProdPlanChange.Status := ProdPlan.Status;
                ProdPlanChange."Production Order No." := ProdPlan."No.";
            end else begin
                // A simple change is one where we only have to update an existing record, otherwise we have to create
                // two changes - a negative change for the original location/date and a positive for the new
                // location/date
                SimpleChange := (CopyStr(ProdPlan."No.", 1, 3) = '***') or
                  (("Location Code" = "Orig. Location Code") and ("Due Date" = "Orig. Due Date"));

                // Changes to item produced
                ProdPlanChange.Status := Status;
                ProdPlanChange."Production Order No." := "No.";
                ProdPlanChange."Prod. Order Line No." := "Line No.";
                ProdPlanChange.Type := ProdPlanChange.Type::Output;
                ProdPlanChange."Item No." := "Item No.";
                ProdPlanChange."Variant Code" := "Variant Code";
                ProdPlanChange."Location Code" := "Location Code";
                ProdPlanChange.Date := "Due Date";
                ProdPlanChange.Quantity := Quantity;
                ProdPlanChange."Quantity (Base)" := "Quantity (Base)";
                if SimpleChange then begin
                    ProdPlanChange.Quantity -= ProdPlan."Orig. Quantity";
                    ProdPlanChange."Quantity (Base)" -= ProdPlan."Orig. Quantity (Base)";
                    ProdPlanChange.Insert;
                end else begin
                    ProdPlanChange.Insert;
                    ProdPlanChange."Location Code" := "Orig. Location Code";
                    ProdPlanChange.Date := "Orig. Due Date";
                    ProdPlanChange.Quantity := -"Orig. Quantity";
                    ProdPlanChange."Quantity (Base)" := -"Orig. Quantity (Base)";
                    ProdPlanChange.Insert;
                end;

                // Changes to items consumed
                if CopyStr(ProdPlan."No.", 1, 3) = '***' then begin
                    // New orders will require going to the BOM to find the components
                    ProdBoardMgt.GetRequiredItems(ProdPlan."Item No.", ProdPlan."Quantity (Base)", ProdPlan."Due Date",
                      RequiredItem);
                    RequiredItem.Reset;
                    RequiredItem.SetRange("Level Code", 1);
                    if RequiredItem.Find('-') then
                        repeat
                            Item.Get(RequiredItem."Item No.");
                            ProdPlanChange.Init;
                            ProdPlanChange.Status := Status;
                            ProdPlanChange."Production Order No." := "No.";
                            ProdPlanChange."Prod. Order Line No." := "Line No.";
                            ProdPlanChange.Type := ProdPlanChange.Type::Consumption;
                            ProdPlanChange."Item No." := RequiredItem."Item No.";
                            ProdPlanChange."Variant Code" := '';
                            ProdPlanChange."Location Code" := "Location Code";
                            ProdPlanChange.Date := "Due Date" - 1;
                            if not ProdPlanChange.Find then
                                ProdPlanChange.Insert;
                            ProdPlanChange.Quantity += RequiredItem."Quantity Needed";
                            ProdPlanChange."Quantity (Base)" += RequiredItem."Quantity Needed";
                            ProdPlanChange.Modify;
                        until RequiredItem.Next = 0;
                end else begin
                    // Existing order will be changed based on the production order component lines
                    ProdOrderComponent.SetRange(Status, Status);
                    ProdOrderComponent.SetRange("Prod. Order No.", "No.");
                    ProdOrderComponent.SetRange("Prod. Order Line No.", "Line No.");
                    if ProdOrderComponent.Find('-') then
                        repeat
                            Item.Get(ProdOrderComponent."Item No.");
                            DaysDiff := "Due Date" - "Orig. Due Date";
                            ProdPlanChange.Init;
                            ProdPlanChange.Status := Status;
                            ProdPlanChange."Production Order No." := "No.";
                            ProdPlanChange."Prod. Order Line No." := "Line No.";
                            ProdPlanChange.Type := ProdPlanChange.Type::Consumption;
                            ProdPlanChange."Item No." := ProdOrderComponent."Item No.";
                            ProdPlanChange."Variant Code" := ProdOrderComponent."Variant Code";
                            ProdPlanChange."Location Code" := ProdOrderComponent."Location Code";
                            ProdPlanChange.Date := ProdOrderComponent."Due Date" + DaysDiff;
                            Qty := Quantity * ProdOrderComponent.Quantity * (1 + ProdOrderComponent."Scrap %" / 100);
                            if Item.GetItemUOMRndgPrecision(ProdOrderComponent."Unit of Measure Code", false) then
                                Qty := Round(Qty, Item."Rounding Precision", '>');
                            QtyBase := Qty * ProdOrderComponent."Qty. per Unit of Measure";
                            if SimpleChange then begin
                                if not ProdPlanChange.Find then
                                    ProdPlanChange.Insert;
                                ProdPlanChange.Quantity += Qty - ProdOrderComponent."Expected Quantity";
                                ProdPlanChange."Quantity (Base)" += QtyBase - ProdOrderComponent."Expected Qty. (Base)";
                                ProdPlanChange.Modify;
                            end else begin
                                if not ProdPlanChange.Find then
                                    ProdPlanChange.Insert;
                                ProdPlanChange.Quantity += Qty;
                                ProdPlanChange."Quantity (Base)" += QtyBase;
                                ProdPlanChange.Modify;

                                ProdPlanChange.Init;
                                ProdPlanChange."Location Code" := "Orig. Location Code";
                                ProdPlanChange.Date := ProdOrderComponent."Due Date";
                                if not ProdPlanChange.Find then
                                    ProdPlanChange.Insert;
                                ProdPlanChange.Quantity -= Qty;
                                ProdPlanChange."Quantity (Base)" -= QtyBase;
                                ProdPlanChange.Modify;
                            end;
                        until ProdOrderComponent.Next = 0;
                end;
            end;
        end;

        SalesBoardMgt.AddProductionChanges(ProdPlanChange);
        //CurrForm.UPDATE(FALSE);  // P8000789
    end;

    procedure ProdOrderChangeEquip(ProdPlan: Record "Daily Production Planning"; DeleteFlag: Boolean)
    var
        ProdPlanChange: Record "Daily Prod. Planning-Change" temporary;
        ProdDateTime1: Record "Production Time by Date" temporary;
        ProdDateTime2: Record "Production Time by Date" temporary;
        P800CalMgt: Codeunit "Process 800 Calendar Mngt.";
    begin
        // P8001086 - pulled in from  Daily Prod. Planning-Equipment
        with ProdPlan do begin
            if DeleteFlag then begin
                ProdPlanChange.Status := ProdPlan.Status;
                ProdPlanChange."Production Order No." := ProdPlan."No.";
            end else begin
                if CopyStr(ProdPlan."No.", 1, 3) <> '***' then
                    P800CalMgt.GetProductionDateTime(ProdPlan."Orig. Location Code",
                      ProdPlan."Orig. Starting Date", ProdPlan."Orig. Starting Time",
                      ProdPlan."Orig. Ending Date", ProdPlan."Orig. Ending Time", ProdDateTime1);
                P800CalMgt.GetProductionDateTime(ProdPlan."Location Code",
                  ProdPlan."Starting Date", ProdPlan."Starting Time",
                  ProdPlan."Ending Date", ProdPlan."Ending Time", ProdDateTime2);

                ProdPlanChange.Status := ProdPlan.Status;
                ProdPlanChange."Production Order No." := ProdPlan."No.";
                ProdPlanChange.Description := ProdPlan."Item Description";
                ProdPlanChange.Type := ProdPlanChange.Type::"Prod. Time";
                if ProdPlan."Orig. Equipment Code" <> ProdPlan."Equipment Code" then begin
                    if ProdDateTime1.Find('-') then begin
                        ProdPlanChange."Equipment Code" := ProdPlan."Orig. Equipment Code";
                        ProdPlanChange."Location Code" := ProdPlan."Orig. Location Code";
                        repeat
                            ProdPlanChange.Date := ProdDateTime1.Date;
                            ProdPlanChange."Starting Time" := ProdDateTime1."Starting Time";
                            ProdPlanChange."Ending Time" := ProdDateTime1."Starting Time" + ProdDateTime1."Time Required";
                            ProdPlanChange.Duration := -ProdDateTime1."Time Required";
                            ProdPlanChange.Insert;
                        until ProdDateTime1.Next = 0;
                    end;
                    if ProdDateTime2.Find('-') then begin
                        ProdPlanChange."Equipment Code" := ProdPlan."Equipment Code";
                        ProdPlanChange."Location Code" := ProdPlan."Location Code";
                        repeat
                            ProdPlanChange.Date := ProdDateTime2.Date;
                            ProdPlanChange."Starting Time" := ProdDateTime2."Starting Time";
                            ProdPlanChange."Ending Time" := ProdDateTime2."Starting Time" + ProdDateTime2."Time Required";
                            ProdPlanChange.Duration := ProdDateTime2."Time Required";
                            ProdPlanChange.Insert;
                        until ProdDateTime2.Next = 0;
                    end;
                end else begin
                    ProdPlanChange."Equipment Code" := ProdPlan."Orig. Equipment Code";
                    ProdPlanChange."Location Code" := ProdPlan."Orig. Location Code";
                    if ProdDateTime1.Find('-') then
                        repeat
                            if ProdDateTime2.Get(ProdDateTime1.Date) then begin
                                if (ProdDateTime1."Time Required" <> ProdDateTime2."Time Required") or
                                  (ProdDateTime1."Starting Time" <> ProdDateTime2."Starting Time")
                                then begin
                                    ProdPlanChange.Date := ProdDateTime2.Date;
                                    ProdPlanChange."Starting Time" := ProdDateTime2."Starting Time";
                                    ProdPlanChange."Ending Time" := ProdDateTime2."Starting Time" + ProdDateTime2."Time Required";
                                    ProdPlanChange.Duration := ProdDateTime2."Time Required" - ProdDateTime1."Time Required";
                                    ProdPlanChange.Insert;
                                end;
                                ProdDateTime2.Delete;
                            end else begin
                                ProdPlanChange.Date := ProdDateTime1.Date;
                                ProdPlanChange."Starting Time" := ProdDateTime1."Starting Time";
                                ProdPlanChange."Ending Time" := ProdDateTime1."Starting Time" + ProdDateTime1."Time Required";
                                ProdPlanChange.Duration := -ProdDateTime1."Time Required";
                                ProdPlanChange.Insert;
                            end;
                        until ProdDateTime1.Next = 0;
                    if ProdDateTime2.Find('-') then
                        repeat
                            ProdPlanChange.Date := ProdDateTime2.Date;
                            ProdPlanChange."Starting Time" := ProdDateTime2."Starting Time";
                            ProdPlanChange."Ending Time" := ProdDateTime2."Starting Time" + ProdDateTime2."Time Required";
                            ProdPlanChange.Duration := ProdDateTime2."Time Required";
                            ProdPlanChange.Insert;
                        until ProdDateTime2.Next = 0;
                end;
            end;
        end;

        EquipBoardMgt.AddProductionChanges(ProdPlanChange);
        //CurrPage.UPDATE(FALSE);  // P8000789
    end;

    procedure SetDisplayColor()
    begin
        locationColourFlag := false;
        equipColourFlag := false;
        dueColourFlag := false;
        startColourFlag := false;
        startTimeColourFlag := false;
        endColourFlag := false;
        endTimeColourFlag := false;
        qtyColourFlag := false;
        genericColourFlag := false;

        if CopyStr("No.", 1, 3) = '***' then begin
            locationColourFlag := true;
            equipColourFlag := true;
            dueColourFlag := true;
            startColourFlag := true;
            startTimeColourFlag := true;
            endColourFlag := true;
            endTimeColourFlag := true;
            qtyColourFlag := true;
            genericColourFlag := true;
        end;

        if "Location Code" <> "Orig. Location Code" then
            locationColourFlag := true;
        if "Equipment Code" <> "Orig. Equipment Code" then
            equipColourFlag := true;
        if "Sequence Code" <> "Orig. Sequence Code" then
            seqColourFlag := true;
        if "Due Date" <> "Orig. Due Date" then
            dueColourFlag := true;
        if "Starting Date" <> "Orig. Starting Date" then
            startColourFlag := true;
        if "Starting Time" <> "Orig. Starting Time" then
            startTimeColourFlag := true;
        if "Ending Date" <> "Orig. Ending Date" then
            endColourFlag := true;
        if "Ending Time" <> "Orig. Ending Time" then
            endTimeColourFlag := true;
        if Quantity <> "Orig. Quantity" then
            qtyColourFlag := true;
    end;

    procedure GetRecords(var ProdPlanRec: Record "Daily Production Planning" temporary)
    begin
        // P8001086
        ProdPlanRec.Copy(ProdPlan, true);
        ProdPlanRec.Reset;
    end;

    procedure SetRecords(var ProdPlanRec: Record "Daily Production Planning" temporary)
    begin
        // P8001086
        ProdPlan.Copy(ProdPlanRec, true);
    end;
}

