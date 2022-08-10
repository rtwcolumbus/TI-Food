page 37002047 "Item Cost Basis"
{
    // PR4.00
    // P8000245B, Myers Nissi, Jack Reynolds, 04 OCT 05
    //   Add controls to table box for Variant Code
    // 
    // PR5.00
    // P8000539A, VerticalSoft, Don Bresee, 17 NOV 07
    //   Add Cost Basis Code and Audit Text
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 06 FEB 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Item Cost Basis';
    DataCaptionFields = "Cost Basis Code", "Item No.";
    Editable = false;
    PageType = List;
    SourceTable = "Item Cost Basis";

    layout
    {
        area(content)
        {
            repeater(Control37002001)
            {
                ShowCaption = false;
                field("Cost Basis Code"; "Cost Basis Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Cost Date"; "Cost Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Audit Text"; "Audit Text")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Cost Value"; "Cost Value")
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

    trigger OnAfterGetRecord()
    begin
        CalcFields("Currency Code"); // P8000539A
    end;
}

