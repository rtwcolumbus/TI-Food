page 37002172 "Req. Wksh. Planning Subform"
{
    // PR4.00.02
    // P8000312A, VerticalSoft, Jack Reynolds, 24 MAR 06
    //   Subform for requisition worksheet to show planning parameters for selected item/SKU
    // 
    // PR4.00.04
    // P8000406A, VerticalSoft, Jack Reynolds, 10 OCT 06
    //   Resize and move controls to make room for additional controls to show Include Inventory
    // 
    // PRW16.00.06
    // P8001004, Columbus IT, Jack Reynolds, 15 DEC 11
    //   Fixes to FactBoxes on Req. Worksheet and Order Guide
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Req. Wksh. Planning Subform';
    PageType = CardPart;
    SourceTable = "Stockkeeping Unit";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            field("Reordering Policy"; "Reordering Policy")
            {
                ApplicationArea = FOODBasic;
            }
            field("Reorder Point"; "Reorder Point")
            {
                ApplicationArea = FOODBasic;
                BlankZero = true;
            }
            field("Reorder Quantity"; "Reorder Quantity")
            {
                ApplicationArea = FOODBasic;
                BlankZero = true;
            }
            field("Maximum Inventory"; "Maximum Inventory")
            {
                ApplicationArea = FOODBasic;
                BlankZero = true;
            }
            field("Overflow Level"; "Overflow Level")
            {
                ApplicationArea = FOODBasic;
            }
            field("Time Bucket"; "Time Bucket")
            {
                ApplicationArea = FOODBasic;
            }
            field("Lot Accumulation Period"; "Lot Accumulation Period")
            {
                ApplicationArea = FOODBasic;
            }
            field("Rescheduling Period"; "Rescheduling Period")
            {
                ApplicationArea = FOODBasic;
            }
            field("Safety Lead Time"; "Safety Lead Time")
            {
                ApplicationArea = FOODBasic;
            }
            field("Safety Stock Quantity"; "Safety Stock Quantity")
            {
                ApplicationArea = FOODBasic;
                BlankZero = true;
            }
            field("Minimum Order Quantity"; "Minimum Order Quantity")
            {
                ApplicationArea = FOODBasic;
                BlankZero = true;
            }
            field("Maximum Order Quantity"; "Maximum Order Quantity")
            {
                ApplicationArea = FOODBasic;
                BlankZero = true;
            }
            field("Order Multiple"; "Order Multiple")
            {
                ApplicationArea = FOODBasic;
                BlankZero = true;
            }
            field("Dampener Period"; "Dampener Period")
            {
                ApplicationArea = FOODBasic;
            }
            field("Dampener Quantity"; "Dampener Quantity")
            {
                ApplicationArea = FOODBasic;
            }
            field("Include Inventory"; "Include Inventory")
            {
                ApplicationArea = FOODBasic;
            }
        }
    }

    actions
    {
    }

    trigger OnFindRecord(Which: Text): Boolean
    var
        GetPlanningParmaters: Codeunit "Planning-Get Parameters";
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
            Reset;
            DeleteAll;
            GetPlanningParmaters.AtSKU(Rec, ItemNo, VariantCode, LocationCode);
            Insert;
        end;
        FilterGroup(0);

        exit(Find(Which));
    end;

    var
        OrderGuideMgmt: Codeunit "Purchase Order-Order Guide";
        ItemNo: Code[20];
        VariantCode: Code[10];
        LocationCode: Code[10];
        LocCode: Code[10];

    procedure SetCurrentLocation("Code": Code[10])
    begin
        // P8001004
        LocCode := Code;
    end;

    procedure SetOrderGuideCodeunit(var OrderGuide: Codeunit "Purchase Order-Order Guide")
    begin
        // P8001004
        OrderGuideMgmt := OrderGuide;
    end;
}

