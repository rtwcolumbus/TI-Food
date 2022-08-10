codeunit 37002001 "Alt. Qty. Caption Management"
{
    // PR3.60
    //   Management of alternate quantity captions (Caption Class 14015035)
    // 
    //   Each caption type is designed for a paricular set of parameters based
    //   on which table you find the field. These parameters are used to determine
    //   the item number and if the field is an item quantity. If possible, the
    //   item is retrieved. If it is an alternate quantity item, the alternate
    //   unit of measure is retrieved. From the unit of measure and the field type
    //   parameter, the caption is created.
    // 
    //   Caption Types (first parameter)
    //     0 = Item, Item Journal Line, Prod. Order Line, etc.
    //         parameter 3: Item No.
    //     1 = Sales and Purchase Line
    //         parameters 3-4: Line Type, Item No.
    //     2 = Alternate Quantity Line
    //         parameters 3-8: Table No., Document Type, Document No.,
    //                         Journal Template Name, Journal Batch Name, Line No.
    //     3 = Alternate Quantity Entry
    //         parameters 3-5: Table No., Document No., Line No.
    // 
    //   Field Types (second parameter)
    //     0 = Qty.
    //     1 = Qty. to Ship
    //     2 = Qty. Shipped
    //     3 = Qty. to Receive
    //     4 = Qty. Received
    //     5 = Qty. to Invoice
    //     6 = Qty. Invoiced
    //     7 = Qty. Remaining
    //     8 = Qty. Expected
    //     9 = Qty. Finished
    //    10 = Qty. (Calculated)
    //    11 = Qty. (Phys. Inventory)
    //    12 = Qty. on Hand
    //    13 = Net Qty. Invoiced
    //    14 = Qty. to Handle
    //    15 = Qty. Handled
    //    16 - Qty. Shipped Not Returned
    //    17 - Qty. Not Returned
    //    18 - Qty. Returned
    //    19 - Qty. Applied
    //    20 - Qty. Available
    //    21 - Qty. to Produce
    //    22 - Qty. Produced
    //    23 - Qty. to Transfer
    //    24 - Qty. Transferred
    //    25 - Qty. to Consume
    //    26 - Qty. Consumed
    //    27 - Qty. Picked
    //    28 - Available for Quantity Application
    //    29 - Available for Cost Application
    // 
    // PR3.61
    //   Add logic for Blank Captions
    // 
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Add support for transfer lines
    // 
    // PR4.00.06
    // P8000496A, VerticalSoft, Jack Reynolds, 23 JUL 07
    //   Support for repack orders and lines
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 31 JUL 07
    //   Added new caption types for Qty. Shipped Not Returned, Qty. Not Returned, Qty. Returned, Qty. Applied
    // 
    // PRW15.00.01
    // P8000512A, VerticalSoft, Jack Reynolds, 12 SEP 07
    //   Fix multi-language problem with captions for sales and purchase lines
    // 
    // P8000599A, VerticalSoft, Don Bresee, 14 MAY 08
    //   Added new caption types for Page 522 - Available for Quantity Application, Available for Cost Application
    // 
    // PRW16.00.03
    // P8000828, VerticalSoft, Don Bresee, 09 JUN 10
    //   Eliminate Item specific captions, RTC does not handle them properly, always use default caption
    // 
    // PRW18.00.01
    // P8001390, Columbus IT, Jack Reynolds, 18 JUN 15
    //   Multi-language support for default captions
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        Item: Record Item;
        UnitOfMeasure: Record "Unit of Measure";
        Text000: Label '%1s';
        InvtSetup: Record "Inventory Setup";
        InvtSetupRead: Boolean;
        ProcessFns: Codeunit "Process 800 Functions";
        FieldType: Option "Qty.","Qty. to Ship","Qty. Shipped","Qty. to Receive","Qty. Received","Qty. to Invoice","Qty. Invoiced","Qty. Remaining","Qty. Expected","Qty. Finished","Qty. (Calculated)","Qty. (Phys. Inventory)","Qty. on Hand","Net Qty. Invoiced","Qty. to Handle","Qty. Handled","Qty. Shipped Not Returned","Qty. Not Returned","Qty. Returned","Qty. Applied","Qty. Available","Qty. to Produce","Qty. Produced","Qty. to Transfer","Qty. Transferred","Qty. to Consume","Qty. Consumed","Qty. Picked","Available for Quantity Application","Available for Cost Application";
        Text001: Label '%1 (Alt.)';
        Text002: Label 'ITEM';
        Text1000: Label '%1';
        Text1001: Label '%1 to Ship';
        Text1002: Label '%1 Shipped';
        Text1003: Label '%1 to Receive';
        Text1004: Label '%1 Received';
        Text1005: Label '%1 to Invoice';
        Text1006: Label '%1 Invoiced';
        Text1007: Label '%1 Remaining';
        Text1008: Label '%1 Expected';
        Text1009: Label '%1 Finished';
        Text1010: Label '%1 (Calculated)';
        Text1011: Label '%1 (Phys. Inventory)';
        Text1012: Label '%1 on Hand';
        Text1013: Label 'Net %1 Invoiced';
        Text1014: Label '%1 to Handle';
        Text1015: Label '%1 Handled';
        Text1016: Label 'Shipped %1 Not Returned';
        Text1017: Label '%1 Not Returned';
        Text1018: Label '%1 Returned';
        Text1019: Label '%1 Applied';
        Text1020: Label '%1 Available';
        Text1021: Label '%1 to Produce';
        Text1022: Label '%1 Produced';
        Text1023: Label '%1 to Transfer';
        Text1024: Label '%1 Transferred';
        Text1025: Label '%1 to Consume';
        Text1026: Label '%1 Consumed';
        Text1027: Label '%1 Picked';
        Text1028: Label '%1 Available for Quantity Application';
        Text1029: Label '%1 Available for Cost Application';
        Caption00: Label 'Qty.';
        Caption01: Label 'Qty. to Ship';
        Caption02: Label 'Qty. Shipped';
        Caption03: Label 'Qty. to Receive';
        Caption04: Label 'Qty. Received';
        Caption05: Label 'Qty. to Invoice';
        Caption06: Label 'Qty. Invoiced';
        Caption07: Label 'Qty. Remaining';
        Caption08: Label 'Qty. Expected';
        Caption09: Label 'Qty. Finished';
        Caption10: Label 'Qty. (Calculated)';
        Caption11: Label 'Qty. (Phys. Inventory)';
        Caption12: Label 'Qty. on Hand';
        Caption13: Label 'Net Qty. Invoiced';
        Caption14: Label 'Qty. to Handle';
        Caption15: Label 'Qty. Handled';
        Caption16: Label 'Qty. Shipped Not Returned';
        Caption17: Label 'Qty. Not Returned';
        Caption18: Label 'Qty. Returned';
        Caption19: Label 'Qty. Applied';
        Caption20: Label 'Qty. Available';
        Caption21: Label 'Qty. to Produce';
        Caption22: Label 'Qty. Produced';
        Caption23: Label 'Qty. to Transfer';
        Caption24: Label 'Qty. Transferred';
        Caption25: Label 'Qty. to Consume';
        Caption26: Label 'Qty. Consumed';
        Caption27: Label 'Qty. Picked';
        Caption28: Label 'Available for Quantity Application';
        Caption29: Label 'Available for Cost Application';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Caption Class", 'OnResolveCaptionClass', '', true, true)]
    local procedure CaptionClass_OnResolveCaptionClass(CaptionArea: Text; CaptionExpr: Text; Language: Integer; var Caption: Text; var Resolved: Boolean)
    begin
        // P80073095
        if CaptionArea = '37002080' then begin
            Caption := AltQtyCaptionClassTranslate(Language, CaptionExpr);
            Resolved := true;
        end;
    end;

    local procedure AltQtyCaptionClassTranslate(Language: Integer; CaptionExpr: Text[80]): Text[80]
    var
        CaptionType: Integer;
        TempFieldType: Integer;
    begin
        if ExtractIntParameter(CaptionExpr, CaptionType, false) then
            if ExtractIntParameter(CaptionExpr, TempFieldType, false) then begin
                FieldType := TempFieldType;

                if IsServiceTier() then      // P8000828
                    exit(GetDefaultCaption()); // P8000828

                if not ProcessFns.AltQtyInstalled then
                    exit(GetDefaultCaption);
                case CaptionType of
                    0:
                        exit(GetItemAltUOMDescription(CaptionExpr));
                    1:
                        exit(GetTypeItemAltUOMDescription(CaptionExpr));
                    2:
                        exit(GetAltQtyLineUOMDescription(CaptionExpr));
                    3:
                        exit(GetAltQtyEntryUOMDescription(CaptionExpr));
                end;
            end;
        exit('');
    end;

    local procedure GetUOMDescription(UnitOfMeasureCode: Code[10]): Text[80]
    var
        UOMDescription: Text[80];
    begin
        if (UnitOfMeasureCode = '') then begin               // PR3.61
            GetInvtSetup;                                      // PR3.61
            if InvtSetup."Blank Captions (Non Alt. Qty.)" then // PR3.61
                exit('');                                        // PR3.61
            exit(GetDefaultCaption());                         // PR3.61
        end;                                                 // PR3.61
        GetUnitOfMeasure(UnitOfMeasureCode);
        if (UnitOfMeasure."Qty. Field Caption" <> '') then
            UOMDescription := UnitOfMeasure."Qty. Field Caption"
        else
            if (UnitOfMeasure.Description <> '') then
                UOMDescription := StrSubstNo(Text000, UnitOfMeasure.Description)
            else
                UOMDescription := UnitOfMeasure.Code;

        case FieldType of
            FieldType::"Qty.":
                exit(StrSubstNo(Text1000, UOMDescription));
            FieldType::"Qty. to Ship":
                exit(StrSubstNo(Text1001, UOMDescription));
            FieldType::"Qty. Shipped":
                exit(StrSubstNo(Text1002, UOMDescription));
            FieldType::"Qty. to Receive":
                exit(StrSubstNo(Text1003, UOMDescription));
            FieldType::"Qty. Received":
                exit(StrSubstNo(Text1004, UOMDescription));
            FieldType::"Qty. to Invoice":
                exit(StrSubstNo(Text1005, UOMDescription));
            FieldType::"Qty. Invoiced":
                exit(StrSubstNo(Text1006, UOMDescription));
            FieldType::"Qty. Remaining":
                exit(StrSubstNo(Text1007, UOMDescription));
            FieldType::"Qty. Expected":
                exit(StrSubstNo(Text1008, UOMDescription));
            FieldType::"Qty. Finished":
                exit(StrSubstNo(Text1009, UOMDescription));
            FieldType::"Qty. (Calculated)":
                exit(StrSubstNo(Text1010, UOMDescription));
            FieldType::"Qty. (Phys. Inventory)":
                exit(StrSubstNo(Text1011, UOMDescription));
            FieldType::"Qty. on Hand":
                exit(StrSubstNo(Text1012, UOMDescription));
            FieldType::"Net Qty. Invoiced":
                exit(StrSubstNo(Text1013, UOMDescription));
            FieldType::"Qty. to Handle":
                exit(StrSubstNo(Text1014, UOMDescription));
            FieldType::"Qty. Handled":
                exit(StrSubstNo(Text1015, UOMDescription));
                // P8000466A
            FieldType::"Qty. Shipped Not Returned":
                exit(StrSubstNo(Text1016, UOMDescription));
            FieldType::"Qty. Not Returned":
                exit(StrSubstNo(Text1017, UOMDescription));
            FieldType::"Qty. Returned":
                exit(StrSubstNo(Text1018, UOMDescription));
            FieldType::"Qty. Applied":
                exit(StrSubstNo(Text1019, UOMDescription));
            FieldType::"Qty. Available":
                exit(StrSubstNo(Text1020, UOMDescription));
                // P8000466A
                // P8000496A
            FieldType::"Qty. to Produce":
                exit(StrSubstNo(Text1021, UOMDescription));
            FieldType::"Qty. Produced":
                exit(StrSubstNo(Text1022, UOMDescription));
            FieldType::"Qty. to Transfer":
                exit(StrSubstNo(Text1023, UOMDescription));
            FieldType::"Qty. Transferred":
                exit(StrSubstNo(Text1024, UOMDescription));
            FieldType::"Qty. to Consume":
                exit(StrSubstNo(Text1025, UOMDescription));
            FieldType::"Qty. Consumed":
                exit(StrSubstNo(Text1026, UOMDescription));
                // P8000496A
                // P8000599A
            FieldType::"Qty. Picked":
                exit(StrSubstNo(Text1027, UOMDescription));
            FieldType::"Available for Quantity Application":
                exit(StrSubstNo(Text1028, UOMDescription));
            FieldType::"Available for Cost Application":
                exit(StrSubstNo(Text1029, UOMDescription));
                // P8000599A
        end;
    end;

    local procedure GetItemAltUOMDescription(ItemNo: Code[20]): Text[80]
    begin
        if (ItemNo = '') then
            exit(GetDefaultCaption());
        GetItem(ItemNo);
        exit(GetUOMDescription(Item."Alternate Unit of Measure"));
    end;

    local procedure GetTypeItemAltUOMDescription(CaptionExpr: Text[80]): Text[80]
    var
        LineType: Text[80];
    begin
        if ExtractParameter(CaptionExpr, LineType, false) then
            if (UpperCase(LineType) = Text002) then // P8000512A
                exit(GetItemAltUOMDescription(CaptionExpr));
        exit(GetDefaultCaption());
    end;

    local procedure GetAltQtyLineUOMDescription(CaptionExpr: Text[80]): Text[80]
    var
        TableNo: Integer;
        DocType: Text[80];
        DocNo: Text[80];
        JnlTemplName: Text[80];
        JnlBatchName: Text[80];
        LineNo: Integer;
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        ItemJnlLine: Record "Item Journal Line";
        TransLine: Record "Transfer Line";
    begin
        if ExtractIntParameter(CaptionExpr, TableNo, false) then
            if ExtractParameter(CaptionExpr, DocType, false) then
                if ExtractParameter(CaptionExpr, DocNo, false) then
                    if ExtractParameter(CaptionExpr, JnlTemplName, false) then
                        if ExtractParameter(CaptionExpr, JnlBatchName, false) then
                            if ExtractIntParameter(CaptionExpr, LineNo, true) then
                                case TableNo of
                                    DATABASE::"Item Journal Line":
                                        begin
                                            ItemJnlLine.SetRange("Journal Template Name", JnlTemplName);
                                            ItemJnlLine.SetRange("Journal Batch Name", JnlBatchName);
                                            ItemJnlLine.SetRange("Line No.", LineNo);
                                            if ItemJnlLine.Find('-') then
                                                exit(GetItemAltUOMDescription(ItemJnlLine."Item No."));
                                        end;
                                    DATABASE::"Sales Line":
                                        with SalesLine do begin
                                            SetFilter("Document Type", DocType);
                                            SetRange("Document No.", DocNo);
                                            SetRange("Line No.", LineNo);
                                            if Find('-') then
                                                if (Type = Type::Item) then begin
                                                    if (FieldType = FieldType::"Qty.") then
                                                        if ("Document Type" in
                                                           ["Document Type"::"Return Order", "Document Type"::"Credit Memo"])
                                                        then
                                                            FieldType := FieldType::"Qty. to Receive"
                                                        else
                                                            FieldType := FieldType::"Qty. to Ship";
                                                    exit(GetItemAltUOMDescription("No."));
                                                end;
                                        end;
                                    DATABASE::"Purchase Line":
                                        with PurchLine do begin
                                            SetFilter("Document Type", DocType);
                                            SetRange("Document No.", DocNo);
                                            SetRange("Line No.", LineNo);
                                            if Find('-') then
                                                if (Type = Type::Item) then begin
                                                    if (FieldType = FieldType::"Qty.") then
                                                        if ("Document Type" in
                                                           ["Document Type"::"Return Order", "Document Type"::"Credit Memo"])
                                                        then
                                                            FieldType := FieldType::"Qty. to Ship"
                                                        else
                                                            FieldType := FieldType::"Qty. to Receive";
                                                    exit(GetItemAltUOMDescription("No."));
                                                end;
                                        end;
                                    // P8000282A
                                    DATABASE::"Transfer Line":
                                        with TransLine do
                                            if Get(DocNo, LineNo) then begin
                                                if (FieldType = FieldType::"Qty.") then
                                                    if (DocType = ' ') then
                                                        FieldType := FieldType::"Qty. to Ship"
                                                    else
                                                        FieldType := FieldType::"Qty. to Receive";
                                                exit(GetItemAltUOMDescription("Item No."));
                                            end;
                                        // P8000282A
                                end;
        exit(GetDefaultCaption());
    end;

    local procedure GetAltQtyEntryUOMDescription(CaptionExpr: Text[80]): Text[80]
    var
        CaptionType: Text[80];
        TableNo: Integer;
        DocNo: Text[80];
        LineNo: Integer;
        ItemLedgEntry: Record "Item Ledger Entry";
        PhysInvtLedgEntry: Record "Phys. Inventory Ledger Entry";
        SalesShptLine: Record "Sales Shipment Line";
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        ReturnRcptLine: Record "Return Receipt Line";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        ReturnShptLine: Record "Return Shipment Line";
    begin
        if ExtractIntParameter(CaptionExpr, TableNo, false) then
            if ExtractParameter(CaptionExpr, DocNo, false) then
                if ExtractIntParameter(CaptionExpr, LineNo, true) then
                    case TableNo of
                        DATABASE::"Item Ledger Entry":
                            if ItemLedgEntry.Get(LineNo) then
                                exit(GetItemAltUOMDescription(ItemLedgEntry."Item No."));
                        DATABASE::"Phys. Inventory Ledger Entry":
                            if PhysInvtLedgEntry.Get(LineNo) then
                                exit(GetItemAltUOMDescription(PhysInvtLedgEntry."Item No."));
                        DATABASE::"Sales Shipment Line":
                            if SalesShptLine.Get(DocNo, LineNo) then
                                if (SalesShptLine.Type = SalesShptLine.Type::Item) then
                                    exit(GetItemAltUOMDescription(SalesShptLine."No."));
                        DATABASE::"Sales Invoice Line":
                            if SalesInvLine.Get(DocNo, LineNo) then
                                if (SalesInvLine.Type = SalesInvLine.Type::Item) then
                                    exit(GetItemAltUOMDescription(SalesInvLine."No."));
                        DATABASE::"Sales Cr.Memo Line":
                            if SalesCrMemoLine.Get(DocNo, LineNo) then
                                if (SalesCrMemoLine.Type = SalesCrMemoLine.Type::Item) then
                                    exit(GetItemAltUOMDescription(SalesCrMemoLine."No."));
                        DATABASE::"Return Receipt Line":
                            if ReturnRcptLine.Get(DocNo, LineNo) then
                                if (ReturnRcptLine.Type = ReturnRcptLine.Type::Item) then
                                    exit(GetItemAltUOMDescription(ReturnRcptLine."No."));
                        DATABASE::"Purch. Rcpt. Line":
                            if PurchRcptLine.Get(DocNo, LineNo) then
                                if (PurchRcptLine.Type = PurchRcptLine.Type::Item) then
                                    exit(GetItemAltUOMDescription(PurchRcptLine."No."));
                        DATABASE::"Purch. Inv. Line":
                            if PurchInvLine.Get(DocNo, LineNo) then
                                if (PurchInvLine.Type = PurchInvLine.Type::Item) then
                                    exit(GetItemAltUOMDescription(PurchInvLine."No."));
                        DATABASE::"Purch. Cr. Memo Line":
                            if PurchCrMemoLine.Get(DocNo, LineNo) then
                                if (PurchCrMemoLine.Type = PurchCrMemoLine.Type::Item) then
                                    exit(GetItemAltUOMDescription(PurchCrMemoLine."No."));
                        DATABASE::"Return Shipment Line":
                            if ReturnShptLine.Get(DocNo, LineNo) then
                                if (ReturnShptLine.Type = ReturnShptLine.Type::Item) then
                                    exit(GetItemAltUOMDescription(ReturnShptLine."No."));
                    end;
        exit(GetDefaultCaption());
    end;

    local procedure GetDefaultCaption(): Text[80]
    begin
        // P8001390
        //EXIT(STRSUBSTNO(Text001, FieldType));
        case FieldType of
            FieldType::"Qty.":
                exit(StrSubstNo(Text001, Caption00));
            FieldType::"Qty. to Ship":
                exit(StrSubstNo(Text001, Caption01));
            FieldType::"Qty. Shipped":
                exit(StrSubstNo(Text001, Caption02));
            FieldType::"Qty. to Receive":
                exit(StrSubstNo(Text001, Caption03));
            FieldType::"Qty. Received":
                exit(StrSubstNo(Text001, Caption04));
            FieldType::"Qty. to Invoice":
                exit(StrSubstNo(Text001, Caption05));
            FieldType::"Qty. Invoiced":
                exit(StrSubstNo(Text001, Caption06));
            FieldType::"Qty. Remaining":
                exit(StrSubstNo(Text001, Caption07));
            FieldType::"Qty. Expected":
                exit(StrSubstNo(Text001, Caption08));
            FieldType::"Qty. Finished":
                exit(StrSubstNo(Text001, Caption09));
            FieldType::"Qty. (Calculated)":
                exit(StrSubstNo(Text001, Caption10));
            FieldType::"Qty. (Phys. Inventory)":
                exit(StrSubstNo(Text001, Caption11));
            FieldType::"Qty. on Hand":
                exit(StrSubstNo(Text001, Caption12));
            FieldType::"Net Qty. Invoiced":
                exit(StrSubstNo(Text001, Caption13));
            FieldType::"Qty. to Handle":
                exit(StrSubstNo(Text001, Caption14));
            FieldType::"Qty. Handled":
                exit(StrSubstNo(Text001, Caption15));
            FieldType::"Qty. Shipped Not Returned":
                exit(StrSubstNo(Text001, Caption16));
            FieldType::"Qty. Not Returned":
                exit(StrSubstNo(Text001, Caption17));
            FieldType::"Qty. Returned":
                exit(StrSubstNo(Text001, Caption18));
            FieldType::"Qty. Applied":
                exit(StrSubstNo(Text001, Caption19));
            FieldType::"Qty. Available":
                exit(StrSubstNo(Text001, Caption20));
            FieldType::"Qty. to Produce":
                exit(StrSubstNo(Text001, Caption21));
            FieldType::"Qty. Produced":
                exit(StrSubstNo(Text001, Caption22));
            FieldType::"Qty. to Transfer":
                exit(StrSubstNo(Text001, Caption23));
            FieldType::"Qty. Transferred":
                exit(StrSubstNo(Text001, Caption24));
            FieldType::"Qty. to Consume":
                exit(StrSubstNo(Text001, Caption25));
            FieldType::"Qty. Consumed":
                exit(StrSubstNo(Text001, Caption26));
            FieldType::"Qty. Picked":
                exit(StrSubstNo(Text001, Caption27));
            FieldType::"Available for Quantity Application":
                exit(StrSubstNo(Text001, Caption28));
            FieldType::"Available for Cost Application":
                exit(StrSubstNo(Text001, Caption29));
        end;
        // P8001390
    end;

    local procedure ExtractParameter(var CaptionExpr: Text[80]; var Parameter: Text[80]; LastParameter: Boolean): Boolean
    var
        CommaPosition: Integer;
    begin
        if LastParameter then begin
            Parameter := CaptionExpr;
            CaptionExpr := '';
        end else begin
            CommaPosition := StrPos(CaptionExpr, ',');
            if (CommaPosition = 0) then
                exit(false);
            Parameter := CopyStr(CaptionExpr, 1, CommaPosition - 1);
            CaptionExpr := CopyStr(CaptionExpr, CommaPosition + 1);
        end;
        exit(true);
    end;

    local procedure ExtractIntParameter(var CaptionExpr: Text[80]; var Parameter: Integer; LastParameter: Boolean): Boolean
    var
        ParameterStr: Text[80];
    begin
        if ExtractParameter(CaptionExpr, ParameterStr, LastParameter) then
            if Evaluate(Parameter, ParameterStr) then
                exit(true);
        exit(false);
    end;

    local procedure GetItem(ItemNo: Code[20])
    begin
        if (Item."No." <> ItemNo) then
            Item.Get(ItemNo);
    end;

    local procedure GetUnitOfMeasure(UnitOfMeasureCode: Code[10])
    begin
        if (UnitOfMeasure.Code <> UnitOfMeasureCode) then
            UnitOfMeasure.Get(UnitOfMeasureCode);
    end;

    local procedure GetInvtSetup()
    begin
        if not InvtSetupRead then begin
            InvtSetup.Get;
            InvtSetupRead := true;
        end;
    end;
}

