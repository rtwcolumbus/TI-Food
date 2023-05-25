page 37002431 "Lot No. Segment Values"
{
    // PRW17.10
    // P8001234, Columbus IT, Jack Reynolds, 01 NOV 13
    //    Support for custom lot number formats
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Lot No. Segment Values';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Lot No. Segment Value";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Code/No."; "Code/No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Description';
                    QuickEntry = false;
                }
                field("Segment Value"; "Segment Value")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control37002006; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control37002007; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetupNewLine(xRec);
    end;
}

