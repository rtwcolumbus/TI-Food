codeunit 37002120 AccrualJnlManagement
{
    // PR3.61AC
    // 
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 09 AUG 07
    //   GetNames - change AccName to TEXT50
    // 
    // PRW16.00
    // P8000643, VerticalSoft, Jack Reynolds, 20 NOV 08
    //   New functions TemplateSelectionFromBatch and OpenJnlBatch defined to follow the patter in other
    //     journal management codeunits
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Permissions = TableData "Job Journal Template" = imd,
                  TableData "Job Journal Batch" = imd;

    trigger OnRun()
    begin
    end;

    var
        Text000: Label '%1 Journal';
        Text001: Label 'RECURRING';
        Text002: Label 'Recurring Accrual Journal';
        Text003: Label 'DEFAULT';
        Text004: Label 'Default Journal';
        LastAccrualJnlLine: Record "Accrual Journal Line";
        OpenFromBatch: Boolean;

    procedure TemplateSelection(FormTemplate: Option Accrual,"Scheduled Accrual"; FormID: Integer; RecurringJnl: Boolean; var AccrualJnlLine: Record "Accrual Journal Line"; var JnlSelected: Boolean)
    var
        AccrualJnlTemplate: Record "Accrual Journal Template";
    begin
        // PR4.00 - add parameters for FormId, AccrualJnlLine, JnlSelected
        JnlSelected := true;

        AccrualJnlTemplate.Reset;
        AccrualJnlTemplate.SetRange("Page ID", FormID); // PR4.00
        AccrualJnlTemplate.SetRange(Recurring, RecurringJnl);
        if not RecurringJnl then
            AccrualJnlTemplate.SetRange(Type, FormTemplate);

        case AccrualJnlTemplate.Count of
            0:
                begin
                    AccrualJnlTemplate.Init;
                    AccrualJnlTemplate.Type := FormTemplate;
                    AccrualJnlTemplate.Recurring := RecurringJnl;
                    if not RecurringJnl then begin
                        AccrualJnlTemplate.Name :=
                          Format(AccrualJnlTemplate.Type, MaxStrLen(AccrualJnlTemplate.Name));
                        AccrualJnlTemplate.Description := StrSubstNo(Text000, AccrualJnlTemplate.Type);
                    end else begin
                        AccrualJnlTemplate.Name := Text001;
                        AccrualJnlTemplate.Description := Text002;
                    end;
                    AccrualJnlTemplate.Validate("Page ID");
                    AccrualJnlTemplate.Insert;
                    Commit;
                end;
            1:
                AccrualJnlTemplate.Find('-');
            else
                JnlSelected := PAGE.RunModal(0, AccrualJnlTemplate) = ACTION::LookupOK;
        end;
        if JnlSelected then begin
            AccrualJnlLine.FilterGroup := 2;
            AccrualJnlLine.SetRange("Journal Template Name", AccrualJnlTemplate.Name);
            AccrualJnlLine.FilterGroup := 0;
        end;
    end;

    procedure TemplateSelectionFromBatch(var AccJnlBatch: Record "Accrual Journal Batch")
    var
        AccJnlLine: Record "Accrual Journal Line";
        JnlSelected: Boolean;
        AccJnlTemplate: Record "Accrual Journal Template";
    begin
        // P8000643
        OpenFromBatch := true;
        AccJnlTemplate.Get(AccJnlBatch."Journal Template Name");
        AccJnlTemplate.TestField("Page ID");
        AccJnlBatch.TestField(Name);

        AccJnlLine.FilterGroup := 2;
        AccJnlLine.SetRange("Journal Template Name", AccJnlTemplate.Name);
        AccJnlLine.FilterGroup := 0;

        AccJnlLine."Journal Template Name" := '';
        AccJnlLine."Journal Batch Name" := AccJnlBatch.Name;
        PAGE.Run(AccJnlTemplate."Page ID", AccJnlLine);
    end;

    procedure OpenJnl(var CurrentJnlBatchName: Code[10]; var AccrualJnlLine: Record "Accrual Journal Line")
    begin
        CheckTemplateName(AccrualJnlLine.GetRangeMax("Journal Template Name"), CurrentJnlBatchName);
        AccrualJnlLine.FilterGroup := 2;
        AccrualJnlLine.SetRange("Journal Batch Name", CurrentJnlBatchName);
        AccrualJnlLine.FilterGroup := 0;
    end;

    procedure OpenJnlBatch(var AccJnlBatch: Record "Accrual Journal Batch")
    var
        AccJnlTemplate: Record "Accrual Journal Template";
        AccJnlLine: Record "Accrual Journal Line";
        AccJnlBatch2: Record "Accrual Journal Batch";
        JnlSelected: Boolean;
    begin
        // P8000643
        if AccJnlBatch.GetFilter("Journal Template Name") <> '' then
            exit;
        AccJnlBatch.FilterGroup(2);
        if AccJnlBatch.GetFilter("Journal Template Name") <> '' then begin
            AccJnlBatch.FilterGroup(0);
            exit;
        end;
        AccJnlBatch.FilterGroup(0);

        if not AccJnlBatch.Find('-') then begin
            for AccJnlTemplate.Type := AccJnlTemplate.Type::Accrual to AccJnlTemplate.Type::"Scheduled Accrual" do begin
                AccJnlTemplate.SetRange(Type, AccJnlTemplate.Type);
                if not AccJnlTemplate.Find('-') then
                    TemplateSelection(0, AccJnlTemplate.Type, false, AccJnlLine, JnlSelected);
                if AccJnlTemplate.Find('-') then
                    CheckTemplateName(AccJnlTemplate.Name, AccJnlBatch.Name);
                if AccJnlTemplate.Type = AccJnlTemplate.Type::Accrual then begin
                    AccJnlTemplate.SetRange(Recurring, true);
                    if not AccJnlTemplate.Find('-') then
                        TemplateSelection(0, AccJnlTemplate.Type, true, AccJnlLine, JnlSelected);
                    if AccJnlTemplate.Find('-') then
                        CheckTemplateName(AccJnlTemplate.Name, AccJnlBatch.Name);
                    AccJnlTemplate.SetRange(Recurring);
                end;
            end;
        end;
        AccJnlBatch.Find('-');
        JnlSelected := true;
        AccJnlBatch.CalcFields("Template Type", Recurring);
        AccJnlTemplate.SetRange(Recurring, AccJnlBatch.Recurring);
        if not AccJnlBatch.Recurring then
            AccJnlTemplate.SetRange(Type, AccJnlBatch."Template Type");
        if AccJnlBatch.GetFilter("Journal Template Name") <> '' then
            AccJnlTemplate.SetRange(Name, AccJnlBatch.GetFilter("Journal Template Name"));
        case AccJnlTemplate.Count of
            1:
                AccJnlTemplate.Find('-');
            else
                JnlSelected := PAGE.RunModal(0, AccJnlTemplate) = ACTION::LookupOK;
        end;
        if not JnlSelected then
            Error('');

        AccJnlBatch.FilterGroup(0);
        AccJnlBatch.SetRange("Journal Template Name", AccJnlTemplate.Name);
        AccJnlBatch.FilterGroup(2);
    end;

    procedure CheckTemplateName(CurrentJnlTemplateName: Code[10]; var CurrentJnlBatchName: Code[10])
    var
        AccrualJnlBatch: Record "Accrual Journal Batch";
    begin
        AccrualJnlBatch.SetRange("Journal Template Name", CurrentJnlTemplateName);
        if not AccrualJnlBatch.Get(CurrentJnlTemplateName, CurrentJnlBatchName) then begin
            if not AccrualJnlBatch.Find('-') then begin
                AccrualJnlBatch.Init;
                AccrualJnlBatch."Journal Template Name" := CurrentJnlTemplateName;
                AccrualJnlBatch.SetupNewBatch;
                AccrualJnlBatch.Name := Text003;
                AccrualJnlBatch.Description := Text004;
                AccrualJnlBatch.Insert(true);
                Commit;
            end;
            CurrentJnlBatchName := AccrualJnlBatch.Name;
        end;
    end;

    procedure CheckName(CurrentJnlBatchName: Code[10]; var AccrualJnlLine: Record "Accrual Journal Line")
    var
        AccrualJnlBatch: Record "Accrual Journal Batch";
    begin
        AccrualJnlBatch.Get(AccrualJnlLine.GetRangeMax("Journal Template Name"), CurrentJnlBatchName);
    end;

    procedure SetName(CurrentJnlBatchName: Code[10]; var AccrualJnlLine: Record "Accrual Journal Line")
    begin
        AccrualJnlLine.FilterGroup := 2;
        AccrualJnlLine.SetRange("Journal Batch Name", CurrentJnlBatchName);
        AccrualJnlLine.FilterGroup := 0;
        if AccrualJnlLine.Find('-') then;
    end;

    procedure LookupName(var CurrentJnlBatchName: Code[10]; var AccrualJnlLine: Record "Accrual Journal Line")
    var
        AccrualJnlBatch: Record "Accrual Journal Batch";
    begin
        Commit;
        AccrualJnlBatch."Journal Template Name" := AccrualJnlLine.GetRangeMax("Journal Template Name");
        AccrualJnlBatch.Name := AccrualJnlLine.GetRangeMax("Journal Batch Name");
        AccrualJnlBatch.FilterGroup(2); // P8000643
        AccrualJnlBatch.SetRange("Journal Template Name", AccrualJnlBatch."Journal Template Name");
        AccrualJnlBatch.FilterGroup(0); // P8000643
        if PAGE.RunModal(0, AccrualJnlBatch) = ACTION::LookupOK then begin
            CurrentJnlBatchName := AccrualJnlBatch.Name;
            SetName(CurrentJnlBatchName, AccrualJnlLine);
        end;
    end;

    procedure GetNames(var AccrualJnlLine: Record "Accrual Journal Line"; var AccrualDescription: Text[100]; var AccName: Text[100])
    var
        AccrualPlan: Record "Accrual Plan";
        Customer: Record Customer;
        Vendor: Record Vendor;
        GLAccount: Record "G/L Account";
    begin
        // P8000466A - change AccName to TEXT50
        if (AccrualJnlLine."Accrual Plan Type" <> LastAccrualJnlLine."Accrual Plan Type") or
           (AccrualJnlLine."Accrual Plan No." <> LastAccrualJnlLine."Accrual Plan No.")
        then begin
            AccrualDescription := '';
            if AccrualPlan.Get(AccrualJnlLine."Accrual Plan Type", AccrualJnlLine."Accrual Plan No.") then
                AccrualDescription := AccrualPlan.Name;
        end;

        if (AccrualJnlLine.Type <> LastAccrualJnlLine.Type) or
           (AccrualJnlLine."No." <> LastAccrualJnlLine."No.")
        then begin
            AccName := '';
            if AccrualJnlLine."No." <> '' then
                case AccrualJnlLine.Type of
                    AccrualJnlLine.Type::Customer:
                        if Customer.Get(AccrualJnlLine."No.") then
                            AccName := Customer.Name;
                    AccrualJnlLine.Type::Vendor:
                        if Vendor.Get(AccrualJnlLine."No.") then
                            AccName := Vendor.Name;
                    AccrualJnlLine.Type::"G/L Account":
                        if GLAccount.Get(AccrualJnlLine."No.") then
                            AccName := GLAccount.Name;
                end;
        end;

        LastAccrualJnlLine := AccrualJnlLine;
    end;
}

