page 37002104 "Order Shipping-Purch. Subform"
{
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Purchase return order subform for recording shipments from order shipping
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
    // PRW19.00.01
    // P8007464, To-Increase, Dayakar Battini, 12 JUL 16
    //   Change Order Line feature added.
    // 
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // PRW121.2
    // P800163700, To-Increase, Jack Reynolds, 07 FEB 23
    //   Support for Auto-Save as You Work

    Caption = 'Lines';
    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Purchase Line";
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
                field(Allergens; AllergenManagement.AllergenCodeForRecord(DATABASE::"Purchase Line", Type, "No."))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Allergens';
                    Style = StrongAccent;
                    StyleExpr = TRUE;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        // P8006959
                        AllergenManagement.AllergenDrilldownForRecord(DATABASE::"Purchase Line", Type, "No.");
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
                field("Return Qty. Shipped"; "Return Qty. Shipped")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field("Return Qty. Shipped (Alt.)"; "Return Qty. Shipped (Alt.)")
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
                        EasyLotTracking.SetPurchaseLine(Rec);
                        if EasyLotTracking.AssistEdit("Lot No.") then
                            UpdateLotTracking(true);
                        CurrPage.SaveRecord;
                    end;

                    trigger OnValidate()
                    begin
                        if "Line No." = 0 then begin
                            CurrPage.SaveRecord;
                            UpdateLotTracking(false);
                        end;
                    end;
                }
                field("Return Qty. to Ship"; "Return Qty. to Ship")
                {
                    ApplicationArea = FOODBasic;
                    Editable = FormEditable;
                }
                field("Return Qty. to Ship (Alt.)"; "Return Qty. to Ship (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    Editable = FormEditable;

                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord;
                        AltQtyMgmt.ShowPurchAltQtyLines(Rec);
                        CurrPage.Update;
                    end;

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord;
                        AltQtyMgmt.ValidatePurchAltQtyLine(Rec);
                        CurrPage.Update;
                    end;
                }
                field("Unit Cost"; "Unit Cost")
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
                    Editable = FormEditable;
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
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Change Purchase Order Line")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Change Purchase Order Line';
                    Description = 'N138F0000';

                    trigger OnAction()
                    var
                        ChangeSourceLineWizard: Page "N138 ChangeSource Line Wizard";
                    begin
                        //ChangeQty;
                        ChangeSourceLineWizard.Init("No.", Quantity, 0, Rec, 0); // P8007464
                        ChangeSourceLineWizard.RunModal;
                    end;
                }
            }
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
                action("Co&ntainers")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&ntainers';
                    Image = Inventory;
                    ShortCutKey = 'Ctrl+F7';

                    trigger OnAction()
                    begin
                        // P8001373
                        ContainerSpecification;
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
        FormEditable := true;
    end;

    var
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        ProcessFns: Codeunit "Process 800 Functions";
        EasyLotTracking: Codeunit "Easy Lot Tracking";
        AllergenManagement: Codeunit "Allergen Management";
        [InDataSet]
        "Lot No.Editable": Boolean;
        [InDataSet]
        FormEditable: Boolean;

    procedure ShowDimensions()
    begin
        Rec.ShowDimensions;
    end;

    procedure OpenItemTrackingLines()
    begin
        CurrPage.SaveRecord;
        OpenItemTrackingLines;
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
                  FormEditable and ProcessFns.TrackingInstalled and
                  ("Lot No." <> P800Globals.MultipleLotCode) and (Type = Type::Item);
        end;
    end;

    procedure SetLocation(LocCode: Code[10])
    begin
        FilterGroup(4);
        SetRange("Location Code", LocCode);
        FilterGroup(0);
    end;

    procedure SetFormEditable(NewFormEditable: Boolean)
    begin
        FormEditable := NewFormEditable;
    end;
}

