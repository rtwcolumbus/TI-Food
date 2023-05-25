table 37002007 "Cost Trace"
{
    // PR4.00.04
    // P8000370A, VerticalSoft, Jack Reynolds, 08 SEP 06
    //   Temp table for holding cost trace entries
    // 
    // PRW17.00
    // P8001132, Columbus IT, Don Bresee, 28 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality
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

    Caption = 'Cost Trace';
    LookupPageID = "Cost Trace";
    ReplicateData = false;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; Level; Integer)
        {
            Caption = 'Level';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(3; "Parent Entry No."; Integer)
        {
            Caption = 'Parent Entry No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(4; "Sequence No."; Integer)
        {
            Caption = 'Sequence No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(5; "Has Children"; Boolean)
        {
            Caption = 'Has Children';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(6; Displayed; Boolean)
        {
            Caption = 'Displayed';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(7; Expanded; Boolean)
        {
            Caption = 'Expanded';
            DataClassification = SystemMetadata;
            InitValue = false;

            trigger OnValidate()
            var
                CostTrace2: Record "Cost Trace";
                CostTrace3: Record "Cost Trace";
            begin
                if not "Has Children" then
                    exit;

                CostTrace2.Copy(Rec);
                Reset;
                SetCurrentKey("Sequence No.");
                Get(CostTrace2."Entry No.");
                Next;
                repeat
                    if CostTrace2.Expanded then begin
                        CostTrace3 := Rec;
                        if "Parent Entry No." = CostTrace2."Entry No." then
                            Rec := CostTrace2
                        else
                            Get("Parent Entry No.");
                        if Expanded then begin
                            Rec := CostTrace3;
                            Displayed := true;
                        end else begin
                            Rec := CostTrace3;
                            Displayed := false;
                        end;
                        Modify;
                    end else begin
                        Displayed := false;
                        Modify;
                    end;
                until (Next = 0) or (Level <= CostTrace2.Level);

                Copy(CostTrace2);
            end;
        }
        field(10; Contribution; Decimal)
        {
            Caption = 'Contribution';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 10;
            Editable = false;
        }
        field(11; Type; Option)
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
            Editable = false;
            OptionCaption = 'Start,Standard Application,Fixed Application,Transfer,Assembly/Repack/Reclass.,Production Order';
            OptionMembers = Start,"Standard Application","Fixed Application",Transfer,"Assembly/Repack/Reclass.","Production Order";
        }
        field(12; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            DataClassification = SystemMetadata;
            Editable = false;
            OptionCaption = 'Purchase,Sale,Positive Adjmt.,Negative Adjmt.,Transfer,Consumption,Output,Assembly Consumption,Assembly Output,,,,,,Work Center,Machine Center,Resource';
            OptionMembers = Purchase,Sale,"Positive Adjmt.","Negative Adjmt.",Transfer,Consumption,Output,"Assembly Consumption","Assembly Output",,,,,,"Work Center","Machine Center",Resource;
        }
        field(13; "Output Type"; Option)
        {
            Caption = 'Output Type';
            DataClassification = SystemMetadata;
            Editable = false;
            OptionCaption = ' ,Regular,Co-Product,By-Product';
            OptionMembers = " ",Regular,"Co-Product","By-Product";
        }
        field(14; "Ledger Entry No."; Integer)
        {
            Caption = 'Ledger Entry No.';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = IF ("Entry Type" = FILTER(Purchase .. Output)) "Item Ledger Entry"
            ELSE
            IF ("Entry Type" = FILTER("Work Center" .. "Machine Center")) "Capacity Ledger Entry"
            ELSE
            IF ("Entry Type" = CONST(Resource)) "Res. Ledger Entry";
        }
        field(15; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(16; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(17; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = IF ("Entry Type" = FILTER(Purchase .. Output)) Item
            ELSE
            IF ("Entry Type" = CONST("Work Center")) "Work Center"
            ELSE
            IF ("Entry Type" = CONST("Machine Center")) "Machine Center"
            ELSE
            IF ("Entry Type" = CONST(Resource)) Resource;
        }
        field(21; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(22; "Applied Quantity"; Decimal)
        {
            Caption = 'Applied Quantity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(23; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(24; "Cost by Alternate"; Boolean)
        {
            Caption = 'Cost by Alternate';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(25; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(26; "Quantity (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            Caption = 'Quantity (Alt.)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(27; "Applied Quantity (Base)"; Decimal)
        {
            Caption = 'Applied Quantity (Base)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(28; "Applied Quantity (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            Caption = 'Applied Quantity (Alt.)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(31; Cost; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Cost';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(32; "Direct Cost"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Direct Cost';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(33; "Other Cost"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Other Cost';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(34; "Cost (Actual)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Cost (Actual)';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(35; "Direct Cost (Actual)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Direct Cost (Actual)';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(36; "Other Cost (Actual)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Other Cost (Actual)';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(37; "Cost (Expected)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Cost (Expected)';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(38; "Direct Cost (Expected)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Direct Cost (Expected)';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(39; "Other Cost (Expected)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Other Cost (Expected)';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(40; "Cost Contribution"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Cost Contribution';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(41; "Total Output"; Decimal)
        {
            Caption = 'Total Output';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(42; "Total Output (Base)"; Decimal)
        {
            Caption = 'Total Output (Base)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(43; "Total Output (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            Caption = 'Total Output (Alt.)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(51; "Shared Component"; Boolean)
        {
            Caption = 'Shared Component';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(52; "Allocated to By-Products"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Allocated to By-Products';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(53; "Co-Product Units"; Decimal)
        {
            Caption = 'Co-Product Units';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(54; "Total Co-Product Units"; Decimal)
        {
            Caption = 'Total Co-Product Units';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Parent Entry No.")
        {
        }
        key(Key3; "Sequence No.")
        {
        }
    }

    fieldgroups
    {
    }
}

