page 37002930 "Allergen Factbox"
{
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens

    Caption = 'Allergens';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "Allergen Set Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Allergen Code"; "Allergen Code")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Code';
                }
                field("Allergen Description"; "Allergen Description")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Description';
                }
                field(Presence; Presence)
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnFindRecord(Which: Text): Boolean
    var
        AllergenManagement: Codeunit "Allergen Management";
        "Filter": Text;
        TableNo: Integer;
        Type: Integer;
        No: Code[20];
    begin
        FilterGroup(4);
        Filter := GetFilter("Table No. Filter");
        if Filter <> '' then
            Evaluate(TableNo, Filter);
        Filter := GetFilter("Type Filter");
        if Filter <> '' then
            Evaluate(Type, Filter);
        Filter := GetFilter("No. Filter");
        if Filter <> '' then
            Evaluate(No, Filter);
        SetRange("Allergen Set ID", AllergenManagement.TableTypeNo2AllergentSetID(TableNo, Type, No));
        FilterGroup(0);

        exit(Find(Which));
    end;
}

