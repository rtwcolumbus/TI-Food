codeunit 37002121 "Accrual Jnl.-Check Line"
{
    // PR3.61AC
    // 
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW111.00.02
    // P80068489, To-Increase, Gangabhushan, 31 DEC 18
    //   TI-12522 - VAT issues for accruals process - RunCheckGL modified
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    TableNo = "Accrual Journal Line";

    trigger OnRun()
    begin
        RunCheck(Rec);
    end;

    var
        Text000: Label 'cannot be a closing date';
        Text002: Label 'The combination of dimensions used in %1 %2, %3, %4 is blocked. %5';
        Text003: Label 'A dimension used in %1 %2, %3, %4 has caused an error. %5';
        AccrualPlan: Record "Accrual Plan";
        DimMgt: Codeunit DimensionManagement;

    procedure RunCheck(var AccrualJnlLine: Record "Accrual Journal Line")
    var
        UserSetupManagement: Codeunit "User Setup Management";
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        // P8001133 - remove parameter for JnlLineDim
        with AccrualJnlLine do begin
            if EmptyLine then
                exit;

            TestField("Accrual Plan No.");
            AccrualPlan.Get("Accrual Plan Type", "Accrual Plan No.");
            TestField("Posting Date");
            TestField(Amount);

            case "Entry Type" of
                "Entry Type"::Accrual:
                    if AccrualPlan."Use Accrual Schedule" then
                        TestField("Scheduled Accrual No.")
                    else begin
                        TestField(Type, "Accrual Plan Type");
                        TestField("No.");
                    end;
                "Entry Type"::Payment:
                    begin
                        if AccrualPlan."Use Payment Schedule" then
                            TestField("Scheduled Accrual No.")
                        else
                            TestField("No.");
                        if (AccrualPlan."Plan Type" = AccrualPlan."Plan Type"::Reporting) then
                            FieldError("Entry Type");
                    end;
            end;

            case "Source Document Type" of
                "Source Document Type"::Shipment,
              "Source Document Type"::Receipt:
                    if (AccrualPlan.Accrue <> AccrualPlan.Accrue::"Shipments/Receipts") then
                        FieldError("Source Document Type");
                "Source Document Type"::Invoice,
              "Source Document Type"::"Credit Memo":
                    if (AccrualPlan.Accrue = AccrualPlan.Accrue::"Shipments/Receipts") then
                        FieldError("Source Document Type");
            end;

            if not AccrualPlan."Use Accrual Schedule" then
                case AccrualPlan.GetPostingLevel("Entry Type") of
                    AccrualPlan."Accrual Posting Level"::Plan:
                        begin
                            TestField("Source No.", '');
                            TestField("Source Document Type", "Source Document Type"::None);
                        end;
                    AccrualPlan."Accrual Posting Level"::Source:
                        begin
                            TestField("Source No.");
                            TestField("Source Document Type", "Source Document Type"::None);
                        end;
                    AccrualPlan."Accrual Posting Level"::Document:
                        begin
                            TestField("Source No.");
                            TestField("Source Document Type");
                            TestField("Source Document No.");
                            TestField("Source Document Line No.", 0);
                        end;
                    AccrualPlan."Accrual Posting Level"::"Document Line":
                        begin
                            TestField("Source No.");
                            TestField("Source Document Type");
                            TestField("Source Document No.");
                            TestField("Source Document Line No.");
                            TestField("Item No.");
                        end;
                end;

            if NormalDate("Posting Date") <> "Posting Date" then
                FieldError("Posting Date", Text000);

            UserSetupManagement.CheckAllowedPostingDate("Posting Date"); // P80066030

            if ("Document Date" <> 0D) then
                if ("Document Date" <> NormalDate("Document Date")) then
                    FieldError("Document Date", Text000);

            if not DimMgt.CheckDimIDComb("Dimension Set ID") then // P8001133
                Error(
                  Text002,
                  TableCaption, "Journal Template Name", "Journal Batch Name", "Line No.",
                  DimMgt.GetDimCombErr);

            TableID[1] := DATABASE::"Accrual Plan";
            No[1] := "Accrual Plan No.";
            TableID[2] := TypeToTableID(Type);
            No[2] := "No.";
            TableID[3] := DATABASE::Item;
            No[3] := "Item No.";
            if not DimMgt.CheckDimValuePosting(TableID, No, "Dimension Set ID") then
                if "Line No." <> 0 then
                    Error(
                      Text003,
                      TableCaption, "Journal Template Name", "Journal Batch Name", "Line No.",
                      DimMgt.GetDimValuePostingErr)
                else
                    Error(DimMgt.GetDimValuePostingErr);
        end;
    end;

    procedure RunCheckGL(var GenJnlLine: Record "Gen. Journal Line")
    begin
        with GenJnlLine do begin
            if (("Account Type" = "Account Type"::FOODAccrualPlan) and ("Account No." <> '')) or
               (("Bal. Account Type" = "Bal. Account Type"::FOODAccrualPlan) and ("Bal. Account No." <> ''))
            then begin
                if ("Account Type" = "Account Type"::FOODAccrualPlan) and ("Account No." <> '') then begin
                    if not ("Bal. Account Type" in
                            ["Bal. Account Type"::"G/L Account",
                             "Bal. Account Type"::Customer,
                             "Bal. Account Type"::Vendor])
                    then
                        FieldError("Bal. Account Type");
                    AccrualPlan.Get("Accrual Plan Type", "Account No.");
                end else begin
                    if not ("Account Type" in
                            ["Account Type"::"G/L Account",
                             "Account Type"::Customer,
                             "Account Type"::Vendor])
                    then
                        FieldError("Account Type");
                    AccrualPlan.Get("Accrual Plan Type", "Bal. Account No.");
                    TestField("Bal. Gen. Posting Type", 0);
                end;

                if (AccrualPlan."Plan Type" = AccrualPlan."Plan Type"::Reporting) then
                    AccrualPlan.FieldError("Plan Type");

                case "Accrual Source Doc. Type" of
                    "Accrual Source Doc. Type"::Shipment,
                  "Accrual Source Doc. Type"::Receipt:
                        if (AccrualPlan.Accrue <> AccrualPlan.Accrue::"Shipments/Receipts") then
                            FieldError("Accrual Source Doc. Type");
                    "Accrual Source Doc. Type"::Invoice,
                  "Accrual Source Doc. Type"::"Credit Memo":
                        if (AccrualPlan.Accrue = AccrualPlan.Accrue::"Shipments/Receipts") then
                            FieldError("Accrual Source Doc. Type");
                end;

                case AccrualPlan.GetPostingLevel("Accrual Entry Type") of
                    AccrualPlan."Accrual Posting Level"::Plan:
                        begin
                            TestField("Accrual Source No.", '');
                            TestField("Accrual Source Doc. Type", "Accrual Source Doc. Type"::None);
                        end;
                    AccrualPlan."Accrual Posting Level"::Source:
                        begin
                            TestField("Accrual Source No.");
                            TestField("Accrual Source Doc. Type", "Accrual Source Doc. Type"::None);
                        end;
                    AccrualPlan."Accrual Posting Level"::Document:
                        begin
                            TestField("Accrual Source No.");
                            TestField("Accrual Source Doc. Type");
                            TestField("Accrual Source Doc. No.");
                            TestField("Accrual Source Doc. Line No.", 0);
                        end;
                    AccrualPlan."Accrual Posting Level"::"Document Line":
                        begin
                            TestField("Accrual Source No.");
                            TestField("Accrual Source Doc. Type");
                            TestField("Accrual Source Doc. No.");
                            TestField("Accrual Source Doc. Line No.");
                        end;
                end;
            end;
        end;
    end;
}

