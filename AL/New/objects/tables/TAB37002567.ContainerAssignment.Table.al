table 37002567 "Container Assignment"
{
    // PRW110.0.02
    // P80046533, To-Increase, Jack Reynolds, 10 OCT 17
    //   Inbound containers and shipping containers
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

    Caption = 'Container Assignment';
    ReplicateData = false;

    fields
    {
        field(1; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
            Editable = false;
        }
        field(2; Inbound; Boolean)
        {
            Caption = 'Inbound';
            Editable = false;
        }
        field(3; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            Editable = false;
        }
        field(4; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            Editable = false;
        }
        field(11; "Warehouse Document Type"; Integer)
        {
            Caption = 'Warehouse Document Type';
            Editable = false;
        }
        field(12; "Warehouse Document No."; Code[20])
        {
            Caption = 'Warehouse Document No.';
            Editable = false;
        }
        field(21; "Document Type (Inbound)"; Option)
        {
            Caption = 'Document Type (Inbound)';
            OptionCaption = ' ,Purchase,Sales Return,Transfer';
            OptionMembers = " ",Purchase,"Sales Return",Transfer;

            trigger OnValidate()
            var
                SalesLine: Record "Sales Line";
                PurchaseLine: Record "Purchase Line";
            begin
                TestField("License Plate", '');

                case "Document Type (Inbound)" of
                    "Document Type (Inbound)"::Purchase:
                        begin
                            "Document Type" := DATABASE::"Purchase Line";
                            "Document Subtype" := PurchaseLine."Document Type"::Order;
                        end;
                    "Document Type (Inbound)"::"Sales Return":
                        begin
                            "Document Type" := DATABASE::"Sales Line";
                            "Document Subtype" := SalesLine."Document Type"::"Return Order";
                        end;
                    "Document Type (Inbound)"::Transfer:
                        begin
                            if CurrFieldNo = FieldNo("Document Type (Inbound)") then
                                Error(Text000);

                            "Document Type" := DATABASE::"Transfer Line";
                            "Document Subtype" := 1;
                        end;
                    else begin
                            "Document Type" := 0;
                            "Document Subtype" := 0;
                        end;
                end;

                if xRec."Document Type (Inbound)" <> "Document Type (Inbound)" then
                    "Document No." := '';
            end;
        }
        field(22; "Document Type (Outbound)"; Option)
        {
            Caption = 'Document Type (Outbound)';
            OptionCaption = ' ,Sales,Purchase Return,Transfer';
            OptionMembers = " ",Sales,"Purchase Return",Transfer;

            trigger OnValidate()
            var
                SalesLine: Record "Sales Line";
                PurchaseLine: Record "Purchase Line";
            begin
                TestField("License Plate", '');

                case "Document Type (Outbound)" of
                    "Document Type (Outbound)"::Sales:
                        begin
                            "Document Type" := DATABASE::"Sales Line";
                            "Document Subtype" := SalesLine."Document Type"::Order;
                        end;
                    "Document Type (Outbound)"::"Purchase Return":
                        begin
                            "Document Type" := DATABASE::"Purchase Line";
                            "Document Subtype" := PurchaseLine."Document Type"::"Return Order";
                        end;
                    "Document Type (Outbound)"::Transfer:
                        begin
                            "Document Type" := DATABASE::"Transfer Line";
                            "Document Subtype" := 0;
                        end;
                    else begin
                            "Document Type" := 0;
                            "Document Subtype" := 0;
                        end;
                end;

                if xRec."Document Type (Outbound)" <> "Document Type (Outbound)" then
                    "Document No." := '';
            end;
        }
        field(23; "Document Type"; Integer)
        {
            Caption = 'Document Type';
            Editable = false;
        }
        field(24; "Document Subtype"; Integer)
        {
            Caption = 'Document Subtype';
            Editable = false;
        }
        field(25; "Document No."; Code[20])
        {
            Caption = 'Document No.';

            trigger OnValidate()
            var
                WarehouseShipmentLine: Record "Warehouse Shipment Line";
                WarehouseReceiptLine: Record "Warehouse Receipt Line";
            begin
                TestField("License Plate", '');
                TestField("Document Type");

                if "Document No." = '' then
                    exit;

                TestField("Document Type");
                if "Document Type (Inbound)" <> 0 then begin
                    WarehouseReceiptLine.SetRange("Source Type", "Document Type");
                    WarehouseReceiptLine.SetRange("Source Subtype", "Document Subtype");
                    WarehouseReceiptLine.SetRange("Source No.", "Document No.");
                    WarehouseReceiptLine.FindFirst;
                end else
                    if "Document Type (Outbound)" <> 0 then begin
                        WarehouseShipmentLine.SetRange("Source Type", "Document Type");
                        WarehouseShipmentLine.SetRange("Source Subtype", "Document Subtype");
                        WarehouseShipmentLine.SetRange("Source No.", "Document No.");
                        WarehouseShipmentLine.FindFirst;
                    end;
            end;
        }
        field(26; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            Editable = false;
        }
        field(27; "Document Ref. No."; Integer)
        {
            Caption = 'Document Ref. No.';
            Editable = false;
        }
        field(31; "Container ID"; Code[20])
        {
            Caption = 'Container ID';
            Editable = false;
        }
        field(32; "Container Type Code"; Code[10])
        {
            Caption = 'Container Type Code';
            TableRelation = "Container Type";

            trigger OnValidate()
            begin
                TestField("Ship/Receive", false);
                TestField("Document No.");

                if xRec."Container Type Code" <> "Container Type Code" then begin
                    RemoveAssignment("Container ID", false);
                    "Container ID" := '';
                    "License Plate" := '';
                end;
            end;
        }
        field(33; "License Plate"; Code[50])
        {
            Caption = 'License Plate';

            trigger OnValidate()
            var
                ContainerHeader: Record "Container Header";
            begin
                TestField("Ship/Receive", false);
                TestField("Document No.");

                if "License Plate" <> '' then begin
                    if "Container Type Code" <> '' then
                        ContainerHeader.SetRange("Container Type Code", "Container Type Code");
                    ContainerHeader.SetRange("License Plate", "License Plate");
                    ContainerHeader.FindFirst;
                    if ContainerHeader.ID <> "Container ID" then begin       // P80056709
                        ContainerHeader.TestField("Pending Assignment", false); // P80056709
                        if ContainerHeader."Document Type" <> 0 then
                            Error(Text001, ContainerHeader.DocumentType, ContainerHeader."Document No.");
                    end;                                                     // P80056709

                    "Container ID" := ContainerHeader.ID;
                    "Container Type Code" := ContainerHeader."Container Type Code";
                end else
                    "Container ID" := '';

                RemoveAssignment(xRec."Container ID", false);
                AddAssignment("Container ID", false);
            end;
        }
        field(34; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
        }
        field(41; "Ship/Receive"; Boolean)
        {
            Caption = 'Ship/Receive';

            trigger OnValidate()
            begin
                TestField("License Plate");

                if xRec."Ship/Receive" <> "Ship/Receive" then
                    UpdateShipReceive;
            end;
        }
    }

    keys
    {
        key(Key1; "Transaction No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if "Container ID" <> '' then
            AddAssignment("Container ID", "Ship/Receive");
    end;

    var
        Text000: Label 'Containers cannot be added to transfer orders.';
        Text001: Label 'Already assigned to %1 %2.';
        Text002: Label 'Containers cannot be added to inbound transfers.';
        Text003: Label 'Containers cannot be removed from inbound transfers.';

    procedure SetDocumentType()
    var
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
    begin
        case "Document Type" of
            DATABASE::"Sales Line":
                if "Document Subtype" = SalesLine."Document Type"::Order then
                    "Document Type (Outbound)" := "Document Type (Outbound)"::Sales
                else
                    "Document Type (Inbound)" := "Document Type (Inbound)"::"Sales Return";
            DATABASE::"Purchase Line":
                if "Document Subtype" = PurchaseLine."Document Type"::"Return Order" then
                    "Document Type (Outbound)" := "Document Type (Outbound)"::"Purchase Return"
                else
                    "Document Type (Inbound)" := "Document Type (Inbound)"::Purchase;
            DATABASE::"Transfer Line":
                if "Document Subtype" = 0 then
                    "Document Type (Outbound)" := "Document Type (Outbound)"::Transfer
                else
                    "Document Type (Inbound)" := "Document Type (Inbound)"::Transfer;
        end;
    end;

    procedure InboundTransfer(): Boolean
    begin
        exit(("Document Type" = DATABASE::"Transfer Line") and ("Document Subtype" = 1));
    end;

    procedure LookupContainer(var Text: Text): Boolean
    var
        ContainerHeader: Record "Container Header";
        Containers: Page Containers;
    begin
        ContainerHeader.FilterGroup(2);
        if "Container Type Code" <> '' then
            ContainerHeader.SetRange("Container Type Code", "Container Type Code");
        ContainerHeader.SetRange(Inbound, Inbound);
        if ("Warehouse Document No." <> '') or ("Document Ref. No." <> 0) or ("Document Type" = DATABASE::"Transfer Line") then // P80056709
            ContainerHeader.SetRange("Location Code", "Location Code");
        ContainerHeader.SetRange("Document Type", 0);
        ContainerHeader.SetRange("Pending Assignment", false); // P80056709
        ContainerHeader.FilterGroup(0);

        if "Location Code" <> '' then
            ContainerHeader.SetRange("Location Code", "Location Code");
        if "Bin Code" <> '' then
            ContainerHeader.SetRange("Bin Code", "Bin Code");

        Containers.SetTableView(ContainerHeader);
        Containers.LookupMode(true);
        if Containers.RunModal = ACTION::LookupOK then begin
            Containers.GetRecord(ContainerHeader);
            Text := ContainerHeader."License Plate";
            exit(true);
        end;
    end;

    procedure LookupDocument(var Text: Text): Boolean
    var
        SourceDocument: Record "Warehouse Request" temporary;
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        TransHeader: Record "Transfer Header";
        WarehouseSourceDocument: Page "Warehouse Source Document";
    begin
        case "Warehouse Document Type" of
            1: // Receipt
                begin
                    WarehouseReceiptLine.SetCurrentKey("No.", "Source Type", "Source Subtype", "Source No.", "Source Line No.");
                    if "Document Type" = 0 then
                        WarehouseReceiptLine.SetFilter("Source Type", '%1|%2', DATABASE::"Sales Line", DATABASE::"Purchase Line")
                    else
                        if "Document Type" = DATABASE::"Transfer Line" then
                            exit
                        else begin
                            WarehouseReceiptLine.SetRange("Source Type", "Document Type");
                            WarehouseReceiptLine.SetRange("Source Subtype", "Document Subtype");
                        end;
                    WarehouseReceiptLine.SetRange("No.", "Warehouse Document No.");
                    WarehouseReceiptLine.FilterGroup(9);
                    if WarehouseReceiptLine.FindSet then
                        repeat
                            WarehouseReceiptLine.SetRange("Source Type", WarehouseReceiptLine."Source Type");
                            WarehouseReceiptLine.SetRange("Source Subtype", WarehouseReceiptLine."Source Subtype");
                            WarehouseReceiptLine.SetRange("Source No.", WarehouseReceiptLine."Source No.");

                            SourceDocument."Source Type" := WarehouseReceiptLine."Source Type";
                            SourceDocument."Source Subtype" := WarehouseReceiptLine."Source Subtype";
                            SourceDocument."Source No." := WarehouseReceiptLine."Source No.";
                            case WarehouseReceiptLine."Source Type" of
                                DATABASE::"Sales Line":
                                    begin
                                        SourceDocument."Source Document" := SourceDocument."Source Document"::"Sales Return Order";
                                        SourceDocument."Destination Type" := SourceDocument."Destination Type"::Customer;
                                        SalesHeader.Get(WarehouseReceiptLine."Source Subtype", WarehouseReceiptLine."Source No.");
                                        SourceDocument."Destination No." := SalesHeader."Sell-to Customer No.";
                                    end;
                                DATABASE::"Purchase Line":
                                    begin
                                        SourceDocument."Source Document" := SourceDocument."Source Document"::"Purchase Order";
                                        SourceDocument."Destination Type" := SourceDocument."Destination Type"::Vendor;
                                        PurchHeader.Get(WarehouseReceiptLine."Source Subtype", WarehouseReceiptLine."Source No.");
                                        SourceDocument."Destination No." := PurchHeader."Buy-from Vendor No.";
                                    end;
                                DATABASE::"Transfer Line":
                                    begin
                                        SourceDocument."Source Document" := SourceDocument."Source Document"::"Outbound Transfer";
                                        SourceDocument."Destination Type" := SourceDocument."Destination Type"::Location;
                                        TransHeader.Get(WarehouseReceiptLine."Source No.");
                                        SourceDocument."Destination No." := TransHeader."Transfer-from Code";
                                    end;
                            end;
                            SourceDocument.Insert;

                            WarehouseReceiptLine.FindLast;
                            WarehouseReceiptLine.SetRange("Source Type");
                            WarehouseReceiptLine.SetRange("Source Subtype");
                            WarehouseReceiptLine.SetRange("Source No.");
                        until WarehouseReceiptLine.Next = 0;
                end;

            2: // Shipment
                begin
                    WarehouseShipmentLine.SetCurrentKey("No.", "Source Type", "Source Subtype", "Source No.", "Source Line No.");
                    if "Document Type" <> 0 then begin
                        WarehouseShipmentLine.SetRange("Source Type", "Document Type");
                        WarehouseShipmentLine.SetRange("Source Subtype", "Document Subtype");
                    end;
                    WarehouseShipmentLine.SetRange("No.", "Warehouse Document No.");
                    WarehouseShipmentLine.FilterGroup(9);
                    if WarehouseShipmentLine.FindSet then
                        repeat
                            WarehouseShipmentLine.SetRange("Source Type", WarehouseShipmentLine."Source Type");
                            WarehouseShipmentLine.SetRange("Source Subtype", WarehouseShipmentLine."Source Subtype");
                            WarehouseShipmentLine.SetRange("Source No.", WarehouseShipmentLine."Source No.");

                            SourceDocument."Source Type" := WarehouseShipmentLine."Source Type";
                            SourceDocument."Source Subtype" := WarehouseShipmentLine."Source Subtype";
                            SourceDocument."Source No." := WarehouseShipmentLine."Source No.";
                            case WarehouseShipmentLine."Source Type" of
                                DATABASE::"Sales Line":
                                    SourceDocument."Source Document" := SourceDocument."Source Document"::"Sales Order";
                                DATABASE::"Purchase Line":
                                    SourceDocument."Source Document" := SourceDocument."Source Document"::"Purchase Return Order";
                                DATABASE::"Transfer Line":
                                    SourceDocument."Source Document" := SourceDocument."Source Document"::"Outbound Transfer";
                            end;
                            SourceDocument."Destination Type" := WarehouseShipmentLine."Destination Type";
                            SourceDocument."Destination No." := WarehouseShipmentLine."Destination No.";
                            SourceDocument.Insert;

                            WarehouseShipmentLine.FindLast;
                            WarehouseShipmentLine.SetRange("Source Type");
                            WarehouseShipmentLine.SetRange("Source Subtype");
                            WarehouseShipmentLine.SetRange("Source No.");
                        until WarehouseShipmentLine.Next = 0;
                end;
        end;

        if not SourceDocument.FindFirst then
            exit;

        WarehouseSourceDocument.SetSource(SourceDocument);
        WarehouseSourceDocument.LookupMode(true);
        if WarehouseSourceDocument.RunModal = ACTION::LookupOK then begin
            WarehouseSourceDocument.GetRecord(SourceDocument);
            Text := SourceDocument."Source No.";
            exit(true);
        end;
    end;

    local procedure AddAssignment(ContainerID: Code[20]; ShipReceive: Boolean)
    var
        ContainerFns: Codeunit "Container Functions";
    begin
        if ("Transaction No." <> 0) and (ContainerID <> '') then
            if InboundTransfer then
                Error(Text002)
            else
                ContainerFns.AddContainerToOrder(ContainerID, "Document Type", "Document Subtype", "Document No.", "Document Line No.", "Document Ref. No.", // P80056709
                  "Warehouse Document Type", "Warehouse Document No.", ShipReceive);
    end;

    procedure RemoveAssignment(ContainerID: Code[20]; ShipReceive: Boolean): Boolean
    var
        ContainerFns: Codeunit "Container Functions";
    begin
        if ("Transaction No." <> 0) and (ContainerID <> '') then
            if InboundTransfer then
                Error(Text003)
            else
                exit(ContainerFns.RemoveContainerFromOrder(ContainerID, "Warehouse Document Type", "Warehouse Document No."));
    end;

    local procedure UpdateShipReceive()
    var
        ContainerHeader: Record "Container Header";
        ContainerFns: Codeunit "Container Functions";
    begin
        if "Transaction No." <> 0 then begin
            ContainerHeader.Get("Container ID");
            ContainerHeader."Ship/Receive" := "Ship/Receive";
            ContainerHeader.Modify;
            ContainerFns.UpdateContainerShipReceive(ContainerHeader, "Ship/Receive", false);
        end;
    end;
}

