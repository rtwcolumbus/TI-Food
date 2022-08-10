page 37002841 "PM Worksheet Names"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   Standard list style form for PM worksheet names
    // 
    // PRW16.00.20
    // P8000672, VerticalSoft, Jack Reynolds, 30 JAN 09
    //   Add Edit Worksheet button to run the selected worksheet
    // 
    // P8000664, VerticalSoft, Jack Reynolds, 30 JAN 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'PM Worksheet Names';
    PageType = List;
    SourceTable = "PM Worksheet Name";

    layout
    {
        area(content)
        {
            repeater(Control37002001)
            {
                ShowCaption = false;
                field(Name; Name)
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
        area(processing)
        {
            action("Edit Worksheet")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Edit Worksheet';
                Image = Edit;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Return';

                trigger OnAction()
                begin
                    PMWorkSheet."PM Worksheet Name" := Name;
                    PAGE.Run(PAGE::"PM Worksheet", PMWorkSheet);
                end;
            }
        }
    }

    var
        PMWorkSheet: Record "PM Worksheet";
}

