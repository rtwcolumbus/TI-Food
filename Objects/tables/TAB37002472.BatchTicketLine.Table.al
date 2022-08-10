table 37002472 "Batch Ticket Line"
{
    // PR3.60
    //   Add fields "Quantity (Base)" and "Qty. per Unit of Measure"
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

    Caption = 'Batch Ticket Line';
    ReplicateData = false;

    fields
    {
        field(1; "Step Code"; Code[10])
        {
            Caption = 'Step Code';
            DataClassification = SystemMetadata;
        }
        field(2; Type; Option)
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'Text,Item';
            OptionMembers = Text,Item;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
        }
        field(4; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = SystemMetadata;
        }
        field(5; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = SystemMetadata;
        }
        field(6; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }
        field(8; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            DataClassification = SystemMetadata;
        }
        field(9; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DataClassification = SystemMetadata;
        }
        field(10; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DataClassification = SystemMetadata;
        }
        field(11; "Rounding Precision"; Decimal)
        {
            Caption = 'Rounding Precision';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Step Code", Type, "Line No.", "Lot No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure FmtQuantity(): Text[20]
    var
        Decimals: Text[3];
        tmp: Text[10];
        Text001: Label '<precision,%1><standard format,0>';
    begin
        // PR3.60 Begin
        if (Type <> Type::Item) or ("Item No." = '') then
            exit;

        if 1 <= "Rounding Precision" then
            Decimals := '0:0'
        else begin
            tmp := Format("Rounding Precision", 0, '<precision,:5><standard format,0>');
            Decimals := Format(StrLen(tmp) - 2, 1) + ':' + Format(StrLen(tmp) - 2, 1);
        end;
        exit(Format("Quantity (Base)" / "Qty. per Unit of Measure", 0, StrSubstNo(Text001, Decimals)));
        // PR3.60 End
    end;
}

