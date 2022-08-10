page 7326 "Whse. Phys. Invt. Journal"
{
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 17 MAR 16
    //   Incorporate modifications for NAV Anywhere processes
    // 
    // PRW19.00.01
    // P8007117, To-Increase, Jack Reynolds, 01 JUN 16
    //   Correct missing Source Expression for Container License Plate
    //
    // PRW111.00.03
    //   P80092144,To-Increase, Gangabhushan, 27 JAN 20
    //     In warehouse Physical Inventory Journal system not allow to Register when container information added.

    AdditionalSearchTerms = 'physical count';
    ApplicationArea = Warehouse;
    AutoSplitKey = true;
    Caption = 'Warehouse Physical Inventory Journal';
    DataCaptionFields = "Journal Batch Name";
    DelayedInsert = true;
    PageType = Worksheet;
    PromotedActionCategories = 'New,Process,Report,Post/Print,Item,Line';
    SaveValues = true;
    SourceTable = "Warehouse Journal Line";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            field(CurrentJnlBatchName; CurrentJnlBatchName)
            {
                ApplicationArea = Warehouse;
                Caption = 'Batch Name';
                Lookup = true;
                ToolTip = 'Specifies the name of the journal batch, a personalized journal layout, that the journal is based on.';

                trigger OnLookup(var Text: Text): Boolean
                begin
                    CurrPage.SaveRecord();
                    Rec.LookupName(CurrentJnlBatchName, CurrentLocationCode, Rec);
                    CurrPage.Update(false);
                end;

                trigger OnValidate()
                begin
                    Rec.CheckName(CurrentJnlBatchName, CurrentLocationCode, Rec);
                    CurrentJnlBatchNameOnAfterVali;
                end;
            }
            field(CurrentLocationCode; CurrentLocationCode)
            {
                ApplicationArea = Warehouse;
                Caption = 'Location Code';
                Editable = false;
                Lookup = true;
                TableRelation = Location;
                ToolTip = 'Specifies the code for the location where the warehouse activity takes place.';
            }
            repeater(Control1)
            {
                ShowCaption = false;
                field("Registering Date"; Rec."Registering Date")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the date the line is registered.';
                }
                field("Whse. Document No."; Rec."Whse. Document No.")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Whse. Document No.';
                    ToolTip = 'Specifies the warehouse document number of the journal line.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of the item on the journal line.';

                    trigger OnValidate()
                    begin
                        ItemNoOnAfterValidate();
                        SetCatchAltQty; // P8001323
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
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the description of the item.';
                }
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = ItemTracking;
                    Editable = SerialNoEditable;
                    ToolTip = 'Specifies the same as for the field in the Item Journal window.';
                    Visible = false;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = ItemTracking;
                    Editable = LotNoEditable;
                    ToolTip = 'Specifies the same as for the field in the Item Journal window.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        SetExpirationDateEditable(ExpirationDateEditable); // P80092144 
                    end;
                }
                field("Package No."; Rec."Package No.")
                {
                    ApplicationArea = ItemTracking;
                    Editable = PackageNoEditable;
                    ToolTip = 'Specifies the same as for the field in the Item Journal window.';
                    Visible = PackageNoVisible;
                }
                field("Zone Code"; Rec."Zone Code")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the zone code where the bin on this line is located.';
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the bin where the items are picked or put away.';
                }
                field("Container License Plate"; Rec."Container License Plate")
                {
                    ApplicationArea = FOODBasic;
                    Editable = ("Container License Plate" = '') AND ("Qty. (Calculated)" = 0);
                }
                field("Qty. (Calculated) (Base)"; Rec."Qty. (Calculated) (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the same as for the field in the Item Journal window.';
                    Visible = false;
                }
                field("Qty. (Phys. Inventory) (Base)"; Rec."Qty. (Phys. Inventory) (Base)")
                {
                    ApplicationArea = Warehouse;
                    Editable = QtyPhysInventoryBaseIsEditable;
                    ToolTip = 'Specifies the same as for the field in the Item Journal window.';
                    Visible = false;
                }
                field("Qty. (Calculated)"; Rec."Qty. (Calculated)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity of the bin item that is calculated when you use the function, Calculate Inventory, in the Whse. Physical Inventory Journal.';
                }
                field("Qty. (Phys. Inventory)"; Rec."Qty. (Phys. Inventory)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity of items in the bin that you have counted.';

                    trigger OnValidate()
                    begin
                        SetExpirationDateEditable(ExpirationDateEditable); // P80092144 
                    end;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Warehouse;
                    Editable = false;
                    ToolTip = 'Specifies the number of units of the item in the adjustment (positive or negative) or the reclassification.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Qty. (Alt.) (Calculated)"; Rec."Qty. (Alt.) (Calculated)")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = (NOT CatchAltQty) AND FALSE;
                }
                field("Qty. (Alt.) (Phys. Inventory)"; Rec."Qty. (Alt.) (Phys. Inventory)")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = (NOT CatchAltQty) AND FALSE;
                }
                field("Quantity (Alt.)"; Rec."Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    HideValue = (NOT CatchAltQty) AND FALSE;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Reason Code';
                    ToolTip = 'Specifies the reason code for the warehouse journal line.';
                    Visible = false;
                }
                field("Phys Invt Counting Period Type"; Rec."Phys Invt Counting Period Type")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies whether the physical inventory counting period was assigned to a stockkeeping unit or an item.';
                    Visible = false;
                }
                field("Phys Invt Counting Period Code"; Rec."Phys Invt Counting Period Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies a code for the physical inventory counting period, if the counting period functionality was used when the line was created.';
                    Visible = false;
                }
                field("Expiration Date"; "Expiration Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = ExpirationDateEditable;
                    Visible = false;
                }
            }
            group(Control22)
            {
                ShowCaption = false;
                fixed(Control1900669001)
                {
                    ShowCaption = false;
                    group("Item Description")
                    {
                        Caption = 'Item Description';
                        field(ItemDescription; ItemDescription)
                        {
                            ApplicationArea = Warehouse;
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
            group("&Item")
            {
                Caption = '&Item';
                Image = Item;
                action(Card)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Card';
                    Image = EditLines;
                    Promoted = true;
                    PromotedCategory = Category5;
                    RunObject = Page "Item Card";
                    RunPageLink = "No." = FIELD("Item No.");
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'View or change detailed information about the record on the document or journal line.';
                }
                action("Warehouse Entries")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Warehouse Entries';
                    Image = BinLedger;
                    RunObject = Page "Warehouse Entries";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code"),
                                  "Location Code" = FIELD("Location Code");
                    RunPageView = SORTING("Item No.", "Location Code", "Variant Code", "Bin Type Code", "Unit of Measure Code", "Lot No.", "Serial No.");
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View completed warehouse activities related to the document.';
                }
                action("Ledger E&ntries")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Ledger E&ntries';
                    Image = ItemLedger;
                    Promoted = true;
                    PromotedCategory = Category5;
                    RunObject = Page "Item Ledger Entries";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code"),
                                  "Location Code" = FIELD("Location Code");
                    RunPageView = SORTING("Item No.");
                    ToolTip = 'View the history of transactions that have been posted for the selected record.';
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
                    RunPageView = SORTING("Location Code", "Item No.", "Variant Code");
                    ToolTip = 'View items in the bin if the selected line contains a bin code.';
                }
            }
        }
        area(processing)
        {
            group("&Line")
            {
                Caption = '&Line';
                action("New Container")
                {
                    AccessByPermission = TableData "Container Header" = R;
                    ApplicationArea = FOODBasic;
                    Caption = 'New Container';
                    Enabled = ("Container License Plate" = '') AND ("Qty. (Calculated)" = 0);
                    Image = NewItem;

                    trigger OnAction()
                    begin
                        // P8001323
                        ContainerFns.NewContainerOnWhseJournalLine(Rec);
                        CurrPage.Update;
                    end;
                }
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Calculate &Inventory")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Calculate &Inventory';
                    Ellipsis = true;
                    Image = CalculateInventory;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Start the process of counting inventory by filling the journal with known quantities.';

                    trigger OnAction()
                    var
                        BinContent: Record "Bin Content";
                        WhseCalcInventory: Report "Whse. Calculate Inventory";
                    begin
                        BinContent.SetRange("Location Code", Rec."Location Code");
                        WhseCalcInventory.SetWhseJnlLine(Rec);
                        WhseCalcInventory.SetTableView(BinContent);
                        WhseCalcInventory.SetProposalMode(true);
                        WhseCalcInventory.RunModal();
                        Clear(WhseCalcInventory);
                    end;
                }
                action("&Calculate Counting Period")
                {
                    ApplicationArea = Warehouse;
                    Caption = '&Calculate Counting Period';
                    Ellipsis = true;
                    Image = CalculateCalendar;
                    ToolTip = 'Show all items that a counting period has been assigned to, according to the counting period, the last counting period update, and the current work date.';

                    trigger OnAction()
                    var
                        PhysInvtCountMgt: Codeunit "Phys. Invt. Count.-Management";
                        SortingMethod: Option " ",Item,Bin;
                    begin
                        PhysInvtCountMgt.InitFromWhseJnl(Rec);
                        PhysInvtCountMgt.Run();

                        PhysInvtCountMgt.GetSortingMethod(SortingMethod);
                        case SortingMethod of
                            SortingMethod::Item:
                                Rec.SetCurrentKey("Location Code", "Item No.", "Variant Code");
                            SortingMethod::Bin:
                                Rec.SetCurrentKey("Location Code", "Bin Code");
                        end;

                        Clear(PhysInvtCountMgt);
                    end;
                }
            }
            action("&Print")
            {
                ApplicationArea = Warehouse;
                Caption = '&Print';
                Ellipsis = true;
                Image = Print;
                Promoted = true;
                PromotedCategory = Category4;
                ToolTip = 'Prepare to print the document. A report request window for the document opens where you can specify what to include on the print-out.';

                trigger OnAction()
                begin
                    WhseJournalBatch.SetRange("Journal Template Name", Rec."Journal Template Name");
                    WhseJournalBatch.SetRange(Name, Rec."Journal Batch Name");
                    WhseJournalBatch.SetRange("Location Code", CurrentLocationCode);
                    WhsePhysInventoryList.SetTableView(WhseJournalBatch);
                    WhsePhysInventoryList.RunModal();
                    Clear(WhsePhysInventoryList);
                end;
            }
            group("&Registering")
            {
                Caption = '&Registering';
                Image = PostOrder;
                action("Test Report")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Test Report';
                    Ellipsis = true;
                    Image = TestReport;
                    ToolTip = 'View a test report so that you can find and correct any errors before you perform the actual posting of the journal or document.';

                    trigger OnAction()
                    begin
                        ReportPrint.PrintWhseJnlLine(Rec);
                    end;
                }
                action("&Register")
                {
                    ApplicationArea = Warehouse;
                    Caption = '&Register';
                    Image = Confirm;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ShortCutKey = 'F9';
                    ToolTip = 'Register the warehouse entry in question, such as a positive adjustment. ';

                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"Whse. Jnl.-Register", Rec);
                        CurrentJnlBatchName := Rec.GetRangeMax("Journal Batch Name");
                        CurrPage.Update(false);
                    end;
                }
                action("Register and &Print")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Register and &Print';
                    Image = ConfirmAndPrint;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ShortCutKey = 'Shift+F9';
                    ToolTip = 'Register the warehouse entry adjustments and print an overview of the changes. ';

                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"Whse. Jnl.-Register+Print", Rec);
                        CurrentJnlBatchName := Rec.GetRangeMax("Journal Batch Name");
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        Rec.GetItem(Rec."Item No.", ItemDescription);
        SetControls;
    end;

    trigger OnAfterGetRecord()
    begin
        SetCatchAltQty; // P8001323
        SetExpirationDateEditable(ExpirationDateEditable); // P80092144
    end;

    trigger OnInit()
    begin
        LotNoEditable := true;
        SerialNoEditable := true;
        ExpirationDateEditable := true; // P80092144
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.SetUpNewLine(xRec);
    end;

    trigger OnOpenPage()
    var
        JnlSelected: Boolean;
    begin
        if Rec.IsOpenedFromBatch then begin
            CurrentJnlBatchName := Rec."Journal Batch Name";
            CurrentLocationCode := Rec."Location Code";
            Rec.OpenJnl(CurrentJnlBatchName, CurrentLocationCode, Rec);
            exit;
        end;
        JnlSelected := Rec.TemplateSelection(PAGE::"Whse. Phys. Invt. Journal", "Warehouse Journal Template Type"::"Physical Inventory", Rec);
        if not JnlSelected then
            Error('');
        Rec.OpenJnl(CurrentJnlBatchName, CurrentLocationCode, Rec);

        SetPackageTrackingVisibility();
    end;

    var
        WhseJournalBatch: Record "Warehouse Journal Batch";
        WhsePhysInventoryList: Report "Whse. Phys. Inventory List";
        ReportPrint: Codeunit "Test Report-Print";
        CurrentJnlBatchName: Code[10];
        CurrentLocationCode: Code[10];
        ContainerFns: Codeunit "Container Functions";
        [InDataSet]
        CatchAltQty: Boolean;
        Item: Record Item;
        ExpirationDateEditable: Boolean;

    protected var
        ItemDescription: Text[100];
        [InDataSet]
        SerialNoEditable: Boolean;
        [InDataSet]
        LotNoEditable: Boolean;
        [InDataSet]
        PackageNoEditable: Boolean;
        [InDataSet]
        PackageNoVisible: Boolean;
        QtyPhysInventoryBaseIsEditable: Boolean;

    procedure SetControls()
    begin
        SerialNoEditable := (not Rec."Phys. Inventory") or ((Rec."Serial No." = '') and (Rec."Qty. (Calculated)" = 0)); // P8001323
        LotNoEditable := (not Rec."Phys. Inventory") or ((Rec."Lot No." = '') and (Rec."Qty. (Calculated)" = 0)); // P8001323
        PackageNoEditable := not Rec."Phys. Inventory";
        QtyPhysInventoryBaseIsEditable := Rec.IsQtyPhysInventoryBaseEditable();
    end;

    local procedure CurrentJnlBatchNameOnAfterVali()
    begin
        CurrPage.SaveRecord;
        Rec.SetName(CurrentJnlBatchName, CurrentLocationCode, Rec);
        CurrPage.Update(false);
    end;

    procedure ItemNoOnAfterValidate()
    begin
        Rec.GetItem(Rec."Item No.", ItemDescription);
    end;

    local procedure SetCatchAltQty()
    begin
        // P8001323
        if Item.Get("Item No.") then
            CatchAltQty := Item."Catch Alternate Qtys."
        else
            CatchAltQty := false;
    end;

    local procedure SetPackageTrackingVisibility()
    var
        PackageMgt: Codeunit "Package Management";
    begin
        PackageNoVisible := PackageMgt.IsEnabled();
    end;
}

