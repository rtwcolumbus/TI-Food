﻿table 27021 "SAT Federal Motor Transport"
{
    DataPerCompany = false;
    DrillDownPageID = "SAT Federal Motor Transports";
    LookupPageID = "SAT Federal Motor Transports";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[200])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

