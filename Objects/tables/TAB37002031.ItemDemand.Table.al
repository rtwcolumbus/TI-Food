table 37002031 "Item Demand"
{
    // PR3.70.08
    // P8000165A, Myers Nissi, Jack Reynolds, 11 FEB 05
    //   Temparay table used as basis for Lot Reservation form
    // 
    // PRW16.00.06
    // P8001070, Columbus IT, Jack Reynolds, 07 JAN 13
    //   Support for Lot Freshness
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

    Caption = 'Item Demand';
    ReplicateData = false;

    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'Sales,Production,Transfer';
            OptionMembers = Sales,Production,Transfer;
        }
        field(2; "Source Table"; Integer)
        {
            Caption = 'Source Table';
            DataClassification = SystemMetadata;
        }
        field(3; "Source Subtype"; Option)
        {
            Caption = 'Source Subtype';
            DataClassification = SystemMetadata;
            OptionCaption = '0,1,2,3,4,5,6,7,8,9,10';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9","10";
        }
        field(4; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = SystemMetadata;
        }
        field(5; "Prod. Order Line No."; Integer)
        {
            Caption = 'Prod. Order Line No.';
            DataClassification = SystemMetadata;
        }
        field(6; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
        }
        field(7; "Date Required"; Date)
        {
            Caption = 'Date Required';
            DataClassification = SystemMetadata;
        }
        field(8; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
        }
        field(9; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = SystemMetadata;
        }
        field(10; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
        }
        field(11; "Reserved Quantity"; Decimal)
        {
            CalcFormula = - Sum ("Reservation Entry".Quantity WHERE("Reservation Status" = CONST(Reservation),
                                                                   "Source Type" = FIELD("Source Table"),
                                                                   "Source Subtype" = FIELD("Source Subtype"),
                                                                   "Source ID" = FIELD("Document No."),
                                                                   "Source Prod. Order Line" = FIELD("Prod. Order Line No."),
                                                                   "Source Ref. No." = FIELD("Line No.")));
            Caption = 'Reserved Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(12; "Reserved Quantity (Base)"; Decimal)
        {
            CalcFormula = - Sum ("Reservation Entry"."Quantity (Base)" WHERE("Reservation Status" = CONST(Reservation),
                                                                            "Source Type" = FIELD("Source Table"),
                                                                            "Source Subtype" = FIELD("Source Subtype"),
                                                                            "Source ID" = FIELD("Document No."),
                                                                            "Source Prod. Order Line" = FIELD("Prod. Order Line No."),
                                                                            "Source Ref. No." = FIELD("Line No.")));
            Caption = 'Reserved Quantity (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(13; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DataClassification = SystemMetadata;
        }
        field(14; "Freshness Calc. Method"; Option)
        {
            Caption = 'Freshness Calc. Method';
            DataClassification = SystemMetadata;
            OptionCaption = ' ,Days To Fresh,Best If Used By,Sell By';
            OptionMembers = " ","Days To Fresh","Best If Used By","Sell By";
        }
        field(15; "Oldest Accept. Freshness Date"; Date)
        {
            Caption = 'Oldest Acceptable Freshness Date';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; Type, "Source Subtype", "Document No.", "Prod. Order Line No.", "Line No.")
        {
        }
        key(Key2; "Date Required")
        {
        }
    }

    fieldgroups
    {
    }

    var
        LotAgePref: Record "Lot Age Filter";
        LotSpecPref: Record "Lot Specification Filter";
        Text001: Label '%1 Order %2';

    procedure GetLotPreferences(var LotAgePref: Record "Lot Age Filter"; var LotSpecPref: Record "Lot Specification Filter" temporary)
    var
        LotAgeFilter: Record "Lot Age Filter";
        LotSpecFilter: Record "Lot Specification Filter";
    begin
        Clear(LotAgePref);
        LotSpecPref.Reset;
        LotSpecPref.DeleteAll;

        if LotAgeFilter.Get("Source Table", "Source Subtype", "Document No.", '', "Prod. Order Line No.", "Line No.") then
            LotAgePref := LotAgeFilter;

        LotSpecFilter.SetRange("Table ID", "Source Table");
        LotSpecFilter.SetRange(Type, "Source Subtype");
        LotSpecFilter.SetRange(ID, "Document No.");
        LotSpecFilter.SetRange("Prod. Order Line No.", "Prod. Order Line No.");
        LotSpecFilter.SetRange("Line No.", "Line No.");
        if LotSpecFilter.Find('-') then
            repeat
                LotSpecPref := LotSpecFilter;
                LotSpecPref.Insert;
            until LotSpecFilter.Next = 0;
    end;

    procedure SourceDescription(): Text[100]
    begin
        exit(StrSubstNo(Text001, Type, "Document No."));
    end;
}

