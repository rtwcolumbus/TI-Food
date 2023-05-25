page 37002111 "Order Receiving-Sales Subform"
{
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Sales return order subform for recording receipts from order receiving
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 31 JUL 07
    //   Change call to UpdateLotTracking to pass ApplyFromEntryNo
    // 
    // PRW16.00.02
    // P8000777, VerticalSoft, Don Bresee, 24 FEB 10
    //   Changed EDITABLE so it could be handled by the form transformation tool
    // 
    // PRW16.00.03
    // P8000817, VerticalSoft, Jack Reynolds, 26 APR 10
    //   Change visible property of fields
    // 
    // PRW16.00.04
    // P8000862, VerticalSoft, Jack Reynolds, 25 AUG 10
    //   Restore Line actions
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 19 FEB 13
    //   Restoring the SaveValues Property.
    // 
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW121.2
    // P800163700, To-Increase, Jack Reynolds, 07 FEB 23
    //   Support for Auto-Save as You Work

    Caption = 'Lines';
    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SaveValues = true;
    SourceTable = "Sales Line";
    SourceTableView = WHERE("Outstanding Quantity" = FILTER(<> 0));

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(Allergens; AllergenManagement.AllergenCodeForRecord(DATABASE::"Sales Line", Type, "No."))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Allergens';
                    Style = StrongAccent;
                    StyleExpr = TRUE;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        // P8006959
                        AllergenManagement.AllergenDrilldownForRecord(DATABASE::"Sales Line", Type, "No.");
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field("Quantity (Alt.)"; "Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Return Qty. Received"; "Return Qty. Received")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field("Return Qty. Received (Alt.)"; "Return Qty. Received (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Outstanding Quantity"; "Outstanding Quantity")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Lot No.Editable";

                    trigger OnAssistEdit()
                    begin
                        if Type <> Type::Item then
                            exit;
                        CurrPage.SaveRecord;
                        Commit;
                        EasyLotTracking.SetSalesLine(Rec);
                        if EasyLotTracking.AssistEdit("Lot No.") then
                            UpdateLotTracking(true, 0); // P8000466A
                        CurrPage.SaveRecord
                    end;

                    trigger OnValidate()
                    begin
                        if "Line No." = 0 then begin
                            CurrPage.SaveRecord;
                            UpdateLotTracking(false, 0); // P8000466A
                        end;
                    end;
                }
                field("Return Qty. to Receive"; "Return Qty. to Receive")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Return Qty. to Receive (Alt.)"; "Return Qty. to Receive (Alt.)")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord;
                        AltQtyMgmt.ShowSalesAltQtyLines(Rec);
                        CurrPage.Update;
                    end;

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord;
                        AltQtyMgmt.ValidateSalesAltQtyLine(Rec);
                        CurrPage.Update;
                    end;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field("Job No."; "Job No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Gross Weight"; "Gross Weight")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field("Net Weight"; "Net Weight")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field("Units per Parcel"; "Units per Parcel")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field("Appl.-to Item Entry"; "Appl.-to Item Entry")
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
                action("Item &Tracking Lines")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item &Tracking Lines';
                    Image = ItemTrackingLines;
                    ShortCutKey = 'Shift+Ctrl+I';

                    trigger OnAction()
                    begin
                        OpenItemTrackingLines; // P8000862
                    end;
                }
                action(Dimensions)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        ShowDimensions; // P8000862
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        SetLotFields('EDITABLE');
    end;

    trigger OnInit()
    begin
        "Lot No.Editable" := true;
    end;

    var
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        EasyLotTracking: Codeunit "Easy Lot Tracking";
        AllergenManagement: Codeunit "Allergen Management";
        [InDataSet]
        "Lot No.Editable": Boolean;

    procedure ShowDimensions()
    begin
        Rec.ShowDimensions;
    end;

    procedure OpenItemTrackingLines()
    begin
        CurrPage.SaveRecord;
        Rec.OpenItemTrackingLines;
    end;

    procedure SetLotFields(Property: Code[10])
    var
        ProcessFns: Codeunit "Process 800 Functions";
        P800Globals: Codeunit "Process 800 System Globals";
    begin
        case Property of
            'EDITABLE':
                // CurrForm."Lot No.".EDITABLE( // P8000777
                "Lot No.Editable" :=  // P8000777
                  ProcessFns.TrackingInstalled and ("Lot No." <> P800Globals.MultipleLotCode) and (Type = Type::Item);
        end;
    end;

    procedure SetLocation(LocCode: Code[10])
    begin
        FilterGroup(4);
        SetRange("Location Code", LocCode);
        FilterGroup(0);
    end;
}

