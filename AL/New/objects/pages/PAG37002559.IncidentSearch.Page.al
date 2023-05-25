page 37002559 "Incident Search"
{
    // PRW111.00.01
    // P80036649, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Incident/Complaint Registration
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    AutoSplitKey = true;
    Caption = 'Incident Search';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Worksheet;
    SourceTable = "Incident Comment Line";
    SourceTableTemporary = true;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'Search';
                field(FindWhat; SearchText)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Find What';
                    ToolTip = 'Specify containing text';

                    trigger OnValidate()
                    begin
                        Clear(SearchTextResult);
                        FindPush;
                    end;
                }
                field(FindAny; SearchAny)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Find Any';
                    ToolTip = 'Select if finding any of the keyword';

                    trigger OnValidate()
                    begin
                        Clear(SearchTextResult);
                        FindPush;
                    end;
                }
            }
            group(Results)
            {
                Caption = 'Result Set';
                group(Control37002014)
                {
                    ShowCaption = false;
                    field(FindWhatResult; SearchTextResult)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Find What';
                        Editable = SearchText <> '';
                        ToolTip = 'Specify containing text within the result set';

                        trigger OnValidate()
                        begin
                            FindPush;
                        end;
                    }
                }
            }
            repeater(Loop)
            {
                Caption = 'Loop';
                field(Hits; Hits)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field(Source; Format("Incident Entry Record ID"))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Source Record';
                    Editable = false;
                }
                field(SourceFieldName; SourceFieldName)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Source Columns';
                    Editable = false;
                }
                field(Comment; Comment)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Result';
                    Editable = false;

                    trigger OnAssistEdit()
                    var
                        RecordVariant: Variant;
                        RecRef: RecordRef;
                    begin
                        ShowNAVRecord;
                    end;
                }
                field(Records; Records)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Total Records';
                    Editable = false;
                    Visible = false;

                    trigger OnAssistEdit()
                    var
                        PageManagement: Codeunit "Page Management";
                        PageID: Integer;
                        RecRef: RecordRef;
                        TableMetadata: Record "Table Metadata";
                    begin
                        if "Table ID" = DATABASE::"Table Metadata" then begin
                            RecRef.Get("Incident Entry Record ID");
                            RecRef.SetTable(TableMetadata);
                            PageID := PageManagement.GetDefaultLookupPageID(TableMetadata.ID);
                        end else
                            PageID := PageManagement.GetDefaultLookupPageID("Table ID");
                        if PageID <> 0 then
                            PAGE.RunModal(PageID);
                    end;
                }
            }
            part(Lines; "Incident Entries Subpage")
            {
                ApplicationArea = FOODBasic;
                Editable = false;
                SubPageLink = SourceRecordID = FIELD(IncidentRecID),
                              SourceRecordID2 = FIELD(IncidentRecID2);
                SubPageView = SORTING("Entry No.");
                Visible = LinesVisible;
            }
            part(AllLines; "Incident Entries Subpage")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Incident Entries - All';
                Editable = false;
                SubPageView = SORTING("Entry No.");
                Visible = AllLinesVisible;
            }
        }
    }

    actions
    {
        area(creation)
        {
        }
        area(navigation)
        {
            action(CreateIncident)
            {
                ApplicationArea = FOODBasic;
                Caption = '&Create Incident';
                Image = CreateInteraction;
                ToolTip = 'Create Incident';

                trigger OnAction()
                var
                    RecRef: RecordRef;
                    CreateIncident: Codeunit "Incident Management";
                begin
                    RecRef.Get("Incident Entry Record ID");
                    CreateIncident.CreateEntryFromSource(RecRef);
                end;
            }
            action(OpenDocument)
            {
                ApplicationArea = FOODBasic;
                Caption = '&Record';
                Image = ViewDetails;
                ToolTip = 'Open the source record';

                trigger OnAction()
                begin
                    ShowNAVRecord;
                end;
            }
            action("Advanced Search")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Advanced Search';
                Image = Find;
                ToolTip = 'Specify advance search criteria';

                trigger OnAction()
                begin
                    PerformAdvancedSearch;
                end;
            }
        }
        area(Promoted)
        {
            actionref(CreateIncident_Promoted; CreateIncident)
            {
            }
            actionref(OpenDocument_Promoted; OpenDocument)
            {
            }
            actionref(AdvancedSearch_Promoted; "Advanced Search")
            {
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetVisibility;
    end;

    trigger OnAfterGetRecord()
    begin
        GetSourceDetails(Rec, SourceFieldName, Records);
    end;

    trigger OnOpenPage()
    begin
        SetVisibility;
    end;

    var
        SearchText: Text;
        SearchAny: Boolean;
        SearchTextResult: Text;
        Records: Integer;
        SourceFieldName: Text;
        LinesVisible: Boolean;
        AllLinesVisible: Boolean;
        TempFilterRecords: Record "Incident Search Setup" temporary;
        EntryNo: Integer;

    local procedure GetCaption(): Text[250]
    begin
    end;

    local procedure FindPush()
    var
        IncidentSearchManagement: Codeunit "Incident Search Management";
    begin
        Clear(IncidentSearchManagement);
        if SearchTextResult <> '' then
            IncidentSearchManagement.InitializeFindResultSet(SearchAny, Rec)
        else
            IncidentSearchManagement.Initialize(SearchAny);
        IncidentSearchManagement.PerformSearch(SearchText, SearchTextResult);
        IncidentSearchManagement.GetResultSet(Rec);
        Reset;
        SetCurrentKey(Hits);
        Ascending(false);
        if FindSet then;

        CurrPage.Update(false);
    end;

    local procedure GetSourceDetails(IncidentBuffer: Record "Incident Comment Line"; var FieldName: Text; var RecordCount: Integer)
    var
        SourceRecRef: RecordRef;
        RecordField: Record "Field";
        NullRecID: RecordID;
        TableMetadata: Record "Table Metadata";
        RecRef: RecordRef;
    begin
        FieldName := '';
        Clear(RecordCount);
        if (Format(IncidentBuffer."Incident Entry Record ID") = Format(NullRecID)) then
            exit;
        if SourceRecRef.Get(IncidentBuffer."Incident Entry Record ID") then begin
            case SourceRecRef.Number of
                DATABASE::"Table Metadata":
                    SourceRecRef.SetTable(TableMetadata);
            end;
            SourceRecRef.Close;
            if TableMetadata.ID <> 0 then begin
                SourceRecRef.Open(TableMetadata.ID);
            end else begin
                SourceRecRef.Open(IncidentBuffer."Table ID");
            end;
            RecordCount := SourceRecRef.Count;
        end;
        // IF RecordField.GET("Table ID","Source Field No.") THEN
        //  FieldName := RecordField.FieldName;
        FieldName := IncidentBuffer."Source Field Name";
    end;

    local procedure SetVisibility()
    var
        IncidentEntry: Record "Incident Entry";
    begin
        AllLinesVisible := (SearchText = '') and (SearchTextResult = '');

        IncidentEntry.SetRange("Source Record ID", "Incident Entry Record ID");
        LinesVisible := not IncidentEntry.IsEmpty;
    end;

    local procedure PerformAdvancedSearch()
    var
        TableFilters: Page "Incident Table Filters";
        RecordRef: RecordRef;
    begin
        TableFilters.LookupMode := true;
        if TableFilters.RunModal = ACTION::LookupOK then begin
            Reset;
            DeleteAll;
            TableFilters.GetRecordFilters(TempFilterRecords);
            TempFilterRecords.Reset;
            if TempFilterRecords.FindFirst then
                repeat
                    GetFilteredRecord(TempFilterRecords, RecordRef, GetFiltersAsText(TempFilterRecords));
                    if RecordRef.GetFilters <> '' then begin
                        if RecordRef.FindFirst then
                            repeat
                                InsertLine(RecordRef);
                            until RecordRef.Next = 0;
                    end;
                    RecordRef.Close;
                until TempFilterRecords.Next = 0;
        end;
        Reset;
        SetCurrentKey(Hits);
        Ascending(false);
        if FindSet then;

        CurrPage.Update(false);
    end;

    local procedure InsertLine(var RecRef: RecordRef)
    var
        TableMetadata: Record "Table Metadata";
    begin
        EntryNo += 1;
        Init;
        "Entry No." := EntryNo;
        "Table ID" := RecRef.Number;
        "Incident Entry Record ID" := RecRef.RecordId;
        IncidentRecID := CopyStr(Format("Incident Entry Record ID"), 1, 249);
        IncidentRecID2 := CopyStr(Format("Incident Entry Record ID"), 250, 499);
        TableMetadata.Get("Table ID");
        Comment := TableMetadata.Name;
        if Insert then;
    end;

    local procedure GetFilteredRecord(var TempFilterRecords: Record "Incident Search Setup" temporary; var RecordRef: RecordRef; Filters: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        FiltersOutStream: OutStream;
    begin
        // P800-MegaApp
        //TempBlob.Init;
        TempBlob.CreateOutStream(FiltersOutStream);
        // P800-MegaApp
        FiltersOutStream.Write(Filters);

        RecordRef.Open(TempFilterRecords."Table No.");
        RequestPageParametersHelper.ConvertParametersToFilters(RecordRef, TempBlob);
    end;

    local procedure GetFiltersAsText(var TempFilterRecords: Record "Incident Search Setup" temporary) Filters: Text
    var
        FiltersInStream: InStream;
    begin
        TempFilterRecords.CalcFields("Apply to Table Filter");
        if not TempFilterRecords."Apply to Table Filter".HasValue then
            exit;
        TempFilterRecords."Apply to Table Filter".CreateInStream(FiltersInStream);
        FiltersInStream.Read(Filters);
    end;
}

