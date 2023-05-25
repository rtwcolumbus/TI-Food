page 37002531 "Batch Planning Order Detail"
{
    // PRW16.00.04
    // P8000877, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Planning detail for a specific date and equipment
    // 
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // PRW17.00.01
    // P8001183, Columbus IT, Jack Reynolds, 18 JUL 13
    //   Fix problem deleting non-production event
    // 
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW121.2
    // P800163700, To-Increase, Jack Reynolds, 07 FEB 23
    //   Support for Auto-Save as You Work

    Caption = 'Batch Planning Order Detail';
    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Batch Planning Order Detail";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Order No."; "Order No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Allergens; AllergenManagement.AllergenCodeForRecord(DATABASE::"Batch Planning Order Detail", Type, "Item No."))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Allergens';
                    Style = StrongAccent;
                    StyleExpr = TRUE;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        // P8006959
                        AllergenManagement.AllergenDrilldownForRecord(DATABASE::"Batch Planning Order Detail", Type, "Item No.");
                    end;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Item Description"; "Item Description")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure"; "Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                    HideValue = IsEvent;
                }
                field("Duration (Hours)"; "Duration (Hours)")
                {
                    ApplicationArea = FOODBasic;
                    Editable = IsEvent;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Refresh)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Refresh';
                Image = Refresh;

                trigger OnAction()
                begin
                    CurrPage.Update(false);
                end;
            }
            action("Add Event")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Add Event';
                Image = AddAction;

                trigger OnAction()
                var
                    ProdPlanningEvent: Record "Production Planning Event";
                    DailyEvent: Record "Daily Production Event";
                    DailySummary: Record "Batch Planning Equip. Summary";
                    ProdPlanningEvents: Page "Production Planning Events";
                    ProdDate: Date;
                    EqCode: Code[20];
                begin
                    FilterGroup(4);
                    if BatchPlanningFns.GetSummaryRecordDisplayed then begin
                        ProdDate := GetRangeMin("Production Date");
                        EqCode := GetRangeMin("Equipment Code");
                        if EqCode <> '' then begin
                            ProdPlanningEvents.LookupMode(true);
                            if ProdPlanningEvents.RunModal = ACTION::LookupOK then begin
                                ProdPlanningEvents.GetRecord(ProdPlanningEvent);
                                Init;
                                "Production Date" := ProdDate;
                                "Equipment Code" := EqCode;
                                Type := Type::"Event";
                                Validate("Event Code", ProdPlanningEvent.Code);
                                "Order Status" := 0;
                                "Order No." := '';
                                "Duration (Hours)" := ProdPlanningEvent."Duration (Hours)";
                                if BatchPlanningFns.InsertDailyDetail(Rec) then
                                    Insert;
                                CurrPage.Update(false);
                            end;
                        end;
                    end;
                    FilterGroup(0);
                end;
            }
            action(DeleteEvent)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Delete Event';
                Image = Delete;
                Visible = IsEvent;

                trigger OnAction()
                begin
                    if Confirm(ConfirmDelete, false) then
                        if BatchPlanningFns.DeleteDailyDetail(Rec) then begin
                            Commit;
                            Delete(true);
                            CurrPage.Update(false); // P800-MegaApp
                        end;
                end;
            }
            action("Production Order")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Production Order';
                Enabled = NOT IsEvent;
                Image = Production;

                trigger OnAction()
                var
                    ProdOrder: Record "Production Order";
                begin
                    ProdOrder.Get("Order Status", "Order No.");
                    case ProdOrder.Status of
                        ProdOrder.Status::"Firm Planned":
                            PAGE.Run(PAGE::"Firm Planned Prod. Order", ProdOrder);
                        ProdOrder.Status::Released:
                            PAGE.Run(PAGE::"Released Production Order", ProdOrder);
                    end;
                end;
            }
        }
    }

    var
        ConfirmDelete: Label 'Delete Event?';

    trigger OnAfterGetRecord()
    begin
        IsEvent := Type = Type::"Event";
    end;

    trigger OnDeleteRecord(): Boolean
    var
        DailySummary: Record "Batch Planning Equip. Summary";
    begin
        // P8001183
        if BatchPlanningFns.DeleteDailyDetail(Rec) then begin
            Commit;
            CurrPage.Update(false); // P800-MegaApp
            exit(true);
        end else
            exit(false);
        // P8001183
    end;



    trigger OnModifyRecord(): Boolean
    begin
        if BatchPlanningFns.ModifyDailyDetail(Rec) then begin
            Commit;
            CurrPage.Update(false); // P800-MegaApp
            exit(true);
        end else
            exit(false);
    end;

    trigger OnOpenPage()
    begin
        UpdateRecords;
    end;

    var
        BatchPlanningFns: Codeunit "Batch Planning Functions";
        AllergenManagement: Codeunit "Allergen Management";
        [InDataSet]
        IsEvent: Boolean;

    procedure GetProductionDate() ProductionDate: Date
    begin
        FilterGroup(4);
        ProductionDate := GetRangeMin("Production Date");
        FilterGroup(0);
    end;

    procedure SetSharedCU(var CU: Codeunit "Batch Planning Functions")
    begin
        BatchPlanningFns := CU;
    end;

    procedure UpdateRecords()
    var
        Detail: Record "Batch Planning Order Detail" temporary;
    begin
        Reset;
        DeleteAll;

        BatchPlanningFns.GetDailyDetail(Detail);
        if Detail.FindSet then
            repeat
                Rec := Detail;
                Insert;
            until Detail.Next = 0;

        if not FindFirst then;
    end;
}

