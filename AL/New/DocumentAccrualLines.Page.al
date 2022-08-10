page 37002141 "Document Accrual Lines"
{
    // PR3.70.04
    // P8000044A, Myers Nissi, Jack Reynolds, 21 MAY 04
    //   Accrual Fixes
    // 
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
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

    Caption = 'Document Accrual Lines';
    DataCaptionExpression = GetCaption();
    PageType = List;
    SourceTable = "Document Accrual Line";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Accrual Plan No."; "Accrual Plan No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Accrual Plan No.Editable";

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if (Text = '') then           // P8000044A
                            Text := "Accrual Plan No."; // P8000044A
                        exit(AccrualPlanLookup(Text));
                    end;
                }
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                    Editable = TypeEditable;
                }
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "No.Editable";
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Accrual Amount (LCY)"; "Accrual Amount (LCY)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Payment %"; "Payment %")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Payment %Editable";
                }
                field("Payment Amount (LCY)"; "Payment Amount (LCY)")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Payment Amount (LCY)Editable";
                }
                field("Price Impact"; "Price Impact")
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
            group("&Accrual Plan")
            {
                Caption = '&Accrual Plan';
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;
                    ShortCutKey = 'Shift+F7';

                    trigger OnAction()
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
                    Image = LedgerEntries;
                    RunObject = Page "Accrual Ledger Entries";
                    RunPageLink = "Accrual Plan Type" = FIELD("Accrual Plan Type"),
                                  "Accrual Plan No." = FIELD("Accrual Plan No.");
                    RunPageView = SORTING("Accrual Plan Type", "Accrual Plan No.", "Posting Date");
                    ShortCutKey = 'Ctrl+F7';
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        if not FormDisabled then
            if IsNewRecord() then
                UpdateFields(true)
            else begin
                CalcFields("Edit Accrual on Document");
                UpdateFields("Edit Accrual on Document");
            end;
    end;

    trigger OnInit()
    begin
        "Payment Amount (LCY)Editable" := true;
        "Payment %Editable" := true;
        "No.Editable" := true;
        TypeEditable := true;
        "Accrual Plan No.Editable" := true;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Type := "Accrual Plan Type";
    end;

    trigger OnOpenPage()
    begin
        if FormDisabled then
            CurrPage.Editable(false);
    end;

    var
        FormDisabled: Boolean;
        AccrualPlan: Record "Accrual Plan";
        [InDataSet]
        "Accrual Plan No.Editable": Boolean;
        [InDataSet]
        TypeEditable: Boolean;
        [InDataSet]
        "No.Editable": Boolean;
        [InDataSet]
        "Payment %Editable": Boolean;
        [InDataSet]
        "Payment Amount (LCY)Editable": Boolean;

    local procedure UpdateFields(SetToEditable: Boolean)
    begin
        "Accrual Plan No.Editable" := SetToEditable;
        TypeEditable := SetToEditable;
        "No.Editable" := SetToEditable;
        "Payment %Editable" := SetToEditable;
        "Payment Amount (LCY)Editable" := SetToEditable;
    end;

    procedure DisableForm(NewFormDisabled: Boolean)
    begin
        FormDisabled := NewFormDisabled;
    end;
}

