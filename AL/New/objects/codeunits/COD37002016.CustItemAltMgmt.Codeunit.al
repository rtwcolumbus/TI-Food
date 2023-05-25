codeunit 37002016 "Cust./Item Alt. Mgmt."
{
    // PRW15.00.01
    // P8000589A, VerticalSoft, Don Bresee, 05 MAR 08
    //   Add alternate sales items by Customer
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00


    trigger OnRun()
    begin
    end;

    var
        CustItemAlternate: Record "Customer Item Alternate";
        Text000: Label 'Item %1 is not allowed for Customer %2.';
        Text001: Label 'Customer %1 is setup to use Item %2 in place of Item %3.';
        Text002: Label 'Item %1 is not allowed for Customer %2. You must select an Alternate Item.';
        Text003: Label 'Item %1 has Alternate Items for Customer %2 that you can use instead.';

    procedure IsBlocked(CustNo: Code[20]; SalesItemNo: Code[20]): Boolean
    begin
        with CustItemAlternate do
            exit(Get(CustNo, SalesItemNo, ''));
    end;

    procedure SetBlocked(CustNo: Code[20]; SalesItemNo: Code[20]; SetBlocked: Boolean)
    begin
        with CustItemAlternate do
            if SetBlocked then begin
                if not IsBlocked(CustNo, SalesItemNo) then begin
                    Init;
                    "Customer No." := CustNo;
                    "Sales Item No." := SalesItemNo;
                    "Alternate Item No." := '';
                    Insert;
                end;
            end else begin
                if IsBlocked(CustNo, SalesItemNo) then
                    Delete;
            end;
    end;

    procedure HasAlternates(CustNo: Code[20]; SalesItemNo: Code[20]): Boolean
    begin
        with CustItemAlternate do begin
            Reset;
            FilterGroup(2);
            SetRange("Customer No.", CustNo);
            SetRange("Sales Item No.", SalesItemNo);
            SetFilter("Alternate Item No.", '<>%1', '');
            FilterGroup(0);
            exit(Find('-'));
        end;
    end;

    procedure SalesLineValidate(var SalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
    begin
        with SalesLine do
            if (Type = Type::Item) and ("No." <> '') then
                if SalesHeader.Get("Document Type", "Document No.") then
                    if (SalesHeader."Sell-to Customer No." <> '') then
                        ReplaceWithAltItem(SalesHeader."Sell-to Customer No.", "No.");
    end;

    local procedure ReplaceWithAltItem(CustNo: Code[20]; var SalesItemNo: Code[20])
    var
        RefItemNo: Code[20];
        ItemIsBlocked: Boolean;
        ItemHasAlternates: Boolean;
    begin
        if FindAltItem(CustNo, SalesItemNo, RefItemNo, ItemIsBlocked, ItemHasAlternates) then
            case true of
                ItemIsBlocked and ItemHasAlternates:
                    begin
                        if (RefItemNo = SalesItemNo) then
                            Message(Text002, SalesItemNo, CustNo)
                        else
                            Message('%1\\%2',
                              StrSubstNo(Text001, CustNo, RefItemNo, SalesItemNo),
                              StrSubstNo(Text002, RefItemNo, CustNo));
                        if not LookupAltItem(SalesItemNo) then
                            Error(Text000, SalesItemNo, CustNo);
                        ReplaceWithAltItem(CustNo, SalesItemNo);
                    end;
                ItemIsBlocked:
                    Error(Text000, SalesItemNo, CustNo);
                ItemHasAlternates:
                    begin
                        if (RefItemNo = SalesItemNo) then
                            Message(Text003, SalesItemNo, CustNo)
                        else
                            Message('%1\\%2',
                              StrSubstNo(Text001, CustNo, RefItemNo, SalesItemNo),
                              StrSubstNo(Text003, RefItemNo, CustNo));
                        if not LookupAltItem(SalesItemNo) then
                            SalesItemNo := RefItemNo
                        else
                            ReplaceWithAltItem(CustNo, SalesItemNo);
                    end;
                else begin
                        Message(Text001, CustNo, RefItemNo, SalesItemNo);
                        SalesItemNo := RefItemNo;
                    end;
            end;
    end;

    local procedure FindAltItem(CustNo: Code[20]; SalesItemNo: Code[20]; var RefItemNo: Code[20]; var ItemIsBlocked: Boolean; var ItemHasAlternates: Boolean): Boolean
    begin
        ItemIsBlocked := IsBlocked(CustNo, SalesItemNo);
        ItemHasAlternates := HasAlternates(CustNo, SalesItemNo);
        if not ItemIsBlocked then
            if not ItemHasAlternates then
                exit(false);
        RefItemNo := SalesItemNo;
        repeat
            ItemIsBlocked := IsBlocked(CustNo, RefItemNo);
            ItemHasAlternates := HasAlternates(CustNo, RefItemNo);
            if not ItemIsBlocked then
                exit(true);
            if not ItemHasAlternates then
                exit(true);
            if (CustItemAlternate.Next <> 0) then
                exit(true);
            RefItemNo := CustItemAlternate."Alternate Item No.";
        until false;
    end;

    local procedure LookupAltItem(var NewItemNo: Code[20]): Boolean
    var
        AltItemList: Page "Alternate Item List";
    begin
        with CustItemAlternate do begin
            Find('-');
            AltItemList.SetRecord(CustItemAlternate);
            AltItemList.SetTableView(CustItemAlternate);
            AltItemList.LookupMode(true);
            if (AltItemList.RunModal <> ACTION::LookupOK) then
                exit(false);
            AltItemList.GetRecord(CustItemAlternate);
            NewItemNo := CustItemAlternate."Alternate Item No.";
            exit(true);
        end;
    end;

    procedure LookupCustomer(var Text: Text[1024]): Boolean
    var
        Customer: Record Customer;
        CustomerFound: Boolean;
    begin
        // P80066030
        if (Text <> '') then begin
            Customer.SetFilter("No.", UpperCase(Text) + '*');
            CustomerFound := Customer.FindFirst;
            if CustomerFound and (Customer."No." = UpperCase(Text)) then
                Customer.SetRange("No.")
            else begin
                Customer.SetFilter("No.", '*' + UpperCase(Text) + '*');
                if not CustomerFound then
                    Customer.FindFirst;
            end;
        end;
        exit(PresentCustomerList(Customer, Text));
    end;

    local procedure PresentCustomerList(var Customer: Record Customer; var Text: Text[1024]): Boolean
    var
        CustomerList: Page "Customer List";
    begin
        // P80066030
        if (Customer."No." <> '') then
            CustomerList.SetRecord(Customer);
        CustomerList.SetTableView(Customer);
        CustomerList.LookupMode(true);
        if (CustomerList.RunModal <> ACTION::LookupOK) then
            exit(false);
        CustomerList.GetRecord(Customer);
        Text := Customer."No.";
        exit(true);
    end;

    procedure LookupItem(var Text: Text[1024]): Boolean
    var
        Item: Record Item;
        ItemFound: Boolean;
    begin
        // P80066030
        if (Text <> '') then begin
            Item.SetFilter("No.", UpperCase(Text) + '*');
            ItemFound := Item.FindFirst;
            if ItemFound and (Item."No." = UpperCase(Text)) then
                Item.SetRange("No.")
            else begin
                Item.SetFilter("No.", '*' + UpperCase(Text) + '*');
                if not ItemFound then
                    Item.FindFirst
            end;
        end;
        exit(PresentItemList(Item, Text));
    end;

    local procedure PresentItemList(var Item: Record Item; var Text: Text[1024]): Boolean
    var
        ItemList: Page "Item List";
    begin
        // P80066030
        if (Item."No." <> '') then
            ItemList.SetRecord(Item);
        ItemList.SetTableView(Item);
        ItemList.LookupMode := true;
        if (ItemList.RunModal <> ACTION::LookupOK) then
            exit(false);
        ItemList.GetRecord(Item);
        Text := Item."No.";
        exit(true);
    end;
}

