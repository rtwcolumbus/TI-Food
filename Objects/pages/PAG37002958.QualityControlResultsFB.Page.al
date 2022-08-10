page 37002958 "Quality Control Results FB"
{
    // PRW111.00.01
    // P80037659, To-Increase, Jack Reynolds, 25 JUL 18
    //   QC-Additions: Develop average measurement

    Caption = 'Quality Control Results';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Quality Control Line";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Test No."; "Test No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'No.';
                    StyleExpr = LineStyle;
                }
                field("Test Code"; "Test Code")
                {
                    ApplicationArea = FOODBasic;
                    StyleExpr = LineStyle;
                }
                field(Result; Result)
                {
                    ApplicationArea = FOODBasic;
                    StyleExpr = LineStyle;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                    OptionCaption = 'Not Tested,Pass,Fail,,Suspended';
                    StyleExpr = LineStyle;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        LineStyle := SetLineStyle;
    end;

    var
        SelectedTest: Record "Integer" temporary;
        [InDataSet]
        LineStyle: Text;

    local procedure SetLineStyle(): Text
    begin
        if not SelectedTest.Get("Test No.") then
            exit('Subordinate')
    end;

    procedure SetSelectedTest(var "Integer": Record "Integer" temporary)
    begin
        SelectedTest.Copy(Integer, true);
    end;
}

