page 37002763 "Whse. Staged Pick"
{
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 15 SEP 06
    //   Staged Picks
    // 
    // PR5.00
    // P8000503A, VerticalSoft, Don Bresee, 06 AUG 07
    //   Order picking options
    // 
    // PRW16.00.02
    // P8000777, VerticalSoft, Don Bresee, 03 MAR 10
    //   Remove groups that are 1 subform (created from the form tab control)
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Whse. Staged Pick';
    PageType = Document;
    PopulateAllFields = true;
    SourceTable = "Whse. Staged Pick Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update;
                    end;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        CurrPage.SaveRecord;
                        LookupLocation(Rec);
                        CurrPage.Update(true);
                    end;
                }
                field("Zone Code"; "Zone Code")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        ZoneCodeOnAfterValidate;
                    end;
                }
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        BinCodeOnAfterValidate;
                    end;
                }
                field("Staging Status"; "Staging Status")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;
                }
                field("Order Picking Status"; "Order Picking Status")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Assigned User ID"; "Assigned User ID")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Assignment Date"; "Assignment Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Assignment Time"; "Assignment Time")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Sorting Method"; "Sorting Method")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        SortingMethodOnAfterValidate;
                    end;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                }
            }
            part(WhseStagedPickLines; "Whse. Staged Pick Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Items to Stage';
                SubPageLink = "No." = FIELD("No.");
                SubPageView = SORTING("No.", "Sorting Sequence No.");
            }
            part(WhseStagedPickSourceLines; "Whse. Staged Pick Source Line")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Orders';
                SubPageLink = "No." = FIELD("No.");
            }
            group(Options)
            {
                Caption = 'Options';
                field("Staging Type"; "Staging Type")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;
                }
                field("Stage Exact Qty. Needed"; "Stage Exact Qty. Needed")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        StageExactQtyNeededOnAfterVali;
                    end;
                }
                field("Ignore Staging Bin Contents"; "Ignore Staging Bin Contents")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        IgnoreStagingBinContentsOnAfte;
                    end;
                }
                field("Order Picking Options"; "Order Picking Options")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            part(Control1901796907; "Item Warehouse FactBox")
            {
                ApplicationArea = FOODBasic;
                Provider = WhseStagedPickLines;
                SubPageLink = "No." = FIELD("Item No.");
                Visible = true;
            }
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
            group("Staged &Pick")
            {
                Caption = 'Staged &Pick';
                action(List)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'List';
                    ShortCutKey = 'Shift+Ctrl+L';

                    trigger OnAction()
                    begin
                        LookupWhseStagedPickHeader(Rec);
                    end;
                }
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Warehouse Comment Sheet";
                    RunPageLink = "Table Name" = CONST("Staged Pick"),
                                  Type = CONST(" "),
                                  "No." = FIELD("No.");
                }
                separator(Separator1102603013)
                {
                }
                action("Item &Pick Lines (To Stage)")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item &Pick Lines (To Stage)';
                    Image = ItemLines;
                    RunObject = Page "Warehouse Activity Lines";
                    RunPageLink = "Whse. Document No." = FIELD("No.");
                    RunPageView = SORTING("Whse. Document No.", "Whse. Document Type", "Activity Type")
                                  WHERE("Activity Type" = CONST(Pick),
                                        "Whse. Document Type" = CONST(FOODStagedPick));
                }
                action("Reg. Item P&ick Lines (To Stage)")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Reg. Item P&ick Lines (To Stage)';
                    Image = RegisterPick;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    RunObject = Page "Registered Whse. Act.-Lines";
                    RunPageLink = "Whse. Document No." = FIELD("No.");
                    RunPageView = SORTING("Whse. Document Type", "Whse. Document No.", "Whse. Document Line No.")
                                  WHERE("Whse. Document Type" = CONST(FOODStagedPick));
                }
                separator(Separator1102603020)
                {
                }
                action("O&rder Pick Lines (From Stage)")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'O&rder Pick Lines (From Stage)';
                    Image = PickLines;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    RunObject = Page "Warehouse Activity Lines";
                    RunPageLink = "From Staged Pick No." = FIELD("No.");
                    RunPageView = SORTING("From Staged Pick No.", "From Staged Pick Line No.", "Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.", "Unit of Measure Code", "Action Type", "Breakbulk No.", "Original Breakbulk");
                }
                action("Reg. &Order Pick Lines (From Stage)")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Reg. &Order Pick Lines (From Stage)';
                    Image = RegisterPick;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    RunObject = Page "Registered Whse. Act.-Lines";
                    RunPageLink = "From Staged Pick No." = FIELD("No.");
                    RunPageView = SORTING("From Staged Pick No.", "From Staged Pick Line No.");
                }
            }
            group("O&rders")
            {
                Caption = 'O&rders';
                action("Get &Shipments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Get &Shipments';
                    Image = GetSourceDoc;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;

                    trigger OnAction()
                    var
                        GetWhseShpts: Report "Staged Pick - Get Shipments";
                    begin
                        GetWhseShpts.SetWhseStagedPick("No.");
                        GetWhseShpts.RunModal;
                        CurrPage.Update(false);
                    end;
                }
                separator(Separator1102603009)
                {
                }
                action("Get Sales &Orders")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Get Sales &Orders';
                    Ellipsis = true;
                    Image = GetSourceDoc;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;

                    trigger OnAction()
                    var
                        GetSalesOrders: Report "Staged Pick - Get Sales Orders";
                    begin
                        GetSalesOrders.SetWhseStagedPick("No.");
                        GetSalesOrders.RunModal;
                        CurrPage.Update(false);
                    end;
                }
                action("Get &Prod. Orders")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Get &Prod. Orders';
                    Ellipsis = true;
                    Image = GetSourceDoc;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;

                    trigger OnAction()
                    var
                        GetProdOrders: Report "Staged Pick - Get Prod. Orders";
                    begin
                        GetProdOrders.SetWhseStagedPick("No.");
                        GetProdOrders.RunModal;
                        CurrPage.Update(false);
                    end;
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("Recalculate &Qty. to Stage")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Recalculate &Qty. to Stage';
                    Image = Recalculate;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        RecalcStageQtys;
                    end;
                }
                separator(Separator1102603018)
                {
                }
                action("Re&lease")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Re&lease';
                    Image = ReleaseDoc;
                    ShortCutKey = 'Ctrl+F9';

                    trigger OnAction()
                    begin
                        CurrPage.Update(true);
                        WhseStagedPickMgmt.Release(Rec);
                    end;
                }
                action("Re&open")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Re&open';
                    Image = ReOpen;

                    trigger OnAction()
                    begin
                        WhseStagedPickMgmt.Reopen(Rec);
                    end;
                }
                separator(Separator1102603003)
                {
                }
                action("&Pick Items (To Staging Bin)")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Pick Items (To Staging Bin)';
                    Ellipsis = true;
                    Image = InventoryPick;
                    ShortCutKey = 'Shift+F11';

                    trigger OnAction()
                    begin
                        CurrPage.Update(true);
                        WhseStagedPickMgmt.Release(Rec);
                        Commit;
                        CurrPage.WhseStagedPickLines.PAGE.PickCreate(Rec);
                    end;
                }
                action("Pick O&rders (From Staging Bin)")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Pick O&rders (From Staging Bin)';
                    Ellipsis = true;
                    Image = PickLines;
                    ShortCutKey = 'Ctrl+F11';

                    trigger OnAction()
                    begin
                        CurrPage.Update(true);
                        WhseStagedPickMgmt.Release(Rec);
                        Commit;
                        CurrPage.WhseStagedPickSourceLines.PAGE.PickCreate(Rec);
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(Release_Promoted; "Re&lease")
                {
                }
                actionref(PickItemsToStagingBin_Promoted; "&Pick Items (To Staging Bin)")
                {
                }
                actionref(PickOrdersFromStagingBin_Promoted; "Pick O&rders (From Staging Bin)")
                {
                }
                actionref(ItemPickLinesToStage_Promoted; "Item &Pick Lines (To Stage)")
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        OpenWhseStagedPickHeader(Rec);
    end;

    var
        WhseStagedPickMgmt: Codeunit "Whse. Staged Pick Mgmt.";

    local procedure SortingMethodOnAfterValidate()
    begin
        CurrPage.Update;
    end;

    local procedure ZoneCodeOnAfterValidate()
    begin
        CurrPage.Update;
    end;

    local procedure BinCodeOnAfterValidate()
    begin
        CurrPage.Update;
    end;

    local procedure IgnoreStagingBinContentsOnAfte()
    begin
        CurrPage.SaveRecord;
        RecalcStageQtys;
        CurrPage.Update(false);
    end;

    local procedure StageExactQtyNeededOnAfterVali()
    begin
        CurrPage.SaveRecord;
        RecalcStageQtys;
        CurrPage.Update(false);
    end;
}

