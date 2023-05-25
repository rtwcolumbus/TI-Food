table 5841 "Standard Cost Worksheet"
{
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // PRW17.10.02
    // P8001262, Columbus IT, Jack Reynolds, 17 JAN 14
    //   Fix problem setting descriptoin for SKUs
    // 
    // P8001298, Columbus IT, Jack Reynolds, 26 FEB 14
    //   Fix problems with SKUs
    // 
    // PRW110.0.01
    // P8008734, To Increase, Jack Reynolds, 04 MAY 17
    //   Fix ValidateSKU to INIT the record

    Caption = 'Standard Cost Worksheet';

    fields
    {
        field(2; "Standard Cost Worksheet Name"; Code[10])
        {
            Caption = 'Standard Cost Worksheet Name';
            TableRelation = "Standard Cost Worksheet Name";
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Item,Work Center,Machine Center,Resource';
            OptionMembers = Item,"Work Center","Machine Center",Resource;

            trigger OnValidate()
            begin
                if Type <> xRec.Type then
                    Validate("No.", '');
            end;
        }
        field(4; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
            TableRelation = IF (Type = CONST(Item)) Item
            ELSE
            IF (Type = CONST("Machine Center")) "Machine Center"
            ELSE
            IF (Type = CONST("Work Center")) "Work Center"
            ELSE
            IF (Type = CONST(Resource)) Resource;

            trigger OnValidate()
            var
                TempStdCostWksh: Record "Standard Cost Worksheet" temporary;
            begin
                TempStdCostWksh := Rec;
                Init();
                Type := TempStdCostWksh.Type;
                "No." := TempStdCostWksh."No.";
                "Replenishment System" := "Replenishment System"::" "; // P8001298

                if "No." = '' then
                    exit;

                case Type of
                    Type::Item:
                        begin
                            Item.Get("No.");
                            Description := Item.Description;
                            "Replenishment System" := Item."Replenishment System";
                            "Location Code" := ''; // P8001030
                            "Variant Code" := '';  // P8001030
                            GetItemCosts();
                        end;
                    Type::"Work Center":
                        begin
                            WorkCtr.Get("No.");
                            Description := WorkCtr.Name;
                            GetWorkCtrCosts();
                        end;
                    Type::"Machine Center":
                        begin
                            MachCtr.Get("No.");
                            Description := MachCtr.Name;
                            GetMachCtrCosts();
                        end;
                    Type::Resource:
                        begin
                            Res.Get("No.");
                            Description := Res.Name;
                            GetResCosts();
                        end;
                end;
            end;
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(6; Implemented; Boolean)
        {
            Caption = 'Implemented';
            Editable = false;
        }
        field(7; "Replenishment System"; Enum "Replenishment System")
        {
            Caption = 'Replenishment System';
            Editable = false;
        }
        field(11; "Standard Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Standard Cost';
            Editable = false;
            MinValue = 0;
        }
        field(12; "New Standard Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'New Standard Cost';
            MinValue = 0;

            trigger OnValidate()
            begin
                if Type = Type::Item then
                    UpdateCostShares();
            end;
        }
        field(13; "Indirect Cost %"; Decimal)
        {
            Caption = 'Indirect Cost %';
            DecimalPlaces = 0 : 5;
            Editable = false;
            MinValue = 0;
        }
        field(14; "New Indirect Cost %"; Decimal)
        {
            Caption = 'New Indirect Cost %';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(15; "Overhead Rate"; Decimal)
        {
            Caption = 'Overhead Rate';
            DecimalPlaces = 2 : 5;
            Editable = false;
        }
        field(16; "New Overhead Rate"; Decimal)
        {
            Caption = 'New Overhead Rate';
            DecimalPlaces = 2 : 5;

            trigger OnValidate()
            begin
                if Type = Type::Resource then
                    TestField("New Overhead Rate", 0);
            end;
        }
        field(21; "Single-Lvl Material Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Single-Lvl Material Cost';
            Editable = false;
        }
        field(22; "New Single-Lvl Material Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'New Single-Lvl Material Cost';
            Editable = false;
        }
        field(23; "Single-Lvl Cap. Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Single-Lvl Cap. Cost';
            Editable = false;
        }
        field(24; "New Single-Lvl Cap. Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'New Single-Lvl Cap. Cost';
            Editable = false;
        }
        field(25; "Single-Lvl Subcontrd Cost"; Decimal)
        {
            AccessByPermission = TableData "Machine Center" = R;
            AutoFormatType = 2;
            Caption = 'Single-Lvl Subcontrd Cost';
            Editable = false;
        }
        field(26; "New Single-Lvl Subcontrd Cost"; Decimal)
        {
            AccessByPermission = TableData "Machine Center" = R;
            AutoFormatType = 2;
            Caption = 'New Single-Lvl Subcontrd Cost';
            Editable = false;
        }
        field(27; "Single-Lvl Cap. Ovhd Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Single-Lvl Cap. Ovhd Cost';
            Editable = false;
        }
        field(28; "New Single-Lvl Cap. Ovhd Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'New Single-Lvl Cap. Ovhd Cost';
            Editable = false;
        }
        field(29; "Single-Lvl Mfg. Ovhd Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Single-Lvl Mfg. Ovhd Cost';
            Editable = false;
        }
        field(30; "New Single-Lvl Mfg. Ovhd Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'New Single-Lvl Mfg. Ovhd Cost';
            Editable = false;
        }
        field(41; "Rolled-up Material Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Rolled-up Material Cost';
            Editable = false;
        }
        field(42; "New Rolled-up Material Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'New Rolled-up Material Cost';
            Editable = false;
        }
        field(43; "Rolled-up Cap. Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Rolled-up Cap. Cost';
            Editable = false;
        }
        field(44; "New Rolled-up Cap. Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'New Rolled-up Cap. Cost';
            Editable = false;
        }
        field(45; "Rolled-up Subcontrd Cost"; Decimal)
        {
            AccessByPermission = TableData "Machine Center" = R;
            AutoFormatType = 2;
            Caption = 'Rolled-up Subcontrd Cost';
            Editable = false;
        }
        field(46; "New Rolled-up Subcontrd Cost"; Decimal)
        {
            AccessByPermission = TableData "Machine Center" = R;
            AutoFormatType = 2;
            Caption = 'New Rolled-up Subcontrd Cost';
            Editable = false;
        }
        field(47; "Rolled-up Cap. Ovhd Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Rolled-up Cap. Ovhd Cost';
            Editable = false;
        }
        field(48; "New Rolled-up Cap. Ovhd Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'New Rolled-up Cap. Ovhd Cost';
            Editable = false;
        }
        field(49; "Rolled-up Mfg. Ovhd Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Rolled-up Mfg. Ovhd Cost';
            Editable = false;
        }
        field(50; "New Rolled-up Mfg. Ovhd Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'New Rolled-up Mfg. Ovhd Cost';
            Editable = false;
        }
        field(37002000; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = IF (Type = CONST(Item)) Location;

            trigger OnLookup()
            begin
                LookupSKU;
            end;

            trigger OnValidate()
            begin
                // P8001030
                TestField(Type, Type::Item);
                ValidateSKU;
            end;
        }
        field(37002001; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = IF (Type = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD("No."));

            trigger OnLookup()
            begin
                LookupSKU;
            end;

            trigger OnValidate()
            begin
                // P8001030
                TestField(Type, Type::Item);
                ValidateSKU;
            end;
        }
        field(37002002; SKU; Boolean)
        {
            Caption = 'SKU';
        }
    }

    keys
    {
        key(Key1; "Standard Cost Worksheet Name", Type, "No.", "Location Code", "Variant Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        StdCostWkshName.Get("Standard Cost Worksheet Name");
        CheckSKU; // P8001030
    end;

    trigger OnRename()
    begin
        CheckSKU; // P8001030
    end;

    var
        Item: Record Item;
        WorkCtr: Record "Work Center";
        MachCtr: Record "Machine Center";
        Res: Record Resource;
        StdCostWkshName: Record "Standard Cost Worksheet Name";
        Text37002000: Label '%1 %2, %3, %4 does not exist.';

    local procedure GetItemCosts()
    begin
        OnBeforeGetItemCosts(Rec, Item);

        "Standard Cost" := Item."Standard Cost";
        "New Standard Cost" := Item."Standard Cost";
        "Overhead Rate" := Item."Overhead Rate";
        "New Overhead Rate" := Item."Overhead Rate";
        "Indirect Cost %" := Item."Indirect Cost %";
        "New Indirect Cost %" := Item."Indirect Cost %";

        if Item.IsMfgItem() then
            TransferManufCostsFromItem()
        else
            TransferStandardCostFromItem();
    end;

    local procedure GetWorkCtrCosts()
    begin
        OnBeforeGetWorkCtrCosts(Rec, WorkCtr);

        "Standard Cost" := WorkCtr."Unit Cost";
        "New Standard Cost" := WorkCtr."Unit Cost";
        "Overhead Rate" := WorkCtr."Overhead Rate";
        "New Overhead Rate" := WorkCtr."Overhead Rate";
        "Indirect Cost %" := WorkCtr."Indirect Cost %";
        "New Indirect Cost %" := WorkCtr."Indirect Cost %";
    end;

    local procedure GetMachCtrCosts()
    begin
        OnBeforeGetMachCtrCosts(Rec, MachCtr);

        "Standard Cost" := MachCtr."Unit Cost";
        "New Standard Cost" := MachCtr."Unit Cost";
        "Overhead Rate" := MachCtr."Overhead Rate";
        "New Overhead Rate" := MachCtr."Overhead Rate";
        "Indirect Cost %" := MachCtr."Indirect Cost %";
        "New Indirect Cost %" := MachCtr."Indirect Cost %";
    end;

    local procedure GetResCosts()
    begin
        "Standard Cost" := Res."Unit Cost";
        "New Standard Cost" := Res."Unit Cost";
        "Overhead Rate" := 0;
        "New Overhead Rate" := 0;
        "Indirect Cost %" := Res."Indirect Cost %";
        "New Indirect Cost %" := Res."Indirect Cost %";
    end;

    local procedure UpdateCostShares()
    var
        Ratio: Decimal;
        RoundingResidual: Decimal;
    begin
        if xRec."New Standard Cost" <> 0 then
            Ratio := "New Standard Cost" / xRec."New Standard Cost";

        "New Single-Lvl Material Cost" := RoundAmt("New Single-Lvl Material Cost", Ratio);
        "New Single-Lvl Mfg. Ovhd Cost" := RoundAmt("New Single-Lvl Mfg. Ovhd Cost", Ratio);
        "New Single-Lvl Cap. Cost" := RoundAmt("New Single-Lvl Cap. Cost", Ratio);
        "New Single-Lvl Subcontrd Cost" := RoundAmt("New Single-Lvl Subcontrd Cost", Ratio);
        "New Single-Lvl Cap. Ovhd Cost" := RoundAmt("New Single-Lvl Cap. Ovhd Cost", Ratio);
        RoundingResidual := "New Standard Cost" -
          ("New Single-Lvl Material Cost" +
           "New Single-Lvl Mfg. Ovhd Cost" +
           "New Single-Lvl Cap. Cost" +
           "New Single-Lvl Subcontrd Cost" +
           "New Single-Lvl Cap. Ovhd Cost");
        "New Single-Lvl Material Cost" := "New Single-Lvl Material Cost" + RoundingResidual;

        "New Rolled-up Material Cost" := RoundAmt("New Rolled-up Material Cost", Ratio);
        "New Rolled-up Mfg. Ovhd Cost" := RoundAmt("New Rolled-up Mfg. Ovhd Cost", Ratio);
        "New Rolled-up Cap. Cost" := RoundAmt("New Rolled-up Cap. Cost", Ratio);
        "New Rolled-up Subcontrd Cost" := RoundAmt("New Rolled-up Subcontrd Cost", Ratio);
        "New Rolled-up Cap. Ovhd Cost" := RoundAmt("New Rolled-up Cap. Ovhd Cost", Ratio);
        RoundingResidual := "New Standard Cost" -
          ("New Rolled-up Material Cost" +
           "New Rolled-up Mfg. Ovhd Cost" +
           "New Rolled-up Cap. Cost" +
           "New Rolled-up Subcontrd Cost" +
           "New Rolled-up Cap. Ovhd Cost");
        "New Rolled-up Material Cost" := "New Rolled-up Material Cost" + RoundingResidual;

        OnAfterUpdateCostShares(Rec);
    end;

    local procedure RoundAmt(Amt: Decimal; AmtAdjustFactor: Decimal): Decimal
    begin
        exit(Round(Amt * AmtAdjustFactor, 0.00001));
    end;

    local procedure TransferManufCostsFromItem()
    begin
        "Single-Lvl Material Cost" := Item."Single-Level Material Cost";
        "New Single-Lvl Material Cost" := Item."Single-Level Material Cost";
        "Single-Lvl Cap. Cost" := Item."Single-Level Capacity Cost";
        "New Single-Lvl Cap. Cost" := Item."Single-Level Capacity Cost";
        "Single-Lvl Subcontrd Cost" := Item."Single-Level Subcontrd. Cost";
        "New Single-Lvl Subcontrd Cost" := Item."Single-Level Subcontrd. Cost";
        "Single-Lvl Cap. Ovhd Cost" := Item."Single-Level Cap. Ovhd Cost";
        "New Single-Lvl Cap. Ovhd Cost" := Item."Single-Level Cap. Ovhd Cost";
        "Single-Lvl Mfg. Ovhd Cost" := Item."Single-Level Mfg. Ovhd Cost";
        "New Single-Lvl Mfg. Ovhd Cost" := Item."Single-Level Mfg. Ovhd Cost";

        "Rolled-up Material Cost" := Item."Rolled-up Material Cost";
        "New Rolled-up Material Cost" := Item."Rolled-up Material Cost";
        "Rolled-up Cap. Cost" := Item."Rolled-up Capacity Cost";
        "New Rolled-up Cap. Cost" := Item."Rolled-up Capacity Cost";
        "Rolled-up Subcontrd Cost" := Item."Rolled-up Subcontracted Cost";
        "New Rolled-up Subcontrd Cost" := Item."Rolled-up Subcontracted Cost";
        "Rolled-up Cap. Ovhd Cost" := Item."Rolled-up Cap. Overhead Cost";
        "New Rolled-up Cap. Ovhd Cost" := Item."Rolled-up Cap. Overhead Cost";
        "Rolled-up Mfg. Ovhd Cost" := Item."Rolled-up Mfg. Ovhd Cost";
        "New Rolled-up Mfg. Ovhd Cost" := Item."Rolled-up Mfg. Ovhd Cost";

        OnAfterTransferManufCostsFromItem(Rec, Item);
    end;

    local procedure TransferStandardCostFromItem()
    begin
        "Single-Lvl Material Cost" := Item."Standard Cost";
        "New Single-Lvl Material Cost" := Item."Standard Cost";
        "Single-Lvl Cap. Cost" := 0;
        "New Single-Lvl Cap. Cost" := 0;
        "Single-Lvl Subcontrd Cost" := 0;
        "New Single-Lvl Subcontrd Cost" := 0;
        "Single-Lvl Cap. Ovhd Cost" := 0;
        "New Single-Lvl Cap. Ovhd Cost" := 0;
        "Single-Lvl Mfg. Ovhd Cost" := 0;
        "New Single-Lvl Mfg. Ovhd Cost" := 0;

        "Rolled-up Material Cost" := Item."Standard Cost";
        "New Rolled-up Material Cost" := Item."Standard Cost";
        "Rolled-up Cap. Cost" := 0;
        "New Rolled-up Cap. Cost" := 0;
        "Rolled-up Subcontrd Cost" := 0;
        "New Rolled-up Subcontrd Cost" := 0;
        "Rolled-up Cap. Ovhd Cost" := 0;
        "New Rolled-up Cap. Ovhd Cost" := 0;
        "Rolled-up Mfg. Ovhd Cost" := 0;
        "New Rolled-up Mfg. Ovhd Cost" := 0;

        OnAfterTransferStandardCostFromItem(Rec, Item);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateCostShares(var StandardCostWorksheet: Record "Standard Cost Worksheet")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferManufCostsFromItem(var StandardCostWorksheet: Record "Standard Cost Worksheet"; Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferStandardCostFromItem(var StandardCostWorksheet: Record "Standard Cost Worksheet"; Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetItemCosts(var StandardCostWorksheet: Record "Standard Cost Worksheet"; var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetWorkCtrCosts(var StandardCostWorksheet: Record "Standard Cost Worksheet"; var WorkCenter: Record "Work Center")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetMachCtrCosts(var StandardCostWorksheet: Record "Standard Cost Worksheet"; var MachineCenter: Record "Machine Center")
    begin
    end;
    
    procedure LookupSKU()
    var
        SKU: Record "Stockkeeping Unit";
        SKUList: Page "Stockkeeping Unit List";
    begin
        // P8001030
        if (Type <> Type::Item) or ("No." = '') then
            exit;

        SKU.FilterGroup(2);
        SKU.SetCurrentKey("Item No.");
        SKU.SetRange("Item No.", "No.");
        SKU.FilterGroup(2);
        if SKU.IsEmpty then
            exit;

        SKUList.SetTableView(SKU);
        SKUList.LookupMode(true);
        if SKUList.RunModal = ACTION::LookupOK then begin
            SKUList.GetRecord(SKU);
            "Location Code" := SKU."Location Code";
            "Variant Code" := SKU."Variant Code";
            GetSKUFields(SKU);
            Rec.SKU := true;
        end;
    end;

    procedure ValidateSKU()
    var
        SKU: Record "Stockkeeping Unit";
        TempStdCostWksh: Record "Standard Cost Worksheet";
    begin
        // P801030
        // P8008734
        TempStdCostWksh := Rec;
        Init;
        Type := TempStdCostWksh.Type;
        "No." := TempStdCostWksh."No.";
        "Location Code" := TempStdCostWksh."Location Code";
        "Variant Code" := TempStdCostWksh."Variant Code";
        // P8008734

        if ("Location Code" = '') and ("Variant Code" = '') then begin
            Item.Get("No.");
            "Replenishment System" := Item."Replenishment System";
            GetItemCosts;
            Rec.SKU := false;
        end else begin
            Rec.SKU := SKU.Get("Location Code", "No.", "Variant Code");
            GetSKUFields(SKU);
        end;
    end;

    procedure CheckSKU()
    var
        SKU: Record "Stockkeeping Unit";
    begin
        // P8001030
        if (Type = Type::Item) and (("Location Code" <> '') or ("Variant Code" <> '')) and (not Rec.SKU) then
            Error(Text37002000, SKU.TableCaption, "No.", "Location Code", "Variant Code");
    end;

    procedure GetSKUFields(SKU: Record "Stockkeeping Unit")
    begin
        // P8001030
        // P8001262
        if Item."No." <> "No." then
            Item.Get("No.");
        Description := Item.Description;
        // P8001262
        "Replenishment System" := SKU."Replenishment System";

        "Standard Cost" := SKU."Standard Cost";
        "New Standard Cost" := SKU."Standard Cost";
        "Overhead Rate" := SKU."Overhead Rate";
        "New Overhead Rate" := SKU."Overhead Rate";
        "Indirect Cost %" := SKU."Indirect Cost %";
        "New Indirect Cost %" := SKU."Indirect Cost %";

        "Single-Lvl Material Cost" := SKU."Single-Level Material Cost";
        "New Single-Lvl Material Cost" := SKU."Single-Level Material Cost";
        "Single-Lvl Cap. Cost" := SKU."Single-Level Capacity Cost";
        "New Single-Lvl Cap. Cost" := SKU."Single-Level Capacity Cost";
        "Single-Lvl Subcontrd Cost" := SKU."Single-Level Subcontrd. Cost";
        "Single-Lvl Subcontrd Cost" := SKU."Single-Level Subcontrd. Cost";
        "Single-Lvl Cap. Ovhd Cost" := SKU."Single-Level Cap. Ovhd Cost";
        "New Single-Lvl Cap. Ovhd Cost" := SKU."Single-Level Cap. Ovhd Cost";
        "Single-Lvl Mfg. Ovhd Cost" := SKU."Single-Level Mfg. Ovhd Cost";
        "New Single-Lvl Mfg. Ovhd Cost" := SKU."Single-Level Mfg. Ovhd Cost";

        "Rolled-up Material Cost" := SKU."Rolled-up Material Cost";
        "New Rolled-up Material Cost" := SKU."Rolled-up Material Cost";
        "Rolled-up Cap. Cost" := SKU."Rolled-up Capacity Cost";
        "New Rolled-up Cap. Cost" := SKU."Rolled-up Capacity Cost";
        "Rolled-up Subcontrd Cost" := SKU."Rolled-up Subcontracted Cost";
        "New Rolled-up Subcontrd Cost" := SKU."Rolled-up Subcontracted Cost";
        "Rolled-up Cap. Ovhd Cost" := SKU."Rolled-up Cap. Overhead Cost";
        "New Rolled-up Cap. Ovhd Cost" := SKU."Rolled-up Cap. Overhead Cost";
        "Rolled-up Mfg. Ovhd Cost" := SKU."Rolled-up Mfg. Ovhd Cost";
        "New Rolled-up Mfg. Ovhd Cost" := SKU."Rolled-up Mfg. Ovhd Cost";
    end;    
}

