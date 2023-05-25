page 37002107 "Order Receiving"
{
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   This is a re-working of the order receiving form to expand beyond sales orders to include all inbound receipts
    // 
    // PR5.00
    // P8000322A, VerticalSoft, Don Bresee, 15 NOV 06
    //   Change to date filter - OnAfterInput
    // 
    // PR5.00.03
    // P8000656, VerticalSoft, Jack Reynolds, 08 JAN 09
    //   Fix problem when clearing document type and destination type filters
    // 
    // PRW16.00.02
    // P8000777, VerticalSoft, Don Bresee, 24 FEB 10
    //   Changed VISIBLE so it could be handled by the form transformation tool
    //   Removed += operator, used with an option variable, causes trouble for the form transformation tool
    // 
    // P8000777, VerticalSoft, Don Bresee, 01 APR 10
    //   Remove visible varibles from list field properties
    // 
    // PRW16.00.03
    // P8000828, VerticalSoft, Don Bresee, 21 JUN 10
    //   Move DrillDown calls to the Lookup trigger - so the page will use "Edit" mode
    // 
    // PRW16.00.05
    // P8000950, Columbus IT, Jack Reynolds, 25 MAY 11
    //   More flexibilty in specifying date filters
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001034, Columbus IT, Jack Reynolds, 10 FEB 12
    //   Change codeunit for Warehouse Employee functions
    // 
    // P8001047, Columbus IT, Jack Reynolds, 30 MAR 12
    //   Receiving Labels
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW19.00.01
    // P8007791, To-Increase, Dayakar Battini, 19 SEP 16
    //  Block Deletion of Orders
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW117.3
    // P80096165, To Increase, Jack Reynolds, 02 MAR 21
    //   Upgrade to 17.3 - Options to Enums

    ApplicationArea = FOODBasic;
    Caption = 'Order Receiving';
    DeleteAllowed = false;
    PageType = Worksheet;
    SourceTable = "Warehouse Request";
    SourceTableView = SORTING(Type, "Location Code", "Completely Handled", "Document Status", "Expected Receipt Date", "Shipment Date", "Source Document", "Source No.")
                      WHERE(Type = CONST(Inbound),
                            "Source Document" = FILTER("Purchase Order" | "Sales Return Order" | "Inbound Transfer"),
                            "Document Status" = CONST(Released),
                            "Completely Handled" = CONST(false));
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(Filters)
            {
                Caption = 'Filters';
                field("LocCode[1]"; LocCode[1])
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Location Code';
                    TableRelation = Location;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(P800CoreFns.LookupEmpLocation(Text)); // P8001034
                    end;

                    trigger OnValidate()
                    begin
                        P800CoreFns.ValidateEmpLocation(LocCode[1]); // P8001034
                        SetLocation;
                        CurrPage.Update(false);
                    end;
                }
                field(ReceiptDateFilter; ReceiptDateFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Receipt Date';

                    trigger OnValidate()
                    var
                        FilterTokens: Codeunit "Filter Tokens";
                    begin
                        FilterTokens.MakeDateFilter(ReceiptDateFilter); // P8000950, P80066030, P800-MegaApp
                        if ReceiptDateFilter = '' then
                            SetRange("Expected Receipt Date")
                        else
                            SetFilter("Expected Receipt Date", ReceiptDateFilter);
                        CurrPage.Update(false);
                    end;
                }
                field(DocTypeFilter; DocTypeFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Document Type';

                    trigger OnValidate()
                    begin
                        case DocTypeFilter of
                            DocTypeFilter::" ":
                                SetRange("Source Document");
                            DocTypeFilter::"Sales Return Order":
                                SetRange("Source Document", "Source Document"::"Sales Return Order");
                            DocTypeFilter::"Purchase Order":
                                SetRange("Source Document", "Source Document"::"Purchase Order");
                            DocTypeFilter::"Inbound Transfer":
                                SetRange("Source Document", "Source Document"::"Inbound Transfer");
                        end;
                        DocTypeFilterText := GetFilter("Source Document");
                        CurrPage.Update(false);
                    end;
                }
                field(DocNoFilter; DocNoFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Document No.';

                    trigger OnValidate()
                    begin
                        if DocNoFilter = '' then
                            SetRange("Source No.")
                        else
                            SetFilter("Source No.", DocNoFilter);
                        CurrPage.Update(false);
                    end;
                }
                field(DestTypeFilter; DestTypeFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Destination Type';

                    trigger OnValidate()
                    begin
                        case DestTypeFilter of
                            DestTypeFilter::" ":
                                SetRange("Destination Type");
                            DestTypeFilter::Customer:
                                SetRange("Destination Type", "Destination Type"::Customer);
                            DestTypeFilter::Vendor:
                                SetRange("Destination Type", "Destination Type"::Vendor);
                            DestTypeFilter::Location:
                                SetRange("Destination Type", "Destination Type"::Location);
                        end;
                        DestTypeFilterText := GetFilter("Destination Type");
                        CurrPage.Update(false);
                    end;
                }
                field(DestNoFilter; DestNoFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Destination No.';

                    trigger OnValidate()
                    begin
                        if DestNoFilter = '' then
                            SetRange("Destination No.")
                        else
                            SetFilter("Destination No.", DestNoFilter);
                        CurrPage.Update(false);
                    end;
                }
            }
            repeater(Control37002000)
            {
                Editable = false;
                ShowCaption = false;
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source Document"; "Source Document")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Document Type';
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Document No.';
                }
                field("Destination Type"; "Destination Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Destination No."; "Destination No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("P800WhseMgt.WhseReqDestName(Rec)"; P800WhseMgt.WhseReqDestName(Rec))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Destination Name';
                }
                field("P800WhseMgt.WhseReqSourceDate(Rec)"; P800WhseMgt.WhseReqSourceDate(Rec))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Order Date';
                }
                field("Expected Receipt Date"; "Expected Receipt Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field(ReceiptNo; P800WhseMgt.WhseReqReceiptNo(Rec))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Receipt No.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        P800WhseMgt.WhseReqReceiptDrillDown(Rec);
                        CurrPage.Update(false);
                    end;
                }
                field(PutAwayNo; P800WhseMgt.WhseReqPickPutAwayNo(Rec))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Put-away No.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        P800WhseMgt.WhseReqPutAwayDrillDown(Rec);
                        CurrPage.Update(false);
                    end;
                }
                field("Shipment Method Code"; "Shipment Method Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
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
                action("&Card")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Card';
                    Image = Card;
                    ShortCutKey = 'Shift+F7';

                    trigger OnAction()
                    begin
                        P800WhseMgt.WhseReqShowSourceDoc(Rec);
                    end;
                }
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;

                    trigger OnAction()
                    begin
                        P800WhseMgt.WhseReqShowSourceComments(Rec);
                    end;
                }
                separator(Separator1102603041)
                {
                }
                action("&Receive")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Receive';
                    Image = Receipt;
                    ShortCutKey = 'F7';

                    trigger OnAction()
                    var
                        WhseReq: Record "Warehouse Request";
                    begin
                        CurrPage.SetSelectionFilter(WhseReq);
                        WhseReq.MarkedOnly(true);
                        if not WhseReq.Find('-') then begin
                            WhseReq.MarkedOnly(false);
                            WhseReq := Rec;
                            WhseReq.SetRecFilter;
                        end;

                        P800WhseMgt.WhseReceiveOrder(WhseReq);
                    end;
                }
            }
        }
        area(processing)
        {
            action("Reset Filters")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Reset Filters';
                Image = ClearFilter;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;

                trigger OnAction()
                begin
                    LocCode[1] := P800CoreFns.GetDefaultEmpLocation; // P8001034
                    LocCode[2] := '*';
                    ReceiptDateFilter := '';
                    DocTypeFilter := 0;
                    DocNoFilter := '';
                    DestTypeFilter := 0;
                    DestNoFilter := '';

                    DocTypeFilterText := '*';
                    DestTypeFilterText := '*';

                    SetLocation;
                    SetRange("Expected Receipt Date");
                    SetRange("Source Document");
                    SetRange("Source No.");
                    SetRange("Destination Type");
                    SetRange("Destination No.");
                    CurrPage.Update(false);
                end;
            }
            separator(Separator37002021)
            {
            }
            action("Print Labels")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Print Labels';
                Ellipsis = true;
                Image = Print;

                trigger OnAction()
                var
                    WhseRequest: Record "Warehouse Request";
                    LabelWorksheetLine: Record "Label Worksheet Line" temporary;
                    ReceivingLabelMgmt: Codeunit "Label Worksheet Management";
                begin
                    // P8001047
                    CurrPage.SetSelectionFilter(WhseRequest);
                    ReceivingLabelMgmt.WorksheetLinesForWhseReq(WhseRequest, LabelWorksheetLine);
                    ReceivingLabelMgmt.RunWorksheet(LabelWorksheetLine);
                end;
            }
        }
        area(Promoted)
        {
                actionref(PrintLabels_Promoted; "Print Labels")
                {
                }
                actionref(Card_Promoted; "&Card")
                {
                }
                actionref(Receive_Promoted; "&Receive")
                {
                }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        UpdateFilters;

        exit(Find(Which));
    end;

    trigger OnInit()
    begin
        DocTypeFilterText := '*';
        DestTypeFilterText := '*';
    end;

    trigger OnOpenPage()
    begin
        LocCode[1] := P800CoreFns.GetDefaultEmpLocation; // P8001034
        LocCode[2] := '*';

        SetLocation;
    end;

    var
        P800WhseMgt: Codeunit "Process 800 Warehouse Mgmt.";
        P800CoreFns: Codeunit "Process 800 Core Functions";
        LocCode: array[2] of Code[10];
        ReceiptDateFilter: Text[50];
        DocTypeFilter: Option ," ","Sales Return Order","Purchase Order","Inbound Transfer";
        Text001: Label '* MULTIPLE *';
        DocTypeFilterText: Text[250];
        DocNoFilter: Code[50];
        DestTypeFilter: Option ," ",Customer,Vendor,Location;
        DestTypeFilterText: Text[250];
        DestNoFilter: Code[50];

    procedure SetLocation()
    var
        Location: Record Location;
    begin
        if LocCode[1] <> LocCode[2] then begin
            FilterGroup(2);
            if LocCode[1] <> '' then begin
                SetRange("Location Code", LocCode[1]);
                Location.Get(LocCode[1]);
            end else
                SetFilter("Location Code", P800CoreFns.GetEmpLocationFilter); // P8001034
            FilterGroup(0);
            LocCode[2] := LocCode[1];
        end;
    end;

    procedure UpdateFilters()
    begin
        ReceiptDateFilter := GetFilter("Expected Receipt Date");

        if DocTypeFilterText <> GetFilter("Source Document") then begin
            DocTypeFilterText := GetFilter("Source Document");
            if DocTypeFilterText = '' then
                DocTypeFilter := 1
            else begin
                DocTypeFilter := 2;
                while (DocTypeFilterText <> Format(DocTypeFilter)) and (DocTypeFilter < 5) do
                    // DocTypeFilter += 1;              // P8000777
                    DocTypeFilter := DocTypeFilter + 1; // P8000777
            end;
            if DocTypeFilter = 5 then
                DocTypeFilter := 0;
        end;

        DocNoFilter := GetFilter("Source No.");

        if DestTypeFilterText <> GetFilter("Destination Type") then begin
            DestTypeFilterText := GetFilter("Destination Type");
            if DestTypeFilterText = '' then
                DestTypeFilter := 1
            else begin
                DestTypeFilter := 2;
                while (DestTypeFilterText <> Format(DestTypeFilter)) and (DestTypeFilter < 5) do
                    // DestTypeFilter += 1;                // P8000777
                    DestTypeFilter := DestTypeFilter + 1; // P8000777
            end;
            if DestTypeFilter = 5 then
                DestTypeFilter := 0;
        end;

        DestNoFilter := GetFilter("Destination No.");
    end;
}

