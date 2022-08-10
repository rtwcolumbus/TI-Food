page 37002670 "Extra Charge Posting Setup"
{
    // PR3.70.05
    // P8000062B, Myers Nissi, Jack Reynolds, 18 JUN 04
    //   Add controls for Invt. Accrual Acc. (Interim)
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 02 FEB 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Extra Charge Posting Setup';
    DataCaptionFields = "Gen. Bus. Posting Group", "Gen. Prod. Posting Group";
    PageType = List;
    SourceTable = "Extra Charge Posting Setup";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Extra Charge Code"; "Extra Charge Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Direct Cost Applied Account"; "Direct Cost Applied Account")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Invt. Accrual Acc. (Interim)"; "Invt. Accrual Acc. (Interim)")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
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

