#if not CLEAN21
page 36728 "Bank Rec Worksheet FactBox"
{
    Caption = 'Bank Rec Worksheet';
    PageType = CardPart;
    SourceTable = "Bank Rec. Header";
    ObsoleteReason = 'Deprecated in favor of W1 Bank Reconciliation';
    ObsoleteState = Pending;
    ObsoleteTag = '21.0';
    layout
    {
        area(content)
        {
            field("Bank Account No."; Rec."Bank Account No.")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                Lookup = false;
                ToolTip = 'Specifies the code for the bank account the reconciliation applies to.';
            }
            field("Statement No."; Rec."Statement No.")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the statement number to be reconciled.';
            }
            field("Statement Date"; Rec."Statement Date")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the as-of date of the statement. All G/L balances will be calculated based upon this date.';
            }
            field("Currency Code"; Rec."Currency Code")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies the currency code assigned to the bank account.';
            }
            field("Currency Factor"; Rec."Currency Factor")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies currency conversions when posting adjustments for bank accounts with a foreign currency code assigned.';
            }
            field("Date Created"; Rec."Date Created")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies a date automatically populated when the record is created.';
            }
            field("Time Created"; Rec."Time Created")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the  time created, which is automatically populated when the record is created.';
            }
            field("Created By"; Rec."Created By")
            {
                ApplicationArea = Basic, Suite;
                AssistEdit = false;
                DrillDown = false;
                Editable = false;
                Lookup = false;
                ToolTip = 'Specifies the User ID of the person who created the record.';
            }
            field("Cleared With./Chks. Per Stmnt."; Rec."Cleared With./Chks. Per Stmnt.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the total of withdrawals or checks that cleared the bank for this statement.';
            }
            field("Total Cleared Checks"; Rec."Total Cleared Checks")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the total amount of the cleared checks for the statement being reconciled.';
            }
            field("Cleared Inc./Dpsts. Per Stmnt."; Rec."Cleared Inc./Dpsts. Per Stmnt.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the total of increases or deposits that cleared the bank for this statement.';
            }
            field("Total Cleared Deposits"; Rec."Total Cleared Deposits")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the total amount of the cleared deposits for the statement being reconciled.';
            }
            field(TotalAdjustments; "Total Adjustments" - "Total Balanced Adjustments")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Total Adjustments';
                ToolTip = 'Specifies the total amount of the lines that are adjustments.';
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        CalcLineInfo();
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        exit(Find(Which));
    end;

    trigger OnOpenPage()
    begin
        CalcLineInfo();
    end;

    var
        CurrentDate: Date;

    procedure CalcLineInfo()
    begin
        SetRange("Bank Account No.");
        SetRange("Statement No.");

        if CurrentDate <> WorkDate() then
            CurrentDate := WorkDate();

        SetRange("Date Filter", 0D, CurrentDate);

        CalcFields("Total Cleared Checks", "Total Cleared Deposits",
          "Total Adjustments", "Total Balanced Adjustments");
    end;
}

#endif