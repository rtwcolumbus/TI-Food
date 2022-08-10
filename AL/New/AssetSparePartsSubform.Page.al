page 37002818 "Asset Spare Parts Subform"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   Standard list style subform for asset spare parts (filtered by manufacturer and model no.)
    // 
    // PRW15.00.01
    // P8000579A, VerticalSoft, Jack Reynolds, 20 FEB 08
    //   Filter item lookup for spares
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 06 FEB 09
    //   Transformed from form
    //   Changes made to page after transformation
    // 
    // PR6.00.04
    // P8000844, VerticalSoft, Jack Reynolds, 15 JUL 10
    //   Fix problem with editing
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Spare Parts';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Asset Spare Part";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        MaintMgt: Codeunit "Maintenance Management";
                    begin
                        if Type = Type::Stock then         // P8000579A
                            exit(MaintMgt.LookupItem(Text)); // P8000579A
                    end;
                }
                field("Part No."; "Part No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
    }

    procedure SetFilter(MfgCode: Code[10]; ModelNo: Code[30])
    begin
        FilterGroup(4);
        SetRange("Manufacturer Code", MfgCode);
        SetRange("Model No.", ModelNo);
        FilterGroup(0);

        CurrPage.Update;
    end;
}

