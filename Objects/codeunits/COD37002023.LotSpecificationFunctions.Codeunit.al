codeunit 37002023 "Lot Specification Functions"
{
    // PR3.70.07
    // P8000152A, Myers Nissi, Jack Reynolds, 26 NOV 04
    //   LotSpecLookup - lookup function for lot specification lookups
    // 
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Support for lot specification shortcuts and lot preferences
    // 
    // PR3.70.08
    // P8000174A, Myers Nissi, Jack Reynolds, 27 JAN 05
    //   DeleteItemLotPrefs - set range for lot age and lot specification filter tables should be on "ID 2" not ID
    // 
    // P8000179A, Myers Nissi, Jack Reynolds, 09 FEB 05
    //   CopyLotPrefBOMToProdOrderComp - blank ID 2 (BOM Version) when copying preferences
    // 
    // PR3.70.10
    // P8000210A, Myers Nissi, Jack Reynolds, 11 MAY 05
    //   Improve lot preference for sales quide, blanket and standing orders
    // 
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00


    trigger OnRun()
    begin
    end;

    var
        InvSetup: Record "Inventory Setup";
        InvSetupShortcutLSCode: array[10] of Code[10];
        InvSetupRead: Boolean;

    procedure LotSpecLookup(LotSpecCode: Code[20]; var Text: Text[1024]): Boolean
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        exit(DataCollectionMgmt.DataElementLookup(LotSpecCode, Text)); // P8001090
    end;

    procedure GetInvSetup()
    begin
        // P8000153A
        if not InvSetupRead then begin
            InvSetup.Get;
            InvSetupShortcutLSCode[1] := InvSetup."Shortcut Lot Spec. 1 Code";
            InvSetupShortcutLSCode[2] := InvSetup."Shortcut Lot Spec. 2 Code";
            InvSetupShortcutLSCode[3] := InvSetup."Shortcut Lot Spec. 3 Code";
            InvSetupShortcutLSCode[4] := InvSetup."Shortcut Lot Spec. 4 Code";
            InvSetupShortcutLSCode[5] := InvSetup."Shortcut Lot Spec. 5 Code";
            InvSetupRead := true;
        end;
    end;

    procedure ShowShortcutLotSpec(ItemNo: Code[20]; VariantCode: Code[10]; LotNo: Code[50]; var ShortcutLotSpec: array[5] of Code[50])
    var
        LotSpec: Record "Lot Specification";
        i: Integer;
    begin
        // P8000153A
        GetInvSetup;
        for i := 1 to 5 do begin
            ShortcutLotSpec[i] := '';
            if InvSetupShortcutLSCode[i] <> '' then
                if LotSpec.Get(ItemNo, VariantCode, LotNo, InvSetupShortcutLSCode[i]) then
                    ShortcutLotSpec[i] := LotSpec.Value;
        end;
    end;

    procedure DeleteCustomerLotPrefs(Customer: Record Customer)
    var
        LotAgeFilter: Record "Lot Age Filter";
        LotSpecFilter: Record "Lot Specification Filter";
    begin
        // P8000153A
        LotAgeFilter.SetRange("Table ID", DATABASE::Customer);
        LotAgeFilter.SetRange(ID, Customer."No.");
        LotAgeFilter.DeleteAll;

        LotSpecFilter.SetRange("Table ID", DATABASE::Customer);
        LotSpecFilter.SetRange(ID, Customer."No.");
        LotSpecFilter.DeleteAll;
    end;

    procedure DeleteItemLotPrefs(Item: Record Item)
    var
        LotAgeFilter: Record "Lot Age Filter";
        LotSpecFilter: Record "Lot Specification Filter";
    begin
        // P8000153A
        LotAgeFilter.SetCurrentKey("Table ID", "ID 2");
        LotAgeFilter.SetRange("Table ID", DATABASE::Customer);
        LotAgeFilter.SetRange("ID 2", Item."No."); // P8000174A
        LotAgeFilter.DeleteAll;

        LotSpecFilter.SetCurrentKey("Table ID", "ID 2");
        LotSpecFilter.SetRange("Table ID", DATABASE::Customer);
        LotSpecFilter.SetRange("ID 2", Item."No."); // P8000174A
        LotSpecFilter.DeleteAll;
    end;

    procedure DeleteSalesLineLotPrefs(SalesLine: Record "Sales Line")
    var
        LotAgeFilter: Record "Lot Age Filter";
        LotSpecFilter: Record "Lot Specification Filter";
    begin
        // P8000153A
        LotAgeFilter.SetRange("Table ID", DATABASE::"Sales Line");
        LotAgeFilter.SetRange(Type, SalesLine."Document Type");
        LotAgeFilter.SetRange(ID, SalesLine."Document No.");
        LotAgeFilter.SetRange("Line No.", SalesLine."Line No.");
        LotAgeFilter.DeleteAll;

        LotSpecFilter.SetRange("Table ID", DATABASE::"Sales Line");
        LotSpecFilter.SetRange(Type, SalesLine."Document Type");
        LotSpecFilter.SetRange(ID, SalesLine."Document No.");
        LotSpecFilter.SetRange("Line No.", SalesLine."Line No.");
        LotSpecFilter.DeleteAll;
    end;

    procedure DeleteSalesDocLotPrefs(SalesHeader: Record "Sales Header")
    var
        LotAgeFilter: Record "Lot Age Filter";
        LotSpecFilter: Record "Lot Specification Filter";
    begin
        // P8000153A
        LotAgeFilter.SetRange("Table ID", DATABASE::"Sales Line");
        LotAgeFilter.SetRange(Type, SalesHeader."Document Type");
        LotAgeFilter.SetRange(ID, SalesHeader."No.");
        LotAgeFilter.DeleteAll;

        LotSpecFilter.SetRange("Table ID", DATABASE::"Sales Line");
        LotSpecFilter.SetRange(Type, SalesHeader."Document Type");
        LotSpecFilter.SetRange(ID, SalesHeader."No.");
        LotSpecFilter.DeleteAll;
    end;

    procedure DeleteBOMLineLotPrefs(BOMLine: Record "Production BOM Line")
    var
        LotAgeFilter: Record "Lot Age Filter";
        LotSpecFilter: Record "Lot Specification Filter";
    begin
        // P8000153A
        LotAgeFilter.SetRange("Table ID", DATABASE::"Production BOM Line");
        LotAgeFilter.SetRange(ID, BOMLine."Production BOM No.");
        LotAgeFilter.SetRange("ID 2", BOMLine."Version Code");
        LotAgeFilter.SetRange("Line No.", BOMLine."Line No.");
        LotAgeFilter.DeleteAll;

        LotSpecFilter.SetRange("Table ID", DATABASE::"Production BOM Line");
        LotSpecFilter.SetRange(ID, BOMLine."Production BOM No.");
        LotSpecFilter.SetRange("ID 2", BOMLine."Version Code");
        LotSpecFilter.SetRange("Line No.", BOMLine."Line No.");
        LotSpecFilter.DeleteAll;
    end;

    procedure DeleteBOMLotPrefs(BOMVersion: Record "Production BOM Version")
    var
        LotAgeFilter: Record "Lot Age Filter";
        LotSpecFilter: Record "Lot Specification Filter";
    begin
        // P8000153A
        LotAgeFilter.SetRange("Table ID", DATABASE::"Production BOM Line");
        LotAgeFilter.SetRange(ID, BOMVersion."Production BOM No.");
        LotAgeFilter.SetRange("ID 2", BOMVersion."Version Code");
        LotAgeFilter.DeleteAll;

        LotSpecFilter.SetRange("Table ID", DATABASE::"Production BOM Line");
        LotSpecFilter.SetRange(ID, BOMVersion."Production BOM No.");
        LotSpecFilter.SetRange("ID 2", BOMVersion."Version Code");
        LotSpecFilter.DeleteAll;
    end;

    procedure DeleteProdOrderCompLotPrefs(ProdOrderComp: Record "Prod. Order Component")
    var
        LotAgeFilter: Record "Lot Age Filter";
        LotSpecFilter: Record "Lot Specification Filter";
    begin
        // P8000153A
        LotAgeFilter.SetRange("Table ID", DATABASE::"Prod. Order Component");
        LotAgeFilter.SetRange(Type, ProdOrderComp.Status);
        LotAgeFilter.SetRange(ID, ProdOrderComp."Prod. Order No.");
        LotAgeFilter.SetRange("Prod. Order Line No.", ProdOrderComp."Prod. Order Line No.");
        LotAgeFilter.SetRange("Line No.", ProdOrderComp."Line No.");
        LotAgeFilter.DeleteAll;

        LotSpecFilter.SetRange("Table ID", DATABASE::"Prod. Order Component");
        LotSpecFilter.SetRange(Type, ProdOrderComp.Status);
        LotSpecFilter.SetRange(ID, ProdOrderComp."Prod. Order No.");
        LotSpecFilter.SetRange("Prod. Order Line No.", ProdOrderComp."Prod. Order Line No.");
        LotSpecFilter.SetRange("Line No.", ProdOrderComp."Line No.");
        LotSpecFilter.DeleteAll;
    end;

    procedure CopyLotPrefCustomerToSalesLine(SalesLine: Record "Sales Line")
    var
        LotAgeFilter: Record "Lot Age Filter";
        LotAgeFilter2: Record "Lot Age Filter";
        LotSpecFilter: Record "Lot Specification Filter";
        LotSpecFilter2: Record "Lot Specification Filter";
    begin
        // P8000153A
        // P8000210A - remove parameter for xSalesLine
        with SalesLine do begin
            if not ("Document Type" in                                                                       // P8000210A
              ["Document Type"::"Blanket Order", "Document Type"::FOODStandingOrder, "Document Type"::Order]) // P8000210A
            then                                                                                             // P8000210A
                exit;
            //  IF (xSalesLine.Type = Type) AND (xSalesLine."No." = "No.") THEN // P8000210A
            //    EXIT;                                                         // P8000210A
            DeleteSalesLineLotPrefs(SalesLine);

            if Type <> Type::Item then
                exit;

            LotAgeFilter.SetRange("Table ID", DATABASE::Customer);
            LotAgeFilter.SetRange(ID, "Sell-to Customer No.");
            LotAgeFilter.SetRange("ID 2", "No.");
            if LotAgeFilter.Find('-') then
                repeat
                    LotAgeFilter2 := LotAgeFilter;
                    LotAgeFilter2."Table ID" := DATABASE::"Sales Line";
                    LotAgeFilter2.Type := "Document Type";
                    LotAgeFilter2.ID := "Document No.";
                    LotAgeFilter2."ID 2" := '';
                    LotAgeFilter2."Line No." := "Line No.";
                    LotAgeFilter2.Insert;
                until LotAgeFilter.Next = 0;

            LotSpecFilter.SetRange("Table ID", DATABASE::Customer);
            LotSpecFilter.SetRange(ID, "Sell-to Customer No.");
            LotSpecFilter.SetRange("ID 2", "No.");
            if LotSpecFilter.Find('-') then
                repeat
                    LotSpecFilter2 := LotSpecFilter;
                    LotSpecFilter2."Table ID" := DATABASE::"Sales Line";
                    LotSpecFilter2.Type := "Document Type";
                    LotSpecFilter2.ID := "Document No.";
                    LotSpecFilter2."ID 2" := '';
                    LotSpecFilter2."Line No." := "Line No.";
                    LotSpecFilter2.Insert;
                until LotSpecFilter.Next = 0;
        end;
    end;

    procedure CopyLotPrefSlsLineToSalesLine(FromSalesLine: Record "Sales Line"; ToSalesLine: Record "Sales Line")
    var
        LotAgeFilter: Record "Lot Age Filter";
        LotAgeFilter2: Record "Lot Age Filter";
        LotSpecFilter: Record "Lot Specification Filter";
        LotSpecFilter2: Record "Lot Specification Filter";
    begin
        // P8000210A
        if ToSalesLine.Type <> ToSalesLine.Type::Item then
            exit;

        LotAgeFilter.SetRange("Table ID", DATABASE::"Sales Line");
        LotAgeFilter.SetRange(Type, FromSalesLine."Document Type");
        LotAgeFilter.SetRange(ID, FromSalesLine."Document No.");
        LotAgeFilter.SetRange("Line No.", FromSalesLine."Line No.");
        if LotAgeFilter.Find('-') then
            repeat
                LotAgeFilter2 := LotAgeFilter;
                LotAgeFilter2.Type := ToSalesLine."Document Type";
                LotAgeFilter2.ID := ToSalesLine."Document No.";
                LotAgeFilter2."Line No." := ToSalesLine."Line No.";
                LotAgeFilter2.Insert;
            until LotAgeFilter.Next = 0;

        LotSpecFilter.SetRange("Table ID", DATABASE::"Sales Line");
        LotSpecFilter.SetRange(Type, FromSalesLine."Document Type");
        LotSpecFilter.SetRange(ID, FromSalesLine."Document No.");
        LotSpecFilter.SetRange("Line No.", FromSalesLine."Line No.");
        if LotSpecFilter.Find('-') then
            repeat
                LotSpecFilter2 := LotSpecFilter;
                LotSpecFilter2.Type := ToSalesLine."Document Type";
                LotSpecFilter2.ID := ToSalesLine."Document No.";
                LotSpecFilter2."Line No." := ToSalesLine."Line No.";
                LotSpecFilter2.Insert;
            until LotSpecFilter.Next = 0;
    end;

    procedure CopyLotPrefBOMToBOM(FromBOMLine: Record "Production BOM Line"; ToBOMLine: Record "Production BOM Line")
    var
        LotAgeFilter: Record "Lot Age Filter";
        LotAgeFilter2: Record "Lot Age Filter";
        LotSpecFilter: Record "Lot Specification Filter";
        LotSpecFilter2: Record "Lot Specification Filter";
    begin
        LotAgeFilter.SetRange("Table ID", DATABASE::"Production BOM Line");
        LotAgeFilter.SetRange(ID, FromBOMLine."Production BOM No.");
        LotAgeFilter.SetRange("ID 2", FromBOMLine."Version Code");
        LotAgeFilter.SetRange("Line No.", FromBOMLine."Line No.");
        if LotAgeFilter.Find('-') then
            repeat
                LotAgeFilter2 := LotAgeFilter;
                LotAgeFilter2.ID := ToBOMLine."Production BOM No.";
                LotAgeFilter2."ID 2" := ToBOMLine."Version Code";
                LotAgeFilter2."Line No." := ToBOMLine."Line No.";
                LotAgeFilter2.Insert;
            until LotAgeFilter.Next = 0;

        LotSpecFilter.SetRange("Table ID", DATABASE::"Production BOM Line");
        LotSpecFilter.SetRange(ID, FromBOMLine."Production BOM No.");
        LotSpecFilter.SetRange("ID 2", FromBOMLine."Version Code");
        LotSpecFilter.SetRange("Line No.", FromBOMLine."Line No.");
        if LotSpecFilter.Find('-') then
            repeat
                LotSpecFilter2 := LotSpecFilter;
                LotSpecFilter2.ID := ToBOMLine."Production BOM No.";
                LotSpecFilter2."ID 2" := ToBOMLine."Version Code";
                LotSpecFilter2."Line No." := ToBOMLine."Line No.";
                LotSpecFilter2.Insert;
            until LotSpecFilter.Next = 0;
    end;

    procedure CopyLotPrefBOMToProdOrderComp(POComp: Record "Prod. Order Component")
    var
        LotAgeFilter: Record "Lot Age Filter";
        LotAgeFilter2: Record "Lot Age Filter";
        LotSpecFilter: Record "Lot Specification Filter";
        LotSpecFilter2: Record "Lot Specification Filter";
    begin
        // P8000153A
        with POComp do begin
            if (Status <> Status::Released) or ("Production BOM No." = '') or
              ("Production BOM Version Code" = '') or ("Production BOM Line No." = 0)
            then
                exit;

            LotAgeFilter.SetRange("Table ID", DATABASE::"Production BOM Line");
            LotAgeFilter.SetRange(ID, "Production BOM No.");
            LotAgeFilter.SetRange("ID 2", "Production BOM Version Code");
            LotAgeFilter.SetRange("Line No.", "Production BOM Line No.");
            if LotAgeFilter.Find('-') then
                repeat
                    LotAgeFilter2 := LotAgeFilter;
                    LotAgeFilter2."Table ID" := DATABASE::"Prod. Order Component";
                    LotAgeFilter2.Type := Status;
                    LotAgeFilter2.ID := "Prod. Order No.";
                    LotAgeFilter2."ID 2" := ''; // P8000179A
                    LotAgeFilter2."Prod. Order Line No." := "Prod. Order Line No.";
                    LotAgeFilter2."Line No." := "Line No.";
                    LotAgeFilter2.Insert;
                until LotAgeFilter.Next = 0;

            LotSpecFilter.SetRange("Table ID", DATABASE::"Production BOM Line");
            LotSpecFilter.SetRange(ID, "Production BOM No.");
            LotSpecFilter.SetRange("ID 2", "Production BOM Version Code");
            LotSpecFilter.SetRange("Line No.", "Production BOM Line No.");
            if LotSpecFilter.Find('-') then
                repeat
                    LotSpecFilter2 := LotSpecFilter;
                    LotSpecFilter2."Table ID" := DATABASE::"Prod. Order Component";
                    LotSpecFilter2.Type := Status;
                    LotSpecFilter2.ID := "Prod. Order No.";
                    LotSpecFilter2."ID 2" := ''; // P8000179A
                    LotSpecFilter2."Prod. Order Line No." := "Prod. Order Line No.";
                    LotSpecFilter2."Line No." := "Line No.";
                    LotSpecFilter2.Insert;
                until LotSpecFilter.Next = 0;
        end;
    end;
}

