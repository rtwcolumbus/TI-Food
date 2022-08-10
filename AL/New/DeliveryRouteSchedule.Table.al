table 37002063 "Delivery Route Schedule"
{
    // PRW15.00.01
    // P8000547A, VerticalSoft, Jack Reynolds, 02 MAY 08
    //   Delivery route defaults by day of week
    // 
    // PRW16.00.05
    // P8000954, Columbus IT, Jack Reynolds, 08 JUL 11
    //   Support for transfer orders on delivery routes and trips
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Delivery Route Schedule';

    fields
    {
        field(1; "Delivery Route No."; Code[20])
        {
            Caption = 'Delivery Route No.';
            Editable = false;
        }
        field(2; "Day of Week"; Option)
        {
            Caption = 'Day of Week';
            Editable = false;
            OptionCaption = ',Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday';
            OptionMembers = ,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday;
        }
        field(3; Enabled; Boolean)
        {
            Caption = 'Enabled';

            trigger OnValidate()
            var
                SalesHeader: Record "Sales Header";
                PurchHeader: Record "Purchase Header";
                TransHeader: Record "Transfer Header";
                DeliveryRoute: Record "Delivery Route";
                DeliveryRouteMatrix: Record "Delivery Routing Matrix Line";
                DeliveryRouteMatrix2: Record "Delivery Routing Matrix Line";
                SalesFound: Boolean;
                PurchFound: Boolean;
                TransFound: Boolean;
                MsgText: Text[250];
            begin
                if not Enabled then begin
                    SalesHeader.SetCurrentKey("Document Type", "Shipment Date", "Delivery Route No.");
                    SalesHeader.SetFilter("Document Type", '%1|%2', SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Return Order");
                    SalesHeader.SetRange("Delivery Route No.", "Delivery Route No.");
                    if SalesHeader.FindSet(false, false) then
                        repeat
                            if SalesHeader."Shipment Date" <> 0D then // P8000954
                                SalesFound := Date2DWY(SalesHeader."Shipment Date", 1) = "Day of Week";
                        until (SalesHeader.Next = 0) or SalesFound;

                    // P8000954
                    PurchHeader.SetCurrentKey("Document Type", "Delivery Route No.");
                    PurchHeader.SetFilter("Document Type", '%1|%2', PurchHeader."Document Type"::Order, PurchHeader."Document Type"::"Return Order");
                    PurchHeader.SetRange("Delivery Route No.", "Delivery Route No.");
                    if PurchHeader.FindSet(false, false) then
                        repeat
                            if PurchHeader."Expected Receipt Date" <> 0D then
                                PurchFound := Date2DWY(PurchHeader."Expected Receipt Date", 1) = "Day of Week";
                        until (PurchHeader.Next = 0) or PurchFound;

                    TransHeader.SetCurrentKey("Delivery Route No.");
                    TransHeader.SetRange("Delivery Route No.", "Delivery Route No.");
                    if TransHeader.FindSet(false, false) then
                        repeat
                            if TransHeader."Shipment Date" <> 0D then
                                TransFound := Date2DWY(TransHeader."Shipment Date", 1) = "Day of Week";
                        until (TransHeader.Next = 0) or TransFound;
                    // P8000954

                    // P8000954
                    if SalesFound and PurchFound and TransFound then
                        MsgText := Text007
                    else
                        if SalesFound and PurchFound then
                            MsgText := StrSubstNo(Text004, Text005, Text006)
                        else
                            if SalesFound and TransFound then
                                MsgText := StrSubstNo(Text004, Text005, text008)
                            else
                                if PurchFound and TransFound then
                                    MsgText := StrSubstNo(Text004, Text006, text008)
                                else
                                    if SalesFound then
                                        MsgText := Text005
                                    else
                                        if PurchFound then
                                            MsgText := Text006
                                        else
                                            if TransFound then
                                                MsgText := text008;
                    // P8000954
                    if MsgText <> '' then
                        if not Confirm(Text003, false, MsgText, DeliveryRoute.TableCaption, "Delivery Route No.", "Day of Week") then
                            Error(Text002);

                    DeliveryRouteMatrix.SetCurrentKey("Delivery Route No.", "Day Of Week");
                    DeliveryRouteMatrix.SetRange("Delivery Route No.", "Delivery Route No.");
                    DeliveryRouteMatrix.SetRange("Day Of Week", "Day of Week");
                    if DeliveryRouteMatrix.FindSet(true, true) then
                        if Confirm(Text001, false, DeliveryRouteMatrix.TableCaption) then
                            repeat
                                DeliveryRouteMatrix2 := DeliveryRouteMatrix;
                                DeliveryRouteMatrix2.Validate("Delivery Route No.", '');
                                DeliveryRouteMatrix2.Validate("Delivery Stop No.", '');
                                if DeliveryRouteMatrix2.IsBlank then
                                    DeliveryRouteMatrix2.Delete(true)
                                else
                                    DeliveryRouteMatrix2.Modify(true);
                            until DeliveryRouteMatrix.Next = 0
                        else
                            Error(Text002);
                end;
            end;
        }
        field(10; "Default Driver No."; Code[20])
        {
            Caption = 'Default Driver No.';
            TableRelation = "Delivery Driver";

            trigger OnValidate()
            begin
                CalcFields("Default Driver Name");
            end;
        }
        field(11; "Default Driver Name"; Text[100])
        {
            CalcFormula = Lookup ("Delivery Driver".Name WHERE("No." = FIELD("Default Driver No.")));
            Caption = 'Default Driver Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(12; "Default Truck ID"; Code[10])
        {
            Caption = 'Default Truck ID';
        }
        field(13; "Default Departure Time"; Time)
        {
            Caption = 'Default Departure Time';
        }
    }

    keys
    {
        key(Key1; "Delivery Route No.", "Day of Week")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label 'Route has been selected in %1.  Continue?';
        Text002: Label 'Cancelled.';
        Text003: Label '%1 documents found for %2 %3 on %4.  Continue?';
        Text004: Label '%1 and %2';
        Text005: Label 'Sales';
        Text006: Label 'Purchase';
        Text007: Label 'Sales, Purchase, and Transfer';
        text008: Label 'Transfer';
}

