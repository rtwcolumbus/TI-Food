page 37002761 "Bin Status"
{
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 08 AUG 06
    //   List form of bins with functions to manage the bin contents
    // 
    // PR5.00
    // P8000494A, VerticalSoft, Don Bresee, 18 JUL 07
    //   Add Production Bins/Replenishment
    // 
    // P8000495A, VerticalSoft, Don Bresee, 18 JUL 07
    //   Add Combining of Lots
    // 
    // PRW15.00.03
    // P8000632A, VerticalSoft, Don Bresee, 18 SEP 08
    //   Fix to Move, Units functions to allow access in 1 document locations
    // 
    // PRW16.00.02
    // P8000777, VerticalSoft, Don Bresee, 01 MAR 10
    //   Changed VISIBLE so it could be handled by the form transformation tool
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001034, Columbus IT, Jack Reynolds, 10 FEB 12
    //   Change codeunit for Warehouse Employee functions
    // 
    // PRW17.00
    // P8001142, Columbus IT, Don Bresee, 09 MAR 13
    //   Rework Replenishment logic
    // 
    // PRW17.10.03
    // P8001337, Columbus IT, Dayakar Battini, 06 Aug 14
    //    Container Visibilty with Bin Status.
    // 
    // PRW18.00.02
    // P8004229, to-Increase, Jack Reynolds, 02 Oct 15
    //    Add loose quantity
    // 
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.01
    // P80059471, To Increase, Jack Reynolds, 25 JUN 18
    //   Cleanup TimerUpdate references
    // 
    // P80061239, To Increase, Jack Reynolds, 31 JUL 18
    //   Run Bin Status from warehouse document pages
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    ApplicationArea = FOODBasic;
    Caption = 'Bin Status';
    DataCaptionExpression = GetFormCaption(Rec);
    PageType = Worksheet;
    SourceTable = "Bin Content";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(Filters)
            {
                Caption = 'Filters';
                field(LocCodeCtrl; UserLocCode)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Location Code';
                    Editable = LocCodeCtrlEditable;
                    TableRelation = Location;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(P800CoreFns.LookupEmpLocation(Text)); // P8001034
                    end;

                    trigger OnValidate()
                    begin
                        P800CoreFns.ValidateEmpLocation(UserLocCode); // P8001034
                        SetLocation(UserLocCode);
                        UserLocCodeOnAfterValidate;
                    end;
                }
                field(ItemNoCtrl; ItemNoFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item No.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Item: Record Item;
                    begin
                        if (Text <> '') then begin
                            Item.SetFilter("No.", Text);
                            if Item.Find('-') then;
                            Item.SetRange("No.");
                        end;
                        if (PAGE.RunModal(0, Item) = ACTION::LookupOK) then begin
                            Text := Item."No.";
                            exit(true);
                        end;
                        exit(false);
                    end;

                    trigger OnValidate()
                    var
                        Item: Record Item;
                    begin
                        SetUserFilters;
                        if (ItemNoFilter <> '') then
                            if not FindFirst then
                                Item.Get(ItemNoFilter);
                        ItemNoFilterOnAfterValidate;
                    end;
                }
                field(BinCodeCtrl; UserBinCode)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Bin Code';
                    Editable = BinCodeCtrlEditable;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Bin: Record Bin;
                    begin
                        if (LocationCode <> '') then begin
                            Bin.SetRange("Location Code", LocationCode);
                            if (Text <> '') then begin
                                Bin.SetFilter(Code, Text);
                                if Bin.Find('-') then;
                                Bin.SetRange(Code);
                            end;
                            if (PAGE.RunModal(0, Bin) = ACTION::LookupOK) then begin
                                Text := Bin.Code;
                                exit(true);
                            end;
                        end;
                        exit(false);
                    end;

                    trigger OnValidate()
                    var
                        Bin: Record Bin;
                    begin
                        if (UserBinCode <> '') then
                            Bin.Get(LocationCode, UserBinCode);
                        UserBinCodeOnAfterValidate;
                    end;
                }
                field(LotNoCtrl; LotNoFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Lot No. Filter';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        LotNoInfo: Record "Lot No. Information";
                    begin
                        LotNoInfo.SetRange("Location Filter", LocationCode);
                        if (ItemNoFilter <> '') then
                            LotNoInfo.SetFilter("Item No.", ItemNoFilter);
                        if (Text <> '') then begin
                            LotNoInfo.SetFilter("Lot No.", Text);
                            if LotNoInfo.Find('-') then;
                            LotNoInfo.SetRange("Lot No.");
                        end;
                        if (PAGE.RunModal(PAGE::Lots, LotNoInfo) = ACTION::LookupOK) then begin
                            Text := LotNoInfo."Lot No.";
                            exit(true);
                        end;
                        exit(false);
                    end;

                    trigger OnValidate()
                    begin
                        LotNoFilterOnAfterValidate;
                    end;
                }
            }
            repeater(Control37002001)
            {
                Editable = false;
                ShowCaption = false;
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = LocationCodeVisible;
                }
                field("Zone Code"; "Zone Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Bin Type Code"; "Bin Type Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = BinCodeVisible;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
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
                field("GetItemDescription(Rec)"; GetItemDescription(Rec))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Description';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Remaining Quantity"; "Remaining Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity in Container"; "Quantity in Container")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("""Remaining Quantity"" - ""Quantity in Container"""; "Remaining Quantity" - "Quantity in Container")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Loose Quantity';
                    DecimalPlaces = 0 : 5;
                    Visible = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Remaining Qty. (Base)"; "Remaining Qty. (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Qty. in Container (Base)"; "Qty. in Container (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("""Remaining Qty. (Base)"" - ""Qty. in Container (Base)"""; "Remaining Qty. (Base)" - "Qty. in Container (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Loose Qty. (Base)';
                    DecimalPlaces = 0 : 5;
                    Visible = false;
                }
                field("Allocated Container Count"; "Allocated Container Count")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Allocated Container Qty."; "Allocated Container Qty.")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                }
                field(PutAwayNo; BinWhseActNo(Rec, WhseAction::Take))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Outbound Doc. No.';
                    Editable = false;
                    Visible = PutAwayNoVisible;

                    trigger OnDrillDown()
                    begin
                        BinWhseActNoDrillDown(Rec, WhseAction::Take);
                        CurrPage.Update(false);
                    end;
                }
                field(PutAwayQty; BinWhseActQty(Rec, WhseAction::Take))
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Outbound Qty.';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    Visible = PutAwayQtyVisible;

                    trigger OnDrillDown()
                    begin
                        BinWhseActQtyDrillDown(Rec, WhseAction::Take);
                        CurrPage.Update(false);
                    end;
                }
                field(PickNo; BinWhseActNo(Rec, WhseAction::Place))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Inbound Doc. No.';
                    Editable = false;
                    Visible = PickNoVisible;

                    trigger OnDrillDown()
                    begin
                        BinWhseActNoDrillDown(Rec, WhseAction::Place);
                        CurrPage.Update(false);
                    end;
                }
                field(PickQty; BinWhseActQty(Rec, WhseAction::Place))
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Inbound Qty.';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    Visible = PickQtyVisible;

                    trigger OnDrillDown()
                    begin
                        BinWhseActQtyDrillDown(Rec, WhseAction::Place);
                        CurrPage.Update(false);
                    end;
                }
            }
        }
        area(factboxes)
        {
            part(Lots; "Lot Numbers by Bin and UOM FB")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lots';
                SubPageLink = "Item No." = FIELD("Item No."),
                              "Variant Code" = FIELD("Variant Code"),
                              "Location Code" = FIELD("Location Code"),
                              "Bin Code" = FIELD("Bin Code"),
                              "Unit of Measure Code" = FIELD("Unit of Measure Code");
            }
            part(Control1000000000; "Containers by Bin FactBox")
            {
                AccessByPermission = TableData "Container Header" = R; // FactBoxVisibility
                ApplicationArea = FOODBasic;
                SubPageLink = "Item No." = FIELD("Item No."),
                              "Variant Code" = FIELD("Variant Code"),
                              "Location Code" = FIELD("Location Code"),
                              "Bin Code" = FIELD("Bin Code"),
                              "Unit of Measure Code" = FIELD("Unit of Measure Code"),
                              "Lot No." = FIELD("Lot No. Filter");
                Visible = true; // FactBoxVisibility
            }
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
        area(processing)
        {
            action(LotButton)
            {
                ApplicationArea = FOODBasic;
                Caption = '&Lots';
                Ellipsis = true;
                Enabled = LotButtonEnable;
                Image = Lot;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    BinContent2: Record "Bin Content";
                    CombineWhseLotForm: Page "Combine Warehouse Lots";
                begin
                    // P8000495A
                    Clear(CombineWhseLotForm);   // P8001337
                    if (FormMode in [FormMode::Shipping, FormMode::Receiving]) then
                        exit;
                    GetLocation("Location Code");
                    if not Location."Bin Mandatory" then // P8000632A
                        exit;
                    CurrPage.SetSelectionFilter(BinContent2);
                    if BinContent2.Find('=><') then begin
                        CopyFilter("Lot No. Filter", BinContent2."Lot No. Filter");
                        CopyFilter("Serial No. Filter", BinContent2."Serial No. Filter");
                        CombineWhseLotForm.SetBinContents(BinContent2);
                        CombineWhseLotForm.RunModal;
                    end;
                end;
            }
            action(BreakButton)
            {
                ApplicationArea = FOODBasic;
                Caption = '&Units';
                Ellipsis = true;
                Enabled = BreakButtonEnable;
                Image = UnitOfMeasure;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    BinContent2: Record "Bin Content";
                    ConvertWhseUOMForm: Page "Convert Warehouse Units";
                begin
                    if (FormMode in [FormMode::Shipping, FormMode::Receiving]) then
                        exit;
                    GetLocation("Location Code");
                    if not Location."Bin Mandatory" then // P8000632A
                        exit;
                    CurrPage.SetSelectionFilter(BinContent2);
                    if BinContent2.Find('=><') then begin
                        CopyFilter("Lot No. Filter", BinContent2."Lot No. Filter");
                        CopyFilter("Serial No. Filter", BinContent2."Serial No. Filter");
                        ConvertWhseUOMForm.SetLocation("Location Code");
                        ConvertWhseUOMForm.SetBinContents(BinContent2);
                        ConvertWhseUOMForm.RunModal;
                    end;
                end;
            }
            action(MoveButton)
            {
                ApplicationArea = FOODBasic;
                Caption = '&Move';
                Ellipsis = true;
                Enabled = MoveButtonEnable;
                Image = CreateMovement;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    BinContent2: Record "Bin Content";
                    BuildWhseActForm: Page "Build Warehouse Activity";
                begin
                    if (FormMode in [FormMode::Shipping, FormMode::Receiving]) then
                        exit;
                    GetLocation("Location Code");
                    if not Location."Bin Mandatory" then // P8000632A
                        exit;
                    CurrPage.SetSelectionFilter(BinContent2);
                    if BinContent2.Find('=><') then begin
                        CopyFilter("Lot No. Filter", BinContent2."Lot No. Filter");
                        CopyFilter("Serial No. Filter", BinContent2."Serial No. Filter");
                        BuildWhseActForm.SetLocation("Location Code");
                        BuildWhseActForm.SetBinContents(BinContent2);
                        BuildWhseActForm.RunModal;
                    end;
                end;
            }
            action("Reset Filters")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Reset Filters';
                Image = ClearFilter;
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;

                trigger OnAction()
                begin
                    ItemNoFilter := '';
                    LotNoFilter := '';

                    ResetLocation;
                    FormUpdate;
                end;
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        UpdateFilters;

        exit(FormFind(Which));
    end;

    trigger OnInit()
    begin
        LotButtonEnable := true;
        BreakButtonEnable := true;
        MoveButtonEnable := true;
        LocCodeCtrlEditable := true;
        BinCodeCtrlEditable := true;
        PickQtyVisible := true;
        PickNoVisible := true;
        PutAwayQtyVisible := true;
        PutAwayNoVisible := true;
        BinCodeVisible := true;
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        exit(FormNext(Rec, Steps));
    end;

    trigger OnOpenPage()
    begin
        // P8000777 - Change Syntax
        BinCodeVisible := not SingleBinMode();
        BinCodeCtrlEditable := not SingleBinMode();
        LocationCodeVisible := not SingleBinMode();
        LocCodeCtrlEditable := not SingleBinMode();
        // P8000777

        if (FormMode in [FormMode::Shipping, FormMode::Receiving]) then begin
            MoveButtonEnable := false;
            BreakButtonEnable := false;
            LotButtonEnable := false; // P8000494A
        end;

        // P8000777 - Change Syntax
        PutAwayNoVisible := ShowOutboundFields();
        PutAwayQtyVisible := ShowOutboundFields();

        PickNoVisible := ShowInboundFields();
        PickQtyVisible := ShowInboundFields();
        // P8000777

        // P80061239
        if GetFilter("Bin Code") <> '' then
            InitialBinCode := GetFilter("Bin Code");
        if GetFilter("Item No.") <> '' then
            ItemNoFilter := GetFilter("Item No.");
        // P80061239

        ResetLocation;

        SetDisableValidation(true);
    end;

    var
        P800CoreFns: Codeunit "Process 800 Core Functions";
        AllergenManagement: Codeunit "Allergen Management";
        UserLocCode: Code[10];
        UserBinCode: Code[20];
        LocationCode: Code[10];
        BinCode: Code[20];
        ItemNoFilter: Code[250];
        LotNoFilter: Code[250];
        Location: Record Location;
        WhseSetup: Record "Warehouse Setup";
        Text000: Label '%1 Bin %2';
        Text001: Label 'Nothing to Put-Away.';
        BlankBinContent: Record "Bin Content";
        WhseAction: Option " ",Take,Place;
        FormMode: Option " ",Shipping,Receiving,"Production Input","Production Output";
        InitialLocationCode: Code[10];
        InitialBinCode: Code[20];
        P800WhseActCreate: Codeunit "Process 800 Create Whse. Act.";
        ProdOrderLine: Record "Prod. Order Line";
        [InDataSet]
        BinCodeVisible: Boolean;
        [InDataSet]
        LocationCodeVisible: Boolean;
        [InDataSet]
        PutAwayNoVisible: Boolean;
        [InDataSet]
        PutAwayQtyVisible: Boolean;
        [InDataSet]
        PickNoVisible: Boolean;
        [InDataSet]
        PickQtyVisible: Boolean;
        [InDataSet]
        BinCodeCtrlEditable: Boolean;
        [InDataSet]
        LocCodeCtrlEditable: Boolean;
        [InDataSet]
        MoveButtonEnable: Boolean;
        [InDataSet]
        BreakButtonEnable: Boolean;
        [InDataSet]
        LotButtonEnable: Boolean;

    local procedure GetFormCaption(var BinContent: Record "Bin Content"): Text[80]
    begin
        if GetLocation(LocationCode) then
            case FormMode of
                FormMode::Shipping, FormMode::Receiving:
                    exit(Format(FormMode));
                FormMode::"Production Input":
                    begin
                        UpdateInbProdBin; // P8000494A
                        exit(StrSubstNo(Text000, FormMode, Location."To-Production Bin Code"));
                    end;
                FormMode::"Production Output":
                    begin
                        UpdateOutbProdBin; // P8000494A
                        exit(StrSubstNo(Text000, FormMode, Location."From-Production Bin Code"));
                    end;
            end;
    end;

    local procedure FormFind(Which: Text[1024]): Boolean
    var
        SearchRec: Record "Bin Content";
    begin
        SearchRec.Copy(Rec);
        if not SearchRec.Find(Which) then
            exit(false);
        if not InFormRecSet(SearchRec) then
            if (FormNext(SearchRec, 1) = 0) then
                if (FormNext(SearchRec, -1) = 0) then
                    exit(false);
        Rec := SearchRec;
        exit(true);
    end;

    local procedure FormNext(var SearchRec: Record "Bin Content"; Steps: Integer): Integer
    var
        NumRecs: Integer;
        Direction: Integer;
        SearchRec2: Record "Bin Content";
    begin
        if (Steps > 0) then begin
            NumRecs := Steps;
            Direction := 1;
        end else begin
            NumRecs := -Steps;
            Direction := -1;
        end;
        SearchRec2.Copy(SearchRec);
        while (NumRecs > 0) do begin
            if (SearchRec2.Next(Direction) = 0) then
                exit(Steps - NumRecs * Direction);
            if InFormRecSet(SearchRec2) then begin
                SearchRec := SearchRec2;
                NumRecs := NumRecs - 1;
            end;
        end;
        exit(Steps - NumRecs * Direction);
    end;

    local procedure InFormRecSet(var SearchRec: Record "Bin Content"): Boolean
    begin
        with SearchRec do begin
            CalcFields(Quantity, "Pick Qty.", "Put-away Qty.");
            exit((Quantity <> 0) or ("Pick Qty." <> 0) or ("Put-away Qty." <> 0));
        end;
    end;

    local procedure GetItemDescription(var BinContent: Record "Bin Content"): Text[100]
    var
        Item: Record Item;
    begin
        with BinContent do
            if ("Item No." <> '') then
                if Item.Get("Item No.") then
                    exit(Item.Description);
    end;

    local procedure FormUpdate()
    begin
        Rec := BlankBinContent;
        CurrPage.Update(false);
    end;

    procedure SetInitialLocation(NewInitialLocationCode: Code[20])
    begin
        InitialLocationCode := NewInitialLocationCode;
    end;

    procedure SetMode(NewFormMode: Integer)
    begin
        FormMode := NewFormMode;
    end;

    local procedure ShowInboundFields(): Boolean
    begin
        exit(FormMode in [0, FormMode::Shipping, FormMode::"Production Input"]);
    end;

    local procedure ShowOutboundFields(): Boolean
    begin
        exit(FormMode in [0, FormMode::Receiving, FormMode::"Production Output"]);
    end;

    local procedure SingleBinMode(): Boolean
    begin
        exit(FormMode in [FormMode::"Production Input", FormMode::"Production Output"]);
    end;

    local procedure GetSingleBin(): Code[20]
    begin
        case FormMode of
            FormMode::"Production Input":
                begin
                    UpdateInbProdBin; // P8000494A
                    Location.TestField("To-Production Bin Code");
                    exit(Location."To-Production Bin Code");
                end;
            FormMode::"Production Output":
                begin
                    UpdateOutbProdBin; // P8000494A
                    Location.TestField("From-Production Bin Code");
                    exit(Location."From-Production Bin Code");
                end;
        end;
    end;

    local procedure GetLocation(LocationCode: Code[10]): Boolean
    begin
        with Location do begin
            if Get(LocationCode) then
                exit(true);
            Clear(Location);
            WhseSetup.Get;
            "Require Pick" := WhseSetup."Require Pick";
            "Require Put-away" := WhseSetup."Require Put-away";
            exit(false);
        end;
    end;

    local procedure SetLocation(LocationCode2: Code[10])
    begin
        if (LocationCode2 <> LocationCode) then begin
            if SingleBinMode() then begin
                Location.Get(LocationCode2);
                GetSingleBin;
                SetRange("Bin Code");
            end;
            if (LocationCode2 <> '') then begin
                Location.Get(LocationCode2);
                Location.TestField("Bin Mandatory", true);
            end;

            LocationCode := LocationCode2;
            UserLocCode := LocationCode;
            FilterGroup(2);
            if (LocationCode = '') then
                SetFilter("Location Code", P800CoreFns.GetEmpLocationFilter) // P8001034
            else
                SetRange("Location Code", LocationCode);
            case FormMode of
                FormMode::Shipping:
                    SetRange("Ship Bin", true);
                FormMode::Receiving:
                    SetRange("Receive Bin", true);
                else
                    if SingleBinMode() then
                        SetBin(GetSingleBin());
            end;
            FilterGroup(0);

            if not SingleBinMode() then
                SetBin('');
            SetUserFilters;
        end;
    end;

    local procedure ResetLocation()
    begin
        LocationCode := '*';
        if (InitialLocationCode = '') then
            SetLocation(P800CoreFns.GetDefaultEmpLocation) // P801034
        else
            SetLocation(InitialLocationCode);
    end;

    local procedure SetBin(BinCode2: Code[20])
    begin
        // P80061239
        if InitialBinCode <> '' then begin
            BinCode2 := InitialBinCode;
            InitialBinCode := '';
        end;
        // P80061239
        if (BinCode2 = '') then
            SetRange("Bin Code")
        else
            SetRange("Bin Code", BinCode2);
        BinCode := BinCode2;
        UserBinCode := BinCode;
    end;

    local procedure SetUserFilters()
    begin
        if (ItemNoFilter = '') then
            SetRange("Item No.")
        else
            SetFilter("Item No.", ItemNoFilter);
        if (LotNoFilter = '') then
            SetRange("Lot No. Filter")
        else
            SetFilter("Lot No. Filter", LotNoFilter);
    end;

    local procedure UpdateFilters()
    begin
        if not SingleBinMode() then begin
            BinCode := GetFilter("Bin Code");
            UserBinCode := BinCode;
        end;
        ItemNoFilter := GetFilter("Item No.");
        LotNoFilter := GetFilter("Lot No. Filter");
    end;

    local procedure GetFirstBinWhseActLine(var BinContent: Record "Bin Content"; var WhseActivityLine: Record "Warehouse Activity Line"; ActionType: Integer): Boolean
    begin
        GetLocation(BinContent."Location Code");
        if not (Location."Require Pick" or Location."Require Put-away") then
            exit(false);

        with WhseActivityLine do begin
            SetCurrentKey(
              "Item No.", "Bin Code", "Location Code", "Action Type",
              "Variant Code", "Unit of Measure Code");
            SetRange("Item No.", BinContent."Item No.");
            SetRange("Bin Code", BinContent."Bin Code");
            SetRange("Location Code", BinContent."Location Code");
            SetRange("Action Type", ActionType);
            SetRange("Variant Code", BinContent."Variant Code");
            SetRange("Unit of Measure Code", BinContent."Unit of Measure Code");
            BinContent.CopyFilter("Lot No. Filter", "Lot No.");
            BinContent.CopyFilter("Serial No. Filter", "Serial No.");
            exit(Find('-'));
        end;
    end;

    local procedure BinWhseActNo(var BinContent: Record "Bin Content"; ActionType: Integer): Code[20]
    var
        WhseActivityLine: Record "Warehouse Activity Line";
    begin
        if GetFirstBinWhseActLine(BinContent, WhseActivityLine, ActionType) then
            exit(WhseActivityLine."No.");
    end;

    local procedure BinWhseActNoDrillDown(var BinContent: Record "Bin Content"; ActionType: Integer)
    var
        WhseActivityLine: Record "Warehouse Activity Line";
        WhseActivityHdr: Record "Warehouse Activity Header";
        BinContent2: Record "Bin Content";
    begin
        if GetFirstBinWhseActLine(BinContent, WhseActivityLine, ActionType) then begin
            WhseActivityHdr.Get(WhseActivityLine."Activity Type", WhseActivityLine."No.");
            P800WhseActCreate.ShowWhseActHeader(WhseActivityHdr);
        end;
    end;

    local procedure BinWhseActQty(var BinContent: Record "Bin Content"; ActionType: Integer): Decimal
    var
        WhseActivityLine: Record "Warehouse Activity Line";
    begin
        if not GetFirstBinWhseActLine(BinContent, WhseActivityLine, ActionType) then
            exit(0);
        with WhseActivityLine do begin
            CalcSums("Qty. Outstanding");
            exit("Qty. Outstanding");
        end;
    end;

    local procedure BinWhseActQtyDrillDown(var BinContent: Record "Bin Content"; ActionType: Integer)
    var
        WhseActivityLine: Record "Warehouse Activity Line";
    begin
        GetFirstBinWhseActLine(BinContent, WhseActivityLine, ActionType);
        PAGE.RunModal(0, WhseActivityLine);
    end;

    procedure SetProdOrderLine(NewProdOrderLine: Record "Prod. Order Line")
    begin
        ProdOrderLine := NewProdOrderLine; // P8000494A
    end;

    local procedure UpdateOutbProdBin()
    begin
        // P8000494A
        with ProdOrderLine do
            if ("Line No." <> 0) then
                Location.SetFromProductionBin("Prod. Order No.", "Line No."); // P8001142
    end;

    local procedure UpdateInbProdBin()
    var
        ProdOrderComp: Record "Prod. Order Component";
    begin
        // P8000494A
        with ProdOrderLine do
            if ("Line No." <> 0) then begin
                ProdOrderComp.SetRange(Status, Status);
                ProdOrderComp.SetRange("Prod. Order No.", "Prod. Order No.");
                if ProdOrderComp.FindFirst then
                    Location.SetToProductionBin("Prod. Order No.", "Line No.", ProdOrderComp."Line No."); // P8001142
            end;
    end;

    local procedure UserLocCodeOnAfterValidate()
    begin
        FormUpdate;
    end;

    local procedure UserBinCodeOnAfterValidate()
    begin
        SetBin(UserBinCode);
        FormUpdate;
    end;

    local procedure LotNoFilterOnAfterValidate()
    begin
        SetUserFilters;
        FormUpdate;
    end;

    local procedure ItemNoFilterOnAfterValidate()
    begin
        FormUpdate;
    end;
}

