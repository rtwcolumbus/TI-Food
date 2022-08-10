codeunit 37002569 ContainerJnlManagement
{
    // PR3.70.07
    // P8000140A, Myers Nissi, Jack Reynolds, 19 NOV 04
    //   Container journal management functions
    // 
    // PRW16.00
    // P8000643, VerticalSoft, Jack Reynolds, 20 NOV 08
    //   New functions TemplateSelectionFromBatch and OpenJnlBatch defined to follow the patter in other
    //     journal management codeunits
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'CONTAINER';
        Text001: Label 'Container Journal';
        Text002: Label 'DEFAULT';
        Text003: Label 'Default Journal';
        OpenFromBatch: Boolean;

    procedure TemplateSelection(FormID: Integer; var ContJnlLine: Record "Container Journal Line"; var JnlSelected: Boolean)
    var
        ContJnlTemplate: Record "Container Journal Template";
    begin
        // PR4.00 - add parameters for FormId, ContJnlLine, JnlSelected
        JnlSelected := true;

        ContJnlTemplate.Reset;
        ContJnlTemplate.SetRange("Page ID", FormID); // PR4.00

        case ContJnlTemplate.Count of
            0:
                begin
                    ContJnlTemplate.Init;
                    ContJnlTemplate.Validate(Name, Text000);
                    ContJnlTemplate.Description := Text001;
                    ContJnlTemplate.Insert;
                    Commit;
                end;
            1:
                ContJnlTemplate.Find('-');
            else
                JnlSelected := PAGE.RunModal(0, ContJnlTemplate) = ACTION::LookupOK;
        end;
        if JnlSelected then begin
            ContJnlLine.FilterGroup := 2;
            ContJnlLine.SetRange("Journal Template Name", ContJnlTemplate.Name);
            ContJnlLine.FilterGroup := 0;
        end;
    end;

    procedure TemplateSelectionFromBatch(var ContJnlBatch: Record "Container Journal Batch")
    var
        ContJnlLine: Record "Container Journal Line";
        JnlSelected: Boolean;
        ContJnlTemplate: Record "Container Journal Template";
    begin
        // P8000643
        OpenFromBatch := true;
        ContJnlTemplate.Get(ContJnlBatch."Journal Template Name");
        ContJnlTemplate.TestField("Page ID");
        ContJnlBatch.TestField(Name);

        ContJnlLine.FilterGroup := 2;
        ContJnlLine.SetRange("Journal Template Name", ContJnlTemplate.Name);
        ContJnlLine.FilterGroup := 0;

        ContJnlLine."Journal Template Name" := '';
        ContJnlLine."Journal Batch Name" := ContJnlBatch.Name;
        PAGE.Run(ContJnlTemplate."Page ID", ContJnlLine);
    end;

    procedure OpenJnl(var CurrentJnlBatchName: Code[10]; var ContJnlLine: Record "Container Journal Line")
    begin
        CheckTemplateName(ContJnlLine.GetRangeMax("Journal Template Name"), CurrentJnlBatchName);
        ContJnlLine.FilterGroup := 2;
        ContJnlLine.SetRange("Journal Batch Name", CurrentJnlBatchName);
        ContJnlLine.FilterGroup := 0;
    end;

    procedure OpenJnlBatch(var ContJnlBatch: Record "Container Journal Batch")
    var
        ContJnlTemplate: Record "Container Journal Template";
        ContJnlLine: Record "Container Journal Line";
        JnlSelected: Boolean;
    begin
        // P8000643
        if ContJnlBatch.GetFilter("Journal Template Name") <> '' then
            exit;
        ContJnlBatch.FilterGroup(2);
        if ContJnlBatch.GetFilter("Journal Template Name") <> '' then begin
            ContJnlBatch.FilterGroup(0);
            exit;
        end;
        ContJnlBatch.FilterGroup(0);

        if not ContJnlBatch.Find('-') then begin
            if not ContJnlTemplate.Find('-') then
                TemplateSelection(0, ContJnlLine, JnlSelected);
            if ContJnlTemplate.Find('-') then
                CheckTemplateName(ContJnlTemplate.Name, ContJnlBatch.Name);
        end;
        ContJnlBatch.Find('-');
        JnlSelected := true;
        if ContJnlBatch.GetFilter("Journal Template Name") <> '' then
            ContJnlTemplate.SetRange(Name, ContJnlBatch.GetFilter("Journal Template Name"));
        case ContJnlTemplate.Count of
            1:
                ContJnlTemplate.Find('-');
            else
                JnlSelected := PAGE.RunModal(0, ContJnlTemplate) = ACTION::LookupOK;
        end;
        if not JnlSelected then
            Error('');

        ContJnlBatch.FilterGroup(2);
        ContJnlBatch.SetRange("Journal Template Name", ContJnlTemplate.Name);
        ContJnlBatch.FilterGroup(0);
    end;

    procedure CheckTemplateName(CurrentJnlTemplateName: Code[10]; var CurrentJnlBatchName: Code[10])
    var
        ContJnlBatch: Record "Container Journal Batch";
    begin
        ContJnlBatch.SetRange("Journal Template Name", CurrentJnlTemplateName);
        if not ContJnlBatch.Get(CurrentJnlTemplateName, CurrentJnlBatchName) then begin
            if not ContJnlBatch.Find('-') then begin
                ContJnlBatch.Init;
                ContJnlBatch."Journal Template Name" := CurrentJnlTemplateName;
                ContJnlBatch.SetupNewBatch;
                ContJnlBatch.Name := Text002;
                ContJnlBatch.Description := Text003;
                ContJnlBatch.Insert(true);
                Commit;
            end;
            CurrentJnlBatchName := ContJnlBatch.Name;
        end;
    end;

    procedure CheckName(CurrentJnlBatchName: Code[10]; var ContJnlLine: Record "Container Journal Line")
    var
        ContJnlBatch: Record "Container Journal Batch";
    begin
        ContJnlBatch.Get(ContJnlLine.GetRangeMax("Journal Template Name"), CurrentJnlBatchName);
    end;

    procedure SetName(CurrentJnlBatchName: Code[10]; var ContJnlLine: Record "Container Journal Line")
    begin
        ContJnlLine.FilterGroup := 2;
        ContJnlLine.SetRange("Journal Batch Name", CurrentJnlBatchName);
        ContJnlLine.FilterGroup := 0;
        if ContJnlLine.Find('-') then;
    end;

    procedure LookupName(var CurrentJnlBatchName: Code[10]; var ContJnlLine: Record "Container Journal Line")
    var
        ContJnlBatch: Record "Container Journal Batch";
    begin
        Commit;
        ContJnlBatch."Journal Template Name" := ContJnlLine.GetRangeMax("Journal Template Name");
        ContJnlBatch.Name := ContJnlLine.GetRangeMax("Journal Batch Name");
        ContJnlBatch.FilterGroup(2); // P8000643
        ContJnlBatch.SetRange("Journal Template Name", ContJnlBatch."Journal Template Name");
        ContJnlBatch.FilterGroup(0); // P8000643
        if PAGE.RunModal(0, ContJnlBatch) = ACTION::LookupOK then begin
            CurrentJnlBatchName := ContJnlBatch.Name;
            SetName(CurrentJnlBatchName, ContJnlLine);
        end;
    end;
}

