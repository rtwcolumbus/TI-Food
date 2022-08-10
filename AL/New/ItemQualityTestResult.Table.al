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
}

