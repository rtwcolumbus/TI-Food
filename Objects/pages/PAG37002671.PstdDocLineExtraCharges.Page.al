page 37002671 "Pstd. Doc. Line Extra Charges"
{
    // PR4.00.06
    // P8000487A, VerticalSoft, Jack Reynolds, 12 JUN 07
    //   Multi-currency support for extra charges
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 02 FEB 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.05
    // P8000928, Columbus IT, Jack Reynolds, 06 APR 11
    //   Support for extra charges on transfer orders
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Posted Document Line Extra Charges';
    DataCaptionExpression = GetCaption;
    Editable = false;
    PageType = List;
    SourceTable = "Posted Document Extra Charge";

    layout
    {
        area(content)
        {
            repeater(Control37002001)
            {
                ShowCaption = false;
                field("Extra Charge Code"; "Extra Charge Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Charge; Charge)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Charge (LCY)"; "Charge (LCY)")
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

    var
        CurrLineNo: Integer;
        CurrTableID: Integer;
        SourceTableName: Text[100];

    procedure GetCaption(): Text[250]
    var
        ObjTransl: Record "Object Translation";
        NewTableID: Integer;
        CurrDocNo: Code[20];
    begin
        if not Evaluate(NewTableID, GetFilter("Table ID")) then
            exit('');

        if NewTableID = 0 then
            SourceTableName := ''
        else
            if NewTableID <> CurrTableID then
                SourceTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, NewTableID);

        CurrTableID := NewTableID;

        if GetFilter("Line No.") = '' then
            CurrLineNo := 0
        else
            if GetRangeMin("Line No.") = GetRangeMax("Line No.") then
                CurrLineNo := GetRangeMin("Line No.")
            else
                CurrLineNo := 0;

        if GetFilter("Document No.") = '' then
            CurrDocNo := ''
        else
            if GetRangeMin("Document No.") = GetRangeMax("Document No.") then
                CurrDocNo := GetRangeMin("Document No.")
            else
                CurrDocNo := '';

        if NewTableID = 0 then
            exit('')
        else
            if CurrLineNo = 0 then
                exit(StrSubstNo('%1 %2', SourceTableName, CurrDocNo))
            else
                exit(StrSubstNo('%1 %2 %3', SourceTableName, CurrDocNo, Format(CurrLineNo)));
    end;
}

