table 37002559 "Incident Classification"
{
    // PRW111.00.01
    // P80036649, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Incident/Complaint Registration
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Incident Classification';
    DrillDownPageID = "Incident Classification Codes";
    LookupPageID = "Incident Classification Codes";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(204; "Incident Type"; Option)
        {
            Caption = 'Incident Type';
            OptionCaption = 'Material,Man,Machine';
            OptionMembers = Material,Man,Machine;
        }
        field(205; "Incident Area"; Option)
        {
            Caption = 'Incident Area';
            OptionCaption = ' ,Customer,Vendor,,Production,,Warehouse Activity,Resource,Third Party';
            OptionMembers = " ",Customer,Vendor,,Production,,"Warehouse Activity",Resource,"Third Party";
        }
        field(206; "Incident Area ID"; Integer)
        {
            Caption = 'Incident Area ID';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }
}

