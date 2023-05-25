page 37002058 "Req. Wksh. Usage Subform"
{
    // PR4.00.02
    // P8000312A, VerticalSoft, Jack Reynolds, 20 MAR 06
    //   Subform for requisition worksheet to show item usage and usage projection of selected item
    // 
    // PRW16.00.06
    // P8001004, Columbus IT, Jack Reynolds, 15 DEC 11
    //   Fixes to FactBoxes on Req. Worksheet and Order Guide
    // 
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Req. Wksh. Usage Subform';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Usage History and Projection";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field(PeriodDescription; PeriodDescription)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Usage';
                }
                field("Comparison Period"; "Comparison Period")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Prior';
                }
                field("Current Period"; "Current Period")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Current';
                    Style = Attention;
                    StyleExpr = CurrentPeriod;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        CurrentPeriod := "Period Offset" > 0; // P8001004
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        ItmNo: Code[20];
        VarCode: Code[10];
    begin
        // P8001004
        FilterGroup(4);
        if GetFilter("Item No.") <> '' then
            ItmNo := GetRangeMin("Item No.")
        else
            ItmNo := '';
        if GetFilter("Variant Code") <> '' then
            VarCode := GetRangeMin("Variant Code")
        else
            VarCode := '**********';
        if GetFilter("Location Code") <> '' then
            LocCode := GetRangeMin("Location Code");

        if (ItemNo <> ItmNo) or (VariantCode <> VarCode) or (LocationCode <> LocCode) then begin
            ItemNo := ItmNo;
            if OrderGuideMgmt.CalledFromOrderGuide then
                VariantCode := OrderGuideMgmt.GetVariant(ItemNo)
            else
                VariantCode := VarCode;
            LocationCode := LocCode;
            ReqWkshFns.ProjectUsage(ItemNo, VariantCode, LocationCode, BegDate, EndDate, Rec);
        end else
            Reset;
        FilterGroup(0);

        exit(Find(Which));
    end;

    var
        OrderGuideMgmt: Codeunit "Purchase Order-Order Guide";
        ItemNo: Code[20];
        VariantCode: Code[10];
        LocationCode: Code[10];
        LocCode: Code[10];
        BegDate: Date;
        EndDate: Date;
        ReqWkshFns: Codeunit "Process 800 Req. Wksh. Fns.";
        [InDataSet]
        CurrentPeriod: Boolean;

    procedure SetCurrentLocation("Code": Code[10])
    begin
        // P8001004
        LocCode := Code;
    end;

    procedure SetDates(Date1: Date; Date2: Date)
    begin
        // P8001004
        BegDate := Date1;
        EndDate := Date2;
    end;

    procedure SetOrderGuideCodeunit(var OrderGuide: Codeunit "Purchase Order-Order Guide")
    begin
        // P8001004
        OrderGuideMgmt := OrderGuide;
    end;
}

