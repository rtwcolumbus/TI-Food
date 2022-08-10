table 37002095 "N138 Trans. CC Template Line"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 09-10-2014, Initial Version
    // --------------------------------------------------------------------------------
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Transport Cost Component Template Line';

    fields
    {
        field(1; "Template Code"; Code[20])
        {
            Caption = 'Template Code';
            TableRelation = "N138 Trans. Cost Comp Template".Code;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';

            trigger OnValidate()
            begin
                lFncStatusCheck;
            end;
        }
        field(4; "Transport Cost Component"; Code[20])
        {
            Caption = 'Transport Cost Component';
            TableRelation = "N138 Transport Cost Component";

            trigger OnValidate()
            var
                lRecTransCC: Record "N138 Transport Cost Component";
            begin
                lFncStatusCheck;
                if "Transport Cost Component" <> '' then begin
                    if lRecTransCC.Get("Transport Cost Component") then
                        Description := lRecTransCC.Description;
                end else
                    Description := '';
            end;
        }
    }

    keys
    {
        key(Key1; "Template Code", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    local procedure lFncStatusCheck()
    var
        lRecTransCCTemp: Record "N138 Trans. Cost Comp Template";
    begin
        if lRecTransCCTemp.Get("Template Code") and (lRecTransCCTemp.Status = lRecTransCCTemp.Status::Certified) then
            lRecTransCCTemp.FieldError(Status);
    end;
}

