report 37002763 "Staged Pick - Pick Orders"
{
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 15 SEP 06
    //   Staged Picks
    // 
    // PR5.00
    // P8000494A, VerticalSoft, Don Bresee, 18 JUL 07
    //   Add Production Bins/Replenishment
    // 
    // PRW16.00.03
    // P8000792, VerticalSoft, Rick Tweedle, 17 MAR 10
    //   Converted using TIF Editor
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 20 FEB 13
    //   Restoring the SaveValues property in the Request Page.
    // 
    // PRW17.00
    // P8001142, Columbus IT, Don Bresee, 09 MAR 13
    //   Rework Replenishment logic
    // 
    // PRW17.10.02
    // P8001301, Columbus IT, Jack Reynolds, 03 MAR 14
    //   Update Rollup 4 - Change call to CreatePick.CreateWhseDocument

    Caption = 'Staged Pick - Pick Orders';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Whse. Staged Pick Source Line"; "Whse. Staged Pick Source Line")
        {
            DataItemTableView = SORTING("No.", "Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.");
            dataitem("Warehouse Shipment Line"; "Warehouse Shipment Line")
            {
                DataItemLink = "Source Type" = FIELD("Source Type"), "Source Subtype" = FIELD("Source Subtype"), "Source No." = FIELD("Source No."), "Source Line No." = FIELD("Source Line No.");
                DataItemTableView = SORTING("Source Type", "Source Subtype", "Source No.", "Source Line No.");

                trigger OnAfterGetRecord()
                begin
                    TestField("Qty. per Unit of Measure");
                    if QtyToPick > 0 then begin
                        if "Destination Type" = "Destination Type"::Customer then begin
                            TestField("Destination No.");
                            Cust.Get("Destination No.");
                            Cust.CheckBlockedCustOnDocs(Cust, "Source Document", false, false);
                        end;

                        WhseShptHeader.Get("No.");
                        CreatePick.SetWhseShipment(
                          "Warehouse Shipment Line",
                          WhseStgdPickMgmt.AssignTempDocNo(
                            WhseStgdPickHeader."Order Picking Options", "Source No."),
                          WhseShptHeader."Shipping Agent Code", WhseShptHeader."Shipping Agent Service Code",
                          WhseShptHeader."Shipment Method Code");
                        CreatePick.SetTempWhseItemTrkgLine(
                          "No.", DATABASE::"Warehouse Shipment Line",
                          '', 0, "Line No.", "Location Code");
                        CreatePick.CreateTempLine(
                          "Location Code", "Item No.", "Variant Code", "Unit of Measure Code",
                          '', "Bin Code", "Qty. per Unit of Measure", QtyToPick, QtyToPickBase);
                        CreatePick.SaveTempItemTrkgLines;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    if (WhseStgdPickHeader."Staging Type" <> WhseStgdPickHeader."Staging Type"::Shipment) then
                        CurrReport.Break;
                end;
            }
            dataitem("Prod. Order Component"; "Prod. Order Component")
            {
                DataItemLink = Status = FIELD("Source Subtype"), "Prod. Order No." = FIELD("Source No."), "Prod. Order Line No." = FIELD("Source Line No."), "Line No." = FIELD("Source Subline No.");
                DataItemTableView = SORTING(Status, "Prod. Order No.", "Prod. Order Line No.", "Line No.");

                trigger OnAfterGetRecord()
                begin
                    if ("Flushing Method" = "Flushing Method"::"Pick + Forward") and ("Routing Link Code" = '') then
                        CurrReport.Skip;

                    GetLocation("Location Code");
                    Location.SetToProductionBin("Prod. Order No.", "Prod. Order Line No.", "Line No."); // P8001142
                    if Location."Directed Put-away and Pick" then begin
                        Location.TestField("To-Production Bin Code");
                        if BinContent.Get(
                          "Location Code", Location."To-Production Bin Code",
                          "Item No.", "Variant Code", "Unit of Measure Code")
                        then begin
                            if BinContent."Block Movement" in [
                               BinContent."Block Movement"::Inbound, BinContent."Block Movement"::All]
                            then
                                BinContent.FieldError("Block Movement");
                        end else begin
                            if Location."Bin Mandatory" then begin
                                Bin.Get("Location Code", Location."To-Production Bin Code");
                                if Bin."Block Movement" in [Bin."Block Movement"::Inbound, Bin."Block Movement"::All] then
                                    Bin.FieldError("Block Movement");
                            end;
                        end;
                    end;

                    TestField("Qty. per Unit of Measure");
                    if QtyToPick > 0 then begin
                        CreatePick.SetProdOrderCompLine(
                          "Prod. Order Component",
                          WhseStgdPickMgmt.AssignTempDocNo(
                            WhseStgdPickHeader."Order Picking Options", "Prod. Order No."));
                        CreatePick.SetTempWhseItemTrkgLine(
                          "Prod. Order No.", DATABASE::"Prod. Order Component", '',
                          "Prod. Order Line No.", "Line No.", "Location Code");
                        CreatePick.CreateTempLine(
                          "Location Code", "Item No.", "Variant Code", "Unit of Measure Code",
                          '', Location."To-Production Bin Code",
                          "Qty. per Unit of Measure", QtyToPick, QtyToPickBase);
                        CreatePick.SaveTempItemTrkgLines;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    if (WhseStgdPickHeader."Staging Type" <> WhseStgdPickHeader."Staging Type"::Production) then
                        CurrReport.Break;

                    SetFilter(
                      "Flushing Method", '%1|%2|%3',
                      "Prod. Order Component"."Flushing Method"::Manual,
                      "Prod. Order Component"."Flushing Method"::"Pick + Forward",
                      "Prod. Order Component"."Flushing Method"::"Pick + Backward");
                    SetRange("Planning Level Code", 0);
                    SetFilter("Expected Quantity", '>0');
                end;
            }

            trigger OnAfterGetRecord()
            begin
                WhseStgdPickHeader.Get("No.");
                WhseStgdPickLine.Get("No.", "Line No.");
                if Location."Directed Put-away and Pick" then
                    WhseStgdPickLine.CheckBin(false);

                CalcFields("Pick Qty.", "Pick Qty. (Base)");
                QtyToPickBase := "Qty. (Base)" - ("Qty. Picked (Base)" + "Pick Qty. (Base)");
                QtyToPick := Quantity - ("Qty. Picked" + "Pick Qty.");

                CreatePick.RestrictToStagedFromPick("Whse. Staged Pick Source Line");
            end;

            trigger OnPreDataItem()
            begin
                case WhseStgdPickHeader."Staging Type" of
                    WhseStgdPickHeader."Staging Type"::Shipment:
                        begin
                            // P800131478
                            Clear(CreatePickParameters);
                            CreatePickParameters."Assigned ID" := AssignedID;
                            CreatePickParameters."Sorting Method" := CreatePickParameters."Sorting Method"::Item;
                            CreatePickParameters."Max No. of Lines" := 0;
                            CreatePickParameters."Max No. of Source Doc." := 0;
                            CreatePickParameters."Do Not Fill Qty. to Handle" := DoNotFillQtytoHandle;
                            CreatePickParameters."Breakbulk Filter" := BreakbulkFilter;
                            CreatePickParameters."Per Bin" := false;
                            CreatePickParameters."Per Zone" := false;
                            CreatePickParameters."Whse. Document" := CreatePickParameters."Whse. Document"::Shipment;
                            CreatePickParameters."Whse. Document Type" := CreatePickParameters."Whse. Document Type"::Pick;
                            CreatePick.SetParameters(CreatePickParameters);
                            // P800131478
                        end;
                    WhseStgdPickHeader."Staging Type"::Production:
                        begin
                            // P800131478
                            Clear(CreatePickParameters);
                            CreatePickParameters."Assigned ID" := AssignedID;
                            CreatePickParameters."Sorting Method" := CreatePickParameters."Sorting Method"::Item;
                            CreatePickParameters."Max No. of Lines" := 0;
                            CreatePickParameters."Max No. of Source Doc." := 0;
                            CreatePickParameters."Do Not Fill Qty. to Handle" := DoNotFillQtytoHandle;
                            CreatePickParameters."Breakbulk Filter" := BreakbulkFilter;
                            CreatePickParameters."Per Bin" := false;
                            CreatePickParameters."Per Zone" := false;
                            CreatePickParameters."Whse. Document" := CreatePickParameters."Whse. Document"::Production;
                            CreatePickParameters."Whse. Document Type" := CreatePickParameters."Whse. Document Type"::Pick;
                            CreatePick.SetParameters(CreatePickParameters);
                            // P800131478
                        end;
                end;

                CopyFilters(WhseStgdPickSourceLine);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(AssignedID; AssignedID)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Assigned User ID';
                        TableRelation = "Warehouse Employee";

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            WhseEmployee: Record "Warehouse Employee";
                            LookupWhseEmployee: Page "Warehouse Employee List";
                        begin
                            WhseEmployee.SetCurrentKey("Location Code");
                            WhseEmployee.SetRange("Location Code", Location.Code);
                            LookupWhseEmployee.LookupMode(true);
                            LookupWhseEmployee.SetTableView(WhseEmployee);
                            if LookupWhseEmployee.RunModal = ACTION::LookupOK then begin
                                LookupWhseEmployee.GetRecord(WhseEmployee);
                                AssignedID := WhseEmployee."User ID";
                            end;
                        end;

                        trigger OnValidate()
                        var
                            WhseEmployee: Record "Warehouse Employee";
                        begin
                            if AssignedID <> '' then
                                WhseEmployee.Get(AssignedID, Location.Code);
                        end;
                    }
                    field(SortActivity; SortActivity)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Sorting Method for Activity Lines';
                        MultiLine = true;
                        OptionCaption = ' ,Item,Document,Shelf or Bin,Due Date,Destination,Bin Ranking,Action Type';
                    }
                    field(BreakbulkFilter; BreakbulkFilter)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Set Breakbulk Filter';
                    }
                    field(DoNotFillQtytoHandle; DoNotFillQtytoHandle)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Do Not Fill Qty. to Handle';
                    }
                    field(PrintDoc; PrintDoc)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Print Document';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            if Location."Use ADCS" then
                DoNotFillQtytoHandle := true;

            if (OverrideAssignedID <> '') then
                AssignedID := OverrideAssignedID;
        end;
    }

    labels
    {
    }

    trigger OnPostReport()
    var
        WhseActivHeader: Record "Warehouse Activity Header";
        TempWhseItemTrkgLine: Record "Whse. Item Tracking Line" temporary;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        CreatePick.CreateWhseDocument(FirstActivityNo, LastActivityNo, false); // P8001301

        CreatePick.ReturnTempItemTrkgLines(TempWhseItemTrkgLine);
        ItemTrackingMgt.UpdateWhseItemTrkgLines(TempWhseItemTrkgLine);

        WhseActivHeader.SetRange(Type, WhseActivHeader.Type::Pick);
        WhseActivHeader.SetRange("No.", FirstActivityNo, LastActivityNo);
        if WhseActivHeader.Find('-') then begin
            repeat
                if SortActivity > 0 then
                    WhseActivHeader.SortWhseDoc;
            until WhseActivHeader.Next = 0;

            if PrintDoc then
                REPORT.Run(REPORT::"Picking List", false, false, WhseActivHeader);
        end else
            Error(Text002);
    end;

    trigger OnPreReport()
    begin
        Clear(CreatePick);
        EverythingHandled := true;
    end;

    var
        Location: Record Location;
        WhseStgdPickHeader: Record "Whse. Staged Pick Header";
        WhseStgdPickLine: Record "Whse. Staged Pick Line";
        WhseStgdPickSourceLine: Record "Whse. Staged Pick Source Line";
        WhseShptHeader: Record "Warehouse Shipment Header";
        BinContent: Record "Bin Content";
        Bin: Record Bin;
        Cust: Record Customer;
        CreatePickParameters: Record "Create Pick Parameters";
        CreatePick: Codeunit "Create Pick";
        FirstActivityNo: Code[20];
        LastActivityNo: Code[20];
        AssignedID: Code[20];
        OverrideAssignedID: Code[20];
        SortActivity: Option " ",Item,Document,"Shelf or Bin","Due Date",Destination,"Bin Ranking","Action Type";
        QtyToPick: Decimal;
        QtyToPickBase: Decimal;
        PrintDoc: Boolean;
        EverythingHandled: Boolean;
        HideValidationDialog: Boolean;
        DoNotFillQtytoHandle: Boolean;
        BreakbulkFilter: Boolean;
        Text000: Label '%1 activity no. %2 has been created.';
        Text001: Label '%1 activities no. %2 to %3 have been created.';
        Text002: Label 'There is nothing to handle.';
        WhseStgdPickMgmt: Codeunit "Whse. Staged Pick Mgmt.";

    procedure SetWhseStgdPickSourceLine(var WhseStgdPickSourceLine2: Record "Whse. Staged Pick Source Line"; WhseStgdPickHeader2: Record "Whse. Staged Pick Header")
    begin
        WhseStgdPickSourceLine.Copy(WhseStgdPickSourceLine2);
        WhseStgdPickHeader := WhseStgdPickHeader2;
        AssignedID := WhseStgdPickHeader."Assigned User ID";
        OverrideAssignedID := AssignedID;
        GetLocation(WhseStgdPickSourceLine."Location Code");
    end;

    procedure GetResultMessage(): Boolean
    var
        WhseActivHeader: Record "Warehouse Activity Header";
    begin
        if FirstActivityNo = '' then
            exit(false)
        else begin
            if not HideValidationDialog then begin
                WhseActivHeader.Type := WhseActivHeader.Type::Pick;
                if FirstActivityNo = LastActivityNo then
                    Message(Text000, Format(WhseActivHeader.Type), FirstActivityNo)
                else
                    Message(Text001, Format(WhseActivHeader.Type), FirstActivityNo, LastActivityNo);
            end;
            exit(EverythingHandled);
        end;
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    local procedure GetLocation(LocationCode: Code[10])
    begin
        if Location.Code <> LocationCode then begin
            if LocationCode = '' then
                Clear(Location)
            else
                Location.Get(LocationCode);
        end;
    end;

    procedure Initialize(AssignedID2: Code[20]; SortActivity2: Option " ",Item,Document,"Shelf/Bin No.","Due Date","Ship-To","Bin Ranking","Action Type"; PrintDoc2: Boolean; DoNotFillQtytoHandle2: Boolean; BreakbulkFilter2: Boolean)
    begin
        AssignedID := AssignedID2;
        SortActivity := SortActivity2;
        PrintDoc := PrintDoc2;
        DoNotFillQtytoHandle := DoNotFillQtytoHandle2;
        BreakbulkFilter := BreakbulkFilter2;
    end;
}

