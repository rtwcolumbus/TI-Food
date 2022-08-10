page 37002767 "Whse. Staged Pick Source Line"
{
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 15 SEP 06
    //   Staged Picks
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens

    Caption = 'Whse. Staged Pick Source Line';
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Whse. Staged Pick Source Line";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Source Document"; "Source Document")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = FOODBasic;
                    Lookup = false;

                    trigger OnAssistEdit()
                    begin
                        ShowSourceDocument;
                    end;
                }
                field("Source Line No."; "Source Line No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Source Subline No."; "Source Subline No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(Allergens; AllergenManagement.AllergenCodeForRecord(0, 0, "Item No."))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Allergens';
                    Style = StrongAccent;
                    StyleExpr = TRUE;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        // P8006959
                        AllergenManagement.AllergenDrilldownForRecord(0, 0, "Item No.");
                    end;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
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
                    Visible = true;
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
                    Editable = false;
                }
                field("Qty. per Unit of Measure"; "Qty. per Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Pick Qty."; "Pick Qty.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Pick Qty. (Base)"; "Pick Qty. (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    var
        AllergenManagement: Codeunit "Allergen Management";

    procedure PickCreate(WhseStagedPickHeader: Record "Whse. Staged Pick Header")
    var
        WhseStagedPickSourceLine: Record "Whse. Staged Pick Source Line";
    begin
        WhseStagedPickHeader.Get("No.");
        WhseStagedPickSourceLine.Copy(Rec);
        CreatePickDoc(WhseStagedPickSourceLine, WhseStagedPickHeader);
    end;
}

