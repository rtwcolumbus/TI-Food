table 37002568 "Container Line Application"
{
    // PRW16.00.06
    // P8001035, Columbus IT, Jack Reynolds, 23 FEB 12
    //   Fix problem with containers, alternate quantity and reservation entries
    // 
    // PRW18.00.01
    // P8001373, Columbus IT, Jack Reynolds, 01 APR 15
    //   Support for containers on purchase returns
    // 
    // PRW110.0.02
    // P80046953, To-Increase, Dayakar Battini, 27 SEP 17
    //   Delete related reservation entry also
    // 
    // P80046533, To-Increase, Jack Reynolds, 10 OCT 17
    //   Inbound containers and shipping containers
    // 
    // PRW111.00.01
    // P80058321, To-Increase, Jack Reynolds, 03 MAY 18
    //   Problem adding tracking lines
    // 
    // P80060004, To Increase, Jack Reynolds, 14 JUN 18
    //   Problem adding tracking lines with multiple lots
    // 
    // PRW111.00.03
    // P80075420, To-Increase, Jack Reynolds, 08 JUL 19
    //   Problem losing tracking when using containers and specifying alt quantity to handle

    Caption = 'Container Line Application';

    fields
    {
        field(2; "Application Table No."; Integer)
        {
            Caption = 'Application Table No.';
        }
        field(3; "Application Subtype"; Integer)
        {
            Caption = 'Application Subtype';
        }
        field(4; "Application No."; Code[20])
        {
            Caption = 'Application No.';
        }
        field(5; "Application Batch Name"; Code[10])
        {
            Caption = 'Application Batch Name';
        }
        field(6; "Application Line No."; Integer)
        {
            Caption = 'Application Line No.';
        }
        field(7; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(8; "Container ID"; Code[20])
        {
            Caption = 'Container ID';
            TableRelation = "Container Header";
        }
        field(9; "Container Line No."; Integer)
        {
            Caption = 'Container Line No.';
            TableRelation = "Container Line"."Line No." WHERE("Container ID" = FIELD("Container ID"));
        }
        field(10; "Quantity (Alt.)"; Decimal)
        {
            Caption = 'Quantity (Alt.)';
            DecimalPlaces = 0 : 5;
        }
        field(11; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
        }
    }

    keys
    {
        key(Key1; "Application Table No.", "Application Subtype", "Application No.", "Application Batch Name", "Application Line No.", "Container ID", "Container Line No.")
        {
        }
        key(Key2; "Container ID", "Container Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        SubtractApplicationLine(Quantity, "Quantity (Base)", "Quantity (Alt.)");
    end;

    trigger OnInsert()
    begin
        AddApplicationLine(Quantity, "Quantity (Base)", "Quantity (Alt.)");
    end;

    trigger OnModify()
    begin
        xRec.Find;
        if xRec.Quantity <= Quantity then
            AddApplicationLine(Quantity - xRec.Quantity, "Quantity (Base)" - xRec."Quantity (Base)", "Quantity (Alt.)" - xRec."Quantity (Alt.)")
        else
            SubtractApplicationLine(xRec.Quantity - Quantity, xRec."Quantity (Base)" - "Quantity (Base)", xRec."Quantity (Alt.)" - "Quantity (Alt.)");
    end;

    var
        ContainerLine: Record "Container Line";
        ShipReceive: Boolean;
        SpecificTracking: Boolean;
        RegisteringPick: Boolean;

    procedure SetParameters(NewContainerLine: Record "Container Line"; NewShipReceive: Boolean; NewSpecificTracking: Boolean; NewRegisteringPick: Boolean)
    begin
        // P80046533
        ContainerLine := NewContainerLine;
        ShipReceive := NewShipReceive;
        SpecificTracking := NewSpecificTracking;
        RegisteringPick := NewRegisteringPick; // P80075420
    end;

    procedure AddApplicationLine(QuantityAdded: Decimal; QuantityAddedBase: Decimal; QuantityAddedAlt: Decimal)
    var
        ContainerHeader: Record "Container Header";
        UpdateDocLine: Codeunit "Update Document Line";
        ContainerQtyByDocLine: Query "Container Qty. by Doc. Line";
        ApplicationQuantity: array[3] of Decimal;
    begin
        // P80046533
        ContainerHeader.Get("Container ID");

        UpdateDocLine.SetApplication(ContainerHeader.Inbound, "Application Table No.", "Application Subtype", "Application No.", "Application Line No.");

        // P80058321
        if not RegisteringPick then begin
            // P80060004
            ContainerQtyByDocLine.SetRange(ApplicationTableNo, "Application Table No.");
            ContainerQtyByDocLine.SetRange(ApplicationSubtype, "Application Subtype");
            ContainerQtyByDocLine.SetRange(ApplicationNo, "Application No.");
            ContainerQtyByDocLine.SetRange(ApplicationBatchName, "Application Batch Name");
            ContainerQtyByDocLine.SetRange(ApplicationLineNo, "Application Line No.");
            ContainerQtyByDocLine.SetRange(LotNo, ContainerLine."Lot No.");
            ContainerQtyByDocLine.SetRange(SerialNo, ContainerLine."Serial No.");
            if ContainerQtyByDocLine.Open then
                while ContainerQtyByDocLine.Read do begin
                    ApplicationQuantity[1] += ContainerQtyByDocLine.SumQuantity;
                    ApplicationQuantity[2] += ContainerQtyByDocLine.SumQuantityBase;
                    ApplicationQuantity[3] += ContainerQtyByDocLine.SumQuantityAlt;
                end;
            UpdateDocLine.AddTracking(SpecificTracking, false, ContainerLine."Lot No.", ContainerLine."Serial No.",
                ApplicationQuantity[1] + QuantityAdded,
                ApplicationQuantity[2] + QuantityAddedBase,
                ApplicationQuantity[3] + QuantityAddedAlt,
                QuantityAdded, QuantityAddedBase, QuantityAddedAlt, ShipReceive);
            // P80060004
        end;
        // P80058321

        if ShipReceive then begin
            UpdateDocLine.AddAlternateQuantityLines(ContainerLine."Lot No.", ContainerLine."Serial No.",
                ContainerLine."Container ID", ContainerLine."Line No.", QuantityAdded, QuantityAddedBase, QuantityAddedAlt);
            UpdateDocLine.UpdateSourceDocumentLine(QuantityAdded, QuantityAddedAlt);
            UpdateDocLine.UpdateWarehouseDcoumentLine(ContainerHeader."Whse. Document Type", ContainerHeader."Whse. Document No.",
              RegisteringPick, ContainerHeader."Bin Code", QuantityAdded);
            UpdateDocLine.UpdateTrackingAltQuantity(ContainerLine."Lot No.", ContainerLine."Serial No.");
        end;
    end;

    procedure SubtractApplicationLine(QuantityRemoved: Decimal; QuantityRemovedBase: Decimal; QuantityRemovedAlt: Decimal)
    var
        ContainerHeader: Record "Container Header";
        UpdateDocLine: Codeunit "Update Document Line";
    begin
        // P80046533
        ContainerHeader.Get("Container ID");

        UpdateDocLine.SetApplication(ContainerHeader.Inbound, "Application Table No.", "Application Subtype", "Application No.", "Application Line No.");

        if (ContainerLine."Lot No." <> '') or (ContainerLine."Serial No." <> '') then
            UpdateDocLine.DeleteTracking(ContainerLine."Lot No.", ContainerLine."Serial No.", QuantityRemoved, QuantityRemovedBase, QuantityRemovedAlt, ShipReceive);

        if ContainerHeader."Ship/Receive" then begin
            UpdateDocLine.DeleteAlternateQuantityLines(ContainerLine."Lot No.", ContainerLine."Serial No.", ContainerLine."Container ID", ContainerLine."Line No.",
              QuantityRemoved, QuantityRemovedBase, QuantityRemovedAlt);
            UpdateDocLine.UpdateSourceDocumentLine(-QuantityRemoved, -QuantityRemovedAlt);
            UpdateDocLine.UpdateWarehouseDcoumentLine(ContainerHeader."Whse. Document Type", ContainerHeader."Whse. Document No.",
              false, ContainerHeader."Bin Code", -QuantityRemoved);
            UpdateDocLine.UpdateTrackingAltQuantity(ContainerLine."Lot No.", ContainerLine."Serial No.");
        end;
    end;

    procedure UpdateShipReceive(ShipReceive: Boolean)
    var
        ContainerHeader: Record "Container Header";
        UpdateDocLine: Codeunit "Update Document Line";
        RegisteringPick: Boolean;
    begin
        // P80046533
        // Need to set RegisgteringPick??
        ContainerHeader.Get("Container ID");

        UpdateDocLine.SetApplication(ContainerHeader.Inbound, "Application Table No.", "Application Subtype", "Application No.", "Application Line No.");

        if (ContainerLine."Lot No." <> '') or (ContainerLine."Serial No." <> '') then
            UpdateDocLine.UpdateTracking(ContainerLine."Lot No.", ContainerLine."Serial No.", Quantity, "Quantity (Base)", ShipReceive);

        if ShipReceive then begin
            UpdateDocLine.AddAlternateQuantityLines(ContainerLine."Lot No.", ContainerLine."Serial No.", ContainerLine."Container ID", ContainerLine."Line No.",
              Quantity, "Quantity (Base)", "Quantity (Alt.)");
            UpdateDocLine.UpdateSourceDocumentLine(Quantity, "Quantity (Alt.)");
            UpdateDocLine.UpdateWarehouseDcoumentLine(ContainerHeader."Whse. Document Type", ContainerHeader."Whse. Document No.",
              false, ContainerHeader."Bin Code", Quantity);
            UpdateDocLine.UpdateTrackingAltQuantity(ContainerLine."Lot No.", ContainerLine."Serial No.");
        end else begin
            UpdateDocLine.DeleteAlternateQuantityLines(ContainerLine."Lot No.", ContainerLine."Serial No.", ContainerLine."Container ID", ContainerLine."Line No.",
              Quantity, "Quantity (Base)", "Quantity (Alt.)");
            UpdateDocLine.UpdateSourceDocumentLine(-Quantity, -"Quantity (Alt.)");
            UpdateDocLine.UpdateWarehouseDcoumentLine(ContainerHeader."Whse. Document Type", ContainerHeader."Whse. Document No.",
              false, ContainerHeader."Bin Code", -Quantity);
            UpdateDocLine.UpdateTrackingAltQuantity(ContainerLine."Lot No.", ContainerLine."Serial No.");
        end;
    end;
}

