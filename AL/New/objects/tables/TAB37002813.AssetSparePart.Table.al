table 37002813 "Asset Spare Part"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 30 AUG 06
    //   List of spare parts for assets (based on manufacturer and model number)
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Asset Spare Part';
    DataCaptionFields = "Manufacturer Code", "Model No.";

    fields
    {
        field(1; "Manufacturer Code"; Code[10])
        {
            Caption = 'Manufacturer Code';
            TableRelation = Manufacturer;
        }
        field(2; "Model No."; Code[30])
        {
            Caption = 'Model No.';
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            InitValue = Stock;
            OptionCaption = ',Stock,NonStock';
            OptionMembers = ,Stock,NonStock;
        }
        field(4; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            NotBlank = true;
            TableRelation = IF (Type = CONST(Stock)) Item;

            trigger OnValidate()
            begin
                if "Item No." <> xRec."Item No." then
                    Init;

                case Type of
                    Type::Stock:
                        begin
                            Item.Get("Item No.");
                            "Part No." := Item."Part No.";
                            Description := Item.Description;
                        end;

                    Type::NonStock:
                        begin
                            "Part No." := "Item No.";
                        end;
                end;
            end;
        }
        field(5; "Part No."; Code[20])
        {
            Caption = 'Part No.';

            trigger OnValidate()
            begin
                if (Type = Type::NonStock) and ("Item No." = '') then
                    "Item No." := "Part No.";
            end;
        }
        field(6; Description; Text[100])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Manufacturer Code", "Model No.", Type, "Item No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Item: Record Item;
}

