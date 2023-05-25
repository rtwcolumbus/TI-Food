page 37002094 "Item Lot Reservations"
{
    // PR3.70.08
    // P8000165A, Myers Nissi, Jack Reynolds, 11 FEB 05
    //   Item list showing demand (sales, transfers, produciton) and reservations with ability to launch lot reservation form
    // 
    // PR4.00
    //  RENAMED from Item Reservations
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Don Bresee, 12 JUN 07
    //   Change "Var" to VariantRec
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 16 APR 09
    //   Transformed - additions in TIF Editor
    //   Page changes made after transformation
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 19 FEB 13
    //   Restoring the SaveValues Property.
    // 
    // PRW17.00.01
    // P8001166, Columbus IT, Jack Reynolds, 30 MAY 13
    //   Fix problem restoring flow filters
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Item Lot Reservations';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = Item;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(Filters)
            {
                Caption = 'Filters';
                field(DateFilter; DateFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Date Filter';

                    trigger OnValidate()
                    var
                        FilterTokens: Codeunit "Filter Tokens";
                    begin
                        // P8000664
                        FilterTokens.MakeDateFilter(DateFilter); // P80066030, P800-MegaApp
                        SetFilter("Date Filter", DateFilter);
                        DateFilter := GetFilter("Date Filter");
                        CurrPage.Update(false);
                    end;
                }
                field(LocationFilter; LocationFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Location Filter';
                    TableRelation = Location;

                    trigger OnValidate()
                    begin
                        // P8000664
                        SetFilter("Location Filter", LocationFilter);
                        LocationFilter := GetFilter("Location Filter");
                        CurrPage.Update(false);
                    end;
                }
                field(VariantFilter; VariantFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Variant Filter';
                    TableRelation = Variant;

                    trigger OnValidate()
                    begin
                        // P8000664
                        SetFilter("Variant Filter", VariantFilter);
                        VariantFilter := GetFilter("Variant Filter");
                        CurrPage.Update(false);
                    end;
                }
                field(UnreservedOnly; UnreservedOnly)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Only show items with unreserved demand';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }
            }
            repeater(Control37002002)
            {
                Editable = false;
                ShowCaption = false;
                field(UnresDemand; UnresDemand)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Unreserved Demand';
                }
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Base Unit of Measure"; "Base Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item Category Code"; "Item Category Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item Tracking Code"; "Item Tracking Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(QtyOnSalesOrder; QtyOnSalesOrder)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Qty. on Sales Orders';
                    DecimalPlaces = 0 : 5;

                    trigger OnDrillDown()
                    begin
                        DrillDown('QtyOnSalesOrder');
                    end;
                }
                field(ResQtyOnSalesOrder; ResQtyOnSalesOrder)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Reserved for Sales Orders';
                    DecimalPlaces = 0 : 5;

                    trigger OnDrillDown()
                    begin
                        DrillDown('ResQtyOnSalesOrder');
                    end;
                }
                field(QtyOnTransOrder; QtyOnTransOrder)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Qty. on Trans. Orders';
                    DecimalPlaces = 0 : 5;

                    trigger OnDrillDown()
                    begin
                        DrillDown('QtyOnTransOrder');
                    end;
                }
                field(ResQtyOnTransOrder; ResQtyOnTransOrder)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Reserved for Trans. Orders';
                    DecimalPlaces = 0 : 5;

                    trigger OnDrillDown()
                    begin
                        DrillDown('ResQtyOnTransOrder');
                    end;
                }
                field(QtyOnProdOrder; QtyOnProdOrder)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Qty. on Prod. Orders';
                    DecimalPlaces = 0 : 5;

                    trigger OnDrillDown()
                    begin
                        DrillDown('QtyOnProdOrder');
                    end;
                }
                field(ResQtyOnProdOrder; ResQtyOnProdOrder)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Reserved for Prod. Orders';
                    DecimalPlaces = 0 : 5;

                    trigger OnDrillDown()
                    begin
                        DrillDown('ResQtyOnProdOrder');
                    end;
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
                    RunObject = Page "Item Card";
                    RunPageLink = "No." = FIELD("No."),
                                  "Date Filter" = FIELD("Date Filter"),
                                  "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                  "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                                  "Location Filter" = FIELD("Location Filter"),
                                  "Drop Shipment Filter" = FIELD("Drop Shipment Filter");
                    ShortCutKey = 'Shift+F7';
                }
                action("Lot Availability")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Lot Availability';
                    Image = Lot;
                    RunObject = Page "Item Lot Availability";
                    RunPageLink = "Item No." = FIELD("No.");
                }
            }
        }
        area(processing)
        {
            action("&Lot Reservations")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Lot Reservations';
                Image = ItemReservation;

                trigger OnAction()
                var
                    Location: Record Location;
                    VariantRec: Record Variant;
                    LotReservations: Page "Lot Reservations";
                    BegDate: Date;
                    EndDate: Date;
                    DateFilter: Text[1024];
                begin
                    // P8000466A - Change "Var" to VariantRec
                    DateFilter := GetFilter("Date Filter");
                    if DateFilter <> '' then begin
                        if CopyStr(DateFilter, 1, 2) = '..' then
                            BegDate := 0D
                        else
                            BegDate := GetRangeMin("Date Filter");
                        if CopyStr(DateFilter, StrLen(DateFilter) - 1, 2) = '..' then
                            EndDate := 0D
                        else
                            EndDate := GetRangeMax("Date Filter");
                    end;

                    if GetFilter("Location Filter") <> '' then begin
                        CopyFilter("Location Filter", Location.Code);
                        if Location.Count <> 1 then
                            Error(Text001, FieldCaption("Location Filter"), Location.TableCaption);
                        Location.Find('-');
                    end;

                    if GetFilter("Variant Filter") <> '' then begin
                        CopyFilter("Variant Filter", VariantRec.Code);
                        if VariantRec.Count <> 1 then
                            Error(Text001, FieldCaption("Variant Filter"), VariantRec.TableCaption);
                        VariantRec.Find('-');
                    end;

                    LotReservations.SetParameters("No.", Location.Code, VariantRec.Code, BegDate, EndDate);
                    LotReservations.RunModal;

                    xNo := '';
                    CalculateQuantities;
                end;
            }
        }
        area(Promoted)
        {
                actionref(LotReservations_Promoted; "&Lot Reservations")
                {
                }
                actionref(LotAvailability_Promoted; "Lot Availability")
                {
                }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CalculateQuantities;
        if UnreservedDemand(Rec) then
            UnresDemand := true   // P8000664
        else
            UnresDemand := false; // P8000664
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        Direction: Integer;
        EOF: Boolean;
        i: Integer;
    begin
        if not UnreservedOnly then
            exit(Find(Which));

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
            EOF := not Find(CopyStr(Which, i, 1));
            while (not EOF) and (not ShowRecord(Rec)) do
                EOF := Next(Direction) = 0;
            if not EOF then
                exit(true);
        end;
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        NextRec: Record Item;
        Direction: Integer;
        NoSteps: Integer;
        StepsTaken: Integer;
        EOF: Boolean;
    begin
        if not UnreservedOnly then
            exit(Next(Steps));

        NextRec := Rec;
        Direction := 1;
        if Steps < 0 then
            Direction := -1;
        NoSteps := Direction * Steps;
        while (StepsTaken < NoSteps) and (not EOF) do begin
            EOF := Next(Direction) = 0;
            if (not EOF) and ShowRecord(Rec) then begin
                NextRec := Rec;
                StepsTaken += 1;
            end;
        end;
        Rec := NextRec;
        exit(Direction * StepsTaken);
    end;

    trigger OnOpenPage()
    begin
        // P8001166
        SetFilter("Date Filter", DateFilter);
        SetFilter("Location Filter", LocationFilter);
        SetFilter("Variant Filter", VariantFilter);
        // P8001166
    end;

    var
        UnreservedOnly: Boolean;
        Text001: Label 'The %1 must specify a single %2.';
        [InDataSet]
        UnresDemand: Boolean;
        VariantFilter: Code[30];
        LocationFilter: Code[30];
        DateFilter: Text[30];
        xNo: Code[20];
        xVarFilter: Text[250];
        xLocFilter: Text[250];
        xDateFilter: Text[250];
        QtyOnSalesOrder: Decimal;
        ResQtyOnSalesOrder: Decimal;
        QtyOnTransOrder: Decimal;
        ResQtyOnTransOrder: Decimal;
        QtyOnProdOrder: Decimal;
        ResQtyOnProdOrder: Decimal;

    procedure UnreservedDemand(var Item: Record Item): Boolean
    begin
        CalculateQuantities;
        exit((QtyOnSalesOrder <> ResQtyOnSalesOrder) or
          (QtyOnTransOrder <> ResQtyOnTransOrder) or
          (QtyOnProdOrder <> ResQtyOnProdOrder));
    end;

    procedure ShowRecord(var Item: Record Item): Boolean
    begin
        if UnreservedOnly then
            exit(UnreservedDemand(Rec))
        else
            exit(true);
    end;

    procedure CalculateQuantities()
    var
        ProdOrderComp: Record "Prod. Order Component";
        ResEntry: Record "Reservation Entry";
        VarFilter: Text[250];
        LocFilter: Text[250];
        DateFilter: Text[250];
    begin
        VarFilter := GetFilter("Variant Filter");
        LocFilter := GetFilter("Location Filter");
        DateFilter := GetFilter("Date Filter");

        if ("No." <> xNo) or (VarFilter <> xVarFilter) or (LocFilter <> xLocFilter) or (DateFilter <> xDateFilter) then begin
            xNo := "No.";
            xVarFilter := VarFilter;
            xLocFilter := LocFilter;
            xDateFilter := DateFilter;

            CalcFields("Qty. on Sales Order", "Reserved Qty. on Sales Orders",
              "Trans. Ord. Shipment (Qty.)", "Res. Qty. on Outbound Transfer");

            QtyOnSalesOrder := "Qty. on Sales Order";
            ResQtyOnSalesOrder := "Reserved Qty. on Sales Orders";
            QtyOnTransOrder := "Trans. Ord. Shipment (Qty.)";
            ResQtyOnTransOrder := "Res. Qty. on Outbound Transfer";

            FilterProdOrderComp(ProdOrderComp, VarFilter, LocFilter, DateFilter);
            ProdOrderComp.CalcSums("Remaining Qty. (Base)");
            QtyOnProdOrder := ProdOrderComp."Remaining Qty. (Base)";

            FilterResEntry(ResEntry, VarFilter, LocFilter, DateFilter, DATABASE::"Prod. Order Component", ProdOrderComp.Status::Released);
            ResEntry.CalcSums("Quantity (Base)");
            ResQtyOnProdOrder := -ResEntry."Quantity (Base)";
        end;
    end;

    procedure DrillDown(DataElement: Text[30])
    var
        SalesLine: Record "Sales Line";
        TransLine: Record "Transfer Line";
        ProdOrderComp: Record "Prod. Order Component";
        ResEntry: Record "Reservation Entry";
    begin
        case DataElement of
            'QtyOnSalesOrder':
                begin
                    FilterSalesLine(SalesLine, GetFilter("Variant Filter"), GetFilter("Location Filter"), GetFilter("Date Filter"));
                    PAGE.RunModal(0, SalesLine);
                end;
            'ResQtyOnSalesOrder':
                begin
                    FilterResEntry(ResEntry, GetFilter("Variant Filter"), GetFilter("Location Filter"), GetFilter("Date Filter"),
                      DATABASE::"Sales Line", SalesLine."Document Type"::Order);
                    PAGE.RunModal(0, ResEntry);
                end;
            'QtyOnTransOrder':
                begin
                    FilterTransLine(TransLine, GetFilter("Variant Filter"), GetFilter("Location Filter"), GetFilter("Date Filter"));
                    PAGE.RunModal(0, TransLine);
                end;
            'ResQtyOnTransOrder':
                begin
                    FilterResEntry(ResEntry, GetFilter("Variant Filter"), GetFilter("Location Filter"), GetFilter("Date Filter"),
                      DATABASE::"Transfer Line", 0);
                    PAGE.RunModal(0, ResEntry);
                end;
            'QtyOnProdOrder':
                begin
                    FilterProdOrderComp(ProdOrderComp, GetFilter("Variant Filter"), GetFilter("Location Filter"), GetFilter("Date Filter"));
                    PAGE.RunModal(0, ProdOrderComp);
                end;
            'ResQtyOnProdOrder':
                begin
                    FilterResEntry(ResEntry, GetFilter("Variant Filter"), GetFilter("Location Filter"), GetFilter("Date Filter"),
                      DATABASE::"Prod. Order Component", ProdOrderComp.Status::Released);
                    PAGE.RunModal(0, ResEntry);
                end;
        end;
    end;

    procedure FilterSalesLine(var SalesLine: Record "Sales Line"; VarFilter: Text[250]; LocFilter: Text[250]; DateFilter: Text[250])
    begin
        SalesLine.SetCurrentKey("Document Type", Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Shipment Date");
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetRange("No.", "No.");
        SalesLine.SetRange("Drop Shipment", false);
        if VarFilter <> '' then
            SalesLine.SetFilter("Variant Code", VarFilter);
        if LocFilter <> '' then
            SalesLine.SetFilter("Location Code", LocFilter);
        if DateFilter <> '' then
            SalesLine.SetFilter("Shipment Date", DateFilter);
    end;

    procedure FilterProdOrderComp(var ProdOrderComp: Record "Prod. Order Component"; VarFilter: Text[250]; LocFilter: Text[250]; DateFilter: Text[250])
    begin
        ProdOrderComp.SetCurrentKey(Status, "Item No.", "Variant Code", "Location Code", "Due Date");
        ProdOrderComp.SetRange(Status, ProdOrderComp.Status::Released);
        ProdOrderComp.SetRange("Item No.", "No.");
        if VarFilter <> '' then
            ProdOrderComp.SetFilter("Variant Code", VarFilter);
        if LocFilter <> '' then
            ProdOrderComp.SetFilter("Location Code", LocFilter);
        if DateFilter <> '' then
            ProdOrderComp.SetFilter("Due Date", DateFilter);
    end;

    procedure FilterTransLine(TransLine: Record "Transfer Line"; VarFilter: Text[250]; LocFilter: Text[250]; DateFilter: Text[250])
    begin
        TransLine.SetCurrentKey("Transfer-from Code", Status, "Derived From Line No.", "Item No.", "Variant Code",
          "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Shipment Date");
        TransLine.SetRange("Derived From Line No.", 0);
        TransLine.SetRange("Item No.", "No.");
        if VarFilter <> '' then
            TransLine.SetFilter("Variant Code", VarFilter);
        if LocFilter <> '' then
            TransLine.SetFilter("Transfer-from Code", LocFilter);
        if DateFilter <> '' then
            TransLine.SetFilter("Shipment Date", DateFilter);
    end;

    procedure FilterResEntry(var ResEntry: Record "Reservation Entry"; VarFilter: Text[250]; LocFilter: Text[250]; DateFilter: Text[250]; SourceType: Integer; SourceSubtype: Integer)
    begin
        ResEntry.SetCurrentKey("Reservation Status", "Item No.", "Variant Code", "Location Code",
          "Source Type", "Source Subtype", "Shipment Date");
        ResEntry.SetRange("Reservation Status", ResEntry."Reservation Status"::Reservation);
        ResEntry.SetRange("Item No.", "No.");
        if VarFilter <> '' then
            ResEntry.SetFilter("Variant Code", VarFilter);
        if LocFilter <> '' then
            ResEntry.SetFilter("Location Code", LocFilter);
        ResEntry.SetRange("Source Type", SourceType);
        ResEntry.SetRange("Source Subtype", SourceSubtype);
        if DateFilter <> '' then
            ResEntry.SetFilter("Shipment Date", DateFilter);
    end;
}

