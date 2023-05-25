table 37002546 "Quality Control Cue"
{
    // PRw16.00.20
    // P8000685, VerticalSoft, Jack Reynolds, 29 APR 09
    //   Cue table to support Quality Control Activities
    // 
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW111.00.01
    // P80036649, To-Increase, Jack Reynolds, 28 AUG 18
    //   Incidents

    Caption = 'Quality Control Cue';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Pending Q/C Activities"; Integer)
        {
            CalcFormula = Count ("Quality Control Header" WHERE(Status = CONST(Pending)));
            Caption = 'Pending Q/C Activities';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; "Pending  Data Sheets"; Integer)
        {
            CalcFormula = Count ("Data Sheet Header" WHERE(Status = CONST(Pending)));
            Caption = 'Pending  Data Sheets';
            Editable = false;
            FieldClass = FlowField;
        }
        field(12; "In Progress Data Sheets"; Integer)
        {
            CalcFormula = Count ("Data Sheet Header" WHERE(Status = CONST("In Progress")));
            Caption = 'In Progress Data Sheets';
            Editable = false;
            FieldClass = FlowField;
        }
        field(13; "Open Alerts"; Integer)
        {
            CalcFormula = Count ("Data Collection Alert" WHERE(Status = CONST(Open)));
            Caption = 'Open Alerts';
            Editable = false;
            FieldClass = FlowField;
        }
        field(21; "Created Incidents"; Integer)
        {
            CalcFormula = Count ("Incident Entry" WHERE(Status = CONST(Created)));
            Caption = 'Created Incidents';
            Editable = false;
            FieldClass = FlowField;
        }
        field(22; "In Progress Incidents"; Integer)
        {
            CalcFormula = Count ("Incident Entry" WHERE(Status = CONST("In-Progress")));
            Caption = 'In Progress Incidents';
            Editable = false;
            FieldClass = FlowField;
        }
        field(23; "Assigned Incidents"; Integer)
        {
            CalcFormula = Count ("Incident Entry" WHERE(Status = CONST(Assigned)));
            Caption = 'Assigned Incidents';
            Editable = false;
            FieldClass = FlowField;
        }
        field(24; "To Be Approved Incidents"; Integer)
        {
            CalcFormula = Count ("Incident Entry" WHERE(Status = CONST("To Be Approved")));
            Caption = 'To Be Approved Incidents';
            Editable = false;
            FieldClass = FlowField;
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

