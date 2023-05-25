page 37002817 "Asset Spare Parts"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   Standard list style form for asset spare parts
    // 
    // PRW15.00.01
    // P8000579A, VerticalSoft, Jack Reynolds, 20 FEB 08
    //   Filter item lookup for spares
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 30 JAN 09
    //   Transformed - additions in TIF Editor
    //   Page changes made after transformation
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Asset Spare Parts';
    DataCaptionFields = "Manufacturer Code", "Model No.";
    PageType = List;
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
        area(factboxes)
        {
            systempart(Control1900000003; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1900000004; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
    }
}

