page 37002507 "Equipment Board Drilldown"
{
    // PR4.00
    // P8000197A, Myers Nissi, Jack Reynolds, 22 SEP 05
    //   List style form is used to show the equipment availability drill down from the prodction planning board
    // 
    // PRW16.00.03
    // P8000789, VerticalSoft, Rick Tweedle, 17 MAR 10
    //   Transformed using TIF editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Equipment Board Drilldown';
    DataCaptionExpression = CaptionText;
    Editable = false;
    PageType = ListPart;
    SourceTable = "Equipment Board";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field(Description; StrSubstNo('%1 %2', "Data Element", "Date Text"))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Description';
                }
                field(Quantity; EquipBoardMgt.FormatDuration(Quantity))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Quantity';

                    trigger OnDrillDown()
                    var
                        EquipBoardDrillDown: Record "Equipment Board" temporary;
                    begin
                        EquipBoard.Copy(Rec);
                        EquipBoard.SetProdPlanChange(ProdPlanChange);
                        EquipBoard.DrillDown(Date);
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        EquipBoard.Copy(Rec);
        if not EquipBoard.Find(Which) then
            exit(false);
        Rec := EquipBoard;
        exit(true);
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        CurrentSteps: Integer;
    begin
        EquipBoard.Copy(Rec);
        CurrentSteps := EquipBoard.Next(Steps);
        if CurrentSteps <> 0 then
            Rec := EquipBoard;
        exit(CurrentSteps);
    end;

    var
        Date: Record Date;
        EquipBoard: Record "Equipment Board" temporary;
        ProdPlanChange: Record "Daily Prod. Planning-Change" temporary;
        EquipBoardMgt: Codeunit "Equipment Board Management";
        CaptionText: Text[50];

    procedure SetParameters(var Dt: Record Date; var EqBoard: Record "Equipment Board" temporary)
    begin
        CaptionText := StrSubstNo('%1 %2', EqBoard."Data Element", EqBoard."Date Text");
        Date.Copy(Dt);
        EqBoard.Mark(true);
        EqBoard.Find('-');
        repeat
            if not EqBoard.Mark then begin
                EquipBoard := EqBoard;
                EquipBoard.Insert;
            end;
        until EqBoard.Next = 0;
    end;

    procedure DisplayColor(): Integer
    begin
        if "Includes Production Changes" then
            exit(255);
    end;

    procedure SetProdPlanChange(var PPchange: Record "Daily Prod. Planning-Change" temporary)
    begin
        ProdPlanChange.Reset;
        ProdPlanChange.DeleteAll;
        if PPchange.Find('-') then
            repeat
                ProdPlanChange := PPchange;
                ProdPlanChange.Insert;
            until PPchange.Next = 0;
    end;
}

