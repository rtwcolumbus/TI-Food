page 37002850 "Asset Usage FactBox"
{
    // PRW16.00.20
    // P8000671, VerticalSoft, Jack Reynolds, 04 FEB 09
    //   Standard fact box for asset usage

    Caption = 'Asset Usage';
    PageType = CardPart;
    SourceTable = Asset;

    layout
    {
        area(content)
        {
            field("No."; "No.")
            {
                ApplicationArea = FOODBasic;

                trigger OnDrillDown()
                begin
                    ShowDetails;
                end;
            }
            field("Usage Unit of Measure"; "Usage Unit of Measure")
            {
                ApplicationArea = FOODBasic;
            }
            field("Usage Reading Frequency"; "Usage Reading Frequency")
            {
                ApplicationArea = FOODBasic;
            }
            field(LastUsageDate; LastUsageDate)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Last Usage Date';
                HideValue = HideUsageData;
            }
            field(LastUsage; LastUsage)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Last Usage';
                DecimalPlaces = 0 : 5;
                HideValue = HideUsageData;
            }
            field(AvgDailyUsage; AvgDailyUsage)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Average Daily Usage';
                DecimalPlaces = 0 : 5;
                HideValue = HideUsageData;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        GetLastUsage(LastUsageDate, LastUsage, AvgDailyUsage);
        HideUsageData := "Usage Unit of Measure" = '';
    end;

    var
        LastUsageDate: Date;
        LastUsage: Decimal;
        AvgDailyUsage: Decimal;
        [InDataSet]
        HideUsageData: Boolean;

    procedure ShowDetails()
    begin
        PAGE.Run(PAGE::"Asset Card", Rec);
    end;
}

