page 99000846 "Consumption Journal"
{
    // PR3.60
    //   Add fields/logic for alternate quantities
    // 
    // PR3.61
    //   Add fields/logic for container tracking
    // 
    // PR3.70.04
    // P8000043A, Myers Nissi, Jack Reynolds, 30 MAY 04
    //   Support for easy lot tracking
    // 
    // PR3.70.07
    // P8000138A, Myers Nissi, Jack Reynolds, 28 OCT 04
    //   Integrate 3.70 Service Pack 2
    // 
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Support for checking lot preferences
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
    // P8001101, Columbus IT, Jack Reynolds, 27 SEP 12
    //   Change keyboard shortcut for containers
    // 
    // PRW17.10
    // P8001231, Columbus IT, Jack Reynolds, 22 OCT 13
    //   Add support for Shift Code
    // 
    // PRW17.10.03
    // P8001343, Columbus IT, Dayakar Battini, 25 Aug 14
    //    Containers -Consumption posting reduces container contents.
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
    Caption = 'Consumption Journals';
    DataCaptionFields = "Journal Batch Name";
    DelayedInsert = true;
    PageType = Worksheet;
    PromotedActionCategories = 'New,Process,Report,Post/Print,Prepare,Line,Prod. Order';
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
                        ItemJnlMgt.GetConsump(Rec, ProdOrderDescription);
                    end;
                }
                field("Order Line No."; Rec."Order Line No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the line number of the order that created the entry.';
                }
                field("Prod. Order Comp. Line No."; Rec."Prod. Order Comp. Line No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the production order component line number.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupItemNo();
                    end;
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
                    ApplicationArea = FOODBasic;
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
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number of units of the item to be included on the journal line.';
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
                        CurrPage.SaveRecord; // P8000153A
                        Commit;              // P8000153A
                        EasyLotTracking.SetItemJnlLine(Rec, FieldNo("Lot No.")); // P8000343A
                        if EasyLotTracking.AssistEdit("Lot No.") then
                            UpdateLotTracking(true);
                        CurrPage.SaveRecord;
                    end;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the cost of one unit of the item or resource on the line.';
                    Visible = false;
                }
                field("Unit Amount"; Rec."Unit Amount")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the price of one unit of the item on the journal line.';
                }
                field("Applies-to Entry"; Rec."Applies-to Entry")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies if the quantity on the journal line must be applied to an already-posted entry. In that case, enter the entry number that the quantity will be applied to.';
                }
                field("Applies-from Entry"; Rec."Applies-from Entry")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number of the outbound item ledger entry, whose cost is forwarded to the inbound item ledger entry.';
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
                }
            }
        }
        area(factboxes)
        {
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
                    Promoted = true;
                    PromotedCategory = Category6;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                        CurrPage.SaveRecord();
                    end;
                }
                action("Item &Tracking Lines")
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Item &Tracking Lines';
                    Image = ItemTrackingLines;
                    Promoted = true;
                    PromotedCategory = Category6;
                    ShortCutKey = 'Shift+Ctrl+I';
                    ToolTip = 'View or edit serial numbers and lot numbers that are assigned to the item on the document or journal line.';

                    trigger OnAction()
                    begin
                        CurrPage.SaveRecord; // PR3.60
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
                    Promoted = true;
                    PromotedCategory = Category6;
                    RunObject = Page "Bin Contents List";
                    RunPageLink = "Location Code" = FIELD("Location Code"),
                                  "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code");
                    RunPageView = SORTING("Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code");
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
                    Promoted = true;
                    PromotedCategory = Category7;
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
                        Promoted = true;
                        PromotedCategory = Category7;
                        RunObject = Page "Item Ledger Entries";
                        RunPageLink = "Order Type" = CONST(Production),
                                      "Order No." = FIELD("Order No.");
                        ShortCutKey = 'Ctrl+F7';
                        ToolTip = 'View the item ledger entries of the item on the document or journal line.';
                    }
                    action("Capacity Ledger Entries")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Capacity Ledger Entries';
                        Image = CapacityLedger;
                        Promoted = true;
                        PromotedCategory = Category7;
                        RunObject = Page "Capacity Ledger Entries";
                        RunPageLink = "Order Type" = CONST(Production),
                                      "Order No." = FIELD("Order No.");
                        RunPageView = SORTING("Order Type", "Order No.");
                        ToolTip = 'View the capacity ledger entries of the involved production order. Capacity is recorded either as time (run time, stop time, or setup time) or as quantity (scrap quantity or output quantity).';
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
                action("Calc. Co&nsumption")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Calc. Co&nsumption';
                    Ellipsis = true;
                    Image = CalculateConsumption;
                    Promoted = true;
                    PromotedCategory = Category5;
                    ToolTip = 'Use a batch job to help you fill the consumption journal with actual or expected consumption figures.';

                    trigger OnAction()
                    var
                        CalcConsumption: Report "Calc. Consumption";
                    begin
                        CalcConsumption.SetTemplateAndBatchName("Journal Template Name", "Journal Batch Name");

                        CalcConsumption.RunModal();
                    end;
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
                action("P&ost")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'P&ost';
                    Image = PostOrder;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';
                    ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.';

                    trigger OnAction()
                    begin
                        Rec.PostingItemJnlFromProduction(false);
                        CurrentJnlBatchName := Rec.GetRangeMax("Journal Batch Name");
                        CurrPage.Update(false);
                    end;
                }
                action("Post and &Print")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Post and &Print';
                    Image = PostPrint;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
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
                Promoted = true;
                PromotedCategory = Category4;
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
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        ItemJnlMgt.GetConsump(Rec, ProdOrderDescription);
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
        Rec.Validate("Entry Type", Rec."Entry Type"::Consumption);
        Clear(ShortcutDimCode);
    end;

    trigger OnOpenPage()
    var
        JnlSelected: Boolean;
    begin
        SetDimensionsVisibility();

        if Rec.IsOpenedFromBatch then begin
            CurrentJnlBatchName := Rec."Journal Batch Name";
            ItemJnlMgt.OpenJnl(CurrentJnlBatchName, Rec);
            exit;
        end;
        ItemJnlMgt.TemplateSelection(PAGE::"Consumption Journal", 4, false, Rec, JnlSelected);
        if not JnlSelected then
            Error('');
        ItemJnlMgt.OpenJnl(CurrentJnlBatchName, Rec);
    end;

    var
        ItemJnlMgt: Codeunit ItemJnlManagement;
        ReportPrint: Codeunit "Test Report-Print";
        ProdOrderDescription: Text[100];
        CurrentJnlBatchName: Code[10];
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        EasyLotTracking: Codeunit "Easy Lot Tracking";
        AllergenManagement: Codeunit "Allergen Management";
        [InDataSet]
        "Lot No.Editable": Boolean;

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

    local procedure CurrentJnlBatchNameOnAfterValidate()
    begin
        CurrPage.SaveRecord;
        ItemJnlMgt.SetName(CurrentJnlBatchName, Rec);
        CurrPage.Update(false);
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
                // CurrForm."Lot No.".EDITABLE(ProcessFns.TrackingInstalled AND ("Lot No." <> P800Globals.MultipleLotCode));  // P8000785
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

