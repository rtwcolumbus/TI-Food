page 37002884 "Open Data Sheets"
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
    Caption = 'Open Data Sheets';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Data Sheet Header";
    SourceTableView = SORTING("Location Code", "Source ID", "Source Subtype", "Source No.")
                      WHERE(Status = FILTER(Pending | "In Progress"));
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Create Date"; "Create Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Reference Type"; "Reference Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Reference ID"; "Reference ID")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Start Date"; "Start Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Start Time"; "Start Time")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control37002014; Links)
            {
                ApplicationArea = FOODBasic;
            }
            systempart(Control37002015; Notes)
            {
                ApplicationArea = FOODBasic;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Data Sheet")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Data Sheet';
                Image = EntriesList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Return';

                trigger OnAction()
                var
                    DataSheet: Record "Data Sheet Header";
                begin
                    DataSheet.SetRange("No.", "No.");
                    if Type <> Type::Production then
                        PAGE.Run(PAGE::"Data Sheet", DataSheet)
                    else
                        PAGE.Run(PAGE::"Data Sheet-Production", DataSheet);
                end;
            }
        }
    }
}

