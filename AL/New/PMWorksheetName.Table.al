table 37002823 "PM Worksheet Name"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 31 AUG 06
    //   List of PM worksheet names
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'PM Worksheet Name';
    LookupPageID = "PM Worksheet Names";

    fields
    {
        field(2; Name; Code[10])
        {
            Caption = 'Name';
            NotBlank = true;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; Name)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        PMWorksheet.SetRange("PM Worksheet Name", Name);
        PMWorksheet.DeleteAll(true);
    end;

    var
        PMWorksheet: Record "PM Worksheet";
}

