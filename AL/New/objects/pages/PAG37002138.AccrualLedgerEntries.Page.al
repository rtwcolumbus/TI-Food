page 37002138 "Accrual Ledger Entries"
{
    // PR3.61AC
    // 
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 30 JAN 09
    //   Transformed - additions in TIF Editor
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
    //
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 01 JUN 22
    //   Cleanup Role Centers and Navigate (Find Entries)

    Caption = 'Accrual Ledger Entries';
    DataCaptionFields = "Accrual Plan Type", "Accrual Plan No.";
    Editable = false;
    PageType = List;
    SourceTable = "Accrual Ledger Entry";

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
                        ShowDimensions;      // P8001133
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
                ShortCutKey = 'Ctrl+Alt+Q'; // P800144605

                trigger OnAction()
                begin
                    Navigate.SetDoc("Posting Date", "Document No.");
                    Navigate.Run;
                end;
            }
        }
        area(Promoted)
        {
            actionref(Navigate_Promoted; "&Navigate")
            {
            }
        }
    }

    var
        Navigate: Page Navigate;
        DimensionSetIDFilter: Page "Dimension Set ID Filter";
}

