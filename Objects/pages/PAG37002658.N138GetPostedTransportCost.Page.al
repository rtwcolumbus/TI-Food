page 37002658 "N138 Get Posted Transport Cost"
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

    Caption = 'Posted Transport Costs';
    Editable = false;
    PageType = List;
    SourceTable = "N138 Posted Transport Cost";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control1100499000)
            {
                ShowCaption = false;
                field("Posted No."; "Posted No.")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = PostedTransportOrderNoHideValu;
                }
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
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
            }
        }
    }

    actions
    {
    }

    var
        [InDataSet]
        PostedTransportOrderNoHideValu: Boolean;
        [InDataSet]
        PostedTransportOrderNoEmphasiz: Boolean;

    procedure SetTransportCost(var PostedTransCost: Record "N138 Posted Transport Cost" temporary)
    begin
        Copy(PostedTransCost, true);
    end;

    procedure GetTransportCost(var PostedTransCost: Record "N138 Posted Transport Cost" temporary)
    begin
        CurrPage.SetSelectionFilter(Rec);
        PostedTransCost.Copy(Rec, true);
    end;
}

