codeunit 37002804 "Maintenance Journal Management"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 31 AUG 06
    //   Standard code for journal management codenit adapted for maintenance journal template/batch
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 09 AUG 07
    //   GetVendor - change VendorName to TEXT50
    // 
    // PRW16.00
    // P8000643, VerticalSoft, Jack Reynolds, 20 NOV 08
    //   New functions TemplateSelectionFromBatch and OpenJnlBatch defined to follow the patter in other
    //     journal management codeunits
    // 
    // PRW16.00.01
    // P8000719, VerticalSoft, Jack Reynolds, 10 AUG 09
    //   Support for combined maintenance journal
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 03 FEB 09
    //   Expand AssetDescription and ItemDescription to 50 characters
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00


    trigger OnRun()
    begin
    end;

    var
        Text000: Label '%1 journal';
        Text001: Label 'DEFAULT';
        Text002: Label 'Default Journal';
        OpenFromBatch: Boolean;
        OldWorkOrderNo: Code[20];
        OldVendorNo: Code[20];
        OldItemNo: Code[20];
        Text003: Label 'Maintenance Journal';

    procedure TemplateSelection(FormID: Integer; FormTemplate: Option Labor,Material,Contract,Maintenance; var MaintJnlLine: Record "Maintenance Journal Line"; var JnlSelected: Boolean)
    var
        MaintJnlTemplate: Record "Maintenance Journal Template";
    begin
        // P8000719 - add Maintenance to FormTemplate
        MaintJnlLine.FilterGroup := 2;
        JnlSelected := MaintJnlLine.GetFilter("Journal Template Name") <> '';
        MaintJnlLine.FilterGroup := 0;
        if JnlSelected then
            exit;

        JnlSelected := true;

        MaintJnlTemplate.Reset;
        MaintJnlTemplate.SetRange("Page ID", FormID);
        MaintJnlTemplate.SetRange(Type, FormTemplate);

        case MaintJnlTemplate.Count of
            0:
                begin
                    MaintJnlTemplate.Init;
                    MaintJnlTemplate.Validate(Type, FormTemplate);
                    MaintJnlTemplate.Validate("Page ID");
                    MaintJnlTemplate.Name := Format(MaintJnlTemplate.Type, MaxStrLen(MaintJnlTemplate.Name));
                    MaintJnlTemplate.Description := StrSubstNo(Text000, MaintJnlTemplate.Type);
                    MaintJnlTemplate.Insert;
                    Commit;
                end;
            1:
                MaintJnlTemplate.FindFirst;
            else
                JnlSelected := PAGE.RunModal(0, MaintJnlTemplate) = ACTION::LookupOK;
        end;
        if JnlSelected then begin
            MaintJnlLine.FilterGroup := 2;
            MaintJnlLine.SetRange("Journal Template Name", MaintJnlTemplate.Name);
            MaintJnlLine.FilterGroup := 0;
        end;
    end;

    procedure TemplateSelectionFromBatch(var MaintJnlBatch: Record "Maintenance Journal Batch")
    var
        MaintJnlLine: Record "Maintenance Journal Line";
        JnlSelected: Boolean;
        MaintJnlTemplate: Record "Maintenance Journal Template";
    begin
        // P8000643
        OpenFromBatch := true;
        MaintJnlTemplate.Get(MaintJnlBatch."Journal Template Name");
        MaintJnlTemplate.TestField("Page ID");
        MaintJnlBatch.TestField(Name);

        MaintJnlLine.FilterGroup := 2;
        MaintJnlLine.SetRange("Journal Template Name", MaintJnlTemplate.Name);
        MaintJnlLine.FilterGroup := 0;

        MaintJnlLine."Journal Template Name" := '';
        MaintJnlLine."Journal Batch Name" := MaintJnlBatch.Name;
        PAGE.Run(MaintJnlTemplate."Page ID", MaintJnlLine);
    end;

    procedure OpenJnl(var CurrentJnlBatchName: Code[10]; var MaintJnlLine: Record "Maintenance Journal Line")
    begin
        CheckTemplateName(MaintJnlLine.GetRangeMax("Journal Template Name"), CurrentJnlBatchName);
        MaintJnlLine.FilterGroup := 2;
        MaintJnlLine.SetRange("Journal Batch Name", CurrentJnlBatchName);
        MaintJnlLine.FilterGroup := 0;
    end;

    procedure OpenJnlBatch(var MaintJnlBatch: Record "Maintenance Journal Batch")
    var
        MaintJnlTemplate: Record "Maintenance Journal Template";
        MaintJnlLine: Record "Maintenance Journal Line";
        MaintJnlBatch2: Record "Maintenance Journal Batch";
        JnlSelected: Boolean;
    begin
        // P8000643
        if MaintJnlBatch.GetFilter("Journal Template Name") <> '' then
            exit;
        MaintJnlBatch.FilterGroup(2);
        if MaintJnlBatch.GetFilter("Journal Template Name") <> '' then begin
            MaintJnlBatch.FilterGroup(0);
            exit;
        end;
        MaintJnlBatch.FilterGroup(0);

        if not MaintJnlBatch.Find('-') then begin
            for MaintJnlTemplate.Type := MaintJnlTemplate.Type::Labor to MaintJnlTemplate.Type::Maintenance do begin // P8000719
                MaintJnlTemplate.SetRange(Type, MaintJnlTemplate.Type);
                if not MaintJnlTemplate.Find('-') then
                    TemplateSelection(0, MaintJnlTemplate.Type, MaintJnlLine, JnlSelected);
                if MaintJnlTemplate.Find('-') then
                    CheckTemplateName(MaintJnlTemplate.Name, MaintJnlBatch.Name);
            end;
        end;
        MaintJnlBatch.Find('-');
        JnlSelected := true;
        MaintJnlBatch.CalcFields("Template Type");
        MaintJnlTemplate.SetRange(Type, MaintJnlBatch."Template Type");
        if MaintJnlBatch.GetFilter("Journal Template Name") <> '' then
            MaintJnlTemplate.SetRange(Name, MaintJnlBatch.GetFilter("Journal Template Name"));
        case MaintJnlTemplate.Count of
            1:
                MaintJnlTemplate.Find('-');
            else
                JnlSelected := PAGE.RunModal(0, MaintJnlTemplate) = ACTION::LookupOK;
        end;
        if not JnlSelected then
            Error('');

        MaintJnlBatch.FilterGroup(0);
        MaintJnlBatch.SetRange("Journal Template Name", MaintJnlTemplate.Name);
        MaintJnlBatch.FilterGroup(2);
    end;

    procedure CheckTemplateName(CurrentJnlTemplateName: Code[10]; var CurrentJnlBatchName: Code[10])
    var
        MaintJnlBatch: Record "Maintenance Journal Batch";
    begin
        MaintJnlBatch.SetRange("Journal Template Name", CurrentJnlTemplateName);
        if not MaintJnlBatch.Get(CurrentJnlTemplateName, CurrentJnlBatchName) then begin
            if not MaintJnlBatch.FindFirst then begin
                MaintJnlBatch.Init;
                MaintJnlBatch."Journal Template Name" := CurrentJnlTemplateName;
                MaintJnlBatch.SetupNewBatch;
                MaintJnlBatch.Name := Text001;
                MaintJnlBatch.Description := Text002;
                MaintJnlBatch.Insert(true);
                Commit;
            end;
            CurrentJnlBatchName := MaintJnlBatch.Name
        end;
    end;

    procedure CheckName(CurrentJnlBatchName: Code[10]; var MaintJnlLine: Record "Maintenance Journal Line")
    var
        MaintJnlBatch: Record "Maintenance Journal Batch";
    begin
        MaintJnlBatch.Get(MaintJnlLine.GetRangeMax("Journal Template Name"), CurrentJnlBatchName);
    end;

    procedure SetName(CurrentJnlBatchName: Code[10]; var MaintJnlLine: Record "Maintenance Journal Line")
    begin
        MaintJnlLine.FilterGroup := 2;
        MaintJnlLine.SetRange("Journal Batch Name", CurrentJnlBatchName);
        MaintJnlLine.FilterGroup := 0;
        if MaintJnlLine.FindFirst then;
    end;

    procedure LookupName(var CurrentJnlBatchName: Code[10]; var MaintJnlLine: Record "Maintenance Journal Line")
    var
        MaintJnlBatch: Record "Maintenance Journal Batch";
    begin
        Commit;
        MaintJnlBatch."Journal Template Name" := MaintJnlLine.GetRangeMax("Journal Template Name");
        MaintJnlBatch.Name := MaintJnlLine.GetRangeMax("Journal Batch Name");
        MaintJnlBatch.FilterGroup(2); // P8000643
        MaintJnlBatch.SetRange("Journal Template Name", MaintJnlBatch."Journal Template Name");
        MaintJnlBatch.FilterGroup(0); // P8000643
        if PAGE.RunModal(0, MaintJnlBatch) = ACTION::LookupOK then begin
            CurrentJnlBatchName := MaintJnlBatch.Name;
            SetName(CurrentJnlBatchName, MaintJnlLine);
        end;
    end;

    procedure GetWorkOrder(WorkOrderNo: Code[20]; var AssetDescription: Text[100])
    var
        WorkOrder: Record "Work Order";
    begin
        // P8000664 - AssetDescription changed to Text50
        if WorkOrderNo <> OldWorkOrderNo then begin
            AssetDescription := '';
            if WorkOrderNo <> '' then
                if WorkOrder.Get(WorkOrderNo) then
                    AssetDescription := WorkOrder."Asset Description";
            OldWorkOrderNo := WorkOrderNo;
        end;
    end;

    procedure GetVendor(VendorNo: Code[20]; var VendorName: Text[100])
    var
        Vendor: Record Vendor;
    begin
        // P8000466A - change VendorName to TEXT50
        if VendorNo <> OldVendorNo then begin
            VendorName := '';
            if VendorNo <> '' then
                if Vendor.Get(VendorNo) then
                    VendorName := Vendor.Name;
            OldVendorNo := VendorNo;
        end;
    end;

    procedure GetItem(ItemNo: Code[20]; var ItemDescription: Text[100])
    var
        Item: Record Item;
    begin
        // P8000664 - ItemDescription changed to Text50
        if ItemNo <> OldItemNo then begin
            ItemDescription := '';
            if ItemNo <> '' then
                if Item.Get(ItemNo) then
                    ItemDescription := Item.Description;
            OldItemNo := ItemNo;
        end;
    end;

    procedure RunForWorkOrder(WorkOrder: Record "Work Order")
    var
        MaintJnlTemplate: Record "Maintenance Journal Template";
        MaintJnlBatch: Record "Maintenance Journal Batch";
        MaintJnlLine: Record "Maintenance Journal Line";
        BatchName: Code[10];
    begin
        // P8000719
        MaintJnlTemplate.SetRange("Page ID", PAGE::"Maintenance Journal");
        MaintJnlTemplate.SetRange(Type, MaintJnlTemplate.Type::Maintenance);
        if not MaintJnlTemplate.Find('-') then begin
            MaintJnlTemplate.Init;
            MaintJnlTemplate.Validate(Type, MaintJnlTemplate.Type::Maintenance);
            MaintJnlTemplate.Validate("Page ID");

            MaintJnlTemplate.Name := Format(MaintJnlTemplate.Type, MaxStrLen(MaintJnlTemplate.Name));
            MaintJnlTemplate.Description := StrSubstNo(Text000, MaintJnlTemplate.Type);
            MaintJnlTemplate.Insert;
        end;

        if StrLen(WorkOrder."No.") < MaxStrLen(BatchName) then
            BatchName := WorkOrder."No."
        else
            BatchName := CopyStr(WorkOrder."No.", StrLen(WorkOrder."No.") + 1 - MaxStrLen(BatchName));

        if not MaintJnlBatch.Get(MaintJnlTemplate.Name, BatchName) then begin
            MaintJnlBatch.Init;
            MaintJnlBatch."Journal Template Name" := MaintJnlTemplate.Name;
            MaintJnlBatch.SetupNewBatch;
            MaintJnlBatch.Name := BatchName;
            MaintJnlBatch.Description := Text003;
            MaintJnlBatch.Insert(true);
        end;

        Commit;

        MaintJnlLine.FilterGroup := 2;
        MaintJnlLine.SetRange("Journal Template Name", MaintJnlTemplate.Name);
        MaintJnlLine.SetRange("Work Order No.", WorkOrder."No.");
        MaintJnlLine.FilterGroup := 0;
        MaintJnlLine."Journal Batch Name" := BatchName;

        PAGE.RunModal(MaintJnlTemplate."Page ID", MaintJnlLine);

        MaintJnlLine.SetRange("Journal Batch Name", BatchName);
        if MaintJnlLine.IsEmpty then
            if MaintJnlBatch.Delete(true) then;
    end;
}

