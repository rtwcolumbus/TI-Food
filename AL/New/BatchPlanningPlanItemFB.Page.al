page 37002528 "Batch Planning - Plan Item FB"
{
    // PRW16.00.05
    // P8000959, Columbus IT, Jack Reynolds, 21 JUN 11
    //   Item Availability factbox for Batch Planning
    // 
    // PRW16.00.06
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status

    Caption = 'Batch Planning - Plan Item FactBox';
    PageType = CardPart;
    SourceTable = "Quick Planner Worksheet";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            field("Safety Stock"; "Safety Stock")
            {
                ApplicationArea = FOODBasic;
            }
            field("Qty. Available"; "Qty. Available")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Projected Available';
            }
            field("On Hand"; "On Hand")
            {
                ApplicationArea = FOODBasic;

                trigger OnDrillDown()
                begin
                    OnHandDrillDown(LotStatusExclusionFilter); // P8001083
                end;
            }
            field(Demand; Demand)
            {
                ApplicationArea = FOODBasic;
            }
            field("Qty. on Forecast"; "Qty. on Forecast")
            {
                ApplicationArea = FOODBasic;
                Caption = '   Forecast';
            }
            field("Qty. on Sales Order"; "Qty. on Sales Order")
            {
                ApplicationArea = FOODBasic;
                Caption = '   Sales Orders';
            }
            field("Qty. on Transfer (Outbound)"; "Qty. on Transfer (Outbound)")
            {
                ApplicationArea = FOODBasic;
                Caption = '   Transfers';
            }
            field("Qty. Required For Production"; "Qty. Required For Production")
            {
                ApplicationArea = FOODBasic;
                Caption = '   Production Requirements';
            }
            field(Orders; Orders)
            {
                ApplicationArea = FOODBasic;
            }
            field("Qty. on Purchase Order"; "Qty. on Purchase Order")
            {
                ApplicationArea = FOODBasic;
                Caption = '   Purchase Orders';
            }
            field("Qty. on Transfer (Inbound)"; "Qty. on Transfer (Inbound)")
            {
                ApplicationArea = FOODBasic;
                Caption = '   Transfers';

                trigger OnDrillDown()
                begin
                    TransInDrilldown(EndDate - BeginDate, LotStatusExclusionFilter); // P8001083
                end;
            }
            field("Qty. on Production Order"; "Qty. on Production Order")
            {
                ApplicationArea = FOODBasic;
                Caption = '   Production Orders';
            }
        }
    }

    actions
    {
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        FilterGroup(4);
        SetRange("Date Filter", BeginDate, EndDate);
        SetRange("Location Filter", LocationCode);
        FilterGroup(0);
        exit(Find(Which));
    end;

    var
        BeginDate: Date;
        EndDate: Date;
        LocationCode: Code[10];
        LotStatusExclusionFilter: Text[1024];

    procedure ClearData(Date1: Date; Date2: Date; LocCode: Code[10])
    begin
        Reset;
        DeleteAll;
        BeginDate := Date1;
        EndDate := Date2;
        LocationCode := LocCode;
        LotStatusExclusionFilter := ''; // P8001083
    end;

    procedure InsertRecord(QuickPlanner: Record "Quick Planner Worksheet")
    begin
        Rec := QuickPlanner;
        Insert;
    end;

    procedure SetLotStatus(ExclusionFilter: Text[1024])
    begin
        // P8001083
        LotStatusExclusionFilter := ExclusionFilter;
    end;
}

