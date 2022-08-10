page 37002502 "Create Item From BOM"
{
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 02 FEB 09
    //   Transformed from Form
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group

    Caption = 'Create Item From BOM';
    PageType = Card;

    layout
    {
        area(content)
        {
            field("InputItem.""No."""; InputItem."No.")
            {
                ApplicationArea = FOODBasic;
                Caption = 'No.';

                trigger OnAssistEdit()
                begin
                    if InputItem.AssistEdit then
                        CurrPage.Update;
                end;

                trigger OnValidate()
                begin
                    if Item.Get(InputItem."No.") then
                        Error(Text002, Item.TableCaption, Item.FieldCaption("No."), InputItem."No.");
                    InputItem.Validate("No.");
                end;
            }
            field("InputItem.Description"; InputItem.Description)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Description';
                Editable = false;
            }
            field("InputItem.""Item Type"""; InputItem."Item Type")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Item Type';
                OptionCaption = ' ,Raw Material,Packaging,Intermediate,Finished Good,Container';
            }
            field(TemplateCode; TemplateCode)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Template Code';
                TableRelation = "Config. Template Header".Code WHERE("Table ID" = CONST(27),
                                                                      Enabled = CONST(true));
            }
            field("InputItem.""Manufacturing Policy"""; InputItem."Manufacturing Policy")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Manufacturing Policy';
                OptionCaption = 'Make-to-Stock,Make-to-Order';
            }
            field(DisplayItemCard; DisplayItemCard)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Display Item Card';
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        CurrPage.Caption(StrSubstNo(Text001, Type));
    end;

    var
        InputItem: Record Item;
        Item: Record Item;
        Type: Text[30];
        TemplateCode: Code[10];
        DisplayItemCard: Boolean;
        Text001: Label 'Create Item From %1';
        Text002: Label '%1 %2 ''%3'' already exists.';

    procedure SetItem(rec: Record Item)
    begin
        InputItem := rec;
    end;

    procedure SetType(text: Text[30])
    begin
        Type := text;
    end;

    procedure GetItem(var rec: Record Item)
    begin
        rec := InputItem;
    end;

    procedure GetDisplayFlag(): Boolean
    begin
        exit(DisplayItemCard);
    end;

    procedure GetTemplateCode(): Code[10]
    begin
        // P8007749
        exit(TemplateCode);
    end;
}

