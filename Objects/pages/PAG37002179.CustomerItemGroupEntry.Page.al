page 37002179 "Customer/Item Group Entry"
{
    // PR5.00
    // P8000545A, VerticalSoft, Don Bresee, 13 NOV 07
    //   New table for associations between customers and item categories/product groups
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 19 FEB 13
    //   Restoring the SaveValues Property.
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Customer/Item Group Entry';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = Customer;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            field("Item Category Code"; ItemCategoryCode)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Item Category Code';
                TableRelation = "Item Category";

                trigger OnLookup(var Text: Text): Boolean
                var
                    ItemCategoryList: Page "Item Categories";
                begin
                    ItemCategory.Reset;
                    ItemCategoryList.SetTableView(ItemCategory);
                    if (Text <> '') then begin
                        ItemCategory.Code := Text;
                        if ItemCategory.Find('=><') then
                            ItemCategoryList.SetRecord(ItemCategory);
                    end;
                    ItemCategoryList.LookupMode(true);
                    if (ItemCategoryList.RunModal <> ACTION::LookupOK) then
                        exit(false);
                    ItemCategoryList.GetRecord(ItemCategory);
                    Text := ItemCategory.Code;
                    exit(true);
                end;

                trigger OnValidate()
                begin
                    CurrPage.Update(false);
                end;
            }
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(Name; Name)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Customer Price Group"; CustPriceGroupCode)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Customer Price Group';
                    TableRelation = "Customer Price Group";

                    trigger OnValidate()
                    begin
                        SaveGroupCodes;
                    end;
                }
                field("Customer Disc. Group"; CustDiscGroupCode)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Customer Disc. Group';
                    TableRelation = "Customer Discount Group";

                    trigger OnValidate()
                    begin
                        SaveGroupCodes;
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        LoadGroupCodes;
    end;

    trigger OnAfterGetRecord()
    begin
        LoadGroupCodes;
    end;

    trigger OnOpenPage()
    begin
        if (ExtItemCategoryCode <> '') then
            ItemCategoryCode := ExtItemCategoryCode;
    end;

    var
        CustPriceGroupCode: Code[10];
        CustDiscGroupCode: Code[10];
        ItemCategoryCode: Code[20];
        ExtItemCategoryCode: Code[20];
        ItemCategory: Record "Item Category";
        CustItemGroup: Record "Cust./Item Price/Disc. Group";

    local procedure LoadGroupCodes()
    begin
        if (ItemCategoryCode = '') then begin
            CustPriceGroupCode := "Customer Price Group";
            CustDiscGroupCode := "Customer Disc. Group";
        end else
            if CustItemGroup.Get("No.", ItemCategoryCode) then begin // P8007749
                CustPriceGroupCode := CustItemGroup."Customer Price Group";
                CustDiscGroupCode := CustItemGroup."Customer Disc. Group";
            end else begin
                CustPriceGroupCode := '';
                CustDiscGroupCode := '';
            end;
    end;

    local procedure SaveGroupCodes()
    begin
        if (ItemCategoryCode = '') then begin
            "Customer Price Group" := CustPriceGroupCode;
            "Customer Disc. Group" := CustDiscGroupCode;
            CurrPage.SaveRecord;
        end else
            if CustItemGroup.Get("No.", ItemCategoryCode) then // P8007749
                if (CustPriceGroupCode = '') and (CustDiscGroupCode = '') then
                    CustItemGroup.Delete(true)
                else begin
                    CustItemGroup."Customer Price Group" := CustPriceGroupCode;
                    CustItemGroup."Customer Disc. Group" := CustDiscGroupCode;
                    CustItemGroup.Modify(true);
                end
            else
                if (CustPriceGroupCode <> '') or (CustDiscGroupCode <> '') then begin
                    CustItemGroup.Init;
                    CustItemGroup."Customer No." := "No.";
                    CustItemGroup."Item Category Code" := ItemCategoryCode;
                    CustItemGroup."Customer Price Group" := CustPriceGroupCode;
                    CustItemGroup."Customer Disc. Group" := CustDiscGroupCode;
                    CustItemGroup.Insert(true);
                end;
    end;

    procedure SetGroupCodes(NewItemCategoryCode: Code[20])
    begin
        // P8007749 - remove parameter NewProductGropCode
        ExtItemCategoryCode := NewItemCategoryCode;
    end;
}

