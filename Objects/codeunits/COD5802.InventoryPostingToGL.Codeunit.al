codeunit 5802 "Inventory Posting To G/L"
{
    // PR3.60
    //   Add logic for alternate quantities
    // 
    // PR3.61.01
    //   Add logic for writeoff accounts
    // 
    // PR3.70.05
    // P8000062B, Myers Nissi, Jack Reynolds, 22 JUN 04
    //   BufferInvtPosting - change call to CalcCostToPost to return extra charges to post; for purchases buffer the extra
    //    charge postings
    //   PostInvtBufPerEntry - with extra charges there may be more than a single G/L entry with a single balancing entry;
    //    therefore set G/L Entry No. (Account) to the first entry and G/L Entry No. (Bal. Account) to the last entry
    //   SetAccNo - get Extra Charge Posting Setup if necessary; use it for Invt. Accrual-EC (Interim) and
    //    Direct Cost Applied-EC
    //   CalcCostToPost - add parameter for extra charge to post; call extra charge management codeunit to calculate
    //    extra charge to post
    //   UpdateInvtPostBuf - blank Extra Charge Code in global inventory posting buffer
    //   UpdateInvtPostBufEC - similar to UpdateInvtPostBuf, but with additional logic for extra charges
    //   UpdateInvtPostBuf2 - increment amount variables instead of setting them; add to existing case statement for Invt.
    //    Accrual-EC (Interim) and Direct Cost Applied-EC
    //   UseECPostingSetup - returns TRUE if account type indicates extra charge posting setup
    // 
    // PR4.00
    // P8000261B, VerticalSoft, Jack Reynolds, 28 OCT 05
    //   Modify to check fro FreshPro granule before call extra charge management codeunit
    // 
    // PR4.00.04
    // P8000375A, VerticalSoft, Jack Reynolds, 08 SEP 06
    //   Support for posting output indirect cost from ABC detail
    // 
    // PR4.00.05
    // P8000413A, VerticalSoft, Jack Reynolds, 02 APR 07
    //   Part of P8000062A was to increment the amount in UpdateInvtPostBuf2 rather than replace them;
    //   this is now standard in SP3
    // 
    // PR4.00.06
    // P8000487A, VerticalSoft, Jack Reynolds, 12 JUN 07
    //   Fix problem with reference to G/L entry number in value entry records
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 31 JUL 07
    //   Modify to support extra charges and ABC detail
    // 
    // PRW16.00.02
    // P8000756, VerticalSoft, Jack Reynolds, 08 JAN 10
    //   InitInvPostBuffer - add Job No. to buffer
    // 
    // PRW16.00.04
    // P8000888, VerticalSoft, Don Bresee, 14 DEC 10
    //   Add logic to handle registers
    // 
    // PRW16.00.05
    // P8000928, Columbus IT, Jack Reynolds, 06 APR 11
    //   Support for extra charges on transfer orders
    // 
    // PRW16.00.06
    // P8001061, Columbus IT, Jack Reynolds, 23 APR 12
    //   Fix posting problem with transfer orders and extra charges
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.00.01
    // P8001195, Columbus IT, Jack Reynolds, 14 AUG 13
    //   Allow variances for positive adjustments
    // 
    // PRW17.10
    // P8001227, Columbus IT, Don Bresee, 03 OCT 13
    //   Add ResetGLReg routine for Adjust Cost Job
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 11 NOV 15
    //   Posting preview
    // 
    // PRW110.0.02
    // P80050651, To-Increase, Jack Reynolds, 05 FEB 18
    //   Allow indirect entries for positive adjustments (for repack)
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    //
    // PRW115.03
    // P800110504, To Increase, Jack Reynolds, 05 NOV 20
    //    Allow variance entries for Lot Combinations

    Permissions = TableData "G/L Account" = r,
                  TableData "Invt. Posting Buffer" = rimd,
                  TableData "Value Entry" = rm,
                  TableData "G/L - Item Ledger Relation" = rimd;
    TableNo = "Value Entry";

    trigger OnRun()
    var
        GenJnlLine: Record "Gen. Journal Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOnRun(Rec, GlobalPostPerPostGroup, IsHandled);
        if IsHandled then
            exit;

        if GlobalPostPerPostGroup then
            PostInvtPostBuf(Rec, "Document No.", '', '', true)
        else
            PostInvtPostBuf(
              Rec,
              "Document No.",
              "External Document No.",
              CopyStr(
                StrSubstNo(Text000, "Entry Type", "Source No.", "Posting Date"),
                1, MaxStrLen(GenJnlLine.Description)),
              false);

        OnAfterRun(Rec);
    end;

    var
        GLSetup: Record "General Ledger Setup";
        InvtSetup: Record "Inventory Setup";
        Currency: Record Currency;
        SourceCodeSetup: Record "Source Code Setup";
        GlobalInvtPostBuf: Record "Invt. Posting Buffer" temporary;
        TempInvtPostBuf: Record "Invt. Posting Buffer" temporary;
        TempInvtPostToGLTestBuf: Record "Invt. Post to G/L Test Buffer" temporary;
        TempGLItemLedgRelation: Record "G/L - Item Ledger Relation" temporary;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
        DimMgt: Codeunit DimensionManagement;
        COGSAmt: Decimal;
        InvtAdjmtAmt: Decimal;
        DirCostAmt: Decimal;
        OvhdCostAmt: Decimal;
        VarPurchCostAmt: Decimal;
        VarMfgDirCostAmt: Decimal;
        VarMfgOvhdCostAmt: Decimal;
        WIPInvtAmt: Decimal;
        InvtAmt: Decimal;
        TotalCOGSAmt: Decimal;
        TotalInvtAdjmtAmt: Decimal;
        TotalDirCostAmt: Decimal;
        TotalOvhdCostAmt: Decimal;
        TotalVarPurchCostAmt: Decimal;
        TotalVarMfgDirCostAmt: Decimal;
        TotalVarMfgOvhdCostAmt: Decimal;
        TotalWIPInvtAmt: Decimal;
        TotalInvtAmt: Decimal;
        GlobalInvtPostBufEntryNo: Integer;
        PostBufDimNo: Integer;
        GLSetupRead: Boolean;
        SourceCodeSetupRead: Boolean;
        InvtSetupRead: Boolean;
        Text000: Label '%1 %2 on %3';
        Text001: Label '%1 - %2, %3,%4,%5,%6';
        Text002: Label 'The following combination %1 = %2, %3 = %4, and %5 = %6 is not allowed.';
        RunOnlyCheck: Boolean;
        RunOnlyCheckSaved: Boolean;
        CalledFromItemPosting: Boolean;
        CalledFromTestReport: Boolean;
        GlobalPostPerPostGroup: Boolean;
        Text003: Label '%1 %2';
        GlobalJnlTemplName: Code[10];
        GlobalJnlBatchName: Code[10];
        ProcessFns: Codeunit "Process 800 Functions";
        ExtraChargeMgmt: Codeunit "Extra Charge Management";
        ValueEntryABCDetail: Record "Value Entry ABC Detail";
        AdditionalPostingCode: Code[20];

    procedure Initialize(PostPerPostGroup: Boolean)
    begin
        GlobalPostPerPostGroup := PostPerPostGroup;
        GlobalInvtPostBufEntryNo := 0;
    end;

    procedure SetGenJnlBatch(JnlTemplName: Code[10]; JnlBatchName: Code[10])
    begin
        GlobalJnlTemplName := JnlTemplName;
        GlobalJnlBatchName := JnlBatchName;
    end;

    procedure SetRunOnlyCheck(SetCalledFromItemPosting: Boolean; SetCheckOnly: Boolean; SetCalledFromTestReport: Boolean)
    begin
        CalledFromItemPosting := SetCalledFromItemPosting;
        RunOnlyCheck := SetCheckOnly;
        CalledFromTestReport := SetCalledFromTestReport;

        TempGLItemLedgRelation.Reset();
        TempGLItemLedgRelation.DeleteAll();
    end;

    procedure BufferInvtPosting(var ValueEntry: Record "Value Entry"): Boolean
    var
        CostToPost: Decimal;
        CostToPostACY: Decimal;
        ExpCostToPost: Decimal;
        ExpCostToPostACY: Decimal;
        PostToGL: Boolean;
        IsHandled: Boolean;
        Result: Boolean;
        ItemLedgerEntry: Record "Item Ledger Entry";
        ECToPost: Record "Extra Charge Posting Buffer" temporary;
        PostABCDetail: Boolean;
        ABCCostToPost: Decimal;
        ABCCostToPostACY: Decimal;
        PostABCToGL: Boolean;
    begin
        IsHandled := false;
        OnBeforeBufferInvtPosting(ValueEntry, Result, IsHandled, RunOnlyCheck, CalledFromTestReport);
        if IsHandled then
            exit(Result);

        with ValueEntry do begin
            GetGLSetup();
            GetInvtSetup;
            if (not InvtSetup."Expected Cost Posting to G/L") and
               ("Expected Cost Posted to G/L" = 0) and
               "Expected Cost"
            then
                exit(false);

            if not ("Entry Type" in ["Entry Type"::"Direct Cost", "Entry Type"::Revaluation]) and
               not CalledFromTestReport
            then begin
                TestField("Expected Cost", false);
                TestField("Cost Amount (Expected)", 0);
                TestField("Cost Amount (Expected) (ACY)", 0);
            end;

            if InvtSetup."Expected Cost Posting to G/L" then begin
                CalcCostToPost(ExpCostToPost, "Cost Amount (Expected)", "Expected Cost Posted to G/L", PostToGL);
                CalcCostToPost(ExpCostToPostACY, "Cost Amount (Expected) (ACY)", "Exp. Cost Posted to G/L (ACY)", PostToGL);
                if ProcessFns.FreshProInstalled then // P8000261B
                    ExtraChargeMgmt.CalcChargeToPost(ECToPost, "Entry No.", true, PostToGL); // PR4.00
            end;
            CalcCostToPost(CostToPost, "Cost Amount (Actual)", "Cost Posted to G/L", PostToGL);
            CalcCostToPost(CostToPostACY, "Cost Amount (Actual) (ACY)", "Cost Posted to G/L (ACY)", PostToGL);
            if ProcessFns.FreshProInstalled then // P8000261B
                ExtraChargeMgmt.CalcChargeToPost(ECToPost, "Entry No.", false, PostToGL); // PR4.00
            OnAfterCalcCostToPostFromBuffer(ValueEntry, CostToPost, CostToPostACY, ExpCostToPost, ExpCostToPostACY, PostToGL);
            PostBufDimNo := 0;

            RunOnlyCheckSaved := RunOnlyCheck;
            if not PostToGL then
                exit(false);

            OnBeforeBufferPosting(ValueEntry, CostToPost, CostToPostACY, ExpCostToPost, ExpCostToPostACY);

            case "Item Ledger Entry Type" of
                "Item Ledger Entry Type"::Purchase:
                    BufferPurchPosting(ValueEntry, CostToPost, CostToPostACY, ExpCostToPost, ExpCostToPostACY, ECToPost); // P8001132
                "Item Ledger Entry Type"::Sale:
                    BufferSalesPosting(ValueEntry, CostToPost, CostToPostACY, ExpCostToPost, ExpCostToPostACY);
                "Item Ledger Entry Type"::"Positive Adjmt.",
                "Item Ledger Entry Type"::"Negative Adjmt.",
                "Item Ledger Entry Type"::Transfer:
                    BufferAdjmtPosting(ValueEntry, CostToPost, CostToPostACY, ExpCostToPost, ExpCostToPostACY, ECToPost); // P8001132
                "Item Ledger Entry Type"::Consumption:
                    BufferConsumpPosting(ValueEntry, CostToPost, CostToPostACY);
                "Item Ledger Entry Type"::Output:
                    BufferOutputPosting(ValueEntry, CostToPost, CostToPostACY, ExpCostToPost, ExpCostToPostACY);
                "Item Ledger Entry Type"::"Assembly Consumption":
                    BufferAsmConsumpPosting(ValueEntry, CostToPost, CostToPostACY);
                "Item Ledger Entry Type"::"Assembly Output":
                    BufferAsmOutputPosting(ValueEntry, CostToPost, CostToPostACY);
                "Item Ledger Entry Type"::" ":
                    BufferCapacityPosting(ValueEntry, CostToPost, CostToPostACY);
                else
                    ErrorNonValidCombination(ValueEntry);
            end;

            OnAfterBufferPosting(ValueEntry, CostToPost, CostToPostACY, ExpCostToPost, ExpCostToPostACY);
        end;

        if UpdateGlobalInvtPostBuf(ValueEntry."Entry No.") then
            exit(true);
        exit(CalledFromTestReport);
    end;

    local procedure BufferPurchPosting(ValueEntry: Record "Value Entry"; CostToPost: Decimal; CostToPostACY: Decimal; ExpCostToPost: Decimal; ExpCostToPostACY: Decimal; var ECToPost: Record "Extra Charge Posting Buffer" temporary)
    var
        IsHandled: Boolean;
    begin
        // P8001132 - add parameter for ECToPost
        OnBeforeBufferPurchPosting(ValueEntry, GlobalInvtPostBuf, CostToPost, CostToPostACY, ExpCostToPost, ExpCostToPostACY, IsHandled);
        if IsHandled then
            exit;

        with ValueEntry do
            case "Entry Type" of
                "Entry Type"::"Direct Cost":
                    begin
                        // PR4.00 Begin
                        if ECToPost.Find('-') then
                            repeat
                                if (ECToPost."Cost To Post (Expected)" <> 0) or (ECToPost."Cost To Post (Expected) (ACY)" <> 0) then begin
                                    // P8000466A
                                    //UpdateInvtPostBufEC(
                                    AdditionalPostingCode := ECToPost."Extra Charge Code";
                                    InitInvtPostBuf(
                                      // P8000466A
                                      ValueEntry,
                                      GlobalInvtPostBuf."Account Type"::"Inventory (Interim)",
                                      GlobalInvtPostBuf."Account Type"::FOODInvtAccrualECInterim,
                                      //ECToPost."Extra Charge Code", // P8000466A
                                      ECToPost."Cost To Post (Expected)", ECToPost."Cost To Post (Expected) (ACY)", true);
                                    ExpCostToPost -= ECToPost."Cost To Post (Expected)";
                                    ExpCostToPostACY -= ECToPost."Cost To Post (Expected) (ACY)";
                                end;
                                if (ECToPost."Cost To Post" <> 0) or (ECToPost."Cost To Post (ACY)" <> 0) then begin
                                    // P8000466A
                                    //UpdateInvtPostBufEC(
                                    AdditionalPostingCode := ECToPost."Extra Charge Code";
                                    InitInvtPostBuf(
                                      // P8000466A
                                      ValueEntry,
                                      GlobalInvtPostBuf."Account Type"::Inventory,
                                      GlobalInvtPostBuf."Account Type"::FOODDirectCostAppliedEC,
                                      //ECToPost."Extra Charge Code", // P8000466A
                                      ECToPost."Cost To Post", ECToPost."Cost To Post (ACY)", false);
                                    CostToPost -= ECToPost."Cost To Post";
                                    CostToPostACY -= ECToPost."Cost To Post (ACY)";
                                end;
                            until ECToPost.Next = 0;
                        // PR4.00 End
                        if (ExpCostToPost <> 0) or (ExpCostToPostACY <> 0) then
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::"Inventory (Interim)",
                              GlobalInvtPostBuf."Account Type"::"Invt. Accrual (Interim)",
                              ExpCostToPost, ExpCostToPostACY, true);
                        if (CostToPost <> 0) or (CostToPostACY <> 0) then
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Direct Cost Applied",
                              CostToPost, CostToPostACY, false);
                    end;
                "Entry Type"::"Indirect Cost":
                    InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"Overhead Applied",
                      CostToPost, CostToPostACY, false);
                "Entry Type"::Variance:
                    begin
                        TestField("Variance Type", "Variance Type"::Purchase);
                        InitInvtPostBuf(
                          ValueEntry,
                          GlobalInvtPostBuf."Account Type"::Inventory,
                          GlobalInvtPostBuf."Account Type"::"Purchase Variance",
                          CostToPost, CostToPostACY, false);
                    end;
                "Entry Type"::Revaluation:
                    begin
                        if (ExpCostToPost <> 0) or (ExpCostToPostACY <> 0) then
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::"Inventory (Interim)",
                              GlobalInvtPostBuf."Account Type"::"Invt. Accrual (Interim)",
                              ExpCostToPost, ExpCostToPostACY, true);
                        if (CostToPost <> 0) or (CostToPostACY <> 0) then
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                              CostToPost, CostToPostACY, false);
                    end;
                "Entry Type"::Rounding:
                    InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                      CostToPost, CostToPostACY, false);
                else
                    ErrorNonValidCombination(ValueEntry);
            end;
    end;

    local procedure BufferSalesPosting(ValueEntry: Record "Value Entry"; CostToPost: Decimal; CostToPostACY: Decimal; ExpCostToPost: Decimal; ExpCostToPostACY: Decimal)
    var
        IsHandled: Boolean;
    begin
        OnBeforeBufferSalesPosting(ValueEntry, GlobalInvtPostBuf, CostToPost, CostToPostACY, ExpCostToPost, ExpCostToPostACY, IsHandled);
        if IsHandled then
            exit;

        with ValueEntry do
            case "Entry Type" of
                "Entry Type"::"Direct Cost":
                    begin
                        if (ExpCostToPost <> 0) or (ExpCostToPostACY <> 0) then
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::"Inventory (Interim)",
                              GlobalInvtPostBuf."Account Type"::"COGS (Interim)",
                              ExpCostToPost, ExpCostToPostACY, true);
                        if (CostToPost <> 0) or (CostToPostACY <> 0) then
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::COGS,
                              CostToPost, CostToPostACY, false);
                    end;
                "Entry Type"::Revaluation:
                    begin
                        if (ExpCostToPost <> 0) or (ExpCostToPostACY <> 0) then
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::"Inventory (Interim)",
                              GlobalInvtPostBuf."Account Type"::"COGS (Interim)",
                              ExpCostToPost, ExpCostToPostACY, true);
                        if (CostToPost <> 0) or (CostToPostACY <> 0) then
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                              CostToPost, CostToPostACY, false);
                    end;
                "Entry Type"::Rounding:
                    InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                      CostToPost, CostToPostACY, false);
                else
                    ErrorNonValidCombination(ValueEntry);
            end;

        OnAfterBufferSalesPosting(TempInvtPostBuf, ValueEntry, PostBufDimNo);
    end;

    local procedure BufferOutputPosting(ValueEntry: Record "Value Entry"; CostToPost: Decimal; CostToPostACY: Decimal; ExpCostToPost: Decimal; ExpCostToPostACY: Decimal)
    var
        PostABCDetail: Boolean;
        PostABCToGL: Boolean;
        ABCCostToPost: Decimal;
        ABCCostToPostACY: Decimal;
        IsHandled: Boolean;
    begin
        OnBeforeBufferOutputPosting(ValueEntry, GlobalInvtPostBuf, CostToPost, CostToPostACY, ExpCostToPost, ExpCostToPostACY, IsHandled);
        if IsHandled then
            exit;

        with ValueEntry do
            case "Entry Type" of
                "Entry Type"::"Direct Cost":
                    begin
                        if (ExpCostToPost <> 0) or (ExpCostToPostACY <> 0) then
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::"Inventory (Interim)",
                              GlobalInvtPostBuf."Account Type"::"WIP Inventory",
                              ExpCostToPost, ExpCostToPostACY, true);
                        if (CostToPost <> 0) or (CostToPostACY <> 0) then
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"WIP Inventory",
                              CostToPost, CostToPostACY, false);
                    end;
                "Entry Type"::"Indirect Cost":
                    // P8000375A
                    begin
                        if InvtSetup."ABC Detail Posting" then begin
                            ValueEntryABCDetail.SetRange("Entry No.", "Entry No.");
                            PostABCDetail := ValueEntryABCDetail.FindSet(false, false); // P8000466A
                        end;
                        if PostABCDetail then begin
                            repeat
                                // ABC Direct
                                PostABCToGL := false;
                                CalcCostToPost(ABCCostToPost,
                                  ValueEntryABCDetail.Cost, ValueEntryABCDetail."Cost Posted to G/L", PostABCToGL);
                                CalcCostToPost(ABCCostToPostACY,
                                  ValueEntryABCDetail."Cost (ACY)", ValueEntryABCDetail."Cost Posted to G/L (ACY)", PostABCToGL);
                                if PostABCToGL then begin                                      // P8000466A
                                    AdditionalPostingCode := ValueEntryABCDetail."Resource No."; // P8000466A
                                    InitInvtPostBuf(                                             // P8000466A
                                      ValueEntry,
                                      GlobalInvtPostBuf."Account Type"::Inventory,
                                      GlobalInvtPostBuf."Account Type"::FOODABCDirect,
                                      //ValueEntryABCDetail."Resource No.",                      // P8000466A
                                      ABCCostToPost, ABCCostToPostACY, false);
                                end;                                                           // P8000466A
                                                                                               // ABC Overhead
                                PostABCToGL := false;
                                CalcCostToPost(ABCCostToPost,
                                  ValueEntryABCDetail.Overhead, ValueEntryABCDetail."Overhead Posted to G/L", PostABCToGL);
                                CalcCostToPost(ABCCostToPostACY,
                                  ValueEntryABCDetail."Overhead (ACY)", ValueEntryABCDetail."Overhead Posted to G/L (ACY)", PostABCToGL);
                                if PostABCToGL then begin                                      // P8000466A
                                    AdditionalPostingCode := ValueEntryABCDetail."Resource No."; // P8000466A
                                    InitInvtPostBuf(                                             // P8000466A
                                      ValueEntry,
                                      GlobalInvtPostBuf."Account Type"::Inventory,
                                      GlobalInvtPostBuf."Account Type"::FOODABCOverhead,
                                      //ValueEntryABCDetail."Resource No.",                      // P8000466A
                                      ABCCostToPost, ABCCostToPostACY, false);
                                end;                                                           // P8000466A
                                                                                               //ValueEntryABCDetail.MODIFY;                                  // P8000466A
                            until ValueEntryABCDetail.Next = 0;
                        end else
                            // P8000375A
                            InitInvtPostBuf(
                    ValueEntry,
                    GlobalInvtPostBuf."Account Type"::Inventory,
                    GlobalInvtPostBuf."Account Type"::"Overhead Applied",
                    CostToPost, CostToPostACY, false);
                    end; // P8000375A
                "Entry Type"::Variance:
                    case "Variance Type" of
                        "Variance Type"::Material:
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Material Variance",
                              CostToPost, CostToPostACY, false);
                        "Variance Type"::Capacity:
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Capacity Variance",
                              CostToPost, CostToPostACY, false);
                        "Variance Type"::Subcontracted:
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Subcontracted Variance",
                              CostToPost, CostToPostACY, false);
                        "Variance Type"::"Capacity Overhead":
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Cap. Overhead Variance",
                              CostToPost, CostToPostACY, false);
                        "Variance Type"::"Manufacturing Overhead":
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Mfg. Overhead Variance",
                              CostToPost, CostToPostACY, false);
                        else
                            ErrorNonValidCombination(ValueEntry);
                    end;
                "Entry Type"::Revaluation:
                    begin
                        if (ExpCostToPost <> 0) or (ExpCostToPostACY <> 0) then
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::"Inventory (Interim)",
                              GlobalInvtPostBuf."Account Type"::"WIP Inventory",
                              ExpCostToPost, ExpCostToPostACY, true);
                        if (CostToPost <> 0) or (CostToPostACY <> 0) then
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                              CostToPost, CostToPostACY, false);
                    end;
                "Entry Type"::Rounding:
                    InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                      CostToPost, CostToPostACY, false);
                else
                    ErrorNonValidCombination(ValueEntry);
            end;

        OnAfterBufferOutputPosting(ValueEntry, CostToPost, CostToPostACY, ExpCostToPost, ExpCostToPostACY);
    end;

    local procedure BufferConsumpPosting(ValueEntry: Record "Value Entry"; CostToPost: Decimal; CostToPostACY: Decimal)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeBufferConsumpPosting(ValueEntry, GlobalInvtPostBuf, CostToPost, CostToPostACY, IsHandled);
        if IsHandled then
            exit;

        with ValueEntry do
            case "Entry Type" of
                "Entry Type"::"Direct Cost":
                    InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"WIP Inventory",
                      CostToPost, CostToPostACY, false);
                "Entry Type"::Revaluation,
              "Entry Type"::Rounding:
                    InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                      CostToPost, CostToPostACY, false);
                else
                    ErrorNonValidCombination(ValueEntry);
            end;

        OnAfterBufferConsumpPosting(TempInvtPostBuf, ValueEntry, PostBufDimNo, CostToPost, CostToPostACY);
    end;

    local procedure BufferCapacityPosting(ValueEntry: Record "Value Entry"; CostToPost: Decimal; CostToPostACY: Decimal)
    begin
        with ValueEntry do
            if "Order Type" = "Order Type"::Assembly then
                case "Entry Type" of
                    "Entry Type"::"Direct Cost":
                        InitInvtPostBuf(
                          ValueEntry,
                          GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                          GlobalInvtPostBuf."Account Type"::"Direct Cost Applied",
                          CostToPost, CostToPostACY, false);
                    "Entry Type"::"Indirect Cost":
                        InitInvtPostBuf(
                          ValueEntry,
                          GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                          GlobalInvtPostBuf."Account Type"::"Overhead Applied",
                          CostToPost, CostToPostACY, false);
                    else
                        ErrorNonValidCombination(ValueEntry);
                end
            else
                case "Entry Type" of
                    "Entry Type"::"Direct Cost":
                        InitInvtPostBuf(
                          ValueEntry,
                          GlobalInvtPostBuf."Account Type"::"WIP Inventory",
                          GlobalInvtPostBuf."Account Type"::"Direct Cost Applied",
                          CostToPost, CostToPostACY, false);
                    "Entry Type"::"Indirect Cost":
                        InitInvtPostBuf(
                          ValueEntry,
                          GlobalInvtPostBuf."Account Type"::"WIP Inventory",
                          GlobalInvtPostBuf."Account Type"::"Overhead Applied",
                          CostToPost, CostToPostACY, false);
                    else
                        ErrorNonValidCombination(ValueEntry);
                end;

        OnAfterBufferCapacityPosting(ValueEntry, CostToPost, CostToPostACY);
    end;

    local procedure BufferAsmOutputPosting(ValueEntry: Record "Value Entry"; CostToPost: Decimal; CostToPostACY: Decimal)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeBufferAsmOutputPosting(ValueEntry, GlobalInvtPostBuf, CostToPost, CostToPostACY, IsHandled);
        if IsHandled then
            exit;

        with ValueEntry do
            case "Entry Type" of
                "Entry Type"::"Direct Cost":
                    InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                      CostToPost, CostToPostACY, false);
                "Entry Type"::"Indirect Cost":
                    InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"Overhead Applied",
                      CostToPost, CostToPostACY, false);
                "Entry Type"::Variance:
                    case "Variance Type" of
                        "Variance Type"::Material:
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Material Variance",
                              CostToPost, CostToPostACY, false);
                        "Variance Type"::Capacity:
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Capacity Variance",
                              CostToPost, CostToPostACY, false);
                        "Variance Type"::Subcontracted:
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Subcontracted Variance",
                              CostToPost, CostToPostACY, false);
                        "Variance Type"::"Capacity Overhead":
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Cap. Overhead Variance",
                              CostToPost, CostToPostACY, false);
                        "Variance Type"::"Manufacturing Overhead":
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::Inventory,
                              GlobalInvtPostBuf."Account Type"::"Mfg. Overhead Variance",
                              CostToPost, CostToPostACY, false);
                        else
                            ErrorNonValidCombination(ValueEntry);
                    end;
                "Entry Type"::Revaluation:
                    InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                      CostToPost, CostToPostACY, false);
                "Entry Type"::Rounding:
                    InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                      CostToPost, CostToPostACY, false);
                else
                    ErrorNonValidCombination(ValueEntry);
            end;
    end;

    local procedure BufferAsmConsumpPosting(ValueEntry: Record "Value Entry"; CostToPost: Decimal; CostToPostACY: Decimal)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeBufferAsmConsumpPosting(ValueEntry, GlobalInvtPostBuf, CostToPost, CostToPostACY, IsHandled);
        if IsHandled then
            exit;

        with ValueEntry do
            case "Entry Type" of
                "Entry Type"::"Direct Cost":
                    InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                      CostToPost, CostToPostACY, false);
                "Entry Type"::Revaluation,
              "Entry Type"::Rounding:
                    InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                      CostToPost, CostToPostACY, false);
                else
                    ErrorNonValidCombination(ValueEntry);
            end;
    end;

    local procedure BufferAdjmtPosting(ValueEntry: Record "Value Entry"; CostToPost: Decimal; CostToPostACY: Decimal; ExpCostToPost: Decimal; ExpCostToPostACY: Decimal; var ECToPost: Record "Extra Charge Posting Buffer" temporary)
    var
        IsHandled: Boolean;
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        // P8001132 - add parameter for ECToPost
        OnBeforeBufferAdjmtPosting(ValueEntry, GlobalInvtPostBuf, CostToPost, CostToPostACY, ExpCostToPost, ExpCostToPostACY, IsHandled);
        if IsHandled then
            exit;

        with ValueEntry do
            case "Entry Type" of
                "Entry Type"::"Direct Cost":
                    begin
                        // Posting adjustments to Interim accounts (Service)
                        if (ExpCostToPost <> 0) or (ExpCostToPostACY <> 0) then
                            InitInvtPostBuf(
                              ValueEntry,
                              GlobalInvtPostBuf."Account Type"::"Inventory (Interim)",
                              GlobalInvtPostBuf."Account Type"::"COGS (Interim)",
                              ExpCostToPost, ExpCostToPostACY, true);
                        if (CostToPost <> 0) or (CostToPostACY <> 0) then
                        // PR3.61.01 Begin
                        //  InitInvtPostBuf(
                        //    ValueEntry,
                        //    GlobalInvtPostBuf."Account Type"::Inventory,
                        //    GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                        //    CostToPost,CostToPostACY,FALSE);
                        begin
                            ItemLedgerEntry.Get("Item Ledger Entry No.");
                            case ItemLedgerEntry."Writeoff Responsibility" of
                                ItemLedgerEntry."Writeoff Responsibility"::" ":
                                    // P8000928
                                    begin
                                        if ECToPost.Find('-') then
                                            repeat
                                                if (ECToPost."Cost To Post" <> 0) or (ECToPost."Cost To Post (ACY)" <> 0) then begin
                                                    AdditionalPostingCode := ECToPost."Extra Charge Code";
                                                    InitInvtPostBuf(
                                                      ValueEntry,
                                                      GlobalInvtPostBuf."Account Type"::Inventory,
                                                      GlobalInvtPostBuf."Account Type"::FOODDirectCostAppliedEC,
                                                      ECToPost."Cost To Post", ECToPost."Cost To Post (ACY)", false);
                                                    CostToPost -= ECToPost."Cost To Post";
                                                    CostToPostACY -= ECToPost."Cost To Post (ACY)";
                                                end;
                                            until ECToPost.Next = 0;
                                        if (CostToPost <> 0) or (CostToPostACY <> 0) then // P8001061
                                                                                          // P8000928
                                            InitInvtPostBuf(
                            ValueEntry,
                            GlobalInvtPostBuf."Account Type"::Inventory,
                            GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                            CostToPost, CostToPostACY, false); // PR4.00
                                    end; // P8000928
                                ItemLedgerEntry."Writeoff Responsibility"::Company:
                                    InitInvtPostBuf(
                                      ValueEntry,
                                      GlobalInvtPostBuf."Account Type"::Inventory,
                                      GlobalInvtPostBuf."Account Type"::FOODWriteoffCompany,
                                      CostToPost, CostToPostACY, false); // PR4.00
                                ItemLedgerEntry."Writeoff Responsibility"::Vendor:
                                    InitInvtPostBuf(
                                      ValueEntry,
                                      GlobalInvtPostBuf."Account Type"::Inventory,
                                      GlobalInvtPostBuf."Account Type"::FOODWriteoffVendor,
                                      CostToPost, CostToPostACY, false); // PR4.00
                            end;
                        end;
                        // PR3.61.01 End
                    end;
                "Entry Type"::Revaluation,
              "Entry Type"::Rounding:
                    InitInvtPostBuf(
                      ValueEntry,
                      GlobalInvtPostBuf."Account Type"::Inventory,
                      GlobalInvtPostBuf."Account Type"::"Inventory Adjmt.",
                      CostToPost, CostToPostACY, false);
                // P80050651
                "Entry Type"::"Indirect Cost":
                    if "Order Type" = "Order Type"::FOODRepack then
                        InitInvtPostBuf(
                          ValueEntry,
                          GlobalInvtPostBuf."Account Type"::Inventory,
                          GlobalInvtPostBuf."Account Type"::"Overhead Applied",
                          CostToPost, CostToPostACY, false)
                    else
                        ErrorNonValidCombination(ValueEntry);
                // P80050651
                // P8001195
                "Entry Type"::Variance:
                    if "Order Type" in ["Order Type"::FOODRepack, "Order Type"::FOODSalesRepack, "Order Type"::FOODLotCombination] then begin // P800110504
                        case "Variance Type" of
                            "Variance Type"::Material:
                                InitInvtPostBuf(
                                  ValueEntry,
                                  GlobalInvtPostBuf."Account Type"::Inventory,
                                  GlobalInvtPostBuf."Account Type"::"Material Variance",
                                  CostToPost, CostToPostACY, false);
                            "Variance Type"::Capacity:
                                InitInvtPostBuf(
                                  ValueEntry,
                                  GlobalInvtPostBuf."Account Type"::Inventory,
                                  GlobalInvtPostBuf."Account Type"::"Capacity Variance",
                                  CostToPost, CostToPostACY, false);
                            "Variance Type"::Subcontracted:
                                InitInvtPostBuf(
                                  ValueEntry,
                                  GlobalInvtPostBuf."Account Type"::Inventory,
                                  GlobalInvtPostBuf."Account Type"::"Subcontracted Variance",
                                  CostToPost, CostToPostACY, false);
                            "Variance Type"::"Capacity Overhead":
                                InitInvtPostBuf(
                                  ValueEntry,
                                  GlobalInvtPostBuf."Account Type"::Inventory,
                                  GlobalInvtPostBuf."Account Type"::"Cap. Overhead Variance",
                                  CostToPost, CostToPostACY, false);
                            "Variance Type"::"Manufacturing Overhead":
                                InitInvtPostBuf(
                                  ValueEntry,
                                  GlobalInvtPostBuf."Account Type"::Inventory,
                                  GlobalInvtPostBuf."Account Type"::"Mfg. Overhead Variance",
                                  CostToPost, CostToPostACY, false);
                            else
                                ErrorNonValidCombination(ValueEntry);
                        end;
                    end else
                        ErrorNonValidCombination(ValueEntry);
                // P8001195
                else
                    ErrorNonValidCombination(ValueEntry);
            end;
    end;

    local procedure GetGLSetup()
    begin
        if not GLSetupRead then begin
            GLSetup.Get();
            if GLSetup."Additional Reporting Currency" <> '' then
                Currency.Get(GLSetup."Additional Reporting Currency");
        end;
        GLSetupRead := true;
    end;

    local procedure GetInvtSetup()
    begin
        if not InvtSetupRead then
            InvtSetup.Get();
        InvtSetupRead := true;
    end;

    local procedure CalcCostToPost(var CostToPost: Decimal; AdjdCost: Decimal; var PostedCost: Decimal; var PostToGL: Boolean)
    begin
        CostToPost := AdjdCost - PostedCost;

        if CostToPost <> 0 then begin
            if not RunOnlyCheck then
                PostedCost := AdjdCost;
            PostToGL := true;
        end;
    end;

    procedure InitInvtPostBuf(ValueEntry: Record "Value Entry"; AccType: Enum "Invt. Posting Buffer Account Type"; BalAccType: Enum "Invt. Posting Buffer Account Type"; CostToPost: Decimal; CostToPostACY: Decimal; InterimAccount: Boolean)
    begin
        OnBeforeInitInvtPostBuf(ValueEntry);

        InitInvtPostBufPerAccount(ValueEntry, AccType, BalAccType, CostToPost, CostToPostACY, InterimAccount, false, AdditionalPostingCode);
        InitInvtPostBufPerAccount(ValueEntry, AccType, BalAccType, CostToPost, CostToPostACY, InterimAccount, true, AdditionalPostingCode);

        OnAfterInitInvtPostBuf(ValueEntry);

        AdditionalPostingCode := ''; // P8000466A
    end;

    local procedure InitInvtPostBufPerAccount(var ValueEntry: Record "Value Entry"; AccType: Enum "Invt. Posting Buffer Account Type"; BalAccType: Enum "Invt. Posting Buffer Account Type"; CostToPost: Decimal; CostToPostACY: Decimal; InterimAccount: Boolean; BalancingRecord: Boolean; AdditionalPostingCode: Code[20])
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitInvtPostBufPerAccount(ValueEntry, AccType, BalAccType, CostToPost, CostToPostACY, InterimAccount, BalancingRecord, IsHandled);
        if IsHandled then
            exit;

        PostBufDimNo := PostBufDimNo + 1;
        Clear(TempInvtPostBuf); // P8000466A           

        if BalancingRecord then begin
            SetAccNo(TempInvtPostBuf, ValueEntry, AdditionalPostingCode, BalAccType, AccType); // P8000466A
            SetPostBufAmounts(TempInvtPostBuf, -CostToPost, -CostToPostACY, InterimAccount);   // P8000466A
        end else begin
            SetAccNo(TempInvtPostBuf, ValueEntry, AdditionalPostingCode, AccType, BalAccType); // P8000466A
            SetPostBufAmounts(TempInvtPostBuf, CostToPost, CostToPostACY, InterimAccount);     // P8000466A
        end;

        TempInvtPostBuf."Dimension Set ID" := ValueEntry."Dimension Set ID"; // P8001133
        TempInvtPostBuf.Insert;                                                        // P8000466A

        OnAfterInitTempInvtPostBuf(TempInvtPostBuf, ValueEntry, PostBufDimNo);
    end;

    local procedure CheckAccNo(var AccountNo: Code[20])
    var
        GLAccount: Record "G/L Account";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckGLAcc(AccountNo, CalledFromItemPosting, IsHandled);
        if IsHandled then
            exit;

        if AccountNo = '' then
            exit;

        GLAccount.Get(AccountNo);
        if GLAccount.Blocked then begin
            if CalledFromItemPosting then
                GLAccount.TestField(Blocked, false);
            if not CalledFromTestReport then
                AccountNo := '';
        end;
    end;

    local procedure SetAccNo(var InvtPostBuf: Record "Invt. Posting Buffer"; ValueEntry: Record "Value Entry"; AdditionalPostingCode: Code[20]; AccType: Enum "Invt. Posting Buffer Account Type"; BalAccType: Enum "Invt. Posting Buffer Account Type")
    var
        InvtPostingSetup: Record "Inventory Posting Setup";
        GenPostingSetup: Record "General Posting Setup";
        IsHandled: Boolean;
        ECPostingSetup: Record "Extra Charge Posting Setup";
        Resource: Record Resource;
    begin
        // P8000466A - parameter added for additional posting code
        with InvtPostBuf do begin
            "Account No." := '';
            "Account Type" := AccType;
            "Bal. Account Type" := BalAccType;
            "Location Code" := ValueEntry."Location Code";
            "Inventory Posting Group" :=
                GetInvPostingGroupCode(ValueEntry, AccType = "Account Type"::"WIP Inventory", ValueEntry."Inventory Posting Group");
            "Gen. Bus. Posting Group" := ValueEntry."Gen. Bus. Posting Group";
            // P8000466A
            if UseABCDetail then begin
                Resource.Get(AdditionalPostingCode);
                "Gen. Prod. Posting Group" := Resource."Gen. Prod. Posting Group"
            end else
                // P8000466A
                "Gen. Prod. Posting Group" := ValueEntry."Gen. Prod. Posting Group";
            "Posting Date" := ValueEntry."Posting Date";
            "Additional Posting Code" := AdditionalPostingCode; // P8000466A

            IsHandled := false;
            OnBeforeGetInvtPostSetup(InvtPostingSetup, "Location Code", "Inventory Posting Group", GenPostingSetup, IsHandled);
            if not IsHandled then
            // P8000062B
            if UseECPostingSetup then begin // P8000466A
                if CalledFromItemPosting then
                    ECPostingSetup.Get("Gen. Bus. Posting Group", "Gen. Prod. Posting Group", "Additional Posting Code") // P8000466A
                else
                    if not ECPostingSetup.Get("Gen. Bus. Posting Group", "Gen. Prod. Posting Group", "Additional Posting Code") then // P8000466A
                        exit;
                // P8000062B
            end else
                if UseInvtPostSetup then begin // P8000062B
                    if CalledFromItemPosting then
                        InvtPostingSetup.Get("Location Code", "Inventory Posting Group")
                    else
                        if not InvtPostingSetup.Get("Location Code", "Inventory Posting Group") then
                            exit;
                end else begin
                    if CalledFromItemPosting then
                        GenPostingSetup.Get("Gen. Bus. Posting Group", "Gen. Prod. Posting Group")
                    else
                        if not GenPostingSetup.Get("Gen. Bus. Posting Group", "Gen. Prod. Posting Group") then
                            exit;
                    if not CalledFromTestReport then
                        GenPostingSetup.TestField(Blocked, false);
                end;

            OnSetAccNoOnAfterGetPostingSetup(InvtPostBuf, InvtPostingSetup, GenPostingSetup, ValueEntry, UseInvtPostSetup());

            IsHandled := false;
            OnBeforeSetAccNo(InvtPostBuf, ValueEntry, AccType.AsInteger(), BalAccType.AsInteger(), CalledFromItemPosting, IsHandled);
            if not IsHandled then
                case "Account Type" of
                    "Account Type"::Inventory:
                        if CalledFromItemPosting then
                            "Account No." := InvtPostingSetup.GetInventoryAccount
                        else
                            "Account No." := InvtPostingSetup."Inventory Account";
                    "Account Type"::"Inventory (Interim)":
                        if CalledFromItemPosting then
                            "Account No." := InvtPostingSetup.GetInventoryAccountInterim
                        else
                            "Account No." := InvtPostingSetup."Inventory Account (Interim)";
                    "Account Type"::"WIP Inventory":
                        if CalledFromItemPosting then
                            "Account No." := InvtPostingSetup.GetWIPAccount
                        else
                            "Account No." := InvtPostingSetup."WIP Account";
                    "Account Type"::"Material Variance":
                        if CalledFromItemPosting then
                            "Account No." := InvtPostingSetup.GetMaterialVarianceAccount
                        else
                            "Account No." := InvtPostingSetup."Material Variance Account";
                    "Account Type"::"Capacity Variance":
                        if CalledFromItemPosting then
                            "Account No." := InvtPostingSetup.GetCapacityVarianceAccount
                        else
                            "Account No." := InvtPostingSetup."Capacity Variance Account";
                    "Account Type"::"Subcontracted Variance":
                        if CalledFromItemPosting then
                            "Account No." := InvtPostingSetup.GetSubcontractedVarianceAccount
                        else
                            "Account No." := InvtPostingSetup."Subcontracted Variance Account";
                    "Account Type"::"Cap. Overhead Variance":
                        if CalledFromItemPosting then
                            "Account No." := InvtPostingSetup.GetCapOverheadVarianceAccount
                        else
                            "Account No." := InvtPostingSetup."Cap. Overhead Variance Account";
                    "Account Type"::"Mfg. Overhead Variance":
                        if CalledFromItemPosting then
                            "Account No." := InvtPostingSetup.GetMfgOverheadVarianceAccount
                        else
                            "Account No." := InvtPostingSetup."Mfg. Overhead Variance Account";
                    "Account Type"::"Inventory Adjmt.":
                        if CalledFromItemPosting then
                            "Account No." := GenPostingSetup.GetInventoryAdjmtAccount
                        else
                            "Account No." := GenPostingSetup."Inventory Adjmt. Account";
                    "Account Type"::"Direct Cost Applied":
                        if CalledFromItemPosting then
                            "Account No." := GenPostingSetup.GetDirectCostAppliedAccount
                        else
                            "Account No." := GenPostingSetup."Direct Cost Applied Account";
                    "Account Type"::"Overhead Applied":
                        if CalledFromItemPosting then
                            "Account No." := GenPostingSetup.GetOverheadAppliedAccount
                        else
                            "Account No." := GenPostingSetup."Overhead Applied Account";
                    // P8000375A
                    "Account Type"::FOODABCDirect:
                        if CalledFromItemPosting then
                            "Account No." := GenPostingSetup.GetABCDirectAccount // P80053245
                        else
                            "Account No." := GenPostingSetup."ABC Direct Account";
                    "Account Type"::FOODABCOverhead:
                        if CalledFromItemPosting then
                            "Account No." := GenPostingSetup.GetABCOverheadAccount // P80053245
                        else
                            "Account No." := GenPostingSetup."ABC Overhead Account";
                    // P8000375A
                    "Account Type"::"Purchase Variance":
                        if CalledFromItemPosting then
                            "Account No." := GenPostingSetup.GetPurchaseVarianceAccount
                        else
                            "Account No." := GenPostingSetup."Purchase Variance Account";
                    "Account Type"::COGS:
                        if CalledFromItemPosting then
                            "Account No." := GenPostingSetup.GetCOGSAccount
                        else
                            "Account No." := GenPostingSetup."COGS Account";
                    "Account Type"::"COGS (Interim)":
                        if CalledFromItemPosting then
                            "Account No." := GenPostingSetup.GetCOGSInterimAccount
                        else
                            "Account No." := GenPostingSetup."COGS Account (Interim)";
                    "Account Type"::"Invt. Accrual (Interim)":
                        if CalledFromItemPosting then
                            "Account No." := GenPostingSetup.GetInventoryAccrualAccount
                        else
                            "Account No." := GenPostingSetup."Invt. Accrual Acc. (Interim)";
                    // PR3.61.01 Begin
                    "Account Type"::FOODWriteoffCompany:
                        if CalledFromItemPosting then
                            "Account No." := InvtPostingSetup.GetWriteoffAccountCompany // P80053245
                        else
                            "Account No." := InvtPostingSetup."Writeoff Account (Company)";
                    "Account Type"::FOODWriteoffVendor:
                        if CalledFromItemPosting then
                            "Account No." := InvtPostingSetup.GetWriteoffAccountVendor // P80053245
                        else
                            "Account No." := InvtPostingSetup."Writeoff Account (Vendor)";
                    // PR3.61.01 End
                    // P8000062B Begin
                    "Account Type"::FOODInvtAccrualECInterim:
                        if CalledFromItemPosting then
                            "Account No." := ECPostingSetup.GetInventoryAccrualAccount // P80053245
                        else
                            "Account No." := ECPostingSetup."Invt. Accrual Acc. (Interim)";
                    "Account Type"::FOODDirectCostAppliedEC:
                        if CalledFromItemPosting then
                            "Account No." := ECPostingSetup.GetDirectCostAppliedAccount // P80053245
                        else
                            "Account No." := ECPostingSetup."Direct Cost Applied Account";
                        // P8000062B End
                end;


            OnSetAccNoOnBeforeCheckAccNo(InvtPostBuf, InvtPostingSetup, GenPostingSetup, CalledFromItemPosting, ValueEntry);
            CheckAccNo("Account No.");

            OnAfterSetAccNo(InvtPostBuf, ValueEntry, CalledFromItemPosting);
        end;
    end;

    local procedure SetPostBufAmounts(var InvtPostBuf: Record "Invt. Posting Buffer"; CostToPost: Decimal; CostToPostACY: Decimal; InterimAccount: Boolean)
    begin
        with InvtPostBuf do begin
            "Interim Account" := InterimAccount;
            Amount := CostToPost;
            "Amount (ACY)" := CostToPostACY;
        end;
    end;

    local procedure UpdateGlobalInvtPostBuf(ValueEntryNo: Integer): Boolean
    var
        i: Integer;
        ShouldInsertTempGLItemLedgRelation: Boolean;
    begin
        with GlobalInvtPostBuf do begin
            if not CalledFromTestReport then
                /*P8000466A
                FOR i := 1 TO PostBufDimNo DO
                  IF TempInvtPostBuf[i]."Account No." = '' THEN BEGIN
                    CLEAR(TempInvtPostBuf);
                    EXIT(FALSE);
                  END;
                P8000466A*/
                // P8000466A
                if TempInvtPostBuf.Find('-') then
                    repeat
                        if TempInvtPostBuf."Account No." = '' then begin
                            TempInvtPostBuf.DeleteAll;
                            exit(false);
                        end;
                    until TempInvtPostBuf.Next = 0;
            // P8000466A
            //FOR i := 1 TO PostBufDimNo DO BEGIN // P8000466A
            if TempInvtPostBuf.Find('-') then     // P8000466A
                repeat                                // P8000466A
                    GlobalInvtPostBuf := TempInvtPostBuf; // P8000466A
                                                          //"Dimension Set ID" := TempInvtPostBuf[i]."Dimension Set ID"; // P8001133
                    Negative := (TempInvtPostBuf.Amount < 0) or (TempInvtPostBuf."Amount (ACY)" < 0); // P8000466A

                    UpdateReportAmounts;
                    // P8000466A
                    if not UseECPostingSetup then
                        "Additional Posting Code" := '';
                    if (not GlobalPostPerPostGroup) and (not UseABCDetail) then
                        "Bal. Account Type" := 0;
                    // P8000466A
                    if Find then begin
                        Amount := Amount + TempInvtPostBuf.Amount; // P8000466A
                        "Amount (ACY)" := "Amount (ACY)" + TempInvtPostBuf."Amount (ACY)"; // P8000466A
                        OnUpdateGlobalInvtPostBufOnBeforeModify(GlobalInvtPostBuf, TempInvtPostBuf); // P800-MegaApp
                        Modify;
                    end else begin
                        GlobalInvtPostBufEntryNo := GlobalInvtPostBufEntryNo + 1;
                        "Entry No." := GlobalInvtPostBufEntryNo;
                        Insert;
                    end;
                    ShouldInsertTempGLItemLedgRelation := not (RunOnlyCheck or CalledFromTestReport);
                    OnUpdateGlobalInvtPostBufOnAfterCalcShouldInsertTempGLItemLedgRelation(TempGLItemLedgRelation, GlobalInvtPostBuf, ValueEntryNo, RunOnlyCheck, CalledFromTestReport, ShouldInsertTempGLItemLedgRelation);
                    if ShouldInsertTempGLItemLedgRelation then begin
                        TempGLItemLedgRelation.Init();
                        TempGLItemLedgRelation."G/L Entry No." := "Entry No.";
                        TempGLItemLedgRelation."Value Entry No." := ValueEntryNo;
                        if TempGLItemLedgRelation.Insert() then; // P8000466A
                    end;
                until TempInvtPostBuf.Next = 0; // P8000466A
                                                //END;                          // P8000466A
        end;
        //Clear(TempInvtPostBuf);
        TempInvtPostBuf.DeleteAll; // P8000466A
        exit(true);

    end;

    local procedure UpdateReportAmounts()
    begin
        with GlobalInvtPostBuf do
            case "Account Type" of
                "Account Type"::Inventory, "Account Type"::"Inventory (Interim)":
                    InvtAmt += Amount;
                "Account Type"::"WIP Inventory":
                    WIPInvtAmt += Amount;
                "Account Type"::FOODWriteoffCompany, // PR3.61.01
              "Account Type"::FOODWriteoffVendor,  // PR3.61.01
              "Account Type"::"Inventory Adjmt.":
                    InvtAdjmtAmt += Amount;
                "Account Type"::FOODInvtAccrualECInterim, // P8000062B
              "Account Type"::"Invt. Accrual (Interim)":
                    InvtAdjmtAmt += Amount;
                "Account Type"::FOODDirectCostAppliedEC,     // P8000062B
              "Account Type"::"Direct Cost Applied":
                    DirCostAmt += Amount;
                "Account Type"::FOODABCDirect,   // P8000375A
              "Account Type"::FOODABCOverhead, // P8000375A
              "Account Type"::"Overhead Applied":
                    OvhdCostAmt += Amount;
                "Account Type"::"Purchase Variance":
                    VarPurchCostAmt += Amount;
                "Account Type"::COGS:
                    COGSAmt += Amount;
                "Account Type"::"COGS (Interim)":
                    COGSAmt += Amount;
                "Account Type"::"Material Variance", "Account Type"::"Capacity Variance",
              "Account Type"::"Subcontracted Variance", "Account Type"::"Cap. Overhead Variance":
                    VarMfgDirCostAmt += Amount;
                "Account Type"::"Mfg. Overhead Variance":
                    VarMfgOvhdCostAmt += Amount;
            end;

        OnAfteUpdateReportAmounts(GlobalInvtPostBuf, InvtAmt, InvtAdjmtAmt);
    end;

    local procedure ErrorNonValidCombination(ValueEntry: Record "Value Entry")
    begin
        with ValueEntry do
            if CalledFromTestReport then
                InsertTempInvtPostToGLTestBuf(ValueEntry)
            else
                Error(
                  Text002,
                  FieldCaption("Item Ledger Entry Type"), "Item Ledger Entry Type",
                  FieldCaption("Entry Type"), "Entry Type",
                  FieldCaption("Expected Cost"), "Expected Cost")
    end;

    local procedure InsertTempInvtPostToGLTestBuf(ValueEntry: Record "Value Entry")
    begin
        with ValueEntry do begin
            TempInvtPostToGLTestBuf."Line No." := GetNextLineNo;
            TempInvtPostToGLTestBuf."Posting Date" := "Posting Date";
            TempInvtPostToGLTestBuf.Description := StrSubstNo(Text003, TableCaption, "Entry No.");
            TempInvtPostToGLTestBuf.Amount := "Cost Amount (Actual)";
            TempInvtPostToGLTestBuf."Value Entry No." := "Entry No.";
            TempInvtPostToGLTestBuf."Dimension Set ID" := "Dimension Set ID";
            OnInsertTempInvtPostToGLTestBufOnBeforeInsert(TempInvtPostToGLTestBuf, ValueEntry);
            TempInvtPostToGLTestBuf.Insert();
        end;
    end;

    local procedure GetNextLineNo(): Integer
    var
        InvtPostToGLTestBuffer: Record "Invt. Post to G/L Test Buffer";
        LastLineNo: Integer;
    begin
        InvtPostToGLTestBuffer := TempInvtPostToGLTestBuf;
        if TempInvtPostToGLTestBuf.FindLast() then
            LastLineNo := TempInvtPostToGLTestBuf."Line No." + 10000
        else
            LastLineNo := 10000;
        TempInvtPostToGLTestBuf := InvtPostToGLTestBuffer;
        exit(LastLineNo);
    end;

    procedure PostInvtPostBufPerEntry(var ValueEntry: Record "Value Entry")
    var
        DummyGenJnlLine: Record "Gen. Journal Line";
    begin
        with ValueEntry do
            PostInvtPostBuf(
              ValueEntry,
              "Document No.",
              "External Document No.",
              CopyStr(
                StrSubstNo(Text000, "Entry Type", "Source No.", "Posting Date"),
                1, MaxStrLen(DummyGenJnlLine.Description)),
              false);
    end;

    procedure PostInvtPostBufPerPostGrp(DocNo: Code[20]; Desc: Text[50])
    var
        ValueEntry: Record "Value Entry";
    begin
        PostInvtPostBuf(ValueEntry, DocNo, '', Desc, true);
    end;

    local procedure PostInvtPostBuf(var ValueEntry: Record "Value Entry"; DocNo: Code[20]; ExternalDocNo: Code[35]; Desc: Text[100]; PostPerPostGrp: Boolean)
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        with GlobalInvtPostBuf do begin
            Reset;
            OnPostInvtPostBufferOnBeforeFind(GlobalInvtPostBuf, TempGLItemLedgRelation, ValueEntry);
            if not FindSet() then
                exit;

            PostInvtPostBufInitGenJnlLine(GenJnlLine, ValueEntry, DocNo, ExternalDocNo, Desc);

            PostInvtPostBufProcessGlobalInvtPostBuf(GenJnlLine, ValueEntry, PostPerPostGrp);

            RunOnlyCheck := RunOnlyCheckSaved;
            OnPostInvtPostBufferOnAfterPostInvtPostBuf(GlobalInvtPostBuf, ValueEntry, CalledFromItemPosting, CalledFromTestReport, RunOnlyCheck, PostPerPostGrp);

            DeleteAll();
        end;
    end;

    local procedure PostInvtPostBufInitGenJnlLine(var GenJnlLine: Record "Gen. Journal Line"; var ValueEntry: Record "Value Entry"; DocNo: Code[20]; ExternalDocNo: Code[35]; Desc: Text[100])
    begin
        GenJnlLine.Init();
        GenJnlLine."Document No." := DocNo;
        GenJnlLine."External Document No." := ExternalDocNo;
        GenJnlLine.Description := Desc;
        GetSourceCodeSetup;
        GenJnlLine."Source Code" := SourceCodeSetup."Inventory Post Cost";
        GenJnlLine."System-Created Entry" := true;
        GenJnlLine."Job No." := ValueEntry."Job No.";
        GenJnlLine."Reason Code" := ValueEntry."Reason Code";
        GenJnlLine."Prod. Order No." := ValueEntry."Order No.";
        GetGLSetup();
        if GLSetup."Journal Templ. Name Mandatory" then begin
            GenJnlLine."Journal Template Name" := GlobalJnlTemplName;
            GenJnlLine."Journal Batch Name" := GlobalJnlBatchName;
        end;
        OnPostInvtPostBufOnAfterInitGenJnlLine(GenJnlLine, ValueEntry);
    end;

    local procedure PostInvtPostBufProcessGlobalInvtPostBuf(var GenJnlLine: Record "Gen. Journal Line"; var ValueEntry: Record "Value Entry"; PostPerPostGrp: Boolean)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostInvtPostBufProcessGlobalInvtPostBuf(GlobalInvtPostBuf, GenJnlLine, ValueEntry, GenJnlPostLine, CalledFromItemPosting, PostPerPostGrp, IsHandled);
        if IsHandled then
            exit;

        with GlobalInvtPostBuf do
            repeat
                GenJnlLine.Validate("Posting Date", "Posting Date");
                OnPostInvtPostBufOnBeforeSetAmt(GenJnlLine, ValueEntry, GlobalInvtPostBuf);
                if SetAmt(GenJnlLine, Amount, "Amount (ACY)") then begin
                    if PostPerPostGrp then
                        SetDesc(GenJnlLine, GlobalInvtPostBuf);
                    OnPostInvtPostBufProcessGlobalInvtPostBufOnAfterSetDesc(GenJnlLine, GlobalInvtPostBuf);
                    GenJnlLine."Account No." := "Account No.";
                    GenJnlLine."Dimension Set ID" := "Dimension Set ID";
                    DimMgt.UpdateGlobalDimFromDimSetID(
                      "Dimension Set ID", GenJnlLine."Shortcut Dimension 1 Code",
                      GenJnlLine."Shortcut Dimension 2 Code");
                    OnPostInvtPostBufOnAfterUpdateGlobalDimFromDimSetID(GenJnlLine, GlobalInvtPostBuf);
                    if not CalledFromTestReport then
                        if not RunOnlyCheck then begin
                            if not CalledFromItemPosting then
                                GenJnlPostLine.SetOverDimErr;
                            OnBeforePostInvtPostBuf(GenJnlLine, GlobalInvtPostBuf, ValueEntry, GenJnlPostLine);
                            PostGenJnlLine(GenJnlLine);
                        end else begin
                            OnBeforeCheckInvtPostBuf(GenJnlLine, GlobalInvtPostBuf, ValueEntry, GenJnlPostLine, GenJnlCheckLine);
                            CheckGenJnlLine(GenJnlLine);
                        end
                    else
                        InsertTempInvtPostToGLTestBuf(GenJnlLine, ValueEntry);
                end;
                OnPostInvtPostBufProcessGlobalInvtPostBufOnAfterSetAmt(GenJnlLine);

                if not CalledFromTestReport and not RunOnlyCheck then
                    CreateGLItemLedgRelation(ValueEntry);
            until Next() = 0;
    end;

    local procedure GetSourceCodeSetup()
    begin
        if not SourceCodeSetupRead then
            SourceCodeSetup.Get();
        SourceCodeSetupRead := true;
    end;

    local procedure SetAmt(var GenJnlLine: Record "Gen. Journal Line"; Amt: Decimal; AmtACY: Decimal) HasAmountToPost: Boolean
    begin
        with GenJnlLine do begin
            "Additional-Currency Posting" := "Additional-Currency Posting"::None;
            Validate(Amount, Amt);

            GetGLSetup();
            if GLSetup."Additional Reporting Currency" <> '' then begin
                "Source Currency Code" := GLSetup."Additional Reporting Currency";
                "Source Currency Amount" := AmtACY;
                if (Amount = 0) and ("Source Currency Amount" <> 0) then begin
                    "Additional-Currency Posting" :=
                      "Additional-Currency Posting"::"Additional-Currency Amount Only";
                    Validate(Amount, "Source Currency Amount");
                    "Source Currency Amount" := 0;
                end;
            end;
        end;

        HasAmountToPost := (Amt <> 0) or (AmtACY <> 0);
        OnAfterSetAmt(GenJnlLine, Amt, AmtACY, HasAmountToPost);
    end;

    procedure SetDesc(var GenJnlLine: Record "Gen. Journal Line"; InvtPostBuf: Record "Invt. Posting Buffer")
    begin
        with InvtPostBuf do
            GenJnlLine.Description :=
              CopyStr(
                StrSubstNo(
                  Text001,
                  "Account Type", "Bal. Account Type",
                  "Location Code", "Inventory Posting Group",
                  "Gen. Bus. Posting Group", "Gen. Prod. Posting Group"),
                1, MaxStrLen(GenJnlLine.Description));

        OnAfterSetDesc(GenJnlLine, InvtPostBuf);
    end;

    local procedure InsertTempInvtPostToGLTestBuf(GenJnlLine: Record "Gen. Journal Line"; ValueEntry: Record "Value Entry")
    begin
        with GenJnlLine do begin
            TempInvtPostToGLTestBuf.Init();
            TempInvtPostToGLTestBuf."Line No." := GetNextLineNo;
            TempInvtPostToGLTestBuf."Posting Date" := "Posting Date";
            TempInvtPostToGLTestBuf."Document No." := "Document No.";
            TempInvtPostToGLTestBuf.Description := Description;
            TempInvtPostToGLTestBuf."Account No." := "Account No.";
            TempInvtPostToGLTestBuf.Amount := Amount;
            TempInvtPostToGLTestBuf."Source Code" := "Source Code";
            TempInvtPostToGLTestBuf."System-Created Entry" := true;
            TempInvtPostToGLTestBuf."Value Entry No." := ValueEntry."Entry No.";
            TempInvtPostToGLTestBuf."Additional-Currency Posting" := "Additional-Currency Posting";
            TempInvtPostToGLTestBuf."Source Currency Code" := "Source Currency Code";
            TempInvtPostToGLTestBuf."Source Currency Amount" := "Source Currency Amount";
            TempInvtPostToGLTestBuf."Inventory Account Type" := GlobalInvtPostBuf."Account Type";
            TempInvtPostToGLTestBuf."Dimension Set ID" := "Dimension Set ID";
            if GlobalInvtPostBuf.UseInvtPostSetup then begin
                TempInvtPostToGLTestBuf."Location Code" := GlobalInvtPostBuf."Location Code";
                TempInvtPostToGLTestBuf."Invt. Posting Group Code" :=
                  GetInvPostingGroupCode(
                    ValueEntry,
                    TempInvtPostToGLTestBuf."Inventory Account Type" = TempInvtPostToGLTestBuf."Inventory Account Type"::"WIP Inventory",
                    GlobalInvtPostBuf."Inventory Posting Group")
            end else begin
                TempInvtPostToGLTestBuf."Gen. Bus. Posting Group" := GlobalInvtPostBuf."Gen. Bus. Posting Group";
                TempInvtPostToGLTestBuf."Gen. Prod. Posting Group" := GlobalInvtPostBuf."Gen. Prod. Posting Group";
            end;
            OnInsertTempInvtPostToGLTestBufOnBeforeTempInvtPostToGLTestBufInsert(TempInvtPostToGLTestBuf, GenJnlLine, ValueEntry);
            TempInvtPostToGLTestBuf.Insert();
        end;
    end;

    local procedure CreateGLItemLedgRelation(var ValueEntry: Record "Value Entry")
    var
        GLReg: Record "G/L Register";
    begin
        GenJnlPostLine.GetGLReg(GLReg);
        if GlobalPostPerPostGroup then begin
            TempGLItemLedgRelation.Reset();
            TempGLItemLedgRelation.SetRange("G/L Entry No.", GlobalInvtPostBuf."Entry No.");
            TempGLItemLedgRelation.FindSet();
            repeat
                ValueEntry.Get(TempGLItemLedgRelation."Value Entry No.");
                UpdateValueEntry(ValueEntry);
                CreateGLItemLedgRelationEntry(GLReg);
            until TempGLItemLedgRelation.Next() = 0;
        end else begin
            UpdateValueEntry(ValueEntry);
            CreateGLItemLedgRelationEntry(GLReg);
        end;
    end;

    local procedure CreateGLItemLedgRelationEntry(GLReg: Record "G/L Register")
    var
        GLItemLedgRelation: Record "G/L - Item Ledger Relation";
    begin
        if GLReg."To Entry No." <> 0 then begin // P8004516
            GLItemLedgRelation.Init();
            GLItemLedgRelation."G/L Entry No." := GLReg."To Entry No.";
            GLItemLedgRelation."Value Entry No." := TempGLItemLedgRelation."Value Entry No.";
            GLItemLedgRelation."G/L Register No." := GLReg."No.";
            OnBeforeGLItemLedgRelationInsert(GLItemLedgRelation, GlobalInvtPostBuf, GLReg, TempGLItemLedgRelation);
            GLItemLedgRelation.Insert();
            OnAfterGLItemLedgRelationInsert();
        end;
        TempGLItemLedgRelation."G/L Entry No." := GlobalInvtPostBuf."Entry No.";
        TempGLItemLedgRelation.Delete();
    end;

    local procedure UpdateValueEntry(var ValueEntry: Record "Value Entry")
    begin
        with ValueEntry do begin
            if GlobalInvtPostBuf."Interim Account" then begin
                "Expected Cost Posted to G/L" := "Cost Amount (Expected)";
                "Exp. Cost Posted to G/L (ACY)" := "Cost Amount (Expected) (ACY)";
            end else begin
                "Cost Posted to G/L" := "Cost Amount (Actual)";
                "Cost Posted to G/L (ACY)" := "Cost Amount (Actual) (ACY)";
            end;
            OnUpdateValueEntryOnBeforeModify(ValueEntry, GlobalInvtPostBuf);
            if not CalledFromItemPosting then
                Modify;
            // P8000466A
            if ProcessFns.FreshProInstalled then
                ExtraChargeMgmt.UpdatePostedCharge("Entry No.", GlobalInvtPostBuf."Interim Account");
            if InvtSetup."ABC Detail Posting" and (not GlobalInvtPostBuf."Interim Account") then begin
                ValueEntryABCDetail.SetRange("Entry No.", "Entry No.");
                if ValueEntryABCDetail.FindSet(true, false) then
                    repeat
                        ValueEntryABCDetail."Cost Posted to G/L" := ValueEntryABCDetail.Cost;
                        ValueEntryABCDetail."Cost Posted to G/L (ACY)" := ValueEntryABCDetail."Cost (ACY)";
                        ValueEntryABCDetail."Overhead Posted to G/L" := ValueEntryABCDetail.Overhead;
                        ValueEntryABCDetail."Overhead Posted to G/L (ACY)" := ValueEntryABCDetail."Overhead (ACY)";
                        ValueEntryABCDetail.Modify;
                    until ValueEntryABCDetail.Next = 0;
            end;
            // P8000466A
        end;
    end;

    procedure GetTempInvtPostToGLTestBuf(var InvtPostToGLTestBuf: Record "Invt. Post to G/L Test Buffer")
    begin
        InvtPostToGLTestBuf.DeleteAll();
        if not TempInvtPostToGLTestBuf.FindSet() then
            exit;

        repeat
            InvtPostToGLTestBuf := TempInvtPostToGLTestBuf;
            InvtPostToGLTestBuf.Insert();
        until TempInvtPostToGLTestBuf.Next() = 0;
    end;

    procedure GetAmtToPost(var NewCOGSAmt: Decimal; var NewInvtAdjmtAmt: Decimal; var NewDirCostAmt: Decimal; var NewOvhdCostAmt: Decimal; var NewVarPurchCostAmt: Decimal; var NewVarMfgDirCostAmt: Decimal; var NewVarMfgOvhdCostAmt: Decimal; var NewWIPInvtAmt: Decimal; var NewInvtAmt: Decimal; GetTotal: Boolean)
    begin
        GetAmt(NewInvtAdjmtAmt, InvtAdjmtAmt, TotalInvtAdjmtAmt, GetTotal);
        GetAmt(NewDirCostAmt, DirCostAmt, TotalDirCostAmt, GetTotal);
        GetAmt(NewOvhdCostAmt, OvhdCostAmt, TotalOvhdCostAmt, GetTotal);
        GetAmt(NewVarPurchCostAmt, VarPurchCostAmt, TotalVarPurchCostAmt, GetTotal);
        GetAmt(NewVarMfgDirCostAmt, VarMfgDirCostAmt, TotalVarMfgDirCostAmt, GetTotal);
        GetAmt(NewVarMfgOvhdCostAmt, VarMfgOvhdCostAmt, TotalVarMfgOvhdCostAmt, GetTotal);
        GetAmt(NewWIPInvtAmt, WIPInvtAmt, TotalWIPInvtAmt, GetTotal);
        GetAmt(NewCOGSAmt, COGSAmt, TotalCOGSAmt, GetTotal);
        GetAmt(NewInvtAmt, InvtAmt, TotalInvtAmt, GetTotal);
    end;

    local procedure GetAmt(var NewAmt: Decimal; var Amt: Decimal; var TotalAmt: Decimal; GetTotal: Boolean)
    begin
        if GetTotal then
            NewAmt := TotalAmt
        else begin
            NewAmt := Amt;
            TotalAmt := TotalAmt + Amt;
            Amt := 0;
        end;
    end;

    procedure GetInvtPostBuf(var InvtPostBuf: Record "Invt. Posting Buffer")
    begin
        InvtPostBuf.DeleteAll();

        GlobalInvtPostBuf.Reset();
        if GlobalInvtPostBuf.FindSet() then
            repeat
                InvtPostBuf := GlobalInvtPostBuf;
                InvtPostBuf.Insert();
            until GlobalInvtPostBuf.Next() = 0;
    end;

    local procedure GetInvPostingGroupCode(ValueEntry: Record "Value Entry"; WIPInventory: Boolean; InvPostingGroupCode: Code[20]): Code[20]
    var
        Item: Record Item;
    begin
        if WIPInventory then begin
            OnBeforeGetInvPostingGroupCode(ValueEntry, InvPostingGroupCode);
            if ValueEntry."Source No." <> ValueEntry."Item No." then
                if Item.Get(ValueEntry."Source No.") then
                    exit(Item."Inventory Posting Group");
        end;

        exit(InvPostingGroupCode);
    end;

    procedure CheckGenJnlLine(var GenJnlLine: Record "Gen. Journal Line")
    begin
        GenJnlCheckLine.RunCheck(GenJnlLine);
    end;

    procedure PostGenJnlLine(var GenJnlLine: Record "Gen. Journal Line")
    begin
        GenJnlPostLine.RunWithCheck(GenJnlLine);
    end;

    local procedure SetPostGrpsABC(ValueEntry: Record "Value Entry"; Resource: Record Resource; var InvtPostBuf: Record "Invt. Posting Buffer")
    begin
        // P8000375A, P8000466A
        with InvtPostBuf do begin
            "Location Code" := ValueEntry."Location Code";
            "Inventory Posting Group" := ValueEntry."Inventory Posting Group";
            "Gen. Bus. Posting Group" := ValueEntry."Gen. Bus. Posting Group";
            "Gen. Prod. Posting Group" := Resource."Gen. Prod. Posting Group";
        end;
    end;

    procedure GetGLRegister(var GLReg2: Record "G/L Register"; var NextVATEntryNo2: Integer; var NextTransactionNo2: Integer)
    begin
        GenJnlPostLine.GetGLRegister(GLReg2, NextVATEntryNo2, NextTransactionNo2); // P8000888
    end;

    procedure SetGLRegister(var GLReg2: Record "G/L Register"; NextVATEntryNo2: Integer; NextTransactionNo2: Integer)
    begin
        GenJnlPostLine.SetGLRegister(GLReg2, NextVATEntryNo2, NextTransactionNo2); // P8000888
    end;

    procedure ResetGLReg(): Boolean
    var
        GLReg: Record "G/L Register";
        LastGLReg: Record "G/L Register";
    begin
        // P8001227
        GenJnlPostLine.GetGLReg(GLReg);
        if (GLReg."No." <> 0) then begin
            LastGLReg.FindLast;
            exit(LastGLReg."No." <> GLReg."No.");
        end;
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterBufferCapacityPosting(var ValueEntry: Record "Value Entry"; var CostToPost: Decimal; var CostToPostACY: Decimal)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterBufferConsumpPosting(var TempInvtPostingBuffer: Record "Invt. Posting Buffer" temporary; ValueEntry: Record "Value Entry"; var PostBufDimNo: Integer; var CostToPost: Decimal; var CostToPostACY: Decimal)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterBufferOutputPosting(var ValueEntry: Record "Value Entry"; var CostToPost: Decimal; var CostToPostACY: Decimal; var ExpCostToPost: Decimal; var ExpCostToPostACY: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBufferPosting(var ValueEntry: Record "Value Entry"; var CostToPost: Decimal; var CostToPostACY: Decimal; var ExpCostToPost: Decimal; var ExpCostToPostACY: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBufferSalesPosting(var TempInvtPostingBuffer: Record "Invt. Posting Buffer" temporary; ValueEntry: Record "Value Entry"; var PostBufDimNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcCostToPostFromBuffer(var ValueEntry: Record "Value Entry"; var CostToPost: Decimal; var CostToPostACY: Decimal; var ExpCostToPost: Decimal; var ExpCostToPostACY: Decimal; var PostToGL: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGLItemLedgRelationInsert()
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnAfterInitInvtPostBuf(var ValueEntry: Record "Value Entry")
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnAfterInitTempInvtPostBuf(var TempInvtPostBuf: Record "Invt. Posting Buffer" temporary; ValueEntry: Record "Value Entry"; PostBufDimNo: Integer)
    begin
        // P80073095 - Clear Dimensions fronm TempInvtPostBuf
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRun(var ValueEntry: Record "Value Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetAccNo(var InvtPostingBuffer: Record "Invt. Posting Buffer"; ValueEntry: Record "Value Entry"; CalledFromItemPosting: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetDesc(var GenJnlLine: Record "Gen. Journal Line"; var InvtPostBuf: Record "Invt. Posting Buffer")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetAmt(var GenJnlLine: Record "Gen. Journal Line"; Amt: Decimal; AmtACY: Decimal; var HasAmountToPost: Boolean)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnBeforeBufferAdjmtPosting(var ValueEntry: Record "Value Entry"; var GlobalInvtPostBuf: Record "Invt. Posting Buffer"; CostToPost: Decimal; CostToPostACY: Decimal; ExpCostToPost: Decimal; ExpCostToPostACY: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeBufferInvtPosting(var ValueEntry: Record "Value Entry"; var Result: Boolean; var IsHandled: Boolean; RunOnlyCheck: Boolean; CalledFromTestReport: Boolean)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnBeforeBufferOutputPosting(var ValueEntry: Record "Value Entry"; var GlobalInvtPostBuf: Record "Invt. Posting Buffer"; CostToPost: Decimal; CostToPostACY: Decimal; ExpCostToPost: Decimal; ExpCostToPostACY: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeBufferPosting(var ValueEntry: Record "Value Entry"; var CostToPost: Decimal; var CostToPostACY: Decimal; var ExpCostToPost: Decimal; var ExpCostToPostACY: Decimal)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnBeforeBufferPurchPosting(var ValueEntry: Record "Value Entry"; var GlobalInvtPostBuf: Record "Invt. Posting Buffer"; CostToPost: Decimal; CostToPostACY: Decimal; ExpCostToPost: Decimal; ExpCostToPostACY: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnBeforeBufferSalesPosting(var ValueEntry: Record "Value Entry"; var GlobalInvtPostBuf: Record "Invt. Posting Buffer"; CostToPost: Decimal; CostToPostACY: Decimal; ExpCostToPost: Decimal; ExpCostToPostACY: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckGLAcc(var AccountNo: Code[20]; CalledFromItemPosting: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckInvtPostBuf(var GenJournalLine: Record "Gen. Journal Line"; var InvtPostingBuffer: Record "Invt. Posting Buffer"; ValueEntry: Record "Value Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetInvPostingGroupCode(var ValueEntry: Record "Value Entry"; var InvPostingGroupCode: Code[20])
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnBeforeInitInvtPostBuf(var ValueEntry: Record "Value Entry")
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnBeforeInitInvtPostBufPerAccount(var ValueEntry: Record "Value Entry"; AccType: Enum "Invt. Posting Buffer Account Type"; BalAccType: Enum "Invt. Posting Buffer Account Type"; CostToPost: Decimal; CostToPostACY: Decimal; InterimAccount: Boolean; BalancingRecord: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostInvtPostBuf(var GenJournalLine: Record "Gen. Journal Line"; var InvtPostingBuffer: Record "Invt. Posting Buffer"; ValueEntry: Record "Value Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetInvtPostSetup(var InventoryPostingSetup: Record "Inventory Posting Setup"; LocationCode: Code[10]; InventoryPostingGroup: Code[20]; var GenPostingSetup: Record "General Posting Setup"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGLItemLedgRelationInsert(var GLItemLedgerRelation: Record "G/L - Item Ledger Relation"; InvtPostingBuffer: Record "Invt. Posting Buffer"; GLRegister: Record "G/L Register"; TempGLItemLedgerRelation: Record "G/L - Item Ledger Relation" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostInvtPostBufProcessGlobalInvtPostBuf(var GlobalInvtPostBuf: Record "Invt. Posting Buffer" temporary; var GenJnlLine: Record "Gen. Journal Line"; var ValueEntry: Record "Value Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; CalledFromItemPosting: Boolean; PostPerPostGroup: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetAccNo(var InvtPostBuf: Record "Invt. Posting Buffer"; ValueEntry: Record "Value Entry"; AccType: Option; BalAccType: Option; CalledFromItemPosting: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnRun(var ValueEntry: Record "Value Entry"; PostPerPostGroup: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertTempInvtPostToGLTestBufOnBeforeInsert(var TempInvtPostToGLTestBuf: Record "Invt. Post to G/L Test Buffer" temporary; ValueEntry: Record "Value Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertTempInvtPostToGLTestBufOnBeforeTempInvtPostToGLTestBufInsert(var TempInvtPostToGLTestBuf: Record "Invt. Post to G/L Test Buffer" temporary; GenJournalLine: Record "Gen. Journal Line"; ValueEntry: Record "Value Entry")
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnPostInvtPostBufferOnBeforeFind(var GlobalInvtPostBuf: Record "Invt. Posting Buffer"; var TempGLItemLedgRelation: Record "G/L - Item Ledger Relation"; var ValueEntry: Record "Value Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostInvtPostBufOnAfterInitGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; var ValueEntry: Record "Value Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostInvtPostBufferOnAfterPostInvtPostBuf(var GlobalInvtPostBuf: Record "Invt. Posting Buffer"; var ValueEntry: Record "Value Entry"; CalledFromItemPosting: Boolean; CalledFromTestReport: Boolean; RunOnlyCheck: Boolean; PostPerPostGrp: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostInvtPostBufOnAfterUpdateGlobalDimFromDimSetID(var GenJournalLine: Record "Gen. Journal Line"; var GlobalInvtPostBuf: Record "Invt. Posting Buffer" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostInvtPostBufOnBeforeSetAmt(var GenJournalLine: Record "Gen. Journal Line"; var ValueEntry: Record "Value Entry"; var GlobalInvtPostingBuffer: Record "Invt. Posting Buffer")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostInvtPostBufProcessGlobalInvtPostBufOnAfterSetAmt(var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostInvtPostBufProcessGlobalInvtPostBufOnAfterSetDesc(var GenJournalLine: Record "Gen. Journal Line"; var GlobalInvtPostBuf: Record "Invt. Posting Buffer" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetAccNoOnAfterGetPostingSetup(var InvtPostBuf: Record "Invt. Posting Buffer"; var InvtPostingSetup: Record "Inventory Posting Setup"; var GenPostingSetup: Record "General Posting Setup"; ValueEntry: Record "Value Entry"; UseInvtPostSetup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetAccNoOnBeforeCheckAccNo(var InvtPostBuf: Record "Invt. Posting Buffer"; InvtPostingSetup: Record "Inventory Posting Setup"; GenPostingSetup: Record "General Posting Setup"; CalledFromItemPosting: Boolean; var ValueEntry: Record "Value Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateGlobalInvtPostBufOnBeforeModify(var GlobalInvtPostBuf: Record "Invt. Posting Buffer"; TempInvtPostBuf: Record "Invt. Posting Buffer" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateGlobalInvtPostBufOnAfterCalcShouldInsertTempGLItemLedgRelation(var TempGLItemLedgerRelation: Record "G/L - Item Ledger Relation" temporary; TempInvtPostingBuffer: Record "Invt. Posting Buffer" temporary; ValueEntryNo: Integer; RunOnlyCheck: Boolean; CalledFromTestReport: Boolean; var ShouldInsertTempGLItemLedgRelation: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateValueEntryOnBeforeModify(var ValueEntry: Record "Value Entry"; InvtPostingBuffer: Record "Invt. Posting Buffer")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeBufferConsumpPosting(var ValueEntry: Record "Value Entry"; var GlobalInvtPostBuf: Record "Invt. Posting Buffer" temporary; CostToPost: Decimal; CostToPostACY: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfteUpdateReportAmounts(var GlobalInvtPostBuf: Record "Invt. Posting Buffer" temporary; var InvtAmt: Decimal; var InvtAdjmtAmt: Decimal)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeBufferAsmOutputPosting(var ValueEntry: Record "Value Entry"; var GlobalInvtPostBuf: Record "Invt. Posting Buffer" temporary; var CostToPost: Decimal; var CostToPostACY: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeBufferAsmConsumpPosting(var ValueEntry: Record "Value Entry"; var GlobalInvtPostBuf: Record "Invt. Posting Buffer" temporary; var CostToPost: Decimal; var CostToPostACY: Decimal; var IsHandled: Boolean)
    begin
    end;
}

