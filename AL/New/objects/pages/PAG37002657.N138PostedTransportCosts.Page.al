page 37002657 "N138 Posted Transport Costs"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 09-10-2014, Initial Version
    // --------------------------------------------------------------------------------
    // PRW110.0
    // P8008464, To-Increase, Dayakar Battini, 28 FEB 17
    //   Product N138 replaced with Distribution Planning
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects

    Caption = 'Posted Transport Costs';
    Editable = false;
    PageType = List;
    SourceTable = "N138 Posted Transport Cost";

    layout
    {
        area(content)
        {
            repeater(Control1100499000)
            {
                ShowCaption = false;
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Amount (LCY)"; "Amount (LCY)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Currency; Currency)
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("G/L Account No."; "G/L Account No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Purch. Invoice No."; "Purch. Invoice No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Posted Invoice No."; "Posted Invoice No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Posted Amount"; "Posted Amount")
                {
                    ApplicationArea = FOODBasic;
                }
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        // P8008464
        if not ProcessFns.DistPlanningInstalled then
            Error(Text000);
        // P8008464
    end;

    var
        ProcessFns: Codeunit "Process 800 Functions";
        Text000: Label 'Product Distribution Planning must be installed.';
}

