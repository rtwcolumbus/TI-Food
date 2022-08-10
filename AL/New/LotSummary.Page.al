page 37002676 "Lot Summary"
{
    // PR4.00
    // P8000244A, Myers Nissi, Jack Reynolds, 03 OCT 05
    //   New lot summary form showing lot records and sales summary
    // 
    // PR4.00.04
    // P8000378A, VerticalSoft, Jack Reynolds, 08 SEP 06
    //   Clear unit sales price for new lots
    // 
    // PR4.00.06
    // P8000496A, VerticalSoft, Jack Reynolds, 25 JUL 07
    //   LoadLotSummary - change call to FPLotFns.GetRepackSale for different return value
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 31 JUL 07
    //   Expand/collapse bit maps replaced from left (47) and down (4) pointing trinagles to plus (47) and minus (46)
    // 
    // PRW15.00.01
    // P8000560A, VerticalSoft, Jack Reynolds, 22 JAN 08
    //   Change the bitmaps on the PictureBox to +/- signs
    // 
    // PRW15.00.03
    // P8000624A, VerticalSoft, Jack Reynolds, 19 AUG 08
    //   Add controls for country/region of origin
    // 
    // PRW16.00.03
    // P8000820, VerticalSoft, Don Bresee, 30 APR 10
    //   Transform/Rework Lot Summary
    // 
    // PRW16.00.05
    // P8000981, Columbus IT, Don Bresee, 20 SEP 11
    //   Use Pricing Qtys for Sale entries
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Lot Summary';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Worksheet;
    SourceTable = "Lot Summary";
    SourceTableTemporary = true;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(Control37002022)
            {
                ShowCaption = false;
                field("ItemNoFilter[1]"; ItemNoFilter[1])
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item No. Filter';
                    TableRelation = Item;

                    trigger OnValidate()
                    begin
                        OnAfterValidateFilter;
                    end;
                }
                field("LotNoFilter[1]"; LotNoFilter[1])
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Lot No. Filter';

                    trigger OnValidate()
                    begin
                        OnAfterValidateFilter;
                    end;
                }
                field("DocNoFilter[1]"; DocNoFilter[1])
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Document No. Filter';

                    trigger OnValidate()
                    begin
                        OnAfterValidateFilter;
                    end;
                }
            }
            group(Control37002001)
            {
                ShowCaption = false;
                field("LotTotals.""Sales Amount"""; LotTotals."Sales Amount")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Total Sales';
                    Editable = false;
                }
                field("LotTotals.""Cost Amount"""; LotTotals."Cost Amount")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Total Cost';
                    Editable = false;
                }
                field("LotTotals.""Sales Amount"" - LotTotals.""Cost Amount"""; LotTotals."Sales Amount" - LotTotals."Cost Amount")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Gross Margin';
                    Editable = false;
                }
                field("Product Cost"; LotTotals."Cost Amount" - LotTotals."Extra Charge Amount" - LotTotals."Item Charge Amount" - LotTotals."Accrual Plan Amount")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Product Cost';
                    Editable = false;
                }
                field("LotTotals.""Extra Charge Amount"""; LotTotals."Extra Charge Amount")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Extra Charges';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        PAGE.RunModal(0, ExtraChargeTemp);
                    end;
                }
                field("LotTotals.""Item Charge Amount"""; LotTotals."Item Charge Amount")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Charges';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        PAGE.RunModal(0, ItemChargeTemp);
                    end;
                }
                field("LotTotals.""Accrual Plan Amount"""; LotTotals."Accrual Plan Amount")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Marketing Plan Expense';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        PAGE.RunModal(0, AccrualLedgerTemp);
                    end;
                }
            }
            field(Control37002032; '')
            {
                ApplicationArea = FOODBasic;
                CaptionClass = Format(GetLotInfoFilters(LotInfoView[1]));
                Editable = false;
                MultiLine = true;
                ShowCaption = false;
                Style = Strong;
                StyleExpr = TRUE;
            }
            repeater(Control37002003)
            {
                IndentationColumn = IndentValue;
                ShowAsTree = true;
                ShowCaption = false;
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = DetailLine;
                    Style = Strong;
                    StyleExpr = SummaryLine;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = DetailLine;
                    Style = Strong;
                    StyleExpr = SummaryLine;
                    Visible = false;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = DetailLine;
                    Style = Strong;
                    StyleExpr = SummaryLine;
                }
                field("Item Description"; "Item Description")
                {
                    ApplicationArea = FOODBasic;
                    Style = Strong;
                    StyleExpr = SummaryLine;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = FOODBasic;
                    Style = Strong;
                    StyleExpr = SummaryLine;
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = FOODBasic;
                    Style = Strong;
                    StyleExpr = SummaryLine;
                }
                field("Release Date"; "Release Date")
                {
                    ApplicationArea = FOODBasic;
                    Style = Strong;
                    StyleExpr = SummaryLine;
                    Visible = false;
                }
                field("Expiration Date"; "Expiration Date")
                {
                    ApplicationArea = FOODBasic;
                    Style = Strong;
                    StyleExpr = SummaryLine;
                    Visible = false;
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = FOODBasic;
                    Style = Strong;
                    StyleExpr = SummaryLine;
                    Visible = false;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = FOODBasic;
                    Style = Strong;
                    StyleExpr = SummaryLine;
                    Visible = false;
                }
                field("Source Name"; "Source Name")
                {
                    ApplicationArea = FOODBasic;
                    Style = Strong;
                    StyleExpr = SummaryLine;
                }
                field(Farm; Farm)
                {
                    ApplicationArea = FOODBasic;
                    Style = Strong;
                    StyleExpr = SummaryLine;
                }
                field(Brand; Brand)
                {
                    ApplicationArea = FOODBasic;
                    Style = Strong;
                    StyleExpr = SummaryLine;
                }
                field("Country/Region of Origin Code"; "Country/Region of Origin Code")
                {
                    ApplicationArea = FOODBasic;
                    Style = Strong;
                    StyleExpr = SummaryLine;
                }
                field("Unit Sales Price"; "Unit Sales Price")
                {
                    ApplicationArea = FOODBasic;
                    Style = Strong;
                    StyleExpr = SummaryLine;
                }
                field("Quantity Sold"; "Quantity Sold")
                {
                    ApplicationArea = FOODBasic;
                    Style = Strong;
                    StyleExpr = SummaryLine;
                }
                field("Sales Amount"; "Sales Amount")
                {
                    ApplicationArea = FOODBasic;
                    Style = Strong;
                    StyleExpr = SummaryLine;
                }
                field("Original Quantity"; "Original Quantity")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = DetailLine;
                    Style = Strong;
                    StyleExpr = SummaryLine;
                }
                field("Quantity Adjusted"; "Quantity Adjusted")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = DetailLine;
                    Style = Strong;
                    StyleExpr = SummaryLine;
                }
                field("Quantity On Hand"; "Quantity On Hand")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = DetailLine;
                    Style = Strong;
                    StyleExpr = SummaryLine;
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = DetailLine;
                    Style = Strong;
                    StyleExpr = SummaryLine;
                }
                field("Cost Amount"; "Cost Amount")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = DetailLine;
                    Style = Strong;
                    StyleExpr = SummaryLine;
                }
                field("Extra Charge Amount"; "Extra Charge Amount")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = DetailLine;
                    Style = Strong;
                    StyleExpr = SummaryLine;
                    Visible = false;
                }
                field("Item Charge Amount"; "Item Charge Amount")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = DetailLine;
                    Style = Strong;
                    StyleExpr = SummaryLine;
                    Visible = false;
                }
                field("Accrual Plan Amount"; "Accrual Plan Amount")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Marketing Plan Expense';
                    HideValue = DetailLine;
                    Style = Strong;
                    StyleExpr = SummaryLine;
                    Visible = false;
                }
                field(GrossMargin; "Sales Amount" - "Cost Amount")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Gross Margin';
                    HideValue = DetailLine;
                    Style = Strong;
                    StyleExpr = SummaryLine;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&View")
            {
                Caption = '&View';
                action("&Define")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Define';
                    Image = CreateForm;

                    trigger OnAction()
                    var
                        LotInfo: Record "Lot No. Information";
                        DefineLotInfoView: Report "Define Lot Information View";
                    begin
                        LotInfo.SetView(LotInfoView[1]);
                        DefineLotInfoView.SetTableView(LotInfo);
                        DefineLotInfoView.RunModal;
                        if DefineLotInfoView.GetView(LotInfo) then begin
                            ItemNoFilter[1] := LotInfo.GetFilter("Item No.");
                            LotNoFilter[1] := LotInfo.GetFilter("Lot No.");
                            DocNoFilter[1] := LotInfo.GetFilter("Document No.");
                            LotInfoView[1] := LotInfo.GetView;
                            if LotInfoView[1] <> LotInfoView[2] then
                                ClearLotSummary;
                        end;
                    end;
                }
                action("&Clear")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Clear';
                    Image = Delete;

                    trigger OnAction()
                    begin
                        Clear(ItemNoFilter);
                        Clear(LotNoFilter);
                        Clear(DocNoFilter);
                        Clear(LotInfoView);
                        ClearLotSummary;
                    end;
                }
                separator(Separator1102603066)
                {
                }
                action("&Show Lots")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Show Lots';
                    Image = Lot;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Ctrl+S';

                    trigger OnAction()
                    begin
                        LoadLotSummary;

                        if not Find('-') then
                            Message(Text003);
                    end;
                }
            }
        }
        area(reporting)
        {
            action("Lot Settlement Report")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lot Settlement Report';
                Image = NewLotProperties;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction()
                var
                    LotInfo: Record "Lot No. Information";
                    LotSettlement: Report "Lot Settlement Report";
                begin
                    if LotInfoView[2] = LotInfoView[1] then begin
                        LotInfo.SetView(LotInfoView[2]);
                        LotSettlement.SetTableView(LotInfo);
                        LotSettlement.RunModal;
                    end;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        DetailLine := "Lot Detail";
        SummaryLine := not DetailLine;
        if SummaryLine then
            IndentValue := 0
        else
            IndentValue := 1;
    end;

    var
        ExtraChargeTemp: Record "Value Entry Extra Charge" temporary;
        ItemChargeTemp: Record "Value Entry" temporary;
        AccrualLedgerTemp: Record "Accrual Ledger Entry" temporary;
        LotTotals: Record "Lot Summary";
        FPLotFns: Codeunit "FreshPro Lot Functions";
        ItemNoFilter: array[2] of Code[250];
        LotNoFilter: array[2] of Code[250];
        DocNoFilter: array[2] of Code[250];
        Text001: Label 'A filter must be specified.';
        LotInfoView: array[2] of Text[1024];
        Text002: Label 'WHERE';
        Text003: Label 'No lots found within specified view.';
        [InDataSet]
        SummaryLine: Boolean;
        [InDataSet]
        DetailLine: Boolean;
        [InDataSet]
        IndentValue: Integer;
        IndentName: Text[30];

    procedure ClearLotSummary()
    begin
        Reset;
        DeleteAll;

        ExtraChargeTemp.Reset;
        ExtraChargeTemp.DeleteAll;
        ItemChargeTemp.Reset;
        ItemChargeTemp.DeleteAll;
        AccrualLedgerTemp.Reset;
        AccrualLedgerTemp.DeleteAll;

        Clear(LotTotals);

        CurrPage.Update;
    end;

    procedure LoadLotSummary()
    var
        GLSetup: Record "General Ledger Setup";
        LotInfo: Record "Lot No. Information";
        Item: Record Item;
        ItemLedger: Record "Item Ledger Entry";
        RepackEntry: Record "Item Ledger Entry";
        CostingQty: Decimal;
        SalesAmt: Decimal;
        UnitPrice: Decimal;
        DrilldownAmount: Decimal;
        LotSummary: Record "Lot Summary";
    begin
        if GetLotInfoFilters(LotInfoView[1]) = '' then
            Error(Text001);

        GLSetup.Get;

        ClearLotSummary;

        LotInfo.SetView(LotInfoView[1]);
        LotInfo.SetRange(Posted, true);
        LotInfo.SetRange("Created From Repack", false);

        ItemLedger.SetCurrentKey("Item No.", "Lot No."); // P8000267B

        if LotInfo.Find('-') then
            repeat
                Item.Get(LotInfo."Item No.");

                LotSummary.Init;
                LotSummary."Item No." := LotInfo."Item No.";
                LotSummary."Variant Code" := LotInfo."Variant Code";
                LotSummary."Lot No." := LotInfo."Lot No.";
                LotSummary."Lot Detail" := false;
                LotSummary."Unit Sales Price" := 0; // P8000378A
                LotSummary.Display := true;
                LotSummary."Item Description" := LotInfo.Description;
                LotSummary."Document No." := LotInfo."Document No.";
                LotSummary."Document Date" := LotInfo."Document Date";
                LotSummary."Release Date" := LotInfo."Release Date";
                LotSummary."Expiration Date" := LotInfo."Expiration Date";
                LotSummary."Source Type" := LotInfo."Source Type";
                LotSummary."Source No." := LotInfo."Source No.";
                LotSummary."Source Name" := LotInfo.SourceName;
                LotSummary.Farm := LotInfo.Farm;
                LotSummary.Brand := LotInfo.Brand;
                LotSummary."Country/Region of Origin Code" := LotInfo."Country/Region of Origin Code"; // P8000624A

                Rec := LotSummary;
                Init;
                "Lot Detail" := true;

                ItemLedger.SetRange("Item No.", LotInfo."Item No.");
                ItemLedger.SetRange("Variant Code", LotInfo."Variant Code");
                ItemLedger.SetRange("Lot No.", LotInfo."Lot No.");
                if ItemLedger.Find('-') then
                    repeat
                        CostingQty := ItemLedger.GetCostingQty;
                        LotSummary."Quantity On Hand" += CostingQty;
                        case ItemLedger."Entry Type" of
                            ItemLedger."Entry Type"::Purchase, ItemLedger."Entry Type"::Output:
                                begin
                                    ItemLedger.CalcFields("Cost Amount (Expected)", "Cost Amount (Actual)");
                                    LotSummary."Original Quantity" += CostingQty;
                                    LotSummary."Cost Amount" += ItemLedger."Cost Amount (Expected)" + ItemLedger."Cost Amount (Actual)";

                                    if ItemLedger."Entry Type" = ItemLedger."Entry Type"::Purchase then begin
                                        FPLotFns.GetExtraCharges(ItemLedger."Entry No.", LotSummary."Extra Charge Amount", ExtraChargeTemp);
                                        FPLotFns.GetItemCharges(ItemLedger."Entry No.", LotSummary."Item Charge Amount", ItemChargeTemp);
                                    end;
                                end;
                            ItemLedger."Entry Type"::Sale:
                                begin
                                    CostingQty := ItemLedger.GetPricingQty(); // P8000981
                                    ItemLedger.CalcFields("Sales Amount (Expected)", "Sales Amount (Actual)");
                                    SalesAmt := ItemLedger."Sales Amount (Expected)" + ItemLedger."Sales Amount (Actual)";
                                    LotSummary."Quantity Sold" -= CostingQty;
                                    LotSummary."Sales Amount" += SalesAmt;
                                    //FPLotFns.GetAccrualExpense(ItemLedger."Entry No.",CostingQty,Item.CostInAlternateUnits, // P8000981
                                    FPLotFns.GetAccrualExpense(ItemLedger."Entry No.", CostingQty, Item.PriceInAlternateUnits,  // P8000981
                                      LotSummary."Accrual Plan Amount", AccrualLedgerTemp);

                                    if CostingQty <> 0 then begin
                                        Init;
                                        "Unit Sales Price" := -Round(SalesAmt / CostingQty, GLSetup."Unit-Amount Rounding Precision");
                                        if not Find then
                                            Insert;
                                        "Quantity Sold" -= CostingQty;
                                        "Sales Amount" += SalesAmt;
                                        Modify;
                                    end;
                                end;
                            ItemLedger."Entry Type"::"Negative Adjmt.":
                                if ItemLedger."Order Type" = ItemLedger."Order Type"::FOODSalesRepack then begin // P8001134
                                    FPLotFns.GetRepackSale(ItemLedger, RepackEntry);                               // P8001134
                                    CostingQty := ItemLedger.GetPricingQty(); // P8000981
                                    RepackEntry.CalcFields("Sales Amount (Expected)", "Sales Amount (Actual)");
                                    SalesAmt := RepackEntry."Sales Amount (Expected)" + RepackEntry."Sales Amount (Actual)";
                                    LotSummary."Quantity Sold" -= CostingQty;
                                    LotSummary."Sales Amount" += SalesAmt;
                                    //FPLotFns.GetAccrualExpense(RepackEntry."Entry No.",RepackEntry.GetCostingQty,Item.CostInAlternateUnits, // P8000981
                                    FPLotFns.GetAccrualExpense(RepackEntry."Entry No.", RepackEntry.GetPricingQty, Item.PriceInAlternateUnits,  // P8000981
                                      LotSummary."Accrual Plan Amount", AccrualLedgerTemp);

                                    if CostingQty <> 0 then begin
                                        Init;
                                        "Unit Sales Price" := -Round(SalesAmt / CostingQty, GLSetup."Unit-Amount Rounding Precision");
                                        if not Find then
                                            Insert;
                                        "Quantity Sold" -= CostingQty;
                                        "Sales Amount" += SalesAmt;
                                        Modify;
                                    end;
                                end else
                                    LotSummary."Quantity Adjusted" += CostingQty;
                            else begin
                                    LotSummary."Quantity Adjusted" += CostingQty;
                                end;
                        end;
                    until ItemLedger.Next = 0;
                LotSummary."Cost Amount" += LotSummary."Accrual Plan Amount";
                if LotSummary."Original Quantity" <> 0 then
                    LotSummary."Unit Cost" := Round(LotSummary."Cost Amount" / LotSummary."Original Quantity",
                      GLSetup."Unit-Amount Rounding Precision");
                if LotSummary."Quantity Sold" <> 0 then
                    LotSummary."Unit Sales Price" := Round(LotSummary."Sales Amount" / LotSummary."Quantity Sold",
                      GLSetup."Unit-Amount Rounding Precision");
                Rec := LotSummary;
                Insert;
                LotTotals."Sales Amount" += LotSummary."Sales Amount";
                LotTotals."Cost Amount" += LotSummary."Cost Amount";
                LotTotals."Extra Charge Amount" += LotSummary."Extra Charge Amount";
                LotTotals."Item Charge Amount" += LotSummary."Item Charge Amount";
                LotTotals."Accrual Plan Amount" += LotSummary."Accrual Plan Amount";
            until LotInfo.Next = 0;

        ItemNoFilter[2] := ItemNoFilter[1];
        LotNoFilter[2] := LotNoFilter[1];
        DocNoFilter[2] := DocNoFilter[1];
        LotInfoView[2] := LotInfoView[1];

        CurrPage.Update;
    end;

    procedure UpdateLotInfoView()
    var
        LotInfo: Record "Lot No. Information";
    begin
        LotInfo.SetView(LotInfoView[1]);

        if DocNoFilter[1] <> '' then begin
            LotInfo.SetCurrentKey("Document No.");
            LotInfo.SetFilter("Document No.", DocNoFilter[1]);
        end else
            LotInfo.SetRange("Document No.");

        if LotNoFilter[1] <> '' then begin
            LotInfo.SetCurrentKey("Item No.", "Variant Code", "Lot No.");
            LotInfo.SetFilter("Lot No.", LotNoFilter[1]);
        end else
            LotInfo.SetRange("Lot No.");

        if ItemNoFilter[1] <> '' then begin
            LotInfo.SetCurrentKey("Item No.");
            LotInfo.SetFilter("Item No.", ItemNoFilter[1]);
        end else
            LotInfo.SetRange("Item No.");

        LotInfoView[1] := LotInfo.GetView;
    end;

    procedure GetLotInfoFilters(View: Text[1024]): Text[1024]
    var
        LotInfo: Record "Lot No. Information";
    begin
        LotInfo.SetView(View);
        exit(LotInfo.GetFilters);
    end;

    local procedure OnAfterValidateFilter()
    begin
        UpdateLotInfoView;
        if LotInfoView[1] <> LotInfoView[2] then
            ClearLotSummary;
    end;
}

