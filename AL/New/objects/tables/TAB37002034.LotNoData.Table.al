table 37002034 "Lot No. Data"
{
    // PRW17.10
    // P8001234, Columbus IT, Jack Reynolds, 01 NOV 13
    //    Support for custom lot number formats
    // 
    // PRW17.10.02
    // P8001268, Columbus IT, Jack Reynolds, 23 JAN 14
    //   Fix problem initializing from source when Item No. is blank
    // 
    // PRW17.10.03
    // P8001315, Columbus IT, Jack Reynolds, 23 APR 14
    //   Fix issue with ADC Receiving
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.01
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
    // PRW118.01
    // P800127049, To Increase, Jack Reynolds, 23 AUG 21
    //   Support for Inventory documents

    Caption = 'Lot No. Data';
    ReplicateData = false;

    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
            OptionCaption = ' ,Sales,Purchase,Manufacturing';
            OptionMembers = ,Sales,Purchase,Manufacturing;
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                Item: Record Item;
                ItemTrackingCode: Record "Item Tracking Code";
            begin
                if Item.Get("Item No.") then // P8001268
                    if Item."Item Tracking Code" <> '' then begin
                        ItemTrackingCode.Get(Item."Item Tracking Code");
                        if ItemTrackingCode."Lot Specific Tracking" then begin
                            "Lot Tracked" := true;
                            "Assignment Method" := Item."Lot No. Assignment Method";
                            "Source Code" := Item."Lot Nos.";
                            case Type of
                                Type::Sales:
                                    "Inbound Assignment" := ItemTrackingCode."Lot Sales Inbound Assignment";
                                Type::Purchase:
                                    "Inbound Assignment" := ItemTrackingCode."Lot Purch. Inbound Assignment";
                                Type::Manufacturing:
                                    "Inbound Assignment" := ItemTrackingCode."Lot Manuf. Inbound Assignment";
                                else
                                    "Inbound Assignment" := false;
                            end;
                        end;
                    end;
            end;
        }
        field(3; "Assignment Method"; Option)
        {
            Caption = 'Assignment Method';
            DataClassification = SystemMetadata;
            OptionCaption = 'No. Series,Doc. No.,Doc. No.+Suffix,Date,Date+Suffix,,,,,Custom';
            OptionMembers = "No. Series","Doc. No.","Doc. No.+Suffix",Date,"Date+Suffix",,,,,Custom;
        }
        field(4; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            DataClassification = SystemMetadata;
        }
        field(5; "Inbound Assignment"; Boolean)
        {
            Caption = 'Inbound Assignment';
            DataClassification = SystemMetadata;
        }
        field(6; "Lot Tracked"; Boolean)
        {
            Caption = 'Lot Tracked';
            DataClassification = SystemMetadata;
        }
        field(7; Sample; Boolean)
        {
            Caption = 'Sample';
            DataClassification = SystemMetadata;
        }
        field(11; Date; Date)
        {
            Caption = 'Date';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Sample then
                    exit;
            end;
        }
        field(12; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Sample then
                    exit;
            end;
        }
        field(13; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                SegmentValue: Record "Lot No. Segment Value";
            begin
                if Sample then
                    exit;

                if SegmentValue.Get(SegmentValue.Type::Location, "Location Code") then
                    "Location Segment" := SegmentValue."Segment Value";
            end;
        }
        field(14; "Resource No."; Code[20])
        {
            Caption = 'Resource No.';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                SegmentValue: Record "Lot No. Segment Value";
            begin
                if Sample then
                    exit;

                if SegmentValue.Get(SegmentValue.Type::Equipment, "Resource No.") then
                    "Equipment Segment" := SegmentValue."Segment Value";
            end;
        }
        field(15; "Work Shift Code"; Code[10])
        {
            Caption = 'Work Shift Code';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                SegmentValue: Record "Lot No. Segment Value";
            begin
                if Sample then
                    exit;

                if SegmentValue.Get(SegmentValue.Type::Shift, "Work Shift Code") then
                    "Shift Segment" := SegmentValue."Segment Value";
            end;
        }
        field(23; "Location Segment"; Code[5])
        {
            Caption = 'Location Segment';
            DataClassification = SystemMetadata;
        }
        field(24; "Equipment Segment"; Code[5])
        {
            Caption = 'Equipment Segment';
            DataClassification = SystemMetadata;
        }
        field(25; "Shift Segment"; Code[5])
        {
            Caption = 'Shift Segment';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; Type)
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label 'No document number is available to use for lot number.';
        Text002: Label 'No date is available to use for lot number.';
        Text003: Label 'Unable to assign lot numbers for %1.';
        CustomSpec: Text[250];

    procedure InitializeFromSourceRecord(SourceRec: Variant; AutoAssign: Boolean)
    var
        SourceRecRef: RecordRef;
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        ItemJnlLine: Record "Item Journal Line";
        InvtDocLine: Record "Invt. Document Line";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComp: Record "Prod. Order Component";
        WHActivityLine: Record "Warehouse Activity Line";
        RepackOrder: Record "Repack Order";
        CommManifestHeader: Record "Commodity Manifest Header";
        CommManifestLine: Record "Commodity Manifest Line";
        TrackingSpec: Record "Tracking Specification";
        Item: Record Item;
    begin
        SourceRecRef.GetTable(SourceRec);
        Init;

        case SourceRecRef.Number of
            DATABASE::"Sales Line":
                begin
                    SalesLine := SourceRec;
                    Type := Type::Sales;
                    Validate("Item No.", SalesLine."No.");
                    Validate(Date, SalesLine."Shipment Date");
                    Validate("Document No.", SalesLine."Document No.");
                    Validate("Location Code", SalesLine."Location Code");
                end;

            DATABASE::"Purchase Line":
                begin
                    PurchLine := SourceRec;
                    Type := Type::Purchase;
                    Validate("Item No.", PurchLine."No.");
                    Validate(Date, PurchLine."Expected Receipt Date");
                    Validate("Document No.", PurchLine."Document No.");
                    Validate("Location Code", PurchLine."Location Code");
                end;

            DATABASE::"Item Journal Line":
                begin
                    ItemJnlLine := SourceRec;
                    case ItemJnlLine."Entry Type" of
                        ItemJnlLine."Entry Type"::Purchase:
                            Type := Type::Sales;
                        ItemJnlLine."Entry Type"::Sale:
                            Type := Type::Purchase;
                        ItemJnlLine."Entry Type"::Output:
                            Type := Type::Manufacturing;
                    end;
                    Validate("Item No.", ItemJnlLine."Item No.");
                    Validate(Date, ItemJnlLine."Posting Date");
                    Validate("Document No.", ItemJnlLine."Document No.");
                    Validate("Location Code", ItemJnlLine."Location Code");
                    if Type = Type::Manufacturing then
                        if ProdOrderLine.Get(ProdOrderLine.Status::Released, ItemJnlLine."Order No.", ItemJnlLine."Order Line No.") then begin
                            Validate("Resource No.", ProdOrderLine."Equipment Code");
                            Validate("Work Shift Code", ProdOrderLine."Work Shift Code");
                        end;
                    if ItemJnlLine."Work Shift Code" <> '' then
                        Validate("Work Shift Code", ItemJnlLine."Work Shift Code");
                end;

            // P800127049
            Database::"Invt. Document Line":
                begin
                    InvtDocLine := SourceRec;
                    Validate("Item No.", InvtDocLine."Item No.");
                    Validate(Date, InvtDocLine."Posting Date");
                    Validate("Document No.", InvtDocLine."Document No.");
                    Validate("Location Code", InvtDocLine."Location Code");
                end;

            DATABASE::"Prod. Order Line":
                begin
                    ProdOrderLine := SourceRec;
                    Type := Type::Manufacturing;
                    Validate("Item No.", ProdOrderLine."Item No.");
                    Validate(Date, ProdOrderLine."Due Date");
                    Validate("Document No.", ProdOrderLine."Prod. Order No.");
                    Validate("Location Code", ProdOrderLine."Location Code");
                    Validate("Resource No.", ProdOrderLine."Equipment Code");
                    Validate("Work Shift Code", ProdOrderLine."Work Shift Code");
                end;

            DATABASE::"Prod. Order Component":
                begin
                    ProdOrderComp := SourceRec;
                    Validate("Item No.", ProdOrderComp."Item No.");
                    Validate(Date, ProdOrderComp."Due Date");
                    Validate("Document No.", ProdOrderComp."Prod. Order No.");
                    Validate("Location Code", ProdOrderComp."Location Code");
                    ProdOrderLine.Get(ProdOrderComp.Status, ProdOrderComp."Prod. Order No.", ProdOrderComp."Prod. Order Line No.");
                    Validate("Resource No.", ProdOrderLine."Equipment Code");
                    Validate("Work Shift Code", ProdOrderLine."Work Shift Code");
                end;

            DATABASE::"Warehouse Activity Line":
                begin
                    WHActivityLine := SourceRec;
                    Validate("Item No.", WHActivityLine."Item No.");
                    Validate(Date, WorkDate);
                    Validate("Document No.", WHActivityLine."Source No.");
                    Validate("Location Code", WHActivityLine."Location Code");
                end;

            DATABASE::"Repack Order":
                begin
                    RepackOrder := SourceRec;
                    Type := Type::Manufacturing;
                    Validate("Item No.", RepackOrder."Item No.");
                    if not AutoAssign then
                        Validate(Date, RepackOrder."Posting Date");
                    Validate("Document No.", RepackOrder."No.");
                    Validate("Location Code", RepackOrder."Repack Location");
                end;

            DATABASE::"Commodity Manifest Header":
                begin
                    CommManifestHeader := SourceRec;
                    Validate("Item No.", CommManifestHeader."Item No.");
                    Validate(Date, CommManifestHeader."Posting Date");
                    Validate("Document No.", CommManifestHeader."No.");
                    Validate("Location Code", CommManifestHeader."Location Code");
                end;

            DATABASE::"Commodity Manifest Line":
                begin
                    CommManifestLine := SourceRec;
                    CommManifestHeader.Get(CommManifestLine."Commodity Manifest No.");
                    Validate("Item No.", CommManifestHeader."Item No.");
                    Validate(Date, CommManifestLine."Received Date");
                    Validate("Document No.", CommManifestHeader."No.");
                    Validate("Location Code", CommManifestHeader."Location Code");
                end;

            DATABASE::"Tracking Specification":
                begin
                    TrackingSpec := SourceRec;
                    case TrackingSpec."Source Type" of
                        DATABASE::"Sales Line":
                            begin
                                SalesLine.Get(TrackingSpec."Source Subtype", TrackingSpec."Source ID", TrackingSpec."Source Ref. No.");
                                InitializeFromSourceRecord(SalesLine, false);
                            end;
                        DATABASE::"Purchase Line":
                            begin
                                PurchLine.Get(TrackingSpec."Source Subtype", TrackingSpec."Source ID", TrackingSpec."Source Ref. No.");
                                InitializeFromSourceRecord(PurchLine, false);
                            end;
                        DATABASE::"Item Journal Line":
                            begin
                                ItemJnlLine.Get(TrackingSpec."Source ID", TrackingSpec."Source Batch Name", TrackingSpec."Source Ref. No.");
                                InitializeFromSourceRecord(ItemJnlLine, false);
                            end;
                        DATABASE::"Prod. Order Line":
                            begin
                                ProdOrderLine.Get(TrackingSpec."Source Subtype", TrackingSpec."Source ID", TrackingSpec."Source Prod. Order Line");
                                InitializeFromSourceRecord(ProdOrderLine, false);
                            end;
                        DATABASE::"Prod. Order Component":
                            begin
                                ProdOrderComp.Get(TrackingSpec."Source Subtype", TrackingSpec."Source ID",
                                  TrackingSpec."Source Prod. Order Line", TrackingSpec."Source Ref. No.");
                                InitializeFromSourceRecord(ProdOrderComp, false);
                            end;
                        else begin
                                Validate("Item No.", TrackingSpec."Item No.");
                                Validate("Location Code", TrackingSpec."Location Code");
                            end;
                    end;
                end;

            else
                Error(Text003, SourceRecRef.Caption);
        end;
    end;

    procedure AssignLotNo() LotNo: Code[40]
    var
        LotNoData: Record "Lot No. Data";
        CustomFormatLine: Record "Lot No. Custom Format Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        P800ItemTracking: Codeunit "Process 800 Item Tracking";
        CustomFormat: Codeunit "Lot No. Custom Format";
        Segment: array[4] of Code[5];
        Cnt: Integer;
        SegmentNo: Integer;
        SegmentText: Text[3];
        Delimeter: Text[1];
        RegEx: Codeunit DotNet_Regex;
    begin
        case "Assignment Method" of
            "Assignment Method"::"No. Series":
                begin
                    TestField("Source Code");
                    if Date = 0D then
                        Date := Today;
                    LotNo := NoSeriesMgt.GetNextNo("Source Code", Date, true);
                end;
            "Assignment Method"::"Doc. No.", "Assignment Method"::"Doc. No.+Suffix":
                begin
                    if "Document No." = '' then
                        Error(Text001)
                    else
                        LotNo := "Document No.";
                end;
            "Assignment Method"::Date, "Assignment Method"::"Date+Suffix":
                begin
                    if Date = 0D then
                        Error(Text002)
                    else
                        LotNo := Format(Date, 6, '<Year,2><Month,2><Day,2>');
                end;
            "Assignment Method"::Custom:
                begin
                    CustomFormatLine.SetRange("Custom Format Code", "Source Code");
                    if CustomFormatLine.FindSet then
                        repeat
                            case CustomFormatLine.Type of
                                CustomFormatLine.Type::Code:
                                    LotNo := LotNo + CustomFormat.FormatSegment(CustomFormatLine."Segment Code", Rec);
                                CustomFormatLine.Type::Text:
                                    LotNo := LotNo + CustomFormatLine."Segment Code";
                            end;
                        until CustomFormatLine.Next = 0;

                    LotNo := ConvertStr(LotNo, CustomFormat.FormatSegment('SPACE', LotNoData), ' ');
                end;
        end;

        case "Assignment Method" of
            "Assignment Method"::"Doc. No.+Suffix", "Assignment Method"::"Date+Suffix":
                LotNo := StrSubstNo('%1-%2', LotNo, P800ItemTracking.GetUniqueSegmentNo(LotNo));
            "Assignment Method"::Custom:
                begin
                    Segment[4] := CustomFormat.FormatSegment('U*', LotNoData);
                    Segment[4] := CopyStr(Segment[4], 1, 2) + '\' + CopyStr(Segment[4], 3);
                    Delimeter := CopyStr(Segment[4], 1, 1);
                    if 0 <> StrPos(LotNo, Delimeter) then begin
                        Segment[1] := CustomFormat.FormatSegment('UUU', Rec);
                        Segment[2] := CustomFormat.FormatSegment('UU', Rec);
                        Segment[3] := CustomFormat.FormatSegment('U', Rec);
                        SegmentNo := P800ItemTracking.GetUniqueSegmentNo(RegEx.Replace(LotNo, Delimeter + '[U\*]*' + Delimeter, '')); // P80073095
                        SegmentText := Format(SegmentNo, 3, '<Integer,3><Filler,0>');
                        for Cnt := 1 to 3 do
                            LotNo := RegEx.Replace(LotNo, Segment[Cnt], CopyStr(SegmentText, Cnt)); // P80073095
                        LotNo := RegEx.Replace(LotNo, Segment[4], Format(SegmentNo)); // P80073095
                    end;
                end;
        end;
    end;

    procedure OKToAssign(): Boolean
    var
        CustomFormatLine: Record "Lot No. Custom Format Line";
        CustomFormat: Codeunit "Lot No. Custom Format";
    begin
        case "Assignment Method" of
            "Assignment Method"::"No. Series":
                exit("Source Code" <> '');
            "Assignment Method"::"Doc. No.", "Assignment Method"::"Doc. No.+Suffix":
                exit("Document No." <> '');
            "Assignment Method"::Date, "Assignment Method"::"Date+Suffix":
                exit(Date <> 0D);
            "Assignment Method"::Custom:
                begin
                    CustomFormatLine.SetRange("Custom Format Code", "Source Code");
                    CustomFormatLine.SetRange(Type, CustomFormatLine.Type::Code);
                    if CustomFormatLine.FindSet then
                        repeat
                            if not CustomFormat.CheckSegment(CustomFormatLine."Segment Code", Rec) then
                                exit(false);
                        until CustomFormatLine.Next = 0;
                    exit(true);
                end;
        end;
    end;

    procedure LotDataChanged(xLotNoData: Record "Lot No. Data"): Boolean
    var
        CustomFormatLine: Record "Lot No. Custom Format Line";
        CustomFormat: Codeunit "Lot No. Custom Format";
    begin
        if "Assignment Method" <> xLotNoData."Assignment Method" then
            exit(true);

        case "Assignment Method" of
            "Assignment Method"::"No. Series":
                exit("Source Code" <> xLotNoData."Source Code");
            "Assignment Method"::"Doc. No.", "Assignment Method"::"Doc. No.+Suffix":
                exit("Document No." <> xLotNoData."Document No.");
            "Assignment Method"::Date, "Assignment Method"::"Date+Suffix":
                exit(Date <> xLotNoData.Date);
            "Assignment Method"::Custom:
                begin
                    if "Source Code" <> xLotNoData."Source Code" then
                        exit(true);

                    CustomFormatLine.SetRange("Custom Format Code", "Source Code");
                    CustomFormatLine.SetRange(Type, CustomFormatLine.Type::Code);
                    if CustomFormatLine.FindSet then
                        repeat
                            if CustomFormat.SegmentChanged(CustomFormatLine."Segment Code", Rec, xLotNoData) then
                                exit(true);
                        until CustomFormatLine.Next = 0;
                end;
        end;
    end;

    procedure SetSampleData()
    var
        SegmentValue: Record "Lot No. Segment Value";
        Text001: Label 'DOC001';
    begin
        Sample := true;

        Date := Today;
        "Document No." := Text001;

        SegmentValue.SetRange(Type, SegmentValue.Type::Location);
        if SegmentValue.FindFirst then
            "Location Segment" := SegmentValue."Segment Value";

        SegmentValue.SetRange(Type, SegmentValue.Type::Equipment);
        if SegmentValue.FindFirst then
            "Equipment Segment" := SegmentValue."Segment Value";

        SegmentValue.SetRange(Type, SegmentValue.Type::Shift);
        if SegmentValue.FindFirst then
            "Shift Segment" := SegmentValue."Segment Value";
    end;
}

