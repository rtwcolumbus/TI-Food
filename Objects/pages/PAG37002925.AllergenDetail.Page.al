page 37002925 "Allergen Detail"
{
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens

    Caption = 'Allergen Detail';
    DataCaptionExpression = PageCaption;
    Editable = false;
    PageType = Worksheet;
    SourceTable = "Allergen Detail";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Allergen Code"; "Allergen Code")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = NOT First;
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Allergen Description"; "Allergen Description")
                {
                    ApplicationArea = FOODBasic;
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field(SourceNo; SourceNo)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Source No.';
                }
                field(SourceDescription; SourceDescription)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Description';
                }
                field(Presence; Presence)
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
    }

    var
        Text001: Label '·';
        PageCaption: Text;

    procedure SetSource(SourceRec: Variant)
    var
        Item: Record Item;
        ProductionBOMHeader: Record "Production BOM Header";
        ProductionBOMVersion: Record "Production BOM Version";
        SourceRecRef: RecordRef;
        AllergenRollup: Codeunit "Allergen Rollup";
    begin
        AllergenRollup.GetAllergenDetail(SourceRec, Rec);
        Commit;

        SourceRecRef.GetTable(SourceRec);
        case SourceRecRef.Number of
            DATABASE::Item:
                begin
                    Item := SourceRec;
                    PageCaption := StrSubstNo('%2 %1 %3 %1 %4', Text001, Item.TableCaption, Item."No.", Item.Description);
                end;
            DATABASE::"Production BOM Header":
                begin
                    ProductionBOMHeader := SourceRec;
                    PageCaption := StrSubstNo('%2 %1 %3 %1 %4', Text001, ProductionBOMHeader.TableCaption, ProductionBOMHeader."No.", ProductionBOMHeader.Description);
                end;
            DATABASE::"Production BOM Version":
                begin
                    ProductionBOMVersion := SourceRec;
                    ProductionBOMHeader.Get(ProductionBOMVersion."Production BOM No.");
                    PageCaption := StrSubstNo('%2 %1 %3 %1 %4 %1 %5', Text001, ProductionBOMVersion.TableCaption,
                      ProductionBOMVersion."Production BOM No.", ProductionBOMHeader.Description, ProductionBOMVersion."Version Code");
                end;
        end;
    end;
}

