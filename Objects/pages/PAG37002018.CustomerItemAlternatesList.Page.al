page 37002018 "Customer Item Alternates List"
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

    Caption = 'Customer Item Alternates List';
    DelayedInsert = true;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Customer Item Alternate";

    layout
    {
        area(content)
        {
            group(Control37002004)
            {
                ShowCaption = false;
                field(CustomerNo; CustomerNo)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Customer No.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(CustItemAltMgmt.LookupCustomer(Text)); // P80066030
                    end;

                    trigger OnValidate()
                    begin
                        SetFormFilters;         // P8001132
                        CurrPage.Update(false); // P8001132
                    end;
                }
                field(SalesItemNo; SalesItemNo)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Sales Item No.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(CustItemAltMgmt.LookupItem(Text)); // P80066030
                    end;

                    trigger OnValidate()
                    begin
                        SetFormFilters;         // P8001132
                        CurrPage.Update(false); // P8001132
                    end;
                }
                field("Block Sales"; IsSalesBlocked)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Block Sales';
                    Editable = "Block SalesEditable";

                    trigger OnValidate()
                    begin
                        CustItemAltMgmt.SetBlocked("Customer No.", "Sales Item No.", IsSalesBlocked);
                    end;
                }
            }
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Sales Item No."; "Sales Item No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Sales Item Description"; "Sales Item Description")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                    Visible = false;
                }
                field("Alternate Item No."; "Alternate Item No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(CustItemAltMgmt.LookupItem(Text)); // P80066030
                    end;
                }
                field("Alternate Item Description"; "Alternate Item Description")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
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
        IsSalesBlocked := CustItemAltMgmt.IsBlocked("Customer No.", "Sales Item No.");
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        CustomerNo := GetFilter("Customer No.");
        SalesItemNo := GetFilter("Sales Item No.");

        //CurrForm."Block Sales".EDITABLE((CustomerNo <> '') AND (SalesItemNo <> ''));   // P8000788
        "Block SalesEditable" := (CustomerNo <> '') and (SalesItemNo <> '');   // P8000788

        exit(Find(Which));
    end;

    trigger OnInit()
    begin
        "Block SalesEditable" := true;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        TestField("Alternate Item No.");
    end;

    trigger OnOpenPage()
    begin
        FilterGroup(2);
        SetFilter("Alternate Item No.", '<>%1', '');
        FilterGroup(0);

        SetFormFilters;
    end;

    var
        CustomerNo: Code[20];
        SalesItemNo: Code[20];
        IsSalesBlocked: Boolean;
        CustItemAltMgmt: Codeunit "Cust./Item Alt. Mgmt.";
        [InDataSet]
        "Block SalesEditable": Boolean;

    local procedure SetFormFilters()
    begin
        if (CustomerNo = '') then
            SetRange("Customer No.")
        else
            SetRange("Customer No.", CustomerNo);
        if (SalesItemNo = '') then
            SetRange("Sales Item No.")
        else
            SetRange("Sales Item No.", SalesItemNo);
    end;
}

