page 37002911 "Data Collection History"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names

    Caption = 'Data Collection History';
    Editable = false;
    PageType = List;
    SourceTable = "Data Sheet Line Detail";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Data Sheet No."; "Data Sheet No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("DataSheetHeader.Description"; DataSheetHeader.Description)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Description';
                }
                field("DataSheetHeader.""Location Code"""; DataSheetHeader."Location Code")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Location Code';
                }
                field("Prod. Order Line No."; "Prod. Order Line No.")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                }
                field("Instance No."; "Instance No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("DataSheetLine.Result"; DataSheetLine.Result)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Result';
                }
                field("DataSheetLine.""Actual Date"""; DataSheetLine."Actual Date")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Date';
                }
                field("DataSheetLine.""Actual Time"""; DataSheetLine."Actual Time")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Time';
                }
                field("(""Alert Entry No. (Target)"" <> 0) OR (""Alert Entry No. (Missed)"" <> 0)"; ("Alert Entry No. (Target)" <> 0) or ("Alert Entry No. (Missed)" <> 0))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Alerts';
                }
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
                    DataSheet.SetRange("No.", "Data Sheet No.");
                    if Type <> Type::Production then
                        PAGE.Run(PAGE::"Data Sheet", DataSheet)
                    else
                        PAGE.Run(PAGE::"Data Sheet-Production", DataSheet);
                end;
            }
            action(Alerts)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Alerts';
                Image = Alerts;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Data Collection Alerts";
                RunPageLink = "Data Sheet No." = FIELD("Data Sheet No."),
                              "Prod. Order Line No." = FIELD("Prod. Order Line No."),
                              "Data Element Code" = FIELD("Data Element Code"),
                              "Line No." = FIELD("Line No."),
                              "Source ID" = FIELD("Source ID"),
                              "Source Key 1" = FIELD("Source Key 1"),
                              "Source Key 2" = FIELD("Source Key 2"),
                              "Instance No." = FIELD("Instance No.");
                RunPageView = SORTING("Data Sheet No.", "Prod. Order Line No.", "Data Element Code", "Line No.", "Source ID", "Source Key 1", "Source Key 2", "Instance No.");
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        DataSheetHeader.Get("Data Sheet No.");
        DataSheetLine.Get("Data Sheet No.", "Prod. Order Line No.", "Data Element Code", "Line No.", "Instance No.");
    end;

    var
        DataSheetHeader: Record "Data Sheet Header";
        DataSheetLine: Record "Data Sheet Line";
}

