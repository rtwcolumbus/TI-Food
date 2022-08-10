page 37002008 "Cost Trace"
{
    // PR4.00.04
    // P8000370A, VerticalSoft, Jack Reynolds, 08 SEP 06
    //   This form is used to display the cost trace entries
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 31 JUL 07
    //   Expand/collapse bit maps replaced from left (47) and down (4) pointing trinagles to plus (47) and minus (46)
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // P8000761, VerticalSoft, MMAS, 01 MAR 10
    //   Form into Page transformation
    //     "SourceTableView" property cleared
    //     "ShowAsTree" property set to Yes
    //     <Control1102603030>(ExpansionStatus) has been deleted
    //     Action
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Cost Trace';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    PageType = List;
    SourceTable = "Cost Trace";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                Editable = true;
                IndentationColumn = "Entry TypeIndent";
                IndentationControls = "Entry Type";
                ShowAsTree = true;
                ShowCaption = false;
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Type; Type)
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
                field("Source No."; "Source No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity (Base)"; "Quantity (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Quantity (Alt.)"; "Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Applied Quantity"; "Applied Quantity")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = "Applied QuantityHideValue";
                }
                field("Applied Quantity (Base)"; "Applied Quantity (Base)")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = AppliedQuantityBaseHideValue;
                    Visible = false;
                }
                field("Applied Quantity (Alt.)"; "Applied Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = AppliedQuantityAltHideValue;
                    Visible = false;
                }
                field("Direct Cost"; "Direct Cost")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Direct Cost (Actual)"; "Direct Cost (Actual)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Direct Cost (Expected)"; "Direct Cost (Expected)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Other Cost"; "Other Cost")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Other Cost (Actual)"; "Other Cost (Actual)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Other Cost (Expected)"; "Other Cost (Expected)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Cost; Cost)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Cost (Actual)"; "Cost (Actual)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Cost (Expected)"; "Cost (Expected)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Cost Contribution"; "Cost Contribution")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = "Cost ContributionHideValue";
                }
                field(Contribution; Contribution)
                {
                    ApplicationArea = FOODBasic;
                    HideValue = ContributionHideValue;
                    Visible = false;
                }
                field("Cost by Alternate"; "Cost by Alternate")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Ledger Entry No."; "Ledger Entry No.")
                {
                    ApplicationArea = FOODBasic;
                }
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
                action("&Value Entries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Value Entries';
                    Image = ValueLedger;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Ctrl+F7';

                    trigger OnAction()
                    var
                        ValueEntry: Record "Value Entry";
                    begin
                        case "Entry Type" of
                            "Entry Type"::Purchase .. "Entry Type"::Output:
                                begin
                                    ValueEntry.SetCurrentKey("Item Ledger Entry No.");
                                    ValueEntry.SetRange("Item Ledger Entry No.", "Ledger Entry No.");
                                    PAGE.RunModal(0, ValueEntry);
                                end;
                            "Entry Type"::"Work Center" .. "Entry Type"::"Machine Center": // P80073095
                                begin
                                    ValueEntry.SetCurrentKey("Capacity Ledger Entry No.");
                                    ValueEntry.SetRange("Capacity Ledger Entry No.", "Ledger Entry No.");
                                    PAGE.RunModal(0, ValueEntry);
                                end;
                        end;
                    end;
                }
            }
        }
        area(processing)
        {
            action("&Navigate")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Find entries...';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                ShortCutKey = 'Shift+Ctrl+I';

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc("Posting Date", "Document No.");
                    Navigate.Run;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ContributionHideValue := false;
        "Cost ContributionHideValue" := false;
        AppliedQuantityAltHideValue := false;
        AppliedQuantityBaseHideValue := false;
        "Applied QuantityHideValue" := false;
        "Entry TypeIndent" := 0;
        EntryTypeOnFormat;
        AppliedQuantityOnFormat;
        AppliedQuantityBaseOnFormat;
        AppliedQuantityAltOnFormat;
        CostContributionOnFormat;
        ContributionOnFormat;
    end;

    var
        [InDataSet]
        "Entry TypeIndent": Integer;
        [InDataSet]
        "Applied QuantityHideValue": Boolean;
        [InDataSet]
        AppliedQuantityBaseHideValue: Boolean;
        [InDataSet]
        AppliedQuantityAltHideValue: Boolean;
        [InDataSet]
        "Cost ContributionHideValue": Boolean;
        [InDataSet]
        ContributionHideValue: Boolean;

    procedure ExpansionStatus(): Integer
    begin
        if "Has Children" then begin
            if Expanded then
                exit(0)
            else
                exit(1);
        end else
            exit(2);
    end;

    local procedure ExpansionStatusOnPush()
    begin
        if not "Has Children" then
            exit;

        Validate(Expanded, not Expanded);
        CurrPage.SaveRecord;
    end;

    local procedure EntryTypeOnFormat()
    begin
        "Entry TypeIndent" := Level;
    end;

    local procedure AppliedQuantityOnFormat()
    begin
        if "Entry No." = 1 then
            "Applied QuantityHideValue" := true;
    end;

    local procedure AppliedQuantityBaseOnFormat()
    begin
        if "Entry No." = 1 then
            AppliedQuantityBaseHideValue := true;
    end;

    local procedure AppliedQuantityAltOnFormat()
    begin
        if "Entry No." = 1 then
            AppliedQuantityAltHideValue := true;
    end;

    local procedure CostContributionOnFormat()
    begin
        if "Entry No." = 1 then
            "Cost ContributionHideValue" := true;
    end;

    local procedure ContributionOnFormat()
    begin
        if "Entry No." = 1 then
            ContributionHideValue := true;
    end;
}

