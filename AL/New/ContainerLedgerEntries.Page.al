page 37002578 "Container Ledger Entries"
{
    // PR3.70.07
    // P8000140A, Myers Nissi, Jack Reynolds, 19 NOV 04
    //   Standard ledger form for container ledger entries
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 02 FEB 09
    //   Transformed - additions in TIF Editor
    // P8000782, VerticalSoft, Rick Tweedle, 02 MAR 10
    //   Transformed to Page using transfor tool
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018

    Caption = 'Container Ledger Entries';
    Editable = false;
    PageType = List;
    SourceTable = "Container Ledger Entry";

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
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Dimension Set ID"; "Dimension Set ID")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
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
                action(Dimensions)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        ShowDimensions; // P8001133
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
                begin
                    Navigate.SetDoc("Posting Date", "Document No.");
                    Navigate.Run;
                end;
            }
        }
    }

    var
        Navigate: Page Navigate;
        DimensionSetIDFilter: Page "Dimension Set ID Filter";
}

