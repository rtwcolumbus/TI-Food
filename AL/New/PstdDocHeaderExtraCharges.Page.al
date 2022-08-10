page 37002675 "Pstd.Doc. Header Extra Charges"
{
    // PR4.00.06
    // P8000487A, VerticalSoft, Jack Reynolds, 12 JUN 07
    //   Multi-currency support for extra charges
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 20 JUL 09
    //   Transformed from Form
    // 
    // PRW16.00.05
    // P8000928, Columbus IT, Jack Reynolds, 06 APR 11
    //   Support for extra charges on transfer orders
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Posted Document Header Extra Charges';
    DataCaptionExpression = GetCaption;
    Editable = false;
    PageType = List;
    SourceTable = "Posted Document Extra Charge";
    SourceTableView = WHERE("Line No." = CONST(0));

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
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Allocation Method"; "Allocation Method")
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
    }

    actions
    {
    }

    var
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
            exit(StrSubstNo('%1 %2', SourceTableName, CurrDocNo));
    end;
}

