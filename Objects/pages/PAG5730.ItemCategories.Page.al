page 5730 "Item Categories"
{
    // PR3.60
    //   Sales Pricing
    // 
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Add controls for lot age profile
    // 
    // PR3.70.10
    // P8000237A, Myers Nissi, Jack Reynolds, 04 AUG 05
    //   Non-editable if run in lookup mode
    // 
    // PR4.00.02
    // P8000312A, VerticalSoft, Jack Reynolds, 17 MAR 06
    //   Add control for usage formula
    // 
    // PR5.00
    // P8000545A, VerticalSoft, Don Bresee, 13 NOV 07
    //   Add Cust./Item Price/Disc. Groups to Sales menu button
    // 
    // PRW16.00.05
    // P8000931, Columbus IT, Jack Reynolds, 20 APR 11
    //   Support for Supply Chain Groups
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001019, Columbus IT, Jack Reynolds, 16 JAN 12
    //   Account Schedule - Item Units
    // 
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.10
    // P8001230, Columbus IT, Jack Reynolds, 18 OCT 13
    //   Support for approved vendors
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group

    ApplicationArea = Basic, Suite;
    Caption = 'Item Categories';
    CardPageID = "Item Category Card";
    InsertAllowed = false;
    PageType = List;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "Item Category";
    SourceTableView = SORTING("Presentation Order");
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                IndentationColumn = Indentation;
                IndentationControls = "Code";
                ShowAsTree = true;
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the code for the item category.';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                        CurrPage.ItemAttributesFactbox.PAGE.LoadCategoryAttributesData(Code);
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the item category.';
                }
            }
        }
        area(factboxes)
        {
            part(ItemAttributesFactbox; "Item Attributes Factbox")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attributes';
            }
        }
    }

    actions
    {
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
                separator(Separator37002002)
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
        area(creation)
        {
            action(Recalculate)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Recalculate';
                Image = Hierarchy;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Update the tree of item categories based on recent changes.';

                trigger OnAction()
                begin
                    ItemCategoryManagement.UpdatePresentationOrder();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        StyleTxt := GetStyleText;
        CurrPage.ItemAttributesFactbox.PAGE.LoadCategoryAttributesData(Code);
    end;

    trigger OnAfterGetRecord()
    begin
        StyleTxt := GetStyleText;
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        StyleTxt := GetStyleText;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        StyleTxt := GetStyleText;
    end;

    trigger OnOpenPage()
    begin
        ItemCategoryManagement.CheckPresentationOrder();
        CurrPage.Editable(not CurrPage.LookupMode); // P8000237A
    end;

    protected var
        ItemCategoryManagement: Codeunit "Item Category Management";
        StyleTxt: Text;

    procedure GetSelectionFilter(): Text
    var
        ItemCategory: Record "Item Category";
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
    begin
        CurrPage.SetSelectionFilter(ItemCategory);
        exit(SelectionFilterManagement.GetSelectionFilterForItemCategory(ItemCategory));
    end;

    procedure SetSelection(var ItemCategory: Record "Item Category")
    begin
        CurrPage.SetSelectionFilter(ItemCategory);
    end;
}

