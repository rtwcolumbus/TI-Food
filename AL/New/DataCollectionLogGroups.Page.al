page 37002877 "Data Collection Log Groups"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Data Collection Log Groups';
    PageType = List;
    SourceTable = "Data Collection Log Group";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control37002005; Links)
            {
                ApplicationArea = FOODBasic;
            }
            systempart(Control37002006; Notes)
            {
                ApplicationArea = FOODBasic;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Data Sheets")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Data Sheets';
                Ellipsis = true;
                Image = EntriesList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    DataCollectionMgmt: Codeunit "Data Collection Management";
                begin
                    // P8001090
                    DataCollectionMgmt.DataSheetsForLogGroup(Rec);
                end;
            }
        }
    }
}

