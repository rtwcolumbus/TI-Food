page 37002016 "Customer Item Alt. Subform"
{
    // PRW15.00.01
    // P8000589A, VerticalSoft, Don Bresee, 05 MAR 08
    //   Add alternate sales items by Customer
    // 
    // PRW15.00.02
    // P8000613A, VerticalSoft, Jack Reynolds, 18 JUL 08
    //   Resize to fit subform control on parent form
    // 
    // P8000788, VerticalSoft, Rick Tweedle, 22 MAR 10
    //   Transformed using TIF Tool
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Customer Item Alt. Subform';
    DelayedInsert = true;
    PageType = ListPart;
    SaveValues = true;
    SourceTable = "Customer Item Alternate";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
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

    trigger OnFindRecord(Which: Text): Boolean
    begin
        SetFormFilters;

        exit(Find(Which));
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        TestField("Alternate Item No.");
    end;

    // P800-MegaApp
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Customer No." := CustomerNo;
    end;
    // P800-MegaApp

    var
        CustItemAltMgmt: Codeunit "Cust./Item Alt. Mgmt.";
        CustomerNo: Code[20];

    local procedure SetFormFilters()
    begin
        FilterGroup(2);
        SetRange("Customer No.", CustomerNo);
        SetFilter("Alternate Item No.", '<>%1', '');
        FilterGroup(0);
    end;

    procedure SetCustomerNo(NewCustomerNo: Code[20])
    begin
        CustomerNo := NewCustomerNo;
        CurrPage.Update(false); // P800-MegaApp
     end;
}

