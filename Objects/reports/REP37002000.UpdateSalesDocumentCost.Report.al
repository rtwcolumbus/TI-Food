report 37002000 "Update Sales Document Cost"
{
    // PR2.00
    //   Text constants
    //   Use value entries instead of item ledger entries
    // 
    // PR3.61.01
    //   Fix problem where adjustment was terminating prematurely
    // 
    // PR3.61.02
    //   Missing continuation prompt and initialization of dialog window
    // 
    // PR3.70.02
    //   Logic completely reworked
    //     - was not handling alternate quantities correctly
    //     - was not picking up all costs due to different posting date on value entries
    //     - modified to update customer ledger
    // 
    // PR3.70.06
    // P8000088A, Myers Nissi, Jack Reynolds, 18 AUG 04
    //   Allow modify permission for customer ledger
    // 
    // PR4.00.06
    // P8000481A, VerticalSoft, Jack Reynolds, 31 MAY 07
    //   Fix problem with combine shipments
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 31 JUL 07
    //   Key change on value entry table
    // 
    // PRW16.00.03
    // P8000792, VerticalSoft, Rick Tweedle, 17 MAR 10
    //   Converted using TIF Editor
    // 
    // PRW111.00.03
    // P800146400, To Increase, Gangabhushan, 09 JUN 22
    //   CS00221633 | Adjust Cost Crashes with Div 0 Error
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Update Sales Document Cost';
    Permissions = TableData "Cust. Ledger Entry" = m,
                  TableData "Sales Invoice Header" = m,
                  TableData "Sales Invoice Line" = m,
                  TableData "Sales Cr.Memo Header" = m,
                  TableData "Sales Cr.Memo Line" = m;
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem("Sales Invoice Header"; "Sales Invoice Header")
        {
            DataItemTableView = SORTING("Cost is Adjusted") WHERE("Cost is Adjusted" = CONST(false));
            RequestFilterFields = "No.";
            dataitem("Sales Invoice Line"; "Sales Invoice Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemTableView = SORTING("Document No.", "Line No.");

                trigger OnAfterGetRecord()
                begin
                    if Type <> Type::Item then begin
                        TotalCostLCY += Round(Quantity * "Sales Invoice Line"."Unit Cost (LCY)");
                        CurrReport.Skip;
                    end;

                    LineQtyAdjusted := 0;
                    LineCost := 0;
                    TempValueEntry.SetRange("Item No.", "No.");

                    if TempValueEntry.Find('-') then
                        repeat
                            LineQtyAdjusted -= TempValueEntry."Invoiced Quantity";
                            LineCost -= Round(TempValueEntry."Invoiced Quantity" * GetItemLedgerUnitCost(TempValueEntry."Item Ledger Entry No."));
                            TempValueEntry.Delete;
                        until (TempValueEntry.Next = 0) or (LineQtyAdjusted = GetCostingQtyBase);

                    if LineQtyAdjusted = GetCostingQtyBase then begin
                        "Unit Cost (LCY)" := Round(LineCost / GetCostingQty, 0.00001);
                        Modify;
                    end;

                    TotalCostLCY += Round(GetCostingQty * "Sales Invoice Line"."Unit Cost (LCY)");
                end;

                trigger OnPostDataItem()
                begin
                    SalesInvHeader2 := "Sales Invoice Header";
                    SalesInvHeader2."Cost is Adjusted" := true;
                    SalesInvHeader2.Modify;

                    CustLedgEntry.SetCurrentKey("Document No.", "Document Type", "Customer No.");
                    CustLedgEntry.SetRange("Document No.", "Sales Invoice Header"."No.");
                    CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::Invoice);
                    CustLedgEntry.SetRange("Customer No.", "Sales Invoice Header"."Bill-to Customer No.");
                    CustLedgEntry.SetRange("Posting Date", "Sales Invoice Header"."Posting Date");
                    if CustLedgEntry.Find('-') then begin
                        CustLedgEntry."Profit (LCY)" := CustLedgEntry."Sales (LCY)" - TotalCostLCY;
                        CustLedgEntry.Modify;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    SetFilter(Quantity, '<>%1', 0);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if RecCount mod 100 = 0 then begin
                    Window.Update(1, Text006);
                    Window.Update(2, "No.");
                end;
                RecCount += 1;

                TempValueEntry.Reset;
                TempValueEntry.DeleteAll;
                ValueEntry.Reset;
                //ValueEntry.SETCURRENTKEY("Document No.","Posting Date"); // P8000466A
                ValueEntry.SetCurrentKey("Document No.");                  // P8000466A
                ValueEntry.SetRange("Document No.", "No.");
                //ValueEntry.SETRANGE("Posting Date","Posting Date");       // P8000481A
                ValueEntry.SetRange("Source Type", ValueEntry."Source Type"::Customer);
                //ValueEntry.SETRANGE("Source No.","Sell-to Customer No."); // P8000481A
                ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
                ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
                ValueEntry.SetFilter("Invoiced Quantity", '<>0');
                if ValueEntry.Find('-') then
                    repeat
                        TempValueEntry := ValueEntry;
                        TempValueEntry.Insert;
                    until ValueEntry.Next = 0;

                TotalCostLCY := 0;
            end;
        }
        dataitem("Sales Cr.Memo Header"; "Sales Cr.Memo Header")
        {
            DataItemTableView = SORTING("Cost is Adjusted") WHERE("Cost is Adjusted" = CONST(false));
            RequestFilterFields = "No.";
            dataitem("Sales Cr.Memo Line"; "Sales Cr.Memo Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemTableView = SORTING("Document No.", "Line No.");

                trigger OnAfterGetRecord()
                begin
                    if Type <> Type::Item then begin
                        TotalCostLCY -= Round(Quantity * "Sales Invoice Line"."Unit Cost (LCY)");
                        CurrReport.Skip;
                    end;

                    LineQtyAdjusted := 0;
                    LineCost := 0;
                    TempValueEntry.SetRange("Item No.", "No.");

                    if TempValueEntry.Find('-') then
                        repeat
                            LineQtyAdjusted += TempValueEntry."Invoiced Quantity";
                            LineCost += Round(TempValueEntry."Invoiced Quantity" * GetItemLedgerUnitCost(TempValueEntry."Item Ledger Entry No."));
                            TempValueEntry.Delete;
                        until (TempValueEntry.Next = 0) or (LineQtyAdjusted = GetCostingQtyBase);

                    if LineQtyAdjusted = GetCostingQtyBase then begin
                        "Unit Cost (LCY)" := Round(LineCost / GetCostingQty, 0.00001);
                        Modify;
                    end;

                    TotalCostLCY -= Round(GetCostingQty * "Sales Cr.Memo Line"."Unit Cost (LCY)");
                end;

                trigger OnPostDataItem()
                begin
                    SalesCrMemo2 := "Sales Cr.Memo Header";
                    SalesCrMemo2."Cost is Adjusted" := true;
                    SalesCrMemo2.Modify;

                    CustLedgEntry.SetCurrentKey("Document No.", "Document Type", "Customer No.");
                    CustLedgEntry.SetRange("Document No.", "Sales Cr.Memo Header"."No.");
                    CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::"Credit Memo");
                    CustLedgEntry.SetRange("Customer No.", "Sales Cr.Memo Header"."Bill-to Customer No.");
                    CustLedgEntry.SetRange("Posting Date", "Sales Cr.Memo Header"."Posting Date");
                    if CustLedgEntry.Find('-') then begin
                        CustLedgEntry."Profit (LCY)" := CustLedgEntry."Sales (LCY)" - TotalCostLCY;
                        CustLedgEntry.Modify;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    SetRange(Type, Type::Item);
                    SetFilter("No.", '<>%1', '');
                    SetFilter(Quantity, '<>%1', 0);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if RecCount mod 100 = 0 then begin
                    Window.Update(1, Text007);
                    Window.Update(2, "No.");
                end;
                RecCount += 1;

                TempValueEntry.Reset;
                TempValueEntry.DeleteAll;
                ValueEntry.Reset;
                //ValueEntry.SETCURRENTKEY("Document No.","Posting Date"); // P8000466A
                ValueEntry.SetCurrentKey("Document No.");                  // P8000466A
                ValueEntry.SetRange("Document No.", "No.");
                //ValueEntry.SETRANGE("Posting Date","Posting Date");       // P8000481A
                ValueEntry.SetRange("Source Type", ValueEntry."Source Type"::Customer);
                //ValueEntry.SETRANGE("Source No.","Sell-to Customer No."); // P8000481A
                ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
                ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
                ValueEntry.SetFilter("Invoiced Quantity", '<>0');
                if ValueEntry.Find('-') then
                    repeat
                        TempValueEntry := ValueEntry;
                        TempValueEntry.Insert;
                    until ValueEntry.Next = 0;

                TotalCostLCY := 0;
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        Window.Close;
    end;

    trigger OnPreReport()
    begin
        if not Confirm(
          Text000 +
          Text001)
        then
            Error(Text002);
        Window.Open(
          Text003 +
          Text004 +
          Text005);
    end;

    var
        ValueEntry: Record "Value Entry";
        TempValueEntry: Record "Value Entry" temporary;
        SalesInvHeader2: Record "Sales Invoice Header";
        SalesCrMemo2: Record "Sales Cr.Memo Header";
        Window: Dialog;
        RecCount: Integer;
        LineQtyAdjusted: Decimal;
        LineCost: Decimal;
        Text000: Label 'This report will update the cost on Posted Invoices and Credit Memos.\';
        Text001: Label 'Do you want to continue?';
        Text002: Label 'Nothing was updated.';
        Text003: Label 'Updating Cost...\\';
        Text004: Label 'Document Type #1##################\';
        Text005: Label 'Document No.  #2##################';
        Text006: Label 'Posted Invoice';
        Text007: Label 'Posted Cr. Memo';
        CostAdjusted: Boolean;
        CustLedgEntry: Record "Cust. Ledger Entry";
        TotalCostLCY: Decimal;

    procedure GetItemLedgerUnitCost(EntryNo: Integer): Decimal
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
    begin
        ItemLedgerEntry.Get(EntryNo);
        // P800146400
        if ItemLedgerEntry.GetCostingInvQty = 0 then
            exit(0);
        // P800146400        
        ValueEntry.SetCurrentKey("Item Ledger Entry No.");
        ValueEntry.SetRange("Item Ledger Entry No.", EntryNo);
        ValueEntry.CalcSums("Cost Amount (Actual)");
        exit(ValueEntry."Cost Amount (Actual)" / ItemLedgerEntry.GetCostingInvQty);
    end;
}

