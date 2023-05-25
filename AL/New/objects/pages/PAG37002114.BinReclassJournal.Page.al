page 37002114 "Bin Reclass. Journal"
{
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add 1-Doc Whse Logic
    // 
    // PRW16.00.02
    // P8000777, VerticalSoft, Don Bresee, 24 FEB 10
    //   Changed EDITABLE so it could be handled by the form transformation tool
    // 
    // PRW16.00.03
    // P8000817, VerticalSoft, Jack Reynolds, 26 APR 10
    //   Change visible property of fields
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 19 FEB 13
    //   Restoring the SaveValues Property.
    // 
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds 17 NOV 13
    //   Lookup of Shortcut Dimensions, Standardize OpenedFromBatch
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds 10 JAN 17
    //   Update Images for actions
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 23 MAY 22
    //   Support for background validation of documents and journals

    ApplicationArea = FOODBasic;
    AutoSplitKey = true;
    Caption = 'Bin Reclassification Journals';
    DataCaptionFields = "Journal Batch Name";
    DelayedInsert = true;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Item Journal Line";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            field(CurrentJnlBatchName; CurrentJnlBatchName)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Batch Name';
                Lookup = true;

                trigger OnLookup(var Text: Text): Boolean
                begin
                    CurrPage.SaveRecord;
                    ItemJnlMgt.LookupName(CurrentJnlBatchName, Rec);
                    SetControlAppearanceFromBatch(); // P800144605                  
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
            repeater(Control37002001)
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
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupItemNo;
                        ItemJnlMgt.GetItem("Item No.", ItemDescription);
                        ShowShortcutDimCode(ShortcutDimCode);
                        ShowNewShortcutDimCode(NewShortcutDimCode);
                    end;

                    trigger OnValidate()
                    begin
                        ItemJnlMgt.GetItem("Item No.", ItemDescription);
                        ShowShortcutDimCode(ShortcutDimCode);
                        ShowNewShortcutDimCode(NewShortcutDimCode);
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
                field("New Shortcut Dimension 1 Code"; "New Shortcut Dimension 1 Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = DimVisible2;
                }
                field("New Shortcut Dimension 2 Code"; "New Shortcut Dimension 2 Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("ShortcutDimCode[3]"; ShortcutDimCode[3])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,3';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible3;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field("NewShortcutDimCode[3]"; NewShortcutDimCode[3])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = Text000;
                    ShowCaption = false;
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupNewShortcutDimCode(3, NewShortcutDimCode[3]);
                    end;

                    trigger OnValidate()
                    begin
                        TestField("Entry Type", "Entry Type"::Transfer);
                        ValidateNewShortcutDimCode(3, NewShortcutDimCode[3]);
                    end;
                }
                field("ShortcutDimCode[4]"; ShortcutDimCode[4])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,4';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(4),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible4;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field("NewShortcutDimCode[4]"; NewShortcutDimCode[4])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = Text001;
                    ShowCaption = false;
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupNewShortcutDimCode(4, NewShortcutDimCode[4]);
                    end;

                    trigger OnValidate()
                    begin
                        TestField("Entry Type", "Entry Type"::Transfer);
                        ValidateNewShortcutDimCode(4, NewShortcutDimCode[4]);
                    end;
                }
                field("ShortcutDimCode[5]"; ShortcutDimCode[5])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,5';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(5),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible5;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field("NewShortcutDimCode[5]"; NewShortcutDimCode[5])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = Text002;
                    ShowCaption = false;
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupNewShortcutDimCode(5, NewShortcutDimCode[5]);
                    end;

                    trigger OnValidate()
                    begin
                        TestField("Entry Type", "Entry Type"::Transfer);
                        ValidateNewShortcutDimCode(5, NewShortcutDimCode[5]);
                    end;
                }
                field("ShortcutDimCode[6]"; ShortcutDimCode[6])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,6';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(6),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible6;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field("NewShortcutDimCode[6]"; NewShortcutDimCode[6])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = Text003;
                    ShowCaption = false;
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupNewShortcutDimCode(6, NewShortcutDimCode[6]);
                    end;

                    trigger OnValidate()
                    begin
                        TestField("Entry Type", "Entry Type"::Transfer);
                        ValidateNewShortcutDimCode(6, NewShortcutDimCode[6]);
                    end;
                }
                field("ShortcutDimCode[7]"; ShortcutDimCode[7])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,7';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(7),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible7;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field("NewShortcutDimCode[7]"; NewShortcutDimCode[7])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = Text004;
                    ShowCaption = false;
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupNewShortcutDimCode(7, NewShortcutDimCode[7]);
                    end;

                    trigger OnValidate()
                    begin
                        TestField("Entry Type", "Entry Type"::Transfer);
                        ValidateNewShortcutDimCode(7, NewShortcutDimCode[7]);
                    end;
                }
                field("ShortcutDimCode[8]"; ShortcutDimCode[8])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,8';
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(8),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible8;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
                field("NewShortcutDimCode[8]"; NewShortcutDimCode[8])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = Text005;
                    ShowCaption = false;
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupNewShortcutDimCode(8, NewShortcutDimCode[8]);
                    end;

                    trigger OnValidate()
                    begin
                        TestField("Entry Type", "Entry Type"::Transfer);
                        ValidateNewShortcutDimCode(8, NewShortcutDimCode[8]);
                    end;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    var
                        WMSManagement: Codeunit "WMS Management";
                    begin
                        WMSManagement.CheckItemJnlLineLocation(Rec, xRec);
                    end;
                }
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(BinLookup(Text, true)); // P8000631A
                    end;
                }
                field("Old Container License Plate"; "Old Container License Plate")
                {
                    ApplicationArea = FOODBasic;
                    AccessByPermission = TableData "Container Header" = R;
                    Caption = 'Container License Plate';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ContainerFns: Codeunit "Container Functions";
                    begin
                        // P8001323
                        exit(ContainerFns.LookupContainerOnItemJnlLine(Rec, FieldNo("Old Container License Plate"), Text));
                    end;
                }
                field("New Bin Code"; "New Bin Code")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(BinLookup(Text, false)); // P8000631A
                    end;
                }
                field("New Container License Plate"; "New Container License Plate")
                {
                    ApplicationArea = FOODBasic;
                    AccessByPermission = TableData "Container Header" = R;
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ContainerFns: Codeunit "Container Functions";
                    begin
                        // P8001323
                        exit(ContainerFns.LookupContainerOnItemJnlLine(Rec, FieldNo("New Container License Plate"), Text));
                    end;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Lot No.Editable";

                    trigger OnAssistEdit()
                    begin
                        CurrPage.SaveRecord;
                        Commit;
                        EasyLotTracking.SetItemJnlLine(Rec, FieldNo("Lot No."));
                        if EasyLotTracking.AssistEdit("Lot No.") then begin
                            "New Lot No." := "Lot No.";
                            UpdateLotTracking(true);
                        end;
                        CurrPage.SaveRecord;
                    end;

                    trigger OnValidate()
                    begin
                        if "Line No." = 0 then begin
                            CurrPage.SaveRecord;
                            UpdateLotTracking(false);
                        end;
                    end;
                }
                field("Salespers./Purch. Code"; "Salespers./Purch. Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
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
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity (Alt.)"; "Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord;
                        AltQtyMgmt.ShowItemJnlAltQtyLines(Rec);
                        CurrPage.Update;
                    end;

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord;
                        AltQtyMgmt.ValidateItemJnlAltQtyLine(Rec);
                        CurrPage.Update;
                    end;
                }
                field("Pick Source Type"; "Pick Source Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Pick Source No."; "Pick Source No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Pick Source Line No."; "Pick Source Line No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit Amount"; "Unit Amount")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Indirect Cost %"; "Indirect Cost %")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
            }
            group(Control37002025)
            {
                ShowCaption = false;
                field(ItemDescription; ItemDescription)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Description';
                    Editable = false;
                }
            }
        }
        area(factboxes)
        {
            // P800144605
            part(JournalErrorsFactBox; "Item Journal Errors FactBox")
            {
                ApplicationArea = FOODBasic;
                ShowFilter = false;
                Visible = BackgroundErrorCheck;
                SubPageLink = "Journal Template Name" = FIELD("Journal Template Name"),
                              "Journal Batch Name" = FIELD("Journal Batch Name"),
                              "Line No." = FIELD("Line No.");
            }
            // P800144605
            systempart(Links; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            // P800144605
            systempart(Notes; Notes)
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
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(Dimensions)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Dimensions';
                    ShortCutKey = 'Alt+D';

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
                    ShortCutKey = 'Ctrl+Alt+I';

                    trigger OnAction()
                    begin
                        OpenItemTrackingLines(true);
                    end;
                }
                action("Move Container")
                {
                    ApplicationArea = FOODBasic;
                    AccessByPermission = TableData "Container Header" = R;
                    Caption = 'Move Container';
                    Image = ItemSubstitution;

                    trigger OnAction()
                    begin
                        // P8001323
                        MoveContainer;
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
                action("Bin Contents")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Bin Contents';
                    Image = BinContent;
                    RunObject = Page "Bin Contents List";
                    RunPageLink = "Location Code" = FIELD("Location Code"),
                                  "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code");
                    RunPageView = SORTING("Location Code", "Item No.", "Variant Code");
                }
            }
            group("&Item")
            {
                Caption = '&Item';
                Image = Item;
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = EditLines;
                    RunObject = Page "Item Card";
                    RunPageLink = "No." = FIELD("Item No.");
                    ShortCutKey = 'Shift+F7';
                }
                action("Ledger E&ntries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Ledger E&ntries';
                    Image = ItemLedger;
                    RunObject = Page "Item Ledger Entries";
                    RunPageLink = "Item No." = FIELD("Item No.");
                    RunPageView = SORTING("Item No.");
                    ShortCutKey = 'Ctrl+F7';
                }
                group("Item Availability by")
                {
                    Caption = 'Item Availability by';
                    Image = ItemAvailability;
                    action("Event")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Event';
                        Image = "Event";

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItemJnlLine(Rec, ItemAvailFormsMgt.ByEvent);
                        end;
                    }
                    action(Period)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Period';
                        Image = Period;

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItemJnlLine(Rec, ItemAvailFormsMgt.ByPeriod);
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
                        RunObject = Page "Item Availability by Lot No.";
                        RunPageLink = "No." = field("No."),
                            "Location Filter" = field("Location Code"),
                            "Variant Filter" = field("Variant Code");
                    }
                    action("BOM Level")
                    {
                        AccessByPermission = TableData "BOM Buffer" = R;
                        ApplicationArea = Assembly;
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
                Image = "Action";
                action("Put-Away &Receipts")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Put-Away &Receipts';
                    Image = Receipt;

                    trigger OnAction()
                    begin
                        Clear(PutAwayBinContent);
                        PutAwayBinContent.SetItemJnlLine(Rec, 1);
                        PutAwayBinContent.RunModal;
                        CurrPage.Update(false);
                    end;
                }
                action("Put-Away S&hipments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Put-Away S&hipments';
                    Image = Shipment;

                    trigger OnAction()
                    begin
                        Clear(PutAwayBinContent);
                        PutAwayBinContent.SetItemJnlLine(Rec, 2);
                        PutAwayBinContent.RunModal;
                        CurrPage.Update(false);
                    end;
                }
                action("Put-Away &Output")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Put-Away &Output';
                    Image = PutAway;

                    trigger OnAction()
                    var
                        PutAwayBinContent: Report "Put-Away Move List";
                    begin
                        Clear(PutAwayBinContent);
                        PutAwayBinContent.SetItemJnlLine(Rec, 3);
                        PutAwayBinContent.RunModal;
                        CurrPage.Update(false);
                    end;
                }
                action("Put-Away &Consumption")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Put-Away &Consumption';
                    Image = PutAway;

                    trigger OnAction()
                    begin
                        Clear(PutAwayBinContent);
                        PutAwayBinContent.SetItemJnlLine(Rec, 4);
                        PutAwayBinContent.RunModal;
                        CurrPage.Update(false);
                    end;
                }
                action("Put-Away O&ther")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Put-Away O&ther';
                    Image = PutAway;

                    trigger OnAction()
                    begin
                        Clear(PutAwayBinContent);
                        PutAwayBinContent.SetItemJnlLine(Rec, 5);
                        PutAwayBinContent.RunModal;
                        CurrPage.Update(false);
                    end;
                }
                action("Pick for &Shipment")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Pick for &Shipment';
                    Image = Shipment;

                    trigger OnAction()
                    var
                        ShptReplenishment: Report "Shpt. Replenishment/Move List";
                    begin
                        // P8000631A
                        ShptReplenishment.SetItemJnlLine(Rec);
                        ShptReplenishment.RunModal;
                        CurrPage.Update(false);
                    end;
                }
                action("Pick for &Production")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Pick for &Production';
                    Image = Production;

                    trigger OnAction()
                    var
                        ProdReplenishment: Report "Prod. Replenishment/Move List";
                    begin
                        // P8000631A
                        ProdReplenishment.SetItemJnlLine(Rec);
                        ProdReplenishment.RunModal;
                        CurrPage.Update(false);
                    end;
                }
                action("E&xplode BOM")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'E&xplode BOM';
                    Image = ExplodeBOM;
                    RunObject = Codeunit "Item Jnl.-Explode BOM";
                }
                action("Get Bin Content")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Get Bin Content';
                    Ellipsis = true;
                    Image = GetBinContent;
                    Visible = false;

                    trigger OnAction()
                    var
                        BinContent: Record "Bin Content";
                        GetBinContent: Report "Whse. Get Bin Content";
                    begin
                        BinContent.SetRange("Location Code", "Location Code");
                        GetBinContent.SetTableView(BinContent);
                        GetBinContent.InitializeItemJournalLine(Rec);
                        GetBinContent.RunModal;
                        CurrPage.Update(false);
                    end;
                }
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
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
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post", Rec);
                        CurrentJnlBatchName := GetRangeMax("Journal Batch Name");
                        CurrPage.Update(false);
                    end;
                }
                action("Post and &Print")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Post and &Print';
                    Image = PostPrint;
                    ShortCutKey = 'Shift+F9';

                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post+Print", Rec);
                        CurrentJnlBatchName := GetRangeMax("Journal Batch Name");
                        CurrPage.Update(false);
                    end;
                }
            }
            action("&Print")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Print';
                Ellipsis = true;
                Image = Print;

                trigger OnAction()
                var
                    ItemJnlLine: Record "Item Journal Line";
                begin
                    ItemJnlLine.Copy(Rec);
                    ItemJnlLine.SetRange("Journal Template Name", "Journal Template Name");
                    ItemJnlLine.SetRange("Journal Batch Name", "Journal Batch Name");
                    REPORT.RunModal(REPORT::"Inventory Movement", true, true, ItemJnlLine);
                end;
            }
            // P800144605
            group(Errors)
            {
                Caption = 'Issues';
                Image = ErrorLog;
                Visible = BackgroundErrorCheck;
                action(ShowLinesWithErrors)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Show Lines with Issues';
                    Image = Error;
                    Visible = BackgroundErrorCheck;
                    Enabled = not ShowAllLinesEnabled;
                    ToolTip = 'View a list of journal lines that have issues before you post the journal.';

                    trigger OnAction()
                    begin
                        SwitchLinesWithErrorsFilter(ShowAllLinesEnabled);
                    end;
                }
                action(ShowAllLines)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Show All Lines';
                    Image = ExpandAll;
                    Visible = BackgroundErrorCheck;
                    Enabled = ShowAllLinesEnabled;
                    ToolTip = 'View all journal lines, including lines with and without issues.';

                    trigger OnAction()
                    begin
                        SwitchLinesWithErrorsFilter(ShowAllLinesEnabled);
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(PutAwayReceipts_Promoted; "Put-Away &Receipts")
                {
                }
                actionref(PutAwayShipments_Promoted; "Put-Away S&hipments")
                {
                }
                actionref(PutAwayOutput_Promoted; "Put-Away &Output")
                {
                }
                actionref(PutAwayConsumption_Promoted; "Put-Away &Consumption")
                {
                }
                actionref(PutAwayOther_Promoted; "Put-Away O&ther")
                {
                }
                actionref(PickForShipment_Promoted; "Pick for &Shipment")
                {
                }
                actionref(PickForProduction_Promoted; "Pick for &Production")
                {
                }
            }
            group(Category_PostPrint)
            {
                Caption = 'Post/Print';
                ShowAs = SplitButton;

                actionref(Post_Promoted; "P&ost")
                {
                }
                actionref(PostAndPrint_Promoted; "Post and &Print")
                {
                }
                actionref(Print_Promoted; "&Print")
                {
                }
            }
            group(Category_Line)
            {
                Caption = 'Line';

                actionref(Dimensions_Promoted; Dimensions)
                {
                }
                actionref(ItemTrackingLines_Promoted; "Item &Tracking Lines")
                {
                }
                actionref(MoveContainer_Promoted; "Move Container")
                {
                }
                actionref(NewContainer_Promoted; "New Container")
                {
                }
                actionref(BinContents_Promoted; "Bin Contents")
                {
                }
            }
            group(Category_Item)
            {
                Caption = 'Item';

                actionref(Card_Promoted; Card)
                {
                }
                actionref(LedgerEntries_Promoted; "Ledger E&ntries")
                {
                }
            }
            group(Category_Page)
            {
                Caption = 'Page';

                actionref(ShowLinesWithErrors_Promoted; ShowLinesWithErrors)
                {
                }
                actionref(ShowAllLines_Promoted; ShowAllLines)
                {
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        ItemJnlMgt.GetItem("Item No.", ItemDescription);
        SetLotFields('EDITABLE');
    end;

    trigger OnAfterGetRecord()
    begin
        ShowShortcutDimCode(ShortcutDimCode);
        ShowNewShortcutDimCode(NewShortcutDimCode);
    end;

    trigger OnDeleteRecord(): Boolean
    var
        ReserveItemJnlLine: Codeunit "Item Jnl. Line-Reserve";
    begin
        Commit;
        if not ReserveItemJnlLine.DeleteLineConfirm(Rec) then
            exit(false);
        ReserveItemJnlLine.DeleteLine(Rec);
    end;

    trigger OnInit()
    begin
        "Lot No.Editable" := true;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetUpNewLine(xRec);
        Clear(ShortcutDimCode);
        Clear(NewShortcutDimCode);
        "Entry Type" := "Entry Type"::Transfer;
    end;

    trigger OnOpenPage()
    var
        JnlSelected: Boolean;
    begin
        // P8004516
        if IsOpenedFromBatch then begin
            CurrentJnlBatchName := "Journal Batch Name";
            ItemJnlMgt.OpenJnl(CurrentJnlBatchName, Rec);
            SetControlAppearanceFromBatch(); // P800144605
            exit;
        end;
        // P8004516
        ItemJnlMgt.TemplateSelection(PAGE::"Item Reclass. Journal", 1, false, Rec, JnlSelected);
        if not JnlSelected then
            Error('');
        ItemJnlMgt.OpenJnl(CurrentJnlBatchName, Rec);
        SetDimensionVisibility; // P80073095
        SetControlAppearanceFromBatch(); // P800144605
    end;

    var
        Text000: Label '1,2,3,New ';
        Text001: Label '1,2,4,New ';
        Text002: Label '1,2,5,New ';
        Text003: Label '1,2,6,New ';
        Text004: Label '1,2,7,New ';
        Text005: Label '1,2,8,New ';
        ItemJnlMgt: Codeunit ItemJnlManagement;
        ReportPrint: Codeunit "Test Report-Print";
        ItemJournalErrorsMgt: Codeunit "Item Journal Errors Mgt.";
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        CurrentJnlBatchName: Code[10];
        ItemDescription: Text[100];
        BackgroundErrorCheck: Boolean;
        ShowAllLinesEnabled: Boolean;
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        EasyLotTracking: Codeunit "Easy Lot Tracking";
        PutAwayBinContent: Report "Put-Away Move List";
        P800Globals: Codeunit "Process 800 System Globals";
        WMSMgmt: Codeunit "WMS Management";
        [InDataSet]
        "Lot No.Editable": Boolean;

    protected var
        ShortcutDimCode: array[8] of Code[20];
        NewShortcutDimCode: array[8] of Code[20];
        DimVisible1: Boolean;
        DimVisible2: Boolean;
        DimVisible3: Boolean;
        DimVisible4: Boolean;
        DimVisible5: Boolean;
        DimVisible6: Boolean;
        DimVisible7: Boolean;
        DimVisible8: Boolean;

    procedure SetLotFields(Property: Code[10])
    var
        ProcessFns: Codeunit "Process 800 Functions";
        P800Globals: Codeunit "Process 800 System Globals";
    begin
        case Property of
            'EDITABLE':
                // P8000777
                // CurrForm."Lot No.".EDITABLE(ProcessFns.TrackingInstalled AND ("Lot No." <> P800Globals.MultipleLotCode));
                "Lot No.Editable" := ProcessFns.TrackingInstalled and ("Lot No." <> P800Globals.MultipleLotCode);
        // P8000777
        end;
    end;

    procedure BinLookup(var Text: Text[1024]; IsFromBin: Boolean): Boolean
    var
        BinCode: Code[20];
    begin
        // P8000631A
        if ("Item No." <> '') and
           ((IsFromBin and (Signed(1) < 0) and (Quantity >= 0)) or
            ((not IsFromBin) and (Signed(1) > 0) and (Quantity >= 0)))
        then
            BinCode := WMSMgmt.BinContentLookUp("Location Code", "Item No.", "Variant Code", '', "Bin Code")
        else
            BinCode := WMSMgmt.BinLookUp("Location Code", "Item No.", "Variant Code", '');
        if (BinCode = '') then
            exit(false);
        Text := BinCode;
        exit(true);
    end;

    // P800144605
    local procedure SetControlAppearanceFromBatch()
    var
        ItemJournalBatch: Record "Item Journal Batch";
        BackgroundErrorHandlingMgt: Codeunit "Background Error Handling Mgt.";
    begin
        if not ItemJournalBatch.Get(GetRangeMax("Journal Template Name"), CurrentJnlBatchName) then
            exit;

        BackgroundErrorCheck := BackgroundErrorHandlingMgt.BackgroundValidationFeatureEnabled();
        ShowAllLinesEnabled := true;
        SwitchLinesWithErrorsFilter(ShowAllLinesEnabled);
        ItemJournalErrorsMgt.SetFullBatchCheck(true);
    end;

    local procedure SetDimensionVisibility()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        // P80073095
        DimMgt.UseShortcutDims(
          DimVisible1, DimVisible2, DimVisible3, DimVisible4, DimVisible5, DimVisible6, DimVisible7, DimVisible8);
    end;
}

