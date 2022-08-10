page 37002057 "Req. Wksh. Avail. Subform"
{
    // PR4.00.02
    // P8000312A, VerticalSoft, Jack Reynolds, 20 MAR 06
    //   Subform for requisition worksheet to show item availability of selected item
    // 
    // PRW16.00.02
    // P8000791, VerticalSoft, MMAS, 16 MAR 10
    //   After the page transformation, variables Data ElementEmphasize, QuantityEmphasize were added
    //   into corresponding controls' properties.
    // 
    // PRW16.00.02
    // P8000791, VerticalSoft, MMAS, 16 MAR 10
    //   After page transformation: changed method OnAfterGetRecorrd()
    // 
    // PRW16.00.05
    // P8000936, Columbus IT, Jack Reynolds, 25 APR 11
    //   Support for Repack Orders on Sales Board
    // 
    // PRW16.00.06
    // P8001004, Columbus IT, Jack Reynolds, 15 DEC 11
    //   Fixes to FactBoxes on Req. Worksheet and Order Guide
    // 
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Req. Wksh. Avail. Subform';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Item Availability";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Data Element"; "Data Element")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Availability';
                    OptionCaption = 'On Hand,Available,Purchases,Purchase Orders,Purchase Returns,Sales,Sales Orders,Sales Returns,Output,Production Output,Repack Output,Consumption,Production Components,Repack Components,Transfers,Transfers In,Transfers Out';
                    Style = Strong;
                    StyleExpr = Available;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                    Style = Strong;
                    StyleExpr = Available;

                    trigger OnDrillDown()
                    begin
                        ReqWkshFns.ItemAvailDrillDown(ItemNo, VariantCode, LocationCode, BegDate, EndDate, Rec); // P8001004
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        Available := "Data Element" = "Data Element"::Available; // P8001004
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
            ReqWkshFns.LoadItemAvail(ItemNo, VariantCode, LocationCode, BegDate, EndDate, Rec);
        end else
            Reset;

        SetFilter("Data Element", '%1|%2|%3|%4|%5|%6|%7', "Data Element"::"On Hand", "Data Element"::Purchases, "Data Element"::Output,
          "Data Element"::Sales, "Data Element"::Consumption, "Data Element"::Transfers, "Data Element"::Available);
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
        Available: Boolean;

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

