page 37002598 "Cont. Ledger Entries Preview"
{
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 11 NOV 15
    //   Posting preview
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018

    Caption = 'Container Ledger Entries Preview';
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "Container Ledger Entry";
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
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Container Item No."; "Container Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Container Serial No."; "Container Serial No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Container ID"; "Container ID")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Fill Item No."; "Fill Item No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Fill Variant Code"; "Fill Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Fill Lot No."; "Fill Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Fill Serial No."; "Fill Serial No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Fill Quantity"; "Fill Quantity")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Fill Quantity (Base)"; "Fill Quantity (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Fill Quantity (Alt.)"; "Fill Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Fill Unit of Measure Code"; "Fill Unit of Measure Code")
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
                        GenJnlPostPreview.ShowDimensions(DATABASE::"Container Ledger Entry", "Entry No.", "Dimension Set ID"); // P8004516
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

