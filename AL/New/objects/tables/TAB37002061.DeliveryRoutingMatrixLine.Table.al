table 37002061 "Delivery Routing Matrix Line"
{
    // PR3.10
    //   Delivery Routing
    // 
    // PR3.70.06
    // P8000079A, Myers Nissi, Jack Reynolds, 16 SEP 04
    //   Add day of week logic to table relation for Delivery Route No.
    // 
    // PRW15.00.01
    // P8000547A, VerticalSoft, Jack Reynolds, 02 MAY 08
    //   Modified to support routes for ship-to's, vendors, and order addresses
    // 
    // PRW16.00.05
    // P8000954, Columbus IT, Jack Reynolds, 08 JUL 11
    //   Support for transfer orders on delivery routes and trips
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Delivery Routing Matrix Line';

    fields
    {
        field(1; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            Editable = false;
            NotBlank = true;
            TableRelation = IF ("Source Type" = FILTER(Customer | "Ship-to")) Customer
            ELSE
            IF ("Source Type" = FILTER("Order Address")) Vendor
            ELSE
            IF ("Source Type" = CONST(Transfer)) Location;
        }
        field(2; "Day Of Week"; Option)
        {
            Caption = 'Day Of Week';
            OptionCaption = ',Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday';
            OptionMembers = ,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday;
        }
        field(3; "Delivery Route No."; Code[20])
        {
            Caption = 'Delivery Route No.';
            TableRelation = "Delivery Route";

            trigger OnValidate()
            begin
                // P8000547A
                if "Delivery Route No." <> '' then begin
                    DeliveryRouteSched.Get("Delivery Route No.", "Day Of Week");
                    DeliveryRouteSched.TestField(Enabled);
                end;
                // P8000547A

                CalcFields("Delivery Route Description");
            end;
        }
        field(4; "Delivery Stop No."; Code[20])
        {
            Caption = 'Delivery Stop No.';

            trigger OnValidate()
            begin
                // P8000547
                if "Delivery Stop No." <> '' then
                    if "Source Type" in ["Source Type"::Vendor, "Source Type"::"Order Address"] then
                        FieldError("Delivery Stop No.", Text001);
                // P8000547
            end;
        }
        field(5; "Standing Order No."; Code[20])
        {
            Caption = 'Standing Order No.';
            TableRelation = "Sales Header"."No." WHERE("Document Type" = FILTER(FOODStandingOrder),
                                                        "Sell-to Customer No." = FIELD("Source No."));

            trigger OnValidate()
            begin
                // P8000547
                if "Standing Order No." <> '' then
                    if "Source Type" <> "Source Type"::Customer then
                        FieldError("Standing Order No.", Text001);
                // P8000547
            end;
        }
        field(6; "Delivery Route Description"; Text[100])
        {
            CalcFormula = Lookup ("Delivery Route".Description WHERE("No." = FIELD("Delivery Route No.")));
            Caption = 'Delivery Route Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(7; "Source Type"; Option)
        {
            Caption = 'Source Type';
            OptionCaption = 'Customer,Ship-to,Vendor,Order Address,Transfer';
            OptionMembers = Customer,"Ship-to",Vendor,"Order Address",Transfer;
        }
        field(8; "Source No. 2"; Code[10])
        {
            Caption = 'Source No. 2';
            TableRelation = IF ("Source Type" = CONST("Ship-to")) "Ship-to Address".Code WHERE("Customer No." = FIELD("Source No."))
            ELSE
            IF ("Source Type" = CONST("Order Address")) "Order Address".Code WHERE("Vendor No." = FIELD("Source No."))
            ELSE
            IF ("Source Type" = CONST(Transfer)) Location;
        }
    }

    keys
    {
        key(Key1; "Source Type", "Source No.", "Source No. 2", "Day Of Week")
        {
        }
        key(Key2; "Delivery Route No.", "Day Of Week", "Delivery Stop No.")
        {
        }
        key(Key3; "Day Of Week", "Delivery Route No.", "Delivery Stop No.", "Standing Order No.")
        {
        }
        key(Key4; "Standing Order No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label 'must be blank';
        DeliveryRouteSched: Record "Delivery Route Schedule";

    procedure IsBlank(): Boolean
    begin
        exit(("Delivery Route No." = '') and
             ("Delivery Stop No." = '') and
             ("Standing Order No." = ''));
    end;

    procedure LookupRoute(var Text: Text[1024]): Boolean
    var
        Route: Record "Delivery Route";
        RouteList: Page "Delivery Route List";
    begin
        // P8000547A
        case "Day Of Week" of
            "Day Of Week"::Monday:
                Route.SetRange(Monday, true);
            "Day Of Week"::Tuesday:
                Route.SetRange(Tuesday, true);
            "Day Of Week"::Wednesday:
                Route.SetRange(Wednesday, true);
            "Day Of Week"::Thursday:
                Route.SetRange(Thursday, true);
            "Day Of Week"::Friday:
                Route.SetRange(Friday, true);
            "Day Of Week"::Saturday:
                Route.SetRange(Saturday, true);
            "Day Of Week"::Sunday:
                Route.SetRange(Sunday, true);
        end;

        RouteList.LookupMode(true);
        RouteList.SetTableView(Route);
        if RouteList.RunModal = ACTION::LookupOK then begin
            RouteList.GetRecord(Route);
            Text := Route."No.";
            exit(true);
        end;
    end;
}

