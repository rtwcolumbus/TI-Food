page 37002170 "Req. Wksh. Vendor Subform"
{
    // PR4.00.02
    // P8000312A, VerticalSoft, Jack Reynolds, 20 MAR 06
    //   Subform for requisition worksheet to show vendors for selected item
    // 
    // PR4.00.06
    // P8000493A, VerticalSoft, Jack Reynolds, 06 JUL 07
    //   Use new table as source table and basis for temp table
    // 
    // PRW16.00.06
    // P8001004, Columbus IT, Jack Reynolds, 15 DEC 11
    //   Fixes to FactBoxes on Req. Worksheet and Order Guide
    // 
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Req. Wksh. Vendor Subform';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Item Vendor";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = FOODBasic;
                    Style = Strong;
                    StyleExpr = IsCurrentVendor;
                }
                field(VendorName; VendorName)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Vendor Name';
                    Style = Strong;
                    StyleExpr = IsCurrentVendor;
                }
                field("Lead Time Calculation"; "Lead Time Calculation")
                {
                    ApplicationArea = FOODBasic;
                    Style = Strong;
                    StyleExpr = IsCurrentVendor;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        // P8001004
        IsCurrentVendor := "Vendor No." = CurrentVendorNo;
        Vendor.Get("Vendor No.");
        VendorName := Vendor.Name;
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        ItmNo: Code[20];
        VarCode: Code[10];
    begin
        // P8001004
        FilterGroup(4);
        if GetFilter("Vendor No.") <> '' then begin
            CurrentVendorNo := GetRangeMin("Vendor No.");
            SetRange("Vendor No.");
        end;

        if GetFilter("Item No.") <> '' then
            ItmNo := GetRangeMin("Item No.")
        else
            ItmNo := '';
        if GetFilter("Variant Code") <> '' then
            VarCode := GetRangeMin("Variant Code")
        else
            VarCode := '';
        if (ItemNo <> ItmNo) or (VariantCode <> VarCode) then begin
            ItemNo := ItmNo;
            VariantCode := VarCode;
            ReqWkshFns.LoadItemVendor(ItemNo, VariantCode, Rec);
        end;
        FilterGroup(0);
        Reset;

        exit(Find(Which));
    end;

    var
        Vendor: Record Vendor;
        ReqWkshFns: Codeunit "Process 800 Req. Wksh. Fns.";
        ItemNo: Code[20];
        VariantCode: Code[10];
        CurrentVendorNo: Code[20];
        [InDataSet]
        IsCurrentVendor: Boolean;
        [InDataSet]
        VendorName: Text[100];

    procedure SetCurrentVendor(VendorNo: Code[20])
    begin
        // P8001004
        CurrentVendorNo := VendorNo;
    end;
}

