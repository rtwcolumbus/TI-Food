page 37002109 "Order Receiving-Purch. Subform"
{
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Purchase order subform for recording receipts from order receiving
    // 
    // PRW15.00.03
    // P8000624A, VerticalSoft, Jack Reynolds, 19 AUG 08
    //   Add controls for country/region of origin
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
    // P8001050, Columbus IT, Jack Reynolds, 30 MAR 12
    //   Enter Q/C results from Purchase Order Lines
    // 
    // P8001106, Columbus IT, Don Bresee, 16 OCT 12
    //   Add "Supplier Lot No." field for easy lot tracking
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.10.03
    // P8001313, Columbus IT, Jack Reynolds, 23 APR 14
    //   Fix problem processing backordefrs
    // 
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // P8008351, To-Increase, Jack Reynolds, 26 JAN 17
    //   Support for Lot Creation Date and Country of Origin for multiple lots

    Caption = 'Lines';
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
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Receiving Reason Code"; "Receiving Reason Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Farm; Farm)
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Brand; Brand)
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Country/Region of Origin Code"; "Country/Region of Origin Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Lot No.Editable";
                    Visible = false;

                    trigger OnValidate()
                    begin
                        // P8008351
                        if "Line No." = 0 then begin
                            CurrPage.SaveRecord;
                            UpdateLotTracking(false);
                        end;
                    end;
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
                field("Quantity Received"; "Quantity Received")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field("Qty. Received (Alt.)"; "Qty. Received (Alt.)")
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
                field("Supplier Lot No."; "Supplier Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Lot No.Editable";

                    trigger OnValidate()
                    begin
                        // P8001106
                        if "Line No." = 0 then begin
                            CurrPage.SaveRecord;
                            UpdateLotTracking(false);
                        end;
                    end;
                }
                field("Creation Date"; "Creation Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Lot No.Editable";

                    trigger OnValidate()
                    begin
                        // P8008351
                        if "Line No." = 0 then begin
                            CurrPage.SaveRecord;
                            UpdateLotTracking(false);
                        end;
                    end;
                }
                field("Qty. to Receive"; "Qty. to Receive")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        CurrPage.Update; // P8001313
                    end;
                }
                field("Over-Receipt Quantity"; "Over-Receipt Quantity")
                {
                    ApplicationArea = FOODBasic;
                    Visible = OverReceiptAllowed;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Over-Receipt Code"; "Over-Receipt Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = OverReceiptAllowed;
                }
                field("Qty. to Receive (Alt.)"; "Qty. to Receive (Alt.)")
                {
                    ApplicationArea = FOODBasic;

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
                action("&Quality Control")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Quality Control';
                    Image = CheckRulesSyntax;

                    trigger OnAction()
                    var
                        P800QCFns: Codeunit "Process 800 Q/C Functions";
                    begin
                        // P8001050
                        P800QCFns.QCForPurchLine(Rec);
                    end;
                }
                action("E&xtra Charges")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'E&xtra Charges';
                    Image = Costs;

                    trigger OnAction()
                    begin
                        ShowExtraCharges; // P8000862
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

    trigger OnOpenPage()
    var
        OverReceiptMgt: Codeunit "Over-Receipt Mgt.";
    begin
        OverReceiptAllowed := OverReceiptMgt.IsOverReceiptAllowed();
    end;

    var
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        ProcessFns: Codeunit "Process 800 Functions";
        ExtraChargeMgmt: Codeunit "Extra Charge Management";
        EasyLotTracking: Codeunit "Easy Lot Tracking";
        AllergenManagement: Codeunit "Allergen Management";
        [InDataSet]
        "Lot No.Editable": Boolean;
        OverReceiptAllowed: Boolean;

    procedure ShowDimensions()
    begin
        Rec.ShowDimensions;
    end;

    procedure OpenItemTrackingLines()
    begin
        CurrPage.SaveRecord;
        Rec.OpenItemTrackingLines;
    end;

    procedure ShowExtraCharges()
    begin
        Rec.ShowExtraCharges;
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

