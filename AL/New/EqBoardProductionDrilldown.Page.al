page 37002509 "Eq. Board Production Drilldown"
{
    // PRW16.00.03
    // P8000789, VerticalSoft, Rick Tweedle, 09 APR 10
    //   Created page - based upon form version
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Eq. Board Production Drilldown';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Eq. Board Production Drilldown";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Prod. Order Status"; "Prod. Order Status")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Prod Order No."; "Prod Order No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Location; Location)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Equipment Code"; "Equipment Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Date; Date)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Starting Time"; "Starting Time")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Ending Time"; "Ending Time")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Duration; Duration)
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
    begin
        colourFlag := Change;
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        ProdDrillDown.Copy(Rec);
        if not ProdDrillDown.Find(Which) then
            exit(false);
        Rec.Copy(ProdDrillDown);
        exit(true);
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        currentSteps: Integer;
    begin
        ProdDrillDown.Copy(Rec);
        currentSteps := ProdDrillDown.Next(Steps);
        if currentSteps <> 0 then
            Rec.Copy(ProdDrillDown);
        exit(currentSteps);
    end;

    var
        ProdDrillDown: Record "Eq. Board Production Drilldown" temporary;
        EqBoardMgt: Codeunit "Equipment Board Management";
        CaptionText: Text[50];
        [InDataSet]
        colourFlag: Boolean;

    procedure SetVariables(EqCode: Code[20]; DateText: Text[30]; var ProdDD: Record "Eq. Board Production Drilldown" temporary)
    var
        Resource: Record Resource;
    begin
        CaptionText := EqCode + ' ' + DateText;

        ProdDrillDown.Reset;
        ProdDrillDown.DeleteAll;
        if ProdDD.Find('-') then
            repeat
                ProdDrillDown := ProdDD;
                ProdDrillDown.Insert;
            until ProdDD.Next = 0;
    end;
}

