page 37002052 "Order Off-Invoice Allowances"
{
    // PR3.70.06
    // P8000118A, Myers Nissi, Jack Reynolds, 15 SEP 04
    //   Make Allowance non-editable
    // 
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Change call to OffInvoiceFns.SumSalesLines
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 06 FEB 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Order Off-Invoice Allowances';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Order Off-Invoice Allowance";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Allowance Code"; "Allowance Code")
                {
                    ApplicationArea = FOODBasic;
                    Lookup = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                }
                field("Grant Allowance"; "Grant Allowance")
                {
                    ApplicationArea = FOODBasic;
                }
                field("TempAllowanceLine.Allowance"; TempAllowanceLine.Allowance)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Allowance';
                    DecimalPlaces = 2 : 2;
                    Editable = false;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    var
        AllowanceLine: Record "Off-Invoice Allowance Line";
    begin
        if ("Document Type" <> SalesHeader."Document Type") or ("Document No." <> SalesHeader."No.") then begin
            SalesHeader.Get("Document Type", "Document No.");
            TempAllowanceLine.Reset;
            TempAllowanceLine.DeleteAll;
            OffInvoiceFns.SumSalesLines(SalesHeader, Weight, Volume, Quantity, Amount, 'OUT'); // P8000282A
        end;
        TempAllowanceLine.SetRange("Allowance Code", "Allowance Code");
        if not TempAllowanceLine.Find('-') then begin
            OffInvoiceFns.CalcAllowance(SalesHeader, "Allowance Code", Weight, Volume, Quantity, Amount, AllowanceLine);
            AllowanceLine.Allowance += OffInvoiceFns.AllowanceIssued(SalesHeader, "Allowance Code", false);
            TempAllowanceLine := AllowanceLine;
            TempAllowanceLine.Insert;
        end;
    end;

    var
        SalesHeader: Record "Sales Header";
        TempAllowanceLine: Record "Off-Invoice Allowance Line" temporary;
        OffInvoiceFns: Codeunit "Off-Invoice Allowance Mgt.";
        Weight: Decimal;
        Volume: Decimal;
        Quantity: Decimal;
        Amount: Decimal;
}

