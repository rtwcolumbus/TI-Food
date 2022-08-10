table 37002576 "Container Ledger Entry"
{
    // PR3.70.07
    // P8000140A, Myers Nissi, Jack Reynolds, 19 NOV 04
    //   Support for container journal and ledger
    // 
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add "Bin Code" and related logic
    // 
    // PRW16.00
    // P8000639, VerticalSoft, Jack Reynolds, 18 NOV 08
    //   Add DropDown field group
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW17.00.01
    // P8001154, Columbus IT, Jack Reynolds, 28 MAY 13
    //   Enlarge User ID field
    // 
    // PRW110.0.02
    // P80048075, To-Increase, Dayakar Battini, 31 OCT 17
    //   "External Document No." field length from Code20 to Code35
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
    // 
    // PRW120.00
    // P800144605, To Increase, Jack Reynolds, 20 APR 22
    //   Upgrade to 20.0

    Caption = 'Container Ledger Entry';
    LookupPageID = "Container Ledger Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Container Item No."; Code[20])
        {
            Caption = 'Container Item No.';
            TableRelation = Item WHERE("Item Type" = CONST(Container));
        }
        field(3; "Container Serial No."; Code[50])
        {
            Caption = 'Container Serial No.';

            trigger OnLookup()
            begin
                ItemTrackingMgt.LookupTrackingNoInfo("Container Item No.", '', 0, "Container Serial No."); // P800144605
            end;
        }
        field(4; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'Acquisition,Use,Transfer,Ship,Return,Adjust Tare,Disposal';
            OptionMembers = Acquisition,Use,Transfer,Ship,Return,"Adjust Tare",Disposal;
        }
        field(11; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(12; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(13; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(14; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(15; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(16; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";
        }
        field(17; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(18; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(19; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(20; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(31; "Source Type"; Option)
        {
            Caption = 'Source Type';
            OptionCaption = ' ,Customer,Vendor';
            OptionMembers = " ",Customer,Vendor;
        }
        field(32; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            TableRelation = IF ("Source Type" = CONST(Customer)) Customer
            ELSE
            IF ("Source Type" = CONST(Vendor)) Vendor;
        }
        field(33; "Container ID"; Code[20])
        {
            Caption = 'Container ID';
        }
        field(34; "Fill Item No."; Code[20])
        {
            Caption = 'Fill Item No.';
            TableRelation = Item;
        }
        field(35; "Fill Variant Code"; Code[10])
        {
            Caption = 'Fill Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Fill Item No."));
        }
        field(36; "Fill Lot No."; Code[50])
        {
            Caption = 'Fill Lot No.';

            trigger OnLookup()
            begin
                ItemTrackingMgt.LookupTrackingNoInfo("Fill Item No.", "Fill Variant Code", 1, "Fill Lot No."); // P800144605
            end;
        }
        field(37; "Fill Serial No."; Code[50])
        {
            Caption = 'Fill Serial No.';

            trigger OnLookup()
            begin
                ItemTrackingMgt.LookupTrackingNoInfo("Fill Item No.", "Fill Variant Code", 0, "Fill Serial No."); // P800144605
            end;
        }
        field(38; "Fill Quantity"; Decimal)
        {
            Caption = 'Fill Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(39; "Fill Quantity (Base)"; Decimal)
        {
            Caption = 'Fill Quantity (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(40; "Fill Quantity (Alt.)"; Decimal)
        {
            Caption = 'Fill Quantity (Alt.)';
            DecimalPlaces = 0 : 5;
        }
        field(41; "Fill Unit of Measure Code"; Code[10])
        {
            Caption = 'Fill Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Fill Item No."));
        }
        field(52; Quantity; Integer)
        {
            Caption = 'Quantity';
        }
        field(61; "Tare Weight"; Decimal)
        {
            Caption = 'Tare Weight';
            DecimalPlaces = 0 : 5;
        }
        field(62; "Tare Unit of Measure"; Code[10])
        {
            Caption = 'Tare Unit of Measure';
            Editable = false;
            TableRelation = "Unit of Measure";
        }
        field(101; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                // P8001133
                ShowDimensions;
            end;
        }
        field(37002100; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            Description = 'P8000631A';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Document No.", "Posting Date")
        {
        }
        key(Key3; "Container Item No.", "Container Serial No.")
        {
        }
        key(Key4; "Container Item No.", "Container Serial No.", "Posting Date")
        {
        }
        key(Key5; "Fill Item No.")
        {
            Enabled = false;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Entry No.", Description, "Posting Date", "Entry Type", "Document No.")
        {
        }
    }

    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";

    procedure ShowDimensions()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        // P8001133
        DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo('%1 %2', TableCaption, "Entry No."));
    end;
}

