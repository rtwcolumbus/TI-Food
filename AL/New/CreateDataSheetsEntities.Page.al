page 37002880 "Create Data Sheets-Entities"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection

    Caption = 'Create Data Sheets-Entities';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Data Collection Entity";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control37002001)
            {
                ShowCaption = false;
                field(Include; Include)
                {
                    ApplicationArea = FOODBasic;
                    Editable = EditInclude;
                }
                field(EntityName; EntityName)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Entity';
                }
                field("Source Key 1"; "Source Key 1")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'No. / Code';
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    var
        DataSheetHeader: Record "Data Sheet Header";
    begin
        case DataSheetType of
            DataSheetHeader.Type::Shipping, DataSheetHeader.Type::Receiving:
                EditInclude := "Source ID" in [DATABASE::Item, DATABASE::Resource];
            DataSheetHeader.Type::Log:
                EditInclude := true
        end;
    end;

    var
        DataSheetType: Integer;
        [InDataSet]
        EditInclude: Boolean;

    procedure SetSourceTable(SheetType: Integer; var TempEntity: Record "Data Collection Entity")
    begin
        DataSheetType := SheetType;
        Rec.Copy(TempEntity, true);
    end;

    procedure GetSourceTable(var TempEntity: Record "Data Collection Entity")
    begin
        TempEntity.Copy(Rec, true);
    end;
}

