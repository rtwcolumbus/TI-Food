codeunit 37002540 "Process 800 Q/C Functions"
{
    // PR3.70.02
    //   When creating Q/C test use Variant Type on item tests
    // 
    // PR3.70.07
    // P8000152A, Myers Nissi, Jack Reynolds, 26 NOV 04
    //   CreateQCData - move Lookup Target Value to q/c line
    //   UpdateLotSpecs - moves completed q/c results to lot specification table
    // 
    // PR4.00.02
    // P8000305A, VerticalSoft, Jack Reynolds, 27 FEB 06
    //   Fix problem with missing lot specification descriptions
    // 
    // PRW16.00.04
    // P8000856, VerticalSoft, Don Bresee, 24 AUG 10
    //   Add Commodity Class Costing granule
    // 
    // P8000902, Columbus IT, Don Bresee, 14 MAR 11
    //   Add Commodity Payment logic
    // 
    // PRW16.00.06
    // P8001050, Columbus IT, Jack Reynolds, 30 MAR 12
    //   Enter Q/C results from Purchase and Prod. Order Lines
    // 
    // P8001079, Columbus IT, Jack Reynolds, 15 JUN 12
    //    Support for selective re-tests
    // 
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001149, Columbus IT, Don Bresee, 25 APR 13
    //   Use lookup mode for Q/C Tests page (AddReTest)
    // 
    // PRW17.10.01
    // P8001250, Columbus IT, Jack Reynolds, 13 DEC 13
    //   Add additional Lot Info data when creating Q/C for purchase lines
    // 
    // PRW19.00.01
    // P8008351, To-Increase, Jack Reynolds, 26 JAN 17
    //   Support for Lot Creation Date and Country of Origin for multiple lots
    // 
    // PRW111.00.01
    // P80037569, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Develop QC skip logic
    // 
    // P80037637, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Develop threshhold results
    // 
    // P80037645, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Add UOM/Measuring Method
    // 
    // P80038815, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Certificate of Analysis changes
    // 
    // P80038824, To-Increase, Dayakar Battini, 08 JUN 18
    //   QC-Additions: Re-test flag
    // 
    // PRW119.03
    // P800122712, To Increase, Gangabhushan, 25 MAY 22
    //   Quality Control Samples

    trigger OnRun()
    begin
    end;

    var
        Item: Record Item;
        AverageData: Record "Quality Control Line" temporary;
        AverageCalculation: Record "Quality Control Line" temporary;
        CommItemMgmt: Codeunit "Commodity Item Management";
        CommCostMgmt: Codeunit "Commodity Cost Management";
        Text001: Label 'Test %1 requires a reason code.';
        ErrorMustPassResultEntryTxt: Label 'Result value for must pass line must be entered';
        TextError: Label 'ERROR';
        ErrorsExist: Label 'Averages contain errors.';
        SampleError: Label 'No samples have been defined.'; // P800122712
        SampleTxt: Label 'No samples have been posted.'; // P800122712
        QCLineError: Label '%1 is not defined for Quality Control Result Line. \ %2: %3, %4: %5, %6: %7'; // P800122712

    procedure CreateQCData(var Rec: Record "Lot No. Information"; TestNo: Integer)
    var
        DataCollectionLine: Record "Data Collection Line";
        QCHeader: Record "Quality Control Header";
        QCLine: Record "Quality Control Line";
    begin
        // CreateQCData
        with Rec do begin
            if QCHeader.Get("Item No.", "Variant Code", "Lot No.", TestNo) then // P8001050
                exit;                                                          // P8001050
                                                                               // P8001090
            DataCollectionLine.SetRange("Source ID", DATABASE::Item);
            //ItemTest.SETRANGE("Item No.","Item No.");
            DataCollectionLine.SetRange("Source Key 1", "Item No.");
            DataCollectionLine.SetRange(Type, DataCollectionLine.Type::"Q/C");
            DataCollectionLine.SetRange(Active, true);
            // P8001090
            // PR3.70.02 Begin
            if "Variant Code" = '' then
                DataCollectionLine.SetFilter("Variant Type", '%1|%2',                                                        // P8001090
                  DataCollectionLine."Variant Type"::"Item Only", DataCollectionLine."Variant Type"::"Item and Variant")     // P8001090
            else
                DataCollectionLine.SetFilter("Variant Type", '%1|%2',                                                        // P8001090
                  DataCollectionLine."Variant Type"::"Variant Only", DataCollectionLine."Variant Type"::"Item and Variant"); // P8001090
                                                                                                                             // PR3.70.02 End
            if DataCollectionLine.Find('-') then begin // P8001090
                CreateQCHeader(Rec, QCHeader, TestNo, false); // P8001079
                if (QCHeader.Status <> QCHeader.Status::Skip) then  // P80037569
                    repeat
                        CreateQCLine(QCHeader, DataCollectionLine, '', QCLine); // P8001079, P8001090
                    until DataCollectionLine.Next = 0; // P8001090
                                                       // P8000902
                Item.Get(QCHeader."Item No.");
                if (Item."Comm. Payment Class Code" <> '') then
                    CommCostMgmt.UpdateOrderOnQCTest(QCHeader);
                // P8000902
            end;
        end;
    end;

    local procedure CreateQCHeader(LotInfo: Record "Lot No. Information"; var QCHeader: Record "Quality Control Header"; TestNo: Integer; Retest: Boolean)
    begin
        // P8001079
        QCHeader.LockTable;
        QCHeader.SetRange("Item No.", LotInfo."Item No.");
        QCHeader.SetRange("Variant Code", LotInfo."Variant Code");
        QCHeader.SetRange("Lot No.", LotInfo."Lot No.");
        if TestNo <> 0 then begin
            QCHeader.SetRange("Test No.", TestNo);
            if QCHeader.Find('-') then
                exit
            else
                QCHeader."Test No." := TestNo;
        end else begin
            if QCHeader.Find('+') then
                QCHeader."Test No." += 1
            else
                QCHeader."Test No." := 1;
        end;
        QCHeader."Item No." := LotInfo."Item No.";
        QCHeader."Variant Code" := LotInfo."Variant Code";
        QCHeader."Lot No." := LotInfo."Lot No.";
        QCHeader.Init;
        QCHeader."Re-Test" := Retest;
        QCHeader.Insert;
    end;

    local procedure CreateQCLine(QCHeader: Record "Quality Control Header"; DataCollectionLine: Record "Data Collection Line"; ReasonCode: Code[10]; var QCLine: Record "Quality Control Line")
    begin
        // P8001079
        // P8001090 - replace ItemTest parameter with DataCollectionLine, replace in code below
        QCLine.Init;
        QCLine."Item No." := QCHeader."Item No.";
        QCLine."Variant Code" := QCHeader."Variant Code";
        QCLine."Lot No." := QCHeader."Lot No.";
        QCLine."Test No." := QCHeader."Test No.";
        QCLine."Test Code" := DataCollectionLine."Data Element Code";
        QCLine."Unit of Measure Code" := DataCollectionLine."Unit of Measure Code";  // P80037645
        QCLine."Measuring Method" := DataCollectionLine."Measuring Method";          // P80037645
        QCLine.Description := DataCollectionLine.Description;
        QCLine.Type := DataCollectionLine."Data Element Type";
        QCLine."Numeric Low Value" := DataCollectionLine."Numeric Low-Low Value";
        QCLine."Numeric Higher-Low Value" := DataCollectionLine."Numeric Low Value";  // P80037637
        QCLine."Numeric Target Value" := DataCollectionLine."Numeric Target Value";
        QCLine."Numeric High Value" := DataCollectionLine."Numeric High-High Value";
        QCLine."Numeric Lower-High Value" := DataCollectionLine."Numeric High Value"; // P80037637
        QCLine."Certificate of Analysis" := DataCollectionLine."Certificate of Analysis";
        QCLine."Threshold on COA" := DataCollectionLine."Threshold on COA";  // P80038815
        QCLine."Text Target Value" := DataCollectionLine."Text Target Value";
        QCLine."Boolean Target Value" := DataCollectionLine."Boolean Target Value";
        QCLine."Lookup Target Value" := DataCollectionLine."Lookup Target Value";
        QCLine."Must Pass" := DataCollectionLine."Must Pass";
        QCLine."Reason Code" := ReasonCode;
        QCLine."Line No." := DataCollectionLine."Line No."; // P8001090
        // P800122712
        QCLine."Sample Unit of Measure Code" := DataCollectionLine."Sample Unit of Measure Code";
        QCLine."Combine Samples" := DataCollectionLine."Combine Samples";
        QCLine."Sample Quantity" := DataCollectionLine."Sample Quantity";
        // P800122712
        QCLine.Insert;
    end;

    procedure UpdateLotSpecs(QCHeader: Record "Quality Control Header")
    var
        QCLine: Record "Quality Control Line";
        LotSpec: Record "Lot Specification";
        DataElement: Record "Data Collection Data Element";
    begin
        // P8000152A
        QCLine.SetRange("Item No.", QCHeader."Item No.");
        QCLine.SetRange("Variant Code", QCHeader."Variant Code");
        QCLine.SetRange("Lot No.", QCHeader."Lot No.");
        QCLine.SetRange("Test No.", QCHeader."Test No.");
        QCLine.SetFilter(Status, '%1|%2', QCLine.Status::Pass, QCLine.Status::Fail);
        if QCLine.Find('-') then
            repeat
                if not LotSpec.Get(QCLine."Item No.", QCLine."Variant Code", QCLine."Lot No.", QCLine."Test Code") then begin
                    LotSpec.Init;
                    LotSpec."Item No." := QCLine."Item No.";
                    LotSpec."Variant Code" := QCLine."Variant Code";
                    LotSpec."Lot No." := QCLine."Lot No.";
                    LotSpec."Data Element Code" := QCLine."Test Code";
                    // P80037645
                    if LotSpec."Data Element Code" <> '' then begin
                        DataElement.Get(LotSpec."Data Element Code");
                        LotSpec."Unit of Measure Code" := DataElement."Unit of Measure Code";
                        LotSpec."Measuring Method" := DataElement."Measuring Method";
                    end;
                    // P80037645
                    LotSpec.Description := QCLine.Description; // P8000305A
                    LotSpec.Type := QCLine.Type;
                    LotSpec.Insert;
                end;
                CopyQCLineToLotSpec(QCLine, LotSpec); // P80037659
                                                      // P8000856
                Item.Get(LotSpec."Item No.");
                if Item."Commodity Cost Item" then
                    CommItemMgmt.UpdatePeriodOnQCTest(LotSpec);
                // P8000856
                // P8000902
                if (Item."Comm. Payment Class Code" <> '') then
                    CommCostMgmt.UpdateOrderOnQCTest(QCHeader);
                // P8000902
                LotSpec.Modify;
            until QCLine.Next = 0;
    end;

    local procedure CopyQCLineToLotSpec(QCLine: Record "Quality Control Line"; var LotSpec: Record "Lot Specification")
    begin
        // P80037659
        LotSpec."Boolean Value" := QCLine."Boolean Result";
        LotSpec."Date Value" := QCLine."Date Result";
        LotSpec."Lookup Value" := QCLine."Lookup Result";
        LotSpec."Numeric Value" := QCLine."Numeric Result";
        LotSpec."Text Value" := QCLine."Text Result";
        LotSpec.Value := QCLine.Result;
        LotSpec."Quality Control Result" := true;
        LotSpec."Quality Control Test No." := QCLine."Test No.";
        LotSpec."Certificate of Analysis" := QCLine."Certificate of Analysis";
        LotSpec."Threshold on COA" := QCLine."Threshold on COA";  // P80038815
    end;

    procedure QCForPurchLine(PurchLine: Record "Purchase Line")
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
        ItemEntryRelation: Record "Item Entry Relation";
        ReservEntry: Record "Reservation Entry";
        TempLotInfo: Record "Lot No. Information" temporary;
    begin
        // P8001050
        PurchLine.TestField(Type, PurchLine.Type::Item);
        PurchRcptLine.SetCurrentKey("Order No.", "Order Line No.");
        PurchRcptLine.SetRange("Order No.", PurchLine."Document No.");
        PurchRcptLine.SetRange("Order Line No.", PurchLine."Line No.");
        if PurchRcptLine.FindSet then
            repeat
                if PurchRcptLine."Item Rcpt. Entry No." = 0 then begin
                    ItemEntryRelation.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Ref. No.");
                    ItemEntryRelation.SetRange("Source Type", DATABASE::"Purch. Rcpt. Line");
                    ItemEntryRelation.SetRange("Source ID", PurchRcptLine."Document No.");
                    ItemEntryRelation.SetRange("Source Ref. No.", PurchRcptLine."Line No.");
                    if ItemEntryRelation.FindSet then
                        repeat
                            TempLotInfo."Item No." := PurchLine."No.";
                            TempLotInfo."Variant Code" := PurchLine."Variant Code";
                            TempLotInfo."Lot No." := ItemEntryRelation."Lot No.";
                            if TempLotInfo.Insert then;
                        until ItemEntryRelation.Next = 0;
                end;
            until PurchRcptLine.Next = 0;

        ReservEntry.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name",
          "Source Prod. Order Line", "Source Ref. No.");
        ReservEntry.SetRange("Source Type", DATABASE::"Purchase Line");
        ReservEntry.SetRange("Source Subtype", PurchLine."Document Type");
        ReservEntry.SetRange("Source ID", PurchLine."Document No.");
        ReservEntry.SetRange("Source Ref. No.", PurchLine."Line No.");
        ReservEntry.SetFilter("Lot No.", '<>%1', '');
        if ReservEntry.FindSet then
            repeat
                TempLotInfo."Item No." := PurchLine."No.";
                TempLotInfo."Variant Code" := PurchLine."Variant Code";
                TempLotInfo."Lot No." := ReservEntry."Lot No.";
                // P8001250
                TempLotInfo."Supplier Lot No." := PurchLine."Supplier Lot No.";
                TempLotInfo."Source Type" := TempLotInfo."Source Type"::Vendor;
                TempLotInfo."Source No." := PurchLine."Buy-from Vendor No.";
                TempLotInfo."Receiving Reason Code" := PurchLine."Receiving Reason Code";
                TempLotInfo.Farm := PurchLine.Farm;
                TempLotInfo.Brand := PurchLine.Brand;
                TempLotInfo."Country/Region of Origin Code" := PurchLine."Country/Region of Origin Code";
                TempLotInfo."Creation Date" := PurchLine."Creation Date"; // P8008351
                                                                          // P8001250
                if TempLotInfo.Insert then;
            until ReservEntry.Next = 0;

        RunQCForLots(TempLotInfo);
    end;

    procedure QCForProdOrderLine(ProdOrderLine: Record "Prod. Order Line")
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ReservEntry: Record "Reservation Entry";
        TempLotInfo: Record "Lot No. Information" temporary;
    begin
        // P8001050
        ProdOrderLine.TestField(Status, ProdOrderLine.Status::Released);
        ItemLedgEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type"); // P8001132
        ItemLedgEntry.SetRange("Order Type", ItemLedgEntry."Order Type"::Production); // P8001132
        ItemLedgEntry.SetRange("Order No.", ProdOrderLine."Prod. Order No.");         // P8001132
        ItemLedgEntry.SetRange("Order Line No.", ProdOrderLine."Line No.");           // P8001132
        ItemLedgEntry.SetRange("Entry Type", ItemLedgEntry."Entry Type"::Output);
        ItemLedgEntry.SetFilter("Lot No.", '<>%1', '');
        if ItemLedgEntry.FindSet then
            repeat
                TempLotInfo."Item No." := ProdOrderLine."Item No.";
                TempLotInfo."Variant Code" := ProdOrderLine."Variant Code";
                TempLotInfo."Lot No." := ItemLedgEntry."Lot No.";
                if TempLotInfo.Insert then;
            until ItemLedgEntry.Next = 0;

        ReservEntry.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name",
          "Source Prod. Order Line", "Source Ref. No.");
        ReservEntry.SetRange("Source Type", DATABASE::"Prod. Order Line");
        ReservEntry.SetRange("Source Subtype", ProdOrderLine.Status);
        ReservEntry.SetRange("Source ID", ProdOrderLine."Prod. Order No.");
        ReservEntry.SetRange("Source Prod. Order Line", ProdOrderLine."Line No.");
        ReservEntry.SetRange("Source Ref. No.", 0);
        ReservEntry.SetFilter("Lot No.", '<>%1', '');
        if ReservEntry.FindSet then
            repeat
                TempLotInfo."Item No." := ProdOrderLine."Item No.";
                TempLotInfo."Variant Code" := ProdOrderLine."Variant Code";
                TempLotInfo."Lot No." := ReservEntry."Lot No.";
                if TempLotInfo.Insert then;
            until ReservEntry.Next = 0;

        RunQCForLots(TempLotInfo);
    end;

    local procedure RunQCForLots(var TempLotInfo: Record "Lot No. Information" temporary)
    var
        LotInfo: Record "Lot No. Information";
        QCActivities: Page "Open Q/C Activity List";
    begin
        // P8001050
        // First we need to create Lot Info records if they do not already exist
        // ... while we're at it we can also create the Q/C tests
        if TempLotInfo.FindSet then
            repeat
                LotInfo := TempLotInfo;
                if not LotInfo.Find then begin
                    LotInfo.Validate("Item No.");
                    LotInfo.Insert;
                end;
                LotInfo.CalcFields("Quality Control");
                if not LotInfo."Quality Control" then
                    CreateQCData(LotInfo, 1);
            until TempLotInfo.Next = 0;

        Commit;

        QCActivities.MarkTestsToShow(TempLotInfo);
        QCActivities.Run;
    end;

    procedure AddTest(QCHeader: Record "Quality Control Header")
    var
        LotNoInfo: Record "Lot No. Information";
    begin
        LotNoInfo.Get(QCHeader."Item No.", QCHeader."Variant Code", QCHeader."Lot No.");
        if QCHeader."Re-Test" or (QCHeader.Status in [QCHeader.Status::Pass, QCHeader.Status::Fail, QCHeader.Status::Skip]) then
            AddTest(LotNoInfo, true)
        else
            AddTest(LotNoInfo, false);
    end;

    local procedure AddTest(LotInfo: Record "Lot No. Information"; Retest: Boolean)
    var
        Item: Record Item;
        DataCollectionLine: Record "Data Collection Line" temporary;
        QCHeader: Record "Quality Control Header";
        QCLine: Record "Quality Control Line";
        LotQualityTests: Page "Lot Quality Test Results";
        ReasonCode: Code[10];
        NoOfCopies: Integer;
        Cnt: Integer;
    begin
        // P8001079
        LotQualityTests.SetLot(LotInfo);
        LotQualityTests.SetReTest(Retest);
        // P8001149
        // IF LotQualityTests.RUNMODAL = ACTION::OK THEN BEGIN
        LotQualityTests.LookupMode(true);
        if LotQualityTests.RunModal = ACTION::LookupOK then begin
            // P8001149
            ReasonCode := LotQualityTests.GetReasonCode;
            NoOfCopies := LotQualityTests.GetNoOfCopies();
            LotQualityTests.GetTests(DataCollectionLine); // P8001090
            if DataCollectionLine.FindSet then begin      // P8001090
                for Cnt := 1 to NoOfCopies do begin
                    CreateQCHeader(LotInfo, QCHeader, 0, Retest);
                    if (QCHeader.Status <> QCHeader.Status::Skip) then  // P80037569
                        repeat
                            if DataCollectionLine."Re-Test Requires Reason Code" and (ReasonCode = '') and Retest then // P8001090
                                Error(Text001, DataCollectionLine."Data Element Code");                        // P8001090
                            CreateQCLine(QCHeader, DataCollectionLine, ReasonCode, QCLine);                    // P8001090
                        until DataCollectionLine.Next = 0;                                                // P8001090
                    DataCollectionLine.FindSet()
                end;
                Item.Get(QCHeader."Item No.");
                if (Item."Comm. Payment Class Code" <> '') then
                    CommCostMgmt.UpdateOrderOnQCTest(QCHeader);
            end;
        end;
    end;

    procedure StatusSuspendRequired(QCHeader: Record "Quality Control Header"; var DelegateSuspend: Boolean): Boolean
    var
        QCLine: Record "Quality Control Line";
    begin
        // P80037637
        DelegateSuspend := IsQCAdministrator;
        if QCHeader.Status = QCHeader.Status::Suspended then
            exit(true);

        QCLine.SetRange("Item No.", QCHeader."Item No.");
        QCLine.SetRange("Variant Code", QCHeader."Variant Code");
        QCLine.SetRange("Lot No.", QCHeader."Lot No.");
        QCLine.SetRange("Test No.", QCHeader."Test No.");
        QCLine.SetRange(Status, QCLine.Status::Suspended);
        if QCLine.IsEmpty then
            exit;

        exit(true);
        // P80037637
    end;

    procedure IsQCAdministrator(): Boolean
    var
        UserSetup: Record "User Setup";
    begin
        // P80037637
        if not UserSetup.Get(UserId) then
            exit(false);
        exit(UserSetup."Q/C Administrator");
        // P80037637
    end;

    procedure CheckQCLines(QCHeader: Record "Quality Control Header")
    var
        QCLine: Record "Quality Control Line";
        NullValue: Code[10];
    begin
        // P80037637
        QCLine.SetRange("Item No.", QCHeader."Item No.");
        QCLine.SetRange("Variant Code", QCHeader."Variant Code");
        QCLine.SetRange("Lot No.", QCHeader."Lot No.");
        QCLine.SetRange("Test No.", QCHeader."Test No.");
        QCLine.SetRange("Must Pass", true);
        if QCLine.IsEmpty then
            exit;
        QCLine.SetRange(Result, ' ');
        if not QCLine.IsEmpty then
            Error(ErrorMustPassResultEntryTxt);
        // P80037637
    end;

    procedure ClearAverageData()
    begin
        // P80037659
        AverageData.Reset;
        AverageData.DeleteAll;

        AverageCalculation.Reset;
        AverageCalculation.DeleteAll;
    end;

    procedure LoadAverageData(QualityControlHeader: Record "Quality Control Header")
    var
        QualityControlLine: Record "Quality Control Line";
        DataCollectionDataElement: Record "Data Collection Data Element";
    begin
        // P80037659
        QualityControlLine.SetRange("Item No.", QualityControlHeader."Item No.");
        QualityControlLine.SetRange("Variant Code", QualityControlHeader."Variant Code");
        QualityControlLine.SetRange("Lot No.", QualityControlHeader."Lot No.");
        QualityControlLine.SetRange("Test No.", QualityControlHeader."Test No.");
        if QualityControlLine.FindSet then
            repeat
                AverageData := QualityControlLine;
                AverageData.Insert;

                AverageCalculation := QualityControlLine;
                AverageCalculation."Test No." := 0;
                if not AverageCalculation.Find then begin
                    DataCollectionDataElement.Get(AverageCalculation."Test Code");
                    AverageCalculation."Averaging Method" := DataCollectionDataElement."Averaging Method";
                    AverageCalculation.Insert;
                end;
            until QualityControlLine.Next = 0;
    end;

    procedure RemoveAverageData(QualityControlHeader: Record "Quality Control Header")
    begin
        // P80037659
        AverageData.Reset;
        AverageData.SetRange("Item No.", QualityControlHeader."Item No.");
        AverageData.SetRange("Variant Code", QualityControlHeader."Variant Code");
        AverageData.SetRange("Lot No.", QualityControlHeader."Lot No.");
        AverageData.SetRange("Test No.", QualityControlHeader."Test No.");
        AverageData.DeleteAll;
    end;

    procedure CalculateAverage()
    begin
        // P80037659
        AverageData.Reset;

        if AverageCalculation.FindSet(true) then
            repeat
                AverageData.SetRange("Test Code", AverageCalculation."Test Code");
                if AverageData.FindSet then begin
                    case AverageCalculation."Averaging Method" of
                        AverageCalculation."Averaging Method"::First:
                            begin
                                AverageCalculation.Validate(Result, AverageData.Result);
                                AverageCalculation.Status := AverageData.Status;
                            end;
                        AverageCalculation."Averaging Method"::Last:
                            begin
                                AverageData.FindLast;
                                AverageCalculation.Validate(Result, AverageData.Result);
                                AverageCalculation.Status := AverageData.Status;
                            end;
                        AverageCalculation."Averaging Method"::Arithmetic:
                            begin
                                AverageCalculation."Numeric Result" := 0;
                                repeat
                                    AverageCalculation."Numeric Result" += AverageData."Numeric Result";
                                until AverageData.Next = 0;
                                AverageCalculation.Validate(Result,
                                  Format(AverageCalculation."Numeric Result" / AverageData.Count, 0, '<Precision,0:5><Integer><Decimals>'));
                            end;
                        AverageCalculation."Averaging Method"::Geometric:
                            begin
                                AverageCalculation.Result := '';
                                AverageCalculation."Numeric Result" := 1;
                                repeat
                                    if AverageData."Numeric Result" <= 0 then begin
                                        AverageCalculation.Result := TextError;
                                        AverageCalculation.Status := AverageCalculation.Status::"Not Tested";
                                        break;
                                    end else
                                        AverageCalculation."Numeric Result" *= AverageData."Numeric Result";
                                until AverageData.Next = 0;
                                if AverageCalculation.Result = '' then
                                    AverageCalculation.Validate(Result,
                                      Format(Power(AverageCalculation."Numeric Result", 1 / AverageData.Count), 0, '<Precision,0:5><Integer><Decimals>'));
                            end;
                        AverageCalculation."Averaging Method"::Harmonic:
                            begin
                                AverageCalculation.Result := '';
                                AverageCalculation."Numeric Result" := 0;
                                repeat
                                    if AverageData."Numeric Result" <= 0 then begin
                                        AverageCalculation.Result := TextError;
                                        AverageCalculation.Status := AverageCalculation.Status::"Not Tested";
                                        break;
                                    end else
                                        AverageCalculation."Numeric Result" += 1 / AverageData."Numeric Result";
                                until AverageData.Next = 0;
                                if AverageCalculation.Result = '' then
                                    AverageCalculation.Validate(Result,
                                      Format(AverageData.Count / AverageCalculation."Numeric Result", 0, '<Precision,0:5><Integer><Decimals>'));
                            end;
                        else begin
                                AverageCalculation.Result := '';
                                AverageCalculation.Status := AverageCalculation.Status::"Not Tested";
                            end;
                    end;
                    AverageCalculation.Modify;
                end else
                    AverageCalculation.Delete;
            until AverageCalculation.Next = 0;
    end;

    procedure GetAverageCalculation(var QualityControlLine: Record "Quality Control Line" temporary)
    begin
        // P80037659
        QualityControlLine.Copy(AverageCalculation, true);
    end;

    procedure UpdateLotSpecsWithAverages()
    var
        LotSpecification: Record "Lot Specification";
        Item: Record Item;
        QCHeader: Record "Quality Control Header";
    begin
        // P80037659
        AverageCalculation.Reset;
        if AverageCalculation.FindSet then begin
            Item.Get(AverageCalculation."Item No.");
            repeat
                if AverageCalculation.Result = TextError then
                    Error(ErrorsExist);
                if AverageCalculation.Status <> AverageCalculation.Status::"Not Tested" then begin
                    LotSpecification.Get(AverageCalculation."Item No.", AverageCalculation."Variant Code", AverageCalculation."Lot No.", AverageCalculation."Test Code");
                    CopyQCLineToLotSpec(AverageCalculation, LotSpecification);

                    if Item."Commodity Cost Item" then
                        CommItemMgmt.UpdatePeriodOnQCTest(LotSpecification);
                    LotSpecification.Modify;
                end;
            until AverageCalculation.Next = 0;

            if Item."Comm. Payment Class Code" <> '' then begin
                QCHeader.SetRange("Item No.", AverageCalculation."Item No.");
                QCHeader.SetRange("Variant Code", AverageCalculation."Variant Code");
                QCHeader.SetRange("Lot No.", AverageCalculation."Lot No.");
                QCHeader.FindFirst;
                CommCostMgmt.UpdateOrderOnQCTest(QCHeader);
            end;
        end;
    end;

    procedure RunQCSample(pQCHader: Record "Quality Control Header")
    var
        QCSample: Record "Quality Control Sample" temporary;
        QCSamplePage: Page "Quality Control SampleHdr.Page";
    begin
        // P800122712
        Sampling(pQCHader, QCSample);
        if QCSample.IsEmpty then
            Error(SampleError);
        QCSamplePage.SetSampleData(QCSample);
        QCSamplePage.Run;
    end;

    procedure Sampling(pQCHeader: Record "Quality Control Header"; var QCSample: Record "Quality Control Sample" temporary)
    var
        QualityControlLine, QualityControlLine2 : Record "Quality Control Line";
        InventorySetup: Record "Inventory Setup";
        SourceCodeSetup: Record "Source Code Setup";
        ItemUnitofMeasure: Record "Item Unit of Measure";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        UnitOfMeasureManagement: Codeunit "Unit of Measure Management";
    begin
        // P800122712
        QCSample.Reset();
        QCSample.DeleteAll();
        InventorySetup.Get();
        SourceCodeSetup.Get();
        if not InventorySetup."Samples Enabled" then
            exit;

        QCSample.Init();
        QCSample.Validate("Item No.", pQCHeader."Item No.");
        QCSample."Variant Code" := pQCHeader."Variant Code";
        QCSample."Lot No." := pQCHeader."Lot No.";
        QCSample."Test No." := pQCHeader."Test No.";
        QCSample."Reason Code" := InventorySetup."Default Sample Reason Code";
        QCSample."Source Code" := SourceCodeSetup."Quality Control Sample";
        QCSample."Posting Date" := WorkDate();
        QualityControlLine.SetRange("Item No.", pQCHeader."Item No.");
        QualityControlLine.SetRange("Variant Code", pQCHeader."Variant Code");
        QualityControlLine.SetRange("Lot No.", pQCHeader."Lot No.");
        QualityControlLine.SetRange("Test No.", pQCHeader."Test No.");
        QualityControlLine.SetFilter("Sample Quantity",'>0');
        QualityControlLine.SetRange("Combine Samples", false);
        if QualityControlLine.FindSet() then
            repeat
                CheckSampleUOMCode(QualityControlLine); // P800122712
                QCSample.LineNo += 10000;
                QCSample.Validate("Test Code", QualityControlLine."Test Code");
                QCSample.Validate("Unit of Measure Code", QualityControlLine."Sample Unit of Measure Code");
                QCSample.Validate("Sample Quantity", QualityControlLine."Sample Quantity");
                QCSample."Combine Samples" := QualityControlLine."Combine Samples";
                QCSample.Insert();
            until QualityControlLine.Next() = 0;

        QualityControlLine.SetRange("Combine Samples", true);
        if QualityControlLine.FindSet() then begin
            QCSample.LineNo += 10000;
            QCSample.Validate("Test Code", '');
            QCSample."Combine Samples" := QualityControlLine."Combine Samples";
            QCSample."Sample Quantity" := 0;
            QualityControlLine2.Copy(QualityControlLine);
            QualityControlLine2.SetFilter("Sample Unit of Measure Code", '<>%1', QualityControlLine."Sample Unit of Measure Code");
            if QualityControlLine2.IsEmpty then begin
                CheckSampleUOMCode(QualityControlLine); // P800122712
                QCSample.Validate("Unit of Measure Code", QualityControlLine."Sample Unit of Measure Code")
            end
            else
                QCSample.Validate("Unit of Measure Code", QCSample."Base Unit of Measure");
            repeat
                CheckSampleUOMCode(QualityControlLine); // P800122712
                if QCSample."Unit of Measure Code" <> QualityControlLine."Sample Unit of Measure Code" then begin
                    ItemUnitofMeasure.Get(QCSample."Item No.", QualityControlLine."Sample Unit of Measure Code");
                    QualityControlLine."Sample Quantity" *= ItemUnitofMeasure."Qty. per Unit of Measure";
                end;
                QCSample."Sample Quantity" += QualityControlLine."Sample Quantity";
            until QualityControlLine.Next() = 0;
            ItemUnitofMeasure.Get(QCSample."Item No.", QCSample."Unit of Measure Code");
            QCSample."Sample Quantity" := UnitOfMeasureManagement.RoundQty(QCSample."Sample Quantity", ItemUnitofMeasure."Rounding Precision");
            QCSample.Validate("Sample Quantity");
            QCSample.Insert();
        end;
    end;

    procedure PostSample(QCSampleHeader: Record "Quality Control Sample"; var QCSampleLine: Record "Quality Control Sample")
    var
        InventorySetup: Record "Inventory Setup";
        SourceCodeSetup: Record "Source Code Setup";
        ItemJournalLine: Record "Item Journal Line";
        AlternateQuantityLine: Record "Alternate Quantity Line";
        LotNoInfo: Record "Lot No. Information";
        ReservEntry: Record "Reservation Entry";
        TrackingSpecification: Record "Tracking Specification";
        Location: Record Location;
        Item: Record Item;
        AltQtyManagement: Codeunit "Alt. Qty. Management";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        WhseJnlRegisterLine: Codeunit "Whse. Jnl.-Register Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        DocNo: Code[20];
        ItemJournalLine2: Record "Item Journal Line";
    begin
        // P800122712
        SourceCodeSetup.Get();
        InventorySetup.Get();
        if InventorySetup."Sample Document No. Series" <> '' then
            DocNo := NoSeriesManagement.GetNextNo(InventorySetup."Sample Document No. Series", WorkDate(), true);
        if QCSampleLine.FindSet() then
            repeat
                ItemJournalLine.Init();
                ItemJournalLine.Validate("Posting Date", QCSampleHeader."Posting Date");
                ItemJournalLine."Document Date" := ItemJournalLine."Posting Date";
                ItemJournalLine.Validate("Document No.", DocNo);
                ItemJournalLine."Entry Type" := ItemJournalLine."Entry Type"::"Negative Adjmt.";
                ItemJournalLine."Source Code" := QCSampleHeader."Source Code";
                ItemJournalLine."Reason Code" := QCSampleHeader."Reason Code";
                ItemJournalLine.Validate("Item No.", QCSampleHeader."Item No.");
                ItemJournalLine.Validate("Variant Code", QCSampleHeader."Variant Code");
                ItemJournalLine.Validate("Unit of Measure Code", QCSampleLine."Unit of Measure Code");
                ItemJournalLine.Validate("Location Code", QCSampleHeader."Location Code");
                ItemJournalLine.Validate("Bin Code", QCSampleHeader."Bin Code");
                ItemJournalLine.Validate("Container License Plate", QCSampleHeader."Container License Plate");
                ItemJournalLine.Validate("Sample Test Code", QCSampleLine."Test Code");
                ItemJournalLine.Validate("Sample Test No.", QCSampleHeader."Test No.");
                ItemJournalLine.Validate(Quantity, QCSampleLine."Quanity to Post");
                Item.Get(QCSampleHeader."Item No.");
                if (QCSampleLine."Quantity to Post (Alt.)" <> 0) and Item."Catch Alternate Qtys." then begin
                    ItemJournalLine.Validate("Quantity (Alt.)", QCSampleLine."Quantity to Post (Alt.)");
                    AltQtyManagement.StartItemJnlAltQtyLine(ItemJournalLine);
                    AltQtyManagement.CreateAltQtyLine(AlternateQuantityLine, ItemJournalLine."Alt. Qty. Transaction No.",
                      10000, Database::"Item Journal Line", 0, '', '', '', 0);
                    AlternateQuantityLine."Lot No." := QCSampleHeader."Lot No.";
                    AlternateQuantityLine."Quantity (Base)" := ItemJournalLine."Quantity (Base)";
                    AlternateQuantityLine.Quantity := QCSampleLine."Sample Quantity";
                    AlternateQuantityLine."Quantity (Alt.)" := QCSampleLine."Quantity to Post (Alt.)";
                    AlternateQuantityLine."Invoiced Qty. (Alt.)" := QCSampleLine."Quantity to Post (Alt.)";
                    AlternateQuantityLine.Modify();
                end;
                ReservEntry."Lot No." := QCSampleHeader."Lot No.";
                CreateReservEntry.CreateReservEntryFor(
                  Database::"Item Journal Line", ItemJournalLine."Entry Type".AsInteger(), '', '', 0, 0,
                  ItemJournalLine."Qty. per Unit of Measure", ItemJournalLine.Quantity, ItemJournalLine."Quantity (Base)",
                  ReservEntry);
                CreateReservEntry.SetNewTrackingFromNewTrackingSpecification(TrackingSpecification);
                CreateReservEntry.AddAltQtyData(-ItemJournalLine."Quantity (Alt.)");
                CreateReservEntry.CreateEntry(ItemJournalLine."Item No.", ItemJournalLine."Variant Code",
                  ItemJournalLine."Location Code", ItemJournalLine.Description, 0D, ItemJournalLine."Posting Date", 0, "Reservation Status"::Prospect);

                ItemJournalLine.CreateDimFromDefaultDim(ItemJournalLine.FieldNo("Item No.")); // P800144605
                ItemJournalLine."Lot No." := ReservEntry."Lot No.";
                ItemJournalLine2 := ItemJournalLine;
                ItemJnlPostLine.RunWithCheck(ItemJournalLine);
                if Location.Get(ItemJournalLine."Location Code") then
                    if Location."Bin Mandatory" then begin
                        ItemJournalLine2."Quantity (Base)" := ItemJournalLine2.Quantity * ItemJournalLine2."Qty. per Unit of Measure";
                        RegisterWhseJnlLine(ItemJnlPostLine, WhseJnlRegisterLine, ItemJournalLine2);
                    end;
            until QCSampleLine.Next() = 0;
    end;

    local procedure RegisterWhseJnlLine(var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line"; var WhseJnlRegisterLine: Codeunit "Whse. Jnl.-Register Line"; ItemJournalLine: Record "Item Journal Line")
    var
        WarehouseJournalLine: Record "Warehouse Journal Line";
        Bin: Record Bin;
        WMSManagement: Codeunit "WMS Management";
        WhseManagement: Codeunit "Whse. Management";
    begin
        // P800122712
        if WMSManagement.CreateWhseJnlLine(ItemJournalLine, 1, WarehouseJournalLine, false) then begin
            WarehouseJournalLine."From Bin Code" := ItemJournalLine."Bin Code";
            Bin.GET(WarehouseJournalLine."Location Code", WarehouseJournalLine."From Bin Code");
            WarehouseJournalLine."From Zone Code" := Bin."Zone Code";
            Bin.GET(WarehouseJournalLine."Location Code", ItemJournalLine."Bin Code");
            WarehouseJournalLine."Entry Type" := WarehouseJournalLine."Entry Type"::"Negative Adjmt.";
            WarehouseJournalLine."Source Type" := Database::"Item Journal Line";
            WarehouseJournalLine."Source Subtype" := 0;
            WarehouseJournalLine."Source Document" := WhseManagement.GetSourceDocumentType(WarehouseJournalLine."Source Type", WarehouseJournalLine."Source Subtype");
            WarehouseJournalLine."Source No." := ItemJournalLine."Document No.";
            WarehouseJournalLine."Source Line No." := ItemJournalLine."Line No.";

            WMSManagement.CheckWhseJnlLine(WarehouseJournalLine, 1, 0, false);
            WhseJnlRegisterLine.RUN(WarehouseJournalLine);
        end;
    end;

    procedure GetSamplePosted(ItemNo: Code[20]; VariantCode: Code[20]; LotNo: Code[50]; TestNo: Integer): Decimal
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        // P800122712
        ItemLedgEntry.setrange("Item No.", ItemNo);
        ItemLedgEntry.setrange("Variant Code", VariantCode);
        ItemLedgEntry.setrange("Lot No.", LotNo);
        ItemLedgEntry.setrange("Sample Test No.", TestNo);
        ItemLedgEntry.CalcSums(Quantity);
        exit(Abs(ItemLedgEntry.Quantity));
    end;

    procedure CheckSampleLineExist(QCHeader: Record "Quality Control Header"): Boolean
    var
        QualityControlLine: Record "Quality Control Line";
    begin
        // P800122712
        QualityControlLine.Reset();
        QualityControlLine.SetRange("Item No.", QCHeader."Item No.");
        QualityControlLine.SetRange("Variant Code", QCHeader."Variant Code");
        QualityControlLine.SetRange("Lot No.", QCHeader."Lot No.");
        QualityControlLine.SetRange("Test No.", QCHeader."Test No.");
        QualityControlLine.SetFilter("Sample Quantity", '>%1', 0);
        exit(not QualityControlLine.IsEmpty);
    end;

    procedure SamplesEnabled(): Boolean
    var
        InventorySetup: Record "Inventory Setup";
    begin
        // P800122712
        InventorySetup.Get();
        exit(InventorySetup."Samples Enabled");
    end;

    procedure SetQCWarningText(QCHeader: Record "Quality Control Header"): Text
    var
        InventorySetup: Record "Inventory Setup";
    begin
        // P800122712
        InventorySetup.Get();
        if not InventorySetup."Suppress Sample Warning" then
            if CheckSampleLineExist(QCHeader) then
                if GetSamplePosted(QCHeader."Item No.", QCHeader."Variant Code", QCHeader."Lot No.", QCHeader."Test No.") = 0 then
                    exit(SampleTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInitItemLedgEntry', '', true, false)]
    local procedure ItemJnlPostLine_OnAfterInitItemLedgEntry(var NewItemLedgEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line")
    begin
        // P800122712
        NewItemLedgEntry."Sample Test Code" := ItemJournalLine."Sample Test Code";
        NewItemLedgEntry."Sample Test No." := ItemJournalLine."Sample Test No.";
    end;

    local procedure CheckSampleUOMCode(QualityControlLine: Record "Quality Control Line")
    begin
        // P800122712
        if QualityControlLine."Sample Unit of Measure Code" = '' then
            Error(QCLineError, QualityControlLine.FieldCaption("Sample Unit of Measure Code"), QualityControlLine.FieldCaption("Test Code"), QualityControlLine."Test Code",
                    QualityControlLine.FieldCaption("Lot No."), QualityControlLine."Lot No.", QualityControlLine.FieldCaption("Item No."), QualityControlLine."Item No.");
    end;

    // P800147282
    procedure AddDataElementsToItemQualityTestResult(LotInfo: Record "Lot No. Information"; var ItemQualityTestResult: Record "Item Quality Test Result" temporary)
    var
        DataElement: Record "Data Collection Data Element";
        ItemQualityTestResult2: Record "Item Quality Test Result" temporary;
        DataElementList: Page "Data Collection Data Elements";
        FilterString: Text;
    begin
        // Will show list of all data elements not already part of the Q/C Tests
        ItemQualityTestResult2.Copy(ItemQualityTestResult, true);
        ItemQualityTestResult2.Reset();
        if ItemQualityTestResult2.FindSet() then begin
            repeat
                FilterString += StrSubstNo('&<>%1', ItemQualityTestResult2.Code);
            until ItemQualityTestResult2.Next() = 0;
            FilterString := CopyStr(FilterString, 2);
        end;

        DataElement.FilterGroup(2);
        DataElement.SetFilter(Code, FilterString);
        DataElement.FilterGroup(0);
        DataElementList.LookupMode := true;
        DataElementList.SetTableView(DataElement);
        if DataElementList.RunModal() = Action::LookupOK then begin
            DataElementList.SetSelectionFilter(DataElement);
            if DataElement.FindSet() then begin
                repeat
                    ItemQualityTestResult.Init();
                    ItemQualityTestResult."Item No." := LotInfo."Item No.";
                    ItemQualityTestResult."Variant Code" := LotInfo."Variant Code";
                    ItemQualityTestResult."Lot No." := LotInfo."Lot No.";
                    ItemQualityTestResult."Variant Type" := ItemQualityTestResult."Variant Type"::"Item and Variant";
                    ItemQualityTestResult.Include := true;
                    ItemQualityTestResult.Editable := true;
                    ItemQualityTestResult.Code := DataElement.Code;
                    ItemQualityTestResult.Description := DataElement.Description;
                    ItemQualityTestResult.Type := DataElement.Type;
                    ItemQualityTestResult.GetResults();
                    ItemQualityTestResult.Insert();
                until DataElement.Next() = 0;
            end;
        end;
    end;

    // P800147282
    procedure AddTemplatesToItemQualityTestResult(LotInfo: Record "Lot No. Information"; var ItemQualityTestResult: Record "Item Quality Test Result" temporary)
    var
        DataCollectionTemplate: Record "Data Collection Template";
        DataCollectionTemplates: Page "Data Collection Templates";
    begin
        DataCollectionTemplate.FILTERGROUP(9);
        DataCollectionTemplate.SetRange(Type, DataCollectionTemplate.Type::"Q/C");
        DataCollectionTemplates.SetTableView(DataCollectionTemplate);
        DataCollectionTemplates.SetItem(LotInfo."Item No.");
        DataCollectionTemplates.LookupMode(true);
        if DataCollectionTemplates.RunModal() = Action::LookupOK then begin
            DataCollectionTemplates.GetSelectedTemplates(DataCollectionTemplate);
            if DataCollectionTemplate.FindSet() then
                    repeat
                        AddTemplateToItemQualityTestResult(DataCollectionTemplate, LotInfo, ItemQualityTestResult);
                    until DataCollectionTemplate.NEXT = 0;
        end;
    end;

    // P800147282
    local procedure AddTemplateToItemQualityTestResult(DataCollectionTemplate: Record "Data Collection Template";LotInfo: Record "Lot No. Information"; var ItemQualityTestResult: Record "Item Quality Test Result" temporary)
    var
        ItemQualityTestResult2: Record "Item Quality Test Result" temporary;
        DataCollectionTemplateLine: Record "Data Collection Template Line";
        DataCollectionLine: Record "Data Collection Line";
        DataCollectionManagement: Codeunit "Data Collection Management";
    begin
        ItemQualityTestResult2.Copy(ItemQualityTestResult, true);
        ItemQualityTestResult2.Reset();
        DataCollectionTemplateLine.SetRange("Template Code", DataCollectionTemplate.Code);
        if DataCollectionTemplateLine.FindSet then
            repeat
                ItemQualityTestResult2.SetRange(Code, DataCollectionTemplateLine."Data Element Code");
                if ItemQualityTestResult2.IsEmpty() then begin
                    ItemQualityTestResult.Init();
                    ItemQualityTestResult."Item No." := LotInfo."Item No.";
                    ItemQualityTestResult."Variant Code" := LotInfo."Variant Code";
                    ItemQualityTestResult."Lot No." := LotInfo."Lot No.";
                    ItemQualityTestResult."Variant Type" := ItemQualityTestResult."Variant Type"::"Item and Variant";
                    ItemQualityTestResult.Include := true;
                    ItemQualityTestResult.Editable := true;
                    ItemQualityTestResult.Code := DataCollectionTemplateLine."Data Element Code";
                    ItemQualityTestResult.Description := DataCollectionTemplateLine.Description;
                    ItemQualityTestResult.Type := DataCollectionTemplateLine."Data Element Type";
                    ItemQualityTestResult."Boolean Target Value" := DataCollectionTemplateLine."Boolean Target Value";
                    ItemQualityTestResult."Lookup Target Value" := DataCollectionTemplateLine."Lookup Target Value";
                    ItemQualityTestResult."Numeric Low-Low Value" := DataCollectionTemplateLine."Numeric Low-Low Value";
                    ItemQualityTestResult."Numeric Low Value" := DataCollectionTemplateLine."Numeric Low Value";
                    ItemQualityTestResult."Numeric Target Value" := DataCollectionTemplateLine."Numeric Target Value";
                    ItemQualityTestResult."Numeric High Value" := DataCollectionTemplateLine."Numeric High Value";
                    ItemQualityTestResult."Numeric High-High Value" := DataCollectionTemplateLine."Numeric High-High Value";
                    ItemQualityTestResult."Text Target Value" := DataCollectionTemplateLine."Text Target Value";
                    ItemQualityTestResult."Certificate of Analysis" := DataCollectionTemplateLine."Certificate of Analysis";
                    ItemQualityTestResult."Must Pass" := DataCollectionTemplateLine."Must Pass";

                    DataCollectionLine."Source Key 1" := LotInfo."Item No.";
                    DataCollectionManagement.CopySampleFields(DataCollectionTemplateLine, DataCollectionLine);
                    ItemQualityTestResult."Sample Quantity" := DataCollectionLine."Sample Quantity";
                    ItemQualityTestResult."Sample Unit of Measure Code" := DataCollectionLine."Sample Unit of Measure Code";
                    ItemQualityTestResult."Combine Samples" := DataCollectionLine."Combine Samples";

                    ItemQualityTestResult.GetResults();
                    ItemQualityTestResult.Insert();
                end;
            until DataCollectionTemplateLine.Next() = 0;
    end;
}

