page 37002890 "Data Collection Temp. Line FB"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection

    Caption = 'Data Collection Temp. Line FB';
    PageType = ListPart;
    SourceTable = "Data Collection Template Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Data Element Code"; "Data Element Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Data Element Type"; "Data Element Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field(TargetValue; TargetValue)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Target Value';
                }
            }
        }
    }

    actions
    {
    }
}

