table 37002711 "Container Label"
{
    // PRW17.10
    // P8001246, Columbus IT, Jack Reynolds, 21 NOV 13
    //   Enlarge description fields to 50 characters
    // 
    // PRW18.00.02
    // P8004230, Columbus IT, Jack Reynolds, 02 OCT 15
    //   Label printing through BIS
    // 
    // PRW18.00.03
    // P8006373, To-Increase, Jack Reynolds, 21 JAN 16
    //   Cleanup for BIS label printing
    // 
    // PRW19.00.01
    // P8007508, To-Increase, Jack Reynolds, 01 SEP 16
    //   Primary key on printer table changed to integer
    // 
    // PRW111.00.01
    // P80062661, To-Increase, Jack Reynolds, 25 JUL 18
    //   SSCC
    // 
    // PRW111.00.03
    // P80078206, To-increase, Gangabhushan, 04 JUL 19
    //   CS00069940 - Case Lableing needs GS1 (UCC128) barcodes
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Container Label';
    ReplicateData = false;

    fields
    {
        field(1; "No. Of Copies"; Integer)
        {
            Caption = 'No. Of Copies';
        }
        field(5; "Printer Name"; Text[100])
        {
            Caption = 'Printer Name';
        }
        field(100; "Container ID"; Code[20])
        {
            Caption = 'Container ID';

            trigger OnValidate()
            var
                WeightFactor: Decimal;
            begin
                ContainerHeader.Get("Container ID");
                ContainerHeader.CalcFields("Total Quantity (Base)", "Total Net Weight (Base)", "Line Tare Weight (Base)"); // P8001323

                "Container Type Code" := ContainerHeader."Container Type Code"; // P8004230
                "Container License Plate" := ContainerHeader."License Plate";   // P8004230
                SSCC := ContainerHeader.SSCC; // P80055555
                "Location Code" := ContainerHeader."Location Code";
                "Serial No." := ContainerHeader."Container Serial No.";
                ContainerHeader.GetItem("Item No.", "Item Description"); // P8001323
                "Total Quantity" := ContainerHeader."Total Quantity (Base)";
                "Net Weight" := ContainerHeader."Total Net Weight (Base)";
                "Tare Weight" := ContainerHeader."Container Tare Weight (Base)" + ContainerHeader."Line Tare Weight (Base)";
                "Weight Unit of Measure" := P800UOMFns.DefaultUOM(2);
                WeightFactor := P800UOMFns.UOMtoMetricBase("Weight Unit of Measure");
                "Net Weight" := Round("Net Weight" / WeightFactor, 0.00001);
                "Tare Weight" := Round("Tare Weight" / WeightFactor, 0.00001);

                if "Item No." <> '' then begin
                    ContainerLine.SetRange("Container ID", "Container ID");
                    if ContainerLine.Find('-') then begin
                        ContainerLine.SetFilter("Lot No.", '<>%1', ContainerLine."Lot No.");
                        if not ContainerLine.Find('-') then
                            "Lot No." := ContainerLine."Lot No.";
                    end;
                end;

                // P8005555
                UCCBarcode.Validate("Container ID", "Container ID");
                UCCBarcode.CreateUCC('');
                UCC128 := UCCBarcode."UCC Code";
                "UCC128 (Human Readable)" := UCCBarcode."UCC Code (Human Readable)";
                // P8005555
            end;
        }
        field(110; "Container Type Code"; Code[10])
        {
            Caption = 'Container Type Code';
        }
        field(111; "Container License Plate"; Code[50])
        {
            Caption = 'Container License Plate';
        }
        field(112; SSCC; Code[18])
        {
            Caption = 'SSCC';
        }
        field(120; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
        }
        field(130; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
        }
        field(140; "Item No."; Code[20])
        {
            Caption = 'Item No.';
        }
        field(141; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
        }
        field(150; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
        }
        field(160; "Total Quantity"; Decimal)
        {
            Caption = 'Total Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(170; "Net Weight"; Decimal)
        {
            Caption = 'Net Weight';
            DecimalPlaces = 0 : 5;
        }
        field(171; "Tare Weight"; Decimal)
        {
            Caption = 'Tare Weight';
            DecimalPlaces = 0 : 5;
        }
        field(172; "Weight Unit of Measure"; Code[10])
        {
            Caption = 'Weight Unit of Measure';
        }
        field(600; UCC128; Code[250])
        {
            Caption = 'UCC128';
        }
        field(601; "UCC128 (Human Readable)"; Code[250])
        {
            Caption = 'UCC128 (Human Readable)';
        }
        field(99999; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        ContainerHeader: Record "Container Header";
        ContainerLine: Record "Container Line";
        UCCBarcode: Record "UCC Barcode Data";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
}

