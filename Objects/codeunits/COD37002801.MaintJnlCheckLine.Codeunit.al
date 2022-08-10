codeunit 37002801 "Maint. Jnl.-Check Line"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 31 AUG 06
    //   Standard checking function for maintenance journal lines
    // 
    // PRW16.00.06
    // P8001115, Columbus IT, Jack Reynolds, 08 NOV 12
    //   Fix problem posting to work orders without asset assigned
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    TableNo = "Maintenance Journal Line";

    trigger OnRun()
    begin
        RunCheck(Rec); // P8001133
    end;

    var
        Text000: Label 'cannot be a closing date';
        Text002: Label 'The combination of dimensions used in %1 %2, %3, %4 is blocked. %5';
        Text003: Label 'A dimension used in %1 %2, %3, %4 has caused an error. %5';
        MaintSetup: Record "Maintenance Setup";
        MaintLedger: Record "Maintenance Ledger";
        WorkOrder: Record "Work Order";
        DimMgt: Codeunit DimensionManagement;
        Text004: Label 'cannot be before %1 (%2)';
        Text005: Label 'cannot be after %1 (%2)';
        Text006: Label 'The grace period for posting has expired.';
        RemainingQuantity: Decimal;
        Text007: Label 'cannot exceed remaining quantity';

    procedure RunCheck(var MaintJnlLine: Record "Maintenance Journal Line")
    var
        UserSetupManagement: Codeunit "User Setup Management";
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        // P8001133 - remove parameter for JnlLineDim
        MaintSetup.Get;
        if Format(MaintSetup."Posting Grace Period") = '' then
            Evaluate(MaintSetup."Posting Grace Period", '0D');

        with MaintJnlLine do begin
            if EmptyLine then
                exit;

            TestField("Work Order No.");
            TestField("Posting Date");
            TestField("Document No.");

            WorkOrder.Get("Work Order No.");
            WorkOrder.TestField("Asset No."); // P8001115

            case "Entry Type" of
                "Entry Type"::Labor:
                    begin
                        TestField("Maintenance Trade Code");
                        if MaintSetup."Employee Mandatory" then
                            TestField("Employee No.");
                        TestField(Quantity);
                        if "Employee No." <> '' then begin
                            TableID[2] := DATABASE::Employee;
                            No[2] := "Employee No.";
                        end;
                    end;
                "Entry Type"::"Material-Stock":
                    begin
                        TestField("Item No.");
                        TestField(Quantity);
                    end;
                "Entry Type"::"Material-Nonstock":
                    begin
                        TestField("Part No.");
                        TestField(Quantity);
                        TestField("Unit of Measure Code");
                    end;
                "Entry Type"::Contract:
                    begin
                        TestField("Maintenance Trade Code");
                        if MaintSetup."Vendor Mandatory" then
                            TestField("Vendor No.");
                        TestField(Quantity);
                        if "Vendor No." <> '' then begin
                            TableID[2] := DATABASE::Vendor;
                            No[2] := "Vendor No.";
                        end;
                    end;
            end;

            if Quantity > 0 then
                TestField("Applies-to Entry", 0)
            else begin
                TestField("Applies-to Entry");
                MaintLedger.Get("Applies-to Entry");
                TestField("Posting Date", MaintLedger."Posting Date");
                TestField("Entry Type", MaintLedger."Entry Type");
                TestField("Work Order No.", MaintLedger."Work Order No.");
                case "Entry Type" of
                    "Entry Type"::Labor:
                        begin
                            TestField("Maintenance Trade Code", MaintLedger."Maintenance Trade Code");
                            if MaintSetup."Employee Mandatory" then
                                TestField("Employee No.", MaintLedger."Employee No.");
                        end;
                    "Entry Type"::"Material-Stock":
                        begin
                            TestField("Item No.", MaintLedger."Item No.");
                            TestField("Unit of Measure Code", MaintLedger."Unit of Measure Code");
                            TestField("Lot No.", MaintLedger."Lot No.");
                            TestField("Serial No.", MaintLedger."Serial No.");
                        end;
                    "Entry Type"::"Material-Nonstock":
                        begin
                            TestField("Part No.", MaintLedger."Part No.");
                            TestField("Unit of Measure Code", MaintLedger."Unit of Measure Code");
                        end;
                    "Entry Type"::Contract:
                        begin
                            TestField("Maintenance Trade Code", MaintLedger."Maintenance Trade Code");
                            if MaintSetup."Vendor Mandatory" then
                                TestField("Vendor No.", MaintLedger."Vendor No.");
                        end;
                end;

                RemainingQuantity := MaintLedger.Quantity;
                MaintLedger.SetCurrentKey("Applies-to Entry");
                MaintLedger.SetRange("Applies-to Entry", "Applies-to Entry");
                MaintLedger.CalcSums(Quantity);
                RemainingQuantity += MaintLedger.Quantity;
                if RemainingQuantity < Abs(Quantity) then
                    FieldError(Quantity, Text007);
            end;

            if NormalDate("Posting Date") <> "Posting Date" then
                FieldError("Posting Date", Text000);

            UserSetupManagement.CheckAllowedPostingDate("Posting Date"); // P80066030

            if "Posting Date" < WorkOrder."Origination Date" then
                FieldError("Posting Date",
                  StrSubstNo(Text004, WorkOrder.FieldCaption("Origination Date"), WorkOrder."Origination Date"));

            if (WorkOrder."Completion Date" <> 0D) and (WorkOrder."Completion Date" < "Posting Date") then
                FieldError("Posting Date",
                  StrSubstNo(Text005, WorkOrder.FieldCaption("Completion Date"), WorkOrder."Completion Date"));

            if WorkOrder."Completion Date" <> 0D then
                if CalcDate(MaintSetup."Posting Grace Period", WorkOrder."Completion Date") < WorkDate then
                    Error(Text006);

            if ("Document Date" <> 0D) then
                if ("Document Date" <> NormalDate("Document Date")) then
                    FieldError("Document Date", Text000);

            if not DimMgt.CheckDimIDComb("Dimension Set ID") then // P8001133
                Error(
                  Text002,
                  TableCaption, "Journal Template Name", "Journal Batch Name", "Line No.",
                  DimMgt.GetDimCombErr);

            TableID[1] := DATABASE::Asset;
            No[1] := WorkOrder."Asset No.";
            if not DimMgt.CheckDimValuePosting(TableID, No, "Dimension Set ID") then // P8001133
                if "Line No." <> 0 then
                    Error(
                      Text003,
                      TableCaption, "Journal Template Name", "Journal Batch Name", "Line No.",
                      DimMgt.GetDimValuePostingErr)
                else
                    Error(DimMgt.GetDimValuePostingErr);
        end;
    end;
}

