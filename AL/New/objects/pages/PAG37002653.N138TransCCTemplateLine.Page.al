page 37002653 "N138 Trans. CC Template Line"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 09-10-2014, Initial Version
    // --------------------------------------------------------------------------------
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects

    AutoSplitKey = true;
    Caption = 'Lines';
    PageType = ListPart;
    SourceTable = "N138 Trans. CC Template Line";

    layout
    {
        area(content)
        {
            repeater(Control1100499000)
            {
                ShowCaption = false;
                field("Transport Cost Component"; "Transport Cost Component")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
    }
}

