page 5401 "Item Variants"
{
    // PR2.00.05
    //   Added controls for unit of measure and production BOM
    //   Added Menu Item to Variant button for creating Variant Variables
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    //
    // PRW116.00.05
    // P800103616, To-Increase, Gangabhushan, 04 FEB 21
    //  Enhance inventory costing with Book Cost      

    Caption = 'Item Variants';
    DataCaptionFields = "Item No.";
    PageType = List;
    SourceTable = "Item Variant";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Item No."; "Item No.")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the number of the item card from which you opened the Item Variant Translations window.';
                    Visible = false;
                }
                field("Code"; Code)
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies a code to identify the variant.';
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Production BOM No."; "Production BOM No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies text that describes the item variant.';
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the item variant in more detail than the Description field.';
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            part(ItemDetFactBox; "ItemDetailsCostBasis Factbox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "Item No." = FIELD("Item No."),
                                "Variant Code" = FIELD(Code);
                Visible = false;
            }            
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("V&ariant")
            {
                Caption = 'V&ariant';
                Image = ItemVariant;
                action(Translations)
                {
                    ApplicationArea = Planning;
                    Caption = 'Translations';
                    Image = Translations;
                    RunObject = Page "Item Translations";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD(Code);
                    ToolTip = 'View or edit translated item descriptions. Translated item descriptions are automatically inserted on documents according to the language code.';
                }
                action("Item Variant Variable")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Variant Variable';
                    Image = ItemVariant;
                    RunObject = Page "Item Variant Variable";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD(Code);
                }
            }
        }
    }

    procedure GetSelectionFilter(): Text
    var
        ItemVariant: Record "Item Variant";
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
    begin
        CurrPage.SetSelectionFilter(ItemVariant);
        exit(SelectionFilterManagement.GetSelectionFilterForItemVariant(ItemVariant));
    end;
}

