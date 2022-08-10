table 37002300 "Delivery Trip Container Line"
{
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // PRW115.3
    // P800119529, To Increase, Jack Reynolds, 23 FEB 21
    //   Bring Container Ship/Receive to Delivery trip page

    Caption = 'Delivery Trip Container Line';

    fields
    {
        field(1; "Source Type"; Integer)
        {
            Caption = 'Source Type';
            Editable = false;
        }
        field(2; "Source Subtype"; Integer)
        {
            Caption = 'Source Subtype';
            Editable = false;
        }
        field(3; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            Editable = false;
        }
        field(11; "Container ID"; Code[20])
        {
            Caption = 'Container ID';
            Editable = false;
        }
        field(12; "Container License Plate"; Code[50])
        {
            Caption = 'Container License Plate';
            Editable = false;
        }
        field(13; "Container Type Code"; Code[10])
        {
            Caption = 'Container Type Code';
            Editable = false;
        }
        field(14; "Container Description"; Text[50])
        {
            Caption = 'Container Description';
            Editable = false;
        }
        field(15; "Container Weight"; Decimal)
        {
            Caption = 'Container Weight';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(16; Loaded; Option)
        {
            Caption = 'Loaded';
            OptionCaption = ' ,Yes';
            OptionMembers = " ",Yes;

            trigger OnValidate()
            var
                ContainerHeader: Record "Container Header";
            begin
                if "Line No." = 0 then begin
                    ContainerHeader.Get("Container ID");
                    ContainerHeader.Loaded := Loaded = Loaded::Yes;
                    ContainerHeader.Modify;
                end;
            end;
        }
        field(17; Ship; Option)
        {
            Caption = 'Ship';
            OptionCaption = ' ,Yes';
            OptionMembers = " ",Yes;

            trigger OnValidate()
            var
                ContainerHeader: Record "Container Header";
                ContainerFunctions: Codeunit "Container Functions";
                ShipReceive: Boolean;
            begin
                // P800119529
                if "Line No." = 0 then begin
                    ShipReceive := Ship = Ship::Yes;
                    ContainerHeader.Get("Container ID");
                    if ContainerHeader."Ship/Receive" <> ShipReceive then begin
                        ContainerHeader."Ship/Receive" := ShipReceive;
                        ContainerHeader.Modify;
                        ContainerFunctions.UpdateContainerShipReceive(ContainerHeader, ShipReceive, false);
                    end;
                end;
            end;
        }
        field(21; "Line No."; Integer)
        {
            Caption = 'Line No.';
            Editable = false;
        }
        field(22; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Editable = false;
        }
        field(23; "Item Description"; Text[50])
        {
            Caption = 'Item Description';
            Editable = false;
        }
        field(24; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            Editable = false;
        }
        field(25; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            Editable = false;
        }
        field(26; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            Editable = false;
        }
        field(27; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(100; Level; Integer)
        {
            Caption = 'Level';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Source Type", "Source Subtype", "Source No.", "Container ID", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

