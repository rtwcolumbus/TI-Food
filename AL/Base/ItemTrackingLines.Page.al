page 6510 "Item Tracking Lines"
{
    // PR3.61
    //   Alternate quantity fixes
    //   Add logic form container tracking
    // 
    // PR3.61.01
    //   Modify for alternate quantities on credit memos
    // 
    // PR3.70
    //   CollectPostedOutputEntries - add logic for alternate quantities
    // 
    // PR3.70.04
    // P8000043A, Myers Nissi, Jack Reynolds, 25 MAY 04
    //   Replace RegisterAltQtyLines with more generalized RegisterP800Tracking
    // 
    // PR3.70.07
    // P8000150A, Myers Nissi, Jack Reynolds, 22 NOV 04
    //   RegisterP800Tracking - for drop shipments synchronize linked sources
    // 
    // PR4.00
    // P8000250B, Myers Nissi, Jack Reynolds, 18 OCT 05
    //   Support for alternate lot number assignemnt methods
    // 
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Call AltQtyMgmt.UpdateTrackingLotSerial in OnModifyRecord
    // 
    // PR4.00.03
    // P8000339A, VerticalSoft, Jack Reynolds, 15 MAY 06
    //   Add support for alternate quantity when called from reclass journal
    // 
    // P8000343A, VerticalSoft, Jack Reynolds, 05 JUN 06
    //   Modify to support easy lot with reclass journal
    // 
    // PR4.00.04
    // P8000354A, VerticalSoft, Jack Reynolds, 18 JUL 06
    //   Fix problem updating linked tracking line for alternate quantity to handle
    // 
    // P8000362A, VerticalSoft, Jack Reynolds, 28 JUL 06
    //   Fix problem with tracking quantities for transfer orders
    // 
    // PR4.00.06
    // P8000491B, VerticalSoft, Jack Reynolds, 01 JUL 07
    //   Fix problem with updating quantity to invoice on tracking specification lines
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 31 JUL 07
    //   RegisterP800Tracking - copy Appl.-from Item Entry from temp table passed as parameter to Rec variable
    // 
    // P8000505A, VerticalSoft, Jack Reynolds, 10 AUG 07
    //   Suppress confirmation prompt when synchronizing drop shipments (for easy lot)
    // 
    // PRW15.00.01
    // P8000538A, VerticalSoft, Jack Reynolds, 22 OCT 07
    //   Delete alternate quantity lines when deleting tracking lines
    // 
    // PRW16.00.01
    // P8000702, VerticalSoft, Jack Reynolds, 29 MAY 09
    //   Fix problem with Order Tracking and Alternate Quantity
    // 
    // P8000733, VerticalSoft, Jack Reynolds, 15 OCT 09
    //   Fix bug with incorrect lot numbers
    // 
    // PRW16.00.02
    // P8000756, VerticalSoft, Jack Reynolds, 20 JAN 10
    //   BinContentItemTrackingInsert function restored
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 27 JUL 09
    //   Transformed from Form
    // 
    // In order to provide F6 invoked lookup from availability bitmap columns, a menu button has been hidden behind control 1.
    // Function buttons Line and Function both exist in two overlayed versions to make dynamic show/hide/enable of
    // individual menu items possible.
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001035, Columbus IT, Jack Reynolds, 20 FEB 12
    //   Clear container fields from Tracking Specification and Reservation Entry
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // P8001095, Columbus IT, Jack Reynolds, 27 SEP 12
    //   Fix problem posting adjustments with zoer base and non-zero alternate
    // 
    // P8001106, Columbus IT, Don Bresee, 16 OCT 12
    //   Add "Supplier Lot No." to lot tracking
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.00.01
    // P8001167, Columbus IT, Jack Reynolds, 02 AUG 13
    //   Add UPDATE mode to RegisterP800Tracking
    // 
    // PRW17.10
    // P8001234, Columbus IT, Jack Reynolds, 01 NOV 13
    //    Support for custom lot number formats
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 9 NOV 15
    //   NAV 2016 changes to SetQtyToHandleAndInvoice
    // 
    // PRW19.00.01
    // P8008351, To-Increase, Jack Reynolds, 26 JAN 17
    //   Support for Lot Creation Date and Country of Origin for multiple lots
    // 
    // PRW110.0.02
    // P80050544, To-Increase, Dayakar Battini, 12 FEB 18
    //   Upgrade to 2017 CU13
    // 
    // P80039754, To-Increase, Jack Reynolds, 08 FEB 18
    //   Warehouse Pick process
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.01
    // P80063375, To Increase, Jack Reynolds, 15 AUG 18
    //   fix problem updating Qty. to Handle when synchronizing transfers
    // 
    // PRW111.00.02
    // P80071663, To Increase, Gangabhushan, 08 MAR 19
    //   TI-12953-Unable to register pick for catch weight item.
    //   Removed fix P80063375 as it is fixed by Microsoft.
    //
    // PRW118.01
    // P800127049, To Increase, Jack Reynolds, 23 AUG 21
    //   Support for Inventory documents

    Caption = 'Item Tracking Lines';
    DataCaptionFields = "Item No.", "Variant Code", Description;
    DelayedInsert = true;
    PageType = Worksheet;
    PopulateAllFields = true;
    PromotedActionCategories = 'New,Process,Report,Line';
    SourceTable = "Tracking Specification";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Control59)
            {
                ShowCaption = false;
                fixed(Control1903651101)
                {
                    ShowCaption = false;
                    group(Source)
                    {
                        Caption = 'Source';
                        field(CurrentSourceCaption; CurrentSourceCaption)
                        {
                            ApplicationArea = ItemTracking;
                            Editable = false;
                            ShowCaption = false;
                        }
                        field("SourceQuantityArray[1]"; SourceQuantityArray[1])
                        {
                            ApplicationArea = ItemTracking;
                            Caption = 'Quantity';
                            DecimalPlaces = 0 : 5;
                            Editable = false;
                            ToolTip = 'Specifies the quantity of the item that corresponds to the document line, which is indicated by 0 in the Undefined fields.';
                        }
                        field(Handle1; SourceQuantityArray[2])
                        {
                            ApplicationArea = ItemTracking;
                            Caption = 'Qty. to Handle';
                            DecimalPlaces = 0 : 5;
                            Editable = false;
                            ToolTip = 'Specifies the item-tracked quantity to be handled. The quantities must correspond to those of the document line.';
                            Visible = Handle1Visible;
                        }
                        field(Invoice1; SourceQuantityArray[3])
                        {
                            ApplicationArea = ItemTracking;
                            Caption = 'Qty. to Invoice';
                            DecimalPlaces = 0 : 5;
                            Editable = false;
                            ToolTip = 'Specifies the item-tracked quantity to be invoiced.';
                            Visible = Invoice1Visible;
                        }
                    }
                    group("Item Tracking")
                    {
                        Caption = 'Item Tracking';
                        field(Text020; Text020)
                        {
                            ApplicationArea = ItemTracking;
                            Visible = false;
                            ShowCaption = false;
                        }
                        field(Quantity_ItemTracking; TotalTrackingSpecification."Quantity (Base)")
                        {
                            ApplicationArea = ItemTracking;
                            Caption = 'Quantity';
                            DecimalPlaces = 0 : 5;
                            Editable = false;
                            ToolTip = 'Specifies the item-tracked quantity of the item that corresponds to the document line, which is indicated by 0 in the Undefined fields.';
                        }
                        field(Handle2; TotalTrackingSpecification."Qty. to Handle (Base)")
                        {
                            ApplicationArea = ItemTracking;
                            Caption = 'Qty. to Handle';
                            DecimalPlaces = 0 : 5;
                            Editable = false;
                            ToolTip = 'Specifies the item-tracked quantity to be handled. The quantities must correspond to those of the document line.';
                            Visible = Handle2Visible;
                        }
                        field(Invoice2; TotalTrackingSpecification."Qty. to Invoice (Base)")
                        {
                            ApplicationArea = ItemTracking;
                            Caption = 'Qty. to Invoice';
                            DecimalPlaces = 0 : 5;
                            Editable = false;
                            ToolTip = 'Specifies the item-tracked quantity to be invoiced.';
                            Visible = Invoice2Visible;
                        }
                    }
                    group(Undefined)
                    {
                        Caption = 'Undefined';
                        field(Placeholder2; Text020)
                        {
                            ApplicationArea = ItemTracking;
                            Visible = false;
                            ShowCaption = false;
                        }
                        field(Quantity3; UndefinedQtyArray[1])
                        {
                            ApplicationArea = ItemTracking;
                            BlankZero = true;
                            Caption = 'Undefined Quantity';
                            DecimalPlaces = 2 : 5;
                            Editable = false;
                            ToolTip = 'Specifies the item-tracked quantity that remains to be assigned, according to the document quantity.';
                        }
                        field(Handle3; UndefinedQtyArray[2])
                        {
                            ApplicationArea = ItemTracking;
                            BlankZero = true;
                            Caption = 'Undefined Quantity to Handle';
                            DecimalPlaces = 2 : 5;
                            Editable = false;
                            ToolTip = 'Specifies the difference between the quantity that can be selected for the document line (which is shown in the Selectable field) and the quantity that you have selected in this window (shown in the Selected field). If you have specified more item tracking quantity than is required on the document line, this field shows the overflow quantity as a negative number in red.';
                            Visible = Handle3Visible;
                        }
                        field(Invoice3; UndefinedQtyArray[3])
                        {
                            ApplicationArea = ItemTracking;
                            BlankZero = true;
                            Caption = 'Undefined Quantity to Invoice';
                            DecimalPlaces = 2 : 5;
                            Editable = false;
                            ToolTip = 'Specifies the difference between the quantity that can be selected for the document line (which is shown in the Selectable field) and the quantity that you have selected in this window (shown in the Selected field). If you have specified more item tracking quantity than is required on the document line, this field shows the overflow quantity as a negative number in red.';
                            Visible = Invoice3Visible;
                        }
                    }
                }
            }
            group(Control82)
            {
                ShowCaption = false;
                field("ItemTrackingCode.Code"; ItemTrackingCode.Code)
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Item Tracking Code';
                    Editable = false;
                    Lookup = true;
                    ToolTip = 'Specifies the transferred item tracking lines.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        PAGE.RunModal(0, ItemTrackingCode);
                    end;
                }
                field("ItemTrackingCode.Description"; ItemTrackingCode.Description)
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Description';
                    Editable = false;
                    ToolTip = 'Specifies the description of what is being tracked.';
                }
            }
            repeater(Control1)
            {
                ShowCaption = false;
                field(AvailabilitySerialNo; TrackingAvailable(Rec, "Item Tracking Type"::"Serial No."))
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Availability, Serial No.';
                    Editable = false;
                    ToolTip = 'Specifies whether the sum of the quantities of the item in outbound documents is greater than the quantity in inventory for the serial number. No indicates a lack of inventory.';

                    trigger OnDrillDown()
                    begin
                        LookupAvailable("Item Tracking Type"::"Serial No.");
                    end;
                }
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = ItemTracking;
                    Editable = SerialNoEditable;
                    ToolTip = 'Specifies the serial number associated with the entry.';

                    trigger OnAssistEdit()
                    var
                        MaxQuantity: Decimal;
                        IsHandled: Boolean;
                    begin
                        IsHandled := false;
                        OnBeforeSerialNoAssistEdit(Rec, xRec, CurrentSignFactor, IsHandled, MaxQuantity, UndefinedQtyArray);
                        if IsHandled then
                            exit;

                        MaxQuantity := UndefinedQtyArray[1];

                        Rec."Bin Code" := ForBinCode;
                        if (Rec."Source Type" = DATABASE::"Transfer Line") and (CurrentRunMode = CurrentRunMode::Reclass) then
                            ItemTrackingDataCollection.SetDirectTransfer(true);
                        ItemTrackingDataCollection.AssistEditTrackingNo(Rec,
                          (CurrentSignFactor * SourceQuantityArray[1] < 0) and not
                          InsertIsBlocked, CurrentSignFactor, "Item Tracking Type"::"Serial No.", MaxQuantity);
                        Rec."Bin Code" := '';
                        CurrPage.Update();
                    end;

                    trigger OnValidate()
                    var
                        LotNo: Code[50];
                        IsHandled: Boolean;
                    begin
                        SerialNoOnAfterValidate();
                        if Rec."Serial No." <> '' then begin
                            IsHandled := false;
                            OnValidateSerialNoOnBeforeFindLotNo(Rec, IsHandled);
                            if not IsHandled then begin
                                ItemTrackingDataCollection.FindLotNoBySNSilent(LotNo, Rec);
                                Rec.Validate("Lot No.", LotNo);
                            end;
                            CurrPage.Update();
                        end;
                    end;
                }
                field("New Serial No."; Rec."New Serial No.")
                {
                    ApplicationArea = ItemTracking;
                    Editable = NewSerialNoEditable;
                    ToolTip = 'Specifies a new serial number that will take the place of the serial number in the Serial No. field.';
                    Visible = NewSerialNoVisible;
                }
                field(AvailabilityLotNo; TrackingAvailable(Rec, "Item Tracking Type"::"Lot No."))
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Availability, Lot No.';
                    Editable = false;
                    ToolTip = 'Specifies whether the sum of the quantities of the item in outbound documents is greater than the quantity in inventory for the lot number. No indicates a lack of inventory.';

                    trigger OnDrillDown()
                    begin
                        LookupAvailable("Item Tracking Type"::"Lot No.");
                    end;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = ItemTracking;
                    Editable = LotNoEditable;
                    ToolTip = 'Specifies the lot number of the item being handled for the associated document line.';

                    trigger OnAssistEdit()
                    var
                        MaxQuantity: Decimal;
                        IsHandled: Boolean;
                    begin
                        IsHandled := false;
                        OnBeforeLotNoAssistEdit(Rec, xRec, CurrentSignFactor, MaxQuantity, UndefinedQtyArray, IsHandled);
                        if IsHandled then
                            exit;

                        MaxQuantity := UndefinedQtyArray[1];

                        Rec."Bin Code" := ForBinCode;
                        if (Rec."Source Type" = DATABASE::"Transfer Line") and (CurrentRunMode = CurrentRunMode::Reclass) then
                            ItemTrackingDataCollection.SetDirectTransfer(true);
                        ItemTrackingDataCollection.AssistEditTrackingNo(Rec,
                          (CurrentSignFactor * SourceQuantityArray[1] < 0) and not
                          InsertIsBlocked, CurrentSignFactor, "Item Tracking Type"::"Lot No.", MaxQuantity);
                        Rec."Bin Code" := '';
                        OnAssistEditLotNoOnBeforeCurrPageUdate(Rec, xRec);
                        CurrPage.Update();
                    end;

                    trigger OnValidate()
                    begin
                        LotNoOnAfterValidate();
                    end;
                }
                field("Supplier Lot No."; Rec."Supplier Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = ShowAdditionalLotData;
                }
                field("Lot Creation Date"; Rec."Lot Creation Date")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Creation Date';
                    Visible = ShowAdditionalLotData;
                }
                field("Country/Region of Origin Code"; Rec."Country/Region of Origin Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = ShowAdditionalLotData;
                }
                field("New Lot No."; Rec."New Lot No.")
                {
                    ApplicationArea = ItemTracking;
                    Editable = NewLotNoEditable;
                    ToolTip = 'Specifies a new lot number that will take the place of the lot number in the Lot No. field.';
                    Visible = NewLotNoVisible;

                    trigger OnValidate()
                    var
                        LotInfo: Record "Lot No. Information";
                    begin
                        NewLotStatusEditable := not LotInfo.Get("Item No.", "Variant Code", "New Lot No."); // P8001083
                    end;
                }
                field("New Lot Status Code"; "New Lot Status Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = NewLotStatusEditable;
                    Visible = NewLotNoVisible;
                }
                field("TrackingAvailable(Rec,2)"; TrackingAvailable(Rec, "Item Tracking Type"::"Package No."))
                {
                    ApplicationArea = ItemTracking;
                    CaptionClass = '6,88';
                    Editable = false;
                    ToolTip = 'Specifies whether the sum of the quantities of the item in outbound documents is greater than the quantity in inventory for the package number. No indicates a lack of inventory.';
                    Visible = PackageNoVisible;

                    trigger OnDrillDown()
                    begin
                        LookupAvailable("Item Tracking Type"::"Package No.");
                    end;
                }
                field("Package No."; Rec."Package No.")
                {
                    ApplicationArea = ItemTracking;
                    Editable = PackageNoEditable;
                    ToolTip = 'Specifies the package number of the item being handled for the associated document line.';
                    Visible = PackageNoVisible;

                    trigger OnAssistEdit()
                    var
                        MaxQuantity: Decimal;
                    begin
                        MaxQuantity := UndefinedQtyArray[1];

                        Rec."Bin Code" := ForBinCode;
                        if (Rec."Source Type" = DATABASE::"Transfer Line") and (CurrentRunMode = CurrentRunMode::Reclass) then
                            ItemTrackingDataCollection.SetDirectTransfer(true);
                        ItemTrackingDataCollection.AssistEditTrackingNo(Rec,
                          (CurrentSignFactor * SourceQuantityArray[1] < 0) and not
                          InsertIsBlocked, CurrentSignFactor, "Item Tracking Type"::"Package No.", MaxQuantity);
                        Rec."Bin Code" := '';
                        CurrPage.Update();
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PackageInfoMgt: Codeunit "Package Info. Management";
                    begin
                        PackageInfoMgt.LookupPackageNo(Rec);
                    end;
                }
                field("New Package No."; Rec."New Package No.")
                {
                    ApplicationArea = ItemTracking;
                    Editable = NewPackageNoEditable;
                    ToolTip = 'Specifies a new package number that will take the place of the package number in the Package No. field.';
                    Visible = NewPackageNoVisible;
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = ItemTracking;
                    Editable = ExpirationDateEditable;
                    ToolTip = 'Specifies the expiration date, if any, of the item carrying the item tracking number.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        MarkItemTrackingLinesWithTheSameLotAsModified();
                        CurrPage.Update();
                    end;
                }
                field("New Expiration Date"; Rec."New Expiration Date")
                {
                    ApplicationArea = ItemTracking;
                    Editable = NewExpirationDateEditable;
                    ToolTip = 'Specifies a new expiration date.';
                    Visible = NewExpirationDateVisible;
                }
                field("Warranty Date"; Rec."Warranty Date")
                {
                    ApplicationArea = ItemTracking;
                    Editable = WarrantyDateEditable;
                    ToolTip = 'Specifies that a warranty date must be entered manually.';
                    Visible = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = ItemTracking;
                    Editable = ItemNoEditable;
                    ToolTip = 'Specifies the number of the item associated with the entry.';
                    Visible = false;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Planning;
                    Editable = VariantCodeEditable;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = ItemTracking;
                    Editable = DescriptionEditable;
                    ToolTip = 'Specifies the description of the entry.';
                    Visible = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = ItemTracking;
                    Editable = LocationCodeEditable;
                    ToolTip = 'Specifies the location code for the entry.';
                    Visible = false;
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ApplicationArea = ItemTracking;
                    Editable = QuantityBaseEditable;
                    ToolTip = 'Specifies the quantity on the line expressed in base units of measure.';

                    trigger OnValidate()
                    begin
                        QuantityBaseOnValidate();
                        QuantityBaseOnAfterValidate();
                    end;
                }
                field("Qty. to Handle (Base)"; Rec."Qty. to Handle (Base)")
                {
                    ApplicationArea = ItemTracking;
                    Editable = QtyToHandleBaseEditable;
                    ToolTip = 'Specifies the quantity that you want to handle in the base unit of measure.';
                    Visible = QtyToHandleBaseVisible;

                    trigger OnValidate()
                    begin
                        QtytoHandleBaseOnAfterValidate();
                    end;
                }
                field("Qty. to Invoice (Base)"; Rec."Qty. to Invoice (Base)")
                {
                    ApplicationArea = ItemTracking;
                    Editable = QtyToInvoiceBaseEditable;
                    ToolTip = 'Specifies how many of the items, in base units of measure, are scheduled for invoicing.';
                    Visible = QtyToInvoiceBaseVisible;

                    trigger OnValidate()
                    begin
                        QtytoInvoiceBaseOnAfterValidat;
                    end;
                }
                field("Quantity Handled (Base)"; Rec."Quantity Handled (Base)")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the quantity of serial/lot numbers shipped or received for the associated document line, expressed in base units of measure.';
                    Visible = false;
                }
                field("Quantity Invoiced (Base)"; Rec."Quantity Invoiced (Base)")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the quantity of serial/lot numbers that are invoiced with the associated document line, expressed in base units of measure.';
                    Visible = false;
                }
                field("Appl.-to Item Entry"; Rec."Appl.-to Item Entry")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the number of the item ledger entry that the document or journal line is applied to.';
                    Visible = ApplToItemEntryVisible;
                }
                field("Quantity (Alt.)"; Rec."Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Qty. to Handle (Alt.)"; "Qty. to Handle (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    Editable = QtytoHandleAltEditable;
                    Visible = QtytoHandleAltVisible;

                    trigger OnDrillDown()
                    begin
                        // PR3.60
                        if not QtytoHandleAltEditable then
                            exit;
                        CurrPage.SaveRecord;
                        AltQtyMgmt.ShowTrackingAltQtyLines(Rec); // P8000267B
                        CurrPage.Update;
                        // PR3.60
                    end;

                    trigger OnValidate()
                    begin
                        QtytoHandleAltOnAfterValidate;
                    end;
                }
                field("Qty. to Invoice (Alt.)"; Rec."Qty. to Invoice (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = QtytoInvoiceAltVisible;
                }
                field("Quantity Handled (Alt.)"; Rec."Quantity Handled (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = QuantityHandledAltVisible;
                }
                field("Quantity Invoiced (Alt.)"; Rec."Quantity Invoiced (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = QuantityInvoicedAltVisible;
                }
                field("Appl.-from Item Entry"; Rec."Appl.-from Item Entry")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the number of the item ledger entry that the document or journal line is applied from.';
                    Visible = ApplFromItemEntryVisible;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(ButtonLineReclass)
            {
                Caption = '&Line';
                Image = Line;
                Visible = ButtonLineReclassVisible;
                action(Reclass_SerialNoInfoCard)
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Serial No. Information Card';
                    Visible = ButtonLineReclassVisible;
                    Image = SNInfo;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Serial No. Information List";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code"),
                                  "Serial No." = FIELD("Serial No.");
                    ToolTip = 'View or edit detailed information about the serial number.';

                    trigger OnAction()
                    begin
                        Rec.TestField("Serial No.");
                    end;
                }
                action(Reclass_LotNoInfoCard)
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Lot No. Information Card';
                    Visible = ButtonLineReclassVisible;
                    Image = LotInfo;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Lot No. Information List";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code"),
                                  "Lot No." = FIELD("Lot No.");
                    ToolTip = 'View or edit detailed information about the lot number.';

                    trigger OnAction()
                    begin
                        Rec.TestField("Lot No.");
                    end;
                }
                separator(Action69)
                {
                }
                action(NewSerialNoInformation)
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'New S&erial No. Information';
                    Visible = ButtonLineReclassVisible;
                    Image = NewSerialNoProperties;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'Create a record with detailed information about the serial number.';

                    trigger OnAction()
                    begin
                        Rec.TestField("New Serial No.");
                        SerialNoInfoCardAction(Rec."New Serial No.");
                    end;
                }
                action(NewLotNoInformation)
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'New L&ot No. Information';
                    Visible = ButtonLineReclassVisible;
                    Image = NewLotProperties;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunPageOnRec = false;
                    ToolTip = 'Create a record with detailed information about the lot number.';

                    trigger OnAction()
                    begin
                        Rec.TestField("New Lot No.");
                        LotNoInfoCardAction(Rec."New Lot No.");
                    end;
                }
            }
            group(ButtonLine)
            {
                Caption = '&Line';
                Image = Line;
                Visible = ButtonLineVisible;
                action(Line_SerialNoInfoCard)
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Serial No. Information Card';
                    Visible = ButtonLineVisible;
                    Image = SNInfo;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'View or edit detailed information about the serial number.';

                    trigger OnAction()
                    begin
                        Rec.TestField("Serial No.");
                        SerialNoInfoCardAction(Rec."Serial No.");
                    end;
                }
                action(Line_LotNoInfoCard)
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Lot No. Information Card';
                    Visible = ButtonLineVisible;
                    Image = LotInfo;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'View or edit detailed information about the lot number.';

                    trigger OnAction()
                    begin
                        Rec.TestField("Lot No.");
                        LotNoInfoCardAction(Rec."Lot No.");
                    end;
                }
                action(Line_PackageNoInfoCard)
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Package No. Information Card';
                    Visible = ButtonLineVisible;
                    Image = LotInfo;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Package No. Information List";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code"),
                                  "Package No." = FIELD("Package No.");
                    ToolTip = 'View or edit detailed information about the package number.';

                    trigger OnAction()
                    begin
                        Rec.TestField("Package No.");
                    end;
                }
            }
        }
        area(processing)
        {
            group(FunctionsSupply)
            {
                Caption = 'F&unctions';
                Image = "Action";
                Visible = FunctionsSupplyVisible;
                action("Assign Serial No.")
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Assign &Serial No.';
                    Visible = FunctionsSupplyVisible;
                    Image = SerialNo;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Automatically assign the required serial numbers from predefined number series.';

                    trigger OnAction()
                    begin
                        if InsertIsBlocked then
                            exit;
                        AssignSerialNo();
                    end;
                }
                action("Assign Lot No.")
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Assign &Lot No.';
                    Visible = FunctionsSupplyVisible;
                    Image = Lot;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Automatically assign the required lot numbers from predefined number series.';

                    trigger OnAction()
                    begin
                        if InsertIsBlocked then
                            exit;
                        AssignLotNo();
                    end;
                }
                action("Assign Package No.")
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Assign &Package No.';
                    Visible = FunctionsSupplyVisible and PackageNoVisible;
                    Image = Lot;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Automatically assign the required package numbers from predefined number series.';

                    trigger OnAction()
                    begin
                        if InsertIsBlocked then
                            exit;
                        AssignPackageNo();
                    end;
                }
                action("Create Customized SN")
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Create Customized SN';
                    Visible = FunctionsSupplyVisible;
                    Image = CreateSerialNo;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Automatically assign the required serial numbers based on a number series that you define.';

                    trigger OnAction()
                    begin
                        if InsertIsBlocked then
                            exit;
                        CreateCustomizedSNByPage();
                    end;
                }
                action("Refresh Availability")
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Refresh Availability';
                    Visible = FunctionsSupplyVisible;
                    Promoted = true;
                    PromotedCategory = Process;
                    Image = Refresh;
                    ToolTip = 'Update the availability information according to changes made by other users since you opened the window. ';

                    trigger OnAction()
                    begin
                        ItemTrackingDataCollection.RefreshTrackingAvailability(Rec, true);
                    end;
                }
            }
            group(FunctionsDemand)
            {
                Caption = 'F&unctions';
                Image = "Action";
                Visible = FunctionsDemandVisible;
                action("Assign &Serial No.")
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Assign &Serial No.';
                    Visible = FunctionsDemandVisible;
                    Image = SerialNo;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Automatically assign the required serial numbers from predefined number series.';

                    trigger OnAction()
                    begin
                        if InsertIsBlocked then
                            exit;
                        AssignSerialNo();
                    end;
                }
                action("Assign &Lot No.")
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Assign &Lot No.';
                    Visible = FunctionsDemandVisible;
                    Image = Lot;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Automatically assign the required lot numbers from predefined number series.';

                    trigger OnAction()
                    begin
                        if InsertIsBlocked then
                            exit;
                        AssignLotNo();
                    end;
                }
                action("Assign &Package No.")
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Assign &Package No.';
                    Visible = FunctionsDemandVisible AND PackageNoVisible;
                    Image = Lot;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Automatically assign the required package numbers from predefined number series.';

                    trigger OnAction()
                    begin
                        if InsertIsBlocked then
                            exit;
                        AssignPackageNo();
                    end;
                }
                action(CreateCustomizedSN)
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Create Customized SN';
                    Visible = FunctionsDemandVisible;
                    Image = CreateSerialNo;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Automatically assign the required serial numbers based on a number series that you define.';

                    trigger OnAction()
                    begin
                        if InsertIsBlocked then
                            exit;
                        CreateCustomizedSNByPage();
                    end;
                }
                action("Select Entries")
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Select &Entries';
                    Visible = FunctionsDemandVisible;
                    Image = SelectEntries;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Select from existing, available serial or lot numbers.';

                    trigger OnAction()
                    begin
                        if InsertIsBlocked then
                            exit;

                        SelectEntries();
                    end;
                }
                action(Action64)
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Refresh Availability';
                    Visible = FunctionsDemandVisible;
                    Image = Refresh;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Update the availability information according to changes made by other users since you opened the window. ';

                    trigger OnAction()
                    begin
                        ItemTrackingDataCollection.RefreshTrackingAvailability(Rec, true);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        UpdateExpDateEditable();
    end;

    trigger OnAfterGetRecord()
    var
        LotInfo: Record "Lot No. Information";
    begin
        ExpirationDateOnFormat();
        // P8001083
        if NewLotNoVisible then
            NewLotStatusEditable := not LotInfo.Get("Item No.", "Variant Code", "New Lot No.");
        // P8001083
    end;

    trigger OnClosePage()
    var
        SkipWriteToDatabase: Boolean;
    begin
        SkipWriteToDatabase := false;
        OnBeforeClosePage(Rec, SkipWriteToDatabase);
        if UpdateUndefinedQty and not SkipWriteToDatabase then
            WriteToDatabase();
        if CurrentRunMode = CurrentRunMode::"Drop Shipment" then
            case CurrentSourceType of
                DATABASE::"Sales Line":
                    SynchronizeLinkedSources(StrSubstNo(Text015, Text016));
                DATABASE::"Purchase Line":
                    SynchronizeLinkedSources(StrSubstNo(Text015, Text017));
            end;

        if (CurrentRunMode = CurrentRunMode::Transfer) or IsOrderToOrderBindingToTransfer then
            SynchronizeLinkedSources('');
        SynchronizeWarehouseItemTracking();
    end;

    trigger OnDeleteRecord(): Boolean
    var
        TrackingSpec: Record "Tracking Specification";
        WMSManagement: Codeunit "WMS Management";
        AlreadyDeleted: Boolean;
    begin
        OnBeforeDeleteRecord(Rec);

        TrackingSpec."Item No." := Rec."Item No.";
        TrackingSpec."Location Code" := Rec."Location Code";
        TrackingSpec."Source Type" := Rec."Source Type";
        TrackingSpec."Source Subtype" := Rec."Source Subtype";
        WMSManagement.CheckItemTrackingChange(TrackingSpec, Rec);

        OnDeleteRecordOnAfterWMSCheckTrackingChange(TrackingSpec, Rec);

        if not DeleteIsBlocked then begin
            // P8000538A
            if ProcessFns.AltQtyInstalled() then
                AltQtyMgmt.DeleteTrackingLotSerial(Rec);
            // P8000538A

            AlreadyDeleted := TempItemTrackLineDelete.Get(Rec."Entry No.");
            TempItemTrackLineDelete.TransferFields(Rec);
            Rec.Delete(true);

            if not AlreadyDeleted then
                TempItemTrackLineDelete.Insert();
            ItemTrackingDataCollection.UpdateTrackingDataSetWithChange(
              TempItemTrackLineDelete, CurrentSignFactor * SourceQuantityArray[1] < 0, CurrentSignFactor, 2);
            if TempItemTrackLineInsert.Get(Rec."Entry No.") then
                TempItemTrackLineInsert.Delete();
            if TempItemTrackLineModify.Get(Rec."Entry No.") then
                TempItemTrackLineModify.Delete();
        end;
        CalculateSums();

        exit(false);
    end;

    trigger OnInit()
    begin
        WarrantyDateEditable := true;
        ExpirationDateEditable := true;
        NewExpirationDateEditable := true;
        NewPackageNoEditable := true;
        NewLotNoEditable := true;
        NewLotStatusEditable := true; // P8001083
        NewSerialNoEditable := true;
        DescriptionEditable := true;
        PackageNoEditable := true;
        LotNoEditable := true;
        SerialNoEditable := true;
        QuantityBaseEditable := true;
        QtyToInvoiceBaseEditable := true;
        QtytoHandleAltEditable := true;
        QtyToHandleBaseEditable := true;
        FunctionsDemandVisible := true;
        FunctionsSupplyVisible := true;
        ButtonLineVisible := true;
        QtytoInvoiceAltVisible := true;
        QtyToInvoiceBaseVisible := true;
        Invoice3Visible := true;
        Invoice2Visible := true;
        Invoice1Visible := true;
        QtytoHandleAltVisible := true;
        QtyToHandleBaseVisible := true;
        Handle3Visible := true;
        Handle2Visible := true;
        Handle1Visible := true;
        LocationCodeEditable := true;
        VariantCodeEditable := true;
        ItemNoEditable := true;
        InboundIsSet := false;
        ApplFromItemEntryVisible := false;
        ApplToItemEntryVisible := false;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if Rec."Entry No." <> 0 then
            exit(false);

        InsertRecord(Rec);
        CalculateSums();

        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        Result: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOnModifyRecord(Rec, xRec, InsertIsBlocked, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if InsertIsBlocked then
            if not Rec.HasSameTracking(xRec) or (xRec."Quantity (Base)" <> Rec."Quantity (Base)") then
                exit(false);

        UpdateTrackingData();
        CalculateSums;

        exit(false);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Positive := CurrentSignFactor > 0; // PR3.60
        Rec."Qty. per Unit of Measure" := QtyPerUOM;
        Rec."Qty. Rounding Precision (Base)" := QtyRoundingPerBase;
    end;

    trigger OnOpenPage()
    begin
        ItemNoEditable := false;
        VariantCodeEditable := false;
        LocationCodeEditable := false;
        if InboundIsSet then begin
            ApplFromItemEntryVisible := Inbound;
            ApplToItemEntryVisible := not Inbound;
        end;
        SetupPackageNoControls();

        UpdateUndefinedQtyArray();

        CurrentPageIsOpen := true;

        NotifyWhenTrackingIsManagedByWhse();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        IsHandled: Boolean;
    begin
        if not UpdateUndefinedQty then
            exit(Confirm(Text006));

        if not ItemTrackingDataCollection.RefreshTrackingAvailability(Rec, false) then begin
            CurrPage.Update();

            IsHandled := false;
            OnQueryClosePageOnBeforeConfirmClosePage(Rec, isHandled, CurrentRunMode);
            if IsHandled then
                Exit(true);

            exit(Confirm(AvailabilityWarningsQst, true));
        end;
    end;

    var
        xTempTrackingSpecification: Record "Tracking Specification" temporary;
        TempReservEntry: Record "Reservation Entry" temporary;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        ReservEngineMgt: Codeunit "Reservation Engine Mgt.";
        QtyRoundingPerBase: Decimal;
        QtyToAddAsBlank: Decimal;
        Text002: Label 'Quantity must be %1.';
        Text003: Label 'negative';
        Text004: Label 'positive';
        LastEntryNo: Integer;
        SecondSourceID: Integer;
        IsAssembleToOrder: Boolean;
        ExpectedReceiptDate: Date;
        ShipmentDate: Date;
        Text005: Label 'Error when writing to database.';
        Text006: Label 'The corrections cannot be saved as excess quantity has been defined.\Close the form anyway?';
        Text007: Label 'Another user has modified the item tracking data since it was retrieved from the database.\Start again.';
        CurrentEntryStatus: Enum "Reservation Status";
        Text008: Label 'The quantity to create must be an integer.';
        Text009: Label 'The quantity to create must be positive.';
        Text011: Label 'Tracking specification with Serial No. %1 and Lot No. %2 and Package %3 already exists.', Comment = '%1 - serial no, %2 - lot no, %3 - package no.';
        Text012: Label 'Tracking specification with Serial No. %1 already exists.';
        DeleteIsBlocked: Boolean;
        Text014: Label 'The total item tracking quantity %1 exceeds the %2 quantity %3.\The changes cannot be saved to the database.';
        Text015: Label 'Do you want to synchronize item tracking on the line with item tracking on the related drop shipment %1?';
        BlockCommit: Boolean;
        IsCorrection: Boolean;
        CurrentPageIsOpen: Boolean;
        CalledFromSynchWhseItemTrkg: Boolean;
        Inbound: Boolean;
        CurrentSourceCaption: Text[255];
        CurrentSourceRowID: Text[250];
        SecondSourceRowID: Text[250];
        Text016: Label 'purchase order line';
        Text017: Label 'sales order line';
        Text018: Label 'Saving item tracking line changes';
        AvailabilityWarningsQst: Label 'You do not have enough inventory to meet the demand for items in one or more lines.\This is indicated by No in the Availability fields.\Do you want to continue?';
        Text020: Label 'Placeholder';
        ExcludePostedEntries: Boolean;
        ProdOrderLineHandling: Boolean;
        IsDirectTransfer: Boolean;
        UnincrementableStringErr: Label 'The value in the %1 field must have a number so that we can assign the next number in the series.', Comment = '%1 = serial number';
        ItemTrackingManagedByWhse: Boolean;
        ItemTrkgManagedByWhseMsg: Label 'You cannot assign a lot or serial number because item tracking for this document line is done through a warehouse activity.';
        NewItemTrackingLine: Record "Tracking Specification";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        ProcessFns: Codeunit "Process 800 Functions";
        P800ItemTracking: Codeunit "Process 800 Item Tracking";
        MoveBinContent: Boolean;

    protected var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        TempItemTrackLineInsert: Record "Tracking Specification" temporary;
        TempItemTrackLineModify: Record "Tracking Specification" temporary;
        TempItemTrackLineDelete: Record "Tracking Specification" temporary;
        TempItemTrackLineReserv: Record "Tracking Specification" temporary;
        TotalTrackingSpecification: Record "Tracking Specification";
        SourceTrackingSpecification: Record "Tracking Specification";
        ItemTrackingDataCollection: Codeunit "Item Tracking Data Collection";
        CurrentRunMode: Enum "Item Tracking Run Mode";
        CurrentSignFactor: Integer;
        ForBinCode: Code[20];
        InsertIsBlocked: Boolean;
        QtyPerUOM: Decimal;
        UndefinedQtyArray: array[3] of Decimal;
        SourceQuantityArray: array[5] of Decimal;
        CurrentSourceType: Integer;
        [InDataSet]
        ApplFromItemEntryVisible: Boolean;
        [InDataSet]
        ApplToItemEntryVisible: Boolean;
        [InDataSet]
        ItemNoEditable: Boolean;
        [InDataSet]
        VariantCodeEditable: Boolean;
        [InDataSet]
        LocationCodeEditable: Boolean;
        [InDataSet]
        Handle1Visible: Boolean;
        [InDataSet]
        Handle2Visible: Boolean;
        [InDataSet]
        Handle3Visible: Boolean;
        [InDataSet]
        QtyToHandleBaseVisible: Boolean;
        [InDataSet]
        Invoice1Visible: Boolean;
        [InDataSet]
        Invoice2Visible: Boolean;
        [InDataSet]
        Invoice3Visible: Boolean;
        [InDataSet]
        QtyToInvoiceBaseVisible: Boolean;
        [InDataSet]
        PackageNoVisible: Boolean;
        [InDataSet]
        NewSerialNoVisible: Boolean;
        [InDataSet]
        NewLotNoVisible: Boolean;
        [InDataSet]
        NewPackageNoVisible: Boolean;
        [InDataSet]
        NewExpirationDateVisible: Boolean;
        [InDataSet]
        ButtonLineReclassVisible: Boolean;
        [InDataSet]
        ButtonLineVisible: Boolean;
        [InDataSet]
        FunctionsSupplyVisible: Boolean;
        [InDataSet]
        FunctionsDemandVisible: Boolean;
        InboundIsSet: Boolean;
        [InDataSet]
        QtyToHandleBaseEditable: Boolean;
        [InDataSet]
        QtyToInvoiceBaseEditable: Boolean;
        [InDataSet]
        QuantityBaseEditable: Boolean;
        [InDataSet]
        SerialNoEditable: Boolean;
        [InDataSet]
        LotNoEditable: Boolean;
        [InDataSet]
        PackageNoEditable: Boolean;
        [InDataSet]
        DescriptionEditable: Boolean;
        [InDataSet]
        NewSerialNoEditable: Boolean;
        [InDataSet]
        NewLotNoEditable: Boolean;
        [InDataSet]
        NewPackageNoEditable: Boolean;
        [InDataSet]
        NewExpirationDateEditable: Boolean;
        [InDataSet]
        ExpirationDateEditable: Boolean;
        [InDataSet]
        WarrantyDateEditable: Boolean;
        [InDataSet]
        QuantityHandledAltVisible: Boolean;
        [InDataSet]
        QuantityInvoicedAltVisible: Boolean;
        [InDataSet]
        QtytoHandleAltEditable: Boolean;
        [InDataSet]
        QtytoHandleAltVisible: Boolean;
        [InDataSet]
        QtytoInvoiceAltVisible: Boolean;
        [InDataSet]
        QuantityAltVisible: Boolean;
        [InDataSet]
        NewLotStatusEditable: Boolean;
        [InDataSet]
        ShowAdditionalLotData: Boolean;

    local procedure SetupPackageNoControls()
    var
        PackageManagement: Codeunit "Package Management";
        PackageNoEnabled: Boolean;
    begin
        PackageNoEnabled := PackageManagement.IsEnabled();
        PackageNoVisible := PackageNoEnabled;
        PackageNoEditable := PackageNoEditable and PackageNoEnabled;
        NewPackageNoVisible := NewPackageNoVisible and PackageNoEnabled;
        NewPackageNoEditable := NewPackageNoEditable and PackageNoEnabled;
    end;

    procedure InsertRecord(var TempTrackingSpecification: Record "Tracking Specification" temporary)
    begin
        TempTrackingSpecification."Entry No." := NextEntryNo;
        if (not InsertIsBlocked) and (not ZeroLineExists) then
            if not TestTempSpecificationExists() then begin
                TempItemTrackLineInsert.TransferFields(TempTrackingSpecification);
                OnInsertRecordOnBeforeTempItemTrackLineInsert(TempItemTrackLineInsert, TempTrackingSpecification);
                TempItemTrackLineInsert.Insert();
                TempTrackingSpecification.Insert();
                ItemTrackingDataCollection.UpdateTrackingDataSetWithChange(
                  TempItemTrackLineInsert, CurrentSignFactor * SourceQuantityArray[1] < 0, CurrentSignFactor, 0);
            end;
    end;

#if not CLEAN19
    [Obsolete('Replaced by SetRynMode().', '19.0')]
    procedure SetFormRunMode(Mode: Option ,Reclass,"Combined Ship/Rcpt","Drop Shipment",Transfer)
    begin
        CurrentRunMode := "Item Tracking Run Mode".FromInteger(Mode);
    end;
#endif

    procedure SetRunMode(RunMode: Enum "Item Tracking Run Mode")
    begin
        CurrentRunMode := RunMode;
    end;

    procedure GetRunMode(): Enum "Item Tracking Run Mode"
    begin
        exit(CurrentRunMode);
    end;

#if not CLEAN19
    [Obsolete('Replaced by GetRunMode().', '19.0')]
    procedure GetFormRunMode(var Mode: Option ,Reclass,"Combined Ship/Rcpt","Drop Shipment",Transfer)
    begin
        Mode := CurrentRunMode.AsInteger();
    end;
#endif

    protected procedure UpdateTrackingData()
    var
        xTempTrackingSpec: Record "Tracking Specification" temporary;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateTrackingData(Rec, xRec, xTempTrackingSpec, CurrentSignFactor, SourceQuantityArray, IsHandled);
        if IsHandled then
            exit;

        // P8000282A
        // IF ProcessFns.AltQtyInstalled() THEN                                   // P8000733
        if ProcessFns.AltQtyInstalled() and (xRec."Entry No." = "Entry No.") then // P8000733
            AltQtyMgmt.UpdateTrackingLotSerial(Rec, xRec);
        // P8000282A

        if not TestTempSpecificationExists() then begin
            Rec.Modify();

            if not Rec.HasSameTracking(xRec) then begin
                xTempTrackingSpec := xRec;
                ItemTrackingDataCollection.UpdateTrackingDataSetWithChange(
                  xTempTrackingSpec, CurrentSignFactor * SourceQuantityArray[1] < 0, CurrentSignFactor, 2);
            end;

            if TempItemTrackLineModify.Get(Rec."Entry No.") then
                TempItemTrackLineModify.Delete();
            if TempItemTrackLineInsert.Get(Rec."Entry No.") then begin
                TempItemTrackLineInsert.TransferFields(Rec);
                TempItemTrackLineInsert.Modify();
                ItemTrackingDataCollection.UpdateTrackingDataSetWithChange(
                  TempItemTrackLineInsert, CurrentSignFactor * SourceQuantityArray[1] < 0, CurrentSignFactor, 1);
            end else begin
                TempItemTrackLineModify.TransferFields(Rec);
                TempItemTrackLineModify.Insert();
                ItemTrackingDataCollection.UpdateTrackingDataSetWithChange(
                  TempItemTrackLineModify, CurrentSignFactor * SourceQuantityArray[1] < 0, CurrentSignFactor, 1);
            end;
        end;
    end;

    procedure SetSourceSpec(TrackingSpecification: Record "Tracking Specification"; AvailabilityDate: Date)
    var
        ReservEntry: Record "Reservation Entry";
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        TempTrackingSpecification2: Record "Tracking Specification" temporary;
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        CurrentEntryStatusOption: Option;
    begin
        OnBeforeSetSourceSpec(TrackingSpecification, ReservEntry);

        SourceTrackingSpecification := TrackingSpecification;
        GetItem(TrackingSpecification."Item No.");
        ForBinCode := TrackingSpecification."Bin Code";
        SetFilters(TrackingSpecification);
        TempTrackingSpecification.DeleteAll();
        TempItemTrackLineInsert.DeleteAll();
        TempItemTrackLineModify.DeleteAll();
        TempItemTrackLineDelete.DeleteAll();

        TempReservEntry.DeleteAll();
        LastEntryNo := 0;
        if ItemTrackingMgt.IsOrderNetworkEntity(TrackingSpecification."Source Type",
             TrackingSpecification."Source Subtype") and not (CurrentRunMode = CurrentRunMode::"Drop Shipment")
        then
            CurrentEntryStatus := CurrentEntryStatus::Surplus
        else
            CurrentEntryStatus := CurrentEntryStatus::Prospect;

        if (TrackingSpecification."Source Type" = DATABASE::"Transfer Line") and (CurrentRunMode = CurrentRunMode::Reclass) then
            CurrentEntryStatus := CurrentEntryStatus::Prospect;

        CurrentEntryStatusOption := CurrentEntryStatus.AsInteger();
        OnSetSourceSpecOnAfterAssignCurrentEntryStatus(TrackingSpecification, CurrentEntryStatusOption);
        CurrentEntryStatus := "Reservation Status".FromInteger(CurrentEntryStatusOption);

        // Set controls for Qty to handle:
        SetPageControls("Item Tracking Lines Controls"::Handle, GetHandleSource(TrackingSpecification));
        // Set controls for Qty to Invoice:
        SetPageControls("Item Tracking Lines Controls"::Invoice, GetInvoiceSource(TrackingSpecification));

        SetPageControls("Item Tracking Lines Controls"::Reclass, CurrentRunMode = CurrentRunMode::Reclass);

        if CurrentRunMode = CurrentRunMode::"Combined Ship/Rcpt" then
            SetPageControls("Item Tracking Lines Controls"::Tracking, false);

        SetWarehouseControls(TrackingSpecification);

        SetAltQtyControls(TrackingSpecification); // PR3.60

        ReservEntry."Source Type" := TrackingSpecification."Source Type";
        ReservEntry."Source Subtype" := TrackingSpecification."Source Subtype";
        ReservEntry."Source ID" := TrackingSpecification."Source ID";
        CurrentSignFactor := CreateReservEntry.SignFactor(ReservEntry);
        CurrentSourceCaption := ReservEntry.TextCaption();
        CurrentSourceType := ReservEntry."Source Type";

        if CurrentSignFactor < 0 then begin
            ExpectedReceiptDate := 0D;
            ShipmentDate := AvailabilityDate;
        end else begin
            ExpectedReceiptDate := AvailabilityDate;
            ShipmentDate := 0D;
        end;

        FillSourceQuantityArray(TrackingSpecification);
        QtyPerUOM := TrackingSpecification."Qty. per Unit of Measure";
        QtyRoundingPerBase := TrackingSpecification."Qty. Rounding Precision (Base)";
        // P8001106
        ShowAdditionalLotData := ((TrackingSpecification."Source Type" = DATABASE::"Purchase Line") and (TrackingSpecification."Source Subtype" = 1)) or // P8008351
                                 ((TrackingSpecification."Source Type" = DATABASE::"Invt. Document Line") and (TrackingSpecification."Source Subtype" = 0)); // P800127049
        // P8001106

        ReservEntry.SetSourceFilter(
          TrackingSpecification."Source Type", TrackingSpecification."Source Subtype",
          TrackingSpecification."Source ID", TrackingSpecification."Source Ref. No.", true);
        ReservEntry.SetSourceFilter(
          TrackingSpecification."Source Batch Name", TrackingSpecification."Source Prod. Order Line");
        ReservEntry.SetRange("Untracked Surplus", false);
        // Transfer Receipt gets special treatment:
        SetSourceSpecForTransferReceipt(TrackingSpecification, ReservEntry, TempTrackingSpecification2);

        AddReservEntriesToTempRecSet(ReservEntry, TempTrackingSpecification, false, 0, QtyRoundingPerBase);

        TempReservEntry.CopyFilters(ReservEntry);

        TrackingSpecification.SetSourceFilter(
          TrackingSpecification."Source Type", TrackingSpecification."Source Subtype",
          TrackingSpecification."Source ID", TrackingSpecification."Source Ref. No.", true);
        TrackingSpecification.SetSourceFilter(
          TrackingSpecification."Source Batch Name", TrackingSpecification."Source Prod. Order Line");

        if TrackingSpecification.FindSet() then
            repeat
                TempTrackingSpecification := TrackingSpecification;
                TempTrackingSpecification.Insert();
            until TrackingSpecification.Next() = 0;

        // Data regarding posted quantities on transfers is collected from Item Ledger Entries:
        if TrackingSpecification."Source Type" = DATABASE::"Transfer Line" then
            CollectPostedTransferEntries(TrackingSpecification, TempTrackingSpecification);

        // Data regarding posted quantities on assembly orders is collected from Item Ledger Entries:
        if not ExcludePostedEntries then
            if (TrackingSpecification."Source Type" = DATABASE::"Assembly Line") or
               (TrackingSpecification."Source Type" = DATABASE::"Assembly Header")
            then
                CollectPostedAssemblyEntries(TrackingSpecification, TempTrackingSpecification);

        // Data regarding posted output quantities on prod.orders is collected from Item Ledger Entries:
        if TrackingSpecification."Source Type" = DATABASE::"Prod. Order Line" then
            if TrackingSpecification."Source Subtype" = 3 then
                CollectPostedOutputEntries(TrackingSpecification, TempTrackingSpecification);

        // If run for Drop Shipment a RowID is prepared for synchronisation:
        if CurrentRunMode = CurrentRunMode::"Drop Shipment" then
            CurrentSourceRowID := ItemTrackingMgt.ComposeRowID(TrackingSpecification."Source Type",
                TrackingSpecification."Source Subtype", TrackingSpecification."Source ID",
                TrackingSpecification."Source Batch Name", TrackingSpecification."Source Prod. Order Line",
                TrackingSpecification."Source Ref. No.");

        // Synchronization of outbound transfer order:
        if (TrackingSpecification."Source Type" = DATABASE::"Transfer Line") and
           (TrackingSpecification."Source Subtype" = 0)
        then begin
            BlockCommit := true;
            CurrentSourceRowID := ItemTrackingMgt.ComposeRowID(TrackingSpecification."Source Type",
                TrackingSpecification."Source Subtype", TrackingSpecification."Source ID",
                TrackingSpecification."Source Batch Name", TrackingSpecification."Source Prod. Order Line",
                TrackingSpecification."Source Ref. No.");
            SecondSourceRowID := ItemTrackingMgt.ComposeRowID(TrackingSpecification."Source Type",
                1, TrackingSpecification."Source ID",
                TrackingSpecification."Source Batch Name", TrackingSpecification."Source Prod. Order Line",
                TrackingSpecification."Source Ref. No.");
            CurrentRunMode := CurrentRunMode::Transfer;
        end;

        AddToGlobalRecordSet(TempTrackingSpecification);
        AddToGlobalRecordSet(TempTrackingSpecification2);
        CalculateSums();

        ItemTrackingDataCollection.SetCurrentBinAndItemTrkgCode(ForBinCode, ItemTrackingCode);
        ItemTrackingDataCollection.RetrieveLookupData(Rec, false);

        FunctionsDemandVisible := CurrentSignFactor * SourceQuantityArray[1] < 0;
        FunctionsSupplyVisible := not FunctionsDemandVisible;

        OnAfterSetSourceSpec(
            TrackingSpecification, Rec, AvailabilityDate, BlockCommit, FunctionsDemandVisible, FunctionsSupplyVisible,
            QtyToHandleBaseEditable, QuantityBaseEditable, InsertIsBlocked);
    end;

    local procedure SetSourceSpecForTransferReceipt(TrackingSpecification: Record "Tracking Specification"; var ReservEntry: Record "Reservation Entry"; var TempTrackingSpecification2: Record "Tracking Specification" temporary)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSetSourceSpecForTransferReceipt(Rec, ReservEntry, TrackingSpecification, CurrentRunMode, DeleteIsBlocked, IsHandled, TempTrackingSpecification2);
        if IsHandled then
            exit;

        if (TrackingSpecification."Source Type" = DATABASE::"Transfer Line") and
           (CurrentRunMode <> CurrentRunMode::Transfer) and
           (TrackingSpecification."Source Subtype" = 1)
        then begin
            ReservEntry.SetRange("Source Subtype", 0);
            AddReservEntriesToTempRecSet(ReservEntry, TempTrackingSpecification2, true, 8421504);
            ReservEntry.SetRange("Source Subtype", 1);
            ReservEntry.SetRange("Source Prod. Order Line", TrackingSpecification."Source Ref. No.");
            ReservEntry.SetRange("Source Ref. No.");
            DeleteIsBlocked := true;
            SetPageControls("Item Tracking Lines Controls"::Quantity, false);
        end;
    end;

    procedure SetSecondSourceQuantity(SecondSourceQuantityArray: array[3] of Decimal)
    begin
        OnBeforeSetSecondSourceQuantity(SecondSourceQuantityArray);

        case SecondSourceQuantityArray[1] of
            DATABASE::"Warehouse Receipt Line", DATABASE::"Warehouse Shipment Line":
                begin
                    SourceQuantityArray[2] := SecondSourceQuantityArray[2]; // "Qty. to Handle (Base)"
                    SourceQuantityArray[3] := SecondSourceQuantityArray[3]; // "Qty. to Invoice (Base)"
                    SetPageControls("Item Tracking Lines Controls"::Invoice, false);
                end;
            else
                exit;
        end;

        CalculateSums();
    end;

    procedure SetSecondSourceRowID(RowID: Text[250])
    begin
        SecondSourceRowID := RowID;
    end;

    protected procedure AddReservEntriesToTempRecSet(var ReservEntry: Record "Reservation Entry"; var TempTrackingSpecification: Record "Tracking Specification" temporary; SwapSign: Boolean; Color: Integer)
    begin
        AddReservEntriesToTempRecSet(ReservEntry, TempTrackingSpecification, SwapSign, Color, 0);
    end;

    protected procedure AddReservEntriesToTempRecSet(var ReservEntry: Record "Reservation Entry"; var TempTrackingSpecification: Record "Tracking Specification" temporary; SwapSign: Boolean; Color: Integer; SrcQtyRoundingPrecision: Decimal)
    var
        FromReservEntry: Record "Reservation Entry";
        AddTracking: Boolean;
    begin
        if ReservEntry.FindSet() then
            repeat
                if Color = 0 then begin
                    TempReservEntry := ReservEntry;
                    TempReservEntry.Insert();
                end;
                if ReservEntry.TrackingExists then begin
                    AddTracking := true;
                    if SecondSourceID = DATABASE::"Warehouse Shipment Line" then
                        if FromReservEntry.Get(ReservEntry."Entry No.", not ReservEntry.Positive) then
                            AddTracking := (FromReservEntry."Source Type" = DATABASE::"Assembly Header") = IsAssembleToOrder
                        else
                            AddTracking := not IsAssembleToOrder;

                    if AddTracking then begin
                        TempTrackingSpecification.TransferFields(ReservEntry);
                        TempTrackingSpecification."Qty. Rounding Precision (Base)" := SrcQtyRoundingPrecision;
                        OnAddReservEntriesToTempRecSetOnAfterTempTrackingSpecificationTransferFields(TempTrackingSpecification, ReservEntry);
                        // Ensure uniqueness of Entry No. by making it negative:
                        TempTrackingSpecification."Entry No." *= -1;
                        if SwapSign then
                            TempTrackingSpecification."Quantity (Base)" *= -1;
                        if Color <> 0 then begin
                            TempTrackingSpecification."Quantity Handled (Base)" := TempTrackingSpecification."Quantity (Base)";
                            TempTrackingSpecification."Quantity Invoiced (Base)" := TempTrackingSpecification."Quantity (Base)";
                            TempTrackingSpecification."Qty. to Handle (Base)" := 0;
                            TempTrackingSpecification."Qty. to Invoice (Base)" := 0;
                        end;
                        TempTrackingSpecification."Buffer Status" := Color;
                        OnAddReservEntriesToTempRecSetOnBeforeInsert(TempTrackingSpecification, ReservEntry, SwapSign, Color);
                        TempTrackingSpecification.Insert();
                    end;
                end;
            until ReservEntry.Next() = 0;
    end;

    local procedure AddToGlobalRecordSet(var TempTrackingSpecification: Record "Tracking Specification" temporary)
    var
        ExpDate: Date;
        EntriesExist: Boolean;
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
    begin
        TempTrackingSpecification.SetTrackingKey();
        OnAddToGlobalRecordSetOnAfterTrackingSpecificationSetCurrentKey(TempTrackingSpecification);

        if TempTrackingSpecification.Find('-') then
            repeat
                TempTrackingSpecification.SetTrackingFilterFromSpec(TempTrackingSpecification);
                TempTrackingSpecification.CalcSums(
                    "Quantity (Base)", "Qty. to Handle (Base)", "Qty. to Invoice (Base)",
                    "Qty. to Handle (Alt.)", "Quantity Handled (Alt.)", "Quantity Invoiced (Alt.)", // PR3.60
                    "Quantity Handled (Base)", "Quantity Invoiced (Base)");
                OnAddToGlobalRecordSetOnAfterTrackingSpecificationCalcSums(TempTrackingSpecification);

                if TempTrackingSpecification."Quantity (Base)" <> 0 then begin
                    Rec := TempTrackingSpecification;
                    Rec."Quantity (Base)" *= CurrentSignFactor;
                    Rec."Qty. to Handle (Base)" *= CurrentSignFactor;
                    Rec."Qty. to Invoice (Base)" *= CurrentSignFactor;
                    Rec."Quantity Handled (Base)" *= CurrentSignFactor;
                    Rec."Quantity Invoiced (Base)" *= CurrentSignFactor;
                    Rec."Quantity (Alt.)" *= CurrentSignFactor;          // PR3.61
                    Rec."Qty. to Handle (Alt.)" *= CurrentSignFactor;    // PR3.60
                    Rec."Qty. to Invoice (Alt.)" *= CurrentSignFactor;   // PR3.70
                    Rec."Quantity Handled (Alt.)" *= CurrentSignFactor;  // PR3.60
                    Rec."Quantity Invoiced (Alt.)" *= CurrentSignFactor; // PR3.60
                                                                         //"Quantity (Cont.)" *= CurrentSignFactor;         // PR3.61, P8001035
                    Rec."Qty. to Handle" := Rec.CalcQty(Rec."Qty. to Handle (Base)");
                    Rec."Qty. to Invoice" := Rec.CalcQty(Rec."Qty. to Invoice (Base)");
                    Rec."Entry No." := NextEntryNo;
                    if TrackAlternateUnits then              // PR3.60
                        AltQtyMgmt.SetTrackingLineAltQty(Rec); // PR3.60

                    // skip expiration date check for performance
                    // item tracking code is cached at the beginning of the caller method
                    if not ItemTrackingCode."Use Expiration Dates" then
                        Rec."Buffer Status2" := Rec."Buffer Status2"::"ExpDate blocked"
                    else begin
                        ExpDate := ItemTrackingMgt.ExistingExpirationDate(Rec, false, EntriesExist);
                        if ExpDate <> 0D then begin
                            Rec."Expiration Date" := ExpDate;
                            Rec."Buffer Status2" := Rec."Buffer Status2"::"ExpDate blocked";
                        end;
                    end;

                    OnBeforeAddToGlobalRecordSet(Rec, EntriesExist, CurrentSignFactor, TempTrackingSpecification);
                    Rec.Insert();

                    if Rec."Buffer Status" = 0 then begin
                        xTempTrackingSpecification := Rec;
                        xTempTrackingSpecification.Insert();
                    end;
                end;

                TempTrackingSpecification.Find('+');
                TempTrackingSpecification.ClearTrackingFilter();
            until TempTrackingSpecification.Next() = 0;
    end;

#if not CLEAN19
    [Obsolete('Replaced by SetPageControls().', '19.0')]
    protected procedure SetControls(Controls: Option Handle,Invoice,Quantity,Reclass,Tracking; SetAccess: Boolean)
    begin
        SetPageControls("Item Tracking Lines Controls".FromInteger(Controls), SetAccess);

        OnAfterSetControls(ItemTrackingCode, Controls, SetAccess);
    end;
#endif

    protected procedure SetPageControls(Controls: Enum "Item Tracking Lines Controls"; SetAccess: Boolean)
    begin
        case Controls of
            "Item Tracking Lines Controls"::Handle:
                begin
                    Handle1Visible := SetAccess;
                    Handle2Visible := SetAccess;
                    Handle3Visible := SetAccess;
                    QtyToHandleBaseVisible := SetAccess;
                    QtyToHandleBaseEditable := SetAccess;
                    QtytoHandleAltVisible := SetAccess;  // PR3.60
                    QtytoHandleAltEditable := SetAccess; // PR3.60
                end;
            "Item Tracking Lines Controls"::Invoice:
                begin
                    Invoice1Visible := SetAccess;
                    Invoice2Visible := SetAccess;
                    Invoice3Visible := SetAccess;
                    QtyToInvoiceBaseVisible := SetAccess;
                    QtyToInvoiceBaseEditable := SetAccess;
                    QtytoInvoiceAltVisible := SetAccess;  // PR3.60
                end;
            "Item Tracking Lines Controls"::Quantity:
                begin
                    QuantityBaseEditable := SetAccess;
                    SerialNoEditable := SetAccess;
                    LotNoEditable := SetAccess;
                    PackageNoEditable := SetAccess;
                    DescriptionEditable := SetAccess;
                    InsertIsBlocked := true;
                end;
            "Item Tracking Lines Controls"::Reclass:
                begin
                    NewSerialNoVisible := not IsDirectTransfer and SetAccess;
                    NewSerialNoEditable := not IsDirectTransfer and SetAccess;
                    NewLotNoVisible := not IsDirectTransfer and SetAccess;
                    NewLotNoEditable := not IsDirectTransfer and SetAccess;
                    NewLotStatusEditable := SetAccess; // P8001083
                    NewPackageNoVisible := SetAccess;
                    NewPackageNoEditable := SetAccess;
                    NewExpirationDateVisible := SetAccess;
                    NewExpirationDateEditable := ItemTrackingCode."Use Expiration Dates" and SetAccess;
                    ButtonLineReclassVisible := SetAccess;
                    ButtonLineVisible := not SetAccess;
                end;
            "Item Tracking Lines Controls"::Tracking:
                begin
                    SerialNoEditable := SetAccess;
                    LotNoEditable := SetAccess;
                    PackageNoEditable := SetAccess;
                    ExpirationDateEditable := ItemTrackingCode."Use Expiration Dates" and SetAccess;
                    WarrantyDateEditable := SetAccess;
                    InsertIsBlocked := SetAccess;
                end;
        end;

        OnAfterSetPageControls(ItemTrackingCode, Controls, SetAccess);
    end;

    local procedure SetWarehouseControls(TrackingSpecification: Record "Tracking Specification")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSetWarehouseControls(Rec, IsHandled);
        if IsHandled then
            exit;

        if ItemTrackingMgt.ItemTrkgIsManagedByWhse(
             TrackingSpecification."Source Type",
             TrackingSpecification."Source Subtype",
             TrackingSpecification."Source ID",
             TrackingSpecification."Source Prod. Order Line",
             TrackingSpecification."Source Ref. No.",
             TrackingSpecification."Location Code",
             TrackingSpecification."Item No.")
        then begin
            SetPageControls("Item Tracking Lines Controls"::Quantity, false);
            QtyToHandleBaseEditable := true;
            DeleteIsBlocked := true;
            ItemTrackingManagedByWhse := true;
        end;
    end;

    local procedure GetItem(ItemNo: Code[20])
    begin
        if Item."No." <> ItemNo then begin
            Item.Get(ItemNo);
            Item.TestField("Item Tracking Code");
            if ItemTrackingCode.Code <> Item."Item Tracking Code" then
                ItemTrackingCode.Get(Item."Item Tracking Code");
        end;
    end;

    local procedure SetFilters(TrackingSpecification: Record "Tracking Specification")
    begin
        Rec.FilterGroup := 2;
        Rec.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.");
        Rec.SetRange("Source ID", TrackingSpecification."Source ID");
        Rec.SetRange("Source Type", TrackingSpecification."Source Type");
        Rec.SetRange("Source Subtype", TrackingSpecification."Source Subtype");
        Rec.SetRange("Source Batch Name", TrackingSpecification."Source Batch Name");
        if (TrackingSpecification."Source Type" = DATABASE::"Transfer Line") and
           (TrackingSpecification."Source Subtype" = 1)
        then begin
            Rec.SetFilter("Source Prod. Order Line", '0 | ' + Format(TrackingSpecification."Source Ref. No."));
            Rec.SetRange("Source Ref. No.");
        end else begin
            Rec.SetRange("Source Prod. Order Line", TrackingSpecification."Source Prod. Order Line");
            Rec.SetRange("Source Ref. No.", TrackingSpecification."Source Ref. No.");
        end;
        Rec.SetRange("Item No.", TrackingSpecification."Item No.");
        Rec.SetRange("Location Code", TrackingSpecification."Location Code");
        Rec.SetRange("Variant Code", TrackingSpecification."Variant Code");
        Rec.FilterGroup := 0;

        OnAfterSetFilters(Rec, TrackingSpecification);

        // PR3.60 Begin
        NewItemTrackingLine."Item No." := TrackingSpecification."Item No.";
        NewItemTrackingLine."Location Code" := TrackingSpecification."Location Code";
        NewItemTrackingLine."Variant Code" := TrackingSpecification."Variant Code";
        NewItemTrackingLine."Bin Code" := TrackingSpecification."Bin Code";
        NewItemTrackingLine.Positive := TrackingSpecification.Positive;
        NewItemTrackingLine."Source Type" := TrackingSpecification."Source Type";
        NewItemTrackingLine."Source Subtype" := TrackingSpecification."Source Subtype";
        NewItemTrackingLine."Source ID" := TrackingSpecification."Source ID";
        NewItemTrackingLine."Source Batch Name" := TrackingSpecification."Source Batch Name";
        NewItemTrackingLine."Source Prod. Order Line" := TrackingSpecification."Source Prod. Order Line";
        NewItemTrackingLine."Source Ref. No." := TrackingSpecification."Source Ref. No.";
        // PR3.60 End
    end;

    local procedure CheckItemTrackingLine(TrackingLine: Record "Tracking Specification")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckItemTrackingLine(TrackingLine, IsHandled, SourceQuantityArray);
        if IsHandled then
            exit;

        if TrackingLine."Quantity (Base)" * SourceQuantityArray[1] < 0 then
            if SourceQuantityArray[1] < 0 then
                Error(Text002, Text003)
            else
                Error(Text002, Text004);
    end;

    procedure CalculateSums()
    var
        xTrackingSpec: Record "Tracking Specification";
    begin
        xTrackingSpec.Copy(Rec);
        Rec.Reset();
        Rec.CalcSums("Quantity (Base)", "Qty. to Handle (Base)", "Qty. to Invoice (Base)");
        OnCalculateSumsOnAfterCalcSums(Rec);
        TotalTrackingSpecification := Rec;
        Rec.Copy(xTrackingSpec);

        UpdateUndefinedQtyArray();
    end;

    protected procedure UpdateUndefinedQty(): Boolean
    var
        IsHandled: Boolean;
        ReturnValue: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateUndefinedQty(Rec, TotalTrackingSpecification, UndefinedQtyArray, SourceQuantityArray, ReturnValue, IsHandled);
        if IsHandled then
            exit(ReturnValue);

        UpdateUndefinedQtyArray;
        if ProdOrderLineHandling then // Avoid check for prod.journal lines
            exit(true);
        exit(Abs(SourceQuantityArray[1]) >= Abs(TotalTrackingSpecification."Quantity (Base)"));
    end;

    local procedure UpdateUndefinedQtyArray()
    begin
        UndefinedQtyArray[1] := SourceQuantityArray[1] - TotalTrackingSpecification."Quantity (Base)";
        UndefinedQtyArray[2] := SourceQuantityArray[2] - TotalTrackingSpecification."Qty. to Handle (Base)";
        UndefinedQtyArray[3] := SourceQuantityArray[3] - TotalTrackingSpecification."Qty. to Invoice (Base)";

        OnAfterUpdateUndefinedQtyArray(TotalTrackingSpecification);
    end;

    local procedure TempRecIsValid() OK: Boolean
    var
        ReservEntry: Record "Reservation Entry";
        RecordCount: Integer;
        IdenticalArray: array[2] of Boolean;
    begin
        OK := false;
        TempReservEntry.SetCurrentKey("Entry No.", Positive);
        ReservEntry.SetCurrentKey("Source ID", "Source Ref. No.", "Source Type",
          "Source Subtype", "Source Batch Name", "Source Prod. Order Line");

        ReservEntry.CopyFilters(TempReservEntry);

        if ReservEntry.FindSet() then
            repeat
                if not TempReservEntry.Get(ReservEntry."Entry No.", ReservEntry.Positive) then
                    exit(false);
                if not EntriesAreIdentical(ReservEntry, TempReservEntry, IdenticalArray) then
                    exit(false);
                RecordCount += 1;
            until ReservEntry.Next() = 0;

        OK := RecordCount = TempReservEntry.Count();
    end;

    procedure EntriesAreIdentical(var ReservEntry1: Record "Reservation Entry"; var ReservEntry2: Record "Reservation Entry"; var IdenticalArray: array[2] of Boolean): Boolean
    begin
        IdenticalArray[1] :=
            (ReservEntry1."Entry No." = ReservEntry2."Entry No.") and
            (ReservEntry1."Item No." = ReservEntry2."Item No.") and
            (ReservEntry1."Location Code" = ReservEntry2."Location Code") and
            (ReservEntry1."Quantity (Base)" = ReservEntry2."Quantity (Base)") and
            (ReservEntry1."Quantity (Alt.)" = ReservEntry2."Quantity (Alt.)") and // PR3.61
            (ReservEntry1."Reservation Status" = ReservEntry2."Reservation Status") and
            (ReservEntry1."Creation Date" = ReservEntry2."Creation Date") and
            (ReservEntry1."Transferred from Entry No." = ReservEntry2."Transferred from Entry No.") and
            (ReservEntry1."Source Type" = ReservEntry2."Source Type") and
            (ReservEntry1."Source Subtype" = ReservEntry2."Source Subtype") and
            (ReservEntry1."Source ID" = ReservEntry2."Source ID") and
            (ReservEntry1."Source Batch Name" = ReservEntry2."Source Batch Name") and
            (ReservEntry1."Source Prod. Order Line" = ReservEntry2."Source Prod. Order Line") and
            (ReservEntry1."Source Ref. No." = ReservEntry2."Source Ref. No.") and
            (ReservEntry1."Expected Receipt Date" = ReservEntry2."Expected Receipt Date") and
            (ReservEntry1."Shipment Date" = ReservEntry2."Shipment Date") and
            (ReservEntry1."Created By" = ReservEntry2."Created By") and
            (ReservEntry1."Changed By" = ReservEntry2."Changed By") and
            (ReservEntry1.Positive = ReservEntry2.Positive) and
            (ReservEntry1."Qty. per Unit of Measure" = ReservEntry2."Qty. per Unit of Measure") and
            (ReservEntry1.Quantity = ReservEntry2.Quantity) and
            (ReservEntry1."Action Message Adjustment" = ReservEntry2."Action Message Adjustment") and
            (ReservEntry1.Binding = ReservEntry2.Binding) and
            (ReservEntry1."Suppressed Action Msg." = ReservEntry2."Suppressed Action Msg.") and
            (ReservEntry1."Planning Flexibility" = ReservEntry2."Planning Flexibility") and
            (ReservEntry1."Variant Code" = ReservEntry2."Variant Code") and
            (ReservEntry1."Quantity Invoiced (Base)" = ReservEntry2."Quantity Invoiced (Base)") and
            ReservEntry1.HasSameTracking(ReservEntry2);

        IdenticalArray[2] :=
            (ReservEntry1.Description = ReservEntry2.Description) and
            (ReservEntry1."Expiration Date" = ReservEntry2."Expiration Date") and
            (ReservEntry1."Warranty Date" = ReservEntry2."Warranty Date") and
            (ReservEntry1."New Expiration Date" = ReservEntry2."New Expiration Date") and
            (ReservEntry1."Supplier Lot No." = ReservEntry2."Supplier Lot No.") and // P8001106
            (ReservEntry1."Lot Creation Date" = ReservEntry2."Lot Creation Date") and                         // P8008351
            (ReservEntry1."Country/Region of Origin Code" = ReservEntry2."Country/Region of Origin Code") and // P8008351
            ReservEntry1.HasSameNewTracking(ReservEntry2);

        OnAfterEntriesAreIdentical(ReservEntry1, ReservEntry2, IdenticalArray);

        exit(IdenticalArray[1] and IdenticalArray[2]);
    end;

    local procedure QtyToHandleAndInvoiceChanged(var ReservEntry1: Record "Reservation Entry"; var ReservEntry2: Record "Reservation Entry") HasChanged: Boolean
    begin
        HasChanged :=
            (ReservEntry1."Qty. to Handle (Base)" <> ReservEntry2."Qty. to Handle (Base)") or
            (ReservEntry1."Qty. to Handle (Alt.)" <> ReservEntry2."Qty. to Handle (Alt.)") or // PR3.60
            (ReservEntry1."Qty. to Invoice (Base)" <> ReservEntry2."Qty. to Invoice (Base)");

        OnAfterQtyToHandleAndInvoiceChanged(ReservEntry1, ReservEntry2, HasChanged);
    end;

    procedure NextEntryNo(): Integer
    begin
        LastEntryNo += 1;
        exit(LastEntryNo);
    end;

    procedure WriteToDatabase()
    var
        Window: Dialog;
        ChangeType: Option Insert,Modify,Delete;
        EntryNo: Integer;
        NoOfLines: Integer;
        i: Integer;
        ModifyLoop: Integer;
        Decrease: Boolean;
    begin
        OnBeforeWriteToDatabase(Rec, CurrentPageIsOpen, BlockCommit);
        if CurrentPageIsOpen then begin
            TempReservEntry.LockTable();
            TempRecValid();

            if Item."Order Tracking Policy" = Item."Order Tracking Policy"::None then
                QtyToAddAsBlank := 0
            else
                QtyToAddAsBlank := UndefinedQtyArray[1] * CurrentSignFactor;

            Rec.Reset();
            Rec.DeleteAll();

            Window.Open('#1############# @2@@@@@@@@@@@@@@@@@@@@@');
            Window.Update(1, Text018);
            NoOfLines := TempItemTrackLineInsert.Count + TempItemTrackLineModify.Count + TempItemTrackLineDelete.Count();
            if TempItemTrackLineDelete.Find('-') then begin
                repeat
                    i := i + 1;
                    if i mod 100 = 0 then
                        Window.Update(2, Round(i / NoOfLines * 10000, 1));
                    RegisterChange(TempItemTrackLineDelete, TempItemTrackLineDelete, ChangeType::Delete, false);
                    if TempItemTrackLineModify.Get(TempItemTrackLineDelete."Entry No.") then
                        TempItemTrackLineModify.Delete();
                until TempItemTrackLineDelete.Next() = 0;
                TempItemTrackLineDelete.DeleteAll();
            end;

            for ModifyLoop := 1 to 2 do begin
                if TempItemTrackLineModify.Find('-') then
                    repeat
                        if xTempTrackingSpecification.Get(TempItemTrackLineModify."Entry No.") then begin
                            // Process decreases before increases
                            OnWriteToDatabaseOnBeforeRegisterDecrease(TempItemTrackLineModify);
                            Decrease := (xTempTrackingSpecification."Quantity (Base)" > TempItemTrackLineModify."Quantity (Base)");
                            if ((ModifyLoop = 1) and Decrease) or ((ModifyLoop = 2) and not Decrease) then begin
                                i := i + 1;
                                if ShouldModifyTrackingSpecification(xTempTrackingSpecification, TempItemTrackLineModify) then begin
                                    RegisterChange(xTempTrackingSpecification, xTempTrackingSpecification, ChangeType::Delete, false);
                                    RegisterChange(TempItemTrackLineModify, TempItemTrackLineModify, ChangeType::Insert, false);
                                    if (TempItemTrackLineInsert."Quantity (Base)" <> TempItemTrackLineInsert."Qty. to Handle (Base)") or
                                       (TempItemTrackLineInsert."Quantity (Base)" <> TempItemTrackLineInsert."Qty. to Invoice (Base)")
                                    then
                                        SetQtyToHandleAndInvoice(TempItemTrackLineInsert);
                                end else begin
                                    RegisterChange(xTempTrackingSpecification, TempItemTrackLineModify, ChangeType::Modify, false);
                                    SetQtyToHandleAndInvoice(TempItemTrackLineModify);
                                end;
                                TempItemTrackLineModify.Delete();
                            end;
                        end else begin
                            i := i + 1;
                            TempItemTrackLineModify.Delete();
                        end;
                        if i mod 100 = 0 then
                            Window.Update(2, Round(i / NoOfLines * 10000, 1));
                    until TempItemTrackLineModify.Next() = 0;
            end;

            if TempItemTrackLineInsert.Find('-') then begin
                repeat
                    i := i + 1;
                    if i mod 100 = 0 then
                        Window.Update(2, Round(i / NoOfLines * 10000, 1));
                    if TempItemTrackLineModify.Get(TempItemTrackLineInsert."Entry No.") then
                        TempItemTrackLineInsert.TransferFields(TempItemTrackLineModify);
                    OnWriteToDatabaseOnBeforeRegisterInsert(TempItemTrackLineInsert);
                    if not RegisterChange(TempItemTrackLineInsert, TempItemTrackLineInsert, ChangeType::Insert, false) then
                        Error(Text005);
                    if (TempItemTrackLineInsert."Quantity (Base)" <> TempItemTrackLineInsert."Qty. to Handle (Base)") or
                       (TempItemTrackLineInsert."Quantity (Base)" <> TempItemTrackLineInsert."Qty. to Invoice (Base)")
                    then
                        SetQtyToHandleAndInvoice(TempItemTrackLineInsert);
                until TempItemTrackLineInsert.Next() = 0;
                TempItemTrackLineInsert.DeleteAll();
            end;
            Window.Close();
        end else begin
            TempReservEntry.LockTable();
            TempRecValid();

            if Item."Order Tracking Policy" = Item."Order Tracking Policy"::None then
                QtyToAddAsBlank := 0
            else
                QtyToAddAsBlank := UndefinedQtyArray[1] * CurrentSignFactor;

            Rec.Reset();
            Rec.SetFilter("Buffer Status", '<>%1', 0);
            Rec.DeleteAll();
            Rec.Reset();

            xTempTrackingSpecification.Reset();
            Rec.SetCurrentKey("Entry No.");
            xTempTrackingSpecification.SetCurrentKey("Entry No.");
            if xTempTrackingSpecification.Find('-') then
                repeat
                    Rec.SetTrackingFilterFromSpec(xTempTrackingSpecification);
                    if Rec.Find('-') then begin
                        if RegisterChange(xTempTrackingSpecification, Rec, ChangeType::Modify, false) then begin
                            EntryNo := xTempTrackingSpecification."Entry No.";
                            xTempTrackingSpecification := Rec;
                            xTempTrackingSpecification."Entry No." := EntryNo;
                            xTempTrackingSpecification.Modify();
                        end;
                        SetQtyToHandleAndInvoice(Rec);
                        Rec.Delete();
                    end else begin
                        RegisterChange(xTempTrackingSpecification, xTempTrackingSpecification, ChangeType::Delete, false);
                        xTempTrackingSpecification.Delete();
                    end;
                until xTempTrackingSpecification.Next() = 0;

            Rec.Reset();

            if Rec.Find('-') then
                repeat
                    if RegisterChange(Rec, Rec, ChangeType::Insert, false) then begin
                        xTempTrackingSpecification := Rec;
                        xTempTrackingSpecification.Insert();
                    end else
                        Error(Text005);
                    SetQtyToHandleAndInvoice(Rec);
                    Rec.Delete();
                until Rec.Next() = 0;
        end;

        OnWriteToDatabaseOnBeforeUpdateOrderTracking(TempReservEntry);
        UpdateResEntryAltQty(Rec); // P8000267B
        UpdateOrderTrackingAndReestablishReservation();

        OnWriteToDataOnBeforeCommit(Rec, TempReservEntry);

        if not BlockCommit then
            Commit();
    end;

    local procedure ShouldModifyTrackingSpecification(TrackingSpecification: Record "Tracking Specification"; TrackingSpecificationModify: Record "Tracking Specification"): Boolean
    var
        IsHandled: Boolean;
        Result: Boolean;
    begin
        IsHandled := false;
        OnBeforeShouldModifyTrackingSpecification(TrackingSpecification, TrackingSpecificationModify, Result, IsHandled);
        if IsHandled then
            exit(Result);

        exit(
            (not TrackingSpecification.HasSameTracking(TrackingSpecificationModify)) or
            (TrackingSpecification."Appl.-from Item Entry" <> TrackingSpecificationModify."Appl.-from Item Entry") or
            (TrackingSpecification."Appl.-to Item Entry" <> TrackingSpecificationModify."Appl.-to Item Entry"));
    end;

    protected procedure RegisterChange(var OldTrackingSpecification: Record "Tracking Specification"; var NewTrackingSpecification: Record "Tracking Specification"; ChangeType: Option Insert,Modify,FullDelete,PartDelete,ModifyAll; ModifySharedFields: Boolean) OK: Boolean
    var
        ReservEntry1: Record "Reservation Entry";
        ReservEntry2: Record "Reservation Entry";
        SavedOldTrackingSpecification: Record "Tracking Specification";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        ReservationMgt: Codeunit "Reservation Management";
        QtyToAdd: Decimal;
        IdenticalArray: array[2] of Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeRegisterChange(OldTrackingSpecification, NewTrackingSpecification, CurrentSignFactor, CurrentRunMode.AsInteger(), IsHandled, CurrentPageIsOpen);
        if IsHandled then
            exit;

        OK := false;

        if ((CurrentSignFactor * NewTrackingSpecification."Qty. to Handle") < 0) and
           (CurrentRunMode <> CurrentRunMode::"Drop Shipment")
        then begin
            NewTrackingSpecification."Expiration Date" := 0D;
            OldTrackingSpecification."Expiration Date" := 0D;
        end;

        case ChangeType of
            ChangeType::Insert:
                begin
                    IsHandled := false;
                    OnRegisterChangeOnBeforeInsert(NewTrackingSpecification, OldTrackingSpecification, IsHandled);
                    if IsHandled then
                        exit(true);
                    // P8000702
                    if ((OldTrackingSpecification."Quantity (Base)" = 0) and (OldTrackingSpecification."Quantity (Alt.)" = 0)) or // PR3.61
                      not OldTrackingSpecification.TrackingExists
                    then
                        exit(true);
                    TempReservEntry.SetTrackingFilterBlank();
                    OldTrackingSpecification."Quantity (Base)" :=
                      CurrentSignFactor *
                      ReservEngineMgt.AddItemTrackingToTempRecSet(
                        TempReservEntry, NewTrackingSpecification, CurrentSignFactor * OldTrackingSpecification."Quantity (Base)",
                        QtyToAddAsBlank, ItemTrackingCode);
                    TempReservEntry.ClearTrackingFilter();

                    // Late Binding
                    ProcessLateBinding(NewTrackingSpecification);

                    // P8000702
                    // IF OldTrackingSpecification."Quantity (Base)" = 0 THEN // P8001095
                    if (OldTrackingSpecification."Quantity (Base)" = 0) and (OldTrackingSpecification."Quantity (Alt.)" = 0) then // PR3.61
                        exit(true);

                    if CurrentRunMode = CurrentRunMode::Reclass then begin
                        CreateReservEntry.SetNewTrackingFromNewTrackingSpecification(OldTrackingSpecification);
                        CreateReservEntry.SetNewExpirationDate(OldTrackingSpecification."New Expiration Date");
                        CreateReservEntry.SetNewLotStatus(OldTrackingSpecification."New Lot Status Code"); // P8001083
                    end;

                    OnRegisterChangeOnChangeTypeInsertOnBeforeInsertReservEntry(
                        Rec, OldTrackingSpecification, NewTrackingSpecification, CurrentRunMode.AsInteger());

                    CreateReservEntry.SetDates(
                      NewTrackingSpecification."Warranty Date", NewTrackingSpecification."Expiration Date");
                    CreateReservEntry.SetSupplierLotNo(NewTrackingSpecification."Supplier Lot No."); // P8001106
                    CreateReservEntry.SetLotCreationDate(NewTrackingSpecification."Lot Creation Date");             // P8008351
                    CreateReservEntry.SetCountryOfOrigin(NewTrackingSpecification."Country/Region of Origin Code"); // P8008351
                    CreateReservEntry.SetApplyFromEntryNo(NewTrackingSpecification."Appl.-from Item Entry");
                    CreateReservEntry.SetApplyToEntryNo(NewTrackingSpecification."Appl.-to Item Entry");
                    ReservEntry1.CopyTrackingFromSpec(OldTrackingSpecification);
                    CreateReservEntry.CreateReservEntryFor(
                      OldTrackingSpecification."Source Type",
                      OldTrackingSpecification."Source Subtype",
                      OldTrackingSpecification."Source ID",
                      OldTrackingSpecification."Source Batch Name",
                      OldTrackingSpecification."Source Prod. Order Line",
                      OldTrackingSpecification."Source Ref. No.",
                      OldTrackingSpecification."Qty. per Unit of Measure",
                      0,
                      OldTrackingSpecification."Quantity (Base)", ReservEntry1);

                    OnAfterCreateReservEntryFor(OldTrackingSpecification, NewTrackingSpecification, CreateReservEntry);

                    CreateReservEntry.CreateReservEntryExtraFields(OldTrackingSpecification, NewTrackingSpecification);

                    CreateReservEntry.CreateEntry(OldTrackingSpecification."Item No.",
                      OldTrackingSpecification."Variant Code",
                      OldTrackingSpecification."Location Code",
                      OldTrackingSpecification.Description,
                      ExpectedReceiptDate,
                      ShipmentDate, 0, CurrentEntryStatus);
                    CreateReservEntry.GetLastEntry(ReservEntry1);
                    OnRegisterChangeOnAfterCreateReservEntry(ReservEntry1, NewTrackingSpecification, OldTrackingSpecification);

                    if Item."Order Tracking Policy" = Item."Order Tracking Policy"::"Tracking & Action Msg." then
                        ReservEngineMgt.UpdateActionMessages(ReservEntry1);

                    if ModifySharedFields then begin
                        ReservEntry1.SetPointerFilter();
                        ReservEntry1.SetTrackingFilterFromReservEntry(ReservEntry1);
                        ReservEntry1.SetFilter("Entry No.", '<>%1', ReservEntry1."Entry No.");
                        ModifyFieldsWithinFilter(ReservEntry1, NewTrackingSpecification);
                    end;

                    OnRegisterChangeOnAfterInsert(NewTrackingSpecification, OldTrackingSpecification, CurrentPageIsOpen);
                    OK := true;
                end;
            ChangeType::Modify:
                begin
                    SavedOldTrackingSpecification := OldTrackingSpecification;
                    ReservEntry1.TransferFields(OldTrackingSpecification);
                    ReservEntry2.TransferFields(NewTrackingSpecification);

                    ReservEntry1."Entry No." := ReservEntry2."Entry No."; // If only entry no. has changed it should not trigger
                    OnRegisterChangeOnChangeTypeModifyOnBeforeCheckEntriesAreIdentical(ReservEntry1, ReservEntry2, OldTrackingSpecification, NewTrackingSpecification, IdenticalArray);
                    if EntriesAreIdentical(ReservEntry1, ReservEntry2, IdenticalArray) then
                        exit(QtyToHandleAndInvoiceChanged(ReservEntry1, ReservEntry2));

                    if ShouldAddQuantityAsBlank(OldTrackingSpecification, NewTrackingSpecification) then begin
                        // Item Tracking is added to any blank reservation entries:
                        TempReservEntry.SetTrackingFilterBlank();

                        OnRegisterChangeOnBeforeAddItemTrackingToTempRecSet(
                            OldTrackingSpecification, NewTrackingSpecification, CurrentSignFactor, TempReservEntry);
                        QtyToAdd :=
                            CurrentSignFactor *
                            ReservEngineMgt.AddItemTrackingToTempRecSet(
                                TempReservEntry, NewTrackingSpecification,
                                CurrentSignFactor * (NewTrackingSpecification."Quantity (Base)" -
                                                    OldTrackingSpecification."Quantity (Base)"), QtyToAddAsBlank,
                                ItemTrackingCode);
                        TempReservEntry.ClearTrackingFilter();

                        // Late Binding
                        ProcessLateBinding(NewTrackingSpecification);

                        OldTrackingSpecification."Quantity (Base)" := QtyToAdd;
                        OldTrackingSpecification."Warranty Date" := NewTrackingSpecification."Warranty Date";
                        OldTrackingSpecification."Expiration Date" := NewTrackingSpecification."Expiration Date";
                        OldTrackingSpecification.Description := NewTrackingSpecification.Description;
                        OnAfterCopyTrackingSpec(NewTrackingSpecification, OldTrackingSpecification);

                        RegisterChange(
                            OldTrackingSpecification, OldTrackingSpecification, ChangeType::Insert, not IdenticalArray[2]);
                    end else begin
                        TempReservEntry.SetTrackingFilterFromSpec(OldTrackingSpecification);
                        OldTrackingSpecification.ClearTracking;
                        OnAfterClearTrackingSpec(OldTrackingSpecification);

                        OnRegisterChangeOnBeforeAddItemTrackingToTempRecSet(
                            OldTrackingSpecification, NewTrackingSpecification, CurrentSignFactor, TempReservEntry);
                        QtyToAdd :=
                            CurrentSignFactor *
                            ReservEngineMgt.AddItemTrackingToTempRecSet(
                                TempReservEntry, OldTrackingSpecification,
                                CurrentSignFactor * (OldTrackingSpecification."Quantity (Base)" -
                                                    NewTrackingSpecification."Quantity (Base)"), QtyToAddAsBlank,
                                ItemTrackingCode);
                        TempReservEntry.ClearTrackingFilter();
                        RegisterChange(
                            NewTrackingSpecification, NewTrackingSpecification, ChangeType::PartDelete, not IdenticalArray[2]);
                    end;
                    OnRegisterChangeOnAfterModify(NewTrackingSpecification, OldTrackingSpecification, CurrentPageIsOpen, SavedOldTrackingSpecification);
                    OK := true;
                end;
            ChangeType::FullDelete,
            ChangeType::PartDelete:
                begin
                    ReservationMgt.SetItemTrackingHandling(1); // Allow deletion of Item Tracking
                    ReservEntry1.TransferFields(OldTrackingSpecification);
                    ReservEntry1.SetPointerFilter();
                    ReservEntry1.SetTrackingFilterFromReservEntry(ReservEntry1);
                    if ChangeType = ChangeType::FullDelete then begin
                        TempReservEntry.SetTrackingFilterFromSpec(OldTrackingSpecification);
                        OldTrackingSpecification.ClearTracking;
                        OnAfterClearTrackingSpec(OldTrackingSpecification);
                        QtyToAdd :=
                          CurrentSignFactor *
                          ReservEngineMgt.AddItemTrackingToTempRecSet(
                            TempReservEntry, OldTrackingSpecification,
                            CurrentSignFactor * OldTrackingSpecification."Quantity (Base)",
                            QtyToAddAsBlank, ItemTrackingCode);
                        TempReservEntry.ClearTrackingFilter();
                        ReservationMgt.DeleteReservEntries(true, 0, ReservEntry1);
                        OnRegisterChangeOnAfterFullDelete(ReservEntry1, NewTrackingSpecification, OldTrackingSpecification, CurrentPageIsOpen);
                    end else begin
                        ReservationMgt.DeleteReservEntries(false, ReservEntry1."Quantity (Base)" -
                          OldTrackingSpecification."Quantity Handled (Base)", ReservEntry1);
                        if ModifySharedFields then begin
                            ReservEntry1.SetRange("Reservation Status");
                            ModifyFieldsWithinFilter(ReservEntry1, OldTrackingSpecification);
                        end;
                        OnRegisterChangeOnAfterPartialDelete(NewTrackingSpecification, OldTrackingSpecification, ReservEntry1, CurrentPageIsOpen);
                    end;
                    OK := true;
                end;
        end;
        SetQtyToHandleAndInvoice(NewTrackingSpecification);
    end;

    local procedure ProcessLateBinding(var NewTrackingSpecification: Record "Tracking Specification")
    var
        LostReservQty: Decimal;
    begin
        if ReservEngineMgt.RetrieveLostReservQty(LostReservQty) then begin
            TempItemTrackLineReserv := NewTrackingSpecification;
            TempItemTrackLineReserv."Quantity (Base)" := LostReservQty * CurrentSignFactor;
            OnProcessLateBindingOnBeforeTempItemTrackLineReservInsert(TempItemTrackLineReserv, CurrentSignFactor);
            TempItemTrackLineReserv.Insert();
        end;
    end;

    local procedure ShouldAddQuantityAsBlank(OldTrackingSpecification: Record "Tracking Specification"; NewTrackingSpecification: Record "Tracking Specification"): Boolean
    var
        IsHandled: Boolean;
        Result: Boolean;
    begin
        IsHandled := false;
        OnBeforeShouldAddQuantityAsBlank(OldTrackingSpecification, NewTrackingSpecification, Result, IsHandled);
        if IsHandled then
            exit(Result);

        exit(
            Abs(OldTrackingSpecification."Quantity (Base)") < Abs(NewTrackingSpecification."Quantity (Base)"));
    end;

    local procedure UpdateOrderTrackingAndReestablishReservation()
    var
        TempReservEntry: Record "Reservation Entry" temporary;
        LateBindingMgt: Codeunit "Late Binding Management";
    begin
        // Order Tracking
        if ReservEngineMgt.CollectAffectedSurplusEntries(TempReservEntry) then begin
            LateBindingMgt.SetOrderTrackingSurplusEntries(TempReservEntry);
            if Item."Order Tracking Policy" <> Item."Order Tracking Policy"::None then
                ReservEngineMgt.UpdateOrderTracking(TempReservEntry);
        end;

        // Late Binding
        if TempItemTrackLineReserv.FindSet() then
            repeat
                LateBindingMgt.ReserveItemTrackingLine(TempItemTrackLineReserv, 0, TempItemTrackLineReserv."Quantity (Base)");
                SetQtyToHandleAndInvoice(TempItemTrackLineReserv);
            until TempItemTrackLineReserv.Next() = 0;
        TempItemTrackLineReserv.DeleteAll();
    end;

    local procedure ModifyFieldsWithinFilter(var ReservEntry1: Record "Reservation Entry"; var TrackingSpecification: Record "Tracking Specification")
    begin
        // Used to ensure that field values that are common to a SN/Lot are copied to all entries.
        if ReservEntry1.Find('-') then
            repeat
                ReservEntry1.Description := TrackingSpecification.Description;
                ReservEntry1."Warranty Date" := TrackingSpecification."Warranty Date";
                ReservEntry1."Expiration Date" := TrackingSpecification."Expiration Date";
                ReservEntry1."Supplier Lot No." := TrackingSpecification."Supplier Lot No."; // P8001106
                ReservEntry1."Lot Creation Date" := TrackingSpecification."Lot Creation Date";                         // P8008351
                ReservEntry1."Country/Region of Origin Code" := TrackingSpecification."Country/Region of Origin Code"; // P8008351
                ReservEntry1.CopyNewTrackingFromTrackingSpec(TrackingSpecification);
                ReservEntry1."New Expiration Date" := TrackingSpecification."New Expiration Date";
                OnAfterMoveFields(TrackingSpecification, ReservEntry1);
                ReservEntry1.Modify();
            until ReservEntry1.Next() = 0;
    end;

    local procedure SetQtyToHandleAndInvoice(TrackingSpecification: Record "Tracking Specification")
    var
        ReservEntry1: Record "Reservation Entry";
        TotalQtyToHandle: Decimal;
        TotalQtyToInvoice: Decimal;
        QtyToHandleThisLine: Decimal;
        QtyToInvoiceThisLine: Decimal;
        ModifyLine: Boolean;
        TotalAltQtyToHandle: Decimal;
        AltQtyToHandleThisLine: Decimal;
        AltQtyToInvoiceThisLine: Decimal;
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
    begin
        OnBeforeSetQtyToHandleAndInvoice(TrackingSpecification, IsCorrection, CurrentSignFactor);

        if IsCorrection then
            exit;

        TotalQtyToHandle := TrackingSpecification."Qty. to Handle (Base)" * CurrentSignFactor;
        TotalQtyToInvoice := TrackingSpecification."Qty. to Invoice (Base)" * CurrentSignFactor;
        TotalAltQtyToHandle := TrackingSpecification."Qty. to Handle (Alt.)" * CurrentSignFactor; // PR3.60

        ReservEntry1.TransferFields(TrackingSpecification);
        ReservEntry1.SetPointerFilter();
        ReservEntry1.SetTrackingFilterFromReservEntry(ReservEntry1);
        if TrackingSpecification.TrackingExists() then begin
            ItemTrackingMgt.SetPointerFilter(TrackingSpecification);
            TrackingSpecification.SetTrackingFilterFromSpec(TrackingSpecification);
            if TrackingSpecification.Find('-') then
                repeat
                    if not TrackingSpecification.Correction then begin
                        ModifyLine := false;
                        QtyToInvoiceThisLine :=
                          TrackingSpecification."Quantity Handled (Base)" - TrackingSpecification."Quantity Invoiced (Base)";
                        if Abs(QtyToInvoiceThisLine) > Abs(TotalQtyToInvoice) then
                            QtyToInvoiceThisLine := TotalQtyToInvoice;
                        if TrackingSpecification."Qty. to Invoice (Base)" <> QtyToInvoiceThisLine then begin
                            TrackingSpecification."Qty. to Invoice (Base)" := QtyToInvoiceThisLine;
                            if TrackingSpecification.TrackAlternateUnits then                   // PR3.60
                                AltQtyMgmt.SetTrackingLineAltQtyToInvoice(TrackingSpecification); // PR3.60
                            ModifyLine := true;
                        end;
                        OnSetQtyToHandleAndInvoiceOnBeforeTrackingSpecModify(TrackingSpecification, TotalTrackingSpecification, ModifyLine);
                        if ModifyLine then
                            TrackingSpecification.Modify();
                        TotalQtyToInvoice -= QtyToInvoiceThisLine;
                    end;
                until (TrackingSpecification.Next() = 0);
        end;

        if TrackingSpecification.NonSerialTrackingExists() then begin
            if (TrackingSpecification."Source Type" = DATABASE::"Transfer Line") and
               (TrackingSpecification."Source Subtype" = 1) and
               (TrackingSpecification."Source Prod. Order Line" <> 0) // Shipped
            then
                ReservEntry1.SetRange("Source Ref. No.");

            for ReservEntry1."Reservation Status" := ReservEntry1."Reservation Status"::Reservation to
                ReservEntry1."Reservation Status"::Prospect
            do begin
                ReservEntry1.SetRange("Reservation Status", ReservEntry1."Reservation Status");
                if ReservEntry1.Find('-') then
                    repeat
                        ModifyLine := false;
                        QtyToHandleThisLine := ReservEntry1."Quantity (Base)";
                        QtyToInvoiceThisLine := QtyToHandleThisLine;
                        AltQtyToHandleThisLine := 0;  // PR3.60
                        AltQtyToInvoiceThisLine := 0; // PR3.60

                        if Abs(QtyToHandleThisLine) > Abs(TotalQtyToHandle) then
                            QtyToHandleThisLine := TotalQtyToHandle;
                        if Abs(QtyToInvoiceThisLine) > Abs(TotalQtyToInvoice) then
                            QtyToInvoiceThisLine := TotalQtyToInvoice;
                        // PR3.60 Begin
                        if TotalQtyToHandle <> 0 then
                            AltQtyToHandleThisLine := Round(TotalAltQtyToHandle * QtyToHandleThisLine / TotalQtyToHandle, 0.00001)
                        else                                             // PR3.61
                            AltQtyToHandleThisLine := TotalAltQtyToHandle; // PR3.61
                        if QtyToHandleThisLine <> 0 then
                            AltQtyToInvoiceThisLine := Round(AltQtyToHandleThisLine * QtyToInvoiceThisLine / QtyToHandleThisLine, 0.00001)
                        else                                                 // PR3.61
                            AltQtyToInvoiceThisLine := AltQtyToHandleThisLine; // PR3.61
                                                                               // PR3.60 End

                        if (ReservEntry1."Qty. to Handle (Base)" <> QtyToHandleThisLine) or
                           (ReservEntry1."Qty. to Handle (Alt.)" <> AltQtyToHandleThisLine) or   // PR3.60
                           (ReservEntry1."Qty. to Invoice (Alt.)" <> AltQtyToInvoiceThisLine) or // PR3.60
                           (ReservEntry1."Qty. to Invoice (Base)" <> QtyToInvoiceThisLine) and not ReservEntry1.Correction
                        then begin
                            ReservEntry1."Qty. to Handle (Base)" := QtyToHandleThisLine;
                            ReservEntry1."Qty. to Invoice (Base)" := QtyToInvoiceThisLine;
                            ReservEntry1."Qty. to Handle (Alt.)" := AltQtyToHandleThisLine;   // PR3.60
                            ReservEntry1."Qty. to Invoice (Alt.)" := AltQtyToInvoiceThisLine; // PR3.60
                            OnSetQtyToHandleAndInvoiceOnBeforeReservEntryModify(ReservEntry1, TrackingSpecification);
                            ModifyLine := true;
                        end;
                        OnAfterSetQtyToHandleAndInvoiceOnBeforeReservEntryModify(ReservEntry1, TrackingSpecification, TotalTrackingSpecification, ModifyLine);
                        if ModifyLine then
                            ReservEntry1.Modify();
                        TotalQtyToHandle -= QtyToHandleThisLine;
                        TotalQtyToInvoice -= QtyToInvoiceThisLine;
                        TotalAltQtyToHandle -= AltQtyToHandleThisLine; // PR3.60
                    until (ReservEntry1.Next() = 0);
            end
        end else
            if ReservEntry1.Find('-') then
                if (ReservEntry1."Qty. to Handle (Base)" <> TotalQtyToHandle) or
                   (ReservEntry1."Qty. to Handle (Alt.)" <> TotalAltQtyToHandle) or   // PR4.00
                   (ReservEntry1."Qty. to Invoice (Base)" <> TotalQtyToInvoice) and not ReservEntry1.Correction
                then begin
                    ReservEntry1."Qty. to Handle (Base)" := TotalQtyToHandle;
                    ReservEntry1."Qty. to Invoice (Base)" := TotalQtyToInvoice;
                    // PR4.00 Begin
                    if TotalQtyToHandle <> 0 then
                        ReservEntry1."Qty. to Invoice (Alt.)" :=
                          Round(TotalAltQtyToHandle * TotalQtyToInvoice / TotalQtyToInvoice, 0.00001)
                    else
                        ReservEntry1."Qty. to Invoice (Alt.)" := TotalQtyToHandle;
                    // PR4.00 End
                    OnSetQtyToHandleAndInvoiceOnBeforeReservEntryModify(ReservEntry1, TrackingSpecification);
                    ReservEntry1.Modify();
                end;
    end;

    local procedure CollectPostedTransferEntries(TrackingSpecification: Record "Tracking Specification"; var TempTrackingSpecification: Record "Tracking Specification" temporary)
    var
        ItemEntryRelation: Record "Item Entry Relation";
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        // Used for collecting information about posted Transfer Shipments from the created Item Ledger Entries.
        if TrackingSpecification."Source Type" <> DATABASE::"Transfer Line" then
            exit;

        ItemEntryRelation.SetCurrentKey("Order No.", "Order Line No.");
        ItemEntryRelation.SetRange("Order No.", TrackingSpecification."Source ID");
        ItemEntryRelation.SetRange("Order Line No.", TrackingSpecification."Source Ref. No.");

        case TrackingSpecification."Source Subtype" of
            0: // Outbound
                ItemEntryRelation.SetRange("Source Type", DATABASE::"Transfer Shipment Line");
            1: // Inbound
                ItemEntryRelation.SetRange("Source Type", DATABASE::"Transfer Receipt Line");
        end;

        if ItemEntryRelation.Find('-') then
            repeat
                ItemLedgerEntry.Get(ItemEntryRelation."Item Entry No.");
                TempTrackingSpecification := TrackingSpecification;
                TempTrackingSpecification."Entry No." := ItemLedgerEntry."Entry No.";
                TempTrackingSpecification."Item No." := ItemLedgerEntry."Item No.";
                TempTrackingSpecification.CopyTrackingFromItemLedgEntry(ItemLedgerEntry);
                TempTrackingSpecification."Quantity (Base)" := ItemLedgerEntry.Quantity;
                TempTrackingSpecification."Quantity Handled (Base)" := ItemLedgerEntry.Quantity;
                TempTrackingSpecification."Quantity Invoiced (Base)" := ItemLedgerEntry.Quantity;
                TempTrackingSpecification."Quantity (Alt.)" := ItemLedgerEntry."Quantity (Alt.)";          // PR3.61
                TempTrackingSpecification."Quantity Handled (Alt.)" := ItemLedgerEntry."Quantity (Alt.)";  // PR3.61
                TempTrackingSpecification."Quantity Invoiced (Alt.)" := ItemLedgerEntry."Quantity (Alt.)"; // PR3.61
                TempTrackingSpecification."Qty. per Unit of Measure" := ItemLedgerEntry."Qty. per Unit of Measure";
                TempTrackingSpecification.InitQtyToShip();
                OnBeforeCollectTempTrackingSpecificationInsert(TempTrackingSpecification, ItemLedgerEntry, TrackingSpecification);
                TempTrackingSpecification.Insert();
            until ItemEntryRelation.Next() = 0;
    end;

    local procedure CollectPostedAssemblyEntries(TrackingSpecification: Record "Tracking Specification"; var TempTrackingSpecification: Record "Tracking Specification" temporary)
    var
        ItemEntryRelation: Record "Item Entry Relation";
        ItemLedgerEntry: Record "Item Ledger Entry";
        CurrentQtyBase: Decimal;
        MaxQtyBase: Decimal;
    begin
        // Used for collecting information about posted Assembly Lines from the created Item Ledger Entries.
        if (TrackingSpecification."Source Type" <> DATABASE::"Assembly Line") and
           (TrackingSpecification."Source Type" <> DATABASE::"Assembly Header")
        then
            exit;

        TempTrackingSpecification.CalcSums("Quantity (Base)");
        CurrentQtyBase := TempTrackingSpecification."Quantity (Base)";
        MaxQtyBase := CurrentSignFactor * SourceQuantityArray[1];

        ItemEntryRelation.SetCurrentKey("Order No.", "Order Line No.");
        ItemEntryRelation.SetRange("Order No.", TrackingSpecification."Source ID");
        ItemEntryRelation.SetRange("Order Line No.", TrackingSpecification."Source Ref. No.");
        if TrackingSpecification."Source Type" = DATABASE::"Assembly Line" then
            ItemEntryRelation.SetRange("Source Type", DATABASE::"Posted Assembly Line")
        else
            ItemEntryRelation.SetRange("Source Type", DATABASE::"Posted Assembly Header");

        if ItemEntryRelation.Find('-') then
            repeat
                ItemLedgerEntry.Get(ItemEntryRelation."Item Entry No.");
                TempTrackingSpecification := TrackingSpecification;
                TempTrackingSpecification."Entry No." := ItemLedgerEntry."Entry No.";
                TempTrackingSpecification."Item No." := ItemLedgerEntry."Item No.";
                TempTrackingSpecification.CopyTrackingFromItemLedgEntry(ItemLedgerEntry);
                TempTrackingSpecification."Quantity (Base)" := ItemLedgerEntry.Quantity;
                TempTrackingSpecification."Quantity Handled (Base)" := ItemLedgerEntry.Quantity;
                TempTrackingSpecification."Quantity Invoiced (Base)" := ItemLedgerEntry.Quantity;
                TempTrackingSpecification."Qty. per Unit of Measure" := ItemLedgerEntry."Qty. per Unit of Measure";
                TempTrackingSpecification.InitQtyToShip();

                if Abs(TempTrackingSpecification."Quantity (Base)") > Abs(MaxQtyBase - CurrentQtyBase) then
                    TempTrackingSpecification."Quantity (Base)" := MaxQtyBase - CurrentQtyBase;
                CurrentQtyBase += TempTrackingSpecification."Quantity (Base)";

                OnBeforeCollectTempTrackingSpecificationInsert(TempTrackingSpecification, ItemLedgerEntry, TrackingSpecification);
                TempTrackingSpecification.Insert();
            until ItemEntryRelation.Next() = 0;
    end;

    local procedure CollectPostedOutputEntries(TrackingSpecification: Record "Tracking Specification"; var TempTrackingSpecification: Record "Tracking Specification" temporary)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        // Used for collecting information about posted prod. order output from the created Item Ledger Entries.
        if TrackingSpecification."Source Type" <> DATABASE::"Prod. Order Line" then
            exit;

        ItemLedgerEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type");
        ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Production);
        ItemLedgerEntry.SetRange("Order No.", TrackingSpecification."Source ID");
        ItemLedgerEntry.SetRange("Order Line No.", TrackingSpecification."Source Prod. Order Line");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Output);

        if ItemLedgerEntry.Find('-') then begin
            repeat
                TempTrackingSpecification := TrackingSpecification;
                TempTrackingSpecification."Entry No." := ItemLedgerEntry."Entry No.";
                TempTrackingSpecification."Item No." := ItemLedgerEntry."Item No.";
                TempTrackingSpecification.CopyTrackingFromItemLedgEntry(ItemLedgerEntry);
                TempTrackingSpecification."Quantity (Base)" := ItemLedgerEntry.Quantity;
                TempTrackingSpecification."Quantity Handled (Base)" := ItemLedgerEntry.Quantity;
                TempTrackingSpecification."Quantity Invoiced (Base)" := ItemLedgerEntry.Quantity;
                TempTrackingSpecification."Quantity (Alt.)" := ItemLedgerEntry."Quantity (Alt.)";          // PR3.70
                TempTrackingSpecification."Quantity Handled (Alt.)" := ItemLedgerEntry."Quantity (Alt.)";  // PR3.70
                TempTrackingSpecification."Quantity Invoiced (Alt.)" := ItemLedgerEntry."Quantity (Alt.)"; // PR3.70
                TempTrackingSpecification."Qty. per Unit of Measure" := ItemLedgerEntry."Qty. per Unit of Measure";
                TempTrackingSpecification.InitQtyToShip();
                OnBeforeCollectTempTrackingSpecificationInsert(TempTrackingSpecification, ItemLedgerEntry, TrackingSpecification);
                TempTrackingSpecification.Insert();
            until ItemLedgerEntry.Next() = 0;

            ItemLedgerEntry.CalcSums(Quantity);
            if ItemLedgerEntry.Quantity > SourceQuantityArray[1] then
                SourceQuantityArray[1] := ItemLedgerEntry.Quantity;
        end;

        OnAfterCollectPostedOutputEntries(ItemLedgerEntry, TempTrackingSpecification);
    end;

    procedure ZeroLineExists() OK: Boolean
    var
        xTrackingSpec: Record "Tracking Specification";
    begin
        if (Rec."Quantity (Base)" <> 0) or Rec.TrackingExists then
            exit(false);
        xTrackingSpec.Copy(Rec);
        Rec.Reset();
        Rec.SetRange("Quantity (Base)", 0);
        Rec.SetTrackingFilterBlank;
        OK := not Rec.IsEmpty();
        Rec.Copy(xTrackingSpec);
    end;

    protected procedure AssignSerialNo()
    var
        EnterQuantityToCreate: Page "Enter Quantity to Create";
        QtyToCreate: Decimal;
        QtyToCreateInt: Integer;
        CreateLotNo: Boolean;
        CreateSNInfo: Boolean;
    begin
        if ZeroLineExists then
            Rec.Delete();

        QtyToCreate := UndefinedQtyArray[1] * QtySignFactor;
        if QtyToCreate < 0 then
            QtyToCreate := 0;

        if QtyToCreate mod 1 <> 0 then
            Error(Text008);

        QtyToCreateInt := QtyToCreate;
        OnAssignSerialNoOnAfterAssignQtyToCreateInt(Rec, QtyToCreateInt);

        Clear(EnterQuantityToCreate);
        EnterQuantityToCreate.SetFields(Rec."Item No.", Rec."Variant Code", QtyToCreate, false, false);
        if EnterQuantityToCreate.RunModal = ACTION::OK then begin
            EnterQuantityToCreate.GetFields(QtyToCreateInt, CreateLotNo, CreateSNInfo);
            AssignSerialNoBatch(QtyToCreateInt, CreateLotNo, CreateSNInfo);
        end;
    end;

    protected procedure AssignSerialNoBatch(QtyToCreate: Integer; CreateLotNo: Boolean; CreateSNInfo: Boolean)
    var
        i: Integer;
    begin
        if QtyToCreate <= 0 then
            Error(Text009);
        if QtyToCreate mod 1 <> 0 then
            Error(Text008);

        GetItem(Rec."Item No.");

        if CreateLotNo then begin
            Rec.TestField("Lot No.", '');
            AssignNewLotNo();
            OnAfterAssignNewTrackingNo(Rec, xRec, Rec.FieldNo("Lot No."));
        end;

        Item.TestField("Serial Nos.");
        ItemTrackingDataCollection.SetSkipLot(true);
        for i := 1 to QtyToCreate do begin
            Rec.Validate("Quantity Handled (Base)", 0);
            Rec.Validate("Quantity Invoiced (Base)", 0);
            AssignNewSerialNo();
            OnAfterAssignNewTrackingNo(Rec, xRec, Rec.FieldNo("Serial No."));
            Rec.Validate("Quantity (Base)", QtySignFactor());
            Rec."Entry No." := NextEntryNo;
            if TestTempSpecificationExists then
                Error('');
            Rec.Insert();

            OnAssignSerialNoBatchOnAfterInsert(Rec, QtyToCreate);

            TempItemTrackLineInsert.TransferFields(Rec);
            TempItemTrackLineInsert.Insert();
            if i = QtyToCreate then
                ItemTrackingDataCollection.SetSkipLot(false);
            ItemTrackingDataCollection.UpdateTrackingDataSetWithChange(
              TempItemTrackLineInsert, CurrentSignFactor * SourceQuantityArray[1] < 0, CurrentSignFactor, 0);

            if CreateSNInfo then
                ItemTrackingMgt.CreateSerialNoInformation(Rec);

        end;
        CalculateSums();
    end;

    protected procedure AssignLotNo()
    var
        QtyToCreate: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeAssignLotNo(Rec, TempItemTrackLineInsert, SourceQuantityArray, IsHandled);
        if IsHandled then begin
            CalculateSums();
            exit;
        end;

        if ZeroLineExists then
            Rec.Delete();

        if (SourceQuantityArray[1] * UndefinedQtyArray[1] <= 0) or
           (Abs(SourceQuantityArray[1]) < Abs(UndefinedQtyArray[1]))
        then
            QtyToCreate := 0
        else
            QtyToCreate := UndefinedQtyArray[1];

        GetItem(Rec."Item No.");

        Rec.Validate("Quantity Handled (Base)", 0);
        Rec.Validate("Quantity Invoiced (Base)", 0);
        AssignNewLotNo();
        OnAfterAssignNewTrackingNo(Rec, xRec, Rec.FieldNo("Lot No."));
        Rec."Qty. per Unit of Measure" := QtyPerUOM;
        Rec."Qty. Rounding Precision (Base)" := QtyRoundingPerBase;
        Rec.Validate("Quantity (Base)", QtyToCreate);
        Rec."Entry No." := NextEntryNo;
        TestTempSpecificationExists();
        Rec.Insert();

        OnAssignLotNoOnAfterInsert(Rec);

        TempItemTrackLineInsert.TransferFields(Rec);
        TempItemTrackLineInsert.Insert();
        ItemTrackingDataCollection.UpdateTrackingDataSetWithChange(
          TempItemTrackLineInsert, CurrentSignFactor * SourceQuantityArray[1] < 0, CurrentSignFactor, 0);

        CalculateSums();
    end;

    local procedure AssignNewSerialNo()
    var
        IsHandled: Boolean;
    begin
        OnBeforeAssignNewSerialNo(Rec, IsHandled, SourceTrackingSpecification);
        if IsHandled then
            exit;

        Item.TestField("Serial Nos.");
        Rec.Validate("Serial No.", NoSeriesMgt.GetNextNo(Item."Serial Nos.", WorkDate(), true));
    end;

    local procedure AssignNewCustomizedSerialNo(CustomizedSN: Code[50])
    var
        IsHandled: Boolean;
    begin
        OnBeforeAssignNewCustomizedSerialNo(Rec, CustomizedSN, IsHandled);
        if IsHandled then
            exit;

        Rec.Validate("Serial No.", CustomizedSN);
    end;

    protected procedure AssignPackageNo()
    var
        QtyToCreate: Decimal;
    begin
        if ZeroLineExists() then
            Rec.Delete();

        if (SourceQuantityArray[1] * UndefinedQtyArray[1] <= 0) or
           (Abs(SourceQuantityArray[1]) < Abs(UndefinedQtyArray[1]))
        then
            QtyToCreate := 0
        else
            QtyToCreate := UndefinedQtyArray[1];

        GetItem(Rec."Item No.");

        Rec.Validate("Quantity Handled (Base)", 0);
        Rec.Validate("Quantity Invoiced (Base)", 0);
        AssignNewPackageNo();
        OnAfterAssignNewTrackingNo(Rec, xRec, FieldNo("Package No."));
        Rec."Qty. per Unit of Measure" := QtyPerUOM;
        Validate("Quantity (Base)", QtyToCreate);
        Rec."Entry No." := NextEntryNo();
        TestTempSpecificationExists();
        Rec.Insert();

        OnAssignPackageNoOnAfterInsert(Rec);

        TempItemTrackLineInsert.TransferFields(Rec);
        TempItemTrackLineInsert.Insert();
        ItemTrackingDataCollection.UpdateTrackingDataSetWithChange(
          TempItemTrackLineInsert, CurrentSignFactor * SourceQuantityArray[1] < 0, CurrentSignFactor, 0);
        CalculateSums();
    end;

    local procedure AssignNewPackageNo()
    var
        InventorySetup: Record "Inventory Setup";
        IsHandled: Boolean;
    begin
        OnBeforeAssignNewPackageNo(Rec, IsHandled);
        if IsHandled then
            exit;

        InventorySetup.Get();
        InventorySetup.TestField("Package Nos.");
        Rec.Validate("Package No.", NoSeriesMgt.GetNextNo(InventorySetup."Package Nos.", WorkDate(), true));
    end;

    local procedure AssignNewLotNo()
    var
        IsHandled: Boolean;
    begin
        OnBeforeAssignNewLotNo(Rec, IsHandled, SourceTrackingSpecification);
        if IsHandled then
            exit;

        // P8000250B
        if ProcessFns.TrackingInstalled then
            Validate("Lot No.", P800ItemTracking.AssignLotNo(Rec)) // P8001234
        else begin
            // P8000250B
            Item.TestField("Lot Nos.");
            Rec.Validate("Lot No.", NoSeriesMgt.GetNextNo(Item."Lot Nos.", WorkDate, true));
        end; // P8000250B
    end;

    local procedure CreateCustomizedSNByPage()
    var
        EnterCustomizedSN: Page "Enter Customized SN";
        QtyToCreate: Decimal;
        QtyToCreateInt: Integer;
        Increment: Integer;
        CreateLotNo: Boolean;
        CustomizedSN: Code[50];
        CreateSNInfo: Boolean;
    begin
        if ZeroLineExists() then
            Rec.Delete();

        QtyToCreate := UndefinedQtyArray[1] * QtySignFactor;
        if QtyToCreate < 0 then
            QtyToCreate := 0;

        if QtyToCreate mod 1 <> 0 then
            Error(Text008);

        QtyToCreateInt := QtyToCreate;
        OnCreateCustomizedSNByPageOnAfterCalcQtyToCreate(Rec, QtyToCreate);

        Clear(EnterCustomizedSN);
        EnterCustomizedSN.SetFields(Rec."Item No.", Rec."Variant Code", QtyToCreate, false, false);
        if EnterCustomizedSN.RunModal = ACTION::OK then begin
            EnterCustomizedSN.GetFields(QtyToCreateInt, CreateLotNo, CustomizedSN, Increment, CreateSNInfo);
            CreateCustomizedSNBatch(QtyToCreateInt, CreateLotNo, CustomizedSN, Increment, CreateSNInfo);
        end;
        CalculateSums();
    end;

    local procedure CreateCustomizedSNBatch(QtyToCreate: Decimal; CreateLotNo: Boolean; CustomizedSN: Code[50]; Increment: Integer; CreateSNInfo: Boolean)
    var
        i: Integer;
        Counter: Integer;
    begin
        if IncStr(CustomizedSN) = '' then
            Error(StrSubstNo(UnincrementableStringErr, CustomizedSN));
        NoSeriesMgt.TestManual(Item."Serial Nos.");

        if QtyToCreate <= 0 then
            Error(Text009);
        if QtyToCreate mod 1 <> 0 then
            Error(Text008);

        if CreateLotNo then begin
            Rec.TestField("Lot No.", '');
            AssignNewLotNo();
            OnAfterAssignNewTrackingNo(Rec, xRec, Rec.FieldNo("Lot No."));
        end;

        for i := 1 to QtyToCreate do begin
            Rec.Validate("Quantity Handled (Base)", 0);
            Rec.Validate("Quantity Invoiced (Base)", 0);
            AssignNewCustomizedSerialNo(CustomizedSN);
            OnAfterAssignNewTrackingNo(Rec, xRec, Rec.FieldNo("Serial No."));
            Rec.Validate("Quantity (Base)", QtySignFactor());
            Rec."Entry No." := NextEntryNo();
            if TestTempSpecificationExists() then
                Error('');
            Rec.Insert();
            OnCreateCustomizedSNBatchOnAfterRecInsert(Rec, QtyToCreate);
            TempItemTrackLineInsert.TransferFields(Rec);
            TempItemTrackLineInsert.Insert();
            ItemTrackingDataCollection.UpdateTrackingDataSetWithChange(
              TempItemTrackLineInsert, CurrentSignFactor * SourceQuantityArray[1] < 0, CurrentSignFactor, 0);

            if CreateSNInfo then
                ItemTrackingMgt.CreateSerialNoInformation(Rec);

            if i < QtyToCreate then begin
                Counter := Increment;
                repeat
                    CustomizedSN := IncStr(CustomizedSN);
                    Counter := Counter - 1;
                until Counter <= 0;
            end;
        end;
        CalculateSums();
    end;

    procedure TestTempSpecificationExists() Exists: Boolean
    var
        TrackingSpecification: Record "Tracking Specification";
    begin
        if not Rec.TrackingExists() then
            exit(false);

        TrackingSpecification.Copy(Rec);
        Rec.SetTrackingKey();
        Rec.SetRange("Serial No.", Rec."Serial No.");
        if Rec."Serial No." = '' then
            Rec.SetNonSerialTrackingFilterFromSpec(Rec);
        Rec.SetFilter("Entry No.", '<>%1', Rec."Entry No.");
        Rec.SetRange("Buffer Status", 0);

        OnTestTempSpecificationExistsOnAfterSetFilters(Rec);
        Exists := not Rec.IsEmpty();
        Rec.Copy(TrackingSpecification);
        if Exists and CurrentPageIsOpen then
            if Rec."Serial No." = '' then
                Message(Text011, Rec."Serial No.", Rec."Lot No.", Rec."Package No.")
            else
                Message(Text012, Rec."Serial No.");
    end;

    protected procedure QtySignFactor(): Integer
    begin
        if SourceQuantityArray[1] < 0 then
            exit(-1);

        exit(1)
    end;

    procedure RegisterItemTrackingLines(SourceTrackingSpecification: Record "Tracking Specification"; AvailabilityDate: Date; var TempTrackingSpecification: Record "Tracking Specification" temporary)
    var
        QtyToHandle: Decimal;
    begin
        SourceTrackingSpecification.TestField("Source Type"); // Check if source has been set.
        if not CalledFromSynchWhseItemTrkg then
            TempTrackingSpecification.Reset();
        if not TempTrackingSpecification.Find('-') then
            exit;

        IsCorrection := SourceTrackingSpecification.Correction;
        ExcludePostedEntries := true;
        SetSourceSpec(SourceTrackingSpecification, AvailabilityDate);
        Rec.Reset();
        Rec.SetTrackingKey();

        repeat
            SetTrackingFilterFromSpec(TempTrackingSpecification);
            if Find('-') then begin
                OnRegisterItemTrackingLinesOnAfterFind(Rec, TempTrackingSpecification, IsCorrection);
                if IsCorrection then begin
                    Rec."Quantity (Base)" += TempTrackingSpecification."Quantity (Base)";
                    Rec."Qty. to Handle (Base)" += TempTrackingSpecification."Qty. to Handle (Base)";
                    Rec."Qty. to Invoice (Base)" += TempTrackingSpecification."Qty. to Invoice (Base)";
                    // PR3.60 Begin
                    Rec."Quantity (Alt.)" += TempTrackingSpecification."Qty. to Handle (Alt.)";
                    Rec."Qty. to Handle (Alt.)" += TempTrackingSpecification."Qty. to Handle (Alt.)";
                    Rec."Qty. to Invoice (Alt.)" += TempTrackingSpecification."Qty. to Invoice (Alt.)";
                    // PR3.60 End
                end else begin // PR3.60
                    QtyToHandle := "Qty. to Handle (Base)"; // P80046533
                    Rec.Validate("Quantity (Base)", "Quantity (Base)" + TempTrackingSpecification."Quantity (Base)");
                    Rec.Validate("Qty. to Handle (Base)", QtyToHandle + TempTrackingSpecification."Qty. to Handle (Base)"); // P80046533
                                                                                                                            // PR3.60 Begin
                    if TrackAlternateUnits and CatchAlternateQtys then begin // P8000354A
                        Rec."Quantity (Alt.)" += TempTrackingSpecification."Qty. to Handle (Alt.)";
                        Rec."Qty. to Handle (Alt.)" += TempTrackingSpecification."Qty. to Handle (Alt.)";
                    end;                                                                                       // P8000354A
                                                                                                               // PR3.60 End
                end;           // PR3.60
                Rec.Modify();
            end else begin
                Rec.TransferFields(SourceTrackingSpecification);
                Rec.CopyTrackingFromTrackingSpec(TempTrackingSpecification);
                Rec."Warranty Date" := TempTrackingSpecification."Warranty Date";
                Rec."Expiration Date" := TempTrackingSpecification."Expiration Date";
                if CurrentRunMode = CurrentRunMode::Reclass then begin
                    Rec.CopyNewTrackingFromNewTrackingSpec(TempTrackingSpecification);
                    Rec."New Lot Status Code" := TempTrackingSpecification."New Lot Status Code"; // P8001083
                    Rec."New Expiration Date" := TempTrackingSpecification."New Expiration Date";
                    OnRegisterItemTrackingLinesOnAfterReclass(Rec, TempTrackingSpecification);
                end;
                OnAfterCopyTrackingSpec(TempTrackingSpecification, Rec);
                Rec.Validate("Quantity (Base)", TempTrackingSpecification."Quantity (Base)");
                Rec.Validate("Quantity (Base)", TempTrackingSpecification."Quantity (Base)");
                Rec.Validate("Qty. to Handle (Base)", TempTrackingSpecification."Qty. to Handle (Base)"); // P80046533
                                                                                                          // PR3.60 Begin
                if TempTrackingSpecification."Qty. to Handle (Alt.)" <> 0 then begin
                    Rec."Quantity (Alt.)" := TempTrackingSpecification."Qty. to Handle (Alt.)";
                    Rec."Qty. to Handle (Alt.)" := TempTrackingSpecification."Qty. to Handle (Alt.)";
                end;
                // PR3.60 End
                Rec."Entry No." := NextEntryNo;
                Rec.Insert();
            end;
        until TempTrackingSpecification.Next() = 0;
        OnAfterRegisterItemTrackingLines(SourceTrackingSpecification, TempTrackingSpecification, Rec, AvailabilityDate);

        Rec.Reset();
        if Rec.Find('-') then
            repeat
                CheckItemTrackingLine(Rec);
            until Rec.Next() = 0;

        Rec.SetTrackingFilterFromSpec(SourceTrackingSpecification);

        CalculateSums();
        if UpdateUndefinedQty then
            WriteToDatabase
        else
            Error(Text014, TotalTrackingSpecification."Quantity (Base)",
              LowerCase(TempReservEntry.TextCaption), SourceQuantityArray[1]);

        // Copy to inbound part of transfer
        if (CurrentRunMode = CurrentRunMode::Transfer) or IsOrderToOrderBindingToTransfer then
            SynchronizeLinkedSources('');
    end;

    procedure SynchronizeLinkedSources(DialogText: Text[250]): Boolean
    begin
        OnBeforeSynchronizeLinkedSources(CurrentRunMode.AsInteger(), CurrentSourceType, CurrentSourceRowID, SecondSourceRowID, DialogText);
        if CurrentSourceRowID = '' then
            exit(false);
        if SecondSourceRowID = '' then
            exit(false);

        ItemTrackingMgt.SynchronizeItemTracking(CurrentSourceRowID, SecondSourceRowID, DialogText);

        OnAfterSynchronizeLinkedSources(CurrentRunMode.AsInteger(), CurrentSourceType, CurrentSourceRowID, SecondSourceRowID);
        exit(true);
    end;

    procedure SetBlockCommit(NewBlockCommit: Boolean)
    begin
        BlockCommit := NewBlockCommit;
    end;

    procedure SetCalledFromSynchWhseItemTrkg(CalledFromSynchWhseItemTrkg2: Boolean)
    begin
        CalledFromSynchWhseItemTrkg := CalledFromSynchWhseItemTrkg2;
        BlockCommit := true;
    end;

    local procedure UpdateExpDateColor()
    begin
        if (Rec."Buffer Status2" = Rec."Buffer Status2"::"ExpDate blocked") or (CurrentSignFactor < 0) then;
    end;

    local procedure UpdateExpDateEditable()
    begin
        ExpirationDateEditable := ItemTrackingCode."Use Expiration Dates" and
          not ((Rec."Buffer Status2" = Rec."Buffer Status2"::"ExpDate blocked") or (CurrentSignFactor < 0));

        OnAfterUpdateExpDateEditable(Rec, ExpirationDateEditable, ItemTrackingCode, NewExpirationDateEditable, CurrentSignFactor);
    end;

    local procedure LookupAvailable(LookupMode: Enum "Item Tracking Type")
    begin
        Rec."Bin Code" := ForBinCode;
        ItemTrackingDataCollection.LookupTrackingAvailability(Rec, LookupMode);
        Rec."Bin Code" := '';
        CurrPage.Update();
    end;

    local procedure TrackingAvailable(var TrackingSpecification: Record "Tracking Specification"; LookupMode: Enum "Item Tracking Type"): Boolean
    begin
        exit(ItemTrackingDataCollection.TrackingAvailable(TrackingSpecification, LookupMode));
    end;

    local procedure SelectEntries()
    var
        xTrackingSpec: Record "Tracking Specification";
        MaxQuantity: Decimal;
    begin
        xTrackingSpec.CopyFilters(Rec);
        MaxQuantity := UndefinedQtyArray[1];
        if MaxQuantity * CurrentSignFactor > 0 then
            MaxQuantity := 0;
        Rec."Bin Code" := ForBinCode;
        OnSelectEntriesOnBeforeSelectMultipleTrackingNo(ItemTrackingDataCollection, CurrentSignFactor);
        ItemTrackingDataCollection.SelectMultipleTrackingNo(Rec, MaxQuantity, CurrentSignFactor);
        Rec."Bin Code" := '';
        if Rec.FindSet() then
            repeat
                case Rec."Buffer Status" of
                    Rec."Buffer Status"::MODIFY:
                        begin
                            if TempItemTrackLineModify.Get(Rec."Entry No.") then
                                TempItemTrackLineModify.Delete();
                            if TempItemTrackLineInsert.Get(Rec."Entry No.") then begin
                                TempItemTrackLineInsert.TransferFields(Rec);
                                OnSelectEntriesOnAfterTransferFields(TempItemTrackLineInsert, Rec);
                                TempItemTrackLineInsert.Modify();
                            end else begin
                                TempItemTrackLineModify.TransferFields(Rec);
                                OnSelectEntriesOnAfterTransferFields(TempItemTrackLineModify, Rec);
                                TempItemTrackLineModify.Insert();
                            end;
                        end;
                    Rec."Buffer Status"::INSERT:
                        begin
                            TempItemTrackLineInsert.TransferFields(Rec);
                            OnSelectEntriesOnAfterTransferFields(TempItemTrackLineInsert, Rec);
                            TempItemTrackLineInsert.Insert();
                        end;
                end;
                Rec."Buffer Status" := 0;
                Rec.Modify;
            until Rec.Next() = 0;
        LastEntryNo := Rec."Entry No.";
        CalculateSums();
        UpdateUndefinedQtyArray;
        Rec.CopyFilters(xTrackingSpec);
        CurrPage.Update(false);
    end;

    procedure SetInbound(NewInbound: Boolean)
    begin
        InboundIsSet := true;
        Inbound := NewInbound;
    end;

    procedure SetDirectTransfer(IsDirectTransfer2: Boolean)
    begin
        IsDirectTransfer := IsDirectTransfer2;
        CurrentRunMode := CurrentRunMode::Reclass;
    end;

    protected procedure SerialNoOnAfterValidate()
    begin
        OnBeforeSerialNoOnAfterValidate(Rec);

        UpdateExpDateEditable();
        CurrPage.Update();
    end;

    protected procedure LotNoOnAfterValidate()
    begin
        UpdateExpDateEditable();
        CurrPage.Update();
    end;

    protected procedure QuantityBaseOnAfterValidate()
    begin
        CurrPage.Update();
    end;

    protected procedure QuantityBaseOnValidate()
    begin
        CheckItemTrackingLine(Rec);
    end;

    protected procedure QtytoHandleBaseOnAfterValidate()
    begin
        CurrPage.Update();
    end;

    protected procedure QtytoInvoiceBaseOnAfterValidat()
    begin
        CurrPage.Update();
    end;

    local procedure ExpirationDateOnFormat()
    begin
        UpdateExpDateColor;
    end;

    local procedure TempRecValid()
    begin
        if not TempRecIsValid then
            Error(Text007);
    end;

    procedure GetEditableSettings(var ItemNoEditable2: Boolean; var VariantCodeEditable2: Boolean; var LocationCodeEditable2: Boolean; var QtyToHandleBaseEditable2: Boolean; var QtyToInvoiceBaseEditable2: Boolean; var QuantityBaseEditable2: Boolean; var SerialNoEditable2: Boolean; var LotNoEditable2: Boolean; var DescriptionEditable2: Boolean; var NewSerialNoEditable2: Boolean; var NewLotNoEditable2: Boolean; var NewExpirationDateEditable2: Boolean; var ExpirationDateEditable2: Boolean; var WarrantyDateEditable2: Boolean)
    begin
        ItemNoEditable2 := ItemNoEditable;
        VariantCodeEditable2 := VariantCodeEditable;
        LocationCodeEditable2 := LocationCodeEditable;
        QtyToHandleBaseEditable2 := QtyToHandleBaseEditable;
        QtyToInvoiceBaseEditable2 := QtyToInvoiceBaseEditable;
        QuantityBaseEditable2 := QuantityBaseEditable;
        SerialNoEditable2 := SerialNoEditable;
        LotNoEditable2 := LotNoEditable;
        DescriptionEditable2 := DescriptionEditable;
        NewSerialNoEditable2 := NewSerialNoEditable;
        NewLotNoEditable2 := NewLotNoEditable;
        NewExpirationDateEditable2 := NewExpirationDateEditable;
        ExpirationDateEditable2 := ExpirationDateEditable;
        WarrantyDateEditable2 := WarrantyDateEditable;
    end;

    procedure GetVisibleSettings(var Handle1Visible2: Boolean; var Handle2Visible2: Boolean; var Handle3Visible2: Boolean; var QtyToHandleBaseVisible2: Boolean; var Invoice1Visible2: Boolean; var Invoice2Visible2: Boolean; var Invoice3Visible2: Boolean; var QtyToInvoiceBaseVisible2: Boolean; var NewSerialNoVisible2: Boolean; var NewLotNoVisible2: Boolean; var NewExpirationDateVisible2: Boolean; var ButtonLineReclassVisible2: Boolean; var ButtonLineVisible2: Boolean; var FunctionsSupplyVisible2: Boolean; var FunctionsDemandVisible2: Boolean; var Inbound2: Boolean; var InboundIsSet2: Boolean)
    begin
        Handle1Visible2 := Handle1Visible;
        Handle2Visible2 := Handle2Visible;
        Handle3Visible2 := Handle3Visible;
        QtyToHandleBaseVisible2 := QtyToHandleBaseVisible;
        Invoice1Visible2 := Invoice1Visible;
        Invoice2Visible2 := Invoice2Visible;
        Invoice3Visible2 := Invoice3Visible;
        QtyToInvoiceBaseVisible2 := QtyToInvoiceBaseVisible;
        NewSerialNoVisible2 := NewSerialNoVisible;
        NewLotNoVisible2 := NewLotNoVisible;
        NewExpirationDateVisible2 := NewExpirationDateVisible;
        ButtonLineReclassVisible2 := ButtonLineReclassVisible;
        ButtonLineVisible2 := ButtonLineVisible;
        FunctionsSupplyVisible2 := FunctionsSupplyVisible;
        FunctionsDemandVisible2 := FunctionsDemandVisible;
        Inbound2 := Inbound;
        InboundIsSet2 := InboundIsSet;
    end;

    procedure GetVariables(var TempTrackingSpecInsert2: Record "Tracking Specification" temporary; var TempTrackingSpecModify2: Record "Tracking Specification" temporary; var TempTrackingSpecDelete2: Record "Tracking Specification" temporary; var Item2: Record Item; var UndefinedQtyArray2: array[3] of Decimal; var SourceQuantityArray2: array[5] of Decimal; var CurrentSignFactor2: Integer; var InsertIsBlocked2: Boolean; var DeleteIsBlocked2: Boolean; var BlockCommit2: Boolean)
    begin
        TempTrackingSpecInsert2.DeleteAll();
        TempTrackingSpecInsert2.Reset();
        TempItemTrackLineInsert.Reset();
        if TempItemTrackLineInsert.Find('-') then
            repeat
                TempTrackingSpecInsert2.Init();
                TempTrackingSpecInsert2 := TempItemTrackLineInsert;
                TempTrackingSpecInsert2.Insert();
            until TempItemTrackLineInsert.Next() = 0;

        TempTrackingSpecModify2.DeleteAll();
        TempTrackingSpecModify2.Reset();
        TempItemTrackLineModify.Reset();
        if TempItemTrackLineModify.Find('-') then
            repeat
                TempTrackingSpecModify2.Init();
                TempTrackingSpecModify2 := TempItemTrackLineModify;
                TempTrackingSpecModify2.Insert();
            until TempItemTrackLineModify.Next() = 0;

        TempTrackingSpecDelete2.DeleteAll();
        TempTrackingSpecDelete2.Reset();
        TempItemTrackLineDelete.Reset();
        if TempItemTrackLineDelete.Find('-') then
            repeat
                TempTrackingSpecDelete2.Init();
                TempTrackingSpecDelete2 := TempItemTrackLineDelete;
                TempTrackingSpecDelete2.Insert();
            until TempItemTrackLineDelete.Next() = 0;

        Item2 := Item;
        CopyArray(UndefinedQtyArray2, UndefinedQtyArray, 1);
        CopyArray(SourceQuantityArray2, SourceQuantityArray, 1);
        CurrentSignFactor2 := CurrentSignFactor;
        InsertIsBlocked2 := InsertIsBlocked;
        DeleteIsBlocked2 := DeleteIsBlocked;
        BlockCommit2 := BlockCommit;
    end;

    procedure SetVariables(var TempTrackingSpecInsert2: Record "Tracking Specification" temporary; var TempTrackingSpecModify2: Record "Tracking Specification" temporary; var TempTrackingSpecDelete2: Record "Tracking Specification" temporary)
    begin
        TempItemTrackLineInsert.DeleteAll();
        TempItemTrackLineInsert.Reset();
        TempTrackingSpecInsert2.Reset();
        if TempTrackingSpecInsert2.Find('-') then
            repeat
                TempItemTrackLineInsert.Init();
                TempItemTrackLineInsert := TempTrackingSpecInsert2;
                TempItemTrackLineInsert.Insert();
            until TempTrackingSpecInsert2.Next() = 0;

        TempItemTrackLineModify.DeleteAll();
        TempItemTrackLineModify.Reset();
        TempTrackingSpecModify2.Reset();
        if TempTrackingSpecModify2.Find('-') then
            repeat
                TempItemTrackLineModify.Init();
                TempItemTrackLineModify := TempTrackingSpecModify2;
                TempItemTrackLineModify.Insert();
            until TempTrackingSpecModify2.Next() = 0;

        TempItemTrackLineDelete.DeleteAll();
        TempItemTrackLineDelete.Reset();
        TempTrackingSpecDelete2.Reset();
        if TempTrackingSpecDelete2.Find('-') then
            repeat
                TempItemTrackLineDelete.Init();
                TempItemTrackLineDelete := TempTrackingSpecDelete2;
                TempItemTrackLineDelete.Insert();
            until TempTrackingSpecDelete2.Next() = 0;
    end;

    local procedure GetHandleSource(TrackingSpecification: Record "Tracking Specification"): Boolean
    var
        WhseActivLine: Record "Warehouse Activity Line";
        QtyToHandleColumnIsHidden: Boolean;
    begin
        with TrackingSpecification do begin
            if ("Source Type" = DATABASE::"Item Journal Line") and ("Source Subtype" = 6) then begin // 6 => Prod.order line directly
                ProdOrderLineHandling := true;
                exit(true);  // Display Handle column for prod. orders
            end;

            // Prod. order line via inventory put-away
            if "Source Type" = DATABASE::"Prod. Order Line" then begin
                WhseActivLine.SetSourceFilter("Source Type", "Source Subtype", "Source ID", "Source Prod. Order Line", "Source Ref. No.", true);
                WhseActivLine.SetRange("Activity Type", WhseActivLine."Activity Type"::"Invt. Put-away");
                if not WhseActivLine.IsEmpty() then begin
                    ProdOrderLineHandling := true;
                    exit(true);
                end;
            end;

            QtyToHandleColumnIsHidden :=
              ("Source Type" in
               [DATABASE::"Item Ledger Entry",
                Database::"Invt. Document Line", // P800127049
                DATABASE::"Item Journal Line",
                DATABASE::"Job Journal Line",
                DATABASE::"Requisition Line"]) or
              (("Source Type" in [DATABASE::"Sales Line", DATABASE::"Purchase Line", DATABASE::"Service Line"]) and
               ("Source Subtype" in [0, 2, 3])) or
              (("Source Type" = DATABASE::"Assembly Line") and ("Source Subtype" = 0));
        end;
        OnAfterGetHandleSource(TrackingSpecification, QtyToHandleColumnIsHidden);
        exit(not QtyToHandleColumnIsHidden);
    end;

    local procedure GetInvoiceSource(TrackingSpecification: Record "Tracking Specification"): Boolean
    var
        QtyToInvoiceColumnIsHidden: Boolean;
    begin
        with TrackingSpecification do begin
            QtyToInvoiceColumnIsHidden :=
              ("Source Type" in
               [DATABASE::"Item Ledger Entry",
                Database::"Invt. Document Line", // P800127049
                DATABASE::"Item Journal Line",
                DATABASE::"Job Journal Line",
                DATABASE::"Requisition Line",
                DATABASE::"Transfer Line",
                DATABASE::"Assembly Line",
                DATABASE::"Assembly Header",
                DATABASE::"Prod. Order Line",
                DATABASE::"Prod. Order Component"]) or
              (("Source Type" in [DATABASE::"Sales Line", DATABASE::"Purchase Line", DATABASE::"Service Line"]) and
               ("Source Subtype" in [0, 2, 3, 4]))
        end;
        OnAfterGetInvoiceSource(TrackingSpecification, QtyToInvoiceColumnIsHidden);
        exit(not QtyToInvoiceColumnIsHidden);
    end;

    procedure RegisterP800Tracking(var NewTrackingSpec: Record "Tracking Specification" temporary; Mode: Code[10])
    begin
        // P8000043A
        Reset;
        if Mode <> 'UPDATE' then // P8001167
            if Find('-') then
                repeat
                    "Quantity (Alt.)" := 0;
                    "Qty. to Handle (Base)" := 0;
                    "Qty. to Handle (Alt.)" := 0;
                    case Mode of
                        'INCREMENT':
                            begin
                                "Quantity (Base)" := "Quantity Handled (Base)";
                                "Qty. to Invoice (Base)" := "Quantity Handled (Base)" - "Quantity Invoiced (Base)";
                            end;
                        'REPLACE':
                            begin
                                "Quantity (Base)" := 0;
                                "Qty. to Invoice (Base)" := 0;
                            end;
                    end;
                    "Qty. to Handle" := CalcQty("Qty. to Handle (Base)");
                    "Qty. to Invoice" := CalcQty("Qty. to Invoice (Base)");
                    "Qty. (Phys. Inventory)" := 0;
                    "Qty. (Alt.) (Phys. Inventory)" := 0;
                    Modify;
                until Next = 0;

        if NewTrackingSpec.Find('-') then
            repeat
                SetRange("Serial No.", NewTrackingSpec."Serial No.");
                SetRange("Lot No.", NewTrackingSpec."Lot No.");
                if not Find('-') then begin
                    Rec := NewItemTrackingLine;
                    "Entry No." := NextEntryNo;
                    "Qty. per Unit of Measure" := QtyPerUOM;
                    "Serial No." := NewTrackingSpec."Serial No.";
                    "Lot No." := NewTrackingSpec."Lot No.";
                    "Supplier Lot No." := NewTrackingSpec."Supplier Lot No."; // P8001106
                    "Expiration Date" := NewTrackingSpec."Expiration Date";                            // P8009351
                    "Lot Creation Date" := NewTrackingSpec."Lot Creation Date";                        // P8008351
                    "Country/Region of Origin Code" := NewTrackingSpec."Country/Region of Origin Code"; // P8008351
                    "New Serial No." := NewTrackingSpec."New Serial No."; // P8000343A
                    "New Lot No." := NewTrackingSpec."New Lot No.";       // P8000343A
                    "New Lot Status Code" := NewTrackingSpec."New Lot Status Code"; // P8001083
                    "Appl.-from Item Entry" := NewTrackingSpec."Appl.-from Item Entry"; // P8000466A
                    Insert;
                end;
                if (Mode = 'REPLACE') then begin                            // P8001106, P8008351
                    "Supplier Lot No." := NewTrackingSpec."Supplier Lot No."; // P8001106
                    "Expiration Date" := NewTrackingSpec."Expiration Date";                             // P8009351
                    "Lot Creation Date" := NewTrackingSpec."Lot Creation Date";                         // P8008351
                    "Country/Region of Origin Code" := NewTrackingSpec."Country/Region of Origin Code"; // P8008351
                end; // P8008351
                if not "Phys. Inventory" then begin
                    "Quantity (Base)" += NewTrackingSpec."Quantity (Base)";
                    "Quantity (Alt.)" += NewTrackingSpec."Quantity (Alt.)";
                    "Qty. to Handle (Base)" += NewTrackingSpec."Qty. to Handle (Base)";
                    "Qty. to Invoice (Base)" += NewTrackingSpec."Qty. to Invoice (Base)";
                    "Qty. to Handle (Alt.)" += NewTrackingSpec."Qty. to Handle (Alt.)";
                end else begin
                    "Qty. (Phys. Inventory)" += NewTrackingSpec."Quantity (Base)";
                    "Qty. (Alt.) (Phys. Inventory)" += NewTrackingSpec."Quantity (Alt.)";
                    "Quantity (Base)" := "Qty. (Phys. Inventory)" - "Qty. (Calculated)";
                    "Qty. to Handle (Base)" := "Quantity (Base)";
                    "Qty. to Invoice (Base)" := "Quantity (Base)";
                    "Qty. to Handle (Alt.)" := "Qty. (Alt.) (Phys. Inventory)" - "Qty. (Alt.) (Calculated)";
                end;
                "Qty. to Handle" := CalcQty("Qty. to Handle (Base)");
                "Qty. to Invoice" := CalcQty("Qty. to Invoice (Base)");
                Modify;
            until NewTrackingSpec.Next = 0;

        CalculateSums;
        if UpdateUndefinedQty then begin // P8000150A
            WriteToDatabase;
            // P8000150A Begin
            if CurrentRunMode = CurrentRunMode::"Drop Shipment" then
                case CurrentSourceType of
                    DATABASE::"Sales Line":
                        SynchronizeLinkedSources(''); // P8000505A
                    DATABASE::"Purchase Line":
                        SynchronizeLinkedSources(''); // P8000505A
                end;
            // P8000150A End
            if CurrentRunMode = CurrentRunMode::Transfer then // P8000267B
                SynchronizeLinkedSources('');             // P8000267B
        end else // P8000150A
            Error(Text014, TotalTrackingSpecification."Quantity (Base)",
              LowerCase(TempReservEntry.TextCaption), SourceQuantityArray[1]);
    end;

    procedure SetAltQtyControls(TrackingSpecification: Record "Tracking Specification")
    var
        AltQtyOn: Boolean;
    begin
        // SetAltQtyControls
        // PR3.60 Begin
        AltQtyOn := Item.TrackAlternateUnits;
        if AltQtyOn then
            case TrackingSpecification."Source Type" of
                DATABASE::"Sales Line", DATABASE::"Purchase Line":
                    AltQtyOn := TrackingSpecification."Source Subtype" in [1, 3, 5]; // PR3.61.01 - Order, Credit Memo, Return Order
                DATABASE::"Item Journal Line", Database::"Invt. Document Line": // P800127049
                    AltQtyOn := true;
                DATABASE::"Transfer Line": // PR3.61
                    AltQtyOn := true;         // PR3.61
                else
                    AltQtyOn := false;
            end;
        QuantityAltVisible := (AltQtyOn and (CurrentRunMode = 2));                      //P8000664
        QtytoHandleAltVisible := (AltQtyOn and                                       //P8000664
          ((CurrentRunMode in [0, 1]) or QtytoHandleAltVisible)); // P8000339A
        QtytoHandleAltEditable := AltQtyOn and
          ((CurrentRunMode in [0, 1]) or QtytoHandleAltEditable); // P8000339A
        QtytoInvoiceAltVisible := AltQtyOn and QtytoInvoiceAltVisible;
        QuantityHandledAltVisible := AltQtyOn and QuantityHandledAltVisible;
        QuantityInvoicedAltVisible := AltQtyOn and QuantityInvoicedAltVisible;
        // PR3.60 End
    end;

    procedure UpdateResEntryAltQty(TrackingSpecification: Record "Tracking Specification")
    var
        ResEntry: Record "Reservation Entry";
        TotalResEntry: Record "Reservation Entry";
    begin
        // P8000267B
        ResEntry.SetCurrentKey("Source Type", "Source ID", "Source Batch Name", "Source Ref. No.", "Lot No.", "Serial No.");
        ResEntry.SetRange("Source Type", TrackingSpecification."Source Type");
        ResEntry.SetRange("Source ID", TrackingSpecification."Source ID");
        ResEntry.SetRange("Source Batch Name", TrackingSpecification."Source Batch Name");
        ResEntry.SetRange("Source Ref. No.", TrackingSpecification."Source Ref. No.");
        ResEntry.SetRange("Source Subtype", TrackingSpecification."Source Subtype");
        ResEntry.SetRange("Source Prod. Order Line", TrackingSpecification."Source Prod. Order Line");

        if ResEntry.Find('-') then
            if ResEntry.TrackAlternateUnits then
                repeat
                    TotalResEntry := ResEntry;
                    ResEntry.SetRange("Lot No.", ResEntry."Lot No.");
                    ResEntry.SetRange("Serial No.", ResEntry."Serial No.");
                    while ResEntry.Next <> 0 do begin
                        TotalResEntry."Quantity (Base)" += ResEntry."Quantity (Base)";
                        TotalResEntry."Qty. to Handle (Base)" += ResEntry."Qty. to Handle (Base)";
                        TotalResEntry."Qty. to Invoice (Base)" += ResEntry."Qty. to Invoice (Base)";
                    end;
                    AltQtyMgmt.SetResLineAltQty(TotalResEntry);
                    ResEntry.SetRange("Lot No.");
                    ResEntry.SetRange("Serial No.");
                until ResEntry.Next = 0;
    end;

    procedure BinContentItemTrackingInsert(TempItemTrackingLineNew: Record "Tracking Specification")
    begin
        // P8000756
        Rec := TempItemTrackingLineNew;
        "Entry No." := NextEntryNo;
        if (not InsertIsBlocked) and (not ZeroLineExists) then
            if not TestTempSpecificationExists then
                Insert;
        MoveBinContent := true;
        WriteToDatabase;
    end;

    local procedure QtytoHandleAltOnAfterValidate()
    begin
        // PR3.60
        CurrPage.SaveRecord;
        AltQtyMgmt.ValidateTrackingAltQtyLine(Rec); // P8000267B
        CurrPage.Update;
        // PR3.60
    end;

    procedure GetTrackingSpec(var TempTrackingSpecification: Record "Tracking Specification" temporary)
    begin
        TempTrackingSpecification.DeleteAll();

        if Rec.FindSet() then
            repeat
                TempTrackingSpecification := Rec;
                TempTrackingSpecification.Insert();
            until Rec.Next() = 0;
    end;

    procedure SetSecondSourceID(SourceID: Integer; IsATO: Boolean)
    begin
        SecondSourceID := SourceID;
        IsAssembleToOrder := IsATO;
    end;

    protected procedure SynchronizeWarehouseItemTracking()
    var
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        Location: Record Location;
        WarehouseEntry: Record "Warehouse Entry";
        WhseManagement: Codeunit "Whse. Management";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSynchronizeWarehouseItemTracking(Rec, IsHandled);
        if IsHandled then
            exit;

        if ItemTrackingMgt.ItemTrkgIsManagedByWhse(
             Rec."Source Type", Rec."Source Subtype", Rec."Source ID",
             Rec."Source Prod. Order Line", Rec."Source Ref. No.", Rec."Location Code", Rec."Item No.")
        then
            exit;

        WhseManagement.SetSourceFilterForWhseShptLine(
          WarehouseShipmentLine, Rec."Source Type", Rec."Source Subtype", Rec."Source ID", Rec."Source Ref. No.", true);
        if WarehouseShipmentLine.IsEmpty() then
            exit;

        WarehouseShipmentLine.FindSet();
        if not (Location.RequirePicking(Rec."Location Code") and Location.RequirePutaway(Rec."Location Code")) then begin
            WarehouseEntry.SetSourceFilter(Rec."Source Type", Rec."Source Subtype", Rec."Source ID", Rec."Source Ref. No.", true);
            WarehouseEntry.SetFilter(
              "Reference Document", '%1|%2',
              WarehouseEntry."Reference Document"::"Put-away", WarehouseEntry."Reference Document"::Pick);
            if not WarehouseEntry.IsEmpty() then
                exit;
        end;
        repeat
            WarehouseShipmentLine.DeleteWhseItemTrackingLines();
            WarehouseShipmentLine.CreateWhseItemTrackingLines();
        until WarehouseShipmentLine.Next() = 0;
    end;

    protected procedure IsOrderToOrderBindingToTransfer(): Boolean
    var
        ReservEntry: Record "Reservation Entry";
    begin
        if CurrentSourceType = DATABASE::"Transfer Line" then
            exit(false);

        ReservEntry.SetSourceFilter(Rec."Source Type", Rec."Source Subtype", Rec."Source ID", Rec."Source Ref. No.", true);
        ReservEntry.SetSourceFilter(Rec."Source Batch Name", Rec."Source Prod. Order Line");
        ReservEntry.SetRange("Reservation Status", ReservEntry."Reservation Status"::Reservation);
        ReservEntry.SetRange(Binding, ReservEntry.Binding::"Order-to-Order");
        if ReservEntry.IsEmpty() then
            exit(false);

        ReservEntry.FindFirst();
        ReservEntry.Get(ReservEntry."Entry No.", not ReservEntry.Positive);
        if not ((ReservEntry."Source Type" = DATABASE::"Transfer Line") and (ReservEntry."Source Subtype" = 0)) then
            exit(false);

        CurrentSourceRowID :=
          ItemTrackingMgt.ComposeRowID(ReservEntry."Source Type",
            0, ReservEntry."Source ID", ReservEntry."Source Batch Name",
            ReservEntry."Source Prod. Order Line", ReservEntry."Source Ref. No.");
        SecondSourceRowID :=
          ItemTrackingMgt.ComposeRowID(ReservEntry."Source Type",
            1, ReservEntry."Source ID", ReservEntry."Source Batch Name",
            ReservEntry."Source Prod. Order Line", ReservEntry."Source Ref. No.");
        exit(true);
    end;

    local procedure NotifyWhenTrackingIsManagedByWhse()
    var
        TrkgManagedByWhseNotification: Notification;
    begin
        if ItemTrackingManagedByWhse then begin
            TrkgManagedByWhseNotification.Id := CreateGuid();
            TrkgManagedByWhseNotification.Message(ItemTrkgManagedByWhseMsg);
            TrkgManagedByWhseNotification.Scope(NOTIFICATIONSCOPE::LocalScope);
            TrkgManagedByWhseNotification.Send();
        end;
    end;

    local procedure SerialNoInfoCardAction(SerialNo: Code[50])
    var
        SerialNoInfoNew: Record "Serial No. Information";
        SerialNoInfoForm: Page "Serial No. Information Card";

    begin
        Clear(SerialNoInfoForm);
        SerialNoInfoForm.Init(Rec);

        SerialNoInfoNew.SetRange("Item No.", Rec."Item No.");
        SerialNoInfoNew.SetRange("Variant Code", Rec."Variant Code");
        SerialNoInfoNew.SetRange("Serial No.", SerialNo);

        SerialNoInfoForm.SetTableView(SerialNoInfoNew);
        SerialNoInfoForm.Run;
    end;

    local procedure LotNoInfoCardAction(LotNo: Code[50])
    var
        LotNoInfoNew: Record "Lot No. Information";
        LotNoInfoForm: Page "Lot No. Information Card";
    begin
        Clear(LotNoInfoForm);
        LotNoInfoForm.Init(Rec);

        LotNoInfoNew.SetRange("Item No.", Rec."Item No.");
        LotNoInfoNew.SetRange("Variant Code", Rec."Variant Code");
        LotNoInfoNew.SetRange("Lot No.", LotNo);

        LotNoInfoForm.SetTableView(LotNoInfoNew);
        LotNoInfoForm.Run;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAddReservEntriesToTempRecSetOnAfterTempTrackingSpecificationTransferFields(var TempTrackingSpecification: Record "Tracking Specification" temporary; var ReservEntry: Record "Reservation Entry")
    begin
    end;

    local procedure MarkItemTrackingLinesWithTheSameLotAsModified()
    var
        TempTrackingSpecification: Record "Tracking Specification" temporary;
    begin
        TempTrackingSpecification.Copy(Rec);

        SetFilter("Entry No.", '<>%1', "Entry No.");
        SetRange("Item No.", "Item No.");
        SetRange("Variant Code", "Variant Code");
        SetRange("Lot No.", "Lot No.");
        SetRange("Buffer Status", 0);
        if FindSet() then
            repeat
                if TempItemTrackLineModify.Get("Entry No.") then
                    TempItemTrackLineModify.Delete();
                if TempItemTrackLineInsert.Get("Entry No.") then begin
                    TempItemTrackLineInsert.TransferFields(Rec);
                    TempItemTrackLineInsert.Modify();
                end else begin
                    TempItemTrackLineModify.TransferFields(Rec);
                    TempItemTrackLineModify.Insert();
                end;
            until Next() = 0;

        Copy(TempTrackingSpecification);
    end;

    local procedure FillSourceQuantityArray(TrackingSpecification: Record "Tracking Specification")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeFillSourceQuantityArray(SourceQuantityArray, TrackingSpecification, IsHandled);
        if IsHandled then
            exit;

        SourceQuantityArray[1] := TrackingSpecification."Quantity (Base)";
        SourceQuantityArray[2] := TrackingSpecification."Qty. to Handle (Base)";
        SourceQuantityArray[3] := TrackingSpecification."Qty. to Invoice (Base)";
        SourceQuantityArray[4] := TrackingSpecification."Quantity Handled (Base)";
        SourceQuantityArray[5] := TrackingSpecification."Quantity Invoiced (Base)";
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyTrackingSpec(var SourceTrackingSpec: Record "Tracking Specification"; var DestTrkgSpec: Record "Tracking Specification")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCollectPostedOutputEntries(ItemLedgerEntry: Record "Item Ledger Entry"; var TempTrackingSpecification: Record "Tracking Specification" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterClearTrackingSpec(var OldTrkgSpec: Record "Tracking Specification")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateReservEntryFor(var OldTrackingSpecification: Record "Tracking Specification"; var NewTrackingSpecification: Record "Tracking Specification"; var CreateReservEntry: Codeunit "Create Reserv. Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterEntriesAreIdentical(ReservEntry1: Record "Reservation Entry"; ReservEntry2: Record "Reservation Entry"; var IdenticalArray: array[2] of Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterMoveFields(var TrkgSpec: Record "Tracking Specification"; var ReservEntry: Record "Reservation Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignNewTrackingNo(var TrkgSpec: Record "Tracking Specification"; xTrkgSpec: Record "Tracking Specification"; FieldID: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetHandleSource(TrackingSpecification: Record "Tracking Specification"; var QtyToHandleColumnIsHidden: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetInvoiceSource(TrackingSpecification: Record "Tracking Specification"; var QtyToInvoiceColumnIsHidden: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRegisterItemTrackingLines(var TrackingSpecification: Record "Tracking Specification"; var TempTrackingSpecification: Record "Tracking Specification" temporary; var CurrTrackingSpecification: Record "Tracking Specification"; var AvailabilityDate: Date)
    begin
    end;

#if not CLEAN19
    [IntegrationEvent(TRUE, false)]
    local procedure OnAfterSetControls(ItemTrackingCode: Record "Item Tracking Code"; var Controls: Option Handle,Invoice,Quantity,Reclass,Tracking; var SetAccess: Boolean)
    begin
    end;
#endif

    [IntegrationEvent(TRUE, false)]
    local procedure OnAfterSetPageControls(ItemTrackingCode: Record "Item Tracking Code"; Controls: Enum "Item Tracking Lines Controls"; SetAccess: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetFilters(var TrackingSpecificationRec: Record "Tracking Specification"; TrackingSpecification: Record "Tracking Specification")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetSourceSpec(var TrackingSpecification: Record "Tracking Specification"; var CurrTrackingSpecification: Record "Tracking Specification"; var AvailabilityDate: Date; var BlockCommit: Boolean; FunctionsDemandVisible: Boolean; FunctionsSupplyVisible: Boolean; var QtyToHandleBaseEditable: Boolean; var QuantityBaseEditable: Boolean; var InsertIsBlocked: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSynchronizeLinkedSources(FormRunMode: Option ,Reclass,"Combined Ship/Rcpt","Drop Shipment",Transfer; CurrentSourceType: Integer; CurrentSourceRowID: Text[250]; SecondSourceRowID: Text[250])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAssignLotNoOnAfterInsert(var TrackingSpecification: Record "Tracking Specification")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAssignPackageNoOnAfterInsert(var TrackingSpecification: Record "Tracking Specification")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAssignSerialNoBatchOnAfterInsert(var TrackingSpecification: Record "Tracking Specification"; QtyToCreate: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateCustomizedSNBatchOnAfterRecInsert(var TrackingSpecification: Record "Tracking Specification"; QtyToCreate: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAssignSerialNoOnAfterAssignQtyToCreateInt(var TrackingSpecification: Record "Tracking Specification"; var QtyToCreate: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateCustomizedSNByPageOnAfterCalcQtyToCreate(var TrackingSpecification: Record "Tracking Specification"; var QtyToCreate: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAssistEditLotNoOnBeforeCurrPageUdate(var TrackingSpecification: Record "Tracking Specification"; xTrackingSpecification: Record "Tracking Specification")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddToGlobalRecordSet(var TrackingSpecification: Record "Tracking Specification"; EntriesExist: Boolean; CurrentSignFactor: Integer; var TempTrackingSpecification: Record "Tracking Specification" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAssignNewSerialNo(var TrackingSpecification: Record "Tracking Specification"; var IsHandled: Boolean; var SourceTrackingSpecification: Record "Tracking Specification")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAssignNewCustomizedSerialNo(var TrackingSpecification: Record "Tracking Specification"; var CustomizedSN: Code[50]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAssignNewLotNo(var TrackingSpecification: Record "Tracking Specification"; var IsHandled: Boolean; var SourceTrackingSpecification: Record "Tracking Specification")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAssignNewPackageNo(var TrackingSpecification: Record "Tracking Specification"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeClosePage(var TrackingSpecification: Record "Tracking Specification"; var SkipWriteToDatabase: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteRecord(var TrackingSpecification: Record "Tracking Specification")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLotNoAssistEdit(var TrackingSpecification: Record "Tracking Specification"; xTrackingSpecification: Record "Tracking Specification"; CurrentSignFactor: Integer; var MaxQuantity: Decimal; UndefinedQtyArray: array[3] of Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnModifyRecord(var TrackingSpecification: Record "Tracking Specification"; xTrackingSpecification: Record "Tracking Specification"; InsertIsBlocked: Boolean; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRegisterChange(var OldTrackingSpecification: Record "Tracking Specification"; var NewTrackingSpecification: Record "Tracking Specification"; CurrentSignFactor: Integer; FormRunMode: Option ,Reclass,"Combined Ship/Rcpt","Drop Shipment",Transfer; var IsHandled: Boolean; CurrentPageIsOpen: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSerialNoAssistEdit(var TrackingSpecification: Record "Tracking Specification"; xTrackingSpecification: Record "Tracking Specification"; CurrentSignFactor: Integer; var IsHandled: Boolean; var MaxQuantity: Decimal; UndefinedQtyArray: array[3] of Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSerialNoOnAfterValidate(var TempTrackingSpecification: Record "Tracking Specification" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetSourceSpec(var TrackingSpecification: Record "Tracking Specification"; var ReservationEntry: Record "Reservation Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetSecondSourceQuantity(var SecondSourceQuantityArray: array[3] of Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSynchronizeLinkedSources(FormRunMode: Option ,Reclass,"Combined Ship/Rcpt","Drop Shipment",Transfer; CurrentSourceType: Integer; CurrentSourceRowID: Text[250]; SecondSourceRowID: Text[250]; var DialogText: Text[250])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCollectTempTrackingSpecificationInsert(var TempTrackingSpecification: Record "Tracking Specification" temporary; ItemLedgerEntry: Record "Item Ledger Entry"; var TrackingSpecification: Record "Tracking Specification")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateTrackingData(var TrackingSpecification: Record "Tracking Specification"; xTrackingSpecification: Record "Tracking Specification"; var xTempTrackingSpec: Record "Tracking Specification" temporary; CurrentSignFactor: Integer; var SourceQuantityArray: array[5] of Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateUndefinedQty(var TrackingSpecification: Record "Tracking Specification"; var TotalItemTrackingSpecification: Record "Tracking Specification"; var UndefinedQtyArray: array[3] of Decimal; var SourceQuantityArray: array[5] of Decimal; var ReturnValue: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeWriteToDatabase(var TrackingSpecification: Record "Tracking Specification"; var CurrentPageIsOpen: Boolean; var BlockCommit: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAddReservEntriesToTempRecSetOnBeforeInsert(var TempTrackingSpecification: Record "Tracking Specification" temporary; ReservationEntry: Record "Reservation Entry"; SwapSign: Boolean; Color: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertRecordOnBeforeTempItemTrackLineInsert(var TempTrackingSpecificationInsert: Record "Tracking Specification" temporary; var TempTrackingSpecification: Record "Tracking Specification" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnProcessLateBindingOnBeforeTempItemTrackLineReservInsert(var TempItemTrackLineReserv: Record "Tracking Specification"; CurrentSignFactor: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRegisterChangeOnAfterCreateReservEntry(var ReservEntry: Record "Reservation Entry"; TrackingSpecification: Record "Tracking Specification"; OldTrackingSpecification: Record "Tracking Specification")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRegisterChangeOnAfterFullDelete(var ReservEntry: Record "Reservation Entry"; var NewTrackingSpecification: Record "Tracking Specification"; var OldTrackingSpecification: Record "Tracking Specification"; CurrentPageIsOpen: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRegisterChangeOnAfterModify(var NewTrackingSpecification: Record "Tracking Specification"; var OldTrackingSpecification: Record "Tracking Specification"; CurrentPageIsOpen: Boolean; var SavedOldTrackingSpecification: Record "Tracking Specification")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRegisterChangeOnChangeTypeModifyOnBeforeCheckEntriesAreIdentical(var ReservEntry1: Record "Reservation Entry"; var ReservEntry2: Record "Reservation Entry"; var OldTrackingSpecification: Record "Tracking Specification"; var NewTrackingSpecification: Record "Tracking Specification"; var IdenticalArray: array[2] of Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSelectEntriesOnAfterTransferFields(var TempTrackingSpec: Record "Tracking Specification" temporary; var TrackingSpecification: Record "Tracking Specification")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetQtyToHandleAndInvoiceOnBeforeReservEntryModify(var ReservationEntry: Record "Reservation Entry"; TrackingSpecification: Record "Tracking Specification")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetQtyToHandleAndInvoiceOnBeforeTrackingSpecModify(var TrackingSpecification: Record "Tracking Specification"; var TotalTrackingSpecification: Record "Tracking Specification"; var ModifyLine: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetSourceSpecOnAfterAssignCurrentEntryStatus(var TrackingSpecification: Record "Tracking Specification"; var CurrentEntryStatus: Option)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnWriteToDatabaseOnBeforeRegisterDecrease(var TempTrackingSpecificationModify: Record "Tracking Specification" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnWriteToDatabaseOnBeforeRegisterInsert(var TempTrackingSpecificationInsert: Record "Tracking Specification" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateExpDateEditable(var TrackingSpecification: Record "Tracking Specification"; var ExpirationDateEditable: Boolean; var ItemTrackingCode: Record "Item Tracking Code"; var NewExpirationDateEditable: Boolean; CurrentSignFactor: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnTestTempSpecificationExistsOnAfterSetFilters(var TrackingSpecification: Record "Tracking Specification")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRegisterItemTrackingLinesOnAfterReclass(var TrackingSpecification: Record "Tracking Specification"; TempTrackingSpecification: Record "Tracking Specification" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRegisterChangeOnChangeTypeInsertOnBeforeInsertReservEntry(var TrackingSpecification: Record "Tracking Specification"; var OldTrackingSpecification: Record "Tracking Specification"; var NewTrackingSpecification: Record "Tracking Specification"; FormRunMode: Option)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnWriteToDataOnBeforeCommit(var TrackingSpecification: Record "Tracking Specification"; var TempReservEntry: Record "Reservation Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnQueryClosePageOnBeforeConfirmClosePage(var TrackingSpecification: Record "Tracking Specification"; var IsHandled: Boolean; CurrentRunMode: Enum "Item Tracking Run Mode")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFillSourceQuantityArray(var SourceQuantityArray: array[5] of Decimal; TrackingSpecification: Record "Tracking Specification"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateSerialNoOnBeforeFindLotNo(var TrackingSpecification: Record "Tracking Specification"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetSourceSpecForTransferReceipt(var TrackingSpecificationRec: Record "Tracking Specification"; var ReservEntry: Record "Reservation Entry"; var TrackingSpecification: Record "Tracking Specification"; CurrentRunMode: Enum "Item Tracking Run Mode"; var DeleteIsBlocked: Boolean; var IsHandled: Boolean; var TempTrackingSpecification2: Record "Tracking Specification" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckItemTrackingLine(var TrackingSpecification: Record "Tracking Specification"; var IsHandled: Boolean; var SourceQuantityArray: array[5] of Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAssignLotNo(var TrackingSpecification: Record "Tracking Specification"; var TempItemTrackLineInsert: Record "Tracking Specification" temporary; SourceQuantityArray: array[5] of Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetWarehouseControls(TrackingSpecification: Record "Tracking Specification"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSynchronizeWarehouseItemTracking(TrackingSpecification: Record "Tracking Specification"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRegisterChangeOnBeforeInsert(var NewTrackingSpecification: Record "Tracking Specification"; var OldTrackingSpecification: Record "Tracking Specification"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRegisterChangeOnAfterInsert(var NewTrackingSpecification: Record "Tracking Specification"; var OldTrackingSpecification: Record "Tracking Specification"; CurrentPageIsOpen: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRegisterChangeOnAfterPartialDelete(var NewTrackingSpecification: Record "Tracking Specification"; var OldTrackingSpecification: Record "Tracking Specification"; var ReservationEntry: Record "Reservation Entry"; CurrentPageIsOpen: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRegisterItemTrackingLinesOnAfterFind(var TrackingSpecification: Record "Tracking Specification"; var TempTrackingSpecification: Record "Tracking Specification" temporary; IsCorrection: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetQtyToHandleAndInvoiceOnBeforeReservEntryModify(var ReservEntry: Record "Reservation Entry"; var TrackingSpecification: Record "Tracking Specification"; var TotalTrackingSpecification: Record "Tracking Specification"; var ModifyLine: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterQtyToHandleAndInvoiceChanged(ReservEntry1: Record "Reservation Entry"; ReservEntry2: Record "Reservation Entry"; var HasChanged: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShouldAddQuantityAsBlank(OldTrackingSpecification: Record "Tracking Specification"; NewTrackingSpecification: Record "Tracking Specification"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSelectEntriesOnBeforeSelectMultipleTrackingNo(var ItemTrackingDataCollection: Codeunit "Item Tracking Data Collection"; CurrentSignFactor: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAddToGlobalRecordSetOnAfterTrackingSpecificationCalcSums(var TempTrackingSpecification: Record "Tracking Specification" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShouldModifyTrackingSpecification(TrackingSpecification: Record "Tracking Specification"; TrackingSpecificationModify: Record "Tracking Specification"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalculateSumsOnAfterCalcSums(var TrackingSpecification: Record "Tracking Specification")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateUndefinedQtyArray(TotalTrackingSpecification: Record "Tracking Specification")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetQtyToHandleAndInvoice(var TrackingSpecification: record "Tracking Specification"; IsCorrection: Boolean; CurrentSignFactor: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRegisterChangeOnBeforeAddItemTrackingToTempRecSet(var OldTrackingSpecification: Record "Tracking Specification"; var NewTrackingSpecification: record "Tracking Specification"; CurrentSignFactor: Integer; var TempReservEntry: record "Reservation Entry" temporary);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAddToGlobalRecordSetOnAfterTrackingSpecificationSetCurrentKey(var TempTrackingSpecification: Record "Tracking Specification" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnWriteToDatabaseOnBeforeUpdateOrderTracking(var TempReservEntry: Record "Reservation Entry" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeleteRecordOnAfterWMSCheckTrackingChange(TrackingSpecification: Record "Tracking Specification"; xTrackingSpecification: Record "Tracking Specification")
    begin
    end;
}

