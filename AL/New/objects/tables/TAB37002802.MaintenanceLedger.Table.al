table 37002802 "Maintenance Ledger"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 30 AUG 06
    //   Ledger table for mainteance granule
    //   All maintenance costs associated with work orders and assets
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 31 JUL 07
    //   Add two new keys for lot number and serial number to support item tracking navigation
    // 
    // PRW16.00
    // P8000639, VerticalSoft, Jack Reynolds, 18 NOV 08
    //   Add DropDown field group
    // 
    // PRW16.00.03
    // P8000832, VerticalSoft, Jack Reynolds, 08 JUN 10
    //   Correct spelling on table caption
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Maintenance Ledger Entry';
    DrillDownPageID = "Maint. Ledger Entries";
    LookupPageID = "Maint. Ledger Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Work Order No."; Code[20])
        {
            Caption = 'Work Order No.';
        }
        field(3; "Asset No."; Code[20])
        {
            Caption = 'Asset No.';
            TableRelation = Asset;
        }
        field(4; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'Labor,Material-Stock,Material-NonStock,Contract';
            OptionMembers = Labor,"Material-Stock","Material-NonStock",Contract;
        }
        field(5; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(6; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(7; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(8; "Cost Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Cost Amount';
        }
        field(9; "Maintenance Trade Code"; Code[10])
        {
            Caption = 'Maintenance Trade Code';
            TableRelation = "Maintenance Trade";
        }
        field(10; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(11; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = IF ("Entry Type" = CONST("Material-Stock")) Item;
        }
        field(12; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(13; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(14; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
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
        field(17; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
        }
        field(18; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(19; "Unit Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost';
        }
        field(20; "Applies-to Entry"; Integer)
        {
            Caption = 'Applies-to Entry';
        }
        field(101; "Employee No."; Code[20])
        {
            Caption = 'Employee No.';
            TableRelation = Employee;
        }
        field(102; "Starting Time"; Time)
        {
            Caption = 'Starting Time';
        }
        field(103; "Ending Time"; Time)
        {
            Caption = 'Ending Time';
        }
        field(201; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;
        }
        field(301; "Part No."; Code[20])
        {
            Caption = 'Part No.';
        }
        field(302; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Unit of Measure";
        }
        field(303; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(304; "Item Ledger Entry No."; Integer)
        {
            Caption = 'Item Ledger Entry No.';
        }
        field(305; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
        }
        field(306; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
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
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Asset No.", "Entry Type", "Posting Date")
        {
            SumIndexFields = "Cost Amount";
        }
        key(Key3; "Asset No.", "Entry Type", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code")
        {
            Enabled = false;
            SumIndexFields = "Cost Amount";
        }
        key(Key4; "Work Order No.", "Entry Type", "Maintenance Trade Code")
        {
            SumIndexFields = "Cost Amount", Quantity;
        }
        key(Key5; "Work Order No.", "Entry Type", "Item No.")
        {
            SumIndexFields = "Cost Amount", "Quantity (Base)";
        }
        key(Key6; "Document No.", "Posting Date")
        {
        }
        key(Key7; "Work Order No.", "Posting Date", "Entry No.")
        {
        }
        key(Key8; "Applies-to Entry")
        {
            SumIndexFields = Quantity;
        }
        key(Key9; "Entry Type", "Maintenance Trade Code", "Vendor No.", "Posting Date")
        {
            SumIndexFields = "Cost Amount";
        }
        key(Key10; "Lot No.")
        {
            Enabled = false;
        }
        key(Key11; "Serial No.")
        {
            Enabled = false;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Entry No.", Description, "Asset No.", "Posting Date", "Entry Type", "Document No.")
        {
        }
    }

    procedure ShowDimensions()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        // P8001133
        DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo('%1 %2', TableCaption, "Entry No."));
    end;
}

