report 37002040 "Suggest Recurring Prices"
{
    // PR3.60
    //   Recurring Price Templates
    // 
    // PR5.00
    // P8000539A, VerticalSoft, Don Bresee, 17 NOV 07
    //   Add Cost Calculation Method and Rounding Method
    //   Eliminate generation of fixed prices that are zero
    // 
    // P8000546A, VerticalSoft, Don Bresee, 17 NOV 07
    //   Remove Special Price field
    // 
    // PRW16.00.03
    // P8000792, VerticalSoft, Rick Tweedle, 17 MAR 10
    //   Converted using TIF Editor
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group

    Caption = 'Suggest Recurring Prices';
    ProcessingOnly = true;

    dataset
    {
        dataitem(SalesPriceTemplate; "Recurring Price Template")
        {
            DataItemTableView = SORTING("Next Date", "Starting Date");
            RequestFilterFields = "Next Date", "Sales Type", "Sales Code", "Item Type", "Item Code", "Starting Date";
            dataitem(DateLoop; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                dataitem(ItemTypeItem; Item)
                {
                    DataItemTableView = SORTING("No.");

                    trigger OnAfterGetRecord()
                    begin
                        InsertWkshLine("No.");
                    end;

                    trigger OnPreDataItem()
                    begin
                        if (not SalesPriceTemplate2."Generate Fixed Item Prices") or
                           (SalesPriceTemplate2."Item Type" <> SalesPriceTemplate2."Item Type"::Item)
                        then
                            CurrReport.Break;

                        SetFilter("No.", SalesPriceTemplate2."Item Code"); // P8000546A
                    end;
                }
                dataitem(ItemCategoryDescendants; "Item Category")
                {
                    dataitem(ItemCategoryTypeItem; Item)
                    {
                        DataItemLink = "Item Category Code" = FIELD(Code);
                        DataItemTableView = SORTING("Item Type", "Item Category Code");

                        trigger OnAfterGetRecord()
                        begin
                            InsertWkshLine("No.");
                        end;
                    }

                    trigger OnPreDataItem()
                    begin
                        // P8007749
                        if (not SalesPriceTemplate2."Generate Fixed Item Prices") or
                           (SalesPriceTemplate2."Item Type" <> SalesPriceTemplate2."Item Type"::"Item Category")
                        then
                            CurrReport.Break;

                        ItemCategory.Get(SalesPriceTemplate2."Item Code");
                        ItemCategoryDescendants.Reset;
                        ItemCategoryDescendants := ItemCategory;
                        ItemCategoryDescendants.Mark(true);
                        ItemCategory.MarkDesscendants(ItemCategoryDescendants);
                        ItemCategoryDescendants.MarkedOnly(true);
                        ItemCategoryDescendants.FindSet;
                    end;
                }
                dataitem(UpdateSalesPriceTemplate; "Integer")
                {
                    DataItemTableView = SORTING(Number);
                    MaxIteration = 1;

                    trigger OnAfterGetRecord()
                    begin
                        if not SalesPriceTemplate2."Generate Fixed Item Prices" then
                            InsertWkshLine('');

                        SalesPriceTemplate2.Validate("Next Date", NewNextDate);
                        // SalesPriceTemplate2.MODIFY; // P8000546A
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if (Number > 1) then begin
                        if (SalesPriceTemplate2."Next Date" > LastNextDate) then
                            CurrReport.Break;
                        NewNextDate := CalcDate(SalesPriceTemplate2."Pricing Frequency", SalesPriceTemplate2."Next Date");
                    end;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if (("Next Date" = 0D) and ("Starting Date" = 0D)) or
                   (("Ending Date" <> 0D) and ("Next Date" > "Ending Date"))
                then
                    CurrReport.Skip;

                SalesPriceTemplate2 := SalesPriceTemplate;
                if (SalesPriceTemplate2."Next Date" = 0D) then
                    SalesPriceTemplate2.Validate("Next Date", SalesPriceTemplate2."Starting Date");

                if (SalesPriceTemplate2."Next Date" > LastNextDate) then
                    CurrReport.Skip;

                Window.Update(1, SalesPriceTemplate2."Next Date");
                Window.Update(2,
                  DelChr(
                    StrSubstNo(
                      '%1 %2',                          // P8007749
                      SalesPriceTemplate2."Item Type",
                      SalesPriceTemplate2."Item Code"), // P8007749
                    '><'));

                ItemSalesPriceMgmt.SetPriceTemplateSource(SalesPriceTemplate2);

                NewNextDate := CalcDate(SalesPriceTemplate2."Pricing Frequency", SalesPriceTemplate2."Next Date");
            end;

            trigger OnPreDataItem()
            begin
                FilterGroup(2);
                SetFilter("Starting Date", '..%1', LastNextDate);
                SetFilter("Pricing Frequency", '<>%1', EmptyDateFormula);
                FilterGroup(0);

                Window.Open(
                  Text001 +
                  Text002 +
                  Text003);
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        LastNextDate := SalesPriceTemplate.GetRangeMax("Next Date");
    end;

    var
        Text001: Label 'Processing Date            #1##################\';
        SalesPriceTemplate2: Record "Recurring Price Template";
        ItemCategory: Record "Item Category";
        SalesPriceWksh2: Record "Sales Price Worksheet";
        SalesPriceWksh: Record "Sales Price Worksheet";
        Window: Dialog;
        EmptyDateFormula: DateFormula;
        Item: Record Item;
        LastNextDate: Date;
        NewNextDate: Date;
        PriceAlreadyExists: Boolean;
        ItemSalesPriceMgmt: Codeunit "Item Sales Price Management";
        Text002: Label 'Processing Price Template  #2##################\';
        Text003: Label 'Processing Item            #3##################';

    procedure InsertWkshLine(ItemNo: Code[20])
    begin
        with SalesPriceTemplate2 do begin
            if "Generate Fixed Item Prices" and (Item."No." <> ItemNo) then begin
                Item.Get(ItemNo);
                Window.Update(3, ItemNo);
            end;

            Clear(SalesPriceWksh);
            SalesPriceWksh.Validate("Sales Type", "Sales Type");
            SalesPriceWksh.Validate("Sales Code", "Sales Code");

            if "Generate Fixed Item Prices" then begin
                SalesPriceWksh.Validate("Item Type", SalesPriceWksh."Item Type"::Item);
                SalesPriceWksh.Validate("Item Code", ItemNo);
            end else begin
                SalesPriceWksh.Validate("Item Type", "Item Type");
                SalesPriceWksh.Validate("Item Code", "Item Code");
            end;

            SalesPriceWksh.Validate("Currency Code", "Currency Code");
            SalesPriceWksh.Validate("Unit of Measure Code", "Unit of Measure Code");
            SalesPriceWksh.Validate("Variant Code", "Variant Code");

            SalesPriceWksh.Validate("Starting Date", "Next Date");
            SalesPriceWksh.Validate("Ending Date", NewNextDate - 1);

            SalesPriceWksh.Validate("Price Type", "Price Type");

            if "Generate Fixed Item Prices" then
                ItemSalesPriceMgmt.CalculatePriceTemplate(ItemNo, SalesPriceWksh."New Unit Price")
            else begin
                SalesPriceWksh.Validate("Pricing Method", "Pricing Method");
                SalesPriceWksh.Validate("New Cost Adjustment", "Cost Adjustment");
                SalesPriceWksh.Validate("Cost Reference", "Cost Reference");
                SalesPriceWksh.Validate("Cost Calc. Method Code", "Cost Calc. Method Code"); // P8000539A
                SalesPriceWksh.Validate("Price Rounding Method", "Price Rounding Method");   // P8000539A
                SalesPriceWksh.Validate("New Unit Price", "Unit Price");
            end;

            SalesPriceWksh."Minimum Quantity" := "Minimum Quantity";
            SalesPriceWksh."Maximum Quantity" := "Maximum Quantity";
            SalesPriceWksh."Template ID" := "Template ID";

            SalesPriceWksh.CalcCurrentPrice(PriceAlreadyExists);

            SalesPriceWksh."Price Includes VAT" := false;
            SalesPriceWksh."VAT Bus. Posting Gr. (Price)" := "VAT Bus. Posting Gr. (Price)";
            SalesPriceWksh."Allow Invoice Disc." := "Allow Invoice Disc.";
            SalesPriceWksh."Allow Line Disc." := "Allow Line Disc.";
            SalesPriceWksh."Use Break Charge" :=
              "Use Break Charge" and
              ((not "Generate Fixed Item Prices") or ("Unit of Measure Code" = ''));

            // SalesPriceWksh."Special Price" := "Special Price"; // P8000546A

            if "Generate Fixed Item Prices" and (SalesPriceWksh."New Unit Price" = 0) then // P8000539A
                exit;                                                                        // P8000539A

            SalesPriceWksh2 := SalesPriceWksh;
            if not SalesPriceWksh2.Find then
                SalesPriceWksh.Insert(true)
            else
                if (SalesPriceWksh."New Unit Price" < SalesPriceWksh2."New Unit Price") then
                    SalesPriceWksh.Modify(true);
        end;
    end;
}

