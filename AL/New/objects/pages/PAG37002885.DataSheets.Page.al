page 37002885 "Data Sheets"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 16 NOV 15
    //   Page Management; Cleanup action names

    Caption = 'Data Sheets';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Data Sheet Header";

    layout
    {
        area(content)
        {
            field(PageCaption; PageCaption)
            {
                ApplicationArea = FOODBasic;
                Editable = false;
                ShowCaption = false;
                Style = Strong;
                StyleExpr = TRUE;
            }
            repeater(Group)
            {
                FreezeColumn = Status;
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Start Date"; "Start Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Start Time"; "Start Time")
                {
                    ApplicationArea = FOODBasic;
                }
                field("End Date"; "End Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("End Time"; "End Time")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control37002011; Links)
            {
                ApplicationArea = FOODBasic;
            }
            systempart(Control37002012; Notes)
            {
                ApplicationArea = FOODBasic;
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Create Data Sheets")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Create Data Sheets';
                Ellipsis = true;
                Enabled = CreateEnabled;
                Image = NewSparkle;

                trigger OnAction()
                var
                    LogGroup: Record "Data Collection Log Group";
                    SalesHeader: Record "Sales Header";
                    PurchHeader: Record "Purchase Header";
                    TransHeader: Record "Transfer Header";
                    ProdOrder: Record "Production Order";
                    DataCollectionMgmt: Codeunit "Data Collection Management";
                    ShipReceive: Integer;
                begin
                    FilterGroup(9);
                    if GetFilter("Source ID") <> '' then begin
                        case GetRangeMax("Source ID") of
                            0:
                                begin
                                    LogGroup.Get(GetRangeMax("Source No."));
                                    DataCollectionMgmt.CreateSheetForLogGroup(LogGroup);
                                end;
                            DATABASE::"Sales Header":
                                begin
                                    SalesHeader.Get(GetRangeMax("Source Subtype"), GetRangeMax("Source No."));
                                    DataCollectionMgmt.CreateSheetForSalesHeader(SalesHeader, false);
                                end;
                            DATABASE::"Purchase Header":
                                begin
                                    PurchHeader.Get(GetRangeMax("Source Subtype"), GetRangeMax("Source No."));
                                    DataCollectionMgmt.CreateSheetForPurchHeader(PurchHeader, false);
                                end;
                            DATABASE::"Transfer Header":
                                begin
                                    ShipReceive := StrMenu(Text010);
                                    if ShipReceive = 0 then begin
                                        FilterGroup(0);
                                        exit;
                                    end;
                                    TransHeader.Get(GetRangeMax("Source No."));
                                    DataCollectionMgmt.CreateSheetForTransHeader(TransHeader, ShipReceive - 1, false, '');
                                end;
                            DATABASE::"Production Order":
                                begin
                                    ProdOrder.Get(GetRangeMax("Source Subtype"), GetRangeMax("Source No."));
                                    DataCollectionMgmt.CreateSheetForProdOrder(ProdOrder, false);
                                end;
                        end;
                    end;
                    FilterGroup(0);

                    if Find('=<>') then;
                end;
            }
        }
        area(processing)
        {
            action("Data Sheet")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Data Sheet';
                Image = EntriesList;
                ShortCutKey = 'Return';

                trigger OnAction()
                var
                    PageManagement: Codeunit "Page Management";
                begin
                    PageManagement.PageRun(Rec);
                end;
            }
            action(Alerts)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Alerts';
                Image = Alerts;
                RunObject = Page "Data Collection Alerts";
                RunPageLink = "Data Sheet No." = FIELD("No.");
                RunPageView = SORTING("Data Sheet No.", "Prod. Order Line No.", "Data Element Code", "Line No.", "Source ID", "Source Key 1", "Source Key 2", "Instance No.");
            }
            action(Print)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Print';
                Enabled = PrintEnabled;
                Image = Print;

                trigger OnAction()
                begin
                    PrintDataSheet;
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(CreateDataSheets_Promoted; "Create Data Sheets")
                {
                }
                actionref(DataSheet_Promoted; "Data Sheet")
                {
                }
                actionref(Alerts_Promoted; Alerts)
                {
                }
                actionref(Print_Promoted; Print)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        PrintEnabled := Status = Status::Complete;
    end;

    trigger OnOpenPage()
    begin
        FilterGroup(9);
        CreateEnabled := GetFilter("Source ID") <> '';
        FilterGroup(0);

        PageCaption := SetCaption;
    end;

    var
        Text001: Label 'Sales';
        Text002: Label 'Purchase';
        PageCaption: Text[100];
        [InDataSet]
        CreateEnabled: Boolean;
        Text003: Label 'Sales Shipment %1';
        Text004: Label 'Return Receipt %1';
        Text005: Label 'Purchase Receipt %1';
        Text006: Label 'Return Shipment %1';
        Text007: Label 'Transfer Order %1';
        Text008: Label 'Transfer Shipment %1';
        Text009: Label 'Transfer Receipt %1';
        Text010: Label 'Ship,Receive';
        Text011: Label 'Log Group %1';
        [InDataSet]
        PrintEnabled: Boolean;

    procedure SetCaption(): Text[100]
    var
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        ProdOrder: Record "Production Order";
    begin
        FilterGroup(9);
        if GetFilter("Source ID") <> '' then begin
            case GetRangeMax("Source ID") of
                0:
                    exit(StrSubstNo(Text011, GetRangeMax("Source No.")));
                DATABASE::"Sales Header":
                    begin
                        SalesHeader."Document Type" := GetRangeMax("Source Subtype");
                        exit(StrSubstNo('%1 %2 %3',
                          Text001, SalesHeader."Document Type", GetRangeMax("Source No.")));
                    end;
                DATABASE::"Purchase Header":
                    begin
                        PurchHeader."Document Type" := GetRangeMax("Source Subtype");
                        exit(StrSubstNo('%1 %2 %3',
                          Text002, PurchHeader."Document Type", GetRangeMax("Source No.")));
                    end;
                DATABASE::"Transfer Header":
                    exit(StrSubstNo(Text007, GetRangeMax("Source No.")));
                DATABASE::"Production Order":
                    exit(StrSubstNo('%1 %2', ProdOrder.TableCaption, GetRangeMax("Source No.")));
            end;
        end else
            if GetFilter("Document Type") <> '' then begin
                case GetRangeMax("Document Type") of
                    DATABASE::"Sales Shipment Header":
                        exit(StrSubstNo(Text003, GetRangeMax("Document No.")));
                    DATABASE::"Return Receipt Header":
                        exit(StrSubstNo(Text004, GetRangeMax("Document No.")));
                    DATABASE::"Purch. Rcpt. Header":
                        exit(StrSubstNo(Text005, GetRangeMax("Document No.")));
                    DATABASE::"Return Shipment Header":
                        exit(StrSubstNo(Text006, GetRangeMax("Document No.")));
                    DATABASE::"Transfer Shipment Header":
                        exit(StrSubstNo(Text008, GetRangeMax("Document No.")));
                    DATABASE::"Transfer Receipt Header":
                        exit(StrSubstNo(Text009, GetRangeMax("Document No.")));
                end;
            end;
        FilterGroup(0);
    end;
}

