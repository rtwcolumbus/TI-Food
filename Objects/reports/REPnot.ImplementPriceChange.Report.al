#if not CLEAN19
report 7053 "Implement Price Change"
{
    // PR3.60
    //   Sales Pricing
    // 
    // PR5.00
    // P8000539A, VerticalSoft, Don Bresee, 17 NOV 07
    //   Add Cost Calculation Method and Rounding Method
    // 
    // P8000546A, VerticalSoft, Don Bresee, 17 NOV 07
    //   Change Price ID and Template ID to AutoIncrement
    //   Next Date updated on Price Template when prices are implemented
    // 
    // PRW16.00.04
    // P8000861, VerticalSoft, Jack Reynolds, 25 AUG 10
    //   Fix problem attmpting to change AutoIncrement Price ID
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group

    Caption = 'Implement Price Change';
    ProcessingOnly = true;
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
    ObsoleteTag = '16.0';

    dataset
    {
        dataitem("Sales Price Worksheet"; "Sales Price Worksheet")
        {
            DataItemTableView = SORTING("Starting Date", "Ending Date", "Sales Type", "Sales Code");
            RequestFilterFields = "Item Type", "Item Code", "Sales Type", "Sales Code", "Unit of Measure Code", "Currency Code";

            trigger OnAfterGetRecord()
            begin
                // PR3.60
                // Window.UPDATE(1,"Item No.");
                //
                Window.Update(1, "Item Type");
                Window.Update(6, "Item Code");
                // PR3.60

                Window.Update(2, "Sales Type");
                Window.Update(3, "Sales Code");
                Window.Update(4, "Currency Code");
                Window.Update(5, "Starting Date");

                // PR3.60
                // SalesPrice.Init();
                // SalesPrice.Validate("Item No.", "Item No.");
                Clear(SalesPrice);

                SalesPrice.Validate("Item Type", "Item Type");
                SalesPrice.Validate("Item Code", "Item Code");
                // PR3.60

                SalesPrice.Validate("Sales Type", "Sales Type");
                SalesPrice.Validate("Sales Code", "Sales Code");
                SalesPrice.Validate("Unit of Measure Code", "Unit of Measure Code");
                SalesPrice.Validate("Variant Code", "Variant Code");
                SalesPrice.Validate("Starting Date", "Starting Date");
                SalesPrice.Validate("Ending Date", "Ending Date");

                // PR3.60
                SalesPrice.Validate("Pricing Method", "Pricing Method");
                SalesPrice.Validate("Cost Reference", "Cost Reference");
                SalesPrice.Validate("Cost Calc. Method Code", "Cost Calc. Method Code"); // P8000539A
                SalesPrice.Validate("Price Rounding Method", "Price Rounding Method");   // P8000539A
                SalesPrice.Validate("Price Type", "Price Type");
                SalesPrice.Validate("Template ID", "Template ID");
                // PR3.60

                SalesPrice."Minimum Quantity" := "Minimum Quantity";
                SalesPrice."Currency Code" := "Currency Code";
                SalesPrice."Unit Price" := "New Unit Price";
                SalesPrice."Price Includes VAT" := "Price Includes VAT";
                SalesPrice."Allow Line Disc." := "Allow Line Disc.";
                SalesPrice."Allow Invoice Disc." := "Allow Invoice Disc.";
                SalesPrice."VAT Bus. Posting Gr. (Price)" := "VAT Bus. Posting Gr. (Price)";
                // PR3.60
                SalesPrice."Cost Adjustment" := "New Cost Adjustment";
                SalesPrice."Use Break Charge" := "Use Break Charge";
                SalesPrice."Maximum Quantity" := "Maximum Quantity";
                SalesPrice."Special Price" := "Special Price";
                // PR3.60
                OnAfterCopyToSalesPrice(SalesPrice, "Sales Price Worksheet");

                // PR3.60
                // IF SalesPrice."Unit Price" <> 0 THEN
                if (SalesPrice."Unit Price" <> 0) or
                   (SalesPrice."Cost Adjustment" <> 0)
                then begin             // P8000546A
                                       // PR3.60
                    if not SalesPrice.Insert(true) then begin
                        UpdatePriceID;       // P8000546A, P8000861
                        SalesPrice.Modify(true);
                    end;
                    UpdatePriceTemplate; // P8000546A
                end;                   // P8000546A
            end;

            trigger OnPostDataItem()
            var
                ConfirmManagement: Codeunit "Confirm Management";
            begin
                Commit();
                if not DeleteWhstLine then
                    DeleteWhstLine := ConfirmManagement.GetResponseOrDefault(Text005, true);
                if DeleteWhstLine then
                    DeleteAll();
                Commit();
                if SalesPrice.FindFirst() then;
            end;

            trigger OnPreDataItem()
            begin
                Window.Open(
                  Text000 +

                  // PR3.60
                  // Text007 +
                  //
                  Text37002000 +
                  Text37002001 +
                  // PR3.60

                  Text008 +
                  Text009 +
                  Text010 +
                  Text011);
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

    var
        Text000: Label 'Updating Unit Prices...\\';
        Text005: Label 'The item prices have now been updated in accordance with the suggested price changes.\\Do you want to delete the suggested price changes?';
        Text007: Label 'Item No.               #1##########\';
        Text008: Label 'Sales Type             #2##########\';
        Text009: Label 'Sales Code             #3##########\';
        Text010: Label 'Currency Code          #4##########\';
        Text011: Label 'Starting Date          #5######';
        SalesPrice: Record "Sales Price";
        Window: Dialog;
        DeleteWhstLine: Boolean;
        Text37002000: Label 'Item Type              #1##########\';
        Text37002001: Label 'Item Code              #6##########\';

    procedure InitializeRequest(NewDeleteWhstLine: Boolean)
    begin
        DeleteWhstLine := NewDeleteWhstLine;
    end;

    local procedure UpdatePriceTemplate()
    var
        PriceTemplate: Record "Recurring Price Template";
    begin
        // P8000546A
        if (SalesPrice."Template ID" <> 0) then
            if PriceTemplate.Get(SalesPrice."Template ID") then
                if (SalesPrice."Ending Date" >= PriceTemplate."Next Date") then begin
                    PriceTemplate.Validate("Next Date", SalesPrice."Ending Date" + 1);
                    PriceTemplate.Modify(true);
                end;
    end;

    local procedure UpdatePriceID()
    var
        OldSalesPrice: Record "Sales Price";
    begin
        // P8000546A
        OldSalesPrice := SalesPrice;
        if OldSalesPrice.Find then
            SalesPrice."Price ID" := OldSalesPrice."Price ID";
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyToSalesPrice(var SalesPrice: Record "Sales Price"; SalesPriceWorksheet: Record "Sales Price Worksheet")
    begin
    end;
}
#endif
