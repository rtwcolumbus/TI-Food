table 37002826 "Maintenance Cue"
{
    // PRW16.00.20
    // P8000671, VerticalSoft, Jack Reynolds, 30 JAN 09
    //   Cue table to support Maintenance Activities
    // 
    // PRW17.00.01
    // P8001154, Columbus IT, Jack Reynolds, 28 MAY 13
    //   Enlarge User ID field

    Caption = 'Maintenance Cue';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Orders Waiting Approval"; Integer)
        {
            CalcFormula = Count ("Work Order" WHERE(Status = CONST("Waiting Approval")));
            Caption = 'Orders Waiting Approval';
            Editable = false;
            FieldClass = FlowField;
        }
        field(3; "Orders Waiting Scheduling"; Integer)
        {
            CalcFormula = Count ("Work Order" WHERE(Status = CONST("Waiting Schedule")));
            Caption = 'Orders Waiting Scheduling';
            Editable = false;
            FieldClass = FlowField;
        }
        field(4; "Orders Waiting Parts"; Integer)
        {
            CalcFormula = Count ("Work Order" WHERE(Status = CONST("Waiting Parts")));
            Caption = 'Orders Waiting Parts';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "Orders Scheduled"; Integer)
        {
            CalcFormula = Count ("Work Order" WHERE(Status = CONST(Do)));
            Caption = 'Orders Scheduled';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6; "Orders In Work"; Integer)
        {
            CalcFormula = Count ("Work Order" WHERE(Status = CONST("In Work")));
            Caption = 'Orders In Work';
            Editable = false;
            FieldClass = FlowField;
        }
        field(7; "Purchase Orders"; Integer)
        {
            CalcFormula = Count ("Purchase Header" WHERE("Document Type" = CONST(Order),
                                                         "Assigned User ID" = FIELD("User ID Filter")));
            Caption = 'Purchase Orders';
            FieldClass = FlowField;
        }
        field(21; "User ID Filter"; Code[50])
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
}

