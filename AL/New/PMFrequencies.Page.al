page 37002832 "PM Frequencies"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   Standard lsit style form for PM Frequencies
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 30 JAN 09
    //   Transformed - additions in TIF Editor
    //   Page changes made after transformation
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'PM Frequencies';
    PageType = List;
    SourceTable = "PM Frequency";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Calendar Frequency"; "Calendar Frequency")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Usage Frequency"; "Usage Frequency")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Usage Unit of Measure"; "Usage Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lead Time"; "Lead Time")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
    }
}

