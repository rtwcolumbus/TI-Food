table 37002709 "Label Printer Selection"
{
    Caption = 'Label Printer Selection';

    fields
    {
        field(1; "No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'No.';
        }
        field(2; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(3; "Label Code"; Code[10])
        {
            Caption = 'Label Code';
            TableRelation = Label;

            trigger OnValidate()
            var
                Label: Record Label;
            begin
                if Label.Get("Label Code") then
                    if Label.Method <> Label.Method::Report then
                        "Printer Name" := '';
            end;
        }
        field(4; "User ID"; Code[50])
        {
            Caption = 'User ID';
            TableRelation = User."User Name";
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("User ID");
            end;
        }
        field(10; "Printer Name"; Text[250])
        {
            Caption = 'Printer Name';
            TableRelation = Printer;
            ValidateTableRelation = false;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    procedure SetKeyFieldFilters(LabelPrinterSelection: Record "Label Printer Selection")
    begin
        SetRange("Location Code", LabelPrinterSelection."Location Code");
        SetRange("Label Code", LabelPrinterSelection."Label Code");
        SetRange("User ID", LabelPrinterSelection."User ID");
        OnSetKeyFieldFilters(LabelPrinterSelection, Rec);
    end;

    procedure GetPrinterName(LabelCode: Code[10]) PrinterName: Text
    var
        Label: Record Label;
        LabelMethod: Interface "Label Method";
    begin
        Label.Get(LabelCode);
        LabelMethod := Label.Method;
        PrinterName := LabelMethod.PrinterName(Rec);
    end;

    local procedure TestUnique(Rec: Record "Label Printer Selection")
    var
        LabelPrinterSelection: Record "Label Printer Selection";
    begin
        TestUnique(Rec, LabelPrinterSelection);
    end;

    local procedure TestUnique(Rec: Record "Label Printer Selection"; xRec: Record "Label Printer Selection")
    var
        LabelPrinterSelection: Record "Label Printer Selection";
        KeyFieldsChanged: Boolean;
        AlreadyExists: Label '%1 for %2 already exists.';
    begin
        KeyFieldsChanged := (Rec."Location Code" <> xRec."Location Code") or
           (Rec."Label Code" <> xRec."Label Code") or
           (Rec."User ID" <> xRec."User ID");
        if not KeyFieldsChanged then
            OnCheckKeyFieldsChanged(Rec, xRec, KeyFieldsChanged);
        if not KeyFieldsChanged then
            exit;

        LabelPrinterSelection.SetKeyFieldFilters(Rec);
        if not LabelPrinterSelection.IsEmpty then
            error(AlreadyExists, TableCaption, GetKeyFieldList(LabelPrinterSelection));
    end;

    local procedure GetKeyFieldList(var FilterRec: Record "Label Printer Selection") KeyFieldList: Text
    var
        CurrentRecRecordRef: RecordRef;
        FilterRecRecordRef: RecordRef;
        FilterFieldRef: FieldRef;
        Index: Integer;
    begin
        CurrentRecRecordRef.GetTable(Rec);
        FilterRecRecordRef.GetTable(FilterRec);
        for Index := 1 to FilterRecRecordRef.FieldCount do begin
            FilterFieldRef := FilterRecRecordRef.FieldIndex(Index);
            if FilterFieldRef.GetFilter <> '' then begin
                FilterFieldRef := CurrentRecRecordRef.FieldIndex(Index);
                KeyFieldList := KeyFieldList +
                  StrSubstNo(', %1 ''%2''', FilterFieldRef.Caption, FilterFieldRef.Value);
            end;
        end;
        KeyFieldList := CopyStr(KeyFieldList, 3);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckKeyFieldsChanged(Rec: Record "Label Printer Selection"; xRec: Record "Label Printer Selection"; var KeyFieldsChanged: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetKeyFieldFilters(SourceRec: Record "Label Printer Selection"; var FilterRec: Record "Label Printer Selection")
    begin
    end;

    trigger OnInsert()
    begin
        TestUnique(Rec);
        "No." := 0;
    end;

    trigger OnModify()
    begin
        TestUnique(Rec, xRec);
    end;
}