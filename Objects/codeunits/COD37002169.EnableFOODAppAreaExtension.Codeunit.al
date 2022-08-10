codeunit 37002169 "Enable FOODAppArea Extension"
{
    // Extend and modify Essential experience tier with "FOODBasic App Area"
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", 'OnGetEssentialExperienceAppAreas', '', false, false)]
    local procedure AppAreaMgmtOnGetEssentialExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup.FOODBasic := true;

        // Modify other application areas here
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", 'OnGetPremiumExperienceAppAreas', '', false, false)]
    local procedure AppAreaMgmtOnGetPremiumExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup.FOODBasic := true;

        // Modify other application areas here
    end;

    // Extend and modify Essential experience tier with "FOODBasic App Area"
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", 'OnGetBasicExperienceAppAreas', '', false, false)]
    local procedure AppAreaMgmtOnGetBasicExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup.FOODBasic := true;

        // Modify other application areas here
    end;

    // Validate that application areas needed for the extension are enabled
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", 'OnValidateApplicationAreas', '', false, false)]
    local procedure ApplicationAreaMgmtOnValidateApplicationAreas(ExperienceTierSetup: Record "Experience Tier Setup"; TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        if ExperienceTierSetup.Essential or ExperienceTierSetup.Premium or ExperienceTierSetup.Basic then
            if not TempApplicationAreaSetup."FOODBasic" then begin
                if ExperienceTierSetup.Essential then
                    Error(Text001, ExperienceTierSetup.Essential)
                else
                    if ExperienceTierSetup.Premium then
                        Error(Text001, ExperienceTierSetup.Premium)
                    else
                        if ExperienceTierSetup.Basic then
                            Error(Text001, ExperienceTierSetup.Basic);
            end;
    end;

    // Helpers ................................................................
    procedure IsFOODdBasicApplicationAreaEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if ApplicationAreaMgmtFacade.GetApplicationAreaSetupRecFromCompany(ApplicationAreaSetup, CompanyName()) then
            exit(ApplicationAreaSetup."FOODBasic");
    end;

    procedure EnableFOODBasicExtension()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;

    var
        Text001: Label 'FOODBasic Area should be part of %1 in order for the FOODBasic to work.';
}
