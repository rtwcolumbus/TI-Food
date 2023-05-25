table 5722 "Item Category"
{
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Add field for lot age profile
    // 
    // PR4.00.02
    // P8000312A, VerticalSoft, Jack Reynolds, 17 MAR 06
    //   Add field for Usage Formula
    // 
    // PRW16.00.05
    // P8000931, Columbus IT, Jack Reynolds, 20 APR 11
    //   Support for Supply Chain Groups
    // 
    // PRW17.10
    // P8001230, Columbus IT, Jack Reynolds, 18 OCT 13
    //   Support for approved vendors
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group

    Caption = 'Item Category';
    LookupPageID = "Item Categories";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; "Parent Category"; Code[20])
        {
            Caption = 'Parent Category';
            TableRelation = "Item Category";

            trigger OnValidate()
            var
                ItemCategory: Record "Item Category";
                ItemAttributeManagement: Codeunit "Item Attribute Management";
                ParentCategory: Code[20];
            begin
                ParentCategory := "Parent Category";
                while ItemCategory.Get(ParentCategory) do begin
                    if ItemCategory.Code = Code then
                        Error(CyclicInheritanceErr);
                    ParentCategory := ItemCategory."Parent Category";
                end;
                // P8007749
                if not xRec.VendorApprovalRequired then
                    if VendorApprovalRequired then
                        CheckApprovedVendorForItem;
                // P8007749

                if "Parent Category" <> xRec."Parent Category" then
                    ItemAttributeManagement.UpdateCategoryAttributesAfterChangingParentCategory(Code, "Parent Category", xRec."Parent Category");
            end;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(9; Indentation; Integer)
        {
            Caption = 'Indentation';
            MinValue = 0;
        }
        field(10; "Presentation Order"; Integer)
        {
            Caption = 'Presentation Order';
        }
        field(11; "Has Children"; Boolean)
        {
            Caption = 'Has Children';
        }
        field(12; "Last Modified Date Time"; DateTime)
        {
            Caption = 'Last Modified Date Time';
            Editable = false;
        }
        field(8000; Id; Guid)
        {
            Caption = 'Id';
            ObsoleteState = Pending;
            ObsoleteReason = 'This functionality will be replaced by the systemID field';
            ObsoleteTag = '15.0';
        }
        field(37002000; "Vendor Approval Required"; Option)
        {
            Caption = 'Vendor Approval Required';
            OptionCaption = ' ,No,Yes';
            OptionMembers = " ",No,Yes;

            trigger OnValidate()
            begin
                // P8001230, P8007749
                if not xRec.VendorApprovalRequired then
                    if VendorApprovalRequired then
                        CheckApprovedVendorForItem;
            end;
        }
        field(37002015; "Supply Chain Group Code"; Code[10])
        {
            Caption = 'Supply Chain Group Code';
            TableRelation = "Supply Chain Group";
        }
        field(37002020; "Lot Age Profile Code"; Code[10])
        {
            Caption = 'Lot Age Profile Code';
            TableRelation = "Lot Age Profile";
        }
        field(37002040; "Price Rounding Method"; Code[10])
        {
            Caption = 'Price Rounding Method';
            TableRelation = "Rounding Method";
        }
        field(37002041; "Usage Formula"; Code[10])
        {
            Caption = 'Usage Formula';
            TableRelation = "Usage Formula";
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
        key(Key2; "Parent Category")
        {
        }
        key(Key3; "Presentation Order")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if HasChildren() then
            Error(DeleteWithChildrenErr);
        UpdateDeletedCategoryItems();
        DeleteAssignedAttributes();
    end;

    trigger OnInsert()
    begin
        TestField(Code);
        UpdateIndentation();
        ItemCategoryManagement.CalcPresentationOrder(Rec);
        "Last Modified Date Time" := CurrentDateTime;
    end;

    trigger OnModify()
    begin
        UpdateIndentation();
        ItemCategoryManagement.CalcPresentationOrder(Rec);
        "Last Modified Date Time" := CurrentDateTime;
    end;

    trigger OnRename()
    begin
        "Presentation Order" := 0;
        "Last Modified Date Time" := CurrentDateTime;
    end;

    var
        ItemCategoryManagement: Codeunit "Item Category Management";

        CyclicInheritanceErr: Label 'An item category cannot be a parent of itself or any of its children.';
        DeleteWithChildrenErr: Label 'You cannot delete this item category because it has child item categories.';
        DeleteItemInheritedAttributesQst: Label 'One or more items belong to item category ''''%1''''.\\Do you want to delete the inherited item attributes for the items in question? ', Comment = '%1 - item category code';

    procedure HasChildren(): Boolean
    var
        ItemCategory: Record "Item Category";
    begin
        ItemCategory.SetRange("Parent Category", Code);
        exit(not ItemCategory.IsEmpty)
    end;

    procedure GetStyleText(): Text
    begin
        if Indentation = 0 then
            exit('Strong');

        if HasChildren() then
            exit('Strong');

        exit('');
    end;

    local procedure UpdateDeletedCategoryItems()
    var
        CategoryItem: Record Item;
        TempCategoryItemAttributeValue: Record "Item Attribute Value" temporary;
        ItemAttributeManagement: Codeunit "Item Attribute Management";
        DeleteItemInheritedAttributes: Boolean;
    begin
        CategoryItem.SetRange("Item Category Code", Code);
        if CategoryItem.IsEmpty() then
            exit;
        DeleteItemInheritedAttributes := Confirm(StrSubstNo(DeleteItemInheritedAttributesQst, Code));
        if DeleteItemInheritedAttributes then
            TempCategoryItemAttributeValue.LoadCategoryAttributesFactBoxData(Code);
        if CategoryItem.Find('-') then
            repeat
                CategoryItem.Validate("Item Category Code", '');
                CategoryItem.Modify();
                if DeleteItemInheritedAttributes then
                    ItemAttributeManagement.DeleteItemAttributeValueMapping(CategoryItem, TempCategoryItemAttributeValue);
            until CategoryItem.Next() = 0;
    end;

    local procedure DeleteAssignedAttributes()
    var
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
    begin
        ItemAttributeValueMapping.SetRange("Table ID", DATABASE::"Item Category");
        ItemAttributeValueMapping.SetRange("No.", Code);
        ItemAttributeValueMapping.DeleteAll();
    end;

    local procedure UpdateIndentation()
    var
        ParentItemCategory: Record "Item Category";
    begin
        if ParentItemCategory.Get("Parent Category") then
            UpdateIndentationTree(ParentItemCategory.Indentation + 1)
        else
            UpdateIndentationTree(0);
    end;

    [Scope('OnPrem')]
    procedure UpdateIndentationTree(Level: Integer)
    var
        ItemCategory: Record "Item Category";
    begin
        Indentation := Level;

        ItemCategory.SetRange("Parent Category", Code);
        if ItemCategory.FindSet() then
            repeat
                ItemCategory.UpdateIndentationTree(Level + 1);
                ItemCategory.Modify();
            until ItemCategory.Next() = 0;
    end;

    procedure VendorApprovalRequired(): Boolean
    var
        ItemCategory: Record "Item Category";
    begin
        // P8007749
        if "Vendor Approval Required" <> "Vendor Approval Required"::" " then
            exit("Vendor Approval Required" = "Vendor Approval Required"::Yes);

        if "Parent Category" <> '' then begin
            ItemCategory.Get("Parent Category");
            exit(ItemCategory.VendorApprovalRequired);
        end;
    end;

    procedure CheckApprovedVendorForItem()
    var
        Item: Record Item;
        ItemCategory: Record "Item Category";
    begin
        // P8007749
        Item.SetRange("Item Category Code", Code);
        Item.SetRange("Vendor Approval Required", Item."Vendor Approval Required"::" ");
        if Item.FindSet then
            repeat
                Item.CheckApprovedVendor;
                Item.CheckSKUApprovedVendor;
                Item.CheckDocumentApprovedVendor;
            until Item.Next = 0;

        ItemCategory.SetRange("Parent Category", Code);
        ItemCategory.SetRange("Vendor Approval Required", ItemCategory."Vendor Approval Required"::" ");
        if ItemCategory.FindSet then
            repeat
                ItemCategory.CheckApprovedVendorForItem;
            until ItemCategory.Next = 0;
    end;

    procedure GetSupplyChainGroupCode(): Code[10]
    begin
        // P8007749
        exit(GetNonEmptyCodeField(FieldNo("Supply Chain Group Code")));
    end;

    procedure GetLotAgeProfileCode(): Code[10]
    begin
        // P8007749
        exit(GetNonEmptyCodeField(FieldNo("Lot Age Profile Code")));
    end;

    procedure GetPriceRoundingMethod(): Code[10]
    begin
        // P8007749
        exit(GetNonEmptyCodeField(FieldNo("Price Rounding Method")));
    end;

    procedure GetUsageFormula(): Code[10]
    begin
        // P8007749
        exit(GetNonEmptyCodeField(FieldNo("Usage Formula")));
    end;

    procedure GetNonEmptyCodeField(FldNo: Integer): Code[20]
    var
        ItemCategory: Record "Item Category";
        CodeFieldValue: Code[20];
    begin
        // P8007749
        CodeFieldValue := GetCodeFieldValue(FldNo);
        if CodeFieldValue <> '' then
            exit(CodeFieldValue);

        if "Parent Category" <> '' then begin
            ItemCategory.Get("Parent Category");
            exit(ItemCategory.GetNonEmptyCodeField(FldNo));
        end;
    end;

    local procedure GetCodeFieldValue(FldNo: Integer): Code[20]
    begin
        // P8007749
        case FldNo of
            FieldNo("Supply Chain Group Code"):
                exit("Supply Chain Group Code");
            FieldNo("Lot Age Profile Code"):
                exit("Lot Age Profile Code");
            FieldNo("Price Rounding Method"):
                exit("Price Rounding Method");
            FieldNo("Usage Formula"):
                exit("Usage Formula");
        end;
    end;

    procedure MarkDesscendants(var ItemCategory: Record "Item Category")
    var
        ItemCategory2: Record "Item Category";
    begin
        // P8007749
        ItemCategory2.CopyFilters(ItemCategory);
        ItemCategory2 := ItemCategory;

        ItemCategory.SetFilter("Parent Category", Code);

        if ItemCategory.FindSet then
            repeat
                ItemCategory.Mark(true);
                ItemCategory.MarkDesscendants(ItemCategory);
            until ItemCategory.Next = 0;

        ItemCategory.CopyFilters(ItemCategory2);
        ItemCategory := ItemCategory2;
    end;

    procedure GetExtendedDescription() ExtendedDescription: Text
    var
        ItemCategory: Record "Item Category";
    begin
        // P8007749
        if Description <> '' then
            ExtendedDescription := Description
        else
            ExtendedDescription := Code;

        if "Parent Category" <> '' then begin
            ItemCategory.Get("Parent Category");
            ExtendedDescription := ItemCategory.GetExtendedDescription + ' / ' + ExtendedDescription;
        end;
    end;

    procedure GetAncestorFilterString(IncludeCurrentCategory: Boolean) FilterString: Text
    var
        ItemCategory: Record "Item Category";
    begin
        // P8007749
        if IncludeCurrentCategory then
            FilterString := '|' + Code;

        ItemCategory := Rec;
        while ItemCategory."Parent Category" <> '' do begin
            FilterString := '|' + ItemCategory."Parent Category" + FilterString;
            ItemCategory.Get(ItemCategory."Parent Category");
        end;

        FilterString := CopyStr(FilterString, 2);
    end;

    procedure PresentationRange(var "Min": Integer; var "Max": Integer)
    var
        ItemCategory: Record "Item Category";
    begin
        // P8007749
        Min := "Presentation Order";
        ItemCategory := Rec;
        ItemCategory.SetCurrentKey("Presentation Order");
        ItemCategory.SetFilter(Indentation, '<=%1', ItemCategory.Indentation);
        if ItemCategory.Next = 0 then
            Max := ItemCategory."Presentation Order"
        else
            Max := ItemCategory."Presentation Order" - 1;
    end;
}

