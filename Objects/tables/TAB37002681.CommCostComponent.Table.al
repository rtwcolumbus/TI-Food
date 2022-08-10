table 37002681 "Comm. Cost Component"
{
    // PRW16.00.04
    // P8000856, VerticalSoft, Don Bresee, 24 AUG 10
    //   Add Commodity Class Costing granule
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Comm. Cost Component';
    DataCaptionFields = Description;
    LookupPageID = "Comm. Cost Components";

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
        field(3; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Unit of Measure";

            trigger OnValidate()
            begin
                ValidateUOM;
            end;
        }
        field(4; "Q/C Test Type"; Code[10])
        {
            Caption = 'Q/C Test Type';
            TableRelation = "Data Collection Data Element" WHERE(Type = CONST(Numeric));

            trigger OnValidate()
            begin
                if ("Q/C Test Type" <> '') then
                    "Q/C Test Result Handling" := "Q/C Test Result Handling"::None;
            end;
        }
        field(5; "Q/C Test Result Handling"; Option)
        {
            Caption = 'Q/C Test Result Handling';
            OptionCaption = 'None,Percentage';
            OptionMembers = "None",Percentage;

            trigger OnValidate()
            begin
                if ("Q/C Test Result Handling" <> "Q/C Test Result Handling"::None) then
                    TestField("Q/C Test Type");
            end;
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
        CommCostSetup.SetCurrentKey("Comm. Cost Component Code");
        CommCostSetup.SetRange("Comm. Cost Component Code", Code);
        CommCostSetup.DeleteAll(true);
    end;

    var
        CommCostSetup: Record "Comm. Cost Setup Line";

    local procedure ValidateUOM()
    var
        InvtSetup: Record "Inventory Setup";
        UOM: Record "Unit of Measure";
    begin
        if ("Unit of Measure Code" <> '') then begin
            UOM.SetFilter(Code, "Unit of Measure Code" + '*');
            InvtSetup.Get;
            case InvtSetup."Commodity UOM Type" of
                InvtSetup."Commodity UOM Type"::Weight:
                    UOM.SetRange(Type, UOM.Type::Weight);
                InvtSetup."Commodity UOM Type"::Volume:
                    UOM.SetRange(Type, UOM.Type::Volume);
            end;
            if UOM.IsEmpty then begin
                UOM.Get("Unit of Measure Code");
                UOM.FieldError(Type);
            end;
            UOM.FindFirst;
            "Unit of Measure Code" := UOM.Code;
        end;
    end;

    procedure LookupUOM(var Text: Text[1024]): Boolean
    var
        InvtSetup: Record "Inventory Setup";
        UOM: Record "Unit of Measure";
        UOMList: Page "Units of Measure";
    begin
        UOMList.LookupMode(true);
        UOMList.Editable(false);
        InvtSetup.Get;
        UOM.FilterGroup(2);
        case InvtSetup."Commodity UOM Type" of
            InvtSetup."Commodity UOM Type"::Weight:
                UOM.SetRange(Type, UOM.Type::Weight);
            InvtSetup."Commodity UOM Type"::Volume:
                UOM.SetRange(Type, UOM.Type::Volume);
        end;
        UOM.FilterGroup(0);
        UOMList.SetTableView(UOM);
        if (Text <> '') then begin
            UOM.Code := Text;
            UOMList.SetRecord(UOM);
        end;
        if (UOMList.RunModal <> ACTION::LookupOK) then
            exit(false);
        UOMList.GetRecord(UOM);
        Text := UOM.Code;
        exit(true);
    end;
}

