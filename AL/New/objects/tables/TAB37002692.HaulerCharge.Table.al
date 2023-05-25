table 37002692 "Hauler Charge"
{
    // PRW16.00.04
    // P8000902, Columbus IT, Don Bresee, 14 MAR 11
    //   Add Commodity Payment logic

    Caption = 'Hauler Charge';

    fields
    {
        field(1; "Hauler No."; Code[20])
        {
            Caption = 'Hauler No.';
            NotBlank = true;
            TableRelation = Vendor;
        }
        field(2; "Receiving Location Code"; Code[10])
        {
            Caption = 'Receiving Location Code';
            NotBlank = true;
            TableRelation = Location;
        }
        field(3; "Producer Zone Code"; Code[20])
        {
            Caption = 'Producer Zone Code';
            NotBlank = true;
            TableRelation = "Producer Zone";
        }
        field(4; "Charge Unit Amount"; Decimal)
        {
            AutoFormatType = 2;
            BlankZero = true;
            Caption = 'Charge Unit Amount';
            NotBlank = true;
        }
        field(5; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            NotBlank = true;
            TableRelation = "Unit of Measure";
        }
    }

    keys
    {
        key(Key1; "Hauler No.", "Receiving Location Code", "Producer Zone Code")
        {
        }
        key(Key2; "Hauler No.", "Producer Zone Code", "Receiving Location Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        TestField("Charge Unit Amount");
        TestField("Unit of Measure Code");
    end;

    procedure GetCharge(BuyFromVendorNo: Code[20]; PayToVendorNo: Code[20]; ReceivingLocationCode: Code[10]; ProducerZoneCode: Code[20]): Boolean
    begin
        if (BuyFromVendorNo <> PayToVendorNo) then
            if Get(BuyFromVendorNo, ReceivingLocationCode, ProducerZoneCode) then
                exit(true);
        exit(Get(PayToVendorNo, ReceivingLocationCode, ProducerZoneCode));
    end;
}

