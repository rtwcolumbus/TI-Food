table 37002130 "Accrual Group"
{
    // PR3.61AC
    // 
    // PRW16.00
    // P8000639, VerticalSoft, Jack Reynolds, 18 NOV 08
    //   Add DropDown field group
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Accrual Group';
    DataCaptionFields = "Code", Description;
    LookupPageID = "Accrual Groups";

    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Customer,Vendor,Item';
            OptionMembers = Customer,Vendor,Item;
        }
        field(2; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(3; Description; Text[100])
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
        fieldgroup(DropDown; "Code", Description)
        {
        }
    }

    trigger OnDelete()
    begin
        AccrualGroupLine.Reset;
        AccrualGroupLine.SetRange("Accrual Group Type", Type);
        AccrualGroupLine.SetRange("Accrual Group Code", Code);
        AccrualGroupLine.DeleteAll(true);
    end;

    var
        Text000: Label '%1 %2 is not in the %3 %1 %4.';
        AccrualGroupLine: Record "Accrual Group Line";

    local procedure TestMemberOfGroup(GroupType: Integer; GroupCode: Code[10]; No: Code[20])
    begin
        AccrualGroupLine.Reset;
        AccrualGroupLine."Accrual Group Type" := GroupType;
        AccrualGroupLine."Accrual Group Code" := GroupCode;
        AccrualGroupLine."No." := No;
        if not AccrualGroupLine.Find then
            Error(Text000,
                  AccrualGroupLine."Accrual Group Type", AccrualGroupLine."No.",
                  AccrualGroupLine."Accrual Group Code", TableCaption);
    end;

    procedure TestMemberOfSourceGroup(PlanType: Integer; GroupCode: Code[10]; No: Code[20])
    var
        AccrualPlan: Record "Accrual Plan";
    begin
        case PlanType of
            AccrualPlan.Type::Sales:
                TestMemberOfGroup(Type::Customer, GroupCode, No);
            AccrualPlan.Type::Purchase:
                TestMemberOfGroup(Type::Vendor, GroupCode, No);
        end;
    end;

    procedure TestMemberOfItemGroup(GroupCode: Code[10]; ItemNo: Code[20])
    begin
        TestMemberOfGroup(Type::Item, GroupCode, ItemNo);
    end;

    local procedure IsMemberOfGroup(GroupType: Integer; GroupCode: Code[10]; No: Code[20]): Boolean
    begin
        exit(AccrualGroupLine.Get(GroupType, GroupCode, No));
    end;

    procedure IsMemberOfSourceGroup(PlanType: Integer; GroupCode: Code[10]; No: Code[20]): Boolean
    var
        AccrualPlan: Record "Accrual Plan";
    begin
        case PlanType of
            AccrualPlan.Type::Sales:
                exit(IsMemberOfGroup(Type::Customer, GroupCode, No));
            AccrualPlan.Type::Purchase:
                exit(IsMemberOfGroup(Type::Vendor, GroupCode, No));
        end;
    end;

    procedure IsMemberOfItemGroup(GroupCode: Code[10]; ItemNo: Code[20]): Boolean
    begin
        exit(IsMemberOfGroup(Type::Item, GroupCode, ItemNo));
    end;
}

