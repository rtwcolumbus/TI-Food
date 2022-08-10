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
}