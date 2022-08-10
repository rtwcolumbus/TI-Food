page 37002136 "Accrual Group Subform"
{
    // PR3.61AC
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // P8000613A, VerticalSoft, Jack Reynolds, 18 JUL 08
    //   Resize to fit subform control on parent form
    // 
    // PRW16.00.03
    // P8000828, VerticalSoft, Don Bresee, 09 JUN 10
    //   Move insert/delete logic to form/page
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Accrual Group Subform';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Accrual Group Line";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; GetDescription())
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Description';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnDeleteRecord(): Boolean
    begin
        AccrualSearchMgt.DeleteGroupLine(Rec); // P8000828
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        // P8000828
        Insert;
        AccrualSearchMgt.InsertGroupLine(Rec);
        exit(false);
    end;

    var
        AccrualSearchMgt: Codeunit "Accrual Search Management";

    procedure GetDescription(): Text[100]
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Item: Record Item;
    begin
        case "Accrual Group Type" of
            "Accrual Group Type"::Customer:
                if Customer.Get("No.") then
                    exit(Customer.Name);
            "Accrual Group Type"::Vendor:
                if Vendor.Get("No.") then
                    exit(Vendor.Name);
            "Accrual Group Type"::Item:
                if Item.Get("No.") then
                    exit(Item.Description);
        end;
        exit('');
    end;
}

