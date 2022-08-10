page 37002811 "Work Order List"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 31 AUG 06
    //   Standard list form for work orders
    // 
    // P8000336A, VerticalSoft, Jack Reynolds, 14 SEP 06
    //   Add controls for Standing Order
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 05 FEB 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 16 NOV 15
    //   Page Management

    Caption = 'Work Orders';
    Editable = false;
    PageType = List;
    SourceTable = "Work Order";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Asset No."; "Asset No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Asset Description"; "Asset Description")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Priority; Priority)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Standing Order"; "Standing Order")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Origination Date"; "Origination Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Scheduled Date"; "Scheduled Date")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Completion Date"; "Completion Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Work Requested (First Line)"; "Work Requested (First Line)")
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
            group("O&rder")
            {
                Caption = 'O&rder';
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;
                    ShortCutKey = 'Shift+F7';

                    trigger OnAction()
                    var
                        PageManagement: Codeunit "Page Management";
                    begin
                        // P8004516
                        PageManagement.PageRunModal(Rec);
                    end;
                }
                action("E&ntries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'E&ntries';
                    Image = Entries;
                    RunObject = Page "Maint. Ledger Entries";
                    RunPageLink = "Work Order No." = FIELD("No.");
                    RunPageView = SORTING("Work Order No.", "Posting Date", "Entry No.");
                    ShortCutKey = 'Ctrl+F7';
                }
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Work Order Comment Sheet";
                    RunPageLink = "No." = FIELD("No.");
                }
                action(Dimensions)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Dimensions';
                    Image = Dimensions;

                    trigger OnAction()
                    begin
                        ShowDocDim;
                    end;
                }
                separator(Separator1102603029)
                {
                }
                action(Labor)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Labor';
                    Image = ServiceMan;
                    RunObject = Page "Work Order Activities";
                    RunPageLink = "Work Order No." = FIELD("No.");
                    RunPageView = WHERE(Type = CONST(Labor));
                }
                action(Material)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Material';
                    Image = Inventory;
                    RunObject = Page "Work Order Materials";
                    RunPageLink = "Work Order No." = FIELD("No.");
                }
                action(Contract)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Contract';
                    Image = List;
                    RunObject = Page "Work Order Activities";
                    RunPageLink = "Work Order No." = FIELD("No.");
                    RunPageView = WHERE(Type = CONST(Contract));
                }
            }
        }
    }
}

