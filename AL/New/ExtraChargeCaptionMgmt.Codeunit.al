codeunit 37002011 "Extra Charge Caption Mgmt."
{
    // PR4.00.01
    // P8000278A, VerticalSoft, Jack Reynolds, 06 JAN 06
    //   Check for FreshPro permission
    // 
    // Caption management for extra charges
    // 
    // CaptionExpr is segmented string (comma delimited)
    //   First substring indicates the caption type
    //     1 - Charge
    //     2 - Vendor
    //   Second substring indicates the shortcut extra charge index
    //     1-5
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        PurchSetup: Record "Purchases & Payables Setup";
        ProcessFns: Codeunit "Process 800 Functions";
        PurchSetupRead: Boolean;
        Text001: Label 'Extra Charge %1';
        Text002: Label 'Extra Charge Vendor %1';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Caption Class", 'OnResolveCaptionClass', '', true, true)]
    local procedure CaptionClass_OnResolveCaptionClass(CaptionArea: Text; CaptionExpr: Text; Language: Integer; var Caption: Text; var Resolved: Boolean)
    begin
        // P80073095
        if CaptionArea = '37002660' then begin
            Caption := ExtraChargeCaptionClassTranslate(Language, CaptionExpr);
            Resolved := true;
        end;
    end;

    local procedure ExtraChargeCaptionClassTranslate(Language: Integer; CaptionExpr: Text[80]) Caption: Text[80]
    var
        ExtraCharge: Record "Extra Charge";
        CommaPosition: Integer;
        CaptionType: Text[80];
        CaptionRef: Text[80];
        ExtraChargeCode: Code[10];
    begin
        GetPurchSetup;

        CommaPosition := StrPos(CaptionExpr, ',');
        if CommaPosition = 0 then
            exit;
        CaptionType := CopyStr(CaptionExpr, 1, CommaPosition - 1);
        CaptionRef := CopyStr(CaptionExpr, CommaPosition + 1);

        case CaptionRef of
            '1':
                ExtraChargeCode := PurchSetup."Shortcut Extra Charge 1 Code";
            '2':
                ExtraChargeCode := PurchSetup."Shortcut Extra Charge 2 Code";
            '3':
                ExtraChargeCode := PurchSetup."Shortcut Extra Charge 3 Code";
            '4':
                ExtraChargeCode := PurchSetup."Shortcut Extra Charge 4 Code";
            '5':
                ExtraChargeCode := PurchSetup."Shortcut Extra Charge 5 Code";
        end;

        if not ProcessFns.FreshProInstalled then // P8000278A
            exit(ExtraChargeCode);                 // P8000278A

        if ExtraCharge.Get(ExtraChargeCode) then;
        case CaptionType of
            '1':
                if ExtraCharge."Charge Caption" <> '' then
                    Caption := ExtraCharge."Charge Caption"
                else
                    Caption := StrSubstNo(Text001, CaptionRef);
            '2':
                if ExtraCharge."Vendor Caption" <> '' then
                    Caption := ExtraCharge."Vendor Caption"
                else
                    Caption := StrSubstNo(Text002, CaptionRef);
        end;
    end;

    local procedure GetPurchSetup()
    begin
        if PurchSetupRead then
            exit;
        if PurchSetup.Get then;
        PurchSetupRead := true;
    end;
}

