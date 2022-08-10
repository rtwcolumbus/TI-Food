codeunit 37002924 "Event Subscribers (Allergen)"
{
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // PRW113.00.03
    // P80084737, To Increase, Jack Reynolds, 10 OCT 19
    //   Modify subscriptions for RunTrigger


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeModifyEvent', '', true, false)]
    local procedure Item_OnBeforeModify(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    var
        Item: Record Item;
    begin
        // P80066030
        if Rec.IsTemporary then
            exit;

        Item.Get(Rec."No.");
        Rec."Old Direct Allergen Set ID" := Item."Direct Allergen Set ID";
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterModifyEvent', '', true, false)]
    local procedure Item_OnAfterModify(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    var
        AllergenManagement: Codeunit "Allergen Management";
    begin
        // P80066030
        if Rec.IsTemporary then
            exit;

        AllergenManagement.LogHistory(Rec); // P8006959
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeValidateEvent', 'Production BOM No.', true, false)]
    local procedure Item_OnBeforeValidate_ProductionBOMNo(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    var
        AllergenManagement: Codeunit "Allergen Management";
    begin
        // P80066030
        if (Rec."Production BOM No." <> xRec."Production BOM No.") and (Rec."Production BOM No." <> '') then
            AllergenManagement.CheckAllergenAssigned(Rec."No."); // P8006959
    end;

    [EventSubscriber(ObjectType::Table, Database::"BOM Component", 'OnBeforeInsertEvent', '', true, false)]
    local procedure BOMComponent_OnBeforeInsert(var Rec: Record "BOM Component"; RunTrigger: Boolean)
    var
        AllergenManagement: Codeunit "Allergen Management";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        AllergenManagement.CheckAllergenAssigned(Rec."Parent Item No."); // P8006959
    end;

    [EventSubscriber(ObjectType::Table, Database::"Unapproved Item", 'OnBeforeModifyEvent', '', true, false)]
    local procedure UnapprovedItem_OnBeforeModify(var Rec: Record "Unapproved Item"; var xRec: Record "Unapproved Item"; RunTrigger: Boolean)
    var
        UnapprovedItem: Record "Unapproved Item";
    begin
        // P80066030
        if Rec.IsTemporary then
            exit;

        UnapprovedItem.Get(Rec."No.");
        Rec."Old Allergen Set ID" := UnapprovedItem."Allergen Set ID";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Unapproved Item", 'OnAfterModifyEvent', '', true, false)]
    local procedure UnapprovedItem_OnAfterModify(var Rec: Record "Unapproved Item"; var xRec: Record "Unapproved Item"; RunTrigger: Boolean)
    var
        AllergenManagement: Codeunit "Allergen Management";
    begin
        // P80066030
        if Rec.IsTemporary then
            exit;

        AllergenManagement.LogHistory(Rec); // P8006959
    end;

    [EventSubscriber(ObjectType::Table, Database::"Production BOM Version", 'OnBeforeModifyEvent', '', true, false)]
    local procedure ProductionBOMVersion_OnBeforeModify(var Rec: Record "Production BOM Version"; var xRec: Record "Production BOM Version"; RunTrigger: Boolean)
    var
        ProductionBOMVersion: Record "Production BOM Version";
    begin
        // P80066030
        if Rec.IsTemporary then
            exit;

        ProductionBOMVersion.Get(Rec."Production BOM No.", Rec."Version Code");
        Rec."Old Direct Allergen Set ID" := ProductionBOMVersion."Direct Allergen Set ID";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Production BOM Version", 'OnAfterModifyEvent', '', true, false)]
    local procedure ProductionBOMVersion_OnBAfterModify(var Rec: Record "Production BOM Version"; var xRec: Record "Production BOM Version"; RunTrigger: Boolean)
    var
        AllergenManagement: Codeunit "Allergen Management";
    begin
        // P80066030
        if Rec.IsTemporary then
            exit;

        AllergenManagement.LogHistory(Rec); // P8006959
    end;
}

