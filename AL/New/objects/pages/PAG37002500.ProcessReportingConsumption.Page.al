page 37002500 "Process Reporting Consumption"
{
    // PR1.20
    //   Consumption journal subform for Process Output
    // 
    // PR2.00
    //   Remove Lot No.
    //   Dimensions
    //   Item Tracking
    // 
    // PR3.10
    //   Move Consumption journal into Output journal
    // 
    // PR3.60
    //   Add fields/logic for alternate quantities
    //   Change call for item tracking
    // 
    // PR3.70.04
    // P8000043A, Myers Nissi, Jack Reynolds, 02 JUN 04
    //    Support for easy lot tracking
    // 
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Support for checking lot preferences
    // 
    // PR3.70.10
    // P8000227A, Myers Nissi, Jack Reynolds, 07 JUL 05
    //   Fix problem specifying lot before line has been inserted
    // 
    // PR4.00.01
    // P8000267B, VerticalSoft, Jack Reynolds, 12 DEC 05
    //   Add code to Item No. OnLookup to be in line with SP1 changes to standard forms
    // 
    // PR4.00.02
    // P8000316A, VerticalSoft, Jack Reynolds, 31 MAR 06
    //   Add control for Lot Tracked
    // 
    // PR4.00.03
    // P8000343A, VerticalSoft, Jack Reynolds, 05 JUN 06
    //   Modify to support easy lot with reclass journal
    // 
    // PRW16.00.02
    // P8000785, VerticalSoft, Rick Tweedle, 05 MAR 10
    //   Changes to code to make it transformation tool work
    // 
    // P8000785, VerticalSoft, Rick Tweedle, 05 MAR 10
    //   Created page based on form version - with amendment to make it RTC compatible
    // 
    // PRW16.00.03
    // P8000817, VerticalSoft, Jack Reynolds, 26 APR 10
    //   Change visible property of fields
    // 
    // PRW16.00.05
    // P8000977, Columbus IT, Jack Reynolds, 09 SEP 11
    //   Fix problem with dimensions on new lines
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW121.2
    // P800163700, To-Increase, Jack Reynolds, 07 FEB 23
    //   Support for Auto-Save as You Work

    AutoSplitKey = true;
    Caption = 'Process Reporting Consumption';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Item Journal Line";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupItemNo; // P8000267B
                    end;

                    trigger OnValidate()
                    var
                        LineNo: Integer;
                    begin
                        if "No." <> xRec."No." then begin
                            POComp.Reset;
                            if "Prod. Order Comp. Line No." <> 0 then begin
                                if POComp.Get(POComp.Status::Released, "Order No.", "Order Line No.", // P8001132
                                  "Prod. Order Comp. Line No.") then begin
                                    POComp.Validate("Item No.", "No.");
                                    POComp.Modify;
                                end;
                            end else
                                if "No." <> '' then begin
                                    POComp.SetRange(Status, POComp.Status::Released);
                                    POComp.SetRange("Prod. Order No.", "Order No."); // P8001132
                                    POComp.SetRange("Prod. Order Line No.", "Order Line No."); // P8001132
                                    POComp.SetRange("Item No.", "No.");
                                    if not POComp.Find('-') then begin
                                        POComp.LockTable;
                                        POComp.SetRange("Item No.");
                                        if POComp.Find('+') then
                                            LineNo := POComp."Line No." + 10000
                                        else
                                            LineNo := 10000;
                                        POComp.Init;
                                        POComp.Status := POComp.Status::Released;
                                        POComp."Prod. Order No." := "Order No."; // P8001132
                                        POComp."Prod. Order Line No." := "Order Line No."; // P8001132
                                        POComp."Line No." := LineNo;
                                        POComp.Validate("Item No.", "No.");
                                        POComp.Insert(true); // P8000153A
                                    end;
                                    "Prod. Order Comp. Line No." := POComp."Line No.";
                                    POLine.Get(POLine.Status::Released, "Order No.", "Order Line No."); // P8001132
                                    Validate("Location Code", POLine."Location Code");
                                end;
                        end; // PR3.10
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
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field(LotTrackingRequired; LotTrackingRequired)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Lot Tracked';
                }
                field("Expected Quantity"; "Expected Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity (Alt.)"; "Quantity (Alt.)")
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
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Lot No.Editable";

                    trigger OnAssistEdit()
                    begin
                        // P8000043A
                        CurrPage.SaveRecord; // P8000153A
                        Commit;              // P8000153A
                        EasyLotTracking.SetItemJnlLine(Rec, FieldNo("Lot No.")); // P8000343A
                        if EasyLotTracking.AssistEdit("Lot No.") then
                            UpdateLotTracking(true);
                        CurrPage.SaveRecord;
                    end;

                    trigger OnValidate()
                    begin
                        // P8000227A Begin
                        if "Line No." = 0 then begin
                            CurrPage.SaveRecord;
                            UpdateLotTracking(false);
                        end;
                        // P8000227A End
                    end;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Container License Plate"; "Container License Plate")
                {
                    ApplicationArea = FOODBasic;
                    AccessByPermission = TableData "Container Header" = R;
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ContainerFns: Codeunit "Container Functions";
                    begin
                        // P8001323
                        exit(ContainerFns.LookupContainerOnItemJnlLine(Rec, FieldNo("Container License Plate"), Text));
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("&Dimensions")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Dimensions';
                Image = Dimensions;
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

                trigger OnAction()
                begin
                    //This functionality was copied from page #37002491. Unsupported part was commented. Please check it.
                    /*CurrPage.Consumption.PAGE.*/
                    ItemTracking; // PR2.00

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
    }

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        SetLotFields('EDITABLE'); // PR3.10
    end;

    trigger OnInit()
    var
        grp: Integer;
    begin
        "Lot No.Editable" := true;
        ProcessSetup.Get;
        ProcessSetup.TestField("Process Consumption Template");
        ProcessSetup.TestField("Process Consumption Batch");

        //grp := FILTERGROUP(4);
        FilterGroup := 4;
        SetRange("Journal Template Name", ProcessSetup."Process Consumption Template");
        SetRange("Journal Batch Name", ProcessSetup."Process Consumption Batch");
        FilterGroup := 0;
        //FILTERGROUP(grp);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if ProdOrder.Get(ProdOrder.Status::Released, xRec."Order No.") then begin // P8001132
            SetUpNewLine(xRec);
            Validate("Order Type", "Order Type"::Production); // P8001132
            Validate("Order No.", xRec."Order No."); // P8001132
            Description := '';
            Validate("Document No.", xRec."Document No.");
            Validate("Order Line No.", xRec."Order Line No."); // P8001132
        end;
    end;

    var
        ProcessSetup: Record "Process Setup";
        POLine: Record "Prod. Order Line";
        POComp: Record "Prod. Order Component";
        ProdOrder: Record "Production Order";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        EasyLotTracking: Codeunit "Easy Lot Tracking";
        AllergenManagement: Codeunit "Allergen Management";
        [InDataSet]
        "Lot No.Editable": Boolean;

    procedure SetFilter(ProdOrderNo: Code[20])
    var
        grp: Integer;
    begin
        //grp := FILTERGROUP(4);   // P8000785
        //SETRANGE("Prod. Order No.",ProdOrderNo);
        //FILTERGROUP(grp);        // P8000785
    end;

    procedure UpdateForm()
    begin
        CurrPage.Update(false);
    end;

    procedure ItemTracking()
    begin
        CurrPage.SaveRecord;          // PR3.60
        OpenItemTrackingLines(false); // PR3.60
    end;

    procedure SetLotFields(Property: Code[10])
    var
        ProcessFns: Codeunit "Process 800 Functions";
        P800Globals: Codeunit "Process 800 System Globals";
    begin
        // P8000043A
        case Property of
            'EDITABLE':
                //CurrForm."Lot No.".EDITABLE(ProcessFns.TrackingInstalled AND ("Lot No." <> P800Globals.MultipleLotCode)); // P8000785
                "Lot No.Editable" := ProcessFns.TrackingInstalled and ("Lot No." <> P800Globals.MultipleLotCode); // P8000785
        end;
    end;
}

