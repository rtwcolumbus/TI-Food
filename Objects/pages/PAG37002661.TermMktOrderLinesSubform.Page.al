page 37002661 "Term. Mkt. Order Lines Subform"
{
    // PR3.70.10
    // P8000237A, Myers Nissi, Jack Reynolds, 04 AUG 05
    //   Add controls to display Variant Code
    // 
    // PRW16.00.02
    // P8000797, VerticalSoft, MMAS, 31 MAR 10
    //   Page creation
    //   Line actions added from Terminal Market Sales Order page
    // 
    // PRW16.00.03
    // P8000828, VerticalSoft, Don Bresee, 03 JUN 10
    //   Consolidate timer logic
    // 
    // PRW16.00.05
    // P8000944, Columbus IT, Jack Reynolds, 31 MAY 11
    //   Support for enahnced terminal market order entry
    // 
    // P8000946, Columbus IT, Jack Reynolds, 31 MAY 11
    //   Terminal Market availability by country of origin
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW18.00
    // P8001360, Columbus IT, Jack Reynolds, 06 NOV 14
    //   Update .NET variable references
    // 
    // PRW18.00.01
    // P8001386, Columbus IT, Jack Reynolds, 27 MAY 15
    //    Renamed NAV Food client addins
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    //   Update add-in assembly version references
    // 
    // PRW10.0
    // P8007755, To-Increase, Jack Reynolds, 22 NOV 16
    //   Update add-in assembly version references
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00
    // P80059471, To Increase, Jack Reynolds, 25 JUN 18
    //   Upgrade signal control for JavaScript
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 28 APR 22
    //   Removing support for Signal Functions codeunit
    //   Support for background validation of documents and journals

    Caption = 'Term. Mkt. Order Lines Subform';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Sales Line";

    layout
    {
        area(content)
        {
            repeater(Control37002014)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field("Country/Region of Origin Code"; "Country/Region of Origin Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = LotEditable;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        TermMktFns: Codeunit "Terminal Market Selling";
                    begin
                        exit(TermMktFns.LotLookup(Rec, Text));
                    end;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Quantity (Alt.)"; "Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Line Amount"; "Line Amount")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Promo/Rebate Amount (LCY)"; "Promo/Rebate Amount (LCY)")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Commission Amount (LCY)"; "Commission Amount (LCY)")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("<Commission Amount (LCY)>"; Comment)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ChangeLine)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Chan&ge Line';
                Image = ChangeToLines;
                ShortCutKey = 'Ctrl+G';

                trigger OnAction()
                begin
                    ChangeLine;
                end;
            }
            action(DeleteLine)
            {
                ApplicationArea = FOODBasic;
                Caption = '&Delete Line';
                Image = CancelLine;

                trigger OnAction()
                begin
                    DeleteLine;
                end;
            }
            action("Line Dimensions")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Line Dimensions';
                Image = Dimensions;
                ShortCutKey = 'Shift+Ctrl+D';

                trigger OnAction()
                begin
                    ShowDimensions;
                end;
            }
            // P800144605
            group(Errors)
            {
                Caption = 'Issues';
                Image = ErrorLog;
                Visible = BackgroundErrorCheck;
                action(ShowLinesWithErrors)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Show Lines with Issues';
                    Image = Error;
                    Visible = BackgroundErrorCheck;
                    Enabled = not ShowAllLinesEnabled;
                    ToolTip = 'View a list of sales lines that have issues before you post the document.';

                    trigger OnAction()
                    begin
                        SwitchLinesWithErrorsFilter(ShowAllLinesEnabled);
                    end;
                }
                action(ShowAllLines)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Show All Lines';
                    Image = ExpandAll;
                    Visible = BackgroundErrorCheck;
                    Enabled = ShowAllLinesEnabled;
                    ToolTip = 'View all sales lines, including lines with and without issues.';

                    trigger OnAction()
                    begin
                        SwitchLinesWithErrorsFilter(ShowAllLinesEnabled);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        DocumentErrorsMgt: Codeunit "Document Errors Mgt.";
    begin
        SalesSetup.Get;
        LotEditable := SalesSetup."Terminal Market Item Level" > SalesSetup."Terminal Market Item Level"::Lot;
        BackgroundErrorCheck := DocumentErrorsMgt.BackgroundValidationEnabled(); // P800144605
    end;

    var
        BackgroundErrorCheck: Boolean;
        ShowAllLinesEnabled: Boolean;
        Text001: Label 'Line has already been shipped.';
        SourceSalesHeader: Record "Sales Header";
        SalesSetup: Record "Sales & Receivables Setup";
        SharedItemLotAvail: Record "Item Lot Availability" temporary;
        CustCheckCreditLimit: Codeunit "Cust-Check Cr. Limit";
        [InDataSet]
        LotEditable: Boolean;

    [Obsolete('Removing support for Signal Functions codeunit', 'FOOD-21')]
    procedure SetSignalFns(var SignalCU: Codeunit "Process 800 Signal Functions")
    begin
    end;

    procedure SetSharedTable(var ItemLotAvail: Record "Item Lot Availability" temporary)
    begin
        SharedItemLotAvail.Copy(ItemLotAvail, true);
    end;

    procedure CalcInvDisc()
    begin
        CODEUNIT.Run(CODEUNIT::"Sales-Calc. Discount", Rec);
    end;

    procedure DeleteLine()
    var
        RepackLine: Record "Sales Line Repack";
        SalesSetup: Record "Sales & Receivables Setup";
        Repack: Boolean;
    begin
        // P8000944
        if "Quantity Shipped" <> 0 then
            Error(Text001);

        RepackLine.SetRange("Document Type", "Document Type");
        RepackLine.SetRange("Document No.", "Document No.");
        RepackLine.SetRange("Line No.", "Line No.");
        Repack := RepackLine.FindFirst;

        SetDeleteItemTracking;
        Delete(true);

        SalesSetup.Get;
        if Type = Type::Item then
            UpdateAvailability("No.", "Variant Code", "Lot No.", "Country/Region of Origin Code",
              -RepackLine."Target Quantity", -"Quantity (Base)", 0, SalesSetup."Terminal Market Item Level");

        if Repack then
            UpdateAvailability(RepackLine."Repack Item No.", RepackLine."Variant Code", RepackLine."Lot No.",
              "Country/Region of Origin Code", 0, 0, -RepackLine."Repack Quantity", SalesSetup."Terminal Market Item Level");
    end;

    procedure ChangeLine()
    var
        SalesHeader: Record "Sales Header";
        SalesRepack: Record "Sales Line Repack";
        SalesLine: Record "Sales Line";
        ItemLotAvail: Record "Item Lot Availability";
        ItemLotAvail2: Record "Item Lot Availability" temporary;
        SalesSetup: Record "Sales & Receivables Setup";
        Item: Record Item;
        TermMarketSelling: Codeunit "Terminal Market Selling";
        TermMktLineInput: Page "Term. Mkt. Line Input";
        Repack: Boolean;
        Qty: Decimal;
        QtyAlt: Decimal;
        UnitPrice: Decimal;
        RepackItemNo: Code[20];
        RepackQty: Decimal;
        Comment: Text[30];
        SalesQty: Decimal;
        RepackQtyIn: Decimal;
        RepackQtyOut: Decimal;
    begin
        // P8000944
        if (Type <> Type::Item) or ("No." = '') then
            exit;

        if "Quantity Shipped" <> 0 then
            Error(Text001);

        SalesSetup.Get;
        SalesHeader.Get("Document Type", "Document No.");

        Repack := SalesRepack.Get("Document Type", "Document No.", "Line No.");
        if Repack then begin
            ItemLotAvail."Item No." := SalesRepack."Repack Item No.";
            ItemLotAvail."Variant Code" := SalesRepack."Variant Code";
            ItemLotAvail."Lot No." := SalesRepack."Lot No.";
            ItemLotAvail."Country/Region of Origin Code" := "Country/Region of Origin Code";
            Qty := SalesRepack."Repack Quantity";
            QtyAlt := SalesRepack."Repack Quantity (Alt.)";
            RepackItemNo := "No."
        end else begin
            ItemLotAvail."Item No." := "No.";
            ItemLotAvail."Variant Code" := "Variant Code";
            ItemLotAvail."Lot No." := "Lot No.";
            ItemLotAvail."Country/Region of Origin Code" := "Country/Region of Origin Code";
            Qty := "Quantity (Base)";
            QtyAlt := "Quantity (Alt.)";
        end;
        case SalesSetup."Terminal Market Item Level" of
            SalesSetup."Terminal Market Item Level"::Lot:
                ItemLotAvail."Country/Region of Origin Code" := '';
            SalesSetup."Terminal Market Item Level"::"Item/Variant/Country of Origin":
                ItemLotAvail."Lot No." := '';
            SalesSetup."Terminal Market Item Level"::"Item/Variant":
                ItemLotAvail."Lot No." := '';
        end;
        if SharedItemLotAvail.Get(ItemLotAvail."Item No.", ItemLotAvail."Variant Code", ItemLotAvail."Lot No.",
          ItemLotAvail."Country/Region of Origin Code")
        then
            ItemLotAvail := SharedItemLotAvail
        else begin
            Item.Get(ItemLotAvail."Item No.");
            TermMarketSelling.CalculateAvailability(Item, "Location Code", SalesHeader."Shipment Date",
              SalesSetup."Terminal Market Item Level", ItemLotAvail2);
            ItemLotAvail2 := ItemLotAvail;
            ItemLotAvail2.Find;
            ItemLotAvail := ItemLotAvail2;
        end;
        ItemLotAvail."Qty. on Sales Order" -= Qty;
        ItemLotAvail.CalculateAvailable;

        TermMktLineInput.SetVariables('CHANGE', Repack, ItemLotAvail, SalesHeader, Qty, QtyAlt,
          "Unit Price", RepackItemNo, Comment);
        if TermMktLineInput.RunModal <> ACTION::Yes then
            exit;

        TermMktLineInput.GetVariables(Qty, UnitPrice, RepackItemNo, RepackQty, QtyAlt, Comment);

        SalesQty := -"Quantity (Base)";
        RepackQtyIn := -SalesRepack."Target Quantity";
        RepackQtyOut := -SalesRepack."Repack Quantity";

        if Qty = 0 then begin
            SetDeleteItemTracking;
            Delete(true);
        end else begin
            TermMarketSelling.ChangeSalesLine(SalesHeader, Rec, Qty, QtyAlt, UnitPrice, RepackItemNo, RepackQty, Comment, false);
            SalesQty += "Quantity (Base)";
            if Repack then begin
                SalesRepack.Get("Document Type", "Document No.", "Line No.");
                RepackQtyIn += SalesRepack."Target Quantity";
                RepackQtyOut += SalesRepack."Repack Quantity";
            end;
        end;

        if (SalesQty <> 0) or (RepackQtyIn <> 0) then
            UpdateAvailability("No.", "Variant Code", "Lot No.", "Country/Region of Origin Code",
              RepackQtyIn, SalesQty, 0, SalesSetup."Terminal Market Item Level");
        if RepackQtyOut <> 0 then
            UpdateAvailability(SalesRepack."Repack Item No.", SalesRepack."Variant Code", "Lot No.", "Country/Region of Origin Code",
              0, 0, RepackQtyOut, SalesSetup."Terminal Market Item Level");
    end;

    procedure UpdateAvailability(ItemNo: Code[20]; VariantCode: Code[10]; LotNo: Code[50]; Country: Code[10]; RepackQtyIn: Decimal; SalesQty: Decimal; RepackQtyOut: Decimal; DetailLevel: Integer): Boolean
    begin
        // P8000944
        if DetailLevel <> 0 then
            LotNo := ''
        else
            if DetailLevel <> 1 then
                Country := '';

        if SharedItemLotAvail.Get(ItemNo, VariantCode, LotNo, Country) then begin
            SharedItemLotAvail."Qty. on Line Repack (In)" += RepackQtyIn;
            SharedItemLotAvail."Qty. on Sales Order" += SalesQty;
            SharedItemLotAvail."Qty. on Line Repack (Out)" += RepackQtyOut;
            SharedItemLotAvail.CalculateAvailable;
            SharedItemLotAvail.Modify;
            exit(true);
        end;
    end;

    [Obsolete('Removing support for Signal Functions codeunit', 'FOOD-21')]
    procedure UpdateTermMktPage()
    begin
    end;

    [Obsolete('Removing support for Signal Functions codeunit', 'FOOD-21')]
    procedure UpdateItemAvailPage()
    begin
    end;
}

