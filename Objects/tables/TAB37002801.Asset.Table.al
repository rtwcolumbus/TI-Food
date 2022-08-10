table 37002801 Asset
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 30 AUG 06
    //   Master table for assets
    // 
    // PR4.00.06
    // P8000470A, VerticalSoft, Jack Reynolds, 16 MAY 07
    //   Fix problem looking up list of spares for the asset
    // 
    // PRW15.00.01
    // P8000517A, VerticalSoft, Jack Reynolds, 13 SEP 07
    //   Utility function to get spare part record for specified item
    // 
    // PRW16.00
    // P8000639, VerticalSoft, Jack Reynolds, 18 NOV 08
    //   Add DropDown field group
    // 
    // PRW16.00.01
    // P8000717, VerticalSoft, Jack Reynolds, 10 AUG 09
    //   Add link to fixed asset
    // 
    // P8000718, VerticalSoft, Jack Reynolds, 10 AUG 09
    //   Add flowfield for downtime (from work order)
    // 
    // P8000725, VerticalSoft, Jack Reynolds, 27 AUG 09
    //   Support for Parent Asset No. and Asset Hierarchy
    // 
    // PRW16.00.20
    // P8000671, VerticalSoft, Jack Reynolds, 02 FEB 09
    //   Change SubType on Picture field
    // 
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.00
    // P8001149, Columbus IT, Don Bresee, 25 APR 13
    //   Use lookup mode for Asset Usage page
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW117.3
    // P80096165, To Increase, Jack Reynolds, 02 FEB 21
    //   Rename Comment Lines

    Caption = 'Asset';
    DataCaptionFields = "No.", Description;
    LookupPageID = "Asset List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    MaintSetup.Get;
                    NoSeriesMgt.TestManual(MaintSetup."Asset Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';

            trigger OnValidate()
            begin
                if ("Search Description" = UpperCase(xRec.Description)) or ("Search Description" = '') then
                    "Search Description" := Description;
            end;
        }
        field(3; "Description 2"; Text[30])
        {
            Caption = 'Description 2';
        }
        field(4; "Search Description"; Code[100])
        {
            Caption = 'Search Description';
        }
        field(5; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
        field(6; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(7; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Global Dimension 1 Code");
            end;
        }
        field(8; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Global Dimension 2 Code");
            end;
        }
        field(9; Comment; Boolean)
        {
            CalcFormula = Exist ("Comment Line" WHERE("Table Name" = CONST(FOODAsset),
                                                      "No." = FIELD("No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(10; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(11; "Global Dimension 1 Filter"; Code[20])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension 1 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(12; "Global Dimension 2 Filter"; Code[20])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension 2 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(13; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,Equipment,Vehicle,Facility';
            OptionMembers = " ",Equipment,Vehicle,Facility;
        }
        field(14; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;

            trigger OnValidate()
            var
                WorkOrder: Record "Work Order";
            begin
                if "Location Code" <> xRec."Location Code" then begin
                    WorkOrder.SetCurrentKey("Asset No.");
                    WorkOrder.SetRange("Asset No.", "No.");
                    WorkOrder.SetRange(Completed, false);
                    WorkOrder.SetRange("Location Code", xRec."Location Code");
                    if WorkOrder.FindSet(true, false) then
                        repeat
                            WorkOrder.Validate("Location Code", "Location Code");
                            WorkOrder.Modify;
                        until WorkOrder.Next = 0;
                end;
            end;
        }
        field(15; Picture; MediaSet)
        {
            Caption = 'Picture';
        }
        field(16; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'New,In Service,Out of Service,Deactivated';
            OptionMembers = New,"In Service","Out of Service",Deactivated;
        }
        field(17; "Resource No."; Code[20])
        {
            Caption = 'Resource No.';
            TableRelation = Resource WHERE(Type = CONST(Machine));

            trigger OnValidate()
            begin
                if "Resource No." <> '' then begin
                    Resource.Get("Resource No.");
                    "Location Code" := Resource."Location Code";
                end;
            end;
        }
        field(18; "Physical Location"; Code[20])
        {
            Caption = 'Physical Location';
        }
        field(19; "Total Cost"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum ("Maintenance Ledger"."Cost Amount" WHERE("Asset No." = FIELD("No."),
                                                                        "Posting Date" = FIELD("Date Filter"),
                                                                        "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                        "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter")));
            Caption = 'Total Cost';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "Labor Cost"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum ("Maintenance Ledger"."Cost Amount" WHERE("Asset No." = FIELD("No."),
                                                                        "Entry Type" = CONST(Labor),
                                                                        "Posting Date" = FIELD("Date Filter"),
                                                                        "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                        "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter")));
            Caption = 'Labor Cost';
            Editable = false;
            FieldClass = FlowField;
        }
        field(21; "Material Cost"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum ("Maintenance Ledger"."Cost Amount" WHERE("Asset No." = FIELD("No."),
                                                                        "Entry Type" = FILTER("Material-Stock" | "Material-NonStock"),
                                                                        "Posting Date" = FIELD("Date Filter"),
                                                                        "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                        "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter")));
            Caption = 'Material Cost';
            Editable = false;
            FieldClass = FlowField;
        }
        field(22; "Contract Cost"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum ("Maintenance Ledger"."Cost Amount" WHERE("Asset No." = FIELD("No."),
                                                                        "Entry Type" = CONST(Contract),
                                                                        "Posting Date" = FIELD("Date Filter"),
                                                                        "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                        "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter")));
            Caption = 'Contract Cost';
            Editable = false;
            FieldClass = FlowField;
        }
        field(23; "Asset Category Code"; Code[10])
        {
            Caption = 'Asset Category Code';
            TableRelation = "Asset Category";
        }
        field(24; "Fixed Asset No."; Code[20])
        {
            Caption = 'Fixed Asset No.';
            TableRelation = "Fixed Asset";
            ValidateTableRelation = false;
        }
        field(25; "Downtime (Hours)"; Decimal)
        {
            CalcFormula = Sum ("Work Order"."Downtime (Hours)" WHERE("Asset No." = FIELD("No."),
                                                                     Completed = CONST(true),
                                                                     "Completion Date" = FIELD("Date Filter")));
            Caption = 'Downtime (Hours)';
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(26; "Parent Asset No."; Code[20])
        {
            Caption = 'Parent Asset No.';
            TableRelation = Asset;
        }
        field(27; "Asset Hierarchy"; Code[85])
        {
            Caption = 'Asset Hierarchy';
            Editable = false;
            TableRelation = Asset;
            ValidateTableRelation = false;
        }
        field(41; "Manufacturer Code"; Code[10])
        {
            Caption = 'Manufacturer Code';
            TableRelation = Manufacturer;
        }
        field(42; "Model No."; Code[30])
        {
            Caption = 'Model No.';
        }
        field(43; "Model Year"; Integer)
        {
            Caption = 'Model Year';
        }
        field(44; "Serial No."; Code[30])
        {
            Caption = 'Serial No.';
        }
        field(45; VIN; Code[20])
        {
            Caption = 'VIN';
        }
        field(46; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;
        }
        field(47; "Registration No."; Code[20])
        {
            Caption = 'Registration No.';
        }
        field(48; "Registration Expiration Date"; Date)
        {
            Caption = 'Registration Expiration Date';
        }
        field(49; "Gross Weight"; Decimal)
        {
            Caption = 'Gross Weight';
            DecimalPlaces = 0 : 5;
        }
        field(50; "Gross Weight Unit of Measure"; Code[10])
        {
            Caption = 'Gross Weight Unit of Measure';
            TableRelation = "Unit of Measure" WHERE(Type = CONST(Weight));
        }
        field(51; "Area"; Decimal)
        {
            Caption = 'Area';
            DecimalPlaces = 0 : 5;
        }
        field(52; "Area Unit of Measure"; Code[10])
        {
            Caption = 'Area Unit of Measure';
            TableRelation = "Unit of Measure" WHERE(Type = CONST(" "));
        }
        field(61; "Manufacture Date"; Date)
        {
            Caption = 'Manufacture Date';
        }
        field(62; "Purchase Date"; Date)
        {
            Caption = 'Purchase Date';
        }
        field(63; "Installation Date"; Date)
        {
            Caption = 'Installation Date';
        }
        field(64; "Overhaul Date"; Date)
        {
            Caption = 'Overhaul Date';
        }
        field(65; "Warranty Date"; Date)
        {
            Caption = 'Warranty Date';
        }
        field(81; "Usage Unit of Measure"; Code[10])
        {
            Caption = 'Usage Unit of Measure';
            TableRelation = "Unit of Measure";

            trigger OnValidate()
            begin
                AssetUsage.SetRange("Asset No.", "No.");
                if AssetUsage.FindFirst then
                    Error(Text002, FieldCaption("Usage Unit of Measure"));
            end;
        }
        field(82; "Usage Reading Frequency"; DateFormula)
        {
            Caption = 'Usage Reading Frequency';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; "Resource No.")
        {
        }
        key(Key3; "Location Code")
        {
        }
        key(Key4; "Parent Asset No.")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", Description, Type, "Location Code", Status)
        {
        }
        fieldgroup(Brick; "No.", Description, Type, "Location Code", Picture)
        {
        }
    }

    trigger OnDelete()
    var
        Asset: Record Asset;
        MyAsset: Record "My Asset";
    begin
        WorkOrder.Reset;
        WorkOrder.SetRange("Asset No.", "No.");
        if WorkOrder.FindFirst then
            Error(Text003, TableCaption, "No.", WorkOrder.TableCaption);

        PMOrder.Reset;
        PMOrder.SetRange("Asset No.", "No.");
        if PMOrder.FindFirst then
            Error(Text003, TableCaption, "No.", PMOrder.TableCaption);

        MaintLedger.Reset;
        MaintLedger.SetRange("Asset No.", "No.");
        if MaintLedger.FindFirst then
            Error(Text003, TableCaption, "No.", MaintLedger.TableCaption);

        // P8000725
        Asset.SetCurrentKey("Parent Asset No.");
        Asset.SetRange("Parent Asset No.", "No.");
        if not Asset.IsEmpty then
            Error(Text004, TableCaption, "No.", Asset.TableCaption);
        // P8000725

        CommentLine.SetRange("Table Name", CommentLine."Table Name"::FOODAsset);
        CommentLine.SetRange("No.", "No.");
        CommentLine.DeleteAll;

        // P8001090
        if ProcessFns.ProcessDataCollectionInstalled then
            DataCollectionMgmt.DeleteDataCollectionLines(DATABASE::Asset, "No.", '');
        // P8001090

        // P8007748
        MyAsset.SetRange("Asset No.", "No.");
        MyAsset.DeleteAll;
        // P8007748

        DimMgt.DeleteDefaultDim(DATABASE::Asset, "No.");
    end;

    trigger OnInsert()
    begin
        if "No." = '' then begin
            MaintSetup.Get;
            MaintSetup.TestField("Asset Nos.");
            NoSeriesMgt.InitSeries(MaintSetup."Asset Nos.", xRec."No. Series", 0D, "No.", "No. Series");
        end;

        DimMgt.UpdateDefaultDim(
          DATABASE::Asset, "No.",
          "Global Dimension 1 Code", "Global Dimension 2 Code");

        SetHierarchy; // P8000725
    end;

    trigger OnModify()
    var
        MyAsset: Record "My Asset";
    begin
        "Last Date Modified" := Today;

        SetHierarchy; // P8000725

        // P80053245
        if not IsTemporary then begin
            MyAsset.SetRange("Asset No.", "No.");

            MyAsset.SetFilter(Description, '<>%1', Description);
            MyAsset.ModifyAll(Description, Description);
            MyAsset.SetRange(Description);

            MyAsset.SetFilter(Type, '<>%1', Type);
            MyAsset.ModifyAll(Type, Type);
            MyAsset.SetRange(Type);

            MyAsset.SetFilter(Status, '<>%1', Status);
            MyAsset.ModifyAll(Status, Status);
        end;
        // P80053245
    end;

    trigger OnRename()
    begin
        DimMgt.RenameDefaultDim(DATABASE::Asset, xRec."No.", "No."); // P80073095
        CommentLine.RenameCommentLine(CommentLine."Table Name"::FOODAsset, xRec."No.", "No."); // P80096165

        "Last Date Modified" := Today;

        SetHierarchy; // P8000725
    end;

    var
        MaintSetup: Record "Maintenance Setup";
        CommentLine: Record "Comment Line";
        Resource: Record Resource;
        AssetUsage: Record "Asset Usage";
        WorkOrder: Record "Work Order";
        PMOrder: Record "Preventive Maintenance Order";
        MaintLedger: Record "Maintenance Ledger";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DimMgt: Codeunit DimensionManagement;
        Text001: Label 'Asset &Spares,&Inventory';
        Text002: Label 'You cannot change %1 because there are usage entries for this asset.';
        Text003: Label 'You cannot delete %1 %2 because there exists at least one %3 associated with it.';
        Text004: Label 'You cannot delete %1 %2 because it is a parent for another %3.';
        Text005: Label '%1 cannot exceed %2 levels.';
        Text006: Label '%1 cannot contain loops.';
        Text007: Label '%1 cannot contain the ''%2'' character.';
        ProcessFns: Codeunit "Process 800 Functions";
        DataCollectionMgmt: Codeunit "Data Collection Management";

    procedure AssistEdit(OldAsset: Record Asset): Boolean
    var
        Asset: Record Asset;
    begin
        with Asset do begin
            Asset := Rec;
            MaintSetup.Get;
            MaintSetup.TestField("Asset Nos.");
            if NoSeriesMgt.SelectSeries(MaintSetup."Asset Nos.", OldAsset."No. Series", "No. Series") then begin
                NoSeriesMgt.SetSeries("No.");
                Rec := Asset;
                exit(true);
            end;
        end;
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        DimMgt.SaveDefaultDim(DATABASE::Asset, "No.", FieldNumber, ShortcutDimCode);
        Modify;
    end;

    procedure ShowSpares()
    var
        AssetSpare: Record "Asset Spare Part";
        AssetSpares: Page "Asset Spare Parts";
    begin
        TestField("Manufacturer Code");
        TestField("Model No.");
        AssetSpare.SetRange("Manufacturer Code", "Manufacturer Code");
        AssetSpare.SetRange("Model No.", "Model No.");
        AssetSpares.SetTableView(AssetSpare);
        AssetSpares.RunModal;
    end;

    procedure LookupItem(Type: Option ,Stock,NonStock; var Text: Text[1024]): Boolean
    var
        AssetSpare: Record "Asset Spare Part";
        MaintMgt: Codeunit "Maintenance Management";
        NoSpares: Boolean;
        TableId: Integer;
        Text00001: Label '%1';
    begin
        NoSpares := true; // P8000517A
        if ("Manufacturer Code" <> '') and ("Model No." <> '') then begin
            AssetSpare.SetRange("Manufacturer Code", "Manufacturer Code");
            AssetSpare.SetRange("Model No.", "Model No.");
            AssetSpare.SetRange(Type, Type);
            NoSpares := AssetSpare.IsEmpty; // P8000470A
        end;
        case Type of
            Type::Stock:
                if NoSpares then
                    TableId := 2
                else
                    TableId := StrMenu(Text001);
            Type::NonStock:
                if not NoSpares then
                    TableId := 1;
        end;
        case TableId of
            1:
                exit(MaintMgt.LookupSpare("Manufacturer Code", "Model No.", Type, Text));
            2:
                exit(MaintMgt.LookupItem(Text));
        end;
    end;

    procedure GetSpare(Type: Option ,Stock,NonStock; ItemNo: Code[20]; var AssetSpare: Record "Asset Spare Part"): Boolean
    var
        Text00001: Label '%1';
    begin
        // P8000517A
        if ("Manufacturer Code" = '') or ("Model No." = '') then
            exit(false);

        exit(AssetSpare.Get("Manufacturer Code", "Model No.", Type, ItemNo));
    end;

    procedure ShowAssetUsage()
    var
        AssetUsage: Page "Asset Usage";
    begin
        TestField("Usage Unit of Measure");

        AssetUsage.SetAsset(Rec);
        AssetUsage.LookupMode(true); // P8001149
        AssetUsage.RunModal;
    end;

    procedure GetLastUsage(var UsageDate: Date; var UsageReading: Decimal; var AvgDailyUsage: Decimal)
    begin
        AssetUsage.SetRange("Asset No.", "No.");
        if AssetUsage.FindLast then begin
            UsageDate := AssetUsage.Date;
            UsageReading := AssetUsage.Reading;
            AvgDailyUsage := AssetUsage."Average Daily Usage";
        end else begin
            UsageDate := 0D;
            UsageReading := 0;
            AvgDailyUsage := 0;
        end;
    end;

    procedure SetHierarchy()
    var
        Asset: Record Asset;
        TempAsset: array[2] of Record Asset temporary;
        WorkOrder: Record "Work Order";
        WorkOrder2: Record "Work Order";
        Position: Integer;
        xHierarchy: Code[85];
        xNo: Code[20];
        xParent: Code[20];
        MaxLevel: Integer;
    begin
        // P8000725
        if 0 <> StrPos("No.", Delimiter) then
            Error(Text007, FieldCaption("No."), Delimiter);

        xHierarchy := "Asset Hierarchy";
        if 0 < StrLen("Asset Hierarchy") then begin
            "Asset Hierarchy" := CopyStr("Asset Hierarchy", 2);
            Position := StrPos("Asset Hierarchy", Delimiter);
            xNo := CopyStr("Asset Hierarchy", 1, Position - 1);
            "Asset Hierarchy" := CopyStr("Asset Hierarchy", Position + 1);
            Position := StrPos("Asset Hierarchy", Delimiter);
            if Position <> 0 then
                xParent := CopyStr("Asset Hierarchy", Position - 1)
            else
                "Asset Hierarchy" := Delimiter;
        end else
            "Asset Hierarchy" := Delimiter;

        if xParent <> "Parent Asset No." then begin
            if "Parent Asset No." = '' then
                "Asset Hierarchy" := Delimiter
            else begin
                Asset.Get("Parent Asset No.");
                "Asset Hierarchy" := Asset."Asset Hierarchy";
            end;
        end;

        "Asset Hierarchy" := Delimiter + "No." + "Asset Hierarchy";

        if xHierarchy <> "Asset Hierarchy" then begin
            MaxLevel := (MaxStrLen("Asset Hierarchy") - 1) / (MaxStrLen("No.") + 1);
            CheckHierarchy("Asset Hierarchy", MaxLevel);

            if xNo <> '' then begin
                // Update Hierarchy on descendents and open work orders
                Asset.SetCurrentKey("Parent Asset No.");
                WorkOrder.SetCurrentKey("Asset No.");
                WorkOrder.SetRange(Completed, false);
                TempAsset[2] := Rec;
                TempAsset[2]."No." := xNo;
                TempAsset[2].Insert;
                while TempAsset[1].FindFirst do begin
                    Asset.SetRange("Parent Asset No.", TempAsset[1]."No.");
                    if Asset.FindSet(true, false) then
                        repeat
                            Position := StrPos(Asset."Asset Hierarchy", Delimiter + Asset."Parent Asset No." + Delimiter);
                            Asset."Asset Hierarchy" := CopyStr(Asset."Asset Hierarchy", 1, Position - 1) + TempAsset[1]."Asset Hierarchy";
                            CheckHierarchy(Asset."Asset Hierarchy", MaxLevel);
                            Asset.Modify;
                            TempAsset[2] := Asset;
                            TempAsset[2].Insert;
                        until Asset.Next = 0;

                    WorkOrder.SetRange("Asset No.", TempAsset[1]."No.");
                    if WorkOrder.FindSet(true, false) then
                        repeat
                            WorkOrder."Asset Hierarchy" := TempAsset[1]."Asset Hierarchy";
                            WorkOrder.Modify;
                        until WorkOrder.Next = 0;

                    TempAsset[1].Delete;
                end;
            end;

            if (xNo <> '') and (xNo <> "No.") then begin
                // If Asset is renamed then just modify that portion of the hierarchy on completed work orders
                WorkOrder.Reset;
                WorkOrder.SetFilter("Asset Hierarchy", '*' + Delimiter + xNo + Delimiter + '*');
                WorkOrder.SetRange(Completed, true);
                if WorkOrder.FindSet then
                    repeat
                        WorkOrder2 := WorkOrder;
                        Position := StrPos(WorkOrder2."Asset Hierarchy", Delimiter + xNo + Delimiter);
                        WorkOrder2."Asset Hierarchy" := DelStr(WorkOrder2."Asset Hierarchy", Position + 1, StrLen(xNo));
                        WorkOrder2."Asset Hierarchy" := InsStr(WorkOrder2."Asset Hierarchy", "No.", Position + 1);
                        WorkOrder2.Modify;
                    until WorkOrder.Next = 0;
            end;
        end;
    end;

    procedure CheckHierarchy(Hierarchy: Code[85]; MaxLevel: Integer)
    var
        Asset: Record Asset;
        Level: Integer;
        Position: Integer;
    begin
        // P8000725
        Hierarchy := CopyStr(Hierarchy, 2);
        while (StrLen(Hierarchy) > 0) and (Level <= MaxLevel) do begin
            Position := StrPos(Hierarchy, Delimiter);
            if Asset.Get(CopyStr(Hierarchy, 1, Position - 1)) then
                if Asset.Mark then
                    Error(Text006, FieldCaption("Asset Hierarchy"))
                else
                    Asset.Mark(true);
            Level += 1;
            Hierarchy := CopyStr(Hierarchy, Position + 1);
        end;
        if Level > MaxLevel then
            Error(Text005, FieldCaption("Asset Hierarchy"), MaxLevel);
    end;

    procedure Delimiter(): Text[1]
    begin
        // P8000725
        exit('~');
    end;
}

