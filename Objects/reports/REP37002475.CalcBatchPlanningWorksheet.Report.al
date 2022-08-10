report 37002475 "Calc. Batch Planning Worksheet"
{
    // PRW16.00.04
    // P8000877, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Calculates the Batch Planning Worksheet
    // 
    // PRW16.0.06
    // P8001051, Columbus IT, Jack Reynolds, 02 APR 12
    //   Support for filtering on Supply Chain Group
    // 
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // PRW110.0
    // P8007750, To-Increase, Jack Reynolds, 07 NOV 16
    //   Convert Food Item Attributes to NAV Item Attributes
    // 
    // P8007749, To-Increase, Jack Reynolds, 07 DEC 16
    //   Item Category/Product Group

    Caption = 'Calculate Batch Planning Worksheet';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.") WHERE("Item Type" = CONST("Finished Good"), "Production Grouping Item" = FILTER(<> ''), "Production BOM No." = FILTER(<> ''));
            RequestFilterFields = "Item Category Code", "Supply Chain Group Code";
            RequestFilterHeading = 'Finished Item';
            dataitem("Item Variant"; "Item Variant")
            {
                DataItemLink = "Item No." = FIELD("No.");
                DataItemTableView = SORTING("Item No.", Code);

                trigger OnAfterGetRecord()
                var
                    SKU: Record "Stockkeeping Unit";
                    BPWorksheetLine2: Record "Batch Planning Worksheet Line";
                    BPWorksheetLineTemp: Record "Batch Planning Worksheet Line" temporary;
                begin
                    GetPlanningParameter.AtSKU(SKU, "Item No.", Code, LocationCode);
                    if SKU."Replenishment System" <> SKU."Replenishment System"::"Prod. Order" then
                        CurrReport.Skip;

                    BPWorksheetLine."Variant Code" := Code;
                    BPWorksheetLine.Validate("Production BOM No.", Item.ProductionBOMNo(Code, LocationCode)); // P8001030

                    BPWorksheetLine.GetDemand(Item, SKU."Safety Lead Time", SKU."Manufacturing Policy", BPWorksheetLineTemp); // P8001030
                    BPWorksheetLine.Insert;
                    if BPWorksheetLineTemp.FindSet then
                        repeat
                            BPWorksheetLine2 := BPWorksheetLineTemp;
                            BPWorksheetLine2.Insert;
                        until BPWorksheetLineTemp.Next = 0;
                end;
            }

            trigger OnAfterGetRecord()
            var
                ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
                BPWorksheetLine2: Record "Batch Planning Worksheet Line";
                BPWorksheetLineTemp: Record "Batch Planning Worksheet Line" temporary;
                SKU: Record "Stockkeeping Unit";
                i: Integer;
                ItemNo: Code[20];
            begin
                // P8001051
                if MarkedItem.MarkedOnly then begin
                    MarkedItem.Get("No.");
                    if not MarkedItem.Mark then
                        CurrReport.Skip;
                end;
                // P8001051

                IntermediateItem."No." := "Production Grouping Item";
                if not IntermediateItem.Find('=') then
                    CurrReport.Skip;
                // P8001051
                if MarkedIntermediate.MarkedOnly then begin
                    MarkedIntermediate.Get(IntermediateItem."No.");
                    if not MarkedIntermediate.Mark then
                        CurrReport.Skip;
                end;
                // P8001051

                GetPlanningParameter.AtSKU(SKU, "Production Grouping Item", "Production Grouping Variant", LocationCode); // P8001030
                if SKU."Replenishment System" <> SKU."Replenishment System"::"Prod. Order" then
                    CurrReport.Skip;

                for i := 1 to 3 do
                    if TestAttribute[i] then begin
                        case AttributeType[i] of
                            1:
                                ItemNo := IntermediateItem."No."; // Type 1 - Intermediate Item
                            2:
                                ItemNo := Item."No.";             // Type 2 - Finished Item
                        end;
                        if not ItemAttributeValueMapping.Get(DATABASE::Item, ItemNo, AttributeID[i]) then // P8007750
                            CurrReport.Skip;
                        ItemAttributeValue[i].Get(AttributeID[i], ItemAttributeValueMapping."Item Attribute Value ID"); // P8007750
                        if not ItemAttributeValue[i].Mark then
                            CurrReport.Skip;
                    end;

                BPWorksheetLine.Init;
                BPWorksheetLine."Worksheet Name" := BPWorksheetName.Name;
                BPWorksheetLine."Item No." := "No.";
                BPWorksheetLine."Variant Code" := '';
                BPWorksheetLine.Type := BPWorksheetLine.Type::Summary;
                BPWorksheetLine."Line No." := 0;
                BPWorksheetLine."Location Code" := LocationCode;
                BPWorksheetLine."Begin Date" := WorkDate;
                BPWorksheetLine."End Date" := EndDate;
                BPWorksheetLine.Description := Description;
                BPWorksheetLine."Unit of Measure" := "Base Unit of Measure";
                BPWorksheetLine."Intermediate Item No." := IntermediateItem."No.";
                BPWorksheetLine."Intermediate Variant Code" := "Production Grouping Variant"; // P8001030
                BPWorksheetLine."Intermediate Description" := IntermediateItem.Description;
                BPWorksheetLine."Intermediate Unit of Measure" := IntermediateItem."Base Unit of Measure";
                BPWorksheetLine.Validate("Production BOM No.", "Production BOM No.");

                BPWorksheetLine."Parameter 1" := BatchPlanningFns.GetParameter(Item, IntermediateItem,
                  BPWorksheetName."Parameter 1 Type", BPWorksheetName."Parameter 1 Field", BPWorksheetName."Parameter 1 Attribute");
                BPWorksheetLine."Parameter 2" := BatchPlanningFns.GetParameter(Item, IntermediateItem,
                  BPWorksheetName."Parameter 2 Type", BPWorksheetName."Parameter 2 Field", BPWorksheetName."Parameter 2 Attribute");
                BPWorksheetLine."Parameter 3" := BatchPlanningFns.GetParameter(Item, IntermediateItem,
                  BPWorksheetName."Parameter 3 Type", BPWorksheetName."Parameter 3 Field", BPWorksheetName."Parameter 3 Attribute");

                GetPlanningParameter.AtSKU(SKU, "No.", '', LocationCode);
                if SKU."Replenishment System" = SKU."Replenishment System"::"Prod. Order" then begin // P8001030
                    BPWorksheetLine.GetDemand(Item, SKU."Safety Lead Time", SKU."Manufacturing Policy", BPWorksheetLineTemp); // P8001030
                    BPWorksheetLine.Insert;
                    if BPWorksheetLineTemp.FindSet then
                        repeat
                            BPWorksheetLine2 := BPWorksheetLineTemp;
                            BPWorksheetLine2.Insert;
                        until BPWorksheetLineTemp.Next = 0;
                end;
            end;

            trigger OnPreDataItem()
            var
                SupplyChainGroup: Record "Supply Chain Group";
                i: Integer;
            begin
                // P8001051
                if Item.GetFilter("Supply Chain Group Code") <> '' then begin
                    Item.CopyFilter("Supply Chain Group Code", SupplyChainGroup.Code);
                    Item.SetRange("Supply Chain Group Code");
                    if SupplyChainGroup.FindSet then
                        repeat
                            SupplyChainGroup.MarkItems(MarkedItem);
                        until SupplyChainGroup.Next = 0;
                    MarkedItem.MarkedOnly(true);
                end;

                if Intermediate.GetFilter("Supply Chain Group Code") <> '' then begin
                    Intermediate.CopyFilter("Supply Chain Group Code", SupplyChainGroup.Code);
                    Intermediate.SetRange("Supply Chain Group Code");
                    if SupplyChainGroup.FindSet then
                        repeat
                            SupplyChainGroup.MarkItems(MarkedIntermediate);
                        until SupplyChainGroup.Next = 0;
                    MarkedIntermediate.MarkedOnly(true);
                end;
                // P8001051

                for i := 1 to 3 do
                    if (AttributeType[i] > 0) and (AttributeID[i] <> 0) then begin // P8007750
                        ItemAttributeValue[i].MarkedOnly(true);
                        TestAttribute[i] := ItemAttributeValue[i].FindFirst;
                    end;
            end;
        }
        dataitem(Intermediate; Item)
        {
            DataItemTableView = SORTING("No.") WHERE("Item Type" = CONST(Intermediate), "Production BOM No." = FILTER(<> ''));
            RequestFilterFields = "Item Category Code", "Supply Chain Group Code";
            RequestFilterHeading = 'Intermediate Item';

            trigger OnPreDataItem()
            begin
                CurrReport.Break;
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
                    field("LocationCode "; LocationCode)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Location Code';
                        TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
                    }
                    field(DaysView; DaysView)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Days View';
                        MinValue = 0;

                        trigger OnValidate()
                        begin
                            EndDate := WorkDate + DaysView;
                        end;
                    }
                    field(EndDate; EndDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'End Date';

                        trigger OnValidate()
                        begin
                            if EndDate < WorkDate then
                                Error(Text002, WorkDate);
                            DaysView := EndDate - WorkDate;
                        end;
                    }
                }
                group("Attribute Filters")
                {
                    Caption = 'Attribute Filters';
                    field("SelectedAttributes(1)"; SelectedAttributes(1))
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = AttributeCaption(1);
                        Visible = ShowAttribute1;

                        trigger OnAssistEdit()
                        begin
                            SelectAttributes(1);
                        end;
                    }
                    field("SelectedAttributes(2)"; SelectedAttributes(2))
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = AttributeCaption(2);
                        Visible = ShowAttribute2;

                        trigger OnAssistEdit()
                        begin
                            SelectAttributes(2);
                        end;
                    }
                    field("SelectedAttributes(3)"; SelectedAttributes(3))
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = AttributeCaption(3);
                        Visible = ShowAttribute3;

                        trigger OnAssistEdit()
                        begin
                            SelectAttributes(3);
                        end;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        var
            DefaultLocation: Code[10];
        begin
            // P8001030
            DefaultLocation := P800CoreFns.GetDefaultEmpLocation;
            if DefaultLocation <> '' then
                LocationCode := DefaultLocation;
            // P8001030
            DaysView := WorksheetDaysView;
            EndDate := WorkDate + DaysView;
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        BPWorksheetLine.SetRange("Worksheet Name", BPWorksheetName.Name);
        BPWorksheetLine.DeleteAll(true);

        IntermediateItem.Copy(Intermediate);
    end;

    var
        BPWorksheetName: Record "Batch Planning Worksheet Name";
        BPWorksheetLine: Record "Batch Planning Worksheet Line";
        ItemAttributeValue: array[3] of Record "Item Attribute Value";
        IntermediateItem: Record Item;
        MarkedItem: Record Item;
        MarkedIntermediate: Record Item;
        P800CoreFns: Codeunit "Process 800 Core Functions";
        BatchPlanningFns: Codeunit "Batch Planning Functions";
        GetPlanningParameter: Codeunit "Planning-Get Parameters";
        LocationCode: Code[10];
        WorksheetDaysView: Integer;
        DaysView: Integer;
        EndDate: Date;
        [InDataSet]
        ShowAttribute1: Boolean;
        [InDataSet]
        ShowAttribute2: Boolean;
        [InDataSet]
        ShowAttribute3: Boolean;
        Text001: Label '%1 %2';
        AttributeID: array[3] of Integer;
        AttributeType: array[3] of Integer;
        TestAttribute: array[3] of Boolean;
        Text002: Label 'End date must be after %1.';

    procedure SetWorksheetName(Name: Code[10])
    begin
        BPWorksheetName.Get(Name);

        ShowAttribute1 := (BPWorksheetName."Parameter 1 Type" <> 0) and (BPWorksheetName."Parameter 1 Field" <> 0) and
          (BPWorksheetName."Parameter 1 Attribute" <> 0); // P8007750
        ShowAttribute2 := (BPWorksheetName."Parameter 2 Type" <> 0) and (BPWorksheetName."Parameter 2 Field" <> 0) and
          (BPWorksheetName."Parameter 2 Attribute" <> 0); // P8007750
        ShowAttribute3 := (BPWorksheetName."Parameter 3 Type" <> 0) and (BPWorksheetName."Parameter 3 Field" <> 0) and
          (BPWorksheetName."Parameter 3 Attribute" <> 0); // P8007750

        AttributeType[1] := BPWorksheetName."Parameter 1 Type";
        AttributeID[1] := BPWorksheetName."Parameter 1 Attribute"; // P8007750
        AttributeType[2] := BPWorksheetName."Parameter 2 Type";
        AttributeID[2] := BPWorksheetName."Parameter 2 Attribute"; // P8007750
        AttributeType[3] := BPWorksheetName."Parameter 3 Type";
        AttributeID[3] := BPWorksheetName."Parameter 3 Attribute"; // P8007750

        WorksheetDaysView := BPWorksheetName."Days View";
        if WorksheetDaysView = 0 then
            WorksheetDaysView := 1;
    end;

    procedure AttributeCaption(ParameterNo: Integer): Text[50]
    var
        ItemAttribute: Record "Item Attribute";
        AttributeTypeText: Text[30];
    begin
        case ParameterNo of
            1:
                AttributeTypeText := Format(BPWorksheetName."Parameter 1 Type");
            2:
                AttributeTypeText := Format(BPWorksheetName."Parameter 2 Type");
            3:
                AttributeTypeText := Format(BPWorksheetName."Parameter 3 Type");
        end;

        if ItemAttribute.Get(AttributeID[ParameterNo]) then; // P8007750
        exit(StrSubstNo(Text001, AttributeTypeText, ItemAttribute.Name)); // P8007750
    end;

    procedure SelectedAttributes(ParameterNo: Integer) SelectedText: Text
    begin
        ItemAttributeValue[ParameterNo].MarkedOnly(true);
        if ItemAttributeValue[ParameterNo].FindSet then
            repeat
                SelectedText := SelectedText + '; ' + ItemAttributeValue[ParameterNo].Value; // P8007750
            until ItemAttributeValue[ParameterNo].Next = 0;
        SelectedText := CopyStr(SelectedText, 3);
    end;

    procedure SelectAttributes(ParameterNo: Integer)
    var
        SelectItemAttribute: Page "Select Item Attribute";
    begin
        SelectItemAttribute.SetAttribute(AttributeID[ParameterNo], ItemAttributeValue[ParameterNo]); // P8007750
        if SelectItemAttribute.RunModal = ACTION::OK then begin
            SelectItemAttribute.MarkSelectedAttributes(ItemAttributeValue[ParameterNo])
        end;
    end;
}

