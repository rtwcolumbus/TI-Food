page 37002163 "Acc. Schedule Units"
{
    // PRW16.00.06
    // P8001019, Columbus IT, Jack Reynolds, 16 JAN 12
    //   Account Schedule - Item Units
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Account Schedule Units';
    PageType = List;
    SourceTable = "Acc. Schedule Unit";
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
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity Field"; "Quantity Field")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item Category Code Filter"; "Item Category Code Filter")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookUpItemCatFilter(Text));
                    end;
                }
                field(Factor; Factor)
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control37002009; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control37002010; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
    }
}

