page 37002673 "Truckload Receiving"
{
    // PR3.70.06
    // P8000080A, Myers Nissi, Steve Post, 03 SEP 04
    //   Add filtering for pickup load no
    //   On posting complete the pickup load and update load lines with receipt no
    // 
    // PR4.00.06
    // P8000487A, VerticalSoft, Jack Reynolds, 12 JUN 07
    //   Multi-currency support for extra charges
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 17 AUG 07
    //   Fix problem with extra charges being assigned to purchase order
    // 
    // P8000510A, VerticalSoft, Jack Reynolds, 06 SEP 07
    //   Fix problem updating form after posting
    // 
    // P8000752
    //   OnAfterGetRecord()
    //   OnClosePage()
    //   PostOrders()
    // 
    // PRW16.00.04
    // P8000840, VerticalSoft, Jack Reynolds, 12 JUL 10
    //   Fix error when closing page
    // 
    // PRW16.00.05
    // P8000928, Columbus IT, Jack Reynolds, 06 APR 11
    //   Support for extra charges on transfer orders
    // 
    // P8000950, Columbus IT, Jack Reynolds, 25 MAY 11
    //   More flexibilty in specifying date filters
    // 
    // P8000988, Columbus IT, Jack Reynolds, 07 NOV 11
    //   Fix problem allocating to negative lines
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001032, Columbus IT, Jack Reynolds, 02 FEB 12
    //   Correct flaw in design of Document Extra Charge table
    // 
    // P8001047, Columbus IT, Jack Reynolds, 12 DEC 12
    //   Label printing
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 19 FEB 13
    //   Restoring the SaveValues Property.
    // 
    // PRW17.10.01
    // P8001259, Columbus IT, Jack Reynolds, 13 JAN 14
    //   Fix problem when no shortcust extra charges are defined
    // 
    // PRW17.10.02
    // P8001275, Columbus IT, Jack Reynolds, 03 FEB 14
    //   Display log of posting errors
    // 
    // PRW17.10.03
    // P8001333, Columbus IT, Jack Reynolds, 03 JUL 14
    //   Fix problem allocating extra charges
    // 
    // P8001334, Columbus IT, Jack Reynolds, 03 JUL 14
    //   Remove Line actions from ribbon; allow marking of multiple records at one time
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.02
    // P80073464, To-Increase, Gangabhushan, 30 APR 19
    //   TI-13250 - Orders are prematurely removed from pickup loads and the status of the load is set to complete
    // 
    // PRW111.00.02
    // P80073466, To-Increase, Gangabhushan, 13 JUN 19
    //   TI-13251 - When clicking on show marked orders in truckload receiving, the page closes
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    ApplicationArea = FOODBasic;
    Caption = 'Truckload Receiving';
    InsertAllowed = false;
    PageType = ListPlus;
    RefreshOnActivate = true;
    SaveValues = true;
    SourceTable = "Purchase Header";
    SourceTableView = WHERE("Document Type" = FILTER(Order),
                            "Lines to Receive" = FILTER(<> 0));
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(Filters)
            {
                Caption = 'Filters';
                field(OrderNoFilter; OrderNoFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Order Number';
                    TableRelation = "Purchase Header"."No." WHERE("Document Type" = CONST(Order));

                    trigger OnValidate()
                    begin
                        OrderNoFilterOnAfterValidate;
                    end;
                }
                field(RcptDateFilter; RcptDateFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Expected Receipt Date';

                    trigger OnValidate()
                    begin
                        RcptDateFilterOnAfterValidate;
                    end;
                }
                field(VendNoFilter; VendNoFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Vendor Number';
                    TableRelation = Vendor;

                    trigger OnValidate()
                    begin
                        VendNoFilterOnAfterValidate;
                    end;
                }
                field(VendNameFilter; VendNameFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Vendor Name';

                    trigger OnValidate()
                    begin
                        VendNameFilterOnAfterValidate;
                    end;
                }
                field(VendShipNoFilter; VendShipNoFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Vendor Shipment No.';

                    trigger OnValidate()
                    begin
                        VendShipNoFilterOnAfterValidat;
                    end;
                }
                field(PickupLoadNoFilter; PickupLoadNoFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Pickup Load No.';
                    TableRelation = "Pickup Load Header" WHERE(Status = CONST(Open));

                    trigger OnValidate()
                    begin
                        PickupLoadNoFilterOnAfterValid;
                    end;
                }
            }
            group(ReceivingInformation)
            {
                Caption = 'Receiving Information';
                field(VendorShipmentNo; RecvInfo."Vendor Shipment No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Vendor Shipment No.';
                }
                field(ReceivedBy; RecvInfo."Received By")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Received By';
                }
                field(CheckedBy; RecvInfo."Checked By")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Checked By';
                }
                field(RecorderUnitNo; RecvInfo."Recorder Unit No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Recorder Unit No.';
                }
                field(LowTemperature; RecvInfo."Low Temperature")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Low Temperature';
                }
                field(HighTemperature; RecvInfo."High Temperature")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'High Temperature';
                }
                field(ShortcutECVendor1; ShortcutECVendor[1])
                {
                    ApplicationArea = FOODBasic;
                    AccessByPermission = TableData "Extra Charge" = R;
                    CaptionClass = '37002660,2,1';
                    Visible = ShowExtraCharge1;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //LookupShortcutECVendor(1,ShortcutECVendor[1]); // P8000466A
                        exit(ExtraChargeMgmt.LookupExtraVendor(1, Text)); // P8000466A
                    end;

                    trigger OnValidate()
                    begin
                        if ShortcutECVendor[1] <> '' then // P8001333
                                                          //ValidateShortcutECVendor(1,ShortcutECVendor[1]);          // P8000466A
                            ExtraChargeMgmt.ValidateExtraVendor(1, ShortcutECVendor[1]); // P8000466A
                    end;
                }
                field(ShortcutECCharge1; ShortcutECCharge[1])
                {
                    ApplicationArea = FOODBasic;
                    AccessByPermission = TableData "Extra Charge" = R;
                    AutoFormatType = 2;
                    CaptionClass = '37002660,1,1';
                    Visible = ShowExtraCharge1;

                    trigger OnValidate()
                    begin
                        //ValidateShortcutECCharge(1,ShortcutECCharge[1]);          // P8000466A
                        ExtraChargeMgmt.ValidateExtraCharge(1, ShortcutECCharge[1]); // P8000466A
                    end;
                }
            }
            group("Purchase Orders")
            {
                Caption = 'Purchase Orders';
                repeater(Control37002011)
                {
                    Editable = false;
                    ShowCaption = false;
                    field(Marked; IsMarked)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Marked';
                    }
                    field("No."; "No.")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Buy-from Vendor No."; "Buy-from Vendor No.")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Buy-from Vendor Name"; "Buy-from Vendor Name")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Vendor Shipment No."; "Vendor Shipment No.")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Buy-from Vendor Name 2"; "Buy-from Vendor Name 2")
                    {
                        ApplicationArea = FOODBasic;
                        Visible = false;
                    }
                    field("Buy-from Address"; "Buy-from Address")
                    {
                        ApplicationArea = FOODBasic;
                        Visible = false;
                    }
                    field("Buy-from Address 2"; "Buy-from Address 2")
                    {
                        ApplicationArea = FOODBasic;
                        Visible = false;
                    }
                    field("Buy-from Post Code"; "Buy-from Post Code")
                    {
                        ApplicationArea = FOODBasic;
                        Visible = false;
                    }
                    field("Buy-from City"; "Buy-from City")
                    {
                        ApplicationArea = FOODBasic;
                        Visible = false;
                    }
                    field("Buy-from Country/Region Code"; "Buy-from Country/Region Code")
                    {
                        ApplicationArea = FOODBasic;
                        Visible = false;
                    }
                    field("Buy-from Contact"; "Buy-from Contact")
                    {
                        ApplicationArea = FOODBasic;
                        Visible = false;
                    }
                    field("Order Date"; "Order Date")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Expected Receipt Date"; "Expected Receipt Date")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Shipment Method Code"; "Shipment Method Code")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Location Code"; "Location Code")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Purchaser Code"; "Purchaser Code")
                    {
                        ApplicationArea = FOODBasic;
                        Visible = false;
                    }
                    field(Amount; Amount)
                    {
                        ApplicationArea = FOODBasic;
                        Visible = false;
                    }
                    field("Amount Including VAT"; "Amount Including VAT")
                    {
                        ApplicationArea = FOODBasic;
                        Visible = false;
                    }
                    field("Lines to Receive"; "Lines to Receive")
                    {
                        ApplicationArea = FOODBasic;
                    }
                }
            }
            part(PurchLines; "Truckload Recv. Lines Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Purchase Order Lines';
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("No.");
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("O&rder")
            {
                Caption = 'O&rder';
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Ellipsis = true;
                    Image = Card;
                    RunObject = Page "Purchase Order";
                    RunPageLink = "No." = FIELD("No.");
                    ShortCutKey = 'Shift+F7';
                }
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Purch. Comment Sheet";
                    RunPageLink = "Document Type" = FIELD("Document Type"),
                                  "No." = FIELD("No.");
                }
                action(Dimensions)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Dimensions';
                    Image = Dimensions;

                    trigger OnAction()
                    begin
                        ShowDocDim;          // P8001133
                        CurrPage.SaveRecord; // P8001133
                    end;
                }
                action("E&xtra Charges")
                {
                    ApplicationArea = FOODBasic;
                    AccessByPermission = TableData "Extra Charge" = R;
                    Caption = 'E&xtra Charges';
                    Image = Costs;

                    trigger OnAction()
                    var
                        DocExtraCharge: Record "Document Extra Charge";
                        Extracharges: Page "Document Header Extra Charges";
                    begin
                        DocExtraCharge.Reset;
                        DocExtraCharge.SetRange("Table ID", DATABASE::"Purchase Header"); // P8000928, P8001032
                        DocExtraCharge.SetRange("Document Type", "Document Type");
                        DocExtraCharge.SetRange("Document No.", "No.");
                        Extracharges.SetTableView(DocExtraCharge);
                        Extracharges.RunModal;
                    end;
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("Allocate Charges")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Allocate Charges';
                    Image = Payment;

                    trigger OnAction()
                    begin
                        AllocateCharges;
                    end;
                }
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                action("P&ost Marked Orders")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'P&ost Marked Orders';
                    Ellipsis = true;
                    Image = PostedOrder;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    begin
                        PostOrders(false);
                    end;
                }
                action("Post and &Print Marked Orders")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Post and &Print Marked Orders';
                    Ellipsis = true;
                    Image = PostPrint;
                    ShortCutKey = 'Shift+F9';

                    trigger OnAction()
                    begin
                        PostOrders(true);
                    end;
                }
            }
            action("Print Labels")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Print Labels';
                Ellipsis = true;
                Image = Print;

                trigger OnAction()
                var
                    PurchHeader: Record "Purchase Header";
                    LabelWorksheetLine: Record "Label Worksheet Line" temporary;
                    ReceivingLabelMgmt: Codeunit "Label Worksheet Management";
                begin
                    // P8001047
                    PurchHeader.Copy(Rec);
                    PurchHeader.MarkedOnly(true);
                    ReceivingLabelMgmt.WorksheetLinesForPurchHdr(PurchHeader, LabelWorksheetLine);
                    ReceivingLabelMgmt.RunWorksheet(LabelWorksheetLine);
                end;
            }
            action("Show Marked Orders")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Show Marked Orders';
                Image = "Order";

                trigger OnAction()
                var
                    lrePurchHeader: Record "Purchase Header";
                begin
                    MarkedOnly(true);
                    Error(''); // P80073466
                end;
            }
            action("Reset Selection")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Reset Selection';
                Image = ClearFilter;

                trigger OnAction()
                begin
                    ClearMarks();
                    MarkedOnly(false);
                end;
            }
            action("Mark Record")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Mark Record';
                Image = MakeOrder;
                ShortCutKey = 'Ctrl+F3';

                trigger OnAction()
                var
                    CurrentRecord: Record "Purchase Header";
                    PurchHeader: Record "Purchase Header";
                    SetMark: Boolean;
                begin
                    CurrentRecord := Rec;
                    CurrPage.SetSelectionFilter(PurchHeader);
                    if PurchHeader.FindSet then
                        repeat
                            Get(PurchHeader."Document Type", PurchHeader."No.");
                            SetMark := not Mark;
                        until (PurchHeader.Next = 0) or SetMark;

                    if PurchHeader.FindSet then
                        repeat
                            Get(PurchHeader."Document Type", PurchHeader."No.");
                            Mark(SetMark);
                        until PurchHeader.Next = 0;

                    Rec := CurrentRecord;
                    //MARK(NOT MARK);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Post)
            {
                Caption = 'Post';
                ShowAs = SplitButton;

                actionref(PostMarkedOrders_Promoted; "P&ost Marked Orders")
                {
                }
                actionref(PostAndPrintMarkedOrders_Promoted; "Post and &Print Marked Orders")
                {
                }
            }
            group(Category_Mark)
            {
                Caption = 'Mark';
                ShowAs = SplitButton;

                actionref(MarkRecord_Promoted; "Mark Record")
                {
                }
                actionref(ShowMarkedOrders_Promoted; "Show Marked Orders")
                {
                }
                actionref(ResetSelection_Promoted; "Reset Selection")
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IsMarked := (Mark = true); //P8000752
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        OrderNoFilter := GetFilter("No.");
        VendNoFilter := GetFilter("Buy-from Vendor No.");
        VendNameFilter := GetFilter("Buy-from Vendor Name");
        RcptDateFilter := GetFilter("Expected Receipt Date");
        VendShipNoFilter := GetFilter("Vendor Shipment No.");
        PickupLoadNoFilter := GetFilter("Pickup Load No."); // P8000080A

        exit(Find(Which));
    end;

    trigger OnOpenPage()
    var
        i: Integer;
    begin
        // P8001259
        PurchSetup.Get;
        ShortcutECCode[1] := PurchSetup."Shortcut Extra Charge 1 Code";
        ShortcutECCode[2] := PurchSetup."Shortcut Extra Charge 2 Code";
        ShortcutECCode[3] := PurchSetup."Shortcut Extra Charge 3 Code";
        ShortcutECCode[4] := PurchSetup."Shortcut Extra Charge 4 Code";
        ShortcutECCode[5] := PurchSetup."Shortcut Extra Charge 5 Code";

        ShortcutECVisible[1] := ShortcutECCode[1] <> ''; // P8001333

        ShowExtraCharge1 := ShortcutECVisible[1];
        // P8001259

        Clear(ShortcutECVendor); // P8001333
        Clear(ShortcutECCharge); // P8001333
    end;

    var
        RecvInfo: Record "Purchase Header";
        PurchSetup: Record "Purchases & Payables Setup";
        ReleasePurchDoc: Codeunit "Release Purchase Document";
        ExtraChargeMgmt: Codeunit "Extra Charge Management";
        OrderNoFilter: Code[50];
        RcptDateFilter: Text[50];
        VendNoFilter: Code[50];
        VendNameFilter: Text[100];
        Text000: Label 'Do you want to post the marked orders?';
        VendShipNoFilter: Code[50];
        PickupLoadNoFilter: Code[50];
        ShortcutECCode: array[5] of Code[10];
        ShortcutECCharge: array[5] of Decimal;
        ShortcutECVendor: array[5] of Code[20];
        Text001: Label 'No orders have been marked.';
        Text002: Label '%1 out of %2 orders have been posted.';
        ShortcutECVisible: array[5] of Boolean;
        Text003: Label 'Posting order  #1##########';
        [InDataSet]
        ShowExtraCharge1: Boolean;
        IsMarked: Boolean;
        Text004: Label 'Purchase %1 %2';

    procedure AllocateCharges()
    var
        GLSetup: Record "General Ledger Setup";
        PurchHeader: Record "Purchase Header";
        ExtraCharge: Record "Extra Charge";
        DocExtraCharge: Record "Document Extra Charge";
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        ExtraChargeMgmt: Codeunit "Extra Charge Management";
        i: Integer;
        RemainingCharge: array[5] of Decimal;
        LineTotals: array[4] of Decimal;
        LoadTotals: array[4] of Decimal;
        NegLinesExist: Boolean;
    begin
        PurchHeader.Copy(Rec);
        PurchHeader.MarkedOnly(true);
        if not PurchHeader.Find('-') then
            Error(Text001);

        GLSetup.Get;
        // P8001259
        //PurchSetup.GET;
        //ShortcutECCode[1] := PurchSetup."Shortcut Extra Charge 1 Code";
        //ShortcutECCode[2] := PurchSetup."Shortcut Extra Charge 2 Code";
        //ShortcutECCode[3] := PurchSetup."Shortcut Extra Charge 3 Code";
        //ShortcutECCode[4] := PurchSetup."Shortcut Extra Charge 4 Code";
        //ShortcutECCode[5] := PurchSetup."Shortcut Extra Charge 5 Code";
        // P8001259

        for i := 1 to ArrayLen(ShortcutECCode) do
            if ShortcutECVisible[i] then begin
                RemainingCharge[i] := ShortcutECCharge[i];
                ExtraCharge.Get(ShortcutECCode[i]);
                ExtraCharge.Mark(true)
            end;

        ExtraCharge.SetFilter("Allocation Method", '>0');
        ExtraCharge.MarkedOnly(true);
        if not ExtraCharge.Find('-') then
            exit;

        repeat
            // P8000487A
            if PurchHeader."Currency Code" <> '' then
                Currency.Get(PurchHeader."Currency Code")
            else begin
                Clear(Currency);
                Currency.InitRoundingPrecision;
            end;
            // P8000487A
            ExtraChargeMgmt.GetPurchaseLineTotals(PurchHeader."Document Type", PurchHeader."No.", LineTotals, NegLinesExist); // P8000988
            LineTotals[1] := ExtraChargeMgmt.FCYtoLCY(LineTotals[1], WorkDate, Currency, PurchHeader."Currency Factor"); // P8000487A
            for i := 1 to ArrayLen(LineTotals) do
                LoadTotals[i] += LineTotals[i];
        until PurchHeader.Next = 0;

        PurchHeader.Find('-');
        repeat
            // P8000487A
            if PurchHeader."Currency Code" <> '' then
                Currency.Get(PurchHeader."Currency Code")
            else begin
                Clear(Currency);
                Currency.InitRoundingPrecision;
            end;
            // P8000487A
            ExtraChargeMgmt.GetPurchaseLineTotals(PurchHeader."Document Type", PurchHeader."No.", LineTotals, NegLinesExist); // P8000988
            LineTotals[1] := ExtraChargeMgmt.FCYtoLCY(LineTotals[1], WorkDate, Currency, PurchHeader."Currency Factor"); // P8000487A
            ExtraCharge.Find('-');
            repeat
                i := 1;
                while ExtraCharge.Code <> ShortcutECCode[i] do
                    i += 1;
                if not DocExtraCharge.Get(DATABASE::"Purchase Header", // P8001032
                    PurchHeader."Document Type", PurchHeader."No.", 0, ExtraCharge.Code) then begin // P8000928
                    DocExtraCharge."Table ID" := DATABASE::"Purchase Header"; // P8000928, P8001032
                    DocExtraCharge."Document Type" := PurchHeader."Document Type";
                    DocExtraCharge."Document No." := PurchHeader."No.";
                    DocExtraCharge."Line No." := 0;
                    DocExtraCharge.Validate("Extra Charge Code", ExtraCharge.Code); // P8000487A
                    DocExtraCharge.Insert;
                end;
                DocExtraCharge.Validate("Vendor No.", ShortcutECVendor[i]); // P8001333
                if LoadTotals[ExtraCharge."Allocation Method"] <> 0 then
                    DocExtraCharge.Charge := Round( // P8000487A
                      RemainingCharge[i] * LineTotals[ExtraCharge."Allocation Method"] / LoadTotals[ExtraCharge."Allocation Method"],
                      GLSetup."Amount Rounding Precision")
                else
                    DocExtraCharge.Charge := 0; // P8000487A
                DocExtraCharge.Validate(Charge); // P8000487A
                RemainingCharge[i] -= DocExtraCharge.Charge; // P8000487A
                if DocExtraCharge.Charge <> 0 then begin // P8000487A
                                                         /*P8000487A
                                                         IF PurchHeader."Currency Code" <> '' THEN BEGIN
                                                           Currency.GET(PurchHeader."Currency Code");
                                                           Currency.TESTFIELD("Amount Rounding Precision");
                                                           DocExtraCharge."Charge (LCY)" :=
                                                             ROUND(
                                                               CurrExchRate.ExchangeAmtLCYToFCY(WORKDATE,PurchHeader."Currency Code",
                                                               DocExtraCharge."Charge (LCY)",PurchHeader."Currency Factor"),
                                                               Currency."Amount Rounding Precision");
                                                         END;
                                                         P8000487A*/
                                                         //DocExtraCharge."Vendor No." := ShortcutECVendor[i];                    // P8000487A
                                                         //DocExtraCharge."Allocation Method" := ExtraCharge."Allocation Method"; // P8000487A
                    DocExtraCharge.Modify;
                end else
                    DocExtraCharge.Delete;
            until ExtraCharge.Next = 0;
            for i := 1 to ArrayLen(LineTotals) do
                LoadTotals[i] -= LineTotals[i];
            ExtraChargeMgmt.AllocateChargesToLines(DATABASE::"Purchase Header", // P8001032
              PurchHeader."Document Type", PurchHeader."No.", PurchHeader."Currency Code", ExtraCharge) // P8000928
        until PurchHeader.Next = 0;

    end;

    procedure PostOrders(PrintReceipts: Boolean)
    var
        PurchHeader: Record "Purchase Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        ReportSelection: Record "Report Selections";
        ExtraChargePO: Record "Extra Charge";
        ExtraChargeLoad: Record "Extra Charge";
        PickupLoad: Record "Pickup Load Header";
        PickupLoadLine: Record "Pickup Load Line";
        TempErrorMessage: Record "Error Message" temporary;
        PurchPost: Codeunit "Purch.-Post";
        cnt: array[2] of Integer;
        i: Integer;
        Window: Dialog;
        BatchConfirm: Option;
    begin
        PurchHeader.Copy(Rec);
        PurchHeader.MarkedOnly(true);
        cnt[1] := PurchHeader.Count;
        if cnt[1] = 0 then
            Error(Text001);

        if not Confirm(Text000, false) then
            exit;

        Window.Open(Text003); // P8000080A

        ReportSelection.Reset;
        ReportSelection.SetRange(Usage, ReportSelection.Usage::"P.Receipt");
        ReportSelection.SetFilter("Report ID", '<>0');

        // P8001259
        //PurchSetup.GET;
        //ShortcutECCode[1] := PurchSetup."Shortcut Extra Charge 1 Code";
        //ShortcutECCode[2] := PurchSetup."Shortcut Extra Charge 2 Code";
        //ShortcutECCode[3] := PurchSetup."Shortcut Extra Charge 3 Code";
        //ShortcutECCode[4] := PurchSetup."Shortcut Extra Charge 4 Code";
        //ShortcutECCode[5] := PurchSetup."Shortcut Extra Charge 5 Code";
        // P8001259

        if ExtraChargePO.Find('-') then
            repeat
                ExtraChargePO.Mark(true);
            until ExtraChargePO.Next = 0;
        for i := 1 to ArrayLen(ShortcutECCode) do
            if ShortcutECVisible[i] then begin
                ExtraChargeLoad.Get(ShortcutECCode[i]);
                ExtraChargeLoad.Mark(true);
                ExtraChargePO.Get(ShortcutECCode[i]);
                ExtraChargePO.Mark(false);
            end;
        ExtraChargeLoad.MarkedOnly(true);
        ExtraChargePO.MarkedOnly(true);

        // P8000080A Begin
        // In order to complete a pickup load, the pickup load filter must be set to exactly one load
        if PickupLoadNoFilter <> '' then begin
            PickupLoad.SetFilter("No.", PickupLoadNoFilter);
            if PickupLoad.Find('-') then begin
                if PickupLoad.Next <> 0 then
                    Clear(PickupLoad);
            end;
        end;
        // P8000080A End

        PurchHeader.Find('-');
        repeat
            Window.Update(1, PurchHeader."No.");

            PurchHeader.Receive := true;
            PurchHeader.Invoice := false;
            if PurchHeader."Vendor Shipment No." = '' then
                PurchHeader."Vendor Shipment No." := RecvInfo."Vendor Shipment No.";
            PurchHeader."Received By" := RecvInfo."Received By";
            PurchHeader."Checked By" := RecvInfo."Checked By";
            PurchHeader."Recorder Unit No." := RecvInfo."Recorder Unit No.";
            PurchHeader."High Temperature" := RecvInfo."High Temperature";
            PurchHeader."Low Temperature" := RecvInfo."Low Temperature";
            Clear(PurchPost);
            PurchHeader.BatchConfirmUpdateDeferralDate(BatchConfirm, true, WorkDate); // P80053245
            PurchPost.SetPickupLoad(PickupLoad."No."); // P8000080A
            if PurchPost.Run(PurchHeader) then begin
                cnt[2] += 1;
                Rec.Get(PurchHeader."Document Type", PurchHeader."No.");
                Rec.Mark(false);

                ExtraChargeMgmt.UpdatePurchaseVendorBuffer(PurchHeader);
                ExtraChargeMgmt.CreateVendorInvoices(ExtraChargePO);

                // P8000080A Begin
                if PickupLoad."No." <> '' then
                    if PickupLoadLine.Get(PickupLoad."No.", PurchHeader."No.") then begin
                        PickupLoadLine."Purchase Receipt No." := PurchHeader."Last Receiving No.";
                        PickupLoadLine.Modify;
                    end;
                // P8000080A End
                Commit;

                if PrintReceipts then begin
                    PurchRcptHeader."No." := PurchHeader."Last Receiving No.";
                    PurchRcptHeader.SetRecFilter;
                    if ReportSelection.Find('-') then
                        repeat
                            REPORT.Run(ReportSelection."Report ID", false, false, PurchRcptHeader);
                        until ReportSelection.Next = 0;
                end;

            end else
                // P80053245
                TempErrorMessage.LogDetailedMessage(PurchHeader, 0, TempErrorMessage."Message Type"::Error, GetLastErrorText,
              StrSubstNo(Text004, PurchHeader."Document Type", PurchHeader."No."), '');
        // P80053245

        until PurchHeader.Next = 0;

        ExtraChargeMgmt.CreateVendorInvoices(ExtraChargeLoad);
        Clear(ExtraChargeMgmt);

        if (PickupLoad."No." <> '') and (cnt[2] = cnt[1]) then // P8000080A  // P80073464
            PickupLoad.Complete;         // P8000080A

        Window.Close;

        Message(Text002, cnt[2], cnt[1]);
        // P8001275
        if cnt[2] < cnt[1] then begin
            Commit;
            TempErrorMessage.ShowErrorMessages(false); // P80053245
        end;
        // P8001275

        Clear(RecvInfo);
        Clear(ShortcutECCharge);
        Clear(ShortcutECVendor);
        CurrPage.Update(false); // P8000510A
    end;

    local procedure OrderNoFilterOnAfterValidate()
    begin
        if OrderNoFilter = '' then
            SetRange("No.")
        else
            SetFilter("No.", OrderNoFilter);
        CurrPage.Update;
    end;

    local procedure VendNoFilterOnAfterValidate()
    begin
        if VendNoFilter = '' then
            SetRange("Buy-from Vendor No.")
        else
            SetFilter("Buy-from Vendor No.", VendNoFilter);
        CurrPage.Update;
    end;

    local procedure VendNameFilterOnAfterValidate()
    begin
        if VendNameFilter = '' then
            SetRange("Buy-from Vendor Name")
        else
            SetFilter("Buy-from Vendor Name", VendNameFilter);
        CurrPage.Update;
    end;

    local procedure RcptDateFilterOnAfterValidate()
    var
        FilterTokens: Codeunit "Filter Tokens";
    begin
        FilterTokens.MakeDateFilter(RcptDateFilter); // P8000950, P80066030, P800-MegaApp
        if RcptDateFilter = '' then
            SetRange("Expected Receipt Date")
        else
            SetFilter("Expected Receipt Date", RcptDateFilter);
        CurrPage.Update;
    end;

    local procedure VendShipNoFilterOnAfterValidat()
    begin
        if VendShipNoFilter = '' then
            SetRange("Vendor Shipment No.")
        else
            SetFilter("Vendor Shipment No.", VendShipNoFilter);
        CurrPage.Update;
    end;

    local procedure PickupLoadNoFilterOnAfterValid()
    begin
        // P8000080A
        if PickupLoadNoFilter = '' then
            SetRange("Pickup Load No.")
        else
            SetFilter("Pickup Load No.", PickupLoadNoFilter);
        CurrPage.Update;
    end;
}
