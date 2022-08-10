page 37002683 "Commodity Cost Periods"
{
    // PRW16.00.04
    // P8000856, VerticalSoft, Don Bresee, 03 NOV 10
    //   Add Commodity Class Costing granule
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Commodity Cost Periods';
    LinksAllowed = false;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Commodity Cost Period";
    SourceTableView = SORTING("Location Code", "Starting Market Date");
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(Control37002002)
            {
                ShowCaption = false;
                field(CommClassCode; CommClassCode)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Commodity Class Code';
                    TableRelation = "Commodity Class";

                    trigger OnValidate()
                    begin
                        MATRIX_LoadColumns(MATRIX_Action::Initial);
                        CurrPage.Update(false);
                    end;
                }
            }
            repeater(Control37002013)
            {
                FreezeColumn = "Calculate Cost";
                ShowCaption = false;
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = UseLocation;
                    Visible = UseLocation;
                }
                field("Starting Market Date"; "Starting Market Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Calculate Cost"; "Calculate Cost")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Field1; MATRIX_CellData[1])
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[1];
                    DecimalPlaces = 2 : 12;
                    Enabled = MATRIX_NoOfColumns >= 1;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(1);
                    end;

                    trigger OnValidate()
                    begin
                        MATRIX_OnValidate(1);
                    end;
                }
                field(Field2; MATRIX_CellData[2])
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[2];
                    DecimalPlaces = 2 : 12;
                    Enabled = MATRIX_NoOfColumns >= 2;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(2);
                    end;

                    trigger OnValidate()
                    begin
                        MATRIX_OnValidate(2);
                    end;
                }
                field(Field3; MATRIX_CellData[3])
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[3];
                    DecimalPlaces = 2 : 12;
                    Enabled = MATRIX_NoOfColumns >= 3;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(3);
                    end;

                    trigger OnValidate()
                    begin
                        MATRIX_OnValidate(3);
                    end;
                }
                field(Field4; MATRIX_CellData[4])
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[4];
                    DecimalPlaces = 2 : 12;
                    Enabled = MATRIX_NoOfColumns >= 4;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(4);
                    end;

                    trigger OnValidate()
                    begin
                        MATRIX_OnValidate(4);
                    end;
                }
                field(Field5; MATRIX_CellData[5])
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[5];
                    DecimalPlaces = 2 : 12;
                    Enabled = MATRIX_NoOfColumns >= 5;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(5);
                    end;

                    trigger OnValidate()
                    begin
                        MATRIX_OnValidate(5);
                    end;
                }
                field(Field6; MATRIX_CellData[6])
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[6];
                    DecimalPlaces = 2 : 12;
                    Enabled = MATRIX_NoOfColumns >= 6;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(6);
                    end;

                    trigger OnValidate()
                    begin
                        MATRIX_OnValidate(6);
                    end;
                }
                field(Field7; MATRIX_CellData[7])
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[7];
                    DecimalPlaces = 2 : 12;
                    Enabled = MATRIX_NoOfColumns >= 7;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(7);
                    end;

                    trigger OnValidate()
                    begin
                        MATRIX_OnValidate(7);
                    end;
                }
                field(Field8; MATRIX_CellData[8])
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[8];
                    DecimalPlaces = 2 : 12;
                    Enabled = MATRIX_NoOfColumns >= 8;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(8);
                    end;

                    trigger OnValidate()
                    begin
                        MATRIX_OnValidate(8);
                    end;
                }
                field(Field9; MATRIX_CellData[9])
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[9];
                    DecimalPlaces = 2 : 12;
                    Enabled = MATRIX_NoOfColumns >= 9;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(9);
                    end;

                    trigger OnValidate()
                    begin
                        MATRIX_OnValidate(9);
                    end;
                }
                field(Field10; MATRIX_CellData[10])
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[10];
                    DecimalPlaces = 2 : 12;
                    Enabled = MATRIX_NoOfColumns >= 10;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(10);
                    end;

                    trigger OnValidate()
                    begin
                        MATRIX_OnValidate(10);
                    end;
                }
                field(Field11; MATRIX_CellData[11])
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[11];
                    DecimalPlaces = 2 : 12;
                    Enabled = MATRIX_NoOfColumns >= 11;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(11);
                    end;

                    trigger OnValidate()
                    begin
                        MATRIX_OnValidate(11);
                    end;
                }
                field(Field12; MATRIX_CellData[12])
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[12];
                    DecimalPlaces = 2 : 12;
                    Enabled = MATRIX_NoOfColumns >= 12;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(12);
                    end;

                    trigger OnValidate()
                    begin
                        MATRIX_OnValidate(12);
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Previous Set")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Previous Set';
                Enabled = MATRIX_PreviousEnabled;
                Image = PreviousSet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Previous Set';

                trigger OnAction()
                begin
                    MATRIX_LoadColumns(MATRIX_Action::Previous);
                end;
            }
            action("Previous Column")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Previous Column';
                Enabled = MATRIX_PreviousEnabled;
                Image = PreviousRecord;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    MATRIX_LoadColumns(MATRIX_Action::PreviousColumn);
                end;
            }
            action("Next Column")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Next Column';
                Enabled = MATRIX_NextEnabled;
                Image = Column;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    MATRIX_LoadColumns(MATRIX_Action::NextColumn);
                end;
            }
            action("Next Set")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Next Set';
                Enabled = MATRIX_NextEnabled;
                Image = NextSet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Next Set';

                trigger OnAction()
                begin
                    MATRIX_LoadColumns(MATRIX_Action::Next);
                end;
            }
            separator(Separator37002009)
            {
            }
            action("&Post")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Post';
                Ellipsis = true;
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    CommCostMgmt: Codeunit "Commodity Cost Management";
                begin
                    CurrPage.SaveRecord;
                    CommCostMgmt.ImplementCostChanges(Rec);
                    CurrPage.Update(false);
                end;
            }
            separator(Separator37002011)
            {
            }
            action("&Orders")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Orders';
                Ellipsis = true;
                Image = "Order";
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    CurrPage.SaveRecord;
                    Commit;
                    REPORT.RunModal(REPORT::"Update Commodity Orders");
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        MATRIX_OnAfterGetRecord;
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.SetSelectionFilter(CommClassPeriod);
        if CommClassPeriod.FindSet then
            repeat
                CommClassPeriod.Delete(true);
            until (CommClassPeriod.Next = 0);
        exit(false);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        SetCurrentKey("Location Code", "Starting Market Date");
        exit(Find(Which));
    end;

    trigger OnInit()
    begin
        InvtSetup.Get;
        UseLocation := InvtSetup."Commodity Cost by Location";
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        TestLocationAndDate;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        TestLocationAndDate;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        MATRIX_OnAfterGetRecord;
    end;

    trigger OnOpenPage()
    begin
        MATRIX_LoadColumns(MATRIX_Action::Initial);
    end;

    var
        CommClassCode: Code[20];
        [InDataSet]
        UseLocation: Boolean;
        InvtSetup: Record "Inventory Setup";
        CommClassPeriod: Record "Commodity Cost Period";
        MATRIX_Action: Option Initial,Previous,Same,Next,PreviousColumn,NextColumn;
        MATRIX_Rec: array[12] of Record "Comm. Cost Setup Line";
        [InDataSet]
        MATRIX_NoOfColumns: Integer;
        MATRIX_MaxNoOfColumns: Integer;
        MATRIX_ColumnOffset: Integer;
        MATRIX_CellData: array[12] of Decimal;
        MATRIX_CaptionSet: array[12] of Text[1024];
        [InDataSet]
        MATRIX_NextEnabled: Boolean;
        [InDataSet]
        MATRIX_PreviousEnabled: Boolean;
        Text000: Label 'n/a';

    local procedure MATRIX_LoadColumns(RequestedAction: Integer)
    var
        CommCostSetup: Record "Comm. Cost Setup Line";
        ColumnID: Integer;
    begin
        Clear(MATRIX_Rec);
        Clear(MATRIX_CaptionSet);
        Clear(MATRIX_NoOfColumns);
        if (CommClassCode <> '') then
            CommCostSetup.SetRange("Commodity Class Code", CommClassCode);
        MATRIX_MaxNoOfColumns := CommCostSetup.Count;
        case RequestedAction of
            MATRIX_Action::Initial:
                MATRIX_NewColumnOffset(CommCostSetup, 0);
            MATRIX_Action::Previous:
                MATRIX_NewColumnOffset(CommCostSetup, MATRIX_ColumnOffset - ArrayLen(MATRIX_Rec));
            MATRIX_Action::Next:
                MATRIX_NewColumnOffset(CommCostSetup, MATRIX_ColumnOffset + ArrayLen(MATRIX_Rec));
            MATRIX_Action::PreviousColumn:
                MATRIX_NewColumnOffset(CommCostSetup, MATRIX_ColumnOffset - 1);
            MATRIX_Action::NextColumn:
                MATRIX_NewColumnOffset(CommCostSetup, MATRIX_ColumnOffset + 1);
        end;
        if (MATRIX_MaxNoOfColumns > 0) then begin
            CommCostSetup.FindSet;
            if (MATRIX_ColumnOffset > 0) then
                CommCostSetup.Next(MATRIX_ColumnOffset);
        end;
        for ColumnID := 1 to ArrayLen(MATRIX_Rec) do
            if (ColumnID > (MATRIX_MaxNoOfColumns - MATRIX_ColumnOffset)) then
                MATRIX_CaptionSet[ColumnID] := Text000
            else begin
                MATRIX_NoOfColumns := MATRIX_NoOfColumns + 1;
                MATRIX_Rec[ColumnID] := CommCostSetup;
                MATRIX_CaptionSet[ColumnID] := CommCostSetup.GetDescription();
                if (ColumnID < (MATRIX_MaxNoOfColumns - MATRIX_ColumnOffset)) then
                    CommCostSetup.Next;
            end;
    end;

    local procedure MATRIX_NewColumnOffset(var CommCostSetup: Record "Comm. Cost Setup Line"; NewColumnOffset: Integer)
    var
        MaxColumnOffset: Integer;
    begin
        MATRIX_ColumnOffset := NewColumnOffset;
        MaxColumnOffset := MATRIX_MaxNoOfColumns - ArrayLen(MATRIX_Rec);
        if (MaxColumnOffset < 0) then
            MaxColumnOffset := 0;
        if (MATRIX_ColumnOffset > MaxColumnOffset) then
            MATRIX_ColumnOffset := MaxColumnOffset;
        if (MATRIX_ColumnOffset < 0) then
            MATRIX_ColumnOffset := 0;
        MATRIX_NextEnabled := (MATRIX_ColumnOffset < MaxColumnOffset);
        MATRIX_PreviousEnabled := (MATRIX_ColumnOffset > 0);
    end;

    local procedure MATRIX_SetColumnFilters(ColumnID: Integer)
    begin
        SetRange("Commodity Class Filter", MATRIX_Rec[ColumnID]."Commodity Class Code");
        SetRange("Comm. Cost Comp. Filter", MATRIX_Rec[ColumnID]."Comm. Cost Component Code");
    end;

    local procedure MATRIX_OnAfterGetRecord()
    var
        ColumnID: Integer;
    begin
        Clear(MATRIX_CellData);
        for ColumnID := 1 to MATRIX_NoOfColumns do begin
            MATRIX_SetColumnFilters(ColumnID);
            CalcFields("Component Value");
            MATRIX_CellData[ColumnID] := "Component Value";
        end;
    end;

    local procedure MATRIX_OnValidate(ColumnID: Integer)
    begin
        CurrPage.SaveRecord;
        TestField("Starting Market Date");
        "Calculate Cost" := true;
        MATRIX_SetColumnFilters(ColumnID);
        Validate("Component Value", MATRIX_CellData[ColumnID]);
    end;

    local procedure MATRIX_OnDrillDown(ColumnID: Integer)
    var
        CommCostEntry: Record "Commodity Cost Entry";
        CommCostEntryList: Page "Commodity Cost Entries";
    begin
        MATRIX_SetColumnFilters(ColumnID);
        CommCostEntry.SetCurrentKey("Comm. Class Period Entry No.", "Commodity Class Code", "Comm. Cost Component Code");
        CommCostEntry.SetRange("Comm. Class Period Entry No.", "Entry No.");
        CommCostEntry.SetRange("Commodity Class Code", MATRIX_Rec[ColumnID]."Commodity Class Code");
        CommCostEntry.SetRange("Comm. Cost Component Code", MATRIX_Rec[ColumnID]."Comm. Cost Component Code");
        CommCostEntryList.SetTableView(CommCostEntry);
        CommCostEntryList.RunModal;
    end;
}

