table 6504 "Serial No. Information"
{
    // PR3.70.07
    // P8000140A, Myers Nissi, Jack Reynolds, 19 NOV 04
    //   Add support for serialized containers
    // 
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add "Whse. Inventory" field for serialized containers

    Caption = 'Serial No. Information';
    DataCaptionFields = "Item No.", "Variant Code", "Serial No.", Description;
    DrillDownPageID = "Serial No. Information List";
    LookupPageID = "Serial Nos.";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            NotBlank = true;
            TableRelation = Item;
        }
        field(2; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(3; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
            NotBlank = true;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(13; Blocked; Boolean)
        {
            Caption = 'Blocked';
        }
        field(14; Comment; Boolean)
        {
            CalcFormula = Exist("Item Tracking Comment" WHERE(Type = CONST("Serial No."),
                                                               "Item No." = FIELD("Item No."),
                                                               "Variant Code" = FIELD("Variant Code"),
                                                               "Serial/Lot No." = FIELD("Serial No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; Inventory; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("Item No."),
                                                                  "Variant Code" = FIELD("Variant Code"),
                                                                  "Serial No." = FIELD("Serial No."),
                                                                  "Location Code" = FIELD("Location Filter")));
            Caption = 'Inventory';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(21; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(22; "Location Filter"; Code[10])
        {
            Caption = 'Location Filter';
            FieldClass = FlowFilter;
            TableRelation = Location;
        }
        field(23; "Bin Filter"; Code[20])
        {
            Caption = 'Bin Filter';
            FieldClass = FlowFilter;
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Filter"));
        }
        field(24; "Expired Inventory"; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry"."Remaining Quantity" WHERE("Item No." = FIELD("Item No."),
                                                                              "Variant Code" = FIELD("Variant Code"),
                                                                              "Serial No." = FIELD("Serial No."),
                                                                              "Location Code" = FIELD("Location Filter"),
                                                                              "Expiration Date" = FIELD("Date Filter"),
                                                                              Open = CONST(true),
                                                                              Positive = CONST(true)));
            Caption = 'Expired Inventory';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002100; "Whse. Inventory"; Decimal)
        {
            CalcFormula = Sum ("Warehouse Entry"."Qty. (Base)" WHERE("Item No." = FIELD("Item No."),
                                                                     "Variant Code" = FIELD("Variant Code"),
                                                                     "Serial No." = FIELD("Serial No."),
                                                                     "Location Code" = FIELD("Location Filter"),
                                                                     "Bin Code" = FIELD("Bin Filter")));
            Caption = 'Whse. Inventory';
            DecimalPlaces = 0 : 5;
            Description = 'P8000631A';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002560; "Container ID"; Code[20])
        {
            CalcFormula = Lookup ("Container Header".ID WHERE("Container Item No." = FIELD("Item No."),
                                                              "Container Serial No." = FIELD("Serial No.")));
            Caption = 'Container ID';
            Description = 'PR3.70.07';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002561; "Tare Weight"; Decimal)
        {
            Caption = 'Tare Weight';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.70.07';
            Editable = false;
            MinValue = 0;
        }
        field(37002562; "Tare Unit of Measure"; Code[10])
        {
            Caption = 'Tare Unit of Measure';
            Description = 'PR3.70.07';
            Editable = false;
            TableRelation = "Unit of Measure" WHERE(Type = CONST(Weight));
        }
    }

    keys
    {
        key(Key1; "Item No.", "Variant Code", "Serial No.")
        {
            Clustered = true;
        }
        key(Key2; "Serial No.")
        {
            Enabled = false;
        }
    }

    fieldgroups
    {
        fieldgroup(Dropdown; "Item No.", "Variant Code", "Serial No.")
        {
        }
    }

    trigger OnDelete()
    begin
        // P8000140A
        ContainerLedger.Reset;
        ContainerLedger.SetCurrentKey("Container Item No.", "Container Serial No.");
        ContainerLedger.SetRange("Container Item No.", "Item No.");
        ContainerLedger.SetRange("Container Serial No.", "Serial No.");
        if ContainerLedger.Find('-') then
            Error(Text37002000, FieldCaption("Serial No."), "Serial No.", ContainerLedger.TableCaption);
        // P8000140A

        ItemTrackingComment.SetRange(Type, ItemTrackingComment.Type::"Serial No.");
        ItemTrackingComment.SetRange("Item No.", "Item No.");
        ItemTrackingComment.SetRange("Variant Code", "Variant Code");
        ItemTrackingComment.SetRange("Serial/Lot No.", "Serial No.");
        ItemTrackingComment.DeleteAll();
    end;

    var
        ItemTrackingComment: Record "Item Tracking Comment";
        ContainerLedger: Record "Container Ledger Entry";
        Text37002000: Label 'You cannot delete %1 %2 because there is at least one %3 for this serial number.';
        SourceTypeInt: Integer;
        SourceTypeText: Text;
        SourceNo: Code[20];

    local procedure GetOffSiteSource()
    begin
        // P8001323
        if (ContainerLedger.GetFilter("Container Item No.") <> "Item No.") or
          (ContainerLedger.GetFilter("Container Serial No.") <> "Serial No.")
        then begin
            ContainerLedger.SetCurrentKey("Container Item No.", "Container Serial No.");
            ContainerLedger.SetRange("Container Item No.", "Item No.");
            ContainerLedger.SetRange("Container Serial No.", "Serial No.");
            ContainerLedger.SetRange("Entry Type", ContainerLedger."Entry Type"::Ship);
            if ContainerLedger.FindLast then begin
                SourceTypeInt := ContainerLedger."Source Type";
                SourceTypeText := Format(ContainerLedger."Source Type");
                SourceNo := ContainerLedger."Source No.";
            end;
        end;
    end;

    procedure OffSiteSourceTypeInt(): Integer
    begin
        // P8001323
        GetOffSiteSource;
        exit(SourceTypeInt);
    end;

    procedure OffSiteSourceTypeText(): Text
    begin
        // P8001323
        GetOffSiteSource;
        exit(SourceTypeText);
    end;

    procedure OffSiteSourceNo(): Code[20]
    var
        ContainerLedger: Record "Container Ledger Entry";
    begin
        // P8001323
        GetOffSiteSource;
        exit(SourceNo);
    end;
}

