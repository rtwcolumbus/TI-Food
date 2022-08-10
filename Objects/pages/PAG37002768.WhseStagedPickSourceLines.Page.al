page 37002768 "Whse. Staged Pick Source Lines"
{
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 06 SEP 06
    //   Standard list style form for staged pick source lines
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Whse. Staged Pick Source Lines';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Whse. Staged Pick Source Line";

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
                field("Zone Code"; "Zone Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Bin Code"; "Bin Code")
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
                field("Source Document"; "Source Document")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source Line No."; "Source Line No.")
                {
                    ApplicationArea = FOODBasic;
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
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Qty. (Base)"; "Qty. (Base)")
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
                field("Qty. Picked"; "Qty. Picked")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Qty. Picked (Base)"; "Qty. Picked (Base)")
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
            }
        }
    }

    actions
    {
        area(processing)
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

