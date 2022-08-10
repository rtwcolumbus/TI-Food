table 37002710 "Item Case Label"
{
    // PR4.00.04
    // P8000358A, VerticalSoft, Phyllis McGovern, 03 AUG 06
    //   Added fields: Company Name, UCC128, UCC128 Human Readable
    // 
    // PRW15.00.03
    // P8000624A, VerticalSoft, Jack Reynolds, 19 AUG 08
    //   Add fields for country/region of origin code and name
    // 
    // PRW16.00.01
    // P8000703, VerticalSoft, Jack Reynolds, 15 JUN 09
    //   New function to create UCC barcodes
    // 
    // PRW16.00.05
    // P8000975, Columbus IT, Jack Reynolds, 07 SEP 11
    //   Fix problem with Qty. per Unit of Measure
    // 
    // PRW17.10
    // P8001239, Columbus IT, Jack Reynolds, 01 NOV 13
    //   Fix problem printing labels if Lot No. Information has not yet been posted
    // 
    // P8001246, Columbus IT, Jack Reynolds, 21 NOV 13
    //   Enlarge description fields to 50 characters
    // 
    // PRW18.00.03
    // P8006373, To-Increase, Jack Reynolds, 21 JAN 16
    //   Cleanup for BIS label printing
    // 
    // PRW19.00.01
    // P8007508, To-Increase, Jack Reynolds, 01 SEP 16
    //   Primary key on printer table changed to integer
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

    Caption = 'Item Case Label';
    ReplicateData = false;

    fields
    {
        field(1; "No. Of Copies"; Integer)
        {
            Caption = 'No. Of Copies';
        }
        field(2; "Company Name"; Code[100])
        {
            Caption = 'Company Name';
        }
        field(5; "Printer Name"; Text[100])
        {
            Caption = 'Printer Name';
        }
        field(10; Quantity; Decimal)
        {
            Caption = 'Quantity';

            trigger OnValidate()
            begin
                if ("Unit of Measure Code" <> '') and ("Alternate Unit of Measure" <> '') and (not "Catch Alternate Qtys.") then
                    "Quantity (Alt.)" := Round(Quantity *
                      P800UOMFns.GetConversionFromTo("Item No.", "Unit of Measure Code", "Alternate Unit of Measure"), 0.00001);
            end;
        }
        field(11; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';

            trigger OnValidate()
            begin
                // P8000975
                ItemUOM.Get("Item No.", "Unit of Measure Code");
                "Qty. per Unit of Measure" := ItemUOM."Qty. per Unit of Measure";
                // P8000975
            end;
        }
        field(12; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
        }
        field(13; "Quantity (Alt.)"; Decimal)
        {
            Caption = 'Quantity (Alt.)';
        }
        field(100; "Item No."; Code[20])
        {
            Caption = 'Item No.';

            trigger OnValidate()
            begin
                Item.Get("Item No.");
                Description := Item.Description;
                "Description 2" := Item."Description 2";
                "Base Unit of Measure" := Item."Base Unit of Measure";
                "Unit of Measure Code" := Item."Base Unit of Measure";
                "Qty. per Unit of Measure" := 1; // P8000975
                "Alternate Unit of Measure" := Item."Alternate Unit of Measure";
                "Catch Alternate Qtys." := Item."Catch Alternate Qtys.";
            end;
        }
        field(101; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(102; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
        }
        field(103; "Base Unit of Measure"; Code[10])
        {
            Caption = 'Base Unit of Measure';
        }
        field(104; "Alternate Unit of Measure"; Code[10])
        {
            Caption = 'Alternate Unit of Measure';
        }
        field(105; "Catch Alternate Qtys."; Boolean)
        {
            Caption = 'Catch Alternate Qtys.';
        }
        field(200; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';

            trigger OnValidate()
            begin
                if ItemVariant.Get("Item No.", "Variant Code") then
                    "Variant Description" := ItemVariant.Description;
            end;
        }
        field(201; "Variant Description"; Text[100])
        {
            Caption = 'Variant Description';
        }
        field(300; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';

            trigger OnValidate()
            begin
                if LotInfo.Get("Item No.", "Variant Code", "Lot No.") then begin
                    "Expiration Date" := LotInfo."Expiration Date";
                    "Document No." := LotInfo."Document No.";
                    "Document Date" := LotInfo."Document Date";
                    Validate("Country/Region of Origin Code", LotInfo."Country/Region of Origin Code"); // P8000824A, P8001239
                end;
            end;
        }
        field(301; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
        }
        field(302; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(303; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(304; "Country/Region of Origin Code"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';

            trigger OnValidate()
            begin
                // P8001239
                if Country.Get("Country/Region of Origin Code") then
                    "Country/Region of Origin Name" := Country.Name;
                // P8001239
            end;
        }
        field(305; "Country/Region of Origin Name"; Text[50])
        {
            Caption = 'Country/Region of Origin Name';
        }
        field(600; UCC128; Code[250])
        {
            Caption = 'UCC128';
        }
        field(601; "UCC128 (Human Readable)"; Code[250])
        {
            Caption = 'UCC128 (Human Readable)';
        }
        field(1000; "Prod. Order Status"; Option)
        {
            Caption = 'Prod. Order Status';
            OptionCaption = 'Simulated,Planned,Firm Planned,Released,Finished';
            OptionMembers = Simulated,Planned,"Firm Planned",Released,Finished;
        }
        field(1001; "Prod. Order No."; Code[20])
        {
            Caption = 'Prod. Order No.';
        }
        field(1002; "Prod. Order Line No."; Integer)
        {
            Caption = 'Prod. Order Line No.';
        }
        field(1003; "Prod. Order Comp. Line No."; Integer)
        {
            Caption = 'Prod. Order Comp. Line No.';

            trigger OnValidate()
            var
                poComp: Record "Prod. Order Component";
                prePro: Record "Pre-Process Type";
                replenArea: Record "Replenishment Area";
                qtyToProcess: Decimal;
            begin
            end;
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
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        Country: Record "Country/Region";
        LotInfo: Record "Lot No. Information";
        ItemUOM: Record "Item Unit of Measure";
        P800UOMFns: Codeunit "Process 800 UOM Functions";

    procedure CreateUCC(FldList: Text[50])
    var
        ADCUCCBarcode: Record "UCC Barcode Data";
    begin
        // P8000703
        ADCUCCBarcode.Validate("Item No.", "Item No.");
        ADCUCCBarcode.Validate("Variant Code", "Variant Code");
        if "Unit of Measure Code" <> '' then
            ADCUCCBarcode.Validate("Unit of Measure Code", "Unit of Measure Code");
        ADCUCCBarcode.Validate(Quantity, Quantity);
        ADCUCCBarcode.Validate("Quantity (Alt.)", "Quantity (Alt.)");
        ADCUCCBarcode.Validate("Lot No.", "Lot No.");

        ADCUCCBarcode.CreateUCC(FldList);
        UCC128 := ADCUCCBarcode."UCC Code";
        "UCC128 (Human Readable)" := ADCUCCBarcode."UCC Code (Human Readable)";
    end;

    procedure SetExpirationDate()
    begin
        // P8001239
        if "Document Date" <> 0D then begin
            Item.Get("Item No.");
            if Format(Item."Expiration Calculation") <> '' then
                "Expiration Date" := CalcDate(Item."Expiration Calculation", "Document Date");
        end;
        // P8001239
    end;
}

