table 37002057 "Cost Basis Adjustment"
{
    // PRW116.00.05
    // P800103616, To-Increase, Gangabhushan, 04 FEB 21
    //  Enhance inventory costing with Book Cost   

    Caption = 'Cost Basis Adjustment';
    fields
    {
        field(1; "Cost Basis Code"; Code[20])
        {
            Caption = 'Cost Basis Code';
            TableRelation = "Cost Basis".Code;
        }
        field(2; Code; Code[20])
        {
            Caption = 'Code';

        }
        field(20; Type; Enum "Cost Basis Adjustment Type")
        {
            Caption = 'Adjustment Type';
        }
        field(30; Value; Decimal)
        {
            Caption = 'Value';
        }
        field(40; "Calculation Step"; Integer)
        {
            Caption = 'Calculation Step';
        }
    }

    keys
    {
        key(Key1; "Cost Basis Code", Code)
        {
            Clustered = true;
        }
        key(Key2; "Calculation Step")
        {

        }
    }
}