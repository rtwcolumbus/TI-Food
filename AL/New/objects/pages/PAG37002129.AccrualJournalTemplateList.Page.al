page 37002129 "Accrual Journal Template List"
{
    // PR3.61AC
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 30 JAN 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Accrual Journal Template List';
    Editable = false;
    PageType = List;
    SourceTable = "Accrual Journal Template";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field(Name; Name)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Recurring; Recurring)
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Source Code"; "Source Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Page ID"; "Page ID")
                {
                    ApplicationArea = FOODBasic;
                    LookupPageID = Objects;
                    Visible = false;
                }
                field("Test Report ID"; "Test Report ID")
                {
                    ApplicationArea = FOODBasic;
                    LookupPageID = Objects;
                    Visible = false;
                }
                field("Posting Report ID"; "Posting Report ID")
                {
                    ApplicationArea = FOODBasic;
                    LookupPageID = Objects;
                    Visible = false;
                }
                field("Force Posting Report"; "Force Posting Report")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
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

