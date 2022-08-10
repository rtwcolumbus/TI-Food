codeunit 37002122 "Accrual Jnl.-Post Line"
{
    // PR3.70.03
    // 
    // PR3.70.07
    // P8000119A, Myers Nissi, Don Bresee, 20 SEP 04
    //   Accruals update/fixes
    // 
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PR4.00
    // P8000246A, Myers Nissi, Jack Reynolds, 05 OCT 05
    //   If accounts from general posting setup are blank then use accounts from accrual posting group
    // 
    // PR4.00.01
    // P8000274A, VerticalSoft, Jack Reynolds, 22 DEC 05
    //   Add checks for source, source document no, source document line no, and posting level
    // 
    // P8000279A, VerticalSoft, Jack Reynolds, 11 JAN 06
    //   Fix double posting of accruals when price impact is "Include in Price"
    // 
    // PR4.00.05
    // P8000427A, VerticalSoft, Jack Reynolds, 28 DEC 06
    //   Update global dimension fields in the posting buffer
    // 
    // PRW16.00.04
    // P8000852, VerticalSoft, Jack Reynolds, 05 AUG 10
    //   Fix problem wih records accumulating in Dimension Buffer table
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW18.00.02
    // P8002743, To-Increase, Jack Reynolds, 30 Sep 15
    //   Support for accrual payment documents
    // 
    // P8002745, To-Increase, Jack Reynolds, 30 Sep 15
    //   Support for accrual payment documents
    // 
    // PRW110.0.01
    // P8008663, To-Increase, Jack Reynolds 21 APR 17
    //   Payments in foreign currencies
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.02
    // P80068489, To Increase, Gangabhushan, 31 DEC 18
    //   TI-12522 - VAT issues for accruals process
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Permissions = TableData "Accrual Ledger Entry" = imd,
                  TableData "Accrual Register" = imd,
                  TableData "Accrual Posting Buffer" = rimd;
    TableNo = "Accrual Journal Line";

    trigger OnRun()
    begin
        GetGLSetup;
        RunWithCheck(Rec);
    end;

    var
        AccrualLedgEntry: Record "Accrual Ledger Entry";
        AccrualPlan: Record "Accrual Plan";
        AccrualJnlLine: Record "Accrual Journal Line";
        AccrualPostingGroup: Record "Accrual Posting Group";
        AccrualPostingBuffer: Record "Accrual Posting Buffer" temporary;
        AccrualReg: Record "Accrual Register";
        GenPostingSetup: Record "General Posting Setup";
        GLSetup: Record "General Ledger Setup";
        AccrualJnlCheckLine: Codeunit "Accrual Jnl.-Check Line";
        AccrualJnlMgmt: Codeunit AccrualJnlManagement;
        AccrualFldMgmt: Codeunit "Accrual Field Management";
        DimMgt: Codeunit DimensionManagement;
        GLSetupRead: Boolean;
        NextEntryNo: Integer;

    procedure GetAccrualReg(var NewAccrualReg: Record "Accrual Register")
    begin
        NewAccrualReg := AccrualReg;
    end;

    procedure RunWithCheck(var AccrualJnlLine2: Record "Accrual Journal Line")
    begin
        // P8001133 - remove parameter for TempJnlLineDim2
        AccrualJnlLine.Copy(AccrualJnlLine2);
        Code;
        AccrualJnlLine2 := AccrualJnlLine;
    end;

    local procedure "Code"()
    begin
        with AccrualJnlLine do begin
            if EmptyLine then
                exit;

            AccrualJnlCheckLine.RunCheck(AccrualJnlLine); // P8001133

            PrepareToPost("Source Code", "Journal Batch Name");

            if "Document Date" = 0D then
                "Document Date" := "Posting Date";

            AccrualPlan.Get("Accrual Plan Type", "Accrual Plan No.");

            CheckSourceFields; // P8000274A

            if (AccrualPlan."Plan Type" <> AccrualPlan."Plan Type"::Reporting) then begin
                AccrualPostingGroup.Get("Accrual Posting Group");
                //AccrualPostingGroup.TESTFIELD("Accrual Account"); // P80053245
                case "Entry Type" of
                    "Entry Type"::Accrual:
                        begin
                            case "Accrual Plan Type" of
                                "Accrual Plan Type"::Sales:
                                    begin
                                        AddToPostBuffer(Type::"G/L Account", GetAndTestPlanAccount(), -Amount, -Amount); // P8008663
                                        AddToPostBuffer(Type::"G/L Account", AccrualPostingGroup.GetAccrualAccount, Amount, Amount); // P8008663, P80053245
                                    end;
                                "Accrual Plan Type"::Purchase:
                                    begin
                                        AddToPostBuffer(Type::"G/L Account", GetAndTestPlanAccount(), -Amount, -Amount); // P8008663
                                        AddToPostBuffer(Type::"G/L Account", AccrualPostingGroup.GetAccrualAccount, Amount, Amount); // P8008663, P80053245
                                    end;
                            end;
                            AddReclassEntries;
                        end;
                    "Entry Type"::Payment:
                        begin
                            AddToPostBuffer(Type::"G/L Account", AccrualPostingGroup.GetAccrualAccount, Amount, Amount); // P8008663, P80053245
                            AddToPostBuffer(Type, "No.", -Amount, -"Amount (FCY)"); // P8008663
                        end;
                end;
            end;

            AccrualLedgEntry.Init;
            AccrualLedgEntry."Accrual Plan Type" := "Accrual Plan Type";
            AccrualLedgEntry."Accrual Plan No." := "Accrual Plan No.";
            AccrualLedgEntry."Plan Type" := AccrualPlan."Plan Type";
            AccrualLedgEntry."Posting Date" := "Posting Date";
            AccrualLedgEntry."Document Date" := "Document Date";
            AccrualLedgEntry."Document No." := "Document No.";
            AccrualLedgEntry."External Document No." := "External Document No.";
            AccrualLedgEntry."Entry Type" := "Entry Type";
            AccrualLedgEntry."Scheduled Accrual No." := "Scheduled Accrual No.";
            AccrualLedgEntry."Source No." := "Source No.";
            AccrualLedgEntry.Type := Type;
            AccrualLedgEntry."No." := "No.";
            AccrualLedgEntry.Description := Description;
            AccrualLedgEntry."Source Document Type" := "Source Document Type";
            AccrualLedgEntry."Source Document No." := "Source Document No.";
            AccrualLedgEntry."Source Document Line No." := "Source Document Line No.";
            AccrualLedgEntry."Item No." := "Item No.";
            AccrualLedgEntry."Price Impact" := "Price Impact";
            AccrualLedgEntry."Accrual Posting Group" := "Accrual Posting Group";
            AccrualLedgEntry."Global Dimension 1 Code" := "Shortcut Dimension 1 Code";
            AccrualLedgEntry."Global Dimension 2 Code" := "Shortcut Dimension 2 Code";
            AccrualLedgEntry."Dimension Set ID" := "Dimension Set ID"; // P8001133
            AccrualLedgEntry.Amount := Amount;
            AccrualLedgEntry."Journal Batch Name" := "Journal Batch Name";
            AccrualLedgEntry."Reason Code" := "Reason Code";
            AccrualLedgEntry."No. Series" := "Posting No. Series";
            AccrualLedgEntry."Source Code" := "Source Code";

            AccrualLedgEntry."User ID" := UserId;
            AccrualLedgEntry."Entry No." := NextEntryNo;

            AccrualLedgEntry.Insert;

            NextEntryNo := NextEntryNo + 1;

            UpdatePostedDocAccuralLines;
        end;
    end;

    local procedure PrepareToPost(var SourceCode: Code[10]; var JnlBatchName: Code[10])
    begin
        if AccrualLedgEntry."Entry No." = 0 then begin
            AccrualLedgEntry.LockTable;
            if AccrualLedgEntry.Find('+') then
                NextEntryNo := AccrualLedgEntry."Entry No.";
            NextEntryNo := NextEntryNo + 1;
        end;

        if AccrualReg."No." = 0 then begin
            AccrualReg.LockTable;
            if (not AccrualReg.Find('+')) or (AccrualReg."To Entry No." <> 0) then begin
                AccrualReg.Init;
                AccrualReg."No." := AccrualReg."No." + 1;
                AccrualReg."From Entry No." := NextEntryNo;
                AccrualReg."To Entry No." := NextEntryNo;
                AccrualReg."Creation Date" := Today;
                AccrualReg."Creation Time" := Time; // P80073095
                AccrualReg."Source Code" := SourceCode;
                AccrualReg."Journal Batch Name" := JnlBatchName;
                AccrualReg."User ID" := UserId;
                AccrualReg.Insert;
            end;
        end;
        AccrualReg."To Entry No." := NextEntryNo;
        AccrualReg.Modify;
    end;

    local procedure CheckSourceFields()
    var
        BillToPayToNo: Code[20];
        DueDate: Date;
        ItemNo: Code[20];
        DummyVATProdPosGrp: Code[20];
    begin
        // P8000274A
        with AccrualJnlLine do begin
            if ("Source No." <> '') then begin
                AccrualPlan.CheckPostingLevel("Entry Type", AccrualPlan."Accrual Posting Level"::Source);
                AccrualFldMgmt.CheckSource(AccrualPlan, "Entry Type", "Source No.", "Source No.", 0D);
            end;
            if ("Source Document No." <> '') then begin
                AccrualPlan.CheckPostingLevel("Entry Type", AccrualPlan."Accrual Posting Level"::Document);
                AccrualFldMgmt.CheckSourceDocNo(
                  AccrualPlan, "Entry Type", "Source Document Type",
                  "Source Document No.", BillToPayToNo, DueDate);
            end;
            if ("Source Document Line No." <> 0) then begin
                AccrualPlan.CheckPostingLevel("Entry Type", AccrualPlan."Accrual Posting Level"::"Document Line");
                AccrualFldMgmt.CheckSourceDocLineNo(
                  AccrualPlan, "Entry Type", "Source Document Type", "Source Document No.",
                  "Source Document Line No.", ItemNo, "Gen. Bus. Posting Group", "Gen. Prod. Posting Group", DummyVATProdPosGrp, false); // P80068489
            end;
        end;
    end;

    local procedure GetGLSetup()
    begin
        if not GLSetupRead then
            GLSetup.Get;
        GLSetupRead := true;
    end;

    local procedure AddReclassEntries()
    var
        FromAccount: Code[20];
        ToAccount: Code[20];
        ReclassAmount: Decimal;
    begin
        with AccrualJnlLine do
            if (AccrualPlan."Price Impact" <> AccrualPlan."Price Impact"::None) then begin
                GenPostingSetup.Get("Gen. Bus. Posting Group", "Gen. Prod. Posting Group");
                if (AccrualPlan.Type = AccrualPlan.Type::Sales) then begin
                    GenPostingSetup.TestField("Sales Account");
                    FromAccount := GenPostingSetup."Sales Account";
                    if AccrualPlan."Price Impact" = AccrualPlan."Price Impact"::"Exclude from Price" then begin // P8000279A
                                                                                                                // P8000246A Begin
                        if GenPostingSetup."Sales Account (Accrual)" = '' then                            // P80053245
                                                                                                          //AccrualPostingGroup.TESTFIELD(AccrualPostingGroup."Sales Account (Accrual)"); // P80053245
                            ToAccount := AccrualPostingGroup.GetSalesAccountAccrual                         // P80053245
                        else                                                                              // P80053245
                                                                                                          // P8000246A End
                            ToAccount := GenPostingSetup."Sales Account (Accrual)";
                        // P8000279A Begin
                    end else begin
                        if GenPostingSetup."Sales Plan Account (Accrual)" = '' then                  // P80053245
                                                                                                     //AccrualPostingGroup.TESTFIELD(AccrualPostingGroup."Sales Plan Account"); // P80053245
                            ToAccount := AccrualPostingGroup.GetSalesPlanAccount                       // P80053245
                        else                                                                         // P80053245
                            ToAccount := GenPostingSetup."Sales Plan Account (Accrual)";
                    end;
                    // P8000279A End
                end else begin
                    GenPostingSetup.TestField("Purch. Account");
                    FromAccount := GenPostingSetup."Purch. Account";
                    if AccrualPlan."Price Impact" = AccrualPlan."Price Impact"::"Exclude from Price" then begin // P8000279A
                                                                                                                // P8000246A Begin
                        if GenPostingSetup."Purch. Account (Accrual)" = '' then        // P80053245
                                                                                       //AccrualPostingGroup.TESTFIELD("Purch. Account (Accrual)"); // P80053245
                            ToAccount := AccrualPostingGroup.GetPurchaseAccountAccrual   // P80053245
                        else                                                           // P80053245
                                                                                       // P8000246A End
                            ToAccount := GenPostingSetup."Purch. Account (Accrual)";
                        // P8000279A Begin
                    end else begin
                        if GenPostingSetup."Purch. Plan Account (Accrual)" = '' then                    // P80053245
                                                                                                        //AccrualPostingGroup.TESTFIELD(AccrualPostingGroup."Purchase Plan Account"); // P80053245
                            ToAccount := AccrualPostingGroup.GetPurchasePlanAccount                       // P80053245
                        else                                                                            // P80053245
                            ToAccount := GenPostingSetup."Purch. Plan Account (Accrual)";
                    end;
                    // P8000279A End
                end;
                if (AccrualPlan."Price Impact" =
                    AccrualPlan."Price Impact"::"Include in Price")
                then
                    ReclassAmount := -Amount
                else
                    ReclassAmount := Amount;
                AddToPostBuffer(Type::"G/L Account", FromAccount, ReclassAmount, ReclassAmount); // P8008663
                AddToPostBuffer(Type::"G/L Account", ToAccount, -ReclassAmount, -ReclassAmount); // P8008663
            end;
    end;

    local procedure GetAndTestPlanAccount(): Code[20]
    begin
        if AccrualPlan."Use Accrual Schedule" or
           (AccrualPlan.GetPostingLevel(AccrualJnlLine."Entry Type") <>
            AccrualPlan."Accrual Posting Level"::"Document Line")
        then
            with AccrualPostingGroup do
                if (AccrualPlan.Type = AccrualPlan.Type::Sales) then begin
                    //TESTFIELD("Sales Plan Account");    // P80053245
                    exit(GetSalesPlanAccount);            // P80053245
                end else begin
                    //TESTFIELD("Purchase Plan Account"); // P80053245
                    exit(GetPurchasePlanAccount);         // P80053245
                end
        else
            with GenPostingSetup do begin
                Get(AccrualJnlLine."Gen. Bus. Posting Group", AccrualJnlLine."Gen. Prod. Posting Group");
                if (AccrualPlan.Type = AccrualPlan.Type::Sales) then begin
                    //TESTFIELD("Sales Plan Account (Accrual)"); // P8000246A
                    // P8000246A Begin
                    if "Sales Plan Account (Accrual)" = '' then              // P80053245
                                                                             //AccrualPostingGroup.TESTFIELD("Sales Plan Account"); // P80053245
                        exit(AccrualPostingGroup.GetSalesPlanAccount)          // P80053245
                    else                                                     // P80053245
                                                                             // P8000246A End
                        exit("Sales Plan Account (Accrual)");
                end else begin
                    //TESTFIELD("Purch. Plan Account (Accrual)");
                    // P8000246A Begin
                    if "Purch. Plan Account (Accrual)" = '' then                // P80053245
                                                                                //AccrualPostingGroup.TESTFIELD("Purchase Plan Account"); // P80053245
                        exit(AccrualPostingGroup.GetPurchasePlanAccount)          // P80053245
                    else                                                        // P80053245
                                                                                // P8000246A End
                        exit("Purch. Plan Account (Accrual)");
                end;
            end;
    end;

    local procedure AddToPostBuffer(PostToType: Integer; PostToNo: Code[20]; PostAmount: Decimal; PostAmountFCY: Decimal)
    begin
        // P8008663 - add parameter for PostAmountFCY
        with AccrualPostingBuffer do begin
            Init;
            "Posting Date" := AccrualJnlLine."Posting Date";
            "Document No." := AccrualJnlLine."Document No.";
            "Accrual Plan Type" := AccrualJnlLine."Accrual Plan Type";
            if (AccrualPlan."G/L Posting Level" >
                AccrualPlan."G/L Posting Level"::Summarized)
            then begin
                "Accrual Plan No." := AccrualJnlLine."Accrual Plan No.";
                if (AccrualPlan."G/L Posting Level" >
                    AccrualPlan."G/L Posting Level"::Plan)
                then begin
                    "Source No." := AccrualJnlLine."Source No.";
                    if (AccrualPlan."G/L Posting Level" >
                        AccrualPlan."G/L Posting Level"::Source)
                    then begin
                        "Source Document Type" := AccrualJnlLine."Source Document Type";
                        "Source Document No." := AccrualJnlLine."Source Document No.";
                        if (AccrualPlan."G/L Posting Level" >
                            AccrualPlan."G/L Posting Level"::Document)
                        then
                            "Source Document Line No." := AccrualJnlLine."Source Document Line No.";
                    end;
                end;
            end;
            "Entry Type" := AccrualJnlLine."Entry Type";
            "Source Code" := AccrualJnlLine."Source Code";
            "Reason Code" := AccrualJnlLine."Reason Code";
            "External Document No." := AccrualJnlLine."External Document No.";
            Type := PostToType;
            "No." := PostToNo;
            // P8008663
            "Currency Code" := '';
            if Type in [Type::Customer, Type::Vendor] then
                "Currency Code" := AccrualJnlLine."Currency Code";
            // P8008663
            "Dimension Entry No." := AccrualJnlLine."Dimension Set ID"; // P8001133
            "Global Dimension 1 Code" := AccrualJnlLine."Shortcut Dimension 1 Code"; // P8000427A
            "Global Dimension 2 Code" := AccrualJnlLine."Shortcut Dimension 2 Code"; // P8000427A
            if not Find then
                Insert;
            if ("Due Date" = 0D) or (AccrualJnlLine."Due Date" < "Due Date") then
                "Due Date" := AccrualJnlLine."Due Date";
            Amount := Amount + PostAmount;
            "Amount (FCY)" := "Amount (FCY)" + PostAmountFCY; // P8008663
            Modify;
        end;
    end;

    local procedure UpdatePostedDocAccuralLines()
    var
        PostedDocAccrualLine: Record "Posted Document Accrual Line";
    begin
        if (AccrualPlan."Plan Type" <> AccrualPlan."Plan Type"::Reporting) then
            if (AccrualLedgEntry."Source Document Type" <> AccrualLedgEntry."Source Document Type"::None) then
                with PostedDocAccrualLine do begin
                    SetRange("Accrual Plan Type", AccrualLedgEntry."Accrual Plan Type");
                    SetRange("Source Document Type", AccrualLedgEntry."Source Document Type");
                    SetRange("Source Document No.", AccrualLedgEntry."Source Document No.");
                    SetRange("Source Document Line No.", AccrualLedgEntry."Source Document Line No.");
                    SetRange("Accrual Plan No.", AccrualLedgEntry."Accrual Plan No.");
                    DeleteAll;
                end;
    end;

    procedure PostGenJnlLine(var GenJnlLine: Record "Gen. Journal Line"; var AccrualAccountNo: Code[20]; var AccrualLedgEntryNo: Integer)
    begin
        with GenJnlLine do begin
            PrepareToPost("Source Code", "Journal Batch Name");

            AccrualPlan.Get("Accrual Plan Type", "Account No.");
            AccrualPlan.TestField("Accrual Posting Group");
            AccrualPostingGroup.Get(AccrualPlan."Accrual Posting Group");
            //AccrualPostingGroup.TESTFIELD("Accrual Account");        // P80053245
            AccrualAccountNo := AccrualPostingGroup.GetAccrualAccount; // P80053245
            AccrualLedgEntryNo := NextEntryNo;

            AccrualLedgEntry.Init;
            AccrualLedgEntry."Accrual Plan Type" := "Accrual Plan Type";
            AccrualLedgEntry."Accrual Plan No." := "Account No.";
            AccrualLedgEntry."Plan Type" := AccrualPlan."Plan Type";
            AccrualLedgEntry."Posting Date" := "Posting Date";
            AccrualLedgEntry."Document Date" := "Document Date";
            AccrualLedgEntry."Document No." := "Document No.";
            AccrualLedgEntry."External Document No." := "External Document No.";
            AccrualLedgEntry."Entry Type" := "Accrual Entry Type";
            AccrualLedgEntry."Scheduled Accrual No." := "Scheduled Accrual No."; // P8002746
            AccrualLedgEntry."Source No." := "Accrual Source No.";
            if ("Accrual Bal. Acc. Type" > 0) then
                AccrualLedgEntry.Type := "Accrual Bal. Acc. Type" - 1;
            AccrualLedgEntry."No." := "Accrual Bal. Acc. No.";
            AccrualLedgEntry.Description := Description;
            AccrualLedgEntry."Source Document Type" := "Accrual Source Doc. Type";
            AccrualLedgEntry."Source Document No." := "Accrual Source Doc. No.";
            AccrualLedgEntry."Source Document Line No." := "Accrual Source Doc. Line No.";
            AccrualLedgEntry."Item No." := GetItemNo(GenJnlLine);
            AccrualLedgEntry."Price Impact" := AccrualPlan."Price Impact";
            AccrualLedgEntry."Accrual Posting Group" := AccrualPlan."Accrual Posting Group";
            AccrualLedgEntry."Global Dimension 1 Code" := "Shortcut Dimension 1 Code";
            AccrualLedgEntry."Global Dimension 2 Code" := "Shortcut Dimension 2 Code";
            AccrualLedgEntry."Dimension Set ID" := "Dimension Set ID"; // P8001133
            AccrualLedgEntry.Amount := "Amount (LCY)"; // P8008663
            AccrualLedgEntry."Journal Batch Name" := "Journal Batch Name";
            AccrualLedgEntry."Reason Code" := "Reason Code";
            AccrualLedgEntry."No. Series" := "Posting No. Series";
            AccrualLedgEntry."Source Code" := "Source Code";

            AccrualLedgEntry."User ID" := UserId;
            AccrualLedgEntry."Entry No." := AccrualLedgEntryNo;

            AccrualLedgEntry.Insert;

            NextEntryNo := NextEntryNo + 1;

            UpdatePostedDocAccuralLines;
        end;
    end;

    local procedure GetItemNo(var GenJnlLine: Record "Gen. Journal Line"): Code[20]
    var
        SalesShptLine: Record "Sales Shipment Line";
        SalesRcptLine: Record "Return Receipt Line";
        SalesInvLine: Record "Sales Invoice Line";
        SalesCMLine: Record "Sales Cr.Memo Line";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PurchShptLine: Record "Return Shipment Line";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCMLine: Record "Purch. Cr. Memo Line";
    begin
        with GenJnlLine do
            if ("Accrual Source Doc. Line No." <> 0) then
                case "Accrual Plan Type" of
                    "Accrual Plan Type"::Sales:
                        case "Accrual Source Doc. Type" of
                            "Accrual Source Doc. Type"::Shipment:
                                begin
                                    SalesShptLine.Get("Accrual Source Doc. No.", "Accrual Source Doc. Line No.");
                                    SalesShptLine.TestField(Type, SalesShptLine.Type::Item);
                                    exit(SalesShptLine."No.");
                                end;
                            "Accrual Source Doc. Type"::Receipt:
                                begin
                                    SalesRcptLine.Get("Accrual Source Doc. No.", "Accrual Source Doc. Line No.");
                                    SalesRcptLine.TestField(Type, SalesRcptLine.Type::Item);
                                    exit(SalesRcptLine."No.");
                                end;
                            "Accrual Source Doc. Type"::Invoice:
                                begin
                                    SalesInvLine.Get("Accrual Source Doc. No.", "Accrual Source Doc. Line No.");
                                    SalesInvLine.TestField(Type, SalesInvLine.Type::Item);
                                    exit(SalesInvLine."No.");
                                end;
                            "Accrual Source Doc. Type"::"Credit Memo":
                                begin
                                    SalesCMLine.Get("Accrual Source Doc. No.", "Accrual Source Doc. Line No.");
                                    SalesCMLine.TestField(Type, SalesCMLine.Type::Item);
                                    exit(SalesCMLine."No.");
                                end;
                        end;
                    "Accrual Plan Type"::Purchase:
                        case "Accrual Source Doc. Type" of
                            "Accrual Source Doc. Type"::Receipt:
                                begin
                                    PurchRcptLine.Get("Accrual Source Doc. No.", "Accrual Source Doc. Line No.");
                                    PurchRcptLine.TestField(Type, PurchRcptLine.Type::Item);
                                    exit(PurchRcptLine."No.");
                                end;
                            "Accrual Source Doc. Type"::Shipment:
                                begin
                                    PurchShptLine.Get("Accrual Source Doc. No.", "Accrual Source Doc. Line No.");
                                    PurchShptLine.TestField(Type, PurchShptLine.Type::Item);
                                    exit(PurchShptLine."No.");
                                end;
                            "Accrual Source Doc. Type"::Invoice:
                                begin
                                    PurchInvLine.Get("Accrual Source Doc. No.", "Accrual Source Doc. Line No.");
                                    PurchInvLine.TestField(Type, PurchInvLine.Type::Item);
                                    exit(PurchInvLine."No.");
                                end;
                            "Accrual Source Doc. Type"::"Credit Memo":
                                begin
                                    PurchCMLine.Get("Accrual Source Doc. No.", "Accrual Source Doc. Line No.");
                                    PurchCMLine.TestField(Type, PurchCMLine.Type::Item);
                                    exit(PurchCMLine."No.");
                                end;
                        end;
                end;
        exit('');
    end;

    procedure PrePost()
    begin
        AccrualLedgEntry.LockTable;
        AccrualReg.LockTable;
    end;

    procedure PrePostGenJnlBatch(var GenJnlLine: Record "Gen. Journal Line")
    var
        GenJnlLine2: Record "Gen. Journal Line";
        AccrualLineFound: Boolean;
    begin
        GenJnlLine2.Copy(GenJnlLine);
        with GenJnlLine2 do begin
            SetRange("Account Type", "Account Type"::FOODAccrualPlan);
            SetFilter("Account No.", '<>%1', '');
            if Find('-') then
                AccrualLineFound := true
            else begin
                SetRange("Account Type");
                SetRange("Account No.");
                SetRange("Bal. Account Type", "Bal. Account Type"::FOODAccrualPlan);
                SetFilter("Bal. Account No.", '<>%1', '');
                AccrualLineFound := Find('-');
            end;
        end;
        if AccrualLineFound then
            PrePost;
    end;

    procedure PrePostPurchDoc(var PurchLine: Record "Purchase Line")
    var
        PurchLine2: Record "Purchase Line";
    begin
        PurchLine2.Copy(PurchLine);
        with PurchLine2 do begin
            SetRange(Type, Type::FOODAccrualPlan);
            SetFilter("No.", '<>%1', '');
            if Find('-') then
                PrePost;
        end;
    end;

    procedure GetPostBuffer(var PostBuffer: Record "Accrual Posting Buffer")
    var
        DimBuffer: Record "Dimension Buffer" temporary;
    begin
        // P8000852
        PostBuffer.Reset;
        PostBuffer.DeleteAll;
        if AccrualPostingBuffer.Find('-') then begin
            repeat
                PostBuffer := AccrualPostingBuffer;
                PostBuffer.Insert;
            until AccrualPostingBuffer.Next = 0;
            //AccrualPostingBuffer.GetAllDimensions(DimBuffer); // P8001133
            //PostBuffer.SetAllDimensions(DimBuffer);           // P8001133
        end;
    end;
}

