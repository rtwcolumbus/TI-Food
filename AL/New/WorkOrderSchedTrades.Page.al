page 37002845 "Work Order Sched. Trades"
{
    // PRW16.00.20
    // P8000671, VerticalSoft, Jack Reynolds, 18 FEB 09
    //   Re-done to avoid matrix box
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Work Order Sched. Trades';
    Editable = false;
    DeleteAllowed = false; // P800-MegaApp
    InsertAllowed = false; // P800-MegaApp
    PageType = ListPart;
    SourceTable = "Maintenance Trade";

    layout
    {
        area(content)
        {
            repeater(Control37002001)
            {
                FreezeColumn = Description;
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("HoursRemaining(0)"; HoursRemaining(0))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = DateText(0);
                    DecimalPlaces = 0 : 2;
                    HideValue = MaxColumn <= 0;

                    trigger OnDrillDown()
                    begin
                        DrillDown(0);
                    end;
                }
                field("HoursRemaining(1)"; HoursRemaining(1))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = DateText(1);
                    DecimalPlaces = 0 : 2;
                    HideValue = MaxColumn <= 1;

                    trigger OnDrillDown()
                    begin
                        DrillDown(1);
                    end;
                }
                field("HoursRemaining(2)"; HoursRemaining(2))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = DateText(2);
                    DecimalPlaces = 0 : 2;
                    HideValue = MaxColumn <= 2;

                    trigger OnDrillDown()
                    begin
                        DrillDown(2);
                    end;
                }
                field("HoursRemaining(3)"; HoursRemaining(3))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = DateText(3);
                    DecimalPlaces = 0 : 2;
                    HideValue = MaxColumn <= 3;

                    trigger OnDrillDown()
                    begin
                        DrillDown(3);
                    end;
                }
                field("HoursRemaining(4)"; HoursRemaining(4))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = DateText(4);
                    DecimalPlaces = 0 : 2;
                    HideValue = MaxColumn <= 4;

                    trigger OnDrillDown()
                    begin
                        DrillDown(4);
                    end;
                }
                field("HoursRemaining(5)"; HoursRemaining(5))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = DateText(5);
                    DecimalPlaces = 0 : 2;
                    HideValue = MaxColumn <= 5;

                    trigger OnDrillDown()
                    begin
                        DrillDown(5);
                    end;
                }
                field("HoursRemaining(6)"; HoursRemaining(6))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = DateText(6);
                    DecimalPlaces = 0 : 2;
                    HideValue = MaxColumn <= 6;

                    trigger OnDrillDown()
                    begin
                        DrillDown(6);
                    end;
                }
            }
        }
    }

    actions
    {
    }

    var
        BaseDate: Date;
        Text001: Label '<Weekday Text,3>, <Month>/<Day>';
        ColumnOffset: Integer;
        [InDataSet]
        MaxColumn: Integer;
        LocationFilter: Text[250];

    procedure SetDateRange(Date: Date; DaysView: Integer; var ColOffset: Integer; var MaxOffset: Integer)
    begin
        BaseDate := Date;
        ColumnOffset := 0;
        if DaysView <= 7 then
            MaxColumn := DaysView
        else
            MaxColumn := 7;

        ColOffset := ColumnOffset;
        MaxOffset := DaysView - 7;

        CurrPage.Update(false);
    end;

    procedure SetOffset(ColOffset: Integer)
    begin
        ColumnOffset := ColOffset;

        CurrPage.Update(false);
    end;

    procedure SetLocationFilter(LocFilter: Text[250])
    begin
        LocationFilter := LocFilter;
        CurrPage.Update(false);
    end;

    procedure DateText(Offset: Integer): Text[30]
    begin
        if Offset < MaxColumn then
            exit(UpperCase(Format(BaseDate + ColumnOffset + Offset, 0, Text001)))
        else
            exit(' ');
    end;

    procedure HoursRemaining(Offset: Integer): Decimal
    begin
        if Offset < MaxColumn then begin
            SetFilter("Location Filter", LocationFilter);
            SetRange("Date Filter", BaseDate + ColumnOffset + Offset);
            CalcFields("Remaining Labor Hours");
            exit("Remaining Labor Hours");
        end else
            exit(0);
    end;

    procedure DrillDown(Offset: Integer)
    var
        WOActivity: Record "Work Order Activity";
        WOActivities: Page "Work Order Activities";
    begin
        if Offset < MaxColumn then begin
            WOActivity.SetCurrentKey(Type, "Trade Code", "Location Code", Completed, "Required Date");
            WOActivity.SetRange(Type, WOActivity.Type::Labor);
            WOActivity.SetRange("Trade Code", Code);
            WOActivity.SetFilter("Location Code", LocationFilter);
            WOActivity.SetRange(Completed, false);
            WOActivity.SetRange("Required Date", BaseDate + ColumnOffset + Offset);
            WOActivities.SetTableView(WOActivity);
            WOActivities.Editable(false);
            WOActivities.RunModal;
        end;
    end;
}

