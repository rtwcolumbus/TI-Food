page 37002674 "Truckload Recv. Lines Subform"
{
    // PR3.70.01
    //   Add controls for receiving reason code, farm, brand
    //   Add function to show dimensions
    //   Extra Charges
    // 
    // PR3.70.04
    // P8000043A, Myers Nissi, Jack Reynolds, 26 MAY 04
    //    Support for easy lot tracking
    // 
    // PR3.70.05
    // P8000071A, Myers Nissi, Jack Reynolds, 15 JUL 04
    //   Modify to not allow easy lot tracking unless line is for an item
    // 
    // PRW15.00.03
    // P8000624A, VerticalSoft, Jack Reynolds, 19 AUG 08
    //   Add controls for country/region of origin
    // 
    // PRW16.00.03
    // P8000817, VerticalSoft, Jack Reynolds, 26 APR 10
    //   Change visible property of fields
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.10.03
    // P8001334, Columbus IT, Jack Reynolds, 03 JUL 14
    //   Add image for Extra Charge action
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality

    Caption = 'Truckload Recv. Lines Subform';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Purchase Line";
    SourceTableView = WHERE("Outstanding Quantity" = FILTER(<> 0));

    layout
    {
        area(content)
        {
            repeater(Control37002001)
            {
                ShowCaption = false;
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
                    Visible = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Lot No.Editable";

                    trigger OnAssistEdit()
                    begin
                        // P8000043A
                        if Type <> Type::Item then // P8000071A
                            exit;                    // P8000071A
                        EasyLotTracking.SetPurchaseLine(Rec);
                        if EasyLotTracking.AssistEdit("Lot No.") then
                            UpdateLotTracking(true);
                        CurrPage.SaveRecord;
                    end;
                }
                field("Quantity Received"; "Quantity Received")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field("Outstanding Quantity"; "Outstanding Quantity")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Qty. to Receive"; "Qty. to Receive")
                {
                    ApplicationArea = FOODBasic;
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
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Bin Code"; "Bin Code")
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

                    trigger OnAction()
                    begin
                        //This functionality was copied from page #37002673. Unsupported part was commented. Please check it.
                        /*CurrPage.PurchLines.PAGE.*/
                        _OpenItemTrackingLines;

                    end;
                }
                action("E&xtra Charges")
                {
                    ApplicationArea = FOODBasic;
                    AccessByPermission = TableData "Extra Charge" = R;
                    Caption = 'E&xtra Charges';
                    Image = Costs;

                    trigger OnAction()
                    begin
                        //This functionality was copied from page #37002673. Unsupported part was commented. Please check it.
                        /*CurrPage.PurchLines.PAGE.*/
                        _ShowExtraCharges;

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
                        //This functionality was copied from page #37002673. Unsupported part was commented. Please check it.
                        /*CurrPage.PurchLines.PAGE.*/
                        _ShowDimensions;

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

    trigger OnFindRecord(Which: Text): Boolean
    begin
        if not IsOpenForm then begin
            IsOpenForm := true;
        end;
        exit(Find(Which));
    end;

    trigger OnInit()
    begin
        "Lot No.Editable" := true; //P8000752
    end;

    var
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        EasyLotTracking: Codeunit "Easy Lot Tracking";
        IsOpenForm: Boolean;
        [InDataSet]
        "Lot No.Editable": Boolean;

    procedure _ShowDimensions()
    begin
        Rec.ShowDimensions;
    end;

    procedure ShowDimensions()
    begin
        Rec.ShowDimensions;
    end;

    procedure _OpenItemTrackingLines()
    begin
        CurrPage.SaveRecord;
        OpenItemTrackingLines;
    end;

    procedure OpenItemTrackingLines()
    begin
        CurrPage.SaveRecord;
        OpenItemTrackingLines;
    end;

    procedure _ShowExtraCharges()
    begin
        Rec.ShowExtraCharges;
    end;

    procedure ShowExtraCharges()
    begin
        Rec.ShowExtraCharges;
    end;

    procedure SetLotFields(Property: Code[10])
    var
        ProcessFns: Codeunit "Process 800 Functions";
        P800Globals: Codeunit "Process 800 System Globals";
        lboIsEditable: Boolean;
    begin
        // P8000043A
        case Property of
            'EDITABLE':
                begin
                    //P8000752 >>
                    "Lot No.Editable" :=
                    ProcessFns.TrackingInstalled and ("Lot No." <> P800Globals.MultipleLotCode) and (Type = Type::Item); // P8000071A
                end;
                //P8000752 <<
        end;
    end;
}

