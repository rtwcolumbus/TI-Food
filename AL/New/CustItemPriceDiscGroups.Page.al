page 37002178 "Cust./Item Price/Disc. Groups"
{
    // PR5.00
    // P8000545A, VerticalSoft, Don Bresee, 13 NOV 07
    //   New table for associations between customers and item categories/product groups
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 30 JAN 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group

    Caption = 'Cust./Item Price/Disc. Groups';
    DataCaptionFields = "Customer No.", "Item Category Code";
    PageType = List;
    SourceTable = "Cust./Item Price/Disc. Group";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Item Category Code"; "Item Category Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Customer Price Group"; "Customer Price Group")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Customer Disc. Group"; "Customer Disc. Group")
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

