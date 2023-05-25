page 37002191 "Deduction Line Subform"
{
    // PR3.70.08
    // P8000170A, Myers Nissi, Jack Reynolds, 31 JAN 05
    //   Deduction Management
    // 
    // PR3.70.09
    // P8000192A, Myers Nissi, Jack Reynolds, 24 FEB 05
    //   Total deductions not updating properly
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
    // P8001000, Columbus IT, Jack Reynolds, 30 NOV 11
    //   fix problem with doublng of deduction total
    // 
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW18.00.02
    // P8002751, to-Increase, Jack Reynolds, 26 OCT 15
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
    Caption = 'Deduction Lines';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Deduction Line";
    SourceTableView = WHERE(Type = CONST(Deduction));

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Deduction Type"; "Deduction Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = FOODBasic;
                    Editable = AmountEditable;

                    trigger OnValidate()
                    begin
                        if "Line No." <> 0 then begin
                            TotalDeduction := TotalDeduction - xAmount + Amount;
                            UpdateRemainder;
                        end;
                    end;
                }
                field(Allowed; Allowed)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Assigned To"; "Assigned To")
                {
                    ApplicationArea = FOODBasic;
                }
                field(RelatedDocumentNo; RelatedDocumentNo)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Related Document';
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Account No."; "Account No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(DedMgt.AcctNoLookup("Deduction Type", "Customer No.", Text)); // P8000240A
                    end;
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = FOODBasic;
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
            group(Control37002012)
            {
                ShowCaption = false;
                field(TotalPayment; TotalPayment)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Payment';
                    DecimalPlaces = 2 : 2;
                    Editable = false;
                }
                field(TotalApplication; TotalApplication)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Applied';
                    DecimalPlaces = 2 : 2;
                    Editable = false;
                }
                field(TotalDeduction; TotalDeduction)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Deductions';
                    DecimalPlaces = 2 : 2;
                    Editable = false;
                }
                field(Remainder; RemainderAmt)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Remainder';
                    DecimalPlaces = 2 : 2;
                    Editable = false;
                }
                field(RemainderApplication; RemainderApplication)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Remainder Applied To';
                    Visible = RemainderAppliedToVisible;

                    trigger OnValidate()
                    begin
                        Remainder."Remainder Applied to" := RemainderApplication;
                        Remainder.Modify;
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Line)
            {
                Caption = 'Line';
                action("&Split Line")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Split Line';
                    Ellipsis = true;

                    trigger OnAction()
                    begin
                        //This functionality was copied from page #37002190. Unsupported part was commented. Please check it.
                        /*CurrPage.Deductions.PAGE.*/
                        SplitLine;

                    end;
                }
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

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        AmountEditable := "Applies-to Entry No." = 0;
    end;

    trigger OnAfterGetRecord()
    begin
        ShowShortcutDimCode(ShortcutDimCode);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        if "Applies-to Entry No." <> 0 then
            exit(false);

        TotalDeduction -= Amount;
        UpdateRemainder;
        exit(true);
    end;

    trigger OnInit()
    begin
        AmountEditable := true;

        // P8002751
        SalesSetup.Get;
        RemainderAppliedToVisible := SalesSetup."Deduction Management Cust. No." <> '';
        // P8002751
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        TotalDeduction := TotalDeduction + Amount; // P8000192A
        UpdateRemainder;
        exit(true);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(ShortcutDimCode);
        SetCustomerNo;
    end;

    trigger OnOpenPage()
    begin
        SetDimensionVisibility; // P80073095
    end;

    var
        Remainder: Record "Deduction Line";
        SalesSetup: Record "Sales & Receivables Setup";
        DedMgt: Codeunit "Deduction Management";
        TotalPayment: Decimal;
        TotalApplication: Decimal;
        TotalUnapplied: Decimal;
        TotalDeduction: Decimal;
        RemainderAmt: Decimal;
        xAmount: Decimal;
        RemainderLabel: Text[30];
        RemainderColor: Integer;
        RemainderApplication: Option "Ded. Mgt.",Customer;
        [InDataSet]
        AmountEditable: Boolean;
        [InDataSet]
        RemainderAppliedToVisible: Boolean;

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

    procedure SetLink(TableID: Integer; ID: Code[20]; BatchName: Code[10]; RefNo: Integer)
    var
        DeductionLine: Record "Deduction Line";
        i: Integer;
    begin
        FilterGroup(9);
        SetRange("Source Table No.", TableID);
        SetRange("Source ID", ID);
        SetRange("Source Batch Name", BatchName);
        SetRange("Source Ref. No.", RefNo);
        FilterGroup(0);
        CurrPage.Update;

        Remainder.Get(TableID, ID, BatchName, RefNo, Remainder.Type::Remainder, 10000);
        RemainderApplication := Remainder."Remainder Applied to";
        DeductionLine.Copy(Rec);
        DeductionLine.SetRange(Type, DeductionLine.Type::Deduction); // P8001000
        if DeductionLine.Find('-') then
            repeat
                TotalDeduction += DeductionLine.Amount;
            until DeductionLine.Next = 0;
    end;

    procedure SetPaymentAmount(Amt: Decimal)
    begin
        TotalPayment := Amt;
    end;

    procedure UpdateApplicationAmount(Amt: Decimal)
    begin
        TotalApplication := Amt;
        UpdateRemainder;
    end;

    procedure UpdateUnappliedAmount(Amt: Decimal)
    begin
        TotalUnapplied += Amt;
        UpdateRemainder;
    end;

    procedure UpdateDeductionAmount(ChangeInAmount: Decimal)
    begin
        TotalDeduction += ChangeInAmount;
        UpdateRemainder;
    end;

    procedure UpdateRemainder()
    begin
        RemainderAmt := TotalPayment - TotalApplication + TotalUnapplied + TotalDeduction;
        if RemainderAmt < 0 then
            RemainderColor := 255
        else
            RemainderColor := 0;
    end;

    procedure UpdateForm()
    begin
        CurrPage.Update;
    end;

    procedure SplitLine()
    var
        DeductionLine: Record "Deduction Line";
        SplitLineForm: Page "Split Deduction Line";
        NewAmount: Decimal;
        LineNo: Integer;
    begin
        SplitLineForm.SetAmount(Amount);
        if SplitLineForm.RunModal = ACTION::OK then begin
            NewAmount := SplitLineForm.GetNewAmount;
            DeductionLine := Rec;
            DeductionLine.SetRecFilter;
            DeductionLine.SetRange("Line No.");
            LineNo := DeductionLine."Line No.";
            if DeductionLine.Next = 0 then
                DeductionLine."Line No." := LineNo + 10000
            else
                DeductionLine."Line No." := (LineNo + DeductionLine."Line No.") div 2;
            DeductionLine.Init;
            DeductionLine."Applies-to Entry No." := "Applies-to Entry No.";
            DeductionLine.Amount := Amount - NewAmount;
            DeductionLine.Insert(true);
            Amount := NewAmount;
            Modify;

            CurrPage.Update;
        end;
    end;

    local procedure SetDimensionVisibility()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        // P80073095
        DimMgt.UseShortcutDims(
          DimVisible1, DimVisible2, DimVisible3, DimVisible4, DimVisible5, DimVisible6, DimVisible7, DimVisible8);
    end;
}

