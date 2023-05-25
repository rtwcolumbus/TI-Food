table 37002686 "Commodity Manifest Line"
{
    // PRW16.00.04
    // P8000891, VerticalSoft, Don Bresee, 04 JAN 11
    //   Add Commodity Receiving logic
    // 
    // PRW17.10
    // P8001234, Columbus IT, Jack Reynolds, 01 NOV 13
    //    Support for custom lot number formats
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Commodity Manifest Line';

    fields
    {
        field(1; "Commodity Manifest No."; Code[20])
        {
            Caption = 'Commodity Manifest No.';
            TableRelation = "Commodity Manifest Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor WHERE("Commodity Vendor Type" = CONST(Producer));

            trigger OnValidate()
            begin
                TestField("Vendor No.");
                CalcFields("Vendor Name");
            end;
        }
        field(4; "Vendor Name"; Text[100])
        {
            CalcFormula = Lookup (Vendor.Name WHERE("No." = FIELD("Vendor No.")));
            Caption = 'Vendor Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6; "Manifest Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Manifest Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(8; "Received Date"; Date)
        {
            Caption = 'Received Date';
        }
        field(9; "Received Lot No."; Code[50])
        {
            Caption = 'Received Lot No.';
        }
        field(10; "Purch. Order Status"; Option)
        {
            Caption = 'Purch. Order Status';
            Editable = false;
            OptionCaption = 'Open,Created,Posted';
            OptionMembers = Open,Created,Posted;
        }
        field(11; "Purch. Order No."; Code[20])
        {
            CalcFormula = Lookup ("Purchase Line"."Document No." WHERE("Commodity Manifest No." = FIELD("Commodity Manifest No."),
                                                                       "Commodity Manifest Line No." = FIELD("Line No."),
                                                                       "Commodity P.O. Type" = FILTER(Producer | Broker)));
            Caption = 'Purch. Order No.';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = "Purchase Header"."No." WHERE("Document Type" = CONST(Order));
        }
        field(12; "Purch. Order Line No."; Integer)
        {
            BlankZero = true;
            CalcFormula = Lookup ("Purchase Line"."Line No." WHERE("Commodity Manifest No." = FIELD("Commodity Manifest No."),
                                                                   "Commodity Manifest Line No." = FIELD("Line No."),
                                                                   "Commodity P.O. Type" = FILTER(Producer | Broker)));
            Caption = 'Purch. Order Line No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(13; "Purch. Rcpt. No."; Code[20])
        {
            Caption = 'Purch. Rcpt. No.';
            Editable = false;
            TableRelation = "Purch. Rcpt. Header";
        }
        field(14; "Purch. Rcpt. Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Purch. Rcpt. Line No.';
            Editable = false;
            TableRelation = "Purch. Rcpt. Line"."Line No." WHERE("Document No." = FIELD("Purch. Rcpt. No."));
        }
        field(15; "Hauler P.O. No."; Code[20])
        {
            CalcFormula = Lookup ("Purchase Line"."Document No." WHERE("Commodity Manifest No." = FIELD("Commodity Manifest No."),
                                                                       "Commodity Manifest Line No." = FIELD("Line No."),
                                                                       "Commodity P.O. Type" = CONST(Hauler)));
            Caption = 'Hauler P.O. No.';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = "Purchase Header"."No." WHERE("Document Type" = CONST(Order));
        }
        field(16; "Hauler P.O. Line No."; Integer)
        {
            BlankZero = true;
            CalcFormula = Lookup ("Purchase Line"."Line No." WHERE("Commodity Manifest No." = FIELD("Commodity Manifest No."),
                                                                   "Commodity Manifest Line No." = FIELD("Line No."),
                                                                   "Commodity P.O. Type" = CONST(Hauler)));
            Caption = 'Hauler P.O. Line No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(17; "Rejection Action"; Option)
        {
            Caption = 'Rejection Action';
            OptionCaption = ' ,Withhold Payment';
            OptionMembers = " ","Withhold Payment";

            trigger OnValidate()
            var
                CommManifestHeader: Record "Commodity Manifest Header";
            begin
                if ("Rejection Action" > 0) then begin
                    CommManifestHeader.Get("Commodity Manifest No.");
                    CommManifestHeader.TestField("Product Rejected", true);
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "Commodity Manifest No.", "Line No.")
        {
            SumIndexFields = "Manifest Quantity";
        }
        key(Key2; "Commodity Manifest No.", "Vendor No.", "Received Date")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        case "Purch. Order Status" of
            "Purch. Order Status"::Created:
                begin
                    CalcFields("Purch. Order No.");
                    DeletePurchOrderLine;
                end;
            "Purch. Order Status"::Posted:
                FieldError("Purch. Order Status");
        end;
    end;

    trigger OnInsert()
    begin
        TestField("Vendor No.");
    end;

    trigger OnModify()
    begin
        if ("Purch. Order Status" = "Purch. Order Status"::Posted) then
            FieldError("Purch. Order Status");
    end;

    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
        P800ItemTracking: Codeunit "Process 800 Item Tracking";
        ReleasePurchDoc: Codeunit "Release Purchase Document";
        Text000: Label 'Do you want to assign a %1?';

    procedure AssistEditRcptLotNo(OldCommManifestLine: Record "Commodity Manifest Line"): Boolean
    begin
        TestField("Vendor No.");
        if Confirm(Text000, false, FieldCaption("Received Lot No.")) then begin
            AssignRcptLotNo;
            exit(true);
        end;
    end;

    procedure AssignRcptLotNo()
    var
        CommManifestHeader: Record "Commodity Manifest Header";
        Vendor: Record Vendor;
        InvtSetup: Record "Inventory Setup";
    begin
        CommManifestHeader.Get("Commodity Manifest No.");
        Vendor.Get("Vendor No.");
        if (Vendor."Comm. Rcpt. Lot Nos." <> '') then
            "Received Lot No." := NoSeriesMgt.GetNextNo(Vendor."Comm. Rcpt. Lot Nos.", "Received Date", true)
        else begin
            InvtSetup.Get;
            if (InvtSetup."Comm. Rcpt. Lot Nos." <> '') then
                "Received Lot No." := NoSeriesMgt.GetNextNo(InvtSetup."Comm. Rcpt. Lot Nos.", "Received Date", true)
            else begin
                CommManifestHeader.TestField("Item No.");
                //Item.GET(CommManifestHeader."Item No.");               // P8001234
                "Received Lot No." := P800ItemTracking.AssignLotNo(Rec); // P8001234
            end;
        end;
    end;

    procedure SetupNewLine(OldCommManifestLine: Record "Commodity Manifest Line")
    var
        CommManifestHeader: Record "Commodity Manifest Header";
    begin
        if CommManifestHeader.Get("Commodity Manifest No.") then
            "Received Date" := CommManifestHeader."Posting Date";
    end;

    procedure DeletePurchOrderLine()
    var
        PurchLine: Record "Purchase Line";
        PurchOrder: Record "Purchase Header";
        ReservePurchLine: Codeunit "Purch. Line-Reserve";
    begin
        CalcFields("Purch. Order Line No.");
        PurchLine.Get(PurchLine."Document Type"::Order, "Purch. Order No.", "Purch. Order Line No.");
        ReservePurchLine.SetDeleteItemTracking;
        ReservePurchLine.DeleteLine(PurchLine);
        PurchLine."Commodity Manifest No." := '';
        PurchLine.Delete(true);
        PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order);
        PurchLine.SetRange("Document No.", "Purch. Order No.");
        if PurchLine.IsEmpty then begin
            PurchOrder.Get(PurchOrder."Document Type"::Order, "Purch. Order No.");
            ReleasePurchDoc.Reopen(PurchOrder);
            PurchOrder."Commodity Manifest Order" := false;
            PurchOrder.Delete(true);
        end;
        "Purch. Order Status" := "Purch. Order Status"::Open;
    end;

    procedure GetReceivedPercentage(): Decimal
    var
        CommManifestLine: Record "Commodity Manifest Line";
        TotalQty: Decimal;
    begin
        if ("Manifest Quantity" <> 0) then begin
            CommManifestLine.SetRange("Commodity Manifest No.", "Commodity Manifest No.");
            CommManifestLine.CalcSums("Manifest Quantity");
            TotalQty := CommManifestLine."Manifest Quantity";
            if CommManifestLine.Get("Commodity Manifest No.", "Line No.") then
                TotalQty := TotalQty - CommManifestLine."Manifest Quantity";
            TotalQty := TotalQty + "Manifest Quantity";
            if (TotalQty <> 0) then
                exit(("Manifest Quantity" / TotalQty) * 100);
        end;
    end;
}

