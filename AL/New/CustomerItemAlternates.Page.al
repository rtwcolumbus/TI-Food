page 37002015 "Customer Item Alternates"
{
    // PRW15.00.01
    // P8000589A, VerticalSoft, Don Bresee, 05 MAR 08
    //   Add alternate sales items by Customer
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.03
    // P8000788, VerticalSoft, Rick Tweedle, 22 MAR 10
    //   Ameneded code to work with Transform tool
    // 
    // P8000788, VerticalSoft, Rick Tweedle, 22 MAR 10
    //   Transformed using TIF Tool
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Customer Item Alternates';
    DataCaptionExpression = GetFormCaption();
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = Item;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(Control37002002)
            {
                ShowCaption = false;
                field("Customer No."; CustomerNo)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Customer No.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(CustItemAltMgmt.LookupCustomer(Text)); // P80066030
                    end;

                    trigger OnValidate()
                    begin
                        CustomerNoOnAfterValidate;
                    end;
                }
            }
            field(AlternatesLabel; GetItemListDesc())
            {
                ApplicationArea = FOODBasic;
                DrillDown = false;
                Editable = false;
                ShowCaption = false;
                Style = Strong;

                trigger OnDrillDown()
                begin
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
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Base Unit of Measure"; "Base Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field("Block Sales"; IsSalesBlocked)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Block Sales';
                    Editable = "Block SalesEditable";

                    trigger OnValidate()
                    begin
                        IsSalesBlockedOnAfterValidate;
                    end;
                }
                field("Has Alternates"; CustItemAltMgmt.HasAlternates(CustomerNo, "No."))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Has Alternates';
                    Editable = false;
                }
            }
            field(AlternatesLabel2; GetAltItemListDesc())
            {
                ApplicationArea = FOODBasic;
                DrillDown = false;
                Editable = false;
                ShowCaption = false;
                Style = Strong;

                trigger OnDrillDown()
                begin
                end;
            }
            part(AlternatesSubform; "Customer Item Alt. Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Alternate Items';
                Editable = CustomerNo <> ''; // P800-MegaApp
                SubPageLink = "Sales Item No." = FIELD("No.");
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        IsSalesBlocked := CustItemAltMgmt.IsBlocked(CustomerNo, "No.");
    end;

    trigger OnInit()
    begin
        "Block SalesEditable" := true;
    end;

    trigger OnOpenPage()
    begin
        SetRange("Item Type", "Item Type"::"Finished Good");

        if (CustomerNo = '') then;
        UpdateForm;
    end;

    var
        CustomerNo: Code[20];
        IsSalesBlocked: Boolean;
        CustItemAltMgmt: Codeunit "Cust./Item Alt. Mgmt.";
        Text000: Label 'Sales Items for %1';
        Text001: Label 'Alternate Items for %1';
        [InDataSet]
        "Block SalesEditable": Boolean;

    procedure GetFormCaption(): Text[250]
    var
        Customer: Record Customer;
    begin
        if (CustomerNo <> '') then
            if Customer.Get(CustomerNo) then begin
                if (Customer.Name <> '') then
                    exit(StrSubstNo('%1 %2', Customer."No.", Customer.Name));
                exit(Customer."No.");
            end;
    end;

    local procedure GetItemListDesc(): Text[250]
    var
        Customer: Record Customer;
    begin
        if (CustomerNo <> '') then
            if Customer.Get(CustomerNo) then begin
                if (Customer.Name <> '') then
                    exit(StrSubstNo(Text000, Customer.Name));
                exit(StrSubstNo(Text000, StrSubstNo('%1 %2', Customer.TableCaption, Customer."No.")));
            end;
    end;

    local procedure GetAltItemListDesc(): Text[250]
    begin
        if (CustomerNo <> '') and ("No." <> '') then begin
            if (Description <> '') then
                exit(StrSubstNo(Text001, Description));
            exit(StrSubstNo(Text001, StrSubstNo('%1 %2', TableCaption, "No.")));
        end;
    end;

    local procedure UpdateForm()
    begin
        CurrPage.AlternatesSubform.PAGE.SetCustomerNo(CustomerNo);
        //CurrForm."Block Sales".EDITABLE(CustomerNo <> '');  // P8000788
        "Block SalesEditable" := CustomerNo <> '';  // P8000788
    end;

    local procedure IsSalesBlockedOnAfterValidate()
    begin
        CustItemAltMgmt.SetBlocked(CustomerNo, "No.", IsSalesBlocked);
    end;

    local procedure CustomerNoOnAfterValidate()
    begin
        UpdateForm;
        CurrPage.Update(false);
    end;
}

