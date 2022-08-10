table 37002094 "N138 Trans. Cost Comp Template"
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
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Transport Cost Component Template';
    DrillDownPageID = "N138 Trans Cost Comp Templates";
    LookupPageID = "N138 Trans Cost Comp Templates";
    ReplicateData = false;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';

            trigger OnValidate()
            begin
                if Status = Status::Certified then
                    FieldError(Status);
            end;
        }
        field(3; Percentage; Decimal)
        {
            Caption = 'Percentage';
            DecimalPlaces = 0 : 2;

            trigger OnValidate()
            begin
                if Status = Status::Certified then
                    FieldError(Status);
            end;
        }
        field(4; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'New,Certified,Under Development,Closed';
            OptionMembers = New,Certified,"Under Development",Closed;

            trigger OnValidate()
            begin
                if Status = Status::Certified then
                    TestField(Percentage);
            end;
        }
        field(5; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.';
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true));

            trigger OnValidate()
            begin
                if Status = Status::Certified then
                    FieldError(Status);
            end;
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

