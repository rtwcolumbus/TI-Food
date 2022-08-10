page 37002852 "Completed Work Order List"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 31 AUG 06
    //   Standard list form for work orders
    // 
    // P8000336A, VerticalSoft, Jack Reynolds, 14 SEP 06
    //   Add controls for Standing Order
    // 
    // PRW16.00.01
    // P8000718, VerticalSoft, Jack Reynolds, 10 AUG 09
    //   Add controls for downtime
    // 
    // PRW16.00.20
    // P8000671, VerticalSoft, Jack Reynolds, 04 FEB 09
    //   List page of completed work orders; copied form Work Order List
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds 10 JAN 17
    //   Update Images for actions
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Completed Work Orders';
    CardPageID = "Completed Work Order";
    Editable = false;
    PageType = List;
    SourceTable = "Work Order";
    SourceTableView = WHERE(Completed = CONST(true));
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Control37002003)
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
                field("Downtime (Hours)"; "Downtime (Hours)")
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
            part(Control1900000003; "Asset Details Factbox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("Asset No.");
                Visible = true;
            }
            systempart(Control1900000004; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1900000005; Notes)
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
            group("O&rder")
            {
                Caption = 'O&rder';
                action("E&ntries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'E&ntries';
                    Image = Entries;
                    Promoted = true;
                    PromotedCategory = Process;
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
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Work Order Activities";
                    RunPageLink = "Work Order No." = FIELD("No.");
                    RunPageView = WHERE(Type = CONST(Labor));
                }
                action(Material)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Material';
                    Image = Inventory;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Work Order Materials";
                    RunPageLink = "Work Order No." = FIELD("No.");
                }
                action(Contract)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Contract';
                    Image = List;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Work Order Activities";
                    RunPageLink = "Work Order No." = FIELD("No.");
                    RunPageView = WHERE(Type = CONST(Contract));
                }
            }
        }
        area(processing)
        {
            action("&Navigate")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Navigate;
                end;
            }
        }
        area(reporting)
        {
            action("Work Order Summary")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Work Order Summary';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Work Order Summary";
            }
            action("Work Order History")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Work Order History';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Work Order History";
            }
        }
    }
}

