page 37002020 Lots
{
    // PR1.10, Navision US, John Nozzi, 27 MAR 01, New Object
    //   This form is used to view Inventory Lots for Lot Controlled items.
    //   From here the user can also enter Q/C Results.
    // 
    // PR1.10.01
    //   Add print menu button for Test Results and Certificate of Analysis
    // 
    // PR1.10.02
    //   Add menu button to filter lots by test results and lot specifications
    // 
    // PR3.10
    //   Fix glue on Navigate button
    // 
    // PR3.60
    //   Change call for item tracking entries
    // 
    // PR3.70
    //   Change call for item tracking entries
    // 
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Change filtering to use new lot specification filtering methods
    // 
    // PR4.00.04
    // P8000407A, VerticalSoft, Jack Reynolds, 10 OCT 06
    //   Add menu item to run lot tracing
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 31 JUL 07
    //   Replace Lot Tracing on the Lot menu button with Item Tracing.
    //   Replace Navigate command button with Navigate menu button with two items for general navigation and lot navigation.
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 14 APR 09
    //   Transformed - additions in TIF Editor
    //   Page changes made after transformation
    // 
    // PRW16.00.04
    // P8000899, Columbus IT, Ron Davidson, 01 MAR 11
    //   Added Freshness Date logic.
    // 
    // PRW16.00.05
    // P8000969, Columbus IT, Jack Reynolds, 12 AUG 11
    //   Fix problem with Style for Freshness Date
    // 
    // P8000979, Columbus IT, Jack Reynolds, 06 OCT 11
    //   Add Action for Lot Tracing
    // 
    // P8000984, Columbus IT, Don Bresee, 18 OCT 11
    //   Modify Lot Tracing Action for Multiple Lot Trace
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW16.00.06
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // P8001070, Columbus IT, Jack Reynolds, 07 JAN 13
    //   Support for Lot Freshness
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 9 NOV 15
    //   NAV 2016 refactoring; Cleanup action names
    // 
    // PRW19.00.01
    // P8007841, To-Increase, Dayakar Battini, 12 OCT 16
    //   Enabling Lot Creation and Freshness dates updation.
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.
    //
    // PRW118.1
    // P800129613, To Increase, Jack Reynolds, 20 SEP 21
    //   Creatre Sub-Lot Wizard
    // 
    // PRW120.00
    // P800144605, To Increase, Jack Reynolds, 20 APR 22
    //   Upgrade to 20.0

    ApplicationArea = FOODBasic;
    AdditionalSearchTerms = 'lot history';
    Caption = 'Lots';
    DataCaptionFields = "Item No.";
    Editable = false;
    PageType = List;
    SourceTable = "Lot No. Information";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control37002013)
            {
                ShowCaption = false;
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot Status Code"; Rec."Lot Status Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Supplier Lot No."; Rec."Supplier Lot No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Expected Release Date"; Rec."Expected Release Date")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Release Date"; Rec."Release Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Freshness Date"; Rec."Freshness Date")
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
                    Visible = false;
                }
                field("Lot Strength Percent"; Rec."Lot Strength Percent")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(CountOriginal; Rec.ActivityCount((false)))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Original Activities';
                    DrillDown = false;
                }
                field(CountReTest; Rec.ActivityCount((true)))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Re-Test Activities';
                    DrillDown = false;
                }
                field("Lot Specifications"; Rec."Lot Specifications")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Inventory; Rec.Inventory)
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
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Lot")
            {
                Caption = '&Lot';
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;
                    RunObject = Page "Lot No. Information Card";
                    RunPageOnRec = true;
                    ShortCutKey = 'Return';
                }
                action("Item &Tracking Entries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item &Tracking Entries';
                    Image = ItemTrackingLedger;
                    ShortCutKey = 'Ctrl+F7';

                    trigger OnAction()
                    var
                        ItemTrackingSetup: Record "Item Tracking Setup";
                        ItemTrackingDocMgt: Codeunit "Item Tracking Doc. Management";
                    begin
                        ItemTrackingSetup."Lot No." := Rec."Lot No."; // P800144605
                        ItemTrackingDocMgt.ShowItemTrackingForEntity(0, '', Rec."Item No.", Rec."Variant Code", '', ItemTrackingSetup); // PR3.70, P8004516, P800144605
                    end;
                }
                action("Quality Control")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Quality Control';
                    Image = CheckRulesSyntax;
                    RunObject = Page "Quality Control";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code"),
                                  "Lot No." = FIELD("Lot No.");
                }
                action("Lot &Specifications")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Lot &Specifications';
                    Image = LotInfo;
                    RunObject = Page "Lot Specifications";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code"),
                                  "Lot No." = FIELD("Lot No.");
                }
                action("&Item Tracing")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Item Tracing';
                    Image = ItemTracing;
                    ShortCutKey = 'Ctrl+T';

                    trigger OnAction()
                    var
                        ItemTracingBuffer: Record "Item Tracing Buffer";
                        ItemTracing: Page "Item Tracing";
                    begin
                        // P8000466A
                        ItemTracingBuffer.SetRange("Item No.", Rec."Item No.");
                        ItemTracingBuffer.SetRange("Variant Code", Rec."Variant Code");
                        ItemTracingBuffer.SetRange("Lot No.", Rec."Lot No.");
                        ItemTracing.InitFilters(ItemTracingBuffer);
                        ItemTracing.FindRecords;
                        ItemTracing.Run; // P8000979
                    end;
                }
                action("&Lot Tracing")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Lot Tracing';
                    Image = ItemTracing;

                    trigger OnAction()
                    var
                        LotTracingPage: Page "Lot Tracing";
                        SelectedLot: Record "Lot No. Information";
                        MultLotTracePage: Page "Multiple Lot Trace";
                    begin
                        // P8000979, P8000984
                        CurrPage.SetSelectionFilter(SelectedLot);
                        if (SelectedLot.Count > 1) then begin
                            MultLotTracePage.SetTraceFromLots(SelectedLot);
                            MultLotTracePage.Run;
                        end else begin
                            LotTracingPage.SetTraceLot(Rec."Item No.", Rec."Variant Code", Rec."Lot No.");
                            LotTracingPage.Run;
                        end;
                    end;
                }
                // P800129613
                action(CreateSubLot)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Create Sub-Lot';
                    Ellipsis = true;
                    Image = LotProperties;

                    trigger OnAction();
                    var
                        LotNoInfo: Record "Lot No. Information";
                        SubLotManagement: Codeunit "Sub-Lot Management";
                        ErrNoInventory: Label 'There is no inventory for this item.';
                    begin
                        LotNoInfo := Rec;
                        LotNoInfo.CalcFields(Inventory);
                        if LotNoInfo.Inventory > 0 then
                            SubLotManagement.CreateSubLotWizard(Rec)
                        else
                            Error(ErrNoInventory);
                    end;
                }
            }
        }
        area(processing)
        {
            group("Filter")
            {
                Caption = 'Filter';
                action(Clear)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Clear';
                    Image = Delete;

                    trigger OnAction()
                    begin
                        // P8000664
                        LotSpecFilter.Reset;
                        LotSpecFilter.DeleteAll;
                        CurrPage.Update(false);
                    end;
                }
                action(Set)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Set';
                    Ellipsis = true;
                    Image = EditFilter;

                    trigger OnAction()
                    var
                        LotAgeFilter: Record "Lot Age";
                    begin
                        // P8000664
                        if not LotFiltering.LotSpecAssist(LotSpecFilter) then
                            exit;
                        CurrPage.Update(false);
                    end;
                }
            }
            group(NavigateMenu)
            {
                Caption = 'Find entries';
                action(General)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'General...';
                    Image = Navigate;

                    trigger OnAction()
                    var
                        Navigate: Page Navigate;
                    begin
                        // P8000466A
                        Navigate.SetDoc(Rec."Document Date", Rec."Document No.");
                        Navigate.Run;
                    end;
                }
                action("Item Tracking")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Tracking...';
                    Image = ItemTracking;

                    trigger OnAction()
                    var
                        Navigate: Page Navigate;
                    begin
                        // P8000466A
                        Navigate.SetTracking('', Rec."Lot No.");
                        Navigate.Run;
                    end;
                }
            }
            group(Print)
            {
                Caption = 'Print';
                action("Test Results")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Test Results';
                    Image = CheckRulesSyntax;

                    trigger OnAction()
                    var
                        QCHeader: Record "Quality Control Header";
                    begin
                        // PR1.10.01 Begin
                        QCHeader.SetRange("Item No.", Rec."Item No.");
                        QCHeader.SetRange("Variant Code", Rec."Variant Code");
                        QCHeader.SetRange("Lot No.", Rec."Lot No.");
                        REPORT.RunModal(REPORT::"Quality Control Test Results", true, true, QCHeader); // PR1.10.01
                        // PR1.10.01 End
                    end;
                }
                action("Certificate of Analysis")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Certificate of Analysis';
                    Image = Certificate;

                    trigger OnAction()
                    var
                        LotNoInfo: Record "Lot No. Information";
                    begin
                        // PR1.10.01 Begin
                        LotNoInfo := Rec;
                        LotNoInfo.SetRecFilter;
                        REPORT.RunModal(REPORT::"Certificate of Analysis", true, true, LotNoInfo); // PR1.10.01
                        // PR1.10.01 End
                    end;
                }
            }
        }
        area(reporting)
        {
            action("Item Lots by Expiration Date")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Item Lots by Expiration Date';
                Image = ItemAvailabilitybyPeriod;
                RunObject = Report "Item Lots by Expiration Date";
            }
            action("Item Lot Availability")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Item Lot Availability';
                Image = ItemAvailability;
                RunObject = Report "Item Lot Availability";
            }
        }
        area(Promoted)
        {
            group(Category_Filter)
            {
                Caption = 'Filter';

                actionref(Clear_Promoted; Clear)
                {
                }
                actionref(Set_Promoted; Set)
                {
                }
            }
            group(Category_Lot)
            {
                Caption = 'Lot';

                actionref(Card_Promoted; Card)
                {
                }
                actionref(ItemTrackingEntries_Promoted; "Item &Tracking Entries")
                {
                }
                actionref(QualityControl_Promoted; "Quality Control")
                {
                }
                actionref(LotSpecifications_Promoted; "Lot &Specifications")
                {
                }
                actionref(ItemTracing_Promoted; "&Item Tracing")
                {
                }
                actionref(LotTracing_Promoted; "&Lot Tracing")
                {
                }
                actionref(CreateSubLot_Promoted; CreateSubLot)
                {
                }
            }
            group(Category_FindEntries)
            {
                Caption = 'Find Entries';

                actionref(General_Promoted; General)
                {
                }
                actionref(ItemTracking_Promoted; "Item Tracking")
                {
                }
            }
            group(Category_Reports)
            {
                Caption = 'Reports';

                actionref(TestResults_Promoted; "Test Results")
                {
                }
                actionref(CertificateOfAnalysis_Promoted; "Certificate of Analysis")
                {
                }
                actionref(ItemLotsByExpirationDate_Promoted; "Item Lots by Expiration Date")
                {
                }
                actionref(ItemLotAvailability_Promoted; "Item Lot Availability")
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        // P8000969
        Item.Get(Rec."Item No.");
        SetFreshDateStyleExpr := Item.UseFreshnessDate and (Rec."Freshness Date" < Today); // P8000969
        HideFreshDate := not Item.UseFreshnessDate; // P8007841
        // P8000969
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        LotAgeFilter: Record "Lot Age";
        Direction: Integer;
        EOF: Boolean;
        i: Integer;
    begin
        // P8000664
        for i := 1 to StrLen(Which) do begin
            EOF := false;
            case Which[i] of
                '-', '>':
                    Direction := 1;
                '+', '<':
                    Direction := -1;
                '=':
                    Direction := 0;
            end;
            EOF := not Rec.Find(CopyStr(Which, i, 1));
            while (not EOF) and (not LotFiltering.LotInFilter(Rec, LotAgeFilter, LotSpecFilter, 0, 0D)) do // P8001070
                EOF := Rec.Next(Direction) = 0;
            if not EOF then
                exit(true);
        end;
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        LotAgeFilter: Record "Lot Age";
        NextRec: Record "Lot No. Information";
        Direction: Integer;
        NoSteps: Integer;
        StepsTaken: Integer;
        EOF: Boolean;
    begin
        // P8000664
        NextRec := Rec;
        Direction := 1;
        if Steps < 0 then
            Direction := -1;
        NoSteps := Direction * Steps;
        while (StepsTaken < NoSteps) and (not EOF) do begin
            EOF := Rec.Next(Direction) = 0;
            if (not EOF) and LotFiltering.LotInFilter(Rec, LotAgeFilter, LotSpecFilter, 0, 0D) then begin // P8001070
                NextRec := Rec;
                StepsTaken += 1;
            end;
        end;
        Rec := NextRec;
        exit(Direction * StepsTaken);
    end;

    var
        LotSpecFilter: Record "Lot Specification Filter" temporary;
        LotFiltering: Codeunit "Lot Filtering";
        [InDataSet]
        LotMark: Boolean;
        Item: Record Item;
        [InDataSet]
        SetFreshDateStyleExpr: Boolean;
        [InDataSet]
        HideFreshDate: Boolean;
}
