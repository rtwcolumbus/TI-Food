codeunit 37002018 "Item Attribute Caption Mgmt."
{
    // PRW16.00.04
    // P8000876, VerticalSoft, Jack Reynolds, 26 OCT 10
    //   Caption management for Item Attributes
    // 
    // CaptionExpr is segmented string (comma delimited)
    //   First substring indicates the parameter (1, 2, 3)
    //   Second substring indicates the worksheet name
    // 
    // PRW110.0
    // P8007750, To-Increase, Jack Reynolds, 07 NOV 16
    //   Convert Food Item Attributes to NAV Item Attributes
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        Text001: Label 'Parameter %1';
        Text002: Label '%1 %2';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Caption Class", 'OnResolveCaptionClass', '', true, true)]
    local procedure CaptionClass_OnResolveCaptionClass(CaptionArea: Text; CaptionExpr: Text; Language: Integer; var Caption: Text; var Resolved: Boolean)
    begin
        // P80073095
        if CaptionArea = '37002011' then begin
            Caption := ItemAttributeCaptionClassTranslate(Language, CaptionExpr);
            Resolved := true;
        end;
    end;

    local procedure ItemAttributeCaptionClassTranslate(Language: Integer; CaptionExpr: Text[80]): Text[80]
    var
        WorksheetName: Record "Batch Planning Worksheet Name";
        ItemAttribute: Record "Item Attribute";
        CommaPosition: Integer;
        CaptionType: Text[80];
        CaptionRef: Text[80];
    begin
        CommaPosition := StrPos(CaptionExpr, ',');
        if CommaPosition = 0 then
            exit;
        CaptionType := CopyStr(CaptionExpr, 1, CommaPosition - 1);
        CaptionRef := CopyStr(CaptionExpr, CommaPosition + 1);
        if WorksheetName.Get(CaptionRef) then;
        case CaptionType of
            '2':
                begin
                    WorksheetName."Parameter 1 Type" := WorksheetName."Parameter 2 Type";
                    WorksheetName."Parameter 1 Field" := WorksheetName."Parameter 2 Field";
                    WorksheetName."Parameter 1 Attribute" := WorksheetName."Parameter 2 Attribute";
                end;
            '3':
                begin
                    WorksheetName."Parameter 1 Type" := WorksheetName."Parameter 3 Type";
                    WorksheetName."Parameter 1 Field" := WorksheetName."Parameter 3 Field";
                    WorksheetName."Parameter 1 Attribute" := WorksheetName."Parameter 3 Attribute";
                end;
        end;

        if (WorksheetName."Parameter 1 Type" = 0) or
           (WorksheetName."Parameter 1 Field" = 0) or
           ((WorksheetName."Parameter 1 Field" = WorksheetName."Parameter 1 Field"::Attribute) and
            (WorksheetName."Parameter 1 Attribute" = 0)) // P8007750
        then
            exit(StrSubstNo(Text001, CaptionType));

        if WorksheetName."Parameter 1 Field" < WorksheetName."Parameter 1 Field"::Attribute then
            exit(StrSubstNo(Text002, WorksheetName."Parameter 1 Type", WorksheetName."Parameter 1 Field"));

        ItemAttribute.Get(WorksheetName."Parameter 1 Attribute");
        exit(StrSubstNo(Text002, WorksheetName."Parameter 1 Type", TranslateItemAttributeName(ItemAttribute, Language))); // P8007750
    end;

    local procedure TranslateItemAttributeName(ItemAttribute: Record "Item Attribute"; LanguageID: Integer): Text[250]
    var
        ItemAttributeTranslation: Record "Item Attribute Translation";
        Language: Record Language;
    begin
        // P8007750
        Language.SetRange("Windows Language ID", LanguageID);
        if Language.FindFirst then begin
            ItemAttributeTranslation.SetRange("Attribute ID", ItemAttribute.ID);
            ItemAttributeTranslation.SetRange("Language Code", Language.Code);
            if ItemAttributeTranslation.FindFirst then
                if ItemAttributeTranslation.Name <> '' then
                    ItemAttribute.Name := ItemAttributeTranslation.Name;
        end;
        exit(ItemAttribute.Name);
    end;
}

