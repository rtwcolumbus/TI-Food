page 37002149 "Scheduled Accrual Journal"
{
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PR50.00
    // P8000466A, VerticalSoft, Jack Reynolds, 09 AUG 07
    //   Change AccName to TEXT50
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 03 NOV 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 19 FEB 13
    //   Restoring the SaveValues Property.
    // 
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds 17 NOV 13
    //   Lookup of Shortcut Dimensions, Standardize OpenedFromBatch
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    ApplicationArea = FOODBasic;
    AutoSplitKey = true;
    Caption = 'Scheduled Accrual Journals';
    DataCaptionFields = "Journal Batch Name";
    DelayedInsert = true;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Accrual Journal Line";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            field(CurrentJnlBatchName; CurrentJnlBatchName)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Batch Name';
                Lookup = true;

                trigger OnLookup(var Text: Text): Boolean
                begin
                    CurrPage.SaveRecord;
                    AccrualJnlMgmt.LookupName(CurrentJnlBatchName, Rec);
                    CurrPage.Update(false);
                end;

                trigger OnValidate()
                begin
                    AccrualJnlMgmt.CheckName(CurrentJnlBatchName, Rec);
                    CurrPage.SaveRecord;
                    AccrualJnlMgmt.SetName(CurrentJnlBatchName, Rec);
                    CurrPage.Update(false);
                end;
            }
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Accrual Plan Type"; "Accrual Plan Type")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        AccrualJnlMgmt.GetNames(Rec, AccrualDescription, AccName);
                    end;
                }
                field("Accrual Plan No."; "Accrual Plan No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        AccrualJnlMgmt.GetNames(Rec, AccrualDescription, AccName);
                        ShowShortcutDimCode(ShortcutDimCode);
                    end;
                }
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Scheduled Accrual No."; "Scheduled Accrual No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookupAccrualSchdLine(Text));
                    end;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        AccrualJnlMgmt.GetNames(Rec, AccrualDescription, AccName);
                    end;
                }
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        AccrualJnlMgmt.GetNames(Rec, AccrualDescription, AccName);
                        ShowShortcutDimCode(ShortcutDimCode);
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source Document Type"; "Source Document Type")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Source Document No."; "Source Document No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(AccrualFldMgmt.LookupSourceDoc(
                          "Accrual Plan Type", "Accrual Plan No.", "Source No.",
                          "Source Document Type", Text));
                    end;
                }
                field("Source Document Line No."; "Source Document Line No.")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(AccrualFldMgmt.LookupSourceDocLine(
                          "Accrual Plan Type", "Accrual Plan No.", "Source No.",
                          "Source Document Type", "Source Document No.", Text));
                    end;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ShowShortcutDimCode(ShortcutDimCode);
                    end;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = DimVisible1;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = DimVisible2;
                }
                field("ShortcutDimCode[3]"; ShortcutDimCode[3])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,3';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible3;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field("ShortcutDimCode[4]"; ShortcutDimCode[4])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,4';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(4),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible4;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field("ShortcutDimCode[5]"; ShortcutDimCode[5])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,5';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(5),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible5;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field("ShortcutDimCode[6]"; ShortcutDimCode[6])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,6';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(6),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible6;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field("ShortcutDimCode[7]"; ShortcutDimCode[7])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,7';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(7),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible7;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field("ShortcutDimCode[8]"; ShortcutDimCode[8])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,8';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(8),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible8;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Accrual Posting Group"; "Accrual Posting Group")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
            }
            group(Control37002011)
            {
                ShowCaption = false;
                field(AccrualDescription; AccrualDescription)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Accrual Plan Name';
                    Editable = false;
                }
                field(AccName; AccName)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Account Name';
                    Editable = false;
                }
            }
        }
        area(factboxes)
        {
            part(DimensionSetEntriesFactBox; "Dimension Set Entries FactBox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "Dimension Set ID" = FIELD("Dimension Set ID");
                Visible = false;
            }
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
            group("&Line")
            {
                Caption = '&Line';
                action(Dimensions)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        ShowDimensions;      // P8001133
                        CurrPage.SaveRecord; // P8001133
                    end;
                }
            }
            group("&Accrual Plan")
            {
                Caption = '&Accrual Plan';
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = EditLines;
                    ShortCutKey = 'Shift+F7';

                    trigger OnAction()
                    var
                        AccrualPlan: Record "Accrual Plan";
                    begin
                        TestField("Accrual Plan No.");
                        AccrualPlan.Get("Accrual Plan Type", "Accrual Plan No.");
                        AccrualPlan.ShowCard;
                    end;
                }
                action("Ledger E&ntries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Ledger E&ntries';
                    RunObject = Page "Accrual Ledger Entries";
                    RunPageLink = "Accrual Plan Type" = FIELD("Accrual Plan Type"),
                                  "Accrual Plan No." = FIELD("Accrual Plan No.");
                    RunPageView = SORTING("Accrual Plan Type", "Accrual Plan No.", "Posting Date");
                    ShortCutKey = 'Ctrl+F7';
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("Suggest &Scheduled Accruals")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Suggest &Scheduled Accruals';

                    trigger OnAction()
                    var
                        SuggestSchdAccruals: Report "Suggest Schd. Accrual Entries";
                    begin
                        SuggestSchdAccruals.SetJnlLine(Rec, 0);
                        SuggestSchdAccruals.RunModal;
                        CurrPage.Update(false);
                    end;
                }
                action("Suggest Scheduled P&ayments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Suggest Scheduled P&ayments';

                    trigger OnAction()
                    var
                        SuggestSchdPayments: Report "Suggest Schd. Accrual Entries";
                    begin
                        SuggestSchdPayments.SetJnlLine(Rec, 1);
                        SuggestSchdPayments.RunModal;
                        CurrPage.Update(false);
                    end;
                }
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                action("Test Report")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Test Report';
                    Ellipsis = true;
                    Image = TestReport;

                    trigger OnAction()
                    begin
                        ReportPrint.PrintAccrualJnlLine(Rec);
                    end;
                }
                action("P&ost")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'P&ost';
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"Accrual Jnl.-Post", Rec);
                        CurrentJnlBatchName := GetRangeMax("Journal Batch Name");
                        CurrPage.Update(false);
                    end;
                }
                action("Post and &Print")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Post and &Print';
                    Image = PostPrint;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F9';

                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"Accrual Jnl.-Post+Print", Rec);
                        CurrentJnlBatchName := GetRangeMax("Journal Batch Name");
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        AccrualJnlMgmt.GetNames(Rec, AccrualDescription, AccName);
    end;

    trigger OnAfterGetRecord()
    begin
        ShowShortcutDimCode(ShortcutDimCode);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetUpNewLine(xRec);
        Clear(ShortcutDimCode);
        AccrualJnlMgmt.GetNames(Rec, AccrualDescription, AccName);
    end;

    trigger OnOpenPage()
    var
        JnlSelected: Boolean;
    begin
        // P8004516
        if IsOpenedFromBatch then begin
            CurrentJnlBatchName := "Journal Batch Name";
            AccrualJnlMgmt.OpenJnl(CurrentJnlBatchName, Rec);
            exit;
        end;
        // P8004516
        AccrualJnlMgmt.TemplateSelection(1, PAGE::"Scheduled Accrual Journal", false, Rec, JnlSelected); // PR4.00
        if not JnlSelected then                                                                      // PR4.00
            Error('');                                                                                 // PR4.00
        AccrualJnlMgmt.OpenJnl(CurrentJnlBatchName, Rec);
        Clear(AccrualDescription);
        Clear(AccName);
        SetDimensionVisibility; // P80073095
    end;

    var
        JobJnlReconcile: Page "Job Journal Reconcile";
        AccrualJnlMgmt: Codeunit AccrualJnlManagement;
        AccrualFldMgmt: Codeunit "Accrual Field Management";
        ReportPrint: Codeunit "Test Report-Print";
        AccrualDescription: Text[100];
        AccName: Text[100];
        CurrentJnlBatchName: Code[10];

    protected var
        ShortcutDimCode: array[8] of Code[20];
        DimVisible1: Boolean;
        DimVisible2: Boolean;
        DimVisible3: Boolean;
        DimVisible4: Boolean;
        DimVisible5: Boolean;
        DimVisible6: Boolean;
        DimVisible7: Boolean;
        DimVisible8: Boolean;

    local procedure SetDimensionVisibility()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        // P80073095
        DimMgt.UseShortcutDims(
          DimVisible1, DimVisible2, DimVisible3, DimVisible4, DimVisible5, DimVisible6, DimVisible7, DimVisible8);
    end;
}

