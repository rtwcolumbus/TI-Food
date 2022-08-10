page 37002855 "Maintenance Work FactBox"
{
    // PRW16.00.04
    // P8000880, VerticalSoft, Jack Reynolds, 16 NOV 10
    //   FactBox for upcoming maintenance work by Resource

    Caption = 'Maintenance';
    PageType = ListPart;
    SourceTable = "Work Order by Resource";
    SourceTableTemporary = true;
    SourceTableView = SORTING("Resource No.", Date, "Asset No.");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Asset No."; "Asset No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    var
                        Asset: Record Asset;
                    begin
                        if Asset.Get("Asset No.") then
                            PAGE.Run(PAGE::"Asset Card", Asset);
                    end;
                }
                field(Date; Date)
                {
                    ApplicationArea = FOODBasic;
                }
            }
            field("Work Requested"; "Work Requested")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Work';
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Order")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Order';
                Image = "Order";

                trigger OnAction()
                var
                    WorkOrder: Record "Work Order";
                    PM: Record "Preventive Maintenance Order";
                begin
                    if "Work Order No." <> '' then begin
                        WorkOrder.Get("Work Order No.");
                        PAGE.Run(PAGE::"Work Order", WorkOrder);
                    end else begin
                        PM.Get("PM Entry No.");
                        PAGE.Run(PAGE::"Preventive Maintenance Order", PM);
                    end;
                end;
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    var
        ResourceNo: Code[20];
    begin
        FilterGroup(4);
        ResourceNo := GetFilter("Resource No.");
        FilterGroup(0);
        LoadResource(ResourceNo);

        exit(Find(Which));
    end;

    var
        Resource: Record Resource;
        Asset: Record Asset;
        AssetToProcess: array[2] of Record "Work Order by Resource" temporary;
        WorkByAsset: Record "Work Order by Resource" temporary;
        BeginDate: Date;
        EndDate: Date;
        EntryNo: Integer;

    procedure Initialize(Date1: Date; Date2: Date)
    begin
        BeginDate := Date1;
        EndDate := Date2;
        if EndDate = 0D then
            EndDate := DMY2Date(31, 12, 9999); // P8007748

        Reset;
        DeleteAll;
        Asset.Reset;
        Resource.Reset;
        WorkByAsset.Reset;
        WorkByAsset.DeleteAll;
    end;

    procedure LoadResource(ResourceNo: Code[20])
    begin
        if not Resource.Get(ResourceNo) then
            exit;
        if Resource.Mark then
            exit;

        Resource.Mark(true);

        Asset.SetCurrentKey("Resource No.");
        Asset.SetRange("Resource No.", ResourceNo);
        if Asset.FindSet then begin
            AssetToProcess[1].Reset;
            AssetToProcess[1].DeleteAll;
            AssetToProcess[2]."Entry No." := 0;
            repeat
                AssetToProcess[2]."Entry No." += 1;
                AssetToProcess[2]."Asset No." := Asset."No.";
                AssetToProcess[2].Insert;
            until Asset.Next = 0;
            Asset.SetRange("Resource No.");

            AssetToProcess[1].Find('-');
            repeat
                LoadAsset(AssetToProcess[1]."Asset No.", ResourceNo);
            until AssetToProcess[1].Next = 0;
        end;
    end;

    procedure LoadAsset(AssetNo: Code[20]; ResourceNo: Code[20])
    var
        WorkOrder: Record "Work Order";
        PM: Record "Preventive Maintenance Order";
        NextPMDate: Date;
    begin
        Asset.Get(AssetNo);

        if not Asset.Mark then begin
            // Find WO's for asset
            WorkOrder.SetCurrentKey("Asset No.");
            WorkOrder.SetRange("Asset No.", AssetNo);
            WorkOrder.SetRange(Completed, false);
            if WorkOrder.FindSet then
                repeat
                    if WorkOrder."Scheduled Date" = 0D then
                        WorkOrder."Scheduled Date" := WorkOrder."Due Date";
                    if (BeginDate <= WorkOrder."Scheduled Date") and (WorkOrder."Scheduled Date" <= EndDate) then begin
                        WorkByAsset."Entry No." += 1;
                        WorkByAsset."Asset No." := AssetNo;
                        WorkByAsset.Date := WorkOrder."Scheduled Date";
                        WorkByAsset."Work Order No." := WorkOrder."No.";
                        WorkByAsset."PM Entry No." := '';
                        WorkByAsset."Work Requested" := WorkOrder."Work Requested (First Line)";
                        WorkByAsset.Insert;
                    end;
                until WorkOrder.Next = 0;

            // Find PM's for Asset
            PM.SetCurrentKey("Asset No.");
            PM.SetRange("Asset No.", AssetNo);
            PM.SetRange("Current Work Order", '');
            if PM.FindSet then
                repeat
                    if PM."Override Date" <> 0D then
                        NextPMDate := PM."Override Date"
                    else
                        NextPMDate := PM.NextPMDate;
                    if (BeginDate <= NextPMDate) and (NextPMDate <= EndDate) then begin
                        WorkByAsset."Entry No." += 1;
                        WorkByAsset."Asset No." := AssetNo;
                        WorkByAsset.Date := NextPMDate;
                        WorkByAsset."Work Order No." := '';
                        WorkByAsset."PM Entry No." := PM."Entry No.";
                        WorkByAsset."Work Requested" := PM."Work Requested (First Line)";
                        WorkByAsset.Insert;
                    end;
                until PM.Next = 0;

            Asset.Mark(true);
        end;

        CopyAssetToResource(AssetNo, ResourceNo);

        // Handle children assets
        Asset.SetCurrentKey("Parent Asset No.");
        Asset.SetRange("Parent Asset No.", AssetNo);
        if Asset.FindSet then
            repeat
                AssetToProcess[2]."Entry No." += 1;
                AssetToProcess[2]."Asset No." := Asset."No.";
                AssetToProcess[2].Insert;
            until Asset.Next = 0;
        Asset.SetRange("Parent Asset No.");
    end;

    procedure CopyAssetToResource(AssetNo: Code[20]; ResourceNo: Code[20])
    begin
        WorkByAsset.Reset;
        WorkByAsset.SetCurrentKey("Asset No.");
        WorkByAsset.SetRange("Asset No.", AssetNo);
        if WorkByAsset.FindSet then
            repeat
                EntryNo += 1;
                Rec := WorkByAsset;
                "Entry No." := EntryNo;
                "Resource No." := ResourceNo;
                Insert;
            until WorkByAsset.Next = 0;
    end;
}

