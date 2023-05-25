page 37002569 "Container Assignments"
{
    // PRW110.0.02
    // P80046533, To-Increase, Jack Reynolds, 10 OCT 17
    //   Inbound containers and shipping containers
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.01
    // P80056709, To-Increase, Jack Reynolds, 25 JUL 18
    //   Production Containers - assign container to production order
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // PRW119.03
    // P800142458, To Increase, Gangabhushan, 18 MAr 22
    //   Create warning when using Resolve Shorts before using Undo functionality.        

    AutoSplitKey = true;
    Caption = 'Container Assignments';
    DataCaptionExpression = CaptionText;
    DelayedInsert = true;
    PageType = Worksheet;
    SourceTable = "Container Assignment";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document Type (Inbound)"; "Document Type (Inbound)")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Document Type';
                    Editable = ("Warehouse Document Type" <> 0) AND ("Container ID" = '');
                    Visible = WarehouseDocumentType = 1;
                }
                field("Document Type (Outbound)"; "Document Type (Outbound)")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Document Type';
                    Editable = ("Warehouse Document Type" <> 0) AND ("Container ID" = '');
                    Visible = WarehouseDocumentType = 2;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = ("Document Type" <> 0) AND ("Container ID" = '');
                    Visible = WarehouseDocumentType <> 0;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookupDocument(Text));
                    end;
                }
                field("Container Type Code"; "Container Type Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = TypeEditable AND (NOT "Ship/Receive") AND ("Document No." <> '') AND (NOT InboundXfer);
                }
                field("License Plate"; "License Plate")
                {
                    ApplicationArea = FOODBasic;
                    Editable = (NOT "Ship/Receive") AND ("Document No." <> '') AND (NOT InboundXfer);

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookupContainer(Text));
                    end;
                }
                field(Receive; "Ship/Receive")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Receive';
                    Editable = ("Container ID" <> '') AND (RequireWarehouseDoc <> ("Warehouse Document Type" = 0));
                    Visible = ReceiveVisible;
                }
                field(Ship; "Ship/Receive")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Ship';
                    Editable = ("Container ID" <> '') AND (RequireWarehouseDoc <> ("Warehouse Document Type" = 0));
                    Visible = ShipVisible;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Container)
            {
                Caption = 'Container';
                action(NewContainer)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'New';
                    Enabled = ("Container ID" = '') AND ("Document No." <> '') AND (NOT InboundXfer);
                    Image = New;

                    trigger OnAction()
                    var
                        ContainerFns: Codeunit "Container Functions";
                        TempCopiedContainers: Record "Container Header" temporary;
                        CopyContainer: Codeunit "Copy Container";
                        Cnt: Integer;
                    begin
                        BindSubscription(CopyContainer); // P80056709
                        ContainerFns.NewContainerOnContainerAssignment(Rec);
                        // P80056709
                        UnbindSubscription(CopyContainer);
                        CopyContainer.GetCopiedContainers(TempCopiedContainers);
                        TempCopiedContainers.FindSet;
                        if TempCopiedContainers.Next <> 0 then begin
                            if Rec."Container ID" <> '' then
                                TempCopiedContainers.Next(-1);
                            repeat
                                ContainerFns.AddContainerToOrder(TempCopiedContainers.ID, "Document Type", "Document Subtype", "Document No.", "Document Line No.", "Document Ref. No.", // P80056709
                                  "Warehouse Document Type", "Warehouse Document No.", false);
                            until TempCopiedContainers.Next = 0;

                            Reset;
                            DeleteAll;
                            LoadData;
                            FindLast;
                        end;
                        // P80056709
                    end;
                }
                action(EditContainer)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Edit';
                    Enabled = "Container ID" <> '';
                    Image = Edit;

                    trigger OnAction()
                    var
                        ContainerHeader: Record "Container Header";
                        CopyContainer: Codeunit "Copy Container";
                        Container: Page Container;
                        TransactionNo: Integer;
                    begin
                        BindSubscription(CopyContainer); // P80056709

                        ContainerHeader.FilterGroup(9);
                        ContainerHeader.SetRange(ID, "Container ID");
                        ContainerHeader.FilterGroup(0);
                        ContainerHeader.FindFirst;
                        Container.SetTableView(ContainerHeader);
                        Container.SetRecord(ContainerHeader);
                        Container.RunModal;

                        if not ContainerHeader.Get("Container ID") then
                            Delete;

                        // P80056709
                        TransactionNo := "Transaction No.";

                        if CopyContainer.CopiedContainersExist then begin
                            Reset;
                            DeleteAll;
                            LoadData;
                        end;

                        "Transaction No." := TransactionNo;
                        if Find('=><') then;
                        // P80056709
                    end;
                }
            }
        }
        area(Promoted)
        {
            actionref(NewContainer_Promoted; NewContainer)
            {
            }
            actionref(EditContainer_Promoted; EditContainer)
            {
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        InboundXfer := InboundTransfer;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec := ContainerAssignment;
        if ("Document Type" = DATABASE::"Transfer Line") and ("Document Subtype" = 1) then
            Error(Text003);

        InboundXfer := InboundTransfer;
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        // P800142458
        Rec.TestField("Ship/Receive", false);
        exit(Rec.RemoveAssignment(Rec."Container ID", false));
        // P800142458
    end;

    trigger OnOpenPage()
    begin
        LoadData;
    end;

    var
        CaptionText: Text[250];
        Text001: Label 'Warehouse Shipment %1';
        Text002: Label 'Warehouse Receipt %1';
        ContainerAssignment: Record "Container Assignment";
        ContainerFns: Codeunit "Container Functions";
        RequireWarehouseDoc: Boolean;
        [InDataSet]
        TypeEditable: Boolean;
        [InDataSet]
        InboundXfer: Boolean;
        WarehouseDocumentType: Integer;
        [InDataSet]
        ReceiveVisible: Boolean;
        Text003: Label 'Containers cannot be added to inbound transfers.';
        [InDataSet]
        ShipVisible: Boolean;

    procedure LoadData()
    var
        ContainerHeader: Record "Container Header";
        TransactionNo: Integer;
    begin
        if ContainerAssignment."Warehouse Document Type" = 0 then begin
            ContainerHeader.SetRange("Document Type", ContainerAssignment."Document Type");
            ContainerHeader.SetRange("Document Subtype", ContainerAssignment."Document Subtype");
            ContainerHeader.SetRange("Document No.", ContainerAssignment."Document No.");
            ContainerHeader.SetRange("Pending Assignment", false); // P80056709
            if ContainerAssignment."Document Line No." <> 0 then
                ContainerHeader.SetRange("Document Line No.", ContainerAssignment."Document Line No.");
            if ContainerAssignment."Document Ref. No." <> 0 then
                ContainerHeader.SetRange("Document Ref. No.", ContainerAssignment."Document Ref. No.");
        end else begin
            ContainerHeader.SetRange("Whse. Document Type", ContainerAssignment."Warehouse Document Type");
            ContainerHeader.SetRange("Whse. Document No.", ContainerAssignment."Warehouse Document No.");
        end;

        if ContainerHeader.FindSet then
            repeat
                Rec := ContainerAssignment;
                TransactionNo += 10000;
                "Transaction No." := TransactionNo;
                "Container ID" := ContainerHeader.ID;
                "License Plate" := ContainerHeader."License Plate";
                "Container Type Code" := ContainerHeader."Container Type Code";
                "Ship/Receive" := ContainerHeader."Ship/Receive";
                if "Warehouse Document Type" <> 0 then begin
                    "Document Type" := ContainerHeader."Document Type";
                    "Document Subtype" := ContainerHeader."Document Subtype";
                    "Document No." := ContainerHeader."Document No.";
                end;
                SetDocumentType;
                Insert;
            until ContainerHeader.Next = 0;

        if FindFirst then;
    end;

    procedure SetSource(Type: Integer; SubType: Integer; DocNo: Code[20]; DocLineNo: Integer; DocRefNo: Integer; LocCode: Code[10]; ContainerItemNo: Code[20])
    var
        Location: Record Location;
        ContainerType: Record "Container Type";
        ContainerHeader: Record "Container Header";
    begin
        // P80056709 - Add parameter DocLineNo
        ContainerAssignment."Document Type" := Type;
        ContainerAssignment."Document Subtype" := SubType;
        ContainerAssignment."Document No." := DocNo;
        ContainerAssignment."Document Line No." := DocLineNo; // P80056709
        ContainerAssignment."Document Ref. No." := DocRefNo;  // P80056709
        ContainerAssignment.Inbound := ContainerFns.IsInboundDocument(ContainerAssignment."Document Type", ContainerAssignment."Document Subtype");
        ContainerAssignment."Location Code" := LocCode;
        if Location.Get(ContainerAssignment."Location Code") then
            RequireWarehouseDoc := (Inbound and Location."Require Receive") or ((not Inbound) and Location."Require Shipment");
        if ContainerAssignment.Inbound then                                                                    // P80039780
            ContainerAssignment."Bin Code" := ContainerFns.GetReceivingBin(ContainerAssignment."Location Code"); // P80039780

        if ContainerItemNo <> '' then begin
            ContainerType.SetRange("Container Item No.", ContainerItemNo);
            ContainerType.FindFirst;
            ContainerAssignment."Container Type Code" := ContainerType.Code;
            TypeEditable := false;
        end else
            TypeEditable := true;

        ContainerHeader."Document Type" := ContainerAssignment."Document Type";
        ContainerHeader."Document Subtype" := ContainerAssignment."Document Subtype";
        CaptionText := StrSubstNo('%1 %2', ContainerHeader.DocumentType, ContainerAssignment."Document No.");

        ReceiveVisible := ContainerAssignment.Inbound;
        ShipVisible := (not ReceiveVisible) and (Type <> DATABASE::"Prod. Order Component"); // P80056709
        WarehouseDocumentType := ContainerAssignment."Warehouse Document Type";
    end;

    procedure SetWarehouseDoc(SourceRec: Variant)
    var
        SourceRecRef: RecordRef;
        WarehouseShipment: Record "Warehouse Shipment Header";
        WarehouseReceipt: Record "Warehouse Receipt Header";
    begin
        SourceRecRef.GetTable(SourceRec);

        RequireWarehouseDoc := true;
        case SourceRecRef.Number of
            DATABASE::"Warehouse Receipt Header":
                begin
                    WarehouseReceipt := SourceRec;
                    ContainerAssignment."Warehouse Document Type" := 1;
                    ContainerAssignment."Warehouse Document No." := WarehouseReceipt."No.";
                    ContainerAssignment.Inbound := true;
                    ContainerAssignment."Location Code" := WarehouseReceipt."Location Code";
                    ContainerAssignment."Bin Code" := WarehouseReceipt."Bin Code"; // P8004339
                    CaptionText := StrSubstNo(Text002, WarehouseReceipt."No.");
                end;

            DATABASE::"Warehouse Shipment Header":
                begin
                    WarehouseShipment := SourceRec;
                    ContainerAssignment."Warehouse Document Type" := 2;
                    ContainerAssignment."Warehouse Document No." := WarehouseShipment."No.";
                    ContainerAssignment.Inbound := false;
                    ContainerAssignment."Location Code" := WarehouseShipment."Location Code";
                    ContainerAssignment."Bin Code" := WarehouseShipment."Bin Code"; // P8004339
                    CaptionText := StrSubstNo(Text001, WarehouseShipment."No.");
                end;
        end;

        TypeEditable := true;
        ReceiveVisible := ContainerAssignment.Inbound;
        ShipVisible := not ReceiveVisible;
        WarehouseDocumentType := ContainerAssignment."Warehouse Document Type";
    end;
}

