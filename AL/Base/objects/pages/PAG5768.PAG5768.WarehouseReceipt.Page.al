page 5768 "Warehouse Receipt"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 10-04-2015, Initial Version
    // --------------------------------------------------------------------------------
    // 
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Support for running for order receiving
    // 
    // PRW16.00
    // P8000645, VerticalSoft, Jack Reynolds, 26 NOV 08
    //   Relocate code from OnPush triggers to functions
    // 
    // PRW16.00.02
    // P8000756, VerticalSoft, Jack Reynolds, 12 JAN 10
    //   Incorporate P800 mods into NAV 2009 SP1
    // 
    // P8000777, VerticalSoft, Don Bresee, 03 MAR 10
    //   Remove HeaderVisible use in properties
    // 
    // PRW16.00.03
    // P8000828, VerticalSoft, Don Bresee, 21 JUN 10
    //   Add logic to eliminate modal windows for the RTC
    // 
    // PRW19.00.01
    // P8006916, To-Increase, Jack Reynolds, 31 AUG 16
    //   FOOD-TOM Separation

    Caption = 'Warehouse Receipt';
    PageType = Document;
    PopulateAllFields = true;
    RefreshOnActivate = true;
    SourceTable = "Warehouse Receipt Header";

    layout
    {
        area(content)
        {
            group(Header)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the code of the location in which the items are being received.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        CurrPage.SaveRecord();
                        LookupLocation(Rec);
                        CurrPage.Update(true);
                    end;
                }
                field("Zone Code"; Rec."Zone Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the zone in which the items are being received if you are using directed put-away and pick.';
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the bin where the items are picked or put away.';
                }
                field("Document Status"; Rec."Document Status")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the status of the warehouse receipt.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the posting date of the warehouse receipt.';
                }
                field("Vendor Shipment No."; Rec."Vendor Shipment No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the vendor''s shipment number. It is inserted in the corresponding field on the source document during posting.';
                }
                field("Assigned User ID"; Rec."Assigned User ID")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the ID of the user who is responsible for the document.';
                }
                field("Assignment Date"; Rec."Assignment Date")
                {
                    ApplicationArea = Warehouse;
                    Editable = false;
                    ToolTip = 'Specifies the date when the user was assigned the activity.';
                }
                field("Assignment Time"; Rec."Assignment Time")
                {
                    ApplicationArea = Warehouse;
                    Editable = false;
                    ToolTip = 'Specifies the time when the user was assigned the activity.';
                }
                field("Sorting Method"; Rec."Sorting Method")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the method by which the receipts are sorted.';

                    trigger OnValidate()
                    begin
                        SortingMethodOnAfterValidate();
                    end;
                }
                field("Loading Dock"; "Loading Dock")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            part(WhseReceiptLines; "Whse. Receipt Subform")
            {
                ApplicationArea = Warehouse;
                Editable = IsReceiptLinesEditable;
                Enabled = IsReceiptLinesEditable;
                SubPageLink = "No." = FIELD("No.");
                SubPageView = SORTING("No.", "Sorting Sequence No.");
            }
        }
        area(factboxes)
        {
            part(Control1901796907; "Item Warehouse FactBox")
            {
                ApplicationArea = Warehouse;
                Provider = WhseReceiptLines;
                SubPageLink = "No." = FIELD("Item No.");
                Visible = true;
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Receipt")
            {
                Caption = '&Receipt';
                Image = Receipt;
#if not CLEAN19
                action(List)
                {
                    ApplicationArea = Location;
                    Caption = 'List';
                    Image = OpportunitiesList;
                    ToolTip = 'View all warehouse documents of this type that exist.';
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by platform capabilities.';
                    ObsoleteTag = '19.0';

                    trigger OnAction()
                    begin
                        LookupWhseRcptHeader(Rec);
                    end;
                }
#endif
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Warehouse Comment Sheet";
                    RunPageLink = "Table Name" = CONST("Whse. Receipt"),
                                  Type = CONST(" "),
                                  "No." = FIELD("No.");
                    ToolTip = 'View or add comments for the record.';
                }
                action("Posted &Whse. Receipts")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Posted &Whse. Receipts';
                    Image = PostedReceipts;
                    RunObject = Page "Posted Whse. Receipt List";
                    RunPageLink = "Whse. Receipt No." = FIELD("No.");
                    RunPageView = SORTING("Whse. Receipt No.");
                    ToolTip = 'View the quantity that has been posted as received.';
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Use Filters to Get Src. Docs.")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Use Filters to Get Src. Docs.';
                    Ellipsis = true;
                    Image = UseFilters;
                    ToolTip = 'Retrieve the released source document lines that define which items to receive or ship.';

                    trigger OnAction()
                    var
                        GetSourceDocInbound: Codeunit "Get Source Doc. Inbound";
                    begin
                        if RunFromOrderRec then // P8000282A
                            exit;                 // P8000282A

                        GetSourceDocInbound.GetInboundDocs(Rec);
                    end;
                }
                action("Get Source Documents")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Get Source Documents';
                    Ellipsis = true;
                    Image = GetSourceDoc;
                    ShortCutKey = 'Shift+F11';
                    ToolTip = 'Open the list of released source documents, such as purchase orders, to select the document to receive items for. ';

                    trigger OnAction()
                    var
                        GetSourceDocInbound: Codeunit "Get Source Doc. Inbound";
                    begin
                        if RunFromOrderRec then // P8000282A
                            exit;                 // P8000282A

                        GetSourceDocInbound.GetSingleInboundDoc(Rec);
                    end;
                }
                separator(Action24)
                {
                    Caption = '';
                }
                action("Autofill Qty. to Receive")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Autofill Qty. to Receive';
                    Image = AutofillQtyToHandle;
                    ToolTip = 'Have the system enter the outstanding quantity in the Qty. to Receive field.';

                    trigger OnAction()
                    begin
                        AutofillQtyToReceive();
                    end;
                }
                action("Delete Qty. to Receive")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Delete Qty. to Receive';
                    Image = DeleteQtyToHandle;
                    ToolTip = 'Have the system clear the value in the Qty. To Receive field. ';

                    trigger OnAction()
                    begin
                        DeleteQtyToReceive();
                    end;
                }
                separator(Action40)
                {
                }
                action(CalculateCrossDock)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Calculate Cross-Dock';
                    Image = CalculateCrossDock;
                    ToolTip = 'Open the Cross-Dock Opportunities window to see details about the lines requesting the item, such as type of document, quantity requested, and due date. This information might help you to decide how much to cross-dock, where to place the items in the cross-dock area, or how to group them.';

                    trigger OnAction()
                    var
                        CrossDockOpp: Record "Whse. Cross-Dock Opportunity";
                        CrossDockMgt: Codeunit "Whse. Cross-Dock Management";
                    begin
                        CrossDockMgt.CalculateCrossDockLines(CrossDockOpp, '', "No.", "Location Code");
                    end;
                }
                action("Con&tainers")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Con&tainers';
                    Ellipsis = true;
                    Image = Inventory;
                    ShortCutKey = 'Ctrl+T';

                    trigger OnAction()
                    begin
                        // P8001323
                        ContainerSpecification;
                    end;
                }
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action("Post Receipt")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'P&ost Receipt';
                    Image = PostOrder;
                    ShortCutKey = 'F9';
                    ToolTip = 'Post the items as received. A put-away document is created automatically.';

                    trigger OnAction()
                    begin
                        WhsePostRcptYesNo();

                        if Posted and RunFromOrderRec then                      // P8000282A
                                                                                // CurrPage.CLOSE;                                       // P8000282A, P8000828
                            P800WhseMgmt.WhseReceiptAfterPost(Rec);                  // P8000828
                    end;
                }
                action("Post and &Print")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Post and &Print';
                    Image = PostPrint;
                    ShortCutKey = 'Shift+F9';
                    ToolTip = 'Finalize and prepare to print the document or journal. The values and quantities are posted to the related accounts. A report request window where you can specify what to include on the print-out.';

                    trigger OnAction()
                    begin
                        WhsePostRcptPrintPostedRcpt();

                        if Posted and RunFromOrderRec then                      // P8000576
                                                                                // CurrPage.CLOSE;                                       // P8000576, P8000828
                            P800WhseMgmt.WhseReceiptAfterPost(Rec);                  // P8000828
                    end;
                }
                action("Post and Print P&ut-away")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Post and Print P&ut-away';
                    Image = PostPrint;
                    ShortCutKey = 'Shift+Ctrl+F9';
                    ToolTip = 'Post the items as received and print the put-away document.';

                    trigger OnAction()
                    begin
                        WhsePostRcptPrint();

                        if Posted and RunFromOrderRec then                      // P8000576
                                                                                // CurrPage.CLOSE;                                       // P8000576, P8000828
                            P800WhseMgmt.WhseReceiptAfterPost(Rec);                  // P8000828
                    end;
                }
            }
            action("&Print")
            {
                ApplicationArea = Warehouse;
                Caption = '&Print';
                Ellipsis = true;
                Image = Print;
                ToolTip = 'Prepare to print the document. A report request window for the document opens where you can specify what to include on the print-out.';

                trigger OnAction()
                begin
                    WhseDocPrint.PrintRcptHeader(Rec);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 1.';

                group(Category_Category5)
                {
                    Caption = 'Posting', Comment = 'Generated from the PromotedActionCategories property index 4.';
                    ShowAs = SplitButton;

                    actionref("Post Receipt_Promoted"; "Post Receipt")
                    {
                    }
                    actionref("Post and &Print_Promoted"; "Post and &Print")
                    {
                    }
                    actionref("Post and Print P&ut-away_Promoted"; "Post and Print P&ut-away")
                    {
                    }
                }
                group("Category_Qty. to Receive")
                {
                    Caption = 'Qty. to Receive';
                    ShowAs = SplitButton;

                    actionref("Autofill Qty. to Receive_Promoted"; "Autofill Qty. to Receive")
                    {
                    }
                    actionref("Delete Qty. to Receive_Promoted"; "Delete Qty. to Receive")
                    {
                    }
                }
                actionref(CalculateCrossDock_Promoted; CalculateCrossDock)
                {
                }
                actionref(Containers_Promoted; "Con&tainers")
                {
                }
            }
            group(Category_Category8)
            {
                Caption = 'Prepare', Comment = 'Generated from the PromotedActionCategories property index 7.';

                actionref("Get Source Documents_Promoted"; "Get Source Documents")
                {
                }
                actionref("Use Filters to Get Src. Docs._Promoted"; "Use Filters to Get Src. Docs.")
                {
                }
            }
            group(Category_Category4)
            {
                Caption = 'Print/Send', Comment = 'Generated from the PromotedActionCategories property index 3.';

                actionref("&Print_Promoted"; "&Print")
                {
                }
            }
            group(Category_Category6)
            {
                Caption = 'Receipt', Comment = 'Generated from the PromotedActionCategories property index 5.';

                actionref("Co&mments_Promoted"; "Co&mments")
                {
                }

                separator(Navigate_Separator)
                {
                }

                actionref("Posted &Whse. Receipts_Promoted"; "Posted &Whse. Receipts")
                {
                }
            }
            group(Category_Category7)
            {
                Caption = 'Navigate', Comment = 'Generated from the PromotedActionCategories property index 6.';
            }
            group(Category_Report)
            {
                Caption = 'Report', Comment = 'Generated from the PromotedActionCategories property index 2.';
            }
        }
    }

    trigger OnOpenPage()
    var
        WMSManagement: Codeunit "WMS Management";
    begin
        Rec.ErrorIfUserIsNotWhseEmployee();
        Rec.FilterGroup(2); // set group of filters user cannot change
        Rec.SetFilter("Location Code", WMSManagement.GetWarehouseEmployeeLocationFilter(UserId));
        Rec.FilterGroup(0); // set filter group back to standard

        ActivateControls();

        // P8000282A
        if not RunFromOrderRec then
            ShowHeader := true;

        BottomMargin := FrmHeight - (WhseReceiptLinesYPos + WhseReceiptLinesHeight);
        HdrPos := HeaderYPos;
        HdrHeight := HeaderHeight;

        SetHeaderDisplay(ShowHeader);
        // P8000282A
    end;

    var
        RunFromOrderRec: Boolean;
        Posted: Boolean;
        ShowHeader: Boolean;
        BottomMargin: Integer;
        HdrPos: Integer;
        HdrHeight: Integer;
        WhseReceiptLinesYPos: Integer;
        HeaderYPos: Integer;
        WhseReceiptLinesHeight: Integer;
        HeaderHeight: Integer;
        FrmHeight: Integer;
        [InDataSet]
        HeaderVisible: Boolean;
        P800WhseMgmt: Codeunit "Process 800 Warehouse Mgmt.";
        WhseDocPrint: Codeunit "Warehouse Document-Print";
        [InDataSet]
        IsReceiptLinesEditable: Boolean;

    local procedure ActivateControls()
    begin
        IsReceiptLinesEditable := Rec.ReceiptLinesEditable();
    end;

    local procedure AutofillQtyToReceive()
    begin
        CurrPage.WhseReceiptLines.PAGE.AutofillQtyToReceive();
    end;

    local procedure DeleteQtyToReceive()
    begin
        CurrPage.WhseReceiptLines.PAGE.DeleteQtyToReceive();
    end;

    local procedure WhsePostRcptYesNo()
    begin
        CurrPage.WhseReceiptLines.PAGE.WhsePostRcptYesNo();
        Posted := CurrPage.WhseReceiptLines.PAGE.ReceiptPosted; // P8000645
    end;

    local procedure WhsePostRcptPrint()
    begin
        CurrPage.WhseReceiptLines.PAGE.WhsePostRcptPrint();
        Posted := CurrPage.WhseReceiptLines.PAGE.ReceiptPosted; // P8000645
    end;

    local procedure WhsePostRcptPrintPostedRcpt()
    begin
        CurrPage.WhseReceiptLines.PAGE.WhsePostRcptPrintPostedRcpt();
        Posted := CurrPage.WhseReceiptLines.PAGE.ReceiptPosted; // P8000576
    end;

    local procedure SortingMethodOnAfterValidate()
    begin
        CurrPage.Update();
    end;

    procedure RunFromOrderReceiving(OrderRec: Boolean)
    begin
        // P8000282A
        RunFromOrderRec := OrderRec;
    end;

    procedure ReceiptPosted(): Boolean
    begin
        // P8000282A
        exit(Posted);
    end;

    procedure SetHeaderDisplay(Display: Boolean)
    var
        LineBottom: Integer;
    begin
        // P8000282A
        LineBottom := FrmHeight - BottomMargin;
        HeaderVisible := Display;
        if Display then
            WhseReceiptLinesYPos := HdrPos + HdrHeight + 220
        else
            ;
        WhseReceiptLinesHeight := LineBottom - WhseReceiptLinesYPos;
    end;

    local procedure ShowHeaderOnPush()
    begin
        SetHeaderDisplay(ShowHeader);
    end;
}

