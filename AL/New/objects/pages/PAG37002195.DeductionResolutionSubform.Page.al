page 37002195 "Deduction Resolution Subform"
{
    // PR3.70.08
    // P8000170A, Myers Nissi, Jack Reynolds, 31 JAN 05
    //   Deduction Management
    // 
    // PR3.70.10
    // P8000240A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Support for accrual plans as account number
    // 
    // PR4.00.01
    // P8000269A, VerticalSoft, Jack Reynolds, 05 DEC 05
    //   Support for comments
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
    // PRW18.00.02
    // P8002752, to-Increase, Jack Reynolds, 26 OCT 15
    //   Allow option to keep deductions with original customer
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds 17 NOV 13
    //   Lookup of Shortcut Dimensions
    // 
    // PRW113.00.03
    // P80085994, To Increase, Jack Reynolds, 20 NOV 19
    //   Fix dimension issues
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    AutoSplitKey = true;
    Caption = 'Resolution Lines';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Deduction Resolution";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field(Type1; Type)
                {
                    ApplicationArea = FOODBasic;
                    OptionCaption = ' ,Writeoff,Accrual Plan,,,,,Return';
                    Visible = UseDedMgmtCust;

                    trigger OnValidate()
                    begin
                        CurrPage.Update; // P8002752
                    end;
                }
                field(Type2; Type)
                {
                    ApplicationArea = FOODBasic;
                    OptionCaption = ' ,Writeoff,Accrual Plan,,,,,,Clear';
                    Visible = NOT UseDedMgmtCust;

                    trigger OnValidate()
                    begin
                        CurrPage.Update; // P8002752
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        CurrPage.Update; // P8002752
                    end;
                }
                field("Account No."; "Account No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        DedMgt: Codeunit "Deduction Management";
                    begin
                        exit(DedMgt.AcctNoLookup(Type, "Customer No.", Text));
                    end;
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Use Original Date"; "Use Original Date")
                {
                    ApplicationArea = FOODBasic;
                    Visible = UseDedMgmtCust;
                }
                field("Resolve With Original Customer"; "Resolve With Original Customer")
                {
                    ApplicationArea = FOODBasic;
                    Visible = UseDedMgmtCust;
                }
                field(Comment; Comment)
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
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Line")
            {
                Caption = '&Line';
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = ViewComments;

                    trigger OnAction()
                    begin
                        // P80085994
                        ShowComments;
                        CurrPage.Update;
                    end;
                }
                action(Dimensions)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        // P80085994
                        EditDimensions;
                        CurrPage.Update;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ShowShortcutDimCode(ShortcutDimCode);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        // P8002752
        CurrPage.Update(false);
        exit(true);
    end;

    trigger OnInit()
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        // P8002752
        SalesSetup.Get;
        UseDedMgmtCust := SalesSetup."Deduction Management Cust. No." <> '';
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(ShortcutDimCode);
        InitRecord;
    end;

    trigger OnOpenPage()
    begin
        SetDimensionVisibility; // P80073095
    end;

    var
        [InDataSet]
        UseDedMgmtCust: Boolean;

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

