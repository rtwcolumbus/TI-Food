page 37002923 "Allergen Set History"
{
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens

    Caption = 'Allergen Set History';
    DataCaptionExpression = PageCaption;
    Editable = false;
    LinksAllowed = false;
    PageType = Worksheet;
    SourceTable = "Allergen Set History";
    SourceTableView = SORTING("Entry No.")
                      ORDER(Descending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Date and Time"; "Date and Time")
                {
                    ApplicationArea = FOODBasic;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Control37002004)
            {
                ShowCaption = false;
                part(OldAllergenSet; "Allergen Set History Subpage")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Old Allergen Set';
                    SubPageLink = "Allergen Set ID" = FIELD("Old Allergen Set ID");
                }
                part(NewAllergenSet; "Allergen Set History Subpage")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'New Allergen Set';
                    SubPageLink = "Allergen Set ID" = FIELD("New Allergen Set ID");
                }
            }
        }
    }

    actions
    {
    }

    trigger OnFindRecord(Which: Text): Boolean
    var
        Item: Record Item;
        UnapprovedItem: Record "Unapproved Item";
        ProductionBOMHeader: Record "Production BOM Header";
        ProductionBOMVersion: Record "Production BOM Version";
        Found: Boolean;
    begin
        Found := FindFirst;
        if Found then begin
            case "Table No." of
                DATABASE::Item:
                    begin
                        Item.Get("Code 1");
                        PageCaption := StrSubstNo('%2 %1 %3 %1 %4', Text001, Item.TableCaption, "Code 1", Item.Description);
                    end;
                DATABASE::"Unapproved Item":
                    begin
                        UnapprovedItem.Get("Code 1");
                        PageCaption := StrSubstNo('%2 %1 %3 %1 %4', Text001, UnapprovedItem.TableCaption, "Code 1", UnapprovedItem.Description);
                    end;
                DATABASE::"Production BOM Version":
                    begin
                        ProductionBOMHeader.Get("Code 1");
                        PageCaption := StrSubstNo('%2 %1 %3 %1 %4 %1 %5', Text001, ProductionBOMVersion.TableCaption, "Code 1", ProductionBOMHeader.Description, "Code 2");
                    end;
            end;
        end;

        exit(Found);
    end;

    var
        PageCaption: Text;
        Text001: Label '·';
}

