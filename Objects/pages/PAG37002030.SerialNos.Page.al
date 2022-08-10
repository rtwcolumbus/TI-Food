page 37002030 "Serial Nos."
{
    // PR3.70.07
    // P8000140A, Myers Nissi, Jack Reynolds, 19 NOV 04
    //   Support for serialized containers
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 13 APR 09
    //    Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 9 NOV 15
    //   NAV 2016 refactoring
    // 
    // PRW120.00
    // P800144605, To Increase, Jack Reynolds, 20 APR 22
    //   Upgrade to 20.0

    Caption = 'Serial Nos.';
    CardPageID = "Serial No. Information Card";
    Editable = false;
    PageType = List;
    SourceTable = "Serial No. Information";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Container ID"; "Container ID")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Tare Weight"; "Tare Weight")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Tare Unit of Measure"; "Tare Unit of Measure")
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
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Serial &No.")
            {
                Caption = 'Serial &No.';
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;
                    RunObject = Page "Serial No. Information Card";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code"),
                                  "Serial No." = FIELD("Serial No.");
                    ShortCutKey = 'Shift+Ctrl+L';
                }
                action("Container Ledger Entries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Container Ledger Entries';
                    Image = LedgerEntries;
                    RunObject = Page "Container Ledger Entries";
                    RunPageLink = "Container Item No." = FIELD("Item No."),
                                  "Container Serial No." = FIELD("Serial No.");
                    RunPageView = SORTING("Container Item No.", "Container Serial No.", "Posting Date");
                    ShortCutKey = 'Ctrl+F7';
                }
                action("Item Tracking Entries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Tracking Entries';
                    Image = ItemTrackingLedger;

                    trigger OnAction()
                    var
                        ItemTrackingSetup: Record "Item Tracking Setup";
                        ItemTrackingDocMgt: Codeunit "Item Tracking Doc. Management";
                    begin
                        ItemTrackingSetup."Serial No." := Rec."Serial No."; // P800144605
                        ItemTrackingDocMgt.ShowItemTrackingForEntity(0, '', Rec."Item No.", Rec."Variant Code", '', ItemTrackingSetup); // P8004516, P800144605
                    end;
                }
                action(Comment)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Comment';
                    Image = Comment;
                    RunObject = Page "Item Tracking Comments";
                    RunPageLink = Type = CONST("Serial No."),
                                  "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code"),
                                  "Serial/Lot No." = FIELD("Serial No.");
                }
            }
        }
    }
}

