table 37002093 "N138 Delivery Trip History"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // TOM4554     27-10-2015  Additional history fields
    // --------------------------------------------------------------------------------
    // 
    // PRW19.00.01
    // P8006916, To-Increase, Dayakar Battini, 16 JUN 16
    //   FOOD-TOM Separation delete Transsmart objects
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    //
    // PRW111.00.03
    //   P80094579, To-Increase, Gangabhushan, 25 FEB 20
    //     CS00095752 - Loading Dock - Field Size mismatch
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Delivery Trip History';
    DrillDownPageID = "N138 Delivery Trip List";
    LookupPageID = "N138 Delivery Trip List";

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
        field(3; "Shipment Date"; Date)
        {
            Caption = 'Shipment Date';
        }
        field(5; Status; Option)
        {
            Caption = 'Status';
            Editable = false;
            OptionCaption = 'Open,Release to Deliver,Loading,Shipped';
            OptionMembers = Open,"Release to Deliver",Loading,Shipped;
        }
        field(7; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(10; "Driver No."; Code[20])
        {
            Caption = 'Driver No.';
            TableRelation = Resource."No." WHERE(Type = CONST(Person));
        }
        field(11; "Driver Name"; Text[100])
        {
            CalcFormula = Lookup (Resource.Name WHERE("No." = FIELD("No.")));
            Caption = 'Driver Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(12; "Truck ID"; Code[10])
        {
            Caption = 'Truck ID';
            TableRelation = "Delivery Truck";
        }
        field(14; "Loading Dock"; Code[20])
        {
            Caption = 'Loading Dock';
            TableRelation = "N138 Loading Dock";
        }
        field(60; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";
        }
        field(61; "Shipping Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            Editable = false;
            TableRelation = "Shipping Agent Services".Code WHERE("Shipping Agent Code" = FIELD("Shipping Agent Code"));

            trigger OnValidate()
            var
                lRecShipAgentService: Record "Shipping Agent Services";
            begin
            end;
        }
        field(97; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(37002060; "Delivery Route No."; Code[20])
        {
            Caption = 'Delivery Route No.';
            TableRelation = "Delivery Route";
            ValidateTableRelation = false;
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

    var
        Setup: Record "N138 Transport Mgt. Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;

    procedure OpenTransportCost()
    var
        PostedTransportCost: Record "N138 Posted Transport Cost";
        PostedTransportCosts: Page "N138 Posted Transport Costs";
    begin
        PostedTransportCost.SetRange("Source Type", DATABASE::"N138 Delivery Trip History");
        PostedTransportCost.SetRange("No.", "No.");
        PostedTransportCosts.SetTableView(PostedTransportCost);
        PostedTransportCosts.RunModal;
    end;
}

