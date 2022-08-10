page 6505 "Lot No. Information Card"
{
    // PR2.00
    //   No insertion or deletion
    //   P800 fields
    //   Menu items for List, Lot Tracing, Quality Control, Lot Specifications
    // 
    // PR3.70.01
    //   Add Properties tab with controls for receiving reason code, farm, brand
    // 
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Add controls for lot age calculated fields and lot specification shortcust categories
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Don Bresee, 26 JUN 07
    //   Remove Lot Tracing menu option
    // 
    // PRW15.00.03
    // P8000624A, VerticalSoft, Jack Reynolds, 19 AUG 08
    //   Add controls to Properties tab for country/region of origin
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 13 APR 09
    //   Transformed
    //   Page changes made after transformation
    // 
    // PRW16.00.04
    // P8000899, Columbus IT, Ron Davidson, 01 MAR 11
    //   Added Freshness Date logic.
    // 
    // PRW16.00.05
    // P8000969, Columbus IT, Jack Reynolds, 12 AUG 11
    //   Fix problem with Freshness Calc. Method
    // 
    // P8000979, Columbus IT, Jack Reynolds, 06 OCT 11
    //   Add Action for Lot Tracing
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Lot No. Information Card';
    DeleteAllowed = false;
    PageType = Card;
    PopulateAllFields = true;
    SourceTable = "Lot No. Information";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Item No."; "Item No.")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies this number from the Tracking Specification table when a lot number information record is created.';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant of the item on the line.';
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies this number from the Tracking Specification table when a lot number information record is created.';
                }
                field(Description; Description)
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies a description of the lot no. information record.';
                }
                field("Certificate Number"; "Certificate Number")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the number provided by the supplier to indicate that the batch or lot meets the specified requirements.';
                }
                field("Supplier Lot No."; "Supplier Lot No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies that the related record is blocked from being posted in transactions, for example a customer that is declared insolvent or an item that is placed in quarantine.';
                    Visible = false;
                }
                field("Lot Status Code"; "Lot Status Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Posted; Posted)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quality Control"; "Quality Control")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                }
                field("Lot Specifications"; "Lot Specifications")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                }
            }
            group(Inventory)
            {
                Caption = 'Inventory';
                field(InventoryField; Inventory)
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the inventory quantity of the specified lot number.';
                }
                field("Expired Inventory"; "Expired Inventory")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the inventory of the lot number with an expiration date before the posting date on the associated document.';
                }
            }
            group(Control1907037201)
            {
                Caption = 'Quality Control';
                field("Expected Release Date"; "Expected Release Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Release Date"; "Release Date")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;
                }
                field("Expiration Date"; "Expiration Date")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;
                }
                field("Lot Strength Percent"; "Lot Strength Percent")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Age)
            {
                Caption = 'Age';
                field("Creation Date"; "Creation Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = proddateeditable;

                    trigger OnValidate()
                    begin
                        GetAgeVars; // P8000153A
                    end;
                }
                field(Control37002016; Age)
                {
                    ApplicationArea = FOODBasic;
                    BlankNumbers = BlankNeg;
                    Caption = 'Age';
                    Editable = false;
                    Importance = Promoted;
                }
                field(AgeCategory; AgeCategory)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Age Category';
                    Editable = false;
                }
                field(AgeDate; AgeDate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Current Age Date';
                    Editable = false;
                }
                field(RemainingDaysText; RemainingDaysText)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Remaining Days';
                    Editable = false;
                }
                field("Freshness Date"; "Freshness Date")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = HideFreshDate;
                    Style = Unfavorable;
                    StyleExpr = SetFreshDateStyleExpr;
                }
                field("Item.""Freshness Calc. Method"""; Item."Freshness Calc. Method")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Freshness Calc. Method';
                    Editable = false;
                }
            }
            group(Properties)
            {
                Caption = 'Properties';
                field("Receiving Reason Code"; "Receiving Reason Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Farm; Farm)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Brand; Brand)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Country/Region of Origin Code"; "Country/Region of Origin Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(tbLotSpec1; ShortcutLotSpec[1])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '37002020,1';
                    Editable = false;
                    Visible = lotspecvisible1;
                }
                field(tbLotSpec2; ShortcutLotSpec[2])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '37002020,2';
                    Editable = false;
                    Visible = lotspecvisible2;
                }
                field(tbLotSpec3; ShortcutLotSpec[3])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '37002020,3';
                    Editable = false;
                    Visible = lotspecvisible3;
                }
                field(tbLotSpec4; ShortcutLotSpec[4])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '37002020,4';
                    Editable = false;
                    Visible = lotspecvisible4;
                }
                field(tbLotSpec5; ShortcutLotSpec[5])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '37002020,5';
                    Editable = false;
                    Visible = lotspecvisible5;
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
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Lot No.")
            {
                Caption = '&Lot No.';
                Image = Lot;
                action("Item &Tracking Entries")
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Item &Tracking Entries';
                    Image = ItemTrackingLedger;
                    ShortCutKey = 'Shift+Ctrl+I';
                    ToolTip = 'View serial or lot numbers that are assigned to items.';

                    trigger OnAction()
                    var
                        ItemTrackingSetup: Record "Item Tracking Setup";
                        ItemTrackingDocMgt: Codeunit "Item Tracking Doc. Management";
                    begin
                        ItemTrackingSetup."Lot No." := "Lot No.";
                        ItemTrackingDocMgt.ShowItemTrackingForEntity(0, '', "Item No.", "Variant Code", '', ItemTrackingSetup);
                    end;
                }
                action(Comment)
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Comment';
                    Image = ViewComments;
                    RunObject = Page "Item Tracking Comments";
                    RunPageLink = Type = CONST("Lot No."),
                                  "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code"),
                                  "Serial/Lot No." = FIELD("Lot No.");
                    ToolTip = 'View or add comments for the record.';
                }
                action("&Quality Control")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Quality Control';
                    Image = CheckRulesSyntax;
                    RunObject = Page "Quality Control";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code"),
                                  "Lot No." = FIELD("Lot No.");
                }
                action("&Lot Specifications")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Lot Specifications';
                    Image = LotInfo;
                    RunObject = Page "Lot Specifications";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code"),
                                  "Lot No." = FIELD("Lot No.");
                }
                separator(Action28)
                {
                }
            }
        }
        area(processing)
        {
            group(ButtonFunctions)
            {
                Caption = 'F&unctions';
                Image = "Action";
                Visible = ButtonFunctionsVisible;
                action(CopyInfo)
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Copy &Info';
                    Ellipsis = true;
                    Image = CopySerialNo;
                    ToolTip = 'Copy the information record from the old lot number.';

                    trigger OnAction()
                    var
                        SelectedRecord: Record "Lot No. Information";
                        ShowRecords: Record "Lot No. Information";
                        FocusOnRecord: Record "Lot No. Information";
                        ItemTrackingMgt: Codeunit "Item Tracking Management";
                        LotNoInfoList: Page "Lot No. Information List";
                    begin
                        ShowRecords.SetRange("Item No.", "Item No.");
                        ShowRecords.SetRange("Variant Code", "Variant Code");

                        FocusOnRecord.Copy(ShowRecords);
                        FocusOnRecord.SetRange("Lot No.", TrackingSpec."Lot No.");

                        LotNoInfoList.SetTableView(ShowRecords);

                        if FocusOnRecord.FindFirst then
                            LotNoInfoList.SetRecord(FocusOnRecord);
                        if LotNoInfoList.RunModal = ACTION::LookupOK then begin
                            LotNoInfoList.GetRecord(SelectedRecord);
                            ItemTrackingMgt.CopyLotNoInformation(SelectedRecord, "Lot No.");
                        end;
                    end;
                }
            }
            action("&Item Tracing")
            {
                ApplicationArea = ItemTracking;
                Caption = '&Item Tracing';
                Image = ItemTracing;
                ToolTip = 'Trace where a lot or serial number assigned to the item was used, for example, to find which lot a defective component came from or to find all the customers that have received items containing the defective component.';

                trigger OnAction()
                var
                    ItemTracingBuffer: Record "Item Tracing Buffer";
                    ItemTracing: Page "Item Tracing";
                begin
                    Clear(ItemTracing);
                    ItemTracingBuffer.SetRange("Item No.", "Item No.");
                    ItemTracingBuffer.SetRange("Variant Code", "Variant Code");
                    ItemTracingBuffer.SetRange("Lot No.", "Lot No.");
                    ItemTracing.InitFilters(ItemTracingBuffer);
                    ItemTracing.FindRecords;
                    ItemTracing.RunModal;
                end;
            }
            action("&Lot Tracing")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Lot Tracing';
                Image = ItemTracing;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    LotTracingPage: Page "Lot Tracing";
                begin
                    // P8000979
                    LotTracingPage.SetTraceLot("Item No.", "Variant Code", "Lot No.");
                    LotTracingPage.Run;
                end;
            }
            action(Navigate)
            {
                ApplicationArea = ItemTracking;
                Caption = 'Find entries...';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                ShortCutKey = 'Shift+Ctrl+I';
                ToolTip = 'Find entries and documents that exist for the document number and posting date on the selected document. (Formerly this action was named Navigate.)';

                trigger OnAction()
                var
                    ItemTrackingSetup: Record "Item Tracking Setup";
                    Navigate: Page Navigate;
                begin
                    ItemTrackingSetup."Lot No." := Rec."Lot No.";
                    Navigate.SetTracking(ItemTrackingSetup);
                    Navigate.Run();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        // P8000153A Begin
        GetAgeVars;
        if ShowLotSpecs then
            ShowShortcutLotSpec(ShortcutLotSpec);
        ProdDateEditable := "Creation Date" = 0D;
        if RemainingDays = 2147483647 then
            RemainingDaysText := Text37002000
        else
            RemainingDaysText := Format(RemainingDays);
        // P8000153A End

        // P8000899
        Item.Get("Item No.");
        HideFreshDate := not Item.UseFreshnessDate; // P8000969
        SetFreshDateStyleExpr := Item.UseFreshnessDate and ("Freshness Date" < Today); // P8000969
        // P8000899
    end;

    trigger OnOpenPage()
    begin
        Rec.SetFilter("Date Filter", '>%1&<=%2', 0D, WorkDate());
        if ShowButtonFunctions then
            ButtonFunctionsVisible := true;
        // P8000153A Begin
        InvSetup.Get;
        // P8000153A End
        // P8000664
        LotSpecVisible1 := InvSetup."Shortcut Lot Spec. 1 Code" <> '';
        LotSpecVisible2 := InvSetup."Shortcut Lot Spec. 2 Code" <> '';
        LotSpecVisible3 := InvSetup."Shortcut Lot Spec. 3 Code" <> '';
        LotSpecVisible4 := InvSetup."Shortcut Lot Spec. 4 Code" <> '';
        LotSpecVisible5 := InvSetup."Shortcut Lot Spec. 5 Code" <> '';
        ShowLotSpecs := LotSpecVisible1 or LotSpecVisible2 or LotSpecVisible3 or LotSpecVisible4 or LotSpecVisible5;
        // P8000664
    end;

    var
        TrackingSpec: Record "Tracking Specification";
        ShowButtonFunctions: Boolean;
        InvSetup: Record "Inventory Setup";
        P800Fns: Codeunit "Process 800 Functions";
        Age: Integer;
        AgeCategory: Code[10];
        AgeDate: Date;
        RemainingDays: Integer;
        ShowLotSpecs: Boolean;
        ShortcutLotSpec: array[5] of Code[50];
        Text37002000: Label 'N/A';
        [InDataSet]
        ButtonFunctionsVisible: Boolean;
        [InDataSet]
        ProdDateEditable: Boolean;
        [InDataSet]
        LotSpecVisible1: Boolean;
        [InDataSet]
        LotSpecVisible2: Boolean;
        [InDataSet]
        LotSpecVisible3: Boolean;
        [InDataSet]
        LotSpecVisible4: Boolean;
        [InDataSet]
        LotSpecVisible5: Boolean;
        [InDataSet]
        RemainingDaysText: Text[1024];
        Item: Record Item;
        [InDataSet]
        HideFreshDate: Boolean;
        [InDataSet]
        SetFreshDateStyleExpr: Boolean;

    procedure Init(CurrentTrackingSpec: Record "Tracking Specification")
    begin
        TrackingSpec := CurrentTrackingSpec;
        ShowButtonFunctions := true;
    end;

    procedure InitWhse(CurrentTrackingSpec: Record "Whse. Item Tracking Line")
    begin
        TrackingSpec."Lot No." := CurrentTrackingSpec."Lot No.";
        ShowButtonFunctions := true;

        OnAfterInitWhse(TrackingSpec, CurrentTrackingSpec);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitWhse(var TrackingSpecification: Record "Tracking Specification"; WhseItemTrackingLine: Record "Whse. Item Tracking Line")
    begin
    end;

    procedure GetAgeVars()
    var
        LotFilterFns: Codeunit "Lot Filtering";
    begin
        // P8000153A
        if P800Fns.TrackingInstalled then begin
            Age := LotFilterFns.Age(Rec);
            AgeCategory := LotFilterFns.AgeCategory(Rec);
            AgeDate := LotFilterFns.AgeDate(Rec);
            RemainingDays := LotFilterFns.RemainingDays(Rec);
        end;
    end;
}

