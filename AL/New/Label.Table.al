table 37002700 Label
{
    // PRW16.00.06
    // P8001123, Columbus IT, Jack Reynolds, 19 DEC 12
    //   Move Item table Label Code fields to Item Label table
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001141, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Cleanup ADC for NAV 2013
    // 
    // PRW17.10
    // P8001219, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Object name fields changed to captions
    // 
    // PRW18.00.03
    // P8006373, To-Increase, Jack Reynolds, 21 JAN 16
    //   Cleanup for BIS label printing
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.01
    // P80056709, To-Increase, Jack Reynolds, 25 JUL 18
    //   Production Containers - assign container to production order
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Label';
    LookupPageID = Labels;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(9; Type; Enum "Label Type")
        {
            Caption = 'Type';
        }
        field(10; "Connection No."; Code[20])
        {
            ObsoleteState = Removed;
        }
        field(11; Method; Enum "Label Method")
        {
            trigger OnValidate()
            begin
                if "Method" <> "Method"::Report then
                    Validate("Report ID", 0);
            end;

        }
        field(21; "Report ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Report ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Report));

            trigger OnValidate()
            var
                ReportMetaData: Record "Report Metadata";
                ReportDataitem: Record "Report Data Items";
            begin
                TestField(Type);

                if "Report ID" <> 0 then begin
                    ReportMetaData.Get("Report ID");
                    if ReportMetaData.ProcessingOnly then
                        Error(InvalidReport);
                    if ReportMetaData.FirstDataItemTableID <> Database::Integer then
                        Error(InvalidReport);

                    ReportDataitem.SetRange("Report ID", "Report ID");
                    ReportDataitem.SetFilter("Related Table ID", '<>%1', Database::Integer);

                    if ReportDataitem.Count <> 1 then
                        Error(InvalidReport);
                    ReportDataitem.FindFirst();
                    if (ReportDataitem."Indentation Level" <> 0) or (ReportDataitem."Related Table ID" <> GetLabelTableID()) then
                        Error(InvalidReport);
                end;

                CalcFields("Report Caption");
            end;
        }
        field(22; "Report Caption"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Report),
                                                                           "Object ID" = FIELD("Report ID")));
            Caption = 'Report Caption';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        InvalidReport: Label 'Invalid report.';

    local procedure GetLabelTableID()LabelTableID: Integer
    begin
        case Type of
            Type::"Case", Type::PreProcess:
                LabelTableID := Database::"Item Case Label";
            Type::Container:
                LabelTableID := Database::"Container Label";
            Type::ShippingContainer, Type::ProductionContainer:
                LabelTableID := Database::"Ship/Prod. Container Label";
        end;
    end;

    procedure LookupReport(var Text: Text): Boolean
    var
        AllObjectWithCaption: Record AllObjWithCaption;
        ReportMetadata: Record "Report Metadata";
        ReportDataitem: Record "Report Data Items";
        AllObjectsWithCaptionPage: Page "All Objects with Caption";
        LabelTableID: Integer;
    begin
        LabelTableID := GetLabelTableID();
        ReportMetadata.SetRange(ProcessingOnly, false);
        ReportMetadata.SetRange(FirstDataItemTableID, Database::Integer);
        if ReportMetadata.FindSet() then
            repeat
                AllObjectWithCaption.Get(AllObjectWithCaption."Object Type"::Report, ReportMetadata.ID);
                ReportDataitem.SetRange("Report ID", ReportMetadata.ID);
                ReportDataitem.SetFilter("Related Table ID", '<>%1', Database::Integer);
                if ReportDataitem.Count = 1 then begin 
                    ReportDataitem.FindFirst();
                    if (ReportDataitem."Indentation Level" = 0) and (ReportDataitem."Related Table ID" = LabelTableID) then
                        AllObjectWithCaption.Mark(true);
                end;                
            until ReportMetadata.Next() = 0;

        AllObjectWithCaption.MarkedOnly(true);
        AllObjectsWithCaptionPage.SetTableView(AllObjectWithCaption);
        AllObjectsWithCaptionPage.LookupMode(true);
        if AllObjectsWithCaptionPage.RunModal() = Action::LookupOK then begin
            AllObjectsWithCaptionPage.GetRecord(AllObjectWithCaption);
            Text := Format(AllObjectWithCaption."Object ID");
            exit(true);
        end;

    end;
}

