page 37002003 "Sales Statistics Subform"
{
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Sales Statistics Subform';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Sales Statistic Line";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                    DecimalPlaces = 0 : 5;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Profit (LCY)"; "Profit (LCY)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Profit (%)"; "Profit (%)")
                {
                    ApplicationArea = FOODBasic;
                    DecimalPlaces = 1 : 1;
                }
                field("Unit Price (LCY)"; "Unit Price (LCY)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Amount (LCY)"; "Amount (LCY)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Line Discount (LCY)"; "Line Discount (LCY)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Line Amount (LCY)"; "Line Amount (LCY)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit Cost (LCY)"; "Unit Cost (LCY)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Cost (LCY)"; "Cost (LCY)")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        TempLine.Copy(Rec);
        if TempLine.Find(Which) then begin
            Rec := TempLine;
            exit(true);
        end else
            exit(false);
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        ResultSteps: Integer;
    begin
        TempLine.Copy(Rec);
        ResultSteps := TempLine.Next(Steps);
        if ResultSteps <> 0 then
            Rec := TempLine;
        exit(ResultSteps);
    end;

    var
        TempLine: Record "Sales Statistic Line" temporary;

    procedure SetTempSalesLine(var NewTempLine: Record "Sales Statistic Line" temporary)
    begin
        TempLine.Reset;
        TempLine.DeleteAll;
        if NewTempLine.Find('-') then
            repeat
                TempLine := NewTempLine;
                TempLine.Insert;
            until NewTempLine.Next = 0;
        CurrPage.Update;
    end;
}

