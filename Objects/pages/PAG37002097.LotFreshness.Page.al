page 37002097 "Lot Freshness"
{
    // PRE16.00.06
    // P8001060, Columbus IT, Jack Reynolds, 23 APR 12
    //   Allow freshness preference to be specified for All Items

    Caption = 'Lot Freshness';
    PageType = ListPart;
    SourceTable = "Lot Freshness";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Item Type"; "Item Type")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        AllItems := "Item Type" = "Item Type"::"All Items"; // P8001060
                    end;
                }
                field("Item Code"; "Item Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = NOT AllItems;
                }
                field("Days to Fresh"; "Days to Fresh")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Required Shelf Life"; "Required Shelf Life")
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
        AllItems := "Item Type" = "Item Type"::"All Items"; // P8001060
    end;

    var
        [InDataSet]
        AllItems: Boolean;
}

