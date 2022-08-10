page 37002601 "Supply Driven Planning"
{
    // PRW16.00.03
    // P8000793, VerticalSoft, Don Bresee, 17 MAR 10
    //   Redesign interface for NAV 2009
    // 
    // PRW16.00.03
    // P8000817, VerticalSoft, Jack Reynolds, 26 APR 10
    //   Change visible property of fields
    // 
    // PRW16.00.05
    // P8000940, Columbus IT, Jack Reynolds, 07 NOV 11
    //   RemoveTimer control and add Signal control
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001092, Columbus IT, Don Bresee, 17 AUG 12
    //   Add Location and Variant Code
    //   Change page source from the Item table to temp table (Prod. Order Component)
    //   Change subpage linkage for Output and Package subpage
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW18.00.01
    // P8001386, Columbus IT, Jack Reynolds, 27 MAY 15
    //   Renamed NAV Food client addins
    // 
    // PRW111.00
    // P80059471, To Increase, Jack Reynolds, 25 JUN 18
    //   Upgrade signal control for JavaScript
    //   Cleanup TimerUpdate property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // P800101096, To Increase, Gangabhushan, 11 AUG 20
    // Supply driven planning Qty refresh issue
    // Property change to PROCESSING OPTIONS & PACKAGING OPTIONS
    // 
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 28 APR 22
    //   Removing support for Signal Functions codeunit

    ApplicationArea = FOODBasic;
    Caption = 'Supply Driven Planning';
    DataCaptionExpression = GetCaption();
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;
    PromotedActionCategories = 'New,Process,Report,Item,Preview';
    SaveValues = true;
    SourceTable = "Prod. Order Component";
    SourceTableTemporary = true;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(Control37002018)
            {
                Caption = 'Settings';
                //ShowCaption = false;
                field(LocationCode; LocationCode)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Location Code';
                    TableRelation = Location;

                    trigger OnValidate()
                    begin
                        SDPMgmt.ValidateLocation(Rec, LocationCode); // P8001092
                        CurrPage.Update;                            // P8001092
                    end;
                }
                group(Control37002019)
                {
                    ShowCaption = false;
                    field(SupplyDaysView; SupplyDaysView)
                    {
                        ApplicationArea = FOODBasic;
                        BlankZero = true;
                        Caption = 'Supply Days View';

                        trigger OnValidate()
                        begin
                            // P8001092
                            if (SupplyDaysView < 0) then
                                Error(Text000);
                            SDPMgmt.SetSupplyDaysView(SupplyDaysView, SupplyEndDate);
                            CurrPage.Update;
                        end;
                    }
                    field(SupplyEndDate; SupplyEndDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Supply End Date';

                        trigger OnValidate()
                        begin
                            // P8001092
                            if (SupplyEndDate < WorkDate) then
                                Error(Text001, WorkDate);
                            SDPMgmt.SetSupplyEndDate(SupplyEndDate, SupplyDaysView);
                            CurrPage.Update;
                        end;
                    }
                }
                group(Control37002022)
                {
                    ShowCaption = false;
                    field(DemandDaysView; DemandDaysView)
                    {
                        ApplicationArea = FOODBasic;
                        BlankZero = true;
                        Caption = 'Demand Days View';

                        trigger OnValidate()
                        begin
                            // P8001092
                            if (DemandDaysView < 0) then
                                Error(Text000);
                            SDPMgmt.SetDemandDaysView(DemandDaysView, DemandEndDate);
                            CurrPage.Update;
                        end;
                    }
                    field(DemandEndDate; DemandEndDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Demand End Date';

                        trigger OnValidate()
                        begin
                            // P8001092
                            if (DemandEndDate < WorkDate) then
                                Error(Text001, WorkDate);
                            SDPMgmt.SetDemandEndDate(DemandEndDate, DemandDaysView);
                            CurrPage.Update;
                        end;
                    }
                    field(DemandForecastName; DemandForecastName)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Demand Forecast Name';
                        TableRelation = "Production Forecast Name";

                        trigger OnValidate()
                        begin
                            // P8001092
                            SDPMgmt.SetDemandForecastName(DemandForecastName);
                            CurrPage.Update;
                        end;
                    }
                }
            }
            group("Available Raw Materials")
            {
                ShowCaption = false;
                group(Control37002001)
                {
                    Caption = 'Available Raw Materials';
                    repeater(RawMaterials)
                    {
                        FreezeColumn = Description;
                        field("Item No."; "Item No.")
                        {
                            ApplicationArea = FOODBasic;
                            Editable = false;
                            TableRelation = Item WHERE("Item Type" = FILTER("Raw Material" | Intermediate));
                        }
                        field("Variant Code"; "Variant Code")
                        {
                            ApplicationArea = FOODBasic;
                            Editable = false;
                            Visible = false;
                        }
                        field(Description; Description)
                        {
                            ApplicationArea = FOODBasic;
                            Editable = false;
                        }
                        field("Quantity Available"; MaxReqQty)
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Quantity Available';
                            DecimalPlaces = 0 : 5;
                            Editable = false;
                        }
                        field("Unit of Measure Code"; "Unit of Measure Code")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Unit of Measure Code';
                            Editable = false;
                        }
                        field("Quantity to Process"; CurrReqQty)
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Quantity to Process';
                            DecimalPlaces = 0 : 5;
                            Editable = false;
                        }
                    }
                }
                part(Processes; "Supply Driven Process Subform")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'PROCESSING OPTIONS';
                    SubPageLink = "No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code");
                    SubPageView = SORTING(Type, "No.")
                                  WHERE("Prod. BOM Type" = CONST(Process),
                                        "Prod. BOM Output Type" = CONST(Family),
                                        Type = CONST(Item));
                    UpdatePropagation = Both;
                }
            }
            group(Control37002002)
            {
                ShowCaption = false;
                part(Outputs; "Supply Driven Output Subform")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'OUTPUT OPTIONS';
                    Provider = Processes;
                    SubPageLink = "Process BOM No." = FIELD("Production BOM No."),
                                  "Process BOM Line No." = FIELD("Line No.");
                    SubPageView = SORTING("Form Type", "Item No.", "Variant Code", "Location Code", "Process BOM No.", "Process BOM Line No.", "Output Family Line No.", "Package BOM No.", "Package BOM Line No.", "Finished Item No.", "Finished Variant Code");
                }
                part(Package; "Supply Driven Package Subform")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'PACKAGING OPTIONS';
                    Provider = Outputs;
                    SubPageLink = "Process BOM No." = FIELD("Process BOM No."),
                                  "Process BOM Line No." = FIELD("Process BOM Line No."),
                                  "Output Family Line No." = FIELD("Output Family Line No.");
                    SubPageView = SORTING("Package BOM No.", "Finished Item No.", "Finished Variant Code");
                    UpdatePropagation = Both;
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
            group("&Item")
            {
                Caption = '&Item';
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    RunObject = Page "Item Card";
                    RunPageLink = "No." = FIELD("Item No."),
                                  "Variant Filter" = FIELD("Variant Code"),
                                  "Location Filter" = FIELD("Location Code");
                    ShortCutKey = 'Shift+F7';
                }
                action("Ledger E&ntries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Ledger E&ntries';
                    Image = LedgerEntries;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    RunObject = Page "Item Ledger Entries";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code"),
                                  "Location Code" = FIELD("Location Code");
                    RunPageView = SORTING("Item No.");
                    ShortCutKey = 'Ctrl+F7';
                }
                group("&Item Availability by")
                {
                    Caption = '&Item Availability by';
                    action(Period)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Item Availability by Period';
                        Image = Period;
                        Promoted = true;
                        PromotedCategory = Category4;
                        PromotedOnly = true;
                        RunObject = Page "Item Availability by Periods";
                        RunPageLink = "No." = FIELD("Item No."),
                                      "Variant Filter" = FIELD("Variant Code"),
                                      "Location Filter" = FIELD("Location Code");
                    }
                    action(Variant)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Item Availability by Variant';
                        Image = ItemVariant;
                        Promoted = true;
                        PromotedCategory = Category4;
                        PromotedOnly = true;
                        RunObject = Page "Item Availability by Variant";
                        RunPageLink = "No." = FIELD("Item No."),
                                      "Variant Filter" = FIELD("Variant Code"),
                                      "Location Filter" = FIELD("Location Code");
                    }
                    action(Location)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Item Availability by Location';
                        Image = Warehouse;
                        Promoted = true;
                        PromotedCategory = Category4;
                        PromotedOnly = true;
                        RunObject = Page "Item Availability by Location";
                        RunPageLink = "No." = FIELD("Item No."),
                                      "Variant Filter" = FIELD("Variant Code"),
                                      "Location Filter" = FIELD("Location Code");
                    }
                }
            }
            group("P&review")
            {
                Caption = 'P&review';
                action("P&rocess Orders")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'P&rocess Orders';
                    Image = TestReport;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;

                    trigger OnAction()
                    begin
                        ShowProcessOrders;
                    end;
                }
                action("P&ackage Orders")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'P&ackage Orders';
                    Image = "Order";
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;

                    trigger OnAction()
                    begin
                        ShowPackageOrders;
                    end;
                }
            }
        }
        area(processing)
        {
            action("&Reset Quantities")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Reset Quantities';
                Ellipsis = true;
                Image = DeleteQtyToHandle;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    ResetQuantities;
                end;
            }
            action("Create &Orders")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Create &Orders';
                Ellipsis = true;
                Image = CreateDocuments;
                Promoted = true;
                PromotedCategory = New;
                PromotedIsBig = true;
                PromotedOnly = true;
                ShortCutKey = 'F7';

                trigger OnAction()
                var
                    ProcessOrderMgmt2: Codeunit "Process Order Management";
                begin
                    ProcessOrderMgmt2.SetFormType(0);
                    ProcessOrderMgmt2.SetLocationCode(LocationCode); // P8001092
                    ProcessOrderMgmt2.Run;
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        // SDPMgmt.GetMainPageQtys(Rec,CurrReqQty,MaxReqQty);                      // P8001092, P8001132
        SDPMgmt.GetMainPageQtys("Item No.", "Variant Code", CurrReqQty, MaxReqQty);   // P8001092, P8001132
    end;

    trigger OnAfterGetRecord()
    begin
        // SDPMgmt.GetMainPageQtys(Rec,CurrReqQty,MaxReqQty);                      // P8001092
        SDPMgmt.GetMainPageQtys("Item No.", "Variant Code", CurrReqQty, MaxReqQty);   // P8001092
    end;

    trigger OnInit()
    begin
        SDPMgmt.GetDefaultForecastName(DemandForecastName); // P8001092
    end;

    trigger OnOpenPage()
    var
        ProcessFns: Codeunit "Process 800 Functions";
    begin
        // P8001092
        // SETFILTER("Item Type",'%1|%2',"Item Type"::Intermediate,"Item Type"::"Raw Material");
        // SETFILTER(Inventory,'>0');
        SDPMgmt.SetLocation(Rec, LocationCode);
        SDPMgmt.SetSupplyDaysView(SupplyDaysView, SupplyEndDate);
        SDPMgmt.SetDemandDaysView(DemandDaysView, DemandEndDate);
        SDPMgmt.SetDemandForecastName(DemandForecastName);
        // P8001092

        CurrPage.Processes.PAGE.SetSDPMgmt(SDPMgmt);
        CurrPage.Outputs.PAGE.SetSDPMgmt(SDPMgmt);
        CurrPage.Package.PAGE.SetSDPMgmt(SDPMgmt);
    end;

    var
        Text000: Label 'Days View must be a positive integer.';
        Text001: Label 'End Date must be after %1.';
        Text005: Label 'Do you want to remove all current order quantities?';
        SDPMgmt: Codeunit "Supply Driven Planning Mgmt.";
        CurrReqQty: Decimal;
        MaxReqQty: Decimal;
        LocationCode: Code[10];
        SupplyDaysView: Integer;
        SupplyEndDate: Date;
        DemandDaysView: Integer;
        DemandEndDate: Date;
        DemandForecastName: Code[10];

    local procedure ShowProcessOrders()
    var
        ProcessReqLine: Record "Process Order Request Line";
    begin
        ProcessReqLine.FilterGroup(4);
        ProcessReqLine.SetRange("Form Type", ProcessReqLine."Form Type"::Supply);
        ProcessReqLine.SetRange("Location Code", LocationCode); // P8001092
        ProcessReqLine.FilterGroup(0);
        PAGE.RunModal(PAGE::"Process Order Preview", ProcessReqLine);
        CurrPage.Update(false);
    end;

    local procedure ShowPackageOrders()
    var
        PackageReqLine: Record "Process Order Request Line";
    begin
        PackageReqLine.FilterGroup(4);
        PackageReqLine.SetRange("Form Type", PackageReqLine."Form Type"::Supply);
        PackageReqLine.SetRange("Location Code", LocationCode); // P8001092
        PackageReqLine.FilterGroup(0);
        PAGE.RunModal(PAGE::"Package Order Preview", PackageReqLine);
        CurrPage.Update(false);
    end;

    local procedure ResetQuantities()
    var
        RequestLine: Record "Process Order Request Line";
    begin
        RequestLine.SetRange("Form Type", RequestLine."Form Type"::Supply);
        RequestLine.SetRange("Location Code", LocationCode); // P8001092
        if not RequestLine.Find('-') then
            exit;
        if not Confirm(Text005) then
            exit;
        RequestLine.DeleteAll;
        CurrPage.Update(false);
    end;

    local procedure GetCaption(): Text[250]
    begin
        // P8001092
        // IF (Description <> '') THEN
        //   EXIT(STRSUBSTNO('%1 %2', "No.", Description));
        // EXIT("No.");
        if (Description <> '') then
            exit(StrSubstNo('%1 %2', "Item No.", Description));
        exit("Item No.");
        // P8001092
    end;
}

