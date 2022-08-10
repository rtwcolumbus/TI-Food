table 37002552 "Incident Search Setup"
{
    // PRW111.00.01
    // P80036649, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Incident/Complaint Registration

    Caption = 'Incident Search Setup';

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table));

            trigger OnLookup()
            var
                AllObjWithCaption: Record AllObjWithCaption;
            begin
                if PAGE.RunModal(PAGE::"Table Objects", AllObjWithCaption) = ACTION::LookupOK then begin
                    if AllObjWithCaption."Object ID" > 0 then
                        Validate("Table No.", AllObjWithCaption."Object ID");
                end;
            end;

            trigger OnValidate()
            var
                AllObjWithCaption: Record AllObjWithCaption;
            begin
                if "Table No." = xRec."Table No." then
                    exit;
                Validate("Field No.", 0);

                AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
                AllObjWithCaption.SetRange("Object ID", "Table No.");
                AllObjWithCaption.FindFirst;
                "Table Name" := AllObjWithCaption."Object Name";
            end;
        }
        field(2; "Field No."; Integer)
        {
            Caption = 'Field No.';
            NotBlank = true;
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table No."));

            trigger OnLookup()
            var
                "Field": Record "Field";
                FieldSelection: Codeunit "Field Selection";
            begin
                if "Table No." = 0 then
                    exit;
                Field.SetRange(TableNo, "Table No.");
                if FieldSelection.Open(Field) then // P800-MegaApp
                    Validate("Field No.", Field."No.");
            end;

            trigger OnValidate()
            var
                "Field": Record "Field";
            begin
                TestField("Table No.");
                if "Field No." = xRec."Field No." then
                    exit;

                "Field Name" := '';
                if "Field No." <> 0 then
                    Field.Get("Table No.", "Field No.");
                "Field Name" := Field.FieldName;
            end;
        }
        field(3; "Field Name"; Text[100])
        {
            CalcFormula = Lookup (Field."Field Caption" WHERE(TableNo = FIELD("Table No."),
                                                              "No." = FIELD("Field No.")));
            Caption = 'Field Name';
            FieldClass = FlowField;
        }
        field(4; "Table Name"; Text[100])
        {
            Caption = 'Table Name';
        }
        field(5; "Apply to Table Filter"; BLOB)
        {
            Caption = 'Filter';
        }
        field(11; "Incident Entry Table No."; Integer)
        {
            Caption = 'Incident Entry Table No.';
        }
        field(12; "Incident Entry Field No."; Integer)
        {
            Caption = 'Incident Entry Field No.';
            TableRelation = Field."No." WHERE(TableNo = FIELD("Incident Entry Table No."));

            trigger OnLookup()
            var
                "Field": Record "Field";
                FieldSelection: Codeunit "Field Selection";
            begin
                if "Incident Entry Table No." = 0 then
                    exit;
                Field.SetRange(TableNo, "Incident Entry Table No.");
                if FieldSelection.Open(Field) then // P800-MegaApp
                    Validate("Incident Entry Table No.", Field."No."); // P800-MegaApp
            end;

            trigger OnValidate()
            var
                "Field": Record "Field";
            begin
                TestField("Incident Entry Table No.");
                if "Field No." = xRec."Field No." then
                    exit;

                "Field Name" := '';
                if "Field No." <> 0 then
                    Field.Get("Incident Entry Table No.", "Field No.");
                "Field Name" := Field.FieldName;
            end;
        }
    }

    keys
    {
        key(Key1; "Table No.", "Field No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        ViewFilterDetailsTxt: Label '(Add/View filter details)';
        DefineFiltersTxt: Label 'Define filters...';

    local procedure IsFilterEnabled(): Boolean
    begin
        exit(("Table No." <> 0));
    end;

    local procedure InitRecord(NotificationId: Guid; NotificationName: Text[128]; DescriptionText: Text) Result: Boolean
    var
        OutStream: OutStream;
    begin
        if not Get(UserId, NotificationId) then begin
            Init;
            OutStream.Write(DescriptionText);
            Result := true;
        end;
    end;

    procedure InsertDefault(NotificationId: Guid; NotificationName: Text[128]; DescriptionText: Text; DefaultState: Boolean)
    begin
        if InitRecord(NotificationId, NotificationName, DescriptionText) then begin
            Insert;
        end;
    end;

    procedure InsertDefaultWithTableNum(NotificationId: Guid; NotificationName: Text[128]; DescriptionText: Text; TableNum: Integer)
    begin
        if InitRecord(NotificationId, NotificationName, DescriptionText) then begin
            "Table No." := TableNum;
            Insert;
        end;
    end;

    local procedure GetFilteredRecord(var RecordRef: RecordRef; Filters: Text)
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

        RecordRef.Open("Table No.");
        RequestPageParametersHelper.ConvertParametersToFilters(RecordRef, TempBlob);
    end;

    procedure GetFiltersAsDisplayText(): Text
    var
        RecordRef: RecordRef;
    begin
        if not IsFilterEnabled then
            exit;

        GetFilteredRecord(RecordRef, GetFiltersAsText);

        if RecordRef.GetFilters <> '' then
            exit(RecordRef.GetFilters);

        exit(ViewFilterDetailsTxt);
    end;

    local procedure GetFiltersAsText() Filters: Text
    var
        FiltersInStream: InStream;
    begin
        if not IsFilterEnabled then
            exit;

        CalcFields("Apply to Table Filter");
        if not "Apply to Table Filter".HasValue then
            exit;
        "Apply to Table Filter".CreateInStream(FiltersInStream);
        FiltersInStream.Read(Filters);
    end;

    procedure OpenFilterSettings() Changed: Boolean
    var
        DummyMyNotifications: Record "My Notifications";
        RecordRef: RecordRef;
        FiltersOutStream: OutStream;
        NewFilters: Text;
    begin
        if not IsFilterEnabled then
            exit;

        if RunDynamicRequestPage(NewFilters,
             GetFiltersAsText,
             "Table No.")
        then begin
            GetFilteredRecord(RecordRef, NewFilters);
            if RecordRef.GetFilters = '' then
                "Apply to Table Filter" := DummyMyNotifications."Apply to Table Filter"
            else begin
                "Apply to Table Filter".CreateOutStream(FiltersOutStream);
                FiltersOutStream.Write(NewFilters);
            end;
            Modify;
            Changed := true;
        end;
    end;

    local procedure RunDynamicRequestPage(var ReturnFilters: Text; Filters: Text; TableNum: Integer) FiltersSet: Boolean
    var
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        FilterPageBuilder: FilterPageBuilder;
    begin
        if not RequestPageParametersHelper.BuildDynamicRequestPage(FilterPageBuilder, DefineFiltersTxt, TableNum) then
            exit(false);

        if Filters <> '' then
            if not RequestPageParametersHelper.SetViewOnDynamicRequestPage(
                 FilterPageBuilder, Filters, DefineFiltersTxt, TableNum)
            then
                exit(false);

        FilterPageBuilder.PageCaption := DefineFiltersTxt;
        if not FilterPageBuilder.RunModal then
            exit(false);

        ReturnFilters :=
          RequestPageParametersHelper.GetViewFromDynamicRequestPage(FilterPageBuilder, DefineFiltersTxt, TableNum);

        FiltersSet := true;
    end;

    procedure IsEnabledForRecord(NotificationId: Guid; "Record": Variant): Boolean
    var
        RecordRef: RecordRef;
        RecordRefPassed: RecordRef;
        Filters: Text;
    begin
        if not Record.IsRecord then
            exit(true);

        RecordRefPassed.GetTable(Record);
        RecordRefPassed.FilterGroup(2);
        RecordRefPassed.SetRecFilter;
        RecordRefPassed.FilterGroup(0);

        Filters := GetFiltersAsText;
        if Filters = '' then
            exit(true);

        GetFilteredRecord(RecordRef, Filters);
        RecordRefPassed.SetView(RecordRef.GetView);
        exit(not RecordRefPassed.IsEmpty);
    end;

    [IntegrationEvent(false, false)]
    procedure OnStateChanged(NotificationId: Guid; NewEnabledState: Boolean)
    begin
    end;

    procedure GetFieldCaption(): Text
    var
        recRef: RecordRef;
        fieldRef: FieldRef;
    begin
        if "Incident Entry Table No." = 0 then
            exit(' ');
        if "Incident Entry Field No." = 0 then
            exit(' ');
        recRef.Open("Incident Entry Table No.");
        fieldRef := recRef.Field("Incident Entry Field No.");
        exit(fieldRef.Caption);
    end;
}

