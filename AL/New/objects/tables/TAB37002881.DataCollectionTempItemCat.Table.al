table 37002881 "Data Collection Temp/Item Cat."
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Data Collection Temp/Item Cat.';

    fields
    {
        field(1; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            TableRelation = "Item Category";
        }
        field(3; "Template Code"; Code[10])
        {
            Caption = 'Template Code';
            TableRelation = "Data Collection Template" WHERE(Type = FILTER(<> Log));

            trigger OnValidate()
            begin
                CalcFields(Description, Type);
            end;
        }
        field(4; Description; Text[100])
        {
            CalcFormula = Lookup ("Data Collection Template".Description WHERE(Code = FIELD("Template Code")));
            Caption = 'Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; Type; Option)
        {
            CalcFormula = Lookup ("Data Collection Template".Type WHERE(Code = FIELD("Template Code")));
            Caption = 'Type';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = ' ,Q/C,Shipping,Receiving,Production,Log';
            OptionMembers = " ","Q/C",Shipping,Receiving,Production,Log;
        }
    }

    keys
    {
        key(Key1; "Item Category Code", "Template Code")
        {
        }
    }

    fieldgroups
    {
    }
}

