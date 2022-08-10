page 37002095 "Lot Reservations"
{
    // There is a weird bug when using a source expression for a menu item (Use Lot Preferences) that if the focus is
    // on the subform when the menu button is clicked the system seems to evaluate then menu items source expression
    // in the environment of the subform.  In this case where the source expression is the first variable defined the
    // system uses the first variable defined on the subform.  Therefore some effort has been made to maintain the
    // value of this variable in the subform.  It is important that UseLotPref is the first variable defined on this
    // form as well as the subform.
    // 
    // PR3.70.08
    // P8000165A, Myers Nissi, Jack Reynolds, 13 FEB 05
    //   Form displaying demand for an item with subform showing available lots
    // 
    // PR4.00
    // P8000251A, Myers Nissi, Jack Reynolds, 20 OCT 05
    //   Increase width to handle wider subform
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
    // P8001070, Columbus IT, Jack Reynolds, 07 JAN 13
    //   Support for Lot Freshness
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.00.01
    // P8001163, Columbus IT, Jack Reynolds, 30 MAY 13
    //   Fix problem with editing sub-pages
    // 
    // P8001166, Columbus IT, Jack Reynolds, 30 MAY 13
    //   Fix problem displaying reserved quantities

    Caption = 'Lot Reservations';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Worksheet;
    SourceTable = "Item Demand";
    SourceTableView = SORTING("Date Required");

    layout
    {
        area(content)
        {
            group(Control37002000)
            {
                ShowCaption = false;
                field(ItemNo; ItemNo)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item No.';
                    Editable = false;
                }
                field("Item.Description"; Item.Description)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Description';
                    Editable = false;
                }
                field(VariantCode; VariantCode)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Variant Code';
                    Editable = false;
                }
                field("VariantRec.Description"; VariantRec.Description)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Variant Description';
                    Editable = false;
                }
                field(LocationCode; LocationCode)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Location Code';
                    Editable = false;
                }
                field("Location.Name"; Location.Name)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Location Name';
                    Editable = false;
                }
                field(BegDate; BegDate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Date - from';
                    Editable = false;
                }
                field(EndDate; EndDate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'to';
                    Editable = false;
                }
            }
            repeater(Control37002002)
            {
                Editable = false;
                ShowCaption = false;
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Date Required"; "Date Required")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity (Base)"; "Quantity (Base)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Reserved Quantity"; "Reserved Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Reserved Quantity (Base)"; "Reserved Quantity (Base)")
                {
                    ApplicationArea = FOODBasic;
                }
                field(LotAgePrefText; LotAgePrefText)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Age Preference';
                }
                field(LotSpecPrefText; LotSpecPrefText)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Specification Preference';
                }
                field("Oldest Accept. Freshness Date"; "Oldest Accept. Freshness Date")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            part(Lots; "Lot Reservations Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Available Lots';
            }
            field(UseLotPref; UseLotPref)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Use Lot Preferences';

                trigger OnValidate()
                var
                    LotAgePref: Record "Lot Age Filter";
                    LotSpecPref: Record "Lot Specification Filter" temporary;
                begin
                    // P8000664
                    CurrPage.Lots.PAGE.SetUseLotPref(UseLotPref);
                    if UseLotPref then
                        GetLotPreferences(LotAgePref, LotSpecPref);
                    CurrPage.Lots.PAGE.SetFilters(ItemNo, VariantCode, LocationCode, Rec, LotAgePref, LotSpecPref);
                end;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("O&rder")
            {
                Caption = 'O&rder';
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;
                    ShortCutKey = 'Shift+F7';

                    trigger OnAction()
                    var
                        SalesHeader: Record "Sales Header";
                        ProductionOrder: Record "Production Order";
                        TransferHeader: Record "Transfer Header";
                        SalesOrder: Page "Sales Order";
                        ReleasedProdOrder: Page "Released Production Order";
                        TransferOrder: Page "Transfer Order";
                    begin
                        case Type of
                            Type::Sales:
                                begin
                                    SalesHeader.SetRange("Document Type", "Source Subtype");
                                    SalesHeader.SetRange("No.", "Document No.");
                                    SalesOrder.SetTableView(SalesHeader);
                                    SalesOrder.RunModal;
                                end;
                            Type::Production:
                                begin
                                    ProductionOrder.SetRange(Status, "Source Subtype");
                                    ProductionOrder.SetRange("No.", "Document No.");
                                    ReleasedProdOrder.SetTableView(ProductionOrder);
                                    ReleasedProdOrder.RunModal;
                                end;
                            Type::Transfer:
                                begin
                                    TransferHeader.SetRange("No.", "Document No.");
                                    TransferOrder.SetTableView(TransferHeader);
                                    TransferOrder.RunModal;
                                end;
                        end;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        LotAgePref: Record "Lot Age Filter";
        LotSpecPref: Record "Lot Specification Filter" temporary;
        LotFiltering: Codeunit "Lot Filtering";
    begin
        // P8001132
        CurrPage.Lots.PAGE.SetFilters(ItemNo, VariantCode, LocationCode, Rec, LotAgePref, LotSpecPref);
        GetLotPreferences(LotAgePref, LotSpecPref);
        LotAgePrefText := LotFiltering.LotAgeText(LotAgePref);
        LotSpecPrefText := LotFiltering.LotSpecText(LotSpecPref);
    end;

    trigger OnAfterGetRecord()
    begin
        CalcFields("Reserved Quantity", "Reserved Quantity (Base)"); // P8001166
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        ItemDemand := Rec;
        if not ItemDemand.Find(Which) then
            exit(false);
        Rec := ItemDemand;
        exit(true);
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        CurrentSteps: Integer;
    begin
        ItemDemand := Rec;
        CurrentSteps := ItemDemand.Next(Steps);
        if CurrentSteps <> 0 then
            Rec := ItemDemand;
        exit(CurrentSteps);
    end;

    trigger OnOpenPage()
    begin
        UseLotPref := true;
        CurrPage.Lots.PAGE.SetUseLotPref(UseLotPref);
    end;

    var
        UseLotPref: Boolean;
        Item: Record Item;
        VariantRec: Record Variant;
        Location: Record Location;
        ItemDemand: Record "Item Demand" temporary;
        ItemNo: Code[20];
        VariantCode: Code[10];
        LocationCode: Code[10];
        BegDate: Date;
        EndDate: Date;
        LotAgePrefText: Text[1024];
        LotSpecPrefText: Text[1024];

    procedure SetParameters(ItmNo: Code[20]; LocCode: Code[10]; VarCode: Code[10]; BDate: Date; EDate: Date): Boolean
    begin
        ItemNo := ItmNo;
        Item.Get(ItemNo);
        VariantCode := VarCode;
        if VariantCode <> '' then
            VariantRec.Get(VariantCode);
        LocationCode := LocCode;
        if LocationCode <> '' then
            Location.Get(LocationCode);
        BegDate := BDate;
        EndDate := EDate;

        GetItemDemand;
        exit(true);
    end;

    procedure GetItemDemand()
    var
        SalesLine: Record "Sales Line";
        ProdOrderComp: Record "Prod. Order Component";
        TransLine: Record "Transfer Line";
        EndDate2: Date;
    begin
        ItemDemand.Reset;
        ItemDemand.DeleteAll;

        if EndDate = 0D then
            EndDate2 := DMY2Date(31, 12, 9999) // P8007748
        else
            EndDate2 := EndDate;

        SalesLine.SetCurrentKey("Document Type", Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Shipment Date");
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetRange("No.", ItemNo);
        SalesLine.SetRange("Variant Code", VariantCode);
        SalesLine.SetRange("Drop Shipment", false);
        SalesLine.SetRange("Shipment Date", BegDate, EndDate2);
        SalesLine.SetFilter("Outstanding Quantity", '<>0');
        if SalesLine.Find('-') then
            repeat
                ItemDemand.Init;
                ItemDemand.Type := ItemDemand.Type::Sales;
                ItemDemand."Source Table" := DATABASE::"Sales Line";
                ItemDemand."Source Subtype" := SalesLine."Document Type";
                ItemDemand."Document No." := SalesLine."Document No.";
                ItemDemand."Prod. Order Line No." := 0;
                ItemDemand."Line No." := SalesLine."Line No.";
                ItemDemand."Date Required" := SalesLine."Shipment Date";
                ItemDemand.Quantity := SalesLine."Outstanding Quantity";
                ItemDemand."Unit of Measure Code" := SalesLine."Unit of Measure Code";
                ItemDemand."Qty. per Unit of Measure" := SalesLine."Qty. per Unit of Measure";
                ItemDemand."Quantity (Base)" := SalesLine."Outstanding Qty. (Base)";
                ItemDemand."Freshness Calc. Method" := SalesLine."Freshness Calc. Method";              // P8001070
                ItemDemand."Oldest Accept. Freshness Date" := SalesLine."Oldest Accept. Freshness Date"; // P8001070
                ItemDemand.Insert;
            until SalesLine.Next = 0;

        ProdOrderComp.SetCurrentKey("Item No.", "Variant Code", "Location Code", Status, "Due Date");
        ProdOrderComp.SetRange("Item No.", ItemNo);
        ProdOrderComp.SetRange("Variant Code", VariantCode);
        ProdOrderComp.SetRange("Location Code", LocationCode);
        ProdOrderComp.SetRange(Status, ProdOrderComp.Status::Released);
        ProdOrderComp.SetRange("Due Date", BegDate, EndDate2);
        if ProdOrderComp.Find('-') then
            repeat
                ItemDemand.Init;
                ItemDemand.Type := ItemDemand.Type::Production;
                ItemDemand."Source Table" := DATABASE::"Prod. Order Component";
                ItemDemand."Source Subtype" := ProdOrderComp.Status;
                ItemDemand."Document No." := ProdOrderComp."Prod. Order No.";
                ItemDemand."Prod. Order Line No." := ProdOrderComp."Prod. Order Line No.";
                ItemDemand."Line No." := ProdOrderComp."Line No.";
                ItemDemand."Date Required" := ProdOrderComp."Due Date";
                ItemDemand.Quantity := ProdOrderComp."Remaining Quantity";
                ItemDemand."Unit of Measure Code" := ProdOrderComp."Unit of Measure Code";
                ItemDemand."Qty. per Unit of Measure" := ProdOrderComp."Qty. per Unit of Measure";
                ItemDemand."Quantity (Base)" := ProdOrderComp."Remaining Qty. (Base)";
                ItemDemand.Insert;
            until ProdOrderComp.Next = 0;

        TransLine.SetCurrentKey("Item No.");
        TransLine.SetRange("Item No.", ItemNo);
        TransLine.SetRange("Variant Code", VariantCode);
        TransLine.SetRange("Transfer-from Code", LocationCode);
        TransLine.SetRange("Shipment Date", BegDate, EndDate2);
        if TransLine.Find('-') then
            repeat
                ItemDemand.Init;
                ItemDemand.Type := ItemDemand.Type::Transfer;
                ItemDemand."Source Table" := DATABASE::"Transfer Line";
                ItemDemand."Source Subtype" := 0;
                ItemDemand."Document No." := TransLine."Document No.";
                ItemDemand."Prod. Order Line No." := 0;
                ItemDemand."Line No." := TransLine."Line No.";
                ItemDemand."Date Required" := TransLine."Shipment Date";
                ItemDemand.Quantity := TransLine."Outstanding Quantity";
                ItemDemand."Unit of Measure Code" := TransLine."Unit of Measure Code";
                ItemDemand."Qty. per Unit of Measure" := TransLine."Qty. per Unit of Measure";
                ItemDemand."Quantity (Base)" := TransLine."Outstanding Qty. (Base)";
                ItemDemand.Insert;
            until TransLine.Next = 0;

        ItemDemand.SetCurrentKey("Date Required");
    end;
}

