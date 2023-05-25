page 37002571 "Container Type Charges"
{
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 02 FEB 09
    //   Transformed - additions in TIF Editor
    // 
    // P8000782, VerticalSoft, Rick Tweedle, 02 MAR 10
    //   Transformed to Page using transfor tool
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017

    Caption = 'Container Type Charges';
    DataCaptionExpression = CaptionText;
    PageType = List;
    SourceTable = "Container Type Charge";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Container Type Code"; "Container Type Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = TypeEditable;
                }
                field("Container Charge Code"; "Container Charge Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = ChargeEditable;
                }
                field("Account No."; "Account No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit Price"; "Unit Price")
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

    trigger OnOpenPage()
    begin
        case true of
            GetFilter("Container Type Code") <> '':
                begin
                    TypeEditable := false;
                    ChargeEditable := true;
                    CaptionText := GetFilter("Container Type Code");
                end;
            GetFilter("Container Charge Code") <> '':
                begin
                    ChargeEditable := false;
                    TypeEditable := true;
                    CaptionText := GetFilter("Container Charge Code");
                end;
        end;
    end;

    var
        CaptionText: Code[20];
        [InDataSet]
        TypeEditable: Boolean;
        [InDataSet]
        ChargeEditable: Boolean;
}

