table 37002494 "Pre-Process Activity Line"
{
    // PRW16.00.06
    // P8001082, Columbus IT, Don Bresee, 23 JAN 13
    //   Add Pre-Process functionality
    // 
    // PRW111.00.01
    // P80057829, To-Increase, Dayakar Battini, 27 APR 18
    //   Provide Container handling for non blending pre-process activities
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW119.0
    // P800133109, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 19.0 - Qty. Rounding Precision

    Caption = 'Pre-Process Activity Line';

    fields
    {
        field(1; "Activity No."; Code[20])
        {
            Caption = 'Activity No.';
            TableRelation = "Pre-Process Activity";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Editable = false;
            TableRelation = Item;
        }
        field(11; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            Editable = false;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(13; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            Editable = false;
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            var
                AltQtyMgmt: Codeunit "Alt. Qty. Management";
            begin
                InitContainerQtyToProcess("From Container ID", "Item No.", "Variant Code", "Lot No.", "Unit of Measure Code");  // P80057829
            end;
        }
        field(14; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
        }
        // P800133109
        field(15; "Qty. Rounding Precision"; Decimal)
        {
            Caption = 'Qty. Rounding Precision';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        // P800133109
        field(16; "Qty. Rounding Precision (Base)"; Decimal)
        {
            Caption = 'Qty. Rounding Precision (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(24; "Qty. to Process"; Decimal)
        {
            BlankZero = true;
            Caption = 'Qty. to Process';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            var
                ActivityLine: Record "Pre-Process Activity Line";
            begin
                "Qty. to Process" := UOMMgt.RoundAndValidateQty("Qty. to Process", "Qty. Rounding Precision", FieldCaption("Qty. to Process")); // P800133109
                Activity.Get("Activity No.");
                GetQtysFromOtherLines(ActivityLine);
                if ("Qty. to Process" > (Activity."Remaining Quantity" - ActivityLine."Qty. to Process")) then
                    Error(Text000, FieldCaption("Qty. to Process"), Activity."Remaining Quantity" - ActivityLine."Qty. to Process");
                if ("Qty. to Process" = (Activity."Remaining Quantity" - ActivityLine."Qty. to Process")) then
                    "Qty. to Process (Base)" := Activity."Remaining Qty. (Base)" - ActivityLine."Qty. to Process (Base)"
                else
                    "Qty. to Process (Base)" := CalcBaseQty("Qty. to Process", FieldCaption("Qty. to Process"), FieldCaption("Qty. to Process (Base)")); // P800133109
            end;
        }
        field(25; "Qty. to Process (Base)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Qty. to Process (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(30; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            TableRelation = "Lot No. Information"."Lot No." WHERE("Item No." = FIELD("Item No."),
                                                                   "Variant Code" = FIELD("Variant Code"));

            trigger OnValidate()
            var
                LotNoInfo: Record "Lot No. Information";
            begin
                if not IsLotTracked() then
                    TestField("Lot No.", '');
                if ("Lot No." <> xRec."Lot No.") and ("Lot No." <> '') then begin
                    LotNoInfo.Get("Item No.", "Variant Code", "Lot No.");
                    TestField("Quantity Processed", 0);
                    InitLotQtyToProcess;
                end;
                InitContainerQtyToProcess("From Container ID", "Item No.", "Variant Code", "Lot No.", "Unit of Measure Code");  // P80057829
            end;
        }
        field(33; "Quantity Processed"; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity Processed';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(34; "Qty. Processed (Base)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Qty. Processed (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(37002561; "From Container License Plate"; Code[50])
        {
            AccessByPermission = TableData "Container Header" = R;
            Caption = 'From Container License Plate';

            trigger OnValidate()
            var
                ContainerHeader: Record "Container Header";
                ContainerLine: Record "Container Line";
                ItemNo: Code[20];
                VariantCode: Code[10];
                LotNo: Code[50];
                UOMCode: Code[10];
            begin
                // P80057829
                Activity.Get("Activity No.");
                Activity.TestField(Blending, Activity.Blending::" ");

                CheckMoveContainer(FieldCaption("From Container License Plate"));

                if "From Container License Plate" <> xRec."From Container License Plate" then
                    if "From Container License Plate" = '' then
                        "From Container ID" := ''
                    else begin
                        ContainerHeader.SetRange("License Plate", "From Container License Plate");
                        ContainerHeader.SetRange("Location Code", Activity."Location Code");
                        if Activity."To Bin Code" <> '' then
                            ContainerHeader.SetRange("Bin Code", Activity."To Bin Code");
                        ContainerHeader.SetRange(Inbound, false);
                        ContainerHeader.FindFirst;

                        if ContainerHeader."Document Type" <> 0 then
                            Error(Text37002007, ContainerHeader.DocumentType, ContainerHeader."Document No.");

                        "From Container ID" := ContainerHeader.ID;
                        CheckFromContainer;

                        ContainerLine.SetRange("Container ID", "From Container ID");
                        if ContainerLine.FindFirst then begin
                            if "Item No." = '' then begin
                                ContainerLine.SetFilter("Item No.", '<>%1', ContainerLine."Item No.");
                                if ContainerLine.IsEmpty then
                                    ItemNo := ContainerLine."Item No.";
                                ContainerLine.SetRange("Item No.", ItemNo);
                            end else
                                ContainerLine.SetRange("Item No.", "Item No.");

                            if ("Item No." <> '') or (ItemNo <> '') then begin
                                if "Variant Code" = '' then begin
                                    ContainerLine.SetFilter("Variant Code", '<>%1', ContainerLine."Variant Code");
                                    if ContainerLine.IsEmpty then
                                        VariantCode := ContainerLine."Variant Code";
                                    ContainerLine.SetRange("Variant Code");
                                end;

                                if "Lot No." = '' then begin
                                    ContainerLine.SetFilter("Lot No.", '<>%1', ContainerLine."Lot No.");
                                    if ContainerLine.IsEmpty then
                                        LotNo := ContainerLine."Lot No.";
                                    ContainerLine.SetRange("Lot No.");
                                end;

                                if "Unit of Measure Code" = '' then begin
                                    ContainerLine.SetFilter("Unit of Measure Code", '<>%1', ContainerLine."Unit of Measure Code");
                                    if ContainerLine.IsEmpty then
                                        UOMCode := ContainerLine."Unit of Measure Code";
                                    ContainerLine.SetRange("Unit of Measure Code");
                                end;
                            end;

                            if ItemNo <> '' then
                                Validate("Item No.", ItemNo);
                            if "Variant Code" <> VariantCode then
                                Validate("Variant Code", VariantCode);
                            if LotNo <> '' then
                                Validate("Lot No.", LotNo);
                            if ("Unit of Measure Code" <> UOMCode) and (UOMCode <> '') then
                                Validate("Unit of Measure Code", UOMCode);
                        end;
                    end;
                InitContainerQtyToProcess("From Container ID", "Item No.", "Variant Code", "Lot No.", "Unit of Measure Code");  // P80057829
            end;
        }
        field(37002562; "From Container ID"; Code[20])
        {
            AccessByPermission = TableData "Container Header" = R;
            Caption = 'From Container ID';
        }
        field(37002563; "To Container License Plate"; Code[50])
        {
            AccessByPermission = TableData "Container Header" = R;
            Caption = 'To Container License Plate';

            trigger OnValidate()
            var
                ContainerHeader: Record "Container Header";
            begin
                // P80057829
                Activity.Get("Activity No.");
                Activity.TestField(Blending, Activity.Blending::" ");
                CheckMoveContainer(FieldCaption("To Container License Plate"));

                if "To Container License Plate" <> xRec."To Container License Plate" then
                    if "To Container License Plate" = '' then
                        "To Container ID" := ''
                    else begin
                        ContainerHeader.SetRange("License Plate", "To Container License Plate");
                        ContainerHeader.SetRange("Location Code", Activity."Location Code");
                        if (Activity."From Bin Code" <> '') then
                            ContainerHeader.SetRange("Bin Code", Activity."From Bin Code");
                        ContainerHeader.SetRange(Inbound, false);
                        ContainerHeader.FindFirst;

                        if ContainerHeader."Document Type" <> 0 then
                            Error(Text37002007, ContainerHeader.DocumentType, ContainerHeader."Document No.");

                        "To Container ID" := ContainerHeader.ID;
                        CheckToContainer;
                    end;
            end;
        }
        field(37002564; "To Container ID"; Code[20])
        {
            AccessByPermission = TableData "Container Header" = R;
            Caption = 'To Container ID';
        }
        field(37002565; "Container Master Line No."; Integer)
        {
            AccessByPermission = TableData "Container Header" = R;
            Caption = 'Container Master Line No.';
        }
    }

    keys
    {
        key(Key1; "Activity No.", "Line No.")
        {
            SumIndexFields = "Qty. to Process", "Qty. to Process (Base)", "Quantity Processed", "Qty. Processed (Base)";
        }
        key(Key2; "Activity No.", "Lot No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        UpdateActivity(true);
    end;

    trigger OnInsert()
    begin
        if IsLotTracked() then
            TestField("Lot No.");
        TestUniqueLotNo;
        UpdateActivity(false);
    end;

    trigger OnModify()
    begin
        if IsLotTracked() then
            TestField("Lot No.");
        TestUniqueLotNo;
        UpdateActivity(false);
    end;

    var
        Item: Record Item;
        Text000: Label '%1 cannot be more than %2.';
        Activity: Record "Pre-Process Activity";
        UOMMgt: Codeunit "Unit of Measure Management";
        ItemTrackingDataCollection: Codeunit "Item Tracking Data Collection";
        Text001: Label 'An Activity Line already exists.';
        Text002: Label 'An Activity Line for Lot No. %1 already exists.';
        Text37002000: Label '%1 cannot be changed when moving containers.';
        Text37002001: Label 'Container %1 is already being moved.';
        Text37002002: Label 'This will delete all lines for container %1.\Continue?''';
        Text37002003: Label 'To and From Bin Codes must be different when moving containers.';
        Text37002004: Label 'Item %1 is not allowed for container %2';
        Text37002005: Label 'Different lots for item %1 cannot be combined.';
        Text37002006: Label 'Container %1 cannot have multiple items.';
        Text37002007: Label 'Container has been assigned to %1 %2.';
        ContainerFns: Codeunit "Container Functions";
        Text37002008: Label 'Container quantity exceeds the remaining quantity to process.';

    local procedure CalcBaseQty(Qty: Decimal; FromFieldName: Text; ToFieldName: Text): Decimal
    begin
        // P800133109
        exit(UOMMgt.CalcBaseQty(
            "Item No.", "Variant Code", "Unit of Measure Code", Qty, "Qty. per Unit of Measure", "Qty. Rounding Precision (Base)", FieldCaption("Qty. Rounding Precision"), FromFieldName, ToFieldName));
    end;

    local procedure GetItem(ItemNo: Code[20])
    begin
        if (Item."No." <> ItemNo) then
            Item.Get(ItemNo);
    end;

    procedure InitRecord()
    begin
        Activity.Get("Activity No.");
        "Item No." := Activity."Item No.";
        "Variant Code" := Activity."Variant Code";
        "Unit of Measure Code" := Activity."Unit of Measure Code";
        "Qty. per Unit of Measure" := Activity."Qty. per Unit of Measure";
        // P800133109
        "Qty. Rounding Precision" := Activity."Qty. Rounding Precision";
        "Qty. Rounding Precision (Base)" := Activity."Qty. Rounding Precision (Base)";
        // P800133109
        InitQtyToProcess;
    end;

    procedure IsLotTracked(): Boolean
    begin
        GetItem("Item No.");
        exit(Item."Item Tracking Code" <> '');
    end;

    procedure InitQtyToProcess()
    var
        ActivityLine: Record "Pre-Process Activity Line";
    begin
        if IsLotTracked() then
            Validate("Qty. to Process", 0)
        else begin
            Activity.Get("Activity No.");
            GetQtysFromOtherLines(ActivityLine);
            Validate("Qty. to Process", Activity."Remaining Quantity" - ActivityLine."Qty. to Process");
        end;
    end;

    local procedure GetQtysFromOtherLines(var ActivityLine: Record "Pre-Process Activity Line")
    begin
        ActivityLine.Reset;
        ActivityLine.SetRange("Activity No.", "Activity No.");
        ActivityLine.SetFilter("Line No.", '<>%1', "Line No.");
        ActivityLine.CalcSums("Qty. to Process", "Qty. to Process (Base)");
    end;

    procedure InsertRecord(ActivityNo: Code[20]; LotNo: Code[50])
    begin
        Init;
        "Activity No." := ActivityNo;
        "Line No." := GetNextActivityLineNo(ActivityNo);
        InitRecord;
        "Lot No." := LotNo;
        Insert(true);
    end;

    local procedure GetNextActivityLineNo(ActivityNo: Code[20]): Integer
    var
        ActivityLine: Record "Pre-Process Activity Line";
    begin
        ActivityLine.SetRange("Activity No.", ActivityNo);
        if ActivityLine.FindLast then
            exit(ActivityLine."Line No." + 10000);
        exit(10000);
    end;

    local procedure UpdateActivity(Deleting: Boolean)
    var
        ActivityLine: Record "Pre-Process Activity Line";
    begin
        Activity.Get("Activity No.");
        GetQtysFromOtherLines(ActivityLine);
        if not Deleting then begin
            ActivityLine."Qty. to Process" += "Qty. to Process";
            ActivityLine."Qty. to Process (Base)" += "Qty. to Process (Base)";
        end;
        Activity."Qty. to Process" := ActivityLine."Qty. to Process";
        Activity."Qty. to Process (Base)" := ActivityLine."Qty. to Process (Base)";
        Activity.Modify;
    end;

    procedure AssistEditLotNo(): Boolean
    var
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        Activity.Get("Activity No.");
        GetItem("Item No.");
        ItemTrackingCode.Get(Item."Item Tracking Code");
        if not ItemTrackingDataCollection.CurrentDataSetMatches("Item No.", "Variant Code", Activity."Location Code") then
            Clear(ItemTrackingDataCollection);
        ItemTrackingDataCollection.SetCurrentBinAndItemTrkgCode(Activity."To Bin Code", ItemTrackingCode);

        TempTrackingSpecification.Init;
        TempTrackingSpecification."Item No." := "Item No.";
        TempTrackingSpecification."Location Code" := Activity."Location Code";
        TempTrackingSpecification.Description := Activity.Description;
        TempTrackingSpecification."Variant Code" := "Variant Code";
        TempTrackingSpecification."Quantity (Base)" := "Qty. to Process (Base)";
        TempTrackingSpecification."Qty. to Handle" := "Qty. to Process";
        TempTrackingSpecification."Qty. to Handle (Base)" := "Qty. to Process (Base)";
        TempTrackingSpecification."Qty. per Unit of Measure" := "Qty. per Unit of Measure";
        TempTrackingSpecification."Bin Code" := Activity."To Bin Code";
        ItemTrackingDataCollection.AssistEditTrackingNo(
          TempTrackingSpecification, true, -1, 1,
          Activity."Remaining Qty. (Base)" -
          (Activity."Qty. to Process (Base)" - xRec."Qty. to Process (Base)" + "Qty. to Process (Base)"));
        if TempTrackingSpecification."Lot No." <> '' then begin
            Validate("Lot No.", TempTrackingSpecification."Lot No.");
            InitLotQtyToProcess;
            exit(true);
        end;
    end;

    local procedure TestUniqueLotNo()
    var
        ActivityLine: Record "Pre-Process Activity Line";
    begin
        ActivityLine.SetCurrentKey("Activity No.", "Lot No.");
        ActivityLine.SetRange("Activity No.", "Activity No.");
        ActivityLine.SetFilter("Line No.", '<>%1', "Line No.");
        if not IsLotTracked() then begin
            if not ActivityLine.IsEmpty then
                Error(Text001);
        end else begin
            ActivityLine.SetRange("Lot No.", "Lot No.");
            if not ActivityLine.IsEmpty then
                Error(Text002, "Lot No.");
        end;
    end;

    local procedure InitLotQtyToProcess()
    var
        ActivityLine: Record "Pre-Process Activity Line";
    begin
        Activity.Get("Activity No.");
        GetQtysFromOtherLines(ActivityLine);
        "Qty. to Process" := Activity."Remaining Quantity" - ActivityLine."Qty. to Process";
        "Qty. to Process (Base)" := Activity."Remaining Qty. (Base)" - ActivityLine."Qty. to Process (Base)";
        Activity.ReduceFromBinQtys('', "Lot No.", "Qty. to Process", "Qty. to Process (Base)");
    end;

    local procedure CheckMoveContainer(FldCaption: Text)
    begin
        // P80057829
        if "Container Master Line No." <> 0 then
            Error(Text37002000, FldCaption);
    end;

    local procedure CheckFromContainer()
    var
        ContainerLine: Record "Container Line";
        ContainerHeader: Record "Container Header";
    begin
        // P80057829
        if "From Container ID" <> '' then begin
            ContainerLine.SetRange("Container ID", "From Container ID");
            if "Item No." <> '' then
                ContainerLine.SetRange("Item No.", "Item No.");
            if "Variant Code" <> '' then
                ContainerLine.SetRange("Variant Code", "Variant Code");
            if "Unit of Measure Code" <> '' then
                ContainerLine.SetRange("Unit of Measure Code", "Unit of Measure Code");
            if "Lot No." <> '' then
                ContainerLine.SetRange("Lot No.", "Lot No.");
            ContainerLine.SetFilter(Quantity, '>0');
            ContainerLine.FindFirst;
            ContainerHeader.Get(ContainerLine."Container ID");
            if "Qty. to Process (Base)" <> 0 then
                if ContainerLine."Quantity (Base)" > "Qty. to Process (Base)" then
                    Error(Text37002008);
        end;
    end;

    local procedure CheckToContainer()
    var
        Item: Record Item;
        ContainerHeader: Record "Container Header";
        ContainerLine: Record "Container Line";
        ContainerUsage: Record "Container Type Usage";
    begin
        // P80057829
        if "To Container ID" <> '' then begin
            TestField("Item No.");
            TestField("Unit of Measure Code");
            ContainerHeader.Get("To Container ID");

            Item.Get("Item No.");
            if not ContainerFns.GetContainerUsage(ContainerHeader."Container Type Code", Item."No.", Item."Item Category Code",
              "Unit of Measure Code", true, ContainerUsage)
            then
                Error(Text37002004, Item."No.", "To Container License Plate");

            if ContainerHeader."Document Type" = 0 then begin
                ContainerLine.SetRange("Container ID", "To Container ID");
                ContainerLine.SetFilter("Item No.", '<>%1', "Item No.");
                if not ContainerLine.IsEmpty then
                    Error(Text37002006, "To Container License Plate");

                if ContainerUsage."Single Lot" and ("Lot No." <> '') then begin
                    ContainerLine.SetRange("Item No.");
                    ContainerLine.SetFilter("Lot No.", '<>%1', "Lot No.");
                    ContainerLine.SetFilter("Variant Code", '<>%1', "Variant Code");
                    if not ContainerLine.IsEmpty then
                        Error(Text37002005, "Item No.");
                end;
            end;
        end;
    end;

    local procedure InitContainerQtyToProcess(FromContainerID: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; LotNo: Code[50]; UOMCode: Code[10])
    var
        ActivityLine: Record "Pre-Process Activity Line";
        ContainerLine: Record "Container Line";
    begin
        // P80057829
        ContainerLine.SetRange("Container ID", "From Container ID");
        ContainerLine.SetRange("Item No.", ItemNo);
        ContainerLine.SetRange("Variant Code", VariantCode);
        ContainerLine.SetRange("Lot No.", LotNo);
        ContainerLine.SetRange("Unit of Measure Code", UOMCode);
        if ContainerLine.FindFirst then;
        Activity.Get("Activity No.");
        GetQtysFromOtherLines(ActivityLine);
        "Qty. to Process" := Activity."Remaining Quantity" - ActivityLine."Qty. to Process";
        "Qty. to Process (Base)" := Activity."Remaining Qty. (Base)" - ActivityLine."Qty. to Process (Base)";
        if ("Qty. to Process (Base)" > ContainerLine."Quantity (Base)") then begin
            "Qty. to Process (Base)" := ContainerLine."Quantity (Base)";
            "Qty. to Process" := ContainerLine.Quantity
        end;
    end;
}

