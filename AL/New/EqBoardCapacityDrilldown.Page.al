page 37002508 "Eq. Board Capacity Drilldown"
{
    // PRW16.00.03
    // P8000789, VerticalSoft, Rick Tweedle, 09 APR 10
    //   Created page - based upon form version
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013

    Caption = 'Eq. Board Capacity Drilldown';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Production Time by Date";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;
                field(Date; Date)
                {
                    ApplicationArea = FOODBasic;
                    Style = Attention;
                    StyleExpr = NonWorking;
                }
                field(fld_Capacity; EquipBoardMgt.FormatDuration("Time Required"))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Capacity';
                    Style = Attention;
                    StyleExpr = NonWorking;
                }
                field(fld_NonWorking; NonWorking)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Non Working';
                    Style = Attention;
                    StyleExpr = NonWorking;
                }
                field(fld_Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Description';
                    Style = Attention;
                    StyleExpr = NonWorking;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        NonWorking := not P800CalMgt.CheckCalendar(Date, Description);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        EquipCapacity.Copy(Rec);
        if not EquipCapacity.Find(Which) then
            exit(false);
        Rec.Copy(EquipCapacity);
        exit(true);
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        currentSteps: Integer;
    begin
        EquipCapacity.Copy(Rec);
        currentSteps := EquipCapacity.Next(Steps);
        if currentSteps <> 0 then
            Rec.Copy(EquipCapacity);
        exit(currentSteps);
    end;

    var
        EquipCapacity: Record "Production Time by Date" temporary;
        P800CalMgt: Codeunit "Process 800 Calendar Mngt.";
        EquipBoardMgt: Codeunit "Equipment Board Management";
        CaptionText: Text[50];
        [InDataSet]
        NonWorking: Boolean;
        Description: Text[30];

    procedure SetVariables(EqCode: Code[20]; DateText: Text[30]; var EqCap: Record "Production Time by Date" temporary)
    var
        Resource: Record Resource;
    begin
        CaptionText := EqCode + ' ' + DateText;

        if Resource.Get(EqCode) then;
        P800CalMgt.GetLocation(Resource."Location Code");

        EquipCapacity.Reset;
        EquipCapacity.DeleteAll;
        if EqCap.Find('-') then
            repeat
                EquipCapacity := EqCap;
                EquipCapacity.Insert;
            until EqCap.Next = 0;
    end;
}

