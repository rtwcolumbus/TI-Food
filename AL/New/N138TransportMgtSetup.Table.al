table 37002090 "N138 Transport Mgt. Setup"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 09-10-2014, Initial Version
    // --------------------------------------------------------------------------------
    // TOM4220     05-10-2015    Auto creation of warehouse shipment with delivery trip
    // --------------------------------------------------------------------------------
    // 
    // PRW18.00.01
    // P8001379, Columbus IT, Jack Reynolds, 31 MAR 15
    //   Add FOOD fields for unit of weight/volume
    // 
    // PRW19.00.01
    // P8006916, To-Increase, Jack Reynolds, 31 AUG 16
    //   FOOD-TOM Separation
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018

    Caption = 'Transport Management Setup';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(5; "Container Nos."; Code[20])
        {
            Caption = 'Container ID Nos.';
            TableRelation = "No. Series";
        }
        field(6; "Delivery Trip Nos."; Code[20])
        {
            Caption = 'Delivery Trip Nos.';
            TableRelation = "No. Series";
        }
        field(8; "Chck Shipped before Release"; Boolean)
        {
            Caption = 'Content must be Shipped before Release';
        }
        field(12; "Cost Warning"; Option)
        {
            Caption = 'Cost Warning';
            OptionCaption = ' ,Warning,Error';
            OptionMembers = " ",Warning,Error;
        }
        field(13; "Use Container Status Loaded"; Boolean)
        {
            Caption = 'Use Container Status Loaded';
        }
        field(14; "Auto Create Del. Trip Shipment"; Boolean)
        {
            Caption = 'Auto Create Del. Trip Shipment';
        }
        field(20; "Default Container Type"; Code[20])
        {
            Caption = 'Default Package Type';
        }
        field(37002063; "Delivery Trip Unit of Weight"; Code[10])
        {
            Caption = 'Delivery Trip Unit of Weight';
            TableRelation = "Unit of Measure" WHERE(Type = CONST(Weight));
        }
        field(37002064; "Delivery Trip Unit of Volume"; Code[10])
        {
            Caption = 'Delivery Trip Unit of Volume';
            TableRelation = "Unit of Measure" WHERE(Type = CONST(Volume));
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

