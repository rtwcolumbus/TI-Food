page 37002926 "Allergen Presence"
{
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens

    Caption = 'Allergen Presence';
    DataCaptionExpression = PageCaption;
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "Allergen Presence";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control37002004)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                    Style = Strong;
                    StyleExpr = Direct;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    Style = Strong;
                    StyleExpr = Direct;
                }
                field(Presence; Presence)
                {
                    ApplicationArea = FOODBasic;
                    Style = Strong;
                    StyleExpr = Direct;
                }
            }
        }
        area(factboxes)
        {
            part("Count"; "Allergen Presence-Count")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Count';
                UpdatePropagation = Both;
            }
        }
    }

    actions
    {
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        FilterGroup(9);
        SetRange(Type, CurrPage.Count.PAGE.GetTypeTodisplay);
        FilterGroup(0);
        exit(FindFirst);
    end;

    var
        Text001: Label '·';
        PageCaption: Text;

    procedure SetAllergen(Allergen: Record Allergen)
    var
        AllergenPresenceCount: Record "Allergen Presence" temporary;
        AllergenManagement: Codeunit "Allergen Management";
        Type: Integer;
    begin
        AllergenManagement.GetAllergenPresence(Allergen.Code, Rec);
        for Type := 0 to 2 do begin
            SetRange(Type, Type);
            AllergenPresenceCount.Type := Type;
            AllergenPresenceCount."Record Count" := Count;
            AllergenPresenceCount.Insert;
        end;
        CurrPage.Count.PAGE.SetData(AllergenPresenceCount);

        Reset;
        PageCaption := StrSubstNo('%2 %1 %3', Text001, Allergen.Code, Allergen.Description);
    end;
}

