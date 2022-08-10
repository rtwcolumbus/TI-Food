page 37002896 "Data Sheet Lines-Production"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection

    Caption = 'Data Sheet Lines-Production';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Data Sheet Line";
    SourceTableView = WHERE("Hide Line" = CONST(false));

    layout
    {
        area(content)
        {
            repeater(Control37002001)
            {
                IndentationColumn = Indent;
                IndentationControls = Description;
                ShowAsTree = true;
                ShowCaption = false;
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Data Element Code"; "Data Element Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Data Element Type"; "Data Element Type")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = LineLevel;
                }
                field("Schedule Date"; "Schedule Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Schedule Time"; "Schedule Time")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Result; Result)
                {
                    ApplicationArea = FOODBasic;
                    Editable = AllowEdits;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        DataCollectionMgmt: Codeunit "Data Collection Management";
                    begin
                        if "Data Element Type" <> "Data Element Type"::"Lookup" then
                            exit(false);
                        exit(DataCollectionMgmt.DataElementLookup("Data Element Code", Text))
                    end;
                }
                field("Actual Date"; "Actual Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = AllowEdits;
                }
                field("Actual Time"; "Actual Time")
                {
                    ApplicationArea = FOODBasic;
                    Editable = AllowEdits;
                }
                field(Recurrence; Recurrence)
                {
                    ApplicationArea = FOODBasic;
                    HideValue = LineLevel;
                    Visible = false;
                }
                field(Frequency; Frequency)
                {
                    ApplicationArea = FOODBasic;
                    HideValue = LineLevel;
                    Visible = false;
                }
                field("Scheduled Type"; "Scheduled Type")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = LineLevel;
                    Visible = false;
                }
                field("Schedule Base"; "Schedule Base")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = LineLevel;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Start)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Start Production Order Line';
                Enabled = StartEnabled;
                Image = Start;

                trigger OnAction()
                begin
                    if DataCollectionMgmt.ProdOrderLineStartStop(Rec) then begin
                        Clear(DataSheetOrderLine);
                        CurrPage.Update;
                    end;
                end;
            }
            action(Stop)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Stop Production Order Line';
                Enabled = StopEnabled;
                Image = Cancel;

                trigger OnAction()
                begin
                    if DataCollectionMgmt.ProdOrderLineStartStop(Rec) then begin
                        Clear(DataSheetOrderLine);
                        CurrPage.Update;
                    end;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        StartEnabled := false;
        StopEnabled := false;
        if "Data Element Code" = '' then begin
            Indent := 0;
            if ("Actual Date" <> 0D) and ("Stop Date" = 0D) then
                StopEnabled := true
            else
                if ("Prod. Order Line No." <> 0) and ("Stop Date" = 0D) then begin
                    GetSheetHeader;
                    StartEnabled := DataSheetHeader."Start Date" <> 0D;
                end;
        end else
            Indent := 1;

        LineLevel := Indent = 0;
        if ("Prod. Order Line No." <> 0) and ("Data Element Code" <> '') then begin
            GetOrderLine;
            AllowEdits := (DataSheetOrderLine."Actual DateTime" <> 0DT) and (DataSheetOrderLine."Stop DateTime" = 0DT);
        end else
            AllowEdits := not LineLevel;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        Modify(true);
        CurrPage.Update(false);
        exit(false);
    end;

    var
        DataSheetHeader: Record "Data Sheet Header";
        DataSheetOrderLine: Record "Data Sheet Line";
        DataCollectionMgmt: Codeunit "Data Collection Management";
        [InDataSet]
        Indent: Integer;
        [InDataSet]
        AllowEdits: Boolean;
        [InDataSet]
        StartEnabled: Boolean;
        [InDataSet]
        StopEnabled: Boolean;
        [InDataSet]
        LineLevel: Boolean;

    procedure GetSheetHeader()
    begin
        if DataSheetHeader."No." <> "Data Sheet No." then
            DataSheetHeader.Get("Data Sheet No.");
    end;

    procedure GetOrderLine()
    begin
        if (DataSheetOrderLine."Data Sheet No." <> "Data Sheet No.") or
          (DataSheetOrderLine."Prod. Order Line No." <> "Prod. Order Line No.")
        then
            DataSheetOrderLine.Get("Data Sheet No.", "Prod. Order Line No.", '', 0, 0);
    end;

    procedure ClearGlobals()
    begin
        Clear(DataSheetHeader);
        Clear(DataSheetOrderLine);
    end;
}

