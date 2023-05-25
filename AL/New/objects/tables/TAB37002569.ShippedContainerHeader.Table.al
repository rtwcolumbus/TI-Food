table 37002569 "Shipped Container Header"
{
    // PR3.70
    //   Make Closing Transaction, Document No., and Order No. non-editable
    // 
    // PR3.70.07
    // P8000140A, Myers Nissi, Jack Reynolds, 19 NOV 04
    //   Rename Serial No. to Container Serial No.
    // 
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add "Bin Code"
    // 
    // PRW17.10.01
    // P8001258, Columbus IT, Jack Reynolds, 10 JAN 14
    //   Increase size ot text fields/variables
    // 
    // PRW18.00.02
    // P8004554, To-Increase, Jack Reynolds, 27 OCT 15
    //   Renamed from Closed Container Header; support for delivery trip hiistory
    // 
    // PRW19.00
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup old delivery trips
    // 
    // PRW111.00.01
    // P80062661, To-Increase, Jack Reynolds, 25 JUL 18
    //   SSCC
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Shipped Container Header';
    DataCaptionFields = ID;
    DrillDownPageID = "Shipped Containers";
    LookupPageID = "Shipped Containers";

    fields
    {
        field(1; ID; Code[20])
        {
            Caption = 'ID';
            Editable = false;
        }
        field(2; "Container No."; Code[20])
        {
            Caption = 'Container No.';
            Editable = false;
            TableRelation = Item WHERE("Item Type" = CONST(Container));
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(4; "License Plate"; Code[50])
        {
            Caption = 'License Plate';
            Editable = false;
        }
        field(5; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            Editable = false;
            TableRelation = Location;
        }
        field(8; Comment; Boolean)
        {
            CalcFormula = Exist ("Container Comment Line" WHERE(Status = CONST(Closed),
                                                                "Container ID" = FIELD(ID)));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(9; "Container Serial No."; Code[50])
        {
            Caption = 'Serial No.';
            Editable = false;
        }
        field(10; "Creation Date"; Date)
        {
            Caption = 'Creation Date';
            Editable = false;
        }
        field(11; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            Editable = false;
        }
        field(13; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Editable = false;
        }
        field(14; "Item Description"; Text[100])
        {
            CalcFormula = Lookup (Item.Description WHERE("No." = FIELD("Item No.")));
            Caption = 'Item Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "Total Quantity (Base)"; Decimal)
        {
            CalcFormula = Sum ("Shipped Container Line"."Quantity (Base)" WHERE("Container ID" = FIELD(ID)));
            Caption = 'Total Quantity (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(19; "Container Type Code"; Code[10])
        {
            Caption = 'Container Type Code';
            TableRelation = "Container Type";
        }
        field(20; "Document Type"; Integer)
        {
            Caption = 'Document Type';
            Editable = false;
        }
        field(22; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
        }
        field(23; "Document Ref. No."; Integer)
        {
            Caption = 'Document Ref. No.';
            Editable = false;
        }
        field(101; SSCC; Code[18])
        {
            Caption = 'SSCC';
            Editable = false;
        }
        field(37002100; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            Description = 'P8000631A';
            Editable = false;
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));
        }
    }

    keys
    {
        key(Key1; ID, "Document Type", "Document No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label 'Sales Shipment';
        Text002: Label 'Purchase Return Shipment';
        Text003: Label 'Transfer Shipment';

    procedure DocumentType(): Text[30]
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
    begin
        // P8004554
        case "Document Type" of
            DATABASE::"Sales Shipment Line":
                exit(Text001);
            DATABASE::"Return Shipment Line":
                exit(Text002);
            DATABASE::"Transfer Shipment Line":
                exit(Text003);
        end;
    end;
}

