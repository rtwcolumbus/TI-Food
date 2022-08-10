page 37002950 "Incident Table Filters"
{
    // PRW111.00.01
    // P80036649, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Incident/Complaint Registration

    Caption = 'Incident Table Filters';
    DataCaptionExpression = '';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPlus;
    SourceTable = "Incident Search Setup";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table No."; "Table No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Filters; Filters)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Filters';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        if OpenFilterSettings then begin
                            Filters := GetFiltersAsDisplayText;
                            CurrPage.Update;
                        end;
                    end;
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Add Table")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Add &Table';
                Image = ViewDetails;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Open the document, journal line, or entry that the incoming document is linked to.';

                trigger OnAction()
                var
                    AllObjWithCaption: Record AllObjWithCaption;
                begin
                    if PAGE.RunModal(PAGE::"Table Objects", AllObjWithCaption) = ACTION::LookupOK then begin
                        Init;
                        "Table No." := AllObjWithCaption."Object ID";
                        "Table Name" := AllObjWithCaption."Object Name";
                        if Insert then;
                    end;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Filters := GetFiltersAsDisplayText;
    end;

    trigger OnOpenPage()
    begin
        InitializebyTable;
    end;

    var
        Filters: Text;

    procedure InitializebyTable()
    var
        IncidentSearchSetup: Record "Incident Search Setup";
    begin
        GetSearchTableSetup(DATABASE::"Incident Comment Line");

        IncidentSearchSetup.Reset;
        if IncidentSearchSetup.FindFirst then
            repeat
                GetSearchTableSetup(IncidentSearchSetup."Table No.");
            until IncidentSearchSetup.Next = 0;
    end;

    procedure GetSearchTableSetup(TableNumber: Integer)
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, TableNumber) then begin
            if not Get(TableNumber, 0) then begin
                Init;
                "Table No." := TableNumber;
                "Table Name" := AllObjWithCaption."Object Name";
                Insert;
            end;
        end;
    end;

    procedure GetRecordFilters(var TempFilterRecords: Record "Incident Search Setup" temporary)
    begin
        TempFilterRecords.Reset;
        TempFilterRecords.DeleteAll;

        Reset;
        if FindFirst then
            repeat
                CalcFields("Apply to Table Filter");
                if "Apply to Table Filter".HasValue then begin
                    TempFilterRecords := Rec;
                    TempFilterRecords.Insert;
                end;
            until Next = 0;
    end;
}

