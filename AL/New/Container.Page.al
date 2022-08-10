page 37002560 Container
{
    // PR3.70.04
    // P8000035B, Myers Nissi, Jack Reynolds, 15 MAY 04
    //   Modify Reprint Labels to to use PrintLabel function on Container Header
    // 
    // P8000042B, Myers Nissi, Jack Reynolds, 20 MAY 04
    //   When reassinging set reassignment flag on container assignment form
    // 
    // PR5.00.01
    // P8000599A, VerticalSoft, Don Bresee, 13 MAY 08
    //   Report Selections - SP1 change to Usage options, P800 option values increased by 12
    // 
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add "Bin Code" and related logic
    // 
    // PRW16.00.02
    // P8000782, VerticalSoft, Rick Tweedle, 01 MAR 10
    //   Upgraded from form version with re-design
    // 
    // PRW16.00.03
    // P8000799, VerticalSoft, Jack Reynolds, 25 MAR 10
    //   Fix incorrect report selection when printing
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW18.00.02
    // P8004230, Columbus IT, Jack Reynolds, 02 OCT 15
    //   Label printing through BIS
    // 
    // P8004266, To-Increase, Jack Reynolds, 06 OCT 15
    //   Split containers
    // 
    // P8004339, To-Increase, Jack Reynolds, 07 OCT 15
    //   Cleanup functions to create new containers
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // P8008464, To-Increase, Dayakar Battini, 28 FEB 17
    //   Product N138 replaced with Distribution Planning
    // 
    // PRW110.0.01
    // P80044498, To-Increase, Dayakar Battini, 19 JUL 17
    //   Fix issue with Loaded control visible property
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // P80049649, To-Increase, Dayakar Battini, 01 DEC 17
    //   TOM Setup read error when not licensed
    // 
    // P80046533, To-Increase, Jack Reynolds, 10 OCT 17
    //   Inbound containers and shipping containers
    // 
    // PRW111.00.01
    // P80056709, To-Increase, Jack Reynolds, 25 JUL 18
    //   Production Containers - assign container to production order
    // 
    // P80062661, To-Increase, Jack Reynolds, 25 JUL 18
    //   SSCC

    Caption = 'Container';
    PageType = Document;
    SourceTable = "Container Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(ID; ID)
                {
                    ApplicationArea = FOODBasic;
                    Editable = (NOT NewContainer) AND (NOT InTransit) AND ("Document Type" = 0);

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update;
                    end;
                }
                field("License Plate"; "License Plate")
                {
                    ApplicationArea = FOODBasic;
                }
                field(SSCC; SSCC)
                {
                    ApplicationArea = FOODBasic;
                    Importance = Additional;
                }
                field(Inbound; Inbound)
                {
                    ApplicationArea = FOODBasic;
                    Editable = (NOT NewContainer) AND (NOT InTransit) AND ("Document Type" = 0);

                    trigger OnValidate()
                    begin
                        SetInbound; // P80046533
                    end;
                }
                field("Container Type Code"; "Container Type Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Document Type" = 0;
                    Importance = Promoted;
                    ShowMandatory = true;

                    trigger OnValidate()
                    var
                        ContainerType: Record "Container Type";
                    begin
                        // P8001323
                        if "Container Type Code" = '' then
                            SerialNoMandatory := false
                        else begin
                            ContainerType.Get("Container Type Code");
                            SerialNoMandatory := ContainerType.IsSerializable;
                        end;
                        // P8001323
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Container Serial No."; "Container Serial No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = SerialNoMandatory;
                    ShowMandatory = SerialNoMandatory;
                }
                field("Creation Date"; "Creation Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = (NOT NewContainer) AND (NOT InTransit);
                    Importance = Promoted;
                    ShowMandatory = LocationMandatory;

                    trigger OnValidate()
                    var
                        Location: Record Location;
                    begin
                        SetLocation; // P80046533
                    end;
                }
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = (NOT (NewContainer AND BinSet)) AND (NOT InTransit);
                    Importance = Promoted;
                    ShowMandatory = BinMandatory;
                }
                field(LotStatus; LotStatus)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Lot Status';
                    Importance = Additional;
                }
                field("DisplayWeight(""Total Net Weight (Base)"")"; DisplayWeight("Total Net Weight (Base)"))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = NetWeightCaptionTxt;
                    Caption = 'Net Weight';
                    DecimalPlaces = 0 : 3;
                }
                field("DisplayWeight(""Container Tare Weight (Base)"" + ""Line Tare Weight (Base)"")"; DisplayWeight("Container Tare Weight (Base)" + "Line Tare Weight (Base)"))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = TareWeightCaptionTxt;
                    Caption = 'Tare Weight';
                    DecimalPlaces = 0 : 3;
                }
                field("DisplayWeight(""Total Net Weight (Base)"" + ""Container Tare Weight (Base)"" + ""Line Tare Weight (Base)"")"; DisplayWeight("Total Net Weight (Base)" + "Container Tare Weight (Base)" + "Line Tare Weight (Base)"))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = GrossWeightCaptionTxt;
                    Caption = 'Gross Weight';
                    DecimalPlaces = 0 : 3;
                }
            }
            group(Assignment)
            {
                Caption = 'Assignment';
                fixed(AssignmentDocuments)
                {
                    ShowCaption = false;
                    group(DocumentType)
                    {
                        Caption = 'Document Type';
                        field(SourceDocumentType; DocumentType())
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Source';
                            Importance = Promoted;
                        }
                        field(WhseDocumentType; Format("Whse. Document Type"))
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Warehouse';
                            Editable = false;
                        }
                        field(DeliveryTripDocumentType; '')
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Delivery Trip';
                        }
                    }
                    group(DocumentNo)
                    {
                        Caption = 'Document No.';
                        field(SourceDocumentNo; "Document No.")
                        {
                            ApplicationArea = FOODBasic;
                            Importance = Promoted;
                        }
                        field(WhseDocumentNo; "Whse. Document No.")
                        {
                            ApplicationArea = FOODBasic;
                            Editable = false;
                        }
                        field(DeliveryTripDocumentNo; GetDeliveryTripNo)
                        {
                            ApplicationArea = FOODBasic;
                        }
                    }
                    group(DocumentLineNo)
                    {
                        Caption = 'Document Line No.';
                        field(SourceDocumentLineNo; "Document Line No.")
                        {
                            ApplicationArea = FOODBasic;
                            BlankZero = true;
                        }
                    }
                }
                field(Loaded; Loaded)
                {
                    ApplicationArea = FOODBasic;
                    Editable = LoadedEditable;
                    Enabled = LoadedEnabled;
                    Visible = LoadedEnabled;
                }
                field(ShipReceive; "Ship/Receive")
                {
                    ApplicationArea = FOODBasic;
                    Editable = NOT WarehouseDocRequired;
                    Enabled = ("Document No." <> '') AND ("Document Type" <> 5407);
                }
            }
            part(Lines; "Container Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lines';
                Enabled = (NOT NewContainer) AND (NOT InTransit);
                SubPageLink = "Container ID" = FIELD(ID);
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Container")
            {
                Caption = '&Container';
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Container Comment List";
                    RunPageLink = Status = CONST(Open),
                                  "Container ID" = FIELD(ID);
                }
            }
        }
        area(processing)
        {
            action("Assign to Order")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Assign to Order';
                Ellipsis = true;
                Enabled = (NOT InTransit) AND ("Whse. Document Type" = 0) AND (NOT "Ship/Receive") AND (NOT "Pending Assignment");
                Image = Apply;
                Promoted = true;
                PromotedCategory = Process;
                Visible = NOT NewContainer;

                trigger OnAction()
                begin
                    // P8001324
                    AssignToOrder;
                    CurrPage.Update(false); // P80056709
                end;
            }
            action(CopyContainer)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Copy Container';
                Ellipsis = true;
                Image = Copy;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    // P80056709
                    ContainersCopied := ContainersCopied or CopyHeader;
                end;
            }
            action("Split Container")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Split Container';
                Ellipsis = true;
                Enabled = (NOT NewContainer) AND (NOT InTransit) AND ("Document Type" = 0);
                Image = Split;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ContainerLine: Record "Container Line";
                    ContainerFns: Codeunit "Container Functions";
                begin
                    // P8004266
                    CurrPage.Lines.PAGE.GetSelectedLines(ContainerLine);
                    ContainerFns.SplitContainer(Rec, ContainerLine);
                end;
            }
            action("Change Lot Status")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Change Lot Status';
                Ellipsis = true;
                Enabled = (NOT NewContainer) AND (NOT InTransit) AND ("Document Type" = 0);
                Image = ChangeStatus;

                trigger OnAction()
                var
                    ContainerHeader: Record "Container Header";
                    LotStatusMgmt: Codeunit "Lot Status Management";
                begin
                    // P8001083
                    ContainerHeader := Rec;
                    ContainerHeader.SetRecFilter;
                    LotStatusMgmt.ChangeLotStatusForContainer(ContainerHeader);
                end;
            }
        }
        area(reporting)
        {
            action(Print)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Print';
                Image = Print;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ContainerHeader: Record "Container Header";
                    ReportSelection: Record "Report Selections";
                begin
                    ContainerHeader := Rec;
                    ContainerHeader.SetRecFilter;
                    ReportSelection.SetRange(Usage, ReportSelection.Usage::FOODContainer); // P8000599A // P8000799
                    if ReportSelection.Find('-') then
                        repeat
                            REPORT.Run(ReportSelection."Report ID", true, false, ContainerHeader);
                        until ReportSelection.Next = 0;
                end;
            }
            action("Reprint Container Label")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Reprint Container Label';
                Ellipsis = true;
                Image = Print;
                Promoted = true;
                PromotedCategory = "Report";

                trigger OnAction()
                var
                    ContainerHeader: Record "Container Header";
                    ReportSelection: Record "Report Selections";
                begin
                    PrintLabel; // P8001322, P8004230
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        CalcFields("Total Net Weight (Base)", "Line Tare Weight (Base)");
    end;

    trigger OnAfterGetRecord()
    var
        ContainerType: Record "Container Type";
        DeliveryTrip: Record "N138 Delivery Trip";
    begin
        if ContainerType.Get("Container Type Code") then
            SerialNoMandatory := ContainerType.IsSerializable;
        SetLocation; // P80046533
        BinSet := "Bin Code" <> ''; // P80046533
        InTransit := ("Document Type" = DATABASE::"Transfer Line") and ("Document Subtype" = 1);
        // P8001379
        if LoadedEnabled then begin
            LoadedEditable := false;
            if GetDeliveryTripNo <> '' then begin
                DeliveryTrip.Get(GetDeliveryTripNo);
                LoadedEditable := DeliveryTrip.Status = DeliveryTrip.Status::Loading;
            end;
        end;
    end;

    trigger OnInit()
    var
        TOMSetup: Record "N138 Transport Mgt. Setup";
    begin
        // P8001379
        // P80044498
        //TOMEnabled := ProcessFns.DistPlanningInstalled;   // P8008464
        //IF TOMEnabled THEN BEGIN
        // P80044498
        if ProcessFns.DistPlanningInstalled then
            if TOMSetup.Get then // P80049649
                if TOMSetup."Use Container Status Loaded" then
                    LoadedEnabled := true;
        //END; // P80044498
        // P8001379
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        Text001: Label 'Already creating a new container.';
    begin
        if NewContainer then
            Error(Text001);
    end;

    trigger OnOpenPage()
    var
        InvSetup: Record "Inventory Setup";
    begin
        NewContainer := CurrPage.LookupMode; // P8004339

        // P8001305
        DisplayWeightUOM := P800UOMFns.DefaultUOM(2);
        DisplayWeightFactor := P800UOMFns.UOMtoMetricBase(DisplayWeightUOM);

        NetWeightCaptionTxt := NetWeightTxt + ' (' + DisplayWeightUOM + ')';
        TareWeightCaptionTxt := TareWeightTxt + ' (' + DisplayWeightUOM + ')';
        GrossWeightCaptionTxt := GrossWeightTxt + ' (' + DisplayWeightUOM + ')';

        // P8001323
        InvSetup.Get;
        LocationMandatory := InvSetup."Location Mandatory";
        // P8001323
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        ContainerHeader: Record "Container Header";
        Item: Record Item;
        ContainerUsage: Record "Container Type Usage";
        ContainerFns: Codeunit "Container Functions";
    begin
        // P8004339
        if CloseAction = ACTION::LookupOK then begin
            CheckHeaderComplete(not Inbound);
            if NewContainerItemNo <> '' then begin
                Item.Get(NewContainerItemNo);
                if not ContainerFns.GetContainerUsage("Container Type Code", Item."No.", Item."Item Category Code", // P8007749
                  NewContainerUOMCode, true, ContainerUsage)
                then
                    Error(Text37002000, Item."No.", "License Plate");
                exit(true);
            end;
        end else
            exit(true);
    end;

    var
        Location: Record Location;
        P800UOMFns: Codeunit "Process 800 UOM Functions";
        NewContainerItemNo: Code[20];
        NewContainerUOMCode: Code[10];
        DisplayWeightUOM: Code[10];
        DisplayWeightFactor: Decimal;
        NetWeightCaptionTxt: Text[80];
        NetWeightTxt: Label 'Net Weight';
        TareWeightTxt: Label 'Tare Weight';
        GrossWeightTxt: Label 'Gross Weight';
        TareWeightCaptionTxt: Text[80];
        GrossWeightCaptionTxt: Text[80];
        Text37002000: Label 'Item %1 is not allowed for container %2';
        [InDataSet]
        InTransit: Boolean;
        [InDataSet]
        LocationMandatory: Boolean;
        [InDataSet]
        BinMandatory: Boolean;
        [InDataSet]
        SerialNoMandatory: Boolean;
        [InDataSet]
        NewContainer: Boolean;
        [InDataSet]
        BinSet: Boolean;
        [InDataSet]
        WarehouseDocRequired: Boolean;
        [InDataSet]
        LoadedEnabled: Boolean;
        [InDataSet]
        LoadedEditable: Boolean;
        ProcessFns: Codeunit "Process 800 Functions";
        ContainersCopied: Boolean;

    procedure DisplayWeight(BaseWeight: Decimal): Decimal
    begin
        exit(BaseWeight / DisplayWeightFactor);
    end;

    procedure NewContainerItem(ItemNo: Code[20]; UOMCode: Code[10])
    begin
        // P8004339 - renamed from RunFromWhseLine
        NewContainerItemNo := ItemNo;
        NewContainerUOMCode := UOMCode;
    end;

    local procedure SetLocation()
    begin
        // P80046533
        if not Location.Get("Location Code") then begin
            Clear(Location);
            BinMandatory := false;
        end else
            BinMandatory := Location."Bin Mandatory";

        SetInbound;
    end;

    local procedure SetInbound()
    begin
        // P80046533
        if Inbound then
            WarehouseDocRequired := Location."Require Receive"
        else
            WarehouseDocRequired := Location."Require Shipment";
    end;

    procedure GetContainersCopied(): Boolean
    begin
        // P80056709
        exit(ContainersCopied);
    end;
}

