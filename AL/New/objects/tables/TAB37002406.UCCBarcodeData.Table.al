table 37002406 "UCC Barcode Data"
{
    // PR4.00.04
    // P8000358A, VerticalSoft, Phyllis McGovern, 03 AUG 06
    //   Added field: 'HR UCC CODE'
    //   Added logic in 'ParseUCC' to GET ItemUOM and handle if not found.
    // 
    // PRW16.00.01
    // P8000703, VerticalSoft, Jack Reynolds, 15 JUN 09
    //   Allow a default list of application identifiers for UCC barcodes
    // 
    // PRW16.00.04
    // P8000873, VerticalSoft, Jack Reynolds, 29 SEP 10
    //   Support for 14-character UPC
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.01
    // P80062661, To-Increase, Jack Reynolds, 25 JUL 18
    //   SSCC
    // 
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    //
    // PRW117.3
    // P80096165 To Increase, Jack Reynolds, 10 FEB 21
    //   Upgrade to 17.3 - Item Reference replaces Item Cross Reference

    Caption = 'UCC Barcode Data';
    ReplicateData = false;

    fields
    {
        field(1; "UPC Code"; Code[20])
        {
            Caption = 'UPC Code';
            DataClassification = SystemMetadata;
        }
        field(10; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            DataClassification = SystemMetadata;
        }
        field(11; "Production Date"; Date)
        {
            Caption = 'Production Date';
            DataClassification = SystemMetadata;
        }
        field(13; "Packaging Date"; Date)
        {
            Caption = 'Packaging Date';
            DataClassification = SystemMetadata;
        }
        field(15; "Sell By Date"; Date)
        {
            Caption = 'Sell By Date';
            DataClassification = SystemMetadata;
        }
        field(17; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
            DataClassification = SystemMetadata;
        }
        field(21; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
            DataClassification = SystemMetadata;
        }
        field(310; "Net Weight (kg)"; Decimal)
        {
            Caption = 'Net Weight (kg)';
            DataClassification = SystemMetadata;
        }
        field(320; "Net Weight (lb)"; Decimal)
        {
            Caption = 'Net Weight (lb)';
            DataClassification = SystemMetadata;
        }
        field(10000; "UCC Code"; Text[250])
        {
            Caption = 'UCC Code';
            DataClassification = SystemMetadata;
        }
        field(10001; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                SetUPC;
                Item.Get("Item No.");
                if "Unit of Measure Code" = '' then
                    Validate("Unit of Measure Code", Item."Base Unit of Measure");
                Validate("Alternate Unit of Measure", Item."Alternate Unit of Measure");
                "Catch Alternate Qtys." := Item."Catch Alternate Qtys.";
            end;
        }
        field(10002; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                SetUPC;
            end;
        }
        field(10003; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                SetUPC;
                SetWeight(false);
            end;
        }
        field(10004; "Alternate Unit of Measure"; Code[10])
        {
            Caption = 'Alternate Unit of Measure';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                SetWeight(true);
            end;
        }
        field(10005; "Catch Alternate Qtys."; Boolean)
        {
            Caption = 'Catch Alternate Qtys.';
            DataClassification = SystemMetadata;
        }
        field(10006; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                SetWeight(false);
            end;
        }
        field(10007; "Quantity (Alt.)"; Decimal)
        {
            Caption = 'Quantity (Alt.)';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                SetWeight(true);
            end;
        }
        field(10008; "UCC Code (Human Readable)"; Text[250])
        {
            Caption = 'UCC Code (Human Readable)';
            DataClassification = SystemMetadata;
        }
        field(10100; "Container ID"; Code[20])
        {
            Caption = 'Container ID';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                // P80055555
                ContainerHeader.Get("Container ID");
                SSCC := ContainerHeader.SSCC;
            end;
        }
        field(10101; SSCC; Code[18])
        {
            Caption = 'SSCC';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "UCC Code")
        {
        }
    }

    var
        Item: Record Item;
        UOM: Record "Unit of Measure";
        ContainerHeader: Record "Container Header";
        UOMFns: Codeunit "Process 800 UOM Functions";

    procedure ParseUCC(): Boolean
    var
        UCCText: Text[250];
        ApplicationID: Text[3];
        Year: Integer;
        Month: Integer;
        Day: Integer;
        DateVar: Date;
        Decimals: Integer;
        DecimalVar: Decimal;
    begin
        UCCText := "UCC Code";
        Clear(Rec);

        while 0 < StrLen(UCCText) do begin
            if StrLen(UCCText) < 2 then
                exit(false);
            ApplicationID := CopyStr(UCCText, 1, 2);
            UCCText := CopyStr(UCCText, 3);
            case ApplicationID of
                // P8005555
                // SSCC
                '00':
                    if StrLen(UCCText) < 18 then
                        exit(false)
                    else begin
                        SSCC := UCCText;
                        UCCText := CopyStr(UCCText, 19);
                    end;
                // P8005555
                // UPC
                '01':
                    if StrLen(UCCText) < 14 then
                        exit(false)
                    else begin
                        "UPC Code" := CopyStr(UCCText, 1, 14); // P8000873
                        UCCText := CopyStr(UCCText, 15);
                    end;

                // Lot Number
                '10':
                    if 20 < StrLen(UCCText) then
                        exit(false)
                    else begin
                        "Lot No." := UCCText;
                        UCCText := '';
                    end;

                // Serial Number
                '21':
                    if 20 < StrLen(UCCText) then
                        exit(false)
                    else begin
                        "Serial No." := UCCText;
                        UCCText := '';
                    end;

                // Date
                '11', '13', '15', '17':
                    if StrLen(UCCText) < 6 then
                        exit(false)
                    else
                        if not Evaluate(Year, CopyStr(UCCText, 1, 2)) then
                            exit(false)
                        else
                            if not Evaluate(Month, CopyStr(UCCText, 3, 2)) then
                                exit(false)
                            else
                                if not Evaluate(Day, CopyStr(UCCText, 5, 2)) then
                                    exit(false)
                                else begin
                                    if Year <= 50 then
                                        Year := 2000 + Year
                                    else
                                        Year := 1900 + Year;
                                    if Day = 0 then
                                        Day := 1;
                                    if not Evaluate(DateVar, StrSubstNo('%1/%2/%3', Month, Day, Year)) then
                                        exit(false);
                                    case ApplicationID of
                                        '11':
                                            "Production Date" := DateVar;
                                        '13':
                                            "Packaging Date" := DateVar;
                                        '15':
                                            "Sell By Date" := DateVar;
                                        '17':
                                            "Expiration Date" := DateVar;
                                    end;
                                    UCCText := CopyStr(UCCText, 7);
                                end;

                // Weight, Volume, etc.
                '31', '32', '33', '34', '35', '36':
                    if StrLen(UCCText) < 8 then
                        exit(false)
                    else begin
                        ApplicationID := ApplicationID + CopyStr(UCCText, 1, 1);
                        if not Evaluate(Decimals, CopyStr(UCCText, 2, 1)) then
                            exit(false)
                        else
                            if not Evaluate(DecimalVar, CopyStr(UCCText, 3, 6)) then
                                exit(false);
                        DecimalVar := DecimalVar / Power(10, Decimals);
                        case ApplicationID of
                            '310':
                                "Net Weight (kg)" := DecimalVar;
                            '320':
                                "Net Weight (lb)" := DecimalVar;
                        end;
                        UCCText := CopyStr(UCCText, 9);
                    end;

                else
                    exit(false);
            end;
        end;

        LookupUPC;
        if UOM.Get("Unit of Measure Code") then begin // P8000358A
            CalcQuantity;
            CalcAlternateQty;
            // P8000358A
        end else begin
            Quantity := 0;
            "Quantity (Alt.)" := 0;
            "Item No." := '';
        end;
        // P8000358A

        LookupContainer; // P80055555

        exit(true);
    end;

    procedure CreateUCC(FldList: Text[50])
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        ApplicationID: Text[4];
        UCCText: Text[30];
        FldNo: Integer;
        LotSerial: Text[50];
        DateVar: Date;
        DecimalVar: Decimal;
        Decimals: Integer;
        HRLotSerial: Text[40];
    begin
        if FldList = '' then         // P8000703
            FldList := DefaultFldList; // P8000703

        RecRef.GetTable(Rec);

        "UCC Code" := '';                  // P8000873
        "UCC Code (Human Readable)" := ''; // P8000873

        while 0 < StrLen(FldList) do begin
            ApplicationID := CopyStr(FldList, 1, 2);

            case ApplicationID of
                // P80055555
                // SSCC
                '00':
                    begin
                        UCCText := SSCC;
                        FldList := CopyStr(FldList, 4);
                    end;
                // P80055555
                // UPC
                '01':
                    begin
                        // P8000873
                        if StrLen("UPC Code") = 14 then
                            UCCText := "UPC Code"
                        else begin
                            if "Alternate Unit of Measure" <> '' then
                                ApplicationID := '019'
                            else
                                ApplicationID := '011';
                            UCCText := PadStr('', 13 - StrLen("UPC Code"), '0') + "UPC Code";
                        end;
                        // P8000873
                        FldList := CopyStr(FldList, 4);
                    end;

                // Lot/Serial Number
                '10', '21':
                    begin
                        Evaluate(FldNo, ApplicationID);
                        FldRef := RecRef.Field(FldNo);
                        LotSerial := FldRef.Value;
                        HRLotSerial := '(' + ApplicationID + ')' + LotSerial; // P8000358A
                        LotSerial := ApplicationID + LotSerial;
                        ApplicationID := ''; // P8000873
                        FldList := CopyStr(FldList, 4);
                    end;

                // Date
                '11', '13', '15', '17':
                    begin
                        Evaluate(FldNo, ApplicationID);
                        FldRef := RecRef.Field(FldNo);
                        DateVar := FldRef.Value;
                        UCCText := Format(DateVar, 6, '<Year,2><Fill,0><Month,2><Day,2>'); // P8000873
                        FldList := CopyStr(FldList, 4);
                    end;

                // Weight, Volume, etc.
                '31', '32', '33', '34', '35', '36':
                    begin
                        Evaluate(FldNo, CopyStr(FldList, 1, 3));
                        FldRef := RecRef.Field(FldNo);
                        DecimalVar := FldRef.Value;
                        Evaluate(Decimals, CopyStr(FldList, 4, 1));
                        DecimalVar := DecimalVar * Power(10, Decimals);
                        UCCText := Format(DecimalVar, 0, '<Int,6><Fill,0>'); // P8000873
                        ApplicationID := CopyStr(FldList, 1, 4);             // P8000873
                        FldList := CopyStr(FldList, 6);
                    end;
            end;

            // P8000873
            if ApplicationID <> '' then begin
                "UCC Code" := "UCC Code" + ApplicationID + UCCText;
                "UCC Code (Human Readable)" := "UCC Code (Human Readable)" + StrSubstNo('(%1)%2', ApplicationID, UCCText);
            end;
            // P8000873
        end;

        "UCC Code" := "UCC Code" + LotSerial;
        "UCC Code (Human Readable)" := "UCC Code (Human Readable)" + HRLotSerial;
    end;

    local procedure LookupUPC()
    var
        ItemCrossReference: Record "Item Cross Reference";
        ItemReference: Record "Item Reference";
        ItemReferenceManagement: Codeunit "Item Reference Management";
        ItemReferenceEnabled: Boolean;
        Found: Boolean;
    begin
        // P80096165
        if "UPC Code" = '' then
            exit;

        ItemReferenceEnabled := ItemReferenceManagement.IsEnabled();
        if ItemReferenceEnabled then begin
            ItemReference.SetRange("Reference Type", "Item Reference Type"::"Bar Code");
            ItemReference.SetRange("Reference No.", "UPC Code");
            Found := ItemReference.FindFirst();
        end else begin
            ItemCrossReference.SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::"Bar Code");
            ItemCrossReference.SetRange("Cross-Reference No.", "UPC Code");
            ItemCrossReference.SetRange("Discontinue Bar Code", false);
            Found := ItemCrossReference.FindFirst();
        end;

        while (0 < StrLen("UPC Code")) and (not Found) do begin
            if ((StrLen("UPC Code") = 14) and ("UPC Code"[1] in ['1', '9'])) or
               ((StrLen("UPC Code") < 14) and ("UPC Code"[1] = '0'))
            then begin
                "UPC Code" := CopyStr("UPC Code", 2);
                if ItemReferenceEnabled then begin
                    ItemReference.SetRange("Reference No.", "UPC Code");
                    Found := ItemReference.FindFirst();
                end else begin
                    ItemCrossReference.SetRange("Cross-Reference No.", "UPC Code");
                    Found := ItemCrossReference.FindFirst();
                end;
            end else
                exit;
        end;
        if "UPC Code" = '' then
            exit;

        if ItemReferenceEnabled then begin
            "Item No." := ItemReference."Item No.";
            "Variant Code" := ItemReference."Variant Code";
            "Unit of Measure Code" := ItemReference."Unit of Measure";
        end else begin
            "Item No." := ItemCrossReference."Item No.";
            "Variant Code" := ItemCrossReference."Variant Code";
            "Unit of Measure Code" := ItemCrossReference."Unit of Measure";
        end;
        Item.Get("Item No.");
        if "Unit of Measure Code" = '' then
            "Unit of Measure Code" := Item."Base Unit of Measure";
        "Alternate Unit of Measure" := Item."Alternate Unit of Measure";
        "Catch Alternate Qtys." := Item."Catch Alternate Qtys.";
    end;

    local procedure SetUPC()
    var
        ItemCrossReference: Record "Item Cross Reference";
        ItemReference: Record "Item Reference";
        ItemReferenceManagement: Codeunit "Item Reference Management";
    begin
        // P80096165
        "UPC Code" := '';
        if ItemReferenceManagement.IsEnabled() then begin
            ItemReference.SetRange("Item No.", "Item No.");
            ItemReference.SetRange("Variant Code", "Variant Code");
            ItemReference.SetRange("Unit of Measure", "Unit of Measure Code");
            ItemReference.SetRange("Reference Type", "Item Reference Type"::"Bar Code");
            if ItemReference.FindFirst() then
                "UPC Code" := ItemReference."Reference No.";
        end else begin
            ItemCrossReference.SetRange("Item No.", "Item No.");
            ItemCrossReference.SetRange("Variant Code", "Variant Code");
            ItemCrossReference.SetRange("Unit of Measure", "Unit of Measure Code");
            ItemCrossReference.SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::"Bar Code");
            ItemCrossReference.SetRange("Discontinue Bar Code", false);
            if ItemCrossReference.FindFirst() then
                "UPC Code" := ItemCrossReference."Cross-Reference No.";
        end;
    end;

    local procedure SetWeight(Alternate: Boolean)
    var
        UOMCode: Code[10];
        Qty: Decimal;
    begin
        if ("Unit of Measure Code" <> '') and (Quantity <> 0) and (not Alternate) then begin
            UOMCode := "Unit of Measure Code";
            Qty := Quantity;
        end else
            if ("Alternate Unit of Measure" <> '') and ("Quantity (Alt.)" <> 0) and Alternate then begin
                UOMCode := "Alternate Unit of Measure";
                Qty := "Quantity (Alt.)";
            end else
                exit;

        UOM.Get(UOMCode);
        if UOM.Type <> UOM.Type::Weight then
            exit;

        "Net Weight (kg)" := Round(UOMFns.ConvertUOM(Qty, UOMCode, 'METRIC BASE') / 1000, 0.00001); // P8000703
        "Net Weight (lb)" := Round(UOMFns.ConvertUOM(Qty, UOMCode, 'CONVENTIONAL BASE'), 0.00001);  // P8000703
    end;

    local procedure CalcQuantity()
    begin
        UOM.Get("Unit of Measure Code");
        if UOM.Type = UOM.Type::Weight then
            Quantity := CalcWeightUOM("Unit of Measure Code")
        else
            Quantity := 1;
    end;

    local procedure CalcAlternateQty()
    begin
        if "Alternate Unit of Measure" = '' then
            exit;

        if "Unit of Measure Code" = "Alternate Unit of Measure" then begin
            "Quantity (Alt.)" := 1;
            exit;
        end;

        if not "Catch Alternate Qtys." then begin
            "Quantity (Alt.)" := Round(
              UOMFns.GetConversionFromTo("Item No.", "Unit of Measure Code", "Alternate Unit of Measure"), 0.00001);
            exit;
        end;

        UOM.Get("Alternate Unit of Measure");
        if UOM.Type = UOM.Type::Weight then
            "Quantity (Alt.)" := CalcWeightUOM("Alternate Unit of Measure");
    end;

    local procedure CalcWeightUOM(UOMCode: Code[10]): Decimal
    begin
        if "Net Weight (kg)" <> 0 then
            exit(Round(UOMFns.ConvertUOM(1000 * "Net Weight (kg)", 'METRIC BASE', UOMCode), 0.00001))
        else
            if "Net Weight (lb)" <> 0 then
                exit(Round(UOMFns.ConvertUOM("Net Weight (lb)", 'CONVENTIONAL BASE', UOMCode), 0.00001));
    end;

    local procedure LookupContainer()
    begin
        // P80055555
        ContainerHeader.SetRange(SSCC, SSCC);
        if ContainerHeader.FindFirst then
            "Container ID" := ContainerHeader.ID;
    end;

    local procedure DefaultFldList() FldList: Text[50]
    var
        InvSetup: Record "Inventory Setup";
        MeasSystem: Record "Measuring System";
        UOM: Record "Unit of Measure";
        Weight: Decimal;
        WeightText: Text[30];
    begin
        // P8000703
        if "Item No." <> '' then begin // P80055555
            FldList := '01';
            if "Lot No." <> '' then
                FldList := FldList + ',10';
            if ("Net Weight (kg)" = 0) or ("Net Weight (lb)" = 0) then
                exit;
            InvSetup.Get;
            MeasSystem.Get(InvSetup."Measuring System", MeasSystem.Type::Weight);
            if InvSetup."Measuring System" = InvSetup."Measuring System"::Conventional then begin
                UOM.Get(MeasSystem.UOM);
                Weight := "Net Weight (lb)";
                FldList := FldList + ',320'
            end else begin
                UOM.SetRange(UOM.Type, UOM.Type::Weight);
                UOM.SetRange("Base per Unit of Measure", 1000);
                if UOM.FindFirst then;
                Weight := "Net Weight (kg)";
                FldList := FldList + ',310'
            end;
            if UOM."Alt. Qty. Decimal Places" <> '' then
                FldList := FldList + CopyStr(UOM."Alt. Qty. Decimal Places", StrLen(UOM."Alt. Qty. Decimal Places"), 1)
            else begin
                Weight := Weight mod 1;
                if Weight = 0 then
                    FldList := FldList + '0'
                else begin
                    WeightText := Format(Weight);
                    FldList := FldList + Format(StrLen(WeightText) - 2);
                end;
            end;
            // P80055555
        end else
            if "Container ID" <> '' then
                FldList := '00';
        // P80055555
    end;
}

