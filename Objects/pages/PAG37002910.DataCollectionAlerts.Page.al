page 37002910 "Data Collection Alerts"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names

    Caption = 'Data Collection Alerts';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Data Collection Alert";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Data Sheet No."; "Data Sheet No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("DataSheetHeader.Description"; DataSheetHeader.Description)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Data Sheet';
                }
                field("DataSheetHeader.""Location Code"""; DataSheetHeader."Location Code")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Location Code';
                }
                field("Alert Type"; "Alert Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Critical; Critical)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Elevated; Elevated)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Data Element Code"; "Data Element Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Origination Date"; "Origination Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Origination Time"; "Origination Time")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            part(Detail; "Data Collection Alert Detail")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Detail';
                SubPageLink = "Entry No." = FIELD("Entry No.");
            }
            systempart(Control37002009; Links)
            {
                ApplicationArea = FOODBasic;
            }
            systempart(Control37002010; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Card)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Card';
                Image = Card;
                RunObject = Page "Data Collection Alert";
                RunPageLink = "Entry No." = FIELD("Entry No.");
                ShortCutKey = 'Return';
                Visible = false;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        DataSheetHeader.Get("Data Sheet No.");
        DataSheetLine.Get("Data Sheet No.", "Prod. Order Line No.", "Data Element Code", "Line No.", "Instance No.");
        DataSheetLineDetail.Get("Data Sheet No.", "Prod. Order Line No.", "Data Element Code", "Line No.",
          "Source ID", "Source Key 1", "Source Key 2", "Instance No.");
    end;

    var
        DataSheetHeader: Record "Data Sheet Header";
        DataSheetLine: Record "Data Sheet Line";
        DataSheetLineDetail: Record "Data Sheet Line Detail";
}

