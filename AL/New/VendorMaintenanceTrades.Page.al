page 37002815 "Vendor / Maintenance Trades"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   Standard lsit style form for vendor maintenance trades
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 09 AUG 07
    //   Expand result of GetCaption to TEXT80
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 30 JAN 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018

    Caption = 'Vendor / Maintenance Trades';
    DataCaptionExpression = ShowCaption;
    PageType = List;
    SourceTable = "Vendor / Maintenance Trade";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = VendorNoVisible;
                }
                field("Vendor Name"; "Vendor Name")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                    Visible = VendorNameVisible;
                }
                field("Trade Code"; "Trade Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = TradeCodeVisible;
                }
                field("Trade Description"; "Trade Description")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                    Visible = TradeDescriptionVisible;
                }
                field("Rate (Hourly)"; "Rate (Hourly)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Total Cost"; "Total Cost")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        TradeDescriptionVisible := true;
        TradeCodeVisible := true;
        VendorNameVisible := true;
        VendorNoVisible := true;
    end;

    trigger OnOpenPage()
    begin
        VendorNoVisible := GetFilter("Vendor No.") = '';
        VendorNameVisible := GetFilter("Vendor No.") = '';
        TradeCodeVisible := GetFilter("Trade Code") = '';
        TradeDescriptionVisible := GetFilter("Trade Code") = '';
    end;

    var
        [InDataSet]
        VendorNoVisible: Boolean;
        [InDataSet]
        VendorNameVisible: Boolean;
        [InDataSet]
        TradeCodeVisible: Boolean;
        [InDataSet]
        TradeDescriptionVisible: Boolean;

    procedure ShowCaption(): Text[80]
    var
        Vendor: Record Vendor;
        MaintTrade: Record "Maintenance Trade";
    begin
        if GetFilter("Vendor No.") <> '' then begin
            Vendor.Get(GetFilter("Vendor No."));
            exit(Vendor."No." + ' ' + Vendor.Name);
        end;
        if GetFilter("Trade Code") <> '' then begin
            MaintTrade.Get(GetFilter("Trade Code"));
            exit(MaintTrade.Code + ' ' + MaintTrade.Description);
        end;
    end;
}

