table 37002578 "Container Type"
{
    // P8001373, To-Increase, Dayakar Battini, 11 Feb 15
    //   Support containers for purchase returns.
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    //   Correct misspellings
    // 
    // PRW111.00.01
    // P80062661, To-Increase, Jack Reynolds, 25 JUL 18
    //   SSCC
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Container Type';
    DataCaptionFields = "Code", Description;
    DrillDownPageID = "Container Types";
    LookupPageID = "Container Types";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Maintain Inventory Value"; Boolean)
        {
            Caption = 'Maintain Inventory Value';

            trigger OnValidate()
            begin
                if "Maintain Inventory Value" then
                    TestField("Container Item No.");

                if ("Container Item No." <> '') then begin
                    Item.Get("Container Item No.");
                    if (Item.Type <> GetItemType()) then begin
                        Item.Validate(Type, GetItemType());
                        Item.Modify(true);
                    end;
                end;
            end;
        }
        field(4; "Container Item No."; Code[20])
        {
            Caption = 'Container Item No.';
            TableRelation = Item WHERE("Item Type" = CONST(Container),
                                        Type = FILTER(Inventory | FOODContainer),
                                        "Non-Warehouse Item" = CONST(true));

            trigger OnValidate()
            begin
                if "Container Item No." = xRec."Container Item No." then
                    exit;

                if ("Container Item No." = '') then begin
                    "Maintain Inventory Value" := false;
                    Validate("Container Sales Processing", 0);
                    Validate("Container Purchase Processing", 0); // P8001373
                end else begin
                    Item.Get("Container Item No.");
                    Item.TestField("Item Type", Item."Item Type"::Container);
                    Item.TestField("Non-Warehouse Item", true);
                    "Maintain Inventory Value" := (Item.Type = Item.Type::Inventory);
                    if IsSerializable then begin
                        if "Container Sales Processing" <> "Container Sales Processing"::Transfer then
                            Validate("Container Sales Processing", "Container Sales Processing"::Transfer);
                        if "Container Purchase Processing" <> "Container Purchase Processing"::Transfer then
                            Validate("Container Purchase Processing", "Container Purchase Processing"::Transfer);
                    end else begin
                        if "Container Sales Processing" = "Container Sales Processing"::Transfer then
                            Validate("Container Sales Processing", "Container Sales Processing"::Adjustment);
                        if "Container Purchase Processing" = "Container Purchase Processing"::Transfer then
                            Validate("Container Purchase Processing", "Container Purchase Processing"::Adjustment);
                    end;
                end;
            end;
        }
        field(5; "Setup Level"; Option)
        {
            Caption = 'Setup Level';
            OptionCaption = 'All,Item Category,,Specific';
            OptionMembers = All,"Item Category",,Specific;

            trigger OnValidate()
            begin
                if ("Setup Level" <> xRec."Setup Level") then begin
                    ContTypeUsage.Reset;
                    ContTypeUsage.SetRange("Container Type Code", Code);
                    ContTypeUsage.SetFilter("Item Type", '<%1', "Setup Level");
                    if ContTypeUsage.FindFirst then
                        ContTypeUsage.FieldError("Item Type");
                end;
            end;
        }
        field(7; "Container Sales Processing"; Option)
        {
            Caption = 'Container Sales Processing';
            OptionCaption = 'Adjustment,Transfer,Sale';
            OptionMembers = Adjustment,Transfer,Sale;

            trigger OnValidate()
            var
                SalesLine: Record "Sales Line";
            begin
                if "Container Sales Processing" <> xRec."Container Sales Processing" then begin
                    if IsSerializable then begin
                        if "Container Sales Processing" <> "Container Sales Processing"::Transfer then
                            Error(Text004);
                    end else begin
                        if "Container Sales Processing" = "Container Sales Processing"::Transfer then
                            Error(Text005);
                    end;

                    SalesLine.SetCurrentKey(Type, "No.");
                    SalesLine.SetRange(Type, SalesLine.Type::FOODContainer);
                    SalesLine.SetRange("No.", "Container Item No.");
                    if not SalesLine.IsEmpty then
                        Error(Text000, FieldCaption("Container Sales Processing"), SalesLine.TableCaption);
                end;
            end;
        }
        field(8; "Tare Weight"; Decimal)
        {
            BlankZero = true;
            Caption = 'Tare Weight';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                if "Tare Weight" = 0 then
                    "Tare Unit of Measure" := ''
                else
                    if "Tare Unit of Measure" = '' then
                        "Tare Unit of Measure" := P800UOMFns.DefaultUOM(2);
            end;
        }
        field(9; "Tare Unit of Measure"; Code[10])
        {
            Caption = 'Tare Unit of Measure';
            TableRelation = "Unit of Measure" WHERE(Type = CONST(Weight));

            trigger OnValidate()
            begin
                if "Tare Unit of Measure" = '' then
                    TestField("Tare Weight", 0);
            end;
        }
        field(10; Capacity; Decimal)
        {
            BlankZero = true;
            Caption = 'Capacity';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                if Capacity = 0 then
                    "Capacity Unit of Measure" := '';
            end;
        }
        field(11; "Capacity Unit of Measure"; Code[10])
        {
            Caption = 'Capacity Unit of Measure';
            TableRelation = "Unit of Measure";
        }
        field(12; "No. of Labels"; Integer)
        {
            Caption = 'No. of Labels';
            InitValue = 1;
            MinValue = 0;
        }
        field(13; "Container Purchase Processing"; Option)
        {
            Caption = 'Container Purchase Processing';
            OptionCaption = 'Adjustment,Transfer,Purchase';
            OptionMembers = Adjustment,Transfer,Purchase;

            trigger OnValidate()
            var
                PurchLine: Record "Purchase Line";
            begin
                //P8001373
                if "Container Purchase Processing" <> xRec."Container Purchase Processing" then begin
                    if IsSerializable then begin
                        if "Container Purchase Processing" <> "Container Purchase Processing"::Transfer then
                            Error(Text004);
                    end else begin
                        if "Container Purchase Processing" = "Container Purchase Processing"::Transfer then
                            Error(Text005);
                    end;

                    PurchLine.SetCurrentKey(Type, "No.");
                    PurchLine.SetRange(Type, PurchLine.Type::FOODContainer);
                    PurchLine.SetRange("No.", "Container Item No.");
                    if not PurchLine.IsEmpty then
                        Error(Text000, FieldCaption("Container Purchase Processing"), PurchLine.TableCaption);
                end;
            end;
        }
        field(14; "Default Cont. License Plate"; Option)
        {
            Caption = 'Default Container License Plate';
            OptionCaption = 'SSCC,Serial No.';
            OptionMembers = SSCC,"Serial No.";
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        ContainerHeader.SetRange("Container Type Code", Code);
        if not ContainerHeader.IsEmpty then
            Error(Text003, TableCaption, Code);

        ContTypeUsage.Reset;
        ContTypeUsage.SetRange("Container Type Code", Code);
        ContTypeUsage.DeleteAll;

        ContainerTypeCharge.Reset;
        ContainerTypeCharge.SetRange("Container Type Code", Code);
        ContainerTypeCharge.DeleteAll;

        // P8001322
        LabelSelection.SetRange("Source Type", DATABASE::"Container Type");
        LabelSelection.SetRange("Source No.", Code);
        LabelSelection.DeleteAll;
        // P8001322
    end;

    var
        InvtSetup: Record "Inventory Setup";
        Item: Record Item;
        ContainerHeader: Record "Container Header";
        ContTypeUsage: Record "Container Type Usage";
        ContainerTypeCharge: Record "Container Type Charge";
        LabelSelection: Record "Label Selection";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        P800UOMFns: Codeunit "Process 800 UOM Functions";
        Text000: Label '%1 cannot be changed with open %2 records.';
        Text001: Label '&Use Item %1,Create &New Item';
        Text002: Label '&Create Item %1,Create &New Item';
        HasInvtSetup: Boolean;
        Text003: Label '%1 %2 cannot be deleted with open containers.';
        Text004: Label 'Serialized containers must be transferred.';
        Text005: Label 'Container Type must be serialized.';

    local procedure GetInvtSetup()
    begin
        if not HasInvtSetup then begin
            InvtSetup.Get;
            HasInvtSetup := true;
        end;
    end;

    procedure GetItemType(): Integer
    begin
        if "Maintain Inventory Value" then
            exit(Item.Type::Inventory);
        exit(Item.Type::FOODContainer);
    end;

    procedure TrackInventory(): Boolean
    begin
        exit("Container Item No." <> '');
    end;

    procedure IsSerializable(): Boolean
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        if ("Container Item No." <> '') and Item.Get("Container Item No.") then
            if (Item."Item Tracking Code" <> '') and ItemTrackingCode.Get(Item."Item Tracking Code") then
                exit(ItemTrackingCode."SN Specific Tracking");
    end;

    procedure ItemAssistEdit(): Boolean
    var
        Item2: Record Item;
        Selection: Integer;
    begin
        if ("Container Item No." <> '') then begin
            Item2.FilterGroup(2);
            Item2.SetRange("No.", "Container Item No.");
            Item2.FilterGroup(0);
            PAGE.RunModal(PAGE::"Item Card", Item2);
        end else begin
            if Item2.Get(Code) then
                Selection := StrMenu(StrSubstNo(Text001, Code), 1)
            else
                Selection := StrMenu(StrSubstNo(Text002, Code), 1);
            if (Selection = 0) then
                exit(false);
            case Selection of
                1:
                    if (Item2."No." = '') then
                        CreateItem(Code, Item2)
                    else begin
                        Item2.TestField("Item Type", Item2."Item Type"::Container);
                        Item2.TestField("Non-Warehouse Item", true);
                    end;
                2:
                    CreateItem('', Item2);
            end;
            Validate("Container Item No.", Item2."No.");
            exit(true);
        end;
    end;

    local procedure CreateItem(NewItemNo: Code[20]; var Item2: Record Item)
    begin
        Item2.Init;
        Item2.Validate("No.", NewItemNo);
        Item2.Insert(true);

        Item2.Validate(Description, Description);
        Item2.Validate(Type, GetItemType());
        Item2.Validate("Item Type", Item2."Item Type"::Container);
        Item2.Validate("Non-Warehouse Item", true);
        Item2.Modify(true);
    end;
}

