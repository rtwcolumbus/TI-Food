page 99000823 "Output Journal"
{
    // PR3.60
    //   Add fields/logic for alternate quantities
    // 
    // PR3.61
    //   Add field for output container
    // 
    // PR3.70.04
    // P8000043A, Myers Nissi, Jack Reynolds, 30 MAY 04
    //   Support for easy lot tracking
    // 
    // PR3.70.07
    // P8000138A, Myers Nissi, Jack Reynolds, 28 OCT 04
    //   Integrate 3.70 Service Pack 2
    // 
    // P8000140A, Myers Nissi, Jack Reynolds, 19 NOV 04
    //   Add controls for Output Container Serial No.
    // 
    // PR3.70.09
    // P8000194A, Myers Nissi, Jack Reynolds, 24 FEB 05
    //   Fix easy lot tracking problem to save record before creating tracking lines
    // 
    // PR3.70.10
    // P8000227A, Myers Nissi, Jack Reynolds, 07 JUL 05
    //   Fix problem specifying lot before line has been inserted
    // 
    // PR4.00.03
    // P8000343A, VerticalSoft, Jack Reynolds, 05 JUN 06
    //   Modify to support easy lot with reclass journal
    // 
    // PRW16.00
    // P8000643, VerticalSoft, Jack Reynolds, 21 NOV 08
    //   Modifications when opened from batch
    // 
    // PRW16.00.02
    // P8000785, VerticalSoft, Rick Tweedle, 05 MAR 10
    //   Amendments to code to allow page transformation
    // 
    // PRW16.00.03
    // P8000817, VerticalSoft, Jack Reynolds, 26 APR 10
    //   Change visible property of fields
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    //
    // PRW111.00.03
    //   P80090919, To-Increase, Gangabhushan, 24 DEC 19
    //     CS00088423 - Duplicate Lines creating in Output and Consumption Journals.
    //
    // P80091260, To-Increase, Gangabhushan, 08 JAN 20
    //     CS00088423 - Duplicate Lines creating in Output and Consumption Journals.-2

    ApplicationArea = Manufacturing;
    AutoSplitKey = true;
    Caption = 'Output Journals';
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
                ApplicationArea = Manufacturing;
                Caption = 'Batch Name';
                Lookup = true;
                ToolTip = 'Specifies the name of the journal batch, a personalized journal layout, that the journal is based on.';

                trigger OnLookup(var Text: Text): Boolean
                begin
                    CurrPage.SaveRecord();
                    ItemJnlMgt.LookupName(CurrentJnlBatchName, Rec);
                    SetControlAppearanceFromBatch();
                    CurrPage.Update(false);
                    ItemJnlMgt.CheckName(CurrentJnlBatchName, Rec);
                end;

                trigger OnValidate()
                begin
                    ItemJnlMgt.CheckName(CurrentJnlBatchName, Rec);
                    CurrentJnlBatchNameOnAfterValidate();
                end;
            }
            repeater(Control1)
            {
                ShowCaption = false;
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the posting date for the entry.';
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number of the order that created the entry.';

                    trigger OnValidate()
                    begin
                        ItemJnlMgt.GetOutput(Rec, ProdOrderDescription, OperationName);
                    end;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies a document number for the journal line.';
                    ShowMandatory = true;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number of the item on the journal line.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupItemNo();
                        Rec.ShowShortcutDimCode(ShortcutDimCode);
                    end;

                    trigger OnValidate()
                    begin
                        ItemNoOnAfterValidate();
                    end;
                }
                field(Allergens; AllergenManagement.AllergenCodeForRecord(0, 0, "Item No."))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Allergens';
                    Style = StrongAccent;
                    StyleExpr = TRUE;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        // P8006959
                        AllergenManagement.AllergenDrilldownForRecord(0, 0, "Item No.");
                    end;
                }
                field("Operation No."; Rec."Operation No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number of the production operation on the item journal line when the journal functions as an output journal.';

                    trigger OnValidate()
                    begin
                        ItemJnlMgt.GetOutput(Rec, ProdOrderDescription, OperationName);
                    end;
                }
                field("Order Line No."; Rec."Order Line No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the line number of the order that created the entry.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the journal type, which is either Work Center or Machine Center.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies a description of the item on the journal line.';
                }
                field("Work Shift Code"; Rec."Work Shift Code")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the work shift code for this Journal line.';
                    Visible = false;
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the vendor''s or customer''s trade type to link transactions made for this business partner with the appropriate general ledger account according to the general posting setup.';
                    Visible = false;
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the item''s product type to link transactions made for this item with the appropriate general ledger account according to the general posting setup.';
                    Visible = false;
                }
                field("Starting Time"; Rec."Starting Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the starting time of the operation on the item journal line.';
                    Visible = false;
                }
                field("Ending Time"; Rec."Ending Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the ending time of the operation on the item journal line.';
                    Visible = false;
                }
                field("Concurrent Capacity"; Rec."Concurrent Capacity")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the concurrent capacity.';
                    Visible = false;
                }
                field("Setup Time"; Rec."Setup Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the time required to set up the machines for this journal line.';
                    Visible = false;
                }
                field("Run Time"; Rec."Run Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the run time of the operations represented by this journal line.';
                }
                field("Cap. Unit of Measure Code"; Rec."Cap. Unit of Measure Code")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the unit of measure code for the capacity usage.';
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the cost of one unit of the item or resource on the line.';
                    Visible = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the code for the inventory location where the item on the journal line will be registered.';
                    Visible = false;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies a bin code for the item.';
                    Visible = false;
                }
                field("Container License Plate"; Rec."Container License Plate")
                {
                    AccessByPermission = TableData "Container Header" = R;
                    ApplicationArea = FOODBasic;
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ContainerFns: Codeunit "Container Functions";
                    begin
                        // P8001323
                        exit(ContainerFns.LookupContainerOnItemJnlLine(Rec, FieldNo("Container License Plate"), Text));
                    end;
                }
                field("Scrap Code"; Rec."Scrap Code")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the scrap code.';
                    Visible = false;
                }
                field("Output Quantity"; Rec."Output Quantity")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the quantity of the produced item that can be posted as output on the journal line.';
                }
                field("Quantity (Alt.)"; Rec."Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        TestCatchAlternateUnits; // P80091260
                        // PR3.60
                        CurrPage.SaveRecord;
                        AltQtyMgmt.ShowItemJnlAltQtyLines(Rec);
                        CurrPage.Update;
                        // PR3.60
                    end;

                    trigger OnValidate()
                    begin
                        QuantityAltOnAfterValidate;
                    end;
                }
                field("Scrap Quantity"; Rec."Scrap Quantity")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number of units produced incorrectly, and therefore cannot be used.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Lot No.Editable";

                    trigger OnAssistEdit()
                    begin
                        EasyLotTracking.TestItemJnlLine(Rec); // P80090919
                        // P8000043A
                        CurrPage.SaveRecord; // P8000194A
                        Commit;              // P8000194A
                        EasyLotTracking.SetItemJnlLine(Rec, FieldNo("Lot No.")); // P8000343A
                        if EasyLotTracking.AssistEdit("Lot No.") then
                            UpdateLotTracking(true);
                        CurrPage.SaveRecord;
                    end;

                    trigger OnValidate()
                    begin
                        LotNoOnAfterValidate;
                    end;
                }
                field(Finished; Rec.Finished)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies that the operation represented by the output journal line is finished.';
                }
                field("Applies-to Entry"; Rec."Applies-to Entry")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies if the quantity on the journal line must be applied to an already-posted entry. In that case, enter the entry number that the quantity will be applied to.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the date when the related document was created.';
                    Visible = false;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies a document number that refers to the customer''s or vendor''s numbering system.';
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = DimVisible1;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = DimVisible2;
                }
                field(ShortcutDimCode3; ShortcutDimCode[3])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,3';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible3;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field(ShortcutDimCode4; ShortcutDimCode[4])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,4';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(4),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible4;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field(ShortcutDimCode5; ShortcutDimCode[5])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,5';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(5),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible5;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field(ShortcutDimCode6; ShortcutDimCode[6])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,6';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(6),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible6;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field(ShortcutDimCode7; ShortcutDimCode[7])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,7';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(7),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible7;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field(ShortcutDimCode8; ShortcutDimCode[8])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,8';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(8),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible8;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
            }
            group(Control73)
            {
                ShowCaption = false;
                fixed(Control1902114901)
                {
                    ShowCaption = false;
                    group("Prod. Order Name")
                    {
                        Caption = 'Prod. Order Name';
                        field(ProdOrderDescription; ProdOrderDescription)
                        {
                            ApplicationArea = Manufacturing;
                            Editable = false;
                            ShowCaption = false;
                        }
                    }
                    group(Operation)
                    {
                        Caption = 'Operation';
                        field(OperationName; OperationName)
                        {
                            ApplicationArea = Manufacturing;
                            Caption = 'Operation';
                            Editable = false;
                            ToolTip = 'Specifies the abbreviated task description.';
                        }
                    }
                }
            }
        }
        area(factboxes)
        {
            part(JournalErrorsFactBox; "Item Journal Errors FactBox")
            {
                ApplicationArea = Basic, Suite;
                ShowFilter = false;
                Visible = BackgroundErrorCheck;
                SubPageLink = "Journal Template Name" = FIELD("Journal Template Name"),
                              "Journal Batch Name" = FIELD("Journal Batch Name"),
                              "Line No." = FIELD("Line No.");
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
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
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                        CurrPage.SaveRecord();
                    end;
                }
                action("Item Tracking Lines")
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Item &Tracking Lines';
                    Image = ItemTrackingLines;
                    ShortCutKey = 'Ctrl+Alt+I';
                    ToolTip = 'View or edit serial numbers and lot numbers that are assigned to the item on the document or journal line.';

                    trigger OnAction()
                    begin
                        Rec.OpenItemTrackingLines(false);
                    end;
                }
                action("New Container")
                {
                    AccessByPermission = TableData "Container Header" = R;
                    ApplicationArea = FOODBasic;
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
                    ApplicationArea = Warehouse;
                    Caption = 'Bin Contents';
                    Image = BinContent;
                    RunObject = Page "Bin Contents List";
                    RunPageLink = "Location Code" = FIELD("Location Code"),
                                  "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code");
                    RunPageView = SORTING("Location Code", "Bin Code", "Item No.", "Variant Code");
                    ToolTip = 'View items in the bin if the selected line contains a bin code.';
                }
            }
            group("Pro&d. Order")
            {
                Caption = 'Pro&d. Order';
                Image = "Order";
                action(Card)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Card';
                    Image = EditLines;
                    RunObject = Page "Released Production Order";
                    RunPageLink = "No." = FIELD("Order No.");
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'View or change detailed information about the record on the document or journal line.';
                }
                group("Ledger E&ntries")
                {
                    Caption = 'Ledger E&ntries';
                    Image = Entries;
                    action("Item Ledger E&ntries")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Item Ledger E&ntries';
                        Image = ItemLedger;
                        RunObject = Page "Item Ledger Entries";
                        RunPageLink = "Order Type" = CONST(Production),
                                      "Order No." = FIELD("Order No.");
                        RunPageView = SORTING("Order Type", "Order No.");
                        ShortCutKey = 'Ctrl+F7';
                        ToolTip = 'View the item ledger entries of the item on the document or journal line.';
                    }
                    action("Capacity Ledger Entries")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Capacity Ledger Entries';
                        Image = CapacityLedger;
                        RunObject = Page "Capacity Ledger Entries";
                        RunPageLink = "Order Type" = CONST(Production),
                                      "Order No." = FIELD("Order No.");
                        RunPageView = SORTING("Order Type", "Order No.");
                        ToolTip = 'View the capacity ledger entries of the involved production order. Capacity is recorded either as time (run time, stop time, or setup time) or as quantity (scrap quantity or output quantity).';
                    }
                    action("Value Entries")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Value Entries';
                        Image = ValueLedger;
                        RunObject = Page "Value Entries";
                        RunPageLink = "Order Type" = CONST(Production),
                                      "Order No." = FIELD("Order No.");
                        RunPageView = SORTING("Order Type", "Order No.");
                        ToolTip = 'View the value entries of the item on the document or journal line.';
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
                action("Explode &Routing")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Explode &Routing';
                    Image = ExplodeRouting;
                    RunObject = Codeunit "Output Jnl.-Expl. Route";
                    ToolTip = 'Insert prefilled journal lines according to the production order routing.';
                }
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action("Test Report")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Test Report';
                    Ellipsis = true;
                    Image = TestReport;
                    ToolTip = 'View a test report so that you can find and correct any errors before you perform the actual posting of the journal or document.';

                    trigger OnAction()
                    begin
                        ReportPrint.PrintItemJnlLine(Rec);
                    end;
                }
                action(Post)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'P&ost';
                    Image = PostOrder;
                    ShortCutKey = 'F9';
                    ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.';

                    trigger OnAction()
                    begin
                        PostingItemJnlFromProduction(false);
                        CurrentJnlBatchName := Rec.GetRangeMax("Journal Batch Name");
                        CurrPage.Update(false);
                    end;
                }
                action("Post and &Print")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Post and &Print';
                    Image = PostPrint;
                    ShortCutKey = 'Shift+F9';
                    ToolTip = 'Finalize and prepare to print the document or journal. The values and quantities are posted to the related accounts. A report request window where you can specify what to include on the print-out.';

                    trigger OnAction()
                    begin
                        Rec.PostingItemJnlFromProduction(true);
                        CurrentJnlBatchName := Rec.GetRangeMax("Journal Batch Name");
                        CurrPage.Update(false);
                    end;
                }
            }
            action("&Print")
            {
                ApplicationArea = Manufacturing;
                Caption = '&Print';
                Ellipsis = true;
                Image = Print;
                ToolTip = 'Prepare to print the document. A report request window for the document opens where you can specify what to include on the print-out.';

                trigger OnAction()
                var
                    ItemJnlLine: Record "Item Journal Line";
                begin
                    ItemJnlLine.Copy(Rec);
                    ItemJnlLine.SetRange("Journal Template Name", Rec."Journal Template Name");
                    ItemJnlLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
                    REPORT.RunModal(REPORT::"Inventory Movement", true, true, ItemJnlLine);
                end;
            }
            group(Errors)
            {
                Caption = 'Issues';
                Image = ErrorLog;
                Visible = BackgroundErrorCheck;
                action(ShowLinesWithErrors)
                {
                    ApplicationArea = Basic, Suite;
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
                    ApplicationArea = Basic, Suite;
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
                Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 1.';

                group(Category_Category4)
                {
                    Caption = 'Posting';
                    ShowAs = SplitButton;

                    actionref(Post_Promoted; Post)
                    {
                    }
                    actionref("Post and &Print_Promoted"; "Post and &Print")
                    {
                    }
                }
                actionref("&Print_Promoted"; "&Print")
                {
                }
                actionref("Explode &Routing_Promoted"; "Explode &Routing")
                {
                }
            }
            group(Category_Category5)
            {
                Caption = 'Line', Comment = 'Generated from the PromotedActionCategories property index 4.';

                actionref("Item Tracking Lines_Promoted"; "Item Tracking Lines")
                {
                }
                actionref(Dimensions_Promoted; Dimensions)
                {
                }
#if not CLEAN21
                actionref("Bin Contents_Promoted"; "Bin Contents")
                {
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Action is being demoted based on overall low usage.';
                    ObsoleteTag = '21.0';
                }
#endif
            }
            group(Category_Category6)
            {
                Caption = 'Prod. Order', Comment = 'Generated from the PromotedActionCategories property index 5.';

#if not CLEAN21
                actionref(Card_Promoted; Card)
                {
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Action is being demoted based on overall low usage.';
                    ObsoleteTag = '21.0';
                }
#endif
                actionref("Item Ledger E&ntries_Promoted"; "Item Ledger E&ntries")
                {
                }
                actionref("Capacity Ledger Entries_Promoted"; "Capacity Ledger Entries")
                {
                }
                actionref("Value Entries_Promoted"; "Value Entries")
                {
                }
            }
            group(Category_Category7)
            {
                Caption = 'Page', Comment = 'Generated from the PromotedActionCategories property index 6.';

                actionref(ShowLinesWithErrors_Promoted; ShowLinesWithErrors)
                {
                }
                actionref(ShowAllLines_Promoted; ShowAllLines)
                {
                }
            }
            group(Category_Report)
            {
                Caption = 'Report', Comment = 'Generated from the PromotedActionCategories property index 2.';
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        ItemJnlMgt.GetOutput(Rec, ProdOrderDescription, OperationName);
        SetLotFields('EDITABLE'); // PR3.60
    end;

    trigger OnAfterGetRecord()
    begin
        Rec.ShowShortcutDimCode(ShortcutDimCode);
    end;

    trigger OnDeleteRecord(): Boolean
    var
        ItemJnlLineReserve: Codeunit "Item Jnl. Line-Reserve";
    begin
        Commit();
        if not ItemJnlLineReserve.DeleteLineConfirm(Rec) then
            exit(false);
        ItemJnlLineReserve.DeleteLine(Rec);
    end;

    trigger OnInit()
    begin
        "Lot No.Editable" := true;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.SetUpNewLine(xRec);
        Rec.Validate("Entry Type", Rec."Entry Type"::Output);
        Clear(ShortcutDimCode);
    end;

    trigger OnOpenPage()
    var
        JnlSelected: Boolean;
    begin
        SetDimensionsVisibility();

        if Rec.IsOpenedFromBatch() then begin
            CurrentJnlBatchName := Rec."Journal Batch Name";
            ItemJnlMgt.OpenJnl(CurrentJnlBatchName, Rec);
            SetControlAppearanceFromBatch();
            exit;
        end;
        ItemJnlMgt.TemplateSelection(PAGE::"Output Journal", 5, false, Rec, JnlSelected);
        if not JnlSelected then
            Error('');
        ItemJnlMgt.OpenJnl(CurrentJnlBatchName, Rec);
        SetControlAppearanceFromBatch();
    end;

    var
        ItemJnlMgt: Codeunit ItemJnlManagement;
        ReportPrint: Codeunit "Test Report-Print";
        ItemJournalErrorsMgt: Codeunit "Item Journal Errors Mgt.";
        ProdOrderDescription: Text[100];
        OperationName: Text[100];
        BackgroundErrorCheck: Boolean;
        ShowAllLinesEnabled: Boolean;
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        EasyLotTracking: Codeunit "Easy Lot Tracking";
        AllergenManagement: Codeunit "Allergen Management";
        [InDataSet]
        "Lot No.Editable": Boolean;

    protected var
        CurrentJnlBatchName: Code[10];
        ShortcutDimCode: array[8] of Code[20];
        DimVisible1: Boolean;
        DimVisible2: Boolean;
        DimVisible3: Boolean;
        DimVisible4: Boolean;
        DimVisible5: Boolean;
        DimVisible6: Boolean;
        DimVisible7: Boolean;
        DimVisible8: Boolean;

    local procedure CurrentJnlBatchNameOnAfterValidate()
    begin
        CurrPage.SaveRecord();
        ItemJnlMgt.SetName(CurrentJnlBatchName, Rec);
        SetControlAppearanceFromBatch();
        CurrPage.Update(false);
    end;

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

    procedure ItemNoOnAfterValidate()
    begin
        Rec.ShowShortcutDimCode(ShortcutDimCode);
    end;

    procedure SetLotFields(Property: Code[10])
    var
        ProcessFns: Codeunit "Process 800 Functions";
        P800Globals: Codeunit "Process 800 System Globals";
    begin
        // P8000043A
        case Property of
            'EDITABLE':
                //CurrForm."Lot No.".EDITABLE(ProcessFns.TrackingInstalled AND ("Lot No." <> P800Globals.MultipleLotCode));  // P8000785
                "Lot No.Editable" := ProcessFns.TrackingInstalled and ("Lot No." <> P800Globals.MultipleLotCode);  // P8000785
        end;
    end;

    local procedure QuantityAltOnAfterValidate()
    begin
        // PR3.60
        CurrPage.SaveRecord;
        AltQtyMgmt.ValidateItemJnlAltQtyLine(Rec);
        CurrPage.Update;
        // PR3.60
    end;

    local procedure LotNoOnAfterValidate()
    begin
        // P8000227A Begin
        if "Line No." = 0 then begin
            CurrPage.SaveRecord;
            UpdateLotTracking(false);
        end;
        // P8000227A End
    end;

    local procedure SetDimensionsVisibility()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimVisible1 := false;
        DimVisible2 := false;
        DimVisible3 := false;
        DimVisible4 := false;
        DimVisible5 := false;
        DimVisible6 := false;
        DimVisible7 := false;
        DimVisible8 := false;

        DimMgt.UseShortcutDims(
          DimVisible1, DimVisible2, DimVisible3, DimVisible4, DimVisible5, DimVisible6, DimVisible7, DimVisible8);

        Clear(DimMgt);
    end;
}

