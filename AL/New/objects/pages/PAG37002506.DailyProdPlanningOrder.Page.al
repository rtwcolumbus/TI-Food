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
    // 
    // PRW121.0
    // P800155629, To-Increase, Jack Reynolds, 03 NOV 22
    //   Add support for Mandatory Variant

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
            field("No."; Rec."No.")
            {
                ApplicationArea = FOODBasic;
                HideValue = "No.HideValue";
            }
            field("Source No."; Rec."Source No.")
            {
                ApplicationArea = FOODBasic;
                Editable = false;
            }
            field("Item Description"; Rec."Item Description")
            {
                ApplicationArea = FOODBasic;
            }
            field("Variant Code"; Rec."Variant Code")
            {
                ApplicationArea = FOODBasic;
                Editable = "Variant CodeEditable";
                ShowMandatory = "Variant CodeEditable" and VariantCodeMandatory;

                // P800155629
                trigger OnValidate()
                var
                    Item: Record "Item";
                begin
                    if Rec."Variant Code" = '' then
                        VariantCodeMandatory := Item.IsVariantMandatory(Rec."Source Type" = rec."Source Type"::Item, Rec."Source No.");
                end;
            }
            field("Location Code"; Rec."Location Code")
            {
                ApplicationArea = FOODBasic;
            }
            field("Equipment Code"; Rec."Equipment Code")
            {
                ApplicationArea = FOODBasic;
            }
            field("Equipment Description"; Rec."Equipment Description")
            {
                ApplicationArea = FOODBasic;
            }
            field("Sequence Code"; Rec."Sequence Code")
            {
                ApplicationArea = FOODBasic;
            }
            field(Quantity; Rec.Quantity)
            {
                ApplicationArea = FOODBasic;
                Editable = QuantityEditable;
            }
            field("Unit of Measure Code"; Rec."Unit of Measure Code")
            {
                ApplicationArea = FOODBasic;
                Editable = false;
            }
            field("Starting Date"; Rec."Starting Date")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Starting Date / Time';
            }
            field("Starting Time"; Rec."Starting Time")
            {
                ApplicationArea = FOODBasic;
            }
            field("Ending Date"; Rec."Ending Date")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Ending Date / Time';
            }
            field("Ending Time"; Rec."Ending Time")
            {
                ApplicationArea = FOODBasic;
            }
            field("Due Date"; Rec."Due Date")
            {
                ApplicationArea = FOODBasic;
            }
            field(Release; Rec.Release)
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
    var
        Item: Record "Item";
    begin
        // P8001132
        ReleaseEditable := Rec.Status = Rec.Status::"Firm Planned";
        "Variant CodeEditable" := Rec."Source No." <> '';
        QuantityEditable := Rec.QtyChangeAllowed;
        // P800155629
        if Rec."Variant Code" = '' then
            VariantCodeMandatory := Item.IsVariantMandatory(Rec."Source Type" = rec."Source Type"::Item, Rec."Source No.");
        // P800155629
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
        VariantCodeMandatory: Boolean;
}

