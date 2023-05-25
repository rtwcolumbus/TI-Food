table 37002078 "Dist. Planning Cue"
{
    // PRW16.00.03
    // P8000810, VerticalSoft, Don Bresee, 11 APR 10
    //   Create Distribution Planning Role Center
    // 
    // PRW17.00.01
    // P8001154, Columbus IT, Jack Reynolds, 28 MAY 13
    //   Enlarge User ID field

    Caption = 'Dist. Planning Cue';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "To Ship - Today"; Integer)
        {
            CalcFormula = Count ("Sales Header" WHERE("Document Type" = FILTER(Order),
                                                      Status = FILTER(Released),
                                                      Ship = FILTER(false),
                                                      "Shipment Date" = FIELD("Present Date Filter")));
            Caption = 'To Ship - Today';
            Editable = false;
            FieldClass = FlowField;
        }
        field(3; "Shipping Delayed"; Integer)
        {
            CalcFormula = Count ("Sales Header" WHERE("Document Type" = FILTER(Order),
                                                      Status = FILTER(Released),
                                                      "Shipment Date" = FIELD("Past Date Filter")));
            Caption = 'Shipping Delayed';
            Editable = false;
            FieldClass = FlowField;
        }
        field(4; "Partially Shipped"; Integer)
        {
            CalcFormula = Count ("Sales Header" WHERE("Document Type" = FILTER(Order),
                                                      Status = FILTER(Released),
                                                      Ship = FILTER(true),
                                                      "Completely Shipped" = FILTER(false)));
            Caption = 'Partially Shipped';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "To Pickup - Today"; Integer)
        {
            CalcFormula = Count ("Pickup Load Header" WHERE(Status = CONST(Open),
                                                            "Pickup Date" = FIELD("Present Date Filter")));
            Caption = 'To Pickup - Today';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6; "Pickup Delayed"; Integer)
        {
            CalcFormula = Count ("Pickup Load Header" WHERE(Status = CONST(Open),
                                                            "Pickup Date" = FIELD("Past Date Filter")));
            Caption = 'Pickup Delayed';
            Editable = false;
            FieldClass = FlowField;
        }
        field(7; "My Sales Orders"; Integer)
        {
            CalcFormula = Count ("Sales Header" WHERE("Document Type" = FILTER(Order),
                                                      "Assigned User ID" = FIELD("User ID Filter")));
            Caption = 'My Sales Orders';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "Present Date Filter"; Date)
        {
            Caption = 'Present Date Filter';
            Editable = false;
            FieldClass = FlowFilter;
        }
        field(21; "Past Date Filter"; Date)
        {
            Caption = 'Past Date Filter';
            Editable = false;
            FieldClass = FlowFilter;
        }
        field(22; "User ID Filter"; Code[50])
        {
            Caption = 'User ID Filter';
            FieldClass = FlowFilter;
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

    procedure SetFlowFilters()
    begin
        SetRange("Present Date Filter", WorkDate);
        SetFilter("Past Date Filter", '..%1', WorkDate - 1);
        SetRange("User ID Filter", UserId);
    end;
}

