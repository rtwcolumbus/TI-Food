table 37002121 "Accrual Plan Line"
{
    // PR3.61AC
    // 
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PR4.00.04
    // P8000355A, VerticalSoft, Jack Reynolds, 19 JUL 06
    //   Add support for accrual groups
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 05 NOV 09
    //   Use AutoFormatType and AutoFormatExpr properties
    // 
    // PRW16.00.04
    // P8000882, VerticalSoft, Ron Davidson, 19 NOV 10
    //   Added new field called Manual Entry for the users to check if they don't want the Batch Update process to remove this line.
    // 
    // PRW16.00.06
    // P8001058, Columbus IT, Jack Reynolds, 17 APR 12
    //   Fix problem with unexplained mass changes to Computation UOM
    // 
    // PRW17.00.01
    // P8001203, Columbus IT, Jack Reynolds, 28 AUG 13
    //   Fix problem with item description on new lines
    //
    // PRW115.00.03
    // P800127796, To Increase, Gangabhushan, 13 AUG 21
    //   CS00177725 | Promo/Rebate with Multiplier Type of Percentage does not respect the UOM setup

    Caption = 'Accrual Plan Line';

    fields
    {
        field(1; "Accrual Plan Type"; Option)
        {
            Caption = 'Accrual Plan Type';
            OptionCaption = 'Sales,Purchase';
            OptionMembers = Sales,Purchase;
        }
        field(2; "Accrual Plan No."; Code[20])
        {
            Caption = 'Accrual Plan No.';
            TableRelation = "Accrual Plan"."No." WHERE(Type = FIELD("Accrual Plan Type"));
        }
        field(3; "Minimum Value"; Decimal)
        {
            AutoFormatExpression = AutoFormatMinValue;
            AutoFormatType = 37002000;
            Caption = 'Minimum Value';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                if IsQuantityMinimumValueType() then
                    if ("Reference Value" = "Reference Value"::Quantity) then
                        Validate("Over Reference Value", "Minimum Value")
                    else
                        Validate("Over Reference Value", 0)
                else
                    if ("Reference Value" = "Reference Value"::Price) then
                        Validate("Over Reference Value", "Minimum Value")
                    else
                        Validate("Over Reference Value", 0);
            end;
        }
        field(4; "Accrual Amount"; Decimal)
        {
            Caption = 'Accrual Amount';
        }
        field(5; "Reference Value"; Option)
        {
            Caption = 'Reference Value';
            OptionCaption = 'Price,Cost,Profit,Quantity';
            OptionMembers = Price,Cost,Profit,Quantity;

            trigger OnValidate()
            begin
                if ("Reference Value" <> xRec."Reference Value") then begin
                    if ("Reference Value" in ["Reference Value"::Price, "Reference Value"::Profit]) then
                        TestField("Accrual Plan Type", "Accrual Plan Type"::Sales);
                    if ("Reference Value" <> "Reference Value"::Quantity) then
                        Validate("Multiplier Type", "Multiplier Type"::Percentage)
                    else
                        Validate("Multiplier Type", "Multiplier Type"::"Unit Amount");
                    Validate("Minimum Value");
                end;
            end;
        }
        field(6; "Multiplier Type"; Option)
        {
            Caption = 'Multiplier Type';
            OptionCaption = 'Percentage,Unit Amount';
            OptionMembers = Percentage,"Unit Amount";

            trigger OnValidate()
            begin
                if ("Multiplier Type" <> xRec."Multiplier Type") then begin
                    // P800127796
                    if "Multiplier Type" = "Multiplier Type"::Percentage then begin
                        if "Reference Value" = "Reference Value"::Quantity then
                            "Reference Value" := "Reference Value"::Price;
                    end else begin
                        "Reference Value" := "Reference Value"::Quantity;
                        if "Computation UOM" = '' then
                            "Computation UOM" := GetHeaderCompUOM("Accrual Plan Type", "Accrual Plan No.");
                    end;
                    // P800127796
                    Validate("Multiplier Value", 0);
                    Validate("Estimated Ref. Unit Amount", 0);
                end;
            end;
        }
        field(7; "Multiplier Value"; Decimal)
        {
            AutoFormatExpression = AutoFormatMultValue;
            AutoFormatType = 37002000;
            Caption = 'Multiplier Value';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                SetEstimatedAmount;
            end;
        }
        field(8; "Over Reference Value"; Decimal)
        {
            AutoFormatExpression = AutoFormatOverRefValue;
            AutoFormatType = 37002000;
            Caption = 'Over Reference Value';
            DecimalPlaces = 0 : 5;
        }
        field(9; "Item Selection"; Option)
        {
            Caption = 'Item Selection';
            Editable = false;
            OptionCaption = 'All Items,Specific Item,Item Category,Manufacturer,Vendor No.,Item Group';
            OptionMembers = "All Items","Specific Item","Item Category",Manufacturer,"Vendor No.","Accrual Group";
        }
        field(10; "Item Code"; Code[20])
        {
            Caption = 'Item Code';
            TableRelation = IF ("Item Selection" = CONST("Specific Item")) Item
            ELSE
            IF ("Item Selection" = CONST("Item Category")) "Item Category"
            ELSE
            IF ("Item Selection" = CONST(Manufacturer)) Manufacturer
            ELSE
            IF ("Item Selection" = CONST("Vendor No.")) Vendor
            ELSE
            IF ("Item Selection" = CONST("Accrual Group")) "Accrual Group".Code WHERE(Type = CONST(Item));

            trigger OnValidate()
            var
                OtherItemLine: Record "Accrual Plan Line";
            begin
                if ("Item Selection" = "Item Selection"::"All Items") then
                    TestField("Item Code", '');

                // P8000355A
                if "Item Selection" = "Item Selection"::"Accrual Group" then begin
                    OtherItemLine.SetRange("Accrual Plan Type", "Accrual Plan Type");
                    OtherItemLine.SetRange("Accrual Plan No.", "Accrual Plan No.");
                    OtherItemLine.SetFilter("Item Code", '<>%1', "Item Code");
                    if OtherItemLine.Find('-') then
                        Error(Text001, FieldCaption("Item Code"), OtherItemLine."Item Code");
                end;
                // P8000355A

                if ("Item Code" <> xRec."Item Code") then begin
                    SetUnitOfMeasure;
                    CopyFromOtherItemLines;
                end;
            end;
        }
        field(11; "Start Date"; Date)
        {
            Caption = 'Start Date';

            trigger OnValidate()
            begin
                if ("End Date" <> 0D) and ("Start Date" > "End Date") then
                    Error(Text000, FieldCaption("Start Date"), FieldCaption("End Date"));
            end;
        }
        field(12; "End Date"; Date)
        {
            Caption = 'End Date';

            trigger OnValidate()
            begin
                if ("End Date" <> 0D) and ("Start Date" > "End Date") then
                    Error(Text000, FieldCaption("Start Date"), FieldCaption("End Date"));
            end;
        }
        field(13; "Computation UOM"; Code[10])
        {
            Caption = 'Computation UOM';
            TableRelation = IF ("Item Selection" = CONST("Specific Item")) "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item Code"))
            ELSE
            "Unit of Measure";
            // P800127796
            trigger OnValidate()
            begin
                if "Computation UOM" <> xRec."Computation UOM" then
                    if "Computation UOM" = '' then
                        "Computation UOM" := GetHeaderCompUOM("Accrual Plan Type", "Accrual Plan No.");
            end;
            // P800127796
        }
        field(14; "Estimated Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Estimated Quantity';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                SetEstimatedAmount;
            end;
        }
        field(15; "Estimated Ref. Unit Amount"; Decimal)
        {
            BlankZero = true;
            Caption = 'Estimated Ref. Unit Amount';
            DecimalPlaces = 2 : 5;

            trigger OnValidate()
            begin
                if ("Estimated Ref. Unit Amount" <> 0) then
                    TestField("Multiplier Type", "Multiplier Type"::Percentage);
                SetEstimatedAmount;
            end;
        }
        field(16; "Estimated Accrual Amount"; Decimal)
        {
            Caption = 'Estimated Accrual Amount';
            Editable = false;
        }
        field(17; "Manual Entry"; Boolean)
        {
            Caption = 'Manual Entry';
        }
    }

    keys
    {
        key(Key1; "Accrual Plan Type", "Accrual Plan No.", "Item Code", "Minimum Value")
        {
            SumIndexFields = "Estimated Accrual Amount";
        }
        key(Key2; "Item Selection", "Item Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        SearchMgmt.DeletePlanLine(Rec);
    end;

    trigger OnInsert()
    begin
        SearchMgmt.InsertPlanLine(Rec);

        CopyToOtherItemLines;
    end;

    trigger OnModify()
    begin
        SearchMgmt.ModifyPlanLine(Rec, xRec);

        if ("Start Date" <> xRec."Start Date") or
           ("End Date" <> xRec."End Date") or
           ("Computation UOM" <> xRec."Computation UOM")
        then
            CopyToOtherItemLines;
    end;

    trigger OnRename()
    begin
        SearchMgmt.DeletePlanLine(xRec);
        SearchMgmt.InsertPlanLine(Rec);
    end;

    var
        AccrualPlan: Record "Accrual Plan";
        SearchMgmt: Codeunit "Accrual Search Management";
        Text000: Label '%1 is after %2.';
        Text001: Label '%1 must be %2.';

    local procedure SetUnitOfMeasure()
    var
        Item: Record Item;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        if ("Item Selection" = "Item Selection"::"Specific Item") and ("Item Code" <> '') then begin
            AccrualPlan.Get("Accrual Plan Type", "Accrual Plan No.");
            Item.Get("Item Code");
            if ItemUnitOfMeasure.Get("Item Code", AccrualPlan."Computation UOM") then
                Validate("Computation UOM", AccrualPlan."Computation UOM")
            else
                if (AccrualPlan."Computation Level" = AccrualPlan."Computation Level"::Document) then
                    Validate("Computation UOM", '')
                else
                    if Item.CostInAlternateUnits() then
                        Validate("Computation UOM", Item."Alternate Unit of Measure")
                    else
                        Validate("Computation UOM", Item."Base Unit of Measure");
        end;
    end;

    procedure OtherItemLinesExist(): Boolean
    var
        OtherItemLine: Record "Accrual Plan Line";
    begin
        OtherItemLine.SetRange("Accrual Plan Type", "Accrual Plan Type");
        OtherItemLine.SetRange("Accrual Plan No.", "Accrual Plan No.");
        OtherItemLine.SetRange("Item Code", "Item Code");
        OtherItemLine.SetFilter("Minimum Value", '<>%1', "Minimum Value");
        exit(OtherItemLine.Find('-'));
    end;

    local procedure CopyToOtherItemLines()
    var
        OtherItemLine: Record "Accrual Plan Line";
    begin
        OtherItemLine.SetRange("Accrual Plan Type", "Accrual Plan Type");
        OtherItemLine.SetRange("Accrual Plan No.", "Accrual Plan No.");
        OtherItemLine.SetRange("Item Code", "Item Code");
        OtherItemLine.SetFilter("Minimum Value", '<>%1', "Minimum Value");
        if OtherItemLine.Find('-') then
            repeat
                OtherItemLine."Start Date" := "Start Date";
                OtherItemLine."End Date" := "End Date";
                OtherItemLine."Computation UOM" := "Computation UOM";
                OtherItemLine.Modify;
            until (OtherItemLine.Next = 0);
    end;

    local procedure CopyFromOtherItemLines()
    var
        OtherItemLine: Record "Accrual Plan Line";
    begin
        OtherItemLine.SetRange("Accrual Plan Type", "Accrual Plan Type");
        OtherItemLine.SetRange("Accrual Plan No.", "Accrual Plan No.");
        OtherItemLine.SetRange("Item Code", "Item Code");
        if OtherItemLine.Find('-') then begin
            "Start Date" := OtherItemLine."Start Date";
            "End Date" := OtherItemLine."End Date";
            "Computation UOM" := OtherItemLine."Computation UOM";
        end;
    end;

    local procedure SetEstimatedAmount()
    begin
        case "Multiplier Type" of
            "Multiplier Type"::"Unit Amount":
                "Estimated Accrual Amount" :=
                  Round("Estimated Quantity" * "Multiplier Value", 0.01);
            "Multiplier Type"::Percentage:
                "Estimated Accrual Amount" :=
                  Round("Estimated Quantity" * "Estimated Ref. Unit Amount" * "Multiplier Value" / 100, 0.01);
        end;
    end;

    procedure IsQuantityMinimumValueType(): Boolean
    begin
        if not AccrualPlan.Get("Accrual Plan Type", "Accrual Plan No.") then
            exit(false);
        exit(AccrualPlan."Minimum Value Type" = AccrualPlan."Minimum Value Type"::Quantity);
    end;

    procedure SetUpNewLine(LastPlanLine: Record "Accrual Plan Line")
    var
        OtherItemLine: Record "Accrual Plan Line";
    begin
        if AccrualPlan.Get("Accrual Plan Type", "Accrual Plan No.") then begin
            Validate("Item Selection", AccrualPlan."Item Selection");
            // P8000355A
            if "Item Selection" = "Item Selection"::"Accrual Group" then begin
                OtherItemLine.SetRange("Accrual Plan Type", "Accrual Plan Type");
                OtherItemLine.SetRange("Accrual Plan No.", "Accrual Plan No.");
                if OtherItemLine.Find('-') then
                    Validate("Item Code", OtherItemLine."Item Code");
            end;
            // P8000355A
            //VALIDATE("Computation UOM", AccrualPlan."Computation UOM"); // P8001203
        end;

        if IsQuantityMinimumValueType() then
            Validate("Reference Value", "Reference Value"::Quantity)
        else
            if ("Accrual Plan Type" = "Accrual Plan Type"::Purchase) then
                Validate("Reference Value", "Reference Value"::Cost);
    end;

    procedure GetLineDescription(): Text[250]
    var
        Item: Record Item;
        ItemCategory: Record "Item Category";
        Manufacturer: Record Manufacturer;
        Vendor: Record Vendor;
        AccrualGroup: Record "Accrual Group";
    begin
        if ("Item Selection" = "Item Selection"::"All Items") then
            exit(Format("Item Selection"));
        if ("Item Code" = '') then
            exit('');

        case "Item Selection" of
            "Item Selection"::"Specific Item":
                if Item.Get("Item Code") then
                    exit(Item.Description);
            "Item Selection"::"Item Category":
                if ItemCategory.Get("Item Code") then
                    exit(ItemCategory.Description);
            "Item Selection"::Manufacturer:
                if Manufacturer.Get("Item Code") then
                    exit(Manufacturer.Name);
            "Item Selection"::"Vendor No.":
                if Vendor.Get("Item Code") then
                    exit(Vendor.Name);
            // P8000355A
            "Item Selection"::"Accrual Group":
                if AccrualGroup.Get(AccrualGroup.Type::Item, "Item Code") then
                    exit(AccrualGroup.Description);
                // P8000355A
        end;
        exit(StrSubstNo('%1 - %2', "Item Selection", "Item Code"));
    end;

    procedure AutoFormatMinValue(): Text[10]
    begin
        //P8000664
        if IsQuantityMinimumValueType() then
            exit('0:5')
        else
            exit('2:5');
    end;

    procedure AutoFormatMultValue(): Text[10]
    begin
        //P8000664
        if ("Multiplier Type" = "Multiplier Type"::Percentage) then
            exit('0:5')
        else
            exit('2:5');
    end;

    procedure AutoFormatOverRefValue(): Text[10]
    begin
        //P8000664
        if ("Reference Value" = "Reference Value"::Quantity) then
            exit('0:5')
        else
            exit('2:2');
    end;

    local procedure GetHeaderCompUOM(PlanType: Option Sales,Purchase; PlanNo: Code[20]): Code[10]
    var
        AccrualPlan: Record "Accrual Plan";
    begin
        // P800127796
        AccrualPlan.Get(PlanType, PlanNo);
        exit(AccrualPlan."Computation UOM");
    end;
}

