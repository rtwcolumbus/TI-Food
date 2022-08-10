codeunit 37002809 "Maintenance Purchase Mgmt."
{
    // PR4.00.04
    // P8000335A, VerticalSoft, Jack Reynolds, 20 SEP 06
    //   Functions to support entry of maintenance fields on purchase line and posting of maintenace ledger
    //     entries from purchase lines
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets


    trigger OnRun()
    begin
    end;

    var
        GLSetup: Record "General Ledger Setup";
        MaintMgt: Codeunit "Maintenance Management";
        MaintJnlPost: Codeunit "Maint. Jnl.-Post Line";
        GLSetupRead: Boolean;
        LastItemEntryNo: Integer;

    procedure PurchLineValidate(FldNo: Integer; xPurchLine: Record "Purchase Line"; var PurchLine: Record "Purchase Line")
    var
        MaintTrade: Record "Maintenance Trade";
        VendorTrade: Record "Vendor / Maintenance Trade";
        Text002: Label 'must not be %1';
        Text003: Label 'must be G/L Account or Item';
        Item: Record Item;
    begin
        with PurchLine do
            case FldNo of
                FieldNo("No."):
                    if ("No." <> '') and
                      ("Maintenance Entry Type" = "Maintenance Entry Type"::Stock)
                    then begin
                        Item.Get("No.");
                        "Part No." := Item."Part No.";
                    end;

                FieldNo(Quantity):
                    if "Maintenance Entry Type" = "Maintenance Entry Type"::Contract then
                        Hours := Quantity;

                FieldNo("Unit of Measure Code"):
                    if ("Unit of Measure Code" <> '') and
                      ("Maintenance Entry Type" = "Maintenance Entry Type"::Contract)
                    then
                        FieldError("Maintenance Entry Type", StrSubstNo(Text002, "Maintenance Entry Type"));

                FieldNo("Work Order No."):
                    if "Work Order No." <> xPurchLine."Work Order No." then begin
                        if "Work Order No." <> '' then begin
                            if not (Type in [Type::"G/L Account", Type::Item]) then
                                FieldError(Type, Text003);
                            MaintMgt.CheckPostingGracePeriod("Work Order No.");
                            if Type = Type::Item then
                                Validate("Maintenance Entry Type", "Maintenance Entry Type"::Stock);
                            case "Maintenance Entry Type" of
                                "Maintenance Entry Type"::Nonstock:
                                    begin
                                        SetLineAccount(PurchLine);
                                        SetLineDescription(PurchLine);
                                    end;
                                "Maintenance Entry Type"::Contract:
                                    begin
                                        SetLineAccount(PurchLine);
                                        SetLineDescription(PurchLine);
                                    end;
                            end;
                        end else begin
                            "Maintenance Entry Type" := 0;
                            "Maintenance Trade Code" := '';
                            Hours := 0;
                            "Part No." := '';
                        end;
                    end;

                FieldNo("Maintenance Entry Type"):
                    if "Maintenance Entry Type" <> xPurchLine."Maintenance Entry Type" then begin
                        if "Maintenance Entry Type" > 0 then
                            TestField("Work Order No.");
                        case "Maintenance Entry Type" of
                            "Maintenance Entry Type"::Stock:
                                begin
                                    TestField(Type, Type::Item);
                                    if "No." <> '' then begin
                                        Item.Get("No.");
                                        "Part No." := Item."Part No.";
                                    end;
                                end;
                            "Maintenance Entry Type"::Nonstock:
                                begin
                                    TestField(Type, Type::"G/L Account");
                                    SetLineAccount(PurchLine);
                                    SetLineDescription(PurchLine);
                                    Validate("Maintenance Trade Code", '');
                                end;
                            "Maintenance Entry Type"::Contract:
                                begin
                                    TestField(Type, Type::"G/L Account");
                                    Validate("No.", '');
                                    SetLineAccount(PurchLine);
                                    SetLineDescription(PurchLine);
                                end;
                        end;
                    end;

                FieldNo("Maintenance Trade Code"):
                    if "Maintenance Trade Code" <> '' then begin
                        TestField("Work Order No.");
                        TestField("Maintenance Entry Type", "Maintenance Entry Type"::Contract);
                        MaintTrade.Get("Maintenance Trade Code");
                        Validate(Description, MaintTrade.Description);
                        if VendorTrade.Get("Buy-from Vendor No.", "Maintenance Trade Code") then
                            Validate("Direct Unit Cost", VendorTrade."Rate (Hourly)")
                        else
                            Validate("Direct Unit Cost", MaintTrade."External Rate (Hourly)");
                    end else begin
                        SetLineDescription(PurchLine);
                        Validate("Direct Unit Cost", 0);
                    end;

                FieldNo(Hours):
                    begin
                        if Hours <> 0 then begin
                            TestField("Work Order No.");
                            TestField("Maintenance Entry Type", "Maintenance Entry Type"::Contract);
                        end;
                        Validate(Quantity, Hours);
                    end;

                FieldNo("Part No."):
                    if "Part No." <> '' then begin
                        TestField("Work Order No.");
                        TestField("Maintenance Entry Type", "Maintenance Entry Type"::Nonstock);
                        SetLineDescription(PurchLine);
                    end;
            end;
    end;

    procedure SetLineAccount(var PurchLine: Record "Purchase Line")
    var
        WorkOrder: Record "Work Order";
    begin
        with PurchLine do begin
            if "Work Order No." <> '' then
                case "Maintenance Entry Type" of
                    "Maintenance Entry Type"::Nonstock:
                        begin
                            WorkOrder.Get("Work Order No.");
                            Validate("No.", WorkOrder."Material Account");
                        end;
                    "Maintenance Entry Type"::Contract:
                        begin
                            WorkOrder.Get("Work Order No.");
                            Validate("No.", WorkOrder."Contract Account");
                        end;
                end;
        end;
    end;

    procedure SetLineDescription(var PurchLine: Record "Purchase Line")
    var
        GLAccount: Record "G/L Account";
        MaintTrade: Record "Maintenance Trade";
        Text001: Label 'Part No. %1';
    begin
        with PurchLine do
            case "Maintenance Entry Type" of
                "Maintenance Entry Type"::Nonstock:
                    if "Part No." <> '' then
                        Validate(Description, StrSubstNo(Text001, "Part No."))
                    else
                        if "No." <> '' then begin
                            GLAccount.Get("No.");
                            Validate(Description, GLAccount.Name);
                        end;
                "Maintenance Entry Type"::Contract:
                    if "Maintenance Trade Code" <> '' then begin
                        MaintTrade.Get("Maintenance Trade Code");
                        Validate(Description, MaintTrade.Description);
                    end else
                        if "No." <> '' then begin
                            GLAccount.Get("No.");
                            Validate(Description, GLAccount.Name);
                        end;
            end;
    end;

    procedure PurchPostCheckLine(PurchLine: Record "Purchase Line")
    var
        Text001: Label '%1 must be specified.';
    begin
        with PurchLine do begin
            MaintMgt.CheckPostingGracePeriod("Work Order No.");
            case "Maintenance Entry Type" of
                "Maintenance Entry Type"::Stock:
                    if "Qty. to Receive" <> 0 then begin
                        TestField(Type, Type::Item);
                        TestField("Unit of Measure Code");
                    end;
                "Maintenance Entry Type"::Nonstock:
                    if "Qty. to Invoice" <> 0 then begin
                        TestField(Type, Type::"G/L Account");
                        TestField("Part No.");
                        TestField("Unit of Measure Code");
                    end;
                "Maintenance Entry Type"::Contract:
                    if "Qty. to Invoice" <> 0 then begin
                        TestField(Type, Type::"G/L Account");
                        TestField("Maintenance Trade Code");
                    end;
                else
                    Error(Text001, FieldCaption("Maintenance Entry Type"));
            end;
        end;
    end;

    procedure PurchPostLine(PurchHeader: Record "Purchase Header"; PurchLine: Record "Purchase Line"; PurchRcptLine: Record "Purch. Rcpt. Line"; PurchInvLine: Record "Purch. Inv. Line"; SrcCode: Code[10]; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line")
    var
        WorkOrder: Record "Work Order";
        MaintJnlLine: Record "Maintenance Journal Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemJnlLine: Record "Item Journal Line";
        MaintLedgEntry: Record "Maintenance Ledger";
        ItemReg: Record "Item Register";
    begin
        // P8001133 - remove parameter for TempJnlLineDim
        GetGLSetup;
        ItemJnlPostLine.GetItemReg(ItemReg);
        if LastItemEntryNo <> 0 then
            ItemReg."From Entry No." := LastItemEntryNo + 1;
        LastItemEntryNo := ItemReg."To Entry No.";

        with PurchLine do begin
            if "Work Order No." = '' then
                exit;
            if not (
                (PurchHeader.Receive and
                  ("Maintenance Entry Type" = "Maintenance Entry Type"::Stock) and
                  ("Qty. to Receive" <> 0)) or
                (PurchHeader.Invoice and
                  ("Maintenance Entry Type" in ["Maintenance Entry Type"::Nonstock, "Maintenance Entry Type"::Contract]) and
                  ("Qty. to Invoice" <> 0)))
            then
                exit;

            WorkOrder.Get("Work Order No.");

            MaintJnlLine."Work Order No." := "Work Order No.";
            MaintJnlLine."Posting Date" := PurchHeader."Posting Date";
            MaintJnlLine."Entry Type" := "Maintenance Entry Type" - 1;
            MaintJnlLine."Location Code" := "Location Code";
            MaintJnlLine."Document Date" := PurchHeader."Document Date";
            MaintJnlLine.Description := WorkOrder."Asset Description";
            MaintJnlLine."Source Code" := SrcCode;
            MaintJnlLine."Reason Code" := PurchHeader."Reason Code";
            MaintJnlLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
            MaintJnlLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
            MaintJnlLine."Dimension Set ID" := PurchLine."Dimension Set ID"; // P8001133
            MaintJnlLine."Maintenance Trade Code" := "Maintenance Trade Code";
            MaintJnlLine."Vendor No." := PurchHeader."Buy-from Vendor No.";

            case "Maintenance Entry Type" of
                "Maintenance Entry Type"::Stock:
                    begin
                        if PurchRcptLine."Document No." <> '' then
                            MaintJnlLine."Document No." := PurchRcptLine."Document No."
                        else
                            MaintJnlLine."Document No." := PurchInvLine."Document No.";
                        MaintJnlLine."Item No." := "No.";
                        MaintJnlLine."Part No." := "Part No.";
                        MaintJnlLine."Unit of Measure Code" := "Unit of Measure Code";
                        MaintJnlLine."Qty. per Unit of Measure" := "Qty. per Unit of Measure";
                        ItemLedgerEntry.SetRange("Entry No.", ItemReg."From Entry No.", ItemReg."To Entry No.");
                        if ItemLedgerEntry.FindSet then
                            repeat
                                ItemLedgerEntry.CalcFields("Cost Amount (Expected)", "Cost Amount (Actual)");
                                MaintJnlLine.Quantity := Round(ItemLedgerEntry.Quantity / MaintJnlLine."Qty. per Unit of Measure", 0.00001);
                                MaintJnlLine.Amount := ItemLedgerEntry."Cost Amount (Expected)" + ItemLedgerEntry."Cost Amount (Actual)";
                                MaintJnlLine."Unit Cost" := Round(MaintJnlLine.Amount / MaintJnlLine.Quantity,
                                  GLSetup."Unit-Amount Rounding Precision");
                                MaintJnlLine."Lot No." := ItemLedgerEntry."Lot No.";
                                MaintJnlLine."Serial No." := ItemLedgerEntry."Serial No.";
                                MaintJnlLine."Item Ledger Entry No." := ItemLedgerEntry."Entry No.";
                                MaintJnlPost.SetDeferItemPosting(true);
                                MaintJnlPost.RunWithCheck(MaintJnlLine); // P8001133
                                MaintJnlPost.GetItemJnlLine(ItemJnlLine);
                                ItemJnlPostLine.RunWithCheck(ItemJnlLine); // P8001133
                                MaintJnlPost.GetMaintLedger(MaintLedgEntry);
                                MaintLedgEntry."Item Ledger Entry No." := ItemJnlLine."Item Shpt. Entry No.";
                                LastItemEntryNo := ItemJnlLine."Item Shpt. Entry No.";
                                MaintLedgEntry.Modify;
                            until ItemLedgerEntry.Next = 0;
                    end;

                "Maintenance Entry Type"::Nonstock:
                    begin
                        MaintJnlLine."Document No." := PurchInvLine."Document No.";
                        MaintJnlLine."Item No." := "Part No.";
                        MaintJnlLine."Part No." := "Part No.";
                        MaintJnlLine."Unit of Measure Code" := "Unit of Measure Code";
                        MaintJnlLine.Quantity := PurchInvLine.Quantity;
                        MaintJnlLine."Unit Cost" := PurchInvLine."Direct Unit Cost";
                        MaintJnlLine.Amount := PurchInvLine.Amount;
                        MaintJnlPost.RunWithCheck(MaintJnlLine); // P8001133
                    end;

                "Maintenance Entry Type"::Contract:
                    begin
                        MaintJnlLine."Document No." := PurchInvLine."Document No.";
                        MaintJnlLine.Quantity := PurchInvLine.Quantity;
                        MaintJnlLine."Unit Cost" := PurchInvLine."Direct Unit Cost";
                        MaintJnlLine.Amount := PurchInvLine.Amount;
                        MaintJnlPost.RunWithCheck(MaintJnlLine); // P8001133
                    end;
            end;
        end;
    end;

    procedure GetGLSetup()
    begin
        if GLSetupRead then
            exit;
        GLSetup.Get;
        GLSetupRead := true;
    end;
}

