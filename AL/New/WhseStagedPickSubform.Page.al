page 37002764 "Whse. Staged Pick Subform"
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

    Caption = 'Whse. Staged Pick Subform';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Whse. Staged Pick Line";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        ItemNoOnAfterValidate;
                    end;
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
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        UnitofMeasureCodeOnAfterValida;
                    end;
                }
                field("Qty. per Unit of Measure"; "Qty. per Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Qty. to Stage"; "Qty. to Stage")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        QtytoStageOnAfterValidate;
                    end;
                }
                field("Qty. to Stage (Base)"; "Qty. to Stage (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Order Qty. (Base)"; "Order Qty. (Base)")
                {
                    ApplicationArea = FOODBasic;
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
                field("Pick to Stage Qty."; "Pick to Stage Qty.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Pick to Stage Qty. (Base)"; "Pick to Stage Qty. (Base)")
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
                field("Pick from Stage Qty. (Base)"; "Pick from Stage Qty. (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Qty. Picked from Stage (Base)"; "Qty. Picked from Stage (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        DueDateOnAfterValidate;
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Item")
            {
                Caption = '&Item';
                action("Bin Contents List")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Bin Contents List';

                    trigger OnAction()
                    begin
                        //This functionality was copied from page #37002763. Unsupported part was commented. Please check it.
                        /*CurrPage.WhseStagedPickLines.PAGE.*/
                        _ShowBinContents;

                    end;
                }
                action("Item &Tracking Lines")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item &Tracking Lines';
                    Image = ItemTrackingLines;

                    trigger OnAction()
                    begin
                        //This functionality was copied from page #37002763. Unsupported part was commented. Please check it.
                        /*CurrPage.WhseStagedPickLines.PAGE.*/
                        _OpenItemTrackingLines;

                    end;
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetUpNewLine(xRec);
    end;

    var
        SortMethod: Option " ",Item,,"Due Date";
        WhseStagedPickHeader: Record "Whse. Staged Pick Header";
        WhseStagedPickMgmt: Codeunit "Whse. Staged Pick Mgmt.";
        AllergenManagement: Codeunit "Allergen Management";

    procedure _ShowBinContents()
    var
        BinContent: Record "Bin Content";
    begin
        BinContent.ShowBinContents("Location Code", "Item No.", "Variant Code", '');
    end;

    procedure ShowBinContents()
    var
        BinContent: Record "Bin Content";
    begin
        BinContent.ShowBinContents("Location Code", "Item No.", "Variant Code", '');
    end;

    procedure PickCreate(WhseStagedPickHeader: Record "Whse. Staged Pick Header")
    var
        WhseStagedPickLine: Record "Whse. Staged Pick Line";
    begin
        WhseStagedPickHeader.Get("No.");
        WhseStagedPickLine.Copy(Rec);
        CreatePickDoc(WhseStagedPickLine, WhseStagedPickHeader);
    end;

    procedure _OpenItemTrackingLines()
    begin
        Rec.OpenItemTrackingLines;
    end;

    procedure OpenItemTrackingLines()
    begin
        Rec.OpenItemTrackingLines;
    end;

    procedure GetActualSortMethod(): Decimal
    var
        WhseStagedPickHeader: Record "Whse. Staged Pick Header";
    begin
        if WhseStagedPickHeader.Get("No.") then
            exit(WhseStagedPickHeader."Sorting Method");
        exit(0);
    end;

    local procedure ItemNoOnAfterValidate()
    begin
        if GetActualSortMethod = SortMethod::Item then
            CurrPage.Update;
    end;

    local procedure UnitofMeasureCodeOnAfterValida()
    begin
        CurrPage.SaveRecord;
    end;

    local procedure QtytoStageOnAfterValidate()
    begin
        CurrPage.Update;
    end;

    local procedure DueDateOnAfterValidate()
    begin
        if GetActualSortMethod = SortMethod::"Due Date" then
            CurrPage.Update;
    end;
}

