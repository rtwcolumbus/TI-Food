table 37002550 "Incident Reason Code"
{
    // PRW111.00.01
    // P80036649, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Incident/Complaint Registration
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Incident Reason Code';
    LookupPageID = "Incident Reason Codes";

    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Incident,Resolution';
            OptionMembers = Incident,Resolution;
        }
        field(3; "Code"; Code[20])
        {
            Caption = 'Code';
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; Type, "Code")
        {
        }
    }

    fieldgroups
    {
    }
}

