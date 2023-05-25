page 5784 "Filters to Get Source Docs."
{
    // PRW19.00.01
    // P8006916, To-Increase, Jack Reynolds, 31 AUG 16
    //   FOOD-TOM Separation
    // 
    // P8008014, To-Increase, Jack Reynolds, 17 NOV 16
    //   Problem with containers assigned to inbound transfers
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // P80050544, To-Increase, Dayakar Battini, 12 FEB 18
    //   Upgrade to 2017 CU13
    //
    // PRW120.4
    // P800158446, To-Increase, Gangabhushan, 20 OCT 22
    //   CS00222757 | Warehouse shipment - Use filters to get source docs is not working properly

    Caption = 'Filters to Get Source Docs.';
    PageType = Worksheet;
    RefreshOnActivate = true;
    SourceTable = "Warehouse Source Filter";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(ShowRequestForm; ShowRequestForm)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Show Filter Request';
                    ToolTip = 'Specifies if the Filters to Get Source Docs. window appears when you choose Use Filters to Get Source Docs on a warehouse shipment or warehouse receipt document.';
                }
                field("Do Not Fill Qty. to Handle"; Rec."Do Not Fill Qty. to Handle")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies that inventory quantities are assigned when you get outbound source document lines for shipment.';
                }
            }
            repeater(Control1)
            {
                Editable = true;
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the code that identifies the filter record.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the description of filter combinations in the Source Document Filter Card window to retrieve lines from source documents.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Run)
            {
                ApplicationArea = Warehouse;
                Caption = '&Run';
                Image = Start;
                ToolTip = 'Get the specified source documents.';

                trigger OnAction()
                var
                    GetSourceBatch: Report "Get Source Documents";
                    EventSubscribersWhse: Codeunit "Event Subscribers (Whse)"; // P800158446
                begin
                    case RequestType of
                        RequestType::Receive:
                            begin
                                GetSourceBatch.SetOneCreatedReceiptHeader(WhseReceiptHeader);
                                Rec.SetFilters(GetSourceBatch, WhseReceiptHeader."Location Code"); //N138F0000, P800158446
                            end;
                        RequestType::Ship:
                            begin
                                GetSourceBatch.SetOneCreatedShptHeader(WhseShptHeader);
                                EventSubscribersWhse.SetDelTripFilter(WhseShptHeader."Delivery Trip"); // P800158446
                                Rec.SetFilters(GetSourceBatch, WhseShptHeader."Location Code"); //N138F0000, P800158446
                                GetSourceBatch.SetSkipBlocked(true);
                            end;
                    end;

                    GetSourceBatch.SetSkipBlockedItem(true);
                    GetSourceBatch.SetAssignContainers; // P8008014
                    GetSourceBatch.UseRequestPage(ShowRequestForm);
                    GetSourceBatch.RunModal();
                    //N138F0000.sn
                    if GetSourceBatch.NotCancelled() then
                        DeliveryTripMgt.LinkDeliveryTripWhseShipment(Rec, WhseShptHeader);
                    //N138F0000.en
                    if GetSourceBatch.NotCancelled then
                        CurrPage.Close();
                end;
            }
            action("&Run and Select")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Run and Select';
                Image = Start;

                trigger OnAction()
                var
                    GetSourceBatch: Report "Get Source Documents";
                    WhseShipmentLine: Record "Warehouse Shipment Line" temporary;
                    WhseShipmentLine2: Record "Warehouse Shipment Line" temporary;
                    WhseShipmentLine3: Record "Warehouse Shipment Line";
                    WhseShipmentLinesTemporary: Page "Whse. Shipment Lines Temporary"; // P800158446
                    LineNo: Integer;
                    Text000: Label 'Not Implemented';
                    EventSubscribersWhse: Codeunit "Event Subscribers (Whse)"; // P800158446
                begin
                    //N138F0000.sn
                    case RequestType of
                        RequestType::Receive:
                            begin
                                Error(Text000);
                            end;
                        RequestType::Ship:
                            begin
                                GetSourceBatch.SetOneCreatedShptHeader(WhseShptHeader);
                                EventSubscribersWhse.SetDelTripFilter(WhseShptHeader."Delivery Trip"); // P800158446
                                Rec.SetFilters(GetSourceBatch, WhseShptHeader."Location Code"); //N138F0000 ,P800158446
                                GetSourceBatch.SetSkipBlocked(true);
                                GetSourceBatch.SetUserInteraction;
                            end;
                    end;

                    GetSourceBatch.UseRequestPage(ShowRequestForm);
                    GetSourceBatch.RunModal;
                    GetSourceBatch.GetShipmentLines(WhseShipmentLine);
                    // P800158446
                    WhseShipmentLinesTemporary.LookupMode(true);
                    WhseShipmentLinesTemporary.SetSource(WhseShipmentLine);
                    if WhseShipmentLinesTemporary.RunModal = ACTION::LookupOK then begin
                        WhseShipmentLinesTemporary.GetSource(WhseShipmentLine2);
                        // P800158446
                        if WhseShipmentLine2.FindSet then begin
                            WhseShipmentLine3.SetRange("No.", WhseShptHeader."No.");
                            if WhseShipmentLine3.FindLast then
                                LineNo := WhseShipmentLine3."Line No.";

                            WhseShipmentLine3.Reset;
                            repeat
                                WhseShipmentLine3 := WhseShipmentLine2;
                                LineNo += 10000;
                                WhseShipmentLine3."Line No." := LineNo;
                                WhseShipmentLine3.Insert;
                            until WhseShipmentLine2.Next = 0;
                            WhseShptHeader.SortWhseDoc;
                        end;
                    end;

                    if GetSourceBatch.NotCancelled then begin
                        DeliveryTripMgt.LinkDeliveryTripWhseShipment(Rec, WhseShptHeader);
                        CurrPage.Close;
                    end;
                    //N138F0000.en
                end;
            }
            action(Modify)
            {
                ApplicationArea = Warehouse;
                Caption = '&Modify';
                Image = EditFilter;
                ToolTip = 'Change the type of source documents that the function looks in.';

                trigger OnAction()
                var
                    SourceDocFilterCard: Page "Source Document Filter Card";
                begin
                    TestField(Code);
                    case RequestType of
                        RequestType::Receive:
                            SourceDocFilterCard.SetOneCreatedReceiptHeader(WhseReceiptHeader);
                        RequestType::Ship:
                            SourceDocFilterCard.SetOneCreatedShptHeader(WhseShptHeader);
                    end;
                    SourceDocFilterCard.SetRecord(Rec);
                    SourceDocFilterCard.SetTableView(Rec);
                    SourceDocFilterCard.RunModal();
                    CurrPage.Close();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(Run_Promoted; Run)
                {
                }
                actionref(RunAndSelect_Promoted; "&Run and Select")
                {
                }
                actionref(Modify_Promoted; Modify)
                {
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        ShowRequestForm := "Show Filter Request";
    end;

    trigger OnOpenPage()
    begin
        DataCaption := CurrPage.Caption;
        FilterGroup := 2;
        if GetFilter(Type) <> '' then
            DataCaption := DataCaption + ' - ' + GetFilter(Type);
        FilterGroup := 0;
        CurrPage.Caption(DataCaption);
    end;

    var
        WhseReceiptHeader: Record "Warehouse Receipt Header";
        DataCaption: Text[250];
        ShowRequestForm: Boolean;
        DeliveryTripMgt: Codeunit "N138 Delivery Trip Mgt.";

    protected var
        WhseShptHeader: Record "Warehouse Shipment Header";
        RequestType: Option Receive,Ship;

    procedure SetOneCreatedShptHeader(WhseShptHeader2: Record "Warehouse Shipment Header")
    begin
        RequestType := RequestType::Ship;
        WhseShptHeader := WhseShptHeader2;
    end;

    procedure SetOneCreatedReceiptHeader(WhseReceiptHeader2: Record "Warehouse Receipt Header")
    begin
        RequestType := RequestType::Receive;
        WhseReceiptHeader := WhseReceiptHeader2;
    end;
}

