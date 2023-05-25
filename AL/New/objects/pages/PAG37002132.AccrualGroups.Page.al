page 37002132 "Accrual Groups"
{
    // PR3.61AC
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 08 FEB 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 16 NOV 15
    //   Page Management

    Caption = 'Accrual Groups';
    Editable = false;
    PageType = List;
    SourceTable = "Accrual Group";

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
            action(Setup)
            {
                ApplicationArea = FOODBasic;
                Caption = '&Setup';
                Ellipsis = true;

                trigger OnAction()
                var
                    PageManagement: Codeunit "Page Management";
                begin
                    // P8004516
                    PageManagement.PageRunModal(Rec);
                end;
            }
        }
        area(Promoted)
        {
                actionref(Setup_Promoted; Setup)
                {
                }
        }
    }

    trigger OnOpenPage()
    begin
        TypeFilter := GetFilter(Type);
        SetRange(Type);
        FilterGroup(2);
        if (TypeFilter <> '') then
            SetFilter(Type, TypeFilter)
        else
            TypeFilter := GetFilter(Type);
        FilterGroup(0);

        if (TypeFilter <> '') then
            CurrPage.Caption := StrSubstNo('%1 %2', TypeFilter, CurrPage.Caption);
    end;

    var
        TypeFilter: Text[30];
}

