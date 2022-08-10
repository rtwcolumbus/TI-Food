table 37002689 "Posted Comm. Manifest Line"
{
    // PRW16.00.04
    // P8000891, VerticalSoft, Don Bresee, 04 JAN 11
    //   Add Commodity Receiving logic
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Posted Comm. Manifest Line';

    fields
    {
        field(1; "Posted Comm. Manifest No."; Code[20])
        {
            Caption = 'Posted Comm. Manifest No.';
            TableRelation = "Posted Comm. Manifest Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;
        }
        field(4; "Vendor Name"; Text[100])
        {
            CalcFormula = Lookup (Vendor.Name WHERE("No." = FIELD("Vendor No.")));
            Caption = 'Vendor Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6; "Manifest Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Manifest Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(8; "Received Date"; Date)
        {
            Caption = 'Received Date';
        }
        field(9; "Received Lot No."; Code[50])
        {
            Caption = 'Received Lot No.';
        }
        field(13; "Purch. Rcpt. No."; Code[20])
        {
            Caption = 'Purch. Rcpt. No.';
            Editable = false;
            TableRelation = "Purch. Rcpt. Header";
        }
        field(14; "Purch. Rcpt. Line No."; Integer)
        {
            BlankZero = true;
            Caption = 'Purch. Rcpt. Line No.';
            Editable = false;
            TableRelation = "Purch. Rcpt. Line"."Line No." WHERE("Document No." = FIELD("Purch. Rcpt. No."));
        }
        field(17; "Rejection Action"; Option)
        {
            Caption = 'Rejection Action';
            OptionCaption = ' ,Withhold Payment';
            OptionMembers = " ","Withhold Payment";
        }
    }

    keys
    {
        key(Key1; "Posted Comm. Manifest No.", "Line No.")
        {
            SumIndexFields = "Manifest Quantity";
        }
        key(Key2; "Posted Comm. Manifest No.", "Vendor No.", "Received Date")
        {
        }
        key(Key3; "Purch. Rcpt. No.", "Purch. Rcpt. Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure ShowReceviedLotEntries()
    var
        PstdCommManifestHeader: Record "Posted Comm. Manifest Header";
    begin
        PstdCommManifestHeader.Get("Posted Comm. Manifest No.");
        PstdCommManifestHeader.ShowLotEntries("Received Lot No.");
    end;

    procedure GetReceivedPercentage(): Decimal
    var
        PstdCommManifestLine: Record "Posted Comm. Manifest Line";
    begin
        PstdCommManifestLine.SetRange("Posted Comm. Manifest No.", "Posted Comm. Manifest No.");
        PstdCommManifestLine.CalcSums("Manifest Quantity");
        if (PstdCommManifestLine."Manifest Quantity" <> 0) then
            exit(("Manifest Quantity" / PstdCommManifestLine."Manifest Quantity") * 100);
    end;
}

