codeunit 37002561 "Container Functions"
{
    // PR3.61.01
    //   Modify PostSalesContainerLine to not post but pass back the data to be posted in the calling codeunit
    //   When Closing Container call DeleteRelations on Container Header
    // 
    // PR3.61.02
    //   Use TRUE parameter when inserting closed container transactions
    // 
    // PR3.70
    //   Remove Bin Code from call to create reservation entry
    // 
    // PR3.70.03
    //   Modified UpdateSalesOrderForContainer and UpdateTransOrderForContainer Function
    //    to use new GetUOMRndgPrecision function
    //    item."Rounding precision" will reflect UOM specific Rounding Precision if available
    //   Support for containers at "blank" location
    // 
    // PR3.70.04
    //   fix prolem when updating sales, transfer, item journal lines not properll handling fixed weight
    // 
    // P8000037B, Myers Nissi, Jack Reynolds, 16 MAY 04
    //   UpdateSalesOrderForContainer - change test when comparing remaining quantity to ship to container lines
    //     quantity to greater than or equal
    //   UpdateTransOrderForContainer - change test when comparing remaining quantity to ship to container lines
    //     quantity to greater than or equal
    // 
    // P8000039A, Myers Nissi, Jack Reynolds, 17 MAY 04
    //   UpdateSalesOrderForContainer - move Item.GET
    //   UpdateTransOrderForContainer - move Item.GET
    // 
    // P8000043A, Myers Nissi, Jack Reynolds, 02 JUN 04
    //    Support for easy lot tracking
    // 
    // PR3.70.07
    // P8000142A, Myers Nissi, Jack Reynolds, 18 NOV 04
    //   UpdateItemJnlForContainer - set location code on item journal lines from container
    // 
    // P8000140A, Myers Nissi, Jack Reynolds, 19 NOV 04
    //   Support for serialized containers
    //   Posting to container ledger from item journal posting
    // 
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Support for checking lot preferences
    // 
    // PR3.70.09
    // P8000200A, Myers Nissi, Jack Reynolds, 02 MAR 05
    //   Allow posting serialized containers through the transfer orders
    // 
    // PR3.70.10
    // P8000208A, Myers Nissi, Jack Reynolds, 07 APR 05
    //   Delete container header and lines when physical reduces container quanity to zero
    // 
    // PR4.00.03
    // P8000325A, VerticalSoft, Jack Reynolds, 01 MAY 06
    //   Modify calls to CreateReservEntry for new parameter for expiration date
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Don Bresee, 12 JUN 07
    //   Eliminate parameter for Expiration Date
    // 
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add 1-Doc Whse Logic
    //   Add "Bin Code" and related logic
    //   Add Central Container Bin
    // 
    // PRW16.00.02
    // P8000749, VerticalSoft, Don Bresee, 04 DEC 09
    //   Add GetNewLotNo call in ItemJnlLine logic
    //   Eliminate division by zero issue
    // 
    // PRW16.00.05
    // P8000923, Columbus IT, Jack Reynolds, 29 MAR 11
    //   Fix problems with posting transfer shipments
    // 
    // P8000931, Columbus IT, Jack Reynolds, 20 APR 11
    //   Support for Supply Chain Groups
    // 
    // PRW16.00.06
    // P8001035, Columbus IT, Jack Reynolds, 20 FEB 12
    //   Clear container fields from Tracking Specification and Reservation Entry
    //   Remove changes from project P8000923
    // 
    // P8001070, Columbus IT, Jack Reynolds, 16 MAY 12
    //   Bring Lot Freshness and Lot Preferences together
    // 
    // P8001087, Columbus IT, Jack Reynolds, 14 AUG 12
    //   Check availability of loose containers when posting container transactions
    // 
    // P8001123, Columbus IT, Jack Reynolds, 19 DEC 12
    //   Move Item table Label Code fields to Item Label table
    // 
    // P8001126, Columbus IT, Jack Reynolds, 03 JAN 13
    //   Repair problem assigning containers to sales orders
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW17.00.01
    // P8001186, Columbus IT, Jack Reynolds, 25 JUL 13
    //   Fix problem when adding containers to item journal lines
    // 
    // PRW17.10.03
    // P8001344, Columbus IT, Jack Reynolds, 21 AUG 14
    //   Fix alternate quantity permission error
    // 
    // P8001342, Columbus IT, Dayakar Battini, 21 Aug 14
    //    Containers -Prevent negative inventory applied to loose quantity.
    // 
    // P8001343, Columbus IT, Dayakar Battini, 25 Aug 14
    //    Containers -Consumption posting reduces container contents.
    // 
    // P8001357, Columbus IT, Jack Reynolds, 03 NOV 14
    //   Fix problem addiging/deletein containers to/from released sales orders
    // 
    // P8001373, To-Increase, Dayakar Battini, 11 Feb 15
    //   Support containers for purchase returns.
    // 
    // PRW18.00.02
    // P8004242, To-Increase, Jack Reynolds, 02 OCT 15
    //   Don't allow new containers on calculated physical journal line
    // 
    // P8004266, To-Increase, Jack Reynolds, 06 OCT 15
    //   Split containers
    // 
    // P8004339, To-Increase, Jack Reynolds, 07 OCT 15
    //   Cleanup functions to create new containers
    // 
    // P8004706, To-Increase, Jack Reynolds, 28 OCT 15
    //   Not updating quantity on source document when removing container from order
    // 
    // PRW19.00
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup obsolete container functionality
    // 
    // P8004516, To-Increase, Jack Reynolds, 17 MAR 16
    //   Incorporate modifications for NAV Anywhere processes
    // 
    // PRW19.00.01
    // P8007376, To-Increase, Jack Reynolds, 29 JUN 16
    //   Fix problem deleting containers from warehouse receipt
    // 
    // P8007405, To-Increase, Jack Reynolds, 20 JUL 16
    //   Handle Variant code when looking up containers from warehouse line
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // P8007653, To-Increase, Jack Reynolds, 21 NOV 16
    //   Fix confirmation message when removing container from inbound order
    //   Fix incorrect sign on alternate quantity data for containers on purchase documents
    //   Incorrect update of Qty. To Receive when deleting container from purchase
    //   Fix problems with updating Qty. to Ship (or Receive)
    // 
    // P8008176, To-Increase, Jack Reynolds, 08 DEC 16
    //       Fix Bin Code lenght errors
    // 
    // P8008287, To-Increase, Dayakar Battini, 16 DEC 16
    //       Fix Bin Code lenght errors
    // 
    // PRW110.0.01
    // P8007012, To-Increase, Jack Reynolds, 22 MAR 03
    //   Container Management Process
    // 
    // P8008651, To-Increase, Jack Reynolds, 07 APR 17
    //   Fix missing bin in inbound containers for transfer orders
    // 
    // P80037378, To-Increase, Dayakar Battini, 22 MAY 17
    //   Handling partial containers for picking.
    // 
    // P80039898, To-Increase, Dayakar Battini, 25 MAY 17
    //   Fix issue with container deletion.
    // 
    // P80045063, To-Increase, Dayakar Battini, 24 JUL 17
    //   Item Category Code length from code10 to code20
    // 
    // PRW110.0.02
    // P80050544, To-Increase, Dayakar Battini, 12 FEB 18
    //   Upgrade to 2017 CU13
    // 
    // P80046533, To-Increase, Jack Reynolds, 10 OCT 17
    //   Inbound containers and shipping containers
    // 
    // P80052981, To-Increase, Dayakar Battini, 12 FEB 17
    //   Issue fix for Catch weight item validation for putaway.
    // 
    // P80053241, To-Increase, Jack Reynolds, 13 FEB 18
    //   Fix problem inserting container charges for sales line
    // 
    // P80054495, To-Increase, Dayakar Battini, 26 FEB 17
    //   Issue fix for fixed weight item quantity updation.
    // 
    // P80056312, To-Increase, Dayakar Battini, 28 MAR 18
    //   Issue with container qty on lot no. changes.
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.01
    // P80057829, To-Increase, Dayakar Battini, 27 APR 18
    //   Provide Container handling for non blending pre-process activities
    // 
    // P80060004, To Increase, Jack Reynolds, 14 JUN 18
    //   Update Lot No. on source document lines when assigning containers
    //   Fix problem with ClearPendingShippingContainer
    // 
    // P80060274, To-Increase, Dayakar Battini, 28 JUN 18
    //   Fix problem with check loose quantity
    // 
    // P80056709, To-Increase, Jack Reynolds, 25 JUL 18
    //   Production Containers - assign container to production order
    // 
    // P80056710, To-Increase, Jack Reynolds, 25 JUL 18
    //   Production Containers - create production container from pick
    // 
    // P80056718, To-Increase, Jack Reynolds, 25 JUL 18
    //   Production Containers - consumption from production containers
    // 
    // P80062661, To-Increase, Jack Reynolds, 25 JUL 18
    //   SSCC
    // 
    // P80063018, To Increase, Jack Reynolds, 06 AUG 18
    //   Fix problem updating item tracking quantity to handle on inbound transfers
    // 
    // P80063375, To Increase, Jack Reynolds, 06 AUG 18
    //   Fix problem updating quantity to ship/receive on sales/purchase/transfer lines
    // 
    // PRW111.00.02
    // P80063544, To Increase, Jack Reynolds, 30 AUG 18
    //   Fix problem creating new containers for put-away lines
    // 
    // P80067225, To Increase, Jack Reynolds, 08 NOV 18
    //   Fix problem registering picks for non-integer quantities
    // 
    // P80067617, To Increase, Jack Reynolds, 20 NOV 18
    //   Fix problem checking for loose inventory
    // 
    // P80068361, To Increase, Gangabhushan, 17 DEC 18
    //   TI-12507 - Container loses catch weight qty. during registration of Put away/Pick
    // 
    // P80068877, To Increase, Jack Reynolds, 22 JAN 19
    //   Fix problem assigning container to different warehouse documents
    // 
    // PRW111.00.03
    // P80075420, To-Increase, Jack Reynolds, 08 JUL 19
    //   Problem losing tracking when using containers and specifying alt quantity to handle
    // 
    // P80086144, To-Increase, Gangabhushan, 04 NOV 19
    //   CS00079900 - New Pick Line Creation error when Pick lines more than 9 lines splits in Pick page
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW11300.03
    // P80082969, To Increase, Jack Reynolds, 26 SEP 19
    //   New Events
    // 
    // P80086371, To Increase, Jack Reynolds, 20 NOV 19
    //   New Events
    //
    //   PRW11400.01
    //   P80092182, To Increase, Jack Reynolds, 22 JAV 20
    //     New Events
    //
    //   PRW114.00.03
    //   P80097092, To-Increase, Gangabhushan, 07 APR 20
    //     CS00101702 - Container Information lost during shipping SO for GL Account
    //
    //   P80098649, To-Increase, Gangabhushan, 24 APR 20
    //     CS00105063 | Event needs changing in container functions - make event useful
    //
    //   P80099521, To-Increase, Gangabhushan, 19 MAY 20
    //     CS00107525 | CW Items &amp; Partial movements off containers    
    //
    //  PRW115.00.03
    //  P800117005, To-Increase, Gangabhushan, 09 FEB 21
    //    CS00147410 | FW: Sunshine Mills - Shipped Containers
    // 
    //   PRW114.00.03
    //   P800128454, To Increase, Jack Reynolds, 12 AUG 21
    //     Anywhere support for overpicking production containers
    //
    // PRW118.01
    // P800127049, To Increase, Jack Reynolds, 23 AUG 21
    //   Support for Inventory documents
    //
    // PRW119.03
    // P800142405, To Increase, Gangabhushan, 14 MAR 22
    //   CS00212965 | Error when Lot number exceeds 20 characters 
    //
    // PRW119.03
    // P800142458, To Increase, Gangabhushan, 18 MAr 22
    //   Create warning when using Resolve Shorts before using Undo functionality.      

    trigger OnRun()
    begin
    end;

    var
        ResEntry: Record "Reservation Entry";
        "User ID": Code[20];
        ContainerLineNo: Integer;
        PhysicalSplit: Record "Container Line";
        PhysicalSplitStatus: Integer;
        ContJnlPostLine: Codeunit "Container Jnl.-Post Line";
        Text000: Label 'Container %1 is not allowed for item %2.';
        Text001: Label 'not available at location';
        P800Functions: Codeunit "Process 800 Functions";
        IgnoreContainerBin: Boolean;
        Text002: Label '%1 %2 is not available.';
        RegisteringPick: Boolean;
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        Text003: Label 'Container is in-transit.';
        Text004: Label 'Container %1 is assigned to %2.';
        Text005: Label 'Item %1 is not allowed for container %2';
        Text006: Label 'Container %1 must be removed from the place lines.';
        Text007: Label 'Container %1 is on %2 %3.';
        Text008: Label 'Container %1 is empty.';
        Text009: Label 'Container %1 cannot contain multiple lots.';
        Text010: Label 'Container %1 cannot contain multiple items.';
        TempContainerLine: Record "Container Line" temporary;
        TempContainerLineToPost: Record "Container Line" temporary;
        TempContainerLinePosted: Record "Container Line" temporary;
        Text011: Label 'Loose inventory for Item %1 cannot be negative.';
        Text012: Label 'You cannot add containers to the %1 because Warehouse Shipments exist for the %1.';
        Text013: Label 'Container contains multiple items or lots.  This will cause the container to be deleted.\\Continue?';
        TempProdContainerLine: Record "Container Line" temporary;
        PostedFromDocument: Boolean;
        Text014: Label 'must be %1';
        Text015: Label '%1 cannot be less than number of containers assigned.';
        Text016: Label 'Off-site Source Type must be Customer.';
        Text017: Label 'Off-site Source Type must be Vendor.';
        Text018: Label 'Off-site Source No. must be %1.';
        Text019: Label '&Ship,&Receive';
        Text020: Label 'Nothing to split.';
        Text021: Label 'Container contains items.  This will cause the container to be deleted.\\Continue?';
        ContainerQuantityDocLineTable: Integer;
        ContainerQuantityDocLineDirection: Integer;
        ContainerQuantityDocLinePosition: Text;
        ContainerQuantityDocLineQuantity: array[2, 3] of Decimal;
        Text022: Label 'Item %1 is assigned to a fixed production bin.';
        Text023: Label 'Item %1 is not a component for Production Order %2.';
        Text024: Label 'Lot %1 for Item %2 is not available for consumption.';
        Text025: Label 'Lot %1 for Item %2 does not satisfy lot preferences for the component lines.';
        Text026: Label 'Container assignment is pending.';
        Text027: Label 'Container must be assigned to Production Order Line.';
        Text028: Label 'Container may not be assigned to Production Order Line.';
        Text030: Label 'Containers are assigned to production order lines for %1 %2.';
        Text031: Label 'Containers are not assigned to production order lines for %1 %2.';
        Text032: Label 'Production container %1 cannot be removed from pick line.';
        Text033: Label 'Production container %1 cannot be added to pick line.';
        Text034: Label 'For production containers %1 must be zero or %2.';
        ConfirmOKToRemoveAssignment: Label 'Resolve short will not work if you remove the container from the shipment then it may be necessary to undo pick before the shipment can be posted or resolve shorts can be executed.\\Continue?';

    local procedure LooseQuantity(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; LotNo: Code[50]; SerialNo: Code[50]; var Qty: Decimal; var QtyAlt: Decimal)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ContainerLine: Record "Container Line";
    begin
        // LooseQuantity
        ItemLedgerEntry.SetCurrentKey("Item No.", "Variant Code", "Location Code", "Lot No.", "Serial No.");
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        if VariantCode <> '' then
            ItemLedgerEntry.SetRange("Variant Code", VariantCode);
        //IF LocationCode <> '' THEN // PR3.70.03
        ItemLedgerEntry.SetRange("Location Code", LocationCode);
        if LotNo <> '' then
            ItemLedgerEntry.SetRange("Lot No.", LotNo);
        if SerialNo <> '' then
            ItemLedgerEntry.SetRange("Serial No.", SerialNo);
        ItemLedgerEntry.CalcSums(Quantity, "Quantity (Alt.)");
        Qty := ItemLedgerEntry.Quantity;
        QtyAlt := ItemLedgerEntry."Quantity (Alt.)";

        ContainerLine.SetCurrentKey("Item No.", "Variant Code", "Location Code", "Lot No.", "Serial No.");
        ContainerLine.SetRange("Item No.", ItemNo);
        //IF LocationCode <> '' THEN // PR3.70.03
        ContainerLine.SetRange("Location Code", LocationCode);
        if VariantCode <> '' then
            ContainerLine.SetRange("Variant Code", VariantCode);
        if LotNo <> '' then
            ContainerLine.SetRange("Lot No.", LotNo);
        if SerialNo <> '' then
            ContainerLine.SetRange("Serial No.", SerialNo);
        ContainerLine.CalcSums("Quantity (Base)", "Quantity (Alt.)", "Quantity Posted (Base)", "Quantity Posted (Alt.)"); // P80067617
        Qty -= ContainerLine."Quantity (Base)" - ContainerLine."Quantity Posted (Base)"; // P80067617
        QtyAlt -= ContainerLine."Quantity (Alt.)" - ContainerLine."Quantity Posted (Alt.)"; // P80067617
    end;

    procedure IsOKToRemoveAssignment(ContainerHeader: Record "Container Header"; ExcludeLineNo: Integer): Boolean
    var
        ContainerLine: Record "Container Line";
    begin
        // P8001324
        ContainerLine.SetRange("Container ID", ContainerHeader.ID);
        if ExcludeLineNo <> 0 then
            ContainerLine.SetFilter("Line No.", '<>%1', ExcludeLineNo);

        if ContainerHeader.Inbound then begin
            exit(ContainerLine.IsEmpty);
        end else begin
            // OK if no lines
            if not ContainerLine.FindFirst then
                exit(true);

            // Not OK if multiple items
            ContainerLine.SetFilter("Item No.", '<>%1', ContainerLine."Item No.");
            if not ContainerLine.IsEmpty then
                exit(false);

            // OK if no lots
            ContainerLine.SetRange("Item No.");
            ContainerLine.SetFilter("Lot No.", '<>%1', '');
            if not ContainerLine.FindFirst then
                exit(true);

            // OK if no lines require single lot
            ContainerLine.SetRange("Lot No.");
            ContainerLine.SetRange("Single Lot", true);
            if ContainerLine.IsEmpty then
                exit(true);

            // OK if all lots are the same
            ContainerLine.SetRange("Single Lot");
            ContainerLine.SetFilter("Lot No.", '<>%1', ContainerLine."Lot No.");
            if ContainerLine.IsEmpty then
                exit(true)
            else
                exit(false);
        end;
    end;

    procedure GetLooseQtyForContainerLine(ContLine: Record "Container Line"; var Qty: Decimal; var QtyAlt: Decimal)
    var
        ItemUOM: Record "Item Unit of Measure";
        ContainerLine: Record "Container Line";
        RoundingMgmt: Codeunit "Rounding Adjustment Mgmt.";
        NearZeroQty: Decimal;
    begin
        // P8001323
        ItemUOM.Get(ContLine."Item No.", ContLine."Unit of Measure Code");
        NearZeroQty := RoundingMgmt.GetNearZeroQtyForItem(ContLine."Item No.");

        GetLooseQty(ContLine."Location Code", ContLine."Bin Code", ContLine."Item No.", ContLine."Variant Code", ContLine."Unit of Measure Code",
          ContLine."Lot No.", ContLine."Serial No.", Qty, QtyAlt);

        // P80056312
        if ContainerLine.Get(ContLine."Container ID", ContLine."Line No.") then
            if (ContainerLine."Item No." = ContLine."Item No.") and (ContainerLine."Variant Code" = ContLine."Variant Code") and
                (ContainerLine."Lot No." = ContLine."Lot No.") and (ContainerLine."Serial No." = ContLine."Serial No.") and
                (ContainerLine."Unit of Measure Code" = ContLine."Unit of Measure Code")
            then begin
                // P80056312
                Qty := Qty + (ContainerLine."Quantity (Base)" / ContLine."Qty. per Unit of Measure");
                QtyAlt := QtyAlt + ContainerLine."Quantity (Alt.)";
            end;

        Qty += NearZeroQty / ItemUOM."Qty. per Unit of Measure";
        Qty := Round(Qty, 0.00001);
        QtyAlt += NearZeroQty;
    end;

    procedure SetLooseQtyForWhseEntry(var WhseEntry: Record "Warehouse Entry")
    var
        ContainerLine: Record "Container Line";
        ContainerLineAppl: Record "Container Line Application";
    begin
        // P8001342
        ContainerLine.SetRange("Item No.", WhseEntry.GetFilter("Item No."));
        ContainerLine.SetRange("Variant Code", WhseEntry.GetFilter("Variant Code"));
        ContainerLine.SetRange("Unit of Measure Code", WhseEntry.GetFilter("Unit of Measure Code"));
        ContainerLine.SetRange("Location Code", WhseEntry.GetFilter("Location Code"));
        ContainerLine.SetRange("Bin Code", WhseEntry.GetFilter("Bin Code"));
        ContainerLine.SetRange("Lot No.", WhseEntry.GetFilter("Lot No."));
        ContainerLine.SetRange("Serial No.", WhseEntry.GetFilter("Serial No."));
        ContainerLine.CalcSums(Quantity, "Quantity (Base)");
        WhseEntry.Quantity -= ContainerLine.Quantity;
        WhseEntry."Qty. (Base)" -= ContainerLine."Quantity (Base)";
    end;

    procedure GetLooseQty(LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UOM: Code[10]; LotNo: Code[50]; SerialNo: Code[50]; var Qty: Decimal; var QtyAlt: Decimal)
    var
        ContQty: Decimal;
        ContQtyAlt: Decimal;
    begin
        // P8001323
        // P8008176 - change BinCode to Code20
        GetTotalQty(LocationCode, BinCode, ItemNo, VariantCode, UOM, LotNo, SerialNo, Qty, QtyAlt);
        GetContainerQty(LocationCode, BinCode, ItemNo, VariantCode, UOM, LotNo, SerialNo, ContQty, ContQtyAlt);

        Qty -= ContQty;
        QtyAlt -= ContQtyAlt;
    end;

    local procedure GetTotalQty(LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UOM: Code[10]; LotNo: Code[50]; SerialNo: Code[50]; var Qty: Decimal; var QtyAlt: Decimal)
    var
        ItemUOM: Record "Item Unit of Measure";
        ItemLedgerEntry: Record "Item Ledger Entry";
        WhseEntry: Record "Warehouse Entry";
        Location: Record Location;
    begin
        // P8008176 - change BinCode to Code20
        ItemUOM.Get(ItemNo, UOM);

        if not Location.Get(LocationCode) then // P80053245
            Clear(Location);                     // P80053245
        //LocationType := Location.LocationType; // P8004516

        ItemLedgerEntry.SetCurrentKey("Item No.", "Variant Code", "Location Code", "Lot No.", "Serial No.");
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange("Variant Code", VariantCode);
        ItemLedgerEntry.SetRange("Lot No.", LotNo);
        ItemLedgerEntry.SetRange("Serial No.", SerialNo);
        ItemLedgerEntry.SetRange("Location Code", LocationCode);
        if BinCode = '' then begin
            ItemLedgerEntry.CalcSums(Quantity, "Quantity (Alt.)");
            Qty := ItemLedgerEntry.Quantity / ItemUOM."Qty. per Unit of Measure";
            QtyAlt := ItemLedgerEntry."Quantity (Alt.)";
        end else begin
            ItemLedgerEntry.CalcSums("Quantity (Alt.)");
            QtyAlt := ItemLedgerEntry."Quantity (Alt.)";

            WhseEntry.SetCurrentKey("Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code", "Lot No.", "Serial No.");
            WhseEntry.SetRange("Item No.", ItemNo);
            WhseEntry.SetRange("Variant Code", VariantCode);
            if Location."Directed Put-away and Pick" then // P8004516
                WhseEntry.SetRange("Unit of Measure Code", UOM);
            WhseEntry.SetRange("Lot No.", LotNo);
            WhseEntry.SetRange("Serial No.", SerialNo);
            WhseEntry.SetRange("Location Code", LocationCode);
            WhseEntry.SetRange("Bin Code", BinCode);
            if Location."Directed Put-away and Pick" then begin // P8004516
                WhseEntry.CalcSums(Quantity);
                Qty := WhseEntry.Quantity;
            end else begin
                WhseEntry.CalcSums("Qty. (Base)");
                Qty := WhseEntry."Qty. (Base)" / ItemUOM."Qty. per Unit of Measure";
            end;
        end;
    end;

    local procedure GetContainerQty(LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UOM: Code[10]; LotNo: Code[50]; SerialNo: Code[50]; var Qty: Decimal; var QtyAlt: Decimal)
    var
        ItemUOM: Record "Item Unit of Measure";
        ContainerLine: Record "Container Line";
        Location: Record Location;
    begin
        // P8001342
        // P8008176 - change BinCode to Code20
        ItemUOM.Get(ItemNo, UOM);

        if not Location.Get(LocationCode) then // P80053245
            Clear(Location);                     // P80053245
        //LocationType := Location.LocationType; // P8004516

        ContainerLine.SetRange("Item No.", ItemNo);
        ContainerLine.SetRange("Variant Code", VariantCode);
        if Location."Directed Put-away and Pick" then // P8004516
            ContainerLine.SetRange("Unit of Measure Code", UOM);
        ContainerLine.SetRange("Lot No.", LotNo);
        ContainerLine.SetRange("Serial No.", SerialNo);
        ContainerLine.SetRange("Location Code", LocationCode);
        ContainerLine.SetRange(Inbound, false);
        ContainerLine.CalcSums("Quantity (Alt.)", "Quantity Posted (Alt.)"); // P80067617
        QtyAlt := ContainerLine."Quantity (Alt.)" - ContainerLine."Quantity Posted (Alt.)"; // P80067617

        ContainerLine.SetRange("Bin Code", BinCode);
        if Location."Directed Put-away and Pick" then begin // P8004516
            ContainerLine.CalcSums(Quantity, "Quantity Posted"); // P80067617
            Qty := ContainerLine.Quantity - ContainerLine."Quantity Posted"; // P80067617
        end else begin
            ContainerLine.CalcSums("Quantity (Base)", "Quantity Posted (Base)"); // P80067617
            Qty := (ContainerLine."Quantity (Base)" - ContainerLine."Quantity Posted (Base)") / ItemUOM."Qty. per Unit of Measure"; // P80067617
        end;

        Qty := Round(Qty, 0.00001);
    end;

    procedure GetContainerCount(DocumentType: Integer; DocumentSubtype: Integer; DocumentNo: Code[20]; DocumentRefNo: Integer; ExcludeWhseDoc: Boolean; ShipReceive: Variant): Integer
    var
        ContainerHeader: Record "Container Header";
    begin
        // P80046533
        ContainerHeader.SetRange("Document Type", DocumentType);
        ContainerHeader.SetRange("Document Subtype", DocumentSubtype);
        ContainerHeader.SetRange("Document No.", DocumentNo);
        ContainerHeader.SetRange("Document Ref. No.", DocumentRefNo);
        if ExcludeWhseDoc then
            ContainerHeader.SetRange("Whse. Document Type", 0);
        if ShipReceive.IsBoolean then
            ContainerHeader.SetRange("Ship/Receive", ShipReceive);
        exit(ContainerHeader.Count);
    end;

    procedure GetContainerQuantitiesByDocLine(DocumentLine: Variant; Direction: Integer; var QtyToHandle: Decimal; var QtyToHandleBase: Decimal; var QtyToHandleAlt: Decimal; ShipReceive: Variant)
    var
        Process800CoreFunctions: Codeunit "Process 800 Core Functions";
        DocumentLineRecRef: RecordRef;
        ApplicationTaleNo: Integer;
        ApplicationSubType: Integer;
        ApplicationNo: Code[20];
        ApplicationDummy: Code[10];
        ApplicationLineNo: Integer;
        ContainerQtyByDocLine: Query "Container Qty. by Doc. Line";
        RowIndex: Integer;
        ShipReceiveBoolean: Boolean;
    begin
        // P80046533
        DocumentLineRecRef.GetTable(DocumentLine);
        if (ContainerQuantityDocLineTable <> DocumentLineRecRef.Number) or
           (ContainerQuantityDocLineDirection <> Direction) or
           (ContainerQuantityDocLinePosition <> DocumentLineRecRef.GetPosition)
        then begin
            Clear(ContainerQuantityDocLineQuantity);
            ContainerQuantityDocLineTable := DocumentLineRecRef.Number;
            ContainerQuantityDocLineDirection := Direction;
            ContainerQuantityDocLinePosition := DocumentLineRecRef.GetPosition;
            // P80075420
            Process800CoreFunctions.GetLineFilterValues(DocumentLine, Direction, ApplicationTaleNo, ApplicationSubType, ApplicationNo,
              ApplicationDummy, ApplicationLineNo);
            ContainerQtyByDocLine.SetRange(ApplicationTableNo, ApplicationTaleNo);
            ContainerQtyByDocLine.SetRange(ApplicationSubtype, ApplicationSubType);
            ContainerQtyByDocLine.SetRange(ApplicationNo, ApplicationNo);
            ContainerQtyByDocLine.SetRange(ApplicationLineNo, ApplicationLineNo);
            // P80075420

            if ContainerQtyByDocLine.Open then
                while ContainerQtyByDocLine.Read do begin
                    if ContainerQtyByDocLine.ShipReceive then
                        RowIndex := 2
                    else
                        RowIndex := 1;
                    ContainerQuantityDocLineQuantity[RowIndex, 1] := ContainerQtyByDocLine.SumQuantity;
                    ContainerQuantityDocLineQuantity[RowIndex, 2] := ContainerQtyByDocLine.SumQuantityBase;
                    ContainerQuantityDocLineQuantity[RowIndex, 3] := ContainerQtyByDocLine.SumQuantityAlt;
                end;
        end;

        if not ShipReceive.IsBoolean then begin
            QtyToHandle := ContainerQuantityDocLineQuantity[1, 1] + ContainerQuantityDocLineQuantity[2, 1];
            QtyToHandleBase := ContainerQuantityDocLineQuantity[1, 2] + ContainerQuantityDocLineQuantity[2, 2];
            QtyToHandleAlt := ContainerQuantityDocLineQuantity[1, 3] + ContainerQuantityDocLineQuantity[2, 3];
        end else begin
            ShipReceiveBoolean := ShipReceive;
            if ShipReceiveBoolean then
                RowIndex := 2
            else
                RowIndex := 1;
            QtyToHandle := ContainerQuantityDocLineQuantity[RowIndex, 1];
            QtyToHandleBase := ContainerQuantityDocLineQuantity[RowIndex, 2];
            QtyToHandleAlt := ContainerQuantityDocLineQuantity[RowIndex, 3];
        end;
    end;

    local procedure ContainerItemNo2Type(ContainerItemNo: Code[20]): Code[10]
    var
        ContainerType: Record "Container Type";
    begin
        // P80053241
        if ContainerItemNo = '' then
            exit;

        ContainerType.SetRange("Container Item No.", ContainerItemNo);
        if ContainerType.FindFirst then
            exit(ContainerType.Code);
    end;

    procedure IsContainerAvailable(ContHeader: Record "Container Header"): Boolean
    var
        ContainerType: Record "Container Type";
        InvSetup: Record "Inventory Setup";
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        ContainerHeader: Record "Container Header";
    begin
        // P8001323
        if ContHeader."Container Type Code" = '' then // P80039780
            exit(true);                                 // P80039780

        ContainerType.Get(ContHeader."Container Type Code");
        if not ContainerType."Maintain Inventory Value" then  //P8001373
            exit(true);

        // P8001323
        Item.Get(ContainerType."Container Item No.");
        if (not ContainerType.IsSerializable) and (ContHeader.Inbound or (not Item.PreventNegativeInventory)) then
            exit(true);
        // P8001323

        if ContHeader.Inbound then begin
            if ContHeader."Container Serial No." <> '' then begin
                InvSetup.Get;
                ItemLedgerEntry.SetCurrentKey("Item No.", "Variant Code", "Location Code");
                ItemLedgerEntry.SetRange("Item No.", ContainerType."Container Item No.");
                ItemLedgerEntry.SetRange("Location Code", InvSetup."Offsite Cont. Location Code");
                ItemLedgerEntry.SetRange("Serial No.", ContHeader."Container Serial No.");
                ItemLedgerEntry.CalcSums(Quantity);
                if ItemLedgerEntry.Quantity <> 1 then
                    exit(false);

                ContainerHeader.SetRange("Container Type Code", ContHeader."Container Type Code");
                ContainerHeader.SetRange("Container Serial No.", ContHeader."Container Serial No.");
                exit(ContainerHeader.IsEmpty);
            end;
        end else begin
            ItemLedgerEntry.SetCurrentKey("Item No.", "Variant Code", "Location Code");
            ItemLedgerEntry.SetRange("Item No.", ContainerType."Container Item No.");
            if ContHeader."Location Code" <> '' then
                ItemLedgerEntry.SetRange("Location Code", ContHeader."Location Code");
            if ContHeader."Container Serial No." <> '' then
                ItemLedgerEntry.SetRange("Serial No.", ContHeader."Container Serial No.");
            ItemLedgerEntry.CalcSums(Quantity);

            ContainerHeader.SetRange("Container Type Code", ContHeader."Container Type Code");
            if ContHeader."Location Code" <> '' then
                ContainerHeader.SetRange("Location Code", ContHeader."Location Code");
            if ContHeader."Container Serial No." <> '' then
                ContainerHeader.SetRange("Container Serial No.", ContHeader."Container Serial No.");
            if ContHeader."Container Serial No." = '' then
                ContainerHeader.SetRange(Inbound, false);

            exit(ContainerHeader.Count < ItemLedgerEntry.Quantity);
        end;
    end;

    procedure CheckContainerUsage(ContainerHeader: Record "Container Header"; ItemNo: Code[20]; UOM: Code[10]; LotNo: Code[50]; var ContainerUsage: Record "Container Type Usage")
    var
        Item: Record Item;
        ContainerLine: Record "Container Line";
        ItemWithUOM: Text;
    begin
        // P8007012
        Item.Get(ItemNo);
        if not GetContainerUsage(ContainerHeader."Container Type Code", ItemNo, Item."Item Category Code", UOM, UOM <> '', ContainerUsage) then begin
            if UOM = '' then
                ItemWithUOM := ItemNo
            else
                ItemWithUOM := StrSubstNo('%1 (%2)', ItemNo, UOM);
            Error(Text005, ItemWithUOM, ContainerHeader."License Plate");
        end;

        ContainerLine.SetRange("Container ID", ContainerHeader.ID);
        ContainerLine.SetFilter("Item No.", '<>%1', ItemNo);
        if not ContainerLine.IsEmpty then
            Error(Text010, ContainerHeader."License Plate")
        else
            if (LotNo <> '') and ContainerUsage."Single Lot" then begin
                ContainerLine.SetRange("Item No.");
                ContainerLine.SetFilter("Lot No.", '<>%1', LotNo);
                if not ContainerLine.IsEmpty then
                    Error(Text009, ContainerHeader."License Plate");
            end;
    end;

    procedure GetContainerUsage(ContainerTypeCode: Code[10]; ItemNo: Code[20]; ItemCategoryCode: Code[20]; UOMCode: Code[10]; IncludeUOM: Boolean; var ContainerUsage: Record "Container Type Usage"): Boolean
    var
        ItemCategory: Record "Item Category";
    begin
        // P8001323
        // P8007749 - remove parameter ProductGroupCode
        ContainerUsage.Reset;
        ContainerUsage.SetRange("Container Type Code", ContainerTypeCode);
        ContainerUsage.SetRange("Item Type", ContainerUsage."Item Type"::Specific);
        ContainerUsage.SetRange("Item Code", ItemNo);
        if IncludeUOM then
            ContainerUsage.SetRange("Unit of Measure Code", UOMCode);
        if ContainerUsage.FindFirst then
            exit(true)
        else
            if IncludeUOM then begin
                ContainerUsage.SetRange("Unit of Measure Code", '');
                if ContainerUsage.FindFirst then
                    exit(true);
            end;

        if ItemCategoryCode <> '' then begin
            ContainerUsage.SetRange("Item Type", ContainerUsage."Item Type"::"Item Category");
            //ContainerUsage.SETRANGE("Item Code",ItemCategoryCode);
            if IncludeUOM then
                ContainerUsage.SetRange("Unit of Measure Code", UOMCode);
            if ContainerUsage.FindForItemCategory(ItemCategoryCode) then // P8007749
                exit(true)
            else
                if IncludeUOM then begin
                    ContainerUsage.SetRange("Unit of Measure Code", '');
                    if ContainerUsage.FindForItemCategory(ItemCategoryCode) then // P8007749
                        exit(true);
                end;
        end;

        ContainerUsage.SetRange("Item Type", ContainerUsage."Item Type"::All);
        ContainerUsage.SetRange("Item Code", '');
        if IncludeUOM then
            ContainerUsage.SetRange("Unit of Measure Code", UOMCode);
        if ContainerUsage.FindFirst then
            exit(true)
        else
            if IncludeUOM then begin
                ContainerUsage.SetRange("Unit of Measure Code", '');
                if ContainerUsage.FindFirst then
                    exit(true);
            end;
    end;

    procedure IsInboundDocument(SourceType: Integer; SourceSubType: Integer): Boolean
    var
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
    begin
        // P8001324
        case SourceType of
            DATABASE::"Sales Line":
                exit(SourceSubType = SalesLine."Document Type"::"Return Order");
            DATABASE::"Purchase Line":
                exit(SourceSubType = PurchaseLine."Document Type"::Order);
            DATABASE::"Transfer Line":
                exit(SourceSubType = 1);
            DATABASE::"Prod. Order Component":
                exit(false); // P80056709
        end;
    end;

    procedure GetReceivingBin(LocationCode: Code[10]) BinCode: Code[20]
    var
        Location: Record Location;
    begin
        // P80039780
        if not Location.Get(LocationCode) then
            exit;

        if Location."Require Receive" then
            BinCode := Location."Receipt Bin Code"
        else
            BinCode := Location."Receipt Bin Code (1-Doc)";
    end;

    procedure SplitContainer(ContainerHeader: Record "Container Header"; var ContainerLine: Record "Container Line")
    var
        NewContainerHeader: Record "Container Header";
        ContainerLine2: Record "Container Line";
        ContainerUsage: Record "Container Type Usage";
        Item: Record Item;
        ContainerFns: Codeunit "Container Functions";
        LineCount: Integer;
    begin
        // P8004266
        CheckContainerAssignment(ContainerHeader.ID);

        ContainerLine2.SetRange("Container ID", ContainerHeader.ID);
        LineCount := ContainerLine2.Count;
        if LineCount <= 1 then
            Error(Text020);

        if LineCount = ContainerLine.Count then
            Error(Text020);

        ContainerLine.FindFirst;
        if not CreateNewContainer('', false, ContainerHeader."Location Code", ContainerHeader."Bin Code", // P8004339
          ContainerLine."Item No.", ContainerLine."Unit of Measure Code", NewContainerHeader)
        then
            exit;
        NewContainerHeader.Delete;
        Commit;
        NewContainerHeader.Insert;

        if ContainerLine.FindSet(true, true) then
            repeat
                Item.Get(ContainerLine."Item No.");
                if not GetContainerUsage(NewContainerHeader."Container Type Code", Item."No.", Item."Item Category Code", // P8007749
                    ContainerLine."Unit of Measure Code", true, ContainerUsage)
                then
                    Error(Text005, Item."No.", NewContainerHeader."License Plate");

                ContainerLine.Delete(true);
                ContainerLine2 := ContainerLine;
                ContainerLine2."Container ID" := NewContainerHeader.ID;
                ContainerLine2."Single Lot" := ContainerUsage."Single Lot";
                ContainerLine2.CheckSingleLot;
                ContainerLine2.Insert(true);
            until ContainerLine.Next = 0;
    end;

    procedure AssignContainer(var ContainerHeader: Record "Container Header")
    var
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        ProductionOrder: Record "Production Order";
        AssignToOrder: Page "Assign Container to Order";
        DocType: Integer;
        DocNo: Code[20];
        DocLineNo: Integer;
        DeleteContainer: Boolean;
    begin
        // P80056709
        if ContainerHeader."Pending Assignment" then
            Error(Text026);
        if (ContainerHeader."Document Type" = DATABASE::"Transfer Line") and (ContainerHeader."Document Subtype" = 1) then
            Error(Text003);
        // P80056709

        ContainerHeader.TestField("Ship/Receive", false);    // P80046533
        ContainerHeader.TestField("Whse. Document Type", 0); // P80046533
        ContainerHeader.CheckHeaderComplete(false);

        AssignToOrder.SetContainer(ContainerHeader);
        if AssignToOrder.RunModal = ACTION::OK then begin
            AssignToOrder.GetOrder(DocType, DocNo, DocLineNo, DeleteContainer); // P80056709
            if DeleteContainer then begin
                ContainerHeader.Delete(true);
                exit;
            end;

            if (DocType <> ContainerHeader."Document Type") or (DocNo <> ContainerHeader."Document No.") or (DocLineNo <> ContainerHeader."Document Line No.") then begin // P80056709
                                                                                                                                                                          // First remove container from original document
                DeleteContainerFromOrder(ContainerHeader);

                // Now add container to new order
                ContainerHeader."Document Type" := DocType;
                ContainerHeader."Document Subtype" := 0;
                ContainerHeader."Document No." := DocNo;
                ContainerHeader."Document Ref. No." := 0;
                ContainerHeader."Whse. Document Type" := 0;
                ContainerHeader."Whse. Document No." := '';
                ContainerHeader."Transfer-to Bin Code" := '';

                if ContainerHeader.Inbound then begin
                    case ContainerHeader."Document Type" of
                        DATABASE::"Sales Line":
                            begin
                                ContainerHeader."Document Subtype" := SalesHeader."Document Type"::"Return Order";
                                UpdateSalesForContainer(ContainerHeader, 0, '');
                            end;
                        DATABASE::"Purchase Line":
                            begin
                                ContainerHeader."Document Subtype" := PurchHeader."Document Type"::Order;
                                UpdatePurchaseForContainer(ContainerHeader, 0, '');
                            end;
                    end;
                end else begin
                    case ContainerHeader."Document Type" of
                        DATABASE::"Sales Line":
                            begin
                                ContainerHeader."Document Subtype" := SalesHeader."Document Type"::Order;
                                UpdateSalesForContainer(ContainerHeader, 0, ''); // P8001323
                            end;
                        DATABASE::"Purchase Line":
                            begin
                                //P8001373
                                ContainerHeader."Document Subtype" := PurchHeader."Document Type"::"Return Order";
                                UpdatePurchaseForContainer(ContainerHeader, 0, ''); // P8001323
                                                                                    //P8001373
                            end;
                        DATABASE::"Transfer Line":
                            begin
                                UpdateTransferForContainer(ContainerHeader, 0, ''); // P8001323
                            end;
                        // P80056709
                        DATABASE::"Prod. Order Component":
                            begin
                                ContainerHeader."Document Subtype" := ProductionOrder.Status::Released;
                                ContainerHeader."Document Line No." := DocLineNo;
                                UpdateProductionForContainer(ContainerHeader);
                            end;
                    // P80056709
                    end;
                end;

                ContainerHeader.Modify; // P80056709
            end;
        end;
    end;

    procedure AssignContainerLine(var ContainerHeader: Record "Container Header"; xContainerLine: Record "Container Line"; ContainerLine: Record "Container Line")
    var
        ContainerLineAppl: Record "Container Line Application";
        WarehouseDocType: Integer;
        WarehouseDocNo: Code[20];
        TransferToBin: Code[20];
        QtyToAdjust: Decimal;
    begin
        // P8001324
        // P8008287 - change BinCode to Code20
        if ContainerHeader."Document Type" = 0 then
            exit;

        WarehouseDocType := ContainerHeader."Whse. Document Type";
        WarehouseDocNo := ContainerHeader."Whse. Document No.";

        if (xContainerLine."Item No." <> ContainerLine."Item No.") or
           (xContainerLine."Variant Code" <> ContainerLine."Variant Code") or
           (xContainerLine."Unit of Measure Code" <> ContainerLine."Unit of Measure Code") or
           (xContainerLine."Lot No." <> ContainerLine."Lot No.") or
           (xContainerLine."Serial No." <> ContainerLine."Serial No.")
        then begin
            if (xContainerLine.Quantity <> 0) and (ContainerHeader."Document Type" <> DATABASE::"Prod. Order Component") then begin // P80056709
                ContainerLineAppl.SetCurrentKey("Container ID");
                ContainerLineAppl.SetRange("Container ID", xContainerLine."Container ID");
                ContainerLineAppl.SetRange("Container Line No.", xContainerLine."Line No.");
                if ContainerLineAppl.FindSet(true) then
                    repeat
                        ContainerLineAppl.SetParameters(xContainerLine, ContainerHeader."Ship/Receive", false, RegisteringPick); //P80075420
                        ContainerLineAppl.Delete(true);
                    until ContainerLineAppl.Next = 0;

                if ContainerHeader."Document Type" = DATABASE::"Transfer Line" then begin
                    ContainerHeader."Transfer-to Bin Code" := '';
                    if ContainerHeader.GetTransferToBin(TransferToBin) then
                        ContainerHeader."Transfer-to Bin Code" := TransferToBin;
                end;
            end;

            if ContainerLine.Quantity <> 0 then begin
                case ContainerHeader."Document Type" of
                    DATABASE::"Sales Line":
                        UpdateSalesForContainerLine(ContainerHeader, ContainerLine, WarehouseDocType, WarehouseDocNo); // P8001323
                    DATABASE::"Purchase Line":
                        UpdatePurchaseForContainerLine(ContainerHeader, ContainerLine, WarehouseDocType, WarehouseDocNo); // P8001323
                    DATABASE::"Transfer Line":
                        UpdateTransferForContainerLine(ContainerHeader, ContainerLine, WarehouseDocType, WarehouseDocNo); // P8001323
                    DATABASE::"Prod. Order Component":
                        UpdateProductionForContainerLine(ContainerHeader, ContainerLine); // P80056709
                end;
            end;
        end else
            if ContainerHeader."Document Type" = DATABASE::"Prod. Order Component" then begin // P80056709
                UpdateProductionForContainerLine(ContainerHeader, ContainerLine); // P80056709
            end else begin
                if xContainerLine.Quantity < ContainerLine.Quantity then begin
                    ContainerLine.Quantity -= xContainerLine.Quantity;
                    ContainerLine."Quantity (Base)" -= xContainerLine."Quantity (Base)";
                    ContainerLine."Quantity (Alt.)" -= xContainerLine."Quantity (Alt.)";
                    case ContainerHeader."Document Type" of
                        DATABASE::"Sales Line":
                            UpdateSalesForContainerLine(ContainerHeader, ContainerLine, WarehouseDocType, WarehouseDocNo); // P8001323
                        DATABASE::"Purchase Line":
                            UpdatePurchaseForContainerLine(ContainerHeader, ContainerLine, WarehouseDocType, WarehouseDocNo); // P8001323
                        DATABASE::"Transfer Line":
                            UpdateTransferForContainerLine(ContainerHeader, ContainerLine, WarehouseDocType, WarehouseDocNo); // P8001323
                    end;
                end else begin
                    xContainerLine.Quantity -= ContainerLine.Quantity;
                    xContainerLine."Quantity (Base)" -= ContainerLine."Quantity (Base)";
                    xContainerLine."Quantity (Alt.)" -= ContainerLine."Quantity (Alt.)";
                    ContainerLineAppl.SetCurrentKey("Application Table No.", "Application Subtype", "Application No.", "Application Batch Name", "Application Line No.");
                    ContainerLineAppl.Ascending(false);
                    ContainerLineAppl.SetRange("Container ID", xContainerLine."Container ID");
                    ContainerLineAppl.SetRange("Container Line No.", xContainerLine."Line No.");
                    if ContainerLineAppl.FindSet(true) then
                        repeat
                            if ContainerLineAppl.Quantity <= xContainerLine.Quantity then begin
                                xContainerLine.Quantity -= ContainerLineAppl.Quantity;
                                xContainerLine."Quantity (Base)" -= ContainerLineAppl."Quantity (Base)";
                                xContainerLine."Quantity (Alt.)" -= ContainerLineAppl."Quantity (Alt.)";
                                ContainerLineAppl.SetParameters(ContainerLine, ContainerHeader."Ship/Receive", false, RegisteringPick); //P80075420
                                ContainerLineAppl.Delete(true);
                            end else begin
                                ContainerLineAppl.Quantity -= xContainerLine.Quantity;
                                ContainerLineAppl."Quantity (Base)" -= xContainerLine."Quantity (Base)";
                                ContainerLineAppl."Quantity (Alt.)" -= xContainerLine."Quantity (Alt.)";
                                ContainerLineAppl.SetParameters(ContainerLine, ContainerHeader."Ship/Receive", false, RegisteringPick); //P80075420
                                ContainerLineAppl.Modify(true);
                                break;
                            end;
                        until ContainerLineAppl.Next = 0;
                end;
            end;

        ContainerHeader.Modify;
    end;

    procedure AddContainerToOrder(ContainerID: Code[20]; SourceType: Integer; SourceSubType: Integer; SourceDocNo: Code[20]; SourceDocLineNo: Integer; SourceRefNo: Integer; WarehouseDocType: Integer; WarehouseDocNo: Code[20]; ShipReceive: Boolean)
    var
        ContainerHeader: Record "Container Header";
        Location: Record Location;
    begin
        // P8001324
        // P80046533 - add paraneter ShipReceive
        // P80056709 - add parameter SourceDocLineNo
        ContainerHeader.Get(ContainerID);
        ContainerHeader.CheckHeaderComplete(false);
        ContainerHeader.TestField(Inbound, IsInboundDocument(SourceType, SourceSubType));

        if SourceType <> DATABASE::"Prod. Order Component" then begin // P80056709
            Location.Get(ContainerHeader."Location Code");
            if (not ContainerHeader.Inbound) and (not RegisteringPick) then
                Location.TestField("Require Pick", false);
        end;                                                     // P80056709

        ContainerHeader."Document Type" := SourceType;
        ContainerHeader."Document Subtype" := SourceSubType;
        ContainerHeader."Document No." := SourceDocNo;
        ContainerHeader."Document Line No." := SourceDocLineNo; // P80056709
        ContainerHeader."Document Ref. No." := SourceRefNo;
        ContainerHeader."Whse. Document Type" := WarehouseDocType;
        ContainerHeader."Whse. Document No." := WarehouseDocNo;
        ContainerHeader."Ship/Receive" := ShipReceive; // P80046533
        ContainerHeader.Modify; // P80046533

        case ContainerHeader."Document Type" of
            DATABASE::"Sales Line":
                UpdateSalesForContainer(ContainerHeader, WarehouseDocType, WarehouseDocNo); // P8001323
            DATABASE::"Purchase Line":
                UpdatePurchaseForContainer(ContainerHeader, WarehouseDocType, WarehouseDocNo); // P8001323
            DATABASE::"Transfer Line":
                UpdateTransferForContainer(ContainerHeader, WarehouseDocType, WarehouseDocNo); // P8001323
            DATABASE::"Prod. Order Component":
                UpdateProductionForContainer(ContainerHeader); // P80056709
        end;

        ContainerHeader.Modify;
    end;

    procedure ConfirmRemoveContainerFromOrder(ContainerHeader: Record "Container Header"; var DeleteContainer: Boolean): Boolean
    var
        ConfirmMsg: Text;
    begin
        // P80046533
        DeleteContainer := false;

        // P800142458
        if IsOKToRemoveAssignment(ContainerHeader, 0) then begin
            if CheckWhseRegisteredPickExists(ContainerHeader) then
                exit(Confirm(ConfirmOKToRemoveAssignment))
            else
                exit(true);
        end;
        // P800142458

        if ContainerHeader.Inbound then
            ConfirmMsg := Text021
        else
            ConfirmMsg := Text013;

        if not Confirm(ConfirmMsg) then
            exit(false);

        DeleteContainer := true;
        exit(true);
    end;

    procedure RemoveContainerFromOrder(ContainerID: Code[20]; WarehouseDocType: Integer; WarehouseDocNo: Code[20]): Boolean
    var
        ContainerHeader: Record "Container Header";
        ContainerHeader2: Record "Container Header";
        ContainerLineAppl: Record "Container Line Application";
        DeleteContainer: Boolean;
    begin
        // P8001324
        ContainerHeader.Get(ContainerID);
        ContainerHeader.TestField("Ship/Receive", false); // P80046533

        // P80046533
        if not ConfirmRemoveContainerFromOrder(ContainerHeader, DeleteContainer) then
            exit(false)
        else
            if DeleteContainer then begin
                ContainerHeader.Delete(true);
                exit(true);
            end;
        // P80046533

        ContainerLineAppl.SetCurrentKey("Container ID");
        ContainerLineAppl.SetRange("Container ID", ContainerHeader.ID);

        ContainerHeader2 := ContainerHeader;
        ContainerHeader."Document Type" := 0;
        ContainerHeader."Document Subtype" := 0;
        ContainerHeader."Document No." := '';
        ContainerHeader."Document Line No." := 0; // P80056709
        ContainerHeader."Document Ref. No." := 0;
        ContainerHeader."Whse. Document Type" := 0;
        ContainerHeader."Whse. Document No." := '';
        ContainerHeader."Ship/Receive" := false; // P80046533
        ContainerHeader."Transfer-to Bin Code" := '';
        ContainerHeader.Modify;

        // P80046533
        case ContainerHeader2."Document Type" of
            DATABASE::"Sales Line":
                DeleteContainerFromSales(ContainerHeader2, ContainerHeader2."Whse. Document Type", ContainerHeader2."Whse. Document No.");
            DATABASE::"Purchase Line":
                DeleteContainerFromPurchase(ContainerHeader2, ContainerHeader2."Whse. Document Type", ContainerHeader2."Whse. Document No.");
            DATABASE::"Transfer Line":
                DeleteContainerFromTransfer(ContainerHeader2, ContainerHeader2."Whse. Document Type", ContainerHeader2."Whse. Document No.");
        end;
        // P80046533

        ContainerLineAppl.DeleteAll(true); // P800046533

        exit(true);
    end;

    procedure DeleteContainerFromOrder(var ContainerHeader: Record "Container Header")
    var
        ContainerHeader2: Record "Container Header";
        ContainerLineAppl: Record "Container Line Application";
    begin
        // P8001324
        // P80046533
        if (ContainerHeader."Document Type" = DATABASE::"Transfer Line") and (ContainerHeader."Document Subtype" = 1) then
            Error(Text003);
        // P80046533
        ContainerHeader.TestField("Ship/Receive", false); // P80046533
        if ContainerHeader."Document Type" <> 0 then begin
            ContainerLineAppl.SetCurrentKey("Container ID");
            ContainerLineAppl.SetRange("Container ID", ContainerHeader.ID);

            ContainerHeader2 := ContainerHeader;
            ContainerHeader."Document Type" := 0;
            ContainerHeader."Document Subtype" := 0;
            ContainerHeader."Document No." := '';
            ContainerHeader."Document Line No." := 0; // P80056709
            ContainerHeader."Pending Assignment" := false;
            ContainerHeader."Document Ref. No." := 0;
            ContainerHeader."Whse. Document Type" := 0;
            ContainerHeader."Whse. Document No." := '';
            ContainerHeader."Ship/Receive" := false; // P80046533
            ContainerHeader."Transfer-to Bin Code" := '';
            ContainerHeader.Modify;

            // P80046533
            case ContainerHeader2."Document Type" of
                DATABASE::"Sales Line":
                    DeleteContainerFromSales(ContainerHeader2, ContainerHeader2."Whse. Document Type", ContainerHeader2."Whse. Document No.");
                DATABASE::"Purchase Line":
                    DeleteContainerFromPurchase(ContainerHeader2, ContainerHeader2."Whse. Document Type", ContainerHeader2."Whse. Document No.");
                DATABASE::"Transfer Line":
                    DeleteContainerFromTransfer(ContainerHeader2, ContainerHeader2."Whse. Document Type", ContainerHeader2."Whse. Document No.");
            end;
            // P80046533

            ContainerLineAppl.DeleteAll(true); // P80046533
        end;
    end;

    local procedure CreateContainerLineApplication(var ContainerLine: Record "Container Line"; WarehouseDocType: Integer; WarehouseDocNo: Code[20]; ApplicationTable: Integer; ApplicationSubType: Integer; ApplicationDocumentNo: Code[20]; ApplicationLineNo: Integer; LineQuantity: Decimal; ShipReceive: Boolean; SpecificTracking: Boolean) ProcessLine: Boolean
    var
        Item: Record Item;
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        ContainerLineAppl: Record "Container Line Application";
        xContainerLineAppl: Record "Container Line Application";
        UpdateDocLine: Codeunit "Update Document Line";
        LineQuantityBase: Decimal;
        LineQuantityAlt: Decimal;
        LineFactor: Decimal;
    begin
        // P80046533
        if LineQuantity > 0 then begin
            if LineQuantity >= ContainerLine.Quantity then begin
                LineQuantity := ContainerLine.Quantity;
                LineQuantityBase := ContainerLine."Quantity (Base)";
                LineQuantityAlt := ContainerLine."Quantity (Alt.)";
            end else begin
                LineFactor := LineQuantity / ContainerLine.Quantity;
                LineQuantityBase := Round(ContainerLine."Quantity (Base)" * LineFactor, 0.00001);
                if ContainerLine."Quantity (Alt.)" <> 0 then begin
                    Item.Get(ContainerLine."Item No.");
                    Item.GetItemUOMRndgPrecision(Item."Alternate Unit of Measure", true);
                    LineQuantityAlt := Round(ContainerLine."Quantity (Alt.)" * LineFactor, Item."Rounding Precision");
                end;
            end;

            ContainerLineAppl."Application Table No." := ApplicationTable;
            ContainerLineAppl."Application Subtype" := ApplicationSubType;
            ContainerLineAppl."Application No." := ApplicationDocumentNo;
            ContainerLineAppl."Application Line No." := ApplicationLineNo;
            ContainerLineAppl."Container ID" := ContainerLine."Container ID";
            ContainerLineAppl."Container Line No." := ContainerLine."Line No.";
            if ContainerLineAppl.Find then begin
                ContainerLineAppl.Quantity += LineQuantity;
                ContainerLineAppl."Quantity (Base)" += LineQuantityBase;
                ContainerLineAppl."Quantity (Alt.)" += LineQuantityAlt;
                ContainerLineAppl.SetParameters(ContainerLine, ShipReceive, SpecificTracking, RegisteringPick); //P80075420
                xContainerLineAppl := ContainerLineAppl;
                ContainerLineAppl.Modify(true);
            end else begin
                ContainerLineAppl.Quantity := LineQuantity;
                ContainerLineAppl."Quantity (Base)" := LineQuantityBase;
                ContainerLineAppl."Quantity (Alt.)" := LineQuantityAlt;
                ContainerLineAppl.SetParameters(ContainerLine, ShipReceive, SpecificTracking, RegisteringPick); //P80075420
                xContainerLineAppl := ContainerLineAppl;
                ContainerLineAppl.Insert(true);
            end;

            ContainerLine.Quantity -= LineQuantity - xContainerLineAppl.Quantity + ContainerLineAppl.Quantity;
            ContainerLine."Quantity (Base)" -= LineQuantityBase - xContainerLineAppl."Quantity (Base)" + ContainerLineAppl."Quantity (Base)";
            ContainerLine."Quantity (Alt.)" -= LineQuantityAlt - xContainerLineAppl."Quantity (Alt.)" + ContainerLineAppl."Quantity (Alt.)";
        end;
    end;

    procedure UpdateContainerShipReceive(var ContainerHeader: Record "Container Header"; Receive: Boolean; Posting: Boolean)
    var
        Location: Record Location;
        TransferHeader: Record "Transfer Header";
    begin
        // P80046533
        if (ContainerHeader."Document Type" = DATABASE::"Transfer Line") and (ContainerHeader."Document Subtype" = 1) then begin
            TransferHeader.Get(ContainerHeader."Document No.");
            Location.Get(TransferHeader."Transfer-to Code");
        end else
            if ContainerHeader."Location Code" <> '' then
                Location.Get(ContainerHeader."Location Code");
        if (ContainerHeader.Inbound and Location."Require Receive") or
          ((not ContainerHeader.Inbound) and Location."Require Shipment")
        then
            ContainerHeader.TestField("Whse. Document No.");

        case ContainerHeader."Document Type" of
            DATABASE::"Sales Line":
                UpdateSalesReceiveForContainer(ContainerHeader, ContainerHeader."Ship/Receive");
            DATABASE::"Purchase Line":
                UpdatePurchaseReceiveForContainer(ContainerHeader, ContainerHeader."Ship/Receive");
            DATABASE::"Transfer Line":
                UpdateTransferReceiveForContainer(ContainerHeader, ContainerHeader."Ship/Receive", false);
        end;
    end;

    procedure ContainersInUse(ContNo: Code[20]; ContSerialNo: Code[50]; LocationCode: Code[10]; BinCode: Code[20]): Decimal
    var
        ContainerHeader: Record "Container Header";
    begin
        // P8000140A - add parameter for container serial no.
        // P8000631A - add parameter for BinCode
        ContainerHeader.SetCurrentKey("Container Item No.", "Container Serial No.", "Location Code"); // P8000140A
        ContainerHeader.SetRange("Container Item No.", ContNo);
        if ContSerialNo <> '' then                             // P8000140A
            ContainerHeader.SetRange("Container Serial No.", ContSerialNo); // P8000140A
        //IF LocationCode <> '' THEN // PR3.70.03
        ContainerHeader.SetRange("Location Code", LocationCode);
        exit(ContainerHeader.Count);
    end;

    procedure ContainersAtLocation(ContNo: Code[20]; ContSerialNo: Code[50]; LocationCode: Code[10]; BinCode: Code[20]): Decimal
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        // P8000140A - add parameter for container serial no.
        // P8000631A - add parameter for BinCode
        // P8001342
        //IF (BinCode <> '') THEN                                                    // P8000631A
        //  EXIT(ContainersAtLocationBin(ContNo,ContSerialNo,LocationCode,BinCode)); // P8000631A
        // P8001342
        ItemLedgerEntry.SetCurrentKey("Item No.", "Variant Code", "Location Code", "Lot No.", "Serial No."); // P8000140A
        ItemLedgerEntry.SetRange("Item No.", ContNo);
        if ContSerialNo <> '' then                             // P8000140A
            ItemLedgerEntry.SetRange("Serial No.", ContSerialNo); // P8000140A
        //IF LocationCode <> '' THEN // PR3.70.03
        ItemLedgerEntry.SetRange("Location Code", LocationCode);
        ItemLedgerEntry.CalcSums(Quantity);
        exit(ItemLedgerEntry.Quantity);
    end;

    procedure InsertContainerCharges(SalesLine: Record "Sales Line") Updated: Boolean
    var
        ToSalesLine: Record "Sales Line";
        ContCharge: Record "Container Charge";
        ItemContCharge: Record "Container Type Charge";
    begin
        // InsertContainerCharges
        if SalesLine.Type <> SalesLine.Type::FOODContainer then
            exit;

        ToSalesLine.SetRange("Document Type", SalesLine."Document Type");
        ToSalesLine.SetRange("Document No.", SalesLine."Document No.");
        ToSalesLine.SetRange("Container Line No.", SalesLine."Line No.");
        if ToSalesLine.Find('-') then begin
            Updated := true;
            ToSalesLine.DeleteAll;
        end;

        ItemContCharge.SetRange("Container Type Code", ContainerItemNo2Type(SalesLine."No.")); // P80053241
        ItemContCharge.SetFilter("Account No.", '<>%1', '');
        if ItemContCharge.Find('-') then begin
            ToSalesLine."Document Type" := SalesLine."Document Type";
            ToSalesLine."Document No." := SalesLine."Document No.";
            ToSalesLine."Line No." := SalesLine."Line No.";
            repeat
                ContCharge.Get(ItemContCharge."Container Charge Code");
                ToSalesLine.Init;
                ToSalesLine."Line No." += 1;
                ToSalesLine.SuspendStatusCheck(true); // P8001357
                ToSalesLine.Validate(Type, ToSalesLine.Type::"G/L Account");
                ToSalesLine.Validate("No.", ItemContCharge."Account No.");
                ToSalesLine.Description := ContCharge.Description;
                ToSalesLine.Validate("Location Code", SalesLine."Location Code"); // P8001323
                ToSalesLine.Validate("Unit Price", ItemContCharge."Unit Price");
                ToSalesLine.Validate(Quantity, SalesLine.Quantity);               // P8001323
                ToSalesLine.Validate("Qty. to Ship", SalesLine."Qty. to Ship");   // P8001323
                ToSalesLine."Container Line No." := SalesLine."Line No.";
                ToSalesLine.Insert;
            until ItemContCharge.Next = 0;
            Updated := true;
        end;
    end;

    procedure EditSalesLineLocation(SalesLine: Record "Sales Line")
    var
        SalesLine2: Record "Sales Line";
        ContainerHeader: Record "Container Header";
        Text001: Label '%1 cannot be changed while containers have been assigned.';
    begin
        // EditSalesLineLocation
        // P8001324
        ContainerHeader.SetRange("Container Item No.", SalesLine."No.");
        ContainerHeader.SetRange("Document Type", DATABASE::"Sales Line");
        ContainerHeader.SetRange("Document Subtype", SalesLine."Document Type");
        ContainerHeader.SetRange("Document No.", SalesLine."Document No.");
        ContainerHeader.SetRange("Document Ref. No.", SalesLine."Line No.");
        if not ContainerHeader.IsEmpty then
            // P8001324
            Error(Text001, SalesLine.FieldCaption("Location Code"));

        SalesLine2.SetRange("Document Type", SalesLine."Document Type");
        SalesLine2.SetRange("Document No.", SalesLine."Document No.");
        SalesLine2.SetRange("Container Line No.", SalesLine."Line No.");
        if SalesLine2.Find('-') then
            repeat
                SalesLine2."Location Code" := SalesLine."Location Code";
                SalesLine2."Bin Code" := SalesLine."Bin Code"; // P8000631A
                SalesLine2.Modify;
            until SalesLine2.Next = 0;
    end;

    procedure EditPurchaseLineLocation(PurchLine: Record "Purchase Line")
    var
        ContainerHeader: Record "Container Header";
        Text001: Label '%1 cannot be changed while containers have been assigned.';
    begin
        //P8001373
        ContainerHeader.SetRange("Container Item No.", PurchLine."No.");
        ContainerHeader.SetRange("Document Type", DATABASE::"Purchase Line");
        ContainerHeader.SetRange("Document Subtype", PurchLine."Document Type");
        ContainerHeader.SetRange("Document No.", PurchLine."Document No.");
        ContainerHeader.SetRange("Document Ref. No.", PurchLine."Line No.");
        if not ContainerHeader.IsEmpty then
            Error(Text001, PurchLine.FieldCaption("Location Code"));
        //P8001373
    end;

    procedure CloseContainerForPostedDocument(SourceRec: Variant; LocationCode: Code[10]; var TempWarehouseShipmentHeader: Record "Warehouse Shipment Header"; var TempWarehouseReceiptHeader: Record "Warehouse Receipt Header")
    var
        SourceRecRef: RecordRef;
        ContainerHeader: Record "Container Header";
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        TransHeader: Record "Transfer Header";
        PostedDocType: Integer;
        PostedDocNo: Code[20];
        OkToClose: Boolean;
    begin
        // P8001290
        SourceRecRef.GetTable(SourceRec);

        case SourceRecRef.Number of
            DATABASE::"Sales Header":
                begin
                    SalesHeader := SourceRec;
                    ContainerHeader.SetRange("Document Type", DATABASE::"Sales Line");
                    ContainerHeader.SetRange("Document Subtype", SalesHeader."Document Type");
                    ContainerHeader.SetRange("Document No.", SalesHeader."No.");
                    PostedDocType := DATABASE::"Sales Shipment Line";
                    PostedDocNo := SalesHeader."Last Shipping No.";
                end;
            DATABASE::"Purchase Header":
                begin
                    PurchHeader := SourceRec;
                    ContainerHeader.SetRange("Document Type", DATABASE::"Purchase Line");
                    ContainerHeader.SetRange("Document Subtype", PurchHeader."Document Type");
                    ContainerHeader.SetRange("Document No.", PurchHeader."No.");
                    PostedDocType := DATABASE::"Return Shipment Line";
                    PostedDocNo := PurchHeader."Last Return Shipment No.";
                end;
        end;

        ContainerHeader.SetRange("Ship/Receive", true); // P80046533
        if LocationCode <> '' then
            ContainerHeader.SetRange("Location Code", LocationCode);
        if ContainerHeader.FindSet then
            repeat
                // P80097092
                case ContainerHeader."Whse. Document Type" of
                    ContainerHeader."Whse. Document Type"::Shipment:
                        begin
                            TempWarehouseShipmentHeader.SetRange("No.", ContainerHeader."Whse. Document No.");
                            OkToClose := not TempWarehouseShipmentHeader.IsEmpty;
                        end;
                    ContainerHeader."Whse. Document Type"::Receipt:
                        begin
                            TempWarehouseReceiptHeader.SetRange("No.", ContainerHeader."Whse. Document No.");
                            OkToClose := not TempWarehouseReceiptHeader.IsEmpty;
                        end;
                    else
                        OkToClose := true;
                end;

                if OkToClose then
                    // P80097092
                    if ContainerHeader.Inbound then
                        ClearInbound(ContainerHeader)
                    else
                        CloseContainer(ContainerHeader, PostedDocType, PostedDocNo);
            until ContainerHeader.Next = 0;
    end;

    local procedure ClearInbound(var ContainerHeader: Record "Container Header")
    var
        ContainerLine: Record "Container Line";
        ContainerLineAppl: Record "Container Line Application";
    begin
        ContainerHeader."Document Type" := 0;
        ContainerHeader."Document Subtype" := 0;
        ContainerHeader."Document No." := '';
        ContainerHeader."Document Line No." := 0; // P80056709
        ContainerHeader."Document Ref. No." := 0;
        ContainerHeader."Whse. Document Type" := 0;
        ContainerHeader."Whse. Document No." := '';
        ContainerHeader."Transfer-to Bin Code" := '';
        ContainerHeader."Ship/Receive" := false;

        if ContainerHeader.Inbound then begin
            ContainerLine.SetRange("Container ID", ContainerHeader.ID);
            ContainerLine.ModifyAll(Inbound, false);
        end;

        ContainerHeader.Inbound := false;
        ContainerHeader.Inbound := not IsOKToRemoveAssignment(ContainerHeader, 0);
        ContainerHeader.Modify;

        ContainerLineAppl.SetRange("Container ID", ContainerHeader.ID);
        ContainerLineAppl.DeleteAll;
    end;

    local procedure CloseContainer(ContainerHdr: Record "Container Header"; DocType: Integer; DocNo: Code[20])
    var
        ContainerLine: Record "Container Line";
        ContainerLineAppl: Record "Container Line Application";
        ContainerCommentLine: Record "Container Comment Line";
        ClosedContainerHdr: Record "Shipped Container Header";
        ClosedContainerLine: Record "Shipped Container Line";
        ContainerCommentLine2: Record "Container Comment Line";
    begin
        // CloseContainer
        // P8000140A - add parameters to indicate if usage should be posted and posting data
        // P8001290 - remove parameters for PostUsage, Date, ExtDocNo, SourceCode
        // P8001324 - remove parameter for OrderNo, replace ClosingTrans with DocType
        ClosedContainerHdr.TransferFields(ContainerHdr);
        ClosedContainerHdr."Document Type" := DocType; // P8001324
        ClosedContainerHdr."Document No." := DocNo;
        ClosedContainerHdr."Item No." := GetClosedContainerItemNo(ContainerHdr.ID); // P800117005
        ClosedContainerHdr.Insert;

        ContainerLine.SetRange("Container ID", ContainerHdr.ID);
        if ContainerLine.Find('-') then
            repeat
                ClosedContainerLine.TransferFields(ContainerLine);
                ClosedContainerLine."Document Type" := DocType;
                ClosedContainerLine."Document No." := DocNo;
                ClosedContainerLine.Insert;
                if DocType <> DATABASE::"Transfer Shipment Line" then
                    ContainerLine.Delete
                // P80067617
                else begin
                    ContainerLine."Quantity Posted" := 0;
                    ContainerLine."Quantity Posted (Base)" := 0;
                    ContainerLine."Quantity Posted (Alt.)" := 0;
                    ContainerLine.Modify;
                end;
            // P80067617
            until ContainerLine.Next = 0;

        if DocType <> DATABASE::"Transfer Shipment Line" then begin
            ContainerCommentLine.SetRange(Status, ContainerCommentLine.Status::Open);
            ContainerCommentLine.SetRange("Container ID", ContainerHdr.ID);
            if ContainerCommentLine.Find('-') then
                repeat
                    ContainerCommentLine2 := ContainerCommentLine;
                    ContainerCommentLine2.Status := ContainerCommentLine2.Status::Closed;
                    ContainerCommentLine2.Insert;
                    ContainerCommentLine.Delete;
                until ContainerCommentLine.Next = 0;

            ContainerLineAppl.SetRange("Container ID", ContainerHdr.ID);
            ContainerLineAppl.DeleteAll;

            ContainerHdr.Delete; // PR3.60.01
        end;
    end;

    procedure ContainersFromDocument(SourceRec: Variant)
    var
        SourceRecRef: RecordRef;
        Location: Record Location;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        TransHeader: Record "Transfer Header";
        TransLine: Record "Transfer Line";
        ProductionOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        WarehouseReceipt: Record "Warehouse Receipt Header";
        WarehouseShipment: Record "Warehouse Shipment Header";
        ContainerAssignment: Page "Container Assignments";
        DefaultNumber: Integer;
        Selection: Integer;
    begin
        SourceRecRef.GetTable(SourceRec);

        case SourceRecRef.Number of
            DATABASE::"Sales Header":
                begin
                    SalesHeader := SourceRec;
                    ContainerAssignment.SetSource(DATABASE::"Sales Line", SalesHeader."Document Type", SalesHeader."No.", 0, 0, SalesHeader."Location Code", ''); // P80056709
                end;
            DATABASE::"Sales Line":
                begin
                    SalesLine := SourceRec;
                    if SalesLine.Type <> SalesLine.Type::FOODContainer then
                        exit;
                    ContainerAssignment.SetSource(DATABASE::"Sales Line", SalesLine."Document Type", SalesLine."Document No.", 0, SalesLine."Line No.", // P80056709
                      SalesLine."Location Code", SalesLine."No.");
                end;
            DATABASE::"Purchase Header":
                begin
                    PurchHeader := SourceRec;
                    ContainerAssignment.SetSource(DATABASE::"Purchase Line", PurchHeader."Document Type", PurchHeader."No.", 0, 0, PurchHeader."Location Code", ''); // P80056709
                end;
            DATABASE::"Purchase Line":
                begin
                    PurchLine := SourceRec;
                    if PurchLine.Type <> PurchLine.Type::FOODContainer then
                        exit;
                    ContainerAssignment.SetSource(DATABASE::"Purchase Line", PurchLine."Document Type", PurchLine."Document No.", 0, PurchLine."Line No.", // P80056709
                      PurchLine."Location Code", PurchLine."No.");
                end;
            DATABASE::"Transfer Header":
                begin
                    TransHeader := SourceRec;
                    TransLine.SetRange("Document No.", TransHeader."No.");
                    if TransLine.FindSet then
                        repeat
                            if TransLine."Quantity Shipped" < TransLine.Quantity then
                                DefaultNumber := 1
                            else
                                if TransLine."Quantity Received" < TransLine.Quantity then
                                    DefaultNumber := 2;
                        until (TransLine.Next = 0) or (DefaultNumber > 0);
                    if DefaultNumber = 0 then
                        DefaultNumber := 1;
                    Selection := StrMenu(Text019, DefaultNumber);
                    case Selection of
                        0:
                            exit;
                        1:
                            ContainerAssignment.SetSource(DATABASE::"Transfer Line", 0, TransHeader."No.", 0, 0, TransHeader."Transfer-from Code", ''); // P80056709
                        2:
                            ContainerAssignment.SetSource(DATABASE::"Transfer Line", 1, TransHeader."No.", 0, 0, TransHeader."Transfer-to Code", '');   // P80056709
                    end;
                end;
            DATABASE::"Transfer Line":
                begin
                    TransLine := SourceRec;
                    if TransLine.Type <> TransLine.Type::Container then
                        exit;
                    if TransLine."Quantity Shipped" < TransLine.Quantity then
                        DefaultNumber := 1
                    else
                        if TransLine."Quantity Received" < TransLine.Quantity then
                            DefaultNumber := 2;
                    if DefaultNumber = 0 then
                        DefaultNumber := 1;
                    Selection := StrMenu(Text019, DefaultNumber);
                    case Selection of
                        0:
                            exit;
                        1:
                            ContainerAssignment.SetSource(DATABASE::"Transfer Line", 0, TransLine."Document No.", 0, TransLine."Line No.", TransLine."Transfer-from Code", TransLine."Item No."); // P80056709
                        2:
                            ContainerAssignment.SetSource(DATABASE::"Transfer Line", 1, TransLine."Document No.", 0, TransLine."Line No.", TransLine."Transfer-to Code", TransLine."Item No.");  // P80056709
                    end;
                end;
            DATABASE::"Warehouse Receipt Header", DATABASE::"Warehouse Shipment Header":
                ContainerAssignment.SetWarehouseDoc(SourceRec);
            // P80056709
            DATABASE::"Production Order":
                begin
                    ProductionOrder := SourceRec;
                    if ProductionOrder."Location Code" <> '' then
                        Location.Get(ProductionOrder."Location Code");
                    if Location."Pick Production by Line" then
                        Error(Text030, Location.TableCaption, Location.Code);
                    ContainerAssignment.SetSource(DATABASE::"Prod. Order Component", ProductionOrder.Status, ProductionOrder."No.", 0, 0, ProductionOrder."Location Code", ''); // P80056709
                end;
            DATABASE::"Prod. Order Line":
                begin
                    ProdOrderLine := SourceRec;
                    ProductionOrder.Get(ProductionOrder.Status::Released, ProdOrderLine."Prod. Order No.");
                    if ProductionOrder."Location Code" <> '' then
                        Location.Get(ProductionOrder."Location Code");
                    if not Location."Pick Production by Line" then
                        Error(Text031, Location.TableCaption, Location.Code);
                    ContainerAssignment.SetSource(DATABASE::"Prod. Order Component", ProdOrderLine.Status, ProdOrderLine."Prod. Order No.", ProdOrderLine."Line No.", 0, // P80056709
                      ProductionOrder."Location Code", '');
                end;
        // P80056709
        end;
        ContainerAssignment.RunModal;
    end;

    procedure UpdateSalesForContainer(var ContainerHeader: Record "Container Header"; WarehouseDocType: Integer; WarehouseDocNo: Code[20])
    var
        ContainerLine: Record "Container Line";
        ContainerType: Record "Container Type";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SerialNo: Record "Serial No. Information";
        QtyToHandle: Decimal;
    begin
        // UpdateSalesOrderForContainer
        // P8001324, replace parameter for Container Transaction with ContainerHeader
        if ContainerHeader.Inbound and (ContainerHeader."Container Serial No." <> '') then begin
            SalesHeader.Get(ContainerHeader."Document Subtype", ContainerHeader."Document No.");
            SerialNo.Get(ContainerHeader."Container Item No.", '', ContainerHeader."Container Serial No.");
            if SerialNo.OffSiteSourceTypeInt <> 1 then
                Error(Text016);
            if SerialNo.OffSiteSourceNo <> SalesHeader."Sell-to Customer No." then
                Error(Text018, SerialNo.OffSiteSourceNo);
        end;

        ContainerLine.SetRange("Container ID", ContainerHeader.ID);                          // P8001324
        ContainerLine.SetFilter(Quantity, '>0');                                             // P8001324
        if ContainerLine.FindSet then                                                       // P8001324
            repeat
                UpdateSalesForContainerLine(ContainerHeader, ContainerLine, WarehouseDocType, WarehouseDocNo); // P8001324, P8001323
            until ContainerLine.Next = 0;

        ContainerType.Get(ContainerHeader."Container Type Code");
        if ContainerType.TrackInventory then begin
            //ContainerHeader.GET(ContainerTrans."Container ID"); // P8001324
            if ContainerHeader."Document Ref. No." = 0 then begin // P8001324
                SalesLine.SetRange("Document Type", ContainerHeader."Document Subtype"); // P8001324
                SalesLine.SetRange("Document No.", ContainerHeader."Document No.");      // P8001324
                SalesLine.SetRange(Type, SalesLine.Type::FOODContainer);
                SalesLine.SetRange("No.", ContainerHeader."Container Item No.");         // P8001324
                SalesLine.SetRange("Location Code", ContainerHeader."Location Code");    // P8001324
                if SalesLine.FindFirst then
                    ContainerHeader."Document Ref. No." := SalesLine."Line No." // P8001324
                else begin
                    SalesLine.SetRange(Type);
                    SalesLine.SetRange("No.");
                    SalesLine.SetRange("Location Code"); // P8001324
                    SalesLine.LockTable;
                    if SalesLine.Find('+') then
                        ContainerHeader."Document Ref. No." := SalesLine."Line No." + 10000 // P8001324
                    else
                        ContainerHeader."Document Ref. No." := 10000;                       // P8001324
                    SalesLine.Reset;
                    SalesLine.Init;
                    SalesLine.SuspendStatusCheck(true); // P8001357
                    SalesLine."Document Type" := ContainerHeader."Document Subtype"; // P8001324
                    SalesLine."Document No." := ContainerHeader."Document No.";      // P8001324
                    SalesLine."Line No." := ContainerHeader."Document Ref. No.";     // P8001324
                    SalesLine.Validate(Type, SalesLine.Type::FOODContainer);
                    SalesLine.Validate("No.", ContainerHeader."Container Item No.");
                    SalesLine.Validate("Location Code", ContainerHeader."Location Code"); // P8001324
                    SalesLine.Insert(true);
                    if not ContainerHeader.Inbound then
                        InsertContainerCharges(SalesLine);
                end;
            end;

            SalesLine.Reset;
            SalesLine.SetRange("Document Type", ContainerHeader."Document Subtype");       // P8001324
            SalesLine.SetRange("Document No.", ContainerHeader."Document No.");            // P8001324
            SalesLine.SetRange("Container Line No.", ContainerHeader."Document Ref. No."); // P8001324
            if SalesLine.FindSet(true) then // P8001323
                repeat
                    SalesLine.SuspendStatusCheck(true); // P8001357
                                                        // P80046533
                    if ContainerHeader.Inbound then
                        QtyToHandle := SalesLine."Return Qty. to Receive"
                    else
                        QtyToHandle := SalesLine."Qty. to Ship";
                    SalesLine.Validate(Quantity, SalesLine.Quantity + 1);
                    if WarehouseDocType = 0 then begin
                        if ContainerHeader."Ship/Receive" then
                            QtyToHandle += 1;
                    end else
                        QtyToHandle := 0;
                    if ContainerHeader.Inbound then
                        SalesLine.Validate("Return Qty. to Receive", QtyToHandle)
                    else
                        SalesLine.Validate("Qty. to Ship", QtyToHandle);
                    SalesLine.Modify;
                // P80046533
                until SalesLine.Next = 0;

            SalesLine.Get(ContainerHeader."Document Subtype", ContainerHeader."Document No.", ContainerHeader."Document Ref. No."); // P8001324
            SalesLine.TestField("No.", ContainerHeader."Container Item No.");
            SalesLine.SuspendStatusCheck(true); //
                                                // P80046533
            if ContainerHeader.Inbound then
                QtyToHandle := SalesLine."Return Qty. to Receive"
            else
                QtyToHandle := SalesLine."Qty. to Ship";
            SalesLine.Validate(Quantity, SalesLine.Quantity + 1);
            if WarehouseDocType = 0 then begin
                if ContainerHeader."Ship/Receive" then
                    QtyToHandle += 1;
            end else
                QtyToHandle := 0;
            if ContainerHeader.Inbound then
                SalesLine.Validate("Return Qty. to Receive", QtyToHandle)
            else
                SalesLine.Validate("Qty. to Ship", QtyToHandle);
            SalesLine.Modify;
            if ContainerHeader."Ship/Receive" then
                InsertContTrackingForSalesLine(SalesLine, ContainerHeader); // P8000140A, P8001324
                                                                            // P80046533
        end;
    end;

    local procedure UpdateSalesForContainerLine(ContainerHeader: Record "Container Header"; ContainerLine: Record "Container Line"; WarehouseDocType: Integer; WarehouseDocNo: Code[20])
    var
        SalesLine: Record "Sales Line";
        Text001: Label 'Container %1 has already been assigned.';
        Text002: Label '%1 does not have sufficient quantity of item %2.';
        Text003: Label 'Lot %1 fails to meet established lot preferences.';
        Location: Record Location;
        UpdateDocLine: Codeunit "Update Document Line";
        LineQuantity: Decimal;
        SpecificTracking: Boolean;
        ProcessLine: Boolean;
    begin
        // P8001324
        if not Location.Get(ContainerHeader."Location Code") then // P80053245
            Clear(Location);                                        // P80053245
        if (not ContainerHeader.Inbound) and (not RegisteringPick) then // P8001323
            Location.TestField("Require Pick", false);

        SalesLine.SetRange("Document Type", ContainerHeader."Document Subtype");
        SalesLine.SetRange("Document No.", ContainerHeader."Document No.");
        // P80046533
        if ContainerLine."Document Line No." <> 0 then
            SalesLine.SetRange("Line No.", ContainerLine."Document Line No.")
        else begin
            // P80046533
            SalesLine.SetRange(Type, SalesLine.Type::Item);
            SalesLine.SetRange("No.", ContainerLine."Item No.");
            SalesLine.SetRange("Variant Code", ContainerLine."Variant Code");
            SalesLine.SetRange("Location Code", ContainerHeader."Location Code");
            SalesLine.SetRange("Unit of Measure Code", ContainerLine."Unit of Measure Code");
        end; // P80046533

        for SpecificTracking := ((ContainerLine."Lot No." <> '') or (ContainerLine."Serial No." <> '')) downto false do // P80046533
            if ContainerLine.Quantity <> 0 then // P80075420
                if SalesLine.FindSet(true) then // P8001324
                    repeat
                        // P80046533
                        ProcessLine := ContainerHeader."Bin Code" = SalesLine.GetWarehouseDocumentBin(WarehouseDocNo);
                        if ProcessLine then begin
                            if SalesLine."Document Type" = SalesLine."Document Type"::Order then
                                LineQuantity := UpdateDocLine.FreeQuantity(SalesLine, 0, ContainerLine."Lot No.", SpecificTracking)
                            else
                                LineQuantity := UpdateDocLine.FreeQuantity(SalesLine, 1, ContainerLine."Lot No.", SpecificTracking);
                            CreateContainerLineApplication(ContainerLine, WarehouseDocType, WarehouseDocNo,
                              DATABASE::"Sales Line", SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.",
                              LineQuantity, ContainerHeader."Ship/Receive", SpecificTracking);
                            // P80060004
                            if (LineQuantity > 0) and (ContainerLine."Lot No." <> '') then begin
                                SalesLine.Find; // P80063375
                                SalesLine.GetLotNo;
                                SalesLine.Modify;
                            end;
                            // P80060004
                        end;
                    // P80046533
                    until (SalesLine.Next = 0) or (ContainerLine.Quantity = 0);

        if ContainerLine.Quantity > 0 then begin
            SalesLine."Document Type" := ContainerHeader."Document Subtype";
            Error(Text002, SalesLine."Document Type", ContainerLine."Item No.");
        end;

        // P80046533
        if ContainerLine."Document Line No." <> 0 then begin
            ContainerLine.Find;
            ContainerLine."Document Line No." := 0;
            ContainerLine.Modify;
        end;
        // P80046533
    end;

    local procedure UpdateSalesReceiveForContainer(var ContainerHeader: Record "Container Header"; ShipReceive: Boolean)
    var
        SalesLine: Record "Sales Line";
        ContainerLineAppl: Record "Container Line Application";
        ContainerLine: Record "Container Line";
        Qty: Decimal;
    begin
        // P80046533
        if ContainerHeader."Document Ref. No." <> 0 then begin
            if ShipReceive then
                Qty := 1
            else
                Qty := -1;
            SalesLine.Reset;
            SalesLine.SetRange("Document Type", ContainerHeader."Document Subtype");       // P8001324
            SalesLine.SetRange("Document No.", ContainerHeader."Document No.");            // P8001324
            SalesLine.SetRange("Container Line No.", ContainerHeader."Document Ref. No."); // P8001324
            if SalesLine.FindSet(true) then // P8001323
                repeat
                    if ContainerHeader."Whse. Document Type" = 0 then begin
                        SalesLine.SuspendStatusCheck(true);
                        if ContainerHeader.Inbound then
                            SalesLine.Validate("Return Qty. to Receive", SalesLine."Return Qty. to Receive" + Qty)
                        else
                            SalesLine.Validate("Qty. to Ship", SalesLine."Qty. to Ship" + Qty);
                        SalesLine.Modify;
                    end;
                until SalesLine.Next = 0;

            SalesLine.Get(ContainerHeader."Document Subtype", ContainerHeader."Document No.", ContainerHeader."Document Ref. No.");
            SalesLine.TestField("No.", ContainerHeader."Container Item No.");
            if ContainerHeader."Whse. Document Type" = 0 then begin
                SalesLine.SuspendStatusCheck(true);
                if ContainerHeader.Inbound then
                    SalesLine.Validate("Return Qty. to Receive", SalesLine."Return Qty. to Receive" + Qty)
                else
                    SalesLine.Validate("Qty. to Ship", SalesLine."Qty. to Ship" + Qty);
                SalesLine.Modify;
            end;
            if ShipReceive then
                InsertContTrackingForSalesLine(SalesLine, ContainerHeader)
            else
                DeleteContTrackingForSalesLine(SalesLine, ContainerHeader);
        end;

        ContainerLineAppl.SetRange("Container ID", ContainerHeader.ID);
        if ContainerLineAppl.FindSet then
            repeat
                ContainerLine.Get(ContainerLineAppl."Container ID", ContainerLineAppl."Container Line No.");
                ContainerLineAppl.SetParameters(ContainerLine, ShipReceive, false, RegisteringPick); //P80075420
                ContainerLineAppl.UpdateShipReceive(ShipReceive);
                ;
            until ContainerLineAppl.Next = 0;
    end;

    local procedure DeleteContainerFromSales(ContainerHeader: Record "Container Header"; WarehouseDocType: Integer; WarehouseDocNo: Code[20])
    var
        SalesLine: Record "Sales Line";
        QtyToHandle: Decimal;
    begin
        // P8001324, replace Container Transaction record parameter with ContainerHeader
        if ContainerHeader."Document Ref. No." <> 0 then begin
            SalesLine.Reset;
            SalesLine.SetRange("Document Type", ContainerHeader."Document Subtype");       // P8001324
            SalesLine.SetRange("Document No.", ContainerHeader."Document No.");            // P8001324
            SalesLine.SetRange("Container Line No.", ContainerHeader."Document Ref. No."); // P8001324
            if SalesLine.FindSet(true) then // P8001323
                repeat
                    SalesLine.SuspendStatusCheck(true); // P8001357
                                                        // P80046533
                    if ContainerHeader.Inbound then
                        QtyToHandle := SalesLine."Return Qty. to Receive"
                    else
                        QtyToHandle := SalesLine."Qty. to Ship";
                    SalesLine.Validate(Quantity, SalesLine.Quantity - 1);
                    if WarehouseDocType = 0 then begin
                        if ContainerHeader."Ship/Receive" then
                            QtyToHandle -= 1;
                    end else
                        QtyToHandle := 0;
                    if ContainerHeader.Inbound then
                        SalesLine.Validate("Return Qty. to Receive", QtyToHandle)
                    else
                        SalesLine.Validate("Qty. to Ship", QtyToHandle);
                    SalesLine.Modify;
                until SalesLine.Next = 0;

            SalesLine.Get(ContainerHeader."Document Subtype", ContainerHeader."Document No.", ContainerHeader."Document Ref. No."); // P8001324
            SalesLine.SuspendStatusCheck(true); // P8001357
                                                // P80046533
            if ContainerHeader.Inbound then
                QtyToHandle := SalesLine."Return Qty. to Receive"
            else
                QtyToHandle := SalesLine."Qty. to Ship";
            SalesLine.Validate(Quantity, SalesLine.Quantity - 1);
            if WarehouseDocType = 0 then begin
                if ContainerHeader."Ship/Receive" then
                    QtyToHandle -= 1;
            end else
                QtyToHandle := 0;
            if ContainerHeader.Inbound then
                SalesLine.Validate("Return Qty. to Receive", QtyToHandle)
            else
                SalesLine.Validate("Qty. to Ship", QtyToHandle);
            SalesLine.Modify;
            if ContainerHeader."Ship/Receive" then
                DeleteContTrackingForSalesLine(SalesLine, ContainerHeader); // P8000140A, P8001324
                                                                            // P80046533
        end;
    end;

    local procedure InsertContTrackingForSalesLine(SalesLine: Record "Sales Line"; ContainerHeader: Record "Container Header")
    var
        ContainerType: Record "Container Type";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
    begin
        // P8000140A
        // P8001324, Replace parameter for Container Transaction with ContainerHeader
        // P80046533 - made local
        if (ContainerHeader."Container Serial No." = '') then // P8000631A, P8001324
            exit;                                               // P8000631A
        ContainerType.Get(ContainerHeader."Container Type Code");                                              // P8001324
        if ContainerType."Container Sales Processing" <> ContainerType."Container Sales Processing"::Sale then // P8001324
            exit;

        CreateReservEntry.CreateReservEntryFor(
          DATABASE::"Sales Line", SalesLine."Document Type", SalesLine."Document No.", '', 0, SalesLine."Line No.",
          1, 1, 1, ContainerHeader."Container Serial No.", ''); // P8000325A, P8000466A, P8001132, P8001324
        if ContainerHeader.Inbound then
            CreateReservEntry.CreateEntry(
              ContainerHeader."Container Item No.", '', SalesLine."Location Code", '', SalesLine."Shipment Date", 0D, 0, 2)
        else
            CreateReservEntry.CreateEntry(
              ContainerHeader."Container Item No.", '', SalesLine."Location Code", '', 0D, SalesLine."Shipment Date", 0, 2); // P8001324
    end;

    local procedure DeleteContTrackingForSalesLine(SalesLine: Record "Sales Line"; ContainerHeader: Record "Container Header")
    var
        ContainerType: Record "Container Type";
        ResEntry: Record "Reservation Entry";
    begin
        // P8000140A
        // P8001324, replace parameter for Container Transaction with ContainerHeader
        // P80046533 - made local
        if (ContainerHeader."Container Serial No." = '') then // P8000631A, P8001324
            exit;                                              // P8000631A
        ContainerType.Get(ContainerHeader."Container Type Code"); // P8001324
        if ContainerType."Container Sales Processing" <> ContainerType."Container Sales Processing"::Sale then // P8001324
            exit;
        ResEntry.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name",
          "Source Prod. Order Line", "Source Ref. No.");
        ResEntry.SetRange("Source Type", DATABASE::"Sales Line");
        ResEntry.SetRange("Source Subtype", SalesLine."Document Type");
        ResEntry.SetRange("Source ID", SalesLine."Document No.");
        ResEntry.SetRange("Source Batch Name", '');
        ResEntry.SetRange("Source Prod. Order Line", 0);
        ResEntry.SetRange("Source Ref. No.", SalesLine."Line No.");
        ResEntry.SetRange("Serial No.", ContainerHeader."Container Serial No."); // P8001324
        ResEntry.DeleteAll;
    end;

    procedure PostSalesContainerLine(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; SalesShptHeader: Record "Sales Shipment Header"; ReturnRcptHeader: Record "Return Receipt Header"; SrcCode: Code[10]; var ItemJnlLine: Record "Item Journal Line"): Boolean
    var
        Item: Record Item;
        ContainerType: Record "Container Type";
        ItemTrackingCode: Record "Item Tracking Code";
        InvSetup: Record "Inventory Setup";
        ContainerHeader: Record "Container Header";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        DimMgt: Codeunit DimensionManagement;
        QtyToShip: Decimal;
        QtyToShipBase: Decimal;
    begin
        // PostSalesContainerLine
        // PR3.61.01 - added ItemJnlLine and TempJnlLineDim to parameter list
        // P8001133 - remove parameters TempDocDim and TempJnlLineDim
        with SalesLine do begin
            if "Document Type" in ["Document Type"::Order, "Document Type"::Invoice] then begin
                QtyToShip := -"Qty. to Ship";
                QtyToShipBase := -"Qty. to Ship (Base)";
            end else begin
                QtyToShip := "Return Qty. to Receive";
                QtyToShipBase := "Return Qty. to Receive (Base)";
            end;
            if QtyToShip = 0 then
                exit(false); // PR3.61.01

            Item.Get("No.");
            ContainerType.SetRange("Container Item No.", "No."); // P8001290
            ContainerType.FindFirst;                            // P8001290

            ItemJnlLine.Init;
            ItemJnlLine."Posting Date" := SalesHeader."Posting Date";
            ItemJnlLine."Document Date" := SalesHeader."Document Date";
            ItemJnlLine."Source Posting Group" := SalesHeader."Customer Posting Group";
            ItemJnlLine."Salespers./Purch. Code" := SalesHeader."Salesperson Code";
            ItemJnlLine."Country/Region Code" := SalesHeader."VAT Country/Region Code";
            ItemJnlLine."Reason Code" := SalesHeader."Reason Code";
            ItemJnlLine."Posting No. Series" := SalesHeader."Posting No. Series";
            ItemJnlLine."Item No." := "No.";
            ItemJnlLine.Description := Description;
            ItemJnlLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
            ItemJnlLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
            ItemJnlLine."Dimension Set ID" := "Dimension Set ID"; // P8001133
            ItemJnlLine."Location Code" := "Location Code";
            ItemJnlLine."Bin Code" := "Bin Code";
            ItemJnlLine."Variant Code" := "Variant Code";
            ItemJnlLine."Inventory Posting Group" := "Posting Group";
            ItemJnlLine."Gen. Bus. Posting Group" := "Gen. Bus. Posting Group";
            ItemJnlLine."Gen. Prod. Posting Group" := "Gen. Prod. Posting Group";
            ItemJnlLine."Transaction Type" := "Transaction Type";
            ItemJnlLine."Transport Method" := "Transport Method";
            ItemJnlLine."Entry/Exit Point" := "Exit Point";
            ItemJnlLine.Area := Area;
            ItemJnlLine."Transaction Specification" := "Transaction Specification";
            ItemJnlLine."Drop Shipment" := "Drop Shipment";
            case ContainerType."Container Sales Processing" of
                ContainerType."Container Sales Processing"::Adjustment: // P8001290
                    if "Document Type" in ["Document Type"::Order, "Document Type"::Invoice] then
                        ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::"Negative Adjmt."
                    else
                        ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::"Positive Adjmt.";
                ContainerType."Container Sales Processing"::Transfer: // P8001290
                    begin
                        InvSetup.Get;
                        InvSetup.TestField("Offsite Cont. Location Code");
                        ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::Transfer;
                        if "Document Type" in ["Document Type"::Order, "Document Type"::Invoice] then
                            ItemJnlLine."New Location Code" := InvSetup."Offsite Cont. Location Code"
                        else begin
                            ItemJnlLine."Location Code" := InvSetup."Offsite Cont. Location Code";
                            ItemJnlLine."New Location Code" := "Location Code";
                        end;
                    end;
            end;
            ItemJnlLine."Unit of Measure Code" := "Unit of Measure Code";
            ItemJnlLine."Qty. per Unit of Measure" := "Qty. per Unit of Measure";
            ItemJnlLine."Item Category Code" := "Item Category Code";
            ItemJnlLine."Supply Chain Group Code" := "Supply Chain Group Code"; // P8000931
            ItemJnlLine."Return Reason Code" := "Return Reason Code";
            ItemJnlLine."Planned Delivery Date" := "Planned Delivery Date";
            ItemJnlLine."Order Date" := SalesHeader."Order Date";

            if "Document Type" in ["Document Type"::"Return Order", "Document Type"::"Credit Memo"] then begin
                ItemJnlLine."Document No." := ReturnRcptHeader."No.";
                ItemJnlLine."External Document No." := ReturnRcptHeader."External Document No.";
            end else begin
                ItemJnlLine."Document No." := SalesShptHeader."No.";
                ItemJnlLine."External Document No." := SalesShptHeader."External Document No.";
            end;
            ItemJnlLine.Quantity := QtyToShip;
            ItemJnlLine."Quantity (Base)" := QtyToShipBase;
            ItemJnlLine."Invoiced Quantity" := QtyToShip;
            ItemJnlLine."Invoiced Qty. (Base)" := QtyToShipBase;
            ItemJnlLine."Unit Cost" := "Unit Cost (LCY)";
            ItemJnlLine."Source Currency Code" := SalesHeader."Currency Code";
            ItemJnlLine."Unit Cost (ACY)" := "Unit Cost";
            ItemJnlLine."Value Entry Type" := ItemJnlLine."Value Entry Type"::"Direct Cost";
            ItemJnlLine."Source Type" := ItemJnlLine."Source Type"::Customer;
            ItemJnlLine."Source No." := "Sell-to Customer No.";
            ItemJnlLine."Source Code" := SrcCode;
            //ItemJnlLine."Skip Container Posting" := TRUE; // P8001087
            // P8000140A
            if ItemTrackingCode.Get(Item."Item Tracking Code") and ItemTrackingCode."SN Specific Tracking" then begin
                // P8001324
                ContainerHeader.SetRange("Document Type", DATABASE::"Sales Line");
                ContainerHeader.SetRange("Document Subtype", SalesLine."Document Type");
                ContainerHeader.SetRange("Document No.", SalesLine."Document No.");
                ContainerHeader.SetRange("Document Ref. No.", SalesLine."Line No.");
                if ContainerHeader.FindSet then
                    // P8001324
                    repeat
                        CreateReservEntry.CreateReservEntryFor(
                          DATABASE::"Item Journal Line",
                          ItemJnlLine."Entry Type", ItemJnlLine."Journal Template Name", ItemJnlLine."Journal Batch Name",
                          0, ItemJnlLine."Line No.", ItemJnlLine."Qty. per Unit of Measure",
                          1, 1, ContainerHeader."Container Serial No.", ''); // P8000325A, P8000466A, P8001132, P8001324
                        CreateReservEntry.SetNewSerialLotNo(ContainerHeader."Container Serial No.", ''); // P8001324
                        CreateReservEntry.CreateEntry(
                          ItemJnlLine."Item No.", ItemJnlLine."Variant Code", ItemJnlLine."Location Code",
                          ItemJnlLine.Description, 0D, ItemJnlLine."Posting Date", 0, 2);
                    until ContainerHeader.Next = 0; // P8001324
            end;
            // P8000140A
            //ReserveSalesLine.TransferSalesLineToItemJnlLine(SalesLine,ItemJnlLine,QtyToShipBase); // P8000140A
            // P8000140A Begin
            if ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Transfer then
            // P8001133
            begin
                ItemJnlLine."Shortcut Dimension 1 Code" := ItemJnlLine."New Shortcut Dimension 1 Code";
                ItemJnlLine."Shortcut Dimension 2 Code" := ItemJnlLine."New Shortcut Dimension 2 Code";
                ItemJnlLine."Dimension Set ID" := ItemJnlLine."New Dimension Set ID";
            end;
            // P8001133
            // P8000140A End
            //  ItemJnlPostLine.RunWithCheck(ItemJnlLine,TempJnlLineDim); // PR3.61.01

            exit(true); // PR3.61.01
        end;
    end;

    procedure UpdatePurchaseForContainer(var ContainerHeader: Record "Container Header"; WarehouseDocType: Integer; WarehouseDocNo: Code[20])
    var
        ContainerLine: Record "Container Line";
        ContainerType: Record "Container Type";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        SerialNo: Record "Serial No. Information";
        QtyToHandle: Decimal;
    begin
        //P8001373
        if ContainerHeader.Inbound and (ContainerHeader."Container Serial No." <> '') then begin
            PurchHeader.Get(ContainerHeader."Document Subtype", ContainerHeader."Document No.");
            SerialNo.Get(ContainerHeader."Container Item No.", '', ContainerHeader."Container Serial No.");
            if SerialNo.OffSiteSourceTypeInt <> 2 then
                Error(Text017);
            if SerialNo.OffSiteSourceNo <> PurchHeader."Buy-from Vendor No." then
                Error(Text018, SerialNo.OffSiteSourceNo);
        end;

        ContainerLine.SetRange("Container ID", ContainerHeader.ID);
        ContainerLine.SetFilter(Quantity, '>0');
        if ContainerLine.FindSet then
            repeat
                UpdatePurchaseForContainerLine(ContainerHeader, ContainerLine, WarehouseDocType, WarehouseDocNo); // P8001323
            until ContainerLine.Next = 0;

        ContainerType.Get(ContainerHeader."Container Type Code");
        if ContainerType.TrackInventory then begin
            if ContainerHeader."Document Ref. No." = 0 then begin
                PurchLine.SetRange("Document Type", ContainerHeader."Document Subtype");
                PurchLine.SetRange("Document No.", ContainerHeader."Document No.");
                PurchLine.SetRange(Type, PurchLine.Type::FOODContainer);
                PurchLine.SetRange("No.", ContainerHeader."Container Item No.");
                PurchLine.SetRange("Location Code", ContainerHeader."Location Code");
                if PurchLine.FindFirst then
                    ContainerHeader."Document Ref. No." := PurchLine."Line No."
                else begin
                    PurchLine.SetRange(Type);
                    PurchLine.SetRange("No.");
                    PurchLine.SetRange("Location Code");
                    PurchLine.LockTable;
                    if PurchLine.Find('+') then
                        ContainerHeader."Document Ref. No." := PurchLine."Line No." + 10000
                    else
                        ContainerHeader."Document Ref. No." := 10000;
                    PurchLine.Reset;
                    PurchLine.Init;
                    PurchLine.SuspendStatusCheck(true);
                    PurchLine."Document Type" := ContainerHeader."Document Subtype";
                    PurchLine."Document No." := ContainerHeader."Document No.";
                    PurchLine."Line No." := ContainerHeader."Document Ref. No.";
                    PurchLine.Validate(Type, PurchLine.Type::FOODContainer);
                    PurchLine.Validate("No.", ContainerHeader."Container Item No.");
                    PurchLine.Validate("Location Code", ContainerHeader."Location Code");
                    PurchLine.Insert(true);
                end;
            end;

            PurchLine.Get(ContainerHeader."Document Subtype", ContainerHeader."Document No.", ContainerHeader."Document Ref. No.");
            PurchLine.TestField("No.", ContainerHeader."Container Item No.");
            PurchLine.SuspendStatusCheck(true);
            // P80046533
            if ContainerHeader.Inbound then
                QtyToHandle := PurchLine."Qty. to Receive"
            else
                QtyToHandle := PurchLine."Return Qty. to Ship";
            PurchLine.Validate(Quantity, PurchLine.Quantity + 1);
            if WarehouseDocType = 0 then begin
                if ContainerHeader."Ship/Receive" then
                    QtyToHandle += 1;
            end else
                QtyToHandle := 0;
            if ContainerHeader.Inbound then
                PurchLine.Validate("Qty. to Receive", QtyToHandle)
            else
                PurchLine.Validate("Return Qty. to Ship", QtyToHandle);
            PurchLine.Modify;
            if ContainerHeader."Ship/Receive" then
                InsertContTrackingForPurchaseLine(PurchLine, ContainerHeader);
            // P80046533
        end;
        //P8001373
    end;

    local procedure UpdatePurchaseForContainerLine(ContainerHeader: Record "Container Header"; ContainerLine: Record "Container Line"; WarehouseDocType: Integer; WarehouseDocNo: Code[20])
    var
        PurchLine: Record "Purchase Line";
        Location: Record Location;
        Text001: Label 'Container %1 has already been assigned.';
        Text002: Label '%1 does not have sufficient quantity of item %2.';
        Text003: Label 'Lot %1 fails to meet established lot preferences.';
        UpdateDocLine: Codeunit "Update Document Line";
        LineQuantity: Decimal;
        SpecificTracking: Boolean;
        ProcessLine: Boolean;
    begin
        //P8001373
        if not Location.Get(ContainerHeader."Location Code") then // P80053245
            Clear(Location);                                        // P80053245
        if (not ContainerHeader.Inbound) and (not RegisteringPick) then // P8001323
            Location.TestField("Require Pick", false);

        PurchLine.SetRange("Document Type", ContainerHeader."Document Subtype");
        PurchLine.SetRange("Document No.", ContainerHeader."Document No.");
        // P80046533
        if ContainerLine."Document Line No." <> 0 then
            PurchLine.SetRange("Line No.", ContainerLine."Document Line No.")
        else begin
            // P80046533
            PurchLine.SetRange(Type, PurchLine.Type::Item);
            PurchLine.SetRange("No.", ContainerLine."Item No.");
            PurchLine.SetRange("Variant Code", ContainerLine."Variant Code");
            PurchLine.SetRange("Location Code", ContainerHeader."Location Code");
            PurchLine.SetRange("Unit of Measure Code", ContainerLine."Unit of Measure Code");
        end; // P80046533

        for SpecificTracking := ((ContainerLine."Lot No." <> '') or (ContainerLine."Serial No." <> '')) downto false do // P80046533
            if ContainerLine.Quantity <> 0 then // P80075420
                if PurchLine.FindSet(true) then
                    repeat
                        // P80046533
                        ProcessLine := ContainerHeader."Bin Code" = PurchLine.GetWarehouseDocumentBin(WarehouseDocNo);
                        if ProcessLine then begin
                            if PurchLine."Document Type" = PurchLine."Document Type"::Order then
                                LineQuantity := UpdateDocLine.FreeQuantity(PurchLine, 1, ContainerLine."Lot No.", SpecificTracking)
                            else
                                LineQuantity := UpdateDocLine.FreeQuantity(PurchLine, 0, ContainerLine."Lot No.", SpecificTracking);
                            CreateContainerLineApplication(ContainerLine, WarehouseDocType, WarehouseDocNo,
                              DATABASE::"Purchase Line", PurchLine."Document Type", PurchLine."Document No.", PurchLine."Line No.",
                              LineQuantity, ContainerHeader."Ship/Receive", SpecificTracking);
                            // P80060004
                            if (LineQuantity > 0) and (ContainerLine."Lot No." <> '') then begin
                                PurchLine.Find; // P80063375
                                PurchLine.GetLotNo;
                                PurchLine.Modify;
                            end;
                            // P80060004
                        end;
                    // P80046533
                    until (PurchLine.Next = 0) or (ContainerLine.Quantity = 0);

        if ContainerLine.Quantity > 0 then begin
            PurchLine."Document Type" := ContainerHeader."Document Subtype";
            Error(Text002, PurchLine."Document Type", ContainerLine."Item No.");
        end;
        //P8001373

        // P80046533
        if ContainerLine."Document Line No." <> 0 then begin
            ContainerLine.Find;
            ContainerLine."Document Line No." := 0;
            ContainerLine.Modify;
        end;
        // P80046533
    end;

    local procedure UpdatePurchaseReceiveForContainer(var ContainerHeader: Record "Container Header"; ShipReceive: Boolean)
    var
        PurchaseLine: Record "Purchase Line";
        ContainerLineAppl: Record "Container Line Application";
        ContainerLine: Record "Container Line";
        Qty: Decimal;
    begin
        // P80046533
        if ContainerHeader."Document Ref. No." <> 0 then begin
            PurchaseLine.Get(ContainerHeader."Document Subtype", ContainerHeader."Document No.", ContainerHeader."Document Ref. No.");
            PurchaseLine.TestField("No.", ContainerHeader."Container Item No.");
            if ContainerHeader."Whse. Document Type" = 0 then begin
                PurchaseLine.SuspendStatusCheck(true);
                if ShipReceive then
                    Qty := 1
                else
                    Qty := -1;
                if ContainerHeader.Inbound then
                    PurchaseLine.Validate("Qty. to Receive", PurchaseLine."Qty. to Receive" + Qty)
                else
                    PurchaseLine.Validate("Return Qty. to Ship", PurchaseLine."Return Qty. to Ship" + Qty);
                PurchaseLine.Modify;
            end;
            if ShipReceive then
                InsertContTrackingForPurchaseLine(PurchaseLine, ContainerHeader)
            else
                DeleteContTrackingForPurchaseLine(PurchaseLine, ContainerHeader);
        end;

        ContainerLineAppl.SetRange("Container ID", ContainerHeader.ID);
        if ContainerLineAppl.FindSet then
            repeat
                ContainerLine.Get(ContainerLineAppl."Container ID", ContainerLineAppl."Container Line No.");
                ContainerLineAppl.SetParameters(ContainerLine, ShipReceive, false, RegisteringPick); //P80075420
                ContainerLineAppl.UpdateShipReceive(ShipReceive);
            until ContainerLineAppl.Next = 0;
    end;

    local procedure DeleteContainerFromPurchase(ContainerHeader: Record "Container Header"; WarehouseDocType: Integer; WarehouseDocNo: Code[20])
    var
        PurchLine: Record "Purchase Line";
        QtyToHandle: Decimal;
    begin
        //P8001373
        if ContainerHeader."Document Ref. No." <> 0 then begin
            PurchLine.Get(ContainerHeader."Document Subtype", ContainerHeader."Document No.", ContainerHeader."Document Ref. No.");
            PurchLine.SuspendStatusCheck(true);
            // P80046533
            if ContainerHeader.Inbound then
                QtyToHandle := PurchLine."Qty. to Receive"
            else
                QtyToHandle := PurchLine."Return Qty. to Ship";
            PurchLine.Validate(Quantity, PurchLine.Quantity - 1);
            if WarehouseDocType = 0 then begin
                if ContainerHeader."Ship/Receive" then
                    QtyToHandle -= 1;
            end else
                QtyToHandle := 0;
            if ContainerHeader.Inbound then
                PurchLine.Validate("Qty. to Receive", QtyToHandle)
            else
                PurchLine.Validate("Return Qty. to Ship", QtyToHandle);
            PurchLine.Modify;
            if ContainerHeader."Ship/Receive" then
                DeleteContTrackingForPurchaseLine(PurchLine, ContainerHeader);
            // P80046533
        end;
    end;

    local procedure InsertContTrackingForPurchaseLine(PurchLine: Record "Purchase Line"; ContainerHeader: Record "Container Header")
    var
        ContainerType: Record "Container Type";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
    begin
        //P8001373
        // P80046533 - made local
        if (ContainerHeader."Container Serial No." = '') then
            exit;
        ContainerType.Get(ContainerHeader."Container Type Code");
        if ContainerType."Container Purchase Processing" <> ContainerType."Container Purchase Processing"::Purchase then
            exit;

        CreateReservEntry.CreateReservEntryFor(
          DATABASE::"Purchase Line", PurchLine."Document Type", PurchLine."Document No.", '', 0, PurchLine."Line No.",
          1, 1, 1, ContainerHeader."Container Serial No.", '');
        if ContainerHeader.Inbound then
            CreateReservEntry.CreateEntry(
              ContainerHeader."Container Item No.", '', PurchLine."Location Code", '', PurchLine."Expected Receipt Date", 0D, 0, 2)
        else
            CreateReservEntry.CreateEntry(
              ContainerHeader."Container Item No.", '', PurchLine."Location Code", '', 0D, PurchLine."Expected Receipt Date", 0, 2);
        //P8001373
    end;

    local procedure DeleteContTrackingForPurchaseLine(PurchLine: Record "Purchase Line"; ContainerHeader: Record "Container Header")
    var
        ContainerType: Record "Container Type";
        ResEntry: Record "Reservation Entry";
    begin
        //P8001373
        // P80046533 - made local
        if (ContainerHeader."Container Serial No." = '') then
            exit;
        ContainerType.Get(ContainerHeader."Container Type Code");
        if ContainerType."Container Purchase Processing" <> ContainerType."Container Purchase Processing"::Purchase then
            exit;
        ResEntry.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name",
          "Source Prod. Order Line", "Source Ref. No.");
        ResEntry.SetRange("Source Type", DATABASE::"Purchase Line");
        ResEntry.SetRange("Source Subtype", PurchLine."Document Type");
        ResEntry.SetRange("Source ID", PurchLine."Document No.");
        ResEntry.SetRange("Source Batch Name", '');
        ResEntry.SetRange("Source Prod. Order Line", 0);
        ResEntry.SetRange("Source Ref. No.", PurchLine."Line No.");
        ResEntry.SetRange("Serial No.", ContainerHeader."Container Serial No.");
        ResEntry.DeleteAll;
        //P8001373
    end;

    procedure PostPurchaseContainerLine(PurchHeader: Record "Purchase Header"; PurchLine: Record "Purchase Line"; ReturnShptHeader: Record "Return Shipment Header"; PurchRcptHeader: Record "Purch. Rcpt. Header"; SrcCode: Code[10]; var ItemJnlLine: Record "Item Journal Line"): Boolean
    var
        Item: Record Item;
        ContainerType: Record "Container Type";
        ItemTrackingCode: Record "Item Tracking Code";
        InvSetup: Record "Inventory Setup";
        ContainerHeader: Record "Container Header";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        DimMgt: Codeunit DimensionManagement;
        QtyToShip: Decimal;
        QtyToShipBase: Decimal;
    begin
        //P8001373
        with PurchLine do begin
            if "Document Type" in ["Document Type"::"Return Order", "Document Type"::"Credit Memo"] then begin
                QtyToShip := -"Return Qty. to Ship";
                QtyToShipBase := -"Return Qty. to Ship (Base)";
            end else begin
                QtyToShip := "Qty. to Receive";
                QtyToShipBase := "Qty. to Receive (Base)";
            end;
            if QtyToShip = 0 then
                exit(false);

            Item.Get("No.");
            ContainerType.SetRange("Container Item No.", "No.");
            ContainerType.FindFirst;

            ItemJnlLine.Init;
            ItemJnlLine."Posting Date" := PurchHeader."Posting Date";
            ItemJnlLine."Document Date" := PurchHeader."Document Date";
            ItemJnlLine."Source Posting Group" := PurchHeader."Vendor Posting Group";
            ItemJnlLine."Salespers./Purch. Code" := PurchHeader."Purchaser Code";
            ItemJnlLine."Country/Region Code" := PurchHeader."VAT Country/Region Code";
            ItemJnlLine."Reason Code" := PurchHeader."Reason Code";
            ItemJnlLine."Posting No. Series" := PurchHeader."Posting No. Series";
            ItemJnlLine."Item No." := "No.";
            ItemJnlLine.Description := Description;
            ItemJnlLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
            ItemJnlLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
            ItemJnlLine."Dimension Set ID" := "Dimension Set ID";
            ItemJnlLine."Location Code" := "Location Code";
            ItemJnlLine."Bin Code" := "Bin Code";
            ItemJnlLine."Variant Code" := "Variant Code";
            ItemJnlLine."Inventory Posting Group" := "Posting Group";
            ItemJnlLine."Gen. Bus. Posting Group" := "Gen. Bus. Posting Group";
            ItemJnlLine."Gen. Prod. Posting Group" := "Gen. Prod. Posting Group";
            ItemJnlLine."Transaction Type" := "Transaction Type";
            ItemJnlLine."Transport Method" := "Transport Method";
            ItemJnlLine."Entry/Exit Point" := "Entry Point";
            ItemJnlLine.Area := Area;
            ItemJnlLine."Transaction Specification" := "Transaction Specification";
            ItemJnlLine."Drop Shipment" := "Drop Shipment";
            case ContainerType."Container Purchase Processing" of
                ContainerType."Container Purchase Processing"::Adjustment:
                    if "Document Type" in ["Document Type"::"Return Order", "Document Type"::"Credit Memo"] then
                        ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::"Negative Adjmt."
                    else
                        ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::"Positive Adjmt.";
                ContainerType."Container Sales Processing"::Transfer:
                    begin
                        InvSetup.Get;
                        InvSetup.TestField("Offsite Cont. Location Code");
                        ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::Transfer;
                        if "Document Type" in ["Document Type"::"Return Order", "Document Type"::"Credit Memo"] then
                            ItemJnlLine."New Location Code" := InvSetup."Offsite Cont. Location Code"
                        else begin
                            ItemJnlLine."Location Code" := InvSetup."Offsite Cont. Location Code";
                            ItemJnlLine."New Location Code" := "Location Code";
                        end;
                    end;
            end;
            ItemJnlLine."Unit of Measure Code" := "Unit of Measure Code";
            ItemJnlLine."Qty. per Unit of Measure" := "Qty. per Unit of Measure";
            ItemJnlLine."Item Category Code" := "Item Category Code";
            ItemJnlLine."Supply Chain Group Code" := "Supply Chain Group Code";
            ItemJnlLine."Return Reason Code" := "Return Reason Code";
            ItemJnlLine."Planned Delivery Date" := "Planned Receipt Date";
            ItemJnlLine."Order Date" := PurchHeader."Order Date";

            if "Document Type" in ["Document Type"::"Return Order", "Document Type"::"Credit Memo"] then
                ItemJnlLine."Document No." := ReturnShptHeader."No."
            else
                ItemJnlLine."Document No." := PurchRcptHeader."No.";
            ItemJnlLine.Quantity := QtyToShip;
            ItemJnlLine."Quantity (Base)" := QtyToShipBase;
            ItemJnlLine."Invoiced Quantity" := QtyToShip;
            ItemJnlLine."Invoiced Qty. (Base)" := QtyToShipBase;
            ItemJnlLine."Unit Cost" := "Unit Cost (LCY)";
            ItemJnlLine."Source Currency Code" := PurchHeader."Currency Code";
            ItemJnlLine."Unit Cost (ACY)" := "Unit Cost";
            ItemJnlLine."Value Entry Type" := ItemJnlLine."Value Entry Type"::"Direct Cost";
            ItemJnlLine."Source Type" := ItemJnlLine."Source Type"::Vendor;
            ItemJnlLine."Source No." := PurchHeader."Buy-from Vendor No.";
            ItemJnlLine."Source Code" := SrcCode;
            //ItemJnlLine."Skip Container Posting" := TRUE;
            if ItemTrackingCode.Get(Item."Item Tracking Code") and ItemTrackingCode."SN Specific Tracking" then begin
                ContainerHeader.SetRange("Document Type", DATABASE::"Purchase Line");
                ContainerHeader.SetRange("Document Subtype", PurchLine."Document Type");
                ContainerHeader.SetRange("Document No.", PurchLine."Document No.");
                ContainerHeader.SetRange("Document Ref. No.", PurchLine."Line No.");
                if ContainerHeader.FindSet then
                    repeat
                        CreateReservEntry.CreateReservEntryFor(
                          DATABASE::"Item Journal Line",
                          ItemJnlLine."Entry Type", ItemJnlLine."Journal Template Name", ItemJnlLine."Journal Batch Name",
                          0, ItemJnlLine."Line No.", ItemJnlLine."Qty. per Unit of Measure",
                          1, 1, ContainerHeader."Container Serial No.", '');
                        CreateReservEntry.SetNewSerialLotNo(ContainerHeader."Container Serial No.", '');
                        CreateReservEntry.CreateEntry(
                          ItemJnlLine."Item No.", ItemJnlLine."Variant Code", ItemJnlLine."Location Code",
                          ItemJnlLine.Description, 0D, ItemJnlLine."Posting Date", 0, 2);
                    until ContainerHeader.Next = 0;
            end;
            if ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Transfer then begin
                ItemJnlLine."Shortcut Dimension 1 Code" := ItemJnlLine."New Shortcut Dimension 1 Code";
                ItemJnlLine."Shortcut Dimension 2 Code" := ItemJnlLine."New Shortcut Dimension 2 Code";
                ItemJnlLine."Dimension Set ID" := ItemJnlLine."New Dimension Set ID";
            end;
            exit(true);
        end;
        //P8001373
    end;

    procedure UpdateTransferForContainer(var ContainerHeader: Record "Container Header"; WarehouseDocType: Integer; WarehouseDocNo: Code[20])
    var
        TransLine: Record "Transfer Line";
        ContainerLine: Record "Container Line";
        Text001: Label 'Container %1 has already been assigned.';
        ContainerType: Record "Container Type";
        QtyToHandle: Decimal;
    begin
        // UpdateTransOrderForContainer
        // P8001324, replace parameter for Container Transaction with ContainerHeader

        ContainerLine.SetRange("Container ID", ContainerHeader.ID);                          // P8001324
        ContainerLine.SetFilter(Quantity, '>0');                                             // P8001324
        if ContainerLine.FindSet then                                                       // P8001324
            repeat
                UpdateTransferForContainerLine(ContainerHeader, ContainerLine, WarehouseDocType, WarehouseDocNo); // P8001324, P8001323
            until ContainerLine.Next = 0;

        ContainerType.Get(ContainerHeader."Container Type Code");
        if ContainerType.TrackInventory then begin
            //  ContainerHeader.GET(ContainerTrans."Container ID"); // P8001324
            if ContainerHeader."Document Ref. No." = 0 then begin // P8001324
                TransLine.SetRange("Document No.", ContainerHeader."Document No.");      // P8001324
                TransLine.SetRange(Type, TransLine.Type::Container);
                TransLine.SetRange("Item No.", ContainerHeader."Container Item No.");    // P8001324
                if TransLine.Find('-') then
                    ContainerHeader."Document Ref. No." := TransLine."Line No." // P8001324
                else begin
                    TransLine.SetRange(Type);
                    TransLine.SetRange("Item No.");
                    TransLine.LockTable;
                    if TransLine.Find('+') then
                        ContainerHeader."Document Ref. No." := TransLine."Line No." + 10000 // P8001324
                    else
                        ContainerHeader."Document Ref. No." := 10000;                       // P8001324
                    TransLine.Reset;
                    TransLine.Init;
                    TransLine."Document No." := ContainerHeader."Document No.";      // P8001324
                    TransLine."Line No." := ContainerHeader."Document Ref. No.";     // P8001324
                    TransLine.Validate(Type, TransLine.Type::Container);
                    TransLine.Validate("Item No.", ContainerHeader."Container Item No.");
                    TransLine.Insert(true);
                end;
            end;

            TransLine.Get(ContainerHeader."Document No.", ContainerHeader."Document Ref. No."); // P8001324
            TransLine.TestField("Item No.", ContainerHeader."Container Item No.");
            // P80046533
            QtyToHandle := TransLine."Qty. to Ship";
            TransLine.Validate(Quantity, TransLine.Quantity + 1);
            if WarehouseDocType = 0 then begin
                if ContainerHeader."Ship/Receive" then
                    QtyToHandle += 1;
            end else
                QtyToHandle := 0;
            TransLine.Validate("Qty. to Ship", QtyToHandle);
            TransLine.Modify;
            if ContainerHeader."Ship/Receive" then
                InsertContTrackingForTransferLine(TransLine, ContainerHeader);
            // P80046533
        end;
    end;

    local procedure UpdateTransferForContainerLine(var ContainerHeader: Record "Container Header"; ContainerLine: Record "Container Line"; WarehouseDocType: Integer; WarehouseDocNo: Code[20])
    var
        Text002: Label 'Order does not have sufficient quantity of item %1.';
        Item: Record Item;
        TransLine: Record "Transfer Line";
        UpdateDocLine: Codeunit "Update Document Line";
        LineQuantity: Decimal;
        SpecificTracking: Boolean;
        ProcessLine: Boolean;
        TransToBinSet: Boolean;
    begin
        // P8001324
        // P8008287 - change BinCode to Code20
        TransLine.SetRange("Document No.", ContainerHeader."Document No.");
        // P80046533
        if ContainerLine."Document Line No." <> 0 then
            TransLine.SetRange("Line No.", ContainerLine."Document Line No.")
        else begin
            // P80046533
            TransLine.SetRange(Type, TransLine.Type::Item);
            TransLine.SetRange("Item No.", ContainerLine."Item No.");
            TransLine.SetRange("Variant Code", ContainerLine."Variant Code");
            TransLine.SetRange("Unit of Measure Code", ContainerLine."Unit of Measure Code");
        end; // P80046533

        for SpecificTracking := ((ContainerLine."Lot No." <> '') or (ContainerLine."Serial No." <> '')) downto false do // P80046533
            if ContainerLine.Quantity <> 0 then // P80075420
                if TransLine.FindSet(true) then
                    repeat
                        // P80046533
                        ProcessLine := ContainerHeader."Bin Code" = TransLine.GetWarehouseDocumentBin(0, WarehouseDocNo);
                        if ProcessLine then begin
                            LineQuantity := UpdateDocLine.FreeQuantity(TransLine, 0, ContainerLine."Lot No.", SpecificTracking);
                            if CreateContainerLineApplication(ContainerLine, WarehouseDocType, WarehouseDocNo,
                              DATABASE::"Transfer Line", 0, TransLine."Document No.", TransLine."Line No.",
                              LineQuantity, ContainerHeader."Ship/Receive", SpecificTracking)
                            then
                                if not TransToBinSet then begin
                                    ContainerHeader."Transfer-to Bin Code" := TransLine.GetWarehouseDocumentBin(1, WarehouseDocNo);
                                    TransLine.SetRange("Transfer-To Bin Code", ContainerHeader."Transfer-to Bin Code");
                                end;
                            // P80060004
                            if (LineQuantity > 0) and (ContainerLine."Lot No." <> '') then begin
                                TransLine.Find; // P80063375
                                TransLine.GetLotNo;
                                TransLine.Modify;
                            end;
                            // P80060004
                        end;
                    // P80046533
                    until (TransLine.Next = 0) or (ContainerLine.Quantity = 0);

        if ContainerLine.Quantity > 0 then
            Error(Text002, ContainerLine."Item No.");

        // P80046533
        if ContainerLine."Document Line No." <> 0 then begin
            ContainerLine.Find;
            ContainerLine."Document Line No." := 0;
            ContainerLine.Modify;
        end;
        // P80046533
    end;

    procedure UpdateTransferReceiveForContainer(var ContainerHeader: Record "Container Header"; ShipReceive: Boolean; Posting: Boolean)
    var
        ContainerLineAppl: Record "Container Line Application";
        ContainerLine: Record "Container Line";
        TransLine: Record "Transfer Line";
        Qty: Decimal;
    begin
        // P8001323
        // P80046533 - add parameter for ShipReceive
        if ContainerHeader."Document Ref. No." <> 0 then begin
            TransLine.Get(ContainerHeader."Document No.", ContainerHeader."Document Ref. No.");
            TransLine.TestField("Item No.", ContainerHeader."Container Item No.");
            if (not Posting) and (ContainerHeader."Whse. Document Type" = 0) then begin
                if ShipReceive then
                    Qty := 1
                else
                    Qty := -1;
                if ContainerHeader.Inbound then
                    TransLine.Validate("Qty. to Receive", TransLine."Qty. to Receive" + Qty)
                else
                    TransLine.Validate("Qty. to Ship", TransLine."Qty. to Ship" + Qty);
                TransLine.Modify;
            end;
            if ShipReceive then
                InsertContTrackingForTransferLine(TransLine, ContainerHeader)
            else
                DeleteContTrackingForTransferLine(TransLine, ContainerHeader);
        end;

        ContainerLineAppl.SetRange("Container ID", ContainerHeader.ID);
        if ContainerLineAppl.FindSet then
            repeat
                ContainerLine.Get(ContainerLineAppl."Container ID", ContainerLineAppl."Container Line No.");
                ContainerLineAppl.SetParameters(ContainerLine, ShipReceive, false, RegisteringPick); //P80075420
                ContainerLineAppl.UpdateShipReceive(ShipReceive);
            until ContainerLineAppl.Next = 0;
    end;

    local procedure DeleteContainerFromTransfer(ContainerHeader: Record "Container Header"; WarehouseDocType: Integer; WarehouseDocNo: Code[20])
    var
        TransLine: Record "Transfer Line";
        QtyToHandle: Decimal;
    begin
        // DeleteContainerFromTransOrder
        // P8001324, replace Container Transaction record parameter with ContainerHeader
        if ContainerHeader."Document Ref. No." <> 0 then begin
            TransLine.Get(ContainerHeader."Document No.", ContainerHeader."Document Ref. No."); // P8001324
                                                                                                // P80046533
            QtyToHandle := TransLine."Qty. to Ship";
            TransLine.Validate(Quantity, TransLine.Quantity - 1);
            if WarehouseDocNo = '' then
                if ContainerHeader."Ship/Receive" then
                    QtyToHandle -= 1
                else
                    QtyToHandle := 0;
            TransLine.Validate("Qty. to Ship", QtyToHandle);
            TransLine.Modify;
            if ContainerHeader."Ship/Receive" then
                DeleteContTrackingForTransferLine(TransLine, ContainerHeader); // P8000140A, P8001324
                                                                               // P80046533
        end;
    end;

    local procedure InsertContTrackingForTransferLine(TransLine: Record "Transfer Line"; ContainerHeader: Record "Container Header")
    var
        CreateReservEntry: Codeunit "Create Reserv. Entry";
    begin
        // P8000140A
        // P8001324, Replace parameter for Container Transaction with ContainerHeader
        // P80046533 - made local
        if (ContainerHeader."Container Serial No." = '') then // P8000631A, P8001324
            exit;                                               // P8000631A
        CreateReservEntry.CreateReservEntryFor(
          DATABASE::"Transfer Line", 0, TransLine."Document No.", '', 0, TransLine."Line No.",
          1, 1, 1, ContainerHeader."Container Serial No.", ''); // P8000325A, P8000466A, P8001132, P8001324
        CreateReservEntry.CreateEntry(
          ContainerHeader."Container Item No.", '', TransLine."Transfer-from Code", '', 0D, TransLine."Shipment Date", 0, 2); // P8001324

        // P8001324
        CreateReservEntry.CreateReservEntryFor(
          DATABASE::"Transfer Line", 1, TransLine."Document No.", '', 0, TransLine."Line No.", 1, 1, 1, ContainerHeader."Container Serial No.", '');
        CreateReservEntry.CreateEntry(
          ContainerHeader."Container Item No.", '', TransLine."Transfer-to Code", '', TransLine."Receipt Date", 0D, 0, 2);
        // P8001324
    end;

    local procedure DeleteContTrackingForTransferLine(TransLine: Record "Transfer Line"; ContainerHeader: Record "Container Header")
    var
        ResEntry: Record "Reservation Entry";
    begin
        // P8000140A
        // P8001324, replace parameter for Container Transaction with ContainerHeader
        // P80046533 - made local
        if (ContainerHeader."Container Serial No." = '') then // P8000631A, P8001324
            exit;                                              // P8000631A

        ResEntry.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.");
        ResEntry.SetRange("Source Type", DATABASE::"Transfer Line");
        //ResEntry.SETRANGE("Source Subtype",0); // P8001324
        ResEntry.SetRange("Source ID", TransLine."Document No.");
        ResEntry.SetRange("Source Batch Name", '');
        ResEntry.SetRange("Source Prod. Order Line", 0);
        ResEntry.SetRange("Source Ref. No.", TransLine."Line No.");
        ResEntry.SetRange("Serial No.", ContainerHeader."Container Serial No."); // P8001324
        ResEntry.DeleteAll;
    end;

    procedure PostTransContainerHeader(TransHeader: Record "Transfer Header"; Direction: Integer; PostedDocNo: Code[20])
    var
        ContainerHeader: Record "Container Header";
        TransLine: Record "Transfer Line";
        ContainerLineAppl: Record "Container Line Application";
        ContainerLineAppl2: Record "Container Line Application";
        Location: Record Location;
        NewLocation: Code[10];
        NewBin: Code[20];
    begin
        // P8001324
        // P80046533 - add parameter PostedDocNo
        ContainerHeader.SetRange("Document Type", DATABASE::"Transfer Line");
        ContainerHeader.SetRange("Document Subtype", Direction);
        ContainerHeader.SetRange("Document No.", TransHeader."No.");
        ContainerHeader.SetRange("Ship/Receive", true); // P80046533
        if Direction = 0 then begin
            NewLocation := TransHeader."In-Transit Code";
            NewBin := '';
        end else
            NewLocation := TransHeader."Transfer-to Code";
        Location.Get(TransHeader."Transfer-to Code");

        if ContainerHeader.FindSet(true) then
            repeat
                if Direction = 0 then
                    CloseContainer(ContainerHeader, DATABASE::"Transfer Shipment Line", PostedDocNo); // P80046533

                if Direction = 1 then
                    //NewBin := ContainerHeader."Transfer-to Bin Code"; // P8008651
                    ContainerHeader.GetTransferToBin(NewBin);           // P8008651
                ContainerHeader.Validate("Location Code", NewLocation);
                ContainerHeader.Validate("Bin Code", NewBin); // P8000631A
                ContainerHeader.Inbound := true;
                ContainerHeader."Document Subtype" := 1;
                ContainerHeader."Whse. Document Type" := 0;
                ContainerHeader."Whse. Document No." := '';
                ContainerHeader."Ship/Receive" := false; // P80046533
                if Direction = 0 then begin
                    ContainerLineAppl.SetRange("Container ID", ContainerHeader.ID); // P8001324
                    ContainerLineAppl.SetRange("Application Subtype", Direction);
                    if ContainerLineAppl.Find('-') then
                        repeat
                            ContainerLineAppl2 := ContainerLineAppl;
                            ContainerLineAppl2."Application Subtype" := 1;
                            ContainerLineAppl2.Insert;
                            ContainerLineAppl.Delete;
                        until ContainerLineAppl.Next = 0;
                end else
                    ClearInbound(ContainerHeader);
                if ContainerHeader.Modify then; // P80086371
            until ContainerHeader.Next = 0;
    end;

    procedure UpdateTransLineTrackingQtyToReceive(TransferLine: Record "Transfer Line")
    var
        ResEntry: Record "Reservation Entry";
        ResEntry2: Record "Reservation Entry";
        ContainerQtybyDocLine: Query "Container Qty. by Doc. Line";
        QtyToHandleBase: Decimal;
    begin
        // P80046533
        ResEntry.SetCurrentKey("Source Type", "Source ID", "Source Batch Name", "Source Ref. No.", "Lot No.", "Serial No.");
        ResEntry.SetRange("Source Type", DATABASE::"Transfer Line");
        ResEntry.SetRange("Source Subtype", 1);
        ResEntry.SetRange("Source ID", TransferLine."Document No.");
        ResEntry.SetRange("Source Prod. Order Line", TransferLine."Line No.");
        if ResEntry.FindSet(true) then
            repeat
                ResEntry.SetRange("Lot No.", ResEntry."Lot No.");
                ResEntry.SetRange("Serial No.", ResEntry."Serial No.");
                ContainerQtybyDocLine.SetRange(ApplicationTableNo, DATABASE::"Transfer Line");
                ContainerQtybyDocLine.SetRange(ApplicationSubtype, 1);
                ContainerQtybyDocLine.SetRange(ApplicationNo, TransferLine."Document No.");
                ContainerQtybyDocLine.SetRange(ApplicationLineNo, TransferLine."Line No.");
                ContainerQtybyDocLine.SetRange(LotNo, ResEntry."Lot No.");
                ContainerQtybyDocLine.SetRange(SerialNo, ResEntry."Serial No.");
                if ContainerQtybyDocLine.Open then begin
                    QtyToHandleBase := 0; // P80063018
                    while ContainerQtybyDocLine.Read do
                        QtyToHandleBase += ContainerQtybyDocLine.SumQuantityBase;
                    ResEntry2.Copy(ResEntry);
                    ResEntry2.CalcSums("Quantity (Base)");
                    ResEntry2."Quantity (Base)" -= QtyToHandleBase;
                    if ResEntry2."Quantity (Base)" <= 0 then begin
                        ResEntry.ModifyAll("Qty. to Handle (Base)", 0);
                        ResEntry.ModifyAll("Qty. to Invoice (Base)", 0);
                        ResEntry.FindLast;
                    end else
                        repeat
                            if ResEntry."Quantity (Base)" < ResEntry2."Quantity (Base)" then
                                QtyToHandleBase := ResEntry."Quantity (Base)"
                            else
                                QtyToHandleBase := ResEntry2."Quantity (Base)";
                            ResEntry2."Quantity (Base)" -= QtyToHandleBase;
                            ResEntry."Qty. to Handle (Base)" := QtyToHandleBase;
                            ResEntry."Qty. to Invoice (Base)" := QtyToHandleBase;
                            ResEntry.Modify;
                        until ResEntry.Next = 0;
                end else
                    ResEntry.FindLast;
                ResEntry.SetRange("Lot No.");
                ResEntry.SetRange("Serial No.");
            until ResEntry.Next = 0;
    end;

    procedure UpdateProductionForContainer(var ContainerHeader: Record "Container Header")
    var
        Location: Record Location;
        ContainerLine: Record "Container Line";
    begin
        // P80056709
        if ContainerHeader."Location Code" <> '' then
            Location.Get(ContainerHeader."Location Code");

        if Location."Pick Production by Line" and (ContainerHeader."Document Line No." = 0) then
            Error(Text027);
        if (not Location."Pick Production by Line") and (ContainerHeader."Document Line No." <> 0) then
            Error(Text028);

        ContainerLine.SetRange("Container ID", ContainerHeader.ID);
        ContainerLine.SetFilter(Quantity, '>0');
        if ContainerLine.FindSet then
            repeat
                UpdateProductionForContainerLine(ContainerHeader, ContainerLine);
            until ContainerLine.Next = 0;
    end;

    local procedure UpdateProductionForContainerLine(ContainerHeader: Record "Container Header"; ContainerLine: Record "Container Line")
    var
        ItemFixedProdBin: Record "Item Fixed Prod. Bin";
        LotNoInformation: Record "Lot No. Information";
        LotStatusCode: Record "Lot Status Code";
        ProdOrderComponent: Record "Prod. Order Component";
        LotPreferenceOK: Boolean;
    begin
        // P80056709
        ItemFixedProdBin.SetRange("Item No.", ContainerLine."Item No.");
        ItemFixedProdBin.SetRange("Location Code", ContainerLine."Location Code");
        if not ItemFixedProdBin.IsEmpty then
            Error(Text022, ContainerLine."Item No.");

        if ContainerLine."Lot No." <> '' then begin
            LotNoInformation.Get(ContainerLine."Item No.", ContainerLine."Variant Code", ContainerLine."Lot No.");
            if LotNoInformation."Lot Status Code" <> '' then begin
                LotStatusCode.Get(LotNoInformation."Lot Status Code");
                if not LotStatusCode."Available for Consumption" then
                    Error(Text024, ContainerLine."Lot No.", ContainerLine."Item No.");
            end;
        end;

        ProdOrderComponent.SetRange(Status, ContainerHeader."Document Subtype");
        ProdOrderComponent.SetRange("Prod. Order No.", ContainerHeader."Document No.");
        if ContainerHeader."Document Line No." <> 0 then
            ProdOrderComponent.SetRange("Prod. Order Line No.", ContainerHeader."Document Line No.");
        ProdOrderComponent.SetRange("Item No.", ContainerLine."Item No.");
        ProdOrderComponent.SetRange("Variant Code", ContainerLine."Variant Code");
        ProdOrderComponent.SetRange("Location Code", ContainerLine."Location Code");
        if not ProdOrderComponent.FindSet then
            Error(Text023, ContainerLine."Item No.", ContainerHeader."Document No.");

        if ContainerLine."Lot No." <> '' then begin
            repeat
                LotPreferenceOK := ProdOrderComponent.CheckLotPreferences(ContainerLine."Lot No.", false);
            until (ContainerLine.Next = 0) or LotPreferenceOK;

            if not LotPreferenceOK then
                Error(Text025, ContainerLine."Lot No.", ContainerLine."Item No.");
        end;

        if ContainerLine."Document Line No." <> 0 then begin
            ContainerLine."Document Line No." := 0;
            ContainerLine.Modify;
        end;
    end;

    procedure CreatePickFromProductionContainer(SourceRec: Variant; LocationCode: Code[10]; ToBinCode: Code[20]; TotalQtyToPick: Decimal; var TempContainerLine: Record "Container Line" temporary)
    var
        ContainerHeader: Record "Container Header";
        ContainerLine: Record "Container Line";
        ProdOrderComponent: Record "Prod. Order Component";
        WhseWorksheetLine: Record "Whse. Worksheet Line";
        Location: Record Location;
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        SourceRecRef: RecordRef;
        QtyToPick: Decimal;
    begin
        // P80056710
        TempContainerLine.Reset;
        TempContainerLine.DeleteAll;

        SourceRecRef.GetTable(SourceRec);

        case SourceRecRef.Number of
            DATABASE::"Prod. Order Component":
                ProdOrderComponent := SourceRec;
            DATABASE::"Whse. Worksheet Line":
                begin
                    WhseWorksheetLine := SourceRec;
                    ProdOrderComponent.Get(WhseWorksheetLine."Source Subtype", WhseWorksheetLine."Source No.",
                      WhseWorksheetLine."Source Line No.", WhseWorksheetLine."Source Subline No.");
                end;
        end;

        Location.Get(LocationCode);
        Item.Get(ProdOrderComponent."Item No.");
        if Item."Item Tracking Code" <> '' then
            ItemTrackingCode.Get(Item."Item Tracking Code");

        ContainerHeader.SetRange("Location Code", LocationCode);
        ContainerHeader.SetFilter("Bin Code", '<>%1', ToBinCode);
        ContainerHeader.SetRange("Document Type", DATABASE::"Prod. Order Component");
        ContainerHeader.SetRange("Document Subtype", ProdOrderComponent.Status);
        ContainerHeader.SetRange("Document No.", ProdOrderComponent."Prod. Order No.");
        if Location."Pick Production by Line" then
            ContainerHeader.SetRange("Document Line No.", ProdOrderComponent."Prod. Order Line No.");
        ContainerHeader.SetRange("Pending Assignment", false);
        if ContainerHeader.FindSet then begin
            ContainerLine.SetCurrentKey("Item No.", "Variant Code", "Unit of Measure Code", "Lot No.");
            repeat
                TempProdContainerLine.Reset;

                ContainerLine.SetRange("Container ID", ContainerHeader.ID);
                ContainerLine.SetRange("Item No.", ProdOrderComponent."Item No.");
                ContainerLine.SetRange("Variant Code", ProdOrderComponent."Variant Code");
                ContainerLine.SetRange("Unit of Measure Code", ProdOrderComponent."Unit of Measure Code");
                if ContainerLine.FindSet then
                    repeat
                        ContainerLine.SetRange("Lot No.", ContainerLine."Lot No.");
                        ContainerLine.CalcSums(Quantity);
                        TempProdContainerLine := ContainerLine;
                        //TempProdContainerLine."Line No." := 0;
                        if not TempProdContainerLine.Find then
                            TempProdContainerLine.Insert;
                        ContainerLine.FindLast;
                        ContainerLine.SetRange("Lot No.");
                    until ContainerLine.Next = 0;

                TempProdContainerLine.SetRange("Container ID", ContainerHeader.ID);
                TempProdContainerLine.SetRange("Item No.", ProdOrderComponent."Item No.");
                TempProdContainerLine.SetRange("Variant Code", ProdOrderComponent."Variant Code");
                TempProdContainerLine.SetRange("Unit of Measure Code", ProdOrderComponent."Unit of Measure Code");
                if ItemTrackingCode."Lot Specific Tracking" then
                    TempProdContainerLine.SetFilter("Lot No.", '<>%1', '');
                TempProdContainerLine.SetFilter(Quantity, '>0');
                if TempProdContainerLine.FindSet(true) then
                    repeat
                        if ProdOrderComponent.CheckLotPreferences(TempProdContainerLine."Lot No.", false) then begin
                            if TotalQtyToPick < TempProdContainerLine.Quantity then
                                QtyToPick := TotalQtyToPick
                            else
                                QtyToPick := TempProdContainerLine.Quantity;
                            TotalQtyToPick -= QtyToPick;
                            TempProdContainerLine.Quantity -= QtyToPick;
                            TempProdContainerLine.Modify;

                            TempContainerLine := TempProdContainerLine;
                            TempContainerLine.Quantity := QtyToPick;
                            TempContainerLine."Quantity (Base)" := Round(QtyToPick * TempContainerLine."Qty. per Unit of Measure", 0.00001);
                            TempContainerLine.Insert;
                        end;
                    until (TempProdContainerLine.Next = 0) or (TotalQtyToPick = 0)
            until (ContainerHeader.Next = 0) or (TotalQtyToPick = 0);
        end;
    end;

    procedure ValidatePickQtyToHandleForProductionContainer(var WarehouseActivityLine: Record "Warehouse Activity Line"; UpdateForProductionContainer: Boolean)
    var
        ContainerHeader: Record "Container Header";
        WarehouseActivityLine2: Record "Warehouse Activity Line";
    begin
        // P80056710
        if WarehouseActivityLine."Container ID" = '' then
            exit;

        ContainerHeader.Get(WarehouseActivityLine."Container ID");
        if ContainerHeader."Document Type" = 0 then
            exit;

        if ContainerHeader."Document Type" <> DATABASE::"Prod. Order Component" then
            WarehouseActivityLine.TestField("Container License Plate", '');

        if not UpdateForProductionContainer then
            exit;

        if not (WarehouseActivityLine."Qty. to Handle" in [0, WarehouseActivityLine."Qty. Outstanding"]) then
            Error(Text034, WarehouseActivityLine.FieldCaption("Qty. to Handle"), WarehouseActivityLine.FieldCaption("Qty. Outstanding"));

        WarehouseActivityLine2.SetRange("Activity Type", WarehouseActivityLine."Activity Type");
        WarehouseActivityLine2.SetRange("No.", WarehouseActivityLine."No.");
        WarehouseActivityLine2.SetRange("Container ID", WarehouseActivityLine."Container ID");
        WarehouseActivityLine2.SetFilter("Line No.", '<>%1', WarehouseActivityLine."Line No.");
        if WarehouseActivityLine2.FindSet(true) then
            repeat
                WarehouseActivityLine2.SuppressProductionContainerUpdate;
                if WarehouseActivityLine."Qty. to Handle" = 0 then
                    WarehouseActivityLine2.Validate("Qty. to Handle", 0)
                else
                    WarehouseActivityLine2.Validate("Qty. to Handle", WarehouseActivityLine2."Qty. Outstanding");
                WarehouseActivityLine2.Modify;
            until WarehouseActivityLine2.Next = 0;
    end;

    procedure UpdateContainerQtyToReceive(WhseRcptHeader: Record "Warehouse Receipt Header"; SourceType: Integer; SourceSubtype: Integer; SourceNo: Code[20]) LinesModified: Boolean
    var
        ContainersByDocument: Query "Containers by Whse. Document";
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
    begin
        // P8001323
        // P8007748 - added Boolean return
        ContainersByDocument.SetRange(WhseDocumentType, 1);
        ContainersByDocument.SetRange(WhseDocumentNo, WhseRcptHeader."No.");
        ContainersByDocument.SetRange(DocumentType, SourceType);
        ContainersByDocument.SetRange(DocumentSubtype, SourceSubtype);
        ContainersByDocument.SetRange(DocumentNo, SourceNo);
        ContainersByDocument.SetFilter(DocumentRefNo, '>0');
        ContainersByDocument.SetRange(ShipReceive, true); // P80046533
        ContainersByDocument.Open;
        while ContainersByDocument.Read do begin
            LinesModified := true; // P8007748
            case SourceType of
                DATABASE::"Sales Line":
                    begin
                        SalesLine.Get(SourceSubtype, SourceNo, ContainersByDocument.DocumentRefNo);
                        SalesLine."Return Qty. to Receive" += ContainersByDocument.LineCount;
                        SalesLine.Validate("Return Qty. to Receive");
                        SalesLine.Modify;
                    end;

                DATABASE::"Purchase Line":
                    begin
                        PurchLine.Get(SourceSubtype, SourceNo, ContainersByDocument.DocumentRefNo);
                        PurchLine."Qty. to Receive" += ContainersByDocument.LineCount;
                        PurchLine.Validate("Qty. to Receive");
                        PurchLine.Modify;
                    end;

                DATABASE::"Transfer Line":
                    begin
                        TransLine.Get(SourceNo, ContainersByDocument.DocumentRefNo);
                        TransLine."Qty. to Receive" += ContainersByDocument.LineCount;
                        TransLine.Validate("Qty. to Receive");
                        TransLine.Modify;
                    end;
            end;
        end;
    end;

    procedure UpdateContainerQtyToShip(WhseShptHeader: Record "Warehouse Shipment Header"; SourceType: Integer; SourceSubtype: Integer; SourceNo: Code[20]) LinesModified: Boolean
    var
        ContainersByDocument: Query "Containers by Whse. Document";
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
    begin
        // P8001323
        // P8007748 - added Boolean return
        ContainersByDocument.SetRange(WhseDocumentType, 2);
        ContainersByDocument.SetRange(WhseDocumentNo, WhseShptHeader."No.");
        ContainersByDocument.SetRange(DocumentType, SourceType);
        ContainersByDocument.SetRange(DocumentSubtype, SourceSubtype);
        ContainersByDocument.SetRange(DocumentNo, SourceNo);
        ContainersByDocument.SetFilter(DocumentRefNo, '>0');
        ContainersByDocument.SetRange(ShipReceive, true); // P80046533
        ContainersByDocument.Open;
        while ContainersByDocument.Read do begin
            LinesModified := true; // P8007748
            case SourceType of
                DATABASE::"Sales Line":
                    begin
                        SalesLine.Get(SourceSubtype, SourceNo, ContainersByDocument.DocumentRefNo);
                        SalesLine.Validate("Qty. to Ship", ContainersByDocument.LineCount);
                        SalesLine.Modify;
                        SalesLine.SetRange("Document Type", SalesLine."Document Type");
                        SalesLine.SetRange("Document No.", SalesLine."Document No.");
                        SalesLine.SetRange("Container Line No.", SalesLine."Line No.");
                        if SalesLine.FindSet(true) then
                            repeat
                                SalesLine.Validate("Qty. to Ship", ContainersByDocument.LineCount);
                                SalesLine.Modify;
                            until SalesLine.Next = 0;
                    end;

                DATABASE::"Purchase Line":
                    begin
                        PurchLine.Get(SourceSubtype, SourceNo, ContainersByDocument.DocumentRefNo);
                        PurchLine.Validate("Return Qty. to Ship", ContainersByDocument.LineCount);
                        PurchLine.Modify;
                    end;

                DATABASE::"Transfer Line":
                    begin
                        TransLine.Get(SourceNo, ContainersByDocument.DocumentRefNo);
                        TransLine.Validate("Qty. to Ship", ContainersByDocument.LineCount);
                        TransLine.Modify;
                    end;
            end;
        end;
    end;

    procedure ItemJnlCheckLooseInventory(ItemJnlLine: Record "Item Journal Line")
    var
        Item: Record Item;
        CheckLoose: Boolean;
        Qty: Decimal;
        QtyAlt: Decimal;
        ContQty: Decimal;
        ContQtyAlt: Decimal;
    begin
        // P8001342
        with ItemJnlLine do begin
            if ("Entry Type" = "Entry Type"::Transfer) and
              ("Location Code" = "New Location Code") and
              ("Bin Code" = "New Bin Code") and
              ("Lot No." = "New Lot No.") and
              ("Old Container ID" = "New Container ID")
            then
                exit;

            if "Entry Type" in ["Entry Type"::Sale, "Entry Type"::"Negative Adjmt.", "Entry Type"::Transfer, "Entry Type"::Consumption, "Entry Type"::"Assembly Consumption"] then begin
                "Quantity (Base)" := -"Quantity (Base)";
                "Quantity (Alt.)" := -"Quantity (Alt.)";
                "Loose Qty. (Base)" := -"Loose Qty. (Base)";
                "Loose Qty. (Alt.)" := -"Loose Qty. (Alt.)";
            end;

            if ("Quantity (Base)" < 0) or ("Quantity (Alt.)" < 0) then begin  // Only check decreases in inventory
                Item.Get("Item No.");
                // P80060274
                // Only check if part of the transaction is loose
                if (0 < Abs("Loose Qty. (Base)")) or
                    (Item."Catch Alternate Qtys." and (0 < Abs("Loose Qty. (Alt.)")))
                then
                    if Item.PreventNegativeInventory or
                       ("Entry Type" in ["Entry Type"::Consumption, "Entry Type"::"Assembly Consumption", "Entry Type"::Transfer]) or
                       ("Lot No." <> '') or ("Bin Code" <> '')
                    // P80060274
                    then
                        CheckLoose := true;
            end;

            if CheckLoose then begin
                GetContainerQty("Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code", "Lot No.", "Serial No.", ContQty, ContQtyAlt);

                if PostedFromDocument then begin
                    TempContainerLinePosted.SetRange("Item No.", "Item No.");
                    TempContainerLinePosted.SetRange("Variant Code", "Variant Code");
                    TempContainerLinePosted.SetRange("Unit of Measure Code", "Unit of Measure Code");
                    TempContainerLinePosted.SetRange("Lot No.", "Lot No.");
                    TempContainerLinePosted.SetRange("Serial No.", "Serial No.");
                    if TempContainerLinePosted.FindFirst then begin
                        ContQty += TempContainerLinePosted."Quantity (Base)";
                        ContQtyAlt += TempContainerLinePosted."Quantity (Alt.)";
                    end;
                end;

                // If there is no containerized inventory, then we'll skip the check and just let normal NAV checking take over
                if (ContQty <> 0) or (ContQtyAlt <> 0) then begin
                    GetTotalQty("Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code", "Lot No.", "Serial No.", Qty, QtyAlt);
                    Qty -= ContQty;
                    QtyAlt -= ContQtyAlt;

                    if Qty < Abs("Loose Qty. (Base)") then
                        Error(Text011, "Item No.");
                    if Item."Catch Alternate Qtys." and (QtyAlt < Abs("Loose Qty. (Alt.)")) then
                        Error(Text011, "Item No.");
                end;
            end;

            if PostedFromDocument and (("Loose Qty. (Base)" <> "Quantity (Base)") or ("Loose Qty. (Alt.)" <> "Quantity (Alt.)")) then begin
                TempContainerLinePosted.SetRange("Item No.", "Item No.");
                TempContainerLinePosted.SetRange("Variant Code", "Variant Code");
                TempContainerLinePosted.SetRange("Unit of Measure Code", "Unit of Measure Code");
                TempContainerLinePosted.SetRange("Lot No.", "Lot No.");
                TempContainerLinePosted.SetRange("Serial No.", "Serial No.");
                if TempContainerLinePosted.FindFirst then begin
                    TempContainerLinePosted."Quantity (Base)" += "Quantity (Base)" - "Loose Qty. (Base)";
                    TempContainerLinePosted."Quantity (Alt.)" += "Quantity (Alt.)" - "Loose Qty. (Alt.)";
                    TempContainerLinePosted.Modify;
                end else begin
                    TempContainerLinePosted.Reset;
                    if TempContainerLinePosted.FindLast then;
                    TempContainerLinePosted."Line No." += 1;
                    TempContainerLinePosted."Item No." := "Item No.";
                    TempContainerLinePosted."Variant Code" := "Variant Code";
                    TempContainerLinePosted."Unit of Measure Code" := "Unit of Measure Code";
                    TempContainerLinePosted."Lot No." := "Lot No.";
                    TempContainerLinePosted."Serial No." := "Serial No.";
                    TempContainerLinePosted."Quantity (Base)" := "Quantity (Base)" - "Loose Qty. (Base)";
                    TempContainerLinePosted."Quantity (Alt.)" := "Quantity (Alt.)" - "Loose Qty. (Alt.)";
                    TempContainerLinePosted.Insert;
                end;
            end;
        end;
    end;

    procedure ContainerDetailForPhysical(var Item: Record Item; var ContainerDetailBuffer: Record "Container Line" temporary)
    var
        ContainerPhysicalDetail: Query "Container Physical Detail";
    begin
        // P8001323
        ContainerPhysicalDetail.SetRange(Item_No, Item."No.");
        ContainerPhysicalDetail.SetFilter(Variant_Code, Item.GetFilter("Variant Filter"));
        ContainerPhysicalDetail.SetFilter(Lot_No, Item.GetFilter("Lot No. Filter"));
        ContainerPhysicalDetail.SetFilter(Serial_No, Item.GetFilter("Serial No. Filter"));
        ContainerPhysicalDetail.SetFilter(Location_Code, Item.GetFilter("Location Filter"));
        ContainerPhysicalDetail.SetFilter(Bin_Code, Item.GetFilter("Bin Filter"));
        ContainerPhysicalDetail.SetRange(Inbound, false);

        if ContainerDetailBuffer.FindLast then;
        ContainerPhysicalDetail.Open;
        while ContainerPhysicalDetail.Read do begin
            ContainerDetailBuffer."Container ID" := ContainerPhysicalDetail.Container_ID;
            ContainerDetailBuffer."Line No." += 1;
            ContainerDetailBuffer."Item No." := ContainerPhysicalDetail.Item_No;
            ContainerDetailBuffer."Variant Code" := ContainerPhysicalDetail.Variant_Code;
            ContainerDetailBuffer."Unit of Measure Code" := ContainerPhysicalDetail.Unit_of_Measure_Code;
            ContainerDetailBuffer."Lot No." := ContainerPhysicalDetail.Lot_No;
            ContainerDetailBuffer."Serial No." := ContainerPhysicalDetail.Serial_No;
            ContainerDetailBuffer."Location Code" := ContainerPhysicalDetail.Location_Code;
            ContainerDetailBuffer."Bin Code" := ContainerPhysicalDetail.Bin_Code;
            ContainerDetailBuffer.Quantity := ContainerPhysicalDetail.Sum_Quantity;
            ContainerDetailBuffer."Quantity (Base)" := ContainerPhysicalDetail.Sum_Quantity_Base;
            ContainerDetailBuffer."Quantity (Alt.)" := ContainerPhysicalDetail.Sum_Quantity_Alt;
            ContainerDetailBuffer.Insert;
        end;
    end;

    procedure ContainerDetailForWhsePhysical(BinContent: Record "Bin Content"; var ContainerDetailBuffer: Record "Container Line" temporary)
    var
        ContainerPhysicalDetail: Query "Container Physical Detail";
    begin
        // P8001323
        ContainerPhysicalDetail.SetRange(Item_No, BinContent."Item No.");
        ContainerPhysicalDetail.SetRange(Variant_Code, BinContent."Variant Code");
        ContainerPhysicalDetail.SetRange(Location_Code, BinContent."Location Code");
        ContainerPhysicalDetail.SetRange(Bin_Code, BinContent."Bin Code");
        ContainerPhysicalDetail.SetRange(Unit_of_Measure_Code, BinContent."Unit of Measure Code");
        ContainerPhysicalDetail.SetRange(Inbound, false);

        ContainerPhysicalDetail.Open;
        while ContainerPhysicalDetail.Read do begin
            ContainerDetailBuffer."Container ID" := ContainerPhysicalDetail.Container_ID;
            ContainerDetailBuffer."Line No." += 1;
            ContainerDetailBuffer."Item No." := ContainerPhysicalDetail.Item_No;
            ContainerDetailBuffer."Variant Code" := ContainerPhysicalDetail.Variant_Code;
            ContainerDetailBuffer."Unit of Measure Code" := ContainerPhysicalDetail.Unit_of_Measure_Code;
            ContainerDetailBuffer."Lot No." := ContainerPhysicalDetail.Lot_No;
            ContainerDetailBuffer."Serial No." := ContainerPhysicalDetail.Serial_No;
            ContainerDetailBuffer."Location Code" := ContainerPhysicalDetail.Location_Code;
            ContainerDetailBuffer."Bin Code" := ContainerPhysicalDetail.Bin_Code;
            ContainerDetailBuffer.Quantity := ContainerPhysicalDetail.Sum_Quantity;
            ContainerDetailBuffer."Quantity (Base)" := ContainerPhysicalDetail.Sum_Quantity_Base;
            ContainerDetailBuffer."Quantity (Alt.)" := ContainerPhysicalDetail.Sum_Quantity_Alt;
            ContainerDetailBuffer.Insert;
        end;
    end;

    procedure ItemJnlPostContainer(ItemJnlLine: Record "Item Journal Line")
    var
        InvSetup: Record "Inventory Setup";
        ContJnlLine: Record "Container Journal Line";
    begin
        // P8000140A
        // P8001133 - remove parameter for TempJnlLineDim
        // IF (ItemJnlLine."Serial No." = '') AND (ItemJnlLine.Quantity <> 0) THEN // P8000631A
        if (ItemJnlLine."Serial No." = '') or (ItemJnlLine.Quantity = 0) then      // P8000631A
            exit;

        case ItemJnlLine."Entry Type" of
            ItemJnlLine."Entry Type"::Purchase, ItemJnlLine."Entry Type"::"Positive Adjmt.", ItemJnlLine."Entry Type"::Output:
                begin
                    CreateContAcquisition(ItemJnlLine, ContJnlLine);
                    ContJnlPostLine.RunWithCheck(ContJnlLine); // P8001133
                end;
            ItemJnlLine."Entry Type"::Sale, ItemJnlLine."Entry Type"::"Negative Adjmt.", ItemJnlLine."Entry Type"::Consumption:
                begin
                    CreateContDisposal(ItemJnlLine, ContJnlLine);
                    ContJnlPostLine.RunWithCheck(ContJnlLine); // P8001133
                end;
            ItemJnlLine."Entry Type"::Transfer:
                begin
                    InvSetup.Get;
                    if InvSetup."Offsite Cont. Location Code" = ItemJnlLine."Location Code" then begin
                        CreateContReturn(ItemJnlLine, ContJnlLine);
                        ContJnlPostLine.RunWithCheck(ContJnlLine); // P8001133
                    end else
                        if InvSetup."Offsite Cont. Location Code" = ItemJnlLine."New Location Code" then begin
                            CreateContShip(ItemJnlLine, ContJnlLine);
                            ContJnlPostLine.RunWithCheck(ContJnlLine); // P8001133
                        end else begin
                            CreateContTransfer(ItemJnlLine, ContJnlLine);
                            ContJnlPostLine.RunWithCheck(ContJnlLine); // P8001133
                        end;
                end;
        end;
    end;

    local procedure CreateContAcquisition(ItemJnlLine: Record "Item Journal Line"; var ContJnlLine: Record "Container Journal Line")
    begin
        // P8000140A
        with ItemJnlLine do begin
            ContJnlLine.Init;
            ContJnlLine.Validate("Posting Date", "Posting Date");
            ContJnlLine.Validate("Document Date", "Document Date");
            ContJnlLine.Validate("Document No.", "Document No.");
            ContJnlLine.Validate("Entry Type", ContJnlLine."Entry Type"::Acquisition);
            ContJnlLine.Validate("Container Item No.", "Item No.");
            ContJnlLine.Validate("Container Serial No.", "Serial No.");
            ContJnlLine.Validate("External Document No.", "External Document No.");
            ContJnlLine.Validate("Source Code", "Source Code");
            ContJnlLine.Validate("Reason Code", "Reason Code");
            ContJnlLine.Validate("Shortcut Dimension 1 Code", "Shortcut Dimension 1 Code");
            ContJnlLine.Validate("Shortcut Dimension 2 Code", "Shortcut Dimension 2 Code");
            ContJnlLine."Dimension Set ID" := "Dimension Set ID"; // P8001133
            ContJnlLine.Validate("Location Code", "Location Code");
            ContJnlLine.Validate("Bin Code", "Bin Code"); // P8000631A
            if "Source No." <> '' then begin
                case "Source Type" of
                    "Source Type"::Customer:
                        ContJnlLine.Validate("Source Type", ContJnlLine."Source Type"::Customer);
                    "Source Type"::Vendor:
                        ContJnlLine.Validate("Source Type", ContJnlLine."Source Type"::Vendor);
                end;
                ContJnlLine.Validate("Source No.", "Source No.");
            end else
                ContJnlLine."Source Type" := 0;
            ContJnlLine.Validate("Unit Amount", ItemJnlLine."Unit Amount");
            ContJnlLine.Validate(Quantity, Quantity);
        end;
    end;

    local procedure CreateContDisposal(ItemJnlLine: Record "Item Journal Line"; var ContJnlLine: Record "Container Journal Line")
    begin
        // P8000140A
        with ItemJnlLine do begin
            ContJnlLine.Init;
            ContJnlLine.Validate("Posting Date", "Posting Date");
            ContJnlLine.Validate("Document Date", "Document Date");
            ContJnlLine.Validate("Document No.", "Document No.");
            ContJnlLine.Validate("Entry Type", ContJnlLine."Entry Type"::Disposal);
            ContJnlLine.Validate("Container Item No.", "Item No.");
            ContJnlLine.Validate("Container Serial No.", "Serial No.");
            ContJnlLine.Validate("External Document No.", "External Document No.");
            ContJnlLine.Validate("Source Code", "Source Code");
            ContJnlLine.Validate("Reason Code", "Reason Code");
            ContJnlLine.Validate("Shortcut Dimension 1 Code", "Shortcut Dimension 1 Code");
            ContJnlLine.Validate("Shortcut Dimension 2 Code", "Shortcut Dimension 2 Code");
            ContJnlLine."Dimension Set ID" := "Dimension Set ID"; // P8001133
            ContJnlLine.Validate("Location Code", "Location Code");
            ContJnlLine.Validate("Bin Code", "Bin Code"); // P8000631A
            if "Source No." <> '' then begin
                case "Source Type" of
                    "Source Type"::Customer:
                        ContJnlLine.Validate("Source Type", ContJnlLine."Source Type"::Customer);
                    "Source Type"::Vendor:
                        ContJnlLine.Validate("Source Type", ContJnlLine."Source Type"::Vendor);
                end;
                ContJnlLine.Validate("Source No.", "Source No.");
            end else
                ContJnlLine."Source Type" := 0;
            ContJnlLine.Validate(Quantity, Quantity);
        end;
    end;

    procedure CreateContShip(ItemJnlLine: Record "Item Journal Line"; var ContJnlLine: Record "Container Journal Line")
    var
        SerialNo: Record "Serial No. Information";
    begin
        // P8000140A
        with ItemJnlLine do begin
            ContJnlLine.Init;
            ContJnlLine.Validate("Posting Date", "Posting Date");
            ContJnlLine.Validate("Document Date", "Document Date");
            ContJnlLine.Validate("Document No.", "Document No.");
            ContJnlLine.Validate("Entry Type", ContJnlLine."Entry Type"::Ship);
            ContJnlLine.Validate("Container Item No.", "Item No.");
            ContJnlLine.Validate("Container Serial No.", "Serial No.");
            ContJnlLine.Validate("External Document No.", "External Document No.");
            ContJnlLine.Validate("Source Code", "Source Code");
            ContJnlLine.Validate("Reason Code", "Reason Code");
            ContJnlLine.Validate("Shortcut Dimension 1 Code", "Shortcut Dimension 1 Code");
            ContJnlLine.Validate("Shortcut Dimension 2 Code", "Shortcut Dimension 2 Code");
            ContJnlLine."Dimension Set ID" := "Dimension Set ID"; // P8001133
            ContJnlLine.Validate("Location Code", "Location Code");
            ContJnlLine.Validate("Bin Code", "Bin Code"); // P8000631A
            if "Source No." <> '' then begin
                case "Source Type" of
                    "Source Type"::Customer:
                        ContJnlLine.Validate("Source Type", ContJnlLine."Source Type"::Customer);
                    "Source Type"::Vendor:
                        ContJnlLine.Validate("Source Type", ContJnlLine."Source Type"::Vendor);
                end;
                ContJnlLine.Validate("Source No.", "Source No.");
            end else
                ContJnlLine."Source Type" := 0;
            ContJnlLine.Validate(Quantity, Quantity);
            SerialNo.Get("Item No.", '', "Serial No.");
            SerialNo.CalcFields("Container ID");
            ContJnlLine."Container ID" := SerialNo."Container ID";
        end;
    end;

    procedure CreateContReturn(ItemJnlLine: Record "Item Journal Line"; var ContJnlLine: Record "Container Journal Line")
    begin
        // P8000140A
        with ItemJnlLine do begin
            ContJnlLine.Init;
            ContJnlLine.Validate("Posting Date", "Posting Date");
            ContJnlLine.Validate("Document Date", "Document Date");
            ContJnlLine.Validate("Document No.", "Document No.");
            ContJnlLine.Validate("Entry Type", ContJnlLine."Entry Type"::Return);
            ContJnlLine.Validate("Container Item No.", "Item No.");
            ContJnlLine.Validate("Container Serial No.", "Serial No.");
            ContJnlLine.Validate("External Document No.", "External Document No.");
            ContJnlLine.Validate("Source Code", "Source Code");
            ContJnlLine.Validate("Reason Code", "Reason Code");
            ContJnlLine.Validate("Shortcut Dimension 1 Code", "Shortcut Dimension 1 Code");
            ContJnlLine.Validate("Shortcut Dimension 2 Code", "Shortcut Dimension 2 Code");
            ContJnlLine."Dimension Set ID" := "Dimension Set ID"; // P8001133
            ContJnlLine.Validate("Location Code", "New Location Code");
            ContJnlLine.Validate("Bin Code", "New Bin Code"); // P8000631A
            if "Source No." <> '' then begin
                case "Source Type" of
                    "Source Type"::Customer:
                        ContJnlLine.Validate("Source Type", ContJnlLine."Source Type"::Customer);
                    "Source Type"::Vendor:
                        ContJnlLine.Validate("Source Type", ContJnlLine."Source Type"::Vendor);
                end;
                ContJnlLine.Validate("Source No.", "Source No.");
            end else
                ContJnlLine."Source Type" := 0;
            ContJnlLine.Validate(Quantity, Quantity);
        end;
    end;

    procedure CreateContTransfer(ItemJnlLine: Record "Item Journal Line"; var ContJnlLine: Record "Container Journal Line")
    begin
        // P8000140A
        with ItemJnlLine do begin
            ContJnlLine.Init;
            ContJnlLine.Validate("Posting Date", "Posting Date");
            ContJnlLine.Validate("Document Date", "Document Date");
            ContJnlLine.Validate("Document No.", "Document No.");
            ContJnlLine.Validate("Entry Type", ContJnlLine."Entry Type"::Transfer);
            ContJnlLine."Transfer Order" := "Order No." <> ''; // P8000200A, P8001132
            ContJnlLine.Validate("Container Item No.", "Item No.");
            ContJnlLine.Validate("Container Serial No.", "Serial No.");
            ContJnlLine.Validate("External Document No.", "External Document No.");
            ContJnlLine.Validate("Source Code", "Source Code");
            ContJnlLine.Validate("Reason Code", "Reason Code");
            ContJnlLine.Validate("Shortcut Dimension 1 Code", "Shortcut Dimension 1 Code");
            ContJnlLine.Validate("Shortcut Dimension 2 Code", "Shortcut Dimension 2 Code");
            ContJnlLine."Dimension Set ID" := "Dimension Set ID"; // P8001133
            ContJnlLine.Validate("Location Code", "Location Code");
            ContJnlLine.Validate("New Location Code", "New Location Code");
            ContJnlLine.Validate("Bin Code", "Bin Code");         // P8000631A
            ContJnlLine.Validate("New Bin Code", "New Bin Code"); // P8000631A
            ContJnlLine.Validate(Quantity, Quantity);
        end;
    end;

    procedure LooseBinQuantity(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; BinCode: Code[20]; UOMCode: Code[10]; LotNo: Code[50]; SerialNo: Code[50]; var Qty: Decimal; var QtyBase: Decimal; var QtyAlt: Decimal)
    var
        WhseEntry: Record "Warehouse Entry";
        ContainerLine: Record "Container Line";
        Item: Record Item;
        BinQtyBase: Decimal;
    begin
        // P8000631A
        SetWhseEntryFilters(WhseEntry, ItemNo, VariantCode, LocationCode, BinCode, UOMCode, LotNo, SerialNo);
        with WhseEntry do begin
            CalcSums("Remaining Quantity", "Remaining Qty. (Base)");
            Qty := "Remaining Quantity";
            QtyBase := "Remaining Qty. (Base)";
        end;

        with ContainerLine do begin
            SetCurrentKey(
              "Item No.", "Variant Code", "Location Code", "Bin Code", "Unit of Measure Code", "Lot No.", "Serial No.");
            SetRange("Item No.", ItemNo);
            if VariantCode <> '' then
                SetRange("Variant Code", VariantCode);
            SetRange("Location Code", LocationCode);
            SetRange("Bin Code", BinCode);
            if UOMCode <> '' then
                SetRange("Unit of Measure Code", UOMCode);
            if LotNo <> '' then
                SetRange("Lot No.", LotNo);
            if SerialNo <> '' then
                SetRange("Serial No.", SerialNo);
            CalcSums(Quantity, "Quantity (Base)", "Quantity Posted", "Quantity Posted (Base)"); // P80067617
            Qty -= Quantity - "Quantity Posted"; // P80067617
            QtyBase -= "Quantity (Base)" - "Quantity Posted (Base)"; // P80067617
        end;

        Item.Get(ItemNo);
        if (Qty = 0) or (not Item.TrackAlternateUnits()) then
            QtyAlt := 0
        else begin
            BinQtyBase := QtyBase;
            LooseQuantity(ItemNo, VariantCode, LocationCode, LotNo, SerialNo, QtyBase, QtyAlt);
            if (QtyBase <> BinQtyBase) then begin
                // P8000749
                if (QtyBase = 0) then
                    QtyAlt := 0
                else
                    // P8000749
                    QtyAlt := Round(QtyAlt * (BinQtyBase / QtyBase), 0.00001);
                QtyBase := BinQtyBase;
            end;
        end;
    end;

    local procedure SetWhseEntryFilters(var WhseEntry: Record "Warehouse Entry"; ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; BinCode: Code[20]; UOMCode: Code[10]; LotNo: Code[50]; SerialNo: Code[50])
    begin
        // P8000631A
        with WhseEntry do begin
            SetCurrentKey(
              "Location Code", "Bin Code", "Item No.", "Variant Code",
              "Unit of Measure Code", Open, "Lot No.", "Serial No.");
            SetRange("Location Code", LocationCode);
            SetRange("Bin Code", BinCode);
            SetRange("Item No.", ItemNo);
            if VariantCode <> '' then
                SetRange("Variant Code", VariantCode);
            if UOMCode <> '' then
                SetRange("Unit of Measure Code", UOMCode);
            SetRange(Open, true);
            if LotNo <> '' then
                SetRange("Lot No.", LotNo);
            if SerialNo <> '' then
                SetRange("Serial No.", SerialNo);
        end;
    end;

    procedure SetRegisteringPick(NewRegisteringPick: Boolean)
    begin
        RegisteringPick := NewRegisteringPick; // P8001347
    end;

    procedure BuildContainerTotals(LocationCode: Code[10]; FromBinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UnitofMeasureCode: Code[10]; LotNo: Code[50]; TotalQtytoPick: Decimal; FindExactQty: Boolean; var TempWhseActivLine: Record "Warehouse Activity Line" temporary; var TempContainerTotal: Record "Warehouse Activity Line" temporary)
    var
        ContainerTotal: Query "Containers by Item/Lot";
        WhseActivLine: Record "Warehouse Activity Line";
        TempWhseActivLine2: Record "Warehouse Activity Line" temporary;
    begin
        // P8001347
        with ContainerTotal do begin
            SetRange(Location_Code, LocationCode);
            SetRange(Bin_Code, FromBinCode);
            SetRange(Item_No, ItemNo);
            SetRange(Variant_Code, VariantCode);
            SetRange(Unit_of_Measure_Code, UnitofMeasureCode);
            SetRange(Inbound, false);
            SetRange(Document_Type, 0); // P80056710
            if (LotNo <> '') then
                SetRange(Lot_No, LotNo);
            if FindExactQty then
                SetRange(Sum_Quantity, TotalQtytoPick)
            else
                SetRange(Sum_Quantity, 0, TotalQtytoPick);
            Open;
            while Read do
                if (Sum_Quantity > 0) and (Sum_Quantity_Base = Total_Quantity_Base) then
                    if (TempContainerTotal."Container Qty." = Sum_Quantity) then
                        TempContainerTotal.Quantity += 1
                    else begin
                        SaveTempContainerTotal(TempContainerTotal);
                        NewTempContainerTotal(TempContainerTotal, Container_ID, Lot_No, Sum_Quantity, Sum_Quantity_Base);
                    end;
            Close;
            SaveTempContainerTotal(TempContainerTotal);
        end;
        with TempContainerTotal do
            if FindSet then begin
                TempWhseActivLine2.Copy(TempWhseActivLine);
                repeat
                    Quantity := Quantity -
                      (WhseActivLine.GetAllocatedContainerCount(
                         LocationCode, FromBinCode, ItemNo, VariantCode, UnitofMeasureCode, LotNo, "Container Qty.") +
                       TempWhseActivLine.GetAllocatedContainerCount(
                         LocationCode, FromBinCode, ItemNo, VariantCode, UnitofMeasureCode, LotNo, "Container Qty."));
                    if (Quantity <= 0) then
                        Delete
                    else
                        Modify;
                until (Next = 0);
                TempWhseActivLine.Copy(TempWhseActivLine2);
            end;
    end;

    local procedure SaveTempContainerTotal(var TempContainerTotal: Record "Warehouse Activity Line" temporary)
    begin
        // P8001347
        with TempContainerTotal do
            if ("Line No." > 0) then begin
                // P8001323
                //    IF (Quantity > 1) THEN BEGIN
                //      "Container ID" := '';
                //      "Lot No." := '';
                //    END;
                Insert;
            end;
    end;

    local procedure NewTempContainerTotal(var TempContainerTotal: Record "Warehouse Activity Line" temporary; ContainerID: Code[20]; LotNo: Code[50]; Qty: Decimal; QtyBase: Decimal)
    begin
        // P8001347
        with TempContainerTotal do begin
            "Line No." += 1;
            Quantity := 1;
            // P8001323
            //  "Container ID" := ContainerID;
            //  "Lot No." := LotNo;
            "Container Qty." := Qty;
            "Qty. (Base)" := QtyBase;
        end;
    end;

    local procedure IsFullContainer(ItemNo: Code[20]; UnitofMeasureCode: Code[10]; ContTypeCode: Code[10]; ContItemNo: Code[20]; ContQty: Decimal): Boolean
    var
        ContTypeUsage: Record "Container Type Usage";
        Item: Record Item;
    begin
        // P8001347, P8007749
        Item.Get(ItemNo);
        if GetContainerUsage(ContTypeCode, ItemNo, Item."Item Category Code", UnitofMeasureCode, true, ContTypeUsage) then
            exit(ContTypeUsage."Default Quantity" = ContQty)
    end;

    procedure GetAvailableContainers(LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UnitofMeasureCode: Code[10]; LotNo: Code[50]; ContainerQty: Decimal; SingleLotOnly: Boolean; IncludeAssigned: Boolean; AssignedIDToInclude: Code[20]; var TempContainerLine: Record "Container Line" temporary): Boolean
    var
        ContainerTotal: Query "Containers by Item/Lot";
        WhseActLine: Record "Warehouse Activity Line";
    begin
        // P8001347
        TempContainerLine.Reset;
        TempContainerLine.DeleteAll;
        with ContainerTotal do begin
            SetRange(Location_Code, LocationCode);
            SetRange(Bin_Code, BinCode);
            SetRange(Item_No, ItemNo);
            SetRange(Variant_Code, VariantCode);
            SetRange(Unit_of_Measure_Code, UnitofMeasureCode);
            if (LotNo <> '') then
                SetRange(Lot_No, LotNo);
            if (ContainerQty > 0) then
                SetRange(Sum_Quantity, ContainerQty)
            else
                SetFilter(Sum_Quantity, '>0');
            Open;
            while Read do
                if (not SingleLotOnly) or (Sum_Quantity_Base = Total_Quantity_Base) then
                    if IncludeAssigned or (Container_ID = AssignedIDToInclude) then
                        AddTempContainer(Container_ID, Lot_No, Sum_Quantity, Sum_Quantity_Base, SingleLotOnly, TempContainerLine)
                    else
                        if not ContainerIsOnPick(Container_ID) then
                            AddTempContainer(Container_ID, Lot_No, Sum_Quantity, Sum_Quantity_Base, SingleLotOnly, TempContainerLine);
            Close;
        end;
        exit(TempContainerLine.FindSet);
    end;

    local procedure AddTempContainer(ContainerID: Code[20]; LotNo: Code[50]; Qty: Decimal; QtyBase: Decimal; SingleLotOnly: Boolean; var TempContainerLine: Record "Container Line" temporary)
    var
        ContainerLine: Record "Container Line";
    begin
        // P8001347
        ContainerLine.SetRange("Container ID", ContainerID);
        ContainerLine.SetRange("Lot No.", LotNo);
        if ContainerLine.FindFirst then begin
            TempContainerLine := ContainerLine;
            if SingleLotOnly then
                TempContainerLine."Line No." := 0;
            TempContainerLine.Quantity := Qty;
            TempContainerLine."Quantity (Base)" := QtyBase;
            TempContainerLine.Insert;
        end;
    end;

    procedure ContainerIsOnPick(ContainerID: Code[20]): Boolean
    var
        WhseActivLine: Record "Warehouse Activity Line";
    begin
        // P8001347
        with WhseActivLine do begin
            SetCurrentKey("Activity Type", "Action Type", "Container ID");
            SetRange("Activity Type", "Activity Type"::Pick);
            SetRange("Action Type", "Action Type"::Take);
            SetRange("Container ID", ContainerID);
            exit(not IsEmpty);
        end;
    end;

    procedure ContainerIsAssigned(ContainerID: Code[20]): Boolean
    var
        WhseActivLine: Record "Warehouse Activity Line";
        ContainerLine: Record "Container Line";
        TempContainerLine: Record "Container Line" temporary;
    begin
        // P8001347
        if ContainerIsOnPick(ContainerID) then
            exit(true);
        with ContainerLine do begin
            SetRange("Container ID", ContainerID);
            if FindFirst then begin
                GetAvailableContainers(
                  "Location Code", "Bin Code", "Item No.", "Variant Code",
                  "Unit of Measure Code", "Lot No.", 0, true, true, '', TempContainerLine);
                if TempContainerLine.Get(ContainerID, 0) then begin
                    TempContainerLine.SetRange(Quantity, TempContainerLine.Quantity);
                    exit(
                      TempContainerLine.Count <=
                      WhseActivLine.GetAllocatedContainerCount(
                        "Location Code", "Bin Code", "Item No.", "Variant Code",
                        "Unit of Measure Code", "Lot No.", TempContainerLine.Quantity));
                end;
            end;
        end;
    end;

    procedure ValidateOnWhseActivityLine(var WhseActivityLine: Record "Warehouse Activity Line")
    var
        ContainerHeader: Record "Container Header";
        ContainerLine: Record "Container Line";
        TempContainerLine: Record "Container Line" temporary;
        WhseActivityLine2: Record "Warehouse Activity Line";
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ContainerUsage: Record "Container Type Usage";
        ContQtyToHandle: Page "Container Quantity to Handle";
        QtyToHandle: Decimal;
        MaxQtyToHandle: Decimal;
        FirstLine: Integer;
        LineNo: Integer;
        ModifyContainerHeader: Boolean;
        LotTracked: Boolean;
        SerialTracked: Boolean;
        MoveContainer: Boolean;
        Handled: Boolean;
    begin
        // P8001323
        with WhseActivityLine do begin
            Item.Get("Item No.");
            if Item."Item Tracking Code" <> '' then begin
                ItemTrackingCode.Get(Item."Item Tracking Code");
                LotTracked := ItemTrackingCode."Lot Specific Tracking";
                SerialTracked := ItemTrackingCode."SN Specific Tracking";
            end;

            case "Action Type" of
                "Action Type"::Take:
                    begin
                        if "Container ID" <> '' then begin
                            // This represents the previous container entered on the line and we need to clear it
                            ContainerHeader.Get("Container ID");
                            // P80056710
                            if ContainerHeader."Document Type" = DATABASE::"Prod. Order Component" then
                                Error(Text032, ContainerHeader."License Plate");
                            // P80056710
                            if ContainerHeader."Document Type" <> 0 then begin
                                WhseActivityLine2.SetRange("Activity Type", "Activity Type");
                                WhseActivityLine2.SetRange("No.", "No.");
                                WhseActivityLine2.SetRange("Action Type", WhseActivityLine2."Action Type"::Place);
                                WhseActivityLine2.SetRange("Container ID", "Container ID");
                                if not WhseActivityLine2.IsEmpty then
                                    Error(Text006, ContainerHeader."License Plate");
                            end;
                            "Container ID" := '';
                        end;

                        if "Container License Plate" <> '' then begin
                            ContainerHeader.SetRange("Location Code", "Location Code");
                            ContainerHeader.SetRange("License Plate", "Container License Plate");
                            if "Bin Code" <> '' then
                                ContainerHeader.SetRange("Bin Code", "Bin Code");
                            ContainerHeader.SetRange(Inbound, false);
                            ContainerHeader.FindFirst;
                            if ContainerHeader."Document Type" = DATABASE::"Prod. Order Component" then
                                Error(Text033, ContainerHeader."License Plate");
                            // P80056710
                            ContainerHeader.CheckHeaderComplete(true);

                            if ContainerHeader."Document Type" <> 0 then
                                if (ContainerHeader."Document Type" <> WhseActivityLine."Source Type") or
                                   (ContainerHeader."Document Subtype" <> WhseActivityLine."Source Subtype") or
                                   (ContainerHeader."Document No." <> WhseActivityLine."Source No.") or
                                   // P80056709
                                   (ContainerHeader."Document Line No." <>
                                    ContainerHeader.SourceLineNo(WhseActivityLine."Source Type", WhseActivityLine."Source Subtype", WhseActivityLine."Source Line No."))
                                // P80056709
                                then
                                    Error(Text004, ContainerHeader."License Plate", ContainerHeader.AssignmentText); // P80056709

                            WhseActivityLine2.Reset;
                            WhseActivityLine2.SetRange("Container ID", ContainerHeader.ID);
                            if WhseActivityLine2.FindFirst then
                                if ("Activity Type" <> WhseActivityLine2."Activity Type") or ("No." <> WhseActivityLine2."No.") then
                                    Error(Text007, ContainerHeader."License Plate", WhseActivityLine2."Activity Type", WhseActivityLine2."No.");

                            ContainerLine.SetRange("Container ID", ContainerHeader.ID);
                            ContainerLine.SetRange("Item No.", "Item No.");
                            ContainerLine.SetRange("Variant Code", "Variant Code");
                            ContainerLine.SetRange("Unit of Measure Code", "Unit of Measure Code");
                            if "Lot No." <> '' then
                                ContainerLine.SetRange("Lot No.", "Lot No.");
                            if "Serial No." <> '' then
                                ContainerLine.SetRange("Serial No.", "Serial No.");
                            ContainerLine.FindSet;
                            repeat
                                TempContainerLine.SetRange("Lot No.", ContainerLine."Lot No.");
                                TempContainerLine.SetRange("Serial No.", ContainerLine."Serial No.");
                                if TempContainerLine.FindFirst then begin
                                    TempContainerLine.Quantity += ContainerLine.Quantity;
                                    TempContainerLine."Quantity (Alt.)" += ContainerLine."Quantity (Alt.)";
                                    TempContainerLine.Modify;
                                end else begin
                                    TempContainerLine := ContainerLine;
                                    TempContainerLine.Insert;
                                end;
                            until ContainerLine.Next = 0;

                            TempContainerLine.Reset;
                            WhseActivityLine2.Reset;
                            WhseActivityLine2.SetRange("Container ID", ContainerHeader.ID);
                            WhseActivityLine2.SetRange("Action Type", WhseActivityLine2."Action Type"::Take);
                            WhseActivityLine2.SetRange("Item No.", "Item No.");
                            WhseActivityLine2.SetRange("Variant Code", "Variant Code");
                            WhseActivityLine2.SetRange("Unit of Measure Code", "Unit of Measure Code");
                            if TempContainerLine.FindSet then
                                repeat
                                    WhseActivityLine2.SetRange("Lot No.", TempContainerLine."Lot No.");
                                    WhseActivityLine2.SetRange("Serial No.", TempContainerLine."Serial No.");
                                    WhseActivityLine2.CalcSums("Qty. to Handle", WhseActivityLine2."Qty. to Handle (Alt.)");
                                    TempContainerLine.Quantity -= WhseActivityLine2."Qty. to Handle";
                                    TempContainerLine."Quantity (Alt.)" -= WhseActivityLine2."Qty. to Handle (Alt.)";
                                    if 0 < TempContainerLine.Quantity then begin
                                        TempContainerLine.Modify;
                                        if "Lot No." = '' then
                                            if (TempContainerLine."Lot No." <> '') and P800Functions.TrackingInstalled then begin
                                                WhseActivityLine2 := WhseActivityLine;
                                                WhseActivityLine2."Lot No." := TempContainerLine."Lot No.";
                                                if not WhseActivityLine2.CheckLotPreferences(true) then
                                                    TempContainerLine.Delete;
                                            end;
                                    end else
                                        TempContainerLine.Delete;
                                until TempContainerLine.Next = 0;
                            TempContainerLine.CalcSums(Quantity);
                            if TempContainerLine.Quantity = 0 then
                                Error(Text008, ContainerHeader."License Plate");

                            // P80092182
                            Handled := FALSE;
                            OnValidateOnWhseActivityLineOnBeforeCheckContQtyToHandle(Item, Handled, WhseActivityLine, TempContainerLine); // P80098649
                            if not Handled then
                                // P80092182

                                if ("Qty. Outstanding" < TempContainerLine.Quantity) and ((1 < TempContainerLine.Count) or Item."Catch Alternate Qtys.") then begin
                                    ContQtyToHandle.SetSource(TempContainerLine, "Qty. Outstanding");
                                    if ContQtyToHandle.RunModal = ACTION::Cancel then begin
                                        if "Container ID" = '' then
                                            "Container License Plate" := ''
                                        else begin
                                            // I don't think we ever get here, if there had been a container already assigned to the line then the
                                            // numer of records in TempContainerLine should be 1
                                            ContainerHeader.Get("Container ID");
                                            "Container License Plate" := ContainerHeader."License Plate";
                                        end;
                                        exit;
                                    end else
                                        ContQtyToHandle.GetSource(TempContainerLine);
                                end;

                            if TempContainerLine.FindSet then begin
                                FirstLine := TempContainerLine."Line No.";
                                WhseActivityLine2.Reset;
                                repeat
                                    if FirstLine = TempContainerLine."Line No." then begin
                                        WhseActivityLine2 := WhseActivityLine;
                                        WhseActivityLine2."Container License Plate" := '';
                                    end else
                                        WhseActivityLine2.Next;

                                    if WhseActivityLine2."Qty. Outstanding" < TempContainerLine.Quantity then
                                        QtyToHandle := WhseActivityLine2."Qty. Outstanding"
                                    else
                                        QtyToHandle := TempContainerLine.Quantity;
                                    WhseActivityLine2.Validate("Qty. to Handle", QtyToHandle);
                                    WhseActivityLine2.Modify; // P80086144
                                    if WhseActivityLine2."Qty. to Handle" < WhseActivityLine2."Qty. Outstanding" then
                                        WhseActivityLine2.SplitLine(WhseActivityLine2);
                                    if WhseActivityLine2."Bin Code" = '' then
                                        WhseActivityLine2.Validate("Bin Code", ContainerHeader."Bin Code");
                                    if (WhseActivityLine2."Lot No." = '') and (TempContainerLine."Lot No." <> '') then
                                        WhseActivityLine2.Validate("Lot No.", TempContainerLine."Lot No.");
                                    if (WhseActivityLine2."Serial No." = '') and (TempContainerLine."Serial No." <> '') then
                                        WhseActivityLine2.Validate("Serial No.", TempContainerLine."Serial No.");
                                    // P80068361
                                    WhseActivityLine2."Container ID" := ContainerHeader.ID;
                                    WhseActivityLine2."Container License Plate" := ContainerHeader."License Plate";
                                    // P80068361
                                    // P80052981
                                    if (WhseActivityLine2."Activity Type" in [WhseActivityLine2."Activity Type"::"Invt. Movement",
                                                                              WhseActivityLine2."Activity Type"::"Invt. Pick",
                                                                              WhseActivityLine2."Activity Type"::Movement, // P80099521
                                                                              WhseActivityLine2."Activity Type"::"Invt. Put-away"]) or
                                        ((WhseActivityLine2."Activity Type" = WhseActivityLine2."Activity Type"::Pick) and
                                         (WhseActivityLine2."Whse. Document Type" IN [WhseActivityLine2."Whse. Document Type"::Shipment, WhseActivityLine2."Whse. Document Type"::Production])) or // P80068361, P800128454
                                        ((WhseActivityLine2."Activity Type" = WhseActivityLine2."Activity Type"::"Put-away") and // P80068361
                                         (WhseActivityLine2."Whse. Document Type" = WhseActivityLine2."Whse. Document Type"::Receipt)) // P80068361
                                    then
                                        // P80052981
                                        SetAltQtyOnWhseActivityLine(WhseActivityLine2, TempContainerLine."Quantity (Alt.)", Item."Catch Alternate Qtys.");
                                    WhseActivityLine2.Modify;
                                until TempContainerLine.Next = 0;
                                Get("Activity Type", "No.", "Line No.");
                                Get("Activity Type", "No.", WhseActivityLine2."Line No."); // P80086144
                            end else begin
                                "Container License Plate" := '';
                                "Container ID" := '';
                            end;
                        end;
                    end;

                "Action Type"::Place:
                    begin
                        if "Container ID" <> '' then begin
                            // P80056710
                            ContainerHeader.Get("Container ID");
                            if (ContainerHeader."Document Type" = DATABASE::"Prod. Order Component") and (ContainerHeader."Bin Code" <> "Bin Code") then
                                Error(Text032, ContainerHeader."License Plate");
                            // P80056710
                            SetAltQtyOnWhseActivityLine(WhseActivityLine, 0, Item."Catch Alternate Qtys.");
                            ClearPendingAssignment(WhseActivityLine);
                            "Container ID" := '';
                        end;

                        if "Container License Plate" <> '' then begin
                            ContainerHeader.SetRange("Location Code", "Location Code");
                            ContainerHeader.SetRange("License Plate", "Container License Plate");
                            ContainerHeader.SetRange(Inbound, false);
                            ContainerHeader.FindFirst;
                            // P80056710
                            if (ContainerHeader."Document Type" = DATABASE::"Prod. Order Component") and (ContainerHeader."Bin Code" <> "Bin Code") then
                                Error(Text033, ContainerHeader."License Plate");
                            // P80056710
                            ContainerHeader.CheckHeaderComplete(true);

                            if not GetContainerUsage(ContainerHeader."Container Type Code", "Item No.", Item."Item Category Code", // P8007749
                              "Unit of Measure Code", true, ContainerUsage)
                            then
                                Error(Text005, "Item No.", "Container License Plate");

                            WhseActivityLine2.Reset;
                            WhseActivityLine2.SetRange("Container ID", ContainerHeader.ID);
                            if WhseActivityLine2.FindFirst then
                                if ("Activity Type" <> WhseActivityLine2."Activity Type") or ("No." <> WhseActivityLine2."No.") then
                                    Error(Text007, ContainerHeader."License Plate", WhseActivityLine2."Activity Type", WhseActivityLine2."No.");

                            if ("Bin Code" <> '') and (ContainerHeader."Bin Code" <> "Bin Code") then begin
                                WhseActivityLine2.SetRange("Action Type", WhseActivityLine2."Action Type"::Take);
                                WhseActivityLine2.SetRange("Container ID", ContainerHeader.ID);
                                if WhseActivityLine2.IsEmpty then
                                    ContainerHeader.FieldError("Bin Code", StrSubstNo(Text014, "Bin Code"));
                                WhseActivityLine2.SetRange("Action Type", WhseActivityLine2."Action Type"::Place);
                                if WhseActivityLine2.FindFirst then
                                    if "Bin Code" <> WhseActivityLine2."Bin Code" then
                                        FieldError("Bin Code", StrSubstNo(Text014, WhseActivityLine2."Bin Code"));
                            end;

                            if ContainerHeader."Document Type" <> 0 then
                                if (ContainerHeader."Document Type" <> WhseActivityLine."Source Type") or
                                   (ContainerHeader."Document Subtype" <> WhseActivityLine."Source Subtype") or
                                   (ContainerHeader."Document No." <> WhseActivityLine."Source No.") or
                                   // P80056709
                                   (ContainerHeader."Document Line No." <>
                                    ContainerHeader.SourceLineNo(WhseActivityLine."Source Type", WhseActivityLine."Source Subtype", WhseActivityLine."Source Line No."))
                                // P80056709
                                then
                                    Error(Text004, ContainerHeader."License Plate", ContainerHeader.AssignmentText); // P80056709
                                                                                                                     // P80068877
                            if ContainerHeader."Whse. Document Type" <> 0 then
                                if (ContainerHeader."Whse. Document Type" <> WhseActivityLine."Whse. Document Type") or
                                   (ContainerHeader."Whse. Document No." <> WhseActivityLine."Whse. Document No.")
                                then
                                    Error(Text004, ContainerHeader."License Plate", StrSubstNo('%1 %2', ContainerHeader."Whse. Document Type", ContainerHeader."Whse. Document No."));
                            // P80068877
                            if "Activity Type" = "Activity Type"::Pick then begin // P80068877
                                SetPendingAssignment(WhseActivityLine, ContainerHeader);
                                ContainerHeader.Modify;
                                //ModifyContainerHeader := TRUE;
                            end;

                            if ContainerHeader."Document Type" = 0 then begin
                                ContainerLine.SetRange("Container ID", ContainerHeader.ID);
                                if ContainerLine.IsEmpty then begin
                                    WhseActivityLine2.Reset;
                                    WhseActivityLine2.SetRange("Activity Type", "Activity Type");
                                    WhseActivityLine2.SetRange("No.", "No.");
                                    WhseActivityLine2.SetRange("Container ID", ContainerHeader.ID);
                                    WhseActivityLine2.SetRange("Action Type", WhseActivityLine."Action Type"::Place);
                                    WhseActivityLine2.SetFilter("Item No.", '<>%1', "Item No.");
                                    if not WhseActivityLine2.IsEmpty then
                                        Error(Text010, ContainerHeader."License Plate");

                                    if ContainerUsage."Single Lot" then begin
                                        WhseActivityLine2.SetRange("Item No.", "Item No.");
                                        WhseActivityLine2.SetFilter("Lot No.", '<>%1', "Lot No.");
                                        if not WhseActivityLine2.IsEmpty then
                                            Error(Text009, ContainerHeader."License Plate");
                                    end;
                                end else begin
                                    ContainerLine.SetFilter("Item No.", '<>%1', "Item No.");
                                    if not ContainerLine.IsEmpty then
                                        Error(Text010, ContainerHeader."License Plate");

                                    if ContainerUsage."Single Lot" then begin
                                        ContainerLine.SetRange("Item No.", "Item No.");
                                        ContainerLine.SetFilter("Lot No.", '<>%1', "Lot No.");
                                        if not ContainerLine.IsEmpty then
                                            Error(Text009, ContainerHeader."License Plate");
                                    end;
                                end;
                            end;

                            // Figure out what is available to go into the container
                            //   This is based upon the quantity to handle on similar take lines
                            //   However, if the contianer is being moved then first reference to the contianer will only place what is in the container
                            //      subsequent references to the container will place what it can based upon quantity to handle on the place line
                            WhseActivityLine2.Reset;
                            WhseActivityLine2.SetRange("Activity Type", "Activity Type");
                            WhseActivityLine2.SetRange("No.", "No.");
                            WhseActivityLine2.SetFilter("Line No.", '<>%1', "Line No.");
                            if ("Activity Type" = "Activity Type"::Pick) and
                              ("Source Document" in ["Source Document"::"Sales Order", "Source Document"::"Purchase Return Order", // P80056710
                                "Source Document"::"Outbound Transfer", "Source Document"::"Prod. Consumption"])                   // P80056710
                            then begin
                                WhseActivityLine2.SetRange("Source Type", "Source Type");
                                WhseActivityLine2.SetRange("Source Subtype", "Source Subtype");
                                WhseActivityLine2.SetRange("Source No.", "Source No.");
                                WhseActivityLine2.SetRange("Source Line No.", "Source Line No.");
                                WhseActivityLine2.SetRange("Source Subline No.", "Source Subline No.");
                            end else begin
                                WhseActivityLine2.SetRange("Item No.", "Item No.");
                                WhseActivityLine2.SetRange("Variant Code", "Variant Code");
                                WhseActivityLine2.SetRange("Unit of Measure Code", "Unit of Measure Code");
                            end;
                            if LotTracked then
                                if "Lot No." <> '' then
                                    WhseActivityLine2.SetRange("Lot No.", "Lot No.")
                                else
                                    WhseActivityLine2.SetFilter("Lot No.", '<>%1', '');
                            if SerialTracked then
                                if "Serial No." <> '' then
                                    WhseActivityLine2.SetRange("Serial No.", "Serial No.")
                                else
                                    WhseActivityLine2.SetFilter("Serial No.", '<>%1', '');

                            WhseActivityLine2.SetRange("Container ID", ContainerHeader.ID);
                            WhseActivityLine2.SetRange("Action Type", WhseActivityLine2."Action Type"::Place);
                            if WhseActivityLine2.IsEmpty then begin
                                WhseActivityLine2.SetRange("Action Type", WhseActivityLine2."Action Type"::Take);
                                if WhseActivityLine2.IsEmpty then begin
                                    WhseActivityLine2.SetRange("Container ID");
                                    WhseActivityLine2.SetRange("Action Type");
                                end;
                            end else begin
                                WhseActivityLine2.SetRange("Container ID");
                                WhseActivityLine2.SetRange("Action Type");
                            end;

                            WhseActivityLine2.SetFilter("Qty. to Handle", '>0');

                            if WhseActivityLine2.FindSet then begin
                                repeat
                                    TempContainerLine.SetRange("Container ID", ContainerHeader.ID);
                                    TempContainerLine.SetRange("Item No.", WhseActivityLine2."Item No.");
                                    TempContainerLine.SetRange("Variant Code", WhseActivityLine2."Variant Code");
                                    TempContainerLine.SetRange("Unit of Measure Code", WhseActivityLine2."Unit of Measure Code");
                                    TempContainerLine.SetRange("Lot No.", WhseActivityLine2."Lot No.");
                                    TempContainerLine.SetRange("Serial No.", WhseActivityLine2."Serial No.");
                                    if not TempContainerLine.FindFirst then begin
                                        TempContainerLine.Init;
                                        LineNo += 10000;
                                        TempContainerLine."Container ID" := ContainerHeader.ID;
                                        TempContainerLine."Line No." := LineNo;
                                        TempContainerLine."Item No." := WhseActivityLine2."Item No.";
                                        TempContainerLine.Description := WhseActivityLine2.Description;
                                        TempContainerLine."Variant Code" := WhseActivityLine2."Variant Code";
                                        TempContainerLine."Unit of Measure Code" := WhseActivityLine2."Unit of Measure Code";
                                        TempContainerLine."Lot No." := WhseActivityLine2."Lot No.";
                                        TempContainerLine."Serial No." := WhseActivityLine2."Serial No.";
                                        TempContainerLine.Insert;
                                    end;
                                    if WhseActivityLine2."Action Type" = WhseActivityLine2."Action Type"::Take then begin
                                        TempContainerLine.Quantity += WhseActivityLine2."Qty. to Handle";
                                        TempContainerLine."Quantity (Alt.)" += WhseActivityLine2."Qty. to Handle (Alt.)";
                                    end else begin
                                        TempContainerLine.Quantity -= WhseActivityLine2."Qty. to Handle";
                                        TempContainerLine."Quantity (Alt.)" -= WhseActivityLine2."Qty. to Handle (Alt.)";
                                    end;
                                    if TempContainerLine.Quantity > 0 then
                                        TempContainerLine.Modify
                                    else
                                        TempContainerLine.Delete;
                                until WhseActivityLine2.Next = 0;

                                TempContainerLine.Reset;
                                TempContainerLine.CalcSums(Quantity);
                                OnValidateOnWhseActivityLineOnBeforeShowContQtyToHandle(WhseActivityLine, TempContainerLine, Item, Handled); // P80082969
                                if (("Qty. Outstanding" < TempContainerLine.Quantity) and ((1 < TempContainerLine.Count) or Item."Catch Alternate Qtys.")) or
                                   (("Qty. Outstanding" > TempContainerLine.Quantity) and ((1 < TempContainerLine.Count) and Item."Catch Alternate Qtys."))
                                  and (not Handled) // P80082969
                                then begin
                                    if TempContainerLine.Quantity < "Qty. Outstanding" then
                                        MaxQtyToHandle := TempContainerLine.Quantity
                                    else
                                        MaxQtyToHandle := "Qty. Outstanding";
                                    ContQtyToHandle.SetSource(TempContainerLine, MaxQtyToHandle);
                                    if ContQtyToHandle.RunModal = ACTION::Cancel then begin
                                        if "Container ID" = '' then
                                            "Container License Plate" := ''
                                        else begin
                                            // I don't think we ever get here, if there had been a container already assigned to the line then the
                                            // numer of records in TempContainerLine should be 1
                                            ContainerHeader.Get("Container ID");
                                            "Container License Plate" := ContainerHeader."License Plate";
                                        end;
                                        exit;
                                    end else
                                        ContQtyToHandle.GetSource(TempContainerLine);
                                end;

                                //IF ModifyContainerHeader THEN
                                //  ContainerHeader.MODIFY;

                                if TempContainerLine.FindSet then begin
                                    FirstLine := TempContainerLine."Line No.";
                                    WhseActivityLine2.Reset;
                                    repeat
                                        if FirstLine = TempContainerLine."Line No." then begin
                                            WhseActivityLine2 := WhseActivityLine;
                                            WhseActivityLine2."Container License Plate" := '';
                                        end else
                                            WhseActivityLine2.Next;

                                        if WhseActivityLine2."Qty. Outstanding" < TempContainerLine.Quantity then
                                            QtyToHandle := WhseActivityLine2."Qty. Outstanding"
                                        else
                                            QtyToHandle := TempContainerLine.Quantity;
                                        WhseActivityLine2.Validate("Qty. to Handle", QtyToHandle);
                                        WhseActivityLine2.Modify; // P80086144
                                        if WhseActivityLine2."Qty. to Handle" < WhseActivityLine2."Qty. Outstanding" then begin
                                            // P80082969
                                            Handled := false;
                                            OnValidateOnWhseActivityLineOnBeforeSplitLine(WhseActivityLine, Handled);
                                            if not Handled then
                                                // P80082969
                                                WhseActivityLine2.SplitLine(WhseActivityLine2);
                                        end;
                                        if WhseActivityLine2."Bin Code" = '' then
                                            WhseActivityLine2.Validate("Bin Code", ContainerHeader."Bin Code");
                                        if (WhseActivityLine2."Lot No." = '') and (TempContainerLine."Lot No." <> '') then
                                            WhseActivityLine2.Validate("Lot No.", TempContainerLine."Lot No.");
                                        if (WhseActivityLine2."Serial No." = '') and (TempContainerLine."Serial No." <> '') then
                                            WhseActivityLine2.Validate("Serial No.", TempContainerLine."Serial No.");
                                        // P80068361
                                        WhseActivityLine2."Container ID" := ContainerHeader.ID;
                                        WhseActivityLine2."Container License Plate" := ContainerHeader."License Plate";
                                        // P80068361
                                        SetAltQtyOnWhseActivityLine(WhseActivityLine2, TempContainerLine."Quantity (Alt.)", Item."Catch Alternate Qtys.");
                                        WhseActivityLine2.Modify;
                                    until TempContainerLine.Next = 0;
                                    Get("Activity Type", "No.", WhseActivityLine2."Line No."); // P80086144
                                end;
                            end;

                            if (TempContainerLine.Count = 0) and ("Qty. to Handle" > 0) then begin
                                if ContainerHeader."Document Type" <> 0 then
                                    ContainerHeader.TestField("Bin Code", "Bin Code");

                                if LotTracked then
                                    TestField("Lot No.");
                                if SerialTracked then
                                    TestField("Serial No.");

                                "Container ID" := ContainerHeader.ID;
                            end else
                                if "Container ID" = '' then
                                    "Container License Plate" := '';
                        end;
                    end;
            end;
        end;
    end;

    procedure SetAltQtyOnWhseActivityLine(var WhseActivityLine: Record "Warehouse Activity Line"; QtyToHandleAlt: Decimal; CatchAltQtys: Boolean)
    var
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
    begin
        // P8001323
        //WhseActivityLine."Qty. to Handle (Alt.)" := QtyToHandleAlt; // P80054495
        if CatchAltQtys then begin
            WhseActivityLine."Qty. to Handle (Alt.)" := QtyToHandleAlt; // P80054495
            AltQtyMgmt.AssignNewTransactionNo(WhseActivityLine."Alt. Qty. Transaction No.");
            AltQtyMgmt.DeleteAltQtyLines(WhseActivityLine."Alt. Qty. Transaction No.");
            if WhseActivityLine."Qty. to Handle (Alt.)" <> 0 then
                AltQtyMgmt.ValidateWhseActAltQtyLine(WhseActivityLine);
        end;
    end;

    procedure LookupContainerOnWhseLine(WhseLine: Variant; FldNo: Integer; var Text: Text): Boolean
    var
        TempContainerHeader: Record "Container Header" temporary;
    begin
        // P8004516
        LookupContainerOnWhseLine2(WhseLine, FldNo, TempContainerHeader);
        if PAGE.RunModal(0, TempContainerHeader) = ACTION::LookupOK then begin
            Text := TempContainerHeader."License Plate";
            exit(true);
        end;
    end;

    procedure LookupContainerOnWhseLine2(WhseLine: Variant; FldNo: Integer; var TempContainerHeader: Record "Container Header" temporary)
    var
        WhseLineRecRef: RecordRef;
        WhseActivityLine: Record "Warehouse Activity Line";
        WhseJournalLine: Record "Warehouse Journal Line";
        ContainerHeader: Record "Container Header";
        ContainerLine: Record "Container Line";
        WhseActivityLine2: Record "Warehouse Activity Line";
        FromTo: Option From,"To";
        LocationCode: Code[10];
        ItemNo: Code[20];
        VariantCode: Code[10];
        LotNo: Code[50];
        UOMCode: Code[10];
        BinCode: Code[20];
        LineNo: Integer;
        SourceType: Integer;
        SourceSubtype: Integer;
        SourceNo: Code[20];
        SourceLineNo: Integer;
        PreProcessActivityLine: Record "Pre-Process Activity Line";
        PreProcessActivity: Record "Pre-Process Activity";
    begin
        // P8004516

        // P8001323
        WhseLineRecRef.GetTable(WhseLine);

        case WhseLineRecRef.Number of
            DATABASE::"Warehouse Activity Line":
                begin
                    WhseActivityLine := WhseLine;
                    with WhseActivityLine do begin
                        LineNo := "Line No."; // P8007405
                        LocationCode := "Location Code";
                        ItemNo := "Item No.";
                        VariantCode := "Variant Code";
                        LotNo := "Lot No.";
                        UOMCode := "Unit of Measure Code";
                        BinCode := "Bin Code";
                        SourceType := "Source Type";
                        SourceSubtype := "Source Subtype";
                        SourceNo := "Source No.";
                        SourceLineNo := "Source Line No."; // P80056709
                        case "Action Type" of
                            "Action Type"::Take:
                                FromTo := FromTo::From;
                            "Action Type"::Place:
                                begin
                                    FromTo := FromTo::"To";
                                    WhseActivityLine2.SetRange("Activity Type", "Activity Type");
                                    WhseActivityLine2.SetRange("No.", "No.");
                                    WhseActivityLine2.SetRange("Action Type", "Action Type"::Take);
                                    WhseActivityLine2.SetFilter("Container ID", '<>%1', '');
                                    if WhseActivityLine2.FindSet then
                                        repeat
                                            ContainerHeader.Get(WhseActivityLine2."Container ID");
                                            TempContainerHeader := ContainerHeader;
                                            if TempContainerHeader.Insert then;
                                        until WhseActivityLine2.Next = 0;
                                end;
                        end;
                    end;
                end;

            DATABASE::"Warehouse Journal Line":
                begin
                    WhseJournalLine := WhseLine;
                    with WhseJournalLine do begin
                        LineNo := "Line No."; // P8007405
                        LocationCode := "Location Code";
                        ItemNo := "Item No.";
                        VariantCode := "Variant Code";
                        LotNo := "Lot No.";
                        UOMCode := "Unit of Measure Code";
                        case FldNo of
                            FieldNo("From Container License Plate"):
                                begin
                                    FromTo := FromTo::From;
                                    BinCode := "From Bin Code";
                                end;
                            FieldNo("To Container License Plate"):
                                begin
                                    FromTo := FromTo::"To";
                                    BinCode := "To Bin Code";
                                end;
                            FieldNo("Container License Plate"):
                                begin
                                    if Quantity < 0 then
                                        FromTo := FromTo::From
                                    else
                                        FromTo := FromTo::"To";
                                    BinCode := "Bin Code";
                                end;
                        end;
                    end;
                end;

            DATABASE::"Pre-Process Activity Line":
                begin
                    PreProcessActivityLine := WhseLine;
                    with PreProcessActivityLine do begin
                        PreProcessActivity.Get("Activity No.");
                        LineNo := "Line No."; // P8007405
                        LocationCode := PreProcessActivity."Location Code";
                        ItemNo := "Item No.";
                        VariantCode := "Variant Code";
                        LotNo := "Lot No.";
                        UOMCode := "Unit of Measure Code";
                        BinCode := PreProcessActivity."From Bin Code";
                        SourceType := DATABASE::"Pre-Process Activity Line";
                        SourceSubtype := 0;
                        SourceNo := PreProcessActivity."No.";
                        case FldNo of
                            FieldNo("From Container License Plate"):
                                begin
                                    FromTo := FromTo::From;
                                    BinCode := PreProcessActivity."To Bin Code";
                                end;
                            FieldNo("To Container License Plate"):
                                begin
                                    FromTo := FromTo::"To";
                                    BinCode := PreProcessActivity."From Bin Code";
                                end;
                        end;
                    end;
                end;
        end;

        case FromTo of
            FromTo::From:
                begin
                    ContainerLine.SetRange(Inbound, false);
                    ContainerLine.SetRange("Location Code", LocationCode);
                    if ItemNo <> '' then
                        ContainerLine.SetRange("Item No.", ItemNo);
                    if (LineNo <> 0) and (ItemNo <> '') then // P8007405
                        ContainerLine.SetRange("Variant Code", VariantCode);
                    if UOMCode <> '' then
                        ContainerLine.SetRange("Unit of Measure Code", UOMCode);
                    if LotNo <> '' then
                        ContainerLine.SetRange("Lot No.", LotNo);
                    if BinCode <> '' then
                        ContainerLine.SetRange("Bin Code", BinCode);
                    if ContainerLine.FindSet then
                        repeat
                            ContainerHeader.Get(ContainerLine."Container ID");
                            if ContainerHeader."Document Type" = 0 then begin
                                TempContainerHeader := ContainerHeader;
                                if TempContainerHeader.Insert then;
                            end else
                                if (ContainerHeader."Document Type" = SourceType) and (ContainerHeader."Document Subtype" = SourceSubtype) and (ContainerHeader."Document No." = SourceNo) and
                                   (ContainerHeader."Document Line No." = ContainerHeader.SourceLineNo(SourceType, SourceSubtype, SourceLineNo)) // P80056709
                                then begin
                                    TempContainerHeader := ContainerHeader;
                                    if TempContainerHeader.Insert then;
                                end;
                        until ContainerLine.Next = 0;
                end;

            FromTo::"To":
                begin
                    ContainerHeader.SetRange("Location Code", LocationCode);
                    ContainerHeader.SetRange("Bin Code", BinCode);
                    ContainerHeader.SetRange(Inbound, false);
                    if ContainerHeader.FindSet then
                        repeat
                            if ContainerHeader.IsHeaderComplete then
                                if ContainerHeader."Document Type" = 0 then begin
                                    TempContainerHeader := ContainerHeader;
                                    TempContainerHeader.Insert;
                                end else
                                    if (ContainerHeader."Document Type" = SourceType) and (ContainerHeader."Document Subtype" = SourceSubtype) and (ContainerHeader."Document No." = SourceNo) and
                                       (ContainerHeader."Document Line No." = ContainerHeader.SourceLineNo(SourceType, SourceSubtype, SourceLineNo)) // P80056709
                                    then begin
                                        TempContainerHeader := ContainerHeader;
                                        TempContainerHeader.Insert;
                                    end;
                        until ContainerHeader.Next = 0;
                end;
        end;

        if TempContainerHeader.FindFirst then;
    end;

    procedure NewContainerOnWhseActivityLine(var WhseActivityLine: Record "Warehouse Activity Line")
    var
        Location: Record Location;
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ContainerHeader: Record "Container Header";
    begin
        // P8001323
        with WhseActivityLine do begin
            TestField("Container License Plate", '');
            TestField("Item No.");
            TestField("Unit of Measure Code");
            Location.Get("Location Code");
            if Location."Bin Mandatory" then
                TestField("Bin Code");
            Item.Get("Item No.");
            if Item."Item Tracking Code" <> '' then begin
                ItemTrackingCode.Get(Item."Item Tracking Code");
                if ItemTrackingCode."Lot Specific Tracking" then
                    TestField("Lot No.");
            end;

            if CreateNewContainer('', false, "Location Code", "Bin Code", "Item No.", "Unit of Measure Code", ContainerHeader) then begin // P8004339
                SetPendingAssignment(WhseActivityLine, ContainerHeader);
                ContainerHeader.Modify;

                "Container ID" := ContainerHeader.ID;
                VALIDATE("Container License Plate", ContainerHeader."License Plate"); // P80099521
            end;
        end;
    end;

    procedure NewContainerOnWhseJournalLine(var WhseJournalLine: Record "Warehouse Journal Line")
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ContainerHeader: Record "Container Header";
    begin
        // P8001323
        with WhseJournalLine do begin
            if Quantity < 0 then
                exit;
            TestField("Item No.");
            TestField("Unit of Measure Code");
            if "Entry Type" = "Entry Type"::Movement then begin
                TestField("To Container License Plate", '');
                TestField("To Bin Code");
            end else begin
                TestField("Container License Plate", '');
                TestField("Bin Code");
            end;
            if Item."Item Tracking Code" <> '' then begin
                ItemTrackingCode.Get(Item."Item Tracking Code");
                if ItemTrackingCode."Lot Specific Tracking" then
                    TestField("Lot No.");
            end;

            if CreateNewContainer('', false, "Location Code", "To Bin Code", "Item No.", "Unit of Measure Code", ContainerHeader) then begin // P8004339
                ContainerHeader.Modify;

                "To Container ID" := ContainerHeader.ID;
                "To Container License Plate" := ContainerHeader."License Plate";
                if "Entry Type" <> "Entry Type"::Movement then
                    "Container License Plate" := ContainerHeader."License Plate";
            end;
        end;
    end;

    procedure NewContainerOnContainerAssignment(var ContainerAssignment: Record "Container Assignment")
    var
        ContainerHeader: Record "Container Header";
    begin
        // P8004339
        // P8008176 - change BinCode to Code20
        // P80046533
        if CreateNewContainer(ContainerAssignment."Container Type Code", ContainerAssignment.Inbound,
            ContainerAssignment."Location Code", ContainerAssignment."Bin Code", '', '', ContainerHeader)
        then
            ContainerAssignment.Validate("License Plate", ContainerHeader."License Plate");
    end;

    local procedure CreateNewContainer(ContainerTypeCode: Code[10]; Inbound: Boolean; LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; UOMCode: Code[10]; var ContainerHeader: Record "Container Header"): Boolean
    var
        ContainerCard: Page Container;
    begin
        // P8001323
        // P8004339 - add parameters ContainerTypeCode, Inbound
        // P8008176 - change BinCode to Code20
        ContainerHeader.Insert(true);
        // P8004339
        ContainerHeader.Validate(Inbound, Inbound);
        if ContainerTypeCode <> '' then
            ContainerHeader.Validate("Container Type Code", ContainerTypeCode);
        // P8004339
        ContainerHeader.Validate("Location Code", LocationCode);
        ContainerHeader.Validate("Bin Code", BinCode);
        ContainerHeader.Modify;
        Commit;

        ContainerHeader.FilterGroup(9);
        ContainerHeader.SetRange(ID, ContainerHeader.ID);
        ContainerHeader.FilterGroup(0);
        ContainerCard.SetTableView(ContainerHeader);
        ContainerCard.NewContainerItem(ItemNo, UOMCode);
        ContainerCard.LookupMode(true);
        if ContainerCard.RunModal = ACTION::LookupCancel then begin
            ContainerCard.GetRecord(ContainerHeader);
            if ContainerHeader.Delete then;
            exit(false);
        end else begin
            ContainerCard.GetRecord(ContainerHeader);
            exit(true);
        end;
    end;

    procedure SetPendingAssignment(WhseActivityLine: Record "Warehouse Activity Line"; var ContainerHeader: Record "Container Header")
    var
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
    begin
        // P8001323
        // P80056709 - renamed from SetPendingShippingContainer
        with WhseActivityLine do
            if (("Source Type" = DATABASE::"Sales Line") and ("Source Subtype" = SalesHeader."Document Type"::Order)) or
               (("Source Type" = DATABASE::"Purchase Line") and ("Source Subtype" = PurchHeader."Document Type"::"Return Order")) or
               (("Source Type" = DATABASE::"Transfer Line") and ("Source Subtype" = 0)) or // P80063544
               ("Source Type" = DATABASE::"Prod. Order Component") // P80056709
            then begin
                ContainerHeader."Document Type" := "Source Type";
                ContainerHeader."Document Subtype" := "Source Subtype";
                ContainerHeader."Document No." := "Source No.";
                ContainerHeader."Document Line No." := ContainerHeader.SourceLineNo("Source Type", "Source Subtype", "Source Line No."); // P80056709
                ContainerHeader."Pending Assignment" := true;
                if "Source Type" <> DATABASE::"Prod. Order Component" then begin // P80056709
                    ContainerHeader."Whse. Document Type" := "Whse. Document Type";
                    ContainerHeader."Whse. Document No." := "Whse. Document No.";
                end; // P80056710
            end;
    end;

    procedure ClearPendingAssignment(WhseActivityLine: Record "Warehouse Activity Line")
    var
        ContainerHeader: Record "Container Header";
        WhseActivityLine2: Record "Warehouse Activity Line";
    begin
        // P8001323
        // P80056709 - renamed from ClearPendingShippingContainer
        with WhseActivityLine do begin
            ContainerHeader.Get("Container ID");
            // P80056710
            if (ContainerHeader."Document Type" = DATABASE::"Prod. Order Component") and (not ContainerHeader."Pending Assignment") then // P80060004
                exit;
            // P80056709
            if ContainerHeader."Document Type" <> 0 then begin
                WhseActivityLine2.SetRange("Activity Type", "Activity Type");
                WhseActivityLine2.SetRange("No.", "No.");
                WhseActivityLine2.SetFilter("Line No.", '<>%1', "Line No.");
                WhseActivityLine2.SetRange("Action Type", WhseActivityLine2."Action Type"::Place);
                WhseActivityLine2.SetRange("Container ID", "Container ID");
                if WhseActivityLine2.IsEmpty then begin
                    ContainerHeader."Document Type" := 0;
                    ContainerHeader."Document Subtype" := 0;
                    ContainerHeader."Document No." := '';
                    ContainerHeader."Document Line No." := 0; // P80056709
                    ContainerHeader."Pending Assignment" := false;
                    ContainerHeader."Whse. Document Type" := 0;
                    ContainerHeader."Whse. Document No." := '';
                    ContainerHeader."Transfer-to Bin Code" := '';
                    ContainerHeader.Modify;
                end;
            end;
        end;
    end;

    local procedure IsContainerBeingMoved(WhseActivityLine: Record "Warehouse Activity Line"): Boolean
    var
        WhseActivityLine2: Record "Warehouse Activity Line";
    begin
        // P8001323
        with WhseActivityLine do begin
            WhseActivityLine2.SetRange("Activity Type", "Activity Type");
            WhseActivityLine2.SetRange("No.", "No.");
            if "Action Type" = "Action Type"::Take then
                WhseActivityLine2.SetRange("Action Type", WhseActivityLine2."Action Type"::Place)
            else
                WhseActivityLine2.SetRange("Action Type", WhseActivityLine2."Action Type"::Take);
            WhseActivityLine2.SetRange("Container ID", "Container ID");
            exit(not WhseActivityLine2.IsEmpty);
        end;
    end;

    procedure SetContainerDocumentLineSource(SourceRec: Variant; Direction: Integer)
    var
        SourceRecRef: RecordRef;
        Container: Record "Container Header";
        ContainerLineAppl: Record "Container Line Application";
        ContainerLine: Record "Container Line";
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
    begin
        // P8001342
        TempContainerLineToPost.Reset;
        TempContainerLineToPost.DeleteAll;

        SourceRecRef.GetTable(SourceRec);

        case SourceRecRef.Number of
            DATABASE::"Sales Line":
                begin
                    SalesLine := SourceRec;
                    ContainerLineAppl.SetRange("Application Table No.", DATABASE::"Sales Line");
                    ContainerLineAppl.SetRange("Application Subtype", SalesLine."Document Type");
                    ContainerLineAppl.SetRange("Application No.", SalesLine."Document No.");
                    ContainerLineAppl.SetRange("Application Line No.", SalesLine."Line No.");
                end;
            DATABASE::"Purchase Line":
                begin
                    PurchLine := SourceRec;
                    ContainerLineAppl.SetRange("Application Table No.", DATABASE::"Purchase Line");
                    ContainerLineAppl.SetRange("Application Subtype", PurchLine."Document Type");
                    ContainerLineAppl.SetRange("Application No.", PurchLine."Document No.");
                    ContainerLineAppl.SetRange("Application Line No.", PurchLine."Line No.");
                end;
            DATABASE::"Transfer Line":
                begin
                    TransLine := SourceRec;
                    ContainerLineAppl.SetRange("Application Table No.", DATABASE::"Transfer Line");
                    ContainerLineAppl.SetRange("Application Subtype", Direction);
                    ContainerLineAppl.SetRange("Application No.", TransLine."Document No.");
                    ContainerLineAppl.SetRange("Application Line No.", TransLine."Line No.");
                end;
        end;

        ContainerLineAppl.SetCurrentKey("Container ID"); // P80046533
        if ContainerLineAppl.FindSet then
            repeat
                // P80046533
                ContainerLineAppl.SetRange("Container ID", ContainerLineAppl."Container ID");
                Container.Get(ContainerLineAppl."Container ID");
                if Container."Ship/Receive" then begin
                    repeat
                        // P80046533
                        ContainerLine.Get(ContainerLineAppl."Container ID", ContainerLineAppl."Container Line No.");
                        TempContainerLineToPost.SetRange("Item No.", ContainerLine."Item No.");
                        TempContainerLineToPost.SetRange("Variant Code", ContainerLine."Variant Code");
                        TempContainerLineToPost.SetRange("Unit of Measure Code", ContainerLine."Unit of Measure Code");
                        TempContainerLineToPost.SetRange("Lot No.", ContainerLine."Lot No.");
                        TempContainerLineToPost.SetRange("Serial No.", ContainerLine."Serial No.");
                        TempContainerLineToPost.SetRange("Bin Code", ContainerLine."Bin Code");
                        if TempContainerLineToPost.FindFirst then begin
                            TempContainerLineToPost.Quantity += ContainerLineAppl.Quantity;
                            //TempContainerLineToPost."Quantity (baSE)" += ContainerLineAppl."Quantity (base)";
                            TempContainerLineToPost."Quantity (Alt.)" += ContainerLineAppl."Quantity (Alt.)";
                            TempContainerLineToPost.Modify;
                        end else begin
                            TempContainerLineToPost := ContainerLine;
                            TempContainerLineToPost.Quantity := ContainerLineAppl.Quantity;
                            //TempContainerLineToPost."Quantity (baSE)" := ContainerLineAppl."Quantity (base)";
                            TempContainerLineToPost."Quantity (Alt.)" := ContainerLineAppl."Quantity (Alt.)";
                            TempContainerLineToPost.Insert;
                        end;
                    until ContainerLineAppl.Next = 0;
                    // P80046533
                end else
                    ContainerLineAppl.FindLast;
                ContainerLineAppl.SetRange("Container ID");
            // P80046533
            //IF TempContainerLine.INSERT THEN; // Necessary??
            until ContainerLineAppl.Next = 0;

        PostedFromDocument := true;
    end;

    procedure GetItemJnlContainerQuantity(var ItemJnlLine: Record "Item Journal Line")
    var
        Qty: Decimal;
    begin
        // P8001343
        if not PostedFromDocument then
            if ItemJnlLine."Old Container ID" = '' then begin
                ItemJnlLine."Loose Qty. (Base)" := ItemJnlLine."Quantity (Base)";
                ItemJnlLine."Loose Qty. (Alt.)" := ItemJnlLine."Quantity (Alt.)";
                exit;
            end else
                exit;

        TempContainerLineToPost.SetRange("Item No.", ItemJnlLine."Item No.");
        TempContainerLineToPost.SetRange("Variant Code", ItemJnlLine."Variant Code");
        TempContainerLineToPost.SetRange("Unit of Measure Code", ItemJnlLine."Unit of Measure Code");
        TempContainerLineToPost.SetRange("Lot No.", ItemJnlLine."Lot No.");
        TempContainerLineToPost.SetRange("Serial No.", ItemJnlLine."Serial No.");
        TempContainerLineToPost.SetRange("Bin Code", ItemJnlLine."Bin Code");
        if TempContainerLineToPost.FindFirst then begin
            if TempContainerLineToPost.Quantity < ItemJnlLine.Quantity then
                Qty := TempContainerLineToPost.Quantity
            else
                Qty := ItemJnlLine.Quantity;
            if Qty = ItemJnlLine.Quantity then
                ItemJnlLine."Loose Qty. (Base)" := 0
            else
                ItemJnlLine."Loose Qty. (Base)" := ItemJnlLine."Quantity (Base)" - Round(Qty * TempContainerLineToPost."Qty. per Unit of Measure", 0.00001);

            if TempContainerLineToPost."Quantity (Alt.)" < ItemJnlLine."Quantity (Alt.)" then
                ItemJnlLine."Loose Qty. (Alt.)" := ItemJnlLine."Quantity (Alt.)" - TempContainerLineToPost."Quantity (Alt.)"
            else
                ItemJnlLine."Loose Qty. (Alt.)" := 0;

            TempContainerLineToPost.Quantity -= Qty;
            TempContainerLineToPost."Quantity (Alt.)" -= ItemJnlLine."Quantity (Alt.)" - ItemJnlLine."Loose Qty. (Alt.)";
            TempContainerLineToPost.Modify;
        end else begin
            ItemJnlLine."Loose Qty. (Base)" := ItemJnlLine."Quantity (Base)";
            ItemJnlLine."Loose Qty. (Alt.)" := ItemJnlLine."Quantity (Alt.)";
        end;
    end;

    procedure GetWhseEntryContainerQuantity(var WhseEntry: Record "Warehouse Entry"): Decimal
    var
        ContainerLineAppl: Record "Container Line Application";
    begin
        // P8001343
        if WhseEntry."Source Type" = 0 then
            exit;

        ContainerLineAppl.SetRange("Application Table No.", WhseEntry."Source Type");
        ContainerLineAppl.SetRange("Application Subtype", WhseEntry."Source Subtype");
        ContainerLineAppl.SetRange("Application No.", WhseEntry."Source No.");
        ContainerLineAppl.SetRange("Application Line No.", WhseEntry."Source Line No.");
        ContainerLineAppl.CalcSums(Quantity);
        exit(ContainerLineAppl.Quantity);
    end;

    procedure LookupContainerOnItemJnlLine(ItemJnlLine: Record "Item Journal Line"; FldNo: Integer; var Text: Text): Boolean
    var
        TempContainerHeader: Record "Container Header" temporary;
    begin
        // P8004516
        LookupContainerOnItemJnlLine2(ItemJnlLine, FldNo, TempContainerHeader);

        if TempContainerHeader.FindFirst then;
        if PAGE.RunModal(0, TempContainerHeader) = ACTION::LookupOK then begin
            Text := TempContainerHeader."License Plate";
            exit(true);
        end;
    end;

    procedure LookupContainerOnItemJnlLine2(ItemJnlLine: Record "Item Journal Line"; FldNo: Integer; var TempContainerHeader: Record "Container Header" temporary)
    var
        ContainerHeader: Record "Container Header";
        ContainerLine: Record "Container Line";
        FromTo: Option From,"To";
        LocationCode: Code[10];
        ItemNo: Code[20];
        VariantCode: Code[10];
        LotNo: Code[50];
        UOMCode: Code[10];
        BinCode: Code[20];
        sign: Decimal;
    begin
        // P8004516
        // P8001323
        with ItemJnlLine do begin
            ItemNo := "Item No.";
            VariantCode := "Variant Code";
            LotNo := "Lot No.";
            UOMCode := "Unit of Measure Code";
            case FldNo of
                FieldNo("Old Container License Plate"):
                    begin
                        FromTo := FromTo::From;
                        LocationCode := "Location Code";
                        BinCode := "Bin Code";
                    end;
                FieldNo("New Container License Plate"):
                    begin
                        FromTo := FromTo::"To";
                        LocationCode := "New Location Code";
                        BinCode := "New Bin Code";
                    end;
                FieldNo("Container License Plate"):
                    begin
                        if Quantity = 0 then
                            sign := Signed(1)
                        else
                            sign := Signed(Quantity);
                        if sign < 0 then
                            FromTo := FromTo::From
                        else
                            FromTo := FromTo::"To";
                        LocationCode := "Location Code";
                        BinCode := "Bin Code";
                    end;
            end;
        end;

        case FromTo of
            FromTo::From:
                begin
                    ContainerLine.SetRange(Inbound, false);
                    ContainerLine.SetRange("Location Code", LocationCode);
                    if ItemNo <> '' then
                        ContainerLine.SetRange("Item No.", ItemNo);
                    if VariantCode <> '' then
                        ContainerLine.SetRange("Variant Code", VariantCode);
                    if UOMCode <> '' then
                        ContainerLine.SetRange("Unit of Measure Code", UOMCode);
                    if LotNo <> '' then
                        ContainerLine.SetRange("Lot No.", LotNo);
                    if BinCode <> '' then
                        ContainerLine.SetRange("Bin Code", BinCode);
                    if ContainerLine.FindSet then
                        repeat
                            ContainerHeader.Get(ContainerLine."Container ID");
                            // P80056710
                            if (ContainerHeader."Document Type" = 0) or
                               ((ContainerHeader."Document Type" = DATABASE::"Prod. Order Component") and (ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Consumption))
                            then begin
                                // P80056710
                                TempContainerHeader := ContainerHeader;
                                if TempContainerHeader.Insert then;
                            end;
                        until ContainerLine.Next = 0;
                end;

            FromTo::"To":
                begin
                    ContainerHeader.SetRange("Location Code", LocationCode);
                    ContainerHeader.SetRange("Bin Code", BinCode);
                    ContainerHeader.SetRange(Inbound, false);
                    if ContainerHeader.FindSet then
                        repeat
                            if ContainerHeader.IsHeaderComplete then
                                if ContainerHeader."Document Type" = 0 then begin
                                    TempContainerHeader := ContainerHeader;
                                    TempContainerHeader.Insert;
                                end;
                        until ContainerHeader.Next = 0;
                end;
        end;
    end;

    procedure NewContainerOnItemJournalLine(var ItemJournalLine: Record "Item Journal Line")
    var
        Location: Record Location;
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ContainerHeader: Record "Container Header";
        BinCode: Code[20];
        Sign: Decimal;
    begin
        // P8001323
        with ItemJournalLine do begin
            if "Entry Type" <> "Entry Type"::Transfer then begin
                if Quantity = 0 then
                    Sign := Signed(1)
                else
                    Sign := Signed(Quantity);
                if Sign < 0 then
                    exit;
            end;

            TestField("Item No.");
            TestField("Unit of Measure Code");
            TestField("Qty. (Calculated)", 0); // P8004242
            if "Entry Type" = "Entry Type"::Transfer then begin
                TestField("New Container License Plate", '');
                TestField("New Location Code");
                Location.Get("New Location Code");
                if Location."Bin Mandatory" then
                    TestField("New Bin Code");
                BinCode := "New Bin Code";
            end else begin
                TestField("Container License Plate", '');
                TestField("Location Code");
                Location.Get("Location Code");
                if Location."Bin Mandatory" then
                    TestField("Bin Code");
                BinCode := "Bin Code";
            end;
            Item.Get("Item No.");
            if Item."Item Tracking Code" <> '' then begin
                ItemTrackingCode.Get(Item."Item Tracking Code");
                if ItemTrackingCode."Lot Specific Tracking" then
                    TestField("Lot No.");
            end;

            if CreateNewContainer('', false, Location.Code, BinCode, "Item No.", "Unit of Measure Code", ContainerHeader) then begin // P8004339
                ContainerHeader.Modify;

                "New Container ID" := ContainerHeader.ID;
                "New Container License Plate" := ContainerHeader."License Plate";
                if "Entry Type" <> "Entry Type"::Transfer then
                    "Container License Plate" := ContainerHeader."License Plate";
            end;
        end;
    end;

    // P800127049
    procedure NewContainerOnInvtDocLine(var InvtDocLine: Record "Invt. Document Line")
    var
        InvtDocHeader: Record "Invt. Document Header";
        Location: Record Location;
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ContainerHeader: Record "Container Header";
        BinCode: Code[20];
    begin
        InvtDocHeader.Get(InvtDocLine."Document Type", InvtDocLine."Document No.");
        if ((InvtDocHeader."Document Type" = InvtDocHeader."Document Type"::Receipt) and InvtDocHeader.Correction) or
           ((InvtDocHeader."Document Type" = InvtDocHeader."Document Type"::Shipment) and (not InvtDocHeader.Correction))
        then
            exit;

        InvtDocLine.TestField("Item No.");
        InvtDocLine.TestField("Unit of Measure Code");
        InvtDocLine.TestField("FOOD Container License Plate", '');
        InvtDocLine.TestField("Location Code");
        Location.Get(InvtDocLine."Location Code");
        if Location."Bin Mandatory" then
            InvtDocLine.TestField("Bin Code");
        BinCode := InvtDocLine."Bin Code";
        Item.Get(InvtDocLine."Item No.");
        if Item."Item Tracking Code" <> '' then begin
            ItemTrackingCode.Get(Item."Item Tracking Code");
            if ItemTrackingCode."Lot Specific Tracking" then
                InvtDocLine.TestField("FOOD Lot No.");
        end;

        if CreateNewContainer('', false, Location.Code, BinCode, InvtDocLine."Item No.", InvtDocLine."Unit of Measure Code", ContainerHeader) then begin
            ContainerHeader.Modify();

            InvtDocLine."FOOD New Container ID" := ContainerHeader.ID;
            InvtDocLine."FOOD New License Plate" := ContainerHeader."License Plate";
            InvtDocLine."FOOD Container License Plate" := ContainerHeader."License Plate";
        end;
    end;

    // P800127049
    procedure LookupContainerOnInvtDocLine(InvtDocLine: Record "Invt. Document Line"; var Text: Text): Boolean
    var
        TempContainerHeader: Record "Container Header" temporary;
    begin
        LookupContainerOnInvtDocLine2(InvtDocLine, TempContainerHeader);

        if TempContainerHeader.FindFirst() then;
        if PAGE.RunModal(0, TempContainerHeader) = ACTION::LookupOK then begin
            Text := TempContainerHeader."License Plate";
            exit(true);
        end;
    end;

    // P800127049
    procedure LookupContainerOnInvtDocLine2(InvtDocLine: Record "Invt. Document Line"; var TempContainerHeader: Record "Container Header" temporary)
    var
        InvtDocHeader: Record "Invt. Document Header";
        ContainerHeader: Record "Container Header";
        ContainerLine: Record "Container Line";
        FromTo: Option From,"To";
        LocationCode: Code[10];
        ItemNo: Code[20];
        VariantCode: Code[10];
        LotNo: Code[50];
        UOMCode: Code[10];
        BinCode: Code[20];
    begin
        InvtDocHeader.Get(InvtDocLine."Document Type", InvtDocLine."Document No.");
        if ((InvtDocHeader."Document Type" = InvtDocHeader."Document Type"::Receipt) and InvtDocHeader.Correction) or
           ((InvtDocHeader."Document Type" = InvtDocHeader."Document Type"::Shipment) and (not InvtDocHeader.Correction))
        then
            FromTo := FromTo::From
        else
            FromTo := FromTo::"To";

        ItemNo := InvtDocLine."Item No.";
        VariantCode := InvtDocLine."Variant Code";
        LotNo := InvtDocLine."FOOD Lot No.";
        UOMCode := InvtDocLine."Unit of Measure Code";
        LocationCode := InvtDocLine."Location Code";
        BinCode := InvtDocLine."Bin Code";

        case FromTo of
            FromTo::From:
                begin
                    ContainerLine.SetRange(Inbound, false);
                    ContainerLine.SetRange("Location Code", LocationCode);
                    if ItemNo <> '' then
                        ContainerLine.SetRange("Item No.", ItemNo);
                    if VariantCode <> '' then
                        ContainerLine.SetRange("Variant Code", VariantCode);
                    if UOMCode <> '' then
                        ContainerLine.SetRange("Unit of Measure Code", UOMCode);
                    if LotNo <> '' then
                        ContainerLine.SetRange("Lot No.", LotNo);
                    if BinCode <> '' then
                        ContainerLine.SetRange("Bin Code", BinCode);
                    if ContainerLine.FindSet() then
                        repeat
                            ContainerHeader.Get(ContainerLine."Container ID");
                            if ContainerHeader."Document Type" = 0 then begin
                                TempContainerHeader := ContainerHeader;
                                if TempContainerHeader.Insert() then;
                            end;
                        until ContainerLine.Next() = 0;
                end;

            FromTo::"To":
                begin
                    ContainerHeader.SetRange("Location Code", LocationCode);
                    ContainerHeader.SetRange("Bin Code", BinCode);
                    ContainerHeader.SetRange(Inbound, false);
                    if ContainerHeader.FindSet() then
                        repeat
                            if ContainerHeader.IsHeaderComplete then
                                if ContainerHeader."Document Type" = 0 then begin
                                    TempContainerHeader := ContainerHeader;
                                    TempContainerHeader.Insert();
                                end;
                        until ContainerHeader.Next() = 0;
                end;
        end;
    end;

    procedure CheckContainerAssignment(ContainerID: Code[20])
    var
        ContainerHeader: Record "Container Header";
    begin
        // P8001323
        // P80056709 - renamed from CheckShippingContainer
        if ContainerID <> '' then begin
            ContainerHeader.Get(ContainerID);
            if ContainerHeader."Document Type" <> 0 then
                Error(Text004, ContainerHeader."License Plate", ContainerHeader.AssignmentText); // P80056709
        end;
    end;

    procedure CheckContainerAssignment2(ContainerID: Code[20]; ItemJournalLine: Record "Item Journal Line")
    var
        ContainerHeader: Record "Container Header";
        Location: Record Location;
        ProductionOrder: Record "Production Order";
        DocumentLineNo: Integer;
        ThrowError: Boolean;
    begin
        // P80056718
        if ContainerID <> '' then begin
            ContainerHeader.Get(ContainerID);
            if ItemJournalLine."Entry Type" <> ItemJournalLine."Entry Type"::Consumption then begin
                if ContainerHeader."Document Type" <> 0 then
                    ThrowError := true;
            end else begin
                if not (ContainerHeader."Document Type" in [0, DATABASE::"Prod. Order Component"]) then
                    ThrowError := true
                else
                    if ContainerHeader."Document Type" = DATABASE::"Prod. Order Component" then begin
                        if Location.Get(ItemJournalLine."Location Code") then;
                        if Location."Pick Production by Line" then
                            DocumentLineNo := ItemJournalLine."Order Line No."
                        else
                            DocumentLineNo := 0;
                        if (ProductionOrder.Status::Released <> ContainerHeader."Document Subtype") or
                           (ItemJournalLine."Order No." <> ContainerHeader."Document No.") or
                           (DocumentLineNo <> ContainerHeader."Document Line No.")
                        then
                            ThrowError := true;
                    end;
            end;

            if ThrowError then
                Error(Text004, ContainerHeader."License Plate", ContainerHeader.AssignmentText); // P80056709
        end;
    end;

    procedure CreateSSCC(CompanyPrefix: Code[12]; ExtensionDigit: Code[1]; ReferenceNo: Integer) SSCC: Code[18]
    begin
        // P80055555
        if (CompanyPrefix = '') or (ReferenceNo = 0) then
            exit('');

        if ExtensionDigit = '' then
            ExtensionDigit := '0';

        SSCC := ExtensionDigit + CompanyPrefix +
          Format(ReferenceNo, 0, StrSubstNo('<Integer,%1><Filler,0>', 16 - StrLen(CompanyPrefix)));
        SSCC := SSCC + Format(StrCheckSum(SSCC, '31313131313131313'));
    end;

    procedure NewContainerOnWhsePreProcessActivityLine(var ActivityLine: Record "Pre-Process Activity Line")
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ContainerHeader: Record "Container Header";
        Activity: Record "Pre-Process Activity";
    begin
        // P80057829
        with ActivityLine do begin
            Activity.Get("Activity No.");
            Activity.TestField(Blending, Activity.Blending::" ");
            if "Qty. to Process" < 0 then
                exit;
            TestField("Item No.");
            TestField("Unit of Measure Code");
            TestField("To Container License Plate", '');
            Activity.TestField("From Bin Code");

            if CreateNewContainer('', false, Activity."Location Code", Activity."From Bin Code", "Item No.", "Unit of Measure Code", ContainerHeader) then begin
                ContainerHeader.Modify;

                "To Container ID" := ContainerHeader.ID;
                "To Container License Plate" := ContainerHeader."License Plate";
            end;
        end;
    end;

    procedure RemoveFromContainer(ContainerID: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UOMCode: Code[10]; LotNo: Code[50]; SerialNo: Code[50]; TotalQtyToRemove: Decimal; TotalQtyToRemoveAlt: Decimal; var PostContainerLine: Record "Container Line")
    var
        Item: Record Item;
        ContainerHeader: Record "Container Header";
        ContainerLine: Record "Container Line";
        ContainerLine2: Record "Container Line";
        QtyToRemove: Decimal;
        QtyToRemoveAlt: Decimal;
        QtyAlt: Decimal;
        InsufficientQty: Label 'Insufficient quantity in container %1 to complete this action.';
        ExcessQty: Label 'To complete this action would leave excess quantity in container %1.';
    begin
        Item.Get(ItemNo);
        if (Item."Alternate Unit of Measure" = '') or (not Item."Catch Alternate Qtys.") then
            TotalQtyToRemoveAlt := 0;

        ContainerLine.Reset;
        ContainerLine.SetRange("Container ID", ContainerID);
        ContainerLine.SetRange("Item No.", ItemNo);
        ContainerLine.SetRange("Variant Code", VariantCode);
        ContainerLine.SetRange("Unit of Measure Code", UOMCode);
        ContainerLine.SetRange("Lot No.", LotNo);
        ContainerLine.SetRange("Serial No.", SerialNo);
        if ContainerLine.FindSet(true) then
            repeat
                ContainerLine2 := ContainerLine;
                if ContainerLine.Quantity < TotalQtyToRemove then
                    QtyToRemove := ContainerLine.Quantity
                else
                    QtyToRemove := TotalQtyToRemove;

                if (Item."Alternate Unit of Measure" <> '') and Item."Catch Alternate Qtys." then begin
                    if ContainerLine."Quantity (Alt.)" < TotalQtyToRemoveAlt then
                        QtyToRemoveAlt := ContainerLine."Quantity (Alt.)"
                    else
                        QtyToRemoveAlt := TotalQtyToRemoveAlt;
                    QtyAlt := ContainerLine."Quantity (Alt.)" - QtyToRemoveAlt;
                end;

                ContainerLine.Quantity -= QtyToRemove;
                ContainerLine.Validate(Quantity);
                if (Item."Alternate Unit of Measure" <> '') and Item."Catch Alternate Qtys." then begin
                    ContainerLine.Validate("Quantity (Alt.)", QtyAlt);
                    QtyToRemoveAlt += QtyAlt - ContainerLine."Quantity (Alt.)";
                end;

                if (ContainerLine.Quantity = 0) or ((ContainerLine."Quantity (Alt.)" = 0) and (Item."Alternate Unit of Measure" <> '')) then begin
                    ContainerLine.Delete;
                    if ContainerLine.Quantity <> 0 then
                        QtyToRemove += ContainerLine.Quantity;
                end else
                    ContainerLine.Modify;

                PostContainerLine := ContainerLine;
                PostContainerLine.PostContainerUse(ContainerLine2.Quantity, ContainerLine2."Quantity (Alt.)", ContainerLine.Quantity, ContainerLine."Quantity (Alt.)");

                TotalQtyToRemove -= QtyToRemove;
                TotalQtyToRemoveAlt -= QtyToRemoveAlt;
            until (ContainerLine.Next = 0) or ((TotalQtyToRemove = 0) and (TotalQtyToRemoveAlt = 0));

        if (0 < TotalQtyToRemove) or (0 < TotalQtyToRemoveAlt) then begin
            ContainerHeader.Get(ContainerID);
            Error(InsufficientQty, ContainerHeader."License Plate");
        end;
        if (0 > TotalQtyToRemove) or (0 > TotalQtyToRemoveAlt) then begin
            ContainerHeader.Get(ContainerID);
            Error(ExcessQty, ContainerHeader."License Plate");
        end;

        ContainerLine.Reset;
        ContainerLine.SetRange("Container ID", ContainerID);
        if ContainerLine.IsEmpty then
            if ContainerHeader.Get(ContainerID) then
                ContainerHeader.Delete(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesShptLineInsert', '', true, false)]
    local procedure SalesPost_OnAfterSalesShptLineInsert(var SalesShipmentLine: Record "Sales Shipment Line"; SalesLine: Record "Sales Line")
    var
        ContainerLine: Record "Container Line";
        ContainerLineApplication: Record "Container Line Application";
    begin
        // P80067617
        ContainerLineApplication.SetRange("Application Table No.", DATABASE::"Sales Line");
        ContainerLineApplication.SetRange("Application Subtype", SalesLine."Document Type");
        ContainerLineApplication.SetRange("Application No.", SalesLine."Document No.");
        ContainerLineApplication.SetRange("Application Line No.", SalesLine."Line No.");
        if ContainerLineApplication.FindSet then
            repeat
                ContainerLine.Get(ContainerLineApplication."Container ID", ContainerLineApplication."Container Line No.");
                ContainerLine."Quantity Posted" += ContainerLineApplication.Quantity;
                ContainerLine."Quantity Posted (Base)" += ContainerLineApplication."Quantity (Base)";
                ContainerLine."Quantity Posted (Alt.)" += ContainerLineApplication."Quantity (Alt.)";
                ContainerLine.Modify;
            until ContainerLineApplication.Next = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterReturnShptLineInsert', '', true, false)]
    local procedure PurchPost_OnAfterReturnShptLineInsert(var ReturnShptLine: Record "Return Shipment Line"; ReturnShptHeader: Record "Return Shipment Header"; PurchLine: Record "Purchase Line"; ItemLedgShptEntryNo: Integer; WhseShip: Boolean; WhseReceive: Boolean)
    var
        ContainerLine: Record "Container Line";
        ContainerLineApplication: Record "Container Line Application";
    begin
        // P80067617
        ContainerLineApplication.SetRange("Application Table No.", DATABASE::"Purchase Line");
        ContainerLineApplication.SetRange("Application Subtype", PurchLine."Document Type");
        ContainerLineApplication.SetRange("Application No.", PurchLine."Document No.");
        ContainerLineApplication.SetRange("Application Line No.", PurchLine."Line No.");
        if ContainerLineApplication.FindSet then
            repeat
                ContainerLine.Get(ContainerLineApplication."Container ID", ContainerLineApplication."Container Line No.");
                ContainerLine."Quantity Posted" += ContainerLineApplication.Quantity;
                ContainerLine."Quantity Posted (Base)" += ContainerLineApplication."Quantity (Base)";
                ContainerLine."Quantity Posted (Alt.)" += ContainerLineApplication."Quantity (Alt.)";
                ContainerLine.Modify;
            until ContainerLineApplication.Next = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnAfterInsertTransShptLine', '', true, false)]
    local procedure TransferOrderPostShipment_OnAfterInsertTransShptLine(var TransShptLine: Record "Transfer Shipment Line"; TransLine: Record "Transfer Line"; CommitIsSuppressed: Boolean)
    var
        ContainerLine: Record "Container Line";
        ContainerLineApplication: Record "Container Line Application";
    begin
        // P80067617
        ContainerLineApplication.SetRange("Application Table No.", DATABASE::"Transfer Line");
        ContainerLineApplication.SetRange("Application Subtype", 0);
        ContainerLineApplication.SetRange("Application No.", TransLine."Document No.");
        ContainerLineApplication.SetRange("Application Line No.", TransLine."Line No.");
        if ContainerLineApplication.FindSet then
            repeat
                ContainerLine.Get(ContainerLineApplication."Container ID", ContainerLineApplication."Container Line No.");
                ContainerLine."Quantity Posted" += ContainerLineApplication.Quantity;
                ContainerLine."Quantity Posted (Base)" += ContainerLineApplication."Quantity (Base)";
                ContainerLine."Quantity Posted (Alt.)" += ContainerLineApplication."Quantity (Alt.)";
                ContainerLine.Modify;
            until ContainerLineApplication.Next = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateOnWhseActivityLineOnBeforeShowContQtyToHandle(var WarehouseActivityLine: Record "Warehouse Activity Line"; var ContainerLine: Record "Container Line" temporary; Item: Record Item; var Handled: Boolean)
    begin
        // P80082969
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateOnWhseActivityLineOnBeforeSplitLine(var WarehouseActivityLine: Record "Warehouse Activity Line"; var Handled: Boolean)
    begin
        // P80082969
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateOnWhseActivityLineOnBeforeCheckContQtyToHandle(Item: Record Item; var Handled: Boolean; var WarehouseActivityLine: Record "Warehouse Activity Line"; var TempContainerLine: Record "Container Line" temporary)
    begin
        // P80092182, P80098649
    end;

    local procedure GetClosedContainerItemNo(ContainerId: Code[20]): Code[20]
    var
        ContainerLine: Record "Container Line";
    begin
        // P800117005
        ContainerLine.SetRange("Container ID", ContainerId);
        IF ContainerLine.FindFirst() then begin
            ContainerLine.SetFilter("Item No.", '<>%1', ContainerLine."Item No.");
            IF ContainerLine.IsEmpty then
                Exit(ContainerLine."Item No.");
            Exit('');
        end;
    end;

    local procedure CheckWhseRegisteredPickExists(ContainerHeader: Record "Container Header"): Boolean
    var
        RegisteredWhseActivityLine: Record "Registered Whse. Activity Line";
    begin
        // P800142458
        if ContainerHeader."Whse. Document Type" <> ContainerHeader."Whse. Document Type"::Shipment then
            exit(false);

        RegisteredWhseActivityLine.SetRange("Whse. Document Type", RegisteredWhseActivityLine."Whse. Document Type"::Shipment);
        RegisteredWhseActivityLine.SetRange("Container ID", ContainerHeader.ID);
        exit(not RegisteredWhseActivityLine.IsEmpty());
    end;
}

