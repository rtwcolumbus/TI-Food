page 37002724 "Value Entry Extra Chgs. Prev."
{
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 11 NOV 15
    //   Posting preview

    Caption = 'Value Entry Extra Charges Preview';
    DataCaptionExpression = GetCaption;
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "Value Entry Extra Charge";
    SourceTableTemporary = true;

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

    procedure Set(var TempExtraChargeEntry: Record "Value Entry Extra Charge" temporary)
    begin
        // P8004516
        if TempExtraChargeEntry.Find('-') then
            repeat
                Rec := TempExtraChargeEntry;
                Insert;
            until TempExtraChargeEntry.Next = 0;
    end;
}

