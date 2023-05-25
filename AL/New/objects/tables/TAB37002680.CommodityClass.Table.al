table 37002680 "Commodity Class"
{
    // PRW16.00.04
    // P8000856, VerticalSoft, Don Bresee, 24 AUG 10
    //   Add Commodity Class Costing granule
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Commodity Class';
    DataCaptionFields = Description;
    LookupPageID = "Commodity Classes";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "No. of Cost Components"; Integer)
        {
            BlankZero = true;
            CalcFormula = Count ("Comm. Cost Setup Line" WHERE("Commodity Class Code" = FIELD(Code)));
            Caption = 'No. of Cost Components';
            Editable = false;
            FieldClass = FlowField;
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

    trigger OnDelete()
    begin
        CommCostSetup.SetRange("Commodity Class Code", Code);
        CommCostSetup.DeleteAll(true);
    end;

    var
        CommCostSetup: Record "Comm. Cost Setup Line";
}

