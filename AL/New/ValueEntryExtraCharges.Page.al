page 37002672 "Value Entry Extra Charges"
{
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 02 FEB 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Value Entry Extra Charges';
    DataCaptionExpression = GetCaption;
    Editable = false;
    PageType = List;
    SourceTable = "Value Entry Extra Charge";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
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
                field("Charge Posted to G/L"; "Charge Posted to G/L")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Expected Charge"; "Expected Charge")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Expected Charge Posted to G/L"; "Expected Charge Posted to G/L")
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

    var
        CurrEntryNo: Integer;
        SourceTableName: Text[100];

    procedure GetCaption(): Text[250]
    var
        ObjTransl: Record "Object Translation";
        NewTableID: Integer;
    begin
        SourceTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, DATABASE::"Value Entry");

        if GetFilter("Entry No.") = '' then
            CurrEntryNo := 0
        else
            if GetRangeMin("Entry No.") = GetRangeMax("Entry No.") then
                CurrEntryNo := GetRangeMin("Entry No.")
            else
                CurrEntryNo := 0;

        exit(StrSubstNo('%1 %2', SourceTableName, Format(CurrEntryNo)));
    end;
}

