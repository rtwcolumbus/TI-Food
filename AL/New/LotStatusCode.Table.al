table 37002202 "Lot Status Code"
{
    // PRW16.00.06
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Lot Status Code';
    LookupPageID = "Lot Status Codes";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(11; "Available for Sale"; Boolean)
        {
            Caption = 'Available for Sale';
            InitValue = true;

            trigger OnValidate()
            begin
                TestField(Code);
            end;
        }
        field(12; "Available for Purchase"; Boolean)
        {
            Caption = 'Available for Purchase';
            InitValue = true;

            trigger OnValidate()
            begin
                TestField(Code);
            end;
        }
        field(13; "Available for Transfer"; Boolean)
        {
            Caption = 'Available for Transfer';
            InitValue = true;

            trigger OnValidate()
            begin
                TestField(Code);
            end;
        }
        field(14; "Available for Consumption"; Boolean)
        {
            Caption = 'Available for Consumption';
            InitValue = true;

            trigger OnValidate()
            begin
                TestField(Code);
            end;
        }
        field(15; "Available for Adjustment"; Boolean)
        {
            Caption = 'Available for Adjustment';
            InitValue = true;

            trigger OnValidate()
            begin
                TestField(Code);
            end;
        }
        field(16; "Available for Planning"; Boolean)
        {
            Caption = 'Available for Planning';
            InitValue = true;

            trigger OnValidate()
            begin
                TestField(Code);
            end;
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

    trigger OnDelete()
    var
        LotInfo: Record "Lot No. Information";
        InvSetup: Record "Inventory Setup";
    begin
        TestField(Code);

        LotInfo.SetCurrentKey("Lot Status Code");
        LotInfo.SetRange("Lot Status Code", Code);
        if not LotInfo.IsEmpty then
            Error(Text000, TableCaption, Code);

        InvSetup.Get;
        if InvSetup."Quarantine Lot Status" = Code then
            InvSetup."Quarantine Lot Status" := '';
        if InvSetup."Quality Control Lot Status" = Code then
            InvSetup."Quality Control Lot Status" := '';
        if InvSetup."Sales Lot Status" = Code then
            InvSetup."Sales Lot Status" := '';
        if InvSetup."Purchase Lot Status" = Code then
            InvSetup."Purchase Lot Status" := '';
        if InvSetup."Output Lot Status" = Code then
            InvSetup."Output Lot Status" := '';
        InvSetup.Modify;
    end;

    var
        Text000: Label 'You cannot delete %1 %2 because there is at least one lot with this status.';
}

