page 37002529 "Batch Planning Equip. Summary"
{
    // PRW16.00.04
    // P8000877, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Equipment summary sub-page for the Batch Planning Worksheet
    // 
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW110.0
    // P8007750, To-Increase, Jack Reynolds, 07 NOV 16
    //   Convert Food Item Attributes to NAV Item Attributes

    Caption = 'Batch Planning Equip. Summary';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "Batch Planning Equip. Summary";
    SourceTableTemporary = true;
    SourceTableView = SORTING("Equipment Type", "Equipment Code", "Production Date");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Equipment Type"; "Equipment Type")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = HideEquipment;
                    Style = Attention;
                    StyleExpr = Highlight;
                }
                field("Equipment Code"; "Equipment Code")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = HideEquipment;
                    Style = Attention;
                    StyleExpr = Highlight;
                }
                field("Production Date"; "Production Date")
                {
                    ApplicationArea = FOODBasic;
                    Style = Attention;
                    StyleExpr = Highlight;
                }
                field(Items; Items)
                {
                    ApplicationArea = FOODBasic;
                    Style = Attention;
                    StyleExpr = Highlight;
                }
                field("Total Time (Hours)"; "Total Time (Hours)")
                {
                    ApplicationArea = FOODBasic;
                    Style = Attention;
                    StyleExpr = Highlight;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(FilterByItem)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Filter By Item';
                Image = UseFilters;
                InFooterBar = true;
                Visible = ShowAll;

                trigger OnAction()
                begin
                    ShowAll := false;
                end;
            }
            action(ShowAll)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Show All Equipment';
                Image = ClearFilter;
                InFooterBar = true;
                Visible = NOT ShowAll;

                trigger OnAction()
                begin
                    ShowAll := true;
                end;
            }
            action(Equipment)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Equipment';
                Image = Tools;
                RunObject = Page "Resource Card";
                RunPageLink = "No." = FIELD("Equipment Code");
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Highlight := BatchPlanningFns.HighlightEquipment(Rec, BatchHighlight, PackageHighlight);
        HideEquipment := "Hide Equipment";
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        CurrentItem: Record Item;
        CurrentIntermediate: Record Item;
        CurrentItemVariant: Code[10];
        FindWhich: Text[30];
        Found: Boolean;
        Direction: Integer;
        EOF: Boolean;
        i: Integer;
    begin
        FindWhich := Which;
        FilterGroup(4);
        if not CurrentItem.Get(GetFilter("Item Filter")) then
            Clear(CurrentItem);
        if not CurrentIntermediate.Get(GetFilter("Intermediate Filter")) then
            Clear(CurrentIntermediate);
        // P8001030
        if GetFilter("Variant Filter") = '''''' then
            CurrentItemVariant := ''
        else
            CurrentItemVariant := GetFilter("Variant Filter");
        // P8001030
        FilterGroup(0);
        BatchHighlight := BatchPlanningFns.GetParameter3(CurrentIntermediate, // P8006959
          BPWorksheetName."Batch Highlight Field", BPWorksheetName."Batch Highlight Attribute");
        PackageHighlight := BatchPlanningFns.GetParameter3(CurrentItem, // P8006959
          BPWorksheetName."Package Highlight Field", BPWorksheetName."Package Highlight Attribute");
        BatchPlanningFns.MarkEquipment(CurrentItem, CurrentItemVariant); // P8001030

        if ShowAll then begin
            Found := Find(FindWhich);
            BatchPlanningFns.SetSummaryRecordDisplayed(Found);
            exit(Found);
        end;

        for i := 1 to StrLen(FindWhich) do begin
            EOF := false;
            case FindWhich[i] of
                '-', '>':
                    Direction := 1;
                '+', '<':
                    Direction := -1;
                '=':
                    Direction := 0;
            end;
            EOF := not Find(CopyStr(FindWhich, i, 1));
            while (not EOF) and (not BatchPlanningFns.ShowEquipment(Rec))
            do
                EOF := Next(Direction) = 0;
            if not EOF then begin
                BatchPlanningFns.SetSummaryRecordDisplayed(true);
                exit(true);
            end;
        end;

        BatchPlanningFns.SetSummaryRecordDisplayed(false);
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        NextRec: Record "Batch Planning Equip. Summary";
        Direction: Integer;
        NoSteps: Integer;
        StepsTaken: Integer;
        EOF: Boolean;
    begin
        if ShowAll then
            exit(Next(Steps));

        NextRec := Rec;
        Direction := 1;
        if Steps < 0 then
            Direction := -1;
        NoSteps := Direction * Steps;
        while (StepsTaken < NoSteps) and (not EOF) do begin
            EOF := Next(Direction) = 0;
            if (not EOF) and BatchPlanningFns.ShowEquipment(Rec) then begin
                NextRec := Rec;
                StepsTaken += 1;
            end;
        end;
        Rec := NextRec;
        exit(Direction * StepsTaken);
    end;

    trigger OnOpenPage()
    begin
        UpdateRecords;
    end;

    var
        BPWorksheetName: Record "Batch Planning Worksheet Name";
        BatchPlanningFns: Codeunit "Batch Planning Functions";
        [InDataSet]
        ShowAll: Boolean;
        BatchHighlight: Text[250];
        PackageHighlight: Text[250];
        [InDataSet]
        Highlight: Boolean;
        [InDataSet]
        HideEquipment: Boolean;

    procedure SetSharedCU(var CU: Codeunit "Batch Planning Functions")
    begin
        BatchPlanningFns := CU;
    end;

    procedure UpdateRecords()
    var
        Summary: Record "Batch Planning Equip. Summary" temporary;
    begin
        Reset;
        DeleteAll;

        BatchPlanningFns.GetWorksheet(BPWorksheetName);
        BatchPlanningFns.GetDailySummary(Summary);
        if Summary.FindSet then
            repeat
                Rec := Summary;
                Insert;
            until Summary.Next = 0;

        SetCurrentKey("Equipment Type", "Equipment Code", "Production Date");
        if not FindFirst then;
    end;

    procedure UpdateCurrentRecord()
    var
        Summary: Record "Batch Planning Equip. Summary";
        CurrentRec: Record "Batch Planning Equip. Summary";
    begin
        BatchPlanningFns.GetCurrentDailySummary(Rec);
        Modify;
    end;

    // P800-MegaApp
    procedure UpdatePage(SaveRecord: Boolean)
    begin
        CurrPage.update(SaveRecord)
    end;
}

