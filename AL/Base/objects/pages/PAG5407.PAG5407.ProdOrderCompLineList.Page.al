page 5407 "Prod. Order Comp. Line List"
{
    // PR1.20
    //   Add Line menu button with Document Card item
    // 
    // PR2.10
    //   Add options for finished production order for Document Card
    // 
    // PR4.00
    // P8000197A, Myers Nissi, Jack Reynolds, 21 SEP 05
    //   Add support for changed orders (red) and pending orders
    // 
    // PRW16.00.02
    // P8000787, VerticalSoft, MMAS, 05 MAR 10
    //   Page creation

    ApplicationArea = Manufacturing;
    Caption = 'Prod. Order Comp. Lines';
    Editable = false;
    PageType = List;
    SourceTable = "Prod. Order Component";
    UsageCategory = Lists;

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
                    ToolTip = 'Specifies the status of the production order to which the component list belongs.';
                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                    ApplicationArea = Manufacturing;
                    HideValue = "Prod. Order No.HideValue";
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the number of the related production order.';
                }
                field("Prod. Order Line No."; Rec."Prod. Order Line No.")
                {
                    ApplicationArea = Manufacturing;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the number of the production order line to which the component list belongs.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Manufacturing;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the number of the item that is a component in the production order component list.';
                }
                field("Variant Code"; Rec."Variant Code")
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
                    ToolTip = 'Specifies a description of the item on the line.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
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
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Location;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the location where the component is stored. Copies the location code from the corresponding field on the production order line.';
                    Visible = true;
                }
                field("Quantity per"; Rec."Quantity per")
                {
                    ApplicationArea = Manufacturing;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies how many units of the component are required to produce the parent item.';
                }
                field("Expected Quantity"; Rec."Expected Quantity")
                {
                    ApplicationArea = Manufacturing;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the quantity of the component expected to be consumed during the production of the quantity on this line.';
                }
                field("Remaining Quantity"; Rec."Remaining Quantity")
                {
                    ApplicationArea = Manufacturing;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the difference between the finished and planned quantities, or zero if the finished quantity is greater than the remaining quantity.';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = Manufacturing;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the date when the produced item must be available. The date is copied from the header of the production order.';
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = Manufacturing;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the cost of one unit of the item or resource on the line.';
                    Visible = false;
                }
                field("Cost Amount"; Rec."Cost Amount")
                {
                    ApplicationArea = Manufacturing;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the total cost on the line by multiplying the unit cost by the quantity.';
                    Visible = false;
                }
                field(Position; Position)
                {
                    ApplicationArea = Manufacturing;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the position of the component on the bill of material.';
                    Visible = false;
                }
                field("Position 2"; Rec."Position 2")
                {
                    ApplicationArea = Manufacturing;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the components position in the BOM. It is copied from the production BOM when you calculate the production order.';
                    Visible = false;
                }
                field("Position 3"; Rec."Position 3")
                {
                    ApplicationArea = Manufacturing;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the third reference number for the component position on a bill of material, such as the alternate position number of a component on a print card.';
                    Visible = false;
                }
                field("Lead-Time Offset"; Rec."Lead-Time Offset")
                {
                    ApplicationArea = Manufacturing;
                    Style = Attention;
                    StyleExpr = DisplayStyle;
                    ToolTip = 'Specifies the lead-time offset for the component line. It is copied from the corresponding field in the production BOM when you calculate the production order.';
                    Visible = false;
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
                action("Document Card")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Document Card';
                    Image = Document;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        ProdOrder: Record "Production Order";
                    begin
                        // PR1.20 Begin
                        if "Line No." > 10000000 then // P8000197A
                            exit;                       // P8000197A
                        ProdOrder.Get(Status, "Prod. Order No.");
                        case Status of
                            Status::Simulated:
                                PAGE.Run(PAGE::"Simulated Production Order", ProdOrder);
                            Status::Planned:
                                PAGE.Run(PAGE::"Planned Production Order", ProdOrder);
                            Status::"Firm Planned":
                                PAGE.Run(PAGE::"Firm Planned Prod. Order", ProdOrder);
                            Status::Released:
                                PAGE.Run(PAGE::"Released Production Order", ProdOrder);
                            Status::Finished:                                        // PR2.10
                                PAGE.Run(PAGE::"Finished Production Order", ProdOrder); // PR2.10
                        end;
                        // PR1.20 End
                    end;
                }
                action("Item &Tracking Lines")
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Item &Tracking Lines';
                    Image = ItemTrackingLines;
                    ShortCutKey = 'Ctrl+Alt+I'; 
                    ToolTip = 'View or edit serial numbers and lot numbers that are assigned to the item on the document or journal line.';

                    trigger OnAction()
                    begin
                        OpenItemTrackingLines();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        CurrColour: Integer;
    begin
        "Prod. Order No.HideValue" := false;
        ShowShortcutDimCode(ShortcutDimCode);
        ProdOrderNoOnFormat(Format("Prod. Order No."));

        DisplayStyle := (DisplayColor() = 255); // P8000787
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(ShortcutDimCode);
    end;

    protected var
        ShortcutDimCode: array[8] of Code[20];
        [InDataSet]
        "Prod. Order No.HideValue": Boolean;
        [InDataSet]
        DisplayStyle: Boolean;

    procedure DisplayColor(): Integer
    begin
        // P8000197A
        if "Line No." > 10000000 then
            exit(255);
        // P8000197A
    end;

    local procedure ProdOrderNoOnFormat(Text: Text[1024])
    begin
        // P8000197A
        if CopyStr(Text, 1, 3) = '***' then
            "Prod. Order No.HideValue" := true;
        // P8000197A
    end;
}

