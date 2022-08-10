table 37002065 "Pickup Load Header"
{
    // PR3.70.06
    // P8000080A, Myers Nissi, Steve Post, 30 AUG 04
    //   Added for Pickup Load Planning
    // 
    // PRW15.00.01
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   Add support for locations and delivery trips
    // 
    // PRW16.00
    // P8000639, VerticalSoft, Jack Reynolds, 18 NOV 08
    //   Add DropDown field group
    // 
    // PRW110.0.02
    // P80038979, To-Increase, Dayakar Battini, 18 DEC 17
    //   Adding Pickup load management functionality

    Caption = 'Pickup Load Header';
    DrillDownPageID = "Pickup Load List";
    LookupPageID = "Pickup Load List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                TestField(Status, Status::Open);

                if "No." <> xRec."No." then begin
                    PurchSetup.Get;
                    NoSeriesMgt.TestManual(PurchSetup."Pickup Load Nos.");
                end;
            end;
        }
        field(2; Carrier; Code[20])
        {
            Caption = 'Carrier';
            TableRelation = IF ("Truck Type" = CONST(Company)) "Delivery Route" WHERE("Location Code" = FIELD("Location Code"))
            ELSE
            IF ("Truck Type" = CONST("Common Carrier")) "Shipping Agent";

            trigger OnValidate()
            begin
                TestField(Status, Status::Open);
            end;
        }
        field(3; "Pickup Date"; Date)
        {
            Caption = 'Pickup Date';

            trigger OnValidate()
            begin
                TestField(Status, Status::Open);
                TestField("Delivery Trip No.", ''); // P8000549A
            end;
        }
        field(4; Temperature; Integer)
        {
            Caption = 'Temperature';

            trigger OnValidate()
            begin
                TestField(Status, Status::Open);
            end;
        }
        field(5; "Freight Charge"; Decimal)
        {
            Caption = 'Freight Charge';
            DecimalPlaces = 2 : 2;
            MinValue = 0;

            trigger OnValidate()
            begin
                TestField(Status, Status::Open);
            end;
        }
        field(6; "Due Date"; Date)
        {
            Caption = 'Due Date';

            trigger OnValidate()
            begin
                TestField(Status, Status::Open);
            end;
        }
        field(7; "Due Time"; Time)
        {
            Caption = 'Due Time';

            trigger OnValidate()
            begin
                TestField(Status, Status::Open);
            end;
        }
        field(8; "Truck Type"; Option)
        {
            Caption = 'Truck Type';
            OptionCaption = 'Company,Common Carrier';
            OptionMembers = Company,"Common Carrier";

            trigger OnValidate()
            begin
                TestField(Status, Status::Open);
                TestField("Delivery Trip No.", '');        // P8000549A
                if "Truck Type" <> xRec."Truck Type" then // P8000549A
                    Carrier := '';                          // P8000549A
            end;
        }
        field(9; Status; Option)
        {
            Caption = 'Status';
            Editable = true;
            OptionCaption = 'Open,Complete';
            OptionMembers = Open,Complete;
        }
        field(10; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));

            trigger OnValidate()
            var
                LoadLine: Record "Pickup Load Line";
            begin
                // P8000549A
                TestField("Delivery Trip No.", '');
                if "Location Code" <> xRec."Location Code" then begin
                    LoadLine.SetRange("Pickup Load No.", "No.");
                    if not LoadLine.IsEmpty then
                        Error(Text001, FieldCaption("Location Code"));
                end;
            end;
        }
        field(11; "Delivery Trip No."; Code[20])
        {
            Caption = 'Delivery Trip No.';
            TableRelation = "N138 Delivery Trip";

            trigger OnLookup()
            var
                DeliveryTrip: Record "N138 Delivery Trip";
                DeliveryTripList: Page "N138 Delivery Trip List";
            begin
                // P80038979
                TestField("Location Code");
                if "Location Code" <> '' then
                    DeliveryTrip.SetRange("Location Code", "Location Code");

                if "Pickup Date" <> 0D then
                    DeliveryTrip.SetRange("Departure Date", "Pickup Date");

                DeliveryTripList.SetTableView(DeliveryTrip);
                DeliveryTripList.LookupMode := true;
                if DeliveryTripList.RunModal = ACTION::LookupOK then begin
                    DeliveryTripList.GetRecord(DeliveryTrip);
                    Validate("Delivery Trip No.", DeliveryTrip."No.");
                end;
                // P80038975
            end;

            trigger OnValidate()
            var
                DeliveryTrip: Record "N138 Delivery Trip";
            begin
                if "Delivery Trip No." <> '' then begin
                    DeliveryTrip.Get("Delivery Trip No.");
                    TestField("Location Code");
                    if "Location Code" <> '' then
                        DeliveryTrip.TestField("Location Code", "Location Code");
                    if "Pickup Date" <> 0D then
                        DeliveryTrip.TestField("Departure Date", "Pickup Date")
                    else
                        "Pickup Date" := DeliveryTrip."Departure Date";
                    if DeliveryTrip."Shipping Agent Code" <> '' then begin
                        "Truck Type" := "Truck Type"::"Common Carrier";
                        Carrier := DeliveryTrip."Shipping Agent Code";
                    end;
                end else begin
                    Carrier := '';
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; Status)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", "Location Code", Carrier, "Pickup Date")
        {
        }
    }

    trigger OnDelete()
    var
        LoadDetail: Record "Pickup Load Line";
    begin
        TestField(Status, Status::Open);
        LoadDetail.SetRange("Pickup Load No.", "No.");
        LoadDetail.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        if "No." = '' then begin
            PurchSetup.Get;
            PurchSetup.TestField("Pickup Load Nos.");
            "No." := NoSeriesMgt.GetNextNo(PurchSetup."Pickup Load Nos.", WorkDate, true);
        end;
    end;

    var
        PurchSetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Text001: Label '%1 cannot be changed unless load is empty.';

    procedure AssistEdit(): Boolean
    var
        Dummy: Code[10];
    begin
        PurchSetup.Get;
        PurchSetup.TestField("Pickup Load Nos.");
        if NoSeriesMgt.SelectSeries(PurchSetup."Pickup Load Nos.", '', Dummy) then begin
            NoSeriesMgt.SetSeries("No.");
            exit(true);
        end;
    end;

    procedure Complete()
    var
        PickupLoadLine: Record "Pickup Load Line";
        PurchHeader: Record "Purchase Header";
    begin
        PickupLoadLine.SetRange("Pickup Load No.", "No.");
        PickupLoadLine.SetRange("Purchase Receipt No.", '');
        if PickupLoadLine.Find('-') then
            repeat
                if PurchHeader.Get(PurchHeader."Document Type"::Order, PickupLoadLine."Purchase Order No.") then begin
                    PurchHeader."Pickup Load No." := '';
                    PurchHeader.Modify;
                end;
                PickupLoadLine.Delete;
            until PickupLoadLine.Next = 0;

        Status := Status::Complete;
        Modify;
    end;
}

