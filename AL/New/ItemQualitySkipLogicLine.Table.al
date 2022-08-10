table 37002556 "Item Quality Skip Logic Line"
{
    // PRW111.00.01
    // P80037569, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Develop QC skip logic
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Item Quality Skip Logic Line';

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            NotBlank = true;
            TableRelation = Item WHERE("Replenishment System" = FILTER(Purchase | "Prod. Order" | Assembly));

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if "Item No." <> '' then
                    Item.Get("Item No.");
                Description := Item.Description;
            end;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            var
                ItemVariant: Record "Item Variant";
            begin
                TestField("Item No.");
                if "Variant Code" <> '' then
                    ItemVariant.Get("Item No.", "Variant Code");
                Description := ItemVariant.Description;
            end;
        }
        field(18; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            TableRelation = IF ("Source Type" = CONST(Vendor)) Vendor;
        }
        field(19; "Source Type"; Option)
        {
            Caption = 'Source Type';
            OptionCaption = ' ,,Vendor,Item';
            OptionMembers = " ",,Vendor,Item;
        }
        field(25; "Value Class"; Option)
        {
            Caption = 'Value Class';
            OptionCaption = ' ,a,b,c';
            OptionMembers = " ",a,b,c;
        }
        field(26; "Activity Class"; Option)
        {
            Caption = 'Activity Class';
            OptionCaption = ' ,A,B,C';
            OptionMembers = " ",A,B,C;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Variant Code", "Source Type", "Source No.")
        {
        }
    }

    fieldgroups
    {
    }

    local procedure QCEntriesExists(): Boolean
    var
        QualityControlHeader: Record "Quality Control Header";
        ItemQualitySkipTransaction: Record "Item Quality Skip Logic Trans.";
    begin
        ItemQualitySkipTransaction.Reset;
        ItemQualitySkipTransaction.SetRange("Item No.", "Item No.");
        ItemQualitySkipTransaction.SetRange("Variant Code", "Variant Code");
        ItemQualitySkipTransaction.SetRange("Source Type", "Source Type");
        ItemQualitySkipTransaction.SetRange("Source No.", "Source No.");
        ItemQualitySkipTransaction.SetRange("Value Class", "Value Class");
        ItemQualitySkipTransaction.SetRange("Activity Class", "Activity Class");
        exit(not ItemQualitySkipTransaction.IsEmpty);
    end;
}

