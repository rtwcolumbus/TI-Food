table 37002303 "Document Quote History"
{
    // PRW19.00.01
    // P8008172, To-Increase, Dayakar Battini, 09 DEC 16
    //   Lifecycle Management
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Quote History';

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "Sales Header"."No." WHERE("Document Type" = FIELD("Document Type"));
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(5; "Source No."; Integer)
        {
            Caption = 'Source No.';
        }
        field(15; "Log Date"; Date)
        {
            Caption = 'Log Date';
        }
        field(16; "Log Time"; Time)
        {
            Caption = 'Log Time';
        }
        field(17; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnLookup()
            var
                UserSelection: Codeunit "User Selection";
                User: Record User;
            begin
                // P800-MegaApp
                if UserSelection.Open(User) then
                    "User ID" := User."User Name";
            end;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Document Type", "Document No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Log Date" := Today();
        "Log Time" := Time();
        "User ID" := UserId();
    end;
}

