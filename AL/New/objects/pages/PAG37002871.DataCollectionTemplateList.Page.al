page 37002871 "Data Collection Template List"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group

    Caption = 'Data Collection Template List';
    DataCaptionExpression = Caption;
    PageType = List;
    SourceTable = "Data Collection Temp/Item Cat.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Template Code"; "Template Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                }
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control37002004; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control37002005; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Caption := ItemCategory.TableCaption
    end;

    var
        Text001: Label '% Templates';
        ItemCategory: Record "Item Category";
        Caption: Text[250];
}

