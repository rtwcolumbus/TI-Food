page 37002194 "Ded. Management - Resolution"
{
    // PR3.70.08
    // P8000170A, Myers Nissi, Jack Reynolds, 31 JAN 05
    //   Deduction Management
    // 
    // PR3.70.09
    // P8000190A, Myers Nissi, Jack Reynolds, 22 FEB 05
    //   Remove calls to LockTables when posting lines
    // 
    // PR3.70.10
    // P8000240A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Set all controls except "Assigned To" to non-editable
    // 
    // PR4.00.01
    // P8000269A, VerticalSoft, Jack Reynolds, 05 DEC 05
    //   Support for comments
    // 
    // PRW16.00.01
    // P8000684, VerticalSoft, Jack Reynolds, 24 MAR 09
    //   Modify OriginalCustomerName to accomodate 50 character customer names
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 09 NOV 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.04
    // P8000897, VerticalSoft, Jack Reynolds, 22 JAN 11
    //   Fix spelling mistake
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW18.00.02
    // P8002752, to-Increase, Jack Reynolds, 26 OCT 15
    //   Allow option to keep deductions with original customer
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 11 NOV 15
    //   Posting preview
    // 
    // PRW19.00.01
    // P8007972, To-Increase, Dayakar Battini, 04 NOV 16
    //   UserId variable length from 20 to 50
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    ApplicationArea = FOODBasic;
    Caption = 'Deduction Management - Resolution';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = "Cust. Ledger Entry";
    SourceTableView = SORTING("Customer No.", "Original Customer No.", Open, "Posting Date")
                      WHERE("Unresolved Deduction" = CONST(true));
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
                            SetRange("Original Customer No.")
                        else
                            SetFilter("Original Customer No.", CustNoFilter);
                        CurrPage.Update(false); // P8002752
                    end;
                }
                field(AssignedToFilter; AssignedToFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Assigned To';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        UserSelection: Codeunit "User Selection";
                        User: Record User;
                    begin
                        // P800-MegaApp
                        if UserSelection.Open(User) then begin
                            Text := User."User Name";
                            exit(true);
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        if AssignedToFilter = '' then
                            SetRange("Assigned To")
                        else
                            SetFilter("Assigned To", AssignedToFilter);
                        CurrPage.Update(false); // P8002752
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
                        CurrPage.Update(false); // P8002752
                    end;
                }
            }
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Original Customer No."; "Original Customer No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Customer No.';
                    Editable = false;
                }
                field(OriginalCustomerName; OriginalCustomerName)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Customer Name';
                }
                field("Assigned To"; "Assigned To")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Deduction Type"; "Deduction Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Original Document Type"; "Original Document Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Original Document No."; "Original Document No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Remaining Amount"; "Remaining Amount")
                {
                    ApplicationArea = FOODBasic;
                }
                field(ResolvedAmount; ResolvedAmount)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Resolved Amount';
                    DecimalPlaces = 2 : 2;
                }
                field(Comment; Comment)
                {
                    ApplicationArea = FOODBasic;
                }
            }
            part(Resoultions; "Deduction Resolution Subform")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "Entry No." = FIELD("Entry No.");
                UpdatePropagation = Both;
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
            group("P&osting")
            {
                Caption = 'P&osting';
                action(PostLine)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Post Line';
                    Ellipsis = true;
                    Image = PostApplication;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    var
                        DeductionRes: Record "Deduction Resolution";
                        DedResPost: Codeunit "Ded. Mgt. - Post Resolution";
                    begin
                        DeductionRes.SetRange("Entry No.", "Entry No.");
                        if not DeductionRes.Find('-') then begin
                            Message(Text001);
                            exit;
                        end;

                        if Confirm(Text002, true) then begin
                            // DedResPost.LockTables; // P8000190A
                            DedResPost.Run(Rec);
                        end;
                    end;
                }
                action(Preview)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Posting Preview';
                    Image = ViewPostedOrder;

                    trigger OnAction()
                    var
                        DeductionRes: Record "Deduction Resolution";
                        DedResPost: Codeunit "Ded. Mgt. - Post Resolution";
                    begin
                        // P8004516
                        DeductionRes.SetRange("Entry No.", "Entry No.");
                        if not DeductionRes.Find('-') then begin
                            Message(Text001);
                            exit;
                        end;

                        DedResPost.Preview(Rec);
                    end;
                }
                action(PostAllLines)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Post All Lines';
                    Ellipsis = true;
                    Image = PostingEntries;

                    trigger OnAction()
                    var
                        CustLedger: Record "Cust. Ledger Entry";
                        DeductionRes: Record "Deduction Resolution";
                        DedResPost: Codeunit "Ded. Mgt. - Post Resolution";
                        RecCnt: Integer;
                        Posted: Integer;
                    begin
                        CustLedger.Copy(Rec);
                        if CustLedger.Find('-') then begin
                            if not Confirm(Text003, true) then
                                exit;

                            // DedResPost.LockTables; // P8000190A
                            repeat
                                RecCnt += 1;
                                DeductionRes.SetRange("Entry No.", CustLedger."Entry No.");
                                if DeductionRes.Find('-') then begin
                                    if DedResPost.Run(CustLedger) then
                                        Posted += 1;
                                end else
                                    RecCnt -= 1;
                            until CustLedger.Next = 0;
                            Message(Text004, Posted, RecCnt);
                        end;
                    end;
                }
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        CustNoFilter := GetFilter("Original Customer No.");
        AssignedToFilter := GetFilter("Assigned To");
        PostDateFilter := GetFilter("Posting Date");
        exit(Find(Which));
    end;

    trigger OnModifyRecord(): Boolean
    begin
        CODEUNIT.Run(CODEUNIT::"Cust. Entry-Edit", Rec);
        exit(false);
    end;

    trigger OnOpenPage()
    begin
        SalesSetup.Get;
        if SalesSetup."Deduction Management Cust. No." <> '' then begin // P8002752
            FilterGroup(2);
            SetRange("Customer No.", SalesSetup."Deduction Management Cust. No.");
            FilterGroup(0);
        end; // P8002752

        AssignedToFilter := UserId;
        SetRange("Assigned To", AssignedToFilter);
    end;

    var
        SalesSetup: Record "Sales & Receivables Setup";
        Customer: Record Customer;
        CustNoFilter: Code[1024];
        AssignedToFilter: Code[1024];
        PostDateFilter: Text[1024];
        Text001: Label 'Nothing to post.';
        Text002: Label 'Post deduction resolution?';
        Text003: Label 'Post deduction resolution for all entries?';
        Text004: Label 'Resolutions for %1 entries out of %2 entries have now been posted.';

    procedure ResolvedAmount(): Decimal
    var
        DeductionRes: Record "Deduction Resolution";
    begin
        DeductionRes.SetRange("Entry No.", "Entry No.");
        DeductionRes.CalcSums(Amount);
        exit(DeductionRes.Amount);
    end;

    procedure OriginalCustomerName(): Text[100]
    begin
        // P8000684 - return value expanded to Text50
        if Customer.Get("Original Customer No.") then
            exit(Customer.Name);
    end;
}

