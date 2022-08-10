codeunit 37002013 "Lot Spec. Caption Mgmt."
{
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Functions to create captions for lot specification and lot preference fields and controls
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
        InvSetup: Record "Inventory Setup";
        InvSetupRead: Boolean;
        Text001: Label 'Lot Specification %1';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Caption Class", 'OnResolveCaptionClass', '', true, true)]
    local procedure CaptionClass_OnResolveCaptionClass(CaptionArea: Text; CaptionExpr: Text; Language: Integer; var Caption: Text; var Resolved: Boolean)
    begin
        // P80073095
        case CaptionArea of
            '37002020':
                begin
                    Caption := LotSpecCaptionClassTranslate(Language, CaptionExpr);
                    Resolved := true;
                end;
            '37002021':
                begin
                    Caption := PrefFldCaptionClassTranslate(Language, CaptionExpr);
                    Resolved := true;
                end;
        end;
    end;

    local procedure LotSpecCaptionClassTranslate(Language: Integer; CaptionExpr: Text[80]) Caption: Text[80]
    var
        LotSpecCat: Record "Data Collection Data Element";
        LotSpecCode: Code[10];
    begin
        GetInvSetup;

        case CaptionExpr of
            '1':
                LotSpecCode := InvSetup."Shortcut Lot Spec. 1 Code";
            '2':
                LotSpecCode := InvSetup."Shortcut Lot Spec. 2 Code";
            '3':
                LotSpecCode := InvSetup."Shortcut Lot Spec. 3 Code";
            '4':
                LotSpecCode := InvSetup."Shortcut Lot Spec. 4 Code";
            '5':
                LotSpecCode := InvSetup."Shortcut Lot Spec. 5 Code";
        end;
        if LotSpecCat.Get(LotSpecCode) then begin
            if LotSpecCat.Description <> '' then
                Caption := LotSpecCat.Description
            else
                Caption := LotSpecCode;
        end else
            Caption := StrSubstNo(Text001, CaptionExpr);
    end;

    local procedure PrefFldCaptionClassTranslate(Language: Integer; CaptionExpr: Text[80]) Caption: Text[80]
    var
        LotAgeFilter: Record "Lot Age Filter";
        Customer: Record Customer;
        Item: Record Item;
        CommaPosition: Integer;
        TableID: Integer;
        FldNo: Integer;
    begin
        CommaPosition := StrPos(CaptionExpr, ',');
        if CommaPosition = 0 then
            exit;
        Evaluate(TableID, CopyStr(CaptionExpr, 1, CommaPosition - 1));
        Evaluate(FldNo, CopyStr(CaptionExpr, CommaPosition + 1));

        case TableID of
            DATABASE::Customer:
                case FldNo of
                    LotAgeFilter.FieldNo(ID):
                        exit(StrSubstNo('%1 %2', Customer.TableCaption, Customer.FieldCaption("No.")));
                    LotAgeFilter.FieldNo("ID 2"):
                        exit(StrSubstNo('%1 %2', Item.TableCaption, Item.FieldCaption("No.")));
                end;
            else
                case FldNo of
                    LotAgeFilter.FieldNo(ID):
                        exit(LotAgeFilter.FieldCaption(ID));
                    LotAgeFilter.FieldNo("ID 2"):
                        exit(LotAgeFilter.FieldCaption("ID 2"));
                end;
        end;
    end;

    local procedure GetInvSetup()
    begin
        if InvSetupRead then
            exit;
        if InvSetup.Get then;
        InvSetupRead := true;
    end;
}

