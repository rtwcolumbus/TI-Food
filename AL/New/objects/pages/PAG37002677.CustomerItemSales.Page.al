page 37002677 "Customer/Item Sales"
{
    // PR4.00
    // P8000248B, Myers Nissi, Jack Reynolds, 07 OCT 05
    //   List form for customer/item sales history
    //   Also lookup form from credit memo and return order line
    // 
    // P8000761, VerticalSoft, Maria Maslennikova, 03 FEB 10
    //   Make page work correctly, methods changed:
    //     OnOpenPage()
    //     SetVariables()
    // 
    // PRW16.00.05
    // P8000944, Columbus IT, Jack Reynolds, 31 MAY 11
    //   Support for enahnced terminal market order entry
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 19 FEB 13
    //   Restoring the SaveValues Property.
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018

    Caption = 'Customer/Item Sales';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Item Ledger Entry";
    SourceTableView = SORTING("Entry Type", "Item No.", "Variant Code", "Source Type", "Source No.", "Posting Date")
                      WHERE("Source Type" = CONST(Customer),
                            "Entry Type" = CONST(Sale),
                            Positive = CONST(false));

    layout
    {
        area(content)
        {
            group(Control37002000)
            {
                ShowCaption = false;
                field(CustomerNo; CustomerNo)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Customer No.';
                    Editable = CustomerNoEditable;
                    TableRelation = Customer;

                    trigger OnValidate()
                    begin
                        CustomerNoOnAfterValidate;
                    end;
                }
                field("Customer.Name"; Customer.Name)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(Control37002001)
            {
                ShowCaption = false;
                field(ItemNo; ItemNo)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item No.';
                    Editable = ItemNoEditable;
                    TableRelation = Item;

                    trigger OnValidate()
                    begin
                        ItemNoOnAfterValidate;
                    end;
                }
                field("Item.Description"; Item.Description)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(Control37002002)
            {
                ShowCaption = false;
                field(DaysView; DaysView)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Days View';
                    MinValue = 1;

                    trigger OnValidate()
                    begin
                        DaysViewOnAfterValidate;
                    end;
                }
            }
            repeater(Control37002003)
            {
                Editable = false;
                ShowCaption = false;
                field("Source No."; "Source No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Customer  No.';
                    Visible = SourceNoVisible;
                }
                field(CustomerName; SourceName)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Customer Name';
                    Visible = CustomerNameVisible;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = ItemNoVisible;
                }
                field(ItemDescription; ItemDesc)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Description';
                    Visible = ItemDescriptionVisible;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(SalesQuantity; SalesQuantity)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Quantity';
                    DecimalPlaces = 0 : 5;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(SalesUnitPrice; SalesUnitPrice)
                {
                    ApplicationArea = FOODBasic;
                    AutoFormatType = 2;
                    Caption = 'Unit Price';
                    DecimalPlaces = 2 : 5;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        ItemNoEditable := true;
        CustomerNoEditable := true;
        ItemDescriptionVisible := true;
        ItemNoVisible := true;
        CustomerNameVisible := true;
        SourceNoVisible := true;
    end;

    trigger OnOpenPage()
    begin
        GLSetup.Get;

        Clear(Customer);
        Clear(Item);
        //P8000761 MMAS >>
        //IF xRec.Positive THEN BEGIN
        //  VariablesPassed := TRUE;
        //  CustomerNo := xRec."Source No.";
        //  ItemNo := xRec."Item No.";
        //END;
        if PageFiltersSet then begin
            VariablesPassed := true;
            CustomerNo := PageFilters[1];
            ItemNo := PageFilters[2];
        end;
        //P8000761 MMAS <<

        SetCustomer;
        SetItem;
        SetDaysView;
    end;

    var
        GLSetup: Record "General Ledger Setup";
        Customer: Record Customer;
        Item: Record Item;
        CustomerNo: Code[20];
        ItemNo: Code[20];
        DaysView: Integer;
        Text001: Label '%1 %2 must be specified.';
        VariablesPassed: Boolean;
        [InDataSet]
        SourceNoVisible: Boolean;
        [InDataSet]
        CustomerNameVisible: Boolean;
        [InDataSet]
        ItemNoVisible: Boolean;
        [InDataSet]
        ItemDescriptionVisible: Boolean;
        [InDataSet]
        CustomerNoEditable: Boolean;
        [InDataSet]
        ItemNoEditable: Boolean;
        PageFilters: array[5] of Code[20];
        PageFiltersSet: Boolean;

    procedure SetVariables(CustNo: Code[20]; ItemNo: Code[20])
    begin
        //P8000761 MMAS >>
        //xRec.Positive := TRUE; // Used to indicate filters have been passed
        //xRec."Source No." := CustNo;
        //xRec."Item No." := ItemNo;
        PageFiltersSet := true;
        PageFilters[1] := CustNo;
        PageFilters[2] := ItemNo;
        //P8000761 MMAS <<
    end;

    procedure SetCustomer()
    begin
        if CustomerNo <> '' then begin
            Customer.Get(CustomerNo);
            SetRange("Source No.", CustomerNo);
        end else begin
            Clear(Customer);
            SetRange("Source No.");
        end;

        if VariablesPassed and (CustomerNo <> '') then begin
            CustomerNoEditable := false;
            SourceNoVisible := false;
            CustomerNameVisible := false;
        end else begin
            SourceNoVisible := true;
            CustomerNameVisible := true;
        end;
        CurrPage.Update(false);
    end;

    procedure SetItem()
    begin
        if ItemNo <> '' then begin
            Item.Get(ItemNo);
            SetRange("Item No.", ItemNo);
        end else begin
            Clear(Item);
            SetRange("Item No.");
        end;

        if VariablesPassed and (ItemNo <> '') then begin
            ItemNoEditable := false;
            ItemNoVisible := false;
            ItemDescriptionVisible := false;
        end else begin
            ItemNoVisible := true;
            ItemDescriptionVisible := true;
        end;
        CurrPage.Update(false);
    end;

    procedure SetDaysView()
    begin
        if DaysView = 0 then
            DaysView := 14;
        SetRange("Posting Date", Today - DaysView, DMY2Date(31, 12, 9999)); // P8007748

        CurrPage.Update(false);
    end;

    local procedure CustomerNoOnAfterValidate()
    begin
        SetCustomer;
    end;

    local procedure ItemNoOnAfterValidate()
    begin
        SetItem;
    end;

    local procedure DaysViewOnAfterValidate()
    begin
        SetDaysView;
    end;
}

