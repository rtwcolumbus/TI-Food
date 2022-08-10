codeunit 37002132 "Accrual Field Management"
{
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PR4.00.01
    // P8000274A, VerticalSoft, Jack Reynolds, 22 DEC 05
    //   Fix problems with resolving start and end dates for plan
    // 
    // PR4.00.06
    // P8000464A, VerticalSoft, Don Bresee, 9 APR 07
    //   Fixes relating to Combine Shipment & Combine Return Receipts functions
    // 
    // PRW15.00.03
    // P8000628A, VerticalSoft, Jack Reynolds, 25 AUG 08
    //   Fix text overflow problem with accrual plan name
    // 
    // PRW16.00.02
    // P8000743, VerticalSoft, Jack Reynolds, 19 NOV 09
    //   Fix key issues with source document lookup functions
    // 
    // PRW17.10.03
    // P8001308, Columbus IT, Jack Reynolds, 01 APR 14
    //   Fix problem posting purcahse lines with type of Accrual Plan
    // 
    // PRW18.00.02
    // P8002742, To-Increase, Jack Reynolds, 30 Sep 15
    //   Support for accrual payment documents
    // 
    // P8002743, To-Increase, Jack Reynolds, 30 Sep 15
    //   Support for accrual payment documents
    // 
    // P8002744, To-Increase, Jack Reynolds, 30 Sep 15
    //   Support for accrual payment documents
    // 
    // P8002745, To-Increase, Jack Reynolds, 30 Sep 15
    //   Support for accrual payment documents
    // 
    // PRW19.00
    // P8005495, To-Increase, Jack Reynolds, 20 NOV 15
    //   Fix problem with wrong dates (posting date vs. order date)
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.02
    // P80068489, To Increase, Gangabhushan, 31 DEC 18
    //   TI-12522 - VAT issues for accruals process
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW119.0
    // P800133109, To Increase, Jack Reynolds, 9 DEC 21
    //   Invoice Posting Buffer

    Permissions = TableData "Job Journal Template" = imd,
                  TableData "Job Journal Batch" = imd;

    trigger OnRun()
    begin
    end;

    var
        AccrualPostLine: Codeunit "Accrual Jnl.-Post Line";
        Text000: Label '%1 is not a valid source on %2 for %3 %4.';
        Text001: Label '%1 is not a valid source for %2 %3.';
        Text002: Label '%1/%2 is not a valid source/ship-to on %3 for %4 %5.';
        Text003: Label '%1/%2 is not a valid source/ship-to for %3 %4.';
        Text004: Label '%1 is not a valid item on %2 for %3 %4.';
        Text005: Label '%1 is not a valid item for %2 %3.';
        Text006: Label 'No accrual entries exist for %1 %2.';

    procedure GenJnlValidate(FldNo: Integer; OldGenJnlLine: Record "Gen. Journal Line"; var GenJnlLine: Record "Gen. Journal Line")
    var
        AccrualPlan: Record "Accrual Plan";
        AccrualScheduleLine: Record "Accrual Plan Schedule Line";
        BillToPayToNo: Code[20];
        ItemNo: Code[20];
        DueDate: Date;
    begin
        with GenJnlLine do
            case FldNo of
                FieldNo("Account Type"),
                FieldNo("Bal. Account Type"):
                    begin
                        if ("Account Type" = "Account Type"::FOODAccrualPlan) then
                            if not ("Bal. Account Type" in
                                    ["Bal. Account Type"::"G/L Account",
                                     "Bal. Account Type"::Customer,
                                     "Bal. Account Type"::Vendor])
                            then
                                FieldError("Bal. Account Type");
                        if ("Bal. Account Type" = "Bal. Account Type"::FOODAccrualPlan) then
                            if not ("Account Type" in
                                    ["Account Type"::"G/L Account",
                                     "Account Type"::Customer,
                                     "Account Type"::Vendor])
                            then
                                FieldError("Account Type");
                    end;
                FieldNo("Account No."):
                    if ("Account No." <> OldGenJnlLine."Account No.") then
                        if ("Account No." <> '') then
                            if GetLineAccrualPlan(GenJnlLine, AccrualPlan) then begin
                                SetGenJnlDefaults(FieldNo("Account No."), GenJnlLine, AccrualPlan);
                                if ("Account Type" = "Account Type"::FOODAccrualPlan) then
                                    Description := AccrualPlan.Name;
                            end;
                FieldNo("Bal. Account No."):
                    if ("Bal. Account No." <> OldGenJnlLine."Bal. Account No.") then
                        if ("Bal. Account No." <> '') then
                            if GetLineAccrualPlan(GenJnlLine, AccrualPlan) then begin
                                SetGenJnlDefaults(FieldNo("Bal. Account No."), GenJnlLine, AccrualPlan);
                                if ("Account No." = '') and ("Bal. Account Type" = "Bal. Account Type"::FOODAccrualPlan) then
                                    Description := AccrualPlan.Name;
                            end;
                FieldNo("Accrual Entry Type"):
                    TestField("Accrual Entry Type", "Accrual Entry Type"::Payment);
                FieldNo("Accrual Bal. Acc. Type"):
                    ;
                FieldNo("Accrual Bal. Acc. No."):
                    ;
                FieldNo("Accrual Source No."):
                    begin
                        if ("Accrual Source No." <> OldGenJnlLine."Accrual Source No.") then
                            Validate("Accrual Source Doc. No.", '');
                        if ("Accrual Source No." <> '') then begin
                            if ("Bal. Account Type" = "Bal. Account Type"::FOODAccrualPlan) then
                                TestField("Bal. Account No.")
                            else begin
                                TestField("Account Type", "Account Type"::FOODAccrualPlan);
                                TestField("Account No.");
                            end;
                            GetLineAccrualPlan(GenJnlLine, AccrualPlan);
                            AccrualPlan.CheckPostingLevel(
                              "Accrual Entry Type", AccrualPlan."Accrual Posting Level"::Source);
                            CheckSource(
                              AccrualPlan, "Accrual Entry Type",               // P8000274A
                              "Accrual Source No.", "Accrual Source No.", 0D); // P8000274A
                        end;
                    end;
                FieldNo("Accrual Source Doc. Type"):
                    begin
                        if ("Accrual Source Doc. Type" <> OldGenJnlLine."Accrual Source Doc. Type") then
                            Validate("Accrual Source Doc. No.", '');
                        if ("Accrual Source Doc. Type" <> "Accrual Source Doc. Type"::None) then begin
                            if ("Bal. Account Type" = "Bal. Account Type"::FOODAccrualPlan) then
                                TestField("Bal. Account No.")
                            else begin
                                TestField("Account Type", "Account Type"::FOODAccrualPlan);
                                TestField("Account No.");
                            end;
                            GetLineAccrualPlan(GenJnlLine, AccrualPlan);
                            AccrualPlan.CheckPostingLevel(
                              "Accrual Entry Type", AccrualPlan."Accrual Posting Level"::Document);
                            CheckSourceDocType(AccrualPlan, "Accrual Entry Type", "Accrual Source Doc. Type");
                        end;
                    end;
                FieldNo("Accrual Source Doc. No."):
                    begin
                        if ("Accrual Source Doc. No." <> OldGenJnlLine."Accrual Source Doc. No.") then
                            Validate("Accrual Source Doc. Line No.", 0);
                        if ("Accrual Source Doc. No." <> '') then begin
                            TestField("Accrual Source No.");
                            if ("Accrual Source Doc. Type" = "Accrual Source Doc. Type"::None) then
                                FieldError("Accrual Source Doc. Type");
                            GetLineAccrualPlan(GenJnlLine, AccrualPlan);
                            AccrualPlan.CheckPostingLevel(
                              "Accrual Entry Type", AccrualPlan."Accrual Posting Level"::Document);
                            CheckSourceDocNo(
                              AccrualPlan, "Accrual Entry Type", "Accrual Source Doc. Type",
                              "Accrual Source Doc. No.", BillToPayToNo, DueDate);
                        end;
                    end;
                FieldNo("Accrual Source Doc. Line No."):
                    if ("Accrual Source Doc. Line No." <> 0) then begin
                        TestField("Accrual Source Doc. No.");
                        GetLineAccrualPlan(GenJnlLine, AccrualPlan);
                        AccrualPlan.CheckPostingLevel(
                          "Accrual Entry Type", AccrualPlan."Accrual Posting Level"::"Document Line");
                        CheckSourceDocLineNo(
                          AccrualPlan, "Accrual Entry Type", "Accrual Source Doc. Type", "Accrual Source Doc. No.",
                          "Accrual Source Doc. Line No.", ItemNo, "Gen. Bus. Posting Group", "Gen. Prod. Posting Group", "VAT Prod. Posting Group", true); // P80068489
                    end;
                // P8002746
                FieldNo("Scheduled Accrual No."):
                    if "Scheduled Accrual No." <> '' then begin
                        GetLineAccrualPlan(GenJnlLine, AccrualPlan);
                        AccrualPlan.TestField("Use Payment Schedule", true);
                        AccrualScheduleLine.SetRange("Accrual Plan Type", AccrualPlan.Type);
                        AccrualScheduleLine.SetRange("Accrual Plan No.", AccrualPlan."No.");
                        AccrualScheduleLine.SetRange("Entry Type", AccrualScheduleLine."Entry Type"::Payment);
                        AccrualScheduleLine.SetRange("No.", "Scheduled Accrual No.");
                        AccrualScheduleLine.FindFirst;
                    end;
                    // P8002746
            end;
    end;

    procedure GetAccrualPlan(PlanNo: Code[20]; var AccrualPlan: Record "Accrual Plan"): Boolean
    begin
        with AccrualPlan do begin
            Reset;
            if (PlanNo = '') then
                exit(false);
            SetRange("No.", PlanNo);
            exit(Find('-'));
        end;
    end;

    procedure GetLineAccrualPlan(var GenJnlLine: Record "Gen. Journal Line"; var AccrualPlan: Record "Accrual Plan"): Boolean
    begin
        with GenJnlLine do begin
            if ("Account Type" = "Account Type"::FOODAccrualPlan) then
                exit(GetAccrualPlan("Account No.", AccrualPlan));
            if ("Bal. Account Type" = "Bal. Account Type"::FOODAccrualPlan) then
                exit(GetAccrualPlan("Bal. Account No.", AccrualPlan));
            exit(false);
        end;
    end;

    procedure GetGenJnlDescription(AccNo: Code[20]; var AccDesription: Text[100])
    var
        AccrualPlan: Record "Accrual Plan";
    begin
        // P8000628A - AccDescription changed to Text[50]
        if GetAccrualPlan(AccNo, AccrualPlan) then
            AccDesription := AccrualPlan.Name;
    end;

    local procedure SetGenJnlDefaults(FldNo: Integer; var GenJnlLine: Record "Gen. Journal Line"; var AccrualPlan: Record "Accrual Plan")
    begin
        with GenJnlLine do begin
            "Accrual Plan Type" := AccrualPlan.Type;
            case "Accrual Entry Type" of
                "Accrual Entry Type"::Accrual:
                    FieldError("Accrual Entry Type");
                "Accrual Entry Type"::Payment:
                    case FldNo of
                        FieldNo("Account No."):
                            if ("Bal. Account Type" = "Bal. Account Type"::FOODAccrualPlan) then begin
                                Validate("Accrual Bal. Acc. Type", AccTypeTOPmtType("Account Type"));
                                Validate("Accrual Bal. Acc. No.", "Account No.");
                            end else
                                if (AccrualPlan."Payment Type" in
                                    [AccrualPlan."Payment Type"::Customer,
                                     AccrualPlan."Payment Type"::Vendor,
                                     AccrualPlan."Payment Type"::"G/L Account"])
                       then begin
                                    Validate("Bal. Account Type", PmtTypeTOAccType(AccrualPlan));
                                    Validate("Bal. Account No.", AccrualPlan."Payment Code");
                                end;
                        FieldNo("Bal. Account No."):
                            if ("Account Type" = "Account Type"::FOODAccrualPlan) then begin
                                Validate("Accrual Bal. Acc. Type", AccTypeTOPmtType("Bal. Account Type"));
                                Validate("Accrual Bal. Acc. No.", "Bal. Account No.");
                            end else begin
                                Validate("Accrual Bal. Acc. Type", AccTypeTOPmtType("Account Type"));
                                Validate("Accrual Bal. Acc. No.", "Account No.");
                            end;
                    end;
            end;
            if (AccrualPlan.GetPostingLevel("Accrual Entry Type") <
                AccrualPlan."Payment Posting Level"::Document)
            then
                Validate("Accrual Source Doc. Type", "Accrual Source Doc. Type"::None)
            else begin
                if (AccrualPlan."Source Selection" = AccrualPlan."Source Selection"::Specific) then
                    Validate("Accrual Source No.", AccrualPlan."Source Code")
                else
                    Validate("Accrual Source No.", '');
                if (AccrualPlan.Accrue = AccrualPlan.Accrue::"Shipments/Receipts") then
                    Validate(
                      "Accrual Source Doc. Type", "Accrual Source Doc. Type"::Shipment + "Accrual Plan Type")
                else
                    Validate(
                      "Accrual Source Doc. Type", "Accrual Source Doc. Type"::Invoice);
            end;
        end;
    end;

    local procedure PmtTypeTOAccType(var AccrualPlan: Record "Accrual Plan"): Integer
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        with AccrualPlan do
            case "Payment Type" of
                "Payment Type"::Customer:
                    exit(GenJnlLine."Account Type"::Customer);
                "Payment Type"::Vendor:
                    exit(GenJnlLine."Account Type"::Vendor);
                "Payment Type"::"G/L Account":
                    exit(GenJnlLine."Account Type"::"G/L Account");
            end;
        exit(0);
    end;

    local procedure AccTypeTOPmtType(AccType: Integer): Integer
    var
        AccrualPlan: Record "Accrual Plan";
        GenJnlLine: Record "Gen. Journal Line";
    begin
        with GenJnlLine do
            case AccType of
                "Account Type"::"G/L Account":
                    exit(AccrualPlan."Payment Type"::"G/L Account");
                "Account Type"::Customer:
                    exit(AccrualPlan."Payment Type"::Customer);
                "Account Type"::Vendor:
                    exit(AccrualPlan."Payment Type"::Vendor);
            end;
        exit(0);
    end;

    procedure GenJnlLookupSourceDoc(var GenJnlLine: Record "Gen. Journal Line"; var Text: Text[1024]): Boolean
    begin
        with GenJnlLine do begin
            if ("Account Type" = "Account Type"::FOODAccrualPlan) and ("Account No." <> '') then
                exit(LookupSourceDoc(
                  "Accrual Plan Type", "Account No.", "Accrual Source No.", "Accrual Source Doc. Type", Text));
            if ("Bal. Account Type" = "Bal. Account Type"::FOODAccrualPlan) and ("Bal. Account No." <> '') then
                exit(LookupSourceDoc(
                  "Accrual Plan Type", "Bal. Account No.", "Accrual Source No.", "Accrual Source Doc. Type", Text));
            exit(false);
        end;
    end;

    procedure GenJnlLookupSourceDocLine(var GenJnlLine: Record "Gen. Journal Line"; var Text: Text[1024]): Boolean
    begin
        with GenJnlLine do begin
            if ("Account Type" = "Account Type"::FOODAccrualPlan) and ("Account No." <> '') then
                exit(LookupSourceDocLine(
                  "Accrual Plan Type", "Account No.", "Accrual Source No.",
                  "Accrual Source Doc. Type", "Accrual Source Doc. No.", Text));
            if ("Bal. Account Type" = "Bal. Account Type"::FOODAccrualPlan) and ("Bal. Account No." <> '') then
                exit(LookupSourceDocLine(
                  "Accrual Plan Type", "Bal. Account No.", "Accrual Source No.",
                  "Accrual Source Doc. Type", "Accrual Source Doc. No.", Text));
            exit(false);
        end;
    end;

    procedure DocumentLineLookupNo(var Text: Text[1024]): Boolean
    var
        AccrualPlan: Record "Accrual Plan";
        AccrualPlanList: Page "Accrual Plan List";
    begin
        // P8002744 - renamed from SalesLineLookupNo
        AccrualPlanList.SetTableView(AccrualPlan);
        if GetAccrualPlan(Text, AccrualPlan) then
            AccrualPlanList.SetRecord(AccrualPlan);
        AccrualPlanList.LookupMode(true);
        if (AccrualPlanList.RunModal <> ACTION::LookupOK) then
            exit(false);
        AccrualPlanList.GetRecord(AccrualPlan);
        Text := AccrualPlan."No.";
        exit(true);
    end;

    procedure PurchLineValidate(FldNo: Integer; OldPurchLine: Record "Purchase Line"; var PurchLine: Record "Purchase Line")
    var
        AccrualPlan: Record "Accrual Plan";
        AccrualJnlLine: Record "Accrual Journal Line";
        AccrualPostingGroup: Record "Accrual Posting Group";
        AccrualScheduleLine: Record "Accrual Plan Schedule Line";
        AccrualLedger: Record "Accrual Ledger Entry";
        BillToPayToNo: Code[20];
        ItemNo: Code[20];
        DueDate: Date;
        GenProductPostingGroup: Record "Gen. Product Posting Group";
    begin
        with PurchLine do
            case FldNo of
                FieldNo("No."):
                    if (Type = Type::FOODAccrualPlan) then begin
                        GetAccrualPlan("No.", AccrualPlan);
                        "Accrual Plan Type" := AccrualPlan.Type;
                        Description := AccrualPlan.Name;
                        // P8001308
                        AccrualPlan.TestField("Accrual Posting Group");
                        AccrualPostingGroup.Get(AccrualPlan."Accrual Posting Group");
                        AccrualPostingGroup.TestField("Gen. Prod. Posting Group");
                        "Gen. Prod. Posting Group" := AccrualPostingGroup."Gen. Prod. Posting Group";
                        // P8001308
                        // P80068489
                        GenProductPostingGroup.Get(AccrualPostingGroup."Gen. Prod. Posting Group");
                        Validate("VAT Prod. Posting Group", GenProductPostingGroup."Def. VAT Prod. Posting Group");
                        // P80068489
                        "Tax Area Code" := '';
                        "Tax Liable" := false;
                        "Allow Invoice Disc." := false;
                        "Allow Item Charge Assignment" := false;
                        if (AccrualPlan."Payment Posting Level" < AccrualPlan."Payment Posting Level"::Document) then
                            Validate("Accrual Source Doc. Type", "Accrual Source Doc. Type"::None)
                        else begin
                            if (AccrualPlan."Source Selection" = AccrualPlan."Source Selection"::Specific) then
                                Validate("Accrual Source No.", AccrualPlan."Source Code")
                            else
                                Validate("Accrual Source No.", '');
                            if (AccrualPlan.Accrue = AccrualPlan.Accrue::"Shipments/Receipts") then
                                Validate(
                                  "Accrual Source Doc. Type", "Accrual Source Doc. Type"::Shipment + "Accrual Plan Type")
                            else
                                Validate(
                                  "Accrual Source Doc. Type", "Accrual Source Doc. Type"::Invoice);
                        end;
                        CheckAccrualEntriesExistForSource('PLAN', FieldCaption("No."), AccrualPlan.Type, "No.", '', 0, '', 0); // P8003742
                    end;
                FieldNo("Accrual Source No."):
                    begin
                        if ("Accrual Source No." <> OldPurchLine."Accrual Source No.") then
                            Validate("Accrual Source Doc. No.", '');
                        if ("Accrual Source No." <> '') then begin
                            TestField(Type, Type::FOODAccrualPlan);
                            TestField("No.");
                            GetAccrualPlan("No.", AccrualPlan);
                            AccrualPlan.CheckPostingLevel(
                              AccrualJnlLine."Entry Type"::Payment, AccrualPlan."Accrual Posting Level"::Source);
                            CheckSource(
                              AccrualPlan, AccrualJnlLine."Entry Type"::Payment,
                              "Accrual Source No.", "Accrual Source No.", 0D); // P8000274A
                        end;
                        CheckAccrualEntriesExistForSource('SOURCE', FieldCaption("Accrual Source No."), AccrualPlan.Type, "No.", "Accrual Source No.", 0, '', 0); // P8003742
                    end;
                FieldNo("Accrual Source Doc. Type"):
                    begin
                        if ("Accrual Source Doc. Type" <> OldPurchLine."Accrual Source Doc. Type") then
                            Validate("Accrual Source Doc. No.", '');
                        if ("Accrual Source Doc. Type" <> "Accrual Source Doc. Type"::None) then begin
                            TestField(Type, Type::FOODAccrualPlan);
                            TestField("No.");
                            GetAccrualPlan("No.", AccrualPlan);
                            AccrualPlan.CheckPostingLevel(
                              AccrualJnlLine."Entry Type"::Payment, AccrualPlan."Accrual Posting Level"::Document);
                            CheckSourceDocType(
                              AccrualPlan, AccrualJnlLine."Entry Type"::Payment, "Accrual Source Doc. Type");
                        end;
                    end;
                FieldNo("Accrual Source Doc. No."):
                    begin
                        if ("Accrual Source Doc. No." <> OldPurchLine."Accrual Source Doc. No.") then
                            Validate("Accrual Source Doc. Line No.", 0);
                        if ("Accrual Source Doc. No." <> '') then begin
                            TestField("Accrual Source No.");
                            if ("Accrual Source Doc. Type" = "Accrual Source Doc. Type"::None) then
                                FieldError("Accrual Source Doc. Type");
                            GetAccrualPlan("No.", AccrualPlan);
                            AccrualPlan.CheckPostingLevel(
                              AccrualJnlLine."Entry Type"::Payment, AccrualPlan."Accrual Posting Level"::Document);
                            CheckSourceDocNo(
                              AccrualPlan, AccrualJnlLine."Entry Type"::Payment, "Accrual Source Doc. Type",
                              "Accrual Source Doc. No.", BillToPayToNo, DueDate);
                        end;
                        // P8003742
                        CheckAccrualEntriesExistForSource('DOC', FieldCaption("Accrual Source Doc. No."), AccrualPlan.Type, "No.", "Accrual Source No.",
                          "Accrual Source Doc. Type", "Accrual Source Doc. No.", 0);
                        // P8003742
                    end;
                FieldNo("Accrual Source Doc. Line No."):
                    if ("Accrual Source Doc. Line No." <> 0) then begin
                        TestField("Accrual Source Doc. No.");
                        GetAccrualPlan("No.", AccrualPlan);
                        AccrualPlan.CheckPostingLevel(
                          AccrualJnlLine."Entry Type"::Payment, AccrualPlan."Accrual Posting Level"::"Document Line");
                        CheckSourceDocLineNo(
                          AccrualPlan, AccrualJnlLine."Entry Type"::Payment, "Accrual Source Doc. Type",
                          "Accrual Source Doc. No.", "Accrual Source Doc. Line No.", ItemNo,
                          "Gen. Bus. Posting Group", "Gen. Prod. Posting Group", "VAT Prod. Posting Group", false); // P80068489
                        Validate("VAT Prod. Posting Group"); // P80068489
                                                             // P8003742
                        CheckAccrualEntriesExistForSource('DOC LINE', FieldCaption("Accrual Source Doc. Line No."), AccrualPlan.Type, "No.", "Accrual Source No.",
                          "Accrual Source Doc. Type", "Accrual Source Doc. No.", "Accrual Source Doc. Line No.");
                        // P8003742
                    end;
                // P8002746
                FieldNo("Scheduled Accrual No."):
                    if "Scheduled Accrual No." <> '' then begin
                        GetAccrualPlan("No.", AccrualPlan);
                        AccrualPlan.TestField("Use Payment Schedule", true);
                        AccrualScheduleLine.SetRange("Accrual Plan Type", AccrualPlan.Type);
                        AccrualScheduleLine.SetRange("Accrual Plan No.", AccrualPlan."No.");
                        AccrualScheduleLine.SetRange("Entry Type", AccrualScheduleLine."Entry Type"::Payment);
                        AccrualScheduleLine.SetRange("No.", "Scheduled Accrual No.");
                        AccrualScheduleLine.FindFirst;
                        CheckAccrualEntriesExistForSource('PLAN', FieldCaption("No."), AccrualPlan.Type, "No.", '', 0, '', 0); // P8003742
                    end;
                    // P8002746
            end;
    end;

    procedure PurchPostCheckLine(var PurchLine: Record "Purchase Line")
    var
        AccrualPlan: Record "Accrual Plan";
        AccrualPostingGroup: Record "Accrual Posting Group";
    begin
        with PurchLine do
            AccrualPlan.Get("Accrual Plan Type", "No.");
        AccrualPlan.TestField("Accrual Posting Group");
        AccrualPostingGroup.Get(AccrualPlan."Accrual Posting Group");
        AccrualPostingGroup.TestField("Accrual Account");
    end;

    procedure PurchPrePost(var PurchLine: Record "Purchase Line")
    var
        PurchLine2: Record "Purchase Line";
    begin
        PurchLine2.Copy(PurchLine);
        with PurchLine2 do begin
            SetRange(Type, Type::FOODAccrualPlan);
            SetFilter("No.", '<>%1', '');
            if Find('-') then
                AccrualPostLine.PrePost;
        end;
    end;

    procedure PurchPostPrepareGenJnlLine(var PurchHeader: Record "Purchase Header"; AccrualLineNo: Integer; var GenJnlLine: Record "Gen. Journal Line")
    var
        PurchLine: Record "Purchase Line";
    begin
        with GenJnlLine do begin
            "Account Type" := "Account Type"::FOODAccrualPlan;
            "Accrual Entry Type" := "Accrual Entry Type"::Payment;
            "Accrual Bal. Acc. Type" := "Accrual Bal. Acc. Type"::Vendor;

            PurchLine.Get(PurchHeader."Document Type", PurchHeader."No.", AccrualLineNo);
            "Accrual Plan Type" := PurchLine."Accrual Plan Type";
            "Accrual Bal. Acc. No." := PurchLine."Buy-from Vendor No.";
            "Accrual Source No." := PurchLine."Accrual Source No.";
            "Accrual Source Doc. Type" := PurchLine."Accrual Source Doc. Type";
            "Accrual Source Doc. No." := PurchLine."Accrual Source Doc. No.";
            "Accrual Source Doc. Line No." := PurchLine."Accrual Source Doc. Line No.";
            "Scheduled Accrual No." := PurchLine."Scheduled Accrual No."; // P8002746
        end;
    end;

    procedure PurchPostUpdatePostingBuffer(var InvPostingBuffer: Record "Invoice Post. Buffer"; var PurchLine: Record "Purchase Line")
    begin
        InvPostingBuffer."Accrual Line No." := PurchLine."Line No.";
    end;

    // P800133109
    procedure PurchPostUpdatePostingBuffer(var InvPostingBuffer: Record "Invoice Posting Buffer"; var PurchLine: Record "Purchase Line")
    begin
        InvPostingBuffer."FOOD Accrual Line No." := PurchLine."Line No.";
    end;
    
    procedure SalesLineValidate(FldNo: Integer; OldSalesLine: Record "Sales Line"; var SalesLine: Record "Sales Line")
    var
        AccrualPlan: Record "Accrual Plan";
        AccrualJnlLine: Record "Accrual Journal Line";
        AccrualPostingGroup: Record "Accrual Posting Group";
        AccrualScheduleLine: Record "Accrual Plan Schedule Line";
        AccrualLedger: Record "Accrual Ledger Entry";
        BillToPayToNo: Code[20];
        ItemNo: Code[20];
        DueDate: Date;
        GenProductPostingGroup: Record "Gen. Product Posting Group";
    begin
        // P8002744
        with SalesLine do
            case FldNo of
                FieldNo("No."):
                    if (Type = Type::FOODAccrualPlan) then begin
                        GetAccrualPlan("No.", AccrualPlan);
                        "Accrual Plan Type" := AccrualPlan.Type;
                        Description := AccrualPlan.Name;
                        AccrualPlan.TestField("Accrual Posting Group");
                        AccrualPostingGroup.Get(AccrualPlan."Accrual Posting Group");
                        AccrualPostingGroup.TestField("Gen. Prod. Posting Group");
                        "Gen. Prod. Posting Group" := AccrualPostingGroup."Gen. Prod. Posting Group";
                        // P80068489
                        GenProductPostingGroup.Get(AccrualPostingGroup."Gen. Prod. Posting Group");
                        Validate("VAT Prod. Posting Group", GenProductPostingGroup."Def. VAT Prod. Posting Group");
                        // P80068489
                        "Tax Area Code" := '';
                        "Tax Liable" := false;
                        "Allow Invoice Disc." := false;
                        "Allow Item Charge Assignment" := false;
                        if (AccrualPlan."Payment Posting Level" < AccrualPlan."Payment Posting Level"::Document) then
                            Validate("Accrual Source Doc. Type", "Accrual Source Doc. Type"::None)
                        else begin
                            if (AccrualPlan."Source Selection" = AccrualPlan."Source Selection"::Specific) then
                                Validate("Accrual Source No.", AccrualPlan."Source Code")
                            else
                                Validate("Accrual Source No.", '');
                            if (AccrualPlan.Accrue = AccrualPlan.Accrue::"Shipments/Receipts") then
                                Validate(
                                  "Accrual Source Doc. Type", "Accrual Source Doc. Type"::Shipment + "Accrual Plan Type")
                            else
                                Validate(
                                  "Accrual Source Doc. Type", "Accrual Source Doc. Type"::Invoice);
                        end;
                        CheckAccrualEntriesExistForSource('PLAN', FieldCaption("No."), AccrualPlan.Type, "No.", '', 0, '', 0);
                    end;
                FieldNo("Accrual Source No."):
                    begin
                        if ("Accrual Source No." <> OldSalesLine."Accrual Source No.") then
                            Validate("Accrual Source Doc. No.", '');
                        if ("Accrual Source No." <> '') then begin
                            TestField(Type, Type::FOODAccrualPlan);
                            TestField("No.");
                            GetAccrualPlan("No.", AccrualPlan);
                            AccrualPlan.CheckPostingLevel(
                              AccrualJnlLine."Entry Type"::Payment, AccrualPlan."Accrual Posting Level"::Source);
                            CheckSource(
                              AccrualPlan, AccrualJnlLine."Entry Type"::Payment,
                              "Accrual Source No.", "Accrual Source No.", 0D);
                        end;
                        CheckAccrualEntriesExistForSource('SOURCE', FieldCaption("Accrual Source No."), AccrualPlan.Type, "No.", "Accrual Source No.", 0, '', 0);
                    end;
                FieldNo("Accrual Source Doc. Type"):
                    begin
                        if ("Accrual Source Doc. Type" <> OldSalesLine."Accrual Source Doc. Type") then
                            Validate("Accrual Source Doc. No.", '');
                        if ("Accrual Source Doc. Type" <> "Accrual Source Doc. Type"::None) then begin
                            TestField(Type, Type::FOODAccrualPlan);
                            TestField("No.");
                            GetAccrualPlan("No.", AccrualPlan);
                            AccrualPlan.CheckPostingLevel(
                              AccrualJnlLine."Entry Type"::Payment, AccrualPlan."Accrual Posting Level"::Document);
                            CheckSourceDocType(
                              AccrualPlan, AccrualJnlLine."Entry Type"::Payment, "Accrual Source Doc. Type");
                        end;
                    end;
                FieldNo("Accrual Source Doc. No."):
                    begin
                        if ("Accrual Source Doc. No." <> OldSalesLine."Accrual Source Doc. No.") then
                            Validate("Accrual Source Doc. Line No.", 0);
                        if ("Accrual Source Doc. No." <> '') then begin
                            TestField("Accrual Source No.");
                            if ("Accrual Source Doc. Type" = "Accrual Source Doc. Type"::None) then
                                FieldError("Accrual Source Doc. Type");
                            GetAccrualPlan("No.", AccrualPlan);
                            AccrualPlan.CheckPostingLevel(
                              AccrualJnlLine."Entry Type"::Payment, AccrualPlan."Accrual Posting Level"::Document);
                            CheckSourceDocNo(
                              AccrualPlan, AccrualJnlLine."Entry Type"::Payment, "Accrual Source Doc. Type",
                              "Accrual Source Doc. No.", BillToPayToNo, DueDate);
                        end;
                        CheckAccrualEntriesExistForSource('DOC', FieldCaption("Accrual Source Doc. No."), AccrualPlan.Type, "No.", "Accrual Source No.",
                          "Accrual Source Doc. Type", "Accrual Source Doc. No.", 0);
                    end;
                FieldNo("Accrual Source Doc. Line No."):
                    if ("Accrual Source Doc. Line No." <> 0) then begin
                        TestField("Accrual Source Doc. No.");
                        GetAccrualPlan("No.", AccrualPlan);
                        AccrualPlan.CheckPostingLevel(
                          AccrualJnlLine."Entry Type"::Payment, AccrualPlan."Accrual Posting Level"::"Document Line");
                        CheckSourceDocLineNo(
                          AccrualPlan, AccrualJnlLine."Entry Type"::Payment, "Accrual Source Doc. Type",
                          "Accrual Source Doc. No.", "Accrual Source Doc. Line No.", ItemNo,
                          "Gen. Bus. Posting Group", "Gen. Prod. Posting Group", "VAT Prod. Posting Group", false); // P80068489
                        Validate("VAT Prod. Posting Group"); // P80068489
                        CheckAccrualEntriesExistForSource('DOC LINE', FieldCaption("Accrual Source Doc. Line No."), AccrualPlan.Type, "No.", "Accrual Source No.",
                          "Accrual Source Doc. Type", "Accrual Source Doc. No.", "Accrual Source Doc. Line No.");
                    end;
                FieldNo("Scheduled Accrual No."):
                    if "Scheduled Accrual No." <> '' then begin
                        GetAccrualPlan("No.", AccrualPlan);
                        AccrualPlan.TestField("Use Payment Schedule", true);
                        AccrualScheduleLine.SetRange("Accrual Plan Type", AccrualPlan.Type);
                        AccrualScheduleLine.SetRange("Accrual Plan No.", AccrualPlan."No.");
                        AccrualScheduleLine.SetRange("Entry Type", AccrualScheduleLine."Entry Type"::Payment);
                        AccrualScheduleLine.SetRange("No.", "Scheduled Accrual No.");
                        AccrualScheduleLine.FindFirst;
                        CheckAccrualEntriesExistForSource('PLAN', FieldCaption("No."), AccrualPlan.Type, "No.", '', 0, '', 0); // P8003742
                    end;
            end;
    end;

    procedure SalesPostCheckLine(var SalesLine: Record "Sales Line")
    var
        AccrualPlan: Record "Accrual Plan";
        AccrualPostingGroup: Record "Accrual Posting Group";
    begin
        // P8002744
        with SalesLine do
            AccrualPlan.Get("Accrual Plan Type", "No.");
        AccrualPlan.TestField("Accrual Posting Group");
        AccrualPostingGroup.Get(AccrualPlan."Accrual Posting Group");
        AccrualPostingGroup.TestField("Accrual Account");
    end;

    procedure SalesPrePost(var SalesLine: Record "Sales Line")
    var
        SalesLine2: Record "Sales Line";
    begin
        // P8002744
        SalesLine2.Copy(SalesLine);
        with SalesLine2 do begin
            SetRange(Type, Type::FOODAccrualPlan);
            SetFilter("No.", '<>%1', '');
            if Find('-') then
                AccrualPostLine.PrePost;
        end;
    end;

    procedure SalesPostPrepareGenJnlLine(var SalesHeader: Record "Sales Header"; AccrualLineNo: Integer; var GenJnlLine: Record "Gen. Journal Line")
    var
        SalesLine: Record "Sales Line";
    begin
        // P8002744
        with GenJnlLine do begin
            "Account Type" := "Account Type"::FOODAccrualPlan;
            "Accrual Entry Type" := "Accrual Entry Type"::Payment;
            "Accrual Bal. Acc. Type" := "Accrual Bal. Acc. Type"::Customer;

            SalesLine.Get(SalesHeader."Document Type", SalesHeader."No.", AccrualLineNo);
            "Accrual Plan Type" := SalesLine."Accrual Plan Type";
            "Accrual Bal. Acc. No." := SalesLine."Sell-to Customer No.";
            "Accrual Source No." := SalesLine."Accrual Source No.";
            "Accrual Source Doc. Type" := SalesLine."Accrual Source Doc. Type";
            "Accrual Source Doc. No." := SalesLine."Accrual Source Doc. No.";
            "Accrual Source Doc. Line No." := SalesLine."Accrual Source Doc. Line No.";
            "Scheduled Accrual No." := SalesLine."Scheduled Accrual No."; // P8002746
        end;
    end;

    procedure SalesPostUpdatePostingBuffer(var InvPostingBuffer: Record "Invoice Post. Buffer"; var SalesLine: Record "Sales Line")
    begin
        // P8002744
        InvPostingBuffer."Accrual Line No." := SalesLine."Line No.";
    end;

    // P800133109
    procedure SalesPostUpdatePostingBuffer(var InvPostingBuffer: Record "Invoice Posting Buffer"; var SalesLine: Record "Sales Line")
    begin
        // P8002744
        InvPostingBuffer."FOOD Accrual Line No." := SalesLine."Line No.";
    end;

    local procedure CheckAccrualEntriesExistForSource(Fld: Code[10]; FldCaption: Text; PlanType: Integer; PlanNo: Code[20]; SourceNo: Code[20]; SourceDocType: Integer; SourceDocNo: Code[20]; SourceDocLineNo: Integer)
    var
        AccrualLedger: Record "Accrual Ledger Entry";
    begin
        AccrualLedger.SetRange("Entry Type", AccrualLedger."Entry Type"::Accrual);
        AccrualLedger.SetRange("Accrual Plan Type", PlanType);
        AccrualLedger.SetRange("Accrual Plan No.", PlanNo);

        case Fld of
            'PLAN':
                if PlanNo <> '' then begin
                    if AccrualLedger.IsEmpty then
                        Error(Text006, FldCaption, PlanNo);
                end;

            'SOURCE':
                if SourceNo <> '' then begin
                    AccrualLedger.SetRange(Type, PlanType);
                    AccrualLedger.SetRange("Source No.", SourceNo);
                    if AccrualLedger.IsEmpty then
                        Error(Text006, FldCaption, SourceNo);
                end;

            'DOC':
                if SourceDocNo <> '' then begin
                    AccrualLedger.SetRange("Source Document Type", SourceDocType);
                    AccrualLedger.SetRange("Source Document No.", SourceDocNo);
                    if AccrualLedger.IsEmpty then
                        Error(Text006, FldCaption, SourceDocNo);
                end;

            'DOC LINE':
                if SourceDocLineNo <> 0 then begin
                    AccrualLedger.SetRange("Source Document Type", SourceDocType);
                    AccrualLedger.SetRange("Source Document No.", SourceDocNo);
                    AccrualLedger.SetRange("Source Document Line No.", SourceDocLineNo);
                    if AccrualLedger.IsEmpty then
                        Error(Text006, FldCaption, SourceDocLineNo);
                end;
        end;
    end;

    procedure CheckSource(var AccrualPlan: Record "Accrual Plan"; EntryType: Integer; BillToPayToNo: Code[20]; SellToBuyFromNo: Code[20]; TransactionDate: Date)
    var
        AccrualJnlLine: Record "Accrual Journal Line";
    begin
        // P8000274A - add parameter TransactionDate
        with AccrualPlan do begin
            if (EntryType = AccrualJnlLine."Entry Type"::Payment) then
                if EntriesExist(GetPlanSource(BillToPayToNo, SellToBuyFromNo), 0, '', 0, '') then
                    exit;

            // P8000274A
            if not IsSourceInPlan(BillToPayToNo, SellToBuyFromNo, TransactionDate) then
                if (TransactionDate <> 0D) then
                    Error(Text000,
                      GetPlanSource(BillToPayToNo, SellToBuyFromNo), TransactionDate, TableCaption, "No.")
                else
                    Error(Text001, GetPlanSource(BillToPayToNo, SellToBuyFromNo), TableCaption, "No.");
            // P8000274A
        end;
    end;

    local procedure CheckShipTo(var AccrualPlan: Record "Accrual Plan"; EntryType: Integer; SourceNo: Code[20]; ShipToCode: Code[20]; TransactionDate: Date)
    var
        AccrualJnlLine: Record "Accrual Journal Line";
    begin
        // P8000274A - add parameter TransactionDate
        with AccrualPlan do
            if (EntryType = AccrualJnlLine."Entry Type"::Accrual) and
               ("Source Selection Type" = "Source Selection Type"::"Sell-to/Ship-to")
            then
                // P8000274A
                if not IsShipToInPlan(SourceNo, ShipToCode, TransactionDate) then
                    if (TransactionDate <> 0D) then
                        Error(Text002, SourceNo, ShipToCode, TransactionDate, TableCaption, "No.")
                    else
                        Error(Text003, SourceNo, ShipToCode, TableCaption, "No.");
        // P8000274A
    end;

    procedure CheckSourceDocType(var AccrualPlan: Record "Accrual Plan"; EntryType: Integer; SourceDocType: Integer)
    var
        AccrualJnlLine: Record "Accrual Journal Line";
    begin
        with AccrualPlan do begin
            if (SourceDocType <> AccrualJnlLine."Source Document Type"::None) then
                CheckPostingLevel(EntryType, "Accrual Posting Level"::Document);
            case SourceDocType of
                AccrualJnlLine."Source Document Type"::Shipment,
              AccrualJnlLine."Source Document Type"::Receipt:
                    TestField(Accrue, Accrue::"Shipments/Receipts");
                AccrualJnlLine."Source Document Type"::Invoice,
              AccrualJnlLine."Source Document Type"::"Credit Memo":
                    if (Accrue = Accrue::"Shipments/Receipts") then
                        FieldError(Accrue);
            end;
        end;
    end;

    procedure CheckSourceDocNo(var AccrualPlan: Record "Accrual Plan"; EntryType: Integer; SourceDocType: Integer; SourceDocNo: Code[20]; var BillToPayToNo: Code[20]; var DueDate: Date)
    var
        AccrualJnlLine: Record "Accrual Journal Line";
        SalesShptHeader: Record "Sales Shipment Header";
        SalesRcptHeader: Record "Return Receipt Header";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCMHeader: Record "Sales Cr.Memo Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchShptHeader: Record "Return Shipment Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCMHeader: Record "Purch. Cr. Memo Hdr.";
    begin
        case AccrualPlan.Type of
            AccrualPlan.Type::Sales:
                case SourceDocType of
                    AccrualJnlLine."Source Document Type"::Shipment:
                        with SalesShptHeader do begin
                            Get(SourceDocNo);
                            CheckSource(                                                                               // P8000274A
                              AccrualPlan, EntryType, "Bill-to Customer No.", "Sell-to Customer No.", "Posting Date"); // P8000274A
                            CheckShipTo(                                                                               // P8000274A
                              AccrualPlan, EntryType, "Sell-to Customer No.", "Ship-to Code", "Posting Date");         // P8000274A
                            BillToPayToNo := "Bill-to Customer No.";
                            DueDate := "Due Date";
                        end;
                    AccrualJnlLine."Source Document Type"::Receipt:
                        with SalesRcptHeader do begin
                            Get(SourceDocNo);
                            CheckSource(                                                                               // P8000274A
                              AccrualPlan, EntryType, "Bill-to Customer No.", "Sell-to Customer No.", "Posting Date"); // P8000274A
                            CheckShipTo(                                                                               // P8000274A
                              AccrualPlan, EntryType, "Sell-to Customer No.", "Ship-to Code", "Posting Date");         // P8000274A
                            BillToPayToNo := "Bill-to Customer No.";
                            DueDate := "Due Date";
                        end;
                    AccrualJnlLine."Source Document Type"::Invoice:
                        with SalesInvHeader do begin
                            Get(SourceDocNo);
                            // P8000464A
                            if (AccrualPlan."Source Selection Type" =
                                AccrualPlan."Source Selection Type"::"Bill-to/Pay-to")
                            then
                                CheckSource(AccrualPlan, EntryType, "Bill-to Customer No.", '', "Posting Date");
                            /*
                            CheckSource(                                                                               // P8000274A
                              AccrualPlan, EntryType, "Bill-to Customer No.", "Sell-to Customer No.", "Posting Date"); // P8000274A
                            CheckShipTo(                                                                               // P8000274A
                              AccrualPlan, EntryType, "Sell-to Customer No.", "Ship-to Code", "Posting Date");         // P8000274A
                            */
                            // P8000464A
                            BillToPayToNo := "Bill-to Customer No.";
                            DueDate := "Due Date";
                        end;
                    AccrualJnlLine."Source Document Type"::"Credit Memo":
                        with SalesCMHeader do begin
                            Get(SourceDocNo);
                            // P8000464A
                            if (AccrualPlan."Source Selection Type" =
                                AccrualPlan."Source Selection Type"::"Bill-to/Pay-to")
                            then
                                CheckSource(AccrualPlan, EntryType, "Bill-to Customer No.", '', "Posting Date");
                            /*
                            CheckSource(                                                                               // P8000274A
                              AccrualPlan, EntryType, "Bill-to Customer No.", "Sell-to Customer No.", "Posting Date"); // P8000274A
                            CheckShipTo(                                                                               // P8000274A
                              AccrualPlan, EntryType, "Sell-to Customer No.", "Ship-to Code", "Posting Date");         // P8000274A
                            */
                            // P8000464A
                            BillToPayToNo := "Bill-to Customer No.";
                            DueDate := "Due Date";
                        end;
                end;
            AccrualPlan.Type::Purchase:
                case SourceDocType of
                    AccrualJnlLine."Source Document Type"::Receipt:
                        with PurchRcptHeader do begin
                            Get(SourceDocNo);
                            CheckSource(                                                                           // P8000274A
                              AccrualPlan, EntryType, "Pay-to Vendor No.", "Buy-from Vendor No.", "Posting Date"); // P8000274A
                            BillToPayToNo := "Pay-to Vendor No.";
                            DueDate := "Due Date";
                        end;
                    AccrualJnlLine."Source Document Type"::Shipment:
                        with PurchShptHeader do begin
                            Get(SourceDocNo);
                            CheckSource(                                                                           // P8000274A
                              AccrualPlan, EntryType, "Pay-to Vendor No.", "Buy-from Vendor No.", "Posting Date"); // P8000274A
                            BillToPayToNo := "Pay-to Vendor No.";
                            DueDate := "Due Date";
                        end;
                    AccrualJnlLine."Source Document Type"::Invoice:
                        with PurchInvHeader do begin
                            Get(SourceDocNo);
                            CheckSource(                                                                           // P8000274A
                              AccrualPlan, EntryType, "Pay-to Vendor No.", "Buy-from Vendor No.", "Posting Date"); // P8000274A
                            BillToPayToNo := "Pay-to Vendor No.";
                            DueDate := "Due Date";
                        end;
                    AccrualJnlLine."Source Document Type"::"Credit Memo":
                        with PurchCMHeader do begin
                            Get(SourceDocNo);
                            CheckSource(                                                                           // P8000274A
                              AccrualPlan, EntryType, "Pay-to Vendor No.", "Buy-from Vendor No.", "Posting Date"); // P8000274A
                            BillToPayToNo := "Pay-to Vendor No.";
                            DueDate := "Due Date";
                        end;
                end;
        end;

    end;

    procedure CheckSourceDocLineNo(var AccrualPlan: Record "Accrual Plan"; EntryType: Integer; SourceDocType: Integer; SourceDocNo: Code[20]; SourceDocLineNo: Integer; var ItemNo: Code[20]; var GenBusPostingGroup: Code[20]; var GenProdPostingGroup: Code[20]; var VATProdPostingGroup: Code[20]; OverridePostGrps: Boolean)
    var
        SourceNo: Code[20];
        AccrualJnlLine: Record "Accrual Journal Line";
        SalesShptLine: Record "Sales Shipment Line";
        SalesRcptLine: Record "Return Receipt Line";
        SalesInvLine: Record "Sales Invoice Line";
        SalesCMLine: Record "Sales Cr.Memo Line";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PurchShptLine: Record "Return Shipment Line";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCMLine: Record "Purch. Cr. Memo Line";
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        OriginalBusPostingGroup: Code[20];
        OriginalProdPostingGroup: Code[20];
    begin
        // P80053245 - Enalarge GenBusPostingGroup, GenProdPostingGroup
        // P80068489
        OriginalBusPostingGroup := GenBusPostingGroup;
        OriginalProdPostingGroup := GenProdPostingGroup;
        // P80068489
        case AccrualPlan.Type of
            AccrualPlan.Type::Sales:
                case SourceDocType of
                    AccrualJnlLine."Source Document Type"::Shipment:
                        with SalesShptLine do begin
                            Get(SourceDocNo, SourceDocLineNo);
                            TestField(Type, Type::Item);
                            ItemNo := "No.";
                            CheckItem(
                              AccrualPlan, EntryType, SourceNo, SourceDocType, SourceDocNo, SourceDocLineNo, ItemNo);
                            GenBusPostingGroup := "Gen. Bus. Posting Group";
                            GenProdPostingGroup := "Gen. Prod. Posting Group";
                        end;
                    AccrualJnlLine."Source Document Type"::Receipt:
                        with SalesRcptLine do begin
                            Get(SourceDocNo, SourceDocLineNo);
                            TestField(Type, Type::Item);
                            ItemNo := "No.";
                            CheckItem(
                              AccrualPlan, EntryType, SourceNo, SourceDocType, SourceDocNo, SourceDocLineNo, ItemNo);
                            GenBusPostingGroup := "Gen. Bus. Posting Group";
                            GenProdPostingGroup := "Gen. Prod. Posting Group";
                        end;
                    AccrualJnlLine."Source Document Type"::Invoice:
                        with SalesInvLine do begin
                            Get(SourceDocNo, SourceDocLineNo);
                            // P8000464A
                            if (AccrualPlan."Source Selection Type" <>
                                AccrualPlan."Source Selection Type"::"Bill-to/Pay-to")
                            then begin
                                CheckSource(
                                  AccrualPlan, EntryType, "Bill-to Customer No.",
                                  "Sell-to Customer No.", GetSourceDocDate(AccrualPlan, SourceDocType, SourceDocNo));
                                CheckShipTo(
                                  AccrualPlan, EntryType, "Sell-to Customer No.",
                                  GetSalesInvShipToCode(SalesInvLine),
                                  GetSourceDocDate(AccrualPlan, SourceDocType, SourceDocNo))
                            end;
                            // P8000464A
                            TestField(Type, Type::Item);
                            ItemNo := "No.";
                            CheckItem(
                              AccrualPlan, EntryType, SourceNo, SourceDocType, SourceDocNo, SourceDocLineNo, ItemNo);
                            GenBusPostingGroup := "Gen. Bus. Posting Group";
                            GenProdPostingGroup := "Gen. Prod. Posting Group";
                        end;
                    AccrualJnlLine."Source Document Type"::"Credit Memo":
                        with SalesCMLine do begin
                            Get(SourceDocNo, SourceDocLineNo);
                            // P8000464A
                            if (AccrualPlan."Source Selection Type" <>
                                AccrualPlan."Source Selection Type"::"Bill-to/Pay-to")
                            then begin
                                CheckSource(
                                  AccrualPlan, EntryType, "Bill-to Customer No.",
                                  "Sell-to Customer No.", GetSourceDocDate(AccrualPlan, SourceDocType, SourceDocNo));
                                CheckShipTo(
                                  AccrualPlan, EntryType, "Sell-to Customer No.",
                                  GetSalesCMShipToCode(SalesCMLine),
                                  GetSourceDocDate(AccrualPlan, SourceDocType, SourceDocNo))
                            end;
                            // P8000464A
                            TestField(Type, Type::Item);
                            ItemNo := "No.";
                            CheckItem(
                              AccrualPlan, EntryType, SourceNo, SourceDocType, SourceDocNo, SourceDocLineNo, ItemNo);
                            GenBusPostingGroup := "Gen. Bus. Posting Group";
                            GenProdPostingGroup := "Gen. Prod. Posting Group";
                        end;
                end;
            AccrualPlan.Type::Purchase:
                case SourceDocType of
                    AccrualJnlLine."Source Document Type"::Receipt:
                        with PurchRcptLine do begin
                            Get(SourceDocNo, SourceDocLineNo);
                            TestField(Type, Type::Item);
                            ItemNo := "No.";
                            CheckItem(
                              AccrualPlan, EntryType, SourceNo, SourceDocType, SourceDocNo, SourceDocLineNo, ItemNo);
                            GenBusPostingGroup := "Gen. Bus. Posting Group";
                            GenProdPostingGroup := "Gen. Prod. Posting Group";
                        end;
                    AccrualJnlLine."Source Document Type"::Shipment:
                        with PurchShptLine do begin
                            Get(SourceDocNo, SourceDocLineNo);
                            TestField(Type, Type::Item);
                            ItemNo := "No.";
                            CheckItem(
                              AccrualPlan, EntryType, SourceNo, SourceDocType, SourceDocNo, SourceDocLineNo, ItemNo);
                            GenBusPostingGroup := "Gen. Bus. Posting Group";
                            GenProdPostingGroup := "Gen. Prod. Posting Group";
                        end;
                    AccrualJnlLine."Source Document Type"::Invoice:
                        with PurchInvLine do begin
                            Get(SourceDocNo, SourceDocLineNo);
                            TestField(Type, Type::Item);
                            ItemNo := "No.";
                            CheckItem(
                              AccrualPlan, EntryType, SourceNo, SourceDocType, SourceDocNo, SourceDocLineNo, ItemNo);
                            GenBusPostingGroup := "Gen. Bus. Posting Group";
                            GenProdPostingGroup := "Gen. Prod. Posting Group";
                        end;
                    AccrualJnlLine."Source Document Type"::"Credit Memo":
                        with PurchCMLine do begin
                            Get(SourceDocNo, SourceDocLineNo);
                            TestField(Type, Type::Item);
                            ItemNo := "No.";
                            CheckItem(
                              AccrualPlan, EntryType, SourceNo, SourceDocType, SourceDocNo, SourceDocLineNo, ItemNo);
                            GenBusPostingGroup := "Gen. Bus. Posting Group";
                            GenProdPostingGroup := "Gen. Prod. Posting Group";
                        end;
                end;
        end;
        // P80068489
        if not OverridePostGrps then begin
            GenBusPostingGroup := OriginalBusPostingGroup;
            GenProdPostingGroup := OriginalProdPostingGroup;
        end;
        if GenProductPostingGroup.Get(GenProdPostingGroup) then
            VATProdPostingGroup := GenProductPostingGroup."Def. VAT Prod. Posting Group";
        // P80068489
    end;

    local procedure GetSourceDocDate(var AccrualPlan: Record "Accrual Plan"; SourceDocType: Integer; SourceDocNo: Code[20]): Date
    var
        AccrualJnlLine: Record "Accrual Journal Line";
        SalesShptHeader: Record "Sales Shipment Header";
        SalesRcptHeader: Record "Return Receipt Header";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCMHeader: Record "Sales Cr.Memo Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchShptHeader: Record "Return Shipment Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCMHeader: Record "Purch. Cr. Memo Hdr.";
    begin
        // P8000274A
        case AccrualPlan.Type of
            AccrualPlan.Type::Sales:
                case SourceDocType of
                    AccrualJnlLine."Source Document Type"::Shipment:
                        with SalesShptHeader do begin
                            Get(SourceDocNo);
                            exit(AccrualPlan.GetDocumentTransactionDate(SalesShptHeader)); // P8005495
                        end;
                    AccrualJnlLine."Source Document Type"::Receipt:
                        with SalesRcptHeader do begin
                            Get(SourceDocNo);
                            exit(AccrualPlan.GetDocumentTransactionDate(SalesRcptHeader)); // P8005495
                        end;
                    AccrualJnlLine."Source Document Type"::Invoice:
                        with SalesInvHeader do begin
                            Get(SourceDocNo);
                            exit(AccrualPlan.GetDocumentTransactionDate(SalesInvHeader)); // P8005495
                        end;
                    AccrualJnlLine."Source Document Type"::"Credit Memo":
                        with SalesCMHeader do begin
                            Get(SourceDocNo);
                            exit(AccrualPlan.GetDocumentTransactionDate(SalesCMHeader)); // P8005495
                        end;
                end;
            AccrualPlan.Type::Purchase:
                case SourceDocType of
                    AccrualJnlLine."Source Document Type"::Receipt:
                        with PurchRcptHeader do begin
                            Get(SourceDocNo);
                            exit(AccrualPlan.GetDocumentTransactionDate(PurchRcptHeader)); // P8005495
                        end;
                    AccrualJnlLine."Source Document Type"::Shipment:
                        with PurchShptHeader do begin
                            Get(SourceDocNo);
                            exit(AccrualPlan.GetDocumentTransactionDate(PurchShptHeader)); // P8005495
                        end;
                    AccrualJnlLine."Source Document Type"::Invoice:
                        with PurchInvHeader do begin
                            Get(SourceDocNo);
                            exit(AccrualPlan.GetDocumentTransactionDate(PurchInvHeader)); // P8005495
                        end;
                    AccrualJnlLine."Source Document Type"::"Credit Memo":
                        with PurchCMHeader do begin
                            Get(SourceDocNo);
                            exit(AccrualPlan.GetDocumentTransactionDate(PurchCMHeader)); // P8005495
                        end;
                end;
        end;
        exit(0D);
    end;

    procedure GetSalesInvShipToCode(var SalesInvLine: Record "Sales Invoice Line"): Code[10]
    var
        SalesInvHeader: Record "Sales Invoice Header";
        SalesShptHeader: Record "Sales Shipment Header";
    begin
        // P8000464A
        with SalesInvLine do
            if ("Shipment No." <> '') then begin
                SalesShptHeader.Get("Shipment No.");
                exit(SalesShptHeader."Ship-to Code");
            end else begin
                SalesInvHeader.Get("Document No.");
                exit(SalesInvHeader."Ship-to Code");
            end;
    end;

    procedure GetSalesCMShipToCode(var SalesCMLine: Record "Sales Cr.Memo Line"): Code[10]
    var
        SalesCMHeader: Record "Sales Cr.Memo Header";
        SalesRcptHeader: Record "Return Receipt Header";
    begin
        // P8000464A
        with SalesCMLine do
            if ("Return Receipt No." <> '') then begin
                SalesRcptHeader.Get("Return Receipt No.");
                exit(SalesRcptHeader."Ship-to Code");
            end else begin
                SalesCMHeader.Get("Document No.");
                exit(SalesCMHeader."Ship-to Code");
            end;
    end;

    procedure CheckItem(var AccrualPlan: Record "Accrual Plan"; EntryType: Integer; SourceNo: Code[20]; SourceDocType: Integer; SourceDocNo: Code[20]; SourceDocLineNo: Integer; ItemNo: Code[20])
    var
        AccrualJnlLine: Record "Accrual Journal Line";
        Item: Record Item;
        TransactionDate: Date;
    begin
        with AccrualPlan do
            if (ItemNo <> '') then begin
                Item.Get(ItemNo);

                if (EntryType = AccrualJnlLine."Entry Type"::Payment) then
                    if EntriesExist(SourceNo, SourceDocType, SourceDocNo, SourceDocLineNo, ItemNo) then
                        exit;

                // P8000274A
                TransactionDate := GetSourceDocDate(AccrualPlan, SourceDocType, SourceDocNo);
                if not IsItemInPlan(ItemNo, TransactionDate) then
                    if (TransactionDate <> 0D) then
                        Error(Text004, ItemNo, TransactionDate, TableCaption, "No.")
                    else
                        Error(Text005, ItemNo, TableCaption, "No.");
                // P8000274A
            end;
    end;

    procedure LookupSourceDoc(AccrualPlanType: Integer; AccrualPlanNo: Code[20]; SourceNo: Code[20]; SourceDocumentType: Integer; var Text: Text[1024]): Boolean
    var
        AccrualPlan: Record "Accrual Plan";
        AccrualJnlLine: Record "Accrual Journal Line";
    begin
        with AccrualJnlLine do begin
            AccrualPlan.Get(AccrualPlanType, AccrualPlanNo);
            case AccrualPlanType of
                "Accrual Plan Type"::Sales:
                    case SourceDocumentType of
                        "Source Document Type"::Shipment:
                            exit(LookupSalesShptHeader(AccrualPlan, SourceNo, Text));
                        "Source Document Type"::Receipt:
                            exit(LookupSalesRcptHeader(AccrualPlan, SourceNo, Text));
                        "Source Document Type"::Invoice:
                            exit(LookupSalesInvHeader(AccrualPlan, SourceNo, Text));
                        "Source Document Type"::"Credit Memo":
                            exit(LookupSalesCMHeader(AccrualPlan, SourceNo, Text));
                    end;
                "Accrual Plan Type"::Purchase:
                    case SourceDocumentType of
                        "Source Document Type"::Receipt:
                            exit(LookupPurchRcptHeader(AccrualPlan, SourceNo, Text));
                        "Source Document Type"::Shipment:
                            exit(LookupPurchShptHeader(AccrualPlan, SourceNo, Text));
                        "Source Document Type"::Invoice:
                            exit(LookupPurchInvHeader(AccrualPlan, SourceNo, Text));
                        "Source Document Type"::"Credit Memo":
                            exit(LookupPurchCMHeader(AccrualPlan, SourceNo, Text));
                    end;
            end;
        end;
    end;

    procedure LookupSourceDocLine(AccrualPlanType: Integer; AccrualPlanNo: Code[20]; SourceNo: Code[20]; SourceDocumentType: Integer; SourceDocumentNo: Code[20]; var Text: Text[1024]): Boolean
    var
        AccrualPlan: Record "Accrual Plan";
        AccrualJnlLine: Record "Accrual Journal Line";
    begin
        with AccrualJnlLine do
            case AccrualPlanType of
                "Accrual Plan Type"::Sales:
                    case SourceDocumentType of
                        "Source Document Type"::Shipment:
                            exit(LookupSalesShptLine(SourceDocumentNo, Text));
                        "Source Document Type"::Receipt:
                            exit(LookupSalesRcptLine(SourceDocumentNo, Text));
                        "Source Document Type"::Invoice:
                            exit(LookupSalesInvLine(SourceDocumentNo, Text));
                        "Source Document Type"::"Credit Memo":
                            exit(LookupSalesCMLine(SourceDocumentNo, Text));
                    end;
                "Accrual Plan Type"::Purchase:
                    case SourceDocumentType of
                        "Source Document Type"::Receipt:
                            exit(LookupPurchRcptLine(SourceDocumentNo, Text));
                        "Source Document Type"::Shipment:
                            exit(LookupPurchShptLine(SourceDocumentNo, Text));
                        "Source Document Type"::Invoice:
                            exit(LookupPurchInvLine(SourceDocumentNo, Text));
                        "Source Document Type"::"Credit Memo":
                            exit(LookupPurchCMLine(SourceDocumentNo, Text));
                    end;
            end;
    end;

    local procedure LookupSalesShptHeader(var AccrualPlan: Record "Accrual Plan"; SourceNo: Code[20]; var Text: Text[1024]): Boolean
    var
        SalesShptHeader: Record "Sales Shipment Header";
    begin
        with AccrualPlan do begin
            case "Date Type" of
                "Date Type"::"Posting Date":
                    begin
                        //SalesShptHeader.SETCURRENTKEY("Posting Date", "Bill-to Customer No.", "Sell-to Customer No."); // P8000743
                        SalesShptHeader.SetFilter("Posting Date", GetTransactionDateFilter());
                    end;
                "Date Type"::"Order Date":
                    begin
                        //SalesShptHeader.SETCURRENTKEY("Order Date", "Bill-to Customer No.", "Sell-to Customer No."); // P8000743
                        SalesShptHeader.SetFilter("Order Date", GetTransactionDateFilter());
                    end;
            end;
            case "Source Selection Type" of
                "Source Selection Type"::"Bill-to/Pay-to":
                    begin                                                    // P8000743
                        SalesShptHeader.SetCurrentKey("Bill-to Customer No."); // P8000743
                        SalesShptHeader.SetRange("Bill-to Customer No.", SourceNo);
                    end;                                                     // P8000743
                "Source Selection Type"::"Sell-to/Buy-from":
                    begin                                                    // P8000743
                        SalesShptHeader.SetCurrentKey("Sell-to Customer No."); // P8000743
                        SalesShptHeader.SetRange("Sell-to Customer No.", SourceNo);
                    end;                                                     // P8000743
                "Source Selection Type"::"Sell-to/Ship-to":
                    begin
                        SalesShptHeader.SetCurrentKey("Sell-to Customer No."); // P8000743
                        SalesShptHeader.SetRange("Sell-to Customer No.", SourceNo);
                        SalesShptHeader.SetRange("Ship-to Code", "Source Ship-to Code");
                    end;
            end;
        end;
        SalesShptHeader.SetFilter("No.", Text);
        if SalesShptHeader.Find('-') then;
        SalesShptHeader.SetRange("No.");
        if (PAGE.RunModal(0, SalesShptHeader) <> ACTION::LookupOK) then
            exit(false);
        Text := SalesShptHeader."No.";
        exit(true);
    end;

    local procedure LookupSalesShptLine(SourceDocumentNo: Code[20]; var Text: Text[1024]): Boolean
    var
        SalesShptLine: Record "Sales Shipment Line";
    begin
        SalesShptLine.SetRange("Document No.", SourceDocumentNo);
        SalesShptLine.SetRange(Type, SalesShptLine.Type::Item);
        SalesShptLine.SetFilter("Line No.", Text);
        if SalesShptLine.Find('-') then;
        SalesShptLine.SetRange("Line No.");
        if (PAGE.RunModal(PAGE::"Posted Sales Shipment Lines", SalesShptLine) <> ACTION::LookupOK) then
            exit(false);
        Text := Format(SalesShptLine."Line No.");
        exit(true);
    end;

    local procedure LookupSalesRcptHeader(var AccrualPlan: Record "Accrual Plan"; SourceNo: Code[20]; var Text: Text[1024]): Boolean
    var
        SalesRcptHeader: Record "Return Receipt Header";
    begin
        with AccrualPlan do begin
            case "Date Type" of
                "Date Type"::"Posting Date":
                    begin
                        //SalesRcptHeader.SETCURRENTKEY("Posting Date", "Bill-to Customer No.", "Sell-to Customer No."); // P8000743
                        SalesRcptHeader.SetFilter("Posting Date", GetTransactionDateFilter());
                    end;
                "Date Type"::"Order Date":
                    begin
                        //SalesRcptHeader.SETCURRENTKEY("Order Date", "Bill-to Customer No.", "Sell-to Customer No."); // P8000743
                        SalesRcptHeader.SetFilter("Order Date", GetTransactionDateFilter());
                    end;
            end;
            case "Source Selection Type" of
                "Source Selection Type"::"Bill-to/Pay-to":
                    begin                                                    // P8000743
                        SalesRcptHeader.SetCurrentKey("Bill-to Customer No."); // P8000743
                        SalesRcptHeader.SetRange("Bill-to Customer No.", SourceNo);
                    end;                                                     // P8000743
                "Source Selection Type"::"Sell-to/Buy-from":
                    begin                                                    // P8000743
                        SalesRcptHeader.SetCurrentKey("Sell-to Customer No."); // P8000743
                        SalesRcptHeader.SetRange("Sell-to Customer No.", SourceNo);
                    end;                                                     // P8000743
                "Source Selection Type"::"Sell-to/Ship-to":
                    begin
                        SalesRcptHeader.SetCurrentKey("Sell-to Customer No."); // P8000743
                        SalesRcptHeader.SetRange("Sell-to Customer No.", SourceNo);
                        SalesRcptHeader.SetRange("Ship-to Code", "Source Ship-to Code");
                    end;
            end;
        end;
        SalesRcptHeader.SetFilter("No.", Text);
        if SalesRcptHeader.Find('-') then;
        SalesRcptHeader.SetRange("No.");
        if (PAGE.RunModal(0, SalesRcptHeader) <> ACTION::LookupOK) then
            exit(false);
        Text := SalesRcptHeader."No.";
        exit(true);
    end;

    local procedure LookupSalesRcptLine(SourceDocumentNo: Code[20]; var Text: Text[1024]): Boolean
    var
        SalesRcptLine: Record "Return Receipt Line";
    begin
        SalesRcptLine.SetRange("Document No.", SourceDocumentNo);
        SalesRcptLine.SetRange(Type, SalesRcptLine.Type::Item);
        SalesRcptLine.SetFilter("Line No.", Text);
        if SalesRcptLine.Find('-') then;
        SalesRcptLine.SetRange("Line No.");
        if (PAGE.RunModal(PAGE::"Posted Return Receipt Lines", SalesRcptLine) <> ACTION::LookupOK) then
            exit(false);
        Text := Format(SalesRcptLine."Line No.");
        exit(true);
    end;

    local procedure LookupSalesInvHeader(var AccrualPlan: Record "Accrual Plan"; SourceNo: Code[20]; var Text: Text[1024]): Boolean
    var
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        with AccrualPlan do begin
            case "Date Type" of
                "Date Type"::"Posting Date":
                    begin
                        //SalesInvHeader.SETCURRENTKEY("Posting Date", "Bill-to Customer No.", "Sell-to Customer No."); // P8000743
                        SalesInvHeader.SetFilter("Posting Date", GetTransactionDateFilter());
                    end;
                "Date Type"::"Order Date":
                    begin
                        //SalesInvHeader.SETCURRENTKEY("Order Date", "Bill-to Customer No.", "Sell-to Customer No."); // P8000743
                        SalesInvHeader.SetFilter("Order Date", GetTransactionDateFilter());
                    end;
            end;
            case "Source Selection Type" of
                "Source Selection Type"::"Bill-to/Pay-to":
                    begin                                                   // P8000743
                        SalesInvHeader.SetCurrentKey("Bill-to Customer No."); // P8000743
                        SalesInvHeader.SetRange("Bill-to Customer No.", SourceNo);
                    end;                                                    // P8000743
                "Source Selection Type"::"Sell-to/Buy-from":
                    begin                                                   // P8000743
                        SalesInvHeader.SetCurrentKey("Sell-to Customer No."); // P8000743
                        SalesInvHeader.SetRange("Sell-to Customer No.", SourceNo);
                    end;                                                    // P8000743
                "Source Selection Type"::"Sell-to/Ship-to":
                    begin
                        SalesInvHeader.SetCurrentKey("Sell-to Customer No."); // P8000743
                        SalesInvHeader.SetRange("Sell-to Customer No.", SourceNo);
                        SalesInvHeader.SetRange("Ship-to Code", "Source Ship-to Code");
                    end;
            end;
        end;
        SalesInvHeader.SetFilter("No.", Text);
        if SalesInvHeader.Find('-') then;
        SalesInvHeader.SetRange("No.");
        if (PAGE.RunModal(0, SalesInvHeader) <> ACTION::LookupOK) then
            exit(false);
        Text := SalesInvHeader."No.";
        exit(true);
    end;

    local procedure LookupSalesInvLine(SourceDocumentNo: Code[20]; var Text: Text[1024]): Boolean
    var
        SalesInvLine: Record "Sales Invoice Line";
    begin
        SalesInvLine.SetRange("Document No.", SourceDocumentNo);
        SalesInvLine.SetRange(Type, SalesInvLine.Type::Item);
        SalesInvLine.SetFilter("Line No.", Text);
        if SalesInvLine.Find('-') then;
        SalesInvLine.SetRange("Line No.");
        if (PAGE.RunModal(PAGE::"Posted Sales Invoice Lines", SalesInvLine) <> ACTION::LookupOK) then
            exit(false);
        Text := Format(SalesInvLine."Line No.");
        exit(true);
    end;

    local procedure LookupSalesCMHeader(var AccrualPlan: Record "Accrual Plan"; SourceNo: Code[20]; var Text: Text[1024]): Boolean
    var
        SalesCMHeader: Record "Sales Cr.Memo Header";
    begin
        with AccrualPlan do begin
            case "Date Type" of
                "Date Type"::"Posting Date":
                    begin
                        //SalesCMHeader.SETCURRENTKEY("Posting Date", "Bill-to Customer No.", "Sell-to Customer No."); // P8000743
                        SalesCMHeader.SetFilter("Posting Date", GetTransactionDateFilter());
                    end;
                    /*
                    "Date Type"::"Order Date" :
                      BEGIN
                        //SalesCMHeader.SETCURRENTKEY("Order Date", "Bill-to Customer No.", "Sell-to Customer No."); // P8000743
                        SalesCMHeader.SETFILTER("Order Date", GetTransactionDateFilter());
                      END;
                    */
            end;
            case "Source Selection Type" of
                "Source Selection Type"::"Bill-to/Pay-to":
                    begin                                                  // P8000743
                        SalesCMHeader.SetCurrentKey("Bill-to Customer No."); // P8000743
                        SalesCMHeader.SetRange("Bill-to Customer No.", SourceNo);
                    end;                                                   // P8000743
                "Source Selection Type"::"Sell-to/Buy-from":
                    begin                                                  // P8000743
                        SalesCMHeader.SetCurrentKey("Sell-to Customer No."); // P8000743
                        SalesCMHeader.SetRange("Sell-to Customer No.", SourceNo);
                    end;                                                   // P8000743
                "Source Selection Type"::"Sell-to/Ship-to":
                    begin
                        SalesCMHeader.SetCurrentKey("Sell-to Customer No."); // P8000743
                        SalesCMHeader.SetRange("Sell-to Customer No.", SourceNo);
                        SalesCMHeader.SetRange("Ship-to Code", "Source Ship-to Code");
                    end;
            end;
        end;
        SalesCMHeader.SetFilter("No.", Text);
        if SalesCMHeader.Find('-') then;
        SalesCMHeader.SetRange("No.");
        if (PAGE.RunModal(0, SalesCMHeader) <> ACTION::LookupOK) then
            exit(false);
        Text := SalesCMHeader."No.";
        exit(true);

    end;

    local procedure LookupSalesCMLine(SourceDocumentNo: Code[20]; var Text: Text[1024]): Boolean
    var
        SalesCMLine: Record "Sales Cr.Memo Line";
    begin
        SalesCMLine.SetRange("Document No.", SourceDocumentNo);
        SalesCMLine.SetRange(Type, SalesCMLine.Type::Item);
        SalesCMLine.SetFilter("Line No.", Text);
        if SalesCMLine.Find('-') then;
        SalesCMLine.SetRange("Line No.");
        if (PAGE.RunModal(PAGE::"Posted Sales Credit Memo Lines", SalesCMLine) <> ACTION::LookupOK) then
            exit(false);
        Text := Format(SalesCMLine."Line No.");
        exit(true);
    end;

    local procedure LookupPurchRcptHeader(var AccrualPlan: Record "Accrual Plan"; SourceNo: Code[20]; var Text: Text[1024]): Boolean
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
    begin
        with AccrualPlan do begin
            case "Date Type" of
                "Date Type"::"Posting Date":
                    begin
                        //PurchRcptHeader.SETCURRENTKEY("Posting Date", "Pay-to Vendor No.", "Buy-from Vendor No."); // P8000743
                        PurchRcptHeader.SetFilter("Posting Date", GetTransactionDateFilter());
                    end;
                "Date Type"::"Order Date":
                    begin
                        //PurchRcptHeader.SETCURRENTKEY("Order Date", "Pay-to Vendor No.", "Buy-from Vendor No."); // P8000743
                        PurchRcptHeader.SetFilter("Order Date", GetTransactionDateFilter());
                    end;
            end;
            case "Source Selection Type" of
                "Source Selection Type"::"Bill-to/Pay-to":
                    begin                                                 // P8000743
                        PurchRcptHeader.SetCurrentKey("Pay-to Vendor No."); // P8000743
                        PurchRcptHeader.SetRange("Pay-to Vendor No.", SourceNo);
                    end;                                                  // P8000743
                "Source Selection Type"::"Sell-to/Buy-from":
                    begin                                                   // P8000743
                        PurchRcptHeader.SetCurrentKey("Buy-from Vendor No."); // P8000743
                        PurchRcptHeader.SetRange("Buy-from Vendor No.", SourceNo);
                    end;                                                    // P8000743
            end;
        end;
        PurchRcptHeader.SetFilter("No.", Text);
        if PurchRcptHeader.Find('-') then;
        PurchRcptHeader.SetRange("No.");
        if (PAGE.RunModal(0, PurchRcptHeader) <> ACTION::LookupOK) then
            exit(false);
        Text := PurchRcptHeader."No.";
        exit(true);
    end;

    local procedure LookupPurchRcptLine(SourceDocumentNo: Code[20]; var Text: Text[1024]): Boolean
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
    begin
        PurchRcptLine.SetRange("Document No.", SourceDocumentNo);
        PurchRcptLine.SetRange(Type, PurchRcptLine.Type::Item);
        PurchRcptLine.SetFilter("Line No.", Text);
        if PurchRcptLine.Find('-') then;
        PurchRcptLine.SetRange("Line No.");
        if (PAGE.RunModal(PAGE::"Posted Purchase Receipt Lines", PurchRcptLine) <> ACTION::LookupOK) then
            exit(false);
        Text := Format(PurchRcptLine."Line No.");
        exit(true);
    end;

    local procedure LookupPurchShptHeader(var AccrualPlan: Record "Accrual Plan"; SourceNo: Code[20]; var Text: Text[1024]): Boolean
    var
        PurchShptHeader: Record "Return Shipment Header";
    begin
        with AccrualPlan do begin
            case "Date Type" of
                "Date Type"::"Posting Date":
                    begin
                        //PurchShptHeader.SETCURRENTKEY("Posting Date", "Pay-to Vendor No.", "Buy-from Vendor No."); // P8000743
                        PurchShptHeader.SetFilter("Posting Date", GetTransactionDateFilter());
                    end;
                    /*
                    "Date Type"::"Order Date" :
                      BEGIN
                        //PurchShptHeader.SETCURRENTKEY("Order Date", "Pay-to Vendor No.", "Buy-from Vendor No."); // P8000743
                        PurchShptHeader.SETFILTER("Order Date", GetTransactionDateFilter());
                      END;
                    */
            end;
            case "Source Selection Type" of
                "Source Selection Type"::"Bill-to/Pay-to":
                    begin                                                 // P8000743
                        PurchShptHeader.SetCurrentKey("Pay-to Vendor No."); // P8000743
                        PurchShptHeader.SetRange("Pay-to Vendor No.", SourceNo);
                    end;                                                  // P8000743
                "Source Selection Type"::"Sell-to/Buy-from":
                    begin                                                   // P8000743
                        PurchShptHeader.SetCurrentKey("Buy-from Vendor No."); // P8000743
                        PurchShptHeader.SetRange("Buy-from Vendor No.", SourceNo);
                    end;                                                    // P8000743
            end;
        end;
        PurchShptHeader.SetFilter("No.", Text);
        if PurchShptHeader.Find('-') then;
        PurchShptHeader.SetRange("No.");
        if (PAGE.RunModal(0, PurchShptHeader) <> ACTION::LookupOK) then
            exit(false);
        Text := PurchShptHeader."No.";
        exit(true);

    end;

    local procedure LookupPurchShptLine(SourceDocumentNo: Code[20]; var Text: Text[1024]): Boolean
    var
        PurchShptLine: Record "Return Shipment Line";
    begin
        PurchShptLine.SetRange("Document No.", SourceDocumentNo);
        PurchShptLine.SetRange(Type, PurchShptLine.Type::Item);
        PurchShptLine.SetFilter("Line No.", Text);
        if PurchShptLine.Find('-') then;
        PurchShptLine.SetRange("Line No.");
        if (PAGE.RunModal(PAGE::"Posted Return Shipment Lines", PurchShptLine) <> ACTION::LookupOK) then
            exit(false);
        Text := Format(PurchShptLine."Line No.");
        exit(true);
    end;

    local procedure LookupPurchInvHeader(var AccrualPlan: Record "Accrual Plan"; SourceNo: Code[20]; var Text: Text[1024]): Boolean
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        with AccrualPlan do begin
            case "Date Type" of
                "Date Type"::"Posting Date":
                    begin
                        //PurchInvHeader.SETCURRENTKEY("Posting Date", "Pay-to Vendor No.", "Buy-from Vendor No."); // P8000743
                        PurchInvHeader.SetFilter("Posting Date", GetTransactionDateFilter());
                    end;
                "Date Type"::"Order Date":
                    begin
                        //PurchInvHeader.SETCURRENTKEY("Order Date", "Pay-to Vendor No.", "Buy-from Vendor No."); // P8000743
                        PurchInvHeader.SetFilter("Order Date", GetTransactionDateFilter());
                    end;
            end;
            case "Source Selection Type" of
                "Source Selection Type"::"Bill-to/Pay-to":
                    begin                                                // P8000743
                        PurchInvHeader.SetCurrentKey("Pay-to Vendor No."); // P8000743
                        PurchInvHeader.SetRange("Pay-to Vendor No.", SourceNo);
                    end;                                                 // P8000743
                "Source Selection Type"::"Sell-to/Buy-from":
                    begin                                                  // P8000743
                        PurchInvHeader.SetCurrentKey("Buy-from Vendor No."); // P8000743
                        PurchInvHeader.SetRange("Buy-from Vendor No.", SourceNo);
                    end;                                                   // P8000743
            end;
        end;
        PurchInvHeader.SetFilter("No.", Text);
        if PurchInvHeader.Find('-') then;
        PurchInvHeader.SetRange("No.");
        if (PAGE.RunModal(0, PurchInvHeader) <> ACTION::LookupOK) then
            exit(false);
        Text := PurchInvHeader."No.";
        exit(true);
    end;

    local procedure LookupPurchInvLine(SourceDocumentNo: Code[20]; var Text: Text[1024]): Boolean
    var
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        PurchInvLine.SetRange("Document No.", SourceDocumentNo);
        PurchInvLine.SetRange(Type, PurchInvLine.Type::Item);
        PurchInvLine.SetFilter("Line No.", Text);
        if PurchInvLine.Find('-') then;
        PurchInvLine.SetRange("Line No.");
        if (PAGE.RunModal(PAGE::"Posted Purchase Invoice Lines", PurchInvLine) <> ACTION::LookupOK) then
            exit(false);
        Text := Format(PurchInvLine."Line No.");
        exit(true);
    end;

    local procedure LookupPurchCMHeader(var AccrualPlan: Record "Accrual Plan"; SourceNo: Code[20]; var Text: Text[1024]): Boolean
    var
        PurchCMHeader: Record "Purch. Cr. Memo Hdr.";
    begin
        with AccrualPlan do begin
            case "Date Type" of
                "Date Type"::"Posting Date":
                    begin
                        //PurchCMHeader.SETCURRENTKEY("Posting Date", "Pay-to Vendor No.", "Buy-from Vendor No."); // P8000743
                        PurchCMHeader.SetFilter("Posting Date", GetTransactionDateFilter());
                    end;
                    /*
                    "Date Type"::"Order Date" :
                      BEGIN
                        //PurchCMHeader.SETCURRENTKEY("Order Date", "Pay-to Vendor No.", "Buy-from Vendor No."); // P8000743
                        PurchCMHeader.SETFILTER("Order Date", GetTransactionDateFilter());
                      END;
                    */
            end;
            case "Source Selection Type" of
                "Source Selection Type"::"Bill-to/Pay-to":
                    begin                                               // P8000743
                        PurchCMHeader.SetCurrentKey("Pay-to Vendor No."); // P8000743
                        PurchCMHeader.SetRange("Pay-to Vendor No.", SourceNo);
                    end;                                                // P8000743
                "Source Selection Type"::"Sell-to/Buy-from":
                    begin                                                 // P8000743
                        PurchCMHeader.SetCurrentKey("Buy-from Vendor No."); // P8000743
                        PurchCMHeader.SetRange("Buy-from Vendor No.", SourceNo);
                    end;                                                  // P8000743
            end;
        end;
        PurchCMHeader.SetFilter("No.", Text);
        if PurchCMHeader.Find('-') then;
        PurchCMHeader.SetRange("No.");
        if (PAGE.RunModal(0, PurchCMHeader) <> ACTION::LookupOK) then
            exit(false);
        Text := PurchCMHeader."No.";
        exit(true);

    end;

    local procedure LookupPurchCMLine(SourceDocumentNo: Code[20]; var Text: Text[1024]): Boolean
    var
        PurchCMLine: Record "Purch. Cr. Memo Line";
    begin
        PurchCMLine.SetRange("Document No.", SourceDocumentNo);
        PurchCMLine.SetRange(Type, PurchCMLine.Type::Item);
        PurchCMLine.SetFilter("Line No.", Text);
        if PurchCMLine.Find('-') then;
        PurchCMLine.SetRange("Line No.");
        if (PAGE.RunModal(PAGE::"Posted Purchase Cr. Memo Lines", PurchCMLine) <> ACTION::LookupOK) then
            exit(false);
        Text := Format(PurchCMLine."Line No.");
        exit(true);
    end;

    procedure UpdateAccrualPlanGLobalDimCode(GlobalDimCodeNo: Integer; PlanNo: Code[20]; NewDimValue: Code[20])
    var
        AccrualPlan: Record "Accrual Plan";
    begin
        // P8001133
        // P8001263 - CustNo renamed to PlanNo
        AccrualPlan.SetRange("No.", PlanNo); // P8001263
        if AccrualPlan.FindFirst then begin // P8001263
            case GlobalDimCodeNo of
                1:
                    AccrualPlan."Global Dimension 1 Code" := NewDimValue;
                2:
                    AccrualPlan."Global Dimension 2 Code" := NewDimValue;
            end;
            AccrualPlan.Modify(true);
        end;
    end;
}

