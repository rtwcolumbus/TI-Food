page 37002028 "Phys. Inv. Jnl. w/ Tracking"
{
    // PR2.00
    //   Support for physical count with item tracking
    //     Subform to enter item tracking data
    //     Tracking menu button to perform tasks with lines on subform
    // 
    // PR3.61
    //   Update for new item tracking
    //   Add fields/logic for alternate quantities
    // 
    // PR3.61.01
    //   Setting of Phys. Inventory flag moved from OnNewRecord to SetupNewLine
    // 
    // PR3.70.07
    // P8000138A, Myers Nissi, Jack Reynolds, 28 OCT 04
    //   Integrate 3.70 Service Pack 2
    // 
    // PR4.00
    // P8000250B, Myers Nissi, Jack Reynolds, 18 OCT 05
    //   Support for alternate lot number assignemnt methods
    // 
    // PR4.00.01
    // P8000267B, VerticalSoft, Jack Reynolds, 12 DEC 05
    //   Add code to Item No. OnLookup to be in line with SP1 changes to standard forms
    // 
    // PR4.00.04
    // P8000380A, VerticalSoft, Jack Reynolds, 21 SEP 06
    //   Fix problem with entering quantity on new lines (not yet inserted)
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 31 JUL 07
    //   Added Print button to run physical inventory list
    // 
    // PRW15.00.02
    // P8000613A, VerticalSoft, Jack Reynolds, 04 AUG 08
    //   Right border on form was missing
    // 
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add 1-Doc Whse Logic
    // 
    // PRW16.00.01
    // P8000683, VerticalSoft, Jack Reynolds, 23 MAR 09
    //   Fix problem deleting lines with tracking
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 09 APR 09
    //   Transformed - additions in TIF Editor
    //   Page changes made after transformation
    // 
    // PRW16.00.03
    // P8000817, VerticalSoft, Jack Reynolds, 26 APR 10
    //   Change visible property of fields
    // 
    // PRW16.00.05
    // P8000947, Columbus IT, Jack Reynolds, 25 MAY 11
    //   Fix problem deleting lines with tracking
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001104, Columbus IT, Don Bresee, 12 OCT 12
    //   Add Sort By Bin option, sort lines accordingly, change page property SaveValues to Yes
    //   Add logic to assign the "Line No." for any key, change page property AutoSplitKey to No
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW17.10
    // P8001234, Columbus IT, Jack Reynolds, 01 NOV 13
    //    Support for custom lot number formats
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds 17 NOV 13
    //   Lookup of Shortcut Dimensions, Standardize OpenedFromBatch
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Phys. Inventory Journal';
    DataCaptionFields = "Journal Batch Name";
    DelayedInsert = true;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Item Journal Line";

    layout
    {
        area(content)
        {
            group(Control37002040)
            {
                ShowCaption = false;
                field(CurrentJnlBatchName; CurrentJnlBatchName)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Batch Name';
                    Lookup = true;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        CurrPage.SaveRecord;
                        ItemJnlMgt.LookupName(CurrentJnlBatchName, Rec);
                        CurrPage.Update(false);
                    end;

                    trigger OnValidate()
                    begin
                        ItemJnlMgt.CheckName(CurrentJnlBatchName, Rec);

                        CurrPage.SaveRecord;
                        ItemJnlMgt.SetName(CurrentJnlBatchName, Rec);
                        CurrPage.Update(false);
                    end;
                }
                field(SortByBin; SortByBin)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Sort By Bin';

                    trigger OnValidate()
                    begin
                        SetSortByBin(SortByBin); // P8001104
                        CurrPage.Update;         // P8001104
                    end;
                }
            }
            repeater(Control37002002)
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
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = FOODBasic;
                    OptionCaption = 'Purchase,Sale,Positive Adjmt.,Negative Adjmt.';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupItemNo;                         // P8000267B
                        ShowShortcutDimCode(ShortcutDimCode); // P8000267B
                    end;

                    trigger OnValidate()
                    begin
                        ShowShortcutDimCode(ShortcutDimCode);
                        if "Line No." = 0 then // P8000380A
                            CurrPage.SaveRecord; // P8000380A
                    end;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = DimVisible1;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = DimVisible2;
                }
                field("ShortcutDimCode[3]"; ShortcutDimCode[3])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,3';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible3;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field("ShortcutDimCode[4]"; ShortcutDimCode[4])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,4';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(4),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible4;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field("ShortcutDimCode[5]"; ShortcutDimCode[5])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,5';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(5),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible5;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field("ShortcutDimCode[6]"; ShortcutDimCode[6])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,6';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(6),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible6;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field("ShortcutDimCode[7]"; ShortcutDimCode[7])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,7';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(7),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible7;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field("ShortcutDimCode[8]"; ShortcutDimCode[8])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,8';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(8),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible8;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = true;
                }
                field("Container License Plate"; "Container License Plate")
                {
                    ApplicationArea = FOODBasic;
                    AccessByPermission = TableData "Container Header" = R;
                    Visible = false;
                }
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Control37002038; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Control37002037; "Serial No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Salespers./Purch. Code"; "Salespers./Purch. Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Gen. Bus. Posting Group"; "Gen. Bus. Posting Group")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Gen. Prod. Posting Group"; "Gen. Prod. Posting Group")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Qty. (Calculated)"; "Qty. (Calculated)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Qty. (Phys. Inventory)"; "Qty. (Phys. Inventory)")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Qty. (Alt.) (Calculated)"; "Qty. (Alt.) (Calculated)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Qty. (Alt.) (Phys. Inventory)"; "Qty. (Alt.) (Phys. Inventory)")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        // PR3.60
                        CurrPage.SaveRecord;
                        AltQtyMgmt.ShowItemJnlAltQtyLines(Rec);
                        CurrPage.Update;
                        // PR3.60
                    end;

                    trigger OnValidate()
                    begin
                        // PR3.60
                        CurrPage.SaveRecord;
                        AltQtyMgmt.ValidateItemJnlAltQtyLine(Rec);
                        CurrPage.Update;
                        // PR3.60
                    end;
                }
                field("Quantity (Alt.)"; "Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Unit Amount"; "Unit Amount")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Indirect Cost %"; "Indirect Cost %")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Applies-to Entry"; "Applies-to Entry")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Reason Code"; "Reason Code")
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
            group("&Tracking")
            {
                Caption = '&Tracking';
                action("Assign &Serial No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Assign &Serial No.';
                    Image = CreateSerialNo;

                    trigger OnAction()
                    var
                        Item: Record Item;
                        NoSeriesMgt: Codeunit NoSeriesManagement;
                    begin
                        // PR3.61
                        if ("Serial No." = '') and Item.Get("Item No.") then begin
                            Item.TestField("Serial Nos.");
                            Validate("Serial No.", NoSeriesMgt.GetNextNo(Item."Serial Nos.", WorkDate, true));
                            CurrPage.SaveRecord;
                        end;
                        // PR3.61
                    end;
                }
                action("Assign &Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Assign &Lot No.';
                    Image = LotInfo;

                    trigger OnAction()
                    var
                        Item: Record Item;
                        NoSeriesMgt: Codeunit NoSeriesManagement;
                    begin
                        // PR3.61
                        if ("Lot No." = '') and Item.Get("Item No.") then begin
                            Validate("Lot No.", P800ItemTracking.AssignLotNo(Rec)); // P8000250B, P8001234
                            CurrPage.SaveRecord;
                        end;
                        // PR3.61
                    end;
                }
                group(Information)
                {
                    Caption = 'Information';
                    action("Serial No.")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Serial No.';
                        Image = SerialNo;

                        trigger OnAction()
                        var
                            SerialInfo: Record "Serial No. Information";
                        begin
                            // PR3.61
                            TestField("Serial No.");
                            if SerialInfo.Get("Item No.", "Variant Code", "Serial No.") then
                                PAGE.RunModal(PAGE::"Serial No. Information Card", SerialInfo);
                            // PR3.61
                        end;
                    }
                    action("Lot No.")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Lot No.';
                        Image = Lot;

                        trigger OnAction()
                        var
                            LotNoInfo: Record "Lot No. Information";
                        begin
                            // PR3.61
                            TestField("Lot No.");
                            if LotNoInfo.Get("Item No.", "Variant Code", "Lot No.") then
                                PAGE.RunModal(PAGE::"Lot No. Information Card", LotNoInfo);
                            // PR3.61
                        end;
                    }
                }
            }
            group("&Line")
            {
                Caption = '&Line';
                action(Dimensions)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        ShowDimensions;      // P8001133
                        CurrPage.SaveRecord; // P8001133
                    end;
                }
                action("Item &Tracking Lines")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item &Tracking Lines';
                    Image = ItemTrackingLines;
                    Visible = false;

                    trigger OnAction()
                    begin
                        OpenItemTrackingLines(false);
                    end;
                }
                action("New Container")
                {
                    ApplicationArea = FOODBasic;
                    AccessByPermission = TableData "Container Header" = R;
                    Caption = 'New Container';
                    Image = NewItem;

                    trigger OnAction()
                    var
                        ContainerFns: Codeunit "Container Functions";
                    begin
                        // P8001323
                        ContainerFns.NewContainerOnItemJournalLine(Rec);
                        CurrPage.Update;
                    end;
                }
            }
            group("&Item")
            {
                Caption = '&Item';
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;
                    RunObject = Page "Item Card";
                    RunPageLink = "No." = FIELD("Item No.");
                    ShortCutKey = 'Shift+F7';
                }
                action("Ledger E&ntries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Ledger E&ntries';
                    Image = LedgerEntries;
                    RunObject = Page "Item Ledger Entries";
                    RunPageLink = "Item No." = FIELD("Item No.");
                    RunPageView = SORTING("Item No.");
                    ShortCutKey = 'Ctrl+F7';
                }
                action("Phys. In&ventory Ledger Entries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Phys. In&ventory Ledger Entries';
                    Image = PhysicalInventoryLedger;
                    RunObject = Page "Phys. Inventory Ledger Entries";
                    RunPageLink = "Item No." = FIELD("Item No.");
                    RunPageView = SORTING("Item No.");
                }
                group("Item Availability by")
                {
                    Caption = 'Item Availability by';
                    action("Event")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Event';
                        Image = "Event";
                        
                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItemJnlLine(Rec, ItemAvailFormsMgt.ByEvent)
                        end;
                    }
                    action(Period)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Period';
                        Image = Period;
                        
                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItemJnlLine(Rec, ItemAvailFormsMgt.ByPeriod)
                        end;
                    }
                    action(Variant)
                    {
                        ApplicationArea = Planning;
                        Caption = 'Variant';
                        Image = ItemVariant;
                        
                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItemJnlLine(Rec, ItemAvailFormsMgt.ByVariant)
                        end;
                    }
                    action(Location)
                    {
                        AccessByPermission = TableData Location = R;
                        ApplicationArea = Location;
                        Caption = 'Location';
                        Image = Warehouse;

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItemJnlLine(Rec, ItemAvailFormsMgt.ByLocation)
                        end;
                    }
                    action(Lot)
                    {
                        ApplicationArea = ItemTracking;
                        Caption = 'Lot';
                        Image = LotInfo;

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItemJnlLine(Rec, ItemAvailFormsMgt.ByLot)
                        end;
                    }
                    action("BOM Level")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'BOM Level';
                        Image = BOMLevel;
                        
                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItemJnlLine(Rec, ItemAvailFormsMgt.ByBOM)
                        end;
                    }
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("Calculate &Inventory")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Calculate &Inventory';
                    Ellipsis = true;
                    Image = CalculateInventory;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        CalcQtyOnHand.SetItemJnlLine(Rec);
                        CalcQtyOnHand.RunModal;
                        Clear(CalcQtyOnHand);
                    end;
                }
                action("&Calculate Counting Period")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Calculate Counting Period';
                    Ellipsis = true;
                    Image = CalculateCalendar;

                    trigger OnAction()
                    var
                        PhysInvtCountMgt: Codeunit "Phys. Invt. Count.-Management";
                    begin
                        PhysInvtCountMgt.InitFromItemJnl(Rec);
                        PhysInvtCountMgt.Run;
                        Clear(PhysInvtCountMgt);
                    end;
                }
            }
            action("&Print")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Print';
                Ellipsis = true;
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    ItemJournalBatch.SetRange("Journal Template Name", "Journal Template Name");
                    ItemJournalBatch.SetRange(Name, "Journal Batch Name");
                    PhysInventoryList.SetTableView(ItemJournalBatch);
                    PhysInventoryList.SetSortByBin(SortByBin); // P8001104
                    PhysInventoryList.RunModal;
                    Clear(PhysInventoryList);
                end;
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                action("Test Report")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Test Report';
                    Ellipsis = true;
                    Image = TestReport;

                    trigger OnAction()
                    begin
                        ReportPrint.PrintItemJnlLine(Rec);
                    end;
                }
                action("P&ost")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'P&ost';
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post", Rec);
                        CurrentJnlBatchName := GetRangeMax("Journal Batch Name");
                        SetSortByBin(SortByBin); // P8001104
                        CurrPage.Update(false);
                    end;
                }
                action("Post and &Print")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Post and &Print';
                    Image = PostPrint;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F9';

                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post+Print", Rec);
                        CurrentJnlBatchName := GetRangeMax("Journal Batch Name");
                        SetSortByBin(SortByBin); // P8001104
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ShowShortcutDimCode(ShortcutDimCode);
    end;

    trigger OnDeleteRecord(): Boolean
    var
        ReserveItemJnlLine: Codeunit "Item Jnl. Line-Reserve";
    begin
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        UpdateSortByBin(SortByBin); // P8001104
        exit(Find(Which));          // P8001104
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        "Line No." := AssignSortByBinLineNo(NewRecordLineNo); // P8001104
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        NewRecordLineNo := CalcSortByBinLineNo(BelowxRec, xRec."Line No."); // P8001104

        SetUpNewLine(xRec);
        Clear(ShortcutDimCode);
    end;

    trigger OnOpenPage()
    begin
        // P8000687
        if IsOpenedFromBatch then begin // P8004516
            CurrentJnlBatchName := "Journal Batch Name";
            ItemJnlMgt.OpenJnl(CurrentJnlBatchName, Rec);
            exit;
        end;
        // P8000687
        ItemJnlMgt.TemplateSelection(PAGE::"Phys. Inv. Jnl. w/ Tracking", 2, false, Rec, JnlSelected); // PR4.00
        if not JnlSelected then                                                                    // PR4.00
            Error('');                                                                               // PR4.00
        ItemJnlMgt.OpenJnl(CurrentJnlBatchName, Rec);

        SetSortByBin(SortByBin); // P8001104
        SetDimensionVisibility; // P80073095
    end;

    var
        ItemJournalBatch: Record "Item Journal Batch";
        CalcQtyOnHand: Report "Calculate Inventory";
        PhysInventoryList: Report "Phys. Inventory List";
        ItemJnlMgt: Codeunit ItemJnlManagement;
        ReportPrint: Codeunit "Test Report-Print";
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        CurrentJnlBatchName: Code[10];
        P800ItemTracking: Codeunit "Process 800 Item Tracking";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        JnlSelected: Boolean;
        SortByBin: Boolean;
        NewRecordLineNo: Integer;

    protected var
        ShortcutDimCode: array[8] of Code[20];
        DimVisible1: Boolean;
        DimVisible2: Boolean;
        DimVisible3: Boolean;
        DimVisible4: Boolean;
        DimVisible5: Boolean;
        DimVisible6: Boolean;
        DimVisible7: Boolean;
        DimVisible8: Boolean;

    local procedure SetDimensionVisibility()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        // P80073095
        DimMgt.UseShortcutDims(
          DimVisible1, DimVisible2, DimVisible3, DimVisible4, DimVisible5, DimVisible6, DimVisible7, DimVisible8);
    end;
}

