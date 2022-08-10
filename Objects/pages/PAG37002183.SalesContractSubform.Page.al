page 37002183 "Sales Contract Subform"
{
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW110.0.01
    // P80042410, To-Increase, Dayakar Battini, 05 JUL 17
    //   Fix for contract line limit functionality.
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Sales Contract Subform';
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "Sales Contract Line";
    SourceTableView = SORTING("Contract No.", "Item Type", "Item Code");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item Type"; "Item Type")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        UpdatePageControls;
                    end;
                }
                field("Item Code"; "Item Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = ItemCode1Editable;
                }
                field("Line Limit Unit of Measure"; "Line Limit Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Line Limit"; "Line Limit")
                {
                    ApplicationArea = FOODBasic;
                }
                field(CalcLimitUsed; CalcLimitUsed)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Line Limit Used';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                }
                field("Limit Type"; "Limit Type")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        UpdatePageControls;
    end;

    trigger OnOpenPage()
    begin
        UpdatePageControls;
    end;

    var
        [InDataSet]
        ItemCode1Editable: Boolean;

    procedure UpdatePageControls()
    begin
        ItemCode1Editable := "Item Type" <> "Item Type"::"All Items";
    end;
}

