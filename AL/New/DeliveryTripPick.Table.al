table 37002068 "Delivery Trip Pick"
{
    // PRW15.00.01
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   New table - header for picks associated with delivery trips
    // 
    // PRW15.00.03
    // P8000630A, VerticalSoft, Don Bresee, 17 SEP 08
    //   Add Whse. logic to delivery trips
    // 
    // P8000644, VerticalSoft, Jack Reynolds, 25 NOV 08
    //   Support for total quantity, weight, volume
    // 
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add 1-Doc Whse Logic
    // 
    // PRW16.00
    // P8000639, VerticalSoft, Jack Reynolds, 18 NOV 08
    //   Add DropDown field group
    // 
    // PRW16.00.02
    // P8000746, VerticalSoft, Jack Reynolds, 04 MAR 10
    //   Modify for printing from ADC
    // 
    // PRW16.00.05
    // P8000954, Columbus IT, Jack Reynolds, 08 JUL 11
    //   Support for transfer orders on delivery routes and trips
    // 
    // P8000954, Columbus IT, Jack Reynolds, 08 JUL 11
    //   Support for transfer orders on delivery routes and trips
    // 
    // P8000962, Columbus IT, Jack Reynolds, 08 JUL 11
    //   Fix problem with no lot specified
    // 
    // P8000963, Columbus IT, Jack Reynolds, 19 OCT 11
    //   Remove deletion of PDF file after call to PrintPDFFile
    // 
    // PRW17.00
    // P8001141, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Cleanup ADC for NAV 2013
    // 
    // P8001168, Columbus IT, Don Bresee, 31 MAY 13
    //   Changes to P8000962 - Bypass lot check for lines with no handled quantity, Add BEGIN / END
    // 
    // PRW17.10.03
    // P8001335, Columbus IT, Jack Reynolds, 15 JUL 14
    //   Update Delivery Trip No. on Pick Lines
    // 
    // PRW19.00
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup old delivery trips
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Delivery Trip Pick';

    fields
    {
        field(1; "No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'No.';
            Editable = false;
        }
        field(2; "Delivery Trip No."; Code[20])
        {
            Caption = 'Delivery Trip No.';
            Editable = false;
            TableRelation = "Delivery Trip";
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            Editable = false;
            OptionCaption = 'Order,Class,Short';
            OptionMembers = "Order",Class,Short;
        }
        field(4; "Source Type"; Integer)
        {
            Caption = 'Source Type';
            Editable = false;
        }
        field(5; "Source Subtype"; Integer)
        {
            Caption = 'Source Subtype';
            Editable = false;
        }
        field(6; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            Editable = false;
        }
        field(7; "Pick Class Code"; Code[10])
        {
            Caption = 'Pick Class Code';
            Editable = false;
        }
        field(8; Status; Option)
        {
            Caption = 'Status';
            Editable = true;
            OptionCaption = 'Held,Pending,In Progress,Suspended,Completed';
            OptionMembers = Held,Pending,"In Progress",Suspended,Completed;
        }
        field(9; Picker; Code[20])
        {
            Caption = 'Picker';
        }
        field(10; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(11; "Departure Date"; Date)
        {
            Caption = 'Departure Date';
        }
        field(12; "Departure Time"; Time)
        {
            Caption = 'Departure Time';
        }
        field(20; "No. of Containers"; Integer)
        {
            CalcFormula = Count ("Pick Container Header" WHERE("Pick No." = FIELD("No.")));
            Caption = 'No. of Containers';
            Editable = false;
            FieldClass = FlowField;
        }
        field(21; "Quantity Handled"; Decimal)
        {
            CalcFormula = Sum ("Delivery Trip Pick Line"."Quantity Handled" WHERE("Pick No." = FIELD("No.")));
            Caption = 'Quantity Handled';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(22; "Weight Handled"; Decimal)
        {
            CalcFormula = Sum ("Delivery Trip Pick Line"."Weight Handled" WHERE("Pick No." = FIELD("No.")));
            Caption = 'Weight Handled';
            Editable = false;
            FieldClass = FlowField;
        }
        field(23; "Volume Handled"; Decimal)
        {
            CalcFormula = Sum ("Delivery Trip Pick Line"."Volume Handled" WHERE("Pick No." = FIELD("No.")));
            Caption = 'Volume Handled';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; "Delivery Trip No.", Type, "Source Type", "Source Subtype", "Source No.", "Pick Class Code")
        {
        }
        key(Key3; "Location Code", Status)
        {
        }
        key(Key4; "Departure Date", "Departure Time", Picker)
        {
        }
    }

    fieldgroups
    {
    }

    var
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        TransHeader: Record "Transfer Header";
        Text001: Label 'Sales';
        Text002: Label 'Purchase';
        Text007: Label 'Transfer Order';

    procedure DocumentType(): Text[30]
    begin
        if Type <> Type::Order then
            exit;

        case "Source Type" of
            DATABASE::"Sales Line":
                begin
                    SalesHeader."Document Type" := "Source Subtype";
                    exit(Text001 + ' ' + Format(SalesHeader."Document Type"));
                end;
            DATABASE::"Purchase Line":
                begin
                    PurchHeader."Document Type" := "Source Subtype";
                    exit(Text002 + ' ' + Format(PurchHeader."Document Type"));
                end;
            DATABASE::"Transfer Line":
                exit(Text007); // P8000954
        end;
    end;

    procedure SourceDescription(): Text[100]
    var
        PickClass: Record "Pick Class";
    begin
        case Type of
            Type::Order:
                exit(StrSubstNo('%1 %2', DocumentType, "Source No."));
            Type::Class:
                begin
                    PickClass.Get("Pick Class Code");
                    exit(StrSubstNo('%1 %2', "Pick Class Code", PickClass.Description));
                end;
            Type::Short:
                exit(Format(Type));
        end;
    end;

    procedure DestinationNo(): Code[20]
    begin
        if Type <> Type::Order then
            exit;

        case "Source Type" of
            DATABASE::"Sales Line":
                begin
                    if (SalesHeader."Document Type" <> "Source Subtype") or (SalesHeader."No." <> "Source No.") then
                        if not SalesHeader.Get("Source Subtype", "Source No.") then // P8000630A
                            Clear(SalesHeader);                                      // P8000630A
                    exit(Format(SalesHeader."Sell-to Customer No."));
                end;
            DATABASE::"Purchase Line":
                begin
                    if (PurchHeader."Document Type" <> "Source Subtype") or (PurchHeader."No." <> "Source No.") then
                        if not PurchHeader.Get("Source Subtype", "Source No.") then // P8000630A
                            Clear(PurchHeader);                                      // P8000630A
                    exit(Format(PurchHeader."Buy-from Vendor No."));
                end;
            // P8000954
            DATABASE::"Transfer Line":
                begin
                    if TransHeader."No." <> "Source No." then
                        if not TransHeader.Get("Source No.") then
                            Clear(TransHeader);
                    exit(Format(TransHeader."Transfer-from Code"));
                end;
                // P8000954
        end;
    end;

    procedure DestinationName(): Text[100]
    var
        DeliveryTrip: Record "Delivery Trip";
        DeliveryRoute: Record "Delivery Route";
        Location: Record Location;
    begin
        if Type = Type::Order then begin
            case "Source Type" of
                DATABASE::"Sales Line":
                    begin
                        if (SalesHeader."Document Type" <> "Source Subtype") or (SalesHeader."No." <> "Source No.") then
                            if not SalesHeader.Get("Source Subtype", "Source No.") then // P8000630A
                                Clear(SalesHeader);                                      // P8000630A
                        exit(Format(SalesHeader."Sell-to Customer Name"));
                    end;
                DATABASE::"Purchase Line":
                    begin
                        if (PurchHeader."Document Type" <> "Source Subtype") or (PurchHeader."No." <> "Source No.") then
                            if not PurchHeader.Get("Source Subtype", "Source No.") then // P8000630A
                                Clear(PurchHeader);                                      // P8000630A
                        exit(Format(PurchHeader."Buy-from Vendor Name"));
                    end;
                // P8000954
                DATABASE::"Transfer Line":
                    begin
                        if TransHeader."No." <> "Source No." then
                            if not TransHeader.Get("Source No.") then
                                Clear(TransHeader);
                        if Location.Get(TransHeader."Transfer-from Code") then
                            exit(Format(Location.Name));
                    end;
                    // P8000954
            end;
        end else begin
            DeliveryTrip.Get("Delivery Trip No.");
            if DeliveryTrip."Delivery Route No." <> '' then begin
                DeliveryRoute.Get(DeliveryTrip."Delivery Route No.");
                exit(StrSubstNo('%1 - %2', DeliveryRoute.Description, "Delivery Trip No."))
            end else
                exit("Delivery Trip No.");
        end;
    end;
}

