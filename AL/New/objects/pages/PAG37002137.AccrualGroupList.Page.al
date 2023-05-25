page 37002137 "Accrual Group List"
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
    //
    //   PRW113.00.03
    //   P80093906, To Increase, Jack Reynolds, 14 FEB 20
    //     Maintain Accrual Plan Search Line table when inserting and deleting group members

    Caption = 'Accrual Group List';
    DataCaptionFields = "Accrual Group Type", "No.";
    PageType = List;
    SourceTable = "Accrual Group Line";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Accrual Group Code"; "Accrual Group Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Accrual Group Description"; "Accrual Group Description")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
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

    trigger OnDeleteRecord(): Boolean
    var
        AccrualSearchMgt: Codeunit "Accrual Search Management";
    begin
        AccrualSearchMgt.DeleteGroupLine(Rec); // P80093906
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        AccrualSearchMgt: Codeunit "Accrual Search Management";
    begin
        // P8000828
        Insert;
        AccrualSearchMgt.InsertGroupLine(Rec);
        exit(false);
    end;
}

