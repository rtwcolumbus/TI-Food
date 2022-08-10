codeunit 14014998 "Food Upgrade"
{
    Subtype = Upgrade;

    var
        P800functions: Codeunit "Process 800 Functions";
        UpgradeTag: Codeunit "Upgrade Tag";

    trigger OnUpgradePerCompany()
    begin 
        UpdateItemTrackingCreateLotInfo();
        InitializeFOODTransactionNumber(); // P800122976
        MoveWarehouseEnums(); // P800144605
    end;

    local procedure UpdateItemTrackingCreateLotInfo()
    var
        ItemTrackingCode: Record "Item Tracking Code";
        Tag: Code[250];
    begin
        Tag := P800functions.CreateUpgradeTag('18.0',DMY2Date(1,6,2021),'CREATE LOT INFO');
        if UpgradeTag.HasUpgradeTag(Tag) then
            exit;

        ItemTrackingCode.SetRange("Lot Specific Tracking",true);
        if not ItemTrackingCode.IsEmpty then
            ItemTrackingCode.ModifyAll("Create Lot No. Info on posting",true);

        UpgradeTag.SetUpgradeTag(Tag);
    end;

    // P800122976
    local procedure InitializeFOODTransactionNumber()
    var
        P800Utility: Codeunit "Process 800 Utility Functions";
        Tag: Code[250];
    begin
        Tag := P800functions.CreateUpgradeTag('18.0', DMY2Date(1, 9, 2021), 'TRANS NO');
        if UpgradeTag.HasUpgradeTag(Tag) then
            exit;

        P800Utility.InitializeFOODTransactionNumber();

        UpgradeTag.SetUpgradeTag(Tag);
    end;

    // P800144605
    local procedure MoveWarehouseEnums()
    var
        RegisteredWhseAcvityLine: Record "Registered Whse. Activity Line";
        WarehouseActivityLine: Record "Warehouse Activity Line";
        WarehouseEntry: Record "Warehouse Entry";
        WarehouseJournalLine: Record "Warehouse Journal Line";
        WhseWorksheetLine: Record "Whse. Worksheet Line";
        P800Utility: Codeunit "Process 800 Utility Functions";
        Tag: Code[250];
    begin
        Tag := P800functions.CreateUpgradeTag('20.0', DMY2Date(12, 5, 2022), 'WAREHOUSE ENUMS');
        if UpgradeTag.HasUpgradeTag(Tag) then
            exit;

        RegisteredWhseAcvityLine.SetRange("Whse. Document Type", 9); // Old Enum value for FOODStagedPick
        RegisteredWhseAcvityLine.ModifyAll("Whse. Document Type", "Warehouse Activity Document Type"::FOODStagedPick);
        RegisteredWhseAcvityLine.SetRange("Whse. Document Type", 10); // Old Enum value for FOODDeliveryTripPick
        RegisteredWhseAcvityLine.ModifyAll("Whse. Document Type", "Warehouse Activity Document Type"::FOODDeliveryTripPick);

        WarehouseActivityLine.SetRange("Whse. Document Type", 9); // Old Enum value for FOODStagedPick
        WarehouseActivityLine.ModifyAll("Whse. Document Type", "Warehouse Activity Document Type"::FOODStagedPick);
        WarehouseActivityLine.SetRange("Whse. Document Type", 10); // Old Enum value for FOODDeliveryTripPick
        WarehouseActivityLine.ModifyAll("Whse. Document Type", "Warehouse Activity Document Type"::FOODDeliveryTripPick);

        WarehouseEntry.SetRange("Whse. Document Type", 9); // Old Enum value for FOODStagedPick
        WarehouseEntry.ModifyAll("Whse. Document Type", "Warehouse Journal Document Type"::FOODStagedPick);
        WarehouseEntry.SetRange("Whse. Document Type", 10); // Old Enum value for FOODDeliveryTripPick
        WarehouseEntry.ModifyAll("Whse. Document Type", "Warehouse Journal Document Type"::FOODDeliveryTripPick);
        WarehouseEntry.SetRange("Whse. Document Type", 11); // Old Enum value for FOODDeliveryTrip
        WarehouseEntry.ModifyAll("Whse. Document Type", "Warehouse Journal Document Type"::FOODDeliveryTrip);

        WarehouseJournalLine.SetRange("Whse. Document Type", 9); // Old Enum value for FOODStagedPick
        WarehouseJournalLine.ModifyAll("Whse. Document Type", "Warehouse Journal Document Type"::FOODStagedPick);
        WarehouseJournalLine.SetRange("Whse. Document Type", 10); // Old Enum value for FOODDeliveryTripPick
        WarehouseJournalLine.ModifyAll("Whse. Document Type", "Warehouse Journal Document Type"::FOODDeliveryTripPick);
        WarehouseJournalLine.SetRange("Whse. Document Type", 11); // Old Enum value for FOODDeliveryTrip
        WarehouseJournalLine.ModifyAll("Whse. Document Type", "Warehouse Journal Document Type"::FOODDeliveryTrip);

        WhseWorksheetLine.SetRange("Whse. Document Type", 9); // Old Enum value for FOODStagedPick
        WhseWorksheetLine.ModifyAll("Whse. Document Type", "Warehouse Worksheet Document Type"::FOODStagedPick);
        WhseWorksheetLine.SetRange("Whse. Document Type", 10); // Old Enum value for FOODDeliveryTripPick
        WhseWorksheetLine.ModifyAll("Whse. Document Type", "Warehouse Worksheet Document Type"::FOODDeliveryTripPick);

        UpgradeTag.SetUpgradeTag(Tag);
    end;
}