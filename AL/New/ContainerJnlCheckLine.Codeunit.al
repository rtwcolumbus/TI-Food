codeunit 37002568 "Container Jnl.-Check Line"
{
    // PR3.70.07
    // P8000140A, Myers Nissi, Jack Reynolds, 19 NOV 04
    //   Check container journal line prior to posting
    // 
    // PR3.70.09
    // P8000200A, Myers Nissi, Jack Reynolds, 02 MAR 05
    //   Allow posting serialized containers through the transfer orders
    // 
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add "Bin Code" and related logic
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

    TableNo = "Container Journal Line";

    trigger OnRun()
    begin
        RunCheck(Rec);
    end;

    var
        Text000: Label 'cannot be a closing date';
        InvSetup: Record "Inventory Setup";
        ContainerItem: Record Item;
        ContainerTracking: Record "Item Tracking Code";
        SerialNo: Record "Serial No. Information";
        DimMgt: Codeunit DimensionManagement;
        Text002: Label 'The combination of dimensions used in %1 %2, %3, %4 is blocked. %5';
        Text003: Label 'A dimension used in %1 %2, %3, %4 has caused an error. %5';
        Text004: Label '%1 %2 already exists';
        Text005: Label 'already exists';
        Text006: Label 'is not off-site';
        Text007: Label 'may not be ''%1''';
        Text008: Label 'is not at %1 ''%2''';
        Text009: Label 'is not in %1 ''%2''';

    procedure RunCheck(var ContJnlLine: Record "Container Journal Line")
    var
        UserSetupManagement: Codeunit "User Setup Management";
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        // P8001132 - remove parameter for JnlLineDim
        with ContJnlLine do begin
            if EmptyLine then
                exit;

            TestField("Container Item No.");
            TestField("Posting Date");
            TestField("Document No.");

            ContainerItem.Get("Container Item No.");
            if ContainerItem."Item Tracking Code" <> '' then begin
                ContainerTracking.Get(ContainerItem."Item Tracking Code");
                if ContainerTracking."SN Specific Tracking" then
                    TestField("Container Serial No.");
            end;

            InvSetup.Get;
            if "Location Code" = InvSetup."Offsite Cont. Location Code" then
                FieldError("Location Code", StrSubstNo(Text007, InvSetup."Offsite Cont. Location Code"));

            case "Entry Type" of
                "Entry Type"::Acquisition:
                    begin
                        if "Container Serial No." <> '' then begin
                            TestField(Quantity, 1);
                            if SerialNo.Get("Container Item No.", '', "Container Serial No.") then
                                FieldError("Container Serial No.", Text005);
                        end;
                        TestField("New Location Code", '');
                        if "Source Type" = "Source Type"::" " then
                            TestField("Source No.", '')
                        else
                            TestField("Source No.");
                    end;
                "Entry Type"::Transfer:
                    begin
                        if "New Location Code" = InvSetup."Offsite Cont. Location Code" then
                            FieldError("New Location Code", StrSubstNo(Text007, InvSetup."Offsite Cont. Location Code"));
                        if "Location Code" = "New Location Code" then
                            FieldError("New Location Code", StrSubstNo(Text007, "Location Code"));
                        if "Container Serial No." <> '' then begin
                            SerialNo.Get("Container Item No.", '', "Container Serial No.");
                            if not "Transfer Order" then begin // P8000200A
                                SerialNo.CalcFields("Container ID");
                                SerialNo.TestField("Container ID", '');
                                SerialNo.SetRange("Location Filter", "Location Code");
                                SerialNo.CalcFields(Inventory);
                                if SerialNo.Inventory <> 1 then
                                    FieldError("Container Serial No.", StrSubstNo(Text008, FieldCaption("Location Code"), "Location Code"));
                                // P8000631A
                                if ("Bin Code" <> '') then begin
                                    SerialNo.SetRange("Bin Filter", "Bin Code");
                                    SerialNo.CalcFields("Whse. Inventory");
                                    if SerialNo."Whse. Inventory" <> 1 then
                                        FieldError("Container Serial No.", StrSubstNo(Text009, FieldCaption("Bin Code"), "Bin Code"));
                                end;
                                // P8000631A
                            end;                               // P8000200A
                        end;
                        TestField("Source Type", "Source Type"::" ");
                        TestField("Source No.", '');
                    end;
                "Entry Type"::Return:
                    begin
                        TestField("Container Serial No.");
                        TestField("New Location Code", '');
                        SerialNo.Get("Container Item No.", '', "Container Serial No.");
                        SerialNo.SetRange("Location Filter", InvSetup."Offsite Cont. Location Code");
                        SerialNo.CalcFields(Inventory);
                        if SerialNo.Inventory <> 1 then
                            FieldError("Container Serial No.", Text006);
                        TestField("Source Type", SerialNo.OffSiteSourceTypeInt); // P8001323
                        TestField("Source No.", SerialNo.OffSiteSourceNo);
                    end;
                "Entry Type"::Disposal:
                    begin
                        TestField("New Location Code", '');
                        if "Container Serial No." <> '' then begin
                            SerialNo.Get("Container Item No.", '', "Container Serial No.");
                            SerialNo.CalcFields("Container ID");
                            SerialNo.TestField("Container ID", '');
                            SerialNo.SetRange("Location Filter", "Location Code");
                            SerialNo.CalcFields(Inventory);
                            if SerialNo.Inventory <> 1 then
                                FieldError("Container Serial No.", StrSubstNo(Text008, FieldCaption("Location Code"), "Location Code"));
                            // P8000631A
                            if ("Bin Code" <> '') then begin
                                SerialNo.SetRange("Bin Filter", "Bin Code");
                                SerialNo.CalcFields("Whse. Inventory");
                                if SerialNo."Whse. Inventory" <> 1 then
                                    FieldError("Container Serial No.", StrSubstNo(Text009, FieldCaption("Bin Code"), "Bin Code"));
                            end;
                            // P8000631A
                        end;
                        if "Source Type" = "Source Type"::" " then
                            TestField("Source No.", '')
                        else
                            TestField("Source No.");
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

            TableID[1] := DATABASE::Item;
            No[1] := "Container Item No.";
            TableID[2] := SourceTypeToTableID("Source Type");
            No[2] := "Source No.";
            if not DimMgt.CheckDimValuePosting(TableID, No, "Dimension Set ID") then // P8001132
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

