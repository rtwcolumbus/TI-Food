table 37002066 "Pickup Load Line"
{
    // PR3.70.06
    // P8000080A, Myers Nissi, Jack Reynolds, 15 SEP 04
    //    Added for Pickup Load Planning
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 09 AUG 07
    //   Expand result of VemdorName function to 50 characters
    // 
    // PRW15.00.01
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   Add support for locations
    // 
    // PRW17.10.01
    // P8001258, Columbus IT, Jack Reynolds, 10 JAN 14
    //   Increase size ot text fields/variables
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Pickup Load Line';

    fields
    {
        field(1; "Pickup Load No."; Code[20])
        {
            Caption = 'Pickup Load No.';
            TableRelation = "Pickup Load Header";
        }
        field(2; "Sequence No."; Integer)
        {
            Caption = 'Sequence No.';

            trigger OnValidate()
            begin
                TestStatusOpen;
            end;
        }
        field(3; "Purchase Order No."; Code[20])
        {
            Caption = 'Purchase Order No.';
            NotBlank = true;
            TableRelation = "Purchase Header"."No." WHERE("Document Type" = CONST(Order));

            trigger OnValidate()
            var
                POHdr: Record "Purchase Header";
                PickupLocation: Record "Pickup Location";
            begin
                TestStatusOpen;

                if POHdr.Get(POHdr."Document Type"::Order, "Purchase Order No.") then begin
                    if not (POHdr."Pickup Load No." in ['', "Pickup Load No."]) then
                        Error(Text002, "Purchase Order No.", POHdr."Pickup Load No.");
                    POHdr.TestField("Location Code", LoadHeader."Location Code"); // P8000549A
                    if POHdr."Pickup Location Code" = '' then
                        Error(Text001, POHdr.FieldCaption("Pickup Location Code"));
                    PickupLocation.Get(POHdr."Buy-from Vendor No.", POHdr."Pickup Location Code");
                    "Pickup Location Code" := POHdr."Pickup Location Code";
                    POHdr."Pickup Load No." := "Pickup Load No.";
                    POHdr.Modify;
                end;
            end;
        }
        field(4; "Pickup Location Code"; Code[10])
        {
            Caption = 'Pickup Location Code';
            Editable = false;
        }
        field(5; "Purchase Receipt No."; Code[20])
        {
            Caption = 'Purchase Receipt No.';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Pickup Load No.", "Purchase Order No.")
        {
        }
        key(Key2; "Sequence No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        POHdr: Record "Purchase Header";
    begin
        TestStatusOpen;

        if POHdr.Get(POHdr."Document Type"::Order, "Purchase Order No.") then begin
            POHdr."Pickup Load No." := '';
            POHdr.Modify;
        end;
    end;

    trigger OnInsert()
    begin
        TestStatusOpen;
    end;

    var
        LoadHeader: Record "Pickup Load Header";
        Text001: Label '%1 must not be blank.';
        Text002: Label 'Order %1 is already assigned to load %2.';
        PurchHeader: Record "Purchase Header";
        PurchReceipt: Record "Purch. Rcpt. Header";

    procedure GetPurchHeader()
    begin
        if PurchHeader."No." <> "Purchase Order No." then
            if not PurchHeader.Get(PurchHeader."Document Type"::Order, "Purchase Order No.") then
                Clear(PurchHeader);
    end;

    procedure GetPurchReceipt()
    begin
        if PurchReceipt."No." <> "Purchase Receipt No." then
            if not PurchReceipt.Get("Purchase Receipt No.") then
                Clear(PurchReceipt);
    end;

    procedure GetLoadHeader()
    begin
        //IF LoadHeader."No." <> "Pickup Load No." THEN // P8000549A
        LoadHeader.Get("Pickup Load No.");              // P8000549A
    end;

    procedure VendorName(): Text[100]
    begin
        // P8000466A - expand result to TEXT50
        if "Purchase Receipt No." <> '' then begin
            GetPurchReceipt;
            exit(PurchReceipt."Buy-from Vendor Name");
        end else begin
            GetPurchHeader;
            exit(PurchHeader."Buy-from Vendor Name");
        end;
    end;

    procedure PickupLocationName(): Text[100]
    var
        PickupLocation: Record "Pickup Location";
        VendorNo: Code[20];
    begin
        // P8001258 - increase size or Return Value to Text50
        if "Purchase Receipt No." <> '' then begin
            GetPurchReceipt;
            VendorNo := PurchReceipt."Buy-from Vendor No.";
        end else begin
            GetPurchHeader;
            VendorNo := PurchHeader."Buy-from Vendor No.";
        end;
        if PickupLocation.Get(VendorNo, "Pickup Location Code") then
            exit(PickupLocation.Name);
    end;

    procedure TestStatusOpen()
    begin
        GetLoadHeader;
        LoadHeader.TestField(Status, LoadHeader.Status::Open);
    end;

    procedure LookupOrder(var Text: Text[1024]): Boolean
    var
        PurchHeader: Record "Purchase Header";
        PurchaseList: Page "Purchase List";
    begin
        // P8000549A
        GetLoadHeader;
        PurchHeader.FilterGroup(9);
        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
        PurchHeader.SetRange("Location Code", LoadHeader."Location Code");
        PurchHeader.FilterGroup(0);

        PurchaseList.LookupMode(true);
        PurchaseList.SetTableView(PurchHeader);
        if PurchHeader.Get(PurchHeader."Document Type"::Order, Text) then
            PurchaseList.SetRecord(PurchHeader);
        if PurchaseList.RunModal = ACTION::LookupOK then begin
            PurchaseList.GetRecord(PurchHeader);
            Text := PurchHeader."No.";
            exit(true);
        end;
    end;
}

