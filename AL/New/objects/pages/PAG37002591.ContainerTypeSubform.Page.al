page 37002591 "Container Type Subform"
{
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group

    Caption = 'Container Type Subform';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Container Type Usage";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item Type"; "Item Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item Code"; "Item Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Ranking; Ranking)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Default Quantity"; "Default Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Single Lot"; "Single Lot")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        NewRecord;
    end;
}

