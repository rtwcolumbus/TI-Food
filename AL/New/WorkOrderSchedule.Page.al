page 37002844 "Work Order Schedule"
{
    // PRW16.00.20
    // P8000671, VerticalSoft, Jack Reynolds, 18 FEB 09
    //   Re-done for pages dues to layout issues and matrix box issues
    // 
    // PRW16.00.04
    // P8000845, VerticalSoft, Jack Reynolds, 20 JUL 10
    //   Automatically resequence when entering schedule date/time
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 19 FEB 13
    //   Restoring the SaveValues Property.
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Work Order Schedule';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Listplus;
    PromotedActionCategories = 'New,Process,Report,Work Order';
    SaveValues = true;
    SourceTable = "Work Order";
    SourceTableView = SORTING(Completed, "Resource No.", "Scheduled Date", "Scheduled Time", Priority)
                      WHERE(Completed = CONST(false),
                            "Standing Order" = CONST(false));
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                group(Control37002020)
                {
                    ShowCaption = false;
                    field(BaseDate; BaseDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Base Date';
                        Editable = false;
                    }
                    field(DaysView; DaysView)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Days View';
                        MinValue = 1;

                        trigger OnValidate()
                        begin
                            SetDateRange;
                        end;
                    }
                }
                group(Control37002027)
                {
                    ShowCaption = false;
                    field(LocationFilter; LocationFilter)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Location Filter';
                        TableRelation = Location WHERE("Use As In-Transit" = CONST(false));

                        trigger OnValidate()
                        begin
                            SetFilter("Location Code", LocationFilter);
                            CurrPage.Trades.PAGE.SetLocationFilter(LocationFilter);
                            CurrPage.Update;
                        end;
                    }
                    field(ShowUnscheduled; ShowUnscheduled)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Show Unscheduled';

                        trigger OnValidate()
                        begin
                            SetDateRange;
                        end;
                    }
                }
            }
            repeater(Control37002001)
            {
                ShowCaption = false;
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field("Resource No."; "Resource No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    StyleExpr = TRUE;
                }
                field("Asset No."; "Asset No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    StyleExpr = TRUE;
                }
                field("Asset Description"; "Asset Description")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    StyleExpr = TRUE;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    StyleExpr = TRUE;
                }
                field("Scheduled Date"; "Scheduled Date")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        CurrPage.Update; // P8000845
                    end;
                }
                field("Scheduled Time"; "Scheduled Time")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        CurrPage.Update; // P8000845
                    end;
                }
                field(Priority; Priority)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Labor Hours (Remaining)"; "Labor Hours (Remaining)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Contract Hours (Remaining)"; "Contract Hours (Remaining)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Work Requested (First Line)"; "Work Requested (First Line)")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group("Activities & Trades")
            {
                Caption = 'Activities & Trades';
                part("Work Order Activity"; "Work Order Sched. Activity")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Work Order Activity';
                    Editable = false;
                    SubPageLink = "Work Order No." = FIELD("No.");
                }
                part(Trades; "Work Order Sched. Trades")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Trades';
                    Editable = false;
                }
            }
        }
        area(factboxes)
        {
            part(Control37002022; "Asset Details Factbox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("Asset No.");
            }
            systempart(Control37002024; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control37002025; Notes)
            {
                ApplicationArea = FOODBasic;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Previous Date")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Previous Date';
                Enabled = 0 < columnoffset;
                Image = PreviousSet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    ColumnOffset -= 1;
                    CurrPage.Trades.PAGE.SetOffset(ColumnOffset);
                end;
            }
            action("Next Date")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Next Date';
                Enabled = columnoffset < maxoffset;
                Image = NextSet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    ColumnOffset += 1;
                    CurrPage.Trades.PAGE.SetOffset(ColumnOffset);
                end;
            }
        }
        area(navigation)
        {
            group("WorkO&rder")
            {
                Caption = 'Work O&rder';
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    ShortCutKey = 'Shift+F7';

                    trigger OnAction()
                    var
                        WorkOrder: Record "Work Order";
                    begin
                        WorkOrder := Rec;
                        WorkOrder.SetRecFilter;
                        if WorkOrder.Completed then
                            PAGE.RunModal(PAGE::"Completed Work Order", WorkOrder)
                        else
                            PAGE.RunModal(PAGE::"Work Order", WorkOrder);
                    end;
                }
                action("Maintenance Work Order")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Maintenance Work Order';
                    Image = "Order";
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        DocPrint: Codeunit "Document-Print";
                    begin
                        DocPrint.PrintMaintWorkOrder(Rec);
                    end;
                }
                action(Complete)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Complete';
                    Ellipsis = true;
                    Image = Completed;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;

                    trigger OnAction()
                    begin
                        CompleteWorkOrder;
                        if Completed then
                            CurrPage.Update(false);
                    end;
                }
                action("E&ntries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'E&ntries';
                    Image = Entries;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
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
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    RunObject = Page "Work Order Comment Sheet";
                    RunPageLink = "No." = FIELD("No.");
                }
                action(Material)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Material';
                    Image = Inventory;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    RunObject = Page "Work Order Materials";
                    RunPageLink = "Work Order No." = FIELD("No.");
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        BaseDate := WorkDate;
        if DaysView = 0 then
            DaysView := 7;
        SetDateRange;
    end;

    var
        BaseDate: Date;
        DaysView: Integer;
        LocationFilter: Code[250];
        ShowUnscheduled: Boolean;
        [InDataSet]
        MaxOffset: Integer;
        [InDataSet]
        ColumnOffset: Integer;

    procedure SetDateRange()
    begin
        if ShowUnscheduled then
            SetRange("Scheduled Date", 0D, BaseDate + DaysView - 1)
        else
            SetRange("Scheduled Date", DMY2Date(1, 1, 0), BaseDate + DaysView - 1); // P8007748

        CurrPage.Trades.PAGE.SetDateRange(BaseDate, DaysView, ColumnOffset, MaxOffset);

        CurrPage.Update(false);
    end;
}

