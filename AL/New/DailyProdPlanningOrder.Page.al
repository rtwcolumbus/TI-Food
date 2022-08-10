page 37002506 "Daily Prod. Planning-Order"
{
    // PR4.00
    // P8000197A, Myers Nissi, Jack Reynolds, 22 SEP 05
    //   Card style form used to create and change production order from the daily production planning board
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 02 FEB 09
    //   Transformed from Form
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013

    Caption = 'Daily Prod. Planning-Order';
    DataCaptionExpression = '';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Daily Production Planning";

    layout
    {
        area(content)
        {
            field("No."; "No.")
            {
                ApplicationArea = FOODBasic;
                HideValue = "No.HideValue";
            }
            field("Source No."; "Source No.")
            {
                ApplicationArea = FOODBasic;
                Editable = false;
            }
            field("Item Description"; "Item Description")
            {
                ApplicationArea = FOODBasic;
            }
            field("Variant Code"; "Variant Code")
            {
                ApplicationArea = FOODBasic;
                Editable = "Variant CodeEditable";
            }
            field("Location Code"; "Location Code")
            {
                ApplicationArea = FOODBasic;
            }
            field("Equipment Code"; "Equipment Code")
            {
                ApplicationArea = FOODBasic;
            }
            field("Equipment Description"; "Equipment Description")
            {
                ApplicationArea = FOODBasic;
            }
            field("Sequence Code"; "Sequence Code")
            {
                ApplicationArea = FOODBasic;
            }
            field(Quantity; Quantity)
            {
                ApplicationArea = FOODBasic;
                Editable = QuantityEditable;
            }
            field("Unit of Measure Code"; "Unit of Measure Code")
            {
                ApplicationArea = FOODBasic;
                Editable = false;
            }
            field("Starting Date"; "Starting Date")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Starting Date / Time';
            }
            field("Starting Time"; "Starting Time")
            {
                ApplicationArea = FOODBasic;
            }
            field("Ending Date"; "Ending Date")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Ending Date / Time';
            }
            field("Ending Time"; "Ending Time")
            {
                ApplicationArea = FOODBasic;
            }
            field("Due Date"; "Due Date")
            {
                ApplicationArea = FOODBasic;
            }
            field(Release; Release)
            {
                ApplicationArea = FOODBasic;
                Editable = ReleaseEditable;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        ReleaseEditable := Status = Status::"Firm Planned";
        "Variant CodeEditable" := "No." <> '';
        QuantityEditable := QtyChangeAllowed;
    end;

    trigger OnAfterGetRecord()
    begin
        "No.HideValue" := false;
        if CopyStr(Format("No."), 1, 3) = '***' then
            "No.HideValue" := true;
    end;

    trigger OnInit()
    begin
        QuantityEditable := true;
        "Variant CodeEditable" := true;
        ReleaseEditable := true;
    end;

    var
        ProdPlanRec: Record "Daily Production Planning";
        TempProdPlan: Record "Daily Production Planning" temporary;
        OK: Boolean;
        [InDataSet]
        ReleaseEditable: Boolean;
        [InDataSet]
        "Variant CodeEditable": Boolean;
        [InDataSet]
        QuantityEditable: Boolean;
        [InDataSet]
        "No.HideValue": Boolean;
}

