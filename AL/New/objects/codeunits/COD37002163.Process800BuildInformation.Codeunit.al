codeunit 37002163 "Process 800 Build Information"
{
    // PRW17.00.01
    // P8001177, Columbus IT, Jack Reynolds, 03 JUL 13
    //   Build codeunit for product registration
    // 
    // PRW18.00.01
    // P8001386, Columbus IT, Jack Reynolds, 28 MAY 15
    //   Updated for automated builds
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds. 18 NOV 15
    //   Append Food build information to NAV Application Version

    procedure ApplicationBuild(): Text[80]
    var
        PublishedApplication: Record "Published Application";
        FoodAppID: Guid;
        Country: Text;
    begin
        Evaluate(FoodAppID, 'a8e204e7-7dea-40b9-9443-6185c50c08b9');
        PublishedApplication.SetRange(ID, FoodAppID);
        if PublishedApplication.FindFirst() then begin
            Country := PublishedApplication.Brief;
            Country := Country.Substring(Country.LastIndexOf('(') + 1, 2);
            exit(StrSubstNo('FOOD%1.%2.%3.%4.%5', Country,
              PublishedApplication."Version Major", PublishedApplication."Version Minor", PublishedApplication."Version Build", PublishedApplication."Version Revision"));
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application System Constants", 'OnAfterGetApplicationVersion', '', false, false)]
    local procedure ApplicationSystemConstants_OnAfterGetApplicationVersion(var ApplicationVersion: Text[248])
    begin
        // P8004516
        ApplicationVersion := ApplicationVersion + ' / ' + ApplicationBuild;
    end;
}

