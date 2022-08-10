page 37002127 "Accrual Payment Group Subform"
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
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 15 JAN 10
    //   Change Form Caption
    // 
    // P8000664, VerticalSoft, Jimmy Abidi, 15 JAN 10
    //   Transformed from Form
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Accrual Payment Group Line";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; GetDescription())
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Description';
                    Editable = false;
                }
                field("Payment %"; "Payment %")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        Payment37OnAfterValidate;
                    end;
                }
            }
            field("Total Payment %"; GetTotalPaymentPercent())
            {
                ApplicationArea = FOODBasic;
                Caption = 'Total Payment %';
                DecimalPlaces = 0 : 5;
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Type := xRec.Type;
        "Payment %" := 100 - GetTotalPaymentPercent();
        if ("Payment %" < 0) then
            "Payment %" := 0;
    end;

    var
        SourceDescription: Label 'Source of Accrual';

    local procedure GetDescription(): Text[100]
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        GLAccount: Record "G/L Account";
        PaymentGroup: Record "Accrual Payment Group";
    begin
        if Type = Type::"Source Bill-to/Pay-to" then
            exit(SourceDescription);
        case Type of
            Type::Customer:
                if Customer.Get(Code) then
                    exit(Customer.Name);
            Type::Vendor:
                if Vendor.Get(Code) then
                    exit(Vendor.Name);
            Type::"G/L Account":
                if GLAccount.Get(Code) then
                    exit(GLAccount.Name);
            Type::"Payment Group":
                if PaymentGroup.Get(Code) then
                    exit(PaymentGroup.Description);
        end;
        exit('');
    end;

    local procedure GetTotalPaymentPercent(): Decimal
    var
        AccrualPaymentGroupLine: Record "Accrual Payment Group Line";
    begin
        AccrualPaymentGroupLine.SetRange("Accrual Payment Group", "Accrual Payment Group");
        AccrualPaymentGroupLine.CalcSums("Payment %");
        exit(AccrualPaymentGroupLine."Payment %");
    end;

    local procedure Payment37OnAfterValidate()
    begin
        CurrPage.Update;
    end;
}

