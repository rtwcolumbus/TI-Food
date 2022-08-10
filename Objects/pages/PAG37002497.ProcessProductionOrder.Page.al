page 37002497 "Process Production Order"
{
    // PR1.20
    //   Create Process Orders
    // 
    // PR2.00
    //   Text Constants
    //   Dimensions
    //   Item Tracking
    // 
    // PR3.10
    //   New Production Order table
    // 
    // PR3.60
    //   Change call to CreateProcesOrder to pass Process BOM No.
    //   Round output quantity based on item rounding precision
    // 
    // PR3.70.03
    //   Modified OK button OnPush trigger
    //    to use new GetUOMRndgPrecision function
    //    item."Rounding precision" will reflect UOM specific Rounding Precision if available
    // 
    // PR4.00.04
    // P8000369A, VerticalSoft, Jack Reynolds, 30 AUG 06
    //   Remove shortcut dimension table relations
    // 
    // PRW15.00.01
    // P8000570A, VerticalSoft, Jack Reynolds, 14 FEB 08
    //   Change option string for OrderStatus to replace Simulated and Planned by nulls
    // 
    // PRW16.00.02
    // P8000787, VerticalSoft, MMAS, 05 MAR 10 Page creation
    //   Changed: controls grouping, promote actions
    // 
    // PRW16.00.03
    // P8000785, VerticalSoft, Rick Tweedle, 10 MAR 10
    //   Added Code to make OK button work as per OK Action
    // 
    // PRW16.00.04
    // P8000897, VerticalSoft, Jack Reynolds, 22 JAN 11
    //   Fix spelling mistake
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // P8001149, Columbus IT, Don Bresee, 25 APR 13
    //   Change calling of page to use lookup mode
    // 
    // PRW17.10.01
    // P8001258, Columbus IT, Jack Reynolds, 10 JAN 14
    //   Increase size ot text fields/variables
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds 17 NOV 13
    //   Lookup of Shortcut Dimensions
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 08 MAR 16
    //   Expand BOM Version code to Code20
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 26 APR 22
    //   Upgrade to 20.0 - Refactoring for default dimensions

    Caption = 'Process Production Order';
    PageType = Card;

    layout
    {
        area(content)
        {
            group(Input)
            {
                Caption = 'Input';
                group(Control37002005)
                {
                    ShowCaption = false;
                    field(InputItem; InputItem)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Item No.';
                        TableRelation = Item;

                        trigger OnValidate()
                        begin
                            ValidateItemLot;
                            ValidateItemProcess;
                        end;
                    }
                    field(InputLot; InputLot)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Lot No.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            LotNoInfo: Record "Lot No. Information";
                            Lots: Page Lots;
                        begin
                            if InputItem <> '' then
                                LotNoInfo.SetRange("Item No.", InputItem);
                            LotNoInfo.SetRange(Posted, true);
                            LotNoInfo.SetFilter(Inventory, '>0');
                            Lots.SetTableView(LotNoInfo);
                            if Text <> '' then begin
                                LotNoInfo.SetRange("Lot No.", Text);
                                if LotNoInfo.Find('-') then
                                    Lots.SetRecord(LotNoInfo);
                            end;
                            Lots.LookupMode(true);

                            if Lots.RunModal = ACTION::LookupOK then begin
                                Lots.GetRecord(LotNoInfo);
                                Text := LotNoInfo."Lot No.";
                                if InputItem = '' then
                                    InputItem := LotNoInfo."Item No.";
                                exit(true);
                            end else
                                exit(false);
                            /*
                            ItemLedgEntry.SETCURRENTKEY("Item No.","Variant Code",Open,Positive);
                            IF InputItem <> '' THEN
                              ItemLedgEntry.SETRANGE("Item No.",InputItem);
                            ItemLedgEntry.SETRANGE(Open,TRUE);
                            ItemLedgEntry.SETRANGE(Positive,TRUE);
                            ItemLedgEntries.SETTABLEVIEW(ItemLedgEntry);
                            IF Text <> '' THEN BEGIN
                              ItemLedgEntry.SETRANGE("Lot No.",Text);
                              IF ItemLedgEntry.FIND('-') THEN
                                ItemLedgEntries.SETRECORD(ItemLedgEntry);
                            END;
                            ItemLedgEntry.SETRANGE("Lot No.",'<>%1','');
                            ItemLedgEntries.LOOKUPMODE(TRUE);
                            
                            IF ItemLedgEntries.RUNMODAL = ACTION::LookupOK THEN BEGIN
                              ItemLedgEntries.GETRECORD(ItemLedgEntry);
                              Text := ItemLedgEntry."Lot No.";
                              IF InputItem = '' THEN
                                InputItem := ItemLedgEntry."Item No.";
                              EXIT(TRUE);
                            END ELSE
                              EXIT(FALSE);
                            */

                        end;

                        trigger OnValidate()
                        var
                            ItemLedgEntry: Record "Item Ledger Entry";
                        begin
                            ValidateItemLot;
                        end;
                    }
                    field(InputQty; InputQty)
                    {
                        ApplicationArea = FOODBasic;
                        AutoFormatType = 3;
                        CaptionClass = 'Quantity (' + Format(ItemUOM(InputItem)) + ')';
                        Caption = 'Quantity';
                        MinValue = 0;
                    }
                }
                group(Control37002002)
                {
                    ShowCaption = false;
                    field("ItemDescription(InputItem)"; ItemDescription(InputItem))
                    {
                        ApplicationArea = FOODBasic;
                        Editable = false;
                    }
                }
            }
            group(Process)
            {
                Caption = 'Process';
                field("Process No."; Process)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Process No.';
                    TableRelation = "Production BOM Header" WHERE("Mfg. BOM Type" = CONST(Process),
                                                                   "Output Type" = CONST(Item));

                    trigger OnValidate()
                    begin
                        if ProdBOM.Get(Process) then
                            OutputItem := ProdBOM."Output Item No."
                        else
                            OutputItem := '';
                        ValidateItemProcess;
                    end;
                }
                group("Output Item")
                {
                    Caption = 'Output Item';
                    field(OutputItem; OutputItem)
                    {
                        ApplicationArea = FOODBasic;
                        Editable = false;
                    }
                    field("ItemDescription(OutputItem)"; ItemDescription(OutputItem))
                    {
                        ApplicationArea = FOODBasic;
                        Editable = false;
                    }
                }
            }
            group("Order")
            {
                Caption = 'Order';
                field(StartDate; StartDate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Start Date';
                    NotBlank = true;
                }
                field(Direction; Direction)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Scheduling direction';
                    OptionCaption = 'Forward,Backward';
                }
                field(PopulateJnl; PopulateJnl)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Populate Journals';
                }
                field(OrderStatus; OrderStatus)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Order Status';
                }
                field("ShortcutDimCode[1]"; ShortcutDimCode[1])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,1';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(1, ShortcutDimCode[1]); // PR2.00
                    end;
                }
                field("ShortcutDimCode[2]"; ShortcutDimCode[2])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,2';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(2, ShortcutDimCode[2]); // PR2.00
                    end;
                }
                field(LocCode; LocCode)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Location Code';
                    TableRelation = Location;
                }
                field(PrintTicket; PrintTicket)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Print Ticket';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(OK)
            {
                ApplicationArea = FOODBasic;
                Caption = 'OK';
                Image = Approve;
                Promoted = true;
                PromotedCategory = New;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    ClickedOK;
                end;
            }
            action(Dimensions)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Dimensions';
                Image = Dimensions;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Shift+Ctrl+D';

                trigger OnAction()
                begin
                    DimMgt.EditDimensionSet(DimensionSetID, CurrPage.Caption); // P8001133
                    DimMgt.UpdateGlobalDimFromDimSetID(DimensionSetID, ShortcutDimCode[1], ShortcutDimCode[2]); // P8001133
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        ProcessSetup.Get;
        StartDate := WorkDate;
        OrderStatus := ProcessSetup."Default Process Status";
        LocCode := ProcessSetup."Default Process Location";
        PopulateJnl := ProcessSetup."Process Default Populate Jnls";
        PrintTicket := ProcessSetup."Default Process Ticket";
        // P800144605
        DimMgt.AddDimSource(DefaultDimSource, DATABASE::"Process Setup", 'PROCESS');
        DimensionSetID :=
          DimMgt.GetDefaultDimID(DefaultDimSource, '', ShortcutDimCode[1], ShortcutDimCode[2], 0, 0);
        // P800144605
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        // IF CloseAction = ACTION::OK THEN    // P8000785, P8001149
        if CloseAction = ACTION::LookupOK then // P8000785, P8001149
            ClickedOK;                       // P8000785
    end;

    var
        ProcessSetup: Record "Process Setup";
        Item: Record Item;
        ProdBOM: Record "Production BOM Header";
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        P800ProdOrderMgt: Codeunit "Process 800 Prod. Order Mgt.";
        DimMgt: Codeunit DimensionManagement;
        InputItem: Code[20];
        InputLot: Code[20];
        InputQty: Decimal;
        Process: Code[20];
        OutputItem: Code[20];
        LocCode: Code[10];
        ShortcutDimCode: array[8] of Code[20];
        StartDate: Date;
        OrderStatus: Option ,,"Firm Planned",Released;
        Direction: Option Forward,Backward;
        PopulateJnl: Boolean;
        PrintTicket: Boolean;
        OK: Boolean;
        Text000: Label 'must be greater than 0';
        Text001: Label 'Input item must be specified.';
        Text002: Label 'Input quantity must be specified.';
        Text003: Label 'Process must be specified.';
        Text004: Label 'Invalid process %1 for item %2.';
        Dummy: array[5] of Code[10];
        DimensionSetID: Integer;

    local procedure ItemDescription(No: Code[20]): Text[100]
    begin
        // P8001258 - increase size or Return Value to Text50
        if Item.Get(No) then
            exit(Item.Description)
        else
            exit('');
    end;

    local procedure ItemUOM(No: Code[20]): Code[10]
    begin
        if Item.Get(No) then
            exit(Item."Base Unit of Measure")
        else
            exit('');
    end;

    local procedure ValidateItemLot()
    var
        LotNoInfo: Record "Lot No. Information";
    begin
        // PR2.00 Begin
        // Redone for item tracking
        if (InputItem <> '') and (InputLot <> '') then begin
            LotNoInfo.Get(InputItem, '', InputLot);
            LotNoInfo.TestField(Posted, true);
            LotNoInfo.CalcFields(Inventory);
            if LotNoInfo.Inventory <= 0 then
                LotNoInfo.FieldError(Inventory, Text000);
            InputQty := LotNoInfo.Inventory;
        end;
        // PR2.00 End
    end;

    local procedure ValidateItemProcess()
    var
        ProdBOMLine: Record "Production BOM Line";
        VersionMgt: Codeunit VersionManagement;
    begin
        if (InputItem <> '') and (Process <> '') then begin
            ProdBOMLine.SetRange("Production BOM No.", Process);
            ProdBOMLine.SetRange("Version Code", VersionMgt.GetBOMVersion(Process, StartDate, true));
            ProdBOMLine.SetRange(Type, ProdBOMLine.Type::Item);
            ProdBOMLine.SetRange("No.", InputItem);
            ProdBOMLine.SetFilter("Quantity per", '>0');
            ProdBOMLine.SetFilter("Starting Date", '%1|..%2', 0D, StartDate);
            ProdBOMLine.SetFilter("Ending Date", '%1|%2..', 0D, StartDate);
            if not ProdBOMLine.Find('-') then
                Error(Text004, Process, InputItem);
        end;
    end;

    procedure GetProdOrder(var rec: Record "Production Order"; var Populate: Boolean): Boolean
    begin
        if OK then begin
            rec := ProdOrder;
            Populate := PopulateJnl;
            exit(OK);
        end else
            exit(OK);
    end;

    procedure ValidateShortcutDimCode(FieldNo: Integer; var ShortcutDimCode: Code[20])
    begin
        // PR2.00 Begin
        DimMgt.ValidateShortcutDimValues(FieldNo, ShortcutDimCode, DimensionSetID); // P8001133
        //DimValueMgt.SaveDimension(FieldNo,ShortcutDimCode); // P8001133
        // PR2.00 End
    end;

    procedure LookupShortcutDimCode(FieldNo: Integer; var ShortcutDimCode: Code[20])
    begin
        // PR2.00 Begin
        DimMgt.LookupDimValueCode(FieldNo, ShortcutDimCode); // P8001133
        ValidateShortcutDimCode(FieldNo, ShortcutDimCode); // P8001133
        //DimValueMgt.SaveDimension(FieldNo,ShortcutDimCode); // P8001133
        // PR2.00 End
    end;

    procedure ClickedOK()
    var
        ProdBOMLine: Record "Production BOM Line";
        VersionMgt: Codeunit VersionManagement;
        P800UOMFns: Codeunit "Process 800 UOM Functions";
        ProdTicket: Report "Production Ticket";
        VersionCode: Code[20];
        Qty: Decimal;
        factor: Decimal;
    begin
        if InputItem = '' then
            Error(Text001);
        if InputQty = 0 then
            Error(Text002);
        if Process = '' then
            Error(Text003);

        VersionCode := VersionMgt.GetBOMVersion(Process, StartDate, true);
        ProdBOMLine.SetRange("Production BOM No.", Process);
        ProdBOMLine.SetRange("Version Code", VersionCode);
        ProdBOMLine.SetRange(Type, ProdBOMLine.Type::Item);
        ProdBOMLine.SetRange("No.", InputItem);
        ProdBOMLine.SetFilter("Quantity per", '>0');
        ProdBOMLine.SetFilter("Starting Date", '%1|..%2', 0D, StartDate);
        ProdBOMLine.SetFilter("Ending Date", '%1|%2..', 0D, StartDate);
        ProdBOMLine.Find('-');
        factor := P800UOMFns.GetConversionFromTo(InputItem, ItemUOM(InputItem), ProdBOMLine."Unit of Measure Code");
        Qty := factor * InputQty; // convert to BOM line units
        Qty := Qty / ProdBOMLine."Quantity per"; // convert to output units (BOM)
        // PR3.60 Begin
        Item.Get(OutputItem);
        if Item.GetItemUOMRndgPrecision(ProdBOMLine."Unit of Measure Code", false) then  // PR3.70.03
            Qty := Round(Qty, Item."Rounding Precision");
        // PR3.60 End

        P800ProdOrderMgt.CreateProcessOrder(
          ProdOrder,
          ProdOrderLine,
          InputItem,
          OrderStatus,
          OutputItem,
          Qty,
          StartDate,
          LocCode,
          DimensionSetID, // P8001133
          InputLot,
          VersionMgt.GetBOMUnitOfMeasure(Process, VersionCode),
          Direction, Process); // PR3.60

        // Finally print the production ticket if the user has requested
        if PrintTicket then begin
            ProdOrder.SetRecFilter;
            ProdTicket.UseRequestPage(false);
            ProdTicket.SetTableView(ProdOrder);
            ProdTicket.Run;
        end;
        OK := true;
        CurrPage.Close;
    end;
}

