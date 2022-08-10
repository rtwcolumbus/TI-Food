table 37002925 "Allergen Detail"
{
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Allergen Detail';
    ReplicateData = false;

    fields
    {
        field(1; "Allergen Code"; Code[10])
        {
            Caption = 'Allergen Code';
            DataClassification = SystemMetadata;
        }
        field(2; "Source Type"; Option)
        {
            Caption = 'Source Type';
            DataClassification = SystemMetadata;
            OptionCaption = ' ,Item,BOM,Unapproved Item';
            OptionMembers = " ",Item,BOM,"Unapproved Item";
        }
        field(3; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            DataClassification = SystemMetadata;
        }
        field(4; "Version Code"; Code[20])
        {
            Caption = 'Version Code';
            DataClassification = SystemMetadata;
        }
        field(5; First; Boolean)
        {
            Caption = 'First';
            DataClassification = SystemMetadata;
        }
        field(11; Presence; Option)
        {
            Caption = 'Presence';
            DataClassification = SystemMetadata;
            InitValue = Allergen;
            OptionCaption = ' ,,,May Contain,,,,Allergen';
            OptionMembers = " ",,,"May Contain",,,,Allergen;
        }
        field(12; "Allergen Description"; Text[100])
        {
            Caption = 'Allergen Description';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Allergen Code", "Source Type", "Source No.", "Version Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label '%1, Version %2';

    procedure SourceNo(): Text
    begin
        case "Source Type" of
            "Source Type"::Item, "Source Type"::"Unapproved Item":
                exit("Source No.");
            "Source Type"::BOM:
                exit(StrSubstNo(Text001, "Source No.", "Version Code"));
        end;
    end;

    procedure SourceDescription(): Text
    var
        Item: Record Item;
        UnapprovedItem: Record "Unapproved Item";
        ProductionBOMHeader: Record "Production BOM Header";
    begin
        case "Source Type" of
            "Source Type"::Item:
                begin
                    Item.Get("Source No.");
                    exit(Item.Description);
                end;
            "Source Type"::BOM:
                begin
                    ProductionBOMHeader.Get("Source No.");
                    exit(ProductionBOMHeader.Description);
                end;
            "Source Type"::"Unapproved Item":
                begin
                    UnapprovedItem.Get("Source No.");
                    exit(UnapprovedItem.Description);
                end;
        end;
    end;
}

