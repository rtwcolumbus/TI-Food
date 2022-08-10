table 37002560 "Container Header"
{
    // PR3.61.01
    //   Add logic to delete container transaction records when deleting container
    // 
    // PR3.70.02
    //   Update AssignedTo function to report container at ADC Build A Container Position
    //   Initialize Container Label Code
    // 
    // PR3.70.04
    // P8000035B, Myers Nissi, Jack Reynolds, 15 MAY 04
    //   PrintLabel - function to print lable for current container
    // 
    // PR3.70.07
    // P8000140A, Myers Nissi, Jack Reynolds, 19 NOV 04
    //   Support for serialized containers
    // 
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add "Bin Code" and related logic
    // 
    // PRW16.00
    // P8000639, VerticalSoft, Jack Reynolds, 18 NOV 08
    //   Add DropDown field group
    // 
    // PRW16.00.06
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // P8001123, Columbus IT, Jack Reynolds, 19 DEC 12
    //   Move Item table Label Code fields to Item Label table
    // 
    // PRW17.10
    // P8001246, Columbus IT, Jack Reynolds, 21 NOV 13
    //   Enlarge description fields to 50 characters
    // 
    // PRW18.00.02
    // P8004230, Columbus IT, Jack Reynolds, 02 OCT 15
    //   Label printing through BIS
    // 
    // PRW19.00
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup old delivery trips
    // 
    // P8004516, To-Increase, Jack Reynolds, 17 MAR 16
    //   Incorporate modifications for NAV Anywhere processes
    // 
    // P8008287, To-Increase, Dayakar Battini, 16 DEC 16
    //       Fix Bin Code lenght errors
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 16 JAN 17
    //   Correct misspellings
    // 
    // PRW110.0.01
    // P8007012, To-Increase, Jack Reynolds, 22 MAR 03
    //   Container Management Process
    // 
    // P8008651, To-Increase, Jack Reynolds, 07 APR 17
    //   Fix missing bin in inbound containers for transfer orders
    // 
    // P80039900, To-Increase, Jack Reynolds, 30 May 17
    //   Fix missing bin in inbound containers for transfer orders on warehouse receipts
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // P80050544, To-Increase, Dayakar Battini, 12 FEB 18
    //   Upgrade to 2017 CU13
    // 
    // P80055869, To-Increase, Dayakar Battini, 20 MAR 18
    //   Fix Label Printing User selection Issue
    // 
    // PRW111.00.01
    // P80056709, To-Increase, Jack Reynolds, 25 JUL 18
    //   Production Containers - assign container to production order
    // 
    // P80056710, To-Increase, Jack Reynolds, 25 JUL 18
    //   Production Containers - create production container from pick
    // 
    // P80062661, To-Increase, Jack Reynolds, 25 JUL 18
    //   SSCC
    // 
    // PRW111.00.02
    // P80067767, To-Increase, Gangabhushan, 11 DEC 18
    //   TI-12354 - Container line is missing the bin code after posting a transfer receipt
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    //
    //   PRW11400.01
    //   P80092182, To Increase, Jack Reynolds, 22 JAV 20
    //     New Events

    Caption = 'Container Header';
    DataCaptionFields = ID;
    DrillDownPageID = Containers;
    LookupPageID = Containers;

    fields
    {
        field(1; ID; Code[20])
        {
            Caption = 'ID';

            trigger OnValidate()
            begin
                if ID <> xRec.ID then begin
                    InvSetup.Get;
                    NoSeriesMgt.TestManual(InvSetup."Container IDs");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Container Item No."; Code[20])
        {
            Caption = 'Container Item No.';
            Editable = false;
            TableRelation = Item WHERE("Item Type" = CONST(Container));
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(4; "License Plate"; Code[50])
        {
            Caption = 'License Plate';

            trigger OnValidate()
            var
                ContainerHeader: Record "Container Header";
            begin
                // P8001323
                ContainerHeader.SetFilter(ID, '<>%1', ID);
                ContainerHeader.SetRange("License Plate", "License Plate");
                if not ContainerHeader.IsEmpty then
                    Error(Text008, FieldCaption("License Plate"));
            end;
        }
        field(5; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;

            trigger OnValidate()
            begin
                // P8001323
                if "Location Code" <> xRec."Location Code" then begin
                    if CurrFieldNo = FieldNo("Location Code") then begin
                        if "Document Type" <> 0 then
                            Error(Text010);

                        if LinesExist then
                            Error(Text002, FieldCaption("Location Code"));

                        if (not Inbound) and ("Container Type Code" <> '') then
                            if not ContainerFns.IsContainerAvailable(Rec) then
                                Error(Text004, FieldCaption("Container Type Code"), "Container Type Code");
                    end;

                    "Bin Code" := ''; // P8000631A
                                      // P80039780
                    if Inbound then
                        "Bin Code" := ContainerFns.GetReceivingBin("Location Code");
                    // P80039780
                    UpdateContainerLines(FieldNo("Location Code"), false);
                end;
            end;
        }
        field(8; Comment; Boolean)
        {
            CalcFormula = Exist ("Container Comment Line" WHERE(Status = CONST(Open),
                                                                "Container ID" = FIELD(ID)));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(9; "Container Serial No."; Code[50])
        {
            Caption = 'Container Serial No.';
            TableRelation = "Serial No. Information"."Serial No." WHERE("Item No." = FIELD("Container Item No."));

            trigger OnValidate()
            begin
                // P8001323
                if "Container Serial No." <> xRec."Container Serial No." then begin
                    if LinesExist then
                        Error(Text002, FieldCaption("Container Serial No."));

                    if "Container Serial No." <> '' then begin
                        if "Container Type Code" <> '' then
                            if not ContainerFns.IsContainerAvailable(Rec) then
                                Error(Text004, FieldCaption("Container Type Code"), "Container Type Code");
                    end;

                    // P80055555
                    if "Container Serial No." <> '' then
                        if xRec."License Plate" = xRec.DefaultLicensePlate then
                            Validate("License Plate", DefaultLicensePlate);
                    if "Container Serial No." = '' then
                        if xRec."License Plate" = xRec."Container Serial No." then
                            Validate("License Plate", DefaultLicensePlate);
                    // P80055555

                    SetTareWeight; // P8000140A
                end;
            end;
        }
        field(10; "Creation Date"; Date)
        {
            Caption = 'Creation Date';
            Editable = false;
        }
        field(11; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            Editable = false;
        }
        field(15; "Total Quantity (Base)"; Decimal)
        {
            CalcFormula = Sum ("Container Line"."Quantity (Base)" WHERE("Container ID" = FIELD(ID)));
            Caption = 'Total Quantity (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(16; "Total Net Weight (Base)"; Decimal)
        {
            CalcFormula = Sum ("Container Line"."Weight (Base)" WHERE("Container ID" = FIELD(ID)));
            Caption = 'Total Net Weight (Base)';
            DecimalPlaces = 0 : 9;
            Editable = false;
            FieldClass = FlowField;
        }
        field(17; "Container Tare Weight (Base)"; Decimal)
        {
            Caption = 'Container Tare Weight (Base)';
            DecimalPlaces = 0 : 9;
            Editable = false;
        }
        field(18; "Line Tare Weight (Base)"; Decimal)
        {
            CalcFormula = Sum ("Container Line"."Tare Weight (Base)" WHERE("Container ID" = FIELD(ID)));
            Caption = 'Line Tare Weight (Base)';
            DecimalPlaces = 0 : 9;
            Editable = false;
            FieldClass = FlowField;
        }
        field(19; "Container Type Code"; Code[10])
        {
            Caption = 'Container Type Code';
            TableRelation = "Container Type";

            trigger OnValidate()
            begin
                // P8001323
                if "Container Type Code" <> xRec."Container Type Code" then begin
                    if "Document Type" <> 0 then
                        Error(Text010);

                    if LinesExist then
                        Error(Text002, FieldCaption("Container Type Code"));

                    if "Container Type Code" <> '' then begin
                        if not Inbound then
                            if not ContainerFns.IsContainerAvailable(Rec) then
                                Error(Text004, FieldCaption("Container Type Code"), "Container Type Code");

                        ContainerType.Get("Container Type Code");
                        Description := ContainerType.Description;
                        "Container Item No." := ContainerType."Container Item No.";
                        "Container Serial No." := '';
                        SetTareWeight;
                    end else begin
                        Description := '';
                        "Container Item No." := '';
                        "Container Serial No." := '';
                        "Container Tare Weight (Base)" := 0;
                    end;
                end;
            end;
        }
        field(20; "Document Type"; Integer)
        {
            Caption = 'Document Type';
            Editable = false;
        }
        field(21; "Document Subtype"; Integer)
        {
            Caption = 'Document Subtype';
            Editable = false;
        }
        field(22; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
        }
        field(23; "Document Ref. No."; Integer)
        {
            Caption = 'Document Ref. No.';
            Editable = false;
        }
        field(24; "Pending Assignment"; Boolean)
        {
            Caption = 'Pending Assignment';
        }
        field(25; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            Editable = false;
        }
        field(30; Inbound; Boolean)
        {
            Caption = 'Inbound';

            trigger OnValidate()
            begin
                // P8001323
                if Inbound = xRec.Inbound then
                    exit;

                if "Document Type" <> 0 then
                    Error(Text010);

                if LinesExist then
                    Error(Text002, FieldCaption(Inbound));

                if not Inbound then
                    if not ContainerFns.IsContainerAvailable(Rec) then
                        Error(Text004, FieldCaption("Container Type Code"), "Container Type Code");

                "Bin Code" := '';  // P80039780
                // P80039780
                if Inbound then
                    "Bin Code" := ContainerFns.GetReceivingBin("Location Code");
                // P80039780

                "Document Type" := 0;
                "Document Subtype" := 0;
                "Document No." := '';
                "Document Line No." := 0; // P80056709
                "Document Ref. No." := 0;
                "Whse. Document Type" := 0;
                "Whse. Document No." := '';
                "Transfer-to Bin Code" := '';
                "Ship/Receive" := false;
            end;
        }
        field(31; "Ship/Receive"; Boolean)
        {
            Caption = 'Ship/Receive';

            trigger OnValidate()
            begin
                // P80046533
                if CurrFieldNo = FieldNo("Ship/Receive") then begin
                    Modify;
                    ContainerFns.UpdateContainerShipReceive(Rec, "Ship/Receive", false);
                end;
            end;
        }
        field(40; "Whse. Document Type"; Option)
        {
            Caption = 'Whse. Document Type';
            Description = 'Matches Whse. Document Type on Warehouse Activity Line';
            OptionCaption = ' ,Receipt,Shipment';
            OptionMembers = " ",Receipt,Shipment;
        }
        field(41; "Whse. Document No."; Code[20])
        {
            Caption = 'Whse. Document No.';
        }
        field(100; "Serial Reference"; Integer)
        {
            AutoIncrement = true;
            Caption = 'Serial Reference';
            Editable = false;
        }
        field(101; SSCC; Code[18])
        {
            Caption = 'SSCC';
            Editable = false;
        }
        field(11028580; Loaded; Boolean)
        {
            Caption = 'Loaded';

            trigger OnValidate()
            var
                DeliveryTrip: Record "N138 Delivery Trip";
            begin
                // P8001379
                GetWarehouseShipment;
                if WarehouseShipment."Delivery Trip" = '' then
                    Error(Text100);
                DeliveryTrip.Get(WarehouseShipment."Delivery Trip");
                DeliveryTrip.TestField(Status, DeliveryTrip.Status::Loading);
            end;
        }
        field(37002100; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            Description = 'P8000631A';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));

            trigger OnValidate()
            var
                Bin: Record Bin;
                RegisterMovement: Boolean;
            begin
                // P8001323
                if ("Bin Code" <> '') then begin // P80067767
                    Bin.Get("Location Code", "Bin Code");
                    Bin.CalcFields("Adjustment Bin");
                    Bin.TestField("Adjustment Bin", false);
                    Bin.TestField("Lot Combination Method", Bin."Lot Combination Method"::Manual);

                    if CurrFieldNo = FieldNo("Bin Code") then begin
                        // P80039780
                        if LinesExist then begin
                            if ("Document Type" <> 0) and ("Document Type" <> DATABASE::"Prod. Order Component") then // P80056710
                                Error(Text010);
                            if not Confirm(Text009, false, xRec."Bin Code", "Bin Code") then
                                Error('');
                            RegisterMovement := true;
                        end;
                        // P80039780
                    end else                       // P8004516
                        RegisterMovement := RegMove; // P8004516

                    UpdateContainerLines(FieldNo("Bin Code"), RegisterMovement);
                end;
            end;
        }
        field(37002101; "Transfer-to Bin Code"; Code[20])
        {
            Caption = 'Transfer-to Bin Code';
        }
    }

    keys
    {
        key(Key1; ID)
        {
        }
        key(Key2; "Container Type Code", "Location Code")
        {
        }
        key(Key3; "Container Type Code", "Container Serial No.", "Location Code", "Bin Code")
        {
        }
        key(Key4; "Location Code", "Bin Code")
        {
        }
        key(Key5; "Document Type", "Document Subtype", "Document No.")
        {
        }
        key(Key6; SSCC)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "License Plate", Description)
        {
        }
    }

    trigger OnDelete()
    begin
        ContainerFns.DeleteContainerFromOrder(Rec);
        if Inbound then begin
            Inbound := false;
            Modify;
        end;
        DeleteRelations(false, 0D, '', '', ''); // PR3.60.01, P8000140A, P8001324, P8007012
    end;

    trigger OnInsert()
    begin
        InvSetup.Get;
        if ID = '' then begin
            InvSetup.TestField("Container IDs");
            NoSeriesMgt.InitSeries(InvSetup."Container IDs", xRec."No. Series", WorkDate, ID, "No. Series");
        end;

        InitRecord;
    end;

    trigger OnRename()
    begin
        Error(Text001);
    end;

    var
        InvSetup: Record "Inventory Setup";
        Location: Record Location;
        ContainerType: Record "Container Type";
        SerialNo: Record "Serial No. Information";
        ContainerLine: Record "Container Line";
        ContainerCommentLine: Record "Container Comment Line";
        WarehouseShipment: Record "Warehouse Shipment Header";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Text001: Label 'You cannot rename a container.';
        P800UOMFns: Codeunit "Process 800 UOM Functions";
        Text002: Label '%1 cannot be changed if the container has lines.';
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        Text003: Label '%1 %2 is in use for container %3.';
        Text004: Label '%1 %2 is not available for use.';
        ContainerFns: Codeunit "Container Functions";
        Text005: Label 'Sales %1';
        Text006: Label 'Purchase %1';
        Text007: Label 'Outbound Transfer Order';
        Text008: Label '%1 must be unique.';
        Text009: Label 'Move container from bin %1 to bin %2?';
        Text010: Label 'Container is assigned to an order.';
        Text011: Label 'Inbound Transfer Order';
        Text012: Label 'Container must be assigned to an inbound transfer order.';
        Text013: Label '%1 %2';
        Text014: Label '%1 %2 (Line %3)';
        Text015: Label 'Serialized containers cannot be copied.';
        Text016: Label 'Container %1 created.';
        Text017: Label 'Containers %1 through %2 created.';
        Text018: Label 'Containers assigned to inbound transfers cannot be copied.';
        Text100: Label 'Container must be assigned to a delivery trip.';
        RegMove: Boolean;

    procedure AssistEdit(xContainer: Record "Container Header"): Boolean
    var
        Container: Record "Container Header";
    begin
        // P8001323
        with Container do begin
            Container := Rec;
            InvSetup.Get;
            InvSetup.TestField("Container IDs");
            if NoSeriesMgt.SelectSeries(InvSetup."Container IDs", xContainer."No. Series", "No. Series") then begin
                NoSeriesMgt.SetSeries(ID);
                Rec := Container;
                exit(true);
            end;
        end;
    end;

    procedure InitRecord()
    begin
        "Creation Date" := WorkDate;
        //"License Plate" := ID; // P8001323, P80055555
    end;

    procedure DefaultLicensePlate(): Code[50]
    var
        LicensePlate: Code[50];
        Handled: Boolean;
    begin
        OnBeforeSetDefaultLicensePlate(Rec, LicensePlate, Handled);
        if Handled then
            exit(LicensePlate);

        begin
            // P80055555
            if "Container Serial No." = '' then begin
                if SSCC <> '' then
                    exit('00' + SSCC)
                else
                    exit(ID);
            end else begin
                ContainerType.Get("Container Type Code");
                if (SSCC <> '') and (ContainerType."Default Cont. License Plate" = ContainerType."Default Cont. License Plate"::SSCC) then
                    exit('00' + SSCC)
                else
                    exit("Container Serial No.");
            end;
        end;
    end;

    procedure IsHeaderComplete(): Boolean
    begin
        // P8001323
        if "Container Type Code" = '' then
            exit(false);
        InvSetup.Get;
        if InvSetup."Location Mandatory" and ("Location Code" = '') then
            exit(false);
        Location.Get("Location Code");
        if Location."Bin Mandatory" and ("Bin Code" = '') then
            exit(false);
        ContainerType.Get("Container Type Code");
        if ContainerType.IsSerializable and ("Container Serial No." = '') then
            exit(false);
        if Inbound and ("Document Type" = 0) then
            exit(false);

        exit(true);
    end;

    procedure CheckHeaderComplete(CheckInboundDocument: Boolean)
    begin
        // P8001323
        TestField("Container Type Code");
        InvSetup.Get;
        if InvSetup."Location Mandatory" then
            TestField("Location Code");
        Location.Get("Location Code");
        if Location."Bin Mandatory" then
            TestField("Bin Code");
        ContainerType.Get("Container Type Code");
        if ContainerType.IsSerializable then
            TestField("Container Serial No.");
        if CheckInboundDocument and ("Document Type" = 0) then
            TestField(Inbound, false);
    end;

    procedure MultipleItemsAllowed(): Boolean
    begin
        // P8001323
        exit("Document Type" <> 0);
    end;

    procedure DocumentType(): Text[30]
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
        ProductionOrder: Record "Production Order";
    begin
        // P8001324
        case "Document Type" of
            DATABASE::"Sales Line":
                begin
                    SalesLine."Document Type" := "Document Subtype";
                    exit(StrSubstNo(Text005, SalesLine."Document Type"));
                end;
            DATABASE::"Purchase Line":
                begin
                    PurchLine."Document Type" := "Document Subtype";
                    exit(StrSubstNo(Text006, PurchLine."Document Type"));
                end;
            DATABASE::"Transfer Line":
                if "Document Subtype" = 0 then
                    exit(Text007)
                else
                    exit(Text011);
            // P80056709
            DATABASE::"Prod. Order Component":
                exit(Format(ProductionOrder.TableCaption));
        // P80056709
        end;
    end;

    procedure AssignmentText(): Text
    begin
        // P80056709
        if "Document Line No." = 0 then
            exit(StrSubstNo(Text013, DocumentType, "Document No."))
        else
            exit(StrSubstNo(Text014, DocumentType, "Document No.", "Document Line No."));
    end;

    procedure SourceLineNo(SourceType: Integer; SourceSubType: Integer; SourceLineNo: Integer): Integer
    var
        Location: Record Location;
    begin
        // P80056709
        if SourceType <> DATABASE::"Prod. Order Component" then
            exit;

        if "Location Code" <> '' then
            Location.Get("Location Code");

        if Location."Pick Production by Line" then
            exit(SourceLineNo);
    end;

    procedure AssignToOrder()
    begin
        // P8001324
        ContainerFns.AssignContainer(Rec);
    end;

    procedure LinesExist(): Boolean
    begin
        ContainerLine.Reset;
        ContainerLine.SetRange("Container ID", ID);
        exit(not ContainerLine.IsEmpty); // P8001323
    end;

    procedure UpdateContainerLines(FldNo: Integer; RegisterMovement: Boolean)
    var
        ContainerLine: Record "Container Line";
        Process800CreateWhseAct: Codeunit "Process 800 Create Whse. Act.";
        LinesToMove: Boolean;
    begin
        ContainerLine.SetRange("Container ID", ID);
        OnBeforeUpdateContainerLines(FldNo, RegisterMovement, ContainerLine, Process800CreateWhseAct); // P80092182
        if ContainerLine.Find('-') then begin
            repeat
                case FldNo of
                    // P8000631A
                    FieldNo("Location Code"):
                        begin
                            ContainerLine."Location Code" := "Location Code";
                            ContainerLine."Bin Code" := '';
                        end;
                    FieldNo("Bin Code"):
                        begin
                            if RegisterMovement and (ContainerLine.Quantity > 0) then begin
                                Process800CreateWhseAct.AddToSpecificationBase("Location Code", ContainerLine."Bin Code", "Bin Code",
                                  ContainerLine."Item No.", ContainerLine."Variant Code", ContainerLine."Unit of Measure Code", ContainerLine."Lot No.", ContainerLine."Serial No.",
                                  ContainerLine.Quantity, ContainerLine."Quantity (Base)");
                                LinesToMove := true;
                            end;
                            ContainerLine."Bin Code" := "Bin Code";
                        end;
                // P8000631A
                end;
                ContainerLine.Modify;
            until ContainerLine.Next = 0;

            if RegisterMovement and LinesToMove then begin // P80056710
                Process800CreateWhseAct.SetMoveContainer;    // P80056710
                Process800CreateWhseAct.RegisterMoveFromSpecification;
            end;                                           // P80056710
        end;
        OnAfterUpdateContainerLines(FldNo, RegisterMovement, ContainerLine, Process800CreateWhseAct); // P80092182
    end;

    procedure DeleteRelations(PostUsage: Boolean; Date: Date; DocNo: Code[20]; ExtDocNo: Code[20]; SourceCode: Code[10])
    begin
        // P8000140A - add parameters to trigger posting of usage and usage data
        // P8001324 - remove parameter for DeleteContainerTrans
        // PR3.60.01 Begin
        ContainerLine.SetRange("Container ID", ID);
        // P8000140A Begin
        if ContainerLine.Find('-') then begin
            ContainerLine.SetUsageParms(Date, DocNo, ExtDocNo, SourceCode);
            repeat
                if PostUsage then
                    ContainerLine.PostContainerUse(ContainerLine.Quantity, ContainerLine."Quantity (Alt.)", 0, 0);
                ContainerLine.Delete(true);
            until ContainerLine.Next = 0;
        end;
        // P8000140A End

        ContainerCommentLine.SetRange(Status, ContainerCommentLine.Status::Open);
        ContainerCommentLine.SetRange("Container ID", ID);
        ContainerCommentLine.DeleteAll;
        // PR3.60.01 End
    end;

    procedure GetLabelCode(LabelType: Integer): Code[10]
    var
        ItemLabel: Record "Label Selection";
    begin
        // P8001322
        // LabelType: 2 - Ccontainer
        //            9 - Shipping Container
        //           10 - Production Container
        if ItemLabel.Get(DATABASE::"Container Type", "Container Type Code", LabelType) then
            exit(ItemLabel."Label Code");
    end;

    procedure PrintLabel()
    var
        ContainerType: Record "Container Type";
        ContainerLabel: Record "Container Label";
        ShipProdContainerLabel: Record "Ship/Prod. Container Label";
        LabData: RecordRef;
        LabelMgmt: Codeunit "Label Management";
        LabelCode: Code[10];
    begin
        // P8004230
        if not ContainerType.Get("Container Type Code") then
            exit;

        if ContainerType."No. of Labels" <= 0 then
            exit;

        if "Document Type" = 0 then begin
            LabelCode := GetLabelCode(2);
            if LabelCode <> '' then begin
                ContainerLabel.Validate("Container ID", ID);
                ContainerLabel."No. Of Copies" := ContainerType."No. of Labels";
                LabData.GetTable(ContainerLabel);
            end;
        end else begin
            // P80056709
            if "Document Type" <> DATABASE::"Prod. Order Component" then
                LabelCode := GetLabelCode("Label Type"::ShippingContainer.AsInteger())
            else
                LabelCode := GetLabelCode("Label Type"::ProductionContainer.AsInteger());

            if LabelCode <> '' then begin
                ShipProdContainerLabel.Validate("Container ID", ID);
                ShipProdContainerLabel."No. Of Copies" := ContainerType."No. of Labels";
                LabData.GetTable(ShipProdContainerLabel);
            end;
            // P80056709
        end;
        // LabelMgmt.SetUser(UserId);  // P80055869
        LabelMgmt.PrintLabel(LabelCode, "Location Code", LabData); // P8008451
    end;

    procedure ContainerHasItem(ContainerID: Code[20]; ItemNo: Code[20]; Variant: Code[10]; UOM: Code[10]): Boolean
    var
        ContainerLine: Record "Container Line";
    begin
        with ContainerLine do begin
            SetRange("Container ID", ContainerID);
            SetRange("Item No.", ItemNo);
            SetRange("Variant Code", Variant);
            SetRange("Unit of Measure Code", UOM);
            if Find('-') then
                exit(true)
            else
                exit(false);
        end;
    end;

    procedure ContainerHasSingleItem(ContainerID: Code[20]; ItemNo: Code[20]; Variant: Code[10]; UOM: Code[10]): Boolean
    var
        ContainerLine: Record "Container Line";
    begin
        with ContainerLine do begin
            SetCurrentKey("Container ID");
            SetRange("Container ID", ContainerID);
            SetFilter("Item No.", '<>%1', ItemNo);
            SetRange("Unit of Measure Code", UOM);
            if Find('-') then
                exit(false)
            else begin
                SetRange("Item No.", ItemNo);
                SetFilter("Variant Code", '<>%1', Variant);
                if Find('-') then
                    exit(false)
                else
                    exit(true);
            end;
        end;
    end;

    procedure ContainerQtyIsTooLarge(ContainerID: Code[20]; ItemNo: Code[20]; Variant: Code[10]; UOM: Code[10]; QuantityNeeded: Decimal): Boolean
    var
        ContainerLine: Record "Container Line";
        Qty: Decimal;
    begin
        with ContainerLine do begin
            SetRange("Container ID", ContainerID);
            SetRange("Item No.", ItemNo);
            SetRange("Variant Code", Variant);
            SetRange("Unit of Measure Code", UOM);
            if Find('-') then
                repeat
                    Qty += ContainerLine.Quantity;
                until Next = 0;
        end;
        if Qty > QuantityNeeded then
            exit(true)
        else
            exit(false);
    end;

    procedure SetTareWeight()
    begin
        // P8000140A
        "Container Tare Weight (Base)" := 0;
        ContainerType.Get("Container Type Code");
        if ContainerType.IsSerializable then begin
            if "Container Serial No." <> '' then begin
                SerialNo.Get("Container Item No.", '', "Container Serial No.");
                if SerialNo."Tare Unit of Measure" <> '' then
                    "Container Tare Weight (Base)" := SerialNo."Tare Weight" * P800UOMFns.UOMtoMetricBase(SerialNo."Tare Unit of Measure");
            end;
        end else
            if ContainerType."Tare Unit of Measure" <> '' then
                "Container Tare Weight (Base)" := ContainerType."Tare Weight" * P800UOMFns.UOMtoMetricBase(ContainerType."Tare Unit of Measure");
    end;

    procedure LotStatus() LotStatusCode: Code[10]
    var
        ContainerLine: Record "Container Line";
        P800Globals: Codeunit "Process 800 System Globals";
        LotStatusCode2: Code[10];
    begin
        // P8001083
        ContainerLine.SetRange("Container ID", ID);
        ContainerLine.SetFilter("Lot No.", '<>%1', '');
        if ContainerLine.FindSet then begin
            LotStatusCode := ContainerLine.LotStatus;
            while ContainerLine.Next <> 0 do begin
                LotStatusCode2 := ContainerLine.LotStatus;
                if LotStatusCode <> LotStatusCode2 then
                    exit(P800Globals.MultipleLotCode);
            end;
        end;
    end;

    procedure GetItem(var ItemNo: Code[20]; var ItemDesc: Text[100]): Code[20]
    var
        ContainerLine: Record "Container Line";
    begin
        // P8001323
        ItemNo := '';
        ItemDesc := '';

        ContainerLine.SetRange("Container ID", ID);
        if ContainerLine.FindFirst then begin
            ContainerLine.SetFilter("Item No.", '<>%1', ContainerLine."Item No.");
            if ContainerLine.IsEmpty then begin
                ItemNo := ContainerLine."Item No.";
                ItemDesc := ContainerLine.Description;
            end;
        end;
    end;

    procedure GetTransferToBin(var BinCode: Code[20]): Boolean
    var
        ContLineAppl: Record "Container Line Application";
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        TransLine: Record "Transfer Line";
    begin
        // P8008287 - change BinCode to Code20
        BinCode := "Transfer-to Bin Code";
        if BinCode <> '' then
            exit(true);

        if "Document Type" <> DATABASE::"Transfer Line" then
            exit(false);

        //IF "Document Subtype" = 1 THEN // P8008651
        //  EXIT(TRUE);                  // P8008651

        ContLineAppl.SetRange("Application Table No.", DATABASE::"Transfer Line");
        ContLineAppl.SetRange("Application Subtype", "Document Subtype"); // P8008651
        ContLineAppl.SetRange("Application No.", "Document No.");
        ContLineAppl.SetRange("Container ID", ID);
        if not ContLineAppl.FindFirst then
            exit(false);

        // P80039900
        if "Whse. Document Type" = "Whse. Document Type"::Receipt then begin
            WarehouseReceiptLine.SetRange("No.", "Whse. Document No.");
            WarehouseReceiptLine.SetRange("Source Type", ContLineAppl."Application Table No.");
            WarehouseReceiptLine.SetRange("Source Subtype", ContLineAppl."Application Subtype");
            WarehouseReceiptLine.SetRange("Source No.", ContLineAppl."Application No.");
            WarehouseReceiptLine.SetRange("Source Line No.", ContLineAppl."Application Line No.");
            if not WarehouseReceiptLine.FindFirst then
                exit(false);
            BinCode := WarehouseReceiptLine."Bin Code";
        end else begin
            // P80039900
            TransLine.Get("Document No.", ContLineAppl."Application Line No.");
            BinCode := TransLine."Transfer-To Bin Code";
        end; // P80039900
        exit(true);
    end;

    local procedure GetWarehouseShipment()
    begin
        // P8001379
        if "Whse. Document Type" <> "Whse. Document Type"::Shipment then
            Clear(WarehouseShipment)
        else
            if "Whse. Document No." <> WarehouseShipment."No." then
                WarehouseShipment.Get("Whse. Document No.");
    end;

    procedure GetDeliveryTripNo(): Code[20]
    begin
        // P8001379
        GetWarehouseShipment;
        exit(WarehouseShipment."Delivery Trip");
    end;

    procedure RegisterMovement()
    begin
        // P8004516
        RegMove := true;
    end;

    procedure CopyHeader(): Boolean
    var
        ContainerType: Record "Container Type";
        ContainerHeader: Record "Container Header";
        CopyContainers: Page "Copy Containers";
        NoOfCopies: Integer;
        ContainerLicensePlate: array[2] of Code[50];
    begin
        // P80056709
        CheckHeaderComplete(false);
        if ("Document Type" = DATABASE::"Transfer Line") and ("Document Subtype" = 1) then
            Error(Text018);
        ContainerType.Get("Container Type Code");
        if ContainerType.IsSerializable then
            Error(Text015);

        if CopyContainers.RunModal = ACTION::Cancel then
            exit;
        NoOfCopies := CopyContainers.GetNoOfCopies;
        if NoOfCopies <= 0 then
            exit;

        while NoOfCopies > 0 do begin
            NoOfCopies -= 1;

            ContainerHeader.Init;
            ContainerHeader.ID := '';
            ContainerHeader.Insert(true);
            ContainerHeader.Inbound := Inbound;
            ContainerHeader.Validate("Container Type Code", "Container Type Code");
            if "Location Code" <> '' then
                ContainerHeader.Validate("Location Code", "Location Code");
            if "Bin Code" <> '' then
                ContainerHeader.Validate("Bin Code", "Bin Code");
            ContainerHeader.Modify;
            if (not "Pending Assignment") and ("Document Type" <> 0) then
                ContainerFns.AddContainerToOrder(ContainerHeader.ID, "Document Type", "Document Subtype", "Document No.", "Document Line No.",
                  "Document Ref. No.", "Whse. Document Type", "Whse. Document No.", false);
            if ContainerLicensePlate[1] = '' then
                ContainerLicensePlate[1] := ContainerHeader."License Plate";
            ContainerLicensePlate[2] := ContainerHeader."License Plate";
        end;

        if ContainerLicensePlate[1] = ContainerLicensePlate[2] then
            Message(Text016, ContainerLicensePlate[1])
        else
            Message(Text017, ContainerLicensePlate[1], ContainerLicensePlate[2]);

        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateContainerLines(FldNo: Integer; RegisterMovement: Boolean; var ContainerLine: Record "Container Line"; var Process800CreateWhseAct: Codeunit "Process 800 Create Whse. Act.")
    begin
        // P80092182   
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateContainerLines(FldNo: Integer; RegisterMovement: Boolean; var ContainerLine: Record "Container Line"; var Process800CreateWhseAct: Codeunit "Process 800 Create Whse. Act.")
    begin
        // P80092182   
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetDefaultLicensePlate(ContainerHeader: Record "Container Header"; var LicensePlate: Code[50]; var Handled: Boolean)
    begin
    end;
}

