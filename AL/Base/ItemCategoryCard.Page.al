page 5733 "Item Category Card"
{
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group

    Caption = 'Item Category Card';
    DeleteAllowed = false;
    PageType = Card;
    RefreshOnActivate = true;
    SourceTable = "Item Category";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Code)
                {
                    ApplicationArea = Basic, Suite;
                    NotBlank = true;
                    ToolTip = 'Specifies the item category.';

                    trigger OnValidate()
                    begin
                        if (xRec.Code <> '') and (xRec.Code <> Code) then
                            CurrPage.Attributes.PAGE.SaveAttributes(Code);
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the item category.';
                }
                field("Parent Category"; "Parent Category")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the item category that this item category belongs to. Item attributes that are assigned to a parent item category also apply to the child item category.';

                    trigger OnValidate()
                    begin
                        if (Code <> '') and ("Parent Category" <> xRec."Parent Category") then
                            PersistCategoryAttributes;
                    end;
                }
                field("Vendor Approval Required"; "Vendor Approval Required")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Supply Chain Group Code"; "Supply Chain Group Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot Age Profile Code"; "Lot Age Profile Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Price Rounding Method"; "Price Rounding Method")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Usage Formula"; "Usage Formula")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            part(Attributes; "Item Category Attributes")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attributes';
                ShowFilter = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Delete)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Delete';
                Enabled = CanDelete;
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Delete the record.';

                trigger OnAction()
                begin
                    if Confirm(StrSubstNo(DeleteQst, Code)) then
                        Delete(true);
                end;
            }
        }
        area(navigation)
        {
            group("S&ales")
            {
                Caption = 'S&ales';
                action(Prices)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Prices';
                    Image = Price;
                    RunObject = Page "Enhanced Sales Prices";
                    RunPageLink = "Item Type" = CONST("Item Category"),
                                  "Item Code" = FIELD(Code);
                    RunPageView = SORTING("Item Type", "Item Code");
                }
                action("Price Templates")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Price Templates';
                    Image = Template;
                    RunObject = Page "Recurring Price Template Card";
                    RunPageLink = "Item Type" = CONST("Item Category"),
                                  "Item Code" = FIELD(Code);
                    RunPageView = SORTING("Item Type", "Item Code");
                }
                action("Line Discounts")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Line Discounts';
                    Image = LineDiscount;
                    RunObject = Page "Enhanced Sales Line Discounts";
                    RunPageLink = "Item Type" = CONST("Item Category"),
                                  "Item Code" = FIELD(Code);
                    RunPageView = SORTING("Item Type", "Item Code");
                }
                separator(Separator37002007)
                {
                }
                action("Cust./Item &Group Entry")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Cust./Item &Group Entry';
                    Image = Entry;

                    trigger OnAction()
                    var
                        GroupEntryForm: Page "Customer/Item Group Entry";
                    begin
                        // P8000545A
                        GroupEntryForm.SetGroupCodes(Code); // P8007749
                        GroupEntryForm.Run;
                    end;
                }
            }
            group("Data Collection")
            {
                Caption = 'Data Collection';
                action(DataCollectionTemplates)
                {
                    AccessByPermission = TableData "Data Collection Line" = R;
                    ApplicationArea = FOODBasic;
                    Caption = 'Data Collection Templates';
                    Image = Template;
                    RunObject = Page "Data Collection Template List";
                    RunPageLink = "Item Category Code" = FIELD(Code);
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if Code <> '' then
            CurrPage.Attributes.PAGE.LoadAttributes(Code);

        CanDelete := not HasChildren();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        CurrPage.Attributes.PAGE.SetItemCategoryCode(Code);
    end;

    trigger OnOpenPage()
    begin
        if Code <> '' then
            CurrPage.Attributes.PAGE.LoadAttributes(Code);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if Code <> '' then
            CurrPage.Attributes.PAGE.SaveAttributes(Code);

        ItemCategoryManagement.CheckPresentationOrder();
    end;

    var
        ItemCategoryManagement: Codeunit "Item Category Management";
        DeleteQst: Label 'Delete %1?', Comment = '%1 - item category name';
        CanDelete: Boolean;

    local procedure PersistCategoryAttributes()
    begin
        CurrPage.Attributes.PAGE.SaveAttributes(Code);
        CurrPage.Attributes.PAGE.LoadAttributes(Code);
        CurrPage.Update(true);
    end;
}

