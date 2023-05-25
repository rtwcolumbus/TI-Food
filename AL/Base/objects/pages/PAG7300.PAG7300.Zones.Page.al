page 7300 Zones
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality

    Caption = 'Zones';
    DataCaptionFields = "Location Code";
    PageType = List;
    SourceTable = Zone;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the location code of the zone.';
                    Visible = false;
                }
                field("Code"; Code)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the code of the zone.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies a description of the zone.';
                }
                field("Bin Type Code"; Rec."Bin Type Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the bin type code for the zone. The bin type determines the inbound and outbound flow of items.';
                }
                field("Warehouse Class Code"; Rec."Warehouse Class Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the warehouse class code of the zone. You can store items with the same warehouse class code in this zone.';
                }
                field("Special Equipment Code"; Rec."Special Equipment Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the code of the special equipment to be used when you work in this zone.';
                }
                field("Zone Ranking"; Rec."Zone Ranking")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Zone Ranking';
                    ToolTip = 'Specifies the ranking of the zone, which is copied to all bins created within the zone.';
                }
                field("Cross-Dock Bin Zone"; Rec."Cross-Dock Bin Zone")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies if this is a cross-dock zone.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Zone")
            {
                Caption = '&Zone';
                Image = Zones;
                action("&Bins")
                {
                    ApplicationArea = Warehouse;
                    Caption = '&Bins';
                    Image = Bins;
                    RunObject = Page Bins;
                    RunPageLink = "Location Code" = FIELD("Location Code"),
                                  "Zone Code" = FIELD(Code);
                    ToolTip = 'View or edit information about zones that you use in your warehouse to hold items.';
                }
                action(DataCollectionLines)
                {
                    AccessByPermission = TableData "Data Collection Line" = R;
                    ApplicationArea = FOODBasic;
                    Caption = 'Data Collection Lines';
                    Image = EditLines;
                    RunObject = Page "Data Collection Lines";
                    RunPageLink = "Source ID" = CONST(7300),
                                  "Source Key 1" = FIELD("Location Code"),
                                  "Source Key 2" = FIELD(Code);
                }
            }
        }
    }
}

