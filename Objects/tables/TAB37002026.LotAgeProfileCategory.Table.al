table 37002026 "Lot Age Profile Category"
{
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Identifies the categories associated with an aging profile
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Lot Age Profile Category';

    fields
    {
        field(1; "Profile Code"; Code[10])
        {
            Caption = 'Profile Code';
            TableRelation = "Lot Age Profile";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Category Code"; Code[10])
        {
            Caption = 'Category Code';
            NotBlank = true;
            TableRelation = "Lot Age Category";

            trigger OnValidate()
            begin
                LotAgeCat.Get("Category Code");
                Description := LotAgeCat.Description;
            end;
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(5; "Duration (Days)"; Integer)
        {
            Caption = 'Duration (Days)';
            MinValue = 0;
        }
        field(6; "Beginning Age (Days)"; Integer)
        {
            Caption = 'Beginning Age (Days)';
            Editable = false;
        }
        field(11; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(12; "Quantity (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            Caption = 'Quantity (Alt.)';
            DecimalPlaces = 0 : 5;
        }
    }

    keys
    {
        key(Key1; "Profile Code", "Line No.")
        {
        }
        key(Key2; "Category Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        CalculateBeginningAge(false);
    end;

    trigger OnInsert()
    begin
        TestField("Category Code");
        CalculateBeginningAge(true);
    end;

    trigger OnModify()
    begin
        TestField("Category Code");
        CalculateBeginningAge(true);
    end;

    var
        LotAgeCat: Record "Lot Age Category";

    procedure CalculateBeginningAge(IncludeRecord: Boolean)
    var
        LotAgeCat: Record "Lot Age Profile Category";
        BegAge: Integer;
        CurrentRecProcessed: Boolean;
    begin
        LotAgeCat.SetRange("Profile Code", "Profile Code");
        LotAgeCat.SetFilter("Line No.", '<>%1', "Line No.");
        if LotAgeCat.Find('-') then
            repeat
                if IncludeRecord and (not CurrentRecProcessed) and ("Line No." < LotAgeCat."Line No.") then begin
                    "Beginning Age (Days)" := BegAge;
                    BegAge += "Duration (Days)";
                    CurrentRecProcessed := true;
                end;
                LotAgeCat."Beginning Age (Days)" := BegAge;
                LotAgeCat.Modify;
                BegAge += LotAgeCat."Duration (Days)";
            until LotAgeCat.Next = 0;

        if IncludeRecord and (not CurrentRecProcessed) then
            "Beginning Age (Days)" := BegAge;
    end;
}

