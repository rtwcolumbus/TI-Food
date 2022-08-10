table 37002092 "N138 Loading Dock"
{
    // PRW19.00.01
    // P8006916, To-Increase, Jack Reynolds, 31 AUG 16
    //   FOOD-TOM Separation
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Loading Dock';
    DrillDownPageID = "N138 Loading Docks";
    LookupPageID = "N138 Loading Docks";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(4; "Warehouse Receipt"; Integer)
        {
            CalcFormula = Count ("Warehouse Receipt Header" WHERE("Loading Dock" = FIELD("No.")));
            Caption = 'Warehouse Receipt';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        WhseShipmentHeader: Record "Warehouse Shipment Header";
    begin
    end;

    var
        Setup: Record "N138 Transport Mgt. Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
}

