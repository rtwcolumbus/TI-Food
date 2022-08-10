page 37002443 "Accrual Ledger Entries Preview"
{
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 11 NOV 15
    //   Posting preview
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018

    Caption = 'Accrual Ledger Entries Preview';
    DataCaptionFields = "Accrual Plan Type", "Accrual Plan No.";
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "Accrual Ledger Entry";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
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
                }
                field("Accrual Plan No."; "Accrual Plan No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Scheduled Accrual No."; "Scheduled Accrual No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                }
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source Document Type"; "Source Document Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source Document No."; "Source Document No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source Document Line No."; "Source Document Line No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Price Impact"; "Price Impact")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source Code"; "Source Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Journal Batch Name"; "Journal Batch Name")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Accrual Posting Group"; "Accrual Posting Group")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Dimension Set ID"; "Dimension Set ID")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
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
                action(Dimensions)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        GenJnlPostPreview.ShowDimensions(DATABASE::"Accrual Ledger Entry", "Entry No.", "Dimension Set ID");
                    end;
                }
                action(SetDimensionFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Set Dimension Filter';
                    Ellipsis = true;
                    Image = "Filter";

                    trigger OnAction()
                    begin
                        // P80053245
                        SetFilter("Dimension Set ID", DimensionSetIDFilter.LookupFilter);
                    end;
                }
            }
        }
    }

    var
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
        DimensionSetIDFilter: Page "Dimension Set ID Filter";
}

