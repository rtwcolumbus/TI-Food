page 37002192 "Ded. Management - Application"
{
    // PR3.70.08
    // P8000170A, Myers Nissi, Jack Reynolds, 31 JAN 05
    //   Deduction Management
    // 
    // PR3.70.09
    // P8000203A, Myers Nissi, Jack Reynolds, 08 MAR 05
    //   Display Original Amount of payment rather than the Amount
    // 
    // PR4.00.01
    // P8000269A, VerticalSoft, Jack Reynolds, 05 DEC 05
    //   Support for comments
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 09 NOV 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW18.00.02
    // P8002751, to-Increase, Jack Reynolds, 26 OCT 15
    //   Allow option to keep deductions with original customer
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    AdditionalSearchTerms = 'payment application';
    Caption = 'Deduction Management - Application';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Worksheet;
    SourceTable = "Cust. Ledger Entry";
    SourceTableView = SORTING("Document Type", Open, "Customer No.", "Posting Date")
                      WHERE("Document Type" = CONST(Payment),
                            Open = CONST(true));
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(Filters)
            {
                Caption = 'Filters';
                field(CustNoFilter; CustNoFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Customer No.';
                    TableRelation = Customer;

                    trigger OnValidate()
                    begin
                        if CustNoFilter = '' then
                            SetRange("Customer No.")
                        else
                            SetFilter("Customer No.", CustNoFilter);
                        CurrPage.Update(false); // P8002751
                    end;
                }
                field(PostDateFilter; PostDateFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Posting Date';

                    trigger OnValidate()
                    var
                        CustLedger: Record "Cust. Ledger Entry";
                    begin
                        CustLedger.SetFilter("Date Filter", PostDateFilter);
                        PostDateFilter := CustLedger.GetFilter("Date Filter");
                        if PostDateFilter = '' then
                            SetRange("Posting Date")
                        else
                            SetFilter("Posting Date", PostDateFilter);
                        CurrPage.Update(false); // P8002751
                    end;
                }
            }
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Customer No."; "Customer No.")
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
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Original Amount"; "Original Amount")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Remaining Amount"; "Remaining Amount")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Comment; Comment)
                {
                    ApplicationArea = FOODBasic;
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
        area(navigation)
        {
            group("Ent&ry")
            {
                Caption = 'Ent&ry';
                action(Comments)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Ledger Entry Comments";
                    RunPageLink = "Table ID" = CONST(21),
                                  "Entry No." = FIELD("Entry No.");
                }
                action(Dimensions)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        ShowDimensions;      // P8001133
                    end;
                }
                action(DetailedLedgerEntries)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Detailed &Ledger Entries';
                    Image = LedgerEntries;
                    RunObject = Page "Detailed Cust. Ledg. Entries";
                    RunPageLink = "Cust. Ledger Entry No." = FIELD("Entry No."),
                                  "Customer No." = FIELD("Customer No.");
                    RunPageView = SORTING("Cust. Ledger Entry No.", "Posting Date");
                    ShortCutKey = 'Ctrl+F7';
                }
            }
        }
        area(processing)
        {
            action(Application)
            {
                ApplicationArea = FOODBasic;
                Caption = '&Application';
                Image = ApplicationWorksheet;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    DedMgt: Codeunit "Deduction Management";
                begin
                    DedMgt.ApplyFromCustomerLedger(Rec);
                end;
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        CustNoFilter := GetFilter("Customer No.");
        PostDateFilter := GetFilter("Posting Date");
        exit(Find(Which));
    end;

    trigger OnOpenPage()
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        SalesSetup.Get;
        if SalesSetup."Deduction Management Cust. No." <> '' then begin
            FilterGroup(2);
            SetFilter("Customer No.", '<>%1', SalesSetup."Deduction Management Cust. No.");
            FilterGroup(0);
        end;
    end;

    var
        CustNoFilter: Code[1024];
        PostDateFilter: Text[1024];
}

