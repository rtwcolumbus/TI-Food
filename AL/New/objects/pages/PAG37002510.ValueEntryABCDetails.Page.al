page 37002510 "Value Entry ABC Details"
{
    // PR4.00.04
    // P8000375A, VerticalSoft, Jack Reynolds, 08 SEP 06
    //   Standard list style form for Value Entry ABC Detail
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 02 FEB 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Value Entry ABC Details';
    DataCaptionExpression = GetCaption;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Value Entry ABC Detail";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Resource No."; "Resource No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Cost; Cost)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Cost Posted to G/L"; "Cost Posted to G/L")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Overhead; Overhead)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Overhead Posted to G/L"; "Overhead Posted to G/L")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Cost (ACY)"; "Cost (ACY)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Cost Posted to G/L (ACY)"; "Cost Posted to G/L (ACY)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Overhead (ACY)"; "Overhead (ACY)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Overhead Posted to G/L (ACY)"; "Overhead Posted to G/L (ACY)")
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

