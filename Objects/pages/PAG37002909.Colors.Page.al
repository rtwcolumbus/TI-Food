page 37002909 Colors
{
    Caption = 'Colors';
    PageType = List;
    PromotedActionCategories = 'New,Color';
    ObsoleteState = Pending;
    ObsoleteReason = 'This was used to support color selection for the VPS which never made it to AL';
    ObsoleteTag = 'FOOD-21';
    SourceTable = Color;
    SourceTableView = SORTING(Red, Green, Blue);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Red; Red)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Green; Green)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Blue; Blue)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Control1000000007; Color)
                {
                    ApplicationArea = FOODBasic;
                    ShowCaption = false;
                    QuickEntry = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Color)
            {
                Caption = 'Color';
                action(Select)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Select';
                    Image = New;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'F4';

                    trigger OnAction()
                    begin
                        AssistEdit;
                        SetColor;
                        CurrPage.Update;
                    end;
                }
            }
        }
    }
}

