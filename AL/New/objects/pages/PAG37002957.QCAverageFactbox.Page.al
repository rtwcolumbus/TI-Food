page 37002957 "Q/C Average Factbox"
{
    // PRW111.00.01
    // P80037659, To-Increase, Jack Reynolds, 25 JUL 18
    //   QC-Additions: Develop average measurement

    Caption = 'Averages';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "Quality Control Line";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Test Code"; "Test Code")
                {
                    ApplicationArea = FOODBasic;
                    Lookup = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Result; Result)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                    Lookup = false;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                    OptionCaption = ' ,Pass,Fail,Skip,Suspended';
                }
                field("Averaging Method"; "Averaging Method")
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
        Process800QCFunctions: Codeunit "Process 800 Q/C Functions";

    procedure LoadData()
    begin
        Process800QCFunctions.GetAverageCalculation(Rec);
        if FindFirst then;
        CurrPage.Update(false);
    end;

    procedure SetQCCodeunit(var QCCodeunit: Codeunit "Process 800 Q/C Functions")
    begin
        Process800QCFunctions := QCCodeunit;
    end;
}

