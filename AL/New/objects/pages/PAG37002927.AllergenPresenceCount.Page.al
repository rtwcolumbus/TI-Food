page 37002927 "Allergen Presence-Count"
{
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens

    Caption = 'Allergen Presence-Count';
    PageType = CardPart;

    layout
    {
        area(content)
        {
            field(Item; GetCount(0))
            {
                ApplicationArea = FOODBasic;
                CaptionClass = GetTypeCaption(0);
                Caption = 'Item';
                Style = Strong;
                StyleExpr = TypeToDisplay = 0;

                trigger OnDrillDown()
                begin
                    SetTypeToDisplay(0);
                end;
            }
            field(Unapproved; GetCount(1))
            {
                ApplicationArea = FOODBasic;
                CaptionClass = GetTypeCaption(1);
                Caption = 'Unapproved';
                Style = Strong;
                StyleExpr = TypeToDisplay = 1;

                trigger OnDrillDown()
                begin
                    SetTypeToDisplay(1);
                end;
            }
            field(BOM; GetCount(2))
            {
                ApplicationArea = FOODBasic;
                CaptionClass = GetTypeCaption(2);
                Caption = 'BOM';
                Style = Strong;
                StyleExpr = TypeToDisplay = 2;

                trigger OnDrillDown()
                begin
                    SetTypeToDisplay(2);
                end;
            }
        }
    }

    actions
    {
    }

    var
        [InDataSet]
        TypeToDisplay: Integer;
        AllergenPresence: Record "Allergen Presence" temporary;

    procedure SetData(var AllergenPresenceCount: Record "Allergen Presence" temporary)
    begin
        AllergenPresence.Copy(AllergenPresenceCount, true);
    end;

    local procedure GetCount(Type: Integer): Integer
    begin
        AllergenPresence.Get(Type);
        exit(AllergenPresence."Record Count");
    end;

    local procedure GetTypeCaption(Type: Integer): Text
    begin
        AllergenPresence.Get(Type);
        exit(StrSubstNo('3,%1', AllergenPresence.Type));
    end;

    local procedure SetTypeToDisplay(Type: Integer)
    begin
        if 0 = GetCount(Type) then
            exit;

        TypeToDisplay := Type;
        CurrPage.Update;
    end;

    procedure GetTypeTodisplay(): Integer
    begin
        exit(TypeToDisplay);
    end;
}

