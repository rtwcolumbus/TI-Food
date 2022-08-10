page 37002537 "Pre-Process Types"
{
    // PRW16.00.06
    // P8001082, Columbus IT, Don Bresee, 23 JAN 13
    //   Add Pre-Process functionality
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Pre-Process Types';
    PageType = List;
    SourceTable = "Pre-Process Type";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Blending; Blending)
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        EnableAutoComplete := Blending = Blending::"Per Order";
                    end;
                }
                field("Auto Complete"; "Auto Complete")
                {
                    ApplicationArea = FOODBasic;
                    Enabled = EnableAutoComplete;
                }
                field("Order Specific"; "Order Specific")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Default Lead Time (Days)"; "Default Lead Time (Days)")
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
        EnableAutoComplete := Blending = Blending::"Per Order";
    end;

    var
        [InDataSet]
        EnableAutoComplete: Boolean;
}

