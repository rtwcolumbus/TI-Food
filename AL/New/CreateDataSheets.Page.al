page 37002874 "Create Data Sheets"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection

    Caption = 'Create Data Sheets';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = "Data Collection Entity";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Include; Include)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Data Sheet No."; "Data Sheet No.")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            part(Entities; "Create Data Sheets-Entities")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Entities';
                SubPageLink = "Location Code" = FIELD("Location Code");
                Visible = ShowEntity;
            }
            part(Lines; "Create Data Sheets-Lines")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lines';
                SubPageLink = "Location Code" = FIELD("Location Code");
                Visible = NOT ShowEntity;
            }
        }
    }

    actions
    {
    }

    var
        [InDataSet]
        ShowEntity: Boolean;

    procedure SetData(SheetType: Integer; var TempLocation: Record "Data Collection Entity" temporary; var TempEntityLine: Record "Data Collection Entity" temporary)
    var
        DataSheetHeader: Record "Data Sheet Header";
    begin
        Rec.Copy(TempLocation, true);
        FindFirst;
        ShowEntity := SheetType <> DataSheetHeader.Type::Production;
        if ShowEntity then
            CurrPage.Entities.PAGE.SetSourceTable(SheetType, TempEntityLine)
        else
            CurrPage.Lines.PAGE.SetSourceTable(TempEntityLine);
    end;

    procedure GetData(var TempLocation: Record "Data Collection Entity" temporary; var TempEntityLine: Record "Data Collection Entity" temporary)
    begin
        TempLocation.Copy(Rec, true);
        if ShowEntity then
            CurrPage.Entities.PAGE.GetSourceTable(TempEntityLine)
        else
            CurrPage.Lines.PAGE.GetSourceTable(TempEntityLine);
    end;
}

