table 37002492 "Pre-Process Type"
{
    // PRW16.00.06
    // P8001082, Columbus IT, Don Bresee, 23 JAN 13
    //   Add Pre-Process functionality
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Pre-Process Type';
    LookupPageID = "Pre-Process Types";

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
        field(3; Blending; Option)
        {
            Caption = 'Blending';
            OptionCaption = ' ,Per Order,Per Item';
            OptionMembers = " ","Per Order","Per Item";

            trigger OnValidate()
            begin
                "Auto Complete" := (Blending = Blending::"Per Order");
                if (Blending <> Blending::" ") then
                    "Order Specific" := true;
            end;
        }
        field(4; "Auto Complete"; Boolean)
        {
            Caption = 'Auto Complete';

            trigger OnValidate()
            begin
                if "Auto Complete" then
                    TestField(Blending, Blending::"Per Order");
            end;
        }
        field(5; "Order Specific"; Boolean)
        {
            Caption = 'Order Specific';

            trigger OnValidate()
            begin
                if not "Order Specific" then
                    if (Blending <> Blending::" ") then
                        FieldError(Blending);
            end;
        }
        field(6; "Default Lead Time (Days)"; Integer)
        {
            BlankZero = true;
            Caption = 'Default Lead Time (Days)';
            MinValue = 0;
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
}

