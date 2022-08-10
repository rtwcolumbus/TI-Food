page 37002029 "Lot Control Items"
{
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 14 APR 09
    //   Transformed - additions in TIF Editor
    //   Page changes made after transformation
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Convert Items to Lot Controlled';
    PageType = Worksheet;
    SourceTable = "Lot Control Item";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(ItemDescription; ItemDescription)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Description';
                }
                field(ItemUOM; ItemUOM)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Base Unit of Measure';
                }
                field("Item Tracking Code"; "Item Tracking Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot Nos."; "Lot Nos.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Original Lot No."; "Original Lot No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Message; Message)
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Convert)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Convert';
                Image = UnitConversions;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    LotControlItem: Record "Lot Control Item";
                begin
                    if not Confirm(Text001, false) then
                        exit;

                    LotControlItem.Copy(Rec);
                    REPORT.RunModal(REPORT::"Convert Lot Controlled Items", false, false, LotControlItem);
                    Reset;
                end;
            }
        }
    }

    var
        Text001: Label 'This process will convert these items to lot controlled items; it is not reversible.\\Proceed?';
}

