page 37002522 "Batch Planning - Plan Item"
{
    // PRW16.00.04
    // P8000877, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Main page for batch planning an intermediate
    // 
    // PRW16.00.05
    // P8000959, Columbus IT, Jack Reynolds, 21 JUN 11
    //   Item Availability factbox for Batch Planning
    // 
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // P8001089, Columbus IT, Jack Reynolds, 14 AUG 12
    //   Fix page update issue (always moving to first record)
    // 
    // PRW17.00.01
    // P8001182, Columbus IT, Jack Reynolds, 18 JUL 13
    //   Modify to use signalling instead of SENDKEYS to trigger an action
    // 
    // PRW18.00.01
    // P8001386, Columbus IT, Jack Reynolds, 27 MAY 15
    //   Renamed NAV Food client addins
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW111.00
    // P80059471, To Increase, Jack Reynolds, 25 JUN 18
    //   Upgrade signal control for JavaScript

    Caption = 'Batch Planning - Plan Item';
    DataCaptionExpression = '';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;
    SourceTable = "Batch Planning Worksheet Line";
    SourceTableTemporary = true;
    SourceTableView = SORTING("Parameter 1", "Parameter 2", "Parameter 3") WHERE(Type = CONST(Summary));

    layout
    {
        area(content)
        {
            // usercontrol(Signal; "TI.NAVFood.Controls.SignalWeb")
            // {

            //     trigger AddInReady(guid: Text)
            //     begin
            //         // P80059471
            //         BatchPlanningFns.SetSignalControl(2, guid, CurrPage.Signal);
            //         CurrPage.Signal.SetInterval(1);
            //     end;

            //     trigger OnSignal()
            //     begin
            //         // P80059471
            //         case BatchPlanningFns.GetUpdateAction(2) of
            //             'CALCULATE BATCH', 'PACKAGE QUANTITY':
            //                 UpdateDisplay;
            //             'HIGHLIGHT EQUIPMENT':
            //                 begin
            //                     CurrPage.PackagesByItem.PAGE.UpdateDisplay;
            //                     CurrPage.PackagesByBatch.PAGE.UpdateDisplay;
            //                 end;
            //         end;
            //     end;
            // }
            group(Control37002017)
            {
                ShowCaption = false;
                field("IntermediateItem.Description"; IntermediateItem.Description)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Description';
                    Editable = false;
                }
                field(LocationCode; LocationCode)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Location Code';
                    Editable = false;
                }
                field(ProductionDate; ProductionDate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Production Date';
                    Editable = false;
                }
                field(DateRange; DateRange)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Date Range';
                    Editable = false;
                }
            }
            repeater(Group)
            {
                field(Include; Include)
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        Modify;
                        BatchPlanningFns.ModifyFinishedItem(Rec, true);
                        QtyEditable := Include; // P8001132
                        UpdateDisplay;
                    end;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Parameter 1"; "Parameter 1")
                {
                    ApplicationArea = FOODBasic;
                    Visible = ShowParameter1;
                }
                field("Parameter 2"; "Parameter 2")
                {
                    ApplicationArea = FOODBasic;
                    Visible = ShowParameter2;
                }
                field("Parameter 3"; "Parameter 3")
                {
                    ApplicationArea = FOODBasic;
                    Visible = ShowParameter3;
                }
                field("Unit of Measure"; "Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Projected Availability"; "Projected Availability")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity Required"; "Quantity Required")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        BatchPlanningFns.ShowFinishedItemDetail(Rec);
                    end;
                }
                field("Date Required"; "Date Required")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        BatchPlanningFns.ShowFinishedItemDetail(Rec);
                    end;
                }
                field("Suggested Date"; "Suggested Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Intermediate Quantity per"; "Intermediate Quantity per")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Intermediate Unit of Measure"; "Intermediate Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Remaining Quantity to Produce"; "Remaining Quantity to Produce")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Quantity Remaining';
                }
                field("Additional Quantity Possible"; "Additional Quantity Possible")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity to Produce"; "Quantity to Produce")
                {
                    ApplicationArea = FOODBasic;
                    Editable = QtyEditable;

                    trigger OnValidate()
                    begin
                        Modify;
                        BatchPlanningFns.ModifyFinishedItem(Rec, true);
                        UpdateDisplay;
                        CurrPage.Batches.Page.UpdatePage; // P800-MegaApp
                    end;
                }
                field("Remaining Quantity to Pack"; "Remaining Quantity to Pack")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                }
            }
            group(Control37002033)
            {
                ShowCaption = false;
                part(Batches; "Batch Planning - Batches")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Batches';
                    UpdatePropagation = Both;
                }
                part(PackagesByItem; "Batch Planning - Pkg. by Item")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Package Orders';
                    SubPageLink = "Item No." = FIELD("Item No."), "Variant Code" = FIELD("Variant Code");
                    UpdatePropagation = Both;
                    Visible = NOT ShowPackageByBatch;
                }
                part(PackagesByBatch; "Batch Planning - Pkg. by Batch")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Package Orders';
                    Provider = Batches;
                    SubPageLink = "Batch No." = FIELD("Batch No. Link");
                    UpdatePropagation = Both;
                    Visible = ShowPackageByBatch;
                }
            }
        }
        area(factboxes)
        {
            part(ItemAvailability; "Batch Planning - Plan Item FB")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Item Availability';
                SubPageLink = "Item No." = FIELD("Item No."), "Variant Code" = FIELD("Variant Code");
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Create &Orders")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Create &Orders';
                Image = CreateDocuments;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ShortCutKey = 'F7';

                trigger OnAction()
                begin
                    if BatchPlanningFns.CreateBatchOrders then begin
                        Created := true;
                        CurrPage.Close;
                    end;
                end;
            }
            action("Show Package Orders by Batch")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Show Package Orders by Batch';
                Enabled = NOT ShowPackageByBatch;
                Image = ChangeBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Visible = NOT ShowPackageByBatch;

                trigger OnAction()
                begin
                    ShowPackageByBatch := true;
                    CurrPage.Update(false);
                end;
            }
            action("Show Package Orders by Item")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Show Package Orders by Item';
                Enabled = ShowPackageByBatch;
                Image = Item;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Visible = ShowPackageByBatch;

                trigger OnAction()
                begin
                    ShowPackageByBatch := false;
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        QtyEditable := Include;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        BatchPlanningFns.SetPackageHighlight("Item No.", "Variant Code");
        CurrPage.PackagesByItem.PAGE.UpdateDisplay;
        CurrPage.PackagesByBatch.PAGE.UpdateDisplay;
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        case BatchPlanningFns.GetUpdateAction(2) of
            'CALCULATE BATCH', 'PACKAGE QUANTITY':
                UpdateDisplay;
        end;

        exit(Find(Which));
    end;

    trigger OnOpenPage()
    begin
        CurrPage.Batches.PAGE.SetSharedCU(BatchPlanningFns);
        CurrPage.PackagesByBatch.PAGE.SetSharedCU(BatchPlanningFns);
        CurrPage.PackagesByItem.PAGE.SetSharedCU(BatchPlanningFns);
        UpdateDisplay;
    end;

    var
        IntermediateItem: Record Item;
        BPWorksheetName: Record "Batch Planning Worksheet Name";
        QuickPlanner: Record "Quick Planner Worksheet" temporary;
        P800Functions: Codeunit "Process 800 Functions";
        BatchPlanningFns: Codeunit "Batch Planning Functions";
        LocationCode: Code[10];
        BeginDate: Date;
        EndDate: Date;
        ProductionDate: Date;
        DateRange: Text[30];
        [InDataSet]
        QtyEditable: Boolean;
        Created: Boolean;
        [InDataSet]
        ShowParameter1: Boolean;
        [InDataSet]
        ShowParameter2: Boolean;
        [InDataSet]
        ShowParameter3: Boolean;
        [InDataSet]
        ShowPackageByBatch: Boolean;

    procedure SetParameters(var CU: Codeunit "Batch Planning Functions"; ProdDate: Date; IntermediateNo: Code[20]; IntermediateVariant: Code[10])
    begin
        // P8001030 - parameter added for IntemediateVariant
        BatchPlanningFns := CU;
        IntermediateItem.Get(IntermediateNo);
        BatchPlanningFns.GetWorksheetParameters(LocationCode, BeginDate, EndDate);
        DateRange := StrSubstNo('%1..%2', BeginDate, EndDate);
        ProductionDate := ProdDate;

        BatchPlanningFns.GetWorksheet(BPWorksheetName);
        ShowParameter1 := BPWorksheetName."Parameter 1 Type" = BPWorksheetName."Parameter 1 Type"::Finished;
        ShowParameter2 := BPWorksheetName."Parameter 2 Type" = BPWorksheetName."Parameter 2 Type"::Finished;
        ShowParameter3 := BPWorksheetName."Parameter 3 Type" = BPWorksheetName."Parameter 3 Type"::Finished;
        ShowPackageByBatch := BPWorksheetName."Create Multi-line Orders";

        BatchPlanningFns.InitializePlanningItem(IntermediateItem, IntermediateVariant, ProdDate); // P8001030
    end;

    procedure UpdateRecords()
    var
        CurrentRec: Record "Batch Planning Worksheet Line";
        BatchItem: Record "Batch Planning Worksheet Line" temporary;
        ProcessSetup: Record "Process Setup";
        UseNAVForecast: Boolean;
        EarliestForecastDate: Date;
        LotStatus: Record "Lot Status Code";
        LotStatusMgmt: Codeunit "Lot Status Management";
        LotStatusExclusionFilter: Text[1024];
    begin
        CurrentRec := Rec;
        Reset;
        DeleteAll;
        // P8000959
        CurrPage.ItemAvailability.PAGE.ClearData(BeginDate, EndDate, LocationCode);
        QuickPlanner.SetRange("Date Filter", BeginDate, EndDate);
        QuickPlanner.SetRange("Location Filter", LocationCode);
        UseNAVForecast := P800Functions.ForecastInstalled;
        LotStatusExclusionFilter := LotStatusMgmt.SetLotStatusExclusionFilter(LotStatus.FieldNo("Available for Planning")); // P8001083
        CurrPage.ItemAvailability.PAGE.SetLotStatus(LotStatusExclusionFilter); // P8001083
        ProcessSetup.Get;
        if Format(ProcessSetup."Forecast Time Fence") <> '' then
            EarliestForecastDate := CalcDate(ProcessSetup."Forecast Time Fence", BeginDate)
        else
            EarliestForecastDate := BeginDate;
        // P8000959

        BatchPlanningFns.GetFinishedItems(BatchItem);
        if BatchItem.FindSet then
            repeat
                Rec := BatchItem;
                // P8000959
                QuickPlanner.Init;
                QuickPlanner."Item No." := "Item No.";
                QuickPlanner."Variant Code" := "Variant Code";
                QuickPlanner.Calculate(UseNAVForecast, EarliestForecastDate, LotStatusExclusionFilter); // P8001083
                CurrPage.ItemAvailability.PAGE.InsertRecord(QuickPlanner);
                "Projected Availability" := QuickPlanner."Qty. Available";
                // P8000959
                Insert;
            until BatchItem.Next = 0;

        SetCurrentKey("Parameter 1", "Parameter 2", "Parameter 3");
        if not Get(CurrentRec."Worksheet Name", CurrentRec."Item No.", CurrentRec."Variant Code", CurrentRec.Type, 0) then // P8001089
            if FindFirst then;
        UseNAVForecast := P800Functions.ForecastInstalled; // P8000869
    end;

    procedure UpdateDisplay()
    begin
        CurrPage.Batches.PAGE.UpdateRecords;
        CurrPage.PackagesByBatch.PAGE.UpdateRecords;
        CurrPage.PackagesByItem.PAGE.UpdateRecords;
        UpdateRecords;
        CurrPage.Update(false);
    end;

    procedure OrdersCreated(): Boolean
    begin
        exit(Created);
    end;
}

