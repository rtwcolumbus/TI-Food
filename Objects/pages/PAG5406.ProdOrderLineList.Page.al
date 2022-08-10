page 5406 "Prod. Order Line List"
{
    // PR1.20
    //   Add Line menu button with Document Card item
    // 
    // PR3.10
    //   Add options for finished production order for Document Card
    // 
    // PR4.00
    // P8000197A, Myers Nissi, Jack Reynolds, 21 SEP 05
    //   Add support for changed orders (red) and pending orders
    // 
    // PR4.00.03
    // P8000325A, VerticalSoft, Jack Reynolds, 01 MAY 06
    //   Line menu button is now strandard in P800
    // 
    // PRW16.00.02
    // P8000787, VerticalSoft, MMAS, 05 MAR 10
    //   Page creation

    Caption = 'Prod. Order Line List';
    Editable = false;
    PageType = List;
    SourceTable = "Prod. Order Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Status; Status)
                {
                    ApplicationArea = Manufacturing;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies a value that is copied from the corresponding field on the production order header.';
                }
                field("Prod. Order No."; "Prod. Order No.")
                {
                    ApplicationArea = Manufacturing;
                    HideValue = "Prod. Order No.HideValue";
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the number of the related production order.';
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = Manufacturing;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the number of the item that is to be produced.';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = Planning;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = Manufacturing;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the value of the Description field on the item card. If you enter a variant code, the variant description is copied to this field instead.';
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = Manufacturing;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies an additional description.';
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field(ShortcutDim3; ShortcutDimCode[3])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,3';
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;
                }
                field(ShortcutDim4; ShortcutDimCode[4])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,4';
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(4),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;
                }
                field(ShortcutDim5; ShortcutDimCode[5])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,5';
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(5),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;
                }
                field(ShortcutDim6; ShortcutDimCode[6])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,6';
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(6),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;
                }
                field(ShortcutDim7; ShortcutDimCode[7])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,7';
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(7),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;
                }
                field(ShortcutDim8; ShortcutDimCode[8])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,8';
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(8),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = Location;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the location code, if the produced items should be stored in a specific location.';
                    Visible = true;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = Manufacturing;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the quantity to be produced if you manually fill in this line.';
                }
                field("Finished Quantity"; "Finished Quantity")
                {
                    ApplicationArea = Manufacturing;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies how much of the quantity on this line has been produced.';
                }
                field("Remaining Quantity"; "Remaining Quantity")
                {
                    ApplicationArea = Manufacturing;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the difference between the finished and planned quantities, or zero if the finished quantity is greater than the remaining quantity.';
                }
                field("Scrap %"; "Scrap %")
                {
                    ApplicationArea = Manufacturing;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the percentage of the item that you expect to be scrapped in the production process.';
                    Visible = false;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = Manufacturing;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the date when the produced item must be available. The date is copied from the header of the production order.';
                }
                field("Starting Date"; StartingDate)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Starting Date';
                    ToolTip = 'Specifies the entry''s starting date, which is retrieved from the production order routing.';
                    Visible = DateAndTimeFieldVisible;
                }
                field("Starting Time"; StartingTime)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Starting Time';
                    ToolTip = 'Specifies the entry''s starting time, which is retrieved from the production order routing.';
                    Visible = DateAndTimeFieldVisible;
                }
                field("Ending Date"; EndingDate)
                {
                    StyleExpr = DisplayStyle;
                    ApplicationArea = Manufacturing;
                    Caption = 'Ending Date';
                    ToolTip = 'Specifies the entry''s ending date, which is retrieved from the production order routing.';
                    Visible = DateAndTimeFieldVisible;
                }
                field("Ending Time"; EndingTime)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Ending Time';
                    ToolTip = 'Specifies the entry''s ending time, which is retrieved from the production order routing.';
                    Visible = DateAndTimeFieldVisible;
                }
                field("Starting Date-Time"; "Starting Date-Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the entry''s starting date and starting time, which is retrieved from the production order routing.';
                }
                field("Ending Date-Time"; "Ending Date-Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the entry''s ending date and ending time, which is retrieved from the production order routing.';
                }
                field("Production BOM No."; "Production BOM No.")
                {
                    ApplicationArea = Manufacturing;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the number of the production BOM that is the basis for creating the Prod. Order Component list for this line.';
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = Manufacturing;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the cost of one unit of the item or resource on the line.';
                }
                field("Cost Amount"; "Cost Amount")
                {
                    ApplicationArea = Manufacturing;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the total cost on the line by multiplying the unit cost by the quantity.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
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
                Image = Line;
                action(ShowDocument)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Show Document';
                    Image = View;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'Open the document that the selected line exists on.';

                    trigger OnAction()
                    var
                        ProdOrder: Record "Production Order";
                    begin
                        if "Line No." > 10000000 then // P8000197A
                            exit;                       // P8000197A
                        ProdOrder.Get(Status, "Prod. Order No.");
                        case Status of
                            Status::Planned:
                                PAGE.Run(PAGE::"Planned Production Order", ProdOrder);
                            Status::"Firm Planned":
                                PAGE.Run(PAGE::"Firm Planned Prod. Order", ProdOrder);
                            Status::Released:
                                PAGE.Run(PAGE::"Released Production Order", ProdOrder);
                            Status::Finished:                                        // PR3.10
                                PAGE.Run(PAGE::"Finished Production Order", ProdOrder); // PR3.10
                        end;

                        OnAfterShowDocument(Rec, ProdOrder);
                    end;
                }
                action(ShowReservEntries)
                {
                    AccessByPermission = TableData Item = R;
                    ApplicationArea = Reservation;
                    Caption = 'Reservation Entries';
                    Image = ReservationLedger;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'View the entries for every reservation that is made, either manually or automatically.';

                    trigger OnAction()
                    begin
                        if "Line No." > 10000000 then // P8000325A
                            exit;                       // P8000325A
                        ShowReservationEntries(true);
                    end;
                }
                action(ShowTrackingLines)
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Item &Tracking Lines';
                    Image = ItemTrackingLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Ctrl+Alt+I'; 
                    ToolTip = 'View or edit serial numbers and lot numbers that are assigned to the item on the document or journal line.';

                    trigger OnAction()
                    begin
                        if "Line No." > 10000000 then // P8000325A
                            exit;                       // P8000325A
                        OpenItemTrackingLines();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        "Prod. Order No.HideValue" := false;
        ShowShortcutDimCode(ShortcutDimCode);
        GetStartingEndingDateAndTime(StartingTime, StartingDate, EndingTime, EndingDate);
        DisplayStyle := (DisplayColor() = 255); // P8000787
    end;

    trigger OnInit()
    begin
        DateAndTimeFieldVisible := false;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(ShortcutDimCode);
    end;

    trigger OnOpenPage()
    begin
        DateAndTimeFieldVisible := false;
    end;

    var
        ShortcutDimCode: array[8] of Code[20];
        StartingTime: Time;
        EndingTime: Time;
        StartingDate: Date;
        EndingDate: Date;
        [InDataSet]
        "Prod. Order No.HideValue": Boolean;
        [InDataSet]
        DisplayStyle: Boolean;
        DateAndTimeFieldVisible: Boolean;

    [IntegrationEvent(false, false)]
    local procedure OnAfterShowDocument(var ProdOrderLine: Record "Prod. Order Line"; ProdOrder: Record "Production Order")
    begin
    end;

    procedure DisplayColor(): Integer
    begin
        // P8000197A
        if "Line No." > 10000000 then
            exit(255);
    end;

    local procedure ProdOrderNoOnFormat(Text: Text[1024])
    begin
        // P8000197A
        if CopyStr(Text, 1, 3) = '***' then
            "Prod. Order No.HideValue" := true;
        // P8000197A
    end;
}

