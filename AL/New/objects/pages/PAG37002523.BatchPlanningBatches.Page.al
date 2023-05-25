page 37002523 "Batch Planning - Batches"
{
    // PRW16.00.04
    // P8000877, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Batch sub-page of the Batch Planning - Plan Item page
    // 
    // PRW17.00.01
    // P8001182, Columbus IT, Jack Reynolds, 18 JUL 13
    //   Modify to use signalling instead of SENDKEYS to trigger an action
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW19.00.01
    // P8007121, To-Increase, Dayakar Battini, 03 JUN 16
    //   Missing captions for Batch Quantity fields
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 14 DEC 16
    //   Fix page refresh issue with Include CheckBox
    // 
    // PRW111.00.01
    // P80062449, To-Increase, Jack Reynolds, 23 JUL 18
    //   Fix problem selecting equipment to include
    //
    // PRW121.4
    // P800165851, To-Increase, Gangabhushan, 24 MAR 23
    //   CS00224365 | Change Request - page 37002523 Batch Planning - Batches

    Caption = 'Batch Planning - Batches';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Batch Planning - Batch";
    SourceTableTemporary = true;
    SourceTableView = SORTING(Sequence, "Batch No.");

    layout
    {
        area(content)
        {
            group(Quantity)
            {
                ShowCaption = false;
                field(TotalBatchQuantity; TotalBatchQty)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Total Batch Quantity';
                    DecimalPlaces = 0 : 5;
                    MinValue = 0;

                    trigger OnValidate()
                    begin
                        BatchPlanningFns.ModifyQtyRequired(TotalBatchQty);
                        CurrPage.Update(false);
                    end;
                }
                field(RequiredQuantity; TotalRequired)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Required Quantity';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                }
                field(ExcessQuantity; TotalBatchQty - TotalRequired)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Excess Quantity';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                }
            }
            repeater(Group)
            {
                field(Include; Include)
                {
                    ApplicationArea = FOODBasic;
                    Editable = EquipmentRec;

                    trigger OnValidate()
                    begin
                        BatchPlanningFns.ModifyBatches(Rec, true);
                        UpdateRecords; // P8007748
                        CurrPage.Update(false); // P800-MegaApp
                    end;
                }
                field(Batches; Batches)
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Editable = EquipmentRec;
                    HideValue = NOT EquipmentRec;
                    Style = Attention;
                    StyleExpr = HighlightRec;

                    trigger OnValidate()
                    begin
                        BatchPlanningFns.ModifyBatches(Rec, true);
                        CurrPage.Update(false); // P800-MegaApp
                    end;
                }
                field(EquipmentCode; "Equipment Code")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = NOT EquipmentRec;
                    Style = Attention;
                    StyleExpr = HighlightRec;
                }
                field(EquipmentDescription; "Equipment Description")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = NOT EquipmentRec;
                    Style = Attention;
                    StyleExpr = HighlightRec;
                }
                field(MaximumOrderQuantity; "Maximum Order Quantity")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = NOT EquipmentRec;
                    Style = Attention;
                    StyleExpr = HighlightRec;
                }
                field(TotalTime; "Batch Time (Hours)" + "Other Time (Hours)")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Total Time (Hours)';
                    DecimalPlaces = 0 : 5;
                    HideValue = NOT EquipmentRec;
                    Style = Attention;
                    StyleExpr = HighlightRec;
                }
                field(BatchNo; "Batch No.")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = NOT BatchRec;
                    Style = Attention;
                    StyleExpr = HighlightRec;
                }
                field(BatchSize; "Batch Size")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = NOT BatchRec;
                    Style = Attention;
                    StyleExpr = HighlightRec;
                }
                field(ProductionTime; "Production Time (Hours)")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = NOT BatchRec;
                    Style = Attention;
                    StyleExpr = HighlightRec;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(MoveUp)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Move Up';
                Enabled = MoveUp;
                Image = MoveUp;

                trigger OnAction()
                begin
                    Move(-1);
                    CurrPage.Update(false); // P800-MegaApp
                end;
            }
            action(MoveDown)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Move Down';
                Enabled = MoveDown;
                Image = MoveDown;

                trigger OnAction()
                begin
                    Move(1);
                    CurrPage.Update(false); // P800-MegaApp
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        EquipmentRec := Summary;
        BatchRec := "Batch No." <> 0;
        HighlightRec := Highlight;
        MoveUp := EquipmentRec and (Sequence > 1);
        MoveDown := EquipmentRec and (Sequence < MaxSequence);
    end;

    trigger OnOpenPage()
    begin
        BatchPlanningFns.GetBatchItem(BatchItem);
        UpdateRecords;
    end;

    var
        [InDataSet]
        EquipmentRec: Boolean;
        [InDataSet]
        BatchRec: Boolean;
        [InDataSet]
        HighlightRec: Boolean;
        [InDataSet]
        MoveUp: Boolean;
        [InDataSet]
        MoveDown: Boolean;
        MaxSequence: Integer;

    protected var
        BatchItem: Record Item;
        BatchPlanningFns: Codeunit "Batch Planning Functions";
        TotalBatchQty: Decimal;
        TotalRequired: Decimal;

    procedure SetSharedCU(var CU: Codeunit "Batch Planning Functions")
    begin
        BatchPlanningFns := CU;
    end;

    procedure UpdateRecords()
    var
        Batch: Record "Batch Planning - Batch" temporary;
        BatchCopy: Record "Batch Planning - Batch";
    begin
        BatchCopy.Copy(Rec);
        Reset;
        DeleteAll;
        Rec.Copy(BatchCopy);

        BatchPlanningFns.GetBatchSummary(TotalBatchQty, TotalRequired);
        BatchPlanningFns.GetBatches(Batch);
        if Batch.FindSet then
            repeat
                Rec := Batch;
                Insert;
                if MaxSequence < Sequence then
                    MaxSequence := Sequence;
            until Batch.Next = 0;

        SetCurrentKey(Sequence, "Batch No.");
        // P80062449
        if xRec."Equipment Code" <> '' then begin
            Rec.FilterGroup(9);
            Rec.SetRange("Equipment Code", xRec."Equipment Code");
            Rec.FindFirst;
            Rec.SetRange("Equipment Code");
            Rec.FilterGroup(0);
        end else
            if FindFirst then;
        // P80062449

        CurrPage.Update(false); // P8001182
    end;

    procedure Move(Direction: Integer)
    var
        Batch: Record "Batch Planning - Batch";
        Recalc: Boolean;
    begin
        SetRange(Summary, true);
        Batch := Rec;

        Next(Direction);
        Sequence -= Direction;
        Recalc := Include;
        Modify;
        BatchPlanningFns.ModifyBatches(Rec, false);

        Rec := Batch;
        Sequence += Direction;
        Recalc := Recalc and Include;
        Modify;
        BatchPlanningFns.ModifyBatches(Rec, false);
        SetRange(Summary);

        if Recalc then begin
            BatchPlanningFns.ClearBatches;
            BatchPlanningFns.CalculateBatches(true);
        end else begin
            UpdateRecords;
            CurrPage.Update(false);
        end;
    end;

    procedure UpdatePage()
    begin
        CurrPage.update(false);
    end;
}

