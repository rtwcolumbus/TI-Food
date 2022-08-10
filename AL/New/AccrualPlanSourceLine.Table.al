table 37002137 "Accrual Plan Source Line"
{
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PR4.00.04
    // P8000355A, VerticalSoft, Jack Reynolds, 19 JUL 06
    //   Add support for accrual groups
    // 
    // PRW16.00.04
    // P8000882, VerticalSoft, Ron Davidson, 19 NOV 10
    //   Added new field called Manual Entry for the users to check if they don't want the Batch Update process to remove this line.

    Caption = 'Accrual Plan Source Line';

    fields
    {
        field(1; "Accrual Plan Type"; Option)
        {
            Caption = 'Accrual Plan Type';
            OptionCaption = 'Sales,Purchase';
            OptionMembers = Sales,Purchase;
        }
        field(2; "Accrual Plan No."; Code[20])
        {
            Caption = 'Accrual Plan No.';
            TableRelation = "Accrual Plan"."No." WHERE(Type = FIELD("Accrual Plan Type"));
        }
        field(3; "Source Selection Type"; Option)
        {
            Caption = 'Source Selection Type';
            Editable = false;
            OptionCaption = 'Bill-to/Pay-to,Sell-to/Buy-from,Sell-to/Ship-to';
            OptionMembers = "Bill-to/Pay-to","Sell-to/Buy-from","Sell-to/Ship-to";
        }
        field(4; "Source Selection"; Option)
        {
            Caption = 'Source Selection';
            Editable = false;
            OptionCaption = 'All,Specific,Price Group,Accrual Group';
            OptionMembers = All,Specific,"Price Group","Accrual Group";
        }
        field(5; "Source Code"; Code[20])
        {
            Caption = 'Source Code';
            TableRelation = IF ("Accrual Plan Type" = CONST(Sales),
                                "Source Selection" = CONST(Specific)) Customer
            ELSE
            IF ("Accrual Plan Type" = CONST(Sales),
                                         "Source Selection" = CONST("Price Group")) "Customer Price Group"
            ELSE
            IF ("Accrual Plan Type" = CONST(Sales),
                                                  "Source Selection" = CONST("Accrual Group")) "Accrual Group".Code WHERE(Type = CONST(Customer))
            ELSE
            IF ("Accrual Plan Type" = CONST(Purchase),
                                                           "Source Selection" = CONST(Specific)) Vendor
            ELSE
            IF ("Accrual Plan Type" = CONST(Purchase),
                                                                    "Source Selection" = CONST("Accrual Group")) "Accrual Group".Code WHERE(Type = CONST(Vendor));

            trigger OnValidate()
            var
                OtherSourceLine: Record "Accrual Plan Source Line";
            begin
                if ("Source Selection" = "Source Selection"::All) then
                    TestField("Source Code", '');

                // P8000355A
                if "Source Selection" = "Source Selection"::"Accrual Group" then begin
                    OtherSourceLine.SetRange("Accrual Plan Type", "Accrual Plan Type");
                    OtherSourceLine.SetRange("Accrual Plan No.", "Accrual Plan No.");
                    OtherSourceLine.SetFilter("Source Code", '<>%1', "Source Code");
                    if OtherSourceLine.Find('-') then
                        Error(Text001, FieldCaption("Source Code"), OtherSourceLine."Source Code");
                end;
                // P8000355A

                if ("Source Code" <> xRec."Source Code") then
                    Validate("Source Ship-to Code", '');
            end;
        }
        field(6; "Source Ship-to Code"; Code[10])
        {
            Caption = 'Source Ship-to Code';
            TableRelation = IF ("Accrual Plan Type" = CONST(Sales),
                                "Source Selection Type" = CONST("Sell-to/Ship-to"),
                                "Source Selection" = CONST(Specific)) "Ship-to Address".Code WHERE("Customer No." = FIELD("Source Code"));

            trigger OnValidate()
            begin
                if ("Source Ship-to Code" <> '') then begin
                    if ("Accrual Plan Type" <> "Accrual Plan Type"::Sales) then
                        FieldError("Accrual Plan Type");
                    TestField("Source Selection", "Source Selection"::Specific);
                    TestField("Source Selection Type", "Source Selection Type"::"Sell-to/Ship-to");
                end;
            end;
        }
        field(7; "Start Date"; Date)
        {
            Caption = 'Start Date';

            trigger OnValidate()
            begin
                if ("End Date" <> 0D) and ("Start Date" > "End Date") then
                    Error(Text000, FieldCaption("Start Date"), FieldCaption("End Date"));
            end;
        }
        field(8; "End Date"; Date)
        {
            Caption = 'End Date';

            trigger OnValidate()
            begin
                if ("End Date" <> 0D) and ("Start Date" > "End Date") then
                    Error(Text000, FieldCaption("Start Date"), FieldCaption("End Date"));
            end;
        }
        field(9; "Manual Entry"; Boolean)
        {
            Caption = 'Manual Entry';
        }
    }

    keys
    {
        key(Key1; "Accrual Plan Type", "Accrual Plan No.", "Source Code", "Source Ship-to Code")
        {
        }
        key(Key2; "Source Selection", "Source Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        SearchMgmt.DeleteSourceLine(Rec);
    end;

    trigger OnInsert()
    begin
        SearchMgmt.InsertSourceLine(Rec);
    end;

    trigger OnModify()
    begin
        SearchMgmt.ModifySourceLine(Rec, xRec);
    end;

    trigger OnRename()
    begin
        SearchMgmt.DeleteSourceLine(xRec);
        SearchMgmt.InsertSourceLine(Rec);
    end;

    var
        AccrualPlan: Record "Accrual Plan";
        SearchMgmt: Codeunit "Accrual Search Management";
        Text000: Label '%1 is after %2.';
        Text001: Label '%1 must be %2.';

    procedure SetUpNewLine(LastPlanLine: Record "Accrual Plan Source Line")
    var
        OtherSourceLine: Record "Accrual Plan Source Line";
    begin
        if AccrualPlan.Get("Accrual Plan Type", "Accrual Plan No.") then begin
            Validate("Source Selection Type", AccrualPlan."Source Selection Type");
            Validate("Source Selection", AccrualPlan."Source Selection");
            // P8000355A
            if "Source Selection" = "Source Selection"::"Accrual Group" then begin
                OtherSourceLine.SetRange("Accrual Plan Type", "Accrual Plan Type");
                OtherSourceLine.SetRange("Accrual Plan No.", "Accrual Plan No.");
                if OtherSourceLine.Find('-') then
                    Validate("Source Code", OtherSourceLine."Source Code");
            end;
            // P8000355A
        end;
    end;

    procedure GetLineDescription(): Text[250]
    var
        Customer: Record Customer;
        PriceGroup: Record "Customer Price Group";
        Vendor: Record Vendor;
        AccrualGroup: Record "Accrual Group";
    begin
        if ("Source Selection" = "Source Selection"::All) then
            if ("Accrual Plan Type" = "Accrual Plan Type"::Sales) then
                exit(StrSubstNo('%1 %2s', "Source Selection", Customer.TableCaption))
            else
                exit(StrSubstNo('%1 %2s', "Source Selection", Vendor.TableCaption));
        if ("Source Code" = '') then
            exit('');

        case "Source Selection" of
            "Source Selection"::Specific:
                if ("Accrual Plan Type" = "Accrual Plan Type"::Sales) then begin
                    if Customer.Get("Source Code") then
                        exit(Customer.Name);
                end else begin
                    if Vendor.Get("Source Code") then
                        exit(Vendor.Name);
                end;
            "Source Selection"::"Price Group":
                if PriceGroup.Get("Source Code") then
                    exit(PriceGroup.Description);
            // P8000355A
            "Source Selection"::"Accrual Group":
                if AccrualGroup.Get("Accrual Plan Type", "Source Code") then
                    exit(AccrualGroup.Description);
                // P8000355A
        end;
        exit(StrSubstNo('%1 - %2', "Source Selection", "Source Code"));
    end;
}

