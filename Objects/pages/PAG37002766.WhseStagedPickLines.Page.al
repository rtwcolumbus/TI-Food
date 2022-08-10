page 37002766 "Whse. Staged Pick Lines"
{
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 06 SEP 06
    //   Standard list style form for staged pick lines
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Whse. Staged Pick Lines';
    Editable = false;
    PageType = List;
    SourceTable = "Whse. Staged Pick Line";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Zone Code"; "Zone Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(GetSortSeqNo; GetSortSeqNo)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Sorting Sequence No.';
                    Visible = false;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Qty. to Stage"; "Qty. to Stage")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Qty. to Stage (Base)"; "Qty. to Stage (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Qty. Outstanding"; "Qty. Outstanding")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Qty. Outstanding (Base)"; "Qty. Outstanding (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Qty. Staged"; "Qty. Staged")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Qty. Staged (Base)"; "Qty. Staged (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Qty. per Unit of Measure"; "Qty. per Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                action("Show Whse. Document")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Show Whse. Document';
                    ShortCutKey = 'Shift+F7';

                    trigger OnAction()
                    var
                        WhseStagedPickHeader: Record "Whse. Staged Pick Header";
                    begin
                        WhseStagedPickHeader.Get("No.");
                        PAGE.Run(PAGE::"Whse. Staged Pick", WhseStagedPickHeader);
                    end;
                }
            }
        }
    }
}

