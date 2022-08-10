table 37002547 "Item Quality Test Result"
{
    // PRW16.00.06
    // P8001079, Columbus IT, Jack Reynolds, 15 JUN 12
    //    Support for selective re-tests
    // 
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW120.2
    // P800147282, To Increase, Jack Reynolds, 29 JUN 22
    //   Add additional Q/C Test to Lot

    Caption = 'Item Quality Test Result';

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Editable = false;
        }
        field(2; "Variant Type"; Option)
        {
            Caption = 'Variant Type';
            Description = 'PR3.70.02';
            Editable = false;
            OptionCaption = 'Item Only,Item and Variant,Variant Only';
            OptionMembers = "Item Only","Item and Variant","Variant Only";
        }
        field(3; "Code"; Code[10])
        {
            Caption = 'Code';
            Editable = false;
            NotBlank = true;
            TableRelation = "Data Collection Data Element";
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(5; Type; Option)
        {
            Caption = 'Type';
            Editable = false;
            OptionCaption = 'Boolean,Date,Lookup,Numeric,Text';
            OptionMembers = Boolean,Date,"Lookup",Numeric,Text;
        }
        field(6; "Reason Code Required"; Boolean)
        {
            Caption = 'Reason Code Required';
            Editable = false;
        }
        field(7; "Test No."; Integer)
        {
            BlankZero = true;
            Caption = 'Test No.';
            Editable = false;
        }
        field(8; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            Editable = false;
        }
        field(9; Date; Date)
        {
            Caption = 'Date';
            Editable = false;
        }
        field(10; Status; Option)
        {
            Caption = 'Status';
            Editable = false;
            OptionCaption = ' ,Pass,Fail';
            OptionMembers = " ",Pass,Fail;
        }
        field(11; Value; Code[50])
        {
            Caption = 'Value';
            Editable = false;
        }
        field(12; Target; Code[50])
        {
            Caption = 'Target';
            Editable = false;
        }
        field(20; Include; Boolean)
        {
            Caption = 'Include';
        }
        field(21; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            Editable = false;
        }
        field(22; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            Editable = false;
        }
        field(23; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(24; Editable; Boolean)
        {
            Caption = 'Editable';
            Editable = false;
        }
        field(31; "Boolean Target Value"; Option)
        {
            Caption = 'Boolean Target Value';
            OptionCaption = ' ,No,Yes';
            OptionMembers = " ",No,Yes;

            trigger OnValidate()
            begin
                DataCollectionLine := Copy2DataCollectionLine(FieldNo("Boolean Target Value"));
                DataCollectionLine.Validate("Boolean Target Value", "Boolean Target Value");
            end;
        }
        field(32; "Lookup Target Value"; Code[10])
        {
            Caption = 'Lookup Target Value';
            TableRelation = IF (Type = CONST("Lookup")) "Data Collection Lookup".Code WHERE("Data Element Code" = FIELD(Code));

            trigger OnValidate()
            begin
                DataCollectionLine := Copy2DataCollectionLine(FieldNo("Lookup Target Value"));
                DataCollectionLine.Validate("Lookup Target Value", "Lookup Target Value");
            end;
        }
        field(33; "Numeric Target Value"; Decimal)
        {
            Caption = 'Numeric Target Value';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                DataCollectionLine := Copy2DataCollectionLine(FieldNo("Numeric Target Value"));
                DataCollectionLine.Validate("Numeric Target Value", "Numeric Target Value");
            end;
        }
        field(34; "Text Target Value"; Code[50])
        {
            Caption = 'Text Target Value';

            trigger OnValidate()
            var
            begin
                DataCollectionLine := Copy2DataCollectionLine(FieldNo("Text Target Value"));
                DataCollectionLine.Validate("Text Target Value", "Text Target Value");
            end;
        }
        field(35; "Numeric Low-Low Value"; Decimal)
        {
            Caption = 'Numeric Low-Low Value';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                DataCollectionLine := Copy2DataCollectionLine(FieldNo("Numeric Low-Low Value"));
                DataCollectionLine.Validate("Numeric Low-Low Value", "Numeric Low-Low Value");
            end;
        }
        field(36; "Numeric Low Value"; Decimal)
        {
            Caption = 'Numeric Low Value';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                DataCollectionLine := Copy2DataCollectionLine(FieldNo("Numeric Low Value"));
                DataCollectionLine.Validate("Numeric Low Value", "Numeric Low Value");
                "Numeric Low-Low Value" := DataCollectionLine."Numeric Low-Low Value";
            end;
        }
        field(37; "Numeric High Value"; Decimal)
        {
            Caption = 'Numeric High Value';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                DataCollectionLine := Copy2DataCollectionLine(FieldNo("Numeric High Value"));
                DataCollectionLine.Validate("Numeric High Value", "Numeric High Value");
            end;
        }
        field(38; "Numeric High-High Value"; Decimal)
        {
            Caption = 'Numeric High-High Value';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                DataCollectionLine := Copy2DataCollectionLine(FieldNo("Numeric High-High Value"));
                DataCollectionLine.Validate("Numeric High-High Value", "Numeric High-High Value");
                "Numeric High Value" := DataCollectionLine."Numeric High Value";
            end;
        }
        field(41; "Certificate of Analysis"; Boolean)
        {
            Caption = 'Certificate of Analysis';

            trigger OnValidate()
            begin
                DataCollectionLine := Copy2DataCollectionLine(FieldNo("Certificate of Analysis"));
                DataCollectionLine.Validate("Certificate of Analysis", "Certificate of Analysis");
            end;
        }
        field(42; "Must Pass"; Boolean)
        {
            Caption = 'Must Pass';

            trigger OnValidate()
            begin
                DataCollectionLine := Copy2DataCollectionLine(FieldNo("Must Pass"));
                DataCollectionLine.Validate("Must Pass", "Must Pass");
            end;
        }
        field(51; "Sample Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Sample Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                DataCollectionLine := Copy2DataCollectionLine(FieldNo("Sample Quantity"));
                DataCollectionLine.Validate("Sample Quantity", "Sample Quantity");
                "Sample Unit of Measure Code" := DataCollectionLine."Sample Unit of Measure Code";
                "Combine Samples" := DataCollectionLine."Combine Samples";
            end;
        }
        field(52; "Sample Unit of Measure Code"; Code[10])
        {
            Caption = 'Sample Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            begin
                DataCollectionLine := Copy2DataCollectionLine(FieldNo("Sample Unit of Measure Code"));
                DataCollectionLine.Validate("Sample Unit of Measure Code", "Sample Unit of Measure Code");
            end;
        }
        field(53; "Combine Samples"; Boolean)
        {
            Caption = 'Combine Samples';

            trigger OnValidate()
            begin
                DataCollectionLine := Copy2DataCollectionLine(FieldNo("Combine Samples"));
                DataCollectionLine.Validate("Combine Samples", "Combine Samples");
            end;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Variant Type", "Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        DataCollectionLine: Record "Data Collection Line";

    procedure GetResults()
    var
        LotSpecification: Record "Lot Specification";
        QualityControlLine: Record "Quality Control Line";
    begin
        if LotSpecification.Get("Item No.", "Variant Code", "Lot No.", Code) then
            "Test No." := LotSpecification."Quality Control Test No.";

        if "Test No." = 0 then begin
            "Reason Code" := '';
            Date := 0D;
            Status := 0;
            Value := '';
            Target := '';
        end else begin
            QualityControlLine.Get("Item No.", "Variant Code", "Lot No.", "Test No.", Code);
            "Reason Code" := QualityControlLine."Reason Code";
            Date := QualityControlLine."Test Date";
            Status := QualityControlLine.Status;
            Value := QualityControlLine.Result;
            case Type of
                Type::Boolean:
                    Target := Format(QualityControlLine."Boolean Target Value");
                Type::Date:
                    Target := '';
                Type::"Lookup":
                    Target := QualityControlLine."Lookup Target Value";
                Type::Numeric:
                    Target := Format(QualityControlLine."Numeric Target Value");
                Type::Text:
                    Target := QualityControlLine."Text Target Value";
            end;
        end;
    end;

    // P800147282
    procedure Copy2DataCollectionLine(FldNumber: Integer) DataCollectionLine: Record "Data Collection Line"
    begin
        DataCollectionLine."Source ID" := Database::Item;
        DataCollectionLine."Source Key 1" := "Item No.";
        DataCollectionLine."Data Element Code" := Code;
        DataCollectionLine."Data Element Type" := Type;
        if FldNumber <> FieldNo("Boolean Target Value") then
            DataCollectionLine."Boolean Target Value" := "Boolean Target Value";
        if FldNumber <> FieldNo("Lookup Target Value") then
            DataCollectionLine."Lookup Target Value" := "Lookup Target Value";
        if FldNumber <> FieldNo("Numeric High-High Value") then
            DataCollectionLine."Numeric High-High Value" := "Numeric High-High Value";
        if FldNumber <> FieldNo("Numeric High Value") then
            DataCollectionLine."Numeric High Value" := "Numeric High Value";
        if FldNumber <> FieldNo("Numeric Target Value") then
            DataCollectionLine."Numeric Target Value" := "Numeric Target Value";
        if FldNumber <> FieldNo("Numeric Low Value") then
            DataCollectionLine."Numeric Low Value" := "Numeric Low Value";
        if FldNumber <> FieldNo("Numeric Low-Low Value") then
            DataCollectionLine."Numeric Low-Low Value" := "Numeric Low-Low Value";
        if FldNumber <> FieldNo("Text Target Value") then
            DataCollectionLine."Text Target Value" := "Text Target Value";
        if FldNumber <> FieldNo("Certificate of Analysis") then
            DataCollectionLine."Certificate of Analysis" := "Certificate of Analysis";
        if FldNumber <> FieldNo("Must Pass") then
            DataCollectionLine."Must Pass" := "Must Pass";
        if FldNumber <> FieldNo("Sample Quantity") then
            DataCollectionLine."Sample Quantity" := "Sample Quantity";
        if FldNumber <> FieldNo("Sample Unit of Measure Code") then
            DataCollectionLine."Sample Unit of Measure Code" := "Sample Unit of Measure Code";
        if FldNumber <> FieldNo("Combine Samples") then
            DataCollectionLine."Combine Samples" := "Combine Samples";
    end;
}

