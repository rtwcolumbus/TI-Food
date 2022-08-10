page 37002527 "Batch Planning Worksheet"
{
    // PRW16.00.04
    // P8000877, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Batch Planning Worksheet
    // 
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // PRW17.00.01
    // P8001163, Columbus IT, Jack Reynolds, 04 JUN 13
    //   Fix problem with editing sub-pages
    // 
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
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW110.0
    // P8007750, To-Increase, Jack Reynolds, 07 NOV 16
    //   Convert Food Item Attributes to NAV Item Attributes
    // 
    // PRW110.0.02
    // P80046223, To-Increase, Jack Reynolds, 31 AUG 17
    //   Problem with Quantity Planned
    // 
    // PRW111.00
    // P80059471, To Increase, Jack Reynolds, 25 JUN 18
    //   Upgrade signal control for JavaScript
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Batch Planning Worksheet';
    DataCaptionExpression = '';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;
    PromotedActionCategories = 'New,Process,Report,Navigate';
    SaveValues = true;
    SourceTable = "Batch Planning Worksheet Line";
    SourceTableView = SORTING("Parameter 1", "Parameter 2", "Parameter 3") WHERE(Type = CONST(Summary));
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            // usercontrol(Signal; "TI.NAVFood.Controls.SignalWeb")
            // {

            //     trigger AddInReady(guid: Text)
            //     begin
            //         // P80059471
            //         BatchPlanningFns.SetSignalControl(1, guid, CurrPage.Signal);
            //         CurrPage.Signal.SetInterval(1);
            //     end;

            //     trigger OnSignal()
            //     begin
            //         // P80059471
            //         CurrPage.Summary.PAGE.UpdateCurrentRecord;
            //     end;
            // }
            group(Control37002019)
            {
                ShowCaption = false;
                field(CurrWkshName; CurrWkshName)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Name';
                    TableRelation = "Batch Planning Worksheet Name";

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        WkshName: Record "Batch Planning Worksheet Name";
                        WorksheetNames: Page "Batch Planning Worksheet Names";
                    begin
                        CurrPage.SaveRecord;
                        Commit;
                        WkshName.Name := GetRangeMax("Worksheet Name");
                        WorksheetNames.SetRecord(WkshName);
                        WorksheetNames.LookupMode(true);
                        if WorksheetNames.RunModal = ACTION::LookupOK then begin
                            WorksheetNames.GetRecord(WkshName);
                            CurrWkshName := WkshName.Name;
                            SetName;
                            QtyRemainingOnly := false;
                            SetWorksheet;
                            CurrPage.Update(false);
                            CurrPage.Summary.PAGE.UpdateRecords;
                            CurrPage.Detail.PAGE.UpdateRecords;
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord;
                        SetName;
                        QtyRemainingOnly := false;
                        SetWorksheet;
                        CurrPage.Update(false);
                        CurrPage.Summary.PAGE.UpdateRecords;
                        CurrPage.Detail.PAGE.UpdateRecords;
                    end;
                }
                field(QtyRemainingOnly; QtyRemainingOnly)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Quantity Remaining Only';

                    trigger OnValidate()
                    begin
                        if QtyRemainingOnly then
                            SetFilter("Quantity Remaining", '<>0')
                        else
                            SetRange("Quantity Remaining");
                        CurrPage.Update(false);
                    end;
                }
                group(Control37002039)
                {
                    ShowCaption = false;
                    field(LocationCode; LocationCode)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Location Code';
                        Editable = false;
                    }
                    field(DateRange; DateRange)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Date Range';
                        Editable = false;
                    }
                }
            }
            repeater(Group)
            {
                Editable = false;
                FreezeColumn = "Unit of Measure";
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure"; "Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Parameter 1"; "Parameter 1")
                {
                    ApplicationArea = FOODBasic;
                    Visible = ShowParameter1;

                    trigger OnDrillDown()
                    begin
                        ParameterDrilldown(1); // P8006959
                    end;
                }
                field("Parameter 2"; "Parameter 2")
                {
                    ApplicationArea = FOODBasic;
                    Visible = ShowParameter2;

                    trigger OnDrillDown()
                    begin
                        ParameterDrilldown(2); // P8006959
                    end;
                }
                field("Parameter 3"; "Parameter 3")
                {
                    ApplicationArea = FOODBasic;
                    Visible = ShowParameter3;

                    trigger OnDrillDown()
                    begin
                        ParameterDrilldown(3); // P8006959
                    end;
                }
                field("Quantity Required"; "Quantity Required")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        ShowDetail;
                    end;
                }
                field("Quantity Planned"; "Quantity Planned")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        ShowDetail; // P80046223
                    end;
                }
                field("Quantity Remaining"; "Quantity Remaining")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        ShowDetail;
                    end;
                }
                field("Suggested Date"; "Suggested Date")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        ShowDetail;
                    end;
                }
                field("Date Required"; "Date Required")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        ShowDetail;
                    end;
                }
                field("Intermediate Item No."; "Intermediate Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Intermediate Description"; "Intermediate Description")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Intermediate Unit of Measure"; "Intermediate Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Intermediate Qty. Required"; "Intermediate Qty. Required")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Intermediate Qty. Planned"; "Intermediate Qty. Planned")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Intermediate Qty. Remaining"; "Intermediate Qty. Remaining")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Control37002017)
            {
                ShowCaption = false;
                part(Summary; "Batch Planning Equip. Summary")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Equipment Summary';
                    Editable = false;
                    SubPageLink = "Item Filter" = FIELD("Item No."),
                                  "Variant Filter" = FIELD("Variant Code"),
                                  "Intermediate Filter" = FIELD("Intermediate Item No.");
                }
                part(Detail; "Batch Planning Order Detail")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Order Detail';
                    Provider = Summary;
                    SubPageLink = "Production Date" = FIELD("Production Date"),
                                  "Equipment Code" = FIELD("Equipment Code");
                    UpdatePropagation = Both; // P800-MegaApp
                }
            }
        }
        area(factboxes)
        {
            part(Control37002041; "SKU/Item Planning FactBox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("Item No."),
                              "Variant Filter" = FIELD("Variant Code"),
                              "Location Filter" = FIELD("Location Code");
            }
            part(Control37002042; "SKU/Item Planning FactBox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("Intermediate Item No."),
                              "Variant Filter" = FIELD("Variant Code"),
                              "Location Filter" = FIELD("Location Code");
            }
            part(MaintenanceWorkFactBox; "Maintenance Work FactBox")
            {
                ApplicationArea = FOODBasic;
                Provider = Summary;
                SubPageLink = "Resource No." = FIELD("Equipment Code");
                Visible = false;
            }
            systempart(Control37002033; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control37002034; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Plan Item")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Plan Item';
                Image = MakeOrder;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    PlanItem: Page "Batch Planning - Plan Item";
                begin
                    if BatchPlanningFns.GetSummaryRecordDisplayed then begin
                        PlanItem.SetParameters(BatchPlanningFns, CurrPage.Detail.PAGE.GetProductionDate, "Intermediate Item No.", // P8001030
                          "Intermediate Variant Code");                                                                         // P8001030
                        PlanItem.RunModal;
                        if PlanItem.OrdersCreated then begin
                            CurrPage.Summary.PAGE.UpdateRecords;
                            CurrPage.Detail.PAGE.UpdateRecords;
                            Message(Text001);
                        end;
                    end;
                end;
            }
            action("Calculate Worksheet")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Calculate Worksheet';
                Image = CalculatePlan;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    CalcBPWorksheet: Report "Calc. Batch Planning Worksheet";
                begin
                    CalcBPWorksheet.SetWorksheetName(CurrWkshName);
                    CalcBPWorksheet.RunModal;
                    GetParameters;
                    CurrPage.Summary.PAGE.UpdateRecords;
                end;
            }
            action("Finished Item")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Finished Item';
                Image = Item;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;
                RunObject = Page "Item Card";
                RunPageLink = "No." = FIELD("Item No.");
            }
            action("Intermediate Item")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Intermediate Item';
                Image = Item;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;
                RunObject = Page "Item Card";
                RunPageLink = "No." = FIELD("Intermediate Item No.");
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        QtyRemainingOnly := GetFilter("Quantity Remaining") in ['>0', '<>0'];
        if BatchPlanningFns.GetUpdateAction(1) <> '' then begin
            CurrPage.Summary.PAGE.UpdateCurrentRecord; // P800-MegaApp
            CurrPage.Summary.PAGE.UpdatePage(false);   // P8
        end;
        exit(Find(Which));
    end;

    trigger OnInit()
    begin
        CurrPage.Summary.PAGE.SetSharedCU(BatchPlanningFns);
        CurrPage.Detail.PAGE.SetSharedCU(BatchPlanningFns);
    end;

    trigger OnOpenPage()
    begin
        OpenedFromBatch := "Worksheet Name" <> '';
        if OpenedFromBatch then
            CurrWkshName := "Worksheet Name"
        else
            if not WorksheetName.Get(CurrWkshName) then begin
                if not WorksheetName.FindFirst then begin
                    WorksheetName.Init;
                    WorksheetName.Name := Text002;
                    WorksheetName.Description := Text003;
                    WorksheetName.Insert(true);
                    Commit;
                end;
                CurrWkshName := WorksheetName.Name;
            end;

        QtyRemainingOnly := false;

        SetWorksheet;
    end;

    var
        WorksheetName: Record "Batch Planning Worksheet Name";
        BatchPlanningFns: Codeunit "Batch Planning Functions";
        P800Functions: Codeunit "Process 800 Functions";
        AllergenManagement: Codeunit "Allergen Management";
        CurrWkshName: Code[10];
        [InDataSet]
        ShowParameter1: Boolean;
        [InDataSet]
        ShowParameter2: Boolean;
        [InDataSet]
        ShowParameter3: Boolean;
        LocationCode: Code[10];
        BeginDate: Date;
        EndDate: Date;
        DateRange: Text[30];
        Text001: Label 'Orders updated.';
        OpenedFromBatch: Boolean;
        Text002: Label 'DEFAULT';
        Text003: Label 'Default Worksheet';
        QtyRemainingOnly: Boolean;

    procedure SetWorksheet()
    begin
        FilterGroup := 2;
        SetRange("Worksheet Name", CurrWkshName);
        FilterGroup := 0;

        WorksheetName.Get(CurrWkshName);
        if WorksheetName."Parameter 1 Type" <> 0 then
            if WorksheetName."Parameter 1 Field" < WorksheetName."Parameter 1 Field"::Attribute then
                ShowParameter1 := true
            else
                ShowParameter1 := WorksheetName."Parameter 1 Attribute" <> 0; // P8007750
        if WorksheetName."Parameter 2 Type" <> 0 then
            if WorksheetName."Parameter 2 Field" < WorksheetName."Parameter 2 Field"::Attribute then
                ShowParameter2 := true
            else
                ShowParameter2 := WorksheetName."Parameter 2 Attribute" <> 0; // P8007750
        if WorksheetName."Parameter 3 Type" <> 0 then
            if WorksheetName."Parameter 3 Field" < WorksheetName."Parameter 3 Field"::Attribute then
                ShowParameter3 := true
            else
                ShowParameter3 := WorksheetName."Parameter 3 Attribute" <> 0; // P8007750

        GetParameters;
    end;

    procedure GetParameters()
    var
        BPWorksheet: Record "Batch Planning Worksheet Line";
    begin
        BPWorksheet.SetRange("Worksheet Name", CurrWkshName);
        if BPWorksheet.FindFirst then begin
            LocationCode := BPWorksheet."Location Code";
            BeginDate := BPWorksheet."Begin Date";
            EndDate := BPWorksheet."End Date";
            DateRange := StrSubstNo('%1..%2', BeginDate, EndDate);
        end else begin
            LocationCode := '';
            BeginDate := 0D;
            EndDate := 0D;
            DateRange := '';
        end;

        BatchPlanningFns.InitializeWorksheet(CurrWkshName, LocationCode, BeginDate, EndDate);
        if P800Functions.MaintenanceInstalled then
            CurrPage.MaintenanceWorkFactBox.PAGE.Initialize(BeginDate, EndDate);
    end;

    procedure ShowDetail()
    var
        BPWorksheetLine: Record "Batch Planning Worksheet Line";
    begin
        BPWorksheetLine.FilterGroup(9);
        BPWorksheetLine.SetRange("Worksheet Name", "Worksheet Name");
        BPWorksheetLine.SetRange("Item No.", "Item No.");
        BPWorksheetLine.SetRange("Variant Code", "Variant Code");
        BPWorksheetLine.SetRange(Type, Type::Detail);
        BPWorksheetLine.FilterGroup(9);
        PAGE.Run(PAGE::"Batch Planning Wrksheet Detail", BPWorksheetLine);
    end;

    procedure SetName()
    begin
        FilterGroup := 2;
        SetRange("Worksheet Name", CurrWkshName);
        FilterGroup := 0;
    end;

    local procedure ParameterDrilldown(No: Integer)
    var
        BatchPlanningWorksheetName: Record "Batch Planning Worksheet Name";
        Type: Integer;
        Fld: Integer;
    begin
        // P8006959
        BatchPlanningWorksheetName.Get("Worksheet Name");
        case No of
            1:
                begin
                    Type := BatchPlanningWorksheetName."Parameter 1 Type";
                    Fld := BatchPlanningWorksheetName."Parameter 1 Field";
                end;
            2:
                begin
                    Type := BatchPlanningWorksheetName."Parameter 2 Type";
                    Fld := BatchPlanningWorksheetName."Parameter 2 Field";
                end;
            3:
                begin
                    Type := BatchPlanningWorksheetName."Parameter 3 Type";
                    Fld := BatchPlanningWorksheetName."Parameter 3 Field";
                end;
        end;

        if Fld = BatchPlanningWorksheetName."Parameter 1 Field"::Allergen then begin
            case Type of
                BatchPlanningWorksheetName."Parameter 1 Type"::Finished:
                    AllergenManagement.AllergenDrilldownForRecord(0, 0, "Item No.");
                BatchPlanningWorksheetName."Parameter 1 Type"::Intermediate:
                    AllergenManagement.AllergenDrilldownForRecord(0, 0, "Intermediate Item No.");
            end;
        end;
    end;
}
